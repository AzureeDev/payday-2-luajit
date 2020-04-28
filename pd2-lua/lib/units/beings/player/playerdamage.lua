PlayerDamage = PlayerDamage or class()
PlayerDamage._HEALTH_INIT = tweak_data.player.damage.HEALTH_INIT
PlayerDamage._ARMOR_INIT = tweak_data.player.damage.ARMOR_INIT
PlayerDamage._ARMOR_STEPS = tweak_data.player.damage.ARMOR_STEPS
PlayerDamage._ARMOR_DAMAGE_REDUCTION = tweak_data.player.damage.ARMOR_DAMAGE_REDUCTION
PlayerDamage._ARMOR_DAMAGE_REDUCTION_STEPS = tweak_data.player.damage.ARMOR_DAMAGE_REDUCTION_STEPS
PlayerDamage._UPPERS_COOLDOWN = 20

function PlayerDamage:init(unit)
	self._lives_init = tweak_data.player.damage.LIVES_INIT

	if Global.game_settings.one_down then
		self._lives_init = 2
	end

	self._lives_init = managers.modifiers:modify_value("PlayerDamage:GetMaximumLives", self._lives_init)
	self._unit = unit
	self._max_health_reduction = managers.player:upgrade_value("player", "max_health_reduction", 1)
	self._healing_reduction = managers.player:upgrade_value("player", "healing_reduction", 1)
	self._revives = Application:digest_value(0, true)
	self._uppers_elapsed = 0

	self:replenish()

	local player_manager = managers.player
	self._bleed_out_health = Application:digest_value(tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * player_manager:upgrade_value("player", "bleed_out_health_multiplier", 1), true)
	self._god_mode = Global.god_mode
	self._invulnerable = false
	self._mission_damage_blockers = {}
	self._gui = Overlay:newgui()
	self._ws = self._gui:create_screen_workspace()
	self._focus_delay_mul = 1
	self._dmg_interval = tweak_data.player.damage.MIN_DAMAGE_INTERVAL
	self._next_allowed_dmg_t = Application:digest_value(-100, true)
	self._last_received_dmg = 0
	self._next_allowed_sup_t = -100
	self._last_received_sup = 0
	self._supperssion_data = {}
	self._inflict_damage_body = self._unit:body("inflict_reciever")

	self._inflict_damage_body:set_extension(self._inflict_damage_body:extension() or {})

	local body_ext = PlayerBodyDamage:new(self._unit, self, self._inflict_damage_body)
	self._inflict_damage_body:extension().damage = body_ext

	managers.sequence:add_inflict_updator_body("fire", self._unit:key(), self._inflict_damage_body:key(), self._inflict_damage_body:extension().damage)

	self._doh_data = tweak_data.upgrades.damage_to_hot_data or {}
	self._damage_to_hot_stack = {}
	self._armor_stored_health = 0
	self._can_take_dmg_timer = 0
	self._regen_on_the_side_timer = 0
	self._regen_on_the_side = false
	self._interaction = managers.interaction
	self._armor_regen_mul = managers.player:upgrade_value("player", "armor_regen_time_mul", 1)
	self._dire_need = managers.player:has_category_upgrade("player", "armor_depleted_stagger_shot")
	self._has_damage_speed = managers.player:has_inactivate_temporary_upgrade("temporary", "damage_speed_multiplier")
	self._has_damage_speed_team = managers.player:upgrade_value("player", "team_damage_speed_multiplier_send", 0) ~= 0

	local function revive_player()
		self:revive(true)
	end

	managers.player:register_message(Message.RevivePlayer, self, revive_player)

	self._current_armor_fill = 0
	local has_swansong_skill = player_manager:has_category_upgrade("temporary", "berserker_damage_multiplier")
	self._current_state = nil
	self._listener_holder = unit:event_listener()

	if player_manager:has_category_upgrade("player", "damage_to_armor") then
		local damage_to_armor_data = player_manager:upgrade_value("player", "damage_to_armor", nil)
		local armor_data = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)]

		if damage_to_armor_data and armor_data then
			local idx = armor_data.upgrade_level
			self._damage_to_armor = {
				armor_value = damage_to_armor_data[idx][1],
				target_tick = damage_to_armor_data[idx][2],
				elapsed = 0
			}

			local function on_damage(damage_info)
				local attacker_unit = damage_info and damage_info.attacker_unit

				if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
					attacker_unit = attacker_unit:base():thrower_unit()
				end

				if self._unit == attacker_unit then
					local time = Application:time()

					if self._damage_to_armor.target_tick < time - self._damage_to_armor.elapsed then
						self._damage_to_armor.elapsed = time

						self:restore_armor(self._damage_to_armor.armor_value, true)
					end
				end
			end

			CopDamage.register_listener("on_damage", {
				"on_damage"
			}, on_damage)
		end
	end

	self._listener_holder:add("on_use_armor_bag", {
		"on_use_armor_bag"
	}, callback(self, self, "_on_use_armor_bag_event"))

	if self:_init_armor_grinding_data() then
		function self._on_damage_callback_func()
			return callback(self, self, "_on_damage_armor_grinding")
		end

		self:_add_on_damage_event()
		self._listener_holder:add("on_enter_bleedout", {
			"on_enter_bleedout"
		}, callback(self, self, "_on_enter_bleedout_event"))

		if has_swansong_skill then
			self._listener_holder:add("on_enter_swansong", {
				"on_enter_swansong"
			}, callback(self, self, "_on_enter_swansong_event"))
			self._listener_holder:add("on_exit_swansong", {
				"on_enter_bleedout"
			}, callback(self, self, "_on_exit_swansong_event"))
		end

		self._listener_holder:add("on_revive", {
			"on_revive"
		}, callback(self, self, "_on_revive_event"))
	else
		self:_init_standard_listeners()
	end

	if player_manager:has_category_upgrade("temporary", "revive_damage_reduction") then
		self._listener_holder:add("combat_medic_damage_reduction", {
			"on_revive"
		}, callback(self, self, "_activate_combat_medic_damage_reduction"))
	end

	if player_manager:has_category_upgrade("player", "revive_damage_reduction") and player_manager:has_category_upgrade("player", "revive_damage_reduction") then
		local function on_revive_interaction_start()
			managers.player:set_property("revive_damage_reduction", player_manager:upgrade_value("player", "revive_damage_reduction"), 1)
		end

		local function on_exit_interaction()
			managers.player:remove_property("revive_damage_reduction")
		end

		local function on_revive_interaction_success()
			managers.player:activate_temporary_upgrade("temporary", "revive_damage_reduction")
		end

		self._listener_holder:add("on_revive_interaction_start", {
			"on_revive_interaction_start"
		}, on_revive_interaction_start)
		self._listener_holder:add("on_revive_interaction_interrupt", {
			"on_revive_interaction_interrupt"
		}, on_exit_interaction)
		self._listener_holder:add("on_revive_interaction_success", {
			"on_revive_interaction_success"
		}, on_revive_interaction_success)
	end

	managers.mission:add_global_event_listener("player_regenerate_armor", {
		"player_regenerate_armor"
	}, callback(self, self, "_regenerate_armor"))
	managers.mission:add_global_event_listener("player_force_bleedout", {
		"player_force_bleedout"
	}, callback(self, self, "force_into_bleedout", false))

	local level_tweak = tweak_data.levels[managers.job:current_level_id()]

	if level_tweak and level_tweak.is_safehouse and not level_tweak.is_safehouse_combat then
		self:set_mission_damage_blockers("damage_fall_disabled", true)
		self:set_mission_damage_blockers("invulnerable", true)
	end

	self._delayed_damage = {
		epsilon = 0.001,
		chunks = {}
	}

	self:clear_delayed_damage()
end

function PlayerDamage:_init_standard_listeners()
	function self._on_damage_callback_func()
		return callback(self, self, "_on_damage_event")
	end

	self:_add_on_damage_event()
	self._listener_holder:add("on_enter_bleedout", {
		"on_enter_bleedout"
	}, callback(self, self, "_on_enter_bleedout_event"))
	self._listener_holder:add("on_revive", {
		"on_revive"
	}, callback(self, self, "_on_revive_event"))

	if managers.player:has_category_upgrade("temporary", "berserker_damage_multiplier") then
		self._listener_holder:add("on_enter_swansong", {
			"on_enter_swansong"
		}, callback(self, self, "_on_enter_swansong_event"))
		self._listener_holder:add("on_exit_swansong", {
			"on_enter_bleedout"
		}, callback(self, self, "_on_exit_swansong_event"))
	end
end

function PlayerDamage:_on_use_armor_bag_event()
	self:_init_armor_grinding_data()
	self:_regenerate_armor()
end

function PlayerDamage:_on_damage_event()
	self:set_regenerate_timer_to_max()

	local armor_broken = self:_max_armor() > 0 and self:get_real_armor() <= 0

	if armor_broken and self._has_damage_speed then
		managers.player:activate_temporary_upgrade("temporary", "damage_speed_multiplier")

		if self._has_damage_speed_team then
			managers.player:send_activate_temporary_team_upgrade_to_peers("temporary", "team_damage_speed_multiplier_received")
		end
	end
end

function PlayerDamage:_on_damage_armor_grinding()
	self._current_state = self._update_armor_grinding
end

function PlayerDamage:_init_armor_grinding_data()
	local armor_grinding_data = managers.player:upgrade_value("player", "armor_grinding", nil)

	if armor_grinding_data and armor_grinding_data ~= 0 then
		local armor_data = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)]
		local idx = armor_data.upgrade_level
		self._armor_grinding = {
			armor_value = armor_grinding_data[idx][1],
			target_tick = armor_grinding_data[idx][2],
			elapsed = 0
		}

		return true
	end

	return false
