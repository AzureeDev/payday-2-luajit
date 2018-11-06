core:import("CoreFiniteStateMachine")
require("lib/units/beings/player/PlayerMovementInputVR")

local WARP_TYPE_MOVE = 0
local WARP_TYPE_JUMP = 1
WarpCommonState = WarpCommonState or class()
WarpCommonState.WARP_MIN_TH = 100
WarpCommonState.HUSK_SPEED = tweak_data.player.movement_state.standard.movement.speed.RUNNING_MAX

function WarpCommonState:init()
end

function WarpCommonState:destroy()
end

function WarpCommonState:climb_ladder()
	return self._climb_ladder
end

function WarpCommonState:warp()
	if self.params.state_data.warping or self.params.state_data.on_zipline or self.params.state_data.on_ladder then
		return false
	end

	return self._warp
end

function WarpCommonState:transition()
end

function WarpCommonState:_setup_warp(warp_type, target, cost)
	local distance = mvector3.distance(self.params.unit:position(), target)
	self.params.state_data._warp_distance = distance
	self.params.state_data._warp_cost = cost and distance / self.params.state_data._wanted_husk_speed or 0
	self.params.state_data._warp_target = target
	self.params.state_data._warp_type = warp_type
end

WarpTargetState = WarpTargetState or class(WarpCommonState)

function WarpTargetState:init(args)
	self._warp_ext = self.params.unit:hand():hand_unit(args.hand):warp()

	self._warp_ext:set_targeting(true)
	self:_update_warp_variables()

	self._movement_ext = self.params.unit:movement()

	self._warp_ext:set_ladders_enabled(not self._movement_ext:in_clean_state())

	self._brush = Draw:brush(Color(0.15, 1, 1, 1))

	self._brush:set_blend_mode("opacity_add")
end

function WarpTargetState:_update_warp_variables()
	local state = self.params.state_data
	local jump_speed = PlayerStandardVR.MAX_WARP_JUMP_MOVE_SPEED
	local jump_distance = PlayerStandardVR.MAX_WARP_JUMP_DISTANCE

	if state.ducking then
		jump_distance = state._warp_max_range
		jump_speed = state._warp_max_range / PlayerStandardVR.WARP_JUMP_TIME
	end

	self._warp_ext:set_max_jump_distance(jump_distance)
	self._warp_ext:set_jump_move_speed(jump_speed)
	self._warp_ext:set_max_range(state._warp_max_range)
	self._warp_ext:set_range(state._warp_range)
	self._warp_ext:set_blocked(self._blocked)

	local timer = state._warp_timer or 0
	local state_name = self.params.unit:movement():current_state_name()
	local disable_jump = state_name == "mask_off" or state_name == "civilian"

	self._warp_ext:set_enable_jump(timer <= 0 and jump_distance <= jump_speed * state._warp_stamina_jump_run_time and not disable_jump)
end

function WarpTargetState:destroy()
	self._warp_ext:set_targeting(false)
end

function WarpTargetState:update(t, dt)
	self._warp_ext:clear_snap_points()

	local unit = self.params.unit
	local state = self.params.state_data

	self:_update_warp_variables()
end

function WarpTargetState:transition()
	if self.params.state_data.warping or self.params.state_data.on_zipline or self.params.state_data.on_ladder or self.params.state_data.interacting or not self.params.input:is_movement_warp() then
		return WarpIdleState
	end

	local targeting = self.params.input:state().warp_target
	local warp_button_state = self.params.input:state().warp
	self.params.state_data._hold_warp = self.params.state_data._hold_warp and warp_button_state
	local should_warp = warp_button_state

	if not should_warp and not targeting then
		return WarpIdleState
	end

	local length = managers.vr:get_setting("autowarp_length")

	if self.params.state_data._hold_warp and length ~= "off" and should_warp then
		local tp = self._warp_ext:target_position()

		if tp and self._warp_ext:target_type() == "move" then
			local timer = self.params.state_data._warp_timer or 0
			local warp_max_time = math.max(PlayerStandardVR.MAX_WARP_DESYNC_TIME - timer, 0)
			local wanted_distance = tp and mvector3.distance(tp, self.params.unit:position()) or 0
			local time_th = tweak_data.vr.autowarp_length[length] * PlayerStandardVR.MAX_WARP_DESYNC_TIME
			should_warp = self.WARP_MIN_TH < wanted_distance and warp_max_time - time_th >= -0.05 and self.params.state_data._warp_time_since_start - 0.35 >= -0.05
		else
			should_warp = false
		end
	end

	self.params.state_data._hold_warp = warp_button_state

	if should_warp then
		if self._blocked then
			return WarpIdleState
		end

		local tp = self._warp_ext:target_position()

		if tp then
			local tp_type = self._warp_ext:target_type()
			local target = mvector3.copy(tp)

			if tp_type == "ladder" then
				return WarpLadderState, {
					target = target,
					ladder_unit = self._warp_ext:target_data()
				}
			elseif tp_type == "jump" then
				self:_setup_warp(WARP_TYPE_JUMP, target, true)

				return WarpWarpingState
			else
				self:_setup_warp(WARP_TYPE_MOVE, target, true)

				return WarpWarpingState
			end
		end

		return WarpIdleState
	end
end

WarpLadderState = WarpLadderState or class(WarpCommonState)

function WarpLadderState:init(data)
	self._climb_ladder = true
	self._ladder_unit = data.ladder_unit
end

function WarpLadderState:ladder_unit()
	return self._ladder_unit
end

function WarpLadderState:transition()
	if not self.params.state_data.on_ladder then
		return WarpIdleState
	end
end

WarpWarpingState = WarpWarpingState or class(WarpCommonState)

function WarpWarpingState:init(args)
	self._warp = true
end

function WarpWarpingState:transition()
	if not self.params.state_data.warping then
		return WarpIdleState
	end
end

WarpIdleState = WarpIdleState or class(WarpCommonState)

function WarpIdleState:init()
end

function WarpIdleState:transition()
	if self.params.state_data.warping or self.params.state_data.on_zipline or self.params.state_data.on_ladder or self.params.state_data.downed or self.params.state_data.tased or self.params.state_data.warp_disabled or self.params.state_data.interacting or not self.params.input:is_movement_warp() then
		return
	end

	local warping = self.params.input:state().warp
	self.params.state_data._hold_warp = self.params.state_data._hold_warp and warping
	local touching = self.params.input:state().warp_target
	local autowarp = managers.vr:get_setting("autowarp_length") ~= "off"

	if autowarp and self.params.state_data._hold_warp or (touching or warping) and not self.params.state_data._hold_warp then
		return WarpTargetState, {
			hand = self.params.unit:hand():warp_hand()
		}
	end
end

PlayerStandardVR = PlayerStandard or Application:error("PlayerStandardVR requires PlayerStandard!")
local __init_standard = PlayerStandard.init
local __update_standard = PlayerStandard.update
local __enter_standard = PlayerStandard.enter
local __exit_standard = PlayerStandard.exit
local __start_action_ducking_standard = PlayerStandard._start_action_ducking
local __start_action_zipline_standard = PlayerStandard._start_action_zipline
local __end_action_zipline_standard = PlayerStandard._end_action_zipline
PlayerStandardVR.WARP_SPEED = 3000
PlayerStandardVR.DUCK_START_TH = 30
PlayerStandardVR.DUCK_END_TH = 5
PlayerStandardVR.MAX_WARP_DISTANCE = 500
PlayerStandardVR.MAX_WARP_JUMP_DISTANCE = 450
PlayerStandardVR.WARP_JUMP_TIME = 2 * tweak_data.player.movement_state.standard.movement.jump_velocity.z / 982
PlayerStandardVR.MAX_WARP_JUMP_MOVE_SPEED = PlayerStandardVR.MAX_WARP_JUMP_DISTANCE / PlayerStandardVR.WARP_JUMP_TIME
PlayerStandardVR.MAX_WARP_DESYNC_TIME = PlayerStandardVR.MAX_WARP_DISTANCE / tweak_data.player.movement_state.standard.movement.speed.RUNNING_MAX
PlayerStandardVR.MOVEMENT_DISTANCE_LIMIT = 20

