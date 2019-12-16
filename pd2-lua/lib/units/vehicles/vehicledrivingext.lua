require("lib/units/vehicles/BaseVehicleState")
require("lib/units/vehicles/VehicleStateBroken")
require("lib/units/vehicles/VehicleStateDriving")
require("lib/units/vehicles/VehicleStateInactive")
require("lib/units/vehicles/VehicleStateInvalid")
require("lib/units/vehicles/VehicleStateLocked")
require("lib/units/vehicles/VehicleStateParked")
require("lib/units/vehicles/VehicleStateSecured")
require("lib/units/vehicles/VehicleStateFrozen")
require("lib/units/vehicles/VehicleStateBlocked")

VehicleDrivingExt = VehicleDrivingExt or class()
VehicleDrivingExt.SEAT_PREFIX = "v_"
VehicleDrivingExt.INTERACTION_PREFIX = "interact_"
VehicleDrivingExt.EXIT_PREFIX = "v_exit_"
VehicleDrivingExt.THIRD_PREFIX = "v_third_"
VehicleDrivingExt.LOOT_PREFIX = "v_"
VehicleDrivingExt.INTERACT_INVALID = -1
VehicleDrivingExt.INTERACT_ENTER = 0
VehicleDrivingExt.INTERACT_LOOT = 1
VehicleDrivingExt.INTERACT_REPAIR = 2
VehicleDrivingExt.INTERACT_DRIVE = 3
VehicleDrivingExt.INTERACT_TRUNK = 4
VehicleDrivingExt.STATE_INVALID = "invalid"
VehicleDrivingExt.STATE_INACTIVE = "inactive"
VehicleDrivingExt.STATE_PARKED = "parked"
VehicleDrivingExt.STATE_DRIVING = "driving"
VehicleDrivingExt.STATE_BROKEN = "broken"
VehicleDrivingExt.STATE_LOCKED = "locked"
VehicleDrivingExt.STATE_SECURED = "secured"
VehicleDrivingExt.STATE_FROZEN = "frozen"
VehicleDrivingExt.STATE_BLOCKED = "blocked"
VehicleDrivingExt.TIME_ENTER = 0.3
VehicleDrivingExt.TIME_REPAIR = 10
VehicleDrivingExt.INTERACT_ENTRY_ENABLED = "state_vis_icon_entry_enabled"
VehicleDrivingExt.INTERACT_ENTRY_DISABLED = "state_vis_icon_entry_disabled"
VehicleDrivingExt.INTERACT_LOOT_ENABLED = "state_vis_icon_loot_enabled"
VehicleDrivingExt.INTERACT_LOOT_DISABLED = "state_vis_icon_loot_disabled"
VehicleDrivingExt.INTERACT_REPAIR_ENABLED = "state_vis_icon_repair_enabled"
VehicleDrivingExt.INTERACT_REPAIR_DISABLED = "state_vis_icon_repair_disabled"
VehicleDrivingExt.INTERACT_INTERACTION_ENABLED = "state_interaction_enabled"
VehicleDrivingExt.INTERACT_INTERACTION_DISABLED = "state_interaction_disabled"
VehicleDrivingExt.SEQUENCE_HALF_DAMAGED = "int_seq_med_damaged"
VehicleDrivingExt.SEQUENCE_FULL_DAMAGED = "int_seq_full_damaged"
VehicleDrivingExt.SEQUENCE_REPAIRED = "int_seq_repaired"
VehicleDrivingExt.SEQUENCE_TRUNK_OPEN = "anim_trunk_open"
VehicleDrivingExt.SEQUENCE_TRUNK_CLOSE = "anim_trunk_close"
VehicleDrivingExt.PLAYER_CAPSULE_OFFSET = Vector3(0, 0, -150)

function VehicleDrivingExt:init(unit)
	self._unit = unit

	self._unit:set_extension_update_enabled(Idstring("vehicle_driving"), true)

	self._vehicle = self._unit:vehicle()

	if self._vehicle == nil then
		print("[DRIVING] unit doesn't contain a vehicle")
	end

	self._vehicle_view = self._unit:get_object(Idstring("v_driver"))

	if self._vehicle_view == nil then
		print("[DRIVING] vehicle doesn't contain driver view point")
	end

	self._drop_time_delay = nil
	self._last_synced_position = Vector3(0, 0, 0)
	self._shooting_stance_allowed = true
	self._position_counter = 0
	self._position_dt = 0
	self._positions = {}
	self._could_not_move = false
	self._last_input_fwd_dt = 0
	self._last_input_bwd_dt = 0
	self._pos_reservation_id = nil
	self._pos_reservation = nil
	self.inertia_modifier = self.inertia_modifier or 1
	self._old_speed = Vector3(0, 0, 0)

	managers.vehicle:add_vehicle(self._unit)
	self._unit:set_body_collision_callback(callback(self, self, "collision_callback"))
	self:set_tweak_data(tweak_data.vehicle[self.tweak_data])

	self._interaction_allowed = true

	self:_setup_states()
	self:set_state(VehicleDrivingExt.STATE_INACTIVE, true)

	self._interaction_enter_vehicle = true
	self._interaction_trunk = true
	self._interaction_loot = false
	self._interaction_repair = false
	self._trunk_open = false
	self._has_trunk = self._unit:damage():has_sequence(VehicleDrivingExt.SEQUENCE_TRUNK_OPEN)

	if not self._has_trunk then
		self._interaction_loot = true
	end

	self._playing_slip_sound_dt = 0
	self._playing_reverse_sound_dt = 0
	self._playing_engine_sound = false
	self._hit_soundsource = SoundDevice:create_source("vehicle_hit")
	self._slip_soundsource = SoundDevice:create_source("vehicle_slip")

	self._slip_soundsource:link(self._unit:get_object(Idstring("anim_tire_front_left")))

	self._bump_soundsource = SoundDevice:create_source("vehicle_bump")

	self._bump_soundsource:link(self._unit:get_object(Idstring("anim_tire_front_left")))

	self._door_soundsource = SoundDevice:create_source("vehicle_door")

	self._door_soundsource:link(self._unit:get_object(Idstring("v_driver")))

	self._engine_soundsource = nil
	local snd_engine = self._unit:get_object(Idstring("snd_engine"))

	if snd_engine then
		self._engine_soundsource = SoundDevice:create_source("vehicle_engine")

		self._engine_soundsource:link(snd_engine)
	end

	self._wheel_jounce = {}
	self._reverse_sound = self._tweak_data.sound.going_reverse
	self._reverse_sound_stop = self._tweak_data.sound.going_reverse_stop
	self._slip_sound = self._tweak_data.sound.slip
	self._slip_sound_stop = self._tweak_data.sound.slip_stop
	self._bump_sound = self._tweak_data.sound.bump
	self._bump_rtpc = self._tweak_data.sound.bump_rtpc
	self._hit_sound = self._tweak_data.sound.hit
	self._hit_rtpc = self._tweak_data.sound.hit_rtpc
	self._loot = {}
	self.hud_label_offset = self._tweak_data.hud_label_offset or self._unit:oobb():size().z
