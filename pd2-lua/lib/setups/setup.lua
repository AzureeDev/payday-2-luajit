_G.IS_VR = _G.SystemInfo ~= nil and getmetatable(_G.SystemInfo).is_vr ~= nil and SystemInfo:is_vr()

core:register_module("lib/managers/PlatformManager")
core:register_module("lib/managers/SystemMenuManager")
core:register_module("lib/managers/UserManager")
core:register_module("lib/managers/SequenceManager")
core:register_module("lib/managers/ControllerManager")
core:register_module("lib/managers/SlotManager")
core:register_module("lib/managers/DebugManager")
core:register_module("lib/utils/game_state_machine/GameState")
core:register_module("lib/utils/dev/FreeFlight")

Global.DEBUG_MENU_ON = Application:debug_enabled()
Global.SKIP_OVERKILL_290 = SystemInfo:platform() == Idstring("PS3")
Global.DISCORD_APP_ID = "364785249202208768"

core:import("CoreSetup")
require("lib/managers/DLCManager")

managers.dlc = DLCManager:new()

require("lib/tweak_data/TweakData")
require("lib/utils/Utl")
require("lib/utils/SequenceActivator")
require("lib/utils/PropertyManager")
require("lib/utils/TemporaryPropertyManager")
require("lib/player_actions/PlayerAction")
require("lib/utils/PlayerSkill")
require("lib/utils/FrameCallback")
require("lib/utils/MessageSystem")
require("lib/utils/CoroutineManager")
require("lib/utils/EventListenerHolder")
require("lib/utils/Quickhull")
require("lib/utils/Easing")
require("lib/utils/DateTime")
require("lib/managers/UpgradesManager")
require("lib/managers/ExperienceManager")
require("lib/managers/PlayerManager")
require("lib/managers/SavefileManager")
require("lib/managers/MenuManager")
require("lib/managers/AchievmentManager")
require("lib/managers/SkillTreeManager")
require("lib/managers/DynamicResourceManager")
require("lib/managers/InfamyManager")
require("lib/managers/VehicleManager")
require("lib/managers/FireManager")
require("lib/managers/SyncManager")
core:import("PlatformManager")
core:import("SystemMenuManager")
core:import("UserManager")
core:import("ControllerManager")
core:import("SlotManager")
core:import("FreeFlight")
core:import("CoreGuiDataManager")

if _G.IS_VR then
	require("lib/managers/VRManagerPD2")
	require("lib/managers/subtitle/SubtitlePresenterVR")
end

