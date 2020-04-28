BlackMarketTweakData = BlackMarketTweakData or class()

require("lib/tweak_data/blackmarket/ColorsTweakData")
require("lib/tweak_data/blackmarket/MaterialsTweakData")
require("lib/tweak_data/blackmarket/TexturesTweakData")
require("lib/tweak_data/blackmarket/MasksTweakData")
require("lib/tweak_data/blackmarket/ProjectilesTweakData")
require("lib/tweak_data/blackmarket/MeleeWeaponsTweakData")
require("lib/tweak_data/blackmarket/WeaponSkinsTweakData")
require("lib/tweak_data/blackmarket/PlayerStyleTweakData")

local is_nextgen_console = SystemInfo:platform() == Idstring("PS4") or SystemInfo:platform() == Idstring("XB1")

function BlackMarketTweakData:init(tweak_data)
	self:_init_colors(tweak_data)
	self:_init_materials(tweak_data)
	self:_init_textures(tweak_data)
	self:_init_masks(tweak_data)
	self:_init_characters(tweak_data)
	self:_init_cash()
	self:_init_xp()
	self:_init_armors()
	self:_init_deployables(tweak_data)
	self:_init_bullets(tweak_data)
	self:_init_projectiles(tweak_data)
	self:_init_melee_weapons(tweak_data)
	self:_init_weapon_skins(tweak_data)
	self:_init_player_styles(tweak_data)
	self:_init_weapon_mods(tweak_data)
end

function BlackMarketTweakData:_get_character_groups()
	local characters_female = {
		"female_1",
		"sydney",
		"joy",
		"ecp_female"
	}
	local characters_female_big = {
		"bonnie",
		"ecp_male"
	}
	local characters_male = {
		"dallas",
		"wolf",
		"hoxton",
		"chains",
		"jowi",
		"old_hoxton",
		"dragan",
		"jacket",
		"sokol",
		"dragon",
		"bodhi",
		"jimmy",
		"chico",
		"myh"
	}
	local characters_male_big = {
		"wild",
		"max"
	}

	return characters_female, characters_female_big, characters_male, characters_male_big
end

function BlackMarketTweakData:print_missing_strings(skip_print_id)
end

function BlackMarketTweakData:_add_desc_from_name_macro(tweak_data)
	for id, data in pairs(tweak_data) do
		if data.name_id and not data.desc_id then
			data.desc_id = tostring(data.name_id) .. "_desc"
		end

		if not data.name_id then
			-- Nothing
		end
	end
end

function BlackMarketTweakData:_init_weapon_mods(tweak_data)
	if self.weapon_skins then
		tweak_data.weapon.factory:create_bonuses(tweak_data, self.weapon_skins)
	end

	self.weapon_mods = {}

	for id, data in pairs(tweak_data.weapon.factory.parts) do
		if is_nextgen_console then
			data.is_a_unlockable = nil
		end

		self.weapon_mods[id] = {
			max_in_inventory = data.is_a_unlockable and 1 or 2,
			pc = data.pc,
			pcs = data.pcs,
			dlc = data.dlc,
			dlcs = data.dlcs,
			name_id = data.name_id,
			desc_id = data.desc_id,
			infamous = data.infamous,
			value = data.stats and data.stats.value or 1,
			weight = data.weight,
			texture_bundle_folder = data.texture_bundle_folder,
			is_a_unlockable = data.is_a_unlockable,
			unatainable = data.unatainable,
			inaccessible = data.inaccessible
		}
	end

	self:_add_desc_from_name_macro(self.weapon_mods)
end

