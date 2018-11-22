SkirmishMenuComponentBase = SkirmishMenuComponentBase or class(MenuGuiComponent)

function SkirmishMenuComponentBase:init()
	self._buttons = {}
end

function SkirmishMenuComponentBase:_add_button(button)
	table.insert(self._buttons, button)
end

function SkirmishMenuComponentBase:_set_default_selection(button)
	self._default_selection = button
end

function SkirmishMenuComponentBase:mouse_moved(_, x, y)
	self:_select_button(nil)

	local used, pointer = nil

	for _, button in ipairs(self._buttons) do
		if button.mouse_moved then
			local current_used, current_pointer = button:mouse_moved(x, y)
			used = used or current_used
			pointer = pointer or current_pointer
		end
	end

	return used, pointer
end

function SkirmishMenuComponentBase:mouse_clicked(_, input_button, x, y)
	for _, button in ipairs(self._buttons) do
		if button.mouse_clicked then
			local used, pointer = button:mouse_clicked(input_button, x, y)

			if used then
				return used, pointer
			end
		end
	end
end

function SkirmishMenuComponentBase:move_up()
	self:_move_in_direction("up")
end

function SkirmishMenuComponentBase:move_down()
	self:_move_in_direction("down")
end

function SkirmishMenuComponentBase:move_left()
	self:_move_in_direction("left")
end

function SkirmishMenuComponentBase:move_right()
	self:_move_in_direction("right")
end

function SkirmishMenuComponentBase:confirm_pressed()
	if self._selected_button then
		self._selected_button._clicked_callback()
	end
end

function SkirmishMenuComponentBase:_select_button(button)
	if self._selected_button == button then
		return
	end

	if self._selected_button then
		self._selected_button:set_button_state(ClickButton.STATE_NORMAL)
	end

	self._selected_button = button

	if self._selected_button then
		self._selected_button:set_button_state(ClickButton.STATE_HOVER)
	end
end

function SkirmishMenuComponentBase:_move_in_direction(direction)
	local button_in_direction = nil

	if self._selected_button then
		button_in_direction = self._selected_button:get_directional_link(direction)
	else
		button_in_direction = self._default_selection
	end

	if button_in_direction then
		self:_select_button(button_in_direction)
	end
end

SkirmishLandingMenuComponent = SkirmishLandingMenuComponent or class(SkirmishMenuComponentBase)

function SkirmishLandingMenuComponent:init(ws, fullscreen_ws, node)
	SkirmishLandingMenuComponent.super.init(self)

	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._panel = self._ws:panel():panel({
		layer = 60,
		name = "skirmish_landing"
	})
	self._bg_panel = self._fullscreen_ws:panel():panel({
		layer = 50,
		name = "skirmish_landing_bg"
	})
	local bg_blur = BlurSheet:new(self._bg_panel)
	local title = FineText:new(self._panel, {
		name = "title",
		text = managers.localization:to_upper_text("menu_skirmish"),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size
	})
	local variant_selection_panel = self._panel:panel({
		name = "variant_selection"
	})

	local function open_node_callback(node_name)
		return function ()
			managers.menu:open_node(node_name)
			managers.menu_component:post_event("menu_enter")
		end
	end

	local active_weekly = managers.skirmish:active_weekly()
	local active_weekly_tweak = active_weekly and tweak_data.narrative.jobs[active_weekly.id]
	local weekly_skirmish_button = active_weekly and WeeklySkirmishVariantButton:new(variant_selection_panel, {
		bitmap = active_weekly_tweak.contract_visuals.weekly_skirmish_image,
		title = managers.localization:to_upper_text("menu_weekly_skirmish"),
		subtitle = managers.localization:to_upper_text(active_weekly_tweak.name_id),
		callback = open_node_callback("skirmish_weekly_contract")
	})
	local random_skirmish_button = SkirmishVariantButton:new(variant_selection_panel, {
		bitmap = "guis/textures/pd2/skirmish/menu_landing_random_skirmish",
		title = managers.localization:to_upper_text("menu_skirmish_random"),
		subtitle = managers.localization:to_upper_text("menu_random_skirmish_subtitle"),
		callback = open_node_callback("skirmish_contract")
	})

	if weekly_skirmish_button then
		random_skirmish_button:set_left(weekly_skirmish_button:right() + 10)
	end

	variant_selection_panel:set_width(random_skirmish_button:right())
	variant_selection_panel:set_height(random_skirmish_button:bottom())
	variant_selection_panel:set_center_x(self._panel:w() * 0.5)
	variant_selection_panel:set_center_y(self._panel:h() * 0.5)
	title:set_left(variant_selection_panel:left())
	title:set_bottom(variant_selection_panel:top())
	self:_add_button(random_skirmish_button)
	self:_set_default_selection(random_skirmish_button)

	if weekly_skirmish_button then
		self:_add_button(weekly_skirmish_button)
		self:_set_default_selection(weekly_skirmish_button)
		weekly_skirmish_button:set_directional_link("right", random_skirmish_button)
		random_skirmish_button:set_directional_link("left", weekly_skirmish_button)
	end

	if managers.menu:is_pc_controller() then
		local back_button = BackButton:new(self._panel, {
			name = "back_button"
		})

		back_button:set_right(self._panel:right() - 10)
		back_button:set_bottom(self._panel:bottom() - 10)
		random_skirmish_button:set_directional_link("down", back_button)
		back_button:set_directional_link("up", random_skirmish_button)

		if weekly_skirmish_button then
			weekly_skirmish_button:set_directional_link("down", back_button)
			back_button:set_directional_link("up", weekly_skirmish_button)
		end

		self:_add_button(back_button)
	else
		self:_select_button(weekly_skirmish_button and weekly_skirmish_button or random_skirmish_button)
	end

	managers.menu_component:disable_crimenet()
	managers.menu:active_menu().input:deactivate_controller_mouse()

	if #managers.skirmish:unclaimed_rewards() > 0 then
		managers.menu:open_node("weekly_skirmish_rewards")
	end
