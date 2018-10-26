MutatorExplodingEnemies = MutatorExplodingEnemies or class(BaseMutator)
MutatorExplodingEnemies._type = "MutatorExplodingEnemies"
MutatorExplodingEnemies.name_id = "mutator_creeps"
MutatorExplodingEnemies.desc_id = "mutator_creeps_desc"
MutatorExplodingEnemies.has_options = true
MutatorExplodingEnemies.reductions = {
	money = 0.5,
	exp = 0.5
}
MutatorExplodingEnemies.categories = {
	"enemies",
	"gameplay"
}
MutatorExplodingEnemies.icon_coords = {
	2,
	1
}

function MutatorExplodingEnemies:register_values(mutator_manager)
	self:register_value("explosion_size", 4, "es")
	self:register_value("nuclear_dozers", false, "nd")
end

function MutatorExplodingEnemies:setup(mutator_manager)
	self._explosions = {}

	mutator_manager:register_message(Message.OnCopDamageDeath, "MutatorExplodingEnemies", callback(self, self, "explode"))
end

function MutatorExplodingEnemies:name()
	local name = MutatorExplodingEnemies.super.name(self)

	if self:_mutate_name("explosion_size") then
		name = string.format("%s - %.1fm", name, tonumber(self:value("explosion_size")))
	end

	if self:_mutate_name("nuclear_dozers") then
		name = string.format("%s - %s", name, managers.localization:text("menu_mutator_creeps_nuclear"))
	end

	return name
end

function MutatorExplodingEnemies:default_explosion_size()
	return 4
end

function MutatorExplodingEnemies:get_explosion_size()
	return self:value("explosion_size")
end

function MutatorExplodingEnemies:use_nuclear_bulldozers()
	return self:value("nuclear_dozers")
end

function MutatorExplodingEnemies:explosion_delay()
	return 0
end

function MutatorExplodingEnemies:_min_explosion_size()
	return 2
end

function MutatorExplodingEnemies:_max_explosion_size()
	return 6
end

function MutatorExplodingEnemies:setup_options_gui(node)
	local params = {
		name = "explosion_slider",
		callback = "_update_mutator_value",
		text_id = "menu_mutator_creeps_scale",
		update_callback = callback(self, self, "_update_explosion_size")
	}
	local data_node = {
		show_value = true,
		step = 0.5,
		type = "CoreMenuItemSlider.ItemSlider",
		decimal_count = 1,
		min = self:_min_explosion_size(),
		max = self:_max_explosion_size()
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(self:get_explosion_size())
	node:add_item(new_item)

	local params = {
		name = "nuclear_dozers_toggle",
		callback = "_update_mutator_value",
		text_id = "menu_mutator_creeps_nuclear",
		update_callback = callback(self, self, "_toggle_nuclear_bulldozers")
	}
	local data_node = {
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "on",
			s_w = 24,
			s_h = 24,
			s_x = 24,
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = 24,
			s_icon = "guis/textures/menu_tickbox"
		},
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "off",
			s_w = 24,
			s_h = 24,
			s_x = 0,
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = 0,
			s_icon = "guis/textures/menu_tickbox"
		},
		type = "CoreMenuItemToggle.ItemToggle"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(self:use_nuclear_bulldozers() and "on" or "off")
	node:add_item(new_item)

	self._node = node

	return new_item
end

function MutatorExplodingEnemies:_update_explosion_size(item)
	self:set_value("explosion_size", item:value())
end

function MutatorExplodingEnemies:_toggle_nuclear_bulldozers(item)
	self:set_value("nuclear_dozers", item:value() == "on")
end

function MutatorExplodingEnemies:reset_to_default()
	self:clear_values()

	if self._node then
		local slider = self._node:item("explosion_slider")

		if slider then
			slider:set_value(self:get_explosion_size())
		end

		local toggle = self._node:item("nuclear_dozers_toggle")

		if toggle then
			toggle:set_value(self:use_nuclear_bulldozers() and "on" or "off")
		end
	end
end

function MutatorExplodingEnemies:options_fill()
	return self:_get_percentage_fill(self:_min_explosion_size(), self:_max_explosion_size(), self:get_explosion_size())
end

function MutatorExplodingEnemies:update(t, dt)
	for i = #self._explosions, 1, -1 do
		local data = self._explosions[i]
		data.t = data.t - dt

		if data.t < 0 then
			self:_detonate(data.cop_damage, data.attack_data)
			table.remove(self._explosions, i)
		end
	end
end

function MutatorExplodingEnemies:explode(cop_damage, attack_data)
	if not Network:is_server() then
		return
	end

	if self:explosion_delay() <= 0 then
		self:_detonate(cop_damage, attack_data)
	else
		table.insert(self._explosions, {
			cop_damage = cop_damage,
			attack_data = attack_data,
			t = self:explosion_delay()
		})
	end
end

function MutatorExplodingEnemies:_detonate(cop_damage, attack_data)
	if Network:is_server() then
		local pos = attack_data.pos

		if (self:explosion_delay() > 0 or not pos) and alive(cop_damage._unit) then
			pos = cop_damage._unit:get_object(Idstring("Spine2")):position() or pos
		end

		local range = self:get_explosion_size() * 100
		local damage = attack_data.raw_damage or attack_data.damage or cop_damage._HEALTH_INIT
		local ply_damage = damage * 0.5
		local normal = attack_data.attack_dir or math.UP
		local slot_mask = managers.slot:get_mask("explosion_targets")
		local curve_pow = 4
		local unit_tweak = alive(cop_damage._unit) and cop_damage._unit:base()._tweak_table

		if unit_tweak and unit_tweak == "tank" and self:use_nuclear_bulldozers() then
			range = 2000
			damage = damage * 2.5
			ply_damage = damage * 0.5
			curve_pow = 6
		end

		local damage_params = {
			no_raycast_check_characters = false,
			hit_pos = pos,
			range = range,
			collision_slotmask = slot_mask,
			curve_pow = curve_pow,
			damage = damage,
			player_damage = ply_damage,
			ignore_unit = cop_damage._unit,
			user = attack_data.attacker_unit
		}
		local effect_params = {
			sound_event = "grenade_explode",
			effect = "effects/payday2/particles/explosions/grenade_explosion",
			camera_shake_max_mul = 4,
			sound_muffle_effect = true,
			feedback_range = range * 2
		}

		managers.explosion:give_local_player_dmg(pos, range, ply_damage)
		managers.explosion:play_sound_and_effects(pos, normal, range, effect_params)
		managers.explosion:detect_and_give_dmg(damage_params)
		managers.network:session():send_to_peers_synched("sync_explosion_to_client", attack_data.attacker_unit, pos, normal, ply_damage, range, curve_pow)
	end
end

