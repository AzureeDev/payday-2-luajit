PlayerAction.UnseenStrike = {
	Priority = 1,
	Function = function (player_manager, min_time, max_duration, crit_chance)
		local co = coroutine.running()
		local current_time = Application:time()
		local target_time = Application:time() + min_time
		local can_activate = true

		local function on_damage_taken()
			if not player_manager:has_activate_temporary_upgrade("temporary", "unseen_strike") then
				target_time = Application:time() + min_time
				can_activate = true
			end
		end

		player_manager:register_message(Message.OnPlayerDamage, co, on_damage_taken)

		while true do
			current_time = Application:time()

			if target_time <= current_time and can_activate then
				managers.player:activate_temporary_upgrade("temporary", "unseen_strike")

				can_activate = false
			end

			coroutine.yield(co)
		end

		player_manager:unregister_message(Message.OnPlayerDamage, co)
	end
}