require("lib/managers/ControllerWrapper")
require("lib/utils/game_state_machine/GameStateMachine")
require("lib/utils/LightLoadingScreenGuiScript")
require("lib/managers/LocalizationManager")
require("lib/managers/MousePointerManager")
require("lib/managers/VideoManager")
require("lib/managers/menu/TextBoxGui")
require("lib/managers/menu/ButtonBoxGui")
require("lib/managers/menu/BookBoxGui")
require("lib/managers/menu/FriendsBoxGui")
require("lib/managers/menu/CircleGuiObject")
require("lib/managers/menu/BoxGuiObject")
require("lib/managers/menu/NewsFeedGui")
require("lib/managers/menu/ImageBoxGui")
require("lib/managers/menu/ScrollablePanel")
require("lib/managers/menu/SpecializationBoxGui")
require("lib/managers/menu/ProfileBoxGui")
require("lib/managers/menu/ContractBoxGui")
require("lib/managers/menu/ServerStatusBoxGui")
require("lib/managers/menu/DebugStringsBoxGui")
require("lib/managers/menu/DebugDrawFonts")
require("lib/managers/menu/MenuBackdropGUI")
require("lib/managers/SimpleGUIEffectSpewer")
require("lib/managers/WeaponFactoryManager")
require("lib/managers/BlackMarketManager")
require("lib/managers/CrimeNetManager")
require("lib/managers/LootDropManager")
require("lib/managers/ChatManager")
require("lib/managers/LootManager")
require("lib/managers/JobManager")
require("lib/managers/VoiceBriefingManager")
require("lib/managers/FeatureManager")
require("lib/managers/ChallengeManager")
require("lib/managers/MissionAssetsManager")
require("lib/managers/GageAssignmentManager")
require("lib/managers/PrePlanningManager")
require("lib/managers/MusicManager")
require("lib/managers/VoteManager")
require("lib/units/UnitDamage")
require("lib/units/props/DigitalGui")
require("lib/units/props/TextGui")
require("lib/units/props/MagazineUnitDamage")
require("lib/units/props/MaterialControl")
require("lib/units/props/ManageSpawnedUnits")
require("lib/units/props/WaypointExt")
require("lib/managers/ButlerMirroringManager")
require("lib/managers/MultiProfileManager")
require("lib/managers/BanListManager")
require("lib/managers/WorkshopManager")
require("lib/managers/CustomSafehouseManager")
require("lib/managers/MutatorsManager")
require("lib/managers/OverlayEffectManager")
require("lib/managers/EnvironmentControllerManager")
require("lib/managers/TangoManager")
require("lib/managers/CrimeSpreeManager")
require("lib/managers/StoryMissionsManager")
require("lib/managers/PromoUnlockManager")
require("lib/managers/GenericSideJobsManager")
require("lib/managers/SideJobGenericDLCManager")
require("lib/managers/RaidJobsManager")
require("lib/managers/ModifiersManager")
require("lib/managers/SkirmishManager")
require("lib/utils/StatisticsGenerator")
require("lib/utils/Bitwise")
require("lib/utils/WeightedSelector")
require("lib/units/MaskExt")
require("lib/utils/dev/api/TestAPI")

script_data = script_data or {}
game_state_machine = game_state_machine or nil
Setup = Setup or class(CoreSetup.CoreSetup)
_next_update_funcs = _next_update_funcs or {}
local next_update_funcs_busy = nil

function call_on_next_update(func, optional_key)
	if not optional_key then
		table.insert(_next_update_funcs, func)
	else
		local key = optional_key == true and func or optional_key
		_next_update_funcs[key] = func
	end
end

function call_next_update_functions()
	local current = _next_update_funcs
	_next_update_funcs = {}

	for _, func in pairs(current) do
		func()
	end
end

function Setup:init_category_print()
	CoreSetup.CoreSetup.init_category_print(self)

	if Global.category_print_initialized.setup then
		return
	end

	if not Global.interface_sound then
		-- Nothing
	end

	local cat_list = {
		"dialog_manager",
		"user_manager",
		"exec_manager",
		"savefile_manager",
		"loading_environment",
		"player_intel",
		"player_damage",
		"player_action",
		"AI_action",
		"bt",
		"dummy_ai",
		"dummy_block_chance",
		"johan",
		"george",
		"qa",
		"bob",
		"jansve",
		"sound_placeholder",
		"spam"
	}

	for _, cat in ipairs(cat_list) do
		Global.category_print[cat] = false
	end

	catprint_load()
end

function Setup:load_packages()
	PackageManager:set_resource_loaded_clbk(Idstring("unit"), nil)
	TextureCache:set_streaming_enabled(true)

	if SystemInfo:platform() == Idstring("PS4") or SystemInfo:platform() == Idstring("XB1") then
		TextureCache:set_LOD_streaming_enabled(false)
	else
		TextureCache:set_LOD_streaming_enabled(true)
	end

	if not Application:editor() then
		PackageManager:set_streaming_enabled(true)
	end

	if not PackageManager:loaded("packages/base") then
		PackageManager:load("packages/base")
	end

	if not PackageManager:loaded("packages/dyn_resources") then
		PackageManager:load("packages/dyn_resources")
	end

	if Application:ews_enabled() and not PackageManager:loaded("packages/production/editor") then
		PackageManager:load("packages/production/editor")
	end
end

