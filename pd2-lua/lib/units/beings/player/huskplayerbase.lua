require("lib/units/enemies/cop/CopBase")

HuskPlayerBase = HuskPlayerBase or class(PlayerBase)
HuskPlayerBase.set_anim_lod = CopBase.set_anim_lod
HuskPlayerBase.set_visibility_state = CopBase.set_visibility_state
HuskPlayerBase._anim_lods = CopBase._anim_lods

function HuskPlayerBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	self._upgrades = {}
	self._upgrade_levels = {}
	self._temporary_upgrades = {}
	self._temporary_upgrades_map = {}

	self:_setup_suspicion_and_detection_data()
end

function HuskPlayerBase:post_init()
	self._ext_anim = self._unit:anim_data()

	self._unit:movement():post_init()
	managers.groupai:state():register_criminal(self._unit)
	managers.occlusion:remove_occlusion(self._unit)
	self:set_anim_lod(1)

	self._lod_stage = 1
	self._allow_invisible = true
	local spawn_state = self._spawn_state or "std/stand/still/idle/look"

	self._unit:movement():play_state(spawn_state)
end

function HuskPlayerBase:load(data)
	self._concealment_modifier = data.concealment_modifier

	if data.upgrades then
		for category, upgrades in pairs(data.upgrades) do
			for upgrade, level in pairs(upgrades) do
				self:set_upgrade_value(category, upgrade, level)
			end
		end
	end

	if data.temporary_upgrades then
		for category, temporary_upgrades in pairs(data.temporary_upgrades) do
			for upgrade, upgrade_data in pairs(temporary_upgrades) do
				self:set_temporary_upgrade_owned(category, upgrade, upgrade_data.level, upgrade_data.index)
			end
		end
	end

	self._concealment_modifier = nil
end

function HuskPlayerBase:save(data)
	data.upgrades = {}
	data.temporary_upgrades = {}

	for category, upgrades in pairs(self._upgrade_levels) do
		for upgrade, level in pairs(upgrades) do
			data.upgrades[category] = data.upgrades[category] or {}
			data.upgrades[category][upgrade] = level
		end
	end

	for category, upgrades in pairs(self._temporary_upgrades_map) do
		for upgrade, index in pairs(upgrades) do
			data.temporary_upgrades[category] = data.temporary_upgrades[category] or {}
			local level = self._temporary_upgrades[index] and self._temporary_upgrades[index].level or 1
			data.temporary_upgrades[category][upgrade] = {
				index = index,
				level = level
			}
		end
	end

	data.concealment_modifier = managers.blackmarket:get_concealment_of_peer(managers.network:session():peer_by_unit(self._unit))
end

function HuskPlayerBase:set_upgrade_value(category, upgrade, level)
	self._upgrades[category] = self._upgrades[category] or {}
	self._upgrade_levels[category] = self._upgrade_levels[category] or {}
	local value = managers.player:upgrade_value_by_level(category, upgrade, level)
	self._upgrades[category][upgrade] = value
	self._upgrade_levels[category][upgrade] = level

	if upgrade == "passive_concealment_modifier" then
		local peer = managers.network:session():peer_by_unit(self._unit)
		local con_mul = self._concealment_modifier

		if peer then
			con_mul = managers.blackmarket:get_concealment_of_peer(peer)
		end

		self:set_suspicion_multiplier("equipment", 1 / con_mul)
		self:set_detection_multiplier("equipment", 1 / con_mul)
	elseif upgrade == "suspicion_multiplier" then
		self:set_suspicion_multiplier(upgrade, value)
	end
end

function HuskPlayerBase:update_concealment()
	local con_mul, index = managers.blackmarket:get_concealment_of_peer(managers.network:session():peer_by_unit(self._unit))

	self:set_suspicion_multiplier("equipment", 1 / con_mul)
	self:set_detection_multiplier("equipment", 1 / con_mul)
end

function HuskPlayerBase:set_temporary_upgrade_owned(category, upgrade, level, index)
	local upgrade_values = managers.player:upgrade_value_by_level(category, upgrade, level)

	if type(upgrade_values) ~= "table" then
		Application:error("[HuskPlayerBase:set_temporary_upgrade_owned] invalid upgrade", category, upgrade, level, index)
	end

	self._temporary_upgrades_map[category] = self._temporary_upgrades_map[category] or {}
	self._temporary_upgrades_map[category][upgrade] = index
	self._temporary_upgrades[index] = {
		value = upgrade_values[1],
		time = upgrade_values[2],
		level = level
	}
end

function HuskPlayerBase:activate_temporary_upgrade(index)
	self._temporary_upgrades[index].activation_time = TimerManager:game():time()
end

function HuskPlayerBase:has_activate_temporary_upgrade(category, upgrade)
	local index = self._temporary_upgrades_map[category] and self._temporary_upgrades_map[category][upgrade]

	if index then
		return self._temporary_upgrades[index] and self._temporary_upgrades[index].activation_time and TimerManager:game():time() < self._temporary_upgrades[index].activation_time + self._temporary_upgrades[index].time
	end
end

function HuskPlayerBase:upgrade_value(category, upgrade)
	local val = self._upgrades[category] and self._upgrades[category][upgrade]

	if not val then
		local i = self._temporary_upgrades_map[category] and self._temporary_upgrades_map[category][upgrade]
		local t = i and self._temporary_upgrades[i]

		if t then
			val = {
				t.value,
				t.time
			}
		end
	end

	return val
end

function HuskPlayerBase:upgrade_level(category, upgrade)
	return self._upgrade_levels[category] and self._upgrade_levels[category][upgrade]
end

function HuskPlayerBase:pre_destroy(unit)
	self._unit:movement():pre_destroy(unit)
	self._unit:inventory():pre_destroy(self._unit)
	managers.groupai:state():unregister_criminal(self._unit)

	if managers.network:session() then
		local peer = managers.network:session():peer_by_unit(self._unit)

		if peer then
			peer:set_unit(nil)
		end
	end

	UnitBase.pre_destroy(self, unit)
end

function HuskPlayerBase:nick_name()
	local peer = managers.network:session():peer_by_unit(self._unit)

	return peer and peer:name() or ""
end

function HuskPlayerBase:on_death_exit()
end

function HuskPlayerBase:chk_freeze_anims()
end
