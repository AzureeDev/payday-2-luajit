core:import("CoreEws")

TrailerCamera = TrailerCamera or class()
TrailerCamera.GAME_MULTIPLIER = 0.01

function TrailerCamera:init(unit)
	print("TrailerCamera:init")

	self._unit = unit
	self._ref_camera = self._unit:get_object(Idstring("a_camera"))
	self._camera = World:create_camera()

	self._camera:set_fov(self._ref_camera:fov())
	self._camera:set_near_range(self._ref_camera:near_range())
	self._camera:set_far_range(self._ref_camera:far_range())

	self._anim_name = Idstring("trailer_camera")
	self._timer = TimerManager:timer(self._anim_name) or TimerManager:make_timer(self._anim_name, TimerManager:pausable())

	self._unit:set_timer(self._timer)
	self._unit:set_animation_timer(self._timer)
	self._camera:set_near_range(10)
	self._camera:set_far_range(10000)

	self._viewport = managers.viewport:new_vp(0, 0, 1, 1, "trailercamera", CoreManagerBase.PRIO_WORLDCAMERA)
	self._director = self._viewport:director()
	self._shaker = self._director:shaker()
	self._camera_controller = self._director:make_camera(self._camera, Idstring("world_camera"))

	self._camera_controller:set_timer(self._timer)
	self._viewport:set_camera(self._camera)
	self._director:set_camera(self._camera_controller)
	self._camera_controller:set_camera(self._ref_camera:position())
	self._camera_controller:set_target(self._unit:get_object(Idstring("a_camera_target")):position())
	self:_set_actions()
end

function TrailerCamera:_set_interpolation_type(type)
	self._camera_controller:set_interpolation_type(Idstring("cam"), Idstring(type))
	self._camera_controller:set_interpolation_type(Idstring("tar"), Idstring(type))
end

function TrailerCamera:_set_actions()
	self._actions = {}

	table.insert(self._actions, {
		time = 6,
		action = TrailerCameraElementAction:new("trailer_effect2")
	})
	table.insert(self._actions, {
		time = 4,
		action = TrailerCameraElementAction:new("trailer_effect1")
	})
	table.insert(self._actions, {
		time = 3,
		action = TrailerCameraElementAction:new("trailer_effect1")
	})
	table.sort(self._actions, function (e1, e2)
		return e1.time < e2.time
	end)
	print(inspect(self._actions))
end

function TrailerCamera:start()
	if game_state_machine:current_state_name() ~= "editor" then
		self._old_game_state_name = game_state_machine:current_state_name()
	end

	game_state_machine:change_state_by_name("world_camera")
	managers.enemy:set_gfx_lod_enabled(false)

	self._playing = true
	local start_time = self._main_frame and self._time_slider.value or 0

	self._unit:anim_set_time(self._anim_name, start_time)

	local speed = self._main_frame and self._speed_slider.value or 1

	self._unit:anim_play_to(self._anim_name, self._unit:anim_length(self._anim_name), speed)
	self._viewport:set_active(true)
end

function TrailerCamera:pause()
	self._unit:anim_set_time(self._anim_name, self._unit:anim_time(self._anim_name))
	self._unit:anim_play(self._anim_name, 0)
end

function TrailerCamera:set_speed(speed)
	self._unit:anim_play_to(self._anim_name, self._unit:anim_length(self._anim_name), speed)
end

function TrailerCamera:goto(time)
	self._unit:anim_set_time(self._anim_name, time)
	self._unit:anim_play(self._anim_name, 0)
end

function TrailerCamera:stop()
	self._viewport:set_active(false)
	self._unit:anim_stop(self._anim_name)
	self._unit:anim_set_time(self._anim_name, 0)
	managers.enemy:set_gfx_lod_enabled(true)
	TimerManager:game():set_multiplier(1)
	TimerManager:game_animation():set_multiplier(1)

	if self._old_game_state_name then
		game_state_machine:change_state_by_name(self._old_game_state_name)

		self._old_game_state_name = nil
	end

	self._playing = false
end

function TrailerCamera:create_ews()
	self:close_ews()

	self._main_frame = EWS:Frame("Trailer", Vector3(250, 0, 0), Vector3(600, 200, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE,FULL_REPAINT_ON_RESIZE", Global.frame)
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
		max = self._unit:anim_length(self._anim_name)
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
		min = 0.01,
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
	print("done")
end

function TrailerCamera:update_slider_time(data)
	self:goto(data.slider_params.value)
end

function TrailerCamera:update_slider_speed(data)
	self:set_speed(data.slider_params.value)
end

function TrailerCamera:close_ews()
	if self._main_frame then
		self._main_frame:destroy()

		self._main_frame = nil
	end
end

function TrailerCamera:update(unit, t, dt)
	if self._playing then
		if self._main_frame then
			CoreEws.change_slider_and_number_value(self._time_slider, self._unit:anim_time(self._anim_name))
		end

		self._camera_controller:set_camera(self._ref_camera:position())
		self._camera_controller:set_target(self._unit:get_object(Idstring("a_camera_target")):position())
		self._camera:set_fov(self._ref_camera:fov())
		self._camera:set_near_range(self._ref_camera:near_range())
		self._camera:set_far_range(self._locked_far_range or self._ref_camera:far_range())

		if self._wait_t then
			if self._wait_t < t then
				self._wait_t = nil
			end
		elseif not self._unit:anim_is_playing(self._anim_name) then
			self._wait_t = t + 4
		end
	end
end

function TrailerCamera:set_depth_mode(depth_mode)
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

function TrailerCamera:destroy()
	if self._viewport then
		self._viewport:destroy()

		self._viewport = nil
	end

	self:close_ews()
end

TrailerCameraAction = TrailerCameraAction or class()

function TrailerCameraAction:init()
end

function TrailerCameraAction:execute()
end

TrailerCameraElementAction = TrailerCameraElementAction or class(TrailerCameraAction)

function TrailerCameraElementAction:init(name)
	self._name = name
end

function TrailerCameraElementAction:execute()
	print("TrailerCameraElementAction:execute()", self._name)
	managers.mission:debug_execute_mission_element_by_name(self._name)
end