function Setup:init_managers(managers)
	Global.game_settings = Global.game_settings or {
		is_playing = false,
		auto_kick = true,
		drop_in_option = 1,
		permission = "public",
		job_plan = -1,
		search_modded_lobbies = true,
		search_appropriate_jobs = true,
		gamemode = "standard",
		drop_in_allowed = true,
		reputation_permission = 0,
		difficulty = "normal",
		team_ai_option = 1,
		team_ai = true,
		kick_option = 1,
		one_down = false,
		allow_modded_players = true,
		search_one_down_lobbies = false,
		level_id = managers.dlc:is_trial() and "bank_trial" or "branchbank"
	}

	managers.dlc:setup()

	if _G.IS_VR then
		managers.vr = VRManagerPD2:new()
	end

	managers.dyn_resource = DynamicResourceManager:new()
	managers.gui_data = CoreGuiDataManager.GuiDataManager:new()
	managers.platform = PlatformManager.PlatformManager:new()
	managers.music = MusicManager:new()
	managers.system_menu = SystemMenuManager.SystemMenuManager:new()
	managers.achievment = AchievmentManager:new()
	managers.savefile = SavefileManager:new()
	managers.user = UserManager.UserManager:new()
	managers.upgrades = UpgradesManager:new()
	managers.experience = ExperienceManager:new()
	managers.skilltree = SkillTreeManager:new()
	managers.player = PlayerManager:new()
	managers.video = VideoManager:new()
	managers.menu = MenuManager:new(self.IS_START_MENU)

	managers.subtitle:set_presenter(CoreSubtitlePresenter.OverlayPresenter:new(tweak_data.menu.pd2_medium_font, tweak_data.menu.pd2_medium_font_size))

	managers.mouse_pointer = MousePointerManager:new()
	managers.weapon_factory = WeaponFactoryManager:new()
	managers.blackmarket = BlackMarketManager:new()
	managers.crimenet = CrimeNetManager:new()
	managers.lootdrop = LootDropManager:new()
	managers.chat = ChatManager:new()
	managers.menu_component = MenuComponentManager:new()
	managers.loot = LootManager:new()
	managers.job = JobManager:new()
	managers.briefing = VoiceBriefingManager:new()
	managers.infamy = InfamyManager:new()
	managers.features = FeatureManager:new()
	managers.challenge = ChallengeManager:new()
	managers.gage_assignment = GageAssignmentManager:new()
	managers.assets = MissionAssetsManager:new()
	managers.preplanning = PrePlanningManager:new()
	managers.vote = VoteManager:new()
	managers.vehicle = VehicleManager:new()
	managers.fire = FireManager:new()
	managers.sync = SyncManager:new()
	managers.modifiers = ModifiersManager:new()
	managers.multi_profile = MultiProfileManager:new()
	managers.workshop = WorkshopManager:new()

	Discord:init(Global.DISCORD_APP_ID)

	managers.custom_safehouse = CustomSafehouseManager:new()
	managers.ban_list = BanListManager:new()
	managers.skirmish = SkirmishManager:new()
	managers.mutators = MutatorsManager:new()
	managers.butler_mirroring = ButlerMirroringManager:new()
	managers.generic_side_jobs = GenericSideJobsManager:new()
	managers.tango = TangoManager:new()
	managers.crime_spree = CrimeSpreeManager:new()
	managers.story = StoryMissionsManager:new()
	managers.promo_unlocks = PromoUnlockManager:new()
	managers.raid_jobs = RaidJobsManager:new()

	managers.savefile:load_settings()

	game_state_machine = GameStateMachine:new()
end

function Setup:start_boot_loading_screen()
	if _G.IS_VR then
		VRManager:fade_to_color(0, Color(1, 0, 0, 0), false)

		Global._boot_fade = true
	end

	if not PackageManager:loaded("packages/boot_screen") then
		PackageManager:load("packages/boot_screen")
	end

	self:_start_loading_screen()
end

function Setup:start_loading_screen()
	self:_start_loading_screen()
