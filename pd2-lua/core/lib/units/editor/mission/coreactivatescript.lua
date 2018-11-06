CoreActivateScriptUnitElement = CoreActivateScriptUnitElement or class(MissionElement)
ActivateScriptUnitElement = ActivateScriptUnitElement or class(CoreActivateScriptUnitElement)

function ActivateScriptUnitElement:init(...)
	CoreActivateScriptUnitElement.init(self, ...)
end

function CoreActivateScriptUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.activate_script = "none"

	table.insert(self._save_values, "activate_script")
end

function CoreActivateScriptUnitElement:selected()
	MissionElement.selected(self)
	CoreEWS.update_combobox_options(self._script_params, self:_scripts())

	if self._hed.activate_script ~= "none" and not table.contains(self:_scripts(), self._hed.activate_script) then
		self._hed.activate_script = "none"
	end

	CoreEWS.change_combobox_value(self._script_params, self._hed.activate_script)
end

function CoreActivateScriptUnitElement:_scripts()
	return managers.editor:layer("Mission"):script_names()
end

function CoreActivateScriptUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	self._script_params = {
		default = "none",
		name = "Script:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select a script from the combobox",
		sorted = true,
		panel = panel,
		sizer = panel_sizer,
		options = self:_scripts(),
		value = self._hed.activate_script
	}
	local scripts = CoreEWS.combobox(self._script_params)

	scripts:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "activate_script",
		ctrlr = scripts
	})
end
