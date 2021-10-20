MutatorTweakData = MutatorTweakData or class()

function MutatorTweakData:init(tweak_data)
	self:init_birthday(tweak_data)
end

function MutatorTweakData:init_birthday(tweak_data)
	self.birthday = {
		event_track = "its_clown_time",
		special_unit_rules_data = {
			taser = {
				buff_id = 1,
				spawn_rate = 3
			},
			medic = {
				buff_id = 2,
				spawn_rate = 1
			},
			shield = {
				buff_id = 3,
				spawn_rate = 2
			},
			tank = {
				buff_id = 4,
				spawn_rate = 1
			},
			spooc = {
				buff_id = 5,
				spawn_rate = 3
			},
			sniper = {
				buff_id = 6,
				spawn_rate = 1
			}
		},
		buffs = {
			ammo_refresh = {
				buff_id = 1,
				color = Color.white
			},
			health_refresh = {
				buff_id = 2,
				amount = 10,
				color = Color.white
			},
			shield_refresh = {
				buff_id = 3,
				color = Color.white
			},
			god_mode = {
				buff_id = 4,
				duration = 15,
				color = Color.yellow
			},
			double_damage = {
				buff_id = 5,
				duration = 20,
				color = Color.yellow
			},
			inf_ammo = {
				buff_id = 6,
				duration = 15,
				color = Color.yellow
			}
		}
	}
end

function MutatorTweakData:get_birthday_buff_name_from_id(buff_id)
	for buff_name, buff_data in pairs(self.birthday.buffs) do
		if buff_id == buff_data.buff_id then
			return buff_name
		end
	end

	return "buff_name_error"
end

function MutatorTweakData:get_birthday_unit_from_id(buff_id)
	for unit_name, unit_data in pairs(self.birthday.special_unit_rules_data) do
		if buff_id == unit_data.buff_id then
			return unit_name
		end
	end

	return "unit_name_error"
end
