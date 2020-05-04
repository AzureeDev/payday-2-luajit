require("lib/units/beings/player/playerwarp")
require("lib/units/beings/player/PlayerMovementInputVR")
require("lib/units/beings/player/HandMelee")
require("lib/units/beings/player/HandExt")
require("lib/units/cameras/ScopeCamera")
require("lib/input/HandStateMachine")
require("lib/utils/VRFadeout")

PlayerMenuCamera = PlayerMenuCamera or class()

function PlayerMenuCamera:init(unit)
end

function PlayerMenuCamera:set_menu_player(player)
	self._player = player
end

function PlayerMenuCamera:position()
	return Vector3(0, 0, 0)
end

function PlayerMenuCamera:rotation()
	return Rotation()
end

local hand_states_menu = require("lib/input/HandStatesPlayerMenu")
TouchWheel = TouchWheel or class()

function TouchWheel:init(granularity_x, granularity_y)
	self._granularity_x = granularity_x
	self._granularity_y = granularity_y
	self._reference = Vector3(0, 0, 0)
	self._value = Vector3(0, 0, 0)
	self._prev_value = Vector3(0, 0, 0)
	self._touching = false
end

function TouchWheel:feed(v)
	mvector3.set(self._prev_value, self._value)

	if mvector3.length_sq(v) < 0.001 then
		if self._touching then
			self._touching = false

			mvector3.set_zero(self._value)
			mvector3.set_zero(self._prev_value)
		end
	elseif not self._touching then
		mvector3.set(self._reference, v)

		self._touching = true
	end

	if self._touching then
		mvector3.set_x(self._value, math.round((v.x - self._reference.x) / self._granularity_x))
		mvector3.set_y(self._value, math.round((v.y - self._reference.y) / self._granularity_y))
	end

	return self._touching
end

function TouchWheel:step_x()
	return self._value.x - self._prev_value.x
end

function TouchWheel:step_y()
	return self._value.y - self._prev_value.y
end

function TouchWheel:value()
	return self._value
end

StickWheel = StickWheel or class()

function StickWheel:init()
	self._value = Vector3(0, 0, 0)
	self._scrolling = false
end

function StickWheel:feed(v)
	local t = TimerManager:game():time()

	if mvector3.length_sq(v) < 0.2 then
		if self._scrolling then
			self._scrolling = false
			self._next_scroll_t = nil

			mvector3.set_zero(self._value)
		end
	elseif not self._scrolling then
		self._next_scroll_t = t + 0.3
		self._scrolling = true

		mvector3.set_x(self._value, v.x)
		mvector3.set_y(self._value, v.y)
	end

	if self._next_scroll_t and self._next_scroll_t < t then
		self._next_scroll_t = t + 0.15

		mvector3.set_x(self._value, v.x)
		mvector3.set_y(self._value, v.y)
	end

	return self._scrolling
end

function StickWheel:step_x()
	local v = self._value.x

	mvector3.set_x(self._value, 0)

	return v
end

function StickWheel:step_y()
	local v = self._value.y

	mvector3.set_y(self._value, 0)

	return v
end

function StickWheel:value()
	return self._value
end

PlayerMenu = PlayerMenu or class()
PlayerMenu.STATE_IDLE = 0
PlayerMenu.STATE_TARGETING = 1
PlayerMenu.STATE_WARPING = 2
PlayerMenu.STATE_BOOTUP_INIT = 3
PlayerMenu.STATE_EMPTY = 4
PlayerMenu.WARP_SPEED = 3000
PlayerMenu.MAX_WARP_DISTANCE = 500
PlayerMenu.MAX_WARP_JUMP_DISTANCE = 450
PlayerMenu.WARP_JUMP_TIME = 2 * tweak_data.player.movement_state.standard.movement.jump_velocity.z / 982
PlayerMenu.MAX_WARP_JUMP_MOVE_SPEED = PlayerMenu.MAX_WARP_JUMP_DISTANCE / PlayerMenu.WARP_JUMP_TIME
local mvec_temp1 = Vector3()
local mvec_temp2 = Vector3()
local mvec_temp3 = Vector3()

