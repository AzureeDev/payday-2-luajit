PlayerBipod = PlayerBipod or class(PlayerStandard)
PlayerBipod.target_tilt = -5
PlayerBipod._shoulder_pos = nil
PlayerBipod._camera_pos = nil
PlayerBipod._default_spread_modifier = 1.6

function PlayerBipod:init(unit)
	PlayerBipod.super.init(self, unit)
end

function PlayerBipod:set_camera_positions(bipod_pos, camera_pos)
	self._shoulder_pos = Vector3(bipod_pos.x, bipod_pos.y, bipod_pos.z)
	self._camera_pos = Vector3(camera_pos.x, camera_pos.y, camera_pos.z)
end

function PlayerBipod:enter(state_data, enter_data)
	PlayerBipod.super.enter(self, state_data, enter_data)
end

function PlayerBipod:_enter(enter_data)
	local player = managers.player:player_unit()

	if player and self._unit:base().is_local_player then
		self._bipod = true
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		local speed_multiplier = self._equipped_unit:base():get_property("bipod_deploy_multiplier") or 1
		local reload_name_id = tweak_data.animations.reload_name_id or self._equipped_unit:base().name_id
		local equipped_unit_id = self._equipped_unit:base().name_id
		self._unit_deploy_position = player:position()

		self._unit:camera():camera_unit():base():set_limits(tweak_data.bipod_camera_spin_limit, tweak_data.bipod_camera_pitch_limit)
		PlayerBipod.super:start_deploying_bipod(tweak_data.timers.deploy_bipod)
		self._equipped_unit:base():tweak_data_anim_stop("undeploy")

		local result = self._ext_camera:play_redirect(Idstring(tweak_data.animations.bipod_enter .. "_" .. equipped_unit_id), speed_multiplier)
		local result_deploy = self._equipped_unit:base():tweak_data_anim_play("deploy", speed_multiplier)
		self._headbob = 0
		self._target_headbob = 0

		self._ext_camera:set_shaker_parameter("headbob", "amplitude", 0)

		PlayerStandard.ANIM_STATES.bipod = {
			recoil = Idstring(tweak_data.animations.bipod_recoil .. "_" .. equipped_unit_id),
			recoil_enter = Idstring(tweak_data.animations.bipod_recoil_enter .. "_" .. equipped_unit_id),
			recoil_loop = Idstring(tweak_data.animations.bipod_recoil_loop .. "_" .. equipped_unit_id),
			recoil_exit = Idstring(tweak_data.animations.bipod_recoil_exit .. "_" .. equipped_unit_id)
		}

		self:set_animation_state("bipod")
		self._unit:sound_source():post_event("wp_steady_in")
		self:_stance_entered()
		self:_husk_bipod_data()
	end
end

function PlayerBipod:get_movement_modifier(weapon_spread)
	if not weapon_spread.bipod then
		Application:debug("[PlayerBipod:get_movement_modifier] Unable to get bipod spread modifier, did you forget to add this value for the current weapon? Returning default spread modifier")

		return self._spread_modifier or 1
	end

	return weapon_spread.bipod
end

function PlayerBipod:get_movement_state()
	return "crouching"
end

function PlayerBipod:exit(state_data, new_state_name)
	PlayerBipod.super.exit(self, state_data or self._state_data, new_state_name)

	self._bipod = nil
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	local speed_multiplier = self._equipped_unit:base():get_property("bipod_deploy_multiplier") or 1
	local equipped_unit_id = self._equipped_unit:base().name_id

	self._equipped_unit:base():tweak_data_anim_stop("deploy")

	local result = self._ext_camera:play_redirect(Idstring(tweak_data.animations.bipod_exit .. "_" .. equipped_unit_id), speed_multiplier)
	local result_deploy = self._equipped_unit:base():tweak_data_anim_play("undeploy", speed_multiplier)

	self._unit:camera():camera_unit():base():remove_limits()

	self._unit:camera():camera_unit():base().bipod_location = nil
	local exit_data = {skip_equip = true}
	self._dye_risk = nil

	self:set_animation_state("standard")
	self._unit:sound_source():post_event("wp_steady_out")

	local peer_id = managers.network:session():peer_by_unit(self._unit):id()

	Application:trace("PlayerBipod:exit: ", peer_id)
	managers.player:set_bipod_data_for_peer({peer_id = peer_id})

	self._state_data.previous_state = "bipod"

	return exit_data
end

function PlayerBipod:_husk_bipod_data()
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local weapon = self._unit:inventory():equipped_unit()
	local bipod_obj = weapon:get_object(Idstring("a_bp"))
	local bipod_pos = nil

	if bipod_obj then
		bipod_pos = bipod_obj:position()

		Application:trace("Getting bipod obj: ", bipod_pos)
	else
		Application:trace("Missing bipod obj: ", bipod_pos)
	end

	local body_pos = Vector3(self._m_pos.x, self._m_pos.y, self._m_pos.z)

	managers.player:set_bipod_data_for_peer({
		peer_id = peer_id,
		bipod_pos = bipod_pos,
		body_pos = body_pos
	})
	managers.network:session():send_to_peers_synched("sync_bipod", bipod_pos, body_pos)
end

function PlayerBipod:update(t, dt)
	PlayerBipod.super.update(self, t, dt)

	local deploy_valid = self._equipped_unit:base():is_bipod_usable()
	local movement_distance = (self._unit_deploy_position - managers.player:player_unit():position()):length()

	if not managers.player:player_unit():mover():standing() or movement_distance > 10 or not deploy_valid then
		self:exit(nil, "standard")
		managers.player:set_player_state("standard")
	end
