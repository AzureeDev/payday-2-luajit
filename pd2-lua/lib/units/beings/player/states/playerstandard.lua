require("lib/input/BipodDeployControllerInput")
require("lib/input/SecondDeployableControllerInput")
core:import("CoreEnvironmentFeeder")
require("lib/input/HoldButtonMetaInput")

local mvec3_dis_sq = mvector3.distance_sq
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
PlayerStandard = PlayerStandard or class(PlayerMovementState)
PlayerStandard.MOVER_STAND = Idstring("stand")
PlayerStandard.MOVER_DUCK = Idstring("duck")
PlayerStandard.MOVEMENT_DEADZONE = 0.1
PlayerStandard.ANIM_STATES = {
	standard = {
		equip = Idstring("equip"),
		mask_equip = Idstring("mask_equip"),
		unequip = Idstring("unequip"),
		reload_exit = Idstring("reload_exit"),
		reload_not_empty_exit = Idstring("reload_not_empty_exit"),
		start_running = Idstring("start_running"),
		stop_running = Idstring("stop_running"),
		melee = Idstring("melee"),
		melee_miss = Idstring("melee_miss"),
		melee_bayonet = Idstring("melee_bayonet"),
		melee_miss_bayonet = Idstring("melee_miss_bayonet"),
		idle = Idstring("idle"),
		use = Idstring("use"),
		recoil = Idstring("recoil"),
		recoil_steelsight = Idstring("recoil_steelsight"),
		recoil_enter = Idstring("recoil_enter"),
		recoil_loop = Idstring("recoil_loop"),
		recoil_exit = Idstring("recoil_exit"),
		melee_charge = Idstring("melee_charge"),
		melee_charge_state = Idstring("fps/melee_charge"),
		melee_attack = Idstring("melee_attack"),
		melee_attack_state = Idstring("fps/melee_attack"),
		melee_exit_state = Idstring("fps/melee_exit"),
		melee_enter = Idstring("melee_enter"),
		projectile_start = Idstring("throw_projectile_start"),
		projectile_idle = Idstring("throw_projectile_idle"),
		projectile_throw = Idstring("throw_projectile"),
		projectile_throw_state = Idstring("fps/throw_projectile"),
		projectile_exit_state = Idstring("fps/throw_projectile_exit"),
		projectile_enter = Idstring("throw_projectile_enter"),
		charge = Idstring("charge"),
		base = Idstring("base"),
		cash_inspect = Idstring("cash_inspect"),
		falling = Idstring("falling"),
		tased = Idstring("tased"),
		tased_exit = Idstring("tased_exit"),
		tased_boost = Idstring("tased_boost"),
		tased_counter = Idstring("tazer_counter")
	},
	bipod = {
		recoil = Idstring("bipod_recoil"),
		recoil_steelsight = Idstring("bipod_recoil_steelsight"),
		recoil_enter = Idstring("bipod_recoil_enter"),
		recoil_loop = Idstring("bipod_recoil_loop"),
		recoil_exit = Idstring("bipod_recoil_exit")
	},
	underbarrel = {
		equip = Idstring("underbarrel_equip"),
		unequip = Idstring("underbarrel_unequip"),
		start_running = Idstring("underbarrel_start_running"),
		stop_running = Idstring("underbarrel_stop_running"),
		melee = Idstring("underbarrel_melee"),
		melee_miss = Idstring("underbarrel_melee_miss"),
		idle = Idstring("underbarrel_idle")
	}
}
PlayerStandard.projectile_throw_delays = {
	projectile_frag_com = 0.83062744140625,
	projectile_dynamite = 0.86656761169434,
	projectile_molotov = 0.86867332458496,
	projectile_frag = 0.52984619140625
}
PlayerStandard.debug_bipod = nil

function PlayerStandard:init(unit)
	PlayerMovementState.init(self, unit)

	self._tweak_data = tweak_data.player.movement_state.standard
	self._obj_com = self._unit:get_object(Idstring("rp_mover"))
	local slot_manager = managers.slot
	self._slotmask_gnd_ray = slot_manager:get_mask("player_ground_check")
	self._slotmask_fwd_ray = slot_manager:get_mask("bullet_impact_targets")
	self._slotmask_bullet_impact_targets = slot_manager:get_mask("bullet_impact_targets")
	self._slotmask_pickups = slot_manager:get_mask("pickups")
	self._slotmask_AI_visibility = slot_manager:get_mask("AI_visibility")
	self._slotmask_long_distance_interaction = slot_manager:get_mask("long_distance_interaction")
	self._ext_camera = unit:camera()
	self._ext_movement = unit:movement()
	self._ext_damage = unit:character_damage()
	self._ext_inventory = unit:inventory()
	self._ext_anim = unit:anim_data()
	self._ext_network = unit:network()
	self._ext_event_listener = unit:event_listener()
	self._camera_unit = self._ext_camera._camera_unit
	self._camera_unit_anim_data = self._camera_unit:anim_data()
	self._machine = unit:anim_state_machine()
	self._m_pos = self._ext_movement:m_pos()
	self._pos = Vector3()
	self._stick_move = Vector3()
	self._stick_look = Vector3()
	self._cam_fwd_flat = Vector3()
	self._walk_release_t = -100
	self._last_sent_pos = unit:position()
	self._last_sent_pos_t = 0
	self._state_data = unit:movement()._state_data
	local pm = managers.player
	self.RUN_AND_RELOAD = pm:has_category_upgrade("player", "run_and_reload")
	self._pickup_area = 200 * pm:upgrade_value("player", "increased_pickup_area", 1)

	self:set_animation_state("standard")

	self._interaction = managers.interaction
	self._on_melee_restart_drill = pm:has_category_upgrade("player", "drill_melee_hit_restart_chance")
	local controller = unit:base():controller()

	if controller:get_type() ~= "pc" and controller:get_type() ~= "vr" then
		self._input = {}

		table.insert(self._input, BipodDeployControllerInput:new())

		if pm:has_category_upgrade("player", "second_deployable") then
			table.insert(self._input, SecondDeployableControllerInput:new())
		end
	end

	self._input = self._input or {}

	table.insert(self._input, HoldButtonMetaInput:new("night_vision", "weapon_firemode", nil, 0.5))

	self._menu_closed_fire_cooldown = 0

	managers.menu:add_active_changed_callback(callback(self, self, "_on_menu_active_changed"))
end

function PlayerStandard:_on_menu_active_changed(active)
	if not active and self == self._ext_movement:current_state() then
		self._menu_closed_fire_cooldown = 0.15
	end
end

function PlayerStandard:get_animation(anim)
	return PlayerStandard._current_anim_state[2][anim] or PlayerStandard.ANIM_STATES.standard[anim]
end

function PlayerStandard:set_animation_state(state_name)
	if state_name and PlayerStandard.ANIM_STATES[state_name] then
		PlayerStandard._current_anim_state = {
			state_name,
			PlayerStandard.ANIM_STATES[state_name]
		}
	else
		Application:error("No player animation states for state: ", tostring(state_name))

		PlayerStandard._current_anim_state = {
			"standard",
			PlayerStandard.ANIM_STATES.standard
		}
	end
end

function PlayerStandard:current_anim_state_name()
	return PlayerStandard._current_anim_state[1]
end

function PlayerStandard:enter(state_data, enter_data)
	PlayerMovementState.enter(self, state_data, enter_data)
	tweak_data:add_reload_callback(self, self.tweak_data_clbk_reload)

	self._state_data = state_data
	self._state_data.using_bipod = managers.player:current_state() == "bipod"
	self._equipped_unit = self._ext_inventory:equipped_unit()
	local weapon = self._ext_inventory:equipped_unit()
	self._weapon_hold = weapon and weapon:base().weapon_hold and weapon:base():weapon_hold() or weapon:base():get_name_id()

	self:inventory_clbk_listener(self._unit, "equip")
	self:_enter(enter_data)
	self:_update_ground_ray()

	self._controller = self._unit:base():controller()

	if not self._unit:mover() then
		self:_activate_mover(PlayerStandard.MOVER_STAND)
	end

	if not _G.IS_VR and (enter_data and enter_data.wants_crouch or not self:_can_stand()) and not self._state_data.ducking then
		self:_start_action_ducking(managers.player:player_timer():time())
	end

	self._ext_camera:clbk_fp_enter(self._unit:rotation():y())

	if self._ext_movement:nav_tracker() then
		self._pos_reservation = {
			radius = 100,
			position = self._ext_movement:m_pos(),
			filter = self._ext_movement:pos_rsrv_id()
		}
		self._pos_reservation_slow = {
			radius = 100,
			position = mvector3.copy(self._ext_movement:m_pos()),
			filter = self._ext_movement:pos_rsrv_id()
		}

		managers.navigation:add_pos_reservation(self._pos_reservation)
		managers.navigation:add_pos_reservation(self._pos_reservation_slow)
	end

	for _, data in ipairs(self._ext_inventory._available_selections) do
		local unit = data.unit

		managers.hud:set_ammo_amount(unit:base():selection_index(), unit:base():ammo_info())
	end

	if enter_data and enter_data.equip_weapon then
		self:_start_action_unequip_weapon(managers.player:player_timer():time(), {
			selection_wanted = enter_data.equip_weapon
		})
	end

	if enter_data then
		self._change_weapon_data = enter_data.change_weapon_data or self._change_weapon_data
		self._unequip_weapon_expire_t = enter_data.unequip_weapon_expire_t or self._unequip_weapon_expire_t
		self._equip_weapon_expire_t = enter_data.equip_weapon_expire_t or self._equip_weapon_expire_t
	end

	self:_reset_delay_action()

	self._last_velocity_xy = Vector3()
	self._last_sent_pos_t = enter_data and enter_data.last_sent_pos_t or managers.player:player_timer():time()
	self._last_sent_pos = enter_data and enter_data.last_sent_pos or mvector3.copy(self._pos)
	self._gnd_ray = true
end

function PlayerStandard:_enter(enter_data)
	self._unit:base():set_slot(self._unit, 2)

	if Network:is_server() and self._ext_movement:nav_tracker() then
		managers.groupai:state():on_player_weapons_hot()
	end

	if self._ext_movement:nav_tracker() then
		managers.groupai:state():on_criminal_recovered(self._unit)
	end

	local skip_equip = enter_data and enter_data.skip_equip
	local skip_mask_anim = enter_data and enter_data.skip_mask_anim

	if not self:_changing_weapon() and not skip_equip then
		if not self._state_data.mask_equipped then
			self._state_data.mask_equipped = true

			if not skip_mask_anim then
				local equipped_mask = managers.blackmarket:equipped_mask()
				local peer_id = managers.network:session() and managers.network:session():local_peer():id()
				local mask_id = managers.blackmarket:get_real_mask_id(equipped_mask.mask_id, peer_id)
				local equipped_mask_type = tweak_data.blackmarket.masks[mask_id].type

				self._camera_unit:anim_state_machine():set_global((equipped_mask_type or "mask") .. "_equip", 1)
				self:_start_action_equip(self:get_animation("mask_equip"), 1.6)
			end
		else
			self:_start_action_equip(self:get_animation("equip"))
		end
	end

	self._ext_camera:camera_unit():base():set_target_tilt(0)

	if self._ext_movement:nav_tracker() then
		self._standing_nav_seg_id = self._ext_movement:nav_tracker():nav_segment()
		local metadata = managers.navigation:get_nav_seg_metadata(self._standing_nav_seg_id)
		local location_id = metadata.location_id

		managers.hud:set_player_location(location_id)
		self._unit:base():set_suspicion_multiplier("area", metadata.suspicion_mul)
		self._unit:base():set_detection_multiplier("area", metadata.detection_mul and 1 / metadata.detection_mul or nil)
	end

	self._ext_inventory:set_mask_visibility(true)
	self:_upd_attention()
	self._ext_network:send("set_stance", 3, false, false)
end

function PlayerStandard:exit(state_data, new_state_name)
	PlayerMovementState.exit(self, state_data)
	tweak_data:remove_reload_callback(self)
	self:_interupt_action_interact()
	self:_interupt_action_use_item()
	managers.environment_controller:set_dof_distance()

	if self._pos_reservation then
		managers.navigation:unreserve_pos(self._pos_reservation)
		managers.navigation:unreserve_pos(self._pos_reservation_slow)

		self._pos_reservation = nil
		self._pos_reservation_slow = nil
	end

	if self._running then
		self:_end_action_running(managers.player:player_timer():time())
		self:set_running(false)
	end

	if self._shooting then
		self._camera_unit:base():stop_shooting()
		self:_check_stop_shooting()
	end

	self._headbob = 0
	self._target_headbob = 0

	self._ext_camera:set_shaker_parameter("headbob", "amplitude", 0)

	local exit_data = {
		skip_equip = true,
		last_sent_pos_t = self._last_sent_pos_t,
		last_sent_pos = self._last_sent_pos,
		ducking = self._state_data.ducking,
		change_weapon_data = self._change_weapon_data,
		unequip_weapon_expire_t = self._unequip_weapon_expire_t,
		equip_weapon_expire_t = self._equip_weapon_expire_t
	}
	self._state_data.using_bipod = managers.player:current_state() == "bipod"

	self:_update_network_jump(nil, true)

	self._state_data.previous_state = "standard"

	return exit_data
end

function PlayerStandard:_activate_mover(mover, velocity)
	self._unit:activate_mover(mover, velocity)

	if self._state_data.on_ladder then
		self._unit:mover():set_gravity(Vector3(0, 0, 0))
	else
		self._unit:mover():set_gravity(Vector3(0, 0, -982))
	end

	if self._is_jumping then
		self._unit:mover():jump()
		self._unit:mover():set_velocity(velocity)
	end
end

function PlayerStandard:interaction_blocked()
	return self:is_deploying() or self:_on_zipline()
end

function PlayerStandard:bleed_out_blocked()
	return false
end

function PlayerStandard:update(t, dt)
	PlayerMovementState.update(self, t, dt)
	self:_calculate_standard_variables(t, dt)
	self:_update_ground_ray()
	self:_update_fwd_ray()
	self:_update_check_actions(t, dt)

	if self._menu_closed_fire_cooldown > 0 then
		self._menu_closed_fire_cooldown = self._menu_closed_fire_cooldown - dt
	end

	self:_update_movement(t, dt)
	self:_upd_nav_data()
	managers.hud:_update_crosshair_offset(t, dt)
	self:_update_omniscience(t, dt)
	self:_upd_stance_switch_delay(t, dt)

	if self._last_equipped then
		if self._last_equipped ~= self._equipped_unit then
			self._equipped_visibility_timer = t + 0.1
		end

		if self._equipped_visibility_timer and self._equipped_visibility_timer < t and alive(self._equipped_unit) then
			self._equipped_unit:base():set_visibility_state(true)
		end
	end

	self._last_equipped = self._equipped_unit
end

function PlayerStandard:in_air()
	return self._state_data.in_air
end

function PlayerStandard:in_steelsight()
	return self._state_data.in_steelsight
end

function PlayerStandard:is_reticle_aim()
	return self._state_data.reticle_obj and self._camera_unit:base():is_stance_done() and not self._equipped_unit:base():is_second_sight_on()
end

function PlayerStandard:get_fire_weapon_position()
	if self:is_reticle_aim() then
		return self._ext_camera:position_with_shake()
	else
		return self._ext_camera:position()
	end
end

function PlayerStandard:get_fire_weapon_direction()
	if self:is_reticle_aim() then
		return self._ext_camera:forward_with_shake_toward_reticle(self._state_data.reticle_obj)
	else
		return self._ext_camera:forward()
	end
end

local temp_vec1 = Vector3()

function PlayerStandard:_upd_nav_data()
	if mvec3_dis_sq(self._m_pos, self._pos) > 1 then
		if self._ext_movement:nav_tracker() then
			self._ext_movement:nav_tracker():move(self._pos)

			local nav_seg_id = self._ext_movement:nav_tracker():nav_segment()

			if self._standing_nav_seg_id ~= nav_seg_id then
				self._standing_nav_seg_id = nav_seg_id
				local metadata = managers.navigation:get_nav_seg_metadata(nav_seg_id)
				local location_id = metadata.location_id

				managers.hud:set_player_location(location_id)
				self._unit:base():set_suspicion_multiplier("area", metadata.suspicion_mul)
				self._unit:base():set_detection_multiplier("area", metadata.detection_mul and 1 / metadata.detection_mul or nil)
				managers.groupai:state():on_criminal_nav_seg_change(self._unit, nav_seg_id)
			end
		end

		if self._pos_reservation then
			managers.navigation:move_pos_rsrv(self._pos_reservation)

			local slow_dist = 100

			mvec3_set(temp_vec1, self._pos_reservation_slow.position)
			mvec3_sub(temp_vec1, self._pos_reservation.position)

			if slow_dist < mvec3_norm(temp_vec1) then
				mvec3_mul(temp_vec1, slow_dist)
				mvec3_add(temp_vec1, self._pos_reservation.position)
				mvec3_set(self._pos_reservation_slow.position, temp_vec1)
				managers.navigation:move_pos_rsrv(self._pos_reservation)
			end
		end

		self._ext_movement:set_m_pos(self._pos)
	end
end

function PlayerStandard:_calculate_standard_variables(t, dt)
	self._gnd_ray = nil
	self._gnd_ray_chk = nil

	self._unit:m_position(self._pos)

	self._rot = self._unit:rotation()
	self._cam_fwd = self._ext_camera:forward()

	mvector3.set(self._cam_fwd_flat, self._cam_fwd)
	mvector3.set_z(self._cam_fwd_flat, 0)
	mvector3.normalize(self._cam_fwd_flat)

	local last_vel_xy = self._last_velocity_xy
	local sampled_vel_dir = self._unit:sampled_velocity()

	if not self._state_data.on_ladder then
		mvector3.set_z(sampled_vel_dir, 0)
	end

	local sampled_vel_len = mvector3.normalize(sampled_vel_dir)

	if sampled_vel_len == 0 then
		mvector3.set_zero(self._last_velocity_xy)
	else
		local fwd_dot = mvector3.dot(sampled_vel_dir, last_vel_xy)

		mvector3.set(self._last_velocity_xy, sampled_vel_dir)

		if sampled_vel_len < fwd_dot then
			mvector3.multiply(self._last_velocity_xy, sampled_vel_len)
		else
			mvector3.multiply(self._last_velocity_xy, math.max(0, fwd_dot))
		end
	end

	self._setting_hold_to_run = managers.user:get_setting("hold_to_run")
	self._setting_hold_to_duck = managers.user:get_setting("hold_to_duck")
end

local tmp_ground_from_vec = Vector3()
local tmp_ground_to_vec = Vector3()
local up_offset_vec = math.UP * 30
local down_offset_vec = math.UP * -40

function PlayerStandard:_update_ground_ray()
	local hips_pos = tmp_ground_from_vec
	local down_pos = tmp_ground_to_vec

	mvector3.set(hips_pos, self._pos)
	mvector3.add(hips_pos, up_offset_vec)
	mvector3.set(down_pos, hips_pos)
	mvector3.add(down_pos, down_offset_vec)

	if self._unit:movement():ladder_unit() then
		self._gnd_ray = World:raycast("ray", hips_pos, down_pos, "slot_mask", self._slotmask_gnd_ray, "ignore_unit", self._unit:movement():ladder_unit(), "ray_type", "body mover", "sphere_cast_radius", 29, "report")
	else
		self._gnd_ray = World:raycast("ray", hips_pos, down_pos, "slot_mask", self._slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 29, "report")
	end

	self._gnd_ray_chk = true
end

function PlayerStandard:_chk_floor_moving_pos(pos)
	local hips_pos = tmp_ground_from_vec
	local down_pos = tmp_ground_to_vec

	mvector3.set(hips_pos, self._pos)
	mvector3.add(hips_pos, up_offset_vec)
	mvector3.set(down_pos, hips_pos)
	mvector3.add(down_pos, down_offset_vec)

	local ground_ray = World:raycast("ray", hips_pos, down_pos, "slot_mask", self._slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 29)

	if ground_ray and ground_ray.body and math.abs(ground_ray.body:velocity().z) > 0 then
		return ground_ray.body:position().z
	end
end

