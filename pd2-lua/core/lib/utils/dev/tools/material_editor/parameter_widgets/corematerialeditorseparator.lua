require("core/lib/utils/dev/tools/material_editor/CoreSmartNode")

local CoreMaterialEditorParameter = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorParameter")
local CoreMaterialEditorSeparator = CoreMaterialEditorSeparator or class(CoreMaterialEditorParameter)

function CoreMaterialEditorSeparator:init(parent)
	self._panel = EWS:Panel(parent, "", "")
	self._box = EWS:BoxSizer("HORIZONTAL")
	self._line = EWS:StaticLine(self._panel, "", "")

	self._box:add(self._line, 1, 4, "TOP,EXPAND")
	self._panel:set_sizer(self._box)
end

function CoreMaterialEditorSeparator:update(t, dt)
end

function CoreMaterialEditorSeparator:destroy()
	CoreMaterialEditorParameter.destroy(self)
end

return CoreMaterialEditorSeparator
