core:module("CoreDOFManager")

DOFManager = DOFManager or class()

function DOFManager:init()
	self._queued_effects = {}
	self._sorted_effect_list = {}
	self._last_id = 0
	self._current_effect = nil
	self._enabled = true
	self._var_map = {
		"near_min",
		"near_max",
		"far_min",
		"far_max"
	}
	self._game_timer = TimerManager:game()
	self._env_dof_enabled = true
	self._environment_parameters = {
		clamp = 0,
		far_min = 0,
		far_max = 0,
		near_max = 0,
		near_min = 0
	}
	self._clamp_prev_frame = 0
end

function DOFManager:save(data)
	if next(self._queued_effects) then
		local state = {
			queued_effects = clone(self._queued_effects)
		}
		data.DOFManager = state
	end
end

function DOFManager:load(data)
	local state = data.DOFManager

	if state then
		if state.queued_effects then
			self._queued_effects = clone(state.queued_effects)
		else
			self._queued_effects = {}
		end
	end
end

function DOFManager:update(t, dt)
	self:remove_expired_effects(t, dt)

	self._current_effect = self._sorted_effect_list[1]
	local new_data, new_clamp = nil

	if self._current_effect then
		self:update_effect(t, dt, self._current_effect)

		new_data = self:check_dof_allowed() and self._queued_effects[self._current_effect]
	end

	if new_data then
		new_data = new_data.prog_data
		new_clamp = new_data.dirty and new_data.clamp
		new_data = new_clamp and new_data.cur_values

		if new_data then
			if self._clamp_prev_frame ~= new_clamp then
				self._clamp_prev_frame = new_clamp
			end

			self:feed_dof(new_data.near_min, new_data.near_max, new_data.far_min, new_data.far_max, new_clamp)
		end
	elseif not self._env_dof_enabled and managers.viewport:get_active_vp() then
		self._env_dof_enabled = true
	end
end

function DOFManager:update_world_camera(t, dt, effect)
	managers.worldcamera:update_dof(t, dt, effect)
end

function DOFManager:paused_update(t, dt)
	self:update(t, dt)
end

function DOFManager:modifier_callback(interface)
	self._modifier_output = interface:parameters()

	return assert(self._modifier_input)
end

function DOFManager:feed_dof(near_min, near_max, far_min, far_max, clamp)
	self._modifier_input = {
		near_focus_distance_min = near_min,
		near_focus_distance_max = near_max,
		far_focus_distance_min = far_min,
		far_focus_distance_max = far_max,
		clamp = clamp
	}
end

function DOFManager:get_dof_parameters()
	return self._current_effect and self._queued_effects[self._current_effect].prog_data.cur_values
end

function DOFManager:get_dof_values()
	assert(self._modifier_output)

	return self._modifier_output.near_focus_distance_min, self._modifier_output.near_focus_distance_max, self._modifier_output.far_focus_distance_min, self._modifier_output.far_focus_distance_max, self._modifier_output.clamp
end

function DOFManager:debug_draw_feed(near_max, near_min, far_min, far_max, clamp)
	local vp = managers.viewport:first_active_viewport()

	if vp and alive(vp:camera()) then
		local camera = vp:camera()
		local cam_dir = camera:rotation():y()
		local cam_pos = camera:position() - math.UP * 50

		Application:draw_cone(cam_pos + cam_dir * near_min, cam_pos + cam_dir * near_max, 49 * clamp + 1, 0, 0, 1)
		Application:draw_cone(cam_pos + cam_dir * far_min, cam_pos + cam_dir * far_max, 49 * clamp + 1, 0, 1, 0)
	end
end

function DOFManager:remove_expired_effects(t, dt)
	local id, effect = next(self._queued_effects)

	while id do
		if effect.prog_data.finish_t then
			local eff_t = (effect.preset.timer or self._game_timer):time()

			if effect.prog_data.finish_t <= eff_t then
				self:intern_remove_effect(id)
			end
		end

		id, effect = next(self._queued_effects, id)
	end
end