function PlayerStandardVR:init(unit)
	__init_standard(self, unit)

	local controller = unit:base():controller()
	self._camera_base_rot = self._camera_unit:base():base_rotation()
	self._cur_hmd_position = VRManager:hmd_position()

	mvector3.set_z(self._cur_hmd_position, 0)

	self._movement_input = PlayerMovementInputVR:new(controller)
	self._warp_state_machine = CoreFiniteStateMachine.FiniteStateMachine:new(WarpIdleState, "params", {
		state_data = self._state_data,
		unit = unit,
		input = self._movement_input
	})

	self._warp_state_machine:set_debug(false)
	managers.menu:add_active_changed_callback(callback(self, self, "_on_menu_active_changed_vr"))

	self._zipline_screen_setting_changed_clbk = callback(self, self, "_on_zipline_screen_setting_changed")
end

function PlayerStandardVR:_start_action_jump(t)
	self._jump_start_pos = mvector3.copy(self._pos)
	self._jump_end_pos = mvector3.copy(self._state_data._warp_target)
	local jump_vec = self._jump_end_pos - self._jump_start_pos

	mvector3.set_z(jump_vec, 0)

	local horz_distance = mvector3.normalize(jump_vec)
	local move_time = horz_distance / tweak_data.player.movement_state.standard.movement.speed.STANDARD_MAX
	local jump_height = self._jump_end_pos.z - self._jump_start_pos.z
	local jump_distance = mvector3.distance(self._jump_end_pos, self._jump_start_pos)
	local v_h = tweak_data.player.movement_state.standard.movement.speed.STANDARD_MAX
	local v_v = (jump_height + 10 + 491 * move_time * move_time) / (move_time * jump_distance / horz_distance)

	mvector3.multiply(jump_vec, v_h)
	mvector3.set_z(jump_vec, v_v)

	self._is_jumping = true
	self._jump_timer = 0
	self._jump_time = move_time
	self._jump_vec = jump_vec

	self._ext_network:send("action_jump", self._pos, jump_vec)
end

function PlayerStandardVR:_start_action_warp(t)
	self:_interupt_action_running(t)
	self:_interupt_action_ducking(t, true)
	self:_interupt_action_steelsight(t)

	local cost = self._state_data._warp_cost
	self._state_data._warp_timer = (self._state_data._warp_timer or 0) + cost
	self._state_data._warp_start_time = t
	self._state_data.warping = true

	if self._state_data._warp_type == WARP_TYPE_JUMP then
		self:_start_action_jump(t)
	end

	if cost > 0 and self._state_data._warp_consumes_stamina then
		self._ext_movement:activate_regeneration()
		self._ext_movement:subtract_stamina(cost * tweak_data.player.movement_state.stamina.STAMINA_DRAIN_RATE_WARP)

		if self._ext_movement:is_stamina_drained() then
			self._state_data._warp_stamina_drained = true
		end
	end

	self._unit:kill_mover()
	self._unit:hand():set_warping(true)
end

function PlayerStandardVR:_end_action_warp(t)
	self._state_data.warping = false

	self:_activate_mover(PlayerStandard.MOVER_STAND, Vector3(0, 0, -100))

	if self._state_data._warp_distance > 100 then
		self._unit:sound():play("matrix_footstep_land")
	else
		self._unit:sound():play("footstep_run")
	end

	self._unit:hand():set_warping(false)

	self._state_data.last_warp_pos = mvector3.copy(self._ext_movement:ghost_position())

	if self._state_data.warping_to_ladder then
		self:_start_action_ladder(t)
	end

	local warp_amount = self._state_data._warp_distance / self._state_data._warp_max_range

	if managers.player:has_category_upgrade("player", "warp_health") then
		local min, max, total_amount, time = unpack(managers.player:upgrade_value("player", "warp_health"))
		local health_regen = (max - min) * warp_amount + min

		if not self._state_data.warp_health or t > self._state_data.warp_health.t + time then
			self._state_data.warp_health = {
				amount = 0,
				t = t
			}
		end

		if self._state_data.warp_health.amount < total_amount then
			health_regen = math.min(health_regen, total_amount - self._state_data.warp_health.amount)
			local prev_health = self._ext_damage:get_real_health()

			self._ext_damage:restore_health(health_regen, true)

			local amount_healed = self._ext_damage:get_real_health() - prev_health
			self._state_data.warp_health.amount = self._state_data.warp_health.amount + amount_healed
		end
	end

	if managers.player:has_category_upgrade("player", "warp_armor") or managers.player:has_category_upgrade("player", "warp_armor_lite") then
		local upgrade = managers.player:has_category_upgrade("player", "warp_armor_lite") and "warp_armor_lite" or "warp_armor"
		local min, max, max_restores, time = unpack(managers.player:upgrade_value("player", upgrade))
		local armor_regen = (max - min) * warp_amount + min

		if not self._state_data.warp_armor or t > self._state_data.warp_armor.t + time then
			self._state_data.warp_armor = {
				restores = 0,
				t = t
			}
		end

		if self._state_data.warp_armor.restores < max_restores then
			self._ext_damage:restore_armor(armor_regen)

			self._state_data.warp_armor.restores = self._state_data.warp_armor.restores + 1
		end
	end

	if managers.player:has_category_upgrade("player", "warp_dodge") then
		local min, max, time = unpack(managers.player:upgrade_value("player", "warp_dodge"))
		local dodge_increase = (max - min) * warp_amount + min

		self._ext_damage:add_temporary_dodge(dodge_increase, time)
	end

	local move_min = tweak_data.vr.post_warp.min
	local move_max = tweak_data.vr.post_warp.max
	self._post_warp_skill_t = t + warp_amount * (move_max - move_min) + move_max
	self._moving = true

	if managers.player:has_category_upgrade("player", "post_warp_suppression") then
		local distance, min, max = unpack(managers.player:upgrade_value("player", "post_warp_suppression"))

		managers.player:register_message(Message.OnEnemyKilled, "fear_nearby_enemies", callback(self, self, "_fear_nearby_enemies", distance))

		local active_time = (max - min) * warp_amount + min
		self._post_warp_suppression_t = t + active_time
	end

	if managers.player:has_category_upgrade("player", "post_warp_reload_speed") then
		local min, max = unpack(managers.player:upgrade_value("player", "post_warp_reload_speed"))
		local reload_multiplier = (max - min) * warp_amount + min

		self._ext_movement:set_next_reload_speed_multiplier(reload_multiplier)
	end

	if managers.player:has_category_upgrade("player", "run_dodge_chance_vr") then
		local dodge_increase = managers.player:upgrade_value("player", "run_dodge_chance")
		local time_min, time_max = unpack(managers.player:upgrade_value("player", "run_dodge_chance_vr"))
		local time = (time_max - time_min) * warp_amount + time_min

		self._ext_damage:add_temporary_dodge(dodge_increase, time)
	end
end

function PlayerStandardVR:_fear_nearby_enemies(distance)
	local enemies = World:find_units_quick("sphere", self._unit:position(), distance, managers.slot:get_mask("enemies"))

	for _, enemy_unit in ipairs(enemies) do
		if not enemy_unit:movement():cool() then
			enemy_unit:character_damage():build_suppression("panic", 1)
		end
	end
