core:module("CoreInteractionEditorUI")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreInteractionEditorConfig")
core:import("CoreInteractionEditorPropUI")

InteractionEditorUI = InteractionEditorUI or CoreClass.class()

function InteractionEditorUI:init(owner)
	self._main_frame = EWS:Frame(CoreInteractionEditorConfig.EDITOR_TITLE, Vector3(-1, -1, -1), Vector3(1000, 800, 0), "", Global.frame)
	local menu_bar = EWS:MenuBar()
	self._file_menu = EWS:Menu("")

	self._file_menu:append_item("NEW", "New\tCtrl-N", "")
	self._file_menu:append_item("OPEN", "Open\tCtrl-O", "")
	self._file_menu:append_separator()
	self._file_menu:append_item("SAVE", "Save\tCtrl-S", "")
	self._file_menu:set_enabled("SAVE", false)
	self._file_menu:append_item("SAVE_AS", "Save As", "")
	self._file_menu:set_enabled("SAVE_AS", false)
	self._file_menu:append_item("SAVE_ALL", "Save All", "")
	self._file_menu:set_enabled("SAVE_ALL", false)
	self._file_menu:append_separator()
	self._file_menu:append_item("CLOSE", "Close\tCtrl-W", "")
	self._file_menu:set_enabled("CLOSE", false)
	self._file_menu:append_separator()
	self._file_menu:append_item("EXIT", "Exit", "")
	menu_bar:append(self._file_menu, "File")

	local edit_menu = EWS:Menu("")

	edit_menu:append_item("UNDO", "Undo\tCtrl-Z", "")
	self._file_menu:set_enabled("UNDO", false)
	edit_menu:append_item("REDO", "Redo\tCtrl-Y", "")
	self._file_menu:set_enabled("REDO", false)
	menu_bar:append(edit_menu, "Edit")
	self._main_frame:set_menu_bar(menu_bar)

	self._tool_bar = EWS:ToolBar(self._main_frame, "", "TB_FLAT,TB_NOALIGN")

	self._tool_bar:add_tool("NEW", "New", CoreInteractionEditorConfig.NEW_ICON, "")
	self._tool_bar:add_tool("OPEN", "Open", CoreInteractionEditorConfig.OPEN_ICON, "")
	self._tool_bar:add_separator()
	self._tool_bar:add_tool("SAVE", "Save", CoreInteractionEditorConfig.SAVE_ICON, "")
	self._tool_bar:set_tool_enabled("SAVE", false)
	self._tool_bar:add_tool("SAVE_ALL", "Save All", CoreInteractionEditorConfig.SAVE_ALL_ICON, "")
	self._tool_bar:set_tool_enabled("SAVE_ALL", false)
	self._tool_bar:add_separator()
	self._tool_bar:add_tool("CLOSE", "Close", CoreInteractionEditorConfig.CLOSE_ICON, "")
	self._tool_bar:set_tool_enabled("CLOSE", false)
	self._main_frame:set_tool_bar(self._tool_bar)
	self._tool_bar:realize()

	self._status_bar = EWS:StatusBar(self._main_frame, "", "")

	self._main_frame:set_status_bar(self._status_bar)

	local main_box = EWS:BoxSizer("HORIZONTAL")
	self._main_splitter = EWS:SplitterWindow(self._main_frame, "", "")
	self._main_notebook = EWS:Notebook(self._main_splitter, "", "")
	self._prop_panel = CoreInteractionEditorPropUI.InteractionEditorPropUI:new(self._main_splitter, owner)

	self._main_splitter:split_vertically(self._main_notebook, self._prop_panel:window(), -1)
	main_box:add(self._main_splitter, 1, 0, "EXPAND")
	self._main_frame:set_sizer(main_box)
	self._main_splitter:set_minimum_pane_size(200)
	self._main_splitter:set_sash_gravity(1)
	self._main_splitter:update_size()
	self._main_frame:set_visible(true)

	self._owner = owner

	self:connect_events()
end

function InteractionEditorUI:frame()
	return self._main_frame
end

function InteractionEditorUI:set_position(pos)
	self._main_frame:set_position(pos)
end

function InteractionEditorUI:set_title(text)
	self._main_frame:set_title(text and CoreInteractionEditorConfig.EDITOR_TITLE .. " - " .. text or CoreInteractionEditorConfig.EDITOR_TITLE)
end

