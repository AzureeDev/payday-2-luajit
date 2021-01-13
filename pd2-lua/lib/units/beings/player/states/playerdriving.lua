PlayerDriving = PlayerDriving or class(PlayerStandard)
PlayerDriving.IDS_STEER_LEFT_REDIRECT = Idstring("steering_wheel_left")
PlayerDriving.IDS_STEER_LEFT_STATE = Idstring("fps/wheel_turn_left")
PlayerDriving.IDS_STEER_RIGHT_REDIRECT = Idstring("steering_wheel_right")
PlayerDriving.IDS_STEER_RIGHT_STATE = Idstring("fps/wheel_turn_right")
PlayerDriving.IDS_STEER_IDLE_REDIRECT = Idstring("steering_wheel_idle")
PlayerDriving.IDS_PASSENGER_REDIRECT = Idstring("passenger_vehicle")
PlayerDriving.EXIT_VEHICLE_TIMER = 0.4
PlayerDriving.STANCE_NORMAL = 0
PlayerDriving.STANCE_SHOOTING = 1

function PlayerDriving:init(unit)
	PlayerDriving.super.init(self, unit)

	self._vehicle = nil
	self._dt = 0
	self._move_x = 0
	self._stance = PlayerDriving.STANCE_NORMAL
	self._wheel_idle = false
	self._respawn_hint_shown = false
end

function PlayerDriving:enter(state_data, enter_data)
	PlayerDriving.super.enter(self, state_data, enter_data)

	for _, ai in pairs(managers.groupai:state():all_AI_criminals()) do
		if ai.unit:movement() and ai.unit:movement()._should_stay then
			ai.unit:movement():set_should_stay(false)
		end
	end

	self._was_unarmed = enter_data and enter_data.was_unarmed
end

function PlayerDriving:_enter(enter_data)
	self:_get_vehicle()

	if self._vehicle == nil then
		print("[DRIVING] No vehicle found")

		return
	end

	if self._vehicle_ext:get_view() == nil then
		print("[DRIVING] No vehicle view point found")

		return
	end

	self._seat = self._vehicle_ext:find_seat_for_player(self._unit)
	self._wheel_idle = false

	self:_postion_player_on_seat(self._seat)
	self._unit:inventory():add_listener("PlayerDriving", {
		"equip"
	}, callback(self, self, "on_inventory_event"))

	self._current_weapon = self._unit:inventory():equipped_unit()

	if self._current_weapon then
		table.insert(self._current_weapon:base()._setup.ignore_units, self._vehicle_unit)
	end

	if self._seat.driving then
		self:_set_camera_limits("driving")

		local use_fps_material = true
		use_fps_material = not _G.IS_VR

		if use_fps_material and self._vehicle_unit:damage():has_sequence("local_driving_enter") then
			self._vehicle_unit:damage():run_sequence("local_driving_enter")
		end

		self._camera_unit:anim_state_machine():set_global(self._vehicle_ext._tweak_data.animations.vehicle_id, 1)
	else
		self:_set_camera_limits("passenger")

		if not self._seat.allow_shooting then
			self._unit:camera():play_redirect(self.IDS_PASSENGER_REDIRECT)
		end
	end

	self._unit:camera():set_shaker_parameter("breathing", "amplitude", 0)
	self._unit:camera()._camera_unit:base():animate_fov(self._vehicle_ext._tweak_data.fov, 0.33)

	self._controller = self._unit:base():controller()

	managers.controller:set_ingame_mode("driving")
	self:_upd_attention()
end

