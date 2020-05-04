CoreHub = CoreHub or class(HubElement)
Hub = Hub or class(CoreHub)

function Hub:init(...)
	CoreHub.init(self, ...)
end

function CoreHub:init(unit)
	HubElement.init(self, unit)

	self._timeline_color = Vector3(0, 1, 0)
	self._hed.required_triggers = "all"
	self._hed.trigger_once = true
	self._hed.trigger_on_inverse = false
	self._hed.actions_data = {}
	self._hed.triggers_data = {}
	self._hed.default_test_hub = false
	self._hed.use_as_start = false
	self._hed.never_start = false
	self._hed.start_from_relay = "none"
	self._hed.hub_entered_from_zone = "none"

	table.insert(self._save_values, "required_triggers")
	table.insert(self._save_values, "actions_data")
	table.insert(self._save_values, "triggers_data")
	table.insert(self._save_values, "default_test_hub")
	table.insert(self._save_values, "trigger_once")
	table.insert(self._save_values, "trigger_on_inverse")
	table.insert(self._save_values, "use_as_start")
	table.insert(self._save_values, "never_start")
	table.insert(self._hed.action_types, "activate")
	table.insert(self._hed.action_types, "deactivate")
	table.insert(self._hed.action_types, "trigger_actions")
end

function CoreHub:set_actions()
	if not self._actions_ctrlrs then
		return
	end

	self._actions_ctrlrs.actions:clear()

	if #self._hed.actions ~= 0 then
		self:append_actions_sorted()

		if self._selected_action and alive(self:action_unit(self._selected_action.unit_id)) then
			local u = self:action_unit(self._selected_action.unit_id)

			self:select_action(self:combobox_name(u), self._actions_ctrlrs.actions, self._actions_ctrlrs.action_types, self._actions_ctrlrs.action_delay)
		else
			self:select_action(self:_action_names()[1], self._actions_ctrlrs.actions, self._actions_ctrlrs.action_types, self._actions_ctrlrs.action_delay)
		end
	else
		self._actions_ctrlrs.actions:set_enabled(false)

		local action_types = self._actions_ctrlrs.action_types

		action_types:clear()
		action_types:set_enabled(false)

		local action_delay = self._actions_ctrlrs.action_delay

		action_delay:set_value("-")
		action_delay:set_enabled(false)
	end
end

function CoreHub:append_actions_sorted()
	self._actions_ctrlrs.actions:clear()

	for _, name in ipairs(self:_action_names()) do
		self._actions_ctrlrs.actions:append(name)
	end
end

function CoreHub:_action_names()
	local names = {}

	for _, action in ipairs(self._hed.actions) do
		table.insert(names, self:combobox_name(action))
	end

	table.sort(names)

	return names
end

function CoreHub:set_triggers()
	if not self._triggers_ctrlrs then
		return
	end

	self._triggers_ctrlrs.triggers:clear()

	if #self._hed.triggers ~= 0 then
		self:append_triggers_sorted()

		if self._selected_trigger and alive(self:trigger_unit(self._selected_trigger.unit_id)) then
			local u = self:trigger_unit(self._selected_trigger.unit_id)

			self:select_trigger(self:combobox_name(u), self._triggers_ctrlrs.triggers, self._triggers_ctrlrs.trigger_types)
		else
			self:select_trigger(self:_trigger_names()[1], self._triggers_ctrlrs.triggers, self._triggers_ctrlrs.trigger_types)
		end
	else
		self._triggers_ctrlrs.triggers:set_enabled(false)

		local trigger_types = self._triggers_ctrlrs.trigger_types

		trigger_types:clear()
		trigger_types:set_enabled(false)
	end
end

function CoreHub:append_triggers_sorted()
	self._triggers_ctrlrs.triggers:clear()

	for _, name in ipairs(self:_trigger_names()) do
		self._triggers_ctrlrs.triggers:append(name)
	end
end

