PlayerTasedVR = PlayerTased or Application:error("PlayerTasedVR need PlayerTased!")
local __update_movement = PlayerTased._update_movement
local __enter = PlayerTased.enter
local __exit = PlayerTased.exit
local __destroy = PlayerTased.destroy

function PlayerTasedVR:enter(...)
	__enter(self, ...)

	self._state_data.tased = true

	self._unit:hand():set_tased(true)
	self:set_belt_and_hands_enabled(false)
end

function PlayerTasedVR:exit(...)
	__exit(self, ...)

	if alive(self._equipped_unit) then
		self._equipped_unit:base():stop_shooting()

		if self._equipped_unit:base().akimbo then
			self._equipped_unit:base()._second_gun:base():stop_shooting()
		end

		if table.contains(self._equipped_unit:base():weapon_tweak_data().categories, "bow") then
			self:_start_action_reload_enter(TimerManager:game():time())
		end
	end

	self._state_data.tased = false

	self._unit:hand():set_tased(false)
	self:set_belt_and_hands_enabled(true)
end

function PlayerTasedVR:destroy()
	if managers.network:session() then
		self:set_belt_and_hands_enabled(true)
	end

	__destroy(self)
end

local mvec_pos_new = Vector3()
local mvec_hmd_delta = Vector3()
local mvec_hmd_pos = Vector3()

function PlayerTasedVR:_update_movement(t, dt)
	__update_movement(self, t, dt)

	local pos_new = mvec_pos_new

	mvector3.set(pos_new, self._ext_movement:ghost_position())

	local hmd_pos = mvec_hmd_pos

	mvector3.set(hmd_pos, self._ext_movement:hmd_position())

	local hmd_delta = mvec_hmd_delta

	mvector3.set(hmd_delta, self._ext_movement:hmd_delta())
	mvector3.set_z(hmd_delta, 0)
	mvector3.rotate_with(hmd_delta, self._camera_base_rot)
	mvector3.add(pos_new, hmd_delta)
	self._ext_movement:set_ghost_position(pos_new, self._unit:position())
end

function PlayerTasedVR:_check_action_shock(t, input)
	local has_akimbo = alive(self._equipped_unit) and self._equipped_unit:base().akimbo
	local use_akimbo = has_akimbo and math.random() > 0.5

	if self._next_shock < t then
		self._num_shocks = self._num_shocks + 1
		self._next_shock = t + 0.25 + math.rand(1)
		self._taser_value = math.max(self._taser_value - 0.25, 0)

		self._unit:sound():play("tasered_shock")
		managers.rumble:play("electric_shock")

		if not alive(self._counter_taser_unit) then
			self._camera_unit:base():start_shooting()

			self._recoil_t = t + 0.5

			if not managers.player:has_category_upgrade("player", "resist_firing_tased") then
				if use_akimbo then
					input.btn_akimbo_fire_state = true
					input.btn_akimbo_fire_press = true
				else
					input.btn_primary_attack_state = true
					input.btn_primary_attack_press = true
				end
			end

			self._camera_unit:base():recoil_kick(-5, 5, -5, 5)
			self._unit:camera():play_redirect(self:get_animation("tased_boost"))
		end
	elseif self._recoil_t then
		if not managers.player:has_category_upgrade("player", "resist_firing_tased") then
			if use_akimbo then
				input.btn_akimbo_fire_state = true
			else
				input.btn_primary_attack_state = true
			end
		end

		if self._recoil_t < t then
			self._recoil_t = nil

			self._camera_unit:base():stop_shooting()
		end
	end
end

