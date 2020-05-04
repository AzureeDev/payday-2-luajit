require("core/lib/managers/cutscene/CoreCutsceneCast")
require("core/lib/managers/cutscene/CoreCutsceneKeyCollection")
core:import("CoreManagerBase")

CoreCutscenePlayer = CoreCutscenePlayer or class()

mixin(CoreCutscenePlayer, get_core_or_local("CutsceneKeyCollection"))

CoreCutscenePlayer.BLACK_BAR_GUI_LAYER = 29
CoreCutscenePlayer.BLACK_BAR_TOP_GUI_NAME = "__CutscenePlayer__black_bar_top"
CoreCutscenePlayer.BLACK_BAR_BOTTOM_GUI_NAME = "__CutscenePlayer__black_bar_bottom"

function CoreCutscenePlayer:_all_keys_sorted_by_time()
	return self._owned_cutscene_keys
end

function CoreCutscenePlayer:init(cutscene, optional_shared_viewport, optional_shared_cast)
	self._cutscene = assert(cutscene, "No cutscene supplied.")
	self._viewport = optional_shared_viewport or self:_create_viewport()
	self._cast = optional_shared_cast or self:_create_cast()
	self._owned_cutscene_keys = {}
	self._time = 0

	cat_print("cutscene", string.format("[CoreCutscenePlayer] Created CutscenePlayer for \"%s\".", self:cutscene_name()))

	if not alive(self._viewport:camera()) then
		self:_create_camera()
	end

	self:_create_future_camera()
	self:_clear_workspace()

	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "_configure_viewport"))
end

function CoreCutscenePlayer:_create_future_camera()
	self._future_camera_locator = World:spawn_unit(Idstring("core/units/locator/locator"), Vector3(0, 0, 0), Rotation())
	self._future_camera = World:create_camera()

	self:_initialize_camera(self._future_camera)
	self._future_camera:link(self._future_camera_locator:get_object("locator"))
	self._future_camera:set_local_rotation(Rotation(-90, 0, 0))
	self._cast:_reparent_to_locator_unit(self._cast:_root_unit(), self._future_camera_locator)
end

function CoreCutscenePlayer:add_keys(key_collection)
	key_collection = key_collection or self._cutscene

	for _, template_key in ipairs(key_collection:_all_keys_sorted_by_time()) do
		if self:_is_driving_sound_key(template_key) then
			self:_set_driving_sound_from_key(template_key)
		else
			local cutscene_key = template_key:clone()

			cutscene_key:set_key_collection(self)
			cutscene_key:set_cast(self._cast)
			table.insert(self._owned_cutscene_keys, cutscene_key)
		end
	end
end

function CoreCutscenePlayer:_is_driving_sound_key(cutscene_key)
	return cutscene_key.ELEMENT_NAME == CoreSoundCutsceneKey.ELEMENT_NAME and cutscene_key:frame() == 0 and cutscene_key:sync_to_video()
end

function CoreCutscenePlayer:_set_driving_sound_from_key(cutscene_key)
	cat_print("cutscene", string.format("[CoreCutscenePlayer] Using sound cue \"%s/%s\" to drive the playhead.", cutscene_key:bank(), cutscene_key:cue()))

	self._driving_sound = assert(Sound:make_bank(cutscene_key:bank(), cutscene_key:cue()), string.format("Driving sound cue \"%s/%s\" not found.", cutscene_key:bank(), cutscene_key:cue()))
end

function CoreCutscenePlayer:set_timer(timer)
	self._cast:set_timer(timer)

	if alive(self._workspace) then
		self._workspace:set_timer(timer)
	end

	local camera_controller = self:_camera_controller()

	if alive(camera_controller) then
		camera_controller:set_timer(timer)
	end
end

function CoreCutscenePlayer:viewport()
	return self._viewport
end

function CoreCutscenePlayer:cutscene_name()
	return self._cutscene:name()
end

function CoreCutscenePlayer:cutscene_duration()
	return self._cutscene:duration()
end