function PlayerMenu:init(position, is_start_menu)
	self._is_start_menu = is_start_menu or false
	self._can_warp = self._is_start_menu
	self._position = mvector3.copy(position)
	self._base_rotation = Rotation(0, 0, 0)
	self._hmd_pos = VRManager:hmd_position()
	self._hmd_delta = Vector3()
	self._vr_controller = managers.controller:get_vr_controller()
	self._controller = managers.controller:create_controller("menu_vr", managers.controller:get_vr_wrapper_index(), false)
	self._movement_input = PlayerMovementInputVR:new(self._controller)

	self._controller:set_enabled(true)
	self:_set_tracking_enabled(false)

	self._touch_wheel = managers.vr:is_oculus() and StickWheel:new() or TouchWheel:new(0.25, 0.25)

	self:_create_camera()
	self:_create_mover()
	self:_create_hands()
	self:_setup_draw()
	self:_setup_states()

	self._input_cache = {}

	self:register_workspace({
		ws = managers.mouse_pointer:workspace(),
		activate = function ()
			if managers.menu:active_menu() then
				local index = self._input_cache[managers.menu:active_menu().name]

				managers.menu:active_menu().input:activate_mouse(index or 1)
			end
		end,
		deactivate = function ()
			if managers.menu:active_menu() then
				local index = managers.menu:active_menu().input:deactivate_mouse()
				self._input_cache[managers.menu:active_menu().name] = index
			end
		end
	})

	self._current_ws = managers.mouse_pointer:workspace()
	self._default_ws = self._current_ws

	if is_start_menu then
		managers.savefile:add_load_done_callback(callback(self, self, "on_savefile_loaded"))

		self._scope_camera = ScopeCamera:new(self:camera())
	end
end

function PlayerMenu:link_scope(camera_object, screen_object, material, texture_channel, zoom)
	self._scope_camera:link_scope(camera_object, screen_object, material, texture_channel, zoom)
end

function PlayerMenu:unlink_scope()
	self._scope_camera:unlink_scope()
end

function PlayerMenu:on_savefile_loaded(slot, success, is_setting_slot, cache_only)
	if is_setting_slot then
		self._refresh_settings = true
	end
end

function PlayerMenu:destroy()
	if self._vp then
		self._vp:destroy()

		self._vp = nil
	end

	if self._controller then
		self._controller:destroy()

		self._controller = nil
	end
end

function PlayerMenu:register_workspace(params)
	self._workspaces = self._workspaces or {}
	self._workspaces[params.ws:key()] = params
end

function PlayerMenu:unregister_workspace(ws)
	self._workspaces = self._workspaces or {}
	self._workspaces[ws:key()] = nil
end

function PlayerMenu:get_rumble_position()
	return self._hmd_pos
end

function PlayerMenu:change_state(state, ...)
	if state == self._current_state then
		return
	end

	if self._current_state then
		local exit = self._states[self._current_state].exit

		if exit then
			exit(...)
		end
	end

	self._current_state = state
	local enter = self._states[self._current_state].enter

	if enter then
		enter(...)
	end

	self._state_update = self._states[self._current_state].update
end

function PlayerMenu:current_state()
	return self._current_state
end

function PlayerMenu:controller()
	return self._controller
end

function PlayerMenu:hand(hand_index)
	return self._hands[hand_index]
end

function PlayerMenu:camera()
	return self._camera_object
end

function PlayerMenu:position()
	return self._position
end

function PlayerMenu:base_rotation()
	return self._base_rotation
end

function PlayerMenu:_rotate_player(right)
	local angle = managers.vr:get_setting("rotate_player_angle")
	local rot = right and Rotation(-angle, 0, 0) or Rotation(angle, 0, 0)

	mrotation.multiply(self._base_rotation, rot)
	managers.overlay_effect:play_effect(tweak_data.vr.overlay_effects.fade_in_rotate_player)
end

function PlayerMenu:_get_max_walk_speed(t, force_run)
	local speed_tweak = tweak_data.player.movement_state.standard.movement.speed
	local movement_speed = speed_tweak.STANDARD_MAX
	local speed_state = "walk"

	if force_run then
		movement_speed = speed_tweak.RUNNING_MAX
		speed_state = "run"
	end

	local multiplier = managers.player:movement_speed_multiplier(speed_state, false, nil, 1)

	if managers.player:has_activate_temporary_upgrade("temporary", "increased_movement_speed") then
		multiplier = multiplier * managers.player:temporary_upgrade_value("temporary", "increased_movement_speed", 1)
	end

	return movement_speed * multiplier
end

local mvec_prev_pos = Vector3()
local mvec_mover_to_ghost = Vector3()

