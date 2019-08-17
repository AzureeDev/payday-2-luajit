require("core/lib/managers/cutscene/CoreCutscene")
require("core/lib/managers/cutscene/CoreCutsceneKeys")
require("core/lib/managers/cutscene/CoreCutsceneCast")
require("core/lib/managers/cutscene/CoreCutscenePlayer")
require("core/lib/managers/cutscene/CoreCutsceneActorDatabase")

CoreCutsceneManager = CoreCutsceneManager or mixin(class(), BasicEventHandling)

function CoreCutsceneManager:cutscene_actor_unit_type(original_unit_type)
	return Global.__CutsceneManager__replaced_actor_unit_types and Global.__CutsceneManager__replaced_actor_unit_types[original_unit_type] or original_unit_type
end

function CoreCutsceneManager:replace_cutscene_actor_unit_type(original_unit_type, replacement_unit_type)
	assert(DB:has("unit", original_unit_type), string.format("Unrecognized Unit \"%s\".", original_unit_type:t()))
	assert(replacement_unit_type == nil or DB:has("unit", replacement_unit_type), string.format("Unrecognized Unit \"%s\".", (replacement_unit_type or ""):t()))

	Global.__CutsceneManager__replaced_actor_unit_types = Global.__CutsceneManager__replaced_actor_unit_types or {}

	if replacement_unit_type then
		cat_print("cutscene", string.format("[CoreCutsceneManager] Replacing all \"%s\" actors with instances of \"%s\".", original_unit_type, replacement_unit_type))
	elseif Global.__CutsceneManager__replaced_actor_unit_types[original_unit_type] then
		cat_print("cutscene", string.format("[CoreCutsceneManager] Undoing replacement of all \"%s\" actors.", original_unit_type))
	end

	Global.__CutsceneManager__replaced_actor_unit_types[original_unit_type] = replacement_unit_type
end

function CoreCutsceneManager:init()
	managers.listener:add_set("cutscene", {
		"cutscene"
	})

	self._timer = TimerManager:game_animation()
	self._actor_database = core_or_local("CutsceneActorDatabase")
	self._input_controller = managers.controller:create_controller()
	self._gui_workspace = self:_create_gui_workspace()
	self._video_workspace = self:_create_video_workspace()
end

function CoreCutsceneManager:post_init()
	self:_prime_cutscenes_in_world()
end

function CoreCutsceneManager:destroy()
	if self._player then
		self._player:destroy()

		self._player = nil
	end

	self:_destroy_units_with_cutscene_data_extension()

	if alive(self._video_workspace) then
		Overlay:newgui():destroy_workspace(self._video_workspace)
	end

	self._video_workspace = nil

	if alive(self._gui_workspace) then
		Overlay:newgui():destroy_workspace(self._gui_workspace)
	end

	self._gui_workspace = nil

	if self._input_controller then
		self._input_controller:destroy()

		self._input_controller = nil
	end

	managers.listener:remove_set("cutscene")
end

function CoreCutsceneManager:timer()
	return self._timer
end

function CoreCutsceneManager:set_timer(timer)
	self._timer = assert(timer, "Must supply a timer.")

	if self._player then
		self._player:set_timer(timer)
	end

	if self:gui_workspace() then
		self:gui_workspace():set_timer(self._timer)
	end

	if self:video_workspace() then
		self:video_workspace():set_timer(self._timer)
	end
end

function CoreCutsceneManager:register_unit_with_cutscene_data_extension(unit)
	self._units_with_cutscene_data_extension = self._units_with_cutscene_data_extension or {}

	table.insert(self._units_with_cutscene_data_extension, unit)
end

function CoreCutsceneManager:unregister_unit_with_cutscene_data_extension(unit)
	if self._units_with_cutscene_data_extension then
		table.delete(self._units_with_cutscene_data_extension, unit)

		if #self._units_with_cutscene_data_extension == 0 then
			self._units_with_cutscene_data_extension = nil
		end
	end
end

