require("core/lib/utils/dev/tools/material_editor/CoreSmartNode")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreEws")
core:import("CoreColorPickerPanel")

local CoreMaterialEditorParameter = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorParameter")
local CoreMaterialEditorColor3 = CoreMaterialEditorColor3 or class(CoreMaterialEditorParameter)

function CoreMaterialEditorColor3:init(parent, editor, parameter_info, parameter_node)
	CoreMaterialEditorParameter.init(self, parent, editor, parameter_info, parameter_node)

	self._picker_panel = CoreColorPickerPanel.ColorPickerPanel:new(self._right_panel, false, "HORIZONTAL")

	self._picker_panel:set_color(Color(self._value.x, self._value.y, self._value.z))
	self._picker_panel:connect("EVT_COLOR_UPDATED", CoreEvent.callback(self, self, "_on_color"), self._picker_panel)
	self._right_box:add(self._picker_panel:panel(), 1, 0, "ALL,EXPAND")
end

function CoreMaterialEditorColor3:update(t, dt)
	CoreMaterialEditorParameter.update(self, t, dt)
	self._picker_panel:update(t, dt)
end

function CoreMaterialEditorColor3:destroy()
	CoreMaterialEditorParameter.destroy(self)
end

function CoreMaterialEditorColor3:on_toggle_customize()
	self._customize = not self._customize

	self:_load_value()
	self._editor:_update_output()
	self._right_panel:set_enabled(self._customize)
	self._picker_panel:set_color(Color(self._value.x, self._value.y, self._value.z))
	self:update_live()
end

function CoreMaterialEditorColor3:_on_color(sender, color)
	self._value = Vector3(color.r, color.g, color.b)

	self._parameter_node:set_parameter("value", math.vector_to_string(self._value))
	self:update_live()
end

return CoreMaterialEditorColor3
