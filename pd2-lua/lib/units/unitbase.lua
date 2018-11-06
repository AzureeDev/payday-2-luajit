UnitBase = UnitBase or class()

function UnitBase:init(unit, update_enabled)
	self._unit = unit

	if not update_enabled then
		unit:set_extension_update_enabled(Idstring("base"), false)
	end

	self._destroy_listener_holder = ListenerHolder:new()
end

function UnitBase:add_destroy_listener(key, clbk)
	if not self._destroying then
		self._destroy_listener_holder:add(key, clbk)
	end
end

function UnitBase:remove_destroy_listener(key)
	self._destroy_listener_holder:remove(key)
end

function UnitBase:save(data)
end

function UnitBase:load(data)
	managers.worlddefinition:use_me(self._unit)
end

function UnitBase:pre_destroy(unit)
	self._destroying = true

	self._destroy_listener_holder:call(unit)
end

function UnitBase:destroy(unit)
	if self._destroying then
		return
	end

	self._destroy_listener_holder:call(unit)
end

function UnitBase:set_slot(unit, slot)
	unit:set_slot(slot)
end
