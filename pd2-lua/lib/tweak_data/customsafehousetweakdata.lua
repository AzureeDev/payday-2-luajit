CustomSafehouseTweakData = CustomSafehouseTweakData or class()

function CustomSafehouseTweakData:init(tweak_data)
	self.prices = {
		rooms = {
			0,
			12,
			24
		},
		weapon_mod = 6,
		event_weapon_mod = 18,
		crew_boost = 2,
		crew_ability = 6
	}
	self.rewards = {
		initial = self.prices.rooms[2] * 1,
		challenge = 6,
		daily_complete = 6,
		raid = 6,
		experience_ratio = 1000000
	}
	self.level_limit = 25

	self:_init_heisters(tweak_data)
	self:_init_safehouse_contractors(tweak_data)
	self:_init_safehouse_rooms(tweak_data)
	self:_init_trophies(tweak_data)
	self:_init_dailies(tweak_data)
	self:_init_map(tweak_data)
	self:_init_uno()

	self.daily_redirects = {
		daily_sewers = "daily_helicopter",
		daily_tapes = "daily_spacetime"
	}
end

function CustomSafehouseTweakData:_init_heisters(tweak_data)
	self.heisters = {
		base = {}
	}
	self.heisters.base.idle_line_dist = 500
	self.heisters.base.idle_line_time = {
		15,
		20
	}
	self.heisters.base.answer_lines = {
		{
			sound_event = "Play_{voice}_answering",
			priority = 0
		}
	}
	self.heisters.base.idle_lines = {
		{
			sound_event = "Play_{voice}_idle",
			priority = 0
		}
	}
	self.heisters.dallas = clone(self.heisters.base)
	self.heisters.dallas.character_material = "var_mtr_dallas"
	self.heisters.dallas.voice = self:get_voice(tweak_data, "russian")
	self.heisters.chains = clone(self.heisters.base)
	self.heisters.chains.character_material = "var_mtr_chains"
	self.heisters.chains.voice = self:get_voice(tweak_data, "spanish")
	self.heisters.hoxton = clone(self.heisters.base)
	self.heisters.hoxton.character_material = "var_mtr_hoxton"
	self.heisters.hoxton.voice = self:get_voice(tweak_data, "american")
	self.heisters.hoxton.answer_lines = {
		{
			sound_event = "Play_{voice}_answering",
			priority = 0
		},
		{
			sound_event = "Play_{voice}_answering_longfellow",
			priority = 10,
			requirements = {
				tiers = {
					3
				},
				trophies = {
					"trophy_longfellow"
				}
			}
		}
	}
	self.heisters.wolf = clone(self.heisters.base)
	self.heisters.wolf.character_material = "var_mtr_wolf"
	self.heisters.wolf.voice = self:get_voice(tweak_data, "german")
	self.heisters.jowi = clone(self.heisters.base)
	self.heisters.jowi.character_material = "var_mtr_john_wick"
	self.heisters.jowi.voice = self:get_voice(tweak_data, "jowi")
	self.heisters.old_hoxton = clone(self.heisters.base)
	self.heisters.old_hoxton.character_material = "var_mtr_old_hoxton"
	self.heisters.old_hoxton.voice = self:get_voice(tweak_data, "old_hoxton")
	self.heisters.clover = clone(self.heisters.base)
	self.heisters.clover.character_material = "var_mtr_fem1"
	self.heisters.clover.voice = self:get_voice(tweak_data, "female_1")
	self.heisters.dragan = clone(self.heisters.base)
	self.heisters.dragan.character_material = "var_mtr_dragan"
	self.heisters.dragan.voice = self:get_voice(tweak_data, "dragan")
	self.heisters.dragan.anim_lines = {
		{
			sound_event = "Play_{voice}_idle_phone",
			line_type = "idle",
			anim_value = "talking_on_phone"
		}
	}
	self.heisters.dragan.anim_blocks = {
		{
			block = "answering",
			anim_value = "talking_on_phone"
		}
	}
	self.heisters.dragan.idle_limit = 1
	self.heisters.jacket = clone(self.heisters.base)
	self.heisters.jacket.character_material = "var_mtr_jacket"
	self.heisters.jacket.voice = self:get_voice(tweak_data, "jacket")
	self.heisters.bonnie = clone(self.heisters.base)
	self.heisters.bonnie.character_material = "var_mtr_bonnie"
	self.heisters.bonnie.voice = self:get_voice(tweak_data, "bonnie")
	self.heisters.sokol = clone(self.heisters.base)
	self.heisters.sokol.character_material = "var_mtr_sokol"
	self.heisters.sokol.voice = self:get_voice(tweak_data, "sokol")
	self.heisters.dragon = clone(self.heisters.base)
	self.heisters.dragon.character_material = "var_mtr_jiro"
	self.heisters.dragon.voice = self:get_voice(tweak_data, "dragon")
	self.heisters.dragon.answer_lines = {
		{
			sound_event = "Play_{voice}_answering",
			priority = 0
		},
		{
			sound_event = "Play_{voice}_answering_glace",
			priority = 100,
			requirements = {
				trophies = {
					"trophy_glace_completion"
				}
			}
		}
	}
	self.heisters.dragon.idle_lines = {
		{
			sound_event = "Play_{voice}_idle",
			priority = 0
		},
		{
			sound_event = "Play_{voice}_idle_glace",
			priority = 100,
			requirements = {
				trophies = {
					"trophy_glace_completion"
				}
			}
		}
	}
	self.heisters.bodhi = clone(self.heisters.base)
	self.heisters.bodhi.character_material = "var_mtr_bodhi"
	self.heisters.bodhi.voice = self:get_voice(tweak_data, "bodhi")
	self.heisters.jimmy = clone(self.heisters.base)
	self.heisters.jimmy.character_material = "var_mtr_jimmy"
	self.heisters.jimmy.voice = self:get_voice(tweak_data, "jimmy")
	self.heisters.sydney = clone(self.heisters.base)
	self.heisters.sydney.character_material = "var_mtr_sydney"
	self.heisters.sydney.voice = self:get_voice(tweak_data, "sydney")
	self.heisters.wild = clone(self.heisters.base)
	self.heisters.wild.character_material = "var_mtr_wild"
	self.heisters.wild.voice = self:get_voice(tweak_data, "wild")
	self.heisters.terry = clone(self.heisters.base)
	self.heisters.terry.character_material = "var_mtr_terry"
	self.heisters.terry.voice = self:get_voice(tweak_data, "chico")
	self.heisters.max = clone(self.heisters.base)
	self.heisters.max.character_material = "var_mtr_max"
	self.heisters.max.voice = self:get_voice(tweak_data, "max")
	self.heisters.joy = clone(self.heisters.base)
	self.heisters.joy.character_material = "var_mtr_joy"
	self.heisters.joy.voice = self:get_voice(tweak_data, "joy")
	self.heisters.myh = clone(self.heisters.base)
	self.heisters.myh.character_material = "var_mtr_myh"
	self.heisters.myh.voice = self:get_voice(tweak_data, "myh")
	self.heisters.ecp_female = clone(self.heisters.base)
	self.heisters.ecp_female.character_material = "var_mtr_ecp_female"
	self.heisters.ecp_female.voice = self:get_voice(tweak_data, "ecp_female")
	self.heisters.ecp_male = clone(self.heisters.base)
	self.heisters.ecp_male.character_material = "var_mtr_ecp_male"
	self.heisters.ecp_male.voice = self:get_voice(tweak_data, "ecp_male")
	self.heisters.butler = clone(self.heisters.base)
	self.heisters.butler.character_material = ""
	self.heisters.vlad = clone(self.heisters.base)
	self.heisters.vlad.voice = "rb1"
	self.heisters.vlad.idle_offset = 20
