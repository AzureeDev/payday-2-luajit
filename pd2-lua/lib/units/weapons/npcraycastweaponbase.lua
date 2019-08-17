NPCRaycastWeaponBase = NPCRaycastWeaponBase or class(RaycastWeaponBase)
NPCRaycastWeaponBase._VOICES = {
	"a",
	"b",
	"c"
}
NPCRaycastWeaponBase._next_i_voice = {}

function NPCRaycastWeaponBase:init(unit)
	RaycastWeaponBase.super.init(self, unit, false)

	self._player_manager = managers.player
	self._unit = unit
	self._name_id = self.name_id or "m4_npc"
	self._bullet_slotmask = managers.slot:get_mask("bullet_impact_targets")
	self._blank_slotmask = managers.slot:get_mask("bullet_blank_impact_targets")

	self:_create_use_setups()

	self._setup = {}
	self._digest_values = false

	self:set_ammo_max(tweak_data.weapon[self._name_id].AMMO_MAX)
	self:set_ammo_total(self:get_ammo_max())
	self:set_ammo_max_per_clip(tweak_data.weapon[self._name_id].CLIP_AMMO_MAX)
	self:set_ammo_remaining_in_clip(self:get_ammo_max_per_clip())

	self._damage = tweak_data.weapon[self._name_id].DAMAGE
	self._next_fire_allowed = -1000
	self._obj_fire = self._unit:get_object(Idstring("fire"))
	self._sound_fire = SoundDevice:create_source("fire")

	self._sound_fire:link(self._unit:orientation_object())

	self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash or "effects/particles/test/muzzleflash_maingun")
	self._muzzle_effect_table = {
		force_synch = false,
		effect = self._muzzle_effect,
		parent = self._obj_fire
	}
	self._use_shell_ejection_effect = SystemInfo:platform() == Idstring("WIN32")

	if self._use_shell_ejection_effect then
		self._obj_shell_ejection = self._unit:get_object(Idstring("a_shell"))
		self._shell_ejection_effect = Idstring(self:weapon_tweak_data().shell_ejection or "effects/payday2/particles/weapons/shells/shell_556")
		self._shell_ejection_effect_table = {
			effect = self._shell_ejection_effect,
			parent = self._obj_shell_ejection
		}
	end

	self._trail_effect_table = {
		effect = self.TRAIL_EFFECT,
		position = Vector3(),
		normal = Vector3()
	}
	self._flashlight_light_lod_enabled = true

	if false and self._multivoice then
		if not NPCRaycastWeaponBase._next_i_voice[self._name_id] then
			NPCRaycastWeaponBase._next_i_voice[self._name_id] = 1
		end

		self._voice = NPCRaycastWeaponBase._VOICES[NPCRaycastWeaponBase._next_i_voice[self._name_id]]

		if NPCRaycastWeaponBase._next_i_voice[self._name_id] == #NPCRaycastWeaponBase._VOICES then
			NPCRaycastWeaponBase._next_i_voice[self._name_id] = 1
		else
			NPCRaycastWeaponBase._next_i_voice[self._name_id] = NPCRaycastWeaponBase._next_i_voice[self._name_id] + 1
		end
	else
		self._voice = "a"
	end

	if self._unit:get_object(Idstring("ls_flashlight")) then
		self._flashlight_data = {
			light = self._unit:get_object(Idstring("ls_flashlight")),
			effect = self._unit:effect_spawner(Idstring("flashlight"))
		}

		self._flashlight_data.light:set_far_range(400)
		self._flashlight_data.light:set_spot_angle_end(25)
		self._flashlight_data.light:set_multiplier(2)
	end

	if tweak_data.weapon[self._name_id].has_suppressor then
		self._sound_fire:set_switch("suppressed", tweak_data.weapon[self._name_id].has_suppressor)
	end
end

function NPCRaycastWeaponBase:setup(setup_data)
	self._autoaim = setup_data.autoaim
	self._alert_events = setup_data.alert_AI and {} or nil
	self._alert_size = tweak_data.weapon[self._name_id].alert_size
	self._alert_fires = {}
	self._suppression = tweak_data.weapon[self._name_id].suppression
	self._bullet_slotmask = setup_data.hit_slotmask or self._bullet_slotmask
	self._character_slotmask = managers.slot:get_mask("raycastable_characters")
	self._hit_player = setup_data.hit_player and true or false
	self._setup = setup_data
	self._setup.user_sound_variant = 1
end

function NPCRaycastWeaponBase:start_autofire(nr_shots)
	self:_sound_autofire_start(nr_shots)

	self._next_fire_allowed = math.max(self._next_fire_allowed, Application:time())
	self._shooting = true
end

function NPCRaycastWeaponBase:fire_mode()
	return tweak_data.weapon[self._name_id].auto and "auto" or "single"
end

function NPCRaycastWeaponBase:recoil_wait()
	return self:fire_mode() == "auto" and self:weapon_tweak_data().auto.fire_rate or nil
end

function NPCRaycastWeaponBase:stop_autofire()
	if not self._shooting then
		return
	end

	self:_sound_autofire_end()

	self._shooting = nil
