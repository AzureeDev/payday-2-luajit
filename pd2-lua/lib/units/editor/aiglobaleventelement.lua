AiGlobalEventUnitElement = AiGlobalEventUnitElement or class(MissionElement)

function AiGlobalEventUnitElement:init(unit)
	AiGlobalEventUnitElement.super.init(self, unit)

	self._hed.blame = "none"

	table.insert(self._save_values, "wave_mode")
	table.insert(self._save_values, "AI_event")
	table.insert(self._save_values, "blame")
end

function AiGlobalEventUnitElement:post_init(...)
	AiGlobalEventUnitElement.super.post_init(self, ...)

	if self._hed.event then
		self._hed.wave_mode = self._hed.event
		self._hed.event = nil
	end
end

function AiGlobalEventUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "wave_mode", ElementAiGlobalEvent._wave_modes)
	self:_build_value_combobox(panel, panel_sizer, "AI_event", ElementAiGlobalEvent._AI_events)
	self:_build_value_combobox(panel, panel_sizer, "blame", ElementAiGlobalEvent._blames)
end
