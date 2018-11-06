RemoteCommandManagerPD2 = RemoteCommandManagerPD2 or class()

function RemoteCommandManagerPD2:init()
	print("[RemoteCommandManagerPD2] Init")

	if rawget(_G, "RemoteCommandManager") ~= nil then
		RemoteCommandManager:set_callback(callback(self, self, "remote_callback"))
	end
end

local steam_users = {}

function RemoteCommandManagerPD2:remote_callback(method, parameters)
	if method == "user_id" then
		return tostring(Steam:userid())
	elseif method == "user_name" then
		return Steam:username()
	elseif method == "num_players" then
		return managers.network:session():amount_of_players()
	elseif method == "start_timer" then
		local state = managers.job:arcade_state()

		if Global.game_host and (state == "lobby" or state == "tutorial") then
			return managers.job:force_start_lobby_timer()
		end

		return false
	elseif method == "players" then
		local users = {}

		if managers.network:session() then
			for _, peer in pairs(managers.network:session():all_peers()) do
				if peer and not peer:is_host() then
					table.insert(users, tostring(peer:user_id()))
				end
			end
		end

		return users
	elseif method == "toggle_primary_hand" then
		if managers.vr then
			managers.vr:toggle_primary_hand()

			return true
		end

		return false
	elseif method == "set_player_ready" then
		if game_state_machine:current_state_name() == "ingame_waiting_for_players" and not Network:is_server() then
			managers.menu_component:on_ready_pressed_mission_briefing_gui(true)

			Global.auto_ready = true

			return true
		end

		return false
	elseif method == "game_state" then
		local players = {}

		if managers.network:session() then
			for _, peer in pairs(managers.network:session():all_peers()) do
				if peer and not peer:is_host() then
					local user_id = tostring(peer:user_id())
					local user_name = steam_users[user_id]

					if not user_name then
						user_name = Steam:username(user_id)
						steam_users[user_id] = user_name
					end

					table.insert(players, {
						user_id = user_id,
						user_name = user_name
					})
				end
			end
		end

		local is_server = Global.game_host or false
		local game_state = game_state_machine:current_state_name()
		local ready = false

		if string.find(game_state, "ingame_") then
			ready = game_state ~= "ingame_waiting_for_players"
		end

		local pos = managers.viewport:get_current_camera_position()
		local cam_pos = {}

		if pos then
			cam_pos.x = pos.x
			cam_pos.y = pos.y
			cam_pos.z = pos.z
		end

		local primary_hand = "right"

		if managers.vr then
			primary_hand = managers.vr:get_setting("default_weapon_hand")
		end

		return {
			game_state = game_state or {},
			arcade_state = managers.job:arcade_state() or {},
			killed_enemies = managers.statistics:session_total_kills() or 0,
			cam_pos = cam_pos,
			is_server = is_server,
			is_ready = ready,
			primary_hand = primary_hand,
			players = players,
			timer = managers.game_play_central and math.abs(managers.game_play_central:get_heist_timer()) or {}
		}
	end
end