end

function PlayerDamage:_on_enter_bleedout_event()
	self:_remove_on_damage_event()
end

function PlayerDamage:_on_enter_swansong_event()
	self:_remove_on_damage_event()

	self._block_medkit_auto_revive = true
	self.swansong = true

	if Network:is_client() then
		managers.network:session():send_to_host("sync_player_swansong", self._unit, true)
	else
		managers.network:session():send_to_peers("sync_swansong_hud", self._unit, managers.network:session():local_peer():id())
	end
end

function PlayerDamage:_on_exit_swansong_event()
	self.swansong = nil

	if Network:is_client() then
		managers.network:session():send_to_host("sync_player_swansong", self._unit, false)
	end
end

function PlayerDamage:_activate_combat_medic_damage_reduction()
	managers.player:activate_temporary_upgrade("temporary", "revive_damage_reduction")
end

function PlayerDamage:_on_revive_event()
	self:_add_on_damage_event()

	self._block_medkit_auto_revive = false
	self.swansong = nil
end

function PlayerDamage:_remove_on_damage_event()
	self._listener_holder:remove("on_damage")
end

function PlayerDamage:_add_on_damage_event()
	self._listener_holder:add("on_damage", {
		"on_damage",
		"suppression_max"
	}, self:_on_damage_callback_func())
end

function PlayerDamage:recharge_pistol_messiah()
	local recharge = managers.player:upgrade_value("player", "recharge_pistol_messiah", 0)
	self._messiah_charges = math.max(self._messiah_charges + recharge, 1)
end

function PlayerDamage:post_init()
	self:send_set_status()
end

function PlayerDamage:send_set_status()
	self:_send_set_armor()
	self:_send_set_health()
end

function PlayerDamage:force_into_bleedout(can_activate_berserker)
	if self:incapacitated() or self:arrested() then
		return
	end

	self._check_berserker_done = nil

	self:set_health(0)
	self:_chk_cheat_death()
	self:_damage_screen()
	self:_check_bleed_out(can_activate_berserker)
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
end

local function get_heartbeat_value(t)
	local speed = 550
	local val = math.sin(t * speed)

	if val < 0 then
		val = -math.clamp(math.sin(t * speed + speed / 5), -1, 0)
	end

	return val < 0.4 and 0 or val
end

function PlayerDamage:stop_vr_heartbeat()
	self._heartbeat_t = nil
end

function PlayerDamage:update(unit, t, dt)
	if _G.IS_VR and self._heartbeat_t and t < self._heartbeat_t then
		local intensity_mul = 1 - (t - self._heartbeat_start_t) / (self._heartbeat_t - self._heartbeat_start_t)
		local controller = self._unit:base():controller():get_controller("vr")

		for i = 0, 1, 1 do
			local intensity = get_heartbeat_value(t)
			intensity = intensity * (1 - math.clamp(self:health_ratio() / 0.3, 0, 1))
			intensity = intensity * intensity_mul

			controller:trigger_haptic_pulse(i, 0, intensity * 900)
		end
	end

	self:_check_update_max_health()
	self:_check_update_max_armor()
	self:_update_can_take_dmg_timer(dt)
	self:_update_regen_on_the_side(dt)

	if not self._armor_stored_health_max_set then
		self._armor_stored_health_max_set = true

		self:update_armor_stored_health()
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") then
		self._chico_injector_active = true
		local total_time = managers.player:upgrade_value("temporary", "chico_injector")[2]
		local current_time = managers.player:get_activate_temporary_expire_time("temporary", "chico_injector") - t

		managers.hud:set_player_ability_radial({
			current = current_time,
			total = total_time
		})
	elseif self._chico_injector_active then
		managers.hud:set_player_ability_radial({
			current = 0,
			total = 1
		})

		self._chico_injector_active = nil
	end

	local is_berserker_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

	if self._check_berserker_done then
		if is_berserker_active then
			if self._unit:movement():tased() then
				self._tased_during_berserker = true
			else
				self._tased_during_berserker = false
			end
		end

		if not is_berserker_active then
			if self._unit:movement():tased() then
				self._bleed_out_blocked_by_tased = true
			else
				self._bleed_out_blocked_by_tased = false
				self._check_berserker_done = nil

				managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_normal", "")
				managers.hud:set_player_custom_radial({
					current = 0,
					total = self:_max_health(),
					revives = Application:digest_value(self._revives, false)
				})
				self:force_into_bleedout()

				if not self._bleed_out then
					self._disable_next_swansong = true
				end
			end
		else
			local expire_time = managers.player:get_activate_temporary_expire_time("temporary", "berserker_damage_multiplier")
			local total_time = managers.player:upgrade_value("temporary", "berserker_damage_multiplier")
			total_time = total_time and total_time[2] or 0
			local delta = 0
			local max_health = self:_max_health()

			if total_time ~= 0 then
				delta = math.clamp((expire_time - Application:time()) / total_time, 0, 1)
			end

			managers.hud:set_player_custom_radial({
				current = delta * max_health,
				total = max_health,
				revives = Application:digest_value(self._revives, false)
			})
			managers.network:session():send_to_peers("sync_swansong_timer", self._unit, delta * max_health, max_health, Application:digest_value(self._revives, false), managers.network:session():local_peer():id())
		end
	end

	if self._bleed_out_blocked_by_zipline and not self._unit:movement():zipline_unit() then
		self:force_into_bleedout(true)

		self._bleed_out_blocked_by_zipline = nil
	end

	if self._bleed_out_blocked_by_movement_state and not self._unit:movement():current_state():bleed_out_blocked() then
		self:force_into_bleedout()

		self._bleed_out_blocked_by_movement_state = nil
	end

	if self._bleed_out_blocked_by_tased and not self._tased_during_berserker and not self._unit:movement():tased() then
		self:force_into_bleedout()

		self._bleed_out_blocked_by_tased = nil
	end

	if self._current_state then
		self:_current_state(t, dt)
	end

	self:_update_armor_hud(t, dt)

	if self._tinnitus_data then
		self._tinnitus_data.intensity = (self._tinnitus_data.end_t - t) / self._tinnitus_data.duration

		if self._tinnitus_data.intensity <= 0 then
			self:_stop_tinnitus()
		else
			SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, self._tinnitus_data.intensity * 100))
		end
	end

	if self._concussion_data then
		self._concussion_data.intensity = (self._concussion_data.end_t - t) / self._concussion_data.duration

		if self._concussion_data.intensity <= 0 then
			self:_stop_concussion()
		else
			SoundDevice:set_rtpc("concussion_effect", self._concussion_data.intensity * 100)
		end
	end

	if not self._downed_timer and self._downed_progression then
		self._downed_progression = math.max(0, self._downed_progression - dt * 50)

		if not _G.IS_VR then
			managers.environment_controller:set_downed_value(self._downed_progression)
		end

		SoundDevice:set_rtpc("downed_state_progression", self._downed_progression)

		if self._downed_progression == 0 then
			self._unit:sound():play("critical_state_heart_stop")

			self._downed_progression = nil
		end
	end

	if self._auto_revive_timer then
		if not managers.platform:presence() == "Playing" or not self._bleed_out or self._dead or self:incapacitated() or self:arrested() or self._check_berserker_done then
			self._auto_revive_timer = nil
		else
			self._auto_revive_timer = self._auto_revive_timer - dt

			if self._auto_revive_timer <= 0 then
				self:revive(true)
				self._unit:sound_source():post_event("nine_lives_skill")

				self._auto_revive_timer = nil
			end
		end
	end

	if self._revive_miss then
		self._revive_miss = self._revive_miss - dt

		if self._revive_miss <= 0 then
			self._revive_miss = nil
		end
	end

	self:_upd_suppression(t, dt)

	if not self._dead and not self._bleed_out and not self._check_berserker_done then
		self:_upd_health_regen(t, dt)
	end

	if not self:is_downed() then
		self:_update_delayed_damage(t, dt)
	end
end

function PlayerDamage:get_revives()
	local revives = 0

	if self._revives then
		revives = Application:digest_value(self._revives, false)
	end

	return revives
end

function PlayerDamage:_update_armor_hud(t, dt)
	local real_armor = self:get_real_armor()
	self._current_armor_fill = math.lerp(self._current_armor_fill, real_armor, 10 * dt)

	if math.abs(self._current_armor_fill - real_armor) > 0.01 then
		managers.hud:set_player_armor({
			current = self._current_armor_fill,
			total = self:_max_armor()
		})
	end

	if self._hurt_value then
		self._hurt_value = math.min(1, self._hurt_value + dt)
	end
end

function PlayerDamage:_update_regenerate_timer(t, dt)
	self._regenerate_timer = math.max(self._regenerate_timer - dt * (self._regenerate_speed or 1), 0)

	if self._regenerate_timer <= 0 then
		self:_regenerate_armor()
	end
end

function PlayerDamage:_update_armor_grinding(t, dt)
	self._armor_grinding.elapsed = self._armor_grinding.elapsed + dt

	if self._armor_grinding.target_tick <= self._armor_grinding.elapsed then
		self._armor_grinding.elapsed = 0

		self:change_armor(self._armor_grinding.armor_value)
	end
end

function PlayerDamage:band_aid_health()
	if managers.platform:presence() == "Playing" and (self:arrested() or self:need_revive()) then
		return
	end

	self:change_health(self:_max_health() * self._healing_reduction)

	self._said_hurt = false

	if math.rand(1) < managers.player:upgrade_value("first_aid_kit", "downs_restore_chance", 0) then
		self._revives = Application:digest_value(math.min(self._lives_init + managers.player:upgrade_value("player", "additional_lives", 0), Application:digest_value(self._revives, false) + 1), true)
		self._revive_health_i = math.max(self._revive_health_i - 1, 1)

		managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)
	end