function PlayerStandard:_update_fwd_ray()
	local from = self._unit:movement():m_head_pos()
	local range = alive(self._equipped_unit) and self._equipped_unit:base():has_range_distance_scope() and 20000 or 4000
	local to = self._cam_fwd * range

	mvector3.add(to, from)

	self._fwd_ray = World:raycast("ray", from, to, "slot_mask", self._slotmask_fwd_ray)

	managers.environment_controller:set_dof_distance(math.max(0, math.min(self._fwd_ray and self._fwd_ray.distance or 4000, 4000) - 200), self._state_data.in_steelsight)

	if alive(self._equipped_unit) then
		if self._state_data.in_steelsight and self._fwd_ray and self._fwd_ray.unit and self._equipped_unit:base().check_highlight_unit then
			self._equipped_unit:base():check_highlight_unit(self._fwd_ray.unit)
		end

		if self._equipped_unit:base().set_scope_range_distance then
			self._equipped_unit:base():set_scope_range_distance(self._fwd_ray and self._fwd_ray.distance / 100 or false)
		end
	end
end

function PlayerStandard:force_input(inputs, release_inputs)
	self._forced_inputs = inputs
	self._forced_release_inputs = release_inputs
end

function PlayerStandard:_create_on_controller_disabled_input()
	local release_interact = Global.game_settings.single_player or not managers.menu:get_controller():get_input_bool("interact")
	local input = {
		btn_melee_release = true,
		btn_steelsight_release = true,
		is_customized = true,
		btn_use_item_release = true,
		btn_projectile_release = true,
		btn_interact_release = release_interact
	}

	return input
end

local win32 = SystemInfo:platform() == Idstring("WIN32")

function PlayerStandard:_get_input(t, dt, paused)
	if self._state_data.controller_enabled ~= self._controller:enabled() then
		if self._state_data.controller_enabled then
			self._state_data.controller_enabled = self._controller:enabled()

			return self:_create_on_controller_disabled_input()
		end
	elseif not self._state_data.controller_enabled then
		local input = {
			is_customized = true,
			btn_interact_release = managers.menu:get_controller():get_input_released("interact")
		}

		return input
	end

	self._state_data.controller_enabled = self._controller:enabled()
	local pressed = self._controller:get_any_input_pressed()
	local released = self._controller:get_any_input_released()
	local downed = self._controller:get_any_input()

	if paused then
		self._input_paused = true
	elseif not downed then
		self._input_paused = false
	end

	if not pressed and not released and not downed and not self._forced_inputs or self._input_paused then
		return {}
	end

	local input = {
		data = {
			_unit = self._unit
		},
		any_input_pressed = pressed,
		any_input_released = released,
		any_input_downed = downed,
		btn_stats_screen_press = pressed and not self._unit:base():stats_screen_visible() and self._controller:get_input_pressed("stats_screen"),
		btn_stats_screen_release = released and self._unit:base():stats_screen_visible() and self._controller:get_input_released("stats_screen"),
		btn_duck_press = pressed and self._controller:get_input_pressed("duck"),
		btn_duck_release = released and self._controller:get_input_released("duck"),
		btn_jump_press = pressed and self._controller:get_input_pressed("jump"),
		btn_primary_attack_press = pressed and self._controller:get_input_pressed("primary_attack"),
		btn_primary_attack_state = downed and self._controller:get_input_bool("primary_attack"),
		btn_primary_attack_release = released and self._controller:get_input_released("primary_attack"),
		btn_reload_press = pressed and self._controller:get_input_pressed("reload"),
		btn_steelsight_press = pressed and self._controller:get_input_pressed("secondary_attack"),
		btn_steelsight_release = released and self._controller:get_input_released("secondary_attack"),
		btn_steelsight_state = downed and self._controller:get_input_bool("secondary_attack"),
		btn_interact_press = pressed and self._controller:get_input_pressed("interact"),
		btn_interact_release = released and self._controller:get_input_released("interact"),
		btn_run_press = pressed and self._controller:get_input_pressed("run"),
		btn_run_release = released and self._controller:get_input_released("run"),
		btn_run_state = downed and self._controller:get_input_bool("run"),
		btn_switch_weapon_press = pressed and self._controller:get_input_pressed("switch_weapon"),
		btn_use_item_press = pressed and self._controller:get_input_pressed("use_item"),
		btn_use_item_release = released and self._controller:get_input_released("use_item"),
		btn_melee_press = pressed and self._controller:get_input_pressed("melee"),
		btn_melee_release = released and self._controller:get_input_released("melee"),
		btn_meleet_state = downed and self._controller:get_input_bool("melee"),
		btn_weapon_gadget_press = pressed and self._controller:get_input_pressed("weapon_gadget"),
		btn_throw_grenade_press = pressed and self._controller:get_input_pressed("throw_grenade"),
		btn_projectile_press = pressed and self._controller:get_input_pressed("throw_grenade"),
		btn_projectile_release = released and self._controller:get_input_released("throw_grenade"),
		btn_projectile_state = downed and self._controller:get_input_bool("throw_grenade"),
		btn_weapon_firemode_press = pressed and self._controller:get_input_pressed("weapon_firemode"),
		btn_cash_inspect_press = pressed and self._controller:get_input_pressed("cash_inspect"),
		btn_deploy_bipod = pressed and self._controller:get_input_pressed("deploy_bipod"),
		btn_change_equipment = pressed and self._controller:get_input_pressed("change_equipment"),
		btn_interact_secondary_press = pressed and self._controller:get_input_pressed("interact_secondary")
	}

	if win32 then
		local i = 1

		while i < 3 do
			if self._controller:get_input_pressed("primary_choice" .. i) then
				input.btn_primary_choice = i

				break
			end

			i = i + 1
		end
	end

	if self._input then
		for i = 1, #self._input do
			self._input[i]:update(t, dt, self._controller, input, self._ext_movement:current_state_name())
		end
	end

	if self._forced_inputs then
		for key, value in pairs(self._forced_inputs) do
			input[key] = value
		end

		if self._forced_release_inputs then
			self._forced_inputs = self._forced_release_inputs
			self._forced_release_inputs = nil
		else
			self._forced_inputs = nil
		end
	end

	return input
end

function PlayerStandard:_determine_move_direction()
	self._stick_move = self._controller:get_input_axis("move")

	if self._state_data.on_zipline then
		return
	end

	if mvector3.length(self._stick_move) < PlayerStandard.MOVEMENT_DEADZONE or self:_interacting() or self:_does_deploying_limit_movement() then
		self._move_dir = nil
		self._normal_move_dir = nil
	else
		local ladder_unit = self._unit:movement():ladder_unit()

		if alive(ladder_unit) then
			local ladder_ext = ladder_unit:ladder()
			self._move_dir = mvector3.copy(self._stick_move)
			self._normal_move_dir = mvector3.copy(self._move_dir)
			local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

			mvector3.rotate_with(self._normal_move_dir, cam_flat_rot)

			local cam_rot = Rotation(self._cam_fwd, self._ext_camera:rotation():z())

			mvector3.rotate_with(self._move_dir, cam_rot)

			local up_dot = math.dot(self._move_dir, ladder_ext:up())
			local w_dir_dot = math.dot(self._move_dir, ladder_ext:w_dir())
			local normal_dot = math.dot(self._move_dir, ladder_ext:normal()) * -1
			local normal_offset = ladder_ext:get_normal_move_offset(self._unit:movement():m_pos())

			mvector3.set(self._move_dir, ladder_ext:up() * (up_dot + normal_dot))
			mvector3.add(self._move_dir, ladder_ext:w_dir() * w_dir_dot)
			mvector3.add(self._move_dir, ladder_ext:normal() * normal_offset)
		else
			self._move_dir = mvector3.copy(self._stick_move)
			local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

			mvector3.rotate_with(self._move_dir, cam_flat_rot)

			self._normal_move_dir = mvector3.copy(self._move_dir)
		end
	end
end

function PlayerStandard:update_check_actions_paused()
	self:_update_check_actions(Application:time(), 0.1, true)
end

function PlayerStandard:_update_check_actions(t, dt, paused)
	local input = self:_get_input(t, dt, paused)

	self:_determine_move_direction()
	self:_update_interaction_timers(t)
	self:_update_throw_projectile_timers(t, input)
	self:_update_reload_timers(t, dt, input)
	self:_update_melee_timers(t, input)
	self:_update_charging_weapon_timers(t, input)
	self:_update_use_item_timers(t, input)
	self:_update_equip_weapon_timers(t, input)
	self:_update_running_timers(t)
	self:_update_zipline_timers(t, dt)

	if self._change_item_expire_t and self._change_item_expire_t <= t then
		self._change_item_expire_t = nil
	end

	if self._change_weapon_pressed_expire_t and self._change_weapon_pressed_expire_t <= t then
		self._change_weapon_pressed_expire_t = nil
	end

	self:_update_steelsight_timers(t, dt)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil
	local anim_data = self._ext_anim
	new_action = new_action or self:_check_action_weapon_gadget(t, input)
	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_melee(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)

	if not new_action then
		new_action = self:_check_action_primary_attack(t, input)

		if not _G.IS_VR and not new_action then
			self:_check_stop_shooting()
		end
	end

	new_action = new_action or self:_check_action_equip(t, input)
	new_action = new_action or self:_check_use_item(t, input)
	new_action = new_action or self:_check_action_throw_projectile(t, input)
	new_action = new_action or self:_check_action_interact(t, input)

	self:_check_action_jump(t, input)
	self:_check_action_run(t, input)
	self:_check_action_ladder(t, input)
	self:_check_action_zipline(t, input)
	self:_check_action_cash_inspect(t, input)

	if not new_action then
		new_action = self:_check_action_deploy_bipod(t, input)
		new_action = new_action or self:_check_action_deploy_underbarrel(t, input)
	end

	self:_check_action_change_equipment(t, input)
	self:_check_action_duck(t, input)
	self:_check_action_steelsight(t, input)
	self:_check_action_night_vision(t, input)
	self:_find_pickups(t)
end

local mvec_pos_new = Vector3()
local mvec_achieved_walk_vel = Vector3()
local mvec_move_dir_normalized = Vector3()

function PlayerStandard:_update_movement(t, dt)
	local anim_data = self._unit:anim_data()
	local weapon_id = alive(self._equipped_unit) and self._equipped_unit:base() and self._equipped_unit:base():get_name_id()
	local weapon_tweak_data = weapon_id and tweak_data.weapon[weapon_id]
	local pos_new = nil
	self._target_headbob = self._target_headbob or 0
	self._headbob = self._headbob or 0

	if self._state_data.on_zipline and self._state_data.zipline_data.position then
		local speed = mvector3.length(self._state_data.zipline_data.position - self._pos) / dt / 500
		pos_new = mvec_pos_new

		mvector3.set(pos_new, self._state_data.zipline_data.position)

		if self._state_data.zipline_data.camera_shake then
			self._ext_camera:shaker():set_parameter(self._state_data.zipline_data.camera_shake, "amplitude", speed)
		end

		if alive(self._state_data.zipline_data.zipline_unit) then
			local dot = mvector3.dot(self._ext_camera:rotation():x(), self._state_data.zipline_data.zipline_unit:zipline():current_direction())

			self._ext_camera:camera_unit():base():set_target_tilt(dot * 10 * speed)
		end

		self._target_headbob = 0
	elseif self._move_dir then
		local enter_moving = not self._moving
		self._moving = true

		if enter_moving then
			self._last_sent_pos_t = t

			self:_update_crosshair_offset()
		end

		local WALK_SPEED_MAX = self:_get_max_walk_speed(t)

		mvector3.set(mvec_move_dir_normalized, self._move_dir)
		mvector3.normalize(mvec_move_dir_normalized)

		local wanted_walk_speed = WALK_SPEED_MAX * math.min(1, self._move_dir:length())
		local acceleration = self._state_data.in_air and 700 or self._running and 5000 or 3000
		local achieved_walk_vel = mvec_achieved_walk_vel

		if self._jump_vel_xy and self._state_data.in_air and mvector3.dot(self._jump_vel_xy, self._last_velocity_xy) > 0 then
			local input_move_vec = wanted_walk_speed * self._move_dir
			local jump_dir = mvector3.copy(self._last_velocity_xy)
			local jump_vel = mvector3.normalize(jump_dir)
			local fwd_dot = jump_dir:dot(input_move_vec)

			if fwd_dot < jump_vel then
				local sustain_dot = (input_move_vec:normalized() * jump_vel):dot(jump_dir)
				local new_move_vec = input_move_vec + jump_dir * (sustain_dot - fwd_dot)

				mvector3.step(achieved_walk_vel, self._last_velocity_xy, new_move_vec, 700 * dt)
			else
				mvector3.multiply(mvec_move_dir_normalized, wanted_walk_speed)
				mvector3.step(achieved_walk_vel, self._last_velocity_xy, wanted_walk_speed * self._move_dir:normalized(), acceleration * dt)
			end

			local fwd_component = nil
		else
			mvector3.multiply(mvec_move_dir_normalized, wanted_walk_speed)
			mvector3.step(achieved_walk_vel, self._last_velocity_xy, mvec_move_dir_normalized, acceleration * dt)
		end

		if mvector3.is_zero(self._last_velocity_xy) then
			mvector3.set_length(achieved_walk_vel, math.max(achieved_walk_vel:length(), 100))
		end

		pos_new = mvec_pos_new

		mvector3.set(pos_new, achieved_walk_vel)
		mvector3.multiply(pos_new, dt)
		mvector3.add(pos_new, self._pos)

		self._target_headbob = self:_get_walk_headbob()
		self._target_headbob = self._target_headbob * self._move_dir:length()

		if weapon_tweak_data and weapon_tweak_data.headbob and weapon_tweak_data.headbob.multiplier then
			self._target_headbob = self._target_headbob * weapon_tweak_data.headbob.multiplier
		end
	elseif not mvector3.is_zero(self._last_velocity_xy) then
		local decceleration = self._state_data.in_air and 250 or math.lerp(2000, 1500, math.min(self._last_velocity_xy:length() / tweak_data.player.movement_state.standard.movement.speed.RUNNING_MAX, 1))
		local achieved_walk_vel = math.step(self._last_velocity_xy, Vector3(), decceleration * dt)
		pos_new = mvec_pos_new

		mvector3.set(pos_new, achieved_walk_vel)
		mvector3.multiply(pos_new, dt)
		mvector3.add(pos_new, self._pos)

		self._target_headbob = 0
	elseif self._moving then
		self._target_headbob = 0
		self._moving = false

		self:_update_crosshair_offset()
	end

	if self._headbob ~= self._target_headbob then
		local ratio = 4

		if weapon_tweak_data and weapon_tweak_data.headbob and weapon_tweak_data.headbob.speed_ratio then
			ratio = weapon_tweak_data.headbob.speed_ratio
		end

		self._headbob = math.step(self._headbob, self._target_headbob, dt / ratio)

		self._ext_camera:set_shaker_parameter("headbob", "amplitude", self._headbob)
	end

	local ground_z = self:_chk_floor_moving_pos()

	if ground_z and not self._is_jumping then
		if not pos_new then
			pos_new = mvec_pos_new

			mvector3.set(pos_new, self._pos)
		end

		mvector3.set_z(pos_new, ground_z)
	end

	if pos_new then
		self._unit:movement():set_position(pos_new)
		mvector3.set(self._last_velocity_xy, pos_new)
		mvector3.subtract(self._last_velocity_xy, self._pos)

		if not self._state_data.on_ladder and not self._state_data.on_zipline then
			mvector3.set_z(self._last_velocity_xy, 0)
		end

		mvector3.divide(self._last_velocity_xy, dt)
	else
		mvector3.set_static(self._last_velocity_xy, 0, 0, 0)
	end

	local cur_pos = pos_new or self._pos

	self:_update_network_jump(cur_pos, false)
	self:_update_network_position(t, dt, cur_pos, pos_new)
end

function PlayerStandard:_update_network_position(t, dt, cur_pos, pos_new)
	if not self._last_sent_pos_t or t - self._last_sent_pos_t > 1 / tweak_data.network.player_tick_rate then
		local move_speed = math.clamp(mvector3.length(self._stick_move), 0, 1)

		if move_speed < PlayerStandard.MOVEMENT_DEADZONE then
			move_speed = 1
		end

		if managers.menu:is_pc_controller() then
			move_speed = 1
		end

		self._ext_network:send("player_action_walk_nav_point", cur_pos, move_speed)

		self._last_sent_pos_t = t

		mvector3.set(self._last_sent_pos, cur_pos)
	end
end

function PlayerStandard:is_network_move_allowed()
	return not self:_on_zipline() and not self._is_jumping
end

function PlayerStandard:_get_walk_headbob()
	if self._state_data.using_bipod then
		return 0
	elseif self._state_data.in_steelsight then
		return 0
	elseif self._state_data.in_air then
		return 0
	elseif self._state_data.ducking then
		return 0.0125
	elseif self._running then
		return 0.1 * (self._equipped_unit:base():run_and_shoot_allowed() and 0.5 or 1)
	end

	return 0.025
end

function PlayerStandard:_update_foley(t, input)
	if self._state_data.on_zipline then
		return
	end

	if not self._gnd_ray and not self._state_data.on_ladder then
		if not self._state_data.in_air then
			self._state_data.in_air = true
			self._state_data.enter_air_pos_z = self._pos.z

			self:_interupt_action_running(t)
			self._unit:set_driving("orientation_object")
		end
	elseif self._state_data.in_air then
		self._unit:set_driving("script")

		self._state_data.in_air = false
		local from = self._pos + math.UP * 10
		local to = self._pos - math.UP * 60
		local material_name, pos, norm = World:pick_decal_material(from, to, self._slotmask_bullet_impact_targets)

		self._unit:sound():play_land(material_name)

		if self._unit:character_damage():damage_fall({
			height = self._state_data.enter_air_pos_z - self._pos.z
		}) then
			self._running_wanted = false

			managers.rumble:play("hard_land")
			self._ext_camera:play_shaker("player_fall_damage")
			self:_start_action_ducking(t)
		elseif input.btn_run_state then
			self._running_wanted = true
		end

		self._jump_t = nil
		self._jump_vel_xy = nil

		self._ext_camera:play_shaker("player_land", 0.5)
		managers.rumble:play("land")
	elseif self._jump_vel_xy and t - self._jump_t > 0.3 then
		self._jump_vel_xy = nil

		if input.btn_run_state then
			self._running_wanted = true
		end
	end

	self:_check_step(t)
end

function PlayerStandard:_check_step(t)
	if self._state_data.in_air then
		return
	end

	self._last_step_pos = self._last_step_pos or Vector3()
	local step_length = self._state_data.on_ladder and 50 or self._state_data.in_steelsight and (managers.player:has_category_upgrade("player", "steelsight_normal_movement_speed") and 150 or 100) or self._state_data.ducking and 125 or self._running and 175 or 150

	if mvector3.distance_sq(self._last_step_pos, self._pos) > step_length * step_length then
		mvector3.set(self._last_step_pos, self._pos)
		self._unit:base():anim_data_clbk_footstep()
	end
end

function PlayerStandard:_update_crosshair_offset(t)
	return

	if not alive(self._equipped_unit) then
		return
	end

	local name_id = self._equipped_unit:base():get_name_id()

	if not tweak_data.weapon[name_id].crosshair then
		return
	end

	if self._state_data.in_steelsight then
		managers.hud:set_crosshair_visible(not tweak_data.weapon[name_id].crosshair.steelsight.hidden)
		managers.hud:set_crosshair_offset(tweak_data.weapon[name_id].crosshair.steelsight.offset)

		return
	end

	local spread_multiplier = self._equipped_unit:base():spread_multiplier()

	managers.hud:set_crosshair_visible(not tweak_data.weapon[name_id].crosshair[self._state_data.ducking and "crouching" or "standing"].hidden)

	if self._moving then
		managers.hud:set_crosshair_offset(tweak_data.weapon[name_id].crosshair[self._state_data.ducking and "crouching" or "standing"].moving_offset * spread_multiplier)

		return
	else
		managers.hud:set_crosshair_offset(tweak_data.weapon[name_id].crosshair[self._state_data.ducking and "crouching" or "standing"].offset * spread_multiplier)
	end
end

