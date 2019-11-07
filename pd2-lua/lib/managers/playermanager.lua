require("lib/player_actions/PlayerActionManager")
require("lib/managers/player/SmokeScreenEffect")
require("lib/utils/ValueModifier")
require("lib/managers/player/SniperGrazeDamage")

PlayerManager = PlayerManager or class()
PlayerManager.WEAPON_SLOTS = 2
PlayerManager.TARGET_COCAINE_AMOUNT = 1500
PlayerManager._SHOCK_AND_AWE_TARGET_KILLS = 2

local function get_as_digested(amount)
	local list = {}

	for i = 1, #amount, 1 do
		table.insert(list, Application:digest_value(amount[i], false))
	end

	return list
end

local function make_double_hud_string(a, b)
	return string.format("%01d|%01d", a, b)
end

local function add_hud_item(amount, icon)
	if #amount > 1 then
		managers.hud:add_item_from_string({
			amount_str = make_double_hud_string(amount[1], amount[2]),
			amount = amount,
			icon = icon
		})
	else
		managers.hud:add_item({
			amount = amount[1],
			icon = icon
		})
	end
end

local function set_hud_item_amount(index, amount)
	if #amount > 1 then
		managers.hud:set_item_amount_from_string(index, make_double_hud_string(amount[1], amount[2]), amount)
	else
		managers.hud:set_item_amount(index, amount[1])
	end
end

function PlayerManager:init()
	self._coroutine_mgr = CoroutineManager:new()
	self._message_system = MessageSystem:new()
	self._properties = PropertyManager:new()
	self._action_mgr = PlayerActionManager:new()
	self._temporary_properties = TemporaryPropertyManager:new()
	self._value_modifier = ValueModifier:new()
	self._player_name = Idstring("units/multiplayer/mp_fps_mover/mp_fps_mover")
	self._players = {}
	self._nr_players = Global.nr_players or 1
	self._last_id = 1
	self._viewport_configs = {}
	self._num_kills = 0
	self._timers = {}
	self._player_list = {}
	self._viewport_configs[1] = {
		{
			dimensions = {
				w = 1,
				h = 1,
				x = 0,
				y = 0
			}
		}
	}
	self._viewport_configs[2] = {
		{
			dimensions = {
				w = 1,
				h = 0.5,
				x = 0,
				y = 0
			}
		},
		{
			dimensions = {
				w = 1,
				h = 0.5,
				x = 0,
				y = 0.5
			}
		}
	}

	self:_setup_rules()

	self._local_player_minions = 0
	self._local_player_body_bags = nil
	self._player_states = {
		jerry1 = "ingame_freefall",
		carry = "ingame_standard",
		civilian = "ingame_civilian",
		jerry2 = "ingame_parachuting",
		driving = "ingame_driving",
		bleed_out = "ingame_bleed_out",
		incapacitated = "ingame_incapacitated",
		mask_off = "ingame_mask_off",
		arrested = "ingame_arrested",
		clean = "ingame_clean",
		fatal = "ingame_fatal",
		standard = "ingame_standard",
		bipod = "ingame_standard",
		tased = "ingame_electrified"
	}
	self._custody_state = "custody"
	self._DEFAULT_STATE = "mask_off"
	self._current_state = self._DEFAULT_STATE
	self._sync_states = {
		"civilian",
		"clean",
		"mask_off",
		"standard",
		"jerry1",
		"jerry2"
	}
	self._current_sync_state = self._DEFAULT_STATE
	local ids_player = Idstring("player")
	self._player_timer = TimerManager:timer(ids_player) or TimerManager:make_timer(ids_player, TimerManager:pausable())
	self._hostage_close_to_local_t = 0

	self:_setup()

	self._crit_mul = 1
	self._melee_dmg_mul = 1
	self._accuracy_multiplier = 1
	self._damage_absorption = {}
	self._consumable_upgrades = {}
end

function PlayerManager:init_finalize()
	self:check_skills()
	self:aquire_default_upgrades()
end

function PlayerManager:check_skills()
	self:send_message_now("check_skills")
	self._coroutine_mgr:clear()

	self._saw_panic_when_kill = self:has_category_upgrade("saw", "panic_when_kill")
	self._unseen_strike = self:has_category_upgrade("player", "unseen_increased_crit_chance")

	if self:has_category_upgrade("pistol", "stacked_accuracy_bonus") then
		self._message_system:register(Message.OnEnemyShot, self, callback(self, self, "_on_expert_handling_event"))
	else
		self._message_system:unregister(Message.OnEnemyShot, self)
	end

	if self:has_category_upgrade("pistol", "stacking_hit_damage_multiplier") then
		self._message_system:register(Message.OnEnemyShot, "trigger_happy", callback(self, self, "_on_enter_trigger_happy_event"))
	else
		self._message_system:unregister(Message.OnEnemyShot, "trigger_happy")
	end

	if self:has_category_upgrade("player", "melee_damage_stacking") then
		local function start_bloodthirst_base(weapon_unit, variant)
			if variant ~= "melee" and not self._coroutine_mgr:is_running(PlayerAction.BloodthirstBase) then
				local data = self:upgrade_value("player", "melee_damage_stacking", nil)

				if data and type(data) ~= "number" then
					self._coroutine_mgr:add_coroutine(PlayerAction.BloodthirstBase, PlayerAction.BloodthirstBase, self, data.melee_multiplier, data.max_multiplier)
				end
			end
		end

		self._message_system:register(Message.OnEnemyKilled, "bloodthirst_base", start_bloodthirst_base)
	else
		self._message_system:unregister(Message.OnEnemyKilled, "bloodthirst_base")
	end

	if self:has_category_upgrade("player", "messiah_revive_from_bleed_out") then
		self._messiah_charges = self:upgrade_value("player", "messiah_revive_from_bleed_out", 0)
		self._max_messiah_charges = self._messiah_charges

		self._message_system:register(Message.OnEnemyKilled, "messiah_revive_from_bleed_out", callback(self, self, "_on_messiah_event"))
	else
		self._messiah_charges = 0
		self._max_messiah_charges = self._messiah_charges

		self._message_system:unregister(Message.OnEnemyKilled, "messiah_revive_from_bleed_out")
	end

	if self:has_category_upgrade("player", "recharge_messiah") then
		self._message_system:register(Message.OnDoctorBagUsed, "recharge_messiah", callback(self, self, "_on_messiah_recharge_event"))
	else
		self._message_system:unregister(Message.OnDoctorBagUsed, "recharge_messiah")
	end

	if self:has_category_upgrade("player", "double_drop") then
		self._target_kills = self:upgrade_value("player", "double_drop", 0)

		self._message_system:register(Message.OnEnemyKilled, "double_ammo_drop", callback(self, self, "_on_spawn_extra_ammo_event"))
	else
		self._target_kills = 0

		self._message_system:unregister(Message.OnEnemyKilled, "double_ammo_drop")
	end

	if self:has_category_upgrade("temporary", "single_shot_fast_reload") then
		self._message_system:register(Message.OnLethalHeadShot, "activate_aggressive_reload", callback(self, self, "_on_activate_aggressive_reload_event"))
	else
		self._message_system:unregister(Message.OnLethalHeadShot, "activate_aggressive_reload")
	end

	if self:has_category_upgrade("player", "head_shot_ammo_return") then
		self._ammo_efficiency = self:upgrade_value("player", "head_shot_ammo_return", nil)

		self._message_system:register(Message.OnHeadShot, "ammo_efficiency", callback(self, self, "_on_enter_ammo_efficiency_event"))
	else
		self._ammo_efficiency = nil

		self._message_system:unregister(Message.OnHeadShot, "ammo_efficiency")
	end

	if self:has_category_upgrade("player", "melee_kill_increase_reload_speed") then
		self._message_system:register(Message.OnEnemyKilled, "bloodthirst_reload_speed", callback(self, self, "_on_enemy_killed_bloodthirst"))
	else
		self._message_system:unregister(Message.OnEnemyKilled, "bloodthirst_reload_speed")
	end

	if self:has_category_upgrade("player", "super_syndrome") then
		self._super_syndrome_count = self:upgrade_value("player", "super_syndrome")
	else
		self._super_syndrome_count = 0
	end

	if self:has_category_upgrade("player", "dodge_shot_gain") then
		local last_gain_time = 0
		local dodge_gain = self:upgrade_value("player", "dodge_shot_gain")[1]
		local cooldown = self:upgrade_value("player", "dodge_shot_gain")[2]

		local function on_player_damage(attack_data)
			local t = TimerManager:game():time()

			if attack_data.variant == "bullet" and t > last_gain_time + cooldown then
				last_gain_time = t

				managers.player:_dodge_shot_gain(managers.player:_dodge_shot_gain() + dodge_gain)
			end
		end

		self:register_message(Message.OnPlayerDodge, "dodge_shot_gain_dodge", callback(self, self, "_dodge_shot_gain", 0))
		self:register_message(Message.OnPlayerDamage, "dodge_shot_gain_damage", on_player_damage)
	else
		self:unregister_message(Message.OnPlayerDodge, "dodge_shot_gain_dodge")
		self:unregister_message(Message.OnPlayerDamage, "dodge_shot_gain_damage")
	end

	if self:has_category_upgrade("player", "dodge_replenish_armor") then
		self:register_message(Message.OnPlayerDodge, "dodge_replenish_armor", callback(self, self, "_dodge_replenish_armor"))
	else
		self:unregister_message(Message.OnPlayerDodge, "dodge_replenish_armor")
	end

	if managers.blackmarket:equipped_grenade() == "smoke_screen_grenade" then
		local function speed_up_on_kill()
			if #managers.player:smoke_screens() == 0 then
				managers.player:speed_up_grenade_cooldown(1)
			end
		end

		self:register_message(Message.OnEnemyKilled, "speed_up_smoke_grenade", speed_up_on_kill)
	else
		self:unregister_message(Message.OnEnemyKilled, "speed_up_smoke_grenade")
	end

	self:add_coroutine("damage_control", PlayerAction.DamageControl)

	if self:has_category_upgrade("snp", "graze_damage") then
		self:register_message(Message.OnWeaponFired, "graze_damage", callback(SniperGrazeDamage, SniperGrazeDamage, "on_weapon_fired"))
	else
		self:unregister_message(Message.OnWeaponFired, "graze_damage")
	end
end

function PlayerManager:damage_absorption()
	local total = 0

	for _, absorption in pairs(self._damage_absorption) do
		total = total + Application:digest_value(absorption, false)
	end

	total = total + self:get_best_cocaine_damage_absorption()
	total = managers.modifiers:modify_value("PlayerManager:GetDamageAbsorption", total)

	return total
end

function PlayerManager:set_damage_absorption(key, value)
	self._damage_absorption[key] = value and Application:digest_value(value, true) or nil

	managers.hud:set_absorb_active(HUDManager.PLAYER_PANEL, self:damage_absorption())
end

function PlayerManager:_on_expert_handling_event(unit, attack_data)
	local attacker_unit = attack_data.attacker_unit
	local variant = attack_data.variant

	if attacker_unit == self:player_unit() and self:is_current_weapon_of_category("pistol") and variant == "bullet" and not self._coroutine_mgr:is_running(PlayerAction.ExpertHandling) then
		local data = self:upgrade_value("pistol", "stacked_accuracy_bonus", nil)

		if data and type(data) ~= "number" then
			self._coroutine_mgr:add_coroutine(PlayerAction.ExpertHandling, PlayerAction.ExpertHandling, self, data.accuracy_bonus, data.max_stacks, Application:time() + data.max_time)
		end
	end
end

function PlayerManager:_on_enter_trigger_happy_event(unit, attack_data)
	local attacker_unit = attack_data.attacker_unit
	local variant = attack_data.variant

	if attacker_unit == self:player_unit() and variant == "bullet" and not self._coroutine_mgr:is_running("trigger_happy") and self:is_current_weapon_of_category("pistol") then
		local data = self:upgrade_value("pistol", "stacking_hit_damage_multiplier", 0)

		if data ~= 0 then
			self._coroutine_mgr:add_coroutine("trigger_happy", PlayerAction.TriggerHappy, self, data.damage_bonus, data.max_stacks, Application:time() + data.max_time)
		end
	end
end

function PlayerManager:_on_enemy_killed_bloodthirst(equipped_unit, variant, killed_unit)
	if variant == "melee" then
		local data = self:upgrade_value("player", "melee_kill_increase_reload_speed", 0)

		if data ~= 0 then
			self._temporary_properties:activate_property("bloodthirst_reload_speed", data[2], data[1])
		end
	end
end

function PlayerManager:_on_enter_ammo_efficiency_event()
	if not self._coroutine_mgr:is_running("ammo_efficiency") then
		local weapon_unit = self:equipped_weapon_unit()

		if weapon_unit and weapon_unit:base():fire_mode() == "single" and weapon_unit:base():is_category("smg", "assault_rifle", "snp") then
			self._coroutine_mgr:add_coroutine("ammo_efficiency", PlayerAction.AmmoEfficiency, self, self._ammo_efficiency.headshots, self._ammo_efficiency.ammo, Application:time() + self._ammo_efficiency.time)
		end
	end
end

function PlayerManager:_on_activate_aggressive_reload_event(attack_data)
	if attack_data and attack_data.variant ~= "projectile" then
		local weapon_unit = self:equipped_weapon_unit()

		if weapon_unit then
			local weapon = weapon_unit:base()

			if weapon and weapon:fire_mode() == "single" and weapon:is_category("smg", "assault_rifle", "snp") then
				self:activate_temporary_upgrade("temporary", "single_shot_fast_reload")
			end
		end
	end
end

function PlayerManager:_on_enter_shock_and_awe_event()
	if not self._coroutine_mgr:is_running("automatic_faster_reload") then
		local equipped_unit = self:get_current_state()._equipped_unit
		local data = self:upgrade_value("player", "automatic_faster_reload", nil)
		local is_grenade_launcher = equipped_unit:base():is_category("grenade_launcher")

		if data and equipped_unit and not is_grenade_launcher and (equipped_unit:base():fire_mode() == "auto" or equipped_unit:base():is_category("bow", "flamethrower")) then
			self._coroutine_mgr:add_and_run_coroutine("automatic_faster_reload", PlayerAction.ShockAndAwe, self, data.target_enemies, data.max_reload_increase, data.min_reload_increase, data.penalty, data.min_bullets, equipped_unit)
		end
	end
end

function PlayerManager:_on_messiah_event()
	if self._messiah_charges > 0 and self._current_state == "bleed_out" and not self._coroutine_mgr:is_running("get_up_messiah") then
		self._coroutine_mgr:add_coroutine("get_up_messiah", PlayerAction.MessiahGetUp, self)
	end
end

function PlayerManager:messiah_charges()
	return self._messiah_charges
end

function PlayerManager:use_messiah_charge()
	if self._messiah_charges then
		self._messiah_charges = math.max(self._messiah_charges - 1, 0)
	end
end

function PlayerManager:_on_messiah_recharge_event()
	if self._messiah_charges and self._max_messiah_charges then
		self._messiah_charges = math.min(self._messiah_charges + 1, self._max_messiah_charges)
	end
end

function PlayerManager:stockholm_syndrome_count()
	return self._super_syndrome_count
end

function PlayerManager:change_stockholm_syndrome_count(value)
	self._super_syndrome_count = math.max(self._super_syndrome_count + value, 0)

	if self._super_syndrome_count <= 0 then
		if Network:is_server() then
			managers.groupai:state():set_super_syndrome(managers.network:session():local_peer():id(), false)
		else
			managers.network:session():send_to_host("sync_set_super_syndrome", managers.network:session():local_peer():id(), false)
		end
	end
end

function PlayerManager:_on_spawn_extra_ammo_event(equipped_unit, variant, killed_unit)
	if self._num_kills % self._target_kills == 0 then
		if Network:is_client() then
			managers.network:session():send_to_host("sync_spawn_extra_ammo", killed_unit)
		else
			self:spawn_extra_ammo(killed_unit)
		end
	end
end

function PlayerManager:mul_melee_damage(value)
	self._melee_dmg_mul = self._melee_dmg_mul * value
end

function PlayerManager:set_melee_dmg_multiplier(value)
	self._melee_dmg_mul = value
end

function PlayerManager:reset_melee_dmg_multiplier()
	self._melee_dmg_mul = 1
end

function PlayerManager:get_melee_dmg_multiplier()
	return self._melee_dmg_mul
end

function PlayerManager:mul_to_accuracy_multiplier(value)
	self._accuracy_multiplier = self._accuracy_multiplier * value
end

function PlayerManager:reset_acuracy_multiplier()
	self._accuracy_multiplier = 1
end

function PlayerManager:get_accuracy_multiplier()
	return self._accuracy_multiplier
end

function PlayerManager:add_to_crit_mul(value)
	self._crit_mul = self._crit_mul + value
end

function PlayerManager:sub_from_crit_mul(value)
	self._crit_mul = self._crit_mul - value
end

function PlayerManager:register_message(message, uid, func)
	self._message_system:register(message, uid, func)
end

function PlayerManager:unregister_message(message, uid)
	self._message_system:unregister(message, uid)
end

function PlayerManager:send_message(message, uid, ...)
	self._message_system:notify(message, uid, ...)
end

function PlayerManager:send_message_now(message, uid, ...)
	self._message_system:notify_now(message, uid, ...)
end

function PlayerManager:add_coroutine(name, func, ...)
	self._coroutine_mgr:add_coroutine(name, func, ...)
end

function PlayerManager:add_to_property(name, value)
	self._properties:add_to_property(name, value)
end

function PlayerManager:mul_to_property(name, value)
	self._properties:mul_to_property(name, value)
end

function PlayerManager:remove_property(name)
	self._properties:remove_property(name)
end

function PlayerManager:set_property(name, value)
	self._properties:set_property(name, value)
end

function PlayerManager:get_property(name, default)
	return self._properties:get_property(name, default)
end

function PlayerManager:get_temporary_property(name, default)
	return self._temporary_properties:get_property(name, default)
end

function PlayerManager:activate_temporary_property(name, time, value)
	self._temporary_properties:activate_property(name, time, value)
end

function PlayerManager:add_to_temporary_property(name, time, value)
	self._temporary_properties:add_to_property(name, time, value)
end

function PlayerManager:has_active_temporary_property(name)
	return self._temporary_properties:has_active_property(name)
end

function PlayerManager:add_modifier(...)
	return self._value_modifier:add_modifier(...)
end

function PlayerManager:remove_modifier(...)
	return self._value_modifier:remove_modifier(...)
end

function PlayerManager:modify_value(...)
	return self._value_modifier:modify_value(...)
end

function PlayerManager:_setup()
	self._equipment = {
		selections = {},
		specials = {}
	}
	self._listener_holder = EventListenerHolder:new()
	self._player_mesh_suffix = ""
	self._temporary_upgrades = {}

	if not Global.player_manager then
		Global.player_manager = {
			upgrades = {},
			team_upgrades = {},
			cooldown_upgrades = {}
		}
		Global.player_manager.cooldown_upgrades.cooldown = {}
		Global.player_manager.weapons = {}
		Global.player_manager.equipment = {}
		Global.player_manager.grenades = {}
		Global.player_manager.synced_upgrades = {}
		Global.player_manager.kit = {
			weapon_slots = {
				"glock_17"
			},
			equipment_slots = {},
			special_equipment_slots = {}
		}
		Global.player_manager.viewed_content_updates = {}
	else
		for _, val in pairs(Global.player_manager.cooldown_upgrades.cooldown) do
			val.cooldown_time = 0
		end
	end

	Global.player_manager.default_kit = {
		weapon_slots = {
			"glock_17"
		},
		equipment_slots = {},
		special_equipment_slots = {
			"cable_tie"
		}
	}
	Global.player_manager.synced_bonuses = {}
	Global.player_manager.synced_equipment_possession = {}
	Global.player_manager.synced_deployables = {}
	Global.player_manager.synced_grenades = {}
	Global.player_manager.synced_cable_ties = {}
	Global.player_manager.synced_ammo_info = {}
	Global.player_manager.synced_carry = {}
	Global.player_manager.synced_team_upgrades = {}
	Global.player_manager.synced_vehicle_data = {}
	Global.player_manager.synced_bipod = {}
	Global.player_manager.synced_cocaine_stacks = {}
	self._global = Global.player_manager
end

function PlayerManager:_setup_rules()
	self._rules = {
		no_run = 0
	}
end