function CoreHub:_trigger_names()
	local names = {}

	for _, trigger in ipairs(self._hed.triggers) do
		table.insert(names, self:combobox_name(trigger))
	end

	table.sort(names)

	return names
end

function CoreHub:set_required_triggers()
	self._required_triggers:clear()

	for i = 1, #self._hed.triggers - 1 do
		self._required_triggers:append(i)
	end

	self._required_triggers:append("all")

	if self._hed.required_triggers ~= "all" and tonumber(self._hed.required_triggers) > #self._hed.triggers - 1 then
		if tonumber(self._hed.required_triggers) == 1 then
			self._hed.required_triggers = "all"
		else
			self._hed.required_triggers = self._hed.required_triggers - 1
		end
	end

	self._required_triggers:set_value(self._hed.required_triggers)
end

function CoreHub:set_trigger_type(trigger_types)
	if self._selected_trigger then
		self._selected_trigger.type = trigger_types:get_value()
	end
end

function CoreHub:set_action_type(action_types)
	if self._selected_action then
		self._selected_action.type = action_types:get_value()
	end
end

function CoreHub:set_action_delay(action_delay)
	if self._selected_action then
		local value = tonumber(action_delay:get_value()) or 0
		self._selected_action.action_delay = value

		action_delay:change_value(string.format("%.4f", self._selected_action.action_delay))

		if self._timeline then
			self._timeline:action_delay_updated(self._selected_action)
		end
	end
end

function CoreHub:ews_select_action()
	self:select_action(self._actions_ctrlrs.actions:get_value(), self._actions_ctrlrs.actions, self._actions_ctrlrs.action_types, self._actions_ctrlrs.action_delay)
end

function CoreHub:select_action_with_unit(unit)
	if not table.contains(self._hed.actions, unit) then
		return
	end

	self:select_action(self:combobox_name(unit), self._actions_ctrlrs.actions, self._actions_ctrlrs.action_types, self._actions_ctrlrs.action_delay)
end

function CoreHub:ews_select_trigger()
	self:select_trigger(self._triggers_ctrlrs.triggers:get_value(), self._triggers_ctrlrs.triggers, self._triggers_ctrlrs.trigger_types)
end

function CoreHub:select_trigger_with_unit(unit)
	if not table.contains(self._hed.triggers, unit) then
		return
	end

	self:select_trigger(self:combobox_name(unit), self._triggers_ctrlrs.triggers, self._triggers_ctrlrs.trigger_types)
end

function CoreHub:select_action(s, actions, action_types, action_delay)
	local action_id = self:combobox_id(s)
	local a = self._hed.actions_data[action_id]
	self._selected_action = a

	actions:set_enabled(true)
	actions:set_value(s)
	action_types:set_enabled(true)
	action_types:clear()

	local action_unit = self:action_unit(self._selected_action.unit_id)

	if #action_unit:hub_element_data().action_types ~= 0 then
		for _, types in ipairs(action_unit:hub_element_data().action_types) do
			action_types:append(types)
		end

		action_types:set_value(self._selected_action.type)
	else
		action_types:set_enabled(false)
	end

	action_delay:set_enabled(true)
	action_delay:change_value(string.format("%.4f", self._selected_action.action_delay))

	if self._timeline then
		self._timeline:select_action(self._selected_action)
	end
end

function CoreHub:select_trigger(s, triggers, trigger_types)
	local trigger_id = self:combobox_id(s)
	local t = self._hed.triggers_data[trigger_id]
	self._selected_trigger = t

	triggers:set_enabled(true)
	triggers:set_value(s)
	trigger_types:set_enabled(true)
	trigger_types:clear()

	local trigger_unit = self:trigger_unit(self._selected_trigger.unit_id)

	if #trigger_unit:hub_element_data().trigger_types ~= 0 then
		for _, types in ipairs(trigger_unit:hub_element_data().trigger_types) do
			trigger_types:append(types)
		end

		trigger_types:set_value(self._selected_trigger.type)
	else
		trigger_types:set_enabled(false)
	end
