require("lib/utils/VRLoadingEnvironment")

VRViewport = VRViewport or class()

function VRViewport:init(x, y, width, height, name, prio)
	self._vp = Application:create_world_viewport(x, y, width, height)
	self._use_adaptive_quality = true
	self._prio = prio
	self._name = name
	self._pre_render = false
end

function VRViewport:set_camera(camera)
	self._vp:set_camera(camera)
end

function VRViewport:set_pre_render(pre_render)
	self._pre_render = pre_render
end

function VRViewport:pre_render()
	return self._pre_render
end

function VRViewport:set_active(active)
	self._active = active
end

function VRViewport:vp()
	return self._vp
end

function VRViewport:set_render_params(...)
	self._render_params = {
		...
	}
end

function VRViewport:use_adaptive_quality()
	return self._use_adaptive_quality
end

function VRViewport:set_enable_adaptive_quality(enable)
	self._use_adaptive_quality = enable
end

function VRViewport:active()
	return self._active
end

function VRViewport:destroy()
end

function VRViewport:render()
	Application:render(unpack(self._render_params))
end

VRManagerPD2 = VRManagerPD2 or class()
VRManagerPD2.DISABLE_ADAPTIVE_QUALITY = false

function VRManagerPD2:init()
	print("[VRManagerPD2] init")

	if not PackageManager:loaded("packages/vr_base") then
		PackageManager:load("packages/vr_base")
	end

	VRManager:set_max_adaptive_levels(7)

	self._adaptive_scale = {
		0.85,
		0.9,
		1,
		1.1,
		1.2,
		1.3
	}
	self._adaptive_scale_max = 1.4

	VRManager:set_present_post_processor(Idstring("core/shaders/render_to_backbuffer"), Idstring("stretch_copy"), "back_buffer")

	self._is_default_hmd = true
	self._is_oculus = string.find(string.lower(VRManager:hmd_manufacturer()), "oculus") ~= nil
	self._is_default_hmd = self._is_default_hmd and not self._is_oculus
	self._super_sample_scale = VRManager:super_sample_scale()
	self._viewports = {}
	self._default = {
		belt_height_ratio = 0.6,
		height = 140,
		keep_items_in_hand = false,
		autowarp_length = "long",
		weapon_precision_mode = true,
		belt_snap = 72,
		auto_reload = true,
		warp_zone_size = 0,
		belt_size = 96,
		fadeout_type = "fadeout_smooth",
		default_tablet_hand = "left",
		enable_dead_zone_warp = true,
		zipline_screen = true,
		rotate_player_angle = 45,
		collision_instant_teleport = false,
		default_weapon_hand = "right",
		arm_animation = false,
		movement_type = "warp",
		belt_distance = 10,
		grip_toggle = true,
		dead_zone_size = self._is_default_hmd and 50 or 35,
		belt_layout = {
			bag = {
				7,
				5
			},
			reload = {
				7,
				3
			},
			melee = {
				3,
				7
			},
			throwable = {
				4,
				4
			},
			deployable = {
				10,
				4
			},
			deployable_secondary = {
				12,
				4
			},
			weapon = {
				11,
				7
			}
		},
		belt_box_sizes = {
			bag = {
				2,
				1
			},
			reload = {
				2,
				1
			},
			melee = {
				2,
				2
			},
			deployable = {
				1,
				1
			},
			throwable = {
				1,
				1
			},
			deployable_secondary = {
				1,
				1
			},
			weapon = {
				2,
				2
			}
		},
		arm_length = tweak_data.vr.default_body_metrics.arm_length,
		head_to_shoulder = tweak_data.vr.default_body_metrics.head_to_shoulder,
		shoulder_width = tweak_data.vr.default_body_metrics.shoulder_width
	}
	self._limits = {
		height = {
			max = 250,
			min = 50
		},
		belt_height_ratio = {
			max = 0.9,
			min = 0.1
		},
		belt_distance = {
			max = 30,
			min = -10
		},
		belt_size = {
			max = 126,
			min = 66
		},
		belt_snap = {
			max = 360,
			min = 0
		},
		rotate_player_angle = {
			max = 90,
			min = 45
		},
		warp_zone_size = {
			max = 100,
			min = 0
		},
		dead_zone_size = {
			max = 100,
			min = 0
		},
		arm_length = {
			max = 150,
			min = 10
		},
		head_to_shoulder = {
			max = 50,
			min = 10
		},
		shoulder_width = {
			max = 120,
			min = 20
		}
	}

	if not Global.vr then
		Global.vr = {}
	end

	self._global = Global.vr

	for setting, default in pairs(self._default) do
		if self._global[setting] == nil then
			if type(default) == "table" then
				self._global[setting] = deep_clone(default)
			else
				self._global[setting] = default
			end
		end
	end

	self._vr_loading_environment = VRLoadingEnvironment:new()
	self._force_disable_low_adaptive_quality = false

	MenuRoom:load("units/pd2_dlc_vr/menu/vr_menu_mini", false)