function PlayerMenu:update(t, dt)
	if self._tracking_enabled then
		if self._refresh_settings then
			self._movement_input:refresh_settings()

			self._refresh_settings = nil
		end

		if self._controller:get_input_pressed("rotate_player_left") then
			self:_rotate_player(false)
		end

		if self._controller:get_input_pressed("rotate_player_right") then
			self:_rotate_player(true)
		end

		local hand = self._hands[self._primary_hand == 1 and 2 or 1]

		self._movement_input:update(t, dt, hand:raw_rotation() or Rotation())

		local state = self._movement_input:state()
		local hmd_pos, hmd_rot = VRManager:hmd_pose()

		mvector3.set(mvec_mover_to_ghost, self._position)
		mvector3.set(self._hmd_delta, hmd_pos)
		mvector3.subtract(self._hmd_delta, self._hmd_pos)
		mvector3.set_z(self._hmd_delta, 0)
		mvector3.set(self._hmd_pos, hmd_pos)

		self._position = self._position + self._hmd_delta:rotate_with(self._base_rotation)

		if self._is_start_menu then
			self._pos_mover = self._mover_unit:position()
			local pos_mover = mvector3.copy(self._pos_mover)

			mvector3.subtract(mvec_mover_to_ghost, pos_mover)

			local pos_diff = pos_mover - mvec_prev_pos

			mvector3.set(mvec_prev_pos, pos_mover)

			if self._movement_input:is_movement_walk() then
				local movement = mvector3.copy(state.move_axis)
				local speed = self:_get_max_walk_speed(t, state.run)

				mvector3.multiply(movement, speed * dt)

				self._position = self._position + pos_diff
				pos_mover = pos_mover + movement
				local len = mvector3.length(mvec_mover_to_ghost)

				if len > 30 then
					local warp, pos = self._mover_unit:find_warp_position(1, 0.6, 350, 10, self._position)

					if warp and mvector3.distance(pos, self._position) < 1 then
						pos_mover = pos_mover + mvec_mover_to_ghost

						mvector3.set(mvec_prev_pos, pos_mover)
					end
				end

				self._mover_unit:set_position(pos_mover)
			else
				self._mover_unit:set_position(self._position)
			end
		end

		local pos = mvec_temp1

		mvector3.set(pos, self._position)
		mvector3.set_z(pos, pos.z + hmd_pos.z)
		self._camera_object:set_position(pos)

		hmd_rot = self._base_rotation * hmd_rot

		self._camera_object:set_rotation(hmd_rot)

		if self._is_start_menu then
			local pos_mover = mvector3.copy(self._pos_mover)

			mvector3.set_z(pos_mover, pos_mover.z + self._mover_unit:get_active_mover_offset() * 2)

			local pos_head = mvector3.copy(self._position)

			mvector3.set_z(pos_head, pos_head.z + self._hmd_pos.z)
			self:_update_fadeout(pos_mover, pos_head, hmd_rot, t, dt)
		end

		local hmd_horz = mvec_temp1

		mvector3.set(hmd_horz, hmd_pos:rotate_with(self._base_rotation))
		mvector3.set_z(hmd_horz, 0)

		if self._precision_mode_block_t and t - self._precision_mode_block_t > 0.02 then
			self._precision_mode_block_t = nil
		end

		for i, hand in ipairs(self._hands) do
			local pos, rot = self._vr_controller:pose(i - 1)
			hand.prev_rotation_raw = hand.prev_rotation_raw or Rotation()
			hand.prev_rotation = hand.prev_rotation or Rotation()
			hand.prev_pos = hand.prev_pos or Vector3()
			hand.speed = hand.speed or 0
			local da = math.max(math.acos(math.abs(mrotation.dot(rot, hand.prev_rotation_raw))), 0)

			mrotation.set_zero(hand.prev_rotation_raw)
			mrotation.multiply(hand.prev_rotation_raw, rot)

			hand.speed = math.min(hand.speed + da * 0.01, 1)
			hand.speed = math.pow(0.01, dt) * hand.speed

			if self._precision_mode_block_t and hand.speed > 0.05 or not self._precision_mode_block_t and hand.speed > 0.09 then
				self._precision_mode_block_t = t
			end

			local precision_mode = i == self._primary_hand and not self._precision_mode_block_t

			if precision_mode and not self._precision_mode_block_t then
				local deg = math.acos(math.abs(mrotation.dot(rot, hand.prev_rotation)))
				local speed = 9.5 * deg

				if deg > 5 then
					hand.speed = hand.speed + 3 * dt
				elseif deg > 2 then
					hand.speed = hand.speed + 0.5 * dt
				end

				local t_slerp = math.min(speed * dt / deg, 1)

				mrotation.slerp(rot, hand.prev_rotation, rot, t_slerp)

				if mvector3.distance(pos, hand.prev_pos) > 0.5 then
					self._precision_mode_block_t = t + 0.2
				end
			end

			mvector3.set(hand.prev_pos, pos)
			mrotation.set_zero(hand.prev_rotation)
			mrotation.multiply(hand.prev_rotation, rot)

			rot = self._base_rotation * rot
			pos = pos:rotate_with(self._base_rotation)

			hand:update_orientation(pos, rot, self._position, hmd_horz)
		end
	end

	if self._state_update then
		self._state_update(t, dt)
	end

	if self._is_start_menu then
		self._scope_camera:update(t, dt)
	end

	self:_update_post_material_vars()