function CoreCutscenePlayer:camera_attributes()
	local camera = self:_camera()
	local attributes = {
		aspect_ratio = camera:aspect_ratio(),
		fov = camera:fov(),
		near_range = camera:near_range(),
		far_range = camera:far_range()
	}

	if self._dof_attributes then
		for key, value in pairs(self._dof_attributes) do
			attributes[key] = value
		end
	end

	return attributes
end

function CoreCutscenePlayer:depth_of_field_attributes()
	return self._dof_attributes
end

function CoreCutscenePlayer:prime()
	if not self._primed then
		self._cast:prime(self._cutscene)

		for _, cutscene_key in dpairs(self._owned_cutscene_keys) do
			if cutscene_key:is_valid() then
				self:prime_cutscene_key(cutscene_key)
			else
				Application:error(string.format("[CoreCutscenePlayer] Invalid cutscene key in \"%s\": %s", self:cutscene_name(), cutscene_key.__tostring and cutscene_key:__tostring() or tostring(cutscene_key)))
				table.delete(self._owned_cutscene_keys, cutscene_key)
			end
		end

		self:_process_camera_cutscene_keys_between(-1, 0)

		if self:_camera_object() ~= nil then
			self:_reparent_camera()
		end

		if self._driving_sound then
			self._driving_sound:prime()
		end

		self._primed = true
	end
end

function CoreCutscenePlayer:is_primed()
	return self._primed == true
end

function CoreCutscenePlayer:_driving_sound_offset()
	if alive(self._driving_sound_instance) then
		local master_sound_instance = self:_master_driving_sound_instance(self._driving_sound_instance)

		if master_sound_instance == nil then
			return 0
		elseif not alive(master_sound_instance) or not master_sound_instance:is_playing() then
			return nil
		end

		local name, offset = master_sound_instance:offset()

		if offset < self._time then
			cat_print("cutscene", string.format("[CoreCutscenePlayer] Bad SoundInstance offset: Got %g, previous was %g.", offset, self._time))

			offset = self._time
		end

		return offset
	end

	return nil
end

function CoreCutscenePlayer:_master_driving_sound_instance(sound_instance)
	self._driving_sound_instance_map = self._driving_sound_instance_map or {}
	local master_instance = self._driving_sound_instance_map[sound_instance]

	if master_instance == nil then
		if sound_instance.playing_instances then
			master_instance = sound_instance:playing_instances()[1]
		else
			master_instance = sound_instance
		end

		self._driving_sound_instance_map[sound_instance] = master_instance
	end

	return master_instance
end

function CoreCutscenePlayer:is_presentable()
	return self._cast:is_ready(self._cutscene) and (self:_driving_sound_offset() or 1) > 0
end

function CoreCutscenePlayer:is_viewport_enabled()
	return managers.viewport and self._viewport and self._viewport:active()
end

function CoreCutscenePlayer:unload()
	self:stop()

	for key in self:keys_between(math.huge, -math.huge) do
		key:unload(self)
	end

	if self._owned_cast then
		self._owned_cast:unload()
	end
end

function CoreCutscenePlayer:destroy()
	cat_print("cutscene", string.format("[CoreCutscenePlayer] Destroying CutscenePlayer for \"%s\".", self:cutscene_name()))
	self:set_viewport_enabled(false)

	for gui_name, _ in pairs(self._owned_gui_objects or {}) do
		self:invoke_callback_in_gui(gui_name, "on_cutscene_player_destroyed", self)
	end

	self._owned_gui_objects = nil

	self:unload()

	if self._listener_id and managers.listener then
		managers.listener:remove_listener(self._listener_id)
	end

	self._listener_id = nil

	if self._resolution_changed_callback_id and managers.viewport then
		managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)
	end

	self._resolution_changed_callback_id = nil

	if self._owned_camera_controller then
		self._viewport:director():release_camera()
		assert(self._viewport:director():camera() == nil)
	end

	if alive(self._workspace) then
		Overlay:newgui():destroy_workspace(self._workspace)
	end

	self._workspace = nil

	if self._owned_viewport and self._owned_viewport:alive() then
		self._owned_viewport:destroy()
	end

	self._owned_viewport = nil

	if alive(self._owned_camera) then
		World:delete_camera(self._owned_camera)
	end

	self._owned_camera = nil

	if alive(self._future_camera) then
		World:delete_camera(self._future_camera)
	end

	self._future_camera = nil

	if alive(self._future_camera_locator) then
		World:delete_unit(self._future_camera_locator)
	end

	self._future_camera_locator = nil
