PlayerFreefall = PlayerFreefall or class(PlayerStandard)

function PlayerFreefall:init(unit)
	PlayerFreefall.super.init(self, unit)

	self._tweak_data = tweak_data.player.freefall
	self._dt = 0
end

function PlayerFreefall:enter(state_data, enter_data)
	print("[PlayerFreefall:enter]", "Enter freefall state")
	PlayerFreefall.super.enter(self, state_data, enter_data)

	if self._state_data.ducking then
		self:_end_action_ducking()
	end

	self:_interupt_action_steelsight()
	self:_interupt_action_melee(managers.player:player_timer():time())
	self:_interupt_action_ladder(managers.player:player_timer():time())

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		self:_interupt_action_throw_grenade(managers.player:player_timer():time())
	else
		self:_interupt_action_throw_projectile(managers.player:player_timer():time())
	end

	self:_interupt_action_charging_weapon(managers.player:player_timer():time())

	self._original_damping = self._unit:mover():damping()

	self._unit:mover():set_damping(self._tweak_data.gravity / self._tweak_data.terminal_velocity)
	self._unit:sound():play("free_falling", nil, false)
end

function PlayerFreefall:_enter(enter_data)
	if self._ext_camera:anim_data().equipped then
		self._ext_camera:play_redirect(self:get_animation("unequip"))
	end

	self._unit:movement().fall_rotation = self._unit:movement().fall_rotation or Rotation(0, 0, 0)

	self:_pitch_down()
	self:_set_camera_limits()

	self._shaker_id = self._ext_camera:shaker():play("player_freefall", 0)
end

function PlayerFreefall:exit(state_data, new_state_name)
	print("[PlayerFreefall:exit]", "Exiting freefall state")
	PlayerFreefall.super.exit(self, state_data)
	self._unit:mover():set_damping(self._original_damping or 1)
	self:_remove_camera_limits()
	self._ext_camera:shaker():stop(self._shaker_id)
end

function PlayerFreefall:interaction_blocked()
	return true
end

function PlayerFreefall:bleed_out_blocked()
	return true
end

function PlayerFreefall:_chk_play_falling_anim()
	if not self._played_unequip_animation and not self._ext_camera:anim_data().unequipping then
		self._ext_camera:play_redirect(self:get_animation("falling"))
		self._unit:inventory():hide_equipped_unit()

		self._played_unequip_animation = true
	end
end

function PlayerFreefall:update(t, dt)
	PlayerFreefall.super.update(self, t, dt)

	self._last_shake_update = (self._last_shake_update or 0) + dt

	if self._last_shake_update > 0.2 then
		local shake_amplitude = math.lerp(self._tweak_data.camera.shake.min, self._tweak_data.camera.shake.max, math.abs(self._unit:mover():velocity().z) / self._tweak_data.terminal_velocity)

		self._ext_camera:shaker():set_parameter(self._shaker_id, "amplitude", shake_amplitude)

		self._last_shake_update = 0
	end

	self:_chk_play_falling_anim()
end

function PlayerFreefall:_update_movement(t, dt)
	local direction = self._controller:get_input_axis("move")

	if not self._gnd_ray and self._tweak_data.camera then
		self._camera_unit:base():update_tilt_smooth(direction.x, self._tweak_data.camera.tilt.max, self._tweak_data.camera.tilt.speed, dt)
	end

	local current_rot = self._unit:movement().fall_rotation
	local new_rot = nil
	local delta = self._tweak_data.movement.rotation_speed * dt

	if direction.x > 0 then
		local yaw = current_rot:yaw() - delta
		new_rot = Rotation(yaw, current_rot:pitch(), current_rot:roll())
		self._unit:movement().fall_rotation = new_rot
	elseif direction.x < 0 then
		local yaw = current_rot:yaw() + delta
		new_rot = Rotation(yaw, current_rot:pitch(), current_rot:roll())
		self._unit:movement().fall_rotation = new_rot
	end

	if direction.y > 0 and self._move_dir then
		local old_pos = self._unit:position()

		self._unit:set_position(old_pos + self._move_dir:normalized() * self._tweak_data.movement.forward_speed * dt)
		self._ext_movement:set_m_pos(self._unit:position())
	end

	self:_update_network_position(t, dt, self._unit:position())
end

function PlayerFreefall:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)
	self._stick_move = self._controller:get_input_axis("move")

	if mvector3.length(self._stick_move) < 0.1 then
		self._move_dir = nil
	else
		self._move_dir = mvector3.copy(self._stick_move)
		local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

		mvector3.rotate_with(self._move_dir, cam_flat_rot)
	end

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil

	if not new_action then
		-- Nothing
	end

	if not new_action and self._state_data.ducking then
		self:_end_action_ducking(t)
	end
end

function PlayerFreefall:_get_walk_headbob()
	return 0
end

function PlayerFreefall:_set_camera_limits()
	self._camera_unit:base():set_pitch(self._tweak_data.camera.target_pitch)
	self._camera_unit:base():set_limits(self._tweak_data.camera.limits.spin, self._tweak_data.camera.limits.pitch)
end

function PlayerFreefall:_remove_camera_limits()
	self._camera_unit:base():remove_limits()
	self._camera_unit:base():set_target_tilt(0)
end

function PlayerFreefall:_check_action_interact(t, input)
	local new_action = nil
	local interaction_wanted = input.btn_interact_press

	if interaction_wanted then
		local action_forbidden = self:chk_action_forbidden("interact")

		if not action_forbidden then
			self:_start_action_state_standard(t)
		end
	end

	return new_action
end

function PlayerFreefall:_pitch_down()
	local t = Application:time()

	self._camera_unit:base():animate_pitch(t, nil, self._tweak_data.camera.target_pitch, 1.7)
end

function PlayerFreefall:tweak_data_clbk_reload()
end
