CoreRumbleHubElement = CoreRumbleHubElement or class(HubElement)
RumbleHubElement = RumbleHubElement or class(CoreRumbleHubElement)

function RumbleHubElement:init(...)
	CoreRumbleHubElement.init(self, ...)
end

function CoreRumbleHubElement:init(unit)
	HubElement.init(self, unit)

	self._hed.rumble_engine = "both"
	self._hed.rumble_peak = 1
	self._hed.rumble_attack = 1
	self._hed.rumble_sustain = 2
	self._hed.rumble_release = 1

	table.insert(self._save_values, "rumble_engine")
	table.insert(self._save_values, "rumble_peak")
	table.insert(self._save_values, "rumble_attack")
	table.insert(self._save_values, "rumble_sustain")
	table.insert(self._save_values, "rumble_release")
end

function CoreRumbleHubElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local rumble_sizer = EWS:BoxSizer("HORIZONTAL")
	local ctrlr_sizer = EWS:BoxSizer("VERTICAL")
	local engines_sizer = EWS:BoxSizer("HORIZONTAL")

	engines_sizer:add(EWS:StaticText(panel, "Engine", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL,EXPAND")

	local engines = EWS:ComboBox(panel, "", "", "CB_DROPDOWN,CB_READONLY")

	for _, engine in ipairs({
		"both",
		"left",
		"right"
	}) do
		engines:append(engine)
	end

	engines:set_value(self._hed.rumble_engine)
	engines_sizer:add(engines, 2, 0, "EXPAND")
	engines:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "rumble_engine",
		ctrlr = engines
	})
	ctrlr_sizer:add(engines_sizer, 0, 0, "EXPAND")

	local peak_sizer = EWS:BoxSizer("HORIZONTAL")

	peak_sizer:add(EWS:StaticText(panel, "Peak", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL,EXPAND")
	peak_sizer:add(EWS:StaticText(panel, "[0-1]", 0, ""), 0, 0, "ALIGN_CENTER_VERTICAL")

	local peak = EWS:TextCtrl(panel, "1.0", "pulla", "TE_CENTRE")

	peak:set_value(self._hed.rumble_peak)
	peak_sizer:add(peak, 2, 0, "EXPAND")
	peak:connect("EVT_CHAR", callback(nil, _G, "verify_number"), peak)
	peak:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "set_element_data"), {
		value = "rumble_peak",
		ctrlr = peak
	})
	ctrlr_sizer:add(peak_sizer, 0, 0, "EXPAND")

	local attack_sizer = EWS:BoxSizer("HORIZONTAL")

	attack_sizer:add(EWS:StaticText(panel, "Attack", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL,EXPAND")
	attack_sizer:add(EWS:StaticText(panel, "[sec]", 0, ""), 0, 0, "ALIGN_CENTER_VERTICAL")

	local attack = EWS:TextCtrl(panel, "1.0", "", "TE_CENTRE")

	attack:set_value(self._hed.rumble_attack)
	attack_sizer:add(attack, 2, 0, "EXPAND")
	attack:connect("EVT_CHAR", callback(nil, _G, "verify_number"), attack)
	attack:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "set_element_data"), {
		value = "rumble_attack",
		ctrlr = attack
	})
	ctrlr_sizer:add(attack_sizer, 0, 0, "EXPAND")

	local sustain_sizer = EWS:BoxSizer("HORIZONTAL")

	sustain_sizer:add(EWS:StaticText(panel, "Sustain", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL,EXPAND")
	sustain_sizer:add(EWS:StaticText(panel, "[sec]", 0, ""), 0, 0, "ALIGN_CENTER_VERTICAL")

	local sustain = EWS:TextCtrl(panel, "1.0", "", "TE_CENTRE")

	sustain:set_value(self._hed.rumble_sustain)
	sustain_sizer:add(sustain, 2, 0, "EXPAND")
	sustain:connect("EVT_CHAR", callback(nil, _G, "verify_number"), sustain)
	sustain:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "set_element_data"), {
		value = "rumble_sustain",
		ctrlr = sustain
	})
	ctrlr_sizer:add(sustain_sizer, 0, 0, "EXPAND")

	local release_sizer = EWS:BoxSizer("HORIZONTAL")

	release_sizer:add(EWS:StaticText(panel, "Release", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL,EXPAND")
	release_sizer:add(EWS:StaticText(panel, "[sec]", 0, ""), 0, 0, "ALIGN_CENTER_VERTICAL")

	local release = EWS:TextCtrl(panel, "1.0", "", "TE_CENTRE")

	release:set_value(self._hed.rumble_release)
	release_sizer:add(release, 2, 0, "EXPAND")
	release:connect("EVT_CHAR", callback(nil, _G, "verify_number"), release)
	release:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "set_element_data"), {
		value = "rumble_release",
		ctrlr = release
	})
	ctrlr_sizer:add(release_sizer, 0, 0, "EXPAND")
	rumble_sizer:add(ctrlr_sizer, 2, 0, "EXPAND")
	panel_sizer:add(rumble_sizer, 0, 0, "EXPAND")
end