function PlayerManager:aquire_default_upgrades()
	local default_upgrades = tweak_data.skilltree.default_upgrades or {}

	for _, upgrade in ipairs(default_upgrades) do
		if not managers.upgrades:aquired(upgrade, UpgradesManager.AQUIRE_STRINGS[1]) then
			managers.upgrades:aquire_default(upgrade, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end

	for i = 1, PlayerManager.WEAPON_SLOTS, 1 do
		if not managers.player:weapon_in_slot(i) then
			self._global.kit.weapon_slots[i] = managers.player:availible_weapons(i)[1]
		end
	end

	self:_verify_equipment_kit(true)
end

function PlayerManager:update(t, dt)
	self._message_system:update()
	self:_update_timers(t)

	if self._need_to_send_player_status then
		self._need_to_send_player_status = nil

		self:need_send_player_status()
	end

	self._sent_player_status_this_frame = nil
	local local_player = self:local_player()

	if self:has_category_upgrade("player", "close_to_hostage_boost") and (not self._hostage_close_to_local_t or self._hostage_close_to_local_t <= t) then
		self._is_local_close_to_hostage = alive(local_player) and managers.groupai and managers.groupai:state():is_a_hostage_within(local_player:movement():m_pos(), tweak_data.upgrades.hostage_near_player_radius)
		self._hostage_close_to_local_t = t + tweak_data.upgrades.hostage_near_player_check_t
	end

	self:_update_damage_dealt(t, dt)

	if #self._global.synced_cocaine_stacks >= 4 then
		local amount = 0

		for i, stack in pairs(self._global.synced_cocaine_stacks) do
			if stack.in_use then
				amount = amount + stack.amount
			end

			if PlayerManager.TARGET_COCAINE_AMOUNT <= amount then
				managers.achievment:award("mad_5")
			end
		end
	end

	self._coroutine_mgr:update(t, dt)
	self._action_mgr:update(t, dt)

	if self._unseen_strike and not self._coroutine_mgr:is_running(PlayerAction.UnseenStrike) then
		local data = self:upgrade_value("player", "unseen_increased_crit_chance", 0)

		if data ~= 0 then
			self._coroutine_mgr:add_coroutine(PlayerAction.UnseenStrike, PlayerAction.UnseenStrike, self, data.min_time, data.max_duration, data.crit_chance)
		end
	end

	self:update_smoke_screens(t, dt)
end

function PlayerManager:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

function PlayerManager:remove_listener(key)
	self._listener_holder:remove(key)
end

function PlayerManager:preload()
end

function PlayerManager:need_send_player_status()
	local player = self:player_unit()

	if not player then
		self._need_to_send_player_status = true

		return
	elseif self._sent_player_status_this_frame then
		return
	end

	self._sent_player_status_this_frame = true

	player:character_damage():send_set_status()
end

function PlayerManager:_internal_load()
	local player = self:player_unit()

	if not player then
		return
	end

	local default_weapon_selection = 1
	local secondary = managers.blackmarket:equipped_secondary()
	local secondary_slot = managers.blackmarket:equipped_weapon_slot("secondaries")
	local texture_switches = managers.blackmarket:get_weapon_texture_switches("secondaries", secondary_slot, secondary)

	player:inventory():add_unit_by_factory_name(secondary.factory_id, default_weapon_selection == 1, false, secondary.blueprint, secondary.cosmetics, texture_switches)

	local primary = managers.blackmarket:equipped_primary()

	if primary then
		local primary_slot = managers.blackmarket:equipped_weapon_slot("primaries")
		local texture_switches = managers.blackmarket:get_weapon_texture_switches("primaries", primary_slot, primary)

		player:inventory():add_unit_by_factory_name(primary.factory_id, default_weapon_selection == 2, false, primary.blueprint, primary.cosmetics, texture_switches)
	end

	player:inventory():set_melee_weapon(managers.blackmarket:equipped_melee_weapon())

	local peer_id = managers.network:session():local_peer():id()
	local grenade, amount = managers.blackmarket:equipped_grenade()

	if self:has_grenade(peer_id) then
		amount = self:get_grenade_amount(peer_id) or amount
	end

	amount = managers.modifiers:modify_value("PlayerManager:GetThrowablesMaxAmount", amount)

	self:_set_grenade({
		grenade = grenade,
		amount = math.min(amount, self:get_max_grenades())
	})
	self:_set_body_bags_amount(self._local_player_body_bags or self:total_body_bags())

	if not self._respawn then
		self:_add_level_equipment(player)

		for i, name in ipairs(self._global.default_kit.special_equipment_slots) do
			local ok_name = self._global.equipment[name] and name

			if ok_name then
				local upgrade = tweak_data.upgrades.definitions[ok_name]

				if upgrade and (upgrade.slot and upgrade.slot < 2 or not upgrade.slot) then
					self:add_equipment({
						silent = true,
						equipment = upgrade.equipment_id
					})
				end
			end
		end

		local slot = 2

		if self:has_category_upgrade("player", "second_deployable") then
			slot = 3
		else
			self:set_equipment_in_slot(nil, 2)
		end

		local equipment_list = self:equipment_slots()

		for i, name in ipairs(equipment_list) do
			local ok_name = self._global.equipment[name] and name or self:equipment_in_slot(i)

			if ok_name then
				local upgrade = tweak_data.upgrades.definitions[ok_name]

				if upgrade and (upgrade.slot and upgrade.slot < slot or not upgrade.slot) then
					self:add_equipment({
						silent = true,
						equipment = upgrade.equipment_id,
						slot = i
					})
				end
			end
		end

		self:update_deployable_selection_to_peers()
	end

	if self:has_category_upgrade("player", "cocaine_stacking") then
		self:update_synced_cocaine_stacks_to_peers(0, self:upgrade_value("player", "sync_cocaine_upgrade_level", 1), self:upgrade_level("player", "cocaine_stack_absorption_multiplier", 0))
		managers.hud:set_info_meter(nil, {
			icon = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_icon_01",
			max = 1,
			current = self:get_local_cocaine_damage_absorption_ratio(),
			total = self:get_local_cocaine_damage_absorption_max_ratio()
		})
	end

	self:update_cocaine_hud()

	local equipment = self:selected_equipment()

	if equipment then
		add_hud_item(get_as_digested(equipment.amount), equipment.icon)
	end

	if self:has_equipment("armor_kit") then
		managers.mission:call_global_event("player_regenerate_armor", true)
	end
end

function PlayerManager:_add_level_equipment(player)
	local id = Global.running_simulation and managers.editor:layer("Level Settings"):get_setting("simulation_level_id")
	id = id ~= "none" and id or nil
	id = id or Global.level_data.level_id

	if not id then
		return
	end

	local equipment = tweak_data.levels[id] and tweak_data.levels[id].equipment

	if not equipment then
		return
	end

	for _, eq in ipairs(equipment) do
		self:add_equipment({
			silent = true,
			equipment = eq,
			slot = _
		})
	end
end

function PlayerManager:spawn_dropin_penalty(dead, bleed_out, health, used_deployable, used_cable_ties, used_body_bags)
	local player = self:player_unit()

	print("[PlayerManager:spawn_dropin_penalty]", dead, bleed_out, health, used_deployable, used_cable_ties, used_body_bags)

	if not alive(player) then
		return
	end

	if used_deployable then
		managers.player:clear_equipment()

		local equipped_deployable = managers.blackmarket:equipped_deployable()
		local deployable_data = tweak_data.equipments[equipped_deployable]

		if deployable_data and deployable_data.dropin_penalty_function_name then
			local used_one, redirect = player:equipment()[deployable_data.dropin_penalty_function_name](player:equipment(), self._equipment.selected_index)

			if redirect then
				redirect(player)
			end
		end
	end

	for i = 1, used_cable_ties, 1 do
		self:remove_special("cable_tie")
	end

	self:_set_body_bags_amount(math.max(self:total_body_bags() - used_body_bags, 0))

	local min_health = nil

	if dead or bleed_out then
		min_health = 0
	else
		min_health = 0.25
	end

	player:character_damage():set_health(math.max(min_health, health) * player:character_damage():_max_health())

	if dead or bleed_out then
		print("[PlayerManager:spawn_dead] Killing")
		player:network():send("sync_player_movement_state", "dead", player:character_damage():down_time(), player:id())
		managers.groupai:state():on_player_criminal_death(managers.network:session():local_peer():id())
		player:base():set_enabled(false)
		game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
		player:character_damage():set_invulnerable(true)
		player:character_damage():set_health(0)
		player:base():_unregister()
		World:delete_unit(player)
	end
end

function PlayerManager:nr_players()
	return self._nr_players
end

function PlayerManager:set_nr_players(nr)
	self._nr_players = nr
end

function PlayerManager:player_id(unit)
	local id = self._last_id

	for k, player in ipairs(self._players) do
		if player == unit then
			id = k
		end
	end

	return id
end

function PlayerManager:viewport_config()
	local configs = self._viewport_configs[self._last_id]

	if configs then
		return configs[1]
	end
end

function PlayerManager:setup_viewports()
	local configs = self._viewport_configs[self._last_id]

	if configs then
		for k, player in ipairs(self._players) do
			-- Nothing
		end
	else
		Application:error("Unsupported number of players: " .. tostring(self._last_id))
	end
end

function PlayerManager:player_states()
	local ret = {}

	for k, _ in pairs(self._player_states) do
		table.insert(ret, k)
	end

	table.insert(ret, self._custody_state)

	return ret
end

function PlayerManager:current_state()
	return self._current_state
end

function PlayerManager:default_player_state()
	return self._DEFAULT_STATE
end

function PlayerManager:current_sync_state()
	return self._current_sync_state
end

function PlayerManager:set_player_state(state)
	state = state or self._current_state

	if state == "bleed_out" and self._super_syndrome_count and self._super_syndrome_count > 0 then
		if Network:is_server() then
			managers.groupai:state():set_super_syndrome(managers.network:session():local_peer():id(), true)
		else
			managers.network:session():send_to_host("sync_set_super_syndrome", managers.network:session():local_peer():id(), true)
		end
	end

	if state == "standard" and self:get_my_carry_data() then
		state = "carry"
	end

	if state == self._current_state then
		return
	end

	if state ~= "standard" and state ~= "carry" and state ~= "bipod" and state ~= "jerry1" and state ~= "jerry2" and state ~= "tased" then
		local unit = self:player_unit()

		if unit then
			unit:character_damage():disable_berserker()
		end
	end

	if (state == "clean" or state == "mask_off" or state == "civilian") and self._current_state ~= "clean" and self._current_state ~= "mask_off" and self._current_state ~= "civilian" then
		managers.groupai:state():calm_ai()
	end

	if not self._player_states[state] then
		Application:error("State '" .. tostring(state) .. "' does not exist in list of available states.")

		state = self._DEFAULT_STATE
	end

	if table.contains(self._sync_states, state) then
		self._current_sync_state = state
	end

	self._current_state = state

	self:_change_player_state()
end

function PlayerManager:spawn_players(position, rotation, state)
	for var = 1, self._nr_players, 1 do
		self._last_id = var
	end

	self:spawned_player(self._last_id, safe_spawn_unit(self:player_unit_name(), position, rotation))

	return self._players[1]
end

function PlayerManager:spawned_player(id, unit)
	self._players[id] = unit

	self:setup_viewports()
	self:_internal_load()
	self:_change_player_state()

	if id == 1 then
		managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, 1, unit:inventory():unit_by_selection(1):base():fire_mode())
		managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, 2, unit:inventory():unit_by_selection(2):base():fire_mode())

		local grenade_cooldown = tweak_data.blackmarket.projectiles[managers.blackmarket:equipped_grenade()].base_cooldown

		if grenade_cooldown and not self:got_max_grenades() then
			self:replenish_grenades(grenade_cooldown)
		end
	end
end

function PlayerManager:_change_player_state()
	local unit = self:player_unit()

	if not unit then
		return
	end

	self._listener_holder:call(self._current_state, unit)

	if game_state_machine:last_queued_state_name() ~= self._player_states[self._current_state] then
		game_state_machine:change_state_by_name(self._player_states[self._current_state])
	end

	unit:movement():change_state(self._current_state)
	self:send_message("player_state_changed", nil, self._current_state)
end

function PlayerManager:player_destroyed(id)
	self._players[id] = nil
	self._respawn = true

	if id == 1 then
		self:clear_timers()
	end
end

function PlayerManager:players()
	return self._players
end

function PlayerManager:player_unit_name()
	return self._player_name
end

function PlayerManager:player_unit(id)
	local p_id = id or 1

	return self._players[p_id]
end

function PlayerManager:local_player()
	return self:player_unit()
end

function PlayerManager:num_players_with_more_health()
	local num_players = 0
	local count = #self._player_list
	local local_health = self:player_unit():character_damage():health_ratio_100()

	for i = 1, count, 1 do
		if local_health < self._player_list[i].health then
			num_players = num_players + 1
		end
	end

	return num_players
end

function PlayerManager:num_connected_players()
	return #self._player_list
end

function PlayerManager:warp_to(pos, rot, id, velocity)
	local player = self._players[id or 1]

	if alive(player) then
		player:movement():warp_to(pos, rot, velocity)
	end
end

function PlayerManager:on_out_of_world()
	local player_unit = managers.player:player_unit()

	if not alive(player_unit) then
		return
	end

	local player_pos = player_unit:position()
	local closest_pos, closest_distance = nil

	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if data.unit ~= player_unit then
			local pos = data.unit:position()
			local distance = mvector3.distance(player_pos, pos)

			if not closest_distance or distance < closest_distance then
				closest_distance = distance
				closest_pos = pos
			end
		end
	end

	if closest_pos then
		managers.player:warp_to(closest_pos, player_unit:rotation())

		return
	end

	local pos = player_unit:movement():nav_tracker():field_position()

	managers.player:warp_to(pos, player_unit:rotation())
end

function PlayerManager:aquire_weapon(upgrade, id)
	if self._global.weapons[id] then
		return
	end

	self._global.weapons[id] = upgrade
	local player = self:player_unit()

	if not player then
		return
	end
end

function PlayerManager:unaquire_weapon(upgrade, id)
	self._global.weapons[id] = upgrade
end

function PlayerManager:aquire_melee_weapon(upgrade, id)
end

function PlayerManager:unaquire_melee_weapon(upgrade, id)
end

function PlayerManager:aquire_grenade(upgrade, id)
end

function PlayerManager:unaquire_grenade(upgrade, id)
end

function PlayerManager:_verify_equipment_kit(loading)
	local max_n = table.maxn(self._global.kit.equipment_slots)
	local equipment_slots = {}

	for i = 1, max_n, 1 do
		if self._global.kit.equipment_slots[i] then
			table.insert(equipment_slots, self._global.kit.equipment_slots[i])
		end
	end

	if #equipment_slots ~= #self._global.kit.equipment_slots then
		Application:error("[PlayerManager:_verify_equipment_kit] Gaps in player equipment slots detected, re-adjusting")
		Application:error(inspect(self._global.kit.equipment_slots))
		Application:error(inspect(equipment_slots))

		self._global.kit.equipment_slots = equipment_slots

		if managers.blackmarket then
			managers.blackmarket:equip_deployable({
				target_slot = 1,
				name = self._global.kit.equipment_slots[1]
			}, loading)
		end
	end
end

function PlayerManager:aquire_equipment(upgrade, id, loading)
	if self._global.equipment[id] then
		return
	end

	self._global.equipment[id] = upgrade

	if upgrade.aquire then
		managers.upgrades:aquire_default(upgrade.aquire.upgrade, UpgradesManager.AQUIRE_STRINGS[1])
	end

	self:_verify_equipment_kit(loading)
end

function PlayerManager:spawn_extra_ammo(unit)
	if alive(unit) then
		unit:character_damage():drop_pickup(true)
	end
end

function PlayerManager:on_killshot(killed_unit, variant, headshot, weapon_id)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
		return
	end

	local weapon_melee = weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[weapon_id] and true

	if killed_unit:brain().surrendered and killed_unit:brain():surrendered() and (variant == "melee" or weapon_melee) then
		managers.custom_safehouse:award("daily_honorable")
	end

	managers.modifiers:run_func("OnPlayerManagerKillshot", player_unit, killed_unit:base()._tweak_table, variant)

	local equipped_unit = self:get_current_state()._equipped_unit
	self._num_kills = self._num_kills + 1

	if self._num_kills % self._SHOCK_AND_AWE_TARGET_KILLS == 0 and self:has_category_upgrade("player", "automatic_faster_reload") then
		self:_on_enter_shock_and_awe_event()
	end

	self._message_system:notify(Message.OnEnemyKilled, nil, equipped_unit, variant, killed_unit)

	if self._saw_panic_when_kill and variant ~= "melee" then
		local equipped_unit = self:get_current_state()._equipped_unit:base()

		if equipped_unit:is_category("saw") then
			local pos = player_unit:position()
			local skill = self:upgrade_value("saw", "panic_when_kill")

			if skill and type(skill) ~= "number" then
				local area = skill.area
				local chance = skill.chance
				local amount = skill.amount
				local enemies = World:find_units_quick("sphere", pos, area, 12, 21)

				for i, unit in ipairs(enemies) do
					if unit:character_damage() then
						unit:character_damage():build_suppression(amount, chance)
					end
				end
			end
		end
	end

	local t = Application:time()
	local damage_ext = player_unit:character_damage()

	if self:has_category_upgrade("player", "kill_change_regenerate_speed") then
		local amount = self:body_armor_value("skill_kill_change_regenerate_speed", nil, 1)
		local multiplier = self:upgrade_value("player", "kill_change_regenerate_speed", 0)

		damage_ext:change_regenerate_speed(amount * multiplier, tweak_data.upgrades.kill_change_regenerate_speed_percentage)
	end

	local gain_throwable_per_kill = managers.player:upgrade_value("team", "crew_throwable_regen", 0)

	if gain_throwable_per_kill ~= 0 then
		self._throw_regen_kills = (self._throw_regen_kills or 0) + 1

		if gain_throwable_per_kill < self._throw_regen_kills then
			managers.player:add_grenade_amount(1, true)

			self._throw_regen_kills = 0
		end
	end

	if self._on_killshot_t and t < self._on_killshot_t then
		return
	end

	local regen_armor_bonus = self:upgrade_value("player", "killshot_regen_armor_bonus", 0)
	local dist_sq = mvector3.distance_sq(player_unit:movement():m_pos(), killed_unit:movement():m_pos())
	local close_combat_sq = tweak_data.upgrades.close_combat_distance * tweak_data.upgrades.close_combat_distance

	if dist_sq <= close_combat_sq then
		regen_armor_bonus = regen_armor_bonus + self:upgrade_value("player", "killshot_close_regen_armor_bonus", 0)
		local panic_chance = self:upgrade_value("player", "killshot_close_panic_chance", 0)
		panic_chance = managers.modifiers:modify_value("PlayerManager:GetKillshotPanicChance", panic_chance)

		if panic_chance > 0 or panic_chance == -1 then
			local slotmask = managers.slot:get_mask("enemies")
			local units = World:find_units_quick("sphere", player_unit:movement():m_pos(), tweak_data.upgrades.killshot_close_panic_range, slotmask)

			for e_key, unit in pairs(units) do
				if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
					unit:character_damage():build_suppression(0, panic_chance)
				end
			end
		end
	end

	if damage_ext and regen_armor_bonus > 0 then
		damage_ext:restore_armor(regen_armor_bonus)
	end

	local regen_health_bonus = 0

	if variant == "melee" then
		regen_health_bonus = regen_health_bonus + self:upgrade_value("player", "melee_kill_life_leech", 0)
	end

	if damage_ext and regen_health_bonus > 0 then
		damage_ext:restore_health(regen_health_bonus)
	end

	self._on_killshot_t = t + (tweak_data.upgrades.on_killshot_cooldown or 0)

	if _G.IS_VR then
		local steelsight_multiplier = equipped_unit:base():enter_steelsight_speed_multiplier()
		local stamina_percentage = (steelsight_multiplier - 1) * tweak_data.vr.steelsight_stamina_regen
		local stamina_regen = player_unit:movement():_max_stamina() * stamina_percentage

		player_unit:movement():add_stamina(stamina_regen)
	end
end

function PlayerManager:chk_wild_kill_counter(killed_unit, variant)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
		return
	end

	local damage_ext = player_unit:character_damage()

	if damage_ext and (managers.player:has_category_upgrade("player", "wild_health_amount") or managers.player:has_category_upgrade("player", "wild_armor_amount")) then
		self._wild_kill_triggers = self._wild_kill_triggers or {}
		local t = Application:time()

		while self._wild_kill_triggers[1] and self._wild_kill_triggers[1] <= t do
			table.remove(self._wild_kill_triggers, 1)
		end

		if tweak_data.upgrades.wild_max_triggers_per_time <= #self._wild_kill_triggers then
			return
		end

		local trigger_cooldown = tweak_data.upgrades.wild_trigger_time or 30
		local wild_health_amount = managers.player:upgrade_value("player", "wild_health_amount", 0)
		local wild_armor_amount = managers.player:upgrade_value("player", "wild_armor_amount", 0)
		local less_health_wild_armor = managers.player:upgrade_value("player", "less_health_wild_armor", 0)
		local less_armor_wild_health = managers.player:upgrade_value("player", "less_armor_wild_health", 0)
		local less_health_wild_cooldown = managers.player:upgrade_value("player", "less_health_wild_cooldown", 0)
		local less_armor_wild_cooldown = managers.player:upgrade_value("player", "less_armor_wild_cooldown", 0)
		local missing_health_ratio = math.clamp(1 - damage_ext:health_ratio(), 0, 1)
		local missing_armor_ratio = math.clamp(1 - damage_ext:armor_ratio(), 0, 1)

		if less_health_wild_armor ~= 0 and less_health_wild_armor[1] ~= 0 then
			local missing_health_stacks = math.floor(missing_health_ratio / less_health_wild_armor[1])
			wild_armor_amount = wild_armor_amount + less_health_wild_armor[2] * missing_health_stacks
		end

		if less_armor_wild_health ~= 0 and less_armor_wild_health[1] ~= 0 then
			local missing_armor_stacks = math.floor(missing_armor_ratio / less_armor_wild_health[1])
			wild_health_amount = wild_health_amount + less_armor_wild_health[2] * missing_armor_stacks
		end

		damage_ext:restore_health(wild_health_amount, true, false)
		damage_ext:restore_armor(wild_armor_amount)

		if less_health_wild_cooldown ~= 0 and less_health_wild_cooldown[1] ~= 0 then
			local missing_health_stacks = math.floor(missing_health_ratio / less_health_wild_cooldown[1])
			trigger_cooldown = trigger_cooldown - less_health_wild_cooldown[2] * missing_health_stacks
		end

		if less_armor_wild_cooldown ~= 0 and less_armor_wild_cooldown[1] ~= 0 then
			local missing_armor_stacks = math.floor(missing_armor_ratio / less_armor_wild_cooldown[1])
			trigger_cooldown = trigger_cooldown - less_armor_wild_cooldown[2] * missing_armor_stacks
		end

		local trigger_time = t + math.max(trigger_cooldown, 0)
		local insert_index = #self._wild_kill_triggers

		while insert_index > 0 and trigger_time < self._wild_kill_triggers[insert_index] do
			insert_index = insert_index - 1
		end

		table.insert(self._wild_kill_triggers, insert_index + 1, trigger_time)
	end
