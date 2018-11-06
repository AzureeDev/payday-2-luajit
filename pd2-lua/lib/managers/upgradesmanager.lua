UpgradesManager = UpgradesManager or class()
UpgradesManager.AQUIRE_STRINGS = {
	"Default",
	"SkillTree",
	"SpecializationTree",
	"LevelTree",
	"DLC"
}

function UpgradesManager:init()
	self:_setup()
end

function UpgradesManager:_setup()
	if not Global.upgrades_manager then
		Global.upgrades_manager = {
			aquired = {},
			automanage = false,
			progress = {
				0,
				0,
				0,
				0
			},
			target_tree = self:_autochange_tree(),
			disabled_visual_upgrades = {}
		}
	end

	self._global = Global.upgrades_manager
end

function UpgradesManager:setup_current_weapon()
end

function UpgradesManager:visual_weapon_upgrade_active(upgrade)
	return not self._global.disabled_visual_upgrades[upgrade]
end

function UpgradesManager:toggle_visual_weapon_upgrade(upgrade)
	if self._global.disabled_visual_upgrades[upgrade] then
		self._global.disabled_visual_upgrades[upgrade] = nil
	else
		self._global.disabled_visual_upgrades[upgrade] = true
	end
end

function UpgradesManager:set_target_tree(tree)
	local level = managers.experience:current_level()
	local step = self._global.progress[tree]
	local cap = tweak_data.upgrades.tree_caps[self._global.progress[tree] + 1]

	if cap and level < cap then
		return
	end

	self:_set_target_tree(tree)
end

function UpgradesManager:_set_target_tree(tree)
	local i = self._global.progress[tree] + 1
	local upgrade = tweak_data.upgrades.definitions[tweak_data.upgrades.progress[tree][i]]
	self._global.target_tree = tree
end

function UpgradesManager:current_tree_name()
	return self:tree_name(self._global.target_tree)
end

function UpgradesManager:tree_name(tree)
	return managers.localization:text(tweak_data.upgrades.trees[tree].name_id)
end

function UpgradesManager:tree_allowed(tree, level)
	level = level or managers.experience:current_level()
	local cap = tweak_data.upgrades.tree_caps[self._global.progress[tree] + 1]

	return not cap or level >= cap, cap
end

function UpgradesManager:current_tree()
	return self._global.target_tree
end

function UpgradesManager:next_upgrade(tree)
end

function UpgradesManager:level_up()
	local level = managers.experience:current_level()

	print("UpgradesManager:level_up()", level)
	self:aquire_from_level_tree(level, false)
end

function UpgradesManager:aquire_from_level_tree(level, loading)
	local tree_data = tweak_data.upgrades.level_tree[level]

	if not tree_data then
		return
	end

	local identifier = UpgradesManager.AQUIRE_STRINGS[4] .. tostring(level)

	for _, upgrade in ipairs(tree_data.upgrades) do
		if not self:aquired(upgrade, identifier) then
			self:aquire(upgrade, loading, identifier)
		end
	end
end

function UpgradesManager:verify_level_tree(level, loading)
	local tree_data = tweak_data.upgrades.level_tree[level]

	if not tree_data then
		return
	end

	local identifier = UpgradesManager.AQUIRE_STRINGS[4] .. tostring(level)
	local upgrade = nil

	for _, id in ipairs(tree_data.upgrades) do
		upgrade = tweak_data.upgrades.definitions[id]

		if upgrade and upgrade.dlc and not managers.dlc:is_dlc_unlocked(upgrade.dlc) and self:aquired(id, identifier) then
			self:unaquire(id, identifier)
		end
	end
end

function UpgradesManager:_next_tree()
	local tree = nil

	if self._global.automanage then
		tree = self:_autochange_tree()
	end

	local level = managers.experience:current_level() + 1
	local cap = tweak_data.upgrades.tree_caps[self._global.progress[self._global.target_tree] + 1]

	if cap and level < cap then
		tree = self:_autochange_tree(self._global.target_tree)
	end

	return tree or self._global.target_tree
end

function UpgradesManager:num_trees()
	return managers.dlc:is_dlc_unlocked("preorder") and 4 or 3
