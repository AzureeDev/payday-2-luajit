core:import("CoreEngineAccess")

CoreParticleEditorPanel = CoreParticleEditorPanel or class()

function CoreParticleEditorPanel:init(editor, parent, effect)
	self._editor = editor
	self._effect = effect
	local n = Node("effect")

	self._effect:save(n)

	self._box_status = ""
	self._box_help = ""
	self._box_help_header = ""
	self._undo_stack = CoreUndoStack:new({
		name = effect:name(),
		xml = n:to_xml()
	}, 20)
	local n = Node("effect")

	self._effect:save(n)

	self._last_saved_xml = n:to_xml()
	self._frames_since_spawn = 0

	self:create_panel(parent)
end

function CoreParticleEditorPanel:panel()
	return self._panel
end

function CoreParticleEditorPanel:set_box_help(h, t)
	self._box_help_header = h
	self._box_help = t

	self:update_status_box()
end

function CoreParticleEditorPanel:create_panel(parent)
	self._stacklist_boxes = {}
	self._stack_member_combos = {}
	self._stack_panels = {}
	self._panel = EWS:Panel(parent, "", "")

	self._panel:set_visible(false)

	local splitter = EWS:SplitterWindow(self._panel, "", "SP_NOBORDER")
	self._top_splitter = splitter
	local gv_splitter = EWS:SplitterWindow(splitter, "", "SP_NOBORDER")
	self._gv_splitter = gv_splitter
	local effect_panel = self:create_effect_panel(gv_splitter)
	self._status_box = self:create_status_box(gv_splitter)
	local atom_panel = self:create_atom_panel(splitter)
	local top_sizer = EWS:BoxSizer("VERTICAL")

	self._panel:set_sizer(top_sizer)
	top_sizer:add(splitter, 1, 0, "EXPAND")
	splitter:set_sash_gravity(0)
	splitter:split_vertically(gv_splitter, atom_panel, 100)
	gv_splitter:set_sash_gravity(0)
	gv_splitter:split_horizontally(effect_panel, self._status_box, 100)
	self:update_atom_combo()

	if #self._effect._atoms > 0 then
		self._atom_combo:set_value(self._effect._atoms[1]:name())
		self:on_select_atom()
	else
		self._atom = nil
	end

	self._stack_notebook:connect("EVT_COMMAND_NOTEBOOK_PAGE_CHANGED", callback(self, self, "clear_box_help"), "")
	self:update_view(true)
	self._panel:set_visible(true)
end

function CoreParticleEditorPanel:set_init_positions()
	self._top_splitter:set_sash_position(250, true)
	self._gv_splitter:set_sash_position(150, true)
	self._gv_splitter:update_size()
	self._top_splitter:update_size()
	self._panel:refresh()
end

function CoreParticleEditorPanel:on_timeline_modify(arg, event)
	if event:scale() then
		self._atom:scale_timeline(event:istart(), event:iend(), event:tstart(), event:tend())
	else
		self._atom:extend_timeline(event:istart(), event:iend(), event:tstart(), event:tend())
	end

	self:update_view(false)
end

function CoreParticleEditorPanel:fill_timelines()
	self._timeline_edit:clear_timelines()
	self._timeline_edit:add_timeline("atom")

	local events = self._atom:collect_time_events()

	for _, e in ipairs(events) do
		local name = e[1]
		local t = tonumber(e[2][e[3]])

		self._timeline_edit:add_event("atom", t, name)
	end

	self._timeline_edit:refresh()
end

function CoreParticleEditorPanel:timeline_init(timeline)
	timeline:connect("EVT_TIMELINE_MODIFIED", callback(self, self, "on_timeline_modify"), "")

	self._timeline_edit = timeline

	self:fill_timelines()
end

function CoreParticleEditorPanel:on_rename_atom()
	if self._effect:find_atom(self._atom_textctrl:get_value()) or #self._effect._atoms == 0 then
		return
	end

	self._atom:set_name(self._atom_textctrl:get_value())
	self:update_atom_combo()
	self._atom_combo:set_value(self._atom_textctrl:get_value())
	self:on_select_atom()
