CharacterTweakData = CharacterTweakData or class()

function CharacterTweakData:init(tweak_data)
	self:_create_table_structure()

	self._enemy_list = {}
	self._speech_prefix_p2 = "n"

	if Global and Global.game_settings and Global.game_settings.difficulty then
		self._speech_prefix_p2 = Global.game_settings.difficulty == "sm_wish" and "d" or "n"
	end

	local func = "_init_region_" .. tostring(tweak_data.levels:get_ai_group_type())

	self[func](self)

	self._prefix_data_p1 = {
		cop = function ()
			return self._unit_prefixes.cop
		end,
		swat = function ()
			return self._unit_prefixes.swat
		end,
		heavy_swat = function ()
			return self._unit_prefixes.heavy_swat
		end,
		taser = function ()
			return self._unit_prefixes.taser
		end,
		cloaker = function ()
			return self._unit_prefixes.cloaker
		end,
		bulldozer = function ()
			return self._unit_prefixes.bulldozer
		end,
		medic = function ()
			return self._unit_prefixes.medic
		end
	}
	self.flashbang_multiplier = 1
	self.concussion_multiplier = 1
	local presets = self:_presets(tweak_data)
	self.presets = presets
	self.tweak_data = tweak_data

	self:_init_security(presets)
	self:_init_gensec(presets)
	self:_init_cop(presets)
	self:_init_inside_man(presets)
	self:_init_fbi(presets)
	self:_init_swat(presets)
	self:_init_heavy_swat(presets)
	self:_init_fbi_swat(presets)
	self:_init_fbi_heavy_swat(presets)
	self:_init_city_swat(presets)
	self:_init_sniper(presets)
	self:_init_gangster(presets)
	self:_init_biker(presets)
	self:_init_biker_escape(presets)
	self:_init_mobster(presets)
	self:_init_mobster_boss(presets)
	self:_init_hector_boss(presets)
	self:_init_hector_boss_no_armor(presets)
	self:_init_tank(presets)
	self:_init_medic(presets)
	self:_init_shadow_spooc(presets)
	self:_init_spooc(presets)
	self:_init_shield(presets)
	self:_init_phalanx_minion(presets)
	self:_init_phalanx_vip(presets)
	self:_init_taser(presets)
	self:_init_civilian(presets)
	self:_init_melee_box(presets)
	self:_init_bank_manager(presets)
	self:_init_drunk_pilot(presets)
	self:_init_boris(presets)
	self:_init_escort(presets)
	self:_init_escort_undercover(presets)
	self:_init_russian(presets)
	self:_init_german(presets)
	self:_init_spanish(presets)
	self:_init_american(presets)
	self:_init_jowi(presets)
	self:_init_old_hoxton(presets)
	self:_init_clover(presets)
	self:_init_dragan(presets)
	self:_init_jacket(presets)
	self:_init_bonnie(presets)
	self:_init_sokol(presets)
	self:_init_dragon(presets)
	self:_init_bodhi(presets)
	self:_init_jimmy(presets)
	self:_init_sydney(presets)
	self:_init_wild(presets)
	self:_init_biker_boss(presets)
	self:_init_chavez_boss(presets)
	self:_init_chico(presets)
	self:_init_max(presets)
	self:_init_joy(presets)
	self:_init_myh(presets)
	self:_init_ecp(presets)
	self:_init_bolivians(presets)
	self:_init_drug_lord_boss(presets)
	self:_init_drug_lord_boss_stealth(presets)
	self:_init_old_hoxton_mission(presets)
	self:_init_spa_vip(presets)
	self:_init_spa_vip_hurt(presets)
	self:_init_captain(presets)

	self._prefix_data = nil
	self._prefix_data_p1 = nil
	self._speech_prefix_p2 = nil

	self:_process_weapon_usage_table()
end

function CharacterTweakData:_init_region_america()
	self._default_chatter = "dispatch_generic_message"
	self._unit_prefixes = {
		cop = "l",
		swat = "l",
		heavy_swat = "l",
		taser = "tsr",
		cloaker = "clk",
		bulldozer = "bdz",
		medic = "mdc"
	}
end

function CharacterTweakData:_init_region_russia()
	self._default_chatter = "dsp_radio_russian"
	self._unit_prefixes = {
		cop = "r",
		swat = "r",
		heavy_swat = "r",
		taser = "rtsr",
		cloaker = "rclk",
		bulldozer = "rbdz",
		medic = "rmdc"
	}
end

function CharacterTweakData:_init_region_zombie()
	self._default_chatter = "dsp_radio_russian"
	self._unit_prefixes = {
		cop = "z",
		swat = "z",
		heavy_swat = "z",
		taser = "tsr",
		cloaker = "clk",
		bulldozer = "bdz",
		medic = "mdc"
	}
	self._speech_prefix_p2 = "n"
end

function CharacterTweakData:_init_region_murkywater()
	self:_init_region_america()
end

function CharacterTweakData:_init_security(presets)
	self.security = deep_clone(presets.base)
	self.security.tags = {
		"law"
	}
	self.security.experience = {}
	self.security.weapon = presets.weapon.normal
	self.security.detection = presets.detection.guard
	self.security.HEALTH_INIT = 4
	self.security.headshot_dmg_mul = 2
	self.security.headshot_dmg_mul = 2
	self.security.move_speed = presets.move_speed.normal
	self.security.crouch_move = nil
	self.security.surrender_break_time = {
		20,
		30
	}
	self.security.suppression = presets.suppression.easy
	self.security.surrender = presets.surrender.easy
	self.security.ecm_vulnerability = 1
	self.security.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.security.weapon_voice = "3"
	self.security.experience.cable_tie = "tie_swat"
	self.security.speech_prefix_p1 = "l"
	self.security.speech_prefix_p2 = "n"
	self.security.speech_prefix_count = 4
	self.security.access = "security"
	self.security.rescue_hostages = false
	self.security.use_radio = nil
	self.security.silent_priority_shout = "f37"
	self.security.dodge = presets.dodge.poor
	self.security.deathguard = false
	self.security.chatter = presets.enemy_chatter.cop
	self.security.has_alarm_pager = true
	self.security.melee_weapon = "baton"
	self.security.steal_loot = nil

	table.insert(self._enemy_list, "security")

	self.security_undominatable = deep_clone(self.security)
	self.security_undominatable.suppression = nil
	self.security_undominatable.surrender = nil

	table.insert(self._enemy_list, "security_undominatable")

	self.mute_security_undominatable = deep_clone(self.security)
	self.mute_security_undominatable.suppression = nil
	self.mute_security_undominatable.surrender = nil
	self.mute_security_undominatable.has_alarm_pager = false
	self.mute_security_undominatable.chatter = presets.enemy_chatter.no_chatter
	self.mute_security_undominatable.weapon_voice = "3"
	self.mute_security_undominatable.speech_prefix_p1 = "bb"
	self.mute_security_undominatable.speech_prefix_p2 = "n"
	self.mute_security_undominatable.speech_prefix_count = 1

	table.insert(self._enemy_list, "mute_security_undominatable")
end

function CharacterTweakData:_init_gensec(presets)
	self.gensec = deep_clone(presets.base)
	self.gensec.tags = {
		"law"
	}
	self.gensec.experience = {}
	self.gensec.weapon = presets.weapon.normal
	self.gensec.detection = presets.detection.guard
	self.gensec.HEALTH_INIT = 4
	self.gensec.headshot_dmg_mul = 2
	self.gensec.move_speed = presets.move_speed.normal
	self.gensec.crouch_move = nil
	self.gensec.surrender_break_time = {
		20,
		30
	}
	self.gensec.suppression = presets.suppression.hard
	self.gensec.surrender = presets.surrender.easy
	self.gensec.ecm_vulnerability = 1
	self.gensec.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.gensec.weapon_voice = "3"
	self.gensec.experience.cable_tie = "tie_swat"
	self.gensec.speech_prefix_p1 = "l"
	self.gensec.speech_prefix_p2 = "n"
	self.gensec.speech_prefix_count = 4
	self.gensec.access = "security"
	self.gensec.rescue_hostages = false
	self.gensec.use_radio = nil
	self.gensec.silent_priority_shout = "f37"
	self.gensec.dodge = presets.dodge.athletic
	self.gensec.deathguard = false
	self.gensec.chatter = presets.enemy_chatter.cop
	self.gensec.has_alarm_pager = true
	self.gensec.melee_weapon = "baton"
	self.gensec.steal_loot = nil

	table.insert(self._enemy_list, "gensec")
end

function CharacterTweakData:_init_cop(presets)
	self.cop = deep_clone(presets.base)
	self.cop.tags = {
		"law"
	}
	self.cop.experience = {}
	self.cop.weapon = presets.weapon.normal
	self.cop.detection = presets.detection.normal
	self.cop.HEALTH_INIT = 4
	self.cop.headshot_dmg_mul = 2
	self.cop.move_speed = presets.move_speed.normal
	self.cop.surrender_break_time = {
		10,
		15
	}
	self.cop.suppression = presets.suppression.easy
	self.cop.surrender = presets.surrender.easy
	self.cop.ecm_vulnerability = 1
	self.cop.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.cop.weapon_voice = "1"
	self.cop.experience.cable_tie = "tie_swat"
	self.cop.speech_prefix_p1 = self._prefix_data_p1.swat()
	self.cop.speech_prefix_p2 = "n"
	self.cop.speech_prefix_count = 4
	self.cop.access = "cop"
	self.cop.silent_priority_shout = "f37"
	self.cop.dodge = presets.dodge.average
	self.cop.deathguard = true
	self.cop.chatter = presets.enemy_chatter.cop
	self.cop.melee_weapon = "baton"
	self.cop.steal_loot = true

	table.insert(self._enemy_list, "cop")

	self.cop_scared = deep_clone(self.cop)
	self.cop_scared.surrender = presets.surrender.always
	self.cop_scared.surrender_break_time = nil

	table.insert(self._enemy_list, "cop_scared")

	self.cop_female = deep_clone(self.cop)
	self.cop_female.speech_prefix_p1 = "fl"
	self.cop_female.speech_prefix_p2 = "n"
	self.cop_female.speech_prefix_count = 1

	table.insert(self._enemy_list, "cop_female")
end

function CharacterTweakData:_init_fbi(presets)
	self.fbi = deep_clone(presets.base)
	self.fbi.tags = {
		"law"
	}
	self.fbi.experience = {}
	self.fbi.weapon = presets.weapon.normal
	self.fbi.detection = presets.detection.normal
	self.fbi.HEALTH_INIT = 8
	self.fbi.headshot_dmg_mul = 2
	self.fbi.move_speed = presets.move_speed.very_fast
	self.fbi.surrender_break_time = {
		7,
		12
	}
	self.fbi.suppression = presets.suppression.hard_def
	self.fbi.surrender = presets.surrender.easy
	self.fbi.ecm_vulnerability = 1
	self.fbi.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.fbi.weapon_voice = "2"
	self.fbi.experience.cable_tie = "tie_swat"
	self.fbi.speech_prefix_p1 = "l"
	self.fbi.speech_prefix_p2 = "n"
	self.fbi.speech_prefix_count = 4
	self.fbi.silent_priority_shout = "f37"
	self.fbi.access = "fbi"
	self.fbi.dodge = presets.dodge.athletic
	self.fbi.deathguard = true
	self.fbi.no_arrest = true
	self.fbi.chatter = presets.enemy_chatter.cop
	self.fbi.steal_loot = true

	table.insert(self._enemy_list, "fbi")
end

function CharacterTweakData:_init_medic(presets)
	self.medic = deep_clone(presets.base)
	self.medic.tags = {
		"law",
		"medic",
		"special"
	}
	self.medic.experience = {}
	self.medic.weapon = presets.weapon.normal
	self.medic.detection = presets.detection.normal
	self.medic.HEALTH_INIT = 30
	self.medic.headshot_dmg_mul = 2
	self.medic.damage.hurt_severity = presets.hurt_severities.no_hurts
	self.medic.suppression = presets.suppression.no_supress
	self.medic.surrender = presets.surrender.special
	self.medic.move_speed = presets.move_speed.very_fast
	self.medic.surrender_break_time = {
		7,
		12
	}
	self.medic.ecm_vulnerability = 1
	self.medic.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.medic.weapon_voice = "2"
	self.medic.experience.cable_tie = "tie_swat"
	self.medic.speech_prefix_p1 = self._prefix_data_p1.medic()
	self.medic.speech_prefix_count = nil
	self.medic.spawn_sound_event = self._prefix_data_p1.medic() .. "_entrance"
	self.medic.silent_priority_shout = "f37"
	self.medic.access = "swat"
	self.medic.dodge = presets.dodge.athletic
	self.medic.deathguard = true
	self.medic.no_arrest = true
	self.medic.chatter = {
		contact = true,
		aggressive = true
	}
	self.medic.steal_loot = false
	self.medic.priority_shout = "f47"
	self.medic.priority_shout_max_dis = 700
	self.medic.die_sound_event = "mdc_x02a_any_3p"

	table.insert(self._enemy_list, "medic")
end

function CharacterTweakData:_init_swat(presets)
	self.swat = deep_clone(presets.base)
	self.swat.tags = {
		"law"
	}
	self.swat.experience = {}
	self.swat.weapon = presets.weapon.normal
	self.swat.detection = presets.detection.normal
	self.swat.HEALTH_INIT = 8
	self.swat.headshot_dmg_mul = 2
	self.swat.move_speed = presets.move_speed.fast
	self.swat.surrender_break_time = {
		6,
		10
	}
	self.swat.suppression = presets.suppression.hard_agg
	self.swat.surrender = presets.surrender.easy
	self.swat.ecm_vulnerability = 1
	self.swat.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.swat.weapon_voice = "2"
	self.swat.experience.cable_tie = "tie_swat"
	self.swat.speech_prefix_p1 = self._prefix_data_p1.swat()
	self.swat.speech_prefix_p2 = self._speech_prefix_p2
	self.swat.speech_prefix_count = 4
	self.swat.access = "swat"
	self.swat.dodge = presets.dodge.athletic
	self.swat.no_arrest = true
	self.swat.chatter = presets.enemy_chatter.swat
	self.swat.melee_weapon = "knife_1"
	self.swat.melee_weapon_dmg_multiplier = 1
	self.swat.steal_loot = true

	table.insert(self._enemy_list, "swat")
end

function CharacterTweakData:_init_heavy_swat(presets)
	self.heavy_swat = deep_clone(presets.base)
	self.heavy_swat.tags = {
		"law"
	}
	self.heavy_swat.experience = {}
	self.heavy_swat.weapon = presets.weapon.normal
	self.heavy_swat.detection = presets.detection.normal
	self.heavy_swat.HEALTH_INIT = 16
	self.heavy_swat.headshot_dmg_mul = 2
	self.heavy_swat.damage.explosion_damage_mul = 1
	self.heavy_swat.move_speed = presets.move_speed.fast
	self.heavy_swat.surrender_break_time = {
		6,
		8
	}
	self.heavy_swat.suppression = presets.suppression.hard_agg
	self.heavy_swat.surrender = presets.surrender.easy
	self.heavy_swat.ecm_vulnerability = 1
	self.heavy_swat.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.heavy_swat.weapon_voice = "2"
	self.heavy_swat.experience.cable_tie = "tie_swat"
	self.heavy_swat.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.heavy_swat.speech_prefix_p2 = self._speech_prefix_p2
	self.heavy_swat.speech_prefix_count = 4
	self.heavy_swat.access = "swat"
	self.heavy_swat.dodge = presets.dodge.heavy
	self.heavy_swat.no_arrest = true
	self.heavy_swat.chatter = presets.enemy_chatter.swat
	self.heavy_swat.steal_loot = true
	self.heavy_swat_sniper = deep_clone(self.heavy_swat)
	self.heavy_swat_sniper.weapon = presets.weapon.sniper

	table.insert(self._enemy_list, "heavy_swat")
	table.insert(self._enemy_list, "heavy_swat_sniper")
end

function CharacterTweakData:_init_fbi_swat(presets)
	self.fbi_swat = deep_clone(presets.base)
	self.fbi_swat.tags = {
		"law"
	}
	self.fbi_swat.experience = {}
	self.fbi_swat.weapon = presets.weapon.good
	self.fbi_swat.detection = presets.detection.normal
	self.fbi_swat.HEALTH_INIT = 8
	self.fbi_swat.headshot_dmg_mul = self.fbi_swat.HEALTH_INIT / 4
	self.fbi_swat.move_speed = presets.move_speed.very_fast
	self.fbi_swat.surrender_break_time = {
		6,
		10
	}
	self.fbi_swat.suppression = presets.suppression.hard_def
	self.fbi_swat.surrender = presets.surrender.easy
	self.fbi_swat.ecm_vulnerability = 1
	self.fbi_swat.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.fbi_swat.weapon_voice = "2"
	self.fbi_swat.experience.cable_tie = "tie_swat"
	self.fbi_swat.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.fbi_swat.speech_prefix_p2 = self._speech_prefix_p2
	self.fbi_swat.speech_prefix_count = 4
	self.fbi_swat.access = "swat"
	self.fbi_swat.dodge = presets.dodge.athletic
	self.fbi_swat.no_arrest = true
	self.fbi_swat.chatter = presets.enemy_chatter.swat
	self.fbi_swat.melee_weapon = "knife_1"
	self.fbi_swat.steal_loot = true

	table.insert(self._enemy_list, "fbi_swat")
end

function CharacterTweakData:_init_fbi_heavy_swat(presets)
	self.fbi_heavy_swat = deep_clone(presets.base)
	self.fbi_heavy_swat.tags = {
		"law"
	}
	self.fbi_heavy_swat.experience = {}
	self.fbi_heavy_swat.weapon = presets.weapon.good
	self.fbi_heavy_swat.detection = presets.detection.normal
	self.fbi_heavy_swat.HEALTH_INIT = 16
	self.fbi_heavy_swat.headshot_dmg_mul = 2
	self.fbi_heavy_swat.damage.explosion_damage_mul = 0.9
	self.fbi_heavy_swat.move_speed = presets.move_speed.fast
	self.fbi_heavy_swat.surrender_break_time = {
		6,
		8
	}
	self.fbi_heavy_swat.suppression = presets.suppression.hard_agg
	self.fbi_heavy_swat.surrender = presets.surrender.easy
	self.fbi_heavy_swat.ecm_vulnerability = 1
	self.fbi_heavy_swat.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.fbi_heavy_swat.weapon_voice = "2"
	self.fbi_heavy_swat.experience.cable_tie = "tie_swat"
	self.fbi_heavy_swat.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.fbi_heavy_swat.speech_prefix_p2 = self._speech_prefix_p2
	self.fbi_heavy_swat.speech_prefix_count = 4
	self.fbi_heavy_swat.access = "swat"
	self.fbi_heavy_swat.dodge = presets.dodge.heavy
	self.fbi_heavy_swat.no_arrest = true
	self.fbi_heavy_swat.chatter = presets.enemy_chatter.swat
	self.fbi_heavy_swat.steal_loot = true

	table.insert(self._enemy_list, "fbi_heavy_swat")
end

function CharacterTweakData:_init_city_swat(presets)
	self.city_swat = deep_clone(presets.base)
	self.city_swat.tags = {
		"law"
	}
	self.city_swat.experience = {}
	self.city_swat.weapon = presets.weapon.good
	self.city_swat.detection = presets.detection.normal
	self.city_swat.HEALTH_INIT = 8
	self.city_swat.headshot_dmg_mul = 2
	self.city_swat.move_speed = presets.move_speed.very_fast
	self.city_swat.surrender_break_time = {
		6,
		10
	}
	self.city_swat.suppression = presets.suppression.hard_def
	self.city_swat.surrender = presets.surrender.easy
	self.city_swat.ecm_vulnerability = 1
	self.city_swat.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.city_swat.weapon_voice = "2"
	self.city_swat.experience.cable_tie = "tie_swat"
	self.city_swat.silent_priority_shout = "f37"
	self.city_swat.speech_prefix_p1 = self._prefix_data_p1.heavy_swat()
	self.city_swat.speech_prefix_p2 = self._speech_prefix_p2
	self.city_swat.speech_prefix_count = 4
	self.city_swat.access = "swat"
	self.city_swat.dodge = presets.dodge.athletic
	self.city_swat.chatter = presets.enemy_chatter.swat
	self.city_swat.melee_weapon = "knife_1"
	self.city_swat.steal_loot = true
	self.city_swat.has_alarm_pager = true

	table.insert(self._enemy_list, "city_swat")
end

function CharacterTweakData:_init_sniper(presets)
	self.sniper = deep_clone(presets.base)
	self.sniper.tags = {
		"law",
		"sniper",
		"special"
	}
	self.sniper.experience = {}
	self.sniper.weapon = presets.weapon.sniper
	self.sniper.detection = presets.detection.sniper
	self.sniper.HEALTH_INIT = 4
	self.sniper.headshot_dmg_mul = 2
	self.sniper.move_speed = presets.move_speed.normal
	self.sniper.shooting_death = false
	self.sniper.no_move_and_shoot = true
	self.sniper.move_and_shoot_cooldown = 1
	self.sniper.suppression = presets.suppression.easy
	self.sniper.ecm_vulnerability = 1
	self.sniper.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.sniper.weapon_voice = "1"
	self.sniper.experience.cable_tie = "tie_swat"
	self.sniper.speech_prefix_p1 = "l"
	self.sniper.speech_prefix_p2 = "n"
	self.sniper.speech_prefix_count = 4
	self.sniper.priority_shout = "f34"
	self.sniper.access = "sniper"
	self.sniper.no_retreat = true
	self.sniper.no_arrest = true
	self.sniper.chatter = presets.enemy_chatter.no_chatter
	self.sniper.steal_loot = nil
	self.sniper.rescue_hostages = false

	table.insert(self._enemy_list, "sniper")
end

function CharacterTweakData:_init_gangster(presets)
	self.gangster = deep_clone(presets.base)
	self.gangster.experience = {}
	self.gangster.weapon = presets.weapon.good
	self.gangster.detection = presets.detection.normal
	self.gangster.HEALTH_INIT = 8
	self.gangster.headshot_dmg_mul = 2
	self.gangster.move_speed = presets.move_speed.fast
	self.gangster.suspicious = nil
	self.gangster.suppression = presets.suppression.easy
	self.gangster.surrender = nil
	self.gangster.ecm_vulnerability = 1
	self.gangster.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.gangster.no_arrest = true
	self.gangster.no_retreat = true
	self.gangster.weapon_voice = "3"
	self.gangster.experience.cable_tie = "tie_swat"
	self.gangster.speech_prefix_p1 = "l"
	self.gangster.speech_prefix_p2 = "n"
	self.gangster.speech_prefix_count = 4
	self.gangster.silent_priority_shout = "f37"
	self.gangster.access = "gangster"
	self.gangster.rescue_hostages = false
	self.gangster.use_radio = nil
	self.gangster.dodge = presets.dodge.average
	self.gangster.challenges = {
		type = "gangster"
	}
	self.gangster.chatter = presets.enemy_chatter.no_chatter
	self.gangster.melee_weapon = "fists"
	self.gangster.steal_loot = nil

	table.insert(self._enemy_list, "gangster")
end

function CharacterTweakData:_init_biker(presets)
	self.biker = deep_clone(self.gangster)
	self.biker.calls_in = true

	table.insert(self._enemy_list, "biker")
end

function CharacterTweakData:_init_captain(presets)
	self.captain = deep_clone(self.gangster)
	self.captain.calls_in = true
	self.captain.immune_to_knock_down = true
	self.captain.immune_to_concussion = true
	self.captain.no_retreat = true
	self.captain.no_arrest = true
	self.captain.surrender = nil
	self.captain.damage.hurt_severity = presets.hurt_severities.no_hurts
	self.captain.flammable = false
	self.captain.can_be_tased = false
	self.captain.suppression = nil

	table.insert(self._enemy_list, "biker")
end

function CharacterTweakData:_init_biker_escape(presets)
	self.biker_escape = deep_clone(self.gangster)
	self.biker_escape.melee_weapon = "knife_1"
	self.biker_escape.move_speed = presets.move_speed.very_fast
	self.biker_escape.HEALTH_INIT = 8
	self.biker_escape.suppression = nil

	table.insert(self._enemy_list, "biker_escape")
end

function CharacterTweakData:_init_mobster(presets)
	self.mobster = deep_clone(self.gangster)
	self.mobster.calls_in = nil

	table.insert(self._enemy_list, "mobster")
end

function CharacterTweakData:_init_mobster_boss(presets)
	self.mobster_boss = deep_clone(presets.base)
	self.mobster_boss.experience = {}
	self.mobster_boss.weapon = deep_clone(presets.weapon.good)
	self.mobster_boss.weapon.is_rifle = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			30
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	self.mobster_boss.detection = presets.detection.normal
	self.mobster_boss.HEALTH_INIT = 350
	self.mobster_boss.headshot_dmg_mul = 2
	self.mobster_boss.damage.explosion_damage_mul = 1
	self.mobster_boss.damage.hurt_severity = presets.hurt_severities.base_no_poison
	self.mobster_boss.move_speed = presets.move_speed.very_slow
	self.mobster_boss.allowed_poses = {
		stand = true
	}
	self.mobster_boss.no_retreat = true
	self.mobster_boss.no_arrest = true
	self.mobster_boss.surrender = nil
	self.mobster_boss.ecm_vulnerability = 0.85
	self.mobster_boss.ecm_hurts = {
		ears = {
			max_duration = 9,
			min_duration = 7
		}
	}
	self.mobster_boss.weapon_voice = "3"
	self.mobster_boss.experience.cable_tie = "tie_swat"
	self.mobster_boss.access = "gangster"
	self.mobster_boss.speech_prefix_p1 = "l"
	self.mobster_boss.speech_prefix_p2 = "n"
	self.mobster_boss.speech_prefix_count = 4
	self.mobster_boss.rescue_hostages = false
	self.mobster_boss.melee_weapon = "fists"
	self.mobster_boss.melee_weapon_dmg_multiplier = 2.5
	self.mobster_boss.steal_loot = nil
	self.mobster_boss.calls_in = nil
	self.mobster_boss.chatter = presets.enemy_chatter.no_chatter
	self.mobster_boss.use_radio = nil
	self.mobster_boss.can_be_tased = false
	self.mobster_boss.immune_to_concussion = true

	table.insert(self._enemy_list, "mobster_boss")
end

