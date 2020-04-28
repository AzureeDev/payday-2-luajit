SentryGunWeapon = SentryGunWeapon or class()
SentryGunWeapon._AP_ROUNDS_FIRE_RATE = 3.5
SentryGunWeapon._AP_ROUNDS_DAMAGE_MULTIPLIER = 2.5
local tmp_rot1 = Rotation()

function SentryGunWeapon:init(unit)
	self._unit = unit
	self._current_damage_mul = 1
	self._timer = TimerManager:game()
	self._character_slotmask = managers.slot:get_mask("raycastable_characters")
	self._next_fire_allowed = -1000
	self._obj_fire = self._unit:get_object(Idstring("a_detect"))
	self._effect_align = {
		self._unit:get_object(Idstring(self._muzzle_flash_parent or "fire")),
		self._unit:get_object(Idstring(self._muzzle_flash_parent or "fire"))
	}
	self._muzzle_flash_parent = nil

	if self._laser_align_name then
		self._laser_align = self._unit:get_object(Idstring(self._laser_align_name))
	end

	self._interleaving_fire = 1
	self._trail_effect_table = {
		effect = RaycastWeaponBase.TRAIL_EFFECT,
		position = Vector3(),
		normal = Vector3()
	}
	self._ammo_sync_resolution = 0.0625

	if Network:is_server() then
		self._ammo_total = 1
		self._ammo_max = self._ammo_total
		self._ammo_sync = 16
	else
		self._ammo_ratio = 1
	end

	self._spread_mul = 1
	self._use_armor_piercing = false
	self._slow_fire_rate = false
	self._fire_rate_reduction = 1
	self._name_id = self._unit:base():get_name_id()
	local my_tweak_data = tweak_data.weapon[self._name_id]
	self._default_alert_size = my_tweak_data.alert_size
	self._from = Vector3()
	self._to = Vector3()
end

function SentryGunWeapon:unit()
	return self._unit
end

function SentryGunWeapon:switch_fire_mode()
	self:_set_fire_mode(not self._use_armor_piercing)

	if self._use_armor_piercing then
		managers.hint:show_hint("sentry_set_ap_rounds")
	else
		managers.hint:show_hint("sentry_normal_ammo")
	end

	self._unit:network():send("sentrygun_sync_armor_piercing", self._use_armor_piercing)
	self._unit:sound_source():post_event("wp_sentrygun_swap_ammo")
	self._unit:event_listener():call("on_switch_fire_mode", self._use_armor_piercing)
end

function SentryGunWeapon:_set_fire_mode(use_armor_piercing)
	self._use_armor_piercing = use_armor_piercing
	self._fire_rate_reduction = self._use_armor_piercing and self._AP_ROUNDS_FIRE_RATE or 1
	self._current_damage_mul = self._use_armor_piercing and self._AP_ROUNDS_DAMAGE_MULTIPLIER or 1

	self:flip_fire_sound()
end

function SentryGunWeapon:set_fire_mode_net(use_armor_piercing)
	self:_set_fire_mode(use_armor_piercing)
	self._unit:event_listener():call("on_switch_fire_mode", self._use_armor_piercing)
end

function SentryGunWeapon:flip_fire_sound()
	if self._shooting then
		self:_sound_autofire_end()
		self:_sound_autofire_start()
	end
end

function SentryGunWeapon:_init()
	self._name_id = self._unit:base():get_name_id()
	local my_tweak_data = tweak_data.weapon[self._name_id]
	self._bullet_slotmask = managers.slot:get_mask(Network:is_server() and "bullet_impact_targets" or "bullet_blank_impact_targets")
	self._character_slotmask = managers.slot:get_mask("raycastable_characters")
	self._muzzle_effect = Idstring(my_tweak_data.muzzleflash or "effects/particles/test/muzzleflash_maingun")
	local muzzle_offset = Vector3()

	mvector3.set_static(muzzle_offset, 0, 10, 0)

	self._muzzle_effect_table = {
		{
			force_synch = false,
			effect = self._muzzle_effect,
			parent = self._effect_align[1]
		},
		{
			force_synch = false,
			effect = self._muzzle_effect,
			parent = self._effect_align[2]
		}
	}
	self._use_shell_ejection_effect = SystemInfo:platform() == Idstring("WIN32")

	if self._use_shell_ejection_effect then
		self._obj_shell_ejection = self._unit:get_object(Idstring("shell"))
		self._shell_ejection_effect = Idstring(tweak_data.weapon[self._name_id].shell_ejection or "effects/payday2/particles/weapons/shells/shell_556")
		self._shell_ejection_effect_table = {
			effect = self._shell_ejection_effect,
			parent = self._obj_shell_ejection
		}
	end

	self._damage = my_tweak_data.DAMAGE
	self._alert_events = {}
	self._alert_fires = {}
	self._suppression = my_tweak_data.SUPPRESSION