end

function CoreParticleEditorPanel:on_add_atom()
	if self._effect:find_atom(self._atom_textctrl:get_value()) then
		return
	end

	self._effect:add_atom(CoreEffectAtom:new(self._atom_textctrl:get_value()))
	self:update_atom_combo()
	self._atom_combo:set_value(self._atom_textctrl:get_value())
	self:on_select_atom()
end

function CoreParticleEditorPanel:on_remove_atom()
	if not self._atom then
		return
	end

	self._effect:remove_atom(self._atom)
	self:update_atom_combo()

	if #self._effect._atoms > 0 then
		self._atom_combo:set_value(self._effect._atoms[1]:name())
		self:on_select_atom()
	end
end

function CoreParticleEditorPanel:on_copy_atom()
	local atom = self._effect:find_atom(self._atom_combo:get_value())

	if atom then
		self._editor._clipboard_type = "atom"
		self._editor._clipboard_object = deep_clone(atom)
	end
end

function CoreParticleEditorPanel:on_paste_atom()
	if self._editor._clipboard_type == "atom" and self._editor._clipboard_object then
		local e = self._effect:find_atom(self._editor._clipboard_object:name())
		local i = 0
		local n = self._editor._clipboard_object:name() .. ""

		while e do
			self._editor._clipboard_object:set_name(n .. i)

			i = i + 1
			e = self._effect:find_atom(self._editor._clipboard_object:name())
		end

		self._effect:add_atom(deep_clone(self._editor._clipboard_object))
		self:update_atom_combo()
		self._atom_combo:set_value(self._editor._clipboard_object:name())
		self:on_select_atom()
	end
end

function CoreParticleEditorPanel:on_set_selected_only()
	if self._valid_effect then
		self:update_effect_instance()
	end
end

function CoreParticleEditorPanel:create_effect_panel(parent)
	local panel = EWS:Panel(parent, "", "")
	self._atom_combo = EWS:ComboBox(panel, "", "", "CB_DROPDOWN,CB_READONLY")

	self._atom_combo:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "on_select_atom"))

	local remove_button = EWS:Button(panel, "Remove", "", "BU_EXACTFIT")

	remove_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_remove_atom"))

	local copy_button = EWS:Button(panel, "Copy", "", "BU_EXACTFIT")

	copy_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_copy_atom"))

	local paste_button = EWS:Button(panel, "Paste", "", "BU_EXACTFIT")

	paste_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_paste_atom"))

	self._atom_textctrl = EWS:TextCtrl(panel, "", "", "TE_PROCESS_ENTER")

	self._atom_textctrl:set_min_size(Vector3(100, 20, 0))
	self._atom_textctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_rename_atom"))

	local add_button = EWS:Button(panel, "Add", "", "BU_EXACTFIT")

	add_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_add_atom"))

	self._render_selected_only_check = EWS:CheckBox(panel, "Render Selected Atom Only", "", "")

	self._render_selected_only_check:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "on_set_selected_only"))

	local top_sizer = EWS:BoxSizer("VERTICAL")
	local atoms_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Atoms")
	local row_sizer = EWS:BoxSizer("HORIZONTAL")

	row_sizer:add(EWS:StaticText(panel, "Atom:", "", ""), 0, 0, "EXPAND")
	row_sizer:add(self._atom_combo, 0, 0, "EXPAND")
	row_sizer:add(remove_button, 0, 0, "EXPAND")
	row_sizer:add(copy_button, 0, 0, "EXPAND")
	row_sizer:add(paste_button, 0, 0, "EXPAND")
	atoms_sizer:add(row_sizer, 0, 0, "EXPAND")

	row_sizer = EWS:BoxSizer("HORIZONTAL")

	row_sizer:add(EWS:StaticText(panel, "Rename/add atom:", "", ""), 0, 0, "LEFT,ALIGN_CENTER_VERTICAL")
	row_sizer:add(self._atom_textctrl, 0, 2, "LEFT")
	row_sizer:add(add_button, 0, 2, "LEFT")
	atoms_sizer:add(row_sizer, 0, 0, "EXPAND")
	atoms_sizer:add(self._render_selected_only_check, 0, 0, "EXPAND")
	top_sizer:add(atoms_sizer, 0, 0, "EXPAND")

	self._effect_properties_panel = EWS:Panel(panel, "", "")

	self:create_graph_view(self._editor._main_frame)
	top_sizer:add(self._effect_properties_panel, 0, 0, "EXPAND")
	panel:set_sizer(top_sizer)

	return panel
