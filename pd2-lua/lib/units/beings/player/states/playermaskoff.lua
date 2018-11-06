PlayerMaskOff = PlayerMaskOff or class(PlayerStandard)

function PlayerMaskOff:init(unit)
	PlayerMaskOff.super.init(self, unit)

	self._mask_off_attention_settings = {
		"pl_mask_off_friend_combatant",
		"pl_mask_off_friend_non_combatant",
		"pl_mask_off_foe_combatant",
		"pl_mask_off_foe_non_combatant"
	}
end

function PlayerMaskOff:enter(state_data, enter_data)
	if managers.groupai:state():enemy_weapons_hot() then
		managers.player:set_player_state("standard")
	else
		PlayerMaskOff.super.enter(self, state_data, enter_data)
	end
end

function PlayerMaskOff:_enter(enter_data)
	local equipped_weapon = self._unit:inventory():equipped_unit()

	if equipped_weapon then
		equipped_weapon:base():set_gadget_on(0, false)
		self._unit:network():send("set_weapon_gadget_state", 0)
	end

	local equipped_selection = self._unit:inventory():equipped_selection()

	if equipped_selection ~= 1 then
		self._previous_equipped_selection = equipped_selection

		self._ext_inventory:equip_selection(1, false)
		managers.upgrades:setup_current_weapon()
	end

	if self._unit:camera():anim_data().equipped then
		self._unit:camera():play_redirect(self:get_animation("unequip"))
	end

	self._unit:base():set_slot(self._unit, 4)
	self._ext_movement:set_attention_settings(self._mask_off_attention_settings)

	if not managers.groupai:state():enemy_weapons_hot() then
		self._enemy_weapons_hot_listen_id = "PlayerMaskOff" .. tostring(self._unit:key())

		managers.groupai:state():add_listener(self._enemy_weapons_hot_listen_id, {
			"enemy_weapons_hot"
		}, callback(self, self, "clbk_enemy_weapons_hot"))
	end

	MenuCallbackHandler:_update_outfit_information()
	self._ext_network:send("set_stance", 1, false, false)

	self._show_casing_t = Application:time() + 4
end

function PlayerMaskOff:exit(state_data, new_state_name)
	PlayerMaskOff.super.exit(self, state_data)
	managers.hud:hide_casing()

	if self._previous_equipped_selection then
		self._unit:inventory():equip_selection(self._previous_equipped_selection, false)

		self._previous_equipped_selection = nil
	end

	self._unit:base():set_slot(self._unit, 2)
	self._ext_movement:chk_play_mask_on_slow_mo(state_data)

	if self._enemy_weapons_hot_listen_id then
		managers.groupai:state():remove_listener(self._enemy_weapons_hot_listen_id)

		self._enemy_weapons_hot_listen_id = nil
	end

	self:_interupt_action_start_standard()

	return {
		was_unarmed = true
	}
end

function PlayerMaskOff:update(t, dt)
	PlayerMaskOff.super.update(self, t, dt)

	if self._show_casing_t and self._show_casing_t < t then
		self._show_casing_t = nil

		managers.hud:show_casing()
	end
end

function PlayerMaskOff:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)
	self._stick_move = self._controller:get_input_axis("move")

	if mvector3.length(self._stick_move) < 0.1 or self:_interacting() then
		self._move_dir = nil
	else
		self._move_dir = mvector3.copy(self._stick_move)
		local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

		mvector3.rotate_with(self._move_dir, cam_flat_rot)
	end

	self:_update_interaction_timers(t)
	self:_update_start_standard_timers(t)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil
	new_action = new_action or self:_check_use_item(t, input)
	new_action = new_action or self:_check_action_interact(t, input)

	if not new_action and self._state_data.ducking then
		self:_end_action_ducking(t)
	end

	self:_check_action_jump(t, input)
	self:_check_action_duck(t, input)
	self:_check_action_run(t, input)
	self:_check_action_change_equipment(t, input)
end