function PlayerStandard:_stance_entered(unequipped)
	local stance_standard = tweak_data.player.stances.default[managers.player:current_state()] or tweak_data.player.stances.default.standard
	local head_stance = self._state_data.ducking and tweak_data.player.stances.default.crouched.head or stance_standard.head
	local stance_id = nil
	local stance_mod = {
		translation = Vector3(0, 0, 0)
	}

	if not unequipped then
		stance_id = self._equipped_unit:base():get_stance_id()

		if self._state_data.in_steelsight and self._equipped_unit:base().stance_mod then
			stance_mod = self._equipped_unit:base():stance_mod() or stance_mod
		end
	end

	local stances = nil
	stances = (self:_is_meleeing() or self:_is_throwing_projectile()) and tweak_data.player.stances.default or tweak_data.player.stances[stance_id] or tweak_data.player.stances.default
	local misc_attribs = stances.standard
	misc_attribs = (not self:_is_using_bipod() or self:_is_throwing_projectile() or stances.bipod) and (self._state_data.in_steelsight and stances.steelsight or self._state_data.ducking and stances.crouched or stances.standard)
	local duration = tweak_data.player.TRANSITION_DURATION + (self._equipped_unit:base():transition_duration() or 0)
	local duration_multiplier = self._state_data.in_steelsight and 1 / self._equipped_unit:base():enter_steelsight_speed_multiplier() or 1
	local new_fov = self:get_zoom_fov(misc_attribs) + 0

	self._camera_unit:base():clbk_stance_entered(misc_attribs.shoulders, head_stance, misc_attribs.vel_overshot, new_fov, misc_attribs.shakers, stance_mod, duration_multiplier, duration)
	managers.menu:set_mouse_sensitivity(self:in_steelsight())
end

function PlayerStandard:update_fov_external()
	if not alive(self._equipped_unit) then
		return
	end

	local stance_id = self._equipped_unit:base():get_stance_id()
	local stances = tweak_data.player.stances[stance_id] or tweak_data.player.stances.default
	local misc_attribs = self._state_data.in_steelsight and stances.steelsight or self._state_data.ducking and stances.crouched or stances.standard
	local new_fov = self:get_zoom_fov(misc_attribs) + 0

	self._camera_unit:base():set_fov_instant(new_fov)
end

function PlayerStandard:_get_max_walk_speed(t, force_run)
	local speed_tweak = self._tweak_data.movement.speed
	local movement_speed = speed_tweak.STANDARD_MAX
	local speed_state = "walk"

	if self._state_data.in_steelsight and not managers.player:has_category_upgrade("player", "steelsight_normal_movement_speed") and not _G.IS_VR then
		movement_speed = speed_tweak.STEELSIGHT_MAX
		speed_state = "steelsight"
	elseif self:on_ladder() then
		movement_speed = speed_tweak.CLIMBING_MAX
		speed_state = "climb"
	elseif self._state_data.ducking then
		movement_speed = speed_tweak.CROUCHING_MAX
		speed_state = "crouch"
	elseif self._state_data.in_air then
		movement_speed = speed_tweak.INAIR_MAX
		speed_state = nil
	elseif self._running or force_run then
		movement_speed = speed_tweak.RUNNING_MAX
		speed_state = "run"
	end

	movement_speed = managers.modifiers:modify_value("PlayerStandard:GetMaxWalkSpeed", movement_speed, self._state_data, speed_tweak)
	local morale_boost_bonus = self._ext_movement:morale_boost()
	local multiplier = managers.player:movement_speed_multiplier(speed_state, speed_state and morale_boost_bonus and morale_boost_bonus.move_speed_bonus, nil, self._ext_damage:health_ratio())
	multiplier = multiplier * (self._tweak_data.movement.multiplier[speed_state] or 1)
	local apply_weapon_penalty = true

	if self:_is_meleeing() then
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		apply_weapon_penalty = not tweak_data.blackmarket.melee_weapons[melee_entry].stats.remove_weapon_movement_penalty
	end

	if alive(self._equipped_unit) and apply_weapon_penalty then
		multiplier = multiplier * self._equipped_unit:base():movement_penalty()
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "increased_movement_speed") then
		multiplier = multiplier * managers.player:temporary_upgrade_value("temporary", "increased_movement_speed", 1)
	end

	local final_speed = movement_speed * multiplier
	self._cached_final_speed = self._cached_final_speed or 0

	if final_speed ~= self._cached_final_speed then
		self._cached_final_speed = final_speed

		self._ext_network:send("action_change_speed", final_speed)
	end

	return final_speed
end

function PlayerStandard:_start_action_steelsight(t, gadget_state)
	if self:_changing_weapon() or self:_is_reloading() or self:_interacting() or self:_is_meleeing() or self._use_item_expire_t or self:_is_throwing_projectile() or self:_on_zipline() then
		self._steelsight_wanted = true

		return
	end

	if self._running and not self._end_running_expire_t then
		self:_interupt_action_running(t)

		self._steelsight_wanted = true

		return
	end

	self:_break_intimidate_redirect(t)

	self._steelsight_wanted = false
	self._state_data.in_steelsight = true

	self:_update_crosshair_offset()
	self:_stance_entered()
	self:_interupt_action_running(t)
	self:_interupt_action_cash_inspect(t)

	local weap_base = self._equipped_unit:base()

	if gadget_state ~= nil then
		weap_base:play_sound("gadget_steelsight_" .. (gadget_state and "enter" or "exit"))
	else
		weap_base:play_tweak_data_sound("enter_steelsight")
	end

	if weap_base:weapon_tweak_data().animations.has_steelsight_stance then
		self:_need_to_play_idle_redirect()

		self._state_data.steelsight_weight_target = 1

		self._camera_unit:base():set_steelsight_anim_enabled(true)
	end

	self._state_data.reticle_obj = weap_base.get_reticle_obj and weap_base:get_reticle_obj()

	if managers.controller:get_default_wrapper_type() ~= "pc" and managers.user:get_setting("aim_assist") then
		local closest_ray = self._equipped_unit:base():check_autoaim(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), nil, true)

		self._camera_unit:base():clbk_aim_assist(closest_ray)
	end

	self._ext_network:send("set_stance", 3, false, false)
	managers.job:set_memory("cac_4", true)
end

function PlayerStandard:_end_action_steelsight(t)
	self._state_data.in_steelsight = false
	self._state_data.reticle_obj = nil

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._camera_unit:base():clbk_stop_aim_assist()

	local weap_base = self._equipped_unit:base()

	weap_base:play_tweak_data_sound("leave_steelsight")

	if weap_base:weapon_tweak_data().animations.has_steelsight_stance then
		self:_need_to_play_idle_redirect()

		self._state_data.steelsight_weight_target = 0

		self._camera_unit:base():set_steelsight_anim_enabled(true)
	end

	self._ext_network:send("set_stance", 3, false, false)
end

function PlayerStandard:_need_to_play_idle_redirect()
	if not self._camera_unit:base():anims_enabled() or self._camera_unit:base():playing_empty_state() then
		self._ext_camera:play_redirect(self:get_animation("idle"))
	end
end

function PlayerStandard:_interupt_action_steelsight(t)
	self._steelsight_wanted = false

	if self._state_data.in_steelsight then
		self:_end_action_steelsight(t)
	end
end

function PlayerStandard:_update_steelsight_timers(t, dt)
	if self._state_data.steelsight_weight_target then
		self._state_data.steelsight_weight = self._state_data.steelsight_weight or 0
		self._state_data.steelsight_weight = math.step(self._state_data.steelsight_weight, self._state_data.steelsight_weight_target, dt * 5)

		self._camera_unit:anim_state_machine():set_global("steelsight_weight", self._state_data.steelsight_weight)

		if self._state_data.steelsight_weight == self._state_data.steelsight_weight_target then
			self._camera_unit:base():set_steelsight_anim_enabled(false)

			self._state_data.steelsight_weight_target = nil
		end
	end
end

function PlayerStandard:_start_action_running(t)
	if not self._move_dir then
		self._running_wanted = true

		return
	end

	if self:on_ladder() or self:_on_zipline() then
		return
	end

	if self._shooting and not self._equipped_unit:base():run_and_shoot_allowed() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t or self._state_data.in_air or self:_is_throwing_projectile() or self:_is_charging_weapon() then
		self._running_wanted = true

		return
	end

	if self._state_data.ducking and not self:_can_stand() then
		self._running_wanted = true

		return
	end

	if not self:_can_run_directional() then
		return
	end

	self._running_wanted = false

	if managers.player:get_player_rule("no_run") then
		return
	end

	if not self._unit:movement():is_above_stamina_threshold() then
		return
	end

	if (not self._state_data.shake_player_start_running or not self._ext_camera:shaker():is_playing(self._state_data.shake_player_start_running)) and managers.user:get_setting("use_headbob") then
		self._state_data.shake_player_start_running = self._ext_camera:play_shaker("player_start_running", 0.75)
	end

	self:set_running(true)

	self._end_running_expire_t = nil
	self._start_running_t = t
	self._play_stop_running_anim = nil

	if not self:_is_reloading() or not self.RUN_AND_RELOAD then
		if not self._equipped_unit:base():run_and_shoot_allowed() then
			self._ext_camera:play_redirect(self:get_animation("start_running"))
		else
			self._ext_camera:play_redirect(self:get_animation("idle"))
		end
	end

	if not self.RUN_AND_RELOAD then
		self:_interupt_action_reload(t)
	end

	self:_interupt_action_steelsight(t)
	self:_interupt_action_ducking(t)
end

function PlayerStandard:_end_action_running(t)
	if not self._end_running_expire_t then
		local speed_multiplier = self._equipped_unit:base():exit_run_speed_multiplier()
		self._end_running_expire_t = t + 0.4 / speed_multiplier
		local stop_running = not self._equipped_unit:base():run_and_shoot_allowed() and (not self.RUN_AND_RELOAD or not self:_is_reloading())

		if stop_running then
			self._ext_camera:play_redirect(self:get_animation("stop_running"), speed_multiplier)
		end
	end
end

function PlayerStandard:_interupt_action_running(t)
	if self._running and not self._end_running_expire_t then
		self:_end_action_running(t)
	end
end

function PlayerStandard:_start_action_ducking(t)
	if self:_interacting() or self:_on_zipline() then
		return
	end

	self:_interupt_action_running(t)

	self._state_data.ducking = true

	self:_stance_entered()
	self:_update_crosshair_offset()

	local velocity = self._unit:mover():velocity()

	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_DUCK, velocity)
	self._ext_network:send("action_change_pose", 2, self._unit:position())
	self:_upd_attention()
end

function PlayerStandard:_end_action_ducking(t, skip_can_stand_check)
	if not skip_can_stand_check and not self:_can_stand() then
		return
	end

	self._state_data.ducking = false

	self:_stance_entered()
	self:_update_crosshair_offset()

	local velocity = self._unit:mover():velocity()

	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_STAND, velocity)
	self._ext_network:send("action_change_pose", 1, self._unit:position())
	self:_upd_attention()
end

function PlayerStandard:_interupt_action_ducking(t, skip_can_stand_check)
	if self._state_data.ducking then
		self:_end_action_ducking(t, skip_can_stand_check)
	end
end

function PlayerStandard:_can_stand(ignored_bodies)
	local offset = 50
	local radius = 30
	local hips_pos = self._obj_com:position() + math.UP * offset
	local up_pos = math.UP * (160 - offset)

	mvector3.add(up_pos, hips_pos)

	local ray_table = {
		"ray",
		hips_pos,
		up_pos,
		"slot_mask",
		self._slotmask_gnd_ray,
		"ray_type",
		"body mover",
		"sphere_cast_radius",
		radius,
		"bundle",
		20
	}

	if ignored_bodies then
		table.insert(ray_table, "ignore_body")
		table.insert(ray_table, ignored_bodies)
	end

	local ray = World:raycast(unpack(ray_table))

	if ray then
		if alive(ray.body) and not ray.body:collides_with_mover() then
			ignored_bodies = ignored_bodies or {}

			table.insert(ignored_bodies, ray.body)

			return self:_can_stand(ignored_bodies)
		end

		managers.hint:show_hint("cant_stand_up", 2)

		return false
	end

	return true
end

function PlayerStandard:_can_run_directional()
	if managers.player:has_category_upgrade("player", "can_free_run") then
		return true
	end

	local running_angle = managers.player:has_category_upgrade("player", "can_strafe_run") and 92 or 50

	return mvector3.angle(self._stick_move, math.Y) <= running_angle
end

function PlayerStandard:_start_action_equip(redirect, extra_time)
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	self._equip_weapon_expire_t = managers.player:player_timer():time() + (tweak_data.timers.equip or 0.7) + (extra_time or 0)

	if redirect == self:get_animation("equip") then
		self._equipped_unit:base():tweak_data_anim_stop("unequip")
		self._equipped_unit:base():tweak_data_anim_play("equip")
	end

	local result = self._ext_camera:play_redirect(redirect or self:get_animation("equip"))
end

function PlayerStandard:_check_action_throw_projectile(t, input)
	local projectile_entry = managers.blackmarket:equipped_projectile()
	local projectile_tweak = tweak_data.blackmarket.projectiles[projectile_entry]

	if projectile_tweak.is_a_grenade then
		return self:_check_action_throw_grenade(t, input)
	elseif projectile_tweak.ability then
		return self:_check_action_use_ability(t, input)
	end

	if self._state_data.projectile_throw_wanted then
		if not self._state_data.projectile_throw_allowed_t then
			self._state_data.projectile_throw_wanted = nil

			self:_do_action_throw_projectile(t, input)
		end

		return
	end

	local action_wanted = input.btn_projectile_press or input.btn_projectile_release or self._state_data.projectile_idle_wanted

	if not action_wanted then
		return
	end

	if not managers.player:can_throw_grenade() then
		self._state_data.projectile_throw_wanted = nil
		self._state_data.projectile_idle_wanted = nil

		return
	end

	if input.btn_projectile_release then
		if self._state_data.throwing_projectile then
			if self._state_data.projectile_throw_allowed_t then
				self._state_data.projectile_throw_wanted = true

				return
			end

			self:_do_action_throw_projectile(t, input)
		end

		return
	end

	local action_forbidden = not PlayerBase.USE_GRENADES or not self:_projectile_repeat_allowed() or self:chk_action_forbidden("interact") or self:_interacting() or self:is_deploying() or self:_changing_weapon() or self:_is_meleeing() or self:_is_using_bipod()

	if action_forbidden then
		return
	end

	self:_start_action_throw_projectile(t, input)

	return true
end

function PlayerStandard:_start_action_throw_projectile(t, input)
	self._equipped_unit:base():tweak_data_anim_stop("fire")
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	self._state_data.projectile_idle_wanted = nil
	self._state_data.throwing_projectile = true
	self._state_data.projectile_start_t = nil
	local projectile_entry = managers.blackmarket:equipped_projectile()

	self:_stance_entered()

	if self._state_data.projectile_global_value then
		self._camera_unit:anim_state_machine():set_global(self._state_data.projectile_global_value, 0)
	end

	self._state_data.projectile_global_value = tweak_data.blackmarket.projectiles[projectile_entry].anim_global_param or "projectile_frag"

	self._camera_unit:anim_state_machine():set_global(self._state_data.projectile_global_value, 1)

	local current_state_name = self._camera_unit:anim_state_machine():segment_state(self:get_animation("base"))
	local throw_allowed_expire_t = tweak_data.blackmarket.projectiles[projectile_entry].throw_allowed_expire_t or 0.15
	self._state_data.projectile_throw_allowed_t = t + (current_state_name ~= self:get_animation("projectile_throw_state") and throw_allowed_expire_t or 0)

	if current_state_name == self:get_animation("projectile_throw_state") then
		self._ext_camera:play_redirect(self:get_animation("projectile_idle"))

		return
	end

	local offset = nil

	if current_state_name == self:get_animation("projectile_exit_state") then
		local segment_relative_time = self._camera_unit:anim_state_machine():segment_relative_time(self:get_animation("base"))
		offset = (1 - segment_relative_time) * 0.9
	end

	self._ext_camera:play_redirect(self:get_animation("projectile_enter"), nil, offset)
end

function PlayerStandard:_is_throwing_projectile()
	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		return self:_is_throwing_grenade()
	end

	return self._state_data.throwing_projectile or self._state_data.projectile_expire_t and true
end

function PlayerStandard:in_throw_projectile()
	return self._state_data.throwing_projectile and true
end

function PlayerStandard:_projectile_repeat_allowed()
	return not self._camera_unit_anim_data.throwing and not self._state_data.throwing_projectile and not self._state_data.projectile_repeat_expire_t
end

function PlayerStandard:_do_action_throw_projectile(t, input, drop_projectile)
	local current_state_name = self._camera_unit:anim_state_machine():segment_state(self:get_animation("base"))
	self._state_data.throwing_projectile = nil
	local projectile_entry = managers.blackmarket:equipped_projectile()
	local projectile_data = tweak_data.blackmarket.projectiles[projectile_entry]
	self._state_data.projectile_expire_t = t + projectile_data.expire_t
	self._state_data.projectile_repeat_expire_t = t + math.min(projectile_data.repeat_expire_t, projectile_data.expire_t)

	managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, "throw_grenade")

	self._state_data.projectile_global_value = projectile_data.anim_global_param or "projectile_frag"

	self._camera_unit:anim_state_machine():set_global(self._state_data.projectile_global_value, 1)
	self._ext_camera:play_redirect(self:get_animation("projectile_throw"))
	self:_stance_entered()
end

function PlayerStandard:_interupt_action_throw_projectile(t)
	if not self:_is_throwing_projectile() then
		return
	end

	self._state_data.projectile_idle_wanted = nil
	self._state_data.projectile_expire_t = nil
	self._state_data.projectile_throw_allowed_t = nil
	self._state_data.throwing_projectile = nil
	self._camera_unit_anim_data.throwing = nil

	self._ext_camera:play_redirect(self:get_animation("equip"))
	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip")
	self._camera_unit:base():unspawn_grenade()
	self._camera_unit:base():show_weapon()
	self:_stance_entered()
end

function PlayerStandard:_update_throw_projectile_timers(t, input)
	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		return self:_update_throw_grenade_timers(t, input)
	end

	if self._state_data.projectile_throw_allowed_t and self._state_data.projectile_throw_allowed_t <= t then
		self._state_data.projectile_start_t = t
		self._state_data.projectile_throw_allowed_t = nil
	end

	if self._state_data.projectile_repeat_expire_t and self._state_data.projectile_repeat_expire_t <= t then
		self._state_data.projectile_repeat_expire_t = nil

		if input.btn_projectile_state then
			self._state_data.projectile_idle_wanted = true
		end
	end

	if self._state_data.projectile_expire_t and self._state_data.projectile_expire_t <= t then
		self._state_data.projectile_expire_t = nil
		self._state_data.projectile_repeat_expire_t = nil

		self:_stance_entered()

		if self._equipped_unit and input.btn_steelsight_state then
			self._steelsight_wanted = true
		end
	end
end

function PlayerStandard:_check_action_throw_grenade(t, input)
	local action_wanted = input.btn_throw_grenade_press

	if not action_wanted then
		return
	end

	if not managers.player:can_throw_grenade() then
		return
	end

	local action_forbidden = not PlayerBase.USE_GRENADES or self:chk_action_forbidden("interact") or self._unit:base():stats_screen_visible() or self:_is_throwing_grenade() or self:_interacting() or self:is_deploying() or self:_changing_weapon() or self:_is_meleeing() or self:_is_using_bipod()

	if action_forbidden then
		return
	end

	self:_start_action_throw_grenade(t, input)

	return action_wanted
end

function PlayerStandard:_get_projectile_throw_offset()
	if not self.projectile_throw_delays[self._projectile_global_value] then
		Application:error("No projectile throw delay for ", self._projectile_global_value, "! This needs to be added to PlayerStandard!")

		self._debug_throw_anim_req_update = true

		return 0
	end

	return self.projectile_throw_delays[self._projectile_global_value]
end

function PlayerStandard:_start_action_throw_grenade(t, input)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	local equipped_grenade = managers.blackmarket:equipped_grenade()
	local projectile_tweak = tweak_data.blackmarket.projectiles[equipped_grenade]

	if self._projectile_global_value then
		self._camera_unit:anim_state_machine():set_global(self._projectile_global_value, 0)

		self._projectile_global_value = nil
	end

	if projectile_tweak.anim_global_param then
		self._projectile_global_value = projectile_tweak.anim_global_param

		self._camera_unit:anim_state_machine():set_global(self._projectile_global_value, 1)
	end

	local delay = self:_get_projectile_throw_offset()

	managers.network:session():send_to_peers_synched("play_distance_interact_redirect_delay", self._unit, "throw_grenade", delay)
	self._ext_camera:play_redirect(Idstring(projectile_tweak.animation or "throw_grenade"))

	local projectile_data = tweak_data.blackmarket.projectiles[equipped_grenade]
	self._state_data.throw_grenade_expire_t = t + (projectile_data.expire_t or 1.1)

	self:_stance_entered()
