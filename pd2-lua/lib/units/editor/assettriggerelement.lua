AssetTriggerUnitElement = AssetTriggerUnitElement or class(MissionElement)
AssetTriggerUnitElement.SAVE_UNIT_POSITION = false
AssetTriggerUnitElement.SAVE_UNIT_ROTATION = false

function AssetTriggerUnitElement:init(unit)
	AssetTriggerUnitElement.super.init(self, unit)

	self._hed.trigger_times = 1
	self._hed.id = managers.assets:get_default_asset_id()

	table.insert(self._save_values, "id")
end

function AssetTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "id", managers.assets:get_every_asset_ids(), "Select an asset id from the combobox")
	self:_add_help_text("Set the asset that the element should trigger on.")
end