end

function PlayerManager:chk_store_armor_health_kill_counter(killed_unit, variant)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
		return
	end

	local damage_ext = player_unit:character_damage()

	if damage_ext and damage_ext:can_store_armor_health() and self:has_category_upgrade("player", "armor_health_store_amount") then
		self._armor_health_store_kill_counter = self._armor_health_store_kill_counter or 0
		self._armor_health_store_kill_counter = self._armor_health_store_kill_counter + 1

		if tweak_data.upgrades.armor_health_store_kill_amount <= self._armor_health_store_kill_counter then
			self._armor_health_store_kill_counter = 0

			damage_ext:add_armor_stored_health(self:upgrade_value("player", "armor_health_store_amount", 0))
		end
	end
end

function PlayerManager:_update_damage_dealt(t, dt)
	local local_peer_id = managers.network:session() and managers.network:session():local_peer():id()

	if not local_peer_id or not self:has_category_upgrade("player", "cocaine_stacking") then
		return
	end

	self._damage_dealt_to_cops_t = self._damage_dealt_to_cops_t or t + (tweak_data.upgrades.cocaine_stacks_tick_t or 1)
	self._damage_dealt_to_cops_decay_t = self._damage_dealt_to_cops_decay_t or t + (tweak_data.upgrades.cocaine_stacks_decay_t or 5)
	local cocaine_stack = self:get_synced_cocaine_stacks(local_peer_id)
	local amount = cocaine_stack and cocaine_stack.amount or 0
	local new_amount = amount

	if self._damage_dealt_to_cops_t <= t then
		self._damage_dealt_to_cops_t = t + (tweak_data.upgrades.cocaine_stacks_tick_t or 1)
		local new_stacks = (self._damage_dealt_to_cops or 0) * (tweak_data.gui.stats_present_multiplier or 10) * self:upgrade_value("player", "cocaine_stacking", 0)
		self._damage_dealt_to_cops = 0
		new_amount = new_amount + math.min(new_stacks, tweak_data.upgrades.max_cocaine_stacks_per_tick or 20)
	end

	if self._damage_dealt_to_cops_decay_t <= t then
		self._damage_dealt_to_cops_decay_t = t + (tweak_data.upgrades.cocaine_stacks_decay_t or 5)
		local decay = amount * (tweak_data.upgrades.cocaine_stacks_decay_percentage_per_tick or 0)
		decay = decay + (tweak_data.upgrades.cocaine_stacks_decay_amount_per_tick or 20) * self:upgrade_value("player", "cocaine_stacks_decay_multiplier", 1)
		new_amount = new_amount - decay
	end

	new_amount = math.clamp(math.floor(new_amount), 0, tweak_data.upgrades.max_total_cocaine_stacks or 2047)

	if new_amount ~= amount then
		self:update_synced_cocaine_stacks_to_peers(new_amount, self:upgrade_value("player", "sync_cocaine_upgrade_level", 1), self:upgrade_level("player", "cocaine_stack_absorption_multiplier", 0))
	end
end

function PlayerManager:on_damage_dealt(unit, damage_info)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	local t = Application:time()

	self:_check_damage_to_hot(t, unit, damage_info)
	self:_check_damage_to_cops(t, unit, damage_info)

	if self._on_damage_dealt_t and t < self._on_damage_dealt_t then
		return
	end

	self._on_damage_dealt_t = t + (tweak_data.upgrades.on_damage_dealt_cooldown or 0)
end

function PlayerManager:_check_damage_to_cops(t, unit, damage_info)
	local player_unit = self:player_unit()

	if alive(player_unit) and not player_unit:character_damage():need_revive() and player_unit:character_damage():dead() then
		-- Nothing
	end

	if not alive(unit) or not unit:base() or not damage_info then
		return
	end

	if damage_info.is_fire_dot_damage then
		return
	end

	if CopDamage.is_civilian(unit:base()._tweak_table) then
		return
	end

	self._damage_dealt_to_cops = self._damage_dealt_to_cops or 0
	self._damage_dealt_to_cops = self._damage_dealt_to_cops + (damage_info.damage or 0)
end

function PlayerManager:on_headshot_dealt()
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	self._message_system:notify(Message.OnHeadShot, nil, nil)

	local t = Application:time()

	if self._on_headshot_dealt_t and t < self._on_headshot_dealt_t then
		return
	end

	self._on_headshot_dealt_t = t + (tweak_data.upgrades.on_headshot_dealt_cooldown or 0)
	local damage_ext = player_unit:character_damage()
	local regen_armor_bonus = managers.player:upgrade_value("player", "headshot_regen_armor_bonus", 0)

	if damage_ext and regen_armor_bonus > 0 then
		damage_ext:restore_armor(regen_armor_bonus)
	end
end

function PlayerManager:on_lethal_headshot_dealt(attacker_unit, attack_data)
	if not self:player_unit() or attacker_unit ~= self:player_unit() then
		return
	end

	self._message_system:notify(Message.OnLethalHeadShot, nil, attack_data)
end

function PlayerManager:_check_damage_to_hot(t, unit, damage_info)
	local player_unit = self:player_unit()

	if not self:has_category_upgrade("player", "damage_to_hot") then
		return
	end

	if not alive(player_unit) or player_unit:character_damage():need_revive() or player_unit:character_damage():dead() then
		return
	end

	if not alive(unit) or not unit:base() or not damage_info then
		return
	end

	if damage_info.is_fire_dot_damage then
		return
	end

	local data = tweak_data.upgrades.damage_to_hot_data

	if not data then
		return
	end

	if self._next_allowed_doh_t and t < self._next_allowed_doh_t then
		return
	end

	local add_stack_sources = data.add_stack_sources or {}

	if not add_stack_sources.swat_van and unit:base().sentry_gun then
		return
	elseif not add_stack_sources.civilian and CopDamage.is_civilian(unit:base()._tweak_table) then
		return
	end

	if not add_stack_sources[damage_info.variant] then
		return
	end

	if not unit:brain():is_hostile() then
		return
	end

	local player_armor = managers.blackmarket:equipped_armor(data.works_with_armor_kit, true)

	if not table.contains(data.armors_allowed or {}, player_armor) then
		return
	end

	player_unit:character_damage():add_damage_to_hot()

	self._next_allowed_doh_t = t + data.stacking_cooldown
end

function PlayerManager:unaquire_equipment(upgrade, id)
	if not self._global.equipment[id] then
		return
	end

	local in_slot = self:equipment_slot(id)
	self._global.equipment[id] = nil

	if in_slot then
		self:set_equipment_in_slot(nil, in_slot)
		self:_verify_equipment_kit(false)
	end

	if upgrade.aquire then
		managers.upgrades:unaquire(upgrade.aquire.upgrade, UpgradesManager.AQUIRE_STRINGS[1])
	end
end

function PlayerManager:aquire_upgrade(upgrade)
	self._global.upgrades[upgrade.category] = self._global.upgrades[upgrade.category] or {}
	self._global.upgrades[upgrade.category][upgrade.upgrade] = math.max(upgrade.value, self._global.upgrades[upgrade.category][upgrade.upgrade] or 0)
	local value = tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][upgrade.value]

	if upgrade.synced then
		self._global.synced_upgrades[upgrade.category] = self._global.synced_upgrades[upgrade.category] or {}
		self._global.synced_upgrades[upgrade.category][upgrade.upgrade] = true
	end

	if self[upgrade.upgrade] then
		self[upgrade.upgrade](self, value)
	end
end

function PlayerManager:unaquire_upgrade(upgrade)
	if not self._global.upgrades[upgrade.category] then
		Application:error("[PlayerManager:unaquire_upgrade] Can't unaquire upgrade of category", upgrade.category)

		return
	end

	if not self._global.upgrades[upgrade.category][upgrade.upgrade] then
		Application:error("[PlayerManager:unaquire_upgrade] Can't unaquire upgrade", upgrade.upgrade)

		return
	end

	if upgrade.category == "player" and upgrade.upgrade == "second_deployable" then
		self:set_equipment_in_slot(nil, 2)
	end

	self:unaquire_incremental_upgrade(upgrade)
end

function PlayerManager:aquire_incremental_upgrade(upgrade)
	self._global.upgrades[upgrade.category] = self._global.upgrades[upgrade.category] or {}
	local val = self._global.upgrades[upgrade.category][upgrade.upgrade]
	self._global.upgrades[upgrade.category][upgrade.upgrade] = (val or 0) + 1
	local value = tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][self._global.upgrades[upgrade.category][upgrade.upgrade]]
	local last_value = tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][val or 0]

	if last_value and not value then
		if Application:production_build() then
			debug_pause("Trying to increment upgrade'" .. upgrade.category .. "." .. upgrade.upgrade .. "' beyond what is specified in tweak data!")
		end

		value = last_value
		tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][self._global.upgrades[upgrade.category][upgrade.upgrade]] = last_value
	end

	if upgrade.synced then
		self._global.synced_upgrades[upgrade.category] = self._global.synced_upgrades[upgrade.category] or {}
		self._global.synced_upgrades[upgrade.category][upgrade.upgrade] = true
	end

	if self[upgrade.upgrade] then
		self[upgrade.upgrade](self, value)
	end
end

function PlayerManager:unaquire_incremental_upgrade(upgrade)
	if not self._global.upgrades[upgrade.category] then
		Application:error("[PlayerManager:unaquire_incremental_upgrade] Can't unaquire upgrade of category", upgrade.category)

		return
	end

	if not self._global.upgrades[upgrade.category][upgrade.upgrade] then
		Application:error("[PlayerManager:unaquire_incremental_upgrade] Can't unaquire upgrade", upgrade.upgrade)

		return
	end

	local val = self._global.upgrades[upgrade.category][upgrade.upgrade]
	val = val - 1
	self._global.upgrades[upgrade.category][upgrade.upgrade] = val > 0 and val or nil
	local value = nil

	if self._global.upgrades[upgrade.category][upgrade.upgrade] then
		value = tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][self._global.upgrades[upgrade.category][upgrade.upgrade]]
	elseif upgrade.synced and self._global.synced_upgrades[upgrade.category] then
		self._global.synced_upgrades[upgrade.category][upgrade.upgrade] = nil
	end

	if self[upgrade.upgrade] then
		self[upgrade.upgrade](self, value)
	end
end

function PlayerManager:is_upgrade_synced(category, upgrade)
	return self._global.synced_upgrades[category] and self._global.synced_upgrades[category][upgrade]
end

function PlayerManager:temporary_upgrade_index(category, upgrade)
	if self._temporary_upgrade_indices and self._temporary_upgrade_indices[category .. upgrade] then
		return self._temporary_upgrade_indices[category .. upgrade]
	end

	self._synced_temporary_upgrades_count = self._synced_temporary_upgrades_count and self._synced_temporary_upgrades_count + 1 or 1
	self._temporary_upgrade_indices = self._temporary_upgrade_indices or {}
	self._temporary_upgrade_indices[category .. upgrade] = self._synced_temporary_upgrades_count

	return self._temporary_upgrade_indices[category .. upgrade]
end

function PlayerManager:upgrade_value(category, upgrade, default)
	if not self._global.upgrades[category] then
		return default or 0
	end

	if not self._global.upgrades[category][upgrade] then
		return default or 0
	end

	local level = self._global.upgrades[category][upgrade]
	local value = tweak_data.upgrades.values[category][upgrade][level]

	return value or value ~= false and (default or 0) or false
end

function PlayerManager:upgrade_value_nil(category, upgrade)
	local level = self._global.upgrades[category] and self._global.upgrades[category][upgrade]
	local value = level and tweak_data.upgrades.values[category][upgrade][level]

	return value
end

function PlayerManager:crew_ability_upgrade_value(upgrade, default)
	if not self._global.upgrades.team or not self._global.upgrades.team[upgrade] then
		return default or 0
	end

	local ai_level = self:upgrade_value("team", "crew_active", 0)
	local level = self._global.upgrades.team[upgrade]
	local value = tweak_data.upgrades.values.team[upgrade][level]

	print(level, value, ai_level)

	return value and value[ai_level] or default
end

function PlayerManager:start_custom_cooldown(category, upgrade, cooldown)
	self:start_timer(category .. "_" .. upgrade, cooldown)
end

function PlayerManager:is_custom_cooldown_not_active(category, upgrade)
	return self:has_category_upgrade(category, upgrade) and not self:has_active_timer(category .. "_" .. upgrade)
end

function PlayerManager:get_custom_cooldown_left(category, upgrade)
	return self:get_timer_remaining(category .. "_" .. upgrade)
end

function PlayerManager:consumable_upgrade_value(upgrade, default)
	if self._consumable_upgrades[upgrade] then
		local amount = self._consumable_upgrades[upgrade].amount

		if amount > 0 then
			local data = self._consumable_upgrades[upgrade].data
			amount = amount - 1

			if amount <= 0 then
				self._consumable_upgrades[upgrade] = nil
			else
				self._consumable_upgrades[upgrade].amount = amount
			end

			return data
		end
	end

	return default or 1
end

function PlayerManager:add_consumable_upgrade(upgrade, amount, data)
	self._consumable_upgrades[upgrade] = {
		amount = amount,
		data = data
	}
end

function PlayerManager:list_level_rewards(dlcs)
	return managers.upgrades:list_level_rewards(dlcs)
end

function PlayerManager:activate_temporary_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return
	end

	local time = upgrade_value[2]
	self._temporary_upgrades[category] = self._temporary_upgrades[category] or {}
	self._temporary_upgrades[category][upgrade] = {
		expire_time = Application:time() + time
	}

	if self:is_upgrade_synced(category, upgrade) then
		managers.network:session():send_to_peers("sync_temporary_upgrade_activated", self:temporary_upgrade_index(category, upgrade))
	end
end

function PlayerManager:extend_temporary_upgrade(category, upgrade, time)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return
	end

	local time = upgrade_value[2]
	local upgrade = self._temporary_upgrades[category][upgrade]
	upgrade.expire_time = upgrade_expire_time + time
end

function PlayerManager:activate_temporary_upgrade_by_level(category, upgrade, level)
	local upgrade_level = self:upgrade_level(category, upgrade, 0) or 0

	if level > upgrade_level then
		return
	end

	local upgrade_value = self:upgrade_value_by_level(category, upgrade, level, 0)

	if upgrade_value == 0 then
		return
	end

	local time = upgrade_value[2]
	self._temporary_upgrades[category] = self._temporary_upgrades[category] or {}
	self._temporary_upgrades[category][upgrade] = {
		upgrade_value = upgrade_value[1],
		expire_time = Application:time() + time
	}
end

function PlayerManager:deactivate_temporary_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return
	end

	if not self._temporary_upgrades[category] then
		return
	end

	self._temporary_upgrades[category][upgrade] = nil
end

function PlayerManager:has_activate_temporary_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return false
	end

	if not self._temporary_upgrades[category] then
		return false
	end

	if not self._temporary_upgrades[category][upgrade] then
		return false
	end

	return Application:time() < self._temporary_upgrades[category][upgrade].expire_time
end

function PlayerManager:has_inactivate_temporary_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return false
	end

	if not self._temporary_upgrades[category] then
		return true
	end

	if not self._temporary_upgrades[category][upgrade] then
		return true
	end

	return self._temporary_upgrades[category][upgrade].expire_time <= Application:time()
end

function PlayerManager:get_activate_temporary_expire_time(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return 0
	end

	if not self._temporary_upgrades[category] then
		return 0
	end

	if not self._temporary_upgrades[category][upgrade] then
		return 0
	end

	return self._temporary_upgrades[category][upgrade].expire_time or 0
end

function PlayerManager:temporary_upgrade_value(category, upgrade, default)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return default or 0
	end

	if not self._temporary_upgrades[category] then
		return default or 0
	end

	if not self._temporary_upgrades[category][upgrade] then
		return default or 0
	end

	if self._temporary_upgrades[category][upgrade].expire_time < Application:time() then
		return default or 0
	end

	if self._temporary_upgrades[category][upgrade].upgrade_value then
		return self._temporary_upgrades[category][upgrade].upgrade_value
	end

	return upgrade_value[1]
end

function PlayerManager:equiptment_upgrade_value(category, upgrade, default)
	return self:upgrade_value(category, upgrade, default)
end

function PlayerManager:aquire_cooldown_upgrade(upgrade)
	self:aquire_upgrade(upgrade)

	local upgrade_value = self:upgrade_value(upgrade.category, upgrade.upgrade)

	if upgrade_value == 0 then
		return
	end

	self._global.cooldown_upgrades[upgrade.category] = self._global.cooldown_upgrades[upgrade.category] or {}
	self._global.cooldown_upgrades[upgrade.category][upgrade.upgrade] = {
		cooldown_time = Application:time()
	}
end

function PlayerManager:unaquire_cooldown_upgrade(upgrade)
	self:unaquire_upgrade(upgrade)
end

function PlayerManager:disable_cooldown_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return
	end

	local time = upgrade_value[2]
	self._global.cooldown_upgrades[category] = self._global.cooldown_upgrades[category] or {}
	self._global.cooldown_upgrades[category][upgrade] = {
		cooldown_time = Application:time() + time
	}
end

function PlayerManager:has_disabled_cooldown_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return false
	end

	if not self._global.cooldown_upgrades[category] then
		return false
	end

	if not self._global.cooldown_upgrades[category][upgrade] then
		return false
	end

	return Application:time() < self._global.cooldown_upgrades[category][upgrade].cooldown_time
end

function PlayerManager:has_enabled_cooldown_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return false
	end

	if not self._global.cooldown_upgrades[category] then
		return true
	end

	if not self._global.cooldown_upgrades[category][upgrade] then
		return true
	end

	return self._global.cooldown_upgrades[category][upgrade].cooldown_time <= Application:time()
end

function PlayerManager:get_disabled_cooldown_time(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return 0
	end

	if not self._global.cooldown_upgrades[category] then
		return 0
	end

	if not self._global.cooldown_upgrades[category][upgrade] then
		return 0
	end

	return self._global.cooldown_upgrades[category][upgrade].cooldown_time or 0
end

function PlayerManager:cooldown_upgrade_value(category, upgrade, default)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return default or 0
	end

	if not self._global.cooldown_upgrades[category] then
		return default or 0
	end

	if not self._global.cooldown_upgrades[category][upgrade] then
		return default or 0
	end

	if Application:time() < self._global.cooldown_upgrades[category][upgrade].cooldown_time then
		return default or 0
	end

	if self._global.cooldown_upgrades[category][upgrade].upgrade_value then
		return self._global.cooldown_upgrades[category][upgrade].upgrade_value
	end

	return upgrade_value[1]
end

function PlayerManager:upgrade_level(category, upgrade, default)
	if not self._global.upgrades[category] then
		return default or 0
	end

	if not self._global.upgrades[category][upgrade] then
		return default or 0
	end

	local level = self._global.upgrades[category][upgrade]

	return level
end

function PlayerManager:upgrade_level_nil(category, upgrade)
	return self._global.upgrades[category] and self._global.upgrades[category][upgrade]
end

function PlayerManager:upgrade_value_by_level(category, upgrade, level, default)
	return tweak_data.upgrades.values[category][upgrade][level] or default or 0
end

function PlayerManager:equipped_upgrade_value(equipped, category, upgrade)
	if not self:has_category_upgrade(category, upgrade) then
		return 0
	end

	local equipment_list = self:equipment_slots()

	if not table.contains(equipment_list, equipped) then
		return 0
	end

	return self:upgrade_value(category, upgrade)
end

function PlayerManager:has_category_upgrade(category, upgrade)
	if not self._global.upgrades[category] then
		return false
	end

	if not self._global.upgrades[category][upgrade] then
		return false
	end

	return true
end

function PlayerManager:body_armor_value(category, override_value, default)
	local armor_data = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)]

	return self:upgrade_value_by_level("player", "body_armor", category, {})[override_value or armor_data.upgrade_level] or default or 0
end

function PlayerManager:get_infamy_exp_multiplier()
	local multiplier = 1

	if managers.experience:current_rank() > 0 then
		for infamy, item in pairs(tweak_data.infamy.items) do
			if managers.infamy:owned(infamy) and item.upgrades and item.upgrades.infamous_xp then
				multiplier = multiplier + math.abs(item.upgrades.infamous_xp - 1)
			end
		end
	end

	return multiplier
