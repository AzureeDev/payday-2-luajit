require("core/lib/utils/dev/tools/material_editor/CoreSmartNode")

local CoreMaterialEditorParameter = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorParameter")
local CoreMaterialEditorDBValue = CoreMaterialEditorDBValue or class(CoreMaterialEditorParameter)

function CoreMaterialEditorDBValue:init(parent, editor, parameter_info, parameter_node)
	CoreMaterialEditorParameter.init(self, parent, editor, parameter_info, parameter_node)

	self._combobox = EWS:ComboBox(self._right_panel, self._value, "", "CB_READONLY")

	self:_fill_combobox()
	self._combobox:set_value(self._value)
	self._combobox:connect("", "EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_on_combobox_changed"), "")
	self._right_box:add(self._combobox, 0, 4, "ALL,EXPAND")
end

function CoreMaterialEditorDBValue:update(t, dt)
	CoreMaterialEditorParameter.update(self, t, dt)
end

function CoreMaterialEditorDBValue:destroy()
	CoreMaterialEditorParameter.destroy(self)
end

function CoreMaterialEditorDBValue:on_toggle_customize()
	self._customize = not self._customize

	self:_load_value()
	self._editor:_update_output()
	self._right_panel:set_enabled(self._customize)
	self._combobox:set_value(self._value)
	self:update_live()
end

function CoreMaterialEditorDBValue:_on_combobox_changed()
	self._value = self._combobox:get_value()

	self._parameter_node:set_parameter("value", tostring(self._value))
	self:update_live()
end

function CoreMaterialEditorDBValue:_fill_combobox()
	for _, v in ipairs(LightIntensityDB:list()) do
		self._combobox:append(v:s())
	end
end

return CoreMaterialEditorDBValue
