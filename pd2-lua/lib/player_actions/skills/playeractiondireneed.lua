PlayerAction.DireNeed = {
	Priority = 1,
	Function = function (is_armor_regenerating_func, target_duration)
		local co = coroutine.running()
		local quit = false

		managers.player:send_message(Message.SetWeaponStagger, nil, true)

		while is_armor_regenerating_func() and not quit do
			coroutine.yield(co)
		end

		local current_time = Application:time()
		local target_time = current_time + target_duration

		while current_time <= target_time and not quit do
			current_time = Application:time()

			coroutine.yield(co)
		end

		managers.player:send_message(Message.SetWeaponStagger, nil, false)
		managers.player:send_message(Message.ResetStagger, nil)
	end
}
