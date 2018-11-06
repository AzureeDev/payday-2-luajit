core:import("CoreEws")

CinematicStateCamera = CinematicStateCamera or class()
CinematicStateCamera.GAME_MULTIPLIER = 0.01

function CinematicStateCamera:init(unit)
	self._unit = unit

	self._unit:set_animation_lod(1, 1000000, 1000000, 1000000)

	self._ref_camera = self._unit:get_object(Idstring("align"))
	self._camera = World:create_camera()
	self._speed = 1
	self._anim_name = Idstring("cinematic_camera")
	self._timer = TimerManager:timer(self._anim_name) or TimerManager:make_timer(self._anim_name, TimerManager:pausable())

	self._unit:set_timer(self._timer)
	self._unit:set_animation_timer(self._timer)
	self._camera:set_near_range(10)
	self._camera:set_far_range(10000)

	self._viewport = managers.viewport:new_vp(0, 0, 1, 1, "cinematic_camera", CoreManagerBase.PRIO_WORLDCAMERA)
	self._director = self._viewport:director()
	self._shaker = self._director:shaker()
	self._camera_controller = self._director:make_camera(self._camera, Idstring("cinematic_camera"))

	self._camera_controller:set_timer(self._timer)
	self._viewport:set_camera(self._camera)
	self._director:set_camera(self._camera_controller)
	self._camera_controller:set_both(self._ref_camera)
end

function CinematicStateCamera:_set_interpolation_type(type)
	self._camera_controller:set_interpolation_type(Idstring("cam"), Idstring(type))
	self._camera_controller:set_interpolation_type(Idstring("tar"), Idstring(type))
end

CinematicStateCamera.IDS_NOSTRING = Idstring("")

function CinematicStateCamera:play_redirect(redirect_name, speed, offset_time)
	local result = self._unit:play_redirect(redirect_name, offset_time)

	if result == self.IDS_NOSTRING then
		return false
	end

	if speed then
		self._unit:anim_state_machine():set_speed(result, speed)
	end

	self._current_redirect_name = redirect_name
	self._current_state_name = result

	return result
end

function CinematicStateCamera:_get_state_length(state_name)
	local animation_set = AnimationManager:animation_set(Idstring("anims/units/cinematic/cinematic"))
	local len = 0

	for _, animation in ipairs(self._unit:anim_state_machine():config():state(state_name):animations()) do
		len = math.max(len, animation_set:animation_total_duration(animation))
	end

	return len
end

function CinematicStateCamera:set_current_state_name(state_name)
	self._current_state_name = Idstring(state_name)
	self._length = self:_get_state_length(self._current_state_name)

	self:play_state(self._current_state_name, 0, 0)

	if self._time_slider then
		CoreEws.change_slider_and_number_controller_range(self._time_slider, 0, self._length)
		CoreEws.update_slider_and_number_controller_value(self._time_slider, 0)
	end
end

function CinematicStateCamera:play_state(state_name, speed, offset_time)
	self._unit:play_state(state_name, offset_time)

	if speed then
		self:set_speed(speed)
	end
end

function CinematicStateCamera:set_mission_element(mission_element)
	self._mission_element = mission_element
end

function CinematicStateCamera:anim_clbk_done()
	local entered_empty = self._unit:anim_state_machine():is_playing(Idstring("std/empty"))

	if entered_empty and self._mission_element then
		self._mission_element:anim_clbk_done()
	end
end

function CinematicStateCamera:anim_clbk_set_fov(unit, fov, transition_t)
	self:set_fov(fov, transition_t)
end

function CinematicStateCamera:set_fov(fov, transition_t)
	self._fov_transition_data = nil

	if not transition_t then
		self._camera:set_fov(fov)

		return
	end

	self._fov_transition_data = {
		start_fov = self._camera:fov(),
		target_fov = fov,
		transition_t = transition_t,
		current_t = 0
	}
end

