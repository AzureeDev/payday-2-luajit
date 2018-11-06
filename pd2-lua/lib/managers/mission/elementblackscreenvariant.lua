core:import("CoreMissionScriptElement")

ElementBlackscreenVariant = ElementBlackscreenVariant or class(CoreMissionScriptElement.MissionScriptElement)

function ElementBlackscreenVariant:init(...)
	ElementBlackscreenVariant.super.init(self, ...)
end

function ElementBlackscreenVariant:client_on_executed(...)
	self:on_executed(...)
end

function ElementBlackscreenVariant:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	managers.groupai:state():set_blackscreen_variant(tonumber(self._values.variant))
	ElementBlackscreenVariant.super.on_executed(self, instigator)
end

ElementEndscreenVariant = ElementEndscreenVariant or class(CoreMissionScriptElement.MissionScriptElement)

function ElementEndscreenVariant:init(...)
	ElementEndscreenVariant.super.init(self, ...)
end

function ElementEndscreenVariant:client_on_executed(...)
	self:on_executed(...)
end

function ElementEndscreenVariant:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	managers.groupai:state():set_endscreen_variant(tonumber(self._values.variant))
	ElementEndscreenVariant.super.on_executed(self, instigator)
end
