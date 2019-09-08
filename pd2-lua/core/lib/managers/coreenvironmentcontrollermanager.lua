local flashbang_test_offset = Vector3(0, 0, 150)
local debug_vec1 = Vector3()
CoreEnvironmentControllerManager = CoreEnvironmentControllerManager or class()

function CoreEnvironmentControllerManager:init()
	self._DEFAULT_DOF_DISTANCE = 10
	self._dof_distance = self._DEFAULT_DOF_DISTANCE
	self._current_dof_distance = self._dof_distance
	self._chromatic_enabled = false
	self._base_chromatic_amount = 0.15
	self._base_contrast = 0.1
	self._hurt_value = 1
	self._taser_value = 1
	self._health_effect_value = 1
	self._suppression_value = 0
	self._current_suppression_value = 0
	self._old_suppression_value = 0
	self._supression_start_flash = 0
	self._old_health_effect_value = 1
	self._health_effect_value_diff = 0
	self._GAME_DEFAULT_COLOR_GRADING = "color_off"
	self._default_color_grading = self._GAME_DEFAULT_COLOR_GRADING
	self._ignore_user_color_grading = false
	self._blurzones = {}
	self._hit_right = 0
	self._hit_left = 0
	self._hit_up = 0
	self._hit_down = 0
	self._hit_front = 0
	self._hit_back = 0
	self._hit_some = 0
	self._hit_amount = 0.3
	self._hit_cap = 1
	self._current_flashbang = 0
	self._current_flashbang_flash = 0
	self._flashbang_multiplier = 1
	self._flashbang_duration = 1
	self._current_concussion = 0
	self._concussion_multiplier = 1
	self._concussion_duration = 1
	self._HE_blinding = 0
	self._downed_value = 0
	self._last_life = false

	self:_create_dof_tweak_data()

	self._current_dof_setting = "standard"
	self._near_plane_x = self._dof_tweaks[self._current_dof_setting].steelsight.near_plane_x
	self._near_plane_y = self._dof_tweaks[self._current_dof_setting].steelsight.near_plane_y
	self._far_plane_x = self._dof_tweaks[self._current_dof_setting].steelsight.far_plane_x
	self._far_plane_y = self._dof_tweaks[self._current_dof_setting].steelsight.far_plane_y
	self._dof_override = false
	self._dof_override_near = 5
	self._dof_override_near_pad = 5
	self._dof_override_far = 5000
	self._dof_override_far_pad = 1000

	self:set_dome_occ_default()

	self._default_fov_value = 75
	self._current_fov_value = 75
	self._fov_ratio = 1
end

function CoreEnvironmentControllerManager:update(t, dt)
	self:_update_values(t, dt)
	self:set_post_composite(t, dt)
end

function CoreEnvironmentControllerManager:_update_values(t, dt)
	if self._current_dof_distance ~= self._dof_distance then
		self._current_dof_distance = math.lerp(self._current_dof_distance, self._dof_distance, 5 * dt)
	end

	if Global.debug_post_effects_enabled and self._current_suppression_value ~= self._suppression_value then
		self._current_suppression_value = math.step(self._current_suppression_value, self._suppression_value, 2 * dt)
	end
end

function CoreEnvironmentControllerManager:_refresh_fov_ratio_params(vp)
end

function CoreEnvironmentControllerManager:_update_fov_ratio()
	if self._current_fov_value == 0 then
		self._fov_ratio = 1

		return
	end

	self._fov_ratio = math.pow(self._default_fov_value / self._current_fov_value, 0.5)
end

function CoreEnvironmentControllerManager:fov_ratio()
	return self._fov_ratio
end

function CoreEnvironmentControllerManager:set_current_fov_value(current_fov_value)
	if self._current_fov_value ~= current_fov_value then
		self._current_fov_value = current_fov_value
		self._fov_ratio_dirty = true
	end
end

function CoreEnvironmentControllerManager:current_fov_value()
	return self._current_fov_value
end

function CoreEnvironmentControllerManager:set_default_fov_value(default_fov_value)
	if self._default_fov_value ~= default_fov_value then
		self._default_fov_value = default_fov_value
		self._fov_ratio_dirty = true
	end
end

function CoreEnvironmentControllerManager:default_fov_value()
	return self._default_fov_value
end

function CoreEnvironmentControllerManager:set_dof_distance(distance, in_steelsight, position)
	self._dof_distance = math.max(self._DEFAULT_DOF_DISTANCE, distance or self._DEFAULT_DOF_DISTANCE)
	self._in_steelsight = in_steelsight
end