end

function Setup:stop_loading_screen()
	if Global.is_loading then
		cat_print("loading_environment", "[LoadingEnvironment] Stop.")

		if not Global._boot_fade then
			self:set_main_thread_loading_screen_visible(false)
		else
			Global._boot_fade = nil
		end

		LoadingEnvironment:stop()

		Global.is_loading = nil
	else
		Application:stack_dump_error("[LoadingEnvironment] Tried to stop loading screen when it wasn't started.")
	end
end

function Setup:_start_loading_screen()
	if Global.is_loading then
		Application:stack_dump_error("[LoadingEnvironment] Tried to start loading screen when it was already started.")

		return
	elseif not SystemInfo:threaded_renderer() then
		cat_print("loading_environment", "[LoadingEnvironment] Skipped (renderer is not threaded).")

		Global.is_loading = true

		return
	end

	cat_print("loading_environment", "[LoadingEnvironment] Start.")

	local setup = nil

	if not LoadingEnvironmentScene:loaded() then
		LoadingEnvironmentScene:load("levels/zone", false)
	end

	local load_level_data = nil

	if Global.load_level then
		if not PackageManager:loaded("packages/load_level") then
			PackageManager:load("packages/load_level")
		end

		local using_steam_controller = false
		local show_controller = managers.user:get_setting("loading_screen_show_controller")
		local show_hints = managers.user:get_setting("loading_screen_show_hints")
		setup = "lib/setups/LevelLoadingSetup"
		load_level_data = {
			level_data = Global.level_data,
			level_tweak_data = tweak_data.levels[Global.level_data.level_id] or {}
		}
		load_level_data.level_tweak_data.name = load_level_data.level_tweak_data.name_id and managers.localization:text(load_level_data.level_tweak_data.name_id)
		load_level_data.gui_tweak_data = tweak_data.load_level
		load_level_data.menu_tweak_data = tweak_data.menu
		load_level_data.scale_tweak_data = tweak_data.scale

		if show_hints then
			load_level_data.tip = tweak_data.tips:get_a_tip()
		end

		if show_controller then
			if not using_steam_controller then
				local coords = tweak_data:get_controller_help_coords()
				load_level_data.controller_coords = coords and coords[table.random({
					"normal",
					"vehicle"
				})]
				load_level_data.controller_image = "guis/textures/controller"
				load_level_data.controller_shapes = {
					{
						position = {
							cy = 0.5,
							cx = 0.5
						},
						texture_rect = {
							0,
							0,
							512,
							256
						}
					}
				}
			end

			if load_level_data.controller_coords then
				for id, data in pairs(load_level_data.controller_coords) do
					data.string = data.localize == false and data.id or managers.localization:to_upper_text(data.id)
					data.color = (data.id == "menu_button_unassigned" or data.localize == false) and Color(0.5, 0.5, 0.5) or Color.white
				end
			end
		end

		local load_data = load_level_data.level_tweak_data.load_data
		local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
		local safe_rect = managers.viewport:get_safe_rect()
		local aspect_ratio = managers.viewport:aspect_ratio()
		local res = RenderSettings.resolution
		local job_data = managers.job:current_job_data() or {}
		local bg_texture = load_level_data.level_tweak_data.load_screen or job_data.load_screen or load_data and load_data.image
		load_level_data.gui_data = {
			safe_rect_pixels = safe_rect_pixels,
			safe_rect = safe_rect,
			aspect_ratio = aspect_ratio,
			res = res,
			workspace_size = {
				x = 0,
				y = 0,
				w = res.x,
				h = res.y
			},
			saferect_size = {
				x = safe_rect.x,
				y = safe_rect.y,
				w = safe_rect.width,
				h = safe_rect.height
			},
			bg_texture = bg_texture or "guis/textures/loading/loading_bg"
		}
	elseif not Global.boot_loading_environment_done then
		setup = "lib/setups/LightLoadingSetup"
	else
		setup = "lib/setups/HeavyLoadingSetup"
	end

	self:_setup_loading_environment()

	local data = {
		res = RenderSettings.resolution,
		layer = tweak_data.gui.LOADING_SCREEN_LAYER,
		load_level_data = load_level_data,
		is_win32 = SystemInfo:platform() == Idstring("WIN32"),
		vr_overlays = Global.__vr_overlays
	}

	LoadingEnvironment:start(setup, "LoadingEnvironmentScene", data)

	Global.is_loading = true