end

function VehicleDrivingExt:_setup_states()
	local unit = self._unit
	self._states = {
		broken = VehicleStateBroken:new(unit),
		driving = VehicleStateDriving:new(unit),
		inactive = VehicleStateInactive:new(unit),
		invalid = VehicleStateInvalid:new(unit),
		locked = VehicleStateLocked:new(unit),
		parked = VehicleStateParked:new(unit),
		secured = VehicleStateSecured:new(unit),
		frozen = VehicleStateFrozen:new(unit),
		blocked = VehicleStateBlocked:new(unit)
	}
end

function VehicleDrivingExt:set_tweak_data(data)
	self._tweak_data = data
	self._seats = deep_clone(self._tweak_data.seats)
	self._loot_points = deep_clone(self._tweak_data.loot_points)

	for _, seat in pairs(self._seats) do
		seat.occupant = nil
		seat.object = self._unit:get_object(Idstring(VehicleDrivingExt.SEAT_PREFIX .. seat.name))
		seat.third_object = self._unit:get_object(Idstring(VehicleDrivingExt.THIRD_PREFIX .. seat.name))
		seat.SO_object = self._unit:get_object(Idstring(VehicleDrivingExt.EXIT_PREFIX .. seat.name))
	end

	for _, loot_point in pairs(self._loot_points) do
		loot_point.object = self._unit:get_object(Idstring(VehicleDrivingExt.LOOT_PREFIX .. loot_point.name))
	end

	if self._unit:character_damage() then
		self._unit:character_damage():set_tweak_data(data)
	end

	self._last_drop_position = self._unit:get_object(Idstring(self._tweak_data.loot_drop_point)):position()
end

function VehicleDrivingExt:get_view()
	return self._vehicle_view
end

function VehicleDrivingExt:update(unit, t, dt)
	self:_manage_position_reservation()

	if Network:is_server() then
		if self._vehicle:is_active() then
			self:drop_loot()
		end

		self:_catch_loot()
	end

	for _, seat in pairs(self._seats) do
		local is_ai = alive(seat.occupant) and seat.occupant:brain() ~= nil

		if is_ai then
			if seat.occupant:character_damage():is_downed() then
				self:_evacuate_seat(seat)
			else
				local pos = seat.third_object:position()

				seat.occupant:movement():set_position(pos)
			end
		end
	end

	self._current_state:update(t, dt)
end

function VehicleDrivingExt:_create_position_reservation()
	self._pos_reservation_id = managers.navigation:get_pos_reservation_id()

	if self._pos_reservation_id then
		self._pos_reservation = {
			radius = 500,
			position = self._unit:position(),
			filter = self._pos_reservation_id
		}

		managers.navigation:add_pos_reservation(self._pos_reservation)
	end
end

function VehicleDrivingExt:_manage_position_reservation()
	if not self._pos_reservation_id and managers.navigation and managers.navigation:is_data_ready() then
		self:_create_position_reservation()

		return
	end

	if self._pos_reservation then
		local pos = self._unit:position()
		local distance = mvector3.distance(pos, self._pos_reservation.position)

		if distance > 100 then
			self._pos_reservation.position = pos

			managers.navigation:move_pos_rsrv(self._pos_reservation)
		end
	end
end

function VehicleDrivingExt:get_action_for_interaction(pos, locator)
	return self._current_state:get_action_for_interaction(pos, locator, self._tweak_data)
end

function VehicleDrivingExt:set_interaction_allowed(allowed)
	self._interaction_allowed = allowed

	self._current_state:adjust_interactions()
end

function VehicleDrivingExt:is_interaction_allowed()
	return self._interaction_allowed
end

function VehicleDrivingExt:is_interaction_enabled(action)
	if not self:is_interaction_allowed() then
		return false
	end

	local result = false

	if action == VehicleDrivingExt.INTERACT_ENTER or action == VehicleDrivingExt.INTERACT_DRIVE then
		result = self._interaction_enter_vehicle
	elseif action == VehicleDrivingExt.INTERACT_LOOT then
		result = self._interaction_loot
	elseif action == VehicleDrivingExt.INTERACT_REPAIR then
		result = self._interaction_repair
	elseif action == VehicleDrivingExt.INTERACT_TRUNK then
		result = self._interaction_trunk
	end

	return result
end

function VehicleDrivingExt:set_state(name, do_not_sync)
	if name == self._current_state_name or self._current_state_name == VehicleDrivingExt.STATE_SECURED then
		return
	end

	local exit_data = nil

	if self._current_state then
		exit_data = self._current_state:exit(self._state_data, name)
	end

	local new_state = self._states[name]

	if not new_state then
		new_state = self._states[VehicleDrivingExt.STATE_PARKED]
		self._current_state = new_state
		self._current_state_name = VehicleDrivingExt.STATE_PARKED
		self._state_enter_t = managers.player:player_timer():time()

		new_state:enter(self._state_data, exit_data)
	else
		self._current_state = new_state
		self._current_state_name = name
		self._state_enter_t = managers.player:player_timer():time()

		new_state:enter(self._state_data, exit_data)
	end

	if managers.network and managers.network:session() and not do_not_sync then
		managers.network:session():send_to_peers_synched("sync_ai_vehicle_action", "state", self._unit, name, nil)
	end
end

function VehicleDrivingExt:get_state_name()
	return self._current_state_name
end

function VehicleDrivingExt:lock()
	self:set_state(VehicleDrivingExt.STATE_LOCKED)
end

function VehicleDrivingExt:unlock()
	if not self._vehicle:is_active() then
		self:set_state(VehicleDrivingExt.STATE_INACTIVE)
	else
		self:set_state(VehicleDrivingExt.STATE_PARKED)
	end
end

function VehicleDrivingExt:secure()
	local carry_ext = self._unit:carry_data()

	if Network:is_server() then
		local silent = false
		local carry_id = carry_ext:carry_id()
		local multiplier = carry_ext:multiplier()

		managers.loot:secure(carry_id, multiplier, silent)
	end

	self:set_state(VehicleDrivingExt.STATE_SECURED)
end

function VehicleDrivingExt:break_down()
	self._unit:character_damage():damage_mission(100000)
	self:set_state(VehicleDrivingExt.STATE_BROKEN)
end

function VehicleDrivingExt:damage(damage)
	self._unit:character_damage():damage_mission(damage)
end

function VehicleDrivingExt:activate()
	if self:num_players_inside() > 0 then
		self:set_state(VehicleDrivingExt.STATE_DRIVING)
	else
		self:set_state(VehicleDrivingExt.STATE_PARKED)
	end
end

function VehicleDrivingExt:deactivate()
	self:set_state(VehicleDrivingExt.STATE_FROZEN)
end

