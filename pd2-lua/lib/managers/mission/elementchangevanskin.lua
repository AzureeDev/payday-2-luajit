core:import("CoreMissionScriptElement")

ElementChangeVanSkin = ElementChangeVanSkin or class(CoreMissionScriptElement.MissionScriptElement)

function ElementChangeVanSkin:init(...)
	ElementChangeVanSkin.super.init(self, ...)

	self._units = {}
end

function ElementChangeVanSkin:on_script_activated()
	local elementBroken = false

	for _, id in ipairs(self._values.unit_ids) do
		if Global.running_simulation then
			if not managers.editor:unit_with_id(id) then
				print("MISSING UNIT WITH ID:", id)

				elementBroken = true
			else
				table.insert(self._units, managers.editor:unit_with_id(id))
			end
		else
			local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "_load_unit"))

			if unit then
				table.insert(self._units, unit)
			end
		end
	end

	if elementBroken then
		for _, id in ipairs(self._values.unit_ids) do
			if managers.editor:unit_with_id(id) then
				print(inspect(managers.editor:unit_with_id(id)))
			end
		end
	end

	self._has_fetched_units = true

	self._mission_script:add_save_state_cb(self._id)
end

function ElementChangeVanSkin:_load_unit(unit)
	table.insert(self._units, unit)
end

function ElementChangeVanSkin:on_executed(instigator)
	if not self._values.enabled or not self._values.target_skin then
		return
	end

	local van_data = tweak_data.van.skins[self._values.target_skin]

	if Network:is_server() and van_data.dlc and not managers.dlc:is_dlc_unlocked(van_data.dlc) then
		return
	end

	if Network:is_server() then
		managers.blackmarket:equip_van_skin(self._values.target_skin)
	end

	for i, unit in pairs(self._units) do
		if unit:damage() and unit:damage():has_sequence(van_data.sequence_name) then
			unit:damage():run_sequence_simple(van_data.sequence_name)
		end
	end

	ElementChangeVanSkin.super.on_executed(self, instigator)
end

function ElementChangeVanSkin:client_on_executed(...)
	self:on_executed(...)
end

function ElementChangeVanSkin:save(data)
	data.enabled = self._values.enabled
end

function ElementChangeVanSkin:load(data)
	if not self._has_fetched_units and managers.blackmarket:equipped_van_skin() == self._values.target_skin then
		self:on_script_activated()
	end

	self:set_enabled(data.enabled)
end