end

function VRManagerPD2:init_finalize()
	print("[VRManagerPD2] init_finalize")

	if game_state_machine:is_boot_intro_done() then
		self._vr_loading_environment:stop()
	else
		self._vr_loading_environment:start()
	end

	self._adaptive_quality_setting_changed_clbk = callback(self, self, "_on_adaptive_quality_setting_changed")

	managers.user:add_setting_changed_callback("adaptive_quality", self._adaptive_quality_setting_changed_clbk)
	self._adaptive_quality_setting_changed_clbk("adaptive_quality", nil, managers.user:get_setting("adaptive_quality"))
	managers.statistics:publish_custom_stat_to_steam("info_playing_vr")
end

function VRManagerPD2:is_default_hmd()
	return self._is_default_hmd
end

function VRManagerPD2:is_oculus()
	return self._is_oculus
end

function VRManagerPD2:apply_arcade_settings()
	print("[VRManagerPD2] Apply arcade settings")
	managers.user:set_setting("video_ao", "off")
	managers.user:set_setting("video_aa", "smaa_x1")
	managers.user:set_setting("parallax_mapping", true)
	managers.user:set_setting("chromatic_setting", "none")
	managers.user:set_setting("adaptive_quality", true)

	local dirty = false
	dirty = dirty or RenderSettings.texture_quality_default ~= "high"
	dirty = dirty or RenderSettings.shadow_quality_default ~= "low"
	dirty = dirty or RenderSettings.max_anisotropy ~= 2

	if dirty then
		RenderSettings.texture_quality_default = "high"
		RenderSettings.shadow_quality_default = "low"
		RenderSettings.max_anisotropy = 2

		MenuCallbackHandler:apply_and_save_render_settings()
	end
end

function VRManagerPD2:force_start_loading()
	print("[VRManagerPD2] Force start loading")
	self._vr_loading_environment:force_start()
end

function VRManagerPD2:start_loading()
	print("[VRManagerPD2] Start loading")
	self._vr_loading_environment:start()
end

function VRManagerPD2:start_end_screen()
	print("[VRManagerPD2] Start end screen")
	self._vr_loading_environment:start("end")
end

function VRManagerPD2:stop_loading()
	print("[VRManagerPD2] Stop loading")
	self._vr_loading_environment:stop()
end

function VRManagerPD2:destroy()
	managers.user:remove_setting_changed_callback("adaptive_quality", self._adaptive_quality_setting_changed_clbk)
	print("[VRManagerPD2] destroy")
end

function VRManagerPD2:update(t, dt)
	self:_update_adaptive_quality_level(t)
	self._vr_loading_environment:update(t, dt)
end

function VRManagerPD2:paused_update(t, dt)
	self:_update_adaptive_quality_level(t)
	self._vr_loading_environment:update(t, dt)
end

function VRManagerPD2:end_update(t, dt)
end

