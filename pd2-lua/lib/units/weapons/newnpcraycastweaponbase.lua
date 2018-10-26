NewNPCRaycastWeaponBase = NewNPCRaycastWeaponBase or class(NewRaycastWeaponBase)
NewNPCRaycastWeaponBase._VOICES = {
	"a",
	"b",
	"c"
}
NewNPCRaycastWeaponBase._next_i_voice = {}

function NewNPCRaycastWeaponBase:init(unit)
	NewRaycastWeaponBase.super.super.init(self, unit, false)

	self._player_manager = managers.player
	self._unit = unit
	self._name_id = self.name_id or "m4_crew"
	self.name_id = nil
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
	self._shoot_through_data = {from = Vector3()}
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

	if self._multivoice then
		if not NewNPCRaycastWeaponBase._next_i_voice[self._name_id] then
			NewNPCRaycastWeaponBase._next_i_voice[self._name_id] = 1
		end

		self._voice = NewNPCRaycastWeaponBase._VOICES[NewNPCRaycastWeaponBase._next_i_voice[self._name_id]]

		if NewNPCRaycastWeaponBase._next_i_voice[self._name_id] == #NewNPCRaycastWeaponBase._VOICES then
			NewNPCRaycastWeaponBase._next_i_voice[self._name_id] = 1
		else
			NewNPCRaycastWeaponBase._next_i_voice[self._name_id] = NewNPCRaycastWeaponBase._next_i_voice[self._name_id] + 1
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

	self._textures = {}
	self._cosmetics_data = nil
	self._materials = nil

	managers.mission:add_global_event_listener(tostring(self._unit:key()), {"on_peer_removed"}, callback(self, self, "_on_peer_removed"))
end

function NewNPCRaycastWeaponBase:_on_peer_removed(peer_id)
	if self._shooting then
		local user_unit = self._setup.user_unit
		local user_peer_id = managers.criminals:character_peer_id_by_unit(user_unit)

		if peer_id == user_peer_id then
			self:stop_autofire()
		end
	end
end

function NewNPCRaycastWeaponBase:non_npc_name_id()
	if not self._non_npc_name_id then
		self._non_npc_name_id = self._name_id
		self._non_npc_name_id = string.gsub(self._non_npc_name_id, "_npc", "")
		self._non_npc_name_id = string.gsub(self._non_npc_name_id, "_crew", "")
	end

	return self._non_npc_name_id
end

function NewNPCRaycastWeaponBase:setup(setup_data)
	self._autoaim = setup_data.autoaim
	self._alert_events = setup_data.alert_AI and {} or nil
	self._alert_size = tweak_data.weapon[self._name_id].alert_size
	self._alert_fires = {}
	self._suppression = tweak_data.weapon[self._name_id].suppression
	self._bullet_slotmask = setup_data.hit_slotmask or self._bullet_slotmask
	self._character_slotmask = managers.slot:get_mask("raycastable_characters")
	self._hit_player = setup_data.hit_player and true or false
	self._setup = setup_data
	self._part_stats = managers.weapon_factory:get_stats(self._factory_id, self._blueprint)
end

function NewNPCRaycastWeaponBase:assemble(factory_id)
	NewNPCRaycastWeaponBase.super:assemble(factory_id)

	self._ammo_data = managers.weapon_factory:get_ammo_data_from_weapon(self._factory_id, self._blueprint) or {}
	local ammo_muzzle_effect = self._ammo_data and self._ammo_data.muzzleflash

	if ammo_muzzle_effect then
		self._muzzle_effect = ammo_muzzle_effect
		self._muzzle_effect_table = {
			force_synch = false,
			effect = self._muzzle_effect,
			parent = self._obj_fire
		}
	end
end

function NewNPCRaycastWeaponBase:is_npc()
	return true
end

function NewNPCRaycastWeaponBase:skip_queue()
	return true
end

function NewNPCRaycastWeaponBase:use_thq()
	return managers.weapon_factory:use_thq_weapon_parts()
end

