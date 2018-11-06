DialogueUnitElement = DialogueUnitElement or class(MissionElement)
DialogueUnitElement.SAVE_UNIT_POSITION = false
DialogueUnitElement.SAVE_UNIT_ROTATION = false

function DialogueUnitElement:init(unit)
	DialogueUnitElement.super.init(self, unit)

	self._hed.dialogue = "none"
	self._hed.execute_on_executed_when_done = false
	self._hed.use_position = false
	self._hed.force_quit_current = nil
	self._hed.use_instigator = false
	self._hed.can_not_be_muted = false
	self._hed.play_on_player_instigator_only = false

	table.insert(self._save_values, "dialogue")
	table.insert(self._save_values, "execute_on_executed_when_done")
	table.insert(self._save_values, "use_position")
	table.insert(self._save_values, "force_quit_current")
	table.insert(self._save_values, "use_instigator")
	table.insert(self._save_values, "can_not_be_muted")
	table.insert(self._save_values, "play_on_player_instigator_only")
end

function DialogueUnitElement:new_save_values(...)
	local t = DialogueUnitElement.super.new_save_values(self, ...)
	t.position = self._hed.use_position and self._unit:position() or nil

	return t
end

function DialogueUnitElement:test_element()
	if self._hed.dialogue == "none" then
		return
	end

	managers.dialog:quit_dialog()
	managers.dialog:queue_dialog(self._hed.dialogue, {
		skip_idle_check = true,
		case = "russian",
		on_unit = self._unit
	})
	managers.editor:set_wanted_mute(false)
	managers.editor:set_listener_enabled(true)
end

function DialogueUnitElement:stop_test_element()
	managers.dialog:quit_dialog()
	managers.editor:set_wanted_mute(true)
	managers.editor:set_listener_enabled(false)
end

function DialogueUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "dialogue", table.list_add({
		"none"
	}, managers.dialog:conversation_names()), "Select a dialogue from the combobox")
	self:_build_value_checkbox(panel, panel_sizer, "force_quit_current", "Force quits current dialog to allow this to be played immediately")
	self:_build_value_checkbox(panel, panel_sizer, "execute_on_executed_when_done", "Execute on executed when done")
	self:_build_value_checkbox(panel, panel_sizer, "use_position")
	self:_build_value_checkbox(panel, panel_sizer, "use_instigator", "Play on instigator")
	self:_build_value_checkbox(panel, panel_sizer, "can_not_be_muted", "This dialogue will play regardless of if the player has disabled contractor VO")
	self:_build_value_checkbox(panel, panel_sizer, "play_on_player_instigator_only", "This dialogue will only play on the player that triggers it")
end
