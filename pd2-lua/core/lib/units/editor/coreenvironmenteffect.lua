CoreEnvironmentEffectHubElement = CoreEnvironmentEffectHubElement or class(HubElement)
EnvironmentEffectHubElement = EnvironmentEffectHubElement or class(CoreEnvironmentEffectHubElement)

function EnvironmentEffectHubElement:init(...)
	CoreEnvironmentEffectHubElement.init(self, ...)
end

function CoreEnvironmentEffectHubElement:init(unit)
	HubElement.init(self, unit)

	self._hed.environment_effect = "none"

	table.insert(self._save_values, "environment_effect")
	table.insert(self._hed.action_types, "use")
	table.insert(self._hed.action_types, "stop")
end

function CoreEnvironmentEffectHubElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local effect_sizer = EWS:BoxSizer("HORIZONTAL")

	effect_sizer:add(EWS:StaticText(self._panel, "Effect:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local effects = EWS:ComboBox(self._panel, "", "", "CB_DROPDOWN,CB_READONLY")

	effects:append("none")

	for _, name in ipairs(managers.environment_effects:effects_names()) do
		effects:append(name)
	end

	effects:set_value(self._hed.environment_effect)
	effects:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "environment_effect",
		ctrlr = effects
	})
	effect_sizer:add(effects, 3, 0, "EXPAND")
	self._panel_sizer:add(effect_sizer, 0, 0, "EXPAND")
end
