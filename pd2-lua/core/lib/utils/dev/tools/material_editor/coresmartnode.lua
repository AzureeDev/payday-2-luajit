CoreSmartNode = CoreSmartNode or class()

function CoreSmartNode:init(node)
	self._parameters = {}
	self._children = {}

	if type(node) == "string" then
		self._name = node
	else
		self._name = node:name()

		for k, v in pairs(node:parameters()) do
			self._parameters[k] = v
		end

		for child in node:children() do
			table.insert(self._children, CoreSmartNode:new(child))
		end
	end
end

function CoreSmartNode:children()
	local count = table.getn(self._children)
	local i = 0

	return function ()
		i = i + 1

		if i <= count then
			return self._children[i]
		end
	end
end

function CoreSmartNode:parameters()
	return self._parameters
end

function CoreSmartNode:name()
	return self._name
end

function CoreSmartNode:num_children()
	return #self._children
end

function CoreSmartNode:parameter(k)
	return self._parameters[k]
end

function CoreSmartNode:set_parameter(k, v)
	self._parameters[k] = v
end

function CoreSmartNode:clear_parameter(k)
	self._parameters[k] = nil
end

function CoreSmartNode:make_child(name)
	local node = CoreSmartNode:new(name)

	table.insert(self._children, node)

	return node
end

function CoreSmartNode:add_child(n)
	local node = CoreSmartNode:new(n)

	table.insert(self._children, node)

	return node
end

function CoreSmartNode:index_of_child(c)
	local i = 0

	for child in self:children() do
		if child == c then
			return i
		end

		i = i + 1
	end

	return -1
end

function CoreSmartNode:remove_child_at(index)
	local i = index + 1
	self._children[i] = self._children[#self._children]
	self._children[#self._children] = nil
end

function CoreSmartNode:to_real_node()
	local node = Node(self._name)

	for k, v in pairs(self:parameters()) do
		node:set_parameter(k, v)
	end

	for child in self:children() do
		node:add_child(child:to_real_node())
	end

	return node
end

function CoreSmartNode:to_xml()
	return self:to_real_node():to_xml()
end
