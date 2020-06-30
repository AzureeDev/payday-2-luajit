core:import("CoreUnit")
require("lib/states/GameState")

IngameWaitingForRespawnState = IngameWaitingForRespawnState or class(GameState)
IngameWaitingForRespawnState.GUI_SPECTATOR_FULLSCREEN = Idstring("guis/spectator_fullscreen")
IngameWaitingForRespawnState.GUI_SPECTATOR = Idstring("guis/spectator_mode")
IngameWaitingForRespawnState.STATE_STRING = "ingame_waiting_for_respawn"

function IngameWaitingForRespawnState:init(game_state_machine)
	GameState.init(self, self.STATE_STRING, game_state_machine)

	self._slotmask = managers.slot:get_mask("world_geometry") + 39
	self._fwd = Vector3(1, 0, 0)
	self._up_offset = math.UP * 80
	self._rot = Rotation()
	self._vec_target = Vector3()
	self._vec_eye = Vector3()
	self._vec_dir = Vector3()
end

function IngameWaitingForRespawnState:_setup_controller()
	self._controller = managers.controller:create_controller("waiting_for_respawn", managers.controller:get_default_wrapper_index(), false)
	self._next_player_cb = callback(self, self, "cb_next_player")
	self._prev_player_cb = callback(self, self, "cb_prev_player")
	local next_btn = "right"
	local prev_btn = "left"

	if _G.IS_VR then
		next_btn = "suvcam_next"
		prev_btn = "suvcam_prev"
	end

	self._controller:add_trigger(prev_btn, self._prev_player_cb)
	self._controller:add_trigger(next_btn, self._next_player_cb)

	if not _G.IS_VR then
		self._controller:add_trigger("primary_attack", self._prev_player_cb)
		self._controller:add_trigger("secondary_attack", self._next_player_cb)
	end

	self._controller:set_enabled(true)
	managers.controller:set_ingame_mode("main")
end

function IngameWaitingForRespawnState:_clear_controller()
	if self._controller then
		self._controller:remove_trigger("left", self._prev_player_cb)
		self._controller:remove_trigger("right", self._next_player_cb)
		self._controller:remove_trigger("primary_attack", self._prev_player_cb)
		self._controller:remove_trigger("secondary_attack", self._next_player_cb)
		self._controller:set_enabled(false)
		self._controller:destroy()

		self._controller = nil
	end
end

function IngameWaitingForRespawnState:set_controller_enabled(enabled)
	if self._controller then
		self._controller:set_enabled(enabled)
	end
end

function IngameWaitingForRespawnState:_setup_camera()
	self._camera_object = World:create_camera()

	self._camera_object:set_near_range(3)
	self._camera_object:set_far_range(1000000)
	self._camera_object:set_fov(75)

	if _G.IS_VR then
		self._camera_object:set_aspect_ratio(1.7777777777777777)
		self._camera_object:set_stereo(false)
		managers.menu:set_override_ingame_camera(self._camera_object)
	else
		self._viewport = managers.viewport:new_vp(0, 0, 1, 1, "spectator", CoreManagerBase.PRIO_WORLDCAMERA)

		self._viewport:set_camera(self._camera_object)
		self._viewport:set_active(true)
	end
end

function IngameWaitingForRespawnState:_clear_camera()
	if self._viewport then
		self._viewport:destroy()

		self._viewport = nil
	end

	World:delete_camera(self._camera_object)

	self._camera_object = nil

	if _G.IS_VR then
		managers.menu:set_override_ingame_camera(nil)
	end
end

function IngameWaitingForRespawnState:_setup_sound_listener()
	self._listener_id = managers.listener:add_listener("spectator_camera", self._camera_object, self._camera_object, nil, false)

	managers.listener:add_set("spectator_camera", {
		"spectator_camera"
	})

	self._listener_activation_id = managers.listener:activate_set("main", "spectator_camera")
	self._sound_check_object = managers.sound_environment:add_check_object({
		primary = true,
		active = true,
		object = self._camera_object
	})
end

function IngameWaitingForRespawnState:_clear_sound_listener()
	managers.sound_environment:remove_check_object(self._sound_check_object)
	managers.listener:remove_listener(self._listener_id)
	managers.listener:remove_set("spectator_camera")

	self._listener_id = nil