function CoreCutsceneManager:_prime_cutscenes_in_world()
	for _, unit in ipairs(self._units_with_cutscene_data_extension or {}) do
		if alive(unit) then
			local player = unit:cutscene_data():cutscene_player()

			cat_print("cutscene", string.format("[CoreCutsceneManager] Priming in-world cutscene \"%s\".", player:cutscene_name()))
			player:prime()
		end
	end
end

function CoreCutsceneManager:_destroy_units_with_cutscene_data_extension()
	local units_to_destroy = table.list_copy(self._units_with_cutscene_data_extension or {})

	for _, unit in ipairs(units_to_destroy) do
		self:unregister_unit_with_cutscene_data_extension(unit)

		if alive(unit) then
			cat_print("cutscene", string.format("[CoreCutsceneManager] Destroying Unit with CutsceneData extension \"%s\".", unit:name()))
			World:delete_unit(unit)
		end
	end

	assert(self._units_with_cutscene_data_extension == nil, "Not all units with the CutsceneData extension were destroyed.")
end

function CoreCutsceneManager:register_cutscene_actor(unit)
	assert(alive(unit), "Zombie unit registered as cutscene actor.")

	local actor_name = unit.unit_data and unit:unit_data().cutscene_actor

	assert(actor_name and actor_name ~= "", "Unnamed unit registered as cutscene actor.")

	local existing_unit = self:cutscene_actors_in_world()[actor_name]

	if existing_unit ~= nil then
		return existing_unit == unit
	end

	self:actor_database():append_unit_info(unit)

	self._cutscene_actors = self._cutscene_actors or {}
	self._cutscene_actors[actor_name] = unit

	return true
end

function CoreCutsceneManager:unregister_cutscene_actor(unit)
	assert(alive(unit), "Zombie unit unregistered as cutscene actor.")

	local actor_name = unit.unit_data and unit:unit_data().cutscene_actor

	assert(actor_name and actor_name ~= "", "Unnamed unit unregistered as cutscene actor.")

	local existing_unit = self:cutscene_actors_in_world()[actor_name]

	if existing_unit == nil then
		return false
	end

	self._cutscene_actors[actor_name] = nil

	if table.empty(self._cutscene_actors) then
		self._cutscene_actors = nil
	end

	return true
end

function CoreCutsceneManager:cutscene_actors_in_world()
	if self._cutscene_actors == nil then
		return {}
	end

	local dead_units = table.collect(self._cutscene_actors, function (unit)
		return not alive(unit) or nil
	end)

	for dead_unit_name, _ in pairs(dead_units) do
		self._cutscene_actors[dead_unit_name] = nil
	end

	return self._cutscene_actors
end

function CoreCutsceneManager:actor_database()
	return self._actor_database
end

function CoreCutsceneManager:debug_next_exec(scene_name)
	self:delay_cutscene_debug()

	Global.debug_cutscene = scene_name
end

function CoreCutsceneManager:delay_cutscene_debug()
	self._delay_cutscene_debug = true
end

function CoreCutsceneManager:start_delayed_cutscene()
	local debug_scene = Global.debug_cutscene or arg_value("-debugcs")

	if not self._delay_cutscene_debug and debug_scene then
		self._stop_playback = nil
		self._disable_events = true

		self:_cleanup()

		self._disable_events = nil

		managers.cutscene:play_cutscene(debug_scene)

		self._manager_locked = true
		Global.debug_cutscene = nil

		self:connect("EVT_PLAYBACK_FINISHED", function ()
			managers.cutscene._manager_locked = nil
		end)
	end
end

