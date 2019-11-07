core:module("CoreEnvironmentFeeder")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreEngineAccess")

local is_editor = Application:editor()
local platform_intensity_scale = LightIntensityDB:platform_intensity_scale()
local ids_sun_anim_group = Idstring("d_sun")
local ids_ref_cam_obj = Idstring("rp_skydome")
local ids_sky = Idstring("sky")
local ids_top_color = Idstring("color0")
local ids_bottom_color = Idstring("color2")
local ids_ambient_falloff_scale = Idstring("ambient_falloff_scale")
local ids_ambient_color = Idstring("ambient_color")
local ids_sky_top_color = Idstring("sky_top_color")
local ids_sky_bottom_color = Idstring("sky_bottom_color")
local ids_fog_start_color = Idstring("fog_start_color")
local ids_fog_far_low_color = Idstring("fog_far_low_color")
local ids_fog_max_density = Idstring("fog_max_density")
local ids_fog_max_range = Idstring("fog_max_range")
local ids_fog_min_range = Idstring("fog_min_range")
local ids_ambient_scale = Idstring("ambient_scale")
local ids_effect_light_scale = Idstring("effect_light_scale")
local ids_slice0 = Idstring("slice0")
local ids_slice1 = Idstring("slice1")
local ids_slice2 = Idstring("slice2")
local ids_slice3 = Idstring("slice3")
local ids_shadow_slice_depths = Idstring("shadow_slice_depths")
local ids_shadow_slice_overlap = Idstring("shadow_slice_overlap")
local ids_bloom_combine_processor = Idstring("bloom_combine_post_processor")
local ids_bloom_combine = Idstring("bloom_combine")
local ids_bloom_lense = Idstring("bloom_lense")
local ids_bloom_lense_id = Idstring("post_effect/bloom_combine_post_processor/bloom_combine/bloom_lense"):key()
local ids_bloom_threshold = Idstring("bloom_threshold")
local ids_bloom_intensity = Idstring("bloom_intensity")
local ids_lense_intensity = Idstring("lense_intensity")
local ids_deferred = Idstring("deferred")
local ids_deferred_lighting = Idstring("deferred_lighting")
local ids_apply_ambient = Idstring("apply_ambient")
local ids_apply_ambient_id = Idstring("post_effect/deferred/deferred_lighting/apply_ambient"):key()
local ids_shadow_processor = Idstring("shadow_processor")
local ids_shadow_rendering = Idstring("shadow_rendering")
local ids_shadow_modifier = Idstring("shadow_modifier")
local ids_shadow_modifier_id = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier"):key()
local zero_rotation = Rotation(0, 0, 0)
local zero_vector3 = Vector3(0, 0, 0)
local temp_rotation = Rotation(0, 0, 0)
local temp_vector3 = Vector3(0, 0, 0)
Feeder = Feeder or CoreClass.class()
Feeder.APPLY_GROUP_ID = 0
Feeder.DATA_PATH_KEY = nil
Feeder.IS_GLOBAL = nil
Feeder.AFFECTED_LIST = nil
Feeder.DEFAULT_VALUE = nil
Feeder.FILTER_CATEGORY = "Others"

function Feeder:init(current)
	self:set(current)
end

function Feeder:destroy()
	self._source = nil
	self._target = nil
end

function Feeder.get_next_id()
	Feeder.APPLY_GROUP_ID = Feeder.APPLY_GROUP_ID + 1

	return Feeder.APPLY_GROUP_ID
end

function Feeder:set_target(target)
	self._source = self._current
	self._target = target
end

function Feeder:equals(value)
	return self._current == value
end

function Feeder:get_current()
	return self._current
end

function Feeder:get_default_value()
	return Feeder.DEFAULT_VALUE
end

function Feeder:set(current)
	self._current = current
	self._source = current
	self._target = current
end

function Feeder:get_modifier()
	return self._modifier_func, self._is_modifier_override
