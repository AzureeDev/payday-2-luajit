SpawnDeployableUnitElement = SpawnDeployableUnitElement or class(MissionElement)

function SpawnDeployableUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.deployable_id = "none"

	table.insert(self._save_values, "deployable_id")
end

function SpawnDeployableUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "deployable_id", {
		"none",
		"doctor_bag",
		"ammo_bag",
		"grenade_crate",
		"bodybags_bag"
	}, "Select a deployable_id to be spawned.")
end
