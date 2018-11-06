ArrowBase = ArrowBase or class(ProjectileBase)
ArrowBase._arrow_units = {}
local mvec1 = Vector3()
local mrot1 = Rotation()
local ids_pickup = Idstring("pickup")

function ArrowBase:_setup_from_tweak_data(arrow_entry)
	local arrow_entry = self._tweak_projectile_entry or "west_arrow"
	local tweak_entry = tweak_data.projectiles[arrow_entry]
	self._damage_class_string = tweak_data.projectiles[self._tweak_projectile_entry].bullet_class or "InstantBulletBase"
	self._damage_class = CoreSerialize.string_to_classtable(self._damage_class_string)
	self._mass_look_up_modifier = tweak_entry.mass_look_up_modifier
	self._damage = tweak_entry.damage or 1
	self._slot_mask = managers.slot:get_mask("arrow_impact_targets")
end

function ArrowBase:set_owner_peer_id(peer_id)
	self._owner_peer_id = peer_id
	ArrowBase._arrow_units[peer_id] = ArrowBase._arrow_units[peer_id] or {}
	ArrowBase._arrow_units[peer_id][self._unit:key()] = self._unit

	if peer_id == managers.network:session():local_peer():id() then
		self._unit:add_body_activation_callback(callback(self, self, "clbk_body_activation"))
		self._unit:body("dynamic_body"):set_deactivate_tag(ids_pickup)
	end
end

function ArrowBase:owner_peer_id()
	return self._owner_peer_id
end

function ArrowBase:set_weapon_unit(weapon_unit)
	ArrowBase.super.set_weapon_unit(self, weapon_unit)

	self._weapon_damage_mult = weapon_unit and weapon_unit:base().projectile_damage_multiplier and weapon_unit:base():projectile_damage_multiplier() or 1
	self._weapon_charge_value = weapon_unit and weapon_unit:base().projectile_charge_value and weapon_unit:base():projectile_charge_value() or 1
	self._weapon_speed_mult = weapon_unit and weapon_unit:base().projectile_speed_multiplier and weapon_unit:base():projectile_speed_multiplier() or 1
	self._weapon_charge_fail = weapon_unit and weapon_unit:base():charge_fail() or false

	if not self._weapon_charge_fail then
		self:add_trail_effect()
	end
end

function ArrowBase:add_trail_effect()
	managers.game_play_central:add_projectile_trail(self._unit, self._unit:orientation_object())
end

function ArrowBase:_on_collision(col_ray)
	local damage_mult = self._weapon_damage_mult or 1
	local loose_shoot = self._weapon_charge_fail

	if not loose_shoot and alive(col_ray.unit) then
		local client_damage = self._damage_class_string == "InstantExplosiveBulletBase" or alive(col_ray.unit) and col_ray.unit:id() ~= -1

		if Network:is_server() or client_damage then
			self._damage_class:on_collision(col_ray, self._weapon_unit or self._unit, self._thrower_unit, self._damage * damage_mult, false, false)
		end
	end

	if not loose_shoot and tweak_data.projectiles[self._tweak_projectile_entry].remove_on_impact then
		self._unit:set_slot(0)

		return
	end

	self._unit:body("dynamic_body"):set_deactivate_tag(Idstring())

	self._col_ray = col_ray

	self:_attach_to_hit_unit(nil, loose_shoot)
end

function ArrowBase:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	ArrowBase.super.clbk_impact(self, tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)

	if not self._is_pickup and not self._sweep_data then
		self._unit:set_enabled(false)
		self:_check_stop_flyby_sound()
		self:_kill_trail()

		if tweak_data.projectiles[self._tweak_projectile_entry].remove_on_impact then
			self._unit:set_slot(0)

			return
		end
	end
end

function ArrowBase:throw(...)
	self:_tweak_data_play_sound("flyby")

	self._requires_stop_flyby_sound = true

	ArrowBase.super.throw(self, ...)
	self:reload_contour()
end

function ArrowBase:clbk_body_activation(tag, unit, body, activated)
	if not activated and tag == ids_pickup then
		local pos = self._unit:position()

		self:_on_collision({
			distance = 0,
			position = pos,
			hit_position = pos,
			normal = math.UP,
			ray = -math.UP,
			velocity = Vector3()
		})
	end
