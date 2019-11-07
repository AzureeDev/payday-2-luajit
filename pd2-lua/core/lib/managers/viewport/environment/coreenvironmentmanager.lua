core:module("CoreEnvironmentManager")
core:import("CoreClass")
core:import("CoreEnvironmentHandler")
core:import("CoreEnvironmentFeeder")

EnvironmentManager = EnvironmentManager or CoreClass.class()
local extension = "environment"
local ids_extension = Idstring(extension)

function EnvironmentManager:init()
	self._env_data_map = {}
	self._feeder_class_map = {}
	self._global_feeder_map = {}
	self._predefined_environment_filter_map = {}
	self._global_environment_modifier_map = {}
	self._game_default_environment_path = "core/environments/default"
	self._default_environment_path = self._game_default_environment_path
	local feeder_class_list = {
		CoreEnvironmentFeeder.UnderlayPathFeeder,
		CoreEnvironmentFeeder.GlobalLightColorFeeder,
		CoreEnvironmentFeeder.GlobalLightColorScaleFeeder,
		CoreEnvironmentFeeder.CubeMapTextureFeeder,
		CoreEnvironmentFeeder.WorldOverlayTextureFeeder,
		CoreEnvironmentFeeder.WorldOverlayMaskTextureFeeder,
		CoreEnvironmentFeeder.SkyRotationFeeder,
		CoreEnvironmentFeeder.UnderlaySkyTopColorFeeder,
		CoreEnvironmentFeeder.UnderlaySkyTopColorScaleFeeder,
		CoreEnvironmentFeeder.UnderlaySkyBottomColorFeeder,
		CoreEnvironmentFeeder.UnderlaySkyBottomColorScaleFeeder,
		CoreEnvironmentFeeder.PostAmbientFalloffScaleFeeder,
		CoreEnvironmentFeeder.PostAmbientColorFeeder,
		CoreEnvironmentFeeder.PostAmbientColorScaleFeeder,
		CoreEnvironmentFeeder.PostSkyTopColorFeeder,
		CoreEnvironmentFeeder.PostSkyTopColorFeeder,
		CoreEnvironmentFeeder.PostSkyTopColorScaleFeeder,
		CoreEnvironmentFeeder.PostSkyBottomColorFeeder,
		CoreEnvironmentFeeder.PostSkyBottomColorScaleFeeder,
		CoreEnvironmentFeeder.PostFogStartColorFeeder,
		CoreEnvironmentFeeder.PostFogFarLowColorFeeder,
		CoreEnvironmentFeeder.PostFogMinRangeFeeder,
		CoreEnvironmentFeeder.PostFogMaxRangeFeeder,
		CoreEnvironmentFeeder.PostFogMaxDensityFeeder,
		CoreEnvironmentFeeder.PostAmbientScaleFeeder,
		CoreEnvironmentFeeder.PostEffectLightScaleFeeder,
		CoreEnvironmentFeeder.PostShadowSlice0Feeder,
		CoreEnvironmentFeeder.PostShadowSlice1Feeder,
		CoreEnvironmentFeeder.PostShadowSlice2Feeder,
		CoreEnvironmentFeeder.PostShadowSlice3Feeder,
		CoreEnvironmentFeeder.PostShadowSliceDepthsFeeder,
		CoreEnvironmentFeeder.PostShadowSliceOverlapFeeder,
		CoreEnvironmentFeeder.PostEffectBloomThresholdFeeder,
		CoreEnvironmentFeeder.PostEffectBloomIntensityFeeder,
		CoreEnvironmentFeeder.PostEffectBloomBlurSizeFeeder,
		CoreEnvironmentFeeder.PostEffectLenseIntensityFeeder,
		CoreEnvironmentFeeder.EnvironmentEffectFeeder
	}

	for _, feeder_class in ipairs(feeder_class_list) do
		self._feeder_class_map[feeder_class.DATA_PATH_KEY] = feeder_class

		if feeder_class.FILTER_CATEGORY then
			local filter_list = self._predefined_environment_filter_map[feeder_class.FILTER_CATEGORY]

			if not filter_list then
				filter_list = {}
				self._predefined_environment_filter_map[feeder_class.FILTER_CATEGORY] = filter_list
			end

			table.insert(filter_list, feeder_class.DATA_PATH_KEY)
		end
	end

	if Application:editor() then
		local deprecated_data_path_list = {
			"post_effect/fog_processor/fog/fog/color0",
			"post_effect/fog_processor/fog/fog/color0_scale",
			"post_effect/fog_processor/fog/fog/color1",
			"post_effect/fog_processor/fog/fog/color1_scale",
			"post_effect/fog_processor/fog/fog/color2",
			"post_effect/fog_processor/fog/fog/color2_scale",
			"post_effect/fog_processor/fog/fog/end0",
			"post_effect/fog_processor/fog/fog/end1",
			"post_effect/fog_processor/fog/fog/end2",
			"post_effect/fog_processor/fog/fog/alpha0",
			"post_effect/fog_processor/fog/fog/alpha1",
			"post_effect/fog_processor/fog/fog/start",
			"post_effect/fog_processor/fog/fog/start_color",
			"post_effect/fog_processor/fog/fog/start_color_scale",
			"underlay_effect/sky_top/sky_intensity",
			"underlay_effect/sun/sun_color",
			"underlay_effect/sun/sun_color_scale",
			"underlay_effect/sky/color1",
			"underlay_effect/sky/color1_scale",
			"underlay_effect/cloud_overlay/color_sun",
			"underlay_effect/cloud_overlay/alpha_scale_opposite_sun",
			"underlay_effect/cloud_overlay/color_opposite_sun_scale",
			"underlay_effect/cloud_overlay/uv_velocity_b_mask",
			"underlay_effect/cloud_overlay/uv_scale_b_mask",
			"underlay_effect/cloud_overlay/color_opposite_sun",
			"underlay_effect/cloud_overlay/uv_velocity_rg_mask",
			"underlay_effect/cloud_overlay/color_sun_scale",
			"underlay_effect/cloud_overlay/alpha_scale_sun",
			"underlay_effect/sky_bottom/sky_intensity",
			"others/sun_anim_x",
			"others/sun_anim",
			"others/flare_alpha_1",
			"others/flare_scale_1",
			"others/flare_index_1",
			"others/flare_offset_1",
			"others/flare_index_2",
			"others/flare_alpha_2",
			"others/flare_scale_2",
			"others/flare_offset_2",
			"others/flare_index_3",
			"others/flare_alpha_3",
			"others/flare_scale_3",
			"others/flare_offset_3",
			"others/flare_scale_4",
			"others/flare_alpha_4",
			"others/flare_index_4",
			"others/flare_offset_4",
			"others/flare_scale_5",
			"others/flare_index_5",
			"others/flare_alpha_5",
			"others/flare_offset_5",
			"others/flare_scale_6",
			"others/flare_alpha_6",
			"others/flare_index_6",
			"others/flare_offset_6",
			"others/flare_alpha_7",
			"others/flare_index_7",
			"others/flare_scale_7",
			"others/flare_offset_7",
			"others/flare_alpha_8",
			"others/flare_scale_8",
			"others/flare_index_8",
			"others/flare_offset_8",
			"others/flare_anim_y",
			"others/flare_color",
			"others/flare_anim_x",
			"others/flare_name",
			"post_effect/shadow_processor/shadow_rendering/shadow_modifier/shadow_fadeout",
			"post_effect/deferred/deferred_lighting/shadow/fadeout_blend",
			"post_effect/deferred/deferred_lighting/apply_ambient/sun_specular_color_scale",
			"post_effect/deferred/deferred_lighting/apply_ambient/max_range",
			"post_effect/deferred/deferred_lighting/apply_ambient/sky_reflection_top_color_scale",
			"post_effect/deferred/deferred_lighting/apply_ambient/sun_range",
			"post_effect/deferred/deferred_lighting/apply_ambient/fog_sun_range",
			"post_effect/deferred/deferred_lighting/apply_ambient/sun_specular_color",
			"post_effect/deferred/deferred_lighting/apply_ambient/fog_sun_scatter_color",
			"post_effect/deferred/deferred_lighting/apply_ambient/fog_far_high_color",
			"post_effect/deferred/deferred_lighting/apply_ambient/environment_map_intensity",
			"post_effect/deferred/deferred_lighting/apply_ambient/min_range",
			"post_effect/deferred/deferred_lighting/apply_ambient/height_fade_intesity_clamp",
			"post_effect/deferred/deferred_lighting/apply_ambient/environment_map_intensity_shadow",
			"post_effect/deferred/deferred_lighting/apply_ambient/sky_reflection_bottom_color",
			"post_effect/deferred/deferred_lighting/apply_ambient/start_color",
			"post_effect/deferred/deferred_lighting/apply_ambient/height_fade",
			"post_effect/deferred/deferred_lighting/apply_ambient/sky_reflection_top_color",
			"post_effect/deferred/deferred_lighting/apply_ambient/fog_height_range",
			"post_effect/deferred/deferred_lighting/apply_ambient/sky_reflection_bottom_color_scale",
			"post_effect/deferred/deferred_lighting/apply_ambient/fog_curve",
			"post_effect/deferred/deferred_lighting/global_ssao/intensity",
			"post_effect/deferred/deferred_lighting/local_ssao/intensity",
			"post_effect/deferred/deferred_lighting/ssao/intensity",
			"post_effect/hdr_post_processor/default/dof/near_focus_distance_min",
			"post_effect/hdr_post_processor/default/dof/near_focus_distance_max",
			"post_effect/hdr_post_processor/default/dof/far_focus_distance_min",
			"post_effect/hdr_post_processor/default/dof/far_focus_distance_max",
			"post_effect/hdr_post_processor/default/dof/clamp",
			"post_effect/hdr_post_processor/default/tone_mapping/luminance_clamp",
			"post_effect/hdr_post_processor/default/tone_mapping/white_luminance",
			"post_effect/hdr_post_processor/default/tone_mapping/dark_to_bright_adaption_speed",
			"post_effect/hdr_post_processor/default/tone_mapping/bright_to_dark_adaption_speed",
			"post_effect/hdr_post_processor/default/tone_mapping/middle_grey",
			"post_effect/hdr_post_processor/default/tone_mapping/$template_mix",
			"post_effect/hdr_post_processor/default/bloom_brightpass/threshold",
			"post_effect/hdr_post_processor/default/bloom_brightpass/white_luminance",
			"post_effect/hdr_post_processor/default/bloom_brightpass/middle_grey",
			"post_effect/hdr_post_processor/default/bloom_brightpass/disable_tone_mapping",
			"post_effect/hdr_post_processor/default/bloom_apply/opacity",
			"post_effect/hdr_post_processor/default/exposure_sepia_levels/disable_tone_mapping"
		}
		self._deprecated_data_path_map = {}

		for _, data_path in ipairs(deprecated_data_path_list) do
			self._deprecated_data_path_map[data_path] = true
		end
	end

	self:preload_environment(self._game_default_environment_path)
