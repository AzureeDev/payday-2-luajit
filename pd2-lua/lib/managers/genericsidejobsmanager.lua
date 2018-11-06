GenericSideJobsManager = GenericSideJobsManager or class()

function GenericSideJobsManager:init()
	self._side_jobs = {}
end

function GenericSideJobsManager:register(manager)
	if table.find_value(self._side_jobs, function (v)
		return v.manager == manager
	end) then
		return
	end

	table.insert(self._side_jobs, {
		manager = manager
	})
end

function GenericSideJobsManager:side_jobs()
	return self._side_jobs
end

function GenericSideJobsManager:get_challenge(id)
	for _, side_job_dlc in ipairs(self._side_jobs) do
		local challenge = side_job_dlc.manager:get_challenge(id)

		if challenge then
			return challenge
		end
	end
end

function GenericSideJobsManager:has_completed_and_claimed_rewards(id)
	for _, side_job_dlc in ipairs(self._side_jobs) do
		local challenge = side_job_dlc.manager:get_challenge(id)

		if challenge then
			return side_job_dlc.manager:has_completed_and_claimed_rewards(id)
		end
	end

	return false
end

function GenericSideJobsManager:award(id)
	for _, side_job_dlc in ipairs(self._side_jobs) do
		side_job_dlc.manager:award(id)
	end
end

function GenericSideJobsManager:save(cache)
	for _, side_job_dlc in ipairs(self._side_jobs) do
		side_job_dlc.manager:save(cache)
	end
end

function GenericSideJobsManager:load(cache, version)
	for _, side_job_dlc in ipairs(self._side_jobs) do
		side_job_dlc.manager:load(cache, version)
	end
end

function GenericSideJobsManager:reset()
	local list = table.list_copy(self._side_jobs)

	for _, side_job_dlc in ipairs(list) do
		side_job_dlc.manager:reset()
	end
end
