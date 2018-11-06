core:import("CoreMissionScriptElement")

ElementTeammateComment = ElementTeammateComment or class(CoreMissionScriptElement.MissionScriptElement)

function ElementTeammateComment:init(...)
	ElementTeammateComment.super.init(self, ...)
end

function ElementTeammateComment:client_on_executed(...)
	self:on_executed(...)
end

function ElementTeammateComment:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.comment ~= "none" then
		local radius = self._values.radius ~= 0 and self._values.radius or nil
		local trigger_unit = self._values.use_instigator and instigator or nil

		if trigger_unit and type(trigger_unit) ~= "userdata" then
			debug_pause("[ElementTeammateComment:on_executed] instigator is not a unit", instigator, trigger_unit)

			trigger_unit = nil
		end

		managers.groupai:state():teammate_comment(trigger_unit, self._values.comment, self._values.position, self._values.close_to_element, radius, false)
	elseif Application:editor() then
		managers.editor:output_error("Cant play comment " .. self._values.comment .. " in element " .. self._editor_name .. ".")
	end

	ElementTeammateComment.super.on_executed(self, instigator)
end
