StatisticsTweakData = StatisticsTweakData or class()

function StatisticsTweakData:init()
	self.session = {}
	self.killed = {
		civilian = {
			total = {
				count = 0,
				type = "normal"
			},
			head_shots = {
				count = 0,
				type = "normal"
			},
			session = {
				count = 0,
				type = "session"
			}
		},
		civilian = {
			count = 0,
			head_shots = 0
		},
		security = {
			count = 0,
			head_shots = 0
		},
		cop = {
			count = 0,
			head_shots = 0
		},
		swat = {
			count = 0,
			head_shots = 0
		},
		total = {
			count = 0,
			head_shots = 0
		}
	}
end

function StatisticsTweakData:statistics_specializations()
	return table.size(tweak_data.skilltree.specializations)
end

function StatisticsTweakData:statistics_table()
	if not self._level_list then
		self._level_list = {}

		for index, level_id in pairs(tweak_data.levels:get_level_index()) do
			table.insert(self._level_list, level_id)
		end

		table.sort(self._level_list)
	end

	if not self._job_list or not self._level_list then
		self._job_list = {}
		self._level_list = {}

		local function add_level_id(level_id)
			local level_tweak = tweak_data.levels[level_id]

			if level_tweak and not level_tweak.ignore_statistics and not table.contains(self._level_list, level_id) then
				table.insert(self._level_list, level_id)
			end
		end

		for index, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
			local job_tweak = tweak_data.narrative.jobs[job_id]
			local contact = job_tweak.contact
			local contact_tweak = contact and tweak_data.narrative.contacts[contact]
			local allow_job = not contact or contact ~= "wip" and contact ~= "tests"

			if not job_tweak.competitive then
				-- Nothing
			else
				allow_job = false

				if false then
					allow_job = true
				end
			end

			if not job_tweak.job_wrapper then
				-- Nothing
			else
				allow_job = false

				if false then
					allow_job = true
				end
			end

			if not job_tweak.hidden then
				-- Nothing
			else
				allow_job = false

				if false then
					allow_job = true
				end
			end

			if not job_tweak.ignore_statistics then
				-- Nothing
			else
				allow_job = false

				if false then
					allow_job = true
				end
			end

			if contact_tweak then
				if not contact_tweak.ignore_statistics then
					-- Nothing
				else
					allow_job = false

					if false then
						allow_job = true
					end
				end
			end

			if allow_job then
				table.insert(self._job_list, job_id)

				for _, chain_data in ipairs(job_tweak.chain) do
					if chain_data.level_id then
						add_level_id(chain_data.level_id)
					else
						for _, level_data in ipairs(chain_data) do
							add_level_id(level_data.level_id)
						end
					end
				end
			end
		end

		for index, level_id in ipairs(tweak_data.levels.escape_levels) do
			local level_tweak = tweak_data.levels[level_id]

			if level_tweak and not level_tweak.ignore_statistics and not table.contains(self._level_list, level_id) then
				table.insert(self._level_list, level_id)
			end
		end

		table.sort(self._job_list)
		table.sort(self._level_list)
	end

	if not self._mask_list then
		self._mask_list = {}

		for mask, data in pairs(tweak_data.blackmarket.masks) do
			if data.name_id ~= "bm_msk_cheat_error" then
				table.insert(self._mask_list, mask)
			end
		end

		table.sort(self._mask_list)
	end

	if not self._weapon_list then
		self._weapon_list = {}

		for weapon_id, data in pairs(tweak_data.weapon) do
			if not data.ignore_statistics and not string.match(weapon_id, "_npc") and not string.match(weapon_id, "_crew") and data.name_id and not data.ECM_HACKABLE and not data.ACC_PITCH then
				table.insert(self._weapon_list, weapon_id)
			end
		end

		table.sort(self._weapon_list)
	end

	if not self._melee_list then
		self._melee_list = {}

		for weapon, _ in pairs(tweak_data.blackmarket.melee_weapons) do
			table.insert(self._melee_list, weapon)
		end

		table.sort(self._melee_list)
	end

	if not self._grenade_list then
		self._grenade_list = {}

		for id, data in pairs(tweak_data.blackmarket.projectiles) do
			if not data.ignore_statistics and data.name_id and not data.weapon_id then
				table.insert(self._grenade_list, id)
			end
		end

		table.sort(self._grenade_list)
	end

	local enemy_list = {
		"civilian",
		"civilian_female",
		"robbers_safehouse",
		"cop",
		"fbi",
		"fbi_swat",
		"fbi_heavy_swat",
		"swat",
		"heavy_swat",
		"city_swat",
		"security",
		"gensec",
		"gangster",
		"biker_escape",
		"sniper",
		"shield",
		"spooc",
		"tank",
		"taser",
		"mobster",
		"mobster_boss",
		"tank_hw",
		"hector_boss",
		"hector_boss_no_armor",
		"chavez_boss",
		"tank_green",
		"tank_black",
		"tank_skull",
		"hostage_rescue",
		"murkywater",
		"phalanx_vip",
		"phalanx_minion",
		"biker",
		"inside_man",
		"bank_manager",
		"cop_scared",
		"biker_boss",
		"cop_female",
		"security_undominatable",
		"medic",
		"mute_security_undominatable",
		"escort_chinese_prisoner",
		"bolivian",
		"bolivian_indoors",
		"drug_lord_boss",
		"drug_lord_boss_stealth"
	}
	local armor_list = {
		"level_1",
		"level_2",
		"level_3",
		"level_4",
		"level_5",
		"level_6",
		"level_7"
	}
	local character_list = {
		"russian",
		"german",
		"spanish",
		"american",
		"jowi",
		"old_hoxton",
		"female_1",
		"dragan",
		"jacket",
		"bonnie",
		"sokol",
		"dragon",
		"bodhi",
		"jimmy",
		"sydney",
		"wild",
		"chico",
		"max",
		"joy",
		"myh",
		"ecp_female",
		"ecp_male"
	}
	local deployable_list = {
		"ammo_bag",
		"doctor_bag",
		"trip_mine",
		"sentry_gun",
		"ecm_jammer",
		"first_aid_kit",
		"bodybags_bag",
		"armor_kit",
		"sentry_gun_silent"
	}

	return self._level_list, self._job_list, self._mask_list, self._weapon_list, self._melee_list, self._grenade_list, enemy_list, armor_list, character_list, deployable_list
end

function StatisticsTweakData:resolution_statistics_table()
	return {
		"2560x1440",
		"1920x1200",
		"1920x1080",
		"1680x1050",
		"1600x900",
		"1536x864",
		"1440x900",
		"1366x768",
		"1360x768",
		"1280x1024",
		"1280x800",
		"1280x720",
		"1024x768"
	}
end

function StatisticsTweakData:mission_statistics_table()
	return {
		"labrat"
	}
end
