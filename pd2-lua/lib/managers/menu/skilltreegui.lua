require("lib/managers/menu/WalletGuiObject")

SkillTreeLogic = SkillTreeLogic or class()
local NOT_WIN_32 = SystemInfo:platform() ~= Idstring("WIN32")
local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.6 or 0.6
local SPEC_WIDTH_MULTIPLIER = NOT_WIN_32 and 0.7 or 0.7
local CONSOLE_PAGE_ADJUSTMENT = NOT_WIN_32 and 0 or 0
local TOP_ADJUSTMENT = NOT_WIN_32 and 50 or 55
local BOX_GAP = 54
local NUM_TREES_PER_PAGE = 4

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

local function fit_text_height(text_gui)
	local _, y, _, h = text_gui:text_rect()

	text_gui:set_h(h)
	text_gui:set_y(math.round(text_gui:y()))
end

SkillTreeItem = SkillTreeItem or class()

function SkillTreeItem:init()
	self._left_item = nil
	self._right_item = nil
	self._up_item = nil
	self._down_item = nil
end

function SkillTreeItem:refresh()
end

function SkillTreeItem:inside()
end

function SkillTreeItem:select(no_sound)
	if not self._selected then
		self._selected = true

		self:refresh()

		if not no_sound then
			managers.menu_component:post_event("highlight")
		end
	end
end

function SkillTreeItem:deselect()
	if self._selected then
		self._selected = false

		self:refresh()
	end
end

function SkillTreeItem:trigger()
	managers.menu_component:post_event("menu_enter")
	self:refresh()
end

function SkillTreeItem:flash()
end

SkillTreeTabItem = SkillTreeTabItem or class(SkillTreeItem)

function SkillTreeTabItem:init(tree_tabs_panel, tree, data, w, x)
	SkillTreeTabItem.super.init(self)

	self._tree = tree
	self._tree_tab = tree_tabs_panel:panel({
		name = "" .. tree,
		w = w,
		x = x
	})

	self._tree_tab:text({
		word_wrap = false,
		name = "tree_tab_name",
		vertical = "center",
		wrap = false,
		align = "center",
		layer = 1,
		text = utf8.to_upper(managers.localization:text(data.name_id)),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})

	local _, _, tw, th = self._tree_tab:child("tree_tab_name"):text_rect()

	self._tree_tab:set_size(tw + 15, th + 10)
	self._tree_tab:child("tree_tab_name"):set_size(self._tree_tab:size())
	self._tree_tab:bitmap({
		texture = "guis/textures/pd2/shared_tab_box",
		name = "tree_tab_select_rect",
		visible = false,
		layer = 0,
		w = self._tree_tab:w(),
		h = self._tree_tab:h(),
		color = tweak_data.screen_colors.text
	})
	self._tree_tab:move(0, 0)
end

function SkillTreeTabItem:set_active(active)
	self._active = active

	self:refresh()
end

function SkillTreeTabItem:tree()
	return self._tree
end

function SkillTreeTabItem:inside(x, y)
	return self._tree_tab:inside(x, y)
end

function SkillTreeTabItem:refresh()
	if not alive(self._tree_tab) then
		return
	end

	if self._active then
		self._tree_tab:child("tree_tab_select_rect"):show()
		self._tree_tab:child("tree_tab_name"):set_color(tweak_data.screen_colors.button_stage_1)
		self._tree_tab:child("tree_tab_name"):set_blend_mode("normal")
	elseif self._selected then
		self._tree_tab:child("tree_tab_select_rect"):hide()
		self._tree_tab:child("tree_tab_name"):set_color(tweak_data.screen_colors.button_stage_2)
		self._tree_tab:child("tree_tab_name"):set_blend_mode("add")
	else
		self._tree_tab:child("tree_tab_select_rect"):hide()
		self._tree_tab:child("tree_tab_name"):set_color(tweak_data.screen_colors.button_stage_3)
		self._tree_tab:child("tree_tab_name"):set_blend_mode("add")
	end
end

SkillTreeSkillItem = SkillTreeSkillItem or class(SkillTreeItem)

function SkillTreeSkillItem:init(skill_id, tier_panel, num_skills, i, tree, tier, w, h, skill_refresh_skills)
	SkillTreeSkillItem.super.init(self)

	self._skill_id = skill_id
	self._tree = tree
	self._tier = tier
	local skill_panel = tier_panel:panel({
		name = skill_id,
		w = w,
		h = h
	})
	self._skill_panel = skill_panel
	self._skill_refresh_skills = skill_refresh_skills
	local skill = tweak_data.skilltree.skills[skill_id]
	self._skill_name = managers.localization:text(skill.name_id)
	local texture_rect_x = skill.icon_xy and skill.icon_xy[1] or 0
	local texture_rect_y = skill.icon_xy and skill.icon_xy[2] or 0
	self._base_size = h - 10
	local state_image = skill_panel:bitmap({
		texture = "guis/textures/pd2/skilltree/icons_atlas",
		name = "state_image",
		layer = 1,
		texture_rect = {
			texture_rect_x * 64,
			texture_rect_y * 64,
			64,
			64
		},
		color = tweak_data.screen_colors.item_stage_3
	})

	state_image:set_size(self._base_size, self._base_size)
	state_image:set_blend_mode("add")

	local skill_text = skill_panel:text({
		word_wrap = true,
		name = "skill_text",
		vertical = "center",
		wrap = true,
		align = "left",
		blend_mode = "add",
		text = "",
		layer = 3,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		x = self._base_size + 10,
		w = skill_panel:w() - self._base_size - 10
	})

	state_image:set_x(5)
	state_image:set_center_y(skill_panel:h() / 2)

	self._inside_panel = skill_panel:panel({
		w = w - 10,
		h = h - 10
	})

	self._inside_panel:set_center(skill_panel:w() / 2, skill_panel:h() / 2)

	local half_box = w * 0.5
	local center_x = tier_panel:w() * 0.5 - (num_skills - 1) * half_box
	local pos_x = center_x + w * (i - 1)

	skill_panel:set_center_x(pos_x)

	self._box = BoxGuiObject:new(skill_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})

	self._box:hide()

	local state_indicator = skill_panel:bitmap({
		texture = "guis/textures/pd2/skilltree/ace",
		name = "state_indicator",
		alpha = 0,
		layer = 0,
		color = Color.white:with_alpha(1)
	})

	state_indicator:set_size(state_image:w() * 2, state_image:h() * 2)
	state_indicator:set_blend_mode("add")
	state_indicator:set_rotation(360)
	state_indicator:set_center(state_image:center())
end

function SkillTreeSkillItem:tier()
	return self._tier
end

function SkillTreeSkillItem:skill_id()
	return self._skill_id
end

function SkillTreeSkillItem:tree()
	return self._tree
end

function SkillTreeSkillItem:link(i, items)
	if i == 1 then
		self._left_item = items[2]
		self._up_item = items[3]
		self._right_item = items[4]
	else
		self._left_item = i % 3 ~= 2 and items[i - 1]
		self._right_item = i % 3 ~= 1 and items[i + 1]
		self._up_item = items[math.max(1, i + 3)]
		self._down_item = items[math.max(1, i - 3)]
	end
end

function SkillTreeSkillItem:inside(x, y)
	return self._inside_panel:inside(x, y)
end

function SkillTreeSkillItem:flash()
	local skill_text = self._skill_panel:child("skill_text")
	local state_image = self._skill_panel:child("state_image")
	local box = self._box

	local function flash_anim(panel)
		local st_color = skill_text:color()
		local si_color = state_image:color()
		local b_color = box:color()
		local s = 0

		over(0.5, function (t)
			s = math.min(1, math.sin(t * 180) * 2)

			skill_text:set_color(math.lerp(st_color, tweak_data.screen_colors.important_1, s))
			state_image:set_color(math.lerp(si_color, tweak_data.screen_colors.important_1, s))
			box:set_color(math.lerp(b_color, tweak_data.screen_colors.important_1, s))
		end)
		skill_text:set_color(st_color)
		state_image:set_color(si_color)
		box:set_color(b_color)
	end

	self:refresh(self._locked)
	self._skill_panel:animate(flash_anim)
end

function SkillTreeSkillItem:refresh(locked)
	if not alive(self._skill_panel) then
		return
	end

	local skill_id = self._skill_panel:name()

	self._skill_panel:stop()

	local step = managers.skilltree:next_skill_step(skill_id)
	local unlocked = managers.skilltree:skill_unlocked(nil, skill_id) or not self._tier
	local completed = managers.skilltree:skill_completed(skill_id)
	local talent = tweak_data.skilltree.skills[skill_id]
	self._locked = locked

	if Application:production_build() then
		-- Nothing
	end

	local selected = self._selected

	self._box:set_visible(selected)
	self._box:set_color(tweak_data.screen_colors.item_stage_1)

	local skill_text = self._skill_panel:child("skill_text")
	local skill_text_string = ""

	if selected then
		if not self._tier then
			if step == 1 then
				skill_text_string = managers.localization:text("st_menu_unlock_profession", {
					profession = managers.localization:text(tweak_data.skilltree.trees[self._tree].name_id),
					points = managers.skilltree:get_skill_points(self._skill_id, 1)
				})
			else
				skill_text_string = managers.localization:text("st_menu_profession_unlocked", {
					profession = managers.localization:text(tweak_data.skilltree.trees[self._tree].name_id)
				})
			end
		elseif completed then
			skill_text_string = managers.localization:text("st_menu_skill_maxed")
		elseif step == 2 then
			local points = managers.skilltree:get_skill_points(self._skill_id, 2)
			local cost = managers.money:get_skillpoint_cost(self._tree, self._tier, points)
			skill_text_string = managers.localization:text("st_menu_buy_skill_pro" .. (points > 1 and "_plural" or ""), {
				cost = managers.experience:cash_string(cost),
				points = points
			})
		elseif not unlocked then
			skill_text_string = managers.localization:text("st_menu_skill_locked")
		elseif step == 1 then
			local points = managers.skilltree:get_skill_points(self._skill_id, 1)
			local cost = managers.money:get_skillpoint_cost(self._tree, self._tier, points)
			skill_text_string = managers.localization:text("st_menu_buy_skill_basic" .. (points > 1 and "_plural" or ""), {
				cost = managers.experience:cash_string(cost),
				points = points
			})
		else
			skill_text_string = "MISSING"
		end
	elseif self._tier then
		if completed then
			skill_text_string = managers.localization:text("st_menu_skill_maxed")
		elseif step == 2 then
			skill_text_string = managers.localization:text("st_menu_skill_owned")
		end
	end

	skill_text:set_text(utf8.to_upper(skill_text_string))
	skill_text:set_color(tweak_data.screen_colors.item_stage_1)

	if not self._tier then
		self._skill_panel:child("state_indicator"):set_alpha(0)
		self._skill_panel:child("state_image"):set_color(tweak_data.screen_colors[(step > 1 or selected) and "item_stage_1" or "item_stage_2"])

		return
	end

	local color = (completed or selected or step > 1) and tweak_data.screen_colors.item_stage_1 or unlocked and tweak_data.screen_colors.item_stage_2 or tweak_data.screen_colors.item_stage_3

	self._skill_panel:child("state_image"):set_color(color)

	if completed then
		self._skill_panel:child("state_indicator"):set_alpha(1)

		return
	end

	if unlocked then
		if step ~= 2 then
			self._skill_panel:child("state_indicator"):set_alpha(0)
		end
	elseif selected then
		-- Nothing
	end

	if unlocked then
		local prerequisites = talent.prerequisites or {}

		for _, prerequisite in ipairs(prerequisites) do
			local req_unlocked = managers.skilltree:skill_step(prerequisite)

			if req_unlocked and req_unlocked == 0 then
				self._skill_panel:child("state_image"):set_color(tweak_data.screen_colors[selected and "important_1" or "important_2"])
				self._box:set_color(tweak_data.screen_colors[selected and "important_1" or "important_2"])

				if selected then
					skill_text:set_color(tweak_data.screen_colors.important_1)
					skill_text:set_text(utf8.to_upper(managers.localization:text("st_menu_skill_locked")))
				end

				break
			end
		end
	end
end

function SkillTreeSkillItem:trigger()
	if managers.skilltree:tier_unlocked(self._tree, self._tier) then
		managers.skilltree:unlock(self._tree, self._skill_id)
	end

	self:refresh(self._locked)

	return self._skill_refresh_skills
end

SkillTreeUnlockItem = SkillTreeUnlockItem or class(SkillTreeSkillItem)

function SkillTreeUnlockItem:init(skill_id, parent_panel, tree, base_size, h)
	SkillTreeUnlockItem.super.init(self, skill_id, parent_panel, 1, 2, tree, nil, base_size, h)
end

function SkillTreeUnlockItem:trigger()
	if not managers.skilltree:tree_unlocked(self._tree) then
		managers.skilltree:unlock_tree(self._tree)
		self:refresh(self._locked)
	end
end

SkillTreePage = SkillTreePage or class()

