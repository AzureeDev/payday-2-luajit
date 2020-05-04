UnoAchievementChallenge = UnoAchievementChallenge or class()
UnoAchievementChallenge.CHALLENGE_COUNT = 20

function UnoAchievementChallenge:init()
	self._global = Global.custom_safehouse_manager.uno_achievements_challenge or {}
	Global.custom_safehouse_manager.uno_achievements_challenge = self._global
	self._peer_completion = {}
end

function UnoAchievementChallenge:init_finalize()
	if not managers.network:session() then
		return
	end

	if Network:is_client() and self:challenge_completed() then
		managers.network:session():send_to_host("uno_achievement_challenge_completed")
	end

	if not Network:is_client() then
		self:set_peer_completed(managers.network:session():local_peer():id(), self:challenge_completed())
		managers.mission:add_global_event_listener({}, "on_peer_removed", callback(self, self, "on_peer_removed"))
	end

	managers.mission:add_global_event_listener({}, Message.OnAchievement, callback(self, self, "on_achievement_awarded"))
end

function UnoAchievementChallenge:generate_challenge(trigger_save)
	local pool = tweak_data.safehouse.uno_achievements_pool
	local challenge = table.shuffled_copy(pool)

	for i = self.CHALLENGE_COUNT + 1, #pool do
		challenge[i] = nil
	end

	self._global.challenge = challenge

	if trigger_save == nil or trigger_save then
		managers.savefile:save_progress()
	end
end

function UnoAchievementChallenge:on_peer_removed(peer_id)
	self:set_peer_completed(peer_id, nil)
end

function UnoAchievementChallenge:set_peer_completed(peer_id, completed)
	self._peer_completion[peer_id] = completed

	self:attempt_access_notification()
end

function UnoAchievementChallenge:uno_ending_key()
	return Application:md5_encrypt("9x7XhhdHVse6hmRBTmz2" .. Steam:userid())
end

function UnoAchievementChallenge:on_achievement_awarded(achievement_id)
	if achievement_id == "fin_1" then
		Global.statistics_manager.stat_check.h = self:uno_ending_key()

		managers.statistics:check_stats()
	end
end

function UnoAchievementChallenge:attempt_access_notification()
	local verified_before = self._group_challenge_verified
	local verified_after = self:group_challenge_completed()

	if verified_before ~= verified_after then
		managers.mission:call_global_event(verified_after and "uno_access_granted" or "uno_access_denied")
	end

	self._group_challenge_verified = verified_after
end

function UnoAchievementChallenge:group_challenge_completed()
	local session = managers.network:session()

	if not session then
		return false
	end

	local peers = session:all_peers()

	for _, peer in pairs(peers) do
		if not self._peer_completion[peer:id()] then
			return false
		end
	end

	return true
end

function UnoAchievementChallenge:challenge_completed()
	if not self._global.challenge then
		return false
	end

	for _, achievement_id in ipairs(self._global.challenge) do
		local is_awarded = managers.achievment:get_info(achievement_id).awarded

		if not is_awarded then
			return false
		end
	end

	return true
end

function UnoAchievementChallenge:challenge()
	return self._global.challenge
end

function UnoAchievementChallenge:save()
	return self._global
end

function UnoAchievementChallenge:load(data)
	if not data then
		return
	end

	self._global.challenge = data.challenge
end
