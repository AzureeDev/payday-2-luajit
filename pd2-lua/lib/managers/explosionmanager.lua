ExplosionManager = ExplosionManager or class()
local idstr_small_light_fire = Idstring("effects/particles/fire/small_light_fire")
local idstr_explosion_std = Idstring("explosion_std")
local empty_idstr = Idstring("")
local molotov_effect = "effects/payday2/particles/explosions/molotov_grenade"
local tmp_vec3 = Vector3()

function ExplosionManager:init()
	self._sustain_effects = {}
end

function ExplosionManager:update(t, dt)
	for i, effect in ipairs(self._sustain_effects) do
		if effect.expire_t < t then
			World:effect_manager():fade_kill(effect.id)
			table.remove(self._sustain_effects, i)
		end
	end
end

function ExplosionManager:add_sustain_effect(effect_id, sustain_time)
	table.insert(self._sustain_effects, {
		id = effect_id,
		expire_t = Application:time() + sustain_time
	})
end

function ExplosionManager:give_local_player_dmg(pos, range, damage, ignite_character)
	local player = managers.player:player_unit()

	if player then
		player:character_damage():damage_explosion({
			variant = "explosion",
			position = pos,
			range = range,
			damage = damage,
			ignite_character = ignite_character
		})
	end
end

function ExplosionManager:units_to_push(units_to_push, hit_pos, range)
	for u_key, unit in pairs(units_to_push) do
		if alive(unit) then
			local is_character = unit:character_damage() and unit:character_damage().damage_explosion

			if not is_character or unit:character_damage():dead() then
				if is_character and unit:movement() and unit:movement()._active_actions and unit:movement()._active_actions[1] and unit:movement()._active_actions[1]:type() == "hurt" then
					unit:movement()._active_actions[1]:force_ragdoll(true)
				end

				local nr_u_bodies = unit:num_bodies()
				local rot_acc = Vector3(1 - math.rand(2), 1 - math.rand(2), 1 - math.rand(2)) * 10
				local i_u_body = 0

				while nr_u_bodies > i_u_body do
					local u_body = unit:body(i_u_body)

					if u_body:enabled() and u_body:dynamic() then
						local body_mass = u_body:mass()
						local len = mvector3.direction(tmp_vec3, hit_pos, u_body:center_of_mass())
						local body_vel = u_body:velocity()
						local vel_dot = mvector3.dot(body_vel, tmp_vec3)
						local max_vel = 800

						if vel_dot < max_vel then
							mvector3.set_z(tmp_vec3, mvector3.z(tmp_vec3) + 0.75)

							local push_vel = (1 - len / range) * (max_vel - math.max(vel_dot, 0))

							mvector3.multiply(tmp_vec3, push_vel)
							World:play_physic_effect(Idstring("physic_effects/body_explosion"), u_body, tmp_vec3, body_mass / math.random(2), u_body:position(), rot_acc, 1)
						end
					end

					i_u_body = i_u_body + 1
				end
			end
		end
	end
end

function ExplosionManager:_apply_body_damage(is_server, hit_body, user_unit, dir, damage)
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
			hit_body:extension().damage:damage_explosion(user_unit, normal, hit_body:position(), dir, prop_damage)
			hit_body:extension().damage:damage_damage(user_unit, normal, hit_body:position(), dir, prop_damage)
		end

		if sync_damage and managers.network:session() then
			if alive(user_unit) then
				managers.network:session():send_to_peers_synched("sync_body_damage_explosion", hit_body, user_unit, normal, hit_body:position(), dir, math.min(32768, network_damage))
			else
				managers.network:session():send_to_peers_synched("sync_body_damage_explosion_no_attacker", hit_body, normal, hit_body:position(), dir, math.min(32768, network_damage))
			end
		end
	end
end

function ExplosionManager:explode_on_client(position, normal, user_unit, dmg, range, curve_pow, custom_params)
	self:play_sound_and_effects(position, normal, range, custom_params)
	self:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
end

function ExplosionManager:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
	local bodies = World:find_bodies("intersect", "sphere", position, range, managers.slot:get_mask("bullet_impact_targets"))
	local units_to_push = {}

	for _, hit_body in ipairs(bodies) do
		local hit_unit = hit_body:unit()
		units_to_push[hit_body:unit():key()] = hit_unit
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

function ExplosionManager:play_sound_and_effects(position, normal, range, custom_params, molotov_damage_effect_table)
	self:player_feedback(position, normal, range, custom_params)
	self:spawn_sound_and_effects(position, normal, range, custom_params and custom_params.effect, custom_params and custom_params.sound_event, custom_params and custom_params.on_unit, custom_params and custom_params.idstr_decal, custom_params and custom_params.idstr_effect, molotov_damage_effect_table)
end