end

function EnvironmentManager:destroy()
	self._env_data_map = nil
	self._feeder_class_map = nil
	self._global_feeder_map = nil
	self._predefined_environment_filter_map = nil
	self._global_environment_modifier_map = nil
	self._deprecated_data_path_map = nil
end

function EnvironmentManager:preload_environment(path)
	if not self._env_data_map[path] then
		self._env_data_map[path] = self:_load(path)
	end
end

function EnvironmentManager:has_data_path_key(data_path_key)
	return self._feeder_class_map[data_path_key] ~= nil
end

function EnvironmentManager:is_deprecated_data_path(data_path)
	return self._deprecated_data_path_map and self._deprecated_data_path_map[data_path] ~= nil
end

function EnvironmentManager:get_predefined_environment_filter_map()
	return self._predefined_environment_filter_map
end

function EnvironmentManager:get_default_value(data_path_key)
	local feeder = self._feeder_class_map[data_path_key]

	if not feeder then
		return nil
	end

	return feeder.DEFAULT_VALUE
end

function EnvironmentManager:get_value(path, data_path_key)
	local env_data = self:_get_data(path)

	if not env_data then
		Application:stack_dump_error("[EnvironmentManager] Invalid environment path: " .. path)

		return nil
	end

	local value = env_data[data_path_key]

	if not value then
		Application:stack_dump_error("[EnvironmentManager] Invalid data path.")
	end

	return value
