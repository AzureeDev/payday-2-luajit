PlayerAction.BloodthirstBase = {
	Priority = 1,
	Function = function (player_manager, melee_multiplier, max_multiplier)
		local co = coroutine.running()
		local multiplier = 1
		local quit = false

		local function increase_multiplier()
			multiplier = math.min(multiplier + melee_multiplier, max_multiplier)

			player_manager:set_melee_dmg_multiplier(multiplier)
		end

		increase_multiplier()

		local function on_enemy_killed(weapon_unit, variant)
			if variant == "melee" then
				quit = true
			else
				increase_multiplier()
			end
		end

		player_manager:register_message(Message.OnEnemyKilled, co, on_enemy_killed)

		while not quit do
			coroutine.yield(co)
		end

		player_manager:reset_melee_dmg_multiplier()
		player_manager:unregister_message(Message.OnEnemyKilled, co)
	end
}