function ExplosionManager:player_feedback(position, normal, range, custom_params)
	local player = managers.player:player_unit()

	if player then
		local range = custom_params and custom_params.feedback_range or range
		local feedback = managers.feedback:create("mission_triggered")
		local distance = mvector3.distance_sq(position, player:position())
		local mul = math.clamp(1 - distance / (range * range), 0, 1)
		local camera_shake_mul = custom_params and custom_params.camera_shake_mul or mul * (custom_params and custom_params.camera_shake_max_mul or 1)

		feedback:set_unit(player)
		feedback:set_enabled("camera_shake", true)
		feedback:set_enabled("rumble", true)
		feedback:set_enabled("above_camera_effect", false)

		local params = {
			"camera_shake",
			"multiplier",
			camera_shake_mul,
			"camera_shake",
			"amplitude",
			0.5,
			"camera_shake",
			"attack",
			0.05,
			"camera_shake",
			"sustain",
			0.15,
			"camera_shake",
			"decay",
			0.5,
			"rumble",
			"multiplier_data",
			mul,
			"rumble",
			"peak",
			0.5,
			"rumble",
			"attack",
			0.05,
			"rumble",
			"sustain",
			0.15,
			"rumble",
			"release",
			0.5
		}

		feedback:play(unpack(params))

		if custom_params and custom_params.sound_muffle_effect then
			local sound_eff_range = range / 4
			local sound_eff_mul = math.clamp(1 - distance / (sound_eff_range * sound_eff_range), 0, 1)

			if sound_eff_mul >= 0.3 then
				player:character_damage():on_flashbanged(sound_eff_mul)
			end
		end
	end
end

local decal_ray_from = Vector3()
local decal_ray_to = Vector3()

function ExplosionManager:spawn_sound_and_effects(position, normal, range, effect_name, sound_event, on_unit, idstr_decal, idstr_effect, molotov_damage_effect_table)
	effect_name = effect_name or "effects/particles/explosions/explosion_grenade_launcher"
	local effect_id = nil
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

	if effect_name ~= "none" then
		if ray and ray.body and ray.body:root_object() then
			local pos = ray.body:root_object():to_local(ray.position)
			effect_id = World:effect_manager():spawn({
				effect = Idstring(effect_name),
				position = pos,
				normal = normal,
				parent = ray.body:root_object()
			})
		else
			effect_id = World:effect_manager():spawn({
				effect = Idstring(effect_name),
				position = position,
				normal = normal
			})
		end
	end

	if molotov_damage_effect_table ~= nil then
		table.insert(molotov_damage_effect_table, {
			effect_id = effect_id,
			detonation_position = position,
			detonation_normal = normal
		})
	end

	local sound_switch_name = nil

	if ray then
		local material_name, _, _ = World:pick_decal_material(ray.unit, decal_ray_from, decal_ray_to, slotmask_world_geometry)
		sound_switch_name = material_name ~= empty_idstr and material_name
	end

	if effect_name == molotov_effect and molotov_damage_effect_table ~= nil and #molotov_damage_effect_table <= 1 or effect_name ~= molotov_effect then
		sound_event = sound_event or "trip_mine_explode"

		if sound_event ~= "no_sound" then
			local sound_source = SoundDevice:create_source("ExplosionManager")

			sound_source:set_position(position)

			if sound_switch_name then
				sound_source:set_switch("materials", managers.game_play_central:material_name(sound_switch_name))
			end

			sound_source:post_event(sound_event)
			managers.enemy:add_delayed_clbk("ExplosionManager", callback(ProjectileBase, ProjectileBase, "_dispose_of_sound", {
				sound_source = sound_source
			}), TimerManager:game():time() + 4)
		end
	end

	if idstr_decal ~= false then
		self:project_decal(ray, decal_ray_from, decal_ray_to, on_unit and ray and ray.unit, idstr_decal, idstr_effect)
	end
end

function ExplosionManager:project_decal(ray, from, to, on_unit, idstr_decal, idstr_effect)
	local slotmask_world_geometry = managers.slot:get_mask("world_geometry")

	if ray then
		local units = on_unit or World:find_units("intersect", "cylinder", from, to, 100, slotmask_world_geometry)
		local redir_name = World:project_decal(idstr_decal or idstr_explosion_std, ray.position, ray.ray, on_unit or units, nil, ray.normal)

		if redir_name ~= empty_idstr then
			if ray and ray.body and ray.body:root_object() then
				local pos = ray.body:root_object():to_local(ray.position)

				World:effect_manager():spawn({
					effect = redir_name,
					position = pos,
					normal = ray.normal,
					parent = ray.body:root_object()
				})
			else
				World:effect_manager():spawn({
					effect = redir_name,
					position = ray.position,
					normal = ray.normal
				})
			end
		end

		if not idstr_effect or idstr_effect ~= empty_idstr then
			local id = nil

			if ray and ray.body and ray.body:root_object() then
				local pos = ray.body:root_object():to_local(ray.position)
				id = World:effect_manager():spawn({
					effect = idstr_effect or idstr_small_light_fire,
					position = pos,
					normal = ray.normal,
					parent = ray.body:root_object()
				})
			else
				id = World:effect_manager():spawn({
					effect = idstr_effect or idstr_small_light_fire,
					position = ray.position,
					normal = ray.normal
				})
			end

			self:add_sustain_effect(id, 2 + math.rand(3))
		end
	end