end

function ArrowBase:sync_throw_projectile(dir, projectile_type)
	self:throw({
		dir = dir,
		projectile_entry = projectile_type
	})
	self._unit:damage():add_body_collision_callback(callback(self._unit:base(), self._unit:base(), "clbk_impact"))
end

function ArrowBase:add_damage_result(unit, is_dead, damage_percent)
	if not alive(self._thrower_unit) or self._thrower_unit ~= managers.player:player_unit() then
		return
	end

	local unit_type = unit:base()._tweak_table
	local is_civlian = unit:character_damage().is_civilian(unit_type)

	if is_civlian or not is_dead then
		return
	end

	GrenadeBase._check_achievements(self, unit, true, 1, 1, 1)
end

local tmp_vel = Vector3()

function ArrowBase:update(unit, t, dt)
	if self._drop_in_sync_data then
		self._drop_in_sync_data.f = self._drop_in_sync_data.f - 1

		if self._drop_in_sync_data.f < 0 then
			local parent_unit = self._drop_in_sync_data.parent_unit

			if alive(parent_unit) then
				local state = self._drop_in_sync_data.state
				local parent_body = parent_unit:body(state.sync_attach_data.parent_body_index)
				local parent_obj = parent_body:root_object()

				self:sync_attach_to_unit(false, parent_unit, parent_body, parent_obj, state.sync_attach_data.local_pos, state.sync_attach_data.dir, true)
			end

			self._drop_in_sync_data = nil
		end
	end

	if _G.IS_VR and not self._is_pickup then
		local autohit_dir = self:_calculate_autohit_direction()

		if autohit_dir then
			local body = self._unit:body(0)

			mvector3.set(tmp_vel, body:velocity())

			local speed = mvector3.normalize(tmp_vel)

			mvector3.step(tmp_vel, tmp_vel, autohit_dir, dt * 0.15)
			body:set_velocity(tmp_vel * speed)
		end
	end

	ArrowBase.super.update(self, unit, t, dt)

	if self._draw_debug_cone then
		local tip = unit:position()
		local base = tip + unit:rotation():y() * -35

		Application:draw_cone(tip, base, 3, 0, 0, 1)
	end
end

local tmp_vec1 = Vector3()

function ArrowBase:_calculate_autohit_direction()
	local enemies = managers.enemy:all_enemies()
	local pos = self._unit:position()
	local dir = self._unit:rotation():y()
	local closest_dis, closest_pos = nil

	for u_key, enemy_data in pairs(enemies) do
		local enemy = enemy_data.unit

		if enemy:base():lod_stage() == 1 and not enemy:in_slot(16) then
			local com = enemy:movement():m_head_pos()

			mvector3.direction(tmp_vec1, pos, com)

			local angle = mvector3.angle(dir, tmp_vec1)

			if angle < 30 then
				local dis = mvector3.distance_sq(pos, com)

				if not closest_dis or dis < closest_dis then
					closest_dis = dis
					closest_pos = com
				end
			end
		end
	end

	if closest_pos then
		mvector3.direction(tmp_vec1, pos, closest_pos)

		return tmp_vec1
	end
end

function ArrowBase:_switch_to_pickup_delayed(dynamic)
	self._is_pickup = true
	self._is_pickup_dynamic = dynamic

	self:_remove_switch_to_pickup_clbk()

	self._switch_to_pickup_clbk = "_switch_to_pickup " .. tostring(self._unit:key())

	managers.enemy:add_delayed_clbk(self._switch_to_pickup_clbk, callback(self, self, "_switch_to_pickup_delay_cbk", dynamic), TimerManager:game():time() + 1)
end

function ArrowBase:_switch_to_pickup_delay_cbk(dynamic)
	self._switch_to_pickup_clbk = nil

	self:_switch_to_pickup(dynamic)
end