function CinematicStateCamera:start()
	if game_state_machine:current_state_name() ~= "editor" then
		self._old_game_state_name = game_state_machine:current_state_name()
	end

	self._unit:set_visible(false)

	if Application:editor() then
		managers.editor:layer("WorldCamera"):set_gui_visible(true, true)
	end

	game_state_machine:change_state_by_name("world_camera")
	managers.enemy:set_gfx_lod_enabled(false)

	self._playing = true

	self._viewport:set_active(true)

	local start_time = self._main_frame and self._time_slider.value or 0
	local speed = self._main_frame and self._speed_slider.value or nil

	if self._current_redirect_name then
		self:play_redirect(self._current_redirect_name, speed, start_time)
		self._timer:set_multiplier(speed)
	elseif self._current_state_name then
		self:play_state(self._current_state_name, speed, math.min(start_time, self._length))

		if speed then
			self._timer:set_multiplier(speed)
		end
	end
end

function CinematicStateCamera:pause()
	if self._current_state_name then
		self:set_speed(0)
	end
end

function CinematicStateCamera:set_speed(speed)
	self._speed = speed

	if self._current_state_name then
		self._unit:anim_state_machine():set_speed(self._current_state_name, speed)
	end
end

function CinematicStateCamera:goto(time)
	if self._current_redirect_name then
		self:play_redirect(self._current_redirect_name, 0, time)
	end

	if self._current_state_name then
		self:play_state(self._current_state_name, 0, time)
	end
end

function CinematicStateCamera:stop()
	self._viewport:set_active(false)
	managers.enemy:set_gfx_lod_enabled(true)
	TimerManager:game():set_multiplier(1)
	TimerManager:game_animation():set_multiplier(1)

	if self._old_game_state_name then
		game_state_machine:change_state_by_name(self._old_game_state_name)

		self._old_game_state_name = nil
	end

	if Application:editor() then
		self._unit:set_visible(true)
		managers.editor:layer("WorldCamera"):set_gui_visible(false, true)
	end

	self._playing = false
end

function CinematicStateCamera:create_ews()
	self:close_ews()

	self._main_frame = EWS:Frame("Cinematic", Vector3(250, 0, 0), Vector3(600, 200, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE,FULL_REPAINT_ON_RESIZE", Global.frame)
	local main_box = EWS:BoxSizer("HORIZONTAL")
	self._main_panel = EWS:Panel(self._main_frame, "", "FULL_REPAINT_ON_RESIZE")
	local main_panel_sizer = EWS:BoxSizer("VERTICAL")

	self._main_panel:set_sizer(main_panel_sizer)
	main_box:add(self._main_panel, 1, 0, "EXPAND")
	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "close_ews"), "")

	local btn_sizer = EWS:StaticBoxSizer(self._main_panel, "HORIZONTAL", "")

	main_panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local play_btn = EWS:Button(self._main_panel, "Play", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(play_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	play_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start"), nil)

	local pause_btn = EWS:Button(self._main_panel, "Pause", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(pause_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	pause_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "pause"), nil)

	local stop_btn = EWS:Button(self._main_panel, "Stop", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(stop_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	stop_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "stop"), nil)

	local slider_sizer = EWS:StaticBoxSizer(self._main_panel, "VERTICAL", "")

	main_panel_sizer:add(slider_sizer, 0, 0, "EXPAND")
	slider_sizer:add(EWS:StaticText(self._main_panel, "Time:", "", "ALIGN_LEFT"), 0, 0, "EXPAND")

	local slider_params = {
		min = 0,
		floats = 2,
		slider_ctrlr_proportions = 9,
		value = 0,
		number_ctrlr_proportions = 1,
		panel = self._main_panel,
		sizer = slider_sizer,
		max = self._length or 10
	}

	CoreEws.slider_and_number_controller(slider_params)
	slider_params.slider_ctrlr:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_slider_time"), {
		slider_params = slider_params
	})
	slider_params.slider_ctrlr:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_slider_time"), {
		slider_params = slider_params
	})
	slider_params.number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_slider_time"), {
		slider_params = slider_params
	})
	slider_params.number_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "update_slider_time"), {
		slider_params = slider_params
	})

	self._time_slider = slider_params
	local slider_sizer = EWS:StaticBoxSizer(self._main_panel, "VERTICAL", "")

	main_panel_sizer:add(slider_sizer, 0, 0, "EXPAND")
	slider_sizer:add(EWS:StaticText(self._main_panel, "Speed:", "", "ALIGN_LEFT"), 0, 0, "EXPAND")

	local slider_params = {
		min = 0,
		floats = 2,
		slider_ctrlr_proportions = 9,
		value = 1,
		number_ctrlr_proportions = 1,
		max = 10,
		panel = self._main_panel,
		sizer = slider_sizer
	}

	CoreEws.slider_and_number_controller(slider_params)
	slider_params.slider_ctrlr:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_slider_speed"), {
		slider_params = slider_params
	})
	slider_params.slider_ctrlr:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_slider_speed"), {
		slider_params = slider_params
	})
	slider_params.number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_slider_speed"), {
		slider_params = slider_params
	})
	slider_params.number_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "update_slider_speed"), {
		slider_params = slider_params
	})

	self._speed_slider = slider_params

	self._main_frame:set_sizer(main_box)
	self._main_frame:set_visible(true)