function VehicleDrivingExt:block()
	self:set_state(VehicleDrivingExt.STATE_BLOCKED)
end

function VehicleDrivingExt:add_loot(carry_id, multiplier)
	if not carry_id or carry_id == "" then
		return false
	end

	if self._tweak_data.max_loot_bags <= #self._loot then
		return false
	end

	table.insert(self._loot, {
		carry_id = carry_id,
		multiplier = multiplier
	})
	managers.hud:set_vehicle_label_carry_info(self._unit:unit_data().name_label_id, true, #self._loot)

	local bag_type_seq = "action_add_bag_" .. carry_id

	if self._unit:damage():has_sequence(bag_type_seq) then
		self._unit:damage():run_sequence_simple(bag_type_seq)
	elseif self._unit:damage():has_sequence("action_add_bag") then
		self._unit:damage():run_sequence_simple("action_add_bag")
	end
end

function VehicleDrivingExt:sync_loot(carry_id, multiplier)
	if not carry_id or carry_id == "" then
		return false
	end

	table.insert(self._loot, {
		carry_id = carry_id,
		multiplier = multiplier
	})
	managers.hud:set_vehicle_label_carry_info(self._unit:unit_data().name_label_id, true, #self._loot)

	local count = #self._loot
	local bag_type_seq_carry = "int_seq_sync_slot_" .. count .. "_" .. carry_id
	local bag_type_seq = "int_seq_sync_slot_" .. count

	if self._unit:damage():has_sequence(bag_type_seq_carry) then
		self._unit:damage():run_sequence_simple(bag_type_seq_carry)
	elseif self._unit:damage():has_sequence(bag_type_seq) then
		self._unit:damage():run_sequence_simple(bag_type_seq)
	end
end

function VehicleDrivingExt:remove_loot(carry_id, multiplier)
	if not carry_id or carry_id == "" then
		return false
	end

	for i = #self._loot, 1, -1 do
		local loot = self._loot[i]

		if loot.carry_id == carry_id and loot.multiplier == multiplier then
			table.remove(self._loot, i)

			local bag_type_seq = "action_remove_bag_" .. carry_id

			if self._unit:damage():has_sequence(bag_type_seq) then
				self._unit:damage():run_sequence_simple(bag_type_seq)
			elseif self._unit:damage():has_sequence("action_remove_bag") then
				self._unit:damage():run_sequence_simple("action_remove_bag")
			end

			local display_bag = true

			if #self._loot == 0 then
				display_bag = false
			end

			managers.hud:set_vehicle_label_carry_info(self._unit:unit_data().name_label_id, display_bag, #self._loot)

			return true
		end
	end

	return false
end

function VehicleDrivingExt:get_random_loot()
	local entry = math.random(#self._loot)

	return entry
end

function VehicleDrivingExt:get_loot()
	local entry = #self._loot

	return entry
end

function VehicleDrivingExt:give_vehicle_loot_to_player(peer_id)
	if Network:is_server() then
		self:server_give_vehicle_loot_to_player(peer_id)
	else
		managers.network:session():send_to_host("server_give_vehicle_loot_to_player", self._unit, peer_id)
	end
end

function VehicleDrivingExt:server_give_vehicle_loot_to_player(peer_id)
	local loot = self._loot[self:get_loot()]

	if loot then
		managers.network:session():send_to_peers_synched("sync_give_vehicle_loot_to_player", self._unit, loot.carry_id, loot.multiplier, peer_id)
		self:sync_give_vehicle_loot_to_player(loot.carry_id, loot.multiplier, peer_id)
	end
end

function VehicleDrivingExt:sync_give_vehicle_loot_to_player(carry_id, multiplier, peer_id)
	if not self:remove_loot(carry_id, multiplier) then
		Application:error("[VehicleDrivingExt] Trying to remove loot that is not in the vehicle: ", carry_id)

		return
	end

	if peer_id == managers.network:session():local_peer():id() then
		managers.player:set_carry(carry_id, multiplier, true, false, 1)
	end

	managers.player:register_carry(managers.network:session():peer(peer_id), carry_id)
end

function VehicleDrivingExt:drop_loot()
	if not self:_should_drop_loot() then
		return
	end

	local loot = self._loot[self:get_loot()]

	if loot then
		local pos = self._unit:get_object(Idstring(self._tweak_data.loot_drop_point)):position()
		local velocity = self._vehicle:velocity()

		mvector3.normalize(velocity)
		mvector3.multiply(velocity, -300)

		local drop_point = pos + velocity

		Application:debug("dropping loot    " .. inspect(self._unit:position()) .. "      " .. inspect(drop_point))

		local rot = self._unit:rotation()
		local dir = Vector3(0, 0, 0)

		managers.player:server_drop_carry(loot.carry_id, loot.multiplier, true, false, 1, drop_point, rot, dir, 0, nil, nil)
	end
end

function VehicleDrivingExt:_should_drop_loot()
	return false
end

function VehicleDrivingExt:_store_loot(unit)
	if self._tweak_data and self._tweak_data.max_loot_bags <= #self._loot then
		return
	end

	if Network:is_server() then
		self:server_store_loot_in_vehicle(unit)
	else
		managers.network:session():send_to_host("server_store_loot_in_vehicle", self._unit, unit)
	end
end

function VehicleDrivingExt:server_store_loot_in_vehicle(unit)
	local carry_ext = unit:carry_data()
	local carry_id = carry_ext:carry_id()
	local multiplier = carry_ext:multiplier()

	managers.network:session():send_to_peers_synched("sync_store_loot_in_vehicle", self._unit, unit, carry_id, multiplier)
	self:sync_store_loot_in_vehicle(unit, carry_id, multiplier)
end

function VehicleDrivingExt:sync_store_loot_in_vehicle(unit, carry_id, multiplier)
	local carry_ext = unit:carry_data()

	carry_ext:disarm()
	self:add_loot(carry_id, multiplier)
	unit:set_slot(0)
	carry_ext:set_value(0)

	if unit:damage():has_sequence("secured") then
		unit:damage():run_sequence_simple("secured")
	end
end

function VehicleDrivingExt:_loot_filter_func(carry_data)
	local carry_id = carry_data:carry_id()

	if carry_id == "gold" or carry_id == "goat" or carry_id == "present" or carry_id == "mad_master_server_value_1" or carry_id == "mad_master_server_value_2" or carry_id == "mad_master_server_value_3" or carry_id == "mad_master_server_value_4" or carry_id == "money" or carry_id == "diamonds" or carry_id == "coke" or carry_id == "weapon" or carry_id == "painting" or carry_id == "circuit" or carry_id == "diamonds" or carry_id == "engine_01" or carry_id == "engine_02" or carry_id == "engine_03" or carry_id == "engine_04" or carry_id == "engine_05" or carry_id == "engine_06" or carry_id == "engine_07" or carry_id == "engine_08" or carry_id == "engine_09" or carry_id == "engine_10" or carry_id == "engine_11" or carry_id == "engine_12" or carry_id == "meth" or carry_id == "lance_bag" or carry_id == "lance_bag_large" or carry_id == "grenades" or carry_id == "ammo" or carry_id == "cage_bag" or carry_id == "turret" or carry_id == "artifact_statue" or carry_id == "samurai_suit" or carry_id == "equipment_bag" or carry_id == "cro_loot1" or carry_id == "cro_loot2" or carry_id == "ladder_bag" or carry_id == "warhead" or carry_id == "paper_roll" or carry_id == "counterfeit_money" or carry_id == "safe_wpn" or carry_id == "safe_ovk" or carry_id == "prototype" or carry_id == "master_server" or carry_id == "lost_artifact" or carry_id == "masterpiece_painting" then
		return true
	elseif tweak_data.carry[carry_data:carry_id()].is_unique_loot then
		return true
	end

	return false
end

function VehicleDrivingExt:_catch_loot()
	if self._tweak_data and self._tweak_data.max_loot_bags <= #self._loot or not self._interaction_loot then
		return false
	end

	for _, loot_point in pairs(self._loot_points) do
		if loot_point.object then
			local pos = loot_point.object:position()
			local equipement = World:find_units_quick("sphere", pos, 100, 14)

			for _, unit in ipairs(equipement) do
				local carry_data = unit:carry_data()

				if carry_data and self:_loot_filter_func(carry_data) then
					self:_store_loot(unit)

					break
				end
			end
		end
	end
end

function VehicleDrivingExt:get_nearest_loot_point(pos)
	local nearest_loot_point = nil
	local min_distance = 1e+20

	for name, loot_point in pairs(self._loot_points) do
		if loot_point.object then
			local loot_point_pos = loot_point.object:position()
			local distance = mvector3.distance(loot_point_pos, pos)

			if distance < min_distance then
				min_distance = distance
				nearest_loot_point = loot_point
			end
		end
	end

	return nearest_loot_point, min_distance
end

function VehicleDrivingExt:enter_vehicle(player)
	local seat = self:find_seat_for_player(player)

	if seat == nil then
		return
	end
end

function VehicleDrivingExt:reserve_seat(player, position, seat_name)
	local seat = nil

	if position then
		seat = self:get_available_seat(position)
	else
		for _, s in pairs(self._seats) do
			if s.name == seat_name then
				seat = s
			end
		end

		if alive(seat.occupant) and seat.occupant:brain() == nil then
			seat = self:get_available_seat(player:position())
		end
	end

	if seat == nil then
		return nil
	end

	if alive(seat.occupant) and seat.occupant:brain() then
		self:_evacuate_seat(seat)
	end

	seat.occupant = player

	self:_unregister_drive_SO(seat)

	return seat
end

function VehicleDrivingExt:place_player_on_seat(player, seat_name)
	local number_of_seats = 0

	for _, seat in pairs(self._seats) do
		number_of_seats = number_of_seats + 1

		if seat.name == seat_name then
			seat.occupant = player

			self._door_soundsource:set_position(seat.object:position())
			self._door_soundsource:post_event(self._tweak_data.sound.door_close)

			local count = self:_number_in_the_vehicle()

			if count == 1 then
				self:_chk_register_drive_SO()
			end

			if alive(self._seats.driver.occupant) and (self._current_state_name == VehicleDrivingExt.STATE_INACTIVE or self._current_state_name == VehicleDrivingExt.STATE_PARKED) then
				self:set_state(VehicleDrivingExt.STATE_DRIVING)
			end

			if count == 1 and self._current_state_name ~= VehicleDrivingExt.STATE_BROKEN and self._current_state_name ~= VehicleDrivingExt.STATE_BLOCKED then
				self:start(player)
			end
		end
	end

	if number_of_seats == self:_number_in_the_vehicle() then
		self._interaction_enter_vehicle = false
	end

	if self:num_players_inside() == 1 then
		local attention_setting_name = "vehicle_enemy_cbt"
		local attention_desc = tweak_data.attention.settings[attention_setting_name]
		local attention_setting = PlayerMovement._create_attention_setting_from_descriptor(self, attention_desc, attention_setting_name)

		self._unit:attention():set_attention(attention_setting, nil)
		self._unit:attention():set_team(player:movement():team())
	end
end

function VehicleDrivingExt:disable_player_exit()
	self._manual_exit_disabled = true
end

function VehicleDrivingExt:enable_player_exit()
	self._manual_exit_disabled = nil
end

function VehicleDrivingExt:allow_exit()
	local allowed = self._current_state:allow_exit()
	allowed = allowed and not self._manual_exit_disabled

	return allowed
end

function VehicleDrivingExt:exit_vehicle(player)
	local seat = self:find_seat_for_player(player)

	if seat == nil then
		return
	end

	seat.occupant = nil
	local count = self:_number_in_the_vehicle()

	self:_unregister_drive_SO_all()

	self._interaction_enter_vehicle = true

	if not alive(self._seats.driver.occupant) and self._current_state_name ~= VehicleDrivingExt.STATE_BROKEN and self._current_state_name ~= VehicleDrivingExt.STATE_LOCKED and self._current_state_name ~= VehicleDrivingExt.STATE_BLOCKED then
		self:set_state(VehicleDrivingExt.STATE_PARKED)
	end

	if count == 0 then
		self:_evacuate_vehicle()
	end

	if self.on_exit_vehicle then
		self.on_exit_vehicle(player)
	end
end

function VehicleDrivingExt:_evacuate_vehicle()
	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant:brain() then
			self:_evacuate_seat(seat)
		end
	end

	self:_unregister_drive_SO_all()
	self._unit:attention():set_attention(nil, nil)
end

function VehicleDrivingExt:_evacuate_seat(seat)
	seat.occupant:unlink()

	seat.occupant:movement().vehicle_unit = nil
	seat.occupant:movement().seat = nil

	if seat.occupant:character_damage():dead() then
		-- Nothing
	elseif Network:is_server() then
		seat.occupant:movement():action_request({
			sync = true,
			body_part = 1,
			type = "idle"
		})
	end

	local rot = seat.SO_object:rotation()
	local pos = seat.SO_object:position()

	seat.occupant:movement():set_rotation(rot)
	seat.occupant:movement():set_position(pos)

	seat.occupant = nil
end

function VehicleDrivingExt:find_exit_position(player)
	local seat = self:find_seat_for_player(player)
	local seat_position = self._vehicle:object_position(seat.object)
	local exit_position = self._unit:get_object(Idstring(VehicleDrivingExt.EXIT_PREFIX .. seat.name))
	local found_exit = true
	local rot = self._vehicle:rotation()
	local offset = Vector3(0, 0, 100)

	mvector3.rotate_with(offset, rot)

	local slot_mask = World:make_slot_mask(1, 11)
	local ray = World:raycast("ray_type", "body bag mover", "ray", seat_position + offset, exit_position:position() + offset, "sphere_cast_radius", 35, "slot_mask", slot_mask)

	if ray and ray.unit then
		found_exit = false

		for _, seat in pairs(self._tweak_data.seats) do
			exit_position = self._unit:get_object(Idstring(VehicleDrivingExt.EXIT_PREFIX .. seat.name))
			ray = World:raycast("ray_type", "body bag mover", "ray", seat_position + offset, exit_position:position() + offset, "sphere_cast_radius", 35, "slot_mask", slot_mask)

			if not ray or not ray.unit then
				found_exit = true

				break
			end
		end

		if not found_exit then
			local i_alt = 1
			exit_position = self._unit:get_object(Idstring("v_exit_alternate_" .. i_alt))

			while exit_position do
				ray = World:raycast("ray_type", "body bag mover", "ray", seat_position + offset, exit_position:position() + offset, "sphere_cast_radius", 35, "slot_mask", slot_mask)

				if not ray or not ray.unit then
					found_exit = true

					break
				end

				i_alt = i_alt + 1
				exit_position = self._unit:get_object(Idstring("v_exit_alternate_" .. i_alt))
			end
		end
	end

	if not found_exit then
		exit_position = nil
	end

	return exit_position
end

function VehicleDrivingExt:get_object_placement(player)
	local seat = self:find_seat_for_player(player)

	if seat then
		local obj_pos = self._vehicle:object_position(seat.object)
		local obj_rot = self._vehicle:object_rotation(seat.object)

		return obj_pos, obj_rot
	end

	print("[VehicleDrivingExt:get_object_placement] Seat not found for player!")

	return nil, nil
end

function VehicleDrivingExt:get_seat_by_name(seat_name)
	for name, seat in pairs(self._seats) do
		if name == seat_name then
			return seat
		end
	end
end

function VehicleDrivingExt:get_available_seat(position)
	local nearest_seat = nil
	local min_distance = 1e+20
	local min_seat_distance = 1e+20

	for name, seat in pairs(self._seats) do
		local object = self._unit:get_object(Idstring(VehicleDrivingExt.INTERACTION_PREFIX .. seat.name))

		if object ~= nil then
			local seat_pos = object:position()
			local distance = mvector3.distance(seat_pos, position)

			if distance < min_distance then
				min_distance = distance
			end

			if (not alive(seat.occupant) or seat.occupant:brain()) and distance < min_seat_distance then
				nearest_seat = seat
				min_seat_distance = distance
			end
		end
	end

	return nearest_seat, min_distance
end

function VehicleDrivingExt:has_driving_seat()
	for _, seat in pairs(self._seats) do
		if seat.driving then
			return true
		end
	end

	return false
end

function VehicleDrivingExt:find_seat_for_player(player)
	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant == player then
			return seat
		end
	end

	return nil
end

function VehicleDrivingExt:num_players_inside()
	local num_players = 0

	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and not seat.occupant:brain() then
			num_players = num_players + 1
		end
	end

	return num_players
end

function VehicleDrivingExt:on_team_ai_enter(ai_unit)
	ai_unit:movement().vehicle_unit:link(Idstring(VehicleDrivingExt.THIRD_PREFIX .. ai_unit:movement().vehicle_seat.name), ai_unit, ai_unit:orientation_object():name())

	ai_unit:movement().vehicle_seat.occupant = ai_unit

	if ai_unit:movement():carrying_bag() then
		ai_unit:movement():throw_bag()
	end

	Application:debug("VehicleDrivingExt:sync_ai_vehicle_action")
	self._door_soundsource:set_position(ai_unit:movement().vehicle_seat.object:position())
	self._door_soundsource:post_event(self._tweak_data.sound.door_close)
end

function VehicleDrivingExt:on_vehicle_death()
	self:set_state(VehicleDrivingExt.STATE_BROKEN)
end

function VehicleDrivingExt:repair_vehicle()
	self:set_state(VehicleDrivingExt.STATE_PARKED)
	self._unit:character_damage():revive()
end

function VehicleDrivingExt:is_vulnerable()
	return self._current_state:is_vulnerable()
end

function VehicleDrivingExt:start(player)
	self:_start(player)

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_vehicle_driving", "start", self._unit, player)
	end
end

function VehicleDrivingExt:sync_start(player)
	self:_start(player)
end

function VehicleDrivingExt:_start(player)
	local seat = self:find_seat_for_player(player)

	if seat == nil then
		return
	end

	self:activate_vehicle()
end

function VehicleDrivingExt:activate_vehicle()
	if not self._vehicle:is_active() then
		self._unit:damage():run_sequence_simple("driving")
		self._vehicle:set_active(true)
		self:set_state(VehicleDrivingExt.STATE_DRIVING)
	end

	self._last_drop_position = self._unit:get_object(Idstring(self._tweak_data.loot_drop_point)):position()
	self._drop_time_delay = TimerManager:main():time()
end

function VehicleDrivingExt:stop()
	self:_stop()

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_vehicle_driving", "stop", self._unit, nil)
	end
end

function VehicleDrivingExt:sync_stop()
	self:_stop()
end

function VehicleDrivingExt:_stop()
	print("[DRIVING] VehicleDrivingExt: _stop()")
	self:stop_all_sound_events()
	self._unit:damage():run_sequence_simple("not_driving")
	self._vehicle:set_active(false)

	self._drop_time_delay = nil

	self:set_state(VehicleDrivingExt.STATE_INACTIVE)
end

function VehicleDrivingExt:set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear, dt, y_axis)
	if self._current_state:stop_vehicle() then
		accelerate = 0
		steer = 0
		gear_up = false
		gear_down = false
		brake = 1
	elseif dt and y_axis > 0 then
		self._last_input_fwd_dt = self._last_input_fwd_dt + dt
	elseif dt and y_axis < 0 then
		self._last_input_bwd_dt = self._last_input_bwd_dt + dt
	end

	self:_set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)

	if managers.network:session() then
		local pos = self._vehicle:position()

		managers.network:session():send_to_peers_synched("sync_vehicle_set_input", self._unit, accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)

		local distance = mvector3.distance(self._last_synced_position, pos)

		if distance > 1 then
			managers.network:session():send_to_peers_synched("sync_vehicle_state", self._unit, self._vehicle:position(), self._vehicle:rotation(), self._vehicle:velocity())

			self._last_synced_position = pos
		end
	end
end

function VehicleDrivingExt:sync_set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)
	self:_set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)