end

function Setup:_setup_loading_environment()
	local env_map = {
		deferred = {
			shadow = {
				shadow_slice_depths = Vector3(800, 1600, 5500),
				shadow_slice_overlap = Vector3(150, 300, 400),
				slice0 = Vector3(0, 800, 0),
				slice1 = Vector3(650, 1600, 0),
				slice2 = Vector3(1300, 5500, 0),
				slice3 = Vector3(5100, 17500, 0)
			},
			apply_ambient = {
				ambient_falloff_scale = 0,
				effect_light_scale = 1,
				ambient_color_scale = 0.31999999284744,
				ambient_scale = 1,
				ambient_color = Vector3(1, 1, 1),
				sky_top_color = Vector3(0, 0, 0),
				sky_bottom_color = Vector3(0, 0, 0)
			}
		},
		shadow_processor = {
			shadow_modifier = {
				slice0 = Vector3(0, 800, 0),
				slice1 = Vector3(650, 1600, 0),
				slice2 = Vector3(1300, 5500, 0),
				slice3 = Vector3(5100, 17500, 0),
				shadow_slice_depths = Vector3(800, 1600, 5500),
				shadow_slice_overlap = Vector3(150, 300, 400)
			}
		}
	}
	local dummy_vp = Application:create_world_viewport(0, 0, 1, 1)

	LoadingEnvironment:viewport():set_post_processor_effect("World", Idstring("hdr_post_processor"), Idstring("empty"))
	LoadingEnvironment:viewport():set_post_processor_effect("World", Idstring("bloom_combine_post_processor"), Idstring("bloom_combine_empty"))
	Application:destroy_viewport(dummy_vp)
end

function Setup:init_game()
	if not Global.initialized then
		Global.level_data = {}
		Global.initialized = true
	end

	self._end_frame_clbks = {}
	local scene_gui = Overlay:gui()
	self._main_thread_loading_screen_gui_script = LightLoadingScreenGuiScript:new(scene_gui, RenderSettings.resolution, -1, tweak_data.gui.LOADING_SCREEN_LAYER, SystemInfo:platform() == Idstring("WIN32"))
	self._main_thread_loading_screen_gui_visible = true

	return game_state_machine
end

function Setup:init_finalize()
	Setup.super.init_finalize(self)
	game_state_machine:init_finilize()
	managers.dlc:init_finalize()
	managers.achievment:init_finalize()
	managers.system_menu:init_finalize()
	managers.menu:init_finalize()
	managers.controller:init_finalize()

	if Application:editor() then
		managers.user:init_finalize()
	end

	managers.player:init_finalize()
	managers.blackmarket:init_finalize()

	if SystemInfo:platform() == Idstring("WIN32") then
		AnimationManager:set_anim_cache_size(10485760, 0)
	end

	tweak_data:add_reload_callback(self, self.on_tweak_data_reloaded)

	if _G.IS_VR then
		managers.vr:init_finalize()
	end

	managers.skirmish:init_finalize()
end