end

function PlayerStandardVR:_can_run_directional()
	return true
end

function PlayerStandardVR:_can_run(check_stamina)
	if self:on_ladder() or self:_on_zipline() then
		return false
	end

	if self:_changing_weapon() or self._use_item_expire_t or self._state_data.in_air or self:_is_throwing_projectile() or self:_is_charging_weapon() then
		return false
	end

	if self._state_data.ducking and not self:_can_stand() then
		return false
	end

	if managers.player:get_player_rule("no_run") then
		return false
	end

	if check_stamina and not self._unit:movement():is_above_stamina_threshold() then
		return false
	end

	return true
end

function PlayerStandardVR:_check_action_run(t, input)
	if self._movement_input:state().run then
		if not self._running then
			self:_start_action_running(t, input)
		end
	elseif self._running then
		self:_end_action_running(t)
	end
end

function PlayerStandardVR:_start_action_running(t, input)
	if self:_can_run(true) then
		if self._shooting and not self._equipped_unit:base():run_and_shoot_allowed() then
			return
		end

		self:set_running(true)

		self._end_running_expire_t = nil
		self._start_running_t = t
	end
end

function PlayerStandardVR:_end_action_running(t)
	if not self._end_running_expire_t then
		self:set_running(false)
		self._movement_input:stop_running()

		self._end_running_expire_t = t
	end
end

function PlayerStandardVR:_rotate_player(right)
	local angle = managers.vr:get_setting("rotate_player_angle")
	local rot = right and Rotation(-angle, 0, 0) or Rotation(angle, 0, 0)

	self._ext_camera:camera_unit():base():rotate_base(rot)
	self._unit:hand():set_base_rotation(self._camera_unit:base():base_rotation())

	self._camera_base_rot = self._camera_unit:base():base_rotation()

	managers.overlay_effect:play_effect(tweak_data.vr.overlay_effects.fade_in_rotate_player)
end

function PlayerStandardVR:_check_vr_actions(t, dt)
	if self._controller:get_input_pressed("rotate_player_left") then
		self:_rotate_player(false)
	end

	if self._controller:get_input_pressed("rotate_player_right") then
		self:_rotate_player(true)
	end

	local state = self._warp_state_machine:state()

	if state.update then
		state:update(t, dt)
	end

	self._warp_state_machine:transition()

	if self._warp_state_machine:state():warp() and not self._state_data.warping then
		self:_start_action_warp(t)
	end
end

function PlayerStandardVR:_update_variables(t, dt)
	local hand = self._unit:hand()

	self._movement_input:update(t, dt, hand:raw_hand_rotation(hand:warp_hand()) or Rotation())

	self._current_height = self._ext_movement:hmd_position().z

	if self._state_data._warp_timer then
		self._state_data._warp_timer = self._state_data._warp_timer - dt

		if self._state_data._warp_timer <= 0 then
			self._state_data._warp_timer = nil
		end
	end

	if not self._state_data.warping and not self._moving then
		if self._state_data._warp_stamina_drained and self._ext_movement:is_above_stamina_threshold() then
			self._state_data._warp_stamina_drained = false
		end

		local is_running = self:_can_run() and not self._state_data._warp_stamina_drained
		self._state_data._wanted_husk_speed = self:_get_max_walk_speed(t, is_running)
		local timer = self._state_data._warp_timer or 0
		local warp_max_time = math.max(self.MAX_WARP_DESYNC_TIME - timer, 0)
		local warp_range = math.min(self._state_data._wanted_husk_speed * warp_max_time, self.MAX_WARP_DISTANCE)
		self._state_data._warp_range = warp_range
		self._state_data._warp_max_range = math.min(self.MAX_WARP_DESYNC_TIME * self._state_data._wanted_husk_speed, self.MAX_WARP_DISTANCE)
		self._state_data._warp_time_since_start = t - (self._state_data._warp_start_time or 0)
		self._state_data._warp_consumes_stamina = is_running

		if self._ext_movement:is_above_stamina_threshold() then
			local stamina = self._ext_movement:stamina()
			local jump_run_time = (stamina - tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN) / tweak_data.player.movement_state.stamina.STAMINA_DRAIN_RATE_WARP
			self._state_data._warp_stamina_jump_run_time = jump_run_time
		else
			self._state_data._warp_stamina_jump_run_time = 0
		end
	end

	if self._post_warp_suppression_t and self._post_warp_suppression_t < t then
		managers.player:unregister_message(Message.OnEnemyKilled, "fear_nearby_enemies")
	end
end

function PlayerStandardVR:update(t, dt)
	self:_update_variables(t, dt)
	self:_check_vr_actions(t)

	self._last_equipped = nil

	__update_standard(self, t, dt)
end

local mvec_pos_new = Vector3()
local mvec_hmd_delta = Vector3()
local mvec_prev_pos = Vector3()
local mvec_mover_to_ghost = Vector3()

function PlayerStandardVR:_update_movement(t, dt)
	local pos_new = mvec_pos_new

	mvector3.set(pos_new, self._ext_movement:ghost_position())
	mvector3.set(mvec_mover_to_ghost, pos_new)
	mvector3.subtract(mvec_mover_to_ghost, self._pos)

	if self._state_data.warping and self._state_data._warp_target then
		local dir = self._state_data._warp_target - pos_new
		local dist = mvector3.normalize(dir)
		local warp_len = dt * self.WARP_SPEED

		if dist <= warp_len or dist == 0 then
			mvector3.set(pos_new, self._state_data._warp_target)
			self:_end_action_warp(t)
		elseif t - self._state_data._warp_start_time > 3 then
			self:_end_action_warp(t)
		else
			mvector3.add(pos_new, dir * warp_len)
		end
	else
		if not self._state_data.last_warp_pos or mvector3.distance_sq(self._state_data.last_warp_pos, pos_new) > self.MOVEMENT_DISTANCE_LIMIT * self.MOVEMENT_DISTANCE_LIMIT then
			mvector3.set_z(pos_new, self._pos.z)
		end

		local ground_z = self:_chk_floor_moving_pos()

		if ground_z then
			mvector3.set_z(pos_new, ground_z)
		end

		local hmd_delta = mvec_hmd_delta

		if not self._state_data._block_input then
			mvector3.set(hmd_delta, self._ext_movement:hmd_delta())
		else
			mvector3.set_zero(hmd_delta)
		end

		mvector3.set_z(hmd_delta, 0)
		mvector3.rotate_with(hmd_delta, self._camera_base_rot)
		mvector3.add(pos_new, hmd_delta)
	end

	local pos_diff = self._pos - mvec_prev_pos

	mvector3.set(mvec_prev_pos, self._pos)

	if self._state_data.on_ladder then
		local unit_position = self._state_data.ladder.current_position + math.dot(pos_new - self._state_data.ladder.current_position, self._state_data.ladder.w_dir) * self._state_data.ladder.w_dir + math.dot(pos_new - self._state_data.ladder.current_position, self._state_data.ladder.ladder_ext:normal()) * self._state_data.ladder.ladder_ext:normal()

		self._ext_movement:set_ghost_position(pos_new, unit_position)
		mvector3.set(pos_new, unit_position)
	elseif self._state_data.on_zipline and self._state_data.zipline_data.position then
		local rot = Rotation()

		mrotation.set_look_at(rot, self._state_data.zipline_data.zipline_unit:zipline():current_direction(), math.UP)

		self._ext_camera:camera_unit():base()._output_data.rotation = rot
		pos_new = pos_new + pos_diff

		mvector3.set(self._pos, self._state_data.zipline_data.position)
		self._ext_movement:set_ghost_position(pos_new, self._pos)
	elseif self._movement_input:is_movement_walk() and not self:_interacting() and not self._state_data.warping then
		local movement = mvector3.copy(self._movement_input:state().move_axis)

		mvector3.multiply(movement, self:_get_max_walk_speed(t) * dt)

		pos_new = pos_new + pos_diff
		self._pos = self._pos + movement
		local len = mvector3.length(mvec_mover_to_ghost)

		if len > 30 then
			local warp, pos = self._unit:find_warp_position(1, 0.6, 350, 10, pos_new)

			if warp and mvector3.distance(pos, pos_new) < 1 then
				self._pos = self._pos + mvec_mover_to_ghost

				mvector3.set(mvec_prev_pos, self._pos)
			end
		end

		self._ext_movement:set_ghost_position(pos_new, self._pos)
		mvector3.set(pos_new, self._pos)

		self._moving = true
	else
		self._moving = false

		self._ext_movement:set_ghost_position(pos_new)
	end

	if self._state_data.warping then
		mvector3.set_z(self._last_velocity_xy, 0)
	else
		mvector3.set(self._last_velocity_xy, pos_new)
		mvector3.subtract(self._last_velocity_xy, self._pos)
		mvector3.divide(self._last_velocity_xy, dt)
	end

	local cur_pos = pos_new or self._pos

	self:_update_network_jump(cur_pos, false, t, dt)
	self:_update_network_position(t, dt, cur_pos, pos_new)

	local move_dis = mvector3.distance_sq(cur_pos, self._last_sent_pos)

	if self:is_network_move_allowed() and (move_dis > 22500 or move_dis > 400 and (t - self._last_sent_pos_t > 1.5 or not pos_new)) then
		self._ext_network:send("action_walk_nav_point", cur_pos)
		mvector3.set(self._last_sent_pos, cur_pos)

		self._last_sent_pos_t = t
	end

	if self._is_jumping then
		self._jump_timer = self._jump_timer + dt
	end

	if self._post_warp_skill_t and self._post_warp_skill_t < t then
		self._moving = false
		self._post_warp_skill_t = nil
	end
