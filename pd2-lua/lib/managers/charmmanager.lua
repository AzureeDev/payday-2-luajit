local mvec3_x = mvector3.x
local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_set_stat = mvector3.set_static
local mvec3_add = mvector3.add
local mvec3_div = mvector3.divide
local mvec3_mul = mvector3.multiply
local mvec3_sub = mvector3.subtract
local mvec3_dot = mvector3.dot
local mvec3_len_sq = mvector3.length_sq
local mvec3_cpy = mvector3.copy
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local mrot_x = mrotation.x
local mrot_y = mrotation.y
local mrot_yaw = mrotation.yaw
local mrot_pitch = mrotation.pitch
local mrot_roll = mrotation.roll
local mrot_set = mrotation.set_yaw_pitch_roll
local mrot_set_zero = mrotation.set_zero
local tmp_rot1 = Rotation()
local tmp_rot2 = Rotation()
local math_abs = math.abs
local math_random = math.random
local math_up = math.UP
local math_clamp = math.clamp
local next = next
local pairs = pairs
CharmManager = CharmManager or class()
CharmManager.fps = SystemInfo:platform() ~= Idstring("WIN32") and 30 or 45
CharmManager.beta = 0.8
CharmManager.inertia_factor = 15
CharmManager.inertia_duration = 0.16666666666666666
CharmManager.apply_inertia_epsilon = 25
CharmManager.falling_factor = 2
CharmManager.max_speed = 300
CharmManager.pitch_angle = 55
CharmManager.yaw_angle = 25
CharmManager.left_roll_angle = 25
CharmManager.right_roll_angle = 7
CharmManager.velocity_epsilon = 0.1
CharmManager.friction = 0.85
CharmManager.weapon_velocity_factor = 400
CharmManager.weapon_velocity_z_clamp = 200
CharmManager.vel_adj_lower_random_value = -20
CharmManager.vel_adj_higher_random_value = 100

function CharmManager:init()
	self._is_upd_empty = true
	self.update = self.update_empty
	self._random_array = {}
	self._random_i = 1
	self._random_i_max = 8
	self._weapons = {}
	self._enabled_weapons = {}
	local set_fps = self.fps
	set_fps = set_fps ~= 300 and set_fps
	self._fps = set_fps and 1 / set_fps
	self._is_upd_capped = set_fps and true or false
end

function CharmManager:get_movement_data(weapon, user, is_menu)
	local data = {}

	if not user then
		if not is_menu then
			print("[CharmManager:get_movement_data] ERROR? - In-game weapon has no user unit", weapon)

			data.update_type = "simulate_ingame_no_user"
			data.prev_weapon_rot = Rotation()
		elseif _G.IS_VR then
			print("[CharmManager:get_movement_data] Menu weapon in VR")

			data.update_type = "simulate_menu_vr"
			data.prev_weapon_rot = Rotation()
		else
			local entries = self._weapons
			local parent_unit = weapon:parent()

			if parent_unit and not entries[parent_unit:key()] then
				print("[CharmManager:get_movement_data] Menu weapon with parent unit")

				data.update_type = "simulate_menu_standard"
			else
				print("[CharmManager:get_movement_data] Menu weapon without a parent unit")

				data.update_type = "simulate_menu_no_character"
				data.prev_weapon_rot = Rotation()
			end
		end

		return data
	end

	data.prev_weapon_rot = Rotation()
	local base_ext = user:base()

	if base_ext and base_ext.is_local_player then
		if _G.IS_VR then
			print("[CharmManager:get_movement_data] Weapon has user unit: local VR player")

			local mov_ext = user:movement()

			if mov_ext then
				data.update_type = "simulate_ingame_vr"
				local ghost_pos = mov_ext:ghost_position()
				local ghost_head_pos = mov_ext:m_head_pos()
				data.ghost_m_pos = ghost_pos
				data.ghost_m_head_pos = ghost_head_pos
				data.user_m_pos = ghost_pos:with_z(mvec3_z(ghost_head_pos))
			else
				print("[CharmManager:get_movement_data] ERROR - Local VR player unit has no movement() extension", user)

				data.update_type = "simulate_ingame_no_user"
			end
		else
			print("[CharmManager:get_movement_data] weapon has user unit: local player")

			data.update_type = "simulate_ingame_standard"
			local cam_ext = user:camera()
			data.user_m_pos = cam_ext:position()
			data.m_fwd = cam_ext:forward()
			data.m_right = cam_ext:right()
			local chk_ext = user:camera()

			if chk_ext then
				data.update_type = "simulate_ingame_standard"
				data.user_m_pos = chk_ext:position()
				data.m_fwd = chk_ext:forward()
				data.m_right = chk_ext:right()
			else
				print("[CharmManager:get_movement_data] ERROR - Local player unit has no camera() extension, falling back to movement() extension", user)

				chk_ext = user:movement()

				if chk_ext then
					data.update_type = "simulate_ingame_upd_m"
					data.user_unit = user
					data.user_m_pos = chk_ext:m_head_pos()
				else
					print("[CharmManager:get_movement_data] ERROR - Local player unit has no movement() extension", user)

					data.update_type = "simulate_ingame_no_user"
				end
			end
		end
	else
		local mov_ext = user:movement()

		if mov_ext then
			if mov_ext.is_vr and mov_ext:is_vr() then
				data.update_type = "simulate_ingame_vr_third_person"
			else
				data.update_type = "simulate_ingame_upd_m"
			end

			data.user_unit = user
			data.user_m_pos = mov_ext:m_pos()
		else
			print("[CharmManager:get_movement_data] ERROR - user unit has no movement() extension")

			data.update_type = "simulate_ingame_no_user"
		end
	end

	if data.user_m_pos then
		self:set_common_mov_data(weapon, data)
	end

	return data
