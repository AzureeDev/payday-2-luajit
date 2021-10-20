MutatorBirthday = MutatorBirthday or class(BaseMutator)
MutatorBirthday._type = "MutatorBirthday"
MutatorBirthday.name_id = "mutator_birthday"
MutatorBirthday.desc_id = "mutator_birthday_desc"
MutatorBirthday.reductions = {
	money = 0,
	exp = 0
}
MutatorBirthday.disables_achievements = false
MutatorBirthday.categories = {
	"event"
}
MutatorBirthday.icon_coords = {
	5,
	1
}

function MutatorBirthday:setup(mutator_manager)
	self._tweakdata = tweak_data.mutators.birthday
	self._special_killed_count = {}
end

function MutatorBirthday:update(t, dt)
	local unit = managers.player:player_unit()
	local unit_damage = alive(unit) and unit:character_damage() or nil

	if unit_damage and unit_damage:god_mode() and not managers.player:has_active_temporary_property("birthday_god") then
		unit_damage:set_god_mode(false)
	end

	managers.hud:update_mutator_hud(t, dt)
end

function MutatorBirthday:main_category()
	return "event"
end

function MutatorBirthday:on_special_killed(dead_unit)
	local buff_id = 0
	local special_id = ""

	for id, unit_data in pairs(self._tweakdata.special_unit_rules_data) do
		if dead_unit:base():has_tag(id) then
			buff_id = unit_data.buff_id
			special_id = id

			break
		end
	end

	self._special_killed_count[special_id] = (self._special_killed_count[special_id] or 0) + 1

	if self._tweakdata.special_unit_rules_data[special_id].spawn_rate <= self._special_killed_count[special_id] then
		local balloon_unit = BuffBalloon.spawn(dead_unit:position(), Rotation(0, 0, 0), buff_id)
		self._special_killed_count[special_id] = 0
	end
end

function MutatorBirthday:activate_buff(buff_id)
	print("[MutatorBirthday] activate_buff()", buff_id)

	local buff_name = tweak_data.mutators:get_birthday_buff_name_from_id(buff_id)
	local buff_func = MutatorBirthday["activate_" .. buff_name .. "_buff"]

	if buff_func then
		buff_func()
		managers.environment_controller:set_buff_effect(0.5)
		managers.hud:post_event("stinger_10th_ability_on")
	else
		print("[MutatorBirthday] MISSING BUFF FUNCTION", buff_name)
	end
end

function MutatorBirthday.activate_ammo_refresh_buff()
	if managers.mutators:is_mutator_active(MutatorBirthday) then
		local unit = managers.player:player_unit()

		if alive(unit) then
			for id, weapon in pairs(unit:inventory():available_selections()) do
				if alive(weapon.unit) then
					local td = tweak_data.mutators.birthday.buffs.ammo_refresh

					weapon.unit:base():replenish()
					managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
					managers.hud:add_buff("ammo_refresh", "hud_buff_birthday_ammo_refresh", td.color, 2)
				end
			end
		end
	end
end

function MutatorBirthday.activate_health_refresh_buff()
	if managers.mutators:is_mutator_active(MutatorBirthday) then
		local unit = managers.player:player_unit()
		local unit_damage = alive(unit) and unit:character_damage() or nil

		if unit_damage then
			local td = tweak_data.mutators.birthday.buffs.health_refresh

			unit_damage:restore_health(tweak_data.mutators.birthday.buffs.health_refresh.amount, true)
			managers.hud:add_buff("recover_health", "hud_buff_birthday_recover_health", td.color, 2)
		end
	end
end

function MutatorBirthday.activate_shield_refresh_buff()
	if managers.mutators:is_mutator_active(MutatorBirthday) then
		local unit = managers.player:player_unit()
		local unit_damage = alive(unit) and unit:character_damage() or nil

		if unit_damage then
			local td = tweak_data.mutators.birthday.buffs.shield_refresh

			unit_damage:regenerate_armor()
			managers.hud:add_buff("regenerate_armor", "hud_buff_birthday_regenerate_armor", td.color, 2)
		end
	end
end

function MutatorBirthday.activate_god_mode_buff()
	if managers.mutators:is_mutator_active(MutatorBirthday) then
		local unit = managers.player:player_unit()
		local unit_damage = alive(unit) and unit:character_damage() or nil

		if unit_damage then
			local td = tweak_data.mutators.birthday.buffs.god_mode

			managers.player:activate_temporary_property("birthday_god", td.duration, 1)
			unit_damage:set_god_mode(true)
			managers.hud:add_buff("god_mode", "hud_buff_birthday_god_mode", td.color, td.duration, true)
		end
	end
end

function MutatorBirthday.activate_double_damage_buff()
	if managers.mutators:is_mutator_active(MutatorBirthday) and alive(managers.player:player_unit()) then
		local td = tweak_data.mutators.birthday.buffs.double_damage

		managers.player:activate_temporary_property("birthday_multiplier", td.duration, 2)
		managers.hud:add_buff("double_damage", "hud_buff_birthday_2x_damage", td.color, td.duration, true)
	end
end

function MutatorBirthday.activate_inf_ammo_buff()
	if managers.mutators:is_mutator_active(MutatorBirthday) and alive(managers.player:player_unit()) then
		local td = tweak_data.mutators.birthday.buffs.inf_ammo

		managers.player:activate_temporary_property("bullet_storm", td.duration, 1)
		managers.hud:add_buff("inf_ammo", "hud_buff_birthday_inf_ammo", td.color, td.duration, true)
	end
end