end

function PlayerDamage:recover_health()
	if managers.platform:presence() == "Playing" and (self:arrested() or self:need_revive()) then
		self:revive(true)
	end

	self:_regenerated(true)
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
end

function PlayerDamage:replenish()
	if (Application:editor() or managers.platform:presence() == "Playing") and (self:arrested() or self:need_revive()) then
		self:revive(true)
	end

	self:_regenerated()
	self:_regenerate_armor()
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	SoundDevice:set_rtpc("shield_status", 100)
	SoundDevice:set_rtpc("downed_state_progression", 0)
end

function PlayerDamage:_regenerate_armor(no_sound)
	if self._unit:sound() and not no_sound then
		self._unit:sound():play("shield_full_indicator")
	end

	self._regenerate_speed = nil

	self:set_armor(self:_max_armor())
	self:_send_set_armor()

	self._current_state = nil
end

function PlayerDamage:is_regenerating_armor()
	return self._current_state == self._update_regenerate_timer
end

function PlayerDamage:_inline_RIP1()
end

function PlayerDamage:restore_health(health_restored, is_static, chk_health_ratio)
	if chk_health_ratio and managers.player:is_damage_health_ratio_active(self:health_ratio()) then
		return false
	end

	if is_static then
		return self:change_health(health_restored * self._healing_reduction)
	else
		local max_health = self:_max_health()

		return self:change_health(max_health * health_restored * self._healing_reduction)
	end
end

function PlayerDamage:restore_armor(armor_restored)
	if self._dead or self._bleed_out or self._check_berserker_done then
		return
	end

	local max_armor = self:_max_armor()
	local armor = self:get_real_armor()
	local new_armor = math.min(armor + armor_restored, max_armor)

	self:set_armor(new_armor)
	self:_send_set_armor()

	if self._unit:sound() and new_armor ~= armor and new_armor == max_armor then
		self._unit:sound():play("shield_full_indicator")
	end
end

function PlayerDamage:update_armor_stored_health()
	if managers.hud then
		local max_health = self:_max_health()

		managers.hud:set_stored_health_max(math.min(self:max_armor_stored_health() / max_health, 1))

		if self._armor_stored_health then
			self._armor_stored_health = math.min(self._armor_stored_health, self:max_armor_stored_health())
			local stored_health_ratio = self._armor_stored_health / max_health

			managers.hud:set_stored_health(stored_health_ratio)
		end
	end
end

function PlayerDamage:change_regenerate_speed(value, percent)
	if self._regenerate_speed then
		self._regenerate_speed = percent and self._regenerate_speed * value or self._regenerate_speed + value
	end
end

function PlayerDamage:max_armor_stored_health()
	if not managers.player:has_category_upgrade("player", "armor_health_store_amount") then
		return 0
	end

	local amount = managers.player:body_armor_value("skill_max_health_store", nil, 1)
	local multiplier = managers.player:upgrade_value("player", "armor_max_health_store_multiplier", 1)
	local max = amount * multiplier

	return max
end

function PlayerDamage:can_store_armor_health()
	return self:get_real_armor() > 0 and not self._dead and not self._bleed_out and not self._check_berserker_done
end

function PlayerDamage:armor_stored_health(amount)
	return self._armor_stored_health
end

function PlayerDamage:armor_ratio()
	local max_armor = self:_max_armor()

	return max_armor ~= 0 and self:get_real_armor() / max_armor or 0
end

function PlayerDamage:add_armor_stored_health(amount)
	self._armor_stored_health = math.min(self._armor_stored_health + amount, self:max_armor_stored_health())

	if managers.hud and not self._check_berserker_done then
		local stored_health_ratio = self._armor_stored_health / self:_max_health()

		managers.hud:set_stored_health(stored_health_ratio)
	end
end

function PlayerDamage:clear_armor_stored_health()
	self._armor_stored_health = 0

	if managers.hud then
		managers.hud:set_stored_health(0)
	end
end

function PlayerDamage:consume_armor_stored_health(amount)
	if self._armor_stored_health and not self._dead and not self._bleed_out and not self._check_berserker_done then
		self:change_health(self._armor_stored_health)
	end

	self:clear_armor_stored_health()
end

function PlayerDamage:_regenerated(no_messiah)
	self:set_health(self:_max_health())
	self:_send_set_health()
	self:_set_health_effect()

	self._said_hurt = false
	self._revives = Application:digest_value(self._lives_init + managers.player:upgrade_value("player", "additional_lives", 0), true)
	self._revive_health_i = 1

	managers.environment_controller:set_last_life(false)

	self._down_time = tweak_data.player.damage.DOWNED_TIME

	if not no_messiah then
		self._messiah_charges = managers.player:upgrade_value("player", "pistol_revive_from_bleed_out", 0)
	end
end

function PlayerDamage:consume_messiah_charge()
	if self:got_messiah_charges() then
		self._messiah_charges = self._messiah_charges - 1

		return true
	end

	return false
end

function PlayerDamage:got_messiah_charges()
	return self._messiah_charges and self._messiah_charges > 0
end

function PlayerDamage:get_real_health()
	return Application:digest_value(self._health, false)
end

function PlayerDamage:get_real_armor()
	return Application:digest_value(self._armor, false)
end

function PlayerDamage:_check_update_max_health()
	local max_health = self:_max_health()
	self._current_max_health = self._current_max_health or self:_max_health()

	if self._current_max_health ~= max_health then
		local ratio = max_health / self._current_max_health
		local health = math.clamp(self:get_real_health() * ratio, 0, max_health)
		self._health = Application:digest_value(health, true)
		self._current_max_health = max_health

		self:update_armor_stored_health()
	end
end

function PlayerDamage:change_health(change_of_health)
	self:_check_update_max_health()

	return self:set_health(self:get_real_health() + change_of_health)
end

function PlayerDamage:set_health(health)
	self:_check_update_max_health()

	local max_health = self:_max_health() * self._max_health_reduction
	health = math.min(health, max_health)
	local prev_health = self._health and Application:digest_value(self._health, false) or health
	self._health = Application:digest_value(math.clamp(health, 0, max_health), true)

	self:_send_set_health()
	self:_set_health_effect()

	if self._said_hurt and self:get_real_health() / self:_max_health() > 0.2 then
		self._said_hurt = false
	end

	if self:health_ratio() < 0.3 then
		self._heartbeat_start_t = TimerManager:game():time()
		self._heartbeat_t = self._heartbeat_start_t + tweak_data.vr.heartbeat_time
	end

	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})

	return prev_health ~= Application:digest_value(self._health, false)
end

function PlayerDamage:_check_update_max_armor()
	local max_armor = self:_max_armor()
	self._current_max_armor = self._current_max_armor or max_armor

	if self._current_max_armor ~= max_armor then
		local ratio = self._current_max_armor ~= 0 and max_armor / self._current_max_armor or 0
		self._current_armor_fill = self._current_armor_fill * ratio
		self._armor = Application:digest_value(math.clamp(self:get_real_armor() * ratio, 0, max_armor), true)
		self._current_max_armor = max_armor
	end
end

function PlayerDamage:change_armor(change)
	self:_check_update_max_armor()
	self:set_armor(self:get_real_armor() + change)
end

function PlayerDamage:set_armor(armor)
	self:_check_update_max_armor()

	armor = math.clamp(armor, 0, self:_max_armor())

	if self._armor then
		local current_armor = self:get_real_armor()

		if current_armor == 0 and armor ~= 0 then
			self:consume_armor_stored_health()
		elseif current_armor ~= 0 and armor == 0 and self._dire_need then
			local function clbk()
				return self:is_regenerating_armor()
			end

			managers.player:add_coroutine(PlayerAction.DireNeed, PlayerAction.DireNeed, clbk, managers.player:upgrade_value("player", "armor_depleted_stagger_shot", 0))
		end
	end

	self._armor = Application:digest_value(armor, true)
end

function PlayerDamage:down_time()
	return self._down_time
end

function PlayerDamage:health_ratio()
	return self:get_real_health() / self:_max_health()
end

function PlayerDamage:health_ratio_100()
	return math.floor(self:health_ratio() * 100)
end

function PlayerDamage:_raw_max_health()
	local base_max_health = self._HEALTH_INIT + managers.player:health_skill_addend()
	local mul = managers.player:health_skill_multiplier()
	mul = managers.modifiers:modify_value("PlayerDamage:GetMaxHealth", mul)

	return base_max_health * mul
end

function PlayerDamage:_max_health()
	local max_health = self:_raw_max_health()

	if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
		local max_armor = self:_raw_max_armor()
		local conversion_factor = managers.player:upgrade_value("player", "armor_to_health_conversion") * 0.01
		max_health = max_health + max_armor * conversion_factor
	end

	return max_health
end

function PlayerDamage:_raw_max_armor()
	local base_max_armor = self._ARMOR_INIT + managers.player:body_armor_value("armor") + managers.player:body_armor_skill_addend()
	local mul = managers.player:body_armor_skill_multiplier()
	mul = managers.modifiers:modify_value("PlayerDamage:GetMaxArmor", mul)

	return base_max_armor * mul
end

function PlayerDamage:_max_armor()
	local max_armor = self:_raw_max_armor()

	if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
		local conversion_factor = managers.player:upgrade_value("player", "armor_to_health_conversion") * 0.01
		max_armor = max_armor * (1 - conversion_factor)
	end

	return max_armor
end

function PlayerDamage:_armor_steps()
	return self._ARMOR_STEPS
end

function PlayerDamage:_armor_damage_reduction()
	return 0
end

function PlayerDamage:full_health()
	local diff = math.abs(self:get_real_health() - self:_max_health() * self._max_health_reduction)

	return diff < 0.001
