DropInPointUnitElement = DropInPointUnitElement or class(MissionElement)

function DropInPointUnitElement:init(unit)
	DropInPointUnitElement.super.init(self, unit)
end

function DropInPointUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()
	self:_add_help_text("Will act as a drop-in point when enabled. Drop-in points affect users that drop-in, respawns and team AI spawns.")
end