end

function Feeder:set_modifier(modifier_func, is_modifier_override)
	self._modifier_func = modifier_func
	self._is_modifier_override = is_modifier_override
end

function Feeder:update(handler, scale)
	if self._modifier_func then
		local is_done, is_not_changed = nil

		if not self._is_modifier_override then
			is_done, is_not_changed = self:update_current(handler, scale)
		end

		self._current, is_done, is_not_changed = self._modifier_func(handler, self, scale, is_done, is_not_changed)

		return is_done, is_not_changed
	else
		return self:update_current(handler, scale)
	end
end

function Feeder:update_current(handler, scale)
	self._current = math.lerp(self._source, self._target, scale)

	return scale == 1, false
end

function Feeder:apply(handler, viewport, scene)
end

Vector3Feeder = Vector3Feeder or CoreClass.class(Feeder)

function Vector3Feeder:set(current)
	self._current = mvector3.copy(current)
	self._source = current
	self._target = current
end

function Vector3Feeder:set_target(target)
	self._source = mvector3.copy(self._current)
	self._target = target
end

function Vector3Feeder:equals(value)
	return mvector3.equal(self._current, value)
end

function Vector3Feeder:update_current(handler, scale)
	mvector3.lerp(self._current, self._source, self._target, scale)

	return scale == 1, false
end

StringFeeder = StringFeeder or CoreClass.class(Feeder)

function StringFeeder:update_current(handler, scale)
	if scale > 0.5 then
		self._current = self._target

		return true, false
	else
		return false, true
	end
end

UnderlayPathFeeder = UnderlayPathFeeder or CoreClass.class(StringFeeder)
UnderlayPathFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
UnderlayPathFeeder.DATA_PATH_KEY = Idstring("others/underlay"):key()
UnderlayPathFeeder.IS_GLOBAL = true
UnderlayPathFeeder.FILTER_CATEGORY = "Underlay path"

function UnderlayPathFeeder:apply(handler, viewport, scene)
	if CoreCode.alive(Global._global_light) then
		World:delete_light(Global._global_light)
	end

	if CoreCode.alive(Global._underlay_ref_camera) then
		Underlay:delete_camera(Global._underlay_ref_camera)
	end

	local underlay_path = managers.database and managers.database:entry_path(self._current) or self._current

	if is_editor then
		CoreEngineAccess._editor_load(Idstring("scene"), underlay_path:id())
	end

	Underlay:load(underlay_path, false)

	Global._global_light = World:create_light("directional|specular")

	Global._global_light:link(Underlay:get_object(ids_sun_anim_group))
	Global._global_light:set_local_rotation(zero_rotation)
	World:set_global_shadow_caster(Global._global_light)

	Global._underlay_ref_camera = Underlay:create_camera()

	Global._underlay_ref_camera:set_near_range(1000)
	Global._underlay_ref_camera:set_far_range(10000000)
	Global._underlay_ref_camera:set_fov(75)

	if _G.IS_VR then
		Global._underlay_ref_camera:set_hmd_tracking(false)
	end

	UnderlayPathFeeder.sky_material = Underlay:material(ids_sky)
	UnderlayPathFeeder.ref_cam_obj = Underlay:get_object(ids_ref_cam_obj)

	Global._underlay_ref_camera:set_local_position(UnderlayPathFeeder.ref_cam_obj:position())
	Underlay:set_reference_camera(Global._underlay_ref_camera)

	Global._current_underlay_name = self._current
end

GlobalLightColorFeeder = GlobalLightColorFeeder or CoreClass.class(Vector3Feeder)
GlobalLightColorFeeder.DATA_PATH_KEY = Idstring("others/sun_ray_color"):key()
GlobalLightColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
GlobalLightColorFeeder.IS_GLOBAL = true
GlobalLightColorFeeder.FILTER_CATEGORY = "Sun"

