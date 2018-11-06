require("lib/states/GameState")

IngameMaskOffState = IngameMaskOffState or class(IngamePlayerBaseState)
IngameMaskOffState.immortal = true

function IngameMaskOffState:init(game_state_machine)
	IngameMaskOffState.super.init(self, "ingame_mask_off", game_state_machine)

	self._MASK_OFF_HUD = Idstring("guis/mask_off_hud")
end

function IngameMaskOffState:at_enter()
	local players = managers.player:players()

	for k, player in ipairs(players) do
		local vp = player:camera():viewport()

		if vp then
			vp:set_active(true)
		else
			Application:error("No viewport for player " .. tostring(k))
		end
	end

	if not managers.hud:exists(self._MASK_OFF_HUD) then
		managers.hud:load_hud(self._MASK_OFF_HUD, false, false, true, {})
	end

	if not _G.IS_VR then
		managers.hud:show(self._MASK_OFF_HUD)
	end

	managers.hud:show(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:show(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
	end
end

function IngameMaskOffState:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(self._MASK_OFF_HUD)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
end

function IngameMaskOffState:on_server_left()
	IngameCleanState.on_server_left(self)
end

function IngameMaskOffState:on_kicked()
	IngameCleanState.on_kicked(self)
end

function IngameMaskOffState:on_disconnected()
	IngameCleanState.on_disconnected(self)
end