end

local function intersect_ws(shape, normal, from, dir)
	local d = mvector3.dot(dir, normal)

	if d <= 0 then
		return nil
	end

	local p = mvector3.dot(shape[1] - from, normal) / d * dir + from

	for i = 1, #shape do
		local p1 = shape[i]
		local p2 = nil

		if i ~= #shape then
			p2 = shape[i + 1]
		else
			p2 = shape[1]
		end

		local d = p1 - p2

		mvector3.normalize(d)

		local line_normal = p1 - (i == 1 and shape[4] or shape[i - 1])

		mvector3.normalize(line_normal)

		if mvector3.dot(p1 - p, line_normal) < 0 then
			return nil
		end
	end

	return p
end

function PlayerMenu:raycast(from, dir)
	local closest_point, min_length_sq = nil
	local workspaces = self._workspaces
	local p = {}
	local v1 = mvec_temp1
	local v2 = mvec_temp2
	local normal = mvec_temp3
	local v = mvec_temp1
	local hit_ws = nil

	for _, data in pairs(workspaces) do
		local ws = data.ws

		if ws:visible() then
			local w = ws:width()
			local h = ws:height()

			mvector3.set_static(v, 0, 0, 0)

			p[1] = ws:local_to_world(v)

			mvector3.set_static(v, w, 0, 0)

			p[2] = ws:local_to_world(v)

			mvector3.set_static(v, w, h, 0)

			p[3] = ws:local_to_world(v)

			mvector3.set_static(v, 0, h, 0)

			p[4] = ws:local_to_world(v)

			mvector3.set(v1, p[2])
			mvector3.subtract(v1, p[1])
			mvector3.normalize(v1)
			mvector3.set(v2, p[4])
			mvector3.subtract(v2, p[1])
			mvector3.normalize(v2)
			mvector3.cross(normal, v1, v2)

			local point = intersect_ws(p, normal, from, dir)

			if point then
				mvector3.set(mvec_temp1, point)
				mvector3.subtract(mvec_temp1, from)

				local len_sq = mvector3.length_sq(mvec_temp1)

				if not min_length_sq or len_sq < min_length_sq then
					min_length_sq = len_sq
					closest_point = point
					hit_ws = ws
				end
			end
		end
	end

	return closest_point, hit_ws
end

function PlayerMenu:is_idle()
	return self._current_state == PlayerMenu.STATE_IDLE
end

function PlayerMenu:attach_controller(controller)
	self._hand_state_machine:attach_controller(controller)
	self._hand_state_machine:refresh()
end

function PlayerMenu:dettach_controller(controller)
	self._hand_state_machine:deattach_controller(controller)
end

function PlayerMenu:set_primary_hand(hand)
	self:_set_primary_hand(hand == "right" and 1 or 2)
end

function PlayerMenu:primary_hand_index()
	return self._primary_hand
end

function PlayerMenu:start()
	self._base_rotation = Rotation(self._is_start_menu and 0 or -VRManager:hmd_rotation():yaw(), 0, 0)

	if not self._is_start_menu then
		self._position = Vector3()
	end

	self._hmd_pos = VRManager:hmd_position()
	self._hmd_delta = Vector3()

	self._hand_state_machine:refresh()
	self:_set_tracking_enabled(true)

	self._is_active = true

	if self._clear_vp then
		self._clear_vp:set_active(true)
	end

	self:_set_viewport_active(true)
	self:change_state(PlayerMenu.STATE_IDLE)
end

function PlayerMenu:stop()
	self:_set_tracking_enabled(false)

	self._is_active = false

	self:_set_viewport_active(false)

	if self._clear_vp then
		self._clear_vp:set_active(false)
	end

	self:change_state(PlayerMenu.STATE_EMPTY)
	self._hand_state_machine:enter_hand_state(1, "default")
	self._hand_state_machine:enter_hand_state(2, "default")
end

function PlayerMenu:is_active()
	return self._is_active or false
end

function PlayerMenu:set_position(position)
	mvector3.set(self._position, position)
end

