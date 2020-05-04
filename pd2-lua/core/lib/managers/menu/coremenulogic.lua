core:module("CoreMenuLogic")

Logic = Logic or class()

function Logic:init(menu_data)
	self._data = menu_data
	self._node_stack = {}
	self._callback_map = {
		renderer_show_node = nil,
		renderer_refresh_node_stack = nil,
		renderer_refresh_node = nil,
		renderer_update_node = nil,
		renderer_select_item = nil,
		renderer_deselect_item = nil,
		renderer_trigger_item = nil,
		renderer_navigate_back = nil,
		renderer_node_item_dirty = nil,
		input_accept_input = nil,
		menu_manager_menu_closed = nil,
		menu_manager_select_node = nil
	}
	self._action_queue = {}
	self._action_callback_map = {
		select_node = callback(self, self, "_select_node"),
		navigate_back = callback(self, self, "_navigate_back"),
		select_item = callback(self, self, "_select_item"),
		trigger_item = callback(self, self, "_trigger_item"),
		refresh_node = callback(self, self, "_refresh_node"),
		refresh_node_stack = callback(self, self, "_refresh_node_stack"),
		update_node = callback(self, self, "_update_node")
	}
end

function Logic:open(...)
	self._accept_input = not managers.system_menu:is_active()

	self:select_node(nil, true)
end

function Logic:_queue_action(action_name, ...)
	table.insert(self._action_queue, {
		action_name = action_name,
		parameters = {
			...
		}
	})
end

function Logic:_execute_action_queue()
	while self._accept_input and #self._action_queue > 0 do
		local action = self._action_queue[1]

		if self._action_callback_map[action.action_name] then
			self._action_callback_map[action.action_name](unpack(action.parameters))
		end

		table.remove(self._action_queue, 1)
	end
end

function Logic:update(t, dt)
	if self:selected_node() then
		self:selected_node():update(t, dt)
	end

	self:_execute_action_queue()
end

function Logic:select_node(node_name, queue, ...)
	if self._accept_input or queue then
		self:_queue_action("select_node", node_name, ...)
	end
end

function Logic:_select_node(node_name, ...)
	local node = self:get_node(node_name, ...)
	local has_active_menu = managers.menu._open_menus and #managers.menu._open_menus > 0 and true or false

	if has_active_menu and node then
		local selected_node = self:selected_node()

		if selected_node then
			selected_node:trigger_focus_changed(false)
		end

		node:trigger_focus_changed(true, ...)

		if node:parameters().menu_components then
			managers.menu_component:set_active_components(node:parameters().menu_components, node)
		end

		node:parameters().create_params = {
			...
		}

		table.insert(self._node_stack, node)
		self:_call_callback("renderer_show_node", node)
		node:select_item()
		self:_call_callback("renderer_select_item", node:selected_item())
		self:_call_callback("menu_manager_select_node", node)
	end
end

function Logic:refresh_node_stack(queue, ...)
	self:_queue_action("refresh_node_stack", ...)
end

function Logic:_refresh_node_stack(...)
	for i, node in ipairs(self._node_stack) do
		if node:parameters().refresh then
			for _, refresh_func in ipairs(node:parameters().refresh) do
				node = refresh_func(node, ...)
			end
		end

		local selected_item = node:selected_item()

		if selected_item then
			node:select_item(selected_item and selected_item:name())
		end
	end

	self:_call_callback("renderer_refresh_node_stack")
end

function Logic:refresh_node(node_name, queue, ...)
	self:_queue_action("refresh_node", node_name, ...)
end

function Logic:_refresh_node(node_name, ...)
	local node = self:selected_node()

	if node and node:parameters().refresh then
		for _, refresh_func in ipairs(node:parameters().refresh) do
			node = refresh_func(node, ...)
		end
	end

	if node then
		self:_call_callback("renderer_refresh_node", node)

		local selected_item = node:selected_item()

		node:select_item(selected_item and selected_item:name())
		self:_call_callback("renderer_select_item", node:selected_item())
	end
end

function Logic:update_node(node_name, queue, ...)
	self:_queue_action("update_node", node_name, ...)
end

