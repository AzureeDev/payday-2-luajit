PlayerTased = PlayerTased or class(PlayerStandard)
PlayerTased._update_movement = PlayerBleedOut._update_movement

function PlayerTased:init(unit)
	PlayerTased.super.init(self, unit)
end

function PlayerTased:enter(state_data, enter_data)
	PlayerTased.super.enter(self, state_data, enter_data)
	self:_start_action_tased(managers.player:player_timer():time(), state_data.non_lethal_electrocution)

	if state_data.non_lethal_electrocution then
		state_data.non_lethal_electrocution = nil
		local recover_time = Application:time() + tweak_data.player.damage.TASED_TIME * managers.player:upgrade_value("player", "electrocution_resistance_multiplier", 1)
		self._recover_delayed_clbk = "PlayerTased_recover_delayed_clbk"

		managers.enemy:add_delayed_clbk(self._recover_delayed_clbk, callback(self, self, "clbk_exit_to_std"), recover_time)
	else
		self._fatal_delayed_clbk = "PlayerTased_fatal_delayed_clbk"
		local tased_time = tweak_data.player.damage.TASED_TIME
		tased_time = managers.modifiers:modify_value("PlayerTased:TasedTime", tased_time)

		managers.enemy:add_delayed_clbk(self._fatal_delayed_clbk, callback(self, self, "clbk_exit_to_fatal"), TimerManager:game():time() + tased_time)
	end

	self._next_shock = 0.5
	self._taser_value = 1
	self._num_shocks = 0

	managers.groupai:state():on_criminal_disabled(self._unit, "electrified")

	if Network:is_server() then
		self:_register_revive_SO()
	end

	self._equipped_unit:base():on_reload()

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		self:_interupt_action_throw_grenade()
	else
		self:_interupt_action_throw_projectile()
	end

	self:_interupt_action_reload()
	self:_interupt_action_steelsight()
	self:_interupt_action_melee(managers.player:player_timer():time())
	self:_interupt_action_ladder(managers.player:player_timer():time())
	self:_interupt_action_charging_weapon(managers.player:player_timer():time())

	self._rumble_electrified = managers.rumble:play("electrified")
	self.tased = true
	self._state_data = state_data

	if managers.player:has_category_upgrade("player", "taser_malfunction") then
		local data = managers.player:upgrade_value("player", "taser_malfunction")

		if data then
			managers.player:register_message(Message.SendTaserMalfunction, "taser_malfunction", function ()
				self:_on_malfunction_to_taser_event()
			end)
			managers.player:add_coroutine("taser_malfunction", PlayerAction.TaserMalfunction, managers.player, data.interval, data.chance_to_trigger)
		end
	end

	if managers.player:has_category_upgrade("player", "escape_taser") then
		local target_time = managers.player:upgrade_value("player", "escape_taser", 2)

		managers.player:add_coroutine("escape_tase", PlayerAction.EscapeTase, managers.player, Application:time() + target_time)

		local function clbk()
			self:give_shock_to_taser_no_damage()
		end

		managers.player:register_message(Message.EscapeTase, "escape_tase", clbk)
	end

	CopDamage.register_listener("on_criminal_tased", {
		"on_criminal_tased"
	}, callback(self, self, "_on_tased_event"))
end

function PlayerTased:_enter(enter_data)
	self._unit:base():set_slot(self._unit, 2)
	self._unit:camera():camera_unit():base():set_target_tilt(0)
	self._ext_movement:set_attention_settings({
		"pl_friend_combatant_cbt",
		"pl_friend_non_combatant_cbt",
		"pl_foe_combatant_cbt_stand",
		"pl_foe_non_combatant_cbt_stand"
	})

	if Network:is_server() and self._ext_movement:nav_tracker() then
		managers.groupai:state():on_player_weapons_hot()
	end
end

function PlayerTased:exit(state_data, enter_data)
	PlayerTased.super.exit(self, state_data, enter_data)

	if self._fatal_delayed_clbk then
		managers.enemy:remove_delayed_clbk(self._fatal_delayed_clbk)

		self._fatal_delayed_clbk = nil
	end

	if self._recover_delayed_clbk then
		managers.enemy:remove_delayed_clbk(self._recover_delayed_clbk)

		self._recover_delayed_clbk = nil
	end

	if Network:is_server() and self._SO_id then
		managers.groupai:state():remove_special_objective(self._SO_id)
	end

	managers.environment_controller:set_taser_value(1)
	self._camera_unit:base():break_recoil()
	self._unit:sound():play("tasered_stop")
	managers.rumble:stop(self._rumble_electrified)
	self._unit:camera():play_redirect(Idstring("idle"))

	self._tase_ended = nil
	self._counter_taser_unit = nil
	self._num_shocks = nil
	self.tased = false
	self._state_data.non_lethal_electrocution = nil

	managers.player:unregister_message(Message.SendTaserMalfunction, "taser_malfunction")
	managers.player:unregister_message(Message.EscapeTase, "escape_tase")
	CopDamage.unregister_listener("on_criminal_tased")
