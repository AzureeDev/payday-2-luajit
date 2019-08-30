NpcVehicleDamage = NpcVehicleDamage or class(VehicleDamage)
NpcVehicleDamage.VEHICLE_DEFAULT_HEALTH = 100
NpcVehicleDamage._HEALTH_GRANULARITY = 512

function NpcVehicleDamage:init(unit)
	VehicleDamage.init(self, unit)

	self._is_alive = true
end

function NpcVehicleDamage:damage_bullet(attack_data)
	local result = nil
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

function NpcVehicleDamage:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height)
	self._unit:network():send("damage_bullet", attacker, damage_percent, body_index, hit_offset_height, 0, self:dead() and true or false)
end

function NpcVehicleDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, variant, death)
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

function NpcVehicleDamage:_send_sync_bullet_attack_result(attack_data, hit_offset_height)
end

function NpcVehicleDamage:damage_explosion(attack_data)
	Application:trace("[NpcVehicleDamage:damage_explosion]")

	local result = nil
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

function NpcVehicleDamage:_send_explosion_attack_result(attack_data, attacker, damage_percent, i_attack_variant, direction)
	self._unit:network():send("damage_explosion_fire", attacker, damage_percent, i_attack_variant, self._dead and true or false, direction, attack_data.weapon_unit)
end

function NpcVehicleDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, death, direction)
	Application:trace("[NpcVehicleDamage:sync_damage_explosion]")

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

		local data = {
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

function NpcVehicleDamage:_send_sync_explosion_attack_result(attack_data)
end

function NpcVehicleDamage:damage_fire(attack_data)
	Application:trace("[NpcVehicleDamage:damage_fire]")

	local result = nil
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

function NpcVehicleDamage:_send_fire_attack_result(attack_data, attacker, damage_percent, i_attack_variant, direction)
	self._unit:network():send("damage_explosion_fire", attacker, damage_percent, i_attack_variant, self._dead and true or false, direction, attack_data.weapon_unit)
end

function NpcVehicleDamage:sync_damage_fire(attacker_unit, damage_percent, i_attack_variant, death, direction)
	Application:trace("[NpcVehicleDamage:sync_damage_fire]")

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

		local data = {
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

	self:_health_recap(attack_data)

	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_fire_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

function NpcVehicleDamage:_send_sync_fire_attack_result(attack_data)
end

function NpcVehicleDamage:damage_collision(attack_data)
	if Network:is_server() then
		if not self._unit:vehicle_driving():is_vulnerable() then
			return
		end

		local damage_info = {
			result = {
				variant = "collision",
				type = "hurt"
			}
		}
		local damage = attack_data.damage
		local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
		damage = damage_percent * self._HEALTH_INIT_PRECENT

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

function NpcVehicleDamage:is_friendly_fire(attacker_unit)
	local friendly_fire = false

	if not attacker_unit then
		return
	end

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		return false
	end

	friendly_fire = attacker_unit:movement():team().foes[self._team_police]

	return not friendly_fire
end

function NpcVehicleDamage:_health_recap()
	local current_health = self:get_real_health()

	if current_health <= 0 and self._is_alive then
		self._is_alive = false

		self._unit:npc_vehicle_driving():on_vehicle_death()
	end
end