end

function PlayerDamage:damage_tase(attack_data)
	if self._god_mode then
		return
	end

	local cur_state = self._unit:movement():current_state_name()

	if cur_state ~= "tased" and cur_state ~= "fatal" then
		self:on_tased(false)

		self._tase_data = attack_data

		managers.player:set_player_state("tased")

		local damage_info = {
			result = {
				variant = "tase",
				type = "hurt"
			}
		}

		self:_call_listeners(damage_info)

		if attack_data.attacker_unit and attack_data.attacker_unit:alive() and attack_data.attacker_unit:base()._tweak_table == "taser" then
			attack_data.attacker_unit:sound():say("post_tasing_taunt")

			if managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.its_alive_its_alive.mask then
				managers.achievment:award_progress(tweak_data.achievement.its_alive_its_alive.stat)
			end
		end
	end
end

function PlayerDamage:on_tased(non_lethal)
end

function PlayerDamage:tase_data()
	return self._tase_data
end

function PlayerDamage:erase_tase_data()
	self._tase_data = nil
end

local mvec1 = Vector3()

function PlayerDamage:damage_melee(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local pm = managers.player
	local can_counter_strike = pm:has_category_upgrade("player", "counter_strike_melee")

	if can_counter_strike and self._unit:movement():current_state().in_melee and self._unit:movement():current_state():in_melee() then
		self._unit:movement():current_state():discharge_melee()

		return "countered"
	end

	local blood_effect = attack_data.melee_weapon and attack_data.melee_weapon == "weapon"
	blood_effect = blood_effect or attack_data.melee_weapon and tweak_data.weapon.npc_melee[attack_data.melee_weapon] and tweak_data.weapon.npc_melee[attack_data.melee_weapon].player_blood_effect or false

	if blood_effect then
		local pos = mvec1

		mvector3.set(pos, self._unit:camera():forward())
		mvector3.multiply(pos, 20)
		mvector3.add(pos, self._unit:camera():position())

		local rot = self._unit:camera():rotation():z()

		World:effect_manager():spawn({
			effect = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"),
			position = pos,
			normal = rot
		})
	end

	local dmg_mul = pm:damage_reduction_skill_multiplier("melee")
	attack_data.damage = attack_data.damage * dmg_mul

	self._unit:sound():play("melee_hit_body", nil, nil)

	local result = self:damage_bullet(attack_data)
	local vars = {
		"melee_hit",
		"melee_hit_var2"
	}

	self._unit:camera():play_shaker(vars[math.random(#vars)], 1)

	if pm:current_state() == "bipod" then
		self._unit:movement()._current_state:exit(nil, "standard")
		pm:set_player_state("standard")
	end

	self._unit:movement():push(attack_data.push_vel)

	return result
end

function PlayerDamage:is_friendly_fire(unit)
	if not unit then
		return false
	end

	if unit:movement():team() ~= self._unit:movement():team() and unit:movement():friendly_fire() then
		return false
	end

	local friendly_fire = not unit:movement():team().foes[self._unit:movement():team().id]
	friendly_fire = managers.mutators:modify_value("PlayerDamage:FriendlyFire", friendly_fire)

	return friendly_fire
end

function PlayerDamage:play_whizby(position)
	self._unit:sound():play_whizby({
		position = position
	})
	self._unit:camera():play_shaker("whizby", 0.1)

	if not _G.IS_VR then
		managers.rumble:play("bullet_whizby")
	end
end

function PlayerDamage:clbk_kill_taunt(attack_data)
	if attack_data.attacker_unit and attack_data.attacker_unit:alive() then
		self._kill_taunt_clbk_id = nil

		attack_data.attacker_unit:sound():say("post_kill_taunt")
	end
end

function PlayerDamage:add_temporary_dodge(amount, time)
	local t = TimerManager:game():time()

	if self._temporary_dodge_t and t < self._temporary_dodge_t and self._temporary_dodge and amount < self._temporary_dodge then
		return
	end

	self._temporary_dodge = amount
	self._temporary_dodge_t = t + time
end

function PlayerDamage:damage_bullet(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local damage_info = {
		result = {
			variant = "bullet",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}
	local pm = managers.player
	local dmg_mul = pm:damage_reduction_skill_multiplier("bullet")
	attack_data.damage = attack_data.damage * dmg_mul
	attack_data.damage = managers.mutators:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage)
	attack_data.damage = managers.modifiers:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage, attack_data.attacker_unit:base()._tweak_table)

	if _G.IS_VR then
		local distance = mvector3.distance(self._unit:position(), attack_data.attacker_unit:position())

		if tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
			local step = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2], 0, 1)
			local mul = 1 - math.step(tweak_data.vr.long_range_damage_reduction[1], tweak_data.vr.long_range_damage_reduction[2], step)
			attack_data.damage = attack_data.damage * mul
		end
	end

	local damage_absorption = pm:damage_absorption()

	if damage_absorption > 0 then
		attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
	end

	if self._god_mode then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, attack_data.damage)
		end

		self:_call_listeners(damage_info)

		return
	elseif self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self._revive_miss and math.random() < self._revive_miss then
		self:play_whizby(attack_data.col_ray.position)

		return
	end

	self._last_received_dmg = attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
	local dodge_roll = math.random()
	local dodge_value = tweak_data.player.damage.DODGE_INIT or 0
	local armor_dodge_chance = pm:body_armor_value("dodge")
	local skill_dodge_chance = pm:skill_dodge_chance(self._unit:movement():running(), self._unit:movement():crouching(), self._unit:movement():zipline_unit())
	dodge_value = dodge_value + armor_dodge_chance + skill_dodge_chance

	if self._temporary_dodge_t and TimerManager:game():time() < self._temporary_dodge_t then
		dodge_value = dodge_value + self._temporary_dodge
	end

	local smoke_dodge = 0

	for _, smoke_screen in ipairs(managers.player._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(self._unit) then
			smoke_dodge = tweak_data.projectiles.smoke_screen_grenade.dodge_chance

			break
		end
	end

	dodge_value = 1 - (1 - dodge_value) * (1 - smoke_dodge)

	if dodge_roll < dodge_value then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, 0)
		end

		self:_call_listeners(damage_info)
		self:play_whizby(attack_data.col_ray.position)
		self:_hit_direction(attack_data.attacker_unit:position())

		self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
		self._last_received_dmg = attack_data.damage

		managers.player:send_message(Message.OnPlayerDodge)

		return
	end

	if attack_data.attacker_unit:base()._tweak_table == "tank" then
		managers.achievment:set_script_data("dodge_this_fail", true)
	end

	if self:get_real_armor() > 0 then
		self._unit:sound():play("player_hit")
	else
		self._unit:sound():play("player_hit_permadamage")
	end

	local shake_armor_multiplier = pm:body_armor_value("damage_shake") * pm:upgrade_value("player", "damage_shake_multiplier", 1)
	local gui_shake_number = tweak_data.gui.armor_damage_shake_base / shake_armor_multiplier
	gui_shake_number = gui_shake_number + pm:upgrade_value("player", "damage_shake_addend", 0)
	shake_armor_multiplier = tweak_data.gui.armor_damage_shake_base / gui_shake_number
	local shake_multiplier = math.clamp(attack_data.damage, 0.2, 2) * shake_armor_multiplier

	self._unit:camera():play_shaker("player_bullet_damage", 1 * shake_multiplier)

	if not _G.IS_VR then
		managers.rumble:play("damage_bullet")
	end

	self:_hit_direction(attack_data.attacker_unit:position())
	pm:check_damage_carry(attack_data)

	attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data)

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)

		return
	end

	if not attack_data.ignore_suppression and not self:is_suppressed() then
		return
	end

	self:_check_chico_heal(attack_data)

	local armor_reduction_multiplier = 0

	if self:get_real_armor() <= 0 then
		armor_reduction_multiplier = 1
	end

	local health_subtracted = self:_calc_armor_damage(attack_data)

	if attack_data.armor_piercing then
		attack_data.damage = attack_data.damage - health_subtracted
	else
		attack_data.damage = attack_data.damage * armor_reduction_multiplier
	end

	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	if not self._bleed_out and health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	elseif self._bleed_out and attack_data.attacker_unit and attack_data.attacker_unit:alive() and attack_data.attacker_unit:base()._tweak_table == "tank" then
		self._kill_taunt_clbk_id = "kill_taunt" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._kill_taunt_clbk_id, callback(self, self, "clbk_kill_taunt", attack_data), TimerManager:game():time() + tweak_data.timespeed.downed.fade_in + tweak_data.timespeed.downed.sustain + tweak_data.timespeed.downed.fade_out)
	end

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end

function PlayerDamage:_calc_armor_damage(attack_data)
	local health_subtracted = 0

	if self:get_real_armor() > 0 then
		health_subtracted = self:get_real_armor()

		self:change_armor(-attack_data.damage)

		health_subtracted = health_subtracted - self:get_real_armor()

		self:_damage_screen()
		SoundDevice:set_rtpc("shield_status", self:armor_ratio() * 100)
		self:_send_set_armor()

		if self:get_real_armor() <= 0 then
			self._unit:sound():play("player_armor_gone_stinger")

			if attack_data.armor_piercing then
				self._unit:sound():play("player_sniper_hit_armor_gone")
			end

			local pm = managers.player

			self:_start_regen_on_the_side(pm:upgrade_value("player", "passive_always_regen_armor", 0))

			if pm:has_inactivate_temporary_upgrade("temporary", "armor_break_invulnerable") then
				pm:activate_temporary_upgrade("temporary", "armor_break_invulnerable")

				self._can_take_dmg_timer = pm:temporary_upgrade_value("temporary", "armor_break_invulnerable", 0)
			end
		end
	end

	managers.hud:damage_taken()

	return health_subtracted
