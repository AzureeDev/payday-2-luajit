core:module("CoreMenuInput")
core:import("CoreDebug")
core:import("CoreMenuItem")
core:import("CoreMenuItemSlider")
core:import("CoreMenuItemToggle")

MenuInput = MenuInput or class()

function MenuInput:init(logic, menu_name)
	self._logic = logic
	self._menu_name = menu_name
	self._accept_input = true

	self._logic:register_callback("input_accept_input", callback(self, self, "accept_input"))

	self._axis_delay_timer = {
		x = 0,
		y = 0
	}
	self._item_input_action_map = {
		[CoreMenuItem.Item.TYPE] = callback(self, self, "input_item"),
		[CoreMenuItemSlider.ItemSlider.TYPE] = callback(self, self, "input_slider"),
		[CoreMenuItemToggle.ItemToggle.TYPE] = callback(self, self, "input_toggle")
	}
end

function MenuInput:open(...)
	self:create_controller()
end

function MenuInput:close()
	self:destroy_controller()
end

function MenuInput:axis_timer()
	return self._axis_delay_timer
end

function MenuInput:set_axis_x_timer(time)
	self._axis_delay_timer.x = time
end

function MenuInput:set_axis_y_timer(time)
	self._axis_delay_timer.y = time
end

function MenuInput:_input_hijacked()
	local item = self._logic:selected_item()

	if item and item.input_focus then
		local input_focus = item:input_focus()

		if input_focus then
			return input_focus
		end
	end

	local active_menu = managers.menu:active_menu()

	return active_menu and active_menu.renderer:input_focus()
end

function MenuInput:input_item(item, controller, mouse_click)
	if controller:get_input_pressed("confirm") or mouse_click then
		if item:parameters().sign_in then
			print("requires sign in")

			local function f(success)
				print(success)

				if success then
					self._logic:trigger_item(true, item)
					self:select_node()
				end
			end

			managers.menu:open_sign_in_menu(f)
		else
			local node_gui = managers.menu:active_menu().renderer:active_node_gui()

			if node_gui and node_gui._listening_to_input then
				return
			end

			self._logic:trigger_item(true, item)
			self:select_node()
		end
	end
end

function MenuInput:input_slider(item, controller)
	local slider_delay_down = 0.1
	local slider_delay_pressed = 0.2

	if self:menu_right_input_bool() then
		item:increase()
		self._logic:trigger_item(true, item)
		self:set_axis_x_timer(slider_delay_down)

		if self:menu_right_pressed() then
			local percentage = item:percentage()

			if percentage > 0 and percentage < 100 then
				self:post_event("slider_increase")
			end

			self:set_axis_x_timer(slider_delay_pressed)
		end
	elseif self:menu_left_input_bool() then
		item:decrease()
		self._logic:trigger_item(true, item)
		self:set_axis_x_timer(slider_delay_down)

		if self:menu_left_pressed() then
			self:set_axis_x_timer(slider_delay_pressed)

			local percentage = item:percentage()

			if percentage > 0 and percentage < 100 then
				self:post_event("slider_decrease")
			end
		end
	end
end

function MenuInput:input_toggle(item, controller, mouse_click)
	local toggle_delay_down = 0.3
	local toggle_delay_pressed = 0.6

	if controller:get_input_pressed("confirm") or mouse_click then
		item:toggle()
		self._logic:trigger_item(true, item)
	end
end

function MenuInput:update(t, dt)
	self:_check_releases()
	self:any_keyboard_used()

	local axis_timer = self:axis_timer()

	if axis_timer.y > 0 then
		self:set_axis_y_timer(axis_timer.y - dt)
	end

	if axis_timer.x > 0 then
		self:set_axis_x_timer(axis_timer.x - dt)
	end

	if self:_input_hijacked() then
		local item = self._logic:selected_item()

		if item and item.INPUT_ON_HIJACK then
			self._item_input_action_map[item.TYPE](item, self._controller)
		end

		return false
	end

	if self._accept_input and self._controller then
		if axis_timer.y <= 0 then
			if self:menu_up_input_bool() then
				self:prev_item()
				self:set_axis_y_timer(0.12)

				if self:menu_up_pressed() then
					self:set_axis_y_timer(0.3)
				end
			elseif self:menu_down_input_bool() then
				self:next_item()
				self:set_axis_y_timer(0.12)

				if self:menu_down_pressed() then
					self:set_axis_y_timer(0.3)
				end
			end
		end

		if axis_timer.x <= 0 then
			local item = self._logic:selected_item()

			if item then
				self._item_input_action_map[item.TYPE](item, self._controller)
			end
		end

		if self._controller:get_input_pressed("menu_update") then
			print("update something")
			self._logic:update_node()
		end
	end

	return true
end