end

function PlayerManager:get_skill_exp_multiplier(whisper_mode)
	local multiplier = 1
	multiplier = multiplier + managers.player:upgrade_value("player", "xp_multiplier", 1) - 1
	multiplier = multiplier + managers.player:upgrade_value("player", "passive_xp_multiplier", 1) - 1
	multiplier = multiplier + managers.player:team_upgrade_value("xp", "multiplier", 1) - 1

	if whisper_mode then
		multiplier = multiplier + managers.player:team_upgrade_value("xp", "stealth_multiplier", 1) - 1
	end

	if managers.network:session() then
		local outfit, tweak = nil

		for _, peer in pairs(managers.network:session():all_peers()) do
			if peer:has_blackmarket_outfit() and not peer:is_cheater() then
				outfit = peer:blackmarket_outfit()

				for _, weapon in ipairs({
					"primary",
					"secondary"
				}) do
					if managers.weapon_factory:has_perk("bonus", outfit[weapon].factory_id, outfit[weapon].blueprint) then
						local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(outfit[weapon].factory_id, outfit[weapon].blueprint)

						if custom_stats then
							for part_id, stats in pairs(custom_stats) do
								if stats.exp_multiplier then
									multiplier = multiplier + stats.exp_multiplier - 1
								end
							end
						end
					elseif not managers.job:is_current_job_competitive() and outfit[weapon] and outfit[weapon].cosmetics and outfit[weapon].cosmetics.bonus then
						tweak = tweak_data.blackmarket.weapon_skins[outfit[weapon].cosmetics.id]
						tweak = tweak and tweak_data.economy.bonuses[tweak.bonus]

						if tweak and tweak.exp_multiplier then
							multiplier = multiplier + tweak.exp_multiplier - 1
						end
					end
				end
			end
		end
	end

	return multiplier
end

function PlayerManager:get_skill_money_multiplier(whisper_mode)
	local cash_skill_mulitplier = 1
	local bag_skill_mulitplier = 1
	bag_skill_mulitplier = bag_skill_mulitplier * managers.player:upgrade_value("player", "secured_bags_money_multiplier", 1)

	if whisper_mode then
		cash_skill_mulitplier = cash_skill_mulitplier * managers.player:team_upgrade_value("cash", "stealth_money_multiplier", 1)
		bag_skill_mulitplier = bag_skill_mulitplier * managers.player:team_upgrade_value("cash", "stealth_bags_multiplier", 1)
	end

	if managers.network:session() then
		local multiplier = 1
		local outfit, tweak = nil

		for _, peer in pairs(managers.network:session():all_peers()) do
			if peer:has_blackmarket_outfit() and not peer:is_cheater() then
				outfit = peer:blackmarket_outfit()

				for _, weapon in ipairs({
					"primary",
					"secondary"
				}) do
					if managers.weapon_factory:has_perk("bonus", outfit[weapon].factory_id, outfit[weapon].blueprint) then
						local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(outfit[weapon].factory_id, outfit[weapon].blueprint)

						if custom_stats then
							for part_id, stats in pairs(custom_stats) do
								if stats.exp_multiplier then
									multiplier = multiplier + stats.money_multiplier - 1
								end
							end
						end
					elseif not managers.job:is_current_job_competitive() and outfit[weapon] and outfit[weapon].cosmetics and outfit[weapon].cosmetics.bonus then
						tweak = tweak_data.blackmarket.weapon_skins[outfit[weapon].cosmetics.id]
						tweak = tweak and tweak_data.economy.bonuses[tweak.bonus]

						if tweak and tweak.money_multiplier then
							multiplier = multiplier + tweak.money_multiplier - 1
						end
					end
				end
			end
		end

		cash_skill_mulitplier = cash_skill_mulitplier * multiplier
		bag_skill_mulitplier = bag_skill_mulitplier * multiplier
	end

	return cash_skill_mulitplier, bag_skill_mulitplier
end

function PlayerManager:get_hostage_bonus_multiplier(category)
	local hostages = managers.groupai and managers.groupai:state():hostage_count() or 0
	local minions = self:num_local_minions() or 0
	local multiplier = 0
	hostages = hostages + minions
	local hostage_max_num = tweak_data:get_raw_value("upgrades", "hostage_max_num", category)

	if hostage_max_num then
		hostages = math.min(hostages, hostage_max_num)
	end

	multiplier = multiplier + self:team_upgrade_value(category, "hostage_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value(category, "passive_hostage_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "hostage_" .. category .. "_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "passive_hostage_" .. category .. "_multiplier", 1) - 1
	local local_player = self:local_player()

	if self:has_category_upgrade("player", "close_to_hostage_boost") and self._is_local_close_to_hostage then
		multiplier = multiplier * tweak_data.upgrades.hostage_near_player_multiplier
	end

	return 1 + multiplier * hostages
end

function PlayerManager:get_hostage_bonus_addend(category)
	local hostages = managers.groupai and managers.groupai:state():hostage_count() or 0
	local minions = self:num_local_minions() or 0
	local addend = 0
	hostages = hostages + minions
	local hostage_max_num = tweak_data:get_raw_value("upgrades", "hostage_max_num", category)

	if hostage_max_num then
		hostages = math.min(hostages, hostage_max_num)
	end

	addend = addend + self:team_upgrade_value(category, "hostage_addend", 0)
	addend = addend + self:team_upgrade_value(category, "passive_hostage_addend", 0)
	addend = addend + self:upgrade_value("player", "hostage_" .. category .. "_addend", 0)
	addend = addend + self:upgrade_value("player", "passive_hostage_" .. category .. "_addend", 0)
	local local_player = self:local_player()

	if self:has_category_upgrade("player", "close_to_hostage_boost") and self._is_local_close_to_hostage then
		addend = addend * tweak_data.upgrades.hostage_near_player_multiplier
	end

	return addend * hostages
end

function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
	local multiplier = 1
	local armor_penalty = self:mod_movement_penalty(self:body_armor_value("movement", upgrade_level, 1))
	multiplier = multiplier + armor_penalty - 1

	if bonus_multiplier then
		multiplier = multiplier + bonus_multiplier - 1
	end

	if speed_state then
		multiplier = multiplier + self:upgrade_value("player", speed_state .. "_speed_multiplier", 1) - 1
	end

	multiplier = multiplier + self:get_hostage_bonus_multiplier("speed") - 1
	multiplier = multiplier + self:upgrade_value("player", "movement_speed_multiplier", 1) - 1

	if self:num_local_minions() > 0 then
		multiplier = multiplier + self:upgrade_value("player", "minion_master_speed_multiplier", 1) - 1
	end

	if self:has_category_upgrade("player", "secured_bags_speed_multiplier") then
		local bags = 0
		bags = bags + (managers.loot:get_secured_mandatory_bags_amount() or 0)
		bags = bags + (managers.loot:get_secured_bonus_bags_amount() or 0)
		multiplier = multiplier + bags * (self:upgrade_value("player", "secured_bags_speed_multiplier", 1) - 1)
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") then
		multiplier = multiplier * (tweak_data.upgrades.berserker_movement_speed_multiplier or 1)
	end

	if health_ratio then
		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "movement_speed")
		multiplier = multiplier * (1 + managers.player:upgrade_value("player", "movement_speed_damage_health_ratio_multiplier", 0) * damage_health_ratio)
	end

	local damage_speed_multiplier = managers.player:temporary_upgrade_value("temporary", "damage_speed_multiplier", managers.player:temporary_upgrade_value("temporary", "team_damage_speed_multiplier_received", 1))
	multiplier = multiplier * damage_speed_multiplier

	return multiplier
end

function PlayerManager:mod_movement_penalty(movement_penalty)
	local skill_mods = self:upgrade_value("player", "passive_armor_movement_penalty_multiplier", 1)
	skill_mods = skill_mods * self:upgrade_value("team", "crew_reduce_speed_penalty", 1)

	if skill_mods < 1 and movement_penalty < 1 then
		local penalty = 1 - movement_penalty
		penalty = penalty * skill_mods
		movement_penalty = 1 - penalty
	end

	return movement_penalty
end

function PlayerManager:body_armor_skill_multiplier(override_armor)
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "tier_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "passive_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "armor_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("armor", "multiplier", 1) - 1
	multiplier = multiplier + self:get_hostage_bonus_multiplier("armor") - 1
	multiplier = multiplier + self:upgrade_value("player", "perk_armor_loss_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "chico_armor_multiplier", 1) - 1

	return multiplier
end

function PlayerManager:body_armor_regen_multiplier(moving, health_ratio)
	local multiplier = 1
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier_tier", 1)
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier", 1)
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier_passive", 1)
	multiplier = multiplier * self:team_upgrade_value("armor", "regen_time_multiplier", 1)
	multiplier = multiplier * self:team_upgrade_value("armor", "passive_regen_time_multiplier", 1)
	multiplier = multiplier * self:upgrade_value("player", "perk_armor_regen_timer_multiplier", 1)

	if not moving then
		multiplier = multiplier * managers.player:upgrade_value("player", "armor_regen_timer_stand_still_multiplier", 1)
	end

	if health_ratio then
		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "armor_regen")
		multiplier = multiplier * (1 - managers.player:upgrade_value("player", "armor_regen_damage_health_ratio_multiplier", 0) * damage_health_ratio)
	end

	return multiplier
end

function PlayerManager:body_armor_skill_addend(override_armor)
	local addend = 0
	addend = addend + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_addend", 0)

	if self:has_category_upgrade("player", "armor_increase") then
		local health_multiplier = self:health_skill_multiplier()
		local max_health = (PlayerDamage._HEALTH_INIT + self:health_skill_addend()) * health_multiplier
		addend = addend + max_health * self:upgrade_value("player", "armor_increase", 1)
	end

	addend = addend + self:upgrade_value("team", "crew_add_armor", 0)

	return addend
end

