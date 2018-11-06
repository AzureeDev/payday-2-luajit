core:import("CoreMissionScriptElement")

ElementInstigatorRule = ElementInstigatorRule or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInstigatorRule:init(...)
	ElementInstigatorRule.super.init(self, ...)

	for instigator_type, rules in pairs(self._values.rules) do
		for rule, data in pairs(rules) do
			local restructured_data = {}

			for _, value in ipairs(data) do
				if rule == "enemy_names" or rule == "civilian_names" or rule == "vehicle_names" then
					restructured_data[Idstring(value):key()] = true
				else
					restructured_data[value] = true
				end
			end

			rules[rule] = restructured_data
		end
	end
end

function ElementInstigatorRule:on_script_activated(...)
	ElementInstigatorRule.super.on_script_activated(self, ...)
	self._mission_script:add_save_state_cb(self._id)
end

function ElementInstigatorRule:client_on_executed(...)
	self:on_executed(...)
end

function ElementInstigatorRule:check_rules(instigator_type, instigator)
	if not self._values.enabled then
		return true
	end

	local rules = self._values.rules[instigator_type]

	if not rules then
		return true
	end

	if not next(rules) then
		return true
	end

	local check_result = true

	if instigator_type == "player" then
		check_result = self:_check_player_rules(rules, instigator)
	elseif instigator_type == "enemies" then
		check_result = self:_check_enemies_rules(rules, instigator)
	elseif instigator_type == "civilians" then
		check_result = self:_check_civilians_rules(rules, instigator)
	elseif instigator_type == "loot" then
		check_result = self:_check_loot_rules(rules, instigator)
	elseif instigator_type == "vehicle" then
		check_result = self:_check_vehicle_rules(rules, instigator)
	end

	if self._values.invert then
		check_result = not check_result
	end

	return check_result
end

function ElementInstigatorRule:_check_player_rules(rules, instigator)
	for rule, data in pairs(rules) do
		if rule == "carry_ids" then
			local current_carry_id = managers.player:current_carry_id()

			if not data[current_carry_id] then
				return false
			end
		end

		if rule == "states" then
			local current_state = managers.player:current_state()

			if not data[current_state] then
				return false
			end
		end

		if rule == "mission_equipment" then
			for value, _ in pairs(data) do
				if not managers.player:has_special_equipment(value) then
					return false
				end
			end
		end
	end

	return true
end

function ElementInstigatorRule:_check_enemies_rules(rules, instigator)
	for rule, data in pairs(rules) do
		if rule == "enemy_names" and not data[instigator:name():key()] then
			return false
		end

		if rule == "pickup" and not data[instigator:character_damage():pickup()] then
			return false
		end
	end

	return true
end

function ElementInstigatorRule:_check_civilians_rules(rules, instigator)
	for rule, data in pairs(rules) do
		if rule == "civilian_names" and not data[instigator:name():key()] then
			return false
		end

		if rule == "pickup" and not data[instigator:character_damage():pickup()] then
			return false
		end
	end

	return true
end

function ElementInstigatorRule:_check_loot_rules(rules, instigator)
	for rule, data in pairs(rules) do
		if rule == "carry_ids" and not data[instigator:carry_data():carry_id()] then
			return false
		end
	end

	return true
end

function ElementInstigatorRule:_check_vehicle_rules(rules, instigator)
	for rule, data in pairs(rules) do
		if rule == "vehicle_names" and not data[instigator:name():key()] then
			return false
		end
	end

	return true
end

function ElementInstigatorRule:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementInstigatorRule.super.on_executed(self, instigator)
end

function ElementInstigatorRule:save(data)
	data.enabled = self._values.enabled
end

function ElementInstigatorRule:load(data)
	self:set_enabled(data.enabled)
end