end

function CharmManager:set_common_mov_data(weapon, data)
	data.fwd_dot = 0
	data.right_dot = 0
	data.up_dot = 0
	data.inertia = 0
	data.inertia_transpired = 0
	data.m_fwd = data.m_fwd or Vector3()
	data.m_right = data.m_right or Vector3()
	local cur_user_pos = data.user_m_pos
	data.prev_user_pos = mvec3_cpy(cur_user_pos)
	local prev_weap_pos = mvec3_cpy(cur_user_pos)
	data.prev_weap_pos = prev_weap_pos
	local weap_pos = tmp_vec1

	weapon:m_position(weap_pos)
	mvec3_sub(prev_weap_pos, weap_pos)
end

function CharmManager:get_charm_data(charm_data_table, charm_unit, custom_body_obj, custom_parent_obj, is_menu)
	local u_key = charm_unit:key()

	if charm_data_table[u_key] then
		print("[CharmManager:get_charm_data] This charm unit is already simulating physics, skipping")

		return
	end

	local ids_f = Idstring
	local get_object_f = charm_unit.get_object
	local body_obj_name = custom_body_obj or "g_charm"
	local parent_obj_name = custom_parent_obj or "a_charm"
	local charm_body = get_object_f(charm_unit, ids_f(body_obj_name))
	local charm_ring = get_object_f(charm_unit, ids_f(parent_obj_name))

	if not charm_body or not charm_ring then
		print("[CharmManager:get_charm_data] This charm unit won't simulate fake physics because of the following reason/s", charm_unit)

		if not charm_body then
			print("No charm body object '" .. tostring(body_obj_name) .. "' found in charm unit")
		end

		if not charm_ring then
			print("No charm ring object '" .. tostring(parent_obj_name) .. "' found in charm unit")
		end

		return
	end

	local charm_entry = {
		unit = charm_unit,
		body = charm_body,
		ring = charm_ring,
		orig_ring_rot = charm_ring:local_rotation()
	}
	local enable_updating = is_menu or charm_unit:enabled() and charm_unit:visible()
	charm_entry.update_enabled = enable_updating
	local cur_body_parent = charm_body:parent()

	if cur_body_parent ~= charm_ring then
		charm_entry.orig_body_parent = cur_body_parent
		charm_entry.orig_body_rot = cur_body_parent and charm_body:local_rotation()

		if enable_updating then
			charm_body:link(charm_ring)
		end
	end

	charm_data_table[u_key] = charm_entry
