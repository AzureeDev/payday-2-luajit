CoreOverlayEffectUnitElement = CoreOverlayEffectUnitElement or class(MissionElement)
OverlayEffectUnitElement = OverlayEffectUnitElement or class(CoreOverlayEffectUnitElement)

function OverlayEffectUnitElement:init(...)
	OverlayEffectUnitElement.super.init(self, ...)
end

function CoreOverlayEffectUnitElement:init(unit)
	CoreOverlayEffectUnitElement.super.init(self, unit)

	self._hed.effect = "none"

	table.insert(self._save_values, "effect")
	table.insert(self._save_values, "sustain")
	table.insert(self._save_values, "fade_in")
	table.insert(self._save_values, "fade_out")
end

function CoreOverlayEffectUnitElement:test_element()
	if self._hed.effect ~= "none" then
		local effect = clone(managers.overlay_effect:presets()[self._hed.effect])
		effect.sustain = self._hed.sustain or effect.sustain
		effect.fade_in = self._hed.fade_in or effect.fade_in
		effect.fade_out = self._hed.fade_out or effect.fade_out

		managers.overlay_effect:play_effect(effect)
	end
end

function CoreOverlayEffectUnitElement:stop_test_element()
	managers.overlay_effect:stop_effect()
end

function CoreOverlayEffectUnitElement:changed_effect()
	if self._hed.effect == "none" then
		self._fade_in_default:set_value("-")
		self._sustain_default:set_value("-")
		self._fade_out_default:set_value("-")
	else
		local effect = managers.overlay_effect:presets()[self._hed.effect]

		self._fade_in_default:set_value(string.format("%.2f", effect.fade_in))
		self._sustain_default:set_value(string.format("%.2f", effect.sustain))
		self._fade_out_default:set_value(string.format("%.2f", effect.fade_out))
	end
end

function CoreOverlayEffectUnitElement:set_option_time(data)
	local c = data.ctrlr
	local value = c:get_value()

	if c:get_value() == "" then
		value = nil
	else
		value = tonumber(value)

		c:change_value(string.format("%.2f", value))
		c:set_selection(-1, -1)
	end

	self._hed[data.value] = value
end

function CoreOverlayEffectUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local options = {}

	for name, _ in pairs(managers.overlay_effect:presets()) do
		table.insert(options, name)
	end

	local effect_params = {
		default = "none",
		name = "Effect:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select a preset effect for the combo box",
		sorted = true,
		panel = panel,
		sizer = panel_sizer,
		options = options,
		value = self._hed.effect
	}
	local effect = CoreEWS.combobox(effect_params)

	effect:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "effect",
		ctrlr = effect
	})
	effect:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "changed_effect"), nil)

	local fade_in_sizer = EWS:BoxSizer("HORIZONTAL")

	fade_in_sizer:add(EWS:StaticText(panel, "Fade in:", 0, ""), 2, 0, "ALIGN_CENTER_VERTICAL")

	local fade_in = EWS:TextCtrl(self._panel, self._hed.fade_in, "", "TE_PROCESS_ENTER")

	fade_in:connect("EVT_CHAR", callback(nil, _G, "verify_number"), fade_in)
	fade_in:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_option_time"), {
		value = "fade_in",
		ctrlr = fade_in
	})
	fade_in:connect("EVT_KILL_FOCUS", callback(self, self, "set_option_time"), {
		value = "fade_in",
		ctrlr = fade_in
	})
	fade_in_sizer:add(fade_in, 3, 0, "EXPAND")

	self._fade_in_default = EWS:StaticText(panel, "-", 0, "ALIGN_CENTER")

	self._fade_in_default:set_tool_tip("Default value for selected effect")
	fade_in_sizer:add(self._fade_in_default, 1, 5, "ALIGN_CENTER_VERTICAL,LEFT")
	panel_sizer:add(fade_in_sizer, 0, 0, "EXPAND")

	local sustain_sizer = EWS:BoxSizer("HORIZONTAL")

	sustain_sizer:add(EWS:StaticText(panel, "Sustain:", 0, ""), 2, 0, "ALIGN_CENTER_VERTICAL")

	local sustain = EWS:TextCtrl(self._panel, self._hed.sustain, "", "TE_PROCESS_ENTER")

	sustain:connect("EVT_CHAR", callback(nil, _G, "verify_number"), sustain)
	sustain:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_option_time"), {
		value = "sustain",
		ctrlr = sustain
	})
	sustain:connect("EVT_KILL_FOCUS", callback(self, self, "set_option_time"), {
		value = "sustain",
		ctrlr = sustain
	})
	sustain_sizer:add(sustain, 3, 0, "EXPAND")

	self._sustain_default = EWS:StaticText(panel, "-", 0, "ALIGN_CENTER")

	self._sustain_default:set_tool_tip("Default value for selected effect")
	sustain_sizer:add(self._sustain_default, 1, 5, "ALIGN_CENTER_VERTICAL,LEFT")
	panel_sizer:add(sustain_sizer, 0, 0, "EXPAND")

	local fade_out_sizer = EWS:BoxSizer("HORIZONTAL")

	fade_out_sizer:add(EWS:StaticText(panel, "Fade out:", 0, ""), 2, 0, "ALIGN_CENTER_VERTICAL")

	local fade_out = EWS:TextCtrl(self._panel, self._hed.fade_out, "", "TE_PROCESS_ENTER")

	fade_out:connect("EVT_CHAR", callback(nil, _G, "verify_number"), fade_out)
	fade_out:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_option_time"), {
		value = "fade_out",
		ctrlr = fade_out
	})
	fade_out:connect("EVT_KILL_FOCUS", callback(self, self, "set_option_time"), {
		value = "fade_out",
		ctrlr = fade_out
	})
	fade_out_sizer:add(fade_out, 3, 0, "EXPAND")

	self._fade_out_default = EWS:StaticText(panel, "-", 0, "ALIGN_CENTER")

	self._fade_out_default:set_tool_tip("Default value for selected effect")
	fade_out_sizer:add(self._fade_out_default, 1, 5, "ALIGN_CENTER_VERTICAL,LEFT")
	panel_sizer:add(fade_out_sizer, 0, 0, "EXPAND")
	self:changed_effect()
end