end

function UpgradesManager:_autochange_tree(exlude_tree)
	local progress = clone(Global.upgrades_manager.progress)

	if exlude_tree then
		progress[exlude_tree] = nil
	end

	if not managers.dlc:is_dlc_unlocked("preorder") then
		progress[4] = nil
	end

	local n_tree = 0
	local n_v = 100

	for tree, v in pairs(progress) do
		if v < n_v then
			n_tree = tree
			n_v = v
		end
	end

	return n_tree
end

function UpgradesManager:aquired(id, identifier)
	if identifier then
		local identify_key = Idstring(identifier):key()

		return self._global.aquired[id] and not not self._global.aquired[id][identify_key]
	else
		local count = 0

		for key, aquired in pairs(self._global.aquired[id] or {}) do
			if aquired then
				count = count + 1
			end
		end

		return count > 0
	end
end

function UpgradesManager:aquire_default(id, identifier)
	if not tweak_data.upgrades.definitions[id] then
		Application:error("Tried to aquire an upgrade that doesn't exist: " .. (id or "nil") .. "")

		return
	end

	local upgrade = tweak_data.upgrades.definitions[id]

	if upgrade.dlc and not managers.dlc:is_dlc_unlocked(upgrade.dlc) then
		Application:error("Tried to aquire an upgrade locked to a dlc you do not have: " .. id .. " DLC: ", upgrade.dlc)

		return
	end

	if not identifier then
		debug_pause(identifier, "[UpgradesManager:aquire_default] No identifier for upgrade aquire", "id", id)

		identifier = UpgradesManager.AQUIRE_STRINGS[1]
	end

	local identify_key = Idstring(identifier):key()

	if self._global.aquired[id] and self._global.aquired[id][identify_key] then
		Application:error("Tried to aquire an upgrade that has already been aquired: " .. id, "identifier", identifier, "id_key", identify_key)
		Application:stack_dump()

		return
	end

	self._global.aquired[id] = self._global.aquired[id] or {}
	self._global.aquired[id][identify_key] = identifier
	local upgrade = tweak_data.upgrades.definitions[id]

	self:_aquire_upgrade(upgrade, id, true)
end

function UpgradesManager:enable_weapon(id, identifier)
	if not tweak_data.upgrades.definitions[id] then
		Application:error("Tried to aquire an upgrade that doesn't exist: " .. (id or "nil") .. "")

		return
	end

	local upgrade = tweak_data.upgrades.definitions[id]

	if upgrade.dlc and not managers.dlc:is_dlc_unlocked(upgrade.dlc) then
		Application:error("Tried to aquire an upgrade locked to a dlc you do not have: " .. id .. " DLC: ", upgrade.dlc)

		return
	end

	if not identifier then
		debug_pause(identifier, "[UpgradesManager:aquire_default] No identifier for upgrade aquire", "id", id)

		identifier = UpgradesManager.AQUIRE_STRINGS[1]
	end

	local identify_key = Idstring(identifier):key()

	if self._global.aquired[id] and self._global.aquired[id][identify_key] then
		Application:error("Tried to aquire an upgrade that has already been aquired: " .. id, "identifier", identifier, "id_key", identify_key)
		Application:stack_dump()

		return
	end

	self._global.aquired[id] = self._global.aquired[id] or {}
	self._global.aquired[id][identify_key] = identifier

	managers.player:aquire_weapon(upgrade, id, UpgradesManager.AQUIRE_STRINGS[1])
end

function UpgradesManager:aquire(id, loading, identifier)
	if not tweak_data.upgrades.definitions[id] then
		Application:error("Tried to aquire an upgrade that doesn't exist: " .. (id or "nil") .. "")

		return
	end

	local upgrade = tweak_data.upgrades.definitions[id]

	if upgrade.dlc and not managers.dlc:is_dlc_unlocked(upgrade.dlc) then
		Application:error("Tried to aquire an upgrade locked to a dlc you do not have: " .. id .. " DLC: ", upgrade.dlc)

		return
	end

	if not identifier then
		debug_pause(identifier, "[UpgradesManager:aquire] No identifier for upgrade aquire", "id", id, "loading", loading)

		identifier = UpgradesManager.AQUIRE_STRINGS[1]
	end

	local identify_key = Idstring(identifier):key()

	if self._global.aquired[id] and self._global.aquired[id][identify_key] then
		Application:error("Tried to aquire an upgrade that has already been aquired: " .. id, "identifier", identifier, "id_key", identify_key)
		Application:stack_dump()

		return
	end

	self._global.aquired[id] = self._global.aquired[id] or {}
	self._global.aquired[id][identify_key] = identifier

	self:_aquire_upgrade(upgrade, id, loading)
	self:setup_current_weapon()
