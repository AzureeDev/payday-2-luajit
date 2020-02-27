InventoryDescription = InventoryDescription or class()

function InventoryDescription._find_item_in_content(entry, category, content)
	if category == "drills" or category == "safes" or category == "contents" then
		return false
	end

	local content_data = tweak_data.economy.contents[content]

	if content_data then
		for search_category, search_content in pairs(content_data.contains) do
			if search_category == "contents" then
				for _, search_entry in pairs(search_content) do
					if InventoryDescription._find_item_in_content(entry, category, search_entry) then
						return true
					end
				end
			end

			if search_category == category then
				for _, search_entry in pairs(search_content) do
					if search_entry == entry then
						return true
					end
				end
			end
		end
	end

	return false
end

local function is_weapon_category(weapon_tweak, ...)
	local arg = {
		...
	}
	local categories = weapon_tweak.categories

	for i = 1, #arg, 1 do
		if table.contains(categories, arg[i]) then
			return true
		end
	end

	return false
end

local color_ranges = {}

function InventoryDescription._create_hex_color(color)
	if not color or type(color) == "string" then
		return
	end

	local r, g, b = color:unpack()

	return string.format("%02X", r * 255) .. string.format("%02X", g * 255) .. string.format("%02X", b * 255)
end

function InventoryDescription._add_color_to_text(text, color, ingame_format)
	if ingame_format then
		table.insert(color_ranges, Color(color))

		return "##" .. text .. "##"
	else
		return "[color=#" .. color .. "]" .. text .. "[/color]"
	end
end

function InventoryDescription._add_line_break(ingame_format)
	return ingame_format and "\n" or "\\n"
end

function InventoryDescription._create_list(list, ingame_format)
	local list_text = ""

	table.sort(list)

	for i, text in ipairs(list) do
		list_text = ingame_format and list_text .. (i > 1 and ", " or "") .. text or list_text .. "[*]" .. text
	end

	return ingame_format and list_text or "[list]" .. list_text .. "[/list]"
end

local func_hex_color = InventoryDescription._create_hex_color
local func_color_text = InventoryDescription._add_color_to_text
local func_add_lb = InventoryDescription._add_line_break
local func_create_list = InventoryDescription._create_list

function InventoryDescription.create_description_safe(safe_entry, ingame_format)
	local safe_td = tweak_data.economy.safes[safe_entry]

	if not safe_td then
		return "", {}
	end

	local content_td = tweak_data.economy.contents[safe_td.content]

	if not content_td then
		return "", {}
	end

	local text = ""
	color_ranges = {}
	local items_list = {}

	for category, items in pairs(content_td.contains) do
		for _, item in ipairs(items) do
			items_list[#items_list + 1] = {
				category = category,
				entry = item
			}
		end
	end

	local x_td, y_td, xr_td, yr_td = nil

	local function sort_func(x, y)
		x_td = (tweak_data.economy[x.category] or tweak_data.blackmarket[x.category])[x.entry]
		y_td = (tweak_data.economy[y.category] or tweak_data.blackmarket[y.category])[y.entry]
		xr_td = tweak_data.economy.rarities[x_td.rarity or "common"]
		yr_td = tweak_data.economy.rarities[y_td.rarity or "common"]

		if xr_td.index ~= yr_td.index then
			return xr_td.index < yr_td.index
		end

		return x.entry < y.entry
	end

	table.sort(items_list, sort_func)

	local td = nil

	for i, item in ipairs(items_list) do
		td = (tweak_data.economy[item.category] or tweak_data.blackmarket[item.category])[item.entry]
		local item_text = ""

		if item.category == "contents" and td.rarity == "legendary" then
			item_text = managers.localization:text("bm_menu_rarity_legendary_item_long")
		else
			item_text = (td.weapon_id and utf8.to_upper(managers.weapon_factory:get_weapon_name_by_weapon_id(td.weapon_id)) .. " | " or "") .. managers.localization:text(td.name_id)
		end

		text = text .. func_color_text(item_text, func_hex_color(tweak_data.economy.rarities[td.rarity or "common"].color), ingame_format)

		if i ~= #items_list then
			text = text .. func_add_lb(ingame_format)
		end
	end

	if ingame_format then
		return text, color_ranges
	end

	return text
end

