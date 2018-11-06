core:module("CoreElementSpawnUnit")
core:import("CoreMissionScriptElement")
core:import("CoreUnit")

ElementSpawnUnit = ElementSpawnUnit or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSpawnUnit:init(...)
	ElementSpawnUnit.super.init(self, ...)

	self._units = {}
end

function ElementSpawnUnit:client_on_executed(...)
	if self._values.unit_name ~= "none" then
		local network_sync = PackageManager:unit_data(self._values.unit_name:id()):network_sync()

		if network_sync ~= "none" and network_sync ~= "client" then
			return
		end
	end

	self:on_executed(...)
end

function ElementSpawnUnit:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.unit_name ~= "none" then
		local unit = CoreUnit.safe_spawn_unit(self._values.unit_name, self._values.position, self._values.rotation)

		if self._values.unit_spawn_mass then
			unit:push(self._values.unit_spawn_mass, self._values.unit_spawn_dir * self._values.unit_spawn_velocity)
		end

		table.insert(self._units, unit)
	elseif Application:editor() then
		managers.editor:output_error("Cant spawn unit \"none\" [" .. self._editor_name .. "]")
	end

	ElementSpawnUnit.super.on_executed(self, instigator)
end

function ElementSpawnUnit:units()
	return self._units
end

function ElementSpawnUnit:delete_units()
	for _, unit in ipairs(self._units) do
		unit:set_slot(0)
	end

	self._units = {}
end
