GuiTweakData = GuiTweakData or class()

function GuiTweakData:init()
	local soundtrack = {
		store = 254260,
		name_id = "menu_content_soundtrack",
		id = "soundtrack",
		date_id = "menu_content_soundtrack_date",
		image = "guis/textures/pd2/content_updates/soundtrack",
		desc_id = "menu_content_soundtrack_desc"
	}
	local diamond_store = {
		store = 274160,
		name_id = "menu_content_diamond_store",
		id = "diamond_store",
		date_id = "menu_content_diamond_store_date",
		image = "guis/textures/pd2/content_updates/diamond_store",
		desc_id = "menu_content_diamond_store_desc"
	}
	local birthday = {
		webpage = "http://www.overkillsoftware.com/birthday/",
		name_id = "menu_content_birthday",
		id = "birthday",
		date_id = "menu_content_birthday_date",
		image = "guis/textures/pd2/content_updates/birthday",
		desc_id = "menu_content_birthday_desc"
	}
	local halloween = {
		webpage = "http://www.overkillsoftware.com/helltopay/",
		name_id = "menu_content_halloween",
		id = "halloween",
		date_id = "menu_content_halloween_date",
		image = "guis/textures/pd2/content_updates/halloween",
		desc_id = "menu_content_halloween_desc"
	}
	local armored_transport = {
		store = 264610,
		name_id = "menu_content_armored_transport",
		id = "armored_transport",
		date_id = "menu_content_armored_transport_date",
		image = "guis/textures/pd2/content_updates/armored_transport",
		desc_id = "menu_content_armored_transport_desc"
	}
	local gage_pack = {
		store = 267380,
		name_id = "menu_content_gage_pack",
		id = "gage_pack",
		date_id = "menu_content_gage_pack_date",
		image = "guis/textures/pd2/content_updates/gage_pack",
		desc_id = "menu_content_gage_pack_desc"
	}
	local charliesierra = {
		store = 271110,
		name_id = "menu_content_charliesierra",
		id = "charliesierra",
		date_id = "menu_content_charliesierra_date",
		image = "guis/textures/pd2/content_updates/charliesierra",
		desc_id = "menu_content_charliesierra_desc"
	}
	local christmas = {
		store = 267381,
		name_id = "menu_content_christmas",
		id = "christmas",
		date_id = "menu_content_christmas_date",
		image = "guis/textures/pd2/content_updates/christmas",
		desc_id = "menu_content_christmas_desc"
	}
	local infamy = {
		store = 274161,
		name_id = "menu_content_infamy",
		id = "infamy",
		date_id = "menu_content_infamy_date",
		image = "guis/textures/pd2/content_updates/infamy_introduction",
		desc_id = "menu_content_infamy_desc"
	}
	local gage_pack_lmg = {
		store = 275590,
		name_id = "menu_content_gage_pack_lmg",
		id = "gage_pack_lmg",
		date_id = "menu_content_gage_pack_lmg_date",
		image = "guis/textures/pd2/content_updates/gage_pack_lmg",
		desc_id = "menu_content_gage_pack_lmg_desc"
	}
	local deathwish = {
		store = 284430,
		name_id = "menu_content_deathwish",
		id = "deathwish",
		date_id = "menu_content_deathwish_date",
		image = "guis/textures/pd2/content_updates/deathwish",
		desc_id = "menu_content_deathwish_desc"
	}
	local election_day = {
		store = 288900,
		name_id = "menu_content_election_day",
		id = "election_day",
		date_id = "menu_content_election_day_date",
		image = "guis/textures/pd2/content_updates/election_day",
		desc_id = "menu_content_election_day_desc"
	}
	local gage_pack_jobs = {
		store = 259381,
		name_id = "menu_content_gage_pack_jobs",
		id = "gage_pack_jobs",
		date_id = "menu_content_gage_pack_jobs_date",
		image = "guis/textures/pd2/content_updates/gage_pack_jobs",
		desc_id = "menu_content_gage_pack_jobs_desc"
	}
	local gage_pack_snp = {
		store = 259380,
		name_id = "menu_content_gage_pack_snp",
		id = "gage_pack_snp",
		date_id = "menu_content_gage_pack_snp_date",
		image = "guis/textures/pd2/content_updates/gage_pack_snp",
		desc_id = "menu_content_gage_pack_snp_desc"
	}
	local kosugi = {
		store = 267382,
		name_id = "menu_content_kosugi",
		id = "kosugi",
		date_id = "menu_content_kosugi_date",
		image = "guis/textures/pd2/content_updates/kosugi",
		desc_id = "menu_content_kosugi_desc"
	}
	local big_bank = {
		store = 306690,
		name_id = "menu_content_big_bank",
		id = "big_bank",
		date_id = "menu_content_big_bank_date",
		image = "guis/dlcs/big_bank/textures/pd2/content_updates/big_bank",
		desc_id = "menu_content_big_bank_desc"
	}
	local gage_pack_shotgun = {
		store = 311050,
		name_id = "menu_content_gage_pack_shotgun",
		id = "gage_pack_shotgun",
		date_id = "menu_content_gage_pack_shotgun_date",
		image = "guis/dlcs/gage_pack_shotgun/textures/pd2/content_updates/gage_pack_shotgun",
		desc_id = "menu_content_gage_pack_shotgun_desc"
	}
	local gage_pack_assault = {
		store = 320030,
		name_id = "menu_content_gage_pack_assault",
		id = "gage_pack_assault",
		date_id = "menu_content_gage_pack_assault_date",
		image = "guis/dlcs/gage_pack_assault/textures/pd2/content_updates/gage_pack_assault",
		desc_id = "menu_content_gage_pack_assault_desc"
	}
	local jukebox = {
		webpage = "http://www.overkillsoftware.com/bigfatmusicupdate/",
		name_id = "menu_content_jukebox",
		id = "jukebox",
		date_id = "menu_content_jukebox_date",
		image = "guis/textures/pd2/content_updates/jukebox",
		desc_id = "menu_content_jukebox_desc"
	}
	local hl_miami = {
		store = 323500,
		name_id = "menu_content_hl_miami",
		id = "hl_miami",
		date_id = "menu_content_hl_miami_date",
		image = "guis/dlcs/hl_miami/textures/pd2/content_updates/hl_miami",
		desc_id = "menu_content_hl_miami_desc"
	}
	local crimefest = {
		webpage = "http://www.overkillsoftware.com/crimefest/mrated.html",
		name_id = "menu_content_crimefest",
		id = "crimefest",
		date_id = "menu_content_crimefest_date",
		image = "guis/textures/pd2/content_updates/crimefest",
		desc_id = "menu_content_crimefest_desc"
	}
	local jowi = {
		store = 330010,
		name_id = "menu_content_jowi",
		id = "jowi",
		date_id = "menu_content_jowi_date",
		image = "guis/textures/pd2/content_updates/jowi",
		desc_id = "menu_content_jowi_desc"
	}
	local hoxton_char = {
		store = 330490,
		name_id = "menu_content_hoxton_char",
		id = "hoxton_char",
		date_id = "menu_content_hoxton_char_date",
		image = "guis/textures/pd2/content_updates/hoxton_char",
		desc_id = "menu_content_hoxton_char_desc"
	}
	local hoxton_job = {
		store = 330491,
		name_id = "menu_content_hoxton_job",
		id = "hoxton_job",
		date_id = "menu_content_hoxton_job_date",
		image = "guis/textures/pd2/content_updates/hoxton_job",
		desc_id = "menu_content_hoxton_job_desc"
	}
	local halloween_2014 = {
		webpage = "http://www.overkillsoftware.com/halloween/",
		name_id = "menu_content_halloween_2014",
		id = "halloween_2014",
		date_id = "menu_content_halloween_2014_date",
		image = "guis/textures/pd2/content_updates/halloween_2014",
		desc_id = "menu_content_halloween_2014_desc"
	}
	local gage_pack_historical = {
		store = 331900,
		name_id = "menu_content_gage_pack_historical",
		id = "gage_pack_historical",
		date_id = "menu_content_gage_pack_historical_date",
		image = "guis/dlcs/gage_pack_historical/textures/pd2/content_updates/gage_pack_historical",
		desc_id = "menu_content_gage_pack_historical_desc"
	}
	local christmas_2014 = {
		webpage = "http://www.overkillsoftware.com/whitechristmas/",
		name_id = "menu_content_christmas_2014",
		id = "christmas_2014",
		date_id = "menu_content_christmas_2014_date",
		image = "guis/dlcs/pines/textures/pd2/content_updates/christmas_2014",
		desc_id = "menu_content_christmas_2014_desc"
	}
	local character_pack_clover = {
		store = 337661,
		name_id = "menu_content_character_pack_clover",
		id = "character_pack_clover",
		date_id = "menu_content_character_pack_clover_date",
		image = "guis/dlcs/character_pack_clover/textures/pd2/content_updates/character_pack_clover",
		desc_id = "menu_content_character_pack_clover_desc"
	}
	local hope_diamond = {
		store = 337660,
		name_id = "menu_content_hope_diamond",
		id = "hope_diamond",
		date_id = "menu_content_hope_diamond_date",
		image = "guis/dlcs/character_pack_clover/textures/pd2/content_updates/hope_diamond",
		desc_id = "menu_content_hope_diamond_desc"
	}
	local hw_boxing = {
		webpage = "http://www.overkillsoftware.com/happynewyear/",
		name_id = "menu_content_hw_boxing",
		id = "hw_boxing",
		date_id = "menu_content_hw_boxing_date",
		image = "guis/dlcs/pd2_hw_boxing/textures/pd2/content_updates/hw_boxing",
		desc_id = "menu_content_hw_boxing_desc"
	}
	local character_pack_dragan = {
		store = 344140,
		name_id = "menu_content_character_pack_dragan",
		id = "character_pack_dragan",
		date_id = "menu_content_character_pack_dragan_date",
		image = "guis/dlcs/character_pack_dragan/textures/pd2/content_updates/dragan",
		desc_id = "menu_content_character_pack_dragan_desc"
	}
	local the_bomb = {
		store = 339480,
		name_id = "menu_content_the_bomb",
		id = "the_bomb",
		date_id = "menu_content_the_bomb_date",
		image = "guis/dlcs/the_bomb/textures/pd2/content_updates/the_bomb",
		desc_id = "menu_content_the_bomb_desc"
	}
	local akm4_pack = {
		store = 351890,
		name_id = "menu_content_akm4_pack",
		id = "akm4_pack",
		date_id = "menu_content_akm4_pack_date",
		image = "guis/dlcs/dlc_akm4/textures/pd2/content_updates/akm4_pack",
		desc_id = "menu_content_akm4_pack_desc"
	}
	local infamy_2_0 = {
		webpage = "http://www.overkillsoftware.com/games/infamy2/",
		name_id = "menu_content_infamy_2_0",
		id = "infamy_2_0",
		date_id = "menu_content_infamy_2_0_date",
		image = "guis/dlcs/infamous/textures/pd2/content_updates/infamy_2_0",
		desc_id = "menu_content_infamy_2_0_desc"
	}
	local overkill_pack = {
		store = 348090,
		name_id = "menu_content_overkill_pack",
		id = "overkill_pack",
		date_id = "menu_content_overkill_pack_date",
		image = "guis/dlcs/dlc_pack_overkill/textures/pd2/content_updates/overkill_pack",
		desc_id = "menu_content_overkill_pack_desc"
	}
	local complete_overkill_pack = {
		webpage = "http://www.overkillsoftware.com/thehypetrain/",
		name_id = "menu_content_complete_overkill_pack",
		id = "complete_overkill_pack",
		date_id = "menu_content_complete_overkill_pack_date",
		image = "guis/dlcs/dlc_pack_overkill/textures/pd2/content_updates/complete_overkill_pack",
		desc_id = "menu_content_complete_overkill_pack_desc"
	}
	local hlm2 = {
		store = 274170,
		name_id = "menu_content_hlm2",
		id = "hlm2",
		date_id = "menu_content_hlm2_date",
		image = "guis/dlcs/hlm2/textures/pd2/content_updates/hlm2",
		desc_id = "menu_content_hlm2_desc"
	}
	local hlm2_deluxe = {
		store = 274170,
		name_id = "menu_content_hlm2_deluxe",
		id = "hlm2_deluxe",
		date_id = "menu_content_hlm2_deluxe_date",
		image = "guis/dlcs/hlm2/textures/pd2/content_updates/hlm2_deluxe",
		desc_id = "menu_content_hlm2_deluxe_desc"
	}
	local bbq = {
		store = 337661,
		name_id = "menu_content_bbq",
		id = "bbq",
		webpage = "http://www.overkillsoftware.com/bbq/",
		date_id = "menu_content_bbq_date",
		image = "guis/textures/pd2/content_updates/bbq",
		desc_id = "menu_content_bbq_desc"
	}
	local springbreak = {
		webpage = "http://www.overkillsoftware.com/springbreak/",
		name_id = "menu_content_springbreak",
		id = "springbreak",
		date_id = "menu_content_springbreak_date",
		image = "guis/textures/pd2/content_updates/springbreak",
		desc_id = "menu_content_springbreak_desc"
	}
	local bbq = {
		store = 358150,
		name_id = "menu_content_bbq",
		id = "bbq",
		date_id = "menu_content_bbq_date",
		image = "guis/dlcs/bbq/textures/pd2/content_updates/bbq",
		desc_id = "menu_content_bbq_desc"
	}
	local fpsanimation = {
		webpage = "http://www.overkillsoftware.com/animations-update/",
		name_id = "menu_content_fpsanimation",
		id = "fpsanimation",
		date_id = "menu_content_fpsanimation_date",
		image = "guis/textures/pd2/content_updates/fpsanimation",
		desc_id = "menu_content_fpsanimation_desc"
	}
	local springcleaning = {
		webpage = "http://steamcommunity.com/games/218620/announcements/detail/177107167839449807",
		name_id = "menu_content_springcleaning",
		id = "springcleaning",
		date_id = "menu_content_springcleaning_date",
		image = "guis/textures/pd2/content_updates/springcleaning",
		desc_id = "menu_content_springcleaning_desc"
	}
	local west = {
		store = 349830,
		name_id = "menu_content_west",
		id = "west",
		date_id = "menu_content_west_date",
		image = "guis/dlcs/west/textures/pd2/content_updates/west",
		desc_id = "menu_content_west_desc"
	}
	local bsides = {
		store = 368870,
		name_id = "menu_content_bsides",
		id = "bsides",
		date_id = "menu_content_bsides_date",
		image = "guis/textures/pd2/content_updates/bsides",
		desc_id = "menu_content_bsides_desc"
	}
	local shoutout = {
		webpage = "http://www.overkillsoftware.com/meltdown/",
		name_id = "menu_content_shoutout",
		id = "shoutout",
		date_id = "menu_content_shoutout_date",
		image = "guis/textures/pd2/content_updates/shoutout",
		desc_id = "menu_content_shoutout_desc"
	}
	local arena = {
		store = 366660,
		name_id = "menu_content_arena",
		id = "arena",
		date_id = "menu_content_arena_date",
		image = "guis/dlcs/dlc_arena/textures/pd2/content_updates/arena",
		desc_id = "menu_content_arena_desc"
	}
	local character_pack_sokol = {
		store = 374301,
		name_id = "menu_content_character_pack_sokol",
		id = "character_pack_sokol",
		date_id = "menu_content_character_pack_sokol_date",
		image = "guis/dlcs/character_pack_sokol/textures/pd2/content_updates/sokol",
		desc_id = "menu_content_character_pack_sokol_desc"
	}
	local kenaz = {
		store = 374300,
		name_id = "menu_content_kenaz",
		id = "kenaz",
		date_id = "menu_content_kenaz_date",
		image = "guis/dlcs/kenaz/textures/pd2/content_updates/kenaz",
		desc_id = "menu_content_kenaz_desc"
	}
	local turtles = {
		store = 384021,
		name_id = "menu_content_turtles",
		id = "turtles",
		date_id = "menu_content_turtles_date",
		image = "guis/dlcs/turtles/textures/pd2/content_updates/turtles",
		desc_id = "menu_content_turtles_desc"
	}
	local dragon = {
		store = 384020,
		name_id = "menu_content_dragon",
		id = "dragon",
		date_id = "menu_content_dragon_date",
		image = "guis/dlcs/dragon/textures/pd2/content_updates/dragon",
		desc_id = "menu_content_dragon_desc"
	}
	local steel = {
		store = 401650,
		name_id = "menu_content_steel",
		id = "steel",
		date_id = "menu_content_steel_date",
		image = "guis/dlcs/steel/textures/pd2/content_updates/steel",
		desc_id = "menu_content_steel_desc"
	}
	local gordon = {
		webpage = "http://www.overkillsoftware.com/games/fbifiles/",
		name_id = "menu_content_gordon",
		id = "gordon",
		date_id = "menu_content_gordon_date",
		image = "guis/dlcs/gordon/textures/pd2/content_updates/gordon",
		desc_id = "menu_content_gordon_desc"
	}
	local rip = {
		webpage = "http://www.overkillsoftware.com/games/pointbreak/",
		name_id = "menu_content_rip",
		id = "rip",
		date_id = "menu_content_rip_date",
		image = "guis/dlcs/rip/textures/pd2/content_updates/rip",
		desc_id = "menu_content_rip_desc"
	}
	local berry = {
		store = 422400,
		name_id = "menu_content_berry",
		id = "berry",
		date_id = "menu_content_berry_date",
		image = "guis/dlcs/berry/textures/pd2/content_updates/berry",
		desc_id = "menu_content_berry_desc"
	}
	local cane = {
		webpage = "http://www.overkillsoftware.com/games/christmas2015/",
		name_id = "menu_content_cane",
		id = "cane",
		date_id = "menu_content_cane_date",
		image = "guis/textures/pd2/content_updates/xmas2015",
		desc_id = "menu_content_cane_desc"
	}
	local peta = {
		store = 433730,
		name_id = "menu_content_peta",
		id = "peta",
		date_id = "menu_content_peta_date",
		image = "guis/dlcs/peta/textures/pd2/content_updates/peta",
		desc_id = "menu_content_peta_desc"
	}
	local pal = {
		store = 441600,
		name_id = "menu_content_pal",
		id = "pal",
		date_id = "menu_content_pal_date",
		image = "guis/dlcs/lupus/textures/pd2/content_updates/lupus",
		desc_id = "menu_content_pal_desc"
	}
	local coco = {
		webpage = "http://www.overkillsoftware.com/games/hardcorehenry/",
		name_id = "menu_content_coco",
		id = "coco",
		date_id = "menu_content_coco_date",
		image = "guis/dlcs/coco/textures/pd2/content_updates/coco",
		desc_id = "menu_content_coco_desc"
	}
	local mad = {
		webpage = "http://www.overkillsoftware.com/games/hardcorehenry/",
		name_id = "menu_content_mad",
		id = "mad",
		date_id = "menu_content_mad_date",
		image = "guis/dlcs/mad/textures/pd2/content_updates/mad",
		desc_id = "menu_content_mad_desc"
	}
	local opera = {
		store = 468410,
		name_id = "menu_content_opera",
		id = "opera",
		date_id = "menu_content_opera_date",
		image = "guis/dlcs/opera/textures/pd2/content_updates/opera",
		desc_id = "menu_content_opera_desc"
	}
	local update100 = {
		webpage = "http://www.overkillsoftware.com/games/update100/",
		name_id = "menu_content_update100",
		id = "update100",
		date_id = "menu_content_update100_date",
		image = "guis/textures/pd2/content_updates/update100",
		desc_id = "menu_content_update100_desc"
	}
	local tutorial = {
		webpage = "http://steamcommunity.com/app/218620/allnews/",
		name_id = "menu_content_tutorial",
		id = "tutorial",
		date_id = "menu_content_tutorial_date",
		image = "guis/textures/pd2/content_updates/tutorial",
		desc_id = "menu_content_tutorial_desc"
	}
	local wild = {
		store = 450660,
		name_id = "menu_content_wild",
		id = "wild",
		date_id = "menu_content_wild_date",
		image = "guis/dlcs/wild/textures/pd2/content_updates/wild",
		desc_id = "menu_content_wild_desc"
	}
	local born = {
		store = 487210,
		name_id = "menu_content_born",
		id = "born",
		date_id = "menu_content_born_date",
		image = "guis/dlcs/born/textures/pd2/content_updates/born",
		desc_id = "menu_content_born_desc"
	}
	local pim = {
		store = 545100,
		name_id = "menu_content_pim",
		id = "pim",
		date_id = "menu_content_pim_date",
		image = "guis/dlcs/pim/textures/pd2/content_updates/pim",
		desc_id = "menu_content_pim_desc"
	}
	local tango = {
		store = 487210,
		name_id = "menu_content_tango",
		id = "tango",
		date_id = "menu_content_tango_date",
		image = "guis/dlcs/tango/textures/pd2/content_updates/tango",
		desc_id = "menu_content_tango_desc"
	}
	self.content_updates = {
		title_id = "menu_content_updates",
		num_items = 6,
		choice_id = "menu_content_updates_previous"
	}
	self.store_page = "http://store.steampowered.com/app/218620"

	if SystemInfo:platform() == Idstring("WIN32") then
		self.content_updates.item_list = {
			soundtrack,
			diamond_store,
			birthday,
			halloween,
			armored_transport,
			gage_pack,
			charliesierra,
			christmas,
			infamy,
			gage_pack_lmg,
			deathwish,
			election_day,
			gage_pack_jobs,
			gage_pack_snp,
			kosugi,
			big_bank,
			gage_pack_shotgun,
			gage_pack_assault,
			jukebox,
			hl_miami,
			crimefest,
			jowi,
			hoxton_char,
			hoxton_job,
			halloween_2014,
			gage_pack_historical,
			christmas_2014,
			hope_diamond,
			character_pack_clover,
			hw_boxing,
			the_bomb,
			character_pack_dragan,
			akm4_pack,
			infamy_2_0,
			overkill_pack,
			complete_overkill_pack,
			hlm2,
			hlm2_deluxe,
			springbreak,
			bbq,
			west,
			springcleaning,
			bsides,
			shoutout,
			arena,
			kenaz,
			character_pack_sokol,
			turtles,
			dragon,
			steel,
			gordon,
			berry,
			rip,
			cane,
			peta,
			pal,
			coco,
			mad,
			opera,
			update100,
			tutorial,
			wild,
			born,
			pim,
			tango
		}
	elseif SystemInfo:platform() == Idstring("PS3") then
		self.content_updates.item_list = {
			armored_transport,
			gage_pack,
			gage_pack_lmg
		}
	elseif SystemInfo:platform() == Idstring("PS4") then
		self.content_updates.item_list = {armored_transport}
	elseif SystemInfo:platform() == Idstring("XB1") then
		self.content_updates.item_list = {armored_transport}
	elseif SystemInfo:platform() == Idstring("X360") then
		self.content_updates.item_list = {}
	end

	self.fav_videos = {
		title_id = "menu_fav_videos",
		num_items = 3,
		db_url = "http://www.overkillsoftware.com/?page_id=1263",
		button = {
			url = "http://www.overkillsoftware.com/?page_id=1263",
			text_id = "menu_fav_video_homepage"
		},
		item_list = {
			{
				id = "fav3",
				image = "guis/textures/pd2/fav_video3",
				use_db = true
			},
			{
				id = "fav2",
				image = "guis/textures/pd2/fav_video2",
				use_db = true
			},
			{
				id = "fav1",
				image = "guis/textures/pd2/fav_video1",
				use_db = true
			}
		}
	}
	self.masks_sort_order = {
		"aviator",
		"plague",
		"welder",
		"smoker",
		"ghost",
		"skullhard",
		"skullveryhard",
		"skulloverkill",
		"skulloverkillplus"
	}
	self.blackscreen_risk_textures = {
		sm_wish = "guis/textures/pd2/risklevel_deathwish_sm_blackscreen",
		overkill_290 = "guis/textures/pd2/risklevel_deathwish_blackscreen",
		easy_wish = "guis/textures/pd2/risklevel_deathwish_easywish_blackscreen"
	}
	self.suspicion_to_visibility = {{}}
	self.suspicion_to_visibility[1].name_id = "bm_menu_concealment_low"
	self.suspicion_to_visibility[1].max_index = 9
	self.suspicion_to_visibility[2] = {
		name_id = "bm_menu_concealment_medium",
		max_index = 20
	}
	self.suspicion_to_visibility[3] = {
		name_id = "bm_menu_concealment_high",
		max_index = 30
	}
	self.mouse_pointer = {controller = {}}
	self.mouse_pointer.controller.acceleration_speed = 4
	self.mouse_pointer.controller.max_acceleration = 3
	self.mouse_pointer.controller.mouse_pointer_speed = 125
	local min_amount_masks = 160
	self.MASK_ROWS_PER_PAGE = 4
	self.MASK_COLUMNS_PER_PAGE = 4
	self.MAX_MASK_PAGES = math.ceil(min_amount_masks / (self.MASK_ROWS_PER_PAGE * self.MASK_COLUMNS_PER_PAGE))
	self.MAX_MASK_SLOTS = self.MAX_MASK_PAGES * self.MASK_ROWS_PER_PAGE * self.MASK_COLUMNS_PER_PAGE
	local min_amount_weapons = 160
	self.WEAPON_ROWS_PER_PAGE = 4
	self.WEAPON_COLUMNS_PER_PAGE = 4
	self.MAX_WEAPON_PAGES = math.ceil(min_amount_weapons / (self.WEAPON_ROWS_PER_PAGE * self.WEAPON_COLUMNS_PER_PAGE))
	self.MAX_WEAPON_SLOTS = self.MAX_WEAPON_PAGES * self.WEAPON_ROWS_PER_PAGE * self.WEAPON_COLUMNS_PER_PAGE
	self.fbi_files_webpage = "http://fbi.overkillsoftware.com/"
	self.crimefest_challenges_webpage = "http://www.overkillsoftware.com/games/roadtocrimefest/"
	self.crime_net = {controller = {}}
	self.crime_net.controller.snap_distance = 50
	self.crime_net.controller.snap_speed = 5
	self.crime_net.job_vars = {
		max_active_jobs = 10,
		active_job_time = 25,
		new_job_min_time = 1.5,
		new_job_max_time = 3.5,
		refresh_servers_time = SystemInfo:platform() == Idstring("PS4") and 10 or 5,
		total_active_jobs = 40,
		max_active_server_jobs = 100
	}
	self.crime_net.debug_options = {
		regions = false,
		mass_spawn = false,
		mass_spawn_limit = 100,
		mass_spawn_timer = 0.04
	}
	self.rename_max_letters = 20
	self.rename_skill_set_max_letters = 15
	self.mod_preview_min_fov = -19
	self.mod_preview_max_fov = 3
	self.stats_present_multiplier = 10
	self.armor_damage_shake_base = 1.1
	self.buy_weapon_category_aliases = {
		flamethrower = "wpn_special",
		grenade_launcher = "wpn_special",
		bow = "wpn_special",
		crossbow = "wpn_special",
		minigun = "wpn_special",
		saw = "wpn_special"
	}
	self.buy_weapon_categories = {
		primaries = {
			{"assault_rifle"},
			{"shotgun"},
			{"lmg"},
			{"snp"},
			{
				"akimbo",
				"pistol"
			},
			{
				"akimbo",
				"smg"
			},
			{
				"akimbo",
				"shotgun"
			},
			{"wpn_special"}
		},
		secondaries = {
			{"pistol"},
			{"smg"},
			{"wpn_special"},
			{"shotgun"}
		}
	}
	self.LONGEST_CHAR_NAME = "JOHN WICK"
	self.crime_net.regions = {
		{
			{
				-10,
				270,
				293,
				252,
				271,
				337,
				341,
				372,
				372,
				475,
				475,
				491,
				491,
				504,
				503,
				524,
				536,
				536,
				542,
				542,
				555,
				555,
				598,
				598,
				638,
				638,
				657,
				688,
				686,
				691,
				701,
				698,
				687,
				650,
				634,
				602,
				609,
				580,
				576,
				576,
				567,
				559,
				558,
				542,
				543,
				512,
				512,
				503,
				381,
				377,
				348,
				315,
				315,
				290,
				290,
				259,
				259,
				237,
				237,
				261,
				261,
				257,
				224,
				221,
				187,
				182,
				163,
				163,
				147,
				147,
				133,
				133,
				102,
				102,
				-10
			},
			{
				-10,
				-10,
				28,
				73,
				122,
				123,
				132,
				141,
				145,
				172,
				216,
				215,
				180,
				179,
				229,
				228,
				244,
				253,
				253,
				248,
				247,
				241,
				241,
				219,
				219,
				209,
				208,
				234,
				241,
				242,
				262,
				270,
				277,
				276,
				279,
				296,
				300,
				362,
				361,
				408,
				416,
				417,
				430,
				430,
				477,
				477,
				514,
				523,
				523,
				514,
				514,
				501,
				493,
				484,
				469,
				469,
				465,
				465,
				439,
				440,
				434,
				430,
				429,
				433,
				433,
				438,
				438,
				423,
				423,
				435,
				435,
				423,
				423,
				412,
				412
			},
			closed = true,
			text = {
				title_id = "cn_menu_georgetown_title",
				x = 348,
				y = 310
			}
		},
		{
			{
				340,
				350,
				350,
				373,
				373,
				368,
				368,
				358,
				358,
				351,
				351,
				340
			},
			{
				103,
				103,
				106,
				106,
				116,
				116,
				123,
				123,
				116,
				116,
				122,
				121
			},
			closed = true
		},
		{
			{
				564,
				576,
				576,
				564
			},
			{
				189,
				189,
				208,
				208
			},
			closed = true
		},
		{
			{
				147,
				168,
				164,
				144
			},
			{
				444,
				451,
				463,
				457
			},
			closed = true
		},
		{
			{
				168,
				185,
				181,
				166
			},
			{
				463,
				468,
				478,
				473
			},
			closed = true
		},
		{
			{
				371,
				417,
				417,
				414,
				371
			},
			{
				534,
				534,
				554,
				557,
				538
			},
			closed = true
		},
		{
			{
				422,
				509,
				509,
				500,
				500,
				477,
				477,
				466,
				457,
				457,
				447,
				422
			},
			{
				534,
				534,
				548,
				559,
				585,
				585,
				575,
				581,
				581,
				573,
				573,
				557
			},
			closed = true
		},
		{
			{
				519,
				530,
				517,
				528,
				522,
				540,
				538,
				544,
				549,
				561,
				565,
				571,
				566,
				574,
				579,
				609,
				613,
				630,
				628,
				644,
				641,
				662,
				665,
				703,
				696,
				721,
				721,
				756,
				756,
				767,
				767,
				736,
				709,
				701,
				651,
				651,
				640,
				623,
				634,
				608,
				591,
				581,
				599,
				599,
				551,
				541,
				598,
				598,
				640,
				735,
				735,
				751,
				760,
				766,
				771,
				831,
				831,
				882,
				882,
				922,
				922,
				976,
				976,
				1031,
				1036,
				1019,
				1020,
				994,
				1063,
				1063,
				1068,
				1098,
				1104,
				1113,
				1123,
				1132,
				1175,
				1175,
				1184,
				1184,
				1171,
				1171,
				1161,
				1161,
				1169,
				1169,
				1185,
				1185,
				1168,
				1168,
				1175,
				1175,
				1193,
				1193,
				1175,
				1175,
				1170,
				1170,
				1190,
				1190,
				1171,
				1171
			},
			{
				-10,
				13,
				23,
				34,
				42,
				57,
				61,
				68,
				63,
				75,
				69,
				74,
				79,
				87,
				82,
				113,
				110,
				128,
				131,
				144,
				148,
				169,
				165,
				199,
				207,
				226,
				239,
				258,
				276,
				284,
				305,
				341,
				340,
				331,
				331,
				343,
				338,
				364,
				369,
				428,
				428,
				452,
				460,
				514,
				514,
				540,
				540,
				586,
				636,
				636,
				552,
				549,
				545,
				539,
				529,
				529,
				533,
				533,
				530,
				530,
				537,
				537,
				530,
				530,
				521,
				483,
				480,
				416,
				382,
				345,
				340,
				353,
				348,
				346,
				346,
				350,
				328,
				297,
				297,
				269,
				269,
				247,
				247,
				222,
				222,
				182,
				182,
				170,
				170,
				116,
				116,
				111,
				111,
				85,
				85,
				68,
				68,
				60,
				60,
				31,
				31,
				-10
			},
			closed = true,
			text = {
				title_id = "cn_menu_westend_title",
				x = 789,
				y = 418
			}
		},
		{
			{
				1031,
				1052,
				1039,
				1039,
				1045,
				1045,
				1039,
				1039,
				1000,
				990,
				972,
				972,
				927,
				908,
				901,
				882,
				882,
				722,
				693,
				693,
				686,
				685,
				676,
				676,
				688,
				693,
				730,
				730,
				679,
				670,
				664,
				664,
				667,
				667,
				673,
				669,
				674,
				652,
				652
			},
			{
				530,
				574,
				575,
				616,
				616,
				667,
				667,
				893,
				893,
				883,
				883,
				855,
				855,
				842,
				853,
				853,
				906,
				906,
				874,
				816,
				816,
				804,
				804,
				785,
				785,
				774,
				774,
				759,
				759,
				754,
				745,
				734,
				726,
				691,
				686,
				683,
				677,
				657,
				636
			},
			closed = false,
			text = {
				title_id = "cn_menu_foggy_bottom_title",
				x = 858,
				y = 704
			}
		},
		{
			{
				512,
				529,
				516,
				519,
				513,
				495,
				498,
				501,
				504,
				500
			},
			{
				597,
				616,
				627,
				630,
				634,
				609,
				607,
				611,
				609,
				604
			},
			closed = true
		},
		{
			{
				559,
				569,
				571,
				639,
				631,
				647,
				616,
				616,
				610,
				610,
				601,
				598,
				589,
				580,
				569,
				561,
				557,
				557,
				584,
				584,
				580,
				591,
				589,
				580,
				570,
				564,
				568,
				563,
				558,
				561,
				552,
				546,
				550,
				549
			},
			{
				601,
				611,
				609,
				666,
				679,
				692,
				732,
				792,
				792,
				814,
				814,
				822,
				831,
				833,
				831,
				825,
				815,
				721,
				721,
				710,
				706,
				697,
				688,
				686,
				693,
				683,
				676,
				658,
				650,
				646,
				619,
				614,
				610,
				608
			},
			closed = true
		},
		{
			{
				2047,
				1972,
				1879,
				1879,
				1735,
				1677,
				1677,
				1683,
				1625,
				1619,
				1624,
				1620,
				1641,
				1641,
				1572,
				1571,
				1558,
				1558,
				1547,
				1547,
				1523,
				1523,
				1462,
				1462,
				1450,
				1450,
				1422,
				1402,
				1402,
				1356,
				1356,
				1316,
				1316,
				1308,
				1308,
				1279,
				1279,
				1245,
				1245,
				1200,
				1200,
				1039
			},
			{
				278,
				311,
				311,
				352,
				416,
				416,
				429,
				440,
				468,
				461,
				458,
				451,
				442,
				420,
				420,
				470,
				470,
				467,
				467,
				469,
				469,
				518,
				518,
				532,
				532,
				547,
				560,
				560,
				570,
				569,
				591,
				610,
				604,
				604,
				614,
				628,
				614,
				614,
				644,
				665,
				608,
				608
			},
			closed = false,
			text = {
				title_id = "cn_menu_shaw_title",
				x = 1426,
				y = 310
			}
		},
		{
			{
				1200,
				1206,
				1206,
				1201,
				1201,
				1251,
				1251,
				1201,
				1201,
				1205,
				1254,
				1254,
				1285,
				1285,
				1308,
				1308,
				1372,
				1372,
				1388,
				1388,
				1411,
				1411,
				1462,
				1462,
				1523,
				1523,
				1538,
				1538,
				1528,
				1527,
				1709,
				1709,
				1760,
				1880,
				1880,
				2047
			},
			{
				665,
				669,
				688,
				688,
				741,
				760,
				787,
				787,
				898,
				902,
				902,
				896,
				896,
				902,
				902,
				896,
				896,
				903,
				903,
				896,
				896,
				898,
				898,
				889,
				889,
				901,
				901,
				920,
				920,
				953,
				953,
				902,
				902,
				798,
				609,
				609
			},
			closed = false,
			text = {
				title_id = "cn_menu_downtown_title",
				x = 1469,
				y = 720
			}
		}
	}
	self.crime_net.map_start_positions = {
		{
			max_level = 10,
			zoom = 4,
			x = 1080,
			y = 512
		},
		{
			max_level = 20,
			zoom = 4,
			x = 1080,
			y = 512
		},
		{
			max_level = 30,
			zoom = 4,
			x = 1080,
			y = 512
		},
		{
			max_level = 40,
			zoom = 4,
			x = 1080,
			y = 512
		},
		{
			max_level = 50,
			zoom = 4,
			x = 1080,
			y = 512
		},
		{
			max_level = 60,
			zoom = 4,
			x = 1080,
			y = 512
		},
		{
			max_level = 70,
			zoom = 4,
			x = 1080,
			y = 512
		},
		{
			max_level = 80,
			zoom = 4,
			x = 1080,
			y = 512
		},
		{
			max_level = 90,
			zoom = 4,
			x = 1080,
			y = 512
		},
		{
			max_level = 100,
			zoom = 4,
			x = 1080,
			y = 512
		}
	}
	self.crime_net.special_contracts = {
		{
			name_id = "menu_cn_gage_assignment",
			menu_node = "crimenet_gage_assignment",
			dlc = "gage_pack_jobs",
			y = 910,
			id = "gage_assignment",
			icon = "guis/textures/pd2/crimenet_marker_gage",
			desc_id = "menu_cn_gage_assignment_desc",
			x = 425
		},
		{
			name_id = "menu_cn_contact_info",
			menu_node = "crimenet_contact_info",
			x = 912,
			y = 905,
			id = "contact_info",
			icon = "guis/textures/pd2/crimenet_marker_codex",
			desc_id = "menu_cn_contact_info_desc"
		},
		{
			name_id = "menu_cn_casino",
			menu_node = "crimenet_contract_casino",
			pulse = false,
			desc_id = "menu_cn_casino_desc",
			unlock = "unlock_level",
			y = 775,
			id = "casino",
			icon = "guis/textures/pd2/crimenet_casino",
			x = 385,
			pulse_color = Color(204, 255, 209, 32) / 255
		},
		{
			name_id = "menu_cn_premium_buy",
			menu_node = "contract_broker",
			x = 420,
			y = 846,
			id = "premium_buy",
			icon = "guis/textures/pd2/crimenet_marker_buy",
			desc_id = "menu_cn_premium_buy_desc"
		},
		{
			name_id = "menu_cn_short",
			menu_node = "crimenet_contract_short",
			pulse_level = 10,
			pulse = true,
			desc_id = "menu_cn_short_desc",
			y = 626,
			id = "short",
			icon = "guis/textures/pd2/crimenet_tutorial",
			x = 332,
			pulse_color = Color(204, 255, 209, 32) / 255
		},
		{
			name_id = "menu_mutators",
			menu_node = "mutators",
			pulse_level = 10,
			pulse = true,
			desc_id = "menu_mutators_help",
			y = 910,
			id = "mutators",
			icon = "guis/textures/pd2/crimenet_marker_mutators",
			x = 675,
			pulse_color = Color(255, 255, 0, 255) / 255,
			mutators_color = Color(255, 255, 0, 255) / 255
		},
		{
			name_id = "cn_crime_spree",
			menu_node = "crimenet_crime_spree_contract_host",
			pulse_level = 10,
			pulse = true,
			desc_id = "cn_crime_spree_help_start",
			mp_only = true,
			y = 810,
			id = "crime_spree",
			icon = "guis/textures/pd2/crimenet_marker_crimespree",
			x = 675,
			no_session_only = true,
			pulse_color = Color(255, 255, 255, 0) / 255
		},
		{
			name_id = "cn_crime_spree",
			menu_node = "crimenet_crime_spree_contract_singleplayer",
			pulse_level = 10,
			pulse = true,
			sp_only = true,
			desc_id = "cn_crime_spree_help_start",
			y = 810,
			id = "crime_spree",
			icon = "guis/textures/pd2/crimenet_marker_crimespree",
			x = 675,
			pulse_color = Color(255, 255, 255, 0) / 255
		}
	}

	if SystemInfo:platform() == Idstring("WIN32") then
		table.insert(self.crime_net.special_contracts, {
			name_id = "menu_cn_challenge",
			menu_node = "crimenet_contract_challenge",
			x = 362,
			y = 696,
			id = "challenge",
			icon = "guis/textures/pd2/crimenet_challenge",
			desc_id = "menu_cn_challenge_desc"
		})
	end

	self.crime_net.sidebar = {
		{
			name_id = "menu_cn_shortcuts",
			icon = "sidebar_expand",
			show_name_while_collapsed = false,
			callback = "clbk_toggle_sidebar"
		},
		{
			visible_callback = "clbk_visible_multiplayer",
			btn_macro = "menu_toggle_filters",
			callback = "clbk_crimenet_filters",
			name_id = "menu_cn_filters_sidebar",
			icon = "sidebar_filters"
		},
		{item_class = "CrimeNetSidebarSeparator"},
		{
			visible_callback = "clbk_visible_not_in_lobby",
			callback = "clbk_the_basics",
			name_id = "menu_cn_short",
			icon = "sidebar_basics",
			item_class = "CrimeNetSidebarTutorialHeistsItem"
		},
		{
			name_id = "menu_cn_story_missions",
			icon = "sidebar_question",
			item_class = "CrimeNetSidebarStoryMissionItem",
			callback = "clbk_open_story_missions"
		},
		{
			name_id = "menu_cn_chill",
			callback = "clbk_safehouse",
			id = "safehouse",
			icon = "sidebar_safehouse",
			item_class = "CrimeNetSidebarSafehouseItem"
		},
		{
			name_id = "menu_cn_premium_buy",
			icon = "sidebar_broker",
			callback = "clbk_contract_broker"
		},
		{item_class = "CrimeNetSidebarSeparator"},
		{
			name_id = "menu_cn_side_jobs",
			icon = "sidebar_side_jobs",
			callback = "clbk_side_jobs"
		},
		{
			name_id = "menu_cn_gage_assignment",
			icon = "sidebar_gage",
			callback = "clbk_gage_courier"
		},
		{
			name_id = "menu_cn_casino",
			icon = "sidebar_casino",
			callback = "clbk_offshore_payday"
		},
		{
			name_id = "menu_cn_contact_info",
			icon = "sidebar_codex",
			callback = "clbk_contact_database"
		},
		{item_class = "CrimeNetSidebarSeparator"},
		{
			name_id = "menu_mutators",
			callback = "clbk_mutators",
			id = "mutators",
			icon = "sidebar_mutators",
			item_class = "CrimeNetSidebarMutatorsItem"
		},
		{
			visible_callback = "clbk_visible_not_in_lobby",
			name_id = "cn_crime_spree",
			callback = "clbk_crime_spree",
			id = "crime_spree",
			icon = "sidebar_crimespree",
			item_class = "CrimeNetSidebarCrimeSpreeItem"
		},
		{
			visible_callback = "clbk_visible_skirmish",
			name_id = "menu_cn_skirmish",
			callback = "clbk_skirmish",
			id = "skirmish",
			icon = "sidebar_skirmish",
			item_class = "CrimeNetSidebarSkirmishItem"
		}
	}
	self.crime_net.codex = {
		{
			{
				{
					video = "bain",
					desc_id = "heist_contact_bain_description",
					post_event = "pln_contact_bain"
				},
				name_id = "heist_contact_bain",
				id = "bain"
			},
			{
				{
					desc_id = "heist_contact_vlad_description",
					post_event = "vld_quote_set_a",
					videos = {
						"vlad1",
						"vlad2",
						"vlad3"
					}
				},
				name_id = "heist_contact_vlad",
				id = "vlad"
			},
			{
				{
					desc_id = "heist_contact_hector_description",
					post_event = "hct_quote_set_a",
					videos = {
						"hector1",
						"hector2",
						"hector3"
					}
				},
				name_id = "heist_contact_hector",
				id = "hector"
			},
			{
				{
					desc_id = "heist_contact_the_elephant_description",
					post_event = "elp_quote_set_a",
					videos = {
						"the_elephant1",
						"the_elephant2",
						"the_elephant3"
					}
				},
				name_id = "heist_contact_the_elephant",
				id = "the_elephant"
			},
			{
				{
					desc_id = "heist_contact_gage_description",
					post_event = "pln_contact_gage",
					videos = {
						"gage1",
						"gage2",
						"gage3"
					}
				},
				name_id = "heist_contact_gage",
				id = "gage"
			},
			{
				{
					desc_id = "heist_contact_the_dentist_description",
					post_event = "dentist_quote_set_a",
					videos = {
						"the_dentist1",
						"the_dentist2",
						"the_dentist3",
						"the_dentist4",
						"the_dentist5",
						"the_dentist6"
					}
				},
				name_id = "heist_contact_the_dentist",
				id = "the_dentist"
			},
			{
				{
					desc_id = "heist_contact_the_butcher_description",
					post_event = "butcher_quote_set_a",
					videos = {
						"the_butcher1",
						"the_butcher2",
						"the_butcher3"
					}
				},
				name_id = "heist_contact_the_butcher",
				id = "the_butcher"
			},
			{
				{
					desc_id = "heist_contact_locke_description",
					post_event = "loc_quote_set_a",
					videos = {"locke1"}
				},
				name_id = "heist_contact_locke",
				id = "locke"
			},
			{
				{
					desc_id = "menu_jimmy_desc_codex",
					post_event = "pln_contact_jimmy",
					videos = {"jimmy1"}
				},
				name_id = "menu_jimmy",
				id = "jimmy_contact"
			},
			{
				{
					desc_id = "menu_continental_desc_codex",
					post_event = "continental_quote_set_a",
					videos = {"continental1"}
				},
				name_id = "menu_continental",
				id = "continental_contact"
			},
			name_id = "menu_contacts",
			id = "contacts"
		},
		{
			{
				{
					desc_id = "russian_desc_codex",
					post_event = "pln_contact_dallas",
					videos = {
						"dallas1",
						"dallas2",
						"dallas3"
					}
				},
				name_id = "menu_russian",
				id = "dallas"
			},
			{
				{
					desc_id = "german_desc_codex",
					post_event = "pln_contact_wolf",
					videos = {
						"wolf1",
						"wolf2"
					}
				},
				name_id = "menu_german",
				id = "wolf"
			},
			{
				{
					desc_id = "spanish_desc_codex",
					post_event = "pln_contact_chains",
					videos = {
						"chains1",
						"chains2",
						"chains3"
					}
				},
				name_id = "menu_spanish",
				id = "chains"
			},
			{
				{
					desc_id = "old_hoxton_desc_codex",
					post_event = "pln_contact_hoxton",
					videos = {
						"old_hoxton1",
						"old_hoxton2"
					}
				},
				name_id = "menu_old_hoxton",
				id = "old_hoxton"
			},
			{
				{
					desc_id = "jowi_desc_codex",
					post_event = "pln_contact_wick",
					videos = {
						"jowi1",
						"jowi2",
						"jowi3",
						"jowi4"
					}
				},
				name_id = "menu_jowi",
				id = "jowi"
			},
			{
				{
					desc_id = "american_desc_codex",
					post_event = "pln_contact_houston",
					videos = {
						"hoxton1",
						"hoxton2",
						"hoxton3"
					}
				},
				{
					desc_id = "houston_desc_codex",
					post_event = "pln_contact_houston",
					videos = {
						"hoxton1",
						"hoxton2",
						"hoxton3"
					}
				},
				name_id = "menu_american",
				id = "hoxton"
			},
			{
				{
					desc_id = "menu_clover_desc_codex",
					post_event = "pln_contact_clover",
					videos = {
						"clover1",
						"clover2"
					}
				},
				name_id = "menu_clover",
				id = "clover"
			},
			{
				{
					desc_id = "menu_dragan_desc_codex",
					post_event = "pln_contact_dragan",
					videos = {
						"dragan1",
						"dragan2",
						"dragan3"
					}
				},
				name_id = "menu_dragan",
				id = "dragan"
			},
			{
				{
					desc_id = "menu_jacket_desc_codex",
					post_event = "pln_contact_jacket",
					videos = {
						"jacket1",
						"jacket2"
					}
				},
				name_id = "menu_jacket",
				id = "jacket"
			},
			{
				{
					desc_id = "menu_bonnie_desc_codex",
					post_event = "pln_contact_bonnie",
					videos = {"bonnie1"}
				},
				name_id = "menu_bonnie",
				id = "bonnie"
			},
			{
				{
					desc_id = "menu_sokol_desc_codex",
					post_event = "pln_contact_sokol",
					videos = {"sokol1"}
				},
				name_id = "menu_sokol",
				id = "sokol"
			},
			{
				{
					desc_id = "menu_dragon_desc_codex",
					post_event = "pln_contact_jiro",
					videos = {"dragon1"}
				},
				name_id = "menu_dragon",
				id = "dragon"
			},
			{
				{
					desc_id = "menu_bodhi_desc_codex",
					post_event = "pln_contact_bodhi",
					videos = {"bodhi1"}
				},
				name_id = "menu_bodhi",
				id = "bodhi"
			},
			{
				{
					desc_id = "menu_jimmy_desc_codex",
					post_event = "pln_contact_jimmy",
					videos = {"jimmy1"}
				},
				name_id = "menu_jimmy",
				id = "jimmy"
			},
			{
				{
					desc_id = "menu_sydney_desc_codex",
					post_event = "pln_contact_sydney",
					videos = {"sydney1"}
				},
				name_id = "menu_sydney",
				id = "sydney"
			},
			{
				{
					desc_id = "menu_wild_desc_codex",
					post_event = "pln_contact_rust",
					videos = {"wild1"}
				},
				name_id = "menu_wild",
				id = "wild"
			},
			{
				{
					desc_id = "menu_chico_desc_codex",
					post_event = "pln_contact_tony",
					videos = {"chico1"}
				},
				name_id = "menu_chico",
				id = "chico"
			},
			{
				{
					desc_id = "menu_max_desc_codex",
					post_event = "pln_contact_sangres",
					videos = {"max1"}
				},
				name_id = "menu_max",
				id = "max"
			},
			{
				{
					desc_id = "menu_joy_desc_codex",
					post_event = "pln_contact_joy",
					videos = {"joy1"}
				},
				name_id = "menu_joy",
				id = "joy"
			},
			{
				{
					desc_id = "menu_myh_desc_codex",
					post_event = "pln_contact_duke",
					videos = {"myh1"}
				},
				name_id = "menu_myh",
				id = "myh"
			},
			{
				{
					desc_id = "menu_ecp_desc_codex",
					post_event = "pln_contact_ecp",
					videos = {"ecp1"}
				},
				name_id = "menu_ecp",
				id = "ecp"
			},
			name_id = "menu_playable_characters",
			id = "playable_characters"
		}
	}
	self.crime_net.locations = {}

	if not Application:production_build() or SystemInfo:platform() ~= Idstring("WIN32") then
		self.crime_net.locations = {{
			{
				weight = 100,
				dots = {
					{
						1601,
						425
					},
					{
						1025,
						835
					},
					{
						444,
						567
					},
					{
						1221,
						685
					},
					{
						1603,
						555
					},
					{
						1401,
						620
					},
					{
						1581,
						685
					},
					{
						1306,
						750
					},
					{
						1486,
						815
					},
					{
						1666,
						750
					},
					{
						1450,
						880
					},
					{
						1041,
						620
					},
					{
						730,
						880
					},
					{
						883,
						555
					},
					{
						861,
						685
					},
					{
						766,
						815
					},
					{
						946,
						750
					},
					{
						1480,
						165
					},
					{
						1304,
						295
					},
					{
						1484,
						230
					},
					{
						1664,
						295
					},
					{
						1241,
						425
					},
					{
						1421,
						360
					},
					{
						1063,
						490
					},
					{
						1243,
						555
					},
					{
						1423,
						490
					},
					{
						1120,
						165
					},
					{
						1124,
						230
					},
					{
						760,
						165
					},
					{
						764,
						230
					},
					{
						944,
						295
					},
					{
						701,
						360
					},
					{
						681,
						620
					},
					{
						881,
						425
					},
					{
						703,
						490
					},
					{
						400,
						165
					},
					{
						404,
						230
					},
					{
						584,
						295
					},
					{
						343,
						490
					},
					{
						224,
						295
					},
					{
						341,
						360
					},
					{
						521,
						425
					},
					{
						586,
						750
					}
				}
			},
			filters = {
				regions = {
					"street",
					"dock",
					"professional"
				},
				contacts = {
					"vlad",
					"the_elephant",
					"hector",
					"bain",
					"the_dentist",
					"the_butcher"
				},
				difficulties = {
					"normal",
					"hard",
					"overkill",
					"overkill_145",
					"easy_wish",
					"overkill_290",
					"sm_wish"
				}
			}
		}}
	else
		self.crime_net.locations = {
			{
				{
					{
						558,
						558,
						566,
						579,
						591,
						600,
						608,
						607,
						614,
						616
					},
					{
						722,
						812,
						824,
						832,
						827,
						811,
						810,
						788,
						790,
						722
					},
					weight = 500
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						610,
						644,
						555,
						591,
						593,
						582,
						585
					},
					{
						733,
						691,
						620,
						685,
						699,
						705,
						724
					},
					weight = 500
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						567,
						570,
						589,
						559,
						563,
						571
					},
					{
						683,
						690,
						684,
						623,
						652,
						678
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						627,
						636,
						568,
						556,
						549
					},
					{
						684,
						665,
						610,
						604,
						614
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						498,
						505,
						505,
						513,
						527,
						517,
						514
					},
					{
						611,
						611,
						602,
						598,
						615,
						624,
						632
					},
					weight = 5
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						372,
						416,
						416
					},
					{
						535,
						557,
						533
					},
					weight = 5
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						149,
						145,
						164,
						167
					},
					{
						446,
						455,
						462,
						452
					},
					weight = 5
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						168,
						167,
						182,
						184
					},
					{
						465,
						472,
						477,
						469
					},
					weight = 5
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						424,
						506,
						508,
						467,
						423
					},
					{
						535,
						536,
						549,
						581,
						556
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						479,
						499,
						498,
						471
					},
					{
						583,
						583,
						535,
						534
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						212,
						558,
						554,
						203
					},
					{
						432,
						430,
						248,
						251
					},
					weight = 500
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {"normal"}
				}
			},
			{
				{
					{
						240,
						543,
						542,
						241
					},
					{
						440,
						442,
						477,
						464
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {"normal"}
				}
			},
			{
				{
					{
						260,
						291,
						289,
						315,
						315,
						346,
						511,
						511
					},
					{
						432,
						472,
						483,
						493,
						500,
						514,
						514,
						407
					},
					weight = 500
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						376,
						382,
						502,
						511,
						511,
						542,
						542,
						510
					},
					{
						510,
						522,
						519,
						512,
						473,
						441,
						420,
						421
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						554,
						567,
						577,
						574,
						609,
						556,
						522
					},
					{
						416,
						416,
						407,
						360,
						302,
						247,
						291
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						598,
						630,
						690,
						701,
						679,
						659,
						639,
						639,
						596
					},
					{
						298,
						276,
						275,
						266,
						229,
						210,
						211,
						219,
						219
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						536,
						524,
						505,
						504,
						491,
						491,
						472,
						470
					},
					{
						253,
						232,
						229,
						180,
						180,
						215,
						215,
						261
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						205,
						202,
						339,
						373,
						474,
						472
					},
					{
						251,
						123,
						125,
						147,
						173,
						267
					},
					weight = 500
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						564,
						563,
						576,
						576
					},
					{
						190,
						206,
						207,
						191
					},
					weight = 5
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						341,
						349,
						358,
						372,
						373,
						369,
						367,
						359,
						358,
						349,
						349,
						340
					},
					{
						103,
						105,
						108,
						107,
						115,
						115,
						122,
						121,
						116,
						115,
						121,
						120
					},
					weight = 1
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						553,
						628,
						628,
						555
					},
					{
						243,
						245,
						282,
						326
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						148,
						166,
						164,
						185,
						189,
						224,
						225,
						135
					},
					{
						422,
						423,
						436,
						436,
						432,
						432,
						123,
						125
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						553,
						544,
						774,
						832,
						879,
						925,
						977,
						988,
						1036,
						874,
						735,
						599,
						598
					},
					{
						514,
						538,
						527,
						528,
						533,
						527,
						534,
						527,
						529,
						161,
						342,
						458,
						515
					},
					weight = 500
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						585,
						602,
						598,
						641,
						734,
						732,
						760,
						772,
						609,
						591
					},
					{
						452,
						462,
						584,
						637,
						635,
						552,
						544,
						527,
						429,
						429
					},
					weight = 50
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						740,
						708,
						702,
						652,
						650,
						640,
						625,
						635,
						602,
						743
					},
					{
						343,
						343,
						333,
						333,
						344,
						339,
						363,
						368,
						443,
						437
					},
					weight = 25
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						983,
						1059,
						1059,
						656,
						707,
						755,
						833
					},
					{
						423,
						384,
						162,
						162,
						199,
						258,
						393
					},
					weight = 500
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1058,
						1094,
						1112,
						1133,
						1174,
						1172,
						1183,
						1183,
						1170,
						1170,
						1049
					},
					{
						337,
						349,
						345,
						349,
						328,
						296,
						296,
						269,
						268,
						248,
						248
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1053,
						1168,
						1149,
						1004,
						872
					},
					{
						162,
						166,
						340,
						341,
						162
					},
					weight = 500
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						997,
						1071,
						1201,
						1886,
						1879,
						1197,
						1206
					},
					{
						418,
						609,
						608,
						253,
						105,
						110,
						325
					},
					weight = 500
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1045,
						1115,
						1127,
						1110,
						1092,
						1072,
						1066,
						1058,
						1041
					},
					{
						604,
						607,
						354,
						351,
						358,
						347,
						352,
						578,
						576
					},
					weight = 50
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1204,
						1239,
						1239,
						1280,
						1280,
						1305,
						1307,
						1200
					},
					{
						658,
						642,
						606,
						612,
						624,
						613,
						536,
						590
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1306,
						1318,
						1352,
						1354,
						1399,
						1401,
						1284
					},
					{
						602,
						606,
						589,
						565,
						568,
						487,
						539
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1399,
						1426,
						1446,
						1447,
						1460,
						1460,
						1522,
						1521,
						1376
					},
					{
						559,
						556,
						545,
						529,
						527,
						513,
						516,
						423,
						481
					},
					weight = 25
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1521,
						1569,
						1571,
						1510
					},
					{
						466,
						465,
						394,
						411
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1625,
						1625,
						1678,
						1676,
						1643,
						1642
					},
					{
						455,
						465,
						441,
						416,
						418,
						445
					},
					weight = 5
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1563,
						1733,
						1877,
						1878
					},
					{
						417,
						414,
						349,
						239
					},
					weight = 50
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1125,
						1181,
						1177,
						1187,
						1188,
						1238,
						1239
					},
					{
						358,
						328,
						300,
						298,
						266,
						267,
						361
					},
					weight = 25
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1162,
						1162,
						1172,
						1170,
						1212,
						1211,
						1170,
						1171
					},
					{
						225,
						246,
						247,
						267,
						269,
						181,
						183,
						223
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1185,
						1186,
						1171,
						1170,
						1178,
						1218,
						1216
					},
					{
						184,
						168,
						168,
						120,
						112,
						111,
						189
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						772,
						1033,
						1036,
						972,
						736,
						733,
						763
					},
					{
						529,
						537,
						895,
						854,
						814,
						550,
						547
					},
					weight = 200
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						743,
						696,
						675,
						696,
						692,
						723,
						882,
						881,
						917,
						917
					},
					{
						780,
						776,
						792,
						817,
						873,
						906,
						903,
						854,
						835,
						791
					},
					weight = 50
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						653,
						655,
						676,
						668,
						667,
						665,
						678,
						750,
						747
					},
					{
						639,
						659,
						676,
						693,
						735,
						744,
						758,
						760,
						636
					},
					weight = 25
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						916,
						928,
						973,
						972,
						990,
						999,
						1036,
						1035,
						904
					},
					{
						846,
						853,
						854,
						882,
						882,
						892,
						892,
						831,
						829
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1033,
						1044,
						1042,
						1038,
						1039,
						1050,
						1033,
						1000,
						1004
					},
					{
						667,
						667,
						615,
						615,
						574,
						573,
						536,
						539,
						683
					},
					weight = 5
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1872,
						1879,
						1763,
						1199,
						1250,
						1240
					},
					{
						359,
						790,
						900,
						879,
						788,
						647
					},
					weight = 500
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1201,
						1256,
						1277,
						1247,
						1244,
						1201,
						1209,
						1202
					},
					{
						739,
						763,
						613,
						614,
						644,
						665,
						675,
						689
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1259,
						1200,
						1203,
						1253,
						1265
					},
					{
						789,
						788,
						901,
						901,
						825
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1256,
						1283,
						1287,
						1307,
						1308,
						1374,
						1375,
						1391,
						1388,
						1460,
						1457,
						1254
					},
					{
						893,
						894,
						903,
						901,
						894,
						894,
						901,
						902,
						896,
						895,
						854,
						854
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1522,
						1524,
						1542,
						1540,
						1529,
						1528,
						1707,
						1706,
						1520
					},
					{
						891,
						898,
						901,
						920,
						921,
						950,
						951,
						874,
						872
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1575,
						1637,
						1638,
						1620,
						1625,
						1525,
						1523,
						1559,
						1575
					},
					{
						422,
						422,
						438,
						449,
						488,
						528,
						468,
						468,
						473
					},
					weight = 10
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1533,
						1462,
						1464,
						1453,
						1450,
						1530
					},
					{
						519,
						519,
						530,
						533,
						557,
						554
					},
					weight = 5
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1357,
						1355,
						1463,
						1463,
						1403,
						1402
					},
					{
						572,
						609,
						609,
						556,
						561,
						574
					},
					weight = 5
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			},
			{
				{
					{
						1676,
						1680,
						1753,
						1751
					},
					{
						417,
						461,
						464,
						415
					},
					weight = 5
				},
				filters = {
					regions = {
						"street",
						"dock",
						"professional"
					},
					contacts = {
						"vlad",
						"the_elephant",
						"hector",
						"bain"
					},
					difficulties = {
						"normal",
						"hard",
						"overkill",
						"overkill_145",
						"easy_wish",
						"overkill_290",
						"sm_wish"
					}
				}
			}
		}

		self:_create_location_bounding_boxes()
		self:_create_location_spawning_dots()
		print("Generating new spawn points for crimenet")
	end

	local wts = {}
	local dlc_1_folder = "units/pd2_dlc1/weapons/wpn_effects_textures/"
	local butch_folder = "units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/"
	wts.color_indexes = {
		{color = "red"},
		{
			color = "blue",
			dlc = "gage_pack_jobs"
		},
		{
			color = "green",
			dlc = "gage_pack_jobs"
		},
		{
			color = "yellow",
			dlc = "gage_pack_jobs"
		}
	}
	wts.types = {sight = {
		{
			name_id = "menu_reticle_1_s",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_s_1_il"
		},
		{
			name_id = "menu_reticle_1_m",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_m_1_il"
		},
		{
			name_id = "menu_reticle_1_l",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_l_1_il"
		},
		{
			name_id = "menu_reticle_2",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_2_il"
		},
		{
			name_id = "menu_reticle_3",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_3_il"
		},
		{
			name_id = "menu_reticle_4",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_4_il"
		},
		{
			name_id = "menu_reticle_5",
			dlc = "gage_pack_jobs",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_5_il"
		},
		{
			name_id = "menu_reticle_6",
			dlc = "gage_pack_jobs",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_6_il"
		},
		{
			name_id = "menu_reticle_7",
			dlc = "gage_pack_jobs",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_7_il"
		},
		{
			name_id = "menu_reticle_8",
			dlc = "gage_pack_jobs",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_8_il"
		},
		{
			name_id = "menu_reticle_9",
			dlc = "gage_pack_jobs",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_9_il"
		},
		{
			name_id = "menu_reticle_10",
			dlc = "gage_pack_jobs",
			texture_path = dlc_1_folder .. "wpn_sight_reticle_10_il"
		},
		{
			name_id = "menu_reticle_11",
			texture_path = butch_folder .. "wpn_sight_reticle_11_il"
		},
		{
			name_id = "menu_reticle_12",
			texture_path = butch_folder .. "wpn_sight_reticle_12_il"
		},
		{
			name_id = "menu_reticle_13",
			texture_path = butch_folder .. "wpn_sight_reticle_13_il"
		},
		{
			name_id = "menu_reticle_14",
			texture_path = butch_folder .. "wpn_sight_reticle_14_il"
		},
		{
			name_id = "menu_reticle_15",
			texture_path = butch_folder .. "wpn_sight_reticle_15_il"
		},
		{
			name_id = "menu_reticle_16",
			texture_path = butch_folder .. "wpn_sight_reticle_16_il"
		},
		{
			name_id = "menu_reticle_17",
			texture_path = butch_folder .. "wpn_sight_reticle_17_il"
		},
		{
			name_id = "menu_reticle_18",
			texture_path = butch_folder .. "wpn_sight_reticle_18_il"
		},
		{
			name_id = "menu_reticle_19",
			texture_path = butch_folder .. "wpn_sight_reticle_19_il"
		},
		{
			name_id = "menu_reticle_20",
			texture_path = butch_folder .. "wpn_sight_reticle_20_il"
		},
		{
			name_id = "menu_reticle_21",
			texture_path = butch_folder .. "wpn_sight_reticle_21_il"
		},
		{
			name_id = "menu_reticle_22",
			texture_path = butch_folder .. "wpn_sight_reticle_22_il"
		},
		{
			name_id = "menu_reticle_23",
			texture_path = butch_folder .. "wpn_sight_reticle_23_il"
		},
		suffix = "_il"
	}}
	wts.types.gadget = wts.types.sight
	self.weapon_texture_switches = wts
	self.default_part_texture_switch = "1 3"
	self.part_texture_switches = {
		wpn_fps_upg_o_45rds_v2 = "1 3",
		wpn_fps_upg_o_45rds = "1 3"
	}
	self.tradable_inventory_sort_list = {
		"aquired",
		"alphabetic",
		"quality",
		"rarity",
		"category",
		"bonus"
	}
	self.new_heists = {limit = 5}

	table.insert(self.new_heists, {
		name_id = "menu_nh_icebreaker",
		texture_path = "guis/textures/pd2/new_heists/icebreaker",
		url = "https://www.overkillsoftware.com/games/icebreaker/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_sft",
		texture_path = "guis/textures/pd2/new_heists/menu_nh_sft",
		url = "https://steamcommunity.com/games/218620/announcements/detail/2885003081979937951"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_euu",
		texture_path = "guis/textures/pd2/new_heists/euu",
		url = "https://steamcommunity.com/games/218620/announcements/detail/1698303218390483331"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_cat",
		texture_path = "guis/textures/pd2/new_heists/cat",
		url = "http://www.overkillsoftware.com/games/communitysafe7/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_sb_2018_thesecretisreallyreal",
		texture_path = "guis/textures/pd2/new_heists/sb_2018_thesecretisreallyreal",
		url = "http://www.overkillsoftware.com/archive/thesecretisreallyreal/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_pd2vr_launch",
		texture_path = "guis/textures/pd2/new_heists/pd2vr_launch",
		url = "http://steamcommunity.com/games/218620/announcements/detail/1669019670888919416"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_sb_2018_sale",
		texture_path = "guis/textures/pd2/new_heists/sb_2018_sale",
		url = "http://store.steampowered.com/app/218620/PAYDAY_2/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_ggez",
		texture_path = "guis/textures/pd2/new_heists/difficultyandsniper_update",
		url = "http://steamcommunity.com/games/218620/announcements/detail/1666767238319907275"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_css",
		texture_path = "guis/textures/pd2/new_heists/css",
		url = "http://steamcommunity.com/games/218620/announcements/detail/1671268301110805355"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_ami",
		texture_path = "guis/textures/pd2/new_heists/ami",
		url = "http://steamcommunity.com/games/218620/announcements/detail/1664512272293565206"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_fgl",
		texture_path = "guis/textures/pd2/new_heists/fgl",
		url = "http://steamcommunity.com/games/218620/announcements/detail/2784778964087853978"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_brooklynbank_heist",
		texture_path = "guis/textures/pd2/new_heists/brooklynbank_heist",
		url = "http://www.overkillsoftware.com/games/brookyn-bank-heist/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_reservoirdogs_heist",
		texture_path = "guis/textures/pd2/new_heists/reservoirdogs_heist",
		url = "http://www.overkillsoftware.com/games/reservoirdogs/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_h3h3_characters",
		texture_path = "guis/textures/pd2/new_heists/h3h3_characters",
		url = "http://www.overkillsoftware.com/games/h3h3/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_locke_and_load_ultimate_discount",
		texture_path = "guis/textures/pd2/new_heists/locke_and_load_discount",
		url = "http://store.steampowered.com/bundle/3756/PAYDAY_2_Ultimate_Edition/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_halloween_2017_heist",
		texture_path = "guis/textures/pd2/new_heists/halloween_2017_heist",
		url = "http://steamcommunity.com/games/218620/announcements/detail/1453961083959105742"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_cas",
		texture_path = "guis/textures/pd2/new_heists/community_armor_safe",
		url = "http://www.overkillsoftware.com/games/communityarmorsafe/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_locke_and_load_event",
		texture_path = "guis/textures/pd2/new_heists/locke_and_load_event",
		url = "http://www.overkillsoftware.com/games/lockeandload/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_locke_and_load_f2p",
		texture_path = "guis/textures/pd2/new_heists/locke_and_load_f2p",
		url = "http://store.steampowered.com/app/218620/PAYDAY_2/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_enter_the_gungeon_collab",
		texture_path = "guis/textures/pd2/new_heists/enter_the_gungeon_collab",
		url = "http://steamcommunity.com/games/218620/announcements/detail/1462966036244751362"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_community_safe_5",
		texture_path = "guis/textures/pd2/new_heists/community_safe_5",
		url = "http://www.overkillsoftware.com/games/communitysafe5/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_aldstone_room",
		texture_path = "guis/textures/pd2/new_heists/aldstone_room",
		url = "http://www.overkillsoftware.com/games/aldstonesheritage/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_golden_chains",
		texture_path = "guis/textures/pd2/new_heists/golden_chains",
		url = "http://steamcommunity.com/games/218620/announcements/detail/1444947199697735668"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_ultimate_edition",
		texture_path = "guis/textures/pd2/new_heists/ultimate_edition",
		url = "http://store.steampowered.com/app/218620"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_community_safe_4",
		texture_path = "guis/textures/pd2/new_heists/community_safe_4",
		url = "http://www.overkillsoftware.com/games/communitysafe4/"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_crime_spree_update",
		texture_path = "guis/textures/pd2/new_heists/crime_spree_update",
		url = "http://store.steampowered.com/news/?appids=218620"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_dsync_beta_is_live",
		texture_path = "guis/textures/pd2/new_heists/desync_beta_is_live",
		url = "http://steamcommunity.com/games/218620/announcements/detail/1342486185513464930"
	})
	table.insert(self.new_heists, {
		name_id = "menu_nh_russian_national_day",
		texture_path = "guis/textures/pd2/new_heists/russian_national_day",
		url = "http://store.steampowered.com/news/?appids=218620"
	})
