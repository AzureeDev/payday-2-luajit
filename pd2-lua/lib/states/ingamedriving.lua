require("lib/states/GameState")

IngameDriving = IngameDriving or class(IngamePlayerBaseState)
IngameDriving.DRIVING_GUI_SAFERECT = Idstring("guis/driving_saferect")
IngameDriving.DRIVING_GUI_FULLSCREEN = Idstring("guis/driving_fullrect")

function IngameDriving:init(game_state_machine)
	IngameDriving.super.init(self, "ingame_driving", game_state_machine)
end

function IngameDriving:_update_driving_hud()
	local vehicle = managers.player:get_vehicle().vehicle_unit:vehicle()
	local vehicle_state = vehicle:get_state()
	local speed = vehicle_state:get_speed() * 3.6
	local rpm = vehicle_state:get_rpm()
	local gear = vehicle_state:get_gear() - 1

	if gear == 0 then
		gear = "N"
	elseif gear < 0 then
		gear = "R"
	end

	managers.hud:set_driving_vehicle_state(speed, rpm, gear)
end

function IngameDriving:update(t, dt)
end

function IngameDriving:update_player_stamina(t, dt)
end

function IngameDriving:_player_damage(info)
	print("IngameDriving:_player_damage()")
end

function IngameDriving:at_enter(old_state, ...)
	print("IngameDriving:at_enter()")

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

	SoundDevice:set_rtpc("stamina", 100)

	self._old_state = old_state:name()
	local vehicle_ext = managers.player:get_vehicle().vehicle_unit:vehicle_driving()
	local seat = vehicle_ext:find_seat_for_player(player)

	if false then
		if not managers.hud:exists(IngameDriving.DRIVING_GUI_SAFERECT) then
			print("Loading HUD...")
			managers.hud:load_hud(IngameDriving.DRIVING_GUI_FULLSCREEN, false, true, false, {})
			managers.hud:load_hud(IngameDriving.DRIVING_GUI_SAFERECT, false, true, true, {})
		end

		managers.hud:show(IngameDriving.DRIVING_GUI_SAFERECT)
		managers.hud:show(IngameDriving.DRIVING_GUI_FULLSCREEN)
		managers.hud:start_driving()
	else
		managers.hud:show(PlayerBase.PLAYER_HUD)
		managers.hud:show(PlayerBase.PLAYER_INFO_HUD)
		managers.hud:show(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	end

	if vehicle_ext:has_driving_seat() and tweak_data.achievement.drive_away then
		managers.achievment:award(tweak_data.achievement.drive_away)
	end
end

function IngameDriving:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.PLAYER_HUD)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
end

function IngameDriving:on_server_left()
	IngameCleanState.on_server_left(self)
end

function IngameDriving:on_kicked()
	IngameCleanState.on_kicked(self)
end

function IngameDriving:on_disconnected()
	IngameCleanState.on_disconnected(self)
end
