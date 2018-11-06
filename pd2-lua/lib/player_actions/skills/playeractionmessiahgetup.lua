PlayerAction.MessiahGetUp = {
	Priority = 1,
	Function = function (player_manager)
		local hint = "skill_messiah_get_up"

		if _G.IS_VR then
			hint = "skill_messiah_get_up_vr"
		end

		managers.hint:show_hint(hint)

		local controller = player_manager:player_unit():base():controller()
		local co = coroutine.running()

		while player_manager:current_state() == "bleed_out" do
			local button_pressed = controller:get_input_pressed("jump")

			if _G.IS_VR then
				button_pressed = controller:get_input_pressed("warp")
			end

			if button_pressed then
				player_manager:use_messiah_charge()
				player_manager:send_message(Message.RevivePlayer, nil, nil)

				break
			end

			coroutine.yield(co)
		end
	end
}
