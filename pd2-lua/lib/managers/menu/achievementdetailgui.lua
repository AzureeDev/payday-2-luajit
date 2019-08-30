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
HalfCircleProgressBar = HalfCircleProgressBar or class(ExtendedPanel)

function HalfCircleProgressBar:init(parent, config, progress)
	HalfCircleProgressBar.super.init(self, parent, config)

	local half_w = math.floor(self:w() / 2)
	self._color = config.color or Color(config.alpha or 1, 1, 1, 1)
	self._back_color = config.back_color or self._color:with_alpha(config.back_alpha or self._color.alpha * 0.5)
	self._back = self:fit_bitmap({
		blend_mode = "add",
		texture = config.texture,
		color = self._back_color
	})
	self._right = self:fit_bitmap({
		render_template = "VertexColorTexturedRadial",
		blend_mode = "add",
		texture = config.texture,
		color = self._color
	})
	self._left = self:fit_bitmap({
		render_template = "VertexColorTexturedRadial",
		blend_mode = "add",
		texture = config.texture,
		color = self._color
	})

	self._right:set_w(half_w)
	self._left:set_w(half_w)
	self._right:set_left(self._left:right())

	local tw = self._left:texture_width()
	local th = self._left:texture_height()
	local half_tw = math.floor(tw / 2)

	self._left:set_texture_rect(0, th, half_tw, -th)
	self._right:set_texture_rect(half_tw, 0, half_tw, th)

	if progress then
		self:set_progress(progress)
	end
end

function HalfCircleProgressBar:set_progress(value)
	self._right:set_color(self._color:with_red(value * 0.5))
	self._left:set_color(self._color:with_red(0.5 + value * 0.5))
end

local function create_tag_text(str)
	return "menu_achievements_" .. str
end

local function get_tag_category(tag)
	return string.split(tag, "_", nil, 1)[1]
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

AchievementDetailGui = AchievementDetailGui or class(GrowPanel)