function CharacterTweakData:_init_biker_boss(presets)
	self.biker_boss = deep_clone(presets.base)
	self.biker_boss.experience = {}
	self.biker_boss.weapon = deep_clone(presets.weapon.good)
	self.biker_boss.weapon.is_rifle = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			30
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	self.biker_boss.detection = presets.detection.normal
	self.biker_boss.HEALTH_INIT = 350
	self.biker_boss.headshot_dmg_mul = 2
	self.biker_boss.damage.explosion_damage_mul = 1
	self.biker_boss.damage.hurt_severity = presets.hurt_severities.no_hurts
	self.biker_boss.move_speed = presets.move_speed.very_slow
	self.biker_boss.allowed_poses = {
		stand = true
	}
	self.biker_boss.no_retreat = true
	self.biker_boss.no_arrest = true
	self.biker_boss.surrender = nil
	self.biker_boss.ecm_vulnerability = 0
	self.biker_boss.ecm_hurts = {
		ears = {
			max_duration = 0,
			min_duration = 0
		}
	}
	self.biker_boss.weapon_voice = "3"
	self.biker_boss.experience.cable_tie = "tie_swat"
	self.biker_boss.access = "gangster"
	self.biker_boss.speech_prefix_p1 = "bb"
	self.biker_boss.speech_prefix_p2 = "n"
	self.biker_boss.speech_prefix_count = 1
	self.biker_boss.rescue_hostages = false
	self.biker_boss.melee_weapon = "fists"
	self.biker_boss.melee_weapon_dmg_multiplier = 2.5
	self.biker_boss.steal_loot = nil
	self.biker_boss.calls_in = nil
	self.biker_boss.chatter = presets.enemy_chatter.no_chatter
	self.biker_boss.use_radio = nil
	self.biker_boss.can_be_tased = false
	self.biker_boss.DAMAGE_CLAMP_BULLET = 80
	self.biker_boss.DAMAGE_CLAMP_EXPLOSION = 80
	self.biker_boss.use_animation_on_fire_damage = false
	self.biker_boss.flammable = true
	self.biker_boss.can_be_tased = false
	self.biker_boss.immune_to_knock_down = true
	self.biker_boss.immune_to_concussion = true

	table.insert(self._enemy_list, "biker_boss")
end

function CharacterTweakData:_init_chavez_boss(presets)
	self.chavez_boss = deep_clone(presets.base)
	self.chavez_boss.experience = {}
	self.chavez_boss.weapon = deep_clone(presets.weapon.good)
	self.chavez_boss.weapon.akimbo_pistol = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			30
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	self.chavez_boss.detection = presets.detection.normal
	self.chavez_boss.HEALTH_INIT = 550
	self.chavez_boss.headshot_dmg_mul = 2
	self.chavez_boss.damage.explosion_damage_mul = 1
	self.chavez_boss.move_speed = presets.move_speed.fast
	self.chavez_boss.allowed_poses = {
		stand = true
	}
	self.chavez_boss.no_retreat = true
	self.chavez_boss.no_arrest = true
	self.chavez_boss.surrender = nil
	self.chavez_boss.ecm_vulnerability = 0
	self.chavez_boss.ecm_hurts = {
		ears = {
			max_duration = 0,
			min_duration = 0
		}
	}
	self.chavez_boss.weapon_voice = "1"
	self.chavez_boss.experience.cable_tie = "tie_swat"
	self.chavez_boss.access = "gangster"
	self.chavez_boss.speech_prefix_p1 = "bb"
	self.chavez_boss.speech_prefix_p2 = "n"
	self.chavez_boss.speech_prefix_count = 1
	self.chavez_boss.rescue_hostages = false
	self.chavez_boss.melee_weapon = "fists"
	self.chavez_boss.melee_weapon_dmg_multiplier = 2.5
	self.chavez_boss.steal_loot = nil
	self.chavez_boss.calls_in = nil
	self.chavez_boss.chatter = presets.enemy_chatter.no_chatter
	self.chavez_boss.use_radio = nil
	self.chavez_boss.can_be_tased = false
	self.chavez_boss.DAMAGE_CLAMP_BULLET = 80
	self.chavez_boss.DAMAGE_CLAMP_EXPLOSION = 80
	self.chavez_boss.use_animation_on_fire_damage = false
	self.chavez_boss.flammable = true
	self.chavez_boss.can_be_tased = false
	self.chavez_boss.immune_to_knock_down = true
	self.chavez_boss.immune_to_concussion = true

	table.insert(self._enemy_list, "chavez_boss")
end

function CharacterTweakData:_init_hector_boss(presets)
	self.hector_boss = deep_clone(self.mobster_boss)
	self.hector_boss.DAMAGE_CLAMP_BULLET = 320
	self.hector_boss.DAMAGE_CLAMP_EXPLOSION = 550
	self.hector_boss.melee_weapon_dmg_multiplier = 2.5
	self.hector_boss.HEALTH_INIT = 900
	self.hector_boss.weapon.is_shotgun_mag = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 4,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		autofire_rounds = presets.weapon.deathwish.is_rifle.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 2.2,
				r = 200,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					1
				}
			},
			{
				dmg_mul = 1.75,
				r = 500,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.4,
					0.8
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 1.25,
				r = 2000,
				acc = {
					0.4,
					0.55
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					3,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					3,
					1,
					1,
					0
				}
			}
		}
	}
	self.hector_boss.can_be_tased = false

	table.insert(self._enemy_list, "hector_boss")
end

function CharacterTweakData:_init_hector_boss_no_armor(presets)
	self.hector_boss_no_armor = deep_clone(self.fbi)
	self.hector_boss_no_armor.damage.hurt_severity = presets.hurt_severities.base_no_poison
	self.hector_boss_no_armor.no_retreat = true
	self.hector_boss_no_armor.no_arrest = true
	self.hector_boss_no_armor.surrender = nil
	self.hector_boss_no_armor.access = "gangster"
	self.hector_boss_no_armor.rescue_hostages = false
	self.hector_boss_no_armor.steal_loot = nil
	self.hector_boss_no_armor.calls_in = nil
	self.hector_boss_no_armor.chatter = presets.enemy_chatter.no_chatter
	self.hector_boss_no_armor.use_radio = nil
	self.hector_boss_no_armor.can_be_tased = false
	self.hector_boss_no_armor.immune_to_concussion = true

	table.insert(self._enemy_list, "hector_boss_no_armor")
end

function CharacterTweakData:_init_bolivians(presets)
	self.bolivian = deep_clone(self.gangster)
	self.bolivian.detection = presets.detection.guard
	self.bolivian.access = "security"
	self.bolivian.radio_prefix = "fri_"
	self.bolivian.suspicious = true
	self.bolivian.weapon.is_pistol.range = {
		optimal = 900,
		far = 3000,
		close = 500
	}
	self.bolivian.crouch_move = nil
	self.bolivian.no_arrest = false

	table.insert(self._enemy_list, "bolivian")

	self.bolivian_indoors = deep_clone(self.bolivian)
	self.bolivian_indoors.has_alarm_pager = true

	table.insert(self._enemy_list, "bolivian_indoors")

	self.bolivian_indoors_mex = deep_clone(self.bolivian)
	self.bolivian_indoors_mex.has_alarm_pager = true
	self.bolivian_indoors_mex.access = "gangster"

	table.insert(self._enemy_list, "bolivian_indoors_mex")
end

function CharacterTweakData:_init_drug_lord_boss(presets)
	self.drug_lord_boss = deep_clone(presets.base)
	self.drug_lord_boss.experience = {}
	self.drug_lord_boss.weapon = deep_clone(presets.weapon.good)
	self.drug_lord_boss.weapon.is_rifle = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			30
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	self.drug_lord_boss.detection = presets.detection.normal
	self.drug_lord_boss.HEALTH_INIT = 350
	self.drug_lord_boss.headshot_dmg_mul = 2
	self.drug_lord_boss.damage.explosion_damage_mul = 1
	self.drug_lord_boss.move_speed = presets.move_speed.normal
	self.drug_lord_boss.allowed_poses = {
		stand = true
	}
	self.drug_lord_boss.no_retreat = true
	self.drug_lord_boss.no_arrest = true
	self.drug_lord_boss.surrender = nil
	self.drug_lord_boss.ecm_vulnerability = 0
	self.drug_lord_boss.ecm_hurts = {
		ears = {
			max_duration = 0,
			min_duration = 0
		}
	}
	self.drug_lord_boss.weapon_voice = "3"
	self.drug_lord_boss.experience.cable_tie = "tie_swat"
	self.drug_lord_boss.access = "gangster"
	self.drug_lord_boss.speech_prefix_p1 = "bb"
	self.drug_lord_boss.speech_prefix_p2 = "n"
	self.drug_lord_boss.speech_prefix_count = 1
	self.drug_lord_boss.rescue_hostages = false
	self.drug_lord_boss.silent_priority_shout = "f37"
	self.drug_lord_boss.melee_weapon = "fists"
	self.drug_lord_boss.melee_weapon_dmg_multiplier = 2.5
	self.drug_lord_boss.steal_loot = nil
	self.drug_lord_boss.calls_in = nil
	self.drug_lord_boss.chatter = presets.enemy_chatter.no_chatter
	self.drug_lord_boss.use_radio = nil
	self.drug_lord_boss.can_be_tased = false
	self.drug_lord_boss.DAMAGE_CLAMP_BULLET = 80
	self.drug_lord_boss.DAMAGE_CLAMP_EXPLOSION = 80
	self.drug_lord_boss.use_animation_on_fire_damage = false
	self.drug_lord_boss.flammable = true
	self.drug_lord_boss.can_be_tased = false
	self.drug_lord_boss.immune_to_knock_down = true
	self.drug_lord_boss.immune_to_concussion = true

	table.insert(self._enemy_list, "drug_lord_boss")
end

function CharacterTweakData:_init_drug_lord_boss_stealth(presets)
	self.drug_lord_boss_stealth = deep_clone(presets.base)
	self.drug_lord_boss_stealth.experience = {}
	self.drug_lord_boss_stealth.weapon = deep_clone(presets.weapon.good)
	self.drug_lord_boss_stealth.weapon.is_rifle = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			30
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	self.drug_lord_boss_stealth.detection = presets.detection.normal
	self.drug_lord_boss_stealth.HEALTH_INIT = 50
	self.drug_lord_boss_stealth.headshot_dmg_mul = 2
	self.drug_lord_boss_stealth.damage.explosion_damage_mul = 1
	self.drug_lord_boss_stealth.move_speed = presets.move_speed.normal
	self.drug_lord_boss_stealth.allowed_poses = {
		stand = true
	}
	self.drug_lord_boss_stealth.no_retreat = true
	self.drug_lord_boss_stealth.no_arrest = true
	self.drug_lord_boss_stealth.surrender = nil
	self.drug_lord_boss_stealth.ecm_vulnerability = 0
	self.drug_lord_boss_stealth.ecm_hurts = {
		ears = {
			max_duration = 0,
			min_duration = 0
		}
	}
	self.drug_lord_boss_stealth.weapon_voice = "3"
	self.drug_lord_boss_stealth.experience.cable_tie = "tie_swat"
	self.drug_lord_boss_stealth.access = "gangster"
	self.drug_lord_boss_stealth.speech_prefix_p1 = "bb"
	self.drug_lord_boss_stealth.speech_prefix_p2 = "n"
	self.drug_lord_boss_stealth.speech_prefix_count = 1
	self.drug_lord_boss_stealth.rescue_hostages = false
	self.drug_lord_boss_stealth.silent_priority_shout = "f37"
	self.drug_lord_boss_stealth.melee_weapon = "fists"
	self.drug_lord_boss_stealth.melee_weapon_dmg_multiplier = 2.5
	self.drug_lord_boss_stealth.steal_loot = nil
	self.drug_lord_boss_stealth.calls_in = nil
	self.drug_lord_boss_stealth.chatter = presets.enemy_chatter.no_chatter
	self.drug_lord_boss_stealth.use_radio = nil
	self.drug_lord_boss_stealth.can_be_tased = false
	self.drug_lord_boss_stealth.DAMAGE_CLAMP_BULLET = 80
	self.drug_lord_boss_stealth.DAMAGE_CLAMP_EXPLOSION = 80
	self.drug_lord_boss_stealth.use_animation_on_fire_damage = false
	self.drug_lord_boss_stealth.flammable = true
	self.drug_lord_boss_stealth.can_be_tased = false
	self.drug_lord_boss_stealth.immune_to_knock_down = true
	self.drug_lord_boss_stealth.immune_to_concussion = true

	table.insert(self._enemy_list, "drug_lord_boss_stealth")
end

function CharacterTweakData:_init_tank(presets)
	self.tank = deep_clone(presets.base)
	self.tank.tags = {
		"law",
		"tank",
		"special"
	}
	self.tank.experience = {}
	self.tank.damage.tased_response = {
		light = {
			down_time = 0,
			tased_time = 1
		},
		heavy = {
			down_time = 0,
			tased_time = 2
		}
	}
	self.tank.weapon = deep_clone(presets.weapon.good)
	self.tank.weapon.is_shotgun_pump.FALLOFF[1].dmg_mul = 6.5
	self.tank.weapon.is_shotgun_pump.FALLOFF[2].dmg_mul = 4.5
	self.tank.weapon.is_shotgun_pump.FALLOFF[3].dmg_mul = 2
	self.tank.weapon.is_shotgun_pump.RELOAD_SPEED = 1
	self.tank.weapon.is_shotgun_mag = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 4,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		autofire_rounds = presets.weapon.deathwish.is_rifle.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 2,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1.75,
				r = 500,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.4,
					0.8
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 1.25,
				r = 2000,
				acc = {
					0.4,
					0.55
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					3,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					3,
					1,
					1,
					0
				}
			}
		}
	}
	self.tank.weapon.is_rifle = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 800,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			40
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	self.tank.detection = presets.detection.normal
	self.tank.HEALTH_INIT = 200
	self.tank.headshot_dmg_mul = 5
	self.tank.damage.explosion_damage_mul = 1.1
	self.tank.move_speed = presets.move_speed.slow
	self.tank.allowed_stances = {
		cbt = true
	}
	self.tank.allowed_poses = {
		stand = true
	}
	self.tank.crouch_move = false
	self.tank.no_run_start = true
	self.tank.no_run_stop = true
	self.tank.no_retreat = true
	self.tank.no_arrest = true
	self.tank.surrender = nil
	self.tank.ecm_vulnerability = 0.85
	self.tank.ecm_hurts = {
		ears = {
			max_duration = 3,
			min_duration = 1
		}
	}
	self.tank.weapon_voice = "3"
	self.tank.experience.cable_tie = "tie_swat"
	self.tank.access = "tank"
	self.tank.speech_prefix_p1 = self._prefix_data_p1.bulldozer()
	self.tank.speech_prefix_p2 = nil
	self.tank.speech_prefix_count = nil
	self.tank.priority_shout = "f30"
	self.tank.rescue_hostages = false
	self.tank.deathguard = true
	self.tank.melee_weapon = "fists"
	self.tank.melee_weapon_dmg_multiplier = 2.5
	self.tank.melee_anims = {
		"cbt_std_melee"
	}
	self.tank.critical_hits = {
		damage_mul = self.tank.headshot_dmg_mul * 1
	}
	self.tank.die_sound_event = "bdz_x02a_any_3p"
	self.tank.damage.hurt_severity = presets.hurt_severities.no_hurts
	self.tank.chatter = {
		retreat = true,
		aggressive = true,
		contact = true
	}
	self.tank.announce_incomming = "incomming_tank"
	self.tank.steal_loot = nil
	self.tank.calls_in = nil
	self.tank.use_animation_on_fire_damage = false
	self.tank.flammable = true
	self.tank.can_be_tased = false
	self.tank.immune_to_knock_down = true
	self.tank.immune_to_concussion = true
	self.tank_hw = deep_clone(self.tank)
	self.tank_hw.move_speed = {
		stand = {
			walk = {
				ntl = {
					strafe = 60,
					fwd = 72,
					bwd = 56
				},
				hos = {
					strafe = 60,
					fwd = 72,
					bwd = 56
				},
				cbt = {
					strafe = 60,
					fwd = 72,
					bwd = 56
				}
			},
			run = {
				hos = {
					strafe = 70,
					fwd = 72,
					bwd = 56
				},
				cbt = {
					strafe = 50,
					fwd = 72,
					bwd = 60
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 60,
					fwd = 72,
					bwd = 56
				},
				cbt = {
					strafe = 60,
					fwd = 72,
					bwd = 56
				}
			},
			run = {
				hos = {
					strafe = 65,
					fwd = 72,
					bwd = 56
				},
				cbt = {
					strafe = 50,
					fwd = 72,
					bwd = 60
				}
			}
		}
	}
	self.tank_hw.HEALTH_INIT = 200
	self.tank_hw.headshot_dmg_mul = 1
	self.tank_hw.ignore_headshot = true
	self.tank_hw.damage.explosion_damage_mul = 1
	self.tank_hw.use_animation_on_fire_damage = false
	self.tank_hw.flammable = true
	self.tank_hw.can_be_tased = false
	self.tank_medic = deep_clone(self.tank)

	table.insert(self.tank_medic.tags, "medic")

	self.tank_mini = deep_clone(self.tank)
	self.tank_mini.weapon.mini = {}
	self.tank_mini.move_speed = {
		stand = {
			walk = {
				ntl = {
					strafe = 60,
					fwd = 72,
					bwd = 56
				},
				hos = {
					strafe = 60,
					fwd = 72,
					bwd = 56
				},
				cbt = {
					strafe = 60,
					fwd = 72,
					bwd = 56
				}
			},
			run = {
				hos = {
					strafe = 70,
					fwd = 72,
					bwd = 56
				},
				cbt = {
					strafe = 50,
					fwd = 72,
					bwd = 60
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 60,
					fwd = 72,
					bwd = 56
				},
				cbt = {
					strafe = 60,
					fwd = 72,
					bwd = 56
				}
			},
			run = {
				hos = {
					strafe = 65,
					fwd = 72,
					bwd = 56
				},
				cbt = {
					strafe = 50,
					fwd = 72,
					bwd = 60
				}
			}
		}
	}
	self.tank_mini.weapon.mini.aim_delay = {
		0.1,
		0.2
	}
	self.tank_mini.weapon.mini.focus_delay = 4
	self.tank_mini.weapon.mini.focus_dis = 800
	self.tank_mini.weapon.mini.spread = 20
	self.tank_mini.weapon.mini.miss_dis = 40
	self.tank_mini.weapon.mini.RELOAD_SPEED = 1
	self.tank_mini.weapon.mini.melee_speed = 1
	self.tank_mini.weapon.mini.melee_dmg = 25
	self.tank_mini.weapon.mini.melee_retry_delay = {
		1,
		2
	}
	self.tank_mini.weapon.mini.range = {
		optimal = 2500,
		far = 5000,
		close = 1000
	}
	self.tank_mini.weapon.mini.autofire_rounds = {
		20,
		40
	}
	self.tank_mini.weapon.mini.FALLOFF = {
		{
			dmg_mul = 5,
			r = 100,
			acc = {
				0.1,
				0.15
			},
			recoil = {
				2,
				2
			},
			mode = {
				0,
				0,
				0,
				1
			},
			autofire_rounds = {
				500,
				700
			}
		},
		{
			dmg_mul = 4,
			r = 500,
			acc = {
				0.05,
				0.1
			},
			recoil = {
				1.5,
				1.75
			},
			mode = {
				0,
				0,
				0,
				1
			},
			autofire_rounds = {
				500,
				500
			}
		},
		{
			dmg_mul = 3.5,
			r = 1000,
			acc = {
				0.04,
				0.075
			},
			recoil = {
				1.2,
				1.5
			},
			mode = {
				0,
				0,
				0,
				1
			},
			autofire_rounds = {
				300,
				500
			}
		},
		{
			dmg_mul = 3,
			r = 2000,
			acc = {
				0.025,
				0.05
			},
			recoil = {
				0.7,
				1
			},
			mode = {
				0,
				0,
				0,
				1
			},
			autofire_rounds = {
				100,
				300
			}
		},
		{
			dmg_mul = 3,
			r = 3000,
			acc = {
				0.01,
				0.025
			},
			recoil = {
				0.5,
				0.7
			},
			mode = {
				0,
				0,
				0,
				1
			},
			autofire_rounds = {
				40,
				100
			}
		}
	}

	table.insert(self._enemy_list, "tank")
	table.insert(self._enemy_list, "tank_hw")
	table.insert(self._enemy_list, "tank_medic")
	table.insert(self._enemy_list, "tank_mini")
end

function CharacterTweakData:_init_spooc(presets)
	self.spooc = deep_clone(presets.base)
	self.spooc.tags = {
		"law",
		"spooc",
		"special"
	}
	self.spooc.experience = {}
	self.spooc.weapon = deep_clone(presets.weapon.good)
	self.spooc.detection = presets.detection.normal
	self.spooc.HEALTH_INIT = 60
	self.spooc.headshot_dmg_mul = 6
	self.spooc.move_speed = presets.move_speed.lightning
	self.spooc.no_retreat = true
	self.spooc.no_arrest = true
	self.spooc.damage.hurt_severity = presets.hurt_severities.only_fire_and_poison_hurts
	self.spooc.surrender_break_time = {
		4,
		6
	}
	self.spooc.suppression = nil
	self.spooc.surrender = presets.surrender.special
	self.spooc.priority_shout = "f33"
	self.spooc.priority_shout_max_dis = 700
	self.spooc.rescue_hostages = false
	self.spooc.spooc_attack_timeout = {
		10,
		10
	}
	self.spooc.spooc_attack_beating_time = {
		3,
		3
	}
	self.spooc.spooc_attack_use_smoke_chance = 1
	self.spooc.weapon_voice = "3"
	self.spooc.experience.cable_tie = "tie_swat"
	self.spooc.speech_prefix_p1 = self._prefix_data_p1.cloaker()
	self.spooc.speech_prefix_count = nil
	self.spooc.access = "spooc"
	self.spooc.use_animation_on_fire_damage = false
	self.spooc.flammable = true
	self.spooc.dodge = presets.dodge.ninja
	self.spooc.dodge_with_grenade = {
		smoke = {
			duration = {
				10,
				20
			}
		},
		check = function (t, nr_grenades_used)
			local delay_till_next_use = math.lerp(17, 45, math.min(1, (nr_grenades_used or 0) / 4))
			local chance = math.lerp(1, 0.5, math.min(1, (nr_grenades_used or 0) / 10))

			if math.random() < chance then
				return true, t + delay_till_next_use
			end

			return false, t + delay_till_next_use
		end
	}
	self.spooc.chatter = presets.enemy_chatter.no_chatter
	self.spooc.steal_loot = nil
	self.spooc.spawn_sound_event = "cloaker_presence_loop"
	self.spooc.die_sound_event = "cloaker_presence_stop"
	self.spooc.spooc_sound_events = {
		detect_stop = "cloaker_detect_stop",
		detect = "cloaker_detect_mono"
	}

	table.insert(self._enemy_list, "spooc")
end

function CharacterTweakData:_init_shadow_spooc(presets)
	self.shadow_spooc = deep_clone(presets.base)
	self.shadow_spooc.tags = {
		"law"
	}
	self.shadow_spooc.experience = {}
	self.shadow_spooc.weapon = deep_clone(presets.weapon.good)
	self.shadow_spooc.detection = presets.detection.normal
	self.shadow_spooc.HEALTH_INIT = 100
	self.shadow_spooc.headshot_dmg_mul = 6
	self.shadow_spooc.move_speed = presets.move_speed.lightning
	self.shadow_spooc.no_retreat = true
	self.shadow_spooc.no_arrest = true
	self.shadow_spooc.damage.hurt_severity = presets.hurt_severities.only_fire_and_poison_hurts
	self.shadow_spooc.surrender_break_time = {
		4,
		6
	}
	self.shadow_spooc.suppression = nil
	self.shadow_spooc.surrender = nil
	self.shadow_spooc.silent_priority_shout = "f37"
	self.shadow_spooc.priority_shout_max_dis = 700
	self.shadow_spooc.rescue_hostages = false
	self.shadow_spooc.spooc_attack_timeout = {
		10,
		10
	}
	self.shadow_spooc.spooc_attack_beating_time = {
		3,
		3
	}
	self.shadow_spooc.spooc_attack_use_smoke_chance = 0
	self.shadow_spooc.weapon_voice = "3"
	self.shadow_spooc.experience.cable_tie = "tie_swat"
	self.shadow_spooc.speech_prefix_p1 = "uno_clk"
	self.shadow_spooc.speech_prefix_count = nil
	self.shadow_spooc.access = "spooc"
	self.shadow_spooc.use_radio = nil
	self.shadow_spooc.use_animation_on_fire_damage = false
	self.shadow_spooc.flammable = false
	self.shadow_spooc.dodge = presets.dodge.ninja
	self.shadow_spooc.chatter = presets.enemy_chatter.no_chatter
	self.shadow_spooc.do_not_drop_ammo = true
	self.shadow_spooc.steal_loot = nil
	self.shadow_spooc.spawn_sound_event = "uno_cloaker_presence_loop"
	self.shadow_spooc.die_sound_event = "uno_cloaker_presence_stop"
	self.shadow_spooc.spooc_sound_events = {
		detect_stop = "uno_cloaker_detect_stop",
		taunt_during_assault = "",
		taunt_after_assault = "",
		detect = "uno_cloaker_detect"
	}

	table.insert(self._enemy_list, "shadow_spooc")
end