function PlayerDriving:exit(state_data, new_state_name)
	print("[DRIVING] PlayerDriving: Exiting vehicle")
	PlayerDriving.super.exit(self, state_data, new_state_name)

	if self._vehicle_unit:camera() then
		self._vehicle_unit:camera():deactivate(self._unit)
	end

	self:_interupt_action_exit_vehicle()
	self:_interupt_action_steelsight()

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		self:_interupt_action_throw_grenade()
	else
		self:_interupt_action_throw_projectile()
	end

	self:_interupt_action_reload()
	self:_interupt_action_charging_weapon()
	self:_interupt_action_melee()

	local exit_position = self._vehicle_ext:find_exit_position(self._unit)

	if exit_position then
		local exit_rot = exit_position:rotation()

		self._unit:set_rotation(exit_rot)
		self._unit:camera():set_rotation(exit_rot)

		local pos = exit_position:position() + Vector3(0, 0, 30)

		self._unit:set_position(pos)
		self._unit:camera():set_position(pos)

		if _G.IS_VR then
			self._unit:movement():set_ghost_position(exit_position:position())
		end

		self._unit:camera():camera_unit():base():set_spin(exit_rot:y():to_polar().spin)
		self._unit:camera():camera_unit():base():set_pitch(0)
		self._unit:camera():camera_unit():base():set_target_tilt(0)

		self._unit:camera():camera_unit():base().bipod_location = nil
	else
		Application:error("[PlayerDriving:exit] No vehicle exit position")
	end

	if self._vehicle_unit:damage():has_sequence("local_driving_exit") then
		self._vehicle_unit:damage():run_sequence("local_driving_exit")
	end

	if self._seat.driving then
		self._unit:inventory():show_equipped_unit()
	end

	if not self._was_unarmed or not managers.groupai:state():whisper_mode() then
		self._unit:camera():play_redirect(self:get_animation("equip"))
	end

	managers.player:exit_vehicle()

	self._dye_risk = nil
	self._state_data.in_air = false
	self._stance = PlayerDriving.STANCE_NORMAL
	local exit_data = {
		skip_equip = true
	}
	local velocity = self._unit:mover():velocity()

	self:_activate_mover(PlayerStandard.MOVER_STAND, velocity)
	self._ext_network:send("set_pose", 1)
	self._unit:inventory():remove_listener("PlayerDriving")

	if self._current_weapon then
		table.delete(self._current_weapon:base()._setup.ignore_units, self._vehicle_unit)
	end

	self:_upd_attention()
	self:_remove_camera_limits()
	self._camera_unit:base():animate_fov(75, 0.33)
	self._camera_unit:anim_state_machine():set_global(self._vehicle_ext._tweak_data.animations.vehicle_id, 0)
	managers.controller:set_ingame_mode("main")

	return exit_data
end

function PlayerDriving:_create_on_controller_disabled_input()
	local input = PlayerDriving.super._create_on_controller_disabled_input(self)
	input.btn_vehicle_rear_camera_release = true

	return input
end

function PlayerDriving:_get_input(t, dt)
	local input = PlayerDriving.super._get_input(self, t, dt)

	if not next(input) or input.is_customized then
		return input
	end

	input.btn_vehicle_change_camera = input.any_input_pressed and self._controller:get_input_pressed("vehicle_change_camera")
	input.btn_vehicle_rear_camera_press = input.any_input_pressed and self._controller:get_input_pressed("vehicle_rear_camera")
	input.btn_vehicle_rear_camera_release = input.any_input_released and self._controller:get_input_released("vehicle_rear_camera")
	input.btn_vehicle_shooting_stance = input.any_input_pressed and self._controller:get_input_pressed("vehicle_shooting_stance")
	input.btn_vehicle_exit_press = input.any_input_pressed and self._controller:get_input_pressed("vehicle_exit")
	input.btn_vehicle_exit_release = input.any_input_released and self._controller:get_input_released("vehicle_exit")

	return input
end

function PlayerDriving:update(t, dt)
	if self._vehicle == nil then
		print("[DRIVING] No in a vehicle")

		return
	elseif not self._vehicle:is_active() then
		print("[DRIVING] The vehicle is not active")

		return
	end

	if self._controller == nil then
		print("[DRIVING] No controller available")

		return
	end

	self:_update_input(dt)

	local input = self:_get_input(t, dt)

	self:_calculate_standard_variables(t, dt)
	self:_update_ground_ray()
	self:_update_fwd_ray()
	self:_check_action_change_camera(t, input)
	self:_check_action_rear_cam(t, input)
	self:_update_hud(t, input)
	self:_update_action_timers(t, input)
	self:_check_action_exit_vehicle(t, input)

	if self._menu_closed_fire_cooldown > 0 then
		self._menu_closed_fire_cooldown = self._menu_closed_fire_cooldown - dt
	end

	if self._seat.driving then
		self:_update_check_actions_driver(t, dt, input)
	elseif self._seat.allow_shooting or self._stance == PlayerDriving.STANCE_SHOOTING then
		self:_update_check_actions_passenger(t, dt, input)
	else
		self:_update_check_actions_passenger_no_shoot(t, dt, input)
	end

	self._ext_movement:set_m_pos(self._unit:position())
	self:_upd_stance_switch_delay(t, dt)