function PlayerMenu:update_input()
	if self._controller:get_input_pressed("laser_primary") then
		managers.mouse_pointer._ws:feed_mouse_pressed(Idstring("0"))
	elseif self._controller:get_input_released("laser_primary") then
		managers.mouse_pointer._ws:feed_mouse_released(Idstring("0"))
	end

	if self._controller:get_input_pressed("laser_secondary") then
		managers.mouse_pointer._ws:feed_mouse_pressed(Idstring("1"))
	elseif self._controller:get_input_released("laser_secondary") then
		managers.mouse_pointer._ws:feed_mouse_released(Idstring("1"))
	end

	if self._touch_wheel:feed(self._controller:get_input_axis("touchpad_primary")) then
		local dx = self._touch_wheel:step_x()
		local dy = self._touch_wheel:step_y()

		if dx ~= 0 or dy ~= 0 then
			self._vr_controller:trigger_haptic_pulse(self._primary_hand - 1, 0, 700)
		end

		if dy > 0 then
			managers.mouse_pointer._ws:feed_mouse_pressed(Idstring("mouse wheel up"))
		elseif dy < 0 then
			managers.mouse_pointer._ws:feed_mouse_pressed(Idstring("mouse wheel down"))
		end

		if dx > 0 then
			managers.mouse_pointer._ws:feed_mouse_pressed(Idstring("mouse wheel right"))
		elseif dx < 0 then
			managers.mouse_pointer._ws:feed_mouse_pressed(Idstring("mouse wheel left"))
		end
	end
end

function PlayerMenu:change_ws(ws)
	self._workspaces[self._current_ws:key()].deactivate()
	self._workspaces[ws:key()].activate()
	managers.mouse_pointer:set_custom_workspace(ws)

	self._current_ws = ws
end

function PlayerMenu:draw()
	local hand = self._hands[self._primary_hand]
	local offset = mvector3.copy(hand:laser_position())

	mvector3.rotate_with(offset, hand:rotation())

	local from = hand:position() + offset
	local p, ws = self:raycast(from, hand:forward())
	local to = nil

	if p and ws then
		to = p

		if ws ~= self._current_ws then
			self:change_ws(ws)
		end

		local mouse_pos = managers.mouse_pointer:workspace():world_to_local(p)

		managers.mouse_pointer:set_mouse_world_position(mouse_pos.x, mouse_pos.y)
	end

	self:_laser_ray(p ~= nil, from, to)
end

function PlayerMenu:set_block_input(block)
	self._block_input = block
end

function PlayerMenu:update_base(t, dt)
	if not self._block_input then
		self:update_input()
	end

	self:draw()
end

function PlayerMenu:idle_update(t, dt)
	if (self._can_warp or PlayerMenu.DEBUG_WARP) and self._movement_input:is_movement_warp() then
		local state = self._movement_input:state()

		if state.warp_target and not state.warp then
			self:change_state(PlayerMenu.STATE_TARGETING)
		end
	end

	self:update_base(t, dt)
end

function PlayerMenu:target_enter()
	local hand = self._hands[self._primary_hand == 1 and 2 or 1]
	self._warp_ext = hand:unit():warp()

	self._warp_ext:set_targeting(true)
	self._warp_ext:set_max_jump_distance(PlayerMenu.MAX_WARP_JUMP_DISTANCE)
	self._warp_ext:set_jump_move_speed(PlayerMenu.MAX_WARP_JUMP_MOVE_SPEED)
	self._warp_ext:set_max_range(PlayerMenu.MAX_WARP_DISTANCE)
	self._warp_ext:set_range(PlayerMenu.MAX_WARP_DISTANCE)
	self._warp_ext:set_blocked(false)
end

function PlayerMenu:target_exit()
	self._warp_ext:set_targeting(false)
end

function PlayerMenu:target_update(t, dt)
	self:update_base(t, dt)

	local state = self._movement_input:state()
	local targeting = self._movement_input:is_movement_warp() and state.warp_target

	if state.warp then
		local tp = self._warp_ext:target_position()

		if tp and self._warp_ext:target_type() == "move" then
			self:change_state(PlayerMenu.STATE_WARPING, tp)
		end
	elseif not targeting then
		self:change_state(PlayerMenu.STATE_IDLE)
	end
end

function PlayerMenu:warp_enter(position)
	self._target_position = mvector3.copy(position)
end

function PlayerMenu:warp_exit()
end

function PlayerMenu:warp_update(t, dt)
	self._warp_dir = self._target_position - self._position
	local dist = mvector3.normalize(self._warp_dir)
	local warp_len = dt * PlayerMenu.WARP_SPEED

	if dist <= warp_len or dist == 0 then
		self:set_position(self._target_position)
		self:change_state(PlayerMenu.STATE_IDLE)
	else
		self:set_position(self._position + self._warp_dir * warp_len)
	end
end

function PlayerMenu:bootup_init_update()
	if TextureCache:check_textures_loaded() then
		self:change_state(PlayerMenu.STATE_EMPTY)
	end
end

function PlayerMenu:bootup_init_exit()
	self:_set_viewport_active(true)
	managers.overlay_effect:play_effect(tweak_data.overlay_effects.level_fade_in)
	self:_set_tracking_enabled(true)
end