function DOFManager:update_effect(t, dt, id)
	local effect = self._queued_effects[id]
	local preset = effect.preset
	local prog = effect.prog_data
	local eff_t = preset.timer and preset.timer:time() or t

	if prog.fade_in_end and eff_t < prog.fade_in_end then
		prog.lerp = (eff_t - prog.start_t) / preset.fade_in

		self:calculate_current_parameters_fade_in(t, dt, effect)
	elseif not prog.sustain_end or eff_t < prog.sustain_end then
		prog.lerp = 1

		self:calculate_current_parameters_sustain(t, dt, effect)
	elseif prog.finish_t then
		prog.lerp = (prog.finish_t - eff_t) / preset.fade_out

		self:calculate_current_parameters_fade_out(t, dt, effect, id)
	end
end

function DOFManager:calculate_current_parameters_fade_in(t, dt, effect)
	local next_eff_sort = effect.prog_data.sort_index + 1
	local next_eff_id = self._sorted_effect_list[next_eff_sort]
	local init = nil

	if next_eff_id then
		self:update_effect(t, dt, next_eff_id)

		init = self._queued_effects[self._sorted_effect_list[next_eff_sort]].prog_data.cur_values
	end

	init = init or self._environment_parameters
	local cur = effect.prog_data.cur_values
	local tar = effect.prog_data.target_values
	local eff_lerp = effect.prog_data.lerp

	for _, v in pairs(self._var_map) do
		cur[v] = math.lerp(init[v], tar[v], eff_lerp)
	end

	cur.clamp = math.lerp(init.clamp, effect.prog_data.clamp, eff_lerp)
	effect.prog_data.dirty = true
end

function DOFManager:calculate_current_parameters_sustain(t, dt, effect)
	if effect.prog_data.peak_reached then
		effect.prog_data.dirty = nil
	else
		effect.prog_data.peak_reached = true
		local cur = effect.prog_data.cur_values
		local tar = effect.prog_data.target_values

		for _, v in pairs(self._var_map) do
			cur[v] = tar[v]
		end

		cur.clamp = effect.prog_data.clamp
		effect.prog_data.dirty = true
	end
end

function DOFManager:calculate_current_parameters_fade_out(t, dt, effect, id)
	local next_eff_sort = effect.prog_data.sort_index + 1
	local next_eff_id = self._sorted_effect_list[next_eff_sort]
	local out = nil

	if next_eff_id then
		self:update_effect(t, dt, next_eff_id)

		out = self._queued_effects[self._sorted_effect_list[next_eff_sort]].prog_data.cur_values
	end

	out = out or self._environment_parameters
	local cur = effect.prog_data.cur_values
	local tar = effect.prog_data.target_values
	local eff_lerp = effect.prog_data.lerp

	for _, v in pairs(self._var_map) do
		cur[v] = math.lerp(out[v], tar[v], eff_lerp)
	end

	cur.clamp = math.lerp(out.clamp, effect.prog_data.clamp, eff_lerp)
	effect.prog_data.dirty = true
end

function DOFManager:play(dof_data, amplitude_multiplier)
	self._last_id = self._last_id + 1
	local new_data = {}
	local timer = dof_data.timer or self._game_timer
	local t = timer:time()
	local prog_data = {
		clamp = amplitude_multiplier and dof_data.clamp * amplitude_multiplier or dof_data.clamp,
		fade_in_end = dof_data.fade_in and t + dof_data.fade_in or t
	}
	prog_data.sustain_end = dof_data.sustain and prog_data.fade_in_end + dof_data.sustain
	prog_data.finish_t = prog_data.sustain_end and prog_data.sustain_end + (dof_data.fade_out or 0)
	prog_data.start_t = t
	local cur_values = nil
	local near_min, near_max, far_min, far_max, clamp = self:get_dof_values()

	if clamp > 0 then
		cur_values = {
			near_min = near_min,
			near_max = near_max,
			far_min = far_min,
			far_max = far_max,
			clamp = clamp
		}
	else
		cur_values = {
			clamp = 0,
			far_min = 0,
			far_max = 0,
			near_max = 0,
			near_min = 0
		}
	end

	local target_values = {}

	for _, v in pairs(self._var_map) do
		target_values[v] = dof_data[v]
	end

	prog_data.target_values = target_values
	prog_data.cur_values = cur_values
	new_data.preset = dof_data
	new_data.prog_data = prog_data
	self._queued_effects[self._last_id] = new_data

	self:add_to_sorted_list(self._last_id, dof_data.prio)

	return self._last_id
