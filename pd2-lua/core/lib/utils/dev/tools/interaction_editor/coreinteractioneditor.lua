core:module("CoreInteractionEditor")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreInteractionEditorUI")
core:import("CoreInteractionEditorUIEvents")
core:import("CoreInteractionEditorSystem")

InteractionEditor = InteractionEditor or CoreClass.class(CoreInteractionEditorUIEvents.InteractionEditorUIEvents)

function InteractionEditor:init()
	self._ui = CoreInteractionEditorUI.InteractionEditorUI:new(self)
	self._systems = {}
end

function InteractionEditor:set_position(pos)
	self._ui:set_position(pos)
end

function InteractionEditor:update(t, dt)
	for _, sys in pairs(self._systems) do
		sys:update(t, dt)
	end
end

function InteractionEditor:ui()
	return self._ui
end

function InteractionEditor:close()
	for _, sys in pairs(self._systems) do
		sys:close()
	end

	self._system = nil

	self._ui:destroy()
end

function InteractionEditor:open_system(path)
	for _, sys in pairs(self._systems) do
		sys:deactivate()
	end

	local sys = CoreInteractionEditorSystem.InteractionEditorSystem:new(self._ui, path)
	self._systems[sys] = sys
end

function InteractionEditor:save_system(sys, path)
	assert(sys or self:active_system()):save(path)
end

function InteractionEditor:close_system(sys)
	local system = sys or self:active_system()

	if system then
		if system:has_unsaved_changes() then
			local res = self._ui:want_to_save(system:path())

			if res == "CANCEL" then
				return
			elseif res == "YES" then
				self:do_save(system)
			end
		end

		system:close()
		assert(self._systems[system])

		self._systems[system] = nil
	end
end

function InteractionEditor:active_system()
	for _, sys in pairs(self._systems) do
		if sys:active() then
			return sys
		end
	end
end

function InteractionEditor:activate_system(panel)
	for _, sys in pairs(self._systems) do
		sys:deactivate()
	end

	for _, sys in pairs(self._systems) do
		if sys:panel() == panel then
			sys:activate()

			return
		end
	end
end

function InteractionEditor:do_save(sys)
	local system = sys or self:active_system()

	if system then
		if system:is_new() then
			self:do_save_as(system)
		else
			self:save_system(system, system:path())
		end
	end
end

function InteractionEditor:do_save_as(sys)
	local system = sys or self:active_system()

	if system then
		local path, dir = managers.database:save_file_dialog(self._ui:frame(), true, "*.interaction_project", managers.database:entry_name(managers.database:base_path() .. "/" .. string.lower(system:caption())))

		if path then
			self:save_system(system, path)
		end
	end
end

function InteractionEditor:do_save_all()
	for _, system in pairs(self._systems) do
		if system:is_new() then
			self:do_save_as(system)
		else
			self:save_system(system, system:path())
		end
	end
end

function InteractionEditor:undo(sys)
	local system = sys or self:active_system()

	if system then
		system:undo()
	end
end

function InteractionEditor:redo(sys)
	local system = sys or self:active_system()

	if system then
		system:redo()
	end
end