end

function UpgradesManager:unaquire(id, identifier)
	if not tweak_data.upgrades.definitions[id] then
		Application:error("Tried to unaquire an upgrade that doesn't exist: " .. (id or "nil") .. "")

		return
	end

	if not identifier then
		debug_pause(identifier, "[UpgradesManager:unaquire] No identifier for upgrade aquire", "id", id)

		identifier = UpgradesManager.AQUIRE_STRINGS[1]
	end

	local identify_key = Idstring(identifier):key()

	if not self._global.aquired[id] or not self._global.aquired[id][identify_key] then
		Application:error("Tried to unaquire an upgrade that hasn't benn aquired: " .. id, "identifier", identifier)

		return
	end

	self._global.aquired[id][identify_key] = nil
	local count = 0

	for key, aquired in pairs(self._global.aquired[id]) do
		count = count + 1
	end

	if count == 0 then
		self._global.aquired[id] = nil
		local upgrade = tweak_data.upgrades.definitions[id]

		self:_unaquire_upgrade(upgrade, id)
	end
end

function UpgradesManager:_aquire_upgrade(upgrade, id, loading)
	if upgrade.category == "weapon" then
		self:_aquire_weapon(upgrade, id, loading)
	elseif upgrade.category == "feature" then
		self:_aquire_feature(upgrade, id, loading)
	elseif upgrade.category == "equipment" then
		self:_aquire_equipment(upgrade, id, loading)
	elseif upgrade.category == "equipment_upgrade" then
		self:_aquire_equipment_upgrade(upgrade, id, loading)
	elseif upgrade.category == "temporary" then
		self:_aquire_temporary(upgrade, id, loading)
	elseif upgrade.category == "cooldown" then
		self:_aquire_cooldown(upgrade, id, loading)
	elseif upgrade.category == "team" then
		self:_aquire_team(upgrade, id, loading)
	elseif upgrade.category == "armor" then
		self:_aquire_armor(upgrade, id, loading)
	elseif upgrade.category == "rep_upgrade" then
		self:_aquire_rep_upgrade(upgrade, id, loading)
	elseif upgrade.category == "melee_weapon" then
		self:_aquire_melee_weapon(upgrade, id, loading)
	elseif upgrade.category == "grenade" then
		self:_aquire_grenade(upgrade, id, loading)
	end
end

function UpgradesManager:_unaquire_upgrade(upgrade, id)
	if upgrade.category == "weapon" then
		self:_unaquire_weapon(upgrade, id)
	elseif upgrade.category == "feature" then
		self:_unaquire_feature(upgrade, id)
	elseif upgrade.category == "equipment" then
		self:_unaquire_equipment(upgrade, id)
	elseif upgrade.category == "equipment_upgrade" then
		self:_unaquire_equipment_upgrade(upgrade, id)
	elseif upgrade.category == "temporary" then
		self:_unaquire_temporary(upgrade, id)
	elseif upgrade.category == "cooldown" then
		self:_unaquire_cooldown(upgrade, id)
	elseif upgrade.category == "team" then
		self:_unaquire_team(upgrade, id)
	elseif upgrade.category == "armor" then
		self:_unaquire_armor(upgrade, id)
	elseif upgrade.category == "melee_weapon" then
		self:_unaquire_melee_weapon(upgrade, id)
	elseif upgrade.category == "grenade" then
		self:_unaquire_grenade(upgrade, id)
	end
end

function UpgradesManager:_aquire_weapon(upgrade, id, loading)
	managers.player:aquire_weapon(upgrade, id)
	managers.blackmarket:on_aquired_weapon_platform(upgrade, id, loading)