end

function CoreParticleEditorPanel:show_stack_overview(b)
	self._graph_view_dialog:show(b)

	if b then
		self:update_graph_view()
	end
end

function CoreParticleEditorPanel:create_graph_view(parent)
	self._graph_view_dialog = EWS:Dialog(parent, "Stacks And Channels Overview", "", Vector3(-1, -1, 0), Vector3(500, 400, 0), "CAPTION,RESIZE_BORDER")
	self._graph = EWS:Graph()
	local gv = EWS:GraphView(self._graph_view_dialog, "", self._graph)

	gv:set_clipping(false)
	gv:toggle_style("SUNKEN_BORDER")

	self._graph_view = gv
	local top_sizer = EWS:BoxSizer("VERTICAL")

	top_sizer:add(gv, 1, 0, "EXPAND")
	self._graph_view_dialog:set_sizer(top_sizer)

	if self._editor._view_menu:is_checked("SHOW_STACK_OVERVIEW") then
		self:show_stack_overview(true)
	end
end

function CoreParticleEditorPanel:create_status_box(parent)
	return EWS:TextCtrl(parent, "", "", "TE_MULTILINE,TE_READONLY,TE_RICH2,TE_NOHIDESEL")
end

function CoreParticleEditorPanel:on_stack_up(stacktype)
	local box = self._stacklist_boxes[stacktype]
	local selected = box:selected_index()

	if selected < 0 then
		return
	end

	self._atom:stack(stacktype):move_up(selected + 1)
	self:update_view(true)
end

function CoreParticleEditorPanel:on_stack_down(stacktype)
	local box = self._stacklist_boxes[stacktype]
	local selected = box:selected_index()

	if selected < 0 then
		return
	end

	self._atom:stack(stacktype):move_down(selected + 1)
	self:update_view(true)
end

function CoreParticleEditorPanel:on_stack_remove(stacktype)
	local box = self._stacklist_boxes[stacktype]
	local selected = box:selected_index()

	if selected < 0 then
		return
	end

	self._atom:stack(stacktype):remove(selected + 1)
	self:update_view(true)
end

function CoreParticleEditorPanel:on_stack_add(stacktype)
	if not self._atom then
		return
	end

	local members = stack_members[stacktype]
	local member_names = stack_member_names[stacktype]
	local to_add_idx = self._stack_member_combos[stacktype]:get_selection()

	if to_add_idx < 0 then
		return
	end

	self._atom:stack(stacktype):add_member(members[member_names[to_add_idx + 1].key]())
	self:update_view(true)
	self._stacklist_boxes[stacktype]:select_index(self._stacklist_boxes[stacktype]:nr_items() - 1)
	self:on_select_stack_member(stacktype)
end

function CoreParticleEditorPanel:on_select_stack_member(stacktype)
	local stacklist = self._stacklist_boxes[stacktype]
	local selected = stacklist:selected_index()

	if selected >= 0 then
		self._atom:stack(stacktype):stack()[selected + 1]:fill_property_container_sheet(self._stack_panels[stacktype], self)
		self._stack_panels[stacktype]:fit_inside()
	end
end

function CoreParticleEditorPanel:update_effect_instance(quality)
	self._dirty_effect = true
	self._quality = quality
end

function CoreParticleEditorPanel:reload_effect_definition()
	local n = Node("effect")

	if self._render_selected_only_check:get_value() and self._atom then
		self._atom:save(n)
	else
		self._effect:save(n)
	end

	CoreEngineAccess._editor_reload_node(n, Idstring("effect"), Idstring("unique_test_effect_name"))

	self._effect_id = nil
end

