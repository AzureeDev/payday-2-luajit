SmokeScreenGrenade = SmokeScreenGrenade or class(FragGrenade)

function SmokeScreenGrenade:_setup_server_data(...)
	SmokeScreenGrenade.super._setup_server_data(self, ...)

	if self._timer then
		self._timer = math.max(self._timer, 0.1)
	end
end

function SmokeScreenGrenade:set_thrower_unit(unit)
	SmokeScreenGrenade.super.set_thrower_unit(self, unit)

	self._has_dodge_bonus = self._thrower_unit ~= managers.player:player_unit() and self._thrower_unit:base():upgrade_value("player", "sicario_multiplier")
end

function SmokeScreenGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	end

	managers.player:spawn_smoke_screen(pos, normal, self._unit, self._has_dodge_bonus)
	managers.groupai:state():propagate_alert({
		"explosion",
		pos,
		range,
		managers.groupai:state("civilian_enemies"),
		self._unit
	})
end

function SmokeScreenGrenade:bullet_hit()
end

function SmokeScreenGrenade:_detonate_on_client()
	self:_detonate()
end

function SmokeScreenGrenade:update(unit, t, dt)
	if self._timer then
		self._timer = self._timer - dt

		if self._timer <= 0 and mvector3.length(self._unit:body("static_body"):velocity()) < 1 then
			self._timer = nil

			self:_detonate()
		end
	end

	ProjectileBase.update(self, unit, t, dt)
end

