EventSideJobAwardElement = EventSideJobAwardElement or class(MissionElement)

function EventSideJobAwardElement:init(unit)
	EventSideJobAwardElement.super.init(self, unit)

	self._hed.challenge = ""
	self._hed.objective_id = ""
	self._hed.award_instigator = false
	self._hed.award_instantly = false
	self._hed.players_from_start = nil

	table.insert(self._save_values, "challenge")
	table.insert(self._save_values, "objective_id")
	table.insert(self._save_values, "award_instigator")
	table.insert(self._save_values, "award_instantly")
	table.insert(self._save_values, "players_from_start")
end

function EventSideJobAwardElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	if not self._challenge_ids then
		self._challenge_ids = {}

		for idx, challenge in pairs(tweak_data.event_jobs.collective_stats) do
			table.insert(self._challenge_ids, idx)
		end
	end

	local objectives = {
		"select a stat"
	}

	if self._hed.challenge then
		local id = self._hed.challenge
		local items = tweak_data.event_jobs.collective_stats[id]

		if items then
			objectives = {}

			for idx, objective in ipairs(items.all) do
				table.insert(objectives, objective)
			end
		end
	end

	self._challenge_box = self:_build_value_combobox(panel, panel_sizer, "challenge", self._challenge_ids, "Select a challenge from the combobox")

	self._challenge_box:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "challenge",
		ctrlr = self._challenge_box
	})

	self._objective_box = self:_build_value_combobox(panel, panel_sizer, "objective_id", objectives, "Select a challenge objective from the combobox")

	self._objective_box:set_value(self._hed.objective_id)
	self:_build_value_checkbox(panel, panel_sizer, "award_instigator", "Award only the instigator (Player or driver in vehicle)?")
	self:_build_value_checkbox(panel, panel_sizer, "award_instantly", "Award now (Else award at end of mission)")
	self:_build_value_checkbox(panel, panel_sizer, "players_from_start", "Only award to players that joined from start.")
	self:_add_help_text("Awards a weapon-part objective from the Gage Spec Ops (Tango) DLC.")
end

function EventSideJobAwardElement:set_element_data(data)
	EventSideJobAwardElement.super.set_element_data(self, data)

	if data.ctrlr == self._challenge_box then
		local id = self._challenge_box:get_value()
		local items = tweak_data.event_jobs.collective_stats[id]

		self._objective_box:clear()

		for idx, objective in ipairs(items.all) do
			self._objective_box:append(objective)
		end

		self._objective_box:set_selection(0)
	end
end

EventSideJobFilterElement = EventSideJobFilterElement or class(MissionElement)

function EventSideJobFilterElement:init(unit)
	EventSideJobFilterElement.super.init(self, unit)

	self._hed.challenge = ""
	self._hed.objective_id = ""
	self._hed.check_type = "unlocked"

	table.insert(self._save_values, "challenge")
	table.insert(self._save_values, "objective_id")
	table.insert(self._save_values, "check_type")
end

function EventSideJobFilterElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	if not self._challenge_ids then
		self._challenge_ids = {}

		for idx, challenge in pairs(tweak_data.event_jobs.collective_stats) do
			table.insert(self._challenge_ids, idx)
		end
	end

	local objectives = {
		"select a stat"
	}

	if self._hed.challenge then
		local id = self._hed.challenge
		local items = tweak_data.event_jobs.collective_stats[id]

		if items then
			objectives = {}

			for idx, objective in ipairs(items.all) do
				table.insert(objectives, objective)
			end
		end
	end

	self._challenge_box = self:_build_value_combobox(panel, panel_sizer, "challenge", self._challenge_ids, "Select a challenge from the combobox")

	self._challenge_box:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "challenge",
		ctrlr = self._challenge_box
	})

	self._objective_box = self:_build_value_combobox(panel, panel_sizer, "objective_id", objectives, "Select a challenge objective from the combobox")

	self._objective_box:set_value(self._hed.objective_id)
	self:_build_value_combobox(panel, panel_sizer, "check_type", {
		"complete",
		"incomplete"
	}, "Check if the challenge is completed or incomplete")
end

function EventSideJobFilterElement:set_element_data(data)
	EventSideJobFilterElement.super.set_element_data(self, data)

	if data.ctrlr == self._challenge_box then
		local id = self._challenge_box:get_value()
		local items = tweak_data.event_jobs.collective_stats[id]

		self._objective_box:clear()

		for idx, objective in ipairs(items.all) do
			self._objective_box:append(objective)
		end

		self._objective_box:set_selection(0)
	end
end