end

function CharmManager:add_weapon(weapon_unit, parts, user_unit, is_menu, custom_params)
	custom_params = custom_params or {}
	local custom_units = custom_params.custom_units

	if not custom_units and not parts then
		print("[CharmManager:add_weapon] ERROR - No weapon parts or custom units sent")

		return
	end

	local u_key = weapon_unit:key()
	local existing_entries = self._weapons
	local old_entry = existing_entries[u_key]
	local charm_data = old_entry and old_entry.charm_data or {}

	if custom_units then
		for i = 1, #custom_units do
			local custom_data = custom_units[i]
			local custom_unit = custom_data.unit
			local custom_body_name = custom_data.body_name
			local custom_parent_name = custom_data.parent_name

			self:get_charm_data(charm_data, custom_unit, custom_body_name, custom_parent_name, is_menu)
		end
	end

	if parts and not custom_params.ignore_parts then
		local cloned_parts = deep_clone(parts)
		local find_params = custom_params.find_types or {
			{
				type_name = "charm"
			}
		}
		local t_delete = table.delete
		local factory_manager = managers.weapon_factory
		local get_part_f = factory_manager.get_part_from_weapon_by_type

		for i = 1, #find_params do
			local find_data = find_params[i]

			repeat
				local find_type = find_data.type_name
				local charm_part = get_part_f(factory_manager, find_type, cloned_parts)

				if not charm_part then
					break
					break
				end

				local charm_unit = charm_part.unit

				if charm_unit then
					local custom_body_name = find_data.body_name
					local custom_parent_name = find_data.parent_name

					self:get_charm_data(charm_data, charm_unit, custom_body_name, custom_parent_name, is_menu)
				end

				t_delete(cloned_parts, charm_part)
			until true
		end
	end

	if not next(charm_data) then
		print("[CharmManager:add_weapon] No charm weapon parts found")

		return
	end

	local enable_updating = false

	for _, c_entry in pairs(charm_data) do
		if c_entry.update_enabled then
			enable_updating = true

			break
		end
	end

	if old_entry then
		local enabled_entries = self._enabled_weapons

		if enable_updating then
			if not enabled_entries[u_key] then
				enabled_entries[u_key] = old_entry

				weapon_unit:base():set_charm_data(charm_data, enable_updating)
				self:_chk_updator()
			end
		elseif enabled_entries[u_key] then
			enabled_entries[u_key] = nil

			weapon_unit:base():set_charm_data(charm_data, enable_updating)
			self:_chk_updator()
		end
	else
		local entry = {
			weapon_unit = weapon_unit,
			charm_data = charm_data,
			mov_data = self:get_movement_data(weapon_unit, user_unit, is_menu)
		}
		existing_entries[u_key] = entry

		if enable_updating then
			self._enabled_weapons[u_key] = entry
		end

		weapon_unit:base():set_charm_data(charm_data, enable_updating)
		self:_chk_updator()
	end
end

function CharmManager:remove_weapon(weapon_unit)
	local u_key = weapon_unit:key()
	local weapons = self._weapons
	local enabled_weapons = self._enabled_weapons
	local entry = weapons[u_key]

	if not entry then
		print("[CharmManager:remove_weapon] ERROR - Weapon wasn't added ", weapon_unit)

		return
	elseif enabled_weapons[u_key] then
		for _, c_data in pairs(entry.charm_data) do
			if c_data.update_enabled then
				local charm_unit = c_data.unit

				if alive(charm_unit) then
					local charm_body = c_data.body
					local charm_ring = c_data.ring

					if alive(charm_body) then
						local orig_parent = c_data.orig_body_parent

						if alive(orig_parent) then
							charm_body:link(orig_parent)
							charm_body:set_local_rotation(c_data.orig_body_rot)
						end
					end

					if alive(charm_ring) then
						charm_ring:set_local_rotation(c_data.orig_ring_rot)
					end

					charm_unit:set_moving()
				else
					print("[CharmManager:remove_weapon] Charm unit was already destroyed on weapon unit ", weapon_unit)
					print("This should only happen during unload_all_units() and similar calls, where the unit is destroyed without the weapon being disassembled")
				end
			end
		end
	end

	weapon_unit:base():set_charm_data(nil)

	weapons[u_key] = nil
	enabled_weapons[u_key] = nil

	self:_chk_updator()