end

function SkirmishLandingMenuComponent:close()
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._bg_panel)
	managers.menu:active_menu().input:activate_controller_mouse()
	managers.menu_component:enable_crimenet()
end

function SkirmishLandingMenuComponent:open_node()
	managers.menu_component:post_event("menu_enter")
	managers.menu:open_node("skirmish_landing")
end

function SkirmishLandingMenuComponent:update(t, dt)
end

function SkirmishLandingMenuComponent:input_focus()
	return 1
end

ClickButton = ClickButton or class(GUIObjectWrapper)
ClickButton.STATE_NORMAL = 0
ClickButton.STATE_HOVER = 1

function ClickButton:init(gui_obj, callback)
	ClickButton.super.init(self, gui_obj)

	self._clicked_callback = callback
	self._directional_links = {}
end

function ClickButton:_set_button_state(state)
	if self._button_state ~= state then
		self._button_state = state

		if self.set_button_state then
			self:set_button_state(state)
		end

		if state == ClickButton.STATE_HOVER then
			managers.menu_component:post_event("highlight")
		end
	end
end

function ClickButton:set_callback(callback)
	self._clicked_callback = callback
end

function ClickButton:set_directional_link(direction, button)
	self._directional_links[direction] = button
end

function ClickButton:get_directional_link(direction)
	return self._directional_links[direction]
end

function ClickButton:mouse_moved(x, y)
	if self:inside(x, y) then
		self:_set_button_state(ClickButton.STATE_HOVER)

		return true, "link"
	else
		self:_set_button_state(ClickButton.STATE_NORMAL)

		return false
	end
end

function ClickButton:mouse_clicked(button, x, y)
	if button == Idstring("0") and self:inside(x, y) and self._clicked_callback then
		self._clicked_callback(button, x, y)

		return true
	end
end

BackButton = BackButton or class(ClickButton)

