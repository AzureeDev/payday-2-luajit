MutatorEnemyDamage = MutatorEnemyDamage or class(BaseMutator)
MutatorEnemyDamage._type = "MutatorEnemyDamage"
MutatorEnemyDamage.name_id = "mutator_enemy_damage"
MutatorEnemyDamage.desc_id = "mutator_enemy_damage_desc"
MutatorEnemyDamage.has_options = true
MutatorEnemyDamage.reductions = {
	money = 0,
	exp = 0
}
MutatorEnemyDamage.disables_achievements = true
MutatorEnemyDamage.categories = {
	"enemies"
}
MutatorEnemyDamage.icon_coords = {
	5,
	1
}

function MutatorEnemyDamage:register_values(mutator_manager)
	self:register_value("damage_multiplier", 2, "dm")
end

function MutatorEnemyDamage:name()
	local name = MutatorEnemyHealth.super.name(self)

	if self:_mutate_name("damage_multiplier") then
		return string.format("%s - %.0f%%", name, tonumber(self:value("damage_multiplier")) * 100)
	else
		return name
	end
end

function MutatorEnemyDamage:get_damage_multiplier()
	return self:value("damage_multiplier")
end

function MutatorEnemyDamage:modify_value(id, value)
	if id == "PlayerDamage:TakeDamageBullet" then
		return value * self:get_damage_multiplier()
	end

	return value
end

function MutatorEnemyDamage:_min_damage()
	return 1.01
end

function MutatorEnemyDamage:_max_damage()
	return 10
end

function MutatorEnemyDamage:setup_options_gui(node)
	local params = {
		name = "enemy_damage_slider",
		callback = "_update_mutator_value",
		text_id = "menu_mutator_enemy_damage",
		update_callback = callback(self, self, "_update_damage_multiplier")
	}
	local data_node = {
		show_value = true,
		step = 0.1,
		type = "CoreMenuItemSlider.ItemSlider",
		decimal_count = 2,
		min = self:_min_damage(),
		max = self:_max_damage()
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(self:get_damage_multiplier())
	node:add_item(new_item)

	self._node = node

	return new_item
end

function MutatorEnemyDamage:_update_damage_multiplier(item)
	self:set_value("damage_multiplier", item:value())
end

function MutatorEnemyDamage:reset_to_default()
	self:clear_values()

	if self._node then
		local slider = self._node:item("enemy_damage_slider")

		if slider then
			slider:set_value(self:get_damage_multiplier())
		end
	end
end

function MutatorEnemyDamage:options_fill()
	return self:_get_percentage_fill(self:_min_damage(), self:_max_damage(), self:get_damage_multiplier())
end