function InventoryDescription.create_description_item(item, tweak, colors, ingame_format)
	local desc = ""
	color_ranges = {}
	local color_default = colors and func_hex_color(colors.default) or "cccccc"
	local color_bonus = colors and func_hex_color(colors.bonus) or "4c4cff"
	local color_collection = colors and func_hex_color(colors.collection) or "ffff00"
	local color_dlc = colors and func_hex_color(colors.dlc) or "cc0000"
	local color_mods_title = colors and func_hex_color(colors.mods_title) or "228B22"
	local color_mods = colors and func_hex_color(colors.mods) or color_mods_title

	if tweak.rarity then
		local rarity_tweak = tweak_data.economy.rarities[tweak.rarity]
		local rarity_title = func_color_text(managers.localization:text("steam_inventory_rarity"), color_default, ingame_format)
		local rarity_string = func_color_text(managers.localization:text(rarity_tweak.name_id), func_hex_color(rarity_tweak.color), ingame_format)
		desc = desc .. rarity_title .. " " .. rarity_string
	end

	if item.quality then
		local quality_title = func_color_text(managers.localization:text("steam_inventory_quality") .. " " .. managers.localization:text(tweak_data.economy.qualities[item.quality].name_id), color_default, ingame_format)
		desc = desc .. func_add_lb(ingame_format) .. quality_title
	end

	if item.bonus then
		local bonus_string = ""
		local bonus_data = tweak_data.economy.bonuses[tweak.bonus]

		if bonus_data.stats then
			local stats = WeaponDescription.get_bonus_stats(item.entry, tweak.weapon_id, bonus_data.stats)

			for bonus_name, bonus_value in pairs(stats or bonus_data.stats) do
				bonus_string = bonus_string .. managers.localization:text("steam_inventory_stat_boost") .. " " .. (bonus_value > 0 and "+" or "") .. tostring(math.round(bonus_value)) .. " " .. managers.localization:text("bm_menu_" .. bonus_name)
			end
		end

		if bonus_data.exp_multiplier and bonus_data.money_multiplier then
			local xp_boost = "+" .. bonus_data.exp_multiplier * 100 - 100 .. "%"
			local cash_boost = bonus_data.money_multiplier == bonus_data.exp_multiplier and "" or "+" .. bonus_data.money_multiplier * 100 - 100 .. "% "
			bonus_string = bonus_string .. (not ingame_format and func_add_lb(ingame_format) or "") .. func_add_lb(ingame_format) .. managers.localization:text("steam_inventory_team_boost") .. " " .. managers.localization:text("steam_inventory_boost_xp_cash", {
				xp = xp_boost,
				cash = cash_boost
			})
		elseif bonus_data.exp_multiplier then
			local xp_boost = "+" .. bonus_data.exp_multiplier * 100 - 100 .. "%"
			bonus_string = bonus_string .. (not ingame_format and func_add_lb(ingame_format) or "") .. func_add_lb(ingame_format) .. managers.localization:text("steam_inventory_team_boost") .. " " .. managers.localization:text("steam_inventory_boost_xp", {
				xp = xp_boost
			})
		elseif bonus_data.money_multiplier then
			local cash_boost = "+" .. bonus_data.money_multiplier * 100 - 100 .. "%"
			bonus_string = bonus_string .. (not ingame_format and func_add_lb(ingame_format) or "") .. func_add_lb(ingame_format) .. managers.localization:text("steam_inventory_team_boost") .. " " .. managers.localization:text("steam_inventory_boost_cash", {
				cash = cash_boost
			})
		end

		bonus_string = func_color_text(bonus_string, color_bonus, ingame_format)
		desc = desc .. func_add_lb(ingame_format) .. func_add_lb(ingame_format) .. bonus_string
	end

	if tweak.name_id and not tweak.weapon_id or tweak.name_id and tweak.rarity == "legendary" then
		local formatted_text = managers.localization:text(tweak.name_id .. "_desc")

		if not ingame_format then
			formatted_text = string.gsub(formatted_text, "\"", "'")
		end

		formatted_text = string.gsub(formatted_text, "\n", "\\n")
		local desc_string = func_color_text(formatted_text, color_default, ingame_format)
		desc = desc .. func_add_lb(ingame_format) .. func_add_lb(ingame_format) .. desc_string
	end

	local collection = {}

	for safe, safe_data in pairs(tweak_data.economy.safes) do
		if InventoryDescription._find_item_in_content(item.entry, item.category, safe_data.content) then
			table.insert(collection, safe)
		end
	end

	local collection_size = table.size(collection)

	if collection_size > 0 then
		local collection_string = ""

		for i, safe in pairs(collection) do
			collection_string = collection_string .. managers.localization:text("steam_inventory_collection_" .. safe) .. (i < collection_size and ", " or "")
		end

		collection_string = func_color_text(collection_string, color_collection, ingame_format)

		if item.category == "armor_skins" then
			desc = desc .. func_add_lb(ingame_format) .. collection_string
		else
			desc = desc .. func_add_lb(ingame_format) .. func_add_lb(ingame_format) .. collection_string
		end
	end

	if tweak.weapon_id then
		local dlc = tweak_data.weapon[tweak.weapon_id].global_value

		if dlc and dlc ~= "pd2_clan" and dlc ~= "normal" and (not ingame_format or not managers.dlc:is_dlc_unlocked(dlc)) then
			local dlc_string = func_color_text(managers.localization:text("steam_inventory_dlc_required", {
				dlc = managers.localization:text("bm_global_value_" .. dlc)
			}), color_dlc, ingame_format)
			desc = desc .. func_add_lb(ingame_format) .. func_add_lb(ingame_format) .. dlc_string
		end
	end

	if tweak.default_blueprint then
		local mods_title = func_color_text(managers.localization:text("steam_inventory_mods_included"), color_mods_title, ingame_format)
		local list = {}

		for _, blueprint in pairs(tweak.default_blueprint) do
			local blueprint_tweak = tweak_data.blackmarket.weapon_mods[blueprint]

			if blueprint_tweak and blueprint_tweak.pcs then
				table.insert(list, managers.localization:text(blueprint_tweak.name_id))
			end
		end

		if #list > 0 then
			local mods_string = (ingame_format and "\n" or "") .. func_color_text(func_create_list(list, ingame_format), color_mods, ingame_format)
			desc = desc .. func_add_lb(ingame_format) .. func_add_lb(ingame_format) .. mods_title .. mods_string
		end
	end

	if ingame_format then
		return desc, color_ranges
	end

	return desc