function CoreCutsceneManager:update()
	return

	local time = self._timer:time()
	local delta_time = self._timer:delta_time()

	if self._stop_playback then
		self:_cleanup()

		self._stop_playback = nil
		self._disable_events = nil
	else
		if self._player then
			if not self._player:is_primed() then
				self._player:prime()
			end

			if self._start_playback and not self:is_paused() then
				self._player:play()

				self._start_playback = nil
			end

			if self._player:is_presentable() and not self._player:is_viewport_enabled() then
				self._player:set_viewport_enabled(true)
				self:set_gui_visible(true)
				self:_on_playback_started(self._player:cutscene_name())
				self:_send_event("EVT_PLAYBACK_STARTED", self._player:cutscene_name())
			end
		end

		local just_finished_playing_in_game_cutscene = self._player and self._player:update(time, delta_time) == false and self:_video() == nil
		local just_finished_playing_video = self:_video() ~= nil and self:_video():loop_count() > 0

		if just_finished_playing_in_game_cutscene or just_finished_playing_video then
			self:_cleanup()
		end
	end
end

function CoreCutsceneManager:paused_update()
	self:update()
end

function CoreCutsceneManager:play_overlay_effect(effect_data)
	self:stop_overlay_effect()

	effect_data.play_paused = true
	effect_data.timer = self:timer()
	self.__overlay_effect_id = managers.overlay_effect:play_effect(effect_data)
end

function CoreCutsceneManager:stop_overlay_effect(fade_out)
	if self.__overlay_effect_id then
		assert(fade_out == nil or type(fade_out) == "boolean")
		managers.overlay_effect[fade_out and "fade_out_effect" or "stop_effect"](managers.overlay_effect, self.__overlay_effect_id)

		self.__overlay_effect_id = nil
	end
end

function CoreCutsceneManager:_create_gui_workspace()
	return nil
end

function CoreCutsceneManager:_create_video_workspace()
	local res = RenderSettings.resolution
	local workspace = Overlay:newgui():create_scaled_screen_workspace(res.x, res.x / managers.viewport:aspect_ratio(), 0, 0, res.x, res.y)

	workspace:set_timer(self._timer)

	return workspace
end

function CoreCutsceneManager:input_controller()
	return self._input_controller
end

function CoreCutsceneManager:gui_workspace()
	return self._gui_workspace
end

function CoreCutsceneManager:video_workspace()
	return self._video_workspace
end

function CoreCutsceneManager:_video()
	local panel = self:video_workspace():panel()

	return panel:num_children() > 1 and panel:child(1) or nil
end

function CoreCutsceneManager:set_gui_visible(visible)
	local gui_workspace = self:gui_workspace() or responder(visible)

	if gui_workspace:visible() ~= visible then
		gui_workspace[visible and "show" or "hide"](gui_workspace)
	end

	local input_controller = self:input_controller()

	input_controller[visible and "enable" or "disable"](input_controller)
end

function CoreCutsceneManager:get_cutscene_names()
	return managers.database:list_entries_of_type("cutscene")
end

function CoreCutsceneManager:prime(name, time)
	time = time or 0
	local cutscene = self:get_cutscene(name)

	if self._player == nil then
		self._player = self:_player_for_cutscene(cutscene)
	elseif self._player:cutscene_name() ~= name then
		self:_cleanup(true)

		self._player = self:_player_for_cutscene(cutscene)
	end

	self._player:seek(time, true)
end

function CoreCutsceneManager:_player_for_cutscene(cutscene)
	local orientation_unit = cutscene:find_spawned_orientation_unit()
	local cutscene_data = orientation_unit and orientation_unit.cutscene_data and orientation_unit:cutscene_data()

	if cutscene_data then
		return cutscene_data:cutscene_player()
	else
		local player = core_or_local("CutscenePlayer", cutscene)

		player:add_keys()

		return player
	end
end

function CoreCutsceneManager:play_cutscene(name)
	if not self._manager_locked then
		self:prime(name)
		self:play()
	end
end

function CoreCutsceneManager:play()
	if self._player ~= nil and not self._player:is_playing() then
		if not self._is_overriding_user_music then
			managers.music:override_user_music(true)

			self._is_overriding_user_music = true
		end

		self._player:preroll_cutscene_keys()

		self._start_playback = true
	end
end

function CoreCutsceneManager:stop(disable_events)
	self._start_playback = nil
	self._stop_playback = true
	self._paused = nil
	self._disable_events = disable_events