end

function VehicleDrivingExt:sync_state(position, rotation, velocity)
	self._vehicle:adjust_vehicle_state(position, rotation, velocity)
end

function VehicleDrivingExt:sync_vehicle_state(new_state)
	self:set_state(new_state, true)
end

function VehicleDrivingExt:_set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)
	local gear_shift = 0

	if gear_up then
		gear_shift = 1
	end

	if gear_down then
		gear_shift = -1
	end

	self._vehicle:set_input(accelerate, steer, brake, handbrake, gear_shift, forced_gear)
end

function VehicleDrivingExt:_wake_nearby_dynamics()
	local slotmask = World:make_slot_mask(1)
	local units = World:find_units_quick("sphere", self._vehicle:position(), 500, slotmask)

	for _, unit in pairs(units) do
		if unit:damage() and unit:damage():has_sequence("car_destructable") then
			unit:damage():run_sequence_simple("car_destructable")
		end
	end
end

function VehicleDrivingExt:_should_push(unit)
	for _, seat in pairs(self._seats) do
		if seat.occupant == unit or seat.drive_SO_data and seat.drive_SO_data.unit == unit then
			return false
		end
	end

	return true
end

function VehicleDrivingExt:_detect_npc_collisions()
	local vel = self._vehicle:velocity()

	if vel:length() < 150 then
		return
	end

	local oobb = self._unit:oobb()
	local slotmask = managers.slot:get_mask("flesh")
	local units = World:find_units("intersect", "obb", oobb:center(), oobb:x(), oobb:y(), oobb:z(), slotmask)

	for _, unit in pairs(units) do
		local unit_is_criminal = unit:in_slot(managers.slot:get_mask("all_criminals"))

		if unit_is_criminal then
			-- Nothing
		elseif unit:character_damage() and not unit:character_damage():dead() then
			self._hit_soundsource:set_position(unit:position())
			self._hit_soundsource:set_rtpc("car_hit_vel", math.clamp(vel:length() / 100 * 2, 0, 100))
			self._hit_soundsource:post_event("car_hit_body_01")

			local damage_ext = unit:character_damage()
			local attack_data = {
				variant = "explosion",
				damage = damage_ext._HEALTH_INIT or 1000
			}

			if self._seats.driver.occupant == managers.player:local_player() then
				attack_data.attacker_unit = managers.player:local_player()
			end

			damage_ext:damage_mission(attack_data)

			if unit:movement()._active_actions[1] and unit:movement()._active_actions[1]:type() == "hurt" then
				unit:movement()._active_actions[1]:force_ragdoll(true)
			end

			local nr_u_bodies = unit:num_bodies()
			local i_u_body = 0

			while nr_u_bodies > i_u_body do
				local u_body = unit:body(i_u_body)

				if u_body:enabled() and u_body:dynamic() then
					local body_mass = u_body:mass()

					u_body:push_at(body_mass / math.random(2), vel * 2.5, u_body:position())
				end

				i_u_body = i_u_body + 1
			end
		end
	end