function NewNPCRaycastWeaponBase:check_npc()
	if not self._assembly_complete then
		return
	end

	local gadgets = self._gadgets

	if gadgets then
		local gadget = nil

		for _, i in ipairs(gadgets) do
			gadget = self._parts[i]

			if gadget then
				gadget.unit:base():set_npc()
			end
		end
	end
end

function NewNPCRaycastWeaponBase:start_autofire(nr_shots)
	self:_sound_autofire_start(nr_shots)

	self._next_fire_allowed = math.max(self._next_fire_allowed, Application:time())
	self._shooting = true
end

function NewNPCRaycastWeaponBase:stop_autofire()
	self:_sound_autofire_end()

	self._shooting = nil
end

function NewNPCRaycastWeaponBase:singleshot(...)
	local fired = self:fire(...)

	if fired then
		self:_sound_singleshot()
	end

	return fired
end

function NewNPCRaycastWeaponBase:trigger_held(...)
	local fired = nil

	if self._next_fire_allowed <= Application:time() then
		fired = self:fire(...)

		if fired then
			local fire_rate = tweak_data.weapon[self._name_id] and tweak_data.weapon[self._name_id].auto and tweak_data.weapon[self._name_id].auto.fire_rate
			fire_rate = fire_rate or 0.1
			self._next_fire_allowed = self._next_fire_allowed + fire_rate
		end
	end

	return fired
end

function NewNPCRaycastWeaponBase:auto_trigger_held(direction, impact)
	local fired = false

	if self._next_fire_allowed <= Application:time() then
		fired = self:auto_fire_blank(direction, impact)

		if fired then
			local fire_rate = tweak_data.weapon[self._name_id] and tweak_data.weapon[self._name_id].auto and tweak_data.weapon[self._name_id].auto.fire_rate
			fire_rate = fire_rate or 0.1
			self._next_fire_allowed = self._next_fire_allowed + fire_rate
		end
	end

	return fired
end
local mto = Vector3()
local mfrom = Vector3()
local mspread = Vector3()

function NewNPCRaycastWeaponBase:auto_fire_blank(direction, impact)
	local user_unit = self._setup.user_unit

	self._unit:m_position(mfrom)

	local rays = {}
	local right = direction:cross(math.UP):normalized()
	local up = direction:cross(right):normalized()

	if impact and (self._use_trails == nil or self._use_trails == true) then
		local num_rays = (tweak_data.weapon[self:non_npc_name_id()] or {}).rays or 1

		if self._ammo_data and self._ammo_data.rays then
			num_rays = self._ammo_data.rays
		end

		for i = 1, num_rays, 1 do
			local spread_x, spread_y = self:_get_spread(user_unit)
			local theta = math.random() * 360
			local ax = math.sin(theta) * math.random() * spread_x
			local ay = math.cos(theta) * math.random() * (spread_y or spread_x)

			mvector3.set(mspread, direction)
			mvector3.add(mspread, right * math.rad(ax))
			mvector3.add(mspread, up * math.rad(ay))
			mvector3.set(mto, mspread)
			mvector3.multiply(mto, 20000)
			mvector3.add(mto, mfrom)

			local col_ray = World:raycast("ray", mfrom, mto, "slot_mask", self._blank_slotmask, "ignore_unit", self._setup.ignore_units)

			if alive(self._obj_fire) then
				self._obj_fire:m_position(self._trail_effect_table.position)
				mvector3.set(self._trail_effect_table.normal, mspread)
			end

			local trail = nil

			if not self:weapon_tweak_data().no_trail then
				trail = alive(self._obj_fire) and (not col_ray or col_ray.distance > 650) and World:effect_manager():spawn(self._trail_effect_table) or nil
			end

			if col_ray then
				InstantBulletBase:on_collision(col_ray, self._unit, user_unit, self._damage, true)

				if trail then
					World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
				end

				table.insert(rays, col_ray)
			end
		end
	end

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(mfrom, direction)
	end

	if self._use_shell_ejection_effect then
		World:effect_manager():spawn(self._shell_ejection_effect_table)
	end

	if self:weapon_tweak_data().has_fire_animation then
		self:tweak_data_anim_play("fire")
	end

	if user_unit:movement() then
		user_unit:movement():play_redirect("recoil_single")
	end

	return true