function CoreParticleEditorPanel:update(t, dt)
	if self._valid_effect then
		if self._dirty_effect then
			self:reload_effect_definition()

			self._dirty_effect = false
		end

		if (not self._effect_id or not World:effect_manager():alive(self._effect_id)) and self._frames_since_spawn > 1 then
			local quality = self._quality
			quality = quality or 0.5
			self._quality = nil
			local gizmo = self._editor:effect_gizmo()
			self._effect_id = World:effect_manager():spawn({
				effect = Idstring("unique_test_effect_name"),
				parent = gizmo:get_object(Idstring("rp_root_point")),
				custom_quality = quality
			})
			self._frames_since_spawn = 0
		else
			self._frames_since_spawn = self._frames_since_spawn + 1
		end
	elseif self._effect_id then
		World:effect_manager():kill(self._effect_id)

		self._effect_id = nil
	end

	if self._editor._view_menu:is_checked("SHOW_STACK_OVERVIEW") then
		self._graph_view:update_graph(dt)
	end
end

function CoreParticleEditorPanel:update_graph_view()
	self._graph:clear()

	if not self._atom then
		return
	end

	local stacks = {
		"initializer",
		"simulator",
		"visualizer"
	}
	local row = 0
	local channel_height = 20
	local row_height = 70
	local channels = {}
	local affector_x = 0
	local channel_x_count = 110

	local function channel_x(channel)
		if not channels[channel] then
			channels[channel] = channel_x_count
			channel_x_count = channel_x_count + 80
		end

		return channels[channel]
	end

	for _, stacktype in ipairs(stacks) do
		for _, m in ipairs(self._atom:stack(stacktype):stack()) do
			if m._valid_properties then
				local affector_node = EWS:Node(m:name(), affector_x, row * row_height)

				self._graph:add_node(affector_node)

				local reads = {}
				local writes = {}
				reads, writes = m:reads_writes()

				for channel, read_type in pairs(reads) do
					local read_node = EWS:Node(channel, channel_x(channel), row * row_height - channel_height)

					self._graph:add_node(read_node)

					local slot = read_node:free_slot()

					read_node:set_target(slot, affector_node, "read " .. channel)
				end

				for channel, read_type in pairs(writes) do
					local write_node = EWS:Node(channel, channel_x(channel), row * row_height + channel_height)

					self._graph:add_node(write_node)

					local slot = affector_node:free_slot()

					affector_node:set_target(slot, write_node, "write " .. channel .. " " .. read_type)
				end
			else
				local affector_node = EWS:Node("INVALID: " .. m:name(), affector_x, row * row_height)

				self._graph:add_node(affector_node)
			end

			row = row + 1
		end
	end

	self._graph_view:refresh()
end

function CoreParticleEditorPanel:update_view(clear, undoredo)
	local n = Node("effect")

	self._effect:save(n)

	local new_xml = n:to_xml()

	if not undoredo then
		self._undo_stack:push({
			name = self._effect:name(),
			xml = new_xml
		})
	end

	local name = self._effect:name()

	if name == "" then
		name = "New Effect"
	end

	if new_xml ~= self._last_saved_xml then
		name = name .. "*"
	end

	self._editor:set_page_name(self, base_path(name))

	if clear then
		self._atom_panel:destroy_children()

		if self._atom then
			self._atom:fill_property_container_sheet(self._atom_panel, self)
		else
			self._atom_panel:set_sizer(EWS:BoxSizer("VERTICAL"))
		end
	elseif self._atom then
		self:fill_timelines()
	end

	if clear then
		self._effect_properties_panel:destroy_children()

		if self._effect then
			self._effect:fill_property_container_sheet(self._effect_properties_panel, self)
		else
			self._effect_properties_panel:set_sizer(EWS:BoxSizer("VERTICAL"))
		end
	end

	if clear then
		for stacktype, c in pairs(self._stacklist_boxes) do
			c:clear()

			if self._atom then
				for _, m in ipairs(self._atom:stack(stacktype):stack()) do
					c:append(m:ui_name())
				end
			end

			self._stack_panels[stacktype]:destroy_children()
			self._stack_panels[stacktype]:set_sizer(EWS:BoxSizer("VERTICAL"))
		end
	end

	for stacktype, panel in pairs(self._stack_panels) do
		panel:fit_inside()
	end

	local valid = self._effect:validate()
	self._valid_effect = valid.valid

	if not valid.valid then
		self._box_status = valid.message
	else
		self._box_status = "Effect is valid"
	end

	self:update_status_box()

	if self._editor._view_menu:is_checked("SHOW_STACK_OVERVIEW") then
		self:update_graph_view()
	end

	self:safety_backup()

	if valid.valid then
		self:update_effect_instance()
	end
