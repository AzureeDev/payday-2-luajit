require("lib/states/GameState")

IngamePlayerBaseState = IngamePlayerBaseState or class(GameState)

function IngamePlayerBaseState:init(...)
	GameState.init(self, ...)
end

function IngamePlayerBaseState:set_controller_enabled(enabled)
	local players = managers.player:players()

	for _, player in ipairs(players) do
		local controller = player:base():controller()

		if controller then
			controller:set_enabled(enabled)
		end

		if enabled then
			controller:clear_input_pressed_state("duck")
			controller:clear_input_pressed_state("jump")

			if controller:get_input_bool("stats_screen") then
				player:base():set_stats_screen_visible(true)
			end
		else
			player:base():set_stats_screen_visible(false)
		end
	end
end