end

function IngameWaitingForRespawnState:_create_spectator_data()
	local all_teammates = managers.groupai:state():all_char_criminals()
	local teammate_list = {}

	for u_key, u_data in pairs(all_teammates) do
		table.insert(teammate_list, u_key)
	end

	self._spectator_data = {
		teammate_records = all_teammates,
		teammate_list = teammate_list,
		watch_u_key = teammate_list[1]
	}
end

function IngameWaitingForRespawnState:_begin_game_enter_transition()
	if self._ready_to_spawn_t then
		return
	end

	self._auto_respawn_t = nil
	self._ai_trade_respawn_gui_enabled = nil
	local overlay_effect_desc = tweak_data.overlay_effects.spectator
	local fade_in_duration = overlay_effect_desc.fade_in
	self._fade_in_overlay_eff_id = managers.overlay_effect:play_effect(overlay_effect_desc)
	self._ready_to_spawn_t = TimerManager:game():time() + fade_in_duration
end

function IngameWaitingForRespawnState.request_player_spawn(peer_to_spawn)
	if Network:is_client() then
		managers.network:session():server_peer():send("request_spawn_member")
	else
		local peer = managers.network:session():peer(peer_to_spawn)
		local pos_rot = managers.criminals:get_valid_player_spawn_pos_rot(peer and peer:id())

		if not pos_rot and managers.network then
			local spawn_point = managers.network:session() and managers.network:session():get_next_spawn_point() or managers.network:spawn_point(1)
			pos_rot = spawn_point and spawn_point.pos_rot
		end

		if pos_rot then
			local peer_id = peer_to_spawn or 1
			local crim_name = managers.criminals:character_name_by_peer_id(peer_id)
			local first_crim = managers.trade:get_criminal_to_trade()

			if first_crim and first_crim.id == crim_name then
				managers.trade:cancel_trade()
			end

			managers.trade:sync_set_trade_spawn(crim_name)
			managers.network:session():send_to_peers_synched("set_trade_spawn", crim_name)

			local sp_id = "IngameWaitingForRespawnState"
			local spawn_point = {
				position = pos_rot[1],
				rotation = pos_rot[2]
			}

			managers.network:register_spawn_point(sp_id, spawn_point)
			managers.network:session():spawn_member_by_id(peer_id, sp_id, true)
			managers.network:unregister_spawn_point(sp_id)
		end
	end

	local player_unit = managers.player:player_unit()

	if player_unit then
		managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, 1, player_unit:inventory():unit_by_selection(1):base():fire_mode())
		managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, 2, player_unit:inventory():unit_by_selection(2):base():fire_mode())
	end
end

function IngameWaitingForRespawnState:update(t, dt)
	if self._player_state_change_needed and not alive(managers.player:player_unit()) then
		self._player_state_change_needed = nil

		managers.player:set_player_state("standard")
	end

	local btn_stats_screen_press = not self._stats_screen and self._controller:get_input_pressed("stats_screen")
	local btn_stats_screen_release = self._stats_screen and self._controller:get_input_released("stats_screen")

	if btn_stats_screen_press then
		self._stats_screen = true

		managers.hud:show_stats_screen()
	elseif btn_stats_screen_release then
		self._stats_screen = false

		managers.hud:hide_stats_screen()
	end

	local ai_trade_time = managers.trade:get_auto_assault_ai_trade_time()

	if not ai_trade_time and self._ai_trade_respawn_gui_enabled then
		managers.hud:set_custody_timer_visibility(false)

		self._ai_trade_respawn_gui_enabled = false
	end

	if ai_trade_time and (not self._auto_respawn_t or math.max(0, ai_trade_time) < self._auto_respawn_t - t) and not self._ready_to_spawn_t then
		if not self._auto_respawn_t and not self._ai_trade_respawn_gui_enabled then
			managers.hud:set_custody_timer_visibility(true)

			self._ai_trade_respawn_gui_enabled = true
		end

		managers.hud:set_custody_respawn_type(true)
		managers.hud:set_custody_respawn_time(ai_trade_time)
	elseif self._auto_respawn_t then
		managers.hud:set_custody_respawn_type(false)
		managers.hud:set_custody_respawn_time(self._auto_respawn_t - t)

		if self._auto_respawn_t < t then
			self._auto_respawn_t = nil

			self:_begin_game_enter_transition()
		end
	elseif self._ready_to_spawn_t and self._ready_to_spawn_t < t then
		IngameWaitingForRespawnState.request_player_spawn()
	end

	if self._respawn_delay then
		self._respawn_delay = managers.trade:respawn_delay_by_name(managers.criminals:local_character_name())

		if self._respawn_delay <= 0 then
			self._respawn_delay = nil

			managers.hud:set_custody_negotiating_visible(false)
			managers.hud:set_custody_trade_delay_visible(false)
		else
			managers.hud:set_custody_trade_delay(self._respawn_delay)
		end
	end

	if self._play_too_long_line_t and self._play_too_long_line_t < t and managers.groupai:state():bain_state() then
		self._play_too_long_line_t = nil

		managers.dialog:queue_narrator_dialog("h38x", {})
	end

	self:_upd_watch(t, dt)
