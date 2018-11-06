require("lib/managers/menu/MenuInitiatorBase")

local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local tiny_font = tweak_data.menu.pd2_tiny_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local tiny_font_size = tweak_data.menu.pd2_tiny_font_size
MenuNodeAchievementFilterCreator = MenuNodeAchievementFilterCreator or class(MenuInitiatorBase)

function MenuNodeAchievementFilterCreator:create_item(node, item_type, params)
	local data_node = {
		type = item_type
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_enabled(params.enabled)
	node:add_item(new_item)

	return new_item
end

function MenuNodeAchievementFilterCreator:create_divider(node, params)
	params = params or {}
	params.no_text = not params.text_id
	params.size = params.size or 8
	local data_node = {
		type = "MenuItemDivider"
	}
	local new_item = node:create_item(data_node, params)

	node:add_item(new_item)

	return new_item
end

function MenuNodeAchievementFilterCreator:create_tags_option(node, category_name, text_func, sort_func)
	Global.achievements_filters = Global.achievements_filters or {}
	local filters = Global.achievements_filters
	filters.tags = filters.tags or {}
	local tags = tweak_data.achievement.tags
	local options = {
		{
			text_id = "menu_achievement_filter_off",
			_meta = "option",
			color = tweak_data.screen_colors.button_stage_3
		},
		{
			value = true,
			text_id = "menu_achievement_any",
			_meta = "option"
		}
	}
	local values = table.map_values(tags[category_name], sort_func)

	for _, v in pairs(values) do
		local text, localize = text_func(v)

		table.insert(options, {
			_meta = "option",
			text_id = text,
			value = v,
			localize = localize
		})
	end

	table.insert(options, {
		value = false,
		text_id = "menu_achievement_none",
		_meta = "option"
	})

	local rtn = self:create_multichoice(node, options, {
		enabled = true,
		text_id = "menu_achievements_" .. category_name,
		name = "tag_" .. category_name,
		help_id = "menu_achievements_" .. category_name .. "_help"
	})

	rtn:set_value(filters.tags[category_name])

	return rtn
end

local function create_tag_text(str)
	return "menu_achievements_" .. str
end

local difficulty_order = {
	"difficulty_normal",
	"difficulty_hard",
	"difficulty_very_hard",
	"difficulty_overkill",
	"difficulty_mayhem",
	"difficulty_death_wish",
	"difficulty_death_sentence"
}

local function difficulty_sort(lhs, rhs)
	return (table.index_of(difficulty_order, lhs) or 999) < (table.index_of(difficulty_order, rhs) or 998)
end

local function alphabetical_sort(lhs, rhs)
	return lhs < rhs
end

local difficulty_translate = {
	difficulty_death_wish = "menu_difficulty_apocalypse",
	difficulty_death_sentence = "menu_difficulty_sm_wish",
	difficulty_normal = "menu_difficulty_normal",
	difficulty_hard = "menu_difficulty_hard",
	difficulty_very_hard = "menu_difficulty_very_hard",
	difficulty_overkill = "menu_difficulty_overkill",
	difficulty_mayhem = "menu_difficulty_easy_wish"
}

local function create_difficulty_text(str)
	return difficulty_translate[str]
end

local function create_contract_text(str)
	local id = string.sub(str, 11)
	local data = tweak_data.narrative.contacts[id]

	if data then
		return data.name_id
	end

	return create_tag_text(str)
end

MenuNodeAchievementFilterGui = MenuNodeAchievementFilterGui or class(MenuNodeGui)

function MenuNodeAchievementFilterGui:init(node, layer, parameters)
	Global.achievements_filters = Global.achievements_filters or {}
	local filters = Global.achievements_filters
	filters.tags = filters.tags or {}
	local tags = tweak_data.achievement.tags
	local sort_orders = {
		{
			value = "default",
			text_id = "menu_default",
			_meta = "option"
		},
		{
			value = "alphabetical",
			text_id = "menu_sort_alphabetic",
			_meta = "option"
		},
		{
			value = "chronological",
			text_id = "menu_sort_chronologic",
			_meta = "option"
		},
		{
			value = "progress",
			text_id = "menu_sort_progress",
			_meta = "option"
		}
	}

	node:clean_items()

	local n = MenuNodeAchievementFilterCreator:new()

	n:create_divider(node, {
		name = "title_dummy",
		size = medium_font_size + 10
	})
	n:create_toggle(node, {
		help_id = "menu_achievements_hide_unlocked_help",
		name = "toggle_unlocked",
		enabled = true,
		text_id = "menu_achievements_hide_unlocked"
	}):set_value(filters.hide_unlocked and "on" or "off")
	n:create_toggle(node, {
		help_id = "menu_achievements_hide_ladder_help",
		name = "toggle_ladder",
		enabled = true,
		text_id = "menu_achievements_hide_ladder"
	}):set_value(filters.hide_ladder and "on" or "off")
	n:create_multichoice(node, sort_orders, {
		help_id = "menu_achievements_sort_order_help",
		name = "sort_order",
		enabled = true,
		text_id = "menu_achievements_sort_order"
	}):set_value(filters.sort_order or "default")
	node:set_default_item_name("toggle_unlocked")
	n:create_divider(node, {
		size = 24,
		name = "divider_top"
	})

	self._tags_bidnings = {
		progress = n:create_tags_option(node, "progress", create_tag_text, alphabetical_sort),
		contracts = n:create_tags_option(node, "contracts", create_contract_text, alphabetical_sort),
		difficulty = n:create_tags_option(node, "difficulty", create_difficulty_text, difficulty_sort),
		unlock = n:create_tags_option(node, "unlock", create_tag_text, alphabetical_sort),
		tactics = n:create_tags_option(node, "tactics", create_tag_text, alphabetical_sort),
		inventory = n:create_tags_option(node, "inventory", create_tag_text, alphabetical_sort),
		teamwork = n:create_tags_option(node, "teamwork", create_tag_text, alphabetical_sort)
	}

	n:create_divider(node, {
		size = 24,
		name = "divider_bottom"
	})

	if managers.menu:is_pc_controller() then
		n:create_divider(node, {
			name = "buttons_div",
			size = medium_font_size + 5
		})
	end

	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true
	parameters.hide_bg = false
	parameters._align_line_proportions = 0.5

	MenuNodeAchievementFilterGui.super.init(self, node, layer, parameters)

	local create_params = node:parameters().create_params[1]
	self._on_filters_clbk = create_params.on_filters_done or function ()
	end
	self._calc_filter_num = create_params.calc_filter_num or function ()
		return 0
	end
	self._extra_panel = ExtendedPanel:new(self.item_panel, {
		layer = 151
	})
	local title_dummy = self:row_item_by_name("title_dummy").gui_panel
	self._title_help = LeftRightText:new(self._extra_panel, {
		font = medium_font,
		font_size = medium_font_size,
		right = {
			font = small_font,
			font_size = small_font_size
		},
		w = title_dummy:w()
	}, "ACHIEVEMENTS", " ")

	self._title_help:set_lefttop(title_dummy:lefttop())

	local top_div = self:row_item_by_name("divider_top").gui_panel
	local bot_div = self:row_item_by_name("divider_bottom").gui_panel
	local corners = self._extra_panel:panel()

	corners:set_w(top_div:w())
	corners:set_h(bot_div:y() - top_div:y())
	corners:set_lefttop(top_div:lefttop())
	corners:move(0, 12)
	BoxGuiObject:new(corners, {
		sides = {
			1,
			1,
			2,
			2
		}
	})

	if managers.menu:is_pc_controller() then
		local buttons_div = self:row_item_by_name("buttons_div").gui_panel
		local back = TextButton:new(self._extra_panel, {
			input = true,
			text_id = "menu_back",
			font = medium_font,
			font_size = medium_font_size
		}, function ()
			managers.menu:back()
		end)

		back:set_righttop(buttons_div:righttop())

		local hide = TextButton:new(self._extra_panel, {
			text_id = "menu_achievements_clear_filter_btn",
			binding = "menu_clear",
			input = true,
			font = medium_font,
			font_size = medium_font_size
		}, callback(self, self, "_clear_tags"))

		hide:set_lefttop(buttons_div:lefttop())
	else
		SpecialButtonBinding:new("menu_clear", callback(self, self, "_clear_tags"), self._extra_panel)
	end
end

function MenuNodeAchievementFilterGui:close(...)
	MenuNodeAchievementFilterGui.super.close(self, ...)
	self._on_filters_clbk()
end

function MenuNodeAchievementFilterGui:_clear_tags()
	for _, item in pairs(self._tags_bidnings) do
		item:set_value(nil)
	end
end

function MenuNodeAchievementFilterGui:update(...)
	MenuNodeAchievementFilterGui.super.update(self, ...)

	Global.achievements_filters.hide_unlocked = self.node:item("toggle_unlocked"):value() == "on"
	Global.achievements_filters.hide_ladder = self.node:item("toggle_ladder"):value() == "on"
	Global.achievements_filters.sort_order = self.node:item("sort_order"):value()
	Global.achievements_filters.tags = Global.achievements_filters.tags or {}

	for k, item in pairs(self._tags_bidnings) do
		Global.achievements_filters.tags[k] = item:value()
	end

	self._title_help:set_left(managers.localization:text("menu_filter_achievement_count", {
		COUNT = self._calc_filter_num()
	}))
end

function MenuNodeAchievementFilterGui:_set_help_text(text_id, localize)
	local text = text_id or ""

	if localize then
		text = managers.localization:text(text)
	end

	self._title_help:set_right(text)
end

function MenuNodeAchievementFilterGui:_setup_item_panel(safe_rect, res)
	MenuNodeAchievementFilterGui.super._setup_item_panel(self, safe_rect, res)
	self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions))
	self.item_panel:set_center(self.item_panel:parent():w() / 2, self.item_panel:parent():h() / 2)

	local static_y = self.static_y and safe_rect.height * self.static_y

	if static_y and static_y < self.item_panel:y() then
		self.item_panel:set_y(static_y)
	end

	self.item_panel:set_position(math.round(self.item_panel:x()), math.round(self.item_panel:y()))

	if alive(self.box_panel) then
		self.item_panel:parent():remove(self.box_panel)

		self.box_panel = nil
	end

	self.box_panel = self.item_panel:parent():panel()

	self.box_panel:set_x(self.item_panel:x())
	self.box_panel:set_w(self.item_panel:w())
	self.box_panel:set_y(self.item_panel:top())
	self.box_panel:set_h(self.item_panel:h())
	self.box_panel:grow(20, 20)
	self.box_panel:move(-10, -10)
	self.box_panel:set_layer(151)

	self.boxgui = BoxGuiObject:new(self.box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self.boxgui:set_layer(self.item_panel:layer() + 50)
	self.box_panel:rect({
		alpha = 0.6,
		color = Color.black
	})
	self:_set_topic_position()
end

function MenuNodeAchievementFilterGui:reload_item(item)
	MenuNodeAchievementFilterGui.super.reload_item(self, item)

	local row_item = self:row_item(item)

	if row_item and alive(row_item.gui_panel) then
		row_item.gui_panel:set_halign("right")
		row_item.gui_panel:set_right(self.item_panel:w())
	end
end

function MenuNodeAchievementFilterGui:_align_marker(row_item)
	MenuNodeAchievementFilterGui.super._align_marker(self, row_item)

	if row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_world_right(row_item.gui_panel:world_right())

		return
	end

	self._marker_data.marker:set_world_right(self.item_panel:world_right())
end

function MenuNodeAchievementFilterGui:mouse_moved(o, x, y)
	return self._extra_panel:mouse_moved(o, x, y)
end

function MenuNodeAchievementFilterGui:mouse_clicked(button, x, y)
	return self._extra_panel:mouse_clicked(nil, button, x, y)
end

function MenuNodeAchievementFilterGui:special_btn_pressed(...)
	return self._extra_panel:special_btn_pressed(...)
end
