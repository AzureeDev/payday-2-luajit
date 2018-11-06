core:import("CoreMissionScriptElement")

ElementEquipment = ElementEquipment or class(CoreMissionScriptElement.MissionScriptElement)

function ElementEquipment:init(...)
	ElementEquipment.super.init(self, ...)
end

function ElementEquipment:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.equipment ~= "none" then
		if instigator == managers.player:player_unit() then
			managers.player:add_special({
				name = self._values.equipment,
				amount = self._values.amount
			})
		else
			local rpc_params = {
				"give_equipment",
				self._values.equipment,
				self._values.amount,
				false
			}

			instigator:network():send_to_unit(rpc_params)
		end
	elseif Application:editor() then
		managers.editor:output_error("Cant give equipment " .. self._values.equipment .. " in element " .. self._editor_name .. ".")
	end

	ElementEquipment.super.on_executed(self, instigator)
end
