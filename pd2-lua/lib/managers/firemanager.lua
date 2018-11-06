FireManager = FireManager or class()
local idstr_small_light_fire = Idstring("effects/particles/fire/small_light_fire")
local idstr_explosion_std = Idstring("explosion_std")
local empty_idstr = Idstring("")
local molotov_effect = "effects/payday2/particles/explosions/molotov_grenade"
local tmp_vec3 = Vector3()

function FireManager:init()
	self._enemies_on_fire = {}
	self._dozers_on_fire = {}
	self._doted_enemies = {}
	self._fire_dot_grace_period = 1
	self._fire_dot_tick_period = 1
end

function FireManager:update(t, dt)
	for index = #self._doted_enemies, 1, -1 do
		local dot_info = self._doted_enemies[index]

		if t > dot_info.fire_damage_received_time + self._fire_dot_grace_period and dot_info.fire_dot_counter >= 0.5 then
			self:_damage_fire_dot(dot_info)

			dot_info.fire_dot_counter = 0
		end

		if t > dot_info.fire_damage_received_time + dot_info.dot_length then
			if dot_info.fire_effects then
				for _, fire_effect_id in ipairs(dot_info.fire_effects) do
					World:effect_manager():fade_kill(fire_effect_id)
				end
			end

			self:_remove_flame_effects_from_doted_unit(dot_info.enemy_unit)
			self:_stop_burn_body_sound(dot_info.sound_source)
			table.remove(self._doted_enemies, index)

			if dot_info.enemy_unit and alive(dot_info.enemy_unit) then
				self._dozers_on_fire[dot_info.enemy_unit:id()] = nil
			end
		else
			dot_info.fire_dot_counter = dot_info.fire_dot_counter + dt
		end
	end
end

function FireManager:check_achievemnts(unit, t)
	if not unit and not alive(unit) then
		return
	end

	if not unit:base() or not unit:base()._tweak_table then
		return
	end

	if CopDamage.is_civilian(unit:base()._tweak_table) then
		return
	end

	for i = #self._enemies_on_fire, 1, -1 do
		local data = self._enemies_on_fire[i]

		if t - data.t > 5 or data.unit == unit then
			table.remove(self._enemies_on_fire, i)
		end
	end

	table.insert(self._enemies_on_fire, {
		unit = unit,
		t = t
	})

	local count = #self._enemies_on_fire

	if count >= 10 and tweak_data.achievement.disco_inferno then
		managers.achievment:award(tweak_data.achievement.disco_inferno)
	end

	local unit_type = unit:base()._tweak_table
	local unit_id = unit:id()

	if unit_type == "tank" or unit_type == "tank_hw" then
		self._dozers_on_fire[unit_id] = self._dozers_on_fire[unit_id] or {
			t = t,
			unit = unit
		}
	end

	for dozer_id, dozer_info in pairs(self._dozers_on_fire) do
		if t - dozer_info.t >= 10 and tweak_data.achievement.overgrill then
			managers.achievment:award(tweak_data.achievement.overgrill)
		end
	end
end

function FireManager:remove_dead_dozer_from_overgrill(dozer_id)
	self._dozers_on_fire[dozer_id] = nil
end

function FireManager:is_set_on_fire(unit)
	for key, dot_info in ipairs(self._doted_enemies) do
		if dot_info.enemy_unit == unit then
			return true
		end
	end

	return false
end

function FireManager:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	local contains = false

	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if dot_info.enemy_unit == enemy_unit then
				dot_info.fire_damage_received_time = fire_damage_received_time
				contains = true
			end
		end

		if not contains then
			local dot_info = {
				fire_dot_counter = 0,
				enemy_unit = enemy_unit,
				fire_damage_received_time = fire_damage_received_time,
				weapon_unit = weapon_unit,
				dot_length = dot_length,
				dot_damage = dot_damage,
				user_unit = user_unit,
				is_molotov = is_molotov
			}

			table.insert(self._doted_enemies, dot_info)
			self:_start_enemy_fire_effect(dot_info)
			self:start_burn_body_sound(dot_info)
		end

		self:check_achievemnts(enemy_unit, fire_damage_received_time)
	end
end

