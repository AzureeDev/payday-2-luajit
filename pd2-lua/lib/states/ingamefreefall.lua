require("lib/states/GameState")

IngameFreefall = IngameFreefall or class(IngamePlayerBaseState)

function IngameFreefall:init(game_state_machine)
	IngameFreefall.super.init(self, "ingame_freefall", game_state_machine)
end

function IngameFreefall:at_enter()
	local players = managers.player:players()

	for k, player in ipairs(players) do
		local vp = player:camera():viewport()

		if vp then
			vp:set_active(true)
		else
			Application:error("No viewport for player " .. tostring(k))
		end
	end

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
	end

	managers.hud:show(PlayerBase.PLAYER_HUD)
	managers.hud:show(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:show(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
end

function IngameFreefall:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
end

function IngameFreefall:on_server_left()
	IngameCleanState.on_server_left(self)
end

function IngameFreefall:on_kicked()
	IngameCleanState.on_kicked(self)
end

function IngameFreefall:on_disconnected()
	IngameCleanState.on_disconnected(self)
end
