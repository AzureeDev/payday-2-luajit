AnimatedVehicleBase = AnimatedVehicleBase or class(UnitBase)

function AnimatedVehicleBase:init(unit)
	AnimatedVehicleBase.super.init(self, unit, false)

	self._unit = unit

	if unit:anim_state_machine() then
		self:_set_anim_lod(0)
	end

	self._body_name = self._body_name or "a_body"
	self._allow_sync = false
	self._stored_pos = nil
	self._stored_rot = nil
end

function AnimatedVehicleBase:update(unit, t, dt)
	local new_pos = self._obj_com:position()

	if new_pos ~= self._last_pos and alive(self._listener_obj) then
		local new_vel = new_pos - self._last_pos

		mvector3.divide(new_vel, dt)

		self._last_pos = new_pos
		local listener_pos = self._listener_obj:position()
		local listener_vec = listener_pos - new_pos
		local listener_dis = mvector3.normalize(listener_vec)
		local vel_dot = mvector3.dot(listener_vec, new_vel)
		vel_dot = math.clamp(vel_dot / 15000, -1, 1)

		self._sound_source:set_rtpc("vel_to_listener", vel_dot)
		self:_set_anim_lod(listener_dis)
	end
end

function AnimatedVehicleBase:_set_anim_lod(dis)
	if dis > 9000 then
		if self._lod_high then
			self._lod_high = false

			self._unit:set_animation_lod(2, 0, 0, 0)
		end
	elseif dis < 8000 and not self._lod_high then
		self._lod_high = true

		self._unit:set_animation_lod(1, 1000000, 1000000, 1000000)
	end
end

function AnimatedVehicleBase:start_doppler()
	self:set_enabled(true)

	self._obj_com = self._unit:get_object(Idstring(self._body_name))
	self._last_pos = self._obj_com:position()
	self._listener_obj = managers.listener:active_listener_obj()
	self._sound_source = self._unit:sound_source()
end

function AnimatedVehicleBase:stop_doppler()
	self:set_enabled(false)

	self._listener_obj = nil
	self._sound_source = nil
end

function AnimatedVehicleBase:set_enabled(state)
	if state then
		if self._ext_enabled_count then
			self._ext_enabled_count = self._ext_enabled_count + 1
		else
			self._ext_enabled_count = 1

			self._unit:set_extension_update_enabled(Idstring("base"), true)
		end
	elseif self._ext_enabled_count and self._ext_enabled_count > 1 then
		self._ext_enabled_count = self._ext_enabled_count - 1
	else
		self._ext_enabled_count = nil

		self._unit:set_extension_update_enabled(Idstring("base"), false)
	end
end

function AnimatedVehicleBase:anim_clbk_empty_full_blend(unit)
	self:stop_doppler()

	if not Application:editor() then
		unit:set_animations_enabled(false)
	end
end

function AnimatedVehicleBase:anim_clbk_empty_exit(unit)
	self:start_doppler()
	unit:set_animations_enabled(true)
end

function AnimatedVehicleBase:anim_clbk_animated_driving(unit, state)
	if state and self._driving ~= "animation" then
		self._unit:set_driving("animation")

		self._driving = "animation"
	elseif not state and self._driving ~= "orientation_object" then
		self._unit:set_driving("orientation_object")

		self._driving = "orientation_object"
	end
end

function AnimatedVehicleBase:anim_clbk_save_pose(unit, pose_id)
	self._saved_poses = self._saved_poses or {}
	self._saved_poses[pose_id] = {
		position = unit:position(),
		rotation = unit:rotation()
	}
end

function AnimatedVehicleBase:anim_clbk_recall_pose(unit, pose_id, delete)
	local pose_info = self._saved_poses[pose_id]

	self._unit:set_position(pose_info.position)
	self._unit:set_rotation(pose_info.rotation)

	if delete then
		self._saved_poses[pose_id] = nil

		if not next(self._saved_poses) then
			self._saved_poses = nil
		end
	end
end

function AnimatedVehicleBase:spawn_module(module_unit_name, align_obj_name, module_id)
	local align_obj = self._unit:get_object(Idstring(align_obj_name))
	local module_unit = nil

	if type_name(module_unit_name) == "string" then
		if Network:is_server() then
			local spawn_pos = align_obj:position()
			local spawn_rot = align_obj:rotation()
			module_unit = World:spawn_unit(Idstring(module_unit_name), spawn_pos, spawn_rot)
		end
	else
		module_unit = module_unit_name
	end

	if not module_unit then
		return
	end

	self._modules = self._modules or {}
	local destroy_clbk_key = nil

	if module_unit:base() and module_unit:base().add_destroy_listener then
		destroy_clbk_key = "AnimatedVehicleBase" .. tostring(self._unit:key())

		module_unit:base():add_destroy_listener(destroy_clbk_key, callback(self, self, "clbk_module_unit_destroyed", module_id))
	end

	self._unit:link(Idstring(align_obj_name), module_unit, module_unit:orientation_object():name(), true)

	local module_entry = {
		align_obj_name = align_obj_name,
		destroy_clbk_key = destroy_clbk_key,
		unit = module_unit
	}
	self._modules[module_id] = module_entry

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_unit_module", self._unit, module_unit, align_obj_name, module_id, "base")
	end

	if module_unit:character_damage() ~= nil then
		module_unit:character_damage():set_parent_unit(self._unit)
	end
end

function AnimatedVehicleBase:clbk_module_unit_destroyed(module_id, module_unit)
	if not self._modules then
		return
	end

	local entry = self._modules[module_id]
	self._modules[module_id] = nil

	if not next(self._modules) then
		self._modules = nil
	end
