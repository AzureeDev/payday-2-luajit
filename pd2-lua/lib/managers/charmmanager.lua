CharmManager = CharmManager or class()
CharmManager.beta = 0.8
CharmManager.inertia_factor = 15
CharmManager.falling_factor = 2
CharmManager.max_speed = 300
CharmManager.pitch_angle = 55
CharmManager.yaw_angle = 25
CharmManager.left_roll_angle = 25
CharmManager.right_roll_angle = 7
CharmManager.velocity_epsilon = 0.1
CharmManager.friction = 0.85
CharmManager.fps = 0.03333333333333333
CharmManager.inertia_duration = 0.16666666666666666
CharmManager.apply_inertia_epsilon = 25
CharmManager.cross_product_factor = 1000
CharmManager.weapon_velocity_factor = 400
CharmManager.weapon_z_clamp = 200
CharmManager.lower_random_value = -20
CharmManager.higher_random_value = 100
CharmManager.initialized = false
CharmManager.charms_found = false
CharmManager._fwd_dot = 0
CharmManager._right_dot = 0
CharmManager._up_dot = 0
CharmManager._inertia = 0
CharmManager._up = Vector3(0, 0, 1)
CharmManager._last_frame_timestamp = 0
CharmManager._prev_xy_forward = Vector3(0, 0, 0)
CharmManager._prev_weapon_rot = Rotation(0, 0, 0)
CharmManager._prev_charm_pos = nil
CharmManager._random_array = {}
CharmManager._index = 1
CharmManager._inertia_transpired = 0

function CharmManager:init()
end

function CharmManager:on_spawned()
	self.player = managers.player:local_player()
	self.player_body = self.player:body("inflict_reciever")
end

function CharmManager:update(t, dt)
	local weapon = nil

	if not self:_check_fps(t) then
		return
	end

	if self:is_game_running() then
		self:link_charms(self.player:inventory()._available_selections[1].unit)
		self:link_charms(self.player:inventory()._available_selections[2].unit)

		weapon = self.player:inventory():equipped_unit()

		self:_update_player_charm(t, dt, weapon)
	elseif self:is_menu_showing() and managers.menu_scene then
		if managers.menu_scene:is_character_posing() then
			if managers.menu_scene and managers.menu_scene._character_unit then
				local children = managers.menu_scene._character_unit:children()

				for i = 1, #children do
					if children[i]:base() and children[i]:base().assembled then
						local weapon = children[i]

						self:link_charms(weapon)
						self:_update_model_weapon_charm(t, dt, weapon)
					end
				end
			end
		elseif (managers.menu_scene:is_gun_interactable() or _G.IS_VR) and self:is_weapon_rotatable() then
			weapon = managers.menu_scene._item_unit.unit

			self:link_charms(weapon)
			self:_update_weapon_charm(t, dt, weapon)
		end
	end
end

function CharmManager:is_game_running()
	return (Global.load_level or Application:editor()) and self.player and alive(self.player) and self.player:inventory() and self.player:inventory()._available_selections and #self.player:inventory()._available_selections == 2
end

function CharmManager:is_menu_showing()
	return Global.load_start_menu or not Application:editor()
end

function CharmManager:is_weapon_rotatable()
	return managers.menu_scene._item_unit and managers.menu_scene._item_unit.unit and alive(managers.menu_scene._item_unit.unit)
end

function CharmManager:random_smoothed(random)
	self._random_array[self._index] = random
	local sum = 0

	for _, v in pairs(self._random_array) do
		sum = sum + v
	end

	sum = sum / table.getn(self._random_array)

	if self._index == 8 then
		self._index = 1
	else
		self._index = self._index + 1
	end

	return sum
end

