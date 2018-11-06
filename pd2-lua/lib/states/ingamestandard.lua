require("lib/states/GameState")

IngameStandardState = IngameStandardState or class(IngamePlayerBaseState)

function IngameStandardState:init(game_state_machine)
	IngameStandardState.super.init(self, "ingame_standard", game_state_machine)
end

function IngameStandardState:at_enter()
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

function IngameStandardState:at_exit()
	managers.environment_controller:set_dof_distance()
	managers.hud:hide(PlayerBase.PLAYER_HUD)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end
end

function IngameStandardState:on_server_left()
	IngameCleanState.on_server_left(self)
end

function IngameStandardState:on_kicked()
	IngameCleanState.on_kicked(self)
end

function IngameStandardState:on_disconnected()
	IngameCleanState.on_disconnected(self)
end
