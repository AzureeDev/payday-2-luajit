HuskServerSyncedCivilianDamage = HuskServerSyncedCivilianDamage or class(HuskCivilianDamage)
HuskServerSyncedCivilianDamage._RESULT_NAME_TABLE = {
	"hurt",
	"light_hurt",
	"heavy_hurt",
	"death"
}

function HuskServerSyncedCivilianDamage:sync_damage_bullet(attacker_unit, hit_offset_height, result_index)
	if self._dead or self._fatal then
		return
	end

	local result_type = self._RESULT_NAME_TABLE[result_index]
	local result = {
		variant = "bullet",
		type = result_type
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + hit_offset_height)

	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = "bullet",
		attacker_unit = attacker_unit,
		attack_dir = attack_dir,
		pos = hit_pos,
		result = result
	}

	if result_type == "death" then
		self:die(attack_data.variant)
	end

	self:_on_damage_received(attack_data)
end

function HuskServerSyncedCivilianDamage:sync_damage_explosion(attacker_unit, result_index)
	if self._dead or self._fatal then
		return
	end

	local result_type = self._RESULT_NAME_TABLE[result_index]
	local result = {
		variant = "explosion",
		type = result_type
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + 130)

	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = "explosion",
		attacker_unit = attacker_unit,
		attack_dir = attack_dir,
		pos = hit_pos,
		result = result
	}

	if result_type == "death" then
		self:die(attack_data.variant)
	end

	self:_on_damage_received(attack_data)
end

function HuskServerSyncedCivilianDamage:sync_damage_fire(attacker_unit, result_index)
	if self._dead or self._fatal then
		return
	end

	local result_type = self._RESULT_NAME_TABLE[result_index]
	local result = {
		variant = "fire",
		type = result_type
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + 130)

	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = "fire",
		attacker_unit = attacker_unit,
		attack_dir = attack_dir,
		pos = hit_pos,
		result = result
	}

	if result_type == "death" then
		self:die(attack_data.variant)
	end

	self:_on_damage_received(attack_data)
end

function HuskServerSyncedCivilianDamage:sync_damage_melee(attacker_unit, attacker_unit, hit_offset_height, result_index)
	if self._dead or self._fatal then
		return
	end

	local result_type = self._RESULT_NAME_TABLE[result_index]
	local result = {
		variant = "melee",
		type = result_type
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + 130)

	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()

		mvector3.negate(attack_dir)
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = "melee",
		attacker_unit = attacker_unit,
		attack_dir = attack_dir,
		pos = hit_pos,
		result = result
	}

	if result_type == "death" then
		self:die(attack_data.variant)
	end

	self:_on_damage_received(attack_data)
end

function HuskServerSyncedCivilianDamage:damage_bullet(attack_data)
	if self._dead or self._fatal then
		return
	end

	local damage_abs, damage_percent = HuskServerSyncedCivilianDamage._clamp_health_percentage(self, attack_data.damage)

	if damage_percent > 0 then
		local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
		local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
		local attacker = attack_data.attacker_unit

		if attacker:id() == -1 then
			attacker = self._unit
		end

		self._unit:network():send_to_host("damage_bullet", attacker, damage_percent, body_index, hit_offset_height, 0, false)
	end
end

function HuskServerSyncedCivilianDamage:damage_explosion(attack_data)
	if self._dead or self._fatal then
		return
	end

	local damage_abs, damage_percent = HuskServerSyncedCivilianDamage._clamp_health_percentage(self, attack_data.damage)

	if damage_percent > 0 then
		local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
		local attacker = attack_data.attacker_unit

		if attacker:id() == -1 then
			attacker = self._unit
		end

		managers.hud:set_mugshot_damage_taken(self._unit:unit_data().mugshot_id)
	end
end

function HuskServerSyncedCivilianDamage:damage_fire(attack_data)
	if self._dead or self._fatal then
		return
	end

	local damage_abs, damage_percent = HuskServerSyncedCivilianDamage._clamp_health_percentage(self, attack_data.damage)

	if damage_percent > 0 then
		local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
		local attacker = attack_data.attacker_unit

		if attacker:id() == -1 then
			attacker = self._unit
		end

		managers.hud:set_mugshot_damage_taken(self._unit:unit_data().mugshot_id)
		self._unit:network():send_to_host("damage_fire", attacker, damage_percent, 1, hit_offset_height, 0)
	end
end

function HuskServerSyncedCivilianDamage:damage_melee(attack_data)
	if self._dead or self._fatal then
		return
	end

	local damage_abs, damage_percent = HuskServerSyncedCivilianDamage._clamp_health_percentage(self, attack_data.damage)

	if damage_percent > 0 then
		local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
		local attacker = attack_data.attacker_unit

		if attacker:id() == -1 then
			attacker = self._unit
		end

		managers.hud:set_mugshot_damage_taken(self._unit:unit_data().mugshot_id)
		self._unit:network():send_to_host("damage_melee", attacker, damage_percent, 1, hit_offset_height, 0)
	end
end

function HuskServerSyncedCivilianDamage:_clamp_health_percentage(health_abs)
	local damage = math.clamp(health_abs, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT

	return damage, damage_percent
end