function GlobalLightColorFeeder:apply(handler, viewport, scene)
	if alive(Global._global_light) then
		local color = handler:get_value(GlobalLightColorFeeder.DATA_PATH_KEY)

		if color then
			local color_scale = handler:get_value(GlobalLightColorScaleFeeder.DATA_PATH_KEY) or 1

			mvector3.set(temp_vector3, color)
			mvector3.multiply(temp_vector3, color_scale)
			Global._global_light:set_color(temp_vector3)
		else
			Global._global_light:set_color(zero_vector3)
		end
	else
		Application:error("[EnvironmentManager][GlobalLightFeeder] No underlay loaded.")
	end
end

GlobalLightColorScaleFeeder = GlobalLightColorScaleFeeder or CoreClass.class(Feeder)
GlobalLightColorScaleFeeder.DATA_PATH_KEY = Idstring("others/sun_ray_color_scale"):key()
GlobalLightColorScaleFeeder.APPLY_GROUP_ID = GlobalLightColorFeeder.APPLY_GROUP_ID
GlobalLightColorScaleFeeder.IS_GLOBAL = GlobalLightColorFeeder.IS_GLOBAL
GlobalLightColorScaleFeeder.FILTER_CATEGORY = GlobalLightColorFeeder.FILTER_CATEGORY
GlobalLightColorScaleFeeder.apply = GlobalLightColorFeeder.apply
CubeMapTextureFeeder = CubeMapTextureFeeder or CoreClass.class(StringFeeder)
CubeMapTextureFeeder.DATA_PATH_KEY = Idstring("others/global_texture"):key()
CubeMapTextureFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
CubeMapTextureFeeder.IS_GLOBAL = true
CubeMapTextureFeeder.FILTER_CATEGORY = "Cubemap"

function CubeMapTextureFeeder:apply(handler, viewport, scene)
	managers.global_texture:set_texture("current_global_texture", self._current, "CUBEMAP")
end

WorldOverlayTextureFeeder = WorldOverlayTextureFeeder or CoreClass.class(StringFeeder)
WorldOverlayTextureFeeder.DATA_PATH_KEY = Idstring("others/global_world_overlay_texture"):key()
WorldOverlayTextureFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
WorldOverlayTextureFeeder.IS_GLOBAL = true
WorldOverlayTextureFeeder.FILTER_CATEGORY = "GlobalTexture"

function WorldOverlayTextureFeeder:apply(handler, viewport, scene)
	managers.global_texture:set_texture("current_global_world_overlay_texture", self._current, "texture")
end

WorldOverlayMaskTextureFeeder = WorldOverlayMaskTextureFeeder or CoreClass.class(StringFeeder)
WorldOverlayMaskTextureFeeder.DATA_PATH_KEY = Idstring("others/global_world_overlay_mask_texture"):key()
WorldOverlayMaskTextureFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
WorldOverlayMaskTextureFeeder.IS_GLOBAL = true
WorldOverlayMaskTextureFeeder.FILTER_CATEGORY = "GlobalTexture"

function WorldOverlayMaskTextureFeeder:apply(handler, viewport, scene)
	managers.global_texture:set_texture("current_global_world_overlay_mask_texture", self._current, "texture")
end

SkyRotationFeeder = SkyRotationFeeder or CoreClass.class(Feeder)
SkyRotationFeeder.DATA_PATH_KEY = Idstring("sky_orientation/rotation"):key()
SkyRotationFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
SkyRotationFeeder.IS_GLOBAL = true
SkyRotationFeeder.FILTER_CATEGORY = false

function SkyRotationFeeder:apply(handler, viewport, scene)
	if UnderlayPathFeeder.ref_cam_obj then
		mrotation.set_yaw_pitch_roll(temp_rotation, -self._current, 0, 0)
		UnderlayPathFeeder.ref_cam_obj:set_rotation(temp_rotation)
	end
end