end

function PlayerStandard:_update_throw_grenade_timers(t, input)
	if self._state_data.throw_grenade_expire_t and self._state_data.throw_grenade_expire_t <= t then
		self._state_data.throw_grenade_expire_t = nil

		self:_stance_entered()

		if self._equipped_unit and input.btn_steelsight_state then
			self._steelsight_wanted = true
		end
	end
end

function PlayerStandard:_interupt_action_throw_grenade(t, input)
	if not self:_is_throwing_grenade() then
		return
	end

	self._ext_camera:play_redirect(self:get_animation("equip"))
	self._camera_unit:base():unspawn_grenade()
	self._camera_unit:base():show_weapon()

	self._state_data.throw_grenade_expire_t = nil

	self:_stance_entered()
end

function PlayerStandard:_is_throwing_grenade()
	return (self._camera_unit_anim_data.throwing or self._state_data.throw_grenade_expire_t) and true or false
end

function PlayerStandard:_check_action_use_ability(t, input)
	local action_wanted = input.btn_throw_grenade_press

	if not action_wanted then
		return
	end

	local equipped_ability = managers.blackmarket:equipped_grenade()

	if not managers.player:attempt_ability(equipped_ability) then
		return
	end

	return action_wanted
end

function PlayerStandard:_check_action_interact(t, input)
	local keyboard = self._controller.TYPE == "pc" or managers.controller:get_default_wrapper_type() == "pc"
	local new_action, timer, interact_object = nil

	if input.btn_interact_press then
		if _G.IS_VR then
			self._interact_hand = input.btn_interact_left_press and PlayerHand.LEFT or PlayerHand.RIGHT
		end

		if not self:_action_interact_forbidden() then
			new_action, timer, interact_object = self._interaction:interact(self._unit, input.data, self._interact_hand)

			if new_action then
				self:_play_interact_redirect(t, input)
			end

			if timer then
				new_action = true

				self._ext_camera:camera_unit():base():set_limits(80, 50)
				self:_start_action_interact(t, input, timer, interact_object)
			end

			if not new_action then
				self._start_intimidate = true
				self._start_intimidate_t = t
			end
		end
	end

	local secondary_delay = tweak_data.team_ai.stop_action.delay
	local force_secondary_intimidate = false

	if not new_action and keyboard and input.btn_interact_secondary_press then
		force_secondary_intimidate = true
	end

	if input.btn_interact_release then
		local released = true

		if _G.IS_VR then
			local release_hand = input.btn_interact_left_release and PlayerHand.LEFT or PlayerHand.RIGHT
			released = release_hand == self._interact_hand
		end

		if released then
			if self._start_intimidate and not self:_action_interact_forbidden() then
				if t < self._start_intimidate_t + secondary_delay then
					self:_start_action_intimidate(t)

					self._start_intimidate = false
				end
			else
				self:_interupt_action_interact()
			end
		end
	end

	if (self._start_intimidate or force_secondary_intimidate) and not self:_action_interact_forbidden() and (not keyboard and t > self._start_intimidate_t + secondary_delay or force_secondary_intimidate) then
		self:_start_action_intimidate(t, true)

		self._start_intimidate = false
	end

	return new_action
end

function PlayerStandard:_action_interact_forbidden()
	local action_forbidden = self:chk_action_forbidden("interact") or self._unit:base():stats_screen_visible() or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline()

	return action_forbidden
end

function PlayerStandard:_check_action_change_equipment(t, input)
	if input.btn_change_equipment and managers.player:has_category_upgrade("player", "second_deployable") then
		self:_switch_equipment()

		if self:is_deploying() then
			self:_interupt_action_use_item()
			self:_start_action_use_item(t)
		end
	end
end

function PlayerStandard:_switch_equipment()
	managers.player:switch_equipment()
end

function PlayerStandard:_play_equip_animation()
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	self._equip_weapon_expire_t = managers.player:player_timer():time() + (tweak_data.timers.equip or 0.7)
	local result = self._ext_camera:play_redirect(self:get_animation("equip"))

	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip")
end

function PlayerStandard:_play_unequip_animation()
	self._ext_camera:play_redirect(self:get_animation("unequip"))
	self._equipped_unit:base():tweak_data_anim_stop("equip")
	self._equipped_unit:base():tweak_data_anim_play("unequip")
end

function PlayerStandard:_start_action_interact(t, input, timer, interact_object)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	local final_timer = timer
	final_timer = managers.modifiers:modify_value("PlayerStandard:OnStartInteraction", final_timer, interact_object)
	self._interact_expire_t = final_timer
	local start_timer = 0
	self._interact_params = {
		object = interact_object,
		timer = final_timer,
		tweak_data = interact_object:interaction().tweak_data
	}

	self:_play_unequip_animation()
	managers.hud:show_interaction_bar(start_timer, final_timer)
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, true, self._interact_params.tweak_data, final_timer, false)
	self._unit:network():send("sync_interaction_anim", true, self._interact_params.tweak_data)
end

function PlayerStandard:_interupt_action_interact(t, input, complete)
	if self._interact_expire_t then
		self._interact_expire_t = nil

		if alive(self._interact_params.object) then
			self._interact_params.object:interaction():interact_interupt(self._unit, complete)
		end

		self._ext_camera:camera_unit():base():remove_limits()
		self._interaction:interupt_action_interact(self._unit)
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, false, self._interact_params.tweak_data, 0, complete and true or false)

		self._interact_params = nil

		self:_play_equip_animation()
		managers.hud:hide_interaction_bar(complete)
		self._unit:network():send("sync_interaction_anim", false, "")
	end
end

function PlayerStandard:_end_action_interact()
	self:_interupt_action_interact(nil, nil, true)
	self._interaction:end_action_interact(self._unit)
end

function PlayerStandard:_interacting()
	return self._interact_expire_t
end

function PlayerStandard:interupt_interact()
	if self:_interacting() then
		self:_interupt_action_interact()
		self._interaction:interupt_action_interact()

		self._interact_expire_t = nil
	end
end

function PlayerStandard:_get_interaction_speed()
	local dt = managers.player:player_timer():delta_time()

	return dt
end

function PlayerStandard:_update_interaction_timers(t)
	if self._interact_expire_t then
		local dt = self:_get_interaction_speed()
		self._interact_expire_t = self._interact_expire_t - dt

		if not alive(self._interact_params.object) or self._interact_params.object ~= self._interaction:active_unit() or self._interact_params.tweak_data ~= self._interact_params.object:interaction().tweak_data or self._interact_params.object:interaction():check_interupt() then
			self:_interupt_action_interact(t)
		else
			local current = self._interact_params.timer - self._interact_expire_t
			local total = self._interact_params.timer

			managers.hud:set_interaction_bar_width(current, total)

			if self._interact_expire_t <= 0 then
				self:_end_action_interact(t)

				self._interact_expire_t = nil
			end
		end
	end
end

function PlayerStandard:_check_action_weapon_firemode(t, input)
	if input.btn_weapon_firemode_press and self._equipped_unit:base().toggle_firemode then
		self:_check_stop_shooting()

		if self._equipped_unit:base():toggle_firemode() then
			managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, self._unit:inventory():equipped_selection(), self._equipped_unit:base():fire_mode())
		end
	end
end

function PlayerStandard:_toggle_gadget(weap_base)
	local gadget_index = 0

	if weap_base.toggle_gadget and weap_base:has_gadget() and weap_base:toggle_gadget(self) then
		gadget_index = weap_base:current_gadget_index()

		self._unit:network():send("set_weapon_gadget_state", weap_base._gadget_on)

		local gadget = weap_base:get_active_gadget()

		if gadget and gadget.color then
			local col = gadget:color()

			self._unit:network():send("set_weapon_gadget_color", col.r * 255, col.g * 255, col.b * 255)
		end

		if alive(self._equipped_unit) then
			managers.hud:set_ammo_amount(weap_base:selection_index(), weap_base:ammo_info())
		end
	end
end

function PlayerStandard:_check_action_weapon_gadget(t, input)
	if input.btn_weapon_gadget_press then
		self:_toggle_gadget(self._equipped_unit:base())
	end
end

function PlayerStandard:_check_action_melee(t, input)
	if self._state_data.melee_attack_wanted then
		if not self._state_data.melee_attack_allowed_t then
			self._state_data.melee_attack_wanted = nil

			self:_do_action_melee(t, input)
		end

		return
	end

	local action_wanted = input.btn_melee_press or input.btn_melee_release or self._state_data.melee_charge_wanted

	if not action_wanted then
		return
	end

	if input.btn_melee_release then
		if self._state_data.meleeing then
			if self._state_data.melee_attack_allowed_t then
				self._state_data.melee_attack_wanted = true

				return
			end

			self:_do_action_melee(t, input)
		end

		return
	end

	local action_forbidden = not self:_melee_repeat_allowed() or self._use_item_expire_t or self:_changing_weapon() or self:_interacting() or self:_is_throwing_projectile() or self:_is_using_bipod()

	if action_forbidden then
		return
	end

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant = tweak_data.blackmarket.melee_weapons[melee_entry].instant

	self:_start_action_melee(t, input, instant)

	return true
end

function PlayerStandard:_start_action_melee(t, input, instant)
	self._equipped_unit:base():tweak_data_anim_stop("fire")
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	self._state_data.melee_charge_wanted = nil
	self._state_data.meleeing = true
	self._state_data.melee_start_t = nil
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local bayonet_id = managers.blackmarket:equipped_bayonet(primary_id)
	local bayonet_melee = false

	if bayonet_id and melee_entry == "weapon" and self._equipped_unit:base():selection_index() == 2 then
		bayonet_melee = true
	end

	if instant then
		self:_do_action_melee(t, input)

		return
	end

	self:_stance_entered()

	if self._state_data.melee_global_value then
		self._camera_unit:anim_state_machine():set_global(self._state_data.melee_global_value, 0)
	end

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	self._state_data.melee_global_value = tweak_data.blackmarket.melee_weapons[melee_entry].anim_global_param

	self._camera_unit:anim_state_machine():set_global(self._state_data.melee_global_value, 1)

	local current_state_name = self._camera_unit:anim_state_machine():segment_state(self:get_animation("base"))
	local attack_allowed_expire_t = tweak_data.blackmarket.melee_weapons[melee_entry].attack_allowed_expire_t or 0.15
	self._state_data.melee_attack_allowed_t = t + (current_state_name ~= self:get_animation("melee_attack_state") and attack_allowed_expire_t or 0)
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant

	if not instant_hit then
		self._ext_network:send("sync_melee_start", 0)
	end

	if current_state_name == self:get_animation("melee_attack_state") then
		self._ext_camera:play_redirect(self:get_animation("melee_charge"))

		return
	end

	local offset = nil

	if current_state_name == self:get_animation("melee_exit_state") then
		local segment_relative_time = self._camera_unit:anim_state_machine():segment_relative_time(self:get_animation("base"))
		offset = (1 - segment_relative_time) * 0.9
	end

	offset = math.max(offset or 0, attack_allowed_expire_t)

	self._ext_camera:play_redirect(self:get_animation("melee_enter"), nil, offset)
end

function PlayerStandard:_is_meleeing()
	return self._state_data.meleeing or self._state_data.melee_expire_t and true
end

function PlayerStandard:in_melee()
	return self._state_data.meleeing and true
end

function PlayerStandard:discharge_melee()
	self:_do_action_melee(managers.player:player_timer():time(), nil, true)
end

function PlayerStandard:_melee_repeat_allowed()
	return not self._state_data.meleeing and not self._state_data.melee_repeat_expire_t
end

function PlayerStandard:_get_melee_charge_lerp_value(t, offset)
	offset = offset or 0
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local max_charge_time = tweak_data.blackmarket.melee_weapons[melee_entry].stats.charge_time

	if not self._state_data.melee_start_t then
		return 0
	end

	return math.clamp(t - self._state_data.melee_start_t - offset, 0, max_charge_time) / max_charge_time
end

local melee_vars = {
	"player_melee",
	"player_melee_var2"
}

function PlayerStandard:_do_action_melee(t, input, skip_damage)
	self._state_data.meleeing = nil
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	local pre_calc_hit_ray = tweak_data.blackmarket.melee_weapons[melee_entry].hit_pre_calculation
	local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	melee_damage_delay = math.min(melee_damage_delay, tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t)
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local bayonet_id = managers.blackmarket:equipped_bayonet(primary_id)
	local bayonet_melee = false

	if bayonet_id and self._equipped_unit:base():selection_index() == 2 then
		bayonet_melee = true
	end

	self._state_data.melee_expire_t = t + tweak_data.blackmarket.melee_weapons[melee_entry].expire_t
	self._state_data.melee_repeat_expire_t = t + math.min(tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t, tweak_data.blackmarket.melee_weapons[melee_entry].expire_t)

	if not instant_hit and not skip_damage then
		self._state_data.melee_damage_delay_t = t + melee_damage_delay

		if pre_calc_hit_ray then
			self._state_data.melee_hit_ray = self:_calc_melee_hit_ray(t, 20) or true
		else
			self._state_data.melee_hit_ray = nil
		end
	end

	local send_redirect = instant_hit and (bayonet_melee and "melee_bayonet" or "melee") or "melee_item"

	if instant_hit then
		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, send_redirect)
	else
		self._ext_network:send("sync_melee_discharge")
	end

	if self._state_data.melee_charge_shake then
		self._ext_camera:shaker():stop(self._state_data.melee_charge_shake)

		self._state_data.melee_charge_shake = nil
	end

	self._melee_attack_var = 0

	if instant_hit then
		local hit = skip_damage or self:_do_melee_damage(t, bayonet_melee)

		if hit then
			self._ext_camera:play_redirect(bayonet_melee and self:get_animation("melee_bayonet") or self:get_animation("melee"))
		else
			self._ext_camera:play_redirect(bayonet_melee and self:get_animation("melee_miss_bayonet") or self:get_animation("melee_miss"))
		end
	else
		local state = self._ext_camera:play_redirect(self:get_animation("melee_attack"))
		local anim_attack_vars = tweak_data.blackmarket.melee_weapons[melee_entry].anim_attack_vars
		self._melee_attack_var = anim_attack_vars and math.random(#anim_attack_vars)

		self:_play_melee_sound(melee_entry, "hit_air", self._melee_attack_var)

		local melee_item_tweak_anim = "attack"
		local melee_item_prefix = ""
		local melee_item_suffix = ""
		local anim_attack_param = anim_attack_vars and anim_attack_vars[self._melee_attack_var]

		if anim_attack_param then
			self._camera_unit:anim_state_machine():set_parameter(state, anim_attack_param, 1)

			melee_item_prefix = anim_attack_param .. "_"
		end

		if self._state_data.melee_hit_ray and self._state_data.melee_hit_ray ~= true then
			self._camera_unit:anim_state_machine():set_parameter(state, "hit", 1)

			melee_item_suffix = "_hit"
		end

		melee_item_tweak_anim = melee_item_prefix .. melee_item_tweak_anim .. melee_item_suffix

		self._camera_unit:base():play_anim_melee_item(melee_item_tweak_anim)
	end
end

function PlayerStandard:_calc_melee_hit_ray(t, sphere_cast_radius)
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local range = tweak_data.blackmarket.melee_weapons[melee_entry].stats.range or 175
	local from = self._unit:movement():m_head_pos()
	local to = from + self._unit:movement():m_head_rot():y() * range

	return self._unit:raycast("ray", from, to, "slot_mask", self._slotmask_bullet_impact_targets, "sphere_cast_radius", sphere_cast_radius, "ray_type", "body melee")
end

function PlayerStandard:_do_melee_damage(t, bayonet_melee, melee_hit_ray, melee_entry, hand_id)
	melee_entry = melee_entry or managers.blackmarket:equipped_melee_weapon()
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	local charge_lerp_value = instant_hit and 0 or self:_get_melee_charge_lerp_value(t, melee_damage_delay)

	self._ext_camera:play_shaker(melee_vars[math.random(#melee_vars)], math.max(0.3, charge_lerp_value))

	local sphere_cast_radius = 20
	local col_ray = nil

	if melee_hit_ray then
		col_ray = melee_hit_ray ~= true and melee_hit_ray or nil
	else
		col_ray = self:_calc_melee_hit_ray(t, sphere_cast_radius)
	end

	if col_ray and alive(col_ray.unit) then
		local damage, damage_effect = managers.blackmarket:equipped_melee_weapon_damage_info(charge_lerp_value)
		local damage_effect_mul = math.max(managers.player:upgrade_value("player", "melee_knockdown_mul", 1), managers.player:upgrade_value(self._equipped_unit:base():weapon_tweak_data().categories and self._equipped_unit:base():weapon_tweak_data().categories[1], "melee_knockdown_mul", 1))
		damage = damage * managers.player:get_melee_dmg_multiplier()
		damage_effect = damage_effect * damage_effect_mul
		col_ray.sphere_cast_radius = sphere_cast_radius
		local hit_unit = col_ray.unit

		if hit_unit:character_damage() then
			if bayonet_melee then
				self._unit:sound():play("fairbairn_hit_body", nil, false)
			else
				local hit_sfx = "hit_body"

				if hit_unit:character_damage() and hit_unit:character_damage().melee_hit_sfx then
					hit_sfx = hit_unit:character_damage():melee_hit_sfx()
				end

				self:_play_melee_sound(melee_entry, hit_sfx, self._melee_attack_var)
			end

			if not hit_unit:character_damage()._no_blood then
				managers.game_play_central:play_impact_flesh({
					col_ray = col_ray
				})
				managers.game_play_central:play_impact_sound_and_effects({
					no_decal = true,
					no_sound = true,
					col_ray = col_ray
				})
			end

			self._camera_unit:base():play_anim_melee_item("hit_body")
		elseif self._on_melee_restart_drill and hit_unit:base() and (hit_unit:base().is_drill or hit_unit:base().is_saw) then
			hit_unit:base():on_melee_hit(managers.network:session():local_peer():id())
		else
			if bayonet_melee then
				self._unit:sound():play("knife_hit_gen", nil, false)
			else
				self:_play_melee_sound(melee_entry, "hit_gen", self._melee_attack_var)
			end

			self._camera_unit:base():play_anim_melee_item("hit_gen")
			managers.game_play_central:play_impact_sound_and_effects({
				no_decal = true,
				no_sound = true,
				col_ray = col_ray,
				effect = Idstring("effects/payday2/particles/impacts/fallback_impact_pd2")
			})
		end

		local custom_data = nil

		if _G.IS_VR and hand_id then
			custom_data = {
				engine = hand_id == 1 and "right" or "left"
			}
		end

		managers.rumble:play("melee_hit", nil, nil, custom_data)
		managers.game_play_central:physics_push(col_ray)

		local character_unit, shield_knock = nil
		local can_shield_knock = managers.player:has_category_upgrade("player", "shield_knock")

		if can_shield_knock and hit_unit:in_slot(8) and alive(hit_unit:parent()) and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() then
			shield_knock = true
			character_unit = hit_unit:parent()
		end

		character_unit = character_unit or hit_unit

		if character_unit:character_damage() and character_unit:character_damage().damage_melee then
			local dmg_multiplier = 1

			if not managers.enemy:is_civilian(character_unit) and not managers.groupai:state():is_enemy_special(character_unit) then
				dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "non_special_melee_multiplier", 1)
			else
				dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "melee_damage_multiplier", 1)
			end

			dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "melee_" .. tostring(tweak_data.blackmarket.melee_weapons[melee_entry].stats.weapon_type) .. "_damage_multiplier", 1)

			if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
				self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
				self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
					nil,
					0
				}
				local stack = self._state_data.stacking_dmg_mul.melee

				if stack[1] and t < stack[1] then
					dmg_multiplier = dmg_multiplier * (1 + managers.player:upgrade_value("melee", "stacking_hit_damage_multiplier", 0) * stack[2])
				else
					stack[2] = 0
				end
			end

			local health_ratio = self._ext_damage:health_ratio()
			local damage_health_ratio = managers.player:get_damage_health_ratio(health_ratio, "melee")

			if damage_health_ratio > 0 then
				local damage_ratio = damage_health_ratio
				dmg_multiplier = dmg_multiplier * (1 + managers.player:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0) * damage_ratio)
			end

			dmg_multiplier = dmg_multiplier * managers.player:temporary_upgrade_value("temporary", "berserker_damage_multiplier", 1)
			local target_dead = character_unit:character_damage().dead and not character_unit:character_damage():dead()
			local target_hostile = managers.enemy:is_enemy(character_unit) and not tweak_data.character[character_unit:base()._tweak_table].is_escort and character_unit:brain():is_hostile()
			local life_leach_available = managers.player:has_category_upgrade("temporary", "melee_life_leech") and not managers.player:has_activate_temporary_upgrade("temporary", "melee_life_leech")

			if target_dead and target_hostile and life_leach_available then
				managers.player:activate_temporary_upgrade("temporary", "melee_life_leech")
				self._unit:character_damage():restore_health(managers.player:temporary_upgrade_value("temporary", "melee_life_leech", 1))
			end

			local special_weapon = tweak_data.blackmarket.melee_weapons[melee_entry].special_weapon
			local action_data = {
				variant = "melee"
			}

			if special_weapon == "taser" then
				action_data.variant = "taser_tased"
			end

			if _G.IS_VR and melee_entry == "weapon" and not bayonet_melee then
				dmg_multiplier = 0.1
			end

			action_data.damage = shield_knock and 0 or damage * dmg_multiplier
			action_data.damage_effect = damage_effect
			action_data.attacker_unit = self._unit
			action_data.col_ray = col_ray

			if shield_knock then
				action_data.shield_knock = can_shield_knock
			end

			action_data.name_id = melee_entry
			action_data.charge_lerp_value = charge_lerp_value

			if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
				self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
				self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
					nil,
					0
				}
				local stack = self._state_data.stacking_dmg_mul.melee

				if character_unit:character_damage().dead and not character_unit:character_damage():dead() then
					stack[1] = t + managers.player:upgrade_value("melee", "stacking_hit_expire_t", 1)
					stack[2] = math.min(stack[2] + 1, tweak_data.upgrades.max_melee_weapon_dmg_mul_stacks or 5)
				else
					stack[1] = nil
					stack[2] = 0
				end
			end

			local defense_data = character_unit:character_damage():damage_melee(action_data)

			self:_check_melee_dot_damage(col_ray, defense_data, melee_entry)
			self:_perform_sync_melee_damage(hit_unit, col_ray, action_data.damage)

			return defense_data
		else
			self:_perform_sync_melee_damage(hit_unit, col_ray, damage)
		end
	end

	if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
		self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
		self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
			nil,
			0
		}
		local stack = self._state_data.stacking_dmg_mul.melee
		stack[1] = nil
		stack[2] = 0
	end

	return col_ray
