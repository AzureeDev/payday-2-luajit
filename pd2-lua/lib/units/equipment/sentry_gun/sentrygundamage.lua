SentryGunDamage = SentryGunDamage or class()
SentryGunDamage._HEALTH_GRANULARITY = CopDamage._HEALTH_GRANULARITY
SentryGunDamage._ATTACK_VARIANTS = CopDamage._ATTACK_VARIANTS
SentryGunDamage.can_be_critical = CopDamage.can_be_critical

function SentryGunDamage:init(unit)
	self._unit = unit
	self._parent_unit = nil
	self._ext_movement = unit:movement()

	unit:base():post_init()
	unit:brain():post_init()
	unit:movement():post_init()

	self._HEALTH_INIT = 10000
	self._SHIELD_HEALTH_INIT = 10000

	if self._shield_body_name then
		self._shield_body_name_ids = Idstring(self._shield_body_name)
	end

	if self._bag_body_name then
		self._bag_body_name_ids = Idstring(self._bag_body_name)
	end

	if self._invulnerable_body_names then
		self._invulnerable_bodies = {}
		local names_split = string.split(self._invulnerable_body_names, " ")

		for _, name_ids in ipairs(names_split) do
			self._invulnerable_bodies[name_ids:key()] = true
		end
	end

	self._health = self._HEALTH_INIT
	self._shield_health = self._SHIELD_HEALTH_INIT
	self._shield_smoke_level = 0
	self._shield_smoke_levels = {}

	table.insert(self._shield_smoke_levels, self._shield_smoke_level_1)
	table.insert(self._shield_smoke_levels, self._shield_smoke_level_2)
	table.insert(self._shield_smoke_levels, self._shield_smoke_level_3)

	self._num_shield_smoke_levels = table.getn(self._shield_smoke_levels)
	self._sync_dmg_leftover = 0

	if self._ignore_client_damage then
		if Network:is_server() then
			self._HEALTH_GRANULARITY = 5
		else
			self._health_ratio = 1
		end
	end

	self._HEALTH_INIT_PERCENT = self._HEALTH_INIT / self._HEALTH_GRANULARITY
	self._SHIELD_HEALTH_INIT_PERCENT = self._SHIELD_HEALTH_INIT / self._HEALTH_GRANULARITY
end

function SentryGunDamage:set_health(amount, shield_health_amount)
	self._health = amount
	self._HEALTH_INIT = amount
	self._HEALTH_INIT_PERCENT = self._HEALTH_INIT / self._HEALTH_GRANULARITY
	self._shield_health = shield_health_amount
	self._SHIELD_HEALTH_INIT = shield_health_amount
	self._SHIELD_HEALTH_INIT_PERCENT = self._SHIELD_HEALTH_INIT / self._HEALTH_GRANULARITY
end

function SentryGunDamage:sync_health(health_ratio)
	self._health_ratio = health_ratio / self._HEALTH_GRANULARITY

	if health_ratio == 0 then
		self:die()
	end
end

function SentryGunDamage:shoot_pos_mid(m_pos)
	mvector3.set(m_pos, self._ext_movement:m_head_pos())
end

function SentryGunDamage:on_marked_state(state)
	if state then
		self._marked_dmg_mul = self._marked_dmg_mul or tweak_data.upgrades.values.player.marked_enemy_damage_mul
	else
		self._marked_dmg_mul = nil
	end
end