end

function NPCRaycastWeaponBase:singleshot(...)
	local fired = self:fire(...)

	if fired then
		self:_sound_singleshot()
	end

	return fired
end

function NPCRaycastWeaponBase:trigger_held(...)
	local fired = nil

	if self._next_fire_allowed <= Application:time() then
		fired = self:fire(...)

		if fired then
			self._next_fire_allowed = self._next_fire_allowed + (tweak_data.weapon[self._name_id].auto.fire_rate or 1)
		end
	end

	return fired
end

function NPCRaycastWeaponBase:add_damage_multiplier(damage_multiplier)
	self._damage = self._damage * damage_multiplier
end

local mto = Vector3()
local mfrom = Vector3()
local mspread = Vector3()

function NPCRaycastWeaponBase:fire_blank(direction, impact)
	local user_unit = self._setup.user_unit

	self._unit:m_position(mfrom)

	local rays = {}

	if impact then
		mvector3.set(mspread, direction)
		mvector3.spread(mspread, 5)
		mvector3.set(mto, mspread)
		mvector3.multiply(mto, 20000)
		mvector3.add(mto, mfrom)

		local col_ray = World:raycast("ray", mfrom, mto, "slot_mask", self._blank_slotmask, "ignore_unit", self._setup.ignore_units)

		self._obj_fire:m_position(self._trail_effect_table.position)
		mvector3.set(self._trail_effect_table.normal, mspread)

		local trail = (not col_ray or col_ray.distance > 650) and World:effect_manager():spawn(self._trail_effect_table) or nil

		if col_ray then
			InstantBulletBase:on_collision(col_ray, self._unit, user_unit, self._damage, true)

			if trail then
				World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
			end

			table.insert(rays, col_ray)
		end
	end

	World:effect_manager():spawn(self._muzzle_effect_table)
	self:_sound_singleshot()
end

function NPCRaycastWeaponBase:destroy(unit)
	RaycastWeaponBase.super.pre_destroy(self, unit)

	if self._shooting then
		self:stop_autofire()
	end
end

function NPCRaycastWeaponBase:non_npc_name_id()
	if not self._non_npc_name_id then
		self._non_npc_name_id = self._name_id
		self._non_npc_name_id = string.gsub(self._non_npc_name_id, "_npc", "")
		self._non_npc_name_id = string.gsub(self._non_npc_name_id, "_crew", "")
	end

	return self._non_npc_name_id
end

function NPCRaycastWeaponBase:_get_spread(user_unit)
	local weapon_tweak = tweak_data.weapon[self._name_id]

	if not weapon_tweak then
		return 3
	end

	return weapon_tweak.spread
end

function NPCRaycastWeaponBase:_sound_autofire_start(nr_shots)
	local tweak_sound = tweak_data.weapon[self._name_id].sounds
	local sound_name = tweak_sound.prefix .. self._setup.user_sound_variant .. self._voice .. (nr_shots and "_" .. tostring(nr_shots) .. "shot" or "_loop")
	local sound = self._sound_fire:post_event(sound_name)

	if not sound then
		sound_name = tweak_sound.prefix .. "1" .. self._voice .. "_end"
		sound = self._sound_fire:post_event(sound_name)
	end
end

function NPCRaycastWeaponBase:_sound_autofire_end()
	local tweak_sound = tweak_data.weapon[self._name_id].sounds
	local sound_name = tweak_sound.prefix .. self._setup.user_sound_variant .. self._voice .. "_end"
	local sound = self._sound_fire:post_event(sound_name)

	if not sound then
		sound_name = tweak_sound.prefix .. "1" .. self._voice .. "_end"
		sound = self._sound_fire:post_event(sound_name)
	end
end

function NPCRaycastWeaponBase:_sound_singleshot()
	local tweak_sound = tweak_data.weapon[self._name_id].sounds
	local sound_name = tweak_sound.prefix .. self._setup.user_sound_variant .. self._voice .. "_1shot"
	local sound = self._sound_fire:post_event(sound_name)

	if not sound then
		sound_name = tweak_sound.prefix .. "1" .. self._voice .. "_1shot"
		sound = self._sound_fire:post_event(sound_name)
	end
end

local mvec_to = Vector3()
local mvec_spread = Vector3()

function NPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local result = {}
	local hit_unit = nil
	local miss, extra_spread = self:_check_smoke_shot(user_unit, target_unit)

	if miss then
		result.guaranteed_miss = miss

		mvector3.spread(direction, math.rand(unpack(extra_spread)))
	end

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, 20000)
	mvector3.add(mvec_to, from_pos)

	local damage = self._damage * (dmg_mul or 1)
	local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	local player_hit, player_ray_data = nil

	if shoot_player and self._hit_player then
		player_hit, player_ray_data = self:damage_player(col_ray, from_pos, direction, result)

		if player_hit then
			InstantBulletBase:on_hit_player(col_ray or player_ray_data, self._unit, user_unit, damage)
		end
	end

	local char_hit = nil

	if not player_hit and col_ray then
		char_hit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
	end

	if (not col_ray or col_ray.unit ~= target_unit) and target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression then
		target_unit:character_damage():build_suppression(tweak_data.weapon[self._name_id].suppression)
	end

	if not col_ray or col_ray.distance > 600 or result.guaranteed_miss then
		local num_rays = (tweak_data.weapon[self._name_id] or {}).rays or 1

		for i = 1, num_rays, 1 do
			mvector3.set(mvec_spread, direction)

			if i > 1 then
				mvector3.spread(mvec_spread, self:_get_spread(user_unit))
			end

			self:_spawn_trail_effect(mvec_spread, col_ray)
		end
	end

	result.hit_enemy = char_hit

	if self._alert_events then
		result.rays = {
			col_ray
		}
	end

	self:_cleanup_smoke_shot()

	return result