end

function CinematicStateCamera:update_slider_time(data)
	self:goto(data.slider_params.value)
end

function CinematicStateCamera:update_slider_speed(data)
	self:set_speed(data.slider_params.value)
end

function CinematicStateCamera:close_ews()
	if self._main_frame then
		self._main_frame:destroy()

		self._main_frame = nil
	end
end

function CinematicStateCamera:update(unit, t, dt)
	dt = dt * self._speed

	if not self._unit:anim_state_machine():is_playing(Idstring("std/empty")) then
		local current_time = self._unit:anim_state_machine():segment_real_time(Idstring("base"))

		if self._time_slider then
			CoreEws.change_slider_and_number_value(self._time_slider, math.min(current_time, self._length))
		end
	end

	if self._fov_transition_data then
		local lerp_value = math.bezier({
			0,
			0,
			1,
			1
		}, self._fov_transition_data.current_t)
		local fov = math.lerp(self._fov_transition_data.start_fov, self._fov_transition_data.target_fov, lerp_value)

		self._camera:set_fov(fov)

		self._fov_transition_data.current_t = self._fov_transition_data.current_t + dt / self._fov_transition_data.transition_t

		if self._fov_transition_data.current_t >= 1 then
			self._fov_transition_data = nil
		end
	end

	if not self._playing then
		-- Nothing
	end

	if self._main_frame and self._current_state_name then
		-- Nothing
	end
end

function CinematicStateCamera:set_depth_mode(depth_mode)
	self._locked_far_range = depth_mode and 5000 or nil
	local viz = depth_mode and "depth_visualization" or "deferred_lighting"

	for _, vp in ipairs(managers.viewport:viewports()) do
		vp:set_visualization_mode(viz)
	end

	local effect = depth_mode and "empty" or "default"

	for _, vp in ipairs(managers.viewport:viewports()) do
		vp:vp():set_post_processor_effect("World", Idstring("hdr_post_processor"), Idstring(effect))

		local bloom_combine_effect = Idstring(effect) == Idstring("empty") and Idstring("bloom_combine_empty") or Idstring("bloom_combine")

		vp:vp():set_post_processor_effect("World", Idstring("bloom_combine_post_processor"), bloom_combine_effect)
	end
end

function CinematicStateCamera:destroy()
	if self._playing then
		self:stop()
	end

	if self._viewport then
		self._viewport:destroy()

		self._viewport = nil
	end

	self:close_ews()
end
