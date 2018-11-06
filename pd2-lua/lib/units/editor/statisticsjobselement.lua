StatisticsJobsElement = StatisticsJobsElement or class(MissionElement)
StatisticsJobsElement.SAVE_UNIT_POSITION = false
StatisticsJobsElement.SAVE_UNIT_ROTATION = false

function StatisticsJobsElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.job = "four_stores"
	self._hed.state = "completed"
	self._hed.difficulty = "all"
	self._hed.include_prof = true
	self._hed.include_dropin = false
	self._hed.required = 1

	table.insert(self._save_values, "job")
	table.insert(self._save_values, "state")
	table.insert(self._save_values, "difficulty")
	table.insert(self._save_values, "include_prof")
	table.insert(self._save_values, "include_dropin")
	table.insert(self._save_values, "required")
end

function StatisticsJobsElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local job_list = {}

	for job, data in pairs(tweak_data.narrative.jobs) do
		if not data.wrapped_to_job and table.contains(tweak_data.narrative:get_jobs_index(), job) then
			table.insert(job_list, job)
		end
	end

	table.sort(job_list)
	self:_build_value_combobox(panel, panel_sizer, "job", job_list, "Select the required job")

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
	self:_build_value_checkbox(panel, panel_sizer, "include_prof", "Select if professional heists should be included.")
	self:_build_value_checkbox(panel, panel_sizer, "include_dropin", "Select if drop-in is counted as well.")
	self:_build_value_number(panel, panel_sizer, "required", {
		floats = 0,
		min = 1
	}, "Type the required amount that is needed.")
end