function SentryGunDamage:damage_bullet(attack_data)
	if self._dead or self._invulnerable or Network:is_client() and self._ignore_client_damage or PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return
	end

	local hit_body = attack_data.col_ray.body
	local hit_body_name = hit_body:name()

	if self._invulnerable_bodies and self._invulnerable_bodies[hit_body_name:key()] then
		return
	end

	local hit_shield = attack_data.col_ray.body and hit_body_name == self._shield_body_name_ids
	local hit_bag = attack_data.col_ray.body and hit_body_name == self._bag_body_name_ids
	local dmg_adjusted = attack_data.damage

	if attack_data.attacker_unit == managers.player:player_unit() then
		self._char_tweak = tweak_data.weapon[self._unit:base():get_name_id()]
		local critical_hit, damage = CopDamage.roll_critical_hit(self, attack_data)
		dmg_adjusted = damage

		if critical_hit then
			managers.hud:on_crit_confirmed()
		else
			managers.hud:on_hit_confirmed()
		end
	end

	dmg_adjusted = dmg_adjusted * (self._marked_dmg_mul or 1)

	if hit_shield then
		dmg_adjusted = dmg_adjusted * tweak_data.weapon[self._unit:base():get_name_id()].SHIELD_DMG_MUL
	elseif hit_bag then
		dmg_adjusted = dmg_adjusted * tweak_data.weapon[self._unit:base():get_name_id()].BAG_DMG_MUL

		if self._bag_hit_snd_event then
			self._unit:sound_source():post_event(self._bag_hit_snd_event)
		end
	end

	dmg_adjusted = dmg_adjusted + self._sync_dmg_leftover
	local dmg_shield = nil

	if hit_shield and self._shield_health > 0 then
		dmg_shield = true
	end

	local result = {
		variant = "bullet",
		type = "dmg_rcv"
	}
	local damage_sync = self:_apply_damage(dmg_adjusted, dmg_shield, not dmg_shield, true, attack_data.attacker_unit, attack_data.variant)
	attack_data.result = result

	if self._ignore_client_damage then
		local health_percent = math.ceil(self._health / self._HEALTH_INIT_PERCENT)

		self._unit:network():send("sentrygun_health", health_percent)
	else
		if not damage_sync or damage_sync == 0 then
			return
		end

		local attacker = attack_data.attacker_unit

		if not attacker or attacker:id() == -1 then
			attacker = self._unit
		end

		local body_index = self._unit:get_body_index(hit_body_name)

		self._unit:network():send("damage_bullet", attacker, damage_sync, body_index, 0, 0, self._dead and true or false)
	end

	if not self._dead then
		self._unit:brain():on_damage_received(attack_data.attacker_unit)
	end

	local attacker_unit = attack_data and attack_data.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit == managers.player:player_unit() and attack_data then
		managers.player:on_damage_dealt(self._unit, attack_data)
	end

	managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)

	return result
end

function SentryGunDamage:stun_hit(attack_data)
	if self._dead or self._invulnerable then
		return
	end
end

function SentryGunDamage:damage_fire(attack_data)
	if self._dead or self._invulnerable or Network:is_client() and self._ignore_client_damage or attack_data.variant == "stun" or not tweak_data.weapon[self._unit:base():get_name_id()].FIRE_DMG_MUL then
		return
	end

	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit and PlayerDamage.is_friendly_fire(self, attacker_unit) then
		return
	end

	local damage = attack_data.damage * tweak_data.weapon[self._unit:base():get_name_id()].FIRE_DMG_MUL
	damage = damage * (self._marked_dmg_mul or 1)
	damage = damage + self._sync_dmg_leftover
	local damage_sync = self:_apply_damage(damage, true, true, true, attacker_unit, "fire")

	if self._ignore_client_damage then
		local health_percent = math.ceil(self._health / self._HEALTH_INIT_PERCENT)

		self._unit:network():send("sentrygun_health", health_percent)
	else
		if not damage_sync or damage_sync == 0 then
			return
		end

		local attacker = attack_data.attacker_unit

		if not attacker or attacker:id() == -1 then
			attacker = self._unit
		end

		local i_attack_variant = CopDamage._get_attack_variant_index(self, attack_data.variant)

		self._unit:network():send("damage_fire", attacker, damage_sync, false, self._dead and true or false, attack_data.col_ray.ray, nil, nil, false)
	end

	if not self._dead then
		self._unit:brain():on_damage_received(attack_data.attacker_unit)
	end

	local attacker_unit = attack_data and attack_data.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit == managers.player:player_unit() and attack_data then
		managers.player:on_damage_dealt(self._unit, attack_data)
	end
end