end

function CustomSafehouseTweakData:get_voice(tweak_data, character_name)
	for i, data in ipairs(tweak_data.criminals.characters) do
		if data.name == character_name then
			return data.static_data.voice
		end
	end
end

function CustomSafehouseTweakData:_init_safehouse_contractors(tweak_data)
	local heister_weighting = 98 / #tweak_data.criminals.character_names
	local butler_weighting = 2
	self.contractors = {}

	table.insert(self.contractors, {
		character = "russian",
		name_id = "menu_russian",
		image_name = "dallas",
		character_name = "dallas",
		weighting = heister_weighting,
		dailies = {
			"daily_classics",
			"daily_discord"
		}
	})
	table.insert(self.contractors, {
		character = "spanish",
		name_id = "menu_spanish",
		image_name = "chains",
		character_name = "chains",
		weighting = heister_weighting,
		dailies = {
			"daily_grenades",
			"daily_phobia"
		}
	})
	table.insert(self.contractors, {
		character = "german",
		name_id = "menu_german",
		image_name = "wolf",
		character_name = "wolf",
		weighting = heister_weighting,
		dailies = {
			"daily_fwtd",
			"daily_gears"
		}
	})
	table.insert(self.contractors, {
		character = "american",
		name_id = "menu_american",
		image_name = "houston",
		character_name = "houston",
		weighting = heister_weighting,
		dailies = {
			"daily_mortage",
			"daily_art"
		}
	})
	table.insert(self.contractors, {
		character = "old_hoxton",
		name_id = "menu_old_hoxton",
		image_name = "hoxton",
		weighting = heister_weighting,
		dailies = {
			"daily_spacetime",
			"daily_tapes"
		}
	})
	table.insert(self.contractors, {
		character = "jowi",
		name_id = "menu_jowi",
		image_name = "john",
		weighting = heister_weighting,
		dailies = {
			"daily_akimbo",
			"daily_professional"
		}
	})
	table.insert(self.contractors, {
		character = "female_1",
		name_id = "menu_clover",
		image_name = "clover",
		character_name = "clover",
		weighting = heister_weighting,
		dailies = {
			"daily_toast",
			"daily_heirloom"
		}
	})
	table.insert(self.contractors, {
		character = "dragan",
		name_id = "menu_dragan",
		image_name = "dragan",
		weighting = heister_weighting,
		dailies = {
			"daily_sewers",
			"daily_helicopter"
		}
	})
	table.insert(self.contractors, {
		character = "jacket",
		name_id = "menu_jacket",
		image_name = "jacket",
		weighting = heister_weighting,
		dailies = {
			"daily_night_out",
			"daily_secret_identity"
		}
	})
	table.insert(self.contractors, {
		character = "sokol",
		name_id = "menu_sokol",
		image_name = "sokol",
		weighting = heister_weighting,
		dailies = {
			"daily_rush",
			"daily_naked"
		}
	})
	table.insert(self.contractors, {
		character = "bonnie",
		name_id = "menu_bonnie",
		image_name = "bonnie",
		weighting = heister_weighting,
		dailies = {
			"daily_lodsofemone",
			"daily_hangover"
		}
	})
	table.insert(self.contractors, {
		character = "dragon",
		name_id = "menu_dragon",
		image_name = "jiro",
		weighting = heister_weighting,
		dailies = {
			"daily_honorable",
			"daily_ninja"
		}
	})
	table.insert(self.contractors, {
		character = "bodhi",
		name_id = "menu_bodhi",
		image_name = "bodhi",
		weighting = heister_weighting,
		dailies = {
			"daily_cake",
			"daily_my_bodhi_is_ready"
		}
	})
	table.insert(self.contractors, {
		character = "jimmy",
		name_id = "menu_jimmy",
		image_name = "jimmy",
		weighting = heister_weighting,
		dailies = {
			"daily_tasty",
			"daily_candy"
		}
	})
	table.insert(self.contractors, {
		character = "sydney",
		name_id = "menu_sydney",
		image_name = "sydney",
		weighting = heister_weighting,
		dailies = {
			"daily_dosh",
			"daily_snake"
		}
	})
	table.insert(self.contractors, {
		character = "wild",
		name_id = "menu_wild",
		image_name = "rust",
		weighting = heister_weighting,
		dailies = {
			"daily_coke_run",
			"daily_whats_stealth"
		}
	})
	table.insert(self.contractors, {
		character = "terry",
		name_id = "menu_terry",
		weighting = 0,
		image_name = "terry",
		dailies = {}
	})
	table.insert(self.contractors, {
		name_id = "menu_butler",
		character = "butler",
		weighting = butler_weighting,
		dailies = {}
	})
end