function VRManagerPD2:new_vp(x, y, width, height, name, prio)
	local vp = VRViewport:new(x, y, width, height, name, prio)

	table.insert(self._viewports, vp)

	return vp
end

function VRManagerPD2:pre_render()
	for _, vp in ipairs(self._viewports) do
		if vp:active() and vp:pre_render() then
			vp:render()
		end
	end
end

function VRManagerPD2:render()
	for _, vp in ipairs(self._viewports) do
		if vp:active() and not vp:pre_render() then
			vp:render()
		end
	end
end

function VRManagerPD2:set_hand_state_machine(hsm)
	self._hsm = hsm
end

function VRManagerPD2:hand_state_machine()
	return self._hsm
end

function VRManagerPD2:_on_adaptive_quality_setting_changed(setting, old, new)
	local setting = new and true or false
	self._use_adaptive_quality = setting

	if RenderSettings.adaptive_quality ~= setting then
		RenderSettings.adaptive_quality = setting

		VRManager:set_adaptive_quality(new)
		Application:apply_render_settings()
	end
end

function VRManagerPD2:set_force_disable_low_adaptive_quality(disable)
	self._force_disable_low_adaptive_quality = disable
end

function VRManagerPD2:_update_adaptive_quality_level(t)
	if self._update_super_sample_scale_t and self._update_super_sample_scale_t < t then
		self._update_super_sample_scale_t = nil
	end

	local scale = VRManager:super_sample_scale()

	if math.abs(scale - self._super_sample_scale) > 0.01 and not self._update_super_sample_scale_t then
		self._update_super_sample_scale_t = t + 0.5
		self._super_sample_scale = scale

		Application:apply_render_settings()
	end

	local quality_level = VRManager:adaptive_level() + 1

	if self._force_disable_low_adaptive_quality then
		quality_level = math.max(quality_level, 3)
	end

	local x_scale = 1
	local y_scale = 1

	if self._use_adaptive_quality and quality_level < 7 then
		local tres = VRManager:target_resolution()
		local scaling = self._adaptive_scale[quality_level]
		x_scale = scaling / self._adaptive_scale_max
		local res_x = math.floor(tres.x * x_scale)

		if res_x % 4 > 0.01 then
			res_x = res_x + 4 - res_x % 4
		end

		x_scale = res_x / tres.x + 0.05 / tres.x
		y_scale = scaling / self._adaptive_scale_max
		local res_y = math.floor(tres.y * y_scale)

		if res_y % 2 > 0.01 then
			res_y = res_y + 1
		end

		y_scale = res_y / tres.y + 0.05 / tres.y
	end

	VRManager:set_output_scaling(x_scale, y_scale)
	managers.overlay_effect:viewport():set_dimensions(0, 0, x_scale, y_scale)

	for _, svp in ipairs(managers.viewport:all_really_active_viewports()) do
		if svp:use_adaptive_quality() then
			svp:vp():set_dimensions(0, 0, x_scale, y_scale)
		end
	end

	for _, svp in ipairs(self._viewports) do
		if svp:use_adaptive_quality() then
			svp:vp():set_dimensions(0, 0, x_scale, y_scale)
		end
	end
end

function VRManagerPD2:block_exec()
	return self._vr_loading_environment:block_exec()
end

function VRManagerPD2:save(data)
	data.vr = {}

	for setting in pairs(self._default) do
		data.vr[setting] = self._global[setting]
	end

	data.vr.has_set_height = self._global.has_set_height
	data.vr.has_notified_procedural_animation = self._global.has_notified_procedural_animation
end

function VRManagerPD2:load(data)
	if not data.vr then
		return
	end

	for setting in pairs(self._default) do
		if data.vr[setting] ~= nil then
			self._global[setting] = data.vr[setting]
		end
	end

	self._global.has_set_height = data.vr.has_set_height
	self._global.has_notified_procedural_animation = data.vr.has_notified_procedural_animation
end

