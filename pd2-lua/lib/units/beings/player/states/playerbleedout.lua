PlayerBleedOut = PlayerBleedOut or class(PlayerStandard)

function PlayerBleedOut:init(unit)
	PlayerBleedOut.super.init(self, unit)
end

function PlayerBleedOut:enter(state_data, enter_data)
	PlayerBleedOut.super.enter(self, state_data, enter_data)

	self._revive_SO_data = {unit = self._unit}

	self:_start_action_bleedout(managers.player:player_timer():time())

	self._tilt_wait_t = managers.player:player_timer():time() + 1
	self._old_selection = nil

	if (not managers.player:has_category_upgrade("player", "primary_weapon_when_downed") or self._unit:inventory():equipped_unit():base():weapon_tweak_data().not_allowed_in_bleedout) and self._unit:inventory():equipped_selection() ~= 1 then
		local projectile_entry = managers.blackmarket:equipped_projectile()

		if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
			self:_interupt_action_throw_grenade(managers.player:player_timer():time())
		else
			self:_interupt_action_throw_projectile(managers.player:player_timer():time())
		end

		self._old_selection = self._unit:inventory():equipped_selection()

		self:_start_action_unequip_weapon(managers.player:player_timer():time(), {selection_wanted = 1})
		self._unit:inventory():unit_by_selection(1):base():on_reload()
	end

	self._unit:camera():play_shaker("player_bleedout_land")

	local effect_id_world = "world_downed_Peer" .. tostring(managers.network:session():local_peer():id())

	managers.time_speed:play_effect(effect_id_world, tweak_data.timespeed.downed)

	local effect_id_player = "player_downed_Peer" .. tostring(managers.network:session():local_peer():id())

	managers.time_speed:play_effect(effect_id_player, tweak_data.timespeed.downed_player)
	managers.groupai:state():on_criminal_disabled(self._unit)

	if Network:is_server() and self._ext_movement:nav_tracker() then
		self._register_revive_SO(self._revive_SO_data, "revive")
	end

	if self._state_data.in_steelsight then
		self:_interupt_action_steelsight(managers.player:player_timer():time())
	end

	self:_interupt_action_melee(managers.player:player_timer():time())
	self:_interupt_action_ladder(managers.player:player_timer():time())
	managers.groupai:state():report_criminal_downed(self._unit)
	managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, -1, table.index_of(ContourExt.indexed_types, "teammate_downed"), true, 1)
end

function PlayerBleedOut:_enter(enter_data)
	self._unit:base():set_slot(self._unit, 2)

	if Network:is_server() and self._ext_movement:nav_tracker() then
		managers.groupai:state():on_player_weapons_hot()
	end

	local preset = nil
	preset = managers.groupai:state():whisper_mode() and {
		"pl_mask_on_friend_combatant_whisper_mode",
		"pl_mask_on_friend_non_combatant_whisper_mode",
		"pl_mask_on_foe_combatant_whisper_mode_crouch",
		"pl_mask_on_foe_non_combatant_whisper_mode_crouch"
	} or {
		"pl_friend_combatant_cbt",
		"pl_friend_non_combatant_cbt",
		"pl_foe_combatant_cbt_crouch",
		"pl_foe_non_combatant_cbt_crouch"
	}

	self._ext_movement:set_attention_settings(preset)
end

function PlayerBleedOut:exit(state_data, new_state_name)
	PlayerBleedOut.super.exit(self, state_data, new_state_name)
	self:_end_action_bleedout(managers.player:player_timer():time())
	self._unit:camera():camera_unit():base():set_target_tilt(0)

	self._tilt_wait_t = nil
	local exit_data = {equip_weapon = self._old_selection}

	if Network:is_server() then
		if new_state_name == "fatal" then
			exit_data.revive_SO_data = self._revive_SO_data
			self._revive_SO_data = nil
		else
			self:_unregister_revive_SO()
		end
	end

	exit_data.skip_equip = true

	if new_state_name == "standard" then
		exit_data.wants_crouch = true
	end

	managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, -1, table.index_of(ContourExt.indexed_types, "teammate_downed"), false, 1)

	return exit_data
end

function PlayerBleedOut:interaction_blocked()
	return true
end

function PlayerBleedOut:_check_use_item()
	return false
end

function PlayerBleedOut:update(t, dt)
	PlayerBleedOut.super.update(self, t, dt)

	if self._tilt_wait_t then
		local tilt = math.lerp(35, 0, self._tilt_wait_t - t)

		self._unit:camera():camera_unit():base():set_target_tilt(tilt)

		if self._tilt_wait_t < t then
			self._tilt_wait_t = nil

			self._unit:camera():camera_unit():base():set_target_tilt(35)
		end
	end
