core:import("CoreMissionScriptElement")

ElementObjective = ElementObjective or class(CoreMissionScriptElement.MissionScriptElement)

function ElementObjective:init(...)
	ElementObjective.super.init(self, ...)
end

function ElementObjective:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

function ElementObjective:client_on_executed(...)
	self:on_executed(...)
end

function ElementObjective:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local objective = self:value("objective")
	local amount = self:value("amount")
	amount = amount and amount > 0 and amount or nil

	if objective ~= "none" then
		if self._values.state == "activate" then
			if self._values.countdown then
				managers.objectives:activate_objective_countdown(objective, nil, {
					amount = amount
				})
			else
				managers.objectives:activate_objective(objective, nil, {
					amount = amount
				})
			end
		elseif self._values.state == "complete_and_activate" then
			managers.objectives:complete_and_activate_objective(objective, nil, {
				amount = amount
			})
		elseif self._values.state == "complete" then
			if self._values.sub_objective and self._values.sub_objective ~= "none" then
				managers.objectives:complete_sub_objective(objective, self._values.sub_objective)
			elseif self._values.countdown then
				managers.objectives:complete_objective_countdown(objective)
			else
				managers.objectives:complete_objective(objective)
			end
		elseif self._values.state == "update" then
			managers.objectives:update_objective(objective)
		elseif self._values.state == "remove" then
			managers.objectives:remove_objective(objective)
		elseif self._values.state == "remove_and_activate" then
			managers.objectives:remove_and_activate_objective(objective, nil, {
				amount = amount
			})
		end
	elseif Application:editor() then
		managers.editor:output_error("Cant operate on objective " .. objective .. " in element " .. self._editor_name .. ".")
	end

	ElementObjective.super.on_executed(self, instigator)
end

function ElementObjective:apply_job_value(amount)
	local type = CoreClass.type_name(amount)

	if type ~= "number" then
		Application:error("[ElementObjective:apply_job_value] " .. self._id .. "(" .. self._editor_name .. ") Can't apply job value of type " .. type)

		return
	end

	self._values.amount = amount
end

function ElementObjective:save(data)
	data.enabled = self._values.enabled
end

function ElementObjective:load(data)
	self:set_enabled(data.enabled)
end