function BlackMarketTweakData:_init_characters(tweak_data)
	self.characters = {
		locked = {}
	}
	self.characters.locked.fps_unit = "units/payday2/characters/fps_mover/fps_mover"
	self.characters.locked.npc_unit = "units/payday2/characters/npc_criminals_suit_1/npc_criminals_suit_1"
	self.characters.locked.menu_unit = "units/payday2/characters/npc_criminals_suit_1/npc_criminals_suit_1_menu"
	self.characters.locked.sequence = "var_material_01"
	self.characters.locked.name_id = "bm_character_locked"
	self.characters.locked.dallas = {
		sequence = "var_mtr_dallas",
		installed = true,
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_dallas",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_dallas"
		}
	}
	self.characters.locked.wolf = {
		sequence = "var_mtr_wolf",
		installed = true,
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_wolf",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_wolf"
		}
	}
	self.characters.locked.hoxton = {
		sequence = "var_mtr_hoxton",
		installed = true,
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_hoxton",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_hoxton"
		}
	}
	self.characters.locked.chains = {
		sequence = "var_mtr_chains",
		installed = true,
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_chains",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_chains"
		}
	}
	self.characters.locked.jowi = {
		sequence = "var_mtr_john_wick",
		dlc = "pd2_clan",
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_john_wick",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_john_wick"
		}
	}
	self.characters.locked.old_hoxton = {
		sequence = "var_mtr_old_hoxton",
		dlc = "freed_old_hoxton",
		locks = {
			dlc = "pd2_clan",
			achievement = "bulldog_1"
		},
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_old_hoxton",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_old_hoxton"
		}
	}
	self.characters.locked.dragan = {
		dlc = "character_pack_dragan",
		texture_bundle_folder = "character_pack_dragan",
		sequence = "var_mtr_dragan",
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_dragan",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_dragan"
		}
	}
	self.characters.locked.jacket = {
		dlc = "hlm2_deluxe",
		texture_bundle_folder = "hlm2",
		sequence = "var_mtr_jacket",
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_jacket",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_jacket"
		}
	}
	self.characters.locked.sokol = {
		texture_bundle_folder = "character_pack_sokol",
		dlc = "character_pack_sokol",
		mask_on_sequence = "mask_on_sokol",
		mask_off_sequence = "mask_off_sokol",
		sequence = "var_mtr_sokol",
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_sokol",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_sokol"
		}
	}
	self.characters.locked.dragon = {
		dlc = "dragon",
		texture_bundle_folder = "dragon",
		sequence = "var_mtr_jiro",
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_jiro",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_jiro"
		}
	}
	self.characters.locked.bodhi = {
		texture_bundle_folder = "rip",
		sequence = "var_mtr_bodhi",
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_bodhi",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_bodhi"
		}
	}
	self.characters.locked.jimmy = {
		texture_bundle_folder = "coco",
		mask_on_sequence = "mask_on_jimmy",
		mask_off_sequence = "mask_off_jimmy",
		sequence = "var_mtr_jimmy",
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_jimmy",
			npc = "units/payday2/characters/npc_criminals_suit_1/mtr_jimmy"
		}
	}
	self.characters.female_1 = {
		fps_unit = "units/payday2/characters/fps_mover/fps_female_1_mover",
		npc_unit = "units/payday2/characters/npc_criminal_female_1/npc_criminal_female_1",
		menu_unit = "units/payday2/characters/npc_criminal_female_1/npc_criminal_female_1_menu",
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_fem1",
			npc = "units/payday2/characters/npc_criminal_female_1/mtr_fem1"
		},
		texture_bundle_folder = "character_pack_clover",
		sequence = "var_mtr_fem1",
		mask_on_sequence = "mask_on",
		mask_off_sequence = "mask_off",
		dlc = "character_pack_clover"
	}
	self.characters.bonnie = {
		fps_unit = "units/pd2_dlc_bonnie/characters/npc_criminal_bonnie/fps_bonnie_mover",
		npc_unit = "units/pd2_dlc_bonnie/characters/npc_criminal_bonnie/npc_criminal_bonnie",
		menu_unit = "units/pd2_dlc_bonnie/characters/npc_criminal_bonnie/npc_criminal_bonnie_menu",
		material_config = {
			fps = "units/payday2/characters/fps_criminals_suit_1/mtr_bonnie",
			npc = "units/pd2_dlc_bonnie/characters/npc_criminal_bonnie/mtr_bonnie"
		},
		texture_bundle_folder = "character_pack_bonnie",
		sequence = "var_mtr_bonnie",
		mask_on_sequence = "bonnie_mask_on",
		mask_off_sequence = "bonnie_mask_off",
		dlc = "pd2_clan"
	}
	self.characters.ai_hoxton = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/hoxton/npc_criminal_suit_hoxton",
		sequence = "var_mtr_hoxton"
	}
	self.characters.ai_chains = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/chains/npc_criminal_suit_chains",
		sequence = "var_mtr_chains"
	}
	self.characters.ai_dallas = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/dallas/npc_criminal_suit_dallas",
		sequence = "var_mtr_dallas"
	}
	self.characters.ai_wolf = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/wolf/npc_criminal_suit_wolf",
		sequence = "var_mtr_wolf"
	}
	self.characters.ai_jowi = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/jowi/npc_criminal_suit_jowi",
		sequence = "var_mtr_john_wick"
	}
	self.characters.ai_old_hoxton = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/old_hoxton/npc_criminal_suit_old_hoxton",
		sequence = "var_mtr_old_hoxton"
	}
	self.characters.ai_female_1 = {
		npc_unit = "units/payday2/characters/npc_criminal_female_1/fem1/npc_criminal_female_fem1",
		sequence = "var_mtr_fem1",
		mask_on_sequence = "mask_on",
		mask_off_sequence = "mask_off"
	}
	self.characters.ai_dragan = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/dragan/npc_criminal_suit_dragan",
		sequence = "var_mtr_dragan"
	}
	self.characters.ai_jacket = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/jacket/npc_criminal_suit_jacket",
		sequence = "var_mtr_jacket"
	}
	self.characters.ai_bonnie = {
		npc_unit = "units/pd2_dlc_bonnie/characters/npc_criminal_bonnie/fem1/npc_criminal_female_bonnie_1",
		sequence = "var_mtr_bonnie",
		mask_on_sequence = "bonnie_mask_on",
		mask_off_sequence = "bonnie_mask_off"
	}
	self.characters.ai_sokol = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/sokol/npc_criminal_suit_sokol",
		sequence = "var_mtr_sokol",
		mask_on_sequence = "mask_on_sokol",
		mask_off_sequence = "mask_off_sokol"
	}
	self.characters.ai_dragon = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/dragon/npc_criminal_suit_dragon",
		sequence = "var_mtr_jiro"
	}
	self.characters.ai_bodhi = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/bodhi/npc_criminal_suit_bodhi",
		sequence = "var_mtr_bodhi"
	}
	self.characters.ai_jimmy = {
		npc_unit = "units/payday2/characters/npc_criminals_suit_1/jimmy/npc_criminal_suit_jimmy",
		sequence = "var_mtr_jimmy"
	}
	self.characters.sydney = {
		fps_unit = "units/pd2_dlc_opera/characters/npc_criminals_fem_3/fps_sydney_mover",
		npc_unit = "units/pd2_dlc_opera/characters/npc_criminals_fem_3/npc_criminal_sydney",
		menu_unit = "units/pd2_dlc_opera/characters/npc_criminals_fem_3/npc_criminal_sydney_menu",
		material_config = {
			fps = "units/pd2_dlc_opera/characters/fps_criminals_fem_3/mtr_sydney",
			npc = "units/pd2_dlc_opera/characters/npc_criminals_fem_3/mtr_criminal_sydney"
		},
		texture_bundle_folder = "opera",
		sequence = "var_mtr_sydney",
		mask_on_sequence = "mask_on",
		mask_off_sequence = "mask_off",
		dlc = "opera"
	}
	self.characters.ai_sydney = {
		npc_unit = "units/pd2_dlc_opera/characters/npc_criminals_fem_3/fem3/npc_criminal_female_3",
		sequence = "var_mtr_sydney",
		mask_on_sequence = "mask_on",
		mask_off_sequence = "mask_off"
	}
	self.characters.wild = {
		fps_unit = "units/pd2_dlc_wild/characters/npc_criminals_wild_1/fps_wild_mover",
		npc_unit = "units/pd2_dlc_wild/characters/npc_criminals_wild_1/npc_criminal_wild_1",
		menu_unit = "units/pd2_dlc_wild/characters/npc_criminals_wild_1/npc_criminal_wild_1_menu",
		material_config = {
			fps = "units/pd2_dlc_wild/characters/fps_criminals_wild_1/mtr_wild",
			npc = "units/pd2_dlc_wild/characters/npc_criminals_wild_1/mtr_criminal_wild_1"
		},
		texture_bundle_folder = "wild",
		sequence = "var_mtr_wild",
		dlc = "wild"
	}
	self.characters.ai_wild = {
		npc_unit = "units/pd2_dlc_wild/characters/npc_criminals_wild_1/wild_1/npc_criminal_wild_1",
		sequence = "var_mtr_wild"
	}
	self.characters.chico = {
		fps_unit = "units/pd2_dlc_chico/characters/npc_criminals_terry/fps_terry_mover",
		npc_unit = "units/pd2_dlc_chico/characters/npc_criminals_terry/npc_criminal_terry",
		menu_unit = "units/pd2_dlc_chico/characters/npc_criminals_terry/npc_criminal_terry_menu",
		material_config = {
			fps = "units/pd2_dlc_chico/characters/fps_criminals_terry/mtr_terry",
			npc = "units/pd2_dlc_chico/characters/npc_criminals_terry/mtr_criminal_terry"
		},
		texture_bundle_folder = "chico",
		sequence = "var_mtr_terry",
		dlc = "chico"
	}
	self.characters.ai_chico = {
		npc_unit = "units/pd2_dlc_chico/characters/npc_criminals_terry/terry/npc_criminal_terry",
		sequence = "var_mtr_terry"
	}
	self.characters.max = {
		fps_unit = "units/pd2_dlc_max/characters/npc_criminals_max/fps_max_mover",
		npc_unit = "units/pd2_dlc_max/characters/npc_criminals_max/npc_criminal_max",
		menu_unit = "units/pd2_dlc_max/characters/npc_criminals_max/npc_criminal_max_menu",
		texture_bundle_folder = "max",
		sequence = "var_mtr_max",
		material_config = {
			{
				fps = "units/pd2_dlc_max/characters/fps_criminals_max/mtr_max",
				npc = "units/pd2_dlc_max/characters/npc_criminals_max/mtr_criminal_max_shirt_01"
			},
			{
				fps = "units/pd2_dlc_max/characters/fps_criminals_max/mtr_max",
				npc = "units/pd2_dlc_max/characters/npc_criminals_max/mtr_criminal_max_shirt_02"
			},
			{
				fps = "units/pd2_dlc_max/characters/fps_criminals_max/mtr_max",
				npc = "units/pd2_dlc_max/characters/npc_criminals_max/mtr_criminal_max_shirt_03"
			},
			{
				fps = "units/pd2_dlc_max/characters/fps_criminals_max/mtr_max",
				npc = "units/pd2_dlc_max/characters/npc_criminals_max/mtr_criminal_max_shirt_04"
			},
			{
				fps = "units/pd2_dlc_max/characters/fps_criminals_max/mtr_max",
				npc = "units/pd2_dlc_max/characters/npc_criminals_max/mtr_criminal_max_shirt_05"
			},
			{
				fps = "units/pd2_dlc_max/characters/fps_criminals_max/mtr_max",
				npc = "units/pd2_dlc_max/characters/npc_criminals_max/mtr_criminal_max_shirt_06"
			},
			{
				fps = "units/pd2_dlc_max/characters/fps_criminals_max/mtr_max",
				npc = "units/pd2_dlc_max/characters/npc_criminals_max/mtr_criminal_max"
			},
			{
				fps = "units/pd2_dlc_max/characters/fps_criminals_max/mtr_max",
				chance = 200,
				npc = "units/pd2_dlc_max/characters/npc_criminals_max/mtr_criminal_max_taco"
			},
			{
				fps = "units/pd2_dlc_max/characters/fps_criminals_max/mtr_max",
				chance = 50,
				npc = "units/pd2_dlc_max/characters/npc_criminals_max/mtr_criminal_max_snakeskin"
			},
			{
				fps = "units/pd2_dlc_max/characters/fps_criminals_max/mtr_max",
				chance = 50,
				npc = "units/pd2_dlc_max/characters/npc_criminals_max/mtr_criminal_max_pink"
			}
		}
	}
	self.characters.ai_max = {
		npc_unit = "units/pd2_dlc_max/characters/npc_criminals_max/max/npc_criminal_max",
		sequence = "var_mtr_max"
	}
	self.characters.joy = {
		fps_unit = "units/pd2_dlc_joy/characters/npc_criminals_joy_1/fps_joy_mover",
		npc_unit = "units/pd2_dlc_joy/characters/npc_criminals_joy_1/npc_criminal_joy_1",
		menu_unit = "units/pd2_dlc_joy/characters/npc_criminals_joy_1/npc_criminal_joy_1_menu",
		material_config = {
			fps = "units/pd2_dlc_joy/characters/fps_criminals_joy_1/mtr_joy",
			npc = "units/pd2_dlc_joy/characters/npc_criminals_joy_1/mtr_criminal_joy_1"
		},
		texture_bundle_folder = "joy",
		sequence = "var_mtr_joy",
		mask_on_sequence = "mask_on_joy",
		mask_off_sequence = "mask_off_joy"
	}
	self.characters.ai_joy = {
		npc_unit = "units/pd2_dlc_joy/characters/npc_criminals_joy_1/joy_1/npc_criminal_joy_1",
		sequence = "var_mtr_joy",
		mask_on_sequence = "mask_on_joy",
		mask_off_sequence = "mask_off_joy"
	}
	self.characters.myh = {
		fps_unit = "units/pd2_dlc_myh/characters/npc_criminals_myh/fps_myh_mover",
		npc_unit = "units/pd2_dlc_myh/characters/npc_criminals_myh/npc_criminal_myh",
		menu_unit = "units/pd2_dlc_myh/characters/npc_criminals_myh/npc_criminal_myh_menu",
		material_config = {
			fps = "units/pd2_dlc_myh/characters/fps_criminals_myh/mtr_myh",
			npc = "units/pd2_dlc_myh/characters/npc_criminals_myh/mtr_criminal_myh"
		},
		texture_bundle_folder = "myh",
		sequence = "var_mtr_myh"
	}
	self.characters.ai_myh = {
		npc_unit = "units/pd2_dlc_myh/characters/npc_criminals_myh/myh/npc_criminal_myh",
		sequence = "var_mtr_myh"
	}
	self.characters.ecp_female = {
		fps_unit = "units/pd2_dlc_ecp/characters/npc_criminals_ecp_female/fps_ecp_female_mover",
		npc_unit = "units/pd2_dlc_ecp/characters/npc_criminals_ecp_female/npc_criminal_ecp_female",
		menu_unit = "units/pd2_dlc_ecp/characters/npc_criminals_ecp_female/npc_criminal_ecp_female_menu",
		material_config = {
			fps = "units/pd2_dlc_ecp/characters/fps_criminals_ecp_female/mtr_ecp_female",
			npc = "units/pd2_dlc_ecp/characters/npc_criminals_ecp_female/mtr_criminal_ecp_female"
		},
		texture_bundle_folder = "ecp",
		sequence = "var_mtr_ecp_female",
		mask_on_sequence = "mask_on_ecp_female",
		mask_off_sequence = "mask_off_ecp_female",
		dlc = "ecp"
	}
	self.characters.ecp_male = {
		fps_unit = "units/pd2_dlc_ecp/characters/npc_criminals_ecp_male/fps_ecp_male_mover",
		npc_unit = "units/pd2_dlc_ecp/characters/npc_criminals_ecp_male/npc_criminal_ecp_male",
		menu_unit = "units/pd2_dlc_ecp/characters/npc_criminals_ecp_male/npc_criminal_ecp_male_menu",
		material_config = {
			fps = "units/pd2_dlc_ecp/characters/fps_criminals_ecp_male/mtr_ecp_male",
			npc = "units/pd2_dlc_ecp/characters/npc_criminals_ecp_male/mtr_criminal_ecp_male"
		},
		texture_bundle_folder = "ecp",
		sequence = "var_mtr_ecp_male",
		mask_on_sequence = "mask_on_ecp_male",
		mask_off_sequence = "mask_off_ecp_male",
		dlc = "ecp"
	}
	self.characters.ai_ecp_female = {
		npc_unit = "units/pd2_dlc_ecp/characters/npc_criminals_ecp_female/ecp_female/npc_criminal_ecp_female",
		sequence = "var_mtr_ecp_female",
		mask_on_sequence = "mask_on_ecp_female",
		mask_off_sequence = "mask_off_ecp_female"
	}
	self.characters.ai_ecp_male = {
		npc_unit = "units/pd2_dlc_ecp/characters/npc_criminals_ecp_male/ecp_male/npc_criminal_ecp_male",
		sequence = "var_mtr_ecp_male",
		mask_on_sequence = "mask_on_ecp_male",
		mask_off_sequence = "mask_off_ecp_male"
	}
	local free_dlcs = tweak_data:free_dlc_list()

	for _, data in pairs(self.characters) do
		if free_dlcs[data.dlc] then
			data.dlc = nil
		end
	end

	for _, data in pairs(self.characters.locked) do
		if free_dlcs[data.dlc] then
			data.dlc = nil
		end
	end
