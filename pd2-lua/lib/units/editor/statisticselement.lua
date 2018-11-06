StatisticsElement = StatisticsElement or class(MissionElement)
StatisticsElement.SAVE_UNIT_POSITION = false
StatisticsElement.SAVE_UNIT_ROTATION = false

function StatisticsElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.name = tweak_data.statistics:mission_statistics_table()[1]

	table.insert(self._save_values, "name")
end

function StatisticsElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "name", tweak_data.statistics:mission_statistics_table(), "Select an mission statistics from the combobox")
end
