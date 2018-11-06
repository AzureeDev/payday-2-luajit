VehicleManager = VehicleManager or class()

function VehicleManager:init()
	self._vehicles = {}
	self._listener_holder = EventListenerHolder:new()
	self._debug = SystemInfo:platform() == Idstring("WIN32") and Application:production_build()
	self._draw_enabled = false
end

function VehicleManager:on_simulation_started()
	for i = #self._vehicles, 1, -1 do
		if not alive(self._vehicles[i]) then
			table.remove(self._vehicles, i)
		end
	end
end

function VehicleManager:on_simulation_ended()
	Application:debug("[VehicleManager] on_simulation_ended")

	for i, v in ipairs(self._vehicles) do
		v:interaction():set_contour("standard_color", 0)
		v:vehicle_driving():stop_all_sound_events()

		if v.character_damage and v:character_damage()._broken_effect_id then
			World:effect_manager():fade_kill(v:character_damage()._broken_effect_id)

			v:character_damage()._broken_effect_id = nil
		end
	end

	self._vehicles = {}
	self._listener_holder = EventListenerHolder:new()
end

function VehicleManager:_call_listeners(event, params)
	self._listener_holder:call(event, params)
end

function VehicleManager:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

function VehicleManager:remove_listener(key)
	self._listener_holder:remove(key)
end

function VehicleManager:add_vehicle(vehicle)
	table.insert(self._vehicles, vehicle)

	if Application:editor() then
		self._listener_holder:call("on_add")
	end
end

function VehicleManager:remove_vehicle(vehicle)
	table.delete(vehicle)
	managers.hud:_remove_name_label(vehicle:unit_data().name_label_id)

	if Application:editor() then
		self._listener_holder:call("on_remove")
	end
end

function VehicleManager:get_all_vehicles()
	return self._vehicles
end

function VehicleManager:get_vehicle(animation_id)
	for i, v in ipairs(self._vehicles) do
		if v:vehicle_driving()._tweak_data.animations.vehicle_id == animation_id then
			return v
		end
	end

	return nil
end

function VehicleManager:on_player_entered_vehicle(vehicle_unit, player)
	self._listener_holder:call("on_enter", player)

	if self:all_players_in_vehicles() then
		self._listener_holder:call("on_all_inside", player)
	end
end

function VehicleManager:all_players_in_vehicles()
	local total_players = managers.network:session():amount_of_alive_players()
	local players_in_vehicles = 0

	for _, vehicle in pairs(self._vehicles) do
		players_in_vehicles = players_in_vehicles + vehicle:vehicle_driving():num_players_inside()
	end

	local all_in = total_players == players_in_vehicles

	return all_in
end

function VehicleManager:on_player_exited_vehicle(vehicle_unit, player)
	self._listener_holder:call("on_exit", player)
end

function VehicleManager:remove_player_from_all_vehicles(player)
	Application:debug("[VehicleManager] Removing player from all vehicles")

	for i, v in ipairs(self._vehicles) do
		v:vehicle_driving():exit_vehicle(player)
	end
end

function VehicleManager:update_vehicles_data_to_peer(peer)
	if peer:ip_verified() then
		for i, v in ipairs(self._vehicles) do
			local v_ext = v:vehicle_driving()
			local v_npc_ext = v:npc_vehicle_driving()

			Application:debug("[VehicleManager] Syncing vehicle data for: ", v_ext._unit:id(), v_ext._current_state_name)

			local driver, passenger_front, passenger_back_left, passenger_back_right = nil

			if v_ext._seats.driver and alive(v_ext._seats.driver.occupant) then
				driver = v_ext._seats.driver.occupant
			end

			if v_ext._seats.passenger_front and alive(v_ext._seats.passenger_front.occupant) then
				passenger_front = v_ext._seats.passenger_front.occupant
			end

			if v_ext._seats.passenger_back_left and alive(v_ext._seats.passenger_back_left.occupant) then
				passenger_back_left = v_ext._seats.passenger_back_left.occupant
			end

			if v_ext._seats.passenger_back_right and alive(v_ext._seats.passenger_back_right.occupant) then
				passenger_back_right = v_ext._seats.passenger_back_right.occupant
			end

			local is_trunk_open = nil

			if v_ext._has_trunk then
				is_trunk_open = v_ext._trunk_open
			end

			peer:send_queued_sync("sync_vehicle_data", v_ext._unit, v_ext._current_state_name, driver, passenger_front, passenger_back_left, passenger_back_right, is_trunk_open)

			if v_npc_ext then
				peer:send_queued_sync("sync_npc_vehicle_data", v_npc_ext._unit, v_npc_ext._current_state_name, v_npc_ext._target_unit)
			end

			local stored_loot = v_ext._loot
			local loot_index = 1

			while loot_index <= #stored_loot do
				local loot1 = stored_loot[loot_index]
				loot_index = loot_index + 1
				local loot2 = {
					multiplier = 0
				}

				if loot_index <= #stored_loot then
					loot2 = stored_loot[loot_index]
				end

				loot_index = loot_index + 1
				local loot3 = {
					multiplier = 0
				}

				if loot_index <= #stored_loot then
					loot3 = stored_loot[loot_index]
				end

				loot_index = loot_index + 1

				peer:send_queued_sync("sync_vehicle_loot", v_ext._unit, loot1.carry_id, loot1.multiplier, loot2.carry_id, loot2.multiplier, loot3.carry_id, loot3.multiplier)
			end
		end
	end
end

