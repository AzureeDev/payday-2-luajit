require("lib/states/GameState")

BootupState = BootupState or class(GameState)

function BootupState:init(game_state_machine, setup)
	GameState.init(self, "bootup", game_state_machine)

	self._bootup_volume = 1

	if setup then
		self:setup()
	end
end

function BootupState:old()
	self._play_data_list = {
		{
			height = 200,
			can_skip = false,
			fade_in = 1.25,
			width = 600,
			fade_out = 1.25,
			visible = not is_win32,
			gui = Idstring("guis/autosave_warning"),
			duration = is_win32 and 0 or 6
		},
		{
			texture = "guis/textures/esrb_rating",
			fade_out = 1.25,
			fade_in = 1.25,
			layer = 1,
			visible = show_esrb,
			width = esrb_y * 2,
			height = esrb_y,
			can_skip = has_full_game,
			duration = show_esrb and 6.5 or 0
		},
		{
			texture = "guis/textures/soe_logo",
			height = 256,
			padding = 200,
			fade_out = 1.25,
			fade_in = 1.25,
			duration = 6,
			width = 256,
			layer = 1,
			can_skip = can_skip
		},
		{
			word_wrap = true,
			vertical = "center",
			wrap = true,
			font_size = 24,
			padding = 200,
			fade_in = 1.25,
			fade_out = 1.25,
			duration = 6,
			layer = 1,
			text = legal_text,
			font = tweak_data.menu.default_font,
			width = safe_rect_pixels.width,
			height = safe_rect_pixels.height,
			can_skip = can_skip
		},
		{
			video = "movies/company_logo",
			can_skip = true,
			padding = 200,
			layer = 1,
			width = res.x,
			height = res.y
		},
		{
			video = "movies/game_logo",
			can_skip = true,
			padding = 200,
			layer = 1,
			width = res.x,
			height = res.y
		}
	}
end

function BootupState:on_savefile_loaded(slot, success, is_setting_slot, cache_only)
	if is_setting_slot then
		self._bootup_volume = (managers.user:get_setting("sfx_volume") or 100) / 100

		if self._play_data and self._play_data.video and alive(self._gui_obj) then
			self._gui_obj:set_volume_gain(self._bootup_volume)
		end
	end
end

function BootupState:setup()
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local gui = Overlay:gui()
	local is_win32 = SystemInfo:platform() == Idstring("WIN32")
	local is_x360 = SystemInfo:platform() == Idstring("X360")
	local show_esrb = false

	if _G.IS_VR then
		self._full_workspace = managers.gui_data:create_fullscreen_workspace()
		res = Vector3(1280, 720, 0)
	else
		self._full_workspace = gui:create_screen_workspace()
	end

	self._workspace = managers.gui_data:create_saferect_workspace()
	self._back_drop_gui = MenuBackdropGUI:new()

	self._back_drop_gui:hide()
	self._workspace:hide()
	self._full_workspace:hide()
	managers.gui_data:layout_workspace(self._workspace)

	local esrb_y = safe_rect_pixels.height / 1.9
	local has_full_game = managers.dlc:has_full_game()
	local item_layer = self._back_drop_gui:background_layers()
	local intro_trailer_layer = self._back_drop_gui:foreground_layers()

	managers.savefile:add_load_done_callback(callback(self, self, "on_savefile_loaded"))

	self._play_data_list = {}

	table.insert(self._play_data_list, {
		fade_out = 1.25,
		height = 200,
		fade_in = 1.25,
		can_skip = false,
		width = 600,
		visible = not is_win32,
		layer = item_layer,
		gui = Idstring("guis/autosave_warning"),
		duration = is_win32 and 0 or 6
	})
	table.insert(self._play_data_list, {
		texture = "guis/textures/esrb_rating",
		fade_out = 1.25,
		fade_in = 1.25,
		visible = show_esrb,
		layer = item_layer,
		width = esrb_y * 2,
		height = esrb_y,
		can_skip = has_full_game,
		duration = show_esrb and 6.5 or 0
	})

	local play_intros = not Application:production_build()

	if play_intros then
		self:setup_intro_videos()
	end

	self._full_panel = self._full_workspace:panel()
	self._panel = self._workspace:panel()

	self._full_panel:rect({
		layer = 0,
		visible = false,
		color = Color.red
	})

	self._controller_list = {}

	for index = 1, managers.controller:get_wrapper_count() do
		local con = managers.controller:create_controller("boot_" .. index, index, false)

		con:enable()

		self._controller_list[index] = con
	end
end