end

function SentryGunWeapon:setup(setup_data)
	self:_init()

	self._setup = setup_data
	self._default_alert_size = self._alert_size
	self._current_damage_mul = 1
	self._owner = setup_data.user_unit
	self._spread_mul = setup_data.spread_mul
	self._auto_reload = setup_data.auto_reload
	self._fire_rate_reduction = 1

	if setup_data.alert_AI then
		self._alert_events = {}
		self._alert_size = self._alert_size or tweak_data.weapon[self._name_id].alert_size
		self._alert_fires = {}
	else
		self._alert_events = nil
		self._alert_size = nil
		self._alert_fires = nil
	end

	if setup_data.bullet_slotmask then
		self._bullet_slotmask = setup_data.bullet_slotmask
	end
end

function SentryGunWeapon:update(unit, t, dt)
	if not alive(self._laser_unit) then
		self._blink_start_t = nil
	end

	if self._blink_start_t then
		local period = 0.55
		local phase = (t - self._blink_start_t) % period / period

		if phase < 0.5 then
			self._laser_unit:base():set_on()
		else
			self._laser_unit:base():set_off()
		end
	end
end

function SentryGunWeapon:set_ammo(amount)
	self._ammo_total = amount
	self._ammo_max = math.max(self._ammo_max, amount)
end

function SentryGunWeapon:change_ammo(amount)
	self._ammo_total = math.min(math.ceil(self._ammo_total + amount), self._ammo_max)
	local ammo_percent = self._ammo_total / self._ammo_max
	local resolution_step = math.ceil(ammo_percent / self._ammo_sync_resolution)

	if ammo_percent == 0 or resolution_step ~= self._ammo_sync then
		self._ammo_sync = resolution_step

		self._unit:network():send("sentrygun_ammo", self._ammo_sync)

		if self._unit:interaction() then
			self._unit:interaction():set_dirty(true)
		end
	end
end

function SentryGunWeapon:sync_ammo(ammo_ratio)
	self._ammo_ratio = ammo_ratio * self._ammo_sync_resolution

	self._unit:base():set_waiting_for_refill(false)

	if self._unit:interaction() then
		self._unit:interaction():set_dirty(true)
	end

	self._unit:event_listener():call("on_sync_ammo")
end

function SentryGunWeapon:set_spread_mul(spread_mul)
	self._spread_mul = spread_mul
end

function SentryGunWeapon:start_autofire()
	if self._unit:damage() and self._unit:damage():has_sequence("anim_fire_seq") then
		self._unit:damage():run_sequence_simple("anim_fire_seq")
	end

	if self._shooting then
		return
	end

	self:_sound_autofire_start()

	self._next_fire_allowed = math.max(self._next_fire_allowed, Application:time())
	self._shooting = true
	self._fire_start_t = self._timer:time()
end

function SentryGunWeapon:stop_autofire()
	if self._unit:damage() and self._unit:damage():has_sequence("anim_fire_stop_seq") then
		self._unit:damage():run_sequence_simple("anim_fire_stop_seq")
	end

	if not self._shooting then
		return
	end

	if self:out_of_ammo() then
		self:remove_fire_mode_interaction()
		self:_sound_autofire_end_empty()
		self._unit:event_listener():call("on_out_of_ammo")
	elseif self._timer:time() - self._fire_start_t > 3 then
		self:_sound_autofire_end_cooldown()
	else
		self:_sound_autofire_end()
	end

	self._shooting = nil
end