end

function PlayerDamage:_chk_cheat_death()
	if Application:digest_value(self._revives, false) > 1 and not self._check_berserker_done and managers.player:has_category_upgrade("player", "cheat_death_chance") then
		local r = math.rand(1)

		if r <= managers.player:upgrade_value("player", "cheat_death_chance", 0) then
			self._auto_revive_timer = 1
		end
	end
end

function PlayerDamage:_calc_health_damage(attack_data)
	local health_subtracted = 0
	health_subtracted = self:get_real_health()

	self:change_health(-attack_data.damage)

	health_subtracted = health_subtracted - self:get_real_health()
	local trigger_skills = table.contains({
		"bullet",
		"explosion",
		"melee",
		"delayed_tick"
	}, attack_data.variant)

	if self:get_real_health() == 0 and trigger_skills then
		self:_chk_cheat_death()
	end

	self:_damage_screen()
	self:_check_bleed_out(trigger_skills)
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.statistics:health_subtracted(health_subtracted)

	return health_subtracted
end

function PlayerDamage:_check_chico_heal(attack_data)
	if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") then
		local dmg_to_hp_ratio = managers.player:temporary_upgrade_value("temporary", "chico_injector", 0)

		if managers.player:has_category_upgrade("player", "chico_injector_low_health_multiplier") then
			local upg_values = managers.player:upgrade_value("player", "chico_injector_low_health_multiplier")

			if self:health_ratio() < upg_values[1] then
				dmg_to_hp_ratio = dmg_to_hp_ratio + upg_values[2]
			end
		end

		local health_received = attack_data.damage * dmg_to_hp_ratio

		if managers.player:has_category_upgrade("player", "chico_injector_health_to_speed") and self:_max_health() < self:get_real_health() + health_received then
			self._injector_overflow = self._injector_overflow or 0
			local diff = self:_max_health() - self:get_real_health()

			self:restore_health(diff, true)

			health_received = health_received - diff
			self._injector_overflow = self._injector_overflow + health_received
			local upg_values = managers.player:upgrade_value("player", "chico_injector_health_to_speed")
			local times = math.floor(self._injector_overflow / upg_values[1])

			managers.player:speed_up_grenade_cooldown(upg_values[2] * times)

			self._injector_overflow = self._injector_overflow - upg_values[1] * times
		else
			self:restore_health(health_received, true)
		end
	end
end

function PlayerDamage:_send_damage_drama(attack_data, health_subtracted)
	local dmg_percent = health_subtracted / self._HEALTH_INIT
	local attacker = nil

	if not attacker or attack_data.attacker_unit:id() == -1 then
		attacker = self._unit
	end

	self._unit:network():send("criminal_hurt", attacker, math.clamp(math.ceil(dmg_percent * 100), 1, 100))

	if Network:is_server() then
		attacker = attack_data.attacker_unit

		if attacker and not attack_data.attacker_unit:movement() then
			attacker = nil
		end

		managers.groupai:state():criminal_hurt_drama(self._unit, attacker, dmg_percent)
	end

	if Network:is_client() then
		self._unit:network():send_to_host("damage_bullet", attacker, 1, 1, 1, 0, false)
	end
end

function PlayerDamage:damage_killzone(attack_data)
	local damage_info = {
		result = {
			variant = "killzone",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	end

	self._unit:sound():play("player_hit")

	if attack_data.instant_death then
		self:set_armor(0)
		self:set_health(0)
		self:_send_set_armor()
		self:_send_set_health()
		managers.hud:set_player_health({
			current = self:get_real_health(),
			total = self:_max_health(),
			revives = Application:digest_value(self._revives, false)
		})
		self:_set_health_effect()
		self:_damage_screen()
		self:_check_bleed_out(nil)
	else
		self:_hit_direction(attack_data.col_ray.origin)

		if self._bleed_out then
			return
		end

		attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data)

		self:_check_chico_heal(attack_data)

		local armor_reduction_multiplier = 0

		if self:get_real_armor() <= 0 then
			armor_reduction_multiplier = 1
		end

		local health_subtracted = self:_calc_armor_damage(attack_data)
		attack_data.damage = attack_data.damage * armor_reduction_multiplier
		health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)
	end

	self:_call_listeners(damage_info)
end

