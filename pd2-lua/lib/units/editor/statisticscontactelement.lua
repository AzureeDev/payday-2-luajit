StatisticsContactElement = StatisticsContactElement or class(MissionElement)
StatisticsContactElement.SAVE_UNIT_POSITION = false
StatisticsContactElement.SAVE_UNIT_ROTATION = false

function StatisticsContactElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.contact = "bain"
	self._hed.state = "completed"
	self._hed.difficulty = "all"
	self._hed.include_dropin = false
	self._hed.required = 1

	table.insert(self._save_values, "contact")
	table.insert(self._save_values, "state")
	table.insert(self._save_values, "difficulty")
	table.insert(self._save_values, "include_dropin")
	table.insert(self._save_values, "required")
end

function StatisticsContactElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local contact_list = {}

	for contact, _ in pairs(tweak_data.narrative.contacts) do
		if contact ~= "wip" and contact ~= "tests" then
			table.insert(contact_list, contact)
		end
	end

	table.sort(contact_list)
	self:_build_value_combobox(panel, panel_sizer, "contact", contact_list, "Select the required contact")

	local states = {
		"started",
		"started_dropin",
		"completed",
		"completed_dropin",
		"failed",
		"failed_dropin"
	}

	self:_build_value_combobox(panel, panel_sizer, "state", states, "Select the required play state.")

	local difficulties = deep_clone(tweak_data.difficulties)

	table.insert(difficulties, "all")
	self:_build_value_combobox(panel, panel_sizer, "difficulty", difficulties, "Select the required difficulty.")
	self:_build_value_checkbox(panel, panel_sizer, "include_dropin", "Select if drop-in is counted as well.")
	self:_build_value_number(panel, panel_sizer, "required", {
		floats = 0,
		min = 1
	}, "Type the required amount that is needed.")
end
