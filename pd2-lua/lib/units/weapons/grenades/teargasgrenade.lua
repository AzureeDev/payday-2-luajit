TearGasGrenade = TearGasGrenade or class()

function TearGasGrenade:init(unit)
	self._unit = unit
	self.radius = 0
	self.duration = 0
	self.damage = 0
end

function TearGasGrenade:destroy()
	if self._smoke_effect then
		World:effect_manager():fade_kill(self._smoke_effect)
	end
end

function TearGasGrenade:set_properties(props)
	self.radius = props.radius or 0
	self.duration = props.duration or 0
	self.damage = props.damage or 0

	if Network:is_server() then
		managers.network:session():send_to_peers("sync_tear_gas_grenade_properties", self._unit, self.radius, self.damage * 10)
	end
end

function TearGasGrenade:update(unit, t, dt)
	if Network:is_server() and self._remove_t and self._remove_t < t then
		self._unit:set_slot(0)

		return
	end

	if self._damage_t and self._damage_t < t then
		self._damage_t = self._damage_t + 1
		local player = managers.player:player_unit()
		local radius_sq = self.radius * self.radius
		local in_range = player and mvector3.distance_sq(player:position(), self._unit:position()) <= radius_sq

		if player and in_range then
			player:character_damage():damage_killzone({
				variant = "killzone",
				damage = self.damage,
				col_ray = {
					ray = math.UP
				}
			})
		end
	end
end

function TearGasGrenade:detonate()
	local now = TimerManager:game():time()
	self._remove_t = now + self.duration
	self._damage_t = now + 1
	local position = self._unit:position()
	local sound_source = SoundDevice:create_source("tear_gas_source")

	sound_source:set_position(position)
	sound_source:post_event("grenade_gas_explode")
	World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/explosion_smoke_grenade"),
		position = position,
		normal = self._unit:rotation():y()
	})

	local parent = self._unit:orientation_object()
	self._smoke_effect = World:effect_manager():spawn({
		effect = Idstring("effects/payday2/environment/cs_gas_damage_area"),
		parent = parent
	})

	if Network:is_server() then
		managers.network:session():send_to_peers("sync_tear_gas_grenade_detonate", self._unit)
	end
end