end

function NPCRaycastWeaponBase:_check_smoke_shot(user_unit, target_unit)
	if not user_unit:movement() or not user_unit:movement().in_smoke or not alive(target_unit) then
		return
	end

	if managers.groupai:state():is_unit_team_AI(user_unit) then
		return
	end

	local in_smoke, variant = user_unit:movement():in_smoke()

	if in_smoke then
		local smoke_tweak = tweak_data.projectiles[variant]

		if smoke_tweak.accuracy_roll_chance < math.random() then
			return
		end

		if not self._ignore_unit_tables then
			self._ignore_unit_tables = {
				normal = clone(self._setup.ignore_units)
			}
		end

		local key = "smoke_" .. tostring(target_unit:key())

		if not self._ignore_unit_tables[key] then
			self._ignore_unit_tables[key] = clone(self._setup.ignore_units)

			table.insert(self._ignore_unit_tables[key], target_unit)
		end

		self._setup.ignore_units = self._ignore_unit_tables[key]

		return true, smoke_tweak.accuracy_fail_spread
	end
end

function NPCRaycastWeaponBase:_cleanup_smoke_shot()
	if self._ignore_unit_tables then
		self._setup.ignore_units = self._ignore_unit_tables.normal
	end
end

function NPCRaycastWeaponBase:_spawn_trail_effect(direction, col_ray)
	self._obj_fire:m_position(self._trail_effect_table.position)
	mvector3.set(self._trail_effect_table.normal, direction)

	local trail = World:effect_manager():spawn(self._trail_effect_table)

	if col_ray then
		World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
	end
end

function NPCRaycastWeaponBase:has_flashlight_on()
	return self._flashlight_data and self._flashlight_data.on and true or false
end

function NPCRaycastWeaponBase:flashlight_data()
	return self._flashlight_data
end

function NPCRaycastWeaponBase:flashlight_state_changed()
	if not self._flashlight_data then
		return
	end

	if not self._flashlight_data.enabled or self._flashlight_data.dropped then
		return
	end

	if managers.game_play_central:flashlights_on() then
		self._flashlight_data.light:set_enable(self._flashlight_light_lod_enabled)
		self._flashlight_data.effect:activate()

		self._flashlight_data.on = true
	else
		self._flashlight_data.light:set_enable(false)
		self._flashlight_data.effect:kill_effect()

		self._flashlight_data.on = false
	end
end

function NPCRaycastWeaponBase:set_flashlight_enabled(enabled)
	if not self._flashlight_data then
		return
	end

	self._flashlight_data.enabled = enabled

	if managers.game_play_central:flashlights_on() and enabled then
		self._flashlight_data.light:set_enable(self._flashlight_light_lod_enabled)
		self._flashlight_data.effect:activate()

		self._flashlight_data.on = true
	else
		self._flashlight_data.light:set_enable(false)
		self._flashlight_data.effect:kill_effect()

		self._flashlight_data.on = false
	end
end

function NPCRaycastWeaponBase:set_flashlight_light_lod_enabled(enabled)
	if not self._flashlight_data then
		return
	end

	self._flashlight_light_lod_enabled = enabled

	if self._flashlight_data.on and enabled then
		self._flashlight_data.light:set_enable(true)
	else
		self._flashlight_data.light:set_enable(false)
	end
end

function NPCRaycastWeaponBase:set_laser_enabled(state)
	if state then
		if alive(self._laser_unit) then
			return
		end

		local spawn_rot = self._obj_fire:rotation()
		local spawn_pos = self._obj_fire:position()
		spawn_pos = spawn_pos - spawn_rot:y() * 8 + spawn_rot:z() * 2 - spawn_rot:x() * 1.5
		self._laser_unit = World:spawn_unit(Idstring("units/payday2/weapons/wpn_npc_upg_fl_ass_smg_sho_peqbox/wpn_npc_upg_fl_ass_smg_sho_peqbox"), spawn_pos, spawn_rot)

		self._unit:link(self._obj_fire:name(), self._laser_unit)
		self._laser_unit:base():set_npc()
		self._laser_unit:base():set_on()
		self._laser_unit:base():set_color_by_theme("cop_sniper")
		self._laser_unit:base():set_max_distace(10000)
	elseif alive(self._laser_unit) then
		self._laser_unit:set_slot(0)

		self._laser_unit = nil
	end
end
