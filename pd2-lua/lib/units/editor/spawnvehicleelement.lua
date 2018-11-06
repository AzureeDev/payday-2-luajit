SpawnVehicleElement = SpawnVehicleElement or class(MissionElement)

function SpawnVehicleElement:init(unit)
	Application:trace("SpawnVehicleElement:init", unit)
	MissionElement.init(self, unit)

	self._hed.state = VehicleDrivingExt.STATE_INACTIVE
	self._hed.vehicle = "falcogini"

	table.insert(self._save_values, "state")
	table.insert(self._save_values, "vehicle")
end

function SpawnVehicleElement:_build_panel(panel, panel_sizer)
	Application:trace("SpawnVehicleElement:_build_panel")
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local vehicles = {
		"falcogini",
		"escape_van",
		"muscle"
	}

	self:_build_value_combobox(panel, panel_sizer, "vehicle", vehicles, "Select a vehicle from the combobox")
	self:_add_help_text("The vehicle that will be spawned")
end

function SpawnVehicleElement:add_to_mission_package()
	Application:trace("SpawnVehicleElement:add_to_mission_package")
end
