core:import("CoreMissionScriptElement")

ElementStatisticsJobs = ElementStatisticsJobs or class(CoreMissionScriptElement.MissionScriptElement)

function ElementStatisticsJobs:init(...)
	ElementStatisticsJobs.super.init(self, ...)
end

function ElementStatisticsJobs:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local value = self:_completed_job_data(self._values.job, self._values.state, self._values.difficulty ~= "all" and self._values.difficulty, self._values.include_prof, self._values.include_dropin)

	if value < self._values.required then
		return
	end

	ElementStatisticsJobs.super.on_executed(self, instigator)
end

function ElementStatisticsJobs:client_on_executed(...)
	self:on_executed(...)
end

function ElementStatisticsJobs:_completed_job_data(job_id, state, difficulty, prof, dropin)
	local count = 0
	local job_list = managers.statistics:sessions_jobs()

	if tweak_data.narrative:has_job_wrapper(job_id) then
		local job_wrapper = tweak_data.narrative.jobs[job_id].job_wrapper

		if not difficulty then
			for _, diff in pairs(tweak_data.difficulties) do
				for _, wrapped_job in ipairs(job_wrapper) do
					count = count + (job_list[tostring(wrapped_job) .. "_" .. tostring(diff) .. "_" .. state] or 0)
				end
			end
		else
			for _, wrapped_job in ipairs(job_wrapper) do
				count = count + (job_list[tostring(wrapped_job) .. "_" .. tostring(difficulty) .. "_" .. state] or 0)
			end
		end
	elseif tweak_data.narrative:is_wrapped_to_job(job_id) then
		local tweak_jobs = tweak_data.narrative.jobs
		local job_wrapper = tweak_jobs[tweak_jobs[job_id].wrapped_to_job].job_wrapper

		if not difficulty then
			for _, diff in pairs(tweak_data.difficulties) do
				for _, wrapped_job in ipairs(job_wrapper) do
					count = count + (job_list[tostring(wrapped_job) .. "_" .. tostring(diff) .. "_" .. state] or 0)
				end
			end
		else
			for _, wrapped_job in ipairs(job_wrapper) do
				count = count + (job_list[tostring(wrapped_job) .. "_" .. tostring(difficulty) .. "_" .. state] or 0)
			end
		end
	else
		if not difficulty then
			for _, diff in pairs(tweak_data.difficulties) do
				count = count + (job_list[tostring(job_id) .. "_" .. tostring(diff) .. "_" .. state] or 0)
			end
		end

		count = count + (job_list[tostring(job_id) .. "_" .. tostring(difficulty) .. "_" .. state] or 0)
	end

	if prof then
		count = count + self:_completed_job_data(job_id .. "_prof", state, difficulty, false, dropin)
	end

	if dropin and not string.find(state, "_dropin") then
		count = count + self:_completed_job_data(job_id, state .. "_dropin", difficulty, prof, false)
	end

	return count
end