function VehicleManager:sync_npc_vehicle_data(vehicle_unit, state_name, target_unit)
	local v_npc_ext = vehicle_unit:npc_vehicle_driving()

	Application:debug("sync_npc_vehicle_data", vehicle_unit:unit_data().unit_id, state_name)
	v_npc_ext:_set_state(state_name)
	v_npc_ext:start()
end

function VehicleManager:sync_vehicle_data(vehicle_unit, state, occupant_driver, occupant_left, occupant_back_left, occupant_back_right, is_trunk_open)
	local v_ext = vehicle_unit:vehicle_driving()

	if v_ext._seats.driver then
		v_ext._seats.driver.occupant = occupant_driver

		if occupant_driver then
			vehicle_unit:link(Idstring(VehicleDrivingExt.SEAT_PREFIX .. v_ext._seats.driver.name), occupant_driver)

			local peer = managers.network:session():peer_by_unit(occupant_driver)

			if peer then
				managers.player._global.synced_vehicle_data[peer:id()] = {
					vehicle_unit = vehicle_unit,
					seat = v_ext._seats.driver.name
				}
			end
		end
	end

	if v_ext._seats.passenger_front then
		v_ext._seats.passenger_front.occupant = occupant_left

		if occupant_left then
			vehicle_unit:link(Idstring(VehicleDrivingExt.SEAT_PREFIX .. v_ext._seats.passenger_front.name), occupant_left)

			local peer = managers.network:session():peer_by_unit(occupant_left)

			if peer then
				managers.player._global.synced_vehicle_data[peer:id()] = {
					vehicle_unit = vehicle_unit,
					seat = v_ext._seats.passenger_front.name
				}
			end
		end
	end

	if v_ext._seats.passenger_back_left then
		v_ext._seats.passenger_back_left.occupant = occupant_back_left

		if occupant_back_left then
			vehicle_unit:link(Idstring(VehicleDrivingExt.SEAT_PREFIX .. v_ext._seats.passenger_back_left.name), occupant_back_left)

			local peer = managers.network:session():peer_by_unit(occupant_back_left)

			if peer then
				managers.player._global.synced_vehicle_data[peer:id()] = {
					vehicle_unit = vehicle_unit,
					seat = v_ext._seats.passenger_back_left.name
				}
			end
		end
	end

	if v_ext._seats.passenger_back_right then
		v_ext._seats.passenger_back_right.occupant = occupant_back_right

		if occupant_back_right then
			vehicle_unit:link(Idstring(VehicleDrivingExt.SEAT_PREFIX .. v_ext._seats.passenger_back_right.name), occupant_back_right)

			local peer = managers.network:session():peer_by_unit(occupant_back_right)

			if peer then
				managers.player._global.synced_vehicle_data[peer:id()] = {
					vehicle_unit = vehicle_unit,
					seat = v_ext._seats.passenger_back_right.name
				}
			end
		end
	end

	Application:debug("[VehicleManager]", inspect(managers.player._global.synced_vehicle_data))

	if state ~= VehicleDrivingExt.STATE_INACTIVE then
		vehicle_unit:damage():run_sequence_simple("driving")
		vehicle_unit:vehicle():set_active(true)
		v_ext:set_state(state, true)

		if vehicle_unit:damage():has_sequence("local_driving_exit") then
			vehicle_unit:damage():run_sequence("local_driving_exit")
		end
	end

	if is_trunk_open then
		vehicle_unit:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_TRUNK_OPEN)

		v_ext._trunk_open = true
		v_ext._interaction_loot = true
	end

	local number_of_seats = 0

	for _, seat in pairs(v_ext._seats) do
		number_of_seats = number_of_seats + 1
	end

	if number_of_seats == v_ext:_number_in_the_vehicle() then
		v_ext._interaction_enter_vehicle = false
	end
end

function VehicleManager:sync_vehicle_loot(vehicle_unit, carry_id1, multiplier1, carry_id2, multiplier2, carry_id3, multiplier3)
	if not alive(vehicle_unit) then
		return
	end

	local v_ext = vehicle_unit:vehicle_driving()

	v_ext:sync_loot(carry_id1, multiplier1)
	v_ext:sync_loot(carry_id2, multiplier2)
	v_ext:sync_loot(carry_id3, multiplier3)
end

function VehicleManager:find_active_vehicle_with_player()
	for i, v in ipairs(self._vehicles) do
		if v:vehicle_driving()._vehicle:is_active() then
			local v_ext = v:vehicle_driving()
			local has_free_seat = false
			local has_player = false

			for _, seat in pairs(v_ext._seats) do
				local occupant = seat.occupant

				if occupant == nil then
					has_free_seat = true
				elseif alive(occupant) and occupant:brain() or not alive(occupant) then
					has_free_seat = true
				else
					has_player = true
				end
			end

			if has_free_seat and has_player then
				return v
			end
		end
	end

	return nil
end

function VehicleManager:find_npc_vehicle_target()
	local target_unit = nil

	for i, v in ipairs(self._vehicles) do
		if alive(v) and v:vehicle_driving()._vehicle:is_active() and v:npc_vehicle_driving() == nil and v:vehicle_driving():num_players_inside() >= 0 then
			target_unit = v
		end
	end

	if not target_unit and managers.player:players() then
		target_unit = managers.player:players()[1]
	end

	return target_unit
end

function VehicleManager:update(t, dt)
	if self._debug and self._draw_enabled then
		for i, v in ipairs(self._vehicles) do
			if v:interaction() and v:interaction()._interact_object then
				local obj = v:get_object(Idstring(v:interaction()._interact_object))
				local interact_radius = v:vehicle_driving()._tweak_data.interact_distance

				Application:draw_sphere(obj:position(), interact_radius, 0, 0, 0.7)
			end
		end
	end
end