function FireManager:sync_add_fire_dot(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	if enemy_unit then
		local t = TimerManager:game():time()

		self:_add_doted_enemy(enemy_unit, t, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	end
end

function FireManager:add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	local dot_info = self:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)

	managers.network:session():send_to_peers_synched("sync_add_doted_enemy", enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
end

function FireManager:_remove_flame_effects_from_doted_unit(enemy_unit)
	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if dot_info.fire_effects then
				for __, fire_effect_id in ipairs(dot_info.fire_effects) do
					World:effect_manager():fade_kill(fire_effect_id)
				end
			end
		end
	end
end

function FireManager:start_burn_body_sound(dot_info, delay)
	local sound_loop_burn_body = SoundDevice:create_source("FireBurnBody")

	sound_loop_burn_body:set_position(dot_info.enemy_unit:position())
	sound_loop_burn_body:post_event("burn_loop_body")

	dot_info.sound_source = sound_loop_burn_body

	if delay then
		managers.enemy:add_delayed_clbk("FireBurnBody", callback(self, self, "_stop_burn_body_sound", sound_loop_burn_body), TimerManager:game():time() + delay - 0.5)
	end
end

function FireManager:_stop_burn_body_sound(sound_source)
	sound_source:post_event("burn_loop_body_stop")
	managers.enemy:add_delayed_clbk("FireBurnBodyFade", callback(self, self, "_release_sound_source", {
		sound_source = sound_source
	}), TimerManager:game():time() + 0.5)
end

function FireManager:_release_sound_source(...)
end

local tmp_used_flame_objects = nil

function FireManager:_start_enemy_fire_effect(dot_info)
	local num_objects = #tweak_data.fire.fire_bones
	local num_effects = math.random(3, num_objects)

	if not tmp_used_flame_objects then
		tmp_used_flame_objects = {}

		for _, effect in ipairs(tweak_data.fire.fire_bones) do
			table.insert(tmp_used_flame_objects, false)
		end
	end

	local idx = 1
	local effect_id = nil
	local effects_table = {}

	for i = 1, num_effects, 1 do
		while tmp_used_flame_objects[idx] do
			idx = math.random(1, num_objects)
		end

		local effect = tweak_data.fire.effects.endless[tweak_data.fire.effects_cost[i]]
		local bone = dot_info.enemy_unit:get_object(Idstring(tweak_data.fire.fire_bones[idx]))

		if bone then
			effect_id = World:effect_manager():spawn({
				effect = Idstring(effect),
				parent = bone
			})

			table.insert(effects_table, effect_id)
		end

		tmp_used_flame_objects[idx] = true
	end

	dot_info.fire_effects = effects_table

	for idx, _ in ipairs(tmp_used_flame_objects) do
		tmp_used_flame_objects[idx] = false
	end
end

function FireManager:_damage_fire_dot(dot_info)
	if dot_info.user_unit and dot_info.user_unit == managers.player:player_unit() or not dot_info.user_unit and Network:is_server() then
		local attacker_unit = managers.player:player_unit()
		local col_ray = {
			unit = dot_info.enemy_unit
		}
		local damage = dot_info.dot_damage
		local ignite_character = false
		local variant = "fire"
		local weapon_unit = dot_info.weapon_unit
		local is_fire_dot_damage = true
		local is_molotov = dot_info.is_molotov

		FlameBulletBase:give_fire_damage_dot(col_ray, weapon_unit, attacker_unit, damage, is_fire_dot_damage, is_molotov)
	end
end

function FireManager:give_local_player_dmg(pos, range, damage, ignite_character)
	local player = managers.player:player_unit()

	if player then
		player:character_damage():damage_fire({
			variant = "fire",
			position = pos,
			range = range,
			damage = damage,
			ignite_character = ignite_character
		})
	end
end

function FireManager:detect_and_give_dmg(params)
	local hit_pos = params.hit_pos
	local slotmask = params.collision_slotmask
	local user_unit = params.user
	local dmg = params.damage
	local player_dmg = params.player_damage or dmg
	local range = params.range
	local ignore_unit = params.ignore_unit
	local curve_pow = params.curve_pow
	local col_ray = params.col_ray
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local owner = params.owner
	local push_units = false
	local fire_dot_data = params.fire_dot_data
	local results = {}
	local alert_radius = params.alert_radius or 3000
	local is_molotov = params.is_molotov

	if params.push_units ~= nil then
		push_units = params.push_units
	end

	local player = managers.player:player_unit()

	if alive(player) and player_dmg ~= 0 then
		player:character_damage():damage_fire({
			variant = "fire",
			position = hit_pos,
			range = range,
			damage = player_dmg,
			ignite_character = params.ignite_character
		})
	end

	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, slotmask)
	local alert_unit = user_unit

	if alive(alert_unit) and alert_unit:base() and alert_unit:base().thrower_unit then
		alert_unit = alert_unit:base():thrower_unit()
	end

	managers.groupai:state():propagate_alert({
		"fire",
		hit_pos,
		alert_radius,
		alert_filter,
		alert_unit
	})

	local splinters = {
		mvector3.copy(hit_pos)
	}
	local dirs = {
		Vector3(range, 0, 0),
		Vector3(-range, 0, 0),
		Vector3(0, range, 0),
		Vector3(0, -range, 0),
		Vector3(0, 0, range),
		Vector3(0, 0, -range)
	}
	local pos = Vector3()

	for _, dir in ipairs(dirs) do
		mvector3.set(pos, dir)
		mvector3.add(pos, hit_pos)

		local splinter_ray = nil

		if ignore_unit then
			splinter_ray = World:raycast("ray", hit_pos, pos, "ignore_unit", ignore_unit, "slot_mask", slotmask)
		else
			splinter_ray = World:raycast("ray", hit_pos, pos, "slot_mask", slotmask)
		end

		pos = (splinter_ray and splinter_ray.position or pos) - dir:normalized() * math.min(splinter_ray and splinter_ray.distance or 0, 10)
		local near_splinter = false

		for _, s_pos in ipairs(splinters) do
			if mvector3.distance_sq(pos, s_pos) < 900 then
				near_splinter = true

				break
			end
		end

		if not near_splinter then
			table.insert(splinters, mvector3.copy(pos))
		end
	end

	local count_cops = 0
	local count_gangsters = 0
	local count_civilians = 0
	local count_cop_kills = 0
	local count_gangster_kills = 0
	local count_civilian_kills = 0
	local characters_hit = {}
	local units_to_push = {}
	local hit_units = {}
	local ignore_units = {}

	if not params.no_raycast_check_characters then
		for _, hit_body in ipairs(bodies) do
			local character = hit_body:unit():character_damage() and hit_body:unit():character_damage().damage_fire

			if character then
				table.insert(ignore_units, hit_body:unit())
			end
		end
	end

	local type = nil

	for _, hit_body in ipairs(bodies) do
		local character = hit_body:unit():character_damage() and hit_body:unit():character_damage().damage_fire
		local apply_dmg = hit_body:extension() and hit_body:extension().damage
		units_to_push[hit_body:unit():key()] = hit_body:unit()
		local dir, len, damage, ray_hit = nil

		if character and not characters_hit[hit_body:unit():key()] then
			if params.no_raycast_check_characters then
				ray_hit = true
				characters_hit[hit_body:unit():key()] = true
			else
				for i_splinter, s_pos in ipairs(splinters) do
					ray_hit = not World:raycast("ray", s_pos, hit_body:center_of_mass(), "slot_mask", slotmask, "ignore_unit", ignore_units, "report")

					if ray_hit then
						characters_hit[hit_body:unit():key()] = true

						break
					end
				end
			end

			if ray_hit then
				local hit_unit = hit_body:unit()

				if hit_unit:base() and hit_unit:base()._tweak_table and not hit_unit:character_damage():dead() then
					type = hit_unit:base()._tweak_table

					if CopDamage.is_civilian(type) then
						count_civilians = count_civilians + 1
					elseif CopDamage.is_gangster(type) then
						count_gangsters = count_gangsters + 1
					elseif type ~= "russian" and type ~= "german" and type ~= "spanish" and type ~= "american" and type ~= "jowi" then
						if type == "hoxton" then
							-- Nothing
						else
							count_cops = count_cops + 1
						end
					end
				end
			end
		elseif apply_dmg or hit_body:dynamic() then
			ray_hit = true
		end

		if ray_hit then
			dir = hit_body:center_of_mass()
			len = mvector3.direction(dir, hit_pos, dir)
			damage = dmg

			if apply_dmg then
				self:_apply_body_damage(true, hit_body, user_unit, dir, damage)
			end

			damage = math.max(damage, 1)
			local hit_unit = hit_body:unit()
			hit_units[hit_unit:key()] = hit_unit

			if character then
				local dead_before = hit_unit:character_damage():dead()
				local action_data = {
					variant = "fire",
					damage = damage,
					attacker_unit = user_unit,
					weapon_unit = owner,
					ignite_character = params.ignite_character,
					col_ray = self._col_ray or {
						position = hit_body:position(),
						ray = dir
					},
					is_fire_dot_damage = false,
					fire_dot_data = fire_dot_data,
					is_molotov = is_molotov
				}
				local t = TimerManager:game():time()

				hit_unit:character_damage():damage_fire(action_data)

				if not dead_before and hit_unit:base() and hit_unit:base()._tweak_table and hit_unit:character_damage():dead() then
					type = hit_unit:base()._tweak_table

					if CopDamage.is_civilian(type) then
						count_civilian_kills = count_civilian_kills + 1
					elseif CopDamage.is_gangster(type) then
						count_gangster_kills = count_gangster_kills + 1
					elseif type ~= "russian" and type ~= "german" and type ~= "spanish" then
						if type == "american" then
							-- Nothing
						else
							count_cop_kills = count_cop_kills + 1
						end
					end
				end
			end
		end
	end

	if push_units and push_units == true then
		managers.explosion:units_to_push(units_to_push, hit_pos, range)
	end

	if owner then
		results.count_cops = count_cops
		results.count_gangsters = count_gangsters
		results.count_civilians = count_civilians
		results.count_cop_kills = count_cop_kills
		results.count_gangster_kills = count_gangster_kills
		results.count_civilian_kills = count_civilian_kills
	end

	return hit_units, splinters, results
end

function FireManager:units_to_push(units_to_push, hit_pos, range)
end

function FireManager:_apply_body_damage(is_server, hit_body, user_unit, dir, damage)
	local hit_unit = hit_body:unit()
	local local_damage = is_server or hit_unit:id() == -1
	local sync_damage = is_server and hit_unit:id() ~= -1

	if not local_damage and not sync_damage then
		print("_apply_body_damage skipped")

		return
	end

	local normal = dir
	local prop_damage = math.min(damage, 200)

	if prop_damage < 0.25 then
		prop_damage = math.round(prop_damage, 0.25)
	end

	if prop_damage == 0 then
		-- Nothing
	end

	if prop_damage > 0 then
		local local_damage = is_server or hit_unit:id() == -1
		local sync_damage = is_server and hit_unit:id() ~= -1
		local network_damage = math.ceil(prop_damage * 163.84)
		prop_damage = network_damage / 163.84

		if local_damage then
			hit_body:extension().damage:damage_fire(user_unit, normal, hit_body:position(), dir, prop_damage)
			hit_body:extension().damage:damage_damage(user_unit, normal, hit_body:position(), dir, prop_damage)
		end

		if sync_damage and managers.network:session() then
			if alive(user_unit) then
				managers.network:session():send_to_peers_synched("sync_body_damage_fire", hit_body, user_unit, normal, hit_body:position(), dir, math.min(32768, network_damage))
			else
				managers.network:session():send_to_peers_synched("sync_body_damage_fire_no_attacker", hit_body, normal, hit_body:position(), dir, math.min(32768, network_damage))
			end
		end
	end
end

function FireManager:explode_on_client(position, normal, user_unit, dmg, range, curve_pow, custom_params)
	self:play_sound_and_effects(position, normal, range, custom_params)
	self:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
end

function FireManager:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
	local bodies = World:find_bodies("intersect", "sphere", position, range, managers.slot:get_mask("bullet_impact_targets"))
	local units_to_push = {}

	for _, hit_body in ipairs(bodies) do
		local hit_unit = hit_body:unit()
		local apply_dmg = hit_body:extension() and hit_body:extension().damage and hit_unit:id() == -1
		local dir, len, damage = nil

		if apply_dmg then
			dir = hit_body:center_of_mass()
			len = mvector3.direction(dir, position, dir)
			damage = dmg * math.pow(math.clamp(1 - len / range, 0, 1), curve_pow)

			self:_apply_body_damage(false, hit_body, user_unit, dir, damage)
		end
	end

	self:units_to_push(units_to_push, position, range)
end

function FireManager:play_sound_and_effects(position, normal, range, custom_params, molotov_damage_effect_table)
	self:player_feedback(position, normal, range, custom_params)
	self:spawn_sound_and_effects(position, normal, range, custom_params and custom_params.effect, custom_params and custom_params.sound_event, custom_params and custom_params.on_unit, custom_params and custom_params.idstr_decal, custom_params and custom_params.idstr_effect, molotov_damage_effect_table, custom_params.sound_event_burning, custom_params.sound_event_impact_duration or 0, custom_params.sound_event_duration or 0)
end

function FireManager:player_feedback(position, normal, range, custom_params)
end

local decal_ray_from = Vector3()
local decal_ray_to = Vector3()

function FireManager:spawn_sound_and_effects(position, normal, range, effect_name, sound_event, on_unit, idstr_decal, idstr_effect, molotov_damage_effect_table, sound_event_burning, sound_event_impact_duration, sound_event_duration)
	effect_name = effect_name or "effects/payday2/particles/explosions/molotov_grenade"
	local effect_id = nil

	if molotov_damage_effect_table ~= nil then
		if effect_name ~= "none" then
			effect_id = World:effect_manager():spawn({
				effect = Idstring(effect_name),
				position = position,
				normal = normal
			})
		end

		table.insert(molotov_damage_effect_table, {
			effect_id = effect_id,
			detonation_position = position,
			detonation_normal = normal
		})
	end

	local slotmask_world_geometry = managers.slot:get_mask("world_geometry")

	if on_unit then
		mvector3.set(decal_ray_from, position)
		mvector3.set(decal_ray_to, normal)
		mvector3.multiply(decal_ray_to, 100)
		mvector3.add(decal_ray_from, decal_ray_to)
		mvector3.multiply(decal_ray_to, -2)
		mvector3.add(decal_ray_to, decal_ray_from)
	else
		mvector3.set(decal_ray_from, position)
		mvector3.set(decal_ray_to, math.UP)
		mvector3.multiply(decal_ray_to, -100)
		mvector3.add(decal_ray_to, decal_ray_from)
	end

	local ray = World:raycast("ray", decal_ray_from, decal_ray_to, "slot_mask", slotmask_world_geometry)
	local sound_switch_name = nil

	if ray then
		local material_name, _, _ = World:pick_decal_material(ray.unit, decal_ray_from, decal_ray_to, slotmask_world_geometry)
		sound_switch_name = material_name ~= empty_idstr and material_name
	end

	if (effect_name == molotov_effect and molotov_damage_effect_table ~= nil and #molotov_damage_effect_table <= 1 or effect_name ~= molotov_effect) and sound_event ~= "no_sound" then
		local sound_source = SoundDevice:create_source("MolotovImpact")

		sound_source:set_position(position)

		if sound_switch_name then
			sound_source:set_switch("materials", managers.game_play_central:material_name(sound_switch_name))
		end

		sound_source:post_event(sound_event)
		managers.enemy:add_delayed_clbk("MolotovImpact", callback(FireManager, FireManager, "_dispose_of_impact_sound", {
			position = position,
			sound_event_duration = sound_event_duration,
			sound_event_impact_duration = sound_event_impact_duration
		}), TimerManager:game():time() + sound_event_impact_duration)
		managers.enemy:add_delayed_clbk("MolotovImpact", callback(GrenadeBase, GrenadeBase, "_dispose_of_sound", {
			sound_source = sound_source
		}), TimerManager:game():time() + sound_event_impact_duration)
	end

	self:project_decal(ray, decal_ray_from, decal_ray_to, on_unit and ray and ray.unit, idstr_decal, idstr_effect)
end

function FireManager:project_decal(ray, from, to, on_unit, idstr_decal, idstr_effect)
end

function FireManager:_dispose_of_impact_sound(custom_params)
	local sound_source_burning_loop = SoundDevice:create_source("MolotovBurning")

	sound_source_burning_loop:set_position(custom_params.position)
	sound_source_burning_loop:post_event("burn_loop_gen")

	local molotov_tweak = tweak_data.env_effect:molotov_fire()
	local t = custom_params.sound_event_duration or tonumber(molotov_tweak.burn_duration)

	managers.enemy:add_delayed_clbk("MolotovBurning", callback(FireManager, FireManager, "_fade_out_burn_loop_sound", {
		position = custom_params.position,
		sound_source = sound_source_burning_loop
	}), TimerManager:game():time() + t - custom_params.sound_event_impact_duration)
end

function FireManager:_fade_out_burn_loop_sound(custom_params)
	local fade_duration = 2

	custom_params.sound_source:post_event("burn_loop_gen_stop_fade")
	managers.enemy:add_delayed_clbk("MolotovFading", callback(GrenadeBase, GrenadeBase, "_dispose_of_sound", custom_params), TimerManager:game():time() + fade_duration)
end

function FireManager:on_simulation_ended()
	self._enemies_on_fire = {}
	self._dozers_on_fire = {}
end