end

function ExplosionManager:_detect_hits(params)
	local hit_pos = params.hit_pos
	local slotmask = params.collision_slotmask
	local range = params.range
	local ignore_unit = params.ignore_unit
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

	local function is_alive_character(unit)
		return unit:character_damage() and unit:character_damage().dead and not unit:character_damage():dead()
	end

	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, slotmask)
	local results = {
		bodies_detected = bodies,
		splinters = splinters,
		units_detected = {},
		characters_detected = {},
		bodies_hit = {},
		units_hit = {},
		characters_hit = {}
	}
	local ignore_units = {
		ignore_unit
	}

	if not params.no_raycast_check_characters then
		for _, hit_body in ipairs(bodies) do
			local unit = hit_body:unit()

			if is_alive_character(unit) and not table.contains(ignore_units, unit) then
				table.insert(ignore_units, unit)
			end
		end
	end

	for _, hit_body in ipairs(bodies) do
		local unit = hit_body:unit()
		local unit_key = unit:key()

		if unit ~= ignore_unit then
			results.units_detected[unit_key] = unit
			local character_hit = false

			if is_alive_character(unit) and not results.characters_hit[unit_key] then
				results.characters_detected[unit_key] = unit

				if params.no_raycast_check_characters then
					character_hit = true
				else
					for i_splinter, s_pos in ipairs(splinters) do
						local hit = not World:raycast("ray", s_pos, hit_body:center_of_mass(), "slot_mask", slotmask - 17, "ignore_unit", ignore_units, "report")

						if hit then
							character_hit = hit

							break
						end
					end
				end

				if character_hit then
					results.characters_hit[unit_key] = unit
				end
			end

			if character_hit or hit_body:extension() and hit_body:extension().damage or hit_body:dynamic() then
				results.units_hit[unit_key] = unit
				results.bodies_hit[unit_key] = results.bodies_hit[unit_key] or {}

				table.insert(results.bodies_hit[unit_key], hit_body)
			end
		end
	end

	return results
end

function ExplosionManager:_damage_characters(characters, params, variant, damage_func_name)
	local user_unit = params.user
	local owner = params.owner
	local damage = params.damage
	local hit_pos = params.hit_pos
	local col_ray = params.col_ray
	local range = params.range
	local curve_pow = params.curve_pow
	local verify_callback = params.verify_callback
	local ignite_character = params.ignite_character
	damage_func_name = damage_func_name or "damage_explosion"
	local counts = {
		cops = {
			kills = 0,
			hits = 0
		},
		gangsters = {
			kills = 0,
			hits = 0
		},
		civilians = {
			kills = 0,
			hits = 0
		},
		criminals = {
			kills = 0,
			hits = 0
		}
	}
	local criminal_names = CriminalsManager.character_names()
	local dir, len, type, count_table = nil

	for key, unit in pairs(characters) do
		dir = unit:position()
		len = mvector3.direction(dir, hit_pos, dir)
		local can_damage = not verify_callback

		if verify_callback then
			can_damage = verify_callback(unit)
		end

		if can_damage then
			if unit:character_damage()[damage_func_name] then
				local action_data = {
					variant = variant or "explosion"
				}

				if damage > 0 then
					action_data.damage = math.max(damage * math.pow(math.clamp(1 - len / range, 0, 1), curve_pow), 1)
				else
					action_data.damage = 0
				end

				action_data.attacker_unit = user_unit
				action_data.weapon_unit = owner
				action_data.col_ray = col_ray or {
					position = unit:position(),
					ray = dir
				}
				action_data.ignite_character = ignite_character

				unit:character_damage()[damage_func_name](unit:character_damage(), action_data)
			else
				debug_pause("unit: ", unit, " is missing " .. tostring(damage_func_name) .. " implementation")
			end
		end

		if unit:base() and unit:base()._tweak_table then
			type = unit:base()._tweak_table

			if table.contains(criminal_names, CriminalsManager.convert_new_to_old_character_workname(type)) then
				count_table = counts.criminals
			elseif CopDamage.is_civilian(type) then
				count_table = counts.civilians
			elseif CopDamage.is_gangster(type) then
				count_table = counts.gangsters
			else
				count_table = counts.cops
			end

			count_table.hits = count_table.hits + 1

			if unit:character_damage():dead() then
				count_table.kills = count_table.kills + 1
			end
		end
	end

	local results = {
		count_cops = counts.cops.hits,
		count_gangsters = counts.gangsters.hits,
		count_civilians = counts.civilians.hits,
		count_criminals = counts.criminals.hits,
		count_cop_kills = counts.cops.kills,
		count_gangster_kills = counts.gangsters.kills,
		count_civilian_kills = counts.civilians.kills,
		count_criminal_kills = counts.criminals.kills
	}

	return results