function ArrowBase:_switch_to_pickup(dynamic)
	print("ArrowBase:_switch_to_pickup dynamic", dynamic)

	self._is_pickup = true
	self._is_pickup_dynamic = dynamic

	self:_remove_switch_to_pickup_clbk()

	if dynamic then
		self._unit:unlink()
	end

	self._unit:set_slot(20)
	self._unit:set_enabled(true)
	self:_set_body_enabled(dynamic)
end

function ArrowBase:_check_stop_flyby_sound(skip_impact)
	if not self._requires_stop_flyby_sound then
		return
	end

	self._requires_stop_flyby_sound = nil

	self:_tweak_data_play_sound("flyby_stop")

	if not skip_impact then
		self:_tweak_data_play_sound("impact")
	end
end

function ArrowBase:_attach_to_hit_unit(is_remote, dynamic_pickup_wanted)
	local instant_dynamic_pickup = dynamic_pickup_wanted and (is_remote or Network:is_server())
	self._attached_to_unit = true

	self:reload_contour()
	self._unit:set_enabled(true)
	self:_set_body_enabled(instant_dynamic_pickup)
	self:_check_stop_flyby_sound(dynamic_pickup_wanted)
	self:_kill_trail()
	mrotation.set_look_at(mrot1, self._col_ray.velocity, math.UP)
	self._unit:set_rotation(mrot1)

	local hit_unit = self._col_ray.unit
	local switch_to_pickup = true
	local switch_to_dynamic_pickup = instant_dynamic_pickup or not alive(hit_unit)
	local local_pos = nil
	local global_pos = self._col_ray.position
	local parent_obj, child_obj, parent_body = nil

	if switch_to_dynamic_pickup then
		self._unit:set_position(global_pos)
		self._unit:set_position(global_pos)

		if alive(hit_unit) and hit_unit:character_damage() then
			self:_set_body_enabled(false)
		end

		self:_set_body_enabled(true)
	elseif alive(hit_unit) then
		local damage_ext = hit_unit:character_damage()

		if damage_ext and damage_ext.get_impact_segment then
			parent_obj, child_obj = damage_ext:get_impact_segment(self._col_ray.position)

			if parent_obj then
				if not child_obj then
					hit_unit:link(parent_obj:name(), self._unit, self._unit:orientation_object():name())
				else
					local parent_pos = parent_obj:position()
					local child_pos = child_obj:position()
					local segment_dir = Vector3()
					local segment_dist = mvector3.direction(segment_dir, parent_pos, child_pos)
					local collision_to_parent = Vector3()

					mvector3.set(collision_to_parent, global_pos)
					mvector3.subtract(collision_to_parent, parent_pos)

					local projected_dist = mvector3.dot(collision_to_parent, segment_dir)
					projected_dist = math.clamp(projected_dist, 0, segment_dist)
					local projected_pos = parent_pos + projected_dist * segment_dir
					local max_dist_from_segment = 10
					local dir_from_segment = Vector3()
					local dist_from_segment = mvector3.direction(dir_from_segment, projected_pos, global_pos)

					if max_dist_from_segment < dist_from_segment then
						global_pos = projected_pos + max_dist_from_segment * dir_from_segment
					end

					local_pos = global_pos - parent_pos:rotate_with(parent_obj:rotation():inverse())
				end
			end

			if not hit_unit:character_damage():dead() and damage_ext:can_kill() then
				switch_to_pickup = false
			end
		elseif damage_ext and damage_ext.can_attach_projectiles and not damage_ext:can_attach_projectiles() then
			switch_to_dynamic_pickup = true
		elseif not alive(self._col_ray.body) or not self._col_ray.body:enabled() then
			local_pos = global_pos - hit_unit:position():rotate_with(hit_unit:rotation():inverse())
			switch_to_dynamic_pickup = true
		else
			parent_body = self._col_ray.body
			parent_obj = self._col_ray.body:root_object()
			local_pos = global_pos - parent_obj:position():rotate_with(parent_obj:rotation():inverse())
		end

		if damage_ext and not damage_ext:dead() and damage_ext.add_listener and not self._death_listener_id then
			self._death_listener_id = "ArrowBase_death" .. tostring(self._unit:key())

			damage_ext:add_listener(self._death_listener_id, {
				"death"
			}, callback(self, self, "clbk_hit_unit_death"))
		end

		local hit_base = hit_unit:base()

		if hit_base and hit_base.add_destroy_listener and not self._destroy_listener_id then
			self._destroy_listener_id = "ArrowBase_destroy" .. tostring(self._unit:key())

			hit_base:add_destroy_listener(self._destroy_listener_id, callback(self, self, "clbk_hit_unit_destroyed"))
		end

		if hit_base and hit_base._tweak_table == tweak_data.achievement.pincushion.enemy and alive(self:weapon_unit()) and self:weapon_unit():base():is_category(tweak_data.achievement.pincushion.weapon_category) then
			hit_base._num_attached_arrows = (hit_base._num_attached_arrows or 0) + 1

			if hit_base._num_attached_arrows == tweak_data.achievement.pincushion.count then
				managers.achievment:award(tweak_data.achievement.pincushion.award)
			end
		end
	end

	self._unit:set_position(global_pos)
	self._unit:set_position(global_pos)

	if parent_obj then
		hit_unit:link(parent_obj:name(), self._unit)
	else
		print("ArrowBase:_attach_to_hit_unit(): No parent object!!")
	end

	if not switch_to_dynamic_pickup then
		local vip_unit = hit_unit and hit_unit:parent() or hit_unit

		if vip_unit and vip_unit:base() and vip_unit:base()._tweak_table == "phalanx_vip" then
			switch_to_pickup = true
			switch_to_dynamic_pickup = true
		end
	end

	if switch_to_pickup then
		if switch_to_dynamic_pickup then
			self:_set_body_enabled(true)
		end

		self:_switch_to_pickup_delayed(switch_to_dynamic_pickup)
	end

	if alive(hit_unit) and parent_body then
		self._attached_body_disabled_cbk_data = {
			cbk = callback(self, self, "_cbk_attached_body_disabled"),
			unit = hit_unit,
			body = parent_body
		}

		hit_unit:add_body_enabled_callback(self._attached_body_disabled_cbk_data.cbk)
	end

	if not is_remote then
		local dir = self._col_ray.velocity

		mvector3.normalize(dir)

		if managers.network:session() then
			local unit = alive(hit_unit) and hit_unit:id() ~= -1 and hit_unit

			managers.network:session():send_to_peers_synched("sync_attach_projectile", self._unit:id() ~= -1 and self._unit or nil, dynamic_pickup_wanted or false, unit or nil, unit and parent_body or nil, unit and parent_obj or nil, unit and local_pos or self._unit:position(), dir, tweak_data.blackmarket:get_index_from_projectile_id(self._tweak_projectile_entry), managers.network:session():local_peer():id())
		end
	end

	if alive(hit_unit) then
		local dir = self._col_ray.velocity

		mvector3.normalize(dir)

		if parent_body then
			local id = hit_unit:editor_id()

			if id ~= -1 then
				self._sync_attach_data = {
					parent_unit = hit_unit,
					parent_unit_id = id,
					parent_body = parent_body,
					local_pos = local_pos or self._unit:position(),
					dir = dir
				}
			end
		else
			local id = hit_unit:id()

			if id ~= -1 then
				self._sync_attach_data = {
					character = true,
					parent_unit = hit_unit:id() ~= -1 and hit_unit or nil,
					parent_obj = hit_unit:id() ~= -1 and parent_obj or nil,
					parent_body = hit_unit:id() ~= -1 and parent_body or nil,
					local_pos = hit_unit:id() ~= -1 and local_pos or self._unit:position(),
					dir = dir
				}
			end
		end
	end