function InteractionEditorUI:connect_events()
	self._main_frame:connect("NEW", "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_new"), nil)
	self._main_frame:connect("OPEN", "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_open"), nil)
	self._main_frame:connect("SAVE", "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_save"), nil)
	self._main_frame:connect("SAVE_AS", "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_save_as"), nil)
	self._main_frame:connect("SAVE_ALL", "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_save_all"), nil)
	self._main_frame:connect("CLOSE", "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_close_system"), nil)
	self._main_frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_close"), nil)
	self._main_frame:connect("UNDO", "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_undo"), nil)
	self._main_frame:connect("REDO", "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_redo"), nil)
	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self._owner, self._owner, "on_close"), nil)
	self._main_frame:connect("", "EVT_COMMAND_NOTEBOOK_PAGE_CHANGED", callback(self._owner, self._owner, "on_notebook_changing"), nil)
end

function InteractionEditorUI:create_graph_context_menu(system)
	system:graph():connect("", "EVT_RIGHT_UP", callback(self._owner, self._owner, "on_show_graph_context_menu"), system)

	local add_menu = EWS:Menu("")

	for _, v in ipairs(InteractionDescription:node_types()) do
		add_menu:append_item("ADD_NODE_" .. string.upper(v), string.upper(v), "")
		system:graph():window():connect("ADD_NODE_" .. string.upper(v), "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_add_node"), function ()
			system:add_node(v)
		end)
	end

	local menu = EWS:Menu("")

	menu:append_menu("ADD_NODE", "Add Node", add_menu, "")
	menu:append_separator()
	menu:append_item("DELETE_NODE", "Delete Node", "")
	system:graph():window():connect("DELETE_NODE", "EVT_COMMAND_MENU_SELECTED", callback(self._owner, self._owner, "on_remove_node"), function ()
		for _, n in ipairs(system:selected_nodes()) do
			system:remove_node(n)
		end
	end)

	return menu
end

function InteractionEditorUI:show_graph_context_menu(system)
	system:context_menu():set_enabled("DELETE_NODE", false)
	system:graph():window():popup_menu(system:context_menu(), Vector3(-1, -1, 0))
end

function InteractionEditorUI:destroy()
	if CoreCode.alive(self._main_frame) then
		self._main_frame:destroy()

		self._main_frame = nil
	end
end

function InteractionEditorUI:clean_prop_panel()
	self._prop_panel:clean()
end

function InteractionEditorUI:rebuild_prop_panel(desc, node)
	self._prop_panel:rebuild(desc, node)
end

function InteractionEditorUI:create_nb_page(caption, select)
	local panel = EWS:Panel(self._main_notebook, "", "")

	return panel, self._main_notebook:add_page(panel, caption, select)
end

function InteractionEditorUI:destroy_nb_page(id)
	self._main_notebook:freeze()

	local newid = math.clamp(self:set_nb_page(0), 0, math.clamp(self:get_nb_page_count() - 2, 0, math.huge))

	self._main_notebook:delete_page(id)
	self:set_nb_page(newid)
	self._main_notebook:thaw()
	self._main_notebook:refresh()
end

function InteractionEditorUI:current_nb_page()
	return self._main_notebook:get_current_page()
end

function InteractionEditorUI:get_nb_page_count()
	return self._main_notebook:get_page_count()
end

function InteractionEditorUI:set_nb_page(id)
	return self._main_notebook:set_page(id)
end

function InteractionEditorUI:get_nb_page(id)
	return self._main_notebook:get_page(id)
end

function InteractionEditorUI:update_nb_page_caption(id, text)
	self._main_notebook:set_page_text(id, text)
end

function InteractionEditorUI:get_nb_page_by_caption(text)
	for i = 0, self._main_notebook:get_page_count() - 1 do
		if self._main_notebook:get_page_text(i) == text then
			return i
		end
	end
end

function InteractionEditorUI:get_nb_page_id(panel)
	for i = 0, self._main_notebook:get_page_count() - 1 do
		if self._main_notebook:get_page(i) == panel then
			return i
		end
	end
end

function InteractionEditorUI:set_save_close_option_enabled(b)
	self._file_menu:set_enabled("SAVE", b)
	self._tool_bar:set_tool_enabled("SAVE", b)
	self._file_menu:set_enabled("SAVE_AS", b)
	self._file_menu:set_enabled("SAVE_ALL", b)
	self._tool_bar:set_tool_enabled("SAVE_ALL", b)
	self._file_menu:set_enabled("CLOSE", b)
	self._tool_bar:set_tool_enabled("CLOSE", b)
end

function InteractionEditorUI:want_to_save(path)
	return EWS:message_box(self._main_frame, path .. " has changed.\nDo you want to save it?", "Save Changes", "ICON_WARNING,YES_DEFAULT,YES_NO,CANCEL", Vector3(-1, -1, -1))
end
