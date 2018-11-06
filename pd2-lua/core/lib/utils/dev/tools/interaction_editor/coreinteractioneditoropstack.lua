core:module("CoreInteractionEditorOpStack")
core:import("CoreClass")
core:import("CoreCode")

InteractionEditorOpStack = InteractionEditorOpStack or CoreClass.class()

function InteractionEditorOpStack:init()
	self._stack = {}
	self._redo_stack = {}
	self._ops = {
		save = {
			name = "save"
		}
	}
end

function InteractionEditorOpStack:has_unsaved_changes()
	local size = #self._stack

	return size > 0 and self._stack[size].op.name ~= "save"
end

function InteractionEditorOpStack:new_op_type(name, undo_cb, redo_cb)
	self._ops[name] = {
		name = name,
		undo_cb = undo_cb,
		redo_cb = redo_cb
	}
end

function InteractionEditorOpStack:mark_save()
	self:new_op("save")
end

function InteractionEditorOpStack:new_op(name, ...)
	table.insert(self._stack, {
		op = assert(self._ops[name]),
		params = {
			...
		}
	})

	self._redo_stack = {}
end

function InteractionEditorOpStack:undo()
	local size = #self._stack

	if size > 0 then
		local op_data = self._stack[size]

		table.insert(self._redo_stack, op_data)
		table.remove(self._stack, size)

		if op_data.op.name ~= "save" then
			op_data.op.undo_cb(op.params)
		else
			self:undo()
		end
	end
end

function InteractionEditorOpStack:redo()
	local size = #self._redo_stack

	if size > 0 then
		local op_data = self._redo_stack[size]

		table.insert(self._stack, op_data)
		table.remove(self._redo_stack, size)

		if op_data.op.name ~= "save" then
			op_data.op.redo_cb(op.params)
		else
			self:redo()
		end
	end
end
