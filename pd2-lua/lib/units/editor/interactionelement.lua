InteractionUnitElement = InteractionUnitElement or class(MissionElement)
InteractionUnitElement.ON_EXECUTED_ALTERNATIVES = {
	"interacted",
	"interupt",
	"start"
}

function InteractionUnitElement:init(unit)
	InteractionUnitElement.super.init(self, unit)

	self._hed.tweak_data_id = "none"
	self._hed.override_timer = -1
	self._hed.host_only = false

	table.insert(self._save_values, "tweak_data_id")
	table.insert(self._save_values, "override_timer")
	table.insert(self._save_values, "host_only")
end

function InteractionUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "tweak_data_id", table.list_add({"none"}, table.map_keys(tweak_data.interaction)))
	self:_build_value_number(panel, panel_sizer, "override_timer", {
		floats = 1,
		min = -1
	}, "Can be used to override the interaction time specified in tweak data. -1 means that it should not override.")
	self:_build_value_checkbox(panel, panel_sizer, "host_only", "Only allow the host of the game to interact with this.", "Host Only")
	self:_add_help_text("This element creates an interaction. Override time is optional and will replace tweak data timer (-1 means do not overrride). Use disabled/enabled state on element to set active state on interaction.")
end

function InteractionUnitElement:add_to_mission_package()
	managers.editor:add_to_world_package({
		name = "units/dev_tools/mission_elements/point_interaction/interaction_dummy",
		category = "units",
		continent = self._unit:unit_data().continent
	})
	managers.editor:add_to_world_package({
		name = "units/dev_tools/mission_elements/point_interaction/interaction_dummy_nosync",
		category = "units",
		continent = self._unit:unit_data().continent
	})
end

