require("lib/managers/menu/WalletGuiObject")

local function make_fine_text(text_gui)
	local x, y, w, h = text_gui:text_rect()

	text_gui:set_size(w, h)
	text_gui:set_position(math.round(text_gui:x()), math.round(text_gui:y()))
end

local function fit_text_height(text_gui)
	local _, y, _, h = text_gui:text_rect()

	text_gui:set_h(h)
	text_gui:set_y(math.round(text_gui:y()))
end

local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local IS_WIN_32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not IS_WIN_32
local TOP_ADJUSTMENT = NOT_WIN_32 and 45 or 45
local BOT_ADJUSTMENT = NOT_WIN_32 and 45 or 45
local BIG_PADDING = 13.5
local PADDING = 10
local PAGE_TREE_OVERLAP = 2
local SKILLS_WIDTH_PERCENT = 0.7
local PAGE_TAB_H = medium_font_size + 10
NewSkillTreeGui = NewSkillTreeGui or class()

function NewSkillTreeGui:init(ws, fullscreen_ws, node)
	self._event_listener = EventListenerHolder:new()
	self._skilltree = managers.skilltree

	managers.menu:active_menu().renderer.ws:hide()

	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._node = node
	self._init_layer = self._ws:panel():layer()
	local menu_components_data = node:parameters().menu_component_data or {}
	self._active_page = nil
	self._active_tree_item = nil
	self._active_tier_item = nil
	self._selected_item = nil

	self:_setup()
	self:set_layer(5)
	self._event_listener:add(self, {
		"refresh"
	}, callback(self, self, "_on_refresh_event"))
end

function NewSkillTreeGui:event_listener()
	return self._event_listener
end

