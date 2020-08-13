function BlackMarketTweakData:get_glove_value(glove_id, character_name, key, player_style, material_variation)
	if key == nil then
		return
	end

	glove_id = glove_id or "default"

	if glove_id == "default" then
		glove_id = self.suit_default_gloves[player_style]

		if glove_id == false then
			return false
		end
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
		x_sn = x_sn + (x_td.sort_number or 0)
		y_sn = y_sn + (y_td.sort_number or 0)

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
	self.glove_adapter = {
		unit = "units/pd2_dlc_hnd/characters/hnd_forearms/hnd_forearms",
		third_material = "units/pd2_dlc_hnd/characters/hnd_forearms/hnd_forearms_third",
		character_sequence = {
			bonnie = "set_arms_female",
			dragon = "set_arms_male_02",
			myh = "set_arms_male",
			chico = "set_arms_male_02",
			dragan = "set_arms_male",
			ecp_male = "set_arms_male",
			ecp_female = "set_arms_female",
			max = "set_arms_male_sangres",
			old_hoxton = "set_arms_male",
			jowi = "set_arms_male",
			wild = "set_arms_male",
			joy = "set_arms_female_joy",
			dallas = "set_arms_male",
			jacket = "set_arms_male",
			jimmy = "set_arms_male",
			bodhi = "set_arms_male_bodhi",
			wolf = "set_arms_male",
			sokol = "set_arms_male",
			hoxton = "set_arms_male",
			female_1 = "set_arms_female",
			chains = "set_arms_male_chains",
			sydney = "set_arms_female_sydney"
		},
		player_style_exclude_list = {
			"none",
			"slaughterhouse"
		}
	}
	self.suit_default_gloves = {
		sneak_suit = "sneak",
		peacoat = "saints",
		clown = "heist_clown",
		scrub = "heist_default",
		jumpsuit = "heat",
		hiphop = "bonemittens",
		slaughterhouse = "heist_default",
		xmas_tuxedo = "heist_default",
		winter_suit = "sneak",
		hippie = "rainbow_mittens",
		desperado = "desperado",
		punk = "punk",
		raincoat = "heist_default",
		mariachi = "mariatchi",
		poolrepair = "heist_default",
		jail_pd2_clan = "heist_default",
		esport = "esport",
		miami = "heist_default",
		murky_suit = "murky",
		tux = "heist_default",
		continental = "continental"
	}
	self.gloves.default = {
		name_id = "bm_gloves_default",
		desc_id = "bm_gloves_default_desc",
		texture_bundle_folder = "hnd",
		unlocked = true
	}
	self.gloves.heist_default = {
		name_id = "bm_gloves_heistwrinkled",
		desc_id = "bm_gloves_heistwrinkled_desc",
		texture_bundle_folder = "hnd",
		sort_number = -1000,
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_heistwrinkled/hnd_glv_heistwrinkled",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_heistwrinkled/hnd_glv_heistwrinkled_third"
	}
	self.gloves.saints = {
		name_id = "bm_gloves_saintsleather",
		desc_id = "bm_gloves_saintsleather_desc",
		texture_bundle_folder = "hnd",
		global_value = "trd",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_saintsleather/hnd_glv_saintsleather",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_saintsleather/hnd_glv_saintsleather_third"
	}
	self.gloves.heist_clown = {
		name_id = "bm_gloves_heistwrinkled_purple",
		desc_id = "bm_gloves_heistwrinkled_purple_desc",
		texture_bundle_folder = "hnd",
		global_value = "trd",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_heistwrinkled_purple/hnd_glv_heistwrinkled_purple",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_heistwrinkled_purple/hnd_glv_heistwrinkled_purple_third"
	}
	self.gloves.heat = {
		name_id = "bm_gloves_heatleather",
		desc_id = "bm_gloves_heatleather_desc",
		texture_bundle_folder = "hnd",
		global_value = "trd",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_heatleather/hnd_glv_heatleather",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_heatleather/hnd_glv_heatleather_third"
	}
	self.gloves.sneak = {
		name_id = "bm_gloves_sneak",
		desc_id = "bm_gloves_sneak_desc",
		texture_bundle_folder = "hnd",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_sneakgloves/hnd_glv_sneakgloves",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_sneakgloves/hnd_glv_sneakgloves_third"
	}
	self.gloves.murky = {
		name_id = "bm_gloves_murky",
		desc_id = "bm_gloves_murky_desc",
		texture_bundle_folder = "hnd",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_murkygloves/hnd_glv_murkygloves",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_murkygloves/hnd_glv_murkygloves_third"
	}
	self.gloves.mariatchi = {
		name_id = "bm_gloves_heistwrinkled_white",
		desc_id = "bm_gloves_heistwrinkled_white_desc",
		texture_bundle_folder = "hnd",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_heistwrinkled_white/hnd_glv_heistwrinkled_white",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_heistwrinkled_white/hnd_glv_heistwrinkled_white_third"
	}
	self.gloves.punk = {
		name_id = "bm_gloves_punkleather",
		desc_id = "bm_gloves_punkleather_desc",
		texture_bundle_folder = "hnd",
		global_value = "mbs",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_punkleather/hnd_glv_punkleather",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_punkleather/hnd_glv_punkleather_third"
	}
	self.gloves.desperado = {
		name_id = "bm_gloves_desperadoleather",
		desc_id = "bm_gloves_desperadoleather_desc",
		texture_bundle_folder = "hnd",
		global_value = "mbs",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_desperadoleather/hnd_glv_desperadoleather",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_desperadoleather/hnd_glv_desperadoleather_third"
	}
	self.gloves.bonemittens = {
		name_id = "bm_gloves_bonemittens",
		desc_id = "bm_gloves_bonemittens_desc",
		texture_bundle_folder = "hnd",
		global_value = "mbs",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_bonemittens/hnd_glv_bonemittens",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_bonemittens/hnd_glv_bonemittens_third"
	}
	self.gloves.rainbow_mittens = {
		name_id = "bm_gloves_rainbowmittens",
		desc_id = "bm_gloves_rainbowmittens_desc",
		texture_bundle_folder = "hnd",
		global_value = "mbs",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_rainbowmittens/hnd_glv_rainbowmittens",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_rainbowmittens/hnd_glv_rainbowmittens_third"
	}
	self.gloves.esport = {
		name_id = "bm_gloves_esport",
		desc_id = "bm_gloves_esport_desc",
		texture_bundle_folder = "hnd",
		global_value = "ess",
		unit = "units/pd2_dlc_hnd/characters/hnd_glv_esport/hnd_glv_esport",
		third_material = "units/pd2_dlc_hnd/characters/hnd_glv_esport/hnd_glv_esport_third"
	}
	self.gloves.continental = {
		name_id = "bm_gloves_continental",
		desc_id = "bm_gloves_continental_desc",
		texture_bundle_folder = "anv",
		global_value = "anv",
		unit = "units/pd2_dlc_anv/characters/anv_glv_continental/anv_glv_continental",
		third_material = "units/pd2_dlc_anv/characters/anv_glv_continental/anv_glv_continental_third"
	}
end