end

function PlayerStandardVR:_check_action_duck(t, input)
	if not self._state_data.warping and not self._state_data.on_ladder then
		local diff = managers.vr:get_setting("height") - self._current_height

		if not self._state_data.ducking then
			if self.DUCK_START_TH <= diff then
				self:_start_action_ducking(t)
			end
		elseif diff <= self.DUCK_END_TH then
			self:_end_action_ducking(t)
		end
	end
end

function PlayerStandardVR:_start_action_ducking(t)
	if self._state_data.warping or not self._unit:mover() then
		return
	end

	__start_action_ducking_standard(self, t)
end

function PlayerStandardVR:_teleport_player(target)
	target = mvector3.copy(target)

	self._ext_movement:set_ghost_position(target)
	self._unit:warp_to(self._unit:rotation(), target)
	self._unit:camera():set_position(target)

	self._pos = target
end

function PlayerStandardVR:_check_action_ladder(t, input)
	if self._state_data.on_ladder then
		local t_pos = self._state_data.ladder.t_pos
		local hand = self._unit:hand():get_active_hand_id("idle") == 1 and "right" or "left"
		local hand_unit = self._unit:hand():hand_unit(hand)
		local touching = self._unit:base():controller():get_input_touch_bool("warp_target")

		if alive(self._ladder_directions) then
			local aiming_up = hand_unit:rotation():y().z > 0

			if self._ladder_aiming_up ~= aiming_up then
				self._ladder_aiming_up = aiming_up
				local seq = "ladder_" .. (aiming_up and "up" or "down")

				self._ladder_directions:damage():run_sequence_simple(seq)
			end

			self._ladder_directions:set_position(self._state_data.ladder.current_position + Vector3(0, 70, 50):rotate_with(self._ladder_directions:rotation()))
		end

		local pos = self._ext_movement:ghost_position()
		local offset = pos - self._state_data.ladder.current_position

		if touching and self._unit:base():controller():get_input_pressed("warp") then
			local dir = hand_unit:rotation():y().z > 0 and 1 or -1
			local next_t_pos = self._state_data.ladder.t_pos + self._state_data.ladder.step_length * dir
			local prev_pos = self._state_data.ladder.current_position + offset
			local next_pos = self._state_data.ladder.ladder_ext:position(next_t_pos) + offset
			local head_pos = self._ext_movement:m_head_pos() - self._unit:position()
			local ray = self._unit:raycast("ray", prev_pos + head_pos, next_pos + head_pos, "slot_mask", managers.slot:get_mask("statics"))

			if not ray then
				self._state_data.ladder.t_pos = next_t_pos

				if alive(self._ladder_directions) then
					self._ladder_directions:damage():run_sequence_simple("ladder_hide")

					self._ladder_aiming_up = nil
				end
			end
		end

		if t_pos ~= self._state_data.ladder.t_pos then
			t_pos = self._state_data.ladder.t_pos

			if t_pos < 0 then
				self:_teleport_player(self._state_data.ladder.bottom + offset)
				self:_end_action_ladder()
			elseif t_pos > 1 then
				self:_teleport_player(self._state_data.ladder.top + offset)
				self:_end_action_ladder()
			else
				self._state_data.ladder:update_position()
				self:_teleport_player(self._state_data.ladder.current_position + offset)
			end
		end

		if not self._state_data.ladder.ladder_ext:on_ladder(pos, self._state_data.ladder.t_pos) then
			self:_end_action_ladder()
		end

		return
	end

	if self._warp_state_machine:state():climb_ladder() then
		self:_start_action_ladder(t, self._warp_state_machine:state():ladder_unit(), true)
	end
end

function PlayerStandardVR:_end_action_ladder()
	if not self._state_data.on_ladder then
		return
	end

	self._state_data.on_ladder = false

	if self._unit:mover() then
		self._unit:mover():set_velocity(Vector3())
		self._unit:mover():set_gravity(Vector3(0, 0, -982))
	end

	self._ext_movement:on_exit_ladder()
	self._unit:sound():play("footstep_land")

	if alive(self._ladder_directions) then
		World:delete_unit(self._ladder_directions)

		self._ladder_directions = nil
	end

	self._state_data.last_warp_pos = nil
	self._state_data._warp_start_time = TimerManager:game():time()
end

local mvec3_zero = Vector3()

function PlayerStandardVR:_start_action_ladder(t, ladder_unit, need_warp)
	if need_warp then
		local ladder = ladder_unit:ladder()
		local u_pos = self._ext_movement:m_pos()
		local distance_bottom = mvector3.distance(u_pos, ladder:bottom())
		local distance_top = mvector3.distance(u_pos, ladder:top())
		local target = nil
		local top = ladder:top_exit()
		local bottom = ladder:bottom_exit()
		self._state_data.ladder = {
			ladder_unit = ladder_unit,
			ladder_ext = ladder,
			top = top,
			bottom = bottom,
			w_dir = ladder:w_dir(),
			t_pos = distance_bottom < distance_top and 0 or 1,
			step_length = 1 / ladder:segments(),
			update_position = function (self)
				self.current_position = self.ladder_ext:position(self.t_pos)
				self.locked_z = self.current_position.z
			end,
			timer = t
		}

		self._state_data.ladder:update_position()

		local distance = mvector3.distance(self._unit:position(), self._state_data.ladder.current_position)
		self._state_data._warp_distance = distance
		self._state_data._warp_cost = distance / self._state_data._wanted_husk_speed or 0
		self._state_data._warp_target = self._state_data.ladder.current_position
		self._state_data._warp_type = WARP_TYPE_MOVE
		self._state_data.warping_to_ladder = true

		self:_start_action_warp(t)
	else
		self._ext_movement:on_enter_ladder(self._state_data.ladder.ladder_unit)

		self._state_data.on_ladder = true
		self._state_data.warping_to_ladder = nil

		self._unit:mover():set_gravity(Vector3(0, 0, 0))

		self._ladder_directions = World:spawn_unit(Idstring("units/pd2_dlc_vr/player/vr_ladder_directions"), self._state_data.ladder.current_position, self._state_data.ladder.ladder_unit:rotation())

		self._ladder_directions:damage():run_sequence_simple("ladder_hide")
	end