function SentryGunWeapon:trigger_held(blanks, expend_ammo, shoot_player, target_unit)
	local fired = nil

	if self._next_fire_allowed <= self._timer:time() then
		fired = self:fire(blanks, expend_ammo, shoot_player, target_unit)

		if fired then
			local fire_rate = tweak_data.weapon[self._name_id].auto.fire_rate * self._fire_rate_reduction
			self._next_fire_allowed = self._next_fire_allowed + fire_rate
			self._interleaving_fire = self._interleaving_fire == 1 and 2 or 1
		end
	end

	return fired
end

function SentryGunWeapon:interaction_setup(fire_mode_unit, owner_id)
	self._fire_mode_unit = fire_mode_unit

	self._fire_mode_unit:interaction():setup(self)
	self._fire_mode_unit:interaction():set_owner_id(owner_id)
end

function SentryGunWeapon:fire(blanks, expend_ammo, shoot_player, target_unit)
	if expend_ammo then
		if self._ammo_total <= 0 then
			return
		end

		self:change_ammo(-1)
	end

	local fire_obj = self._effect_align[self._interleaving_fire]
	local from_pos = fire_obj:position()
	local direction = fire_obj:rotation():y()

	mvector3.spread(direction, tweak_data.weapon[self._name_id].SPREAD * self._spread_mul)
	World:effect_manager():spawn(self._muzzle_effect_table[self._interleaving_fire])

	if self._use_shell_ejection_effect then
		World:effect_manager():spawn(self._shell_ejection_effect_table)
	end

	if self._unit:damage() and self._unit:damage():has_sequence("anim_fire_seq") then
		self._unit:damage():run_sequence_simple("anim_fire_seq")
	end

	local ray_res = self:_fire_raycast(from_pos, direction, shoot_player, target_unit)

	if self._alert_events and ray_res.rays then
		RaycastWeaponBase._check_alert(self, ray_res.rays, from_pos, direction, self._unit)
	end

	self._unit:movement():give_recoil()
	self._unit:event_listener():call("on_fire")

	return ray_res
end

local mvec_to = Vector3()

function SentryGunWeapon:_fire_raycast(from_pos, direction, shoot_player, target_unit)
	local result = {}
	local hit_unit, col_ray = nil

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, tweak_data.weapon[self._name_id].FIRE_RANGE)
	mvector3.add(mvec_to, from_pos)

	self._from = from_pos
	self._to = mvec_to

	if not self._setup.ignore_units then
		return
	end

	if self._use_armor_piercing then
		local col_rays = World:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
		col_ray = col_rays[1]

		if col_ray and col_ray.unit:in_slot(8) and alive(col_ray.unit:parent()) then
			col_ray = col_rays[2] or col_ray
		end
	else
		col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	end

	local player_hit, player_ray_data = nil

	if shoot_player then
		player_hit, player_ray_data = RaycastWeaponBase.damage_player(self, col_ray, from_pos, direction)

		if player_hit then
			local damage = self:_apply_dmg_mul(self._damage, col_ray or player_ray_data, from_pos)

			InstantBulletBase:on_hit_player(col_ray or player_ray_data, self._unit, self._unit, damage)
		end
	end

	if not player_hit and col_ray then
		local damage = self:_apply_dmg_mul(self._damage, col_ray, from_pos)
		hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, self._unit, damage)
	end

	if (not col_ray or col_ray.unit ~= target_unit) and target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression then
		target_unit:character_damage():build_suppression(self._suppression)
	end

	if not col_ray or col_ray.distance > 600 then
		self:_spawn_trail_effect(direction, col_ray)
	end

	result.hit_enemy = hit_unit

	if self._alert_events then
		result.rays = {
			col_ray
		}
	end

	return result
end

function SentryGunWeapon:_apply_dmg_mul(damage, col_ray, from_pos)
	local damage_out = damage * self._current_damage_mul

	if tweak_data.weapon[self._name_id].DAMAGE_MUL_RANGE then
		local ray_dis = col_ray.distance or mvector3.distance(from_pos, col_ray.position)
		local ranges = tweak_data.weapon[self._name_id].DAMAGE_MUL_RANGE
		local i_range = nil

		for test_i_range, range_data in ipairs(ranges) do
			if ray_dis < range_data[1] or test_i_range == #ranges then
				i_range = test_i_range

				break
			end
		end

		if i_range == 1 or ranges[i_range][1] < ray_dis then
			damage_out = damage_out * ranges[i_range][2]
		else
			local dis_lerp = (ray_dis - ranges[i_range - 1][1]) / (ranges[i_range][1] - ranges[i_range - 1][1])
			damage_out = damage_out * math.lerp(ranges[i_range - 1][2], ranges[i_range][2], dis_lerp)
		end
	end

	return damage_out