end

function BlackMarketTweakData:_init_cash()
	self.cash = {
		cash10 = {}
	}
	self.cash.cash10.name_id = "bm_csh_cash10"
	self.cash.cash10.value_id = "cash10"
	self.cash.cash10.multiplier = 1
	self.cash.cash10.pcs = {
		10,
		40
	}
	self.cash.cash20 = {
		name_id = "bm_csh_cash20",
		value_id = "cash20",
		multiplier = 1,
		pcs = {
			20,
			40
		}
	}
	self.cash.cash30 = {
		name_id = "bm_csh_cash30",
		multiplier = 1,
		value_id = "cash30",
		pcs = {
			30,
			40
		}
	}
	self.cash.cash40 = {
		name_id = "bm_csh_cash40",
		multiplier = 1,
		value_id = "cash40",
		pcs = {
			20,
			30,
			40
		}
	}
	self.cash.cash50 = {
		name_id = "bm_csh_cash50",
		multiplier = 1,
		value_id = "cash50",
		pcs = {
			30,
			40,
			50
		}
	}
	self.cash.cash60 = {
		name_id = "bm_csh_cash60",
		value_id = "cash60",
		multiplier = 1,
		pcs = {
			40,
			50,
			60
		}
	}
	self.cash.cash70 = {
		name_id = "bm_csh_cash70",
		value_id = "cash70",
		multiplier = 1,
		pcs = {
			50,
			60,
			70
		}
	}
	self.cash.cash80 = {
		name_id = "bm_csh_cash80",
		value_id = "cash80",
		multiplier = 1,
		pcs = {
			60,
			70,
			80
		}
	}
	self.cash.cash90 = {
		name_id = "bm_csh_cash90",
		value_id = "cash90",
		multiplier = 1,
		pcs = {
			70,
			80,
			90
		}
	}
	self.cash.cash100 = {
		name_id = "bm_csh_cash100",
		value_id = "cash100",
		multiplier = 1,
		pcs = {
			80,
			90,
			100
		}
	}
	self.cash.cash_preorder = {
		name_id = "bm_csh_cash_preorder",
		value_id = "cash_preorder",
		multiplier = 1.2,
		dlc = "preorder"
	}

	if is_nextgen_console then
		self.cash.xone_bonus = {
			name_id = "bm_csh_cash_xone",
			value_id = "xone_bonus",
			multiplier = 1
		}
	end