end

function VehicleDrivingExt:_detect_collisions(t, dt)
	local current_speed = self._vehicle:velocity()

	if dt ~= 0 and self._vehicle:is_active() then
		local dv = self._old_speed - current_speed
		local gforce = math.abs(dv:length() / 100 / dt) / 9.81

		if gforce > 15 then
			local ray_from = self._seats.driver.object:position() + Vector3(0, 0, 100)
			local distance = mvector3.copy(self._old_speed)

			mvector3.normalize(distance)
			mvector3.multiply(distance, 300)

			local ray = World:raycast("ray", ray_from, ray_from + distance, "sphere_cast_radius", 75, "slot_mask", managers.slot:get_mask("world_geometry"))

			if ray and ray.unit then
				self:on_impact(ray, gforce, self._old_speed)
			elseif self._seats.passenger_front then
				ray_from = self._seats.passenger_front.object:position() + Vector3(0, 0, 100)
				ray = World:raycast("ray", ray_from, ray_from + distance, "sphere_cast_radius", 75, "slot_mask", managers.slot:get_mask("world_geometry"))

				if ray and ray.unit then
					self:on_impact(ray, gforce, self._old_speed)
				else
					self:on_impact(nil, gforce, self._old_speed)
				end
			end
		end
	end

	self._old_speed = current_speed
