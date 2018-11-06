RaidJobsManager = RaidJobsManager or class(SideJobGenericDLCManager)
RaidJobsManager.save_version = 1
RaidJobsManager.global_table_name = "raid_jobs"
RaidJobsManager.save_table_name = "raid_jobs"
RaidJobsManager.category = "raid_jobs"
RaidJobsManager.category_id = "menu_raid_jobs"

function RaidJobsManager:init()
	self._challenges_tweak_data = tweak_data.raid_jobs.challenges

	self:_setup()
end