end

function EnvironmentManager:set_global_environment_modifier(data_path_key, is_override, modifier_func)
	local global_modifier_data = nil

	if modifier_func then
		global_modifier_data = {
			is_override = is_override,
			modifier_func = modifier_func
		}
	end

	self._global_environment_modifier_map[data_path_key] = global_modifier_data
end

function EnvironmentManager:set_default_environment(default_environment_path)
	self._default_environment_path = default_environment_path
end

function EnvironmentManager:default_environment()
	return self._default_environment_path
end

function EnvironmentManager:game_default_environment()
	return self._game_default_environment_path
end

function EnvironmentManager:set_override_environment(override_environment_path)
	self._override_environment_path = override_environment_path
end

function EnvironmentManager:override_environment()
	return self._override_environment_path
end

function EnvironmentManager:_set_global_feeder(feeder)
	local old_feeder = self._global_feeder_map[feeder.DATA_PATH_KEY]
	self._global_feeder_map[feeder.DATA_PATH_KEY] = feeder

	return old_feeder
end

function EnvironmentManager:editor_add_created_callback(func)
	self._created_callback_list = self._created_callback_list or {}

	table.insert(self._created_callback_list, func)
end

function EnvironmentManager:editor_reload(path)
	local entry_path = managers.database:entry_relative_path(path .. "." .. extension)
	local is_new = not managers.database:has(entry_path)
	local source_files = {
		entry_path
	}

	for _, old_path in ipairs(managers.database:list_entries_of_type("environment")) do
		table.insert(source_files, old_path .. "." .. extension)
	end

	local compile_settings = {
		target_db_name = "all",
		send_idstrings = false,
		preprocessor_definitions = "preprocessor_definitions",
		verbose = false,
		platform = string.lower(SystemInfo:platform():s()),
		source_root = managers.database:base_path(),
		target_db_root = Application:base_path() .. "assets",
		source_files = source_files
	}

	Application:data_compile(compile_settings)
	DB:reload()
	managers.database:clear_all_cached_indices()
	PackageManager:reload(ids_extension, path:id())

	if self._env_data_map[path] then
		self._env_data_map[path] = self:_load(path)
	end

	if is_new and self._created_callback_list then
		for _, func in ipairs(self._created_callback_list) do
			func(path)
		end
	end