end

function BlackMarketTweakData:_init_xp()
	self.xp = {
		xp10 = {}
	}
	self.xp.xp10.name_id = "bm_exp_xp10"
	self.xp.xp10.value_id = "xp10"
	self.xp.xp10.multiplier = 1
	self.xp.xp10.pcs = {
		10,
		40
	}
	self.xp.xp20 = {
		name_id = "bm_exp_xp20",
		value_id = "xp20",
		multiplier = 1,
		pcs = {
			20,
			40
		}
	}
	self.xp.xp30 = {
		name_id = "bm_exp_xp30",
		multiplier = 1,
		value_id = "xp30",
		pcs = {
			30,
			40
		}
	}
	self.xp.xp40 = {
		name_id = "bm_exp_xp40",
		multiplier = 1,
		value_id = "xp40",
		pcs = {
			20,
			30,
			40
		}
	}
	self.xp.xp50 = {
		name_id = "bm_exp_xp50",
		multiplier = 1,
		value_id = "xp50",
		pcs = {
			30,
			40,
			50
		}
	}
	self.xp.xp60 = {
		name_id = "bm_exp_xp60",
		value_id = "xp60",
		multiplier = 1,
		pcs = {
			40,
			50,
			60
		}
	}
	self.xp.xp70 = {
		name_id = "bm_exp_xp70",
		value_id = "xp70",
		multiplier = 1,
		pcs = {
			50,
			60,
			70
		}
	}
	self.xp.xp80 = {
		name_id = "bm_exp_xp80",
		value_id = "xp80",
		multiplier = 1,
		pcs = {
			60,
			70,
			80
		}
	}
	self.xp.xp90 = {
		name_id = "bm_exp_xp90",
		value_id = "xp90",
		multiplier = 1,
		pcs = {
			70,
			80,
			90
		}
	}
	self.xp.xp100 = {
		name_id = "bm_exp_xp100",
		value_id = "xp100",
		multiplier = 1,
		pcs = {
			80,
			90,
			100
		}
	}
