ObjectiveUnitElement = ObjectiveUnitElement or class(MissionElement)
ObjectiveUnitElement.INSTANCE_VAR_NAMES = {
	{
		value = "objective",
		type = "objective"
	},
	{
		value = "amount",
		type = "number"
	}
}

function ObjectiveUnitElement:init(unit)
	ObjectiveUnitElement.super.init(self, unit)

	self._hed.state = "complete_and_activate"
	self._hed.objective = "none"
	self._hed.sub_objective = "none"
	self._hed.amount = 0
	self._hed.countdown = false

	table.insert(self._save_values, "state")
	table.insert(self._save_values, "objective")
	table.insert(self._save_values, "sub_objective")
	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "countdown")
end

function ObjectiveUnitElement:update_sub_objectives()
	local sub_objectives = table.list_add({
		"none"
	}, managers.objectives:sub_objectives_by_name(self._hed.objective))
	self._hed.sub_objective = "none"

	CoreEws.update_combobox_options(self._sub_objective_params, sub_objectives)
	CoreEws.change_combobox_value(self._sub_objective_params, self._hed.sub_objective)
end

function ObjectiveUnitElement:set_element_data(params, ...)
	ObjectiveUnitElement.super.set_element_data(self, params, ...)

	if params.value == "objective" then
		self:update_sub_objectives()
	end
end

function ObjectiveUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "state", {
		"activate",
		"complete",
		"update",
		"remove",
		"complete_and_activate",
		"remove_and_activate"
	})
	self:_build_value_combobox(panel, panel_sizer, "objective", table.list_add({
		"none"
	}, managers.objectives:objectives_by_name()))

	local options = self._hed.objective ~= "none" and managers.objectives:sub_objectives_by_name(self._hed.objective) or {}
	local _, params = self:_build_value_combobox(panel, panel_sizer, "sub_objective", table.list_add({
		"none"
	}, options), "Select a sub objective from the combobox (if availible)")
	self._sub_objective_params = params

	self:_build_value_number(panel, panel_sizer, "amount", {
		min = 0,
		floats = 0,
		max = 100
	}, "Overrides objective amount counter with this value.")
	self:_build_value_checkbox(panel, panel_sizer, "countdown", "Sets whether this objective should be a countdown instead.")

	local help = {
		panel = panel,
		sizer = panel_sizer,
		text = "State complete_and_activate will complete any previous objective and activate the selected objective. Note that it might not function well with objectives using amount"
	}

	self:add_help_text(help)
end