function BootupState:setup_intro_videos()
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local legal_text = managers.localization:text("legal_text")
	local item_layer = self._back_drop_gui:background_layers()
	local intro_trailer_layer = self._back_drop_gui:foreground_layers()

	table.insert(self._play_data_list, {
		video = "movies/intro_trailer",
		can_skip = true,
		padding = 200,
		limit_file_streamer = true,
		layer = intro_trailer_layer,
		width = res.x,
		height = res.y
	})
	table.insert(self._play_data_list, {
		word_wrap = true,
		vertical = "center",
		wrap = true,
		font_size = 24,
		padding = 200,
		fade_in = 1.25,
		fade_out = 1.25,
		can_skip = true,
		duration = 6,
		layer = item_layer,
		text = legal_text,
		font = tweak_data.menu.pd2_medium_font,
		width = safe_rect_pixels.width,
		height = safe_rect_pixels.height
	})
	table.insert(self._play_data_list, {
		video = "movies/game_intro",
		can_skip = true,
		padding = 200,
		layer = item_layer,
		width = res.x,
		height = res.y
	})
end

function BootupState:at_enter()
	managers.menu:input_enabled(false)

	if not self._controller_list then
		self:setup()
		Application:stack_dump_error("Shouldn't enter boot state more than once. Except when toggling freeflight.")
	end

	self._sound_listener = SoundDevice:create_listener("main_menu")

	self._sound_listener:activate(true)
	self._workspace:show()
	self._full_workspace:show()
	self._back_drop_gui:show()

	self._clbk_game_has_music_control_callback = callback(self, self, "clbk_game_has_music_control")

	managers.platform:add_event_callback("media_player_control", self._clbk_game_has_music_control_callback)

	if _G.IS_VR then
		managers.menu:_enter_menu_room()
	end

	self._wait_for_textures = _G.IS_VR

	if not self._wait_for_textures then
		self:play_next()
	end

	if Global.exe_argument_level then
		self:gsm():change_state_by_name("menu_titlescreen")
	end
end

function BootupState:clbk_game_has_music_control(status)
	if self._play_data and self._play_data.video then
		self._gui_obj:set_volume_gain(status and self._bootup_volume or 0)
	end
end

function BootupState:update(t, dt)
	if self._wait_for_textures then
		if TextureCache:check_textures_loaded() then
			self._wait_for_textures = false

			managers.vr:stop_loading()
			managers.overlay_effect:play_effect(tweak_data.overlay_effects.level_fade_in)
			setup:set_main_thread_loading_screen_visible(false)
		end

		return
	end

	self:check_confirm_pressed()

	if not self:is_playing() or (self._play_data and self._play_data.can_skip or Global.override_bootup_can_skip) and self:is_skipped() then
		self:play_next(self:is_skipped())
	else
		self:update_fades()
	end
end

function BootupState:check_confirm_pressed()
	for index, controller in ipairs(self._controller_list) do
		if controller:get_input_pressed("confirm") then
			print("check_confirm_pressed")

			local active, dialog = managers.system_menu:is_active_by_id("invite_join_message")

			if active then
				print("close")
				dialog:button_pressed_callback()
			end
		end
	end
end

function BootupState:update_fades()
	local time, duration = nil
	local old_fade = self._fade
	self._fade = 1

	if self._play_data then
		if self._play_data.video then
			duration = self._gui_obj:length()
			local frames = self._gui_obj:frames()

			if frames > 0 then
				time = self._gui_obj:frame_num() / frames * duration
			else
				time = 0
			end
		else
			time = TimerManager:game():time() - self._play_time
			duration = self._play_data.duration
		end

		if self._play_data.fade_in and time < self._play_data.fade_in then
			if self._play_data.fade_in > 0 then
				self._fade = time / self._play_data.fade_in
			else
				self._fade = 1
			end
		elseif self._play_data.fade_in and duration - time < self._play_data.fade_out then
			if self._play_data.fade_out > 0 then
				self._fade = (duration - time) / self._play_data.fade_out
			else
				self._fade = 0
			end
		end
	end

	if self._fade ~= old_fade then
		self:apply_fade()
	end
end

function BootupState:apply_fade()
	if self._play_data and self._play_data.gui then
		local script = self._gui_obj.script and self._gui_obj:script()

		if script.set_fade then
			script:set_fade(self._fade)
		else
			Application:error("GUI \"" .. tostring(self._play_data.gui) .. "\" lacks a function set_fade( o, fade ).")
		end
	else
		self._gui_obj:set_color(self._gui_obj:color():with_alpha(self._fade))
	end
end

function BootupState:is_skipped()
	for _, controller in ipairs(self._controller_list) do
		if controller:get_any_input_pressed() then
			return true
		end
	end

	return false
end