end

function CoreCutscenePlayer:update(time, delta_time)
	local done = false

	if self:is_playing() then
		if alive(self._driving_sound_instance) then
			self._driving_sound_instance:unpause()
		elseif self._driving_sound then
			self._driving_sound_instance = self._driving_sound:play("offset", self._time)
		end

		if self:is_presentable() then
			local offset = self:_driving_sound_offset() or self._time + delta_time
			done = self:seek(offset, self._time == offset) == false
		end
	elseif alive(self._driving_sound_instance) then
		self._driving_sound_instance:pause()
	end

	if done then
		self:stop()
	elseif self:is_viewport_enabled() then
		self:refresh()
	end

	return not done
end

function CoreCutscenePlayer:refresh()
	if self:_camera_has_cut() and managers.environment then
		managers.environment:clear_luminance()
	end

	self:_update_future_camera()
end

function CoreCutscenePlayer:evaluate_current_frame()
	self._last_evaluated_time = self._last_evaluated_time or -1

	self:_set_visible(true)
	self:_process_discontinuity_cutscene_keys_between(self._last_evaluated_time, self._time)
	self:_evaluate_animations()
	self:_resume_discontinuity()
	self:_process_camera_cutscene_keys_between(self._last_evaluated_time, self._time)
	self:_reparent_camera()
	self:_process_non_camera_cutscene_keys_between(self._last_evaluated_time, self._time)

	self._last_evaluated_time = self._time
end

function CoreCutscenePlayer:preroll_cutscene_keys()
	if self._time > 0 then
		return
	end

	for _, cutscene_key in ipairs(self:_all_keys_sorted_by_time()) do
		if cutscene_key:frame() > 0 then
			break
		end

		if cutscene_key.preroll then
			cutscene_key:preroll(self)
		end
	end
end

function CoreCutscenePlayer:is_playing()
	return self._playing or false
end

function CoreCutscenePlayer:play()
	self._playing = true

	for _, cutscene_key in ipairs(self:_all_keys_sorted_by_time()) do
		if cutscene_key.resume then
			cutscene_key:resume(self)
		end
	end
end

function CoreCutscenePlayer:pause()
	self._playing = nil

	for _, cutscene_key in ipairs(self:_all_keys_sorted_by_time()) do
		if cutscene_key.pause then
			cutscene_key:pause(self)
		end
	end
end

function CoreCutscenePlayer:stop()
	self._playing = nil
	self._driving_sound_instance = nil

	self:_set_visible(false)
end

function CoreCutscenePlayer:skip_to_end()
	for key in self:keys_between(self._time, math.huge) do
		if key.skip then
			self:skip_cutscene_key(key)
		end
	end

	if alive(self._driving_sound_instance) then
		self._driving_sound_instance:stop()
	end

	self._driving_sound_instance = nil
	self._time = self:cutscene_duration()
end

function CoreCutscenePlayer:seek(time, skip_evaluation)
	self._time = math.min(math.max(0, time), self:cutscene_duration())

	if not skip_evaluation then
		self:evaluate_current_frame()
	end

	return self._time == time
end

function CoreCutscenePlayer:distance_from_camera(unit_name, object_name)
	local object = self:_actor_object(unit_name, object_name)
	local distance = object and self:_camera():world_to_screen(object:position()).z

	return distance
end

function CoreCutscenePlayer:set_camera(camera)
	assert(camera == nil or string.begins(camera, "camera"))

	self._camera_name = camera
end

function CoreCutscenePlayer:set_camera_attribute(attribute_name, value)
	local camera = self:_camera()
	local func = assert(camera["set_" .. attribute_name], "Invalid camera attribute.")

	func(camera, value)
	func(self._future_camera, value)
end