end

PlayerStandard.MINMAX_MELEE_SYNC = {
	0,
	63
}

function PlayerStandard:_perform_sync_melee_damage(hit_unit, col_ray, damage)
	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		damage = math.clamp(damage, PlayerStandard.MINMAX_MELEE_SYNC[1], PlayerStandard.MINMAX_MELEE_SYNC[2])

		col_ray.body:extension().damage:damage_melee(self._unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
		managers.network:session():send_to_peers_synched("sync_body_damage_melee", col_ray.body, self._unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
	end
end

function PlayerStandard:_check_melee_dot_damage(col_ray, defense_data, melee_entry)
	if not defense_data or defense_data.type == "death" then
		return
	end

	local dot_data = tweak_data.blackmarket.melee_weapons[melee_entry].dot_data

	if not dot_data then
		return
	end

	local data = managers.dot:create_dot_data(dot_data.type, dot_data.custom_data)
	local damage_class = CoreSerialize.string_to_classtable(data.damage_class)

	damage_class:start_dot_damage(col_ray, nil, data, melee_entry)
end

function PlayerStandard:_play_melee_sound(melee_entry, sound_id, variation)
	local tweak_data = tweak_data.blackmarket.melee_weapons[melee_entry]

	if not tweak_data.sounds or not tweak_data.sounds[sound_id] then
		return
	end

	local post_event = tweak_data.sounds[sound_id]

	if type(post_event) == "table" then
		post_event = post_event[variation] or post_event[1]
	end

	self._unit:sound():play(post_event, nil, false)
end

function PlayerStandard:_interupt_action_melee(t)
	if not self:_is_meleeing() then
		return
	end

	self._state_data.melee_hit_ray = nil
	self._state_data.melee_charge_wanted = nil
	self._state_data.melee_expire_t = nil
	self._state_data.melee_repeat_expire_t = nil
	self._state_data.melee_attack_allowed_t = nil
	self._state_data.melee_damage_delay_t = nil
	self._state_data.meleeing = nil

	self._unit:sound():play("interupt_melee", nil, false)
	self:_play_melee_sound(managers.blackmarket:equipped_melee_weapon(), "hit_air", self._melee_attack_var)
	self._ext_camera:play_redirect(self:get_animation("equip"))
	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip")
	self._camera_unit:base():unspawn_melee_item()
	self._camera_unit:base():show_weapon()

	if self._state_data.melee_charge_shake then
		self._ext_camera:stop_shaker(self._state_data.melee_charge_shake)

		self._state_data.melee_charge_shake = nil
	end

	self:_stance_entered()
end

function PlayerStandard:_update_melee_timers(t, input)
	if self._state_data.meleeing then
		local lerp_value = self:_get_melee_charge_lerp_value(t)

		self._camera_unit:anim_state_machine():set_parameter(self:get_animation("melee_charge_state"), "charge_lerp", math.bezier({
			0,
			0,
			1,
			1
		}, lerp_value))

		if self._state_data.melee_charge_shake then
			self._ext_camera:shaker():set_parameter(self._state_data.melee_charge_shake, "amplitude", math.bezier({
				0,
				0,
				1,
				1
			}, lerp_value))
		end
	end

	if self._state_data.melee_damage_delay_t and self._state_data.melee_damage_delay_t <= t then
		self:_do_melee_damage(t, nil, self._state_data.melee_hit_ray)

		self._state_data.melee_damage_delay_t = nil
		self._state_data.melee_hit_ray = nil
	end

	if self._state_data.melee_attack_allowed_t and self._state_data.melee_attack_allowed_t <= t then
		self._state_data.melee_start_t = t
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		local melee_charge_shaker = tweak_data.blackmarket.melee_weapons[melee_entry].melee_charge_shaker or "player_melee_charge"
		self._state_data.melee_charge_shake = self._ext_camera:play_shaker(melee_charge_shaker, 0)
		self._state_data.melee_attack_allowed_t = nil
	end

	if self._state_data.melee_repeat_expire_t and self._state_data.melee_repeat_expire_t <= t then
		self._state_data.melee_repeat_expire_t = nil

		if input.btn_meleet_state then
			local melee_entry = managers.blackmarket:equipped_melee_weapon()
			local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
			self._state_data.melee_charge_wanted = not instant_hit and true
		end
	end

	if self._state_data.melee_expire_t and self._state_data.melee_expire_t <= t then
		self._state_data.melee_expire_t = nil
		self._state_data.melee_repeat_expire_t = nil

		self:_stance_entered()

		if self._equipped_unit and input.btn_steelsight_state then
			self._steelsight_wanted = true
		end
	end
end

function PlayerStandard:_check_action_reload(t, input)
	local new_action = nil
	local action_wanted = input.btn_reload_press

	if action_wanted then
		local action_forbidden = self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t or self:_interacting() or self:_is_throwing_projectile()

		if not action_forbidden and self._equipped_unit and not self._equipped_unit:base():clip_full() then
			self:_start_action_reload_enter(t)

			new_action = true
		end
	end

	return new_action
end

function PlayerStandard:_update_reload_timers(t, dt, input)
	if self._state_data.reload_enter_expire_t and self._state_data.reload_enter_expire_t <= t then
		self._state_data.reload_enter_expire_t = nil

		self:_start_action_reload(t)
	end

	if self._state_data.reload_expire_t then
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

			if self._equipped_unit:base():reload_exit_expire_t() then
				local speed_multiplier = self._equipped_unit:base():reload_speed_multiplier()

				if self._equipped_unit:base():started_reload_empty() then
					self._state_data.reload_exit_expire_t = t + self._equipped_unit:base():reload_exit_expire_t() / speed_multiplier

					self._ext_camera:play_redirect(self:get_animation("reload_exit"), speed_multiplier)
					self._equipped_unit:base():tweak_data_anim_play("reload_exit", speed_multiplier)
				else
					self._state_data.reload_exit_expire_t = t + self._equipped_unit:base():reload_not_empty_exit_expire_t() / speed_multiplier

					self._ext_camera:play_redirect(self:get_animation("reload_not_empty_exit"), speed_multiplier)
					self._equipped_unit:base():tweak_data_anim_play("reload_not_empty_exit", speed_multiplier)
				end
			elseif self._equipped_unit then
				if not interupt then
					self._equipped_unit:base():on_reload()
				end

				managers.statistics:reloaded()
				managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())

				if input.btn_steelsight_state then
					self._steelsight_wanted = true
				elseif self.RUN_AND_RELOAD and self._running and not self._end_running_expire_t and not self._equipped_unit:base():run_and_shoot_allowed() then
					self._ext_camera:play_redirect(self:get_animation("start_running"))
				end
			end
		end
	end

	if self._state_data.reload_exit_expire_t and self._state_data.reload_exit_expire_t <= t then
		self._state_data.reload_exit_expire_t = nil

		if self._equipped_unit then
			managers.statistics:reloaded()
			managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())

			if input.btn_steelsight_state then
				self._steelsight_wanted = true
			elseif self.RUN_AND_RELOAD and self._running and not self._end_running_expire_t and not self._equipped_unit:base():run_and_shoot_allowed() then
				self._ext_camera:play_redirect(self:get_animation("start_running"))
			end

			if self._equipped_unit:base().on_reload_stop then
				self._equipped_unit:base():on_reload_stop()
			end
		end
	end
end

function PlayerStandard:_check_use_item(t, input)
	local new_action = nil
	local action_wanted = input.btn_use_item_press

	if action_wanted then
		local action_forbidden = self._use_item_expire_t or self:_interacting() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing()

		if not action_forbidden and managers.player:can_use_selected_equipment(self._unit) then
			self:_start_action_use_item(t)

			new_action = true
		end
	end

	if input.btn_use_item_release then
		self:_interupt_action_use_item()
	end

	return new_action
end

function PlayerStandard:_update_use_item_timers(t, input)
	if self._use_item_expire_t then
		local valid = managers.player:check_selected_equipment_placement_valid(self._unit)
		local deploy_timer = managers.player:selected_equipment_deploy_timer()

		managers.hud:set_progress_timer_bar_valid(valid, not valid and "hud_deploy_valid_help")
		managers.hud:set_progress_timer_bar_width(deploy_timer - (self._use_item_expire_t - t), deploy_timer)

		if self._use_item_expire_t <= t then
			self:_end_action_use_item(valid)

			self._use_item_expire_t = nil
		end
	end
end

function PlayerStandard:_does_deploying_limit_movement()
	return self:is_deploying() and managers.player:selected_equipment_limit_movement() or false
end

function PlayerStandard:is_deploying()
	return self._use_item_expire_t and true or false
end

function PlayerStandard:_start_action_use_item(t)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	local deploy_timer = managers.player:selected_equipment_deploy_timer()
	self._use_item_expire_t = t + deploy_timer

	self:_play_unequip_animation()
	managers.hud:show_progress_timer_bar(0, deploy_timer)

	local text = managers.player:selected_equipment_deploying_text() or managers.localization:text("hud_deploying_equipment", {
		EQUIPMENT = managers.player:selected_equipment_name()
	})

	managers.hud:show_progress_timer({
		text = text
	})

	local post_event = managers.player:selected_equipment_sound_start()

	if post_event then
		self._unit:sound_source():post_event(post_event)
	end

	local equipment_id = managers.player:selected_equipment_id()

	managers.network:session():send_to_peers_synched("sync_teammate_progress", 2, true, equipment_id, deploy_timer, false)
end

function PlayerStandard:_end_action_use_item(valid)
	local post_event = managers.player:selected_equipment_sound_done()
	local result = managers.player:use_selected_equipment(self._unit)

	self:_interupt_action_use_item(nil, nil, valid)

	if valid and post_event then
		self._unit:sound_source():post_event(post_event)
	end

	local equipment = managers.player:selected_equipment()

	if equipment == nil then
		self:_switch_equipment()
	end
end

function PlayerStandard:_interupt_action_use_item(t, input, complete)
	if self._use_item_expire_t then
		self._use_item_expire_t = nil
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		self._equip_weapon_expire_t = managers.player:player_timer():time() + (tweak_data.timers.equip or 0.7)

		self:_play_equip_animation()
		managers.hud:hide_progress_timer_bar(complete)
		managers.hud:remove_progress_timer()

		local post_event = managers.player:selected_equipment_sound_interupt()

		if not complete and post_event then
			self._unit:sound_source():post_event(post_event)
		end

		self._unit:equipment():on_deploy_interupted()
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 2, false, "", 0, complete and true or false)
	end
end

function PlayerStandard:_check_change_weapon(t, input)
	local new_action = nil
	local action_wanted = input.btn_switch_weapon_press

	if action_wanted then
		local action_forbidden = self:_changing_weapon()
		action_forbidden = action_forbidden or self:_is_meleeing() or self._use_item_expire_t or self._change_item_expire_t
		action_forbidden = action_forbidden or self._unit:inventory():num_selections() == 1 or self:_interacting() or self:_is_throwing_projectile() or self:_is_deploying_bipod()

		if not action_forbidden then
			local data = {
				next = true
			}
			self._change_weapon_pressed_expire_t = t + 0.33

			self:_start_action_unequip_weapon(t, data)

			new_action = true

			managers.player:send_message(Message.OnSwitchWeapon)
		end
	end

	return new_action
end

function PlayerStandard:_update_equip_weapon_timers(t, input)
	if self._unequip_weapon_expire_t and self._unequip_weapon_expire_t <= t then
		if self._change_weapon_data.unequip_callback and not self._change_weapon_data.unequip_callback() then
			return
		end

		self._unequip_weapon_expire_t = nil

		self:_start_action_equip_weapon(t)
	end

	if self._equip_weapon_expire_t and self._equip_weapon_expire_t <= t then
		self._equip_weapon_expire_t = nil

		if input.btn_steelsight_state then
			self._steelsight_wanted = true
		end

		TestAPIHelper.on_event("load_weapon")
		TestAPIHelper.on_event("mask_up")
	end
end

function PlayerStandard:is_equipping()
	return self._equip_weapon_expire_t
end

function PlayerStandard:_add_unit_to_char_table(char_table, unit, unit_type, interaction_dist, interaction_through_walls, tight_area, priority, my_head_pos, cam_fwd, ray_ignore_units, ray_types)
	if unit:unit_data().disable_shout and not unit:brain():interaction_voice() then
		return
	end

	local u_head_pos = unit_type == 3 and unit:base():get_mark_check_position() or unit:movement():m_head_pos() + math.UP * 30
	local vec = u_head_pos - my_head_pos
	local dis = mvector3.normalize(vec)
	local max_dis = interaction_dist

	if dis < max_dis then
		local max_angle = math.max(8, math.lerp(tight_area and 30 or 90, tight_area and 10 or 30, dis / 1200))
		local angle = vec:angle(cam_fwd)

		if angle < max_angle then
			local ing_wgt = dis * dis * (1 - vec:dot(cam_fwd)) / priority

			if interaction_through_walls then
				table.insert(char_table, {
					unit = unit,
					inv_wgt = ing_wgt,
					unit_type = unit_type
				})
			else
				local ray = World:raycast("ray", my_head_pos, u_head_pos, "slot_mask", self._slotmask_AI_visibility, "ray_type", ray_types or "ai_vision", "ignore_unit", ray_ignore_units or {})

				if not ray or mvector3.distance_sq(ray.position, u_head_pos) < 900 then
					table.insert(char_table, {
						unit = unit,
						inv_wgt = ing_wgt,
						unit_type = unit_type
					})
				end
			end
		end
	end
end

function PlayerStandard:_get_interaction_target(char_table, my_head_pos, cam_fwd)
	local prime_target = nil
	local has_inspire = managers.player:has_enabled_cooldown_upgrade("cooldown", "long_dis_revive")

	for _, char in pairs(char_table) do
		if char.unit_type == 2 then
			if char.unit:base().is_husk_player then
				if char.unit:interaction():active() and char.unit:movement():need_revive() then
					prime_target = char

					break
				end
			elseif char.unit:character_damage():need_revive() then
				prime_target = char

				break
			end
		end
	end

	if not prime_target then
		local ray = World:raycast("ray", my_head_pos, my_head_pos + cam_fwd * 100 * 100, "slot_mask", self._slotmask_long_distance_interaction)

		if ray then
			for _, char in pairs(char_table) do
				if ray.unit == char.unit then
					prime_target = char

					break
				end
			end
		end
	end

	if not prime_target then
		local low_wgt = nil

		for _, char in pairs(char_table) do
			local inv_wgt = char.inv_wgt

			if not low_wgt or inv_wgt < low_wgt then
				low_wgt = inv_wgt
				prime_target = char
			end
		end
	end

	return prime_target
end

function PlayerStandard:_get_intimidation_action(prime_target, char_table, amount, primary_only, detect_only, secondary)
	local voice_type, new_action, plural = nil
	local unit_type_enemy = 0
	local unit_type_civilian = 1
	local unit_type_teammate = 2
	local unit_type_camera = 3
	local unit_type_turret = 4
	local is_whisper_mode = managers.groupai:state():whisper_mode()

	if prime_target then
		if prime_target.unit_type == unit_type_teammate then
			local is_human_player, record = nil

			if not detect_only then
				record = managers.groupai:state():all_criminals()[prime_target.unit:key()]

				if record.ai then
					if not prime_target.unit:brain():player_ignore() then
						prime_target.unit:movement():set_cool(false)
						prime_target.unit:brain():on_long_dis_interacted(0, self._unit, secondary)
					end
				else
					is_human_player = true
				end
			end

			local amount = 0
			local current_state_name = self._unit:movement():current_state_name()

			if current_state_name ~= "arrested" and current_state_name ~= "bleed_out" and current_state_name ~= "fatal" and current_state_name ~= "incapacitated" then
				local rally_skill_data = self._ext_movement:rally_skill_data()

				if rally_skill_data and mvector3.distance_sq(self._pos, record.m_pos) < rally_skill_data.range_sq then
					local needs_revive, is_arrested, action_stop = nil

					if not secondary then
						if prime_target.unit:base().is_husk_player then
							is_arrested = prime_target.unit:movement():current_state_name() == "arrested"
							needs_revive = prime_target.unit:interaction():active() and prime_target.unit:movement():need_revive() and not is_arrested
						else
							is_arrested = prime_target.unit:character_damage():arrested()
							needs_revive = prime_target.unit:character_damage():need_revive()
						end

						if needs_revive and managers.player:has_enabled_cooldown_upgrade("cooldown", "long_dis_revive") then
							voice_type = "revive"

							managers.player:disable_cooldown_upgrade("cooldown", "long_dis_revive")
						elseif not is_arrested and not needs_revive and rally_skill_data.morale_boost_delay_t and rally_skill_data.morale_boost_delay_t < managers.player:player_timer():time() then
							voice_type = "boost"
							amount = 1
						end
					end
				end
			end

			if is_human_player then
				prime_target.unit:network():send_to_unit({
					"long_dis_interaction",
					prime_target.unit,
					amount,
					self._unit,
					secondary or false
				})
			end

			voice_type = voice_type or secondary and "ai_stay" or "come"
			plural = false
		else
			local prime_target_key = prime_target.unit:key()

			if prime_target.unit_type == unit_type_enemy then
				plural = false

				if prime_target.unit:anim_data().hands_back then
					voice_type = "cuff_cop"
				elseif prime_target.unit:anim_data().surrender then
					voice_type = "down_cop"
				elseif is_whisper_mode and prime_target.unit:movement():cool() and prime_target.unit:base():char_tweak().silent_priority_shout then
					voice_type = "mark_cop_quiet"
				elseif prime_target.unit:base():char_tweak().priority_shout then
					voice_type = "mark_cop"
				else
					voice_type = "stop_cop"
				end
			elseif prime_target.unit_type == unit_type_camera then
				if not prime_target.unit or not prime_target.unit:base() or not prime_target.unit:base().is_friendly then
					plural = false
					voice_type = "mark_camera"
				end
			elseif prime_target.unit_type == unit_type_turret then
				plural = false
				voice_type = "mark_turret"
			elseif prime_target.unit:base():char_tweak().is_escort then
				plural = false
				local e_guy = prime_target.unit

				if e_guy:anim_data().move then
					voice_type = "escort_keep"
				elseif e_guy:anim_data().panic then
					voice_type = "escort_go"
				else
					voice_type = prime_target.unit:base():char_tweak().speech_escort or "escort"
				end
			else
				if prime_target.unit:movement():stance_name() == "cbt" and prime_target.unit:anim_data().stand then
					voice_type = "come"
				elseif prime_target.unit:anim_data().move then
					voice_type = "stop"
				elseif prime_target.unit:anim_data().drop then
					voice_type = "down_stay"
				else
					voice_type = "down"
				end

				local num_affected = 0

				for _, char in pairs(char_table) do
					if char.unit_type == unit_type_civilian then
						if voice_type == "stop" and char.unit:anim_data().move then
							num_affected = num_affected + 1
						elseif voice_type == "down_stay" and char.unit:anim_data().drop then
							num_affected = num_affected + 1
						elseif voice_type == "down" and not char.unit:anim_data().move and not char.unit:anim_data().drop then
							num_affected = num_affected + 1
						end
					end
				end

				if num_affected > 1 then
					plural = true
				else
					plural = false
				end
			end

			local max_inv_wgt = 0

			for _, char in pairs(char_table) do
				if max_inv_wgt < char.inv_wgt then
					max_inv_wgt = char.inv_wgt
				end
			end

			if max_inv_wgt < 1 then
				max_inv_wgt = 1
			end

			if detect_only then
				voice_type = "come"
			else
				for _, char in pairs(char_table) do
					if char.unit_type ~= unit_type_camera and char.unit_type ~= unit_type_teammate and (not is_whisper_mode or not char.unit:movement():cool()) then
						if char.unit_type == unit_type_civilian then
							amount = (amount or tweak_data.player.long_dis_interaction.intimidate_strength) * managers.player:upgrade_value("player", "civ_intimidation_mul", 1) * managers.player:team_upgrade_value("player", "civ_intimidation_mul", 1)
						end

						if prime_target_key == char.unit:key() then
							voice_type = char.unit:brain():on_intimidated(amount or tweak_data.player.long_dis_interaction.intimidate_strength, self._unit) or voice_type
						elseif not primary_only and char.unit_type ~= unit_type_enemy then
							char.unit:brain():on_intimidated((amount or tweak_data.player.long_dis_interaction.intimidate_strength) * char.inv_wgt / max_inv_wgt, self._unit)
						end
					end
				end
			end
		end
	end

	return voice_type, plural, prime_target
