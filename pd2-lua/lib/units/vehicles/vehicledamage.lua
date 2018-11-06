VehicleDamage = VehicleDamage or class()
VehicleDamage.VEHICLE_DEFAULT_HEALTH = 100
VehicleDamage._HEALTH_GRANULARITY = 512

function VehicleDamage:init(unit)
	self._unit = unit

	self._unit:set_extension_update_enabled(Idstring("character_damage"), false)

	self._incapacitated = nil
	self._listener_holder = EventListenerHolder:new()
	self._health = VehicleDamage.VEHICLE_DEFAULT_HEALTH
	self._current_max_health = VehicleDamage.VEHICLE_DEFAULT_HEALTH
	self._next_allowed_dmg_t = Application:digest_value(-100, true)
	self._last_received_dmg = 0
	self._team_police = "law1"
	self._team_criminal = "criminal1"
	self._half_damaged_squence_played = false
end

function VehicleDamage:set_tweak_data(data)
	self._tweak_data = data
	self._current_max_health = self._tweak_data.damage.max_health
	self._health = self._tweak_data.damage.max_health
	self._HEALTH_INIT_PRECENT = self._current_max_health / self._HEALTH_GRANULARITY
end

function VehicleDamage:melee_hit_sfx()
	return "hit_gen"
end

function VehicleDamage:is_invulnerable()
	local result = false
	local players_count_inside_vehicle = self._unit:vehicle_driving():num_players_inside()

	if players_count_inside_vehicle <= 0 then
		result = true
	end

	return result
end

function VehicleDamage:is_friendly_fire(attacker_unit)
	local friendly_fire = false

	if not attacker_unit then
		return
	end

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		return false
	end

	friendly_fire = attacker_unit:movement():team().foes[self._team_criminal]

	return not friendly_fire
end

function VehicleDamage:damage_mission(dmg)
	local damage_info = {
		result = {
			variant = "killzone",
			type = "hurt"
		}
	}
	local attack_data = {
		variant = "killzone",
		damage = dmg
	}
	local result = damage_info.result
	local damage = attack_data.damage
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
	damage = damage_percent * self._HEALTH_INIT_PRECENT

	if self._health <= damage then
		attack_data.damage = self._health
		result = {
			type = "death",
			variant = attack_data.variant
		}

		self:die(attack_data.variant)
	else
		attack_data.damage = damage
		result = {
			type = "hurt",
			variant = attack_data.variant
		}
		self._health = self._health - damage
	end

	self:_health_recap(attack_data)

	local body_index = 1
	local hit_offset_height = 1

	self:_send_explosion_attack_result(attack_data, self._unit, damage_percent, self:_get_attack_variant_index("explosion"), attack_data.col_ray and attack_data.col_ray.ray)

	return result
end

function VehicleDamage:damage_bullet(attack_data)
	if self._unit:vehicle_driving() and not self._unit:vehicle_driving():is_vulnerable() then
		return
	end

	local damage_info = {
		result = {
			variant = "bullet",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}

	if Global.god_mode then
		if attack_data.damage > 0 then
			-- Nothing
		end

		self:_call_listeners(damage_info)

		return
	elseif self:is_invulnerable() then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	end

	local result = damage_info.result
	local damage = attack_data.damage
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
	damage = damage_percent * self._HEALTH_INIT_PRECENT

	self:_hit_direction(attack_data.col_ray)

	if self._health <= damage then
		attack_data.damage = self._health
		result = {
			type = "death",
			variant = attack_data.variant
		}

		self:die(attack_data.variant)
	else
		attack_data.damage = damage
		result = {
			type = "hurt",
			variant = attack_data.variant
		}
		self._health = self._health - damage
	end

	local attacker = attack_data.attacker_unit

	if attacker:id() == -1 then
		attacker = self._unit
	end

	if attack_data.attacker_unit == managers.player:player_unit() then
		managers.hud:on_hit_confirmed()
	end

	self:_health_recap(attack_data)

	local body_index = 1
	local hit_offset_height = 1

	self:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height)

	return result
end

function VehicleDamage:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height)
	self._unit:network():send("damage_bullet", attacker, damage_percent, body_index, hit_offset_height, 0, self:dead() and true or false)
end

function VehicleDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, variant, death)
	if self:dead() then
		return
	end

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {}
	local hit_pos = mvector3.copy(self._unit:position())

	mvector3.set_z(hit_pos, hit_pos.z + hit_offset_height)

	attack_data.pos = hit_pos
	local attack_dir, distance = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:position()
		distance = mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	local result = nil

	if death then
		result = {
			variant = "bullet",
			type = "death"
		}

		self:die(attack_data.variant)
	else
		result = {
			variant = "bullet",
			type = "hurt"
		}
		self._health = self._health - damage
		self._health_ratio = self._health / self._current_max_health
	end

	attack_data.variant = "bullet"
	attack_data.attacker_unit = attacker_unit
	attack_data.result = result
	attack_data.damage = damage

	self:_health_recap(attack_data)
	self:_send_sync_bullet_attack_result(attack_data, hit_offset_height)
	self:_on_damage_received(attack_data)
end

function VehicleDamage:_send_sync_bullet_attack_result(attack_data, hit_offset_height)
end

function VehicleDamage:stun_hit(attack_data)
	return nil
end

function VehicleDamage:damage_explosion(attack_data)
	if not self._unit:vehicle_driving():is_vulnerable() then
		return
	end

	local damage_info = {
		result = {
			variant = "explosion",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	end

	local result = damage_info.result
	local damage = attack_data.damage
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT

	if self._health <= damage then
		attack_data.damage = self._health
		result = {
			type = "death",
			variant = attack_data.variant
		}

		self:die(attack_data.variant)
	else
		attack_data.damage = damage
		result = {
			type = "hurt",
			variant = attack_data.variant
		}
		self._health = self._health - damage
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	self:_health_recap(attack_data)
	self:_send_explosion_attack_result(attack_data, attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)

	return result
end

function VehicleDamage:_send_explosion_attack_result(attack_data, attacker, damage_percent, i_attack_variant, direction)
	self._unit:network():send("damage_explosion_fire", attacker, damage_percent, i_attack_variant, self._dead and true or false, direction, attack_data.weapon_unit)
end

function VehicleDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, death, direction)
	Application:trace("[VehicleDamage:sync_damage_explosion]")

	if self._dead then
		return
	end

	local variant = "explosion"
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		variant = variant
	}
	local result = nil

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data.variant)

		slot10 = {
			variant = "explosion",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		}
	else
		result = {
			type = "explosion",
			variant = variant
		}
		self._health = self._health - damage
	end

	attack_data.attacker_unit = attacker_unit
	attack_data.result = result
	attack_data.damage = damage
	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		managers.hud:on_hit_confirmed()
	end

	self:_health_recap(attack_data)

	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_explosion_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

function VehicleDamage:_send_sync_explosion_attack_result(attack_data)
end

function VehicleDamage:damage_fire(attack_data)
	Application:trace("[VehicleDamage:damage_fire]")

	if not self._unit:vehicle_driving():is_vulnerable() then
		return
	end

	local damage_info = {
		result = {
			variant = "fire",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	end

	local result = damage_info.result
	local damage = attack_data.damage
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT

	if self._health <= damage then
		attack_data.damage = self._health
		result = {
			type = "death",
			variant = attack_data.variant
		}

		self:die(attack_data.variant)
	else
		attack_data.damage = damage
		result = {
			type = "hurt",
			variant = attack_data.variant
		}
		self._health = self._health - damage
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	self:_health_recap(attack_data)
	self:_send_fire_attack_result(attack_data, attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)

	return result
end

function VehicleDamage:_send_fire_attack_result(attack_data, attacker, damage_percent, i_attack_variant, direction)
	self._unit:network():send("damage_explosion_fire", attacker, damage_percent, i_attack_variant, self._dead and true or false, direction, attack_data.weapon_unit)
end

function VehicleDamage:sync_damage_fire(attacker_unit, damage_percent, i_attack_variant, death, direction)
	Application:trace("[VehicleDamage:sync_damage_fire]")

	if self._dead then
		return
	end

	local variant = "fire"
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		variant = variant
	}
	local result = nil

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data.variant)

		slot10 = {
			variant = "fire",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		}
	else
		result = {
			type = "fire",
			variant = variant
		}
		self._health = self._health - damage
	end

	attack_data.attacker_unit = attacker_unit
	attack_data.result = result
	attack_data.damage = damage
	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		managers.hud:on_hit_confirmed()
	end

	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_fire_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

function VehicleDamage:_send_sync_fire_attack_result(attack_data)
end

