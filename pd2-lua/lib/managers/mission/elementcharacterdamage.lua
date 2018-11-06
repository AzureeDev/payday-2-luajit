core:import("CoreMissionScriptElement")

ElementCharacterDamage = ElementCharacterDamage or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCharacterDamage:init(...)
	ElementCharacterDamage.super.init(self, ...)

	self._units = {}
	local dmg_filter = self:value("damage_types")

	if dmg_filter and dmg_filter ~= "" then
		self._allow_damage_types = {}
		local dmgs = string.split(dmg_filter, " ")

		for _, dmg_type in ipairs(dmgs) do
			table.insert(self._allow_damage_types, dmg_type)
		end
	end
end

function ElementCharacterDamage:destroy()
end

function ElementCharacterDamage:on_created()
end

function ElementCharacterDamage:on_script_activated()
	for _, id in ipairs(self:value("elements")) do
		local element = self:get_mission_element(id)

		if element.add_event_callback then
			element:add_event_callback("spawn", callback(self, self, "unit_spawned"))
		end
	end
end

function ElementCharacterDamage:unit_spawned(unit)
	if alive(unit) and unit:character_damage() then
		unit:character_damage():add_listener("character_damage_" .. tostring(unit:key()), nil, callback(self, self, "clbk_linked_unit_took_damage"))
	end
end

function ElementCharacterDamage:clbk_linked_unit_took_damage(unit, damage_info)
	if not alive(unit) then
		return
	end

	local damage = damage_info.damage

	if self:value("percentage") then
		damage = damage / unit:character_damage()._HEALTH_INIT * 100
	end

	self:on_executed(damage_info.attacker_unit, damage, damage_info.variant)
end

function ElementCharacterDamage:on_executed(instigator, damage, damage_type)
	if not self._values.enabled then
		return
	end

	local allow = true

	if self._allow_damage_types and not table.contains(self._allow_damage_types, damage_type) then
		allow = false
	end

	if allow then
		damage = math.floor(damage * tweak_data.gui.stats_present_multiplier)

		self:override_value_on_element_type("ElementCounterOperator", "amount", damage)
		ElementCharacterDamage.super.on_executed(self, instigator)
	end
end

function ElementCharacterDamage:save(data)
	data.enabled = self._values.enabled
end

function ElementCharacterDamage:load(data)
	self:set_enabled(data.enabled)
end