end

function CharmManager:enable_charm_upd(weapon_unit)
	local u_key = weapon_unit:key()
	local entry = self._weapons[u_key]
	local enabled_weapons = self._enabled_weapons

	if not entry then
		print("[CharmManager:enable_charm_upd] ERROR - Attempted to enable charm updating on a weapon that wasn't added ", weapon_unit)

		return
	elseif enabled_weapons[u_key] then
		print("[CharmManager:enable_charm_upd] ERROR - Weapon already had charm updating enabled ", weapon_unit)

		return
	end

	local mov_data = entry.mov_data

	self:reset_vel_mutables(entry, mov_data)

	local prev_weapon_rot = mov_data.prev_weapon_rot

	if prev_weapon_rot then
		mrot_set_zero(prev_weapon_rot)
	end

	for _, c_data in pairs(entry.charm_data) do
		local charm_unit = c_data.unit
		local cur_upd_state = charm_unit:enabled() and charm_unit:visible()

		if c_data.update_enabled then
			if not cur_upd_state then
				c_data.update_enabled = false
				local charm_body = c_data.body
				local orig_parent = c_data.orig_body_parent

				if orig_parent then
					charm_body:link(orig_parent)
					charm_body:set_local_rotation(c_data.orig_body_rot)
				end

				c_data.ring:set_local_rotation(c_data.orig_ring_rot)
				c_data.unit:set_moving()
			end
		elseif cur_upd_state then
			c_data.update_enabled = true

			if c_data.orig_body_parent then
				c_data.body:link(c_data.ring)
			end
		end
	end

	enabled_weapons[u_key] = entry

	self:_chk_updator()
end

function CharmManager:disable_charm_upd(weapon_unit)
	local u_key = weapon_unit:key()
	local entry = self._weapons[u_key]
	local enabled_weapons = self._enabled_weapons

	if not entry then
		print("[CharmManager:disable_charm_upd] ERROR - weapon wasn't added ", weapon_unit)

		return
	elseif not enabled_weapons[u_key] then
		print("[CharmManager:disable_charm_upd] ERROR - weapon already had charm updating disabled ", weapon_unit)

		return
	end

	for _, c_data in pairs(entry.charm_data) do
		if c_data.update_enabled then
			local charm_body = c_data.body
			local orig_parent = c_data.orig_body_parent

			if orig_parent then
				charm_body:link(orig_parent)
				charm_body:set_local_rotation(c_data.orig_body_rot)
			end

			c_data.ring:set_local_rotation(c_data.orig_ring_rot)
			c_data.unit:set_moving()
		end

		c_data.update_enabled = false
	end

	enabled_weapons[u_key] = nil

	self:_chk_updator()
end

function CharmManager:_chk_updator()
	if next(self._enabled_weapons) then
		if self._is_upd_empty then
			self._is_upd_empty = false

			if self._is_upd_capped then
				self.update = self.update_capped
				self._last_frame_timestamp = TimerManager:game():time() - self._fps
			else
				self.update = self[nil]
			end

			print("[CharmManager:_chk_updator] set enabled")
		end
	elseif not self._is_upd_empty then
		self._is_upd_empty = true
		self.update = self.update_empty

		print("[CharmManager:_chk_updator] set disabled")
	end
end

function CharmManager:update_empty()
end

function CharmManager:update(_, dt)
	local mov_data = nil

	for _, entry in pairs(self._enabled_weapons) do
		mov_data = entry.mov_data

		self[mov_data.update_type](self, entry, mov_data, entry.charm_data, dt)
	end
end

function CharmManager:update_capped(t, dt)
	dt = t - self._last_frame_timestamp

	if dt < self._fps then
		return
	end

	self._last_frame_timestamp = t
	local mov_data = nil

	for _, entry in pairs(self._enabled_weapons) do
		mov_data = entry.mov_data

		self[mov_data.update_type](self, entry, mov_data, entry.charm_data, dt)
	end
