PlayerAction.TaserMalfunction = {
	Priority = 1,
	Function = function (player_manager, interval, chance_to_trigger)
		local co = coroutine.running()
		local elapsed = 0
		local target_elapsed = Application:time() + interval

		while player_manager:current_state() == "tased" do
			elapsed = Application:time()

			if target_elapsed <= elapsed then
				if math.random() <= chance_to_trigger then
					player_manager:send_message(Message.SendTaserMalfunction, nil, nil)
				end

				target_elapsed = Application:time() + interval
			end

			coroutine.yield(co)
		end
	end
}
