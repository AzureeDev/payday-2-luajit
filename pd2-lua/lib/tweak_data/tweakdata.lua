require("lib/tweak_data/WeaponTweakData")
require("lib/tweak_data/EquipmentsTweakData")
require("lib/tweak_data/CharacterTweakData")
require("lib/tweak_data/PlayerTweakData")
require("lib/tweak_data/StatisticsTweakData")
require("lib/tweak_data/LevelsTweakData")
require("lib/tweak_data/GroupAITweakData")
require("lib/tweak_data/DramaTweakData")
require("lib/tweak_data/UpgradesTweakData")
require("lib/tweak_data/UpgradesVisualTweakData")
require("lib/tweak_data/HudIconsTweakData")
require("lib/tweak_data/TipsTweakData")
require("lib/tweak_data/BlackMarketTweakData")
require("lib/tweak_data/CarryTweakData")
require("lib/tweak_data/MissionDoorTweakData")
require("lib/tweak_data/AttentionTweakData")
require("lib/tweak_data/NarrativeTweakData")
require("lib/tweak_data/SkillTreeTweakData")
require("lib/tweak_data/TimeSpeedEffectTweakData")
require("lib/tweak_data/SoundTweakData")
require("lib/tweak_data/LootDropTweakData")
require("lib/tweak_data/GuiTweakData")
require("lib/tweak_data/MoneyTweakData")
require("lib/tweak_data/AssetsTweakData")
require("lib/tweak_data/DLCTweakData")
require("lib/tweak_data/InfamyTweakData")
require("lib/tweak_data/GageAssignmentTweakData")
require("lib/tweak_data/PrePlanningTweakData")
require("lib/tweak_data/InteractionTweakData")
require("lib/tweak_data/VehicleTweakData")
require("lib/tweak_data/EconomyTweakData")
require("lib/tweak_data/VanSkinsTweakData")
require("lib/tweak_data/EnvEffectTweakData")
require("lib/tweak_data/AchievementsTweakData")
require("lib/tweak_data/CustomSafehouseTweakData")
require("lib/tweak_data/TangoTweakData")
require("lib/tweak_data/SubtitleTweakData")
require("lib/tweak_data/InputTweakData")
require("lib/tweak_data/ArmorSkinsTweakData")
require("lib/tweak_data/CrimeSpreeTweakData")
require("lib/tweak_data/FireTweakData")
require("lib/tweak_data/NetworkTweakData")
require("lib/tweak_data/AnimationTweakData")
require("lib/tweak_data/StoryMissionsTweakData")
require("lib/tweak_data/PromotionalMenusTweakData")
require("lib/tweak_data/PromoUnlocksTweakData")
require("lib/tweak_data/RaidJobsTweakData")
require("lib/tweak_data/TweakDataVR")
require("lib/tweak_data/SkirmishTweakData")

TweakData = TweakData or class()

function TweakData:_init_wip_tweak_data()
end

function TweakData:_init_wip_blackmarket(tweak_data)
end

function TweakData:_init_wip_levels()
end

function TweakData:_init_wip_narrative()
end

function TweakData:_init_wip_assets(tweak_data)
end

function TweakData:_init_wip_weapon_factory(tweak_data)
end

function TweakData:_init_wip_skilltree()
end

function TweakData:_init_wip_upgrades()
end

function TweakData:_init_wip_economy()
end

require("lib/tweak_data/TweakDataPD2")

TweakData.RELOAD = true

function TweakData:digest_tweak_data()
	Application:debug("TweakData: Digesting tweak_data. <('O'<)")

	self.digested_tables = {
		"money_manager",
		"experience_manager",
		"casino"
	}

	for i, digest_me in ipairs(self.digested_tables) do
		self:digest_recursive(self[digest_me])
	end
end

function TweakData:digest_recursive(key, parent)
	local value = parent and parent[key] or key

	if type(value) == "table" then
		for index, data in pairs(value) do
			self:digest_recursive(index, value)
		end
	elseif type(value) == "number" then
		parent[key] = Application:digest_value(value, true)
	end
end

function TweakData:get_value(...)
	local arg = {
		...
	}
	local value = self

	for _, v in ipairs(arg) do
		if not value[v] then
			return false
		end

		value = value[v]
	end

	if type(value) == "string" then
		return Application:digest_value(value, false)
	elseif type(value) == "table" then
		Application:debug("TweakData:get_value() value was a table, is this correct? returning false!", inspect(arg), inspect(value))

		return false
	end

	return value
end

function TweakData:get_raw_value(...)
	local arg = {
		...
	}
	local value = self
	local v = nil

	for i = 1, #arg, 1 do
		v = arg[i]

		if not value[v] then
			return nil, v, i
		end

		value = value[v]
	end

	return value
end

function TweakData:get_mutatable_value(id, ...)
	local value = self:get_raw_value(...)

	managers.mutators:modify_tweak_data(id, value)

	return value
end

function TweakData:set_mode()
	if not Global.game_settings then
		return
	end

	if Global.game_settings.single_player then
		self:_set_singleplayer()
	else
		self:_set_multiplayer()
	end
end

function TweakData:_set_singleplayer()
	self.player:_set_singleplayer()
end

function TweakData:_set_multiplayer()
	self.player:_set_multiplayer()
end

function TweakData:set_difficulty()
	if not Global.game_settings then
		return
	end

	if Global.game_settings.difficulty == "easy" then
		self:_set_easy()
	elseif Global.game_settings.difficulty == "normal" then
		self:_set_normal()
	elseif Global.game_settings.difficulty == "overkill" then
		self:_set_overkill()
	elseif Global.game_settings.difficulty == "overkill_145" then
		self:_set_overkill_145()
	elseif Global.game_settings.difficulty == "easy_wish" then
		self:_set_easy_wish()
	elseif Global.game_settings.difficulty == "overkill_290" then
		self:_set_overkill_290()
	elseif Global.game_settings.difficulty == "sm_wish" then
		self:_set_sm_wish()
	else
		self:_set_hard()
	end
end

function TweakData:_set_easy()
	self.player:_set_easy()
	self.character:_set_easy()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_easy()

	self.experience_manager.civilians_killed = 15
	self.difficulty_name_id = self.difficulty_name_ids.easy
	self.experience_manager.total_level_objectives = 1000
	self.experience_manager.total_criminals_finished = 25
	self.experience_manager.total_objectives_finished = 750
end

function TweakData:_set_normal()
	self.player:_set_normal()
	self.character:_set_normal()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_normal()

	self.experience_manager.civilians_killed = 35
	self.difficulty_name_id = self.difficulty_name_ids.normal
	self.experience_manager.total_level_objectives = 2000
	self.experience_manager.total_criminals_finished = 50
	self.experience_manager.total_objectives_finished = 1000
end

function TweakData:_set_hard()
	self.player:_set_hard()
	self.character:_set_hard()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_hard()

	self.experience_manager.civilians_killed = 75
	self.difficulty_name_id = self.difficulty_name_ids.hard
	self.experience_manager.total_level_objectives = 2500
	self.experience_manager.total_criminals_finished = 150
	self.experience_manager.total_objectives_finished = 1500
end

function TweakData:_set_overkill()
	self.player:_set_overkill()
	self.character:_set_overkill()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_overkill()

	self.experience_manager.civilians_killed = 150
	self.difficulty_name_id = self.difficulty_name_ids.overkill
	self.experience_manager.total_level_objectives = 5000
	self.experience_manager.total_criminals_finished = 500
	self.experience_manager.total_objectives_finished = 3000
end

function TweakData:_set_overkill_145()
	self.player:_set_overkill_145()
	self.character:_set_overkill_145()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_overkill_145()

	self.experience_manager.civilians_killed = 550
	self.difficulty_name_id = self.difficulty_name_ids.overkill_145
	self.experience_manager.total_level_objectives = 5000
	self.experience_manager.total_criminals_finished = 2000
	self.experience_manager.total_objectives_finished = 3000
end

function TweakData:_set_easy_wish()
	self.player:_set_easy_wish()
	self.character:_set_easy_wish()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_easy_wish()

	self.experience_manager.civilians_killed = 10000
	self.difficulty_name_id = self.difficulty_name_ids.easy_wish
	self.experience_manager.total_level_objectives = 5000
	self.experience_manager.total_criminals_finished = 2000
	self.experience_manager.total_objectives_finished = 3000
end

function TweakData:_set_overkill_290()
	self.player:_set_overkill_290()
	self.character:_set_overkill_290()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_overkill_290()

	self.experience_manager.civilians_killed = 10000
	self.difficulty_name_id = self.difficulty_name_ids.overkill_290
	self.experience_manager.total_level_objectives = 5000
	self.experience_manager.total_criminals_finished = 2000
	self.experience_manager.total_objectives_finished = 3000
end

function TweakData:_set_sm_wish()
	self.player:_set_sm_wish()
	self.character:_set_sm_wish()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_sm_wish()

	self.experience_manager.civilians_killed = 10000
	self.difficulty_name_id = self.difficulty_name_ids.sm_wish
	self.experience_manager.total_level_objectives = 5000
	self.experience_manager.total_criminals_finished = 2000
	self.experience_manager.total_objectives_finished = 3000
end

function TweakData:difficulty_to_index(difficulty)
	return table.index_of(self.difficulties, difficulty)
end

function TweakData:index_to_difficulty(index)
	return self.difficulties[index]
end

function TweakData:permission_to_index(permission)
	return table.index_of(self.permissions, permission)
end

function TweakData:index_to_permission(index)
	return self.permissions[index]
end

function TweakData:server_state_to_index(state)
	return table.index_of(self.server_states, state)
end

function TweakData:index_to_server_state(index)
	return self.server_states[index]
end

function TweakData:menu_sync_state_to_index(state)
	if not state then
		return false
	end

	for i, menu_sync in ipairs(self.menu_sync_states) do
		if menu_sync == state then
			return i
		end
	end
end

function TweakData:index_to_menu_sync_state(index)
	return self.menu_sync_states[index]
end

