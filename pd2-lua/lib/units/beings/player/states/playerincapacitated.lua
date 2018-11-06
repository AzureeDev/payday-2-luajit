PlayerIncapacitated = PlayerIncapacitated or class(PlayerStandard)
PlayerIncapacitated._update_movement = PlayerBleedOut._update_movement

function PlayerIncapacitated:init(unit)
	PlayerIncapacitated.super.init(self, unit)
end

function PlayerIncapacitated:enter(state_data, enter_data)
	PlayerIncapacitated.super.enter(self, state_data, enter_data)
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

	self._revive_SO_data = {
		unit = self._unit
	}

	self:_start_action_incapacitated(managers.player:player_timer():time())
	self._unit:base():set_slot(self._unit, 4)
	self._unit:camera():camera_unit():base():set_target_tilt(80)
	self._unit:character_damage():on_incapacitated()
	self._unit:character_damage():on_incapacitated_state_enter()

	self._reequip_weapon = enter_data and enter_data.equip_weapon
	self._next_shock = 0.5
	self._taser_value = 0.5

	managers.groupai:state():on_criminal_neutralized(self._unit)

	if Network:is_server() then
		PlayerBleedOut._register_revive_SO(self._revive_SO_data, "revive")
	end

	managers.groupai:state():report_criminal_downed(self._unit)
	managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, -1, table.index_of(ContourExt.indexed_types, "teammate_downed"), true, 1)
end

function PlayerIncapacitated:_enter(enter_data)
	local preset = nil

	if managers.groupai:state():whisper_mode() then
		preset = {
			"pl_mask_on_friend_combatant_whisper_mode",
			"pl_mask_on_friend_non_combatant_whisper_mode",
			"pl_mask_on_foe_combatant_whisper_mode_crouch",
			"pl_mask_on_foe_non_combatant_whisper_mode_crouch"
		}
	else
		preset = {
			"pl_friend_combatant_cbt",
			"pl_friend_non_combatant_cbt"
		}
	end

	self._ext_movement:set_attention_settings(preset)

	if Network:is_server() and self._ext_movement:nav_tracker() then
		managers.groupai:state():on_player_weapons_hot()
	end
end

function PlayerIncapacitated:exit(state_data, new_state_name)
	PlayerIncapacitated.super.exit(self, state_data, new_state_name)
	self:_end_action_incapacitated(managers.player:player_timer():time())
	managers.environment_controller:set_taser_value(1)
	PlayerBleedOut._unregister_revive_SO(self)
	managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, -1, table.index_of(ContourExt.indexed_types, "teammate_downed"), false, 1)

	return {
		equip_weapon = self._reequip_weapon
	}
end

function PlayerIncapacitated:interaction_blocked()
	return true
end

function PlayerIncapacitated:update(t, dt)
	PlayerIncapacitated.super.update(self, t, dt)
end

function PlayerIncapacitated:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	if self._next_shock < t then
		self._unit:camera():play_shaker("player_taser_shock", 0.5, 10)

		self._next_shock = t + 0.5 + math.rand(2.5)

		self._camera_unit:base():start_shooting()

		self._recoil_t = t + 0.5

		self._camera_unit:base():recoil_kick(-2, 2, -2, 2)

		self._taser_value = 0.25

		managers.rumble:play("incapacitated_shock")
		self._unit:camera()._camera_unit:base():animate_fov(math.lerp(65, 75, math.random()), 0.33)
	elseif self._recoil_t and self._recoil_t < t then
		self._recoil_t = nil

		self._camera_unit:base():stop_shooting()
	end

	self._taser_value = math.step(self._taser_value, 0.75, dt / 2)

	managers.environment_controller:set_taser_value(self._taser_value)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil

	self:_check_action_interact(t, input)
end

function PlayerIncapacitated:_check_action_interact(t, input)
	if input.btn_interact_press then
		if _G.IS_VR then
			self._interact_hand = input.btn_interact_left_press and PlayerHand.LEFT or PlayerHand.RIGHT
		end

		if not self._intimidate_t or tweak_data.player.movement_state.interaction_delay < t - self._intimidate_t then
			self._intimidate_t = t

			PlayerArrested.call_teammate(self, "f11", t, true, true, true)
		end
	end
end

function PlayerIncapacitated:_start_action_incapacitated(t)
	self:_interupt_action_running(t)

	self._state_data.ducking = true

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:kill_mover()
	self:_activate_mover(Idstring("duck"))
	self._unit:camera():play_redirect(self:get_animation("tased_exit"))
	self._unit:camera()._camera_unit:base():animate_fov(75)
end

function PlayerIncapacitated:_end_action_incapacitated(t)
	if not self:_can_stand() then
		return
	end

	self._state_data.ducking = false

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:kill_mover()
	self:_activate_mover(Idstring("stand"))
end

function PlayerIncapacitated:pre_destroy(unit)
	PlayerIncapacitated.super.pre_destroy(self, unit)
	PlayerBleedOut._unregister_revive_SO(self)
end

function PlayerIncapacitated:destroy(unit)
	PlayerBleedOut._unregister_revive_SO(self)
	managers.environment_controller:set_taser_value(1)
end
