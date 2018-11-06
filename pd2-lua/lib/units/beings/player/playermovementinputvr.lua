TouchMovementInputStateMachine = TouchMovementInputStateMachine or class()
TouchMovementInputStateMachine.STATE_WARP_ZONE = 1
TouchMovementInputStateMachine.STATE_DEAD_ZONE = 2
TouchMovementInputStateMachine.STATE_LOCAL_WARP_ZONE = 3

function TouchMovementInputStateMachine:init(default_controls)
	self._warp_zone = 0.4
	self._dead_zone = 0.25
	self._dead_zone_local_th = 0.08
	self._warp_in_dead_zone = true
	self._default_controls = default_controls
	self._states = {
		[TouchMovementInputStateMachine.STATE_WARP_ZONE] = {
			update = callback(self, self, "_update_warp_zone")
		},
		[TouchMovementInputStateMachine.STATE_DEAD_ZONE] = {
			update = callback(self, self, "_update_dead_zone")
		},
		[TouchMovementInputStateMachine.STATE_LOCAL_WARP_ZONE] = {
			enter = callback(self, self, "_enter_warp_zone_local"),
			update = callback(self, self, "_update_warp_zone_local")
		}
	}

	self:change_state(TouchMovementInputStateMachine.STATE_WARP_ZONE)
end

function TouchMovementInputStateMachine:current_dead_zone()
	return self._dead_zone
end

function TouchMovementInputStateMachine:set_warp_zone(value)
	self._warp_zone = value
end

function TouchMovementInputStateMachine:set_dead_zone(value)
	self._dead_zone = value
end

function TouchMovementInputStateMachine:set_warp_in_dead_zone(value)
	self._warp_in_dead_zone = value
end

function TouchMovementInputStateMachine:change_state(state, ...)
	if state < 1 or state > #self._states then
		return
	end

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

	self._update_dead_zone_func = self._states[self._current_state].update
end

function TouchMovementInputStateMachine:update(move_length, warp_target)
	if self._default_controls then
		if warp_target == false then
			if self._current_state ~= TouchMovementInputStateMachine.STATE_WARP_ZONE then
				self:change_state(TouchMovementInputStateMachine.STATE_WARP_ZONE)
			end

			return false
		end
	elseif warp_target == false and move_length < self._warp_zone then
		if self._current_state ~= TouchMovementInputStateMachine.STATE_WARP_ZONE then
			self:change_state(TouchMovementInputStateMachine.STATE_WARP_ZONE)
		end

		return false
	end

	return self._update_dead_zone_func and self._update_dead_zone_func(move_length) or false
end

function TouchMovementInputStateMachine:_update_warp_zone(move_length)
	local warp_zone_length = math.max(self._warp_zone, self._dead_zone)

	if move_length < warp_zone_length then
		if self._default_controls then
			self:change_state(TouchMovementInputStateMachine.STATE_LOCAL_WARP_ZONE, move_length)
		end

		return true
	else
		self:change_state(TouchMovementInputStateMachine.STATE_DEAD_ZONE)
	end

	return false
end

function TouchMovementInputStateMachine:_update_dead_zone(move_length)
	if self._warp_in_dead_zone and move_length < self._dead_zone then
		return true
	end

	return false
end

function TouchMovementInputStateMachine:_enter_warp_zone_local(move_length)
	self._warp_zone_local = math.max(self._dead_zone, move_length) + self._dead_zone_local_th

	if self._default_controls then
		self._warp_zone_local = math.min(self._warp_zone_local, self._warp_zone + 0.025)
	end
end

function TouchMovementInputStateMachine:_update_warp_zone_local(move_length)
	if move_length < self._warp_zone_local then
		return true
	end

	self:change_state(TouchMovementInputStateMachine.STATE_DEAD_ZONE)

	return false
end

function TouchMovementInputStateMachine:_update_dead_zone_none()
	return false
end

PlayerMovementInputVR = PlayerMovementInputVR or class()

