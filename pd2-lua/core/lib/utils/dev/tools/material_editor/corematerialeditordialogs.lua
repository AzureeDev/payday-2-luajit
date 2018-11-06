CoreMaterialEditorGlobalDialog = CoreMaterialEditorGlobalDialog or class()

function CoreMaterialEditorGlobalDialog:init(parent, editor)
	self._editor = editor
	self._dialog = EWS:Dialog(parent, "Global Configuration", "", Vector3(-1, -1, 0), Vector3(400, 500, 0), "CAPTION,SYSTEM_MENU,CLOSE_BOX,STAY_ON_TOP")
	local main_frame_box = EWS:BoxSizer("VERTICAL")
	local main_panel = EWS:Panel(self._dialog, "", "")
	local panel_box = EWS:BoxSizer("VERTICAL")
	self._tree_ctrl = EWS:TreeCtrl(main_panel, "", "TR_HAS_BUTTONS,TR_LINES_AT_ROOT,TR_HIDE_ROOT,TR_DEFAULT_STYLE")

	self._tree_ctrl:connect("", "EVT_COMMAND_TREE_ITEM_RIGHT_CLICK", self._editor._on_edit_global_popup, self)
	panel_box:add(self._tree_ctrl, 1, 0, "EXPAND")

	local btn_box = EWS:BoxSizer("HORIZONTAL")
	self._ok_btn = EWS:Button(main_panel, "OK", "", "")

	self._ok_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "destroy"), true)
	btn_box:add(self._ok_btn, 0, 8, "ALL,EXPAND")

	local dead_panel = EWS:Panel(main_panel, "", "")

	btn_box:add(dead_panel, 1, 0, "EXPAND")

	self._cancel_btn = EWS:Button(main_panel, "Cancel", "", "")

	self._cancel_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "destroy"), false)
	btn_box:add(self._cancel_btn, 0, 8, "ALL,EXPAND")
	panel_box:add(btn_box, 0, 0, "EXPAND")
	main_panel:set_sizer(panel_box)
	main_frame_box:add(main_panel, 1, 0, "EXPAND")
	self._dialog:set_sizer(main_frame_box)
	self._dialog:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "destroy"), false)

	self._destroy_map = {}
	self._item_map = {}

	for child in self._editor._global_material_config_node:children() do
		self:_fill_tree(self._tree_ctrl:append_root(""), self._editor._global_material_config_node, child, self._item_map)
	end

	self._dialog:show_modal()
end

function CoreMaterialEditorGlobalDialog:destroy(clean)
	if clean then
		for _, n in ipairs(self._destroy_map) do
			n._parent:remove_child_at(n._parent:index_of_child(n._node))
		end
	end

	self._editor:_save_global_to_disk(true)
	self._dialog:end_modal("")
end

function CoreMaterialEditorGlobalDialog:on_remove(custom_data)
	local item = custom_data:get_item()

	self._tree_ctrl:remove(item)
	table.insert(self._destroy_map, self._item_map[tostring(item)])
end

function CoreMaterialEditorGlobalDialog:_on_ok()
end

function CoreMaterialEditorGlobalDialog:_on_cancel()
end

function CoreMaterialEditorGlobalDialog:_fill_tree(id, parent, node)
	local text = node:name()

	for k, v in pairs(node:parameters()) do
		if k == "name" then
			text = text .. " | " .. k .. "=" .. v

			break
		end
	end

	for k, v in pairs(node:parameters()) do
		if k ~= "name" then
			text = text .. " | " .. k .. "=" .. v
		end
	end

	local new_id = self._tree_ctrl:append(id, text)
	self._item_map[tostring(new_id)] = {
		_node = node,
		_parent = parent
	}

	for child in node:children() do
		self:_fill_tree(new_id, node, child)
	end

	return new_id
end

CoreMaterialEditorStartDialog = CoreMaterialEditorStartDialog or class()

