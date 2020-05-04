EnvironmentFire = EnvironmentFire or class(UnitBase)
local unit_id = Idstring("units/payday2/environment/environment_fire_1/environment_fire_1")

function EnvironmentFire.spawn(position, rotation, data, normal, user_unit, added_time, range_multiplier)
	local unit = World:spawn_unit(unit_id, position, rotation)

	if unit then
		unit:base():on_spawn(data, normal, user_unit, added_time, range_multiplier)
	end

	return unit
end

function EnvironmentFire:init(unit)
	self._unit = unit
	self._burn_tick_counter = 0
	self._burn_duration = 0
	self._molotov_damage_effect_table = {}
end

function EnvironmentFire:get_name_id()
	return "environment_fire"
end

function EnvironmentFire:on_spawn(data, normal, user_unit, added_time, range_multiplier)
	local custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		effect = data.effect_name,
		sound_event = data.sound_event,
		feedback_range = data.range * 2,
		sound_event_burning = data.sound_event_burning,
		sound_event_impact_duration = data.sound_event_impact_duration,
		sound_event_duration = data.burn_duration + added_time
	}
	self._data = data
	self._normal = normal
	self._added_time = added_time
	self._range_multiplier = range_multiplier
	self._user_unit = user_unit
	self._burn_duration = data.burn_duration + added_time
	self._burn_tick_counter = 0
	self._burn_tick_period = data.burn_tick_period
	self._range = data.range * range_multiplier
	self._curve_pow = data.curve_pow
	self._damage = data.damage
	self._player_damage = data.player_damage
	self._fire_dot_data = deep_clone(data.fire_dot_data)
	self._fire_alert_radius = data.fire_alert_radius
	self._is_molotov = data.is_molotov
	self._hexes = data.hexes or 6
	local detonated_position = self._unit:position()
	local range = self._range
	local single_effect_radius = range
	local diagonal_distance = math.sqrt(math.pow(single_effect_radius * 2, 2) - math.pow(single_effect_radius, 2))
	local raycast = nil
	local slotmask = managers.slot:get_mask("molotov_raycasts")
	local vector, effect_id = nil

	if normal == nil or mvector3.length(normal) < 0.1 then
		normal = Vector3(0, 0, 1)
	end

	local tangent = Vector3(normal.z, normal.z, -normal.x - normal.y)

	if tangent.x == 0 and tangent.y == 0 and tangent.z == 0 then
		tangent = Vector3(-normal.y - normal.z, normal.x, normal.x)
	end

	mvector3.normalize(tangent)

	local offset = tangent

	mvector3.multiply(offset, single_effect_radius * 2)

	local rotation = Rotation()
	local position = self._unit:position()

	mrotation.set_axis_angle(rotation, normal, 60)

	vector = position + Vector3(0, 0, 0)
	raycast = World:raycast("ray", position, vector, "slot_mask", slotmask)
	local ray_cast2, fake_ball_main = nil

	if raycast == nil then
		local vector21 = vector + Vector3(0, 0, -150)
		raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector21, "slot_mask", slotmask)

		if raycast == nil then
			local vector41 = vector21 - 50 * normal
			raycast = World:raycast("ray", vector21 + 20 * normal, vector41, "slot_mask", slotmask)

			if raycast ~= nil then
				managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

				ray_cast2 = raycast
			else
				local vector31 = vector + Vector3(0, 0, -1500)
				raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector31, "slot_mask", slotmask)

				if raycast ~= nil then
					managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

					ray_cast2 = raycast
				end
			end
		else
			managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

			ray_cast2 = raycast
		end

		if ray_cast2 ~= nil then
			self._molotov_damage_effect_table[1].body = ray_cast2.body
			self._molotov_damage_effect_table[1].body_initial_position = ray_cast2.body:position()
			self._molotov_damage_effect_table[1].body_initial_rotation = ray_cast2.body:rotation()
			self._molotov_damage_effect_table[1].effect_initial_position = ray_cast2.position
			self._molotov_damage_effect_table[1].effect_initial_normal = ray_cast2.normal
		end
	end

	for i = 1, self._hexes do
		vector = position + offset
		raycast = World:raycast("ray", position, vector, "slot_mask", slotmask)
		local ray_cast, fake_ball_outline = nil

		if raycast == nil then
			local vector2 = vector + Vector3(0, 0, -150)
			raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector2, "slot_mask", slotmask)

			if raycast == nil then
				local vector4 = vector2 - 50 * normal
				raycast = World:raycast("ray", vector2 + 20 * normal, vector4, "slot_mask", slotmask)

				if raycast ~= nil then
					managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

					ray_cast = raycast
				else
					local vector3 = vector + Vector3(0, 0, -1500)
					raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector3, "slot_mask", slotmask)

					if raycast ~= nil then
						managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

						ray_cast = raycast
					end
				end
			else
				managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, custom_params, self._molotov_damage_effect_table)

				ray_cast = raycast
			end

			if ray_cast ~= nil then
				local tableSize = #self._molotov_damage_effect_table
				self._molotov_damage_effect_table[tableSize].body = ray_cast.body
				self._molotov_damage_effect_table[tableSize].body_initial_position = ray_cast.body:position()
				self._molotov_damage_effect_table[tableSize].body_initial_rotation = ray_cast.body:rotation()
				self._molotov_damage_effect_table[tableSize].effect_initial_position = ray_cast.position
				self._molotov_damage_effect_table[tableSize].effect_initial_normal = ray_cast.normal
			end
		else
			table.insert(self._molotov_damage_effect_table, nil)
		end

		mvector3.rotate_with(offset, rotation)
	end

	self._unit:set_visible(false)