function CustomSafehouseTweakData:_init_safehouse_rooms(tweak_data)
	self.rooms = {}

	table.insert(self.rooms, {
		title_id = "menu_cs_title_dallas",
		tier_max = 3,
		name_id = "menu_russian",
		room_id = "russian",
		help_id = "menu_cs_help_dallas",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_dallas_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_dallas_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_dallas_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_chains",
		tier_max = 3,
		name_id = "menu_spanish",
		room_id = "spanish",
		help_id = "menu_cs_help_chains",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_chains_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_chains_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_chains_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_wolf",
		tier_max = 3,
		name_id = "menu_german",
		room_id = "german",
		help_id = "menu_cs_help_wolf",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_wolf_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_wolf_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_wolf_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_houston",
		tier_max = 3,
		name_id = "menu_american",
		room_id = "american",
		help_id = "menu_cs_help_houston",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_houston_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_houston_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_houston_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_hoxton",
		tier_max = 3,
		name_id = "menu_old_hoxton",
		room_id = "old_hoxton",
		help_id = "menu_cs_help_hoxton",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_hoxton_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_hoxton_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_hoxton_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_jowi",
		tier_max = 3,
		name_id = "menu_jowi",
		room_id = "jowi",
		help_id = "menu_cs_help_jowi",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_wick_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_wick_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_wick_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_clover",
		tier_max = 3,
		name_id = "menu_clover",
		room_id = "clover",
		help_id = "menu_cs_help_clover",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_clover_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_clover_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_clover_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_dragan",
		tier_max = 3,
		name_id = "menu_dragan",
		room_id = "dragan",
		help_id = "menu_cs_help_dragan",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_dragan_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_dragan_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_dragan_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_jacket",
		tier_max = 3,
		name_id = "menu_jacket",
		room_id = "jacket",
		help_id = "menu_cs_help_jacket",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_jacket_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_jacket_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_jacket_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_sokol",
		tier_max = 3,
		name_id = "menu_sokol",
		room_id = "sokol",
		help_id = "menu_cs_help_sokol",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_sokol_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_sokol_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_sokol_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_bonnie",
		tier_max = 3,
		name_id = "menu_bonnie",
		room_id = "bonnie",
		help_id = "menu_cs_help_bonnie",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_bonnie_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_bonnie_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_bonnie_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_dragon",
		tier_max = 3,
		name_id = "menu_dragon",
		room_id = "dragon",
		help_id = "menu_cs_help_dragon",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_jiro_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_jiro_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_jiro_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_bodhi",
		tier_max = 3,
		name_id = "menu_bodhi",
		room_id = "bodhi",
		help_id = "menu_cs_help_bodhi",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_bodhi_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_bodhi_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_bodhi_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_jimmy",
		tier_max = 3,
		name_id = "menu_jimmy",
		room_id = "jimmy",
		help_id = "menu_cs_help_jimmy",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_jimmy_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_jimmy_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_jimmy_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_sydney",
		tier_max = 3,
		name_id = "menu_sydney",
		room_id = "sydney",
		help_id = "menu_cs_help_sydney",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_sydney_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_sydney_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_sydney_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_rust",
		tier_max = 3,
		name_id = "menu_wild",
		room_id = "wild",
		help_id = "menu_cs_help_rust",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_rust_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_rust_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_rust_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_terry",
		tier_max = 3,
		name_id = "menu_terry",
		room_id = "terry",
		help_id = "menu_cs_help_terry",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_scarface_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_scarface_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_scarface_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_max",
		tier_max = 3,
		name_id = "menu_max",
		room_id = "max",
		help_id = "menu_cs_help_max",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_max_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_max_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_max_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_joy",
		tier_max = 3,
		name_id = "menu_joy",
		room_id = "joy",
		help_id = "menu_cs_help_joy",
		images = {
			"guis/dlcs/joy/textures/pd2/rooms/safehouse_room_preview_joy_lvl1",
			"guis/dlcs/joy/textures/pd2/rooms/safehouse_room_preview_joy_lvl2",
			"guis/dlcs/joy/textures/pd2/rooms/safehouse_room_preview_joy_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_myh",
		tier_max = 3,
		name_id = "menu_myh",
		room_id = "myh",
		help_id = "menu_cs_help_myh",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_duke_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_duke_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_duke_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_ecp",
		tier_max = 3,
		name_id = "menu_ecp",
		room_id = "ecp",
		help_id = "menu_cs_help_ecp",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_ecp_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_ecp_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_ecp_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_vault",
		tier_max = 3,
		name_id = "menu_cs_vault",
		room_id = "vault",
		help_id = "menu_cs_help_vault",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_vault_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_vault_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_vault_lvl3"
		}
	})
	table.insert(self.rooms, {
		title_id = "menu_cs_title_common_room",
		tier_max = 3,
		name_id = "menu_cs_common_room",
		room_id = "livingroom",
		help_id = "menu_cs_help_common_room",
		images = {
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_common_rooms_lvl1",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_common_rooms_lvl2",
			"guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_common_rooms_lvl3"
		}
	})
end

function CustomSafehouseTweakData:_create_objective(data)
	local save_values = {
		"achievement_id",
		"progress_id",
		"completed",
		"progress"
	}

	if data.save_values then
		for idx, value in ipairs(data.save_values) do
			table.insert(save_values, value)
		end
	end

	local obj = {
		progress = 0,
		completed = false,
		displayed = true,
		achievement_id = data.achievement_id,
		name_id = data.name_id,
		desc_id = data.desc_id,
		progress_id = data.progress_id,
		max_progress = data.progress_id and data.max_progress or 1,
		verify = data.verify,
		save_values = save_values
	}

	return obj
end

function CustomSafehouseTweakData:_achievement(achievement_id, data)
	data = data or {}
	data.achievement_id = achievement_id

	return self:_create_objective(data)
end

function CustomSafehouseTweakData:_progress(progress_id, max_progress, data)
	data = data or {}
	data.progress_id = progress_id
	data.max_progress = max_progress or 1

	return self:_create_objective(data)
end

