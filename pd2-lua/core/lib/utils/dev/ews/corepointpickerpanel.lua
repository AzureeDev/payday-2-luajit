core:module("CorePointPickerPanel")
core:import("CorePointPicker")
core:import("CorePointerDraw")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreDebug")

PointPickerPanel = PointPickerPanel or CoreClass.class()

function PointPickerPanel:init(parent_frame, title)
	assert(managers.viewport)

	self.__point_picker = CorePointPicker.PointPicker:new(managers.viewport:get_active_vp())

	self.__point_picker:connect("EVT_PICKING", CoreEvent.callback(self, self, "_on_picking"), self.__point_picker)
	self.__point_picker:connect("EVT_FINISHED_PICKING", CoreEvent.callback(self, self, "_on_finished_picking"), self.__point_picker)

	self.__point_draw = CorePointerDraw.PointerDraw:new(Color("ffffff"), 10)

	self:_create_panel(parent_frame)
end

function PointPickerPanel:_create_panel(parent_frame)
	local panel_sizer = EWS:BoxSizer("HORIZONTAL")
	self.__panel = EWS:Panel(parent_frame)

	self.__panel:set_sizer(panel_sizer)

	self.__picker_button = EWS:ToggleButton(self.__panel, "Pick", "", "NO_BORDER")

	self.__picker_button:connect("", "EVT_COMMAND_TOGGLEBUTTON_CLICKED", CoreEvent.callback(self, self, "_on_picker_toggle"), "")

	self.__x_textctrl = EWS:TextCtrl(self.__panel, 0, "", "TE_PROCESS_ENTER,TE_RIGHT")
	self.__y_textctrl = EWS:TextCtrl(self.__panel, 0, "", "TE_PROCESS_ENTER,TE_RIGHT")
	self.__z_textctrl = EWS:TextCtrl(self.__panel, 0, "", "TE_PROCESS_ENTER,TE_RIGHT")

	panel_sizer:add(self.__picker_button, 1, 2, "ALL,EXPAND")
	panel_sizer:add(EWS:StaticText(self.__panel, "x:"), 0, 4, "ALL,ALIGN_CENTER_VERTICAL,ALIGN_RIGHT")
	panel_sizer:add(self.__x_textctrl, 1, 2, "ALL,EXPAND,ALIGN_RIGHT")
	panel_sizer:add(EWS:StaticText(self.__panel, "y:"), 0, 4, "ALL,ALIGN_CENTER_VERTICAL,ALIGN_RIGHT")
	panel_sizer:add(self.__y_textctrl, 1, 2, "ALL,EXPAND,ALIGN_RIGHT")
	panel_sizer:add(EWS:StaticText(self.__panel, "z:"), 0, 4, "ALL,ALIGN_CENTER_VERTICAL,ALIGN_RIGHT")
	panel_sizer:add(self.__z_textctrl, 1, 2, "ALL,EXPAND,ALIGN_RIGHT")
end

function PointPickerPanel:panel()
	return self.__panel
end

function PointPickerPanel:get_value()
	return self.__current_position
end

function PointPickerPanel:set_value(vector)
	self.__current_position = vector

	self:_set_text(vector)
end

function PointPickerPanel:update(time, delta_time)
	if self:_text_ctrl_has_focus() then
		self.__current_position = Vector3(self.__x_textctrl:get_value(), self.__y_textctrl:get_value(), self.__z_textctrl:get_value())
		self.__draw_position = self.__current_position
	end

	self.__point_draw:set_position(self.__draw_position)
	self.__point_picker:update(time, delta_time)
	self.__point_draw:update(time, delta_time)
end

function PointPickerPanel:_text_ctrl_has_focus()
	return EWS:get_window_in_focus() == self.__x_textctrl or EWS:get_window_in_focus() == self.__y_textctrl or EWS:get_window_in_focus() == self.__z_textctrl
end

function PointPickerPanel:_set_text(vector)
	self.__x_textctrl:set_value(string.format("%.3f", vector.x))
	self.__y_textctrl:set_value(string.format("%.3f", vector.y))
	self.__z_textctrl:set_value(string.format("%.3f", vector.z))
end

function PointPickerPanel:_on_picker_toggle()
	if self.__picker_button:get_value() == false then
		self.__point_picker:stop_picking()
		self.__picker_button:set_value(true)
	else
		self.__point_picker:start_picking()
		self.__picker_button:set_value(false)
	end
end

function PointPickerPanel:_on_picking(sender, raycast)
	if raycast then
		self:_set_text(raycast.position)

		self.__current_position = raycast.position
		self.__draw_position = raycast.position
	else
		self:set_value(Vector3(0, 0, 0))

		self.__draw_position = nil
		self.__current_position = nil
	end
end

function PointPickerPanel:_on_finished_picking(sender, raycast)
	if raycast then
		self.__picker_button:set_value(false)

		self.__current_position = raycast.position
		self.__draw_position = nil

		self:set_value(raycast.position)
	end
end