function PlayerDamage:damage_fall(data)
	local damage_info = {
		result = {
			variant = "fall",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self._mission_damage_blockers.damage_fall_disabled then
		return
	end

	local height_limit = 300
	local death_limit = 631

	if data.height < height_limit then
		return
	end

	local die = death_limit < data.height

	self._unit:sound():play("player_hit")
	managers.environment_controller:hit_feedback_down()
	managers.hud:on_hit_direction(Vector3(0, 0, 0), die and HUDHitDirection.DAMAGE_TYPES.HEALTH or HUDHitDirection.DAMAGE_TYPES.ARMOUR, 0)

	if self._bleed_out and self._unit:movement():current_state_name() ~= "jerry1" then
		return
	end

	local health_damage_multiplier = 0

	if die then
		self._check_berserker_done = false

		self:set_health(0)

		if self._unit:movement():current_state_name() == "jerry1" then
			self._revives = Application:digest_value(1, true)
		end
	else
		health_damage_multiplier = managers.player:upgrade_value("player", "fall_damage_multiplier", 1) * managers.player:upgrade_value("player", "fall_health_damage_multiplier", 1)

		self:change_health(-(tweak_data.player.fall_health_damage * health_damage_multiplier))
	end

	if die or health_damage_multiplier > 0 then
		local alert_rad = tweak_data.player.fall_damage_alert_size or 500
		local new_alert = {
			"vo_cbt",
			self._unit:movement():m_head_pos(),
			alert_rad,
			self._unit:movement():SO_access(),
			self._unit
		}

		managers.groupai:state():propagate_alert(new_alert)
	end

	local max_armor = self:_max_armor()

	if die then
		self:set_armor(0)
	else
		self:change_armor(-max_armor * managers.player:upgrade_value("player", "fall_damage_multiplier", 1))
	end

	SoundDevice:set_rtpc("shield_status", 0)
	self:_send_set_armor()

	self._bleed_out_blocked_by_movement_state = nil

	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	self:_damage_screen()
	self:_check_bleed_out(nil, true)
	self:_call_listeners(damage_info)

	return true
end

function PlayerDamage:damage_explosion(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local damage_info = {
		result = {
			variant = "explosion",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self:incapacitated() then
		return
	end

	local distance = mvector3.distance(attack_data.position, self._unit:position())

	if attack_data.range < distance then
		return
	end

	local damage = (attack_data.damage or 1) * (1 - distance / attack_data.range)

	if self._bleed_out then
		return
	end

	local dmg_mul = managers.player:damage_reduction_skill_multiplier("explosion")
	attack_data.damage = damage * dmg_mul
	attack_data.damage = managers.modifiers:modify_value("PlayerDamage:OnTakeExplosionDamage", attack_data.damage)
	attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data)

	self:_check_chico_heal(attack_data)

	local armor_subtracted = self:_calc_armor_damage(attack_data)
	attack_data.damage = attack_data.damage - (armor_subtracted or 0)
	local health_subtracted = self:_calc_health_damage(attack_data)

	managers.player:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end

function PlayerDamage:damage_fire(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local damage_info = {
		result = {
			variant = "fire",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self:incapacitated() then
		return
	end

	local distance = mvector3.distance(attack_data.position or attack_data.col_ray.position, self._unit:position())

	if attack_data.range < distance then
		return
	end

	local damage = attack_data.damage or 1

	if self:get_real_armor() > 0 then
		self._unit:sound():play("player_hit")
	else
		self._unit:sound():play("player_hit_permadamage")
	end

	if self._bleed_out then
		return
	end

	local dmg_mul = managers.player:damage_reduction_skill_multiplier("fire")
	attack_data.damage = damage * dmg_mul
	attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data)

	self:_check_chico_heal(attack_data)

	local armor_subtracted = self:_calc_armor_damage(attack_data)
	attack_data.damage = attack_data.damage - (armor_subtracted or 0)
	local health_subtracted = self:_calc_health_damage(attack_data)

	self:_call_listeners(damage_info)
end

function PlayerDamage:damage_simple(attack_data)
	local damage_info = {
		result = {
			type = "hurt",
			variant = attack_data.variant
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	end

	self._unit:sound():play("player_hit")

	attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data)

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)

		return
	end

	self:_check_chico_heal(attack_data)

	local armor_reduction_multiplier = 0

	if self:get_real_armor() <= 0 then
		armor_reduction_multiplier = 1
	end

	local health_subtracted = self:_calc_armor_damage(attack_data)
	attack_data.damage = attack_data.damage * armor_reduction_multiplier
	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	self:_call_listeners(damage_info)
end

function PlayerDamage:update_downed(t, dt)
	if self._downed_timer and self._downed_paused_counter == 0 then
		self._downed_timer = self._downed_timer - dt

		if self._downed_start_time == 0 then
			self._downed_progression = 100
		else
			self._downed_progression = math.clamp(1 - self._downed_timer / self._downed_start_time, 0, 1) * 100
		end

		if not _G.IS_VR then
			managers.environment_controller:set_downed_value(self._downed_progression)
		end

		SoundDevice:set_rtpc("downed_state_progression", self._downed_progression)

		return self._downed_timer <= 0
	end

	return false
end

function PlayerDamage:is_berserker()
	return not not self._check_berserker_done
end

function PlayerDamage:_check_bleed_out(can_activate_berserker, ignore_movement_state)
	if self:get_real_health() == 0 and not self._check_berserker_done then
		if self._unit:movement():zipline_unit() then
			self._bleed_out_blocked_by_zipline = true

			return
		end

		if not ignore_movement_state and self._unit:movement():current_state():bleed_out_blocked() then
			self._bleed_out_blocked_by_movement_state = true

			return
		end

		local time = Application:time()

		if not self._block_medkit_auto_revive and time > self._uppers_elapsed + self._UPPERS_COOLDOWN then
			local auto_recovery_kit = FirstAidKitBase.GetFirstAidKit(self._unit:position())

			if auto_recovery_kit then
				auto_recovery_kit:take(self._unit)
				self._unit:sound():play("pickup_fak_skill")

				self._uppers_elapsed = time

				return
			end
		end

		if can_activate_berserker and not self._check_berserker_done then
			local has_berserker_skill = managers.player:has_category_upgrade("temporary", "berserker_damage_multiplier")

			if has_berserker_skill and not self._disable_next_swansong then
				managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_swansong", managers.localization:text("debug_mugshot_downed"))
				managers.player:activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

				self._current_state = nil
				self._check_berserker_done = true

				if alive(self._interaction:active_unit()) and not self._interaction:active_unit():interaction():can_interact(self._unit) then
					self._unit:movement():interupt_interact()
				end

				self._listener_holder:call("on_enter_swansong")
			end

			self._disable_next_swansong = nil
		end

		self._hurt_value = 0.2
		self._damage_to_hot_stack = {}

		managers.environment_controller:set_downed_value(0)
		SoundDevice:set_rtpc("downed_state_progression", 0)

		if not self._check_berserker_done or not can_activate_berserker then
			self._revives = Application:digest_value(Application:digest_value(self._revives, false) - 1, true)
			self._check_berserker_done = nil

			managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)

			if Application:digest_value(self._revives, false) == 0 then
				self._down_time = 0
			end

			self._bleed_out = true
			self._current_state = nil

			managers.player:set_player_state("bleed_out")

			self._critical_state_heart_loop_instance = self._unit:sound():play("critical_state_heart_loop")
			self._slomo_sound_instance = self._unit:sound():play("downed_slomo_fx")
			self._bleed_out_health = Application:digest_value(tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * managers.player:upgrade_value("player", "bleed_out_health_multiplier", 1), true)

			self:_drop_blood_sample()
			self:on_downed()
		end
	elseif not self._said_hurt and self:get_real_health() / self:_max_health() < 0.2 then
		self._said_hurt = true

		PlayerStandard.say_line(self, "g80x_plu")
	end
end

function PlayerDamage:_drop_blood_sample()
	local remove = math.rand(1) < 0.5

	if not remove then
		return
	end

	local removed = false

	if managers.player:has_special_equipment("blood_sample") then
		removed = true

		managers.player:remove_special("blood_sample")
		managers.hint:show_hint("dropped_blood_sample")
	end

	if managers.player:has_special_equipment("blood_sample_verified") then
		removed = true

		managers.player:remove_special("blood_sample_verified")
		managers.hint:show_hint("dropped_blood_sample")
	end

	if removed then
		self._unit:sound():play("vial_break_2d")
		self._unit:sound():say("g29", false)

		if managers.groupai:state():bain_state() then
			local params = {}

			if not self._blood_sample_reminder_given then
				function params.done_cbk()
					managers.dialog:queue_dialog("Play_pln_nmh_73", {
						delay = 3
					})
				end

				self._blood_sample_reminder_given = true
			end

			managers.dialog:queue_dialog("Play_pln_nmh_72", params)
		end

		local splatter_from = self._unit:position() + math.UP * 5
		local splatter_to = self._unit:position() - math.UP * 45
		local splatter_ray = World:raycast("ray", splatter_from, splatter_to, "slot_mask", managers.game_play_central._slotmask_world_geometry)

		if splatter_ray then
			World:project_decal(Idstring("blood_spatter"), splatter_ray.position, splatter_ray.ray, splatter_ray.unit, nil, splatter_ray.normal)
		end
	end
end

function PlayerDamage:disable_berserker()
	managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_normal", "")
	managers.hud:set_player_custom_radial({
		current = 0,
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})

	self._check_berserker_done = false

	managers.player:deactivate_temporary_upgrade("temporary", "berserker_damage_multiplier")
	managers.network:session():send_to_peers("sync_swansong_timer", self._unit, 0, self:_max_health(), Application:digest_value(self._revives, false), managers.network:session():local_peer():id())
end

function PlayerDamage:on_downed()
	self._current_state = nil
	self._downed_timer = self:down_time()
	self._downed_start_time = self._downed_timer
	self._downed_paused_counter = 0
	self._damage_to_hot_stack = {}

	self:disable_berserker()
	managers.hud:pd_start_timer({
		time = self._downed_timer
	})
	managers.hud:on_downed()
	self:_stop_tinnitus()
	self:_stop_concussion()
	self:clear_armor_stored_health()
	self:clear_delayed_damage()
	self._listener_holder:call("on_enter_bleedout")
end

function PlayerDamage:get_paused_counter_name_by_peer(peer_id)
	return self._paused_counter_name_by_peer_map and self._paused_counter_name_by_peer_map[peer_id]
end

function PlayerDamage:set_peer_paused_counter(peer_id, counter_name)
	if peer_id then
		self._paused_counter_name_by_peer_map = self._paused_counter_name_by_peer_map or {}
		self._paused_counter_name_by_peer_map[peer_id] = counter_name

		if not next(self._paused_counter_name_by_peer_map) then
			self._paused_counter_name_by_peer_map = nil
		end
	end
end

function PlayerDamage:pause_downed_timer(timer, peer_id)
	self._downed_paused_counter = self._downed_paused_counter + 1

	self:set_peer_paused_counter(peer_id, "downed")

	if self._downed_paused_counter == 1 then
		managers.hud:pd_pause_timer()
		managers.hud:pd_start_progress(0, timer or tweak_data.interaction.revive.timer, "debug_interact_being_revived", "interaction_help")
	end

	if Network:is_server() then
		managers.network:session():send_to_peers("pause_downed_timer", self._unit)
	end
end

function PlayerDamage:unpause_downed_timer(peer_id)
	self._downed_paused_counter = self._downed_paused_counter - 1

	self:set_peer_paused_counter(peer_id, nil)

	if self._downed_paused_counter == 0 then
		managers.hud:pd_unpause_timer()
		managers.hud:pd_stop_progress()
	end

	if Network:is_server() then
		managers.network:session():send_to_peers("unpause_downed_timer", self._unit)
	end
end

function PlayerDamage:update_arrested(t, dt)
	if self._arrested_timer and self._arrested_paused_counter == 0 then
		self._arrested_timer = self._arrested_timer - dt

		return not self:arrested()
	end

	return false
end

function PlayerDamage:on_freed()
	self._arrested_timer = nil
	self._arrested = nil
end

function PlayerDamage:on_arrested()
	self._bleed_out = false
	self._arrested_timer = tweak_data.player.damage.ARRESTED_TIME
	self._arrested_paused_counter = 0

	managers.hud:pd_start_timer({
		time = self._arrested_timer
	})
	managers.hud:on_arrested()
end

function PlayerDamage:pause_arrested_timer(peer_id)
	if not self._arrested_timer or self._arrested_timer <= 0 then
		return
	end

	self._arrested_paused_counter = self._arrested_paused_counter + 1

	self:set_peer_paused_counter(peer_id, "arrested")

	if self._arrested_paused_counter == 1 then
		managers.hud:pd_pause_timer()
		managers.hud:pd_start_progress(0, tweak_data.interaction.free.timer, "debug_interact_being_freed", "interaction_free")
	end
end

function PlayerDamage:unpause_arrested_timer(peer_id)
	if not self._arrested_timer or self._arrested_timer <= 0 then
		return
	end

	self._arrested_paused_counter = self._arrested_paused_counter - 1

	self:set_peer_paused_counter(peer_id, nil)

	if self._arrested_paused_counter == 0 then
		managers.hud:pd_unpause_timer()
		managers.hud:pd_stop_progress()
	end
end

function PlayerDamage:update_incapacitated(t, dt)
	return self:update_downed(t, dt)
end

function PlayerDamage:on_incapacitated()
	self:on_downed()

	self._incapacitated = true
end

function PlayerDamage:bleed_out()
	return self._bleed_out
end

function PlayerDamage:incapacitated()
	return self._incapacitated
end

function PlayerDamage:arrested()
	return self._arrested_timer or self._arrested
end

function PlayerDamage:_bleed_out_damage(attack_data)
	local health_subtracted = Application:digest_value(self._bleed_out_health, false)
	self._bleed_out_health = Application:digest_value(math.max(0, health_subtracted - attack_data.damage), true)
	health_subtracted = health_subtracted - Application:digest_value(self._bleed_out_health, false)
	self._next_allowed_dmg_t = Application:digest_value(managers.player:player_timer():time() + self._dmg_interval, true)
	self._last_received_dmg = health_subtracted

	if Application:digest_value(self._bleed_out_health, false) <= 0 then
		managers.player:set_player_state("fatal")
	end

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	end
end

function PlayerDamage:_hit_direction(position_vector)
	if position_vector then
		managers.hud:on_hit_direction(position_vector, self:get_real_armor() > 0 and HUDHitDirection.DAMAGE_TYPES.ARMOUR or HUDHitDirection.DAMAGE_TYPES.HEALTH)
	end
end

function PlayerDamage:_damage_screen()
	local armor_ratio = self:armor_ratio()
	self._hurt_value = 1 - math.clamp(0.8 - math.pow(armor_ratio, 2), 0, 1)
	self._armor_value = math.clamp(armor_ratio, 0, 1)

	managers.environment_controller:set_hurt_value(self._hurt_value)
	self._listener_holder:call("on_damage")
end

function PlayerDamage:set_revive_boost(revive_health_level)
	self._revive_health_multiplier = tweak_data.upgrades.revive_health_multiplier[revive_health_level]

	print("PlayerDamage:set_revive_boost", "revive_health_level", revive_health_level, "revive_health_multiplier", tostring(self._revive_health_multiplier))
end

function PlayerDamage:revive(silent)
	if Application:digest_value(self._revives, false) == 0 then
		self._revive_health_multiplier = nil

		return
	end

	local arrested = self:arrested()

	managers.player:set_player_state("standard")

	if not silent then
		PlayerStandard.say_line(self, "s05x_sin")
	end

	self._bleed_out = false
	self._incapacitated = nil
	self._downed_timer = nil
	self._downed_start_time = nil

	if not arrested then
		self:set_health(self:_max_health() * tweak_data.player.damage.REVIVE_HEALTH_STEPS[self._revive_health_i] * (self._revive_health_multiplier or 1) * managers.player:upgrade_value("player", "revived_health_regain", 1))
		self:set_armor(self:_max_armor())

		self._revive_health_i = math.min(#tweak_data.player.damage.REVIVE_HEALTH_STEPS, self._revive_health_i + 1)
		self._revive_miss = 2
	end

	self:_regenerate_armor()
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.hud:pd_stop_progress()

	self._revive_health_multiplier = nil

	self._listener_holder:call("on_revive")

	if managers.player:has_inactivate_temporary_upgrade("temporary", "revived_damage_resist") then
		managers.player:activate_temporary_upgrade("temporary", "revived_damage_resist")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "increased_movement_speed") then
		managers.player:activate_temporary_upgrade("temporary", "increased_movement_speed")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "swap_weapon_faster") then
		managers.player:activate_temporary_upgrade("temporary", "swap_weapon_faster")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "reload_weapon_faster") then
		managers.player:activate_temporary_upgrade("temporary", "reload_weapon_faster")
	end
end

function PlayerDamage:need_revive()
	return self._bleed_out or self._incapacitated
end

function PlayerDamage:is_downed()
	return self._bleed_out or self._incapacitated
end

function PlayerDamage:dead()
	return false
end

function PlayerDamage:set_mission_damage_blockers(type, state)
	self._mission_damage_blockers[type] = state
end

function PlayerDamage:get_mission_blocker(type)
	return self._mission_damage_blockers[type]
end

function PlayerDamage:set_god_mode(state)
	Global.god_mode = state
	self._god_mode = state

	self:print("PlayerDamage god mode " .. (state and "ON" or "OFF"))
end

function PlayerDamage:god_mode()
	return self._god_mode
end

function PlayerDamage:print(...)
	cat_print("player_damage", ...)
end

function PlayerDamage:set_invulnerable(state)
	self._invulnerable = state
end

function PlayerDamage:set_danger_level(danger_level)
	self._danger_level = self._danger_level ~= danger_level and danger_level or nil
	self._focus_delay_mul = danger_level and tweak_data.danger_zones[self._danger_level] or 1
end

function PlayerDamage:focus_delay_mul()
	return self._focus_delay_mul
end

function PlayerDamage:shoot_pos_mid(m_pos)
	mvector3.set(m_pos, self._unit:movement():m_head_pos())
end

function PlayerDamage:got_max_doh_stacks()
	return self._doh_data.max_stacks and #self._damage_to_hot_stack >= (tonumber(self._doh_data.max_stacks) or 1)
end

function PlayerDamage:add_damage_to_hot()
	if self:got_max_doh_stacks() then
		return
	end

	if self:need_revive() or self:dead() or self._check_berserker_done then
		return
	end

	table.insert(self._damage_to_hot_stack, {
		next_tick = TimerManager:game():time() + (self._doh_data.tick_time or 1),
		ticks_left = (self._doh_data.total_ticks or 1) + managers.player:upgrade_value("player", "damage_to_hot_extra_ticks", 0)
	})
	table.sort(self._damage_to_hot_stack, function (x, y)
		return x.next_tick < y.next_tick
	end)
end

function PlayerDamage:set_regenerate_timer_to_max()
	local mul = managers.player:body_armor_regen_multiplier(alive(self._unit) and self._unit:movement():current_state()._moving, self:health_ratio())
	self._regenerate_timer = tweak_data.player.damage.REGENERATE_TIME * mul
	self._regenerate_timer = self._regenerate_timer * managers.player:upgrade_value("player", "armor_regen_time_mul", 1)
	self._regenerate_speed = self._regenerate_speed or 1
	self._current_state = self._update_regenerate_timer
end

function PlayerDamage:_send_set_health()
	if self._unit:network() then
		local hp = math.round(self:get_real_health() / self:_max_health() * 100)
		local max_mul = math.min(self:_max_health() / 100, 1)

		self._unit:network():send("set_health", math.clamp(hp, 0, 100), max_mul)

		if self:get_real_health() - self:_max_health() > 0.001 then
			managers.mission:call_global_event("player_damaged")
		end
	end
end

function PlayerDamage:_set_health_effect()
	local hp = self:get_real_health() / self:_max_health()

	math.clamp(hp, 0, 1)
	managers.environment_controller:set_health_effect_value(hp)
end

function PlayerDamage:_send_set_armor()
	if self._unit:network() then
		local armor = math.round(self:armor_ratio() * 100)
		local max_mul = math.min(self:_max_armor() / 100, 1)

		self._unit:network():send("set_armor", math.clamp(armor, 0, 100), max_mul)
	end
end

function PlayerDamage:stop_heartbeat()
	if self._critical_state_heart_loop_instance then
		self._critical_state_heart_loop_instance:stop()

		self._critical_state_heart_loop_instance = nil
	end

	if self._slomo_sound_instance then
		self._slomo_sound_instance:stop()

		self._slomo_sound_instance = nil
	end

	managers.environment_controller:set_downed_value(0)
	SoundDevice:set_rtpc("downed_state_progression", 0)
	SoundDevice:set_rtpc("stamina", 100)
end

function PlayerDamage:pre_destroy()
	if alive(self._gui) and alive(self._ws) then
		self._gui:destroy_workspace(self._ws)
	end

	if self._critical_state_heart_loop_instance then
		self._critical_state_heart_loop_instance:stop()
	end

	if self._slomo_sound_instance then
		self._slomo_sound_instance:stop()

		self._slomo_sound_instance = nil
	end

	managers.player:unregister_message(Message.RevivePlayer, self)
	managers.environment_controller:set_last_life(false)
	managers.environment_controller:set_downed_value(0)
	SoundDevice:set_rtpc("downed_state_progression", 0)
	SoundDevice:set_rtpc("shield_status", 100)
	managers.environment_controller:set_hurt_value(1)
	managers.environment_controller:set_health_effect_value(1)
	managers.environment_controller:set_suppression_value(0)
	managers.sequence:remove_inflict_updator_body("fire", self._unit:key(), self._inflict_damage_body:key())
	CopDamage.unregister_listener("on_damage")
	managers.mission:remove_global_event_listener("player_regenerate_armor")
	managers.mission:remove_global_event_listener("player_force_bleedout")
	self._unit:sound():play("concussion_effect_off")
end

function PlayerDamage:_call_listeners(damage_info)
	CopDamage._call_listeners(self, damage_info)
end

function PlayerDamage:add_listener(...)
	CopDamage.add_listener(self, ...)
end

function PlayerDamage:remove_listener(key)
	CopDamage.remove_listener(self, key)
end

function PlayerDamage:on_fatal_state_enter()
	local dmg_info = {
		result = {
			type = "death"
		}
	}

	self:_call_listeners(dmg_info)
end

function PlayerDamage:on_incapacitated_state_enter()
	local dmg_info = {
		result = {
			type = "death"
		}
	}

	self:_call_listeners(dmg_info)
end

function PlayerDamage:_chk_dmg_too_soon(damage)
	local next_allowed_dmg_t = type(self._next_allowed_dmg_t) == "number" and self._next_allowed_dmg_t or Application:digest_value(self._next_allowed_dmg_t, false)

	if damage <= self._last_received_dmg + 0.01 and managers.player:player_timer():time() < next_allowed_dmg_t then
		return true
	end
end

function PlayerDamage:_chk_suppression_too_soon(amount)
	if amount <= self._last_received_sup and managers.player:player_timer():time() < self._next_allowed_sup_t then
		return true
	end
end

function PlayerDamage.clbk_msg_overwrite_criminal_hurt(overwrite_data, msg_queue, msg_name, crim_unit, attacker_unit, dmg)
	if msg_queue then
		local crim_key = crim_unit:key()
		local attacker_key = attacker_unit:key()

		if overwrite_data.indexes[crim_key] and overwrite_data.indexes[crim_key][attacker_key] then
			local index = overwrite_data.indexes[crim_key][attacker_key]
			local old_msg = msg_queue[index]
			old_msg[4] = math.clamp(dmg + old_msg[4], 1, 100)
		else
			table.insert(msg_queue, {
				msg_name,
				crim_unit,
				attacker_unit,
				dmg
			})

			overwrite_data.indexes[crim_key] = {
				[attacker_key] = #msg_queue
			}
		end
	else
		overwrite_data.indexes = {}
	end
end

function PlayerDamage:build_suppression(amount)
	if self:_chk_suppression_too_soon(amount) then
		return
	end

	local data = self._supperssion_data
	amount = amount * managers.player:upgrade_value("player", "suppressed_multiplier", 1)
	local morale_boost_bonus = self._unit:movement():morale_boost()

	if morale_boost_bonus then
		amount = amount * morale_boost_bonus.suppression_resistance
	end

	amount = amount * tweak_data.player.suppression.receive_mul
	data.value = math.min(tweak_data.player.suppression.max_value, (data.value or 0) + amount * tweak_data.player.suppression.receive_mul)
	self._last_received_sup = amount
	self._next_allowed_sup_t = managers.player:player_timer():time() + self._dmg_interval
	data.decay_start_t = managers.player:player_timer():time() + tweak_data.player.suppression.decay_start_delay
end

function PlayerDamage:_upd_suppression(t, dt)
	local data = self._supperssion_data

	if data.value then
		if data.decay_start_t < t then
			data.value = data.value - dt

			if data.value <= 0 then
				data.value = nil
				data.decay_start_t = nil

				managers.environment_controller:set_suppression_value(0, 0)
			end
		elseif data.value == tweak_data.player.suppression.max_value and self._regenerate_timer then
			self._listener_holder:call("suppression_max")
		end

		if data.value then
			managers.environment_controller:set_suppression_value(self:effective_suppression_ratio(), self:suppression_ratio())
		end
	end
end

function PlayerDamage:_upd_health_regen(t, dt)
	if self._health_regen_update_timer then
		self._health_regen_update_timer = self._health_regen_update_timer - dt

		if self._health_regen_update_timer <= 0 then
			self._health_regen_update_timer = nil
		end
	end

	if not self._health_regen_update_timer then
		local max_health = self:_max_health()

		if self:get_real_health() < max_health then
			self:restore_health(managers.player:health_regen(), false)
			self:restore_health(managers.player:fixed_health_regen(self:health_ratio()), true)

			self._health_regen_update_timer = 5
		end
	end

	if #self._damage_to_hot_stack > 0 then
		repeat
			local next_doh = self._damage_to_hot_stack[1]
			local done = not next_doh or TimerManager:game():time() < next_doh.next_tick

			if not done then
				local regen_rate = managers.player:upgrade_value("player", "damage_to_hot", 0)

				self:restore_health(regen_rate, true)

				next_doh.ticks_left = next_doh.ticks_left - 1

				if next_doh.ticks_left == 0 then
					table.remove(self._damage_to_hot_stack, 1)
				else
					next_doh.next_tick = next_doh.next_tick + (self._doh_data.tick_time or 1)
				end

				table.sort(self._damage_to_hot_stack, function (x, y)
					return x.next_tick < y.next_tick
				end)
			end
		until done
	end
end

function PlayerDamage:melee_hit_sfx()
	return "hit_body"
end

function PlayerDamage:suppression_ratio()
	return (self._supperssion_data.value or 0) / tweak_data.player.suppression.max_value
end

function PlayerDamage:effective_suppression_ratio()
	local effective_ratio = math.max(0, (self._supperssion_data.value or 0) - tweak_data.player.suppression.tolerance) / (tweak_data.player.suppression.max_value - tweak_data.player.suppression.tolerance)

	return effective_ratio
end

function PlayerDamage:is_suppressed()
	return self:effective_suppression_ratio() > 0
end

function PlayerDamage:reset_suppression()
	self._supperssion_data.value = nil
	self._supperssion_data.decay_start_t = nil
end

function PlayerDamage:on_concussion(mul)
	if self._downed_timer then
		return
	end

	self:_start_concussion(mul)
end

function PlayerDamage:_start_concussion(mul)
	if self._concussion_data then
		self._concussion_data.intensity = mul
		local duration_tweak = tweak_data.projectiles.concussion.duration
		self._concussion_data.duration = duration_tweak.min + mul * math.lerp(duration_tweak.additional - 2, duration_tweak.additional + 2, math.random())
		self._concussion_data.end_t = managers.player:player_timer():time() + self._concussion_data.duration

		SoundDevice:set_rtpc("concussion_effect", self._concussion_data.intensity * 100)
	else
		local duration = 4 + mul * math.lerp(8, 12, math.random())
		self._concussion_data = {
			intensity = mul,
			duration = duration,
			end_t = managers.player:player_timer():time() + duration
		}
	end

	self._unit:sound():play("concussion_player_disoriented_sfx")
	self._unit:sound():play("concussion_effect_on")
end

function PlayerDamage:_stop_concussion()
	if not self._concussion_data then
		return
	end

	self._unit:sound():play("concussion_effect_off")

	self._concussion_data = nil
end

function PlayerDamage:on_flashbanged(sound_eff_mul)
	if self._downed_timer then
		return
	end

	self:_start_tinnitus(sound_eff_mul)
end

function PlayerDamage:_start_tinnitus(sound_eff_mul, skip_explosion_sfx)
	if self._tinnitus_data then
		if sound_eff_mul < self._tinnitus_data.intensity then
			return
		end

		self._tinnitus_data.intensity = sound_eff_mul
		self._tinnitus_data.duration = 4 + sound_eff_mul * math.lerp(8, 12, math.random())
		self._tinnitus_data.end_t = managers.player:player_timer():time() + self._tinnitus_data.duration

		if self._tinnitus_data.snd_event then
			self._tinnitus_data.snd_event:stop()
		end

		SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, self._tinnitus_data.intensity * 100))

		self._tinnitus_data.snd_event = self._unit:sound():play("tinnitus_beep")
	else
		local duration = 4 + sound_eff_mul * math.lerp(8, 12, math.random())

		SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, sound_eff_mul * 100))

		self._tinnitus_data = {
			intensity = sound_eff_mul,
			duration = duration,
			end_t = managers.player:player_timer():time() + duration,
			snd_event = self._unit:sound():play("tinnitus_beep")
		}
	end

	if not skip_explosion_sfx then
		self._unit:sound():play("flashbang_explode_sfx_player")
	end