end

function PlayerBleedOut:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self._unit:camera():set_shaker_parameter("headbob", "amplitude", 0)
	self:_update_throw_projectile_timers(t, input)
	self:_update_reload_timers(t, dt, input)
	self:_update_equip_weapon_timers(t, input)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil
	new_action = new_action or self:_check_action_weapon_gadget(t, input)
	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)

	if not new_action then
		new_action = self:_check_action_primary_attack(t, input)

		if not _G.IS_VR then
			self._shooting = new_action
		end
	end

	new_action = new_action or self:_check_action_throw_projectile(t, input)
	new_action = new_action or self:_check_action_equip(t, input)
	new_action = new_action or self:_check_action_interact(t, input)
	new_action = new_action or self:_check_action_steelsight(t, input)
	new_action = new_action or self:_check_action_deploy_underbarrel(t, input)

	self:_check_action_night_vision(t, input)
	self:_check_use_item(t, input)
end

function PlayerBleedOut:_check_use_item(t, input)
	local new_action = nil
	local action_wanted = input.btn_use_item_release and self._throw_time and t and t < self._throw_time

	if input.btn_use_item_press then
		self._throw_down = true
		self._throw_time = t + PlayerCarry.throw_limit_t
	end

	if action_wanted then
		local action_forbidden = self._use_item_expire_t or self:_changing_weapon() or self:_interacting() or self._ext_movement:has_carry_restriction() or self:_is_throwing_projectile() or self:_on_zipline()

		if not action_forbidden then
			managers.player:drop_carry()

			new_action = true
		end
	end

	if self._throw_down and input.btn_use_item_release then
		self._throw_down = false
	end

	return new_action
end

function PlayerBleedOut:_check_action_interact(t, input)
	if input.btn_interact_press then
		if _G.IS_VR then
			self._interact_hand = input.btn_interact_left_press and PlayerHand.LEFT or PlayerHand.RIGHT
		end

		if not self._intimidate_t or tweak_data.player.movement_state.interaction_delay < t - self._intimidate_t then
			self._intimidate_t = t

			if not PlayerArrested.call_teammate(self, "f11", t) then
				self:call_civilian("f11", t, false, true, self._revive_SO_data)
			end
		end
	end
end

function PlayerBleedOut:_check_change_weapon(...)
	local primary = self._unit:inventory():unit_by_selection(2)

	if alive(primary) and primary:base():weapon_tweak_data().not_allowed_in_bleedout then
		return false
	end

	if managers.player:has_category_upgrade("player", "primary_weapon_when_downed") then
		return PlayerBleedOut.super._check_change_weapon(self, ...)
	end

	return false
end

function PlayerBleedOut:_check_action_equip(...)
	local primary = self._unit:inventory():unit_by_selection(2)

	if alive(primary) and primary:base():weapon_tweak_data().not_allowed_in_bleedout then
		return false
	end

	if managers.player:has_category_upgrade("player", "primary_weapon_when_downed") then
		return PlayerBleedOut.super._check_action_equip(self, ...)
	end

	return false
end

function PlayerBleedOut:_check_action_steelsight(...)
	if managers.player:has_category_upgrade("player", "steelsight_when_downed") then
		return PlayerBleedOut.super._check_action_steelsight(self, ...)
	end

	return false
end

function PlayerBleedOut:_start_action_state_standard(t)
	managers.player:set_player_state("standard")
end