function Logic:_update_node(node_name, ...)
	local node = self:selected_node()

	if node then
		if node:parameters().update then
			for _, update_func in ipairs(node:parameters().update) do
				node = update_func(node, ...)
			end
		end
	else
		Application:error("[CoreLogic:_update_node] Trying to update selected node, but none is selected!")
	end
end

function Logic:navigate_back(queue, skip_nodes)
	if self._accept_input or queue then
		self:_queue_action("navigate_back", skip_nodes)
	end
end

function Logic:_navigate_back(skip_nodes)
	local node = self._node_stack[#self._node_stack]

	if node then
		if node:trigger_back() then
			return
		end

		node:trigger_focus_changed(false)
	end

	skip_nodes = type(skip_nodes) == "number" and skip_nodes or 0

	if #self._node_stack > 1 + skip_nodes then
		for i = 1, 1 + skip_nodes do
			table.remove(self._node_stack, #self._node_stack)
			self:_call_callback("renderer_navigate_back")
		end

		node = self._node_stack[#self._node_stack]

		if node then
			node:trigger_focus_changed(true)

			if node:parameters().menu_components then
				managers.menu_component:set_active_components(node:parameters().menu_components, node)
			end
		end
	end

	self:_call_callback("menu_manager_select_node", node)
end

function Logic:soft_open()
	local node = self._node_stack[#self._node_stack]

	if node then
		if node:parameters().menu_components then
			managers.menu_component:set_active_components(node:parameters().menu_components, node)
		end

		self:_call_callback("menu_manager_select_node", node)
	end
end

function Logic:selected_node()
	return self._node_stack[#self._node_stack]
end

function Logic:selected_node_name()
	return self:selected_node():parameters().name
end

function Logic:select_item(item_name, queue)
	if self._accept_input or queue then
		self:_queue_action("select_item", item_name)
	end
end

function Logic:mouse_over_select_item(item_name, queue)
	if self._accept_input or queue then
		self:_queue_action("select_item", item_name, true)
	end
end

function Logic:_select_item(item_name, mouse_over)
	local current_node = self:selected_node()

	if current_node then
		local current_item = current_node:selected_item()

		if current_item then
			self:_call_callback("renderer_deselect_item", current_item)
		end

		current_node:select_item(item_name)
		self:_call_callback("renderer_select_item", current_node:selected_item(), mouse_over)
	end
end

function Logic:trigger_item(queue, item)
	if self._accept_input or queue then
		self:_queue_action("trigger_item", item)
	end
end

function Logic:_trigger_item(item)
	item = item or self:selected_item()

	if item then
		item:trigger()
		self:_call_callback("renderer_trigger_item", item)
	end
end

function Logic:selected_item()
	local item = nil
	local node = self:selected_node()

	if node then
		item = node:selected_item()
	end

	return item
end

function Logic:get_item(name)
	local item = nil
	local node = self:selected_node()

	if node then
		item = node:item(name)
	end

	return item
end

function Logic:get_node(node_name, ...)
	local node = self._data:get_node(node_name, ...)

	if node and not node.dirty_callback then
		node.dirty_callback = callback(self, self, "node_item_dirty")
	end

	return node
end

function Logic:accept_input(accept)
	self._accept_input = accept

	self:_call_callback("input_accept_input", accept)
end

function Logic:register_callback(id, callback)
	self._callback_map[id] = callback
end

function Logic:_call_callback(id, ...)
	if self._callback_map[id] then
		self._callback_map[id](...)
	else
		Application:error("Logic:_call_callback: Callback " .. id .. " not found.")
	end
end

function Logic:node_item_dirty(node, item)
	self:_call_callback("renderer_node_item_dirty", node, item)
end

function Logic:renderer_closed()
	self:_call_callback("menu_manager_menu_closed")
end

function Logic:close(closing_menu)
	local selected_node = self:selected_node()

	managers.menu_component:set_active_components({})

	self._action_queue = {}

	for index = #self._node_stack, 1, -1 do
		local node = self._node_stack[index]

		if not closing_menu and node then
			node:trigger_back()
		end
	end

	self._node_stack = {}

	self:_call_callback("menu_manager_select_node", false)
end