end

function SentryGunWeapon:_sound_autofire_start()
	self._autofire_sound_event = self._unit:sound_source():post_event(self:auto_fire_start_event())
end

function SentryGunWeapon:_sound_autofire_end()
	if self._autofire_sound_event then
		self._autofire_sound_event:stop()

		self._autofire_sound_event = nil
	end

	self._unit:sound_source():post_event(self:auto_fire_end_event())
end

function SentryGunWeapon:_sound_autofire_end_empty()
	if self._autofire_sound_event then
		self._autofire_sound_event:stop()

		self._autofire_sound_event = nil
	end

	if self._depleted_snd_event then
		self._unit:sound_source():post_event(self._depleted_snd_event)
	end
end

function SentryGunWeapon:_sound_autofire_end_cooldown()
	if self._autofire_sound_event then
		self._autofire_sound_event:stop()

		self._autofire_sound_event = nil
	end

	self._unit:sound_source():post_event(self._fire_stop_snd_event)
	self._unit:sound_source():post_event(self._fire_cooldown_snd_event)
end

function SentryGunWeapon:_spawn_trail_effect(direction, col_ray)
	self._effect_align[self._interleaving_fire]:m_position(self._trail_effect_table.position)
	mvector3.set(self._trail_effect_table.normal, direction)

	local trail = World:effect_manager():spawn(self._trail_effect_table)

	if col_ray then
		World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
	end
end

function SentryGunWeapon:out_of_ammo()
	if self._ammo_total then
		return self._ammo_total == 0
	else
		return self._ammo_ratio == 0
	end
end

function SentryGunWeapon:auto_fire_start_event()
	if self._use_armor_piercing then
		return self._fire_start_snd_event_ap
	else
		return self._fire_start_snd_event
	end
end

function SentryGunWeapon:auto_fire_end_event()
	if self._use_armor_piercing then
		return self._fire_stop_snd_event_ap
	else
		return self._fire_stop_snd_event
	end
end

function SentryGunWeapon:ammo_ratio()
	if self._ammo_total then
		return self._ammo_total / self._ammo_max
	else
		return self._ammo_ratio
	end
end

function SentryGunWeapon:ammo_total()
	return self._ammo_total
end

function SentryGunWeapon:ammo_max()
	return self._ammo_max
end

function SentryGunWeapon:can_auto_reload()
	return self._auto_reload
end

function SentryGunWeapon:on_team_set(team_data)
	self._foe_teams = team_data.foes
end

function SentryGunWeapon:set_laser_enabled(mode, blink)
	if mode then
		self:_set_laser_state(true)

		if mode ~= self._laser_unit:base():theme_type() then
			self._laser_unit:base():set_color_by_theme(mode)
		end

		if blink then
			if not self._blink_start_t then
				self._blink_start_t = TimerManager:game():time()

				self._unit:set_extension_update_enabled(Idstring("weapon"), true)
			end
		else
			self._laser_unit:base():set_on()

			self._blink_start_t = nil

			self._unit:set_extension_update_enabled(Idstring("weapon"), false)
		end
	elseif alive(self._laser_unit) then
		self:_set_laser_state(false)

		if self._blink_start_t then
			self._blink_start_t = nil

			self._unit:set_extension_update_enabled(Idstring("weapon"), false)
		end
	end
end

function SentryGunWeapon:_set_laser_state(state)
	if state then
		if not alive(self._laser_unit) then
			local spawn_rot = self._laser_align:rotation()
			local spawn_pos = self._laser_align:position()
			self._laser_unit = World:spawn_unit(Idstring("units/payday2/weapons/wpn_npc_upg_fl_ass_smg_sho_peqbox/wpn_npc_upg_fl_ass_smg_sho_peqbox"), spawn_pos, spawn_rot)

			self._unit:link(self._laser_align:name(), self._laser_unit)
			self._laser_unit:base():set_npc()
			self._laser_unit:base():set_on()
			self._laser_unit:base():set_max_distace(10000)
			self._laser_unit:base():add_ray_ignore_unit(self._unit)
			self._laser_unit:set_visible(false)
		end
	elseif alive(self._laser_unit) then
		self._laser_unit:base():set_off()
		self._laser_unit:set_slot(0)

		self._laser_unit = nil
	end