function BackButton:init(parent, config)
	config = config or {}
	local panel = parent:panel(config)

	BackButton.super.init(self, panel, function ()
		managers.menu:back(true)
	end)

	self._label_text = FineText:new(panel, {
		name = "label",
		layer = 1,
		text = managers.localization:to_upper_text("menu_back"),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})

	if managers.menu:is_pc_controller() then
		local ghost_label = FineText:new(panel, {
			name = "ghost_label",
			alpha = 0.4,
			rotation = 360,
			text = managers.localization:to_upper_text("menu_back"),
			font = tweak_data.menu.pd2_massive_font,
			font_size = tweak_data.menu.pd2_massive_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		ghost_label:set_rightbottom(self._label_text:rightbottom())
		ghost_label:move(10, 10)
	end

	panel:set_size(self._label_text:size())
end

function BackButton:set_button_state(state)
	if state == ClickButton.STATE_NORMAL then
		self._label_text:set_color(tweak_data.screen_colors.button_stage_3)
	elseif state == ClickButton.STATE_HOVER then
		self._label_text:set_color(tweak_data.screen_colors.button_stage_2)
	end
end

SkirmishVariantButton = SkirmishVariantButton or class(ClickButton)
SkirmishVariantButton.PADDING = {
	x = 8,
	y = 6
}

function SkirmishVariantButton:init(parent, config)
	config = config or {}
	config.w = config.w or 400
	config.h = config.h or 400
	local panel = parent:panel(config)

	SkirmishVariantButton.super.init(self, panel, config.callback)

	local text_margin = 2
	local padding = SkirmishVariantButton.PADDING
	local title = FineText:new(panel, {
		name = "title",
		layer = 1,
		text = config.title,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		x = padding.x,
		y = padding.y
	})
	local subtitle = FineText:new(panel, {
		name = "subtitle",
		layer = 1,
		text = config.subtitle,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		x = padding.x,
		y = title:bottom() + text_margin
	})
	self._picture = panel:bitmap({
		name = "picture",
		texture = config.bitmap,
		width = config.w,
		height = config.h,
		color = Color("6b6b6b")
	})
	self._box_corners = BoxGuiObject:new(panel)
end

function SkirmishVariantButton:set_button_state(state)
	local panel = self._gui_obj
	local target_color = nil

	if state == ClickButton.STATE_NORMAL then
		target_color = Color("6b6b6b")

		self._box_corners:create_sides(panel, {
			layer = 3,
			sides = {
				1,
				1,
				1,
				1
			}
		})
	elseif state == ClickButton.STATE_HOVER then
		target_color = tweak_data.screen_colors.button_stage_2

		self._box_corners:create_sides(panel, {
			layer = 3,
			sides = {
				2,
				2,
				2,
				2
			}
		})
	end

	local function fade_color(o)
		local start_color = o:color()

		over(0.2, function (p)
			p = -1 * p * (p - 2)

			self._picture:set_color(target_color * p + start_color * (1 - p))
		end)
	end

	self._picture:stop()
	self._picture:animate(fade_color)
end

WeeklySkirmishVariantButton = WeeklySkirmishVariantButton or class(SkirmishVariantButton)

function WeeklySkirmishVariantButton:init(parent, config)
	WeeklySkirmishVariantButton.super.init(self, parent, config)

	local panel = self._gui_obj
	local padding = SkirmishVariantButton.PADDING
	local countdown_text = panel:text({
		name = "countdown",
		align = "right",
		layer = 1,
		text = managers.localization:to_upper_text("skirmish_weekly_time_left", managers.skirmish:weekly_time_left_params()),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})
	local progress_panel = panel:panel({
		name = "progress_panel",
		h = 100,
		layer = 1
	})
	local progress_panel_bg = progress_panel:rect({
		name = "progress_panel_bg",
		alpha = 0.5,
		color = Color.black
	})
	local x, y, w, h = countdown_text:text_rect()

	countdown_text:set_height(h)
	countdown_text:set_righttop(config.w - padding.x, padding.y)
	progress_panel:set_bottom(panel:height())

	local progress_title = progress_panel:text({
		name = "progress_title",
		y = 10,
		align = "left",
		x = 10,
		layer = 1,
		text = managers.localization:to_upper_text("menu_weekly_skirmish_progress"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})
	local max_weekly_wave = 9
	local progress = managers.skirmish:weekly_progress() / max_weekly_wave
	local milestones = {
		0,
		3,
		5,
		9
	}
	local progress_bar = ProgressBar:new(progress_panel, {
		name = "progress_bar",
		h = 8,
		progress_color = tweak_data.screen_colors.button_stage_2,
		back_color = tweak_data.screen_colors.text:with_alpha(0.4),
		w = progress_panel:w() * 0.6666666666666666,
		y = progress_panel:h() * 0.6666666666666666
	}, progress)

	progress_bar:set_center_x(progress_panel:w() / 2)

	for _, milestone in ipairs(milestones) do
		local milestone_progress = milestone / max_weekly_wave
		local milestone_panel = progress_panel:panel({
			h = 25,
			w = 10,
			layer = 1,
			name = "milestone_" .. tostring(milestone),
			x = progress_bar:x() + progress_bar:w() * milestone_progress - 5
		})

		milestone_panel:set_bottom(progress_bar:y())

		local unlocked = milestone_progress <= progress
		local color = tweak_data.screen_colors.text:with_alpha(unlocked and 1 or 0.4)
		local milestone_title = milestone_panel:text({
			name = "title",
			align = "center",
			text = tostring(milestone),
			font = tweak_data.menu.pd2_tiny_font,
			font_size = tweak_data.menu.pd2_tiny_font_size,
			color = color
		})
		local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
		local milestone_arrow = milestone_panel:bitmap({
			name = "arrow",
			h = 5,
			y = 17,
			w = 8,
			rotation = 180,
			texture = texture,
			texture_rect = rect,
			color = color
		})

		milestone_arrow:set_center_x(milestone_panel:w() / 2)
	end

	countdown_text:animate(function (o)
		while true do
			wait(1)

			local time_text = managers.localization:to_upper_text("skirmish_weekly_time_left", managers.skirmish:weekly_time_left_params())

			countdown_text:set_text(time_text)
		end
	end)
end

local function get_reward_data(reward_type, reward_id)
	local guis_catalog = "guis/"
	local bundle_folder = tweak_data.blackmarket[reward_type][reward_id] and tweak_data.blackmarket[reward_type][reward_id].texture_bundle_folder

	if bundle_folder then
		guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
	end

	local icon_data, text_id = nil

	if reward_type == "textures" then
		icon_data = {
			render_template = "VertexColorTexturedPatterns",
			texture = tweak_data.blackmarket.textures[reward_id].texture
		}
		text_id = tweak_data.blackmarket.textures[reward_id].name_id
	elseif reward_type == "materials" then
		icon_data = {
			texture = guis_catalog .. "textures/pd2/blackmarket/icons/materials/" .. reward_id
		}
		text_id = tweak_data.blackmarket.materials[reward_id].name_id
	elseif reward_type == "masks" then
		icon_data = {
			texture = guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. reward_id
		}
		text_id = tweak_data.blackmarket.masks[reward_id].name_id
	else
		icon_data = tweak_data.hud_icons.downcard_overkill_deck
	end

	return icon_data, text_id
end

SkirmishWeeklyRewardsMenuComponent = SkirmishWeeklyRewardsMenuComponent or class(SkirmishMenuComponentBase)

function SkirmishWeeklyRewardsMenuComponent:init(ws, fullscreen_ws, node)
	SkirmishWeeklyRewardsMenuComponent.super.init(self)

	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._panel = ws:panel():panel({
		layer = 51
	})
	self._fullscreen_panel = fullscreen_ws:panel():panel({
		layer = 50
	})
	local bg_overlay = BlurSheet:new(self._fullscreen_panel, {
		name = "bg_overlay",
		layer = 50,
		color = Color(0.75, 0, 0, 0)
	})
	local width = 760
	local height = 320
	local reward_panel = self._panel:panel({
		name = "reward_panel",
		layer = 50,
		w = width,
		h = height
	})
	self._reward_panel = reward_panel

	reward_panel:set_center(self._panel:width() * 0.5, self._panel:height() * 0.5)
	reward_panel:rect({
		name = "bg",
		color = Color(0.75, 0, 0, 0)
	})
	BoxGuiObject:new(reward_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local progress_title = FineText:new(reward_panel, {
		name = "progress_title",
		rotation = 360,
		layer = 1,
		text = managers.localization:to_upper_text("menu_weekly_skirmish_rewards")
	})

	progress_title:set_bottom(0)

	local countdown_text = FineText:new(reward_panel, {
		name = "countdown",
		y = 5,
		x = 10,
		layer = 1,
		text = managers.localization:to_upper_text("skirmish_weekly_time_left", managers.skirmish:weekly_time_left_params()),
		color = tweak_data.screen_colors.text:with_alpha(0.5)
	})

	countdown_text:animate(function (o)
		while true do
			wait(1)

			local time_text = managers.localization:to_upper_text("skirmish_weekly_time_left", managers.skirmish:weekly_time_left_params())

			countdown_text:set_text(time_text)
		end
	end)

	local max_weekly_wave = 9
	local progress_text = FineText:new(reward_panel, {
		name = "progress_text",
		layer = 1,
		y = 5,
		text = managers.localization:to_upper_text("menu_weekly_skirmish_current_progress", {
			current = managers.skirmish:weekly_progress(),
			total = max_weekly_wave
		})
	})

	progress_text:set_right(reward_panel:w() - 10)

	local progress = managers.skirmish:weekly_progress() / max_weekly_wave
	local progress_bar = ProgressBar:new(reward_panel, {
		name = "progress_bar",
		h = 8,
		edges = "up",
		progress_color = tweak_data.screen_colors.button_stage_2,
		back_color = tweak_data.screen_colors.text:with_alpha(0.4),
		w = reward_panel:w() * 0.75,
		y = reward_panel:h() * 0.75
	}, progress)

	progress_bar:set_center_x(reward_panel:w() / 2)

	local milestones = {
		0,
		3,
		5,
		9
	}
	local last_button = nil

	for _, milestone in ipairs(milestones) do
		local milestone_progress = milestone / max_weekly_wave
		local milestone_panel = reward_panel:panel({
			w = 50,
			h = 150,
			layer = 50,
			name = "milestone_" .. tostring(milestone)
		})

		milestone_panel:set_center_x(progress_bar:x() + progress_bar:w() * milestone_progress)
		milestone_panel:set_bottom(progress_bar:y())

		local unlocked = milestone_progress <= progress
		local color = tweak_data.screen_colors.text:with_alpha(unlocked and 1 or 0.4)
		local milestone_title = FineText:new(milestone_panel, {
			name = "title",
			align = "center",
			text = tostring(milestone),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = color
		})
		local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
		local milestone_arrow = milestone_panel:bitmap({
			name = "arrow",
			h = 6,
			w = 12,
			rotation = 180,
			texture = texture,
			texture_rect = rect,
			color = color
		})

		milestone_arrow:set_center_x(milestone_panel:w() / 2)
		milestone_arrow:set_bottom(milestone_panel:h() - 5)
		milestone_title:set_bottom(milestone_arrow:y() - 2)

		if milestone > 0 then
			local milestone_reward = managers.skirmish:claimed_reward_by_id(milestone)
			local icon_data, text_id = nil

			if milestone_reward then
				local reward_type, reward_id = unpack(milestone_reward)
				icon_data, text_id = get_reward_data(reward_type, reward_id)
			else
				icon_data = tweak_data.hud_icons.downcard_overkill_deck
			end

			local reward_icon = milestone_panel:bitmap({
				name = "icon",
				rotation = 360,
				texture = icon_data.texture,
				texture_rect = icon_data.texture_rect,
				render_template = icon_data.render_template,
				color = color
			})

			ExtendedPanel.make_bitmap_fit(reward_icon, milestone_panel:w(), milestone_panel:h())
			reward_icon:set_center_x(milestone_panel:w() / 2)
			reward_icon:set_bottom(milestone_title:y() - 5)

			local reward_title = FineText:new(milestone_panel, {
				name = "reward_title",
				align = "center",
				rotation = 360,
				text = text_id and managers.localization:to_upper_text(text_id) or "",
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size
			})

			reward_title:set_bottom(reward_icon:top())
			reward_title:set_center_x(reward_icon:center_x())

			if not milestone_reward and unlocked then
				local button = RewardButton:new(milestone_panel, {
					reward_id = milestone,
					reward_icon = reward_icon,
					reward_title = reward_title
				})

				button:set_callback(callback(self, self, "flip_button", button))

				if last_button then
					last_button:set_directional_link("right", button)
					button:set_directional_link("left", last_button)
				end

				last_button = button

				if not managers.menu:is_pc_controller() and not self._selected_button then
					self:_select_button(button)
				end

				if not self._default_selection then
					self:_set_default_selection(button)
				end

				self:_add_button(button)
			end
		end
	end

	managers.menu_component:disable_crimenet()
	managers.menu:active_menu().input:deactivate_controller_mouse()
	managers.menu:active_menu().input:set_back_enabled(false)
end

function SkirmishWeeklyRewardsMenuComponent:close()
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
	managers.menu:active_menu().input:activate_controller_mouse()
	managers.menu_component:enable_crimenet()
end

function SkirmishWeeklyRewardsMenuComponent:flip_button(button)
	local reward_id = button._reward_id

	managers.skirmish:claim_reward(reward_id)
	button:flip()
	self:remove_button(button)
end

function SkirmishWeeklyRewardsMenuComponent:remove_button(button)
	table.delete(self._buttons, button)

	local left_button = button:get_directional_link("left")
	local right_button = button:get_directional_link("right")

	if left_button then
		left_button:set_directional_link("right", right_button)
	end

	if right_button then
		right_button:set_directional_link("left", left_button)
	end

	if self._selected_button == button then
		self:_select_button(right_button or left_button)
	end

	if self._default_selection == button then
		self:_set_default_selection(left_button or right_button)
	end

	button:set_button_state(ClickButton.STATE_NORMAL)

	if #self._buttons == 0 then
		local continue_button = ContinueButton:new(self._reward_panel, {
			name = "continue_button"
		})

		continue_button:set_right(self._reward_panel:w() - 10)
		continue_button:set_bottom(self._reward_panel:h() - 10)
		self:_add_button(continue_button)
		self:_select_button(continue_button)
		managers.menu:active_menu().input:set_back_enabled(true)
	end
end

function SkirmishWeeklyRewardsMenuComponent:input_focus()
	return 1
end

RewardButton = RewardButton or class(ClickButton)

function RewardButton:init(parent, config)
	config = config or {}
	local panel = parent:panel(config)
	self._reward_icon = config.reward_icon
	self._reward_id = config.reward_id
	self._reward_title = config.reward_title
	self._base_width = self._reward_icon:width()
	self._base_height = self._reward_icon:height()
	self._center_x, self._center_y = self._reward_icon:center()

	RewardButton.super.init(self, panel, config.callback)
end

function RewardButton:flip()
	self:set_scale(1)
	self._reward_icon:animate(callback(self, self, "_animate_flip"))
	managers.menu_component:post_event("loot_flip_card")
end

function RewardButton:_animate_flip(o)
	local cx = self._reward_icon:center_x()
	local w, h = self._reward_icon:size()

	over(0.25, function (p)
		self._reward_icon:set_w(w * (1 - p))
		self._reward_icon:set_center_x(cx)
	end)
	self._reward_icon:set_visible(false)

	local bottom = self._reward_icon:bottom()
	local icon_data, text_id = get_reward_data(unpack(managers.skirmish:claimed_reward_by_id(self._reward_id)))

	if icon_data.texture_rect then
		self._reward_icon:set_image(icon_data.texture, unpack(icon_data.texture_rect))
	else
		self._reward_icon:set_image(icon_data.texture)
	end

	if icon_data.render_template then
		self._reward_icon:set_render_template(Idstring(icon_data.render_template))
	end

	self._reward_icon:set_size(self._reward_icon:texture_width(), self._reward_icon:texture_height())
	ExtendedPanel.make_bitmap_fit(self._reward_icon, w, h)
	self._reward_icon:set_bottom(bottom)

	if text_id then
		self._reward_title:set_text(managers.localization:to_upper_text(text_id))
	end

	w, h = self._reward_icon:size()

	self._reward_icon:set_w(0)
	self._reward_icon:set_visible(true)
	over(0.25, function (p)
		self._reward_icon:set_w(w * p)
		self._reward_icon:set_center_x(cx)
	end)
end

function RewardButton:set_scale(scale)
	local scaled_w = self._base_width * scale
	local scaled_h = self._base_height * scale

	self._reward_icon:set_size(scaled_w, scaled_h)
	self._reward_icon:set_center(self._center_x, self._center_y)
end

function RewardButton:set_button_state(state)
	if state == ClickButton.STATE_NORMAL then
		self:set_scale(1)
	elseif state == ClickButton.STATE_HOVER then
		self:set_scale(1.2)
	end
end

ContinueButton = ContinueButton or class(ClickButton)

function ContinueButton:init(parent, config)
	config = config or {}
	local panel = parent:panel(config)

	ContinueButton.super.init(self, panel, function ()
		managers.menu:back(true)
	end)

	self._label_text = FineText:new(panel, {
		name = "label",
		layer = 1,
		text = managers.localization:to_upper_text("dialog_continue"),
		color = tweak_data.screen_colors.button_stage_3
	})

	panel:set_size(self._label_text:size())
end

function ContinueButton:set_button_state(state)
	if state == ClickButton.STATE_NORMAL then
		self._label_text:set_color(tweak_data.screen_colors.button_stage_3)
	elseif state == ClickButton.STATE_HOVER then
		self._label_text:set_color(tweak_data.screen_colors.button_stage_2)
	end
end