function PlayerMenu:_set_tracking_enabled(enabled)
	self._tracking_enabled = enabled
end

function PlayerMenu:_set_primary_hand(hand)
	local offhand = 3 - hand

	self._hand_state_machine:enter_hand_state(offhand, "empty")
	self._hands[offhand]:set_state("idle")
	self._hand_state_machine:enter_hand_state(hand, "laser")
	self._hands[hand]:set_state("laser")

	self._primary_hand = hand
end

function PlayerMenu:_setup_states()
	self._current_state = nil
	self._states = {
		[PlayerMenu.STATE_IDLE] = {
			update = callback(self, self, "idle_update")
		},
		[PlayerMenu.STATE_TARGETING] = {
			enter = callback(self, self, "target_enter"),
			exit = callback(self, self, "target_exit"),
			update = callback(self, self, "target_update")
		},
		[PlayerMenu.STATE_WARPING] = {
			enter = callback(self, self, "warp_enter"),
			exit = callback(self, self, "warp_exit"),
			update = callback(self, self, "warp_update")
		},
		[PlayerMenu.STATE_BOOTUP_INIT] = {
			update = callback(self, self, "bootup_init_update"),
			exit = callback(self, self, "bootup_init_exit")
		},
		[PlayerMenu.STATE_EMPTY] = {}
	}
	local hand_states = {
		empty = hand_states_menu.EmptyHandState:new(),
		laser = hand_states_menu.LaserHandState:new(),
		default = hand_states_menu.DefaultHandState:new(),
		customization = hand_states_menu.CustomizationLaserHandState:new(),
		customization_empty = hand_states_menu.CustomizationEmptyHandState:new()
	}

	self:change_state(self._is_start_menu and PlayerMenu.STATE_BOOTUP_INIT or PlayerMenu.STATE_EMPTY)

	self._hand_state_machine = HandStateMachine:new(hand_states, hand_states.empty, hand_states.empty)

	self._hand_state_machine:attach_controller(self._controller, true)
end

PlayerMenuHandBase = PlayerMenuHandBase or class()

function PlayerMenuHandBase:init(config, laser_orientation_object)
	self._hand_data = {}
	local data = self._hand_data
	data._base_position = config.base_position or Vector3()
	data._base_rotation = config.base_rotation or Rotation()
	data._base_rotation_controller = config.base_rotation_controller or Rotation()
	data._laser_position = config.laser_position or Vector3()
	data.position = data._base_position
	data.rotation = data._base_rotation
	data.raw_rotation = Rotation()
	data._forward = data._base_rotation:y()
	data._laser_orientation_object = laser_orientation_object
end

function PlayerMenuHandBase:update_orientation(position, rotation, player_position, hmd_horz)
	local data = self._hand_data

	mrotation.set_zero(data.raw_rotation)
	mrotation.multiply(data.raw_rotation, rotation)
	mrotation.multiply(data.raw_rotation, data._base_rotation_controller)
	mrotation.multiply(rotation, data._base_rotation)

	position = position + player_position
	position = position - hmd_horz
	position = position + data._base_position:rotate_with(rotation)
	data.rotation = rotation
	data.position = position
	data._forward = rotation:y()

	self:set_orientation(data.position, data.rotation)
end

function PlayerMenuHandBase:position()
	return self._hand_data.position
end

function PlayerMenuHandBase:rotation()
	return self._hand_data.rotation
end

function PlayerMenuHandBase:raw_rotation()
	return self._hand_data.raw_rotation
end

function PlayerMenuHandBase:forward()
	return self._hand_data._forward
end

function PlayerMenuHandBase:set_state(state)
end

function PlayerMenuHandBase:laser_position()
	return self._hand_data._laser_orientation_object:local_position()
end

function PlayerMenuHandBase:set_orientation(position, rotation)
end

PlayerMenuHandUnit = PlayerMenuHandUnit or class(PlayerMenuHandBase)

function PlayerMenuHandUnit:init(config)
	local hand_unit = World:spawn_unit(config.unit_name, Vector3(0, 0, 0), Rotation())

	hand_unit:set_extension_update_enabled(Idstring("melee"), false)
	hand_unit:damage():run_sequence_simple("hide_gadgets")
	hand_unit:warp():set_player_unit(config.player_unit)

	self._unit = hand_unit

	self.super.init(self, config, hand_unit:get_object(config.laser_orientation_object))
end

function PlayerMenuHandUnit:configure(other)
	self._unit:base():set_other_hand_unit(other._unit)
	self._unit:base():set_hand_data(self._hand_data)
end

function PlayerMenuHandUnit:set_orientation(position, rotation)
	self._unit:set_position(position)
	self._unit:set_rotation(rotation)
	self._unit:set_moving(2)
