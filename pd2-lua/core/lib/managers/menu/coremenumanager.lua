core:module("CoreMenuManager")
core:import("CoreMenuData")
core:import("CoreMenuLogic")
core:import("CoreMenuInput")
core:import("CoreMenuRenderer")

Manager = Manager or class()

function Manager:init()
	managers.menu = managers.menu or self
	self._registered_menus = {}
	self._open_menus = {}
end

function Manager:destroy()
	for _, menu in ipairs(self._open_menus) do
		self:close_menu(menu.name)
	end
end

function Manager:register_menu(menu)
	if menu.name and self._registered_menus[menu.name] then
		return
	end

	menu.data = CoreMenuData.Data:new()

	menu.data:load_data(menu.content_file, menu.id)
	menu.data:set_callback_handler(menu.callback_handler)

	menu.logic = CoreMenuLogic.Logic:new(menu.data)

	menu.logic:register_callback("menu_manager_menu_closed", callback(self, self, "_menu_closed", menu.name))
	menu.logic:register_callback("menu_manager_select_node", callback(self, self, "_node_selected", menu.name))

	if not menu.input then
		menu.input = CoreMenuInput.MenuInput:new(menu.logic, menu.name)
	else
		menu.input = loadstring("return " .. menu.input)()
		menu.input = menu.input:new(menu.logic, menu.name)
	end

	if not menu.renderer then
		menu.renderer = CoreMenuRenderer.Renderer:new(menu.logic)
	else
		menu.renderer = loadstring("return " .. menu.renderer)()
		menu.renderer = menu.renderer:new(menu.logic)
	end

	menu.renderer:preload()

	if menu.name then
		self._registered_menus[menu.name] = menu
	else
		Application:error("Manager:register_menu(): Menu '" .. menu.id .. "' is missing a name, in '" .. menu.content_file .. "'")
	end
end

function Manager:get_menu(menu_name)
	local menu = self._registered_menus[menu_name]

	return menu
end

function Manager:open_menu(menu_name, position, ...)
	local menu = self._registered_menus[menu_name]

	if menu then
		for _, open_menu in ipairs(self._open_menus) do
			if open_menu.name == menu_name then
				return false
			end
		end

		local current_open_menu = self._open_menus[#self._open_menus]

		if position then
			table.insert(self._open_menus, position, menu)
		else
			table.insert(self._open_menus, menu)
		end

		if current_open_menu and current_open_menu ~= self._open_menus[#self._open_menus] then
			current_open_menu.renderer:hide()
		end

		menu.renderer:open(...)
		menu.logic:open(...)
		menu.input:open(position, ...)
		self:input_enabled(true)

		return true
	else
		Application:error("Manager:open_menu: No menu named '" .. menu_name .. "'")

		return false
	end
end

function Manager:close_menu(menu_name)
	local menu = nil

	if menu_name then
		for _, open_menu in ipairs(self._open_menus) do
			if open_menu.name == menu_name then
				menu = open_menu

				break
			end
		end
	else
		menu = self._open_menus[#self._open_menus]
	end

	if menu then
		menu.logic:close(true)
		menu.input:close()
		menu.renderer:close()
	end
end

function Manager:_menu_closed(menu_name)
	if menu_name then
		for i, menu in ipairs(self._open_menus) do
			if menu.name == menu_name then
				table.remove(self._open_menus, i)
			end
		end
	else
		table.remove(self._open_menus, #self._open_menus)
	end

	if self._open_menus[#self._open_menus] then
		self._open_menus[#self._open_menus].renderer:show()
		self._open_menus[#self._open_menus].logic:accept_input(true)
		self._open_menus[#self._open_menus].logic:soft_open()
	end
end

function Manager:_node_selected(menu_name, node)
end

function Manager:input_enabled(enabled)
	self._input_enabled = enabled

	for _, menu in ipairs(self._open_menus) do
		menu.input:focus(enabled)
	end
end

function Manager:update(t, dt)
	local active_menu = self._open_menus[#self._open_menus]

	if active_menu then
		active_menu.logic:update(t, dt)

		if self._input_enabled then
			active_menu.input:update(t, dt)
		end
	end

	for _, menu in ipairs(self._open_menus) do
		menu.renderer:update(t, dt)
	end
end
