require("lib/managers/menu/ExtendedUiElemets")
require("lib/managers/menu/AchievementDetailGui")
require("lib/managers/menu/AchievementRecentListGui")
require("lib/managers/menu/AchievementMilestoneGui")
require("lib/managers/menu/AchievementMilestoneRewardGui")

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
LeftRightText = LeftRightText or class(ExtendedPanel)

function LeftRightText:init(parent, config, left_text, right_text)
	LeftRightText.super.init(self, parent, config)

	local left_config = config.left or {}
	local right_config = config.right or {}
	left_config.text = left_config.text or left_text
	right_config.text = right_config.text or right_text
	right_config.align = right_config.align or "right"

	for key, var in pairs(config) do
		if key ~= "left" or key ~= "right" then
			left_config[key] = left_config[key] or var
			right_config[key] = right_config[key] or var
		end
	end

	self._left = self:text(left_config)
	self._right = self:text(right_config)

	if not left_config.h then
		self:_update_height(self._left)
	end

	if not right_config.h then
		self:_update_height(self._right)
	end

	if not config.h then
		self:set_h(math.max(self._left:h(), self._right:h()))
	end

	if not config.dont_align_row then
		local bottom = math.max(self._left:bottom(), self._right:bottom())

		self._left:set_bottom(bottom)
		self._right:set_bottom(bottom)
	end
end

function LeftRightText:_update_height(text)
	local _, _, _, h = text:text_rect()

	text:set_h(h)
end

function LeftRightText:set_left(text)
	self._left:set_text(text)
end

function LeftRightText:set_right(text)
	self._right:set_text(text)
end

function LeftRightText:left_item()
	return self._left
end

function LeftRightText:right_item()
	return self._right
end

function LeftRightText:set_texts(left, right)
	if left then
		self:set_left(left)
	end

	if right then
		self:set_right(right)
	end
end

AchievementButton = AchievementButton or class(BaseButton)
AchievementButton.N_COLOR = Color(255, 30, 105, 150) / 255
AchievementButton.H_COLOR = Color(255, 105, 230, 255) / 255
AchievementButton.S_COLOR = Color.white

function AchievementButton:init(parent, id, info, icon, small_icon, on_trigger)
	AchievementButton.super.init(self, parent, {
		input = true
	})

	self._select_panel = ExtendedPanel:new(self)
	self._id = id
	self._info = info
	self._on_trigger_clbk = on_trigger or function ()
	end
	self._button = self._select_panel:bitmap({
		texture = "guis/dlcs/trk/textures/pd2/star_button",
		color = self.N_COLOR
	})
	self._button_icon = self._select_panel:bitmap({
		texture = small_icon,
		color = self.S_COLOR,
		layer = self:layer() + 1
	})
	self._icon = self:bitmap({
		texture = icon,
		color = self.N_COLOR
	})

	self._icon:set_visible(self._info.forced)
	self:set_size(self._button:size())
end

function AchievementButton:_selected_changed(state)
	self._selected = state
end

function AchievementButton:_trigger()
	self._on_trigger_clbk(self._id, self)
	self:_post_trigger()
end

function AchievementButton:_post_trigger()
end

function AchievementButton:allow_input()
	return (self._icon:visible() or self._select_panel:visible()) and AchievementButton.super.allow_input(self)
end

function AchievementButton:_hover_changed(hover)
	if self._selected then
		self._button:set_color(hover and self.H_COLOR or self.N_COLOR)
		self._icon:set_color(hover and self.H_COLOR or self.N_COLOR)
	end
end

AchievementForceButton = AchievementForceButton or class(AchievementButton)

function AchievementForceButton:init(parent, id, info, on_trigger)
	AchievementForceButton.super.init(self, parent, id, info, "guis/dlcs/trk/textures/pd2/eye", "guis/dlcs/trk/textures/pd2/eye_small", on_trigger)
end

function AchievementForceButton:_selected_changed(state)
	AchievementForceButton.super._selected_changed(self, state)

	local num_forced = #managers.achievment:get_force_tracked()

	self._select_panel:set_visible(state and self._info.tracked and not self._info.forced and num_forced < managers.achievment.MAX_TRACKED)
	self._icon:set_visible(self._info.forced)
end

function AchievementForceButton:_post_trigger()
	local num_forced = #managers.achievment:get_force_tracked()

	self._select_panel:set_visible(self._info.tracked and not self._info.forced and num_forced < managers.achievment.MAX_TRACKED)
	self._icon:set_visible(self._info.forced)
end

AchievementTrackButton = AchievementTrackButton or class(AchievementButton)

function AchievementTrackButton:init(parent, id, info, on_trigger)
	AchievementTrackButton.super.init(self, parent, id, info, "guis/dlcs/trk/textures/pd2/star", "guis/dlcs/trk/textures/pd2/star_small", on_trigger)
	self:_post_trigger()
end

function AchievementTrackButton:_selected_changed(state)
	AchievementTrackButton.super._selected_changed(self, state)
	self._select_panel:set_visible(state and not self._info.tracked)
	self._icon:set_visible(self._info.tracked)
end

function AchievementTrackButton:_post_trigger()
	self._select_panel:set_visible(not self._info.tracked)
	self._icon:set_visible(self._info.tracked)
end

AchievementListItem = AchievementListItem or class(ListItem)
AchievementListItem.HEIGHT = 70
AchievementListItem.ND_COLOR = Color(255, 95, 95, 95) / 255
AchievementListItem.NT_SD_COLOR = tweak_data.screen_colors.achievement_grey
AchievementListItem.ST_COLOR = Color.white

