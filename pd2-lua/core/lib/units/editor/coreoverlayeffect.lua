CoreOverlayEffectHubElement = CoreOverlayEffectHubElement or class(HubElement)
OverlayEffectHubElement = OverlayEffectHubElement or class(CoreOverlayEffectHubElement)

function OverlayEffectHubElement:init(...)
	CoreOverlayEffectHubElement.init(self, ...)
end

function CoreOverlayEffectHubElement:init(unit)
	HubElement.init(self, unit)

	self._hed.overlay_effect = "none"

	table.insert(self._save_values, "overlay_effect")
	table.insert(self._save_values, "overlay_effect_sustain")
	table.insert(self._save_values, "overlay_effect_fade_in")
	table.insert(self._save_values, "overlay_effect_fade_out")
end

function CoreOverlayEffectHubElement:test_element()
	if self._hed.overlay_effect ~= "none" then
		local effect = clone(managers.overlay_effect:presets()[self._hed.overlay_effect])
		effect.sustain = self._hed.overlay_effect_sustain or effect.sustain
		effect.fade_in = self._hed.overlay_effect_fade_in or effect.fade_in
		effect.fade_out = self._hed.overlay_effect_fade_out or effect.fade_out

		managers.overlay_effect:play_effect(effect)
	end
end

function CoreOverlayEffectHubElement:stop_test_element()
	managers.overlay_effect:stop_effect()
end

function CoreOverlayEffectHubElement:changed_effect()
	if self._hed.overlay_effect == "none" then
		self._fade_in_default:set_value("-")
		self._sustain_default:set_value("-")
		self._fade_out_default:set_value("-")
	else
		local effect = managers.overlay_effect:presets()[self._hed.overlay_effect]

		self._fade_in_default:set_value(string.format("%.2f", effect.fade_in))
		self._sustain_default:set_value(string.format("%.2f", effect.sustain))
		self._fade_out_default:set_value(string.format("%.2f", effect.fade_out))
	end
end

function CoreOverlayEffectHubElement:set_option_time(data)
	local c = data.ctrlr
	local value = c:get_value()

	if c:get_value() == "" then
		value = nil
	else
		value = tonumber(value)
	end

	self._hed[data.value] = value
end

function CoreOverlayEffectHubElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local effects_sizer = EWS:BoxSizer("HORIZONTAL")

	effects_sizer:add(EWS:StaticText(panel, "Effect:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local effects = EWS:ComboBox(panel, "", "", "CB_DROPDOWN,CB_READONLY")

	effects:append("none")

	local t = {}

	for name, _ in pairs(managers.overlay_effect:presets()) do
		table.insert(t, name)
	end

	table.sort(t)

	for _, name in ipairs(t) do
		effects:append(name)
	end

	effects:set_value(self._hed.overlay_effect)
	effects_sizer:add(effects, 2, 0, "EXPAND")
	effects:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "overlay_effect",
		ctrlr = effects
	})
	effects:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "changed_effect"), nil)
	panel_sizer:add(effects_sizer, 0, 0, "EXPAND")

	local fade_in_sizer = EWS:BoxSizer("HORIZONTAL")

	fade_in_sizer:add(EWS:StaticText(panel, "Fade in:", 0, ""), 2, 0, "ALIGN_CENTER_VERTICAL")

	local fade_in = EWS:TextCtrl(self._panel, self._hed.overlay_effect_fade_in, "", "TE_PROCESS_ENTER")

	fade_in:connect("EVT_CHAR", callback(nil, _G, "verify_number"), fade_in)
	fade_in:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_option_time"), {
		value = "overlay_effect_fade_in",
		ctrlr = fade_in
	})
	fade_in:connect("EVT_KILL_FOCUS", callback(self, self, "set_option_time"), {
		value = "overlay_effect_fade_in",
		ctrlr = fade_in
	})
	fade_in_sizer:add(fade_in, 3, 0, "EXPAND")

	self._fade_in_default = EWS:StaticText(panel, "-", 0, "ALIGN_CENTER")

	self._fade_in_default:set_tool_tip("Default value for selected effect")
	fade_in_sizer:add(self._fade_in_default, 1, 5, "ALIGN_CENTER_VERTICAL,LEFT")
	panel_sizer:add(fade_in_sizer, 0, 0, "EXPAND")

	local sustain_sizer = EWS:BoxSizer("HORIZONTAL")

	sustain_sizer:add(EWS:StaticText(panel, "Sustain:", 0, ""), 2, 0, "ALIGN_CENTER_VERTICAL")

	local sustain = EWS:TextCtrl(self._panel, self._hed.overlay_effect_sustain, "", "TE_PROCESS_ENTER")

	sustain:connect("EVT_CHAR", callback(nil, _G, "verify_number"), sustain)
	sustain:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_option_time"), {
		value = "overlay_effect_sustain",
		ctrlr = sustain
	})
	sustain:connect("EVT_KILL_FOCUS", callback(self, self, "set_option_time"), {
		value = "overlay_effect_sustain",
		ctrlr = sustain
	})
	sustain_sizer:add(sustain, 3, 0, "EXPAND")

	self._sustain_default = EWS:StaticText(panel, "-", 0, "ALIGN_CENTER")

	self._sustain_default:set_tool_tip("Default value for selected effect")
	sustain_sizer:add(self._sustain_default, 1, 5, "ALIGN_CENTER_VERTICAL,LEFT")
	panel_sizer:add(sustain_sizer, 0, 0, "EXPAND")

	local fade_out_sizer = EWS:BoxSizer("HORIZONTAL")

	fade_out_sizer:add(EWS:StaticText(panel, "Fade out:", 0, ""), 2, 0, "ALIGN_CENTER_VERTICAL")

	local fade_out = EWS:TextCtrl(self._panel, self._hed.overlay_effect_fade_out, "", "TE_PROCESS_ENTER")

	fade_out:connect("EVT_CHAR", callback(nil, _G, "verify_number"), fade_out)
	fade_out:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_option_time"), {
		value = "overlay_effect_fade_out",
		ctrlr = fade_out
	})
	fade_out:connect("EVT_KILL_FOCUS", callback(self, self, "set_option_time"), {
		value = "overlay_effect_fade_out",
		ctrlr = fade_out
	})
	fade_out_sizer:add(fade_out, 3, 0, "EXPAND")

	self._fade_out_default = EWS:StaticText(panel, "-", 0, "ALIGN_CENTER")

	self._fade_out_default:set_tool_tip("Default value for selected effect")
	fade_out_sizer:add(self._fade_out_default, 1, 5, "ALIGN_CENTER_VERTICAL,LEFT")
	panel_sizer:add(fade_out_sizer, 0, 0, "EXPAND")
	self:changed_effect()
end