end

function UpgradesManager:_unaquire_weapon(upgrade, id)
	managers.player:unaquire_weapon(upgrade, id)
	managers.blackmarket:on_unaquired_weapon_platform(upgrade, id)
end

function UpgradesManager:_aquire_melee_weapon(upgrade, id, loading)
	managers.player:aquire_melee_weapon(upgrade, id)
	managers.blackmarket:on_aquired_melee_weapon(upgrade, id, loading)
end

function UpgradesManager:_unaquire_melee_weapon(upgrade, id)
	managers.player:unaquire_melee_weapon(upgrade, id)
	managers.blackmarket:on_unaquired_melee_weapon(upgrade, id)
end

function UpgradesManager:_aquire_grenade(upgrade, id, loading)
	managers.player:aquire_grenade(upgrade, id)
	managers.blackmarket:on_aquired_grenade(upgrade, id, loading)
end

function UpgradesManager:_unaquire_grenade(upgrade, id)
	managers.player:unaquire_grenade(upgrade, id)
	managers.blackmarket:on_unaquired_grenade(upgrade, id)
end

function UpgradesManager:_aquire_feature(feature)
	if feature.incremental then
		managers.player:aquire_incremental_upgrade(feature.upgrade)
	else
		managers.player:aquire_upgrade(feature.upgrade)
	end
end

function UpgradesManager:_unaquire_feature(feature)
	if feature.incremental then
		managers.player:unaquire_incremental_upgrade(feature.upgrade)
	else
		managers.player:unaquire_upgrade(feature.upgrade)
	end
end

function UpgradesManager:_aquire_equipment(equipment, id, loading)
	managers.player:aquire_equipment(equipment, id, loading)
end

function UpgradesManager:_unaquire_equipment(equipment, id)
	managers.player:unaquire_equipment(equipment, id)
end

function UpgradesManager:_aquire_equipment_upgrade(equipment_upgrade)
	if equipment_upgrade.incremental then
		managers.player:aquire_incremental_upgrade(equipment_upgrade.upgrade)
	else
		managers.player:aquire_upgrade(equipment_upgrade.upgrade)
	end
end

function UpgradesManager:_unaquire_equipment_upgrade(equipment_upgrade)
	if equipment_upgrade.incremental then
		managers.player:unaquire_incremental_upgrade(equipment_upgrade.upgrade)
	else
		managers.player:unaquire_upgrade(equipment_upgrade.upgrade)
	end
end

function UpgradesManager:_aquire_temporary(temporary, id)
	if temporary.incremental then
		managers.player:aquire_incremental_upgrade(temporary.upgrade)
	else
		managers.player:aquire_upgrade(temporary.upgrade, id)
	end
end

function UpgradesManager:_unaquire_temporary(temporary, id)
	if temporary.incremental then
		managers.player:unaquire_incremental_upgrade(temporary.upgrade)
	else
		managers.player:unaquire_upgrade(temporary.upgrade)
	end
end

function UpgradesManager:_aquire_cooldown(cooldown, id)
	managers.player:aquire_cooldown_upgrade(cooldown.upgrade, id)
end

function UpgradesManager:_unaquire_cooldown(cooldown, id)
	managers.player:unaquire_cooldown_upgrade(cooldown.upgrade)
end

function UpgradesManager:_aquire_team(team, id)
	managers.player:aquire_team_upgrade(team.upgrade, id)
end

function UpgradesManager:_unaquire_team(team, id)
	managers.player:unaquire_team_upgrade(team.upgrade, id)
end

function UpgradesManager:_aquire_armor(upgrade, id, loading)
	managers.blackmarket:on_aquired_armor(upgrade, id, loading)
end

function UpgradesManager:_unaquire_armor(upgrade, id)
	managers.blackmarket:on_unaquired_armor(upgrade, id)
end

function UpgradesManager:_aquire_rep_upgrade(upgrade, id)
	managers.skilltree:rep_upgrade(upgrade, id)
end