function PlayerMaskOff:_check_action_interact(t, input)
	local new_action, timer, interact_object = nil

	if input.btn_interact_press then
		if _G.IS_VR then
			self._interact_hand = input.btn_interact_left_press and PlayerHand.LEFT or PlayerHand.RIGHT
		end

		local action_forbidden = self:chk_action_forbidden("interact") or self._unit:base():stats_screen_visible() or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_on_zipline()

		if not action_forbidden then
			new_action, timer, interact_object = managers.interaction:interact(self._unit, input.data, self._interact_hand)

			if timer then
				new_action = true

				self._ext_camera:camera_unit():base():set_limits(80, 50)
				self:_start_action_interact(t, input, timer, interact_object)
			end

			if not new_action and (not self._intimidate_t or tweak_data.player.movement_state.interaction_delay < t - self._intimidate_t) then
				self._intimidate_t = t
				new_action = self:mark_units("f11", t, true)
			end
		end

		if not new_action then
			managers.hint:show_hint("mask_off_block_interact")
		end
	end

	if input.btn_interact_release then
		self:_interupt_action_interact()
	end

	return new_action
end

function PlayerMaskOff:_start_action_interact(t, input, timer, interact_object)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)

	self._interact_expire_t = timer
	self._interact_params = {
		object = interact_object,
		timer = timer,
		tweak_data = interact_object:interaction().tweak_data
	}

	managers.hud:show_interaction_bar(0, timer)
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, true, self._interact_params.tweak_data, timer, false)
end

function PlayerMaskOff:_interupt_action_interact(t, input, complete)
	if self._interact_expire_t then
		self._interact_expire_t = nil

		if alive(self._interact_params.object) then
			self._interact_params.object:interaction():interact_interupt(self._unit, complete)
		end

		self._ext_camera:camera_unit():base():remove_limits()
		managers.interaction:interupt_action_interact(self._unit)
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, false, self._interact_params.tweak_data, 0, complete and true or false)

		self._interact_params = nil

		managers.hud:hide_interaction_bar(complete)
	end
end

function PlayerMaskOff:_end_action_interact()
	self:_interupt_action_interact(nil, nil, true)
	managers.interaction:end_action_interact(self._unit)
end

function PlayerMaskOff:_upd_attention()
	self._ext_movement:set_attention_settings(self._mask_off_attention_settings)
end

function PlayerMaskOff:_check_use_item(t, input)
	local new_action = nil
	local action_wanted = input.btn_use_item_press

	if action_wanted then
		local action_forbidden = self._use_item_expire_t or self:_changing_weapon() or self:_interacting()

		if not action_forbidden then
			self:_start_action_state_standard(t)
		end
	end

	if input.btn_use_item_release then
		self:_interupt_action_start_standard()
	end
end

function PlayerMaskOff:_start_action_use_item(t)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)

	local deploy_timer = managers.player:selected_equipment_deploy_timer()
	self._use_item_expire_t = t + deploy_timer

	managers.hud:show_progress_timer_bar(0, deploy_timer)

	local text = managers.player:selected_equipment_deploying_text() or managers.localization:text("hud_deploying_equipment", {
		EQUIPMENT = managers.player:selected_equipment_name()
	})

	managers.hud:show_progress_timer({
		text = text
	})

	local equipment_id = managers.player:selected_equipment_id()

	managers.network:session():send_to_peers_synched("sync_teammate_progress", 2, true, equipment_id, deploy_timer, false)
end

function PlayerMaskOff:_end_action_use_item(valid)
	local result = managers.player:use_selected_equipment(self._unit)

	self:_interupt_action_use_item(nil, nil, valid)
end

function PlayerMaskOff:_interupt_action_use_item(t, input, complete)
	if self._use_item_expire_t then
		self._use_item_expire_t = nil

		managers.hud:hide_progress_timer_bar(complete)
		managers.hud:remove_progress_timer()
		self._unit:equipment():on_deploy_interupted()
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 2, false, "", 0, complete and true or false)
	end
