core:module("CoreMenuRenderer")
core:import("CoreMenuNodeGui")

Renderer = Renderer or class()
Renderer.border_height = 44

function Renderer:preload()
end

function Renderer:init(logic, parameters)
	parameters = parameters or {}
	self._logic = logic

	self._logic:register_callback("renderer_show_node", callback(self, self, "show_node"))
	self._logic:register_callback("renderer_refresh_node_stack", callback(self, self, "refresh_node_stack"))
	self._logic:register_callback("renderer_refresh_node", callback(self, self, "refresh_node"))
	self._logic:register_callback("renderer_select_item", callback(self, self, "highlight_item"))
	self._logic:register_callback("renderer_deselect_item", callback(self, self, "fade_item"))
	self._logic:register_callback("renderer_trigger_item", callback(self, self, "trigger_item"))
	self._logic:register_callback("renderer_navigate_back", callback(self, self, "navigate_back"))
	self._logic:register_callback("renderer_node_item_dirty", callback(self, self, "node_item_dirty"))

	self._timer = 0
	self._base_layer = parameters.layer or 200
	self.ws = managers.gui_data:create_saferect_workspace()
	self._fullscreen_ws = managers.gui_data:create_fullscreen_workspace()

	if _G.IS_VR then
		self._fullscreen_ws:set_pinned_screen(true)
	end

	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		valign = "scale",
		halign = "scale",
		layer = self._base_layer
	})

	self._fullscreen_ws:hide()

	local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
	self._main_panel = self.ws:panel():panel({
		layer = self._base_layer
	})
	self.safe_rect_panel = self.ws:panel():panel({
		w = safe_rect_pixels.width,
		h = safe_rect_pixels.height,
		layer = self._base_layer
	})
end

function Renderer:_scaled_size()
	return managers.gui_data:scaled_size()
end

function Renderer:open(...)
	managers.gui_data:layout_workspace(self.ws)
	managers.gui_data:layout_fullscreen_workspace(self._fullscreen_ws)
	self:_layout_main_panel()

	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "resolution_changed"))
	self._node_gui_stack = {}
	self._open = true

	self._fullscreen_ws:show()
end

function Renderer:is_open()
	return self._open
end

function Renderer:show_node(node, parameters)
	local layer = self._base_layer
	local previous_node_gui = self:active_node_gui()

	if previous_node_gui then
		layer = previous_node_gui:layer()

		previous_node_gui:set_visible(false)
	end

	local new_node_gui = nil

	if parameters.node_gui_class then
		new_node_gui = parameters.node_gui_class:new(node, layer + 1, parameters)
	else
		new_node_gui = CoreMenuNodeGui.NodeGui:new(node, layer + 1, parameters)
	end

	table.insert(self._node_gui_stack, new_node_gui)

	if not managers.system_menu:is_active() then
		self:disable_input(0.2)
	end
end

function Renderer:refresh_node_stack(parameters)
	for i, node_gui in ipairs(self._node_gui_stack) do
		node_gui:refresh_gui(node_gui.node, parameters)

		local selected_item = node_gui.node and node_gui.node:selected_item()

		if selected_item then
			node_gui:highlight_item(selected_item)
		end
	end
end

function Renderer:refresh_node(node, parameters)
	local layer = self._base_layer
	local node_gui = self:active_node_gui()

	node_gui:refresh_gui(node, parameters)
end

function Renderer:highlight_item(item, mouse_over)
	local active_node_gui = self:active_node_gui()

	if active_node_gui then
		active_node_gui:highlight_item(item, mouse_over)
	end
end

function Renderer:fade_item(item)
	local active_node_gui = self:active_node_gui()

	if active_node_gui then
		active_node_gui:fade_item(item)
	end
end

function Renderer:trigger_item(item)
	local node_gui = self:active_node_gui()

	if node_gui then
		node_gui:reload_item(item)
	end
end

function Renderer:navigate_back()
	local active_node_gui = self:active_node_gui()

	if active_node_gui then
		active_node_gui:close()
		table.remove(self._node_gui_stack, #self._node_gui_stack)
		self:active_node_gui():set_visible(true)
		self:disable_input(0.2)
	end
end

function Renderer:node_item_dirty(node, item)
	local node_name = node:parameters().name

	for _, gui in pairs(self._node_gui_stack) do
		if gui.name == node_name then
			gui:reload_item(item)
		end
	end
end

function Renderer:update(t, dt)
	self:update_input_timer(dt)

	for _, node_gui in ipairs(self._node_gui_stack) do
		node_gui:update(t, dt)
	end
end

function Renderer:update_input_timer(dt)
	if self._timer > 0 then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self._logic:accept_input(true)
		end
	end
end

function Renderer:active_node_gui()
	return self._node_gui_stack[#self._node_gui_stack]
end

function Renderer:disable_input(time)
	self._timer = time

	self._logic:accept_input(false)
end

function Renderer:close()
	self._fullscreen_ws:hide()

	self._open = false

	if self._resolution_changed_callback_id then
		managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)
	end

	for _, node_gui in ipairs(self._node_gui_stack) do
		node_gui:close()
	end

	self._main_panel:clear()
	self._fullscreen_panel:clear()
	self.safe_rect_panel:clear()

	self._node_gui_stack = {}

	self._logic:renderer_closed()
end

function Renderer:hide()
	local active_node_gui = self:active_node_gui()

	if active_node_gui then
		active_node_gui:set_visible(false)
	end
end

function Renderer:show()
	local active_node_gui = self:active_node_gui()

	if active_node_gui then
		active_node_gui:set_visible(true)
	end
end

function Renderer:_layout_main_panel()
	local scaled_size = self:_scaled_size()

	self._main_panel:set_shape(0, 0, scaled_size.width, scaled_size.height)

	local safe_rect = self:_scaled_size()

	self.safe_rect_panel:set_shape(safe_rect.x, safe_rect.y, safe_rect.width, safe_rect.height)
end

function Renderer:resolution_changed()
	local res = RenderSettings.resolution

	managers.gui_data:layout_workspace(self.ws)
	managers.gui_data:layout_fullscreen_workspace(self._fullscreen_ws)
	self:_layout_main_panel()

	for _, node_gui in ipairs(self._node_gui_stack) do
		node_gui:resolution_changed()
	end
end

function Renderer:selected_node()
	local stack = self._node_gui_stack

	return stack[#stack]
end