end

local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_subtract = mvector3.subtract
local mvec3_multiply = mvector3.multiply
local mvec3_negate = mvector3.negate
local mvec3_rotate_with = mvector3.rotate_with
local mvec3_x = mvector3.x
local mvec3_y = mvector3.y
local mvec3_normalize = mvector3.normalize
local mvec3_length = mvector3.length
local mvec3_cross = mvector3.cross
local mvec3_angle = mvector3.angle
local mrot_set_axis_angle = mrotation.set_axis_angle
local mrot_set_look_at = mrotation.set_look_at
local math_up = math.UP

function IngameWaitingForRespawnState:_upd_watch(t, dt)
	self:_refresh_teammate_list()

	if self._spectator_data.watch_u_key then
		if managers.hud:visible(self.GUI_SPECTATOR_FULLSCREEN) then
			managers.hud:hide(self.GUI_SPECTATOR_FULLSCREEN)
		end

		local watch_u_record = self._spectator_data.teammate_records[self._spectator_data.watch_u_key]
		local watch_u_head = watch_u_record.unit:movement():get_object(Idstring("Head"))

		if not watch_u_head then
			self._next_player_cb()

			return
		end

		mvec3_set(self._vec_dir, self._controller:get_input_axis("look"))

		if _G.IS_VR then
			mvec3_set(self._vec_dir, self._controller:get_input_axis("touchpad_primary"))
		end

		local controller_type = self._controller:get_default_controller_id()
		local stick_input_x = mvec3_x(self._vec_dir)

		if mvec3_length(self._vec_dir) > 0.1 then
			if controller_type ~= "keyboard" then
				stick_input_x = stick_input_x / (1.3 - 0.3 * (1 - math.abs(mvec3_y(self._vec_dir))))
				stick_input_x = stick_input_x * dt * 180
			end

			mrot_set_axis_angle(self._rot, math_up, -0.5 * stick_input_x)
			mvec3_rotate_with(self._fwd, self._rot)
			mvec3_cross(self._vec_target, math_up, self._fwd)
			mrot_set_axis_angle(self._rot, self._vec_target, 0.5 * -mvec3_y(self._vec_dir))
			mvec3_rotate_with(self._fwd, self._rot)

			local angle = mvec3_angle(math_up, self._fwd)
			local rot = 0

			if angle > 145 then
				rot = 145 - angle
			elseif angle < 85 then
				rot = 85 - angle
			end

			if rot ~= 0 then
				mrot_set_axis_angle(self._rot, self._vec_target, rot)
				mvec3_rotate_with(self._fwd, self._rot)
			end
		end

		local vehicle_unit, vehicle_seat = nil

		if managers.network and managers.network:session() and watch_u_record.unit:network() then
			if watch_u_record.unit:brain() then
				vehicle_unit = watch_u_record.unit:movement().vehicle_unit
				vehicle_seat = watch_u_record.unit:movement().vehicle_seat
			elseif watch_u_record.unit:network():peer() then
				local peer_id = watch_u_record.unit:network():peer():id()
				local vehicle_data = managers.player:get_vehicle_for_peer(peer_id)

				if vehicle_data then
					vehicle_unit = vehicle_data.vehicle_unit
					vehicle_seat = vehicle_unit:vehicle_driving()._seats[vehicle_data.seat]
				end
			end
		end

		if vehicle_unit and vehicle_seat then
			local target_pos = vehicle_unit:vehicle():object_position(vehicle_seat.object)

			mvec3_set(self._vec_target, target_pos)

			local spectate_object = vehicle_unit:vehicle_driving() and vehicle_unit:vehicle_driving().spectate_object and vehicle_unit:get_object(Idstring(vehicle_unit:vehicle_driving().spectate_object)) or vehicle_unit
			local oobb = spectate_object:oobb()
			local z_offset = vehicle_unit:vehicle_driving() and vehicle_unit:vehicle_driving().spectate_offset or 2.5
			local up = oobb:z() * z_offset

			mvec3_add(self._vec_target, up)
		else
			watch_u_head:m_position(self._vec_target)
		end

		mvec3_set(self._vec_eye, self._fwd)
		mvec3_multiply(self._vec_eye, 150)
		mvec3_negate(self._vec_eye)
		mvec3_add(self._vec_eye, self._vec_target)
		mrot_set_look_at(self._rot, self._fwd, math_up)

		local col_ray = World:raycast("ray", self._vec_target, self._vec_eye, "slot_mask", self._slotmask)
		local dis_new = nil

		if col_ray then
			mvec3_set(self._vec_dir, col_ray.ray)

			dis_new = math.max(col_ray.distance - 30, 0)
		else
			mvec3_set(self._vec_dir, self._vec_eye)
			mvec3_subtract(self._vec_dir, self._vec_target)

			dis_new = mvec3_normalize(self._vec_dir)
		end

		if self._dis_curr and self._dis_curr < dis_new then
			local speed = math.max((dis_new - self._dis_curr) / 5, 1.5)
			self._dis_curr = math.lerp(self._dis_curr, dis_new, speed * dt)
		else
			self._dis_curr = dis_new
		end

		mvec3_set(self._vec_eye, self._vec_dir)
		mvec3_multiply(self._vec_eye, self._dis_curr)
		mvec3_add(self._vec_eye, self._vec_target)
		self._camera_object:set_position(self._vec_eye)
		self._camera_object:set_rotation(self._rot)
	elseif not managers.hud:visible(self.GUI_SPECTATOR_FULLSCREEN) then
		managers.hud:show(self.GUI_SPECTATOR_FULLSCREEN)
	end
