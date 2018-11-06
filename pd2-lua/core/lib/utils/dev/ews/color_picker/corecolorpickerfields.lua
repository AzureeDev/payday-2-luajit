core:module("CoreColorPickerFields")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreTable")
core:import("CoreEws")
core:import("CoreMath")

ColorPickerFields = ColorPickerFields or CoreClass.mixin(CoreClass.class(), CoreEvent.BasicEventHandling)

function ColorPickerFields:init(parent_frame, enable_alpha, enable_value)
	self:_create_panel(parent_frame, enable_alpha, enable_value)
	self:set_color(Color.white)
end

function ColorPickerFields:update(time, delta_time)
	if self._is_picking_color_from_screen then
		local current_mouse_event = EWS:MouseEvent("EVT_MOTION")
		self._previous_mouse_event = self._previous_mouse_event or current_mouse_event

		if current_mouse_event:get_position() ~= self._previous_mouse_event:get_position() then
			local pixel_rgb = EWS:get_screen_pixel(current_mouse_event:get_position_on_screen()) / 255
			local color_under_cursor = Color(pixel_rgb.x, pixel_rgb.y, pixel_rgb.z)

			self:set_color(color_under_cursor)
			self:_send_event("EVT_COLOR_UPDATED", color_under_cursor)
		end

		if current_mouse_event:left_is_down() == true and self._previous_mouse_event:left_is_down() == false then
			self:_on_exit_eyedropper_mode(nil, current_mouse_event)

			current_mouse_event = nil
		end

		self._previous_mouse_event = current_mouse_event
	end
end

function ColorPickerFields:panel()
	return self._panel
end

function ColorPickerFields:color()
	local a = self:_field_value("Alpha") or 255
	local r = self:_field_value("Red") or 0
	local g = self:_field_value("Green") or 0
	local b = self:_field_value("Blue") or 0

	return Color(a / 255, r / 255, g / 255, b / 255)
end

function ColorPickerFields:set_color(color)
	self:_set_field_values_except(nil, color)
end

function ColorPickerFields:_field_value(field_name)
	local field_group = self._field_groups and assert(self._field_groups[field_name], "Invalid field.") or {}

	for _, field in ipairs(field_group) do
		return tonumber(field:get_value())
	end
end

function ColorPickerFields:_change_field_value(field_name, value)
	local field_group = assert(self._field_groups[field_name], "Invalid field.")

	for _, field in ipairs(field_group) do
		field:change_value(string.format("%.0f", value))
	end
end

function ColorPickerFields:_create_panel(parent_frame, enable_alpha, enable_value)
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

	local notebook = EWS:Notebook(self._panel, "", "NB_TOP")

	notebook:add_page(self:_create_rgb_fields(notebook), "RGB", true)
	notebook:add_page(self:_create_hsv_fields(notebook), "HSV", false)

	if not enable_alpha then
		for _, field in ipairs(self._field_groups.Alpha) do
			field:set_enabled(false)
		end
	end

	if not enable_value then
		for _, field in ipairs(self._field_groups.Value) do
			field:set_enabled(false)
		end
	end

	panel_sizer:add(notebook, 1, 3, "ALL,EXPAND")

	self._color_well_column_panel = EWS:Panel(self._panel)
	local color_well_column_panel_sizer = EWS:BoxSizer("VERTICAL")

	self._color_well_column_panel:set_sizer(color_well_column_panel_sizer)
	color_well_column_panel_sizer:add(self:_create_color_well(self._color_well_column_panel), 1, 23, "TOP,EXPAND")
	color_well_column_panel_sizer:add(self:_create_color_picker_button(self._color_well_column_panel), 0, 4, "TOP,BOTTOM,EXPAND")
	panel_sizer:add(self._color_well_column_panel, 0, 3, "RIGHT,EXPAND")
end

function ColorPickerFields:_create_color_well(parent_frame)
	self._color_well = EWS:ColorWell(parent_frame, "")

	self._color_well:set_tool_tip("Active color")
	self._color_well:set_size(Vector3(41, 80, 0))
	self._color_well:set_color(self:color())

	return self._color_well
end

function ColorPickerFields:_create_color_picker_button(parent_frame)
	self._color_picker_button = EWS:BitmapButton(parent_frame, CoreEws.image_path("toolbar/eye_dropper_16x16.png"), "", "")

	self._color_picker_button:set_tool_tip("Pick a color from the screen")
	self._color_picker_button:connect("EVT_COMMAND_BUTTON_CLICKED", CoreEvent.callback(self, self, "_on_enter_eyedropper_mode"), self._color_picker_button)

	return self._color_picker_button
end

function ColorPickerFields:_create_rgb_fields(parent_frame)
	local fields = {
		"Red",
		{
			max = 255
		},
		"Green",
		{
			max = 255
		},
		"Blue",
		{
			max = 255
		},
		"Alpha",
		{
			max = 255
		}
	}

	return self:_create_panel_with_fields(parent_frame, fields)