UnderlaySkyTopColorFeeder = UnderlaySkyTopColorFeeder or CoreClass.class(Vector3Feeder)
UnderlaySkyTopColorFeeder.DATA_PATH_KEY = Idstring("underlay_effect/sky/color0"):key()
UnderlaySkyTopColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
UnderlaySkyTopColorFeeder.IS_GLOBAL = true
UnderlaySkyTopColorFeeder.FILTER_CATEGORY = "Sky"

function UnderlaySkyTopColorFeeder:apply(handler, viewport, scene)
	if UnderlayPathFeeder.sky_material then
		local color = handler:get_value(UnderlaySkyTopColorFeeder.DATA_PATH_KEY)

		if color then
			local color_scale = handler:get_value(UnderlaySkyTopColorScaleFeeder.DATA_PATH_KEY) or 1

			mvector3.set(temp_vector3, color)
			mvector3.multiply(temp_vector3, color_scale)
			UnderlayPathFeeder.sky_material:set_variable(ids_top_color, temp_vector3)
		else
			UnderlayPathFeeder.sky_material:set_variable(ids_top_color, zero_vector3)
		end
	end
end

UnderlaySkyTopColorScaleFeeder = UnderlaySkyTopColorScaleFeeder or CoreClass.class(Feeder)
UnderlaySkyTopColorScaleFeeder.DATA_PATH_KEY = Idstring("underlay_effect/sky/color0_scale"):key()
UnderlaySkyTopColorScaleFeeder.APPLY_GROUP_ID = UnderlaySkyTopColorFeeder.APPLY_GROUP_ID
UnderlaySkyTopColorScaleFeeder.IS_GLOBAL = UnderlaySkyTopColorFeeder.IS_GLOBAL
UnderlaySkyTopColorScaleFeeder.FILTER_CATEGORY = UnderlaySkyTopColorFeeder.FILTER_CATEGORY
UnderlaySkyTopColorScaleFeeder.apply = UnderlaySkyTopColorFeeder.apply
UnderlaySkyBottomColorFeeder = UnderlaySkyBottomColorFeeder or CoreClass.class(Vector3Feeder)
UnderlaySkyBottomColorFeeder.DATA_PATH_KEY = Idstring("underlay_effect/sky/color2"):key()
UnderlaySkyBottomColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
UnderlaySkyBottomColorFeeder.IS_GLOBAL = true
UnderlaySkyBottomColorFeeder.FILTER_CATEGORY = "Sky"

function UnderlaySkyBottomColorFeeder:apply(handler, viewport, scene)
	if UnderlayPathFeeder.sky_material then
		local color = handler:get_value(UnderlaySkyBottomColorFeeder.DATA_PATH_KEY)

		if color then
			local color_scale = handler:get_value(UnderlaySkyBottomColorScaleFeeder.DATA_PATH_KEY) or 1

			mvector3.set(temp_vector3, color)
			mvector3.multiply(temp_vector3, color_scale)
			UnderlayPathFeeder.sky_material:set_variable(ids_bottom_color, temp_vector3)
		else
			UnderlayPathFeeder.sky_material:set_variable(ids_bottom_color, zero_vector3)
		end
	end
end

UnderlaySkyBottomColorScaleFeeder = UnderlaySkyBottomColorScaleFeeder or CoreClass.class(Feeder)
UnderlaySkyBottomColorScaleFeeder.DATA_PATH_KEY = Idstring("underlay_effect/sky/color2_scale"):key()
UnderlaySkyBottomColorScaleFeeder.APPLY_GROUP_ID = UnderlaySkyBottomColorFeeder.APPLY_GROUP_ID
UnderlaySkyBottomColorScaleFeeder.IS_GLOBAL = UnderlaySkyBottomColorFeeder.IS_GLOBAL
UnderlaySkyBottomColorScaleFeeder.FILTER_CATEGORY = UnderlaySkyBottomColorFeeder.FILTER_CATEGORY
UnderlaySkyBottomColorScaleFeeder.apply = UnderlaySkyBottomColorFeeder.apply
PostAmbientFalloffScaleFeeder = PostAmbientFalloffScaleFeeder or CoreClass.class(Feeder)
PostAmbientFalloffScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/ambient_falloff_scale"):key()
PostAmbientFalloffScaleFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostAmbientFalloffScaleFeeder.IS_GLOBAL = nil
PostAmbientFalloffScaleFeeder.FILTER_CATEGORY = "Ambient"

function PostAmbientFalloffScaleFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_ambient_falloff_scale, self._current)
end

PostAmbientColorFeeder = PostAmbientColorFeeder or CoreClass.class(Vector3Feeder)
PostAmbientColorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/ambient_color"):key()
PostAmbientColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostAmbientColorFeeder.IS_GLOBAL = nil
PostAmbientColorFeeder.FILTER_CATEGORY = "Ambient"

function PostAmbientColorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)
	local color = handler:get_value(PostAmbientColorFeeder.DATA_PATH_KEY)

	if color then
		local color_scale = handler:get_value(PostAmbientColorScaleFeeder.DATA_PATH_KEY) or 1

		mvector3.set(temp_vector3, color)
		mvector3.multiply(temp_vector3, color_scale * platform_intensity_scale)
		material:set_variable(ids_ambient_color, temp_vector3)
	else
		material:set_variable(ids_ambient_color, zero_vector3)
	end
end

PostAmbientColorScaleFeeder = PostAmbientColorScaleFeeder or CoreClass.class(Feeder)
PostAmbientColorScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/ambient_color_scale"):key()
PostAmbientColorScaleFeeder.APPLY_GROUP_ID = PostAmbientColorFeeder.APPLY_GROUP_ID
PostAmbientColorScaleFeeder.IS_GLOBAL = PostAmbientColorFeeder.IS_GLOBAL
PostAmbientColorScaleFeeder.FILTER_CATEGORY = PostAmbientColorFeeder.FILTER_CATEGORY
PostAmbientColorScaleFeeder.apply = PostAmbientColorFeeder.apply
PostSkyTopColorFeeder = PostSkyTopColorFeeder or CoreClass.class(Vector3Feeder)
PostSkyTopColorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/sky_top_color"):key()
PostSkyTopColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostSkyTopColorFeeder.IS_GLOBAL = nil
PostSkyTopColorFeeder.FILTER_CATEGORY = "Ambient"

function PostSkyTopColorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)
	local color = handler:get_value(PostSkyTopColorFeeder.DATA_PATH_KEY)

	if color then
		local color_scale = handler:get_value(PostSkyTopColorScaleFeeder.DATA_PATH_KEY) or 1

		mvector3.set(temp_vector3, color)
		mvector3.multiply(temp_vector3, color_scale * platform_intensity_scale)
		material:set_variable(ids_sky_top_color, temp_vector3)
	else
		material:set_variable(ids_sky_top_color, zero_vector3)
	end
end

PostSkyTopColorScaleFeeder = PostSkyTopColorScaleFeeder or CoreClass.class(Feeder)
PostSkyTopColorScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/sky_top_color_scale"):key()
PostSkyTopColorScaleFeeder.APPLY_GROUP_ID = PostSkyTopColorFeeder.APPLY_GROUP_ID
PostSkyTopColorScaleFeeder.IS_GLOBAL = PostSkyTopColorFeeder.IS_GLOBAL
PostSkyTopColorScaleFeeder.FILTER_CATEGORY = PostSkyTopColorFeeder.FILTER_CATEGORY
PostSkyTopColorScaleFeeder.apply = PostSkyTopColorFeeder.apply
PostSkyBottomColorFeeder = PostSkyBottomColorFeeder or CoreClass.class(Vector3Feeder)
PostSkyBottomColorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/sky_bottom_color"):key()
PostSkyBottomColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostSkyBottomColorFeeder.IS_GLOBAL = nil
PostSkyBottomColorFeeder.FILTER_CATEGORY = "Ambient"

function PostSkyBottomColorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)
	local color = handler:get_value(PostSkyBottomColorFeeder.DATA_PATH_KEY)

	if color then
		local color_scale = handler:get_value(PostSkyBottomColorScaleFeeder.DATA_PATH_KEY) or 1

		mvector3.set(temp_vector3, color)
		mvector3.multiply(temp_vector3, color_scale * platform_intensity_scale)
		material:set_variable(ids_sky_bottom_color, temp_vector3)
	else
		material:set_variable(ids_sky_bottom_color, zero_vector3)
	end
end

PostSkyBottomColorScaleFeeder = PostSkyBottomColorScaleFeeder or CoreClass.class(Feeder)
PostSkyBottomColorScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/sky_bottom_color_scale"):key()
PostSkyBottomColorScaleFeeder.APPLY_GROUP_ID = PostSkyBottomColorFeeder.APPLY_GROUP_ID
PostSkyBottomColorScaleFeeder.IS_GLOBAL = PostSkyBottomColorFeeder.IS_GLOBAL
PostSkyBottomColorScaleFeeder.FILTER_CATEGORY = PostSkyBottomColorFeeder.FILTER_CATEGORY
PostSkyBottomColorScaleFeeder.apply = PostSkyBottomColorFeeder.apply
PostFogStartColorFeeder = PostFogStartColorFeeder or CoreClass.class(Vector3Feeder)
PostFogStartColorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_start_color"):key()
PostFogStartColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogStartColorFeeder.IS_GLOBAL = nil
PostFogStartColorFeeder.FILTER_CATEGORY = "Fog"

function PostFogStartColorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	mvector3.set(temp_vector3, self._current)
	mvector3.multiply(temp_vector3, platform_intensity_scale)
	material:set_variable(ids_fog_start_color, temp_vector3)
end

PostFogFarLowColorFeeder = PostFogFarLowColorFeeder or CoreClass.class(Vector3Feeder)
PostFogFarLowColorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_far_low_color"):key()
PostFogFarLowColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogFarLowColorFeeder.IS_GLOBAL = nil
PostFogFarLowColorFeeder.FILTER_CATEGORY = "Fog"

function PostFogFarLowColorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	mvector3.set(temp_vector3, self._current)
	mvector3.multiply(temp_vector3, platform_intensity_scale)
	material:set_variable(ids_fog_far_low_color, temp_vector3)
end

PostFogMinRangeFeeder = PostFogMinRangeFeeder or CoreClass.class(Feeder)
PostFogMinRangeFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_min_range"):key()
PostFogMinRangeFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogMinRangeFeeder.IS_GLOBAL = nil
PostFogMinRangeFeeder.FILTER_CATEGORY = "Fog"

function PostFogMinRangeFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_fog_min_range, self._current)
end

PostFogMaxRangeFeeder = PostFogMaxRangeFeeder or CoreClass.class(Feeder)
PostFogMaxRangeFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_max_range"):key()
PostFogMaxRangeFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogMaxRangeFeeder.IS_GLOBAL = nil
PostFogMaxRangeFeeder.FILTER_CATEGORY = "Fog"

function PostFogMaxRangeFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_fog_max_range, self._current)
end

PostFogMaxDensityFeeder = PostFogMaxDensityFeeder or CoreClass.class(Feeder)
PostFogMaxDensityFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_max_density"):key()
PostFogMaxDensityFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogMaxDensityFeeder.DEFAULT_VALUE = 1
PostFogMaxDensityFeeder.IS_GLOBAL = nil
PostFogMaxDensityFeeder.FILTER_CATEGORY = "Fog"

function PostFogMaxDensityFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_fog_max_density, self._current)
end