end

function PlayerStandard:_get_unit_intimidation_action(intimidate_enemies, intimidate_civilians, intimidate_teammates, only_special_enemies, intimidate_escorts, intimidation_amount, primary_only, detect_only, secondary)
	local char_table = {}
	local unit_type_enemy = 0
	local unit_type_civilian = 1
	local unit_type_teammate = 2
	local unit_type_camera = 3
	local unit_type_turret = 4
	local cam_fwd = self._ext_camera:forward()
	local my_head_pos = self._ext_movement:m_head_pos()

	if _G.IS_VR then
		local hand_unit = self._unit:hand():hand_unit(self._interact_hand)

		if hand_unit:raycast("ray", hand_unit:position(), my_head_pos, "slot_mask", 1) then
			return
		end

		cam_fwd = hand_unit:rotation():y()
		my_head_pos = hand_unit:position()
	end

	local spotting_mul = managers.player:upgrade_value("player", "marked_distance_mul", 1)
	local range_mul = managers.player:upgrade_value("player", "intimidate_range_mul", 1) * managers.player:upgrade_value("player", "passive_intimidate_range_mul", 1)
	local intimidate_range_civ = tweak_data.player.long_dis_interaction.intimidate_range_civilians * range_mul
	local intimidate_range_ene = tweak_data.player.long_dis_interaction.intimidate_range_enemies * range_mul
	local highlight_range = tweak_data.player.long_dis_interaction.highlight_range * range_mul * spotting_mul
	local intimidate_range_teammates = tweak_data.player.long_dis_interaction.intimidate_range_teammates

	if intimidate_enemies then
		local enemies = managers.enemy:all_enemies()

		for u_key, u_data in pairs(enemies) do
			if self._unit:movement():team().foes[u_data.unit:movement():team().id] and not u_data.unit:anim_data().hands_tied and not u_data.unit:anim_data().long_dis_interact_disabled and (not u_data.unit:character_damage() or not u_data.unit:character_damage():dead()) and (u_data.char_tweak.priority_shout or not only_special_enemies) then
				if managers.groupai:state():whisper_mode() then
					if u_data.char_tweak.silent_priority_shout and u_data.unit:movement():cool() then
						self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, highlight_range, false, false, 0.01, my_head_pos, cam_fwd)
					elseif not u_data.unit:movement():cool() then
						self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, intimidate_range_ene, false, false, 100, my_head_pos, cam_fwd, nil, "ai_vision mover")
					end
				elseif u_data.char_tweak.priority_shout then
					self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, highlight_range, false, false, 0.01, my_head_pos, cam_fwd)
				else
					self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, intimidate_range_ene, false, false, 100, my_head_pos, cam_fwd, nil, "ai_vision mover")
				end
			end
		end
	end

	if intimidate_civilians then
		local civilians = managers.enemy:all_civilians()

		for u_key, u_data in pairs(civilians) do
			if alive(u_data.unit) and u_data.unit:in_slot(21) and not u_data.unit:movement():cool() and not u_data.unit:anim_data().long_dis_interact_disabled then
				local is_escort = u_data.char_tweak.is_escort

				if not is_escort or intimidate_escorts then
					local dist = is_escort and 300 or intimidate_range_civ
					local prio = is_escort and 100000 or 0.001

					self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_civilian, dist, false, false, prio, my_head_pos, cam_fwd)
				end
			end
		end
	end

	if intimidate_teammates and not managers.groupai:state():whisper_mode() then
		local criminals = managers.groupai:state():all_char_criminals()

		for u_key, u_data in pairs(criminals) do
			local added = nil

			if u_key ~= self._unit:key() then
				local rally_skill_data = self._ext_movement:rally_skill_data()

				if rally_skill_data and rally_skill_data.long_dis_revive and mvector3.distance_sq(self._pos, u_data.m_pos) < rally_skill_data.range_sq then
					local needs_revive = nil

					if u_data.unit:base().is_husk_player then
						needs_revive = u_data.unit:interaction():active() and u_data.unit:movement():need_revive() and u_data.unit:movement():current_state_name() ~= "arrested"
					else
						needs_revive = u_data.unit:character_damage():need_revive()
					end

					if needs_revive then
						added = true

						self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_teammate, intimidate_range_teammates, true, true, 5000, my_head_pos, cam_fwd)
					end
				end
			end

			if not added and not u_data.is_deployable and not u_data.unit:movement():downed() and not u_data.unit:base().is_local_player and not u_data.unit:anim_data().long_dis_interact_disabled then
				self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_teammate, intimidate_range_teammates, true, not secondary, 0.01, my_head_pos, cam_fwd)
			end
		end
	end

	if intimidate_enemies and intimidate_teammates then
		local enemies = managers.enemy:all_enemies()

		for u_key, u_data in pairs(enemies) do
			if u_data.unit:movement():team() and u_data.unit:movement():team().id == "criminal1" and not u_data.unit:movement():cool() and not u_data.unit:anim_data().long_dis_interact_disabled then
				local is_escort = u_data.char_tweak.is_escort

				if not is_escort or intimidate_escorts then
					local dist = is_escort and 300 or intimidate_range_civ
					local prio = is_escort and 100000 or 0.001

					self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_civilian, dist, false, false, prio, my_head_pos, cam_fwd)
				end
			end
		end
	end

	if intimidate_enemies then
		if managers.groupai:state():whisper_mode() then
			for _, unit in ipairs(SecurityCamera.cameras) do
				if alive(unit) and unit:enabled() and not unit:base():destroyed() then
					local dist = 2000
					local prio = 0.001

					self:_add_unit_to_char_table(char_table, unit, unit_type_camera, dist, false, false, prio, my_head_pos, cam_fwd, {
						unit
					})
				end
			end
		end

		local turret_units = managers.groupai:state():turrets()

		if turret_units then
			for _, unit in pairs(turret_units) do
				if alive(unit) and unit:movement():team().foes[self._ext_movement:team().id] then
					self:_add_unit_to_char_table(char_table, unit, unit_type_turret, 2000, false, false, 0.01, my_head_pos, cam_fwd, {
						unit
					})
				end
			end
		end
	end

	local prime_target = self:_get_interaction_target(char_table, my_head_pos, cam_fwd)

	return self:_get_intimidation_action(prime_target, char_table, intimidation_amount, primary_only, detect_only, secondary)
end

function PlayerStandard:_start_action_intimidate(t, secondary)
	if not self._intimidate_t or tweak_data.player.movement_state.interaction_delay < t - self._intimidate_t then
		local skip_alert = managers.groupai:state():whisper_mode()
		local voice_type, plural, prime_target = self:_get_unit_intimidation_action(not secondary, not secondary, true, false, true, nil, nil, nil, secondary)

		if prime_target and prime_target.unit and prime_target.unit.base and (prime_target.unit:base().unintimidateable or prime_target.unit:anim_data() and prime_target.unit:anim_data().unintimidateable) then
			return
		end

		local interact_type, sound_name = nil
		local sound_suffix = plural and "plu" or "sin"

		if voice_type == "stop" then
			interact_type = "cmd_stop"
			sound_name = "f02x_" .. sound_suffix
		elseif voice_type == "stop_cop" then
			interact_type = "cmd_stop"
			sound_name = "l01x_" .. sound_suffix
		elseif voice_type == "mark_cop" or voice_type == "mark_cop_quiet" then
			interact_type = "cmd_point"

			if voice_type == "mark_cop_quiet" then
				sound_name = tweak_data.character[prime_target.unit:base()._tweak_table].silent_priority_shout .. "_any"
			else
				sound_name = tweak_data.character[prime_target.unit:base()._tweak_table].priority_shout .. "x_any"
				sound_name = managers.modifiers:modify_value("PlayerStandart:_start_action_intimidate", sound_name, prime_target.unit)
			end

			if managers.player:has_category_upgrade("player", "special_enemy_highlight") then
				prime_target.unit:contour():add(managers.player:get_contour_for_marked_enemy(), true, managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1))
				managers.network:session():send_to_peers_synched("spot_enemy", prime_target.unit)
			end
		elseif voice_type == "down" then
			interact_type = "cmd_down"
			sound_name = "f02x_" .. sound_suffix
			self._shout_down_t = t
		elseif voice_type == "down_cop" then
			interact_type = "cmd_down"
			sound_name = "l02x_" .. sound_suffix
		elseif voice_type == "cuff_cop" then
			interact_type = "cmd_down"
			sound_name = "l03x_" .. sound_suffix
		elseif voice_type == "down_stay" then
			interact_type = "cmd_down"

			if self._shout_down_t and t < self._shout_down_t + 2 then
				sound_name = "f03b_any"
			else
				sound_name = "f03a_" .. sound_suffix
			end
		elseif voice_type == "come" then
			interact_type = "cmd_come"
			local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)

			if static_data then
				local character_code = static_data.ssuffix
				sound_name = "f21" .. character_code .. "_sin"
			else
				sound_name = "f38_any"
			end
		elseif voice_type == "revive" then
			interact_type = "cmd_get_up"
			local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)

			if not static_data then
				return
			end

			local character_code = static_data.ssuffix
			sound_name = "f36x_any"

			if math.random() < self._ext_movement:rally_skill_data().revive_chance then
				prime_target.unit:interaction():interact(self._unit)
			end

			self._ext_movement:rally_skill_data().morale_boost_delay_t = managers.player:player_timer():time() + (self._ext_movement:rally_skill_data().morale_boost_cooldown_t or 3.5)
		elseif voice_type == "boost" then
			interact_type = "cmd_gogo"
			local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)

			if not static_data then
				return
			end

			local character_code = static_data.ssuffix
			sound_name = "g18"
			self._ext_movement:rally_skill_data().morale_boost_delay_t = managers.player:player_timer():time() + (self._ext_movement:rally_skill_data().morale_boost_cooldown_t or 3.5)
		elseif voice_type == "escort" then
			interact_type = "cmd_point"
			sound_name = "f41_" .. sound_suffix
		elseif voice_type == "escort_keep" or voice_type == "escort_go" then
			interact_type = "cmd_point"
			sound_name = "f40_any"
		elseif voice_type == "bridge_codeword" then
			sound_name = "bri_14"
			interact_type = "cmd_point"
		elseif voice_type == "bridge_chair" then
			sound_name = "bri_29"
			interact_type = "cmd_point"
		elseif voice_type == "undercover_interrogate" then
			sound_name = "f46x_any"
			interact_type = "cmd_point"
		elseif voice_type == "undercover_escort" then
			sound_name = "f41_any"
			interact_type = "cmd_point"
		elseif voice_type == "mark_camera" then
			sound_name = "f39_any"
			interact_type = "cmd_point"

			prime_target.unit:contour():add("mark_unit", true, managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1))
		elseif voice_type == "mark_turret" then
			sound_name = "f44x_any"
			interact_type = "cmd_point"
			local type = prime_target.unit:base().get_type and prime_target.unit:base():get_type()

			prime_target.unit:contour():add(managers.player:get_contour_for_marked_enemy(type), true, managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1))
		elseif voice_type == "ai_stay" then
			sound_name = "f48x_any"
			interact_type = "cmd_stop"
		end

		self:_do_action_intimidate(t, interact_type, sound_name, skip_alert)
	end
end

function PlayerStandard:_do_action_intimidate(t, interact_type, sound_name, skip_alert)
	if sound_name then
		self._intimidate_t = t

		self:say_line(sound_name, skip_alert)

		if _G.IS_VR then
			self._unit:hand():intimidate(self._interact_hand)
		end

		if interact_type and not self:_is_using_bipod() then
			self:_play_distance_interact_redirect(t, interact_type)
		end
	end
end

function PlayerStandard:say_line(sound_name, skip_alert)
	self._unit:sound():say(sound_name, true, false)

	skip_alert = skip_alert or managers.groupai:state():whisper_mode()

	if not skip_alert then
		local alert_rad = 500
		local new_alert = {
			"vo_cbt",
			self._unit:movement():m_head_pos(),
			alert_rad,
			self._unit:movement():SO_access(),
			self._unit
		}

		managers.groupai:state():propagate_alert(new_alert)
	end
end

function PlayerStandard:_play_distance_interact_redirect(t, variant)
	managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, variant)

	if self._state_data.in_steelsight then
		return
	end

	if self._shooting or not self._equipped_unit:base():start_shooting_allowed() then
		return
	end

	if self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t then
		return
	end

	if self._running then
		return
	end

	self._state_data.interact_redirect_t = t + 1

	self._ext_camera:play_redirect(Idstring(variant))
end

function PlayerStandard:_break_intimidate_redirect(t)
	if self._shooting then
		return
	end

	if self._state_data.interact_redirect_t and t < self._state_data.interact_redirect_t then
		self._ext_camera:play_redirect(self:get_animation("idle"))
	end
end

function PlayerStandard:_play_interact_redirect(t)
	if self._shooting or not self._equipped_unit:base():start_shooting_allowed() then
		return
	end

	if self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self:in_steelsight() then
		return
	end

	if self._running then
		return
	end

	self._state_data.interact_redirect_t = t + 1

	self._ext_camera:play_redirect(self:get_animation("use"))
end

function PlayerStandard:_break_interact_redirect(t)
	self._ext_camera:play_redirect(self:get_animation("idle"))
end

function PlayerStandard:_check_action_equip(t, input)
	local new_action = nil
	local selection_wanted = input.btn_primary_choice

	if selection_wanted then
		local action_forbidden = self:chk_action_forbidden("equip")
		action_forbidden = action_forbidden or not self._ext_inventory:is_selection_available(selection_wanted) or self:_is_meleeing() or self._use_item_expire_t or self:_changing_weapon() or self:_interacting() or self:_is_throwing_projectile()

		if not action_forbidden then
			local new_action = not self._ext_inventory:is_equipped(selection_wanted)

			if new_action then
				self:_start_action_unequip_weapon(t, {
					selection_wanted = selection_wanted
				})
			end
		end
	end

	return new_action
end

function PlayerStandard:_check_action_jump(t, input)
	local new_action = nil
	local action_wanted = input.btn_jump_press

	if action_wanted then
		local action_forbidden = self._jump_t and t < self._jump_t + 0.55
		action_forbidden = action_forbidden or self._unit:base():stats_screen_visible() or self._state_data.in_air or self:_interacting() or self:_on_zipline() or self:_does_deploying_limit_movement() or self:_is_using_bipod()

		if not action_forbidden then
			if self._state_data.ducking then
				self:_interupt_action_ducking(t)
			else
				if self._state_data.on_ladder then
					self:_interupt_action_ladder(t)
				end

				local action_start_data = {}
				local jump_vel_z = tweak_data.player.movement_state.standard.movement.jump_velocity.z
				action_start_data.jump_vel_z = jump_vel_z

				if self._move_dir then
					local is_running = self._running and self._unit:movement():is_above_stamina_threshold() and t - self._start_running_t > 0.4
					local jump_vel_xy = tweak_data.player.movement_state.standard.movement.jump_velocity.xy[is_running and "run" or "walk"]
					action_start_data.jump_vel_xy = jump_vel_xy

					if is_running then
						self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN)
					end
				end

				new_action = self:_start_action_jump(t, action_start_data)
			end
		end
	end

	return new_action
end

function PlayerStandard:_start_action_jump(t, action_start_data)
	if self._running and not self.RUN_AND_RELOAD and not self._equipped_unit:base():run_and_shoot_allowed() then
		self:_interupt_action_reload(t)
		self._ext_camera:play_redirect(self:get_animation("stop_running"), self._equipped_unit:base():exit_run_speed_multiplier())
	end

	self:_interupt_action_running(t)

	self._jump_t = t
	local jump_vec = action_start_data.jump_vel_z * math.UP

	self._unit:mover():jump()

	if self._move_dir then
		local move_dir_clamp = self._move_dir:normalized() * math.min(1, self._move_dir:length())
		self._last_velocity_xy = move_dir_clamp * action_start_data.jump_vel_xy
		self._jump_vel_xy = mvector3.copy(self._last_velocity_xy)
	else
		self._last_velocity_xy = Vector3()
	end

	self:_perform_jump(jump_vec)
end

function PlayerStandard:_perform_jump(jump_vec)
	self._unit:mover():set_velocity(jump_vec)

	self._send_jump_vec = jump_vec * 0.87
	local t = managers.game_play_central and managers.game_play_central:get_heist_timer() or 0

	if not (managers.achievment:get_info(tweak_data.achievement.jordan_1) or {}).awarded then
		managers.achievment:award(tweak_data.achievement.jordan_1)
	end

	if not (managers.achievment:get_info(tweak_data.achievement.jordan_2.award) or {}).awarded then
		local memory = managers.job:get_memory("jordan_2", true) or {}

		table.insert(memory, t)

		for i = #memory, 1, -1 do
			if tweak_data.achievement.jordan_2.timer <= t - memory[i] then
				table.remove(memory, i)
			end
		end

		if tweak_data.achievement.jordan_2.count <= #memory then
			managers.achievment:award(tweak_data.achievement.jordan_2.award)
		end

		managers.job:set_memory("jordan_2", memory, true)
	end

	if not managers.job:get_memory("jordan_3") then
		managers.job:set_memory("jordan_3", true)
	end

	local jordan_4 = managers.job:get_memory("jordan_4")

	if jordan_4 or jordan_4 == nil then
		local last_jump_t = managers.job:get_memory("last_jump_t", true) or 0

		if last_jump_t and t > last_jump_t + tweak_data.achievement.complete_heist_achievements.jordan_4.jump_timer then
			managers.job:set_memory("jordan_4", false)
		else
			managers.job:set_memory("jordan_4", true)
		end

		managers.job:set_memory("last_jump_t", t, true)
	end

	if self._jump_vel_xy then
		mvec3_set(temp_vec1, self._jump_vel_xy)
		mvec3_set_z(temp_vec1, 0)
		mvec3_add(self._send_jump_vec, temp_vec1)
	end