end

WeaponDescription = WeaponDescription or class()
WeaponDescription._stats_shown = {
	{
		round_value = true,
		name = "magazine",
		stat_name = "extra_ammo"
	},
	{
		round_value = true,
		name = "totalammo",
		stat_name = "total_ammo_mod"
	},
	{
		round_value = true,
		name = "fire_rate"
	},
	{
		name = "damage"
	},
	{
		percent = true,
		name = "spread",
		offset = true,
		revert = true
	},
	{
		percent = true,
		name = "recoil",
		offset = true,
		revert = true
	},
	{
		index = true,
		name = "concealment"
	},
	{
		percent = false,
		name = "suppression",
		offset = true
	}
}

table.insert(WeaponDescription._stats_shown, {
	name = "reload"
})

function WeaponDescription.get_bonus_stats(cosmetic_id, weapon_id, bonus)
	local base_stats = WeaponDescription._get_base_stats(weapon_id)
	local mod_stats = WeaponDescription._get_mods_stats(weapon_id, base_stats, {}, bonus)
	local stats = WeaponDescription._get_weapon_mod_stats(cosmetic_id, weapon_id, base_stats, mod_stats, {})

	for k, stat in pairs(WeaponDescription._stats_shown) do
		if stats.chosen[stat.name] then
			if stats.chosen[stat.name] == 0 then
				stats.chosen[stat.name] = nil
			elseif stats.chosen[stat.name] then
				stats[stat.name] = stats.chosen[stat.name]
			end
		end
	end

	stats.chosen = nil
	stats.equip = nil

	return stats
end

function WeaponDescription.get_weapon_ammo_info(weapon_id, extra_ammo, total_ammo_mod)
	local weapon_tweak_data = tweak_data.weapon[weapon_id]
	local ammo_max_multiplier = managers.player:upgrade_value("player", "extra_ammo_multiplier", 1)
	local primary_category = weapon_tweak_data.categories[1]
	local category_skill_in_effect = false
	local category_multiplier = 1

	for _, category in ipairs(weapon_tweak_data.categories) do
		if managers.player:has_category_upgrade(category, "extra_ammo_multiplier") then
			category_multiplier = category_multiplier + managers.player:upgrade_value(category, "extra_ammo_multiplier", 1) - 1
			category_skill_in_effect = true
		end
	end

	ammo_max_multiplier = ammo_max_multiplier * category_multiplier

	if managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul") then
		ammo_max_multiplier = ammo_max_multiplier * managers.player:body_armor_value("skill_ammo_mul", nil, 1)
	end

	local function get_ammo_max_per_clip(weapon_id)
		local function upgrade_blocked(category, upgrade)
			if not weapon_tweak_data.upgrade_blocks then
				return false
			end

			if not weapon_tweak_data.upgrade_blocks[category] then
				return false
			end

			return table.contains(weapon_tweak_data.upgrade_blocks[category], upgrade)
		end

		local clip_base = weapon_tweak_data.CLIP_AMMO_MAX
		local clip_mod = extra_ammo and tweak_data.weapon.stats.extra_ammo[extra_ammo] or 0
		local clip_skill = managers.player:upgrade_value(weapon_id, "clip_ammo_increase")

		if not upgrade_blocked("weapon", "clip_ammo_increase") then
			clip_skill = clip_skill + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
		end

		for _, category in ipairs(weapon_tweak_data.categories) do
			if not upgrade_blocked(category, "clip_ammo_increase") then
				clip_skill = clip_skill + managers.player:upgrade_value(category, "clip_ammo_increase", 0)
			end
		end

		return clip_base + clip_mod + clip_skill
	end

	local ammo_max_per_clip = get_ammo_max_per_clip(weapon_id)
	local ammo_max = tweak_data.weapon[weapon_id].AMMO_MAX
	local ammo_from_mods = ammo_max * (total_ammo_mod and tweak_data.weapon.stats.total_ammo_mod[total_ammo_mod] or 0)
	ammo_max = (ammo_max + ammo_from_mods + managers.player:upgrade_value(weapon_id, "clip_amount_increase") * ammo_max_per_clip) * ammo_max_multiplier
	ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)
	local ammo_data = {
		base = tweak_data.weapon[weapon_id].AMMO_MAX,
		mod = ammo_from_mods + managers.player:upgrade_value(weapon_id, "clip_amount_increase") * ammo_max_per_clip
	}
	ammo_data.skill = (ammo_data.base + ammo_data.mod) * ammo_max_multiplier - ammo_data.base - ammo_data.mod
	ammo_data.skill_in_effect = managers.player:has_category_upgrade("player", "extra_ammo_multiplier") or category_skill_in_effect or managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul")

	return ammo_max_per_clip, ammo_max, ammo_data
