CommunityChallengesManager = CommunityChallengesManager or class()
CommunityChallengesManager.FULL_CREW_COUNT = 4
CommunityChallengesManager.PER_CHALLENGE_BONUS = 0.01

function CommunityChallengesManager:init()
	self._full_crew_start = nil
	self._full_crew_time = 0
	self._message_system = MessageSystem:new()
	self._next_stat_request_limit = 0
	self._challenges = {}

	for _, challenge in ipairs(tweak_data.community_challenges) do
		self._challenges[challenge.challenge_id] = challenge
	end

	self._global = Global.community_challenges_manager or {
		active_bonus = 0
	}
	Global.community_challenges_manager = self._global

	self:fetch_community_challenge_data()
end

function CommunityChallengesManager:update(t, dt)
	self._message_system:update()
end

function CommunityChallengesManager:fetch_community_challenge_data()
	if SystemInfo:distribution() == Idstring("STEAM") then
		local now = Application:time()

		if now <= self._next_stat_request_limit then
			return
		end

		self._next_stat_request_limit = now + 10

		if not _G.IS_VR then
			Steam:sa_handler():refresh_global_stats_cb(callback(self, self, "_on_global_stats_refresh_complete"))
			Steam:sa_handler():refresh_global_stats()
		end
	end
end

function CommunityChallengesManager:_on_global_stats_refresh_complete(success)
	if not success then
		return
	end

	self._global.challenge_data = {}
	self._global.active_bonus = 0

	local function get_60_day_stat(stat_name)
		local stat_value = 0

		for _, value in ipairs(Steam:sa_handler():get_global_stat(stat_name, 60)) do
			stat_value = stat_value + value
		end

		return stat_value > 0 and stat_value or 0
	end

	local function better_ceil(number)
		local mod = number % 1

		if mod > 0 then
			return number - mod + 1
		else
			return number
		end
	end

	local ratio = tweak_data.community_challenges_stage_multiplier

	for _, challenge in ipairs(tweak_data.community_challenges) do
		local base = challenge.base_target
		local stat_value = get_60_day_stat(challenge.statistic_id)
		local total_value = math.floor(tonumber(stat_value * (challenge.display_multiplier or 1)))
		local stage = math.floor(math.log(1 - total_value * (1 - ratio) / base) / math.log(ratio))
		local stage_base_value = math.floor(base * (1 - math.pow(ratio, stage)) / (1 - ratio))
		self._global.challenge_data[challenge.statistic_id] = {
			stage = stage + 1,
			total_value = total_value,
			current_value = total_value - stage_base_value,
			target_value = better_ceil(base * math.pow(ratio, stage)),
			additional_zeroes = challenge.additional_zeroes
		}
		self._global.active_bonus = self._global.active_bonus + stage * CommunityChallengesManager.PER_CHALLENGE_BONUS
	end

	self._message_system:notify(Message.OnCommunityChallengeDataReceived, nil, self._global.challenge_data)
end

function CommunityChallengesManager:get_challenge_data()
	return self._global.challenge_data
end

function CommunityChallengesManager:get_active_experience_bonus()
	return self._global.active_bonus
end

function CommunityChallengesManager:add_event_listener(message, uid, func)
	self._message_system:register(message, uid, func)
end

function CommunityChallengesManager:remove_event_listener(message, uid)
	self._message_system:unregister(message, uid)
end