function AchievementListItem:init(parent, data, owner)
	AchievementListItem.super.init(self, parent, {
		input = true,
		h = self.HEIGHT,
		w = parent:row_w()
	})

	local id = data.key
	local visual = data.data
	local info = data.info
	self._owner = owner
	self._id = id
	self._visual = visual
	self._info = info or {}
	self._data = data
	self._select_panel = self._panel:panel({
		layer = self:layer() - 1
	})

	BoxGuiObject:new(self._select_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})

	self._highlight = self._panel:rect({
		color = Color(40, 30, 105, 150) / 255,
		layer = self:layer() - 1,
		visible = self._info.forced == true
	})
	local texture, texture_rect = tweak_data.hud_icons:get_icon_or(visual.icon_id, "guis/dlcs/unfinished/textures/placeholder")
	local bitmap = self._panel:bitmap({
		w = 50,
		h = 50,
		texture = texture,
		texture_rect = texture_rect
	})

	bitmap:set_center(self.HEIGHT / 2, self.HEIGHT / 2)

	local awarded = self._info.awarded

	if not awarded then
		bitmap:set_color(Color.white:with_alpha(0.1))

		local lock = self._panel:bitmap({
			texture = "guis/dlcs/trk/textures/pd2/lock",
			w = bitmap:w(),
			h = bitmap:h()
		})
		local cx, cy = bitmap:center()

		lock:set_center(math.round(cx + bitmap:w() * 0.5 - 10), math.round(cy + bitmap:h() * 0.5 - 10))
	end

	local left = self:w() - 32 - 16

	if visual.unlock_id then
		local texture = awarded and "guis/dlcs/trk/textures/pd2/unlocked" or "guis/dlcs/trk/textures/pd2/locked"
		local safe = self:bitmap({
			w = 32,
			h = 32,
			texture = texture,
			x = left
		})

		safe:set_center_y(self.HEIGHT / 2)
	end

	left = left - 6

	if awarded then
		local date = self:fine_text({
			align = "right",
			text = os.date("%d %b %Y\n%H:%M", self._info.unlock_time),
			font = small_font,
			font_size = small_font_size,
			color = self.NT_SD_COLOR
		})

		date:set_right(left)
		date:set_center_y(self:h() / 2)
	else
		self._track = AchievementTrackButton:new(self, self._id, self._info, callback(self, self, "_on_toggle_tracked"))

		self._track:set_right(left)
		self._track:set_center_y(self:h() / 2)

		left = self._track:left() - 4
		self._force = AchievementForceButton:new(self, self._id, self._info, callback(self, self, "_on_force"))

		self._force:set_center_y(self:h() / 2)
		self._force:set_right(left)

		left = self._force:left() - 4
	end

	self._click = self:panel()

	self._click:set_w(left - 10)

	local title_str = managers.localization:text(visual.name_id)
	self._title = self:fine_text({
		y = 5,
		text = title_str,
		font = medium_font,
		font_size = medium_font_size,
		color = self.NT_SD_COLOR,
		x = self.HEIGHT
	})
	local desc_str = managers.localization:text(visual.desc_id)
	self._desc = self:text({
		wrap = true,
		word_wrap = true,
		text = desc_str,
		font = tiny_font,
		font_size = tiny_font_size,
		color = self.ND_COLOR,
		x = self._title:x(),
		y = self._title:bottom() + 2,
		w = left - 170
	})
	local progress = self._visual.progress
	local have_progress = not awarded and progress
	local max_breaks = have_progress and 2 or 3
	local line_breaks = self._desc:line_breaks()
	local remove_line_only = true

	while max_breaks <= #line_breaks do
		local str = self._desc:text()

		if remove_line_only then
			str = utf8.sub(str, 1, line_breaks[max_breaks] - 1) .. "..."
			remove_line_only = false
		else
			str = utf8.sub(str, 1, line_breaks[max_breaks] - 4) .. "..."
		end

		self._desc:set_text(str)

		line_breaks = self._desc:line_breaks()
	end

	self.make_fine_text(self._desc)

	if have_progress then
		local current = progress.get()

		if type(current) ~= "number" then
			current = 0
		end

		local bar = TextProgressBar:new(self, {
			w = 300,
			h = 12,
			back_color = Color(255, 60, 60, 65) / 255,
			max = type(progress.max) == "function" and progress:max() or progress.max
		}, {
			font = tiny_font,
			font_size = tiny_font_size
		}, current)

		bar:set_left(self._desc:left())
		bar:set_top(self._desc:bottom() + 3)
	end

	self:_selected_changed(false)
end

function AchievementListItem:toggle_tracked()
	if self._track and self._track:allow_input() then
		self._track:_trigger()
	end
end

function AchievementListItem:_on_toggle_tracked()
	managers.achievment:track(self._id, not self._info.tracked)
	self._highlight:set_visible(self._info.forced)
	self._owner:update_detail()
	self:_selected_changed(self._select_panel:visible())
end

function AchievementListItem:sort_item()
	return self._data
end

function AchievementListItem:toggle_force()
	if self._force then
		self._force:_trigger()
	end
end

function AchievementListItem:_on_force()
	managers.achievment:force_track(self._id, not self._info.forced)
	self._highlight:set_visible(self._info.forced)
	self._owner:update_detail()
	self:_selected_changed(self._select_panel:visible())
end

function AchievementListItem:_selected_changed(state)
	self._select_panel:set_visible(state)
	self._title:set_color(state and self.ST_COLOR or self.NT_SD_COLOR)
	self._desc:set_color(state and self.NT_SD_COLOR or self.ND_COLOR)

	if self._track then
		self._track:_selected_changed(state)
	end

	if self._force then
		self._force:_selected_changed(state)
	end
end

function AchievementListItem:mouse_clicked(o, button, x, y)
	if button == Idstring("0") and self._click:inside(x, y) then
		tag_print("Achivement", self._id)
		self._owner:_on_preview()

		return true
	end

	AchievementListItem.super.mouse_clicked(self, o, button, x, y)
end

ToggleInputPanel = ToggleInputPanel or class(ExtendedPanel)

function ToggleInputPanel:init(...)
	ToggleInputPanel.super.init(self, ...)

	self.enabled = true
end

function ToggleInputPanel:allow_input()
	return ToggleInputPanel.super.allow_input(self) and self.enabled
end

function add_achievement_detail_text(scroll, placer, visual, info, font_color)
	if not visual then
		return
	end

	local canvas = scroll:canvas()

	placer:add_row(canvas:fine_text({
		wrap = true,
		word_wrap = true,
		text = managers.localization:text(visual.desc_id),
		font = tiny_font,
		font_size = tiny_font_size,
		color = font_color,
		w = canvas:row_w()
	}))

	if visual.additional_id then
		placer:add_row(canvas:fine_text({
			wrap = true,
			word_wrap = true,
			text = managers.localization:text(visual.additional_id),
			font = tiny_font,
			font_size = tiny_font_size,
			color = font_color,
			w = canvas:row_w()
		}))
	end

	if visual.unlock_id then
		placer:add_row(canvas:fine_text({
			wrap = true,
			word_wrap = true,
			text = managers.localization:text(visual.unlock_id),
			font = tiny_font,
			font_size = tiny_font_size,
			color = font_color,
			w = canvas:row_w()
		}))
	end

	local ICON_SIZE = 52
	local icons = visual.unlock_icons

	if icons then
		placer:new_row(nil, 15)

		for _, data in pairs(icons) do
			local texture, rect = tweak_data.hud_icons:get_icon_or(data.texture, data.texture, data.texture_rect)
			local i = canvas:fit_bitmap({
				texture = data.texture,
				texture_rect = rect,
				w = ICON_SIZE,
				h = ICON_SIZE,
				render_template = data.render_template
			})

			if i:h() < i:w() * 1.5 then
				canvas.make_bitmap_fit(i, ICON_SIZE * 2, ICON_SIZE)
			end

			if canvas:w() < i:w() + placer:current_right() then
				placer:new_row(nil, 0)
			end

			placer:add_right(i, ICON_SIZE < placer:current_right() and 0)
		end
	end

	local progress = visual.progress

	if progress and progress.is_list and not info.awarded then
		local todo = progress.get_todo_list()
		local text = nil

		for _, id in pairs(todo) do
			local job_data = tweak_data.narrative:job_data(id)

			if not job_data then
				error("CAN'T GET JOB DATA!")

				break
			end

			if not text then
				text = managers.localization:text("menu_achievements_levels_left_intro") .. managers.localization:text(job_data.name_id)
			else
				text = text .. ", " .. managers.localization:text(job_data.name_id)
			end
		end

		if text then
			placer:add_row(canvas:fine_text({
				wrap = true,
				word_wrap = true,
				text = text,
				font = tiny_font,
				font_size = tiny_font_size,
				color = font_color,
				w = canvas:row_w()
			}))
		end
	end

	if scroll:h() < canvas:h() and canvas:h() < scroll:h() + 10 then
		scroll:resize_canvas(nil, scroll:h())
	end