end

function EnvironmentManager:_get_data(path)
	local env_data = self._env_data_map[path]

	if not env_data then
		if not Application:editor() then
			Application:stack_dump_error("[EnvironmentManager] Environment was not preloaded: " .. tostring(path))
		end

		env_data = self:_load(path)
		self._env_data_map[path] = env_data
	end

	return env_data
end

function EnvironmentManager:_create_feeder(data_path_key, value)
	local feeder = self._feeder_class_map[data_path_key]:new(value)
	local global_modifier_data = self._global_environment_modifier_map[data_path_key]

	if global_modifier_data then
		feeder:set_modifier(global_modifier_data.modifier_func, global_modifier_data.is_override)
	end

	return feeder
end

function EnvironmentManager:_load(path)
	local raw_data = nil

	if Application:editor() then
		if DB:has(ids_extension, path:id()) then
			raw_data = PackageManager:editor_load_script_data(ids_extension, path:id())
		else
			managers.editor:output_error("Environment " .. path .. " is not in the database, probably removed. Using default instead.")

			raw_data = PackageManager:editor_load_script_data(ids_extension, self._default_environment_path:id())
		end
	else
		raw_data = PackageManager:script_data(ids_extension, path:id())
	end

	local env_data = {}

	self:_load_env_data(nil, env_data, raw_data.data)

	for data_path_key, feeder in pairs(self._feeder_class_map) do
		if not env_data[data_path_key] and feeder and feeder.DEFAULT_VALUE then
			env_data[data_path_key] = feeder.DEFAULT_VALUE
		end
	end

	return env_data
end

function EnvironmentManager:_load_env_data(data_path, env_data, raw_data)
	for _, sub_raw_data in ipairs(raw_data) do
		if sub_raw_data._meta == "param" then
			local next_data_path = data_path and data_path .. "/" .. sub_raw_data.key or sub_raw_data.key
			local next_data_path_key = Idstring(next_data_path):key()

			if self._feeder_class_map[next_data_path_key] then
				env_data[next_data_path_key] = sub_raw_data.value
			elseif self._deprecated_data_path_map and not self._deprecated_data_path_map[next_data_path] then
				Application:error("[EnvironmentManager] Invalid data path: " .. next_data_path)
			end
		else
			local next_data_path = data_path and data_path .. "/" .. sub_raw_data._meta or sub_raw_data._meta

			self:_load_env_data(next_data_path, env_data, sub_raw_data)
		end
	end
end
