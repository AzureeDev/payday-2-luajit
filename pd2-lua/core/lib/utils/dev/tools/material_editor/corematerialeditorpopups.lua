CoreMaterialEditor = CoreMaterialEditor or class()

function CoreMaterialEditor:_on_material_popup()
	local popup = EWS:Menu("")

	popup:append_item("POPUP_ADD_MATERIAL", "Add", "")
	popup:connect("POPUP_ADD_MATERIAL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_add_material"), "")
	popup:append_separator()
	popup:append_item("POPUP_COPY_MATERIAL", "Copy", "")
	popup:set_enabled("POPUP_COPY_MATERIAL", self._current_material_node)
	popup:connect("POPUP_COPY_MATERIAL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_copy_material"), "")
	popup:append_item("POPUP_PASTE_AS_MATERIAL", "Paste As", "")
	popup:set_enabled("POPUP_PASTE_AS_MATERIAL", self._material_clipboard)
	popup:connect("POPUP_PASTE_AS_MATERIAL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_paste_as_material"), "")
	popup:append_separator()
	popup:append_item("POPUP_RENAME_MATERIAL", "Rename", "")
	popup:set_enabled("POPUP_RENAME_MATERIAL", self._current_material_node)
	popup:connect("POPUP_RENAME_MATERIAL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_rename_material"), "")
	popup:append_separator()
	popup:append_item("POPUP_REMOVE_MATERIAL", "Remove", "")
	popup:set_enabled("POPUP_REMOVE_MATERIAL", self._current_material_node)
	popup:connect("POPUP_REMOVE_MATERIAL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_remove_material"), "")
	self._material_list_box:popup_menu(popup, Vector3(-1, -1, 0))
end

function CoreMaterialEditor:_on_parameter_popup()
	local popup = EWS:Menu("")

	popup:append_check_item("POPUP_CUSTOMIZE", "Customize", "")
	popup:set_checked("POPUP_CUSTOMIZE", self._customize)
	popup:set_enabled("POPUP_CUSTOMIZE", self._parent_node ~= nil)
	popup:connect("POPUP_CUSTOMIZE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_toggle_customize"), "")
	popup:append_separator()
	popup:append_item("POPUP_OPEN_TEXTURE", "Open Texture", "")

	local b = self.on_open_texture and self._value and self._value ~= "[NONE]" and os.getenv("MATEDOPEN")

	popup:set_enabled("POPUP_OPEN_TEXTURE", b)

	if b then
		popup:connect("POPUP_OPEN_TEXTURE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_open_texture"), "")
	end

	popup:append_item("POPUP_GLOBAL_TEXTURE", "Browse Global Textures", "")

	b = self._parameter_info and self._parameter_info.type == "texture"

	popup:set_enabled("POPUP_GLOBAL_TEXTURE", b)

	if b then
		popup:connect("POPUP_GLOBAL_TEXTURE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_pick_global_texture"), "")
	end

	popup:append_separator()
	popup:append_item("POPUP_COPY_TO_PARENT", "Copy to Parent", "")
	popup:set_enabled("POPUP_COPY_TO_PARENT", self._customize)
	popup:connect("POPUP_COPY_TO_PARENT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_copy_to_parent"), "")
	self._parent_btn:popup_menu(popup, Vector3(-1, -1, 0))
end

function CoreMaterialEditor:_on_edit_global_popup(event)
	local popup = EWS:Menu("")

	popup:append_item("POPUP_GLOBAL_REMOVE", "Remove", "")
	popup:connect("POPUP_GLOBAL_REMOVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_remove"), event)
	self._tree_ctrl:popup_menu(popup, Vector3(-1, -1, 0))
end