function Setup:update(t, dt)
	local main_t = TimerManager:main():time()
	local main_dt = TimerManager:main():delta_time()

	self:_upd_unload_packages()

	if _G.IS_VR then
		managers.vr:update(t, dt)
	end

	call_next_update_functions()
	managers.weapon_factory:update(t, dt)
	managers.platform:update(t, dt)
	managers.user:update(t, dt)
	managers.dyn_resource:update()
	managers.system_menu:update(main_t, main_dt)
	managers.savefile:update(t, dt)
	managers.menu:update(main_t, main_dt)

	if managers.menu_scene then
		managers.menu_scene:update(t, dt)
	end

	managers.menu_component:update(t, dt)
	managers.player:update(t, dt)
	managers.blackmarket:update(t, dt)
	managers.vote:update(t, dt)
	managers.vehicle:update(t, dt)
	managers.mutators:update(t, dt)
	managers.crime_spree:update(t, dt)
	game_state_machine:update(t, dt)

	if self._main_thread_loading_screen_gui_visible then
		self._main_thread_loading_screen_gui_script:update(-1, dt)
	end

	TestAPIHelper.update(t, dt)
end

function Setup:paused_update(t, dt)
	self:_upd_unload_packages()

	if _G.IS_VR then
		managers.vr:paused_update(t, dt)
	end

	managers.platform:paused_update(t, dt)
	managers.user:paused_update(t, dt)
	managers.dyn_resource:update()
	managers.system_menu:paused_update(t, dt)
	managers.savefile:paused_update(t, dt)
	managers.menu:update(t, dt)

	if managers.menu_scene then
		managers.menu_scene:update(t, dt)
	end

	managers.menu_component:update(t, dt)
	managers.blackmarket:update(t, dt)
	game_state_machine:paused_update(t, dt)
	TestAPIHelper.update(t, dt)
end

function Setup:end_update(t, dt)
	if _G.IS_VR then
		managers.vr:end_update(t, dt)
	end

	game_state_machine:end_update(t, dt)

	while #self._end_frame_clbks > 0 do
		table.remove(self._end_frame_clbks, 1)()
	end
end

function Setup:paused_end_update(t, dt)
	if _G.IS_VR then
		managers.vr:end_update(t, dt)
	end

	game_state_machine:end_update(t, dt)

	while #self._end_frame_clbks > 0 do
		table.remove(self._end_frame_clbks, 1)()
	end
end

function Setup:pre_render()
	if _G.IS_VR then
		managers.vr:pre_render()
	end
end

function Setup:render()
	if _G.IS_VR then
		managers.vr:render()
	end
end

function Setup:end_frame(t, dt)
	while self._end_frame_callbacks and #self._end_frame_callbacks > 0 do
		table.remove(self._end_frame_callbacks)()
	end
end

function Setup:add_end_frame_callback(callback)
	self._end_frame_callbacks = self._end_frame_callbacks or {}

	table.insert(self._end_frame_callbacks, callback)
end

function Setup:add_end_frame_clbk(func)
	table.insert(self._end_frame_clbks, func)
end

function Setup:on_tweak_data_reloaded()
	managers.dlc:on_tweak_data_reloaded()
end

function Setup:destroy()
	if _G.IS_VR then
		managers.vr:destroy()
	end

	managers.system_menu:destroy()
	managers.menu:destroy()

	if self._main_thread_loading_screen_gui_script then
		self._main_thread_loading_screen_gui_script:destroy()

		self._main_thread_loading_screen_gui_script = nil
	end
end

function Setup:load_level(level, mission, world_setting, level_class_name, level_id)
	if _G.IS_VR then
		managers.vr:start_loading()
	end

	managers.menu:close_all_menus()
	managers.platform:destroy_context()

	Global.load_level = true
	Global.load_start_menu = false
	Global.load_start_menu_lobby = false
	Global.load_crime_net = false
	Global.level_data.level = level
	Global.level_data.mission = mission
	Global.level_data.world_setting = world_setting
	Global.level_data.level_class_name = level_class_name
	Global.level_data.level_id = level_id

	managers.mutators:globalize_active_mutators()
	self:exec(level)
end

function Setup:load_start_menu_lobby()
	self:load_start_menu()

	Global.load_start_menu_lobby = true
end