function CustomSafehouseTweakData:_init_trophies(tweak_data)
	self.trophies = {}

	table.insert(self.trophies, {
		name_id = "trophy_falcogini",
		image_id = "safehouse_trophies_preview_falcogini",
		objective_id = "trophy_falcogini_objective",
		id = "trophy_falcogini",
		desc_id = "trophy_falcogini_desc",
		objectives = {
			self:_progress("trophy_car_shop", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_dartboard",
		image_id = "safehouse_trophies_preview_dartboard",
		objective_id = "trophy_dartboard_objective",
		id = "trophy_dartboard",
		desc_id = "trophy_dartboard_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_headshots", 500, {
				name_id = "trophy_dartboard_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_hockey_team",
		image_id = "safehouse_trophies_preview_hockey_team",
		objective_id = "trophy_hockey_team_objective",
		id = "trophy_hockey_team",
		desc_id = "trophy_hockey_team_desc",
		objectives = {
			self:_achievement("the_first_line")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_escape_van",
		image_id = "safehouse_trophies_preview_escape_van",
		objective_id = "trophy_escape_van_objective",
		id = "trophy_escape_van",
		desc_id = "trophy_escape_van_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_escapes", 10, {
				name_id = "trophy_escape_van_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_meth_cookbook",
		image_id = "safehouse_trophies_preview_meth_cookbook",
		objective_id = "trophy_meth_cookbook_objective",
		id = "trophy_meth_cookbook",
		desc_id = "trophy_meth_cookbook_desc",
		objectives = {
			self:_achievement("voff_5")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_diamonds",
		image_id = "safehouse_trophies_preview_diamonds",
		objective_id = "trophy_diamonds_objective",
		id = "trophy_diamonds",
		desc_id = "trophy_diamonds_desc",
		objectives = {
			self:_progress("trophy_diamond_store_heist", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_stealth",
		image_id = "safehouse_trophies_preview_stealth",
		objective_id = "trophy_stealth_objective",
		id = "trophy_stealth",
		desc_id = "trophy_stealth_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_stealth", 15, {
				verify = "_verify_unique_heist",
				name_id = "trophy_stealth_progress",
				save_values = {
					"completed_heists"
				}
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_tiara",
		image_id = "safehouse_trophies_preview_tiara",
		objective_id = "trophy_tiara_objective",
		id = "trophy_tiara",
		desc_id = "trophy_tiara_desc",
		objectives = {
			self:_progress("trophy_tiara", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_hobo_knife",
		image_id = "safehouse_trophies_preview_hobo_knife",
		objective_id = "trophy_hobo_knife_objective",
		id = "trophy_hobo_knife",
		desc_id = "trophy_hobo_knife_desc",
		objectives = {
			self:_achievement("sinus_1")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_transports",
		image_id = "safehouse_trophies_preview_transports",
		objective_id = "trophy_transports_objective",
		id = "trophy_transports",
		desc_id = "trophy_transports_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_transport_crossroads", 1, {
				name_id = "heist_arm_cro"
			}),
			self:_progress("trophy_transport_downtown", 1, {
				name_id = "heist_arm_hcm"
			}),
			self:_progress("trophy_transport_harbor", 1, {
				name_id = "heist_arm_fac"
			}),
			self:_progress("trophy_transport_park", 1, {
				name_id = "heist_arm_par"
			}),
			self:_progress("trophy_transport_underpass", 1, {
				name_id = "heist_arm_und"
			}),
			self:_progress("trophy_transport_train", 1, {
				name_id = "heist_arm_for"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_golden_grin",
		image_id = "safehouse_trophies_preview_golden_grin",
		objective_id = "trophy_golden_grin_objective",
		id = "trophy_golden_grin",
		desc_id = "trophy_golden_grin_desc",
		objectives = {
			self:_progress("trophy_golden_grin", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_pacifier",
		image_id = "safehouse_trophies_preview_pacifier",
		objective_id = "trophy_pacifier_objective",
		id = "trophy_pacifier",
		desc_id = "trophy_pacifier_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_basics_stealth", 1, {
				name_id = "heist_short1"
			}),
			self:_progress("trophy_basics_loud", 1, {
				name_id = "heist_short2"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_discoball",
		image_id = "safehouse_trophies_preview_discoball",
		objective_id = "trophy_discoball_objective",
		id = "trophy_discoball",
		desc_id = "trophy_discoball_desc",
		objectives = {
			self:_progress("trophy_nightclub_dw", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_boxing_gloves",
		image_id = "safehouse_trophies_preview_boxing_gloves",
		objective_id = "trophy_boxing_gloves_objective",
		id = "trophy_boxing_gloves",
		desc_id = "trophy_boxing_gloves_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_knockouts", 5, {
				name_id = "trophy_boxing_gloves_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_ring",
		image_id = "safehouse_trophies_preview_ring",
		objective_id = "trophy_ring_objective",
		id = "trophy_ring",
		desc_id = "trophy_ring_desc",
		objectives = {
			self:_achievement("voff_4")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_dozer_helmet",
		image_id = "safehouse_trophies_preview_dozer_helmet",
		objective_id = "trophy_dozer_helmet_objective",
		id = "trophy_dozer_helmet",
		desc_id = "trophy_dozer_helmet_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_special_kills", 100, {
				name_id = "trophy_dozer_helmet_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_goat",
		image_id = "safehouse_trophies_preview_goat",
		objective_id = "trophy_goat_objective",
		id = "trophy_goat",
		desc_id = "trophy_goat_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_goats_extracted", 25, {
				name_id = "trophy_goat_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_tfturret",
		image_id = "safehouse_trophies_preview_tfturret",
		objective_id = "trophy_tfturret_objective",
		id = "trophy_tfturret",
		desc_id = "trophy_tfturret_desc",
		objectives = {
			self:_progress("trophy_tfturret", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_train_bomb",
		image_id = "safehouse_trophies_preview_train_bomb",
		objective_id = "trophy_train_bomb_objective",
		id = "trophy_train_bomb",
		desc_id = "trophy_train_bomb_desc",
		objectives = {
			self:_achievement("trophy_train_bomb")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_computer",
		image_id = "safehouse_trophies_preview_computer",
		objective_id = "trophy_computer_objective",
		id = "trophy_computer",
		desc_id = "trophy_computer_desc",
		objectives = {
			self:_progress("trophy_ed_computer_full_hack", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_longfellow",
		image_id = "safehouse_trophies_preview_longfellow",
		objective_id = "trophy_longfellow_objective",
		id = "trophy_longfellow",
		desc_id = "trophy_longfellow_desc",
		objectives = {
			self:_progress("trophy_shoutout", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_bank_heists",
		image_id = "safehouse_trophies_preview_bank_heists",
		objective_id = "trophy_bank_heists_objective",
		id = "trophy_bank_heists",
		desc_id = "trophy_bank_heists_desc",
		objectives = {
			self:_progress("trophy_bank_heists", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_carshop_stealth",
		image_id = "safehouse_trophies_preview_carshop_stealth",
		objective_id = "trophy_carshop_stealth_objective",
		id = "trophy_carshop_stealth",
		desc_id = "trophy_carshop_stealth_desc",
		objectives = {
			self:_progress("trophy_carshop_stealth", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_ace",
		image_id = "safehouse_trophies_preview_ace",
		objective_id = "trophy_ace_objective",
		id = "trophy_ace",
		desc_id = "trophy_ace_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_ace", 100, {
				name_id = "trophy_ace_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_washington",
		image_id = "safehouse_trophies_preview_hoxton_statue",
		objective_id = "trophy_washington_objective",
		id = "trophy_washington",
		desc_id = "trophy_washington_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_washington", 658893, {
				name_id = "trophy_ace_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_watchout",
		image_id = "safehouse_trophies_preview_watchout",
		objective_id = "trophy_watchout_objective",
		id = "trophy_watchout",
		desc_id = "trophy_watchout_desc",
		objectives = {
			self:_progress("trophy_watchout", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_piggy_bank",
		image_id = "safehouse_trophies_preview_piggy_bank",
		objective_id = "trophy_piggy_bank_objective",
		id = "trophy_piggy_bank",
		desc_id = "trophy_piggy_bank_desc",
		objectives = {
			self:_progress("trophy_piggy_bank", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_dance",
		image_id = "safehouse_trophies_preview_dances",
		objective_id = "trophy_dance_objective",
		id = "trophy_dance",
		desc_id = "trophy_dance_desc",
		objectives = {
			self:_progress("trophy_dance", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_fbi",
		image_id = "safehouse_trophies_preview_fbi",
		objective_id = "trophy_fbi_objective",
		id = "trophy_fbi",
		desc_id = "trophy_fbi_desc",
		objectives = {
			self:_progress("trophy_fbi", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_jfk",
		image_id = "safehouse_trophies_preview_jfk",
		objective_id = "trophy_jfk_objective",
		id = "trophy_jfk",
		desc_id = "trophy_jfk_desc",
		objectives = {
			self:_progress("trophy_jfk", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_smg",
		image_id = "safehouse_trophies_preview_smg",
		objective_id = "trophy_smg_objective",
		id = "trophy_smg",
		desc_id = "trophy_smg_desc",
		objectives = {
			self:_progress("trophy_smg", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_host",
		image_id = "safehouse_trophies_preview_host",
		objective_id = "trophy_host_objective",
		id = "trophy_host",
		desc_id = "trophy_host_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_host", 10, {
				name_id = "trophy_host_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_framing_frame",
		image_id = "safehouse_trophies_preview_framing_frame",
		objective_id = "trophy_framing_frame_objective",
		id = "trophy_framing_frame",
		desc_id = "trophy_framing_frame_desc",
		objectives = {
			self:_progress("trophy_framing_frame", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_sandwich",
		image_id = "safehouse_trophies_preview_sandwich",
		objective_id = "trophy_sandwich_objective",
		id = "trophy_sandwich",
		desc_id = "trophy_sandwich_desc",
		objectives = {
			self:_progress("trophy_sandwich", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_planmaker",
		image_id = "safehouse_trophies_preview_planmaker",
		objective_id = "trophy_planmaker_objective",
		id = "trophy_planmaker",
		desc_id = "trophy_planmaker_desc",
		objectives = {
			self:_progress("trophy_planmaker", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_bonfire",
		secret = true,
		objective_id = "trophy_bonfire_objective",
		id = "trophy_bonfire",
		image_id = "safehouse_trophies_preview_bonfire",
		desc_id = "trophy_bonfire_desc",
		objectives = {
			self:_progress("trophy_bonfire", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_smwish",
		image_id = "safehouse_trophies_preview_dallas_statue",
		objective_id = "trophy_smwish_objective",
		id = "trophy_smwish",
		desc_id = "trophy_smwish_desc",
		objectives = {
			self:_progress("trophy_smwish", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_medic",
		image_id = "safehouse_trophies_preview_medic",
		objective_id = "trophy_medic_objective",
		id = "trophy_medic",
		desc_id = "trophy_medic_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_medic", 100, {
				name_id = "trophy_medic_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_courtesy",
		image_id = "safehouse_trophies_preview_courtesy",
		objective_id = "trophy_courtesy_objective",
		id = "trophy_courtesy",
		desc_id = "trophy_courtesy_desc",
		objectives = {
			self:_progress("trophy_courtesy", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_evolution",
		image_id = "safehouse_trophies_preview_evolution",
		objective_id = "trophy_evolution_objective",
		id = "trophy_evolution",
		desc_id = "trophy_evolution_desc",
		objectives = {
			self:_progress("trophy_evolution", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_flawless",
		image_id = "safehouse_trophies_preview_flawless",
		objective_id = "trophy_flawless_objective",
		id = "trophy_flawless",
		desc_id = "trophy_flawless_desc",
		objectives = {
			self:_progress("trophy_flawless", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_defender",
		image_id = "safehouse_trophies_preview_barbwire",
		objective_id = "trophy_defender_objective",
		id = "trophy_defender",
		desc_id = "trophy_defender_desc",
		objectives = {
			self:_progress("trophy_defender", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_tooth",
		image_id = "safehouse_trophies_preview_toothbrush",
		objective_id = "trophy_tooth_objective",
		id = "trophy_tooth",
		desc_id = "trophy_tooth_desc",
		objectives = {
			self:_achievement("flat_3")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_spooky",
		image_id = "safehouse_trophies_preview_spooky",
		objective_id = "trophy_spooky_objective",
		id = "trophy_spooky",
		desc_id = "trophy_spooky_desc",
		objectives = {
			self:_progress("trophy_spooky", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_flamingo",
		image_id = "safehouse_trophies_preview_flamingo",
		objective_id = "trophy_flamingo_objective",
		id = "trophy_flamingo",
		desc_id = "trophy_flamingo_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_flamingo", 20, {
				name_id = "trophy_flamingo_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_coke",
		image_id = "safehouse_trophies_preview_coke",
		objective_id = "trophy_coke_objective",
		id = "trophy_coke",
		desc_id = "trophy_coke_desc",
		show_progress = true,
		objectives = {
			self:_progress("trophy_coke", 24, {
				name_id = "trophy_coke_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_friendly_car",
		image_id = "safehouse_trophies_preview_tonys_car",
		objective_id = "trophy_friendly_car_objective",
		id = "trophy_friendly_car",
		desc_id = "trophy_friendly_car_desc",
		objectives = {
			self:_progress("trophy_friendly_car", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_fish_trophy",
		image_id = "safehouse_trophies_preview_yacht",
		objective_id = "trophy_fish_trophy_objective",
		id = "trophy_fish_trophy",
		desc_id = "trophy_fish_trophy_desc",
		objectives = {
			self:_progress("trophy_fish_trophy", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_run_matt",
		hidden_in_list = true,
		objective_id = "trophy_run_matt_objective",
		id = "trophy_run_matt",
		gives_reward = false,
		desc_id = "trophy_run_matt_desc",
		image_id = "safehouse_trophies_preview_yacht",
		objectives = {
			self:_progress("trophy_run_matt", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_run_turtle",
		image_id = "safehouse_trophies_preview_turtle",
		objective_id = "trophy_run_turtle_objective",
		id = "trophy_run_turtle",
		desc_id = "trophy_run_turtle_desc",
		objectives = {
			self:_progress("trophy_run_turtle", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_glace_cuffs",
		image_id = "safehouse_trophies_preview_glace_cuffs",
		objective_id = "trophy_glace_cuffs_objective",
		id = "trophy_glace_cuffs",
		desc_id = "trophy_glace_cuffs_desc",
		objectives = {
			self:_progress("trophy_glace_cuffs", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_glace_completion",
		hidden_in_list = true,
		objective_id = "trophy_glace_completion_objective",
		id = "trophy_glace_completion",
		gives_reward = false,
		desc_id = "trophy_glace_completion_desc",
		image_id = "safehouse_trophies_preview_yacht",
		objectives = {
			self:_progress("trophy_glace_completion", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_jfr_1",
		image_id = "safehouse_trophies_preview_hat",
		objective_id = "trophy_jfr_1_completion_objective",
		id = "trophy_jfr_1",
		gives_reward = false,
		desc_id = "trophy_jfr_1_desc",
		objectives = {
			self:_progress("sidejob_jfr_1", 1),
			self:_progress("sidejob_jfr_2", 1),
			self:_progress("sidejob_jfr_3", 1),
			self:_progress("sidejob_jfr_4", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_aru_1",
		image_id = "safehouse_trophies_preview_push_dagger",
		objective_id = "trophy_aru_1_completion_objective",
		id = "trophy_aru_1",
		gives_reward = false,
		desc_id = "trophy_aru_1_desc",
		objectives = {
			self:_progress("sidejob_aru_1", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_aru_2",
		image_id = "safehouse_trophies_preview_luger",
		objective_id = "trophy_aru_2_completion_objective",
		id = "trophy_aru_2",
		gives_reward = false,
		desc_id = "trophy_aru_2_desc",
		objectives = {
			self:_progress("sidejob_aru_2", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_aru_3",
		image_id = "safehouse_trophies_preview_mp40",
		objective_id = "trophy_aru_3_completion_objective",
		id = "trophy_aru_3",
		gives_reward = false,
		desc_id = "trophy_aru_3_desc",
		objectives = {
			self:_progress("sidejob_aru_3", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_aru_4",
		image_id = "safehouse_trophies_preview_garand",
		objective_id = "trophy_aru_4_completion_objective",
		id = "trophy_aru_4",
		gives_reward = false,
		desc_id = "trophy_aru_4_desc",
		objectives = {
			self:_progress("sidejob_aru_4", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_eng_1",
		image_id = "safehouse_trophies_preview_bullet",
		objective_id = "trophy_eng_1_completion_objective",
		id = "trophy_eng_1",
		desc_id = "trophy_eng_1_desc",
		show_progress = true,
		objectives = {
			self:_progress("eng_1_stats", 5, {
				name_id = "trophy_eng_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_eng_2",
		image_id = "safehouse_trophies_preview_the_robot",
		objective_id = "trophy_eng_2_completion_objective",
		id = "trophy_eng_2",
		desc_id = "trophy_eng_2_desc",
		show_progress = true,
		objectives = {
			self:_progress("eng_2_stats", 5, {
				name_id = "trophy_eng_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_eng_3",
		image_id = "safehouse_trophies_preview_the_marine",
		objective_id = "trophy_eng_3_completion_objective",
		id = "trophy_eng_3",
		desc_id = "trophy_eng_3_desc",
		show_progress = true,
		objectives = {
			self:_progress("eng_3_stats", 5, {
				name_id = "trophy_eng_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_eng_4",
		image_id = "safehouse_trophies_preview_the_cultist",
		objective_id = "trophy_eng_4_completion_objective",
		id = "trophy_eng_4",
		desc_id = "trophy_eng_4_desc",
		show_progress = true,
		objectives = {
			self:_progress("eng_4_stats", 5, {
				name_id = "trophy_eng_progress"
			})
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_brb_1",
		image_id = "safehouse_trophies_preview_medallion",
		objective_id = "trophy_brb_1_completion_objective",
		id = "trophy_brb_1",
		gives_reward = false,
		desc_id = "trophy_brb_1_desc",
		objectives = {
			self:_achievement("brb_4")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_box_1",
		image_id = "safehouse_trophies_preview_box1_healer",
		objective_id = "trophy_box_1_completion_objective",
		id = "trophy_box_1",
		desc_id = "trophy_box_1_desc",
		objectives = {
			self:_achievement("trk_gg_0"),
			self:_achievement("des_1")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_box_2",
		image_id = "safehouse_trophies_preview_box2_elephant",
		objective_id = "trophy_box_2_completion_objective",
		id = "trophy_box_2",
		desc_id = "trophy_box_2_desc",
		objectives = {
			self:_achievement("tag_1")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_box_3",
		image_id = "safehouse_trophies_preview_box3_scribe",
		objective_id = "trophy_box_3_completion_objective",
		id = "trophy_box_3",
		desc_id = "trophy_box_3_desc",
		objectives = {
			self:_achievement("des_1")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_device_parts",
		hidden_in_list = true,
		objective_id = "trophy_device_parts_completion_objective",
		id = "trophy_device_parts",
		gives_reward = false,
		desc_id = "trophy_device_parts_desc",
		objectives = {
			self:_progress("trophy_device_parts", 1)
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_black_plate",
		image_id = "safehouse_trophies_preview_blackplate",
		objective_id = "trophy_black_plate_completion_objective",
		id = "trophy_black_plate",
		desc_id = "trophy_black_plate_desc",
		objectives = {
			self:_achievement("sah_1")
		}
	})
	table.insert(self.trophies, {
		id = "trophy_device_assembled",
		gives_reward = false,
		hidden_in_list = true,
		objectives = {
			self:_progress("trophy_device_assembled", 1)
		}
	})
	table.insert(self.trophies, {
		id = "trophy_device_opened",
		gives_reward = false,
		hidden_in_list = true,
		objectives = {
			self:_progress("trophy_device_opened", 1)
		}
	})
	table.insert(self.trophies, {
		id = "trophy_vlads_cupcake",
		gives_reward = false,
		hidden_in_list = true,
		objectives = {
			self:_achievement("trk_gg_0"),
			self:_achievement("trk_dm_0")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_bains_book",
		image_id = "safehouse_trophies_preview_bains_book",
		objective_id = "trophy_bains_book_completion_objective",
		id = "trophy_bains_book",
		desc_id = "trophy_bains_book_desc",
		objectives = {
			self:_achievement("nmh_1")
		}
	})
	table.insert(self.trophies, {
		name_id = "trophy_bex",
		image_id = "safehouse_trophies_preview_bex",
		objective_id = "trophy_bex_objective",
		id = "trophy_bex",
		gives_reward = false,
		desc_id = "trophy_bex_desc",
		objectives = {
			self:_progress("trophy_bex", 1)
		}
	})
end

function CustomSafehouseTweakData:get_trophy_data(id)
	for idx, trophy in ipairs(self.trophies) do
		if trophy.id == id then
			return trophy
		end
	end

	return self:get_daily_data(id)
end

function CustomSafehouseTweakData:_verify_unique_heist(trophy_objective)
	trophy_objective.completed_heists = trophy_objective.completed_heists or {}
	local job_id = managers.job:current_job_id()

	if job_id and not table.contains(trophy_objective.completed_heists, job_id) then
		table.insert(trophy_objective.completed_heists, job_id)

		return true
	else
		return false
	end
end

function CustomSafehouseTweakData:_init_dailies(tweak_data)
	self.dailies = {}

	table.insert(self.dailies, {
		name_id = "daily_classics",
		objective_id = "daily_classics_objective",
		id = "daily_classics",
		desc_id = "daily_classics_desc",
		show_progress = true,
		objectives = {
			self:_progress("daily_classics", 2, {
				verify = "_verify_unique_heist",
				name_id = "daily_classics_progress",
				save_values = {
					"completed_heists"
				}
			})
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_discord",
		objective_id = "daily_discord_objective",
		id = "daily_discord",
		desc_id = "daily_discord_desc",
		show_progress = true,
		objectives = {
			self:_progress("daily_discord", 3, {
				name_id = "daily_discord_progress"
			})
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_fwtd",
		objective_id = "daily_fwtd_objective",
		id = "daily_fwtd",
		desc_id = "daily_fwtd_desc",
		objectives = {
			self:_progress("daily_fwtd", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_gears",
		objective_id = "daily_gears_objective",
		id = "daily_gears",
		desc_id = "daily_gears_desc",
		objectives = {
			self:_progress("daily_gears", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_grenades",
		objective_id = "daily_grenades_objective",
		id = "daily_grenades",
		desc_id = "daily_grenades_desc",
		show_progress = true,
		objectives = {
			self:_progress("daily_grenades", 25, {
				name_id = "daily_grenades_progress"
			})
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_phobia",
		objective_id = "daily_phobia_objective",
		id = "daily_phobia",
		desc_id = "daily_phobia_desc",
		objectives = {
			self:_progress("daily_phobia", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_mortage",
		objective_id = "daily_mortage_objective",
		id = "daily_mortage",
		desc_id = "daily_mortage_desc",
		objectives = {
			self:_progress("daily_mortage", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_art",
		objective_id = "daily_art_objective",
		id = "daily_art",
		desc_id = "daily_art_desc",
		objectives = {
			self:_progress("daily_art", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_akimbo",
		objective_id = "daily_akimbo_objective",
		id = "daily_akimbo",
		desc_id = "daily_akimbo_desc",
		objectives = {
			self:_progress("daily_akimbo", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_professional",
		objective_id = "daily_professional_objective",
		id = "daily_professional",
		desc_id = "daily_professional_desc",
		objectives = {
			self:_progress("daily_professional", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_spacetime",
		objective_id = "daily_spacetime_objective",
		id = "daily_spacetime",
		desc_id = "daily_spacetime_desc",
		objectives = {
			self:_progress("daily_spacetime", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_tapes",
		objective_id = "daily_tapes_objective",
		id = "daily_tapes",
		desc_id = "daily_tapes_desc",
		objectives = {
			self:_progress("daily_tapes", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_toast",
		objective_id = "daily_toast_objective",
		id = "daily_toast",
		desc_id = "daily_toast_desc",
		objectives = {
			self:_progress("daily_toast", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_heirloom",
		objective_id = "daily_heirloom_objective",
		id = "daily_heirloom",
		desc_id = "daily_heirloom_desc",
		objectives = {
			self:_progress("daily_heirloom", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_helicopter",
		objective_id = "daily_helicopter_objective",
		id = "daily_helicopter",
		desc_id = "daily_helicopter_desc",
		objectives = {
			self:_progress("daily_helicopter", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_sewers",
		objective_id = "daily_sewers_objective",
		id = "daily_sewers",
		desc_id = "daily_sewers_desc",
		objectives = {
			self:_progress("daily_sewers", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_night_out",
		objective_id = "daily_night_out_objective",
		id = "daily_night_out",
		desc_id = "daily_night_out_desc",
		objectives = {
			self:_progress("daily_night_out", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_secret_identity",
		objective_id = "daily_secret_identity_objective",
		id = "daily_secret_identity",
		desc_id = "daily_secret_identity_desc",
		objectives = {
			self:_progress("daily_secret_identity", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_lodsofemone",
		objective_id = "daily_lodsofemone_objective",
		id = "daily_lodsofemone",
		desc_id = "daily_lodsofemone_desc",
		show_progress = true,
		objectives = {
			self:_progress("daily_lodsofemone", 20, {
				name_id = "daily_lodsofemone_progress"
			})
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_hangover",
		objective_id = "daily_hangover_objective",
		id = "daily_hangover",
		desc_id = "daily_hangover_desc",
		show_progress = true,
		objectives = {
			self:_progress("daily_hangover", 25, {
				name_id = "daily_hangover_progress"
			})
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_rush",
		objective_id = "daily_rush_objective",
		id = "daily_rush",
		desc_id = "daily_rush_desc",
		objectives = {
			self:_progress("daily_rush", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_naked",
		objective_id = "daily_naked_objective",
		id = "daily_naked",
		desc_id = "daily_naked_desc",
		objectives = {
			self:_progress("daily_naked", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_honorable",
		objective_id = "daily_honorable_objective",
		id = "daily_honorable",
		desc_id = "daily_honorable_desc",
		show_progress = true,
		objectives = {
			self:_progress("daily_honorable", 10, {
				name_id = "daily_honorable_progress"
			})
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_ninja",
		objective_id = "daily_ninja_objective",
		id = "daily_ninja",
		desc_id = "daily_ninja_desc",
		objectives = {
			self:_progress("daily_ninja", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_cake",
		objective_id = "daily_cake_objective",
		id = "daily_cake",
		desc_id = "daily_cake_desc",
		objectives = {
			self:_progress("daily_cake", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_my_bodhi_is_ready",
		objective_id = "daily_my_bodhi_is_ready_objective",
		id = "daily_my_bodhi_is_ready",
		desc_id = "daily_my_bodhi_is_ready_desc",
		show_progress = true,
		objectives = {
			self:_progress("corpse_dispose", 10, {
				name_id = "daily_my_bodhi_is_ready_progress"
			})
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_tasty",
		objective_id = "daily_tasty_objective",
		id = "daily_tasty",
		desc_id = "daily_tasty_desc",
		show_progress = true,
		objectives = {
			self:_progress("daily_tasty", 20, {
				name_id = "daily_tasty_progress"
			})
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_candy",
		objective_id = "daily_candy_objective",
		id = "daily_candy",
		desc_id = "daily_candy_desc",
		show_progress = true,
		objectives = {
			self:_progress("daily_candy", 10, {
				name_id = "daily_candy_progress"
			})
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_dosh",
		objective_id = "daily_dosh_objective",
		id = "daily_dosh",
		desc_id = "daily_dosh_desc",
		objectives = {
			self:_achievement("pal_2")
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_snake",
		objective_id = "daily_snake_objective",
		id = "daily_snake",
		desc_id = "daily_snake_desc",
		show_progress = true,
		objectives = {
			self:_progress("gmod_5_stats", 10, {
				name_id = "daily_snake_progress"
			})
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_coke_run",
		objective_id = "daily_coke_run_objective",
		id = "daily_coke_run",
		desc_id = "daily_coke_run_desc",
		objectives = {
			self:_progress("daily_coke_run", 1)
		}
	})
	table.insert(self.dailies, {
		name_id = "daily_whats_stealth",
		objective_id = "daily_whats_stealth_objective",
		id = "daily_whats_stealth",
		desc_id = "daily_whats_stealth_desc",
		objectives = {
			self:_progress("daily_whats_stealth", 1)
		}
	})
end

function CustomSafehouseTweakData:get_daily_data(id)
	for idx, daily in ipairs(self.dailies) do
		if daily.id == id then
			return daily
		end
	end
end

function CustomSafehouseTweakData:_init_map(tweak_data)
	self.map = {
		size = 2000,
		frame_texture = {
			"guis/dlcs/chill/textures/pd2/character_icon/safehouse_character_lvl_indicator1",
			"guis/dlcs/chill/textures/pd2/character_icon/safehouse_character_lvl_indicator2",
			"guis/dlcs/chill/textures/pd2/character_icon/safehouse_character_lvl_indicator3"
		},
		rooms = {},
		floors = {}
	}

	table.insert(self.map.floors, {
		texture = "guis/dlcs/chill/textures/pd2/safehouse/chill_map_top_floor",
		name_id = "menu_cs_top_floor",
		desc_id = "menu_cs_top_floor_desc",
		alpha_limit = 0.05,
		start_zoom = 1.2,
		min_zoom = 1,
		shape = {
			0.4,
			0.22,
			0.88,
			0.56
		},
		controller_shape = {
			0.4,
			0.22,
			0.88,
			0.61
		},
		rooms = {
			"old_hoxton",
			"russian",
			"clover",
			"terry",
			"myh"
		}
	})
	table.insert(self.map.floors, {
		texture = "guis/dlcs/chill/textures/pd2/safehouse/chill_map_ground_floor",
		name_id = "menu_cs_ground_floor",
		desc_id = "menu_cs_ground_floor_desc",
		alpha_limit = 0.05,
		start_zoom = 1,
		min_zoom = 0.8,
		shape = {
			0.29,
			0.21,
			0.88,
			0.63
		},
		controller_shape = {
			0.29,
			0.16,
			0.93,
			0.73
		},
		rooms = {
			"bonnie",
			"dragon",
			"jimmy",
			"spanish",
			"american",
			"sydney",
			"wild",
			"livingroom",
			"max",
			"joy",
			"ecp"
		}
	})
	table.insert(self.map.floors, {
		texture = "guis/dlcs/chill/textures/pd2/safehouse/chill_map_basement",
		name_id = "menu_cs_basement",
		desc_id = "menu_cs_basement_desc",
		alpha_limit = 0.03,
		start_zoom = 0.8,
		min_zoom = 0.6,
		shape = {
			0.19,
			0.19,
			0.9,
			0.63
		},
		controller_shape = {
			0.14,
			0.09,
			1,
			0.78
		},
		rooms = {
			"dragan",
			"german",
			"sokol",
			"bodhi",
			"vault",
			"jacket",
			"jowi"
		}
	})

	self.map.rooms.dragan = {
		icon = "safehouse_character_icon_dragan",
		x = 1150,
		y = 730
	}
	self.map.rooms.german = {
		icon = "safehouse_character_icon_wolf",
		x = 1237,
		y = 1108
	}
	self.map.rooms.sokol = {
		icon = "safehouse_character_icon_sokol",
		x = 1260,
		y = 690
	}
	self.map.rooms.bodhi = {
		icon = "safehouse_character_icon_bodhi",
		x = 1300,
		y = 550
	}
	self.map.rooms.vault = {
		icon = "safehouse_character_icon_vault",
		x = 902,
		y = 653
	}
	self.map.rooms.jacket = {
		icon = "safehouse_character_icon_jacket",
		x = 1402,
		y = 660
	}
	self.map.rooms.jowi = {
		icon = "safehouse_character_icon_wick",
		x = 1045,
		y = 1108
	}
	self.map.rooms.bonnie = {
		icon = "safehouse_character_icon_bonnie",
		x = 1320,
		y = 815
	}
	self.map.rooms.dragon = {
		icon = "safehouse_character_icon_jiro",
		x = 1400,
		y = 803
	}
	self.map.rooms.jimmy = {
		icon = "safehouse_character_icon_jimmy",
		x = 1380,
		y = 910
	}
	self.map.rooms.spanish = {
		icon = "safehouse_character_icon_chains",
		x = 1205,
		y = 1108
	}
	self.map.rooms.american = {
		icon = "safehouse_character_icon_houston",
		x = 1160,
		y = 640
	}
	self.map.rooms.sydney = {
		icon = "safehouse_character_icon_sydney",
		x = 1240,
		y = 640
	}
	self.map.rooms.wild = {
		icon = "safehouse_character_icon_rust",
		x = 1240,
		y = 750
	}
	self.map.rooms.livingroom = {
		icon = "safehouse_character_icon_livingroom",
		x = 1170,
		y = 930
	}
	self.map.rooms.old_hoxton = {
		icon = "safehouse_character_icon_reborn",
		x = 1290,
		y = 850
	}
	self.map.rooms.russian = {
		icon = "safehouse_character_icon_dallas",
		x = 1353,
		y = 810
	}
	self.map.rooms.clover = {
		icon = "safehouse_character_icon_clover",
		x = 1350,
		y = 900
	}
	self.map.rooms.terry = {
		path = "guis/dlcs/chico/textures/pd2/blackmarket/icons/safehouse_icons/",
		icon = "safehouse_character_icon_terry",
		x = 1325,
		y = 700
	}
	self.map.rooms.max = {
		path = "guis/dlcs/max/textures/pd2/blackmarket/icons/safehouse_icons/",
		icon = "safehouse_character_icon_max",
		x = 1295,
		y = 1015
	}
	self.map.rooms.joy = {
		path = "guis/dlcs/joy/textures/pd2/blackmarket/icons/safehouse_icons/",
		icon = "safehouse_character_icon_joy",
		x = 1040,
		y = 780
	}
	self.map.rooms.myh = {
		path = "guis/dlcs/myh/textures/pd2/blackmarket/icons/safehouse_icons/",
		icon = "safehouse_character_icon_myh",
		x = 1155,
		y = 955
	}
	self.map.rooms.ecp = {
		path = "guis/dlcs/ecp/textures/pd2/blackmarket/icons/safehouse_icons/",
		icon = "safehouse_character_icon_ecp",
		x = 1140,
		y = 830
	}
end

function CustomSafehouseTweakData:_init_uno()
	self.uno_achievements_pool = {
		"armored_1",
		"armored_2",
		"bat_2",
		"berry_2",
		"bigbank_5",
		"bob_3",
		"born_5",
		"bph_11",
		"brb_8",
		"cac_13",
		"cac_26",
		"cac_9",
		"cane_2",
		"charliesierra_5",
		"cow_10",
		"cow_4",
		"dah_9",
		"dark_3",
		"diamonds_are_forever",
		"doctor_fantastic",
		"fish_5",
		"fort_4",
		"green_6",
		"halloween_2",
		"i_wasnt_even_there",
		"jerry_4",
		"kenaz_4",
		"kosugi_2",
		"lets_do_this",
		"live_2",
		"lord_of_war",
		"man_2",
		"melt_3",
		"moon_5",
		"nmh_10",
		"pal_2",
		"payback_2",
		"peta_3",
		"pig_2",
		"run_10",
		"rvd_11",
		"sah_10",
		"spa_5",
		"tag_10",
		"trk_af_3",
		"trk_fs_3",
		"trk_sh_3",
		"uno_1",
		"uno_2",
		"uno_3",
		"uno_4",
		"uno_5",
		"uno_6",
		"uno_7",
		"uno_8",
		"uno_9",
		"wwh_9"
	}
	self.uno_notes = "07729e9e9633c57e"
	self.uno_door_riddles = {
		"74650960625584b5",
		"fb5c57e8ac77053c",
		"7ace1515c20c617f",
		"14a99f4af0044252",
		"999dce46997b9b8b",
		"7e386d403e2af3b0",
		"7a8274cf00687c19",
		"4287ec39bce6ba9c",
		"2ea0f239dec3d4d2",
		"a52531d7c3a90a88",
		"b4381b950c7d4e0f",
		"c89511e5a2305e79",
		"2b77295d9511fa5f"
	}
end
