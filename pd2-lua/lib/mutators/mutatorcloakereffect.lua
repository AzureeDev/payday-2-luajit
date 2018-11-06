MutatorCloakerEffect = MutatorCloakerEffect or class(BaseMutator)
MutatorCloakerEffect._type = "MutatorCloakerEffect"
MutatorCloakerEffect.name_id = "mutator_cloaker_effect"
MutatorCloakerEffect.desc_id = "mutator_cloaker_effect_desc"
MutatorCloakerEffect.has_options = true
MutatorCloakerEffect.reductions = {
	money = 0,
	exp = 0
}
MutatorCloakerEffect.disables_achievements = true
MutatorCloakerEffect.categories = {
	"enemies"
}
MutatorCloakerEffect.icon_coords = {
	2,
	2
}

function MutatorCloakerEffect:register_values(mutator_manager)
	self:register_value("kick_effect", "explode", "ke")
end

function MutatorCloakerEffect:name(lobby_data)
	local name = MutatorCloakerEffect.super.name(self)

	if self:_mutate_name("kick_effect") then
		return string.format("%s - %s", name, managers.localization:text("menu_mutator_cloaker_effect_" .. tostring(self:value("kick_effect"))))
	else
		return name
	end
end

function MutatorCloakerEffect:kick_effect()
	return self:value("kick_effect")
end

function MutatorCloakerEffect:setup_options_gui(node)
	local params = {
		callback = "_update_mutator_value",
		name = "effect_selector_choice",
		text_id = "menu_mutator_cloaker_effect",
		filter = true,
		update_callback = callback(self, self, "_update_selected_effect")
	}
	local data_node = {
		{
			value = "explode",
			text_id = "menu_mutator_cloaker_effect_explode",
			_meta = "option"
		},
		{
			value = "fire",
			text_id = "menu_mutator_cloaker_effect_fire",
			_meta = "option"
		},
		{
			value = "smoke",
			text_id = "menu_mutator_cloaker_effect_smoke",
			_meta = "option"
		},
		{
			value = "random",
			text_id = "menu_mutator_cloaker_effect_random",
			_meta = "option"
		},
		type = "MenuItemMultiChoice"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(self:kick_effect())
	node:add_item(new_item)

	self._node = node

	return new_item
end

function MutatorCloakerEffect:_update_selected_effect(item)
	self:set_value("kick_effect", item:value())
end

function MutatorCloakerEffect:reset_to_default()
	self:clear_values()

	if self._node then
		local slider = self._node:item("effect_selector_choice")

		if slider then
			slider:set_value(self:kick_effect())
		end
	end
end

function MutatorCloakerEffect:OnPlayerCloakerKicked(cloaker_unit)
	local effect_func = MutatorCloakerEffect["effect_" .. tostring(self:kick_effect())]

	if effect_func then
		effect_func(self, cloaker_unit)
	end
end

function MutatorCloakerEffect:effect_smoke(unit)
	local smoke_grenade = World:spawn_unit(Idstring("units/weapons/smoke_grenade_quick/smoke_grenade_quick"), unit:position(), unit:rotation())

	smoke_grenade:base():activate_immediately(unit:position(), tweak_data.group_ai.smoke_grenade_lifetime)
end

function MutatorCloakerEffect:effect_fire(unit)
	local position = unit:position()
	local rotation = unit:rotation()
	local data = self:cloaker_fire_large()

	if managers.mutators:is_mutator_active(MutatorEnemyReplacer) then
		data = self:cloaker_fire_small()
	end

	EnvironmentFire.spawn(position, rotation, data, math.UP, unit, 0, 1)
end

function MutatorCloakerEffect:effect_explode(unit)
	local foot = unit:get_object(Idstring("RightFoot"))
	local pos = foot and foot:position() or unit:position()
	local range = 800
	local damage = 1000
	local ply_damage = 100
	local normal = math.UP
	local slot_mask = managers.slot:get_mask("explosion_targets")
	local curve_pow = 3
	local damage_params = {
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = curve_pow,
		damage = damage,
		player_damage = ply_damage
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

	if Network:is_server() then
		managers.explosion:detect_and_give_dmg(damage_params)
		managers.network:session():send_to_peers_synched("sync_explosion_to_client", unit, pos, normal, ply_damage, range, curve_pow)
	end
end

MutatorCloakerEffect.random_effects = {
	"effect_smoke",
	"effect_fire",
	"effect_explode"
}

function MutatorCloakerEffect:effect_random(unit)
	local len = #self.random_effects
	local rand = math.clamp(unit:id() % len + 1, 1, len)
	local effect = self.random_effects[rand]

	self[effect](self, unit)
end

function MutatorCloakerEffect:cloaker_fire_large()
	local params = {
		sound_event = "molotov_impact",
		range = 75,
		curve_pow = 3,
		damage = 1,
		fire_alert_radius = 1500,
		hexes = 6,
		sound_event_burning = "burn_loop_gen",
		is_molotov = true,
		player_damage = 2,
		sound_event_impact_duration = 4,
		burn_tick_period = 0.5,
		burn_duration = 15,
		alert_radius = 1500,
		effect_name = "effects/payday2/particles/explosions/molotov_grenade",
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_damage = 15,
			dot_length = 6,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		}
	}

	return params
end

function MutatorCloakerEffect:cloaker_fire_small()
	local params = {
		sound_event = "molotov_impact",
		range = 75,
		curve_pow = 3,
		damage = 1,
		fire_alert_radius = 1500,
		hexes = 2,
		sound_event_burning = "burn_loop_gen",
		is_molotov = true,
		player_damage = 2,
		sound_event_impact_duration = 4,
		burn_tick_period = 0.5,
		burn_duration = 15,
		alert_radius = 1500,
		effect_name = "effects/payday2/particles/explosions/molotov_grenade",
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_damage = 15,
			dot_length = 6,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		}
	}

	return params
end
