core:import("CoreMissionScriptElement")

ElementActionMessage = ElementActionMessage or class(CoreMissionScriptElement.MissionScriptElement)

function ElementActionMessage:init(...)
	ElementActionMessage.super.init(self, ...)
end

function ElementActionMessage:client_on_executed(...)
	self:on_executed(...)
end

function ElementActionMessage:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.message_id ~= "none" then
		if instigator ~= managers.player:player_unit() then
			managers.action_messaging:show_message(self._values.message_id, instigator)
		end
	elseif Application:editor() then
		managers.editor:output_error("Cant show message " .. self._values.message_id .. " in element " .. self._editor_name .. ".")
	end

	ElementActionMessage.super.on_executed(self, instigator)
end