PostAmbientScaleFeeder = PostAmbientScaleFeeder or CoreClass.class(Feeder)
PostAmbientScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/ambient_scale"):key()
PostAmbientScaleFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostAmbientScaleFeeder.IS_GLOBAL = nil
PostAmbientScaleFeeder.FILTER_CATEGORY = "Ambient"

function PostAmbientScaleFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_ambient_scale, self._current)
end

PostEffectLightScaleFeeder = PostEffectLightScaleFeeder or CoreClass.class(Feeder)
PostEffectLightScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/effect_light_scale"):key()
PostEffectLightScaleFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostEffectLightScaleFeeder.IS_GLOBAL = nil
PostEffectLightScaleFeeder.FILTER_CATEGORY = "Ambient"

function PostEffectLightScaleFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_effect_light_scale, self._current)
end

local function _apply_fov_ratio(current)
end

PostShadowSlice0Feeder = PostShadowSlice0Feeder or CoreClass.class(Vector3Feeder)
PostShadowSlice0Feeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/slice0"):key()
PostShadowSlice0Feeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSlice0Feeder.IS_GLOBAL = nil
PostShadowSlice0Feeder.FILTER_CATEGORY = "Shadow"

function PostShadowSlice0Feeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	_apply_fov_ratio(self._current)
	material:set_variable(ids_slice0, self._current)
end

PostShadowSlice1Feeder = PostShadowSlice1Feeder or CoreClass.class(Vector3Feeder)
PostShadowSlice1Feeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/slice1"):key()
PostShadowSlice1Feeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSlice1Feeder.IS_GLOBAL = nil
PostShadowSlice1Feeder.FILTER_CATEGORY = "Shadow"

function PostShadowSlice1Feeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	_apply_fov_ratio(self._current)
	material:set_variable(ids_slice1, self._current)
end

PostShadowSlice2Feeder = PostShadowSlice2Feeder or CoreClass.class(Vector3Feeder)
PostShadowSlice2Feeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/slice2"):key()
PostShadowSlice2Feeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSlice2Feeder.IS_GLOBAL = nil
PostShadowSlice2Feeder.FILTER_CATEGORY = "Shadow"

function PostShadowSlice2Feeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	_apply_fov_ratio(self._current)
	material:set_variable(ids_slice2, self._current)
end

PostShadowSlice3Feeder = PostShadowSlice3Feeder or CoreClass.class(Vector3Feeder)
PostShadowSlice3Feeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/slice3"):key()
PostShadowSlice3Feeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSlice3Feeder.IS_GLOBAL = nil
PostShadowSlice3Feeder.FILTER_CATEGORY = "Shadow"

function PostShadowSlice3Feeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	_apply_fov_ratio(self._current)
	material:set_variable(ids_slice3, self._current)
end

PostShadowSliceDepthsFeeder = PostShadowSliceDepthsFeeder or CoreClass.class(Vector3Feeder)
PostShadowSliceDepthsFeeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/shadow_slice_depths"):key()
PostShadowSliceDepthsFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSliceDepthsFeeder.IS_GLOBAL = nil
PostShadowSliceDepthsFeeder.FILTER_CATEGORY = "Shadow"

function PostShadowSliceDepthsFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	_apply_fov_ratio(self._current)
	material:set_variable(ids_shadow_slice_depths, self._current)
end

PostShadowSliceOverlapFeeder = PostShadowSliceOverlapFeeder or CoreClass.class(Vector3Feeder)
PostShadowSliceOverlapFeeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/shadow_slice_overlap"):key()
PostShadowSliceOverlapFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSliceOverlapFeeder.IS_GLOBAL = nil
PostShadowSliceOverlapFeeder.FILTER_CATEGORY = "Shadow"

function PostShadowSliceOverlapFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	_apply_fov_ratio(self._current)
	material:set_variable(ids_shadow_slice_overlap, self._current)
end