end

function PlayerMenuHandUnit:set_state(state)
	self._unit:damage():run_sequence_simple(state)
end

function PlayerMenuHandUnit:unit()
	return self._unit
end

PlayerMenuHandObject = PlayerMenuHandObject or class(PlayerMenuHandBase)

function PlayerMenuHandObject:init(config)
	self.super.init(self, config, config.laser_orientation_object)

	self._states = config.states

	self:_hide_all()

	if config.default_state then
		self:set_state(config.default_state)
	end
end

function PlayerMenuHandObject:set_orientation(position, rotation)
	if self._object then
		self._object:set_position(position)
		self._object:set_rotation(rotation)
	end
end

function PlayerMenuHandObject:_set_visibility(object, visibility)
	if object then
		local objects = {
			object
		}

		while #objects ~= 0 do
			local cur = table.remove(objects, 1)

			cur:set_visibility(visibility)

			for _, o in ipairs(cur:children()) do
				table.insert(objects, o)
			end
		end
	end
end

function PlayerMenuHandObject:set_state(state)
	local obj = self._states[state]

	if self._object then
		self:_set_visibility(self._object, false)
	end

	if obj then
		self._object = obj

		self:_set_visibility(self._object, true)
	end
end

function PlayerMenuHandObject:_hide_all()
	for _, o in pairs(self._states) do
		self:_set_visibility(o, false)
	end
end

function PlayerMenu:_create_hands()
	local controller_rotation = Rotation()

	if managers.vr:is_oculus() then
		controller_rotation = Rotation(math.X, -30)
	end

	if self._is_start_menu then
		self._hands = {
			PlayerMenuHandUnit:new({
				unit_name = Idstring("units/pd2_dlc_vr/player/vr_hand_right"),
				base_rotation = Rotation(math.X, -50),
				base_rotation_controller = controller_rotation,
				base_position = Vector3(0, -2, -7),
				laser_orientation_object = Idstring("a_laser"),
				player_unit = self._mover_unit
			}),
			PlayerMenuHandUnit:new({
				unit_name = Idstring("units/pd2_dlc_vr/player/vr_hand_left"),
				base_rotation = Rotation(math.X, -50),
				base_rotation_controller = controller_rotation,
				base_position = Vector3(0, -2, -7),
				laser_orientation_object = Idstring("a_laser"),
				player_unit = self._mover_unit
			})
		}

		self._hands[1]:configure(self._hands[2])
		self._hands[2]:configure(self._hands[1])
	else
		self._hands = {
			PlayerMenuHandObject:new({
				default_state = "idle",
				states = {
					idle = MenuRoom:get_object(Idstring("g_gloves_idle_right")),
					laser = MenuRoom:get_object(Idstring("g_gloves_laser_right"))
				},
				base_rotation = Rotation(math.X, -50),
				base_rotation_controller = controller_rotation,
				base_position = Vector3(0, -2, -7),
				laser_orientation_object = MenuRoom:get_object(Idstring("a_laser_right"))
			}),
			PlayerMenuHandObject:new({
				default_state = "idle",
				states = {
					idle = MenuRoom:get_object(Idstring("g_gloves_idle_left")),
					laser = MenuRoom:get_object(Idstring("g_gloves_laser_left"))
				},
				base_rotation = Rotation(math.X, -50),
				base_rotation_controller = controller_rotation,
				base_position = Vector3(0, -2, -7),
				laser_orientation_object = MenuRoom:get_object(Idstring("a_laser_left"))
			})
		}
	end
end

function PlayerMenu:_create_mover()
	if self._is_start_menu then
		self._mover_unit = World:spawn_unit(Idstring("units/pd2_dlc_vr/units/menu_mover"), Vector3(0, 0, 0), Rotation())

		self._mover_unit:camera():set_menu_player(self)
		self._mover_unit:mover():set_velocity(Vector3())
		self._mover_unit:mover():set_gravity(Vector3(0, 0, -982))
		self._mover_unit:set_position(self._position)
	end
end

function PlayerMenu:render_target()
	return self._render_target
end

function PlayerMenu:render_target_resolution()
	return self._render_target_resolution
end

local ids_hdr_post_processor = Idstring("hdr_post_processor")
local ids_hdr_post_composite = Idstring("post_DOF")
local ids_radial_offset = Idstring("radial_offset")
local ids_dof_settings = Idstring("settings")
local ids_contrast = Idstring("contrast")
local ids_chromatic = Idstring("chromatic_amount")

function PlayerMenu:_update_post_material_vars()
	if self._post_material then
		self._post_material:set_variable(ids_chromatic, 0)
		self._post_material:set_variable(ids_contrast, 0)
		self._post_material:set_variable(ids_radial_offset, Vector3(0, 0, 0))
		self._post_material:set_variable(ids_dof_settings, Vector3(0, 0, 0))
	end
