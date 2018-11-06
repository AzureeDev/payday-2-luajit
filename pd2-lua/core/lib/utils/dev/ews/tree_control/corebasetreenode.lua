CoreBaseTreeNode = CoreBaseTreeNode or class()

function CoreBaseTreeNode:path(separator)
	separator = separator or "/"
	local parent = self:parent()

	if parent then
		return parent:path() .. separator .. self:text()
	end

	return self:text()
end

function CoreBaseTreeNode:has_children()
	return table.getn(self:children()) > 0
end

function CoreBaseTreeNode:child(text, separator)
	for _, child in ipairs(self:children()) do
		if child:text() == text then
			return child
		end
	end
end

function CoreBaseTreeNode:child_at_path(path, separator)
	separator = separator or "/"
	local first_path_component, remaining_path = string.split(path, separator, false, 1)
	local child = self:child(first_path_component)

	if child and remaining_path then
		return child:child_at_path(remaining_path, separator)
	end

	return child
end

function CoreBaseTreeNode:append_path(path, separator)
	separator = separator or "/"
	local first_path_component, remaining_path = unpack(string.split(path, separator, false, 1))
	local node = self:child(first_path_component) or self:append(first_path_component)

	if remaining_path then
		return node:append_path(remaining_path, separator)
	end

	return node
end

function CoreBaseTreeNode:append_copy_of_node(node, recurse)
	local new_node = self:append(node:text())

	if recurse then
		for _, child in ipairs(node:children()) do
			new_node:append_copy_of_node(child, true)
		end
	end

	return new_node
end

function CoreBaseTreeNode:for_each_child(func, recurse)
	for _, child in ipairs(table.list_copy(self:children())) do
		if not func(child) then
			break
		end

		if recurse then
			child:for_each_child(func, true)
		end
	end
end

function CoreBaseTreeNode:remove_children()
	for _, child in ipairs(table.list_copy(self:children())) do
		child:remove()
	end
end
