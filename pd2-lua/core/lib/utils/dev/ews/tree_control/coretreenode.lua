require("core/lib/utils/dev/ews/tree_control/CoreBaseTreeNode")

CoreTreeNode = CoreTreeNode or class(CoreBaseTreeNode)

function CoreTreeNode:init(text)
	self._text = text or ""
	self._parent = nil
	self._children = {}
end

function CoreTreeNode:set_callback(event_name, func)
	self._callbacks = self._callbacks or {}
	self._callbacks[event_name] = func
end

function CoreTreeNode:_invoke_callback(event_name, ...)
	local callback_table = self._callbacks

	if not callback_table then
		return
	end

	local callback = callback_table[event_name]

	if callback then
		callback(...)
	end
end

function CoreTreeNode:text()
	return self._text
end

function CoreTreeNode:parent()
	if self._parent and self._parent._parent then
		return self._parent
	end
end

function CoreTreeNode:remove_children()
	return self.super.remove_children(self)
end

function CoreTreeNode:children()
	return self._children
end

function CoreTreeNode:append(text)
	local new_node = CoreTreeNode:new(text)
	new_node._callbacks = self._callbacks
	new_node._parent = self

	table.insert(self._children, new_node)
	self:_invoke_callback("on_append", new_node)

	return new_node
end

function CoreTreeNode:remove()
	self:_invoke_callback("on_remove", self)

	if self._parent then
		table.delete(self._parent._children, self)
	end

	self._text = ""
	self._parent = nil
	self._children = {}
end