end

function CoreHub:update_selected(t, dt)
	Application:draw_circle(self._unit:position(), 75, 1, 1, 0)
end

function CoreHub:draw_connections_selected(t, dt)
	self:draw_triggers(t, dt)
	self:draw_actions(t, dt)
end

function CoreHub:draw_actions(t, dt)
	for _, action in ipairs(self._hed.actions) do
		local r, g, b = action:hub_element():get_color(self._hed.actions_data[self:id_string(action)].type)

		self:draw_arrow(self._unit, action, r * 0.5, g * 0.5, b * 0.5, true)
	end

	if self._selected_action and alive(self:action_unit(self._selected_action.unit_id)) then
		local action = self:action_unit(self._selected_action.unit_id)
		local r, g, b = action:hub_element():get_color(self._selected_action.type)
		local s = 0.75 + (1 + math.sin(t * 100)) * 0.25 * 0.5

		Application:draw(action, r * s, g * s, b * s)
		self:draw_arrow(self._unit, action, r * s, g * s, b * s, true)
	end
end

function CoreHub:draw_triggers(t, dt)
	for _, trigger in ipairs(self._hed.triggers) do
		local r = 1
		local g = 1
		local b = 0

		if trigger:name() == "hub" then
			b = 1
			g = 0
			r = 0
		end

		self:draw_arrow(trigger, self._unit, r * 0.5, g * 0.5, b * 0.5, true)
	end

	if self._selected_trigger and alive(self:trigger_unit(self._selected_trigger.unit_id)) then
		local r = 1
		local g = 1
		local b = 0
		local trigger = self:trigger_unit(self._selected_trigger.unit_id)

		if trigger:name() == "hub" then
			b = 1
			g = 0
			r = 0
		end

		local s = 0.75 + (1 + math.sin(t * 100)) * 0.25 * 0.5

		Application:draw(trigger, r * s, g * s, b * s)
		self:draw_arrow(trigger, self._unit, r * s, g * s, b * s, true)
	end
end

function CoreHub:update_unselected()
end

function CoreHub:draw_connections_unselected()
	Application:draw_circle(self._unit:position(), 50, 1, 1, 0)

	for _, trigger in ipairs(self._hed.triggers) do
		local r = 1
		local g = 1
		local b = 0

		if trigger:name() == "hub" then
			b = 0.75
			g = 0.1
			r = 0.1
		end

		Application:draw_circle(trigger:position(), 50, r, g, b)
		self:draw_arrow(trigger, self._unit, r * 0.75, g * 0.75, b * 0.75, false)
	end

	for _, action in ipairs(self._hed.actions) do
		local r, g, b = action:hub_element():get_color(self._hed.actions_data[self:id_string(action)].type)

		Application:draw_circle(action:position(), 50, r, g, b)
		self:draw_arrow(self._unit, action, r * 0.5, g * 0.5, b * 0.5, false)
	end
end

function CoreHub:combobox_name(unit)
	return unit:unit_data().name_id .. " (" .. unit:unit_data().unit_id .. ")"
end

function CoreHub:combobox_id(name)
	local s = nil
	local e = string.len(name) - 1

	for i = string.len(name), 0, -1 do
		local t = string.sub(name, i, i)

		if t == "(" then
			s = i + 1

			break
		end
	end

	return string.sub(name, s, e)
end

function CoreHub:id_string(unit)
	return tostring(unit:unit_data().unit_id)
end

function CoreHub:save_mission_action(file, t, hub)
	HubElement.save_mission_action(self, file, t, hub, true)
end

function CoreHub:save_mission_trigger(file, tab)
	local name = self._unit:name()

	file:puts(tab .. "<trigger type=\"Hub\" name=\"" .. name .. self._unit:unit_data().unit_id .. "\"/>")