function VRManagerPD2:add_setting_changed_callback(setting, callback)
	self._setting_callback_handler_map = self._setting_callback_handler_map or {}
	self._setting_callback_handler_map[setting] = self._setting_callback_handler_map[setting] or CoreEvent.CallbackEventHandler:new()

	self._setting_callback_handler_map[setting]:add(callback)
end

function VRManagerPD2:remove_setting_changed_callback(setting, callback)
	self._setting_callback_handler_map = self._setting_callback_handler_map or {}
	self._setting_callback_handler_map[setting] = self._setting_callback_handler_map[setting]

	if self._setting_callback_handler_map[setting] then
		self._setting_callback_handler_map[setting]:remove(callback)
	end
end

function VRManagerPD2:setting_limits(setting)
	local limits = self._limits[setting]

	if limits then
		return limits.min, limits.max
	end
end

function VRManagerPD2:has_set_height()
	return self._global.has_set_height
end

function VRManagerPD2:has_notified_procedural_animation()
	return self._global.has_notified_procedural_animation
end

function VRManagerPD2:set_setting(setting, value)
	if type(value) == "number" then
		local limits = self._limits[setting]

		if limits then
			value = math.clamp(value, limits.min, limits.max)
		end
	end

	if setting == "height" then
		self._global.has_set_height = true
	end

	local old_value = self._global[setting]
	self._global[setting] = value

	managers.savefile:setting_changed()
	managers.savefile:save_setting()

	local callback_handler = self._setting_callback_handler_map and self._setting_callback_handler_map[setting]

	if callback_handler then
		callback_handler:dispatch(setting, old_value, value)
	end
end

function VRManagerPD2:reset_setting(setting)
	self:set_setting(setting, self._default[setting])
end

function VRManagerPD2:get_setting(setting)
	return self._global[setting]
end

function VRManagerPD2:walking_mode()
	return self:get_setting("movement_type") == "warp_walk"
end

function VRManagerPD2:show_notify_procedural_animation()
	if not self._global.has_notified_procedural_animation then
		managers.menu:show_vr_procedural_animation()

		self._global.has_notified_procedural_animation = true

		managers.savefile:setting_changed()
		managers.savefile:save_setting()
	end
end

local rt_swap = {
	{
		Idstring("Text"),
		Idstring("OverlayText")
	},
	{
		Idstring("VertexColor"),
		Idstring("OverlayVertexColor")
	},
	{
		Idstring("VertexColorTextured"),
		Idstring("OverlayVertexColorTextured")
	},
	{
		Idstring("VertexColorTexturedAlphaSweep"),
		Idstring("OverlayVertexColorTexturedAlphaSweep")
	},
	{
		Idstring("VertexColorTexturedRadial"),
		Idstring("OverlayVertexColorTexturedRadial")
	},
	{
		Idstring("VertexColorTexturedMaskRender"),
		Idstring("OverlayVertexColorTexturedMaskRender")
	},
	{
		Idstring("VertexColorTexturedBlur3D"),
		Idstring("OverlayVertexColorTexturedBlur3D")
	}
}

function VRManagerPD2.overlay_helper(panel)
	local objects = {
		panel
	}
	local i = 1

	while #objects > 0 do
		local object = objects[#objects]

		table.remove(objects)

		if object.type_name == "Panel" then
			local children = object:children()

			for _, o in ipairs(children) do
				table.insert(objects, o)
			end
		else
			local rt = object:render_template()
			local swap = nil

			for _, s in ipairs(rt_swap) do
				if s[1] == rt then
					object:set_render_template(s[2])

					break
				end
			end
		end
	end
end

function VRManagerPD2.depth_disable_helper(panel)
	local objects = {
		panel
	}
	local i = 1

	while #objects > 0 do
		local object = table.remove(objects)

		if object.type_name == "Panel" then
			local children = object:children()

			for _, o in ipairs(children) do
				table.insert(objects, o)
			end
		else
			object:configure({
				depth_mode = "disabled"
			})
		end
	end
end