end

function PlayerMaskOff:_update_start_standard_timers(t)
	if self._start_standard_expire_t then
		managers.hud:set_progress_timer_bar_width(tweak_data.player.put_on_mask_time - (self._start_standard_expire_t - t), tweak_data.player.put_on_mask_time)

		if self._start_standard_expire_t <= t then
			self:_end_action_start_standard(t)

			self._start_standard_expire_t = nil
		end
	end
end

function PlayerMaskOff:_start_action_state_standard(t)
	self._start_standard_expire_t = t + tweak_data.player.put_on_mask_time

	managers.hud:show_progress_timer_bar(0, tweak_data.player.put_on_mask_time)
	managers.hud:show_progress_timer({
		text = managers.localization:text("hud_starting_heist")
	})
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 3, true, "mask_on_action", tweak_data.player.put_on_mask_time, false)
end

function PlayerMaskOff:_interupt_action_start_standard(t, input, complete)
	if self._start_standard_expire_t then
		self._start_standard_expire_t = nil

		managers.hud:hide_progress_timer_bar(complete)
		managers.hud:remove_progress_timer()
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 3, false, "mask_on_action", 0, complete and true or false)
	end
end

function PlayerMaskOff:_end_action_start_standard()
	self:_interupt_action_start_standard(nil, nil, true)
	PlayerStandard.say_line(self, "a01x_any", true)
	managers.player:set_player_state("standard")
	managers.achievment:award("no_one_cared_who_i_was")
end

function PlayerMaskOff:mark_units(line, t, no_gesture, skip_alert)
	local mark_sec_camera = managers.player:has_category_upgrade("player", "sec_camera_highlight_mask_off")
	local mark_special_enemies = managers.player:has_category_upgrade("player", "special_enemy_highlight_mask_off")
	local voice_type, plural, prime_target = self:_get_unit_intimidation_action(mark_special_enemies, false, false, false, false)
	local interact_type, sound_name = nil

	if voice_type == "mark_cop" or voice_type == "mark_cop_quiet" then
		interact_type = "cmd_point"

		if voice_type == "mark_cop_quiet" then
			sound_name = tweak_data.character[prime_target.unit:base()._tweak_table].silent_priority_shout .. "_any"
		else
			sound_name = tweak_data.character[prime_target.unit:base()._tweak_table].priority_shout .. "x_any"
		end

		if managers.player:has_category_upgrade("player", "special_enemy_highlight") then
			prime_target.unit:contour():add(managers.player:get_contour_for_marked_enemy(), true, managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1))
		end
	elseif voice_type == "mark_camera" and mark_sec_camera then
		sound_name = "f39_any"
		interact_type = "cmd_point"

		prime_target.unit:contour():add("mark_unit", true)
	end

	if interact_type then
		self:_do_action_intimidate(t, not no_gesture and interact_type or nil, sound_name, skip_alert)

		return true
	end

	return mark_sec_camera or mark_special_enemies
end

function PlayerMaskOff:_check_action_jump(t, input)
	if input.btn_duck_press then
		managers.hint:show_hint("mask_off_block_interact")
	end
end

function PlayerMaskOff:_check_action_duck(t, input)
	if input.btn_jump_press then
		managers.hint:show_hint("mask_off_block_interact")
	end
end

function PlayerMaskOff:_check_action_run(t, input)
	if input.btn_run_press then
		managers.hint:show_hint("mask_off_block_interact")
	end
end

function PlayerMaskOff:clbk_enemy_weapons_hot()
	if self._enemy_weapons_hot_listen_id then
		managers.groupai:state():remove_listener(self._enemy_weapons_hot_listen_id)

		self._enemy_weapons_hot_listen_id = nil

		managers.player:set_player_state("standard")
	end
end

function PlayerMaskOff:interaction_blocked()
	return false
end

function PlayerMaskOff:_get_walk_headbob()
	return 0.0125
end
