core:module("CoreElementPlayEffect")
core:import("CoreEngineAccess")
core:import("CoreMissionScriptElement")

ElementPlayEffect = ElementPlayEffect or class(CoreMissionScriptElement.MissionScriptElement)
ElementPlayEffect.IDS_EFFECT = Idstring("effect")

function ElementPlayEffect:init(...)
	ElementPlayEffect.super.init(self, ...)

	if Application:editor() then
		if self._values.effect ~= "none" then
			CoreEngineAccess._editor_load(self.IDS_EFFECT, self._values.effect:id())
		else
			managers.editor:output_error("Cant load effect named \"none\" [" .. self._editor_name .. "]")
		end
	end
end

function ElementPlayEffect:client_on_executed(...)
	self:on_executed(...)
end

function ElementPlayEffect:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self:play_effect()
	ElementPlayEffect.super.on_executed(self, instigator)
end

function ElementPlayEffect:play_effect()
	if self._values.effect ~= "none" then
		local params = {
			effect = Idstring(self._values.effect)
		}
		local pos, rot = self:get_orientation()
		params.position = self._values.screen_space and Vector3() or pos
		params.rotation = self._values.screen_space and Rotation() or rot
		params.base_time = self._values.base_time or 0
		params.random_time = self._values.random_time or 0
		params.max_amount = self._values.max_amount ~= 0 and self._values.max_amount or nil

		managers.environment_effects:spawn_mission_effect(self._id, params)
	elseif Application:editor() then
		managers.editor:output_error("Cant spawn effect named \"none\" [" .. self._editor_name .. "]")
	end
end

function ElementPlayEffect:kill()
	managers.environment_effects:kill_mission_effect(self._id)
end

function ElementPlayEffect:fade_kill()
	managers.environment_effects:fade_kill_mission_effect(self._id)
end

ElementStopEffect = ElementStopEffect or class(CoreMissionScriptElement.MissionScriptElement)

function ElementStopEffect:init(...)
	ElementStopEffect.super.init(self, ...)
end

function ElementStopEffect:client_on_executed(...)
	self:on_executed(...)
end

function ElementStopEffect:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			if self._values.operation == "kill" then
				element:kill()
			elseif self._values.operation == "fade_kill" then
				element:fade_kill()
			end
		end
	end

	ElementStopEffect.super.on_executed(self, instigator)
end
