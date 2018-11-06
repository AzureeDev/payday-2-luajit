ScriptUnitData = ScriptUnitData or class()
UnitBase = UnitBase or class()

function UnitBase:init(unit, update_enabled)
	self._unit = unit

	if not update_enabled then
		unit:set_extension_update_enabled(Idstring("base"), false)
	end
end

function UnitBase:pre_destroy(unit)
	self._destroying = true
end