end

function PlayerTased:interaction_blocked()
	return true
end

function PlayerTased:update(t, dt)
	PlayerTased.super.update(self, t, dt)
end

function PlayerTased:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_check_action_shock(t, input)

	self._taser_value = math.step(self._taser_value, 0.8, dt / 4)

	managers.environment_controller:set_taser_value(self._taser_value)

	local shooting = self:_check_action_primary_attack(t, input)

	if shooting then
		self._camera_unit:base():recoil_kick(-5, 5, -5, 5)
	end

	if self._unequip_weapon_expire_t and self._unequip_weapon_expire_t <= t then
		self._unequip_weapon_expire_t = nil

		self:_start_action_equip_weapon(t)
	end

	if self._equip_weapon_expire_t and self._equip_weapon_expire_t <= t then
		self._equip_weapon_expire_t = nil
	end

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil

	self:_check_action_interact(t, input)

	local new_action = nil
end

function PlayerTased:_check_action_shock(t, input)
	if self._next_shock < t then
		self._num_shocks = self._num_shocks + 1
		self._next_shock = t + 0.25 + math.rand(1)

		self._unit:camera():play_shaker("player_taser_shock", 1, 10)
		self._unit:camera():camera_unit():base():set_target_tilt((math.random(2) == 1 and -1 or 1) * math.random(10))

		self._taser_value = math.max(self._taser_value - 0.25, 0)

		self._unit:sound():play("tasered_shock")
		managers.rumble:play("electric_shock")

		if not alive(self._counter_taser_unit) then
			self._camera_unit:base():start_shooting()

			self._recoil_t = t + 0.5

			if not managers.player:has_category_upgrade("player", "resist_firing_tased") then
				input.btn_primary_attack_state = true
				input.btn_primary_attack_press = true
			end

			self._camera_unit:base():recoil_kick(-5, 5, -5, 5)
			self._unit:camera():play_redirect(self:get_animation("tased_boost"))
		end
	elseif self._recoil_t then
		if not managers.player:has_category_upgrade("player", "resist_firing_tased") then
			input.btn_primary_attack_state = true
		end

		if self._recoil_t < t then
			self._recoil_t = nil

			self._camera_unit:base():stop_shooting()
		end
	end
end

