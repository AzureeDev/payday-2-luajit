HoldButtonMetaInput = HoldButtonMetaInput or class()

function HoldButtonMetaInput:init(name, subject_name, subject_key, delay)
	self._press_key = "btn_" .. name .. "_press"
	self._subject_name = subject_name
	self._subject_press_key = subject_key or "btn_" .. subject_name .. "_press"
	self._delay = delay
	self._trigger_time = nil
end

function HoldButtonMetaInput:update(t, dt, controller, input)
	local subject_down = input.any_input_downed and controller:get_input_bool(self._subject_name)
	local subject_pressed = input.any_input_pressed and controller:get_input_pressed(self._subject_name)
	local subject_released = input.any_input_released and controller:get_input_released(self._subject_name)
	input[self._subject_press_key] = false

	if subject_pressed and not self._trigger_time then
		self._trigger_time = t + self._delay
	end

	if subject_down and self._trigger_time and self._trigger_time <= t then
		self._trigger_time = nil
		input[self._press_key] = true
	end

	if subject_released and self._trigger_time then
		self._trigger_time = nil
		input[self._subject_press_key] = true
	end
end
