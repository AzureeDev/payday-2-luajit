core:module("CoreColorPickerDraggables")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreMath")

ColorPickerDraggables = ColorPickerDraggables or CoreClass.mixin(CoreClass.class(), CoreEvent.BasicEventHandling)

function ColorPickerDraggables:init(parent_frame, enable_alpha, enable_value)
	self:_create_panel(parent_frame, enable_alpha, enable_value)
	self:set_color(Color.white)
end

function ColorPickerDraggables:update(time, delta_time)
	local current_mouse_event = EWS:MouseEvent("EVT_MOTION")
	self._previous_mouse_event = self._previous_mouse_event or current_mouse_event

	if self._dragged_control and current_mouse_event:get_position() ~= self._previous_mouse_event:get_position() then
		self:_on_dragging(self._dragged_control, current_mouse_event)
	end

	if self._dragged_control and current_mouse_event:left_is_down() == false and self._previous_mouse_event:left_is_down() == true then
		self:_on_drag_stop(self._dragged_control, current_mouse_event)
	end

	self._previous_mouse_event = current_mouse_event
end

function ColorPickerDraggables:panel()
	return self._panel
end

function ColorPickerDraggables:color()
	return (self._alpha_slider or self._value_slider or self._spectrum):color()
end

function ColorPickerDraggables:set_color(color)
	hue, saturation, value = CoreMath.rgb_to_hsv(color.red, color.green, color.blue)

	self._spectrum:set_hue(hue)
	self._spectrum:set_saturation(saturation)
	self._spectrum:set_value(value)

	if self._value_slider then
		self._value_slider:set_value(value)
	end

	if self._alpha_slider then
		self._alpha_slider:set_value(color.alpha)
	end

	self:_update_ui_except(self._spectrum)
end

function ColorPickerDraggables:_create_panel(parent_frame, enable_alpha, enable_value)
	if enable_alpha == nil then
		enable_alpha = true
	end

	if enable_value == nil then
		enable_value = true
	end

	self._panel = EWS:Panel(parent_frame)

	self._panel:set_min_size(Vector3(180, 134, 0))

	local panel_sizer = EWS:BoxSizer("HORIZONTAL")

	self._panel:set_sizer(panel_sizer)

	local slider_width = 20
	local slider_margin = 3
	self._spectrum = EWS:ColorSpectrum(self._panel, "")

	panel_sizer:add(self._spectrum, 0, slider_margin, "ALL")
	self._spectrum:connect("EVT_LEFT_DOWN", CoreEvent.callback(self, self, "_on_drag_start"), self._spectrum)

	local spectrum_size = self._spectrum:get_min_size()

	if enable_value then
		self._value_slider = EWS:ColorSlider(self._panel, "")

		panel_sizer:add(self._value_slider, 0, 0, "EXPAND")
		self._value_slider:connect("EVT_LEFT_DOWN", CoreEvent.callback(self, self, "_on_drag_start"), self._value_slider)
	else
		spectrum_size = spectrum_size:with_x(spectrum_size.x + slider_width + slider_margin)
	end

	if enable_alpha then
		self._alpha_slider = EWS:ColorSlider(self._panel, "")

		panel_sizer:add(self._alpha_slider, 0, slider_margin, "LEFT,RIGHT,EXPAND")
		self._alpha_slider:connect("EVT_LEFT_DOWN", CoreEvent.callback(self, self, "_on_drag_start"), self._alpha_slider)
	else
		spectrum_size = spectrum_size:with_x(spectrum_size.x + slider_width + slider_margin)
	end

	self._spectrum:set_min_size(spectrum_size)
end

function ColorPickerDraggables:_update_ui_except(sender)
	if self._value_slider ~= nil then
		if sender ~= self._spectrum then
			self._spectrum:set_value(self._value_slider:value())
		end

		if sender ~= self._value_slider then
			self._value_slider:set_top_color(self._spectrum:unscaled_color())
		end
	end

	if sender ~= self._alpha_slider and self._alpha_slider ~= nil then
		local opaque_color = (self._value_slider or self._spectrum):color()

		self._alpha_slider:set_top_color(opaque_color)
		self._alpha_slider:set_bottom_color(opaque_color:with_alpha(0))
	end
end

function ColorPickerDraggables:_process_color_update_event(sender, event)
	local event_position_in_sender = event:get_position(sender)

	if sender == self._spectrum then
		sender:set_hue(sender:point_to_hue(event_position_in_sender))
		sender:set_saturation(sender:point_to_saturation(event_position_in_sender))
	else
		sender:set_value(sender:point_to_value(event_position_in_sender))
	end

	self:_update_ui_except(sender)
	self:_send_event("EVT_COLOR_UPDATED", self:color())
end

function ColorPickerDraggables:_process_color_change_event(sender, event)
	self:_process_color_update_event(sender, event)
	self:_send_event("EVT_COLOR_CHANGED", self:color())
end

function ColorPickerDraggables:_on_drag_start(sender, event)
	self._previous_mouse_event = EWS:MouseEvent("EVT_LEFT_DOWN")
	self._dragged_control = sender

	self:_process_color_update_event(sender, event)
end

function ColorPickerDraggables:_on_dragging(sender, event)
	self:_process_color_update_event(sender, event)
end

function ColorPickerDraggables:_on_drag_stop(sender, event)
	self:_process_color_change_event(sender, event)

	self._dragged_control = nil
end