end

function CharmManager:_orient_charm(prev_rot, cur_rot)
	local prev_pitch = mrot_pitch(prev_rot)
	local prev_roll = mrot_roll(prev_rot)
	local cur_pitch = mrot_pitch(cur_rot)
	local cur_roll = mrot_roll(cur_rot)
	local prev_vec = tmp_vec1
	local cur_vec = tmp_vec2

	mvec3_set_stat(prev_vec, 0, prev_pitch, prev_roll)
	mvec3_set_stat(cur_vec, 0, cur_pitch, cur_roll)
	mvec3_sub(prev_vec, cur_vec)

	local charm_pitch, charm_roll = nil

	if mvec3_len_sq(prev_vec) >= 10000 then
		charm_pitch = prev_pitch
		charm_roll = prev_roll
	else
		local beta = self.beta
		charm_pitch = prev_pitch * beta + cur_pitch * (1 - beta)
		charm_roll = prev_roll * beta + cur_roll * (1 - beta)
	end

	mrot_set(prev_rot, 0, math_clamp(charm_pitch, -self.pitch_angle, self.pitch_angle), math_clamp(charm_roll, -90, 0))
end

function CharmManager:GetMappedRangeValueClamped(input_range_first, input_range_second, output_range_first, output_range_second, value)
	local m = (output_range_second - output_range_first) / (input_range_second - input_range_first)
	local b = output_range_first - m * input_range_first
	local y = m * value + b
	local output_min = output_range_first < output_range_second and output_range_first or output_range_second
	local output_max = output_range_second < output_range_first and output_range_first or output_range_second

	return math_clamp(y, output_min, output_max)
end

function CharmManager:random_smooth(value)
	local array = self._random_array
	local index = self._random_i
	self._random_i = index < self._random_i_max and index + 1 or 1
	array[index] = value
	local sum = 0
	local array_size = #array

	for i = 1, array_size do
		sum = sum + array[i]
	end

	return sum / array_size
end

function CharmManager:reset_vel_mutables(entry, mov_data)
	local cur_user_pos = mov_data.user_m_pos

	if not cur_user_pos then
		return
	end

	if mov_data.update_type == "simulate_ingame_vr" then
		mvec3_set(cur_user_pos, mov_data.ghost_m_pos)
		mvec3_set_z(cur_user_pos, mvec3_z(mov_data.ghost_m_head_pos))
	end

	mvec3_set(mov_data.prev_user_pos, cur_user_pos)

	local prev_weap_pos = mov_data.prev_weap_pos

	mvec3_set(prev_weap_pos, cur_user_pos)

	local weap_pos = tmp_vec1

	entry.weapon_unit:m_position(weap_pos)
	mvec3_sub(prev_weap_pos, weap_pos)

	mov_data.fwd_dot = mov_data.fwd_dot and 0 or nil
	mov_data.right_dot = mov_data.right_dot and 0 or nil
	mov_data.up_dot = mov_data.up_dot and 0 or nil
	mov_data.inertia = mov_data.inertia and 0 or nil
	mov_data.inertia_transpired = mov_data.inertia_transpired and 0 or nil
end

function CharmManager:set_velocities(m_comb_vel, m_user_vel, m_weap_vel, mov_data, weap_unit, dt)
	local cur_user_pos = mov_data.user_m_pos
	local prev_user_pos = mov_data.prev_user_pos
	local prev_weap_pos = mov_data.prev_weap_pos

	mvec3_set(m_user_vel, cur_user_pos)
	mvec3_sub(m_user_vel, prev_user_pos)
	mvec3_div(m_user_vel, dt)
	mvec3_set(prev_user_pos, cur_user_pos)
	mvec3_set(m_weap_vel, cur_user_pos)

	local cur_weap_pos = m_comb_vel

	weap_unit:m_position(cur_weap_pos)
	mvec3_sub(m_weap_vel, cur_weap_pos)
	mvec3_set(cur_weap_pos, m_weap_vel)
	mvec3_sub(m_weap_vel, prev_weap_pos)
	mvec3_mul(m_weap_vel, self.weapon_velocity_factor)

	local weapon_z_clamp = self.weapon_velocity_z_clamp

	mvec3_set_z(m_weap_vel, math_clamp(-mvec3_z(m_weap_vel), -weapon_z_clamp, weapon_z_clamp))
	mvec3_set(prev_weap_pos, cur_weap_pos)
	mvec3_set(m_comb_vel, m_user_vel)
	mvec3_add(m_comb_vel, m_weap_vel)
	mvec3_set_z(m_user_vel, mvec3_x(m_user_vel))
