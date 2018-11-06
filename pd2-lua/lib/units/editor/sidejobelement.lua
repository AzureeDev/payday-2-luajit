SideJobAwardElement = SideJobAwardElement or class(MissionElement)

function SideJobAwardElement:init(unit)
	SideJobAwardElement.super.init(self, unit)

	self._hed.challenge = ""
	self._hed.objective_id = ""
	self._hed.award_instigator = false
	self._hed.players_from_start = nil

	table.insert(self._save_values, "challenge")
	table.insert(self._save_values, "objective_id")
	table.insert(self._save_values, "award_instigator")
	table.insert(self._save_values, "players_from_start")
end

function SideJobAwardElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	if not self._challenge_ids then
		self._challenge_ids = {}

		for _, side_job_dlc in ipairs(managers.generic_side_jobs:side_jobs()) do
			for idx, challenge in ipairs(side_job_dlc.manager:challenges()) do
				table.insert(self._challenge_ids, challenge.id)
			end
		end
	end

	local objectives = {
		"all"
	}

	if self._hed.challenge then
		local id = self._hed.challenge
		local challenge = managers.generic_side_jobs:get_challenge(id)

		if challenge then
			for idx, objective in ipairs(challenge.objectives) do
				table.insert(objectives, objective.progress_id)
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
	self:_build_value_checkbox(panel, panel_sizer, "players_from_start", "Only award to players that joined from start.")
	self:_add_help_text("Awards an objective from any DLC that uses generic side jobs.")
end

function SideJobAwardElement:set_element_data(data)
	SideJobAwardElement.super.set_element_data(self, data)

	if data.ctrlr == self._challenge_box then
		local id = self._challenge_box:get_value()
		local challenge = managers.generic_side_jobs:get_challenge(id)

		self._objective_box:clear()

		for idx, objective in ipairs(challenge.objectives) do
			self._objective_box:append(objective.progress_id)
		end

		self._objective_box:set_selection(0)
	end
end

SideJobFilterElement = SideJobFilterElement or class(MissionElement)

function SideJobFilterElement:init(unit)
	SideJobFilterElement.super.init(self, unit)

	self._hed.challenge = ""
	self._hed.objective_id = ""
	self._hed.check_type = "unlocked"

	table.insert(self._save_values, "challenge")
	table.insert(self._save_values, "objective_id")
	table.insert(self._save_values, "check_type")
end

function SideJobFilterElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	if not self._challenge_ids then
		self._challenge_ids = {}

		for _, side_job_dlc in ipairs(managers.generic_side_jobs:side_jobs()) do
			for idx, challenge in ipairs(side_job_dlc.manager:challenges()) do
				table.insert(self._challenge_ids, challenge.id)
			end
		end
	end

	local objectives = {
		"all"
	}

	if self._hed.challenge then
		local id = self._hed.challenge
		local challenge = managers.generic_side_jobs:get_challenge(id)

		if challenge then
			for idx, objective in ipairs(challenge.objectives) do
				table.insert(objectives, objective.progress_id)
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

function SideJobFilterElement:set_element_data(data)
	SideJobFilterElement.super.set_element_data(self, data)

	if data.ctrlr == self._challenge_box then
		local id = self._challenge_box:get_value()
		local challenge = managers.generic_side_jobs:get_challenge(id)

		self._objective_box:clear()
		self._objective_box:append("all")

		for idx, objective in ipairs(challenge.objectives) do
			self._objective_box:append(objective.progress_id)
		end

		self._objective_box:set_selection(0)
	end
end
