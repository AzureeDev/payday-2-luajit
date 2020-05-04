PlayerAction.ShockAndAwe = {
	Priority = 1,
	Function = function (player_manager, target_enemies, max_reload_increase, min_reload_increase, penalty, min_bullets, weapon_unit)
		local co = coroutine.running()
		local running = true

		local function on_player_reload(weapon_unit)
			if alive(weapon_unit) and running then
				running = false
				local reload_multiplier = max_reload_increase
				local ammo = weapon_unit:base():get_ammo_max_per_clip()

				if player_manager:has_category_upgrade("player", "automatic_mag_increase") and weapon_unit:base():is_category("smg", "assault_rifle", "lmg") then
					ammo = ammo - player_manager:upgrade_value("player", "automatic_mag_increase", 0)
				end

				if min_bullets < ammo then
					local num_bullets = ammo - min_bullets
					local math_max = math.max

					for i = 1, num_bullets do
						reload_multiplier = math_max(min_reload_increase, reload_multiplier * penalty)
					end
				end

				player_manager:set_property("shock_and_awe_reload_multiplier", reload_multiplier)
			end
		end

		local function on_switch_weapon_quit()
			running = false
		end

		player_manager:register_message(Message.OnSwitchWeapon, co, on_switch_weapon_quit)
		player_manager:register_message(Message.OnPlayerReload, co, on_player_reload)

		while running and alive(weapon_unit) and weapon_unit == player_manager:equipped_weapon_unit() do
			coroutine.yield(co)
		end

		player_manager:unregister_message(Message.OnSwitchWeapon, co)
		player_manager:unregister_message(Message.OnPlayerReload, co)
	end
}