function AchievementDetailGui:init(parent, achievement_data_or_id, back_callback)
	AchievementDetailGui.super.init(self, parent, {
		padding = 10,
		layer = 50,
		border = 10,
		fixed_w = 650,
		input = true
	})

	if type(achievement_data_or_id) == "table" then
		local data = achievement_data_or_id
		self._id = data.id
		self._info = data.info
		self._visual = data.visual
	else
		self._id = achievement_data_or_id
	end

	print(self._id)

	if not managers.menu:is_pc_controller() then
		self._legends = TextLegendsBar:new(parent, nil, {
			layer = self:layer()
		})

		self._legends:add_items({
			"menu_legend_back",
			"menu_legend_scroll_left_right"
		})
		self._legends:set_rightbottom(parent:w(), parent:h())
	end

	self._back_callback = back_callback
	self._info = self._info or managers.achievment:get_info(self._id) or {}
	self._visual = self._visual or tweak_data.achievement.visual[self._id]
	local grey_color = nil
	local placer = self:placer()

	placer:push_right()

	local texture, texture_rect = tweak_data.hud_icons:get_icon_or(self._visual.icon_id, "guis/dlcs/unfinished/textures/placeholder")
	local bitmap = placer:add_right(self:bitmap({
		w = 85,
		h = 85,
		texture = texture,
		texture_rect = texture_rect
	}))

	if not self._info.awarded then
		bitmap:set_color(Color.white:with_alpha(0.1))

		local lock = self:bitmap({
			texture = "guis/dlcs/trk/textures/pd2/lock"
		})
		local cx, cy = bitmap:center()

		lock:set_center(math.round(cx + bitmap:w() * 0.5 - 10), math.round(cy + bitmap:h() * 0.5 - 10))
	end

	placer:add_right(nil)

	local title_text = managers.localization:text(self._visual.name_id)
	local title = placer:add_bottom(self:fine_text({
		text = title_text,
		font = medium_font,
		font_size = medium_font_size
	}))
	local unlock_date = self._info.unlock_time

	if unlock_date then
		placer:add_bottom(self:fine_text({
			text = managers.localization:text("menu_achievement_unlock_date", {
				DATE = os.date("%d %b %Y %H:%M", unlock_date)
			}),
			font = small_font,
			font_size = small_font_size,
			color = grey_color
		}), 5)
	elseif self._info.forced or self._info.tracked then
		local text_id = self._info.forced and "menu_achievements_forced_notify" or "menu_achievements_tracking_notify"

		placer:add_bottom(self:fine_text({
			text_id = text_id,
			font = small_font,
			font_size = small_font_size,
			color = tweak_data.screen_colors.achievement_grey
		}), 5)
	end

	placer:pop()

	local detail = placer:add_bottom(ScrollableList:new(self, {
		w = 380,
		scrollbar_padding = 5,
		h = 300,
		input = true
	}, {
		padding = 10
	}))

	detail:add_lines_and_static_down_indicator()

	local detail_canvas = detail:canvas()
	local detail_placer = detail:canvas():placer()

	add_achievement_detail_text(detail, detail_placer, self._visual, self._info, grey_color)

	local tag_str = nil

	for _, tag in pairs(self._visual.tags) do
		local category = get_tag_category(tag)
		local id = nil

		if category == "contracts" then
			id = create_contract_text(tag)
		elseif category == "difficulty" then
			id = create_difficulty_text(tag)
		else
			id = create_tag_text(tag)
		end

		local str = managers.localization:text("menu_achievements_" .. category) .. ": " .. managers.localization:text(id)

		if not tag_str then
			tag_str = managers.localization:text("menu_achievements_tags_intro") .. str
		else
			tag_str = tag_str .. ", " .. str
		end
	end

	if tag_str then
		local item = detail_placer:add_row(detail_canvas:fine_text({
			wrap = true,
			word_wrap = true,
			text = tag_str,
			font = tiny_font,
			font_size = tiny_font_size,
			color = grey_color,
			w = detail_canvas:row_w()
		}), nil, 10)
	end

	self._detail = detail
	local friend_list = placer:add_right(ScrollableList:new(self, {
		scrollbar_padding = 5,
		input = true,
		w = self:w() - self._detail:right() - 5,
		h = self._detail:h()
	}, {
		padding = 0
	}), 0)

	friend_list:add_lines_and_static_down_indicator()

	self._friend_list = friend_list

	placer:set_at(friend_list:left() + friend_list:canvas():w(), nil)

	if managers.menu:is_pc_controller() then
		placer:set_keep_current(1)
		placer:add_bottom_ralign(TextButton:new(self, {
			input = true,
			text_id = "menu_back",
			font = medium_font,
			font_size = medium_font_size
		}, function ()
			self._back_callback()
		end))
	else
		self:grow(0, 10)
	end

	self._num_friend_text = placer:add_top_ralign(self:fine_text({
		keep_w = true,
		align = "right",
		text = managers.localization:text("menu_achievement_friends_unlocked", {
			COUNT = ""
		}),
		font = small_font,
		font_size = small_font_size,
		color = grey_color
	}))
	local canvas = friend_list:canvas()
	local f_placer = ResizingPlacer:new(canvas, {
		padding = 4,
		y = 10,
		x = canvas:row_w() - 10
	})

	self._num_friend_text:set_text(managers.localization:text("menu_achievement_fetching_data"))

	local friend_p = 0
	local global_p = managers.achievment:get_global_achieved_percent(self._id)
	global_p = global_p >= 0 and global_p / 100 or 0

	placer:push()

	local f_text = managers.localization:text("menu_achievement_friends_unlocked_percent", {
		COUNT = string.format("%.1f", friend_p * 100)
	})
	local g_text = managers.localization:text("menu_achievement_global_unlocked_percent", {
		COUNT = string.format("%.1f", global_p * 100)
	})
	local friend_p_text = placer:add_top_ralign(self:fine_text({
		text = f_text,
		font = small_font,
		font_size = small_font_size,
		color = grey_color
	}))

	placer:add_top_ralign(self:fine_text({
		text = g_text,
		font = small_font,
		font_size = small_font_size,
		color = Color(255, 30, 70, 100) / 255
	}), 0)
	placer:pop()

	local _, cy = placer:current_center()
	local circle_size = 42
	local friend_circle = placer:add_left(HalfCircleProgressBar:new(self, {
		texture = "guis/dlcs/trk/textures/pd2/circle_inside",
		alpha = 1,
		back_alpha = 0.1,
		w = circle_size,
		h = circle_size
	}, friend_p), 15)
	local global_circle = HalfCircleProgressBar:new(self, {
		texture = "guis/dlcs/trk/textures/pd2/circle_outside",
		alpha = 1,
		back_alpha = 0.1,
		w = circle_size,
		h = circle_size
	}, global_p)

	friend_circle:set_center_y(cy)
	global_circle:set_lefttop(friend_circle:lefttop())

	if friend_circle:left() < title:right() then
		title:set_w(title:w() - title:right() + friend_circle:left())
	end

	if managers.network.account:signin_state() == "signed in" then
		local total_friends = Steam:friends()
		local unlocked_friends = {}

		managers.achievment:get_friends_with_achievement(self._id, function (friend)
			print("[Ach]", "GET FRIEND WITH ACHIEVEMENT", friend)

			if not alive(friend_list) or not alive(self._panel) then
				print("[Ach]", "\tQuit!")

				return
			end

			if friend == true then
				print("[Ach]", "\tDONE!")
				self._num_friend_text:set_text(managers.localization:text("menu_achievement_friends_unlocked", {
					COUNT = #unlocked_friends
				}))

				return
			elseif friend == false then
				print("[Ach]", "\tFAILED!")
				self._num_friend_text:set_text("ERROR")

				return
			end

			table.insert(unlocked_friends, friend)

			local friend_p = #unlocked_friends / #total_friends

			friend_circle:set_progress(friend_p)
			friend_p_text:set_text(managers.localization:text("menu_achievement_friends_unlocked_percent", {
				COUNT = string.format("%.1f", friend_p * 100)
			}))
			self.make_fine_text(friend_p_text)
			Steam:friend_avatar(Steam.SMALL_AVATAR, friend:id(), function (texture)
				if alive(friend_list) then
					local avatar = f_placer:add_left(canvas:fit_bitmap({
						w = 32,
						h = 32,
						texture = texture
					}), 10)
					local name = f_placer:add_left(canvas:fine_text({
						text = friend:name(),
						font = small_font,
						font_size = small_font_size,
						color = grey_color
					}))

					name:set_center_y(avatar:center_y())
					f_placer:new_row()
				end
			end)
		end)
	end

	local back_panel = self:panel({
		layer = -1
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

	self:set_center(parent:w() / 2, parent:h() / 2)
end

function AchievementDetailGui:close()
	self:remove_self()

	if self._legends then
		self._legends:remove_self()
	end
end

function AchievementDetailGui:update(...)
	if not managers.menu:is_pc_controller() and self:allow_input() and (not managers.system_menu or not managers.system_menu:is_active() or not not managers.system_menu:is_closing()) then
		local axis_x, axis_y = managers.menu_component:get_right_controller_axis()

		if axis_y ~= 0 and self._friend_list then
			self._friend_list:perform_scroll(axis_y)
		end

		local axis_x, axis_y = managers.menu_component:get_left_controller_axis()

		if axis_y ~= 0 and self._detail then
			self._detail:perform_scroll(axis_y)
		end
	end
end

function AchievementDetailGui:back_pressed()
	self._back_callback()

	return true
end