function SentryGunDamage:damage_explosion(attack_data)
	if self._dead or self._invulnerable or Network:is_client() and self._ignore_client_damage or attack_data.variant == "stun" or not tweak_data.weapon[self._unit:base():get_name_id()].EXPLOSION_DMG_MUL then
		return
	end

	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit and PlayerDamage.is_friendly_fire(self, attacker_unit) then
		return
	end

	local damage = attack_data.damage * tweak_data.weapon[self._unit:base():get_name_id()].EXPLOSION_DMG_MUL
	attack_data.damage = damage

	if attacker_unit and attacker_unit == managers.player:player_unit() then
		self._char_tweak = tweak_data.weapon[self._unit:base():get_name_id()]
		local critical_hit, crit_damage = CopDamage.roll_critical_hit(self, attack_data)
		damage = crit_damage

		if critical_hit then
			managers.hud:on_crit_confirmed()
		else
			managers.hud:on_hit_confirmed()
		end
	end

	damage = damage * (self._marked_dmg_mul or 1)
	damage = damage + self._sync_dmg_leftover
	local damage_sync = self:_apply_damage(damage, true, true, true, attacker_unit, "explosion")

	if self._ignore_client_damage then
		local health_percent = math.ceil(self._health / self._HEALTH_INIT_PERCENT)

		self._unit:network():send("sentrygun_health", health_percent)
	else
		if not damage_sync or damage_sync == 0 then
			return
		end

		local attacker = attack_data.attacker_unit

		if not attacker or attacker:id() == -1 then
			attacker = self._unit
		end

		local i_attack_variant = CopDamage._get_attack_variant_index(self, attack_data.variant)

		self._unit:network():send("damage_explosion_fire", attacker, damage_sync, i_attack_variant, self._dead and true or false, attack_data.col_ray.ray, attack_data.weapon_unit)
	end

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end

	local attacker_unit = attack_data and attack_data.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit == managers.player:player_unit() and attack_data then
		managers.player:on_damage_dealt(self._unit, attack_data)
	end
end

function SentryGunDamage:dead()
	return self._dead
end

function SentryGunDamage:needs_repair()
	return self._shield_health == 0
end

function SentryGunDamage:repair_shield()
	self._shield_health = self._SHIELD_HEALTH_INIT

	self:update_shield_smoke_level(self:shield_health_ratio())

	if self._shield_repaired_sequence_name then
		self._unit:damage():run_sequence_simple(self._shield_repaired_sequence_name)
	end

	self._shield_smoke_level = 0

	if Network:is_server() then
		self._unit:network():send("turret_repair_shield")
	end
end

function SentryGunDamage:health_ratio()
	return self._health / self._HEALTH_INIT
end

function SentryGunDamage:shield_health_ratio()
	return self._shield_health / self._SHIELD_HEALTH_INIT
end

function SentryGunDamage:focus_delay_mul()
	return 1
end

function SentryGunDamage:die(attacker_unit, variant, options)
	options = options or {}
	local sequence_death = options.sequence_death or self._death_sequence_name
	local sequence_shield_death = options.sequence_shield_death or self._death_with_shield_sequence_name
	local sequence_done = options.sequence_done or "done_turret_destroyed"
	local global_event = options.global_event or "turret_destroyed"

	if self._stats_name and attacker_unit == managers.player:player_unit() then
		local data = {
			name = self._stats_name,
			stats_name = self._stats_name,
			variant = variant
		}

		managers.statistics:killed(data)
	end

	self._health = 0
	self._dead = true

	self._unit:weapon():remove_fire_mode_interaction()
	self._unit:set_slot(26)
	self._unit:brain():set_active(false)
	self._unit:movement():set_active(false)
	self._unit:movement():on_death()
	managers.groupai:state():on_criminal_neutralized(self._unit)
	self._unit:base():on_death()
	self._unit:sound_source():post_event(self._breakdown_snd_event)

	self._shield_smoke_level = 0

	if self._unit:base():has_shield() and sequence_shield_death then
		self._unit:damage():run_sequence_simple(sequence_shield_death)
	elseif sequence_death then
		self._unit:damage():run_sequence_simple(sequence_death)
	end

	local turret_units = managers.groupai:state():turrets()

	if turret_units and table.contains(turret_units, self._unit) then
		if global_event then
			managers.mission:call_global_event("turret_destroyed")
		end

		if self._parent_unit ~= nil and self._parent_unit:damage():has_sequence(sequence_done) then
			self._parent_unit:damage():run_sequence_simple(sequence_done)
		end

		self._unit:contour():remove("mark_unit_friendly", true)
		self._unit:contour():remove("mark_unit_dangerous", true)
		managers.groupai:state():unregister_turret(self._unit)
	elseif alive(self._unit) then
		self._turret_destroyed_snd = self._unit:sound_source():post_event("wp_sentrygun_broken_loop")
	end

	self._unit:event_listener():call("on_death")
