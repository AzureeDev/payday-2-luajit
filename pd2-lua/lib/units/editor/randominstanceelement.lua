RandomInstanceElement = RandomInstanceElement or class(MissionElement)
RandomInstanceElement.SAVE_UNIT_POSITION = false
RandomInstanceElement.SAVE_UNIT_ROTATION = false
RandomInstanceElement.LINK_ELEMENTS = {
	"instances"
}
RandomInstanceElement._type = "input"

function RandomInstanceElement:init(unit)
	RandomInstanceElement.super.init(self, unit)

	self._hed.amount = 1
	self._hed.amount_random = 0
	self._hed.instances = {}
	self._hed.unique_instance = false

	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "amount_random")
	table.insert(self._save_values, "instances")
	table.insert(self._save_values, "unique_instance")
end

function RandomInstanceElement:update_editing(t, dt)
	local instance_name = self:_instance_name_raycast()

	if instance_name then
		self:_draw_instance_link(t, dt, instance_name)
	end
end

function RandomInstanceElement:draw_links_selected(t, dt, selected_unit)
	RandomInstanceElement.super.draw_links_selected(self, t, dt, selected_unit)

	local instance_layer = managers.editor:layer("Instances")

	for i, instance_data in ipairs(self._hed.instances) do
		local inst_data = managers.world_instance:get_instance_data_by_name(instance_data.instance)

		if inst_data then
			self:_draw_instance_link(t, dt, instance_data.instance)
		else
			table.remove(self._hed.instances, i)
		end
	end
end

function RandomInstanceElement:draw_links_unselected(t, dt, selected_unit)
end

function RandomInstanceElement:_draw_instance_link(t, dt, instance_name, color_multiplier)
	local r, g, b = self:get_link_color()

	if color_multiplier then
		r = r * color_multiplier
		g = g * color_multiplier
		b = b * color_multiplier
	end

	managers.editor:layer("Instances"):external_draw_instance(t, dt, instance_name, r, g, b)

	local instance_data = managers.world_instance:get_instance_data_by_name(instance_name)

	if instance_data then
		if self._type == "input" then
			Application:draw_arrow(self._unit:position(), instance_data.position, r, g, b, 0.2)
		else
			Application:draw_arrow(instance_data.position, self._unit:position(), r, g, b, 0.2)
		end
	end
end

function RandomInstanceElement:_instance_name_raycast()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		skip_instance_check = true,
		mask = 1
	})

	if not ray or not ray.unit then
		return nil
	end

	local instance_name = ray.unit:unit_data().instance

	if not instance_name then
		return nil
	end

	local instance_data = managers.world_instance:get_instance_data_by_name(instance_name)

	return instance_data and instance_data.script == self._unit:mission_element_data().script and instance_name or nil
end

function RandomInstanceElement:has_element(instance_name)
	for i, instance_data in ipairs(self._hed.instances) do
		if instance_data.instance == instance_name then
			return true
		end
	end

	return false
end

function RandomInstanceElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})
	local instance_name = ray and ray.unit and ray.unit:unit_data().instance

	if instance_name then
		if not self:has_element(instance_name) then
			self:insert_element(instance_name)
		else
			self:remove_element(instance_name)
		end
	end
end

function RandomInstanceElement:insert_element(instance_name)
	local data = {
		event = "",
		instance = instance_name
	}

	self:add_link_element("instances", data)
	self:_add_instance_item(data)
end

function RandomInstanceElement:remove_element(instance_name)
	for i, instance_data in ipairs(self._hed.instances) do
		if instance_data.instance == instance_name then
			self:remove_link_element("instances", instance_data)
			self:_remove_instance_item(i)

			return
		end
	end
end

function RandomInstanceElement:on_instance_changed_name(old_name, new_name)
	for i, instance_data in ipairs(self._hed.instances) do
		if instance_data.instance == old_name then
			instance_data.instance = new_name
		end
	end
end

function RandomInstanceElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function RandomInstanceElement:_add_counter_filter(unit)
	return unit:name() == Idstring("core/units/mission_elements/logic_counter/logic_counter")
end