end

function ExplosionManager:detect_and_tase(params)
	local user_unit = params.user
	local owner = params.owner
	local hit_pos = params.hit_pos
	local tase_strength = params.tase_strength or "light"
	local verify_callback = params.verify_callback
	local alert_radius = params.alert_radius or 10000
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local alert_unit = user_unit

	if alive(alert_unit) and alert_unit:base() and alert_unit:base().thrower_unit then
		alert_unit = alert_unit:base():thrower_unit()
	end

	managers.groupai:state():propagate_alert({
		"explosion",
		hit_pos,
		alert_radius,
		alert_filter,
		alert_unit
	})

	local detect_results = self:_detect_hits(params)
	local damage_results = self:_damage_characters(detect_results.characters_hit, params, tase_strength, "damage_tase", verify_callback)
	local results = {}

	if owner then
		results.count_cops = damage_results.count_cops
		results.count_gangsters = damage_results.count_gangsters
		results.count_civilians = damage_results.count_civilians
		results.count_cop_kills = damage_results.count_cop_kills
		results.count_gangster_kills = damage_results.count_gangster_kills
		results.count_civilian_kills = damage_results.count_civilian_kills
	end

	return detect_results.units_hit, detect_results.splinters, results
end

function ExplosionManager:detect_and_stun(params)
	local user_unit = params.user
	local owner = params.owner
	local hit_pos = params.hit_pos
	local verify_callback = params.verify_callback
	local alert_radius = params.alert_radius or 10000
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local alert_unit = user_unit

	if alive(alert_unit) and alert_unit:base() and alert_unit:base().thrower_unit then
		alert_unit = alert_unit:base():thrower_unit()
	end

	managers.groupai:state():propagate_alert({
		"explosion",
		hit_pos,
		alert_radius,
		alert_filter,
		alert_unit
	})

	local detect_results = self:_detect_hits(params)
	local damage_results = self:_damage_characters(detect_results.characters_hit, params, "stun", "stun_hit", verify_callback)
	local results = {}

	if owner then
		results.count_cops = damage_results.count_cops
		results.count_gangsters = damage_results.count_gangsters
		results.count_civilians = damage_results.count_civilians
		results.count_cop_kills = damage_results.count_cop_kills
		results.count_gangster_kills = damage_results.count_gangster_kills
		results.count_civilian_kills = damage_results.count_civilian_kills
	end

	return detect_results.units_hit, detect_results.splinters, results
end

function ExplosionManager:detect_and_give_dmg(params)
	local user_unit = params.user
	local owner = params.owner
	local damage = params.damage
	local player_damage = params.player_damage or damage
	local range = params.range
	local hit_pos = params.hit_pos
	local alert_radius = params.alert_radius or 10000
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local alert_unit = user_unit

	if alive(alert_unit) and alert_unit:base() and alert_unit:base().thrower_unit then
		alert_unit = alert_unit:base():thrower_unit()
	end

	local push_units = true

	if params.push_units ~= nil then
		push_units = params.push_units
	end

	local player = managers.player:player_unit()

	if alive(player) and player_damage ~= 0 then
		player:character_damage():damage_explosion({
			variant = "explosion",
			position = hit_pos,
			range = range,
			damage = player_damage,
			ignite_character = params.ignite_character
		})
	end

	managers.groupai:state():propagate_alert({
		"explosion",
		hit_pos,
		alert_radius,
		alert_filter,
		alert_unit
	})

	local detect_results = self:_detect_hits(params)
	local damage_results = self:_damage_characters(detect_results.characters_hit, params)
	local results = {}

	if owner then
		results.count_cops = damage_results.count_cops
		results.count_gangsters = damage_results.count_gangsters
		results.count_civilians = damage_results.count_civilians
		results.count_cop_kills = damage_results.count_cop_kills
		results.count_gangster_kills = damage_results.count_gangster_kills
		results.count_civilian_kills = damage_results.count_civilian_kills
	end

	if push_units and push_units == true then
		self:units_to_push(detect_results.units_detected, hit_pos, range)
	end

	return detect_results.units_hit, detect_results.splinters, results
end