end

function CoreParticleEditorPanel:update_status_box()
	self._status_box:set_value("")

	if not self._valid_effect then
		self._status_box:set_default_style_colour(Vector3(200, 0, 0))
	else
		self._status_box:set_default_style_colour(Vector3(0, 190, 0))
	end

	self._status_box:append(self._box_status .. "\n")
	self._status_box:append("\n")
	self._status_box:set_default_style_colour(Vector3(0, 0, 0))
	self._status_box:append(self._box_help_header .. "\n")
	self._status_box:set_default_style_colour(Vector3(110, 110, 110))
	self._status_box:append(self._box_help .. "\n")
end

function CoreParticleEditorPanel:safety_backup()
	local n = Node("effect")

	self._effect:save(n)
	managers.database:save_node(n, "last_played_effect.xml")
end

function CoreParticleEditorPanel:on_stack_copy(stacktype)
	local box = self._stacklist_boxes[stacktype]
	local selected = box:selected_index()

	if selected < 0 then
		return
	end

	self._editor._clipboard_type = stacktype
	self._editor._clipboard_object = deep_clone(self._atom:stack(stacktype):member(selected + 1))
end

function CoreParticleEditorPanel:on_stack_paste(stacktype)
	if self._editor._clipboard_type ~= stacktype or not self._editor._clipboard_object then
		return
	end

	local box = self._stacklist_boxes[stacktype]
	local selected = box:selected_index()

	if selected < 0 then
		selected = nil
	else
		selected = selected + 1
	end

	if not selected then
		self._atom:stack(stacktype):add_member(deep_clone(self._editor._clipboard_object))
	else
		self._atom:stack(stacktype):insert_member(deep_clone(self._editor._clipboard_object), selected)
	end

	self:update_view(true)
end

function CoreParticleEditorPanel:on_lose_focus()
	if self._effect_id and self._effect_id > 0 then
		World:effect_manager():kill(self._effect_id)
	end

	self:show_stack_overview(false)
end

function CoreParticleEditorPanel:on_key_stack_member(stacktype, event)
	if event:control_down() then
		if event:key_code() == 67 then
			self:on_stack_copy(stacktype)
		elseif event:key_code() == 86 then
			self:on_stack_paste(stacktype)
		end
	end
end

