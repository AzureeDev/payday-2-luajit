core:module("CoreInteractionEditorSystem")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreScriptGraph")
core:import("CoreInteractionEditorConfig")
core:import("CoreInteractionEditorSystemEvents")

new_counter = new_counter or 1
node_id = node_id or 1
InteractionEditorSystem = InteractionEditorSystem or CoreClass.class(CoreInteractionEditorSystemEvents.InteractionEditorSystemEvents)

function InteractionEditorSystem:init(ui, path)
	self._ui = ui
	self._path = path
	self._node_id_map = {}
	self._pattern_data = {}
	self._is_new = path == nil
	self._caption = path and managers.database:entry_name(path) or "New" .. tostring(new_counter)
	self._op_stack = CoreInteractionEditorSystemEvents.InteractionEditorSystemEvents.setup_stack(self)
	self._panel, self._id = ui:create_nb_page(self._caption, true)
	local main_box = EWS:BoxSizer("VERTICAL")
	self._graph = CoreScriptGraph.ScriptGraph:new(self._panel, "", "FLOW")

	self._graph:connect("", "EVT_NODE_DELETE", callback(self, self, "on_delete_node"), nil)
	self._graph:connect("", "EVT_NODE_SELECTED", callback(self, self, "on_select_node"), nil)
	self._graph:connect("", "EVT_NODE_CONNECT", callback(self, self, "on_connect_node"), nil)
	self._graph:connect("", "EVT_NODE_DISCONNECT", callback(self, self, "on_disconnect_node"), nil)

	self._context_menu = ui:create_graph_context_menu(self)

	main_box:add(self._graph:window(), 1, 0, "EXPAND")

	self._desc = InteractionDescription()

	self._panel:set_sizer(main_box)

	new_counter = new_counter + 1

	self:activate()

	self._node_id_map = path and self._graph:load(assert(managers.database:load_node(path))) or {}
	local md = self._graph:graph_metadata()

	if md then
		for child in md:children() do
			if child:name() == "interaction" then
				self._desc:from_xml(child)

				break
			end
		end

		for child in md:children() do
			if child:name() == "patterns" then
				self:_load_patterns(self._desc, self._pattern_data, child)

				break
			end
		end
	end
end

function InteractionEditorSystem:caption()
	return self._caption
end

function InteractionEditorSystem:desc()
	return self._desc
end

function InteractionEditorSystem:ui()
	return self._ui
end

function InteractionEditorSystem:is_new()
	return self._is_new
end

function InteractionEditorSystem:path()
	return self._path
end

function InteractionEditorSystem:update(t, dt)
	if self._active and self._graph then
		self._graph:update(t, dt)
	end
end

function InteractionEditorSystem:graph()
	return self._graph
end

function InteractionEditorSystem:graph_node(id)
	return self._node_id_map[id]
end

function InteractionEditorSystem:selected_nodes()
	return self._graph:selected_nodes()
end

function InteractionEditorSystem:add_pattern_data(node, pat, ptype, name, full_name)
	local nd = self._pattern_data[node] or {}
	local key = full_name .. " - " .. ptype

	assert(not nd[key])

	nd[key] = {
		node,
		pat,
		ptype,
		name,
		full_name
	}
	self._pattern_data[node] = nd
end

function InteractionEditorSystem:pattern_data(node, full_name_and_type)
	return unpack(assert(self._pattern_data[node])[full_name_and_type])
end

function InteractionEditorSystem:remove_pattern_data(node, full_name_and_type)
	assert(self._pattern_data[node])[full_name_and_type] = nil
end

function InteractionEditorSystem:add_node(node_type, skip_stack)
	local id = node_type .. tostring(node_id)

	assert(self._desc:node_add(id, node_type))

	local node = EWS:FlowNode(node_type, self._desc:node_inputs(id), self._desc:node_outputs(id), 0, 0)

	node:set_metadata(id)
	self._graph:add_node(node)

	self._node_id_map[id] = node
	node_id = node_id + 1

	self:set_node_colors(node, id)

	if not skip_stack then
		-- Nothing
	end