function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
	local chance = self:upgrade_value("player", "passive_dodge_chance", 0)
	local dodge_shot_gain = self:_dodge_shot_gain()

	for _, smoke_screen in ipairs(self._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(self:player_unit()) then
			if smoke_screen:mine() then
				chance = chance * self:upgrade_value("player", "sicario_multiplier", 1)
				dodge_shot_gain = dodge_shot_gain * self:upgrade_value("player", "sicario_multiplier", 1)
			else
				chance = chance + smoke_screen:dodge_bonus()
			end
		end
	end

	chance = chance + dodge_shot_gain
	chance = chance + self:upgrade_value("player", "tier_dodge_chance", 0)

	if running then
		chance = chance + self:upgrade_value("player", "run_dodge_chance", 0)
	end

	if crouching then
		chance = chance + self:upgrade_value("player", "crouch_dodge_chance", 0)
	end

	if on_zipline then
		chance = chance + self:upgrade_value("player", "on_zipline_dodge_chance", 0)
	end

	local detection_risk_add_dodge_chance = managers.player:upgrade_value("player", "detection_risk_add_dodge_chance")
	chance = chance + self:get_value_from_risk_upgrade(detection_risk_add_dodge_chance, detection_risk)
	chance = chance + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_dodge_addend", 0)
	chance = chance + self:upgrade_value("team", "crew_add_dodge", 0)
	chance = chance + self:temporary_upgrade_value("temporary", "pocket_ecm_kill_dodge", 0)

	return chance
end

function PlayerManager:stamina_multiplier()
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "stamina_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("stamina", "multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("stamina", "passive_multiplier", 1) - 1
	multiplier = multiplier + self:get_hostage_bonus_multiplier("stamina") - 1
	multiplier = managers.modifiers:modify_value("PlayerManager:GetStaminaMultiplier", multiplier)

	return multiplier
end

function PlayerManager:stamina_addend()
	local addend = 0
	addend = addend + self:upgrade_value("team", "crew_add_stamina", 0)

	return addend
end

function PlayerManager:critical_hit_chance()
	local multiplier = 0
	multiplier = multiplier + self:upgrade_value("player", "critical_hit_chance", 0)
	multiplier = multiplier + self:upgrade_value("weapon", "critical_hit_chance", 0)
	multiplier = multiplier + self:team_upgrade_value("critical_hit", "chance", 0)
	multiplier = multiplier + self:get_hostage_bonus_multiplier("critical_hit") - 1
	multiplier = multiplier + managers.player:temporary_upgrade_value("temporary", "unseen_strike", 1) - 1
	multiplier = multiplier + self._crit_mul - 1
	local detection_risk_add_crit_chance = managers.player:upgrade_value("player", "detection_risk_add_crit_chance")
	multiplier = multiplier + self:get_value_from_risk_upgrade(detection_risk_add_crit_chance)

	return multiplier
end

function PlayerManager:get_value_from_risk_upgrade(risk_upgrade, detection_risk)
	local risk_value = 0

	if not detection_risk then
		detection_risk = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
		detection_risk = math.round(detection_risk * 100)
	end

	if risk_upgrade and type(risk_upgrade) == "table" then
		local value = risk_upgrade[1]
		local step = risk_upgrade[2]
		local operator = risk_upgrade[3]
		local threshold = risk_upgrade[4]
		local cap = risk_upgrade[5]
		local num_steps = 0

		if operator == "above" then
			num_steps = math.max(math.floor((detection_risk - threshold) / step), 0)
		elseif operator == "below" then
			num_steps = math.max(math.floor((threshold - detection_risk) / step), 0)
		end

		risk_value = num_steps * value

		if cap then
			risk_value = math.min(cap, risk_value) or risk_value
		end
	end

	return risk_value
end

function PlayerManager:health_skill_multiplier()
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "health_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "passive_health_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("health", "passive_multiplier", 1) - 1
	multiplier = multiplier + self:get_hostage_bonus_multiplier("health") - 1
	multiplier = multiplier - self:upgrade_value("player", "health_decrease", 0)

	if self:num_local_minions() > 0 then
		multiplier = multiplier + self:upgrade_value("player", "minion_master_health_multiplier", 1) - 1
	end

	return multiplier
end

function PlayerManager:health_regen()
	local health_regen = tweak_data.player.damage.HEALTH_REGEN
	health_regen = health_regen + self:temporary_upgrade_value("temporary", "wolverine_health_regen", 0)
	health_regen = health_regen + self:get_hostage_bonus_addend("health_regen")
	health_regen = health_regen + self:upgrade_value("player", "passive_health_regen", 0)

	return health_regen
end

function PlayerManager:fixed_health_regen(health_ratio)
	local health_regen = 0

	if not health_ratio or not self:is_damage_health_ratio_active(health_ratio) then
		health_regen = health_regen + self:upgrade_value("team", "crew_health_regen", 0)
	end

	return health_regen
end

function PlayerManager:max_health()
	local base_health = PlayerDamage._HEALTH_INIT
	local health = (base_health + self:health_skill_addend()) * self:health_skill_multiplier()

	return health
end

function PlayerManager:damage_reduction_skill_multiplier(damage_type)
	local multiplier = 1
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_outnumbered", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_outnumbered_strong", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_close_contact", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "revived_damage_resist", 1)
	multiplier = multiplier * self:upgrade_value("player", "damage_dampener", 1)
	multiplier = multiplier * self:upgrade_value("player", "health_damage_reduction", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "first_aid_damage_reduction", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "revive_damage_reduction", 1)
	multiplier = multiplier * self:get_hostage_bonus_multiplier("damage_dampener")
	multiplier = multiplier * self._properties:get_property("revive_damage_reduction", 1)
	multiplier = multiplier * self._temporary_properties:get_property("revived_damage_reduction", 1)
	local dmg_red_mul = self:team_upgrade_value("damage_dampener", "team_damage_reduction", 1)

	if self:has_category_upgrade("player", "passive_damage_reduction") then
		local health_ratio = self:player_unit():character_damage():health_ratio()
		local min_ratio = self:upgrade_value("player", "passive_damage_reduction")

		if health_ratio < min_ratio then
			dmg_red_mul = dmg_red_mul - (1 - dmg_red_mul)
		end
	end

	multiplier = multiplier * dmg_red_mul

	if damage_type == "melee" then
		multiplier = multiplier * managers.player:upgrade_value("player", "melee_damage_dampener", 1)
	end

	local current_state = self:get_current_state()

	if current_state and current_state:_interacting() then
		multiplier = multiplier * managers.player:upgrade_value("player", "interacting_damage_multiplier", 1)
	end

	return multiplier
end

function PlayerManager:health_skill_addend()
	local addend = 0
	addend = addend + self:upgrade_value("team", "crew_add_health", 0)

	if table.contains(self._global.kit.equipment_slots, "thick_skin") then
		addend = addend + self:upgrade_value("player", "thick_skin", 0)
	end

	return addend
end

function PlayerManager:toolset_value()
	if not self:has_category_upgrade("player", "toolset") then
		return 1
	end

	if not table.contains(self._global.kit.equipment_slots, "toolset") then
		return 1
	end

	return self:upgrade_value("player", "toolset")
end

function PlayerManager:inspect_current_upgrades()
	for name, upgrades in pairs(self._global.upgrades) do
		print("Weapon " .. name .. ":")

		for upgrade, level in pairs(upgrades) do
			print("Upgrade:", upgrade, "is at level", level, "and has value", string.format("%.2f", tweak_data.upgrades.values[name][upgrade][level]))
		end

		print("\n")
	end
end

function PlayerManager:spread_multiplier()
	if not alive(self:player_unit()) then
		return
	end

	self:player_unit():movement()._current_state:_update_crosshair_offset()
end

function PlayerManager:weapon_upgrade_progress(weapon_id)
	local current = 0
	local total = 0

	if self._global.upgrades[weapon_id] then
		for upgrade, value in pairs(self._global.upgrades[weapon_id]) do
			current = current + value
		end
	end

	if tweak_data.upgrades.values[weapon_id] then
		for _, values in pairs(tweak_data.upgrades.values[weapon_id]) do
			total = total + #values
		end
	end

	return current, total
end

function PlayerManager:equipment_upgrade_progress(equipment_id)
	local current = 0
	local total = 0

	if tweak_data.upgrades.values[equipment_id] then
		if self._global.upgrades[equipment_id] then
			for upgrade, value in pairs(self._global.upgrades[equipment_id]) do
				current = current + value
			end
		end

		for _, values in pairs(tweak_data.upgrades.values[equipment_id]) do
			total = total + #values
		end

		return current, total
	end

	if tweak_data.upgrades.values.player[equipment_id] then
		if self._global.upgrades.player and self._global.upgrades.player[equipment_id] then
			current = self._global.upgrades.player[equipment_id]
		end

		total = #tweak_data.upgrades.values.player[equipment_id]

		return current, total
	end

	if tweak_data.upgrades.definitions[equipment_id] and tweak_data.upgrades.definitions[equipment_id].aquire then
		local upgrade = tweak_data.upgrades.definitions[tweak_data.upgrades.definitions[equipment_id].aquire.upgrade]

		return self:equipment_upgrade_progress(upgrade.upgrade.upgrade)
	end

	return current, total
end

function PlayerManager:has_weapon(name)
	return managers.player._global.weapons[name]
end

function PlayerManager:has_aquired_equipment(name)
	return managers.player._global.equipment[name]
end

function PlayerManager:availible_weapons(slot)
	local weapons = {}

	for name, _ in pairs(managers.player._global.weapons) do
		if not slot or slot and tweak_data.weapon[name].use_data.selection_index == slot then
			table.insert(weapons, name)
		end
	end

	return weapons
end

function PlayerManager:weapon_in_slot(slot)
	local weapon = self._global.kit.weapon_slots[slot]

	if self._global.weapons[weapon] then
		return weapon
	end

	local weapon = self._global.default_kit.weapon_slots[slot]

	return self._global.weapons[weapon] and weapon
end

function PlayerManager:availible_equipment(slot)
	local equipment = {}

	for name, _ in pairs(self._global.equipment) do
		if not slot or slot and tweak_data.upgrades.definitions[name].slot == slot then
			table.insert(equipment, name)
		end
	end

	return equipment
end

function PlayerManager:equipment_in_slot(slot)
	local forced_deployable = managers.blackmarket:forced_deployable()

	if forced_deployable then
		return slot == 1 and forced_deployable ~= "none" and forced_deployable
	end

	return self._global.kit.equipment_slots[slot]
end

function PlayerManager:set_equipment_in_slot(item, slot)
	self._global.kit.equipment_slots[slot or 1] = item

	if item then
		managers.story:award("story_inv_deployable")
	end
end

function PlayerManager:equipment_slots()
	local forced_deployable = managers.blackmarket:forced_deployable()

	if forced_deployable then
		return forced_deployable ~= "none" and {
			forced_deployable
		} or {}
	end

	return self._global.kit.equipment_slots
end

function PlayerManager:equipment_slot(equipment)
	for i = 1, #self._global.kit.equipment_slots, 1 do
		if self._global.kit.equipment_slots[i] == equipment then
			return i
		end
	end

	return false
end

function PlayerManager:toggle_player_rule(rule)
	self._rules[rule] = not self._rules[rule]

	if rule == "no_run" and self._rules[rule] then
		local player = self:player_unit()

		if player:movement():current_state()._interupt_action_running then
			player:movement():current_state():_interupt_action_running(Application:time())
		end
	end
end

function PlayerManager:set_player_rule(rule, value)
	self._rules[rule] = self._rules[rule] + (value and 1 or -1)

	if rule == "no_run" and self:get_player_rule(rule) then
		local player = self:player_unit()

		if player:movement():current_state()._interupt_action_running then
			player:movement():current_state():_interupt_action_running(Application:time())
		end
	end
end

function PlayerManager:get_player_rule(rule)
	return self._rules[rule] > 0
end

function PlayerManager:has_deployable_been_used()
	return self._peer_used_deployable or false
end

function PlayerManager:update_deployable_equipment_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_deployables[peer_id] then
		local deployable = self._global.synced_deployables[peer_id].deployable
		local amount = self._global.synced_deployables[peer_id].amount

		peer:send_queued_sync("sync_deployable_equipment", deployable, amount)
	end
end

function PlayerManager:update_deployable_equipment_amount_to_peers(equipment, amount)
	local peer = managers.network:session():local_peer()

	managers.network:session():send_to_peers_synched("sync_deployable_equipment", equipment, amount)
	self:set_synced_deployable_equipment(peer, equipment, amount)
end

function PlayerManager:update_deployable_selection_to_peers()
	local equipment = self:selected_equipment()

	if equipment then
		local amount = Application:digest_value(equipment.amount[1], false)

		self:update_deployable_equipment_amount_to_peers(equipment.equipment, amount)
	end
end

function PlayerManager:set_synced_deployable_equipment(peer, deployable, amount)
	local peer_id = peer:id()
	local only_update_amount = self._global.synced_deployables[peer_id] and self._global.synced_deployables[peer_id].deployable == deployable

	if not self._peer_used_deployable and self._global.synced_deployables[peer_id] and (self._global.synced_deployables[peer_id].deployable ~= deployable or self._global.synced_deployables[peer_id].amount ~= amount) then
		self._peer_used_deployable = true
	end

	self._global.synced_deployables[peer_id] = {
		deployable = deployable,
		amount = amount
	}
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		local icon = tweak_data.equipments[deployable].icon

		if only_update_amount then
			managers.hud:set_teammate_deployable_equipment_amount(character_data.panel_id, 1, {
				icon = icon,
				amount = amount
			})
		else
			managers.hud:set_deployable_equipment(character_data.panel_id, {
				icon = icon,
				amount = amount
			})
		end
	end

	local local_peer_id = managers.network:session():local_peer():id()

	if peer_id ~= local_peer_id then
		local unit = peer:unit()

		if alive(unit) then
			unit:movement():set_visual_deployable_equipment(deployable, amount)
		end
	end
end

function PlayerManager:get_synced_deployable_equipment(peer_id)
	return self._global.synced_deployables[peer_id]
end

function PlayerManager:update_cable_ties_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_cable_ties[peer_id] then
		local amount = self._global.synced_cable_ties[peer_id].amount

		peer:send_queued_sync("sync_cable_ties", amount)
	end
end

function PlayerManager:update_synced_cable_ties_to_peers(amount)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_cable_ties", amount)
	self:set_synced_cable_ties(peer_id, amount)
end

function PlayerManager:set_synced_cable_ties(peer_id, amount)
	local only_update_amount = false

	if self._global.synced_cable_ties[peer_id] and amount < self._global.synced_cable_ties[peer_id].amount and managers.network:session() and managers.network:session():peer(peer_id) then
		local peer = managers.network:session():peer(peer_id)

		peer:on_used_cable_tie()
	end

	self._global.synced_cable_ties[peer_id] = {
		amount = amount
	}
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		local icon = tweak_data.equipments.specials.cable_tie.icon

		if only_update_amount then
			managers.hud:set_cable_ties_amount(character_data.panel_id, amount)
		else
			managers.hud:set_cable_tie(character_data.panel_id, {
				icon = icon,
				amount = amount
			})
		end
	end
end

function PlayerManager:get_synced_cable_ties(peer_id)
	return self._global.synced_cable_ties[peer_id]
end

function PlayerManager:update_ammo_info_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_ammo_info[peer_id] then
		for selection_index, ammo_info in pairs(self._global.synced_ammo_info[peer_id]) do
			peer:send_queued_sync("sync_ammo_amount", selection_index, unpack(ammo_info))
		end
	end
end

function PlayerManager:update_synced_ammo_info_to_peers(selection_index, max_clip, current_clip, current_left, max)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_ammo_amount", selection_index, max_clip, current_clip, current_left, max)
	self:set_synced_ammo_info(peer_id, selection_index, max_clip, current_clip, current_left, max)
end

function PlayerManager:set_synced_ammo_info(peer_id, selection_index, max_clip, current_clip, current_left, max)
	self._global.synced_ammo_info[peer_id] = self._global.synced_ammo_info[peer_id] or {}
	self._global.synced_ammo_info[peer_id][selection_index] = {
		max_clip,
		current_clip,
		current_left,
		max
	}
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		managers.hud:set_teammate_ammo_amount(character_data.panel_id, selection_index, max_clip, current_clip, current_left, max)
	end
end

function PlayerManager:get_synced_ammo_info(peer_id)
	return self._global.synced_ammo_info[peer_id]
end

function PlayerManager:update_carry_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_carry[peer_id] then
		local carry_id = self._global.synced_carry[peer_id].carry_id
		local multiplier = self._global.synced_carry[peer_id].multiplier
		local dye_initiated = self._global.synced_carry[peer_id].dye_initiated
		local has_dye_pack = self._global.synced_carry[peer_id].has_dye_pack
		local dye_value_multiplier = self._global.synced_carry[peer_id].dye_value_multiplier

		peer:send_queued_sync("sync_carry", carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	end
end

function PlayerManager:update_synced_carry_to_peers(carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	local peer = managers.network:session():local_peer()

	managers.network:session():send_to_peers_synched("sync_carry", carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	self:set_synced_carry(peer, carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
end

function PlayerManager:set_synced_carry(peer, carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	local peer_id = peer:id()
	self._global.synced_carry[peer_id] = {
		carry_id = carry_id,
		multiplier = multiplier,
		dye_initiated = dye_initiated,
		has_dye_pack = has_dye_pack,
		dye_value_multiplier = dye_value_multiplier
	}
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		managers.hud:set_teammate_carry_info(character_data.panel_id, carry_id, managers.loot:get_real_value(carry_id, multiplier))
	end

	managers.hud:set_name_label_carry_info(peer_id, carry_id, managers.loot:get_real_value(carry_id, multiplier))

	local local_peer_id = managers.network:session():local_peer():id()

	if peer_id ~= local_peer_id then
		local unit = peer:unit()

		if alive(unit) then
			unit:movement():set_visual_carry(carry_id)
		end
	end
end

function PlayerManager:set_carry_approved(peer)
	self._global.synced_carry[peer:id()].approved = true
end

function PlayerManager:update_removed_synced_carry_to_peers()
	local peer = managers.network:session():local_peer()

	managers.network:session():send_to_peers_synched("sync_remove_carry")
	self:remove_synced_carry(peer)
end

function PlayerManager:remove_synced_carry(peer)
	local peer_id = peer:id()

	if not self._global.synced_carry[peer_id] then
		return
	end

	self._global.synced_carry[peer_id] = nil
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		managers.hud:remove_teammate_carry_info(character_data.panel_id)
	end

	managers.hud:remove_name_label_carry_info(peer_id)

	local local_peer_id = managers.network:session():local_peer():id()

	if peer_id ~= local_peer_id then
		local unit = peer:unit()

		if alive(unit) then
			unit:movement():set_visual_carry(nil)
		end
	end
end

function PlayerManager:get_my_carry_data()
	local peer_id = managers.network:session():local_peer():id()

	return self._global.synced_carry[peer_id]
end

function PlayerManager:get_synced_carry(peer_id)
	return self._global.synced_carry[peer_id]
end

function PlayerManager:from_server_interaction_reply(status)
	self:player_unit():movement():set_carry_restriction(false)

	if not status then
		self:clear_carry()
	end
end

function PlayerManager:get_all_synced_carry()
	return self._global.synced_carry
end

function PlayerManager:aquire_team_upgrade(upgrade)
	self._global.team_upgrades[upgrade.category] = self._global.team_upgrades[upgrade.category] or {}
	self._global.team_upgrades[upgrade.category][upgrade.upgrade] = upgrade.value
end

function PlayerManager:unaquire_team_upgrade(upgrade)
	if not self._global.team_upgrades[upgrade.category] then
		Application:error("[PlayerManager:unaquire_team_upgrade] Can't unaquire team upgrade of category", upgrade.category)

		return
	end

	if not self._global.team_upgrades[upgrade.category][upgrade.upgrade] then
		Application:error("[PlayerManager:unaquire_team_upgrade] Can't unaquire team upgrade", upgrade.upgrade)

		return
	end

	local val = self._global.team_upgrades[upgrade.category][upgrade.upgrade]
	val = val - 1
	self._global.team_upgrades[upgrade.category][upgrade.upgrade] = val > 0 and val or nil
end

function PlayerManager:team_upgrade_value(category, upgrade, default)
	for peer_id, categories in pairs(self._global.synced_team_upgrades) do
		if categories[category] and categories[category][upgrade] then
			local level = categories[category][upgrade]

			return tweak_data.upgrades.values.team[category][upgrade][level]
		end
	end

	if not self._global.team_upgrades[category] then
		return default or 0
	end

	if not self._global.team_upgrades[category][upgrade] then
		return default or 0
	end

	local level = self._global.team_upgrades[category][upgrade]
	local value = tweak_data.upgrades.values.team[category][upgrade][level]

	return value
end

function PlayerManager:has_team_category_upgrade(category, upgrade)
	for peer_id, categories in pairs(self._global.synced_team_upgrades) do
		if categories[category] and categories[category][upgrade] then
			return true
		end
	end

	if not self._global.team_upgrades[category] then
		return false
	end

	if not self._global.team_upgrades[category][upgrade] then
		return false
	end

	return true
end

function PlayerManager:get_contour_for_marked_enemy(enemy_type)
	local contour_type = "mark_enemy"

	if enemy_type == "swat_turret" or enemy_type == "sentry_gun" then
		contour_type = "mark_unit_dangerous"

		if managers.player:has_category_upgrade("player", "marked_enemy_extra_damage") then
			contour_type = "mark_unit_dangerous_damage_bonus"
		end

		if managers.player:has_category_upgrade("player", "marked_inc_dmg_distance") then
			contour_type = "mark_unit_dangerous_damage_bonus_distance"

			if "mark_unit_dangerous_damage_bonus_distance" then
				-- Nothing
			end
		end
	else
		if managers.player:has_category_upgrade("player", "marked_enemy_extra_damage") then
			contour_type = "mark_enemy_damage_bonus"
		end

		if managers.player:has_category_upgrade("player", "marked_inc_dmg_distance") then
			contour_type = "mark_enemy_damage_bonus_distance"
		end
	end

	return contour_type
end

function PlayerManager:update_team_upgrades_to_peers()
	for category, upgrades in pairs(self._global.team_upgrades) do
		for upgrade, level in pairs(upgrades) do
			managers.network:session():send_to_peers_synched("add_synced_team_upgrade", category, upgrade, level)
		end
	end
end

function PlayerManager:update_team_upgrades_to_peer(peer)
	for category, upgrades in pairs(self._global.team_upgrades) do
		for upgrade, level in pairs(upgrades) do
			peer:send_queued_sync("add_synced_team_upgrade", category, upgrade, level)
		end
	end
end

function PlayerManager:add_synced_team_upgrade(peer_id, category, upgrade, level)
	self._global.synced_team_upgrades[peer_id] = self._global.synced_team_upgrades[peer_id] or {}
	self._global.synced_team_upgrades[peer_id][category] = self._global.synced_team_upgrades[peer_id][category] or {}
	self._global.synced_team_upgrades[peer_id][category][upgrade] = level
end

function PlayerManager:activate_synced_temporary_team_upgrade(peer_id, category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		local new_upgrade = {
			category = category,
			upgrade = upgrade,
			value = 1
		}

		self:aquire_upgrade(new_upgrade)
	end

	self:activate_temporary_upgrade(category, upgrade)
end

function PlayerManager:send_activate_temporary_team_upgrade_to_peers(category, upgrade)
	managers.network:session():send_to_peers_synched("activate_temporary_team_upgrade", category, upgrade)
end

function PlayerManager:send_activate_temporary_team_upgrade_to_peer(peer, category, upgrade)
	peer:send_queued_sync("activate_temporary_team_upgrade", category, upgrade)
end

function PlayerManager:update_cocaine_stacks_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_cocaine_stacks[peer_id] then
		local amount = self._global.synced_cocaine_stacks[peer_id].amount or 0
		local upgrade_level = self._global.synced_cocaine_stacks[peer_id].upgrade_level or 1
		local power_level = self._global.synced_cocaine_stacks[peer_id].power_level or 1

		peer:send_queued_sync("sync_cocaine_stacks", amount, self:has_category_upgrade("player", "sync_cocaine_stacks"), upgrade_level, power_level)
	end
end

function PlayerManager:update_synced_cocaine_stacks_to_peers(amount, upgrade_level, power_level)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_cocaine_stacks", amount, self:has_category_upgrade("player", "sync_cocaine_stacks"), upgrade_level, power_level)
	self:set_synced_cocaine_stacks(peer_id, amount, true, upgrade_level, power_level)
end

function PlayerManager:set_synced_cocaine_stacks(peer_id, amount, in_use, upgrade_level, power_level)
	self._global.synced_cocaine_stacks[peer_id] = {
		amount = amount,
		in_use = in_use,
		upgrade_level = upgrade_level,
		power_level = power_level
	}
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and in_use then
		managers.hud:set_info_meter(character_data.panel_id, {
			icon = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_icon_01",
			max = 1,
			current = self:get_peer_cocaine_damage_absorption_ratio(peer_id),
			total = self:get_peer_cocaine_damage_absorption_max_ratio(peer_id)
		})
	end

	self:update_cocaine_hud()
end

function PlayerManager:update_cocaine_hud()
	if managers.hud then
		managers.hud:set_absorb_active(HUDManager.PLAYER_PANEL, self:damage_absorption())
	end
end

function PlayerManager:get_synced_cocaine_stacks(peer_id)
	return self._global.synced_cocaine_stacks[peer_id]
end

function PlayerManager:get_cocaine_damage_absorption_from_peer_id(peer_id, multiplier_peer_id)
	local data = self._global.synced_cocaine_stacks[peer_id] or {}
	local absorption = self:_get_cocaine_damage_absorption_from_data(data)
	local data = self._global.synced_cocaine_stacks[multiplier_peer_id or peer_id] or {}
	local multiplier = self:upgrade_value_by_level("player", "cocaine_stack_absorption_multiplier", data.power_level or 0, 1)

	return absorption * multiplier
end

function PlayerManager:_get_cocaine_damage_absorption_from_data(data)
	local amount = data.amount or 0
	local upgrade_level = data.upgrade_level or 1

	if amount == 0 then
		return 0
	end

	return amount / (tweak_data.upgrades.cocaine_stacks_convert_levels and tweak_data.upgrades.cocaine_stacks_convert_levels[upgrade_level] or 20) * (tweak_data.upgrades.cocaine_stacks_dmg_absorption_value or 0.1)
end

function PlayerManager:get_best_cocaine_damage_absorption(my_peer_id)
	local data = self._global.synced_cocaine_stacks[my_peer_id] or {}
	local multiplier = self:upgrade_value_by_level("player", "cocaine_stack_absorption_multiplier", data.power_level or 0, 1)
	local absorption = 0
	local best_peer_id = 0

	if self._global.synced_cocaine_stacks then
		local peer_absorption = nil

		for peer_id, data in pairs(self._global.synced_cocaine_stacks) do
			if peer_id == my_peer_id or data.in_use then
				peer_absorption = self:_get_cocaine_damage_absorption_from_data(data)

				if absorption < peer_absorption then
					best_peer_id = peer_id or best_peer_id
				end

				absorption = math.max(absorption, peer_absorption)
			end
		end
	end

	return absorption * multiplier, best_peer_id
end

function PlayerManager:get_local_cocaine_damage_absorption_max()
	local upgrade_tweak = tweak_data.upgrades
	local amount = upgrade_tweak.max_total_cocaine_stacks or 2047
	local upgrade_level = upgrade_tweak.cocaine_stacks_convert_levels and #upgrade_tweak.cocaine_stacks_convert_levels or 1
	local multiplier = self:upgrade_value("player", "cocaine_stack_absorption_multiplier", 1)
	local max_absorption = math.max(self:_get_cocaine_damage_absorption_from_data({
		amount = amount,
		upgrade_level = upgrade_level
	}), 1)

	return max_absorption * multiplier
end

function PlayerManager:get_best_cocaine_damage_absorption_ratio()
	local best_ratio = 0

	for peer_id, data in pairs(self._global.synced_cocaine_stacks) do
		best_ratio = math.max(self:get_peer_cocaine_damage_absorption_ratio(peer_id), best_ratio)
	end

	return best_ratio
end

function PlayerManager:_get_best_max_cocaine_damage_absorption_ratio()
	local upgrade_tweak = tweak_data.upgrades
	local amount = upgrade_tweak.max_total_cocaine_stacks or 2047
	local upgrade_level = upgrade_tweak.cocaine_stacks_convert_levels and #upgrade_tweak.cocaine_stacks_convert_levels or 1
	local multiplier = upgrade_tweak.values.player.cocaine_stack_absorption_multiplier and upgrade_tweak.values.player.cocaine_stack_absorption_multiplier[#upgrade_tweak.values.player.cocaine_stack_absorption_multiplier] or 1
	local max_absorption = math.max(self:_get_cocaine_damage_absorption_from_data({
		amount = amount,
		upgrade_level = upgrade_level
	}), 1) * multiplier

	return max_absorption
end

function PlayerManager:get_peer_cocaine_damage_absorption_ratio(peer_id)
	local max_absorption = self:_get_best_max_cocaine_damage_absorption_ratio()
	local data = self._global.synced_cocaine_stacks[peer_id] or {}
	local multiplier = self:upgrade_value_by_level("player", "cocaine_stack_absorption_multiplier", data.power_level or 0, 1)
	local absorption = self:_get_cocaine_damage_absorption_from_data(data) * multiplier

	return math.clamp(absorption / max_absorption, 0, 1)
end

function PlayerManager:get_peer_cocaine_damage_absorption_max_ratio(peer_id)
	local upgrade_tweak = tweak_data.upgrades
	local max_absorption = self:_get_best_max_cocaine_damage_absorption_ratio()
	local data = self._global.synced_cocaine_stacks[peer_id] or {}
	local upgrade_level = data.upgrade_level or 1
	local amount = upgrade_tweak.max_total_cocaine_stacks or 2047
	local multiplier = self:upgrade_value_by_level("player", "cocaine_stack_absorption_multiplier", data.power_level or 0, 1)
	local absorption = self:_get_cocaine_damage_absorption_from_data({
		amount = amount,
		upgrade_level = upgrade_level
	}) * multiplier

	return math.clamp(absorption / max_absorption, 0, 1)
end

function PlayerManager:get_local_cocaine_damage_absorption_ratio()
	local peer_id = managers.network:session():local_peer():id()

	return self:get_peer_cocaine_damage_absorption_ratio(peer_id)
end

function PlayerManager:get_local_cocaine_damage_absorption_max_ratio()
	local peer_id = managers.network:session():local_peer():id()

	return self:get_peer_cocaine_damage_absorption_max_ratio(peer_id)
end

function PlayerManager:remove_equipment_possession(peer_id, equipment)
	if not self._global.synced_equipment_possession[peer_id] then
		return
	end

	self._global.synced_equipment_possession[peer_id][equipment] = nil
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		managers.hud:remove_teammate_special_equipment(character_data.panel_id, equipment)
	end
end

function PlayerManager:get_synced_equipment_possession(peer_id)
	return self._global.synced_equipment_possession[peer_id]
end

function PlayerManager:update_equipment_possession_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_equipment_possession[peer_id] then
		for name, amount in pairs(self._global.synced_equipment_possession[peer_id]) do
			peer:send_queued_sync("sync_equipment_possession", peer_id, name, amount)
		end
	end
end

function PlayerManager:update_equipment_possession_to_peers(equipment, amount)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_equipment_possession", peer_id, equipment, amount or 1)
	self:set_synced_equipment_possession(peer_id, equipment, amount)
end

function PlayerManager:set_synced_equipment_possession(peer_id, equipment, amount)
	local only_update_amount = self._global.synced_equipment_possession[peer_id] and self._global.synced_equipment_possession[peer_id][equipment]
	self._global.synced_equipment_possession[peer_id] = self._global.synced_equipment_possession[peer_id] or {}
	self._global.synced_equipment_possession[peer_id][equipment] = amount or 1
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		local equipment_data = tweak_data.equipments.specials[equipment]
		local icon = equipment_data.icon

		if only_update_amount then
			managers.hud:set_teammate_special_equipment_amount(character_data.panel_id, equipment, amount)
		else
			managers.hud:add_teammate_special_equipment(character_data.panel_id, {
				id = equipment,
				icon = icon,
				amount = amount
			})
		end
	end
end

function PlayerManager:transfer_from_custody_special_equipment_to(target_id)
	local local_peer = managers.network:session():local_peer()
	local local_peer_id = local_peer:id()

	for id, possessions in pairs(self._global.synced_equipment_possession) do
		if id ~= target_id and managers.trade:is_peer_in_custody(id) then
			for name, amount in pairs(possessions) do
				local equipment_data = tweak_data.equipments.specials[name]

				if equipment_data and not equipment_data.avoid_tranfer then
					local max_amount = equipment_data.transfer_quantity or 1
					local amount_to_transfer = amount
					local targets_amount = self._global.synced_equipment_possession[target_id] and self._global.synced_equipment_possession[target_id][name] or 0

					if max_amount > targets_amount then
						local transfer_amount = math.min(amount_to_transfer, max_amount - targets_amount)
						amount_to_transfer = amount_to_transfer - transfer_amount

						if Network:is_server() then
							if target_id == local_peer_id then
								managers.player:add_special({
									transfer = true,
									name = name,
									amount = transfer_amount
								})
							else
								local peer = managers.network:session():peer(target_id)

								if peer then
									peer:send("give_equipment", name, transfer_amount, true)
								else
									transfer_amount = 0

									debug_pause("[PlayerManager:transfer_from_custody_special_equipment_to] Failed to get peer from id!")
								end
							end
						end

						if id == local_peer_id then
							for i = 1, amount - amount_to_transfer, 1 do
								self:remove_special(name)
							end
						end
					end
				end
			end
		end
	end
end

function PlayerManager:on_sole_criminal_respawned(peer_id)
	if managers.groupai:state():num_alive_players() > 1 or managers.trade:is_peer_in_custody(peer_id) then
		return
	end

	self:transfer_from_custody_special_equipment_to(peer_id)
end

function PlayerManager:transfer_special_equipment(peer_id, include_custody)
	if self._global.synced_equipment_possession[peer_id] then
		local local_peer = managers.network:session():local_peer()
		local local_peer_id = local_peer:id()
		local peers = {}
		local peers_loadout = {}
		local peers_custody = {}

		if local_peer_id ~= peer_id then
			if not local_peer:waiting_for_player_ready() then
				table.insert(peers_loadout, local_peer)
			elseif managers.trade:is_peer_in_custody(local_peer:id()) then
				if include_custody then
					table.insert(peers_custody, local_peer)
				end
			else
				table.insert(peers, local_peer)
			end
		end

		for _, peer in pairs(managers.network:session():peers()) do
			if peer:id() ~= peer_id then
				if not peer:waiting_for_player_ready() then
					table.insert(peers_loadout, peer)
				elseif managers.trade:is_peer_in_custody(peer:id()) then
					if include_custody then
						table.insert(peers_custody, peer)
					end
				elseif peer:is_host() then
					table.insert(peers, 1, peer)
				else
					table.insert(peers, peer)
				end
			end
		end

		peers = table.list_add(peers, peers_loadout)
		peers = table.list_add(peers, peers_custody)

		for name, amount in pairs(self._global.synced_equipment_possession[peer_id]) do
			local equipment_data = tweak_data.equipments.specials[name]

			if equipment_data and not equipment_data.avoid_tranfer then
				local equipment_lost = true
				local amount_to_transfer = amount
				local max_amount = equipment_data.transfer_quantity or 1

				for _, p in ipairs(peers) do
					local id = p:id()
					local peer_amount = self._global.synced_equipment_possession[id] and self._global.synced_equipment_possession[id][name] or 0

					if max_amount > peer_amount then
						local transfer_amount = math.min(amount_to_transfer, max_amount - peer_amount)
						amount_to_transfer = amount_to_transfer - transfer_amount

						if Network:is_server() then
							if id == local_peer_id then
								managers.player:add_special({
									transfer = true,
									name = name,
									amount = transfer_amount
								})
							else
								p:send("give_equipment", name, transfer_amount, true)
							end
						end

						if amount_to_transfer == 0 then
							equipment_lost = false

							break
						end
					end
				end

				if peer_id == local_peer_id then
					for i = 1, amount - amount_to_transfer, 1 do
						self:remove_special(name)
					end
				end

				if equipment_lost and name == "evidence" then
					managers.mission:call_global_event("equipment_evidence_lost")
				end
			end
		end
	end
end

function PlayerManager:peer_dropped_out(peer)
	local peer_id = peer:id()

	if Network:is_server() then
		self:transfer_special_equipment(peer_id, true)

		if self._global.synced_carry[peer_id] and self._global.synced_carry[peer_id].approved then
			local carry_id = self._global.synced_carry[peer_id].carry_id
			local carry_multiplier = self._global.synced_carry[peer_id].multiplier
			local dye_initiated = self._global.synced_carry[peer_id].dye_initiated
			local has_dye_pack = self._global.synced_carry[peer_id].has_dye_pack
			local dye_value_multiplier = self._global.synced_carry[peer_id].dye_value_multiplier
			local peer_unit = peer:unit()
			local position = Vector3()

			if alive(peer_unit) then
				if peer_unit:movement():zipline_unit() then
					position = peer_unit:movement():zipline_unit():position()
				else
					position = peer_unit:position()
				end
			end

			local dir = Vector3(0, 0, 0)

			self:server_drop_carry(carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, Rotation(), dir, 0, nil, peer)
		end
	end

	self._global.synced_equipment_possession[peer_id] = nil
	self._global.synced_deployables[peer_id] = nil
	self._global.synced_cable_ties[peer_id] = nil
	self._global.synced_grenades[peer_id] = nil
	self._global.synced_ammo_info[peer_id] = nil
	self._global.synced_carry[peer_id] = nil
	self._global.synced_team_upgrades[peer_id] = nil
	self._global.synced_bipod[peer_id] = nil
	self._global.synced_cocaine_stacks[peer_id] = nil

	self:update_cocaine_hud()

	local peer_unit = peer:unit()

	self:remove_from_player_list(peer_unit)
	managers.vehicle:remove_player_from_all_vehicles(peer_unit)
end

function PlayerManager:add_equipment(params)
	if tweak_data.equipments[params.equipment or params.name] then
		self:_add_equipment(params)

		return
	end

	if tweak_data.equipments.specials[params.equipment or params.name] then
		self:add_special(params)

		return
	end

	Application:error("No equipment or special equipment named", params.equipment or params.name)
end

function PlayerManager:_add_equipment(params)
	if self:has_equipment(params.equipment) then
		print("Allready have equipment", params.equipment)

		return
	end

	local equipment = params.equipment
	local tweak_data = tweak_data.equipments[equipment]
	local amount = {}
	local amount_digest = {}
	local quantity = tweak_data.quantity

	for i = 1, #quantity, 1 do
		local equipment_name = equipment

		if tweak_data.upgrade_name then
			equipment_name = tweak_data.upgrade_name[i]
		end

		local amt = (quantity[i] or 0) + self:equiptment_upgrade_value(equipment_name, "quantity")
		amt = managers.modifiers:modify_value("PlayerManager:GetEquipmentMaxAmount", amt, params)

		table.insert(amount, amt)
		table.insert(amount_digest, Application:digest_value(0, true))
	end

	local icon = params.icon or tweak_data and tweak_data.icon
	local use_function_name = params.use_function_name or tweak_data and tweak_data.use_function_name
	local use_function = use_function_name or nil

	if params.slot and params.slot > 1 then
		for i = 1, #quantity, 1 do
			amount[i] = math.ceil(amount[i] / 2)
		end
	end

	table.insert(self._equipment.selections, {
		equipment = equipment,
		amount = amount_digest,
		use_function = use_function,
		action_timer = tweak_data.action_timer,
		icon = icon,
		unit = tweak_data.unit,
		on_use_callback = tweak_data.on_use_callback
	})

	self._equipment.selected_index = self._equipment.selected_index or 1

	add_hud_item(amount, icon)

	for i = 1, #amount, 1 do
		self:add_equipment_amount(equipment, amount[i], i)
	end
end

function PlayerManager:add_equipment_amount(equipment, amount, slot)
	local data, index = self:equipment_data_by_name(equipment)

	if data then
		local new_amount = Application:digest_value(data.amount[slot or 1], false) + amount
		data.amount[slot or 1] = Application:digest_value(new_amount, true)

		set_hud_item_amount(index, get_as_digested(data.amount))
	end
end

function PlayerManager:set_equipment_amount(equipment, amount, slot)
	local data, index = self:equipment_data_by_name(equipment)

	if data then
		local new_amount = amount
		data.amount[slot or 1] = Application:digest_value(new_amount, true)

		set_hud_item_amount(index, get_as_digested(data.amount))
	end
end

function PlayerManager:equipment_data_by_name(equipment)
	for i, equipments in ipairs(self._equipment.selections) do
		if equipments.equipment == equipment then
			return equipments, i
		end
	end

	return nil
end

function PlayerManager:get_equipment_amount(equipment, slot)
	for i, equipments in ipairs(self._equipment.selections) do
		if equipments.equipment == equipment then
			return Application:digest_value(equipments.amount[slot or 1], false)
		end
	end

	return 0
end

function PlayerManager:has_equipment(equipment)
	for i, equipments in ipairs(self._equipment.selections) do
		if equipments.equipment == equipment then
			return true
		end
	end

	return false
end

function PlayerManager:has_deployable_left(equipment, slot)
	return self:get_equipment_amount(equipment, slot or 1) > 0
end

function PlayerManager:select_next_item()
	if not self._equipment.selected_index then
		return
	end

	local new_index = self._equipment.selected_index + 1 <= #self._equipment.selections and self._equipment.selected_index + 1 or 1
	local valid = false
	local count = #self._equipment.selections[new_index].amount

	for i = 1, count, 1 do
		if Application:digest_value(self._equipment.selections[new_index].amount[i], false) > 0 then
			valid = true
		end
	end

	if valid then
		self._equipment.selected_index = new_index
	end
end

function PlayerManager:select_previous_item()
	if not self._equipment.selected_index then
		return
	end

	self._equipment.selected_index = self._equipment.selected_index - 1 >= 1 and self._equipment.selected_index - 1 or #self._equipment.selections
end

function PlayerManager:clear_equipment()
	for i, equipment in ipairs(self._equipment.selections) do
		for j = 1, #equipment.amount, 1 do
			equipment.amount[j] = Application:digest_value(0, true)
		end

		set_hud_item_amount(i, get_as_digested(equipment.amount))
		self:update_deployable_equipment_amount_to_peers(equipment.equipment, 0)
	end
end

function PlayerManager:from_server_equipment_place_result(selected_index, unit, sentry_gun_unit)
	if alive(unit) then
		unit:equipment():from_server_sentry_gun_place_result(sentry_gun_unit:id())
	end

	local equipment = self._equipment.selections[selected_index]

	if not equipment then
		return
	end

	local new_amount = Application:digest_value(equipment.amount[1], false) - 1
	equipment.amount[1] = Application:digest_value(new_amount, true)
	local equipments_available = self._global.equipment or {}

	managers.hud:set_item_amount(self._equipment.selected_index, new_amount)
	self:update_deployable_equipment_amount_to_peers(equipment.equipment, new_amount)
end

function PlayerManager:can_use_selected_equipment(unit)
	local equipment = self._equipment.selections[self._equipment.selected_index]

	if not equipment or Application:digest_value(equipment.amount[1], false) == 0 then
		return false
	end

	return true
end

function PlayerManager:switch_equipment()
	self:select_next_item()

	local equipment = self:selected_equipment()

	if equipment and not _G.IS_VR then
		add_hud_item(get_as_digested(equipment.amount), equipment.icon)
	end

	self:update_deployable_selection_to_peers()
end

function PlayerManager:selected_equipment()
	local equipment = self._equipment.selections[self._equipment.selected_index]

	if equipment and equipment.amount then
		for i = 1, #equipment.amount, 1 do
			if Application:digest_value(equipment.amount[i], false) > 0 then
				return equipment
			end
		end
	end

	return nil
end

function PlayerManager:selected_equipment_id()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return nil
	end

	return equipment_data.equipment
end

function PlayerManager:selected_equipment_name()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return ""
	end

	return managers.localization:text(tweak_data.equipments[equipment_data.equipment].text_id or "")
end

function PlayerManager:selected_equipment_limit_movement()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].limit_movement or false
end

function PlayerManager:selected_equipment_deploying_text()
	local equipment_data = self:selected_equipment()

	if not equipment_data or not tweak_data.equipments[equipment_data.equipment].deploying_text_id then
		return false
	end

	return managers.localization:text(tweak_data.equipments[equipment_data.equipment].deploying_text_id)
end

function PlayerManager:selected_equipment_sound_start()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].sound_start or false
end

function PlayerManager:selected_equipment_sound_interupt()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].sound_interupt or false
end

function PlayerManager:selected_equipment_sound_done()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].sound_done or false
end

function PlayerManager:use_selected_equipment(unit)
	local equipment = self._equipment.selections[self._equipment.selected_index]

	if not equipment or Application:digest_value(equipment.amount[1], false) == 0 then
		return
	end

	local used_one = false
	local redirect = nil

	if equipment.use_function then
		used_one, redirect = unit:equipment()[equipment.use_function](unit:equipment(), self._equipment.selected_index, equipment.unit)
	else
		used_one = true
	end

	if used_one then
		self:remove_equipment(equipment.equipment)

		if redirect then
			redirect(unit)

			if equipment.on_use_callback then
				local player_unit = self:player_unit()

				if player_unit then
					player_unit:event_listener():call(equipment.on_use_callback)
				end
			end
		end
	end

	return {
		expire_timer = equipment.action_timer,
		redirect = redirect
	}
end

function PlayerManager:check_equipment_placement_valid(player, equipment)
	local equipment_data = managers.player:equipment_data_by_name(equipment)

	if not equipment_data then
		return false
	end

	if equipment_data.equipment == "trip_mine" or equipment_data.equipment == "ecm_jammer" then
		return player:equipment():valid_look_at_placement(tweak_data.equipments[equipment_data.equipment]) and true or false
	elseif equipment_data.equipment == "sentry_gun" or equipment_data.equipment == "ammo_bag" or equipment_data.equipment == "sentry_gun_silent" or equipment_data.equipment == "doctor_bag" or equipment_data.equipment == "first_aid_kit" or equipment_data.equipment == "bodybags_bag" then
		return player:equipment():valid_shape_placement(equipment_data.equipment, tweak_data.equipments[equipment_data.equipment]) and true or false
	elseif equipment_data.equipment == "armor_kit" then
		return true
	end

	return player:equipment():valid_placement(tweak_data.equipments[equipment_data.equipment]) and true or false
end

function PlayerManager:check_selected_equipment_placement_valid(player)
	return self:check_equipment_placement_valid(player, self:selected_equipment_id())
end

function PlayerManager:selected_equipment_deploy_timer()
	if _G.IS_VR then
		local deployable_hand = self:player_unit():hand():get_active_hand("deployable")

		if deployable_hand then
			return 0
		end
	end

	local equipment_data = managers.player:selected_equipment()

	if not equipment_data then
		return 0
	end

	local equipment_tweak_data = tweak_data.equipments[equipment_data.equipment]
	local multiplier = 1

	if equipment_tweak_data.upgrade_deploy_time_multiplier then
		multiplier = managers.player:upgrade_value(equipment_tweak_data.upgrade_deploy_time_multiplier.category, equipment_tweak_data.upgrade_deploy_time_multiplier.upgrade, 1)
	end

	multiplier = multiplier * self:upgrade_value("player", "deploy_interact_faster", 1)

	return (equipment_tweak_data.deploy_time or 1) * multiplier
end

function PlayerManager:remove_equipment(equipment_id, slot)
	local current_equipment = self:selected_equipment()
	local equipment, index = self:equipment_data_by_name(equipment_id)
	local new_amount = Application:digest_value(equipment.amount[slot or 1], false) - 1
	equipment.amount[slot or 1] = Application:digest_value(new_amount, true)

	if current_equipment and current_equipment.equipment == equipment.equipment then
		set_hud_item_amount(index, get_as_digested(equipment.amount))
	end

	if not slot or slot and slot < 2 then
		self:update_deployable_equipment_amount_to_peers(equipment.equipment, new_amount)
	end
end

function PlayerManager:verify_equipment(peer_id, equipment_id)
	if peer_id == 0 then
		local id = "asset_" .. tostring(equipment_id)
		self._asset_equipment = self._asset_equipment or {}
		local max_amount = tweak_data.equipments.max_amount[id]
		max_amount = managers.modifiers:modify_value("PlayerManager:GetEquipmentMaxAmount", max_amount)

		if not max_amount or self._asset_equipment[id] and max_amount < self._asset_equipment[id] + 1 then
			local peer = managers.network:session():server_peer()

			peer:mark_cheater(VoteManager.REASON.many_assets)

			return false
		end

		self._asset_equipment[id] = (self._asset_equipment[id] or 0) + 1

		return true
	end

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return false
	end

	return peer:verify_deployable(equipment_id)
end

function PlayerManager:verify_grenade(peer_id)
	if not managers.network:session() then
		return true
	end

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return false
	end

	return peer:verify_grenade(1)
end

function PlayerManager:register_grenade(peer_id, amount)
	if not managers.network:session() then
		return true
	end

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return false
	end

	return peer:verify_grenade(-(amount or 1))
end

function PlayerManager:verify_carry(peer, carry_id)
	if Network:is_client() or not managers.network:session() then
		return true
	end

	if not peer then
		if Network:is_server() then
			return true
		end

		local level_id = managers.job:current_level_id()
		local amount_bags = tweak_data.levels[level_id] and tweak_data.levels[level_id].max_bags or 20
		self._total_bags = self._total_bags and self._total_bags + 1 or 1

		if amount_bags < self._total_bags then
			local peer = managers.network:session():server_peer()

			peer:mark_cheater(VoteManager.REASON.many_bags)

			return false
		end
	end

	return peer:verify_bag(carry_id, false)
end

function PlayerManager:register_carry(peer, carry_id)
	if Network:is_client() or not managers.network:session() then
		return true
	end

	if not peer then
		return false
	end

	return peer:verify_bag(carry_id, true)
end

function PlayerManager:add_sentry_gun(num, sentry_type)
	local equipment, index = self:equipment_data_by_name(sentry_type)
	local new_amount = Application:digest_value(equipment.amount[1], false) + num
	equipment.amount[1] = Application:digest_value(new_amount, true)
	local update_hud = false

	if self._equipment.selected_index and self._equipment.selections[self._equipment.selected_index].equipment ~= sentry_type and Application:digest_value(self._equipment.selections[self._equipment.selected_index].amount[1], false) == 0 then
		self._equipment.selected_index = index
		update_hud = true
	elseif _G.IS_VR then
		self._equipment.selected_index = index
	end

	if update_hud and equipment then
		managers.hud:add_item({
			amount = Application:digest_value(equipment.amount[1], false),
			icon = equipment.icon
		})
		self:update_deployable_equipment_amount_to_peers(equipment.equipment, new_amount)
	elseif self._equipment.selected_index and self._equipment.selections[self._equipment.selected_index].equipment == sentry_type then
		managers.hud:set_item_amount(index, new_amount)
		self:update_deployable_equipment_amount_to_peers(equipment.equipment, new_amount)
	end
end

function PlayerManager:add_special(params)
	local name = params.equipment or params.name

	if not tweak_data.equipments.specials[name] then
		Application:error("Special equipment " .. name .. " doesn't exist!")

		return
	end

	local unit = self:player_unit()
	local respawn = params.amount and true or false
	local equipment = tweak_data.equipments.specials[name]
	local special_equipment = self._equipment.specials[name]
	local amount = params.amount or equipment.quantity
	local extra = self:_equipped_upgrade_value(equipment) + self:upgrade_value(name, "quantity")

	if name == "cable_tie" then
		extra = self:upgrade_value(name, "quantity_1") + self:upgrade_value(name, "quantity_2")
	end

	if special_equipment then
		if equipment.max_quantity or equipment.quantity or params.transfer and equipment.transfer_quantity then
			local dedigested_amount = special_equipment.amount and Application:digest_value(special_equipment.amount, false) or 1
			local new_amount = self:has_category_upgrade(name, "quantity_unlimited") and -1 or math.min(dedigested_amount + amount, (params.transfer and equipment.transfer_quantity or equipment.max_quantity or equipment.quantity) + extra)
			special_equipment.amount = Application:digest_value(new_amount, true)

			if special_equipment.is_cable_tie then
				managers.hud:set_cable_ties_amount(HUDManager.PLAYER_PANEL, new_amount)
				self:update_synced_cable_ties_to_peers(new_amount)
			else
				managers.hud:set_special_equipment_amount(name, new_amount)
				self:update_equipment_possession_to_peers(name, new_amount)
			end
		end

		return
	end

	local icon = equipment.icon
	local action_message = equipment.action_message

	if not params.silent then
		local text = managers.localization:text(equipment.text_id)
		local title = managers.localization:text("present_obtained_mission_equipment_title")

		managers.hud:present_mid_text({
			time = 4,
			text = text,
			title = title,
			icon = icon
		})

		if action_message and alive(unit) then
			managers.network:session():send_to_peers_synched("sync_show_action_message", unit, action_message)
		end
	end

	local is_cable_tie = name == "cable_tie"
	local quantity = nil

	if is_cable_tie or not params.transfer then
		quantity = self:has_category_upgrade(name, "quantity_unlimited") and -1 or equipment.quantity and (respawn and math.min(params.amount, (equipment.max_quantity or equipment.quantity or 1) + extra) or equipment.quantity and math.min(amount + extra, (equipment.max_quantity or equipment.quantity or 1) + extra))
	else
		quantity = params.amount
	end

	if is_cable_tie then
		managers.hud:set_cable_tie(HUDManager.PLAYER_PANEL, {
			icon = icon,
			amount = quantity or nil
		})
		self:update_synced_cable_ties_to_peers(quantity)
	else
		managers.hud:add_special_equipment({
			id = name,
			icon = icon,
			amount = quantity or equipment.transfer_quantity and 1 or nil
		})
		self:update_equipment_possession_to_peers(name, quantity)
	end

	self._equipment.specials[name] = {
		amount = quantity and Application:digest_value(quantity, true) or nil,
		is_cable_tie = is_cable_tie
	}

	if equipment.player_rule then
		self:set_player_rule(equipment.player_rule, true)
	end
end

function PlayerManager:_equipped_upgrade_value(equipment)
	if not equipment.extra_quantity then
		return 0
	end

	local equipped_upgrade = equipment.extra_quantity.equipped_upgrade
	local category = equipment.extra_quantity.category
	local upgrade = equipment.extra_quantity.upgrade

	return self:equipped_upgrade_value(equipped_upgrade, category, upgrade)
end

function PlayerManager:get_equipped_weapon_category()
	local current_state = self:get_current_state()

	if current_state then
		local equipped_unit = current_state._equipped_unit

		if equipped_unit then
			return equipped_unit:base():weapon_tweak_data().categories[1]
		end
	end

	return nil
end

function PlayerManager:is_current_weapon_of_category(...)
	local weapon_unit = self:equipped_weapon_unit()

	if weapon_unit then
		return weapon_unit:base():is_category(...)
	end

	return false
end

function PlayerManager:has_special_equipment(name)
	return self._equipment.specials[name]
end

function PlayerManager:_can_pickup_special_equipment(special_equipment, name)
	if special_equipment.amount then
		local equipment = tweak_data.equipments.specials[name]
		local extra = self:_equipped_upgrade_value(equipment)

		return Application:digest_value(special_equipment.amount, false) < (equipment.max_quantity or equipment.quantity or 1) + extra, not not equipment.max_quantity
	end

	return false
end

function PlayerManager:can_pickup_equipment(name)
	local special_equipment = self._equipment.specials[name]

	if special_equipment then
		return self:_can_pickup_special_equipment(special_equipment, name)
	else
		local equipment = tweak_data.equipments.specials[name]

		if equipment and equipment.shares_pickup_with then
			for i, special_equipment_name in ipairs(equipment.shares_pickup_with) do
				if special_equipment_name ~= name then
					special_equipment = self._equipment.specials[special_equipment_name]

					if special_equipment and not self:_can_pickup_special_equipment(special_equipment, name) then
						return false
					end
				end
			end
		end
	end

	return true
end

function PlayerManager:remove_special(name)
	local special_equipment = self._equipment.specials[name]

	if not special_equipment then
		return
	end

	local special_amount = special_equipment.amount and Application:digest_value(special_equipment.amount, false)

	if special_amount and special_amount ~= -1 then
		special_amount = math.max(0, special_amount - 1)

		if special_equipment.is_cable_tie then
			managers.hud:set_cable_ties_amount(HUDManager.PLAYER_PANEL, special_amount)
			self:update_synced_cable_ties_to_peers(special_amount)
		else
			managers.hud:set_special_equipment_amount(name, special_amount)
			self:update_equipment_possession_to_peers(name, special_amount)
		end

		special_equipment.amount = Application:digest_value(special_amount, true)
	end

	if not special_amount or special_amount == 0 then
		if not special_equipment.is_cable_tie then
			managers.hud:remove_special_equipment(name)
			managers.network:session():send_to_peers_loaded("sync_remove_equipment_possession", managers.network:session():local_peer():id(), name)
			self:remove_equipment_possession(managers.network:session():local_peer():id(), name)
		end

		self._equipment.specials[name] = nil
		local equipment = tweak_data.equipments.specials[name]

		if equipment.player_rule then
			self:set_player_rule(equipment.player_rule, false)
		end
	end
end

function PlayerManager:add_cable_ties(amount)
	local name = "cable_tie"
	local equipment = tweak_data.equipments.specials[name]
	local special_equipment = self._equipment.specials[name]
	local new_amount = 0

	if special_equipment then
		local current_amount = Application:digest_value(special_equipment.amount, false)
		new_amount = math.min(current_amount + amount, equipment.max_quantity)

		managers.hud:set_cable_ties_amount(HUDManager.PLAYER_PANEL, new_amount)

		special_equipment.amount = Application:digest_value(new_amount, true)
	else
		new_amount = math.min(amount, equipment.max_quantity)
		self._equipment.specials[name] = {
			is_cable_tie = true,
			amount = new_amount and Application:digest_value(new_amount, true) or nil
		}

		managers.hud:set_cable_tie(HUDManager.PLAYER_PANEL, {
			icon = equipment.icon,
			amount = new_amount
		})
	end

	self:update_synced_cable_ties_to_peers(new_amount)
end

function PlayerManager:_set_grenade(params)
	local grenade = params.grenade
	local tweak_data = tweak_data.blackmarket.projectiles[grenade]
	local amount = params.amount
	local icon = tweak_data.icon

	self:update_grenades_amount_to_peers(grenade, amount)
	managers.hud:set_teammate_grenades(HUDManager.PLAYER_PANEL, {
		amount = amount,
		icon = icon
	})
end

function PlayerManager:_on_grenade_cooldown_end()
	local tweak = tweak_data.blackmarket.projectiles[managers.blackmarket:equipped_grenade()]

	if tweak and tweak.sounds and tweak.sounds.cooldown then
		self:player_unit():sound():play(tweak.sounds.cooldown)
	end

	self:add_grenade_amount(1)
end

function PlayerManager:replenish_grenades(cooldown)
	if self:has_active_timer("replenish_grenades") then
		return
	end

	self:start_timer("replenish_grenades", cooldown, callback(self, self, "_on_grenade_cooldown_end"))
	managers.hud:set_player_grenade_cooldown({
		end_time = managers.game_play_central:get_heist_timer() + cooldown,
		duration = cooldown
	})
end

function PlayerManager:speed_up_grenade_cooldown(time)
	local timer = self._timers.replenish_grenades

	if not timer then
		return
	end

	timer.t = timer.t - time
	local peer_id = managers.network:session():local_peer():id()
	local grenade = self._global.synced_grenades[peer_id].grenade
	local tweak = tweak_data.blackmarket.projectiles[grenade]
	local time_left = self:get_timer_remaining("replenish_grenades") or 0

	managers.hud:set_player_grenade_cooldown({
		end_time = managers.game_play_central:get_heist_timer() + time_left,
		duration = tweak.base_cooldown
	})
end

function PlayerManager:add_grenade_amount(amount, sync)
	local peer_id = managers.network:session():local_peer():id()
	local grenade = self._global.synced_grenades[peer_id].grenade
	local tweak = tweak_data.blackmarket.projectiles[grenade]
	local max_amount = self:get_max_grenades_by_peer_id(peer_id)
	local icon = tweak.icon
	local previous_amount = self._global.synced_grenades[peer_id].amount

	if amount > 0 and tweak.base_cooldown then
		managers.hud:animate_grenade_flash(HUDManager.PLAYER_PANEL)
	end

	amount = math.min(Application:digest_value(previous_amount, false) + amount, max_amount)

	if amount < max_amount and tweak.base_cooldown then
		self:replenish_grenades(tweak.base_cooldown)
	end

	managers.hud:set_teammate_grenades_amount(HUDManager.PLAYER_PANEL, {
		icon = icon,
		amount = amount
	})
	self:update_grenades_amount_to_peers(grenade, amount, sync and peer_id)
end

function PlayerManager:update_grenades_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_grenades[peer_id] then
		local grenade = self._global.synced_grenades[peer_id].grenade
		local amount = self._global.synced_grenades[peer_id].amount

		peer:send_queued_sync("sync_grenades", grenade, Application:digest_value(amount, false), 0)
	end
end

function PlayerManager:update_grenades_amount_to_peers(grenade, amount, register_peer_id)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_grenades", grenade, amount, register_peer_id or 0)
	self:set_synced_grenades(peer_id, grenade, amount, register_peer_id)
end

function PlayerManager:set_synced_grenades(peer_id, grenade, amount, register_peer_id)
	local synced_grenade = self._global.synced_grenades[peer_id]
	local only_update_amount = false
	local digested_amount = Application:digest_value(amount, true)
	local incremented = false

	if synced_grenade then
		only_update_amount = synced_grenade.grenade == grenade
		incremented = Application:digest_value(synced_grenade.amount, false) < amount
	end

	self._global.synced_grenades[peer_id] = {
		grenade = grenade,
		amount = digested_amount
	}
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		local icon = tweak_data.blackmarket.projectiles[grenade].icon

		if only_update_amount then
			managers.hud:set_teammate_grenades_amount(character_data.panel_id, {
				icon = icon,
				amount = amount
			})
		else
			managers.hud:set_teammate_grenades(character_data.panel_id, {
				icon = icon,
				amount = amount
			})
		end

		if incremented and tweak_data.blackmarket.projectiles[grenade].base_cooldown then
			managers.hud:animate_grenade_flash(character_data.panel_id)
		end
	end

	if register_peer_id and register_peer_id > 0 then
		managers.player:register_grenade(register_peer_id, amount)
	end
end

function PlayerManager:get_grenade_amount(peer_id)
	return Application:digest_value(self._global.synced_grenades[peer_id].amount, false)
end

function PlayerManager:get_synced_grenades(peer_id)
	return self._global.synced_grenades[peer_id]
end

function PlayerManager:can_throw_grenade()
	local peer_id = managers.network:session():local_peer():id()

	return self:get_grenade_amount(peer_id) > 0
end

function PlayerManager:get_max_grenades_by_peer_id(peer_id)
	local peer = managers.network:session() and managers.network:session():peer(peer_id)

	return peer and self:get_max_grenades(peer:grenade_id()) or 0
end

function PlayerManager:get_max_grenades(grenade_id)
	grenade_id = grenade_id or managers.blackmarket:equipped_grenade()
	local max_amount = tweak_data:get_raw_value("blackmarket", "projectiles", grenade_id, "max_amount") or 0
	max_amount = managers.modifiers:modify_value("PlayerManager:GetThrowablesMaxAmount", max_amount)

	return max_amount
end

function PlayerManager:got_max_grenades()
	local peer_id = managers.network:session():local_peer():id()

	return self:get_max_grenades_by_peer_id(peer_id) <= self:get_grenade_amount(peer_id)
end

function PlayerManager:has_grenade(peer_id)
	peer_id = peer_id or managers.network:session():local_peer():id()
	local synced_grenade = self:get_synced_grenades(peer_id)

	return synced_grenade and synced_grenade.grenade and true or false
end

function PlayerManager:on_throw_grenade()
	local should_decrement = true

	if should_decrement then
		self:add_grenade_amount(-1)
	end

	local peer_id = managers.network:session():local_peer():id()

	if table.contains(tweak_data.achievement.fire_in_the_hole.grenade, self:get_synced_grenades(peer_id).grenade) then
		managers.achievment:award_progress(tweak_data.achievement.fire_in_the_hole.stat)
	end
end

function PlayerManager:set_carry(carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	local carry_data = tweak_data.carry[carry_id]
	local carry_type = carry_data.type

	self:set_player_state("carry")

	local title = managers.localization:text("hud_carrying_announcement_title")
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	local text = managers.localization:text("hud_carrying_announcement", {
		CARRY_TYPE = type_text
	})
	local icon = nil

	if not dye_initiated then
		dye_initiated = true

		if carry_data.dye then
			local chance = tweak_data.carry.dye.chance * managers.player:upgrade_value("player", "dye_pack_chance_multiplier", 1)

			if false then
				has_dye_pack = true
				dye_value_multiplier = math.round(tweak_data.carry.dye.value_multiplier * managers.player:upgrade_value("player", "dye_pack_cash_loss_multiplier", 1))
			end
		end
	end

	self:update_synced_carry_to_peers(carry_id, carry_multiplier or 1, dye_initiated, has_dye_pack, dye_value_multiplier)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, carry_id, managers.loot:get_real_value(carry_id, carry_multiplier or 1))
	managers.hud:temp_show_carry_bag(carry_id, managers.loot:get_real_value(carry_id, carry_multiplier or 1))

	local player = self:player_unit()

	if not player then
		return
	end

	player:movement():current_state():set_tweak_data(carry_type)
	player:sound():play("Play_bag_generic_pickup", nil, false)
end

function PlayerManager:bank_carry()
	local carry_data = self:get_my_carry_data()
	local peer_id = managers.network:session() and managers.network:session():local_peer():id()

	managers.loot:secure(carry_data.carry_id, carry_data.multiplier, nil, peer_id)
	managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
	managers.hud:temp_hide_carry_bag()
	self:update_removed_synced_carry_to_peers()
	managers.player:set_player_state("standard")
end

function PlayerManager:drop_carry(zipline_unit)
	local carry_data = self:get_my_carry_data()

	if not carry_data then
		return
	end

	self._carry_blocked_cooldown_t = Application:time() + 1.2 + math.rand(0.3)
	local player = self:player_unit()

	if player then
		player:sound():play("Play_bag_generic_throw", nil, false)
	end

	local camera_ext = player:camera()
	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local throw_distance_multiplier_upgrade_level = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
	local position = camera_ext:position()
	local rotation = camera_ext:rotation()
	local forward = player:camera():forward()

	if _G.IS_VR then
		local active_hand = player:hand():get_active_hand("bag")

		if active_hand then
			position = active_hand:position()
			rotation = active_hand:rotation()
			forward = rotation:y()
		end
	end

	if Network:is_client() then
		managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, forward, throw_distance_multiplier_upgrade_level, zipline_unit)
	else
		self:server_drop_carry(carry_data.carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, forward, throw_distance_multiplier_upgrade_level, zipline_unit, managers.network:session():local_peer())
	end

	managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
	managers.hud:temp_hide_carry_bag()
	self:update_removed_synced_carry_to_peers()

	if self._current_state == "carry" then
		managers.player:set_player_state("standard")
	end
end

function PlayerManager:server_drop_carry(carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer)
	if not self:verify_carry(peer, carry_id) then
		return
	end

	local unit_name = tweak_data.carry[carry_id].unit or "units/payday2/pickups/gen_pku_lootbag/gen_pku_lootbag"
	local unit = World:spawn_unit(Idstring(unit_name), position, rotation)

	managers.network:session():send_to_peers_synched("sync_carry_data", unit, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer and peer:id() or 0)
	self:sync_carry_data(unit, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer and peer:id() or 0)

	return unit
end

function PlayerManager:sync_carry_data(unit, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id)
	local throw_distance_multiplier = self:upgrade_value_by_level("carry", "throw_distance_multiplier", throw_distance_multiplier_upgrade_level, 1)
	local carry_type = tweak_data.carry[carry_id].type
	throw_distance_multiplier = throw_distance_multiplier * tweak_data.carry.types[carry_type].throw_distance_multiplier

	unit:carry_data():set_carry_id(carry_id)
	unit:carry_data():set_multiplier(carry_multiplier)
	unit:carry_data():set_value(managers.money:get_bag_value(carry_id, carry_multiplier))
	unit:carry_data():set_dye_pack_data(dye_initiated, has_dye_pack, dye_value_multiplier)
	unit:carry_data():set_latest_peer_id(peer_id)

	if alive(zipline_unit) then
		zipline_unit:zipline():attach_bag(unit)
	else
		unit:push(100, dir * 600 * throw_distance_multiplier)
	end

	unit:interaction():register_collision_callbacks()
end

function PlayerManager:force_drop_carry()
	local carry_data = self:get_my_carry_data()

	if not carry_data then
		return
	end

	local player = self:player_unit()

	if not alive(player) then
		print("COULDN'T FORCE DROP! DIDN'T HAVE A UNIT")

		return
	end

	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local camera_ext = player:camera()

	if Network:is_client() then
		managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, camera_ext:position(), camera_ext:rotation(), Vector3(0, 0, 0), 0, nil)
	else
		self:server_drop_carry(carry_data.carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, camera_ext:position(), camera_ext:rotation(), Vector3(0, 0, 0), 0, nil, managers.network:session():local_peer())
	end

	managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
	managers.hud:temp_hide_carry_bag()
	self:update_removed_synced_carry_to_peers()
end

function PlayerManager:clear_carry(soft_reset)
	local carry_data = self:get_my_carry_data()

	if not carry_data then
		return
	end

	local player = self:player_unit()

	if not soft_reset and not alive(player) then
		print("COULDN'T FORCE DROP! DIDN'T HAVE A UNIT")

		return
	end

	managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
	managers.hud:temp_hide_carry_bag()
	self:update_removed_synced_carry_to_peers()

	if self._current_state == "carry" then
		managers.player:set_player_state("standard")
	end
end

function PlayerManager:is_berserker()
	local player_unit = self:player_unit()

	return alive(player_unit) and player_unit:character_damage() and player_unit:character_damage():is_berserker() or false
end

function PlayerManager:get_damage_health_ratio(health_ratio, category)
	local damage_ratio = 1 - health_ratio / math.max(0.01, self:_get_damage_health_ratio_threshold(category))

	return math.max(damage_ratio, 0)
end

function PlayerManager:_get_damage_health_ratio_threshold(category)
	local threshold = tweak_data.upgrades.player_damage_health_ratio_threshold

	if category then
		threshold = threshold * self:upgrade_value("player", category .. "_damage_health_ratio_threshold_multiplier", 1)
	end

	return threshold
end

function PlayerManager:is_damage_health_ratio_active(health_ratio)
	return self:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") and self:get_damage_health_ratio(health_ratio, "melee") > 0 or self:has_category_upgrade("player", "armor_regen_damage_health_ratio_multiplier") and self:get_damage_health_ratio(health_ratio, "armor_regen") > 0 or self:has_category_upgrade("player", "damage_health_ratio_multiplier") and self:get_damage_health_ratio(health_ratio, "damage") > 0 or self:has_category_upgrade("player", "movement_speed_damage_health_ratio_multiplier") and self:get_damage_health_ratio(health_ratio, "movement_speed") > 0
end

function PlayerManager:get_current_state()
	local player = self:player_unit()

	if player and alive(player) then
		return player:movement()._current_state
	end

	return nil
end

function PlayerManager:is_carrying()
	return self:get_my_carry_data() and true or false
end

function PlayerManager:current_carry_id()
	local my_carry_data = self:get_my_carry_data()

	return my_carry_data and my_carry_data.carry_id or nil
end

function PlayerManager:carry_blocked_by_cooldown()
	return self._carry_blocked_cooldown_t and Application:time() < self._carry_blocked_cooldown_t or false
end

function PlayerManager:can_carry(carry_id)
	return true
end

function PlayerManager:check_damage_carry(attack_data)
	local carry_data = self:get_my_carry_data()

	if not carry_data then
		return
	end

	local carry_id = carry_data.carry_id
	local type = tweak_data.carry[carry_id].type

	if not tweak_data.carry.types[type].looses_value then
		return
	end

	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local value = math.max(carry_data.value - tweak_data.carry.types[type].looses_value_per_hit * attack_data.damage, 0)

	self:update_synced_carry_to_peers(carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, carry_id, managers.loot:get_real_value(carry_id, carry_data.multiplier))
end

function PlayerManager:dye_pack_exploded()
	local carry_data = self:get_my_carry_data()

	if not carry_data then
		return
	end

	local carry_id = carry_data.carry_id
	local type = tweak_data.carry[carry_id].type
	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local value = carry_data.value * (1 - dye_value_multiplier / 100)
	value = math.round(value)
	has_dye_pack = false

	self:update_synced_carry_to_peers(carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, carry_id, managers.loot:get_real_value(carry_id, carry_data.multiplier))
end

function PlayerManager:remove_ammo_from_pool(percent)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	local current_state = self:get_current_state()
	local current_weapon = current_state:get_equipped_weapon()
	local index = self:equipped_weapon_index()

	current_weapon:remove_ammo_from_pool(percent)
	managers.hud:set_ammo_amount(index, current_weapon:ammo_info())
end

function PlayerManager:count_up_player_minions()
	self._local_player_minions = math.min(self._local_player_minions + 1, self:upgrade_value("player", "convert_enemies_max_minions", 0))
end

function PlayerManager:count_down_player_minions()
	self._local_player_minions = math.max(self._local_player_minions - 1, 0)
end

function PlayerManager:reset_minions()
	self._local_player_minions = 0
end

function PlayerManager:num_local_minions()
	return self._local_player_minions
end

function PlayerManager:chk_minion_limit_reached()
	return self:upgrade_value("player", "convert_enemies_max_minions", 0) <= self._local_player_minions
end

function PlayerManager:on_used_body_bag()
	self:_set_body_bags_amount(self._local_player_body_bags - 1)
end

function PlayerManager:reset_used_body_bag()
	self:_set_body_bags_amount(self:total_body_bags())
end

function PlayerManager:chk_body_bags_depleted()
	return self._local_player_body_bags <= 0
end

function PlayerManager:_set_body_bags_amount(body_bags_amount)
	self._local_player_body_bags = math.clamp(body_bags_amount, 0, self:max_body_bags())

	managers.hud:on_ext_inventory_changed()
end

function PlayerManager:add_body_bags_amount(body_bags_amount)
	self:_set_body_bags_amount(self._local_player_body_bags + body_bags_amount)
end

function PlayerManager:get_body_bags_amount()
	return self._local_player_body_bags
end

function PlayerManager:has_total_body_bags()
	return self._local_player_body_bags == self:total_body_bags()
end

function PlayerManager:total_body_bags()
	local bags = self:upgrade_value("player", "corpse_dispose_amount", 0)
	bags = managers.modifiers:modify_value("PlayerManager:GetTotalBodyBags", bags)

	return bags
end

function PlayerManager:has_max_body_bags()
	return self._local_player_body_bags == self:max_body_bags()
end

function PlayerManager:max_body_bags()
	return self:total_body_bags() + self:upgrade_value("player", "extra_corpse_dispose_amount", 0)
end

function PlayerManager:change_player_look(new_look)
	self._player_mesh_suffix = new_look

	for _, unit in pairs(managers.groupai:state():all_char_criminals()) do
		unit.unit:movement():set_character_anim_variables()
	end
end

function PlayerManager:player_timer()
	return self._player_timer
end

function PlayerManager:add_weapon_ammo_gain(name_id, amount)
end

function PlayerManager:report_weapon_ammo_gains()
end

function PlayerManager:save(data)
	local state = {
		kit = self._global.kit,
		viewed_content_updates = self._global.viewed_content_updates
	}
	data.PlayerManager = state
end

function PlayerManager:load(data)
	self:aquire_default_upgrades()

	local state = data.PlayerManager

	if state then
		self._global.kit = state.kit or self._global.kit
		self._global.viewed_content_updates = state.viewed_content_updates or self._global.viewed_content_updates

		managers.savefile:add_load_done_callback(callback(self, self, "_verify_loaded_data"))
	end
end

function PlayerManager:set_content_update_viewed(content_update)
	self._global.viewed_content_updates[content_update] = true
end

function PlayerManager:get_content_update_viewed(content_update)
	return self._global.viewed_content_updates[content_update] or false
end

function PlayerManager:_verify_loaded_data()
	for slot, equipment_id in ipairs(self._global.kit.equipment_slots) do
		if not tweak_data.equipments[equipment_id] then
			self._global.kit.equipment_slots[slot] = nil
		end
	end

	self:_verify_equipment_kit(true)

	if managers.menu_scene then
		managers.menu_scene:set_character_deployable(managers.blackmarket:equipped_deployable(), false, 0)
	end
end

function PlayerManager:sync_save(data)
	Application:trace("PlayerManager:sync_save: ", inspect(self._global.synced_bipod))

	local state = {
		current_sync_state = self._current_sync_state,
		player_mesh_suffix = self._player_mesh_suffix,
		husk_bipod_data = self._global.synced_bipod
	}
	data.PlayerManager = state
end

function PlayerManager:sync_load(data)
	local state = data.PlayerManager

	if state then
		self:set_player_state(state.current_sync_state)
		self:change_player_look(state.player_mesh_suffix)
		self:set_husk_bipod_data(state.husk_bipod_data)
	end

	Application:trace("PlayerManager:sync_load: ", inspect(self._global.synced_bipod))
end

function PlayerManager:on_simulation_started()
	self._respawn = false
end

function PlayerManager:reset()
	if managers.hud then
		managers.hud:clear_player_special_equipments()
	end

	Global.player_manager = nil

	self:_setup()
	self:_setup_rules()
	self:aquire_default_upgrades()
end

function PlayerManager:soft_reset()
	self._listener_holder = EventListenerHolder:new()

	self:reset_used_body_bag()

	self._equipment = {
		selections = {},
		specials = {}
	}
	self._global.synced_grenades = {}

	self:clear_carry(true)

	self._throw_regen_kills = nil
end

function PlayerManager:on_peer_synch_request(peer)
	self:player_unit():network():synch_to_peer(peer)
end

function PlayerManager:update_husk_bipod_to_peer(peer)
	Application:trace("PlayerManager:update_husk_bipod_to_peer")

	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_bipod[peer_id] then
		local bipod_pos = self._global.synced_bipod[peer_id].bipod_pos
		local body_pos = self._global.synced_bipod[peer_id].body_pos

		peer:send_queued_sync("sync_bipod", bipod_pos, body_pos)
	end
end

function PlayerManager:set_husk_bipod_data(data)
	Application:trace("PlayerManager:set_husk_bipod_data( data ): ", inspect(data))

	self._global.synced_bipod = data
end

function PlayerManager:set_bipod_data_for_peer(data)
	if not self._global.synced_bipod then
		self._global.synced_bipod = {}
	end

	self._global.synced_bipod[data.peer_id] = {
		bipod_pos = data.bipod_pos,
		body_pos = data.body_pos
	}
end

function PlayerManager:get_bipod_data_for_peer(peer_id)
	return self._global.synced_bipod[peer_id]
end

function PlayerManager:set_synced_bipod(peer, bipod_pos, body_pos)
	Application:trace("PlayerManager:set_synced_bipod")

	local peer_id = peer:id()
	self._global.synced_bipod[peer_id] = {
		bipod_pos = bipod_pos,
		body_pos = body_pos
	}
end

function PlayerManager:enter_vehicle(vehicle, locator)
	local peer_id = managers.network:session():local_peer():id()
	local player = self:local_player()
	local seat = vehicle:vehicle_driving():get_available_seat(locator:position())

	if not seat then
		return
	end

	if Network:is_server() then
		self:server_enter_vehicle(vehicle, peer_id, player, seat.name)
	else
		managers.network:session():send_to_host("sync_enter_vehicle_host", vehicle, seat.name, peer_id, player)
	end
end

function PlayerManager:server_enter_vehicle(vehicle, peer_id, player, seat_name)
	local vehicle_ext = vehicle:vehicle_driving()
	local seat = nil

	if seat_name == nil then
		local pos = player:position()
		seat = vehicle_ext:reserve_seat(player, pos, nil)
	else
		seat = vehicle_ext:reserve_seat(player, nil, seat_name)
	end

	if seat ~= nil then
		managers.network:session():send_to_peers_synched("sync_vehicle_player", "enter", vehicle, peer_id, player, seat.name)
		self:_enter_vehicle(vehicle, peer_id, player, seat.name)
	end
end

function PlayerManager:sync_enter_vehicle(vehicle, peer_id, player, seat_name)
	self:_enter_vehicle(vehicle, peer_id, player, seat_name)
end

function PlayerManager:_enter_vehicle(vehicle, peer_id, player, seat_name)
	self._global.synced_vehicle_data[peer_id] = {
		vehicle_unit = vehicle,
		seat = seat_name
	}
	local vehicle_ext = vehicle:vehicle_driving()

	vehicle_ext:place_player_on_seat(player, seat_name)
	player:kill_mover()

	local seat = vehicle_ext:find_seat_for_player(player)
	local rot = seat.object:rotation()
	local pos = seat.object:position()

	player:set_rotation(rot)

	local pos = seat.object:position() + VehicleDrivingExt.PLAYER_CAPSULE_OFFSET

	vehicle:link(Idstring(VehicleDrivingExt.SEAT_PREFIX .. seat_name), player)

	if self:local_player() == player then
		self:set_player_state("driving")
	end

	managers.hud:update_vehicle_label_by_id(vehicle:unit_data().name_label_id, vehicle_ext:_number_in_the_vehicle())
	managers.vehicle:on_player_entered_vehicle(vehicle, player)
end

function PlayerManager:get_vehicle()
	if managers.network:session() then
		local peer_id = managers.network:session():local_peer():id()
		local vehicle = self._global.synced_vehicle_data[peer_id]

		return vehicle
	else
		return nil
	end
end

function PlayerManager:get_vehicle_for_peer(peer_id)
	if managers.network:session() then
		local vehicle = self._global.synced_vehicle_data[peer_id]

		return vehicle
	else
		return nil
	end
end

function PlayerManager:exit_vehicle()
	local peer_id = managers.network:session():local_peer():id()
	local vehicle_data = self._global.synced_vehicle_data[peer_id]

	if vehicle_data == nil then
		return
	end

	local player = self:local_player()

	managers.network:session():send_to_peers_synched("sync_vehicle_player", "exit", nil, peer_id, player, nil)
	self:_exit_vehicle(peer_id, player)
end

function PlayerManager:sync_exit_vehicle(peer_id, player)
	self:_exit_vehicle(peer_id, player)
end

function PlayerManager:_exit_vehicle(peer_id, player)
	local vehicle_data = self._global.synced_vehicle_data[peer_id]

	if vehicle_data == nil or not alive(player) then
		return
	end

	player:unlink()

	local vehicle_ext = vehicle_data.vehicle_unit:vehicle_driving()

	vehicle_ext:exit_vehicle(player)

	self._global.synced_vehicle_data[peer_id] = nil

	managers.hud:update_vehicle_label_by_id(vehicle_data.vehicle_unit:unit_data().name_label_id, vehicle_ext:_number_in_the_vehicle())
	managers.vehicle:on_player_exited_vehicle(vehicle_data.vehicle, player)
end

function PlayerManager:update_player_list(unit, health)
	for i in pairs(self._player_list) do
		local p = self._player_list[i]

		if p.unit == unit then
			p.health = health

			return
		end
	end

	table.insert(self._player_list, {
		unit = unit,
		health = health
	})
end

function PlayerManager:debug_print_player_status()
	local count = 0

	for i in pairs(self._player_list) do
		local p = self._player_list[i]

		print("Player: ", i, ", health: ", p.health, " , unit: ", p.unit)

		count = count + 1
	end

	print("num players: ", count)
end

function PlayerManager:remove_from_player_list(unit)
	for i in pairs(self._player_list) do
		local p = self._player_list[i]

		if p.unit == unit then
			table.remove(self._player_list, i)

			return
		end
	end
end

function PlayerManager:on_ammo_increase(ammo)
	local equipped_unit = self:get_current_state()._equipped_unit:base()
	local equipped_selection = self:get_current_state()._ext_inventory:equipped_selection()

	if equipped_unit and not equipped_unit:ammo_full() then
		local index = self:equipped_weapon_index()

		equipped_unit:add_ammo_to_pool(ammo, index)
	end
end

function PlayerManager:equipped_weapon_index()
	local current_state = self:get_current_state()
	local equipped_unit = current_state._equipped_unit:base()._unit
	local available_selections = current_state._ext_inventory:available_selections()

	for id, weapon in pairs(available_selections) do
		if equipped_unit == weapon.unit then
			return id
		end
	end

	return 1
end

function PlayerManager:equipped_weapon_unit()
	local current_state = self:get_current_state()

	if current_state then
		local weapon_unit = current_state._equipped_unit:base()._unit

		return weapon_unit
	end

	return nil
end

function PlayerManager:_is_all_in_custody(ignored_peer_id)
	for _, peer in pairs(managers.network:session():all_peers()) do
		if peer and alive(peer:unit()) and peer:id() ~= ignored_peer_id then
			return false
		end
	end

	for _, ai in pairs(managers.groupai:state():all_AI_criminals()) do
		if ai and alive(ai.unit) then
			return false
		end
	end

	return true
end

function PlayerManager:on_enter_custody(_player, already_dead)
	local player = _player or self:player_unit()

	if not player then
		Application:error("[PlayerManager:on_enter_custody] Unable to get player")

		return
	end

	if player == self:player_unit() then
		local equipped_grenade = managers.blackmarket:equipped_grenade()

		if equipped_grenade and tweak_data.blackmarket.projectiles[equipped_grenade] and tweak_data.blackmarket.projectiles[equipped_grenade].ability then
			self:reset_ability_hud()
		end
	end

	managers.mission:call_global_event("player_in_custody")

	local peer_id = managers.network:session():local_peer():id()

	if self._super_syndrome_count and self._super_syndrome_count > 0 and not self._action_mgr:is_running("stockholm_syndrome_trade") then
		self._action_mgr:add_action("stockholm_syndrome_trade", StockholmSyndromeTradeAction:new(player:position(), peer_id))
	end

	self:force_drop_carry()
	managers.statistics:downed({
		death = true
	})

	if not already_dead then
		player:network():send("sync_player_movement_state", "dead", player:character_damage():down_time(), player:id())
		managers.groupai:state():on_player_criminal_death(peer_id)
	end

	self._listener_holder:call(self._custody_state, player)
	game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
	player:character_damage():set_invulnerable(true)
	player:character_damage():set_health(0)
	player:base():_unregister()
	World:delete_unit(player)
	managers.hud:remove_interact()
end

function PlayerManager:captured_hostage()
end

function PlayerManager:init_auto_respawn_callback(position, peer_id, force)
	self._clbk_super_syndrome_respawn = "PlayerManager"
	local game_time = TimerManager:game():time()
	local clbk_delay = game_time + 1
	local pause_trade = 10

	managers.trade:start_stockholm_syndrome()
	managers.enemy:add_delayed_clbk(self._clbk_super_syndrome_respawn, callback(self, self, "clbk_super_syndrome_respawn", {
		pos = position,
		peer_id = peer_id
	}), clbk_delay)
	managers.trade:pause_trade(pause_trade)
end

function PlayerManager:clbk_super_syndrome_respawn(data)
	local trade_manager = managers.trade
	self._clbk_super_syndrome_respawn = nil
	local best_hostage = trade_manager:get_best_hostage(data.pos, true)
	local criminal = trade_manager:get_criminal_by_peer(data.peer_id)

	if criminal and best_hostage then
		local pos = best_hostage.unit:position()
		local rot = best_hostage.unit:rotation()

		trade_manager:criminal_respawn(pos, rot, criminal)
		trade_manager:begin_hostage_trade(pos, rot, best_hostage, true, true, true)
	end
end

function PlayerManager:on_hallowSPOOCed()
	local player = self:local_player()
	local t = Application:time()

	if alive(player) and (not self._halloween_t or self._halloween_t < t) then
		if math.rand(1) < 0.5 then
			player:sound():play("cloaker_taunt_after_assault", nil, nil)
		elseif math.rand(1) < 0.5 then
			local camera_unit = player:camera() and player:camera():camera_unit()

			if alive(camera_unit) then
				local vec = mvector3.copy(player:movement():m_head_rot():y())

				mvector3.set_z(vec, 0)
				mvector3.negate(vec)
				mvector3.normalize(vec)
				camera_unit:base():clbk_aim_assist({
					ray = vec
				})
				player:sound():play("cloaker_detect_mono", nil, nil)
			end
		end

		self._halloween_t = t + 30
	end
end

function PlayerManager:attempt_ability(ability)
	if not self:player_unit() then
		return
	end

	local local_peer_id = managers.network:session():local_peer():id()
	local has_no_grenades = self:get_grenade_amount(local_peer_id) == 0
	local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)
	local swan_song_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

	if has_no_grenades or is_downed or swan_song_active then
		return
	end

	local attempt_func = self["_attempt_" .. ability]

	if attempt_func and not attempt_func(self) then
		return
	end

	local tweak = tweak_data.blackmarket.projectiles[ability]

	if tweak and tweak.sounds and tweak.sounds.activate then
		self:player_unit():sound():play(tweak.sounds.activate)
	end

	self:add_grenade_amount(-1)
	self._message_system:notify("ability_activated", nil, ability)
end

function PlayerManager:_attempt_chico_injector()
	if self:has_activate_temporary_upgrade("temporary", "chico_injector") then
		return false
	end

	local duration = self:upgrade_value("temporary", "chico_injector")[2]
	local now = managers.game_play_central:get_heist_timer()

	managers.network:session():send_to_peers("sync_ability_hud", now + duration, duration)
	self:activate_temporary_upgrade("temporary", "chico_injector")

	local function speed_up_on_kill()
		managers.player:speed_up_grenade_cooldown(1)
	end

	self:register_message(Message.OnEnemyKilled, "speed_up_chico_injector", speed_up_on_kill)

	return true
end

function PlayerManager:_attempt_pocket_ecm_jammer()
	local player_inventory = self:player_unit():inventory()

	if player_inventory:is_jammer_active() then
		return false
	end

	if managers.groupai and managers.groupai:state():whisper_mode() then
		player_inventory:start_jammer_effect()
	else
		player_inventory:start_feedback_effect()
	end

	local base_upgrade = self:upgrade_value("player", "pocket_ecm_jammer_base")

	local function speed_up_on_kill()
		managers.player:speed_up_grenade_cooldown(base_upgrade.cooldown_drain)
	end

	self:register_message(Message.OnEnemyKilled, "speed_up_pocket_ecm_jammer", speed_up_on_kill)
	managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, base_upgrade.duration)

	return true