function CoreMaterialEditorStartDialog:init(parent, editor)
	self._editor = editor
	self._parent = parent
	self._frame_size = Vector3(150, 200, 0)
	self._frame = EWS:Frame("Getting Started", Vector3(0, 0, 0), self._frame_size, "FRAME_FLOAT_ON_PARENT,FRAME_TOOL_WINDOW,CAPTION", parent)
	local main_frame_box = EWS:BoxSizer("VERTICAL")
	local main_panel = EWS:Panel(self._frame, "", "")
	local panel_box = EWS:BoxSizer("VERTICAL")
	self._new_btn = EWS:Button(main_panel, "New", "", "")

	self._new_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_new"), false)
	panel_box:add(self._new_btn, 1, 4, "ALL,EXPAND")

	self._open_btn = EWS:Button(main_panel, "Open", "", "")

	self._open_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_open"), false)
	panel_box:add(self._open_btn, 1, 4, "ALL,EXPAND")

	self._exit_btn = EWS:Button(main_panel, "Exit", "", "")

	self._exit_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_exit"), false)
	panel_box:add(self._exit_btn, 1, 4, "ALL,EXPAND")
	main_panel:set_sizer(panel_box)
	main_frame_box:add(main_panel, 1, 0, "EXPAND")
	self._frame:set_sizer(main_frame_box)
end

function CoreMaterialEditorStartDialog:on_new()
	local path = managers.database:save_file_dialog(self._parent, true, "Material Configurations (*.material_config)|*.material_config")

	if path then
		if managers.database:has(path) and EWS:MessageDialog(self._parent, "A material config with that name already exists. Do you want to replace it?", "Duplicated!", "YES_NO,ICON_ERROR"):show_modal() == "ID_NO" then
			return
		end

		self._editor:_create_new_material_config(path)
		self._editor:_update_interface_after_material_list_change()
		self._editor:_reset_diff()
		self:end_modal()
	end
end

function CoreMaterialEditorStartDialog:on_open()
	local node, path = managers.database:load_node_dialog(self._parent, "*.material_config")

	if node and path and self._editor:_load_node(path, node) then
		self:end_modal()
	end
end

function CoreMaterialEditorStartDialog:on_exit()
	self._frame:destroy()

	self._frame = nil

	managers.toolhub:close(self._editor.TOOLHUB_NAME)
end

function CoreMaterialEditorStartDialog:running()
	return self._running and alive(self._frame)
end

function CoreMaterialEditorStartDialog:show_modal()
	self._running = true

	self._parent:set_enabled(false)
	self._frame:set_visible(true)
end

function CoreMaterialEditorStartDialog:update(t, dt)
	self._frame_pos = self._parent:get_position() + self._parent:get_size() * 0.5 - self._frame_size * 0.5

	self._frame:set_position(self._frame_pos)
end

function CoreMaterialEditorStartDialog:end_modal()
	self._running = false

	self._frame:set_visible(false)
	self._parent:set_enabled(true)
	self._parent:set_focus()
end

CoreMaterialEditorCompileWarningDialog = CoreMaterialEditorCompileWarningDialog or class()

function CoreMaterialEditorCompileWarningDialog:init(parent)
	self._parent = parent
	local frame_size = Vector3(540, 340, 0)
	local frame_pos = self._parent:get_position() + self._parent:get_size() * 0.5 - frame_size * 0.5
	self._dialog = EWS:Dialog(parent, "Warning!", "", frame_pos, frame_size, "")
	local main_frame_box = EWS:BoxSizer("VERTICAL")
	local main_panel = EWS:Panel(self._dialog, "", "")
	local panel_box = EWS:BoxSizer("VERTICAL")
	self._inmage_btn = EWS:BitmapButton(main_panel, CoreEWS.image_path("material_editor/compile_warning.png"), "", "NO_BORDER")

	panel_box:add(self._inmage_btn, 1, 0, "EXPAND")

	local btn_box = EWS:BoxSizer("HORIZONTAL")
	self._ok_btn = EWS:Button(main_panel, "OK", "", "")

	self._ok_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "end_modal"), "OK")
	btn_box:add(self._ok_btn, 1, 4, "ALL,EXPAND")

	self._cancel_btn = EWS:Button(main_panel, "Cancel", "", "")

	self._cancel_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "end_modal"), "CANCEL")
	btn_box:add(self._cancel_btn, 1, 4, "ALL,EXPAND")
	panel_box:add(btn_box, 0, 0, "EXPAND")
	main_panel:set_sizer(panel_box)
	main_frame_box:add(main_panel, 1, 0, "EXPAND")
	self._dialog:set_sizer(main_frame_box)
end

function CoreMaterialEditorCompileWarningDialog:show_modal()
	return self._dialog:show_modal()
end

function CoreMaterialEditorCompileWarningDialog:end_modal(data)
	self._dialog:end_modal(data)
end
