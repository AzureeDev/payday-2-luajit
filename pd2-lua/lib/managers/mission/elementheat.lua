core:import("CoreMissionScriptElement")

ElementHeat = ElementHeat or class(CoreMissionScriptElement.MissionScriptElement)

function ElementHeat:init(...)
	ElementHeat.super.init(self, ...)
end

function ElementHeat:client_on_executed(...)
	self:on_executed(...)
end

function ElementHeat:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if Network:is_server() then
		if self._values.level ~= 0 then
			managers.groupai:state():force_up_heat_level(self._values.level)
		elseif self._values.points ~= 0 then
			-- Nothing
		end
	end

	ElementHeat.super.on_executed(self, instigator)
end

ElementHeatTrigger = ElementHeatTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementHeatTrigger:init(...)
	ElementHeatTrigger.super.init(self, ...)

	if Network:is_server() then
		self:add_callback()
	end
end

function ElementHeatTrigger:add_callback()
end

function ElementHeatTrigger:remove_callback()
end

function ElementHeatTrigger:heat_changed()
	if Network:is_client() then
		return
	end
end

function ElementHeatTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	instigator = managers.player:player_unit()

	ElementHeatTrigger.super.on_executed(self, instigator)

	if not self._values.enabled then
		self:remove_callback()
	end
end