end

function InteractionEditorSystem:remove_node(node, skip_stack)
	local id = node:metadata()

	assert(self._desc:node_remove(id))

	self._node_id_map[id] = nil

	if not skip_stack then
		-- Nothing
	end
end

function InteractionEditorSystem:panel()
	return self._panel
end

function InteractionEditorSystem:context_menu()
	return self._context_menu
end

function InteractionEditorSystem:close()
	self:deactivate()
	self._panel:destroy_children()
	self._ui:destroy_nb_page(self._ui:get_nb_page_by_caption(self._caption))

	self._graph = nil
end

function InteractionEditorSystem:active()
	return self._active
end

function InteractionEditorSystem:activate()
	self._ui:set_title(not self._is_new and self._path)
	self._ui:set_save_close_option_enabled(true)

	local selected = self._graph:selected_nodes()

	if #selected == 1 then
		self._ui:rebuild_prop_panel(self._desc, selected[1]:metadata())
	end

	self._active = true
end

function InteractionEditorSystem:deactivate()
	self._ui:set_title()
	self._ui:set_save_close_option_enabled(false)
	self._ui:clean_prop_panel()

	self._active = false
end

function InteractionEditorSystem:save(path)
	local md_node = Node("graph_metadata")

	md_node:add_child(self._desc:to_xml())

	local pat_node = md_node:make_child("patterns")

	self:_save_patterns(self._pattern_data, pat_node)
	self._graph:set_graph_metadata(md_node)
	managers.database:save_node(assert(self._graph:save(self._node_id_map)), path)

	self._is_new = false
	self._path = path
	local page_id = self._ui:get_nb_page_by_caption(self._caption)
	self._caption = managers.database:entry_name(path)

	self._ui:set_title(self._path)
	self._ui:update_nb_page_caption(page_id, self._caption)
	self._op_stack:mark_save()
end

function InteractionEditorSystem:undo()
	self._op_stack:undo()
end

function InteractionEditorSystem:redo()
	self._op_stack:redo()
end

function InteractionEditorSystem:has_unsaved_changes()
	return self._op_stack:has_unsaved_changes()
end

function InteractionEditorSystem:set_node_colors(node, id)
	for _, trans in ipairs(self._desc:node_inputs(id)) do
		local color = assert(self:_slot_color(self._desc:transput_type(id, trans)))

		node:set_input_colour(trans, color.r, color.g, color.b)
	end

	for _, trans in ipairs(self._desc:node_outputs(id)) do
		local color = assert(self:_slot_color(self._desc:transput_type(id, trans)))

		node:set_output_colour(trans, color.r, color.g, color.b)
	end
end

function InteractionEditorSystem:_slot_color(t)
	for i, v in ipairs(CoreInteractionEditorConfig.NODE_TYPES) do
		if v == t then
			return CoreInteractionEditorConfig.NODE_COLORS[i]
		end
	end
end

function InteractionEditorSystem:_save_patterns(pattern_data, cfg_node)
	for node, data in pairs(pattern_data) do
		for _, params in pairs(data) do
			local inst = cfg_node:make_child("instance")

			inst:set_parameter("node", node)
			inst:set_parameter("pat", params[2])
			inst:set_parameter("ptype", params[3])
			inst:set_parameter("name", params[4])
			inst:set_parameter("full_name", params[5])
		end
	end
end

function InteractionEditorSystem:_load_patterns(desc, pattern_data, cfg_node)
	for inst in cfg_node:children() do
		local node = inst:parameter("node")
		local pat = inst:parameter("pat")
		local ptype = inst:parameter("ptype")
		local name = inst:parameter("name")
		local full_name = inst:parameter("full_name")

		self:add_pattern_data(node, pat, ptype, name, full_name)
	end
end
