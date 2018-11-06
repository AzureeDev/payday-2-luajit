CoreMissionElementData = CoreMissionElementData or class()
MissionElementData = MissionElementData or class(CoreMissionElementData)

function MissionElementData:init(...)
	CoreMissionElementData.init(self, ...)
end

function CoreMissionElementData:init(unit)
end