end

function PlayerStandardVR:_start_action_zipline(t, input, zipline_unit)
	if managers.vr:get_setting("zipline_screen") then
		self._camera_unit:base():set_hmd_tracking(false)
		managers.menu:open_menu("zipline")

		self._zipline_screen_active = true
	end

	__start_action_zipline_standard(self, t, input, zipline_unit)
end

function PlayerStandardVR:_end_action_zipline(t)
	if self._zipline_screen_active then
		managers.menu:close_menu("zipline")
		managers.overlay_effect:play_effect(tweak_data.overlay_effects.fade_in)
		self._camera_unit:base():set_hmd_tracking(true)

		self._zipline_screen_active = false
	end

	__end_action_zipline_standard(self, t)
end

function PlayerStandardVR:get_fire_weapon_position()
	return self._equipped_unit:base():fire_object():position()
end

function PlayerStandardVR:get_fire_weapon_direction()
	return self._equipped_unit:base():fire_object():rotation():y()
end

function PlayerStandardVR:enter(state_data, enter_data)
	__enter_standard(self, state_data, enter_data)

	self._camera_base_rot = self._camera_unit:base():base_rotation()

	managers.vr:add_setting_changed_callback("zipline_screen", self._zipline_screen_setting_changed_clbk)
end

function PlayerStandardVR:exit(state_data, new_state_name)
	self._warp_state_machine:_set_state(WarpIdleState)
	managers.vr:remove_setting_changed_callback("zipline_screen", self._zipline_screen_setting_changed_clbk)

	return __exit_standard(self, state_data, new_state_name)
end

function PlayerStandardVR:_update_network_jump(pos, is_exit, t, dt)
	if self._is_jumping then
		if self._jump_timer < self._jump_time and not is_exit then
			local jump_vec = mvector3.copy(self._jump_vec)

			mvector3.multiply(jump_vec, self._jump_timer)

			local z = jump_vec.z - 491 * self._jump_timer * self._jump_timer

			if t then
				mvector3.set_z(jump_vec, z)

				local v = mvector3.copy(jump_vec)

				mvector3.add(v, self._jump_start_pos)
				self:_update_network_position(t, dt, v)
			end
		else
			self._is_jumping = false

			self._ext_network:send("action_walk_nav_point", self._jump_end_pos)
		end
	end
end

function PlayerStandardVR:_update_network_position(t, dt, cur_pos, pos_new)
	if (not self._last_sent_pos_t or t - self._last_sent_pos_t > 1 / tweak_data.network.player_tick_rate) and (not pos_new or mvector3.distance_sq(self._last_sent_pos, pos_new) > 2500) then
		self._ext_network:send("action_walk_nav_point", cur_pos)

		self._last_sent_pos_t = t

		mvector3.set(self._last_sent_pos, cur_pos)
	end
end

function PlayerStandardVR:_get_melee_charge_lerp_value(t, offset)
	local melee_hand = self._unit:hand():get_active_hand_id("melee")

	if not melee_hand then
		return 0
	end

	local melee_start_t = self._unit:hand():hand_unit(melee_hand):melee():charge_start_t()

	if not melee_start_t then
		return 0
	end

	offset = offset or 0
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local max_charge_time = tweak_data.blackmarket.melee_weapons[melee_entry].stats.charge_time

	return math.clamp(t - melee_start_t - offset, 0, max_charge_time) / max_charge_time
end

local __get_input = PlayerStandard._get_input

function PlayerStandardVR:_get_input(t, dt, paused)
	local input = __get_input(self, t, dt, paused)

	if self._controller:enabled() and not paused then
		input.btn_unequip_press = self._controller:get_input_pressed("unequip")
		input.btn_unequip_release = self._controller:get_input_released("unequip")
		input.btn_akimbo_fire_press = self._controller:get_input_pressed("akimbo_fire")
		input.btn_akimbo_fire_state = self._controller:get_input_bool("akimbo_fire")
		input.btn_akimbo_fire_release = self._controller:get_input_released("akimbo_fire")
		input.btn_interact_left_press = self._controller:get_input_pressed("interact_left")
		input.btn_interact_left_release = self._controller:get_input_released("interact_left")
		input.btn_interact_right_press = self._controller:get_input_pressed("interact_right")
		input.btn_interact_right_release = self._controller:get_input_released("interact_right")
		input.btn_interact_press = input.btn_interact_left_press or input.btn_interact_right_press
		input.btn_interact_release = input.btn_interact_left_release or input.btn_interact_right_release
	end

	return input
end

function PlayerStandardVR:_is_throwing_projectile(input)
	if not input then
		return false
	end

	if self._throwing_projectile_id then
		local weapon_hand_id = self._unit:hand():get_active_hand_id("weapon")

		if weapon_hand_id and weapon_hand_id == self._throwing_projectile_id then
			if input.btn_primary_attack_state then
				return true
			else
				self._throwing_projectile_id = nil
			end
		end

		local akimbo_hand_id = self._unit:hand():get_active_hand_id("akimbo")

		if akimbo_hand_id and akimbo_hand_id == self._throwing_projectile_id then
			if input.btn_akimbo_fire_state then
				return true
			else
				self._throwing_projectile_id = nil
			end
		end
	end

	return false
end

function PlayerStandardVR:set_throwing_projectile(id)
	self._throwing_projectile_id = id
end

function PlayerStandardVR:_check_stop_shooting()
	if self._shooting and self._shooting_weapons then
		self._camera_unit:base():stop_shooting(self._equipped_unit:base():recoil_wait())

		for k, weap_base in pairs(self._shooting_weapons) do
			weap_base:stop_shooting()
			self._ext_network:send("sync_stop_auto_fire_sound")

			self._shooting_weapons[k] = nil
		end

		if not next(self._shooting_weapons) then
			self._shooting = false
			self._shooting_t = nil
		end
	end
end

function PlayerStandardVR:_check_action_primary_attack(t, input)
	local new_action = nil
	local action_wanted = input.btn_primary_attack_state or input.btn_primary_attack_release or input.btn_akimbo_fire_state or input.btn_akimbo_fire_release

	if action_wanted then
		local action_forbidden = self:_changing_weapon() or self:_is_meleeing() or self:_is_throwing_projectile(input) or self:_is_deploying_bipod() or self:is_switching_stances()

		if not action_forbidden then
			self._queue_reload_interupt = nil

			self._ext_inventory:equip_selected_primary(false)

			local weapon_hand_id = self._unit:hand():get_active_hand_id("weapon")

			if self._equipped_unit then
				if table.contains(self._equipped_unit:base():weapon_tweak_data().categories, "bow") then
					local bow_hand_id = self._unit:hand():get_active_hand_id("bow")

					if not bow_hand_id or not self._unit:hand():current_hand_state(bow_hand_id):can_grip_string() then
						input.btn_primary_attack_press = nil
						input.btn_primary_attack_state = nil
						input.btn_primary_attack_release = nil
					end
				end

				if self._equipped_unit:base().akimbo then
					new_action = self:_check_fire_per_weapon(t, input.btn_akimbo_fire_press, input.btn_akimbo_fire_state, input.btn_akimbo_fire_release, self._equipped_unit:base()._second_gun:base(), true) or new_action
				end

				new_action = self:_check_fire_per_weapon(t, input.btn_primary_attack_press, input.btn_primary_attack_state, input.btn_primary_attack_release, self._equipped_unit:base()) or new_action
			end
		elseif self:_is_reloading() and self._equipped_unit:base():reload_interuptable() and (input.btn_primary_attack_press or input.btn_akimbo_fire_press) then
			self._queue_reload_interupt = true
		end
	end

	if not new_action then
		self:_check_stop_shooting()
	end