end

function PlayerDriving:set_tweak_data(name)
end

function PlayerDriving:_update_hud(t, dt)
	if self._vehicle_ext.respawn_available then
		if not self._respawn_hint_shown and self._seat.driving then
			local string_macros = {}

			BaseInteractionExt:_add_string_macros(string_macros)

			local text = managers.localization:text("hud_int_press_respawn", string_macros)
			self._respawn_hint_shown = true

			managers.hud:show_hint({
				time = 30,
				text = text
			})
		end
	elseif self._respawn_hint_shown then
		managers.hud:stop_hint()

		self._respawn_hint_shown = false
	end
end

function PlayerDriving:_update_check_actions_driver(t, dt, input)
	self:_update_equip_weapon_timers(t, input)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_check_action_night_vision(t, input)
end

function PlayerDriving:_update_check_actions_passenger(t, dt, input)
	self:_update_check_actions(t, dt)
	self:_check_action_shooting_stance(t, input)
	self:_check_action_night_vision(t, input)
end

function PlayerDriving:_update_check_actions_passenger_no_shoot(t, dt, input)
	self:_update_equip_weapon_timers(t, input)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_check_action_shooting_stance(t, input)
	self:_check_action_deploy_underbarrel(t, input)
	self:_check_action_night_vision(t, input)
end

function PlayerDriving:_check_action_jump(t, input)
	return false
end

function PlayerDriving:_check_action_interact(t, input)
	return false
end

function PlayerDriving:_check_action_duck()
	return false
end

function PlayerDriving:_check_use_item()
	return false
end

function PlayerDriving:interaction_blocked()
	return true
end

function PlayerDriving:_check_action_shooting_stance(t, input)
	if self._vehicle_ext:shooting_stance_allowed() then
		if input.btn_vehicle_shooting_stance and self._seat.shooting_pos and self._seat.has_shooting_mode and not self._unit:base():stats_screen_visible() then
			if self._stance == PlayerDriving.STANCE_NORMAL then
				self:_enter_shooting_stance()
			else
				self:_exit_shooting_stance()
			end

			self._ext_network:send("sync_vehicle_change_stance", self._stance)
		end
	elseif self._stance == PlayerDriving.STANCE_SHOOTING then
		self:_exit_shooting_stance()
	end
end

function PlayerDriving:_enter_shooting_stance()
	self._stance = PlayerDriving.STANCE_SHOOTING

	self:_postion_player_on_seat()
	self:_set_camera_limits("shooting")
	self._unit:camera():play_redirect(self:get_animation("equip"))
	managers.controller:set_ingame_mode("main")
end

function PlayerDriving:_exit_shooting_stance()
	self._stance = PlayerDriving.STANCE_NORMAL

	self:_postion_player_on_seat(self._seat)
	self:_set_camera_limits("passenger")

	if not self._seat.allow_shooting then
		local t = managers.player:player_timer():time()

		self:_interupt_action_steelsight()

		local projectile_entry = managers.blackmarket:equipped_projectile()

		if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
			self:_interupt_action_throw_grenade(t)
		else
			self:_interupt_action_throw_projectile(t)
		end

		self:_interupt_action_reload(t)
		self:_interupt_action_charging_weapon(t)
		self:_interupt_action_melee(t)
		self:_interupt_action_use_item(t)
		self._unit:camera():play_redirect(self.IDS_PASSENGER_REDIRECT)
	else
		self._unit:camera():play_redirect(self:get_animation("equip"))
	end

	managers.controller:set_ingame_mode("driving")
end

