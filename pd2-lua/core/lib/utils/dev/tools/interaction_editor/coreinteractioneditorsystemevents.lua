core:module("CoreInteractionEditorSystemEvents")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreInteractionEditorOpStack")

InteractionEditorSystemEvents = InteractionEditorSystemEvents or CoreClass.class()

function InteractionEditorSystemEvents:setup_stack()
	local stack = CoreInteractionEditorOpStack.InteractionEditorOpStack:new()

	return stack
end

function InteractionEditorSystemEvents:undo_add_node(node_id, node_type)
end

function InteractionEditorSystemEvents:redo_add_node(node_id, node_type)
end

function InteractionEditorSystemEvents:undo_remove_node(node_id)
end

function InteractionEditorSystemEvents:redo_remove_node(node_id)
end

function InteractionEditorSystemEvents:on_delete_node(data, event)
	self:remove_node(event:node())
	event:skip()
end

function InteractionEditorSystemEvents:on_select_node(data, event)
	self:ui():clean_prop_panel()

	local nodes = event:selected_nodes()

	if #nodes == 1 then
		self:ui():rebuild_prop_panel(self:desc(), nodes[1]:metadata())
	end

	event:skip()
end

function InteractionEditorSystemEvents:on_connect_node(data, event)
	local md_src = event:source():metadata()
	local output = event:outslot()
	local md_dest = event:dest():metadata()
	local input = event:inslot()

	assert(md_src ~= "" and output ~= "" and md_dest ~= "", input ~= "")

	local src_type = self._desc:transput_type(md_src, output)
	local dest_type = self._desc:transput_type(md_dest, input)

	if src_type == "undefined" or dest_type == "undefined" or src_type == dest_type then
		self._desc:transition_add(md_src, output, md_dest, input)
		event:skip()
	end
end

function InteractionEditorSystemEvents:on_disconnect_node(data, event)
	local md_src = event:source():metadata()
	local output = event:outslot()
	local md_dest = event:dest():metadata()
	local input = event:inslot()

	assert(md_src ~= "" and output ~= "" and md_dest ~= "", input ~= "")
	self._desc:transition_remove(md_src, output, md_dest, input)
	event:skip()
end