end

function PlayerStandard:_update_network_jump(pos, is_exit)
	local mover = self._unit:mover()

	if self._is_jumping and (is_exit or not mover or mover:standing() and mover:velocity().z < 0 or mover:gravity().z == 0) then
		if not self._is_jump_middle_passed then
			self._is_jump_middle_passed = true
		end

		self._is_jumping = nil
	elseif self._send_jump_vec and not is_exit then
		if self._is_jumping and type(self._gnd_ray) ~= "boolean" then
			self._ext_network:send("action_walk_nav_point", self._gnd_ray and self._gnd_ray.position)
		end

		self._ext_network:send("action_jump", pos or self._pos, self._send_jump_vec)

		self._send_jump_vec = nil
		self._is_jumping = true
		self._is_jump_middle_passed = nil

		mvector3.set(self._last_sent_pos, pos or self._pos)
	elseif self._is_jumping and not self._is_jump_middle_passed and mover and mover:velocity().z < 0 then
		self._is_jump_middle_passed = true
	end
end

function PlayerStandard:_check_action_zipline(t, input)
	if self._state_data.in_air then
		return
	end

	if not self._state_data.on_zipline then
		local zipline_unit = self._unit:movement():zipline_unit()

		if alive(zipline_unit) then
			self:_start_action_zipline(t, input, zipline_unit)
		end
	end
end

function PlayerStandard:_start_action_zipline(t, input, zipline_unit)
	self:_interupt_action_running(t)
	self:_interupt_action_ducking(t, true)
	self:_interupt_action_steelsight(t)

	self._state_data.on_zipline = true
	self._state_data.zipline_data = {
		zipline_unit = zipline_unit
	}

	self._ext_camera:play_shaker("player_enter_zipline")

	if zipline_unit then
		self._state_data.zipline_data.player_lerp_t = 0
		self._state_data.zipline_data.player_lerp_tot_t = 0.5
		self._state_data.zipline_data.tot_t = zipline_unit:zipline():total_time()
	else
		self._state_data.zipline_data.start_pos = self._unit:position()
		self._state_data.zipline_data.end_pos = self._fwd_ray.position
		self._state_data.zipline_data.slack = math.max(0, math.abs(self._state_data.zipline_data.start_pos.z - self._state_data.zipline_data.end_pos.z) / 3)
		self._state_data.zipline_data.tot_t = (self._state_data.zipline_data.end_pos - self._state_data.zipline_data.start_pos):length() / 1000
	end

	self._state_data.zipline_data.t = 0
	self._state_data.zipline_data.camera_shake = self._ext_camera:play_shaker("player_on_zipline", 0)

	self._unit:kill_mover()
end

function PlayerStandard:_update_zipline_timers(t, dt)
	if not self._state_data.on_zipline then
		return
	end

	self._state_data.zipline_data.t = math.min(self._state_data.zipline_data.t + dt / self._state_data.zipline_data.tot_t, 1)

	if alive(self._state_data.zipline_data.zipline_unit) then
		self._state_data.zipline_data.position = self._state_data.zipline_data.zipline_unit:zipline():update_and_get_pos_at_time(self._state_data.zipline_data.t)

		if self._state_data.zipline_data.player_lerp_t then
			self._state_data.zipline_data.player_lerp_t = math.min(self._state_data.zipline_data.player_lerp_t + dt / self._state_data.zipline_data.player_lerp_tot_t, 1)
			self._state_data.zipline_data.position = math.lerp(self._unit:position(), self._state_data.zipline_data.position, self._state_data.zipline_data.player_lerp_t)

			if self._state_data.zipline_data.player_lerp_t == 1 then
				self._state_data.zipline_data.player_lerp_t = nil
			end
		end
	else
		self._state_data.on_zipline_move = math.bezier({
			0,
			0,
			1,
			1
		}, self._state_data.zipline_data.t)
		self._state_data.zipline_data.position = math.lerp(self._state_data.zipline_data.start_pos, self._state_data.zipline_data.end_pos, self._state_data.on_zipline_move)
		local bez = math.bezier({
			0,
			1,
			0.5,
			0
		}, self._state_data.on_zipline_move)
		local slack = math.lerp(0, self._state_data.zipline_data.slack, bez)

		mvector3.set_z(self._state_data.zipline_data.position, mvector3.z(self._state_data.zipline_data.position) - slack)
	end

	if self._state_data.zipline_data.t == 1 then
		self:_end_action_zipline(t)
	end
end

function PlayerStandard:_end_action_zipline(t)
	self._ext_camera:play_shaker("player_exit_zipline", 1)

	local tilt = managers.player:is_carrying() and PlayerCarry.target_tilt or 0

	self._ext_camera:camera_unit():base():set_target_tilt(tilt)

	self._state_data.on_zipline = nil

	self._unit:movement():on_exit_zipline()

	if self._state_data.zipline_data.camera_shake then
		self._ext_camera:shaker():stop(self._state_data.zipline_data.camera_shake)

		self._state_data.zipline_data.camera_shake = nil
	end

	self._state_data.zipline_data = nil

	self:_activate_mover(PlayerStandard.MOVER_STAND)
end

function PlayerStandard:_on_zipline()
	return self._state_data.on_zipline
end

function PlayerStandard:_check_action_deploy_bipod(t, input)
	local new_action = nil
	local action_forbidden = false

	if not input.btn_deploy_bipod then
		return
	end

	action_forbidden = self:in_steelsight() or self:_on_zipline() or self:_is_throwing_projectile() or self:_is_meleeing() or self:is_equipping() or self:_changing_weapon()

	if not action_forbidden then
		local weapon = self._equipped_unit:base()
		local bipod_part = managers.weapon_factory:get_parts_from_weapon_by_perk("bipod", weapon._parts)

		if bipod_part and bipod_part[1] then
			local bipod_unit = bipod_part[1].unit:base()

			bipod_unit:check_state()

			new_action = true
		end
	end

	return new_action
end

function PlayerStandard:_upd_stance_switch_delay(t, dt)
	if self._stance_switch_delay ~= nil then
		self._stance_switch_delay = self._stance_switch_delay - dt

		if self._stance_switch_delay <= 0 then
			self._stance_switch_delay = nil
		end
	end
end

function PlayerStandard:is_switching_stances()
	return self._stance_switch_delay ~= nil
end

function PlayerStandard:set_stance_switch_delay(delay)
	self._stance_switch_delay = delay
end

function PlayerStandard:_is_underbarrel_attachment_active(weapon_unit)
	local weapon = (weapon_unit or self._equipped_unit):base()
	local underbarrel_names = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("underbarrel", weapon._factory_id, weapon._blueprint)

	if underbarrel_names and underbarrel_names[1] then
		local underbarrel = weapon._parts[underbarrel_names[1]]

		if underbarrel then
			local underbarrel_base = underbarrel.unit:base()

			return underbarrel_base:is_on()
		end
	end

	return false
end

function PlayerStandard:_check_action_deploy_underbarrel(t, input)
	local new_action = nil
	local action_forbidden = false

	if not input.btn_deploy_bipod and not self._toggle_underbarrel_wanted then
		return new_action
	end

	action_forbidden = self:in_steelsight() or self:_is_throwing_projectile() or self:_is_meleeing() or self:is_equipping() or self:_changing_weapon() or self:shooting() or self:_is_reloading() or self:is_switching_stances() or self:_interacting() or self:running() and not self._equipped_unit:base():run_and_shoot_allowed()

	if self._running and not self._equipped_unit:base():run_and_shoot_allowed() and not self._end_running_expire_t then
		self:_interupt_action_running(t)

		self._toggle_underbarrel_wanted = true

		return
	end

	if not action_forbidden then
		self._toggle_underbarrel_wanted = false
		local weapon = self._equipped_unit:base()
		local underbarrel_names = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("underbarrel", weapon._factory_id, weapon._blueprint)

		if underbarrel_names and underbarrel_names[1] then
			local underbarrel = weapon._parts[underbarrel_names[1]]

			if underbarrel then
				local underbarrel_base = underbarrel.unit:base()
				local underbarrel_tweak = tweak_data.weapon[underbarrel_base.name_id]

				if weapon.record_fire_mode then
					weapon:record_fire_mode()
				end

				underbarrel_base:toggle()

				new_action = true

				if weapon.reset_cached_gadget then
					weapon:reset_cached_gadget()
				end

				if weapon._update_stats_values then
					weapon:_update_stats_values(true)
				end

				local anim_ids = nil
				local switch_delay = 1

				if underbarrel_base:is_on() then
					anim_ids = Idstring("underbarrel_enter_" .. weapon.name_id)
					switch_delay = underbarrel_tweak.timers.equip_underbarrel

					self:set_animation_state("underbarrel")
				else
					anim_ids = Idstring("underbarrel_exit_" .. weapon.name_id)
					switch_delay = underbarrel_tweak.timers.unequip_underbarrel

					self:set_animation_state("standard")
				end

				if anim_ids then
					self._ext_camera:play_redirect(anim_ids, 1)
				end

				self:set_animation_weapon_hold(nil)
				self:set_stance_switch_delay(switch_delay)

				if alive(self._equipped_unit) then
					managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())
					managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, self._unit:inventory():equipped_selection(), self._equipped_unit:base():fire_mode())
				end

				managers.network:session():send_to_peers_synched("sync_underbarrel_switch", self._equipped_unit:base():selection_index(), underbarrel_base.name_id, underbarrel_base:is_on())
			end
		end
	end

	return new_action
end

function PlayerStandard:_check_action_cash_inspect(t, input)
	if not input.btn_cash_inspect_press then
		return
	end

	local action_forbidden = self:_interacting() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline() or self:running() or self:_is_reloading() or self:in_steelsight() or self:is_equipping() or self:shooting() or self:_is_cash_inspecting(t)

	if action_forbidden then
		return
	end

	self._ext_camera:play_redirect(self:get_animation("cash_inspect"))
	managers.player:send_message(Message.OnCashInspectWeapon)
end

function PlayerStandard:_is_cash_inspecting(t)
	return self._camera_unit_anim_data.cash_inspecting
end

function PlayerStandard:_interupt_action_cash_inspect(t)
	if self:_is_cash_inspecting() then
		self._ext_camera:play_redirect(Idstring("idle"))
	end
end

function PlayerStandard:_update_omniscience(t, dt)
	local action_forbidden = not managers.player:has_category_upgrade("player", "standstill_omniscience") or managers.player:current_state() == "civilian" or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline() or self._moving or self:running() or self:_is_reloading() or self:in_air() or self:in_steelsight() or self:is_equipping() or self:shooting() or not managers.groupai:state():whisper_mode() or not tweak_data.player.omniscience

	if action_forbidden then
		if self._state_data.omniscience_t then
			self._state_data.omniscience_t = nil
		end

		return
	end

	self._state_data.omniscience_t = self._state_data.omniscience_t or t + tweak_data.player.omniscience.start_t

	if self._state_data.omniscience_t <= t then
		local sensed_targets = World:find_units_quick("sphere", self._unit:movement():m_pos(), tweak_data.player.omniscience.sense_radius, managers.slot:get_mask("trip_mine_targets"))

		for _, unit in ipairs(sensed_targets) do
			if alive(unit) and not unit:base():char_tweak().is_escort then
				self._state_data.omniscience_units_detected = self._state_data.omniscience_units_detected or {}

				if not self._state_data.omniscience_units_detected[unit:key()] or self._state_data.omniscience_units_detected[unit:key()] <= t then
					self._state_data.omniscience_units_detected[unit:key()] = t + tweak_data.player.omniscience.target_resense_t

					managers.game_play_central:auto_highlight_enemy(unit, true)

					break
				end
			end
		end

		self._state_data.omniscience_t = t + tweak_data.player.omniscience.interval_t
	end
end

function PlayerStandard:_check_action_run(t, input)
	if self._setting_hold_to_run and input.btn_run_release or self._running and not self._move_dir then
		self._running_wanted = false

		if self._running then
			self:_end_action_running(t)

			if input.btn_steelsight_state and not self._state_data.in_steelsight then
				self._steelsight_wanted = true
			end
		end
	elseif not self._setting_hold_to_run and input.btn_run_release and not self._move_dir then
		self._running_wanted = false
	elseif input.btn_run_press or self._running_wanted then
		if not self._running or self._end_running_expire_t then
			self:_start_action_running(t)
		elseif self._running and not self._setting_hold_to_run then
			self:_end_action_running(t)

			if input.btn_steelsight_state and not self._state_data.in_steelsight then
				self._steelsight_wanted = true
			end
		end
	end
end

function PlayerStandard:_update_running_timers(t)
	if self._end_running_expire_t then
		if self._end_running_expire_t <= t then
			self._end_running_expire_t = nil

			self:set_running(false)
		end
	elseif self._running and (self._unit:movement():is_stamina_drained() or not self:_can_run_directional()) then
		self:_interupt_action_running(t)
	end
end

function PlayerStandard:set_running(running)
	self._running = running

	self._unit:movement():set_running(self._running)
	self._ext_network:send("action_change_run", running)

	local stance_code = self._running and 2 or 3

	if self._running and self._equipped_unit:base():run_and_shoot_allowed() then
		stance_code = 3
	end

	self._ext_network:send("set_stance", stance_code, false, false)
end

