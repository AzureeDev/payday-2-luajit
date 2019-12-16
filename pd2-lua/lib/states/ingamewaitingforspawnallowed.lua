core:import("CoreUnit")
require("lib/states/GameState")

IngameWaitingForSpawnAllowed = IngameWaitingForSpawnAllowed or class(IngameWaitingForRespawnState)
IngameWaitingForSpawnAllowed.STATE_STRING = "ingame_waiting_for_spawn_allowed"

function IngameWaitingForSpawnAllowed:_begin_game_enter_transition()
	local overlay_effect_desc = tweak_data.overlay_effects.spectator
	local fade_in_duration = overlay_effect_desc.fade_in
	self._fade_in_overlay_eff_id = managers.overlay_effect:play_effect(overlay_effect_desc)
end

function IngameWaitingForSpawnAllowed.spawn_waiting_player(peer_to_spawn)
	if managers.groupai and managers.groupai:state():whisper_mode() and not managers.wait:check_waiting_allowed_spawn(peer_to_spawn) then
		return
	end

	if Network:is_client() then
		debug_pause("Trying to request player spawn on client trough IngameWaitingForSpawnAllowed")
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
			local sp_id = "IngameWaitingForSpawnAllowed"
			local spawn_point = {
				position = pos_rot[1],
				rotation = pos_rot[2]
			}

			managers.network:register_spawn_point(sp_id, spawn_point)
			managers.network:session():spawn_member_by_id(peer_id, sp_id, true)
			managers.network:unregister_spawn_point(sp_id)
			managers.wait:remove_waiting(peer_id)
		end
	end
end

function IngameWaitingForSpawnAllowed:update(t, dt)
	self:_upd_watch(t, dt)
end

function IngameWaitingForSpawnAllowed:at_enter()
	if _G.IS_VR then
		managers.menu:open_menu("custody")
	end

	managers.overlay_effect:play_effect(tweak_data.overlay_effects.fade_in)
	self:_setup_camera()
	self:_setup_controller()
	self:_setup_sound_listener()
	self:set_controller_enabled(false)
	call_on_next_update(function ()
		self:set_controller_enabled(true)
	end)

	self._dis_curr = 150

	managers.menu:set_mouse_sensitivity(false)

	self._player_state_change_needed = true
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
	managers.hud:set_custody_timer_visibility(false)

	if not managers.hud:exists(PlayerBase.PLAYER_HUD) then
		managers.hud:load_hud(PlayerBase.PLAYER_HUD, false, false, true, {})
	end

	self:_create_spectator_data()
	self:watch_priority_character()
	managers.hud:present_mid_text({
		time = 8,
		title = managers.localization:text("hud_waiting_host_accept_title"),
		text = managers.localization:text("hud_waiting_host_accept_text")
	})
end

function IngameWaitingForSpawnAllowed:at_exit(data)
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

	self:_clear_controller()
	self:_clear_camera()
	self:_clear_sound_listener()

	self._fade_in_overlay_eff_id = nil

	managers.hud:set_player_condition("mugshot_normal", "")
end

function IngameWaitingForSpawnAllowed:trade_death(respawn_delay, hostages_killed)
end

function IngameWaitingForSpawnAllowed:finish_trade()
end

function IngameWaitingForSpawnAllowed:begin_trade()
end

function IngameWaitingForSpawnAllowed:cancel_trade()
end

add_prints("IngameWaitingForSpawnAllowed", {
	"update",
	"_upd_watch",
	"_refresh_teammate_list"
})