end

function WeaponDescription._get_skill_stats(name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
	local skill_stats = {}
	local tweak_stats = tweak_data.weapon.stats

	for _, stat in pairs(WeaponDescription._stats_shown) do
		skill_stats[stat.name] = {
			value = 0
		}
	end

	local detection_risk = 0

	if category then
		local custom_data = {
			[category] = managers.blackmarket:get_crafted_category_slot(category, slot)
		}
		detection_risk = managers.blackmarket:get_suspicion_offset_from_custom_data(custom_data, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
		detection_risk = detection_risk * 100
	end

	local base_value, base_index, modifier, multiplier = nil
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
	local weapon_tweak = tweak_data.weapon[name]
	local primary_category = weapon_tweak.categories[1]

	for _, stat in ipairs(WeaponDescription._stats_shown) do
		if weapon_tweak.stats[stat.stat_name or stat.name] or stat.name == "totalammo" or stat.name == "fire_rate" then
			if stat.name == "magazine" then
				skill_stats[stat.name].value = managers.player:upgrade_value(name, "clip_ammo_increase", 0)
				local has_magazine = weapon_tweak.has_magazine
				local add_modifier = false

				if is_weapon_category(weapon_tweak, "shotgun") and has_magazine then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("shotgun", "magazine_capacity_inc", 0)
					add_modifier = managers.player:has_category_upgrade("shotgun", "magazine_capacity_inc")

					if primary_category == "akimbo" then
						skill_stats[stat.name].value = skill_stats[stat.name].value * 2
					end
				elseif is_weapon_category(weapon_tweak, "pistol") and not is_weapon_category(weapon_tweak, "revolver") and managers.player:has_category_upgrade("pistol", "magazine_capacity_inc") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("pistol", "magazine_capacity_inc", 0)

					if primary_category == "akimbo" then
						skill_stats[stat.name].value = skill_stats[stat.name].value * 2
					end

					add_modifier = true
				elseif is_weapon_category(weapon_tweak, "smg", "assault_rifle", "lmg") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("player", "automatic_mag_increase", 0)
					add_modifier = managers.player:has_category_upgrade("player", "automatic_mag_increase")

					if primary_category == "akimbo" then
						skill_stats[stat.name].value = skill_stats[stat.name].value * 2
					end
				end

				if not weapon_tweak.upgrade_blocks or not weapon_tweak.upgrade_blocks.weapon or not table.contains(weapon_tweak.upgrade_blocks.weapon, "clip_ammo_increase") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
				end

				if not weapon_tweak.upgrade_blocks or not weapon_tweak.upgrade_blocks[primary_category] or not table.contains(weapon_tweak.upgrade_blocks[primary_category], "clip_ammo_increase") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value(primary_category, "clip_ammo_increase", 0)
				end

				skill_stats[stat.name].skill_in_effect = managers.player:has_category_upgrade(name, "clip_ammo_increase") or managers.player:has_category_upgrade("weapon", "clip_ammo_increase") or add_modifier
			elseif stat.name == "totalammo" then
				-- Nothing
			elseif stat.name == "reload" then
				local skill_in_effect = false
				local mult = 1

				for _, category in ipairs(weapon_tweak.categories) do
					if managers.player:has_category_upgrade(category, "reload_speed_multiplier") then
						mult = mult + 1 - managers.player:upgrade_value(category, "reload_speed_multiplier", 1)
						skill_in_effect = true
					end
				end

				mult = 1 / managers.blackmarket:_convert_add_to_mul(mult)
				local diff = base_stats[stat.name].value * mult - base_stats[stat.name].value
				skill_stats[stat.name].value = skill_stats[stat.name].value + diff
				skill_stats[stat.name].skill_in_effect = skill_in_effect
			else
				base_value = math.max(base_stats[stat.name].value + mods_stats[stat.name].value, 0)

				if base_stats[stat.name].index and mods_stats[stat.name].index then
					base_index = base_stats[stat.name].index + mods_stats[stat.name].index
				end

				multiplier = 1
				modifier = 0
				local is_single_shot = managers.weapon_factory:has_perk("fire_mode_single", factory_id, blueprint)

				if stat.name == "damage" then
					multiplier = managers.blackmarket:damage_multiplier(name, weapon_tweak.categories, silencer, detection_risk, nil, blueprint)
					modifier = math.floor(managers.blackmarket:damage_addend(name, weapon_tweak.categories, silencer, detection_risk, nil, blueprint) * tweak_data.gui.stats_present_multiplier * multiplier)
				elseif stat.name == "spread" then
					local fire_mode = single_mod and "single" or auto_mod and "auto" or weapon_tweak.FIRE_MODE or "single"
					multiplier = managers.blackmarket:accuracy_multiplier(name, weapon_tweak.categories, silencer, nil, nil, fire_mode, blueprint, nil, is_single_shot)
					modifier = managers.blackmarket:accuracy_addend(name, weapon_tweak.categories, base_index, silencer, nil, fire_mode, blueprint, nil, is_single_shot) * tweak_data.gui.stats_present_multiplier
				elseif stat.name == "recoil" then
					multiplier = managers.blackmarket:recoil_multiplier(name, weapon_tweak.categories, silencer, blueprint)
					modifier = managers.blackmarket:recoil_addend(name, weapon_tweak.categories, base_index, silencer, blueprint, nil, is_single_shot) * tweak_data.gui.stats_present_multiplier
				elseif stat.name == "suppression" then
					multiplier = managers.blackmarket:threat_multiplier(name, weapon_tweak.categories, silencer)
				elseif stat.name == "concealment" then
					if silencer and managers.player:has_category_upgrade("player", "silencer_concealment_increase") then
						modifier = managers.player:upgrade_value("player", "silencer_concealment_increase", 0)
					end

					if silencer and managers.player:has_category_upgrade("player", "silencer_concealment_penalty_decrease") then
						local stats = managers.weapon_factory:get_perk_stats("silencer", factory_id, blueprint)

						if stats and stats.concealment then
							modifier = modifier + math.min(managers.player:upgrade_value("player", "silencer_concealment_penalty_decrease", 0), math.abs(stats.concealment))
						end
					end
				elseif stat.name == "fire_rate" then
					multiplier = managers.blackmarket:fire_rate_multiplier(name, weapon_tweak.categories, silencer, detection_risk, nil, blueprint)
				end

				if modifier ~= 0 then
					local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

					if stat.revert then
						modifier = -modifier
					end

					if stat.percent then
						local max_stat = stat.index and #tweak_stats[stat.name] or math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

						if stat.offset then
							max_stat = max_stat - offset
						end

						local ratio = modifier / max_stat
						modifier = ratio * 100
					end
				end

				if stat.revert then
					multiplier = 1 / math.max(multiplier, 0.01)
				end

				skill_stats[stat.name].skill_in_effect = multiplier ~= 1 or modifier ~= 0
				skill_stats[stat.name].value = modifier + base_value * multiplier - base_value
			end
		end
	end

	return skill_stats
end

function WeaponDescription._get_mods_stats(name, base_stats, equipped_mods, bonus_stats)
	local mods_stats = {}
	local modifier_stats = tweak_data.weapon[name].stats_modifiers

	for _, stat in pairs(WeaponDescription._stats_shown) do
		mods_stats[stat.name] = {
			index = 0,
			value = 0
		}
	end

	if equipped_mods then
		local tweak_stats = tweak_data.weapon.stats
		local tweak_factory = tweak_data.weapon.factory.parts
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		if bonus_stats then
			for _, stat in pairs(WeaponDescription._stats_shown) do
				if stat.name == "magazine" then
					local ammo = mods_stats[stat.name].index
					ammo = ammo and ammo + (tweak_data.weapon[name].stats.extra_ammo or 0)
					mods_stats[stat.name].value = mods_stats[stat.name].value + (ammo and tweak_data.weapon.stats.extra_ammo[ammo] or 0)
				elseif stat.name == "totalammo" then
					local ammo = bonus_stats.total_ammo_mod
					mods_stats[stat.name].index = mods_stats[stat.name].index + (ammo or 0)
				else
					mods_stats[stat.name].index = mods_stats[stat.name].index + (bonus_stats[stat.name] or 0)
				end
			end
		end

		local part_data = nil

		for _, mod in ipairs(equipped_mods) do
			part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod, factory_id, default_blueprint)

			if part_data then
				for _, stat in pairs(WeaponDescription._stats_shown) do
					if part_data.stats then
						if stat.name == "magazine" then
							local ammo = part_data.stats.extra_ammo
							ammo = ammo and ammo + (tweak_data.weapon[name].stats.extra_ammo or 0)
							mods_stats[stat.name].value = mods_stats[stat.name].value + (ammo and tweak_data.weapon.stats.extra_ammo[ammo] or 0)
						elseif stat.name == "totalammo" then
							local ammo = part_data.stats.total_ammo_mod
							mods_stats[stat.name].index = mods_stats[stat.name].index + (ammo or 0)
						elseif stat.name == "reload" then
							if not base_stats[stat.name].index then
								debug_pause("weapon is missing reload stat", name)
							end

							local chosen_index = part_data.stats.reload or 0
							chosen_index = math.clamp(base_stats[stat.name].index + chosen_index, 1, #tweak_stats[stat.name])
							local mult = 1 / tweak_data.weapon.stats[stat.name][chosen_index]
							mods_stats[stat.name].value = base_stats[stat.name].value * mult
							mods_stats[stat.name].index = chosen_index
						else
							mods_stats[stat.name].index = mods_stats[stat.name].index + (part_data.stats[stat.name] or 0)
						end
					end
				end
			end
		end

		local index, stat_name = nil

		for _, stat in pairs(WeaponDescription._stats_shown) do
			stat_name = stat.name

			if mods_stats[stat.name].index and tweak_stats[stat_name] then
				if stat.name == "concealment" then
					index = base_stats[stat.name].index + mods_stats[stat.name].index
				else
					index = math.clamp(base_stats[stat.name].index + mods_stats[stat.name].index, 1, #tweak_stats[stat_name])
				end

				if stat.name ~= "reload" then
					mods_stats[stat.name].value = stat.index and index or tweak_stats[stat_name][index] * tweak_data.gui.stats_present_multiplier
				end

				local offset = math.min(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]]) * tweak_data.gui.stats_present_multiplier

				if stat.offset then
					mods_stats[stat.name].value = mods_stats[stat.name].value - offset
				end

				if stat.revert then
					local max_stat = math.max(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]]) * tweak_data.gui.stats_present_multiplier

					if stat.offset then
						max_stat = max_stat - offset
					end

					mods_stats[stat.name].value = max_stat - mods_stats[stat.name].value
				end

				if modifier_stats and modifier_stats[stat.name] then
					local mod = modifier_stats[stat.name]

					if stat.revert and not stat.index then
						local real_base_value = tweak_stats[stat_name][index]
						local modded_value = real_base_value * mod
						local offset = math.min(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]])

						if stat.offset then
							modded_value = modded_value - offset
						end

						local max_stat = math.max(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]])

						if stat.offset then
							max_stat = max_stat - offset
						end

						local new_value = (max_stat - modded_value) * tweak_data.gui.stats_present_multiplier

						if mod ~= 0 and (tweak_stats[stat_name][1] < modded_value or modded_value < tweak_stats[stat_name][#tweak_stats[stat_name]]) then
							new_value = (new_value + mods_stats[stat.name].value / mod) / 2
						end

						mods_stats[stat.name].value = new_value
					else
						mods_stats[stat.name].value = mods_stats[stat.name].value * mod
					end
				end

				if stat.percent then
					local max_stat = stat.index and #tweak_stats[stat.name] or math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

					if stat.offset then
						max_stat = max_stat - offset
					end

					local ratio = mods_stats[stat.name].value / max_stat
					mods_stats[stat.name].value = ratio * 100
				end

				mods_stats[stat.name].value = mods_stats[stat.name].value - base_stats[stat.name].value
			end
		end
	end

	return mods_stats
end

function WeaponDescription._get_base_stats(name)
	local base_stats = {}
	local index = nil
	local tweak_stats = tweak_data.weapon.stats
	local modifier_stats = tweak_data.weapon[name].stats_modifiers

	for _, stat in pairs(WeaponDescription._stats_shown) do
		base_stats[stat.name] = {}

		if stat.name == "magazine" then
			base_stats[stat.name].index = 0
			base_stats[stat.name].value = tweak_data.weapon[name].CLIP_AMMO_MAX
		elseif stat.name == "totalammo" then
			index = math.clamp(tweak_data.weapon[name].stats.total_ammo_mod, 1, #tweak_stats.total_ammo_mod)
			base_stats[stat.name].index = tweak_data.weapon[name].stats.total_ammo_mod
			base_stats[stat.name].value = tweak_data.weapon[name].AMMO_MAX
		elseif stat.name == "fire_rate" then
			local fire_rate = 60 / tweak_data.weapon[name].fire_mode_data.fire_rate
			base_stats[stat.name].value = fire_rate / 10 * 10
		elseif stat.name == "reload" then
			index = math.clamp(tweak_data.weapon[name].stats[stat.name], 1, #tweak_stats[stat.name])
			base_stats[stat.name].index = tweak_data.weapon[name].stats[stat.name]
			local reload_time = managers.blackmarket:get_reload_time(name)
			local mult = 1 / tweak_data.weapon.stats[stat.name][index]
			base_stats[stat.name].value = reload_time * mult
		elseif tweak_stats[stat.name] then
			index = math.clamp(tweak_data.weapon[name].stats[stat.name], 1, #tweak_stats[stat.name])
			base_stats[stat.name].index = index
			base_stats[stat.name].value = stat.index and index or tweak_stats[stat.name][index] * tweak_data.gui.stats_present_multiplier
			local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

			if stat.offset then
				base_stats[stat.name].value = base_stats[stat.name].value - offset
			end

			if stat.revert then
				local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

				if stat.offset then
					max_stat = max_stat - offset
				end

				base_stats[stat.name].value = max_stat - base_stats[stat.name].value
			end

			if modifier_stats and modifier_stats[stat.name] then
				local mod = modifier_stats[stat.name]

				if stat.revert and not stat.index then
					local real_base_value = tweak_stats[stat.name][index]
					local modded_value = real_base_value * mod
					local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

					if stat.offset then
						modded_value = modded_value - offset
					end

					local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

					if stat.offset then
						max_stat = max_stat - offset
					end

					local new_value = (max_stat - modded_value) * tweak_data.gui.stats_present_multiplier

					if mod ~= 0 and (tweak_stats[stat.name][1] < modded_value or modded_value < tweak_stats[stat.name][#tweak_stats[stat.name]]) then
						new_value = (new_value + base_stats[stat.name].value / mod) / 2
					end

					base_stats[stat.name].value = new_value
				else
					base_stats[stat.name].value = base_stats[stat.name].value * mod
				end
			end

			if stat.percent then
				local max_stat = stat.index and #tweak_stats[stat.name] or math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

				if stat.offset then
					max_stat = max_stat - offset
				end

				local ratio = base_stats[stat.name].value / max_stat
				base_stats[stat.name].value = ratio * 100
			end
		end
	end

	return base_stats
end

function WeaponDescription._get_stats(name, category, slot, blueprint)
	local equipped_mods = nil
	local silencer = false
	local single_mod = false
	local auto_mod = false
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
	local blueprint = blueprint or slot and managers.blackmarket:get_weapon_blueprint(category, slot) or managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local cosmetics = managers.blackmarket:get_weapon_cosmetics(category, slot)
	local bonus_stats = {}

	if cosmetics and cosmetics.id and cosmetics.bonus and not managers.job:is_current_job_competitive() and not managers.weapon_factory:has_perk("bonus", factory_id, blueprint) then
		bonus_stats = tweak_data:get_raw_value("economy", "bonuses", tweak_data.blackmarket.weapon_skins[cosmetics.id].bonus, "stats") or {}
	end

	if blueprint then
		equipped_mods = deep_clone(blueprint)
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		if equipped_mods then
			silencer = managers.weapon_factory:has_perk("silencer", factory_id, equipped_mods)
			single_mod = managers.weapon_factory:has_perk("fire_mode_single", factory_id, equipped_mods)
			auto_mod = managers.weapon_factory:has_perk("fire_mode_auto", factory_id, equipped_mods)
		end
	end

	local base_stats = WeaponDescription._get_base_stats(name)
	local mods_stats = WeaponDescription._get_mods_stats(name, base_stats, equipped_mods, bonus_stats)
	local skill_stats = WeaponDescription._get_skill_stats(name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
	local clip_ammo, max_ammo, ammo_data = WeaponDescription.get_weapon_ammo_info(name, tweak_data.weapon[name].stats.extra_ammo, base_stats.totalammo.index + mods_stats.totalammo.index)
	base_stats.totalammo.value = ammo_data.base
	mods_stats.totalammo.value = ammo_data.mod
	skill_stats.totalammo.value = ammo_data.skill
	skill_stats.totalammo.skill_in_effect = ammo_data.skill_in_effect
	local my_clip = base_stats.magazine.value + mods_stats.magazine.value + skill_stats.magazine.value

	if max_ammo < my_clip then
		mods_stats.magazine.value = mods_stats.magazine.value + max_ammo - my_clip
	end

	return base_stats, mods_stats, skill_stats
end

function WeaponDescription.get_stats_for_mod(mod_name, weapon_name, category, slot)
	local equipped_mods = nil
	local blueprint = managers.blackmarket:get_weapon_blueprint(category, slot)

	if blueprint then
		equipped_mods = deep_clone(blueprint)
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		for _, default_part in ipairs(default_blueprint) do
			table.delete(equipped_mods, default_part)
		end
	end

	local base_stats = WeaponDescription._get_base_stats(weapon_name)
	local mods_stats = WeaponDescription._get_mods_stats(weapon_name, base_stats, equipped_mods)

	return WeaponDescription._get_weapon_mod_stats(mod_name, weapon_name, base_stats, mods_stats, equipped_mods)
end

function WeaponDescription._get_weapon_mod_stats(mod_name, weapon_name, base_stats, mods_stats, equipped_mods)
	local tweak_stats = tweak_data.weapon.stats
	local tweak_factory = tweak_data.weapon.factory.parts
	local modifier_stats = tweak_data.weapon[weapon_name].stats_modifiers
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_name)
	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local part_data = nil
	local mod_stats = {
		chosen = {},
		equip = {}
	}

	for _, stat in pairs(WeaponDescription._stats_shown) do
		mod_stats.chosen[stat.name] = 0
		mod_stats.equip[stat.name] = 0
	end

	mod_stats.chosen.name = mod_name

	if equipped_mods then
		for _, mod in ipairs(equipped_mods) do
			if tweak_factory[mod] and tweak_factory[mod_name].type == tweak_factory[mod].type then
				mod_stats.equip.name = mod

				break
			end
		end
	end

	local curr_stats = base_stats
	local index, wanted_index = nil

	for _, mod in pairs(mod_stats) do
		part_data = nil

		if mod.name then
			if tweak_data.blackmarket.weapon_skins[mod.name] and tweak_data.blackmarket.weapon_skins[mod.name].bonus and tweak_data.economy.bonuses[tweak_data.blackmarket.weapon_skins[mod.name].bonus] then
				part_data = {
					stats = tweak_data.economy.bonuses[tweak_data.blackmarket.weapon_skins[mod.name].bonus].stats
				}
			else
				part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod.name, factory_id, default_blueprint)
			end
		end

		for _, stat in pairs(WeaponDescription._stats_shown) do
			if part_data and part_data.stats then
				if stat.name == "magazine" then
					local ammo = part_data.stats.extra_ammo
					ammo = ammo and ammo + (tweak_data.weapon[weapon_name].stats.extra_ammo or 0)
					mod[stat.name] = ammo and tweak_data.weapon.stats.extra_ammo[ammo] or 0
				elseif stat.name == "totalammo" then
					local chosen_index = part_data.stats.total_ammo_mod or 0
					chosen_index = math.clamp(base_stats[stat.name].index + chosen_index, 1, #tweak_stats.total_ammo_mod)
					mod[stat.name] = base_stats[stat.name].value * tweak_stats.total_ammo_mod[chosen_index]
				elseif stat.name == "reload" then
					local chosen_index = part_data.stats.reload or 0
					chosen_index = math.clamp(base_stats[stat.name].index + chosen_index, 1, #tweak_stats[stat.name])
					local mult = 1 / tweak_data.weapon.stats[stat.name][chosen_index]
					mod[stat.name] = base_stats[stat.name].value * mult - base_stats[stat.name].value
				else
					local chosen_index = part_data.stats[stat.name] or 0

					if tweak_stats[stat.name] then
						wanted_index = curr_stats[stat.name].index + chosen_index
						index = math.clamp(wanted_index, 1, #tweak_stats[stat.name])
						mod[stat.name] = stat.index and index or tweak_stats[stat.name][index] * tweak_data.gui.stats_present_multiplier

						if wanted_index ~= index then
							print("[WeaponDescription._get_weapon_mod_stats] index went out of bound, estimating value", "mod_name", mod_name, "stat.name", stat.name, "wanted_index", wanted_index, "index", index)

							if stat.index then
								index = wanted_index
								mod[stat.name] = index
							elseif index ~= curr_stats[stat.name].index then
								local diff_value = tweak_stats[stat.name][index] - tweak_stats[stat.name][curr_stats[stat.name].index]
								local diff_index = index - curr_stats[stat.name].index
								local diff_ratio = diff_value / diff_index
								diff_index = wanted_index - index
								diff_value = diff_index * diff_ratio
								mod[stat.name] = mod[stat.name] + diff_value * tweak_data.gui.stats_present_multiplier
							end
						end

						local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

						if stat.offset then
							mod[stat.name] = mod[stat.name] - offset
						end

						if stat.revert then
							local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

							if stat.revert then
								max_stat = max_stat - offset
							end

							mod[stat.name] = max_stat - mod[stat.name]
						end

						if modifier_stats and modifier_stats[stat.name] then
							local mod_stat = modifier_stats[stat.name]

							if stat.revert and not stat.index then
								local real_base_value = tweak_stats[stat.name][index]
								local modded_value = real_base_value * mod_stat
								local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

								if stat.offset then
									modded_value = modded_value - offset
								end

								local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

								if stat.offset then
									max_stat = max_stat - offset
								end

								local new_value = (max_stat - modded_value) * tweak_data.gui.stats_present_multiplier

								if mod_stat ~= 0 and (tweak_stats[stat.name][1] < modded_value or modded_value < tweak_stats[stat.name][#tweak_stats[stat.name]]) then
									new_value = (new_value + mod[stat.name] / mod_stat) / 2
								end

								mod[stat.name] = new_value
							else
								mod[stat.name] = mod[stat.name] * mod_stat
							end
						end

						if stat.percent then
							local max_stat = stat.index and #tweak_stats[stat.name] or math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

							if stat.offset then
								max_stat = max_stat - offset
							end

							local ratio = mod[stat.name] / max_stat
							mod[stat.name] = ratio * 100
						end

						mod[stat.name] = mod[stat.name] - curr_stats[stat.name].value
					end
				end
			end
		end
	end

	return mod_stats
end