end

function ColorPickerFields:_create_hsv_fields(parent_frame)
	local fields = {
		"Hue",
		{
			wrap = true,
			max = 359
		},
		"Sat",
		{
			max = 100
		},
		"Value",
		{
			max = 100
		},
		"Alpha",
		{
			max = 255
		}
	}

	return self:_create_panel_with_fields(parent_frame, fields)
end

function ColorPickerFields:_create_panel_with_fields(parent_frame, fields)
	local panel = EWS:Panel(parent_frame)
	local panel_sizer = EWS:FlexGridSizer(0, 2, 3, 0)

	panel_sizer:add_growable_col(1, 1)
	panel:set_sizer(panel_sizer)
	panel_sizer:add_spacer(50, 0)
	panel_sizer:add_spacer(0, 0)

	for field_name, field_attributes in table.tuple_iterator(fields, 2) do
		local value = 0
		local label = EWS:StaticText(panel, field_name .. ":")
		local field = EWS:SpinCtrl(panel, tostring(value), "", field_attributes.wrap and "SP_WRAP,SP_ARROW_KEYS" or "SP_ARROW_KEYS")

		field:set_range(0, field_attributes.max or 255)
		field:connect("EVT_COMMAND_TEXT_UPDATED", CoreEvent.callback(self, self, "_on_field_edited"), field)
		panel_sizer:add(label, 0, 5, "LEFT,ALIGN_CENTER_VERTICAL")
		panel_sizer:add(field, 1, 5, "RIGHT,EXPAND")

		self._field_groups = self._field_groups or {}
		self._field_groups[field_name] = self._field_groups[field_name] or {}

		table.insert(self._field_groups[field_name], field)
	end

	return panel
end

function ColorPickerFields:_on_field_edited(edited_field, event)
	for _, field in ipairs(self:_mirroring_fields(edited_field)) do
		field:change_value(edited_field:get_value())
	end

	local edited_field_label = self:_field_label(edited_field)

	if table.contains({
		"Red",
		"Green",
		"Blue"
	}, edited_field_label) then
		local rgb_values = self:_parse_values({
			Blue = 255,
			Green = 255,
			Alpha = 255,
			Red = 255
		})

		if rgb_values then
			self:_set_field_values_except(edited_field_label, Color(rgb_values.Alpha, rgb_values.Red, rgb_values.Green, rgb_values.Blue))
		end
	elseif table.contains({
		"Hue",
		"Sat",
		"Value"
	}, edited_field_label) then
		local hsv_values = self:_parse_values({
			Value = 100,
			Sat = 100,
			Alpha = 255,
			Hue = 1
		})

		if hsv_values then
			r, g, b = CoreMath.hsv_to_rgb(hsv_values.Hue, hsv_values.Sat, hsv_values.Value)

			self:_set_field_values_except(edited_field_label, Color(hsv_values.Alpha, r, g, b))
		end
	end

	self:_send_event("EVT_COLOR_UPDATED", self:color())
	self:_send_event("EVT_COLOR_CHANGED", self:color())
end

function ColorPickerFields:_on_enter_eyedropper_mode(sender, event)
	self._is_picking_color_from_screen = true
end

function ColorPickerFields:_on_exit_eyedropper_mode(sender, event)
	self._is_picking_color_from_screen = nil

	self._panel:set_focus()
	self:_send_event("EVT_COLOR_CHANGED", color_under_cursor)
end

function ColorPickerFields:_parse_values(field_names)
	local values = {}

	for field_name, range in pairs(field_names) do
		local numeric_value = self:_field_value(field_name)

		if numeric_value == nil then
			return nil
		else
			values[field_name] = numeric_value / range
		end
	end

	return values
end

function ColorPickerFields:_set_field_values_except(skipped_field_name, color)
	hue, saturation, value = CoreMath.rgb_to_hsv(color.red, color.green, color.blue)
	local field_values = {
		Red = color.red * 255,
		Green = color.green * 255,
		Blue = color.blue * 255,
		Alpha = color.alpha * 255,
		Hue = hue,
		Sat = saturation * 100,
		Value = value * 100
	}

	for field_name, value in pairs(field_values) do
		if field_name ~= skipped_field_name then
			self:_change_field_value(field_name, value)
		end
	end

	self._color_well:set_color(color)
end

function ColorPickerFields:_field_label(field)
	for label, field_list in pairs(self._field_groups) do
		if table.contains(field_list, field) then
			return label
		end
	end
end

function ColorPickerFields:_mirroring_fields(field)
	local field_groups = table.map_values(self._field_groups)
	local my_group = table.find_value(field_groups, function (group)
		return table.contains(group, field)
	end)

	return table.exclude(my_group, field)
end