end

function PlayerManager:_attempt_tag_team()
	local player = managers.player:player_unit()
	local player_eye = player:camera():position()
	local player_fwd = player:camera():rotation():y()
	local tagged = nil
	local heisters_slot_mask = World:make_slot_mask(2, 3, 4, 5, 16, 24)
	local cone_camera = player:camera():camera_object()
	local cone_center = Vector3(0, 0)
	local cone_radius = managers.player:upgrade_value("player", "tag_team_base").radius
	local tag_distance = managers.player:upgrade_value("player", "tag_team_base").distance * 100
	local heisters = World:find_units("camera_cone", cone_camera, cone_center, cone_radius, tag_distance, heisters_slot_mask)
	local best_dot = -1

	for _, heister in ipairs(heisters) do
		local heister_center = heister:oobb():center()
		local heister_dir = heister_center - player_eye
		local distance_pass = mvector3.length_sq(heister_dir) <= tag_distance * tag_distance
		local raycast = nil

		if distance_pass then
			mvector3.normalize(heister_dir)

			local heister_dot = Vector3.dot(player_fwd, heister_dir)

			if best_dot < heister_dot then
				best_dot = heister_dot
				raycast = World:raycast(player_eye, heister_center)
				tagged = raycast and raycast.unit:in_slot(heisters_slot_mask) and heister
			end
		end
	end

	if not tagged or self._coroutine_mgr:is_running("tag_team") then
		return false
	end

	self:add_coroutine("tag_team", PlayerAction.TagTeam, tagged, player)

	return true