function RandomInstanceElement:_set_counter_id(unit)
	self._hed.counter_id = unit:unit_data().unit_id
end

function RandomInstanceElement:_remove_counter_filter(unit)
	return self._hed.counter_id == unit:unit_data().unit_id
end

function RandomInstanceElement:_remove_counter_id(unit)
	self._hed.counter_id = nil
end

function RandomInstanceElement:_on_gui_select_instance_list()
	local settings = {
		list_style = "LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING"
	}
	local names = managers.world_instance:instance_names_by_script(self._unit:mission_element_data().script)
	local dialog = SelectNameModal:new("Select instances", names, settings)

	if dialog:cancelled() then
		return
	end

	for _, instance_name in ipairs(dialog:_selected_item_assets()) do
		self:insert_element(instance_name)
	end
end

function RandomInstanceElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local btn_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	btn_toolbar:add_tool("SELECT_UNIT_LIST", "Select unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	btn_toolbar:connect("SELECT_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_select_instance_list"), nil)
	btn_toolbar:realize()
	panel_sizer:add(btn_toolbar, 0, 1, "EXPAND,LEFT")
	self:_build_value_number(panel, panel_sizer, "amount", {
		floats = 0,
		min = 1
	}, "Specifies the amount of instances to be executed")
	self:_build_value_number(panel, panel_sizer, "amount_random", {
		floats = 0,
		min = 0
	}, "Add a random amount to amount")
	self:_build_value_checkbox(panel, panel_sizer, "unique_instance", "Always pick an instance that hasn't been selected yet until all instances have been selected", "Pick Unique Instances")
	self:_add_help_text("Use 'Amount' only to specify an exact amount of instances to execute. Use 'Amount Random' to add a random amount to 'Amount' ('Amount' + random('Amount Random').")
	self._panel:layout()

	self._gui_items = self._gui_items or {}

	for i, instance_data in ipairs(self._hed.instances) do
		self:_add_instance_item(instance_data)
	end
end

function RandomInstanceElement:_get_events(instance_name)
	if self._type == "input" then
		return managers.world_instance:get_mission_inputs_by_name(instance_name)
	else
		return managers.world_instance:get_mission_outputs_by_name(instance_name)
	end
end

function RandomInstanceElement:_add_instance_item(data)
	local panel = self._panel
	local panel_sizer = self._panel_sizer
	local unit_id = EWS:StaticText(self._panel, data.instance, 0, "")

	self._panel_sizer:add(unit_id, 0, 0, "EXPAND")

	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(h_sizer, 0, 1, "EXPAND,LEFT")

	local event_params = {
		name = "Event:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		sizer_proportions = 1,
		tooltip = "Select an instance event from the combobox",
		sorted = true,
		panel = panel,
		sizer = h_sizer,
		options = self:_get_events(data.instance),
		default = data.event or "none",
		value = data.event or "none"
	}
	local event, text = CoreEws.combobox(event_params)

	event:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_on_set_instance_event"), {
		event = event,
		data = data
	})

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("SELECT", "Remove", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	toolbar:connect("SELECT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_element"), data.instance)
	toolbar:realize()
	h_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
	self._panel:layout()
	table.insert(self._gui_items, {
		event = event,
		unit_id = unit_id,
		toolbar = toolbar,
		text = text
	})

	return #self._gui_items
end

function RandomInstanceElement:_on_set_instance_event(data)
	local event_combo = data.event
	data.data.event = event_combo:get_value()
end

function RandomInstanceElement:_remove_instance_item(idx)
	if self._gui_items[idx] then
		self._gui_items[idx].event:destroy()
		self._gui_items[idx].unit_id:destroy()
		self._gui_items[idx].toolbar:destroy()
		self._gui_items[idx].text:destroy()
		table.remove(self._gui_items, idx)
	end

	self._panel:layout()
end

RandomInstanceElementInputEvent = RandomInstanceElementInputEvent or class(RandomInstanceElement)
RandomInstanceElementInputEvent._type = "input"
RandomInstanceElementOutputEvent = RandomInstanceElementOutputEvent or class(RandomInstanceElement)
RandomInstanceElementOutputEvent._type = "output"