function UpgradesManager:get_value(upgrade_id, ...)
	local upgrade = tweak_data.upgrades.definitions[upgrade_id]

	if not upgrade then
		Application:error("[UpgradesManager:get_value] Missing Upgrade ID: ", upgrade_id)
	end

	local u = upgrade.upgrade

	if upgrade.category == "feature" then
		return tweak_data.upgrades.values[u.category][u.upgrade][u.value]
	elseif upgrade.category == "equipment" then
		return upgrade.equipment_id
	elseif upgrade.category == "equipment_upgrade" then
		return tweak_data.upgrades.values[u.category][u.upgrade][u.value]
	elseif upgrade.category == "temporary" then
		local temporary = tweak_data.upgrades.values[u.category][u.upgrade][u.value]

		return "Value: " .. tostring(temporary[1]) .. " Time: " .. temporary[2]
	elseif upgrade.category == "cooldown" then
		local cooldown = tweak_data.upgrades.values[u.category][u.upgrade][u.value]

		return "Value: " .. tostring(cooldown[1]) .. " Time: " .. cooldown[2]
	elseif upgrade.category == "team" then
		local value = tweak_data.upgrades.values.team[u.category][u.upgrade][u.value]

		return value
	elseif upgrade.category == "weapon" then
		local default_weapons = {
			"glock_17",
			"amcar"
		}
		local weapon_id = upgrade.weapon_id
		local is_default_weapon = table.contains(default_weapons, weapon_id) and true or false
		local weapon_level = 0
		local new_weapon_id = tweak_data.weapon[weapon_id] and tweak_data.weapon[weapon_id].parent_weapon_id or weapon_id

		for level, data in pairs(tweak_data.upgrades.level_tree) do
			local upgrades = data.upgrades

			if upgrades and table.contains(upgrades, new_weapon_id) then
				weapon_level = level

				break
			end
		end

		return is_default_weapon, weapon_level, weapon_id ~= new_weapon_id
	elseif upgrade.category == "melee_weapon" then
		local params = {
			...
		}
		local default_id = params[1] or managers.blackmarket and managers.blackmarket:get_category_default("melee_weapon") or "weapon"
		local melee_weapon_id = upgrade_id
		local is_default_weapon = melee_weapon_id == default_id
		local melee_weapon_level = 0

		for level, data in pairs(tweak_data.upgrades.level_tree) do
			local upgrades = data.upgrades

			if upgrades and table.contains(upgrades, melee_weapon_id) then
				melee_weapon_level = level

				break
			end
		end

		return is_default_weapon, melee_weapon_level
	elseif upgrade.category == "grenade" then
		local params = {
			...
		}
		local default_id = params[1] or managers.blackmarket and managers.blackmarket:get_category_default("grenade") or "weapon"
		local grenade_id = upgrade_id
		local is_default_weapon = grenade_id == default_id
		local grenade_level = 0

		for level, data in pairs(tweak_data.upgrades.level_tree) do
			local upgrades = data.upgrades

			if upgrades and table.contains(upgrades, grenade_id) then
				grenade_level = level

				break
			end
		end

		return is_default_weapon, grenade_level
	end

	print("no value for", upgrade_id, upgrade.category)
end

function UpgradesManager:get_category(upgrade_id)
	local upgrade = tweak_data.upgrades.definitions[upgrade_id]

	return upgrade.category
end

function UpgradesManager:get_upgrade_upgrade(upgrade_id)
	local upgrade = tweak_data.upgrades.definitions[upgrade_id]

	return upgrade.upgrade
end

function UpgradesManager:get_upgrade_locks(upgrade_id)
	local upgrade = tweak_data.upgrades.definitions[upgrade_id]

	return {
		dlc = upgrade.dlc
	}
end

function UpgradesManager:is_upgrade_locked(upgrade_id)
	local locks = self:get_upgrade_locks(upgrade_id)

	for category, id in pairs(locks) do
		if category == "dlc" and not managers.dlc:is_dlc_unlocked(id) then
			return true
		end
	end

	return false
end

function UpgradesManager:is_locked(step)
	local level = managers.experience:current_level()

	for i, d in ipairs(tweak_data.upgrades.itree_caps) do
		if level < d.level then
			return d.step <= step
		end
	end

	return false
end

