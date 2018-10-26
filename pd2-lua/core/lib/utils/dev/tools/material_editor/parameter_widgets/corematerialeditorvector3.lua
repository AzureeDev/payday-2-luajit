require("core/lib/utils/dev/tools/material_editor/CoreSmartNode")

local CoreMaterialEditorParameter = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorParameter")
local CoreMaterialEditorVector3 = CoreMaterialEditorVector3 or class(CoreMaterialEditorParameter)

function CoreMaterialEditorVector3:init(parent, editor, parameter_info, parameter_node)
	CoreMaterialEditorParameter.init(self, parent, editor, parameter_info, parameter_node)

	local main_box = EWS:BoxSizer("VERTICAL")
	local box = EWS:BoxSizer("HORIZONTAL")

	main_box:add(box, 1, 0, "EXPAND")

	self._x_slider = EWS:Slider(self._right_panel, self:_to_slider_range(self._value).x, 0, self:_to_slider_range(parameter_info.max).x, "", "")

	self._x_slider:connect("", "EVT_SCROLL_THUMBTRACK", self._on_slider, self)
	self._x_slider:connect("", "EVT_SCROLL_CHANGED", self._on_slider, self)
	box:add(self._x_slider, 1, 4, "ALL,EXPAND")

	self._x_text_ctrl = EWS:TextCtrl(self._right_panel, tostring(self._value.x), "", "TE_PROCESS_ENTER")

	self._x_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", self._on_text_ctrl, self)
	self._x_text_ctrl:set_min_size(Vector3(40, -1, -1))
	box:add(self._x_text_ctrl, 0, 4, "ALL,EXPAND")

	box = EWS:BoxSizer("HORIZONTAL")

	main_box:add(box, 1, 0, "EXPAND")

	self._y_slider = EWS:Slider(self._right_panel, self:_to_slider_range(self._value).y, 0, self:_to_slider_range(parameter_info.max).y, "", "")

	self._y_slider:connect("", "EVT_SCROLL_THUMBTRACK", self._on_slider, self)
	self._y_slider:connect("", "EVT_SCROLL_CHANGED", self._on_slider, self)
	box:add(self._y_slider, 1, 4, "ALL,EXPAND")

	self._y_text_ctrl = EWS:TextCtrl(self._right_panel, tostring(self._value.y), "", "TE_PROCESS_ENTER")

	self._y_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", self._on_text_ctrl, self)
	self._y_text_ctrl:set_min_size(Vector3(40, -1, -1))
	box:add(self._y_text_ctrl, 0, 4, "ALL,EXPAND")

	box = EWS:BoxSizer("HORIZONTAL")

	main_box:add(box, 1, 0, "EXPAND")

	self._z_slider = EWS:Slider(self._right_panel, self:_to_slider_range(self._value).z, 0, self:_to_slider_range(parameter_info.max).z, "", "")

	self._z_slider:connect("", "EVT_SCROLL_THUMBTRACK", self._on_slider, self)
	self._z_slider:connect("", "EVT_SCROLL_CHANGED", self._on_slider, self)
	box:add(self._z_slider, 1, 4, "ALL,EXPAND")

	self._z_text_ctrl = EWS:TextCtrl(self._right_panel, tostring(self._value.z), "", "TE_PROCESS_ENTER")

	self._z_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", self._on_text_ctrl, self)
	self._z_text_ctrl:set_min_size(Vector3(40, -1, -1))
	box:add(self._z_text_ctrl, 0, 4, "ALL,EXPAND")
	self._right_box:add(main_box, 1, 0, "EXPAND")
end

function CoreMaterialEditorVector3:update(t, dt)
	CoreMaterialEditorParameter.update(self, t, dt)
end

function CoreMaterialEditorVector3:destroy()
	CoreMaterialEditorParameter.destroy(self)
end

function CoreMaterialEditorVector3:on_toggle_customize()
	self._customize = not self._customize

	self:_load_value()
	self._editor:_update_output()
	self._right_panel:set_enabled(self._customize)
	self._x_text_ctrl:set_value(string.format("%.3f", self._value.x))
	self._y_text_ctrl:set_value(string.format("%.3f", self._value.y))
	self._z_text_ctrl:set_value(string.format("%.3f", self._value.z))

	local value = self:_to_slider_range(self._value)

	self._x_slider:set_value(value.x)
	self._y_slider:set_value(value.y)
	self._z_slider:set_value(value.z)
	self:update_live()
end

function CoreMaterialEditorVector3:_on_slider()
	self._value = self:_from_slider_range(Vector3(self._x_slider:get_value(), self._y_slider:get_value(), self._z_slider:get_value()))

	self._parameter_node:set_parameter("value", math.vector_to_string(self._value))
	self:update_live()
	self._x_text_ctrl:set_value(string.format("%.3f", self._value.x))
	self._y_text_ctrl:set_value(string.format("%.3f", self._value.y))
	self._z_text_ctrl:set_value(string.format("%.3f", self._value.z))
end

function CoreMaterialEditorVector3:_on_text_ctrl()
	self._value = Vector3(tonumber(self._x_text_ctrl:get_value()) or 0, tonumber(self._y_text_ctrl:get_value()) or 0, tonumber(self._z_text_ctrl:get_value()) or 0)

	self._parameter_node:set_parameter("value", math.vector_to_string(self._value))
	self:update_live()

	local value = self:_to_slider_range(self._value)

	self._x_slider:set_value(value.x)
	self._y_slider:set_value(value.y)
	self._z_slider:set_value(value.z)
	self._editor:_update_output()
end

function CoreMaterialEditorVector3:_to_slider_range(v)
	local step_x = self._parameter_info.step.x

	if step_x == 0 then
		step_x = step_x + 0.001
	end

	local step_y = self._parameter_info.step.y

	if step_y == 0 then
		step_y = step_y + 0.001
	end

	local step_z = self._parameter_info.step.z

	if step_z == 0 then
		step_z = step_z + 0.001
	end

	return Vector3(CoreMaterialEditorParameter.to_slider_range(self, v.x, self._parameter_info.min.x, step_x), CoreMaterialEditorParameter.to_slider_range(self, v.y, self._parameter_info.min.y, step_y), CoreMaterialEditorParameter.to_slider_range(self, v.z, self._parameter_info.min.z, step_z))
end

function CoreMaterialEditorVector3:_from_slider_range(v)
	local step_x = self._parameter_info.step.x

	if step_x == 0 then
		step_x = step_x + 0.001
	end

	local step_y = self._parameter_info.step.y

	if step_y == 0 then
		step_y = step_y + 0.001
	end

	local step_z = self._parameter_info.step.z

	if step_z == 0 then
		step_z = step_z + 0.001
	end

	return Vector3(CoreMaterialEditorParameter.from_slider_range(self, v.x, self._parameter_info.min.x, step_x), CoreMaterialEditorParameter.from_slider_range(self, v.y, self._parameter_info.min.y, step_y), CoreMaterialEditorParameter.from_slider_range(self, v.z, self._parameter_info.min.z, step_z))
end

return CoreMaterialEditorVector3
