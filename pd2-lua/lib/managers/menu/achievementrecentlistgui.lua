require("lib/managers/menu/ExtendedUiElemets")

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
OnPressedTextButton = OnPressedTextButton or class(TextButton)

function OnPressedTextButton:mouse_clicked()
end

function OnPressedTextButton:mouse_pressed(button, x, y)
	if button == Idstring("0") and self._text:inside(x, y) then
		self._trigger()

		return true
	end
end

local AchievementRecentListItem = AchievementRecentListItem or class(GrowPanel)

function AchievementRecentListItem:init(parent, item, black_bg)
	AchievementRecentListItem.super.init(self, parent, {
		border = 10,
		padding = 4,
		fixed_w = parent:w()
	})

	self._visual = tweak_data.achievement.visual[item.id]
	local placer = self:placer()
	local texture, texture_rect = tweak_data.hud_icons:get_icon_or(self._visual.icon_id, "guis/dlcs/unfinished/textures/placeholder")
	local bitmap = placer:add_bottom(self:bitmap({
		w = 50,
		h = 50,
		texture = texture,
		texture_rect = texture_rect
	}))
	local name_text = managers.localization:text(self._visual.name_id)

	placer:add_right(self:fine_text({
		text = name_text,
		font = medium_font,
		font_size = medium_font_size
	}))
	placer:add_bottom(self:fine_text({
		text = managers.localization:text("menu_achievement_unlock_date", {
			DATE = os.date("%d %b %Y %H:%M", item.unlock_time)
		}),
		font = tiny_font,
		font_size = tiny_font_size,
		color = tweak_data.screen_colors.achievement_grey
	}))

	local icons = self._visual.unlock_icons

	if icons then
		local fixed_w = self:w() / 3
		local panel = GrowPanel:new(self, {
			fixed_w = fixed_w
		})
		local g_placer = panel:placer()

		g_placer:set_start(fixed_w)

		local ICON_SIZE = 32

		for _, data in pairs(icons) do
			local texture, rect = tweak_data.hud_icons:get_icon_or(data.texture, data.texture, data.texture_rect)
			local i = panel:fit_bitmap({
				texture = data.texture,
				texture_rect = rect,
				w = ICON_SIZE,
				h = ICON_SIZE,
				render_template = data.render_template
			})

			if i:h() < i:w() * 1.5 then
				panel.make_bitmap_fit(i, ICON_SIZE * 2, ICON_SIZE)
			end

			g_placer:add_left(i)

			if i:x() < 0 then
				g_placer:new_row()
				g_placer:add_left(i)
			end
		end

		panel:set_right(self:w() - 10)

		if self:h() < panel:h() then
			self:set_h(panel:h())
		else
			panel:set_center_y(self:h() / 2)
		end
	end

	if black_bg then
		self:rect({
			layer = -1,
			color = Color(0.5, 0.1, 0.1, 0.1)
		})
	end
end

AchievementRecentListGui = AchievementRecentListGui or class(ExtendedPanel)

function AchievementRecentListGui:init(parent, list, back_callback)
	self._back_callback = back_callback

	AchievementRecentListGui.super.init(self, parent, {
		w = 650,
		layer = 50,
		h = 440,
		input = true
	})
	self:set_center(parent:w() / 2, parent:h() / 2)

	if not managers.menu:is_pc_controller() then
		self._legends = TextLegendsBar:new(parent, nil, {
			layer = self:layer()
		})

		self._legends:add_items({
			"menu_legend_back"
		})
		self._legends:set_world_rightbottom(parent:world_rightbottom())
	end

	local border = 20
	local row_w = self:w() - border * 2
	local placer = UiPlacer:new(border, border, 8, 8)

	placer:add_bottom(self:fine_text({
		text = managers.localization:text("menu_achievements_recent_unlocked", {
			COUNT = #list
		}),
		font = medium_font,
		font_size = medium_font_size
	}))
	placer:set_at(self:w() - border - 6, nil)

	local safe = placer:add_left(self:fit_bitmap({
		w = 32,
		texture = "guis/dlcs/trk/textures/pd2/unlocked",
		h = 32
	}))
	local text = placer:add_left(self:fine_text({
		text_id = "menu_achievements_rewards",
		font = medium_font,
		font_size = medium_font_size,
		color = tweak_data.screen_colors.achievement_grey
	}))

	safe:set_center_y(text:center_y())
	placer:new_row()

	local scroll = placer:add_bottom(ScrollableList:new(self, {
		scrollbar_padding = 5,
		input = true,
		w = row_w,
		h = self:h() - placer:most().bottom - 48
	}))

	scroll:add_lines_and_static_down_indicator()

	self._scroll = scroll
	local s_placer = scroll:canvas():placer()
	local black_bg = true

	for _, v in pairs(list) do
		s_placer:add_bottom(AchievementRecentListItem:new(scroll:canvas(), v, black_bg))

		black_bg = not black_bg
	end

	if managers.menu:is_pc_controller() then
		local back = OnPressedTextButton:new(self, {
			text_id = "menu_continue_btn",
			binding = "continue",
			input = true,
			font = medium_font,
			font_size = medium_font_size
		}, function ()
			self._back_callback()
		end)

		back:set_righttop(scroll:scroll_item():scroll_panel():right(), scroll:bottom())
		back:move(0, 6)
	end

	local back_panel = self:panel({
		layer = -2
	})

	back_panel:rect({
		color = Color.black:with_alpha(0.8)
	})
	BoxGuiObject:new(back_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._back = back_panel
end

function AchievementRecentListGui:close()
	self:remove_self()

	if self._legends then
		self._legends:remove_self()
	end
end

function AchievementRecentListGui:update(...)
	if not managers.menu:is_pc_controller() and self:allow_input() and (not managers.system_menu or not managers.system_menu:is_active() or not not managers.system_menu:is_closing()) then
		local axis_x, axis_y = managers.menu_component:get_left_controller_axis()

		if axis_y ~= 0 and self._scroll then
			self._scroll:perform_scroll(axis_y)
		end
	end
end

function AchievementRecentListGui:back_pressed()
	self._back_callback()

	return true
end