function CharmManager:_update_player_charm(t, dt, weapon)
	if not weapon or not weapon:base().charm then
		return
	end

	local charm = alive(self.player) and alive(weapon) and weapon:base().charm

	if not charm then
		return
	end

	local charm_top = weapon:base().charm_top
	local charm_top_pos = self.player_body:position() - weapon:position()
	local orientation_rot = self:_orient_charm(weapon)
	local combined_velocity = self.player_body:velocity()
	local weapon_velocity = Vector3(0, 0, 0)

	if self._prev_charm_pos then
		weapon_velocity = (charm_top_pos - self._prev_charm_pos) * self.weapon_velocity_factor
		weapon_velocity = weapon_velocity:with_z(math.clamp(-weapon_velocity.z, -self.weapon_z_clamp, self.weapon_z_clamp))
	end

	self._prev_charm_pos = Vector3(charm_top_pos.x, charm_top_pos.y, charm_top_pos.z)
	local player_velocity = Vector3(combined_velocity.x, combined_velocity.y, combined_velocity.x)
	combined_velocity = combined_velocity + weapon_velocity
	local forward = self.player:camera():forward()
	local right = self.player:camera():right()
	local math_random = math.random(self.lower_random_value, self.higher_random_value) / 100
	local random = self:random_smoothed(math_random)
	local fwd_velocity = math.dot(player_velocity * random, forward)
	local wpn_fwd_velocity = math.clamp(math.dot(weapon_velocity * random, forward), -self.weapon_z_clamp, self.weapon_z_clamp) * 0.1
	fwd_velocity = fwd_velocity + wpn_fwd_velocity
	local wpn_side_velocity = -math.dot(weapon_velocity * random, right)
	local side_velocity = math.dot(player_velocity * random, right) + fwd_velocity
	side_velocity = side_velocity + wpn_side_velocity * 0.5
	local vert_velocity = math.dot(combined_velocity, self._up)
	local xy_forward = forward:with_z(0)
	local xy_cross = self._prev_xy_forward:cross(xy_forward)
	local xy_dot = self._prev_xy_forward:dot(xy_forward)
	self._fwd_dot = self._fwd_dot * self.beta + fwd_velocity * (1 - self.beta)
	self._right_dot = self._right_dot * self.beta + side_velocity * (1 - self.beta)
	self._up_dot = self._up_dot * self.beta + vert_velocity * (1 - self.beta)
	self._prev_xy_forward = xy_forward
	local has_inertia = math.abs(self._inertia) > 0
	local player_stopped = math.abs(fwd_velocity) < self.velocity_epsilon and math.abs(self._fwd_dot) > 1

	if player_stopped and self._inertia == 0 and self.apply_inertia_epsilon < math.abs(self._fwd_dot) then
		self._inertia = -self._fwd_dot * self.inertia_factor * self.fps
		self._inertia_transpired = 0
	end

	if has_inertia then
		if self.inertia_duration < self._inertia_transpired then
			self._inertia = 0
		else
			self._fwd_dot = (self._fwd_dot + self._inertia) * self.friction
			self._inertia_transpired = self._inertia_transpired + self.fps
		end
	end

	local curr_pitch = self:GetMappedRangeValueClamped(-self.max_speed, self.max_speed, -self.pitch_angle, self.pitch_angle, self._fwd_dot) + orientation_rot:pitch()
	local curr_yaw = self:GetMappedRangeValueClamped(-self.max_speed, self.max_speed, -self.yaw_angle, self.yaw_angle, self._fwd_dot) + orientation_rot:yaw()
	local curr_roll = self:GetMappedRangeValueClamped(-self.max_speed, self.max_speed, self.left_roll_angle, -self.left_roll_angle, self._right_dot) + orientation_rot:roll() + self:GetMappedRangeValueClamped(-self.max_speed, 0, -self.left_roll_angle * self.falling_factor, 0, self._up_dot)
	local charm_rot = Rotation(math.clamp(curr_yaw, -self.yaw_angle, self.yaw_angle), math.clamp(curr_pitch, -self.pitch_angle, self.pitch_angle), math.clamp(curr_roll, -self.left_roll_angle, self.right_roll_angle))

	charm_top:set_local_rotation(charm_rot)
	charm:set_moving()
end

function CharmManager:_update_weapon_charm(t, dt, weapon)
	if not alive(weapon) or not weapon:base() then
		return
	end

	local charm = weapon:base().charm
	local charm_top = weapon:base().charm_top

	if not charm and not charm_top then
		weapon:base().scanned = false

		return
	end

	local orientation_rot = self:_orient_charm(weapon)

	charm_top:set_local_rotation(orientation_rot)
	charm:set_moving()
end

function CharmManager:_update_model_weapon_charm(t, dt, weapon)
	if weapon and weapon:base().charm then
		local charm = weapon:base().charm
		local charm_top = weapon:base().charm_top

		if not charm and not charm_top then
			weapon:base().scanned = false

			return
		end

		local rot = weapon:rotation()

		charm_top:set_local_rotation(Rotation(0, rot:pitch(), 0))
		charm:set_moving()
	end
end

function CharmManager:_check_fps(t)
	local elapsed = t - self._last_frame_timestamp

	if elapsed < self.fps then
		return false
	else
		self._last_frame_timestamp = t

		return true
	end
end

function CharmManager:_orient_charm(weapon)
	local weapon_rot = weapon:rotation()
	local charm_pitch = self._prev_weapon_rot:pitch() * self.beta + weapon_rot:pitch() * (1 - self.beta)
	local charm_roll = self._prev_weapon_rot:roll() * self.beta + weapon_rot:roll() * (1 - self.beta)
	local prev_vec = Vector3(0, self._prev_weapon_rot:pitch(), self._prev_weapon_rot:roll())
	local charm_vec = Vector3(0, weapon_rot:pitch(), weapon_rot:roll())
	local diff_vec = prev_vec - charm_vec

	if diff_vec:length() >= 100 then
		charm_pitch = self._prev_weapon_rot:pitch()
		charm_roll = self._prev_weapon_rot:roll()
	end

	local rot = Rotation(0, math.clamp(charm_pitch, -self.pitch_angle, self.pitch_angle), math.clamp(charm_roll, -90, 0))
	self._prev_weapon_rot = rot

	return rot
end

function CharmManager:link_charms(weapon)
	if not alive(weapon) or not weapon:base() then
		return
	end

	if not weapon:base().scanned then
		local weapon_parts = weapon:base()._parts

		if weapon_parts then
			local part_names = table.map_keys(weapon_parts)

			for i = 1, #part_names do
				if part_names[i]:find("charm") then
					local charm = weapon_parts[part_names[i]].unit

					if not charm then
						return
					end

					local charm_base = charm:get_object(Idstring("g_base"))
					local charm_ring = charm:get_object(Idstring("a_charm"))
					local charm_top = charm:get_object(Idstring("g_charm_top"))
					local charm_body = charm:get_object(Idstring("g_charm"))

					if not charm_body or not charm_top or not charm_ring then
						return
					end

					charm_body:link(charm_ring)

					weapon:base().charm = charm
					weapon:base().charm_top = charm_ring
				end
			end

			weapon:base().scanned = true
		end
	end
end

function CharmManager:GetMappedRangeValueClamped(input_range_first, input_range_second, output_range_first, output_range_second, value)
	local m = (output_range_second - output_range_first) / (input_range_second - input_range_first)
	local b = output_range_first - m * input_range_first
	local y = m * value + b
	local output_min = math.min(output_range_first, output_range_second)
	local output_max = math.max(output_range_first, output_range_second)

	if y < output_min then
		y = output_min
	elseif output_max < y then
		y = output_max
	end

	return y
end
