PickupUnitElement = PickupUnitElement or class(MissionElement)
PickupUnitElement.SAVE_UNIT_POSITION = false
PickupUnitElement.SAVE_UNIT_ROTATION = false

function PickupUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.pickup = "remove"

	table.insert(self._save_values, "pickup")
end

function PickupUnitElement.get_options()
	return table.map_keys(tweak_data.pickups)
end

function PickupUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "pickup", table.list_add({
		"remove"
	}, table.map_keys(tweak_data.pickups)), "Select a pickup to be set or remove.")
end
