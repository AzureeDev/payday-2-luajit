PlayerSkill = {
	has_skill = function (category, skill, player)
		if player then
			return player:base():upgrade_value(category, skill) ~= nil
		else
			return managers.player:has_category_upgrade(category, skill)
		end
	end,
	skill_data = function (category, skill, default, player)
		if player then
			return player:base():upgrade_value(category, skill) or default
		else
			return managers.player:upgrade_value(category, skill, default)
		end
	end,
	skill_level = function (category, skill, default, player)
		if player then
			return player:base():upgrade_level(category, skill) or 0
		else
			return managers.player:upgrade_level(category, skill, default)
		end
	end
}