end

function DOFManager:add_to_sorted_list(new_id, prio)
	local allocated = nil

	for index, eff_id in ipairs(self._sorted_effect_list) do
		if self._queued_effects[eff_id].preset.prio <= prio then
			table.insert(self._sorted_effect_list, index, new_id)

			allocated = true

			break
		end
	end

	if not allocated then
		table.insert(self._sorted_effect_list, new_id)
	end

	for index, eff_id in ipairs(self._sorted_effect_list) do
		self._queued_effects[eff_id].prog_data.sort_index = index
	end
end

function DOFManager:remove_from_sorted_list(id)
	for index, eff_id in ipairs(self._sorted_effect_list) do
		if eff_id == id then
			table.remove(self._sorted_effect_list, index)

			break
		end
	end

	for index, eff_id in ipairs(self._sorted_effect_list) do
		self._queued_effects[eff_id].prog_data.sort_index = index
	end
end

function DOFManager:stop(id, instant)
	local effect = self._queued_effects[id]

	if effect then
		if instant then
			self:intern_remove_effect(id)

			if self._current_effect == id then
				self._current_effect = nil
			end
		else
			local t = (effect.preset.timer or self._game_timer):time()
			effect.prog_data.sustain_end = t
			effect.prog_data.finish_t = t + (effect.preset.fade_out or 0)
		end
	end
end

function DOFManager:stop_all(instant)
	self._queued_effects = {}
	self._sorted_effect_list = {}
	self._current_effect = nil

	managers.environment:enable_dof()
	managers.environment:needs_update("PE")

	self._env_dof_enabled = true

	if managers.viewport:get_active_vp() then
		self:feed_dof(0, 0, 0, 0, 0)
	end
end

function DOFManager:intern_remove_effect(id)
	self._queued_effects[id] = nil

	self:remove_from_sorted_list(id)
end

function DOFManager:check_dof_allowed()
	return self._enabled
end

function DOFManager:set_enabled(state)
	self._enabled = state
end

function DOFManager:is_effect_playing(id)
	return id and self._queued_effects[id] and true
end

function DOFManager:from_env_mgr_set_env_dof(env_data)
	local env_param = self._environment_parameters
	env_param.near_min = env_data.near_focus_distance_min
	env_param.near_max = env_data.near_focus_distance_max
	env_param.far_min = env_data.far_focus_distance_min
	env_param.far_max = env_data.far_focus_distance_max
	env_param.clamp = env_data.clamp
end

function DOFManager:clbk_environment_change()
	local env_data = managers.environment:get_posteffect()
	env_data = env_data and env_data._post_processors
	env_data = env_data and env_data.hdr_post_processor
	env_data = env_data and env_data._modifiers
	env_data = env_data and env_data.dof
	env_data = env_data and env_data._params

	if env_data then
		self._environment_parameters = {
			near_min = env_data.near_focus_distance_min,
			near_max = env_data.near_focus_distance_max,
			far_min = env_data.far_focus_distance_min,
			far_max = env_data.far_focus_distance_max,
			clamp = env_data.clamp
		}
	end
end

function DOFManager:set_effect_parameters(id, params, clamp)
	if self._queued_effects[id] then
		if params then
			for k, v in pairs(params) do
				self._queued_effects[id].prog_data.target_values[k] = v
			end
		end

		if clamp then
			self._queued_effects[id].prog_data.clamp = clamp
		end

		self._queued_effects[id].prog_data.peak_reached = nil

		return true
	end
end