end

function PlayerDamage:_stop_tinnitus()
	if not self._tinnitus_data then
		return
	end

	self._unit:sound():play("tinnitus_beep_stop")

	self._tinnitus_data = nil
end

function PlayerDamage:_chk_can_take_dmg()
	if not self._unit:inventory():mask_visibility() then
		return false
	end

	local can_take_damage = self._can_take_dmg_timer <= 0
	can_take_damage = managers.modifiers:modify_value("PlayerDamage:CheckCanTakeDamage", can_take_damage)

	return can_take_damage
end

function PlayerDamage:_update_can_take_dmg_timer(dt)
	self._can_take_dmg_timer = math.max(self._can_take_dmg_timer - dt, 0)
end

function PlayerDamage:_start_regen_on_the_side(time)
	if self._regen_on_the_side_timer <= 0 and time > 0 then
		self._regen_on_the_side_timer = time
		self._regen_on_the_side = true
	end
end

function PlayerDamage:_update_regen_on_the_side(dt)
	if self._regen_on_the_side then
		self._regen_on_the_side_timer = math.max(self._regen_on_the_side_timer - dt, 0)

		if self._regen_on_the_side_timer <= 0 then
			self._regen_on_the_side = false

			self:_regenerate_armor()
		end
	end
end

function PlayerDamage:get_armor_regenerate_timer()
	return self._regenerate_timer or 0