end

function PlayerManager:sync_tag_team(tagged, owner, end_time)
	if tagged == self:local_player() then
		local tagged_id = managers.network:session():peer_by_unit(tagged):id()
		local owner_id = managers.network:session():peer_by_unit(owner):id()
		local coroutine_key = "tag_team_" .. tagged_id .. owner_id

		self:add_coroutine(coroutine_key, PlayerAction.TagTeamTagged, tagged, owner, end_time)
	end
end

function PlayerManager:end_tag_team(tagged, owner)
	self._listener_holder:call("tag_team_end", tagged, owner)
end

function PlayerManager:_update_timers(t)
	local timers_copy = table.map_copy(self._timers)

	for key, timer in pairs(timers_copy) do
		if not timer.t or timer.t <= t then
			self._timers[key] = nil

			if timer.func then
				timer.func(key, timer.t)
			end
		end
	end
end

function PlayerManager:start_timer(key, duration, callback)
	local end_time = TimerManager:game():time() + duration
	self._timers[key] = {
		t = end_time,
		func = callback
	}
end

function PlayerManager:get_timer(key)
	if not key then
		return
	end

	local timer = self._timers[key]

	return timer and TimerManager:game():time() < timer.t and timer.t or nil
end

function PlayerManager:has_active_timer(key)
	return self:get_timer(key) ~= nil
