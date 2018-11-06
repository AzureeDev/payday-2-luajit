MutatorFriendlyFire = MutatorFriendlyFire or class(BaseMutator)
MutatorFriendlyFire._type = "MutatorFriendlyFire"
MutatorFriendlyFire.name_id = "mutator_friendly_fire"
MutatorFriendlyFire.desc_id = "mutator_friendly_fire_desc"
MutatorFriendlyFire.has_options = true
MutatorFriendlyFire.reductions = {
	money = 0,
	exp = 0
}
MutatorFriendlyFire.disables_achievements = true
MutatorFriendlyFire.categories = {
	"gameplay"
}
MutatorFriendlyFire.icon_coords = {
	3,
	1
}

function MutatorFriendlyFire:register_values(mutator_manager)
	self:register_value("damage_multiplier", 1, "dm")
end

function MutatorFriendlyFire:name()
	local name = MutatorFriendlyFire.super.name(self)

	if self:_mutate_name("damage_multiplier") then
		return string.format("%s - %.0f%%", name, tonumber(self:value("damage_multiplier")) * 100)
	else
		return name
	end
end

function MutatorFriendlyFire:setup(mutator_manager)
	MutatorFriendlyFire.super.setup(mutator_manager)

	managers.slot._masks.bullet_impact_targets = managers.slot._masks.bullet_impact_targets_ff
end

function MutatorFriendlyFire:get_friendly_fire_damage_multiplier()
	return self:value("damage_multiplier")
end

function MutatorFriendlyFire:modify_value(id, value)
	if id == "PlayerDamage:FriendlyFire" then
		return false
	elseif id == "HuskPlayerDamage:FriendlyFireDamage" then
		return value * self:get_friendly_fire_damage_multiplier() * 0.25
	elseif id == "ProjectileBase:create_sweep_data:slot_mask" then
		return value + 3
	end
end

function MutatorFriendlyFire:_min_damage()
	return 0.25
end

function MutatorFriendlyFire:_max_damage()
	return 3
end

function MutatorFriendlyFire:setup_options_gui(node)
	local params = {
		name = "ff_damage_slider",
		callback = "_update_mutator_value",
		text_id = "menu_mutator_ff_damage",
		update_callback = callback(self, self, "_update_damage_multiplier")
	}
	local data_node = {
		show_value = true,
		step = 0.05,
		type = "CoreMenuItemSlider.ItemSlider",
		decimal_count = 2,
		min = self:_min_damage(),
		max = self:_max_damage()
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(self:get_friendly_fire_damage_multiplier())
	node:add_item(new_item)

	self._node = node

	return new_item
end

function MutatorFriendlyFire:_update_damage_multiplier(item)
	self:set_value("damage_multiplier", item:value())
end

function MutatorFriendlyFire:reset_to_default()
	self:clear_values()

	if self._node then
		local slider = self._node:item("ff_damage_slider")

		if slider then
			slider:set_value(self:get_friendly_fire_damage_multiplier())
		end
	end
end

function MutatorFriendlyFire:options_fill()
	return self:_get_percentage_fill(self:_min_damage(), self:_max_damage(), self:get_friendly_fire_damage_multiplier())
end