function CoreCutscenePlayer:set_camera_depth_of_field(near, far)
	local range = far - near
	self._dof_attributes = self._dof_attributes or {}
	self._dof_attributes.near_focus_distance_min = math.max(1e-06, near - range * 0.33)
	self._dof_attributes.near_focus_distance_max = math.max(1e-06, near)
	self._dof_attributes.far_focus_distance_min = far
	self._dof_attributes.far_focus_distance_max = far + range * 0.67
end

function CoreCutscenePlayer:play_camera_shake(shake_name, amplitude, frequency, offset)
	local shake_id = self._viewport:director():shaker():play(shake_name, amplitude, frequency, offset)

	return function ()
		self._viewport:director():shaker():stop_immediately(shake_id)
	end
end

function CoreCutscenePlayer:has_gui(gui_name)
	return self._owned_gui_objects ~= nil and self._owned_gui_objects[gui_name] ~= nil
end

function CoreCutscenePlayer:load_gui(gui_name)
	local preload = true

	Overlay:newgui():preload(gui_name)
	self:_gui_panel(gui_name, preload)
	self:set_gui_visible(gui_name, false)
end

function CoreCutscenePlayer:set_gui_visible(gui_name, visible)
	local panel = self:_gui_panel(gui_name)

	if not visible == panel:visible() then
		self:invoke_callback_in_gui(gui_name, "on_cutscene_player_set_visible", visible, self)
		panel:set_visible(visible)
	end
end

function CoreCutscenePlayer:invoke_callback_in_gui(gui_name, function_name, ...)
	local gui_object = self._owned_gui_objects and self._owned_gui_objects[gui_name]

	if alive(gui_object) and gui_object:has_script() then
		local script = gui_object:script()
		local callback_func = rawget(script, function_name)

		if type(callback_func) == "function" then
			callback_func(...)
		end
	end
end

function CoreCutscenePlayer:_gui_panel(gui_name, preloading)
	local panel = self._workspace:panel():child(gui_name)

	if panel == nil then
		if not preloading then
			Application:error("[CoreCutscenePlayer] The gui \"" .. gui_name .. "\" was not preloaded, causing a performance spike.")
		end

		self._owned_gui_objects = self._owned_gui_objects or {}
		local viewport_rect = self:_viewport_rect()
		panel = self._workspace:panel():panel({
			halign = "grow",
			visible = false,
			valign = "grow",
			name = gui_name,
			x = viewport_rect.px,
			y = viewport_rect.py,
			width = viewport_rect.pw,
			height = viewport_rect.ph
		})
		local gui_object = panel:gui(gui_name)
		self._owned_gui_objects[gui_name] = gui_object
	end

	return panel
end

function CoreCutscenePlayer:set_viewport_enabled(enabled)
	local is_enabled = self._viewport:active()

	if enabled ~= is_enabled then
		if enabled then
			self._viewport:set_active(true)
		else
			self._viewport:set_active(false)
		end

		self:_set_listener_enabled(enabled)
		self:_set_depth_of_field_enabled(enabled)
		self._viewport:set_width_mul_enabled(not enabled)

		local black_bars_enabled = self._widescreen and enabled

		self._workspace:panel():child(self.BLACK_BAR_TOP_GUI_NAME):set_visible(black_bars_enabled)
		self._workspace:panel():child(self.BLACK_BAR_BOTTOM_GUI_NAME):set_visible(black_bars_enabled)
	end
end

function CoreCutscenePlayer:set_widescreen(enabled)
	self._widescreen = enabled or nil

	self:_configure_viewport()
end

function CoreCutscenePlayer:set_key_handler(delegate)
	self._key_handler = delegate
end

function CoreCutscenePlayer:prime_cutscene_key(key, cast)
	local delegate = self._key_handler

	if delegate and delegate.prime_cutscene_key then
		return delegate:prime_cutscene_key(self, key, cast)
	else
		return key:prime(self)
	end
end

function CoreCutscenePlayer:evaluate_cutscene_key(key, time, last_evaluated_time)
	local delegate = self._key_handler

	if delegate and delegate.evaluate_cutscene_key then
		return delegate:evaluate_cutscene_key(self, key, time, last_evaluated_time)
	else
		return key:play(self, false, false)
	end
end