end

function CoreCutsceneManager:skip()
	if self._player then
		self._player:skip_to_end()
	end

	self:stop(false)
end

function CoreCutsceneManager:_cleanup(called_from_prime)
	if self._is_overriding_user_music then
		managers.music:override_user_music(false)

		self._is_overriding_user_music = nil
	end

	local playing_cutscene_name = nil

	if self._player then
		if called_from_prime then
			self._player:skip_to_end()
		end

		playing_cutscene_name = self._player:cutscene_name()

		self._player:destroy()

		self._player = nil
	end

	if not called_from_prime then
		self:set_gui_visible(false)
	end

	if self:_video() then
		self:_video():pause()
		self:video_workspace():panel():clear()
	end

	if playing_cutscene_name and not self._disable_events then
		self:_send_event("EVT_PLAYBACK_FINISHED", playing_cutscene_name)
		self:_on_playback_finished(playing_cutscene_name)
	end
end

function CoreCutsceneManager:pause()
	self._paused = true

	if self:is_playing() then
		if self._is_overriding_user_music then
			managers.music:override_user_music(false)

			self._is_overriding_user_music = nil
		end

		self._player:pause()
		self:_send_event("EVT_PLAYBACK_PAUSED", self._player:cutscene_name())
	end
end

function CoreCutsceneManager:resume()
	if self:is_paused() then
		self._paused = nil

		self:play()
	end
end

function CoreCutsceneManager:evaluate_at_time(name, time)
	self:prime(name, time)
	self._player:evaluate_current_frame()
end

function CoreCutsceneManager:evaluate_at_frame(name, frame)
	self:evaluate_at_time(name, frame / self:get_cutscene(name):frames_per_second())
end

function CoreCutsceneManager:is_playing_cutscene(name)
	return self:is_playing() and self._player:cutscene_name() == name
end

function CoreCutsceneManager:is_playing()
	return self._player ~= nil and self._player:is_playing() or self:_video() ~= nil
end

function CoreCutsceneManager:is_paused()
	return self._paused ~= nil
end

function CoreCutsceneManager:add_playing_changed_callback(object, func_or_name)
	local func = type(func_or_name) == "string" and callback(object, object, func_or_name) or func_or_name

	self:connect("EVT_PLAYBACK_STARTED", func, true)
	self:connect("EVT_PLAYBACK_FINISHED", func, false)
end

function CoreCutsceneManager:get_cutscene(name)
	local cutscene = self._cutscenes and self._cutscenes[name]

	if cutscene == nil then
		if not DB:has("cutscene", name) then
			error("Cutscene \"" .. tostring(name) .. "\" does not exist.")
		end

		cutscene = core_or_local("Cutscene", DB:load_node("cutscene", name), self)

		if not Application:ews_enabled() then
			assert(cutscene:is_optimized(), "Cutscene \"" .. tostring(name) .. "\" is production-only (un-optimized).")
		end

		self._cutscenes = self._cutscenes or {}
		self._cutscenes[name] = cutscene
	end

	return cutscene
end

function CoreCutsceneManager:_on_playback_started(cutscene_name)
end

function CoreCutsceneManager:_on_playback_finished(cutscene_name)
end

function CoreCutsceneManager:_debug_persistent_keys_per_cutscene()
	local persistent_keys_per_cutscene = {}

	for _, name in ipairs(self:get_cutscene_names()) do
		local cutscene = self:get_cutscene(name)
		local persistent_keys = cutscene:_debug_persistent_keys()
		persistent_keys_per_cutscene[name] = table.map_keys(persistent_keys)
	end

	return persistent_keys_per_cutscene
end

function CoreCutsceneManager:_debug_persistent_keys_report()
	local output_string = "Persistent Cutscene Keys Report\n"
	output_string = output_string .. "-------------------------------\n"

	for cutscene_name, persistent_keys in pairs(self:_debug_persistent_keys_per_cutscene()) do
		if not table.empty(persistent_keys) then
			output_string = output_string .. "\n" .. cutscene_name .. "\n"

			for _, persistent_key_description in ipairs(persistent_keys) do
				output_string = output_string .. "\t" .. persistent_key_description .. "\n"
			end
		end
	end

	return output_string