function PlayerDriving:_check_action_exit_vehicle(t, input)
	if input.btn_vehicle_exit_press then
		if self._vehicle_ext.respawn_available then
			if self._seat.driving then
				self._vehicle_ext:respawn_vehicle()
			elseif self._stance == PlayerDriving.STANCE_SHOOTING then
				self:_start_action_intimidate(t)
			else
				self:_start_action_exit_vehicle(t)
			end
		elseif self._stance == PlayerDriving.STANCE_SHOOTING then
			self:_start_action_intimidate(t)
		else
			self:_start_action_exit_vehicle(t)
		end
	end

	if input.btn_vehicle_exit_release then
		self:_interupt_action_exit_vehicle()
	end
end

function PlayerDriving:_start_action_exit_vehicle(t)
	if not self._vehicle_ext:allow_exit() then
		return
	end

	if self:is_deploying() then
		return
	end

	local deploy_timer = PlayerDriving.EXIT_VEHICLE_TIMER
	self._exit_vehicle_expire_t = t + deploy_timer

	managers.hud:show_progress_timer_bar(0, deploy_timer)

	local text = managers.localization:text("hud_action_exit_vehicle")

	managers.hud:show_progress_timer({
		text = text
	})
end

function PlayerDriving:_interacting()
	return PlayerDriving.super._interacting(self) or self._exit_vehicle_expire_t
end

function PlayerDriving:_interupt_action_exit_vehicle(t, input, complete)
	if self._exit_vehicle_expire_t then
		self._exit_vehicle_expire_t = nil

		managers.hud:hide_progress_timer_bar(complete)
		managers.hud:remove_progress_timer()
	end
end

function PlayerDriving:_update_action_timers(t, input)
	if self._exit_vehicle_expire_t then
		local deploy_timer = PlayerDriving.EXIT_VEHICLE_TIMER

		managers.hud:set_progress_timer_bar_width(deploy_timer - (self._exit_vehicle_expire_t - t), deploy_timer)

		if self._exit_vehicle_expire_t <= t then
			self:_end_action_exit_vehicle()

			self._exit_vehicle_expire_t = nil
		end
	end
end

function PlayerDriving:_end_action_exit_vehicle()
	managers.hud:hide_progress_timer_bar(true)
	managers.hud:remove_progress_timer()
	self:cb_leave()
end

function PlayerDriving:_check_action_change_camera(t, input)
	if not self._seat.driving then
		return
	end

	if not self._vehicle_unit:camera() then
		return
	end

	if self._vehicle_unit:camera():rear_cam_active() then
		return
	end

	if input.btn_vehicle_change_camera then
		self._vehicle_unit:camera():show_next(self._unit)
	end
end

function PlayerDriving:_check_action_rear_cam(t, input)
	if not self._seat.driving then
		return
	end

	if not self._vehicle_unit:camera() then
		return
	end

	if input.btn_vehicle_rear_camera_press then
		self._vehicle_unit:camera():set_rear_cam_active(true, self._unit)
	elseif input.btn_vehicle_rear_camera_release then
		self._vehicle_unit:camera():set_rear_cam_active(false, self._unit)
	end
end

function PlayerDriving:_check_action_run(...)
end

function PlayerDriving:stance()
	return self._stance
end

function PlayerDriving:_set_camera_limits(mode)
	if mode == "driving" then
		if not self._vehicle_ext._tweak_data.camera_limits or not self._vehicle_ext._tweak_data.camera_limits.driver then
			self._camera_unit:base():set_limits(60, 20)
		else
			self._camera_unit:base():set_limits(self._vehicle_ext._tweak_data.camera_limits.driver.yaw, self._vehicle_ext._tweak_data.camera_limits.driver.pitch)
		end
	elseif mode == "passenger" then
		if not self._vehicle_ext._tweak_data.camera_limits or not self._vehicle_ext._tweak_data.camera_limits.passenger then
			self._camera_unit:base():set_limits(80, 30)
		else
			self._camera_unit:base():set_limits(self._vehicle_ext._tweak_data.camera_limits.passenger.yaw, self._vehicle_ext._tweak_data.camera_limits.passenger.pitch)
		end
	elseif mode == "shooting" then
		if not self._vehicle_ext._tweak_data.camera_limits or not self._vehicle_ext._tweak_data.camera_limits.shooting then
			self._camera_unit:base():set_limits(nil, 40)
		else
			self._camera_unit:base():set_limits(self._vehicle_ext._tweak_data.camera_limits.shooting.yaw, self._vehicle_ext._tweak_data.camera_limits.shooting.pitch)
		end
	end