function UpgradesManager:get_level_from_step(step)
	for i, d in ipairs(tweak_data.upgrades.itree_caps) do
		if step == d.step then
			return d.level
		end
	end

	return 0
end

function UpgradesManager:progress()
	if managers.dlc:is_dlc_unlocked("preorder") then
		return {
			self._global.progress[1],
			self._global.progress[2],
			self._global.progress[3],
			self._global.progress[4]
		}
	end

	return {
		self._global.progress[1],
		self._global.progress[2],
		self._global.progress[3]
	}
end

function UpgradesManager:progress_by_tree(tree)
	return self._global.progress[tree]
end

function UpgradesManager:name(id)
	if not tweak_data.upgrades.definitions[id] then
		Application:error("Tried to get name from an upgrade that doesn't exist: " .. id .. "")

		return
	end

	local upgrade = tweak_data.upgrades.definitions[id]

	return managers.localization:text(upgrade.name_id)
end

function UpgradesManager:title(id)
	if not tweak_data.upgrades.definitions[id] then
		Application:error("Tried to get title from an upgrade that doesn't exist: " .. id .. "")

		return
	end

	local upgrade = tweak_data.upgrades.definitions[id]

	return upgrade.title_id and managers.localization:text(upgrade.title_id) or nil
end

function UpgradesManager:subtitle(id)
	if not tweak_data.upgrades.definitions[id] then
		Application:error("Tried to get subtitle from an upgrade that doesn't exist: " .. id .. "")

		return
	end

	local upgrade = tweak_data.upgrades.definitions[id]

	return upgrade.subtitle_id and managers.localization:text(upgrade.subtitle_id) or nil
end

function UpgradesManager:complete_title(id, type)
	local title = self:title(id)

	if not title then
		return nil
	end

	local subtitle = self:subtitle(id)

	if not subtitle then
		return title
	end

	if type then
		if type == "single" then
			return title .. " " .. subtitle
		else
			return title .. type .. subtitle
		end
	end

	return title .. "\n" .. subtitle
end

function UpgradesManager:description(id)
	if not tweak_data.upgrades.definitions[id] then
		Application:error("Tried to get description from an upgrade that doesn't exist: " .. id .. "")

		return
	end

	local upgrade = tweak_data.upgrades.definitions[id]

	return upgrade.subtitle_id and managers.localization:text(upgrade.description_text_id or id) or nil
end

function UpgradesManager:image(id)
	local image = tweak_data.upgrades.definitions[id].image

	if not image then
		return nil, nil
	end

	return tweak_data.hud_icons:get_icon_data(image)
end

function UpgradesManager:image_slice(id)
	local image_slice = tweak_data.upgrades.definitions[id].image_slice

	if not image_slice then
		return nil, nil
	end

	return tweak_data.hud_icons:get_icon_data(image_slice)
end

function UpgradesManager:icon(id)
	if not tweak_data.upgrades.definitions[id] then
		Application:error("Tried to aquire an upgrade that doesn't exist: " .. id .. "")

		return
	end

	return tweak_data.upgrades.definitions[id].icon
end

function UpgradesManager:aquired_by_category(category)
	local t = {}

	for name, _ in pairs(self._global.aquired) do
		if tweak_data.upgrades.definitions[name].category == category and self:aquired(name) then
			table.insert(t, name)
		end
	end

	return t
end

function UpgradesManager:aquired_features()
	return self:aquired_by_category("feature")
end

function UpgradesManager:aquired_weapons()
	return self:aquired_by_category("weapon")
end

function UpgradesManager:list_level_rewards(dlcs)
	local t = {}
	local tree_data = tweak_data.upgrades.level_tree
	local def = nil

	for level, data in pairs(tree_data) do
		if data.upgrades then
			for _, upgrade in ipairs(data.upgrades) do
				def = tweak_data.upgrades.definitions[upgrade]

				if def and (not dlcs or def.dlc) and (not dlcs or dlcs == true and def.dlc or dlcs[def.dlc] or table.contains(dlcs, def.dlc)) then
					table.insert(t, {
						upgrade,
						level,
						def.dlc
					})
				end
			end
		end
	end

	return t
