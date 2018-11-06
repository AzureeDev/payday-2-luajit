SpawnTeamAIUnitElement = SpawnTeamAIUnitElement or class(MissionElement)

function SpawnTeamAIUnitElement:init(unit)
	SpawnTeamAIUnitElement.super.init(self, unit)

	self._hed.character = "any"

	table.insert(self._save_values, "character")
end

function SpawnTeamAIUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local characters = {}

	for _, data in ipairs(managers.criminals:characters()) do
		table.insert(characters, data.name)
	end

	self:_build_value_combobox(panel, panel_sizer, "character", table.list_add({
		"any"
	}, characters))
	self:_add_help_text("Spawns a team AI if possible. NOTE: If a character is provided and it's not available it will not be spawned at all!")
end