end

AchievementSortPicker = AchievementSortPicker or class(ExtendedPanel)

function AchievementSortPicker:init(parent, on_change)
	AchievementSortPicker.super.init(self, parent, {
		input = true
	})
	self:set_size(0, 0)

	local placer = ResizingPlacer:new(self, {
		padding = 10
	})
	local strings = {
		default = "menu_default",
		alphabetical = "menu_sort_alphabetic",
		chronological = "menu_sort_chronologic",
		progress = "menu_sort_progress"
	}
	local order = {
		"default",
		"alphabetical",
		"chronological",
		"progress"
	}

	for k, id in pairs(strings) do
		strings[k] = managers.localization:to_upper_text("menu_achievements_sort_order_picker", {
			SORT = managers.localization:text(id)
		})
	end

	Global.achievements_filters = Global.achievements_filters or {
		sort_order = "default"
	}
	local current_id = Global.achievements_filters.sort_order
	self._items = {}
	self._on_change = on_change
	local current_index = 1
	local max_w = 200

	for _, id in pairs(order) do
		local t = self:fine_text({
			align = "center",
			text = strings[id],
			font = small_font,
			font_size = small_font_size,
			color = tweak_data.screen_colors.button_stage_2
		})

		table.insert(self._items, {
			item = t,
			value = id,
			index = #self._items + 1
		})

		max_w = math.max(max_w, t:w())

		if id == current_id then
			current_index = #self._items
		end
	end

	for _, t in pairs(self._items) do
		t.item:set_w(max_w)
		t.item:set_visible(false)
	end

	self:_set_current(self._items[current_index], true)

	local current = self._current.item
	local normal_color = tweak_data.screen_colors.button_stage_3
	local hover_color = tweak_data.screen_colors.button_stage_2

	if not managers.menu:is_pc_controller() then
		placer:add_right(IconButton:new(self, {
			texture = "guis/textures/menu_arrows",
			size = 32,
			binding = "previous_page",
			normal_color = normal_color,
			hover_color = hover_color,
			texture_rect = {
				0,
				0,
				24,
				24
			}
		}, callback(self, self, "_prev")), 20)
		placer:add_right(self:fine_text({
			text = managers.localization:btn_macro("previous_page", true),
			font = small_font,
			font_size = small_font_size,
			color = Color.white
		}), 0)
		placer:add_right_center(current)
		placer:add_right(self:fine_text({
			text = managers.localization:btn_macro("next_page", true),
			font = small_font,
			font_size = medium_font_size,
			color = Color.white
		}))
		placer:add_right(IconButton:new(self, {
			texture = "guis/textures/menu_arrows",
			size = 32,
			rotation = 180,
			binding = "next_page",
			normal_color = normal_color,
			hover_color = hover_color,
			texture_rect = {
				0,
				0,
				24,
				24
			}
		}, callback(self, self, "_next")), 0)
	else
		placer:add_right(IconButton:new(self, {
			texture = "guis/textures/menu_arrows",
			size = 32,
			rotation = 360,
			normal_color = normal_color,
			hover_color = hover_color,
			texture_rect = {
				0,
				0,
				24,
				24
			}
		}, callback(self, self, "_prev")))
		placer:add_right_center(current)
		placer:add_right(IconButton:new(self, {
			texture = "guis/textures/menu_arrows",
			size = 32,
			rotation = 180,
			normal_color = normal_color,
			hover_color = hover_color,
			texture_rect = {
				0,
				0,
				24,
				24
			}
		}, callback(self, self, "_next")))
	end

	for _, t in pairs(self._items) do
		t.item:set_position(current:position())
	end

	self._bg = self:rect({
		layer = -1,
		color = Color.black:with_alpha(0.25)
	})

	BoxGuiObject:new(self, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
end

function AchievementSortPicker:mouse_moved(...)
	local hit, icon = AchievementSortPicker.super.mouse_moved(self, ...)

	self._bg:set_color(hit and tweak_data.screen_colors.button_stage_2:with_alpha(0.2) or Color.black:with_alpha(0.25))

	return hit, icon
end

function AchievementSortPicker:_set_current(item, no_callback)
	if self._current then
		self._current.item:set_visible(false)
	end

	self._current = item

	if self._current then
		self._current.item:set_visible(true)

		if Global.achievements_filters.sort_order ~= item.value and not no_callback then
			Global.achievements_filters.sort_order = item.value

			self._on_change()
		end
	end
end

function AchievementSortPicker:_next()
	local i = (self._current and self._current.index or 1) + 1

	if i > #self._items then
		i = 1
	end

	self:_set_current(self._items[i])
end

function AchievementSortPicker:_prev()
	local i = (self._current and self._current.index or 1) - 1

	if i <= 0 then
		i = #self._items
	end

	self:_set_current(self._items[i])
end

function AchievementSortPicker:refresh()
	Global.achievements_filters = Global.achievements_filters or {
		sort_order = "default"
	}
	local current_id = Global.achievements_filters.sort_order

	for _, t in pairs(self._items) do
		if t.value == current_id then
			self:_set_current(t)
		end
	end
end

AchievementListGui = AchievementListGui or class(ExtendedPanel)
AchievementListGui.ADD_PER_UPDATE = 20

function AchievementListGui:init(ws, fullscreen_ws, node)
	if AchievementListGui.panel_crash_protection then
		AchievementListGui.panel_crash_protection:remove_self()
	end

	AchievementListGui.super.init(self, ws:panel())

	AchievementListGui.panel_crash_protection = self

	managers.achievment:_update_current_milestone()

	self._ws = ws
	self._main_panel = ToggleInputPanel:new(self, {
		input = true
	})

	if not managers.menu:is_pc_controller() then
		self._legends = TextLegendsBar:new(self._main_panel, nil, {
			w = 800,
			wrap = true
		})

		self._legends:add_items({
			"menu_legend_back",
			"menu_legend_scroll_left_right"
		})
	else
		self._legends = ButtonLegendsBar:new(self._main_panel, nil, {
			w = 800,
			wrap = true
		})
	end

	self._legends:add_items({
		{
			binding = "menu_toggle_tracked",
			text_id = "menu_legend_track_achievement",
			func = callback(self, self, "_on_toggle_tracked")
		},
		{
			macro_name = "BTN_Y",
			binding = "menu_preview_achievement",
			text_id = "menu_legend_preview",
			func = callback(self, self, "_on_preview")
		},
		{
			binding = "menu_favorite_achievement",
			text_id = "menu_legend_forced",
			func = callback(self, self, "_on_force")
		},
		{
			binding = "menu_unlocked_achievement",
			text_id = "menu_legend_toggle_unlocked",
			func = callback(self, self, "_on_toggle_unlocked")
		},
		{
			id = "show_tracked",
			binding = "menu_toggle_show_tracked",
			text_id = "menu_legend_achievements_track_btn",
			func = callback(self, self, "_show_tracked")
		},
		{
			enabled = false,
			text_id = "menu_legend_achievements_all_btn",
			id = "show_all",
			binding = "menu_toggle_show_tracked",
			func = callback(self, self, "_show_all")
		}
	})
	self._legends:set_righttop(self:righttop())

	local title_text = self._main_panel:text({
		layer = 1,
		text = managers.localization:to_upper_text("menu_achievements"),
		font = large_font,
		font_size = large_font_size,
		color = tweak_data.screen_colors.text
	})

	ExtendedPanel.make_fine_text(title_text)

	local t_y = title_text:bottom() + 20
	self._scroll = ScrollItemList:new(self._main_panel, {
		scrollbar_padding = 10,
		input_focus = true,
		w = 840,
		bar_minimum_size = 16,
		input = true,
		padding = 0,
		y = t_y,
		h = self._main_panel:h() - t_y - 50
	}, {
		padding = 0
	})

	self._scroll:add_lines_and_static_down_indicator()

	self._sort_item = AchievementSortPicker:new(self, callback(self, self, "_redo_sort"))

	self._sort_item:set_top(self._scroll:bottom() + 2)
	self._sort_item:set_world_right(self._scroll:canvas():world_right())

	local canvas = self._scroll:canvas()
	local b_placer = UiPlacer:new(canvas:world_right(), self._scroll:top() - 26, 5)
	local num_forced = #managers.achievment:get_force_tracked()
	self._forced_text = b_placer:add_left(self._main_panel:fine_text({
		align = "right",
		text = managers.localization:text("menu_achievements_forced", {
			CURRENT = num_forced,
			MAX = managers.achievment.MAX_TRACKED
		}),
		font = medium_font,
		font_size = medium_font_size
	}))
	self._force_icon = b_placer:add_left(self._main_panel:fit_bitmap({
		texture = "guis/dlcs/trk/textures/pd2/eye",
		h = self._forced_text:h() - 2,
		color = Color.white
	}))
	local num_fav = table.count(managers.achievment.achievments, function (v)
		return v.tracked
	end)
	self._tracked_text = b_placer:add_left(self._main_panel:fine_text({
		align = "right",
		text = managers.localization:text("menu_achievements_tracking", {
			COUNT = num_fav
		}),
		font = medium_font,
		font_size = medium_font_size
	}), 30)
	self._tracked_icon = b_placer:add_left(self._main_panel:fit_bitmap({
		texture = "guis/dlcs/trk/textures/pd2/star",
		h = self._forced_text:h() - 2,
		color = Color.white
	}))
	local b_h = self._scroll:h()
	local b_w = self._scroll:canvas():w()
	local back_panel = self._main_panel:panel({
		layer = -1,
		w = b_w,
		h = b_h
	})

	back_panel:set_lefttop(self._scroll:lefttop())
	back_panel:rect({
		color = Color.black:with_alpha(0.8)
	})

	self._filter_panel = GrowPanel:new(self._main_panel, {
		input = true,
		padding = 10,
		x = self._scroll:right(),
		y = self._scroll:top()
	})

	self._filter_panel:set_fixed_w(self._main_panel:w() - self._filter_panel:left())

	self._detail_scroll = ScrollableList:new(self._main_panel, {
		scrollbar_padding = 4,
		input = true,
		h = 600,
		padding = 0,
		w = self._filter_panel:w()
	}, {
		padding = 10
	})

	if managers.menu:is_pc_controller() then
		local back_btn = TextButton:new(self._main_panel, {
			blend = "add",
			text_id = "menu_back",
			font = medium_font,
			font_size = medium_font_size
		}, function ()
			managers.menu:force_back()
		end)

		back_btn:set_righttop(self._filter_panel:right(), self._scroll:bottom())
	end

	if managers.menu:is_pc_controller() and not self._search then
		local search_panel = self._main_panel:panel({
			alpha = 1,
			layer = 2,
			h = medium_font_size
		})

		search_panel:set_w(256)
		search_panel:set_h(self._sort_item:h())
		search_panel:set_top(self._sort_item:top())
		search_panel:set_right(self._sort_item:left() - 5)

		local search_placeholder = search_panel:text({
			vertical = "top",
			align = "center",
			alpha = 0.6,
			layer = 2,
			text = managers.localization:to_upper_text("menu_filter_search"),
			font = medium_font,
			font_size = medium_font_size,
			color = tweak_data.screen_colors.text
		})
		local search_text = search_panel:text({
			vertical = "top",
			alpha = 1,
			align = "center",
			text = "",
			layer = 2,
			font = medium_font,
			font_size = medium_font_size,
			color = tweak_data.screen_colors.text,
			w = search_panel:w() - 3
		})
		local caret = search_panel:rect({
			name = "caret",
			h = 0,
			y = 0,
			w = 0,
			x = 0,
			layer = 200,
			color = Color(0.05, 1, 1, 1)
		})

		caret:set_right(search_panel:w() * 0.5)
		search_panel:rect({
			layer = -1,
			color = Color.black:with_alpha(0.25)
		})
		BoxGuiObject:new(search_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		self._search = {
			panel = search_panel,
			placeholder = search_placeholder,
			text = search_text,
			caret = caret
		}
	end

	self._all_achievements = {}

	for k, data in pairs(tweak_data.achievement.visual) do
		local info = managers.achievment:get_info(k) or {}

		table.insert(self._all_achievements, {
			key = k,
			data = data,
			info = info,
			title = string.lower(managers.localization:text(data.name_id)),
			desc = string.lower(managers.localization:text(data.desc_id))
		})
	end

	table.sort(self._all_achievements, self.default_order)
	self._scroll:set_selected_callback(callback(self, self, "update_detail"))
	self:clear_and_start_adding()
	WalletGuiObject.set_wallet(self)

	local recent_list = managers.achievment:get_recent_achievements()
	local recent_milestones = managers.achievment:get_recent_milestones()

	if #recent_milestones > 0 then
		local on_done = #recent_list <= 0 and callback(self, self, "_on_popup_done") or function ()
			self:_do_popup(AchievementRecentListGui:new(self, recent_list, callback(self, self, "_on_popup_done")))
		end

		self:_do_popup(AchievementMilestoneRewardGui:new(self, recent_milestones, on_done))
	elseif #recent_list > 0 then
		self:_do_popup(AchievementRecentListGui:new(self, recent_list, callback(self, self, "_on_popup_done")))
	end

	if managers.achievment.handler.friends_achievements_cache and managers.network.account:signin_state() == "signed in" then
		managers.achievment.handler:friends_achievements_cache(function (ok)
			print("[Ach]", "cache result", ok)

			if not ok then
				Application:error("[AchievmentManager:friends_achievements_cache] FAILED!")
			end
		end)
	else
		Application:error("[AchievmentManager:friends_achievements_cache] friends_achievements_cache DOESN'T EXIST!")
	end
end

function AchievementListGui:_toggle_tracked()
	if self._view_tracked then
		self:_show_all()
	else
		self:_show_tracked()
	end
end

function AchievementListGui:_show_tracked()
	self._view_tracked = true

	self:_redo_filter_and_sort()
	self:generate_side_panel()

	if self._track_btn then
		self._track_btn:set_visible(false)
		self._show_all_btn:set_visible(true)
	else
		self._legends:set_item_enabled("show_tracked", false)
		self._legends:set_item_enabled("show_all", true)
	end
end

function AchievementListGui:_show_all()
	self._view_tracked = false

	self:_redo_filter_and_sort()
	self:generate_side_panel()

	if self._track_btn then
		self._show_all_btn:set_visible(false)
		self._track_btn:set_visible(true)
	else
		self._legends:set_item_enabled("show_all", false)
		self._legends:set_item_enabled("show_tracked", true)
	end
end

local function count_done(list)
	local count = 0

	for _, v in pairs(list) do
		count = count + (v.info.awarded and 1 or 0)
	end

	return count
end

function AchievementListGui:generate_side_panel()
	self._filter_panel:clear()

	local placer = self._filter_panel:placer()
	local milestone = managers.achievment:current_milestone()

	if self._view_tracked then
		placer:add_bottom(LeftRightText:new(self._filter_panel, {
			w = self._filter_panel:row_w(),
			font = medium_font,
			font_size = medium_font_size
		}, managers.localization:to_upper_text("menu_tracked_achievements"), string.format("%d / %d", #self._current_list, #self._all_achievements)), 0)
	else
		local font_color = self._filtered and AchievementListItem.ND_COLOR

		placer:add_bottom(LeftRightText:new(self._filter_panel, {
			w = self._filter_panel:row_w(),
			font = medium_font,
			font_size = medium_font_size,
			color = font_color
		}, managers.localization:to_upper_text("menu_total_achievements"), string.format("%d / %d", count_done(self._all_achievements), #self._all_achievements)))

		if self._filtered then
			placer:add_bottom(LeftRightText:new(self._filter_panel, {
				w = self._filter_panel:row_w(),
				font = medium_font,
				font_size = medium_font_size
			}, managers.localization:to_upper_text("menu_filtered_achievements"), string.format("%d / %d", count_done(self._current_list), #self._current_list)), 0)
		elseif milestone then
			local t = placer:add_bottom(LeftRightText:new(self._filter_panel, {
				w = self._filter_panel:row_w(),
				font = medium_font,
				font_size = medium_font_size
			}, managers.localization:to_upper_text("menu_milestone_next_at"), string.format("%d", milestone.at)), 0)
		end

		local current_progress = #self._current_list == 0 and 0 or count_done(self._current_list) / #self._current_list
		local progress = placer:add_bottom(TextProgressBar:new(self._filter_panel, {
			h = 14,
			w = self._filter_panel:row_w(),
			back_color = Color(255, 60, 60, 65) / 255
		}, {
			font = tiny_font,
			font_size = tiny_font_size
		}, current_progress))

		if not self._filtered and milestone then
			for _, m in pairs(managers.achievment:milestones()) do
				if m == milestone then
					local x = progress:x() + progress:w() * m.at / #self._current_list

					self._filter_panel:rect({
						w = 2,
						h = progress:h(),
						color = Color(255, 80, 80, 85) / 255,
						x = x + 1,
						y = progress:y()
					})

					local arrow = self._filter_panel:bitmap({
						texture = "guis/dlcs/ami/textures/pd2/milestone_marker_arrow"
					})

					arrow:set_bottom(progress:top() - 3)
					arrow:set_center_x(x + 2)
				elseif milestone.at < m.at then
					self._filter_panel:rect({
						w = 2,
						h = progress:h(),
						color = Color(255, 80, 80, 85) / 255,
						x = progress:x() + progress:w() * m.at / #self._current_list + 1,
						y = progress:y()
					})
				end
			end
		end

		local r_btn = placer:add_bottom(TextButton:new(self._filter_panel, {
			blend = "add",
			text_id = "menu_achievements_filter_btn",
			binding = "menu_toggle_filters",
			font = small_font,
			font_size = small_font_size
		}, callback(self, self, "open_filter_popup")))
		local l_btn = self._filtered and TextButton:new(self._filter_panel, {
			blend = "add",
			text_id = "menu_achievements_clear_filter_btn",
			binding = "menu_clear",
			font = small_font,
			font_size = small_font_size
		}, callback(self, self, "_clear_filters")) or TextButton:new(self._filter_panel, {
			blend = "add",
			text_id = "menu_milestone_btn",
			binding = "menu_respec_tree_all",
			font = small_font,
			font_size = small_font_size
		}, callback(self, self, "_on_milestone"))

		r_btn:set_right(progress:right())
		l_btn:set_left(progress:left())
		l_btn:set_top(r_btn:top())
	end

	self._filter_panel:rect({
		color = Color.black:with_alpha(0.8),
		layer = self._filter_panel:layer() - 1
	})
	BoxGuiObject:new(self._filter_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self._detail_scroll:set_lefttop(self._filter_panel:leftbottom())
	self._detail_scroll:move(0, 10)
	self._detail_scroll:resize(nil, self._scroll:bottom() - self._detail_scroll:top())

	if self._detail_bg then
		self._detail_bg:clear()
		self._detail_bg:parent():remove(self._detail_bg)
	end

	self._detail_bg = self._detail_scroll:panel()

	self._detail_bg:rect({
		color = Color.black:with_alpha(0.8),
		layer = self._filter_panel:layer() - 1
	})
	BoxGuiObject:new(self._detail_bg, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self:update_detail()
end

function AchievementListGui:update_detail()
	self._detail_scroll:clear()

	local canvas = self._detail_scroll:canvas()
	local placer = canvas:placer()
	local selected = self._scroll:selected_item()

	if not selected then
		return
	end

	local visual = selected._visual
	local info = selected._info
	local texture, texture_rect = tweak_data.hud_icons:get_icon_or(visual.icon_id, "guis/dlcs/unfinished/textures/placeholder")
	local bitmap = placer:add_row(canvas:bitmap({
		w = 80,
		h = 80,
		texture = texture,
		texture_rect = texture_rect
	}))
	local awarded = info and info.awarded

	if not awarded then
		bitmap:set_color(Color.white:with_alpha(0.1))

		local lock = canvas:bitmap({
			texture = "guis/dlcs/trk/textures/pd2/lock"
		})
		local cx, cy = bitmap:center()

		lock:set_center(math.round(cx + bitmap:w() * 0.5 - 10), math.round(cy + bitmap:h() * 0.5 - 10))
	end

	placer:add_right(canvas:fine_text({
		word_wrap = true,
		wrap = true,
		text = managers.localization:text(visual.name_id),
		font = medium_font,
		font_size = medium_font_size,
		w = canvas:row_w() - placer:current_right()
	}))

	local extra_text = nil

	if info.forced then
		extra_text = "menu_achievements_forced_notify"
	elseif info.tracked then
		extra_text = "menu_achievements_tracking_notify"
	end

	if extra_text then
		placer:add_bottom(canvas:fine_text({
			keep_w = true,
			text_id = extra_text,
			font = small_font,
			font_size = small_font_size,
			color = tweak_data.screen_colors.achievement_grey
		}), 0)
	end

	add_achievement_detail_text(self._detail_scroll, placer, visual, info)
end

function AchievementListGui:update(...)
	self:keep_filling_list()

	if not self._scroll:selected_item() and #self._scroll:items() > 0 then
		self._scroll:select_index(1)
		self:update_detail()
	end

	if not self._main_panel.enabled then
		if self._popup and self._popup.update then
			self._popup:update(...)
		end

		return
	end

	local num_forced = #managers.achievment:get_force_tracked()
	local tracked = num_forced < managers.achievment.MAX_TRACKED

	self._forced_text:set_text(managers.localization:text("menu_achievements_forced", {
		CURRENT = num_forced,
		MAX = managers.achievment.MAX_TRACKED
	}))
	ExtendedPanel.make_fine_text(self._forced_text)

	local placer = UiPlacer:new(0, 0, 5)

	placer:set_at_from(self._forced_text)
	placer:add_left(self._force_icon)

	local num_fav = table.count(managers.achievment.achievments, function (v)
		return v.tracked
	end)

	self._tracked_text:set_text(managers.localization:text("menu_achievements_tracking", {
		COUNT = num_fav
	}))
	ExtendedPanel.make_fine_text(self._tracked_text)
	placer:add_left(self._tracked_text, 30)
	placer:add_left(self._tracked_icon)

	if not managers.menu:is_pc_controller() and self:allow_input() and self._detail_scroll and (not managers.system_menu or not managers.system_menu:is_active() or not not managers.system_menu:is_closing()) then
		local axis_x, axis_y = managers.menu_component:get_right_controller_axis()

		if axis_y ~= 0 then
			self._detail_scroll:perform_scroll(axis_y)
		end
	end

	if self._track_btn then
		self._track_btn:set_enabled(num_forced > 0)
	end
end

function AchievementListGui:filter(list)
	local func = self:_filter_func()

	if not func then
		return list, false
	end

	return table.filter_list(list, func), true
end

function AchievementListGui:_filter_func()
	local data = Global.achievements_filters or {}
	data.tags = data.tags or {}
	local filters = {}

	if data.hide_unlocked then
		table.insert(filters, function (v)
			return not v.info or not v.info.awarded
		end)
	end

	if data.hide_ladder then
		local ladders_locked = {}

		for k, v in pairs(self._all_achievements) do
			local ladder = v.data.ladder

			if ladder and not v.info.awarded then
				ladders_locked[ladder] = ladders_locked[ladder] or {}

				table.insert(ladders_locked[ladder], v)
			end
		end

		local lowest_locked = {}

		for ladder, list in pairs(ladders_locked) do
			table.sort(list, self.default_order)

			lowest_locked[ladder] = list[1]
		end

		table.insert(filters, function (v)
			if not v.info.awarded then
				return not v.data.ladder or lowest_locked[v.data.ladder] == v
			else
				return true
			end
		end)
	end

	if data.only_tracked or self._view_tracked then
		table.insert(filters, function (v)
			return v.info and v.info.tracked
		end)
	end

	for category, tag in pairs(data.tags) do
		if tag == false then
			table.insert(filters, function (v)
				return table.true_for_all(v.data.tags, function (t)
					return not string.begins(t, category)
				end)
			end)
		elseif tag == true then
			table.insert(filters, function (v)
				return not table.true_for_all(v.data.tags, function (t)
					return not string.begins(t, category)
				end)
			end)
		else
			table.insert(filters, function (v)
				return table.contains(v.data.tags, tag)
			end)
		end
	end

	if self._search then
		local text = string.lower(self._search.text:text())

		if #text > 0 then
			table.insert(filters, function (v)
				return string.find(v.title, text, nil, true) or string.find(v.desc, text, nil, true)
			end)
		end
	end

	if #filters > 0 then
		return function (v)
			for _, f in ipairs(filters) do
				if not f(v) then
					return false
				end
			end

			return true
		end
	else
		return
	end
end

function AchievementListGui:_get_sort_func(sort_order)
	sort_order = sort_order or Global.achievements_filters and Global.achievements_filters.sort_order
	local sorters = {
		default = self.default_order,
		alphabetical = self.alphabetical_order,
		chronological = self.chronological_order,
		progress = self.progress_order
	}
	local rtn = sorters[sort_order] or self.default_order

	if self._view_tracked then
		rtn = self.create_tracked_then_other_order(rtn)
	end

	return rtn
end

function AchievementListGui:sort(list, order_setting)
	local data = Global.achievements_filters or {}
	local sort = self:_get_sort_func(data.sort_order)

	table.sort(list, sort)
end

function AchievementListGui:clear_and_start_adding()
	local data = Global.achievements_filters or {}
	data.tags = data.tags or {}
	self._filtered = false
	local list = table.list_copy(self._all_achievements)

	self:sort(list)

	self._adding_to_data = table.list_reverse(list)

	self._scroll:clear()

	self._current_list, self._filtered = self:filter(list)

	self:keep_filling_list()
	self:generate_side_panel()
end

function AchievementListGui:_redo_filter_and_sort()
	if self._adding_to_data then
		self:clear_and_start_adding()

		return
	end

	self:_redo_filter()
	self:_redo_sort()
end

function AchievementListGui:_redo_filter()
	self._filtered = false
	local list = self._all_achievements
	self._current_list, self._filtered = self:filter(list)

	self._scroll:filter_items(function (item)
		return table.find_value(self._current_list, function (v)
			return v.key == item._id
		end)
	end, nil, true)
	self:generate_side_panel()
end

function AchievementListGui:_redo_sort()
	if self._adding_to_data then
		self:clear_and_start_adding()

		return
	end

	local func = self:_get_sort_func()

	self._scroll:sort_items(function (lhs, rhs)
		return func(lhs:sort_item(), rhs:sort_item())
	end, nil, true)
end

function AchievementListGui:keep_filling_list()
	if not self._adding_to_data then
		return
	end

	local d = self._adding_to_data
	local canvas = self._scroll:canvas()
	local limit = 0
	local filter = self:_filter_func()

	while self._adding_to_data[1] do
		local v = table.remove(self._adding_to_data)

		self._scroll:add_item(AchievementListItem:new(canvas, v, self), filter and filter(v))

		if self.ADD_PER_UPDATE <= limit then
			return
		end

		limit = limit + 1
	end

	self._adding_to_data = nil
end

function AchievementListGui:close()
	if self._panel then
		self:remove_self()

		self._panel = nil
		AchievementListGui.panel_crash_protection = nil
	end

	if alive(self._blur_ws) then
		self._blur:parent():remove(self._blur)
		managers.gui_data:destroy_workspace(self._blur_ws)

		self._blur_ws = nil
	end

	WalletGuiObject.close_wallet(self)

	if managers.achievment.handler.friends_achievements_clear then
		managers.achievment.handler:friends_achievements_clear()
	else
		Application:error("[AchievmentManager:friends_achievements_clear] friends_achievements_clear DOESN'T EXIST!")
	end
end

function AchievementListGui:show_blur()
	if not alive(self._blur_ws) then
		self._blur_ws = managers.gui_data:create_fullscreen_workspace()
		self._blur = self._blur_ws:panel():panel()
		local blur = self._blur:bitmap({
			texture = "guis/textures/test_blur_df",
			name = "bg",
			valign = "grow",
			render_template = "VertexColorTexturedBlur3D",
			layer = 5
		})

		self._blur:rect({
			blend_mode = "normal",
			name = "bg",
			halign = "grow",
			alpha = 0.1,
			valign = "grow",
			layer = 0,
			color = Color.black
		})
		blur:set_size(self._blur:size())
	end
end

function AchievementListGui:remove_blur()
	if alive(self._blur_ws) then
		self._blur:parent():remove(self._blur)
		managers.gui_data:destroy_workspace(self._blur_ws)

		self._blur_ws = nil
	end
end

function AchievementListGui:_on_preview()
	local selected = self._scroll:selected_item()

	if selected then
		self:_do_popup(AchievementDetailGui:new(self, selected._id, callback(self, self, "_on_popup_done")))
	end
end

function AchievementListGui:_on_force()
	local selected = self._scroll:selected_item()

	if selected then
		selected:toggle_force()
	end
end

function AchievementListGui:_on_toggle_tracked()
	local selected = self._scroll:selected_item()

	if selected then
		selected:toggle_tracked()
	end
end

function AchievementListGui:_on_toggle_unlocked()
	Global.achievements_filters = Global.achievements_filters or {}
	local data = Global.achievements_filters
	data.hide_unlocked = not data.hide_unlocked

	self:_redo_filter()
end

function AchievementListGui:_do_popup(gui)
	if not gui then
		return
	end

	self:_on_popup_done()

	self._main_panel.enabled = false
	self._popup = gui

	self:show_blur()
end

function AchievementListGui:_on_popup_done()
	if self._popup then
		self._popup:close()

		self._popup = nil

		self:remove_blur()
	end

	self._main_panel.enabled = true
end

function AchievementListGui:_on_filters_done()
	self:remove_blur()
	self:_redo_filter_and_sort()

	if self._sort_item then
		self._sort_item:refresh()
	end
end

function AchievementListGui:open_filter_popup()
	managers.menu:open_node("achievements_filter", {
		{
			on_filters_done = callback(self, self, "_on_filters_done"),
			calc_filter_num = function ()
				return self and #self:filter(self._all_achievements)
			end
		}
	})
	self:show_blur()
end

function AchievementListGui:_clear_filters()
	local data = Global.achievements_filters or {}
	data.hide_unlocked = nil
	data.hide_ladder = nil
	data.tags = {}

	self._search.text:set_text("")
	self:update_caret()
	self:_redo_filter()
end

function AchievementListGui.default_order(lhs, rhs)
	return lhs.data.sort_name < rhs.data.sort_name
end

function AchievementListGui.alphabetical_order(lhs, rhs)
	return lhs.title < rhs.title
end

function AchievementListGui.chronological_order(lhs, rhs)
	if lhs.info.unlock_time and rhs.info.unlock_time then
		if lhs.info.unlock_time == rhs.info.unlock_time then
			return AchievementListGui.default_order(lhs, rhs)
		else
			return rhs.info.unlock_time < lhs.info.unlock_time
		end
	end

	if lhs.info.awarded == rhs.info.awarded then
		return AchievementListGui.default_order(lhs, rhs)
	end

	return lhs.info.awarded
end

function AchievementListGui.progress_order(lhs, rhs)
	local lp = lhs.data.progress
	local rp = rhs.data.progress

	if lhs.info.awarded or rhs.info.awarded then
		if lhs.info.awarded == rhs.info.awarded then
			return AchievementListGui.default_order(lhs, rhs)
		else
			return rhs.info.awarded
		end
	elseif lp and rp then
		local lpv = lp.get() / lp.max
		local rpv = rp.get() / rp.max

		if lpv > rpv then
			return true
		elseif lpv == rpv then
			if lp.max == rp.max then
				return AchievementListGui.default_order(lhs, rhs)
			end

			return lp.max < rp.max
		else
			return false
		end
	elseif lp or rp then
		return lp
	else
		return AchievementListGui.default_order(lhs, rhs)
	end
end

function AchievementListGui.create_tracked_then_other_order(other_sort)
	local function func(lhs, rhs)
		if lhs.info.forced or rhs.info.forced then
			if lhs.info.forced == rhs.info.forced then
				return other_sort(lhs, rhs)
			else
				return lhs.info.forced
			end
		end

		return other_sort(lhs, rhs)
	end

	return func
end

function AchievementListGui:allow_input()
	return not alive(self._blur_ws) or self._popup
end

function AchievementListGui:input_focus()
	return self:allow_input() and ((self._popup or self._search_focus) and true or 1)
end

function AchievementListGui:back_pressed()
	if self._search_focus then
		return
	end

	return AchievementListGui.super.back_pressed(self)
end

function AchievementListGui:special_btn_pressed(...)
	if self._search_focus then
		return
	end

	return AchievementListGui.super.special_btn_pressed(self, ...)
end

function AchievementListGui:mouse_clicked(o, button, x, y)
	if button == Idstring("0") and self._search.panel:inside(x, y) then
		self:connect_search_input()

		return true
	elseif self._search_focus then
		self:disconnect_search_input()
	end

	return AchievementListGui.super.mouse_clicked(self, o, button, x, y)
end

function AchievementListGui:_on_milestone()
	self:_do_popup(AchievementMilestoneGui:new(self, callback(self, self, "_on_popup_done")))
end

AchievementListGui.MAX_SEARCH_LENGTH = 28

function AchievementListGui:connect_search_input()
	if self._adding_to_data or self._search_focus then
		return
	end

	self._ws:connect_keyboard(Input:keyboard())

	if _G.IS_VR then
		Input:keyboard():show_with_text(self._search.text:text())
	end

	self._search.panel:key_press(callback(self, self, "search_key_press"))
	self._search.panel:key_release(callback(self, self, "search_key_release"))

	self._enter_callback = callback(self, self, "enter_key_callback")
	self._esc_callback = callback(self, self, "esc_key_callback")
	self._search_focus = true
	self._focus = true

	self:update_caret()
end

function AchievementListGui:disconnect_search_input()
	if self._search_focus then
		self._ws:disconnect_keyboard()
		self._search.panel:key_press(nil)
		self._search.panel:key_release(nil)

		if self._key_pressed then
			self:search_key_release(nil, self._key_pressed)
		end

		self._search_focus = nil
		self._focus = nil

		self:update_caret()
		self:_redo_filter()
	end
end

function AchievementListGui:_setup_change_search()
	self:_redo_filter()
end

function AchievementListGui:search_key_press(o, k)
	if self._skip_first then
		self._skip_first = false

		return
	end

	if not self._enter_text_set then
		self._search.panel:enter_text(callback(self, self, "enter_text"))

		self._enter_text_set = true
	end

	local text = self._search.text
	local s, e = text:selection()
	local n = utf8.len(text:text())
	local d = math.abs(e - s)
	self._key_pressed = k

	text:stop()
	text:animate(callback(self, self, "update_key_down"), k)

	local len = utf8.len(text:text())

	text:clear_range_color(0, len)

	if k == Idstring("backspace") then
		if s == e and s > 0 then
			text:set_selection(s - 1, e)
		end

		text:replace_text("")
		self:enter_text()
	elseif k == Idstring("delete") then
		if s == e and s < n then
			text:set_selection(s, e + 1)
		end

		text:replace_text("")
	elseif k == Idstring("insert") then
		local clipboard = Application:get_clipboard() or ""

		text:replace_text(clipboard)

		local lbs = text:line_breaks()

		if AchievementListGui.MAX_SEARCH_LENGTH < #text:text() then
			text:set_text(string.sub(text:text(), 1, AchievementListGui.MAX_SEARCH_LENGTH))
		end

		if #lbs > 1 then
			local s = lbs[2]
			local e = utf8.len(text:text())

			text:set_selection(s, e)
			text:replace_text("")
		end
	elseif k == Idstring("left") then
		if s < e then
			text:set_selection(s, s)
		elseif s > 0 then
			text:set_selection(s - 1, s - 1)
		end
	elseif k == Idstring("right") then
		if s < e then
			text:set_selection(e, e)
		elseif s < n then
			text:set_selection(s + 1, s + 1)
		end
	elseif self._key_pressed == Idstring("end") then
		text:set_selection(n, n)
	elseif self._key_pressed == Idstring("home") then
		text:set_selection(0, 0)
	elseif k == Idstring("enter") then
		if type(self._enter_callback) ~= "number" then
			self._enter_callback()
		end
	elseif k == Idstring("esc") and type(self._esc_callback) ~= "number" then
		if not _G.IS_VR then
			text:set_text("")
			text:set_selection(0, 0)
		end

		self._esc_callback()
	end

	self:update_caret()
end

function AchievementListGui:search_key_release(o, k)
	if self._key_pressed == k then
		self._key_pressed = false

		self:_setup_change_search()
	end
end

function AchievementListGui:update_key_down(o, k)
	wait(0.6)

	local text = self._search.text

	while self._key_pressed == k do
		local s, e = text:selection()
		local n = utf8.len(text:text())
		local d = math.abs(e - s)

		if self._key_pressed == Idstring("backspace") then
			if s == e and s > 0 then
				text:set_selection(s - 1, e)
			end

			text:replace_text("")
		elseif self._key_pressed == Idstring("delete") then
			if s == e and s < n then
				text:set_selection(s, e + 1)
			end

			text:replace_text("")
		elseif self._key_pressed == Idstring("insert") then
			local clipboard = Application:get_clipboard() or ""

			text:replace_text(clipboard)

			if AchievementListGui.MAX_SEARCH_LENGTH < #text:text() then
				text:set_text(string.sub(text:text(), 1, AchievementListGui.MAX_SEARCH_LENGTH))
			end

			local lbs = text:line_breaks()

			if #lbs > 1 then
				local s = lbs[2]
				local e = utf8.len(text:text())

				text:set_selection(s, e)
				text:replace_text("")
			end
		elseif self._key_pressed == Idstring("left") then
			if s < e then
				text:set_selection(s, s)
			elseif s > 0 then
				text:set_selection(s - 1, s - 1)
			end
		elseif self._key_pressed == Idstring("right") then
			if s < e then
				text:set_selection(e, e)
			elseif s < n then
				text:set_selection(s + 1, s + 1)
			end
		else
			self._key_pressed = false
		end

		self:update_caret()
		wait(0.03)
	end
end

function AchievementListGui:enter_text(o, s)
	if self._skip_first then
		self._skip_first = false

		return
	end

	local text = self._search.text

	if #text:text() < AchievementListGui.MAX_SEARCH_LENGTH then
		if _G.IS_VR then
			text:set_text(s)
		else
			text:replace_text(s)
		end
	end

	local lbs = text:line_breaks()

	if #lbs > 1 then
		local s = lbs[2]
		local e = utf8.len(text:text())

		text:set_selection(s, e)
		text:replace_text("")
	end

	self:update_caret()
	self:_setup_change_search()
end

function AchievementListGui:enter_key_callback()
	self:_setup_change_search()
end

function AchievementListGui:esc_key_callback()
	call_on_next_update(function ()
		self:disconnect_search_input()
	end)
end

function AchievementListGui.blink(o)
	while true do
		o:set_color(Color(0, 1, 1, 1))
		wait(0.3)
		o:set_color(Color.white)
		wait(0.3)
	end
end

function AchievementListGui:set_blinking(b)
	local caret = self._search.caret

	if b == self._blinking then
		return
	end

	if b then
		caret:animate(self.blink)
	else
		caret:stop()
	end

	self._blinking = b

	if not self._blinking then
		caret:set_color(Color.white)
	end
end

function AchievementListGui:update_caret()
	local text = self._search.text
	local caret = self._search.caret
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()
	local text_s = text:text()

	if #text_s == 0 then
		x = text:world_center_x()
		y = text:world_y()
	end

	h = text:h()

	if w < 3 then
		w = 3
	end

	if not self._focus then
		w = 0
		h = 0
	end

	caret:set_world_shape(x, y + 2, w, h - 4)
	self:set_blinking(s == e and self._focus)
	self._search.placeholder:set_visible(not self._focus and #text_s == 0)
end