end

function PlayerDriving:_remove_camera_limits()
	self._unit:camera():camera_unit():base():remove_limits()
end

function PlayerDriving:_postion_player_on_seat(seat)
	local rot = self._seat.object:rotation()

	self._unit:set_rotation(rot)

	local pos = self._seat.object:position()

	self._unit:set_position(pos)
	self._unit:camera():set_rotation(rot)
	self._unit:camera():set_position(pos)
	self._unit:camera():camera_unit():base():set_spin(90)
	self._unit:camera():camera_unit():base():set_pitch(0)
end

function PlayerDriving:_get_vehicle()
	self._vehicle_unit = managers.player:get_vehicle().vehicle_unit

	if self._vehicle_unit == nil then
		print("[DRIVING] no vehicles found in the scene")

		return
	end

	self._vehicle_ext = self._vehicle_unit:vehicle_driving()
	self._vehicle = self._vehicle_unit:vehicle()
end

function PlayerDriving:cb_leave()
	local cant_exit = self._vehicle_ext:find_exit_position(self._unit) == nil

	if cant_exit then
		print("[DRIVING] PlayerDriving: Could not found valid exit position, aborting exit.")
		managers.hint:show_hint("cant_exit_vehicle", 3)

		return
	end

	if self._was_unarmed and managers.groupai:state():whisper_mode() then
		managers.player:set_player_state("mask_off")
	else
		self._unit:camera():play_redirect(self:get_animation("idle"))
		managers.player:set_player_state("standard")
	end
end

function PlayerDriving:_get_drive_axis()
	return self._controller:get_input_axis("drive")
end