end

function ArrowBase:sync_attach_to_unit(instant_dynamic_pickup, parent_unit, parent_body, parent_obj, local_pos, dir, drop_in)
	if parent_body then
		parent_obj = parent_body:root_object()
	end

	local world_position = nil

	if drop_in then
		world_position = self._unit:position()
		dir = self._unit:rotation():y()
	elseif parent_obj then
		world_position = local_pos:rotate_with(parent_obj:rotation()) + parent_obj:position()
	elseif alive(parent_unit) and parent_body then
		world_position = local_pos:rotate_with(parent_unit:rotation()) + parent_unit:position()
	else
		world_position = local_pos
	end

	self._col_ray = {
		position = world_position,
		unit = parent_unit,
		body = parent_body,
		velocity = dir
	}

	if not parent_obj and not instant_dynamic_pickup then
		local col_ray = World:raycast("ray", world_position - 10 * dir, world_position + 10 * dir, "slot_mask", self._slot_mask, "ignore_unit", self._unit)

		if col_ray and col_ray.unit then
			self._col_ray = col_ray
			self._col_ray.velocity = dir

			if not drop_in and self._damage_class_string ~= "InstantExplosiveBulletBase" and col_ray.unit:in_slot(managers.slot:get_mask("bullet_blank_impact_targets")) then
				self._damage_class:on_collision(col_ray, self:weapon_unit(), self:thrower_unit(), self._damage, true)
			end
		end
	end

	self:_attach_to_hit_unit(true, instant_dynamic_pickup)
