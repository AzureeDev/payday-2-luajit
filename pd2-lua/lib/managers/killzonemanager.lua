KillzoneManager = KillzoneManager or class()

function KillzoneManager:init()
	self._units = {}
end

function KillzoneManager:update(t, dt)
	for _, data in pairs(self._units) do
		if alive(data.unit) then
			if data.type == "sniper" then
				data.timer = data.timer + dt

				if data.next_shot < data.timer then
					local warning_time = 4
					data.next_shot = data.timer + math.rand(warning_time < data.timer and 0.5 or 1)
					local warning_shot = math.max(warning_time - data.timer, 1)
					warning_shot = math.rand(warning_shot) > 0.75

					if warning_shot then
						self:_warning_shot(data.unit)
					else
						self:_deal_damage(data.unit)
					end
				end
			elseif data.type == "gas" then
				data.timer = data.timer + dt

				if data.next_gas < data.timer then
					data.next_gas = data.timer + 0.25

					self:_deal_gas_damage(data.unit)
				end
			elseif data.type == "fire" then
				data.timer = data.timer + dt

				if data.next_fire < data.timer then
					data.next_fire = data.timer + 0.25

					self:_deal_fire_damage(data.unit)
				end
			elseif data.type == "laser" and not data.killed then
				data.timer = data.timer + dt

				if data.next_fire < data.timer then
					self:_kill_unit(data.unit)

					data.killed = true
				end
			end
		end
	end
end

function KillzoneManager:set_unit(unit, type)
	if self._units[unit:key()] then
		self:_remove_unit(unit)
	else
		self:_add_unit(unit, type)
	end
end

function KillzoneManager:_kill_unit(unit)
	if unit:character_damage():need_revive() then
		return
	end

	unit:character_damage():damage_killzone({
		instant_death = true
	})
end

function KillzoneManager:_warning_shot(unit)
	local rot = unit:camera():rotation()
	rot = Rotation(rot:yaw(), 0, 0)
	local pos = unit:position() + rot:y() * (100 + math.random(200))
	local dir = Rotation(math.rand(360), 0, 0):y()
	dir = dir:with_z(-0.4):normalized()
	local from_pos = pos + dir * -100
	local to_pos = pos + dir * 100
	local col_ray = World:raycast("ray", from_pos, to_pos, "slot_mask", managers.slot:get_mask("bullet_impact_targets"), "ignore_unit", unit)

	if col_ray and col_ray.unit then
		managers.game_play_central:play_impact_sound_and_effects({
			col_ray = col_ray
		})
	end
end

function KillzoneManager:_deal_damage(unit)
	if unit:character_damage():need_revive() then
		return
	end

	local col_ray = {}
	local ray = Rotation(math.rand(360), 0, 0):y()
	ray = ray:with_z(-0.4):normalized()
	col_ray.ray = ray
	local attack_data = {
		damage = 1,
		col_ray = col_ray
	}

	unit:character_damage():damage_killzone(attack_data)
end

function KillzoneManager:_deal_gas_damage(unit)
	local attack_data = {
		damage = 0.75,
		col_ray = {
			ray = math.UP
		}
	}

	unit:character_damage():damage_killzone(attack_data)
end

function KillzoneManager:_deal_fire_damage(unit)
	local attack_data = {
		damage = 0.5,
		col_ray = {
			ray = math.UP
		}
	}

	unit:character_damage():damage_killzone(attack_data)
end

function KillzoneManager:_add_unit(unit, type)
	if type == "sniper" then
		local next_shot = math.rand(1)
		self._units[unit:key()] = {
			timer = 0,
			type = type,
			next_shot = next_shot,
			unit = unit
		}
	elseif type == "gas" then
		local next_gas = math.rand(1)
		self._units[unit:key()] = {
			timer = 0,
			type = type,
			next_gas = next_gas,
			unit = unit
		}
	elseif type == "fire" then
		local next_fire = math.rand(1)
		self._units[unit:key()] = {
			timer = 0,
			type = type,
			next_fire = next_fire,
			unit = unit
		}
	elseif type == "laser" then
		local next_fire = math.rand(0.2)
		self._units[unit:key()] = {
			timer = 0,
			type = type,
			next_fire = next_fire,
			unit = unit
		}
	end
end

function KillzoneManager:_remove_unit(unit)
	self._units[unit:key()] = nil
end