PostEffectBloomThresholdFeeder = PostEffectBloomThresholdFeeder or CoreClass.class(Feeder)
PostEffectBloomThresholdFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/bloom_threshold"):key()
PostEffectBloomThresholdFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostEffectBloomThresholdFeeder.IS_GLOBAL = nil
PostEffectBloomThresholdFeeder.DEFAULT_VALUE = 0.55
PostEffectBloomThresholdFeeder.FILTER_CATEGORY = "Effect"

function PostEffectBloomThresholdFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_bloom_threshold, self._current)
end

PostEffectBloomIntensityFeeder = PostEffectBloomIntensityFeeder or CoreClass.class(Feeder)
PostEffectBloomIntensityFeeder.DATA_PATH_KEY = Idstring("post_effect/bloom_combine_post_processor/bloom_combine/bloom_lense/bloom_intensity"):key()
PostEffectBloomIntensityFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostEffectBloomIntensityFeeder.IS_GLOBAL = nil
PostEffectBloomIntensityFeeder.DEFAULT_VALUE = 0.5
PostEffectBloomIntensityFeeder.FILTER_CATEGORY = "Effect"

function PostEffectBloomIntensityFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_bloom_lense_id, ids_bloom_combine_processor, ids_bloom_combine, ids_bloom_lense)

	material:set_variable(ids_bloom_intensity, self._current)
end

PostEffectBloomBlurSizeFeeder = PostEffectBloomBlurSizeFeeder or CoreClass.class(Feeder)
PostEffectBloomBlurSizeFeeder.DATA_PATH_KEY = Idstring("post_effect/bloom_combine_post_processor/bloom_combine/bloom_lense/bloom_blur_size"):key()
PostEffectBloomBlurSizeFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostEffectBloomBlurSizeFeeder.IS_GLOBAL = nil
PostEffectBloomBlurSizeFeeder.DEFAULT_VALUE = 4
PostEffectBloomBlurSizeFeeder.FILTER_CATEGORY = "Effect"

function PostEffectBloomBlurSizeFeeder:apply(handler, viewport, scene)
	managers.environment_controller:bloom_blur_size(self._current, viewport)
end

PostEffectLenseIntensityFeeder = PostEffectLenseIntensityFeeder or CoreClass.class(Feeder)
PostEffectLenseIntensityFeeder.DATA_PATH_KEY = Idstring("post_effect/bloom_combine_post_processor/bloom_combine/bloom_lense/lense_intensity"):key()
PostEffectLenseIntensityFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostEffectLenseIntensityFeeder.IS_GLOBAL = nil
PostEffectLenseIntensityFeeder.DEFAULT_VALUE = 0.5
PostEffectLenseIntensityFeeder.FILTER_CATEGORY = "Effect"

function PostEffectLenseIntensityFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_bloom_lense_id, ids_bloom_combine_processor, ids_bloom_combine, ids_bloom_lense)

	material:set_variable(ids_lense_intensity, self._current)
end

EnvironmentEffectFeeder = EnvironmentEffectFeeder or CoreClass.class(StringFeeder)
EnvironmentEffectFeeder.DATA_PATH_KEY = Idstring("environment_effects/effects"):key()
EnvironmentEffectFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
EnvironmentEffectFeeder.IS_GLOBAL = nil
EnvironmentEffectFeeder.FILTER_CATEGORY = "Effect"

function EnvironmentEffectFeeder:apply(handler, viewport, scene)
	local effects = string.split(self._current, ";")

	if managers.environment_effects then
		managers.environment_effects:set_active_effects(effects)
	end
end

UnderlayPathFeeder.AFFECTED_LIST = {
	GlobalLightColorScaleFeeder,
	GlobalLightColorFeeder,
	SkyRotationFeeder,
	UnderlaySkyTopColorFeeder,
	UnderlaySkyTopColorScaleFeeder,
	UnderlaySkyBottomColorFeeder,
	UnderlaySkyBottomColorScaleFeeder
}
