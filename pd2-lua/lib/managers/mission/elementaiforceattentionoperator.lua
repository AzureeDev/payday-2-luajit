core:import("CoreMissionScriptElement")

ElementAIForceAttentionOperator = ElementAIForceAttentionOperator or class(CoreMissionScriptElement.MissionScriptElement)

function ElementAIForceAttentionOperator:init(...)
	ElementAIForceAttentionOperator.super.init(self, ...)
end

function ElementAIForceAttentionOperator:on_executed(instigator)
	if not self._values.enabled or Network:is_client() then
		return
	end

	if not self._values.element_id then
		return
	end

	if self._values.operation == "disable" then
		managers.groupai:state():set_force_attention(nil)
	else
		Application:error("[ElementAIForceAttentionOperator:on_executed] Operation not implemented:", self._values.operation)
	end

	ElementSpecialObjective.super.on_executed(self, instigator)
end
