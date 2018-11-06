core:import("CoreMissionScriptElement")

ElementPlayerNumberCheck = ElementPlayerNumberCheck or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPlayerNumberCheck:init(...)
	ElementPlayerNumberCheck.super.init(self, ...)
end

function ElementPlayerNumberCheck:client_on_executed(...)
	self:on_executed(...)
end

function ElementPlayerNumberCheck:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local num_plrs = managers.network:session():amount_of_players()

	if not self._values["num" .. num_plrs] then
		return
	end

	ElementPlayerNumberCheck.super.on_executed(self, instigator)
end
