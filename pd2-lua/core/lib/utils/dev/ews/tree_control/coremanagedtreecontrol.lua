require("core/lib/utils/dev/ews/tree_control/CoreEWSTreeCtrlTreeNode")

CoreManagedTreeControl = CoreManagedTreeControl or class()
CoreManagedTreeControl.CHECKBOX_STYLE_STR = "TR_HAS_CHECKBOX"
CoreManagedTreeControl.CHECKBOX_UPDATED_EVENT_NAME = "EVT_COMMAND_TREE_CHECKBOX_UPDATED"
CoreManagedTreeControl.CHECKBOX_STATE0_ICON = CoreEWS.image_path("tree_checkbox_unchecked_16x16.png")
CoreManagedTreeControl.CHECKBOX_STATE1_ICON = CoreEWS.image_path("tree_checkbox_checked_16x16.png")

function CoreManagedTreeControl:init(parent_frame, styles)
	self._styles, self._checkbox_style = self:_eat_checkbox_style(styles or "TR_HAS_BUTTONS,TR_HIDE_ROOT,TR_LINES_AT_ROOT,TR_SINGLE")
	self._tree_ctrl = EWS:TreeCtrl(parent_frame, "", self._styles)

	self:_init_checkbox_icons()

	if self._checkbox_style then
		self._tree_ctrl:connect("", "EVT_LEFT_DOWN", callback(self, self, "_change_state"), "")
		self._tree_ctrl:connect("", "EVT_COMMAND_TREE_ITEM_GETTOOLTIP", callback(self, self, "_tooltip"), "")
	end

	self._visible_root_node = CoreEWSTreeCtrlTreeNode:new(self._tree_ctrl, self._tree_ctrl:append_root("hidden_root"), self._checkbox_style)
	self._tree_event_wrapper_map = {}
	self._custom_callbacks = {}
	self._tooltips = {}
end

function CoreManagedTreeControl:_eat_checkbox_style(styles)
	local checkbox_style = false
	local ret = ""

	for style in string.gmatch(styles, "[%w_]+") do
		if style == self.CHECKBOX_STYLE_STR then
			checkbox_style = true
		else
			ret = ret .. "," .. style
		end
	end

	return ret, checkbox_style
end

function CoreManagedTreeControl:_init_checkbox_icons()
	if self._checkbox_style then
		self:set_image_list(EWS:ImageList(16, 16, false))
		self._image_list:add(self.CHECKBOX_STATE0_ICON)
		self._image_list:add(self.CHECKBOX_STATE1_ICON)
	end
end

function CoreManagedTreeControl:_change_state(data, event)
	local id, hit = self._tree_ctrl:hit_test()

	if id > -1 then
		if hit == "ONITEMICON" then
			self._tree_ctrl:freeze()

			local state = self._tree_ctrl:get_item_image(id, "NORMAL")

			if state == 0 then
				state = 1
			elseif state == 1 then
				state = 0
			else
				self._tree_ctrl:thaw()
				self._tree_ctrl:update()

				return
			end

			self._tree_ctrl:set_item_image(id, state, "NORMAL")
			self._tree_ctrl:thaw()
			self._tree_ctrl:update()
			self:_find_and_do_custom_callback(self.CHECKBOX_UPDATED_EVENT_NAME, {
				_state = state,
				_id = id
			})

			return
		elseif hit == "ONITEMBUTTON" then
			if self._tree_ctrl:is_expanded(id) then
				self._tree_ctrl:collapse(id)
			else
				self._tree_ctrl:expand(id)
			end

			return
		end
	end

	event:skip()
end

function CoreManagedTreeControl:_tooltip(data, event)
	local id, hit = self._tree_ctrl:hit_test()

	if id > -1 and (hit == "ONITEMICON" or hit == "ONITEMLABEL") then
		event:set_tool_tip(self._tooltips[tostring(id)] or "")
	end
end

function CoreManagedTreeControl:_find_and_do_custom_callback(cb_type, data)
	for k, v in pairs(self._custom_callbacks) do
		if v._event_type == cb_type then
			k(v._script_data, data)
		end
	end
end

function CoreManagedTreeControl:_view_tree_root()
	return self._visible_root_node
