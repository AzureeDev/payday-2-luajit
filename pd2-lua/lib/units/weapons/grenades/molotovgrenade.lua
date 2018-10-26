MolotovGrenade = MolotovGrenade or class(GrenadeBase)

function MolotovGrenade:init(unit)
	MolotovGrenade.super.super.init(self, unit)

	self._detonated = false
end

function MolotovGrenade:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity)
	self:_detonate(normal)
end

function MolotovGrenade:_detonate(normal)
	if self._detonated == false then
		self._detonated = true

		self:_spawn_environment_fire(normal)
		managers.network:session():send_to_peers_synched("sync_detonate_molotov_grenade", self._unit, "base", GrenadeBase.EVENT_IDS.detonate, normal)
	end
end

function MolotovGrenade:sync_detonate_molotov_grenade(event_id, normal)
	if event_id == GrenadeBase.EVENT_IDS.detonate then
		self:_detonate_on_client(normal)
	end
end

function MolotovGrenade:_detonate_on_client(normal)
	if self._detonated == false then
		self._detonated = true

		self:_spawn_environment_fire(normal)
	end
end

function MolotovGrenade:_spawn_environment_fire(normal)
	local position = self._unit:position()
	local rotation = self._unit:rotation()
	local data = tweak_data.env_effect:molotov_fire()

	EnvironmentFire.spawn(position, rotation, data, normal, self._thrower_unit, 0, 1)
	self._unit:set_slot(0)
end

function MolotovGrenade:bullet_hit()
	if not Network:is_server() then
		return
	end

	self:_detonate()
end

function MolotovGrenade:add_damage_result(unit, is_dead, damage_percent)
	if not alive(self._thrower_unit) or self._thrower_unit ~= managers.player:player_unit() then
		return
	end

	local unit_type = unit:base()._tweak_table
	local is_civlian = unit:character_damage().is_civilian(unit_type)
	local is_gangster = unit:character_damage().is_gangster(unit_type)
	local is_cop = unit:character_damage().is_cop(unit_type)

	if is_civlian then
		return
	end

	if is_dead then
		self:_check_achievements(unit, is_dead, damage_percent, 1, 1)
	end
end

