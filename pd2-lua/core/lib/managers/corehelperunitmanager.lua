core:module("CoreHelperUnitManager")
core:import("CoreClass")

HelperUnitManager = HelperUnitManager or CoreClass.class()

function HelperUnitManager:init()
	self:_setup()
end

function HelperUnitManager:clear()
	self:_setup()
end

function HelperUnitManager:_setup()
	self._types = {}
end

function HelperUnitManager:add_unit(unit, type)
	self._types[type] = self._types[type] or {}

	table.insert(self._types[type], unit)
end

function HelperUnitManager:get_units_by_type(type)
	return self._types[type] or {}
end
