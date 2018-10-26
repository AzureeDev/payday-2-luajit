MutatorEnemyHealth = MutatorEnemyHealth or class(BaseMutator)
MutatorEnemyHealth._type = "MutatorEnemyHealth"
MutatorEnemyHealth.name_id = "mutator_enemy_health"
MutatorEnemyHealth.desc_id = "mutator_enemy_health_desc"
MutatorEnemyHealth.has_options = true
MutatorEnemyHealth.reductions = {
	money = 0,
	exp = 0
}
MutatorEnemyHealth.disables_achievements = true
MutatorEnemyHealth.categories = {"enemies"}
MutatorEnemyHealth.icon_coords = {
	4,
	1
}

function MutatorEnemyHealth:register_values(mutator_manager)
	self:register_value("health_multiplier", 2, "hm")
end

function MutatorEnemyHealth:setup()
	self:modify_character_tweak_data(tweak_data.character, self:get_health_multiplier())
end

function MutatorEnemyHealth:name()
	local name = MutatorEnemyHealth.super.name(self)

	if self:_mutate_name("health_multiplier") then
		return string.format("%s - %.0f%%", name, tonumber(self:value("health_multiplier")) * 100)
	else
		return name
	end
end

function MutatorEnemyHealth:get_health_multiplier()
	return self:value("health_multiplier")
end

function MutatorEnemyHealth:modify_character_tweak_data(character_tweak, multiplier)
	if character_tweak then
		multiplier = multiplier or self:get_health_multiplier()

		print("[Mutators] Mutating character tweak data: ", self:id())

		for i, character in ipairs(character_tweak:enemy_list()) do
			if character_tweak[character] then
				print("[Mutators] Mutating health:", character, character_tweak[character].HEALTH_INIT, multiplier, character_tweak[character].HEALTH_INIT * multiplier)

				character_tweak[character].HEALTH_INIT = character_tweak[character].HEALTH_INIT * multiplier
			end
		end
	end
end

function MutatorEnemyHealth:_min_health()
	return 1.01
end

function MutatorEnemyHealth:_max_health()
	return 10
end

function MutatorEnemyHealth:setup_options_gui(node)
	local params = {
		name = "enemy_health_slider",
		callback = "_update_mutator_value",
		text_id = "menu_mutator_enemy_health",
		update_callback = callback(self, self, "_update_health_multiplier")
	}
	local data_node = {
		show_value = true,
		step = 0.1,
		type = "CoreMenuItemSlider.ItemSlider",
		decimal_count = 2,
		min = self:_min_health(),
		max = self:_max_health()
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(self:get_health_multiplier())
	node:add_item(new_item)

	self._node = node

	return new_item
end

function MutatorEnemyHealth:_update_health_multiplier(item)
	self:set_value("health_multiplier", item:value())
end

function MutatorEnemyHealth:reset_to_default()
	self:clear_values()

	if self._node then
		local slider = self._node:item("enemy_health_slider")

		if slider then
			slider:set_value(self:get_health_multiplier())
		end
	end
end

function MutatorEnemyHealth:options_fill()
	return self:_get_percentage_fill(self:_min_health(), self:_max_health(), self:get_health_multiplier())
end

