ScopeCamera = ScopeCamera or class()
ScopeCamera.DISABLE_STABILIZATION = false

function ScopeCamera:init(camera)
	self._camera_ext = camera

	self:_setup_camera()

	self._slotmask = managers.slot:get_mask("statics")

	self:_add_setting_callback("weapon_precision_mode", "_weapon_precision_mode_changed")
end

function ScopeCamera:_weapon_precision_mode_changed(setting, old, new)
	self._weapon_precision_mode = new
end

function ScopeCamera:_add_setting_callback(setting_name, method)
	local clbk = callback(self, self, method)

	managers.vr:add_setting_changed_callback(setting_name, clbk)
	clbk(setting_name, nil, managers.vr:get_setting(setting_name))

	self._settings = self._settings or {}

	table.insert(self._settings, {
		name = setting_name,
		clbk = clbk
	})
end

function ScopeCamera:_setup_camera()
	local rt_resolution = Vector3(512, 512, 0)
	local rt = Application:create_texture("render_target", rt_resolution.x, rt_resolution.y)

	rt:set_disable_clear(true)

	local camera_object = World:create_camera()

	camera_object:set_near_range(3)
	camera_object:set_far_range(250000)
	camera_object:set_fov(30)
	camera_object:set_aspect_ratio(1)
	camera_object:set_stereo(false)

	local resolution = VRManager:target_resolution()
	local scale_x = rt_resolution.x / resolution.x
	local scale_y = rt_resolution.y / resolution.y
	local vp = managers.vr:new_vp(0, 0, scale_x, scale_y, "scope", CoreManagerBase.PRIO_WORLDCAMERA)

	vp:set_render_params("World", vp:vp(), nil, "Underlay", vp:vp())
	vp:set_camera(camera_object)
	vp:set_enable_adaptive_quality(false)
	vp:set_active(false)
	vp:set_pre_render(true)
	vp:vp():set_post_processor_effect("World", Idstring("shadow_processor"), Idstring("identity"))
	vp:vp():set_post_processor_effect("World", Idstring("ao_post_processor"), Idstring("AO_aob"))
	vp:vp():set_post_processor_effect("World", Idstring("anti_aliasing_post_processor"), Idstring("AA_off"))

	local clear_vp = managers.vr:new_vp(0, 0, scale_x, scale_y, "scope_clear", CoreManagerBase.PRIO_WORLDCAMERA)

	clear_vp:set_render_params("GBufferClear", clear_vp:vp(), rt)
	clear_vp:vp():set_post_processor_effect("GBufferClear", Idstring("transfer_back_buffer"), Idstring("render_backbuffer_to_target"))
	clear_vp:set_camera(camera_object)
	clear_vp:set_enable_adaptive_quality(false)
	clear_vp:set_active(false)
	clear_vp:set_pre_render(true)

	self._resolution = rt_resolution
	self._render_target = rt
	self._camera = camera_object
	self._vp = vp
	self._clear_vp = clear_vp
end

function ScopeCamera:link_scope(camera_object, screen_object, material, texture_channel, zoom)
	material:set_variable(Idstring("scope_zoom"), 1)
	material:set_variable(Idstring("scope_fadeout"), 1)

	self._material = material

	self._camera:link(camera_object)
	Application:set_material_texture(material, texture_channel, self._render_target)

	self._texture_channel = texture_channel

	self._camera:set_fov(zoom)
	self._vp:set_active(true)
	self._clear_vp:set_active(true)

	self._camera_object = camera_object
	self._screen_object = screen_object
	self._scope_active = true
end

function ScopeCamera:unlink_scope()
	self._vp:set_active(false)
	self._clear_vp:set_active(false)

	self._scope_active = false
end

function ScopeCamera:update(t, dt)
	if not self._scope_active then
		return
	end

	if alive(self._camera_object) and alive(self._screen_object) then
		local p1 = self._camera_object:position()
		local p2 = self._screen_object:position()
		local forward = p1 - p2
		local hlen = mvector3.normalize(forward) * 0.5
		local rot = self._camera_object:rotation() * Rotation(90, 0, 0)
		local collision = World:capsule_overlap(p2 + forward * hlen, rot, hlen, 1.5, self._slotmask)
		local eye_pos = self._camera_ext:position()
		local dir = p2 - eye_pos
		local length = mvector3.normalize(dir)
		local distance_to_screen_plane = mvector3.dot(p2, forward) - mvector3.dot(eye_pos, forward)
		local zoom = math.max((2.2 + distance_to_screen_plane) / 5.5, 0.9)

		self._material:set_variable(Idstring("scope_zoom"), zoom)

		local angle = math.dot(dir, self._camera_object:rotation():y())
		local visible = (angle > 0.965 or length < 20) and true or false
		visible = visible and not collision

		self._material:set_variable(Idstring("scope_fadeout"), visible and 0 or 1)
		self._vp:set_active(visible)
		self._clear_vp:set_active(visible)

		local resolution = VRManager:target_resolution()
		local rt_resolution = self._resolution
		local scale_x = rt_resolution.x / resolution.x
		local scale_y = rt_resolution.y / resolution.y
		local scale = math.lerp(1, 0.25, math.clamp((length - 30) / 50, 0, 1))
		scale_x = scale_x * scale
		scale_y = scale_y * scale

		self._vp:vp():set_dimensions(0, 0, scale_x, scale_y)
		self._clear_vp:vp():set_dimensions(0, 0, scale_x, scale_y)

		if self._weapon_precision_mode then
			local player_unit = managers.player:player_unit()

			if player_unit then
				local hand = player_unit:hand()
				local assist_mode = hand:current_hand_state(1):name() == "weapon_assist" or hand:current_hand_state(2):name() == "weapon_assist"

				if assist_mode and not ScopeCamera.DISABLE_STABILIZATION then
					local precision_mode = angle > 0.9 and length < 30 or length < 10

					hand:set_precision_mode(precision_mode, math.min(length / 20, 1))
				else
					hand:set_precision_mode(false)
				end
			end
		end
	end
end