end

function VehicleDrivingExt:_detect_invalid_possition(t, dt)
	local respawn = false
	local rot = self._vehicle:rotation()

	if rot:z().z < 0.6 and not self._invalid_position_since then
		self._invalid_position_since = t
	elseif rot:z().z >= 0.6 and self._invalid_position_since then
		self._invalid_position_since = nil
	end

	local velocity = self._vehicle:velocity():length()

	if velocity < 10 and not self._stopped_since then
		self._sstopped_since = t
	elseif velocity >= 10 and self._stopped_since then
		self._stopped_since = nil
	end

	if self._stopped_since and t - self._stopped_since > 0.2 and self._invalid_position_since and t - self._invalid_position_since > 0.2 then
		respawn = true
	end

	local state = self._vehicle:get_state()
	local speed = state:get_speed()
	local gear = state:get_gear()

	if self._current_state_name == VehicleDrivingExt.STATE_DRIVING then
		local condition = gear ~= 1 and velocity < 10 and speed < 0.5 and self._last_input_fwd_dt > 0.2 and self._last_input_bwd_dt > 0.2 and self._stopped_since and t - self._stopped_since > 0.5

		if condition then
			self._could_not_move = condition
		elseif speed > 0.5 then
			self._could_not_move = false
			self._last_input_bwd_dt = 0
			self._last_input_fwd_dt = 0
		end
	end

	self.respawn_available = respawn or self._could_not_move
	self._position_dt = self._position_dt + dt

	if self._position_dt > 1 then
		if not self.respawn_available and speed > 2 and rot:z().z >= 0.9 then
			if not self._positions[self._position_counter] then
				self._positions[self._position_counter] = {}
			end

			self._positions[self._position_counter].pos = self._vehicle:position()
			self._positions[self._position_counter].rot = self._vehicle:rotation()
			self._positions[self._position_counter].oobb = self._unit:oobb()
			self._position_counter = self._position_counter + 1

			if self._position_counter == 20 then
				self._position_counter = 0
				self._position_counter_turnover = true
			end
		end

		self._position_dt = 0
	end

	if self.respawn_available and not self._respawn_available_since then
		self._respawn_available_since = t
	elseif not self.respawn_available then
		self._respawn_available_since = nil
	end

	if self._respawn_available_since and t - self._respawn_available_since > 10 then
		self:respawn_vehicle(true)
	end
end

function VehicleDrivingExt:respawn_vehicle(auto_respawn)
	self.respawn_available = false

	if auto_respawn then
		-- Nothing
	end

	print("Respawning vehicle on last valid position")

	self._stopped_since = nil
	self._invalid_position_since = nil
	self._last_input_bwd_dt = 0
	self._last_input_fwd_dt = 0
	self._could_not_move = false
	local counter = self._position_counter - 4

	if counter < 0 then
		if self._position_counter_turnover then
			counter = 20 + counter
		else
			counter = 0
		end
	end

	self._position_counter = self._position_counter - 1

	if self._position_counter < 0 then
		if self._position_counter_turnover then
			self._position_counter = 20 + self._position_counter
		else
			self._position_counter = 0
		end
	end

	Application:debug("Using respawn position on the index:", counter)

	while counter >= 0 do
		if self._positions[counter] and self:_check_respawn_spot_valid(counter) then
			print("[VehicleDrivingExt:respawn_vehicle] respawning vehicle on position, counter", counter)
			self._vehicle:set_position(self._positions[counter].pos)
			self._vehicle:set_rotation(self._positions[counter].rot)

			break
		else
			Application:debug("[VehicleDrivingExt:respawn_vehicle] Trying to respawn vehicle on occupied position", counter)

			counter = counter - 1
		end
	end