end

function SentryGunWeapon:has_laser()
	return self._laser_align and true or false
end

function SentryGunWeapon:update_laser()
	if not self:has_laser() then
		return
	end

	local laser_mode, blink = nil

	if self._unit:character_damage():dead() then
		-- Nothing
	elseif self._unit:movement():is_activating() then
		laser_mode = "turret_module_active"
	elseif self._unit:movement():is_inactivating() then
		laser_mode = "turret_module_active"
		blink = true
	elseif self._unit:movement():is_inactivated() then
		laser_mode = nil
	elseif self._unit:movement():rearming() then
		laser_mode = "turret_module_rearming"
		blink = true
	elseif self._unit:movement():team().foes[tweak_data.levels:get_default_team_ID("player")] then
		laser_mode = "turret_module_active"
	else
		laser_mode = "turret_module_mad"
	end

	self:set_laser_enabled(laser_mode, blink)
end

function SentryGunWeapon:save(save_data)
	local my_save_data = {}
	save_data.weapon = my_save_data

	if self._spread_mul ~= 1 then
		my_save_data.spread_mul = self._spread_mul
	end

	my_save_data.ammo_ratio = self:ammo_ratio()
	my_save_data.foe_teams = self._foe_teams
	my_save_data.auto_reload = self._auto_reload
	my_save_data.alert = self._alert_events and true or nil
	my_save_data.use_armor_piercing = self._use_armor_piercing
end

function SentryGunWeapon:load(save_data)
	self._name_id = self._unit:base():get_name_id()

	self:_init()

	local my_save_data = save_data.weapon
	self._ammo_ratio = my_save_data.ammo_ratio or self._ammo_ratio
	self._spread_mul = my_save_data.spread_mul or 1
	self._foe_teams = my_save_data.foe_teams
	self._auto_reload = my_save_data.auto_reload

	self:_set_fire_mode(my_save_data.use_armor_piercing)

	self._setup = {
		ignore_units = {
			self._unit
		}
	}

	if not my_save_data.alert then
		self._alert_events = nil
	end
end

function SentryGunWeapon:destroy(unit)
	self:remove_fire_mode_interaction()
	self:_set_laser_state(nil)
end

function SentryGunWeapon:remove_fire_mode_interaction()
	if self._fire_mode_unit and alive(self._fire_mode_unit) then
		self._fire_mode_unit:set_slot(0)

		self._fire_mode_unit = nil
	end
end

function SentryGunWeapon:remove_dead_owner(dead_owner)
	if self._setup.ignore_units then
		table.delete(self._setup.ignore_units, dead_owner)
	end
end

function SentryGunWeapon:setup_virtual_ammo(mul)
	local ammo_amount = tweak_data.upgrades.sentry_gun_base_ammo * mul
	self._virtual_max_ammo = ammo_amount
	self._virtual_ammo = ammo_amount
	local event_listener = self._unit:event_listener()

	event_listener:add("virtual_ammo_on_fire", {
		"on_fire"
	}, callback(self, self, "_on_fire_virtual_shoot"))
	event_listener:add("virtual_ammo_on_sync", {
		"on_sync_ammo"
	}, callback(self, self, "_sync_virtual_ammo"))
end

function SentryGunWeapon:get_virtual_ammo_ratio()
	if self._virtual_max_ammo and self._virtual_ammo then
		return self._virtual_ammo / self._virtual_max_ammo
	end

	return 1
end

function SentryGunWeapon:_on_fire_virtual_shoot()
	if self._virtual_ammo then
		self._virtual_ammo = self._virtual_ammo - 1
	end
end

function SentryGunWeapon:_sync_virtual_ammo()
	if self._virtual_max_ammo and self._virtual_ammo then
		self._virtual_ammo = self._virtual_max_ammo * self:ammo_ratio()
	end
end