end

function PlayerStandardVR:_check_fire_per_weapon(t, pressed, held, released, weap_base, akimbo)
	if not pressed and not held and not released then
		return false
	end

	local new_action = false
	local start_shooting = false
	local fire_mode = weap_base:fire_mode()
	local fire_on_release = weap_base:fire_on_release()

	if weap_base:out_of_ammo() or self:_is_reloading() then
		if pressed then
			weap_base:dryfire()
		end
	elseif weap_base.clip_empty and weap_base:clip_empty() then
		if self:_interacting() then
			return false
		end

		local should_reload_immediately = self._equipped_unit:base().should_reload_immediately and self._equipped_unit:base():should_reload_immediately()

		if self:_is_using_bipod() or not managers.vr:get_setting("auto_reload") and not should_reload_immediately then
			if pressed then
				weap_base:dryfire()
			end

			weap_base:tweak_data_anim_stop("fire")
		elseif fire_mode == "single" then
			if pressed or should_reload_immediately then
				self:_start_action_reload_enter(t)
			end
		else
			new_action = true

			self:_start_action_reload_enter(t)
		end
	else
		if self._running and not self._equipped_unit:base():run_and_shoot_allowed() then
			self:_interupt_action_running(t)
		end

		if not self._shooting or not self._shooting_weapons or not self._shooting_weapons[akimbo and 2 or 1] then
			if not self._next_wall_check_t or self._next_wall_check_t < t then
				local wall_check_obj = tweak_data.vr.custom_wall_check[weap_base.name_id] and weap_base._unit:get_object(Idstring(tweak_data.vr.custom_wall_check[weap_base.name_id])) or weap_base:fire_object()
				self._shooting_forbidden = self._unit:hand():check_hand_through_wall(self._unit:hand():get_active_hand_id(akimbo and "akimbo" or "weapon"), wall_check_obj)
				local weapon_tweak = weap_base:weapon_tweak_data()
				local delay = weapon_tweak.auto and weapon_tweak.auto.fire_rate or tweak_data.vr.wall_check_delay
				self._next_wall_check_t = t + delay
			end

			if weap_base:start_shooting_allowed() and not self._shooting_forbidden then
				local start = fire_mode == "single" and pressed
				start = start or fire_mode ~= "single" and held
				start = start and not fire_on_release
				start = start or fire_on_release and released

				if start then
					weap_base:start_shooting()
					self._camera_unit:base():start_shooting()

					self._shooting = true
					self._shooting_weapons = self._shooting_weapons or {}
					self._shooting_weapons[akimbo and 2 or 1] = weap_base
					self._shooting_t = t
					start_shooting = true

					if fire_mode == "auto" and (not weap_base.third_person_important or weap_base.third_person_important and not weap_base:third_person_important()) then
						self._ext_network:send("sync_start_auto_fire_sound")
					end
				end
			else
				return false
			end
		end

		local suppression_ratio = self._unit:character_damage():effective_suppression_ratio()
		local spread_mul = math.lerp(1, tweak_data.player.suppression.spread_mul, suppression_ratio)
		local autohit_mul = math.lerp(1, tweak_data.player.suppression.autohit_chance_mul, suppression_ratio)
		local suppression_mul = managers.blackmarket:threat_multiplier()
		local dmg_mul = managers.player:temporary_upgrade_value("temporary", "dmg_multiplier_outnumbered", 1)

		if managers.player:has_category_upgrade("player", "overkill_all_weapons") or weap_base:is_category("shotgun", "saw") then
			dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "overkill_damage_multiplier", 1)
		end

		local health_ratio = self._ext_damage:health_ratio()
		local primary_category = weap_base:weapon_tweak_data().categories[1]
		local damage_health_ratio = managers.player:get_damage_health_ratio(health_ratio, primary_category)

		if damage_health_ratio > 0 then
			local upgrade_name = weap_base:is_category("saw") and "melee_damage_health_ratio_multiplier" or "damage_health_ratio_multiplier"
			local damage_ratio = damage_health_ratio
			dmg_mul = dmg_mul * (1 + managers.player:upgrade_value("player", upgrade_name, 0) * damage_ratio)
		end

		dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "berserker_damage_multiplier", 1)
		dmg_mul = dmg_mul * managers.player:get_property("trigger_happy", 1)
		local fired = nil

		if fire_mode == "single" then
			if pressed and start_shooting then
				fired = weap_base:trigger_pressed(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
			elseif fire_on_release then
				if released then
					fired = weap_base:trigger_released(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)

					if fired then
						self:_start_action_reload_enter(t)
					end
				elseif held then
					weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
				end
			end
		elseif held then
			if not self._next_wall_check_t or self._next_wall_check_t < t then
				local wall_check_obj = tweak_data.vr.custom_wall_check[weap_base.name_id] and weap_base._unit:get_object(Idstring(tweak_data.vr.custom_wall_check[weap_base.name_id])) or weap_base:fire_object()
				self._shooting_forbidden = self._unit:hand():check_hand_through_wall(self._unit:hand():get_active_hand_id(akimbo and "akimbo" or "weapon"), wall_check_obj)
				self._next_wall_check_t = t + tweak_data.vr.wall_check_delay
			end

			if not self._shooting_forbidden then
				fired = weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
			end
		end

		new_action = true

		if fired then
			local engine = self._unit:hand():get_active_hand_id(akimbo and "akimbo" or "weapon") == 1 and "right" or "left"

			managers.rumble:play("weapon_fire", nil, nil, {
				engine = engine
			})

			local weap_tweak_data = tweak_data.weapon[weap_base:get_name_id()]
			local shake_multiplier = weap_tweak_data.shake[self._state_data.in_steelsight and "fire_steelsight_multiplier" or "fire_multiplier"]

			self._ext_camera:play_shaker("fire_weapon_rot", 1 * shake_multiplier)
			self._ext_camera:play_shaker("fire_weapon_kick", 1 * shake_multiplier, 1, 0.15)
			weap_base:tweak_data_anim_stop("unequip")
			weap_base:tweak_data_anim_stop("equip")
			weap_base:tweak_data_anim_play("fire", weap_base:fire_rate_multiplier())

			if fire_mode == "single" and weap_base:get_name_id() ~= "saw" then
				if not self._state_data.in_steelsight then
					self._ext_camera:play_redirect(self:get_animation("recoil"), weap_base:fire_rate_multiplier())
				elseif weap_tweak_data.animations.recoil_steelsight then
					self._ext_camera:play_redirect(weap_base:is_second_sight_on() and self:get_animation("recoil") or self:get_animation("recoil_steelsight"), 1)
				end
			end

			local recoil_multiplier = (weap_base:recoil() + weap_base:recoil_addend()) * weap_base:recoil_multiplier()
			local up, down, left, right = unpack(weap_tweak_data.kick[self._state_data.in_steelsight and "steelsight" or self._state_data.ducking and "crouching" or "standing"])

			self._camera_unit:base():recoil_kick(up * recoil_multiplier, down * recoil_multiplier, left * recoil_multiplier, right * recoil_multiplier)
			self._unit:hand():apply_weapon_kick(weap_base._current_stats.recoil, akimbo)

			if self._shooting_t then
				local time_shooting = t - self._shooting_t
				local achievement_data = tweak_data.achievement.never_let_you_go

				if achievement_data and weap_base:get_name_id() == achievement_data.weapon_id and achievement_data.timer <= time_shooting then
					managers.achievment:award(achievement_data.award)

					self._shooting_t = nil
				end
			end

			if managers.player:has_category_upgrade(primary_category, "stacking_hit_damage_multiplier") then
				self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
				self._state_data.stacking_dmg_mul[primary_category] = self._state_data.stacking_dmg_mul[primary_category] or {
					nil,
					0
				}
				local stack = self._state_data.stacking_dmg_mul[primary_category]

				if fired.hit_enemy then
					stack[1] = t + managers.player:upgrade_value(primary_category, "stacking_hit_expire_t", 1)
					stack[2] = math.min(stack[2] + 1, tweak_data.upgrades.max_weapon_dmg_mul_stacks or 5)
				else
					stack[1] = nil
					stack[2] = 0
				end
			end

			if weap_base.set_recharge_clbk then
				weap_base:set_recharge_clbk(callback(self, self, "weapon_recharge_clbk_listener"))
			end

			managers.hud:set_ammo_amount(weap_base:selection_index(), weap_base:ammo_info())

			local impact = not fired.hit_enemy

			if weap_base.third_person_important and weap_base:third_person_important() then
				self._ext_network:send("shot_blank_reliable", impact)
			elseif fire_mode == "single" or weap_base.akimbo then
				self._ext_network:send("shot_blank", impact)
			end
		elseif fire_mode == "single" or self._shooting_forbidden then
			new_action = false
		end
	end

	if new_action then
		local rot = Rotation(weap_base._unit:rotation():y(), math.UP)
		local yaw = rot:yaw() % 360

		if yaw < 0 then
			yaw = 360 - yaw
		end

		yaw = math.floor(255 * yaw / 360)
		local pitch = math.clamp(rot:pitch(), -85, 85) + 85
		pitch = math.floor(127 * pitch / 170)

		self._unit:network():send("set_look_dir", yaw, pitch)
		self._unit:camera():set_forced_sync_delay(t + 1)
	end

	return new_action
end

function PlayerStandardVR:_check_action_weapon_gadget(t, input)
	if input.btn_weapon_gadget_press then
		if self._equipped_unit:base().akimbo then
			self:_toggle_gadget(self._equipped_unit:base()._second_gun:base())
		end

		self:_toggle_gadget(self._equipped_unit:base())
	end
end

local tmp_head_fwd = Vector3(0, 0, 0)

function PlayerStandardVR:_check_action_steelsight(t, input)
	local function check_weapon_aim(weapon_unit)
		if self._ext_movement:m_head_pos().z - weapon_unit:position().z > 20 or weapon_unit:position().z - self._ext_movement:m_head_pos().z > 0 then
			return false
		end

		mvector3.set(tmp_head_fwd, self._ext_movement:m_head_rot():y())

		if mvector3.angle(tmp_head_fwd, weapon_unit:rotation():y()) > 35 then
			return false
		end

		return true
	end

	if alive(self._equipped_unit) then
		local steelsight_wanted = check_weapon_aim(self._equipped_unit)

		if steelsight_wanted and not self._state_data.in_steelsight then
			self._ext_network:send("set_stance", 3, false, false)
		elseif not steelsight_wanted and self._state_data.in_steelsight then
			self._ext_network:send("set_stance", 2, false, false)
		end

		self._state_data.in_steelsight = steelsight_wanted

		return
	end

	self._state_data.in_steelsight = false
end

function PlayerStandardVR:_start_action_steelsight(t, gadget_state)
	if gadget_state ~= nil then
		self._equipped_unit:base():play_sound("gadget_steelsight_" .. (gadget_state and "enter" or "exit"))
	end
end

function PlayerStandardVR:_update_fwd_ray()
	if alive(self._equipped_unit) then
		local from = self._equipped_unit:position()
		local range = self._equipped_unit:base():has_range_distance_scope() and 20000 or 4000
		local to = self._equipped_unit:rotation():y() * range

		mvector3.add(to, from)

		self._fwd_ray = World:raycast("ray", from, to, "slot_mask", self._slotmask_fwd_ray)

		if self._state_data.in_steelsight and self._fwd_ray and self._fwd_ray.unit and self._equipped_unit:base().check_highlight_unit then
			self._equipped_unit:base():check_highlight_unit(self._fwd_ray.unit)
		end

		if self._equipped_unit:base().set_scope_range_distance then
			self._equipped_unit:base():set_scope_range_distance(self._fwd_ray and self._fwd_ray.distance / 100 or false)
		end
	end
end

function PlayerStandardVR:_start_action_unequip_weapon(t, data)
	local _, selection_wanted = nil

	if data.next then
		_, selection_wanted = self._ext_inventory:get_next_selection()
	elseif data.previous then
		_, selection_wanted = self._ext_inventory:get_previous_selection()
	else
		selection_wanted = data.selection_wanted
	end

	if selection_wanted then
		self._ext_inventory:equip_selection(selection_wanted, false)
		self:swap_weapon(selection_wanted)
	end
end

function PlayerStandardVR:swap_weapon(selection_wanted)
	if self._ext_inventory:is_equipped(selection_wanted) then
		return
	end

	local t = managers.player:player_timer():time()

	self:_interupt_action_reload(t)

	local speed_multiplier = self:_get_swap_speed_multiplier()

	self._ext_network:send("switch_weapon", speed_multiplier, 1)
end

local __is_reloading = PlayerStandard._is_reloading

function PlayerStandardVR:_is_reloading()
	return __is_reloading(self) or self._can_trigger_reload
end

function PlayerStandardVR:_start_action_reload_enter(t)
	if self._equipped_unit:base():can_reload() then
		managers.player:send_message_now(Message.OnPlayerReload, nil, self._equipped_unit)
		self:_start_action_reload(t)
	end
end

function PlayerStandardVR:_start_action_reload(t)
	local weapon = self._equipped_unit:base()

	if weapon and weapon:can_reload() then
		weapon:tweak_data_anim_stop("fire")

		local speed_multiplier = weapon:reload_speed_multiplier()
		local empty_reload = weapon:clip_empty() and 1 or 0

		if weapon._use_shotgun_reload then
			empty_reload = weapon:get_ammo_max_per_clip() - weapon:get_ammo_remaining_in_clip()
		end

		local reload_time = 0

		if weapon:reload_enter_expire_t() then
			reload_time = reload_time + weapon:reload_enter_expire_t() / speed_multiplier
		end

		if weapon:reload_exit_expire_t() then
			if weapon:started_reload_empty() then
				reload_time = reload_time + weapon:reload_exit_expire_t() / speed_multiplier
			else
				reload_time = reload_time + weapon:reload_not_empty_exit_expire_t() / speed_multiplier
			end
		end

		local tweak = weapon:weapon_tweak_data()
		reload_time = weapon:clip_empty() and reload_time + (tweak.timers.reload_empty or weapon:reload_expire_t() or 2.6) / speed_multiplier or reload_time + (tweak.timers.reload_not_empty or weapon:reload_expire_t() or 2.2) / speed_multiplier

		if not managers.vr:get_setting("auto_reload") then
			if table.contains(tweak.categories, "bow") then
				reload_time = 0
			else
				reload_time = reload_time - tweak_data.vr.reload_buff
			end
		end

		self._state_data.reload_start_t = t
		self._state_data.reload_expire_t = t + reload_time

		weapon:start_reload(reload_time)
		self._ext_network:send("reload_weapon", empty_reload, speed_multiplier)

		if not managers.vr:get_setting("auto_reload") then
			if weapon:is_category("saw") then
				managers.hud:belt():start_reload(reload_time, 0, 1)

				self._state_data.needs_full_reload = true
			else
				local max_ammo = math.min(weapon:get_ammo_max_per_clip(), weapon:get_ammo_total())

				managers.hud:belt():start_reload(reload_time, weapon:get_ammo_remaining_in_clip(), max_ammo)
			end
		end

		managers.hud:set_reload_visible(true)
	end
end

function PlayerStandardVR:_interupt_action_reload(t)
	if alive(self._equipped_unit) then
		self._equipped_unit:base():check_bullet_objects()
		self._equipped_unit:base():stop_reload()
	end

	managers.hud:belt():trigger_reload()
	managers.hud:set_reload_visible(false)

	self._can_trigger_reload = nil
	self._state_data.reload_expire_t = nil
	self._state_data.needs_full_reload = nil

	managers.player:remove_property("shock_and_awe_reload_multiplier")
	self:send_reload_interupt()
end

function PlayerStandardVR:_update_reload_timers(t, dt, input)
	if not alive(self._equipped_unit) then
		return
	end

	if self._state_data.reload_expire_t then
		local total = self._state_data.reload_expire_t - self._state_data.reload_start_t
		local current = t - self._state_data.reload_start_t

		managers.hud:set_reload_timer(current, total)

		local interupt = nil

		if self._equipped_unit:base():update_reloading(t, dt, self._state_data.reload_expire_t - t) then
			managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())

			if self._queue_reload_interupt then
				self._queue_reload_interupt = nil
				interupt = true
			end
		end

		if self._state_data.reload_expire_t <= t or interupt then
			managers.player:remove_property("shock_and_awe_reload_multiplier")

			self._state_data.reload_expire_t = nil
			self._can_trigger_reload = true

			if managers.vr:get_setting("auto_reload") then
				self:trigger_reload()
				managers.hud:belt():trigger_reload()
			end
		end
	end

	if self._equipped_unit:base():is_finishing_reload() then
		self._equipped_unit:base():update_reload_finish(t, dt)
	end
