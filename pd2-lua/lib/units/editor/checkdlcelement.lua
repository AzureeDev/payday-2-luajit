CheckDLCUnitElement = CheckDLCUnitElement or class(MissionElement)

function CheckDLCUnitElement:init(unit)
	CheckDLCUnitElement.super.init(self, unit)

	self._hed.dlc_ids = {}
	self._hed.require_all = false
	self._hed.invert = false

	table.insert(self._save_values, "dlc_ids")
	table.insert(self._save_values, "require_all")
	table.insert(self._save_values, "invert")
end

function CheckDLCUnitElement:toggle_require_all()
	self._hed.require_all = self._toggle_require_all:get_value()
end

function CheckDLCUnitElement:toggle_invert()
	self._hed.invert = self._toggle_invert:get_value()
end

function CheckDLCUnitElement:toggle_dlc(dlc_id)
	if not self._dlc_toggles[dlc_id] then
		return
	end

	if self._dlc_toggles[dlc_id]:get_value() then
		table.insert(self._hed.dlc_ids, dlc_id)
	else
		table.delete(self._hed.dlc_ids, dlc_id)
	end
end

function CheckDLCUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	panel_sizer:add(EWS:StaticText(panel, "Options", "", "ALIGN_LEFT"), 0, 0, "EXPAND")

	self._toggle_require_all = EWS:CheckBox(panel, "Require all DLCs to execute", "")

	self._toggle_require_all:connect("EVT_COMMAND_CHECKBOX_CLICKED", CoreEvent.callback(self, self, "toggle_require_all"))
	panel_sizer:add(self._toggle_require_all, 0, 1, "EXPAND,LEFT")

	if self._hed.require_all then
		self._toggle_require_all:set_value(true)
	end

	self._toggle_invert = EWS:CheckBox(panel, "Execute only if DLCs not owned", "")

	self._toggle_invert:connect("EVT_COMMAND_CHECKBOX_CLICKED", CoreEvent.callback(self, self, "toggle_invert"))
	panel_sizer:add(self._toggle_invert, 0, 1, "EXPAND,LEFT")

	if self._hed.invert then
		self._toggle_invert:set_value(true)
	end

	panel_sizer:add(EWS:StaticText(panel, "DLCs", "", "ALIGN_LEFT"), 0, 0, "EXPAND")

	local dlcs_alphabetical = {}

	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		table.insert(dlcs_alphabetical, dlc_name)
	end

	table.sort(dlcs_alphabetical, function (a, b)
		return a < b
	end)

	self._dlc_toggles = {}

	for i, dlc_name in pairs(dlcs_alphabetical) do
		local toggle = EWS:CheckBox(panel, tostring(dlc_name), "")

		toggle:connect("EVT_COMMAND_CHECKBOX_CLICKED", CoreEvent.callback(self, self, "toggle_dlc"), dlc_name)
		panel_sizer:add(toggle, 0, 1, "EXPAND,LEFT")

		self._dlc_toggles[dlc_name] = toggle

		if self._hed.dlc_ids and table.contains(self._hed.dlc_ids, dlc_name) then
			toggle:set_value(true)
		end
	end
end