end

function CharmManager:project_velocities(fwd, right, combined_vel, user_vel, weap_vel)
	local vert_vel = mvec3_dot(combined_vel, math_up)
	local weapon_z_clamp = self.weapon_velocity_z_clamp
	local wpn_fwd_vel = math_clamp(mvec3_dot(weap_vel, fwd), -weapon_z_clamp, weapon_z_clamp) * 0.1
	local fwd_vel = mvec3_dot(user_vel, fwd) + wpn_fwd_vel
	local wpn_side_vel = -mvec3_dot(weap_vel, right)
	local side_vel = mvec3_dot(user_vel, right) + fwd_vel + wpn_side_vel * 0.5

	return fwd_vel, side_vel, vert_vel
end

function CharmManager:get_new_dots(mov_data, fwd_vel_dot, side_vel_dot, vert_vel_dot, beta, dt)
	local fwd_dot = mov_data.fwd_dot * beta + fwd_vel_dot * (1 - beta)
	local right_dot = mov_data.right_dot * beta + side_vel_dot * (1 - beta)
	local up_dot = mov_data.up_dot * beta + vert_vel_dot * (1 - beta)
	local inertia = mov_data.inertia
	local inertia_transpired = mov_data.inertia_transpired
	local has_inertia = inertia ~= 0
	local user_has_stopped = not has_inertia and self.apply_inertia_epsilon < math_abs(fwd_dot) and math_abs(fwd_vel_dot) < self.velocity_epsilon

	if user_has_stopped then
		inertia = -fwd_dot * self.inertia_factor * dt
		inertia_transpired = 0
	end

	if has_inertia then
		if self.inertia_duration < inertia_transpired then
			inertia = 0
		else
			fwd_dot = (fwd_dot + inertia) * self.friction
			inertia_transpired = inertia_transpired + dt
		end
	end

	mov_data.fwd_dot = fwd_dot
	mov_data.right_dot = right_dot
	mov_data.up_dot = up_dot
	mov_data.inertia = inertia
	mov_data.inertia_transpired = inertia_transpired

	return fwd_dot, right_dot, up_dot
end

function CharmManager:simulate_menu_standard(entry, _, charm_data)
	local new_rot = tmp_rot1

	entry.weapon_unit:m_rotation(new_rot)
	mrot_set(new_rot, 0, mrot_pitch(new_rot), 0)

	for _, c_data in pairs(charm_data) do
		c_data.ring:set_local_rotation(new_rot)
		c_data.unit:set_moving()
	end
end

function CharmManager:simulate_menu_no_character(entry, mov_data, charm_data)
	local weap_rot = tmp_rot1

	entry.weapon_unit:m_rotation(weap_rot)

	local old_to_new_rot = mov_data.prev_weapon_rot

	self:_orient_charm(old_to_new_rot, weap_rot)

	for _, c_data in pairs(charm_data) do
		c_data.ring:set_local_rotation(old_to_new_rot)
		c_data.unit:set_moving()
	end
end

function CharmManager:simulate_menu_vr(...)
	self:simulate_menu_no_character(...)
end