function Setup:load_start_menu()
	if _G.IS_VR then
		self:set_main_thread_loading_screen_visible(true)
		managers.vr:start_loading()

		if managers.overlay_effect then
			managers.overlay_effect:set_hmd_tracking(true)
		end
	end

	managers.platform:set_playing(false)
	managers.job:deactivate_current_job()
	managers.gage_assignment:deactivate_assignments()
	managers.menu:close_all_menus()
	managers.mission:pre_destroy()
	managers.platform:destroy_context()

	Global.load_level = false
	Global.load_start_menu = true
	Global.load_start_menu_lobby = false
	Global.level_data.level = nil
	Global.level_data.mission = nil
	Global.level_data.world_setting = nil
	Global.level_data.level_class_name = nil
	Global.level_data.level_id = nil

	managers.mutators:clear_global_mutators()
	self:exec(nil)

	managers.butler_mirroring = ButlerMirroringManager:new()
end

function Setup:exec(context)
	if managers.network then
		if SystemInfo:platform() == Idstring("PS4") then
			PSN:set_matchmaking_callback("session_destroyed", function ()
			end)
		end

		print("SETTING BLACK LOADING SCREEN")

		self._black_loading_screen = true

		if Network.set_loading_state then
			Network:set_loading_state(true)
		end
	end

	if SystemInfo:platform() == Idstring("WIN32") then
		self:set_fps_cap(30)
	end

	managers.music:stop()
	managers.vote:stop()
	SoundDevice:stop()

	if not managers.system_menu:is_active() then
		self:set_main_thread_loading_screen_visible(true)
	end

	CoreSetup.CoreSetup.exec(self, context)
end

function Setup:quit()
	CoreSetup.CoreSetup.quit(self)

	if not managers.system_menu:is_active() then
		self:set_main_thread_loading_screen_visible(true)
		self._main_thread_loading_screen_gui_script:set_text("Exiting")
	end
end

function Setup:restart()
	local data = Global.level_data

	if data.level then
		self:load_level(data.level, data.mission, data.world_setting, data.level_class_name)
	else
		self:load_start_menu()
	end
end

function Setup:block_exec()
	if not self._main_thread_loading_screen_gui_visible then
		self:set_main_thread_loading_screen_visible(true)

		return true
	end

	local result = false

	if self._packages_to_unload then
		print("BLOCKED BY UNLOADING PACKAGES")

		result = true
	elseif not self._packages_to_unload_gathered then
		self._packages_to_unload_gathered = true

		self:gather_packages_to_unload()

		result = true
	end

	if not managers.network:is_ready_to_load() then
		print("BLOCKED BY STOPPING NETWORK")

		result = true
	end

	if not managers.dyn_resource:is_ready_to_close() then
		print("BLOCKED BY DYNAMIC RESOURCE MANAGER")
		managers.dyn_resource:set_file_streaming_chunk_size_mul(1, 1)

		result = true
	end

	if managers.system_menu:block_exec() then
		result = true
	end

	if managers.savefile:is_active() then
		result = true
	end

	if _G.IS_VR and managers.vr:block_exec() then
		result = true
	end

	return result
end

function Setup:block_quit()
	return self:block_exec()
end

function Setup:set_main_thread_loading_screen_visible(visible)
	if not self._main_thread_loading_screen_gui_visible ~= not visible then
		cat_print("loading_environment", "[LoadingEnvironment] Main thread loading screen visible: " .. tostring(visible))
		self._main_thread_loading_screen_gui_script:set_visible(visible, RenderSettings.resolution)

		self._main_thread_loading_screen_gui_visible = visible
	end
end

function Setup:set_fps_cap(value)
	if not self._framerate_low then
		Application:cap_framerate(value)
	end
end

function Setup:_upd_unload_packages()
	if self._packages_to_unload then
		local package_name = table.remove(self._packages_to_unload)

		if package_name then
			PackageManager:unload(package_name)
		end

		if not next(self._packages_to_unload) then
			self._packages_to_unload = nil
		end
	end
end

function Setup:is_unloading()
	return self._started_unloading_packages and true
end