function CoreEnvironmentControllerManager:set_default_color_grading(color_grading, ignore_user_setting)
	self._default_color_grading = color_grading or self._GAME_DEFAULT_COLOR_GRADING
	self._ignore_user_color_grading = ignore_user_setting or false
end

function CoreEnvironmentControllerManager:game_default_color_grading()
	return self._GAME_DEFAULT_COLOR_GRADING
end

function CoreEnvironmentControllerManager:default_color_grading()
	return self._default_color_grading
end

function CoreEnvironmentControllerManager:set_hurt_value(hurt)
	self._hurt_value = hurt
end

function CoreEnvironmentControllerManager:set_health_effect_value(health_effect_value)
	self._health_effect_value = health_effect_value
end

function CoreEnvironmentControllerManager:set_downed_value(downed_value)
	self._downed_value = downed_value
end

function CoreEnvironmentControllerManager:set_last_life(last_life)
	self._last_life = last_life
end

function CoreEnvironmentControllerManager:hurt_value()
	return self._hurt_value
end

function CoreEnvironmentControllerManager:set_taser_value(taser)
	self._taser_value = taser
end

function CoreEnvironmentControllerManager:taser_value()
	return self._taser_value
end

function CoreEnvironmentControllerManager:set_suppression_value(effective_value, raw_value)
	self._suppression_value = effective_value > 0 and 1 or 0
end

