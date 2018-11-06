PlayerCharacterTriggerUnitElement = PlayerCharacterTriggerUnitElement or class(MissionElement)

function PlayerCharacterTriggerUnitElement:init(unit)
	PlayerCharacterTriggerUnitElement.super.init(self, unit)

	self._hed.character = tweak_data.criminals.character_names[1]
	self._hed.trigger_on_left = false

	table.insert(self._save_values, "character")
	table.insert(self._save_values, "trigger_on_left")
end

function PlayerCharacterTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "character", tweak_data.criminals.character_names, "Select a character from the combobox")

	local checkbox_leave = EWS:CheckBox(panel, "Trigger when character leaves", "")

	checkbox_leave:set_value(self._hed.trigger_on_left)
	checkbox_leave:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "trigger_on_left",
		ctrlr = checkbox_leave
	})
	panel_sizer:add(checkbox_leave, 0, 0, "EXPAND")
	self:_add_help_text("Set the character that the element should trigger on. Can alternatively fire when the character is removed from the game.")
end

PlayerCharacterFilterUnitElement = PlayerCharacterFilterUnitElement or class(MissionElement)

function PlayerCharacterFilterUnitElement:init(unit)
	PlayerCharacterFilterUnitElement.super.init(self, unit)

	self._hed.character = tweak_data.criminals.character_names[1]
	self._hed.require_presence = true
	self._hed.check_instigator = false

	table.insert(self._save_values, "character")
	table.insert(self._save_values, "require_presence")
	table.insert(self._save_values, "check_instigator")
end

function PlayerCharacterFilterUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "character", tweak_data.criminals.character_names, "Select a character from the combobox")

	local checkbox_require = EWS:CheckBox(panel, "Require character presence", "")

	checkbox_require:set_value(self._hed.require_presence)
	checkbox_require:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "require_presence",
		ctrlr = checkbox_require
	})
	panel_sizer:add(checkbox_require, 0, 0, "EXPAND")

	local checkbox_instigator = EWS:CheckBox(panel, "Check instigator character", "")

	checkbox_instigator:set_value(self._hed.check_instigator)
	checkbox_instigator:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "check_instigator",
		ctrlr = checkbox_instigator
	})
	panel_sizer:add(checkbox_instigator, 0, 0, "EXPAND")
	self:_add_help_text("Will only execute if the character is/is not in the game.")
end