end

function NewNPCRaycastWeaponBase:fire_blank(direction, impact)
	local user_unit = self._setup.user_unit

	self._unit:m_position(mfrom)

	local rays = {}
	local right = direction:cross(math.UP):normalized()
	local up = direction:cross(right):normalized()

	if impact and (self._use_trails == nil or self._use_trails == true) then
		local num_rays = (tweak_data.weapon[self:non_npc_name_id()] or {}).rays or 1

		if self._ammo_data and self._ammo_data.rays then
			num_rays = self._ammo_data.rays
		end

		for i = 1, num_rays, 1 do
			local spread_x, spread_y = self:_get_spread(user_unit)
			local theta = math.random() * 360
			local ax = math.sin(theta) * math.random() * spread_x
			local ay = math.cos(theta) * math.random() * (spread_y or spread_x)

			mvector3.set(mspread, direction)
			mvector3.add(mspread, right * math.rad(ax))
			mvector3.add(mspread, up * math.rad(ay))
			mvector3.set(mto, mspread)
			mvector3.multiply(mto, 20000)
			mvector3.add(mto, mfrom)

			local col_ray = World:raycast("ray", mfrom, mto, "slot_mask", self._blank_slotmask, "ignore_unit", self._setup.ignore_units)

			if alive(self._obj_fire) then
				self._obj_fire:m_position(self._trail_effect_table.position)
				mvector3.set(self._trail_effect_table.normal, mspread)
			end

			local trail = nil

			if not self:weapon_tweak_data().no_trail then
				trail = alive(self._obj_fire) and (not col_ray or col_ray.distance > 650) and World:effect_manager():spawn(self._trail_effect_table) or nil
			end

			if col_ray then
				InstantBulletBase:on_collision(col_ray, self._unit, user_unit, self._damage, true)

				if trail then
					World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
				end

				table.insert(rays, col_ray)
			end
		end
	end

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(mfrom, direction)
	end

	if self._use_shell_ejection_effect then
		World:effect_manager():spawn(self._shell_ejection_effect_table)
	end

	if self:weapon_tweak_data().has_fire_animation then
		self:tweak_data_anim_play("fire")
	end

	self:_sound_singleshot()
end

function NewNPCRaycastWeaponBase:_spawn_muzzle_effect(from_pos, direction)
	World:effect_manager():spawn(self._muzzle_effect_table)
end

function NewNPCRaycastWeaponBase:destroy(unit)
	RaycastWeaponBase.super.pre_destroy(self, unit)
	managers.weapon_factory:disassemble(self._parts)

	if self._shooting then
		self:stop_autofire()
	end

	managers.mission:remove_global_event_listener(tostring(self._unit:key()))
end