function PlayerMovementInputVR:init(controller)
	self._default_controls = managers.vr:is_default_hmd()

	if self._default_controls then
		self._default_dead_zone_size = {
			max = 0.5,
			min = 0.05
		}
		self._default_warp_zone_size = {
			max = 0.9,
			min = 0.4
		}
	else
		self._default_dead_zone_size = {
			max = 0.5,
			min = 0.05
		}
		self._default_warp_zone_size = {
			max = 0.15,
			min = 0.15
		}
	end

	self._input = TouchMovementInputStateMachine:new(self._default_controls)
	self._controller = controller
	self._is_movement_warp = true
	self._warp_only_mode = true
	self._dead_zone = 0.1
	self._state = {
		warp = false,
		move_length_scaled = 0,
		warp_target = false,
		move_length = 0,
		move_axis = Vector3(0, 0, 0),
		move_axis_normalized = Vector3(0, 0, 0)
	}

	self:_add_setting_callback("movement_type", "_movement_type_changed")
	self:_add_setting_callback("enable_dead_zone_warp", "_enable_dead_zone_warp_changed")
	self:_add_setting_callback("warp_zone_size", "_warp_zone_size_changed")
	self:_add_setting_callback("dead_zone_size", "_dead_zone_size_changed")

	self._debug_brush = Draw:brush(Color(1, 1, 1, 1))
end

function PlayerMovementInputVR:refresh_settings()
	for _, setting in ipairs(self._settings) do
		setting.clbk(setting.name, nil, managers.vr:get_setting(setting.name))
	end
end

function PlayerMovementInputVR:_add_setting_callback(setting_name, method)
	local clbk = callback(self, self, method)

	managers.vr:add_setting_changed_callback(setting_name, clbk)
	clbk(setting_name, nil, managers.vr:get_setting(setting_name))

	self._settings = self._settings or {}

	table.insert(self._settings, {
		name = setting_name,
		clbk = clbk
	})
end

function PlayerMovementInputVR:update(t, dt, hand_rotation)
	self._state.warp_target = self._controller:get_input_touch_bool("warp_target")
	local run = self._controller:get_input_bool("run")
	self._state.warp = self._controller:get_input_bool("warp")
	local axis = self._controller:get_input_axis("touchpad_move")
	local raw_move_length = mvector3.length(axis)
	local warp_target = self._state.warp_target
	self._is_movement_warp = self._warp_only_mode or self._input:update(raw_move_length, warp_target)
	local dz = self._dead_zone

	if not self._is_movement_warp and dz < raw_move_length then
		self._state.run = self._state.run or run
		local m = raw_move_length
		m = math.clamp((m - dz) / (1 - dz), 0, 1)

		if m > 0.98 then
			m = 1
		end

		self._state.move_length = m
		local unscaled_edge = self._default_controls and 0.25 or 0.3

		if unscaled_edge > raw_move_length - dz then
			local edge = unscaled_edge / (1 - dz)
			local x = m / (2 * edge)
			x = x * x * (3 - 2 * x)
			x = x * x * (3 - 2 * x)
			m = x * 2 * edge
		end

		if math.abs(m) < 0.01 then
			self._state.run = false
			m = 0
		end

		self._state.move_length_scaled = m
		local forward = hand_rotation:y()

		mvector3.set_z(forward, 0)
		mvector3.normalize(forward)
		mrotation.set_look_at(hand_rotation, forward, math.UP)
		mvector3.rotate_with(axis, hand_rotation)
		mvector3.set_z(axis, 0)
		mvector3.normalize(axis)

		self._state.move_axis_normalized = mvector3.copy(axis)

		mvector3.multiply(axis, m)

		self._state.move_axis = axis
	else
		self._state.run = false
		self._state.move_length = 0
		self._state.move_length_scaled = 0
	end
end

function PlayerMovementInputVR:stop_running()
	self._state.run = false
end

function PlayerMovementInputVR:state()
	return self._state
end

function PlayerMovementInputVR:is_movement_warp()
	return self._is_movement_warp
end

function PlayerMovementInputVR:is_movement_walk()
	return not self._is_movement_warp and self._state.move_length_scaled > 0
end

function PlayerMovementInputVR:_movement_type_changed(setting, old, new)
	self._warp_only_mode = new == "warp"
end

function PlayerMovementInputVR:_enable_dead_zone_warp_changed(setting, old, new)
	self._input:set_warp_in_dead_zone(new)
end

function PlayerMovementInputVR:_warp_zone_size_changed(setting, old, new)
	local warp_zone_size = math.lerp(self._default_warp_zone_size.min, self._default_warp_zone_size.max, new * 0.01)

	self._input:set_warp_zone(warp_zone_size)
end

function PlayerMovementInputVR:_dead_zone_size_changed(setting, old, new)
	local dead_zone_size = math.lerp(self._default_dead_zone_size.min, self._default_dead_zone_size.max, new * 0.01)
	self._dead_zone = dead_zone_size

	self._input:set_dead_zone(self._dead_zone)
end
