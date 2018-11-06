core:import("CoreMissionScriptElement")

ElementStatisticsContact = ElementStatisticsContact or class(CoreMissionScriptElement.MissionScriptElement)

function ElementStatisticsContact:init(...)
	ElementStatisticsContact.super.init(self, ...)
end

function ElementStatisticsContact:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local value = self:_completed_contact_data(self._values.contact, self._values.state, self._values.difficulty ~= "all" and self._values.difficulty, self._values.include_dropin)

	if value < self._values.required then
		return
	end

	ElementStatisticsContact.super.on_executed(self, instigator)
end

function ElementStatisticsContact:client_on_executed(...)
	self:on_executed(...)
end

function ElementStatisticsContact:_completed_contact_data(contact_id, state, difficulty, dropin)
	local count = 0
	local job_list = managers.statistics:sessions_jobs()
	local available_jobs = tweak_data.narrative:get_jobs_index()

	for _, job_id in pairs(available_jobs) do
		if tweak_data.narrative.jobs[job_id] and tweak_data.narrative.jobs[job_id].contact == contact_id and not tweak_data.narrative:is_wrapped_to_job(job_id) then
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
			else
				if not difficulty then
					for _, diff in pairs(tweak_data.difficulties) do
						count = count + (job_list[tostring(job_id) .. "_" .. tostring(diff) .. "_" .. state] or 0)
					end
				end

				count = count + (job_list[tostring(job_id) .. "_" .. tostring(difficulty) .. "_" .. state] or 0)
			end
		end
	end

	if dropin and not string.find(state, "_dropin") then
		count = count + self:_completed_contact_data(contact_id, state .. "_dropin", difficulty, false)
	end

	return count
end
