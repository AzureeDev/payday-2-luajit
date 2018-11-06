HUDStageEndCrimeSpreeScreen = HUDStageEndCrimeSpreeScreen or class()

function HUDStageEndCrimeSpreeScreen:init(hud, workspace)
	self._backdrop = MenuBackdropGUI:new(workspace)

	if not _G.IS_VR then
		self._backdrop:create_black_borders()
	end

	self._hud = hud
	self._workspace = workspace
	self._singleplayer = Global.game_settings.single_player
	local bg_font = tweak_data.menu.pd2_massive_font
	local title_font = tweak_data.menu.pd2_large_font
	local content_font = tweak_data.menu.pd2_medium_font
	local small_font = tweak_data.menu.pd2_small_font
	local bg_font_size = tweak_data.menu.pd2_massive_font_size
	local title_font_size = tweak_data.menu.pd2_large_font_size
	local content_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local massive_font = bg_font
	local large_font = title_font
	local medium_font = content_font
	local massive_font_size = bg_font_size
	local large_font_size = title_font_size
	local medium_font_size = content_font_size
	self._background_layer_safe = self._backdrop:get_new_background_layer()
	self._background_layer_full = self._backdrop:get_new_background_layer()
	self._foreground_layer_safe = self._backdrop:get_new_foreground_layer()
	self._foreground_layer_full = self._backdrop:get_new_foreground_layer()

	self._backdrop:set_panel_to_saferect(self._background_layer_safe)
	self._backdrop:set_panel_to_saferect(self._foreground_layer_safe)

	local mission = managers.crime_spree:get_mission(managers.crime_spree:current_played_mission())
	self._stage_name = managers.job:current_level_id() and managers.localization:to_upper_text(tweak_data.levels[mission.level.level_id].name_id) or ""

	self._foreground_layer_safe:text({
		name = "stage_text",
		vertical = "center",
		align = "right",
		text = self._stage_name,
		h = title_font_size,
		font_size = title_font_size,
		font = title_font,
		color = tweak_data.screen_colors.text
	})

	local bg_text = self._background_layer_full:text({
		name = "stage_text",
		vertical = "top",
		alpha = 0.4,
		align = "left",
		text = self._stage_name,
		h = bg_font_size,
		font_size = bg_font_size,
		font = bg_font,
		color = tweak_data.screen_colors.button_stage_3
	})

	bg_text:set_world_center_y(self._foreground_layer_safe:child("stage_text"):world_center_y())
	bg_text:set_world_x(self._foreground_layer_safe:child("stage_text"):world_x())
	bg_text:move(-13, 9)
	bg_text:set_visible(false)
	self._backdrop:animate_bg_text(bg_text)
end

function HUDStageEndCrimeSpreeScreen:hide()
	self._backdrop:hide()
end

function HUDStageEndCrimeSpreeScreen:show()
	self._backdrop:show()
end

function HUDStageEndCrimeSpreeScreen:update(t, dt)
end

function HUDStageEndCrimeSpreeScreen:update_layout()
	self._backdrop:_set_black_borders()
end

function HUDStageEndCrimeSpreeScreen:set_success(success, server_left)
	HUDStageEndScreen.set_success(self, success, server_left)
end

function HUDStageEndCrimeSpreeScreen:set_continue_button_text(text)
end

function HUDStageEndCrimeSpreeScreen:set_statistics(criminals_completed, success)
	HUDStageEndScreen.set_statistics(self, criminals_completed, success)
end

function HUDStageEndCrimeSpreeScreen:set_special_packages(params)
end

function HUDStageEndCrimeSpreeScreen:set_speed_up(multiplier)
end

function HUDStageEndCrimeSpreeScreen:set_group_statistics(...)
	HUDStageEndScreen.set_group_statistics(self, ...)
end

function HUDStageEndCrimeSpreeScreen:send_xp_data(data, done_clbk)
end