function VehicleDamage:damage_collision(attack_data)
	local local_player_seat = nil

	if managers.player:local_player() and managers.player:local_player():movement() and managers.player:local_player():movement()._current_state then
		local_player_seat = managers.player:local_player():movement()._current_state._seat
	end

	if local_player_seat and local_player_seat.driving then
		if not self._unit:vehicle_driving():is_vulnerable() then
			return
		end

		local damage_info = {
			result = {
				variant = "collision",
				type = "hurt"
			}
		}

		if Global.god_mode then
			if attack_data.damage > 0 then
				-- Nothing
			end

			self:_call_listeners(damage_info)

			return
		elseif self:is_invulnerable() then
			self:_call_listeners(damage_info)

			return
		elseif self:incapacitated() then
			return
		end

		local damage = attack_data.damage

		if self._health <= damage then
			attack_data.damage = self._health

			self:die(attack_data.variant)
		else
			attack_data.damage = damage
			self._health = self._health - damage
		end

		self:_health_recap()
		self:_send_vehicle_health(self._health)
	end
end

function VehicleDamage:_send_vehicle_health(health)
	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_ai_vehicle_action", "health", self._unit, health, nil)
	end
end

function VehicleDamage:sync_vehicle_health(health)
	self:set_health(tonumber(health))
	self:_health_recap()
end

function VehicleDamage:_on_damage_received(damage_info)
	self:_call_listeners(damage_info)
end

function VehicleDamage:_get_attack_variant_index(variant)
	for i, test_variant in ipairs(self._ATTACK_VARIANTS) do
		if variant == test_variant then
			return i
		end
	end

	debug_pause("variant not found!", variant, inspect(self._ATTACK_VARIANTS))

	return 1
end

function VehicleDamage:_calc_health_damage(attack_data)
	local health_subtracted = 0
	health_subtracted = self:get_real_health()

	self:change_health(-attack_data.damage)
	self:_set_health_effect()

	return health_subtracted
end

function VehicleDamage:get_real_health()
	return self._health
end

function VehicleDamage:change_health(change_of_health)
	self:set_health(self:get_real_health() + change_of_health)

	if self:get_real_health() < 0 then
		self:set_health(0)
	end
end

function VehicleDamage:incapacitated()
	return self._incapacitated
end

function VehicleDamage:revive()
	self:_revive()

	if managers.network and managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_ai_vehicle_action", "revive", self._unit, nil, nil)
	end
end

function VehicleDamage:_revive()
	self:set_health(self:_max_health())
	self._unit:vehicle_driving():set_state(VehicleDrivingExt.STATE_DRIVING, false)

	if self._unit:damage():has_sequence(VehicleDrivingExt.SEQUENCE_REPAIRED) then
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_REPAIRED)
	end

	self._half_damaged_squence_played = false
end

function VehicleDamage:sync_vehicle_revive()
	self:_revive()
end

function VehicleDamage:need_revive()
	return self.dead()
end

function VehicleDamage:dead()
	return self._health <= 0
end

function VehicleDamage:die()
	Application:trace("[VehicleDamage:die]")

	self._health = 0

	self._unit:vehicle_driving():on_vehicle_death()
end

function VehicleDamage:_chk_dmg_too_soon(damage)
	local next_allowed_dmg_t = type(self._next_allowed_dmg_t) == "number" and self._next_allowed_dmg_t or Application:digest_value(self._next_allowed_dmg_t, false)

	if damage <= self._last_received_dmg + 0.01 and managers.player:player_timer():time() < next_allowed_dmg_t then
		return true
	end
end

function VehicleDamage:_hit_direction(col_ray)
end

function VehicleDamage:_call_listeners(damage_info)
	self._listener_holder:call(damage_info.result.type, self._unit, damage_info)
end

function VehicleDamage:add_listener(key, events, clbk)
	events = events or self._all_event_types

	self._listener_holder:add(key, events, clbk)
end

function VehicleDamage:remove_listener(key)
	self._listener_holder:remove(key)
end

function VehicleDamage:set_health(health)
	self._health = health
end

function VehicleDamage:_max_health()
	return self._current_max_health
end

function VehicleDamage:_set_health_effect()
	local hp = self:get_real_health() / self:_max_health()

	math.clamp(hp, 0, 1)
end

function VehicleDamage:_get_attack_variant_index(variant)
	for i, test_variant in ipairs(CopDamage._ATTACK_VARIANTS) do
		if variant == test_variant then
			return i
		end
	end

	debug_pause("variant not found!", variant, inspect(self._ATTACK_VARIANTS))

	return 1
end

function VehicleDamage:_health_recap()
	if not self._half_damaged_squence_played and self:get_real_health() / self:_max_health() <= 0.5 then
		if self._unit:damage():has_sequence(VehicleDrivingExt.SEQUENCE_HALF_DAMAGED) then
			self._unit:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_HALF_DAMAGED)
		end

		self._half_damaged_squence_played = true
	end

	if self:get_real_health() <= 0 and self._unit:vehicle_driving():get_state_name() ~= VehicleDrivingExt.STATE_BROKEN then
		self:die()
	end
end
