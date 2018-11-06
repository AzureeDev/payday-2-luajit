core:module("CoreVectorSliderBox")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreEws")
core:import("CoreDebug")

VectorSliderBox = VectorSliderBox or CoreClass.mixin(CoreClass.class(), CoreEvent.BasicEventHandling)

function VectorSliderBox:init(parent_frame, title, min, max, step)
	assert(min < max)

	self._parent_frame = parent_frame
	self._step = step
	self._min = min
	self._max = max
	self._slider_max = (max - min) / step
	self._box = EWS:StaticBoxSizer(self._parent_frame, "VERTICAL", title)
end

function VectorSliderBox:box()
	return self._box
end

function VectorSliderBox:_on_slider_movement()
	self:_update_text()
end

function VectorSliderBox:_on_slider_changed()
	self:_update_values()
end

function VectorSliderBox:_on_mute_toggle()
	if self.__mute_toggle:get_value() == true then
		self:_set_enabled_all(false)
	else
		self:_set_enabled_all(true)
	end
end

function VectorSliderBox:_create_slider()
	local new_slider = EWS:Slider(self._parent_frame, 0, 0, self._slider_max)

	new_slider:connect("", "EVT_SCROLL_THUMBTRACK", CoreEvent.callback(self, self, "_on_slider_movement"), "")
	new_slider:connect("", "EVT_SCROLL_CHANGED", CoreEvent.callback(self, self, "_on_slider_changed"), "")

	return new_slider
end

function VectorSliderBox:_create_mute_button()
	local box, mute_button = nil
	box = EWS:BoxSizer("HORIZONTAL")
	mute_button = EWS:ToggleButton(self._parent_frame, "Feed Zero", "", "BU_EXACTFIT,NO_BORDER")

	mute_button:connect("", "EVT_COMMAND_TOGGLEBUTTON_CLICKED", CoreEvent.callback(self, self, "_on_mute_toggle"), "")
	box:add(mute_button, 0, 0, "EXPAND,ALIGN_LEFT")
	self._box:add(box, 1, 0, "EXPAND")

	return mute_button
end

function VectorSliderBox:_create_sizer()
	local box, text_ctrl, slider = nil
	box = EWS:BoxSizer("HORIZONTAL")
	slider = self:_create_slider()
	text_ctrl = EWS:TextCtrl(self._parent_frame, string.format("%.3f", self._min), "", "TE_PROCESS_ENTER")

	text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", CoreEvent.callback(self, self, "_on_update_textctrl"), "")
	box:add(slider, 5, 0, "EXPAND")
	box:add(text_ctrl, 1, 0, "EXPAND")
	self._box:add(box, 1, 0, "EXPAND")

	return slider, text_ctrl
end

function VectorSliderBox:get_value()
	if self._mute_toggle:get_value() == true then
		return Vector3(0, 0, 0)
	else
		return Vector3(self._slider_x:get_value(), self._slider_y:get_value(), self._slider_z:get_value())
	end
end

function VectorSliderBox:set_value(vector)
	self.__slider_x:set_value(self:_actual_to_slider(vector.x))
	self.__slider_y:set_value(self:_actual_to_slider(vector.y))
	self.__slider_z:set_value(self:_actual_to_slider(vector.z))
	self:_set_text(vector.x, vector.y, vector.z)

	if self._vector3 then
		self:_send_event("EVT_VALUE_CHANGED", vector)
	else
		self:_send_event("EVT_VALUE_CHANGED", vector:with_z(0))
	end
end

function VectorSliderBox:_actual_to_slider(value)
	return (value - self._min) / self._step
end

function VectorSliderBox:_slider_to_actual(value)
	return value * self._step + self._min
end

function VectorSliderBox:_update_values()
	local x, y, z = nil
	x = self:_slider_to_actual(self.__slider_x:get_value())
	y = self:_slider_to_actual(self.__slider_y:get_value())
	z = self:_slider_to_actual(self.__slider_z:get_value())

	self:set_value(Vector3(x, y, z))
	self:_set_text(x, y, z)
end

function VectorSliderBox:_update_text()
	local x, y, z = nil
	x = self:_slider_to_actual(self.__slider_x:get_value())
	y = self:_slider_to_actual(self.__slider_y:get_value())
	z = self:_slider_to_actual(self.__slider_z:get_value())

	self:_set_text(x, y, z)
end

function VectorSliderBox:_set_text(x, y, z)
	self.__slider_x_textctrl:set_value(string.format("%.3f", x))
	self.__slider_y_textctrl:set_value(string.format("%.3f", y))
	self.__slider_z_textctrl:set_value(string.format("%.3f", z))
end

function VectorSliderBox:_on_update_textctrl()
	local x, y, z = nil
	x = self:_check_input(self.__slider_x_textctrl:get_value())
	y = self:_check_input(self.__slider_y_textctrl:get_value())
	z = self:_check_input(self.__slider_z_textctrl:get_value())

	self:set_value(Vector3(x, y, z))
end

function VectorSliderBox:_check_input(input)
	local value = tonumber(input)

	if type(value) ~= "number" then
		value = self._min
	elseif value < self._min or self._max < value then
		value = self._min
	end

	return value
end

function VectorSliderBox:_set_enabled_all(value)
	self.__slider_x:set_enabled(value)
	self.__slider_y:set_enabled(value)
	self.__slider_x_textctrl:set_enabled(value)
	self.__slider_y_textctrl:set_enabled(value)
	self.__slider_z:set_enabled(value)
	self.__slider_z_textctrl:set_enabled(value)
end

Vector2SliderBox = Vector2SliderBox or CoreClass.class(VectorSliderBox)

function Vector2SliderBox:init(parent_frame, title, min, max, step)
	self.super:init(parent_frame, title, min, max, step)

	self._vector3 = false
	self.__mute_toggle = self:_create_mute_button()
	self.__slider_x, self.__slider_x_textctrl = self:_create_sizer()
	self.__slider_y, self.__slider_y_textctrl = self:_create_sizer()
	self.__slider_z = EWS:Slider(self._parent_frame, 0, 0, 0)
	self.__slider_z_textctrl = EWS:TextCtrl(self._parent_frame, 0, "", "")
end

Vector3SliderBox = Vector3SliderBox or CoreClass.class(VectorSliderBox)

function Vector3SliderBox:init(parent_frame, title, min, max, step)
	self.super.init(self, parent_frame, title, min, max, step)

	self._vector3 = true
	self.__mute_toggle = self:_create_mute_button()
	self.__slider_x, self.__slider_x_textctrl = self:_create_sizer()
	self.__slider_y, self.__slider_y_textctrl = self:_create_sizer()
	self.__slider_z, self.__slider_z_textctrl = self:_create_sizer()
end
