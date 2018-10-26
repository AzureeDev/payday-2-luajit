require("core/lib/utils/dev/tools/material_editor/CoreSmartNode")

local CoreMaterialEditorParameter = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorParameter")
local CoreMaterialEditorDecal = CoreMaterialEditorDecal or class(CoreMaterialEditorParameter)
CoreMaterialEditorDecal.DECAL_MATERIAL_FILE = "settings/decals"

function CoreMaterialEditorDecal:init(parent, editor)
	self:_set_params(parent, editor)

	self._panel = EWS:Panel(parent, "", "")
	self._box = EWS:BoxSizer("HORIZONTAL")
	self._left_panel = EWS:Panel(self._panel, "", "")
	self._left_box = EWS:BoxSizer("VERTICAL")

	self._left_panel:set_sizer(self._left_box)
	self._box:add(self._left_panel, 0, 4, "RIGHT,EXPAND")

	local panel = EWS:Panel(self._panel, "", "")

	self._left_box:add(panel, 1, 0, "EXPAND")

	self._parent_btn = EWS:Button(self._left_panel, "+", "", "NO_BORDER")

	self._parent_btn:set_min_size(Vector3(15, 15, 0))
	self._parent_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", editor._on_parameter_popup, self)
	self._left_box:add(self._parent_btn, 0, 0, "ALIGN_CENTER_HORIZONTAL")

	panel = EWS:Panel(self._panel, "", "")

	self._left_box:add(panel, 1, 0, "EXPAND")

	self._right_panel = EWS:Panel(self._panel, "", "")
	self._right_box = EWS:StaticBoxSizer(self._right_panel, "HORIZONTAL", "Decal Material")

	self._right_panel:set_sizer(self._right_box)
	self._box:add(self._right_panel, 1, 4, "LEFT,EXPAND")
	self._panel:set_sizer(self._box)

	self._combo_box = EWS:ComboBox(self._right_panel, "", "", "CB_READONLY,CB_SORT")
	self._customize = self._editor._current_material_node:parameter("src") == nil or self._parameter_node ~= nil

	self._right_panel:set_enabled(self._customize)
	self:_fill_decal_materials()
	self._combo_box:connect("", "EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_on_combo_box_change"), "")
	self._right_box:add(self._combo_box, 1, 4, "ALL,EXPAND")
	self._editor:_update_output()
end

function CoreMaterialEditorDecal:update(t, dt)
	CoreMaterialEditorParameter.update(self, t, dt)
end

function CoreMaterialEditorDecal:destroy()
	CoreMaterialEditorParameter.destroy(self)
end

function CoreMaterialEditorDecal:on_toggle_customize()
	self._customize = not self._customize

	self._editor:_update_output()
	self._right_panel:set_enabled(self._customize)

	if self._customize then
		self._editor._current_material_node:clear_parameter("decal_material")

		if self._parent_node and self._parent_node:parameter("decal_material") then
			self._combo_box:set_value(self._parent_node:parameter("decal_material"))
		else
			self._combo_box:set_value("[NONE]")
		end
	elseif self._value == "[NONE]" then
		self._editor._current_material_node:clear_parameter("decal_material")
	else
		self._editor._current_material_node:set_parameter("decal_material", self._value)
	end
end

function CoreMaterialEditorDecal:on_copy_to_parent()
	if self._editor._parent_combo_box:get_value() ~= "[NONE]" then
		self:_copy_to_parent()
	else
		local name = EWS:get_text_from_user(self._editor._main_frame, "Name: ", "Create New Parent", "", Vector3(-1, -1, 0), true)

		if name ~= "" then
			if self._editor:_find_node(self._editor._material_config_node, "name", name) then
				EWS:MessageDialog(self._editor._main_frame, "A parent with that name already exists!", "Create New Parent", "OK,ICON_ERROR"):show_modal()
			else
				self:_copy_to_parent(name)
			end
		end
	end

	self._editor:_create_parameter_panel()
end

function CoreMaterialEditorDecal:_set_params(parent, editor)
	self._parent = parent
	self._editor = editor
	self._value = self._editor._current_material_node:parameter("decal_material") or "[NONE]"
	self._parent_node = self._editor._parent_materials[self._editor._parent_combo_box:get_value()]
end

function CoreMaterialEditorDecal:_copy_to_parent(name)
	local material_node = nil

	if name then
		material_node = self._editor._global_material_config_node:make_child("material")

		material_node:set_parameter("name", name)
	else
		material_node = self._editor:_find_node(self._editor._global_material_config_node, "material", "name", self._editor._parent_combo_box:get_value())
	end

	if self._value == "[NONE]" and not name then
		material_node:clear_parameter("decal_material")
	else
		material_node:set_parameter("decal_material", self._value)
	end

	local parent = self._editor._parent_combo_box:get_value()

	self._editor:_load_parent_dropdown()
	self._editor._parent_combo_box:set_value(parent)
end

function CoreMaterialEditorDecal:_on_combo_box_change()
	self._value = self._combo_box:get_value()

	if self._value == "[NONE]" then
		self._editor._current_material_node:clear_parameter("decal_material")
	else
		self._editor._current_material_node:set_parameter("decal_material", self._value)
	end

	self._editor:_update_output()
end

function CoreMaterialEditorDecal:_fill_decal_materials()
	self._combo_box:clear()
	self._combo_box:append("[NONE]")

	local root = DB:load_node("decals", self.DECAL_MATERIAL_FILE)

	if root and root:num_children() > 0 then
		for material in root:children() do
			if material:name() == "material" then
				self._combo_box:append(material:parameter("name"))
			end
		end
	end

	self._combo_box:set_value(self._value)
end

return CoreMaterialEditorDecal
