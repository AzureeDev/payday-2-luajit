require("core/lib/utils/dev/tools/material_editor/CoreSmartNode")

local CoreMaterialEditorParameter = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorParameter")
local CoreMaterialEditorScalar = CoreMaterialEditorScalar or class(CoreMaterialEditorParameter)

function CoreMaterialEditorScalar:init(parent, editor, parameter_info, parameter_node)
	CoreMaterialEditorParameter.init(self, parent, editor, parameter_info, parameter_node)

	self._slider = EWS:Slider(self._right_panel, self:to_slider_range(self._value, parameter_info.min, parameter_info.step), 0, self:to_slider_range(parameter_info.max, parameter_info.min, parameter_info.step), "", "")

	self._slider:connect("", "EVT_SCROLL_THUMBTRACK", self._on_slider, self)
	self._slider:connect("", "EVT_SCROLL_CHANGED", self._on_slider, self)
	self._right_box:add(self._slider, 1, 4, "ALL,EXPAND")

	self._text_ctrl = EWS:TextCtrl(self._right_panel, tostring(self._value), "", "TE_PROCESS_ENTER")

	self._text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", self._on_text_ctrl, self)
	self._text_ctrl:set_min_size(Vector3(40, -1, -1))
	self._right_box:add(self._text_ctrl, 0, 4, "ALL,EXPAND")
end

function CoreMaterialEditorScalar:update(t, dt)
	CoreMaterialEditorParameter.update(self, t, dt)
end

function CoreMaterialEditorScalar:destroy()
	CoreMaterialEditorParameter.destroy(self)
end

function CoreMaterialEditorScalar:on_toggle_customize()
	self._customize = not self._customize

	self:_load_value()
	self._editor:_update_output()
	self._right_panel:set_enabled(self._customize)
	self._text_ctrl:set_value(string.format("%.3f", self._value))
	self._slider:set_value(self:to_slider_range(self._value, self._parameter_info.min, self._parameter_info.step))
	self:update_live()
end

function CoreMaterialEditorScalar:_on_slider()
	self._value = self:from_slider_range(self._slider:get_value(), self._parameter_info.min, self._parameter_info.step)

	self._parameter_node:set_parameter("value", tostring(self._value))
	self._text_ctrl:set_value(string.format("%.3f", self._value))
	self:update_live()
end

function CoreMaterialEditorScalar:_on_text_ctrl()
	self._value = tonumber(self._text_ctrl:get_value()) or 0

	self._parameter_node:set_parameter("value", tostring(self._value))
	self._slider:set_value(self:to_slider_range(self._value, self._parameter_info.min, self._parameter_info.step))
	self._editor:_update_output()
	self:update_live()
end

return CoreMaterialEditorScalar