function NewNPCRaycastWeaponBase:_get_spread(user_unit)
	local weapon_tweak = tweak_data.weapon[self:non_npc_name_id()]

	if not weapon_tweak then
		return 3
	end

	local spread_values = weapon_tweak.spread

	if not spread_values then
		Application:error("No spread values for weapon: ", self:non_npc_name_id())

		return 3
	end

	local pose = user_unit:movement()._moving and "moving_standing" or "standing"
	local spread_stat_value = math.clamp(weapon_tweak.stats.spread + (self._part_stats and self._part_stats.spread or 0), 1, #tweak_data.weapon.stats.spread)
	local spread_pose_value = spread_values[pose] or 3
	local spread_x, spread_y = nil

	if type(spread_pose_value) == "table" then
		spread_x = spread_pose_value[1] * tweak_data.weapon.stats.spread[spread_stat_value]
		spread_y = spread_pose_value[2] * tweak_data.weapon.stats.spread[spread_stat_value]
	else
		spread_x = spread_pose_value * tweak_data.weapon.stats.spread[spread_stat_value]
		spread_y = spread_x
	end

	if self._part_stats and self._part_stats.spread_multi then
		spread_x = spread_x * (self._part_stats.spread_multi[1] or 0)
		spread_y = spread_y * (self._part_stats.spread_multi[2] or 0)
	end

	return spread_x, spread_y
end

function NewNPCRaycastWeaponBase:_sound_autofire_start(nr_shots)
	self._sound_fire:stop()

	local tweak_sound = tweak_data.weapon[self._name_id].sounds
	local sound_name = tweak_sound.prefix .. self._setup.user_sound_variant .. self._voice .. (nr_shots and "_" .. tostring(nr_shots) .. "shot" or "_loop")
	local sound = self._sound_fire:post_event(sound_name, callback(self, self, "_on_auto_fire_stop"), nil, "end_of_event")

	if not sound then
		sound_name = tweak_sound.prefix .. "1" .. self._voice .. "_end"
		sound = self._sound_fire:post_event(sound_name)
	end
end

function NewNPCRaycastWeaponBase:_on_auto_fire_stop()
	if self._shooting then
		self:_sound_autofire_start()
	end
end

function NewNPCRaycastWeaponBase:_sound_autofire_end()
	local tweak_sound = tweak_data.weapon[self._name_id].sounds
	local sound_name = tweak_sound.prefix .. self._setup.user_sound_variant .. self._voice .. "_end"
	local sound = self._sound_fire:post_event(sound_name)

	if not sound then
		sound_name = tweak_sound.prefix .. "1" .. self._voice .. "_end"
		sound = self._sound_fire:post_event(sound_name)
	end
end

function NewNPCRaycastWeaponBase:_sound_singleshot()
	local tweak_sound = tweak_data.weapon[self._name_id].sounds
	local sound_name = tweak_sound.prefix .. self._setup.user_sound_variant .. self._voice .. "_1shot"
	local sound = self._sound_fire:post_event(sound_name)

	if not sound then
		sound_name = tweak_sound.prefix .. "1" .. self._voice .. "_1shot"
		sound = self._sound_fire:post_event(sound_name)
	end
end

function NewNPCRaycastWeaponBase:set_user_is_team_ai(enabled)
	self._is_team_ai = enabled
end
local mvec_to = Vector3()
local mvec_spread = Vector3()
local mvec1 = Vector3()

function NewNPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, shoot_through_data)
	local result = {}
	local hit_unit = nil
	local ray_distance = shoot_through_data and shoot_through_data.ray_distance or self._weapon_range or 20000

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	local damage = self._damage * (dmg_mul or 1)
	local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
	local col_ray = (ray_from_unit or World):raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

	if shoot_through_data and shoot_through_data.has_hit_wall then
		if not col_ray then
			return result
		end

		mvector3.set(mvec1, col_ray.ray)
		mvector3.multiply(mvec1, -5)
		mvector3.add(mvec1, col_ray.position)

		local ray_blocked = World:raycast("ray", mvec1, shoot_through_data.from, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "report")

		if ray_blocked then
			return result
		end
	end

	local right = direction:cross(math.UP):normalized()
	local up = direction:cross(right):normalized()

	if col_ray then
		if col_ray.unit:in_slot(self._character_slotmask) then
			hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
		elseif shoot_player and self._hit_player and self:damage_player(col_ray, from_pos, direction) then
			InstantBulletBase:on_hit_player(col_ray, self._unit, user_unit, self._damage * (dmg_mul or 1))
		else
			hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
		end
	elseif shoot_player and self._hit_player then
		local hit, ray_data = self:damage_player(col_ray, from_pos, direction)

		if hit then
			InstantBulletBase:on_hit_player(ray_data, self._unit, user_unit, damage)
		end
	end

	if not col_ray or col_ray.distance > 600 then
		local name_id = self.non_npc_name_id and self:non_npc_name_id() or self._name_id
		local num_rays = (tweak_data.weapon[name_id] or {}).rays or 1

		for i = 1, num_rays, 1 do
			mvector3.set(mvec_spread, direction)

			if i > 1 then
				local spread_x, spread_y = self:_get_spread(user_unit)
				local theta = math.random() * 360
				local ax = math.sin(theta) * math.random() * spread_x
				local ay = math.cos(theta) * math.random() * (spread_y or spread_x)

				mvector3.add(mvec_spread, right * math.rad(ax))
				mvector3.add(mvec_spread, up * math.rad(ay))
			end

			self:_spawn_trail_effect(mvec_spread, col_ray)
		end
	end

	result.hit_enemy = hit_unit

	if self._alert_events then
		result.rays = {col_ray}
	end

	if col_ray and col_ray.unit then
		local ap_skill = self._is_team_ai and managers.player:has_category_upgrade("team", "crew_ai_ap_ammo")

		repeat
			if hit_unit and not ap_skill then
				break
			end

			if col_ray.distance < 0.1 or ray_distance - col_ray.distance < 50 then
				break
			end

			local has_hit_wall = shoot_through_data and shoot_through_data.has_hit_wall
			local has_passed_shield = shoot_through_data and shoot_through_data.has_passed_shield
			local is_shoot_through, is_shield, is_wall = nil

			if not hit_unit then
				local is_world_geometry = col_ray.unit:in_slot(managers.slot:get_mask("world_geometry"))

				if is_world_geometry then
					is_shoot_through = not col_ray.body:has_ray_type(Idstring("ai_vision"))

					if not is_shoot_through then
						if has_hit_wall or not ap_skill then
							break
						end

						is_wall = true
					end
				else
					if not ap_skill then
						break
					end

					is_shield = col_ray.unit:in_slot(8) and alive(col_ray.unit:parent())
				end
			end

			if not hit_unit and not is_shoot_through and not is_shield and not is_wall then
				break
			end

			local ray_from_unit = (hit_unit or is_shield) and col_ray.unit
			self._shoot_through_data.has_hit_wall = has_hit_wall or is_wall
			self._shoot_through_data.has_passed_shield = has_passed_shield or is_shield
			self._shoot_through_data.ray_from_unit = ray_from_unit
			self._shoot_through_data.ray_distance = ray_distance - col_ray.distance

			mvector3.set(self._shoot_through_data.from, direction)
			mvector3.multiply(self._shoot_through_data.from, is_shield and 5 or 40)
			mvector3.add(self._shoot_through_data.from, col_ray.position)
			managers.game_play_central:queue_fire_raycast(Application:time() + 0.0125, self._unit, user_unit, self._shoot_through_data.from, mvector3.copy(direction), dmg_mul, shoot_player, self._shoot_through_data)
		until true
	end

	return result