function PlayerStandard:_check_action_ladder(t, input)
	if self._state_data.on_ladder then
		local ladder_unit = self._unit:movement():ladder_unit()

		if ladder_unit:ladder():check_end_climbing(self._unit:movement():m_pos(), self._normal_move_dir, self._gnd_ray) then
			self:_end_action_ladder()
		end

		return
	end

	if not self._move_dir then
		return
	end

	local u_pos = self._unit:movement():m_pos()

	for i = 1, math.min(Ladder.LADDERS_PER_FRAME, #Ladder.active_ladders) do
		local ladder_unit = Ladder.next_ladder()

		if alive(ladder_unit) then
			local can_access = ladder_unit:ladder():can_access(u_pos, self._move_dir)

			if can_access then
				self:_start_action_ladder(t, ladder_unit)

				break
			end
		end
	end
end

function PlayerStandard:_start_action_ladder(t, ladder_unit)
	self._state_data.on_ladder = true

	self:_interupt_action_running(t)
	self._unit:mover():set_velocity(Vector3())
	self._unit:mover():set_gravity(Vector3(0, 0, 0))
	self._unit:mover():jump()
	self._unit:movement():on_enter_ladder(ladder_unit)
end

function PlayerStandard:_end_action_ladder(t, input)
	if not self._state_data.on_ladder then
		return
	end

	self._state_data.on_ladder = false

	if self._unit:mover() then
		self._unit:mover():set_gravity(Vector3(0, 0, -982))
	end

	self._unit:movement():on_exit_ladder()
end

function PlayerStandard:_interupt_action_ladder(t, input)
	self:_end_action_ladder()
end

function PlayerStandard:on_ladder()
	return self._state_data.on_ladder
end

function PlayerStandard:_check_action_duck(t, input)
	if self:_is_using_bipod() then
		return
	end

	if self._setting_hold_to_duck and input.btn_duck_release then
		if self._state_data.ducking then
			self:_end_action_ducking(t)
		end
	elseif input.btn_duck_press and not self._unit:base():stats_screen_visible() then
		if not self._state_data.ducking then
			self:_start_action_ducking(t)
		elseif self._state_data.ducking then
			self:_end_action_ducking(t)
		end
	end
end

function PlayerStandard:_check_action_steelsight(t, input)
	local new_action = nil

	if alive(self._equipped_unit) then
		local result = nil
		local weap_base = self._equipped_unit:base()

		if weap_base.manages_steelsight and weap_base:manages_steelsight() then
			if input.btn_steelsight_press and weap_base.steelsight_pressed then
				result = weap_base:steelsight_pressed()
			elseif input.btn_steelsight_release and weap_base.steelsight_released then
				result = weap_base:steelsight_released()
			end

			if result then
				if result.enter_steelsight and not self._state_data.in_steelsight then
					self:_start_action_steelsight(t)

					new_action = true
				elseif result.exit_steelsight and self._state_data.in_steelsight then
					self:_end_action_steelsight(t)

					new_action = true
				end
			end

			return new_action
		end
	end

	if managers.user:get_setting("hold_to_steelsight") and input.btn_steelsight_release then
		self._steelsight_wanted = false

		if self._state_data.in_steelsight then
			self:_end_action_steelsight(t)

			new_action = true
		end
	elseif input.btn_steelsight_press or self._steelsight_wanted then
		if self._state_data.in_steelsight then
			self:_end_action_steelsight(t)

			new_action = true
		elseif not self._state_data.in_steelsight then
			self:_start_action_steelsight(t)

			new_action = true
		end
	end

	return new_action
end

function PlayerStandard:shooting()
	return self._shooting
end

function PlayerStandard:running()
	return self._running
end

function PlayerStandard:ducking()
	return self._state_data and self._state_data.ducking
end

function PlayerStandard:get_zoom_fov(stance_data)
	local fov = stance_data and stance_data.FOV or 75
	local fov_multiplier = managers.user:get_setting("fov_multiplier")

	if self._state_data.in_steelsight then
		fov = self._equipped_unit:base():zoom()
		fov_multiplier = 1 + (fov_multiplier - 1) / 2
	end

	return fov * fov_multiplier
end

function PlayerStandard:_check_action_primary_attack(t, input)
	local new_action = nil
	local action_wanted = input.btn_primary_attack_state or input.btn_primary_attack_release

	if action_wanted then
		local action_forbidden = self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t or self:_interacting() or self:_is_throwing_projectile() or self:_is_deploying_bipod() or self._menu_closed_fire_cooldown > 0 or self:is_switching_stances()

		if not action_forbidden then
			self._queue_reload_interupt = nil
			local start_shooting = false

			self._ext_inventory:equip_selected_primary(false)

			if self._equipped_unit then
				local weap_base = self._equipped_unit:base()
				local fire_mode = weap_base:fire_mode()
				local fire_on_release = weap_base:fire_on_release()

				if weap_base:out_of_ammo() then
					if input.btn_primary_attack_press then
						weap_base:dryfire()
					end
				elseif weap_base.clip_empty and weap_base:clip_empty() then
					if self:_is_using_bipod() then
						if input.btn_primary_attack_press then
							weap_base:dryfire()
						end

						self._equipped_unit:base():tweak_data_anim_stop("fire")
					elseif fire_mode == "single" then
						if input.btn_primary_attack_press or self._equipped_unit:base().should_reload_immediately and self._equipped_unit:base():should_reload_immediately() then
							self:_start_action_reload_enter(t)
						end
					else
						new_action = true

						self:_start_action_reload_enter(t)
					end
				elseif self._running and not self._equipped_unit:base():run_and_shoot_allowed() then
					self:_interupt_action_running(t)
				else
					if not self._shooting then
						if weap_base:start_shooting_allowed() then
							local start = fire_mode == "single" and input.btn_primary_attack_press
							start = start or fire_mode ~= "single" and input.btn_primary_attack_state
							start = start and not fire_on_release
							start = start or fire_on_release and input.btn_primary_attack_release

							if start then
								weap_base:start_shooting()
								self._camera_unit:base():start_shooting()

								self._shooting = true
								self._shooting_t = t
								start_shooting = true

								if fire_mode == "auto" then
									self._unit:camera():play_redirect(self:get_animation("recoil_enter"))

									if (not weap_base.akimbo or weap_base:weapon_tweak_data().allow_akimbo_autofire) and (not weap_base.third_person_important or weap_base.third_person_important and not weap_base:third_person_important()) then
										self._ext_network:send("sync_start_auto_fire_sound", 0)
									end
								end
							end
						else
							self:_check_stop_shooting()

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
						if input.btn_primary_attack_press and start_shooting then
							fired = weap_base:trigger_pressed(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
						elseif fire_on_release then
							if input.btn_primary_attack_release then
								fired = weap_base:trigger_released(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
							elseif input.btn_primary_attack_state then
								weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
							end
						end
					elseif input.btn_primary_attack_state then
						fired = weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
					end

					if weap_base.manages_steelsight and weap_base:manages_steelsight() then
						if weap_base:wants_steelsight() and not self._state_data.in_steelsight then
							self:_start_action_steelsight(t)
						elseif not weap_base:wants_steelsight() and self._state_data.in_steelsight then
							self:_end_action_steelsight(t)
						end
					end

					local charging_weapon = fire_on_release and weap_base:charging()

					if not self._state_data.charging_weapon and charging_weapon then
						self:_start_action_charging_weapon(t)
					elseif self._state_data.charging_weapon and not charging_weapon then
						self:_end_action_charging_weapon(t)
					end

					new_action = true

					if fired then
						managers.rumble:play("weapon_fire")

						local weap_tweak_data = tweak_data.weapon[weap_base:get_name_id()]
						local shake_multiplier = weap_tweak_data.shake[self._state_data.in_steelsight and "fire_steelsight_multiplier" or "fire_multiplier"]

						self._ext_camera:play_shaker("fire_weapon_rot", 1 * shake_multiplier)
						self._ext_camera:play_shaker("fire_weapon_kick", 1 * shake_multiplier, 1, 0.15)
						self._equipped_unit:base():tweak_data_anim_stop("unequip")
						self._equipped_unit:base():tweak_data_anim_stop("equip")

						if not self._state_data.in_steelsight or not weap_base:tweak_data_anim_play("fire_steelsight", weap_base:fire_rate_multiplier()) then
							weap_base:tweak_data_anim_play("fire", weap_base:fire_rate_multiplier())
						end

						if fire_mode == "single" and weap_base:get_name_id() ~= "saw" then
							if not self._state_data.in_steelsight then
								self._ext_camera:play_redirect(self:get_animation("recoil"), weap_base:fire_rate_multiplier())
							elseif weap_tweak_data.animations.recoil_steelsight then
								self._ext_camera:play_redirect(weap_base:is_second_sight_on() and self:get_animation("recoil") or self:get_animation("recoil_steelsight"), 1)
							end
						end

						local recoil_multiplier = (weap_base:recoil() + weap_base:recoil_addend()) * weap_base:recoil_multiplier()

						cat_print("jansve", "[PlayerStandard] Weapon Recoil Multiplier: " .. tostring(recoil_multiplier))

						local up, down, left, right = unpack(weap_tweak_data.kick[self._state_data.in_steelsight and "steelsight" or self._state_data.ducking and "crouching" or "standing"])

						self._camera_unit:base():recoil_kick(up * recoil_multiplier, down * recoil_multiplier, left * recoil_multiplier, right * recoil_multiplier)

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
							self._ext_network:send("shot_blank_reliable", impact, 0)
						elseif weap_base.akimbo and not weap_base:weapon_tweak_data().allow_akimbo_autofire or fire_mode == "single" then
							self._ext_network:send("shot_blank", impact, 0)
						end
					elseif fire_mode == "single" then
						new_action = false
					end
				end
			end
		elseif self:_is_reloading() and self._equipped_unit:base():reload_interuptable() and input.btn_primary_attack_press then
			self._queue_reload_interupt = true
		end
	end

	if not new_action then
		self:_check_stop_shooting()
	end

	return new_action
end

function PlayerStandard:_check_stop_shooting()
	if self._shooting then
		self._equipped_unit:base():stop_shooting()
		self._camera_unit:base():stop_shooting(self._equipped_unit:base():recoil_wait())

		local weap_base = self._equipped_unit:base()
		local fire_mode = weap_base:fire_mode()

		if fire_mode == "auto" and (not weap_base.akimbo or weap_base:weapon_tweak_data().allow_akimbo_autofire) then
			self._ext_network:send("sync_stop_auto_fire_sound", 0)
		end

		if fire_mode == "auto" and not self:_is_reloading() and not self:_is_meleeing() then
			self._unit:camera():play_redirect(self:get_animation("recoil_exit"))
		end

		self._shooting = false
		self._shooting_t = nil
	end
end

function PlayerStandard:_start_action_charging_weapon(t)
	self._state_data.charging_weapon = true
	self._state_data.charging_weapon_data = {
		t = t,
		max_t = 2.5
	}
	local ANIM_LENGTH = 1.5
	local max = self._equipped_unit:base():charge_max_t()
	local speed_multiplier = ANIM_LENGTH / max

	self._equipped_unit:base():tweak_data_anim_play("charge", speed_multiplier)
	self._ext_camera:play_redirect(self:get_animation("charge"), speed_multiplier)
end

function PlayerStandard:_interupt_action_charging_weapon(t)
	if not self._state_data.charging_weapon then
		return
	end

	self._equipped_unit:base():interupt_charging()
	self:_end_action_charging_weapon(t)
end

function PlayerStandard:_end_action_charging_weapon(t)
	self._state_data.charging_weapon = nil

	self._equipped_unit:base():tweak_data_anim_stop("charge")
	self._ext_camera:play_redirect(self:get_animation("idle"))
end

function PlayerStandard:_is_charging_weapon()
	return self._state_data.charging_weapon
end

function PlayerStandard:_update_charging_weapon_timers(t, dt)
	if not self._state_data.charging_weapon then
		return
	end
end

function PlayerStandard:_start_action_reload_enter(t)
	if self._equipped_unit:base():can_reload() then
		managers.player:send_message_now(Message.OnPlayerReload, nil, self._equipped_unit)
		self:_interupt_action_steelsight(t)

		if not self.RUN_AND_RELOAD then
			self:_interupt_action_running(t)
		end

		if self._equipped_unit:base():reload_enter_expire_t() then
			local speed_multiplier = self._equipped_unit:base():reload_speed_multiplier()

			self._ext_camera:play_redirect(Idstring("reload_enter_" .. self._equipped_unit:base().name_id), speed_multiplier)

			self._state_data.reload_enter_expire_t = t + self._equipped_unit:base():reload_enter_expire_t() / speed_multiplier

			self._equipped_unit:base():tweak_data_anim_play("reload_enter", speed_multiplier)

			return
		end

		self:_start_action_reload(t)
	end
end

function PlayerStandard:_start_action_reload(t)
	local weapon = self._equipped_unit:base()

	if weapon and weapon:can_reload() then
		weapon:tweak_data_anim_stop("fire")

		local speed_multiplier = weapon:reload_speed_multiplier()
		local empty_reload = weapon:clip_empty() and 1 or 0

		if weapon._use_shotgun_reload then
			empty_reload = weapon:get_ammo_max_per_clip() - weapon:get_ammo_remaining_in_clip()
		end

		local tweak_data = weapon:weapon_tweak_data()
		local reload_anim = "reload"
		local reload_prefix = weapon:reload_prefix() or ""
		local reload_name_id = tweak_data.animations.reload_name_id or weapon.name_id

		if weapon:clip_empty() then
			local reload_ids = Idstring(reload_prefix .. "reload_" .. reload_name_id)
			local result = self._ext_camera:play_redirect(reload_ids, speed_multiplier)

			Application:trace("PlayerStandard:_start_action_reload( t ): ", reload_ids)

			self._state_data.reload_expire_t = t + (tweak_data.timers.reload_empty or weapon:reload_expire_t() or 2.6) / speed_multiplier
		else
			reload_anim = "reload_not_empty"
			local reload_ids = Idstring(reload_prefix .. "reload_not_empty_" .. reload_name_id)
			local result = self._ext_camera:play_redirect(reload_ids, speed_multiplier)

			Application:trace("PlayerStandard:_start_action_reload( t ): ", reload_ids)

			self._state_data.reload_expire_t = t + (tweak_data.timers.reload_not_empty or weapon:reload_expire_t() or 2.2) / speed_multiplier
		end

		weapon:start_reload()

		if not weapon:tweak_data_anim_play(reload_anim, speed_multiplier) then
			weapon:tweak_data_anim_play("reload", speed_multiplier)
			Application:trace("PlayerStandard:_start_action_reload( t ): ", reload_anim)
		end

		self._ext_network:send("reload_weapon", empty_reload, speed_multiplier)
	end
end

function PlayerStandard:_interupt_action_reload(t)
	if alive(self._equipped_unit) then
		self._equipped_unit:base():check_bullet_objects()
	end

	if self:_is_reloading() then
		self._equipped_unit:base():tweak_data_anim_stop("reload_enter")
		self._equipped_unit:base():tweak_data_anim_stop("reload")
		self._equipped_unit:base():tweak_data_anim_stop("reload_not_empty")
		self._equipped_unit:base():tweak_data_anim_stop("reload_exit")
	end

	self._state_data.reload_enter_expire_t = nil
	self._state_data.reload_expire_t = nil
	self._state_data.reload_exit_expire_t = nil

	managers.player:remove_property("shock_and_awe_reload_multiplier")
	self:send_reload_interupt()
end

function PlayerStandard:send_reload_interupt()
	self._ext_network:send("reload_weapon_interupt")
end

function PlayerStandard:_is_reloading()
	return self._state_data.reload_expire_t or self._state_data.reload_enter_expire_t or self._state_data.reload_exit_expire_t
end

function PlayerStandard:start_deploying_bipod(bipod_deploy_duration)
	self._deploy_bipod_expire_t = managers.player:player_timer():time() + bipod_deploy_duration
end

function PlayerStandard:_is_deploying_bipod()
	local deploying = false

	if self._deploy_bipod_expire_t and managers.player:player_timer():time() < self._deploy_bipod_expire_t then
		deploying = true
	end

	return deploying
end

function PlayerStandard:_is_using_bipod()
	return self._state_data.using_bipod
end

function PlayerStandard:_get_swap_speed_multiplier()
	local multiplier = 1
	local weapon_tweak_data = self._equipped_unit:base():weapon_tweak_data()
	multiplier = multiplier * managers.player:upgrade_value("weapon", "swap_speed_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value("weapon", "passive_swap_speed_multiplier", 1)

	for _, category in ipairs(weapon_tweak_data.categories) do
		multiplier = multiplier * managers.player:upgrade_value(category, "swap_speed_multiplier", 1)
	end

	multiplier = multiplier * managers.player:upgrade_value("team", "crew_faster_swap", 1)

	if managers.player:has_activate_temporary_upgrade("temporary", "swap_weapon_faster") then
		multiplier = multiplier * managers.player:temporary_upgrade_value("temporary", "swap_weapon_faster", 1)
	end

	multiplier = managers.modifiers:modify_value("PlayerStandard:GetSwapSpeedMultiplier", multiplier)

	return multiplier
end

function PlayerStandard:_start_action_unequip_weapon(t, data)
	local speed_multiplier = self:_get_swap_speed_multiplier()

	self._equipped_unit:base():tweak_data_anim_stop("equip")
	self._equipped_unit:base():tweak_data_anim_play("unequip", speed_multiplier)

	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	self._change_weapon_data = data
	self._unequip_weapon_expire_t = t + (tweak_data.timers.unequip or 0.5) / speed_multiplier

	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	local result = self._ext_camera:play_redirect(self:get_animation("unequip"), speed_multiplier)

	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self._ext_network:send("switch_weapon", speed_multiplier, 1)
end

function PlayerStandard:_start_action_equip_weapon(t)
	if self._change_weapon_data.next then
		local next_equip = self._ext_inventory:get_next_selection()
		next_equip = next_equip and next_equip.unit

		if next_equip then
			local state = self:_is_underbarrel_attachment_active(next_equip) and "underbarrel" or "standard"

			self:set_animation_state(state)
		end

		self._ext_inventory:equip_next(false)
	elseif self._change_weapon_data.previous then
		local prev_equip = self._ext_inventory:get_previous_selection()
		prev_equip = prev_equip and next_equip.unit

		if prev_equip then
			local state = self:_is_underbarrel_attachment_active(prev_equip) and "underbarrel" or "standard"

			self:set_animation_state(state)
		end

		self._ext_inventory:equip_previous(false)
	elseif self._change_weapon_data.selection_wanted then
		local select_equip = self._ext_inventory:get_selected(self._change_weapon_data.selection_wanted)
		select_equip = select_equip and select_equip.unit

		if select_equip then
			local state = self:_is_underbarrel_attachment_active(select_equip) and "underbarrel" or "standard"

			self:set_animation_state(state)
		end

		self._ext_inventory:equip_selection(self._change_weapon_data.selection_wanted, false)
	end

	self:set_animation_weapon_hold(nil)

	local speed_multiplier = self:_get_swap_speed_multiplier()

	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)

	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	self._equip_weapon_expire_t = t + (tweak_data.timers.equip or 0.7) / speed_multiplier

	self._ext_camera:play_redirect(self:get_animation("equip"), speed_multiplier)
	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)
	managers.upgrades:setup_current_weapon()
end

function PlayerStandard:_changing_weapon()
	return self._unequip_weapon_expire_t or self._equip_weapon_expire_t
end

function PlayerStandard:_find_pickups(t)
	local pickups = World:find_units_quick("sphere", self._unit:movement():m_pos(), self._pickup_area, self._slotmask_pickups)
	local grenade_tweak = tweak_data.blackmarket.projectiles[managers.blackmarket:equipped_grenade()]
	local may_find_grenade = not grenade_tweak.base_cooldown and managers.player:has_category_upgrade("player", "regain_throwable_from_ammo")

	for _, pickup in ipairs(pickups) do
		if pickup:pickup() and pickup:pickup():pickup(self._unit) then
			if may_find_grenade then
				local data = managers.player:upgrade_value("player", "regain_throwable_from_ammo", nil)

				if data then
					managers.player:add_coroutine("regain_throwable_from_ammo", PlayerAction.FullyLoaded, managers.player, data.chance, data.chance_inc)
				end
			end

			for id, weapon in pairs(self._unit:inventory():available_selections()) do
				managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
			end
		end
	end
end

function PlayerStandard:_upd_attention()
	local preset = nil

	if false and self._seat and self._seat.driving then
		-- Nothing
	elseif managers.groupai:state():whisper_mode() then
		if self._state_data.ducking then
			preset = {
				"pl_mask_on_friend_combatant_whisper_mode",
				"pl_mask_on_friend_non_combatant_whisper_mode",
				"pl_mask_on_foe_combatant_whisper_mode_crouch",
				"pl_mask_on_foe_non_combatant_whisper_mode_crouch"
			}
		else
			preset = {
				"pl_mask_on_friend_combatant_whisper_mode",
				"pl_mask_on_friend_non_combatant_whisper_mode",
				"pl_mask_on_foe_combatant_whisper_mode_stand",
				"pl_mask_on_foe_non_combatant_whisper_mode_stand"
			}
		end
	elseif self._state_data.ducking then
		preset = {
			"pl_friend_combatant_cbt",
			"pl_friend_non_combatant_cbt",
			"pl_foe_combatant_cbt_crouch",
			"pl_foe_non_combatant_cbt_crouch"
		}
	else
		preset = {
			"pl_friend_combatant_cbt",
			"pl_friend_non_combatant_cbt",
			"pl_foe_combatant_cbt_stand",
			"pl_foe_non_combatant_cbt_stand"
		}
	end

	self._ext_movement:set_attention_settings(preset)
end

function PlayerStandard:get_melee_damage_result(attack_data)
end

function PlayerStandard:get_bullet_damage_result(attack_data)
end

function PlayerStandard:push(vel)
	if self._unit:mover() then
		self._last_velocity_xy = self._last_velocity_xy + vel

		self._unit:mover():set_velocity(self._last_velocity_xy)
	end

	self:_interupt_action_running(managers.player:player_timer():time())
end

function PlayerStandard:_get_dir_str_from_vec(fwd, dir_vec)
	local att_dir_spin = dir_vec:to_polar_with_reference(fwd, math.UP).spin
	local abs_spin = math.abs(att_dir_spin)

	if abs_spin < 45 then
		return "fwd"
	elseif abs_spin > 135 then
		return "bwd"
	elseif att_dir_spin < 0 then
		return "right"
	else
		return "left"
	end

	managers.network:session():send_to_peers_synched("sync_underbarrel_switch", self._equipped_unit:base():selection_index(), underbarrel_base.name_id, underbarrel_base:is_on())
end

function PlayerStandard:get_movement_state()
	if self._state_data.ducking then
		return self._moving and "moving_crouching" or "crouching"
	else
		return self._moving and "moving_standing" or "standing"
	end
end

function PlayerStandard:set_animation_weapon_hold(name_override)
	if self._weapon_hold then
		self._camera_unit:anim_state_machine():set_global(self._weapon_hold, 0)
	end

	if not name_override then
		local weapon = self._ext_inventory:equipped_unit()

		if weapon then
			self._weapon_hold = weapon:base().weapon_hold and weapon:base():weapon_hold() or weapon:base():get_name_id()

			if self:current_anim_state_name() ~= "standard" then
				self._weapon_hold = self._weapon_hold .. "_" .. self:current_anim_state_name()
			end
		end
	else
		self._weapon_hold = name_override
	end

	if self._weapon_hold then
		self._camera_unit:anim_state_machine():set_global(self._weapon_hold, 1)
	end
end

function PlayerStandard:inventory_clbk_listener(unit, event)
	if event == "equip" then
		local weapon = self._ext_inventory:equipped_unit()

		self:set_animation_weapon_hold(nil)

		if self._equipped_unit ~= weapon then
			self._equipped_unit = weapon

			weapon:base():on_equip(unit)
			managers.hud:set_weapon_selected_by_inventory_index(self._ext_inventory:equipped_selection())

			for id, weapon in pairs(self._ext_inventory:available_selections()) do
				managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
			end
		end

		self:_update_crosshair_offset()
		self:_stance_entered()
	elseif event == "unequip" then
		local weapon = self._ext_inventory:equipped_unit()

		if weapon then
			weapon:base():on_unequip(unit)
		end
	end
end

function PlayerStandard:_check_action_night_vision(t, input)
	if not input.btn_night_vision_press then
		return
	end

	local action_forbidden = self:_is_throwing_projectile() or self:_is_meleeing() or self:is_equipping() or self:_changing_weapon() or self:shooting() or self:_is_reloading() or self:is_switching_stances() or self:_interacting()

	if action_forbidden then
		return
	end

	self:set_night_vision_state(not self._state_data.night_vision_active)
end

function PlayerStandard:set_night_vision_state(state)
	local mask_id = managers.blackmarket:equipped_mask().mask_id
	local mask_tweak = tweak_data.blackmarket.masks[mask_id]
	local night_vision = mask_tweak.night_vision

	if not night_vision or not not self._state_data.night_vision_active == state then
		return
	end

	local ambient_color_key = CoreEnvironmentFeeder.PostAmbientColorFeeder.DATA_PATH_KEY
	local effect = nil

	if state then
		local function light_modifier(handler, feeder)
			local base_light = feeder._target and mvector3.copy(feeder._target) or Vector3()
			local light = night_vision.light

			return base_light + Vector3(light, light, light)
		end

		managers.viewport:create_global_environment_modifier(ambient_color_key, true, light_modifier)

		self._state_data.night_vision_saved_default_color_grading = managers.environment_controller:default_color_grading()
		effect = night_vision.effect
	else
		managers.viewport:destroy_global_environment_modifier(ambient_color_key)

		effect = self._state_data.night_vision_saved_default_color_grading
		self._state_data.night_vision_saved_default_color_grading = nil
	end

	self._unit:sound():play(state and "night_vision_on" or "night_vision_off", nil, false)

	if effect then
		managers.environment_controller:set_default_color_grading(effect, state)
		managers.environment_controller:refresh_render_settings()
	end

	self._state_data.night_vision_active = state
end

function PlayerStandard:weapon_recharge_clbk_listener()
	for id, weapon in pairs(self._ext_inventory:available_selections()) do
		managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
	end
end

function PlayerStandard:get_equipped_weapon()
	if self._equipped_unit then
		return self._equipped_unit:base()
	end

	return nil
end

function PlayerStandard:save(data)
	if self._state_data.ducking then
		data.pose = 2
	else
		data.pose = 1
	end
end

function PlayerStandard:pre_destroy()
	if self._pos_reservation then
		managers.navigation:unreserve_pos(self._pos_reservation)

		self._pos_reservation = nil

		managers.navigation:unreserve_pos(self._pos_reservation_slow)

		self._pos_reservation_slow = nil
	end

	self:set_night_vision_state(false)
end

function PlayerStandard:tweak_data_clbk_reload()
	local state_name = self._ext_movement:current_state_name()

	if state_name == "jerry1" then
		self._tweak_data = tweak_data.player.freefall
	elseif state_name == "jerry2" then
		self._tweak_data = tweak_data.player.parachute
	else
		self._tweak_data = tweak_data.player.movement_state.standard
	end
end
