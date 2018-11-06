IncendiaryGrenadeArbiter = IncendiaryGrenadeArbiter or class(IncendiaryGrenade)

function IncendiaryGrenadeArbiter:_detonate(normal)
	IncendiaryGrenadeArbiter.super._detonate(self, normal)
	print("IncendiaryGrenadeArbiter:_detonate")
end

function IncendiaryGrenadeArbiter:_spawn_environment_fire(normal)
	local position = self._unit:position()
	local rotation = self._unit:rotation()
	local data = tweak_data.env_effect:incendiary_fire_arbiter()

	EnvironmentFire.spawn(position, rotation, data, normal, self._thrower_unit, 0, 1)
	self._unit:set_slot(0)
end