end

function VehicleDrivingExt:_check_respawn_spot_valid(counter)
	local oobb = self._positions[counter].oobb
	local slotmask = managers.slot:get_mask("all")
	local units = World:find_units(self._unit, "intersect", "obb", oobb:center(), oobb:x() * 0.8, oobb:y() * 0.8, oobb:z() * 0.8, slotmask)

	if #units > 0 then
		return false
	else
		return true
	end
end

function VehicleDrivingExt:_play_sound_events(t, dt)
	local state = self._vehicle:get_state()
	local slip = false
	local bump = false
	local going_reverse = false
	local speed = state:get_speed() * 3.6

	for id, wheel_state in pairs(state:wheel_states()) do
		local current_jounce = wheel_state:jounce()
		local last_frame_jounce = self._wheel_jounce[id]

		if last_frame_jounce == nil then
			last_frame_jounce = 0
		end

		local dj = current_jounce - last_frame_jounce
		local jerk = dj / dt

		if self._tweak_data.sound.bump_treshold < jerk then
			bump = true
		end

		self._wheel_jounce[id] = current_jounce

		if self._tweak_data.sound.lateral_slip_treshold < math.abs(wheel_state:lat_slip()) then
			slip = true
		elseif self._tweak_data.sound.longitudal_slip_treshold < math.abs(wheel_state:long_slip()) and state:get_rpm() > 500 then
			slip = true
		end
	end

	if state:get_gear() == 0 and speed > 0.5 then
		going_reverse = true
	end

	if slip and self._slip_sound then
		if self._playing_slip_sound_dt == 0 then
			self._slip_soundsource:post_event(self._slip_sound)

			self._playing_slip_sound_dt = self._playing_slip_sound_dt + dt
		end
	elseif self._playing_slip_sound_dt > 0.1 then
		self._slip_soundsource:post_event(self._slip_sound_stop)

		self._playing_slip_sound_dt = 0
	end

	if self._playing_slip_sound_dt > 0 then
		self._playing_slip_sound_dt = self._playing_slip_sound_dt + dt
	end

	if going_reverse and self._reverse_sound then
		if self._playing_reverse_sound_dt == 0 then
			self._door_soundsource:post_event(self._reverse_sound)

			self._playing_reverse_sound_dt = self._playing_reverse_sound_dt + dt
		end
	elseif self._playing_reverse_sound_dt > 0.1 then
		self._door_soundsource:post_event(self._reverse_sound_stop)

		self._playing_reverse_sound_dt = 0
	end

	if self._playing_reverse_sound_dt > 0 then
		self._playing_reverse_sound_dt = self._playing_reverse_sound_dt + dt
	end

	if bump and self._bump_sound then
		self._bump_soundsource:set_rtpc(self._bump_rtpc, 2 * math.clamp(speed, 0, 100))
		self._bump_soundsource:post_event(self._bump_sound)
	end

	self:_play_engine_sound(state)
end

function VehicleDrivingExt:_start_engine_sound()
	if not self._playing_engine_sound and self._engine_soundsource then
		self._playing_engine_sound = true

		if self._tweak_data.sound.engine_start then
			self._engine_soundsource:post_event(self._tweak_data.sound.engine_start)
		else
			Application:error("[Vehicle] No sound specified for engine_start")
		end

		if self._tweak_data.sound.engine_sound_event then
			self._engine_soundsource:post_event(self._tweak_data.sound.engine_sound_event)
		else
			Application:error("[Vehicle] No sound specified for engine_sound_event")
		end

		self._playing_engine_sound = true
	end
end

function VehicleDrivingExt:_stop_engine_sound()
	if self._playing_engine_sound and self._engine_soundsource then
		self._engine_soundsource:stop()

		self._playing_engine_sound = false
	end
end

function VehicleDrivingExt:_start_broken_engine_sound()
	if not self._playing_engine_sound and self._engine_soundsource and self._tweak_data.sound.broken_engine then
		self._engine_soundsource:post_event(self._tweak_data.sound.broken_engine)

		self._playing_engine_sound = true
	end
end

function VehicleDrivingExt:_play_engine_sound(state)
	local speed = state:get_speed() * 3.6
	local rpm = state:get_rpm()
	local max_speed = self._tweak_data.max_speed
	local max_rpm = self._vehicle:get_max_rpm()
	local relative_speed = speed / max_speed

	if relative_speed > 1 then
		relative_speed = 1
	end

	self._relative_rpm = rpm / max_rpm

	if self._relative_rpm > 1 then
		self._relative_rpm = 1
	end

	if self._engine_soundsource == nil then
		return
	end

	if not self._playing_engine_sound then
		return
	end

	local rpm_rtpc = math.round(self._relative_rpm * 100)
	local speed_rtpc = math.round(relative_speed * 100)

	self._engine_soundsource:set_rtpc(self._tweak_data.sound.engine_rpm_rtpc, rpm_rtpc)
	self._engine_soundsource:set_rtpc(self._tweak_data.sound.engine_speed_rtpc, speed_rtpc)
end

function VehicleDrivingExt:stop_all_sound_events()
	self._hit_soundsource:stop()
	self._slip_soundsource:stop()
	self._bump_soundsource:stop()

	if self._engine_soundsource then
		self._engine_soundsource:stop()
	end

	self._playing_slip_sound_dt = 0
end

function VehicleDrivingExt:_unregister_drive_SO_all()
	for _, seat in pairs(self._seats) do
		self:_unregister_drive_SO(seat)
	end
end

function VehicleDrivingExt:_unregister_drive_SO(seat)
	if seat.drive_SO_data then
		local SO_data = seat.drive_SO_data
		seat.drive_SO_data = nil

		if SO_data.SO_registered then
			managers.groupai:state():remove_special_objective(SO_data.SO_id)
		end

		if alive(SO_data.unit) then
			SO_data.unit:brain():set_objective(nil)
		end
	end
end

function VehicleDrivingExt:_chk_register_drive_SO()
	if not Network:is_server() or not managers.navigation:is_data_ready() then
		return
	end

	for _, seat in pairs(self._seats) do
		if not seat.driving and not alive(seat.occupant) then
			self:_create_seat_SO(seat)
		end
	end
end

