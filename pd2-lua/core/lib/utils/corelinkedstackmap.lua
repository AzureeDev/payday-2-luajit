core:module("CoreLinkedStackMap")

LinkedStackMap = LinkedStackMap or class()

function LinkedStackMap:init()
	self._linked_map = {}
	self._top_link = nil
	self._bottom_link = nil
	self._last_link_id = 0
end

function LinkedStackMap:top_link()
	return self._top_link
end

function LinkedStackMap:top()
	return self._top_link and self._top_link.value
end

function LinkedStackMap:get_linked_map()
	return self._linked_map
end

function LinkedStackMap:get(link_id)
	return self._linked_map[link_id]
end

function LinkedStackMap:iterator()
	local function func(map, key)
		local id, link = next(map, key)

		return id, link and link.value
	end

	return func, self._linked_map, nil
end

function LinkedStackMap:top_bottom_iterator()
	local function func(map, link_id)
		if link_id then
			local link = map[link_id].previous

			if link then
				return link.id, link.value
			else
				return nil, nil
			end
		elseif self._top_link then
			return self._top_link.id, self._top_link.value
		else
			return nil, nil
		end
	end

	return func, self._linked_map, nil
end

function LinkedStackMap:bottom_top_iterator()
	local function func(map, link_id)
		if link_id then
			local link = map[link_id].next

			if link then
				return link.id, link.value
			else
				return nil, nil
			end
		elseif self._bottom_link then
			return self._bottom_link.id, self._bottom_link.value
		else
			return nil, nil
		end
	end

	return func, self._linked_map, nil
end

function LinkedStackMap:add(value)
	self._last_link_id = self._last_link_id + 1
	local link = {
		value = value,
		id = self._last_link_id
	}
	self._linked_map[self._last_link_id] = link

	if self._top_link then
		self._top_link.next = link
		link.previous = self._top_link
	else
		self._bottom_link = link
	end

	self._top_link = link

	return self._last_link_id
end

function LinkedStackMap:remove(link_id)
	local link = self._linked_map[link_id]

	if link then
		local previous_link = link.previous
		local next_link = link.next

		if previous_link then
			previous_link.next = next_link
		end

		if next_link then
			next_link.previous = previous_link
		end

		if self._top_link == link then
			self._top_link = previous_link
		end

		if self._bottom_link == link then
			self._bottom_link = next_link
		end

		self._linked_map[link_id] = nil
	end
end

function LinkedStackMap:to_string()
	local string = ""
	local link = self._top_link

	while link do
		if string == "" then
			string = tostring(link.value)
		else
			string = string .. ", " .. tostring(link.value)
		end

		link = link.previous
	end

	return string
end
