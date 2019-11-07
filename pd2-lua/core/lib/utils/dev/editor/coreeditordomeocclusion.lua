core:import("CoreEditorUtils")

function CoreEditor:init_create_dome_occlusion(shape, res)
	print("CoreEditor:init_create_dome_occlusion()")
	managers.editor:disable_all_post_effects(true)
	self:viewport():vp():set_post_processor_effect("World", Idstring("depth_projection"), Idstring("render_dome_occ"))

	self._aa_setting = managers.environment_controller:get_aa_setting()

	managers.environment_controller:set_aa_setting("AA_off")

	local saved_environment = managers.viewport:default_environment()
	local params = {
		res = res,
		shape = shape,
		saved_environment = saved_environment
	}

	self:_create_dome_occlusion(params)
end

function CoreEditor:_create_dome_occlusion(params)
	self._dome_occlusion_params = params

	assert(self._vp:push_ref_fov(500))
	self._vp:set_width_mul_enabled(false)
	self:_set_appwin_fixed_resolution(Vector3(self._dome_occlusion_params.res + 4, self._dome_occlusion_params.res + 4, 0))

	self._saved_camera = {
		aspect_ratio = self:camera():aspect_ratio(),
		pos = self:camera():position(),
		rot = self:camera():rotation(),
		fov = self:camera_fov(),
		near_range = self:camera():near_range(),
		far_range = self:camera():far_range()
	}

	self:camera():set_aspect_ratio(1)
	self:camera():set_width_multiplier(1)
	self:set_show_camera_info(false)
	self._layers[self._mission_layer_name]:set_enabled(false)

	self._saved_show_center = self._show_center
	self._show_center = false

	self:on_hide_helper_units({
		vis = false
	})

	self._saved_hidden_object = {}
	self._saved_hidden_units = {}

	for name, layer in pairs(self._layers) do
		for _, unit in ipairs(layer:created_units()) do
			if unit:has_material_assigned(Idstring("leveltools")) then
				self:set_unit_visible(unit, true)

				for _, obj in ipairs(unit:get_objects("*")) do
					local match = string.find(obj:name(), "s_", 1, true)

					if not match or match ~= 1 then
						obj:set_visibility(false)
						table.insert(self._saved_hidden_object, obj)
					end
				end
			elseif unit:unit_data().hide_on_projection_light then
				self:set_unit_visible(unit, false)
				table.insert(self._saved_hidden_units, unit)
			end
		end
	end

	if self._current_layer then
		self._current_layer:update_unit_settings()
	end

	local shape = self._dome_occlusion_params.shape
	local corner = shape:position()
	local w = shape:depth()
	local d = shape:width()
	local h = shape:height()
	local x = corner.x + w / 2
	local y = corner.y - d / 2
	local fov = 4
	local far_range = math.max(w, d) / 2 / math.tan(fov / 2)
	local z = corner.z + far_range

	self:set_camera_far_range(far_range + 10000)
	self:set_camera(Vector3(x, y, z), Rotation(0, -90, 0))
	self:set_camera_fov(fov)

	local deferred_processor = self:viewport():vp():get_post_processor_effect("World", Idstring("depth_projection"))

	if not deferred_processor then
		self:dome_occlusion_done()

		return
	end

	local post_dome_occ = deferred_processor:modifier(Idstring("post_dome_occ"))
	self._dome_occ_corner = corner
	self._dome_occ_size = Vector3(w, d, h)
	local dome_occ_feed = post_dome_occ:material()

	if dome_occ_feed then
		dome_occ_feed:set_variable(Idstring("dome_occ_pos"), self._dome_occ_corner)
		dome_occ_feed:set_variable(Idstring("dome_occ_size"), self._dome_occ_size)
	end

	if not self._lastdir then
		self:dome_occlusion_done()

		return
	end

	local folder_name = "cube_lights"
	local path = self._lastdir .. "\\" .. folder_name

	print(path)

	self._dome_occlusion_params.file_name = "dome_occlusion"
	self._dome_occlusion_params.output_path = path
	self._dome_occlusion_params.step = 0
	self._dome_occlusion_params.wait_frames = 5

	self:_make_dir(path)
end

function CoreEditor:_tick_generate_dome_occlusion(t, dt)
	if self._dome_occlusion_params then
		if self._dome_occlusion_params.step == 0 then
			self._dome_occlusion_params.wait_frames = self._dome_occlusion_params.wait_frames - 1

			if self._dome_occlusion_params.wait_frames > 0 then
				return
			end

			self:generate_dome_occlusion(self._dome_occlusion_params.output_path .. "\\")
		end

		self._dome_occlusion_params.step = self._dome_occlusion_params.step + 1

		if self._dome_occlusion_params.step == 2 then
			self:_convert_dome_occlusion()
		elseif self._dome_occlusion_params.step == 3 then
			self:dome_occlusion_done()
		end
	end
end

function CoreEditor:generate_dome_occlusion(path)
	local x1, y1, x2, y2 = self._camera_controller:_get_screen_size()

	Application:screenshot(path .. self._dome_occlusion_params.file_name .. ".tga", x1, y1, x2, y2)
end

function CoreEditor:_convert_dome_occlusion()
	local path = self._dome_occlusion_params.output_path .. "\\"
	local execute = managers.database:root_path() .. "aux_assets/engine/tools/spotmapgen.bat "
	execute = execute .. path .. self._dome_occlusion_params.file_name .. ".tga" .. " "
	local output_path = path .. self._dome_occlusion_params.file_name .. ".dds "
	execute = execute .. output_path .. " "

	print("execute", execute)

	self._dome_occlusion_params.output_path_file = output_path .. self._dome_occlusion_params.file_name

	os.execute(execute)
	self._camera_controller:_add_meta_data(output_path, "colormap_no_alpha_no_mips")
end

function CoreEditor:dome_occlusion_done()
	if not self._dome_occlusion_params then
		Application:error("CoreEditor:dome_occlusion_done. Generate has not been started")

		return
	end

	if self._dome_occlusion_params.saved_environment then
		managers.viewport:set_default_environment(self._dome_occlusion_params.saved_environment, nil, nil)
	end

	managers.editor:update_post_effects()
	self:viewport():vp():set_post_processor_effect("World", Idstring("deferred"), Idstring("deferred_lighting"))
	self:viewport():vp():set_post_processor_effect("World", Idstring("depth_projection"), Idstring("depth_project_empty"))
	self:_recompile(self._dome_occlusion_params.output_path)
	managers.environment_controller:set_dome_occ_params(self._dome_occ_corner, self._dome_occ_size, managers.database:entry_path(self._dome_occlusion_params.output_path_file))
	self:set_show_camera_info(true)
	self._layers[self._mission_layer_name]:set_enabled(true)

	self._show_center = self._saved_show_center

	self:on_hide_helper_units({
		vis = true
	})

	for _, obj in ipairs(self._saved_hidden_object) do
		obj:set_visibility(true)
	end

	for _, unit in ipairs(self._saved_hidden_units) do
		self:set_unit_visible(unit, true)
	end

	if self._saved_camera then
		self:set_camera(self._saved_camera.pos, self._saved_camera.rot)
		self:set_camera_fov(self._saved_camera.fov)
		self:camera():set_aspect_ratio(self._saved_camera.aspect_ratio)
		self:camera():set_near_range(self._saved_camera.near_range)
		self:camera():set_far_range(self._saved_camera.far_range)

		self._saved_camera = nil
	end

	self:_set_appwin_fixed_resolution(nil)
	self._vp:set_width_mul_enabled(true)
	assert(self._vp:pop_ref_fov())

	self._dome_occlusion_params = nil
end
