MissionDoor = MissionDoor or class(UnitBase)

function MissionDoor:init(unit)
	MissionDoor.super.init(self, unit, false)

	self._unit = unit
	self._devices = {}
	self._powered = true
end

function MissionDoor:update(unit, t, dt)
	if self._explode_t and self._explode_t < t then
		self:_c4_sequence_done()
	end
end

function MissionDoor:activate()
	if Network:is_client() then
		return
	end

	if self._active then
		Application:error("[MissionDoor:activate()] allready active", self._unit)

		return
	end

	self._active = true

	CoreDebug.cat_debug("gaspode", "MissionDoor:activate", self.tweak_data)

	local devices_data = tweak_data.mission_door[self.tweak_data].devices

	for type, device_data in pairs(devices_data) do
		local amount = #device_data
		self._devices[type] = {
			placed = false,
			placed_counter = 0,
			completed_counter = 0,
			completed = false,
			units = {},
			amount = amount
		}

		for _, unit_data in ipairs(device_data) do
			local a_obj = self._unit:get_object(Idstring(unit_data.align))
			local position = a_obj:position()
			local rotation = a_obj:rotation()
			local unit = World:spawn_unit(unit_data.unit, position, rotation)

			unit:mission_door_device():set_parent_data(self._unit, type)

			if unit_data.can_jam ~= nil then
				unit:timer_gui():set_can_jam(unit_data.can_jam)
			end

			if unit_data.timer then
				unit:timer_gui():set_override_timer(unit_data.timer)
			end

			MissionDoor.run_mission_door_device_sequence(unit, "activate")

			if managers.network:session() then
				managers.network:session():send_to_peers_synched("run_mission_door_device_sequence", unit, "activate")
			end

			table.insert(self._devices[type].units, {
				placed = false,
				completed = false,
				unit = unit
			})
		end
	end
end

function MissionDoor.run_mission_door_device_sequence(unit, sequence_name)
	if unit:damage():has_sequence(sequence_name) then
		unit:damage():run_sequence_simple(sequence_name)
	end
end

function MissionDoor:deactivate()
	CoreDebug.cat_debug("gaspode", "MissionDoor:deactivate")

	self._active = nil

	self:_destroy_devices()
end

function MissionDoor.set_mission_door_device_powered(unit, powered, enabled_interaction)
	unit:timer_gui():set_powered(powered, enabled_interaction)
end

function MissionDoor:set_powered(powered)
	self._powered = powered
	local drills = self._devices.drill

	if drills then
		for _, unit_data in ipairs(drills.units) do
			if unit_data.placed and alive(unit_data.unit) then
				unit_data.unit:timer_gui():set_powered(powered)

				if managers.network:session() then
					managers.network:session():send_to_peers_synched("set_mission_door_device_powered", unit_data.unit, powered, false)
				end
			end
		end
	end
end

function MissionDoor:set_on(state)
	local drills = self._devices.drill

	if drills then
		for _, unit_data in ipairs(drills.units) do
			if unit_data.placed and alive(unit_data.unit) then
				unit_data.unit:timer_gui():set_powered(state, true)

				if managers.network:session() then
					managers.network:session():send_to_peers_synched("set_mission_door_device_powered", unit_data.unit, state, true)
				end
			end
		end
	end
end

function MissionDoor:_get_device_unit_data(unit, type)
	if not self._devices or not self._devices[type] then
		debug_pause("[MissionDoor:_get_device_unit_data] Mission Door do not have any devices of this type!", "type", type, "Mission Door", unit, "Devices", inspect(self._devices))

		return nil
	end

	for _, unit_data in ipairs(self._devices[type].units) do
		if unit_data.unit == unit then
			return unit_data
		end
	end
end

function MissionDoor:device_placed(unit, type)
	local device_unit_data = self:_get_device_unit_data(unit, type)

	if not device_unit_data or device_unit_data.placed then
		CoreDebug.cat_debug("gaspode", "MissionDoor:device_placed", "Allready placed")

		return
	end

	self._devices[type].placed_counter = self._devices[type].placed_counter + 1
	device_unit_data.placed = true

	self:trigger_sequence(type .. "_placed")
	self:_check_placed_counter(type)
end

function MissionDoor:device_completed(type)
	self._devices[type].completed = true
	self._devices[type].completed_counter = self._devices[type].completed_counter + 1

	self:trigger_sequence(type .. "_completed")
	self:_check_completed_counter(type)
end

function MissionDoor:device_jammed(type)
	self:trigger_sequence(type .. "_jammed")
end

function MissionDoor:device_resumed(type)
	self:trigger_sequence(type .. "_resumed")
end

function MissionDoor:_check_placed_counter(type)
	if self._devices[type].placed_counter ~= self._devices[type].amount then
		CoreDebug.cat_debug("gaspode", "MissionDoor:_check_placed_counter", "All", type, "are not placed yet")

		return
	end

	CoreDebug.cat_debug("gaspode", "MissionDoor:_check_placed_counter", "All of type", type, "has been placed")
	self:trigger_sequence("all_" .. type .. "_placed")

	if type == "c4" and self._devices[type].placed_counter == self._devices[type].amount then
		self:_initiate_c4_sequence()

		return
	end

	if (type == "key" or type == "ecm") and self._devices[type].placed_counter == self._devices[type].amount then
		for _, unit_data in ipairs(self._devices[type].units) do
			self:device_completed(type)
		end

		return
	end