function PlayerTased:_check_action_primary_attack(t, input)
	local new_action = nil
	local action_forbidden = self:chk_action_forbidden("primary_attack")
	action_forbidden = action_forbidden or self:_is_reloading() or self:_changing_weapon() or self._melee_expire_t or self._use_item_expire_t or self:_interacting() or alive(self._counter_taser_unit)
	local action_wanted = input.btn_primary_attack_state

	if action_wanted then
		if not action_forbidden then
			self._queue_reload_interupt = nil

			self._ext_inventory:equip_selected_primary(false)

			if self._equipped_unit then
				local weap_base = self._equipped_unit:base()
				local fire_mode = weap_base:fire_mode()

				if weap_base:out_of_ammo() then
					if input.btn_primary_attack_press then
						weap_base:dryfire()
					end
				elseif weap_base.clip_empty and weap_base:clip_empty() then
					if fire_mode == "single" and input.btn_primary_attack_press then
						weap_base:dryfire()
					end
				elseif self._num_shocks > 1 and weap_base.can_refire_while_tased and not weap_base:can_refire_while_tased() then
					-- Nothing
				elseif self._running then
					self:_interupt_action_running(t)
				else
					if not self._shooting and weap_base:start_shooting_allowed() then
						local start = fire_mode == "single" and input.btn_primary_attack_press
						start = start or fire_mode ~= "single" and input.btn_primary_attack_state

						if start then
							weap_base:start_shooting()
							self._camera_unit:base():start_shooting()

							if not self._state_data.in_steelsight or not weap_base:tweak_data_anim_play("fire_steelsight", weap_base:fire_rate_multiplier()) then
								weap_base:tweak_data_anim_play("fire", weap_base:fire_rate_multiplier())
							end
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
						local upgrade_name = primary_category == "saw" and "melee_damage_health_ratio_multiplier" or "damage_health_ratio_multiplier"
						local damage_ratio = damage_health_ratio
						dmg_mul = dmg_mul * (1 + managers.player:upgrade_value("player", upgrade_name, 0) * damage_ratio)
					end

					dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "berserker_damage_multiplier", 1)
					dmg_mul = dmg_mul * managers.player:get_property("trigger_happy", 1)
					local fired = nil

					if fire_mode == "single" then
						if input.btn_primary_attack_press then
							fired = weap_base:trigger_pressed(self._ext_camera:position(), self._ext_camera:forward(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)

							if weap_base:fire_on_release() then
								if weap_base.set_tased_shot then
									weap_base:set_tased_shot(true)
								end

								fired = weap_base:trigger_released(self._ext_camera:position(), self._ext_camera:forward(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)

								if weap_base.set_tased_shot then
									weap_base:set_tased_shot(false)
								end
							end
						end
					elseif input.btn_primary_attack_state then
						fired = weap_base:trigger_held(self._ext_camera:position(), self._ext_camera:forward(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
					end

					new_action = true

					if fired then
						local weap_tweak_data = tweak_data.weapon[weap_base:get_name_id()]
						local recoil_multiplier = weap_base:recoil() * weap_base:recoil_multiplier() + weap_base:recoil_addend()
						local up, down, left, right = unpack(weap_tweak_data.kick[self._state_data.in_steelsight and "steelsight" or self._state_data.ducking and "crouching" or "standing"])

						self._camera_unit:base():recoil_kick(up * recoil_multiplier, down * recoil_multiplier, left * recoil_multiplier, right * recoil_multiplier)

						local spread_multiplier = weap_base:spread_multiplier()

						self._equipped_unit:base():tweak_data_anim_stop("unequip")
						self._equipped_unit:base():tweak_data_anim_stop("equip")

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

						managers.hud:set_ammo_amount(weap_base:selection_index(), weap_base:ammo_info())

						if self._ext_network then
							local impact = not fired.hit_enemy

							self._ext_network:send("shot_blank", impact)
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

	if not new_action and self._shooting then
		self._equipped_unit:base():stop_shooting()
		self._camera_unit:base():stop_shooting()
	end

	self._shooting = new_action

	return new_action
end

function PlayerTased:_check_action_interact(t, input)
	if input.btn_interact_press and (not self._intimidate_t or tweak_data.player.movement_state.interaction_delay < t - self._intimidate_t) and not alive(self._counter_taser_unit) then
		if _G.IS_VR then
			self._interact_hand = input.btn_interact_left_press and PlayerHand.LEFT or PlayerHand.RIGHT
		end

		self._intimidate_t = t

		self:call_teammate(nil, t, true, true)
	end
end

function PlayerTased:call_teammate(line, t, no_gesture, skip_alert)
	local voice_type, plural, prime_target = self:_get_unit_intimidation_action(true, false, false, true, false)
	local interact_type, queue_name = nil

	if voice_type == "stop_cop" or voice_type == "mark_cop" then
		local prime_target_tweak = tweak_data.character[prime_target.unit:base()._tweak_table]
		local shout_sound = prime_target_tweak.priority_shout

		if managers.groupai:state():whisper_mode() then
			shout_sound = prime_target_tweak.silent_priority_shout or shout_sound
		end

		if shout_sound then
			interact_type = "cmd_point"
			queue_name = "s07x_sin"

			if managers.player:has_category_upgrade("player", "special_enemy_highlight") then
				prime_target.unit:contour():add(managers.player:get_contour_for_marked_enemy(), true, managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1))
			end
		end
	end

	if interact_type then
		self:_do_action_intimidate(t, not no_gesture and interact_type or nil, queue_name, skip_alert)
	end
end

function PlayerTased:_start_action_tased(t, non_lethal)
	self:_interupt_action_running(t)
	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:camera():play_redirect(self:get_animation("tased"))
	self._unit:sound():play("tasered_loop")
	managers.hint:show_hint(non_lethal and "hint_been_electrocuted" or "hint_been_tasered")
end

function PlayerTased:_start_action_counter_tase(t, prime_target)
	self._counter_taser_unit = prime_target.unit

	self._unit:camera():play_redirect(self:get_animation("tased_counter"))
end

function PlayerTased:_register_revive_SO()
	if self._SO_id or not managers.navigation:is_data_ready() then
		return
	end

	local objective = {
		scan = true,
		destroy_clbk_key = false,
		type = "follow",
		called = true,
		follow_unit = self._unit,
		nav_seg = self._unit:movement():nav_tracker():nav_segment()
	}
	local so_descriptor = {
		interval = 6,
		chance_inc = 0,
		search_dis_sq = 25000000,
		base_chance = 1,
		usage_amount = 1,
		AI_group = "friendlies",
		objective = objective,
		search_pos = self._unit:position()
	}
	local so_id = "PlayerTased_assistance"
	self._SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)
end

function PlayerTased:clbk_exit_to_fatal()
	self._fatal_delayed_clbk = nil

	managers.player:set_player_state("incapacitated")
end

function PlayerTased:clbk_exit_to_std()
	self._recover_delayed_clbk = nil

	Application:debug("PlayerTased:clbk_exit_to_std(), game_state_machine:last_queued_state_name()", game_state_machine:last_queued_state_name())

	local current_state_name = managers.player:current_state()

	if current_state_name == "tased" and managers.network:session() then
		managers.player:set_player_state("standard")
	end
end

function PlayerTased:on_tase_ended()
	self._tase_ended = true

	if self._fatal_delayed_clbk then
		managers.enemy:remove_delayed_clbk(self._fatal_delayed_clbk)

		self._fatal_delayed_clbk = nil
	end

	local current_state_name = managers.player:current_state()

	if not self._recover_delayed_clbk and current_state_name == "tased" and managers.network:session() then
		self._recover_delayed_clbk = "PlayerTased_recover_delayed_clbk"

		managers.enemy:add_delayed_clbk(self._recover_delayed_clbk, callback(self, self, "clbk_exit_to_std"), TimerManager:game():time() + tweak_data.player.damage.TASED_RECOVER_TIME)
	end

	self._taser_unit = nil
end

function PlayerTased:_on_tased_event(taser_unit, tased_unit)
	if self._unit == tased_unit then
		self._taser_unit = taser_unit
	end
end

function PlayerTased:give_shock_to_taser()
	if not alive(self._counter_taser_unit) then
		return
	end

	return

	self:_give_shock_to_taser(self._counter_taser_unit)
end

function PlayerTased:_give_shock_to_taser(taser_unit)
	return

	local action_data = {
		variant = "counter_tased",
		damage = taser_unit:character_damage()._HEALTH_INIT * (tweak_data.upgrades.counter_taser_damage or 0.2),
		damage_effect = taser_unit:character_damage()._HEALTH_INIT * 2,
		attacker_unit = self._unit,
		attack_dir = -taser_unit:movement()._action_common_data.fwd,
		col_ray = {
			position = mvector3.copy(taser_unit:movement():m_head_pos()),
			body = taser_unit:body("body")
		}
	}

	taser_unit:character_damage():damage_melee(action_data)
end

function PlayerTased:give_shock_to_taser_no_damage()
	if not alive(self._taser_unit) then
		return
	end

	local action_data = {
		damage = 0,
		variant = "counter_tased",
		damage_effect = self._taser_unit:character_damage()._HEALTH_INIT * 2,
		attacker_unit = self._unit,
		attack_dir = -self._taser_unit:movement()._action_common_data.fwd,
		col_ray = {
			position = mvector3.copy(self._taser_unit:movement():m_head_pos()),
			body = self._taser_unit:body("body")
		}
	}

	self._taser_unit:character_damage():damage_melee(action_data)
	self._unit:sound():play("tase_counter_attack")
end

function PlayerTased:_on_malfunction_to_taser_event()
	if not alive(self._taser_unit) then
		return
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/payday2/particles/character/taser_stop"),
		position = self._taser_unit:movement():m_head_pos(),
		normal = math.UP
	})

	local action_data = {
		damage = 0,
		variant = "melee",
		damage_effect = self._taser_unit:character_damage()._HEALTH_INIT * 10,
		attacker_unit = self._unit,
		attack_dir = -self._taser_unit:movement()._action_common_data.fwd,
		col_ray = {
			position = mvector3.copy(self._taser_unit:movement():m_head_pos()),
			body = self._taser_unit:body("body")
		}
	}

	self._taser_unit:character_damage():damage_melee(action_data)
end
