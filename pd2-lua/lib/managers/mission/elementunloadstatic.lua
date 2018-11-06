core:import("CoreMissionScriptElement")

ElementUnloadStatic = ElementUnloadStatic or class(CoreMissionScriptElement.MissionScriptElement)

function ElementUnloadStatic:init(...)
	ElementUnloadStatic.super.init(self, ...)
end

function ElementUnloadStatic:client_on_executed(...)
	self:on_executed(...)
end

function ElementUnloadStatic:_get_unit(unit_id)
	if Application:editor() then
		return managers.editor:unit_with_id(unit_id)
	else
		return managers.worlddefinition:get_unit(unit_id)
	end
end

function ElementUnloadStatic:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not Application:editor() then
		for _, unit_id in ipairs(self._values.unit_ids) do
			local unit = self:_get_unit(unit_id)

			if alive(unit) then
				print("[Mission] unload unit ", unit_id, unit)
				World:delete_unit_free_assets(unit)
			end
		end
	end

	ElementUnloadStatic.super.on_executed(self, instigator)
end