end

function CoreCutsceneManager:_debug_dump_persistent_keys_report(path)
	if path then
		local file = SystemFS:open(path, "w")

		file:write(self:_debug_persistent_keys_report())
		file:close()
		cat_print("debug", "Persistent Keys report written to \"" .. path .. "\"")
	else
		cat_print("debug", "")
		cat_print("debug", self:_debug_persistent_keys_report())
	end
end

function CoreCutsceneManager:set_active_camera()
	error("CoreCutsceneManager:set_active_camera() is deprecated. The camera is now kept in CoreCutscenePlayer, but is not exposed here.")
end

function CoreCutsceneManager:attempt_switch_to_active_camera()
	error("CoreCutsceneManager:attempt_switch_to_active_camera() is deprecated. The camera is now kept in CoreCutscenePlayer, but is not exposed here.")
end

function CoreCutsceneManager:set_cutscene_camera_enabled()
	error("CoreCutsceneManager:set_cutscene_camera_enabled() is deprecated. The camera is now kept in CoreCutscenePlayer, but is not exposed here.")
end

function CoreCutsceneManager:set_listener_enabled()
	error("CoreCutsceneManager:set_listener_enabled() is deprecated. The listener is now kept in CoreCutscenePlayer, but is not exposed here.")
end

function CoreCutsceneManager:set_camera_attribute()
	error("CoreCutsceneManager:set_camera_attribute() is deprecated. The camera is now kept in CoreCutscenePlayer, but is not exposed here.")
end

function CoreCutsceneManager:play_camera_shake()
	error("CoreCutsceneManager:play_camera_shake() is deprecated. The camera is now kept in CoreCutscenePlayer, but is not exposed here.")
end

function CoreCutsceneManager:load()
	Application:stack_dump_error("CoreCutsceneManager:load() is deprecated. There is no need to call it.")
end

function CoreCutsceneManager:save()
	error("CoreCutsceneManager:save() is deprecated. The new Cutscene Editor uses CoreCutsceneEditorProjects.")
end

function CoreCutsceneManager:save_all()
	error("CoreCutsceneManager:save_all() is deprecated. The new Cutscene Editor uses CoreCutsceneEditorProjects.")
end

function CoreCutsceneManager:pre_load_cutscene_units()
	Application:stack_dump_error("CoreCutsceneManager:pre_load_cutscene_units() is deprecated. There is no need to call it.")
end

function CoreCutsceneManager:internal_load()
	Application:stack_dump_error("CoreCutsceneManager:internal_load() is deprecated. There is no need to call it.")
end

function CoreCutsceneManager:stop_cutscene()
	Application:stack_dump_error("CoreCutsceneManager:stop_cutscene() is deprecated. Use CoreCutsceneManager:stop() instead.")
	self:stop()
end

function CoreCutsceneManager:set_stop_at_end()
	Application:stack_dump_error("CoreCutsceneManager:set_stop_at_end() is deprecated. There is no need to call it.")
end

function CoreCutsceneManager:get_current_frame_nr()
	error("CoreCutsceneManager:get_current_frame_nr() is deprecated. The playhead state is kept in CoreCutscenePlayer, but is not exposed here.")
end

function CoreCutsceneManager:get_frame_count()
	error("CoreCutsceneManager:get_frame_count() is deprecated. The frame count is part of the CoreCutscene, but is not exposed here.")
end

function CoreCutsceneManager:move_to_frame()
	error("CoreCutsceneManager:move_to_frame() is deprecated. The playhead state is kept in CoreCutscenePlayer, but is not exposed here.")
end

function CoreCutsceneManager:evaluate_current_frame()
	error("CoreCutsceneManager:evaluate_current_frame() is deprecated. The playhead state is kept in CoreCutscenePlayer, but is not exposed here.")
end
