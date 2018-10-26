MoneyTweakData = MoneyTweakData or class()

function MoneyTweakData._create_value_table(min, max, table_size, round, curve)
	local t = {}

	for i = 1, table_size, 1 do
		local v = math.lerp(min, max, math.pow((i - 1) / (table_size - 1), curve and curve or 1))

		if v > 999 then
			v = v * 0.001

			if round then
				v = math.ceil(v) or v
			end

			v = v * 1000
		elseif v > 99 then
			v = v * 0.01

			if round then
				v = math.ceil(v) or v
			end

			v = v * 100
		elseif v > 9 then
			v = v * 0.1

			if round then
				v = math.ceil(v) or v
			end

			v = v * 10
		elseif round then
			v = math.ceil(v) or v
		end

		table.insert(t, v)
	end

	return t
end

function MoneyTweakData:init(tweak_data)
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)
	self.biggest_score = 4000000
	self.biggest_cashout = 800000
	self.offshore_rate = self.biggest_cashout / self.biggest_score
	self.alive_players_max = 1.1
	self.cashout_without_player_alive = self.biggest_cashout / self.alive_players_max
	self.cut_difficulty = 4
	self.max_mission_bags = 6
	self.cut_lootbag_bonus = self.cashout_without_player_alive * 0.3
	self.cut_lootbag_bonus = (self.cut_lootbag_bonus / self.max_mission_bags) / self.cut_difficulty
	self.max_days = 3
	self.cut_stage_complete = self.cashout_without_player_alive * 0.55
	self.cut_stage_complete = self.cut_stage_complete / self.cut_difficulty * 0.7
	self.cut_job_complete = self.cashout_without_player_alive * 0.15
	self.cut_job_complete = self.cut_job_complete / self.cut_difficulty
	self.bag_values = {
		default = 100,
		money = 1500,
		gold = 2875,
		diamonds = 1000,
		coke = 2000,
		coke_pure = 3000,
		meth = 13000,
		meth_half = 6500,
		weapon = 3000,
		weapons = 3000,
		painting = 3000,
		samurai_suit = 5000,
		artifact_statue = 5000,
		mus_artifact_bag = 1000,
		circuit = 1000,
		shells = 2100,
		turret = 10000,
		sandwich = 10000,
		cro_loot = 10000,
		hope_diamond = 30000,
		evidence_bag = 3000,
		vehicle_falcogini = 4000,
		warhead = 4600,
		unknown = 5000,
		safe = 4600,
		prototype = 10000,
		counterfeit_money = 1100,
		box_unknown = 10000,
		black_tablet = 10000,
		masterpiece_painting = 10000,
		master_server = 10000,
		lost_artifact = 10000,
		present = 2049,
		mad_master_server_value_1 = 5000,
		mad_master_server_value_2 = 10000,
		mad_master_server_value_3 = 15000,
		mad_master_server_value_4 = 20000,
		weapon_glock = 2000,
		weapon_scar = 2000,
		drk_bomb_part = 9000,
		drone_control_helmet = 18000,
		toothbrush = 18000,
		cloaker_gold = 2000,
		cloaker_money = 1750,
		cloaker_cocaine = 1500,
		diamond_necklace = 2875,
		vr_headset = 2875,
		women_shoes = 2875,
		expensive_vine = 2875,
		ordinary_wine = 2875,
		robot_toy = 2875,
		rubies = 1500,
		red_diamond = 10000,
		old_wine = 2000
	}
	self.bag_value_multiplier = self._create_value_table(((self.cut_lootbag_bonus / 5) / self.offshore_rate) / self.bag_values.default, (self.cut_lootbag_bonus / self.offshore_rate) / self.bag_values.default, 7, true, 0.85)
	self.stage_completion = self._create_value_table((self.cut_stage_complete / 7) / self.offshore_rate, self.cut_stage_complete / self.offshore_rate, 7, true, 1)
	self.job_completion = self._create_value_table((self.cut_job_complete / 7) / self.offshore_rate, self.cut_job_complete / self.offshore_rate, 7, true, 1)
	self.flat_stage_completion = math.round(10000 / self.offshore_rate)
	self.flat_job_completion = 0
	self.level_limit = {
		low_cap_level = -1,
		low_cap_multiplier = 0.75,
		pc_difference_multipliers = {
			1,
			0.9,
			0.8,
			0.7,
			0.6,
			0.5,
			0.4,
			0.3,
			0.2,
			0.1
		}
	}
	self.stage_failed_multiplier = 0.1
	self.difficulty_multiplier = {
		4,
		9,
		12,
		20,
		35,
		40,
		45
	}
	self.difficulty_multiplier_payout = {
		1,
		2,
		5,
		10,
		11,
		13,
		14
	}
	self.small_loot_difficulty_multiplier = self._create_value_table(0, 0, 6, false, 1)
	self.alive_humans_multiplier = self._create_value_table(1, self.alive_players_max, tweak_data.max_players, false, 1)
	self.alive_humans_multiplier[0] = 1
	self.limited_bonus_multiplier = 1
	self.sell_weapon_multiplier = 0.25
	self.sell_mask_multiplier = 0.25
	self.killing_civilian_deduction = self._create_value_table(2000, 50000, 10, true, 2)
	self.buy_premium_multiplier = {
		hard = 0,
		overkill = 0,
		overkill_145 = 0,
		normal = 0,
		easy_wish = 0,
		overkill_290 = 0,
		sm_wish = 0,
		easy = 0
	}
	self.buy_premium_static_fee = {
		hard = 0,
		overkill = 0,
		overkill_145 = 0,
		normal = 0,
		easy_wish = 0,
		overkill_290 = 0,
		sm_wish = 0,
		easy = 0
	}
	self.global_value_multipliers = {
		normal = 1,
		superior = 1,
		exceptional = 1,
		infamous = 5,
		infamy = 0,
		preorder = 1,
		overkill = 0.01,
		pd2_clan = 1,
		halloween = 1,
		xmas = 1,
		armored_transport = 1.2,
		big_bank = 0.8,
		gage_pack = 1.4,
		gage_pack_lmg = 1.8,
		gage_pack_jobs = 0,
		gage_pack_snp = 0.8,
		gage_pack_shotgun = 1,
		gage_pack_assault = 1,
		gage_pack_historical = 1,
		xmas_soundtrack = 1,
		sweettooth = 1,
		legendary = 1,
		poetry_soundtrack = 0,
		twitch_pack = 0,
		humble_pack2 = 0,
		humble_pack3 = 0,
		humble_pack4 = 0,
		e3_s15a = 0,
		e3_s15b = 0,
		e3_s15c = 0,
		e3_s15d = 0,
		hl_miami = 1,
		hlm_game = 1,
		alienware_alpha = 1,
		alienware_alpha_promo = 1,
		character_pack_clover = 1,
		hope_diamond = 1,
		goty_weapon_bundle_2014 = 1,
		goty_heist_bundle_2014 = 1,
		goty_dlc_bundle_2014 = 1,
		character_pack_dragan = 1,
		the_bomb = 1,
		bbq = 1,
		akm4_pack = 1,
		overkill_pack = 1,
		complete_overkill_pack = 1,
		hlm2 = 1,
		hlm2_deluxe = 1,
		butch_pack_free = 1,
		speedrunners = 1,
		west = 1,
		arena = 1,
		character_pack_sokol = 1,
		kenaz = 1,
		turtles = 1,
		bobblehead = 1,
		dragon = 1,
		pdcon_2015 = 1,
		pdcon_2016 = 1,
		steel = 1,
		berry = 1,
		peta = 1,
		pal = 1,
		coco = 1,
		dbd_clan = 1,
		dbd_deluxe = 1,
		solus_clan = 1,
		wild = 1,
		born = 1,
		sparkle = 0,
		rota = 1,
		pim = 1,
		tango = 1,
		friend = 1,
		chico = 1,
		rvd = 1,
		swm_bundle = 1,
		spa = 1,
		sha = 1,
		grv = 1,
		amp = 1,
		mp2 = 1,
		ant = 1,
		ant_free = 1,
		pn2 = 0,
		max = 1,
		dgm = 1,
		joy = 1,
		raidww2_clan = 1,
		fdm = 0,
		eng = 1,
		pbm = 0
	}
	self.global_value_bonus_multiplier = {
		normal = 0,
		superior = 0.1,
		exceptional = 0.2,
		infamous = 1,
		infamy = 1,
		preorder = 0,
		overkill = 20,
		pd2_clan = 0,
		halloween = 0,
		xmas = 0,
		armored_transport = 0.5,
		big_bank = 0.4,
		gage_pack = 0.5,
		gage_pack_lmg = 0.5,
		gage_pack_jobs = 0,
		gage_pack_snp = 0.2,
		gage_pack_shotgun = 0.2,
		gage_pack_assault = 0.2,
		gage_pack_historical = 0.2,
		xmas_soundtrack = 0,
		sweettooth = 0,
		legendary = 0,
		poetry_soundtrack = 0,
		twitch_pack = 0,
		humble_pack2 = 0,
		humble_pack3 = 0,
		humble_pack4 = 0,
		e3_s15a = 0,
		e3_s15b = 0,
		e3_s15c = 0,
		e3_s15d = 0,
		hl_miami = 0.2,
		hlm_game = 0.2,
		alienware_alpha = 0.2,
		alienware_alpha_promo = 0.2,
		character_pack_clover = 0.2,
		hope_diamond = 0.2,
		goty_weapon_bundle_2014 = 0.2,
		goty_heist_bundle_2014 = 0.2,
		goty_dlc_bundle_2014 = 0.2,
		character_pack_dragan = 0.2,
		the_bomb = 0.2,
		bbq = 0.2,
		akm4_pack = 0.2,
		overkill_pack = 0.2,
		complete_overkill_pack = 0.3,
		hlm2 = 0.2,
		hlm2_deluxe = 0.5,
		butch_pack_free = 0.2,
		speedrunners = 0,
		west = 0.2,
		arena = 0.2,
		character_pack_sokol = 0.2,
		kenaz = 0.2,
		turtles = 0.2,
		bobblehead = 0.2,
		dragon = 0.2,
		pdcon_2015 = 0.2,
		pdcon_2016 = 0.2,
		steel = 0.2,
		berry = 0.2,
		peta = 0.2,
		pal = 0.2,
		coco = 0.2,
		dbd_clan = 0,
		dbd_deluxe = 0.5,
		solus_clan = 0,
		wild = 0.2,
		born = 0.2,
		sparkle = 0,
		rota = 1,
		pim = 1,
		tango = 1,
		friend = 1,
		chico = 1,
		swm_bundle = 1,
		spa = 1,
		sha = 1,
		grv = 1,
		amp = 1,
		mp2 = 1,
		ant = 1,
		ant_free = 1,
		pn2 = 0,
		max = 1,
		dgm = 1,
		joy = 1,
		raidww2_clan = 1,
		fdm = 1,
		eng = 1,
		pbm = 1
	}
	local smallest_cashout = (self.stage_completion[1] + self.job_completion[1]) * self.offshore_rate
	local biggest_mask_cost = self.biggest_cashout * 40
	local biggest_mask_cost_deinfamous = math.round(biggest_mask_cost / self.global_value_multipliers.infamous)
	local biggest_mask_part_cost = math.round(smallest_cashout * 20)
	local smallest_mask_part_cost = math.round(smallest_cashout * 1.9)
	local biggest_weapon_cost = math.round(self.biggest_cashout * 1.15)
	local smallest_weapon_cost = math.round(smallest_cashout * 3)
	local biggest_weapon_mod_cost = math.round(self.biggest_cashout * 0.1)
	local smallest_weapon_mod_cost = math.round(smallest_cashout * 0.6)
	self.weapon_cost = self._create_value_table(smallest_weapon_cost, biggest_weapon_cost, 40, true, 1.1)
	self.modify_weapon_cost = self._create_value_table(smallest_weapon_mod_cost, biggest_weapon_mod_cost, 10, true, 1.2)
	self.remove_weapon_mod_cost_multiplier = self._create_value_table(1, 1, 10, true, 1)
	self.masks = {
		mask_value = self._create_value_table(smallest_mask_part_cost, smallest_mask_part_cost * 2, 10, true, 2),
		material_value = self._create_value_table(smallest_mask_part_cost * 0.5, biggest_mask_part_cost, 10, true, 1.2),
		pattern_value = self._create_value_table(smallest_mask_part_cost * 0.4, biggest_mask_part_cost, 10, true, 1.1),
		color_value = self._create_value_table(smallest_mask_part_cost * 0.3, biggest_mask_part_cost, 10, true, 1)
	}
	self.skill_switch_cost = {
		{
			offshore = 0,
			spending = 0
		},
		{
			offshore = 0,
			spending = 0
		},
		{
			offshore = 1000000,
			spending = 0
		},
		{
			offshore = 10000000,
			spending = 0
		},
		{
			offshore = 25000000,
			spending = 0
		},
		{
			offshore = 25000000,
			spending = 0
		},
		{
			offshore = 25000000,
			spending = 0
		},
		{
			offshore = 25000000,
			spending = 0
		},
		{
			offshore = 25000000,
			spending = 0
		},
		{
			offshore = 30000000,
			spending = 0
		},
		{
			offshore = 30000000,
			spending = 0
		},
		{
			offshore = 30000000,
			spending = 0
		},
		{
			offshore = 30000000,
			spending = 0
		},
		{
			offshore = 30000000,
			spending = 0
		},
		{
			offshore = 20000000,
			spending = 0
		}
	}
	self.mission_asset_cost_by_pc = self._create_value_table(1, 1, 10, true, 1)
	self.mission_asset_cost_multiplier_by_pc = {
		0,
		0,
		0,
		0,
		0,
		0,
		1
	}
	self.mission_asset_cost_multiplier_by_risk = {
		0.5,
		1,
		2,
		4,
		6,
		8,
		10
	}
	self.mission_asset_cost_small = self._create_value_table(2500, 15000, 10, true, 1)
	self.mission_asset_cost_medium = self._create_value_table(10000, 45000, 10, true, 1)
	self.mission_asset_cost_large = self._create_value_table(55000, 400000, 10, true, 1)
	self.preplaning_asset_cost_multiplier_by_risk = {
		1,
		2,
		5,
		10,
		13,
		13,
		13
	}
	self.preplaning_asset_cost_thermite = 15000
	self.preplaning_asset_cost_escapebig = 10000
	self.preplaning_asset_cost_spycam = 1000
	self.preplaning_asset_cost_delay10 = 1000
	self.preplaning_asset_cost_delay20 = 1000
	self.preplaning_asset_cost_delay30 = 2000
	self.preplaning_asset_cost_timelock60 = 2000
	self.preplaning_asset_cost_cake = 3000
	self.preplaning_asset_cost_extracameras = 500
	self.preplaning_asset_cost_accesscameras = 1000
	self.preplaning_asset_cost_drillparts = 3000
	self.preplaning_asset_cost_deaddropbag = 1600
	self.preplaning_asset_cost_unlocked_door = 1000
	self.preplaning_asset_cost_unlocked_window = 1000
	self.preplaning_asset_cost_zipline = 2000
	self.preplaning_asset_cost_highlight_keybox = 1000
	self.preplaning_asset_cost_keycard = 2000
	self.preplaning_asset_cost_disable_alarm_button = 2000
	self.preplaning_asset_cost_safe_escape = 2000
	self.preplaning_asset_cost_sniper_spot = 2000
	self.preplaning_asset_cost_framing_frame_1_truck = 1000
	self.preplaning_asset_cost_framing_frame_1_entry_point = 1000
	self.preplaning_asset_cost_bag_shortcut = 2000
	self.preplaning_asset_cost_bag_zipline = 2000
	self.preplaning_asset_cost_loot_drop_off = 3000
	self.preplaning_asset_cost_thermal_paste = 3000
	self.preplaning_asset_cost_branchbank_vault_key = 3000
	self.preplaning_mia_cost_sniper = 3000
	self.preplaning_mia_cost_delayed_police = 2000
	self.preplaning_mia_cost_reduce_mobsters = 2000
	self.preplaning_asset_cost_glass_cutter = 1000
	self.preplaning_thebomb_cost_spotter = 4000
	self.preplaning_thebomb_cost_crowbar = 1000
	self.preplaning_thebomb_cost_ladder = 1000
	self.preplaning_thebomb_cost_hacker = 3000
	self.preplaning_thebomb_cost_manifest = 2000
	self.preplaning_thebomb_cost_pilot = 3000
	self.preplaning_thebomb_cost_escape_mid = 6000
	self.preplaning_thebomb_cost_escape_close = 10000
	self.preplaning_thebomb_cost_demolition = 500
	self.small_loot = {}

	if difficulty_index <= 2 then
		self.small_loot.money_bundle = 1000
		self.small_loot.money_bundle_value = 10000
		self.small_loot.ring_band = 1954
		self.small_loot.diamondheist_vault_bust = 900
		self.small_loot.diamondheist_vault_diamond = 1150
		self.small_loot.diamondheist_big_diamond = 1150
		self.small_loot.mus_small_artifact = 700
		self.small_loot.value_gold = 3000
		self.small_loot.gen_atm = 23000
		self.small_loot.special_deposit_box = 3500
		self.small_loot.slot_machine_payout = 25000
		self.small_loot.vault_loot_chest = 570
		self.small_loot.vault_loot_diamond_chest = 610
		self.small_loot.vault_loot_banknotes = 500
		self.small_loot.vault_loot_silver = 540
		self.small_loot.vault_loot_diamond_collection = 650
		self.small_loot.vault_loot_trophy = 690
		self.small_loot.money_wrap_single_bundle_vscaled = 385
		self.small_loot.spawn_bucket_of_money = 20000
		self.small_loot.vault_loot_gold = 2500
		self.small_loot.vault_loot_cash = 1200
		self.small_loot.vault_loot_coins = 800
		self.small_loot.vault_loot_ring = 300
		self.small_loot.vault_loot_jewels = 600
		self.small_loot.vault_loot_macka = 1
	elseif difficulty_index == 3 then
		self.small_loot.money_bundle = 1000
		self.small_loot.money_bundle_value = 10000
		self.small_loot.ring_band = 1954
		self.small_loot.diamondheist_vault_bust = 1800
		self.small_loot.diamondheist_vault_diamond = 2300
		self.small_loot.diamondheist_big_diamond = 2300
		self.small_loot.mus_small_artifact = 1450
		self.small_loot.value_gold = 3000
		self.small_loot.gen_atm = 46000
		self.small_loot.special_deposit_box = 3500
		self.small_loot.slot_machine_payout = 50000
		self.small_loot.vault_loot_chest = 1150
		self.small_loot.vault_loot_diamond_chest = 1250
		self.small_loot.vault_loot_banknotes = 1000
		self.small_loot.vault_loot_silver = 1100
		self.small_loot.vault_loot_diamond_collection = 1300
		self.small_loot.vault_loot_trophy = 1400
		self.small_loot.money_wrap_single_bundle_vscaled = 775
		self.small_loot.spawn_bucket_of_money = 40000
		self.small_loot.vault_loot_gold = 5000
		self.small_loot.vault_loot_cash = 2500
		self.small_loot.vault_loot_coins = 1500
		self.small_loot.vault_loot_ring = 750
		self.small_loot.vault_loot_jewels = 1200
		self.small_loot.vault_loot_macka = 1
	elseif difficulty_index == 4 then
		self.small_loot.money_bundle = 1000
		self.small_loot.money_bundle_value = 10000
		self.small_loot.ring_band = 1954
		self.small_loot.diamondheist_vault_bust = 4500
		self.small_loot.diamondheist_vault_diamond = 5750
		self.small_loot.diamondheist_big_diamond = 5750
		self.small_loot.mus_small_artifact = 3600
		self.small_loot.value_gold = 3000
		self.small_loot.gen_atm = 115000
		self.small_loot.special_deposit_box = 3500
		self.small_loot.slot_machine_payout = 125000
		self.small_loot.vault_loot_chest = 2900
		self.small_loot.vault_loot_diamond_chest = 3100
		self.small_loot.vault_loot_banknotes = 2500
		self.small_loot.vault_loot_silver = 2700
		self.small_loot.vault_loot_diamond_collection = 3300
		self.small_loot.vault_loot_trophy = 3500
		self.small_loot.money_wrap_single_bundle_vscaled = 1950
		self.small_loot.spawn_bucket_of_money = 100000
		self.small_loot.vault_loot_gold = 11500
		self.small_loot.vault_loot_cash = 5775
		self.small_loot.vault_loot_coins = 4000
		self.small_loot.vault_loot_ring = 1750
		self.small_loot.vault_loot_jewels = 3000
		self.small_loot.vault_loot_macka = 1
	elseif difficulty_index == 5 then
		self.small_loot.money_bundle = 1000
		self.small_loot.money_bundle_value = 10000
		self.small_loot.ring_band = 1954
		self.small_loot.diamondheist_vault_bust = 9000
		self.small_loot.diamondheist_vault_diamond = 11500
		self.small_loot.diamondheist_big_diamond = 11500
		self.small_loot.mus_small_artifact = 7000
		self.small_loot.value_gold = 3000
		self.small_loot.gen_atm = 230000
		self.small_loot.special_deposit_box = 3500
		self.small_loot.slot_machine_payout = 250000
		self.small_loot.vault_loot_chest = 5800
		self.small_loot.vault_loot_diamond_chest = 6200
		self.small_loot.vault_loot_banknotes = 5000
		self.small_loot.vault_loot_silver = 5400
		self.small_loot.vault_loot_diamond_collection = 6500
		self.small_loot.vault_loot_trophy = 6900
		self.small_loot.money_wrap_single_bundle_vscaled = 3800
		self.small_loot.spawn_bucket_of_money = 200000
		self.small_loot.vault_loot_gold = 23000
		self.small_loot.vault_loot_cash = 11500
		self.small_loot.vault_loot_coins = 8000
		self.small_loot.vault_loot_ring = 3500
		self.small_loot.vault_loot_jewels = 5775
		self.small_loot.vault_loot_macka = 1
	elseif difficulty_index == 6 then
		self.small_loot.money_bundle = 1000
		self.small_loot.money_bundle_value = 10000
		self.small_loot.ring_band = 1954
		self.small_loot.diamondheist_vault_bust = 12000
		self.small_loot.diamondheist_vault_diamond = 15000
		self.small_loot.diamondheist_big_diamond = 15000
		self.small_loot.mus_small_artifact = 9500
		self.small_loot.value_gold = 3000
		self.small_loot.gen_atm = 300000
		self.small_loot.special_deposit_box = 3500
		self.small_loot.slot_machine_payout = 325000
		self.small_loot.vault_loot_chest = 7500
		self.small_loot.vault_loot_diamond_chest = 8000
		self.small_loot.vault_loot_banknotes = 6500
		self.small_loot.vault_loot_silver = 7000
		self.small_loot.vault_loot_diamond_collection = 8500
		self.small_loot.vault_loot_trophy = 9000
		self.small_loot.money_wrap_single_bundle_vscaled = 5000
		self.small_loot.spawn_bucket_of_money = 260000
		self.small_loot.vault_loot_gold = 30000
		self.small_loot.vault_loot_cash = 15000
		self.small_loot.vault_loot_coins = 10500
		self.small_loot.vault_loot_ring = 4500
		self.small_loot.vault_loot_jewels = 7500
		self.small_loot.vault_loot_macka = 1
	elseif difficulty_index == 7 then
		self.small_loot.money_bundle = 1000
		self.small_loot.money_bundle_value = 10000
		self.small_loot.ring_band = 1954
		self.small_loot.diamondheist_vault_bust = 12000
		self.small_loot.diamondheist_vault_diamond = 15000
		self.small_loot.diamondheist_big_diamond = 15000
		self.small_loot.mus_small_artifact = 9500
		self.small_loot.value_gold = 3000
		self.small_loot.gen_atm = 300000
		self.small_loot.special_deposit_box = 3500
		self.small_loot.slot_machine_payout = 325000
		self.small_loot.vault_loot_chest = 7500
		self.small_loot.vault_loot_diamond_chest = 8000
		self.small_loot.vault_loot_banknotes = 6500
		self.small_loot.vault_loot_silver = 7000
		self.small_loot.vault_loot_diamond_collection = 8500
		self.small_loot.vault_loot_trophy = 9000
		self.small_loot.money_wrap_single_bundle_vscaled = 5000
		self.small_loot.spawn_bucket_of_money = 260000
		self.small_loot.vault_loot_gold = 30000
		self.small_loot.vault_loot_cash = 15000
		self.small_loot.vault_loot_coins = 10500
		self.small_loot.vault_loot_ring = 4500
		self.small_loot.vault_loot_jewels = 7500
		self.small_loot.vault_loot_macka = 1
	else
		self.small_loot.money_bundle = 1000
		self.small_loot.money_bundle_value = 10000
		self.small_loot.ring_band = 1954
		self.small_loot.diamondheist_vault_bust = 12000
		self.small_loot.diamondheist_vault_diamond = 15000
		self.small_loot.diamondheist_big_diamond = 15000
		self.small_loot.mus_small_artifact = 9500
		self.small_loot.value_gold = 3000
		self.small_loot.gen_atm = 300000
		self.small_loot.special_deposit_box = 3500
		self.small_loot.slot_machine_payout = 325000
		self.small_loot.vault_loot_chest = 7500
		self.small_loot.vault_loot_diamond_chest = 8000
		self.small_loot.vault_loot_banknotes = 6500
		self.small_loot.vault_loot_silver = 7000
		self.small_loot.vault_loot_diamond_collection = 8500
		self.small_loot.vault_loot_trophy = 9000
		self.small_loot.money_wrap_single_bundle_vscaled = 5000
		self.small_loot.spawn_bucket_of_money = 260000
		self.small_loot.vault_loot_gold = 30000
		self.small_loot.vault_loot_cash = 15000
		self.small_loot.vault_loot_coins = 10500
		self.small_loot.vault_loot_ring = 4500
		self.small_loot.vault_loot_jewels = 7500
		self.small_loot.vault_loot_macka = 1
	end

	self.max_small_loot_value = 2800000
	self.skilltree = {respec = {}}
	self.skilltree.respec.base_cost = 200
	self.skilltree.respec.profile_cost_increaser_multiplier = {
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1
	}
	self.skilltree.respec.tier_cost = {
		1500,
		2000,
		10000,
		40000,
		100000,
		400000
	}
	self.skilltree.respec.base_point_cost = 500
	self.skilltree.respec.point_tier_cost = self._create_value_table(4000, self.biggest_cashout * 0.18, 6, true, 1.1)
	self.skilltree.respec.respec_refund_multiplier = 0.6
	self.skilltree.respec.point_cost = 0
	self.skilltree.respec.point_multiplier_cost = 1
	local loot_drop_value = 10000
	self.loot_drop_cash = {
		cash10 = loot_drop_value * 2,
		cash20 = loot_drop_value * 4,
		cash30 = loot_drop_value * 6,
		cash40 = loot_drop_value * 8,
		cash50 = loot_drop_value * 9,
		cash60 = loot_drop_value * 10,
		cash70 = loot_drop_value * 11,
		cash80 = loot_drop_value * 12,
		cash90 = loot_drop_value * 13,
		cash100 = loot_drop_value * 14,
		cash_preorder = self.biggest_cashout / 10
	}

	if SystemInfo:platform() == Idstring("XB1") then
		self.loot_drop_cash.xone_bonus = 5000000
	end

	self.unlock_new_mask_slot_value = self.biggest_cashout
	self.unlock_new_weapon_slot_value = self.biggest_cashout
end