function CoreEnvironmentControllerManager:hit_feedback_front()
	self._hit_front = math.min(self._hit_front + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

function CoreEnvironmentControllerManager:hit_feedback_back()
	self._hit_back = math.min(self._hit_back + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

function CoreEnvironmentControllerManager:hit_feedback_right()
	self._hit_right = math.min(self._hit_right + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

function CoreEnvironmentControllerManager:hit_feedback_left()
	self._hit_left = math.min(self._hit_left + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

function CoreEnvironmentControllerManager:hit_feedback_up()
	self._hit_up = math.min(self._hit_up + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

function CoreEnvironmentControllerManager:hit_feedback_down()
	self._hit_down = math.min(self._hit_down + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

function CoreEnvironmentControllerManager:set_blurzone(id, mode, pos, radius, height, delete_after_fadeout)
	local blurzone = self._blurzones[id]

	if id then
		blurzone = blurzone or {
			opacity = 0,
			radius = 0,
			mode = -1,
			height = 0,
			delete_after_fadeout = false
		}

		if mode > 0 then
			blurzone.mode = mode
			blurzone.pos = pos
			blurzone.radius = radius
			blurzone.height = height

			if mode == 2 then
				blurzone.opacity = 2
				blurzone.mode = 1
				blurzone.update = self.blurzone_flash_in_line_of_sight
			elseif mode == 3 then
				blurzone.opacity = 2
				blurzone.mode = 1
				blurzone.update = self.blurzone_flash_in
			else
				blurzone.opacity = 0
				blurzone.update = self.blurzone_fade_in
			end

			if height > 0 then
				blurzone.check = self.blurzone_check_cylinder
			else
				blurzone.check = self.blurzone_check_sphere
			end

			blurzone.delete_after_fadeout = delete_after_fadeout
		elseif blurzone and blurzone.mode > 0 then
			blurzone.mode = mode
			blurzone.pos = blurzone.pos or pos
			blurzone.radius = blurzone.radius or radius
			blurzone.height = blurzone.height or height
			blurzone.opacity = 1
			blurzone.update = self.blurzone_fade_out

			if blurzone.height > 0 then
				blurzone.check = self.blurzone_check_cylinder
			else
				blurzone.check = self.blurzone_check_sphere
			end
		end

		self._blurzones[id] = blurzone
	end
end

function CoreEnvironmentControllerManager:set_all_blurzones(mode)
	for id, blurzone in pairs(self._blurzones) do
		self:set_blurzone(id, mode)
	end
end

function CoreEnvironmentControllerManager:_blurzones_update(t, dt, camera_pos)
	local result = 0

	for id, blurzone in pairs(self._blurzones) do
		if blurzone and blurzone.mode > -1 then
			local blur_zone_val = blurzone:update(self, t, dt, camera_pos, blurzone)

			if result < blur_zone_val then
				result = blur_zone_val
			end
		elseif blurzone.delete_after_fadeout then
			self._blurzones[id] = nil
		end
	end

	return result
end

function CoreEnvironmentControllerManager:blurzone_flash_in_line_of_sight(self, t, dt, camera_pos, blurzone)
	blurzone.opacity = blurzone.opacity - dt * 0.3
	self._HE_blinding = self:test_line_of_sight(blurzone.pos, 150, 1000, 2000)

	if blurzone.opacity < 1 then
		blurzone.opacity = 1
		blurzone.update = self.blurzone_fade_idle_line_of_sight
	end

	return blurzone:check(blurzone, camera_pos) * (1 + 11 * (blurzone.opacity - 1))
end

function CoreEnvironmentControllerManager:blurzone_flash_in(self, t, dt, camera_pos, blurzone)
	blurzone.opacity = blurzone.opacity - dt * 0.3

	if blurzone.opacity < 1 then
		blurzone.opacity = 1
		blurzone.update = self.blurzone_fade_idle
	end

	return blurzone:check(blurzone, camera_pos) * (1 + 11 * (blurzone.opacity - 1))
end

function CoreEnvironmentControllerManager:blurzone_fade_in(self, t, dt, camera_pos, blurzone)
	blurzone.opacity = blurzone.opacity + dt

	if blurzone.opacity > 1 then
		blurzone.opacity = 1
		blurzone.update = self.blurzone_fade_idle
	end

	return blurzone:check(blurzone, camera_pos)
end

function CoreEnvironmentControllerManager:blurzone_fade_out(self, t, dt, camera_pos, blurzone)
	blurzone.opacity = blurzone.opacity - dt

	if blurzone.opacity < 0 then
		blurzone.opacity = 0
		blurzone.mode = -1
		blurzone.update = self.blurzone_fade_idle
	end

	return blurzone:check(blurzone, camera_pos)
end

function CoreEnvironmentControllerManager:blurzone_fade_idle_line_of_sight(self, t, dt, camera_pos, blurzone)
	self._HE_blinding = self:test_line_of_sight(blurzone.pos, 150, 1000, 2000)

	return blurzone:check(blurzone, camera_pos)
end

function CoreEnvironmentControllerManager:blurzone_fade_idle(self, t, dt, camera_pos, blurzone)
	return blurzone:check(blurzone, camera_pos)
end

function CoreEnvironmentControllerManager:blurzone_fade_out_switch(self, t, dt, camera_pos, blurzone)
	return blurzone:check(blurzone, camera_pos)
end

function CoreEnvironmentControllerManager:blurzone_check_cylinder(blurzone, camera_pos)
	local pos_z = blurzone.pos.z
	local cam_z = camera_pos.z
	local len = nil

	if cam_z < pos_z then
		len = (blurzone.pos - camera_pos):length()
	elseif cam_z > pos_z + blurzone.height then
		len = (blurzone.pos:with_z(pos_z + blurzone.height) - camera_pos):length()
	else
		len = (blurzone.pos:with_z(cam_z) - camera_pos):length()
	end

	local result = math.min(len / blurzone.radius, 1)
	result = result * result

	return (1 - result) * blurzone.opacity
end

function CoreEnvironmentControllerManager:blurzone_check_sphere(blurzone, camera_pos)
	local len = (blurzone.pos - camera_pos):length()
	local result = math.min(len / blurzone.radius, 1)
	result = result * result

	return (1 - result) * blurzone.opacity
end

local ids_dof_near_plane = Idstring("near_plane")
local ids_dof_far_plane = Idstring("far_plane")
local ids_dof_settings = Idstring("settings")
local ids_radial_pos = Idstring("radial_pos")
local ids_radial_offset = Idstring("radial_offset")
local ids_tgl_r = Idstring("tgl_r")
local hit_feedback_rlu = Idstring("hit_feedback_rlu")
local hit_feedback_d = Idstring("hit_feedback_d")
local ids_hdr_post_processor = Idstring("hdr_post_processor")
local ids_hdr_post_composite = Idstring("post_DOF")
local ids_anti_aliasing_processor = Idstring("anti_aliasing_post_processor")
local ids_ao_post_processor = Idstring("ao_post_processor")
local ids_ao_mask_post_processor = Idstring("ao_mask_post_processor")
local mvec1 = Vector3()
local mvec2 = Vector3()
local new_cam_fwd = Vector3()
local new_cam_up = Vector3()
local new_cam_right = Vector3()
local ids_LUT_post = Idstring("color_grading_post")
local ids_LUT_settings = Idstring("lut_settings")
local ids_LUT_settings_a = Idstring("LUT_settings_a")
local ids_LUT_settings_b = Idstring("LUT_settings_b")
local ids_LUT_contrast = Idstring("contrast")

function CoreEnvironmentControllerManager:refresh_render_settings(vp)
	if not alive(self._vp) then
		return
	end

	local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local cubemap_name = lvl_tweak_data and lvl_tweak_data.cube or "cube_apply_empty"
	local color_grading = self._default_color_grading

	if not self._ignore_user_color_grading then
		color_grading = managers.user:get_setting("video_color_grading") or self._default_color_grading
	end

	self._vp:vp():set_post_processor_effect("World", Idstring("color_grading_post"), Idstring(color_grading))
	self._vp:vp():set_post_processor_effect("World", ids_hdr_post_processor, Idstring(managers.user:get_setting("light_adaption") and "default" or "no_light_adaption"))
end

function CoreEnvironmentControllerManager:set_post_composite(t, dt)
	local vp = managers.viewport:first_active_viewport()

	if not vp then
		return
	end

	if self._occ_dirty then
		self._occ_dirty = false

		self:_refresh_occ_params(vp)
	end

	if self._fov_ratio_dirty then
		self:_refresh_fov_ratio_params(vp)

		self._fov_ratio_dirty = false
	end

	if self._vp ~= vp or not alive(self._material) then
		local hdr_post_processor = vp:vp():get_post_processor_effect("World", ids_hdr_post_processor)

		if hdr_post_processor then
			local post_composite = hdr_post_processor:modifier(ids_hdr_post_composite)

			if not post_composite then
				return
			end

			self._material = post_composite:material()

			if not self._material then
				return
			end

			self._vp = vp

			self:_update_post_effects()
		end
	end

	local camera = vp:camera()
	local color_tweak = mvec1

	if camera then
		-- Nothing
	end

	if self._old_vp ~= vp then
		self._occ_dirty = true
		self._fov_ratio_dirty = true

		self:refresh_render_settings()

		self._old_vp = vp
	end

	local blur_zone_val = 0
	blur_zone_val = self:_blurzones_update(t, dt, camera:position())

	if self._hit_some > 0 then
		local hit_fade = dt * 1.5
		self._hit_some = math.max(self._hit_some - hit_fade, 0)
		self._hit_right = math.max(self._hit_right - hit_fade, 0)
		self._hit_left = math.max(self._hit_left - hit_fade, 0)
		self._hit_up = math.max(self._hit_up - hit_fade, 0)
		self._hit_down = math.max(self._hit_down - hit_fade, 0)
		self._hit_front = math.max(self._hit_front - hit_fade, 0)
		self._hit_back = math.max(self._hit_back - hit_fade, 0)
	end

	local flashbang = 0
	local flashbang_flash = 0

	if self._current_flashbang > 0 then
		local flsh = self._current_flashbang
		self._current_flashbang = math.max(self._current_flashbang - dt * 0.08 * self._flashbang_multiplier * self._flashbang_duration, 0)
		flashbang = math.min(self._current_flashbang, 1)
		self._current_flashbang_flash = math.max(self._current_flashbang_flash - dt * 0.9, 0)
		flashbang_flash = math.min(self._current_flashbang_flash, 1)
	end

	local concussion = 0

	if self._current_concussion > 0 then
		self._current_concussion = math.max(self._current_concussion - dt * 0.08 * self._concussion_multiplier * self._concussion_duration, 0)
		concussion = math.min(self._current_concussion, 1)
	end

	local hit_some_mod = 1 - self._hit_some
	hit_some_mod = hit_some_mod * hit_some_mod * hit_some_mod
	hit_some_mod = 1 - hit_some_mod
	local downed_value = self._downed_value / 100
	local death_mod = math.max(1 - self._health_effect_value - 0.5, 0) * 2
	local blur_zone_flashbang = blur_zone_val + flashbang
	local flash_1 = math.pow(flashbang, 0.4)
	flash_1 = flash_1 + math.pow(concussion, 0.4)
	local flash_2 = math.pow(flashbang, 16) + flashbang_flash

	if self._custom_dof_settings then
		self._material:set_variable(ids_dof_settings, self._custom_dof_settings)
	elseif flash_1 > 0 then
		self._material:set_variable(ids_dof_settings, Vector3(math.min(self._hit_some * 10, 1) + blur_zone_flashbang * 0.4, math.min(blur_zone_val + downed_value * 2 + flash_1, 1), 10 + math.abs(math.sin(t * 10) * 40) + downed_value * 3))
	else
		self._material:set_variable(ids_dof_settings, Vector3(math.min(self._hit_some * 10, 1) + blur_zone_flashbang * 0.4, math.min(blur_zone_val + downed_value * 2, 1), 1 + downed_value * 3))
	end

	self._material:set_variable(ids_radial_offset, Vector3((self._hit_left - self._hit_right) * 0.2, (self._hit_up - self._hit_down) * 0.2, self._hit_front - self._hit_back + blur_zone_flashbang * 0.1))
	self._material:set_variable(Idstring("contrast"), self._base_contrast + self._hit_some * 0.25)

	if self._chromatic_enabled then
		self._material:set_variable(Idstring("chromatic_amount"), self._base_chromatic_amount + blur_zone_val * 0.3 + flash_1 * 0.5)
	else
		self._material:set_variable(Idstring("chromatic_amount"), 0)
	end

	self:_update_dof(t, dt)

	local lut_post = vp:vp():get_post_processor_effect("World", ids_LUT_post)

	if lut_post then
		local lut_modifier = lut_post:modifier(ids_LUT_settings)

		if not lut_modifier then
			return
		end

		self._lut_modifier_material = lut_modifier:material()

		if not self._lut_modifier_material then
			return
		end
	end

	local hurt_mod = 1 - self._health_effect_value
	local health_diff = math.clamp((self._old_health_effect_value - self._health_effect_value) * 4, 0, 1)
	self._old_health_effect_value = self._health_effect_value

	if self._health_effect_value_diff < health_diff then
		self._health_effect_value_diff = health_diff
	end

	self._health_effect_value_diff = math.max(self._health_effect_value_diff - dt * 0.5, 0)

	self._lut_modifier_material:set_variable(ids_LUT_settings_a, Vector3(math.clamp(self._health_effect_value_diff * 1.3 * (1 + hurt_mod * 1.3), 0, 1.2), 0, math.min(blur_zone_val + self._HE_blinding, 1)))

	local last_life = 0

	if self._last_life then
		last_life = math.clamp((hurt_mod - 0.5) * 2, 0, 1)
	end

	self._lut_modifier_material:set_variable(ids_LUT_settings_b, Vector3(last_life, flash_2 + math.clamp(hit_some_mod * 2, 0, 1) * 0.25 + blur_zone_val * 0.15, 0))
	self._lut_modifier_material:set_variable(ids_LUT_contrast, flashbang * 0.5)
end

function CoreEnvironmentControllerManager:_update_post_effects()
	self:set_ao_setting(managers.user:get_setting("video_ao"))
	self:set_parallax_setting(managers.user:get_setting("parallax_mapping"))
	self:set_aa_setting(managers.user:get_setting("video_aa"))
end

function CoreEnvironmentControllerManager:_create_dof_tweak_data()
	local new_dof_settings = {
		none = {
			use_no_dof = true
		},
		standard = {}
	}
	new_dof_settings.standard.steelsight = {
		near_plane_x = 2500,
		near_plane_y = 2500,
		far_plane_x = 500,
		far_plane_y = 2000
	}
	new_dof_settings.standard.other = {
		near_plane_x = 10,
		near_plane_y = 12,
		far_plane_x = 4000,
		far_plane_y = 5000
	}
	self._dof_tweaks = new_dof_settings
end

function CoreEnvironmentControllerManager:set_dof_setting(setting)
	if not self._dof_tweaks[setting] then
		Application:error("[CoreEnvironmentControllerManager:set_dof_setting] DOF setting do not exist!", setting)

		return
	end

	self._current_dof_setting = setting

	if self._material then
		self:_update_dof(1, 1)
	end
end

local function set_modifier_transform(effect, id, transform)
	local modifier = effect:modifier(Idstring(id))

	if modifier then
		transform(modifier)

		return
	end

	local count = 1

	while true do
		local id = Idstring(id .. "_" .. count)
		modifier = effect:modifier(id)

		if modifier then
			transform(modifier)
		else
			break
		end

		count = count + 1
	end
end

local function set_modifier_visibility(effect, id, visibility_state)
	set_modifier_transform(effect, id, function (mod)
		mod:set_visibility(visibility_state)
	end)
end

local function set_post_material_parameter(post_id, modifier_name, parameter_id, value)
	local vp = managers.viewport:first_active_viewport()

	if vp then
		local effect = vp:vp():get_post_processor_effect("World", post_id)

		if effect then
			set_modifier_transform(effect, modifier_name, function (modifier)
				local material = modifier:material()

				if material then
					material:set_variable(parameter_id, value)
				end
			end)
		end
	end
end

function CoreEnvironmentControllerManager:get_aa_setting()
	return self._aa_setting or "AA_off"
end

function CoreEnvironmentControllerManager:set_aa_setting(setting, vp)
	local effect = "AA_" .. setting
	self._aa_setting = effect
	vp = vp or self._vp and self._vp:vp() or nil

	if vp then
		vp:set_post_processor_effect("World", ids_anti_aliasing_processor, Idstring(effect))
	end
end

function CoreEnvironmentControllerManager:set_parallax_setting(setting)
	local global_material = Application:global_material()

	if global_material then
		global_material:set_variable(Idstring("use_parallax"), setting and 1 or 0)
	end
end

function CoreEnvironmentControllerManager:bloom_blur_size(size, vp)
	local effects = {
		Idstring("bloom_blur_1"),
		Idstring("bloom_blur_2"),
		Idstring("bloom_blur_3")
	}
	vp = vp or self._vp:vp()

	if vp then
		local effect = vp:get_post_processor_effect("World", Idstring("bloom_combine_post_processor"))

		if effect then
			for i = 1, table.getn(effects), 1 do
				local visibility = i >= 5 - size
				local mod = effect:modifier(effects[i])

				if mod then
					mod:set_visibility(visibility)
				end
			end
		end
	end
end

function CoreEnvironmentControllerManager:set_ssao_radius(value)
	set_post_material_parameter(ids_ao_post_processor, "post_SSAO", Idstring("ssao_radius"), value)
end

function CoreEnvironmentControllerManager:set_ssao_range(k, i)
	set_post_material_parameter(ids_ao_post_processor, "post_SSAO", Idstring("ssao_steepness"), k)
	set_post_material_parameter(ids_ao_post_processor, "post_SSAO", Idstring("ssao_inflexion"), i)
end

function CoreEnvironmentControllerManager:get_ao_setting()
	return self._ao_setting or "AO_off"
end

function CoreEnvironmentControllerManager:set_ao_setting(setting, vp)
	local effect = "AO_" .. setting
	self._ao_setting = effect
	vp = vp or self._vp and self._vp:vp() or nil

	if vp then
		local effect = vp:set_post_processor_effect("World", ids_ao_post_processor, Idstring(effect))

		vp:set_post_processor_effect("World", ids_ao_mask_post_processor, setting ~= "off" and Idstring("AO_mask_weapon") or Idstring("AO_off"))

		local deferred_processor = vp:get_post_processor_effect("World", Idstring("deferred"))

		if deferred_processor then
			local apply_ambient = deferred_processor:modifier(Idstring("apply_ambient"))

			if apply_ambient then
				apply_ambient:material():set_variable(Idstring("use_ssao"), setting ~= "off" and effect and 1 or 0)
			end
		end
	end
end

function CoreEnvironmentControllerManager:remove_dof_tweak_data(remove_setting_name)
	if not self._dof_tweaks[new_setting_name] then
		Application:error("[CoreEnvironmentControllerManager:remove_dof_tweak_data] DOF setting do not exist!", remove_setting_name)

		return
	end

	self._dof_tweaks[remove_setting_name] = nil

	if self._current_dof_setting == remove_setting_name then
		if self._dof_tweaks.standard then
			self._current_dof_setting = "standard"
		else
			self._current_dof_setting = next(self._dof_tweaks)
		end
	end
end

function CoreEnvironmentControllerManager:add_dof_tweak_data(new_setting_name, new_setting_tweak_data)
	if self._dof_tweaks[new_setting_name] then
		Application:error("[CoreEnvironmentControllerManager:add_dof_tweak_data] DOF setting already exists!", new_setting_name)

		return
	end

	self._dof_tweaks[new_setting_name] = new_setting_tweak_data
end

function CoreEnvironmentControllerManager:_update_dof(t, dt)
	local mvec_set = mvector3.set_static
	local mvec = mvec1

	if self._dof_override then
		if self._dof_override_transition_params then
			local params = self._dof_override_transition_params
			params.time = math.max(0, params.time - dt)
			local lerp_v = math.bezier({
				0,
				0,
				1,
				1
			}, 1 - params.time / params.total_t)
			self._dof_override_near = math.lerp(params.start.near, params.stop.near, lerp_v)
			self._dof_override_near_pad = math.lerp(params.start.near_pad, params.stop.near_pad, lerp_v)
			self._dof_override_far = math.lerp(params.start.far, params.stop.far, lerp_v)
			self._dof_override_far_pad = math.lerp(params.start.far_pad, params.stop.far_pad, lerp_v)

			if params.time == 0 then
				self._dof_override_transition_params = nil
			end
		end

		mvec_set(mvec, self._dof_override_near, self._dof_override_near + self._dof_override_near_pad, 0)
		self._material:set_variable(ids_dof_near_plane, mvec)
		mvec_set(mvec, self._dof_override_far - self._dof_override_far_pad, self._dof_override_far, 1)
		self._material:set_variable(ids_dof_far_plane, mvec)
	else
		local dof_settings = self._dof_tweaks[self._current_dof_setting]

		if dof_settings.use_no_dof == true then
			mvec_set(mvec, 0, 0, 0)
			self._material:set_variable(ids_dof_near_plane, mvec)
			mvec_set(mvec, 10000, 10000, 1)
			self._material:set_variable(ids_dof_far_plane, mvec)
		elseif self._in_steelsight then
			dof_settings = dof_settings.steelsight
			local dof_plane_v = math.clamp(self._current_dof_distance / 5000, 0, 1)
			self._near_plane_x = math.lerp(500, dof_settings.near_plane_x, dof_plane_v)
			self._near_plane_y = math.lerp(20, dof_settings.near_plane_y, dof_plane_v)
			self._far_plane_x = math.lerp(100, dof_settings.far_plane_x, dof_plane_v)
			self._far_plane_y = math.lerp(500, dof_settings.far_plane_y, dof_plane_v)

			mvec_set(mvec, math.max(self._current_dof_distance - self._near_plane_x, 5), self._near_plane_y, 0)
			self._material:set_variable(ids_dof_near_plane, mvec)
			mvec_set(mvec, self._current_dof_distance + self._far_plane_x, self._far_plane_y, 1)
			self._material:set_variable(ids_dof_far_plane, mvec)
		else
			dof_settings = dof_settings.other
			local dof_speed = math.min(10 * dt, 1)
			self._near_plane_x = math.lerp(self._near_plane_x, dof_settings.near_plane_x, dof_speed)
			self._near_plane_y = math.lerp(self._near_plane_y, dof_settings.near_plane_y, dof_speed)
			self._far_plane_x = math.lerp(self._far_plane_x, dof_settings.far_plane_x, dof_speed)
			self._far_plane_y = math.lerp(self._far_plane_y, dof_settings.far_plane_y, dof_speed)

			mvec_set(mvec, self._near_plane_x, self._near_plane_y, 0)
			self._material:set_variable(ids_dof_near_plane, mvec)
			mvec_set(mvec, self._far_plane_x, self._far_plane_y, 1)
			self._material:set_variable(ids_dof_far_plane, mvec)
		end
	end
end

function CoreEnvironmentControllerManager:set_flashbang(flashbang_pos, line_of_sight, travel_dis, linear_dis, duration)
	local flash = self:test_line_of_sight(flashbang_pos + flashbang_test_offset, 200, 1000, 3000)
	self._flashbang_duration = duration

	if flash > 0 then
		self._current_flashbang = math.min(self._current_flashbang + flash, 1.5) * self._flashbang_duration
		self._current_flashbang_flash = math.min(self._current_flashbang_flash + flash, 1.5) * self._flashbang_duration
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/explosion_grenade"),
		position = flashbang_pos,
		normal = Vector3(0, 0, 1)
	})
end

function CoreEnvironmentControllerManager:set_concussion_grenade(flashbang_pos, line_of_sight, travel_dis, linear_dis, duration)
	local concussion = self:test_line_of_sight(flashbang_pos + flashbang_test_offset, 200, 1000, 3000)
	self._concussion_duration = duration

	if concussion > 0 then
		self._current_concussion = math.min(self._current_concussion + concussion, 1.5) * self._concussion_duration
	end
end

function CoreEnvironmentControllerManager:set_flashbang_multiplier(multiplier)
	self._flashbang_multiplier = multiplier ~= 0 and multiplier or 1
	self._flashbang_multiplier = 1 + (1 - self._flashbang_multiplier) * 2
end

function CoreEnvironmentControllerManager:test_line_of_sight(test_pos, min_distance, dot_distance, max_distance)
	local tmp_vec1 = Vector3()
	local tmp_vec2 = Vector3()
	local tmp_vec3 = Vector3()
	local vp = managers.viewport:first_active_viewport()

	if not vp then
		return 0
	end

	local camera = vp:camera()
	local cam_pos = tmp_vec1

	camera:m_position(cam_pos)

	local test_vec = tmp_vec2
	local dis = mvector3.direction(test_vec, cam_pos, test_pos)

	if max_distance < dis then
		return 0
	end

	if dis < min_distance then
		return 1
	end

	local dot_mul = 1
	local max_dot = math.cos(75)
	local cam_rot = camera:rotation()
	local cam_fwd = camera:rotation():y()

	if mvector3.dot(cam_fwd, test_vec) < max_dot then
		if dis < dot_distance then
			dot_mul = 0.5
		else
			return 0
		end
	end

	local ray_hit = World:raycast("ray", cam_pos, test_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")

	if ray_hit then
		return 0
	end

	local flash = math.max(dis - min_distance, 0) / (max_distance - min_distance)
	flash = (1 - flash) * dot_mul

	return flash
end

function CoreEnvironmentControllerManager:set_dof_override(mode)
	self._dof_override = mode
end

function CoreEnvironmentControllerManager:set_dof_override_ranges(near, near_pad, far, far_pad)
	self._dof_override_near = near
	self._dof_override_near_pad = near_pad
	self._dof_override_far = far
	self._dof_override_far_pad = far_pad
end

function CoreEnvironmentControllerManager:set_dof_override_ranges_transition(time, near, near_pad, far, far_pad)
	self:set_dof_override(true)

	self._dof_override_transition_params = {
		total_t = time,
		time = time,
		start = {}
	}
	self._dof_override_transition_params.start.near = self._dof_override_near
	self._dof_override_transition_params.start.near_pad = self._dof_override_near_pad
	self._dof_override_transition_params.start.far = self._dof_override_far
	self._dof_override_transition_params.start.far_pad = self._dof_override_far_pad
	self._dof_override_transition_params.stop = {
		near = near,
		near_pad = near_pad,
		far = far,
		far_pad = far_pad
	}
end

function CoreEnvironmentControllerManager:set_dome_occ_default()
	local area = 20000
	local occ_texture = "core/textures/dome_occ_test"

	self:set_dome_occ_params(Vector3(-(area * 0.5), -(area * 0.5), 0), Vector3(area, area, 1200), occ_texture)
end

function CoreEnvironmentControllerManager:set_dome_occ_params(occ_pos, occ_size, occ_texture)
	self._occ_dirty = true
	self._occ_pos = occ_pos
	self._occ_pos = Vector3(self._occ_pos.x, self._occ_pos.y - occ_size.y, self._occ_pos.z)
	self._occ_size = occ_size
	self._occ_texture = occ_texture
end

function CoreEnvironmentControllerManager:_refresh_occ_params(vp)
	local deferred_processor = (vp or self._vp):vp():get_post_processor_effect("World", Idstring("deferred"))

	if deferred_processor then
		local apply_ambient = deferred_processor:modifier(Idstring("apply_ambient"))

		if apply_ambient then
			local dome_occ_feed = apply_ambient:material()

			if dome_occ_feed then
				dome_occ_feed:set_variable(Idstring("dome_occ_pos"), self._occ_pos)
				dome_occ_feed:set_variable(Idstring("dome_occ_size"), self._occ_size)
				Application:set_material_texture(dome_occ_feed, Idstring("filter_color_texture"), Idstring(self._occ_texture), Idstring("normal"), 0)
			end
		end

		local shadow = deferred_processor:modifier(Idstring("move_global_occ"))

		if shadow then
			local dome_occ_feed_ps3 = shadow:material()

			if dome_occ_feed_ps3 then
				Application:set_material_texture(dome_occ_feed_ps3, Idstring("filter_color_texture"), Idstring(self._occ_texture), Idstring("normal"), 0)
			end
		end
	end
end

function CoreEnvironmentControllerManager:set_custom_dof_settings(custom_dof_settings)
	self._custom_dof_settings = custom_dof_settings
end

function CoreEnvironmentControllerManager:set_base_chromatic_amount(base_chromatic_amount)
	self._base_chromatic_amount = base_chromatic_amount
end

function CoreEnvironmentControllerManager:set_chromatic_enabled(enabled)
	return

	self._chromatic_enabled = enabled

	if self._material then
		if self._chromatic_enabled then
			self._material:set_variable(Idstring("chromatic_amount"), self._base_chromatic_amount)
		else
			self._material:set_variable(Idstring("chromatic_amount"), 0)
		end
	end
end

function CoreEnvironmentControllerManager:base_chromatic_amount()
	return self._base_chromatic_amount
end

function CoreEnvironmentControllerManager:set_base_contrast(base_contrast)
	self._base_contrast = base_contrast
end

function CoreEnvironmentControllerManager:base_contrast()
	return self._base_contrast
end

local ids_d_sun = Idstring("d_sun")

function CoreEnvironmentControllerManager:feed_params()
end

function CoreEnvironmentControllerManager:feed_param_underlay(material_name, param_name, param_value)
	local material = Underlay:material(Idstring(material_name))

	material:set_variable(Idstring(param_name), param_value)
end

function CoreEnvironmentControllerManager:set_global_param(param_name, param_value)
end