end

function ArrowBase:_cbk_attached_body_disabled(unit, body)
	if not self._attached_body_disabled_cbk_data then
		print("Got callback but didn't have data!")

		return
	end

	if self._attached_body_disabled_cbk_data.body ~= body then
		return
	end

	if not body:enabled() then
		self:_remove_attached_body_disabled_cbk()

		if not self._is_dynamic_pickup then
			self:_switch_to_pickup(true)
		end
	end
end

function ArrowBase:_remove_attached_body_disabled_cbk()
	if self._attached_body_disabled_cbk_data and alive(self._attached_body_disabled_cbk_data.unit) then
		self._attached_body_disabled_cbk_data.unit:remove_body_enabled_callback(self._attached_body_disabled_cbk_data.cbk)
	end

	self._attached_body_disabled_cbk_data = nil
end

function ArrowBase:_set_body_enabled(enabled)
	self._unit:body("dynamic_body"):set_enabled(enabled)

	if enabled then
		self._unit:body("dynamic_body"):set_dynamic()
	else
		self._unit:body("dynamic_body"):set_keyframed()
	end
end

function ArrowBase:clbk_hit_unit_death()
	print("ArrowBase:clbk_hit_unit_death()")

	self._death_listener_id = nil

	self:_switch_to_pickup()
end

function ArrowBase:clbk_hit_unit_destroyed()
	print("ArrowBase:clbk_hit_unit_destroyed()")

	self._destroy_listener_id = nil

	self:_switch_to_pickup(true)
end

ArrowBase.DEFUALT_SOUNDS = {
	impact = "arrow_impact_gen",
	flyby_stop = "arrow_flyby_stop",
	flyby = "arrow_flyby"
}

function ArrowBase:_tweak_data_play_sound(entry)
	local tweak_entry = tweak_data.projectiles[self._tweak_projectile_entry]
	local event = tweak_entry.sounds and tweak_entry.sounds[entry]
	event = event or ArrowBase.DEFUALT_SOUNDS[entry]

	self._unit:sound_source(Idstring("snd")):post_event(event)
end

function ArrowBase:outside_worlds_bounding_box()
	if Network:is_server() or self._unit:id() == -1 then
		self._unit:set_slot(0)
	end
end

function ArrowBase:save(data)
	ArrowBase.super.save(self, data)

	local state = {
		is_pickup = self._is_pickup,
		is_pickup_dynamic = self._is_pickup_dynamic
	}

	if not self._sync_attach_data then
		state.is_pickup = true
		state.is_pickup_dynamic = true
	end

	if not state.is_pickup_dynamic and self._sync_attach_data then
		if self._sync_attach_data.character then
			local peer = managers.network:session():dropin_peer()

			managers.enemy:add_delayed_clbk("delay_sync_attach" .. tostring(self._unit:key()), callback(self, self, "_delay_sync_attach", peer), TimerManager:game():time() + 0.1)
		else
			state.sync_attach_data = {
				parent_unit_id = self._sync_attach_data.parent_unit_id
			}

			if self._sync_attach_data.parent_body then
				state.sync_attach_data.parent_body_index = self._sync_attach_data.parent_unit:get_body_index(self._sync_attach_data.parent_body:name())
			else
				print("no parent body", self._sync_attach_data.parent_unit)
			end

			state.sync_attach_data.local_pos = self._sync_attach_data.local_pos
			state.sync_attach_data.dir = self._sync_attach_data.dir
		end
	end

	data.ArrowBase = state