end

function NewNPCRaycastWeaponBase:_spawn_trail_effect(direction, col_ray)
	if not alive(self._obj_fire) then
		return
	end

	self._obj_fire:m_position(self._trail_effect_table.position)
	mvector3.set(self._trail_effect_table.normal, direction)

	local trail = World:effect_manager():spawn(self._trail_effect_table)

	if col_ray then
		World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
	end
end

function NewNPCRaycastWeaponBase:has_flashlight_on()
	return self._flashlight_data and self._flashlight_data.on and true or false
end

function NewNPCRaycastWeaponBase:flashlight_data()
	return self._flashlight_data
end

function NewNPCRaycastWeaponBase:flashlight_state_changed()
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

function NewNPCRaycastWeaponBase:set_flashlight_enabled(enabled)
	if not self._flashlight_data then
		return
	end

	if not self._assembly_complete then
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

function NewNPCRaycastWeaponBase:set_flashlight_light_lod_enabled(enabled)
	if not self._flashlight_data then
		return
	end

	if not self._assembly_complete then
		return
	end

	self._flashlight_light_lod_enabled = enabled

	if self._flashlight_data.on and enabled then
		self._flashlight_data.light:set_enable(true)
	else
		self._flashlight_data.light:set_enable(false)
	end
end

function NewNPCRaycastWeaponBase:set_underbarrel(underbarrel_id, enabled)
	underbarrel_id = underbarrel_id .. "_npc"

	if enabled then
		self._name_id = underbarrel_id
	else
		self._name_id = self.name_id
	end
end