end

function MissionDoor:_check_completed_counter(type)
	if self._devices[type].completed_counter == self._devices[type].amount then
		self:_destroy_devices()
		self:trigger_sequence("door_opened")

		local sequence_name = "open_door"

		if type == "drill" then
			-- Nothing
		elseif type == "c4" then
			sequence_name = "explode_door"

			if Network:is_server() then
				if self._unit:base() then
					self._unit:base().c4 = true
				end

				local alert_event = {
					"aggression",
					self._unit:position(),
					tweak_data.weapon.trip_mines.alert_radius,
					managers.groupai:state():get_unit_type_filter("civilians_enemies"),
					self._unit
				}

				managers.groupai:state():propagate_alert(alert_event)
			end
		elseif type == "key" then
			sequence_name = "open_door_keycard"
		elseif type == "ecm" then
			sequence_name = "open_door_ecm"
		end

		if managers.network:session() then
			managers.network:session():send_to_peers_synched("run_mission_door_sequence", self._unit, sequence_name)
		end

		self:run_sequence_simple(sequence_name)
	end
end

function MissionDoor:_initiate_c4_sequence()
	for type, device in pairs(self._devices) do
		if type ~= "c4" then
			for _, unit_data in ipairs(device.units) do
				if alive(unit_data.unit) then
					unit_data.unit:set_slot(0)
				end
			end
		end
	end

	for _, unit_data in ipairs(self._devices.c4.units) do
		MissionDoor.run_mission_door_device_sequence(unit_data.unit, "activate_explode_sequence")

		if managers.network:session() then
			managers.network:session():send_to_peers_synched("run_mission_door_device_sequence", unit_data.unit, "activate_explode_sequence")
		end
	end

	self._explode_t = Application:time() + 5

	self._unit:set_extension_update_enabled(Idstring("base"), true)
end

function MissionDoor:_c4_sequence_done()
	self._explode_t = nil

	self._unit:set_extension_update_enabled(Idstring("base"), false)

	if not self._devices.c4 then
		return
	end

	for _, unit_data in ipairs(self._devices.c4.units) do
		self:device_completed("c4")
	end
end

function MissionDoor:run_sequence_simple(sequence_name)
	self:_run_sequence_simple(sequence_name)
end

function MissionDoor:trigger_sequence(trigger_sequence_name)
	CoreDebug.cat_debug("gaspode", "MissionDoor:trigger_sequence", trigger_sequence_name)
	self:_run_sequence_simple(trigger_sequence_name)
end

function MissionDoor:_run_sequence_simple(sequence_name)
	self._unit:damage():run_sequence_simple(sequence_name)
end

function MissionDoor:_destroy_devices()
	for _, device in pairs(self._devices) do
		for _, unit_data in ipairs(device.units) do
			if alive(unit_data.unit) then
				unit_data.unit:set_slot(0)
			end
		end
	end

	self._devices = {}
end

function MissionDoor:destroy()
	for _, device in pairs(self._devices) do
		for _, unit_data in ipairs(device.units) do
			if alive(unit_data.unit) then
				unit_data.unit:set_slot(0)
			end
		end
	end
end

MissionDoorDevice = MissionDoorDevice or class()

function MissionDoorDevice:init(unit)
	self._unit = unit
end

function MissionDoorDevice:set_parent_data(door_unit, device_type)
	self._parent_door = door_unit
	self._device_type = device_type
end

function MissionDoorDevice:placed()
	if not alive(self._parent_door) then
		CoreDebug.cat_debug("gaspode", "MissionDoor:placed", "Had no parent door unit")

		return
	end

	self._placed = true

	self._parent_door:base():device_placed(self._unit, self._device_type)
end

function MissionDoorDevice:can_place()
	return not self._placed
end

function MissionDoorDevice:report_jammed_state(jammed)
	if not alive(self._parent_door) then
		CoreDebug.cat_debug("gaspode", "MissionDoor:report_jammed_state", "Had no parent door unit")

		return
	end

	if jammed then
		self._parent_door:base():device_jammed(self._device_type)
	else
		self._parent_door:base():device_resumed(self._device_type)
	end
end

function MissionDoorDevice:report_resumed()
	if not alive(self._parent_door) then
		CoreDebug.cat_debug("gaspode", "MissionDoor:report_jammed_state", "Had no parent door unit")

		return
	end

	self._parent_door:base():device_resumed(self._device_type)
end

function MissionDoorDevice:report_completed()
	if not alive(self._parent_door) then
		CoreDebug.cat_debug("gaspode", "MissionDoor:report_completed", "Had no parent door unit")

		return
	end

	self._parent_door:base():device_completed(self._device_type)
end

function MissionDoorDevice:report_trigger_sequence(trigger_sequence_name)
	CoreDebug.cat_debug("gaspode", "MissionDoor:report_trigger_sequence", trigger_sequence_name)

	if not alive(self._parent_door) then
		CoreDebug.cat_debug("gaspode", "MissionDoor:report_trigger_sequence", "Had no parent door unit")

		return
	end

	self._parent_door:base():trigger_sequence(trigger_sequence_name)
end

function MissionDoorDevice:destroy()
end