end

function PlayerManager:get_timer_remaining(key)
	local time = self:get_timer(key)
	local now = TimerManager:game():time()

	return time and time - now
end

function PlayerManager:clear_timers()
	self._timers = {}
end

function PlayerManager:reset_ability_hud()
	managers.hud:set_player_grenade_cooldown(nil)
	managers.hud:set_player_ability_radial({
		current = 0,
		total = 1
	})

	self._should_reset_ability_hud = nil
end

function PlayerManager:update_smoke_screens(t, dt)
	if self._smoke_screen_effects and #self._smoke_screen_effects > 0 then
		for i, smoke_screen_effect in dpairs(self._smoke_screen_effects) do
			smoke_screen_effect:update(t, dt)

			if not smoke_screen_effect:alive() then
				table.remove(self._smoke_screen_effects, i)
			end
		end
	end
end

function PlayerManager:smoke_screens()
	return self._smoke_screen_effects or {}
end

function PlayerManager:spawn_smoke_screen(position, normal, grenade_unit, has_dodge_bonus)
	local time = tweak_data.projectiles.smoke_screen_grenade.duration
	self._smoke_screen_effects = self._smoke_screen_effects or {}

	table.insert(self._smoke_screen_effects, SmokeScreenEffect:new(position, normal, time, has_dodge_bonus, grenade_unit))

	if alive(self._smoke_grenade) then
		self._smoke_grenade:set_slot(0)
	end

	self._smoke_grenade = grenade_unit
end

function PlayerManager:_dodge_shot_gain(gain_value)
	if gain_value then
		self._dodge_shot_gain_value = gain_value
	else
		return self._dodge_shot_gain_value or 0
	end
end

function PlayerManager:_dodge_replenish_armor()
	self:player_unit():character_damage():_regenerate_armor()
end

function PlayerManager:crew_add_concealment(new_value)
	for k, v in pairs(managers.network:session():all_peers()) do
		local unit = v:unit()

		print(unit)

		if unit then
			unit:base():update_concealment()
		end
	end
end