end

function EnvironmentFire:update(unit, t, dt)
	if self._burn_duration <= 0 then
		self._unit:set_slot(0)
	else
		self._burn_duration = self._burn_duration - dt
		self._burn_tick_counter = self._burn_tick_counter + dt

		for _, damage_effect_entry in pairs(self._molotov_damage_effect_table) do
			local effect_body_alive = alive(damage_effect_entry.body)

			if effect_body_alive and damage_effect_entry.body ~= nil then
				local body_pos = damage_effect_entry.body:position()
				local distance = mvector3.distance(body_pos, damage_effect_entry.effect_initial_position)

				if distance >= 0.1 then
					mvector3.subtract(body_pos, damage_effect_entry.body_initial_position)

					local effect_new_location = damage_effect_entry.effect_initial_position + body_pos
					damage_effect_entry.effect_current_position = effect_new_location

					World:effect_manager():move(damage_effect_entry.effect_id, effect_new_location)
				end
			end
		end

		if self._burn_tick_period < self._burn_tick_counter then
			self:_do_damage()
		end
	end
end

function EnvironmentFire:_do_damage()
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")
	local player_in_range = false
	local player_in_range_count = 0

	if self._molotov_damage_effect_table then
		local collision_safety_distance = Vector3(0, 0, 5)
		local effect_position = nil
		local player_damage_range = range

		for _, damage_effect_entry in pairs(self._molotov_damage_effect_table) do
			if damage_effect_entry.body ~= nil then
				effect_position = damage_effect_entry.effect_current_position + collision_safety_distance
				local damage_range = range

				if _ == 1 then
					damage_range = range * 1.5
				end

				if managers.player:player_unit() then
					local player_distance = mvector3.distance(damage_effect_entry.effect_current_position, managers.player:player_unit():position())

					if player_distance <= damage_range and player_in_range == false then
						local raycast = World:raycast("ray", effect_position, managers.player:player_unit():position() + Vector3(0, 0, 30), "slot_mask", slot_mask)
						local raycast2 = World:raycast("ray", effect_position, managers.player:player_unit():position() + Vector3(0, 0, 0), "slot_mask", slot_mask)

						if raycast == nil or raycast2 == nil then
							player_in_range = true
							player_in_range_count = player_in_range_count + 1
							pos = damage_effect_entry.effect_current_position
							player_damage_range = damage_range
						end
					end
				end

				if Network:is_server() then
					local hit_units, splinters = managers.fire:detect_and_give_dmg({
						player_damage = 0,
						push_units = false,
						hit_pos = effect_position,
						range = damage_range,
						collision_slotmask = slot_mask,
						curve_pow = self._curve_pow,
						damage = self._damage,
						ignore_unit = self._unit,
						user = self._user_unit,
						owner = self._unit,
						alert_radius = self._fire_alert_radius,
						fire_dot_data = self._fire_dot_data,
						is_molotov = self._is_molotov
					})
				end
			end
		end

		if player_in_range == true then
			managers.fire:give_local_player_dmg(pos, player_damage_range, self._player_damage)
		end
	end

	self._burn_tick_counter = 0
end

function EnvironmentFire:destroy(unit)
	for _, damage_effect_entry in pairs(self._molotov_damage_effect_table) do
		World:effect_manager():fade_kill(damage_effect_entry.effect_id)
	end
end

function EnvironmentFire:save(data)
	local state = {
		burn_duration = self._burn_duration,
		user_unit = self._user_unit,
		burn_duration = self._burn_duration,
		burn_tick_counter = self._burn_tick_counter,
		burn_tick_period = self._burn_tick_period,
		range = self._range,
		curve_pow = self._curve_pow,
		damage = self._damage,
		player_damage = self._player_damage,
		fire_dot_data = self._fire_dot_data,
		fire_alert_radius = self._fire_alert_radius,
		is_molotov = self._is_molotov,
		hexes = self._hexes or 6,
		data = self._data,
		normal = self._normal,
		added_time = self._added_time,
		range_multiplier = self._range_multiplier
	}
	data.EnvironmentFire = state
end

function EnvironmentFire:load(data)
	local state = data.EnvironmentFire
	self._burn_duration = state.burn_duration
	self._user_unit = state.user_unit
	self._burn_duration = state.burn_duration
	self._burn_tick_counter = state.burn_tick_counter
	self._burn_tick_period = state.burn_tick_period
	self._range = state.range
	self._curve_pow = state.curve_pow
	self._damage = state.damage
	self._player_damage = state.player_damage
	self._fire_dot_data = state.fire_dot_data
	self._fire_alert_radius = state.fire_alert_radius
	self._is_molotov = state.is_molotov
	self._hexes = state.hexes or 6
	local data = state.data
	local normal = state.normal
	local added_time = state.added_time
	local range_multiplier = state.range_multiplier

	self:on_spawn(data, normal, self._user_unit, added_time, range_multiplier)
end