function PlayerTasedVR:_check_action_primary_attack(t, input)
	local new_action = nil
	local action_forbidden = self:chk_action_forbidden("primary_attack")
	action_forbidden = action_forbidden or self:_is_reloading() or self:_changing_weapon() or self._melee_expire_t or self._use_item_expire_t or self:_interacting() or alive(self._counter_taser_unit)
	local action_wanted = input.btn_primary_attack_state or input.btn_akimbo_fire_state

	if action_wanted then
		if not action_forbidden then
			self._queue_reload_interupt = nil

			self._ext_inventory:equip_selected_primary(false)

			if self._equipped_unit then
				if self._equipped_unit:base().akimbo then
					new_action = self:_check_fire_per_weapon(t, input.btn_akimbo_fire_press, input.btn_akimbo_fire_state, input.btn_akimbo_fire_release, self._equipped_unit:base()._second_gun:base(), true) or new_action
				end

				new_action = self:_check_fire_per_weapon(t, input.btn_primary_attack_press, input.btn_primary_attack_state, input.btn_primary_attack_release, self._equipped_unit:base()) or new_action
			end
		elseif self:_is_reloading() and self._equipped_unit:base():reload_interuptable() and (input.btn_primary_attack_press or input.btn_akimbo_fire_press) then
			self._queue_reload_interupt = true
		end
	end

	if not new_action and self._shooting and self._shooting_weapons then
		for k, weap_base in pairs(self._shooting_weapons) do
			weap_base:stop_shooting()

			self._shooting_weapons[k] = nil
		end

		if not next(self._shooting_weapons) then
			self._shooting = false
		end
	end

	return new_action
end

function PlayerTasedVR:_check_fire_per_weapon(t, pressed, held, released, weap_base, akimbo)
	if not held then
		return false
	end

	local new_action = false
	local fire_mode = weap_base:fire_mode()

	if weap_base:out_of_ammo() then
		if pressed then
			weap_base:dryfire()
		end
	elseif weap_base.clip_empty and weap_base:clip_empty() then
		if fire_mode == "single" and pressed then
			weap_base:dryfire()
		end
	elseif self._num_shocks > 1 and weap_base.can_refire_while_tased and not weap_base:can_refire_while_tased() then
		-- Nothing
	elseif self._running then
		self:_interupt_action_running(t)
	else
		if not self._shooting and weap_base:start_shooting_allowed() then
			local start = fire_mode == "single" and pressed
			start = start or fire_mode ~= "single" and held

			if start then
				weap_base:start_shooting()

				if not self._state_data.in_steelsight or not weap_base:tweak_data_anim_play("fire_steelsight", weap_base:fire_rate_multiplier()) then
					weap_base:tweak_data_anim_play("fire", weap_base:fire_rate_multiplier())
				end

				self._shooting_weapons = self._shooting_weapons or {}
				self._shooting_weapons[akimbo and 2 or 1] = weap_base
				self._shooting = true
			end
		end

		if not self._shooting_weapons or not self._shooting_weapons[akimbo and 2 or 1] then
			return
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
			if pressed then
				fired = weap_base:trigger_pressed(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)

				if weap_base:fire_on_release() then
					if weap_base.set_tased_shot then
						weap_base:set_tased_shot(true)
					end

					fired = weap_base:trigger_released(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)

					if weap_base.set_tased_shot then
						weap_base:set_tased_shot(false)
					end
				end
			end
		elseif held then
			fired = weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
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

				self._ext_network:send("shot_blank", impact, 0)
			end
		elseif fire_mode == "single" then
			new_action = false
		end
	end

	return new_action
end

function PlayerTasedVR:set_belt_and_hands_enabled(enabled)
	if not enabled then
		local belt_states = {
			melee = managers.hud:belt():state("melee"),
			deployable = managers.hud:belt():state("deployable"),
			deployable_secondary = managers.hud:belt():state("deployable_secondary"),
			throwable = managers.hud:belt():state("throwable"),
			weapon = managers.hud:belt():state("weapon"),
			bag = managers.hud:belt():state("bag")
		}

		for id, state in pairs(belt_states) do
			if state ~= "disabled" then
				managers.hud:belt():set_state(id, "disabled")
			end
		end
	else
		managers.hud:belt():set_state("melee", "default")
		managers.hud:belt():set_state("weapon", "default")
		managers.hud:belt():set_state("throwable", managers.player:get_grenade_amount(managers.network:session():local_peer():id()) > 0 and "default" or "invalid")
		managers.hud:belt():set_state("bag", managers.player:is_carrying() and "default" or "inactive")

		for slot, equipment in ipairs({
			managers.player:equipment_in_slot(1),
			managers.player:equipment_in_slot(2)
		}) do
			local amount = managers.player:get_equipment_amount(equipment)

			managers.hud:belt():set_state(slot == 1 and "deployable" or "deployable_secondary", amount > 0 and "default" or "invalid")
		end
	end
end