function VehicleDrivingExt:_create_seat_SO(seat, dont_register)
	if seat.drive_SO_data then
		return
	end

	local SO_filter = managers.groupai:state():get_unit_type_filter("criminal")
	local tracker_align = managers.navigation:create_nav_tracker(seat.SO_object:position(), false)
	local align_nav_seg = tracker_align:nav_segment()
	local align_pos = seat.SO_object:position()
	local align_rot = seat.SO_object:rotation()
	local align_area = managers.groupai:state():get_area_from_nav_seg_id(align_nav_seg)

	managers.navigation:destroy_nav_tracker(tracker_align)

	local team_ai_animation = self._tweak_data.animations[seat.name]
	local ride_objective = {
		pose = "stand",
		destroy_clbk_key = false,
		type = "act",
		haste = "run",
		nav_seg = align_nav_seg,
		area = align_area,
		pos = align_pos,
		rot = align_rot,
		fail_clbk = callback(self, self, "on_drive_SO_failed", seat),
		action = {
			align_sync = false,
			needs_full_blend = true,
			type = "act",
			body_part = 1,
			variant = team_ai_animation,
			blocks = {
				heavy_hurt = -1,
				hurt = -1,
				action = -1,
				walk = -1
			}
		}
	}
	local SO_descriptor = {
		interval = 0,
		chance_inc = 0,
		base_chance = 1,
		usage_amount = 1,
		AI_group = "friendlies",
		objective = ride_objective,
		search_pos = ride_objective.pos,
		admin_clbk = callback(self, self, "on_drive_SO_administered", seat)
	}
	local SO_id = "ride_" .. tostring(self._unit:key()) .. seat.name
	seat.drive_SO_data = {
		SO_id = SO_id,
		SO_registered = not dont_register,
		align_area = align_area,
		ride_objective = ride_objective
	}

	if not dont_register then
		managers.groupai:state():add_special_objective(SO_id, SO_descriptor)
	end
end

function VehicleDrivingExt:clbk_drive_SO_verification(candidate_unit)
	return true
end

function VehicleDrivingExt:on_drive_SO_administered(seat, unit)
	if seat.drive_SO_data.unit then
		debug_pause("[VehicleDrivingExt:on_drive_SO_administered] Already had a unit!!!!", seat.name, unit, seat.drive_SO_data.unit)
	end

	seat.drive_SO_data.unit = unit
	seat.drive_SO_data.SO_registered = false
	unit:movement().vehicle_unit = self._unit
	unit:movement().vehicle_seat = seat

	managers.network:session():send_to_peers_synched("sync_ai_vehicle_action", "enter", self._unit, seat.name, unit)
end

function VehicleDrivingExt:on_drive_SO_started(seat, unit)
	local rot = seat.third_object:rotation()
	local pos = seat.third_object:position()

	if managers.network:session() then
		-- Nothing
	end
end

function VehicleDrivingExt:on_drive_SO_completed(seat, unit)
	Application:debug("[VehicleDrivingExt:on_drive_SO_completed]", seat.name)

	local rot = seat.third_object:rotation()
	local pos = seat.third_object:position()

	unit:set_rotation(rot)
	unit:set_position(pos)

	seat.occupant = unit

	self._unit:link(Idstring(VehicleDrivingExt.THIRD_PREFIX .. seat.name), unit)

	if managers.network:session() then
		-- Nothing
	end

	unit:brain():set_active(false)
end

function VehicleDrivingExt:on_drive_SO_failed(seat, unit)
	if not seat.drive_SO_data then
		return
	end

	if unit ~= seat.drive_SO_data.unit then
		debug_pause_unit(unit, "[VehicleDrivingExt:on_drive_SO_failed] idiot thinks he is riding", unit)

		return
	end

	seat.drive_SO_data = nil

	self:_create_seat_SO(seat)
end

function VehicleDrivingExt:sync_ai_vehicle_action(action, seat_name, unit)
	if action == "enter" then
		for _, seat in pairs(self._seats) do
			if seat.name == seat_name then
				local rot = seat.third_object:rotation()
				local pos = seat.third_object:position()
				unit:movement().vehicle_unit = self._unit
				unit:movement().vehicle_seat = seat

				self._door_soundsource:post_event(self._tweak_data.sound.door_close)
			end
		end
	elseif action == "exit" then
		unit:movement().vehicle_unit = nil
		unit:movement().vehicle_seat = nil
	else
		debug_pause("[VehicleDrivingExt:sync_ai_vehicle_action] Unknown value for parameter action!", "action", action)
	end
end

function VehicleDrivingExt:collision_callback(tag, unit, body, other_unit, other_body, position, normal, velocity, ...)
	if other_unit and other_unit:npc_vehicle_driving() then
		local attack_data = {
			damage = 1
		}

		other_unit:character_damage():damage_collision(attack_data)
	elseif other_unit and other_unit:damage() and other_body and other_body:extension() then
		local damage = 1

		other_body:extension().damage:damage_collision(self._unit, normal, position, velocity, damage, velocity)
	end
end

function VehicleDrivingExt:on_impact(ray, gforce, velocity)
	if ray then
		self._hit_soundsource:set_position(ray.hit_position)
	else
		self._hit_soundsource:set_position(self._unit:position())
	end

	if self._hit_sound then
		self._hit_soundsource:set_rtpc(self._hit_rtpc, math.clamp(gforce / 2.5, 0, 100))
		self._hit_soundsource:post_event(self._hit_sound)
	end

	local damage_ammount = gforce / 20

	if ray then
		local body = ray.body

		if ray.unit and ray.unit:damage() and ray.body and ray.body:extension() then
			ray.body:extension().damage:damage_collision(self._unit, ray.normal, ray.position, velocity, damage_ammount, velocity)
		end
	end

	local attack_data = {
		damage = damage_ammount,
		col_ray = ray
	}

	self._unit:character_damage():damage_collision(attack_data)

	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant:camera() then
			seat.occupant:camera():play_shaker("player_land", gforce / 500)
		end
	end
end

function VehicleDrivingExt:shooting_stance_allowed()
	return self._shooting_stance_allowed
end

function VehicleDrivingExt:interact_trunk()
	local vehicle = self._unit
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_vehicle_interact_trunk", vehicle, peer_id)
	self:_interact_trunk(vehicle)
end

function VehicleDrivingExt:_interact_trunk(vehicle)
	local driving_ext = vehicle:vehicle_driving()

	if driving_ext._trunk_open then
		vehicle:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_TRUNK_CLOSE)

		driving_ext._trunk_open = false
		driving_ext._interaction_loot = false
	else
		vehicle:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_TRUNK_OPEN)

		driving_ext._trunk_open = true
		driving_ext._interaction_loot = true
	end
end

function VehicleDrivingExt:_number_in_the_vehicle()
	local count = 0

	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant:brain() == nil then
			count = count + 1
		end
	end

	return count
end

function VehicleDrivingExt:pre_destroy(unit)
end

function VehicleDrivingExt:destroy()
	managers.hud:_remove_name_label(self._unit:unit_data().name_label_id)
end
