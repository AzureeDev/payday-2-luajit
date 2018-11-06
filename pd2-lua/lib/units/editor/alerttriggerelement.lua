AlertTriggerElement = AlertTriggerElement or class(MissionElement)

function AlertTriggerElement:init(unit)
	AlertTriggerElement.super.init(self, unit)

	self._hed.filter = "0"
	self._hed.alert_types = {}

	table.insert(self._save_values, "filter")
	table.insert(self._save_values, "alert_types")
end

function AlertTriggerElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local opt_sizer = panel_sizer
	local alert_type_sizer = EWS:BoxSizer("VERTICAL")
	local alert_type_table = {
		"footstep",
		"vo_ntl",
		"vo_cbt",
		"vo_intimidate",
		"vo_distress",
		"bullet",
		"aggression",
		"explosion"
	}
	self._alert_type_check_boxes = {}

	for i, o in ipairs(alert_type_table) do
		local check = EWS:CheckBox(panel, o, "")

		check:set_value(table.contains(self._hed.alert_types, o))
		check:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "on_alert_type_checkbox_changed"), {
			ctrlr = check,
			name = o
		})

		self._alert_type_check_boxes[o] = check

		alert_type_sizer:add(check, 0, 0, "EXPAND")
	end

	opt_sizer:add(alert_type_sizer, 1, 0, "EXPAND")

	local filter_preset_params = {
		sorted = true,
		name = "Preset:",
		name_proportions = 1,
		ctrlr_proportions = 2,
		tooltip = "Select a preset.",
		panel = panel,
		sizer = opt_sizer,
		options = {
			"clear",
			"all"
		}
	}
	local filter_preset = CoreEWS.combobox(filter_preset_params)

	filter_preset:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "apply_preset"), {
		ctrlr = filter_preset
	})

	local filter_sizer = EWS:BoxSizer("HORIZONTAL")
	local opt1_sizer = EWS:BoxSizer("VERTICAL")
	local opt2_sizer = EWS:BoxSizer("VERTICAL")
	local opt3_sizer = EWS:BoxSizer("VERTICAL")
	local opt = NavigationManager.ACCESS_FLAGS
	local filter_table = managers.navigation:convert_access_filter_to_table(self._hed.filter)
	self._filter_check_boxes = {}

	for i, o in ipairs(opt) do
		local check = EWS:CheckBox(panel, o, "")

		check:set_value(table.contains(filter_table, o))
		check:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "on_filter_checkbox_changed"), {
			ctrlr = check,
			name = o
		})

		self._filter_check_boxes[o] = check

		if i <= math.round(#opt / 3) then
			opt1_sizer:add(check, 0, 0, "EXPAND")
		elseif i <= math.round(#opt / 3) * 2 then
			opt2_sizer:add(check, 0, 0, "EXPAND")
		else
			opt3_sizer:add(check, 0, 0, "EXPAND")
		end
	end

	filter_sizer:add(opt1_sizer, 1, 0, "EXPAND")
	filter_sizer:add(opt2_sizer, 1, 0, "EXPAND")
	filter_sizer:add(opt3_sizer, 1, 0, "EXPAND")
	opt_sizer:add(filter_sizer, 1, 0, "EXPAND")
end

function AlertTriggerElement:apply_preset(params)
	local value = params.ctrlr:get_value()
	local confirm = EWS:message_box(Global.frame_panel, "Apply preset " .. value .. "?", "Alert Trigger", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	if value == "clear" then
		self:_set_filter_none()
	elseif value == "all" then
		self:_set_filter_all()
	else
		print("Didn't have preset", value, "yet.")
	end
end

function AlertTriggerElement:_set_filter_all()
	for name, ctrlr in pairs(self._filter_check_boxes) do
		ctrlr:set_value(true)
	end

	self._hed.filter = managers.navigation:convert_access_filter_to_string(managers.navigation.ACCESS_FLAGS)
end

function AlertTriggerElement:_set_filter_none()
	for name, ctrlr in pairs(self._filter_check_boxes) do
		ctrlr:set_value(false)
	end

	self._hed.filter = "0"
end

function AlertTriggerElement:on_filter_checkbox_changed(params)
	local filter_table = managers.navigation:convert_access_filter_to_table(self._hed.filter)
	local value = params.ctrlr:get_value()

	if value then
		if table.contains(filter_table, params.name) then
			return
		end

		table.insert(filter_table, params.name)
	else
		table.delete(filter_table, params.name)
	end

	self._hed.filter = managers.navigation:convert_access_filter_to_string(filter_table)
	local filter = managers.navigation:convert_access_filter_to_number(self._hed.filter)
end

function AlertTriggerElement:on_alert_type_checkbox_changed(params)
	local value = params.ctrlr:get_value()

	if value then
		if table.contains(self._hed.alert_types, params.name) then
			return
		end

		table.insert(self._hed.alert_types, params.name)
	else
		table.delete(self._hed.alert_types, params.name)
	end
end