end

function IngameWaitingForRespawnState:at_enter()
	if _G.IS_VR then
		managers.menu:open_menu("custody")
	end

	managers.player:force_drop_carry()
	managers.hud:set_player_health({
		total = 100,
		current = 0,
		no_hint = true
	})
	managers.hud:set_player_armor({
		total = 100,
		current = 0,
		no_hint = true
	})
	managers.hud:set_player_condition("mugshot_in_custody", managers.localization:text("debug_mugshot_in_custody"))
	managers.overlay_effect:play_effect(tweak_data.overlay_effects.fade_in)
	self:_setup_camera()
	self:_setup_controller()
	self:_setup_sound_listener()

	self._dis_curr = 150

	managers.statistics:in_custody()
	managers.menu:set_mouse_sensitivity(false)

	self._player_state_change_needed = true
	self._respawn_delay = nil
	self._play_too_long_line_t = nil
	local level_tweak = tweak_data.levels[managers.job:current_level_id()]

	if level_tweak and (level_tweak.death_track or level_tweak.death_event) then
		self.music_on_death = true

		managers.music:track_listen_start(level_tweak.death_event or Global.music_manager.current_event, level_tweak.death_track or Global.music_manager.current_track)
	end

	if not managers.hud:exists(self.GUI_SPECTATOR_FULLSCREEN) then
		managers.hud:load_hud(self.GUI_SPECTATOR_FULLSCREEN, false, false, false, {})
	end

	if not managers.hud:exists(PlayerBase.PLAYER_CUSTODY_HUD) then
		managers.hud:load_hud(self.GUI_SPECTATOR, false, true, true, {})
	end

	managers.hud:show(self.GUI_SPECTATOR)
	managers.hud:show(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:show(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	managers.hud:set_custody_can_be_trade_visible(false)
	managers.hud:set_custody_negotiating_visible(false)
	managers.hud:set_custody_trade_delay_visible(false)

	if tweak_data.player.damage.automatic_respawn_time and not Global.game_settings.single_player then
		self._auto_respawn_t = Application:time() + tweak_data.player.damage.automatic_respawn_time * managers.player:upgrade_value("player", "respawn_time_multiplier", 1)

		managers.hud:set_custody_timer_visibility(true)
	else
		managers.hud:set_custody_timer_visibility(false)
	end

	if not managers.hud:exists(PlayerBase.PLAYER_HUD) then
		managers.hud:load_hud(PlayerBase.PLAYER_HUD, false, false, true, {})
	end

	self:_create_spectator_data()
	self:watch_priority_character()

	if Network:is_server() then
		local respawn_delay = managers.trade:respawn_delay_by_name(managers.criminals:local_character_name())
		local hostages_killed = managers.trade:hostages_killed_by_name(managers.criminals:local_character_name())

		self:trade_death(respawn_delay, hostages_killed)
	end

	if Global.game_settings.single_player and not managers.groupai:state():is_ai_trade_possible() then
		managers.hud:set_custody_negotiating_visible(false)
		managers.hud:set_custody_trade_delay_visible(false)
	end
end

function IngameWaitingForRespawnState:at_exit()
	if _G.IS_VR then
		managers.menu:close_menu("custody")
	end

	if self.music_on_death then
		managers.music:stop_listen_all()

		self.music_on_death = nil
	end

	managers.hud:hide(self.GUI_SPECTATOR)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD)
	managers.hud:hide(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	managers.overlay_effect:fade_out_effect(self._fade_in_overlay_eff_id)

	if managers.hud:visible(self.GUI_SPECTATOR_FULLSCREEN) then
		managers.hud:hide(self.GUI_SPECTATOR_FULLSCREEN)
	end

	self._ai_trade_respawn_gui_enabled = nil

	self:_clear_controller()
	self:_clear_camera()
	self:_clear_sound_listener()

	self._auto_respawn_t = nil
	self._ready_to_spawn_t = nil
	self._fade_in_overlay_eff_id = nil

	managers.hud:set_player_condition("mugshot_normal", "")
end

function IngameWaitingForRespawnState:_refresh_teammate_list()
	local all_teammates = self._spectator_data.teammate_records
	local teammate_list = self._spectator_data.teammate_list
	local lost_teammate_at_i = nil
	local i = #teammate_list

	while i > 0 do
		local u_key = teammate_list[i]
		local teammate_data = all_teammates[u_key]

		if not teammate_data then
			table.remove(teammate_list, i)

			if u_key == self._spectator_data.watch_u_key then
				lost_teammate_at_i = i
				self._spectator_data.watch_u_key = nil
			end
		end

		i = i - 1
	end

	if #teammate_list ~= table.size(all_teammates) then
		for u_key, u_data in pairs(all_teammates) do
			local add = true

			for i_key, test_u_key in ipairs(teammate_list) do
				if test_u_key == u_key then
					add = false

					break
				end
			end

			if add then
				table.insert(teammate_list, u_key)
			end
		end
	end

	if lost_teammate_at_i then
		self._spectator_data.watch_u_key = teammate_list[math.clamp(lost_teammate_at_i, 1, #teammate_list)]
	end

	if not self._spectator_data.watch_u_key and #teammate_list > 0 then
		self._spectator_data.watch_u_key = teammate_list[1]
	end
end

function IngameWaitingForRespawnState:_get_teammate_index_by_unit_key(u_key)
	for i_key, test_u_key in ipairs(self._spectator_data.teammate_list) do
		if test_u_key == u_key then
			return i_key
		end
	end
end

function IngameWaitingForRespawnState:watch_priority_character()
	self:_refresh_teammate_list()

	local function try_watch_unit(unit_key)
		if table.contains(self._spectator_data.teammate_list, unit_key) then
			self._spectator_data.watch_u_key = unit_key
			self._dis_curr = nil

			return true
		end
	end

	if Network:is_client() then
		local peer = managers.network:session():server_peer()
		local unit = peer and peer:unit()

		if unit and try_watch_unit(unit:key()) then
			return
		end
	end

	for u_key, _ in pairs(managers.groupai:state():all_player_criminals()) do
		if try_watch_unit(u_key) then
			return
		end
	end

	self._spectator_data.watch_u_key = self._spectator_data.teammate_list[1]
	self._dis_curr = nil
end

function IngameWaitingForRespawnState:cb_next_player()
	self:_refresh_teammate_list()

	local watch_u_key = self._spectator_data.watch_u_key

	if not watch_u_key then
		return
	end

	local i_watch = self:_get_teammate_index_by_unit_key(watch_u_key)
	i_watch = i_watch == #self._spectator_data.teammate_list and 1 or i_watch + 1
	watch_u_key = self._spectator_data.teammate_list[i_watch]
	self._spectator_data.watch_u_key = watch_u_key
	self._dis_curr = nil
end

function IngameWaitingForRespawnState:cb_prev_player()
	self:_refresh_teammate_list()

	local watch_u_key = self._spectator_data.watch_u_key

	if not watch_u_key then
		return
	end

	local i_watch = self:_get_teammate_index_by_unit_key(watch_u_key)

	if i_watch == 1 then
		i_watch = #self._spectator_data.teammate_list
	else
		i_watch = i_watch - 1
	end

	watch_u_key = self._spectator_data.teammate_list[i_watch]
	self._spectator_data.watch_u_key = watch_u_key
	self._dis_curr = nil
end

function IngameWaitingForRespawnState:trade_death(respawn_delay, hostages_killed)
	managers.hud:set_custody_can_be_trade_visible(false)

	self._respawn_delay = managers.trade:respawn_delay_by_name(managers.criminals:local_character_name())
	self._hostages_killed = hostages_killed

	if self._respawn_delay > 0 then
		managers.hud:set_custody_trade_delay_visible(true)
		managers.hud:set_custody_civilians_killed(self._hostages_killed)
		managers.hud:set_custody_trade_delay(self._respawn_delay)
		managers.hud:set_custody_negotiating_visible(true)
	end

	local is_ai_trade_possible = managers.groupai:state():is_ai_trade_possible()

	if (not Global.game_settings.single_player or is_ai_trade_possible) and managers.groupai:state():bain_state() then
		if managers.groupai:state():get_assault_mode() and not is_ai_trade_possible then
			managers.dialog:queue_narrator_dialog("h31x", {})
		elseif is_ai_trade_possible then
			managers.dialog:queue_narrator_dialog("h51", {})
		elseif hostages_killed == 0 then
			managers.dialog:queue_narrator_dialog("h32x", {})
		elseif hostages_killed < 3 then
			managers.dialog:queue_narrator_dialog("h33x", {})
		else
			managers.dialog:queue_narrator_dialog("h34x", {})
		end
	end
end

function IngameWaitingForRespawnState:finish_trade()
	self:_begin_game_enter_transition()
end

function IngameWaitingForRespawnState:begin_trade()
	managers.hud:set_custody_can_be_trade_visible(true)

	local crims = {}

	for k, d in pairs(managers.groupai:state():all_char_criminals()) do
		crims[k] = d
	end

	if managers.groupai:state():bain_state() and next(crims) then
		if table.size(crims) > 1 then
			managers.dialog:queue_narrator_dialog("h36x", {})
		else
			local _, data = next(crims)
			local char_code = managers.criminals:character_static_data_by_unit(data.unit).ssuffix

			managers.dialog:queue_narrator_dialog("h37" .. char_code, {})
		end
	end

	self._play_too_long_line_t = Application:time() + 60
end

function IngameWaitingForRespawnState:cancel_trade()
	managers.hud:set_custody_can_be_trade_visible(false)
end

function IngameWaitingForRespawnState:on_server_left()
	IngameCleanState.on_server_left(self)
end

function IngameWaitingForRespawnState:on_kicked()
	IngameCleanState.on_kicked(self)
end

function IngameWaitingForRespawnState:on_disconnected()
	IngameCleanState.on_disconnected(self)
end
