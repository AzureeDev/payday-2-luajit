require("lib/states/GameState")

IngameFatalState = IngameFatalState or class(IngamePlayerBaseState)

function IngameFatalState:init(game_state_machine)
	IngameFatalState.super.init(self, "ingame_fatal", game_state_machine)
end

function IngameFatalState.on_local_player_dead()
	local peer_id = managers.network:session():local_peer():id()
	local player = managers.player:player_unit()

	player:network():send("sync_player_movement_state", "dead", player:character_damage():down_time(), player:id())
	managers.groupai:state():on_player_criminal_death(peer_id)
end

function IngameFatalState:update(t, dt)
	local player_manager = managers.player
	local player = player_manager:player_unit()

	if not alive(player) then
		return
	end

	if player:character_damage():update_downed(t, dt) then
		player_manager:on_enter_custody(player)
	end
end

function IngameFatalState:at_enter()
	local player_manager = managers.player
	local players = player_manager:players()

	for k, player in ipairs(players) do
		local vp = player:camera():viewport()

		if vp then
			vp:set_active(true)
		else
			Application:error("No viewport for player " .. tostring(k))
		end
	end

	managers.statistics:downed({
		fatal = true
	})

	local player = player_manager:player_unit()

	if player then
		player:base():set_enabled(true)
	end

	local hud_manager = managers.hud

	hud_manager:show(PlayerBase.PLAYER_INFO_HUD)
	hud_manager:show(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	hud_manager:show(PlayerBase.PLAYER_DOWNED_HUD)
end

function IngameFatalState:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	local hud_manager = managers.hud

	hud_manager:hide(PlayerBase.PLAYER_INFO_HUD)
	hud_manager:hide(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	hud_manager:hide(PlayerBase.PLAYER_DOWNED_HUD)
end

function IngameFatalState:on_server_left()
	IngameCleanState.on_server_left(self)
end

function IngameFatalState:on_kicked()
	IngameCleanState.on_kicked(self)
end

function IngameFatalState:on_disconnected()
	IngameCleanState.on_disconnected(self)
end