function CoreCutscenePlayer:revert_cutscene_key(key, time, last_evaluated_time)
	local delegate = self._key_handler

	if delegate and delegate.revert_cutscene_key then
		return delegate:revert_cutscene_key(self, key, time, last_evaluated_time)
	else
		return key:play(self, true, false)
	end
end

function CoreCutscenePlayer:update_cutscene_key(key, time, last_evaluated_time)
	local delegate = self._key_handler

	if delegate and delegate.update_cutscene_key then
		return delegate:update_cutscene_key(self, key, time, last_evaluated_time)
	else
		return key:update(self, time)
	end
end

function CoreCutscenePlayer:skip_cutscene_key(key)
	local delegate = self._key_handler

	if delegate and delegate.skip_cutscene_key then
		return delegate:skip_cutscene_key(self, key)
	else
		return key:skip(self)
	end
end

function CoreCutscenePlayer:time_in_relation_to_cutscene_key(key)
	local delegate = self._key_handler

	if delegate and delegate.time_in_relation_to_cutscene_key then
		return delegate:time_in_relation_to_cutscene_key(key)
	else
		return self._time - key:time()
	end
end

function CoreCutscenePlayer:_set_visible(visible)
	self._cast:set_cutscene_visible(self._cutscene, visible)
end

function CoreCutscenePlayer:_set_listener_enabled(enabled)
	if enabled then
		if not self._listener_activation_id then
			self._listener_activation_id = managers.listener:activate_set("main", "cutscene")
		end
	else
		if self._listener_activation_id then
			managers.listener:deactivate_set(self._listener_activation_id)
		end

		self._listener_activation_id = nil
	end
end

function CoreCutscenePlayer:_set_depth_of_field_enabled(enabled)
	if enabled then
		managers.environment:disable_dof()
	else
		managers.environment:enable_dof()
		managers.environment:needs_update()
	end
end

function CoreCutscenePlayer:_viewport_rect()
	return self._widescreen and self:_wide_viewport_rect() or self:_full_viewport_rect()
end

function CoreCutscenePlayer:_full_viewport_rect()
	local resolution = RenderSettings.resolution

	return {
		px = 0,
		py = 0,
		h = 1,
		y = 0,
		w = 1,
		x = 0,
		pw = resolution.x,
		ph = resolution.y
	}
end

function CoreCutscenePlayer:_wide_viewport_rect()
	local resolution = RenderSettings.resolution
	local resolution_aspect = 1 / managers.viewport:aspect_ratio()
	local cutscene_aspect = 0.5625
	local viewport_width = math.min(resolution_aspect / cutscene_aspect, 1)
	local viewport_height = 1 / resolution_aspect * cutscene_aspect * viewport_width
	local viewport_x = (1 - viewport_width) / 2
	local viewport_y = (1 - viewport_height) / 2
	local rect = {
		x = viewport_x,
		y = viewport_y,
		w = viewport_width,
		h = viewport_height
	}
	rect.px = rect.x * resolution.x
	rect.py = rect.y * resolution.y
	rect.pw = rect.w * resolution.x
	rect.ph = rect.h * resolution.y

	return rect
end

function CoreCutscenePlayer:_camera()
	return self._viewport:camera() or self:_create_camera()
end

function CoreCutscenePlayer:_camera_controller()
	local controller = self._viewport:director():camera()

	return controller or self:_create_camera_controller()
end

function CoreCutscenePlayer:_camera_object()
	return self._camera_name and self:_actor_object(self._camera_name, "locator")
end

function CoreCutscenePlayer:_actor_object(unit_name, object_name)
	local unit = self._cast:actor_unit(unit_name, self._cutscene)

	if unit == nil and managers.cutscene then
		unit = managers.cutscene:cutscene_actors_in_world()[unit_name]
	end

	return unit and unit:get_object(object_name)
end