end

function PlayerBipod:set_tweak_data(name)
end

function PlayerBipod:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_determine_move_direction()
	self:_update_interaction_timers(t)
	self:_update_throw_projectile_timers(t, input)
	self:_update_reload_timers(t, dt, input)
	self:_update_melee_timers(t, input)
	self:_update_equip_weapon_timers(t, input)
	self:_update_running_timers(t)
	self:_update_zipline_timers(t, dt)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = false
	new_action = self:_check_action_reload(t, input)
	new_action = new_action or self:_check_action_weapon_gadget(t, input)

	if not new_action then
		new_action = self:_check_action_primary_attack(t, input)

		if not new_action then
			self:_check_stop_shooting()
		end

		self._shooting = new_action
	end

	new_action = new_action or self:_check_action_jump(t, input)
	new_action = new_action or self:_check_action_run(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)
	new_action = new_action or self:_check_action_unmount_bipod(t, input)
	new_action = new_action or self:_check_action_intimidate(t, input)
	new_action = new_action or self:_check_action_throw_projectile(t, input)

	self:_check_action_steelsight(t, input)
	self:_check_use_item(t, input)
	self:_check_action_night_vision(t, input)
	self:_find_pickups(t)
end

function PlayerBipod:interaction_blocked()
	return true
end

function PlayerBipod:_check_step(t)
end

function PlayerBipod:_check_action_reload(t, input)
	local new_action = nil
	local action_wanted = input.btn_reload_press

	if action_wanted and self._equipped_unit and not self._equipped_unit:base():clip_full() then
		self:exit(nil, "standard")
		managers.player:set_player_state("standard")
		self:_start_action_reload_enter(t)

		new_action = true
	end

	return new_action
end

function PlayerBipod:_check_action_intimidate(t, input)
	if not input.btn_interact_press then
		return
	end

	local action_forbidden = self:chk_action_forbidden("interact") or self._unit:base():stats_screen_visible() or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_on_zipline()

	if action_forbidden then
		return
	end

	return self:_start_action_intimidate(t)
end

function PlayerBipod:_check_action_unmount_bipod(t, input)
	if not input.btn_deploy_bipod then
		return false
	end

	self:_unmount_bipod()

	return true
end

function PlayerBipod:_unmount_bipod()
	local weapon = self._equipped_unit:base()
	local bipod_part = managers.weapon_factory:get_parts_from_weapon_by_perk("bipod", weapon._parts)

	if bipod_part and bipod_part[1] then
		local bipod_unit = bipod_part[1].unit:base()

		bipod_unit:_unmount()
		self:exit(nil, "standard")
		managers.player:set_player_state("standard")
	end
end

function PlayerBipod:_check_action_jump(t, input)
	if input.btn_jump_press then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_check_action_jump(t, input)
		end

		return true
	end

	return false
end

function PlayerBipod:_check_action_run(t, input)
	if self._state_data.previous_state and self._state_data.previous_state == "carry" then
		return
	end

	local move = self._controller:get_input_axis("move")

	if input.btn_run_state and move.y > 0.1 then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_start_action_running(t)
		end

		return true
	end

	return false
end

function PlayerBipod:_check_change_weapon(t, input)
	if input.btn_switch_weapon_press or input.btn_primary_choice == 1 then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_check_change_weapon(t, input)
			current_state:_check_action_equip(t, input)
		end

		return true
	end

	return false
end

function PlayerBipod:_check_use_item(t, input)
	if input.btn_use_item_press then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_check_use_item(t, input)
		end

		return true
	end

	return false
end

function PlayerBipod:_check_action_throw_grenade(t, input)
	local action_forbidden = not PlayerBase.USE_GRENADES or self._unit:base():stats_screen_visible()

	if input.btn_throw_grenade_press and managers.player:can_throw_grenade() and not action_forbidden then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_start_action_throw_grenade(t, input)
		end

		return true
	end

	return false
end

function PlayerBipod:_check_action_throw_projectile(t, input)
	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		return self:_check_action_throw_grenade(t, input)
	elseif tweak_data.blackmarket.projectiles[projectile_entry].ability then
		return self:_check_action_use_ability(t, input)
	end

	local action_forbidden = not PlayerBase.USE_GRENADES or not managers.player:can_throw_grenade() or not self:_projectile_repeat_allowed()

	if input.btn_projectile_press and not action_forbidden then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_start_action_throw_projectile(t, input)
		end

		return true
	end

	return false
end

function PlayerBipod:_check_action_equip(t, input)
	local new_action = nil
	local selection_wanted = input.btn_primary_choice

	if selection_wanted then
		local action_forbidden = self:chk_action_forbidden("equip")
		action_forbidden = action_forbidden or not self._ext_inventory:is_selection_available(selection_wanted) or self._use_item_expire_t or self:_changing_weapon()

		if not action_forbidden then
			local new_action = not self._ext_inventory:is_equipped(selection_wanted)

			if new_action then
				self:_unmount_bipod()
			end
		end
	end

	return new_action
end

function PlayerBipod:_check_action_steelsight(t, input)
end

function PlayerBipod:_update_movement(t, dt)
end

function PlayerBipod:_start_action_jump(...)
end

function PlayerBipod:_perform_jump(jump_vec)
end

function PlayerBipod:_get_max_walk_speed(...)
end

function PlayerBipod:_get_walk_headbob(...)
	return 0
end

