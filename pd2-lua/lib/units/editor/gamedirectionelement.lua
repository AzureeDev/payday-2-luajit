GameDirectionUnitElement = GameDirectionUnitElement or class(MissionElement)

function GameDirectionUnitElement:init(unit)
	MissionElement.init(self, unit)
end

function GameDirectionUnitElement:update_selected(t, dt)
end

function GameDirectionUnitElement:_build_panel(panel, panel_sizer)
end