function PlayerBleedOut._register_revive_SO(revive_SO_data, variant)
	if revive_SO_data.SO_id or not managers.navigation:is_data_ready() then
		return
	end

	local followup_objective = {
		scan = true,
		type = "act",
		action = {
			variant = "crouch",
			body_part = 1,
			type = "act",
			blocks = {
				heavy_hurt = -1,
				hurt = -1,
				action = -1,
				aim = -1,
				walk = -1
			}
		}
	}
	local objective = {
		type = "revive",
		called = true,
		scan = true,
		destroy_clbk_key = false,
		follow_unit = revive_SO_data.unit,
		nav_seg = revive_SO_data.unit:movement():nav_tracker():nav_segment(),
		fail_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_rescue_SO_failed", revive_SO_data),
		complete_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_rescue_SO_completed", revive_SO_data),
		action_start_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_rescue_SO_started", revive_SO_data),
		action = {
			align_sync = true,
			type = "act",
			body_part = 1,
			variant = variant,
			blocks = {
				light_hurt = -1,
				hurt = -1,
				action = -1,
				heavy_hurt = -1,
				aim = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction[variant == "untie" and "free" or variant].timer,
		followup_objective = followup_objective
	}
	local so_descriptor = {
		interval = 0,
		AI_group = "friendlies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = revive_SO_data.unit:position(),
		admin_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_rescue_SO_administered", revive_SO_data),
		verification_clbk = callback(PlayerBleedOut, PlayerBleedOut, "rescue_SO_verification", revive_SO_data.unit)
	}
	revive_SO_data.variant = variant
	local so_id = "Playerrevive"
	revive_SO_data.SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)

	if not revive_SO_data.deathguard_SO_id then
		revive_SO_data.deathguard_SO_id = PlayerBleedOut._register_deathguard_SO(revive_SO_data.unit)
	end
end

function PlayerBleedOut:call_civilian(line, t, no_gesture, skip_alert, revive_SO_data)
	if not managers.player:has_category_upgrade("player", "civilian_reviver") or revive_SO_data and revive_SO_data.sympathy_civ then
		return
	end

	local detect_only = false
	local voice_type, plural, prime_target = self:_get_unit_intimidation_action(false, true, false, false, false, 0, true, detect_only)

	if prime_target then
		if detect_only then
			if not prime_target.unit:sound():speaking(t) then
				prime_target.unit:sound():say("_a01x_any", true)
			end
		else
			if not prime_target.unit:sound():speaking(t) then
				prime_target.unit:sound():say("stockholm_syndrome", true)
			end

			local queue_name = line .. "e_plu"

			self:_do_action_intimidate(t, not no_gesture and "cmd_come" or nil, queue_name, skip_alert)

			if Network:is_server() and prime_target.unit:brain():is_available_for_assignment({type = "revive"}) then
				local followup_objective = {
					interrupt_health = 1,
					interrupt_dis = -1,
					type = "free",
					action = {
						sync = true,
						body_part = 1,
						type = "idle"
					}
				}
				local objective = {
					type = "act",
					haste = "run",
					destroy_clbk_key = false,
					nav_seg = self._unit:movement():nav_tracker():nav_segment(),
					pos = self._unit:movement():nav_tracker():field_position(),
					fail_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_civ_revive_failed", revive_SO_data),
					complete_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_civ_revive_completed", revive_SO_data),
					action_start_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_civ_revive_started", revive_SO_data),
					action = {
						align_sync = true,
						type = "act",
						body_part = 1,
						variant = "revive",
						blocks = {
							light_hurt = -1,
							hurt = -1,
							action = -1,
							heavy_hurt = -1,
							aim = -1,
							walk = -1
						}
					},
					action_duration = tweak_data.interaction.revive.timer,
					followup_objective = followup_objective
				}
				revive_SO_data.sympathy_civ = prime_target.unit

				prime_target.unit:brain():set_objective(objective)
			end
		end
	end
end

function PlayerBleedOut:_unregister_revive_SO()
	if not self._revive_SO_data then
		return
	end

	if self._revive_SO_data.deathguard_SO_id then
		PlayerBleedOut._unregister_deathguard_SO(self._revive_SO_data.deathguard_SO_id)

		self._revive_SO_data.deathguard_SO_id = nil
	end

	if self._revive_SO_data.SO_id then
		managers.groupai:state():remove_special_objective(self._revive_SO_data.SO_id)

		self._revive_SO_data.SO_id = nil
	elseif self._revive_SO_data.rescuer then
		local rescuer = self._revive_SO_data.rescuer
		self._revive_SO_data.rescuer = nil

		if alive(rescuer) then
			rescuer:brain():set_objective(nil)
		end
	end

	if self._revive_SO_data.sympathy_civ then
		local sympathy_civ = self._revive_SO_data.sympathy_civ
		self._revive_SO_data.sympathy_civ = nil

		sympathy_civ:brain():set_objective(nil)
	end
end

function PlayerBleedOut._register_deathguard_SO(my_unit)
end

function PlayerBleedOut._unregister_deathguard_SO(so_id)
	managers.groupai:state():remove_special_objective(so_id)
end

function PlayerBleedOut:_start_action_bleedout(t)
	self:_interupt_action_running(t)

	self._state_data.ducking = true

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:kill_mover()
	self:_activate_mover(Idstring("duck"))
end

function PlayerBleedOut:_end_action_bleedout(t)
	if not self:_can_stand() then
		return
	end

	self._state_data.ducking = false

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:kill_mover()
	self:_activate_mover(Idstring("stand"))
end

function PlayerBleedOut:_update_movement(t, dt)
	self:_update_network_position(t, dt, self._unit:position())
end

function PlayerBleedOut:on_rescue_SO_administered(revive_SO_data, receiver_unit)
	if revive_SO_data.rescuer then
		debug_pause("[PlayerBleedOut:on_rescue_SO_administered] Already had a rescuer!!!!", receiver_unit, revive_SO_data.rescuer)
	end

	revive_SO_data.rescuer = receiver_unit
	revive_SO_data.SO_id = nil

	if receiver_unit:movement():carrying_bag() then
		receiver_unit:movement():throw_bag()
	end
end

function PlayerBleedOut:on_rescue_SO_failed(revive_SO_data, rescuer)
	if revive_SO_data.rescuer then
		revive_SO_data.rescuer = nil

		PlayerBleedOut._register_revive_SO(revive_SO_data, revive_SO_data.variant)
	end
end

function PlayerBleedOut:on_rescue_SO_completed(revive_SO_data, rescuer)
	if revive_SO_data.sympathy_civ then
		local objective = {
			interrupt_health = 1,
			interrupt_dis = -1,
			type = "free",
			action = {
				sync = true,
				body_part = 1,
				type = "idle"
			}
		}

		revive_SO_data.sympathy_civ:brain():set_objective(objective)
	end

	revive_SO_data.rescuer = nil
end

function PlayerBleedOut:on_rescue_SO_started(revive_SO_data, rescuer)
	for c_key, criminal in pairs(managers.groupai:state():all_AI_criminals()) do
		if c_key ~= rescuer:key() then
			local obj = criminal.unit:brain():objective()

			if obj and obj.type == "revive" and obj.follow_unit:key() == revive_SO_data.unit:key() then
				criminal.unit:brain():set_objective(nil)
			end
		end
	end
end

function PlayerBleedOut.rescue_SO_verification(ignore_this, my_unit, unit)
	return not unit:movement():cool() and not my_unit:movement():team().foes[unit:movement():team().id]
end

function PlayerBleedOut:on_civ_revive_completed(revive_SO_data, sympathy_civ)
	if sympathy_civ ~= revive_SO_data.sympathy_civ then
		debug_pause_unit(sympathy_civ, "[PlayerBleedOut:on_civ_revive_completed] idiot thinks he is reviving", sympathy_civ)

		return
	end

	revive_SO_data.sympathy_civ = nil

	revive_SO_data.unit:character_damage():revive(sympathy_civ)

	if managers.player:has_category_upgrade("player", "civilian_gives_ammo") then
		managers.game_play_central:spawn_pickup({
			name = "ammo",
			position = sympathy_civ:position(),
			rotation = Rotation()
		})
	end
end

function PlayerBleedOut:on_civ_revive_started(revive_SO_data, sympathy_civ)
	if sympathy_civ ~= revive_SO_data.sympathy_civ then
		debug_pause_unit(sympathy_civ, "[PlayerBleedOut:on_civ_revive_started] idiot thinks he is reviving", sympathy_civ)

		return
	end

	revive_SO_data.unit:character_damage():pause_downed_timer()

	if revive_SO_data.SO_id then
		managers.groupai:state():remove_special_objective(revive_SO_data.SO_id)

		revive_SO_data.SO_id = nil
	elseif revive_SO_data.rescuer then
		local rescuer = revive_SO_data.rescuer
		revive_SO_data.rescuer = nil

		if alive(rescuer) then
			rescuer:brain():set_objective(nil)
		end
	end
end

function PlayerBleedOut:on_civ_revive_failed(revive_SO_data, sympathy_civ)
	if revive_SO_data.sympathy_civ then
		if sympathy_civ ~= revive_SO_data.sympathy_civ then
			debug_pause_unit(sympathy_civ, "[PlayerBleedOut:on_civ_revive_failed] idiot thinks he is reviving", sympathy_civ)

			return
		end

		revive_SO_data.unit:character_damage():unpause_downed_timer()

		revive_SO_data.sympathy_civ = nil
	end
end

function PlayerBleedOut:verif_clbk_is_unit_deathguard(enemy_unit)
	local char_tweak = tweak_data.character[enemy_unit:base()._tweak_table]

	return char_tweak.deathguard
end

function PlayerBleedOut:clbk_deathguard_administered(unit)
	unit:movement():set_cool(false)
end

function PlayerBleedOut:pre_destroy(unit)
	PlayerBleedOut.super.pre_destroy(self, unit)

	if Network:is_server() then
		self:_unregister_revive_SO()
	end
end

function PlayerBleedOut:destroy()
	if Network:is_server() then
		self:_unregister_revive_SO()
	end
end