function SkillTreePage:init(tree, data, parent_panel, fullscreen_panel, tree_tab_h, skill_prerequisites)
	self._items = {}
	self._selected_item = nil
	self._tree = tree
	local tree_panel = parent_panel:panel({
		y = 0,
		visible = false,
		name = tostring(tree),
		w = math.round(parent_panel:w() * WIDTH_MULTIPLIER)
	})
	self._tree_panel = tree_panel
	self._bg_image = fullscreen_panel:bitmap({
		name = "bg_image",
		blend_mode = "add",
		layer = 1,
		texture = data.background_texture,
		w = fullscreen_panel:w(),
		h = fullscreen_panel:h()
	})

	self._bg_image:set_alpha(0.6)

	local aspect = fullscreen_panel:w() / fullscreen_panel:h()
	local texture_width = self._bg_image:texture_width()
	local texture_height = self._bg_image:texture_height()
	local sw = math.max(texture_width, texture_height * aspect)
	local sh = math.max(texture_height, texture_width / aspect)
	local dw = texture_width / sw
	local dh = texture_height / sh

	self._bg_image:set_size(dw * fullscreen_panel:w(), dh * fullscreen_panel:h())
	self._bg_image:set_right(fullscreen_panel:w())
	self._bg_image:set_center_y(fullscreen_panel:h() / 2)

	local panel_h = 0
	local count = #tweak_data.skilltree.tier_unlocks + 1
	local h = (parent_panel:h() - tree_tab_h - TOP_ADJUSTMENT) / (count - CONSOLE_PAGE_ADJUSTMENT)

	for i = 1, count, 1 do
		local color = Color.black
		local rect = tree_panel:rect({
			h = 2,
			blend_mode = "add",
			name = "rect" .. i,
			color = color
		})

		rect:set_bottom(tree_panel:h() - (i - CONSOLE_PAGE_ADJUSTMENT) * h)

		if true or i == 1 then
			rect:set_alpha(0)
			rect:hide()
		end
	end

	local tier_panels = tree_panel:panel({
		name = "tier_panels"
	})

	for tier, tier_data in ipairs(data.tiers) do
		local unlocked = managers.skilltree:tier_unlocked(tree, tier)
		local tier_panel = tier_panels:panel({
			name = "tier_panel" .. tier,
			h = h
		})
		local num_skills = #tier_data

		tier_panel:set_bottom(tree_panel:child("rect" .. tostring(tier)):top())

		local base_size = h
		local base_w = math.min(tier_panel:w() / math.max(#tier_data, 1), tier_panel:w() / 4)

		for i, skill_id in ipairs(tier_data) do
			local item = SkillTreeSkillItem:new(skill_id, tier_panel, num_skills, i, tree, tier, base_w, base_size, skill_prerequisites[skill_id])

			table.insert(self._items, item)
			item:refresh(not unlocked)
		end

		local tier_string = tostring(tier)
		local debug_text = tier_panel:text({
			word_wrap = false,
			name = "debug_text",
			wrap = false,
			align = "right",
			vertical = "bottom",
			blend_mode = "add",
			rotation = 360,
			layer = 2,
			text = tier_string,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			h = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.item_stage_3
		})

		debug_text:set_world_bottom(tree_panel:child("rect" .. tostring(tier)):world_top() + 2)

		local _, _, tw, _ = debug_text:text_rect()

		debug_text:move(tw * 2, 0)

		local lock_image = tier_panel:bitmap({
			texture = "guis/textures/pd2/skilltree/padlock",
			name = "lock",
			layer = 3,
			w = tweak_data.menu.pd2_small_font_size,
			h = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.item_stage_3
		})

		lock_image:set_blend_mode("add")
		lock_image:set_rotation(360)
		lock_image:set_world_position(debug_text:world_right(), debug_text:world_y() - 2)
		lock_image:set_visible(false)

		local add_infamy_glow = false

		if managers.experience:current_rank() > 0 then
			local tree_name = tweak_data.skilltree.trees[tree].skill

			for infamy, item in pairs(tweak_data.infamy.items) do
				if managers.infamy:owned(infamy) then
					local skilltree = item.upgrades and item.upgrades.skilltree

					if skilltree then
						local tree = skilltree.tree
						local trees = skilltree.trees

						if tree and tree == tree_name or trees and table.contains(trees, tree_name) then
							add_infamy_glow = true

							break
						end
					end
				end
			end
		end

		local cost_string = (managers.skilltree:tier_cost(tree, tier) < 10 and "0" or "") .. tostring(managers.skilltree:tier_cost(tree, tier))
		local cost_text = tier_panel:text({
			word_wrap = false,
			name = "cost_text",
			wrap = false,
			align = "left",
			vertical = "bottom",
			blend_mode = "add",
			rotation = 360,
			layer = 2,
			text = cost_string,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			h = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.item_stage_3
		})
		local x, y, w, h = cost_text:text_rect()

		cost_text:set_size(w, h)
		cost_text:set_world_bottom(tree_panel:child("rect" .. tostring(tier)):world_top() + 2)
		cost_text:set_x(debug_text:right() + tw * 3)

		if add_infamy_glow then
			local glow = tier_panel:bitmap({
				texture = "guis/textures/pd2/crimenet_marker_glow",
				name = "cost_glow",
				h = 56,
				blend_mode = "add",
				w = 56,
				rotation = 360,
				color = tweak_data.screen_colors.button_stage_3
			})

			local function anim_pulse_glow(o)
				local t = 0
				local dt = 0

				while true do
					dt = coroutine.yield()
					t = (t + dt * 0.5) % 1

					o:set_alpha((math.sin(t * 180) * 0.5 + 0.5) * 0.8)
				end
			end

			glow:set_center(cost_text:center())
			glow:animate(anim_pulse_glow)
		end

		local color = unlocked and tweak_data.screen_colors.item_stage_1 or tweak_data.screen_colors.item_stage_2

		debug_text:set_color(color)
		cost_text:set_color(color)

		if not unlocked then
			-- Nothing
		end
	end

	local ps = managers.skilltree:points_spent(self._tree)
	local max_points = 1

	for _, tier in ipairs(tweak_data.skilltree.trees[self._tree].tiers) do
		for _, skill in ipairs(tier) do
			for to_unlock, _ in ipairs(tweak_data.skilltree.skills[skill]) do
				max_points = max_points + managers.skilltree:get_skill_points(skill, to_unlock)
			end
		end
	end

	local prev_tier_p = 0
	local next_tier_p = max_points
	local ct = 0
	local count = #tweak_data.skilltree.tier_unlocks

	for i = 1, count, 1 do
		local tier_unlocks = managers.skilltree:tier_cost(self._tree, i)

		if ps < tier_unlocks then
			next_tier_p = tier_unlocks

			break
		end

		ct = i
		prev_tier_p = tier_unlocks
	end

	local diff_p = next_tier_p - prev_tier_p
	local diff_ps = ps - prev_tier_p
	local dh = self._tree_panel:child("rect2"):bottom()
	local prev_tier_object = self._tree_panel:child("rect" .. tostring(ct + 1))
	local next_tier_object = self._tree_panel:child("rect" .. tostring(ct + 2))
	local prev_tier_y = prev_tier_object and prev_tier_object:top() or 0
	local next_tier_y = next_tier_object and next_tier_object:top() or 0

	if not next_tier_object then
		next_tier_object = self._tree_panel:child("rect" .. tostring(ct))
		next_tier_y = next_tier_object and next_tier_object:top() or 0
		next_tier_y = 2 * prev_tier_y - next_tier_y
	end

	if ct > 0 then
		dh = math.max(2, tier_panels:child("tier_panel1"):world_bottom() - math.lerp(prev_tier_y, next_tier_y, diff_ps / diff_p))
	else
		dh = 0
	end

	local points_spent_panel = tree_panel:panel({
		w = 4,
		name = "points_spent_panel",
		h = dh
	})
	self._points_spent_line = BoxGuiObject:new(points_spent_panel, {
		sides = {
			2,
			2,
			0,
			0
		}
	})

	self._points_spent_line:set_clipping(dh == 0)
	points_spent_panel:set_world_center_x(tier_panels:child("tier_panel1"):child("lock"):world_center())
	points_spent_panel:set_world_bottom(tier_panels:child("tier_panel1"):world_bottom())

	for i, item in ipairs(self._items) do
		item:link(i, self._items)
	end
end

function SkillTreePage:unlock_tier(tier)
	local tier_panels = self._tree_panel:child("tier_panels")
	local tier_panel = tier_panels:child("tier_panel" .. tier)

	tier_panel:child("lock"):hide()

	local color = tweak_data.screen_colors.item_stage_1

	self._tree_panel:child("rect" .. tostring(tier + 1)):set_color(color)
	tier_panel:child("debug_text"):set_color(color)
	tier_panel:child("cost_text"):set_color(color)

	for _, item in ipairs(self._items) do
		item:refresh(false)
	end
end

function SkillTreePage:on_points_spent()
	local points_spent_panel = self._tree_panel:child("points_spent_panel")
	local tier_panels = self._tree_panel:child("tier_panels")
	local ps = managers.skilltree:points_spent(self._tree)
	local max_points = 1

	for _, tier in ipairs(tweak_data.skilltree.trees[self._tree].tiers) do
		for _, skill in ipairs(tier) do
			for to_unlock, _ in ipairs(tweak_data.skilltree.skills[skill]) do
				max_points = max_points + managers.skilltree:get_skill_points(skill, to_unlock)
			end
		end
	end

	local prev_tier_p = 0
	local next_tier_p = max_points
	local ct = 0
	local count = #tweak_data.skilltree.tier_unlocks

	for i = 1, count, 1 do
		local tier_unlocks = managers.skilltree:tier_cost(self._tree, i)

		if ps < tier_unlocks then
			next_tier_p = tier_unlocks

			break
		end

		ct = i
		prev_tier_p = tier_unlocks
	end

	local diff_p = next_tier_p - prev_tier_p
	local diff_ps = ps - prev_tier_p
	local dh = self._tree_panel:child("rect2"):bottom()
	local prev_tier_object = self._tree_panel:child("rect" .. tostring(ct + 1))
	local next_tier_object = self._tree_panel:child("rect" .. tostring(ct + 2))
	local prev_tier_y = prev_tier_object and prev_tier_object:top() or 0
	local next_tier_y = next_tier_object and next_tier_object:top() or 0

	if not next_tier_object then
		next_tier_object = self._tree_panel:child("rect" .. tostring(ct))
		next_tier_y = next_tier_object and next_tier_object:top() or 0
		next_tier_y = 2 * prev_tier_y - next_tier_y
	end

	if ct > 0 then
		dh = math.max(2, tier_panels:child("tier_panel1"):world_bottom() - math.lerp(prev_tier_y, next_tier_y, diff_ps / diff_p))
	else
		dh = 0
	end

	points_spent_panel:set_h(dh)
	self._points_spent_line:create_sides(points_spent_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})
	self._points_spent_line:set_clipping(dh == 0)
	points_spent_panel:set_world_center_x(tier_panels:child("tier_panel1"):child("lock"):world_center())
	points_spent_panel:set_world_bottom(tier_panels:child("tier_panel1"):world_bottom())
end

function SkillTreePage:item(item)
	return self._items[item or 1]
end

function SkillTreePage:activate()
	self._tree_panel:set_visible(true)
	self._bg_image:set_visible(true)
end

function SkillTreePage:deactivate()
	self._tree_panel:set_visible(false)
	self._bg_image:set_visible(false)
end

SkillTreeGui = SkillTreeGui or class()

function SkillTreeGui:init(ws, fullscreen_ws, node)
	managers.menu:active_menu().renderer.ws:hide()

	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._node = node
	self._init_layer = self._ws:panel():layer()
	self._selected_item = nil
	self._hover_spec_item = nil
	self._active_page = nil
	self._active_tree = nil
	self._prerequisites_links = {}

	managers.features:announce_feature("perk_deck")

	local menu_components_data = node:parameters().menu_component_data or {}
	local add_skilltree = not menu_components_data.hide_skilltree
	local add_specialization = not menu_components_data.hide_specialization

	self:_setup(add_skilltree, add_specialization)
	self:set_layer(5)
end

function SkillTreeGui:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function SkillTreeGui:_setup(add_skilltree, add_specialization)
	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end

	local scaled_size = managers.gui_data:scaled_size()
	self._panel = self._ws:panel():panel({
		valign = "center",
		visible = true,
		layer = self._init_layer
	})
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()

	WalletGuiObject.set_wallet(self._panel)

	local skilltree_text = self._panel:text({
		vertical = "top",
		name = "skilltree_text",
		align = "left",
		text = utf8.to_upper(managers.localization:text("menu_st_skilltree")),
		h = tweak_data.menu.pd2_large_font_size,
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local x, y, w, h = skilltree_text:text_rect()

	skilltree_text:set_size(w, h)

	local separator = self._panel:text({
		text = "|",
		vertical = "top",
		align = "left",
		h = tweak_data.menu.pd2_large_font_size,
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3
	})

	separator:set_left(skilltree_text:right() + 7.5)

	local x, y, w, h = separator:text_rect()

	separator:set_size(w, h)

	local specialization_text = self._panel:text({
		vertical = "top",
		name = "specialization_text",
		align = "left",
		text = utf8.to_upper(managers.localization:text("menu_specialization")),
		h = tweak_data.menu.pd2_large_font_size,
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3
	})

	specialization_text:set_left(separator:right() + 7.5)

	local x, y, w, h = specialization_text:text_rect()

	specialization_text:set_size(w, h)

	self._skilltree_text_highlighted = false
	self._specialization_text_highlighted = false
	self._is_skilltree_page_active = true
	local bg_text = self._fullscreen_panel:text({
		name = "title_bg",
		vertical = "top",
		h = 90,
		alpha = 0.4,
		align = "left",
		blend_mode = "add",
		layer = 1,
		text = utf8.to_upper(managers.localization:text("menu_st_skilltree")),
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	local x, y = managers.gui_data:safe_to_full_16_9(self._panel:child("skilltree_text"):world_x(), self._panel:child("skilltree_text"):world_center_y())

	bg_text:set_world_left(x)
	bg_text:set_world_center_y(y)
	bg_text:move(-13, 9)
	MenuBackdropGUI.animate_bg_text(self, bg_text)

	self._skill_tree_panel = self._panel:panel({
		visible = true,
		name = "skill_tree_panel"
	})
	self._specialization_panel = self._panel:panel({
		visible = false,
		name = "skill_tree_panel"
	})
	self._skill_tree_fullscreen_panel = self._fullscreen_panel:panel({
		visible = true,
		name = "skill_tree_panel"
	})
	self._specialization_fullscreen_panel = self._fullscreen_panel:panel({
		visible = false,
		name = "skill_tree_panel"
	})
	local points_text = self._skill_tree_panel:text({
		word_wrap = false,
		name = "points_text",
		vertical = "top",
		wrap = false,
		align = "left",
		layer = 1,
		text = utf8.to_upper(managers.localization:text("st_menu_available_skill_points", {
			points = managers.skilltree:points()
		})),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	points_text:set_left(self._skill_tree_panel:w() * WIDTH_MULTIPLIER * 2 / 3 + 10)

	if managers.menu:is_pc_controller() then
		self._panel:text({
			vertical = "bottom",
			name = "back_button",
			align = "right",
			blend_mode = "add",
			text = utf8.to_upper(managers.localization:text("menu_back")),
			h = tweak_data.menu.pd2_large_font_size,
			font_size = tweak_data.menu.pd2_large_font_size,
			font = tweak_data.menu.pd2_large_font,
			color = tweak_data.screen_colors.button_stage_3
		})
		self:make_fine_text(self._panel:child("back_button"))
		self._panel:child("back_button"):set_right(self._panel:w())
		self._panel:child("back_button"):set_bottom(self._panel:h())

		local bg_back = self._fullscreen_panel:text({
			name = "back_button",
			vertical = "bottom",
			h = 90,
			align = "right",
			alpha = 0.4,
			blend_mode = "add",
			layer = 1,
			text = utf8.to_upper(managers.localization:text("menu_back")),
			font_size = tweak_data.menu.pd2_massive_font_size,
			font = tweak_data.menu.pd2_massive_font,
			color = tweak_data.screen_colors.button_stage_3
		})
		local x, y = managers.gui_data:safe_to_full_16_9(self._panel:child("back_button"):world_right(), self._panel:child("back_button"):world_center_y())

		bg_back:set_world_right(x)
		bg_back:set_world_center_y(y)
		bg_back:move(13, -9)
		MenuBackdropGUI.animate_bg_text(self, bg_back)
	end

	local prefix = (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and managers.localization:get_default_macro("BTN_Y") or ""

	self._skill_tree_panel:text({
		vertical = "top",
		name = "respec_tree_button",
		align = "left",
		blend_mode = "add",
		text = prefix .. managers.localization:to_upper_text("st_menu_respec_tree"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = Color.black
	})
	self:make_fine_text(self._skill_tree_panel:child("respec_tree_button"))
	self._skill_tree_panel:child("respec_tree_button"):set_left(points_text:left())

	self._respec_text_id = "st_menu_respec_tree"
	local skill_set_text = self._skill_tree_panel:text({
		name = "skill_set_text",
		vertical = "top",
		blend_mode = "add",
		align = "left",
		layer = 1,
		text = managers.localization:text("menu_st_skill_switch_set", {
			skill_switch = managers.skilltree:get_skill_switch_name(managers.skilltree:get_selected_skill_switch(), true)
		}),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})
	local skill_set_bg = self._skill_tree_panel:rect({
		name = "skill_set_bg",
		alpha = 0,
		blend_mode = "add",
		color = tweak_data.screen_colors.button_stage_3
	})

	self:make_fine_text(skill_set_text)

	local skill_switch_button = self._skill_tree_panel:text({
		vertical = "top",
		name = "switch_skills_button",
		wrap = true,
		align = "left",
		word_wrap = true,
		blend_mode = "add",
		layer = 0,
		text = prefix .. managers.localization:to_upper_text("menu_st_skill_switch_title"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = Color.black,
		w = self._skill_tree_panel:w() * WIDTH_MULTIPLIER * 1 / 3 - 10
	})
	local _, _, _, h = skill_switch_button:text_rect()

	skill_switch_button:set_h(h)

	local black_rect = self._fullscreen_panel:rect({
		layer = 1,
		color = Color(0.4, 0, 0, 0)
	})
	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		layer = -1,
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h()
	})

	local function func(o)
		over(0.6, function (p)
			o:set_alpha(p)
		end)
	end

	blur:animate(func)

	local tree_tab_h = math.round(self._skill_tree_panel:h() / 14)
	local tree_tabs_panel = self._skill_tree_panel:panel({
		name = "tree_tabs_panel",
		w = self._skill_tree_panel:w() * WIDTH_MULTIPLIER,
		h = tree_tab_h,
		y = TOP_ADJUSTMENT + 1
	})
	local controller_page_tab_panel = self._skill_tree_panel:panel({
		name = "controller_page_tab_panel"
	})

	controller_page_tab_panel:set_shape(tree_tabs_panel:shape())

	local skill_title_panel = self._skill_tree_panel:panel({
		name = "skill_title_panel",
		w = math.round(self._skill_tree_panel:w() * 0.4 - 54),
		h = math.round(tweak_data.menu.pd2_medium_font_size * 2)
	})
	self._skill_title_panel = skill_title_panel

	skill_title_panel:text({
		name = "text",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		blend_mode = "add",
		text = "",
		layer = 1,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	local skill_description_panel = self._skill_tree_panel:panel({
		name = "skill_description_panel",
		w = math.round(self._skill_tree_panel:w() * (1 - WIDTH_MULTIPLIER) - BOX_GAP),
		h = math.round(self._skill_tree_panel:h() * 0.8)
	})
	self._skill_description_panel = skill_description_panel

	skill_description_panel:text({
		word_wrap = true,
		name = "text",
		vertical = "top",
		wrap = true,
		align = "left",
		valign = "scale",
		text = "",
		halign = "scale",
		layer = 1,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})
	skill_description_panel:text({
		word_wrap = true,
		name = "prerequisites_text",
		wrap = true,
		align = "left",
		text = "",
		vertical = "top",
		blend_mode = "add",
		valign = "scale",
		halign = "scale",
		layer = 1,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		h = tweak_data.menu.pd2_small_font_size + 10,
		color = tweak_data.screen_colors.important_1
	})

	self._tab_items = {}
	self._pages_order = {}
	self._pages = {}
	self._tree_tabs_scroll_panel = tree_tabs_panel:panel({
		name = "tree_tabs_scroll_panel",
		w = tree_tabs_panel:w() * WIDTH_MULTIPLIER
	})
	local tab_x = 0

	if not managers.menu:is_pc_controller() or managers.menu:is_steam_controller() then
		local button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_l") or managers.localization:get_default_macro("BTN_BOTTOM_L")
		local prev_page = controller_page_tab_panel:text({
			name = "prev_page",
			y = 0,
			w = 0,
			layer = 2,
			h = tweak_data.menu.pd2_medium_font_size,
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			text = button
		})
		local _, _, w = prev_page:text_rect()

		prev_page:set_w(w)
		prev_page:set_left(tab_x)

		tab_x = math.round(tab_x + w + 15)

		tree_tabs_panel:grow(-tab_x, 0)
		tree_tabs_panel:move(tab_x, 0)
	end

	tab_x = 0
	local skill_prerequisites = {}

	for skill_id, data in pairs(tweak_data.skilltree.skills) do
		if data.prerequisites then
			for _, id in ipairs(data.prerequisites) do
				skill_prerequisites[id] = skill_prerequisites[id] or {}

				table.insert(skill_prerequisites[id], skill_id)
			end
		end
	end

	for tree, data in ipairs(tweak_data.skilltree.trees) do
		local w = math.round(self._tree_tabs_scroll_panel:w() / #tweak_data.skilltree.trees * WIDTH_MULTIPLIER)
		local tab_item = SkillTreeTabItem:new(self._tree_tabs_scroll_panel, tree, data, w, tab_x)

		table.insert(self._tab_items, tab_item)

		local page = SkillTreePage:new(tree, data, self._skill_tree_panel, self._skill_tree_fullscreen_panel, tab_item._tree_tab:h(), skill_prerequisites)

		table.insert(self._pages_order, tree)

		self._pages[tree] = page
		local _, _, tw, _ = self._tab_items[tree]._tree_tab:child("tree_tab_name"):text_rect()
		tab_x = math.round(tab_x + tw + 15 + 5)
	end

	self._tree_tabs_scroll_panel:set_w(tab_x)

	local top_tier_panel = self._skill_tree_panel:child("1"):child("tier_panels"):child("tier_panel" .. tostring(#tweak_data.skilltree.trees[1].tiers))
	local bottom_tier_panel = self._skill_tree_panel:child("1"):child("tier_panels"):child("tier_panel1")

	skill_description_panel:set_right(self._skill_tree_panel:w())
	skill_description_panel:set_h(bottom_tier_panel:world_bottom() - top_tier_panel:world_top())
	skill_description_panel:set_world_top(top_tier_panel:world_top())

	local skill_box_panel = self._skill_tree_panel:panel({
		w = skill_description_panel:w(),
		h = skill_description_panel:h()
	})

	skill_box_panel:set_position(skill_description_panel:position())
	BoxGuiObject:new(skill_box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	points_text:set_top(skill_box_panel:bottom() + 10)

	local _, _, _, pth = points_text:text_rect()

	points_text:set_h(pth)

	local respec_tree_button = self._skill_tree_panel:child("respec_tree_button")

	if alive(respec_tree_button) then
		respec_tree_button:set_top(points_text:bottom())
	end

	local switch_skills_button = self._skill_tree_panel:child("switch_skills_button")

	if alive(switch_skills_button) then
		skill_set_text:set_top(points_text:top())
		switch_skills_button:set_top(points_text:bottom())
		skill_set_bg:set_shape(skill_set_text:left(), skill_set_text:top(), self._skill_tree_panel:w() * WIDTH_MULTIPLIER * 1 / 3 - 10, skill_set_text:h())
	end

	self._skill_switch_highlight = true

	self:check_skill_switch_button()
	skill_title_panel:set_left(skill_box_panel:left() + 10)
	skill_title_panel:set_top(skill_box_panel:top() + 10)
	skill_title_panel:set_w(skill_box_panel:w() - 20)
	skill_description_panel:set_top(skill_title_panel:bottom())
	skill_description_panel:set_h(skill_box_panel:h() - 20 - skill_title_panel:h())
	skill_description_panel:set_left(skill_box_panel:left() + 10)
	skill_description_panel:set_w(skill_box_panel:w() - 20)

	local tiers_box_panel = self._skill_tree_panel:panel({
		name = "tiers_box_panel"
	})

	tiers_box_panel:set_world_shape(top_tier_panel:world_left(), top_tier_panel:world_top(), top_tier_panel:w(), bottom_tier_panel:world_bottom() - top_tier_panel:world_top())
	BoxGuiObject:new(tiers_box_panel, {
		sides = {
			1,
			1,
			2,
			1
		}
	})

	if not managers.menu:is_pc_controller() or managers.menu:is_steam_controller() then
		local button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_r") or managers.localization:get_default_macro("BTN_BOTTOM_R")
		local next_page = controller_page_tab_panel:text({
			name = "next_page",
			y = 0,
			w = 0,
			layer = 2,
			h = tweak_data.menu.pd2_medium_font_size,
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			text = button
		})
		local _, _, w = next_page:text_rect()

		next_page:set_w(w)
		next_page:set_right(controller_page_tab_panel:w())

		tab_x = math.round(w + 15)

		tree_tabs_panel:grow(-tab_x, 0)
	end

	self._spec_tab_items = {}
	self._spec_tree_items = {}
	self._specialization_highlighted = {}
	local specialization_data = tweak_data.skilltree.specializations or {}

	if #specialization_data > 0 then
		self._active_spec_tree = nil
		self._selected_spec_tier = nil
		local skill_tree_h = math.round(self._specialization_panel:h() / 14)
		local h = (self._specialization_panel:h() - skill_tree_h - TOP_ADJUSTMENT) / 8 * 7 + 10
		local spec_box_panel = self._specialization_panel:panel({
			name = "spec_box_panel"
		})

		spec_box_panel:set_shape(tiers_box_panel:x(), tiers_box_panel:y(), self._specialization_panel:w() * SPEC_WIDTH_MULTIPLIER, h)

		local spec_box = BoxGuiObject:new(spec_box_panel, {
			sides = {
				1,
				1,
				2,
				1
			}
		})

		spec_box:set_clipping(false)

		local desc_box_panel = self._specialization_panel:panel({
			name = "desc_box_panel"
		})

		desc_box_panel:set_shape(spec_box_panel:right() + 20, spec_box_panel:y(), 0, spec_box_panel:h())
		desc_box_panel:set_w(self._specialization_panel:w() - desc_box_panel:x())

		self._btns = {}
		local BTNS = {
			activate_spec = {
				btn = "BTN_Y",
				name = "menu_st_activate_spec",
				prio = 1,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "activate_specialization")
			},
			add_points = {
				btn = "BTN_A",
				prio = 2,
				name = "menu_st_add_spec_points"
			},
			remove_points = {
				btn = "BTN_X",
				name = "menu_st_remove_spec_points",
				prio = 3,
				pc_btn = "menu_remove_item"
			},
			max_points = {
				btn = "BTN_STICK_R",
				name = "menu_st_max_perk_deck",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "max_specialization")
			}
		}
		self._btn_panel = self._specialization_panel:panel({
			name = "btn_panel",
			h = 136,
			x = desc_box_panel:x(),
			w = desc_box_panel:w()
		})

		self._btn_panel:set_bottom(desc_box_panel:bottom())

		self._button_border = BoxGuiObject:new(self._btn_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		self._button_border:set_clipping(false)

		self._buttons = self._btn_panel:panel({})
		local btn_x = 10

		for btn, btn_data in pairs(BTNS) do
			local new_btn = SpecializationGuiButtonItem:new(self._buttons, btn_data, btn_x)
			self._btns[btn] = new_btn
		end

		desc_box_panel:grow(0, -self._btn_panel:h() - 10)

		self._desc_box = BoxGuiObject:new(desc_box_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		self._desc_box:set_clipping(false)

		local spec_tab_h = skill_tree_h
		local spec_tabs_panel = self._specialization_panel:panel({
			name = "spec_tabs_panel",
			w = self._specialization_panel:w() * SPEC_WIDTH_MULTIPLIER,
			h = tree_tab_h,
			y = TOP_ADJUSTMENT + 1
		})
		self._spec_tabs_scroll_panel = spec_tabs_panel:panel({
			name = "spec_tabs_scroll_panel",
			w = spec_tabs_panel:w() * SPEC_WIDTH_MULTIPLIER
		})
		local controller_page_tab_panel = self._specialization_panel:panel({
			name = "controller_page_tab_panel"
		})

		controller_page_tab_panel:set_shape(spec_tabs_panel:shape())

		local tab_x = 0

		if not managers.menu:is_pc_controller() or managers.menu:is_steam_controller() then
			local button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_l") or managers.localization:get_default_macro("BTN_BOTTOM_L")
			local prev_page = controller_page_tab_panel:text({
				name = "prev_page",
				y = 0,
				w = 0,
				layer = 2,
				h = tweak_data.menu.pd2_medium_font_size,
				font_size = tweak_data.menu.pd2_medium_font_size,
				font = tweak_data.menu.pd2_medium_font,
				text = button
			})
			local _, _, w = prev_page:text_rect()

			prev_page:set_w(w)
			prev_page:set_left(tab_x)

			tab_x = math.round(tab_x + prev_page:w() + 15)

			spec_tabs_panel:grow(-tab_x, 0)
			spec_tabs_panel:move(tab_x, 0)
		end

		tab_x = 0
		local specialization_page_panel = spec_box_panel:panel({
			y = 0
		})

		for tree, data in ipairs(specialization_data) do
			local w = math.round(self._spec_tabs_scroll_panel:w() / #specialization_data * SPEC_WIDTH_MULTIPLIER)
			local tab_item = SpecializationTabItem:new(self._spec_tabs_scroll_panel, tree, data, w, tab_x)

			table.insert(self._spec_tab_items, tab_item)

			local tree_item = SpecializationTreeItem:new(tree, specialization_page_panel, tab_item)

			table.insert(self._spec_tree_items, tree_item)

			local _, _, tw, _ = self._spec_tab_items[tree]._spec_tab:child("spec_tab_name"):text_rect()
			tab_x = math.round(tab_x + tw + 15 + 5)
		end

		self._spec_tabs_scroll_panel:set_w(tab_x)
		specialization_page_panel:set_h(self._spec_tree_items[#self._spec_tree_items]:panel():bottom())

		self._specialization_page_panel = specialization_page_panel
		self._spec_scroll_up_box = BoxGuiObject:new(spec_box_panel, {
			sides = {
				0,
				0,
				2,
				0
			}
		})
		self._spec_scroll_down_box = BoxGuiObject:new(spec_box_panel, {
			sides = {
				0,
				0,
				0,
				2
			}
		})
		self._specialization_scroll_y = 1

		self._spec_scroll_up_box:set_visible(false)
		self._spec_scroll_down_box:set_visible(NUM_TREES_PER_PAGE < #self._spec_tree_items)

		self._spec_tree_height = self._spec_tree_items[2]:panel():top()

		if not managers.menu:is_pc_controller() or managers.menu:is_steam_controller() then
			local button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_r") or managers.localization:get_default_macro("BTN_BOTTOM_R")
			local next_page = controller_page_tab_panel:text({
				name = "next_page",
				y = 0,
				w = 0,
				layer = 2,
				h = tweak_data.menu.pd2_medium_font_size,
				font_size = tweak_data.menu.pd2_medium_font_size,
				font = tweak_data.menu.pd2_medium_font,
				text = button
			})
			local _, _, w = next_page:text_rect()

			next_page:set_w(w)
			next_page:set_right(controller_page_tab_panel:w())

			tab_x = math.round(next_page:w() + 15)

			spec_tabs_panel:grow(-tab_x, 0)
		end

		self._spec_scroll_bar_panel = self._specialization_panel:panel({
			w = 20,
			name = "spec_scroll_bar_panel",
			h = spec_box_panel:h()
		})

		self._spec_scroll_bar_panel:set_world_left(spec_box_panel:world_right())
		self._spec_scroll_bar_panel:set_world_top(spec_box_panel:world_top())

		local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
		local scroll_up_indicator_arrow = self._spec_scroll_bar_panel:bitmap({
			name = "scroll_up_indicator_arrow",
			layer = 2,
			texture = texture,
			texture_rect = rect,
			color = Color.white
		})

		scroll_up_indicator_arrow:set_center_x(self._spec_scroll_bar_panel:w() / 2)

		local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
		local scroll_down_indicator_arrow = self._spec_scroll_bar_panel:bitmap({
			name = "scroll_down_indicator_arrow",
			layer = 2,
			rotation = 180,
			texture = texture,
			texture_rect = rect,
			color = Color.white
		})

		scroll_down_indicator_arrow:set_bottom(self._spec_scroll_bar_panel:h())
		scroll_down_indicator_arrow:set_center_x(self._spec_scroll_bar_panel:w() / 2)

		local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()

		self._spec_scroll_bar_panel:rect({
			alpha = 0.05,
			w = 4,
			color = Color.black,
			y = scroll_up_indicator_arrow:bottom(),
			h = bar_h
		}):set_center_x(self._spec_scroll_bar_panel:w() / 2)

		bar_h = scroll_down_indicator_arrow:bottom() - scroll_up_indicator_arrow:top()
		local scroll_bar = self._spec_scroll_bar_panel:panel({
			name = "scroll_bar",
			layer = 2,
			h = bar_h
		})
		local scroll_bar_box_panel = scroll_bar:panel({
			w = 4,
			name = "scroll_bar_box_panel",
			valign = "scale",
			halign = "scale"
		})
		self._spec_scroll_bar_box_class = BoxGuiObject:new(scroll_bar_box_panel, {
			sides = {
				2,
				2,
				0,
				0
			}
		})

		self._spec_scroll_bar_box_class:set_aligns("scale", "scale")
		scroll_bar_box_panel:set_w(8)
		scroll_bar_box_panel:set_center_x(scroll_bar:w() / 2)
		scroll_bar:set_top(scroll_up_indicator_arrow:top())
		scroll_bar:set_center_x(scroll_up_indicator_arrow:center_x())

		local points_text = self._specialization_panel:text({
			word_wrap = false,
			name = "points_text",
			vertical = "top",
			wrap = false,
			align = "left",
			layer = 1,
			text = utf8.to_upper(managers.localization:text("menu_st_available_spec_points", {
				points = managers.money:add_decimal_marks_to_string(tostring(managers.skilltree:specialization_points()))
			})),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})

		make_fine_text(points_text)
		points_text:set_right(spec_box_panel:right())
		points_text:set_top(spec_box_panel:bottom() + 20)

		local spec_description_panel = desc_box_panel:panel({
			halign = "grow",
			valign = "grow"
		})

		spec_description_panel:grow(-20, -20)
		spec_description_panel:move(10, 10)

		self._spec_description_title = spec_description_panel:text({
			word_wrap = true,
			blend_mode = "normal",
			wrap = true,
			text = "",
			halign = "grow",
			valign = "grow",
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text
		})
		self._spec_description_locked = spec_description_panel:text({
			word_wrap = true,
			blend_mode = "add",
			wrap = true,
			text = "",
			halign = "grow",
			valign = "grow",
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.important_1
		})
		self._spec_description_text = spec_description_panel:text({
			word_wrap = true,
			blend_mode = "normal",
			wrap = true,
			text = "",
			halign = "grow",
			valign = "grow",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})
		self._spec_description_progress = spec_description_panel:text({
			word_wrap = true,
			blend_mode = "normal",
			wrap = true,
			text = "",
			halign = "grow",
			valign = "grow",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})
	end

	self:show_btns()
	self:_set_active_skill_page(managers.skilltree:get_most_progressed_tree())
	self:_set_active_spec_tree(managers.skilltree:get_specialization_value("current_specialization"))
	self:set_selected_item(self._active_page:item(), true)

	self._use_skilltree = add_skilltree or false
	self._use_specialization = add_specialization or false

	if not self._use_skilltree then
		skilltree_text:hide()
		specialization_text:set_left(skilltree_text:left())
	end

	separator:set_visible(self._use_skilltree and self._use_specialization)
	specialization_text:set_visible(self._use_specialization)
	self:set_skilltree_page_active(self._use_skilltree)
	self:_rec_round_object(self._panel)
end

function SkillTreeGui:check_spec_grab_scroll_bar(x, y)
	local scroll_bar = self._spec_scroll_bar_panel:child("scroll_bar")

	if self._spec_scroll_bar_panel:visible() and scroll_bar:inside(x, y) then
		self._grabbed_spec_scroll_bar = true
		self._current_spec_scroll_bar_y = y

		return true
	end

	return false
end

function SkillTreeGui:release_scroll_bar()
	if self._grabbed_spec_scroll_bar then
		self._grabbed_spec_scroll_bar = nil

		return true
	end

	return false
end

function SkillTreeGui:moved_scroll_bar(x, y)
	local scroll_bar = self._spec_scroll_bar_panel:child("scroll_bar")

	if self._grabbed_spec_scroll_bar then
		self._current_spec_scroll_bar_y = self:scroll_with_bar(y, self._current_spec_scroll_bar_y or 0)

		return true, "grab"
	elseif self._spec_scroll_bar_panel:visible() and scroll_bar:inside(x, y) then
		return true, "hand"
	elseif self._spec_scroll_bar_panel:child("scroll_up_indicator_arrow"):visible() and self._spec_scroll_bar_panel:child("scroll_up_indicator_arrow"):inside(x, y) then
		return true, "link"
	elseif self._spec_scroll_bar_panel:child("scroll_down_indicator_arrow"):visible() and self._spec_scroll_bar_panel:child("scroll_down_indicator_arrow"):inside(x, y) then
		return true, "link"
	end

	return false, "arrow"
end

function SkillTreeGui:scroll_with_bar(target_y, current_y)
	local diff = current_y - target_y

	if diff == 0 then
		return current_y
	end

	local scroll_up_indicator_arrow = self._spec_scroll_bar_panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = self._spec_scroll_bar_panel:child("scroll_down_indicator_arrow")
	local scroll_bar = self._spec_scroll_bar_panel:child("scroll_bar")
	local spec_panel = self._specialization_panel:child("spec_box_panel")
	local spec_scroll_panel = self._specialization_page_panel
	local mul = spec_scroll_panel:h() / spec_panel:h()
	local height = self._spec_tree_height - 24
	local tree_height = height / mul
	local dir = diff / math.abs(diff)
	local steps = math.floor(math.abs(current_y - target_y) / tree_height)

	if steps ~= 0 then
		self:set_spec_scroll_indicators(self._specialization_scroll_y - steps * dir)
	end

	return current_y - steps * tree_height * dir
end

function SkillTreeGui:set_spec_scroll_indicators(tree)
	if tree then
		self._specialization_scroll_y = tree
	elseif self._active_spec_tree < self._specialization_scroll_y then
		self._specialization_scroll_y = self._active_spec_tree
	elseif self._specialization_scroll_y < self._active_spec_tree - NUM_TREES_PER_PAGE + 1 then
		self._specialization_scroll_y = self._active_spec_tree - NUM_TREES_PER_PAGE + 1
	end

	self._specialization_scroll_y = math.clamp(self._specialization_scroll_y, 1, #self._spec_tab_items - NUM_TREES_PER_PAGE + 1)
	local top_scroll_tree_item = self._spec_tree_items[self._specialization_scroll_y]

	if top_scroll_tree_item then
		self._specialization_page_panel:set_y(-top_scroll_tree_item:panel():top() + 24)
	else
		return
	end

	for tree, tree_item in ipairs(self._spec_tree_items) do
		tree_item:set_visible(math.within(tree, self._specialization_scroll_y, self._specialization_scroll_y + NUM_TREES_PER_PAGE - 1))
	end

	local scroll_up_indicator_arrow = self._spec_scroll_bar_panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = self._spec_scroll_bar_panel:child("scroll_down_indicator_arrow")
	local scroll_bar = self._spec_scroll_bar_panel:child("scroll_bar")
	local spec_box_panel = self._specialization_panel:child("spec_box_panel")
	local bar_h = scroll_down_indicator_arrow:bottom() - scroll_up_indicator_arrow:top()
	local scroll_diff = spec_box_panel:h() / self._specialization_page_panel:h()

	scroll_bar:set_h(bar_h * scroll_diff)

	local sh = self._specialization_page_panel:h()

	scroll_bar:set_y(-self._specialization_page_panel:y() * spec_box_panel:h() / sh)
	self._spec_scroll_up_box:set_visible(self._specialization_scroll_y > 1)
	self._spec_scroll_down_box:set_visible(self._specialization_scroll_y < #self._spec_tab_items - NUM_TREES_PER_PAGE + 1)
	scroll_up_indicator_arrow:set_visible(self._specialization_scroll_y > 1)
	scroll_down_indicator_arrow:set_visible(self._specialization_scroll_y < #self._spec_tab_items - NUM_TREES_PER_PAGE + 1)
	self._spec_scroll_bar_panel:set_visible(NUM_TREES_PER_PAGE < #self._spec_tree_items)
end

function SkillTreeGui:_rec_round_object(object)
	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end

	local x, y = object:position()

	object:set_position(math.round(x), math.round(y))
end

function SkillTreeGui:activate_next_tree_panel(play_sound)
	for i, tree_name in ipairs(self._pages_order) do
		if tree_name == self._active_tree then
			if i == #self._pages_order then
				return
			end

			local next_i = i + 1

			self:set_active_page(self._pages_order[next_i], play_sound)

			return true
		end
	end
end

function SkillTreeGui:activate_prev_tree_panel(play_sound)
	for i, tree_name in ipairs(self._pages_order) do
		if tree_name == self._active_tree then
			if i == 1 then
				return
			end

			local prev_i = i - 1

			self:set_active_page(self._pages_order[prev_i], play_sound)

			return true
		end
	end
end

function SkillTreeGui:activate_next_spec_panel(play_sound)
	self._active_spec_tree = self._active_spec_tree or 0

	if self._active_spec_tree == #tweak_data.skilltree.specializations then
		return
	end

	local next_tree = math.min(self._active_spec_tree + 1, #tweak_data.skilltree.specializations)

	self:set_active_page(self._spec_tab_items[next_tree]:tree(), play_sound)

	return true
end

function SkillTreeGui:activate_prev_spec_panel(play_sound)
	self._active_spec_tree = self._active_spec_tree or 0

	if self._active_spec_tree == 1 then
		return
	end

	local next_tree = math.max(self._active_spec_tree - 1, 1)

	self:set_active_page(self._spec_tab_items[next_tree]:tree(), play_sound)

	return true
end

function SkillTreeGui:set_active_page(tree_panel_name, play_sound)
	if self._is_skilltree_page_active then
		self:_set_active_skill_page(tree_panel_name, play_sound)
	else
		self:_set_active_spec_tree(tree_panel_name, play_sound)
	end
end

function SkillTreeGui:_set_active_spec_tree(tree_panel_name, play_sound)
	if self._active_spec_tree == tree_panel_name then
		return
	end

	for tree, tab_item in ipairs(self._spec_tab_items) do
		tab_item:set_active(tree_panel_name == tab_item:tree())

		if tree_panel_name == tab_item:tree() then
			local spec_tabs_panel = self._specialization_panel:child("spec_tabs_panel")
			local spec_tab = tab_item._spec_tab
			local tab_wl = spec_tab:world_left()
			local tab_wr = spec_tab:world_right()
			local panel_wl = spec_tabs_panel:world_left()
			local panel_wr = spec_tabs_panel:world_right()

			if tab_wl < panel_wl then
				self._spec_tabs_scroll_panel:move(panel_wl - tab_wl, 0)
			elseif panel_wr < tab_wr then
				self._spec_tabs_scroll_panel:move(panel_wr - tab_wr, 0)
			end

			self._active_spec_tree = tree
			local prev_page_button = self._specialization_panel:child("controller_page_tab_panel"):child("prev_page")
			local next_page_button = self._specialization_panel:child("controller_page_tab_panel"):child("next_page")

			if prev_page_button then
				prev_page_button:set_visible(self._active_spec_tree > 1)
			end

			if next_page_button then
				next_page_button:set_visible(self._active_spec_tree < #self._spec_tab_items)
			end

			if play_sound then
				managers.menu_component:post_event("highlight")
			end

			self._spec_tree_items[tree]:select()

			local tree_tabs_panel = self._specialization_panel:child("spec_tabs_panel")
			local tree_tab = tab_item._spec_tab
			local tab_wl = tree_tab:world_left()
			local tab_wr = tree_tab:world_right()
			local panel_wl = tree_tabs_panel:world_left()
			local panel_wr = tree_tabs_panel:world_right()

			if tab_wl < panel_wl then
				self._spec_tabs_scroll_panel:move(panel_wl - tab_wl, 0)
			elseif panel_wr < tab_wr then
				self._spec_tabs_scroll_panel:move(panel_wr - tab_wr, 0)
			end

			self:refresh_btns()
		else
			self._spec_tree_items[tree]:deselect()
		end
	end

	self:set_spec_scroll_indicators()
end

function SkillTreeGui:_set_active_skill_page(tree_panel_name, play_sound)
	for tree, page in pairs(self._pages) do
		if tree == tree_panel_name then
			if self._selected_item then
				self._selected_item:deselect()

				self._selected_item = nil
			end

			local item = page:activate()
		else
			page:deactivate()
		end
	end

	self._active_page = self._pages[tree_panel_name]
	self._active_tree = tree_panel_name
	local prev_page_button = self._skill_tree_panel:child("controller_page_tab_panel"):child("prev_page")
	local next_page_button = self._skill_tree_panel:child("controller_page_tab_panel"):child("next_page")

	if prev_page_button then
		prev_page_button:set_visible(self._active_tree > 1)
	end

	if next_page_button then
		next_page_button:set_visible(self._active_tree < #self._pages)
	end

	local respec_cost_text = self._skill_tree_panel:child("respec_cost_text")

	if alive(respec_cost_text) then
		respec_cost_text:set_text(managers.localization:text("st_menu_respec_cost", {
			cost = managers.experience:cash_string(managers.money:get_skilltree_tree_respec_cost(tree_panel_name))
		}))
		self:make_fine_text(respec_cost_text)
		respec_cost_text:set_bottom(self._skill_tree_panel:child("money_text"):top())
	end

	self:check_respec_button(nil, nil, true)

	if play_sound then
		managers.menu_component:post_event("highlight")
	end

	for _, tab_item in ipairs(self._tab_items) do
		tab_item:set_active(tree_panel_name == tab_item:tree())

		if tree_panel_name == tab_item:tree() then
			local tree_tabs_panel = self._skill_tree_panel:child("tree_tabs_panel")
			local tree_tab = tab_item._tree_tab
			local tab_wl = tree_tab:world_left()
			local tab_wr = tree_tab:world_right()
			local panel_wl = tree_tabs_panel:world_left()
			local panel_wr = tree_tabs_panel:world_right()

			if tab_wl < panel_wl then
				self._tree_tabs_scroll_panel:move(panel_wl - tab_wl, 0)
			elseif panel_wr < tab_wr then
				self._tree_tabs_scroll_panel:move(panel_wr - tab_wr, 0)
			end
		end
	end
end

function SkillTreeGui:set_layer(layer)
	self._panel:set_layer(self._init_layer + layer)
end

function SkillTreeGui:layer()
	return self._panel:layer()
end

function SkillTreeGui:set_selected_item(item, no_sound)
	if self._is_skilltree_page_active then
		self:_set_selected_skill_item(item, no_sound)
	else
		self:_set_selected_spec_item(item, no_sound)
	end
end

function SkillTreeGui:update_spec_descriptions(item)
	item = item or self._selected_spec_item

	if not item then
		self._spec_description_title:set_text("")
		self._spec_description_locked:set_text("")
		self._spec_description_text:set_text("")
		self._spec_description_progress:set_text("")

		return
	end

	local current_tier = managers.skilltree:get_specialization_value(item:tree(), "tiers", "current_tier")
	local max_tier = managers.skilltree:get_specialization_value(item:tree(), "tiers", "max_tier")
	local locked_string = ""
	local progress_string = ""

	if current_tier < max_tier and self._selected_spec_tier and self._selected_spec_tier == current_tier + 1 then
		local current_points = managers.skilltree:get_specialization_value(item:tree(), "tiers", "next_tier_data", "current_points")
		local points = managers.skilltree:get_specialization_value(item:tree(), "tiers", "next_tier_data", "points")
		progress_string = managers.localization:to_upper_text("menu_st_progress", {
			progress = string.format("%i/%i", current_points, points)
		})
	end

	local name_string = item:name_string()
	local desc_string = item:desc_string()
	local text_dissected = utf8.characters(desc_string)
	local idsp = Idstring("#")
	local start_ci = {}
	local end_ci = {}
	local first_ci = true

	for i, c in ipairs(text_dissected) do
		if Idstring(c) == idsp then
			local next_c = text_dissected[i + 1]

			if next_c and Idstring(next_c) == idsp then
				if first_ci then
					table.insert(start_ci, i)
				else
					table.insert(end_ci, i)
				end

				first_ci = not first_ci
			end
		end
	end

	if #start_ci == #end_ci then
		for i = 1, #start_ci, 1 do
			start_ci[i] = start_ci[i] - ((i - 1) * 4 + 1)
			end_ci[i] = end_ci[i] - (i * 4 - 1)
		end
	end

	desc_string = string.gsub(desc_string, "##", "")

	self._spec_description_text:set_text(desc_string)
	self._spec_description_text:clear_range_color(1, utf8.len(desc_string))

	if #start_ci ~= #end_ci then
		Application:error("SkillTreeGui: Non even amount of ##'s in Perk description string!", #start_ci, #end_ci)
	else
		for i = 1, #start_ci, 1 do
			self._spec_description_text:set_range_color(start_ci[i], end_ci[i], item:desc_custom_color() or tweak_data.screen_colors.resource)
		end
	end

	local dlc = tweak_data:get_raw_value("skilltree", "specializations", item:tree(), "dlc")

	if dlc and not managers.dlc:is_dlc_unlocked(dlc) then
		local unlock_id = tweak_data:get_raw_value("lootdrop", "global_values", dlc, "unlock_id") or "bm_menu_dlc_locked"
		locked_string = managers.localization:to_upper_text(unlock_id)
	end

	self._spec_description_locked:set_text(locked_string)
	self._spec_description_title:set_text(name_string)
	self._spec_description_progress:set_text(progress_string)

	local font_size = nil

	repeat
		font_size = font_size and font_size * 0.98 or tweak_data.menu.pd2_small_font_size

		self._spec_description_text:set_font_size(font_size)

		local x, y, w, h = self._spec_description_title:text_rect()

		self._spec_description_locked:set_y(self._spec_description_title:y() + h + 15)

		local x, y, w, h = self._spec_description_locked:text_rect()

		self._spec_description_text:set_y(self._spec_description_locked:y() + h + 10)

		local x, y, w, h = self._spec_description_text:text_rect()

		self._spec_description_progress:set_y(self._spec_description_text:y() + h + 10)

		local _, _, _, h = self._spec_description_progress:text_rect()
		local y = self._spec_description_progress:y()
	until y + h < self._spec_description_progress:parent():h()
end

function SkillTreeGui:set_hover_spec_item(item, no_sound)
	if self._hover_spec_item ~= item then
		if self._hover_spec_item then
			self._hover_spec_item:deselect()
		end

		if item then
			if item.tree then
				no_sound = no_sound and self._active_spec_tree == item:tree()
			end

			if item.tier then
				self._selected_spec_tier = item:tier()
			end

			item:select(no_sound)

			self._hover_spec_item = item

			self:update_spec_descriptions(item)
		end
	end
end

function SkillTreeGui:_set_selected_spec_item(item, no_sound)
	self:set_hover_spec_item(item)

	if self._selected_spec_item ~= item then
		self._selected_spec_item = item

		self:refresh_btns()
	end
end

function SkillTreeGui:_set_selected_skill_item(item, no_sound)
	if self._selected_item ~= item then
		if self._selected_item then
			self._selected_item:deselect()
		end

		if item then
			if item.tree then
				no_sound = no_sound and self._active_tree == item:tree()
			end

			item:select(no_sound)

			self._selected_item = item
		end
	end

	local text = ""
	local prerequisite_text = ""
	local title_text = ""
	self._prerequisites_links = self._prerequisites_links or {}

	for _, data in ipairs(self._prerequisites_links) do
		if data ~= item then
			data:refresh()
		end
	end

	self._prerequisites_links = {}
	local skill_stat_color = tweak_data.screen_colors.resource
	local color_replace_table = {}
	local tier_bonus_text = ""

	if self._selected_item and self._selected_item._skill_panel then
		local skill_id = self._selected_item._skill_id
		local tweak_data_skill = tweak_data.skilltree.skills[skill_id]
		local points = managers.skilltree:points() or 0
		local basic_cost = managers.skilltree:get_skill_points(skill_id, 1) or 0
		local pro_cost = managers.skilltree:get_skill_points(skill_id, 2) or 0
		local talent = tweak_data.skilltree.skills[skill_id]
		local unlocked = managers.skilltree:skill_unlocked(nil, skill_id)
		local step = managers.skilltree:next_skill_step(skill_id)
		local completed = managers.skilltree:skill_completed(skill_id)
		local points = managers.skilltree:points()
		local spending_money = managers.money:total()
		local skill_descs = tweak_data.upgrades.skill_descs[skill_id] or {
			0,
			0
		}
		local basic_color_index = 1
		local pro_color_index = 2 + (skill_descs[1] or 0)

		if step > 1 then
			basic_cost = utf8.to_upper(managers.localization:text("st_menu_skill_owned"))
			color_replace_table[basic_color_index] = tweak_data.screen_colors.resource
		else
			local money_cost = managers.money:get_skillpoint_cost(self._selected_item._tree, self._selected_item._tier, basic_cost)
			local can_afford = basic_cost <= points and money_cost <= spending_money
			color_replace_table[basic_color_index] = can_afford and tweak_data.screen_colors.resource or tweak_data.screen_colors.important_1
			basic_cost = managers.localization:text(basic_cost == 1 and "st_menu_point" or "st_menu_point_plural", {
				points = basic_cost
			}) .. " / " .. managers.experience:cash_string(money_cost)
		end

		if step > 2 then
			pro_cost = utf8.to_upper(managers.localization:text("st_menu_skill_owned"))
			color_replace_table[pro_color_index] = tweak_data.screen_colors.resource
		else
			local money_cost = managers.money:get_skillpoint_cost(self._selected_item._tree, self._selected_item._tier, pro_cost)
			local can_afford = pro_cost <= points and money_cost <= spending_money
			color_replace_table[pro_color_index] = can_afford and tweak_data.screen_colors.resource or tweak_data.screen_colors.important_1
			pro_cost = managers.localization:text(pro_cost == 1 and "st_menu_point" or "st_menu_point_plural", {
				points = pro_cost
			}) .. " / " .. managers.experience:cash_string(money_cost)
		end

		local macroes = {
			basic = basic_cost,
			pro = pro_cost
		}

		for i, d in pairs(skill_descs) do
			macroes[i] = d
		end

		title_text = utf8.to_upper(managers.localization:text(tweak_data.skilltree.skills[skill_id].name_id))
		text = managers.localization:text(tweak_data_skill.desc_id, macroes)

		if self._selected_item._tier then
			if not unlocked then
				local point_spent = managers.skilltree:points_spent(self._selected_item._tree) or 0
				local tier_unlocks = managers.skilltree:tier_cost(self._selected_item._tree, self._selected_item._tier) or 0
				local points_needed = tier_unlocks - point_spent
				prerequisite_text = prerequisite_text .. managers.localization:text(points_needed == 1 and "st_menu_points_to_unlock_tier_singular" or "st_menu_points_to_unlock_tier", {
					points = points_needed,
					tier = self._selected_item._tier
				}) .. "\n"
			end

			if not tweak_data.skilltree.HIDE_TIER_BONUS then
				local skilltree = tweak_data.skilltree.trees[self._active_tree] and tweak_data.skilltree.trees[self._active_tree].skill or "NIL"
				local tier_descs = tweak_data.upgrades.skill_descs[tostring(skilltree) .. "_tier" .. tostring(self._selected_item._tier)]
				tier_bonus_text = "\n\n" .. utf8.to_upper(managers.localization:text(unlocked and "st_menu_tier_unlocked" or "st_menu_tier_locked")) .. "\n" .. managers.localization:text(tweak_data.skilltree.skills[tweak_data.skilltree.trees[self._selected_item._tree].skill][self._selected_item._tier].desc_id, tier_descs)
			end
		end

		text = text .. tier_bonus_text
		local prerequisites = talent.prerequisites or {}
		local add_prerequisite = true

		for _, prerequisite in ipairs(prerequisites) do
			local unlocked = managers.skilltree:skill_step(prerequisite)

			if unlocked and unlocked == 0 then
				if add_prerequisite then
					prerequisite_text = prerequisite_text .. managers.localization:text("st_menu_prerequisite_following_skill" .. (#prerequisites > 1 and "_plural" or ""))
					add_prerequisite = nil
				end

				prerequisite_text = prerequisite_text .. "   " .. managers.localization:text(tweak_data.skilltree.skills[prerequisite].name_id) .. "\n"

				if self._active_page then
					for _, item in ipairs(self._active_page._items) do
						if item._skill_id == prerequisite then
							item._skill_panel:child("state_image"):set_color(tweak_data.screen_colors.important_1)
							table.insert(self._prerequisites_links, item)
						end
					end
				end
			end
		end
	end

	self._skill_title_panel:child("text"):set_text(title_text)

	local desc_pre_text = self._skill_description_panel:child("prerequisites_text")

	if prerequisite_text == "" then
		desc_pre_text:hide()
		desc_pre_text:set_h(0)
	else
		prerequisite_text = utf8.to_upper(prerequisite_text)

		desc_pre_text:show()
		desc_pre_text:set_text(prerequisite_text)

		local x, y, w, h = desc_pre_text:text_rect()

		desc_pre_text:set_h(h)
	end

	local text_dissected = utf8.characters(text)
	local idsp = Idstring("#")
	local start_ci = {}
	local end_ci = {}
	local first_ci = true

	for i, c in ipairs(text_dissected) do
		if Idstring(c) == idsp then
			local next_c = text_dissected[i + 1]

			if next_c and Idstring(next_c) == idsp then
				if first_ci then
					table.insert(start_ci, i)
				else
					table.insert(end_ci, i)
				end

				first_ci = not first_ci
			end
		end
	end

	if #start_ci == #end_ci then
		for i = 1, #start_ci, 1 do
			start_ci[i] = start_ci[i] - ((i - 1) * 4 + 1)
			end_ci[i] = end_ci[i] - (i * 4 - 1)
		end
	end

	text = string.gsub(text, "##", "")
	local desc_text = self._skill_description_panel:child("text")

	desc_text:set_text(text)
	desc_text:set_y(math.round(desc_pre_text:h() * 1.15))
	desc_text:clear_range_color(1, utf8.len(text))

	if #start_ci ~= #end_ci then
		Application:error("SkillTreeGui: Not even amount of ##'s in skill description string!", #start_ci, #end_ci)
	else
		for i = 1, #start_ci, 1 do
			desc_text:set_range_color(start_ci[i], end_ci[i], color_replace_table[i] or skill_stat_color)
		end
	end
end

function SkillTreeGui:check_skill_switch_button(x, y, force_text_update)
	local inside = false

	if x and y and self._skill_tree_panel:child("switch_skills_button"):inside(x, y) then
		if not self._skill_switch_highlight then
			self._skill_switch_highlight = true

			self._skill_tree_panel:child("switch_skills_button"):set_color(tweak_data.screen_colors.button_stage_2)
			managers.menu_component:post_event("highlight")
		end

		inside = true
	elseif self._skill_switch_highlight then
		self._skill_switch_highlight = false

		self._skill_tree_panel:child("switch_skills_button"):set_color(managers.menu:is_pc_controller() and tweak_data.screen_colors.button_stage_3 or Color.black)
	end

	if x and y and self._skill_tree_panel:child("skill_set_bg"):inside(x, y) then
		if not self._skill_set_highlight then
			self._skill_set_highlight = true

			self._skill_tree_panel:child("skill_set_text"):set_color(tweak_data.screen_colors.button_stage_2)
			self._skill_tree_panel:child("skill_set_bg"):set_alpha(0.35)
			managers.menu_component:post_event("highlight")
		end

		inside = true
	elseif self._skill_set_highlight then
		self._skill_set_highlight = false

		self._skill_tree_panel:child("skill_set_text"):set_color(tweak_data.screen_colors.text)
		self._skill_tree_panel:child("skill_set_bg"):set_alpha(0)
	end

	if not managers.menu:is_pc_controller() or managers.menu:is_steam_controller() then
		local text_id = "st_menu_respec_tree"
		local prefix = managers.localization:get_default_macro("BTN_X")

		self._skill_tree_panel:child("switch_skills_button"):set_color(tweak_data.screen_colors.text)
		self._skill_tree_panel:child("switch_skills_button"):set_text(prefix .. managers.localization:to_upper_text("menu_st_skill_switch_title"))
	end

	return inside
end

function SkillTreeGui:check_respec_button(x, y, force_text_update)
	local text_id = "st_menu_respec_tree"
	local prefix = (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and managers.localization:get_default_macro("BTN_Y") or ""
	local macroes = {}

	if not managers.menu:is_pc_controller() or managers.menu:is_steam_controller() then
		self._skill_tree_panel:child("respec_tree_button"):set_color(tweak_data.screen_colors.text)
	end

	if managers.skilltree:points_spent(self._active_tree) == 0 then
		self._skill_tree_panel:child("respec_tree_button"):set_color(Color.black)

		self._respec_highlight = false
		prefix = ""
	elseif x and y and self._skill_tree_panel:child("respec_tree_button"):inside(x, y) then
		if not self._respec_highlight then
			self._respec_highlight = true

			self._skill_tree_panel:child("respec_tree_button"):set_color(tweak_data.screen_colors.button_stage_2)
			managers.menu_component:post_event("highlight")
		end
	else
		self._respec_highlight = false

		if not managers.menu:is_pc_controller() or managers.menu:is_steam_controller() then
			self._skill_tree_panel:child("respec_tree_button"):set_color(tweak_data.screen_colors.text)
		else
			self._skill_tree_panel:child("respec_tree_button"):set_color(tweak_data.screen_colors.button_stage_3)
		end
	end

	if self._respec_text_id ~= text_id or force_text_update then
		self._respec_text_id = text_id

		self._skill_tree_panel:child("respec_tree_button"):set_text(prefix .. managers.localization:to_upper_text(text_id, macroes))
		self:make_fine_text(self._skill_tree_panel:child("respec_tree_button"))
	end

	return self._respec_highlight
end

function SkillTreeGui:mouse_moved(o, x, y)
	if self._renaming_skill_switch then
		return true, "link"
	end

	if not self._enabled then
		return
	end

	if self._spec_placing_points then
		return true, "grab"
	end

	local inside = false
	local pointer = "arrow"

	if self._is_skilltree_page_active and self._use_specialization then
		local specialization_text = self._panel:child("specialization_text")

		if specialization_text:inside(x, y) then
			if not self._specialization_text_highlighted then
				self._specialization_text_highlighted = true

				specialization_text:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end

			inside = true
			pointer = "link"
		elseif self._specialization_text_highlighted then
			self._specialization_text_highlighted = false

			specialization_text:set_color(tweak_data.screen_colors.button_stage_3)
		end
	elseif not self._is_skilltree_page_active and self._use_skilltree then
		local skilltree_text = self._panel:child("skilltree_text")

		if skilltree_text:inside(x, y) then
			if not self._skilltree_text_highlighted then
				self._skilltree_text_highlighted = true

				skilltree_text:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end

			inside = true
			pointer = "link"
		elseif self._skilltree_text_highlighted then
			self._skilltree_text_highlighted = false

			skilltree_text:set_color(tweak_data.screen_colors.button_stage_3)
		end
	end

	if self._is_skilltree_page_active and self._use_skilltree then
		if self:check_respec_button(x, y) then
			inside = true
			pointer = "link"
		elseif self:check_skill_switch_button(x, y) then
			inside = true
			pointer = "link"
		end

		if self._active_page then
			for _, item in ipairs(self._active_page._items) do
				if item:inside(x, y) then
					self:set_selected_item(item)

					inside = true
					pointer = "link"
				end
			end
		end

		for _, tab_item in ipairs(self._tab_items) do
			if tab_item:inside(x, y) then
				local same_tab_item = self._active_tree == tab_item:tree()

				self:set_selected_item(tab_item, true)

				inside = true
				pointer = same_tab_item and "arrow" or "link"
			end
		end
	elseif not self._is_skilltree_page_active and self._use_specialization then
		local inside2, pointer2 = self:moved_scroll_bar(x, y)

		if inside2 then
			return inside2, pointer2
		end

		if self._specialization_panel:child("spec_tabs_panel"):inside(x, y) then
			for _, tab_item in ipairs(self._spec_tab_items) do
				if tab_item:inside(x, y) then
					local same_tab_item = self._active_spec_tree == tab_item:tree()

					self:set_selected_item(tab_item, true)

					inside = true
					pointer = same_tab_item and "arrow" or "link"
				end
			end
		end

		for _, tab_item in ipairs(self._spec_tree_items) do
			local selected_item = tab_item:selected_item(x, y)

			if selected_item then
				self:set_hover_spec_item(selected_item)

				inside = true
				pointer = "link"

				break
			elseif tab_item:selected_btn(x, y) then
				inside = true
				pointer = "hand"

				break
			end
		end

		local update_select = false

		if not self._button_highlighted then
			update_select = true
		elseif self._btns[self._button_highlighted] and not self._btns[self._button_highlighted]:inside(x, y) then
			self._btns[self._button_highlighted]:set_highlight(false)

			self._button_highlighted = nil
			update_select = true
		end

		if update_select then
			for i, btn in pairs(self._btns) do
				if not self._button_highlighted and btn:visible() and btn:inside(x, y) then
					self._button_highlighted = i

					btn:set_highlight(true)
				else
					btn:set_highlight(false)
				end
			end
		end
	end

	if managers.menu:is_pc_controller() then
		if self._panel:child("back_button"):inside(x, y) then
			if not self._back_highlight then
				self._back_highlight = true

				self._panel:child("back_button"):set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end

			inside = true
			pointer = "link"
		elseif self._back_highlight then
			self._back_highlight = false

			self._panel:child("back_button"):set_color(tweak_data.screen_colors.button_stage_3)
		end
	end

	if not inside and self._panel:inside(x, y) then
		inside = true
		pointer = "arrow"
	end

	return inside, pointer
end

function SkillTreeGui:mouse_released(button, x, y)
	if not self._enabled then
		return
	end

	if self._spec_placing_points then
		self:stop_spec_place_points()
	end

	self:release_scroll_bar()

	if self._is_skilltree_page_active then
		-- Nothing
	end
end

function SkillTreeGui:mouse_pressed(button, x, y)
	if self._renaming_skill_switch then
		self:_stop_rename_skill_switch()

		return
	end

	if not self._enabled then
		return
	end

	if self._spec_placing_points then
		return
	end

	if button == Idstring("mouse wheel down") then
		if self._is_skilltree_page_active and self._use_skilltree then
			self:activate_next_tree_panel()
		elseif not self._is_skilltree_page_active and self._use_specialization then
			if self._spec_scroll_bar_panel:inside(x, y) or self._specialization_panel:child("spec_box_panel"):inside(x, y) then
				self:set_spec_scroll_indicators(self._specialization_scroll_y + 1)
			elseif self._specialization_panel:child("spec_tabs_panel"):inside(x, y) then
				self:activate_next_spec_panel()
			end
		end

		return
	elseif button == Idstring("mouse wheel up") then
		if self._is_skilltree_page_active and self._use_skilltree then
			self:activate_prev_tree_panel()
		elseif not self._is_skilltree_page_active and self._use_specialization then
			if self._spec_scroll_bar_panel:inside(x, y) or self._specialization_panel:child("spec_box_panel"):inside(x, y) then
				self:set_spec_scroll_indicators(self._specialization_scroll_y - 1)
			elseif self._specialization_panel:child("spec_tabs_panel"):inside(x, y) then
				self:activate_prev_spec_panel()
			end
		end

		return
	end

	if button == Idstring("0") then
		local specialization_text = self._panel:child("specialization_text")
		local skilltree_text = self._panel:child("skilltree_text")
		local title_bg = self._fullscreen_panel:child("title_bg")

		if self._is_skilltree_page_active and self._use_specialization then
			if specialization_text:inside(x, y) then
				self:set_skilltree_page_active(false)

				return
			end
		elseif not self._is_skilltree_page_active and self._use_skilltree and skilltree_text:inside(x, y) then
			self:set_skilltree_page_active(true)

			return
		end

		if self._panel:child("back_button"):inside(x, y) then
			managers.menu:back()

			return
		end

		if self._is_skilltree_page_active and self._use_skilltree then
			if self._skill_tree_panel:child("respec_tree_button"):inside(x, y) then
				self:respec_active_tree()

				return
			end

			if self._skill_tree_panel:child("switch_skills_button"):inside(x, y) then
				managers.menu:open_node("skill_switch", {})

				return
			end

			if self._skill_tree_panel:child("skill_set_bg"):inside(x, y) then
				self:_start_rename_skill_switch()

				return
			end

			if self._active_page then
				for _, item in ipairs(self._active_page._items) do
					if item:inside(x, y) then
						self:place_point(item)

						return true
					end
				end
			end

			for _, tab_item in ipairs(self._tab_items) do
				if tab_item:inside(x, y) then
					if self._active_tree ~= tab_item:tree() then
						self:set_active_page(tab_item:tree(), true)
					end

					return true
				end
			end
		elseif not self._is_skilltree_page_active and self._use_specialization then
			if self._specialization_panel:child("spec_tabs_panel"):inside(x, y) then
				for _, tab_item in ipairs(self._spec_tab_items) do
					if tab_item:inside(x, y) then
						if self._active_spec_tree ~= tab_item:tree() then
							self:set_active_page(tab_item:tree(), true)
						end

						return true
					end
				end
			end

			for _, tree_item in ipairs(self._spec_tree_items) do
				local selected_item = tree_item:selected_item(x, y)

				if selected_item then
					self:set_active_page(selected_item:tree(), true)

					return true
				else
					local count_dir = tree_item:selected_btn(x, y)

					if count_dir then
						self:start_spec_place_points(count_dir, tree_item:tree())

						return
					end
				end
			end

			if self:check_spec_grab_scroll_bar(x, y) then
				return
			end

			if self._spec_scroll_bar_panel:child("scroll_up_indicator_arrow"):inside(x, y) then
				self:set_spec_scroll_indicators(self._specialization_scroll_y - 1)

				return
			elseif self._spec_scroll_bar_panel:child("scroll_down_indicator_arrow"):inside(x, y) then
				self:set_spec_scroll_indicators(self._specialization_scroll_y + 1)

				return
			end

			if self._button_highlighted and self._btns[self._button_highlighted] and self._btns[self._button_highlighted]:inside(x, y) then
				local data = self._btns[self._button_highlighted]:data()

				if data.callback and (not self._button_press_delay or self._button_press_delay < TimerManager:main():time()) then
					managers.menu_component:post_event("menu_enter")
					data.callback(self._active_spec_tree, self._selected_spec_tier)

					self._button_press_delay = TimerManager:main():time() + 0.2
				end
			end
		end
	end
end

function SkillTreeGui:move_spec_item(x, y)
	local tree_item = self._spec_tree_items[self._active_spec_tree]
	local prev_tier = self._selected_spec_tier
	local prev_tree = self._active_spec_tree
	local current_tier = self._selected_spec_tier
	local current_tree = self._active_spec_tree

	if self._selected_spec_tier then
		if self._selected_spec_item then
			current_tree = self._selected_spec_item:tree() or current_tree
		end

		current_tree = math.clamp(current_tree + y, 1, #self._spec_tree_items)

		self:set_active_page(current_tree, false)

		local tree_item = self._spec_tree_items[self._active_spec_tree]
		local next_tier = math.clamp(current_tier + x, 1, managers.skilltree:get_specialization_value(self._active_spec_tree, "tiers", "max_tier"))

		self:set_selected_item(tree_item:item(next_tier), true)
	else
		current_tier = managers.skilltree:get_specialization_value(self._active_spec_tree, "tiers", "current_tier") + 1
		local next_tier = math.clamp(current_tier, 1, managers.skilltree:get_specialization_value(self._active_spec_tree, "tiers", "max_tier"))

		self:set_selected_item(tree_item:item(next_tier), true)
	end

	if prev_tier ~= self._selected_spec_tier or prev_tree ~= self._active_spec_tree then
		managers.menu_component:post_event("highlight")
	end
end

function SkillTreeGui:move_up()
	if not self._enabled then
		return
	end

	if self._spec_placing_points then
		return
	end

	if self._is_skilltree_page_active and self._use_skilltree then
		if not self._selected_item and self._active_page then
			self:set_selected_item(self._active_page:item())
		elseif self._selected_item and self._selected_item._up_item then
			self:set_selected_item(self._selected_item._up_item)
		end
	elseif not self._is_skilltree_page_active and self._use_specialization then
		self:move_spec_item(0, -1)
	end
end

function SkillTreeGui:move_down()
	if not self._enabled then
		return
	end

	if self._spec_placing_points then
		return
	end

	if self._is_skilltree_page_active and self._use_skilltree then
		if not self._selected_item and self._active_page then
			self:set_selected_item(self._active_page:item())
		elseif self._selected_item and self._selected_item._down_item then
			self:set_selected_item(self._selected_item._down_item)
		end
	elseif not self._is_skilltree_page_active and self._use_specialization then
		self:move_spec_item(0, 1)
	end
end

function SkillTreeGui:move_left()
	if not self._enabled then
		return
	end

	if self._spec_placing_points then
		return
	end

	if self._is_skilltree_page_active and self._use_skilltree then
		if not self._selected_item and self._active_page then
			self:set_selected_item(self._active_page:item())
		elseif self._selected_item and self._selected_item._left_item then
			self:set_selected_item(self._selected_item._left_item)
		end
	elseif not self._is_skilltree_page_active and self._use_specialization then
		self:move_spec_item(-1, 0)
	end
end

function SkillTreeGui:move_right()
	if not self._enabled then
		return
	end

	if self._spec_placing_points then
		return
	end

	if self._is_skilltree_page_active and self._use_skilltree then
		if not self._selected_item and self._active_page then
			self:set_selected_item(self._active_page:item())
		elseif self._selected_item and self._selected_item._right_item then
			self:set_selected_item(self._selected_item._right_item)
		end
	elseif not self._is_skilltree_page_active and self._use_specialization then
		self:move_spec_item(1, 0)
	end
end

function SkillTreeGui:next_page(play_sound)
	if not self._enabled then
		return
	end

	if self._spec_placing_points then
		return
	end

	if self._is_skilltree_page_active and self._use_skilltree then
		if self:activate_next_tree_panel(play_sound) then
			self:set_selected_item(self._active_page:item(), true)
		end
	elseif not self._is_skilltree_page_active and self._use_specialization and self:activate_next_spec_panel(play_sound) then
		self:set_selected_item(self._spec_tab_items[self._active_spec_tree], true)
	end
end

function SkillTreeGui:previous_page(play_sound)
	if not self._enabled then
		return
	end

	if self._spec_placing_points then
		return
	end

	if self._is_skilltree_page_active and self._use_skilltree then
		if self:activate_prev_tree_panel(play_sound) then
			self:set_selected_item(self._active_page:item(), true)
		end
	elseif not self._is_skilltree_page_active and self._use_specialization and self:activate_prev_spec_panel(play_sound) then
		self:set_selected_item(self._spec_tab_items[self._active_spec_tree], true)
	end
end

function SkillTreeGui:confirm_pressed()
	if self._renaming_skill_switch then
		self:_stop_rename_skill_switch()

		return
	end

	if not self._enabled then
		return
	end

	if self._is_skilltree_page_active and self._use_skilltree and self._selected_item and self._selected_item._skill_panel then
		self:place_point(self._selected_item)

		return true
	end

	return false
end

function SkillTreeGui:special_btn_pressed(button)
	if not self._enabled then
		return
	end

	if self._spec_placing_points then
		return
	end

	if button == Idstring("trigger_left") and not self._is_skilltree_page_active and self._use_skilltree then
		self:set_skilltree_page_active(true)
		managers.menu_component:post_event("highlight")

		return true
	elseif button == Idstring("trigger_right") and self._is_skilltree_page_active and self._use_specialization then
		self:set_skilltree_page_active(false)
		managers.menu_component:post_event("highlight")

		return true
	end

	if self._is_skilltree_page_active and self._use_skilltree then
		if button == Idstring("menu_respec_tree") then
			self:respec_active_tree()

			return true
		elseif button == Idstring("menu_switch_skillset") then
			managers.menu:open_node("skill_switch", {})

			return
		end
	elseif not self._is_skilltree_page_active and self._use_specialization then
		return self:press_pc_button(button)
	end

	return false
end

function SkillTreeGui:set_skilltree_page_active(active)
	if self._is_skilltree_page_active ~= active then
		local specialization_text = self._panel:child("specialization_text")
		local skilltree_text = self._panel:child("skilltree_text")
		local title_bg = self._fullscreen_panel:child("title_bg")
		self._is_skilltree_page_active = active

		skilltree_text:set_color(active and tweak_data.screen_colors.text or tweak_data.screen_colors.button_stage_3)
		specialization_text:set_color(active and tweak_data.screen_colors.button_stage_3 or tweak_data.screen_colors.text)
		title_bg:set_text((active and skilltree_text or specialization_text):text())

		local wx = (active and skilltree_text or specialization_text):world_x()
		local wy = (active and skilltree_text or specialization_text):world_center_y()
		local x, y = managers.gui_data:safe_to_full_16_9(wx, wy)

		title_bg:set_world_left(x)
		title_bg:set_world_center_y(y)
		title_bg:move(-13, 9)
		self._skill_tree_panel:set_visible(active)
		self._specialization_panel:set_visible(not active)
		self._skill_tree_fullscreen_panel:set_visible(active)
		self._specialization_fullscreen_panel:set_visible(not active)

		self._skilltree_text_highlighted = active
		self._specialization_text_highlighted = not active

		if self._is_skilltree_page_active then
			self:set_selected_item(self._active_page:item(), true)
		else
			self:_set_active_spec_tree(managers.skilltree:get_specialization_value("current_specialization"))

			local current_tier = managers.skilltree:get_specialization_value(self._active_spec_tree, "tiers", "current_tier") + 1
			local next_tier = math.clamp(current_tier, 1, managers.skilltree:get_specialization_value(self._active_spec_tree, "tiers", "max_tier"))

			self:set_selected_item(self._spec_tree_items[self._active_spec_tree]:item(next_tier), true)
		end

		if not active then
			self:_chk_specialization_present()
		end
	end
end

function SkillTreeGui:_chk_specialization_present()
	local xp_present, points_present = managers.skilltree:get_specialization_present()

	if xp_present and points_present then
		managers.menu:show_specialization_xp_convert(xp_present, points_present)
		print(xp_present, points_present)
	end
end

function SkillTreeGui:flash_item(item)
	item:flash()
	managers.menu_component:post_event("menu_error")
end

function SkillTreeGui:place_point(item)
	local tree = item:tree()
	local tier = item:tier()
	local skill_id = item:skill_id()

	if tier and not managers.skilltree:tree_unlocked(tree) then
		self:flash_item(item)

		return
	end

	if managers.skilltree:skill_completed(skill_id) then
		return
	end

	if not tier and managers.skilltree:tree_unlocked(tree) then
		return
	end

	local params = {}
	local to_unlock = managers.skilltree:next_skill_step(skill_id)
	local talent = tweak_data.skilltree.skills[skill_id]
	local skill = talent[to_unlock]
	local points = managers.skilltree:get_skill_points(skill_id, to_unlock) or 0
	local point_cost = managers.money:get_skillpoint_cost(tree, tier, points)
	local prerequisites = talent.prerequisites or {}

	for _, prerequisite in ipairs(prerequisites) do
		local unlocked = managers.skilltree:skill_step(prerequisite)

		if unlocked and unlocked == 0 then
			self:flash_item(item)

			return
		end
	end

	if not managers.money:can_afford_spend_skillpoint(tree, tier, points) then
		self:flash_item(item)

		return
	end

	if tier then
		if managers.skilltree:points() < points then
			self:flash_item(item)

			return
		end

		if managers.skilltree:tier_unlocked(tree, tier) then
			params.skill_name_localized = item._skill_name
			params.points = points
			params.cost = point_cost
			params.remaining_points = managers.skilltree:points()
			params.text_string = "dialog_allocate_skillpoint"
		end
	elseif points <= managers.skilltree:points() then
		params.skill_name_localized = item._skill_name
		params.points = points
		params.cost = point_cost
		params.remaining_points = managers.skilltree:points()
		params.text_string = "dialog_unlock_skilltree"
	end

	if params.text_string then
		params.yes_func = callback(self, self, "_dialog_confirm_yes", item)
		params.no_func = callback(self, self, "_dialog_confirm_no")

		managers.menu:show_confirm_skillpoints(params)
	else
		self:flash_item(item)
	end
end

function SkillTreeGui:_dialog_confirm_yes(item)
	if item and alive(item._skill_panel) then
		local skill_refresh_skills = item:trigger() or {}

		SimpleGUIEffectSpewer.skill_up(item._skill_panel:child("state_image"):center_x(), item._skill_panel:child("state_image"):center_y(), item._skill_panel)
		managers.menu_component:post_event("menu_skill_investment")

		for _, id in ipairs(skill_refresh_skills) do
			for _, item in ipairs(self._active_page._items) do
				if item._skill_id == id then
					item:refresh()

					break
				end
			end
		end
	end
end

function SkillTreeGui:_dialog_confirm_no(item)
end

function SkillTreeGui:on_tier_unlocked(tree, tier)
	self._pages[tree]:unlock_tier(tier)
end

function SkillTreeGui:on_skill_unlocked(tree, skill_id)
end

function SkillTreeGui:on_points_spent()
	local points_text = self._skill_tree_panel:child("points_text")

	points_text:set_text(utf8.to_upper(managers.localization:text("st_menu_available_skill_points", {
		points = managers.skilltree:points()
	})))

	local respec_cost_text = self._skill_tree_panel:child("respec_cost_text")

	if alive(respec_cost_text) then
		respec_cost_text:set_text(managers.localization:text("st_menu_respec_cost", {
			cost = managers.experience:cash_string(managers.money:get_skilltree_tree_respec_cost(self._active_tree))
		}))
		self:make_fine_text(respec_cost_text)
		respec_cost_text:set_bottom(self._skill_tree_panel:child("money_text"):top())
	end

	self._active_page:on_points_spent()
	self:check_respec_button(nil, nil, true)
	self:set_selected_item(self._selected_item, true)
	WalletGuiObject.refresh()
end

function SkillTreeGui:respec_active_tree()
	if not managers.money:can_afford_respec_skilltree(self._active_tree) or managers.skilltree:points_spent(self._active_tree) == 0 then
		return
	end

	self:respec_tree(self._active_tree)
end

function SkillTreeGui:respec_tree(tree)
	local params = {
		tree = tree,
		yes_func = callback(self, self, "_dialog_respec_yes", tree),
		no_func = callback(self, self, "_dialog_respec_no")
	}

	managers.menu:show_confirm_respec_skilltree(params)
end

function SkillTreeGui:_dialog_respec_yes(tree)
	SkillTreeGui._respec_tree(self, tree)
end

function SkillTreeGui:_dialog_respec_no()
end

function SkillTreeGui:_respec_tree(tree)
	managers.skilltree:on_respec_tree(tree)
	self:on_skilltree_reset(tree)
end

function SkillTreeGui:on_skilltree_reset(tree)
	self:_pre_reload()
	SkillTreeGui.init(self, self._ws, self._fullscreen_ws, self._node)
	self:_post_reload()
	self:set_active_page(tree or managers.skilltree:get_most_progressed_tree())
	self:set_selected_item(self._active_page:item(), true)
end

function SkillTreeGui:_pre_reload()
	self._temp_panel = self._panel
	self._temp_fullscreen_panel = self._fullscreen_panel
	self._panel = nil
	self._fullscreen_panel = nil

	self._temp_panel:hide()
	self._temp_fullscreen_panel:hide()
end

function SkillTreeGui:_post_reload()
	self._ws:panel():remove(self._temp_panel)
	self._fullscreen_ws:panel():remove(self._temp_fullscreen_panel)
end

function SkillTreeGui:input_focus()
	if self._one_frame_input_delay then
		self._one_frame_input_delay = nil

		return true
	end

	return self._enabled and 1 or self._renaming_skill_switch and true
end

function SkillTreeGui:visible()
	return self._visible
end

function SkillTreeGui:is_enabled()
	return self._enabled
end

function SkillTreeGui:enable()
	self._enabled = true

	if alive(self._disabled_panel) then
		self._fullscreen_ws:panel():remove(self._disabled_panel)

		self._disabled_panel = nil
	end
end

function SkillTreeGui:disable()
	self._enabled = false

	if alive(self._disabled_panel) then
		self._fullscreen_ws:panel():remove(self._disabled_panel)

		self._disabled_panel = nil
	end

	self._disabled_panel = self._fullscreen_ws:panel():panel({
		layer = 50
	})

	self._disabled_panel:rect({
		name = "bg",
		alpha = 0.4,
		color = Color.black
	})
	self._disabled_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur",
		render_template = "VertexColorTexturedBlur3D",
		layer = -1,
		w = self._disabled_panel:w(),
		h = self._disabled_panel:h()
	})
end

function SkillTreeGui:close()
	managers.menu:active_menu().renderer.ws:show()
	self:_cancel_rename_skill_switch()

	if self._spec_placing_points then
		self._spec_placing_points = nil
		self._spec_placing_tree = nil

		managers.menu_component:post_event("count_1_finished")
	end

	if alive(self._disabled_panel) then
		self._fullscreen_ws:panel():remove(self._disabled_panel)

		self._disabled_panel = nil
	end

	WalletGuiObject.close_wallet(self._panel)
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size

function SkillTreeGui:mouse_clicked(o, button, x, y)
	if self._is_skilltree_page_active then
		return
	end

	self._mouse_click_index = ((self._mouse_click_index or 0) + 1) % 2
	self._mouse_click = self._mouse_click or {}
	self._mouse_click[self._mouse_click_index] = {
		button = button,
		x = x,
		y = y,
		selected_tree = self._active_spec_tree
	}

	self:set_selected_item(self._hover_spec_item, true)
end

function SkillTreeGui:mouse_double_click(o, button, x, y)
	if self._is_skilltree_page_active then
		return
	end

	if not self._mouse_click or not self._mouse_click[0] or not self._mouse_click[1] then
		return
	end

	if self._mouse_click[0].selected_tree ~= self._mouse_click[1].selected_tree then
		return
	end

	if not self._mouse_click[1].selected_tree or not self._spec_tree_items[self._mouse_click[1].selected_tree]:panel():inside(x, y) then
		return
	end

	if managers.system_menu and managers.system_menu:is_active() and not managers.system_menu:is_closing() then
		return
	end

	self:press_first_btn(button)
end

function SkillTreeGui:press_first_btn(button)
	local first_btn_callback = nil
	local first_btn_prio = 999
	local first_btn_visible = false

	if button == Idstring("0") then
		for _, btn in pairs(self._btns) do
			if btn:visible() and btn._data.prio < first_btn_prio then
				first_btn_prio = btn._data.prio
				first_btn_callback = btn._data.callback
				first_btn_visible = btn:visible()
			end

			if btn:visible() and btn._data.prio == first_btn_prio then
				first_btn_prio = btn._data.prio
				first_btn_callback = btn._data.callback
				first_btn_visible = btn:visible()
			end
		end
	end

	if first_btn_visible and first_btn_callback then
		managers.menu_component:post_event("menu_enter")
		first_btn_callback(self._active_spec_tree, self._selected_spec_tier)

		return true
	end

	return false
end

function SkillTreeGui:update(t, dt)
	if not self._enabled then
		return
	end

	if not managers.menu:is_pc_controller() or managers.menu:is_steam_controller() then
		local controller_spec_adding_points, controller_spec_removing_points = nil

		if self._selected_spec_tier == managers.skilltree:get_specialization_value(self._active_spec_tree, "tiers", "current_tier") + 1 then
			controller_spec_adding_points = not self._is_skilltree_page_active and managers.menu_component:get_controller_input_bool("upgrade_alternative1")
			controller_spec_removing_points = not controller_spec_adding_points and not self._is_skilltree_page_active and managers.menu_component:get_controller_input_bool("upgrade_alternative4")
		end

		if self._controller_spec_adding_points ~= controller_spec_adding_points then
			if not controller_spec_adding_points then
				self:stop_spec_place_points()
			elseif self._controller_spec_removing_points then
				self:stop_spec_place_points()
			else
				self:start_spec_place_points(1, self._active_spec_tree)
			end
		elseif self._controller_spec_removing_points ~= controller_spec_removing_points then
			if not controller_spec_removing_points then
				self:stop_spec_place_points()
			else
				self:start_spec_place_points(-1, self._active_spec_tree)
			end
		end

		self._controller_spec_adding_points = controller_spec_adding_points
		self._controller_spec_removing_points = controller_spec_removing_points
	end

	if self._spec_placing_points then
		if self._spec_placing_points == 0 or not self._spec_placing_tree then
			return self:stop_spec_place_points()
		end

		local points_placed = self._spec_placing_points
		local tree = self._spec_placing_tree
		local current_tier = managers.skilltree:get_specialization_value(tree, "tiers", "current_tier")
		local max_tier = managers.skilltree:get_specialization_value(tree, "tiers", "max_tier")

		if current_tier == max_tier then
			return self:stop_spec_place_points()
		end

		local current_points = managers.skilltree:get_specialization_value(tree, "tiers", "next_tier_data", "current_points")
		local points = managers.skilltree:get_specialization_value(tree, "tiers", "next_tier_data", "points")
		local diff = points - current_points
		local points_to_spend = managers.skilltree:get_specialization_value("points")
		local dir = self._spec_placing_points / math.abs(self._spec_placing_points)
		local speed = math.clamp(points / 10, 150, 1000) + math.abs(self._spec_placing_points) * 0.5
		self._spec_placing_points = self._spec_placing_points + dt * dir * speed
		self._spec_placing_points = math.clamp(self._spec_placing_points, -current_points, math.min(diff, points_to_spend))

		self._spec_tree_items[tree]:update_progress(false, current_points + math.round(self._spec_placing_points), false)

		local progress_string = managers.localization:to_upper_text("menu_st_progress", {
			progress = string.format("%i/%i", current_points + math.round(self._spec_placing_points), points)
		})

		self._spec_description_progress:set_text(progress_string)

		if points_placed == self._spec_placing_points then
			self:stop_spec_place_points()
		else
			self:refresh_spec_points()
		end
	end
end

function SkillTreeGui:start_spec_place_points(dir, tree)
	local tree_item = self._spec_tree_items[tree]

	if not tree_item then
		return
	end

	local item = tree_item:place_points_item()

	if not item then
		return
	end

	local dlc = tweak_data:get_raw_value("skilltree", "specializations", tree, "dlc")

	if dlc and not managers.dlc:is_dlc_unlocked(dlc) then
		return
	end

	self._spec_placing_points = math.sign(dir)
	self._spec_placing_tree = tree

	self:set_active_page(tree, true)
	self:set_selected_item(item, true)
	managers.menu_component:post_event("count_1")
end

function SkillTreeGui:stop_spec_place_points()
	if not self._spec_placing_points then
		return
	end

	if self._spec_placing_points > 0 then
		managers.skilltree:spend_specialization_points(math.abs(self._spec_placing_points), self._spec_placing_tree)
	elseif self._spec_placing_points < 0 then
		managers.skilltree:refund_specialization_points(math.abs(self._spec_placing_points), self._spec_placing_tree)
	end

	self._spec_placing_points = nil
	self._spec_placing_tree = nil

	managers.menu_component:post_event("count_1_finished")
	self:update_spec_descriptions()

	for _, tree_item in ipairs(self._spec_tree_items) do
		tree_item:refresh()

		for _, item in ipairs(tree_item:items()) do
			item:refresh()
		end
	end

	WalletGuiObject.refresh()
	self:refresh_spec_points()
end

function SkillTreeGui:refresh_spec_points()
	local points_text = self._specialization_panel:child("points_text")
	local spec_box_panel = self._specialization_panel:child("spec_box_panel")

	points_text:set_text(managers.localization:to_upper_text("menu_st_available_spec_points", {
		points = managers.money:add_decimal_marks_to_string(tostring(managers.skilltree:specialization_points()))
	}))
	make_fine_text(points_text)
	points_text:set_right(spec_box_panel:right())
	points_text:set_top(spec_box_panel:bottom() + 20)
	points_text:set_position(math.round(points_text:x()), math.round(points_text:y()))
end

function SkillTreeGui:refresh_btns()
	local btns = {}
	local item = self._selected_spec_item

	if not item or not item.tree then
		return
	end

	local tree = item:tree()
	local dlc = tweak_data:get_raw_value("skilltree", "specializations", tree, "dlc")

	if not dlc or managers.dlc:is_dlc_unlocked(dlc) then
		if tree ~= managers.skilltree:get_specialization_value("current_specialization") then
			table.insert(btns, "activate_spec")
		end

		local current_tier = managers.skilltree:get_specialization_value(tree, "tiers", "current_tier")
		local max_tier = managers.skilltree:get_specialization_value(tree, "tiers", "max_tier")

		if current_tier < max_tier then
			local next_points = managers.skilltree:get_specialization_value(tree, "tiers", "next_tier_data", "current_points")
			local next_tier_cost = managers.skilltree:get_specialization_value(tree, "tiers", "next_tier_data", "points")
			local points_to_spend = managers.skilltree:get_specialization_value("points")

			if points_to_spend >= next_tier_cost - next_points then
				table.insert(btns, "max_points")
			end
		end

		if (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and item.tier and item:tier() == current_tier + 1 then
			table.insert(btns, "add_points")
			table.insert(btns, "remove_points")
		end
	end

	self:show_btns(unpack(btns))
end

function SkillTreeGui:show_btns(...)
	local data = {
		...
	}

	for _, btn in pairs(self._btns) do
		btn:hide()
	end

	local btns = {}

	for i, btn in ipairs(data) do
		if self._btns[btn] then
			self._btns[btn]:show()
			table.insert(btns, self._btns[btn])
		end
	end

	if not managers.menu:is_pc_controller() or managers.menu:is_steam_controller() then
		local back_btn = self._btns.back_btn

		if back_btn then
			back_btn:show()
			table.insert(btns, back_btn)
		end
	end

	self._button_count = #btns

	table.sort(btns, function (x, y)
		return x:data().prio < y:data().prio
	end)

	self._controllers_mapping = {}
	self._controllers_pc_mapping = {}

	for i, btn in ipairs(btns) do
		if (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and not btn:data().no_btn then
			btn:set_text_btn_prefix(btn:data().btn)
		end

		if btn:data().pc_btn then
			self._controllers_pc_mapping[Idstring(btn:data().pc_btn):key()] = btn
		end

		self._controllers_mapping[btn:data().btn:key()] = btn

		btn:set_text_params(data.btn_text_params)
		btn:set_order(i)
	end

	self:_update_borders()
end

function SkillTreeGui:press_pc_button(button)
	if not self._enabled then
		return
	end

	local btn = self._controllers_pc_mapping and self._controllers_pc_mapping[button:key()]

	if btn and btn:data() and btn:data().callback and (not self._button_press_delay or self._button_press_delay < TimerManager:main():time()) then
		managers.menu_component:post_event("menu_enter")
		btn:data().callback(self._active_spec_tree, self._selected_spec_tier)

		self._button_press_delay = TimerManager:main():time() + 0.2

		return true
	end

	return false
end

function SkillTreeGui:_update_borders()
	local spec_box_panel = self._specialization_panel:child("spec_box_panel")
	local desc_box_panel = self._specialization_panel:child("desc_box_panel")
	local desc_h = desc_box_panel:h()
	local btn_h = self._btn_panel:h()
	local btn_y = self._btn_panel:y()

	if self._button_count > 0 then
		self._btn_panel:set_visible(true)
		self._btn_panel:set_h(20 * self._button_count + 20)
		self._btn_panel:set_bottom(spec_box_panel:bottom())
		desc_box_panel:grow(0, self._btn_panel:top() - desc_box_panel:bottom() - 10)

		if desc_h ~= desc_box_panel:h() then
			self._desc_box:create_sides(desc_box_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		end

		if btn_h ~= self._btn_panel:h() or btn_y ~= self._btn_panel:y() then
			self._button_border:create_sides(self._btn_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		end
	else
		self._btn_panel:set_visible(false)
		desc_box_panel:set_h(spec_box_panel:h())

		if desc_h ~= desc_box_panel:h() then
			self._desc_box:create_sides(desc_box_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		end
	end
end

function SkillTreeGui:activate_specialization(tree, tier)
	if tree then
		managers.skilltree:set_current_specialization(tree)
		self:refresh_btns()

		for tree, item in ipairs(self._spec_tab_items) do
			item:refresh()
		end

		for tree, item in ipairs(self._spec_tree_items) do
			item:refresh()
		end
	end
end

function SkillTreeGui:max_specialization(tree, tier)
	if tree then
		local current_tier = managers.skilltree:get_specialization_value(tree, "tiers", "current_tier")
		local max_tier = managers.skilltree:get_specialization_value(tree, "tiers", "max_tier")

		if current_tier == max_tier then
			return
		end

		local next_points = managers.skilltree:get_specialization_value(tree, "tiers", "next_tier_data", "current_points")
		local next_tier_cost = managers.skilltree:get_specialization_value(tree, "tiers", "next_tier_data", "points")
		local total_cost = 0
		local next_cost = next_tier_cost - next_points
		local points_to_spend = managers.skilltree:get_specialization_value("points")
		local afford_tier = current_tier

		while points_to_spend >= total_cost + next_cost and afford_tier < max_tier do
			total_cost = total_cost + next_cost
			afford_tier = afford_tier + 1
			next_cost = max_tier > afford_tier and tweak_data.skilltree.specializations[tree][afford_tier + 1].cost or 0
		end

		local deck_name = managers.localization:text(tweak_data.skilltree.specializations[tree].name_id)
		local dialog_data = {
			title = managers.localization:text("st_menu_max_perk_dialog_title"),
			text = managers.localization:text("st_menu_max_perk_dialog_text", {
				perk_deck_name = deck_name,
				point_cost = total_cost,
				perk_tier = afford_tier,
				num_tiers = afford_tier - current_tier,
				max_tier = max_tier,
				current_tier = current_tier
			}),
			focus_button = 2,
			button_list = {
				{
					text = managers.localization:text("dialog_yes"),
					callback_func = callback(self, self, "_actually_max_specialization", {
						total_cost,
						tree
					})
				},
				{
					cancel_button = true,
					text = managers.localization:text("dialog_no")
				}
			}
		}

		managers.system_menu:show(dialog_data)
	end
end

function SkillTreeGui:_actually_max_specialization(params)
	local total_cost, tree = unpack(params)

	managers.skilltree:spend_specialization_points(total_cost, tree)
	self:refresh_spec_points()

	for _, tree_item in ipairs(self._spec_tree_items) do
		tree_item:refresh()

		for _, item in ipairs(tree_item:items()) do
			item:refresh()
		end
	end
end

SpecializationItem = SpecializationItem or class()

function SpecializationItem:init()
end

function SpecializationItem:refresh()
end

function SpecializationItem:inside()
end

function SpecializationItem:select(no_sound)
	if not self._selected then
		self._selected = true

		self:refresh()
	end

	if not no_sound then
		managers.menu_component:post_event("highlight")
	end
end

function SpecializationItem:deselect()
	if self._selected then
		self._selected = false

		self:refresh()
	end
end

function SpecializationItem:trigger()
	self:refresh()
end

function SpecializationItem:flash()
end

SpecializationTabItem = SpecializationTabItem or class(SpecializationItem)

function SpecializationTabItem:init(spec_tabs_panel, tree, data, w, x)
	SpecializationTabItem.super.init(self)

	self._data = data
	self._tree = tree
	self._spec_tab = spec_tabs_panel:panel({
		name = tostring(tree),
		w = w,
		x = x
	})
	self._name_string = data.name_id and managers.localization:text(data.name_id) or "NO_NAME_" .. tostring(tree)
	self._desc_string = data.desc_id and managers.localization:text(data.desc_id) or "NO_DESC_" .. tostring(tree)

	if data and data.dlc and tweak_data.lootdrop.global_values[data.dlc] then
		self._desc_string = self._desc_string .. "\n\n" .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[data.dlc].desc_id) .. "##"
		self._desc_custom_color = tweak_data.lootdrop.global_values[data.dlc].color
	end

	self._spec_tab:text({
		word_wrap = false,
		name = "spec_tab_name",
		vertical = "center",
		wrap = false,
		align = "center",
		layer = 1,
		text = utf8.to_upper(self._name_string),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})

	local _, _, tw, th = self._spec_tab:child("spec_tab_name"):text_rect()

	self._spec_tab:set_size(tw + 15, th + 10)
	self._spec_tab:child("spec_tab_name"):set_size(self._spec_tab:size())
	self._spec_tab:bitmap({
		texture = "guis/textures/pd2/shared_tab_box",
		name = "spec_tab_select_rect",
		visible = false,
		layer = 0,
		w = self._spec_tab:w(),
		h = self._spec_tab:h(),
		color = tweak_data.screen_colors.text
	})
	self._spec_tab:move(0, 0)
end

function SpecializationTabItem:set_active(active)
	self._active = active

	self:refresh()
end

function SpecializationTabItem:name_string()
	return self._name_string
end

function SpecializationTabItem:desc_string()
	return self._desc_string
end

function SpecializationTabItem:desc_custom_color()
	return self._desc_custom_color
end

function SpecializationTabItem:tree()
	return self._tree
end

function SpecializationTabItem:data()
	return self._data
end

function SpecializationTabItem:inside(x, y)
	return self._spec_tab:inside(x, y)
end

function SpecializationTabItem:refresh()
	if not alive(self._spec_tab) then
		return
	end

	if self._active then
		self._spec_tab:child("spec_tab_select_rect"):show()
		self._spec_tab:child("spec_tab_name"):set_color(tweak_data.screen_colors.button_stage_1)
		self._spec_tab:child("spec_tab_name"):set_blend_mode("normal")
	elseif self._selected then
		self._spec_tab:child("spec_tab_select_rect"):hide()
		self._spec_tab:child("spec_tab_name"):set_color(tweak_data.screen_colors.button_stage_2)
		self._spec_tab:child("spec_tab_name"):set_blend_mode("add")
	else
		self._spec_tab:child("spec_tab_select_rect"):hide()
		self._spec_tab:child("spec_tab_name"):set_color(tweak_data.screen_colors.button_stage_3)
		self._spec_tab:child("spec_tab_name"):set_blend_mode("add")
	end
end

SpecializationTreeItem = SpecializationTreeItem or class()

function SpecializationTreeItem:init(tree, parent_panel, tab_iem)
	self._items = {}
	self._parent_panel = parent_panel
	self._tree = tree
	self._tab_item = tab_iem
	local tree_panel = parent_panel:panel({
		alpha = 1,
		visible = true,
		name = tostring(tree)
	})
	self._tree_panel = tree_panel
	local max_tier = managers.skilltree:get_specialization_value(tree, "tiers", "max_tier")
	local num_trees_per_page = NUM_TREES_PER_PAGE
	local parent_h = parent_panel:h() - 24
	local x = 0
	local y = 0
	local w = math.round(1 / max_tier * tree_panel:w())
	local h = math.round(parent_h / num_trees_per_page)
	local size = math.min(w, h)
	h = math.round((parent_h - size) / (num_trees_per_page - 1))

	tree_panel:set_h(size)
	tree_panel:set_y(h * (tree - 1) + 24)

	if num_trees_per_page <= tree then
		tree_panel:move(0, -1)
	end

	local data = tweak_data.skilltree.specializations[tree]
	self._data = data
	local new_item = nil

	for tier, tier_data in ipairs(data) do
		x = math.round(w * (tier - 1) + (w - size) / 2 + 1)
		new_item = SpecializationTierItem:new(tier_data, tree_panel, tree, tier, x, y, size, size)

		table.insert(self._items, new_item)
	end

	local active_text = parent_panel:text({
		alpha = 0,
		blend_mode = "add",
		visible = true,
		x = 4,
		name = "active_text" .. tostring(self._tree),
		text = managers.localization:to_upper_text("menu_st_active_spec", {
			specialization = tab_iem:name_string()
		}),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(active_text)
	active_text:set_left(tree_panel:left() + 4)
	active_text:set_bottom(tree_panel:top() + 3)

	local selected_text = parent_panel:text({
		alpha = 0,
		blend_mode = "add",
		visible = true,
		x = 4,
		name = "selected_text" .. tostring(self._tree),
		text = utf8.to_upper(tab_iem:name_string()),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(selected_text)
	selected_text:set_left(tree_panel:left() + 4)
	selected_text:set_bottom(tree_panel:top() + 3)

	self._active_box_panel = parent_panel:panel({
		visible = false,
		name = "active_box_panel" .. tostring(self._tree)
	})

	self._active_box_panel:set_shape(tree_panel:shape())

	self._active_box = BoxGuiObject:new(self._active_box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self._active_rect = self._active_box_panel:rect({
		alpha = 0.5,
		layer = -1,
		color = Color.black
	})
	local point_btns_panel = parent_panel:panel({
		alpha = 0,
		visible = true,
		name = "point_btns_panel" .. tostring(self._tree)
	})
	local reduce_points = point_btns_panel:bitmap({
		texture = "guis/textures/pd2/specialization/points_reduce",
		name = "reduce_points",
		h = 16,
		visible = true,
		w = 16,
		blend_mode = "add",
		rotation = 360,
		layer = 0
	})
	local increase_points = point_btns_panel:bitmap({
		texture = "guis/textures/pd2/specialization/points_add",
		name = "increase_points",
		h = 16,
		rotation = 360,
		w = 16,
		blend_mode = "add",
		visible = true,
		x = 20,
		layer = 0
	})

	point_btns_panel:set_size(36, 16)
	point_btns_panel:set_top(tree_panel:bottom())

	local current_tier = managers.skilltree:get_specialization_value(self._tree, "tiers", "current_tier")
	local max_tier = managers.skilltree:get_specialization_value(self._tree, "tiers", "max_tier")

	self:refresh()
end

function SpecializationTreeItem:unlock_tier(tier)
end

function SpecializationTreeItem:on_points_spent()
end

function SpecializationTreeItem:tree()
	return self._tree
end

function SpecializationTreeItem:update_progress(chk_lock, current_points, next_tier_points)
	local current_tier = managers.skilltree:get_specialization_value(self._tree, "tiers", "current_tier")
	local max_tier = managers.skilltree:get_specialization_value(self._tree, "tiers", "max_tier")

	if current_tier < max_tier then
		local next_tier = current_tier + 1

		self._items[next_tier]:update_progress(chk_lock, current_points, next_tier_points)
	end
end

function SpecializationTreeItem:panel()
	return self._tree_panel
end

function SpecializationTreeItem:items()
	return self._items
end

function SpecializationTreeItem:item(item)
	return self._items[item or 1]
end

function SpecializationTreeItem:place_points_item()
	return self._place_points_item and self._items[self._place_points_item] or false
end

function SpecializationTreeItem:selected_item(x, y)
	for _, item in ipairs(self._items) do
		if item:inside(x, y) then
			return item
		end
	end
end

function SpecializationTreeItem:selected_btn(x, y)
	return self._parent_panel:child("point_btns_panel" .. tostring(self._tree)):tree_visible() and self._parent_panel:child("point_btns_panel" .. tostring(self._tree)):alpha() ~= 0 and (self._parent_panel:child("point_btns_panel" .. tostring(self._tree)):child("reduce_points"):inside(x, y) and -1 or self._parent_panel:child("point_btns_panel" .. tostring(self._tree)):child("increase_points"):inside(x, y) and 1) or false
end

function SpecializationTreeItem:set_visible(visible)
	self._tree_panel:set_visible(visible)
	self._parent_panel:child("active_text" .. tostring(self._tree)):set_visible(visible)
	self._parent_panel:child("selected_text" .. tostring(self._tree)):set_visible(visible)
	self._parent_panel:child("point_btns_panel" .. tostring(self._tree)):set_visible(visible)
end

function SpecializationTreeItem:select()
	self._selected = true

	self:refresh()
end

function SpecializationTreeItem:deselect()
	self._selected = false

	self:refresh()
end

function SpecializationTreeItem:refresh()
	local current_specialization = managers.skilltree:get_specialization_value("current_specialization")
	self._active = self._tree == current_specialization

	local function anim_refresh(o)
		local start_alpha = self._tree_panel:alpha()
		local end_alpha = (self._active and 1 or 0.95) * (self._selected and 1 or 0.3)
		local alpha = start_alpha
		local is_done = false
		local dt = 0

		while not is_done do
			dt = coroutine.yield()
			alpha = math.step(alpha, end_alpha, dt)

			self._tree_panel:set_alpha(alpha)

			is_done = alpha == end_alpha

			for _, item in ipairs(self._items) do
				if not alive(item) then
					return
				end

				if not item:update_size(dt, self._selected) then
					is_done = false
				end
			end
		end
	end

	local current_tier = managers.skilltree:get_specialization_value(self._tree, "tiers", "current_tier")
	local max_tier = managers.skilltree:get_specialization_value(self._tree, "tiers", "max_tier")
	local point_btns_panel = self._parent_panel:child("point_btns_panel" .. tostring(self._tree))
	local reduce_points = point_btns_panel:child("reduce_points")
	local increase_points = point_btns_panel:child("increase_points")

	reduce_points:set_alpha(self._selected and 1 or 0.5)
	increase_points:set_alpha(self._selected and 1 or 0.5)

	local dlc = tweak_data:get_raw_value("skilltree", "specializations", self._tree, "dlc")
	local can_place_points = current_tier < max_tier and (not dlc or managers.dlc:is_dlc_unlocked(dlc))

	point_btns_panel:set_alpha(can_place_points and 1 or 0)

	if can_place_points then
		point_btns_panel:set_center_x(math.round(self._items[current_tier + 1]:panel():center_x()))
	end

	self._place_points_item = can_place_points and current_tier + 1 or false
	local active_text = self._parent_panel:child("active_text" .. tostring(self._tree))

	active_text:set_alpha(self._active and 1 or 0)

	local selected_text = self._parent_panel:child("selected_text" .. tostring(self._tree))

	selected_text:set_alpha(not self._active and self._selected and 1 or self._active and 0 or 0.5)
	self._active_box_panel:set_visible(self._active)
	self._tree_panel:stop()
	self._tree_panel:animate(anim_refresh)
end

SpecializationTierItem = SpecializationTierItem or class(SpecializationItem)

function SpecializationTierItem:init(tier_data, tree_panel, tree, tier, x, y, w, h)
	SpecializationTierItem.super.init(self)

	self._locked = false
	self._tree = tree
	self._tier = tier
	local specialization_descs = tweak_data.upgrades.specialization_descs[tree]
	specialization_descs = specialization_descs and specialization_descs[tier] or {}
	local macroes = {}

	for i, d in pairs(specialization_descs) do
		macroes[i] = d
	end

	self._tier_data = tier_data
	self._name_string = tier_data.name_id and managers.localization:text(tier_data.name_id) or "NO_NAME_" .. tostring(tree) .. "_" .. tostring(tier)
	self._desc_string = tier_data.desc_id and managers.localization:text(tier_data.desc_id, macroes) or "NO_DESC_" .. tostring(tree) .. "_" .. tostring(tier)

	if _G.IS_VR or managers.user:get_setting("show_vr_descs") then
		local vr_desc_data = tweak_data:get_raw_value("vr", "specialization_descs_addons", self._tree, self._tier)

		if vr_desc_data then
			local vr_string = managers.localization:text("menu_vr_skill_addon") .. " " .. managers.localization:text(vr_desc_data.desc_id, vr_desc_data.macros)
			self._desc_string = self._desc_string .. "\n\n" .. vr_string
		end
	end

	local tier_panel = tree_panel:panel({
		halign = "scale",
		valign = "scale",
		name = tostring(tier),
		x = x,
		y = y,
		w = w,
		h = h
	})
	self._tier_panel = tier_panel
	self._basic_size = {
		w - 32,
		h - 32
	}
	self._selected_size = {
		w,
		h
	}
	local texture = "guis/textures/pd2/specialization/perk_icon_card"
	local texture_rect = {
		0,
		0,
		64,
		92
	}
	local unlocked_bg = tier_panel:bitmap({
		name = "unlocked_bg",
		layer = 0,
		visible = false,
		valign = "scale",
		halign = "scale",
		texture = texture,
		texture_rect = texture_rect,
		color = Color.white
	})

	unlocked_bg:set_center(tier_panel:w() / 2, tier_panel:h() / 2)

	local texture_rect_x = tier_data.icon_xy and tier_data.icon_xy[1] or 0
	local texture_rect_y = tier_data.icon_xy and tier_data.icon_xy[2] or 0
	local guis_catalog = "guis/"

	if tier_data.texture_bundle_folder then
		guis_catalog = guis_catalog .. "dlcs/" .. tostring(tier_data.texture_bundle_folder) .. "/"
	end

	local icon_atlas_texture = guis_catalog .. "textures/pd2/specialization/icons_atlas"
	local tier_icon = tier_panel:bitmap({
		layer = 1,
		halign = "scale",
		valign = "scale",
		blend_mode = "add",
		name = tostring(math.random(1000000)),
		texture = icon_atlas_texture,
		texture_rect = {
			texture_rect_x * 64,
			texture_rect_y * 64,
			64,
			64
		},
		color = Color.white
	})

	tier_icon:grow(-16, -16)
	tier_icon:set_center(tier_panel:w() / 2, tier_panel:h() / 2)

	self._tier_icon = tier_icon
	local progress_circle = tier_panel:bitmap({
		texture = "guis/textures/pd2/specialization/progress_ring",
		name = "progress_circle_current",
		valign = "scale",
		visible = false,
		alpha = 0.5,
		halign = "scale",
		render_template = "VertexColorTexturedRadial",
		layer = 1,
		color = Color(0, 1, 1)
	})

	progress_circle:set_shape(-6, -6, w + 12, h + 12)
	progress_circle:set_blend_mode("add")

	local progress_circle = tier_panel:bitmap({
		texture = "guis/textures/pd2/specialization/progress_ring",
		name = "progress_circle",
		valign = "scale",
		visible = false,
		alpha = 0.5,
		halign = "scale",
		render_template = "VertexColorTexturedRadial",
		layer = 1,
		color = Color(0, 1, 1)
	})

	progress_circle:set_shape(-6, -6, w + 12, h + 12)
	progress_circle:set_blend_mode("add")

	local progress_circle_bg = tier_panel:bitmap({
		texture = "guis/textures/pd2/specialization/progress_ring",
		name = "progress_circle_bg",
		valign = "scale",
		visible = false,
		halign = "scale",
		alpha = 0.1,
		layer = 0,
		color = Color.white
	})

	progress_circle_bg:set_shape(-6, -6, w + 12, h + 12)

	self._select_box_panel = self._tier_panel:panel({})
	self._inside_panel = self._select_box_panel:panel({})

	self._inside_panel:set_shape(6, 6, w - 12, h - 12)

	self._select_box = BoxGuiObject:new(self._select_box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._select_box:hide()
	self._select_box:set_clipping(false)
	self:refresh()
end

function SpecializationTierItem:name_string()
	return self._name_string
end

function SpecializationTierItem:desc_string()
	return self._desc_string
end

function SpecializationTierItem:desc_custom_color()
	return nil
end

function SpecializationTierItem:tier()
	return self._tier
end

function SpecializationTierItem:tree()
	return self._tree
end

function SpecializationTierItem:tier_data()
	return self._tier_data
end

function SpecializationTierItem:data()
	return self._tier_data
end

function SpecializationTierItem:panel()
	return self._tier_panel
end

function SpecializationTierItem:alive()
	return alive(self._tier_panel)
end

function SpecializationTierItem:inside(x, y)
	return self._inside_panel:tree_visible() and self._inside_panel:inside(x, y)
end

function SpecializationTierItem:flash()
	print("SpecializationTierItem:flash()")
end

function SpecializationTierItem:update_size(dt, tree_selected)
	local size = {
		self._tier_panel:size()
	}
	local end_size = tree_selected and self._selected_size or self._basic_size
	local is_done = true
	local lerp_size, step_size = nil

	for i = 1, #size, 1 do
		lerp_size = math.lerp(size[i], end_size[i], dt * 10)
		step_size = math.step(size[i], end_size[i], dt * 20)
		size[i] = math.abs(size[i] - lerp_size) < math.abs(size[i] - step_size) and step_size or lerp_size

		if is_done and size[i] ~= end_size[i] then
			is_done = false
		end
	end

	local cx, cy = self._tier_panel:center()

	self._tier_panel:set_size(unpack(size))
	self._tier_panel:set_center(cx, cy)
	self._select_box_panel:set_center(self._tier_panel:w() / 2, self._tier_panel:h() / 2)

	return is_done
end

function SpecializationTierItem:refresh()
	if not alive(self._tier_panel) then
		return
	end

	local points_spent = managers.skilltree:get_specialization_value(self._tree, "points_spent")
	local current_tier = managers.skilltree:get_specialization_value(self._tree, "tiers", "current_tier")
	local max_tier = managers.skilltree:get_specialization_value(self._tree, "tiers", "max_tier")
	local unlocked_bg = self._tier_panel:child("unlocked_bg")
	local tier_icon = self._tier_icon
	local progress_circle_current = self._tier_panel:child("progress_circle_current")
	local progress_circle = self._tier_panel:child("progress_circle")
	local progress_circle_bg = self._tier_panel:child("progress_circle_bg")
	local select_box = self._select_box
	local dlc = tweak_data:get_raw_value("skilltree", "specializations", self._tree, "dlc")
	local is_dlc_locked = dlc and not managers.dlc:is_dlc_unlocked(dlc)

	if current_tier < max_tier then
		local next_tier = current_tier + 1

		if self._tier < next_tier then
			tier_icon:set_blend_mode("sub")
			tier_icon:set_color(Color.white)
			tier_icon:set_layer(2)
			progress_circle:hide()
			progress_circle_bg:hide()
			progress_circle_current:hide()
			unlocked_bg:show()
			unlocked_bg:set_color(is_dlc_locked and tweak_data.screen_colors.important_1 or Color.white)

			if self._is_progressing then
				SimpleGUIEffectSpewer.skill_up(self._tier_panel:center_x(), self._tier_panel:center_y(), self._tier_panel:parent())
				managers.menu_component:post_event("menu_skill_investment")

				self._is_progressing = nil
			end
		elseif next_tier < self._tier then
			tier_icon:set_blend_mode("add")
			tier_icon:set_color(is_dlc_locked and tweak_data.screen_colors.important_1 or Color.white)
			tier_icon:set_layer(1)
			progress_circle:hide()
			progress_circle_bg:hide()
			progress_circle_current:hide()
			unlocked_bg:hide()
		else
			tier_icon:set_blend_mode("add")
			tier_icon:set_color(is_dlc_locked and tweak_data.screen_colors.important_1 or Color.white)
			tier_icon:set_layer(1)
			progress_circle:show()
			progress_circle_bg:show()
			progress_circle_current:show()
			unlocked_bg:hide()

			self._is_progressing = true

			self:update_progress(true)
		end
	else
		tier_icon:set_blend_mode("sub")
		tier_icon:set_color(Color.white)
		tier_icon:set_layer(2)
		progress_circle:hide()
		progress_circle_bg:hide()
		progress_circle_current:hide()
		unlocked_bg:show()
		unlocked_bg:set_color(is_dlc_locked and tweak_data.screen_colors.important_1 or Color.white)

		if self._is_progressing then
			SimpleGUIEffectSpewer.skill_up(self._tier_panel:center_x(), self._tier_panel:center_y(), self._tier_panel:parent())
			managers.menu_component:post_event("menu_skill_investment")

			self._is_progressing = nil
		end
	end

	select_box:set_visible(self._selected)
end

function SpecializationTierItem:update_progress(chk_lock, current_points, next_tier_points)
	if not chk_lock or not self._progress_gui_locked then
		current_points = current_points or managers.skilltree:get_specialization_value(self._tree, "tiers", "next_tier_data", "current_points")
		next_tier_points = next_tier_points or managers.skilltree:get_specialization_value(self._tree, "tiers", "next_tier_data", "points")
		local progress_circle = self._tier_panel:child("progress_circle")
		local progress_circle_bg = self._tier_panel:child("progress_circle_bg")
		local progress_circle_current = self._tier_panel:child("progress_circle_current")
		local progress = current_points / next_tier_points

		progress_circle:set_color(Color(progress, 1, 1))
		progress_circle_current:set_color(Color(managers.skilltree:get_specialization_value(self._tree, "tiers", "next_tier_data", "current_points") / managers.skilltree:get_specialization_value(self._tree, "tiers", "next_tier_data", "points"), 1, 1))
		progress_circle_bg:set_visible(progress ~= 0)
	end
end

function SpecializationTierItem:set_progress_gui_lock(locked)
	self._progress_gui_locked = true
end

function SpecializationTierItem:trigger()
	print("STUFF")
	self:refresh()
end

SpecializationGuiItem = SpecializationGuiItem or class()

function SpecializationGuiItem:init(main_panel, data, x, y, w, h)
	self._main_panel = main_panel
	self._panel = main_panel:panel({
		name = tostring(data.name),
		x = x,
		y = y,
		w = w,
		h = h
	})
	self._data = data or {}
	self._name = data.name
	self._child_panel = nil
	self._alpha = 1
end

function SpecializationGuiItem:data()
	return self._data
end

function SpecializationGuiItem:inside(x, y)
	return self._panel:inside(x, y)
end

function SpecializationGuiItem:select(instant, no_sound)
	if not self._selected then
		self._selected = true

		self:refresh()

		if not instant and not no_sound then
			managers.menu_component:post_event("highlight")
		end
	end
end

function SpecializationGuiItem:deselect(instant)
	if self._selected then
		self._selected = false
	end

	self:refresh()
end

function SpecializationGuiItem:set_highlight(highlight, no_sound)
	if self._highlighted ~= highlight then
		self._highlighted = highlight

		self:refresh()

		if highlight and not no_sound then
			managers.menu_component:post_event("highlight")
		end
	end
end

function SpecializationGuiItem:refresh()
	self._alpha = self._selected and 1 or self._highlighted and 0.85 or 0.7

	if self._child_panel and alive(self._child_panel) then
		self._child_panel:set_visible(self._selected)
	end
end

function SpecializationGuiItem:mouse_pressed(button, x, y)
	return self._panel:inside(x, y)
end

function SpecializationGuiItem:mouse_moved(x, y)
	return false, "arrow"
end

function SpecializationGuiItem:mouse_released(o, button, x, y)
end

function SpecializationGuiItem:destroy()
end

function SpecializationGuiItem:is_inside_scrollbar(x, y)
	return false
end

SpecializationGuiButtonItem = SpecializationGuiButtonItem or class(SpecializationGuiItem)

function SpecializationGuiButtonItem:init(main_panel, data, x)
	SpecializationGuiButtonItem.super.init(self, main_panel, data, 0, 0, 10, 10)

	local up_font_size = NOT_WIN_32 and RenderSettings.resolution.y < 720 and self._data.btn == "BTN_STICK_R" and 2 or 0
	self._btn_text = self._panel:text({
		text = "",
		name = "text",
		align = "left",
		blend_mode = "add",
		x = 10,
		layer = 1,
		font_size = small_font_size + up_font_size,
		font = small_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	self._btn_text_id = data.name
	self._btn_text_legends = data.legends
	self._pc_btn = data.pc_btn

	make_fine_text(self._btn_text)
	self._panel:set_size(main_panel:w() - x * 2, medium_font_size)
	self._panel:rect({
		blend_mode = "add",
		name = "select_rect",
		halign = "scale",
		alpha = 0.3,
		valign = "scale",
		color = tweak_data.screen_colors.button_stage_3
	})

	if not managers.menu:is_pc_controller() or managers.menu:is_steam_controller() then
		self._btn_text:set_color(tweak_data.screen_colors.text)
	end

	self._panel:set_left(x)
	self._panel:hide()
	self:set_order(data.prio)
	self._btn_text:set_right(self._panel:w())
	self:deselect(true)
	self:set_highlight(false)
end

function SpecializationGuiButtonItem:hide()
	self._panel:hide()
end

function SpecializationGuiButtonItem:show()
	self._panel:show()
end

function SpecializationGuiButtonItem:refresh()
	if managers.menu:is_pc_controller() then
		self._btn_text:set_color(self._highlighted and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
	end

	self._panel:child("select_rect"):set_visible(self._highlighted)
end

function SpecializationGuiButtonItem:visible()
	return self._panel:visible()
end

function SpecializationGuiButtonItem:set_order(prio)
	self._panel:set_y((prio - 1) * small_font_size + 10)
end

function SpecializationGuiButtonItem:set_text_btn_prefix(prefix)
	self._btn_prefix = prefix
end

function SpecializationGuiButtonItem:set_text_params(params)
	local prefix = self._btn_prefix and managers.localization:get_default_macro(self._btn_prefix) or ""
	local btn_text = prefix

	if managers.menu:is_steam_controller() then
		prefix = self._pc_btn or "skip_cutscene"
		btn_text = managers.localization:btn_macro(prefix)
	end

	if self._btn_text_id then
		btn_text = btn_text .. utf8.to_upper(managers.localization:text(self._btn_text_id, params))
	end

	if self._btn_text_legends then
		local legend_string = ""

		for i, legend in ipairs(self._btn_text_legends) do
			if i > 1 then
				legend_string = legend_string .. " | "
			end

			legend_string = legend_string .. managers.localization:text(legend)
		end

		btn_text = btn_text .. utf8.to_upper(legend_string)
	end

	self._btn_text:set_text(btn_text)
	make_fine_text(self._btn_text)

	local _, _, w, h = self._btn_text:text_rect()

	self._panel:set_h(h)
	self._btn_text:set_size(w, h)
	self._btn_text:set_right(self._panel:w())
end

function SpecializationGuiButtonItem:btn_text()
	return self._btn_text:text()
end

function SkillTreeGui:_start_rename_skill_switch()
	if not self._renaming_skill_switch then
		self._enabled = false
		local selected_skill_switch = managers.skilltree:get_selected_skill_switch()
		self._renaming_skill_switch = managers.skilltree:has_skill_switch_name(selected_skill_switch) and managers.skilltree:get_skill_switch_name(selected_skill_switch, false) or ""

		self._ws:connect_keyboard(Input:keyboard())
		self._skill_tree_panel:enter_text(callback(self, self, "enter_text"))
		self._skill_tree_panel:key_press(callback(self, self, "key_press"))
		self._skill_tree_panel:key_release(callback(self, self, "key_release"))

		self._rename_caret = self._skill_tree_panel:rect({
			name = "caret",
			h = 0,
			y = 0,
			w = 0,
			x = 0,
			layer = 2,
			color = Color(0.05, 1, 1, 1)
		})

		self._rename_caret:animate(self.blink)

		self._caret_connected = true

		self:_update_rename_skill_switch()
	end
end

function SkillTreeGui:_stop_rename_skill_switch()
	if self._renaming_skill_switch then
		self._enabled = true

		managers.skilltree:set_skill_switch_name(managers.skilltree:get_selected_skill_switch(), self._renaming_skill_switch)

		self._renaming_skill_switch = nil

		if self._caret_connected then
			self._ws:disconnect_keyboard()
			self._skill_tree_panel:enter_text(nil)
			self._skill_tree_panel:key_press(nil)
			self._skill_tree_panel:key_release(nil)
			self._skill_tree_panel:remove(self._rename_caret)

			self._rename_caret = nil
			self._caret_connected = nil
		end

		managers.menu_component:post_event("menu_enter")
		self:_update_rename_skill_switch()
	end
end

function SkillTreeGui:_cancel_rename_skill_switch()
	if self._renaming_skill_switch then
		self._enabled = true
		self._renaming_skill_switch = nil

		if self._caret_connected then
			self._ws:disconnect_keyboard()
			self._skill_tree_panel:enter_text(nil)
			self._skill_tree_panel:key_press(nil)
			self._skill_tree_panel:key_release(nil)
			self._skill_tree_panel:remove(self._rename_caret)

			self._rename_caret = nil
			self._caret_connected = nil
		end

		self._one_frame_input_delay = true

		self:_update_rename_skill_switch()
	end
end

function SkillTreeGui:_update_rename_skill_switch()
	local skill_set_text = self._skill_tree_panel:child("skill_set_text")

	if self._renaming_skill_switch then
		local no_text = self._renaming_skill_switch == ""

		if no_text then
			skill_set_text:set_text(managers.skilltree:get_default_skill_switch_name(managers.skilltree:get_selected_skill_switch()))
			skill_set_text:set_color(tweak_data.screen_colors.text)
			skill_set_text:set_alpha(0.35)
		else
			skill_set_text:set_text(self._renaming_skill_switch)
			skill_set_text:set_color(tweak_data.screen_colors.text)
			skill_set_text:set_alpha(1)
		end

		self:make_fine_text(skill_set_text)
		self._rename_caret:set_w(2)
		self._rename_caret:set_h(skill_set_text:h())
		self._rename_caret:set_world_position(no_text and skill_set_text:left() or skill_set_text:right(), skill_set_text:top())
	else
		skill_set_text:set_text(managers.localization:text("menu_st_skill_switch_set", {
			skill_switch = managers.skilltree:get_skill_switch_name(managers.skilltree:get_selected_skill_switch(), true)
		}))
		skill_set_text:set_color(tweak_data.screen_colors.text)
		skill_set_text:set_alpha(1)

		self._skill_set_highlight = nil

		self:make_fine_text(skill_set_text)
	end
end

function SkillTreeGui:_shift()
	local k = Input:keyboard()

	return k:down("left shift") or k:down("right shift") or k:has_button("shift") and k:down("shift")
end

function SkillTreeGui.blink(o)
	while true do
		o:set_color(Color(0, 1, 1, 1))
		wait(0.3)
		o:set_color(Color.white)
		wait(0.3)
	end
end

function SkillTreeGui:enter_text(o, s)
	if self._renaming_skill_switch then
		local m = tweak_data:get_raw_value("gui", "rename_skill_set_max_letters") or 15
		local n = utf8.len(self._renaming_skill_switch)
		s = utf8.sub(s, 1, m - n)
		self._renaming_skill_switch = self._renaming_skill_switch .. tostring(s)

		self:_update_rename_skill_switch()
	end
end

function SkillTreeGui:update_key_down(o, k)
	wait(0.6)

	while self._key_pressed == k do
		if not self._renaming_skill_switch then
			return
		end

		local text = self._renaming_skill_switch
		local n = utf8.len(text)

		if self._key_pressed == Idstring("backspace") then
			text = utf8.sub(text, 0, math.max(n - 1, 0))
		elseif self._key_pressed == Idstring("delete") then
			-- Nothing
		elseif self._key_pressed == Idstring("left") then
			-- Nothing
		elseif self._key_pressed == Idstring("right") then
			self._key_pressed = false
		elseif self._key_ctrl_pressed == true and k == Idstring("v") then
			return
		end

		if text ~= self._renaming_skill_switch then
			self._renaming_skill_switch = text

			self:_update_rename_skill_switch()
		end

		wait(0.03)
	end
end

function SkillTreeGui:key_release(o, k)
	if self._key_pressed == k then
		self._key_pressed = false
	end

	if k == Idstring("left ctrl") or k == Idstring("right ctrl") then
		self._key_ctrl_pressed = false
	end
end

function SkillTreeGui:key_press(o, k)
	local text = self._renaming_skill_switch
	local n = utf8.len(text)
	self._key_pressed = k

	self._skill_tree_panel:stop()
	self._skill_tree_panel:animate(callback(self, self, "update_key_down"), k)

	if k == Idstring("backspace") then
		text = utf8.sub(text, 0, math.max(n - 1, 0))
	elseif k == Idstring("delete") then
		-- Nothing
	elseif k == Idstring("left") then
		-- Nothing
	elseif k == Idstring("right") then
		-- Nothing
	elseif self._key_pressed == Idstring("end") then
		-- Nothing
	elseif self._key_pressed == Idstring("home") then
		-- Nothing
	elseif k == Idstring("enter") then
		-- Nothing
	elseif k == Idstring("esc") then
		self:_cancel_rename_skill_switch()

		return
	elseif k == Idstring("left ctrl") or k == Idstring("right ctrl") then
		self._key_ctrl_pressed = true
	elseif self._key_ctrl_pressed == true and k == Idstring("v") then
		return
	end

	if text ~= self._renaming_skill_switch then
		self._renaming_skill_switch = text

		self:_update_rename_skill_switch()
	end
end