function MenuInput:menu_up_input_bool()
	if self._controller then
		return self._controller:get_input_bool("menu_up")
	end

	return false
end

function MenuInput:menu_up_pressed()
	if self._controller then
		return self._controller:get_input_pressed("menu_up")
	end

	return false
end

function MenuInput:menu_up_released()
	if self._controller then
		return self._controller:get_input_released("menu_up")
	end

	return false
end

function MenuInput:menu_down_input_bool()
	if self._controller then
		return self._controller:get_input_bool("menu_down")
	end

	return false
end

function MenuInput:menu_down_pressed()
	if self._controller then
		return self._controller:get_input_pressed("menu_down")
	end

	return false
end

function MenuInput:menu_down_released()
	if self._controller then
		return self._controller:get_input_released("menu_down")
	end

	return false
end

function MenuInput:menu_left_input_bool()
	if self._controller then
		return self._controller:get_input_bool("menu_left")
	end

	return false
end

function MenuInput:menu_left_pressed()
	if self._controller then
		return self._controller:get_input_pressed("menu_left")
	end

	return false
end

function MenuInput:menu_left_released()
	if self._controller then
		return self._controller:get_input_released("menu_left")
	end

	return false
end

function MenuInput:menu_right_input_bool()
	if self._controller then
		return self._controller:get_input_bool("menu_right")
	end

	return false
end

function MenuInput:menu_right_pressed()
	if self._controller then
		return self._controller:get_input_pressed("menu_right")
	end

	return false
end

function MenuInput:menu_right_released()
	if self._controller then
		return self._controller:get_input_released("menu_right")
	end

	return false
end

function MenuInput:_check_releases()
	if self:menu_left_released() or self:menu_right_released() then
		self:set_axis_x_timer(0.01)
	end

	if self:menu_up_released() or self:menu_down_released() then
		self:set_axis_y_timer(0.01)
	end
end

function MenuInput:accept_input(accept)
	self._accept_input = accept
end

function MenuInput:focus(focus)
	if focus then
		self:create_controller()
	else
		self:destroy_controller()
	end
end

function MenuInput:create_controller()
	if not self._controller then
		local controller = managers.controller:create_controller(nil, nil, false)

		controller:add_trigger("cancel", callback(self, self, "back"))
		controller:set_enabled(true)

		self._controller = controller
	end
end

function MenuInput:destroy_controller()
	if self._controller then
		self._controller:destroy()

		self._controller = nil
	end
end

function MenuInput:logic_changed()
end

function MenuInput:next_item()
	if not self._accept_input then
		return
	end

	local current_item = self._logic:selected_item()

	if current_item then
		local current_item_name = current_item:parameters().name
		local items = self._logic:selected_node():items()
		local done = nil

		for i, v in ipairs(items) do
			if v:parameters().name == current_item_name then
				for check = 1, #items - 1 do
					local next_item = items[(i + check - 1) % #items + 1]

					if next_item:visible() and not next_item.no_select then
						self._logic:select_item(next_item:parameters().name, true)

						done = true

						break
					end
				end

				if done then
					break
				end
			end
		end
	end
end

function MenuInput:prev_item()
	local current_item = self._logic:selected_item()

	if current_item then
		local current_item_name = current_item:parameters().name
		local items = self._logic:selected_node():items()
		local done = nil

		for i, v in ipairs(items) do
			if v:parameters().name == current_item_name then
				for check = 1, #items - 1 do
					local prev_item = items[(i - check - 1) % #items + 1]

					if prev_item:visible() and not prev_item.no_select then
						self._logic:select_item(prev_item:parameters().name, true)

						done = true

						break
					end
				end

				if done then
					break
				end
			end
		end
	end
end

function MenuInput:back(queue, skip_nodes)
	if self:_input_hijacked() == true then
		return
	end

	if self._logic:selected_node() and self._logic:selected_node():parameters().block_back then
		return
	end

	self._logic:navigate_back(queue == true or false, type(skip_nodes) == "number" and skip_nodes or false)
end

function MenuInput:select_node()
	local item = self._logic:selected_item()

	if item and item:visible() then
		local parameters = item:parameters()

		if parameters.next_node and (item:enabled() or parameters.ignore_disabled) then
			self._logic:select_node(parameters.next_node, true, unpack(parameters.next_node_parameters or {}))
		end

		if parameters.previous_node then
			self:back()
		end
	end
end

function MenuInput:any_keyboard_used()
	if self._keyboard_used or not self._controller or managers.controller:get_default_wrapper_type() ~= "pc" and managers.controller:get_default_wrapper_type() ~= "steam" then
		return
	end

	for _, key in ipairs({
		"menu_right",
		"menu_left",
		"menu_up",
		"menu_down",
		"confirm"
	}) do
		if self._controller:get_input_bool(key) then
			self._keyboard_used = true

			return
		end
	end
end