function BootupState:is_playing()
	if alive(self._gui_obj) then
		if self._gui_obj.loop_count then
			return self._gui_obj:loop_count() < 1
		elseif self._play_data then
			return TimerManager:game():time() < self._play_time + self._play_data.duration
		end
	end

	return false
end

function BootupState:play_next(is_skipped)
	self._play_time = TimerManager:game():time()
	self._play_index = (self._play_index or 0) + 1
	self._play_data = self._play_data_list[self._play_index]

	if is_skipped then
		while self._play_data and self._play_data.auto_skip do
			self._play_index = self._play_index + 1
			self._play_data = self._play_data_list[self._play_index]
		end
	end

	if self._play_data then
		if self._play_data.limit_file_streamer then
			managers.dyn_resource:set_file_streaming_chunk_size_mul(0.05, 10)

			self._limit_file_streamer = true
		elseif self._limit_file_streamer then
			managers.dyn_resource:set_file_streaming_chunk_size_mul(1, 3)

			self._limit_file_streamer = false
		end

		self._fade = self._play_data.fade_in and 0 or 1

		if alive(self._gui_obj) then
			self._panel:remove(self._gui_obj)

			if alive(self._gui_obj) then
				self._full_panel:remove(self._gui_obj)
			end

			self._gui_obj = nil
		end

		local res = RenderSettings.resolution

		if _G.IS_VR then
			res = Vector3(1280, 720, 0)
		end

		local width, height = nil
		local padding = self._play_data.padding or 0

		if self._play_data.gui then
			if self._play_data.width / self._play_data.height > res.x / res.y then
				width = res.x - padding * 2
				height = self._play_data.height * width / self._play_data.width
			else
				height = self._play_data.height
				width = self._play_data.width
			end
		else
			height = self._play_data.height
			width = self._play_data.width
		end

		local x = (self._panel:w() - width) / 2
		local y = (self._panel:h() - height) / 2
		local gui_config = {
			x = x,
			y = y,
			width = width,
			height = height,
			layer = tweak_data.gui.BOOT_SCREEN_LAYER
		}

		if self._play_data.video then
			gui_config.video = self._play_data.video
			gui_config.layer = self._play_data.layer or gui_config.layer
			self._gui_obj = self._full_panel:video(gui_config)

			self._gui_obj:set_volume_gain(self._bootup_volume)

			if not managers.music:has_music_control() then
				self._gui_obj:set_volume_gain(0)
			end

			local w = self._gui_obj:video_width()
			local h = self._gui_obj:video_height()
			local m = h / w

			self._gui_obj:set_size(res.x, res.x * m)
			self._gui_obj:set_center(res.x / 2, res.y / 2)
			self._gui_obj:play()
		elseif self._play_data.texture then
			gui_config.texture = self._play_data.texture
			self._gui_obj = self._panel:bitmap(gui_config)
		elseif self._play_data.text then
			gui_config.text = self._play_data.text
			gui_config.font = self._play_data.font
			gui_config.font_size = self._play_data.font_size
			gui_config.wrap = self._play_data.wrap
			gui_config.word_wrap = self._play_data.word_wrap
			gui_config.vertical = self._play_data.vertical
			self._gui_obj = self._panel:text(gui_config)
		elseif self._play_data.gui then
			self._gui_obj = self._panel:gui(self._play_data.gui)

			self._gui_obj:set_shape(x, y, width, height)

			local script = self._gui_obj:script()

			if script.setup then
				script:setup()
			end
		end

		self:apply_fade()
	else
		self:gsm():change_state_by_name("menu_titlescreen")
	end
end

function BootupState:at_exit()
	managers.platform:remove_event_callback("media_player_control", self._clbk_game_has_music_control_callback)

	if alive(self._workspace) then
		managers.gui_data:destroy_workspace(self._workspace)

		self._workspace = nil
		self._gui_obj = nil
	end

	if alive(self._full_workspace) then
		if _G.IS_VR then
			managers.gui_data:destroy_workspace(self._full_workspace)
		else
			Overlay:gui():destroy_workspace(self._full_workspace)
		end

		self._full_workspace = nil
	end

	self._back_drop_gui:destroy()

	if self._controller_list then
		for _, controller in ipairs(self._controller_list) do
			controller:destroy()
		end

		self._controller_list = nil
	end

	if self._sound_listener then
		self._sound_listener:delete()

		self._sound_listener = nil
	end

	self._play_data_list = nil
	self._play_index = nil
	self._play_data = nil

	managers.menu:input_enabled(true)

	if PackageManager:loaded("packages/boot_screen") then
		PackageManager:unload("packages/boot_screen")
	end
end