end

function PlayerStandardVR:_current_reload_amount()
	if self._state_data.reload_expire_t then
		local t = TimerManager:game():time()
		local weapon = self._equipped_unit:base()
		local total = self._state_data.reload_expire_t - self._state_data.reload_start_t
		local progress = t - self._state_data.reload_start_t
		local ratio = progress / total
		local max_ammo = math.min(weapon:get_ammo_max_per_clip(), weapon:get_ammo_total())

		return math.floor((max_ammo - weapon:get_ammo_remaining_in_clip()) * ratio) + weapon:get_ammo_remaining_in_clip()
	end
end

function PlayerStandardVR:grab_mag()
	if not self:can_grab_mag() then
		return false
	end

	local weapon = self._equipped_unit:base()
	local amount = self:_current_reload_amount()

	if weapon.akimbo then
		local second_gun = weapon._second_gun

		second_gun:base():on_enabled()
		weapon._unit:link(weapon._unit:orientation_object():name(), second_gun, second_gun:orientation_object():name())
		second_gun:set_local_position(Vector3(-5, 0, 0))
		second_gun:base():set_visibility_state(true)
	end

	self._reload_amount = amount
	self._can_trigger_reload = true

	managers.hud:set_reload_visible(false)
end

function PlayerStandardVR:can_trigger_reload()
	return self._can_trigger_reload
