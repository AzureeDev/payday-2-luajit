MoneyUnitElement = MoneyUnitElement or class(MissionElement)
MoneyUnitElement.actions = {
	"none",
	"AddOffshore",
	"DeductOffshore",
	"AddSpending",
	"DeductSpending"
}

function MoneyUnitElement:init(unit)
	MoneyUnitElement.super.init(self, unit)

	self._hed.action = "none"
	self._hed.amount = 0
	self._hed.remove_all = false
	self._hed.only_local_player = true

	table.insert(self._save_values, "action")
	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "remove_all")
	table.insert(self._save_values, "only_local_player")
end

function MoneyUnitElement:toggle_local_only()
	self._hed.only_local_player = self._toggle_local:get_value()
end

function MoneyUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "action", MoneyUnitElement.actions, "Action")
	self:_build_value_number(panel, panel_sizer, "amount", {
		floats = false
	}, nil, "Amount")

	self._toggle_local = EWS:CheckBox(panel, "Execute only if local player is instigator")

	self._toggle_local:connect("EVT_COMMAND_CHECKBOX_CLICKED", CoreEvent.callback(self, self, "toggle_local_only"))
	panel_sizer:add(self._toggle_local, 0, 1, "EXPAND,LEFT")
	self._toggle_local:set_value(self._hed.only_local_player)
	self:_build_value_checkbox(panel, panel_sizer, "remove_all", "Remove all spending/offshore if deducting.", "Remove all when deducting.")

	local help = {
		text = "Used to add or deduct money from the player's spending cash or offshore account.\nEnable \"only if local player is instigator\" if the player activates this, instead of a mission script. ie. offshore gambling",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end

FilterMoneyUnitElement = FilterMoneyUnitElement or class(MissionElement)

function FilterMoneyUnitElement:init(unit)
	FilterMoneyUnitElement.super.init(self, unit)

	self._hed.value = 0
	self._hed.account = "offshore"
	self._hed.check_type = "equal"
	self._hed.only_local_player = true

	table.insert(self._save_values, "value")
	table.insert(self._save_values, "account")
	table.insert(self._save_values, "check_type")
	table.insert(self._save_values, "only_local_player")
end

function FilterMoneyUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "value", {
		floats = 0
	}, "Specify cash value to trigger on.")
	self:_build_value_combobox(panel, panel_sizer, "account", {
		"offshore",
		"spending"
	}, "Select which account to check.")
	self:_build_value_combobox(panel, panel_sizer, "check_type", {
		"equal",
		"less_than",
		"greater_than",
		"less_or_equal",
		"greater_or_equal"
	}, "Select which check operation to perform")
	self:_build_value_checkbox(panel, panel_sizer, "only_local_player", "Only run if the local player is the instigator")
	self:_add_help_text("Checks that the player has the required amount of cash in their spending or offshore accounts.")
end