function CoreCutscenePlayer:_clear_workspace()
	if alive(self._workspace) then
		Overlay:newgui():destroy_workspace(self._workspace)
	end

	local resolution = RenderSettings.resolution
	self._workspace = Overlay:newgui():create_scaled_screen_workspace(resolution.x, resolution.y, 0, 0, resolution.x)

	self._workspace:set_timer(managers.cutscene:timer())
	self._workspace:panel():rect({
		visible = self._widescreen,
		layer = self.BLACK_BAR_GUI_LAYER,
		name = self.BLACK_BAR_TOP_GUI_NAME,
		color = Color.black
	})
	self._workspace:panel():rect({
		visible = self._widescreen,
		layer = self.BLACK_BAR_GUI_LAYER,
		name = self.BLACK_BAR_BOTTOM_GUI_NAME,
		color = Color.black
	})
	self._workspace:show()
	self:_configure_viewport()
end

function CoreCutscenePlayer:_create_viewport()
	assert(self._owned_viewport == nil)

	self._owned_viewport = managers.viewport:new_vp(0, 0, 1, 1, "cutscene", CoreManagerBase.PRIO_CUTSCENE)

	return self._owned_viewport
end

function CoreCutscenePlayer:_configure_viewport()
	self:set_camera_attribute("aspect_ratio", managers.viewport:aspect_ratio())

	if alive(self._workspace) then
		local resolution = RenderSettings.resolution

		self._workspace:set_screen(resolution.x, resolution.y, 0, 0, resolution.x)

		local viewport_rect = self:_viewport_rect()
		local black_bars_enabled = self._widescreen and self:is_viewport_enabled()

		self._workspace:panel():child(self.BLACK_BAR_TOP_GUI_NAME):configure({
			y = 0,
			x = 0,
			visible = black_bars_enabled,
			width = viewport_rect.pw,
			height = viewport_rect.py
		})
		self._workspace:panel():child(self.BLACK_BAR_BOTTOM_GUI_NAME):configure({
			x = 0,
			visible = black_bars_enabled,
			y = resolution.y - viewport_rect.py,
			width = viewport_rect.pw,
			height = viewport_rect.py
		})

		if self._owned_gui_objects then
			for gui_name, _ in pairs(table.map_copy(self._owned_gui_objects)) do
				self:invoke_callback_in_gui(gui_name, "on_cutscene_player_set_visible", false, self)
				self:invoke_callback_in_gui(gui_name, "on_cutscene_player_destroyed", self)

				local panel = self._workspace:panel():child(gui_name)

				panel:clear()
				panel:configure({
					x = viewport_rect.px,
					y = viewport_rect.py,
					width = viewport_rect.pw,
					height = viewport_rect.ph
				})

				self._owned_gui_objects[gui_name] = panel:gui(gui_name)
			end
		end
	end
end

function CoreCutscenePlayer:_create_camera()
	assert(self._owned_camera == nil)

	self._owned_camera = World:create_camera()

	self:_initialize_camera(self._owned_camera)
	self._viewport:set_camera(self._owned_camera)

	return self._owned_camera
end

function CoreCutscenePlayer:_initialize_camera(camera)
	camera:set_fov(CoreZoomCameraCutsceneKey.DEFAULT_CAMERA_FOV)
	camera:set_near_range(7.5)
	camera:set_far_range(50000)
	camera:set_width_multiplier(1)
end

function CoreCutscenePlayer:_create_camera_controller()
	assert(self._owned_camera_controller == nil)

	self._owned_camera_controller = self._viewport:director():make_camera(self:_camera(), "cutscene_camera")

	self._owned_camera_controller:set_timer(managers.cutscene:timer())
	self._viewport:director():set_camera(self._owned_camera_controller)

	return self._owned_camera_controller
end

function CoreCutscenePlayer:_create_cast()
	assert(self._owned_cast == nil)

	self._owned_cast = core_or_local("CutsceneCast")

	return self._owned_cast
end

function CoreCutscenePlayer:_evaluate_animations()
	self._cast:evaluate_cutscene_at_time(self._cutscene, self._time)
end

function CoreCutscenePlayer:_notify_discontinuity()
	for unit_name, _ in pairs(self._cutscene:controlled_unit_types()) do
		local unit = self._cast:actor_unit(unit_name, self._cutscene)

		for index = 0, unit:num_bodies() - 1 do
			local body = unit:body(index)

			if body:dynamic() and body:enabled() then
				body:set_enabled(false)

				self._disabled_bodies = self._disabled_bodies or {}

				table.insert(self._disabled_bodies, body)
			end
		end
	end