function CharmManager:simulate_ingame_standard(entry, mov_data, charm_data, dt)
	local weap_unit = entry.weapon_unit
	local weap_rot = tmp_rot1

	weap_unit:m_rotation(weap_rot)

	local combined_vel = tmp_vec1
	local user_vel = tmp_vec2
	local weap_vel = tmp_vec3

	self:set_velocities(combined_vel, user_vel, weap_vel, mov_data, weap_unit, dt)

	local random_vel_adj = math_random(self.vel_adj_lower_random_value, self.vel_adj_higher_random_value) / 100
	local smooth_adj = self:random_smooth(random_vel_adj)

	mvec3_mul(user_vel, smooth_adj)
	mvec3_mul(weap_vel, smooth_adj)

	local fwd_vel_dot, side_vel_dot, vert_vel_dot = self:project_velocities(mov_data.m_fwd, mov_data.m_right, combined_vel, user_vel, weap_vel)
	local fwd_dot, right_dot, up_dot = self:get_new_dots(mov_data, fwd_vel_dot, side_vel_dot, vert_vel_dot, self.beta, dt)
	local old_to_new_prev_rot = mov_data.prev_weapon_rot

	self:_orient_charm(old_to_new_prev_rot, weap_rot)

	local get_range_value_f = self.GetMappedRangeValueClamped
	local max_speed = self.max_speed
	local yaw_angle = self.yaw_angle
	local pitch_angle = self.pitch_angle
	local left_roll_angle = self.left_roll_angle
	local curr_yaw = get_range_value_f(self, -max_speed, max_speed, -yaw_angle, yaw_angle, fwd_dot) + mrot_yaw(old_to_new_prev_rot)
	local curr_pitch = get_range_value_f(self, -max_speed, max_speed, -pitch_angle, pitch_angle, fwd_dot) + mrot_pitch(old_to_new_prev_rot)
	local curr_roll = get_range_value_f(self, -max_speed, max_speed, left_roll_angle, -left_roll_angle, right_dot) + mrot_roll(old_to_new_prev_rot)
	curr_roll = curr_roll + get_range_value_f(self, -max_speed, 0, -left_roll_angle * self.falling_factor, 0, up_dot)
	local new_rot = tmp_rot2

	mrot_set(new_rot, math_clamp(curr_yaw, -yaw_angle, yaw_angle), math_clamp(curr_pitch, -pitch_angle, pitch_angle), math_clamp(curr_roll, -left_roll_angle, self.right_roll_angle))

	for _, c_data in pairs(charm_data) do
		c_data.ring:set_local_rotation(new_rot)
		c_data.unit:set_moving()
	end
end

function CharmManager:simulate_ingame_vr(entry, mov_data, charm_data, dt)
	local cur_user_pos = mov_data.user_m_pos

	mvec3_set(cur_user_pos, mov_data.ghost_m_pos)
	mvec3_set_z(cur_user_pos, mvec3_z(mov_data.ghost_m_head_pos))

	local hand_rot = tmp_rot1

	entry.weapon_unit:parent():m_rotation(hand_rot)
	mrot_y(hand_rot, mov_data.m_fwd)
	mrot_x(hand_rot, mov_data.m_right)
	self:simulate_ingame_standard(entry, mov_data, charm_data, dt)
end

function CharmManager:simulate_ingame_vr_third_person(entry, mov_data, charm_data, dt)
	local mov_ext = mov_data.user_unit:movement()

	if mov_ext:arm_animation_enabled() and not mov_ext:arm_animation_blocked() then
		local hand_rot = tmp_rot1

		entry.weapon_unit:m_rotation(hand_rot)
		mrot_y(hand_rot, mov_data.m_fwd)
		mrot_x(hand_rot, mov_data.m_right)
	else
		local m_rot = mov_data.user_unit:movement():m_rot()

		mrot_y(m_rot, mov_data.m_fwd)
		mrot_x(m_rot, mov_data.m_right)
	end

	self:simulate_ingame_standard(entry, mov_data, charm_data, dt)
end

function CharmManager:simulate_ingame_upd_m(entry, mov_data, charm_data, dt)
	local m_rot = mov_data.user_unit:movement():m_rot()

	mrot_y(m_rot, mov_data.m_fwd)
	mrot_x(m_rot, mov_data.m_right)
	self:simulate_ingame_standard(entry, mov_data, charm_data, dt)
end

function CharmManager:simulate_ingame_no_user(...)
	self:simulate_menu_no_character(...)
end
