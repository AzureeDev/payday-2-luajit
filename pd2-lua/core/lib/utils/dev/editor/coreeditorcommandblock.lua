core:module("CoreEditorCommandBlock")
core:import("CoreEditorCommand")

CoreEditorCommandBlock = CoreEditorCommandBlock or class()

function CoreEditorCommandBlock:init()
	self._actions = {}
end

function CoreEditorCommandBlock:execute()
	for i = 1, #self._actions do
		self._actions[i]:execute()
	end
end

function CoreEditorCommandBlock:undo()
	local sorted_actions = _G.clone(self._actions)

	for i, action in ipairs(sorted_actions) do
		action.__order = i + (action.__type and (action.__type.__priority or 0))
	end

	table.sort(sorted_actions, function (a, b)
		return a.__order < b.__order
	end)

	for i = #sorted_actions, 1, -1 do
		if managers.editor:undo_debug() then
			print("[Undo] performing undo on ", i, sorted_actions[i])
		end

		sorted_actions[i]:undo(i == 1)
	end
end

function CoreEditorCommandBlock:add_command(action)
	table.insert(self._actions, action)
end

function CoreEditorCommandBlock:__tostring()
	return string.format("[CoreEditorCommandBlock actions: %s]", tostring(#self._actions))
end