end

function GuiTweakData:_create_location_bounding_boxes()
	for _, location in ipairs(self.crime_net.locations) do
		local params = location[1]

		if params then
			local min_x, max_x, min_y, max_y = nil

			for _, x in ipairs(params[1]) do
				min_x = not min_x and x or math.min(min_x, x)
				max_x = not max_x and x or math.max(max_x, x)
			end

			for _, y in ipairs(params[2]) do
				min_y = not min_y and y or math.min(min_y, y)
				max_y = not max_y and y or math.max(max_y, y)
			end

			params.bounding_box = {
				min_x,
				max_x,
				min_y,
				max_y
			}
		end
	end
end

function GuiTweakData:_create_location_spawning_dots()
	local map_w = 2048
	local map_h = 1024
	local border_w = 125
	local border_h = 50
	local start_y = 50
	local start_x = -50
	local step_x = 180
	local step_y = 130
	local random_x = 0
	local random_y = 0
	local random_step_x = step_x / 2
	local zig_y = step_y / 2
	local zig = true

	for y = border_h + start_y, map_h - 2 * border_h + start_y, step_y do
		for x = border_w + math.random(-random_step_x, random_step_x) + start_x, map_w - 2 * border_w + start_x, step_x do
			local found_point = false
			local rx = x + math.random(-random_x, random_x)
			local ry = y + math.random(-random_y, random_y) + (zig and zig_y or 0)

			for _, location_data in ipairs(self.crime_net.locations) do
				local location = location_data[1]
				local bounding_box = location.bounding_box
				location.dots = location.dots or {}

				if bounding_box[1] <= rx and rx <= bounding_box[2] and bounding_box[3] <= ry and ry <= bounding_box[4] then
					local vx = location[1]
					local vy = location[2]
					local j, c = nil
					j = #vx

					for i = 1, #vx, 1 do
						if ry < vy[i] ~= ry < vy[j] and rx < ((vx[j] - vx[i]) * (ry - vy[i])) / (vy[j] - vy[i]) + vx[i] then
							found_point = not found_point
						end

						j = i
					end

					if found_point then
						table.insert(location.dots, {
							rx,
							ry
						})

						break
					end
				end
			end

			zig = not zig
		end

		zig = not zig
	end

	local new_locations = {{}}
	new_locations[1].filters = self.crime_net.locations[1].filters
	new_locations[1][1] = {
		dots = {},
		weight = 100
	}

	for i = #self.crime_net.locations, 1, -1 do
		if self.crime_net.locations[i][1].dots then
			for _, dot in pairs(self.crime_net.locations[i][1].dots) do
				table.insert(new_locations[1][1].dots, dot)
			end
		end
	end

	self.crime_net.locations = new_locations