end

function CoreManagedTreeControl:_tree_root()
	return self._visible_root_node
end

function CoreManagedTreeControl:set_tooltip(node, text)
	self._tooltips[tostring(node._item_id)] = text
end

function CoreManagedTreeControl:set_image_list(list)
	self._image_list = list

	self._tree_ctrl:set_image_list(list)
end

function CoreManagedTreeControl:get_image_list()
	return self._image_list
end

function CoreManagedTreeControl:clear()
	self:_tree_root():remove_children()

	for k, v in pairs(self._custom_callbacks) do
		if v._event_type == self.CHECKBOX_UPDATED_EVENT_NAME then
			self._custom_callbacks[k] = nil
		end
	end
end

function CoreManagedTreeControl:set_size(size)
	self._tree_ctrl:set_size(size)
end

function CoreManagedTreeControl:set_min_size(size)
	self._tree_ctrl:set_min_size(size)
end

function CoreManagedTreeControl:add_to_sizer(sizer, proportion, border, flags)
	return sizer:add(self._tree_ctrl, proportion, border, flags)
end

function CoreManagedTreeControl:detach_from_sizer(sizer)
	return sizer:detach(self._tree_ctrl)
end

function CoreManagedTreeControl:freeze()
	return self._tree_ctrl:freeze()
end

function CoreManagedTreeControl:thaw()
	return self._tree_ctrl:thaw()
end

function CoreManagedTreeControl:append(item_text)
	return self:_tree_root():append(item_text)
end

function CoreManagedTreeControl:append_path(path)
	return self:_tree_root():append_path(path)
end

function CoreManagedTreeControl:append_copy_of_node(node, recurse)
	return self:_tree_root():append_copy_of_node(node, recurse)
end

function CoreManagedTreeControl:expand(recurse)
	self:_view_tree_root():expand(recurse)
end

function CoreManagedTreeControl:collapse(recurse)
	self:_view_tree_root():collapse(recurse)
end

function CoreManagedTreeControl:root_nodes()
	return self:_tree_root():children()
end

function CoreManagedTreeControl:root_node()
	return self:_tree_root()
end

function CoreManagedTreeControl:connect(event_type, script_callback, script_data)
	if event_type == self.CHECKBOX_UPDATED_EVENT_NAME then
		self._custom_callbacks[script_callback] = {
			_event_type = event_type,
			_script_data = script_data
		}
	elseif string.begins(event_type, "EVT_COMMAND_TREE_") then
		local function tree_event_wrapper(data, event, ...)
			local event_metatable = getmetatable(event) or {}
			local wrapped_event = setmetatable({}, {
				__index = event_metatable.__index
			})
			local item_id = event:get_item()
			local old_item_id = event:get_old_item()

			function wrapped_event.get_item()
				return item_id ~= -1 and CoreEWSTreeCtrlTreeNode:new(self._tree_ctrl, item_id, self._checkbox_style) or nil
			end

			function wrapped_event.get_old_item()
				return old_item_id ~= -1 and CoreEWSTreeCtrlTreeNode:new(self._tree_ctrl, old_item_id, self._checkbox_style) or nil
			end

			return script_callback(data, wrapped_event, ...)
		end

		if not self._tree_event_wrapper_map[script_callback] then
			self._tree_event_wrapper_map[script_callback] = tree_event_wrapper

			self._tree_ctrl:connect(event_type, tree_event_wrapper, script_data)
		end
	else
		self._tree_ctrl:connect(event_type, script_callback, script_data)
	end
end

function CoreManagedTreeControl:disconnect(event_type, script_callback)
	if event_type == self.CHECKBOX_UPDATED_EVENT_NAME then
		self._custom_callbacks[script_callback] = nil
	elseif string.begins(event_type, "EVT_COMMAND_TREE_") then
		local resolved_wrapper = self._tree_event_wrapper_map[script_callback]

		if resolved_wrapper then
			self._tree_ctrl:disconnect(event_type, resolved_wrapper)

			self._tree_event_wrapper_map[script_callback] = nil
		end
	else
		self._tree_ctrl:disconnect(event_type, script_callback)
	end
end
