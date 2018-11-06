core:import("CoreMissionScriptElement")

ElementVehicleSpawner = ElementVehicleSpawner or class(CoreMissionScriptElement.MissionScriptElement)

function ElementVehicleSpawner:init(...)
	Application:trace("ElementVehicleSpawner:init")
	ElementVehicleSpawner.super.init(self, ...)

	self._vehicle_units = {}

	Application:trace("ElementVehicleSpawner:init")
	ElementVehicleSpawner.super.init(self, ...)

	self._vehicles = {
		muscle = "units/pd2_dlc_shoutout_raid/vehicles/fps_vehicle_muscle_1/fps_vehicle_muscle_1",
		escape_van = "units/pd2_dlc_drive/vehicles/fps_vehicle_van_1/fps_vehicle_van_1",
		falcogini = "units/pd2_dlc_cage/vehicles/fps_vehicle_falcogini_1/fps_vehicle_falcogini_1"
	}
	self._vehicle_units = {}
end

function ElementVehicleSpawner:value(name)
	Application:trace("ElementVehicleSpawner:value", name)

	return self._values[name]
end

function ElementVehicleSpawner:client_on_executed(...)
	Application:trace("ElementVehicleSpawner:client_on_executed")

	if not self._values.enabled then
		return
	end
end

function ElementVehicleSpawner:on_executed(instigator)
	Application:trace("ElementVehicleSpawner:on_executed", inspect(self._values))

	if not self._values.enabled then
		return
	end

	local vehicle = safe_spawn_unit(self._vehicles[self._values.vehicle], self._values.position, self._values.rotation)

	table.insert(self._vehicle_units, vehicle)
	print("[ElementVehicleSpawner] Spawned vehicle", vehicle)
	ElementVehicleSpawner.super.on_executed(self, self._unit or instigator)
end

function ElementVehicleSpawner:unspawn_all_units()
	for _, vehicle_unit in ipairs(self._vehicle_units) do
		vehicle_unit:set_slot(0)
	end
end

function ElementVehicleSpawner:stop_simulation(...)
	self:unspawn_all_units()
end