function TweakData:init()
	self.max_players = 4
	self.difficulties = {
		"easy",
		"normal",
		"hard",
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	self.difficulty_level_locks = {
		0,
		0,
		0,
		0,
		0,
		0,
		80,
		80
	}
	self.permissions = {
		"public",
		"friends_only",
		"private"
	}
	self.server_states = {
		"in_lobby",
		"loading",
		"briefing",
		"in_game"
	}
	self.menu_sync_states = {
		"crimenet",
		"skilltree",
		"options",
		"lobby",
		"blackmarket",
		"blackmarket_weapon",
		"blackmarket_mask",
		"payday",
		"custom_safehouse"
	}
	self.difficulty_name_ids = {
		easy = "menu_difficulty_easy",
		normal = "menu_difficulty_normal",
		hard = "menu_difficulty_hard",
		overkill = "menu_difficulty_very_hard",
		overkill_145 = "menu_difficulty_overkill",
		easy_wish = "menu_difficulty_easy_wish",
		overkill_290 = "menu_difficulty_apocalypse",
		sm_wish = "menu_difficulty_sm_wish"
	}
	self.criminals = {
		characters = {
			{
				name = "russian",
				order = 1,
				static_data = {
					voice = "rb4",
					ai_mask_id = "dallas",
					ai_character_id = "ai_dallas",
					ssuffix = "a"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "german",
				order = 2,
				static_data = {
					voice = "rb3",
					ai_mask_id = "wolf",
					ai_character_id = "ai_wolf",
					ssuffix = "c"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "spanish",
				order = 3,
				static_data = {
					voice = "rb1",
					ai_mask_id = "chains",
					ai_character_id = "ai_chains",
					ssuffix = "b"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "american",
				order = 4,
				static_data = {
					voice = "rb2",
					ai_mask_id = "hoxton",
					ai_character_id = "ai_hoxton",
					ssuffix = "l"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "jowi",
				order = 5,
				static_data = {
					voice = "rb6",
					ai_mask_id = "jw_shades",
					ai_character_id = "ai_jowi",
					ssuffix = "m"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "old_hoxton",
				order = 6,
				static_data = {
					voice = "rb5",
					ai_mask_id = "old_hoxton",
					ai_character_id = "ai_old_hoxton",
					ssuffix = "d"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "female_1",
				order = 7,
				static_data = {
					voice = "rb7",
					ai_mask_id = "msk_grizel",
					ai_character_id = "ai_female_1",
					ssuffix = "n"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "dragan",
				order = 8,
				static_data = {
					voice = "rb8",
					ai_mask_id = "dragan",
					ai_character_id = "ai_dragan",
					ssuffix = "o"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "jacket",
				order = 9,
				static_data = {
					voice = "rb9",
					ai_mask_id = "richard_returns",
					ai_character_id = "ai_jacket",
					ssuffix = "p"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "bonnie",
				order = 10,
				static_data = {
					voice = "rb10",
					ai_mask_id = "bonnie",
					ai_character_id = "ai_bonnie",
					ssuffix = "q"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "sokol",
				order = 11,
				static_data = {
					voice = "rb11",
					ai_mask_id = "sokol",
					ai_character_id = "ai_sokol",
					ssuffix = "r"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "dragon",
				order = 12,
				static_data = {
					voice = "rb12",
					ai_mask_id = "jiro",
					ai_character_id = "ai_dragon",
					ssuffix = "s"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "bodhi",
				order = 13,
				static_data = {
					voice = "rb13",
					ai_mask_id = "bodhi",
					ai_character_id = "ai_bodhi",
					ssuffix = "t"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "jimmy",
				order = 14,
				static_data = {
					voice = "rb14",
					ai_mask_id = "jimmy_duct",
					ai_character_id = "ai_jimmy",
					ssuffix = "u"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "sydney",
				order = 15,
				static_data = {
					voice = "rb15",
					ai_mask_id = "sydney",
					ai_character_id = "ai_sydney",
					ssuffix = "v"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "wild",
				order = 16,
				static_data = {
					voice = "rb16",
					ai_mask_id = "rust",
					ai_character_id = "ai_wild",
					ssuffix = "w"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "chico",
				order = 17,
				static_data = {
					voice = "rb17",
					ai_mask_id = "chc_terry",
					ai_character_id = "ai_chico",
					ssuffix = "x"
				},
				body_g_object = Idstring("g_body_terry")
			},
			{
				name = "max",
				order = 18,
				static_data = {
					voice = "rb18",
					ai_mask_id = "max",
					ai_character_id = "ai_max",
					ssuffix = "y"
				},
				body_g_object = Idstring("g_body_max")
			},
			{
				name = "joy",
				order = 19,
				static_data = {
					voice = "rb19",
					ai_mask_id = "joy",
					ai_character_id = "ai_joy",
					ssuffix = "z"
				},
				body_g_object = Idstring("g_body")
			},
			{
				name = "myh",
				order = 20,
				static_data = {
					voice = "rb22",
					ai_mask_id = "myh",
					ai_character_id = "ai_myh",
					ssuffix = "ac"
				},
				body_g_object = Idstring("g_body_myh")
			},
			{
				name = "ecp_male",
				order = 21,
				static_data = {
					voice = "rb20",
					ai_mask_id = "ecp_male",
					ai_character_id = "ai_ecp_male",
					ssuffix = "aa"
				},
				body_g_object = Idstring("g_body_ecp_male")
			},
			{
				name = "ecp_female",
				order = 22,
				static_data = {
					voice = "rb21",
					ai_mask_id = "ecp_female",
					ai_character_id = "ai_ecp_female",
					ssuffix = "ab"
				},
				body_g_object = Idstring("g_body_ecp_female")
			}
		},
		character_names = {}
	}

	table.sort(self.criminals.characters, function (a, b)
		return a.order < b.order
	end)

	for _, character in ipairs(self.criminals.characters) do
		table.insert(self.criminals.character_names, character.name)
	end

	self:init_screen_colors()

	self.hud_icons = HudIconsTweakData:new()
	self.weapon = WeaponTweakData:new(self)
	local weapon_tweak_meta = {
		__index = function (table, key)
			if key == "category" then
				local categories = rawget(table, "categories")

				return categories and categories[1]
			elseif key == "sub_category" then
				local categories = rawget(table, "categories")

				return categories and categories[2]
			end
		end
	}

	for key, table in pairs(self.weapon) do
		if not getmetatable(table) then
			table.category = nil
			table.sub_category = nil

			setmetatable(table, weapon_tweak_meta)
		end
	end

	self.equipments = EquipmentsTweakData:new()
	self.player = PlayerTweakData:new()
	self.levels = LevelsTweakData:new()

	self._init_wip_levels(self.levels)

	self.character = CharacterTweakData:new(self)
	self.statistics = StatisticsTweakData:new()
	self.narrative = NarrativeTweakData:new(self)

	self._init_wip_narrative(self.narrative)

	self.group_ai = GroupAITweakData:new(self)
	self.drama = DramaTweakData:new()
	self.upgrades = UpgradesTweakData:new(self)

	self._init_wip_upgrades(self.upgrades)

	self.skilltree = SkillTreeTweakData:new()

	self._init_wip_skilltree(self.skilltree)

	self.upgrades.visual = UpgradesVisualTweakData:new()
	self.tips = TipsTweakData:new()
	self.money_manager = MoneyTweakData:new(self)
	self.blackmarket = BlackMarketTweakData:new(self)

	self._init_wip_blackmarket(self.blackmarket, self)

	self.carry = CarryTweakData:new(self)
	self.mission_door = MissionDoorTweakData:new()
	self.attention = AttentionTweakData:new()
	self.timespeed = TimeSpeedEffectTweakData:new()
	self.sound = SoundTweakData:new()
	self.lootdrop = LootDropTweakData:new(self)
	self.gui = GuiTweakData:new(self)
	self.assets = AssetsTweakData:new(self)

	self._init_wip_assets(self.assets, self)

	self.dlc = DLCTweakData:new(self)
	self.infamy = InfamyTweakData:new(self)
	self.gage_assignment = GageAssignmentTweakData:new(self)
	self.preplanning = PrePlanningTweakData:new(self)
	self.safehouse = CustomSafehouseTweakData:new(self)
	self.interaction = InteractionTweakData:new(self)
	self.vehicle = VehicleTweakData:new(self)
	self.economy = EconomyTweakData:new(self)

	self._init_wip_economy(self.economy, self)

	self.achievement = AchievementsTweakData:new(self)
	self.van = VanSkinsTweakData:new(self)
	self.env_effect = EnvEffectTweakData:new()
	self.tango = TangoTweakData:new(self)
	self.subtitles = SubtitleTweakData:new(self)
	self.input = InputTweakData:new(self)
	self.crime_spree = CrimeSpreeTweakData:new(self)
	self.fire = FireTweakData:new(self)
	self.network = NetworkTweakData:new(self)
	self.animation = AnimationTweakData:new(self)
	self.story = StoryMissionsTweakData:new(self)
	self.promo_unlocks = PromoUnlocksTweakData:new(self)
	self.raid_jobs = RaidJobsTweakData:new(self)

	self.blackmarket:build_player_style_list(self)

	self.ai_carry = {
		throw_distance = 500,
		throw_force = 100,
		revive_distance_autopickup = 300,
		death_distance_teleport = 300
	}
	self.custom_colors = {
		defaults = {}
	}
	self.custom_colors.defaults.laser = Color(0, 0.4, 0)
	self.custom_colors.defaults.flashlight = Color(1, 1, 1)
	self.custom_colors.defaults.laser_alpha = 0.2
	self.EFFECT_QUALITY = 0.5

	if SystemInfo:platform() == Idstring("X360") then
		self.EFFECT_QUALITY = 0.5
	elseif SystemInfo:platform() == Idstring("PS3") then
		self.EFFECT_QUALITY = 0.5
	end

	self:set_scale()
	self:_init_pd2()

	self.menu_themes = {
		old = {
			bg_support = "guis/textures/menu/old_theme/bg_support",
			bg_setupgame = "guis/textures/menu/old_theme/bg_setupgame",
			bg_lobby_fullteam = "guis/textures/menu/old_theme/bg_lobby_fullteam",
			bg_upgrades = "guis/textures/menu/old_theme/bg_upgrades",
			background = "guis/textures/menu/old_theme/background",
			bg_hoxton = "guis/textures/menu/old_theme/bg_hoxton",
			bg_options = "guis/textures/menu/old_theme/bg_options",
			bg_technician = "guis/textures/menu/old_theme/bg_technician",
			bg_dlc = "guis/textures/menu/old_theme/bg_dlc",
			bg_stats = "guis/textures/menu/old_theme/bg_stats",
			bg_creategame = "guis/textures/menu/old_theme/bg_creategame",
			bg_challenge = "guis/textures/menu/old_theme/bg_challenge",
			bg_assault = "guis/textures/menu/old_theme/bg_assault",
			bg_wolf = "guis/textures/menu/old_theme/bg_wolf",
			bg_chains = "guis/textures/menu/old_theme/bg_chains",
			bg_sharpshooter = "guis/textures/menu/old_theme/bg_sharpshooter",
			bg_startscreen = "guis/textures/menu/old_theme/bg_startscreen",
			bg_dallas = "guis/textures/menu/old_theme/bg_dallas"
		},
		fire = {
			bg_support = "guis/textures/menu/fire_theme/bg_support",
			bg_setupgame = "guis/textures/menu/fire_theme/bg_setupgame",
			bg_lobby_fullteam = "guis/textures/menu/fire_theme/bg_lobby_fullteam",
			bg_upgrades = "guis/textures/menu/fire_theme/bg_upgrades",
			background = "guis/textures/menu/fire_theme/background",
			bg_hoxton = "guis/textures/menu/fire_theme/bg_hoxton",
			bg_options = "guis/textures/menu/fire_theme/bg_options",
			bg_technician = "guis/textures/menu/fire_theme/bg_technician",
			bg_dlc = "guis/textures/menu/fire_theme/bg_dlc",
			bg_stats = "guis/textures/menu/fire_theme/bg_stats",
			bg_creategame = "guis/textures/menu/fire_theme/bg_creategame",
			bg_challenge = "guis/textures/menu/fire_theme/bg_challenge",
			bg_assault = "guis/textures/menu/fire_theme/bg_assault",
			bg_wolf = "guis/textures/menu/fire_theme/bg_wolf",
			bg_chains = "guis/textures/menu/fire_theme/bg_chains",
			bg_sharpshooter = "guis/textures/menu/fire_theme/bg_sharpshooter",
			bg_startscreen = "guis/textures/menu/fire_theme/bg_startscreen",
			bg_dallas = "guis/textures/menu/fire_theme/bg_dallas"
		},
		zombie = {
			bg_support = "guis/textures/menu/zombie_theme/bg_support",
			bg_setupgame = "guis/textures/menu/zombie_theme/bg_setupgame",
			bg_lobby_fullteam = "guis/textures/menu/zombie_theme/bg_lobby_fullteam",
			bg_upgrades = "guis/textures/menu/zombie_theme/bg_upgrades",
			background = "guis/textures/menu/zombie_theme/background",
			bg_hoxton = "guis/textures/menu/zombie_theme/bg_hoxton",
			bg_options = "guis/textures/menu/zombie_theme/bg_options",
			bg_technician = "guis/textures/menu/zombie_theme/bg_technician",
			bg_dlc = "guis/textures/menu/fire_theme/bg_dlc",
			bg_stats = "guis/textures/menu/zombie_theme/bg_stats",
			bg_creategame = "guis/textures/menu/zombie_theme/bg_creategame",
			bg_challenge = "guis/textures/menu/zombie_theme/bg_challenge",
			bg_assault = "guis/textures/menu/zombie_theme/bg_assault",
			bg_wolf = "guis/textures/menu/zombie_theme/bg_wolf",
			bg_chains = "guis/textures/menu/zombie_theme/bg_chains",
			bg_sharpshooter = "guis/textures/menu/zombie_theme/bg_sharpshooter",
			bg_startscreen = "guis/textures/menu/zombie_theme/bg_startscreen",
			bg_dallas = "guis/textures/menu/zombie_theme/bg_dallas"
		}
	}
	self.states = {
		title = {}
	}
	self.states.title.ATTRACT_VIDEO_DELAY = 90
	self.menu = {
		BRIGHTNESS_CHANGE = 0.05,
		MIN_BRIGHTNESS = 0.5,
		MAX_BRIGHTNESS = 1.5,
		MUSIC_CHANGE = 10,
		MIN_MUSIC_VOLUME = 0,
		MAX_MUSIC_VOLUME = 100,
		SFX_CHANGE = 10,
		MIN_SFX_VOLUME = 0,
		MAX_SFX_VOLUME = 100,
		VOICE_CHANGE = 0.05,
		MIN_VOICE_VOLUME = 0,
		MAX_VOICE_VOLUME = 1
	}

	self:set_menu_scale()

	local orange = Vector3(204, 161, 102) / 255
	local green = Vector3(194, 252, 151) / 255
	local brown = Vector3(178, 104, 89) / 255
	local blue = Vector3(120, 183, 204) / 255
	local team_ai = Vector3(0.2, 0.8, 1)
	self.peer_vector_colors = {
		green,
		blue,
		brown,
		orange,
		team_ai
	}
	self.peer_colors = {
		"mrgreen",
		"mrblue",
		"mrbrown",
		"mrorange",
		"mrai"
	}
	self.system_chat_color = Color(255, 255, 212, 0) / 255
	self.chat_colors = {
		Color(self.peer_vector_colors[1]:unpack()),
		Color(self.peer_vector_colors[2]:unpack()),
		Color(self.peer_vector_colors[3]:unpack()),
		Color(self.peer_vector_colors[4]:unpack()),
		Color(self.peer_vector_colors[5]:unpack())
	}
	self.preplanning_peer_colors = {
		Color("ff82991e"),
		Color("ff0055ff"),
		Color("ffff7800"),
		Color("ffffff00")
	}
	self.dialog = {
		WIDTH = 400,
		HEIGHT = 300,
		PADDING = 30,
		BUTTON_PADDING = 5,
		BUTTON_SPACING = 10,
		FONT = self.menu.default_font,
		BG_COLOR = self.menu.default_menu_background_color,
		TITLE_TEXT_COLOR = Color(1, 1, 1, 1),
		TEXT_COLOR = self.menu.default_font_row_item_color,
		BUTTON_BG_COLOR = Color(0, 0.5, 0.5, 0.5),
		BUTTON_TEXT_COLOR = self.menu.default_font_row_item_color,
		SELECTED_BUTTON_BG_COLOR = self.menu.default_font_row_item_color,
		SELECTED_BUTTON_TEXT_COLOR = self.menu.default_hightlight_row_item_color,
		TITLE_SIZE = self.menu.topic_font_size,
		TEXT_SIZE = self.menu.dialog_text_font_size,
		BUTTON_SIZE = self.menu.dialog_title_font_size,
		TITLE_TEXT_SPACING = 20,
		BUTTON_TEXT_SPACING = 3,
		DEFAULT_PRIORITY = 1,
		MINIMUM_DURATION = 2,
		DURATION_PER_CHAR = 0.07
	}
	self.hud = {}

	self:set_hud_values()

	self.gui = self.gui or {}
	self.gui.BOOT_SCREEN_LAYER = 1
	self.gui.TITLE_SCREEN_LAYER = 1
	self.gui.MENU_LAYER = 200
	self.gui.MENU_COMPONENT_LAYER = 300
	self.gui.ATTRACT_SCREEN_LAYER = 400
	self.gui.LOADING_SCREEN_LAYER = 1000
	self.gui.CRIMENET_CHAT_LAYER = 1000
	self.gui.DIALOG_LAYER = 1100
	self.gui.MOUSE_LAYER = 1200
	self.gui.SAVEFILE_LAYER = 1400
	self.color_grading = {
		{
			value = "color_payday",
			text_id = "menu_color_off"
		},
		{
			text_id = "menu_color_default"
		},
		{
			value = "color_heat",
			text_id = "menu_color_heat"
		},
		{
			value = "color_nice",
			text_id = "menu_color_nice"
		},
		{
			value = "color_bhd",
			text_id = "menu_color_bhd"
		},
		{
			value = "color_xgen",
			text_id = "menu_color_xgen"
		},
		{
			value = "color_xxxgen",
			text_id = "menu_color_xxxgen"
		},
		{
			value = "color_matrix_classic",
			text_id = "menu_color_matrix_classic"
		},
		{
			value = "color_sin_classic",
			text_id = "menu_color_sin_classic"
		},
		{
			value = "color_sepia",
			text_id = "menu_color_sepia"
		},
		{
			value = "color_sunsetstrip",
			text_id = "menu_color_sunsetstrip"
		},
		{
			value = "color_colorful",
			text_id = "menu_color_colorful"
		},
		{
			value = "color_madplanet",
			text_id = "menu_color_madplanet"
		}
	}
	self.overlay_effects = {
		spectator = {
			blend_mode = "normal",
			fade_out = 2,
			play_paused = true,
			fade_in = 3,
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		level_fade_in = {
			blend_mode = "normal",
			sustain = 1,
			play_paused = true,
			fade_in = 0,
			fade_out = 3,
			color = Color(1, 0, 0, 0),
			timer = TimerManager:game()
		},
		fade_in = {
			blend_mode = "normal",
			sustain = 0,
			play_paused = true,
			fade_in = 0,
			fade_out = 3,
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		fade_out = {
			blend_mode = "normal",
			sustain = 30,
			play_paused = true,
			fade_in = 3,
			fade_out = 0,
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		fade_out_permanent = {
			blend_mode = "normal",
			fade_out = 0,
			play_paused = true,
			fade_in = 1,
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		fade_out_in = {
			blend_mode = "normal",
			sustain = 1,
			play_paused = true,
			fade_in = 1,
			fade_out = 1,
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		white_fade_in = {
			blend_mode = "add",
			sustain = 0,
			play_paused = true,
			fade_in = 0,
			fade_out = 3,
			color = Color(1, 1, 1, 1),
			timer = TimerManager:main()
		},
		white_fade_out = {
			blend_mode = "add",
			sustain = 30,
			play_paused = true,
			fade_in = 3,
			fade_out = 0,
			color = Color(1, 1, 1, 1),
			timer = TimerManager:main()
		},
		white_fade_out_permanent = {
			blend_mode = "add",
			fade_out = 0,
			play_paused = true,
			fade_in = 1,
			color = Color(1, 1, 1, 1),
			timer = TimerManager:main()
		},
		white_fade_out_in = {
			blend_mode = "add",
			sustain = 1,
			play_paused = true,
			fade_in = 1,
			fade_out = 1,
			color = Color(1, 1, 1, 1),
			timer = TimerManager:main()
		},
		element_fade_in = {
			blend_mode = "normal",
			sustain = 0,
			play_paused = true,
			fade_in = 0,
			fade_out = 3,
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		element_fade_out = {
			blend_mode = "normal",
			sustain = 0,
			play_paused = true,
			fade_in = 3,
			fade_out = 0,
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		}
	}
	local d_color = Color(0.75, 1, 1, 1)
	local d_sustain = 0.1
	local d_fade_out = 0.9
	self.overlay_effects.damage = {
		blend_mode = "add",
		fade_in = 0,
		sustain = d_sustain,
		fade_out = d_fade_out,
		color = d_color
	}
	self.overlay_effects.damage_left = {
		blend_mode = "add",
		fade_in = 0,
		orientation = "horizontal",
		sustain = d_sustain,
		fade_out = d_fade_out,
		color = d_color,
		gradient_points = {
			0,
			d_color,
			0.1,
			d_color,
			0.15,
			Color():with_alpha(0),
			1,
			Color():with_alpha(0)
		}
	}
	self.overlay_effects.damage_right = {
		blend_mode = "add",
		fade_in = 0,
		orientation = "horizontal",
		sustain = d_sustain,
		fade_out = d_fade_out,
		color = d_color,
		gradient_points = {
			1,
			d_color,
			0.9,
			d_color,
			0.85,
			Color():with_alpha(0),
			0,
			Color():with_alpha(0)
		}
	}
	self.overlay_effects.damage_up = {
		blend_mode = "add",
		fade_in = 0,
		orientation = "vertical",
		sustain = d_sustain,
		fade_out = d_fade_out,
		color = d_color,
		gradient_points = {
			0,
			d_color,
			0.1,
			d_color,
			0.15,
			Color():with_alpha(0),
			1,
			Color():with_alpha(0)
		}
	}
	self.overlay_effects.damage_down = {
		blend_mode = "add",
		fade_in = 0,
		orientation = "vertical",
		sustain = d_sustain,
		fade_out = d_fade_out,
		color = d_color,
		gradient_points = {
			1,
			d_color,
			0.9,
			d_color,
			0.85,
			Color():with_alpha(0),
			0,
			Color():with_alpha(0)
		}
	}
	self.overlay_effects.maingun_zoomed = {
		blend_mode = "add",
		fade_in = 0,
		sustain = 0,
		fade_out = 0.4,
		color = Color(0.1, 1, 1, 1)
	}
	self.overlay_effects.fade_out_e3_demo = {
		text_to_upper = true,
		sustain = 30,
		blend_mode = "normal",
		fade_in = 3,
		text_blend_mode = "add",
		fade_out = 0,
		font = "fonts/font_large_mf",
		text = [[
Great job, gang!

You've reached the end of our E3 demo.
Play the full version soon to get your full PAYDAY!]],
		font_size = 44,
		play_paused = true,
		color = Color(1, 0, 0, 0),
		timer = TimerManager:main(),
		text_color = Color(255, 255, 204, 0) / 255
	}
	self.overlay_effects.fade_out_mex = {
		text_to_upper = true,
		sustain = 4,
		localize = true,
		fade_in = 1,
		text_blend_mode = "add",
		fade_out = 1,
		font = "fonts/font_large_mf",
		text = "heist_mex_transition",
		font_size = 44,
		blend_mode = "normal",
		color = Color(1, 0, 0, 0),
		timer = TimerManager:main(),
		text_color = Color(255, 255, 153, 0) / 255
	}
	self.overlay_effects.fade_out_e3_video = {
		blend_mode = "normal",
		fade_in = 0,
		sustain = 0,
		fade_out = 0,
		color = Color(1, 0, 0, 0)
	}
	self.materials = {
		[Idstring("concrete"):key()] = "concrete",
		[Idstring("ceramic"):key()] = "ceramic",
		[Idstring("marble"):key()] = "marble",
		[Idstring("flesh"):key()] = "flesh",
		[Idstring("parket"):key()] = "parket",
		[Idstring("sheet_metal"):key()] = "sheet_metal",
		[Idstring("iron"):key()] = "iron",
		[Idstring("wood"):key()] = "wood",
		[Idstring("gravel"):key()] = "gravel",
		[Idstring("cloth"):key()] = "cloth",
		[Idstring("cloth_no_decal"):key()] = "cloth",
		[Idstring("cloth_stuffed"):key()] = "cloth_stuffed",
		[Idstring("dirt"):key()] = "dirt",
		[Idstring("grass"):key()] = "grass",
		[Idstring("carpet"):key()] = "carpet",
		[Idstring("metal"):key()] = "metal",
		[Idstring("glass_breakable"):key()] = "glass_breakable",
		[Idstring("glass_unbreakable"):key()] = "glass_unbreakable",
		[Idstring("glass_no_decal"):key()] = "glass_unbreakable",
		[Idstring("rubber"):key()] = "rubber",
		[Idstring("plastic"):key()] = "plastic",
		[Idstring("asphalt"):key()] = "asphalt",
		[Idstring("foliage"):key()] = "foliage",
		[Idstring("stone"):key()] = "stone",
		[Idstring("sand"):key()] = "sand",
		[Idstring("thin_layer"):key()] = "thin_layer",
		[Idstring("no_decal"):key()] = "silent_material",
		[Idstring("plaster"):key()] = "plaster",
		[Idstring("no_material"):key()] = "no_material",
		[Idstring("paper"):key()] = "paper",
		[Idstring("metal_hollow"):key()] = "metal_hollow",
		[Idstring("metal_chassis"):key()] = "metal_chassis",
		[Idstring("metal_catwalk"):key()] = "metal_catwalk",
		[Idstring("hardwood"):key()] = "hardwood",
		[Idstring("fence"):key()] = "fence",
		[Idstring("steel"):key()] = "steel",
		[Idstring("steel_no_decal"):key()] = "steel",
		[Idstring("tile"):key()] = "tile",
		[Idstring("water_deep"):key()] = "water_deep",
		[Idstring("water_puddle"):key()] = "water_puddle",
		[Idstring("water_shallow"):key()] = "water_puddle",
		[Idstring("shield"):key()] = "shield",
		[Idstring("heavy_swat_steel_no_decal"):key()] = "shield",
		[Idstring("snow"):key()] = "snow",
		[Idstring("ice"):key()] = "ice_thick",
		[Idstring("aim_debug"):key()] = "aim_debug"
	}
	self.screen = {
		fadein_delay = 1
	}
	self.experience_manager = {
		values = {}
	}
	self.experience_manager.values.size02 = 0
	self.experience_manager.values.size03 = 10
	self.experience_manager.values.size04 = 15
	self.experience_manager.values.size06 = 25
	self.experience_manager.values.size08 = 40
	self.experience_manager.values.size10 = 80
	self.experience_manager.values.size12 = 100
	self.experience_manager.values.size14 = 150
	self.experience_manager.values.size16 = 250
	self.experience_manager.values.size18 = 500
	self.experience_manager.values.size20 = 1000
	self.experience_manager.loot_drop_value = {
		xp10 = 2000,
		xp20 = 4000,
		xp30 = 6000,
		xp40 = 10000,
		xp50 = 12000,
		xp60 = 15000,
		xp70 = 20000,
		xp80 = 24000,
		xp90 = 28000,
		xp100 = 32000
	}
	self.experience_manager.stage_completion = {
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}
	self.experience_manager.job_completion = {
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}
	self.experience_manager.stage_failed_multiplier = 0.01
	self.experience_manager.in_custody_multiplier = 0.7
	self.experience_manager.pro_job_multiplier = 1.2
	self.experience_manager.difficulty_multiplier = {
		2,
		5,
		10,
		11.5,
		13,
		14
	}
	self.experience_manager.alive_humans_multiplier = {
		[0] = 1,
		1,
		1.1,
		1.2,
		1.3
	}
	self.experience_manager.limited_bonus_multiplier = 1
	self.experience_manager.level_limit = {
		low_cap_level = -1,
		low_cap_multiplier = 0.75,
		pc_difference_multipliers = {
			0.9,
			0.8,
			0.7,
			0.6,
			0.5,
			0.4,
			0.3,
			0.2,
			0.1,
			0.01
		}
	}
	self.experience_manager.civilians_killed = 0
	self.experience_manager.day_multiplier = {
		1,
		1,
		1,
		4,
		5,
		6,
		7
	}
	self.experience_manager.pro_day_multiplier = {
		1,
		1,
		1,
		5.5,
		7,
		8.5,
		10
	}
	self.experience_manager.total_level_objectives = 500
	self.experience_manager.total_criminals_finished = 50
	self.experience_manager.total_objectives_finished = 500
	local multiplier = 1
	self.experience_manager.levels = {
		{
			points = 900 * multiplier
		},
		{
			points = 1250 * multiplier
		},
		{
			points = 1550 * multiplier
		},
		{
			points = 1850 * multiplier
		},
		{
			points = 2200 * multiplier
		},
		{
			points = 2600 * multiplier
		},
		{
			points = 3000 * multiplier
		},
		{
			points = 3500 * multiplier
		},
		{
			points = 4000 * multiplier
		}
	}
	local exp_step_start = 10
	local exp_step_end = 100
	local exp_step = 1 / (exp_step_end - exp_step_start)
	local exp_step_last_points = 4600
	local exp_step_curve = 3

	for i = exp_step_start, exp_step_end, 1 do
		self.experience_manager.levels[i] = {
			points = math.round((1000000 - exp_step_last_points) * math.pow(exp_step * (i - exp_step_start), exp_step_curve) + exp_step_last_points) * multiplier
		}
	end

	local exp_step_start = 5
	local exp_step_end = 193
	local exp_step = 1 / (exp_step_end - exp_step_start)

	for i = 146, exp_step_end, 1 do
		self.experience_manager.levels[i] = {
			points = math.round(22000 * exp_step * (i - exp_step_start) - 6000) * multiplier
		}
	end

	self.pickups = {
		ammo = {
			unit = Idstring("units/pickups/ammo/ammo_pickup")
		},
		bank_manager_key = {
			unit = Idstring("units/pickups/pickup_bank_manager_key/pickup_bank_manager_key")
		},
		chavez_key = {
			unit = Idstring("units/pickups/pickup_chavez_key/pickup_chavez_key")
		},
		gen_fbi_usb_stick = {
			unit = Idstring("units/pd2_dlc_friend/props/sfm_fbi_usb_stick/sfm_fbi_usb_stick")
		},
		sfm_fbi_usb_stick = {
			unit = Idstring("units/pd2_dlc_friend/props/sfm_fbi_usb_stick/sfm_fbi_usb_stick")
		},
		drill = {
			unit = Idstring("units/pickups/pickup_drill/pickup_drill")
		},
		keycard = {
			unit = Idstring("units/payday2/pickups/gen_pku_keycard/gen_pku_keycard")
		},
		keycard_outlined = {
			unit = Idstring("units/pd2_dlc_red/pickups/gen_pku_keycard_outlined/gen_pku_keycard_outlined")
		},
		keycard_standard_outlined = {
			unit = Idstring("units/payday2/pickups/gen_pku_keycard_standard_outline/gen_pku_keycard_standard_outline")
		},
		hotel_room_key = {
			unit = Idstring("units/pd2_dlc_casino/props/cas_prop_keycard/cas_prop_keycard")
		},
		pku_rambo = {
			unit = Idstring("units/pd2_dlc_jolly/pickups/gen_pku_rambo/gen_pku_rambo")
		},
		keycard_outlined_waypoint = {
			unit = Idstring("units/pd2_dlc_red/pickups/gen_pku_keycard_outlined_waypoint/gen_pku_keycard_outlined_waypoint")
		}
	}
	self.danger_zones = {
		0.6,
		0.5,
		0.35,
		0.1
	}
	self.contour = {
		character = {}
	}
	self.contour.character.standard_color = Vector3(0.1, 1, 0.5)
	self.contour.character.friendly_color = Vector3(0.2, 0.8, 1)
	self.contour.character.downed_color = Vector3(1, 0.5, 0)
	self.contour.character.dead_color = Vector3(1, 0.1, 0.1)
	self.contour.character.dangerous_color = Vector3(0.6, 0.2, 0.2)
	self.contour.character.more_dangerous_color = Vector3(1, 0.1, 0.1)
	self.contour.character.standard_opacity = 0
	self.contour.character.heal_color = Vector3(0, 1, 0)
	self.contour.character_interactable = {
		standard_color = Vector3(1, 0.5, 0),
		selected_color = Vector3(1, 1, 1)
	}
	self.contour.interactable = {
		standard_color = Vector3(1, 0.5, 0),
		selected_color = Vector3(1, 1, 1)
	}
	self.contour.contour_off = {
		standard_color = Vector3(0, 0, 0),
		selected_color = Vector3(0, 0, 0),
		standard_opacity = 0
	}
	self.contour.deployable = {
		standard_color = Vector3(0.1, 1, 0.5),
		selected_color = Vector3(1, 1, 1),
		active_color = Vector3(0.1, 0.5, 1),
		interact_color = Vector3(0.1, 1, 0.1),
		disabled_color = Vector3(1, 0.1, 0.1)
	}
	self.contour.upgradable = {
		standard_color = Vector3(0.1, 0.5, 1),
		selected_color = Vector3(1, 1, 1)
	}
	self.contour.pickup = {
		standard_color = Vector3(0.1, 1, 0.5),
		selected_color = Vector3(1, 1, 1),
		standard_opacity = 1
	}
	self.contour.interactable_icon = {
		standard_color = Vector3(0, 0, 0),
		selected_color = Vector3(0, 1, 0),
		standard_opacity = 0
	}
	self.contour.interactable_look_at = {
		standard_color = Vector3(0, 0, 0),
		selected_color = Vector3(1, 1, 1)
	}
	self.music = {
		hit = {}
	}
	self.music.hit.intro = "music_hit_setup"
	self.music.hit.anticipation = "music_hit_anticipation"
	self.music.hit.assault = "music_hit_assault"
	self.music.hit.fake_assault = "music_hit_assault"
	self.music.hit.control = "music_hit_control"
	self.music.stress = {
		intro = "music_stress_setup",
		anticipation = "music_stress_anticipation",
		assault = "music_stress_assault",
		fake_assault = "music_stress_assault",
		control = "music_stress_control"
	}
	self.music.stealth = {
		intro = "music_stealth_setup",
		anticipation = "music_stealth_anticipation",
		assault = "music_stealth_assault",
		fake_assault = "music_stealth_assault",
		control = "music_stealth_control"
	}
	self.music.heist = {
		intro = "music_heist_setup",
		anticipation = "music_heist_anticipation",
		assault = "music_heist_assault",
		fake_assault = "music_heist_assault",
		control = "music_heist_control"
	}
	self.music.big_bank = {
		intro = "music_heist_setup",
		anticipation = "music_heist_anticipation",
		assault = "music_heist_assault",
		fake_assault = "music_heist_assault",
		control = "music_heist_control"
	}
	self.music.default = deep_clone(self.music.heist)
	self.music.track_list = {
		{
			track = "track_01"
		},
		{
			track = "track_02"
		},
		{
			track = "track_03"
		},
		{
			track = "track_04"
		},
		{
			track = "track_05"
		},
		{
			track = "track_06"
		},
		{
			track = "track_07"
		},
		{
			track = "track_08"
		},
		{
			track = "track_09",
			lock = "armored"
		},
		{
			track = "track_10"
		},
		{
			track = "track_11",
			lock = "infamy"
		},
		{
			track = "track_12",
			lock = "deathwish"
		},
		{
			track = "track_13"
		},
		{
			track = "track_14",
			lock = "bigbank"
		},
		{
			track = "track_15"
		},
		{
			track = "track_16"
		},
		{
			track = "track_17",
			lock = "assault"
		},
		{
			track = "track_18",
			lock = "miami"
		},
		{
			track = "track_19",
			lock = "miami"
		},
		{
			track = "track_20"
		},
		{
			track = "track_21"
		},
		{
			track = "track_22"
		},
		{
			track = "track_23"
		},
		{
			track = "track_24",
			lock = "diamond"
		},
		{
			track = "track_25",
			lock = "thebomb"
		},
		{
			track = "track_26"
		},
		{
			track = "track_27"
		},
		{
			track = "track_28"
		},
		{
			track = "track_29",
			lock = "kenaz"
		},
		{
			track = "track_30"
		},
		{
			track = "track_31"
		},
		{
			track = "track_35"
		},
		{
			track = "track_36"
		},
		{
			track = "track_37",
			lock = "berry"
		},
		{
			track = "track_38",
			lock = "berry"
		},
		{
			track = "track_39"
		},
		{
			track = "track_40",
			lock = "peta"
		},
		{
			track = "track_41",
			lock = "peta"
		},
		{
			track = "track_42",
			lock = "pal"
		},
		{
			track = "track_43",
			lock = "pal"
		},
		{
			track = "track_44"
		},
		{
			track = "track_45",
			lock = "born"
		},
		{
			track = "track_46",
			lock = "born"
		},
		{
			track = "track_47_gen"
		},
		{
			track = "track_48"
		},
		{
			track = "track_49"
		},
		{
			track = "track_50",
			lock = "friend"
		},
		{
			track = "track_51",
			lock = "spa"
		},
		{
			track = "track_52"
		},
		{
			track = "track_53"
		},
		{
			track = "track_54"
		},
		{
			track = "track_55"
		},
		{
			track = "track_56"
		},
		{
			track = "track_57"
		},
		{
			track = "track_58"
		},
		{
			track = "track_59"
		},
		{
			track = "track_60"
		},
		{
			track = "track_61"
		},
		{
			track = "track_62_lcv"
		},
		{
			track = "track_63"
		},
		{
			track = "track_64_lcv"
		},
		{
			track = "track_32_lcv"
		},
		{
			track = "track_33_lcv"
		},
		{
			track = "track_34_lcv"
		},
		{
			track = "track_65"
		},
		{
			track = "track_pth_01",
			lock = "payday"
		},
		{
			track = "track_pth_02",
			lock = "payday"
		},
		{
			track = "track_pth_03",
			lock = "payday"
		},
		{
			track = "track_pth_04",
			lock = "payday"
		},
		{
			track = "track_pth_05",
			lock = "payday"
		},
		{
			track = "track_pth_06",
			lock = "payday"
		},
		{
			track = "track_pth_07",
			lock = "payday"
		},
		{
			track = "track_pth_08",
			lock = "payday"
		},
		{
			track = "track_pth_09",
			lock = "payday"
		}
	}
	self.music.track_menu_list = {
		{
			track = "menu_music"
		},
		{
			track = "loadout_music"
		},
		{
			track = "music_loot_drop"
		},
		{
			track = "resultscreen_win"
		},
		{
			track = "resultscreen_lose"
		},
		{
			track = "preplanning_music"
		},
		{
			track = "preplanning_music_old"
		},
		{
			track = "lets_go_shopping_menu"
		},
		{
			track = "this_is_our_time"
		},
		{
			track = "criminals_ambition"
		},
		{
			track = "criminals_ambition_instrumental",
			lock = "soundtrack"
		},
		{
			track = "release_trailer_track",
			lock = "soundtrack"
		},
		{
			track = "ode_all_avidita",
			lock = "soundtrack"
		},
		{
			track = "ode_all_avidita_instrumental",
			lock = "soundtrack"
		},
		{
			track = "drifting",
			lock = "soundtrack"
		},
		{
			track = "im_a_wild_one",
			lock = "soundtrack"
		},
		{
			track = "the_flames_of_love"
		},
		{
			track = "alesso_payday",
			lock = "alesso"
		},
		{
			track = "pb_do_you_wanna",
			lock = "berry"
		},
		{
			track = "pb_i_need_your_love",
			lock = "berry"
		},
		{
			track = "pb_still_breathing",
			lock = "berry"
		},
		{
			track = "pb_take_me_down",
			lock = "berry"
		},
		{
			track = "biting_elbows_bad_motherfucker"
		},
		{
			track = "biting_elbows_for_the_kill"
		},
		{
			track = "half_passed_wicked",
			lock = "born_wild"
		},
		{
			track = "bsides_04_double_lmgs",
			lock = "bsides"
		},
		{
			track = "bsides_11_meat_and_machine_guns",
			lock = "bsides"
		},
		{
			track = "bsides_05_rule_britannia",
			lock = "bsides"
		},
		{
			track = "bsides_07_an_unexpected_call",
			lock = "bsides"
		},
		{
			track = "bsides_13_infamy_2_0",
			lock = "bsides"
		},
		{
			track = "bsides_12_the_enforcer",
			lock = "bsides"
		},
		{
			track = "bsides_03_showdown",
			lock = "bsides"
		},
		{
			track = "bsides_15_duel",
			lock = "bsides"
		},
		{
			track = "bsides_02_swat_attack",
			lock = "bsides"
		},
		{
			track = "bsides_08_this_is_goodbye",
			lock = "bsides"
		},
		{
			track = "bsides_10_zagrebacka",
			lock = "bsides"
		},
		{
			track = "bsides_16_pilgrim",
			lock = "bsides"
		},
		{
			track = "bsides_14_collide",
			lock = "bsides"
		},
		{
			track = "bsides_01_enter_the_hallway",
			lock = "bsides"
		},
		{
			track = "bsides_06_hur_jag_trivs",
			lock = "bsides"
		},
		{
			track = "pth_i_will_give_you_my_all",
			lock = "payday"
		},
		{
			track = "pth_breaking_news",
			lock = "payday"
		},
		{
			track = "pth_breaking_news_instrumental",
			lock = "payday"
		},
		{
			track = "pth_criminal_intent",
			lock = "payday"
		},
		{
			track = "pth_busted",
			lock = "payday"
		},
		{
			track = "pth_busted_instrumental",
			lock = "payday"
		},
		{
			track = "pth_see_you_at_the_safe_house",
			lock = "payday"
		},
		{
			track = "pth_preparations",
			lock = "payday"
		},
		{
			track = "xmas13_a_merry_payday_christmas",
			lock = "xmas"
		},
		{
			track = "xmas13_a_heist_not_attempted_before",
			lock = "xmas"
		},
		{
			track = "xmas13_if_it_has_to_be_christmas",
			lock = "xmas"
		},
		{
			track = "xmas13_ive_been_a_bad_boy",
			lock = "xmas"
		},
		{
			track = "xmas13_christmas_in_prison",
			lock = "xmas"
		},
		{
			track = "xmas13_deck_the_safe_house",
			lock = "xmas"
		},
		{
			track = "xmas13_if_it_has_to_be_christmas_american_version",
			lock = "xmas"
		},
		{
			track = "xmas13_a_merry_payday_christmas_instrumental",
			lock = "xmas"
		},
		{
			track = "xmas13_a_heist_not_attempted_before_instrumental",
			lock = "xmas"
		},
		{
			track = "xmas13_if_it_has_to_be_christmas_instrumental",
			lock = "xmas"
		},
		{
			track = "xmas13_ive_been_a_bad_boy_instrumental",
			lock = "xmas"
		},
		{
			track = "xmas13_christmas_in_prison_instrumental",
			lock = "xmas"
		},
		{
			track = "xmas13_deck_the_safe_house_instrumental",
			lock = "xmas"
		},
		{
			track = "its_payday"
		},
		{
			track = "music_tag"
		}
	}
	self.music.soundbank_list = {
		"soundbanks/music",
		"soundbanks/music_alesso"
	}
	self.blame = {
		default = "hint_blame_missing",
		empty = nil,
		cam_criminal = "hint_cam_criminal",
		cam_dead_body = "hint_cam_dead_body",
		cam_hostage = "hint_cam_hostage",
		cam_distress = "hint_cam_distress",
		cam_body_bag = "hint_body_bag",
		cam_gunfire = "hint_gunfire",
		cam_drill = "hint_cam_drill",
		cam_saw = "hint_cam_saw",
		cam_sentry_gun = "hint_sentry_gun",
		cam_trip_mine = "hint_trip_mine",
		cam_ecm_jammer = "hint_ecm_jammer",
		cam_c4 = "hint_c4",
		cam_computer = "hint_computer",
		cam_glass = "hint_glass",
		cam_broken_cam = "hint_cam_broken_cam",
		cam_vault = "hint_vault",
		cam_fire = "hint_fire",
		cam_voting = "hint_voting",
		cam_breaking_entering = "hint_breaking_entering",
		civ_criminal = "hint_civ_criminal",
		civ_dead_body = "hint_civ_dead_body",
		civ_hostage = "hint_civ_hostage",
		civ_distress = "hint_civ_distress",
		civ_body_bag = "hint_civ_body_bag",
		civ_gunfire = "hint_civ_gunfire",
		civ_drill = "hint_civ_drill",
		civ_saw = "hint_civ_saw",
		civ_sentry_gun = "hint_civ_sentry_gun",
		civ_trip_mine = "hint_civ_trip_mine",
		civ_ecm_jammer = "hint_civ_ecm_jammer",
		civ_c4 = "hint_civ_c4",
		civ_computer = "hint_civ_computer",
		civ_glass = "hint_civ_glass",
		civ_broken_cam = "hint_civ_broken_cam",
		civ_vault = "hint_civ_vault",
		civ_fire = "hint_civ_fire",
		civ_voting = "hint_civ_voting",
		civ_breaking_entering = "hint_civ_breaking_entering",
		cop_criminal = "hint_cop_criminal",
		cop_dead_body = "hint_cop_dead_body",
		cop_hostage = "hint_cop_hostage",
		cop_distress = "hint_cop_distress",
		cop_body_bag = "hint_cop_body_bag",
		cop_gunfire = "hint_cop_gunfire",
		cop_drill = "hint_cop_drill",
		cop_saw = "hint_cop_saw",
		cop_sentry_gun = "hint_cop_sentry_gun",
		cop_trip_mine = "hint_cop_trip_mine",
		cop_ecm_jammer = "hint_cop_ecm_jammer",
		cop_c4 = "hint_cop_c4",
		cop_computer = "hint_cop_computer",
		cop_glass = "hint_cop_glass",
		cop_broken_cam = "hint_cop_broken_cam",
		cop_vault = "hint_cop_vault",
		cop_fire = "hint_cop_fire",
		cop_voting = "hint_cop_voting",
		cop_breaking_entering = "hint_cop_breaking_entering",
		sys_explosion = "hint_alert_explosion",
		civ_explosion = "hint_alert_explosion",
		cop_explosion = "hint_alert_explosion",
		gan_explosion = "hint_alert_explosion",
		cam_explosion = "hint_alert_explosion",
		sys_blackmailer = "hint_blame_blackmailer",
		sys_gensec = "hint_blame_gensec",
		sys_police_alerted = "hint_blame_police_alerted",
		sys_csgo_gunfire = "hint_blame_csgo_gunfire",
		met_criminal = "hint_met_criminal",
		mot_criminal = "hint_mot_criminal",
		gls_alarm = "hint_alarm_glass",
		alarm_pager_bluff_failed = "hint_alarm_pager_bluff_failed",
		alarm_pager_not_answered = "hint_alarm_pager_not_answered",
		alarm_pager_hang_up = "hint_alarm_pager_hang_up",
		civ_too_many_killed = "hint_civ_too_many_killed",
		civ_alarm = "hint_alarm_civ",
		cop_alarm = "hint_alarm_cop",
		gan_alarm = "hint_alarm_cop",
		cam_crate_open = "hint_cam_crate_open",
		civ_crate_open = "hint_civ_crate_open",
		cop_crate_open = "hint_cop_crate_open",
		gan_crate_open = "hint_cop_crate_open"
	}
	self.casino = {
		unlock_level = 10,
		entrance_level = {
			14,
			28,
			40,
			45,
			55,
			65,
			75
		},
		entrance_fee = {
			500000,
			500000,
			500000,
			750000,
			1000000,
			1250000,
			1500000
		},
		prefer_cost = 500000,
		prefer_chance = 0.1,
		secure_card_cost = {
			1000000,
			3300000,
			6500000
		},
		secure_card_level = {
			10,
			40,
			60
		},
		infamous_cost = 3000000,
		infamous_chance = 3
	}
	self.weapon_disable_crit_for_damage = {
		frag = {
			explosion = false,
			fire = false
		},
		dada_com = {
			explosion = false,
			fire = false
		},
		fir_com = {
			explosion = false,
			fire = false
		},
		launcher_frag = {
			explosion = false,
			fire = false
		},
		launcher_rocket = {
			explosion = false,
			fire = false
		},
		rocket_ray_frag = {
			explosion = false,
			fire = false
		},
		environment_fire = {
			fire = false
		},
		dynamite = {
			fire = false
		},
		launcher_frag_arbiter = {
			explosion = false,
			fire = false
		},
		launcher_m203 = {
			explosion = false,
			fire = false
		}
	}
	self.projectiles = {
		frag = {}
	}
	self.projectiles.frag.damage = 160
	self.projectiles.frag.curve_pow = 0.1
	self.projectiles.frag.player_damage = 10
	self.projectiles.frag.range = 500
	self.projectiles.frag.name_id = "bm_grenade_frag"
	self.projectiles.launcher_frag = {
		damage = 130,
		launch_speed = 1250,
		curve_pow = 0.1,
		player_damage = 8,
		range = 350,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_explode",
		name_id = "bm_launcher_frag"
	}
	self.projectiles.launcher_rocket = {
		damage = 1250,
		launch_speed = 2500,
		curve_pow = 0.1,
		player_damage = 40,
		range = 500,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "rpg_explode",
		name_id = "bm_launcher_rocket"
	}
	self.projectiles.molotov = {
		damage = 3,
		player_damage = 2,
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_damage = 1,
			dot_length = 3,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		},
		range = 75,
		burn_duration = 10,
		burn_tick_period = 0.5,
		sound_event = "molotov_impact",
		sound_event_impact_duration = 4,
		name_id = "bm_grenade_molotov",
		alert_radius = 1500,
		fire_alert_radius = 1500
	}
	self.projectiles.cs_grenade_quick = {
		radius = 300,
		radius_blurzone_multiplier = 1.3,
		damage_tick_period = 0.25,
		damage_per_tick = 0.75
	}
	self.projectiles.launcher_incendiary = {
		damage = 10,
		launch_speed = 1250,
		curve_pow = 0.1,
		player_damage = 2,
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_damage = 25,
			dot_length = 6.1,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		},
		range = 75,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_explode",
		sound_event_impact_duration = 1,
		name_id = "bm_launcher_incendiary",
		burn_duration = 6,
		burn_tick_period = 0.5
	}
	self.projectiles.launcher_frag_m32 = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.launcher_frag_m32.damage = 130
	self.projectiles.launcher_incendiary_m32 = deep_clone(self.projectiles.launcher_incendiary)
	self.projectiles.launcher_frag_china = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.launcher_frag_china.damage = 96
	self.projectiles.launcher_incendiary_china = deep_clone(self.projectiles.launcher_incendiary)
	self.projectiles.launcher_frag_arbiter = {
		damage = 48,
		launch_speed = 7000,
		curve_pow = 0.1,
		player_damage = 8,
		range = 350,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_explode",
		name_id = "bm_launcher_frag"
	}
	self.projectiles.launcher_incendiary_arbiter = {
		damage = 10,
		launch_speed = 7000,
		curve_pow = 0.1,
		player_damage = 2,
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_damage = 25,
			dot_length = 6.1,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		},
		range = 350,
		init_timer = 2.5,
		mass_look_up_modifier = 1,
		sound_event = "gl_explode",
		sound_event_impact_duration = 0.25,
		name_id = "bm_launcher_incendiary",
		burn_duration = 3,
		burn_tick_period = 0.5
	}
	self.projectiles.launcher_frag_slap = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.launcher_incendiary_slap = deep_clone(self.projectiles.launcher_incendiary)
	self.projectiles.fir_com = {
		damage = 3,
		curve_pow = 0.1,
		player_damage = 3,
		fire_dot_data = {
			dot_trigger_chance = 100,
			dot_damage = 25,
			dot_length = 2.1,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		},
		range = 500,
		name_id = "bm_grenade_fir_com",
		sound_event = "white_explosion",
		effect_name = "effects/payday2/particles/explosions/grenade_incendiary_explosion"
	}
	self.projectiles.rocket_frag = {
		launch_speed = 2500,
		adjust_z = 0,
		push_at_body_index = 0
	}
	self.projectiles.west_arrow = {
		damage = 100,
		launch_speed = 2000,
		adjust_z = 0,
		mass_look_up_modifier = 1,
		name_id = "bm_west_arrow",
		push_at_body_index = 0
	}
	self.projectiles.west_arrow_exp = deep_clone(self.projectiles.west_arrow)
	self.projectiles.west_arrow_exp.damage = 75
	self.projectiles.west_arrow_exp.bullet_class = "InstantExplosiveBulletBase"
	self.projectiles.west_arrow_exp.remove_on_impact = true
	self.projectiles.dynamite = {
		damage = 160,
		curve_pow = 0.1,
		player_damage = 10,
		range = 500,
		name_id = "bm_grenade_frag",
		effect_name = "effects/payday2/particles/explosions/dynamite_explosion"
	}
	self.projectiles.bow_poison_arrow = deep_clone(self.projectiles.west_arrow)
	self.projectiles.bow_poison_arrow.damage = 6.6
	self.projectiles.bow_poison_arrow.bullet_class = "PoisonBulletBase"
	self.projectiles.crossbow_arrow = {
		damage = 35,
		launch_speed = 2000,
		adjust_z = 0,
		mass_look_up_modifier = 1,
		push_at_body_index = 0
	}
	self.projectiles.crossbow_poison_arrow = deep_clone(self.projectiles.crossbow_arrow)
	self.projectiles.crossbow_poison_arrow.damage = 10
	self.projectiles.crossbow_poison_arrow.bullet_class = "PoisonBulletBase"
	self.projectiles.crossbow_arrow_exp = deep_clone(self.projectiles.crossbow_arrow)
	self.projectiles.crossbow_arrow_exp.damage = 45
	self.projectiles.crossbow_arrow_exp.bullet_class = "InstantExplosiveBulletBase"
	self.projectiles.crossbow_arrow_exp.remove_on_impact = true
	self.projectiles.wpn_prj_four = {
		damage = 10,
		launch_speed = 1500,
		adjust_z = 0,
		mass_look_up_modifier = 1,
		name_id = "bm_prj_four",
		push_at_body_index = 0,
		dot_data = {
			type = "poison"
		},
		bullet_class = "ProjectilesPoisonBulletBase",
		sounds = {}
	}
	self.projectiles.wpn_prj_four.sounds.flyby = "throwing_star_flyby"
	self.projectiles.wpn_prj_four.sounds.flyby_stop = "throwing_star_flyby_stop"
	self.projectiles.wpn_prj_four.sounds.impact = "throwables_impact_gen"
	self.projectiles.wpn_prj_ace = {
		damage = 4,
		launch_speed = 1500,
		adjust_z = 0,
		mass_look_up_modifier = 1,
		name_id = "bm_prj_ace",
		push_at_body_index = 0,
		sounds = {}
	}
	self.projectiles.wpn_prj_ace.sounds.flyby = "throwing_star_flyby"
	self.projectiles.wpn_prj_ace.sounds.flyby_stop = "throwing_star_flyby_stop"
	self.projectiles.wpn_prj_ace.sounds.impact = "throwables_impact_gen"
	self.projectiles.wpn_prj_jav = {
		damage = 325,
		launch_speed = 1500,
		adjust_z = 30,
		mass_look_up_modifier = 1,
		name_id = "bm_prj_jav",
		push_at_body_index = 0,
		sounds = {}
	}
	self.projectiles.wpn_prj_jav.sounds.flyby = "jav_flyby"
	self.projectiles.wpn_prj_jav.sounds.flyby_stop = "jav_flyby_stop"
	self.projectiles.wpn_prj_jav.sounds.impact = "jav_impact_gen"
	self.projectiles.arblast_arrow = {
		damage = 200,
		launch_speed = 3500,
		adjust_z = 0,
		mass_look_up_modifier = 1,
		push_at_body_index = 0
	}
	self.projectiles.arblast_poison_arrow = deep_clone(self.projectiles.arblast_arrow)
	self.projectiles.arblast_poison_arrow.damage = 30
	self.projectiles.arblast_poison_arrow.bullet_class = "PoisonBulletBase"
	self.projectiles.arblast_arrow_exp = deep_clone(self.projectiles.arblast_arrow)
	self.projectiles.arblast_arrow_exp.damage = 140
	self.projectiles.arblast_arrow_exp.bullet_class = "InstantExplosiveBulletBase"
	self.projectiles.arblast_arrow_exp.remove_on_impact = true
	self.projectiles.frankish_arrow = {
		damage = 75,
		launch_speed = 2500,
		adjust_z = 0,
		mass_look_up_modifier = 1,
		push_at_body_index = 0
	}
	self.projectiles.frankish_poison_arrow = deep_clone(self.projectiles.frankish_arrow)
	self.projectiles.frankish_poison_arrow.damage = 10
	self.projectiles.frankish_poison_arrow.bullet_class = "PoisonBulletBase"
	self.projectiles.frankish_arrow_exp = deep_clone(self.projectiles.frankish_arrow)
	self.projectiles.frankish_arrow_exp.damage = 70
	self.projectiles.frankish_arrow_exp.bullet_class = "InstantExplosiveBulletBase"
	self.projectiles.frankish_arrow_exp.remove_on_impact = true
	self.projectiles.long_arrow = {
		damage = 200,
		launch_speed = 3500,
		adjust_z = -30,
		mass_look_up_modifier = 1,
		push_at_body_index = 0
	}
	self.projectiles.long_poison_arrow = deep_clone(self.projectiles.long_arrow)
	self.projectiles.long_poison_arrow.damage = 30
	self.projectiles.long_poison_arrow.bullet_class = "PoisonBulletBase"
	self.projectiles.long_arrow_exp = deep_clone(self.projectiles.long_arrow)
	self.projectiles.long_arrow_exp.damage = 140
	self.projectiles.long_arrow_exp.bullet_class = "InstantExplosiveBulletBase"
	self.projectiles.long_arrow_exp.remove_on_impact = true
	self.projectiles.wpn_prj_hur = {
		damage = 110,
		launch_speed = 1000,
		adjust_z = 120,
		mass_look_up_modifier = 1,
		name_id = "bm_prj_hur",
		push_at_body_index = "dynamic_body_spinn",
		sounds = {}
	}
	self.projectiles.wpn_prj_hur.sounds.flyby = "hur_flyby"
	self.projectiles.wpn_prj_hur.sounds.flyby_stop = "hur_flyby_stop"
	self.projectiles.wpn_prj_hur.sounds.impact = "hur_impact_gen"
	self.projectiles.wpn_prj_target = {
		damage = 110,
		launch_speed = 1000,
		adjust_z = 120,
		mass_look_up_modifier = 1,
		name_id = "bm_prj_target",
		push_at_body_index = "dynamic_body_spinn",
		sounds = {}
	}
	self.projectiles.wpn_prj_target.sounds.flyby = "target_flyby"
	self.projectiles.wpn_prj_target.sounds.flyby_stop = "target_flyby_stop"
	self.projectiles.wpn_prj_target.sounds.impact = "target_impact_gen"
	self.projectiles.frag_com = {
		damage = 60,
		curve_pow = 0.1,
		range = 1000,
		name_id = "bm_grenade_frag_com"
	}
	self.projectiles.concussion = {
		damage = 0,
		curve_pow = 0.1,
		range = 1500,
		name_id = "bm_concussion",
		sound_event = "concussion_explosion",
		duration = {
			additional = 10,
			min = 4
		}
	}
	self.projectiles.launcher_m203 = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.launcher_m203.projectile_trail = true
	self.projectiles.rocket_ray_frag = deep_clone(self.projectiles.launcher_rocket)
	self.projectiles.rocket_ray_frag.damage = 620
	self.projectiles.rocket_ray_frag.projectile_trail = true
	self.projectiles.rocket_ray_frag.adjust_z = 0
	self.projectiles.rocket_ray_frag.push_at_body_index = 0
	self.projectiles.smoke_screen_grenade = {
		damage = 0,
		curve_pow = 0.1,
		range = 1500,
		name_id = "bm_smoke_screen_grenade",
		duration = 10,
		dodge_chance = 0.5,
		init_timer = 0,
		accuracy_roll_chance = 0.5,
		accuracy_fail_spread = {
			5,
			10
		}
	}
	self.projectiles.dada_com = {
		damage = 160,
		curve_pow = 0.1,
		range = 500,
		name_id = "bm_grenade_dada_com",
		sound_event = "mtl_explosion"
	}
	self.projectiles.ecp_arrow = {
		damage = 70,
		launch_speed = 3500,
		adjust_z = 0,
		mass_look_up_modifier = 1,
		push_at_body_index = 0
	}
	self.projectiles.ecp_arrow_poison = deep_clone(self.projectiles.ecp_arrow)
	self.projectiles.ecp_arrow_poison.damage = 10
	self.projectiles.ecp_arrow_poison.bullet_class = "PoisonBulletBase"
	self.projectiles.ecp_arrow_exp = deep_clone(self.projectiles.ecp_arrow)
	self.projectiles.ecp_arrow_exp.damage = 55
	self.projectiles.ecp_arrow_exp.bullet_class = "InstantExplosiveBulletBase"
	self.projectiles.ecp_arrow_exp.remove_on_impact = true
	self.projectiles.elastic_arrow = {
		damage = 200,
		launch_speed = 3500,
		adjust_z = -130,
		mass_look_up_modifier = 1,
		push_at_body_index = 0
	}
	self.projectiles.elastic_arrow_poison = deep_clone(self.projectiles.elastic_arrow)
	self.projectiles.elastic_arrow_poison.damage = 30
	self.projectiles.elastic_arrow_poison.bullet_class = "PoisonBulletBase"
	self.projectiles.elastic_arrow_exp = deep_clone(self.projectiles.elastic_arrow)
	self.projectiles.elastic_arrow_exp.damage = 140
	self.projectiles.elastic_arrow_exp.bullet_class = "InstantExplosiveBulletBase"
	self.projectiles.elastic_arrow_exp.remove_on_impact = true
	self.voting = {
		timeout = 30,
		cooldown = 50,
		restart_delay = 5
	}
	self.dot_types = {
		poison = {
			damage_class = "PoisonBulletBase",
			dot_damage = 25,
			dot_length = 6,
			hurt_animation_chance = 1
		}
	}
	self.quickplay = {
		default_level_diff = {
			15,
			15
		},
		max_level_diff = {
			40,
			40
		},
		stealth_levels = {}
	}
	self.quickplay.stealth_levels.dark = true
	self.quickplay.stealth_levels.kosugi = true
	self.quickplay.stealth_levels.cage = true
	self.quickplay.stealth_levels.fish = true
	self.quickplay.stealth_levels.tag = true
	self.team_ai = {
		stop_action = {}
	}
	self.team_ai.stop_action.delay = 0.8
	self.team_ai.stop_action.distance = 3000
	self.team_ai.stop_action.teleport_distance = 5000
	self.medic = {
		radius = 400,
		cooldown = 3,
		debug_drawing = false,
		disabled_units = {
			"spooc"
		}
	}
	self.spotlights = {
		helicopter_1 = {
			tracking_speed = 1.2,
			objects = {
				"g_light_cone",
				"g_spotlight",
				"align_spotlight_effect",
				"ls_spotlight"
			},
			wiggle = {
				ang = {
					2,
					6
				},
				speed = {
					50,
					80
				}
			},
			neutral_direction = Vector3(0, 1, -0.7),
			targetting = {
				search_t = 3,
				slot = 12,
				body = "a_body",
				max_distance = math.pow(4000, 2)
			}
		}
	}
	self.promos = PromotionalMenusTweakData:new(self)
	self.vr = TweakDataVR:new(self)

	self:_init_wip_tweak_data()
	self:set_difficulty()

	self.skirmish = SkirmishTweakData:new(self)

	self:set_mode()
	self:digest_tweak_data()
end

function TweakData:load_movie_list()
	local CONFIG_PATH = "gamedata/movie_theater"
	local FILE_EXTENSION = "movie_theater"
	self.movies = {}
	local movie_data = PackageManager:xml_data(FILE_EXTENSION:id(), CONFIG_PATH:id())

	if movie_data then
		for i = 0, movie_data:num_children() - 1, 1 do
			local item = movie_data:child(i):parameter_map()

			if item.file and DB:has(Idstring("movie"), item.file) then
				table.insert(self.movies, item)
			end
		end
	end
end

function TweakData:init_screen_colors()
	self.screen_colors = {
		text = Color(255, 255, 255, 255) / 255,
		resource = Color(255, 77, 198, 255) / 255,
		important_1 = Color(255, 255, 51, 51) / 255,
		important_2 = Color(125, 255, 51, 51) / 255,
		item_stage_1 = Color(255, 255, 255, 255) / 255,
		item_stage_2 = Color(255, 89, 115, 128) / 255,
		item_stage_3 = Color(255, 23, 33, 38) / 255,
		button_stage_1 = Color(255, 0, 0, 0) / 255,
		button_stage_2 = Color(255, 77, 198, 255) / 255,
		button_stage_3 = Color(127, 0, 170, 255) / 255,
		crimenet_lines = Color(255, 127, 157, 182) / 255,
		risk = Color(255, 255, 204, 0) / 255,
		friend_color = Color(255, 41, 204, 122) / 255,
		regular_color = Color(255, 41, 150, 240) / 255,
		pro_color = Color(255, 255, 51, 51) / 255,
		dlc_color = Color(255, 255, 212, 0) / 255,
		skill_color = Color(255, 77, 198, 255) / 255,
		ghost_color = Color("4ca6ff"),
		extra_bonus_color = Color(255, 255, 255, 255) / 255,
		community_color = Color(255, 59, 174, 254) / 255,
		challenge_completed_color = Color(255, 255, 168, 0) / 255,
		stat_maxed = Color("FF00FF"),
		competitive_color = Color(255, 41, 204, 122) / 255,
		event_color = Color(255, 255, 145, 0) / 255,
		infamous_color = Color(1, 0.1, 1),
		mutators_color = Color(255, 211, 133, 255) / 255,
		mutators_color_text = Color(255, 211, 133, 255) / 255,
		crime_spree_risk = Color(255, 255, 255, 0) / 255,
		achievement_grey = Color(255, 145, 145, 145) / 255,
		skirmish_color = Color(255, 255, 85, 30) / 255,
		heat_cold_color = Color(255, 255, 51, 51) / 255,
		heat_warm_color = Color("ff7f00"),
		heat_standard_color = Color(255, 255, 255, 255) / 255
	}
	self.screen_colors.heat_color = self.screen_colors.heat_standard_color
	self.screen_colors.one_down = Color(255, 250, 30, 0) / 255
	self.screen_colors.challenge_title = Color(255, 255, 168, 0) / 255
	self.screen_colors.stats_positive = Color(255, 191, 221, 125) / 255
	self.screen_colors.stats_negative = Color(255, 254, 93, 99) / 255
	self.screen_colors.stats_mods = Color(255, 229, 229, 76) / 255

	if Global.test_new_colors then
		for i, d in pairs(self.screen_colors) do
			self.screen_colors[i] = Color.purple
		end
	end

	if Global.old_colors_purple then
		self.screen_color_white = Color.purple
		self.screen_color_red = Color.purple
		self.screen_color_green = Color.purple
		self.screen_color_grey = Color.purple
		self.screen_color_light_grey = Color.purple
		self.screen_color_blue = Color.purple
		self.screen_color_blue_selected = Color.purple
		self.screen_color_blue_highlighted = Color.purple
		self.screen_color_blue_noselected = Color.purple
		self.screen_color_yellow = Color.purple
		self.screen_color_yellow_selected = Color.purple
		self.screen_color_yellow_noselected = Color.purple
	else
		self.screen_color_white = Color(1, 1, 1)
		self.screen_color_red = Color(0.7137254901960784, 0.24705882352941178, 0.21176470588235294)
		self.screen_color_green = Color(0.12549019607843137, 1, 0.5176470588235295)
		self.screen_color_grey = Color(0.39215686274509803, 0.39215686274509803, 0.39215686274509803)
		self.screen_color_light_grey = Color(0.7843137254901961, 0.7843137254901961, 0.7843137254901961)
		self.screen_color_blue = Color(0.30196078431372547, 0.7764705882352941, 1)
		self.screen_color_blue_selected = Color(0.30196078431372547, 0.7764705882352941, 1)
		self.screen_color_blue_highlighted = self.screen_color_blue_selected:with_alpha(0.75)
		self.screen_color_blue_noselected = self.screen_color_blue_selected:with_alpha(0.5)
		self.screen_color_yellow = Color(0.8627450980392157, 0.6745098039215687, 0.17647058823529413)
		self.screen_color_yellow_selected = Color(1, 0.8, 0)
		self.screen_color_yellow_noselected = Color(0.7333333333333333, 0.42745098039215684, 0.0784313725490196)
	end
end

function TweakData:free_dlc_list()
	local free_dlcs = {}

	return free_dlcs
end

function TweakData:get_dot_type_data(type)
	return self.dot_types[type]
end

function TweakData:_execute_reload_clbks()
	if self._reload_clbks then
		for key, clbk_data in pairs(self._reload_clbks) do
			if clbk_data.func then
				clbk_data.func(clbk_data.clbk_object)
			end
		end
	end
end

function TweakData:add_reload_callback(object, func)
	self._reload_clbks = self._reload_clbks or {}

	table.insert(self._reload_clbks, {
		clbk_object = object,
		func = func
	})
end

function TweakData:remove_reload_callback(object)
	if self._reload_clbks then
		for i, k in ipairs(self._reload_clbks) do
			if k.clbk_object == object then
				table.remove(self._reload_clbks, i)

				return
			end
		end
	end
end

function TweakData:set_scale()
	local lang_key = SystemInfo:language():key()
	local lang_mods = {
		[Idstring("german"):key()] = {
			small = 1,
			level_up_text_kern = -1.5,
			objectives_text_kern = -1,
			sd_menu_border_multiplier = 0.9,
			kit_desc_large = 0.9,
			sd_w_interact_multiplier = 1.55,
			menu_logo_multiplier = 0.9,
			large = 0.9,
			sd_large = 0.9,
			sd_small = 0.9,
			w_interact_multiplier = 1.65,
			stats_upgrade_kern = -1
		},
		[Idstring("french"):key()] = {
			small = 1,
			sd_large = 0.9,
			level_up_text_kern = -1.5,
			sd_level_up_font_multiplier = 0.9,
			stats_upgrade_kern = -1,
			sd_w_interact_multiplier = 1.3,
			kit_desc_large = 0.9,
			subtitle_multiplier = 0.85,
			large = 0.9,
			victory_screen_kern = -0.5,
			sd_small = 0.95,
			w_interact_multiplier = 1.4,
			objectives_text_kern = -0.8
		},
		[Idstring("italian"):key()] = {
			small = 1,
			large = 1,
			sd_large = 1,
			kit_desc_large = 0.9,
			sd_small = 1,
			sd_w_interact_multiplier = 1.5,
			w_interact_multiplier = 1.35,
			objectives_text_kern = -0.8
		},
		[Idstring("spanish"):key()] = {
			level_up_text_kern = -1.5,
			victory_title_multiplier = 0.9,
			objectives_text_kern = -0.8,
			sd_level_up_font_multiplier = 0.9,
			kit_desc_large = 0.9,
			server_list_font_multiplier = 0.9,
			sd_large = 1,
			small = 1,
			objectives_desc_text_kern = 0,
			sd_menu_border_multiplier = 0.85,
			sd_w_interact_multiplier = 1.5,
			menu_logo_multiplier = 0.9,
			large = 1,
			upgrade_menu_kern = -1.25,
			sd_small = 0.9,
			w_interact_multiplier = 1.6,
			stats_upgrade_kern = -1
		}
	}
	local lang_l_mod = lang_mods[lang_key] and lang_mods[lang_key].large or 1
	local lang_s_mod = lang_mods[lang_key] and lang_mods[lang_key].small or 1
	local lang_lsd_mod = lang_mods[lang_key] and lang_mods[lang_key].sd_large or 1
	local lang_ssd_mod = lang_mods[lang_key] and lang_mods[lang_key].sd_large or 1
	local sd_menu_border_multiplier = lang_mods[lang_key] and lang_mods[lang_key].sd_menu_border_multiplier or 1
	local stats_upgrade_kern = lang_mods[lang_key] and lang_mods[lang_key].stats_upgrade_kern or 0
	local level_up_text_kern = lang_mods[lang_key] and lang_mods[lang_key].level_up_text_kern or 0
	local victory_screen_kern = lang_mods[lang_key] and lang_mods[lang_key].victory_screen_kern
	local upgrade_menu_kern = lang_mods[lang_key] and lang_mods[lang_key].upgrade_menu_kern
	local mugshot_name_kern = lang_mods[lang_key] and lang_mods[lang_key].mugshot_name_kern
	local menu_logo_multiplier = lang_mods[lang_key] and lang_mods[lang_key].menu_logo_multiplier or 1
	local objectives_text_kern = lang_mods[lang_key] and lang_mods[lang_key].objectives_text_kern
	local objectives_desc_text_kern = lang_mods[lang_key] and lang_mods[lang_key].objectives_desc_text_kern
	local kit_desc_large = lang_mods[lang_key] and lang_mods[lang_key].kit_desc_large or 1
	local sd_level_up_font_multiplier = lang_mods[lang_key] and lang_mods[lang_key].sd_level_up_font_multiplier or 1
	local sd_w_interact_multiplier = lang_mods[lang_key] and lang_mods[lang_key].sd_w_interact_multiplier or 1
	local w_interact_multiplier = lang_mods[lang_key] and lang_mods[lang_key].w_interact_multiplier or 1
	local server_list_font_multiplier = lang_mods[lang_key] and lang_mods[lang_key].server_list_font_multiplier or 1
	local victory_title_multiplier = lang_mods[lang_key] and lang_mods[lang_key].victory_title_multiplier
	local subtitle_multiplier = lang_mods[lang_key] and lang_mods[lang_key].subtitle_multiplier or 1
	local res = RenderSettings.resolution
	self.sd_scale = {
		is_sd = true,
		title_image_multiplier = 0.6,
		menu_logo_multiplier = 0.575 * menu_logo_multiplier,
		menu_border_multiplier = 0.6 * sd_menu_border_multiplier,
		default_font_multiplier = 0.6 * lang_lsd_mod,
		small_font_multiplier = 0.8 * lang_ssd_mod,
		lobby_info_font_size_scale_multiplier = 0.65,
		lobby_name_font_size_scale_multiplier = 0.6,
		server_list_font_size_multiplier = 0.55,
		multichoice_arrow_multiplier = 0.7,
		align_line_padding_multiplier = 0.4,
		menu_arrow_padding_multiplier = 0.5,
		briefing_text_h_multiplier = 0.5,
		experience_bar_multiplier = 0.825,
		hud_equipment_icon_multiplier = 0.65,
		hud_default_font_multiplier = 0.7,
		hud_ammo_clip_multiplier = 0.75,
		hud_ammo_clip_large_multiplier = 0.5,
		hud_health_multiplier = 0.75,
		hud_mugshot_multiplier = 0.75,
		hud_assault_image_multiplier = 0.5,
		hud_crosshair_offset_multiplier = 0.75,
		hud_objectives_pad_multiplier = 0.65,
		experience_upgrade_multiplier = 0.75,
		level_up_multiplier = 0.7,
		next_upgrade_font_multiplier = 0.75,
		level_up_font_multiplier = 0.51 * sd_level_up_font_multiplier,
		present_multiplier = 0.75,
		lobby_info_offset_multiplier = 0.7,
		info_padding_multiplier = 0.4,
		loading_challenge_bar_scale = 0.8,
		kit_menu_bar_scale = 0.65,
		kit_menu_description_h_scale = 1.22,
		button_layout_multiplier = 0.7,
		subtitle_pos_multiplier = 0.7,
		subtitle_font_multiplier = 0.65,
		subtitle_lang_multiplier = subtitle_multiplier,
		default_font_kern = 0,
		stats_upgrade_kern = stats_upgrade_kern or 0,
		level_up_text_kern = level_up_text_kern or 0,
		victory_screen_kern = victory_screen_kern or -0.5,
		upgrade_menu_kern = upgrade_menu_kern or 0,
		mugshot_name_kern = mugshot_name_kern or -1,
		objectives_text_kern = objectives_text_kern or 0,
		objectives_desc_text_kern = objectives_desc_text_kern or 0,
		kit_description_multiplier = 0.8 * lang_ssd_mod,
		chat_multiplier = 0.68,
		chat_menu_h_multiplier = 0.34,
		w_interact_multiplier = 0.8 * sd_w_interact_multiplier,
		victory_title_multiplier = victory_title_multiplier and victory_title_multiplier * 0.95 or 1
	}
	self.scale = {
		is_sd = false,
		title_image_multiplier = 1,
		menu_logo_multiplier = 1,
		menu_border_multiplier = 1,
		default_font_multiplier = 1 * lang_l_mod,
		small_font_multiplier = 1 * lang_s_mod,
		lobby_info_font_size_scale_multiplier = 1 * lang_l_mod,
		lobby_name_font_size_scale_multiplier = 1 * lang_l_mod,
		server_list_font_size_multiplier = 1 * lang_l_mod * server_list_font_multiplier,
		multichoice_arrow_multiplier = 1,
		align_line_padding_multiplier = 1,
		menu_arrow_padding_multiplier = 1,
		briefing_text_h_multiplier = 1 * lang_s_mod,
		experience_bar_multiplier = 1,
		hud_equipment_icon_multiplier = 1,
		hud_default_font_multiplier = 1 * lang_l_mod,
		hud_ammo_clip_multiplier = 1,
		hud_health_multiplier = 1,
		hud_mugshot_multiplier = 1,
		hud_assault_image_multiplier = 1,
		hud_crosshair_offset_multiplier = 1,
		hud_objectives_pad_multiplier = 1,
		experience_upgrade_multiplier = 1,
		level_up_multiplier = 1,
		next_upgrade_font_multiplier = 1 * lang_l_mod,
		level_up_font_multiplier = 1 * lang_l_mod,
		present_multiplier = 1,
		lobby_info_offset_multiplier = 1,
		info_padding_multiplier = 1,
		loading_challenge_bar_scale = 1,
		kit_menu_bar_scale = 1,
		kit_menu_description_h_scale = 1,
		button_layout_multiplier = 1,
		subtitle_pos_multiplier = 1,
		subtitle_font_multiplier = 1 * lang_l_mod,
		subtitle_lang_multiplier = subtitle_multiplier,
		default_font_kern = 0,
		stats_upgrade_kern = stats_upgrade_kern or 0,
		level_up_text_kern = 0,
		victory_screen_kern = victory_screen_kern or 0,
		upgrade_menu_kern = 0,
		mugshot_name_kern = 0,
		objectives_text_kern = objectives_text_kern or 0,
		objectives_desc_text_kern = objectives_desc_text_kern or 0,
		kit_description_multiplier = 1 * kit_desc_large,
		chat_multiplier = 1,
		chat_menu_h_multiplier = 1,
		w_interact_multiplier = 1 * w_interact_multiplier,
		victory_title_multiplier = victory_title_multiplier or 1
	}
end

function TweakData:set_menu_scale()
	local lang_mods_def = {
		[Idstring("german"):key()] = {
			challenges_font_size = 1,
			topic_font_size = 0.8,
			upgrades_font_size = 1,
			mission_end_font_size = 1
		},
		[Idstring("french"):key()] = {
			challenges_font_size = 1,
			topic_font_size = 1,
			upgrades_font_size = 1,
			mission_end_font_size = 1
		},
		[Idstring("italian"):key()] = {
			challenges_font_size = 1,
			topic_font_size = 1,
			upgrades_font_size = 1,
			mission_end_font_size = 0.95
		},
		[Idstring("spanish"):key()] = {
			challenges_font_size = 0.95,
			topic_font_size = 0.95,
			upgrades_font_size = 1,
			mission_end_font_size = 1
		}
	}
	local lang_mods = lang_mods_def[SystemInfo:language():key()] or {
		challenges_font_size = 1,
		topic_font_size = 1,
		upgrades_font_size = 1,
		mission_end_font_size = 1
	}
	local scale_multiplier = self.scale.default_font_multiplier
	local small_scale_multiplier = self.scale.small_font_multiplier
	self.menu.default_font = "fonts/font_medium_shadow_mf"
	self.menu.default_font_no_outline = "fonts/font_medium_noshadow_mf"
	self.menu.default_font_id = Idstring(self.menu.default_font)
	self.menu.default_font_no_outline_id = Idstring(self.menu.default_font_no_outline)
	self.menu.small_font = "fonts/font_small_shadow_mf"
	self.menu.small_font_size = 14 * small_scale_multiplier
	self.menu.small_font_noshadow = "fonts/font_small_noshadow_mf"
	self.menu.medium_font = "fonts/font_medium_shadow_mf"
	self.menu.medium_font_no_outline = "fonts/font_medium_noshadow_mf"
	self.menu.meidum_font_size = 24 * scale_multiplier
	self.menu.eroded_font = "fonts/font_eroded"
	self.menu.eroded_font_size = 80
	self.menu.pd2_massive_font = "fonts/font_large_mf"
	self.menu.pd2_massive_font_id = Idstring(self.menu.pd2_massive_font)
	self.menu.pd2_massive_font_size = 80
	self.menu.pd2_large_font = "fonts/font_large_mf"
	self.menu.pd2_large_font_id = Idstring(self.menu.pd2_large_font)
	self.menu.pd2_large_font_size = 44
	self.menu.pd2_medium_font = "fonts/font_medium_mf"
	self.menu.pd2_medium_font_id = Idstring(self.menu.pd2_medium_font)
	self.menu.pd2_medium_font_size = 24
	self.menu.pd2_small_font = "fonts/font_small_mf"
	self.menu.pd2_small_font_id = Idstring(self.menu.pd2_small_font)
	self.menu.pd2_small_font_size = 20
	self.menu.pd2_tiny_font = "fonts/font_small_mf"
	self.menu.pd2_tiny_font_id = Idstring(self.menu.pd2_tiny_font)
	self.menu.pd2_tiny_font_size = 16
	self.menu.uno_vessel_font = "fonts/font_vessel"
	self.menu.uno_vessel_font_id = Idstring(self.menu.uno_vessel_font)
	self.menu.uno_vessel_font_size = 20
	self.menu.uno_vessel_ext_font = "fonts/font_vessel_ext"
	self.menu.uno_vessel_ext_font_id = Idstring(self.menu.uno_vessel_ext_font)
	self.menu.uno_vessel_ext_font_size = 20
	self.menu.default_font_size = 24 * scale_multiplier
	self.menu.default_font_row_item_color = Color.white
	self.menu.default_hightlight_row_item_color = Color(1, 0, 0, 0)
	self.menu.default_menu_background_color = Color(1, 0.3254901960784314, 0.37254901960784315, 0.396078431372549)
	self.menu.highlight_background_color_left = Color(1, 1, 0.6588235294117647, 0)
	self.menu.highlight_background_color_right = Color(1, 1, 0.6588235294117647, 0)
	self.menu.default_changeable_text_color = Color(255, 77, 198, 255) / 255
	self.menu.default_disabled_text_color = Color(1, 0.5, 0.5, 0.5)
	self.menu.arrow_available = Color(1, 1, 0.6588235294117647, 0)
	self.menu.arrow_unavailable = Color(1, 0.5, 0.5, 0.5)
	self.menu.arrow_unavailable = Color(1, 0.5, 0.5, 0.5)
	self.menu.upgrade_locked_color = Color(0.75, 0, 0)
	self.menu.upgrade_not_aquired_color = Color(0.5, 0.5, 0.5)
	self.menu.awarded_challenge_color = self.menu.default_font_row_item_color
	self.menu.dialog_title_font_size = 28 * self.scale.small_font_multiplier
	self.menu.dialog_text_font_size = 24 * self.scale.small_font_multiplier
	self.menu.info_padding = 10 * self.scale.info_padding_multiplier
	self.menu.topic_font_size = 32 * scale_multiplier * lang_mods.topic_font_size
	self.menu.main_menu_background_color = Color(1, 0, 0, 0)
	self.menu.kit_default_font_size = 24 * scale_multiplier
	self.menu.stats_font_size = 24 * scale_multiplier
	self.menu.customize_controller_size = 21 * scale_multiplier
	self.menu.server_list_font_size = 22 * self.scale.server_list_font_size_multiplier
	self.menu.challenges_font_size = 24 * scale_multiplier * lang_mods.challenges_font_size
	self.menu.upgrades_font_size = 24 * scale_multiplier * lang_mods.upgrades_font_size
	self.menu.multichoice_font_size = 24 * scale_multiplier
	self.menu.mission_end_font_size = 20 * scale_multiplier * lang_mods.mission_end_font_size
	self.menu.sd_mission_end_font_size = 14 * small_scale_multiplier * lang_mods.mission_end_font_size
	self.menu.lobby_info_font_size = 22 * self.scale.lobby_info_font_size_scale_multiplier
	self.menu.lobby_name_font_size = 22 * self.scale.lobby_name_font_size_scale_multiplier
	self.menu.loading_challenge_progress_font_size = 22 * small_scale_multiplier
	self.menu.loading_challenge_name_font_size = 22 * small_scale_multiplier
	self.menu.upper_saferect_border = 64 * self.scale.menu_border_multiplier
	self.menu.border_pad = 8 * self.scale.menu_border_multiplier
	self.menu.kit_description_font_size = 14 * self.scale.kit_description_multiplier
	self.load_level = {
		briefing_text = {
			h = 192 * self.scale.briefing_text_h_multiplier
		},
		upper_saferect_border = self.menu.upper_saferect_border,
		border_pad = self.menu.border_pad,
		stonecold_small_logo = "guis/textures/game_small_logo"
	}
end

function TweakData:set_hud_values()
	local lang_mods_def = {
		[Idstring("german"):key()] = {
			active_objective_title_font_size = 0.9,
			next_player_font_size = 0.85,
			present_mid_text_font_size = 0.8,
			location_font_size = 1,
			stats_challenges_font_size = 0.7,
			hint_font_size = 0.9
		},
		[Idstring("french"):key()] = {
			active_objective_title_font_size = 1,
			next_player_font_size = 0.85,
			present_mid_text_font_size = 1,
			location_font_size = 1,
			stats_challenges_font_size = 1,
			hint_font_size = 0.825
		},
		[Idstring("italian"):key()] = {
			active_objective_title_font_size = 1,
			next_player_font_size = 0.85,
			present_mid_text_font_size = 1,
			location_font_size = 1,
			stats_challenges_font_size = 1,
			hint_font_size = 1
		},
		[Idstring("spanish"):key()] = {
			active_objective_title_font_size = 1,
			next_player_font_size = 0.85,
			present_mid_text_font_size = 1,
			location_font_size = 0.7,
			stats_challenges_font_size = 1,
			hint_font_size = 1
		}
	}
	local lang_mods = lang_mods_def[SystemInfo:language():key()] or {
		active_objective_title_font_size = 1,
		next_player_font_size = 1,
		present_mid_text_font_size = 1,
		location_font_size = 1,
		stats_challenges_font_size = 1,
		hint_font_size = 1
	}
	self.hud.medium_font = "fonts/font_medium_mf"
	self.hud.medium_font_noshadow = "fonts/font_medium_mf"
	self.hud.small_font = "fonts/font_small_mf"
	self.hud.small_font_size = 14 * self.scale.small_font_multiplier
	self.hud.location_font_size = 28 * self.scale.hud_default_font_multiplier * lang_mods.location_font_size
	self.hud.assault_title_font_size = 30 * self.scale.hud_default_font_multiplier
	self.hud.default_font_size = 32 * self.scale.hud_default_font_multiplier
	self.hud.present_mid_text_font_size = 32 * self.scale.hud_default_font_multiplier * lang_mods.present_mid_text_font_size
	self.hud.timer_font_size = 40 * self.scale.hud_default_font_multiplier
	self.hud.medium_deafult_font_size = 28 * self.scale.hud_default_font_multiplier
	self.hud.ammo_font_size = 30 * self.scale.hud_default_font_multiplier
	self.hud.weapon_ammo_font_size = 24 * self.scale.hud_default_font_multiplier
	self.hud.name_label_font_size = 24 * self.scale.hud_default_font_multiplier
	self.hud.small_name_label_font_size = 17 * self.scale.hud_default_font_multiplier
	self.hud.equipment_font_size = 24 * self.scale.hud_default_font_multiplier
	self.hud.hint_font_size = 28 * self.scale.hud_default_font_multiplier * lang_mods.hint_font_size
	self.hud.active_objective_title_font_size = 24 * self.scale.hud_default_font_multiplier * lang_mods.active_objective_title_font_size
	self.hud.completed_objective_title_font_size = 20 * self.scale.hud_default_font_multiplier
	self.hud.upgrade_awarded_font_size = 26 * self.scale.hud_default_font_multiplier
	self.hud.next_upgrade_font_size = 14 * self.scale.next_upgrade_font_multiplier
	self.hud.level_up_font_size = 32 * self.scale.level_up_font_multiplier
	self.hud.stats_challenges_font_size = 32 * self.scale.hud_default_font_multiplier * lang_mods.stats_challenges_font_size
	self.hud.chatinput_size = 22 * self.scale.hud_default_font_multiplier
	self.hud.chatoutput_size = 14 * self.scale.small_font_multiplier
	self.hud.prime_color = Color(1, 1, 0.6588235294117647, 0)
	self.hud.suspicion_color = Color(1, 0, 0.4666666666666667, 0.6980392156862745)
	self.hud.detected_color = Color(1, 1, 0.2, 0)
end

function TweakData:resolution_changed()
	self:set_scale()
	self:set_menu_scale()
	self:set_hud_values()
end

if (not tweak_data or tweak_data.RELOAD) and managers.dlc then
	local reload = tweak_data and tweak_data.RELOAD
	local reload_clbks = tweak_data and tweak_data._reload_clbks
	tweak_data = TweakData:new()
	tweak_data._reload_clbks = reload_clbks

	if reload then
		tweak_data:_execute_reload_clbks()
	end
end

function TweakData:get_controller_help_coords()
	if managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" then
		return false
	end

	local coords = {
		normal = {},
		vehicle = {}
	}

	if SystemInfo:platform() == Idstring("PS3") then
		coords.normal.left_thumb = {
			vertical = "top",
			y = 255,
			id = "menu_button_sprint",
			align = "right",
			x = 195
		}
		coords.normal.left = {
			vertical = "top",
			y = 280,
			id = "menu_button_move",
			align = "right",
			x = 195
		}
		coords.normal.right_thumb = {
			vertical = "top",
			y = 255,
			id = "menu_button_melee",
			align = "left",
			x = 319
		}
		coords.normal.right = {
			vertical = "top",
			y = 280,
			id = "menu_button_look",
			align = "left",
			x = 319
		}
		coords.normal.triangle = {
			id = "menu_button_switch_weapon",
			align = "left",
			x = 511,
			y = 112
		}
		coords.normal.square = {
			id = "menu_button_reload",
			align = "left",
			x = 511,
			y = 214
		}
		coords.normal.circle = {
			id = "menu_button_crouch",
			align = "left",
			x = 511,
			y = 146
		}
		coords.normal.cross = {
			id = "menu_button_jump",
			align = "left",
			x = 511,
			y = 178
		}
		coords.normal.r2_trigger = {
			id = "menu_button_shout",
			align = "left",
			x = 511,
			y = 8
		}
		coords.normal.r1_trigger = {
			id = "menu_button_fire_weapon",
			align = "left",
			x = 511,
			y = 36
		}
		coords.normal.l2_trigger = {
			id = "menu_button_deploy",
			align = "right",
			x = 0,
			y = 8
		}
		coords.normal.l1_trigger = {
			id = "menu_button_aim_down_sight",
			align = "right",
			x = 0,
			y = 36
		}
		coords.normal.start = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_ingame_menu",
			align = "left",
			x = 280
		}
		coords.normal.back = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_stats_screen",
			align = "right",
			x = 230
		}
		coords.normal.d_down = {
			vertical = "center",
			y = 171,
			id = "menu_button_weapon_gadget_bipod",
			align = "right",
			x = 0
		}
		coords.normal.d_left = {
			vertical = "center",
			y = 145,
			id = "menu_button_throw_grenade",
			align = "right",
			x = 0
		}
		coords.normal.d_right = {
			vertical = "center",
			y = 87,
			id = "menu_button_weapon_firemode",
			align = "right",
			x = 0
		}
		coords.vehicle.left_thumb = {
			vertical = "top",
			y = 255,
			id = "menu_button_unassigned",
			align = "right",
			x = 195
		}
		coords.vehicle.left = {
			vertical = "top",
			y = 280,
			id = "menu_button_steering",
			align = "right",
			x = 195
		}
		coords.vehicle.right_thumb = {
			vertical = "top",
			y = 255,
			id = "menu_button_vehicle_rear_camera",
			align = "left",
			x = 319
		}
		coords.vehicle.right = {
			vertical = "top",
			y = 280,
			id = "menu_button_unassigned",
			align = "left",
			x = 319
		}
		coords.vehicle.triangle = {
			id = "menu_button_unassigned",
			align = "left",
			x = 511,
			y = 112
		}
		coords.vehicle.square = {
			id = "menu_button_vehicle_change_camera",
			align = "left",
			x = 511,
			y = 214
		}
		coords.vehicle.circle = {
			id = "menu_button_vehicle_shooting_stance",
			align = "left",
			x = 511,
			y = 146
		}
		coords.vehicle.cross = {
			id = "menu_button_handbrake",
			align = "left",
			x = 511,
			y = 178
		}
		coords.vehicle.r2_trigger = {
			id = "menu_button_vehicle_exit",
			align = "left",
			x = 511,
			y = 8
		}
		coords.vehicle.r1_trigger = {
			id = "menu_button_accelerate",
			align = "left",
			x = 511,
			y = 36
		}
		coords.vehicle.l2_trigger = {
			id = "menu_button_unassigned",
			align = "right",
			x = 0,
			y = 8
		}
		coords.vehicle.l1_trigger = {
			id = "menu_button_brake",
			align = "right",
			x = 0,
			y = 36
		}
		coords.vehicle.start = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_ingame_menu",
			align = "left",
			x = 280
		}
		coords.vehicle.back = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_stats_screen",
			align = "right",
			x = 230
		}
		coords.vehicle.d_down = {
			vertical = "center",
			y = 171,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
		coords.vehicle.d_left = {
			vertical = "center",
			y = 145,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
		coords.vehicle.d_right = {
			vertical = "center",
			y = 87,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
	elseif SystemInfo:platform() == Idstring("PS4") then
		coords.normal.left_thumb = {
			vertical = "top",
			y = 255,
			id = "menu_button_sprint",
			align = "right",
			x = 199
		}
		coords.normal.left = {
			vertical = "top",
			y = 280,
			id = "menu_button_move",
			align = "right",
			x = 199
		}
		coords.normal.right_thumb = {
			vertical = "top",
			y = 255,
			id = "menu_button_melee",
			align = "left",
			x = 313
		}
		coords.normal.right = {
			vertical = "top",
			y = 280,
			id = "menu_button_look",
			align = "left",
			x = 313
		}
		coords.normal.triangle = {
			id = "menu_button_switch_weapon",
			align = "left",
			x = 511,
			y = 104
		}
		coords.normal.circle = {
			id = "menu_button_crouch",
			align = "left",
			x = 511,
			y = 128
		}
		coords.normal.cross = {
			id = "menu_button_jump",
			align = "left",
			x = 511,
			y = 153
		}
		coords.normal.square = {
			id = "menu_button_reload",
			align = "left",
			x = 511,
			y = 181
		}
		coords.normal.r1_trigger = {
			id = "menu_button_fire_weapon",
			align = "left",
			x = 511,
			y = 10
		}
		coords.normal.r2_trigger = {
			id = "menu_button_shout_and_stop",
			align = "left",
			x = 511,
			y = 55
		}
		coords.normal.l1_trigger = {
			id = "menu_button_aim_down_sight",
			align = "right",
			x = 0,
			y = 10
		}
		coords.normal.l2_trigger = {
			id = "menu_button_deploy",
			align = "right",
			x = 0,
			y = 55
		}
		coords.normal.start = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_ingame_menu",
			align = "right",
			x = 219
		}
		coords.normal.back = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_stats_screen",
			align = "left",
			x = 328
		}
		coords.normal.d_left = {
			vertical = "center",
			y = 128,
			id = "menu_button_throw_grenade",
			align = "right",
			x = 0
		}
		coords.normal.d_down = {
			vertical = "center",
			y = 153,
			id = "menu_button_weapon_gadget_bipod",
			align = "right",
			x = 0
		}
		coords.normal.d_right = {
			vertical = "center",
			y = 181,
			id = "menu_button_weapon_firemode",
			align = "right",
			x = 0
		}
		coords.vehicle.left_thumb = {
			vertical = "top",
			y = 255,
			id = "menu_button_unassigned",
			align = "right",
			x = 199
		}
		coords.vehicle.left = {
			vertical = "top",
			y = 280,
			id = "menu_button_steering",
			align = "right",
			x = 199
		}
		coords.vehicle.right_thumb = {
			vertical = "top",
			y = 255,
			id = "menu_button_vehicle_rear_camera",
			align = "left",
			x = 313
		}
		coords.vehicle.right = {
			vertical = "top",
			y = 280,
			id = "menu_button_unassigned",
			align = "left",
			x = 313
		}
		coords.vehicle.triangle = {
			id = "menu_button_unassigned",
			align = "left",
			x = 511,
			y = 104
		}
		coords.vehicle.circle = {
			id = "menu_button_vehicle_shooting_stance",
			align = "left",
			x = 511,
			y = 128
		}
		coords.vehicle.cross = {
			id = "menu_button_handbrake",
			align = "left",
			x = 511,
			y = 153
		}
		coords.vehicle.square = {
			id = "menu_button_vehicle_change_camera",
			align = "left",
			x = 511,
			y = 181
		}
		coords.vehicle.r1_trigger = {
			id = "menu_button_accelerate",
			align = "left",
			x = 511,
			y = 10
		}
		coords.vehicle.r2_trigger = {
			id = "menu_button_vehicle_exit",
			align = "left",
			x = 511,
			y = 55
		}
		coords.vehicle.l1_trigger = {
			id = "menu_button_brake",
			align = "right",
			x = 0,
			y = 10
		}
		coords.vehicle.l2_trigger = {
			id = "menu_button_unassigned",
			align = "right",
			x = 0,
			y = 55
		}
		coords.vehicle.start = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_ingame_menu",
			align = "right",
			x = 219
		}
		coords.vehicle.back = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_stats_screen",
			align = "left",
			x = 328
		}
		coords.vehicle.d_left = {
			vertical = "center",
			y = 128,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
		coords.vehicle.d_down = {
			vertical = "center",
			y = 153,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
		coords.vehicle.d_right = {
			vertical = "center",
			y = 181,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
	elseif SystemInfo:platform() == Idstring("XB1") then
		coords.normal.left_thumb = {
			vertical = "bottom",
			y = 78,
			id = "menu_button_sprint",
			align = "right",
			x = 0
		}
		coords.normal.left = {
			vertical = "top",
			y = 78,
			id = "menu_button_move",
			align = "right",
			x = 0
		}
		coords.normal.right_thumb = {
			vertical = "top",
			y = 276,
			id = "menu_button_melee",
			align = "center",
			x = 302
		}
		coords.normal.right = {
			vertical = "top",
			y = 301,
			id = "menu_button_look",
			align = "center",
			x = 302
		}
		coords.normal.y = {
			id = "menu_button_switch_weapon",
			align = "left",
			x = 512,
			y = 57
		}
		coords.normal.x = {
			id = "menu_button_reload",
			align = "left",
			x = 512,
			y = 140
		}
		coords.normal.b = {
			id = "menu_button_crouch",
			align = "left",
			x = 512,
			y = 85
		}
		coords.normal.a = {
			id = "menu_button_jump",
			align = "left",
			x = 512,
			y = 113
		}
		coords.normal.right_shoulder = {
			id = "menu_button_shout_and_stop",
			align = "center",
			x = 390,
			y = -10
		}
		coords.normal.right_trigger = {
			id = "menu_button_fire_weapon",
			align = "left",
			x = 512,
			y = 18
		}
		coords.normal.left_shoulder = {
			id = "menu_button_deploy",
			align = "right",
			x = 180,
			y = -10
		}
		coords.normal.left_trigger = {
			id = "menu_button_aim_down_sight",
			align = "right",
			x = 0,
			y = 18
		}
		coords.normal.start = {
			vertical = "bottom",
			y = -25,
			id = "menu_button_ingame_menu",
			align = "left",
			x = 288
		}
		coords.normal.back = {
			vertical = "bottom",
			y = -25,
			id = "menu_button_stats_screen",
			align = "right",
			x = 235
		}
		coords.normal.d_down = {
			vertical = "center",
			y = 193,
			id = "menu_button_weapon_gadget_bipod",
			align = "right",
			x = 0
		}
		coords.normal.d_left = {
			vertical = "center",
			y = 158,
			id = "menu_button_throw_grenade",
			align = "right",
			x = 0
		}
		coords.normal.d_right = {
			vertical = "center",
			y = 266,
			id = "menu_button_weapon_firemode",
			align = "right",
			x = 270
		}
		coords.vehicle.left_thumb = {
			vertical = "bottom",
			y = 78,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
		coords.vehicle.left = {
			vertical = "top",
			y = 78,
			id = "menu_button_steering",
			align = "right",
			x = 0
		}
		coords.vehicle.right_thumb = {
			vertical = "top",
			y = 276,
			id = "menu_button_vehicle_rear_camera",
			align = "center",
			x = 302
		}
		coords.vehicle.right = {
			vertical = "top",
			y = 301,
			id = "menu_button_unassigned",
			align = "center",
			x = 302
		}
		coords.vehicle.y = {
			id = "menu_button_unassigned",
			align = "left",
			x = 512,
			y = 57
		}
		coords.vehicle.x = {
			id = "menu_button_vehicle_change_camera",
			align = "left",
			x = 512,
			y = 140
		}
		coords.vehicle.b = {
			id = "menu_button_vehicle_shooting_stance",
			align = "left",
			x = 512,
			y = 85
		}
		coords.vehicle.a = {
			id = "menu_button_handbrake",
			align = "left",
			x = 512,
			y = 113
		}
		coords.vehicle.right_shoulder = {
			id = "menu_button_vehicle_exit",
			align = "center",
			x = 390,
			y = -10
		}
		coords.vehicle.right_trigger = {
			id = "menu_button_accelerate",
			align = "left",
			x = 512,
			y = 18
		}
		coords.vehicle.left_shoulder = {
			id = "menu_button_unassigned",
			align = "right",
			x = 180,
			y = -10
		}
		coords.vehicle.left_trigger = {
			id = "menu_button_brake",
			align = "right",
			x = 0,
			y = 18
		}
		coords.vehicle.start = {
			vertical = "bottom",
			y = -25,
			id = "menu_button_ingame_menu",
			align = "left",
			x = 288
		}
		coords.vehicle.back = {
			vertical = "bottom",
			y = -25,
			id = "menu_button_stats_screen",
			align = "right",
			x = 235
		}
		coords.vehicle.d_down = {
			vertical = "center",
			y = 193,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
		coords.vehicle.d_left = {
			vertical = "center",
			y = 158,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
		coords.vehicle.d_right = {
			vertical = "center",
			y = 266,
			id = "menu_button_unassigned",
			align = "right",
			x = 270
		}
	else
		coords.normal.left_thumb = {
			vertical = "bottom",
			y = 138,
			id = "menu_button_sprint",
			align = "right",
			x = 0
		}
		coords.normal.left = {
			vertical = "top",
			y = 138,
			id = "menu_button_move",
			align = "right",
			x = 0
		}
		coords.normal.right_thumb = {
			vertical = "top",
			y = 256,
			id = "menu_button_melee",
			align = "left",
			x = 302
		}
		coords.normal.right = {
			vertical = "top",
			y = 281,
			id = "menu_button_look",
			align = "left",
			x = 302
		}
		coords.normal.y = {
			id = "menu_button_switch_weapon",
			align = "left",
			x = 512,
			y = 97
		}
		coords.normal.x = {
			id = "menu_button_reload",
			align = "left",
			x = 512,
			y = 180
		}
		coords.normal.b = {
			id = "menu_button_crouch",
			align = "left",
			x = 512,
			y = 125
		}
		coords.normal.a = {
			id = "menu_button_jump",
			align = "left",
			x = 512,
			y = 153
		}
		coords.normal.right_shoulder = {
			id = "menu_button_shout_and_stop",
			align = "left",
			x = 512,
			y = 49
		}
		coords.normal.right_trigger = {
			id = "menu_button_fire_weapon",
			align = "left",
			x = 512,
			y = 19
		}
		coords.normal.left_shoulder = {
			id = "menu_button_deploy",
			align = "right",
			x = 0,
			y = 49
		}
		coords.normal.left_trigger = {
			id = "menu_button_aim_down_sight",
			align = "right",
			x = 0,
			y = 19
		}
		coords.normal.start = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_ingame_menu",
			align = "left",
			x = 288
		}
		coords.normal.back = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_stats_screen",
			align = "right",
			x = 223
		}
		coords.normal.d_down = {
			vertical = "center",
			y = 243,
			id = "menu_button_weapon_gadget_bipod",
			align = "right",
			x = 0
		}
		coords.normal.d_left = {
			vertical = "center",
			y = 208,
			id = "menu_button_throw_grenade",
			align = "right",
			x = 0
		}
		coords.normal.d_right = {
			vertical = "top",
			y = 256,
			id = "menu_button_weapon_firemode",
			align = "right",
			x = 226
		}

		if SystemInfo:platform() == Idstring("WIN32") then
			coords.normal.d_up = {
				vertical = "center",
				y = 174,
				id = "menu_button_push_to_talk",
				align = "right",
				x = 0
			}
		end

		coords.vehicle.left_thumb = {
			vertical = "bottom",
			y = 138,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
		coords.vehicle.left = {
			vertical = "top",
			y = 138,
			id = "menu_button_steering",
			align = "right",
			x = 0
		}
		coords.vehicle.right_thumb = {
			vertical = "top",
			y = 256,
			id = "menu_button_vehicle_rear_camera",
			align = "left",
			x = 302
		}
		coords.vehicle.right = {
			vertical = "top",
			y = 281,
			id = "menu_button_unassigned",
			align = "left",
			x = 302
		}
		coords.vehicle.y = {
			id = "menu_button_unassigned",
			align = "left",
			x = 512,
			y = 97
		}
		coords.vehicle.x = {
			id = "menu_button_vehicle_change_camera",
			align = "left",
			x = 512,
			y = 180
		}
		coords.vehicle.b = {
			id = "menu_button_vehicle_shooting_stance",
			align = "left",
			x = 512,
			y = 125
		}
		coords.vehicle.a = {
			id = "menu_button_handbrake",
			align = "left",
			x = 512,
			y = 153
		}
		coords.vehicle.right_shoulder = {
			id = "menu_button_vehicle_exit",
			align = "left",
			x = 512,
			y = 49
		}
		coords.vehicle.right_trigger = {
			id = "menu_button_accelerate",
			align = "left",
			x = 512,
			y = 19
		}
		coords.vehicle.left_shoulder = {
			id = "menu_button_unassigned",
			align = "right",
			x = 0,
			y = 49
		}
		coords.vehicle.left_trigger = {
			id = "menu_button_brake",
			align = "right",
			x = 0,
			y = 19
		}
		coords.vehicle.start = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_ingame_menu",
			align = "left",
			x = 288
		}
		coords.vehicle.back = {
			vertical = "bottom",
			y = 0,
			id = "menu_button_stats_screen",
			align = "right",
			x = 223
		}
		coords.vehicle.d_down = {
			vertical = "center",
			y = 243,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
		coords.vehicle.d_left = {
			vertical = "center",
			y = 208,
			id = "menu_button_unassigned",
			align = "right",
			x = 0
		}
		coords.vehicle.d_right = {
			vertical = "top",
			y = 256,
			id = "menu_button_unassigned",
			align = "right",
			x = 226
		}

		if SystemInfo:platform() == Idstring("WIN32") then
			coords.vehicle.d_up = {
				vertical = "center",
				y = 174,
				id = "menu_button_unassigned",
				align = "right",
				x = 0
			}
		end
	end

	if managers.user and managers.user:get_setting("southpaw") then
		local tmp = coords.normal.left.id
		coords.normal.left.id = coords.normal.right.id
		coords.normal.right.id = tmp
	end

	return coords
end
