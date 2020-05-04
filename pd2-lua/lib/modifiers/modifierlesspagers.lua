ModifierLessPagers = ModifierLessPagers or class(BaseModifier)
ModifierLessPagers._type = "ModifierLessPagers"
ModifierLessPagers.name_id = "none"
ModifierLessPagers.desc_id = "menu_cs_modifier_pagers"
ModifierLessPagers.default_value = "count"
ModifierLessPagers.stealth = true

function ModifierLessPagers:init(data)
	ModifierLessPagers.super.init(self, data)

	local max_pagers = 0

	for i, val in ipairs(tweak_data.player.alarm_pager.bluff_success_chance) do
		if val > 0 then
			max_pagers = math.max(max_pagers, i)
		end
	end

	max_pagers = max_pagers - self:value()
	local new_pagers_data = {}

	for i = 1, max_pagers do
		table.insert(new_pagers_data, 1)
	end

	table.insert(new_pagers_data, 0)

	tweak_data.player.alarm_pager.bluff_success_chance = new_pagers_data
	tweak_data.player.alarm_pager.bluff_success_chance_w_skill = new_pagers_data
end