end

function SentryGunDamage:disable(attacker_unit, variant)
	self:die(attacker_unit, variant, {
		sequence_done = "done_turret_disabled",
		sequence_death = self._disable_sequence_name
	})
end

function SentryGunDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, variant, death)
	if self._dead then
		return
	end

	if death then
		self:die(attacker_unit, variant)

		return
	end

	local hit_body = self._unit:body(i_body)
	local hit_shield = hit_body:name() == self._shield_body_name_ids
	local dmg_shield = hit_shield and self._shield_health > 0
	local damage = death and "death" or damage_percent * (dmg_shield and self._SHIELD_HEALTH_INIT_PERCENT or self._HEALTH_INIT_PERCENT)

	self:_apply_damage(damage, dmg_shield, not dmg_shield, false, attacker_unit, variant)

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end
end

function SentryGunDamage:sync_damage_fire(attacker_unit, damage_percent, death, direction)
	if self._dead then
		return
	end

	if death then
		self:die(attacker_unit, "fire")

		return
	end

	local damage = death and "death" or damage_percent * self._HEALTH_INIT_PERCENT

	self:_apply_damage(damage, true, true, false, attacker_unit, "fire")

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end
end

function SentryGunDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, death, direction)
	if self._dead then
		return
	end

	if death then
		self:die(attacker_unit, "explosion")

		return
	end

	local variant = self._ATTACK_VARIANTS[i_attack_variant]
	local damage = death and "death" or damage_percent * self._HEALTH_INIT_PERCENT

	self:_apply_damage(damage, true, true, false, attacker_unit, "explosion")

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end
end

function SentryGunDamage:_apply_damage(damage, dmg_shield, dmg_body, is_local, attacker_unit, variant)
	self._sync_dmg_leftover = 0

	if dmg_shield and self._shield_health > 0 then
		local damage_percent = nil
		local shield_dmg = damage ~= "death" and damage or self._SHIELD_HEALTH_INIT

		if tweak_data.weapon[self._unit:base():get_name_id()].SHIELD_DAMAGE_CLAMP then
			shield_dmg = math.min(shield_dmg, tweak_data.weapon[self._unit:base():get_name_id()].SHIELD_DAMAGE_CLAMP)
		end

		if is_local then
			shield_dmg = shield_dmg * tweak_data.weapon[self._unit:base():get_name_id()].SHIELD_DMG_MUL
			local health_init_percent = self._SHIELD_HEALTH_INIT_PERCENT
			damage_percent = math.clamp(shield_dmg / health_init_percent, 0, self._HEALTH_GRANULARITY)
			local leftover_percent = damage_percent - math.floor(damage_percent)
			self._sync_dmg_leftover = leftover_percent * health_init_percent
			damage_percent = math.floor(damage_percent)
			shield_dmg = damage_percent * health_init_percent
		end

		if shield_dmg > 0 then
			if self._shield_health <= shield_dmg then
				damage = damage - self._shield_health
				self._shield_health = 0
				self._sync_dmg_leftover = 0

				if self._shield_destroyed_sequence_name then
					self._unit:damage():run_sequence_simple(self._shield_destroyed_sequence_name)
				end

				if self._shield_destroyed_snd_event then
					self._unit:sound_source():post_event(self._shield_destroyed_snd_event)
				end

				self:update_shield_smoke_level(self:shield_health_ratio())
			else
				self._shield_health = self._shield_health - shield_dmg
				damage = damage - shield_dmg

				self:update_shield_smoke_level(self:shield_health_ratio())
			end

			if not dmg_body then
				return damage_percent
			end
		end
	end

	if dmg_body then
		local damage_percent = nil
		local body_damage = damage ~= "death" and damage or self._HEALTH_INIT

		if tweak_data.weapon[self._unit:base():get_name_id()].BODY_DAMAGE_CLAMP then
			body_damage = math.min(body_damage, tweak_data.weapon[self._unit:base():get_name_id()].BODY_DAMAGE_CLAMP)
		end

		if is_local then
			local health_init_percent = self._HEALTH_INIT_PERCENT
			damage_percent = math.clamp(body_damage / health_init_percent, 0, self._HEALTH_GRANULARITY)
			local leftover_percent = damage_percent - math.floor(damage_percent)
			self._sync_dmg_leftover = self._sync_dmg_leftover + leftover_percent * health_init_percent
			damage_percent = math.floor(damage_percent)
			body_damage = damage_percent * health_init_percent
		end

		if body_damage == 0 then
			return
		end

		local previous_health_ratio = self:health_ratio()

		if self._health <= body_damage then
			self:die(attacker_unit, variant)
		else
			self._health = self._health - body_damage
		end

		self._unit:event_listener():call("on_damage_received", self:health_ratio())

		if not tweak_data.weapon[self._unit:base():get_name_id()].AUTO_REPAIR and not self._dead and previous_health_ratio >= 0.75 and self:health_ratio() < 0.75 and self._damaged_sequence_name then
			self._unit:damage():run_sequence_simple(self._damaged_sequence_name)
		end

		return damage_percent
	end