end

function BlackMarketTweakData:_init_armors()
	self.armors = {
		level_1 = {}
	}
	self.armors.level_1.name_id = "bm_armor_level_1"
	self.armors.level_1.sequence = "var_model_01"
	self.armors.level_1.upgrade_level = 1
	self.armors.level_2 = {
		name_id = "bm_armor_level_2",
		sequence = "var_model_02",
		upgrade_level = 2
	}
	self.armors.level_3 = {
		name_id = "bm_armor_level_3",
		sequence = "var_model_03",
		upgrade_level = 3
	}
	self.armors.level_4 = {
		name_id = "bm_armor_level_4",
		sequence = "var_model_04",
		upgrade_level = 4
	}
	self.armors.level_5 = {
		name_id = "bm_armor_level_5",
		sequence = "var_model_05",
		upgrade_level = 5
	}
	self.armors.level_6 = {
		name_id = "bm_armor_level_6",
		sequence = "var_model_06",
		upgrade_level = 6
	}
	self.armors.level_7 = {
		name_id = "bm_armor_level_7",
		sequence = "var_model_07",
		upgrade_level = 7
	}

	self:_add_desc_from_name_macro(self.armors)
end

function BlackMarketTweakData:_init_deployables(tweak_data)
	self.deployables = {
		doctor_bag = {}
	}
	self.deployables.doctor_bag.name_id = "bm_equipment_doctor_bag"
	self.deployables.ammo_bag = {
		name_id = "bm_equipment_ammo_bag"
	}
	self.deployables.ecm_jammer = {
		name_id = "bm_equipment_ecm_jammer"
	}
	self.deployables.sentry_gun = {
		name_id = "bm_equipment_sentry_gun"
	}
	self.deployables.sentry_gun_silent = {
		name_id = "bm_equipment_sentry_gun_silent"
	}
	self.deployables.trip_mine = {
		name_id = "bm_equipment_trip_mine"
	}
	self.deployables.armor_kit = {
		name_id = "bm_equipment_armor_kit"
	}
	self.deployables.first_aid_kit = {
		name_id = "bm_equipment_first_aid_kit"
	}
	self.deployables.bodybags_bag = {
		name_id = "bm_equipment_bodybags_bag"
	}

	self:_add_desc_from_name_macro(self.deployables)
end

function BlackMarketTweakData:get_mask_icon(mask_id, character)
	if character and mask_id == "character_locked" then
		local character_name = CriminalsManager.convert_old_to_new_character_workname(character)
		mask_id = tweak_data.blackmarket.masks.character_locked[character_name] or mask_id
	end

	local guis_catalog = "guis/"
	local bundle_folder = tweak_data.blackmarket.masks[mask_id] and tweak_data.blackmarket.masks[mask_id].texture_bundle_folder

	if bundle_folder then
		guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
	end

	return guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. tostring(mask_id)
end

function BlackMarketTweakData:get_character_icon(character)
	local character_name = CriminalsManager.convert_old_to_new_character_workname(character)
	local guis_catalog = "guis/"
	local character_table = tweak_data.blackmarket.characters[character] or tweak_data.blackmarket.characters.locked[character_name]
	local bundle_folder = character_table and character_table.texture_bundle_folder

	if bundle_folder then
		guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
	end

	return guis_catalog .. "textures/pd2/blackmarket/icons/characters/" .. character_name
end
