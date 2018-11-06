CoreCameraDistancePicker = CoreCameraDistancePicker or class()

function CoreCameraDistancePicker:init(parent_window, value, button_label)
	local sizer = EWS:BoxSizer("HORIZONTAL")
	self.__panel = EWS:Panel(parent_window)

	self.__panel:set_sizer(sizer)

	self.__field = EWS:SpinCtrl(self.__panel, value or "", "", "")

	self.__field:set_range(0, 100000)
	self.__field:set_min_size(self.__field:get_min_size():with_x(0))

	self.__button = EWS:Button(self.__panel, button_label or "Pick", "", "BU_EXACTFIT")

	self.__button:fit_inside()
	sizer:add(self.__field, 1, 0, "EXPAND")
	sizer:add(self.__button, 0, 5, "LEFT")
	self.__button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_enter_pick_mode"))
end

function CoreCameraDistancePicker:panel()
	return self.__panel
end

function CoreCameraDistancePicker:update(time, delta_time)
	local picking_camera = self.__is_picking and managers.viewport and managers.viewport:get_current_camera()

	if picking_camera then
		local ray_start = picking_camera:position()
		local ray_end = self:_screen_to_world(managers.editor:cursor_pos():with_z(picking_camera:far_range()))
		local raycast = World:raycast(ray_start, ray_end)

		if raycast then
			local focus_point = Draw:pen()
			local screen_position = self:_world_to_screen(raycast.position)

			focus_point:set("screen")
			focus_point:set(Color("ff0000"))
			focus_point:circle(screen_position, 0.1)
			focus_point:line(screen_position:with_x(-1), screen_position:with_x(screen_position.x - 0.1))
			focus_point:line(screen_position:with_x(screen_position.x + 0.1), screen_position:with_x(1))
			focus_point:line(screen_position:with_y(-1), screen_position:with_y(screen_position.y - 0.1))
			focus_point:line(screen_position:with_y(screen_position.y + 0.1), screen_position:with_y(1))
			self.__field:set_value(string.format("%i", math.max(0, math.round(raycast.distance - 10))))
		end

		if EWS:MouseEvent("EVT_MOTION"):left_is_down() then
			self:_exit_pick_mode()
		end
	end
end

function CoreCameraDistancePicker:_screen_to_world(coords)
	local camera = assert(managers.viewport and managers.viewport:get_current_camera())
	local viewport = assert(managers.viewport and managers.viewport:get_active_vp())
	local viewport_rect = viewport:get_rect()
	local viewport_position = coords:with_x(coords.x * 2 * viewport:get_width_multiplier() / viewport_rect.w):with_y(coords.y * 2 / viewport_rect.h)

	return camera:screen_to_world(viewport_position)
end

function CoreCameraDistancePicker:_world_to_screen(coords)
	local camera = assert(managers.viewport and managers.viewport:get_current_camera())
	local viewport = assert(managers.viewport and managers.viewport:get_active_vp())
	local viewport_rect = viewport:get_rect()
	local viewport_position = camera:world_to_screen(coords)
	local screen_position = viewport_position:with_x(viewport_position.x * 2 * viewport:get_width_multiplier() / viewport_rect.w):with_y(-viewport_position.y / 2 * viewport_rect.h)

	return screen_position
end

function CoreCameraDistancePicker:connect(event_type, script_callback, object_data)
	if object_data then
		self.__field:connect(event_type, script_callback, object_data)
	else
		self.__field:connect(event_type, script_callback)
	end
end

function CoreCameraDistancePicker:disconnect(event_type, script_callback, object_data)
	if object_data then
		self.__field:disconnect(event_type, script_callback, object_data)
	else
		self.__field:disconnect(event_type, script_callback)
	end
end

function CoreCameraDistancePicker:get_value(value)
	return self.__field:get_value(value)
end

function CoreCameraDistancePicker:set_value(value)
	self.__field:set_value(value)
end

function CoreCameraDistancePicker:change_value(value)
	self.__field:change_value(value)
end

function CoreCameraDistancePicker:set_background_colour(r, g, b)
	self.__field:set_background_colour(r, g, b)
	self.__field:refresh()
	self.__field:update()
end

function CoreCameraDistancePicker:enabled()
	return self.__field:enabled()
end

function CoreCameraDistancePicker:set_enabled(enabled)
	self.__field:set_enabled(enabled)
	self.__button:set_enabled(enabled and not self.__pick_button_disabled)
end

function CoreCameraDistancePicker:set_pick_button_enabled(enabled)
	self.__pick_button_disabled = not enabled or nil

	self.__button:set_enabled(self:enabled() and not self.__pick_button_disabled)
end

function CoreCameraDistancePicker:has_focus()
	return self.__is_picking or EWS:get_window_in_focus() == self.__field
end

function CoreCameraDistancePicker:_enter_pick_mode()
	self.__is_picking = true
end

function CoreCameraDistancePicker:_exit_pick_mode()
	self.__is_picking = nil
end