end

function SentryGunDamage:update_shield_smoke_level(ratio, up)
	ratio = math.clamp(ratio, 0, 1)
	local num_shield_smoke_levels = self._num_shield_smoke_levels
	local new_smoke_level = num_shield_smoke_levels - ratio * num_shield_smoke_levels

	if up then
		new_smoke_level = math.ceil(new_smoke_level)
	else
		new_smoke_level = math.floor(new_smoke_level)
	end

	if new_smoke_level ~= self._shield_smoke_level then
		self._shield_smoke_level = new_smoke_level

		self:_make_shield_smoke()

		if Network:is_server() then
			self._unit:network():send("turret_update_shield_smoke_level", ratio, up)
		end
	end
end

function SentryGunDamage:_make_shield_smoke()
	if self._shield_smoke_level == 0 then
		self._unit:damage():run_sequence_simple(self._shield_smoke_level_0)
	elseif self._shield_smoke_levels and self._shield_smoke_levels[self._shield_smoke_level] then
		self._unit:damage():run_sequence_simple(self._shield_smoke_levels[self._shield_smoke_level])
	end
end

function SentryGunDamage:save(save_data)
	local my_save_data = {}
	save_data.char_damage = my_save_data
	my_save_data.ignore_client_damage = self._ignore_client_damage
	my_save_data.health = self._health
	my_save_data.shield_health = self._shield_health
	my_save_data.HEALTH_INIT = self._HEALTH_INIT
	my_save_data.SHIELD_HEALTH_INIT = self._SHIELD_HEALTH_INIT
	my_save_data.shield_smoke_level = self._shield_smoke_level
end

function SentryGunDamage:load(save_data)
	if not save_data or not save_data.char_damage then
		return
	end

	local my_save_data = save_data.char_damage
	self._ignore_client_damage = my_save_data.ignore_client_damage
	self._health = my_save_data.health
	self._shield_health = my_save_data.shield_health
	self._shield_smoke_level = my_save_data.shield_smoke_level
	self._HEALTH_INIT = my_save_data.HEALTH_INIT
	self._SHIELD_HEALTH_INIT = my_save_data.SHIELD_HEALTH_INIT
	self._HEALTH_INIT_PERCENT = self._HEALTH_INIT / self._HEALTH_GRANULARITY
	self._SHIELD_HEALTH_INIT_PERCENT = self._SHIELD_HEALTH_INIT / self._HEALTH_GRANULARITY

	if self._health == 0 then
		self:die()
	end

	if self._shield_smoke_level > 0 then
		self:_make_shield_smoke()
	end
end

function SentryGunDamage:melee_hit_sfx()
	return "hit_gen"
end

function SentryGunDamage:destroy(unit)
	unit:brain():pre_destroy()
	unit:movement():pre_destroy()
	unit:base():pre_destroy()
end

function SentryGunDamage:shield_smoke_level()
	return self._shield_smoke_level
end

function SentryGunDamage:set_parent_unit(unit)
	self._parent_unit = unit
end
