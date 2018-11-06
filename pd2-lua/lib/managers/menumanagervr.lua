MenuManagerVR = MenuManager or Application:error("MenuManagerVR requires MenuManager!")

require("lib/units/beings/player/states/vr/playermenu")
require("lib/managers/menu/VRCustomizationGui")

local __init = MenuManager.init
local __update = MenuManager.update
local __destroy = MenuManager.destroy
local __open_menu = MenuManager.open_menu
local __close_menu = MenuManager.close_menu
local __post_event = MenuManager.post_event

function MenuManagerVR:init(is_start_menu)
	print("[MenuManagerVR] Init")

	self._exit_fade_in = {
		blend_mode = "normal",
		sustain = 0,
		play_paused = true,
		fade_in = 0,
		fade_out = 0.5,
		color = Color(1, 0, 0, 0),
		timer = TimerManager:game()
	}
	self._menu_screens = {}

	if is_start_menu then
		self:_load_scene()
	end

	self:_setup_workspaces(is_start_menu)

	self._vr_controller = managers.controller:get_vr_controller()

	__init(self, is_start_menu)

	if not is_start_menu then
		local system_menu = {
			input = "MenuInput",
			name = "system_menu",
			renderer = "MenuHiddenRenderer",
			id = "menu_room",
			content_file = "gamedata/menus/menu_room",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(system_menu)

		local waiting_for_players = {
			input = "MenuInput",
			name = "waiting_for_players",
			renderer = "MenuHiddenRenderer",
			id = "menu_room",
			content_file = "gamedata/menus/menu_room",
			callback_handler = MenuCallbackHandler:new(),
			on_enter = callback(self, self, "on_enter_menu_disable_ingame_camera")
		}

		self:register_menu(waiting_for_players)

		local zipline = {
			input = "MenuInput",
			name = "zipline",
			renderer = "MenuHiddenRenderer",
			id = "menu_room",
			content_file = "gamedata/menus/menu_room",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(zipline)

		local ingame_access_camera_menu = {
			input = "MenuInput",
			name = "ingame_access_camera_menu",
			renderer = "MenuHiddenRenderer",
			id = "menu_room",
			content_file = "gamedata/menus/menu_room",
			callback_handler = MenuCallbackHandler:new(),
			on_enter = callback(self, self, "on_enter_menu_disable_ingame_camera_active_bg")
		}

		self:register_menu(ingame_access_camera_menu)

		local custody = {
			input = "MenuInput",
			name = "custody",
			renderer = "MenuHiddenRenderer",
			id = "menu_room",
			content_file = "gamedata/menus/menu_room",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(custody)

		self._registered_menus.mission_end_menu.on_enter = callback(self, self, "on_enter_menu_disable_ingame_camera")
		self._registered_menus.loot_menu.on_enter = callback(self, self, "on_enter_menu_disable_ingame_camera")
	end
end

function MenuManagerVR:_setup_ingame_viewport()
	if not self._is_start_menu then
		self._ingame_camera_object = World:create_camera()

		self._ingame_camera_object:set_near_range(3)
		self._ingame_camera_object:set_far_range(1000000)
		self._ingame_camera_object:set_fov(75)
		self._ingame_camera_object:set_stereo(false)
		self._ingame_camera_object:set_aspect_ratio(1.7777777777777777)
		self._ingame_camera_object:set_position(Vector3(0, 3500, 700))
		self._ingame_camera_object:set_rotation(Rotation(180, -10, 0))

		local rt_resolution = self._player:render_target_resolution()
		local resolution = VRManager:target_resolution()
		local scale_x = rt_resolution.x / resolution.x
		local scale_y = rt_resolution.y / resolution.y
		self._ingame_viewport = managers.viewport:new_vp(0, 0, scale_x, scale_y, "menu_ingame_spectator", CoreManagerBase.PRIO_WORLDCAMERA)

		self._ingame_viewport:set_enable_adaptive_quality(false)
		self._ingame_viewport:set_camera(self._ingame_camera_object)
		self._ingame_camera_bm:set_image(self._player:render_target())
		self._ingame_camera_bm:set_blend_mode("solid")
		self._ingame_camera_bm:set_visible(true)
	end
end

function MenuManagerVR:set_override_ingame_camera(camera_object)
	self._override_camera = camera_object
	camera_object = camera_object or self._ingame_camera_object

	self._ingame_viewport:set_camera(camera_object)
end

function MenuManagerVR:init_finalize()
	if not self._is_start_menu then
		managers.system_menu:add_active_changed_callback(callback(self, self, "dialog_active_changed_callback"))
	end

	self._player = PlayerMenu:new(self._is_start_menu and Vector3(0, 100, 0) or Vector3(0, 0, 0), self._is_start_menu)

	self._player:attach_controller(self._controller)
	self:_setup_ingame_viewport()
	self:init_customization_gui()
end

function MenuManagerVR:init_customization_gui()
	self._customization_gui = self._customization_gui or VRCustomizationGui:new(self._is_start_menu)
end

function MenuManagerVR:initialize_customization_gui()
	if self._customization_gui then
		self._customization_gui:initialize()
	end
end

function MenuManagerVR:update(t, dt)
	__update(self, t, dt)

	if self._player and self._player:is_active() then
		if managers.player and not self._override_camera then
			local player = managers.player:player_unit()

			if player then
				local cam = player:camera()

				self._ingame_camera_object:set_position(cam:position())
				self._ingame_camera_object:set_rotation(cam:rotation())
			end
		end

		self._player:update(t, dt)
	end

	if self._customization_gui then
		self._customization_gui:update(t, dt)
	end
end

function MenuManagerVR:destroy()
	print("[MenuManagerVR] Destroy")
	managers.gui_data:set_scene_gui(nil)

	if self._player then
		self._player:destroy()

		self._player = nil
	end

	__destroy(self)
end

function MenuManagerVR:is_pc_controller()
	return true
end

function MenuManagerVR:open_menu(menu_name, ...)
	managers.vr:set_force_disable_low_adaptive_quality(true)

	local menu = self._registered_menus[menu_name]

	if menu then
		self:_enter_menu_room()
		self._player:attach_controller(menu.input._controller)
	end

	local is_open = self:is_open(menu_name)

	__open_menu(self, menu_name, ...)

	if not is_open and self:is_open(menu_name) and menu.on_enter then
		menu.on_enter()
	end

	print("[MenuManagerVR] Open ", menu_name)
end

function MenuManagerVR:close_menu(menu_name)
	managers.vr:set_force_disable_low_adaptive_quality(false)

	local menu = self._registered_menus[menu_name]

	if menu and self._player and self._player:is_active() then
		self._player:dettach_controller(menu.input._controller)
	end

	local is_open = self:is_open(menu_name)

	__close_menu(self, menu_name)

	if #self._open_menus == 0 and self._player and self._player:is_active() then
		self:_exit_menu_room()
	end

	if is_open and not self:is_open(menu_name) and menu.on_exit then
		menu.on_exit()
	end

	print("[MenuManagerVR] Close ", menu_name)
end

function MenuManagerVR:_load_scene()
	self._menu_unit = World:spawn_unit(Idstring("units/pd2_dlc_vr/menu/vr_menu"), Vector3(), Rotation())

	self._menu_unit:set_visible(false)

	local level_path = "levels/vr/menu"
	local t = {
		file_type = "world",
		file_path = level_path .. "/world"
	}

	assert(WorldHolder:new(t):create_world("world", "statics", Vector3()), "Cant load the level!")
end

function MenuManagerVR:_setup_workspaces(is_start_menu)
	if is_start_menu then
		managers.gui_data:set_scene_gui(World:gui())

		self._menu_screens.mid = self._menu_unit:get_object(Idstring("g_workspace_middle"))
		self._menu_screens.left = self._menu_unit:get_object(Idstring("g_workspace_left"))
		self._menu_screens.right = self._menu_unit:get_object(Idstring("g_workspace_right"))
	else
		managers.gui_data:set_scene_gui(MenuRoom:gui())

		self._menu_screens.mid = MenuRoom:get_object(Idstring("g_workspace_middle"))
		self._menu_screens.left = MenuRoom:get_object(Idstring("g_workspace_left"))
		self._menu_screens.right = MenuRoom:get_object(Idstring("g_workspace_middle"))
	end

	local mid = self._menu_screens.mid
	local left = self._menu_screens.left
	local right = self._menu_screens.right

	managers.gui_data:set_workspace_objects({
		mid = mid,
		left = left,
		right = right,
		default = mid
	})

	if not is_start_menu then
		self._ws_ingame_camera = managers.gui_data:create_saferect_workspace("mid")

		self._ws_ingame_camera:set_timer(TimerManager:main())

		local panel = self._ws_ingame_camera:panel()
		self._ingame_camera_bm = panel:bitmap()

		self._ingame_camera_bm:set_layer(0)
		self._ingame_camera_bm:set_width(panel:width())
		self._ingame_camera_bm:set_height(panel:height())
		self._ws_ingame_camera:panel():set_visible(true)
	end
end

function MenuManagerVR:dialog_active_changed_callback(active)
	if active then
		managers.menu:open_menu("system_menu")
	else
		managers.menu:close_menu("system_menu")
	end
end

function MenuManagerVR:screen(screen_id)
	return self._menu_screens[screen_id]
end

function MenuManagerVR:menu_unit()
	return self._menu_unit
end

function MenuManagerVR:set_primary_hand(hand)
	self._hand_index = hand == "right" and 0 or 1

	if self._player then
		self._player:set_primary_hand(hand)
	end
end

function MenuManagerVR:post_event(event)
	__post_event(self, event)
	self:post_event_vr(event)
end

local medium_pulse_events = {
	highlight = true,
	menu_skill_investment = true
}

function MenuManagerVR:post_event_vr(event)
	if event and medium_pulse_events[event] then
		self._vr_controller:trigger_haptic_pulse(self._hand_index, 0, 200)
	end
end

function MenuManagerVR:_enter_menu_room()
	if not self._player:is_active() then
		self._hand_index = managers.vr:get_setting("default_weapon_hand") == "right" and 0 or 1

		self._player:set_primary_hand(managers.vr:get_setting("default_weapon_hand"))
		self._player:start()

		if not self._is_start_menu then
			self._ingame_camera_bm:set_visible(true)
			self._ingame_viewport:set_active(true)
			self:set_ingame_subtitle_presenter(false)
		end
	end
end

function MenuManagerVR:_exit_menu_room()
	if self._player:is_active() then
		self._player:stop()

		if not self._is_start_menu and managers.vr:hand_state_machine() then
			managers.vr:hand_state_machine():refresh()
		end

		if not self._is_start_menu then
			self._ingame_viewport:set_active(false)

			if self._customization_gui then
				self._customization_gui:exit_menu()
			end

			self:set_ingame_subtitle_presenter(true)
		end

		managers.overlay_effect:play_effect(self._exit_fade_in)
	end
end

function MenuManagerVR:set_ingame_subtitle_presenter(ingame)
	local presenter = nil

	if ingame then
		presenter = CoreSubtitlePresenter.IngamePresenterVR:new(tweak_data.menu.pd2_medium_font, tweak_data.menu.pd2_medium_font_size, managers.hud:subtitle_workspace())
	else
		presenter = CoreSubtitlePresenter.OverlayPresenter:new(tweak_data.menu.pd2_medium_font, tweak_data.menu.pd2_medium_font_size)
	end

	managers.subtitle:set_presenter(presenter)
	presenter:show()
end

function MenuManagerVR:player()
	return self._player
end

function MenuManagerVR:on_enter_menu_disable_ingame_camera()
	self._ingame_camera_bm:set_visible(false)
	self._ingame_viewport:set_active(false)
end

function MenuManagerVR:on_enter_menu_disable_ingame_camera_active_bg()
	self._ingame_viewport:set_active(false)
end