end

function ArrowBase:load(data)
	ArrowBase.super.load(self, data)

	local state = data.ArrowBase

	if state.is_pickup then
		self:_switch_to_pickup(state.is_pickup_dynamic)
	end

	if not state.is_pickup_dynamic then
		print(inspect(state.sync_attach_data))

		if state.sync_attach_data then
			local function _dropin_attach(parent_unit)
				local parent_body = parent_unit:body(state.sync_attach_data.parent_body_index)
				local parent_obj = parent_body:root_object()
				self._drop_in_sync_data = {
					f = 2,
					parent_unit = parent_unit,
					state = state
				}
			end

			local parent_unit = managers.worlddefinition:get_unit_on_load(state.sync_attach_data.parent_unit_id, _dropin_attach)

			if alive(parent_unit) then
				_dropin_attach(parent_unit)
			end
		end
	end
end

function ArrowBase:_delay_sync_attach(peer)
	if not managers.network:session() then
		return
	end

	if not peer then
		return
	end

	if not alive(self._sync_attach_data.parent_unit) then
		return
	end

	peer:send_queued_sync("sync_attach_projectile", self._unit:id() ~= -1 and self._unit or nil, false, self._sync_attach_data.parent_unit, nil, self._sync_attach_data.parent_obj, self._sync_attach_data.local_pos, self._sync_attach_data.dir, tweak_data.blackmarket:get_index_from_projectile_id(self._tweak_projectile_entry), managers.network:session():local_peer():id())
end

function ArrowBase:_remove_switch_to_pickup_clbk()
	if not self._switch_to_pickup_clbk or not managers.enemy then
		return
	end

	managers.enemy:remove_delayed_clbk(self._switch_to_pickup_clbk)

	self._switch_to_pickup_clbk = nil
end

function ArrowBase:_kill_trail()
	managers.game_play_central:remove_projectile_trail(self._unit)
end

function ArrowBase:destroy(unit)
	self:_check_stop_flyby_sound()

	if self._owner_peer_id and ArrowBase._arrow_units[self._owner_peer_id] then
		ArrowBase._arrow_units[self._owner_peer_id][self._unit:key()] = nil
	end

	if self._death_listener_id and alive(self._col_ray.unit) then
		self._col_ray.unit:character_damage():remove_listener(self._death_listener_id)
	end

	self._death_listener_id = nil

	if self._destroy_listener_id and alive(self._col_ray.unit) then
		self._col_ray.unit:base():remove_destroy_listener(self._destroy_listener_id)
	end

	self._destroy_listener_id = nil

	self:_remove_switch_to_pickup_clbk()
	self:_remove_attached_body_disabled_cbk()
	self:_kill_trail()
	ArrowBase.super.destroy(self, unit)
end

function ArrowBase.find_nearest_arrow(peer_id, position)
	local closest_unit, closest_dist_sq = nil

	if not ArrowBase._arrow_units or not ArrowBase._arrow_units[peer_id] then
		print("ArrowBase.find_nearest_arrow - arrow not found!")
		print(inspect(ArrowBase._arrow_units))

		return
	end

	for key, unit in pairs(ArrowBase._arrow_units[peer_id]) do
		if unit:id() == -1 then
			unit:m_position(mvec1)

			local dist_sq = mvector3.distance_sq(position, mvec1)

			if not closest_unit or dist_sq < closest_dist_sq then
				closest_unit = unit
				closest_dist_sq = dist_sq
			end
		end
	end

	return closest_unit
end

function ArrowBase:reload_contour()
	if self._unit:contour() then
		if managers.user:get_setting("throwable_contour") then
			self._unit:contour():add("deployable_selected")
			self._unit:contour():_upd_opacity(self._attached_to_unit and 1 or 0)
		else
			self._unit:contour():remove("deployable_selected")
		end
	end
end
