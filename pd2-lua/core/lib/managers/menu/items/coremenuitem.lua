core:module("CoreMenuItem")

Item = Item or class()
Item.TYPE = "item"

function Item:init(data_node, parameters)
	self._type = ""
	local params = parameters or {}
	params.info_panel = ""

	if data_node then
		for key, value in pairs(data_node) do
			if key ~= "_meta" and type(value) ~= "table" then
				params[key] = value
			end
		end
	end

	local required_params = {"name"}

	for _, p_name in ipairs(required_params) do
		if not params[p_name] then
			Application:error("Menu item without parameter '" .. p_name .. "'")
		end
	end

	if params.visible_callback then
		self._visible_callback_name_list = string.split(params.visible_callback, " ")
	end

	if params.enabled_callback then
		self._enabled_callback_name_list = string.split(params.enabled_callback, " ")
	end

	if params.icon_visible_callback then
		self._icon_visible_callback_name_list = string.split(params.icon_visible_callback, " ")
	end

	if params.callback then
		params.callback = string.split(params.callback, " ")
	else
		params.callback = {}
	end

	if params.callback then
		params.callback_name = params.callback
		params.callback = {}
	end

	if params.callback_disabled then
		params.callback_disabled = string.split(params.callback_disabled, " ")
	else
		params.callback_disabled = {}
	end

	if params.callback_disabled then
		params.callback_disabled_name = params.callback_disabled
		params.callback_disabled = {}
	end

	self:set_parameters(params)

	self._enabled = true
end

function Item:set_enabled(enabled)
	self._enabled = enabled

	self:dirty()
end

function Item:enabled()
	return self._enabled
end

function Item:type()
	return self._type
end

function Item:name()
	return self._parameters.name
end

function Item:info_panel()
	return self._parameters.info_panel
end

function Item:parameters()
	return self._parameters
end

function Item:parameter(name)
	return self._parameters[name]
end

function Item:set_parameter(name, value)
	self._parameters[name] = value
end

function Item:set_parameters(parameters)
	self._parameters = parameters
end

function Item:set_callback_handler(callback_handler)
	self._callback_handler = callback_handler

	for _, callback_name in pairs(self._parameters.callback_name) do
		table.insert(self._parameters.callback, callback(callback_handler, callback_handler, callback_name))
	end

	for _, callback_name in pairs(self._parameters.callback_disabled_name) do
		table.insert(self._parameters.callback_disabled, callback(callback_handler, callback_handler, callback_name))
	end

	if self._visible_callback_name_list then
		for _, visible_callback_name in pairs(self._visible_callback_name_list) do
			self._visible_callback_list = self._visible_callback_list or {}

			table.insert(self._visible_callback_list, callback(callback_handler, callback_handler, visible_callback_name))
		end
	end

	if self._icon_visible_callback_name_list then
		for _, visible_callback_name in pairs(self._icon_visible_callback_name_list) do
			self._icon_visible_callback_list = self._icon_visible_callback_list or {}

			table.insert(self._icon_visible_callback_list, callback(callback_handler, callback_handler, visible_callback_name))
		end
	end

	if self._enabled_callback_name_list then
		for _, enabled_callback_name in pairs(self._enabled_callback_name_list) do
			if callback_handler[enabled_callback_name] then
				if not callback_handler[enabled_callback_name](self) then
					self:set_enabled(false)

					break
				end
			else
				Application:error("[Item:set_callback_handler] inexistent callback:", enabled_callback_name)
			end
		end
	end
end

function Item:trigger()
	for _, callback in pairs((self:enabled() or self:parameters().ignore_disabled) and self:parameters().callback or self:parameters().callback_disabled) do
		callback(self)
	end
end

function Item:dirty()
	if self.dirty_callback then
		self:dirty_callback()
	end
end

function Item:set_visible(visible)
	self._visible = visible
end

function Item:visible()
	if self._visible == false then
		return false
	end

	if self._visible_callback_list then
		for _, visible_callback in pairs(self._visible_callback_list) do
			if not visible_callback(self) then
				return false
			end
		end
	end

	return true
end

function Item:on_delete_row_item()
end

function Item:on_delete_item()
	self._parameters.callback = {}
	self._parameters.callback_disabled = {}
	self._visible_callback_list = nil
	self._icon_visible_callback_list = nil
end

function Item:on_item_position(row_item, node)
end

function Item:on_item_positions_done(row_item, node)
end

function Item:get_h(row_item)
	return nil
end

function Item:setup_gui(node, row_item)
	return false
end

function Item:reload(row_item)
	return false
end

function Item:highlight_row_item(node, row_item, mouse_over)
	return false
end

function Item:fade_row_item(node, row_item)
	return false
end

function Item:menu_unselected_visible()
	return true
end

function Item:icon_visible()
	if self._icon_visible_callback_list then
		for _, visible_callback in pairs(self._icon_visible_callback_list) do
			if not visible_callback(self) then
				return false
			end
		end
	end

	return true
end