end

function AnimatedVehicleBase:run_module_function(module_id, extension_name, func_name, param1, param2)
	if not self._modules then
		return
	end

	local entry = self._modules[module_id]

	if not entry then
		return
	end

	if Network:is_server() then
		local params = (param1 or "") .. " " .. (param2 or "")

		managers.network:session():send_to_peers_synched("run_unit_module_function", self._unit, module_id, "base", extension_name, func_name, params)
	end

	self:run_module_function_unsafe(module_id, extension_name, func_name, param1, param2)
end

function AnimatedVehicleBase:run_module_function_unsafe(module_id, extension_name, func_name, param1, param2)
	if not self._modules then
		return
	end

	local entry = self._modules[module_id]

	if not entry then
		return
	end

	local extension = entry.unit[extension_name](entry.unit)

	extension[func_name](extension, param1, param2)
end

function AnimatedVehicleBase:clbk_send_modules(module_units_to_sync)
	if not alive(self._unit) or self._unit:id() == -1 then
		return
	end

	for _, module_unit in pairs(module_units_to_sync) do
		if alive(module_unit) then
			for module_id, module_entry in pairs(self._modules) do
				if module_entry.unit:key() == module_unit:key() then
					managers.network:session():send_to_peers_synched("sync_unit_module", self._unit, module_unit, module_entry.align_obj_name, module_id, "base")

					break
				end
			end
		end
	end
end

function AnimatedVehicleBase:anim_clbk_blackhawk_1_at_loop_end(unit)
	if self._wants_anim_redirect then
		self._unit:play_redirect(Idstring(self._wants_anim_redirect))

		self._wants_anim_redirect = nil
	end
end

function AnimatedVehicleBase:clbk_request_anim_redirect(redirect_name)
	self._wants_anim_redirect = redirect_name

	if self._unit:damage():has_sequence("int_seq_unbend_blades") then
		self._unit:damage():run_sequence_simple("int_seq_unbend_blades")
	end
end

function AnimatedVehicleBase:anim_clbk_run_seq(unit, seq_name)
	if self._unit:damage():has_sequence(seq_name) then
		self._unit:damage():run_sequence_simple(seq_name)
	end
end

function AnimatedVehicleBase:save(save_data)
	if self._modules then
		local module_units_to_sync = {}

		for module_id, module_entry in pairs(self._modules) do
			table.insert(module_units_to_sync, module_entry.unit)
		end

		managers.enemy:add_delayed_clbk("clbk_send_modules" .. tostring(self._unit:key()), callback(self, self, "clbk_send_modules", module_units_to_sync), TimerManager:game():time() + 0.1)
	end

	if self._saved_poses then
		save_data.anim_vehicle_base = save_data.anim_vehicle_base or {}
		save_data.anim_vehicle_base.saved_poses = self._saved_poses
	end

	if self._sync_objects then
		save_data.anim_vehicle_base = save_data.anim_vehicle_base or {}
		save_data.anim_vehicle_base.sync_objects = {}

		for _, name in ipairs(self._sync_objects) do
			save_data.anim_vehicle_base.sync_objects[name] = {
				pos = self._unit:get_object(Idstring(name)):position(),
				rot = self._unit:get_object(Idstring(name)):rotation()
			}
		end
	end

	if self._allow_sync and self._stored_pos ~= nil and self._stored_rot ~= nil then
		managers.network:session():send_to_peers_synched("sync_stored_pos", self._unit, self._allow_sync, self._stored_pos, self._stored_rot)
	end
end

function AnimatedVehicleBase:load(save_data)
	if not save_data.anim_vehicle_base then
		return
	end

	self._saved_poses = save_data.anim_vehicle_base.saved_poses

	if save_data.anim_vehicle_base.sync_objects then
		for name, object in pairs(save_data.anim_vehicle_base.sync_objects) do
			self._unit:get_object(Idstring(name)):set_position(object.pos)
			self._unit:get_object(Idstring(name)):set_rotation(object.rot)
		end
	end
end

function AnimatedVehicleBase:destroy(unit)
	if self._modules then
		local modules = self._modules
		self._modules = nil

		for module_id, entry in pairs(modules) do
			entry.unit:base():remove_destroy_listener(entry.destroy_clbk_key)
			entry.unit:set_slot(0)
		end
	end
end

function AnimatedVehicleBase:allow_sync_stored_pos(sync)
	self._allow_sync = sync
end

function AnimatedVehicleBase:store_current_pos()
	local pos = Vector3(self._unit:position().x / 10, self._unit:position().y / 10, self._unit:position().z / 10)
	local rot = Vector3(self._unit:rotation():yaw() / 10, self._unit:rotation():pitch() / 10, self._unit:rotation():roll() / 10)
	self._stored_pos = pos
	self._stored_rot = rot
end

function AnimatedVehicleBase:move_to_stored_pos()
	if self._stored_pos ~= nil and self._stored_rot ~= nil then
		self._unit:play_state(Idstring("std/empty"))

		local pos = Vector3(self._stored_pos.x * 10, self._stored_pos.y * 10, self._stored_pos.z * 10)
		local rot = Vector3(self._stored_rot.x * 10, self._stored_rot.y * 10, self._stored_rot.z * 10)

		self._unit:set_position(pos)
		self._unit:set_rotation(Rotation(rot.x, rot.y, rot.z))
	end
end

function AnimatedVehicleBase:sync_stored_pos(sync, pos, rot)
	self._allow_sync = sync
	self._stored_pos = pos
	self._stored_rot = rot
end
