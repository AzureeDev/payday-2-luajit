core:import("CoreEditorUtils")

SpawnGageAssignmentElement = SpawnGageAssignmentElement or class(MissionElement)
SpawnGageAssignmentElement.USES_POINT_ORIENTATION = true

function SpawnGageAssignmentElement:init(unit)
	SpawnGageAssignmentElement.super.init(self, unit)
end

function SpawnGageAssignmentElement:_build_panel(panel, panel_sizer)
	self:_create_panel()
end

function SpawnGageAssignmentElement:destroy(...)
	SpawnGageAssignmentElement.super.destroy(self, ...)
end