end

function PlayerMenu:_create_camera()
	if self._is_start_menu then
		self._camera_object = World:create_camera()

		self._camera_object:set_near_range(3)
		self._camera_object:set_far_range(250000)
		self._camera_object:set_fov(75)
		self._camera_object:set_position(self._position)

		self._vp = managers.viewport:new_vp(0, 0, 1, 1, "menu_main")

		self._vp:set_camera(self._camera_object)
		self._vp:set_active(false)

		self._fadeout = VRFadeout:new()

		self._fadeout:play()
	else
		local rt_resolution = Vector3(1280, 720, 0)
		self._render_target_resolution = rt_resolution
		self._render_target = Application:create_texture("render_target", rt_resolution.x, rt_resolution.y)

		self._render_target:set_disable_clear(true)

		local resolution = VRManager:target_resolution()
		local scale_x = rt_resolution.x / resolution.x
		local scale_y = rt_resolution.y / resolution.y
		self._camera_object = MenuRoom:create_camera()

		self._camera_object:set_near_range(3)
		self._camera_object:set_far_range(250000)
		self._camera_object:set_fov(75)
		self._camera_object:set_aspect_ratio(1.7777777777777777)
		self._camera_object:set_stereo(true)

		self._clear_vp = managers.vr:new_vp(0, 0, scale_x, scale_y, "menu_vr_clear", CoreManagerBase.PRIO_WORLDCAMERA)

		self._clear_vp:set_render_params("GBufferClear", self._clear_vp:vp(), self._render_target)
		self._clear_vp:vp():set_post_processor_effect("GBufferClear", Idstring("transfer_back_buffer"), Idstring("render_backbuffer_to_target"))
		self._clear_vp:set_camera(self._camera_object)
		self._clear_vp:set_enable_adaptive_quality(false)
		self._clear_vp:set_active(false)

		self._vp = managers.vr:new_vp(0, 0, 1, 1, "menu_vr", CoreManagerBase.PRIO_WORLDCAMERA)

		self._vp:set_render_params("MenuRoom", self._vp:vp())
		self._vp:set_camera(self._camera_object)
		self._vp:set_active(false)

		local hdr_post_processor = self._vp:vp():get_post_processor_effect("World", ids_hdr_post_processor)

		if hdr_post_processor then
			local post_composite = hdr_post_processor:modifier(ids_hdr_post_composite)

			if post_composite then
				self._post_material = post_composite:material()
			end
		end
	end
end

function PlayerMenu:_set_viewport_active(active)
	self._vp:set_active(active)
end

function PlayerMenu:_laser_ray(visible, from, to)
	if self._is_start_menu then
		if visible then
			self._brush_laser_dot:sphere(to, 1)
			self._brush_laser:cylinder(from, to, 0.25)
		end
	else
		local ray_obj = self._laser_ray_obj
		local dot_obj = self._laser_dot_obj

		if visible then
			ray_obj:cylinder(from, to, 0.25, 20, Color(0.05, 0, 1, 0))
			dot_obj:sphere(to, 1, 1, Color(1, 0, 1, 0))
		end

		ray_obj:set_visibility(visible)
		dot_obj:set_visibility(visible)
	end
end

function PlayerMenu:_update_fadeout(mover_position, head_position, rotation, t, dt)
	if not self._is_start_menu then
		return false
	end

	local ignore_fade = self._current_state == PlayerMenu.STATE_WARPING

	if self._fadeout:update(mover_position, head_position, rotation, t, dt, ignore_fade, ignore_fade) then
		mvector3.set(self._position, self._mover_unit:position())
	end
end

function PlayerMenu:_setup_draw()
	if self._is_start_menu then
		self._brush_warp = Draw:brush(Color(0.07, 0, 0.60784, 0.81176))

		self._brush_warp:set_blend_mode("opacity_add")

		self._brush_laser = Draw:brush(Color(0.05, 0, 1, 0))

		self._brush_laser:set_blend_mode("opacity_add")
		self._brush_laser:set_render_template(Idstring("LineObject"))

		self._brush_laser_dot = Draw:brush(Color(1, 0, 1, 0))

		self._brush_laser_dot:set_blend_mode("opacity_add")
		self._brush_laser_dot:set_render_template(Idstring("LineObject"))
	else
		self._laser_ray_obj = MenuRoom:get_object(Idstring("laser_ray"))

		self._laser_ray_obj:set_visibility(false)

		self._laser_dot_obj = MenuRoom:get_object(Idstring("laser_dot"))

		self._laser_dot_obj:set_visibility(false)
	end
end