end

function GuiTweakData:create_narrative_locations(locations)
end

function GuiTweakData:print_locations()
end

function GuiTweakData:serializeTable(val, name, skipnewlines, depth)
	skipnewlines = skipnewlines or false
	depth = depth or 0
	local tmp = ""

	if name and type(name) == "string" then
		tmp = tmp .. name .. "="
	end

	if type(val) == "table" then
		tmp = tmp .. "{ " .. (depth == 0 and "\n" or "")
		local i = 1

		for k, v in pairs(val) do
			tmp = tmp .. self:serializeTable(v, k, skipnewlines, depth + 1)

			if depth > 0 and i < table.size(val) then
				tmp = tmp .. ", "
				i = i + 1
			else
				tmp = tmp .. " "
			end
		end

		tmp = tmp .. "}" .. (depth <= 1 and ", \n" or "")
	elseif type(val) == "number" then
		tmp = tmp .. tostring(val)
	elseif type(val) == "string" then
		tmp = tmp .. string.format("%q", val)
	elseif type(val) == "boolean" then
		tmp = tmp .. (val and "true" or "false")
	else
		tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
	end

	return tmp
end

function GuiTweakData:tradable_inventory_sort_func(index)
	if type(index) == "string" then
		index = self:tradable_inventory_sort_index(index)
	end

	if index == 1 then
		return function (x, y)
			return y < x
		end
	elseif index == 2 then
		local inventory_tradable = managers.blackmarket:get_inventory_tradable()
		local x_item, y_item, x_td, y_td, x_loc, y_loc = nil
		local localization_cache = {}

		return function (x, y)
			x_item = inventory_tradable[x]
			y_item = inventory_tradable[y]
			x_td = (tweak_data.economy[x_item.category] or tweak_data.blackmarket[x_item.category])[x_item.entry]
			y_td = (tweak_data.economy[y_item.category] or tweak_data.blackmarket[y_item.category])[y_item.entry]

			if x_td.name_id ~= y_td.name_id then
				localization_cache[x_td.name_id] = localization_cache[x_td.name_id] or managers.localization:to_upper_text(x_td.name_id)
				localization_cache[y_td.name_id] = localization_cache[y_td.name_id] or managers.localization:to_upper_text(y_td.name_id)
				x_loc = localization_cache[x_td.name_id]
				y_loc = localization_cache[y_td.name_id]

				return x_loc < y_loc
			end

			return y < x
		end
	elseif index == 3 then
		local inventory_tradable = managers.blackmarket:get_inventory_tradable()
		local x_item, y_item, x_quality, y_quality = nil

		return function (x, y)
			x_item = inventory_tradable[x]
			y_item = inventory_tradable[y]
			x_quality = tweak_data.economy.qualities[x_item.quality]
			y_quality = tweak_data.economy.qualities[y_item.quality]

			if not x_quality then
				return false
			end

			if not y_quality then
				return not x_quality
			end

			if x_quality.index ~= y_quality.index then
				return y_quality.index < x_quality.index
			end

			if x_item.entry ~= y_item.entry then
				return x_item.entry < y_item.entry
			end

			return y < x
		end
	elseif index == 4 then
		local inventory_tradable = managers.blackmarket:get_inventory_tradable()
		local x_item, y_item, x_td, y_td, x_rarity, y_rarity = nil

		return function (x, y)
			x_item = inventory_tradable[x]
			y_item = inventory_tradable[y]
			x_td = (tweak_data.economy[x_item.category] or tweak_data.blackmarket[x_item.category])[x_item.entry]
			y_td = (tweak_data.economy[y_item.category] or tweak_data.blackmarket[y_item.category])[y_item.entry]
			x_rarity = tweak_data.economy.rarities[x_td.rarity or "common"]
			y_rarity = tweak_data.economy.rarities[y_td.rarity or "common"]

			if x_rarity.index ~= y_rarity.index then
				return y_rarity.index < x_rarity.index
			end

			if x_item.entry ~= y_item.entry then
				return x_item.entry < y_item.entry
			end

			return y < x
		end
	elseif index == 5 then
		local inventory_tradable = managers.blackmarket:get_inventory_tradable()
		local x_item, y_item = nil

		return function (x, y)
			x_item = inventory_tradable[x]
			y_item = inventory_tradable[y]

			if x_item.category ~= y_item.category then
				return x_item.category < y_item.category
			end

			if x_item.entry ~= y_item.entry then
				return x_item.entry < y_item.entry
			end

			return y < x
		end
	elseif index == 6 then
		local inventory_tradable = managers.blackmarket:get_inventory_tradable()
		local x_item, y_item = nil

		return function (x, y)
			x_item = inventory_tradable[x]
			y_item = inventory_tradable[y]

			if x_item.bonus ~= y_item.bonus then
				return x_item.bonus
			end

			if x_item.entry ~= y_item.entry then
				return x_item.entry < y_item.entry
			end

			return y < x
		end
	end

	return nil
end

function GuiTweakData:tradable_inventory_sort_name(index)
	return self.tradable_inventory_sort_list[index] or "none"
end

function GuiTweakData:tradable_inventory_sort_index(name)
	for index, n in ipairs(self.tradable_inventory_sort_list) do
		if n == name then
			return index
		end
	end

	return 0
end