end

function CoreCutscenePlayer:_resume_discontinuity()
	if self._disabled_bodies then
		for _, body in ipairs(self._disabled_bodies) do
			body:enable_with_no_velocity()
		end

		self._disabled_bodies = nil
	end
end

function CoreCutscenePlayer:_process_discontinuity_cutscene_keys_between(start_time, end_time)
	for key in self:keys_between(start_time, end_time, CoreDiscontinuityCutsceneKey.ELEMENT_NAME) do
		self:evaluate_cutscene_key(key, end_time, start_time)
	end
end

function CoreCutscenePlayer:_process_camera_cutscene_keys_between(start_time, end_time)
	for key in self:keys_between(start_time, end_time, CoreChangeCameraCutsceneKey.ELEMENT_NAME) do
		if start_time < end_time then
			self:evaluate_cutscene_key(key, end_time, start_time)
		else
			self:revert_cutscene_key(key, end_time, start_time)
		end
	end

	for key in self:keys_to_update(end_time, CoreChangeCameraCutsceneKey.ELEMENT_NAME) do
		self:update_cutscene_key(key, end_time - key:time(), math.max(0, start_time - key:time()))
	end
end

function CoreCutscenePlayer:_process_non_camera_cutscene_keys_between(start_time, end_time)
	for key in self:keys_between(start_time, end_time) do
		if key.ELEMENT_NAME ~= CoreChangeCameraCutsceneKey.ELEMENT_NAME and key.ELEMENT_NAME ~= CoreDiscontinuityCutsceneKey.ELEMENT_NAME then
			if start_time < end_time then
				self:evaluate_cutscene_key(key, end_time, start_time)
			else
				self:revert_cutscene_key(key, end_time, start_time)
			end
		end
	end

	for key in self:keys_to_update(end_time) do
		if key.ELEMENT_NAME ~= CoreChangeCameraCutsceneKey.ELEMENT_NAME and key.ELEMENT_NAME ~= CoreDiscontinuityCutsceneKey.ELEMENT_NAME then
			self:update_cutscene_key(key, end_time - key:time(), math.max(0, start_time - key:time()))
		end
	end
end

function CoreCutscenePlayer:_reparent_camera()
	local camera_object = self._camera_name and assert(self:_camera_object(), string.format("Camera \"%s\" not found in cutscene \"%s\".", self._camera_name, self:cutscene_name()))

	if camera_object ~= nil and camera_object ~= self:_camera_controller():get_camera() then
		self:_camera_controller():set_both(camera_object)

		if self._listener_id then
			managers.listener:set_listener(self._listener_id, camera_object)
		else
			self._listener_id = managers.listener:add_listener("cutscene", camera_object)
		end
	end
end

function CoreCutscenePlayer:_update_future_camera()
	if self._cutscene:is_optimized() then
		local position, rotation = self._cast:evaluate_object_at_time(self._cutscene, "camera", "locator", self._time + 0.16666666666666666)

		self._future_camera_locator:warp_to(rotation, position)
		World:effect_manager():add_camera(self._future_camera)
		World:lod_viewers():add_viewer(self._future_camera)
	end
end

function CoreCutscenePlayer:_camera_has_cut()
	self._last_frame_camera_position = self._last_frame_camera_position or Vector3(0, 0, 0)
	self._last_frame_camera_rotation = self._last_frame_camera_rotation or Rotation()
	local camera = self:_camera()
	local camera_position = camera:position()
	local camera_rotation = camera:rotation()
	local position_difference = self._last_frame_camera_position - camera_position
	local rotation_difference = Rotation:rotation_difference(self._last_frame_camera_rotation, camera_rotation)
	local position_threshold_reached = position_difference:length() > 50
	local rotation_threshold_reached = rotation_difference:yaw() > 5 or rotation_difference:pitch() > 5 or rotation_difference:roll() > 5
	self._last_frame_camera_position = camera_position
	self._last_frame_camera_rotation = camera_rotation

	return position_threshold_reached or rotation_threshold_reached
end