function CoreParticleEditorPanel:create_stack_panel(parent, stacktype)
	local panel = EWS:Panel(parent, "", "")
	local stacklist = EWS:ListBox(panel, "", "LB_SINGLE,LB_HSCROLL")

	set_widget_help(stacklist, "Copy and paste using Ctrl-C/Ctrl-V")
	stacklist:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "on_select_stack_member"), stacktype)
	stacklist:connect("EVT_KEY_DOWN", callback(self, self, "on_key_stack_member"), stacktype)

	self._stacklist_boxes[stacktype] = stacklist
	local stack_member_combo = EWS:ComboBox(panel, "", "", "CB_DROPDOWN,CB_READONLY")
	local member_names = stack_member_names[stacktype]
	local last = nil

	for _, mn in ipairs(member_names) do
		stack_member_combo:append(mn.ui_name)

		last = mn.ui_name
	end

	stack_member_combo:set_value(last)

	self._stack_member_combos[stacktype] = stack_member_combo
	local up_button = EWS:Button(panel, "Up", "", "")
	local down_button = EWS:Button(panel, "Down", "", "")
	local remove_button = EWS:Button(panel, "Remove", "", "")
	local add_button = EWS:Button(panel, "Add", "", "")
	local copy_button = EWS:Button(panel, "Copy", "", "")
	local paste_button = EWS:Button(panel, "Paste", "", "")

	up_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_stack_up", stacktype))
	down_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_stack_down", stacktype))
	remove_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_stack_remove", stacktype))
	add_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_stack_add", stacktype))
	copy_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_stack_copy", stacktype))
	paste_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_stack_paste", stacktype))

	local affector_panel = EWS:ScrolledWindow(panel, "", "HSCROLL,VSCROLL")

	affector_panel:set_scrollbars(Vector3(8, 8, 1), Vector3(1, 1, 1), Vector3(0, 0, 0), false)

	self._stack_panels[stacktype] = affector_panel
	local top_sizer = EWS:BoxSizer("VERTICAL")
	local top_stacklist_sizer = EWS:BoxSizer("VERTICAL")
	local add_member_sizer = EWS:BoxSizer("HORIZONTAL")
	local stacklist_sizer = EWS:BoxSizer("HORIZONTAL")
	local button_sizer = EWS:BoxSizer("VERTICAL")

	button_sizer:add(up_button, 0, 2, "ALL")
	button_sizer:add(down_button, 0, 2, "ALL")
	button_sizer:add(remove_button, 0, 2, "ALL")
	button_sizer:add(copy_button, 0, 2, "ALL")
	button_sizer:add(paste_button, 0, 2, "ALL")
	stacklist_sizer:add(stacklist, 1, 0, "EXPAND")
	stacklist_sizer:add(button_sizer, 0, 0, "EXPAND")
	add_member_sizer:add(add_button, 0, 2, "ALL")
	add_member_sizer:add(stack_member_combo, 1, 0, "EXPAND")
	top_stacklist_sizer:add(stacklist_sizer, 0, 0, "EXPAND")
	top_stacklist_sizer:add(add_member_sizer, 0, 0, "EXPAND")
	top_sizer:add(top_stacklist_sizer, 0, 0, "EXPAND")
	top_sizer:add(affector_panel, 1, 0, "EXPAND")
	panel:set_sizer(top_sizer)

	return panel
end

function CoreParticleEditorPanel:clear_box_help(arg, e)
	self:set_box_help("", "")
	e:skip()
end

function CoreParticleEditorPanel:create_atom_panel(parent)
	local panel = EWS:Panel(parent, "", "")
	local notebook = EWS:Notebook(panel, "", "")
	self._atom_panel = EWS:ScrolledWindow(notebook, "", "HSCROLL,VSCROLL")

	self._atom_panel:set_scrollbars(Vector3(8, 8, 1), Vector3(1, 1, 1), Vector3(0, 0, 0), false)

	local initializer_page = self:create_stack_panel(notebook, "initializer")
	local simulator_page = self:create_stack_panel(notebook, "simulator")
	local visualizer_page = self:create_stack_panel(notebook, "visualizer")

	notebook:add_page(self._atom_panel, "Atom", false)
	notebook:add_page(initializer_page, "Initializer Stack", false)
	notebook:add_page(simulator_page, "Simulator Stack", false)
	notebook:add_page(visualizer_page, "Visualizer Stack", false)
	notebook:set_page(0)

	self._stack_notebook = notebook
	local top_sizer = EWS:BoxSizer("HORIZONTAL")

	top_sizer:add(notebook, 1, 0, "EXPAND")
	panel:set_sizer(top_sizer)

	return panel
end

function CoreParticleEditorPanel:undo()
	self:undoredo("undo")
end

function CoreParticleEditorPanel:redo()
	self:undoredo("redo")
end

function CoreParticleEditorPanel:undoredo(f)
	local undo_state = self._undo_stack[f](self._undo_stack)

	if undo_state then
		local n = Node.from_xml(undo_state.xml)
		self._effect = CoreEffectDefinition:new()

		self._effect:load(n)
		self._effect:set_name(undo_state.name)

		if self._atom then
			local aname = self._atom:name()
			self._atom = nil

			self:update_atom_combo()
			self._atom_combo:set_value(aname)
			self:on_select_atom()
		end

		self:update_view(true, true)
	end