function NewSkillTreeGui:_setup()
	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end

	self._panel = self._ws:panel():panel({
		name = "SkillTreePanel",
		layer = self._init_layer
	})
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()

	WalletGuiObject.set_wallet(self._panel)

	local skilltree_text = self._panel:text({
		vertical = "top",
		name = "TitleText",
		align = "left",
		text = managers.localization:to_upper_text("menu_st_skilltree"),
		font = large_font,
		font_size = large_font_size,
		color = tweak_data.screen_colors.text
	})
	local x, y, w, h = skilltree_text:text_rect()

	skilltree_text:set_size(w, h)

	local title_bg_text = self._fullscreen_panel:text({
		name = "TitleTextBg",
		vertical = "top",
		h = 90,
		alpha = 0.4,
		align = "left",
		blend_mode = "add",
		layer = 1,
		text = skilltree_text:text(),
		font = massive_font,
		font_size = massive_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})
	local x, y = managers.gui_data:safe_to_full_16_9(skilltree_text:world_x(), skilltree_text:world_center_y())

	title_bg_text:set_world_left(x)
	title_bg_text:set_world_center_y(y)
	title_bg_text:move(-13, 9)
	MenuBackdropGUI.animate_bg_text(self, title_bg_text)

	if managers.menu:is_pc_controller() then
		local back_button = self._panel:text({
			name = "BackButton",
			blend_mode = "add",
			text = managers.localization:to_upper_text("menu_back"),
			font = large_font,
			font_size = large_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(back_button)
		back_button:set_right(self._panel:w())
		back_button:set_bottom(self._panel:h())

		local back_bg_text = self._fullscreen_panel:text({
			name = "TitleTextBg",
			vertical = "top",
			h = 90,
			alpha = 0.4,
			align = "right",
			blend_mode = "add",
			layer = 1,
			text = back_button:text(),
			font = massive_font,
			font_size = massive_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})
		local x, y = managers.gui_data:safe_to_full_16_9(back_button:world_right(), back_button:world_center_y())

		back_bg_text:set_world_right(x)
		back_bg_text:set_world_center_y(y)
		back_bg_text:move(13, 0)
		MenuBackdropGUI.animate_bg_text(self, back_bg_text)
	end

	local skills_panel = self._panel:panel({
		name = "SkillsRootPanel",
		layer = 1,
		w = self._panel:w() * SKILLS_WIDTH_PERCENT,
		h = self._panel:h() - (TOP_ADJUSTMENT + BOT_ADJUSTMENT)
	})

	skills_panel:set_top(TOP_ADJUSTMENT)
	skills_panel:set_left(0)

	local tab_panel = skills_panel:panel({
		name = "TabPanel",
		h = PAGE_TAB_H
	})

	tab_panel:set_top(0)
	tab_panel:set_left(0)

	local page_panel = skills_panel:panel({
		name = "PagePanel",
		h = skills_panel:h() - PAGE_TAB_H + PAGE_TREE_OVERLAP
	})

	page_panel:set_top(tab_panel:bottom() - PAGE_TREE_OVERLAP)
	page_panel:set_left(0)

	local tree_title_panel = page_panel:panel({
		name = "TreeTitlePanel",
		h = large_font_size
	})

	tree_title_panel:set_bottom(page_panel:h())
	tree_title_panel:set_left(0)

	local tree_panel = page_panel:panel({
		name = "TreePanel",
		h = tree_title_panel:top()
	})

	tree_panel:set_top(0)
	tree_panel:set_left(0)

	local info_panel = self._panel:panel({
		name = "InfoRootPanel",
		layer = 1,
		w = self._panel:w() * (1 - SKILLS_WIDTH_PERCENT) - BIG_PADDING,
		h = tree_panel:h()
	})

	info_panel:set_world_top(tree_panel:world_y())
	info_panel:set_right(self._panel:w())

	local skillset_panel = info_panel:panel({
		name = "SkillSetPanel"
	})
	local skillset_text = skillset_panel:text({
		name = "SkillSetText",
		blend_mode = "add",
		layer = 1,
		text = utf8.to_upper(self._skilltree:get_skill_switch_name(self._skilltree:get_selected_skill_switch(), true)),
		font = medium_font,
		font_size = medium_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})

	make_fine_text(skillset_text)
	skillset_panel:set_h(skillset_text:bottom())

	self._skillset_panel = skillset_panel
	local skillpoints_panel = info_panel:panel({
		name = "SkillPointsPanel",
		y = skillset_panel:bottom() + PADDING
	})
	local skillpoints_title_text = skillpoints_panel:text({
		name = "SkillPointsTitleText",
		blend_mode = "add",
		layer = 1,
		text = managers.localization:to_upper_text("menu_skillpoints"),
		font = medium_font,
		font_size = medium_font_size,
		color = tweak_data.screen_colors.text
	})
	local skillpoints_points_text = skillpoints_panel:text({
		name = "SkillPointsPointsText",
		blend_mode = "add",
		layer = 1,
		text = tostring(self._skilltree:points()),
		font = medium_font,
		font_size = medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(skillpoints_title_text)
	make_fine_text(skillpoints_points_text)
	skillpoints_points_text:set_right(skillpoints_panel:w())
	skillpoints_panel:set_h(skillpoints_title_text:bottom())

	self._skill_points_title_text = skillpoints_title_text
	self._skill_points_text = skillpoints_points_text
	local color = self._skilltree:points() > 0 and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1

	self._skill_points_title_text:set_color(color)
	self._skill_points_text:set_color(color)

	local description_panel = info_panel:panel({
		name = "DescriptionPanel",
		y = skillpoints_panel:bottom() + PADDING,
		h = info_panel:h() - (skillpoints_panel:bottom() + PADDING)
	})
	local description_text = description_panel:text({
		text = "",
		name = "DescriptionText",
		wrap = true,
		blend_mode = "add",
		word_wrap = true,
		font = small_font,
		font_size = small_font_size
	})

	description_text:grow(-PADDING, -PADDING)
	description_text:move(PADDING / 2, PADDING / 2)

	self._tab_items = {}
	self._tree_items = {}
	self._active_page = 0
	self._active_tree_item = nil
	self._active_tier_item = nil
	self._selected_item = nil
	local pages = managers.skilltree:get_pages()
	local page_data = nil
	local tab_x = 0
	local page_tree_title_panel, page_tree_panel = nil

	for index, page in ipairs(tweak_data.skilltree.skill_pages_order) do
		page_data = pages[page]

		if page_data and tweak_data.skilltree.skilltree[page] then
			page_tree_title_panel = tree_title_panel:panel()
			page_tree_panel = tree_panel:panel()
			local tree = NewSkillTreePage:new(page, page_data, page_tree_title_panel, page_tree_panel, self._fullscreen_panel, self)

			table.insert(self._tree_items, tree)

			local tab_item = NewSkillTreeTabItem:new(tab_panel, page, tab_x, index, self, tree)
			tab_x = tab_item:next_page_position()

			table.insert(self._tab_items, tab_item)
		end
	end

	self._selected_page = self._tree_items[1]
	self._legend_buttons = {}
	local legends_panel = self._panel:panel({
		name = "LegendsPanel",
		w = self._panel:w() * 0.75,
		h = tweak_data.menu.pd2_medium_font_size
	})

	legends_panel:set_righttop(self._panel:w(), 0)
	legends_panel:text({
		text = "",
		name = "LegendText",
		align = "right",
		blend_mode = "add",
		vertical = "top",
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.text
	})

	local legend_panel_reset_skills = self._panel:panel({
		name = "LegendPanelResetSkills",
		w = self._panel:w() * 0.75,
		h = tweak_data.menu.pd2_medium_font_size
	})

	legend_panel_reset_skills:set_righttop(self._panel:w() - 2, tweak_data.menu.pd2_medium_font_size)
	legend_panel_reset_skills:text({
		text = "RESET SKILLS",
		name = "LegendTextResetSkills",
		align = "right",
		blend_mode = "add",
		vertical = "top",
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.text
	})
	BoxGuiObject:new(tree_panel, {
		sides = {
			1,
			1,
			2,
			2
		}
	})
	BoxGuiObject:new(description_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

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
	self:set_active_page(1)
	self:_rec_round_object(self._panel)
end

function NewSkillTreeGui:set_skill_point_text(skill_points)
	local x, y, old_w, old_h = self._skill_points_text:text_rect()

	self._skill_points_text:set_text(tostring(skill_points))

	local x, y, w, h = self._skill_points_text:text_rect()
	local new_w = old_w - w
	local new_h = old_h - h

	self._skill_points_text:set_size(w, h)
	self._skill_points_text:set_position(self._skill_points_text:x() + new_w, self._skill_points_text:y() + new_h)

	local color = skill_points > 0 and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1

	self._skill_points_title_text:set_color(color)
	self._skill_points_text:set_color(color)
end

function NewSkillTreeGui:selected_page()
	return self._selected_page
end

function NewSkillTreeGui:refresh_reset_skills_legends(trees_idx)
	local legend_panel_reset_skills = self._panel:child("LegendPanelResetSkills")

	legend_panel_reset_skills:clear()

	local localization = managers.localization
	local right = legend_panel_reset_skills:w()

	if self:has_spent_skill_points() then
		local text = legend_panel_reset_skills:text({
			blend_mode = "add",
			text = localization:to_upper_text("skill_tree_reset_all_skills_button", {
				BTN_RESET_ALL_SKILLS = localization:btn_macro("menu_respec_tree_all")
			}),
			font = small_font,
			font_size = small_font_size,
			color = managers.menu:is_pc_controller() and tweak_data.screen_colors.button_stage_3 or Color.white
		})

		make_fine_text(text)
		text:set_right(right)

		right = text:left() - 10

		table.insert(self._legend_buttons, {
			text = text,
			callback = function ()
				self:respec_all()
			end
		})
	else
		return
	end

	if self:has_tree_spent_points(trees_idx) then
		local text = legend_panel_reset_skills:text({
			blend_mode = "add",
			text = localization:to_upper_text("skill_tree_reset_skills_button", {
				BTN_RESET_SKILLS = localization:btn_macro("menu_respec_tree")
			}),
			font = small_font,
			font_size = small_font_size,
			color = managers.menu:is_pc_controller() and tweak_data.screen_colors.button_stage_3 or Color.white
		})

		make_fine_text(text)
		text:set_right(right)
		table.insert(self._legend_buttons, {
			text = text,
			callback = function ()
				self:respec_page(self._tree_items[self._active_page])
			end
		})
	end
end

function NewSkillTreeGui:_on_refresh_event()
	local points = self._skilltree:points()

	self:set_skill_point_text(points)
	WalletGuiObject.refresh()
	self:refresh_reset_skills_legends(self._selected_page:trees_idx())
end

function NewSkillTreeGui:_rec_round_object(object)
	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end

	local x, y = object:position()

	object:set_position(math.round(x), math.round(y))
end

function NewSkillTreeGui:set_layer(layer)
	self._panel:set_layer(self._init_layer + layer)
end

function NewSkillTreeGui:layer()
	return self._panel:layer()
end

function NewSkillTreeGui:next_page(play_sound)
	if not self._enabled then
		return
	end

	self:set_active_page(self._active_page + 1, play_sound)
end

function NewSkillTreeGui:previous_page(play_sound)
	if not self._enabled then
		return
	end

	self:set_active_page(self._active_page - 1, play_sound)
end

function NewSkillTreeGui:set_active_page(new_page, play_sound)
	if new_page == self._active_page or new_page <= 0 or new_page >= #self._tab_items + 1 then
		return false
	end

	local active_tree = self._tree_items[self._active_page]
	local active_tab = self._tab_items[self._active_page]
	local new_tree = self._tree_items[new_page]
	local new_tab = self._tab_items[new_page]

	if active_tree then
		active_tree:set_active(false)
	end

	if active_tab then
		active_tab:set_active(false)
	end

	local item = nil

	if new_tree then
		item = new_tree:set_active(true)
	end

	if new_tab then
		new_tab:set_active(true)

		self._selected_page = new_tab:page()
	end

	if item then
		self:set_selected_item(item)
	end

	if play_sound then
		managers.menu_component:post_event("highlight")
	end

	self._active_page = new_page

	self:reload_connections()

	return true
end

function NewSkillTreeGui:set_selected_item(item, play_sound)
	if item == nil or item == self._selected_item then
		return
	end

	if self._selected_item then
		self._selected_item:set_selected(false)
	end

	if item._tier_item then
		self:set_active_tier(item._tier_item)
	end

	self._selected_item = item

	self._selected_item:set_selected(true)
	self:update_item()
end

function NewSkillTreeGui:set_active_tier(item)
	if item == self._active_tier_item then
		return
	end

	if self._active_tier_item then
		self._active_tier_item:set_active(false)
	end

	self._active_tier_item = item

	if self._active_tier_item then
		self._active_tier_item:set_active(true)
		self:set_active_tree(self._active_tier_item._tree_item)
	end
end

function NewSkillTreeGui:set_active_tree(item)
	if item == self._active_tree_item then
		return
	end

	if self._active_tree_item then
		self._active_tree_item:set_active(false)
	end

	self._active_tree_item = item

	if self._active_tree_item then
		self._active_tree_item:set_active(true)
	end
end

function NewSkillTreeGui:update_item()
	local item = self._selected_item

	if not item or not alive(self._panel) then
		return
	end

	self:_update_legends(item)
	self:_update_description(item)
end

function NewSkillTreeGui:_update_description(item)
	local desc_panel = self._panel:child("InfoRootPanel"):child("DescriptionPanel")
	local text = desc_panel:child("DescriptionText")
	local tier = item:tier()
	local skill_id = item:skill_id()
	local tweak_data_skill = tweak_data.skilltree.skills[skill_id]
	local skill_stat_color = tweak_data.screen_colors.resource
	local color_replace_table = {}
	local points = self._skilltree:points() or 0
	local basic_cost = self._skilltree:get_skill_points(skill_id, 1) or 0
	local pro_cost = self._skilltree:get_skill_points(skill_id, 2) or 0
	local talent = tweak_data.skilltree.skills[skill_id]
	local unlocked = self._skilltree:skill_unlocked(nil, skill_id)
	local step = self._skilltree:next_skill_step(skill_id)
	local completed = self._skilltree:skill_completed(skill_id)
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
		basic_cost = managers.localization:text(basic_cost == 1 and "st_menu_point" or "st_menu_point_plural", {
			points = basic_cost
		})
	end

	if step > 2 then
		pro_cost = utf8.to_upper(managers.localization:text("st_menu_skill_owned"))
		color_replace_table[pro_color_index] = tweak_data.screen_colors.resource
	else
		pro_cost = managers.localization:text(pro_cost == 1 and "st_menu_point" or "st_menu_point_plural", {
			points = pro_cost
		})
	end

	local macroes = {
		basic = basic_cost,
		pro = pro_cost
	}

	for i, d in pairs(skill_descs) do
		macroes[i] = d
	end

	local skill_btns = tweak_data.upgrades.skill_btns[skill_id]

	if skill_btns then
		for i, d in pairs(skill_btns) do
			macroes[i] = d()
		end
	end

	local basic_cost = managers.skilltree:skill_cost(tier, 1)
	local aced_cost = managers.skilltree:skill_cost(tier, 2)
	local skill_string = managers.localization:to_upper_text(tweak_data_skill.name_id)
	local cost_string = managers.localization:to_upper_text(basic_cost == 1 and "st_menu_skill_cost_singular" or "st_menu_skill_cost", {
		basic = basic_cost,
		aced = aced_cost
	})
	local desc_string = managers.localization:text(tweak_data.skilltree.skills[skill_id].desc_id, macroes)
	local full_string = skill_string .. "\n\n" .. desc_string

	if (_G.IS_VR or managers.user:get_setting("show_vr_descs")) and tweak_data.vr.skill_descs_addons[skill_id] then
		local addon_data = tweak_data.vr.skill_descs_addons[skill_id]
		local vr_addon = managers.localization:text(addon_data.text_id, addon_data.macros)
		full_string = full_string .. "\n\n" .. managers.localization:text("menu_vr_skill_addon") .. "\n" .. vr_addon
	end

	text:set_text(full_string)
	managers.menu_component:make_color_text(text)
	text:set_font_size(small_font_size)

	local _, _, _, h = text:text_rect()

	while h > desc_panel:h() - text:top() do
		text:set_font_size(text:font_size() * 0.98)

		_, _, _, h = text:text_rect()
	end
end

function NewSkillTreeGui:_update_legends(item)
	local legend_panel = self._panel:child("LegendsPanel")
	local text = legend_panel:child("LegendText")
	local skill_id = item:skill_id()
	local tier = item:tier()
	local tree = item:tree()
	local step = self._skilltree:next_skill_step(skill_id)
	local unlocked = self._skilltree:skill_unlocked(tree, skill_id)
	local completed = self._skilltree:skill_completed(skill_id)
	local skill_data = tweak_data.skilltree.skills[skill_id]
	local can_invest = unlocked and not completed
	local can_refund = step > 1
	local legends = {}

	table.insert(legends, {
		string_id = "menu_st_switch_skillset",
		is_button = managers.menu:is_pc_controller(),
		callback = function ()
			managers.menu:open_node("skill_switch", {})
		end
	})

	if managers.menu:is_pc_controller() then
		if can_refund then
			table.insert(legends, {
				texture = "guis/textures/pd2/mouse_buttons",
				h = 23,
				string_id = "menu_mouse_refund",
				w = 17,
				texture_rect = {
					18,
					1,
					17,
					23
				}
			})
		end

		if can_invest then
			table.insert(legends, {
				texture = "guis/textures/pd2/mouse_buttons",
				h = 23,
				string_id = "menu_mouse_invest",
				w = 17,
				texture_rect = {
					1,
					1,
					17,
					23
				}
			})
		end
	else
		if can_refund then
			table.insert(legends, {
				string_id = "menu_controller_refund"
			})
		end

		if can_invest then
			table.insert(legends, {
				string_id = "menu_controller_invest"
			})
		end
	end

	legend_panel:clear()

	local text, icon = nil
	local right = legend_panel:w()

	for _, legend in ipairs(legends) do
		text, icon = nil

		if legend.string_id then
			text = legend_panel:text({
				blend_mode = "add",
				text = managers.localization:to_upper_text(legend.string_id, {
					BTN_SKILLSET = managers.localization:btn_macro("menu_switch_skillset")
				}),
				font = small_font,
				font_size = small_font_size
			})

			make_fine_text(text)
			text:set_right(right)

			right = text:left()
		end

		if legend.texture then
			icon = legend_panel:bitmap({
				texture = legend.texture,
				texture_rect = legend.texture_rect,
				w = legend.w,
				h = legend.h
			})

			icon:set_right(right)

			right = icon:left()
		end

		if text and legend.is_button then
			text:set_color(managers.menu:is_pc_controller() and tweak_data.screen_colors.button_stage_3 or Color.white)
			table.insert(self._legend_buttons, {
				text = text,
				callback = legend.callback
			})
		end

		right = right - 10
	end
end

function NewSkillTreeGui:move_up()
	if not self._enabled then
		return
	end

	if self._selected_item then
		self:set_selected_item(self._selected_item:get_link("up"))
	end
end

function NewSkillTreeGui:move_down()
	if not self._enabled then
		return
	end

	if self._selected_item then
		self:set_selected_item(self._selected_item:get_link("down"))
	end
end

function NewSkillTreeGui:move_left()
	if not self._enabled then
		return
	end

	if self._selected_item then
		self:set_selected_item(self._selected_item:get_link("left"))
	end
end

function NewSkillTreeGui:move_right()
	if not self._enabled then
		return
	end

	if self._selected_item then
		self:set_selected_item(self._selected_item:get_link("right"))
	end
end

function NewSkillTreeGui:mouse_moved(o, x, y)
	if self._renaming_skill_switch then
		return true, "link"
	end

	if not self._enabled then
		return
	end

	local inside = false
	local pointer = "arrow"

	if self._skillset_panel:inside(x, y) then
		if not self._skillset_highlight then
			self._skillset_highlight = true

			self._skillset_panel:child("SkillSetText"):set_color(tweak_data.screen_colors.button_stage_2)
			managers.menu_component:post_event("highlight")
		end

		inside = true
		pointer = "link"
	elseif self._skillset_highlight then
		self._skillset_highlight = false

		self._skillset_panel:child("SkillSetText"):set_color(tweak_data.screen_colors.button_stage_3)
	end

	if not self._selected_item or not self._selected_item:inside(x, y) then
		if self._active_page then
			local active_tree = self._tree_items[self._active_page]
			local item = active_tree:inside(x, y)

			if item then
				self:set_selected_item(item, true)

				inside = true
				pointer = "link"
			end
		end
	elseif not self._selected_item:is_active() then
		inside = true
		pointer = "link"
	end

	if not self._selected_tab or not self._selected_tab:inside(x, y) then
		if self._selected_tab then
			self._selected_tab:set_selected(false)

			self._selected_tab = nil
		end

		for _, tab_item in ipairs(self._tab_items) do
			if tab_item:inside(x, y) then
				tab_item:set_selected(true)

				self._selected_tab = tab_item
				inside = inside or true
				pointer = "link"
			end
		end
	elseif not self._selected_tab:is_active() then
		inside = inside or true
		pointer = "link"
	end

	if managers.menu:is_pc_controller() then
		if self._panel:child("BackButton"):inside(x, y) then
			if not self._back_highlight then
				self._back_highlight = true

				self._panel:child("BackButton"):set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end

			inside = true
			pointer = "link"
		elseif self._back_highlight then
			self._back_highlight = false

			self._panel:child("BackButton"):set_color(tweak_data.screen_colors.button_stage_3)
		end

		for _, legend in ipairs(self._legend_buttons) do
			if alive(legend.text) then
				if legend.text:inside(x, y) then
					legend.text:set_color(tweak_data.screen_colors.button_stage_2)

					inside = true
					pointer = "link"
				else
					legend.text:set_color(tweak_data.screen_colors.button_stage_3)
				end
			end
		end
	end

	if not inside and self._panel:inside(x, y) then
		inside = true
		pointer = "arrow"
	end

	return inside, pointer
end

function NewSkillTreeGui:mouse_released(button, x, y)
	if not self._enabled then
		return
	end
end

function NewSkillTreeGui:mouse_pressed(button, x, y)
	if self._renaming_skill_switch then
		self:_stop_rename_skill_switch()

		return
	end

	if not self._enabled then
		return
	end

	if button == Idstring("0") and self._skillset_panel:inside(x, y) then
		self:_start_rename_skill_switch()

		return
	end

	if button == Idstring("mouse wheel down") then
		self:next_page()

		return
	elseif button == Idstring("mouse wheel up") then
		self:previous_page()

		return
	end

	local invest_button_pressed = button == Idstring("0")
	local refund_button_pressed = button == Idstring("1")

	if self._selected_item and self._selected_item:inside(x, y) then
		if invest_button_pressed then
			self:invest_point(self._selected_item)

			return
		elseif refund_button_pressed then
			self:refund_point(self._selected_item)

			return
		end
	end

	if invest_button_pressed and self._selected_tab and self._selected_tab:inside(x, y) then
		self:set_active_page(self._selected_tab:index())

		return
	end

	if managers.menu:is_pc_controller() then
		if self._back_highlight and self._panel:child("BackButton"):inside(x, y) then
			managers.menu:back()

			return
		end

		for _, legend in ipairs(self._legend_buttons) do
			if alive(legend.text) and legend.text:inside(x, y) then
				if legend.callback then
					legend.callback()
				end

				return
			end
		end
	end
end

function NewSkillTreeGui:invest_point(item)
	local skill_id = item:skill_id()
	local step = self._skilltree:next_skill_step(skill_id)
	local unlocked = self._skilltree:skill_unlocked(nil, skill_id)
	local completed = self._skilltree:skill_completed(skill_id)
	local skill_data = tweak_data.skilltree.skills[skill_id]

	if not unlocked then
		item:flash()

		return
	end

	if completed then
		item:flash()

		return
	end

	if item:invest() then
		local panel = item:panel()

		SimpleGUIEffectSpewer.infamous_up(panel:world_center_x(), panel:world_center_y(), self._fullscreen_panel)
		self:on_notify(item:tree(), {
			label = "refresh"
		})
		managers.menu_component:post_event("menu_skill_investment")
		self:update_item()
		self:reload_connections()
		WalletGuiObject.refresh()
		self:refresh_reset_skills_legends(self._selected_page:trees_idx())
	end
end

function NewSkillTreeGui:refund_point(item)
	local skill_id = item:skill_id()
	local step = self._skilltree:next_skill_step(skill_id)
	local completed = self._skilltree:skill_completed(skill_id)
	local skill_data = tweak_data.skilltree.skills[skill_id]
	local can_refund = item:can_refund()

	if not can_refund then
		item:flash()

		return
	end

	if item:refund() then
		self:on_notify(item:tree(), {
			label = "refresh"
		})
		managers.menu_component:post_event("menu_skill_investment")
		self:update_item()
		self:reload_connections()
		WalletGuiObject.refresh()
		self:refresh_reset_skills_legends(self._selected_page:trees_idx())
	else
		item:flash()
	end
end

function NewSkillTreeGui:confirm_pressed()
	if self._renaming_skill_switch then
		self:_stop_rename_skill_switch()

		return
	end

	if not self._enabled then
		return
	end

	if self._selected_item and self._selected_item._skill_panel then
		self:invest_point(self._selected_item)

		return true
	end

	return false
end

function NewSkillTreeGui:special_btn_pressed(button)
	if not self._enabled then
		return
	end

	if button == Idstring("menu_remove_skill") then
		self:refund_point(self._selected_item)

		return true
	elseif button == Idstring("menu_switch_skillset") then
		managers.menu:open_node("skill_switch", {})

		return
	elseif button == Idstring("menu_respec_tree") and self:has_tree_spent_points(self._selected_page:trees_idx()) then
		self:respec_page(self._tree_items[self._active_page])

		return
	elseif button == Idstring("menu_respec_tree_all") and self:has_spent_skill_points() then
		self:respec_all()

		return
	end

	return false
end

function NewSkillTreeGui:flash_item(item)
	item:flash()
	managers.menu_component:post_event("menu_error")
end

function NewSkillTreeGui:_dialog_confirm_yes(item)
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

function NewSkillTreeGui:_dialog_confirm_no(item)
end

function NewSkillTreeGui:on_tier_unlocked(tree, tier)
	return

	self._pages[tree]:unlock_tier(tier)
end

function NewSkillTreeGui:on_skill_unlocked(tree, skill_id)
end

function NewSkillTreeGui:on_points_spent()
end

function NewSkillTreeGui:respec_page(page)
	local params = {
		tree = page:name(),
		yes_func = callback(self, self, "_dialog_respec_trees_yes", page:trees_idx()),
		no_func = callback(self, self, "_dialog_respec_no")
	}

	managers.menu:show_confirm_respec_skilltree(params)
end

function NewSkillTreeGui:respec_all()
	local params = {
		yes_func = callback(self, self, "_dialog_respec_all_yes"),
		no_func = callback(self, self, "_dialog_respec_no")
	}

	managers.menu:show_confirm_respec_skilltree_all(params)
end

function NewSkillTreeGui:respec_tree(tree)
	local params = {
		tree = tree
	}
end

function NewSkillTreeGui:_dialog_respec_trees_yes(trees_idx)
	for i = 1, #trees_idx do
		local tree_idx = trees_idx[i]

		if self._skilltree:points_spent(tree_idx) > 0 then
			self._skilltree:on_respec_tree(tree_idx)
		end
	end

	self._event_listener:call("refresh")
end

function NewSkillTreeGui:_dialog_respec_all_yes()
	for i = 1, #self._tree_items do
		local trees_idx = self._tree_items[i]:trees_idx()

		for j = 1, #trees_idx do
			local tree_idx = trees_idx[j]

			if self._skilltree:points_spent(tree_idx) > 0 then
				self._skilltree:on_respec_tree(tree_idx)
			end
		end
	end

	self._event_listener:call("refresh")
end

function NewSkillTreeGui:_dialog_respec_no()
end

function NewSkillTreeGui:has_tree_spent_points(trees_idx)
	for i = 1, #trees_idx do
		local tree_idx = trees_idx[i]

		if self._skilltree:points_spent(tree_idx) > 0 then
			return true
		end
	end

	return false
end

function NewSkillTreeGui:has_spent_skill_points()
	for i = 1, #self._tree_items do
		local trees_idx = self._tree_items[i]:trees_idx()

		for j = 1, #trees_idx do
			local tree_idx = trees_idx[j]

			if self._skilltree:points_spent(tree_idx) > 0 then
				return true
			end
		end
	end

	return false
end

function NewSkillTreeGui:on_skilltree_reset(tree)
	self:_pre_reload()
	NewSkillTreeGui.init(self, self._ws, self._fullscreen_ws, self._node)
	self:_post_reload()
	self:set_active_page(tree or self._skilltree:get_most_progressed_tree())
	self:set_selected_item(self._active_page:item(), true)
end

function NewSkillTreeGui:_pre_reload()
	self._temp_panel = self._panel
	self._temp_fullscreen_panel = self._fullscreen_panel
	self._panel = nil
	self._fullscreen_panel = nil

	self._temp_panel:hide()
	self._temp_fullscreen_panel:hide()
end

function NewSkillTreeGui:_post_reload()
	self._ws:panel():remove(self._temp_panel)
	self._fullscreen_ws:panel():remove(self._temp_fullscreen_panel)
end

function NewSkillTreeGui:input_focus()
	if self._one_frame_input_delay then
		self._one_frame_input_delay = nil

		return true
	end

	return self._enabled and 1 or self._renaming_skill_switch and true
end

function NewSkillTreeGui:visible()
	return self._visible
end

function NewSkillTreeGui:is_enabled()
	return self._enabled
end

function NewSkillTreeGui:enable()
	self._enabled = true

	if alive(self._disabled_panel) then
		self._fullscreen_ws:panel():remove(self._disabled_panel)

		self._disabled_panel = nil
	end
end

function NewSkillTreeGui:disable()
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

function NewSkillTreeGui:close()
	managers.menu:active_menu().renderer.ws:show()
	self:_cancel_rename_skill_switch()

	if alive(self._disabled_panel) then
		self._fullscreen_ws:panel():remove(self._disabled_panel)

		self._disabled_panel = nil
	end

	WalletGuiObject.close_wallet(self._panel)
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

function NewSkillTreeGui:mouse_clicked(o, button, x, y)
	self._mouse_click_index = ((self._mouse_click_index or 0) + 1) % 2
	self._mouse_click = self._mouse_click or {}
	self._mouse_click[self._mouse_click_index] = {
		button = button,
		x = x,
		y = y,
		selected_tree = self._active_skill_tree
	}
end

function NewSkillTreeGui:mouse_double_click(o, button, x, y)
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

function NewSkillTreeGui:press_first_btn(button)
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

function NewSkillTreeGui:update(t, dt)
	local active_tree = self._tree_items[self._active_page]

	if active_tree then
		active_tree:update(t, dt)
	end
end

function NewSkillTreeGui:show_btns(...)
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

function NewSkillTreeGui:press_pc_button(button)
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

function NewSkillTreeGui:_update_borders()
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

function NewSkillTreeGui:on_notify(tree, msg)
	for i = 1, #self._tree_items do
		self._tree_items[i]:on_notify(tree, msg)
	end
end

function NewSkillTreeGui:reload_connections()
	for i = 1, #self._tree_items do
		self._tree_items[i]:reload_connections()
	end
end

NewSkillTreeItem = NewSkillTreeItem or class()

function NewSkillTreeItem:init()
	self._selected = false
end

function NewSkillTreeItem:refresh()
end

function NewSkillTreeItem:inside()
end

function NewSkillTreeItem:is_selected()
	return self._selected
end

function NewSkillTreeItem:set_selected(selected, play_sound)
	self._selected = selected

	self:refresh()

	if self._selected and play_sound then
		managers.menu_component:post_event("highlight")
	end
end

function NewSkillTreeItem:is_active()
	return self._active
end

function NewSkillTreeItem:set_active(active, play_sound)
	self._active = active

	self:refresh()
end

function NewSkillTreeItem:trigger()
	managers.menu_component:post_event("menu_enter")
	self:refresh()
end

function NewSkillTreeItem:flash()
end

NewSkillTreeTabItem = NewSkillTreeTabItem or class(NewSkillTreeItem)

function NewSkillTreeTabItem:init(page_tab_panel, page, tab_x, index, gui, page_item)
	NewSkillTreeTabItem.super.init(self)

	self._index = index
	self._page = page
	self._active = false
	self._selected = false
	self._gui = gui
	self._page_item = page_item
	local page_panel = page_tab_panel:panel({
		name = "Page" .. string.capitalize(tostring(page)),
		x = tab_x
	})
	local page_text = page_panel:text({
		name = "PageText",
		vertical = "center",
		align = "center",
		layer = 1,
		text = managers.localization:to_upper_text(tweak_data.skilltree.skilltree[page].name_id),
		font = medium_font,
		font_size = medium_font_size,
		color = Color.black
	})
	local _, _, tw, th = page_text:text_rect()

	page_panel:set_size(tw + 15, th + 10)
	page_text:set_size(page_panel:size())

	local page_tab_bg = page_panel:bitmap({
		texture = "guis/textures/pd2/shared_tab_box",
		name = "PageTabBG",
		w = page_panel:w(),
		h = page_panel:h(),
		color = tweak_data.screen_colors.text
	})
	self._page_panel = page_panel

	self:refresh()
end

function NewSkillTreeTabItem:index()
	return self._index
end

function NewSkillTreeTabItem:page()
	return self._page_item
end

function NewSkillTreeTabItem:prev_page_position()
	return self._page_panel:left() - 15
end

function NewSkillTreeTabItem:next_page_position()
	return self._page_panel:right() + 15
end

function NewSkillTreeTabItem:set_active(active)
	self._active = active

	self:refresh()
end

function NewSkillTreeTabItem:is_active()
	return self._active
end

function NewSkillTreeTabItem:tree()
	return self._tree
end

function NewSkillTreeTabItem:inside(x, y)
	return self._page_panel:inside(x, y)
end

function NewSkillTreeTabItem:refresh()
	if not alive(self._page_panel) then
		return
	end

	self._page_panel:child("PageText"):set_blend_mode(self._active and "normal" or "add")
	self._page_panel:child("PageText"):set_color(self._active and Color.black or self._selected and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
	self._page_panel:child("PageTabBG"):set_visible(self._active)
end

NewSkillTreePage = NewSkillTreePage or class(NewSkillTreeItem)

function NewSkillTreePage:init(page, page_data, tree_title_panel, tree_panel, fullscreen_panel, gui)
	NewSkillTreePage.super.init(self)

	local skilltrees_tweak = tweak_data.skilltree.trees
	self._gui = gui
	self._active = false
	self._selected = 0
	self._tree_titles = {}
	self._trees = {}
	self._trees_idx = {}
	self._page_name = page
	self._tree_title_panel = tree_title_panel
	self._tree_panel = tree_panel
	self._event_listener = gui:event_listener()

	self._event_listener:add(page, {
		"refresh"
	}, callback(self, self, "_on_refresh_event"))

	local tree_space = tree_title_panel:w() / 2 * 0.015
	local tree_width = tree_title_panel:w() / 3 - tree_space
	tree_space = (tree_title_panel:w() - tree_width * 3) / 2
	local panel, tree_data = nil

	for index, tree in ipairs(page_data) do
		tree_data = skilltrees_tweak[tree]

		table.insert(self._trees_idx, tree)

		panel = tree_title_panel:panel({
			name = "TreeTitle" .. tostring(tree),
			w = tree_width,
			x = (index - 1) * (tree_width + tree_space)
		})

		panel:text({
			name = "TitleText",
			blend_mode = "add",
			align = "center",
			vertical = "center",
			text = managers.localization:to_upper_text(tree_data.name_id),
			font = large_font,
			font_size = large_font_size * 0.75,
			color = tweak_data.screen_colors.button_stage_3
		})
		table.insert(self._tree_titles, panel)

		panel = NewSkillTreeTreeItem:new(tree, tree_data, tree_panel:panel({
			name = "Tree" .. tostring(tree),
			w = tree_width,
			x = (index - 1) * (tree_width + tree_space)
		}), fullscreen_panel, gui, self)

		table.insert(self._trees, panel)
	end

	for tree, tree_item in ipairs(self._trees) do
		tree_item:link(self._trees[tree - 1], self._trees[tree + 1])
	end

	self:refresh()
end

function NewSkillTreePage:trees_idx()
	local trees_idx = deep_clone(self._trees_idx)

	return trees_idx
end

function NewSkillTreePage:_on_refresh_event()
	self:refresh()
end

function NewSkillTreePage:update(t, dt)
	for i = 1, #self._trees do
		self._trees[i]:update(t, dt)
	end
end

function NewSkillTreePage:on_points_spent()
end

function NewSkillTreePage:item(tree, tier, skill_id)
	return self._trees[tree or 1] and self._trees[tree or 1]:item(tier, skill_id)
end

function NewSkillTreePage:inside(x, y)
	if self._tree_panel:inside(x, y) then
		local item, tree_inside = nil

		for tree, tree_item in ipairs(self._trees) do
			item, tree_inside = tree_item:inside(x, y)

			if self._selected ~= tree and tree_inside then
				self._selected = tree

				self:refresh()
			end

			if item then
				return item
			end
		end
	end
end

function NewSkillTreePage:inside_tree(x, y, tree)
	return self._trees[tree] and self._trees[tree]:inside(x, y)
end

function NewSkillTreePage:inside_tree_tier(x, y, tree, tier)
	return self._trees[tree] and self._trees[tree]:inside_tier(x, y, tier)
end

function NewSkillTreePage:inside_tree_tier_skill(x, y, tree, tier, skill)
	return self._trees[tree] and self._trees[tree]:inside_tier_skill(x, y, tier, skill)
end

function NewSkillTreePage:refresh()
	self._tree_panel:set_visible(self._active)
	self._tree_title_panel:set_visible(self._active)

	if self._active then
		for index, title_panel in ipairs(self._tree_titles) do
			local title = title_panel:child("TitleText")

			title:set_color(self._selected == index and tweak_data.screen_colors.text or tweak_data.screen_colors.button_stage_3)
			title:set_alpha(self._selected == index and 1 or 0.75)
		end
	end
end

function NewSkillTreePage:set_active(active)
	self._active = active

	self:refresh()

	if active then
		self._gui:refresh_reset_skills_legends(self:trees_idx())
	end

	return active and self:item(1, 1)
end

function NewSkillTreePage:on_notify(tree, msg)
	for i = 1, #self._trees do
		self._trees[i]:on_notify(tree, msg)
	end
end

function NewSkillTreePage:reload_connections()
	for i = 1, #self._trees do
		self._trees[i]:reload_connections()
	end
end

function NewSkillTreePage:name()
	return self._page_name
end

NewSkillTreeTreeItem = NewSkillTreeTreeItem or class(NewSkillTreeItem)

function NewSkillTreeTreeItem:init(tree, tree_data, tree_panel, fullscreen_panel, gui, page)
	NewSkillTreeTreeItem.super.init(self)

	self._gui = gui
	self._selected = false
	self._tiers = {}
	self._tree_panel = tree_panel
	self._tree = tree
	self._page = page
	self._event_listener = gui:event_listener()

	self._event_listener:add(tree_data, {
		"refresh"
	}, callback(self, self, "_on_refresh_event"))

	local num_tiers = #tree_data.tiers
	local tier_height = tree_panel:h() / num_tiers
	local tier_panel, tier_item = nil

	for tier, tier_data in ipairs(tree_data.tiers) do
		tier_panel = tree_panel:panel({
			name = "Tier" .. tostring(tier),
			h = tier_height,
			y = (num_tiers - tier) * tier_height
		})
		tier_item = NewSkillTreeTierItem:new(tier, tier_data, tier_panel, tree_panel, tree, self, fullscreen_panel, gui)
		self._tiers[tier] = tier_item
	end

	for tier, tier_item in ipairs(self._tiers) do
		tier_item:link(self._tiers[tier + 1], self._tiers[tier - 1])
		tier_item:connect(self._tiers[tier + 1])
	end

	local tier, points_spent, points_max = self:_tree_points()
	local tier_height = self._tree_panel:h() / num_tiers
	self._progress_start = self._tree_panel:h()
	self._progress_tier_height = tier_height
	self._progress_pos_current = math.max(0, self._progress_start - self._progress_tier_height * tier - self._progress_tier_height * points_spent / points_max)
	self._progress_pos_wanted = self._progress_pos_current
	self._progress = tree_panel:bitmap({
		texture = "guis/textures/pd2/skilltree_2/subtree_fill"
	})

	self._progress:set_width(tree_panel:w())
	self._progress:set_height(tree_panel:h())
	self._progress:set_y(self._progress_pos_current)
end

function NewSkillTreeTreeItem:update(t, dt)
	for _, tier_item in ipairs(self._tiers) do
		tier_item:update(t, dt)
	end

	if self._progress_pos_current ~= self._progress_pos_wanted then
		self._progress_pos_current = math.lerp(self._progress_pos_current, self._progress_pos_wanted, dt * 6)
		self._progress_pos_current = math.step(self._progress_pos_current, self._progress_pos_wanted, dt * 25)

		self._progress:set_y(self._progress_pos_current)
	end
end

function NewSkillTreeTreeItem:tier(tier)
	return self._tiers[tier]
end

function NewSkillTreeTreeItem:item(tier, skill_id)
	return self._tiers[tier or 1] and self._tiers[tier or 1]:item(skill_id)
end

function NewSkillTreeTreeItem:inside(x, y)
	if self._tree_panel:inside(x, y) then
		local item = nil

		for tier, tier_item in pairs(self._tiers) do
			item = tier_item:inside(x, y)

			if item then
				return item, true
			end
		end

		return nil, true
	end
end

function NewSkillTreeTreeItem:inside_tier(x, y, tier)
	return self._tiers[tier] and self._tiers[tier]:inside(x, y)
end

function NewSkillTreeTreeItem:inside_tier_skill(x, y, tier, skill)
	return self._tiers[tier] and self._tiers[tier]:inside_skill(x, y, skill)
end

function NewSkillTreeTreeItem:_on_refresh_event()
	self:refresh()

	if self._page ~= self._gui:selected_page() then
		self._progress:set_y(self._progress_pos_wanted)

		self._progress_pos_current = self._progress_pos_wanted
	end
end

function NewSkillTreeTreeItem:refresh()
	local tier, points_spent, points_max = self:_tree_points()
	self._progress_pos_wanted = math.max(0, self._progress_start - self._progress_tier_height * tier - self._progress_tier_height * points_spent / points_max)
end

function NewSkillTreeTreeItem:reload_connections()
	for _, tier_item in ipairs(self._tiers) do
		tier_item:reload_connections()
	end

	local tier, points_spent, points_max = self:_tree_points()
	self._progress_pos_wanted = math.max(0, self._progress_start - self._progress_tier_height * tier - self._progress_tier_height * points_spent / points_max)
end

function NewSkillTreeTreeItem:set_active(active)
	for tier, tier_item in pairs(self._tiers) do
		tier_item:refresh_points(active)
	end

	self._selected = active

	self._progress:set_alpha(active and 1 or 0.5)
end

function NewSkillTreeTreeItem:_tree_points()
	local points_spent = managers.skilltree:points_spent(self._tree)
	local points_max = nil
	local points_prev = 0

	for tier = 1, #self._tiers do
		points_max = managers.skilltree:tier_cost(self._tree, tier)

		if points_spent < points_max then
			return tier - 1, points_spent - points_prev, points_max - points_prev
		end

		points_prev = points_max
	end

	return #self._tiers - 1, points_spent, points_max
end

function NewSkillTreeTreeItem:link(left_tree, right_tree)
	local first_item, last_item = nil

	for tier, tier_item in ipairs(self._tiers) do
		first_item = tier_item:first_item()
		last_item = tier_item:last_item()

		if left_tree then
			first_item:link(left_tree:tier(tier):last_item(), nil, nil, nil)
		end

		if right_tree then
			last_item:link(nil, right_tree:tier(tier):first_item(), nil, nil)
		end
	end
end

function NewSkillTreeTreeItem:on_notify(tree, msg)
	if tree == self._tree or tree == 0 then
		for tier, tier_item in ipairs(self._tiers) do
			tier_item:on_notify(tree, tier, msg)
		end
	end

	for tier, tier_item in pairs(self._tiers) do
		tier_item:refresh_points(self._selected)
	end
end

NewSkillTreeTierItem = NewSkillTreeTierItem or class(NewSkillTreeItem)

function NewSkillTreeTierItem:init(tier, tier_data, tier_panel, tree_panel, tree, tree_item, fullscreen_panel, gui)
	NewSkillTreeTierItem.super.init(self)

	local skilltrees_tweak = tweak_data.skilltree.skills
	self._gui = gui
	self._tree = tree
	self._tree_item = tree_item
	self._tier = tier
	self._tier_panel = tier_panel
	self._skills = {}
	self._skills_ordered = {}
	local num_skills = #tier_data
	local skill_width = tier_panel:w() / num_skills
	local skill_x = 0
	local skill_data, skill_panel, skill_item = nil

	for index, skill_id in ipairs(tier_data) do
		skill_data = skilltrees_tweak[skill_id]

		if skill_data then
			skill_panel = tier_panel:panel({
				name = "Skill" .. string.capitalize(skill_id),
				x = skill_x,
				w = skill_width
			})
			skill_x = skill_panel:right()
			skill_item = NewSkillTreeSkillItem:new(skill_id, skill_data, skill_panel, tree_panel, tree, tier, self, fullscreen_panel, gui)
			self._skills[skill_id] = skill_item

			table.insert(self._skills_ordered, skill_id)
		end
	end

	local line_length = tier_panel:w()
	local line_small = line_length * 0.03
	self._text_space = line_length * 0.02

	if tier < #tweak_data.skilltree.trees[tree].tiers then
		local line_left = tier_panel:bitmap({
			texture = "guis/textures/pd2/shared_lines",
			valign = "grow",
			layer = 1,
			halign = "grow",
			wrap_mode = "wrap"
		})
		local line_right = tier_panel:bitmap({
			texture = "guis/textures/pd2/shared_lines",
			valign = "grow",
			layer = 1,
			halign = "grow",
			wrap_mode = "wrap"
		})
		local line_middle = tier_panel:bitmap({
			texture = "guis/textures/pd2/skilltree_2/lines_blue",
			blend_mode = "add",
			wrap_mode = "wrap",
			halign = "grow",
			layer = 1,
			valign = "grow"
		})
		local lx = math.random(1, 255)
		local ly = math.random(0, line_left:texture_height() / 2 - 1) * 2

		line_left:set_texture_coordinates(Vector3(lx, ly + 2, 0), Vector3(lx, ly, 0), Vector3(lx + 2, ly + 2, 0), Vector3(lx + 2, ly, 0))
		line_left:set_size(line_small, 2)
		line_right:set_texture_coordinates(Vector3(lx, ly + 2, 0), Vector3(lx, ly, 0), Vector3(lx + 2, ly + 2, 0), Vector3(lx + 2, ly, 0))
		line_right:set_size(line_small, 2)
		line_right:set_right(tier_panel:right())
		line_middle:set_texture_coordinates(Vector3(lx, ly + 2, 0), Vector3(lx, ly, 0), Vector3(lx + 2, ly + 2, 0), Vector3(lx + 2, ly, 0))
		line_middle:set_size(line_length - line_small * 2, 2)
		line_middle:set_left(line_left:right())
	end

	self._tier_points_0 = tier_panel:text({
		vertical = "top",
		name = "TierPointsZeros",
		alpha = 0.6,
		align = "left",
		blend_mode = "add",
		visible = false,
		layer = 1,
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})
	self._tier_points = tier_panel:text({
		vertical = "top",
		name = "TierPoints",
		alpha = 0.9,
		align = "left",
		blend_mode = "add",
		visible = false,
		layer = 1,
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})
	local tier_points = managers.skilltree:tier_cost(tree, tier)

	self._tier_points_0:set_text(tier_points < 1 and "000" or tier_points < 10 and "00" or tier_points < 100 and "0" or "")
	self._tier_points:set_text(tier_points > 0 and tier_points or "")

	local _, _, zero_w, zero_h = self._tier_points_0:text_rect()

	self._tier_points_0:set_size(zero_w, zero_h)
	self._tier_points_0:set_position(line_small, self._text_space)
	self._tier_points:set_left(self._tier_points_0:right())
	self._tier_points:set_top(self._text_space)

	if tier == 1 then
		self._tier_points_total = tier_panel:text({
			vertical = "bottom",
			name = "TierPointsTotal",
			alpha = 0.6,
			align = "left",
			blend_mode = "add",
			visible = false,
			layer = 1,
			font = small_font,
			font_size = small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})
		self._tier_points_total_zero = tier_panel:text({
			vertical = "bottom",
			name = "TierPointsTotalZero",
			alpha = 0.6,
			align = "left",
			blend_mode = "add",
			visible = false,
			layer = 1,
			font = small_font,
			font_size = small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})
		self._tier_points_total_curr = tier_panel:text({
			vertical = "bottom",
			name = "TierPointsTotalCurr",
			alpha = 0.6,
			align = "left",
			blend_mode = "add",
			visible = false,
			layer = 1,
			font = small_font,
			font_size = small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		self._tier_points_total:set_text(managers.localization:to_upper_text("menu_st_points_total"))

		local _, _, w, h = self._tier_points_total:text_rect()

		self._tier_points_total:set_size(w, h)
	end

	self._tier_points_needed = tier_panel:text({
		vertical = "top",
		name = "TierPointsNeeded",
		alpha = 0.9,
		align = "left",
		blend_mode = "add",
		visible = false,
		layer = 1,
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})
	self._tier_points_needed_tier = tier_panel:text({
		vertical = "top",
		name = "TierPointsNeededTier",
		alpha = 1,
		align = "left",
		blend_mode = "add",
		visible = false,
		layer = 1,
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.button_stage_2
	})
	self._tier_points_needed_curr = tier_panel:text({
		vertical = "top",
		name = "TierPointsNeededCurr",
		alpha = 0.9,
		align = "left",
		blend_mode = "add",
		visible = false,
		layer = 1,
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})
	self._tier_points_needed_zero = tier_panel:text({
		vertical = "top",
		name = "TierPointsNeededZero",
		alpha = 0.6,
		align = "left",
		blend_mode = "add",
		visible = false,
		layer = 1,
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})

	self._tier_points_needed:set_text(managers.localization:to_upper_text("menu_st_points_unlock"))
	self._tier_points_needed_tier:set_text(managers.localization:to_upper_text("menu_st_points_unlock_tier", {
		tier = tier
	}))

	local _, _, tw, th = self._tier_points_needed_tier:text_rect()

	self._tier_points_needed_tier:set_size(tw, th)

	local _, _, uw, uh = self._tier_points_needed:text_rect()

	self._tier_points_needed:set_size(uw, uh)
	self._tier_points_needed_tier:set_right(tier_panel:w() - self._text_space)
	self._tier_points_needed:set_right(self._tier_points_needed_tier:left() - self._text_space)
	self._tier_points_needed:set_top(self._text_space)
	self._tier_points_needed_tier:set_top(self._text_space)
	self._tier_points_needed_curr:set_top(self._text_space)
	self._tier_points_needed_zero:set_top(self._text_space)

	for index, skill_id in ipairs(self._skills_ordered) do
		local left_item = self._skills[self._skills_ordered[index - 1]]
		local right_item = self._skills[self._skills_ordered[index + 1]]

		self._skills[skill_id]:link(left_item, right_item, nil, nil)
		self._skills[skill_id]:connect(right_item)
	end

	self:refresh()
end

function NewSkillTreeTierItem:refresh_points(selected)
	self._tier_points:set_visible(selected)
	self._tier_points_0:set_visible(selected)

	if self._tier_points_total then
		self._tier_points_total:set_visible(selected)
		self._tier_points_total_zero:set_visible(selected)
		self._tier_points_total_curr:set_visible(selected)

		if selected then
			local points_spent = managers.skilltree:points_spent(self._tree)

			self._tier_points_total_zero:set_text(points_spent < 1 and "000" or points_spent < 10 and "00" or points_spent < 100 and "0" or "")

			local _, _, zw, zh = self._tier_points_total_zero:text_rect()

			self._tier_points_total_zero:set_size(zw, zh)
			self._tier_points_total_curr:set_text(points_spent > 0 and points_spent or "")

			local _, _, cw, ch = self._tier_points_total_curr:text_rect()

			self._tier_points_total_curr:set_size(cw, ch)
			self._tier_points_total_curr:set_right(self._tier_panel:right() - self._text_space)
			self._tier_points_total_zero:set_right(self._tier_points_total_curr:left())
			self._tier_points_total:set_right(self._tier_points_total_zero:left() - self._text_space)
			self._tier_points_total:set_bottom(self._tier_panel:h() - self._text_space)
			self._tier_points_total_zero:set_bottom(self._tier_panel:h() - self._text_space)
			self._tier_points_total_curr:set_bottom(self._tier_panel:h() - self._text_space)
		end
	end

	if not selected then
		self._tier_points_needed:set_visible(false)
		self._tier_points_needed_tier:set_visible(false)
		self._tier_points_needed_curr:set_visible(false)
		self._tier_points_needed_zero:set_visible(false)
	end
end

function NewSkillTreeTierItem:_refresh_tier_text(selected)
	local enable = selected

	if selected then
		local tier_points = managers.skilltree:tier_cost(self._tree, self._tier) - managers.skilltree:points_spent(self._tree)

		if tier_points > 0 then
			self._tier_points_needed_zero:set_text(tier_points < 1 and "000" or tier_points < 10 and "00" or tier_points < 100 and "0" or "")

			local _, _, zw, zh = self._tier_points_needed_zero:text_rect()

			self._tier_points_needed_zero:set_size(zw, zh)
			self._tier_points_needed_curr:set_text(tier_points > 0 and tier_points or "")

			local _, _, cw, ch = self._tier_points_needed_curr:text_rect()

			self._tier_points_needed_curr:set_size(cw, ch)
			self._tier_points_needed_curr:set_right(self._tier_points_needed:left() - self._text_space)
			self._tier_points_needed_zero:set_right(self._tier_points_needed_curr:left())
		else
			enable = false
		end
	end

	self._tier_points_needed:set_visible(enable)
	self._tier_points_needed_tier:set_visible(enable)
	self._tier_points_needed_curr:set_visible(enable)
	self._tier_points_needed_zero:set_visible(enable)
end

function NewSkillTreeTierItem:update(t, dt)
	for _, skill_id in ipairs(self._skills_ordered) do
		self._skills[skill_id]:update(t, dt)
	end
end

function NewSkillTreeTierItem:next_item_by_index(index)
	if index == 0 then
		return nil
	end

	return self._skills_ordered[index] and self._skills[self._skills_ordered[index]] or self:next_item_by_index(index - 1)
end

function NewSkillTreeTierItem:first_item()
	return self._skills_ordered[1] and self._skills[self._skills_ordered[1]]
end

function NewSkillTreeTierItem:last_item()
	return self._skills_ordered[#self._skills_ordered] and self._skills[self._skills_ordered[#self._skills_ordered]]
end

function NewSkillTreeTierItem:item_by_index(index)
	return self._skills_ordered[index] and self._skills[self._skills_ordered[index]]
end

function NewSkillTreeTierItem:item(skill_id)
	return self._skills[skill_id] or self._skills_ordered[1] and self._skills[self._skills_ordered[1]]
end

function NewSkillTreeTierItem:link(up_tier, down_tier)
	local neighbour_tiers = {
		[3] = up_tier,
		[4] = down_tier
	}
	local links = {}

	for index, skill_id in ipairs(self._skills_ordered) do
		links = {
			false,
			false,
			false,
			false
		}

		for i, tier in pairs(neighbour_tiers) do
			if tier then
				links[i] = tier:next_item_by_index(index) or false
			end
		end

		self._skills[skill_id]:link(unpack(links))
	end
end

function NewSkillTreeTierItem:connect(tier)
	if not tier then
		return
	end

	for index, skill_id in ipairs(self._skills_ordered) do
		local index = 1
		local item = tier:item_by_index(index)

		while item do
			self._skills[skill_id]:connect(item)

			index = index + 1
			item = tier:item_by_index(index)
		end
	end
end

function NewSkillTreeTierItem:reload_connections()
	for _, skill_id in ipairs(self._skills_ordered) do
		self._skills[skill_id]:reload_connection()
	end
end

function NewSkillTreeTierItem:set_active(active)
	self:_refresh_tier_text(active)
end

function NewSkillTreeTierItem:inside(x, y)
	if self._tier_panel:inside(x, y) then
		self._gui:set_active_tier(self)

		for skill_id, skill_item in pairs(self._skills) do
			if skill_item:inside(x, y) then
				return skill_item
			end
		end
	end
end

function NewSkillTreeTierItem:inside_skill(x, y, skill)
	return self._skills[skill] and self._skills[skill]:inside(x, y)
end

function NewSkillTreeTierItem:on_notify(tree, tier, msg)
	for _, obj in pairs(self._skills) do
		if self._tree == tree or tree == 0 then
			obj:on_notify(tree, tier, msg)
		end
	end
end

NewSkillTreeSkillItem = NewSkillTreeSkillItem or class(NewSkillTreeItem)

function NewSkillTreeSkillItem:init(skill_id, skill_data, skill_panel, tree_panel, tree, tier, tier_item, fullscreen_panel, gui)
	NewSkillTreeSkillItem.super.init(self)

	self._gui = gui
	self._skilltree = managers.skilltree
	self._fullscreen_panel = fullscreen_panel
	self._tree = tree
	self._tier = tier
	self._tier_item = tier_item
	self._skill_panel = skill_panel
	self._tree_panel = tree_panel
	self._skill_id = skill_id
	self._selected = false
	self._can_refund = false
	self._event_listener = gui:event_listener()

	self._event_listener:add(skill_id, {
		"refresh"
	}, callback(self, self, "_on_refresh_event"))

	local skill_text = skill_panel:text({
		name = "SkillName",
		blend_mode = "add",
		rotation = 360,
		layer = 2,
		text = managers.localization:to_upper_text(skill_data.name_id),
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(skill_text)

	local icon_panel_size = skill_panel:h() - skill_text:h() - PADDING * 2
	local skill_icon_panel = skill_panel:panel({
		name = "SkillIconPanel",
		w = icon_panel_size,
		h = icon_panel_size
	})

	skill_icon_panel:set_center_x(skill_panel:w() / 2)
	skill_icon_panel:set_top(PADDING)
	skill_text:set_center_x(skill_icon_panel:center_x())
	skill_text:set_top(skill_icon_panel:bottom())

	local texture_rect_x = skill_data.icon_xy and skill_data.icon_xy[1] or 0
	local texture_rect_y = skill_data.icon_xy and skill_data.icon_xy[2] or 0
	self._icon = skill_icon_panel:bitmap({
		texture = "guis/textures/pd2/skilltree_2/icons_atlas_2",
		name = "Icon",
		blend_mode = "normal",
		layer = 1,
		texture_rect = {
			texture_rect_x * 80,
			texture_rect_y * 80,
			80,
			80
		},
		color = tweak_data.screen_colors.button_stage_3
	})
	local locked = skill_icon_panel:bitmap({
		texture = "guis/textures/pd2/skilltree/padlock",
		name = "Locked",
		blend_mode = "normal",
		layer = 2,
		color = tweak_data.screen_colors.text
	})

	locked:set_center(skill_icon_panel:w() / 2, skill_icon_panel:h() / 2)

	local maxed_indicator = skill_icon_panel:bitmap({
		texture = "guis/textures/pd2/skilltree_2/ace_symbol",
		name = "MaxedIndicator",
		blend_mode = "add",
		color = tweak_data.screen_colors.button_stage_2
	})

	maxed_indicator:set_size(skill_icon_panel:w() * 1.2, skill_icon_panel:h() * 1.2)
	maxed_indicator:set_center(skill_icon_panel:w() / 2, skill_icon_panel:h() / 2)

	self._selected_size = math.floor(self._icon:w())
	self._unselected_size = math.floor(self._icon:w() * 0.8)
	self._current_size = self._unselected_size

	self._icon:set_size(self._current_size, self._current_size)
	self._icon:set_center(skill_icon_panel:w() / 2, skill_icon_panel:h() / 2)

	self._connection = self._connection or {}

	self:refresh()
end

function NewSkillTreeSkillItem:_on_refresh_event()
	self:refresh()
end

function NewSkillTreeSkillItem:on_notify(tree, tier, msg)
	if (self._tier == tier or tier == 0) and msg.label == "refresh" then
		self:refresh()
	end
end

function NewSkillTreeSkillItem:is_active()
	return self._skilltree:skill_completed(self._skill_id)
end

function NewSkillTreeSkillItem:refresh()
	if not alive(self._skill_panel) then
		return
	end

	local skill_id = self._skill_id
	local selected = self._selected
	local step = self._skilltree:next_skill_step(skill_id)
	local unlocked = managers.skilltree:skill_unlocked(self._tree, skill_id)
	local completed = self._skilltree:skill_completed(skill_id)
	local skill_data = tweak_data.skilltree.skills[skill_id]
	local skill_icon_panel = self._skill_panel:child("SkillIconPanel")
	local skill_text = self._skill_panel:child("SkillName")
	local icon = skill_icon_panel:child("Icon")
	local locked = skill_icon_panel:child("Locked")
	local maxed_indicator = skill_icon_panel:child("MaxedIndicator")

	skill_text:set_visible(self._selected)
	icon:set_color(step > 1 and tweak_data.screen_colors.text or tweak_data.screen_colors.button_stage_3)
	icon:set_alpha(not unlocked and (self._selected and 0.7 or 0.5) or step > 1 and 1 or self._selected and 0.8 or 0.6)
	locked:set_visible(not unlocked)
	maxed_indicator:set_visible(completed)
	self:_update_can_refund()
end

function NewSkillTreeSkillItem:panel()
	return self._skill_panel
end

function NewSkillTreeSkillItem:tree()
	return self._tree
end

function NewSkillTreeSkillItem:tier()
	return self._tier
end

function NewSkillTreeSkillItem:skill_id()
	return self._skill_id
end

function NewSkillTreeSkillItem:can_refund()
	return self._can_refund
end

function NewSkillTreeSkillItem:_update_can_refund()
	if self._selected then
		self._can_refund = self._skilltree:skill_can_be_removed(self:tree(), self:tier(), self:skill_id())
	else
		self._can_refund = false
	end
end

function NewSkillTreeSkillItem:set_selected(selected, play_sound)
	NewSkillTreeSkillItem.super.set_selected(self, selected, play_sound)
	self:_update_can_refund()
end

function NewSkillTreeSkillItem:link(left_item, right_item, up_item, down_item)
	self._left_item = left_item or self._left_item
	self._right_item = right_item or self._right_item
	self._up_item = up_item or self._up_item
	self._down_item = down_item or self._down_item
end

function NewSkillTreeSkillItem:get_link(link)
	if link == "left" then
		return self._left_item
	elseif link == "right" then
		return self._right_item
	elseif link == "up" then
		return self._up_item
	elseif link == "down" then
		return self._down_item
	end
end

function NewSkillTreeSkillItem:connect(item)
end

function NewSkillTreeSkillItem:create_connection_point(offset)
	return self._skill_panel:child("SkillIconPanel"):world_center_x() - self._tree_panel:world_x(), self._skill_panel:child("SkillIconPanel"):world_center_y() - self._tree_panel:world_y()
end

function NewSkillTreeSkillItem:reload_connection()
	for _, connection in pairs(self._connection) do
		self:connect(connection.item)
	end
end

function NewSkillTreeSkillItem:update(t, dt)
	for _, connection in pairs(self._connection) do
		if connection.rotate then
			connection.rotate = (connection.rotate + dt * 10) % connection.length
			local fw = connection.rotate
			local length = connection.length

			connection.line1:set_texture_coordinates(Vector3(fw, 0, 0), Vector3(fw + length, 0, 0), Vector3(fw, 16, 0), Vector3(fw + length, 16, 0))
			connection.line2:set_texture_coordinates(Vector3(-fw, 0, 0), Vector3(-fw + length, 0, 0), Vector3(-fw, 16, 0), Vector3(-fw + length, 16, 0))
		end
	end

	local wanted_size = self._selected and self._selected_size or self._unselected_size

	if self._current_size ~= wanted_size then
		local cx, cy = self._icon:center()
		self._current_size = math.lerp(self._current_size, wanted_size, dt * 6)
		self._current_size = math.step(self._current_size, wanted_size, dt * 25)

		self._icon:set_size(self._current_size, self._current_size)
		self._icon:set_center(cx, cy)
	end
end

function NewSkillTreeSkillItem:inside(x, y)
	return self._skill_panel:child("SkillIconPanel"):inside(x, y)
end

function NewSkillTreeSkillItem:flash()
	local skill_text = self._skill_panel:child("SkillName")

	if self._is_flashing then
		return
	end

	self._is_flashing = true

	local function flash_anim(panel)
		local st_color = skill_text:color()
		local s = 0

		over(0.5, function (t)
			s = math.min(1, math.sin(t * 180) * 2)

			skill_text:set_color(math.lerp(st_color, tweak_data.screen_colors.important_1, s))
		end)
		skill_text:set_color(st_color)

		self._is_flashing = nil
	end

	self:refresh()
	self._skill_panel:animate(flash_anim)
end

function NewSkillTreeSkillItem:invest()
	local refresh = false
	local skill_id = self._skill_id

	if self._skilltree:has_enough_skill_points(skill_id) and self._skilltree:unlock(skill_id) then
		local skill_step = self._skilltree:skill_step(skill_id)
		local points = self._skilltree:skill_cost(self._tier, skill_step)
		local skill_points = self._skilltree:spend_points(points)

		self._gui:set_skill_point_text(skill_points)
		self._skilltree:_set_points_spent(self._tree, self._skilltree:points_spent(self._tree) + points)
		self:refresh(self._locked)

		refresh = true
	end

	return refresh
end

function NewSkillTreeSkillItem:refund()
	local skill_tree = self._skilltree
	local skill_id = self._skill_id
	local skill_level = skill_tree:skill_step(skill_id)
	local refresh = false

	if skill_level > 0 then
		local tier = self._tier
		local tree = self._tree

		if skill_tree:refund_skill(tree, tier, skill_id) then
			local cost = skill_tree:skill_cost(tier, skill_level)
			local skill_points = skill_tree:refund_points(cost)

			self._gui:set_skill_point_text(skill_points)
			self._skilltree:_set_points_spent(tree, skill_tree:points_spent(tree) - cost)
			self:refresh(self._locked)

			refresh = true
		end
	end

	return refresh
end

function NewSkillTreeGui:_start_rename_skill_switch()
	if not self._renaming_skill_switch then
		self._enabled = false
		local selected_skill_switch = self._skilltree:get_selected_skill_switch()
		self._renaming_skill_switch = self._skilltree:has_skill_switch_name(selected_skill_switch) and self._skilltree:get_skill_switch_name(selected_skill_switch, false) or ""

		self._ws:connect_keyboard(Input:keyboard())

		if _G.IS_VR then
			Input:keyboard():show_with_text(self._renaming_skill_switch)
		end

		self._skillset_panel:enter_text(callback(self, self, "enter_text"))
		self._skillset_panel:key_press(callback(self, self, "key_press"))
		self._skillset_panel:key_release(callback(self, self, "key_release"))

		self._rename_caret = self._skillset_panel:rect({
			name = "caret",
			h = 0,
			y = 0,
			w = 0,
			rotation = 360,
			x = 0,
			layer = 2,
			color = Color(0.05, 1, 1, 1)
		})

		self._rename_caret:animate(self.blink)

		self._caret_connected = true

		self:_update_rename_skill_switch()
	end
end

function NewSkillTreeGui:_stop_rename_skill_switch()
	if self._renaming_skill_switch then
		self._enabled = true

		self._skilltree:set_skill_switch_name(self._skilltree:get_selected_skill_switch(), self._renaming_skill_switch)

		self._renaming_skill_switch = nil

		if self._caret_connected then
			self._ws:disconnect_keyboard()
			self._skillset_panel:enter_text(nil)
			self._skillset_panel:key_press(nil)
			self._skillset_panel:key_release(nil)
			self._skillset_panel:remove(self._rename_caret)

			self._rename_caret = nil
			self._caret_connected = nil
		end

		managers.menu_component:post_event("menu_enter")
		self:_update_rename_skill_switch()
	end
end

function NewSkillTreeGui:_cancel_rename_skill_switch()
	if self._renaming_skill_switch then
		self._enabled = true
		self._renaming_skill_switch = nil

		if self._caret_connected then
			self._ws:disconnect_keyboard()
			self._skillset_panel:enter_text(nil)
			self._skillset_panel:key_press(nil)
			self._skillset_panel:key_release(nil)
			self._skillset_panel:remove(self._rename_caret)

			self._rename_caret = nil
			self._caret_connected = nil
		end

		self._one_frame_input_delay = true

		self:_update_rename_skill_switch()
	end
end

function NewSkillTreeGui:_update_rename_skill_switch()
	local skill_set_text = self._skillset_panel:child("SkillSetText")

	if self._renaming_skill_switch then
		local no_text = self._renaming_skill_switch == ""

		if no_text then
			skill_set_text:set_text(self._skilltree:get_default_skill_switch_name(self._skilltree:get_selected_skill_switch()))
			skill_set_text:set_color(tweak_data.screen_colors.text)
			skill_set_text:set_alpha(0.35)
		else
			skill_set_text:set_text(self._renaming_skill_switch)
			skill_set_text:set_color(tweak_data.screen_colors.text)
			skill_set_text:set_alpha(1)
		end

		make_fine_text(skill_set_text)
		self._rename_caret:set_w(2)
		self._rename_caret:set_h(skill_set_text:h())
		self._rename_caret:set_position(no_text and skill_set_text:left() or skill_set_text:right(), skill_set_text:top())
	else
		skill_set_text:set_text(managers.localization:text("menu_st_skill_switch_set", {
			skill_switch = self._skilltree:get_skill_switch_name(self._skilltree:get_selected_skill_switch(), true)
		}))
		skill_set_text:set_color(tweak_data.screen_colors.text)
		skill_set_text:set_alpha(1)

		self._skill_set_highlight = nil

		make_fine_text(skill_set_text)
	end
end

function NewSkillTreeGui:_shift()
	local k = Input:keyboard()

	return k:down("left shift") or k:down("right shift") or k:has_button("shift") and k:down("shift")
end

function NewSkillTreeGui.blink(o)
	while true do
		o:set_color(Color(0, 1, 1, 1))
		wait(0.3)
		o:set_color(Color.white)
		wait(0.3)
	end
end

function NewSkillTreeGui:enter_text(o, s)
	if self._renaming_skill_switch then
		local m = tweak_data:get_raw_value("gui", "rename_skill_set_max_letters") or 15
		local n = utf8.len(self._renaming_skill_switch)

		if _G.IS_VR then
			s = utf8.sub(s, 1, m)
			self._renaming_skill_switch = tostring(s)
		else
			s = utf8.sub(s, 1, m - n)
			self._renaming_skill_switch = self._renaming_skill_switch .. tostring(s)
		end

		self:_update_rename_skill_switch()
	end
end

function NewSkillTreeGui:update_key_down(o, k)
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

function NewSkillTreeGui:key_release(o, k)
	if self._key_pressed == k then
		self._key_pressed = false
	end

	if k == Idstring("left ctrl") or k == Idstring("right ctrl") then
		self._key_ctrl_pressed = false
	end
end

function NewSkillTreeGui:key_press(o, k)
	local text = self._renaming_skill_switch
	local n = utf8.len(text)
	self._key_pressed = k

	self._skillset_panel:stop()
	self._skillset_panel:animate(callback(self, self, "update_key_down"), k)

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
		if _G.IS_VR then
			self:_stop_rename_skill_switch()

			return
		end
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