end

function PlayerDamage:get_armor_regenerate_speed()
	return self._regenerate_speed or 1
end

function PlayerDamage:_update_delayed_damage(t, dt)
	local no_chunks = #self._delayed_damage.chunks == 0
	local time_for_tick = self._delayed_damage.next_tick and t < self._delayed_damage.next_tick

	if no_chunks or time_for_tick then
		return
	end

	self._delayed_damage.next_tick = t + 1
	local total_tick = 0
	local remaining_chunks = {}

	for _, damage_chunk in ipairs(self._delayed_damage.chunks) do
		total_tick = total_tick + damage_chunk.tick
		damage_chunk.remaining = damage_chunk.remaining - damage_chunk.tick

		if self._delayed_damage.epsilon < damage_chunk.remaining then
			table.insert(remaining_chunks, damage_chunk)
		end
	end

	self._delayed_damage.chunks = remaining_chunks

	if total_tick > 0 then
		self:damage_simple({
			variant = "delayed_tick",
			damage = total_tick
		})
	end

	local remaining_damage = self:remaining_delayed_damage()

	if remaining_damage == 0 then
		self._delayed_damage.next_tick = nil
	end

	managers.hud:set_teammate_delayed_damage(HUDManager.PLAYER_PANEL, remaining_damage)
end

function PlayerDamage:delay_damage(damage, seconds)
	local damage_chunk = {
		tick = damage / seconds,
		remaining = damage
	}

	if not self._delayed_damage.next_tick then
		self._delayed_damage.next_tick = TimerManager:game():time() + 1
	end

	table.insert(self._delayed_damage.chunks, damage_chunk)
	managers.hud:set_teammate_delayed_damage(HUDManager.PLAYER_PANEL, self:remaining_delayed_damage())
end

function PlayerDamage:clear_delayed_damage()
	local remaining_damage = self:remaining_delayed_damage()
	self._delayed_damage.chunks = {}
	self._delayed_damage.next_tick = nil

	managers.hud:set_teammate_delayed_damage(HUDManager.PLAYER_PANEL, 0)

	return remaining_damage
end

function PlayerDamage:remaining_delayed_damage()
	local remaining_damage = 0

	for _, damage_chunk in ipairs(self._delayed_damage.chunks) do
		remaining_damage = remaining_damage + damage_chunk.remaining
	end

	return remaining_damage
end

PlayerBodyDamage = PlayerBodyDamage or class()

function PlayerBodyDamage:init(unit, unit_extension, body)
	self._unit = unit
	self._unit_extension = unit_extension
	self._body = body
end

function PlayerBodyDamage:get_body()
	return self._body
end

function PlayerBodyDamage:damage_fire(attack_unit, normal, position, direction, damage, velocity)
	local attack_data = {
		damage = damage,
		col_ray = {
			ray = -direction
		}
	}

	self._unit_extension:damage_killzone(attack_data)
end
