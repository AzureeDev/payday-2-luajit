core:module("CoreInteractionEditorUIEvents")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreMath")
core:import("CoreInteractionEditorConfig")

InteractionEditorUIEvents = InteractionEditorUIEvents or CoreClass.class()

function InteractionEditorUIEvents:on_close()
	managers.toolhub:close(CoreInteractionEditorConfig.EDITOR_TITLE)
end

function InteractionEditorUIEvents:on_new()
	self:open_system()
end

function InteractionEditorUIEvents:on_close_system()
	self:close_system()
end

function InteractionEditorUIEvents:on_notebook_changing(data, event)
	self:activate_system(self:ui():get_nb_page(event:get_selection()))
end

function InteractionEditorUIEvents:on_show_graph_context_menu(system)
	self:ui():show_graph_context_menu(system)
end

function InteractionEditorUIEvents:on_add_node(func)
	func()
end

function InteractionEditorUIEvents:on_remove_node(func)
	func()
end

function InteractionEditorUIEvents:on_save()
	self:do_save()
end

function InteractionEditorUIEvents:on_save_as()
	self:do_save_as()
end

function InteractionEditorUIEvents:on_save_all()
	self:do_save_all()
end

function InteractionEditorUIEvents:on_open()
	local path, dir = managers.database:open_file_dialog(self:ui():frame(), "*.interaction_project")

	if path and managers.database:has(path) then
		self:open_system(path)
	end
end

function InteractionEditorUIEvents:on_undo()
end

function InteractionEditorUIEvents:on_redo()
end