function CharacterTweakData:_init_shield(presets)
	self.shield = deep_clone(presets.base)
	self.shield.tags = {
		"law",
		"shield",
		"special"
	}
	self.shield.experience = {}
	self.shield.weapon = deep_clone(presets.weapon.normal)
	self.shield.detection = presets.detection.normal
	self.shield.HEALTH_INIT = 8
	self.shield.headshot_dmg_mul = 2
	self.shield.allowed_stances = {
		cbt = true
	}
	self.shield.allowed_poses = {
		crouch = true
	}
	self.shield.always_face_enemy = true
	self.shield.move_speed = presets.move_speed.very_fast
	self.shield.no_run_start = true
	self.shield.no_run_stop = true
	self.shield.no_retreat = true
	self.shield.no_arrest = true
	self.shield.surrender = nil
	self.shield.ecm_vulnerability = 0.9
	self.shield.ecm_hurts = {
		ears = {
			max_duration = 9,
			min_duration = 7
		}
	}
	self.shield.priority_shout = "f31"
	self.shield.rescue_hostages = false
	self.shield.deathguard = false
	self.shield.no_equip_anim = true
	self.shield.wall_fwd_offset = 100
	self.shield.damage.explosion_damage_mul = 0.8
	self.shield.calls_in = nil
	self.shield.ignore_medic_revive_animation = true
	self.shield.damage.hurt_severity = presets.hurt_severities.only_explosion_hurts
	self.shield.damage.shield_knocked = true
	self.shield.use_animation_on_fire_damage = false
	self.shield.flammable = true
	self.shield.weapon.is_smg = {
		aim_delay = {
			0,
			0.1
		},
		focus_delay = 2,
		focus_dis = 250,
		spread = 60,
		miss_dis = 15,
		RELOAD_SPEED = 1,
		melee_speed = nil,
		melee_dmg = nil,
		melee_retry_delay = nil,
		range = {
			optimal = 1200,
			far = 3000,
			close = 500
		},
		autofire_rounds = presets.weapon.normal.is_smg.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 4,
				r = 0,
				acc = {
					0.7,
					0.95
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					0.2,
					2,
					4,
					10
				}
			},
			{
				dmg_mul = 3.5,
				r = 700,
				acc = {
					0.5,
					0.75
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					0.2,
					2,
					4,
					10
				}
			},
			{
				dmg_mul = 3,
				r = 1000,
				acc = {
					0.45,
					0.65
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					0.2,
					2,
					4,
					10
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.3,
					0.5
				},
				recoil = {
					0.35,
					1.2
				},
				mode = {
					2,
					5,
					6,
					4
				}
			},
			{
				dmg_mul = 2,
				r = 3000,
				acc = {
					0.1,
					0.25
				},
				recoil = {
					0.35,
					1.5
				},
				mode = {
					6,
					4,
					2,
					0
				}
			}
		}
	}
	self.shield.weapon.is_pistol = {
		aim_delay = {
			0,
			0.2
		},
		focus_delay = 2,
		focus_dis = 250,
		spread = 60,
		miss_dis = 15,
		RELOAD_SPEED = 1,
		melee_speed = nil,
		melee_dmg = nil,
		melee_retry_delay = nil,
		range = {
			optimal = 900,
			far = 3000,
			close = 500
		},
		FALLOFF = {
			{
				dmg_mul = 4,
				r = 0,
				acc = {
					0.5,
					0.9
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 700,
				acc = {
					0.5,
					0.8
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 2000,
				acc = {
					0.15,
					0.5
				},
				recoil = {
					0.35,
					0.75
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 3000,
				acc = {
					0,
					0.25
				},
				recoil = {
					0.35,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	self.shield.weapon_voice = "3"
	self.shield.experience.cable_tie = "tie_swat"
	self.shield.speech_prefix_p1 = "l"
	self.shield.speech_prefix_p2 = self._speech_prefix_p2
	self.shield.speech_prefix_count = 4
	self.shield.access = "shield"
	self.shield.chatter = presets.enemy_chatter.shield
	self.shield.announce_incomming = "incomming_shield"
	self.shield.steal_loot = nil
	self.shield.use_animation_on_fire_damage = false
	self.shield.die_sound_event = "shd_x02a_any_3p_01"

	table.insert(self._enemy_list, "shield")
end

function CharacterTweakData:_init_phalanx_minion(presets)
	self.phalanx_minion = deep_clone(self.shield)
	self.phalanx_minion.experience = {}
	self.phalanx_minion.weapon = deep_clone(presets.weapon.normal)
	self.phalanx_minion.detection = presets.detection.normal
	self.phalanx_minion.headshot_dmg_mul = 5
	self.phalanx_minion.HEALTH_INIT = 150
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 70
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_minion.damage.explosion_damage_mul = 6
	self.phalanx_minion.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase
	self.phalanx_minion.damage.shield_knocked = false
	self.phalanx_minion.damage.immune_to_knockback = true
	self.phalanx_minion.immune_to_knock_down = true
	self.phalanx_minion.immune_to_concussion = true
	self.phalanx_minion.ignore_medic_revive_animation = true
	self.phalanx_minion.ecm_vulnerability = 1
	self.phalanx_minion.ecm_hurts = {
		ears = {
			max_duration = 3,
			min_duration = 2
		}
	}
	self.phalanx_minion.priority_shout = "f45"

	table.insert(self._enemy_list, "phalanx_minion")
end

function CharacterTweakData:_init_phalanx_vip(presets)
	self.phalanx_vip = deep_clone(self.phalanx_minion)
	self.phalanx_vip.LOWER_HEALTH_PERCENTAGE_LIMIT = 1
	self.phalanx_vip.FINAL_LOWER_HEALTH_PERCENTAGE_LIMIT = 0.2
	self.phalanx_vip.HEALTH_INIT = 300
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 100
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.can_be_tased = false
	self.phalanx_vip.immune_to_knock_down = true
	self.phalanx_vip.immune_to_concussion = true

	table.insert(self._enemy_list, "phalanx_vip")
end

function CharacterTweakData:_init_taser(presets)
	self.taser = deep_clone(presets.base)
	self.taser.tags = {
		"law",
		"taser",
		"special"
	}
	self.taser.experience = {}
	self.taser.weapon = {
		is_rifle = {
			melee_speed = 0.5,
			miss_dis = 40,
			RELOAD_SPEED = 0.66,
			spread = 20,
			tase_sphere_cast_radius = 30,
			melee_dmg = 10,
			tase_distance = 1500,
			focus_dis = 200,
			focus_delay = 4,
			aim_delay = {
				0.1,
				0.1
			},
			melee_retry_delay = {
				1,
				2
			},
			aim_delay_tase = {
				0,
				0
			},
			range = {
				optimal = 2000,
				far = 5000,
				close = 1000
			},
			autofire_rounds = presets.weapon.normal.is_rifle.autofire_rounds,
			FALLOFF = {
				{
					dmg_mul = 3,
					r = 100,
					acc = {
						0.6,
						0.9
					},
					recoil = {
						0.4,
						0.7
					},
					mode = {
						0,
						3,
						3,
						1
					}
				},
				{
					dmg_mul = 2.5,
					r = 500,
					acc = {
						0.75,
						0.95
					},
					recoil = {
						0.35,
						0.7
					},
					mode = {
						0,
						3,
						3,
						1
					}
				},
				{
					dmg_mul = 2,
					r = 1000,
					acc = {
						0.65,
						0.95
					},
					recoil = {
						0.35,
						0.75
					},
					mode = {
						1,
						2,
						2,
						0
					}
				},
				{
					dmg_mul = 1.25,
					r = 2000,
					acc = {
						0.65,
						0.8
					},
					recoil = {
						0.4,
						1.2
					},
					mode = {
						3,
						2,
						2,
						0
					}
				},
				{
					dmg_mul = 1,
					r = 3000,
					acc = {
						0.45,
						0.6
					},
					recoil = {
						1.5,
						3
					},
					mode = {
						3,
						1,
						1,
						0
					}
				}
			}
		}
	}
	self.taser.detection = presets.detection.normal
	self.taser.HEALTH_INIT = 30
	self.taser.headshot_dmg_mul = 2
	self.taser.move_speed = presets.move_speed.fast
	self.taser.no_retreat = true
	self.taser.no_arrest = true
	self.taser.surrender = presets.surrender.special
	self.taser.ecm_vulnerability = 0.9
	self.taser.ecm_hurts = {
		ears = {
			max_duration = 8,
			min_duration = 6
		}
	}
	self.taser.surrender_break_time = {
		4,
		6
	}
	self.taser.suppression = nil
	self.taser.weapon_voice = "3"
	self.taser.experience.cable_tie = "tie_swat"
	self.taser.speech_prefix_p1 = self._prefix_data_p1.taser()
	self.taser.speech_prefix_p2 = nil
	self.taser.speech_prefix_count = nil
	self.taser.access = "taser"
	self.taser.dodge = presets.dodge.athletic
	self.taser.priority_shout = "f32"
	self.taser.rescue_hostages = false
	self.taser.deathguard = true
	self.taser.chatter = {
		retreat = true,
		aggressive = true,
		contact = true
	}
	self.taser.announce_incomming = "incomming_taser"
	self.taser.steal_loot = nil
	self.taser.die_sound_event = "tsr_x02a_any_3p"
	self.taser.special_deaths = {
		bullet = {
			[("head"):id():key()] = {
				sequence = "kill_tazer_headshot",
				special_comment = "x01",
				weapon_id = "model70",
				character_name = "bodhi"
			}
		}
	}

	table.insert(self._enemy_list, "taser")
end

function CharacterTweakData:_init_inside_man(presets)
	self.inside_man = deep_clone(presets.base)
	self.inside_man.experience = {}
	self.inside_man.weapon = presets.weapon.normal
	self.inside_man.detection = presets.detection.blind
	self.inside_man.HEALTH_INIT = 8
	self.inside_man.headshot_dmg_mul = 2
	self.inside_man.move_speed = presets.move_speed.normal
	self.inside_man.surrender_break_time = {
		10,
		15
	}
	self.inside_man.suppression = presets.suppression.no_supress
	self.inside_man.surrender = nil
	self.inside_man.ecm_vulnerability = 1
	self.inside_man.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.inside_man.weapon_voice = "1"
	self.inside_man.experience.cable_tie = "tie_swat"
	self.inside_man.speech_prefix_p1 = "l"
	self.inside_man.speech_prefix_p2 = "n"
	self.inside_man.speech_prefix_count = 4
	self.inside_man.access = "cop"
	self.inside_man.dodge = presets.dodge.average
	self.inside_man.chatter = presets.enemy_chatter.no_chatter
	self.inside_man.melee_weapon = "baton"
	self.inside_man.calls_in = nil
end

function CharacterTweakData:_init_civilian(presets)
	self.civilian = {
		detection = presets.detection.civilian,
		tags = {
			"civilian"
		},
		experience = {},
		HEALTH_INIT = 0.9,
		headshot_dmg_mul = 1,
		move_speed = presets.move_speed.civ_fast,
		flee_type = "escape",
		scare_max = {
			10,
			20
		},
		scare_shot = 1,
		scare_intimidate = -5,
		submission_max = {
			60,
			120
		},
		submission_intimidate = 120,
		run_away_delay = {
			5,
			20
		},
		damage = {
			hurt_severity = presets.hurt_severities.no_hurts
		},
		ecm_vulnerability = 1,
		ecm_hurts = {
			ears = {
				max_duration = 10,
				min_duration = 8
			}
		}
	}
	self.civilian.experience.cable_tie = "tie_civ"
	self.civilian.silent_priority_shout = "f37"
	self.civilian.speech_prefix_p1 = "cm"
	self.civilian.speech_prefix_count = 2
	self.civilian.access = "civ_male"
	self.civilian.intimidateable = true
	self.civilian.challenges = {
		type = "civilians"
	}
	self.civilian.calls_in = true
	self.civilian.hostage_move_speed = 1.25
	self.civilian_female = deep_clone(self.civilian)
	self.civilian_female.speech_prefix_p1 = "cf"
	self.civilian_female.speech_prefix_count = 5
	self.civilian_female.female = true
	self.civilian_female.access = "civ_female"
	self.robbers_safehouse = deep_clone(self.civilian)
	self.robbers_safehouse.scare_shot = 0
	self.robbers_safehouse.scare_intimidate = 0
	self.robbers_safehouse.intimidateable = false
	self.robbers_safehouse.ignores_aggression = true
	self.robbers_safehouse.ignores_contours = true
	self.robbers_safehouse.use_ik = true
end

function CharacterTweakData:_init_melee_box(presets)
	self.melee_box = deep_clone(self.civilian)
	self.melee_box.move_speed = presets.move_speed.civ_fast
	self.melee_box.flee_type = "hide"
	self.melee_box.access = "civ_male"
	self.melee_box.intimidateable = nil
	self.melee_box.challenges = {
		type = "civilians"
	}
	self.melee_box.calls_in = nil
	self.melee_box.ignores_aggression = true
end

function CharacterTweakData:_init_bank_manager(presets)
	self.bank_manager = {
		experience = {},
		escort = {},
		detection = presets.detection.civilian,
		tags = {
			"civilian"
		},
		HEALTH_INIT = self.civilian.HEALTH_INIT,
		headshot_dmg_mul = self.civilian.headshot_dmg_mul,
		move_speed = presets.move_speed.normal,
		flee_type = "hide",
		scare_max = {
			10,
			20
		},
		scare_shot = 1,
		scare_intimidate = -5,
		submission_max = {
			60,
			120
		},
		submission_intimidate = 120,
		damage = presets.hurt_severities.no_hurts,
		ecm_vulnerability = 1,
		ecm_hurts = {
			ears = {
				max_duration = 10,
				min_duration = 8
			}
		}
	}
	self.bank_manager.experience.cable_tie = "tie_civ"
	self.bank_manager.speech_prefix_p1 = "cm"
	self.bank_manager.speech_prefix_count = 2
	self.bank_manager.access = "civ_male"
	self.bank_manager.intimidateable = true
	self.bank_manager.challenges = {
		type = "civilians"
	}
	self.bank_manager.calls_in = true
end

function CharacterTweakData:_init_drunk_pilot(presets)
	self.drunk_pilot = deep_clone(self.civilian)
	self.drunk_pilot.move_speed = presets.move_speed.civ_fast
	self.drunk_pilot.flee_type = "hide"
	self.drunk_pilot.access = "civ_male"
	self.drunk_pilot.intimidateable = nil
	self.drunk_pilot.challenges = {
		type = "civilians"
	}
	self.drunk_pilot.calls_in = nil
	self.drunk_pilot.ignores_aggression = true
end

function CharacterTweakData:_init_boris(presets)
	self.boris = deep_clone(self.civilian)
	self.boris.flee_type = "hide"
	self.boris.access = "civ_male"
	self.boris.intimidateable = nil
	self.boris.challenges = {
		type = "civilians"
	}
	self.boris.calls_in = nil
	self.boris.ignores_aggression = true
end

function CharacterTweakData:_init_escort(presets)
	self.escort = {
		experience = {},
		escort = {},
		detection = presets.detection.civilian,
		HEALTH_INIT = 0.9,
		headshot_dmg_mul = 1,
		move_speed = presets.move_speed.civ_fast,
		flee_type = "hide",
		scare_max = {
			10,
			20
		},
		scare_shot = 1,
		scare_intimidate = -5,
		submission_max = {
			60,
			120
		},
		submission_intimidate = 120,
		run_away_delay = {
			5,
			20
		},
		damage = presets.hurt_severities.no_hurts,
		ecm_hurts = {}
	}
	self.escort.experience.cable_tie = "tie_civ"
	self.escort.speech_prefix_p1 = "cm"
	self.escort.speech_prefix_count = 2
	self.escort.access = "civ_male"
	self.escort.intimidateable = false
	self.escort.challenges = {
		type = "civilians"
	}
	self.escort.calls_in = nil
	self.escort.is_escort = true
	self.escort.escort_idle_talk = true
	self.escort.escort_scared_dist = 600
end

function CharacterTweakData:_init_escort_undercover(presets)
	self.escort_undercover = deep_clone(self.civilian)
	self.escort_undercover.move_speed = presets.move_speed.slow
	self.escort_undercover.allowed_stances = {
		hos = true
	}
	self.escort_undercover.allowed_poses = {
		stand = true
	}
	self.escort_undercover.no_run_start = true
	self.escort_undercover.no_run_stop = true
	self.escort_undercover.flee_type = "hide"
	self.escort_undercover.speech_prefix_p1 = "cm"
	self.escort_undercover.speech_prefix_count = 2
	self.escort_undercover.speech_escort = "undercover_escort"
	self.escort_undercover.access = "civ_male"
	self.escort_undercover.intimidateable = false
	self.escort_undercover.calls_in = false
	self.escort_undercover.escort_scared_dist = 200
	self.escort_undercover.is_escort = true
	self.escort_undercover.escort_idle_talk = true
	self.escort_chinese_prisoner = deep_clone(self.escort_undercover)
	self.escort_chinese_prisoner.move_speed = presets.move_speed.slow
	self.escort_chinese_prisoner.no_run_start = false
	self.escort_chinese_prisoner.no_run_stop = false
	self.escort_cfo = deep_clone(self.escort_undercover)
	self.escort_cfo.move_speed = presets.move_speed.normal
end

function CharacterTweakData:_init_old_hoxton_mission(presets)
	self.old_hoxton_mission = deep_clone(presets.base)
	self.old_hoxton_mission.experience = {}
	self.old_hoxton_mission.weapon = presets.weapon.normal
	self.old_hoxton_mission.detection = presets.detection.normal
	self.old_hoxton_mission.HEALTH_INIT = 8
	self.old_hoxton_mission.headshot_dmg_mul = 2
	self.old_hoxton_mission.move_speed = presets.move_speed.fast
	self.old_hoxton_mission.surrender_break_time = {
		6,
		10
	}
	self.old_hoxton_mission.suppression = presets.suppression.no_supress
	self.old_hoxton_mission.surrender = false
	self.old_hoxton_mission.weapon_voice = "1"
	self.old_hoxton_mission.experience.cable_tie = "tie_swat"
	self.old_hoxton_mission.speech_prefix_p1 = "rb2"
	self.old_hoxton_mission.access = "teamAI4"
	self.old_hoxton_mission.dodge = presets.dodge.athletic
	self.old_hoxton_mission.no_arrest = true
	self.old_hoxton_mission.chatter = presets.enemy_chatter.no_chatter
	self.old_hoxton_mission.melee_weapon = "fists"
	self.old_hoxton_mission.melee_weapon_dmg_multiplier = 3
	self.old_hoxton_mission.steal_loot = false
	self.old_hoxton_mission.rescue_hostages = false
end

function CharacterTweakData:_init_spa_vip(presets)
	self.spa_vip = deep_clone(self.old_hoxton_mission)
	self.spa_vip.spotlight_important = 100
	self.spa_vip.is_escort = true
	self.spa_vip.escort_idle_talk = false
	self.spa_vip.escort_scared_dist = 100
	self.spa_vip.suppression.panic_chance_mul = 0
end

function CharacterTweakData:_init_spa_vip_hurt(presets)
	self.spa_vip_hurt = deep_clone(self.civilian)
	self.spa_vip_hurt.move_speed = presets.move_speed.slow
	self.spa_vip_hurt.flee_type = "hide"
	self.spa_vip_hurt.access = "civ_male"
	self.spa_vip_hurt.intimidateable = nil
	self.spa_vip_hurt.challenges = {
		type = "civilians"
	}
	self.spa_vip_hurt.calls_in = nil
	self.spa_vip_hurt.ignores_aggression = true
end

function CharacterTweakData:_init_russian(presets)
	self.russian = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.russian.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_74_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_beretta92/wpn_npc_beretta92")
	}
	self.russian.detection = presets.detection.gang_member
	self.russian.move_speed = presets.move_speed.very_fast
	self.russian.crouch_move = false
	self.russian.speech_prefix = "rb2"
	self.russian.weapon_voice = "1"
	self.russian.access = "teamAI1"
	self.russian.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_german(presets)
	self.german = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.german.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_beretta92/wpn_npc_beretta92")
	}
	self.german.detection = presets.detection.gang_member
	self.german.move_speed = presets.move_speed.very_fast
	self.german.crouch_move = false
	self.german.speech_prefix = "rb2"
	self.german.weapon_voice = "2"
	self.german.access = "teamAI1"
	self.german.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_spanish(presets)
	self.spanish = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.spanish.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.spanish.detection = presets.detection.gang_member
	self.spanish.move_speed = presets.move_speed.very_fast
	self.spanish.crouch_move = false
	self.spanish.speech_prefix = "rb2"
	self.spanish.weapon_voice = "3"
	self.spanish.access = "teamAI1"
	self.spanish.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_american(presets)
	self.american = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.american.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_74_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45")
	}
	self.american.detection = presets.detection.gang_member
	self.american.move_speed = presets.move_speed.very_fast
	self.american.crouch_move = false
	self.american.speech_prefix = "rb2"
	self.american.weapon_voice = "3"
	self.american.access = "teamAI1"
	self.american.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_jowi(presets)
	self.jowi = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.jowi.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45")
	}
	self.jowi.detection = presets.detection.gang_member
	self.jowi.move_speed = presets.move_speed.very_fast
	self.jowi.crouch_move = false
	self.jowi.speech_prefix = "rb2"
	self.jowi.weapon_voice = "3"
	self.jowi.access = "teamAI1"
	self.jowi.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_old_hoxton(presets)
	self.old_hoxton = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.old_hoxton.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.old_hoxton.detection = presets.detection.gang_member
	self.old_hoxton.move_speed = presets.move_speed.very_fast
	self.old_hoxton.crouch_move = false
	self.old_hoxton.speech_prefix = "rb2"
	self.old_hoxton.weapon_voice = "3"
	self.old_hoxton.access = "teamAI1"
	self.old_hoxton.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_clover(presets)
	self.female_1 = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.female_1.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.female_1.detection = presets.detection.gang_member
	self.female_1.move_speed = presets.move_speed.very_fast
	self.female_1.crouch_move = false
	self.female_1.speech_prefix = "rb7"
	self.female_1.weapon_voice = "3"
	self.female_1.access = "teamAI1"
	self.female_1.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_dragan(presets)
	self.dragan = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.dragan.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45")
	}
	self.dragan.detection = presets.detection.gang_member
	self.dragan.move_speed = presets.move_speed.very_fast
	self.dragan.crouch_move = false
	self.dragan.speech_prefix = "rb8"
	self.dragan.weapon_voice = "3"
	self.dragan.access = "teamAI1"
	self.dragan.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_jacket(presets)
	self.jacket = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.jacket.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45")
	}
	self.jacket.detection = presets.detection.gang_member
	self.jacket.move_speed = presets.move_speed.very_fast
	self.jacket.crouch_move = false
	self.jacket.speech_prefix = "rb9"
	self.jacket.weapon_voice = "3"
	self.jacket.access = "teamAI1"
	self.jacket.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_bonnie(presets)
	self.bonnie = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.bonnie.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.bonnie.detection = presets.detection.gang_member
	self.bonnie.move_speed = presets.move_speed.very_fast
	self.bonnie.crouch_move = false
	self.bonnie.speech_prefix = "rb10"
	self.bonnie.weapon_voice = "3"
	self.bonnie.access = "teamAI1"
	self.bonnie.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_sokol(presets)
	self.sokol = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.sokol.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.sokol.detection = presets.detection.gang_member
	self.sokol.move_speed = presets.move_speed.very_fast
	self.sokol.crouch_move = false
	self.sokol.speech_prefix = "rb11"
	self.sokol.weapon_voice = "3"
	self.sokol.access = "teamAI1"
	self.sokol.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_dragon(presets)
	self.dragon = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.dragon.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.dragon.detection = presets.detection.gang_member
	self.dragon.move_speed = presets.move_speed.very_fast
	self.dragon.crouch_move = false
	self.dragon.speech_prefix = "rb12"
	self.dragon.weapon_voice = "3"
	self.dragon.access = "teamAI1"
	self.dragon.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_bodhi(presets)
	self.bodhi = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.bodhi.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45")
	}
	self.bodhi.detection = presets.detection.gang_member
	self.bodhi.move_speed = presets.move_speed.very_fast
	self.bodhi.crouch_move = false
	self.bodhi.speech_prefix = "rb13"
	self.bodhi.weapon_voice = "3"
	self.bodhi.access = "teamAI1"
	self.bodhi.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_jimmy(presets)
	self.jimmy = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.jimmy.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45")
	}
	self.jimmy.detection = presets.detection.gang_member
	self.jimmy.move_speed = presets.move_speed.very_fast
	self.jimmy.crouch_move = false
	self.jimmy.speech_prefix = "rb14"
	self.jimmy.weapon_voice = "3"
	self.jimmy.access = "teamAI1"
	self.jimmy.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_sydney(presets)
	self.sydney = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.sydney.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.sydney.detection = presets.detection.gang_member
	self.sydney.move_speed = presets.move_speed.very_fast
	self.sydney.crouch_move = false
	self.sydney.speech_prefix = "rb15"
	self.sydney.weapon_voice = "3"
	self.sydney.access = "teamAI1"
	self.sydney.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_wild(presets)
	self.wild = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.wild.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.wild.detection = presets.detection.gang_member
	self.wild.move_speed = presets.move_speed.very_fast
	self.wild.crouch_move = false
	self.wild.speech_prefix = "rb16"
	self.wild.weapon_voice = "3"
	self.wild.access = "teamAI1"
	self.wild.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_chico(presets)
	self.chico = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.chico.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.chico.detection = presets.detection.gang_member
	self.chico.move_speed = presets.move_speed.very_fast
	self.chico.crouch_move = false
	self.chico.speech_prefix = "rb17"
	self.chico.weapon_voice = "3"
	self.chico.access = "teamAI1"
	self.chico.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_max(presets)
	self.max = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.max.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.max.detection = presets.detection.gang_member
	self.max.move_speed = presets.move_speed.very_fast
	self.max.crouch_move = false
	self.max.speech_prefix = "rb18"
	self.max.weapon_voice = "3"
	self.max.access = "teamAI1"
	self.max.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_joy(presets)
	self.joy = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.joy.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.joy.detection = presets.detection.gang_member
	self.joy.move_speed = presets.move_speed.very_fast
	self.joy.crouch_move = false
	self.joy.speech_prefix = "rb19"
	self.joy.weapon_voice = "3"
	self.joy.access = "teamAI1"
	self.joy.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_myh(presets)
	self.myh = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.myh.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.myh.detection = presets.detection.gang_member
	self.myh.move_speed = presets.move_speed.very_fast
	self.myh.crouch_move = false
	self.myh.speech_prefix = "rb22"
	self.myh.weapon_voice = "3"
	self.myh.access = "teamAI1"
	self.myh.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_init_ecp(presets)
	self.ecp_female = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.ecp_female.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.ecp_female.detection = presets.detection.gang_member
	self.ecp_female.move_speed = presets.move_speed.very_fast
	self.ecp_female.crouch_move = false
	self.ecp_female.speech_prefix = "rb21"
	self.ecp_female.weapon_voice = "3"
	self.ecp_female.access = "teamAI1"
	self.ecp_female.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
	self.ecp_male = {
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member)
	}
	self.ecp_male.weapon.weapons_of_choice = {
		primary = "wpn_fps_ass_m4_npc",
		secondary = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	}
	self.ecp_male.detection = presets.detection.gang_member
	self.ecp_male.move_speed = presets.move_speed.very_fast
	self.ecp_male.crouch_move = false
	self.ecp_male.speech_prefix = "rb20"
	self.ecp_male.weapon_voice = "3"
	self.ecp_male.access = "teamAI1"
	self.ecp_male.arrest = {
		timeout = 240,
		aggression_timeout = 6,
		arrest_timeout = 240
	}
