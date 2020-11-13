require("lib/utils/accelbyte/Telemetry")

StatisticsManager = StatisticsManager or class()
StatisticsManager.special_unit_ids = {
	"shield",
	"spooc",
	"tank",
	"tank_hw",
	"tank_green",
	"tank_black",
	"tank_skull",
	"taser",
	"medic",
	"sniper",
	"phalanx_minion",
	"phalanx_vip",
	"swat_turret",
	"biker_boss",
	"chavez_boss",
	"mobster_boss",
	"hector_boss",
	"hector_boss_no_armor",
	"drug_lord_boss",
	"drug_lord_boss_stealth"
}
StatisticsManager.JOB_STATS_VERSION = 2

function StatisticsManager:init()
	self:_setup()
	self:_reset_session()
end

function StatisticsManager:_setup(reset)
	local _, _, _, _, _, _, enemy_list = tweak_data.statistics:statistics_table()
	self._defaults = {
		killed = {
			other = {
				melee = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			total = {
				melee = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			}
		}
	}

	for _, id in ipairs(enemy_list) do
		self._defaults.killed[id] = {
			melee = 0,
			count = 0,
			head_shots = 0,
			explosion = 0,
			tied = 0
		}
	end

	self._defaults.killed_by_melee = {}
	self._defaults.killed_by_weapon = {}
	self._defaults.killed_by_grenade = {}
	self._defaults.killed_by_anyone = {
		killed_by_melee = {},
		killed_by_weapon = {},
		killed_by_grenade = {}
	}
	self._defaults.shots_by_weapon = {}
	self._defaults.used_weapons = {}
	self._defaults.melee_hit = false
	self._defaults.sessions = {
		count = 0,
		time = 0,
		levels = {}
	}

	for _, lvl in ipairs(tweak_data.levels._level_index) do
		self._defaults.sessions.levels[lvl] = {
			from_beginning = 0,
			time = 0,
			started = 0,
			completed = 0,
			drop_in = 0,
			quited = 0
		}
	end

	self._defaults.sessions.jobs = {}
	self._defaults.revives = {
		npc_count = 0,
		player_count = 0
	}
	self._defaults.cameras = {
		count = 0
	}
	self._defaults.objectives = {
		count = 0
	}
	self._defaults.shots_fired = {
		total = 0,
		hits = 0
	}
	self._defaults.downed = {
		death = 0,
		bleed_out = 0,
		incapacitated = 0,
		fatal = 0
	}
	self._defaults.reloads = {
		count = 0
	}
	self._defaults.health = {
		amount_lost = 0
	}
	self._defaults.experience = {}
	self._defaults.misc = {}
	self._defaults.play_time = {
		minutes = 0
	}
	self._defaults.sessions.job_stats_version = StatisticsManager.JOB_STATS_VERSION

	if not Global.statistics_manager or reset then
		Global.statistics_manager = deep_clone(self._defaults)
		self._global = Global.statistics_manager
		self._global.session = deep_clone(self._defaults)

		self:_calculate_average()
	end

	self._global = self._global or Global.statistics_manager
end

function StatisticsManager:reset()
	self:_setup(true)
end

function StatisticsManager:_reset_session()
	if self._global then
		self._global.session = deep_clone(self._defaults)

		self:_check_days_in_row()
	end
end

function StatisticsManager:_write_log_header()
	local file_handle = SystemFS:open(self._data_log_name, "w")

	file_handle:puts(managers.network.account:username())
	file_handle:puts(Network:is_server() and "true" or "false")
end

function StatisticsManager:_flush_log()
	if not self._data_log or #self._data_log == 0 then
		return
	end

	local file_handle = SystemFS:open(self._data_log_name, "a")

	for _, line in ipairs(self._data_log) do
		local type = line[1]
		local time = line[2]
		local pos = line[3]

		if type == 1 then
			file_handle:puts("1 " .. time .. " " .. pos.x .. " " .. pos.y .. " " .. pos.z .. " " .. line[4])
		elseif type == 2 then
			file_handle:puts("2 " .. time .. " " .. pos.x .. " " .. pos.y .. " " .. pos.z .. " " .. line[4] .. " " .. tostring(line[5]))
		elseif type == 3 then
			file_handle:puts("3 " .. time .. " " .. pos.x .. " " .. pos.y .. " " .. pos.z .. " " .. line[4] .. " " .. line[5])
		end
	end

	self._data_log = {}
end

function StatisticsManager:update(t, dt)
	if self._data_log then
		self._log_timer = self._log_timer - dt

		if self._log_timer <= 0 and alive(managers.player:player_unit()) then
			self._log_timer = 0.25

			table.insert(self._data_log, {
				1,
				Application:time(),
				managers.player:player_unit():position(),
				1 / dt
			})

			if Network:is_server() then
				for u_key, u_data in pairs(managers.enemy:all_enemies()) do
					table.insert(self._data_log, {
						2,
						Application:time(),
						u_data.unit:position(),
						1,
						u_key
					})
				end

				for u_key, u_data in pairs(managers.groupai:state()._ai_criminals) do
					table.insert(self._data_log, {
						2,
						Application:time(),
						u_data.unit:position(),
						2,
						u_key
					})
				end

				for u_key, u_data in pairs(managers.enemy:all_civilians()) do
					table.insert(self._data_log, {
						2,
						Application:time(),
						u_data.unit:position(),
						3,
						u_key
					})
				end
			end

			if #self._data_log > 5000 then
				self:_flush_log()
			end
		end
	end
end

function StatisticsManager:_check_days_in_row()
	local SEC_IN_DAY = 86400
	local d = self._global.days_in_row
	local current = os.time()

	if not d or SEC_IN_DAY < current - d.last then
		self._global.days_in_row = {
			count = 0,
			first = current,
			last = current
		}
	else
		local days = (current - d.first) / SEC_IN_DAY

		if days > d.count + 1 then
			local count = math.floor(days)
			d.count = count

			print("[StatisticsManager].days_in_row", count)
			managers.mission:call_global_event(Message.OnDaysInRow, count)
		end

		d.last = current
	end
end

function StatisticsManager:get_days_in_row()
	return self._global.days_in_row and self._global.days_in_row.count or 0
end

function StatisticsManager:_check_days_alone(sp)
	local d = self._global.days_alone
	self._global.days_alone_time = sp and self._global.days_alone_time or os.time()
end

function StatisticsManager:get_days_alone()
	local SEC_IN_DAY = 86400
	self._global.days_alone_time = self._global.days_alone_time or os.time()

	return (os.time() - self._global.days_alone_time) / SEC_IN_DAY
end

function StatisticsManager:start_session(data)
	if self._session_started then
		return
	end

	self:_check_days_in_row()
	self:_check_days_alone(Global.game_settings.single_player)

	if Global.level_data.level_id and self._global.sessions.levels[Global.level_data.level_id] then
		self._global.sessions.levels[Global.level_data.level_id].started = self._global.sessions.levels[Global.level_data.level_id].started + 1
		self._global.sessions.levels[Global.level_data.level_id].from_beginning = self._global.sessions.levels[Global.level_data.level_id].from_beginning + (Global.statistics_manager.playing_from_start and 1 or 0)
		self._global.sessions.levels[Global.level_data.level_id].drop_in = self._global.sessions.levels[Global.level_data.level_id].drop_in + (Global.statistics_manager.playing_from_start and 0 or 1)
	end

	local job_id = managers.job:current_job_id()
	local can_record_session = managers.job:on_first_stage()
	can_record_session = can_record_session and not managers.mutators:should_disable_statistics()

	if can_record_session then
		local job_stats = self._global.sessions.jobs
		local stat_name = tostring(job_id)
		stat_name = stat_name .. "_" .. tostring(Global.game_settings.difficulty)
		stat_name = stat_name .. (Global.game_settings.one_down and "_od" or "")
		stat_name = stat_name .. (Global.statistics_manager.playing_from_start and "_started" or "_started_dropin")
		job_stats[stat_name] = (job_stats[stat_name] or 0) + 1
	end

	self._global.session = deep_clone(self._defaults)
	self._global.sessions.count = self._global.sessions.count + 1
	self._start_session_time = Application:time()
	self._start_session_from_beginning = Global.statistics_manager.playing_from_start
	self._start_session_drop_in = data.drop_in
	self._session_started = true
end

function StatisticsManager:has_session_started()
	return self._session_started or false
end

function StatisticsManager:get_session_time_seconds()
	local t = Application:time()

	return t - (self._start_session_time or t)
end

function StatisticsManager:stop_session(data)
	if not self._session_started then
		if data and data.quit then
			Global.statistics_manager.playing_from_start = nil
		end

		return
	end

	self:_check_days_in_row()
	Application:debug("StatisticsManager:stop_session( data ) level_id: ", Global.level_data.level_id)

	if not self._global.sessions.levels[Global.level_data.level_id] then
		return
	end

	self:_flush_log()

	self._data_log = nil
	self._session_started = nil
	local success = data and data.success
	local session_time = self:get_session_time_seconds()

	if Global.level_data.level_id then
		self._global.sessions.levels[Global.level_data.level_id].time = self._global.sessions.levels[Global.level_data.level_id].time + session_time

		if success then
			self._global.sessions.levels[Global.level_data.level_id].completed = self._global.sessions.levels[Global.level_data.level_id].completed + 1
		else
			self._global.sessions.levels[Global.level_data.level_id].quited = self._global.sessions.levels[Global.level_data.level_id].quited + 1
		end
	end

	local completion = nil
	local job_id = managers.job:current_job_id()
	local can_record_session = job_id and data and true or false
	can_record_session = can_record_session and not managers.mutators:should_disable_statistics()

	if can_record_session then
		local job_stats = self._global.sessions.jobs
		local dropped_in = not Global.statistics_manager.playing_from_start
		local stat_name = tostring(job_id)
		stat_name = stat_name .. "_" .. tostring(Global.game_settings.difficulty)
		stat_name = stat_name .. (Global.game_settings.one_down and "_od" or "")

		if data.type == "victory" then
			if managers.job:on_last_stage() then
				stat_name = stat_name .. (dropped_in and "_completed_dropin" or "_completed")
				job_stats[stat_name] = (job_stats[stat_name] or 0) + 1
				completion = dropped_in and "win_dropin" or "win_begin"
			else
				completion = "done"
			end
		elseif data.type == "gameover" then
			stat_name = stat_name .. (dropped_in and "_failed_dropin" or "_failed")
			job_stats[stat_name] = (job_stats[stat_name] or 0) + 1
			completion = "fail"
		end
	end

	self._global.sessions.time = self._global.sessions.time + session_time
	self._global.session.sessions.time = session_time
	self._global.last_session = deep_clone(self._global.session)

	self:_calculate_average()

	if data and (managers.job:on_last_stage() and data.type == "victory" or data.quit) then
		Global.statistics_manager.playing_from_start = nil
	end

	if SystemInfo:distribution() == Idstring("STEAM") then
		self:publish_to_steam(self._global.session, success, completion)

		if data and data.quit then
			Telemetry:on_end_heist("quit_game", 0)
		end
	end
end

function StatisticsManager:started_session_from_beginning()
	return self._start_session_from_beginning
end

function StatisticsManager:_increment_misc(name, amount)
	if not self._global.misc then
		self._global.misc = {}
	end

	self._global.misc[name] = (self._global.misc[name] or 0) + amount
	self._global.session.misc[name] = (self._global.session.misc[name] or 0) + amount

	if self._data_log and alive(managers.player:player_unit()) then
		table.insert(self._data_log, {
			3,
			Application:time(),
			managers.player:player_unit():position(),
			name,
			amount
		})
	end
end

function StatisticsManager:use_trip_mine()
	self:_increment_misc("deploy_trip", 1)
end

function StatisticsManager:use_ammo_bag()
	self:_increment_misc("deploy_ammo", 1)
end

function StatisticsManager:use_doctor_bag()
	self:_increment_misc("deploy_medic", 1)
end

function StatisticsManager:use_ecm_jammer()
	self:_increment_misc("deploy_jammer", 1)
end

function StatisticsManager:use_sentry_gun()
	self:_increment_misc("deploy_sentry", 1)
end

function StatisticsManager:use_first_aid()
	self:_increment_misc("deploy_firstaid", 1)
end

function StatisticsManager:use_body_bag()
	self:_increment_misc("deploy_bodybag", 1)
end

function StatisticsManager:use_armor_bag()
	self:_increment_misc("deploy_armorbag", 1)
end

function StatisticsManager:in_custody()
	self:_increment_misc("in_custody", 1)
end

function StatisticsManager:trade(data)
	self:_increment_misc("trade", 1)
end

function StatisticsManager:aquired_money(amount)
	self:_increment_misc("cash", amount * 1000)
end

function StatisticsManager:aquired_coins(coins)
	self:_increment_misc("coins", coins)
end

function StatisticsManager:mission_stats(name)
	self._global.session.mission_stats = self._global.session.mission_stats or {}
	self._global.session.mission_stats[name] = (self._global.session.mission_stats[name] or 0) + 1
end

function StatisticsManager:publish_to_steam(session, success, completion)
	if Application:editor() or not managers.criminals:local_character_name() then
		return
	end

	local max_ranks = tweak_data.infamy.ranks
	local max_specializations = tweak_data.statistics:statistics_specializations()
	local session_time_seconds = self:get_session_time_seconds()
	local session_time_minutes = session_time_seconds / 60
	local session_time = session_time_minutes / 60

	if session_time_seconds == 0 or session_time_minutes == 0 or session_time == 0 then
		return
	end

	local level_list, job_list, mask_list, weapon_list, melee_list, grenade_list, enemy_list, armor_list, character_list, deployable_list, suit_list, weapon_color_list, glove_list = tweak_data.statistics:statistics_table()
	local stats = self:check_version()
	self._global.play_time.minutes = math.ceil(self._global.play_time.minutes + session_time_minutes)
	local current_time = math.floor(self._global.play_time.minutes / 60)
	local time_found = false
	local play_times = {
		1000,
		500,
		250,
		200,
		150,
		100,
		80,
		40,
		20,
		10,
		0
	}

	for _, play_time in ipairs(play_times) do
		if not time_found and play_time <= current_time then
			stats["player_time_" .. play_time .. "h"] = {
				value = 1,
				method = "set",
				type = "int"
			}
			time_found = true
		else
			stats["player_time_" .. play_time .. "h"] = {
				value = 0,
				method = "set",
				type = "int"
			}
		end
	end

	local current_level = managers.experience:current_level()
	stats.player_level = {
		method = "set",
		type = "int",
		value = current_level
	}

	for i = 0, 100, 10 do
		stats["player_level_" .. i] = {
			value = 0,
			method = "set",
			type = "int"
		}
	end

	local level_range = current_level >= 100 and 100 or math.floor(current_level / 10) * 10
	stats["player_level_" .. level_range] = {
		value = 1,
		method = "set",
		type = "int"
	}
	local current_rank = managers.experience:current_rank()
	local current_rank_range = max_ranks < current_rank and max_ranks or current_rank
	stats.player_rank = {
		method = "set",
		type = "int",
		value = current_rank_range
	}
	local rank_found = false

	for _, rank in ipairs(tweak_data.infamy.statistics_rank_steps) do
		if not rank_found and rank <= current_rank_range then
			stats["player_rank_" .. tostring(rank)] = {
				value = 1,
				method = "set",
				type = "int"
			}
			rank_found = true
		else
			stats["player_rank_" .. tostring(rank)] = {
				value = 0,
				method = "set",
				type = "int"
			}
		end
	end

	for i = 1, max_specializations do
		local specialization = managers.skilltree:get_specialization_value(i)

		if specialization and type(specialization) == "table" and specialization.tiers and specialization.tiers.current_tier then
			stats["player_specialization_" .. i] = {
				method = "set",
				type = "int",
				value = managers.skilltree:digest_value(specialization.tiers.current_tier)
			}
		end
	end

	local current_cash = managers.money:offshore()
	local cash_found = false
	local cash_amount = 1000000000
	current_cash = current_cash / 1000

	for i = 0, 9 do
		if not cash_found and cash_amount <= current_cash then
			stats["player_cash_" .. cash_amount .. "k"] = {
				value = 1,
				method = "set",
				type = "int"
			}
			cash_found = true
		else
			stats["player_cash_" .. cash_amount .. "k"] = {
				value = 0,
				method = "set",
				type = "int"
			}
		end

		cash_amount = cash_amount / 10
	end

	stats.player_cash_0k = {
		method = "set",
		type = "int",
		value = cash_found and 0 or 1
	}
	local current_coins = managers.custom_safehouse:coins()
	local coins_found = false
	local coin_buckets = {
		0,
		24,
		48,
		72,
		96,
		120,
		144,
		168,
		192,
		216,
		240,
		264,
		288,
		312,
		336,
		360,
		384,
		408,
		432,
		456,
		480,
		500,
		600,
		700,
		800,
		900,
		1000
	}
	stats.player_coins = {
		method = "set",
		type = "int",
		value = math.floor(current_coins)
	}

	for i = #coin_buckets, 1, -1 do
		if not coins_found and coin_buckets[i] < current_coins then
			stats["player_coins_" .. tostring(coin_buckets[i])] = {
				value = 1,
				method = "set",
				type = "int"
			}
			coins_found = true
		else
			stats["player_coins_" .. tostring(coin_buckets[i])] = {
				value = 0,
				method = "set",
				type = "int"
			}
		end
	end

	stats.gadget_used_ammo_bag = {
		type = "int",
		value = session.misc.deploy_ammo or 0
	}
	stats.gadget_used_doctor_bag = {
		type = "int",
		value = session.misc.deploy_medic or 0
	}
	stats.gadget_used_trip_mine = {
		type = "int",
		value = session.misc.deploy_trip or 0
	}
	stats.gadget_used_sentry_gun = {
		type = "int",
		value = session.misc.deploy_sentry or 0
	}
	stats.gadget_used_ecm_jammer = {
		type = "int",
		value = session.misc.deploy_jammer or 0
	}
	stats.gadget_used_first_aid = {
		type = "int",
		value = session.misc.deploy_firstaid or 0
	}
	stats.gadget_used_body_bag = {
		type = "int",
		value = session.misc.deploy_bodybag or 0
	}
	stats.gadget_used_armor_bag = {
		type = "int",
		value = session.misc.deploy_armorbag or 0
	}

	if completion then
		for weapon_name, weapon_data in pairs(session.shots_by_weapon) do
			if weapon_data.total > 0 and table.contains(weapon_list, weapon_name) then
				stats["weapon_used_" .. weapon_name] = {
					value = 1,
					type = "int"
				}
				stats["weapon_shots_" .. weapon_name] = {
					type = "int",
					value = weapon_data.total
				}
				stats["weapon_hits_" .. weapon_name] = {
					type = "int",
					value = weapon_data.hits
				}
			end
		end

		local melee_name = managers.blackmarket:equipped_melee_weapon()

		if table.contains(melee_list, melee_name) then
			stats["melee_used_" .. melee_name] = {
				value = 1,
				type = "int"
			}
		end

		local grenade_name = managers.blackmarket:equipped_grenade()

		if table.contains(grenade_list, grenade_name) then
			stats["grenade_used_" .. grenade_name] = {
				value = 1,
				type = "int"
			}
		end

		local mask_id = managers.blackmarket:equipped_mask().mask_id

		if table.contains(mask_list, mask_id) then
			stats["mask_used_" .. mask_id] = {
				value = 1,
				type = "int"
			}
		end

		local armor_id = managers.blackmarket:equipped_armor()

		if table.contains(armor_list, armor_id) then
			stats["armor_used_" .. armor_id] = {
				value = 1,
				type = "int"
			}
		end

		local character_id = managers.network:session() and managers.network:session():local_peer():character()

		if table.contains(character_list, character_id) then
			stats["character_used_" .. character_id] = {
				value = 1,
				type = "int"
			}
		end

		local suit_name = managers.blackmarket:equipped_suit_string()

		if table.contains(suit_list, suit_name) then
			stats["suit_used_" .. suit_name] = {
				value = 1,
				type = "int"
			}
		end

		local glove_id = managers.blackmarket:equipped_glove_id()

		if table.contains(glove_list, glove_id) then
			stats["gloves_used_" .. glove_id] = {
				value = 1,
				type = "int"
			}
		end

		local primary = managers.blackmarket:equipped_primary()

		if primary and primary.cosmetics and table.contains(weapon_color_list, primary.cosmetics.id) then
			stats["weapon_color_used_" .. primary.cosmetics.id] = {
				value = 1,
				type = "int"
			}
		end

		local secondary = managers.blackmarket:equipped_secondary()

		if secondary and secondary.cosmetics and table.contains(weapon_color_list, secondary.cosmetics.id) then
			stats["weapon_color_used_" .. secondary.cosmetics.id] = {
				value = 1,
				type = "int"
			}
		end

		local join_stinger_index = managers.experience:current_rank() > 0 and managers.infamy:selected_join_stinger_index() or 0

		if join_stinger_index > 0 and join_stinger_index <= tweak_data.infamy.join_stingers then
			stats["join_stinger_used_" .. tostring(join_stinger_index)] = {
				value = 1,
				type = "int"
			}
		end

		stats["difficulty_" .. Global.game_settings.difficulty] = {
			value = 1,
			type = "int"
		}
		local specialization = managers.skilltree:get_specialization_value("current_specialization")

		if specialization >= 0 and specialization <= max_specializations then
			stats["specialization_used_" .. specialization] = {
				value = 1,
				type = "int"
			}
		end
	end

	for weapon_name, weapon_data in pairs(session.killed_by_weapon) do
		if weapon_data.count > 0 and table.contains(weapon_list, weapon_name) then
			stats["weapon_kills_" .. weapon_name] = {
				type = "int",
				value = weapon_data.count
			}
		end
	end

	for melee_name, melee_kill in pairs(session.killed_by_melee) do
		if melee_kill > 0 and table.contains(melee_list, melee_name) then
			stats["melee_kills_" .. melee_name] = {
				type = "int",
				value = melee_kill
			}
		end
	end

	for grenade_name, grenade_kill in pairs(session.killed_by_grenade) do
		if grenade_kill > 0 and table.contains(grenade_list, grenade_name) then
			stats["grenade_kills_" .. grenade_name] = {
				type = "int",
				value = grenade_kill
			}
		end
	end

	for enemy_name, enemy_data in pairs(session.killed) do
		if enemy_data.count > 0 and enemy_name ~= "total" and table.contains(enemy_list, enemy_name) then
			stats["enemy_kills_" .. enemy_name] = {
				type = "int",
				value = enemy_data.count
			}
		end
	end

	if completion == "win_begin" then
		if Network:is_server() then
			if Global.game_settings.kick_option == 1 then
				stats.option_decide_host = {
					value = 1,
					type = "int"
				}
			elseif Global.game_settings.kick_option == 2 then
				stats.option_decide_vote = {
					value = 1,
					type = "int"
				}
			elseif Global.game_settings.kick_option == 0 then
				stats.option_decide_none = {
					value = 1,
					type = "int"
				}
			end

			stats.info_playing_win_host = {
				value = 1,
				type = "int"
			}
		else
			stats.info_playing_win_client = {
				value = 1,
				type = "int"
			}
		end
	elseif completion == "win_dropin" then
		if not Network:is_server() then
			stats.info_playing_win_client_dropin = {
				value = 1,
				type = "int"
			}
		end
	elseif completion == "fail" then
		if Network:is_server() then
			stats.info_playing_fail_host = {
				value = 1,
				type = "int"
			}
		else
			stats.info_playing_fail_client = {
				value = 1,
				type = "int"
			}
		end
	end

	if completion == "win_begin" or completion == "win_dropin" then
		stats.heist_success = {
			value = 1,
			type = "int"
		}
	elseif completion == "fail" then
		stats.heist_failed = {
			value = 1,
			type = "int"
		}
	end

	stats.info_playing_pc = {
		value = 1,
		method = "set",
		type = "int"
	}
	local level_id = managers.job:current_level_id()

	if completion then
		if table.contains(level_list, level_id) then
			stats["level_" .. level_id] = {
				value = 1,
				type = "int"
			}
		end

		if level_id == "election_day_2" then
			local stealth = managers.groupai and managers.groupai:state():whisper_mode()

			print("[StatisticsManager]: Election Day 2 Voting: " .. (stealth and "Swing Vote" or "Delayed Vote"))

			stats["stats_election_day_" .. (stealth and "s" or "n")] = {
				value = 1,
				type = "int"
			}
		end
	end

	local job_id = managers.job:current_job_id()

	if table.contains(job_list, job_id) then
		stats["job_" .. job_id] = {
			value = 1,
			type = "int"
		}

		if completion == "win_begin" then
			stats["contract_" .. job_id .. "_win"] = {
				value = 1,
				type = "int"
			}
		elseif completion == "win_dropin" then
			stats["contract_" .. job_id .. "_win_dropin"] = {
				value = 1,
				type = "int"
			}
		elseif completion == "fail" then
			stats["contract_" .. job_id .. "_fail"] = {
				value = 1,
				type = "int"
			}
		end
	end

	if session.mission_stats then
		for name, count in pairs(session.mission_stats) do
			print("Mission Statistics: mission_" .. name, count)

			stats["mission_" .. name] = {
				type = "int",
				value = count
			}
		end
	end

	local roman_rank_setting = managers.user:get_setting("infamy_roman_rank")
	stats.setting_roman_rank_on = {
		method = "set",
		type = "int",
		value = roman_rank_setting and 1 or 0
	}
	stats.setting_roman_rank_off = {
		method = "set",
		type = "int",
		value = roman_rank_setting and 0 or 1
	}
	local roman_card_setting = managers.user:get_setting("infamy_roman_card")
	stats.setting_roman_card_on = {
		method = "set",
		type = "int",
		value = roman_card_setting and 1 or 0
	}
	stats.setting_roman_card_off = {
		method = "set",
		type = "int",
		value = roman_card_setting and 0 or 1
	}

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:publish_level_to_steam()
	if Application:editor() then
		return
	end

	local max_ranks = tweak_data.infamy.ranks
	local stats = {}
	local current_level = managers.experience:current_level()
	stats.player_level = {
		method = "set",
		type = "int",
		value = current_level
	}

	for i = 0, 100, 10 do
		stats["player_level_" .. i] = {
			value = 0,
			method = "set",
			type = "int"
		}
	end

	local level_range = current_level >= 100 and 100 or math.floor(current_level / 10) * 10
	stats["player_level_" .. level_range] = {
		value = 1,
		method = "set",
		type = "int"
	}
	local current_rank = managers.experience:current_rank()
	local current_rank_range = max_ranks < current_rank and max_ranks or current_rank
	stats.player_rank = {
		method = "set",
		type = "int",
		value = current_rank_range
	}
	local rank_found = false

	for _, rank in ipairs(tweak_data.infamy.statistics_rank_steps) do
		if not rank_found and rank <= current_rank_range then
			stats["player_rank_" .. tostring(rank)] = {
				value = 1,
				method = "set",
				type = "int"
			}
			rank_found = true
		else
			stats["player_rank_" .. tostring(rank)] = {
				value = 0,
				method = "set",
				type = "int"
			}
		end
	end

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:publish_custom_stat_to_steam(name, value)
	if Application:editor() then
		return
	end

	local stats = {
		[name] = {
			type = "int"
		}
	}

	if value then
		stats[name].value = value
	else
		stats[name].method = "set"
		stats[name].value = 1
	end

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:_table_contains(list, item)
	for index, name in pairs(list) do
		if name == item then
			return index
		end
	end
end

function StatisticsManager:gather_equipment_data()
	if Application:editor() then
		return
	end

	local stats = {}
	local level_list, job_list, mask_list, weapon_list, melee_list, grenade_list, enemy_list, armor_list, character_list, deployable_list, suit_list, weapon_color_list, glove_list = tweak_data.statistics:statistics_table()
	local mask_name = managers.blackmarket:equipped_mask().mask_id
	local mask_index = self:_table_contains(mask_list, mask_name)

	if mask_index then
		stats.equipped_mask = {
			method = "set",
			type = "int",
			value = mask_index
		}
	end

	local primary_name = managers.blackmarket:equipped_primary().weapon_id
	local primary_index = self:_table_contains(weapon_list, primary_name)

	if primary_index then
		stats.equipped_primary = {
			method = "set",
			type = "int",
			value = primary_index
		}
	end

	local secondary_name = managers.blackmarket:equipped_secondary().weapon_id
	local secondary_index = self:_table_contains(weapon_list, secondary_name)

	if secondary_index then
		stats.equipped_secondary = {
			method = "set",
			type = "int",
			value = secondary_index
		}
	end

	local melee_name = managers.blackmarket:equipped_melee_weapon()
	local melee_index = self:_table_contains(melee_list, melee_name)

	if melee_index then
		stats.equipped_melee = {
			method = "set",
			type = "int",
			value = melee_index
		}
	end

	local grenade_name = managers.blackmarket:equipped_grenade()
	local grenade_index = self:_table_contains(grenade_list, grenade_name)

	if grenade_index then
		stats.equipped_grenade = {
			method = "set",
			type = "int",
			value = grenade_index
		}
	end

	local armor_name = managers.blackmarket:equipped_armor()
	local armor_index = self:_table_contains(armor_list, armor_name)

	if armor_index then
		stats.equipped_armor = {
			method = "set",
			type = "int",
			value = armor_index
		}
	end

	local character_name = managers.blackmarket:get_preferred_character()
	local character_index = self:_table_contains(character_list, character_name)

	if character_index then
		stats.equipped_character = {
			method = "set",
			type = "int",
			value = character_index
		}
	end

	local deployable_name = managers.blackmarket:equipped_deployable()
	local deployable_index = self:_table_contains(deployable_list, deployable_name)

	if deployable_index then
		stats.equipped_deployable = {
			method = "set",
			type = "int",
			value = deployable_index
		}
	end

	local suit_name = managers.blackmarket:equipped_suit_string()
	local suit_index = self:_table_contains(suit_list, suit_name)

	if suit_index then
		stats.equipped_suit = {
			method = "set",
			type = "int",
			value = suit_index
		}
	end

	local glove_id = managers.blackmarket:equipped_glove_id()
	local glove_index = self:_table_contains(glove_list, glove_id)

	if glove_index then
		stats.equipped_glove_id = {
			method = "set",
			type = "int",
			value = glove_index
		}
	end

	local join_stinger_index = managers.experience:current_rank() > 0 and managers.infamy:selected_join_stinger_index() or 0

	if join_stinger_index > 0 and join_stinger_index <= tweak_data.infamy.join_stingers then
		stats.equipped_join_stinger = {
			method = "set",
			type = "int",
			value = join_stinger_index
		}
	end

	return stats
end

function StatisticsManager:publish_equipped_to_steam()
	if Global.block_publish_equipped_to_steam then
		return
	end

	local stats = self:gather_equipment_data()

	if not stats then
		return
	end

	managers.network.account:publish_statistics(stats)
	Telemetry:send_on_player_change_loadout(stats)
end

function StatisticsManager:publish_skills_to_steam(skip_version_check)
	if Application:editor() then
		return
	end

	local stats = skip_version_check and {} or self:check_version()
	local skill_amount = {}
	local skill_data = tweak_data.skilltree.skills
	local tree_data = tweak_data.skilltree.trees

	for tree_index, tree in ipairs(tree_data) do
		if tree.statistics ~= false then
			skill_amount[tree_index] = 0

			for _, tier in ipairs(tree.tiers) do
				for _, skill in ipairs(tier) do
					if skill_data[skill].statistics ~= false then
						local skill_points = managers.skilltree:next_skill_step(skill)
						local skill_bought = skill_points > 1 and 1 or 0
						local skill_aced = skill_points > 2 and 1 or 0
						stats["skill_" .. tree.skill .. "_" .. skill] = {
							method = "set",
							type = "int",
							value = skill_bought
						}
						stats["skill_" .. tree.skill .. "_" .. skill .. "_ace"] = {
							method = "set",
							type = "int",
							value = skill_aced
						}
						skill_amount[tree_index] = skill_amount[tree_index] + skill_bought + skill_aced
					end
				end
			end
		end
	end

	for tree_index, tree in ipairs(tree_data) do
		if tree.statistics ~= false then
			stats["skill_" .. tree.skill] = {
				method = "set",
				type = "int",
				value = skill_amount[tree_index]
			}

			for i = 0, 35, 5 do
				stats["skill_" .. tree.skill .. "_" .. i] = {
					value = 0,
					method = "set",
					type = "int"
				}
			end

			local skill_count = math.ceil(skill_amount[tree_index] / 5) * 5

			if skill_count > 35 then
				skill_count = 35
			end

			stats["skill_" .. tree.skill .. "_" .. skill_count] = {
				value = 1,
				method = "set",
				type = "int"
			}
		end
	end

	local specialization = managers.skilltree:get_specialization_value("current_specialization")
	stats.player_specialization_active = {
		method = "set",
		type = "int",
		value = specialization or 0
	}

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:check_version()
	local CURRENT_VERSION = 2
	local stats = {}
	local resolution = string.format("%dx%d", RenderSettings.resolution.x, RenderSettings.resolution.y)
	local resolution_list = tweak_data.statistics:resolution_statistics_table()

	for _, res in pairs(resolution_list) do
		stats["option_resolution_" .. res] = {
			value = 0,
			method = "set",
			type = "int"
		}
	end

	stats.option_resolution_other = {
		value = 0,
		method = "set",
		type = "int"
	}
	stats[table.contains(resolution_list, resolution) and "option_resolution_" .. resolution or "option_resolution_other"] = {
		value = 1,
		method = "set",
		type = "int"
	}

	if managers.network.account:get_stat("stat_version") < CURRENT_VERSION then
		self:publish_skills_to_steam(true)

		stats.stat_version = {
			method = "set",
			type = "int",
			value = CURRENT_VERSION
		}
	end

	return stats
end

function StatisticsManager:debug_estimate_steam_players()
	local key = nil
	local stats = {}
	local account = managers.network.account
	local days = 60
	local num_players = 0
	local play_times = {
		0,
		10,
		20,
		40,
		80,
		100,
		150,
		200,
		250,
		500,
		1000
	}

	for _, play_time in ipairs(play_times) do
		key = "player_time_" .. play_time .. "h"
		num_players = num_players + account:get_global_stat(key, days)
	end

	Application:debug(managers.money:add_decimal_marks_to_string(tostring(num_players)) .. " players have summited statistics to Steam the last 60 days.")
end

function StatisticsManager:_calculate_average()
	local t = self._global.sessions.count ~= 0 and self._global.sessions.count or 1
	self._global.average = {
		killed = deep_clone(self._global.killed),
		sessions = deep_clone(self._global.sessions),
		revives = deep_clone(self._global.revives)
	}

	for _, data in pairs(self._global.average.killed) do
		data.count = math.round(data.count / t)
		data.head_shots = math.round(data.head_shots / t)
		data.melee = math.round(data.melee / t)
		data.explosion = math.round(data.explosion / t)
	end

	self._global.average.sessions.time = self._global.average.sessions.time / t

	for lvl, data in pairs(self._global.average.sessions.levels) do
		data.time = data.time / t
	end

	for counter, value in pairs(self._global.average.revives) do
		self._global.average.revives[counter] = math.round(value / t)
	end

	self._global.average.shots_fired = deep_clone(self._global.shots_fired)
	self._global.average.shots_fired.total = math.round(self._global.average.shots_fired.total / t)
	self._global.average.shots_fired.hits = math.round(self._global.average.shots_fired.hits / t)
	self._global.average.downed = deep_clone(self._global.downed)
	self._global.average.downed.bleed_out = math.round(self._global.average.downed.bleed_out / t)
	self._global.average.downed.fatal = math.round(self._global.average.downed.fatal / t)
	self._global.average.downed.incapacitated = math.round(self._global.average.downed.incapacitated / t)
	self._global.average.downed.death = math.round(self._global.average.downed.death / t)
	self._global.average.reloads = deep_clone(self._global.reloads)
	self._global.average.reloads.count = math.round(self._global.average.reloads.count / t)
	self._global.average.experience = deep_clone(self._global.experience)

	for size, data in pairs(self._global.average.experience) do
		if data.actions then
			data.count = math.round(data.count / t)

			for action, count in pairs(data.actions) do
				data.actions[action] = math.round(count / t)
			end
		end
	end
end

function StatisticsManager:_get_boom_guns()
	if not self._boom_guns then
		self._boom_guns = {
			"gre_m79",
			"huntsman",
			"r870",
			"saiga",
			"ksg",
			"striker",
			"serbu",
			"benelli",
			"judge",
			"rpg7",
			"m32",
			"china",
			"b682",
			"m37",
			"spas12",
			"frankish",
			"arblast",
			"hunter",
			"plainsrider",
			"long",
			"arbiter",
			"ray",
			"contraband_m203"
		}
	end

	return self._boom_guns
end

function StatisticsManager:killed_by_anyone(data)
	local name_id = alive(data.weapon_unit) and data.weapon_unit:base():get_name_id()

	managers.achievment:set_script_data("pacifist_fail", true)

	if name_id ~= "m79" and name_id ~= "m79_crew" then
		managers.achievment:set_script_data("blow_out_fail", true)
	end

	local kills_table = self._global.session.killed_by_anyone
	local by_bullet = data.variant == "bullet"
	local by_melee = data.variant == "melee" or (data.name_id or data.name) and tweak_data.blackmarket.melee_weapons[data.name_id or data.name]
	local by_explosion = data.variant == "explosion"
	local by_other_variant = not by_bullet and not by_melee and not by_explosion
	local is_molotov = data.is_molotov

	if by_bullet then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			kills_table.killed_by_grenade[throwable_id] = (kills_table.killed_by_grenade[throwable_id] or 0) + 1
		else
			self:_add_to_killed_by_weapon(kills_table, name_id, data, false)
		end
	elseif by_melee then
		local name_id = data.name_id or data.name or "unknown"

		if name_id then
			kills_table.killed_by_melee[name_id] = (kills_table.killed_by_melee[name_id] or 0) + 1
		end
	elseif by_explosion then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			kills_table.killed_by_grenade[throwable_id] = (kills_table.killed_by_grenade[throwable_id] or 0) + 1
		end

		if name_id and table.contains(self:_get_boom_guns(), name_id) then
			self:_add_to_killed_by_weapon(kills_table, name_id, data, false)
		end
	elseif by_other_variant then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			kills_table.killed_by_grenade[throwable_id] = (kills_table.killed_by_grenade[throwable_id] or 0) + 1
		elseif is_molotov then
			if type(is_molotov) == "boolean" then
				kills_table.killed_by_grenade.molotov = (kills_table.killed_by_grenade.molotov or 0) + 1
			else
				kills_table.killed_by_grenade[is_molotov] = (kills_table.killed_by_grenade[is_molotov] or 0) + 1
			end
		else
			self:_add_to_killed_by_weapon(kills_table, name_id, data, false)
		end
	end
end

function StatisticsManager:killed(data)
	local stats_name = data.stats_name or data.name
	data.type = tweak_data.character[data.name] and tweak_data.character[data.name].challenges.type

	if not self._global.killed[stats_name] or not self._global.session.killed[stats_name] then
		Application:error("Bad name id applied to killed, " .. tostring(stats_name) .. ". Defaulting to 'other'")

		stats_name = "other"
	end

	local by_bullet = data.variant == "bullet"
	local by_melee = data.variant == "melee" or data.weapon_id and tweak_data.blackmarket.melee_weapons[data.weapon_id]
	local by_explosion = data.variant == "explosion"
	local by_other_variant = not by_bullet and not by_melee and not by_explosion
	local type = self._global.killed[stats_name]
	type.count = type.count + 1
	type.head_shots = type.head_shots + (data.head_shot and 1 or 0)
	type.melee = type.melee + (by_melee and 1 or 0)
	type.explosion = type.explosion + (by_explosion and 1 or 0)
	self._global.killed.total.count = self._global.killed.total.count + 1
	self._global.killed.total.head_shots = self._global.killed.total.head_shots + (data.head_shot and 1 or 0)
	self._global.killed.total.melee = self._global.killed.total.melee + (by_melee and 1 or 0)
	self._global.killed.total.explosion = self._global.killed.total.explosion + (by_explosion and 1 or 0)
	local type = self._global.session.killed[stats_name]
	type.count = type.count + 1
	type.head_shots = type.head_shots + (data.head_shot and 1 or 0)
	type.melee = type.melee + (by_melee and 1 or 0)
	type.explosion = type.explosion + (by_explosion and 1 or 0)
	self._global.session.killed.total.count = self._global.session.killed.total.count + 1
	self._global.session.killed.total.head_shots = self._global.session.killed.total.head_shots + (data.head_shot and 1 or 0)
	self._global.session.killed.total.melee = self._global.session.killed.total.melee + (by_melee and 1 or 0)
	self._global.session.killed.total.explosion = self._global.session.killed.total.explosion + (by_explosion and 1 or 0)

	if by_bullet then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			self._global.session.killed_by_grenade[throwable_id] = (self._global.session.killed_by_grenade[throwable_id] or 0) + 1
			self._global.killed_by_grenade[throwable_id] = (self._global.killed_by_grenade[throwable_id] or 0) + 1
		else
			self:_add_to_killed_by_weapon(self._global.session, name_id, data, true)

			if self._global.session.killed_by_weapon[name_id] and self._global.session.killed_by_weapon[name_id].count == tweak_data.achievement.first_blood.count then
				local category = data.weapon_unit:base():weapon_tweak_data().categories[1]

				if category == tweak_data.achievement.first_blood.weapon_type then
					managers.achievment:award(tweak_data.achievement.first_blood.award)
				end
			end

			if data.name == "tank" then
				managers.achievment:set_script_data("dodge_this_active", true)
			end
		end
	elseif by_melee then
		local name_id = data.name or data.name_id
		self._global.session.killed_by_melee[name_id] = (self._global.session.killed_by_melee[name_id] or 0) + 1
		self._global.killed_by_melee[name_id] = (self._global.killed_by_melee[name_id] or 0) + 1
	elseif by_explosion then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			self._global.session.killed_by_grenade[throwable_id] = (self._global.session.killed_by_grenade[throwable_id] or 0) + 1
			self._global.killed_by_grenade[throwable_id] = (self._global.killed_by_grenade[throwable_id] or 0) + 1
		end

		if name_id and table.contains(self:_get_boom_guns(), name_id) then
			self:_add_to_killed_by_weapon(self._global.session, name_id, data, true)
		end
	elseif by_other_variant then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			self._global.session.killed_by_grenade[throwable_id] = (self._global.session.killed_by_grenade[throwable_id] or 0) + 1
			self._global.killed_by_grenade[throwable_id] = (self._global.killed_by_grenade[throwable_id] or 0) + 1
		else
			self:_add_to_killed_by_weapon(self._global.session, name_id, data, true)
		end
	end
end

function StatisticsManager:_add_to_killed_by_weapon(kills_table, name_id, data, add_global)
	if not name_id then
		return
	end

	kills_table.killed_by_weapon[name_id] = kills_table.killed_by_weapon[name_id] or {
		count = 0,
		headshots = 0
	}
	kills_table.killed_by_weapon[name_id].count = kills_table.killed_by_weapon[name_id].count + 1
	kills_table.killed_by_weapon[name_id].headshots = kills_table.killed_by_weapon[name_id].headshots + (data.head_shot and 1 or 0)

	if add_global then
		self._global.killed_by_weapon[name_id] = self._global.killed_by_weapon[name_id] or {
			count = 0,
			headshots = 0
		}
		self._global.killed_by_weapon[name_id].count = self._global.killed_by_weapon[name_id].count + 1
		self._global.killed_by_weapon[name_id].headshots = (self._global.killed_by_weapon[name_id].headshots or 0) + (data.head_shot and 1 or 0)
	end
end

function StatisticsManager:_get_name_id_and_throwable_id(weapon_unit)
	if not alive(weapon_unit) then
		return nil, nil
	end

	if weapon_unit:base().projectile_entry then
		local projectile_data = tweak_data.blackmarket.projectiles[weapon_unit:base():projectile_entry()]
		local name_id = projectile_data.weapon_id
		local throwable_id = projectile_data.throwable and weapon_unit:base():projectile_entry()

		return name_id, throwable_id
	elseif weapon_unit:base().get_name_id then
		local name_id = weapon_unit:base():get_name_id()

		return name_id, nil
	end
end

function StatisticsManager:register_melee_hit()
	self._global.session.melee_hit = true
end

function StatisticsManager:completed_job(job_id, difficulty, require_one_down)
	local job_stats = self._global.sessions.jobs
	local tweak_jobs = tweak_data.narrative.jobs
	local job_wrapper = nil

	if tweak_data.narrative:has_job_wrapper(job_id) then
		job_wrapper = tweak_jobs[job_id].job_wrapper
	elseif tweak_data.narrative:is_wrapped_to_job(job_id) then
		job_wrapper = tweak_jobs[tweak_jobs[job_id].wrapped_to_job].job_wrapper
	end

	local function single_job_count(job_id, difficulty, require_one_down)
		local stat_prefix = tostring(job_id) .. "_" .. tostring(difficulty)
		local stat_suffix = "_completed"
		local count = 0
		count = count + (job_stats[stat_prefix .. "_od" .. stat_suffix] or 0)

		if not require_one_down then
			count = count + (job_stats[stat_prefix .. stat_suffix] or 0)
		end

		return count
	end

	local count = 0

	if job_wrapper then
		local count = 0

		for _, wrapped_job in ipairs(job_wrapper) do
			count = count + single_job_count(wrapped_job, difficulty, require_one_down)
		end

		return count
	end

	return single_job_count(job_id, difficulty, require_one_down)
end

function StatisticsManager:tied(data)
	data.type = tweak_data.character[data.name] and tweak_data.character[data.name].challenges.type

	if not self._global.killed[data.name] or not self._global.session.killed[data.name] then
		Application:error("Bad name id applied to tied, " .. tostring(data.name) .. ". Defaulting to 'other'")

		data.name = "other"
	end

	self._global.killed[data.name].tied = (self._global.killed[data.name].tied or 0) + 1
	self._global.session.killed[data.name].tied = self._global.session.killed[data.name].tied + 1

	if self._data_log and alive(managers.player:player_unit()) then
		table.insert(self._data_log, {
			3,
			Application:time(),
			managers.player:player_unit():position(),
			"tiedown",
			1
		})
	end
end

function StatisticsManager:revived(data)
	if not data.reviving_unit or data.reviving_unit ~= managers.player:player_unit() then
		return
	end

	local counter = data.npc and "npc_count" or "player_count"
	self._global.revives[counter] = self._global.revives[counter] + 1
	self._global.session.revives[counter] = self._global.session.revives[counter] + 1

	if self._data_log and alive(managers.player:player_unit()) then
		table.insert(self._data_log, {
			3,
			Application:time(),
			managers.player:player_unit():position(),
			"revive",
			1
		})
	end
end

function StatisticsManager:camera_destroyed(data)
	self._global.cameras.count = self._global.cameras.count + 1
	self._global.session.cameras.count = self._global.session.cameras.count + 1
end

function StatisticsManager:objective_completed(data)
	if managers.platform:presence() ~= "Playing" and managers.platform:presence() ~= "Mission_end" then
		return
	end

	self._global.objectives.count = self._global.objectives.count + 1
	self._global.session.objectives.count = self._global.session.objectives.count + 1
end

function StatisticsManager:health_subtracted(amount)
	self._global.health.amount_lost = self._global.health.amount_lost + amount
	self._global.session.health.amount_lost = self._global.session.health.amount_lost + amount
end

function StatisticsManager:shot_fired(data)
	local name_id = data.name_id or data.weapon_unit:base():get_name_id()

	if not self._global.session.used_weapons[name_id] then
		if Network:is_server() then
			self:used_weapon(name_id)
		else
			managers.network:session():send_to_host("client_used_weapon", name_id)
		end
	end

	if not data.skip_bullet_count then
		self._global.shots_fired.total = self._global.shots_fired.total + 1
		self._global.session.shots_fired.total = self._global.session.shots_fired.total + 1
		self._global.session.shots_by_weapon[name_id] = self._global.session.shots_by_weapon[name_id] or {
			total = 0,
			hits = 0
		}
		self._global.session.shots_by_weapon[name_id].total = self._global.session.shots_by_weapon[name_id].total + 1
		self._global.shots_by_weapon[name_id] = self._global.shots_by_weapon[name_id] or {
			total = 0,
			hits = 0
		}
		self._global.shots_by_weapon[name_id].total = self._global.shots_by_weapon[name_id].total + 1
	end

	if data.hit then
		local count = data.hit_count or 1
		self._global.shots_fired.hits = self._global.shots_fired.hits + count
		self._global.session.shots_fired.hits = self._global.session.shots_fired.hits + count
		self._global.session.shots_by_weapon[name_id] = self._global.session.shots_by_weapon[name_id] or {
			total = 0,
			hits = 0
		}
		self._global.session.shots_by_weapon[name_id].hits = self._global.session.shots_by_weapon[name_id].hits + count
		self._global.shots_by_weapon[name_id] = self._global.shots_by_weapon[name_id] or {
			total = 0,
			hits = 0
		}
		self._global.shots_by_weapon[name_id].hits = self._global.shots_by_weapon[name_id].hits + count
	end
end

function StatisticsManager:used_weapon(weapon_id)
	if not Network:is_server() then
		return
	end

	self:_used_weapon(weapon_id)
	managers.network:session():send_to_peers("sync_used_weapon", weapon_id)
end

function StatisticsManager:_used_weapon(weapon_id)
	self._global.session.used_weapons[weapon_id] = true
end

function StatisticsManager:downed(data)
	managers.achievment:set_script_data("stand_together_fail", true)

	local counter = data.bleed_out and "bleed_out" or data.fatal and "fatal" or data.incapacitated and "incapacitated" or "death"
	self._global.downed[counter] = self._global.downed[counter] + 1
	self._global.session.downed[counter] = self._global.session.downed[counter] + 1

	if self._data_log and alive(managers.player:player_unit()) then
		table.insert(self._data_log, {
			3,
			Application:time(),
			managers.player:player_unit():position(),
			"downed",
			1
		})
	end
end

function StatisticsManager:reloaded(data)
	self._global.reloads.count = self._global.reloads.count + 1
	self._global.session.reloads.count = self._global.session.reloads.count + 1

	if self._data_log and alive(managers.player:player_unit()) then
		table.insert(self._data_log, {
			3,
			Application:time(),
			managers.player:player_unit():position(),
			"reloaded",
			1
		})
	end
end

function StatisticsManager:recieved_experience(data)
	self._global.experience[data.size] = self._global.experience[data.size] or {
		count = 0,
		actions = {}
	}
	self._global.experience[data.size].count = self._global.experience[data.size].count + 1
	self._global.experience[data.size].actions[data.action] = self._global.experience[data.size].actions[data.action] or 0
	self._global.experience[data.size].actions[data.action] = self._global.experience[data.size].actions[data.action] + 1
	self._global.session.experience[data.size] = self._global.session.experience[data.size] or {
		count = 0,
		actions = {}
	}
	self._global.session.experience[data.size].count = self._global.session.experience[data.size].count + 1
	self._global.session.experience[data.size].actions[data.action] = self._global.session.experience[data.size].actions[data.action] or 0
	self._global.session.experience[data.size].actions[data.action] = self._global.session.experience[data.size].actions[data.action] + 1
end

function StatisticsManager:get_killed()
	return self._global.killed
end

function StatisticsManager:get_play_time()
	return self._global and self._global.play_time and self._global.play_time.minutes or 0
end

function StatisticsManager:get_play_time_hours()
	return self:get_play_time() / 60
end

function StatisticsManager:count_up(id)
	if not self._statistics[id] then
		Application:stack_dump_error("Bad id to count up, " .. tostring(id) .. ".")

		return
	end

	self._statistics[id].count = self._statistics[id].count + 1
end

function StatisticsManager:print_stats()
	local time_text = self:_time_text(math.round(self._global.sessions.time))
	local time_average_text = self:_time_text(math.round(self._global.average.sessions.time))
	local t = self._global.sessions.count ~= 0 and self._global.sessions.count or 1

	print("- Sessions \t\t-")
	print("Total sessions:\t", self._global.sessions.count)
	print("Total time:\t\t", time_text)
	print("Average time:\t", time_average_text)
	print("\n- Levels \t\t-")

	for name, data in pairs(self._global.sessions.levels) do
		local time_text = self:_time_text(math.round(data.time))

		print("Started: " .. data.started .. "\tBeginning: " .. data.from_beginning .. "\tDrop in: " .. data.drop_in .. "\tCompleted: " .. data.completed .. "\tQuited: " .. data.quited .. "\tTime: " .. time_text .. "\t- " .. name)
	end

	print("\n- Kills \t\t-")

	for name, data in pairs(self._global.killed) do
		print("Count: " .. self:_amount_format(data.count) .. "/" .. self:_amount_format(self._global.average.killed[name].count, true) .. " Head shots: " .. self:_amount_format(data.head_shots) .. "/" .. self:_amount_format(self._global.average.killed[name].head_shots, true) .. " Melee: " .. self:_amount_format(data.melee) .. "/" .. self:_amount_format(self._global.average.killed[name].melee, true) .. " Explosion: " .. self:_amount_format(data.explosion) .. "/" .. self:_amount_format(self._global.average.killed[name].explosion, true) .. " " .. name)
	end

	print("\n- Revives \t\t-")
	print("Count: " .. self._global.revives.npc_count .. "/" .. self._global.average.revives.npc_count .. "\t- Npcs")
	print("Count: " .. self._global.revives.player_count .. "/" .. self._global.average.revives.player_count .. "\t- Players")
	print("\n- Cameras \t\t-")
	print("Count: " .. self._global.cameras.count)
	print("\n- Objectives \t-")
	print("Count: " .. self._global.objectives.count)
	print("\n- Shots fired \t-")
	print("Total: " .. self._global.shots_fired.total .. "/" .. self._global.average.shots_fired.total)
	print("Hits: " .. self._global.shots_fired.hits .. "/" .. self._global.average.shots_fired.hits)
	print("Hit percentage: " .. math.round(self._global.shots_fired.hits / (self._global.shots_fired.total ~= 0 and self._global.shots_fired.total or 1) * 100) .. "%")
	print("\n- Downed \t-")
	print("Bleed out: " .. self._global.downed.bleed_out .. "/" .. self._global.average.downed.bleed_out)
	print("Fatal: " .. self._global.downed.fatal .. "/" .. self._global.average.downed.fatal)
	print("Incapacitated: " .. self._global.downed.incapacitated .. "/" .. self._global.average.downed.incapacitated)
	print("Death: " .. self._global.downed.death .. "/" .. self._global.average.downed.death)
	print("\n- Reloads \t-")
	print("Count: " .. self._global.reloads.count .. "/" .. self._global.average.reloads.count)
	self:_print_experience_stats()
end

function StatisticsManager:is_dropin()
	return self._start_session_drop_in
end

function StatisticsManager:_print_experience_stats()
	local t = self._global.sessions.count ~= 0 and self._global.sessions.count or 1
	local average = self._global.average.experience
	local total = 0

	print("\n- Experience -")

	for size, data in pairs(self._global.experience) do
		local exp = tweak_data.experience_manager.values[size]
		local average_count = average[size] and self:_amount_format(average[size].count, true) or "-"
		local average_exp = average[size] and self:_amount_format(exp * average[size].count, true) or "-"
		total = total + exp * data.count

		print("\nSize: " .. size .. " " .. self:_amount_format(exp, true) .. "" .. self:_amount_format(data.count) .. "/" .. average_count .. " " .. self:_amount_format(exp * data.count) .. "/" .. average_exp)

		for action, count in pairs(data.actions) do
			local average_count = average[size] and average[size].actions[action] and self:_amount_format(average[size].actions[action], true) or "-"
			local average_exp = average[size] and average[size].actions[action] and self:_amount_format(exp * average[size].actions[action], true) or "-"

			print("\tAction: " .. action)
			print("\t\tCount:" .. self:_amount_format(count) .. "/" .. average_count .. self:_amount_format(exp * count) .. "/" .. average_exp)
		end
	end

	print("\nTotal:" .. self:_amount_format(total) .. "/" .. self:_amount_format(total / t, true))
end

function StatisticsManager:_amount_format(amount, left)
	amount = math.round(amount)
	local s = ""

	for i = 6 - string.len(amount), 0, -1 do
		s = s .. " "
	end

	return left and amount .. s or s .. amount
end

function StatisticsManager:_time_text(time, params)
	local no_days = params and params.no_days
	local days = no_days and 0 or math.floor(time / 86400)
	time = time - days * 86400
	local hours = math.floor(time / 3600)
	time = time - hours * 3600
	local minutes = math.floor(time / 60)
	time = time - minutes * 60
	local seconds = math.round(time)

	return (no_days and "" or (days < 10 and "0" .. days or days) .. ":") .. (hours < 10 and "0" .. hours or hours) .. ":" .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
end

function StatisticsManager:_check_loaded_data()
	if not self._global.downed.incapacitated then
		self._global.downed.incapacitated = 0
	end

	for name, data in pairs(self._defaults.killed) do
		self._global.killed[name] = self._global.killed[name] or deep_clone(self._defaults.killed[name])
	end

	for name, data in pairs(self._global.killed) do
		data.melee = data.melee or 0
		data.explosion = data.explosion or 0
	end

	for name, lvl in pairs(self._defaults.sessions.levels) do
		self._global.sessions.levels[name] = self._global.sessions.levels[name] or deep_clone(lvl)
	end

	for _, lvl in pairs(self._global.sessions.levels) do
		lvl.drop_in = lvl.drop_in or 0
		lvl.from_beginning = lvl.from_beginning or 0
	end

	self._global.sessions.jobs = self._global.sessions.jobs or {}
	self._global.experience = self._global.experience or deep_clone(self._defaults.experience)
	self._global.stat_check = self._global.stat_check or {}

	if managers.achievment:get_info("fin_1").awarded then
		self._global.stat_check.h = managers.custom_safehouse:uno_achievement_challenge():uno_ending_key()
	end

	self:_migrate_job_completion_stats()
end

function StatisticsManager:_migrate_job_completion_stats()
	local from_version = self._global.sessions.job_stats_version or 1
	local job_stats = self._global.sessions.jobs

	if from_version == 1 then
		local migrated_stats = {}
		local job_stats = self._global.sessions.jobs

		for key, stat in pairs(job_stats) do
			local job_id, suffix = key:match("([%w_]+)_sm_wish_([%w_]+)")

			if job_id then
				local new_stat_name = job_id .. "_sm_wish_od_" .. suffix
				migrated_stats[new_stat_name] = job_stats[key]
			else
				migrated_stats[key] = stat
			end
		end

		self._global.sessions.jobs = migrated_stats

		if managers.achievment.achievments.axe_66.awarded then
			managers.achievment:award("ggez_1")
		end
	end

	self._global.sessions.job_stats_version = StatisticsManager.JOB_STATS_VERSION
end

function StatisticsManager:time_played()
	local time = math.round(self._global.sessions.time)
	local time_text = self:_time_text(time)

	return time_text, time
end

function StatisticsManager:favourite_level()
	local started = 0
	local c_name = nil

	for name, data in pairs(self._global.sessions.levels) do
		if started < data.started then
			c_name = name or c_name
		end

		if started < data.started then
			started = data.started or started
		end
	end

	return c_name and tweak_data.levels:get_localized_level_name_from_level_id(c_name) or managers.localization:text("debug_undecided")
end

function StatisticsManager:total_completed_campaigns()
	local i = 0

	for name, data in pairs(self._global.sessions.levels) do
		i = i + data.completed
	end

	return i
end

function StatisticsManager:favourite_weapon()
	local weapon_id = nil
	local count = 0

	for id, data in pairs(self._global.killed_by_weapon) do
		if count < data.count then
			count = data.count
			weapon_id = id
		end
	end

	return weapon_id and managers.localization:text(tweak_data.weapon[weapon_id].name_id) or managers.localization:text("debug_undecided")
end

function StatisticsManager:total_kills()
	return self._global.killed.total.count
end

function StatisticsManager:total_head_shots()
	return self._global.killed.total.head_shots
end

function StatisticsManager:hit_accuracy()
	if self._global.shots_fired.total == 0 then
		return 0
	end

	return math.floor(self._global.shots_fired.hits / self._global.shots_fired.total * 100)
end

function StatisticsManager:total_completed_objectives()
	return self._global.objectives.count
end

function StatisticsManager:total_downed()
	return self._global.session.downed.bleed_out + self._global.session.downed.incapacitated
end

function StatisticsManager:session_time_played()
	local time = math.round(self._global.session.sessions.time)
	local time_text = self:_time_text(time, {
		no_days = true
	})

	return time_text, time
end

function StatisticsManager:completed_objectives()
	return self._global.session.objectives.count
end

function StatisticsManager:session_favourite_weapon()
	local weapon_id = nil
	local count = 0

	for id, data in pairs(self._global.session.killed_by_weapon) do
		if count < data.count then
			count = data.count
			weapon_id = id
		end
	end

	local weapon_tweak_data = tweak_data.weapon[weapon_id]

	if not weapon_tweak_data then
		return managers.localization:text("debug_undecided")
	end

	return weapon_id and managers.localization:text(weapon_tweak_data.name_id) or managers.localization:text("debug_undecided")
end

function StatisticsManager:session_used_weapons()
	local weapons_used = {}

	if self._global.session.shots_by_weapon then
		for weapon, _ in pairs(self._global.session.shots_by_weapon) do
			table.insert(weapons_used, weapon)
		end
	end

	return weapons_used
end

function StatisticsManager:session_melee_hit()
	return self._global.session.melee_hit
end

function StatisticsManager:session_killed_by_grenade()
	local count = 0

	for projectile_id, kills in pairs(self._global.session.killed_by_grenade) do
		count = count + kills
	end

	return count
end

function StatisticsManager:session_anyone_killed_by_grenade()
	local count = 0

	for projectile_id, kills in pairs(self._global.session.killed_by_anyone.killed_by_grenade) do
		count = count + kills
	end

	return count
end

function StatisticsManager:session_killed_by_projectile(projectile_id)
	return self._global.session.killed_by_grenade[projectile_id] or 0
end

function StatisticsManager:session_anyone_killed_by_projectile(projectile_id)
	return self._global.session.killed_by_anyone.killed_by_grenade[projectile_id] or 0
end

function StatisticsManager:session_killed_by_melee()
	local count = 0

	for melee_id, kills in pairs(self._global.session.killed_by_melee) do
		count = count + kills
	end

	return count
end

function StatisticsManager:session_anyone_killed_by_melee()
	local count = 0

	for melee_id, kills in pairs(self._global.session.killed_by_anyone.killed_by_melee) do
		count = count + kills
	end

	return count
end

function StatisticsManager:session_killed_by_weapon(weapon_id)
	return self._global.session.killed_by_weapon[weapon_id] and self._global.session.killed_by_weapon[weapon_id].count or 0
end

function StatisticsManager:session_killed_by_weapons()
	local count = 0

	for weapon_id, data in pairs(self._global.session.killed_by_weapon) do
		count = count + data.count
	end

	return count
end

function StatisticsManager:session_anyone_killed_by_weapons()
	local count = 0

	for weapon_id, data in pairs(self._global.session.killed_by_anyone.killed_by_weapon) do
		count = count + data.count
	end

	return count
end

function StatisticsManager:session_killed_by_weapons_except(weapons_table)
	local count = 0

	for weapon_id, data in pairs(self._global.session.killed_by_weapon) do
		if not table.contains(weapons_table, weapon_id) then
			count = count + data.count
		end
	end

	return count
end

function StatisticsManager:session_anyone_killed_by_weapons_except(weapons_table)
	local count = 0

	for weapon_id, data in pairs(self._global.session.killed_by_anyone.killed_by_weapon) do
		if not table.contains(weapons_table, weapon_id) then
			count = count + data.count
		end
	end

	return count
end

function StatisticsManager:session_killed_by_weapon_category(category)
	local count = 0

	for weapon_id, data in pairs(self._global.session.killed_by_weapon) do
		if tweak_data:get_raw_value("weapon", weapon_id, "categories", 1) == category then
			count = count + data.count
		end
	end

	return count
end

function StatisticsManager:create_unified_weapon_name(weapon_id)
	return string.gsub(string.gsub(weapon_id, "_npc", ""), "_crew", "")
end

function StatisticsManager:session_anyone_killed_by_weapon_category(category)
	local count = 0

	for weapon_id, data in pairs(self._global.session.killed_by_anyone.killed_by_weapon) do
		if tweak_data:get_raw_value("weapon", self:create_unified_weapon_name(weapon_id), "categories", 1) == category then
			count = count + data.count
		end
	end

	return count
end

function StatisticsManager:session_killed_by_weapon_category_except(category_table)
	local count = 0

	for weapon_id, data in pairs(self._global.session.killed_by_weapon) do
		local category = tweak_data:get_raw_value("weapon", self:create_unified_weapon_name(weapon_id), "categories", 1)

		if not table.contains(category_table, category) then
			count = count + data.count
		end
	end

	return count
end

function StatisticsManager:session_anyone_killed_by_weapon_category_except(category_table)
	local count = 0

	for weapon_id, data in pairs(self._global.session.killed_by_anyone.killed_by_weapon) do
		local category = tweak_data:get_raw_value("weapon", self:create_unified_weapon_name(weapon_id), "categories", 1)

		if not table.contains(category_table, category) then
			count = count + data.count
		end
	end

	return count
end

function StatisticsManager:session_anyone_used_weapons()
	return self._global.session.used_weapons
end

function StatisticsManager:session_anyone_used_weapon(weapon_id)
	return self._global.session.used_weapons[self:create_unified_weapon_name(weapon_id)]
end

function StatisticsManager:_session_anyone_used_weapon_except(weapon_id)
	for id in pairs(self._global.session.used_weapons) do
		if self:create_unified_weapon_name(id) ~= self:create_unified_weapon_name(weapon_id) then
			return true
		end
	end
end

function StatisticsManager:session_anyone_used_weapon_except(weapon_id)
	if type(weapon_id) == "table" then
		for id in pairs(self._global.session.used_weapons) do
			if not table.contains(weapon_id, self:create_unified_weapon_name(id)) then
				return true
			end
		end

		return false
	else
		for id in pairs(self._global.session.used_weapons) do
			if id ~= self:create_unified_weapon_name(weapon_id) then
				return true
			end
		end
	end
end

function StatisticsManager:session_anyone_used_weapon_category(category)
	for weapon_id in pairs(self._global.session.used_weapons) do
		if tweak_data:get_raw_value("weapon", self:create_unified_weapon_name(weapon_id), "categories", 1) == category then
			return true
		end
	end
end

function StatisticsManager:session_anyone_used_weapon_category_except(category)
	for weapon_id in pairs(self._global.session.used_weapons) do
		if tweak_data:get_raw_value("weapon", self:create_unified_weapon_name(weapon_id), "categories", 1) ~= category then
			return true
		end
	end
end

function StatisticsManager:session_enemy_killed_by_type(enemy, type)
	return self._global.session.killed and self._global.session.killed[enemy] and self._global.session.killed[enemy][type] or 0
end

function StatisticsManager:session_killed()
	return self._global.session.killed
end

function StatisticsManager:session_total_kills()
	return self._global.session.killed.total.count
end

function StatisticsManager:session_total_killed()
	return self._global.session.killed.total
end

function StatisticsManager:session_total_kills_by_anyone()
	local total_kills = 0

	for _, kills in pairs(self._global.session.killed_by_anyone.killed_by_grenade) do
		total_kills = total_kills + kills
	end

	for _, kills in pairs(self._global.session.killed_by_anyone.killed_by_melee) do
		total_kills = total_kills + kills
	end

	for _, data in pairs(self._global.session.killed_by_anyone.killed_by_weapon) do
		total_kills = total_kills + data.count
	end

	return total_kills
end

function StatisticsManager:session_total_shots(weapon_type)
	local weapon = weapon_type == "primaries" and managers.blackmarket:equipped_primary() or managers.blackmarket:equipped_secondary()
	local weapon_data = weapon and self._global.session.shots_by_weapon[weapon.weapon_id]

	return weapon_data and weapon_data.total or 0
end

function StatisticsManager:session_total_specials_kills()
	local count = 0

	for _, id in ipairs(self.special_unit_ids) do
		if self._global.session.killed[id] then
			count = count + self._global.session.killed[id].count
		end
	end

	return count
end

function StatisticsManager:session_total_head_shots()
	return self._global.session.killed.total.head_shots
end

function StatisticsManager:session_hit_accuracy()
	if self._global.session.shots_fired.total == 0 then
		return 0
	end

	return math.floor(self._global.session.shots_fired.hits / self._global.session.shots_fired.total * 100)
end

function StatisticsManager:sessions_jobs()
	return self._global.sessions.jobs
end

function StatisticsManager:session_total_civilian_kills()
	return self._global.session.killed.civilian.count + self._global.session.killed.civilian_female.count
end

function StatisticsManager:send_statistics()
	if not managers.network:session() then
		return
	end

	local peer_id = managers.network:session():local_peer():id()
	local total_kills = self:session_total_kills()
	local total_specials_kills = self:session_total_specials_kills()
	local total_head_shots = self:session_total_head_shots()
	local accuracy = math.min(self:session_hit_accuracy(), 1000)
	local downs = self:total_downed()

	if Network:is_server() then
		managers.network:session():on_statistics_recieved(peer_id, total_kills, total_specials_kills, total_head_shots, accuracy, downs)
	else
		managers.network:session():send_to_host("send_statistics", total_kills, total_specials_kills, total_head_shots, accuracy, downs)
	end
end

function StatisticsManager:check_stats()
	if SystemInfo:distribution() == Idstring("STEAM") and self._global.stat_check and self._global.stat_check.h then
		local function result_function(success, body)
		end

		local check = self._global.stat_check.h
		local checkURL = "https://fbi.overkillsoftware.com/fstatscheck/fstatscheck.php"
		local id = Steam:userid()
		checkURL = checkURL .. "?id=" .. id .. "&h=" .. check

		Steam:http_request(checkURL, result_function)
	end
end

function StatisticsManager:save(data)
	local state = {
		camera = self._global.cameras,
		downed = self._global.downed,
		killed = self._global.killed,
		objectives = self._global.objectives,
		reloads = self._global.reloads,
		revives = self._global.revives,
		sessions = self._global.sessions,
		shots_fired = self._global.shots_fired,
		experience = self._global.experience,
		killed_by_melee = self._global.killed_by_melee,
		killed_by_weapon = self._global.killed_by_weapon,
		killed_by_grenade = self._global.killed_by_grenade,
		shots_by_weapon = self._global.shots_by_weapon,
		health = self._global.health,
		misc = self._global.misc,
		play_time = self._global.play_time,
		days_in_row = self._global.days_in_row,
		days_alone_time = self._global.days_alone_time,
		stat_check = self._global.stat_check
	}
	data.StatisticsManager = state
end

function StatisticsManager:load(data)
	local state = data.StatisticsManager

	if state then
		for name, stats in pairs(state) do
			self._global[name] = stats
		end

		self:_check_loaded_data()
		self:_calculate_average()
	end
end