end

function CoreHub:layer_finished()
	local hed = self._hed
	local t = {}

	for key, value in pairs(hed.actions_data) do
		local unit = managers.worlddefinition:get_hub_element_unit(value.unit_id)
		t[self:id_string(unit)] = value
	end

	hed.actions_data = t

	for key, value in pairs(hed.actions_data) do
		local a = managers.worlddefinition:get_hub_element_unit(value.unit_id)

		table.insert(hed.actions, a)
		table.insert(a:hub_element_data().hubs, self._unit)
	end

	local tt = {}

	for key, value in pairs(hed.triggers_data) do
		local v = value

		if type_name(value) == "number" then
			v = {
				type = "",
				unit_id = v
			}
		end

		local unit = managers.worlddefinition:get_hub_element_unit(v.unit_id)
		tt[self:id_string(unit)] = v
	end

	hed.triggers_data = tt

	for key, value in pairs(hed.triggers_data) do
		local t = managers.worlddefinition:get_hub_element_unit(value.unit_id)

		table.insert(hed.triggers, t)
		table.insert(t:hub_element_data().hubs, self._unit)
	end
end

function CoreHub:action_unit(id)
	for _, unit in ipairs(self._hed.actions) do
		if unit:unit_data().unit_id == id then
			return unit
		end
	end
end

function CoreHub:trigger_unit(id)
	for _, unit in ipairs(self._hed.triggers) do
		if unit:unit_data().unit_id == id then
			return unit
		end
	end
end

function CoreHub:add_action(a)
	if table.contains(self._hed.actions, a) then
		return
	end

	table.insert(self._hed.actions, a)
	table.insert(a:hub_element_data().hubs, self._unit)

	local s = self:id_string(a)
	self._hed.actions_data[s] = {
		type = "",
		action_delay = 0,
		unit_id = a:unit_data().unit_id
	}

	if #a:hub_element_data().action_types ~= 0 then
		self._hed.actions_data[s].type = a:hub_element_data().action_types[1]
	end

	self:append_actions_sorted()

	if self._timeline then
		self._timeline:add_action(a)
	end

	self:select_action(self:combobox_name(a), self._actions_ctrlrs.actions, self._actions_ctrlrs.action_types, self._actions_ctrlrs.action_delay)
end

function CoreHub:add_trigger(t)
	if table.contains(self._hed.triggers, t) then
		return
	end

	table.insert(self._hed.triggers, t)
	table.insert(t:hub_element_data().hubs, self._unit)

	local s = self:id_string(t)
	self._hed.triggers_data[s] = {
		type = "",
		unit_id = t:unit_data().unit_id
	}

	if #t:hub_element_data().trigger_types ~= 0 then
		self._hed.triggers_data[s].type = t:hub_element_data().trigger_types[1]
	end

	if self._triggers_ctrlrs.triggers then
		self:append_triggers_sorted()
	end

	self:select_trigger(self:combobox_name(t), self._triggers_ctrlrs.triggers, self._triggers_ctrlrs.trigger_types)
	self:set_required_triggers()
end

function CoreHub:remove_action(a)
	cat_print("editor", "remove_action", a:name())
	table.delete(a:hub_element_data().hubs, self._unit)
	self:delete_action(a)

	if self._timeline then
		self._timeline:remove_action(a)
	end
end

function CoreHub:delete_action(a)
	table.delete(self._unit:hub_element_data().actions, a)

	if self._selected_action and self:action_unit(self._selected_action.unit_id) == a then
		self._selected_action = nil
	end

	self._hed.actions_data[self:id_string(a)] = nil

	self:set_actions()

	if self._timeline then
		self._timeline:remove_action(a)
	end
end

function CoreHub:remove_trigger(t)
	cat_print("editor", "remove_trigger", t:name())
	table.delete(t:hub_element_data().hubs, self._unit)
	self:delete_trigger(t)
	self:set_required_triggers()