end

function CharacterTweakData:_presets(tweak_data)
	local presets = {
		hurt_severities = {}
	}
	presets.hurt_severities.no_hurts = {
		tase = true,
		bullet = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		explosion = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		melee = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		fire = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		poison = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		}
	}
	presets.hurt_severities.no_hurts_no_tase = deep_clone(presets.hurt_severities.no_hurts)
	presets.hurt_severities.no_hurts_no_tase.tase = false
	presets.hurt_severities.only_light_hurt = {
		tase = true,
		bullet = {
			health_reference = 1,
			zones = {
				{
					light = 1
				}
			}
		},
		explosion = {
			health_reference = 1,
			zones = {
				{
					explode = 1
				}
			}
		},
		melee = {
			health_reference = 1,
			zones = {
				{
					light = 1
				}
			}
		},
		fire = {
			health_reference = 1,
			zones = {
				{
					light = 1
				}
			}
		},
		poison = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		}
	}
	presets.hurt_severities.only_light_hurt_and_fire = {
		tase = true,
		bullet = {
			health_reference = 1,
			zones = {
				{
					light = 1
				}
			}
		},
		explosion = {
			health_reference = 1,
			zones = {
				{
					explode = 1
				}
			}
		},
		melee = {
			health_reference = 1,
			zones = {
				{
					light = 1
				}
			}
		},
		fire = {
			health_reference = 1,
			zones = {
				{
					fire = 1
				}
			}
		},
		poison = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		}
	}
	presets.hurt_severities.light_hurt_fire_poison = deep_clone(presets.hurt_severities.only_light_hurt_and_fire)
	presets.hurt_severities.light_hurt_fire_poison.poison = {
		health_reference = 1,
		zones = {
			{
				poison = 1
			}
		}
	}
	presets.hurt_severities.only_explosion_hurts = {
		tase = true,
		bullet = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		explosion = {
			health_reference = 1,
			zones = {
				{
					explode = 1
				}
			}
		},
		melee = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		fire = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		poison = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		}
	}
	presets.hurt_severities.only_fire_and_poison_hurts = {
		tase = true,
		bullet = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		explosion = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		melee = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		fire = {
			health_reference = 1,
			zones = {
				{
					fire = 1
				}
			}
		},
		poison = {
			health_reference = 1,
			zones = {
				{
					poison = 1
				}
			}
		}
	}
	presets.hurt_severities.base = {
		bullet = {
			health_reference = "current",
			zones = {
				{
					heavy = 0.05,
					health_limit = 0.3,
					light = 0.7,
					moderate = 0.05,
					none = 0.2
				},
				{
					heavy = 0.2,
					light = 0.4,
					moderate = 0.4,
					health_limit = 0.6
				},
				{
					heavy = 0.6,
					light = 0.2,
					moderate = 0.2,
					health_limit = 0.9
				},
				{
					light = 0,
					moderate = 0,
					heavy = 1
				}
			}
		},
		explosion = {
			health_reference = "current",
			zones = {
				{
					none = 0.6,
					heavy = 0.4,
					health_limit = 0.2
				},
				{
					explode = 0.4,
					heavy = 0.6,
					health_limit = 0.5
				},
				{
					explode = 0.8,
					heavy = 0.2
				}
			}
		},
		melee = {
			health_reference = "current",
			zones = {
				{
					heavy = 0,
					health_limit = 0.3,
					light = 0.7,
					moderate = 0,
					none = 0.3
				},
				{
					heavy = 0,
					light = 1,
					moderate = 0,
					health_limit = 0.8
				},
				{
					heavy = 0.2,
					light = 0.6,
					moderate = 0.2,
					health_limit = 0.9
				},
				{
					light = 0,
					moderate = 0,
					heavy = 9
				}
			}
		},
		fire = {
			health_reference = "current",
			zones = {
				{
					fire = 1
				}
			}
		},
		poison = {
			health_reference = "current",
			zones = {
				{
					poison = 1,
					none = 0
				}
			}
		}
	}
	presets.hurt_severities.base_no_poison = deep_clone(presets.hurt_severities.base)
	presets.hurt_severities.base_no_poison.poison = {
		health_reference = 1,
		zones = {
			{
				none = 1
			}
		}
	}
	presets.base = {
		HEALTH_INIT = 2.5,
		headshot_dmg_mul = 2,
		SPEED_WALK = {
			ntl = 120,
			cbt = 160,
			hos = 180,
			pnc = 160
		},
		SPEED_RUN = 370,
		crouch_move = true,
		shooting_death = true,
		suspicious = true,
		surrender_break_time = {
			20,
			30
		},
		submission_max = {
			45,
			60
		},
		submission_intimidate = 15,
		speech_prefix = "po",
		speech_prefix_count = 1,
		rescue_hostages = true,
		use_radio = self._default_chatter,
		dodge = nil,
		challenges = {
			type = "law"
		},
		calls_in = true,
		ignore_medic_revive_animation = false,
		spotlight_important = false,
		experience = {}
	}
	presets.base.experience.cable_tie = "tie_swat"
	presets.base.damage = {
		hurt_severity = presets.hurt_severities.base,
		death_severity = 0.5,
		explosion_damage_mul = 1,
		tased_response = {
			light = {
				down_time = 5,
				tased_time = 5
			},
			heavy = {
				down_time = 10,
				tased_time = 5
			}
		}
	}
	presets.gang_member_damage = {
		HEALTH_INIT = 75,
		REGENERATE_TIME = 2,
		REGENERATE_TIME_AWAY = 0.2,
		DOWNED_TIME = tweak_data.player.damage.DOWNED_TIME,
		TASED_TIME = tweak_data.player.damage.TASED_TIME,
		BLEED_OUT_HEALTH_INIT = tweak_data.player.damage.BLEED_OUT_HEALTH_INIT,
		ARRESTED_TIME = tweak_data.player.damage.ARRESTED_TIME,
		INCAPACITATED_TIME = tweak_data.player.damage.INCAPACITATED_TIME,
		hurt_severity = deep_clone(presets.hurt_severities.base)
	}
	presets.gang_member_damage.hurt_severity.bullet = {
		health_reference = "current",
		zones = {
			{
				none = 1,
				light = 0,
				moderate = 0,
				health_limit = 0.4
			},
			{
				none = 1,
				light = 0,
				moderate = 0,
				health_limit = 0.7
			},
			{
				heavy = 0,
				light = 0,
				moderate = 0,
				none = 1
			}
		}
	}
	presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35
	presets.gang_member_damage.respawn_time_penalty = 0
	presets.gang_member_damage.base_respawn_time_penalty = 5
	presets.weapon = {
		normal = {}
	}
	presets.weapon.normal.is_pistol = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 10,
		focus_dis = 200,
		spread = 25,
		miss_dis = 30,
		RELOAD_SPEED = 0.9,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.1,
					0.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5,
				r = 500,
				acc = {
					0.4,
					0.85
				},
				recoil = {
					0.1,
					0.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 1000,
				acc = {
					0.375,
					0.55
				},
				recoil = {
					0.15,
					0.3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.25,
					0.45
				},
				recoil = {
					0.3,
					0.7
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.normal.akimbo_pistol = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 10,
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 0.9,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.15,
					0.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5,
				r = 500,
				acc = {
					0.4,
					0.85
				},
				recoil = {
					0.15,
					0.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 1000,
				acc = {
					0.375,
					0.55
				},
				recoil = {
					0.15,
					0.3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.25,
					0.45
				},
				recoil = {
					0.3,
					0.7
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.normal.is_rifle = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 10,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.9,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			6,
			11
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.9
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 1000,
				acc = {
					0.2,
					0.8
				},
				recoil = {
					0.35,
					0.75
				},
				mode = {
					1,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.4,
					1.2
				},
				mode = {
					3,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					3,
					1,
					1,
					0
				}
			}
		}
	}
	presets.weapon.normal.is_bullpup = presets.weapon.normal.is_rifle
	presets.weapon.normal.is_shotgun_pump = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 10,
		focus_dis = 200,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 0.9,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.9
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.5,
				r = 1000,
				acc = {
					0.2,
					0.75
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.5,
				r = 2000,
				acc = {
					0.01,
					0.25
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.2,
				r = 3000,
				acc = {
					0.05,
					0.35
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.normal.is_shotgun_mag = presets.weapon.normal.is_shotgun_pump
	presets.weapon.normal.is_smg = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 10,
		focus_dis = 200,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 0.9,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			6,
			11
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.1,
					0.3
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.9
				},
				recoil = {
					0.1,
					0.3
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 1000,
				acc = {
					0.2,
					0.8
				},
				recoil = {
					0.3,
					0.4
				},
				mode = {
					0,
					3,
					3,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.1,
					0.45
				},
				recoil = {
					0.3,
					0.4
				},
				mode = {
					0,
					3,
					3,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					0.5,
					0.6
				},
				mode = {
					1,
					3,
					2,
					0
				}
			}
		}
	}
	presets.weapon.normal.is_revolver = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 10,
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 0.9,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5,
				r = 500,
				acc = {
					0.5,
					0.85
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 1000,
				acc = {
					0.375,
					0.55
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.75,
				r = 2000,
				acc = {
					0.25,
					0.45
				},
				recoil = {
					1,
					1.3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.5,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.normal.mini = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 800,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			40
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	presets.weapon.normal.is_lmg = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 10,
		focus_dis = 200,
		spread = 24,
		miss_dis = 40,
		RELOAD_SPEED = 0.6,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 1800,
			far = 5000,
			close = 800
		},
		autofire_rounds = {
			20,
			40
		},
		FALLOFF = {
			{
				dmg_mul = 2.5,
				r = 100,
				acc = {
					0.55,
					0.85
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.5,
					0.8
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 1000,
				acc = {
					0.2,
					0.7
				},
				recoil = {
					0.35,
					0.75
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.175,
					0.5
				},
				recoil = {
					0.4,
					1.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.good = {
		is_pistol = {}
	}
	presets.weapon.good.is_pistol.aim_delay = {
		0.1,
		0.1
	}
	presets.weapon.good.is_pistol.focus_delay = 2
	presets.weapon.good.is_pistol.focus_dis = 200
	presets.weapon.good.is_pistol.spread = 25
	presets.weapon.good.is_pistol.miss_dis = 30
	presets.weapon.good.is_pistol.RELOAD_SPEED = 1
	presets.weapon.good.is_pistol.melee_speed = presets.weapon.normal.is_pistol.melee_speed
	presets.weapon.good.is_pistol.melee_dmg = presets.weapon.normal.is_pistol.melee_dmg
	presets.weapon.good.is_pistol.melee_retry_delay = presets.weapon.normal.is_pistol.melee_retry_delay
	presets.weapon.good.is_pistol.range = presets.weapon.normal.is_pistol.range
	presets.weapon.good.is_pistol.FALLOFF = {
		{
			dmg_mul = 3,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 500,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 1000,
			acc = {
				0.375,
				0.55
			},
			recoil = {
				0.15,
				0.3
			},
			mode = {
				1,
				0,
				1,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.15,
				0.45
			},
			recoil = {
				0.3,
				0.7
			},
			mode = {
				1,
				0,
				1,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				0.4,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.good.akimbo_pistol = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 2,
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1,
		melee_speed = presets.weapon.normal.is_pistol.melee_speed,
		melee_dmg = presets.weapon.normal.is_pistol.melee_dmg,
		melee_retry_delay = presets.weapon.normal.is_pistol.melee_retry_delay,
		range = presets.weapon.normal.is_pistol.range,
		FALLOFF = {
			{
				dmg_mul = 4,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.15,
					0.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.5,
					0.85
				},
				recoil = {
					0.15,
					0.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.375,
					0.55
				},
				recoil = {
					0.15,
					0.4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.25,
				r = 2000,
				acc = {
					0.25,
					0.45
				},
				recoil = {
					0.4,
					0.9
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.good.is_rifle = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 3,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay,
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		autofire_rounds = presets.weapon.normal.is_rifle.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.8
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.9
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.2,
					0.8
				},
				recoil = {
					0.35,
					0.75
				},
				mode = {
					1,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 1.25,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.4,
					1.2
				},
				mode = {
					3,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					3,
					1,
					1,
					0
				}
			}
		}
	}
	presets.weapon.good.is_bullpup = presets.weapon.good.is_rifle
	presets.weapon.good.is_shotgun_pump = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 5,
		focus_dis = 200,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.normal.is_shotgun_pump.melee_retry_delay,
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.95
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.2,
					0.75
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.01,
					0.25
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.4,
				r = 3000,
				acc = {
					0.05,
					0.35
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.good.is_shotgun_mag = presets.weapon.good.is_shotgun_pump
	presets.weapon.good.is_smg = {
		aim_delay = {
			0,
			0.2
		},
		focus_delay = 3,
		focus_dis = 200,
		spread = 15,
		miss_dis = 10,
		RELOAD_SPEED = 1,
		melee_speed = presets.weapon.normal.is_smg.melee_speed,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.normal.is_smg.melee_retry_delay,
		range = presets.weapon.normal.is_smg.range,
		autofire_rounds = presets.weapon.normal.is_smg.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.1,
					0.25
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.95
				},
				recoil = {
					0.1,
					0.3
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1.75,
				r = 1000,
				acc = {
					0.2,
					0.75
				},
				recoil = {
					0.35,
					0.5
				},
				mode = {
					0,
					3,
					3,
					0
				}
			},
			{
				dmg_mul = 1.25,
				r = 2000,
				acc = {
					0.1,
					0.45
				},
				recoil = {
					0.35,
					0.6
				},
				mode = {
					0,
					3,
					3,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					0.5,
					0.6
				},
				mode = {
					1,
					3,
					2,
					0
				}
			}
		}
	}
	presets.weapon.good.is_revolver = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 10,
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 0.9,
		melee_speed = 1,
		melee_dmg = 8,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 4,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.5,
					0.85
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.375,
					0.55
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.25,
					0.45
				},
				recoil = {
					1,
					1.3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.5,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.good.mini = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 800,
		spread = 30,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			40
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.1,
					0.15
				},
				recoil = {
					2,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				},
				autofire_rounds = {
					150,
					200
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.05,
					0.1
				},
				recoil = {
					1.5,
					1.75
				},
				mode = {
					0,
					0,
					0,
					1
				},
				autofire_rounds = {
					120,
					160
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.04,
					0.075
				},
				recoil = {
					1.2,
					1.5
				},
				mode = {
					0,
					0,
					0,
					1
				},
				autofire_rounds = {
					100,
					140
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.025,
					0.05
				},
				recoil = {
					0.7,
					1
				},
				mode = {
					0,
					0,
					0,
					1
				},
				autofire_rounds = {
					60,
					100
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.01,
					0.025
				},
				recoil = {
					0.5,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				},
				autofire_rounds = {
					40,
					80
				}
			}
		}
	}
	presets.weapon.good.is_lmg = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 3,
		focus_dis = 200,
		spread = 24,
		miss_dis = 40,
		RELOAD_SPEED = 0.66,
		melee_speed = 1,
		melee_dmg = 13,
		melee_retry_delay = presets.weapon.normal.is_lmg.melee_retry_delay,
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		autofire_rounds = presets.weapon.normal.is_lmg.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.9
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.2,
					0.8
				},
				recoil = {
					0.35,
					0.75
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1.25,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.4,
					1.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.expert = {
		is_pistol = {}
	}
	presets.weapon.expert.is_pistol.aim_delay = {
		0.1,
		0.1
	}
	presets.weapon.expert.is_pistol.focus_delay = 1
	presets.weapon.expert.is_pistol.focus_dis = 300
	presets.weapon.expert.is_pistol.spread = 25
	presets.weapon.expert.is_pistol.miss_dis = 30
	presets.weapon.expert.is_pistol.RELOAD_SPEED = 1.1
	presets.weapon.expert.is_pistol.melee_speed = presets.weapon.normal.is_pistol.melee_speed
	presets.weapon.expert.is_pistol.melee_dmg = presets.weapon.normal.is_pistol.melee_dmg
	presets.weapon.expert.is_pistol.melee_retry_delay = presets.weapon.normal.is_pistol.melee_retry_delay
	presets.weapon.expert.is_pistol.range = presets.weapon.normal.is_pistol.range
	presets.weapon.expert.is_pistol.FALLOFF = {
		{
			dmg_mul = 4,
			r = 0,
			acc = {
				0.5,
				0.95
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 1000,
			acc = {
				0.375,
				0.55
			},
			recoil = {
				0.15,
				0.3
			},
			mode = {
				1,
				0,
				1,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 2000,
			acc = {
				0.05,
				0.5
			},
			recoil = {
				0.3,
				0.7
			},
			mode = {
				1,
				0,
				1,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0,
				0.3
			},
			recoil = {
				0.4,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.expert.is_pistol = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 1,
		focus_dis = 300,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1.2,
		melee_speed = presets.weapon.normal.is_pistol.melee_speed,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.normal.is_pistol.melee_retry_delay,
		range = presets.weapon.normal.is_pistol.range,
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.15,
					0.25
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.5,
					0.9
				},
				recoil = {
					0.15,
					0.3
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.4,
					0.65
				},
				recoil = {
					0.15,
					0.3
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.3,
					0.5
				},
				recoil = {
					0.4,
					0.9
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2.5,
				r = 3000,
				acc = {
					0.1,
					0.25
				},
				recoil = {
					0.4,
					1.4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.expert.akimbo_pistol = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 1,
		focus_dis = 300,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1.2,
		melee_speed = presets.weapon.normal.is_pistol.melee_speed,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.normal.is_pistol.melee_retry_delay,
		range = presets.weapon.normal.is_pistol.range,
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.15,
					0.25
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.5,
					0.9
				},
				recoil = {
					0.15,
					0.3
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.4,
					0.65
				},
				recoil = {
					0.15,
					0.3
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.3,
					0.5
				},
				recoil = {
					0.4,
					0.9
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2.5,
				r = 3000,
				acc = {
					0.1,
					0.25
				},
				recoil = {
					0.4,
					1.4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.expert.is_shotgun_pump = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 5,
		focus_dis = 200,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.normal.is_shotgun_pump.melee_retry_delay,
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.95
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.2,
					0.75
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.01,
					0.25
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.4,
				r = 3000,
				acc = {
					0.05,
					0.35
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.expert.is_shotgun_mag = presets.weapon.expert.is_shotgun_pump
	presets.weapon.expert.is_rifle = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 3,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay,
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		autofire_rounds = presets.weapon.normal.is_rifle.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.8
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.9
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.2,
					0.8
				},
				recoil = {
					0.35,
					0.75
				},
				mode = {
					1,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 1.25,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.4,
					1.2
				},
				mode = {
					3,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					3,
					1,
					1,
					0
				}
			}
		}
	}
	presets.weapon.expert.is_bullpup = presets.weapon.expert.is_rifle
	presets.weapon.expert.is_smg = {
		aim_delay = {
			0,
			0.1
		},
		focus_delay = 1,
		focus_dis = 200,
		spread = 15,
		miss_dis = 10,
		RELOAD_SPEED = 1.2,
		melee_speed = presets.weapon.normal.is_smg.melee_speed,
		melee_dmg = presets.weapon.normal.is_smg.melee_dmg,
		melee_retry_delay = presets.weapon.normal.is_smg.melee_retry_delay,
		range = presets.weapon.normal.is_smg.range,
		autofire_rounds = presets.weapon.normal.is_smg.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.95
				},
				recoil = {
					0.1,
					0.25
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 4.5,
				r = 500,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.1,
					0.3
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 1000,
				acc = {
					0.4,
					0.65
				},
				recoil = {
					0.35,
					0.5
				},
				mode = {
					0,
					3,
					3,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.35,
					0.7
				},
				mode = {
					0,
					3,
					3,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 3000,
				acc = {
					0.2,
					0.35
				},
				recoil = {
					0.5,
					1.5
				},
				mode = {
					1,
					3,
					2,
					0
				}
			}
		}
	}
	presets.weapon.expert.is_revolver = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 10,
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 0.9,
		melee_speed = 1,
		melee_dmg = 8,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.5,
					0.85
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2.5,
				r = 1000,
				acc = {
					0.375,
					0.55
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 2000,
				acc = {
					0.25,
					0.45
				},
				recoil = {
					1,
					1.3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1.5,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.expert.mini = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 800,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			40
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	presets.weapon.expert.is_lmg = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 3,
		focus_dis = 200,
		spread = 24,
		miss_dis = 40,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.normal.is_lmg.melee_retry_delay,
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		autofire_rounds = presets.weapon.normal.is_lmg.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.65,
					0.85
				},
				recoil = {
					0.4,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.8
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.2,
					0.7
				},
				recoil = {
					0.35,
					0.75
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1.25,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.4,
					1.2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.sniper = {
		is_rifle = {}
	}
	presets.weapon.sniper.is_rifle.aim_delay = {
		0,
		0.1
	}
	presets.weapon.sniper.is_rifle.focus_delay = 7
	presets.weapon.sniper.is_rifle.focus_dis = 200
	presets.weapon.sniper.is_rifle.spread = 30
	presets.weapon.sniper.is_rifle.miss_dis = 250
	presets.weapon.sniper.is_rifle.RELOAD_SPEED = 1.25
	presets.weapon.sniper.is_rifle.melee_speed = presets.weapon.normal.is_rifle.melee_speed
	presets.weapon.sniper.is_rifle.melee_dmg = presets.weapon.normal.is_rifle.melee_dmg
	presets.weapon.sniper.is_rifle.melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay
	presets.weapon.sniper.is_rifle.range = {
		optimal = 15000,
		far = 15000,
		close = 15000
	}
	presets.weapon.sniper.is_rifle.autofire_rounds = presets.weapon.normal.is_rifle.autofire_rounds
	presets.weapon.sniper.is_rifle.use_laser = true
	presets.weapon.sniper.is_rifle.FALLOFF = {
		{
			dmg_mul = 5,
			r = 700,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				2,
				4
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 5,
			r = 3500,
			acc = {
				0.1,
				0.75
			},
			recoil = {
				3,
				4
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 10000,
			acc = {
				0,
				0.25
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.deathwish = {
		is_revolver = {}
	}
	presets.weapon.deathwish.is_revolver.aim_delay = {
		0,
		0
	}
	presets.weapon.deathwish.is_revolver.focus_delay = 10
	presets.weapon.deathwish.is_revolver.focus_dis = 200
	presets.weapon.deathwish.is_revolver.spread = 20
	presets.weapon.deathwish.is_revolver.miss_dis = 50
	presets.weapon.deathwish.is_revolver.RELOAD_SPEED = 0.9
	presets.weapon.deathwish.is_revolver.melee_speed = 1
	presets.weapon.deathwish.is_revolver.melee_dmg = 8
	presets.weapon.deathwish.is_revolver.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.deathwish.is_revolver.range = {
		optimal = 2000,
		far = 5000,
		close = 1000
	}
	presets.weapon.deathwish.is_revolver.FALLOFF = {
		{
			dmg_mul = 5,
			r = 100,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.8,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4,
			r = 500,
			acc = {
				0.6,
				0.85
			},
			recoil = {
				0.8,
				1.1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 1000,
			acc = {
				0.5,
				0.75
			},
			recoil = {
				0.8,
				1.1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3,
			r = 2000,
			acc = {
				0.5,
				0.65
			},
			recoil = {
				1,
				1.3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.deathwish.is_pistol = {
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1.4,
		melee_speed = presets.weapon.expert.is_pistol.melee_speed,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_pistol.melee_retry_delay,
		range = {
			optimal = 3200,
			far = 5000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 6.5,
				r = 100,
				acc = {
					0.9,
					0.95
				},
				recoil = {
					0.15,
					0.25
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 6.5,
				r = 500,
				acc = {
					0.9,
					0.95
				},
				recoil = {
					0.15,
					0.3
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 6.5,
				r = 1000,
				acc = {
					0.7,
					0.8
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 6.5,
				r = 2000,
				acc = {
					0.6,
					0.7
				},
				recoil = {
					0.4,
					0.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 6,
				r = 3000,
				acc = {
					0.6,
					0.65
				},
				recoil = {
					0.6,
					0.8
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 6,
				r = 4000,
				acc = {
					0.2,
					0.65
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathwish.is_rifle = {
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1.4,
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_rifle.melee_retry_delay,
		range = {
			optimal = 3500,
			far = 6000,
			close = 2000
		},
		autofire_rounds = {
			4,
			9
		},
		FALLOFF = {
			{
				dmg_mul = 7.5,
				r = 100,
				acc = {
					0.9,
					0.975
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 7.5,
				r = 500,
				acc = {
					0.875,
					0.95
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					3,
					8,
					1
				}
			},
			{
				dmg_mul = 7.5,
				r = 1000,
				acc = {
					0.7,
					0.9
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					0,
					2,
					5,
					1
				}
			},
			{
				dmg_mul = 7.5,
				r = 2000,
				acc = {
					0.7,
					0.85
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					3,
					2,
					5,
					1
				}
			},
			{
				dmg_mul = 7.5,
				r = 3000,
				acc = {
					0.65,
					0.75
				},
				recoil = {
					0.7,
					1.1
				},
				mode = {
					3,
					1,
					5,
					0.5
				}
			},
			{
				dmg_mul = 7.5,
				r = 6000,
				acc = {
					0.25,
					0.7
				},
				recoil = {
					1,
					2
				},
				mode = {
					3,
					1,
					1,
					0
				}
			}
		}
	}
	presets.weapon.deathwish.is_bullpup = presets.weapon.deathwish.is_rifle
	presets.weapon.deathwish.is_shotgun_pump = {
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.4,
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_shotgun_pump.melee_retry_delay,
		range = {
			optimal = 3000,
			far = 5000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 8,
				r = 100,
				acc = {
					0.95,
					0.95
				},
				recoil = {
					1,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 7.5,
				r = 500,
				acc = {
					0.7,
					0.95
				},
				recoil = {
					1,
					1.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 7,
				r = 1000,
				acc = {
					0.5,
					0.8
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 5,
				r = 2000,
				acc = {
					0.45,
					0.65
				},
				recoil = {
					1.25,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.3,
					0.5
				},
				recoil = {
					1.5,
					1.75
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathwish.is_shotgun_mag = presets.weapon.deathwish.is_shotgun_pump
	presets.weapon.deathwish.is_smg = {
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 15,
		miss_dis = 10,
		RELOAD_SPEED = 1.4,
		melee_speed = presets.weapon.expert.is_smg.melee_speed,
		melee_dmg = presets.weapon.expert.is_smg.melee_dmg,
		melee_retry_delay = presets.weapon.expert.is_smg.melee_retry_delay,
		range = {
			optimal = 3200,
			far = 6000,
			close = 2000
		},
		autofire_rounds = {
			8,
			16
		},
		FALLOFF = {
			{
				dmg_mul = 6.75,
				r = 100,
				acc = {
					0.95,
					0.95
				},
				recoil = {
					0.1,
					0.25
				},
				mode = {
					0,
					3,
					3,
					4
				}
			},
			{
				dmg_mul = 6.75,
				r = 500,
				acc = {
					0.75,
					0.75
				},
				recoil = {
					0.1,
					0.3
				},
				mode = {
					0,
					3,
					3,
					4
				}
			},
			{
				dmg_mul = 6.75,
				r = 1000,
				acc = {
					0.65,
					0.65
				},
				recoil = {
					0.35,
					0.5
				},
				mode = {
					0,
					6,
					3,
					3
				}
			},
			{
				dmg_mul = 6.75,
				r = 2000,
				acc = {
					0.6,
					0.7
				},
				recoil = {
					0.35,
					0.5
				},
				mode = {
					0,
					6,
					3,
					0
				}
			},
			{
				dmg_mul = 6.75,
				r = 3000,
				acc = {
					0.55,
					0.6
				},
				recoil = {
					0.5,
					1.5
				},
				mode = {
					1,
					6,
					2,
					0
				}
			},
			{
				dmg_mul = 6.75,
				r = 4500,
				acc = {
					0.3,
					0.6
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					3,
					2,
					0
				}
			}
		}
	}
	presets.weapon.deathwish.mini = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 800,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			40
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	presets.weapon.deathwish.is_lmg = {
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 24,
		miss_dis = 40,
		RELOAD_SPEED = 0.75,
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_lmg.melee_retry_delay,
		range = {
			optimal = 3500,
			far = 6000,
			close = 2000
		},
		autofire_rounds = {
			25,
			50
		},
		FALLOFF = {
			{
				dmg_mul = 4,
				r = 100,
				acc = {
					0.8,
					0.9
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.75,
					0.9
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 1000,
				acc = {
					0.5,
					0.8
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 2000,
				acc = {
					0.4,
					0.65
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.2,
					0.35
				},
				recoil = {
					0.7,
					1.1
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0.35,
				r = 6000,
				acc = {
					0.1,
					0.2
				},
				recoil = {
					1,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.easywish = {
		is_revolver = {}
	}
	presets.weapon.easywish.is_revolver.aim_delay = {
		0,
		0
	}
	presets.weapon.easywish.is_revolver.focus_delay = 10
	presets.weapon.easywish.is_revolver.focus_dis = 200
	presets.weapon.easywish.is_revolver.spread = 20
	presets.weapon.easywish.is_revolver.miss_dis = 50
	presets.weapon.easywish.is_revolver.RELOAD_SPEED = 0.9
	presets.weapon.easywish.is_revolver.melee_speed = 1
	presets.weapon.easywish.is_revolver.melee_dmg = 8
	presets.weapon.easywish.is_revolver.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.easywish.is_revolver.range = {
		optimal = 2000,
		far = 5000,
		close = 1000
	}
	presets.weapon.easywish.is_revolver.FALLOFF = {
		{
			dmg_mul = 5,
			r = 100,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.8,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4,
			r = 500,
			acc = {
				0.6,
				0.85
			},
			recoil = {
				0.8,
				1.1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3,
			r = 1000,
			acc = {
				0.5,
				0.75
			},
			recoil = {
				0.8,
				1.1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3,
			r = 2000,
			acc = {
				0.5,
				0.65
			},
			recoil = {
				1,
				1.3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.easywish.is_pistol = {
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1.4,
		melee_speed = presets.weapon.expert.is_pistol.melee_speed,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_pistol.melee_retry_delay,
		range = {
			optimal = 3200,
			far = 5000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.9,
					0.95
				},
				recoil = {
					0.15,
					0.25
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 5,
				r = 500,
				acc = {
					0.9,
					0.95
				},
				recoil = {
					0.15,
					0.3
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 1000,
				acc = {
					0.7,
					0.8
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					1,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 2000,
				acc = {
					0.6,
					0.7
				},
				recoil = {
					0.4,
					0.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 3000,
				acc = {
					0.6,
					0.65
				},
				recoil = {
					0.6,
					0.8
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 4000,
				acc = {
					0.2,
					0.65
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 5000,
				acc = {
					0.1,
					0.5
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.easywish.is_rifle = {
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1.4,
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_rifle.melee_retry_delay,
		range = {
			optimal = 3500,
			far = 6000,
			close = 2000
		},
		autofire_rounds = {
			4,
			9
		},
		FALLOFF = {
			{
				dmg_mul = 5.25,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 4.75,
				r = 500,
				acc = {
					0.4,
					0.9
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					3,
					8,
					1
				}
			},
			{
				dmg_mul = 4.5,
				r = 1000,
				acc = {
					0.2,
					0.8
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					0,
					2,
					5,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					3,
					2,
					5,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 3000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					0.7,
					1.1
				},
				mode = {
					3,
					1,
					5,
					0.5
				}
			},
			{
				dmg_mul = 3,
				r = 6000,
				acc = {
					0.01,
					0.35
				},
				recoil = {
					1,
					2
				},
				mode = {
					3,
					1,
					1,
					0
				}
			}
		}
	}
	presets.weapon.easywish.is_bullpup = presets.weapon.easywish.is_rifle
	presets.weapon.easywish.is_shotgun_pump = {
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.4,
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_shotgun_pump.melee_retry_delay,
		range = {
			optimal = 3000,
			far = 5000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 5.5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					1,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4.75,
				r = 500,
				acc = {
					0.4,
					0.95
				},
				recoil = {
					1,
					1.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 1000,
				acc = {
					0.2,
					0.75
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 2000,
				acc = {
					0.2,
					0.75
				},
				recoil = {
					1.25,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.2,
					0.75
				},
				recoil = {
					1.5,
					1.75
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.easywish.is_shotgun_mag = presets.weapon.easywish.is_shotgun_pump
	presets.weapon.easywish.is_smg = {
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 15,
		miss_dis = 10,
		RELOAD_SPEED = 1.4,
		melee_speed = presets.weapon.expert.is_smg.melee_speed,
		melee_dmg = presets.weapon.expert.is_smg.melee_dmg,
		melee_retry_delay = presets.weapon.expert.is_smg.melee_retry_delay,
		range = {
			optimal = 3200,
			far = 6000,
			close = 2000
		},
		autofire_rounds = {
			8,
			16
		},
		FALLOFF = {
			{
				dmg_mul = 6,
				r = 100,
				acc = {
					0.95,
					0.95
				},
				recoil = {
					0.1,
					0.25
				},
				mode = {
					0,
					3,
					3,
					4
				}
			},
			{
				dmg_mul = 5,
				r = 500,
				acc = {
					0.6,
					0.75
				},
				recoil = {
					0.1,
					0.3
				},
				mode = {
					0,
					3,
					3,
					4
				}
			},
			{
				dmg_mul = 5,
				r = 1000,
				acc = {
					0.5,
					0.65
				},
				recoil = {
					0.35,
					0.5
				},
				mode = {
					0,
					6,
					3,
					3
				}
			},
			{
				dmg_mul = 4,
				r = 2000,
				acc = {
					0.5,
					0.6
				},
				recoil = {
					0.35,
					0.5
				},
				mode = {
					0,
					6,
					3,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 3000,
				acc = {
					0.5,
					0.6
				},
				recoil = {
					0.5,
					1.5
				},
				mode = {
					1,
					6,
					2,
					0
				}
			},
			{
				dmg_mul = 4,
				r = 4500,
				acc = {
					0.3,
					0.6
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					3,
					2,
					0
				}
			}
		}
	}
	presets.weapon.easywish.mini = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 800,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			40
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	presets.weapon.easywish.is_lmg = {
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.7,
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_lmg.melee_retry_delay,
		range = {
			optimal = 3500,
			far = 6000,
			close = 2000
		},
		autofire_rounds = {
			25,
			40
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.7,
					0.8
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2.5,
				r = 500,
				acc = {
					0.65,
					0.8
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 1000,
				acc = {
					0.55,
					0.75
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.2,
					0.35
				},
				recoil = {
					0.7,
					1.1
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0.25,
				r = 6000,
				acc = {
					0.01,
					0.2
				},
				recoil = {
					1,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.gang_member = {
		is_pistol = {}
	}
	presets.weapon.gang_member.is_pistol.aim_delay = {
		0,
		0.5
	}
	presets.weapon.gang_member.is_pistol.focus_delay = 1
	presets.weapon.gang_member.is_pistol.focus_dis = 2000
	presets.weapon.gang_member.is_pistol.spread = 25
	presets.weapon.gang_member.is_pistol.miss_dis = 20
	presets.weapon.gang_member.is_pistol.RELOAD_SPEED = 1.5
	presets.weapon.gang_member.is_pistol.melee_speed = 3
	presets.weapon.gang_member.is_pistol.melee_dmg = 3
	presets.weapon.gang_member.is_pistol.melee_retry_delay = presets.weapon.normal.is_pistol.melee_retry_delay
	presets.weapon.gang_member.is_pistol.range = presets.weapon.normal.is_pistol.range
	presets.weapon.gang_member.is_pistol.FALLOFF = {
		{
			dmg_mul = 5,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 2.5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	presets.weapon.gang_member.is_rifle = {
		aim_delay = {
			0,
			0.5
		},
		focus_delay = 1,
		focus_dis = 3000,
		spread = 25,
		miss_dis = 10,
		RELOAD_SPEED = 1,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay,
		range = {
			optimal = 2500,
			far = 6000,
			close = 1500
		},
		autofire_rounds = presets.weapon.normal.is_rifle.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 300,
				acc = {
					1,
					1
				},
				recoil = {
					0.25,
					0.45
				},
				mode = {
					0.1,
					0.3,
					4,
					7
				}
			},
			{
				dmg_mul = 2.5,
				r = 10000,
				acc = {
					1,
					1
				},
				recoil = {
					2,
					3
				},
				mode = {
					0.1,
					0.3,
					4,
					7
				}
			}
		}
	}
	presets.weapon.gang_member.is_sniper = {
		aim_delay = {
			0.25,
			1
		},
		focus_delay = 1,
		focus_dis = 3000,
		spread = 25,
		miss_dis = 10,
		RELOAD_SPEED = 1,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay,
		range = {
			optimal = 4000,
			far = 6000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 10,
				r = 500,
				acc = {
					1,
					1
				},
				recoil = {
					1,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 10,
				r = 1000,
				acc = {
					1,
					1
				},
				recoil = {
					1,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 10,
				r = 2500,
				acc = {
					0.95,
					1
				},
				recoil = {
					1,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 5,
				r = 4000,
				acc = {
					0.9,
					0.95
				},
				recoil = {
					1,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 5,
				r = 10000,
				acc = {
					0.85,
					0.9
				},
				recoil = {
					1,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.gang_member.is_lmg = {
		aim_delay = {
			0,
			0.5
		},
		focus_delay = 1,
		focus_dis = 3000,
		spread = 30,
		miss_dis = 10,
		RELOAD_SPEED = 0.7,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_lmg.melee_retry_delay,
		range = {
			optimal = 2500,
			far = 6000,
			close = 1500
		},
		autofire_rounds = presets.weapon.normal.is_lmg.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 4,
				r = 100,
				acc = {
					1,
					1
				},
				recoil = {
					0.25,
					0.45
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 1000,
				acc = {
					0.85,
					0.9
				},
				recoil = {
					0.4,
					0.65
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 2000,
				acc = {
					0.6,
					0.8
				},
				recoil = {
					0.8,
					1.25
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 3000,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.8,
					1.25
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0.4,
				r = 4000,
				acc = {
					0.02,
					0.25
				},
				recoil = {
					1,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0.25,
				r = 10000,
				acc = {
					0.01,
					0.1
				},
				recoil = {
					2,
					3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.gang_member.is_shotgun_pump = {
		aim_delay = {
			0,
			0.25
		},
		focus_delay = 1,
		focus_dis = 2000,
		spread = 15,
		miss_dis = 10,
		RELOAD_SPEED = 2,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_shotgun_pump.melee_retry_delay,
		range = presets.weapon.normal.is_shotgun_pump.range,
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 300,
				acc = {
					1,
					1
				},
				recoil = {
					0.25,
					0.45
				},
				mode = {
					0.1,
					0.3,
					4,
					7
				}
			},
			{
				dmg_mul = 2.5,
				r = 10000,
				acc = {
					1,
					1
				},
				recoil = {
					2,
					3
				},
				mode = {
					0.1,
					0.3,
					4,
					7
				}
			}
		}
	}
	presets.weapon.gang_member.is_shotgun_mag = {
		aim_delay = {
			0,
			0.25
		},
		focus_delay = 1,
		focus_dis = 2000,
		spread = 18,
		miss_dis = 10,
		RELOAD_SPEED = 1.6,
		melee_speed = 2,
		melee_dmg = 3,
		melee_retry_delay = presets.weapon.normal.is_shotgun_mag.melee_retry_delay,
		range = presets.weapon.normal.is_shotgun_mag.range,
		autofire_rounds = {
			4,
			8
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					1,
					1
				},
				recoil = {
					0.1,
					0.1
				},
				mode = {
					1,
					1,
					4,
					6
				}
			},
			{
				dmg_mul = 5,
				r = 500,
				acc = {
					1,
					1
				},
				recoil = {
					0.1,
					0.1
				},
				mode = {
					1,
					1,
					4,
					5
				}
			},
			{
				dmg_mul = 4,
				r = 1000,
				acc = {
					0.85,
					0.95
				},
				recoil = {
					0.1,
					0.15
				},
				mode = {
					1,
					2,
					4,
					4
				}
			},
			{
				dmg_mul = 1.5,
				r = 2000,
				acc = {
					0.75,
					0.9
				},
				recoil = {
					0.25,
					0.45
				},
				mode = {
					1,
					4,
					4,
					1
				}
			},
			{
				dmg_mul = 0.5,
				r = 3000,
				acc = {
					0.4,
					0.7
				},
				recoil = {
					0.4,
					0.5
				},
				mode = {
					4,
					2,
					1,
					0
				}
			},
			{
				dmg_mul = 0.1,
				r = 10000,
				acc = {
					0.05,
					0.2
				},
				recoil = {
					0.5,
					1
				},
				mode = {
					2,
					1,
					0,
					0
				}
			}
		}
	}
	presets.weapon.gang_member.is_smg = presets.weapon.gang_member.is_rifle
	presets.weapon.gang_member.is_pistol = presets.weapon.gang_member.is_pistol
	presets.weapon.gang_member.is_revolver = presets.weapon.gang_member.is_pistol
	presets.weapon.gang_member.is_bullpup = presets.weapon.gang_member.is_rifle
	presets.weapon.gang_member.mac11 = presets.weapon.gang_member.is_smg
	presets.weapon.gang_member.rifle = deep_clone(presets.weapon.gang_member.is_rifle)
	presets.weapon.gang_member.rifle.autofire_rounds = nil
	presets.weapon.gang_member.akimbo_pistol = presets.weapon.gang_member.is_pistol
	presets.detection = {
		normal = {
			idle = {},
			combat = {},
			recon = {},
			guard = {},
			ntl = {}
		}
	}
	presets.detection.normal.idle.dis_max = 10000
	presets.detection.normal.idle.angle_max = 120
	presets.detection.normal.idle.delay = {
		0,
		0
	}
	presets.detection.normal.idle.use_uncover_range = true
	presets.detection.normal.combat.dis_max = 10000
	presets.detection.normal.combat.angle_max = 120
	presets.detection.normal.combat.delay = {
		0,
		0
	}
	presets.detection.normal.combat.use_uncover_range = true
	presets.detection.normal.recon.dis_max = 10000
	presets.detection.normal.recon.angle_max = 120
	presets.detection.normal.recon.delay = {
		0,
		0
	}
	presets.detection.normal.recon.use_uncover_range = true
	presets.detection.normal.guard.dis_max = 10000
	presets.detection.normal.guard.angle_max = 120
	presets.detection.normal.guard.delay = {
		0,
		0
	}
	presets.detection.normal.ntl.dis_max = 4000
	presets.detection.normal.ntl.angle_max = 60
	presets.detection.normal.ntl.delay = {
		0.2,
		2
	}
	presets.detection.guard = {
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.guard.idle.dis_max = 10000
	presets.detection.guard.idle.angle_max = 120
	presets.detection.guard.idle.delay = {
		0,
		0
	}
	presets.detection.guard.idle.use_uncover_range = true
	presets.detection.guard.combat.dis_max = 10000
	presets.detection.guard.combat.angle_max = 120
	presets.detection.guard.combat.delay = {
		0,
		0
	}
	presets.detection.guard.combat.use_uncover_range = true
	presets.detection.guard.recon.dis_max = 10000
	presets.detection.guard.recon.angle_max = 120
	presets.detection.guard.recon.delay = {
		0,
		0
	}
	presets.detection.guard.recon.use_uncover_range = true
	presets.detection.guard.guard.dis_max = 10000
	presets.detection.guard.guard.angle_max = 120
	presets.detection.guard.guard.delay = {
		0,
		0
	}
	presets.detection.guard.ntl = presets.detection.normal.ntl
	presets.detection.sniper = {
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.sniper.idle.dis_max = 10000
	presets.detection.sniper.idle.angle_max = 180
	presets.detection.sniper.idle.delay = {
		0.5,
		1
	}
	presets.detection.sniper.idle.use_uncover_range = true
	presets.detection.sniper.combat.dis_max = 10000
	presets.detection.sniper.combat.angle_max = 120
	presets.detection.sniper.combat.delay = {
		0.5,
		1
	}
	presets.detection.sniper.combat.use_uncover_range = true
	presets.detection.sniper.recon.dis_max = 10000
	presets.detection.sniper.recon.angle_max = 120
	presets.detection.sniper.recon.delay = {
		0.5,
		1
	}
	presets.detection.sniper.recon.use_uncover_range = true
	presets.detection.sniper.guard.dis_max = 10000
	presets.detection.sniper.guard.angle_max = 150
	presets.detection.sniper.guard.delay = {
		0.3,
		1
	}
	presets.detection.sniper.ntl = presets.detection.normal.ntl
	presets.detection.gang_member = {
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.gang_member.idle.dis_max = 10000
	presets.detection.gang_member.idle.angle_max = 120
	presets.detection.gang_member.idle.delay = {
		0,
		0
	}
	presets.detection.gang_member.idle.use_uncover_range = true
	presets.detection.gang_member.combat.dis_max = 10000
	presets.detection.gang_member.combat.angle_max = 120
	presets.detection.gang_member.combat.delay = {
		0,
		0
	}
	presets.detection.gang_member.combat.use_uncover_range = true
	presets.detection.gang_member.recon.dis_max = 10000
	presets.detection.gang_member.recon.angle_max = 120
	presets.detection.gang_member.recon.delay = {
		0,
		0
	}
	presets.detection.gang_member.recon.use_uncover_range = true
	presets.detection.gang_member.guard.dis_max = 10000
	presets.detection.gang_member.guard.angle_max = 120
	presets.detection.gang_member.guard.delay = {
		0,
		0
	}
	presets.detection.gang_member.ntl = presets.detection.normal.ntl
	presets.detection.civilian = {
		cbt = {},
		ntl = {}
	}
	presets.detection.civilian.cbt.dis_max = 700
	presets.detection.civilian.cbt.angle_max = 120
	presets.detection.civilian.cbt.delay = {
		0,
		0
	}
	presets.detection.civilian.cbt.use_uncover_range = true
	presets.detection.civilian.ntl.dis_max = 2000
	presets.detection.civilian.ntl.angle_max = 60
	presets.detection.civilian.ntl.delay = {
		0.2,
		3
	}
	presets.detection.blind = {
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.blind.idle.dis_max = 1
	presets.detection.blind.idle.angle_max = 0
	presets.detection.blind.idle.delay = {
		0,
		0
	}
	presets.detection.blind.idle.use_uncover_range = false
	presets.detection.blind.combat.dis_max = 1
	presets.detection.blind.combat.angle_max = 0
	presets.detection.blind.combat.delay = {
		0,
		0
	}
	presets.detection.blind.combat.use_uncover_range = false
	presets.detection.blind.recon.dis_max = 1
	presets.detection.blind.recon.angle_max = 0
	presets.detection.blind.recon.delay = {
		0,
		0
	}
	presets.detection.blind.recon.use_uncover_range = false
	presets.detection.blind.guard.dis_max = 1
	presets.detection.blind.guard.angle_max = 0
	presets.detection.blind.guard.delay = {
		0,
		0
	}
	presets.detection.blind.guard.use_uncover_range = false
	presets.detection.blind.ntl.dis_max = 1
	presets.detection.blind.ntl.angle_max = 0
	presets.detection.blind.ntl.delay = {
		0,
		0
	}
	presets.detection.blind.ntl.use_uncover_range = false
	presets.dodge = {
		poor = {
			speed = 0.9,
			occasions = {
				hit = {
					chance = 0.9,
					check_timeout = {
						0,
						0
					},
					variations = {
						side_step = {
							chance = 1,
							timeout = {
								2,
								3
							}
						}
					}
				},
				scared = {
					chance = 0.5,
					check_timeout = {
						1,
						2
					},
					variations = {
						side_step = {
							chance = 1,
							timeout = {
								2,
								3
							}
						}
					}
				}
			}
		},
		average = {
			speed = 1,
			occasions = {
				hit = {
					chance = 0.35,
					check_timeout = {
						0,
						0
					},
					variations = {
						side_step = {
							chance = 1,
							timeout = {
								2,
								3
							}
						}
					}
				},
				scared = {
					chance = 0.4,
					check_timeout = {
						4,
						7
					},
					variations = {
						dive = {
							chance = 1,
							timeout = {
								5,
								8
							}
						}
					}
				}
			}
		},
		heavy = {
			speed = 1,
			occasions = {
				hit = {
					chance = 0.75,
					check_timeout = {
						0,
						0
					},
					variations = {
						side_step = {
							chance = 9,
							shoot_chance = 0.8,
							shoot_accuracy = 0.5,
							timeout = {
								0,
								7
							}
						},
						roll = {
							chance = 1,
							timeout = {
								8,
								10
							}
						}
					}
				},
				preemptive = {
					chance = 0.1,
					check_timeout = {
						1,
						7
					},
					variations = {
						side_step = {
							chance = 1,
							shoot_chance = 1,
							shoot_accuracy = 0.7,
							timeout = {
								1,
								7
							}
						}
					}
				},
				scared = {
					chance = 0.8,
					check_timeout = {
						1,
						2
					},
					variations = {
						side_step = {
							chance = 5,
							shoot_chance = 0.5,
							shoot_accuracy = 0.4,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 1,
							timeout = {
								8,
								10
							}
						},
						dive = {
							chance = 2,
							timeout = {
								8,
								10
							}
						}
					}
				}
			}
		},
		athletic = {
			speed = 1.3,
			occasions = {
				hit = {
					chance = 0.9,
					check_timeout = {
						0,
						0
					},
					variations = {
						side_step = {
							chance = 5,
							shoot_chance = 0.8,
							shoot_accuracy = 0.5,
							timeout = {
								1,
								3
							}
						},
						roll = {
							chance = 1,
							timeout = {
								3,
								4
							}
						}
					}
				},
				preemptive = {
					chance = 0.35,
					check_timeout = {
						2,
						3
					},
					variations = {
						side_step = {
							chance = 3,
							shoot_chance = 1,
							shoot_accuracy = 0.7,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 1,
							timeout = {
								3,
								4
							}
						}
					}
				},
				scared = {
					chance = 0.4,
					check_timeout = {
						1,
						2
					},
					variations = {
						side_step = {
							chance = 5,
							shoot_chance = 0.5,
							shoot_accuracy = 0.4,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 3,
							timeout = {
								3,
								5
							}
						},
						dive = {
							chance = 1,
							timeout = {
								3,
								5
							}
						}
					}
				}
			}
		},
		ninja = {
			speed = 1.6,
			occasions = {
				hit = {
					chance = 0.9,
					check_timeout = {
						0,
						3
					},
					variations = {
						side_step = {
							chance = 3,
							shoot_chance = 1,
							shoot_accuracy = 0.7,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 1,
							timeout = {
								1.2,
								2
							}
						},
						wheel = {
							chance = 2,
							timeout = {
								1.2,
								2
							}
						}
					}
				},
				preemptive = {
					chance = 0.6,
					check_timeout = {
						0,
						3
					},
					variations = {
						side_step = {
							chance = 3,
							shoot_chance = 1,
							shoot_accuracy = 0.8,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 1,
							timeout = {
								1.2,
								2
							}
						},
						wheel = {
							chance = 2,
							timeout = {
								1.2,
								2
							}
						}
					}
				},
				scared = {
					chance = 0.9,
					check_timeout = {
						0,
						3
					},
					variations = {
						side_step = {
							chance = 5,
							shoot_chance = 0.8,
							shoot_accuracy = 0.6,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 3,
							timeout = {
								1.2,
								2
							}
						},
						wheel = {
							chance = 3,
							timeout = {
								1.2,
								2
							}
						},
						dive = {
							chance = 1,
							timeout = {
								1.2,
								2
							}
						}
					}
				}
			}
		}
	}

	for preset_name, preset_data in pairs(presets.dodge) do
		for reason_name, reason_data in pairs(preset_data.occasions) do
			local total_w = 0

			for variation_name, variation_data in pairs(reason_data.variations) do
				total_w = total_w + variation_data.chance
			end

			if total_w > 0 then
				for variation_name, variation_data in pairs(reason_data.variations) do
					variation_data.chance = variation_data.chance / total_w
				end
			end
		end
	end

	presets.move_speed = {
		civ_fast = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 150,
						bwd = 100
					},
					hos = {
						strafe = 190,
						fwd = 210,
						bwd = 160
					},
					cbt = {
						strafe = 175,
						fwd = 210,
						bwd = 160
					}
				},
				run = {
					hos = {
						strafe = 192,
						fwd = 500,
						bwd = 230
					},
					cbt = {
						strafe = 250,
						fwd = 500,
						bwd = 230
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 160,
						fwd = 174,
						bwd = 163
					},
					cbt = {
						strafe = 160,
						fwd = 174,
						bwd = 163
					}
				},
				run = {
					hos = {
						strafe = 245,
						fwd = 312,
						bwd = 260
					},
					cbt = {
						strafe = 245,
						fwd = 312,
						bwd = 260
					}
				}
			}
		},
		lightning = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 150,
						bwd = 110
					},
					hos = {
						strafe = 225,
						fwd = 285,
						bwd = 215
					},
					cbt = {
						strafe = 225,
						fwd = 285,
						bwd = 215
					}
				},
				run = {
					hos = {
						strafe = 400,
						fwd = 800,
						bwd = 350
					},
					cbt = {
						strafe = 380,
						fwd = 750,
						bwd = 320
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 210,
						fwd = 245,
						bwd = 190
					},
					cbt = {
						strafe = 190,
						fwd = 255,
						bwd = 190
					}
				},
				run = {
					hos = {
						strafe = 300,
						fwd = 420,
						bwd = 250
					},
					cbt = {
						strafe = 300,
						fwd = 412,
						bwd = 280
					}
				}
			}
		},
		very_slow = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					hos = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					}
				},
				run = {
					hos = {
						strafe = 140,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 100,
						fwd = 144,
						bwd = 125
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					}
				},
				run = {
					hos = {
						strafe = 130,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 100,
						fwd = 144,
						bwd = 125
					}
				}
			}
		},
		slow = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					hos = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					}
				},
				run = {
					hos = {
						strafe = 150,
						fwd = 360,
						bwd = 135
					},
					cbt = {
						strafe = 150,
						fwd = 360,
						bwd = 155
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					}
				},
				run = {
					hos = {
						strafe = 140,
						fwd = 360,
						bwd = 150
					},
					cbt = {
						strafe = 140,
						fwd = 360,
						bwd = 155
					}
				}
			}
		},
		normal = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 150,
						bwd = 100
					},
					hos = {
						strafe = 190,
						fwd = 220,
						bwd = 170
					},
					cbt = {
						strafe = 190,
						fwd = 220,
						bwd = 170
					}
				},
				run = {
					hos = {
						strafe = 290,
						fwd = 450,
						bwd = 255
					},
					cbt = {
						strafe = 250,
						fwd = 400,
						bwd = 255
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 170,
						fwd = 210,
						bwd = 160
					},
					cbt = {
						strafe = 170,
						fwd = 210,
						bwd = 160
					}
				},
				run = {
					hos = {
						strafe = 260,
						fwd = 310,
						bwd = 235
					},
					cbt = {
						strafe = 260,
						fwd = 350,
						bwd = 235
					}
				}
			}
		},
		fast = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 150,
						bwd = 110
					},
					hos = {
						strafe = 215,
						fwd = 270,
						bwd = 185
					},
					cbt = {
						strafe = 215,
						fwd = 270,
						bwd = 185
					}
				},
				run = {
					hos = {
						strafe = 315,
						fwd = 625,
						bwd = 280
					},
					cbt = {
						strafe = 285,
						fwd = 450,
						bwd = 280
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 180,
						fwd = 235,
						bwd = 170
					},
					cbt = {
						strafe = 180,
						fwd = 235,
						bwd = 170
					}
				},
				run = {
					hos = {
						strafe = 280,
						fwd = 330,
						bwd = 255
					},
					cbt = {
						strafe = 270,
						fwd = 312,
						bwd = 255
					}
				}
			}
		},
		very_fast = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 150,
						bwd = 110
					},
					hos = {
						strafe = 225,
						fwd = 285,
						bwd = 215
					},
					cbt = {
						strafe = 225,
						fwd = 285,
						bwd = 215
					}
				},
				run = {
					hos = {
						strafe = 340,
						fwd = 670,
						bwd = 325
					},
					cbt = {
						strafe = 325,
						fwd = 475,
						bwd = 300
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 210,
						fwd = 245,
						bwd = 190
					},
					cbt = {
						strafe = 190,
						fwd = 255,
						bwd = 190
					}
				},
				run = {
					hos = {
						strafe = 282,
						fwd = 350,
						bwd = 268
					},
					cbt = {
						strafe = 282,
						fwd = 312,
						bwd = 268
					}
				}
			}
		}
	}

	for speed_preset_name, poses in pairs(presets.move_speed) do
		for pose, hastes in pairs(poses) do
			hastes.run.ntl = hastes.run.hos
		end

		poses.crouch.walk.ntl = poses.crouch.walk.hos
		poses.crouch.run.ntl = poses.crouch.run.hos
		poses.stand.run.ntl = poses.stand.run.hos
		poses.panic = poses.stand
	end

	presets.surrender = {
		always = {
			base_chance = 1
		},
		never = {
			base_chance = 0
		},
		easy = {
			base_chance = 0.3,
			significant_chance = 0.35,
			reasons = {
				pants_down = 1,
				isolated = 0.08,
				weapon_down = 0.5,
				health = {
					[1.0] = 0.1,
					[0.999] = 0.9
				}
			},
			factors = {
				unaware_of_aggressor = 0.1,
				enemy_weap_cold = 0.11,
				flanked = 0.05,
				aggressor_dis = {
					[300.0] = 0.2,
					[1000.0] = 0
				}
			}
		},
		normal = {
			base_chance = 0.3,
			significant_chance = 0.35,
			reasons = {
				health = {
					[1.0] = 0.1,
					[0.999] = 0.9
				}
			},
			factors = {}
		},
		hard = {
			base_chance = 0.35,
			significant_chance = 0.25,
			violence_timeout = 2,
			reasons = {
				pants_down = 0.8,
				weapon_down = 0.2,
				health = {
					[1.0] = 0,
					[0.35] = 0.5
				}
			},
			factors = {
				enemy_weap_cold = 0.05,
				unaware_of_aggressor = 0.1,
				flanked = 0.04,
				isolated = 0.1,
				aggressor_dis = {
					[300.0] = 0.1,
					[1000.0] = 0
				}
			}
		},
		special = {
			base_chance = 0.25,
			significant_chance = 0.25,
			violence_timeout = 2,
			reasons = {
				pants_down = 0.6,
				weapon_down = 0.02,
				health = {
					[0.5] = 0,
					[0.2] = 0.25
				}
			},
			factors = {
				enemy_weap_cold = 0.05,
				unaware_of_aggressor = 0.02,
				isolated = 0.05,
				flanked = 0.015
			}
		}
	}
	presets.suppression = {
		easy = {
			panic_chance_mul = 1,
			duration = {
				10,
				15
			},
			react_point = {
				0,
				2
			},
			brown_point = {
				3,
				5
			}
		},
		hard_def = {
			panic_chance_mul = 0.7,
			duration = {
				5,
				10
			},
			react_point = {
				0,
				2
			},
			brown_point = {
				5,
				6
			}
		},
		hard_agg = {
			panic_chance_mul = 0.7,
			duration = {
				5,
				8
			},
			react_point = {
				2,
				5
			},
			brown_point = {
				5,
				6
			}
		},
		no_supress = {
			panic_chance_mul = 0,
			duration = {
				0.1,
				0.15
			},
			react_point = {
				100,
				200
			},
			brown_point = {
				400,
				500
			}
		}
	}
	presets.enemy_chatter = {
		no_chatter = {},
		cop = {
			retreat = true,
			aggressive = true,
			go_go = true,
			contact = true,
			suppress = true
		},
		swat = {
			clear = true,
			ready = true,
			contact = true,
			suppress = true,
			smoke = true,
			retreat = true,
			go_go = true,
			aggressive = true,
			follow_me = true
		},
		shield = {
			follow_me = true
		}
	}

	return presets
end

function CharacterTweakData:_create_table_structure()
	self.weap_ids = {
		"beretta92",
		"c45",
		"raging_bull",
		"m4",
		"m4_yellow",
		"ak47",
		"r870",
		"mossberg",
		"mp5",
		"mp5_tactical",
		"mp9",
		"mac11",
		"m14_sniper_npc",
		"saiga",
		"m249",
		"benelli",
		"g36",
		"ump",
		"scar_murky",
		"rpk_lmg",
		"svd_snp",
		"akmsu_smg",
		"asval_smg",
		"sr2_smg",
		"ak47_ass",
		"x_c45",
		"sg417",
		"svdsil_snp",
		"mini",
		"heavy_zeal_sniper",
		"smoke"
	}
	self.weap_unit_names = {
		Idstring("units/payday2/weapons/wpn_npc_beretta92/wpn_npc_beretta92"),
		Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45"),
		Idstring("units/payday2/weapons/wpn_npc_raging_bull/wpn_npc_raging_bull"),
		Idstring("units/payday2/weapons/wpn_npc_m4/wpn_npc_m4"),
		Idstring("units/payday2/weapons/wpn_npc_m4_yellow/wpn_npc_m4_yellow"),
		Idstring("units/payday2/weapons/wpn_npc_ak47/wpn_npc_ak47"),
		Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870"),
		Idstring("units/payday2/weapons/wpn_npc_sawnoff_shotgun/wpn_npc_sawnoff_shotgun"),
		Idstring("units/payday2/weapons/wpn_npc_mp5/wpn_npc_mp5"),
		Idstring("units/payday2/weapons/wpn_npc_mp5_tactical/wpn_npc_mp5_tactical"),
		Idstring("units/payday2/weapons/wpn_npc_smg_mp9/wpn_npc_smg_mp9"),
		Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11"),
		Idstring("units/payday2/weapons/wpn_npc_sniper/wpn_npc_sniper"),
		Idstring("units/payday2/weapons/wpn_npc_saiga/wpn_npc_saiga"),
		Idstring("units/payday2/weapons/wpn_npc_lmg_m249/wpn_npc_lmg_m249"),
		Idstring("units/payday2/weapons/wpn_npc_benelli/wpn_npc_benelli"),
		Idstring("units/payday2/weapons/wpn_npc_g36/wpn_npc_g36"),
		Idstring("units/payday2/weapons/wpn_npc_ump/wpn_npc_ump"),
		Idstring("units/payday2/weapons/wpn_npc_scar_murkywater/wpn_npc_scar_murkywater"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_rpk/wpn_npc_rpk"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_svd/wpn_npc_svd"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_akmsu/wpn_npc_akmsu"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_asval/wpn_npc_asval"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_sr2/wpn_npc_sr2"),
		Idstring("units/pd2_dlc_mad/weapons/wpn_npc_ak47/wpn_npc_ak47"),
		Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_x_c45"),
		Idstring("units/pd2_dlc_chico/weapons/wpn_npc_sg417/wpn_npc_sg417"),
		Idstring("units/pd2_dlc_spa/weapons/wpn_npc_svd_silenced/wpn_npc_svd_silenced"),
		Idstring("units/pd2_dlc_drm/weapons/wpn_npc_mini/wpn_npc_mini"),
		Idstring("units/pd2_dlc_drm/weapons/wpn_npc_heavy_zeal_sniper/wpn_npc_heavy_zeal_sniper"),
		Idstring("units/pd2_dlc_uno/weapons/wpn_npc_smoke/wpn_npc_smoke")
	}
end

function CharacterTweakData:_process_weapon_usage_table(weap_usage_table)
	for id, unit_data in pairs(self) do
		if type(unit_data) == "table" and unit_data.weapon then
			for weapon_id, data in pairs(unit_data.weapon) do
				if data.FALLOFF and not data.FALLOFF.normalized then
					for i_range, range_data in ipairs(data.FALLOFF) do
						local modes = range_data.mode
						local total = 0

						for i_firemode, value in ipairs(modes) do
							total = total + value
						end

						local prev_value = nil

						for i_firemode, value in ipairs(modes) do
							prev_value = (prev_value or 0) + value / total
							modes[i_firemode] = prev_value
						end
					end

					data.FALLOFF.normalized = true
				end
			end
		end
	end
end

function CharacterTweakData:enemy_list()
	return self._enemy_list
end

function CharacterTweakData:_set_easy()
	self:_multiply_all_hp(1, 1)
	self:_multiply_all_speeds(2.05, 2.1)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)

	self.presets.gang_member_damage.REGENERATE_TIME = 1.8
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.2

	self:_set_characters_weapon_preset("normal")

	self.flashbang_multiplier = 1
end

function CharacterTweakData:_set_normal()
	self:_multiply_all_hp(1, 1)
	self:_multiply_all_speeds(1.05, 1.1)

	self.shield.melee_weapon_dmg_multiplier = 0.1
	self.swat.melee_weapon_dmg_multiplier = 0.1
	self.cop.melee_weapon_dmg_multiplier = 0.1

	self:_multiply_weapon_delay(self.presets.weapon.normal, 0)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)

	self.swat.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 1,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 1000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 2000,
			acc = {
				0.2,
				0.5
			},
			recoil = {
				0.4,
				1.2
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.1,
			r = 3000,
			acc = {
				0.01,
				0.35
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.swat.weapon.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 1.5,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 1000,
			acc = {
				0.2,
				0.75
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 2000,
			acc = {
				0.01,
				0.25
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.1,
			r = 3000,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.heavy_swat.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 1,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 1000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 2000,
			acc = {
				0.2,
				0.5
			},
			recoil = {
				0.4,
				1.2
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.1,
			r = 3000,
			acc = {
				0.01,
				0.35
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.heavy_swat.weapon.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 1.5,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 1000,
			acc = {
				0.2,
				0.75
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 2000,
			acc = {
				0.01,
				0.25
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.1,
			r = 3000,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 0.22,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 0.18,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.15,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.13,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.1,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 50
	self.mobster_boss.HEALTH_INIT = 50
	self.biker_boss.HEALTH_INIT = 100
	self.chavez_boss.HEALTH_INIT = 100
	self.presets.gang_member_damage.REGENERATE_TIME = 1.5
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.2
	self.presets.gang_member_damage.HEALTH_INIT = 200

	self:_set_characters_weapon_preset("normal")

	self.presets.weapon.gang_member.is_pistol.FALLOFF = {
		{
			dmg_mul = 2,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 1,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_rifle.FALLOFF = {
		{
			dmg_mul = 2,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 1,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_sniper.FALLOFF = {
		{
			dmg_mul = 4,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4,
			r = 1000,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4,
			r = 2500,
			acc = {
				0.95,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 4000,
			acc = {
				0.9,
				0.95
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 10000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_lmg.FALLOFF = {
		{
			dmg_mul = 2,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 1.5,
			r = 1000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				0.4,
				0.65
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.6,
				0.8
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 3000,
			acc = {
				0.5,
				0.7
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.3,
			r = 4000,
			acc = {
				0.02,
				0.25
			},
			recoil = {
				1,
				2
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.1,
			r = 10000,
			acc = {
				0.01,
				0.1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0,
				0,
				0,
				1
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 2,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 1,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 2,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				6
			}
		},
		{
			dmg_mul = 2,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				5
			}
		},
		{
			dmg_mul = 1,
			r = 1000,
			acc = {
				0.85,
				0.95
			},
			recoil = {
				0.1,
				0.15
			},
			mode = {
				1,
				2,
				4,
				4
			}
		},
		{
			dmg_mul = 0.75,
			r = 2000,
			acc = {
				0.75,
				0.9
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				1,
				4,
				4,
				1
			}
		},
		{
			dmg_mul = 0.25,
			r = 3000,
			acc = {
				0.4,
				0.7
			},
			recoil = {
				0.4,
				0.5
			},
			mode = {
				4,
				2,
				1,
				0
			}
		},
		{
			dmg_mul = 0.1,
			r = 10000,
			acc = {
				0.05,
				0.2
			},
			recoil = {
				0.5,
				1
			},
			mode = {
				2,
				1,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_smg = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_revolver = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_rifle = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_shotgun_pump = self.presets.weapon.gang_member.is_shotgun_pump
	self.presets.weapon.gang_member.mac11 = self.presets.weapon.gang_member.is_smg
	self.presets.weapon.gang_member.rifle = deep_clone(self.presets.weapon.gang_member.is_rifle)
	self.presets.weapon.gang_member.rifle.autofire_rounds = nil
	self.presets.weapon.gang_member.akimbo_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_shotgun_mag = deep_clone(self.presets.weapon.gang_member.is_shotgun_pump)
	self.flashbang_multiplier = 1
	self.concussion_multiplier = 1
end

function CharacterTweakData:_set_hard()
	self:_multiply_all_hp(1, 1)
	self:_multiply_all_speeds(2.05, 2.1)

	self.shield.melee_weapon_dmg_multiplier = 0.1
	self.swat.melee_weapon_dmg_multiplier = 0.1
	self.cop.melee_weapon_dmg_multiplier = 0.1

	self:_multiply_weapon_delay(self.presets.weapon.normal, 0)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)

	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 0.44,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 0.35,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.3,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.2,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 100
	self.mobster_boss.HEALTH_INIT = 100
	self.biker_boss.HEALTH_INIT = 100
	self.chavez_boss.HEALTH_INIT = 100
	self.presets.gang_member_damage.REGENERATE_TIME = 2
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.4

	self:_set_characters_weapon_preset("normal")

	self.presets.gang_member_damage.HEALTH_INIT = 200
	self.presets.weapon.gang_member.is_pistol.FALLOFF = {
		{
			dmg_mul = 2,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 1,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_rifle.FALLOFF = {
		{
			dmg_mul = 2,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 1,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_sniper.FALLOFF = {
		{
			dmg_mul = 4,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4,
			r = 1000,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4,
			r = 2500,
			acc = {
				0.95,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 4000,
			acc = {
				0.9,
				0.95
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 10000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_lmg.FALLOFF = {
		{
			dmg_mul = 2,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 1.5,
			r = 1000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				0.4,
				0.65
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.6,
				0.8
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 3000,
			acc = {
				0.5,
				0.7
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.3,
			r = 4000,
			acc = {
				0.02,
				0.25
			},
			recoil = {
				1,
				2
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.1,
			r = 10000,
			acc = {
				0.01,
				0.1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0,
				0,
				0,
				1
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 2,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 1,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 2,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				6
			}
		},
		{
			dmg_mul = 2,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				5
			}
		},
		{
			dmg_mul = 1,
			r = 1000,
			acc = {
				0.85,
				0.95
			},
			recoil = {
				0.1,
				0.15
			},
			mode = {
				1,
				2,
				4,
				4
			}
		},
		{
			dmg_mul = 0.75,
			r = 2000,
			acc = {
				0.75,
				0.9
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				1,
				4,
				4,
				1
			}
		},
		{
			dmg_mul = 0.25,
			r = 3000,
			acc = {
				0.4,
				0.7
			},
			recoil = {
				0.4,
				0.5
			},
			mode = {
				4,
				2,
				1,
				0
			}
		},
		{
			dmg_mul = 0.1,
			r = 10000,
			acc = {
				0.05,
				0.2
			},
			recoil = {
				0.5,
				1
			},
			mode = {
				2,
				1,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_smg = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_revolver = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_rifle = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_shotgun_pump = self.presets.weapon.gang_member.is_shotgun_pump
	self.presets.weapon.gang_member.mac11 = self.presets.weapon.gang_member.is_smg
	self.presets.weapon.gang_member.rifle = deep_clone(self.presets.weapon.gang_member.is_rifle)
	self.presets.weapon.gang_member.rifle.autofire_rounds = nil
	self.presets.weapon.gang_member.akimbo_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_shotgun_mag = deep_clone(self.presets.weapon.gang_member.is_shotgun_pump)
	self.flashbang_multiplier = 1.25
	self.concussion_multiplier = 1
	self.shadow_spooc.shadow_spooc_attack_timeout = {
		8,
		10
	}
	self.spooc.spooc_attack_timeout = {
		8,
		10
	}
	self.sniper.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 7,
			r = 700,
			acc = {
				0.6,
				1
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 6,
			r = 4000,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				4,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3,
			r = 10000,
			acc = {
				0,
				0.3
			},
			recoil = {
				4,
				6
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
end

function CharacterTweakData:_set_overkill()
	self:_multiply_all_hp(2, 2)
	self:_multiply_all_speeds(2.05, 2.1)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)

	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 1.1,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 0.88,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.75,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.63,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 300
	self.mobster_boss.HEALTH_INIT = 300
	self.biker_boss.HEALTH_INIT = 300
	self.chavez_boss.HEALTH_INIT = 300
	self.phalanx_minion.HEALTH_INIT = 150
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 15
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.HEALTH_INIT = 300
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 30
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET
	self.presets.gang_member_damage.REGENERATE_TIME = 2
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.6
	self.presets.gang_member_damage.HEALTH_INIT = 300
	self.presets.weapon.gang_member.is_pistol.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 1.6,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_rifle.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 1.6,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_sniper.FALLOFF = {
		{
			dmg_mul = 7,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 7,
			r = 1000,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 7,
			r = 2500,
			acc = {
				0.95,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 4000,
			acc = {
				0.9,
				0.95
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 10000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_lmg.FALLOFF = {
		{
			dmg_mul = 3,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 1000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				0.4,
				0.65
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 1.5,
			r = 2000,
			acc = {
				0.6,
				0.8
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.5,
				0.7
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.66,
			r = 4000,
			acc = {
				0.02,
				0.25
			},
			recoil = {
				1,
				2
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.2,
			r = 10000,
			acc = {
				0.01,
				0.1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0,
				0,
				0,
				1
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 1.6,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				6
			}
		},
		{
			dmg_mul = 3.5,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				5
			}
		},
		{
			dmg_mul = 1.5,
			r = 1000,
			acc = {
				0.85,
				0.95
			},
			recoil = {
				0.1,
				0.15
			},
			mode = {
				1,
				2,
				4,
				4
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.75,
				0.9
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				1,
				4,
				4,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 3000,
			acc = {
				0.4,
				0.7
			},
			recoil = {
				0.4,
				0.5
			},
			mode = {
				4,
				2,
				1,
				0
			}
		},
		{
			dmg_mul = 0.2,
			r = 10000,
			acc = {
				0.05,
				0.2
			},
			recoil = {
				0.5,
				1
			},
			mode = {
				2,
				1,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_smg = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_revolver = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_rifle = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_shotgun_pump = self.presets.weapon.gang_member.is_shotgun_pump
	self.presets.weapon.gang_member.mac11 = self.presets.weapon.gang_member.is_smg
	self.presets.weapon.gang_member.rifle = deep_clone(self.presets.weapon.gang_member.is_rifle)
	self.presets.weapon.gang_member.rifle.autofire_rounds = nil
	self.presets.weapon.gang_member.akimbo_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_shotgun_mag = deep_clone(self.presets.weapon.gang_member.is_shotgun_pump)

	self:_set_characters_weapon_preset("good")

	self.shadow_spooc.shadow_spooc_attack_timeout = {
		6,
		8
	}
	self.spooc.spooc_attack_timeout = {
		6,
		8
	}
	self.sniper.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 8,
			r = 700,
			acc = {
				0.7,
				1
			},
			recoil = {
				3,
				6
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 6,
			r = 4000,
			acc = {
				0.5,
				0.95
			},
			recoil = {
				4,
				6
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 10000,
			acc = {
				0,
				0.3
			},
			recoil = {
				4,
				6
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.flashbang_multiplier = 1.5
	self.concussion_multiplier = 1
end

function CharacterTweakData:_set_overkill_145()
	if SystemInfo:platform() == Idstring("PS3") then
		self:_multiply_all_hp(3, 3)
	else
		self:_multiply_all_hp(3, 3)
	end

	self:_multiply_all_speeds(2.05, 2.1)

	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 2.2,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 1.75,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1.5,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.25,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 600
	self.mobster_boss.HEALTH_INIT = 600
	self.biker_boss.HEALTH_INIT = 1800
	self.chavez_boss.HEALTH_INIT = 600
	self.phalanx_minion.HEALTH_INIT = 300
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 30
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.HEALTH_INIT = 600
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 60
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET

	self:_multiply_all_speeds(1.05, 1.05)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)

	self.presets.gang_member_damage.REGENERATE_TIME = 2
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.6
	self.presets.gang_member_damage.HEALTH_INIT = 400

	self:_set_characters_weapon_preset("expert")

	self.shadow_spooc.shadow_spooc_attack_timeout = {
		3.5,
		5
	}
	self.spooc.spooc_attack_timeout = {
		3.5,
		5
	}
	self.sniper.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 10,
			r = 700,
			acc = {
				0.7,
				1
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 10,
			r = 4000,
			acc = {
				0.6,
				0.95
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 6,
			r = 10000,
			acc = {
				0.2,
				0.5
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.flashbang_multiplier = 1.75
	self.concussion_multiplier = 1
end

function CharacterTweakData:_set_easy_wish()
	if SystemInfo:platform() == Idstring("PS3") then
		self:_multiply_all_hp(6, 2)
	else
		self:_multiply_all_hp(6, 2)
	end

	self.hector_boss.HEALTH_INIT = 900
	self.mobster_boss.HEALTH_INIT = 900
	self.biker_boss.HEALTH_INIT = 3000
	self.chavez_boss.HEALTH_INIT = 900

	self:_multiply_all_speeds(2.05, 2.1)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)

	self.presets.gang_member_damage.REGENERATE_TIME = 1.8
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.6
	self.presets.gang_member_damage.HEALTH_INIT = 400
	self.presets.weapon.gang_member.is_pistol.FALLOFF = {
		{
			dmg_mul = 10,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_rifle.FALLOFF = {
		{
			dmg_mul = 10,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_sniper.FALLOFF = {
		{
			dmg_mul = 20,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 20,
			r = 1000,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 20,
			r = 2500,
			acc = {
				0.95,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 10,
			r = 4000,
			acc = {
				0.9,
				0.95
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 10,
			r = 10000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_lmg.FALLOFF = {
		{
			dmg_mul = 10,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 7.5,
			r = 1000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				0.4,
				0.65
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 5,
			r = 2000,
			acc = {
				0.6,
				0.8
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 3,
			r = 3000,
			acc = {
				0.5,
				0.7
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 4000,
			acc = {
				0.02,
				0.25
			},
			recoil = {
				1,
				2
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 10000,
			acc = {
				0.01,
				0.1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0,
				0,
				0,
				1
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 10,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 10,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				6
			}
		},
		{
			dmg_mul = 8,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				5
			}
		},
		{
			dmg_mul = 7,
			r = 1000,
			acc = {
				0.85,
				0.95
			},
			recoil = {
				0.1,
				0.15
			},
			mode = {
				1,
				2,
				4,
				4
			}
		},
		{
			dmg_mul = 5,
			r = 2000,
			acc = {
				0.75,
				0.9
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				1,
				4,
				4,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0.4,
				0.7
			},
			recoil = {
				0.4,
				0.5
			},
			mode = {
				4,
				2,
				1,
				0
			}
		},
		{
			dmg_mul = 0.2,
			r = 10000,
			acc = {
				0.05,
				0.2
			},
			recoil = {
				0.5,
				1
			},
			mode = {
				2,
				1,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_smg = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_revolver = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_rifle = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_shotgun_pump = self.presets.weapon.gang_member.is_shotgun_pump
	self.presets.weapon.gang_member.mac11 = self.presets.weapon.gang_member.is_smg
	self.presets.weapon.gang_member.rifle = deep_clone(self.presets.weapon.gang_member.is_rifle)
	self.presets.weapon.gang_member.rifle.autofire_rounds = nil
	self.presets.weapon.gang_member.akimbo_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_shotgun_mag = deep_clone(self.presets.weapon.gang_member.is_shotgun_pump)

	self:_set_characters_weapon_preset("expert")

	self.shadow_spooc.shadow_spooc_attack_timeout = {
		3,
		4
	}
	self.spooc.spooc_attack_timeout = {
		3,
		4
	}
	self.sniper.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 10,
			r = 700,
			acc = {
				0.7,
				1
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 10,
			r = 4000,
			acc = {
				0.6,
				0.95
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 5,
			r = 10000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.tank.weapon.is_rifle.aim_delay = {
		0,
		0
	}
	self.tank.weapon.is_rifle.focus_delay = 0
	self.tank.weapon.mini.aim_delay = {
		0,
		0
	}
	self.tank.weapon.mini.focus_delay = 0
	self.shield.weapon.is_smg.aim_delay = {
		0,
		0
	}
	self.shield.weapon.is_smg.focus_delay = 0
	self.shield.weapon.is_smg.focus_dis = 200
	self.shield.weapon.is_pistol.aim_delay = {
		0,
		0
	}
	self.shield.weapon.is_pistol.focus_delay = 0
	self.city_swat.damage.explosion_damage_mul = 1
	self.city_swat.damage.hurt_severity = self.presets.hurt_severities.light_hurt_fire_poison
	self.phalanx_minion.HEALTH_INIT = 400
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 40
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.HEALTH_INIT = 800
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 80
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET
	self.flashbang_multiplier = 2
	self.concussion_multiplier = 1
end

function CharacterTweakData:_set_overkill_290()
	if SystemInfo:platform() == Idstring("PS3") then
		self:_multiply_all_hp(6, 1.5)
	else
		self:_multiply_all_hp(6, 1.5)
	end

	self.tank_mini.HEALTH_INIT = 2400
	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 3.14,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 2.5,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2.1,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.8,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.4,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 900
	self.mobster_boss.HEALTH_INIT = 900
	self.biker_boss.HEALTH_INIT = 3000
	self.chavez_boss.HEALTH_INIT = 900

	self:_multiply_all_speeds(2.05, 2.1)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)

	self.presets.gang_member_damage.REGENERATE_TIME = 1.8
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.6
	self.presets.gang_member_damage.HEALTH_INIT = 800
	self.presets.weapon.gang_member.is_pistol.FALLOFF = {
		{
			dmg_mul = 10,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_rifle.FALLOFF = {
		{
			dmg_mul = 10,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_sniper.FALLOFF = {
		{
			dmg_mul = 20,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 20,
			r = 1000,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 20,
			r = 2500,
			acc = {
				0.95,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 10,
			r = 4000,
			acc = {
				0.9,
				0.95
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 10,
			r = 10000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_lmg.FALLOFF = {
		{
			dmg_mul = 10,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 7.5,
			r = 1000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				0.4,
				0.65
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 5,
			r = 2000,
			acc = {
				0.6,
				0.8
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 3,
			r = 3000,
			acc = {
				0.5,
				0.7
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 4000,
			acc = {
				0.02,
				0.25
			},
			recoil = {
				1,
				2
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 10000,
			acc = {
				0.01,
				0.1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0,
				0,
				0,
				1
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 10,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 10,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				6
			}
		},
		{
			dmg_mul = 8,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				5
			}
		},
		{
			dmg_mul = 7,
			r = 1000,
			acc = {
				0.85,
				0.95
			},
			recoil = {
				0.1,
				0.15
			},
			mode = {
				1,
				2,
				4,
				4
			}
		},
		{
			dmg_mul = 5,
			r = 2000,
			acc = {
				0.75,
				0.9
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				1,
				4,
				4,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0.4,
				0.7
			},
			recoil = {
				0.4,
				0.5
			},
			mode = {
				4,
				2,
				1,
				0
			}
		},
		{
			dmg_mul = 0.2,
			r = 10000,
			acc = {
				0.05,
				0.2
			},
			recoil = {
				0.5,
				1
			},
			mode = {
				2,
				1,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_smg = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_revolver = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_rifle = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_shotgun_pump = self.presets.weapon.gang_member.is_shotgun_pump
	self.presets.weapon.gang_member.mac11 = self.presets.weapon.gang_member.is_smg
	self.presets.weapon.gang_member.rifle = deep_clone(self.presets.weapon.gang_member.is_rifle)
	self.presets.weapon.gang_member.rifle.autofire_rounds = nil
	self.presets.weapon.gang_member.akimbo_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_shotgun_mag = deep_clone(self.presets.weapon.gang_member.is_shotgun_pump)

	self:_set_characters_weapon_preset("deathwish")

	self.shadow_spooc.shadow_spooc_attack_timeout = {
		3,
		4
	}
	self.spooc.spooc_attack_timeout = {
		3,
		4
	}
	self.sniper.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 12,
			r = 700,
			acc = {
				0.7,
				1
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 12,
			r = 4000,
			acc = {
				0.6,
				0.95
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 12,
			r = 10000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.tank.weapon.is_shotgun_mag.aim_delay = {
		0,
		0
	}
	self.tank.weapon.is_shotgun_mag.focus_delay = 0
	self.tank.weapon.is_shotgun_mag.focus_dis = 200
	self.tank.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 8,
			r = 100,
			acc = {
				0.75,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 7.5,
			r = 500,
			acc = {
				0.75,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 7,
			r = 1000,
			acc = {
				0.7,
				0.85
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 5,
			r = 2000,
			acc = {
				0.5,
				0.65
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 3000,
			acc = {
				0.3,
				0.5
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.tank.weapon.is_shotgun_pump.focus_dis = 200
	self.tank.weapon.is_shotgun_pump.FALLOFF[1].dmg_mul = 9
	self.tank.weapon.is_shotgun_pump.FALLOFF[2].dmg_mul = 8
	self.tank.weapon.is_shotgun_pump.FALLOFF[3].dmg_mul = 7
	self.tank.weapon.is_rifle.aim_delay = {
		0,
		0
	}
	self.tank.weapon.is_rifle.focus_delay = 0
	self.tank.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 5,
			r = 100,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 5,
			r = 500,
			acc = {
				0.5,
				0.75
			},
			recoil = {
				0.5,
				0.8
			},
			mode = {
				0,
				0,
				0,
				6
			}
		},
		{
			dmg_mul = 5,
			r = 1000,
			acc = {
				0.3,
				0.6
			},
			recoil = {
				1,
				1
			},
			mode = {
				0,
				0,
				2,
				6
			}
		},
		{
			dmg_mul = 5,
			r = 2000,
			acc = {
				0.25,
				0.55
			},
			recoil = {
				1,
				1
			},
			mode = {
				0,
				0,
				2,
				6
			}
		},
		{
			dmg_mul = 5,
			r = 3000,
			acc = {
				0.15,
				0.5
			},
			recoil = {
				1,
				2
			},
			mode = {
				0,
				0,
				2,
				6
			}
		}
	}
	self.tank.weapon.mini.aim_delay = {
		0,
		0
	}
	self.tank.weapon.mini.focus_delay = 0
	self.tank.weapon.mini.FALLOFF = {
		{
			dmg_mul = 5,
			r = 100,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 5,
			r = 500,
			acc = {
				0.5,
				0.75
			},
			recoil = {
				0.5,
				0.8
			},
			mode = {
				0,
				0,
				0,
				6
			}
		},
		{
			dmg_mul = 5,
			r = 1000,
			acc = {
				0.3,
				0.6
			},
			recoil = {
				1,
				1
			},
			mode = {
				0,
				0,
				2,
				6
			}
		},
		{
			dmg_mul = 5,
			r = 2000,
			acc = {
				0.25,
				0.55
			},
			recoil = {
				1,
				1
			},
			mode = {
				0,
				0,
				2,
				6
			}
		},
		{
			dmg_mul = 5,
			r = 3000,
			acc = {
				0.15,
				0.5
			},
			recoil = {
				1,
				2
			},
			mode = {
				0,
				0,
				2,
				6
			}
		}
	}
	self.shield.weapon.is_smg.aim_delay = {
		0,
		0
	}
	self.shield.weapon.is_smg.focus_delay = 0
	self.shield.weapon.is_smg.focus_dis = 200
	self.shield.weapon.is_smg.FALLOFF = {
		{
			dmg_mul = 7,
			r = 0,
			acc = {
				0.9,
				0.95
			},
			recoil = {
				0.35,
				0.35
			},
			mode = {
				0.2,
				2,
				4,
				10
			}
		},
		{
			dmg_mul = 7,
			r = 700,
			acc = {
				0.8,
				0.8
			},
			recoil = {
				0.35,
				0.55
			},
			mode = {
				0.2,
				2,
				4,
				10
			}
		},
		{
			dmg_mul = 7,
			r = 1000,
			acc = {
				0.6,
				0.65
			},
			recoil = {
				0.35,
				0.55
			},
			mode = {
				0.2,
				2,
				4,
				10
			}
		},
		{
			dmg_mul = 7,
			r = 2000,
			acc = {
				0.5,
				0.7
			},
			recoil = {
				0.35,
				1
			},
			mode = {
				2,
				5,
				6,
				4
			}
		},
		{
			dmg_mul = 7,
			r = 3000,
			acc = {
				0.5,
				0.5
			},
			recoil = {
				0.5,
				1.2
			},
			mode = {
				6,
				4,
				2,
				0
			}
		}
	}
	self.shield.weapon.is_pistol.aim_delay = {
		0,
		0
	}
	self.shield.weapon.is_pistol.focus_delay = 0
	self.shield.weapon.is_pistol.FALLOFF = {
		{
			dmg_mul = 7.5,
			r = 0,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.35,
				0.45
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 7.5,
			r = 700,
			acc = {
				0.6,
				0.8
			},
			recoil = {
				0.35,
				0.45
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 7.5,
			r = 1000,
			acc = {
				0.6,
				0.75
			},
			recoil = {
				0.35,
				0.45
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 7.5,
			r = 2000,
			acc = {
				0.6,
				0.75
			},
			recoil = {
				0.35,
				0.65
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 7.5,
			r = 3000,
			acc = {
				0.5,
				0.6
			},
			recoil = {
				0.35,
				1.5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.taser.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 7,
			r = 100,
			acc = {
				0.9,
				0.95
			},
			recoil = {
				0.4,
				0.4
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 7,
			r = 500,
			acc = {
				0.75,
				0.95
			},
			recoil = {
				0.4,
				0.5
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 7,
			r = 1000,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.4,
				0.6
			},
			mode = {
				1,
				2,
				3,
				0
			}
		},
		{
			dmg_mul = 7,
			r = 2000,
			acc = {
				0.65,
				0.8
			},
			recoil = {
				0.5,
				1
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 7,
			r = 3000,
			acc = {
				0.55,
				0.75
			},
			recoil = {
				1,
				2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.city_swat.damage.explosion_damage_mul = 1
	self.city_swat.damage.hurt_severity = self.presets.hurt_severities.light_hurt_fire_poison
	self.phalanx_minion.HEALTH_INIT = 400
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 40
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.HEALTH_INIT = 800
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 80
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET
	self.flashbang_multiplier = 2
	self.concussion_multiplier = 1
end

function CharacterTweakData:_set_sm_wish()
	if SystemInfo:platform() == Idstring("PS3") then
		self:_multiply_all_hp(6, 1.5)
	else
		self:_multiply_all_hp(6, 1.5)
	end

	self.tank.HEALTH_INIT = 2400
	self.tank_mini.HEALTH_INIT = 4800
	self.tank_medic.HEALTH_INIT = 2400
	self.hector_boss.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 3.14,
			r = 200,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				1,
				2,
				1
			}
		},
		{
			dmg_mul = 2.5,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2.1,
			r = 1000,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.8,
			r = 2000,
			acc = {
				0.4,
				0.55
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1.4,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.hector_boss.HEALTH_INIT = 900
	self.mobster_boss.HEALTH_INIT = 900
	self.biker_boss.HEALTH_INIT = 3000
	self.chavez_boss.HEALTH_INIT = 900

	self:_multiply_all_speeds(4.05, 4.1)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)

	self.presets.gang_member_damage.REGENERATE_TIME = 1.8
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.6
	self.presets.gang_member_damage.HEALTH_INIT = 800
	self.presets.weapon.gang_member.is_pistol.FALLOFF = {
		{
			dmg_mul = 10,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_rifle.FALLOFF = {
		{
			dmg_mul = 10,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_sniper.FALLOFF = {
		{
			dmg_mul = 20,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 20,
			r = 1000,
			acc = {
				1,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 20,
			r = 2500,
			acc = {
				0.95,
				1
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 10,
			r = 4000,
			acc = {
				0.9,
				0.95
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 10,
			r = 10000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				1,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_lmg.FALLOFF = {
		{
			dmg_mul = 10,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 7.5,
			r = 1000,
			acc = {
				0.85,
				0.9
			},
			recoil = {
				0.4,
				0.65
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 5,
			r = 2000,
			acc = {
				0.6,
				0.8
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 3,
			r = 3000,
			acc = {
				0.5,
				0.7
			},
			recoil = {
				0.8,
				1.25
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 4000,
			acc = {
				0.02,
				0.25
			},
			recoil = {
				1,
				2
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 10000,
			acc = {
				0.01,
				0.1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0,
				0,
				0,
				1
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 10,
			r = 300,
			acc = {
				1,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 5,
			r = 10000,
			acc = {
				1,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		}
	}
	self.presets.weapon.gang_member.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 10,
			r = 100,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				6
			}
		},
		{
			dmg_mul = 8,
			r = 500,
			acc = {
				1,
				1
			},
			recoil = {
				0.1,
				0.1
			},
			mode = {
				1,
				1,
				4,
				5
			}
		},
		{
			dmg_mul = 7,
			r = 1000,
			acc = {
				0.85,
				0.95
			},
			recoil = {
				0.1,
				0.15
			},
			mode = {
				1,
				2,
				4,
				4
			}
		},
		{
			dmg_mul = 5,
			r = 2000,
			acc = {
				0.75,
				0.9
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				1,
				4,
				4,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0.4,
				0.7
			},
			recoil = {
				0.4,
				0.5
			},
			mode = {
				4,
				2,
				1,
				0
			}
		},
		{
			dmg_mul = 0.2,
			r = 10000,
			acc = {
				0.05,
				0.2
			},
			recoil = {
				0.5,
				1
			},
			mode = {
				2,
				1,
				0,
				0
			}
		}
	}
	self.presets.weapon.gang_member.is_smg = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_revolver = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_rifle = self.presets.weapon.gang_member.is_rifle
	self.presets.weapon.gang_member.is_shotgun_pump = self.presets.weapon.gang_member.is_shotgun_pump
	self.presets.weapon.gang_member.mac11 = self.presets.weapon.gang_member.is_smg
	self.presets.weapon.gang_member.rifle = deep_clone(self.presets.weapon.gang_member.is_rifle)
	self.presets.weapon.gang_member.rifle.autofire_rounds = nil
	self.presets.weapon.gang_member.akimbo_pistol = self.presets.weapon.gang_member.is_pistol
	self.presets.weapon.gang_member.is_shotgun_mag = deep_clone(self.presets.weapon.gang_member.is_shotgun_pump)

	self:_set_characters_weapon_preset("deathwish")

	self.spooc.spooc_attack_timeout = {
		3,
		4
	}
	self.shadow_spooc.shadow_spooc_attack_timeout = {
		3,
		4
	}
	self.sniper.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 12,
			r = 700,
			acc = {
				0.7,
				1
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 12,
			r = 4000,
			acc = {
				0.6,
				0.95
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 12,
			r = 10000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.tank.weapon.is_shotgun_mag.aim_delay = {
		0,
		0
	}
	self.tank.weapon.is_shotgun_mag.focus_delay = 0
	self.tank.weapon.is_shotgun_mag.focus_dis = 200
	self.tank.weapon.is_shotgun_mag.FALLOFF = {
		{
			dmg_mul = 9,
			r = 100,
			acc = {
				0.75,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 8.5,
			r = 500,
			acc = {
				0.75,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 8,
			r = 1000,
			acc = {
				0.7,
				0.85
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 5,
			r = 2000,
			acc = {
				0.5,
				0.65
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 3000,
			acc = {
				0.3,
				0.5
			},
			recoil = {
				1,
				1.2
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	self.tank.weapon.is_shotgun_pump.focus_dis = 200
	self.tank.weapon.is_shotgun_pump.FALLOFF[1].dmg_mul = 9
	self.tank.weapon.is_shotgun_pump.FALLOFF[2].dmg_mul = 8
	self.tank.weapon.is_shotgun_pump.FALLOFF[3].dmg_mul = 7
	self.tank.weapon.is_rifle.aim_delay = {
		0,
		0
	}
	self.tank.weapon.is_rifle.focus_delay = 0
	self.tank.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 6,
			r = 100,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 6,
			r = 500,
			acc = {
				0.5,
				0.75
			},
			recoil = {
				0.5,
				0.8
			},
			mode = {
				0,
				0,
				0,
				6
			}
		},
		{
			dmg_mul = 6,
			r = 1000,
			acc = {
				0.3,
				0.6
			},
			recoil = {
				1,
				1
			},
			mode = {
				0,
				0,
				2,
				6
			}
		},
		{
			dmg_mul = 6,
			r = 2000,
			acc = {
				0.25,
				0.55
			},
			recoil = {
				1,
				1
			},
			mode = {
				0,
				0,
				2,
				6
			}
		},
		{
			dmg_mul = 6,
			r = 3000,
			acc = {
				0.15,
				0.5
			},
			recoil = {
				1,
				2
			},
			mode = {
				0,
				0,
				2,
				6
			}
		}
	}
	self.tank.weapon.mini.aim_delay = {
		0,
		0
	}
	self.tank.weapon.mini.focus_delay = 0
	self.tank.weapon.mini.FALLOFF = {
		{
			dmg_mul = 6,
			r = 100,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				0,
				0,
				0,
				1
			}
		},
		{
			dmg_mul = 6,
			r = 500,
			acc = {
				0.5,
				0.75
			},
			recoil = {
				0.5,
				0.8
			},
			mode = {
				0,
				0,
				0,
				6
			}
		},
		{
			dmg_mul = 6,
			r = 1000,
			acc = {
				0.3,
				0.6
			},
			recoil = {
				1,
				1
			},
			mode = {
				0,
				0,
				2,
				6
			}
		},
		{
			dmg_mul = 6,
			r = 2000,
			acc = {
				0.25,
				0.55
			},
			recoil = {
				1,
				1
			},
			mode = {
				0,
				0,
				2,
				6
			}
		},
		{
			dmg_mul = 6,
			r = 3000,
			acc = {
				0.15,
				0.5
			},
			recoil = {
				1,
				2
			},
			mode = {
				0,
				0,
				2,
				6
			}
		}
	}
	self.tank.weapon.mini.aim_delay = {
		0,
		0
	}
	self.tank.weapon.mini.focus_delay = 0
	self.shield.weapon.is_smg.aim_delay = {
		0,
		0
	}
	self.shield.weapon.is_smg.focus_delay = 0
	self.shield.weapon.is_smg.focus_dis = 200
	self.shield.weapon.is_smg.FALLOFF = {
		{
			dmg_mul = 7,
			r = 0,
			acc = {
				0.9,
				0.95
			},
			recoil = {
				0.35,
				0.35
			},
			mode = {
				0.2,
				2,
				4,
				10
			}
		},
		{
			dmg_mul = 7,
			r = 700,
			acc = {
				0.8,
				0.8
			},
			recoil = {
				0.35,
				0.55
			},
			mode = {
				0.2,
				2,
				4,
				10
			}
		},
		{
			dmg_mul = 7,
			r = 1000,
			acc = {
				0.6,
				0.65
			},
			recoil = {
				0.35,
				0.55
			},
			mode = {
				0.2,
				2,
				4,
				10
			}
		},
		{
			dmg_mul = 7,
			r = 2000,
			acc = {
				0.5,
				0.7
			},
			recoil = {
				0.35,
				1
			},
			mode = {
				2,
				5,
				6,
				4
			}
		},
		{
			dmg_mul = 7,
			r = 3000,
			acc = {
				0.5,
				0.5
			},
			recoil = {
				0.5,
				1.2
			},
			mode = {
				6,
				4,
				2,
				0
			}
		}
	}
	self.shield.weapon.is_pistol.aim_delay = {
		0,
		0
	}
	self.shield.weapon.is_pistol.focus_delay = 0
	self.shield.weapon.is_pistol.FALLOFF = {
		{
			dmg_mul = 6,
			r = 100,
			acc = {
				0.95,
				0.95
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				0,
				3,
				3,
				4
			}
		},
		{
			dmg_mul = 5,
			r = 500,
			acc = {
				0.6,
				0.75
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				4
			}
		},
		{
			dmg_mul = 5,
			r = 1000,
			acc = {
				0.5,
				0.65
			},
			recoil = {
				0.35,
				0.5
			},
			mode = {
				0,
				6,
				3,
				3
			}
		},
		{
			dmg_mul = 4,
			r = 2000,
			acc = {
				0.5,
				0.6
			},
			recoil = {
				0.35,
				0.5
			},
			mode = {
				0,
				6,
				3,
				0
			}
		},
		{
			dmg_mul = 4,
			r = 3000,
			acc = {
				0.5,
				0.6
			},
			recoil = {
				0.5,
				1.5
			},
			mode = {
				1,
				6,
				2,
				0
			}
		}
	}
	self.taser.weapon.is_rifle.FALLOFF = {
		{
			dmg_mul = 7.5,
			r = 100,
			acc = {
				0.9,
				0.975
			},
			recoil = {
				0.25,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 6.5,
			r = 500,
			acc = {
				0.875,
				0.95
			},
			recoil = {
				0.25,
				0.3
			},
			mode = {
				0,
				3,
				8,
				1
			}
		},
		{
			dmg_mul = 6.5,
			r = 1000,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.35,
				0.55
			},
			mode = {
				0,
				2,
				5,
				1
			}
		},
		{
			dmg_mul = 5.5,
			r = 2000,
			acc = {
				0.7,
				0.85
			},
			recoil = {
				0.4,
				0.7
			},
			mode = {
				3,
				2,
				5,
				1
			}
		},
		{
			dmg_mul = 5.5,
			r = 3000,
			acc = {
				0.65,
				0.75
			},
			recoil = {
				0.7,
				1.1
			},
			mode = {
				3,
				1,
				5,
				0.5
			}
		}
	}
	self.city_swat.damage.explosion_damage_mul = 1
	self.city_swat.damage.hurt_severity = self.presets.hurt_severities.light_hurt_fire_poison
	self.phalanx_minion.HEALTH_INIT = 400
	self.phalanx_minion.DAMAGE_CLAMP_BULLET = 40
	self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = self.phalanx_minion.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.HEALTH_INIT = 800
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 80
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET
	self.flashbang_multiplier = 2
	self.concussion_multiplier = 1
end

function CharacterTweakData:_multiply_weapon_delay(weap_usage_table, mul)
	for _, weap_id in ipairs(self.weap_ids) do
		local usage_data = weap_usage_table[weap_id]

		if usage_data then
			usage_data.focus_delay = usage_data.focus_delay * mul
		end
	end
end

function CharacterTweakData:_multiply_all_hp(hp_mul, hs_mul)
	self.fbi.HEALTH_INIT = self.fbi.HEALTH_INIT * hp_mul
	self.swat.HEALTH_INIT = self.swat.HEALTH_INIT * hp_mul
	self.heavy_swat.HEALTH_INIT = self.heavy_swat.HEALTH_INIT * hp_mul
	self.fbi_heavy_swat.HEALTH_INIT = self.fbi_heavy_swat.HEALTH_INIT * hp_mul
	self.sniper.HEALTH_INIT = self.sniper.HEALTH_INIT * hp_mul
	self.gangster.HEALTH_INIT = self.gangster.HEALTH_INIT * hp_mul
	self.biker.HEALTH_INIT = self.biker.HEALTH_INIT * hp_mul
	self.tank.HEALTH_INIT = self.tank.HEALTH_INIT * hp_mul
	self.tank_mini.HEALTH_INIT = self.tank_mini.HEALTH_INIT * hp_mul
	self.tank_medic.HEALTH_INIT = self.tank_medic.HEALTH_INIT * hp_mul
	self.spooc.HEALTH_INIT = self.spooc.HEALTH_INIT * hp_mul
	self.shadow_spooc.HEALTH_INIT = self.shadow_spooc.HEALTH_INIT * hp_mul
	self.shield.HEALTH_INIT = self.shield.HEALTH_INIT * hp_mul
	self.phalanx_minion.HEALTH_INIT = self.phalanx_minion.HEALTH_INIT * hp_mul
	self.phalanx_vip.HEALTH_INIT = self.phalanx_vip.HEALTH_INIT * hp_mul
	self.taser.HEALTH_INIT = self.taser.HEALTH_INIT * hp_mul
	self.city_swat.HEALTH_INIT = self.city_swat.HEALTH_INIT * hp_mul
	self.biker_escape.HEALTH_INIT = self.biker_escape.HEALTH_INIT * hp_mul
	self.fbi_swat.HEALTH_INIT = self.fbi_swat.HEALTH_INIT * hp_mul
	self.tank_hw.HEALTH_INIT = self.tank_hw.HEALTH_INIT * hp_mul
	self.medic.HEALTH_INIT = self.medic.HEALTH_INIT * hp_mul
	self.bolivian.HEALTH_INIT = self.bolivian.HEALTH_INIT * hp_mul
	self.bolivian_indoors.HEALTH_INIT = self.bolivian_indoors.HEALTH_INIT * hp_mul
	self.bolivian_indoors_mex.HEALTH_INIT = self.bolivian_indoors_mex.HEALTH_INIT * hp_mul
	self.drug_lord_boss.HEALTH_INIT = self.drug_lord_boss.HEALTH_INIT * hp_mul
	self.drug_lord_boss_stealth.HEALTH_INIT = self.drug_lord_boss_stealth.HEALTH_INIT * hp_mul

	if self.security.headshot_dmg_mul then
		self.security.headshot_dmg_mul = self.security.headshot_dmg_mul * hs_mul
	end

	if self.cop.headshot_dmg_mul then
		self.cop.headshot_dmg_mul = self.cop.headshot_dmg_mul * hs_mul
	end

	if self.fbi.headshot_dmg_mul then
		self.fbi.headshot_dmg_mul = self.fbi.headshot_dmg_mul * hs_mul
	end

	if self.swat.headshot_dmg_mul then
		self.swat.headshot_dmg_mul = self.swat.headshot_dmg_mul * hs_mul
	end

	if self.heavy_swat.headshot_dmg_mul then
		self.heavy_swat.headshot_dmg_mul = self.heavy_swat.headshot_dmg_mul * hs_mul
	end

	if self.fbi_heavy_swat.headshot_dmg_mul then
		self.fbi_heavy_swat.headshot_dmg_mul = self.fbi_heavy_swat.headshot_dmg_mul * hs_mul
	end

	if self.sniper.headshot_dmg_mul then
		self.sniper.headshot_dmg_mul = self.sniper.headshot_dmg_mul * hs_mul
	end

	if self.gangster.headshot_dmg_mul then
		self.gangster.headshot_dmg_mul = self.gangster.headshot_dmg_mul * hs_mul
	end

	if self.biker.headshot_dmg_mul then
		self.biker.headshot_dmg_mul = self.biker.headshot_dmg_mul * hs_mul
	end

	if self.tank.headshot_dmg_mul then
		self.tank.headshot_dmg_mul = self.tank.headshot_dmg_mul * hs_mul
	end

	if self.shadow_spooc.headshot_dmg_mul then
		self.shadow_spooc.headshot_dmg_mul = self.shadow_spooc.headshot_dmg_mul * hs_mul
	end

	if self.spooc.headshot_dmg_mul then
		self.spooc.headshot_dmg_mul = self.spooc.headshot_dmg_mul * hs_mul
	end

	if self.shield.headshot_dmg_mul then
		self.shield.headshot_dmg_mul = self.shield.headshot_dmg_mul * hs_mul
	end

	if self.phalanx_minion.headshot_dmg_mul then
		self.phalanx_minion.headshot_dmg_mul = self.phalanx_minion.headshot_dmg_mul * hs_mul
	end

	if self.phalanx_vip.headshot_dmg_mul then
		self.phalanx_vip.headshot_dmg_mul = self.phalanx_vip.headshot_dmg_mul * hs_mul
	end

	if self.taser.headshot_dmg_mul then
		self.taser.headshot_dmg_mul = self.taser.headshot_dmg_mul * hs_mul
	end

	if self.biker_escape.headshot_dmg_mul then
		self.biker_escape.headshot_dmg_mul = self.biker_escape.headshot_dmg_mul * hs_mul
	end

	if self.city_swat.headshot_dmg_mul then
		self.city_swat.headshot_dmg_mul = self.city_swat.headshot_dmg_mul * hs_mul
	end

	if self.fbi_swat.headshot_dmg_mul then
		self.fbi_swat.headshot_dmg_mul = self.fbi_swat.headshot_dmg_mul * hs_mul
	end

	if self.tank_hw.headshot_dmg_mul then
		self.tank_hw.headshot_dmg_mul = self.tank_hw.headshot_dmg_mul * hs_mul
	end

	if self.medic.headshot_dmg_mul then
		self.medic.headshot_dmg_mul = self.medic.headshot_dmg_mul * hs_mul
	end

	if self.drug_lord_boss.headshot_dmg_mul then
		self.drug_lord_boss.headshot_dmg_mul = self.drug_lord_boss.headshot_dmg_mul * hs_mul
	end

	if self.bolivian.headshot_dmg_mul then
		self.bolivian.headshot_dmg_mul = self.bolivian.headshot_dmg_mul * hs_mul
	end

	if self.bolivian_indoors.headshot_dmg_mul then
		self.bolivian_indoors.headshot_dmg_mul = self.bolivian_indoors.headshot_dmg_mul * hs_mul
	end

	if self.bolivian_indoors_mex.headshot_dmg_mul then
		self.bolivian_indoors_mex.headshot_dmg_mul = self.bolivian_indoors_mex.headshot_dmg_mul * hs_mul
	end

	if self.tank_medic.headshot_dmg_mul then
		self.tank_medic.headshot_dmg_mul = self.tank_medic.headshot_dmg_mul * hs_mul
	end

	if self.tank_mini.headshot_dmg_mul then
		self.tank_mini.headshot_dmg_mul = self.tank_mini.headshot_dmg_mul * hs_mul
	end
end

function CharacterTweakData:_multiply_all_speeds(walk_mul, run_mul)
	local all_units = {
		"security",
		"cop",
		"fbi",
		"swat",
		"heavy_swat",
		"sniper",
		"gangster",
		"tank",
		"spooc",
		"shield",
		"taser",
		"city_swat",
		"fbi_swat",
		"shadow_spooc"
	}

	table.insert(all_units, "bolivian")
	table.insert(all_units, "bolivian_indoors")
	table.insert(all_units, "bolivian_indoors_mex")

	for _, name in ipairs(all_units) do
		local speed_table = self[name].SPEED_WALK
		speed_table.hos = speed_table.hos * walk_mul
		speed_table.cbt = speed_table.cbt * walk_mul
	end

	self.security.SPEED_RUN = self.security.SPEED_RUN * run_mul
	self.cop.SPEED_RUN = self.cop.SPEED_RUN * run_mul
	self.fbi.SPEED_RUN = self.fbi.SPEED_RUN * run_mul
	self.swat.SPEED_RUN = self.swat.SPEED_RUN * run_mul
	self.heavy_swat.SPEED_RUN = self.heavy_swat.SPEED_RUN * run_mul
	self.fbi_heavy_swat.SPEED_RUN = self.fbi_heavy_swat.SPEED_RUN * run_mul
	self.sniper.SPEED_RUN = self.sniper.SPEED_RUN * run_mul
	self.gangster.SPEED_RUN = self.gangster.SPEED_RUN * run_mul
	self.biker.SPEED_RUN = self.biker.SPEED_RUN * run_mul
	self.tank.SPEED_RUN = self.tank.SPEED_RUN * run_mul
	self.spooc.SPEED_RUN = self.spooc.SPEED_RUN * run_mul
	self.shadow_spooc.SPEED_RUN = self.spooc.SPEED_RUN * run_mul
	self.shield.SPEED_RUN = self.shield.SPEED_RUN * run_mul
	self.taser.SPEED_RUN = self.taser.SPEED_RUN * run_mul
	self.city_swat.SPEED_RUN = self.city_swat.SPEED_RUN * run_mul
	self.biker_escape.SPEED_RUN = self.biker_escape.SPEED_RUN * run_mul
	self.fbi_swat.SPEED_RUN = self.fbi_swat.SPEED_RUN * run_mul
end

function CharacterTweakData:_set_characters_weapon_preset(preset)
	local all_units = {
		"security",
		"cop",
		"fbi",
		"swat",
		"heavy_swat",
		"gangster",
		"swat"
	}

	for _, name in ipairs(all_units) do
		self[name].weapon = self.presets.weapon[preset]
	end
end

function CharacterTweakData:character_map()
	local char_map = {
		basic = {
			path = "units/payday2/characters/",
			list = {
				"civ_female_bank_1",
				"civ_female_bank_manager_1",
				"civ_female_bikini_1",
				"civ_female_bikini_2",
				"civ_female_casual_1",
				"civ_female_casual_2",
				"civ_female_casual_3",
				"civ_female_casual_4",
				"civ_female_casual_5",
				"civ_female_casual_6",
				"civ_female_casual_7",
				"civ_female_casual_8",
				"civ_female_casual_9",
				"civ_female_casual_10",
				"civ_female_crackwhore_1",
				"civ_female_curator_1",
				"civ_female_curator_2",
				"civ_female_hostess_apron_1",
				"civ_female_hostess_jacket_1",
				"civ_female_hostess_shirt_1",
				"civ_female_party_1",
				"civ_female_party_2",
				"civ_female_party_3",
				"civ_female_party_4",
				"civ_female_waitress_1",
				"civ_female_waitress_2",
				"civ_female_waitress_3",
				"civ_female_waitress_4",
				"civ_female_wife_trophy_1",
				"civ_female_wife_trophy_2",
				"civ_male_bank_1",
				"civ_male_bank_2",
				"civ_male_bank_manager_1",
				"civ_male_bank_manager_3",
				"civ_male_bank_manager_4",
				"civ_male_bank_manager_5",
				"civ_male_bartender_1",
				"civ_male_bartender_2",
				"civ_male_business_1",
				"civ_male_business_2",
				"civ_male_casual_1",
				"civ_male_casual_2",
				"civ_male_casual_3",
				"civ_male_casual_4",
				"civ_male_casual_5",
				"civ_male_casual_6",
				"civ_male_casual_7",
				"civ_male_casual_8",
				"civ_male_casual_9",
				"civ_male_casual_12",
				"civ_male_casual_13",
				"civ_male_casual_14",
				"civ_male_curator_1",
				"civ_male_curator_2",
				"civ_male_curator_3",
				"civ_male_dj_1",
				"civ_male_italian_robe_1",
				"civ_male_janitor_1",
				"civ_male_janitor_2",
				"civ_male_janitor_3",
				"civ_male_meth_cook_1",
				"civ_male_party_1",
				"civ_male_party_2",
				"civ_male_party_3",
				"civ_male_pilot_1",
				"civ_male_scientist_1",
				"civ_male_miami_store_clerk_1",
				"civ_male_taxman",
				"civ_male_trucker_1",
				"civ_male_worker_1",
				"civ_male_worker_2",
				"civ_male_worker_3",
				"civ_male_worker_docks_1",
				"civ_male_worker_docks_2",
				"civ_male_worker_docks_3",
				"civ_male_dog_abuser_1",
				"civ_male_dog_abuser_2",
				"ene_biker_1",
				"ene_biker_2",
				"ene_biker_3",
				"ene_biker_4",
				"ene_bulldozer_1",
				"ene_bulldozer_2",
				"ene_bulldozer_3",
				"ene_bulldozer_4",
				"ene_city_swat_1",
				"ene_city_swat_2",
				"ene_city_swat_3",
				"ene_murkywater_1",
				"ene_murkywater_2",
				"ene_cop_1",
				"ene_cop_2",
				"ene_cop_3",
				"ene_cop_4",
				"ene_fbi_1",
				"ene_fbi_2",
				"ene_fbi_3",
				"ene_fbi_boss_1",
				"ene_fbi_female_1",
				"ene_fbi_female_2",
				"ene_fbi_female_3",
				"ene_fbi_female_4",
				"ene_fbi_heavy_1",
				"ene_fbi_office_1",
				"ene_fbi_office_2",
				"ene_fbi_office_3",
				"ene_fbi_office_4",
				"ene_fbi_swat_1",
				"ene_fbi_swat_2",
				"ene_gang_black_1",
				"ene_gang_black_2",
				"ene_gang_black_3",
				"ene_gang_black_4",
				"ene_gang_mexican_1",
				"ene_gang_mexican_2",
				"ene_gang_mexican_3",
				"ene_gang_mexican_4",
				"ene_gang_russian_1",
				"ene_gang_russian_2",
				"ene_gang_russian_3",
				"ene_gang_russian_4",
				"ene_gang_russian_5",
				"ene_gang_mobster_1",
				"ene_gang_mobster_2",
				"ene_gang_mobster_3",
				"ene_gang_mobster_4",
				"ene_gang_mobster_boss",
				"ene_guard_national_1",
				"ene_hoxton_breakout_guard_1",
				"ene_hoxton_breakout_guard_2",
				"ene_male_tgt_1",
				"ene_murkywater_1",
				"ene_murkywater_2",
				"ene_prisonguard_female_1",
				"ene_prisonguard_male_1",
				"ene_secret_service_1",
				"ene_secret_service_2",
				"ene_security_1",
				"ene_security_2",
				"ene_security_3",
				"ene_security_4",
				"ene_security_5",
				"ene_security_6",
				"ene_security_7",
				"ene_security_8",
				"ene_shield_1",
				"ene_shield_2",
				"ene_phalanx_1",
				"ene_vip_1",
				"ene_sniper_1",
				"ene_sniper_2",
				"ene_spook_1",
				"ene_swat_1",
				"ene_swat_2",
				"ene_swat_heavy_1",
				"ene_tazer_1",
				"ene_veteran_cop_1",
				"npc_old_hoxton_prisonsuit_1",
				"npc_old_hoxton_prisonsuit_2",
				"ene_medic_r870",
				"ene_medic_m4",
				"ene_city_heavy_r870",
				"ene_city_heavy_g36"
			}
		},
		dlc1 = {
			path = "units/pd2_dlc1/characters/",
			list = {
				"civ_male_bank_manager_2",
				"civ_male_casual_10",
				"civ_male_casual_11",
				"civ_male_firefighter_1",
				"civ_male_paramedic_1",
				"civ_male_paramedic_2",
				"ene_security_gensec_1",
				"ene_security_gensec_2"
			}
		},
		dlc2 = {
			path = "units/pd2_dlc2/characters/",
			list = {
				"civ_female_bank_assistant_1",
				"civ_female_bank_assistant_2"
			}
		},
		mansion = {
			path = "units/pd2_mcmansion/characters/",
			list = {
				"ene_male_hector_1",
				"ene_male_hector_2",
				"ene_hoxton_breakout_guard_1",
				"ene_hoxton_breakout_guard_2"
			}
		},
		cage = {
			path = "units/pd2_dlc_cage/characters/",
			list = {
				"civ_female_bank_2"
			}
		},
		arena = {
			path = "units/pd2_dlc_arena/characters/",
			list = {
				"civ_female_fastfood_1",
				"civ_female_party_alesso_1",
				"civ_female_party_alesso_2",
				"civ_female_party_alesso_3",
				"civ_female_party_alesso_4",
				"civ_female_party_alesso_5",
				"civ_female_party_alesso_6",
				"civ_male_party_alesso_1",
				"civ_male_party_alesso_2",
				"civ_male_alesso_booth",
				"civ_male_fastfood_1",
				"ene_guard_security_heavy_2",
				"ene_guard_security_heavy_1"
			}
		},
		kenaz = {
			path = "units/pd2_dlc_casino/characters/",
			list = {
				"civ_male_casino_1",
				"civ_male_casino_2",
				"civ_male_casino_3",
				"civ_male_casino_4",
				"ene_secret_service_1_casino",
				"civ_male_business_casino_1",
				"civ_male_business_casino_2",
				"civ_male_impersonator",
				"civ_female_casino_1",
				"civ_female_casino_2",
				"civ_female_casino_3",
				"civ_male_casino_pitboss"
			}
		},
		vip = {
			path = "units/pd2_dlc_vip/characters/",
			list = {
				"ene_vip_1",
				"ene_phalanx_1"
			}
		},
		holly = {
			path = "units/pd2_dlc_holly/characters/",
			list = {
				"civ_male_hobo_1",
				"civ_male_hobo_2",
				"civ_male_hobo_3",
				"civ_male_hobo_4",
				"ene_gang_hispanic_1",
				"ene_gang_hispanic_3",
				"ene_gang_hispanic_2"
			}
		},
		red = {
			path = "units/pd2_dlc_red/characters/",
			list = {
				"civ_female_inside_man_1"
			}
		},
		dinner = {
			path = "units/pd2_dlc_dinner/characters/",
			list = {
				"civ_male_butcher_2",
				"civ_male_butcher_1"
			}
		},
		pal = {
			path = "units/pd2_dlc_pal/characters/",
			list = {
				"civ_male_mitch"
			}
		},
		cane = {
			path = "units/pd2_dlc_cane/characters/",
			list = {
				"civ_male_helper_1",
				"civ_male_helper_2",
				"civ_male_helper_3",
				"civ_male_helper_4"
			}
		},
		berry = {
			path = "units/pd2_dlc_berry/characters/",
			list = {
				"ene_murkywater_no_light",
				"npc_locke"
			}
		},
		peta = {
			path = "units/pd2_dlc_peta/characters/",
			list = {
				"civ_male_boris"
			}
		},
		mad = {
			path = "units/pd2_dlc_mad/characters/",
			list = {
				"civ_male_scientist_01",
				"civ_male_scientist_02",
				"ene_akan_fbi_heavy_g36",
				"ene_akan_fbi_shield_sr2_smg",
				"ene_akan_fbi_spooc_asval_smg",
				"ene_akan_fbi_swat_ak47_ass",
				"ene_akan_fbi_swat_dw_ak47_ass",
				"ene_akan_fbi_swat_dw_r870",
				"ene_akan_fbi_swat_r870",
				"ene_akan_fbi_tank_r870",
				"ene_akan_fbi_tank_rpk_lmg",
				"ene_akan_fbi_tank_saiga",
				"ene_akan_cs_cop_ak47_ass",
				"ene_akan_cs_cop_akmsu_smg",
				"ene_akan_cs_cop_asval_smg",
				"ene_akan_cs_cop_r870",
				"ene_akan_cs_heavy_ak47_ass",
				"ene_akan_cs_shield_c45",
				"ene_akan_cs_swat_ak47_ass",
				"ene_akan_cs_swat_r870",
				"ene_akan_cs_swat_sniper_svd_snp",
				"ene_akan_cs_tazer_ak47_ass",
				"ene_akan_medic_ak47_ass",
				"ene_akan_medic_r870"
			}
		},
		born = {
			path = "units/pd2_dlc_born/characters/",
			list = {
				"ene_gang_biker_boss",
				"ene_biker_female_1",
				"ene_biker_female_2",
				"ene_biker_female_3",
				"npc_male_mechanic"
			}
		},
		flat = {
			path = "units/pd2_dlc_flat/characters/",
			list = {
				"npc_chavez",
				"npc_jamaican"
			}
		},
		glace = {
			path = "units/pd2_dlc_glace/characters/",
			list = {
				"npc_chinese_prisoner",
				"npc_prisoner_1",
				"npc_prisoner_2",
				"npc_prisoner_3",
				"npc_prisoner_4",
				"npc_prisoner_5",
				"npc_prisoner_6",
				"npc_yakuza_prisoner"
			}
		},
		moon = {
			path = "units/pd2_dlc_moon/characters/",
			list = {
				"civ_male_pilot_2"
			}
		},
		friend = {
			path = "units/pd2_dlc_friend/characters/",
			list = {
				"ene_bolivian_thug_outdoor_01",
				"ene_bolivian_thug_outdoor_02",
				"ene_drug_lord_boss",
				"ene_security_manager",
				"ene_thug_indoor_01",
				"ene_thug_indoor_02"
			}
		},
		gitgud = {
			path = "units/pd2_dlc_gitgud/characters/",
			list = {
				"ene_zeal_bulldozer",
				"ene_zeal_bulldozer_2",
				"ene_zeal_bulldozer_3",
				"ene_zeal_cloaker",
				"ene_zeal_swat",
				"ene_zeal_swat_heavy",
				"ene_zeal_swat_shield",
				"ene_zeal_tazer"
			}
		},
		help = {
			path = "units/pd2_dlc_help/characters/",
			list = {
				"ene_zeal_bulldozer_halloween"
			}
		},
		spa = {
			path = "units/pd2_dlc_spa/characters/",
			list = {
				"ene_sniper_3",
				"npc_spa",
				"npc_spa_2",
				"npc_spa_3",
				"npc_gage"
			}
		},
		fish = {
			path = "units/pd2_dlc_lxy/characters/",
			list = {
				"civ_female_guest_gala_1",
				"civ_female_guest_gala_2",
				"civ_male_guest_gala_1",
				"civ_male_guest_gala_2",
				"civ_male_camera_crew_1"
			}
		},
		slu = {
			path = "units/pd2_dlc_slu/characters/",
			list = {
				"npc_vlad",
				"npc_sophia"
			}
		},
		run = {
			path = "units/pd2_dlc_run/characters/",
			list = {
				"npc_matt"
			}
		},
		rvd = {
			path = "units/pd2_dlc_rvd/characters/",
			list = {
				"npc_cop",
				"npc_cop_01",
				"npc_mr_brown",
				"npc_mr_pink",
				"npc_mr_orange",
				"npc_mr_blonde",
				"npc_mr_pink_escort",
				"ene_la_cop_1",
				"ene_la_cop_2",
				"ene_la_cop_3",
				"ene_la_cop_4",
				"ene_female_civ_undercover"
			}
		},
		drm = {
			path = "units/pd2_dlc_drm/characters/",
			list = {
				"ene_bulldozer_medic",
				"ene_bulldozer_minigun",
				"ene_bulldozer_minigun_classic",
				"ene_zeal_swat_heavy_sniper"
			}
		},
		dah = {
			path = "units/pd2_dlc_dah/characters/",
			list = {
				"npc_male_cfo",
				"npc_male_ralph"
			}
		},
		hvh = {
			path = "units/pd2_dlc_hvh/characters/",
			list = {
				"ene_cop_hvh_1",
				"ene_cop_hvh_2",
				"ene_cop_hvh_3",
				"ene_cop_hvh_4",
				"ene_swat_hvh_1",
				"ene_swat_hvh_2",
				"ene_fbi_hvh_1",
				"ene_fbi_hvh_2",
				"ene_fbi_hvh_3",
				"ene_spook_hvh_1",
				"ene_swat_heavy_hvh_1",
				"ene_swat_heavy_hvh_r870",
				"ene_tazer_hvh_1",
				"ene_shield_hvh_1",
				"ene_shield_hvh_2",
				"ene_medic_hvh_r870",
				"ene_medic_hvh_m4",
				"ene_bulldozer_hvh_1",
				"ene_bulldozer_hvh_2",
				"ene_bulldozer_hvh_3",
				"ene_fbi_swat_hvh_1",
				"ene_fbi_swat_hvh_2",
				"ene_fbi_heavy_hvh_1",
				"ene_fbi_heavy_hvh_r870",
				"ene_sniper_hvh_2"
			}
		},
		wwh = {
			path = "units/pd2_dlc_wwh/characters/",
			list = {
				"ene_female_crew",
				"ene_male_crew_01",
				"ene_male_crew_02",
				"ene_captain",
				"ene_locke"
			}
		},
		des = {
			path = "units/pd2_dlc_des/characters/",
			list = {
				"ene_murkywater_no_light_not_security",
				"ene_murkywater_not_security_1",
				"ene_murkywater_not_security_2",
				"ene_male_des",
				"civ_male_hazmat",
				"civ_male_des_scientist_01",
				"civ_male_des_scientist_02"
			}
		},
		tag = {
			path = "units/pd2_dlc_tag/characters/",
			list = {
				"ene_male_commissioner"
			}
		},
		nmh = {
			path = "units/pd2_dlc_nmh/characters/",
			list = {
				"civ_male_doctor_01",
				"civ_male_doctor_02",
				"civ_male_doctor_03",
				"civ_male_scrubs_01",
				"civ_male_scrubs_02",
				"civ_male_scrubs_03",
				"civ_male_scrubs_04",
				"civ_female_scrubs_01",
				"civ_female_scrubs_02",
				"civ_female_scrubs_03",
				"civ_female_scrubs_04",
				"civ_female_doctor_01",
				"civ_female_hotpants"
			}
		},
		sah = {
			path = "units/pd2_dlc_sah/characters/",
			list = {
				"civ_male_gala_guest_03",
				"civ_male_gala_guest_04",
				"civ_male_gala_guest_05",
				"civ_male_gala_guest_06",
				"civ_male_auctioneer",
				"civ_female_gala_guest_04",
				"civ_female_gala_guest_05",
				"civ_female_gala_guest_06",
				"civ_male_shacklethorn_waiter_01",
				"civ_male_shacklethorn_waiter_02",
				"civ_male_maintenance_01"
			}
		},
		skm = {
			path = "units/pd2_skirmish/characters/",
			list = {
				"civ_male_bank_manager_hostage",
				"civ_female_museum_curator_hostage",
				"civ_female_drug_lord_hostage",
				"civ_male_prisoner_hostage"
			}
		},
		bph = {
			path = "units/pd2_dlc_bph/characters/",
			list = {
				"civ_male_locke_escort",
				"civ_male_bain",
				"ene_male_bain",
				"ene_murkywater_medic",
				"ene_murkywater_medic_r870",
				"ene_murkywater_tazer",
				"ene_murkywater_cloaker",
				"ene_murkywater_bulldozer_1",
				"ene_murkywater_bulldozer_2",
				"ene_murkywater_bulldozer_3",
				"ene_murkywater_bulldozer_4",
				"ene_murkywater_bulldozer_medic",
				"ene_murkywater_shield",
				"ene_murkywater_sniper",
				"ene_murkywater_heavy",
				"ene_murkywater_heavy_shotgun",
				"ene_murkywater_heavy_g36",
				"ene_murkywater_light_city",
				"ene_murkywater_light_city_r870",
				"ene_murkywater_light_fbi_r870",
				"ene_murkywater_light_fbi",
				"ene_murkywater_light",
				"ene_murkywater_light_r870"
			}
		},
		vit = {
			path = "units/pd2_dlc_vit/characters/",
			list = {
				"ene_murkywater_secret_service"
			}
		},
		uno = {
			path = "units/pd2_dlc_uno/characters/",
			list = {
				"ene_shadow_cloaker_1",
				"ene_shadow_cloaker_2"
			}
		},
		mex = {
			path = "units/pd2_dlc_mex/characters/",
			list = {
				"ene_mex_security_guard",
				"ene_mex_security_guard_2",
				"ene_mex_security_guard_3",
				"ene_mex_thug_outdoor_01",
				"ene_mex_thug_outdoor_02",
				"ene_mex_thug_outdoor_03",
				"civ_male_italian"
			}
		}
	}

	return char_map
end
