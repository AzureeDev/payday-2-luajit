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
local MilestoneItem = MilestoneItem or class(GrowPanel)

function MilestoneItem:init(parent, data, black_bg)
	MilestoneItem.super.init(self, parent, {
		border = 10,
		padding = 4,
		fixed_w = parent:row_w()
	})

	local current = managers.achievment:current_milestone() or {}
	local is_current = current.id == data.id
	local passed = not current.at or data.at < current.at
	local placer = self:placer()
	local color = not passed and Color.white:with_alpha(0.6)
	local texture, text_rect = tweak_data.hud_icons:get_texture(data.texture)
	local icon = placer:add_row(self:fit_bitmap({
		h = 36,
		w = 36,
		texture = texture,
		texture_rect = text_rect,
		color = Color.white
	}))

	if not data.awarded then
		icon:set_color(Color.white:with_alpha(0.1))

		local lock = self:fit_bitmap({
			texture = "guis/dlcs/trk/textures/pd2/lock",
			w = 36,
			h = 36
		})
		local cx, cy = icon:center()

		lock:set_center(math.round(cx + icon:w() * 0.5 - 10), math.round(cy + icon:h() * 0.5 - 10))
	end

	placer:add_right(self:fine_text({
		text = managers.localization:text("menu_milestone_item_title", {
			AT = data.at
		}),
		font = small_font,
		font_size = small_font_size,
		color = color
	}))
	placer:push_bottom()

	if is_current then
		local total = managers.achievment:total_unlocked()

		local function func(o, at, max)
			return string.format(" %d", at + data.last_at)
		end

		placer:add_row(self:fine_text({
			font = tiny_font,
			font_size = tiny_font_size,
			text = string.format("%d", data.last_at)
		}))
		placer:add_right_center(TextProgressBar:new(self, {
			h = 14,
			w = 350,
			back_color = Color(255, 60, 60, 65) / 255,
			max = data.at - data.last_at,
			format_func = func
		}, {
			font = tiny_font,
			font_size = tiny_font_size
		}, total - data.last_at))
		placer:add_right_center(self:fine_text({
			font = tiny_font,
			font_size = tiny_font_size,
			text = string.format("%d", data.at)
		}))
	end

	for _, data in ipairs(data.rewards or {}) do
		local texture, rect = tweak_data.hud_icons:get_icon_or(data.texture, data.texture, data.texture_rect)
		local icon = placer:add_row(self:fit_bitmap({
			w = 32,
			texture = data.texture,
			texture_rect = rect,
			render_template = data.render_template,
			color = color
		}))

		if (data.amount or 0) > 1 then
			placer:add_right_center(self:fine_text({
				text = string.format("%dx", data.amount),
				font = small_font,
				font_size = small_font_size,
				color = color
			}))
		end

		local reward_name = managers.localization:text(data.name_id)

		placer:add_right_center(self:fine_text({
			text = reward_name,
			font = small_font,
			font_size = small_font_size,
			color = color
		}))
	end

	placer:pop()

	if black_bg then
		self:rect({
			layer = -1,
			color = Color(0.5, 0.1, 0.1, 0.1)
		})
	end

	self._passed = passed
end

AchievementMilestoneGui = AchievementMilestoneGui or class(GrowPanel)

function AchievementMilestoneGui:init(parent, back_callback)
	AchievementMilestoneGui.super.init(self, parent, {
		padding = 10,
		layer = 50,
		border = 10,
		fixed_w = 550,
		input = true
	})

	self._back_callback = back_callback
	local main_placer = self:placer()

	main_placer:add_row(self:fine_text({
		text_id = "menu_milestone_rewards",
		font = medium_font,
		font_size = medium_font_size
	}))

	self._list = main_placer:add_row(ScrollableList:new(self, {
		scrollbar_padding = 10,
		h = 350,
		bar_minimum_size = 16,
		input = true,
		w = self:row_w() + 10
	}))

	self._list:add_lines_and_static_down_indicator()

	local canvas = self._list:canvas()
	local placer = canvas:placer()
	local back = main_placer:add_bottom(TextButton:new(self, {
		input = true,
		text_id = "menu_back",
		font = medium_font,
		font_size = medium_font_size
	}, function ()
		self._back_callback()
	end))

	back:set_world_right(canvas:world_right())

	local black_bg = false
	local last_passed = nil

	for _, v in ipairs(managers.achievment:milestones()) do
		local item = placer:add_row(MilestoneItem:new(canvas, v, black_bg))
		black_bg = not black_bg

		if item._passed then
			last_passed = item
		end
	end

	if last_passed then
		self._list:scroll_to_show_item_at_world(last_passed, self._list:world_y())
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

function AchievementMilestoneGui:close()
	self:remove_self()

	if self._legends then
		self._legends:remove_self()
	end
end

function AchievementMilestoneGui:update(...)
	if not managers.menu:is_pc_controller() and self:allow_input() and (not managers.system_menu or not managers.system_menu:is_active() or not not managers.system_menu:is_closing()) then
		local axis_x, axis_y = managers.menu_component:get_right_controller_axis()

		if axis_y ~= 0 then
			self._list:perform_scroll(axis_y * 2)
		end
	end
end

function AchievementMilestoneGui:back_pressed()
	self._back_callback()

	return true
end