end

function CoreParticleEditorPanel:clear()
	self._effect = CoreEffectDefinition:new()

	self._atom_textctrl:set_value("")
end

function CoreParticleEditorPanel:update_atom_combo()
	self._atom_combo:clear()

	for _, atom in ipairs(self._effect._atoms) do
		self._atom_combo:append(atom._name)
	end
end

function CoreParticleEditorPanel:on_select_atom()
	local atom = self._effect:find_atom(self._atom_combo:get_value())
	self._atom = atom

	if atom then
		self._atom_textctrl:set_value(atom:name())
	end

	self:update_view(true, true)
end

function CoreParticleEditorPanel:on_save()
	if self._effect:name() == "" then
		return self:on_save_as()
	else
		return self:do_save(false)
	end
end

function CoreParticleEditorPanel:on_save_as()
	local f = managers.database:save_file_dialog(self._panel, nil, "*.effect", self._editor._last_used_dir, false)

	if not f then
		return false
	end

	self._effect:set_name(f)

	self._editor._last_used_dir = dir_name(f)
	local node = Node("effect")

	self._effect:save(node)

	local new_xml = node:to_xml()

	self._undo_stack:push({
		name = self._effect:name(),
		xml = new_xml
	})

	return self:do_save(true)
end

function CoreParticleEditorPanel:do_save(warn_on_overwrite)
	if warn_on_overwrite and managers.database:has(self._effect:name()) then
		local ret = EWS:message_box(self._panel, "An effect named " .. self._effect:name() .. " already exists, overwrite?", "Overwrite", "YES_NO", Vector3(-1, -1, 0))

		if ret ~= "YES" then
			return false
		end
	end

	local n = Node("effect")

	self._effect:save(n)
	managers.database:save_node(n, self._effect:name())

	self._last_saved_xml = n:to_xml()

	if self._valid_effect then
		Application:data_compile({
			target_db_name = "all",
			send_idstrings = false,
			preprocessor_definitions = "preprocessor_definitions",
			verbose = false,
			platform = string.lower(SystemInfo:platform():s()),
			source_root = managers.database:base_path(),
			target_db_root = Application:base_path() .. "/assets",
			source_files = {
				managers.database:entry_relative_path(self._effect:name())
			}
		})
		DB:reload()
		managers.database:clear_all_cached_indices()
	end

	self._editor:set_page_name(self, base_path(self._effect:name()))

	return true
end

function CoreParticleEditorPanel:close()
	local n = Node("effect")

	self:on_lose_focus()
	self._effect:save(n)

	if n:to_xml() ~= self._last_saved_xml then
		local continue_asking = true

		while continue_asking do
			local n = self._effect:name()

			if n == "" then
				n = "New Effect"
			end

			local ret = EWS:message_box(self._panel, "Effect " .. n .. " was modified since last saved, save before exiting?", "Save?", "YES,NO,CANCEL", Vector3(-1, -1, 0))

			if ret == "YES" then
				if self:on_save() then
					continue_asking = false
				end
			elseif ret == "NO" then
				continue_asking = false
			elseif ret == "CANCEL" then
				return false
			end
		end
	end

	self._graph_view_dialog:destroy()

	return true
end

CoreUndoStack = CoreUndoStack or class()

function CoreUndoStack:init(startstate, stacksize)
	self._stacksize = stacksize
	self._stack = {
		startstate
	}
	self._ptr = 1
end

function CoreUndoStack:push(state)
	if self._stack[self._ptr] == state then
		return
	end

	while self._ptr < #self._stack do
		table.remove(self._stack, self._ptr)
	end

	table.insert(self._stack, state)

	if self._stacksize < #self._stack then
		table.remove(self._stack, 1)
	end

	self._ptr = #self._stack
end

function CoreUndoStack:undo()
	if self._ptr == 1 then
		return nil
	end

	self._ptr = self._ptr - 1

	return self._stack[self._ptr]
end

function CoreUndoStack:redo()
	if self._ptr == #self._stack then
		return nil
	end

	self._ptr = self._ptr + 1

	return self._stack[self._ptr]
end