function PlayerDriving:_update_input(dt)
	if self._seat.driving then
		local move_d = self:_get_drive_axis()
		local direction = 1
		local forced_gear = -1
		local vehicle_state = self._vehicle:get_state()
		local steer = self._vehicle:get_steer()

		if _G.IS_VR then
			steer = -move_d.x
		end

		if steer == 0 and not self._wheel_idle then
			self._unit:camera():play_redirect(self.IDS_STEER_IDLE_REDIRECT)
			self._vehicle_unit:anim_stop(Idstring("anim_steering_wheel_left"))
			self._vehicle_unit:anim_stop(Idstring("anim_steering_wheel_right"))

			self._wheel_idle = true
		end

		if steer > 0 then
			self._vehicle_unit:anim_stop(Idstring("anim_steering_wheel_right"))

			local anim_length = self._vehicle_unit:anim_length(Idstring("anim_steering_wheel_left"))

			self._vehicle_unit:anim_set_time(Idstring("anim_steering_wheel_left"), math.abs(steer) * anim_length)
			self._vehicle_unit:anim_play(Idstring("anim_steering_wheel_left"))
			self._unit:camera():play_redirect_timeblend(self.IDS_STEER_LEFT_STATE, self.IDS_STEER_LEFT_REDIRECT, 0, math.abs(steer))

			self._wheel_idle = false
		end

		if steer < 0 then
			self._vehicle_unit:anim_stop(Idstring("anim_steering_wheel_left"))

			local anim_length = self._vehicle_unit:anim_length(Idstring("anim_steering_wheel_right"))

			self._vehicle_unit:anim_set_time(Idstring("anim_steering_wheel_right"), math.abs(steer) * anim_length)
			self._vehicle_unit:anim_play(Idstring("anim_steering_wheel_right"))
			self._unit:camera():play_redirect_timeblend(self.IDS_STEER_RIGHT_STATE, self.IDS_STEER_RIGHT_REDIRECT, 0, math.abs(steer))

			self._wheel_idle = false
		end

		local speed_anim_length = self._vehicle_unit:anim_length(Idstring("ag_speedometer"))
		local rpm_anim_length = self._vehicle_unit:anim_length(Idstring("ag_rpm_meter"))
		local speed = vehicle_state:get_speed() * 3.6
		speed = speed * 1.25
		local rpm = vehicle_state:get_rpm()
		local max_speed = self._vehicle_ext._tweak_data.max_speed
		local max_rpm = self._vehicle:get_max_rpm()
		local relative_speed = speed / max_speed

		if relative_speed > 1 then
			relative_speed = 1
		end

		relative_speed = relative_speed * speed_anim_length
		local relative_rpm = rpm / max_rpm

		if relative_rpm > 1 then
			relative_rpm = 1
		end

		relative_rpm = relative_rpm * rpm_anim_length

		self._vehicle_unit:anim_set_time(Idstring("ag_speedometer"), relative_speed)
		self._vehicle_unit:anim_play(Idstring("ag_speedometer"))
		self._vehicle_unit:anim_set_time(Idstring("ag_rpm_meter"), relative_rpm)
		self._vehicle_unit:anim_play(Idstring("ag_rpm_meter"))

		if vehicle_state:get_speed() < 0.5 and move_d.y < 0 and vehicle_state:get_gear() ~= 0 then
			forced_gear = 0
		end

		if vehicle_state:get_speed() < 0.5 and move_d.y > 0 and vehicle_state:get_gear() ~= 2 then
			forced_gear = 2
		end

		if vehicle_state:get_gear() == 0 and move_d.y ~= 0 then
			direction = -1
		end

		local accelerate = 0
		local brake = 0

		if direction > 0 then
			if move_d.y > 0 then
				accelerate = move_d.y
			else
				brake = -move_d.y
			end
		elseif move_d.y > 0 then
			brake = move_d.y
		else
			accelerate = -move_d.y
		end

		local input_held = self._controller:get_any_input()
		local btn_handbrake_held = input_held and self._controller:get_input_bool("hand_brake")
		local handbrake = 0

		if btn_handbrake_held then
			handbrake = 1
		end

		if move_d.x == 0 and math.abs(self._move_x) > 0 then
			self._dt = dt
			self._max_steer = math.abs(steer)
		else
			self._max_steer = 0
		end

		if self._dt > 0 and self._dt < self._max_steer then
			self._move_x = self:smoothstep(0, self._max_steer, self._dt, self._max_steer) * math.sign(self._move_x)
			self._dt = self._dt + dt
		elseif math.abs(move_d.x) == 1 and math.abs(self._move_x) < 0.99 then
			self._move_x = self:smoothstep(math.abs(move_d.x), 0, self._dt, math.abs(move_d.x)) * math.sign(move_d.x)
			self._dt = self._dt + dt
		else
			self._move_x = move_d.x
			self._dt = 0
		end

		local back_light = self._vehicle_unit:get_object(Idstring("light_back"))
		local back_light_effect = self._vehicle_unit:get_object(Idstring("g_lights_rear_effect"))

		if back_light and brake > 0 then
			back_light:set_enable(true)
		elseif back_light then
			back_light:set_enable(false)
		end

		if back_light_effect and brake > 0 then
			back_light_effect:set_visibility(true)
		elseif back_light_effect then
			back_light_effect:set_visibility(false)
		end

		self._vehicle_ext:set_input(accelerate, self._move_x * -1, brake, handbrake, false, false, forced_gear, dt, move_d.y)
	end
end

function PlayerDriving:on_inventory_event(unit, event)
	local weapon = self._unit:inventory():equipped_unit()

	table.insert(weapon:base()._setup.ignore_units, self._vehicle_unit)

	if alive(self._current_weapon) then
		table.delete(self._current_weapon:base()._setup.ignore_units, self._vehicle_unit)
	end

	self._current_weapon = weapon

	weapon:base():set_visibility_state(true)
end

function PlayerDriving:smoothstep(a, b, step, n)
	local v = step / n
	v = 1 - (1 - v) * (1 - v)
	local x = a * v + b * (1 - v)

	return x
end
