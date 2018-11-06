core:module("CoreSlaveUpdators")
core:import("CoreTable")
core:import("CoreCode")
core:import("CoreEngineAccess")

NETWORK_SLAVE_RECEIVER = Idstring("slaveupdator")
NETWORK_MASTER_RECEIVER = Idstring("masterupdator")
DEFAULT_NETWORK_PORT = 31254
DEFAULT_NETWORK_LSPORT = 31255
UNITS_PER_FRAME = 1
SlaveManager = SlaveManager or class()
Updator = Updator or class()

function Updator:init()
end

function Updator:peer()
	return self._peer
end

function Updator:update()
end

function Updator:set_batch_count()
end

SlaveUpdator = SlaveUpdator or class(Updator)

function SlaveUpdator:init(vp, port)
	Network:bind(port or DEFAULT_NETWORK_PORT, self)
	Network:set_receiver(NETWORK_SLAVE_RECEIVER, self)

	self._units = {}
	self._pings = {}

	vp:enable_slave(port)

	return true
end

function SlaveUpdator:type()
	return "slave"
end

function SlaveUpdator:slaveupdators_sync(key, name, pos, rot, rpc)
	local unit = self._units[key]

	if CoreCode.alive(unit) then
		unit:set_position(pos)
		unit:set_rotation(rot)

		self._pings[key] = nil
	else
		CoreEngineAccess._editor_load(Idstring("unit"), name:id())

		unit = World:spawn_unit_without_extensions(name:id(), pos, rot)
		self._units[key] = unit
	end

	rpc:slaveupdators_ready_to_send()
end

function SlaveUpdator:slaveupdators_reset(rpc)
	for _, unit in pairs(self._pings) do
		if CoreCode.alive(unit) then
			World:delete_unit(unit)
		end
	end

	self._pings = table.map_copy(self._units)

	rpc:slaveupdators_ready_to_send()
end

function SlaveUpdator:slaveupdators_init()
	for _, unit in ipairs(World:find_units_quick("all")) do
		if CoreCode.alive(unit) then
			World:delete_unit(unit)
		end
	end

	self._units = {}
	self._pings = {}
end

MasterUpdator = MasterUpdator or class(Updator)

function MasterUpdator:init(vp, host, port, master_listener_port, manual_pumping)
	self._peer = Network:handshake(host or "localhost", port or DEFAULT_NETWORK_PORT)

	if not self._peer then
		return false
	end

	Network:bind(master_listener_port or DEFAULT_NETWORK_LSPORT, self)
	Network:set_receiver(NETWORK_MASTER_RECEIVER, self)

	self._unitqueue = {}
	self._ready_to_send = true

	vp:enable_master(host, port, master_listener_port, manual_pumping)
	self:set_batch_count()
	self._peer:slaveupdators_init()

	return true
end

function MasterUpdator:type()
	return "master"
end

function MasterUpdator:set_batch_count(count)
	self._units_per_frame = count or UNITS_PER_FRAME
end

function MasterUpdator:update(t, dt)
	if #self._unitqueue == 0 then
		self._peer:slaveupdators_reset()

		self._unitqueue = World:find_units_quick("all")
	end

	if not self._ready_to_send then
		return
	end

	local num_sent = 0

	for i = #self._unitqueue, 1, -1 do
		local unit = self._unitqueue[i]

		table.remove(self._unitqueue, i)

		if CoreCode.alive(unit) and unit:visible() and unit:enabled() and not unit:mover() then
			self._peer:slaveupdators_sync(tostring(unit:key()), assert(unit:name():s()), unit:position(), unit:rotation())

			self._ready_to_send = false
			num_sent = num_sent + 1

			if self._units_per_frame <= num_sent then
				break
			end
		end
	end
end

function MasterUpdator:slaveupdators_ready_to_send()
	self._ready_to_send = true
end