end

function UpgradesManager:all_weapon_upgrades()
	for id, data in pairs(tweak_data.upgrades.definitions) do
		if data.category == "weapon" then
			print(id)
		end
	end
end

function UpgradesManager:weapon_upgrade_by_weapon_id(weapon_id)
	for id, data in pairs(tweak_data.upgrades.definitions) do
		if data.category == "weapon" and data.weapon_id == weapon_id then
			return data
		end
	end
end

function UpgradesManager:weapon_upgrade_by_factory_id(factory_id)
	for id, data in pairs(tweak_data.upgrades.definitions) do
		if data.category == "weapon" and data.factory_id == factory_id then
			return data
		end
	end
end

function UpgradesManager:print_aquired_tree()
	local tree = {}

	for name, data in pairs(self._global.aquired) do
		tree[data.level] = {
			name = name
		}
	end

	for i, data in pairs(tree) do
		print(self:name(data.name))
	end
end

function UpgradesManager:analyze()
	local not_placed = {}
	local placed = {}
	local features = {}
	local amount = 0

	for lvl, upgrades in pairs(tweak_data.upgrades.levels) do
		print("Upgrades at level " .. lvl .. ":")

		for _, upgrade in ipairs(upgrades) do
			print("\t" .. upgrade)
		end
	end

	for name, data in pairs(tweak_data.upgrades.definitions) do
		amount = amount + 1

		for lvl, upgrades in pairs(tweak_data.upgrades.levels) do
			for _, upgrade in ipairs(upgrades) do
				if upgrade == name then
					if placed[name] then
						print("ERROR: Upgrade " .. name .. " is already placed in level " .. placed[name] .. "!")
					else
						placed[name] = lvl
					end

					if data.category == "feature" then
						features[data.upgrade.category] = features[data.upgrade.category] or {}

						table.insert(features[data.upgrade.category], {
							level = lvl,
							name = name
						})
					end
				end
			end
		end

		if not placed[name] then
			not_placed[name] = true
		end
	end

	for name, lvl in pairs(placed) do
		print("Upgrade " .. name .. " is placed in level\t\t " .. lvl .. ".")
	end

	for name, _ in pairs(not_placed) do
		print("Upgrade " .. name .. " is not placed any level!")
	end

	print("")

	for category, upgrades in pairs(features) do
		print("Upgrades for category " .. category .. " is recieved at:")

		for _, upgrade in ipairs(upgrades) do
			print("  Level: " .. upgrade.level .. ", " .. upgrade.name .. "")
		end
	end

	print("\nTotal upgrades " .. amount .. ".")
end

function UpgradesManager:tree_stats()
	local t = {
		{
			a = 0,
			u = {}
		},
		{
			a = 0,
			u = {}
		},
		{
			a = 0,
			u = {}
		}
	}

	for name, d in pairs(tweak_data.upgrades.definitions) do
		if d.tree then
			t[d.tree].a = t[d.tree].a + 1

			table.insert(t[d.tree].u, name)
		end
	end

	for i, d in ipairs(t) do
		print(inspect(d.u))
		print(d.a)
	end
end

function UpgradesManager:save(data)
	local state = {
		automanage = self._global.automanage,
		progress = self._global.progress,
		target_tree = self._global.target_tree,
		disabled_visual_upgrades = self._global.disabled_visual_upgrades
	}

	if self._global.incompatible_data_loaded and self._global.incompatible_data_loaded.progress then
		state.progress = clone(self._global.progress)

		for i, k in pairs(self._global.incompatible_data_loaded.progress) do
			print("saving incompatible data", i, k)

			state.progress[i] = math.max(state.progress[i], k)
		end
	end

	data.UpgradesManager = state
end

function UpgradesManager:load(data)
	local state = data.UpgradesManager
	self._global.automanage = state.automanage
	self._global.progress = state.progress
	self._global.target_tree = state.target_tree
	self._global.disabled_visual_upgrades = state.disabled_visual_upgrades

	self:_verify_loaded_data()
end

function UpgradesManager:_verify_loaded_data()
end

function UpgradesManager:reset()
	Global.upgrades_manager = nil

	self:_setup()
end
