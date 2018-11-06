require("lib/states/GameState")

IngameArrestedState = IngameArrestedState or class(IngamePlayerBaseState)

function IngameArrestedState:init(game_state_machine)
	IngameArrestedState.super.init(self, "ingame_arrested", game_state_machine)
end

function IngameArrestedState:update(t, dt)
	local player = managers.player:player_unit()

	if not alive(player) then
		return
	end

	player:character_damage():update_arrested(t, dt)
end

function IngameArrestedState:at_enter()
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
		bleed_out = true
	})

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
	end

	managers.hud:show(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:show(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	managers.hud:show(PlayerBase.PLAYER_DOWNED_HUD)
end

function IngameArrestedState:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	managers.hud:hide(PlayerBase.PLAYER_DOWNED_HUD)
end

function IngameArrestedState:on_server_left()
	IngameCleanState.on_server_left(self)
end

function IngameArrestedState:on_kicked()
	IngameCleanState.on_kicked(self)
end

function IngameArrestedState:on_disconnected()
	IngameCleanState.on_disconnected(self)
end