end

function CoreHub:delete_trigger(t)
	table.delete(self._unit:hub_element_data().triggers, t)

	if self._selected_trigger and self:trigger_unit(self._selected_trigger.unit_id) == t then
		self._selected_trigger = nil
	end

	self._hed.triggers_data[self:id_string(t)] = nil

	self:set_triggers()
end

function CoreHub:get_hub_action(unit)
	return self._hed.actions_data[self:id_string(unit)]
end

function CoreHub:get_hub_trigger(unit)
	return self._hed.triggers_data[self:id_string(unit)]
end

function CoreHub:on_timeline_btn()
	if not self._timeline then
		self._timeline = HubTimeline:new(self._unit:unit_data().name_id)

		self._timeline:set_hub_unit(self._unit)
	else
		self._timeline:set_visible(true)
	end
end

function CoreHub:_build_panel()
	self:_create_panel()

	local timeline_btn = EWS:Button(self._panel, "Timeline", "", "BU_EXACTFIT,NO_BORDER")

	self._panel_sizer:add(timeline_btn, 0, 5, "TOP,BOTTOM,EXPAND")
	timeline_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_timeline_btn"))

	local use_as_start_cb = EWS:CheckBox(self._panel, "Start hub", "")

	use_as_start_cb:set_value(self._hed.use_as_start)
	use_as_start_cb:set_tool_tip("Tell the mission that this is the start hub, not the one without triggers.")
	use_as_start_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "use_as_start",
		ctrlr = use_as_start_cb
	})

	local trigger_once_cb = EWS:CheckBox(self._panel, "Trigger Once", "")

	trigger_once_cb:set_value(self._hed.trigger_once)
	trigger_once_cb:set_tool_tip("The hub will only perform actions once.")
	trigger_once_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "trigger_once",
		ctrlr = trigger_once_cb
	})

	local trigger_on_inverse_cb = EWS:CheckBox(self._panel, "Actions On Inverse", "")

	trigger_on_inverse_cb:set_value(self._hed.trigger_on_inverse)
	trigger_on_inverse_cb:set_tool_tip("Will have the hub perform actions when triggers reaches start state again.")
	trigger_on_inverse_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "trigger_on_inverse",
		ctrlr = trigger_on_inverse_cb
	})

	local trigger_cbs_sizer = EWS:BoxSizer("HORIZONTAL")
	local trigger_cb1_sizer = EWS:BoxSizer("VERTICAL")

	trigger_cb1_sizer:add(use_as_start_cb, 0, 5, "EXPAND,TOP")
	trigger_cb1_sizer:add(trigger_once_cb, 0, 5, "EXPAND,BOTTOM")
	trigger_cbs_sizer:add(trigger_cb1_sizer, 1, 0, "EXPAND")
	trigger_cbs_sizer:add(EWS:StaticLine(self._panel, "", "LI_VERTICAL"), 0, 5, "EXPAND,TOP,RIGHT")

	local trigger_cb2_sizer = EWS:BoxSizer("VERTICAL")

	trigger_cb2_sizer:add(trigger_on_inverse_cb, 0, 5, "EXPAND,TOP")
	trigger_cbs_sizer:add(trigger_cb2_sizer, 1, 0, "EXPAND")
	self._panel_sizer:add(trigger_cbs_sizer, 0, 0, "EXPAND")

	local text_prop = 1
	local ctrl_prop = 3
	local actions_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Actions")
	local action_sizer = EWS:BoxSizer("HORIZONTAL")

	action_sizer:add(EWS:StaticText(self._panel, "Action:", 0, ""), text_prop, 0, "ALIGN_CENTER_VERTICAL")

	local actions = EWS:ComboBox(self._panel, "", "", "CB_DROPDOWN,CB_READONLY")

	action_sizer:add(actions, ctrl_prop, 0, "EXPAND")
	actions_sizer:add(action_sizer, 0, 0, "EXPAND")

	local action_types_sizer = EWS:BoxSizer("HORIZONTAL")

	action_types_sizer:add(EWS:StaticText(self._panel, "Types:", 0, ""), text_prop, 0, "ALIGN_CENTER_VERTICAL")

	local action_types = EWS:ComboBox(self._panel, "", "", "CB_DROPDOWN,CB_READONLY")

	action_types_sizer:add(action_types, ctrl_prop, 0, "EXPAND")
	action_types:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_action_type"), action_types)
	actions_sizer:add(action_types_sizer, 0, 0, "EXPAND")

	local action_delay_sizer = EWS:BoxSizer("HORIZONTAL")

	action_delay_sizer:add(EWS:StaticText(self._panel, "Delay:", 0, ""), text_prop, 0, "ALIGN_CENTER_VERTICAL")

	local action_delay = EWS:TextCtrl(self._panel, "-", "", "TE_CENTRE")

	action_delay_sizer:add(action_delay, ctrl_prop, 0, "EXPAND")
	action_delay:connect("EVT_CHAR", callback(nil, _G, "verify_number"), action_delay)
	action_delay:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		callback = "set_action_delay",
		ctrlr = action_delay
	})
	action_delay:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		callback = "set_action_delay",
		ctrlr = action_delay
	})
	actions_sizer:add(action_delay_sizer, 0, 0, "EXPAND")
	self._panel_sizer:add(actions_sizer, 0, 0, "EXPAND")

	self._actions_ctrlrs = {
		actions = actions,
		action_delay = action_delay,
		action_types = action_types
	}
	local triggers_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Triggers")
	local required_trigger_sizer = EWS:BoxSizer("HORIZONTAL")

	required_trigger_sizer:add(EWS:StaticText(self._panel, "Required:", 0, ""), text_prop, 0, "ALIGN_CENTER_VERTICAL")

	self._required_triggers = EWS:ComboBox(self._panel, "", "", "CB_DROPDOWN,CB_READONLY")

	required_trigger_sizer:add(self._required_triggers, ctrl_prop, 0, "EXPAND")
	self._required_triggers:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "required_triggers",
		ctrlr = self._required_triggers
	})
	triggers_sizer:add(required_trigger_sizer, 0, 0, "EXPAND")

	local trigger_sizer = EWS:BoxSizer("HORIZONTAL")

	trigger_sizer:add(EWS:StaticText(self._panel, "Trigger:", 0, ""), text_prop, 0, "ALIGN_CENTER_VERTICAL")

	local triggers = EWS:ComboBox(self._panel, "", "", "CB_DROPDOWN,CB_READONLY")

	trigger_sizer:add(triggers, ctrl_prop, 0, "EXPAND")
	triggers_sizer:add(trigger_sizer, 0, 0, "EXPAND")

	local trigger_types_sizer = EWS:BoxSizer("HORIZONTAL")

	trigger_types_sizer:add(EWS:StaticText(self._panel, "Types:", 0, ""), text_prop, 0, "ALIGN_CENTER_VERTICAL")

	local trigger_types = EWS:ComboBox(self._panel, "", "", "CB_DROPDOWN,CB_READONLY")

	trigger_types_sizer:add(trigger_types, ctrl_prop, 0, "EXPAND")
	trigger_types:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_trigger_type"), trigger_types)
	triggers_sizer:add(trigger_types_sizer, 0, 0, "EXPAND")
	self._panel_sizer:add(triggers_sizer, 0, 0, "EXPAND")

	self._triggers_ctrlrs = {
		triggers = triggers,
		trigger_types = trigger_types
	}

	actions:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "ews_select_action"), actions)
	triggers:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "ews_select_trigger"), triggers)
	self:set_actions()
	self:set_triggers()
	self:set_required_triggers()
end

function CoreHub:destroy()
	if self._timeline then
		self._timeline:destroy()
	end

	HubElement.destroy(self)
end
