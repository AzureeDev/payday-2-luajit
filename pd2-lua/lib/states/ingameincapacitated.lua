require("lib/states/GameState")

IngameIncapacitatedState = IngameIncapacitatedState or class(IngamePlayerBaseState)

function IngameIncapacitatedState:init(game_state_machine)
	IngameIncapacitatedState.super.init(self, "ingame_incapacitated", game_state_machine)
end

function IngameIncapacitatedState:update(t, dt)
	local player = managers.player:player_unit()

	if not alive(player) then
		return
	end

	if player:character_damage():update_incapacitated(t, dt) then
		IngameFatalState.on_local_player_dead()
		managers.player:on_enter_custody(player, true)
	end
end

function IngameIncapacitatedState:at_enter()
	local players = managers.player:players()

	for k, player in ipairs(players) do
		local vp = player:camera():viewport()

		if vp then
			vp:set_active(true)
		else
			Application:error("No viewport for player " .. tostring(k))
		end
	end

	managers.statistics:downed({
		incapacitated = true
	})

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
	end

	managers.hud:show(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:show(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	managers.hud:show(PlayerBase.PLAYER_DOWNED_HUD)
end

function IngameIncapacitatedState:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	managers.hud:hide(PlayerBase.PLAYER_DOWNED_HUD)
end

function IngameIncapacitatedState:on_server_left()
	IngameCleanState.on_server_left(self)
end

function IngameIncapacitatedState:on_kicked()
	IngameCleanState.on_kicked(self)
end

function IngameIncapacitatedState:on_disconnected()
	IngameCleanState.on_disconnected(self)
end