end

function PlayerStandardVR:can_grab_mag()
	local amount = self:_current_reload_amount()

	return not managers.vr:get_setting("auto_reload") and (not self._state_data.needs_full_reload or self:can_trigger_reload()) and (not amount or amount > 0)
end

function PlayerStandardVR:trigger_reload()
	if not self:can_trigger_reload() then
		return
	end

	if self._equipped_unit then
		self._equipped_unit:base():on_reload(self._reload_amount)
		managers.statistics:reloaded()
		managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())
	end

	local engine = self._unit:hand():get_default_hand_id("weapon") == 1 and "right" or "left"

	managers.rumble:play("reloaded", nil, nil, {
		engine = engine
	})

	self._can_trigger_reload = false
	self._reload_amount = nil
	self._state_data.reload_expire_t = nil

	managers.hud:set_reload_visible(false)
	self._ext_movement:reset_next_reload_speed_multiplier()
end

function PlayerStandardVR:_play_equip_animation()
end

function PlayerStandardVR:_play_unequip_animation()
end

local __start_action_interact = PlayerStandard._start_action_interact

function PlayerStandardVR:_start_action_interact(t, input, timer, interact_object)
	managers.hud:link_interaction_hud(self._unit:hand():hand_unit(self._interact_hand), interact_object)

	self._state_data.interacting = true

	__start_action_interact(self, t, input, timer, interact_object)
end

local __interupt_action_interact = PlayerStandard._interupt_action_interact

function PlayerStandardVR:_interupt_action_interact(t, input, complete)
	self._state_data.interacting = false

	__interupt_action_interact(self, t, input, complete)
end

local __start_action_use_item = PlayerStandard._start_action_use_item

function PlayerStandardVR:_start_action_use_item(...)
	managers.hud:link_interaction_hud(self._unit:hand():get_active_hand("deployable") or self._unit:hand():get_active_hand("weapon"), self._unit:equipment():dummy_unit())
	__start_action_use_item(self, ...)
end

function PlayerStandardVR:_start_action_throw_projectile(...)
	local hand_id = self._unit:hand():get_active_hand_id("throwable") or self._unit:hand():get_active_hand_id("weapon")

	if not managers.player:player_unit():hand():check_hand_through_wall(hand_id) then
		self._unit:equipment():throw_projectile(self._unit:hand():hand_unit(hand_id))
	end
end

PlayerStandardVR._start_action_throw_grenade = PlayerStandardVR._start_action_throw_projectile

function PlayerStandardVR:_on_zipline_screen_setting_changed(setting, old, new)
	if not self:_on_zipline() then
		return
	end

	if new then
		self._camera_unit:base():set_hmd_tracking(false)
		managers.menu:open_menu("zipline", 1)

		self._zipline_screen_active = true
	elseif self._zipline_screen_active then
		managers.menu:close_menu("zipline")
		self._camera_unit:base():set_hmd_tracking(true)

		self._zipline_screen_active = false
	end
end

function PlayerStandardVR:_on_menu_active_changed_vr(active)
	if not alive(self._unit) then
		return
	end

	self._state_data._block_input = active

	self._ext_movement:set_block_input(active)
	self._ext_camera:camera_unit():base():set_block_input(active)
	self._unit:hand():set_block_input(active)
	self._ext_movement:reset_hmd_position()

	if not active then
		local rot = VRManager:hmd_rotation()

		self._ext_camera:camera_unit():base():reset_base_rotation(Rotation(-rot:yaw(), 0, 0))
		self._unit:hand():set_base_rotation(self._camera_unit:base():base_rotation())

		self._camera_base_rot = self._camera_unit:base():base_rotation()
	end
end

function PlayerStandardVR:set_base_rotation(rot)
	self._ext_camera:camera_unit():base():set_base_rotation(Rotation(rot:yaw(), 0, 0))
	self._unit:hand():set_base_rotation(self._camera_unit:base():base_rotation())

	self._camera_base_rot = self._camera_unit:base():base_rotation()
end
