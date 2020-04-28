function BlackMarketTweakData:get_glove_value(glove_id, character_name, key)
	if key == nil then
		return
	end

	local data = self.gloves[glove_id or "default"]

	if data == nil then
		return nil
	end

	character_name = CriminalsManager.convert_old_to_new_character_workname(character_name)
	local character_value = data.characters and data.characters[character_name] and data.characters[character_name][key]

	if character_value ~= nil then
		return character_value
	end

	local tweak_value = data and data[key]

	return tweak_value
end

function BlackMarketTweakData:get_glove_units(glove_id, key)
	local units = {}
	local data = self.gloves[glove_id]
	key = key or "all"
	local include_fps = key == "all" or key == "fps"
	local include_third = key == "all" or key == "third"

	if data.unit and include_fps then
		table.insert(units, data.unit)
	end

	if data.third_unit and include_third then
		table.insert(units, data.third_unit)
	end

	if data.characters then
		for character, char_data in pairs(data.characters) do
			if char_data.unit and include_fps then
				table.insert(units, char_data.unit)
			end

			if char_data.third_unit and include_third then
				table.insert(units, char_data.third_unit)
			end
		end
	end

	return table.list_union(units)
end

function BlackMarketTweakData:build_glove_list(tweak_data)
	local x_td, y_td, x_gv, y_gv, x_sn, y_sn = nil

	local function sort_func(x, y)
		if x == "default" then
			return true
		end

		if y == "default" then
			return false
		end

		x_td = self.gloves[x]
		y_td = self.gloves[y]

		if x_td.unlocked ~= y_td.unlocked then
			return x_td.unlocked
		end

		x_gv = x_td.global_value or x_td.dlc or "normal"
		y_gv = y_td.global_value or y_td.dlc or "normal"
		x_sn = x_gv and tweak_data.lootdrop.global_values[x_gv].sort_number or 0
		y_sn = y_gv and tweak_data.lootdrop.global_values[y_gv].sort_number or 0

		if x_sn ~= y_sn then
			return x_sn < y_sn
		end

		return x < y
	end

	self.glove_list = table.map_keys(self.gloves, sort_func)
end

function BlackMarketTweakData:_init_gloves(tweak_data)
	local characters_female, characters_female_big, characters_male, characters_male_big = self:_get_character_groups()
	local characters_all = table.list_union(characters_female, characters_male, characters_female_big, characters_male_big)

	local function set_characters_data(glove_id, characters, data)
		self.gloves[glove_id].characters = self.gloves[glove_id].characters or {}

		for _, key in ipairs(characters) do
			self.gloves[glove_id].characters[key] = data
		end
	end

	self.gloves = {}
	self.glove_list = {}
	self.gloves.default = {
		name_id = "bm_gloves_default",
		desc_id = "bm_gloves_default_desc",
		texture_bundle_folder = "hnd",
		unlocked = true
	}
end
