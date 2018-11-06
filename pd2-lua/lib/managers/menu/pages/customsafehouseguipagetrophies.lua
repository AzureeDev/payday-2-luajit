local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local PANEL_PADDING = 10
local REWARD_SIZE = 100
local MAX_REWARDS_DISPLAYED = 2
CustomSafehouseGuiPageTrophies = CustomSafehouseGuiPageTrophies or class(CustomSafehouseGuiPage)

function CustomSafehouseGuiPageTrophies:init(page_id, page_panel, fullscreen_panel, gui)
	CustomSafehouseGuiPageTrophies.super.init(self, page_id, page_panel, fullscreen_panel, gui)

	self.make_fine_text = BlackMarketGui.make_fine_text
	self._scrollable_panels = {}

	self:_setup_trophies_counter()
	self:_setup_trophies_info()
	self:_setup_trophies_list()
end

function CustomSafehouseGuiPageTrophies:_setup_trophies_list()
	self._trophies = {}
	local scroll = ScrollablePanel:new(self:panel(), "TrophiesPanel", {
		padding = 0
	})

	BoxGuiObject:new(scroll:panel(), {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._trophies_scroll = scroll

	table.insert(self._scrollable_panels, scroll)

	local trophies = {}

	for idx, trophy in ipairs(managers.custom_safehouse:trophies()) do
		if (not trophy.secret or trophy.completed) and not trophy.hidden_in_list then
			table.insert(trophies, trophy)
		end
	end

	table.sort(trophies, function (a, b)
		return managers.localization:text(a.name_id) < managers.localization:text(b.name_id)
	end)

	for idx, trophy in ipairs(trophies) do
		local trophy_btn = CustomSafehouseGuiTrophyItem:new(scroll:canvas(), trophy, 0, idx)

		table.insert(self._trophies, trophy_btn)
	end

	table.sort(self._trophies, function (a, b)
		return a:priority() < b:priority()
	end)

	local canvas_h = 0

	for idx, trophy in ipairs(self._trophies or {}) do
		trophy:set_position(idx)
		trophy:link(self._trophies[idx - 1], self._trophies[idx + 1])

		canvas_h = math.max(canvas_h, trophy:bottom())
	end

	scroll:set_canvas_size(nil, canvas_h)

	if #self._trophies > 0 then
		self:_set_selected(self._trophies[1], true)
	end
end

function CustomSafehouseGuiPageTrophies:_setup_trophies_info()
	local buttons_panel = self:info_panel():panel({
		name = "buttons_panel"
	})
	local trophy_panel = self:info_panel():panel({
		name = "trophy_panel"
	})
	local buttons = {}
	local button_panel_h = nil

	if not Global.game_settings.is_playing then
		if not managers.menu:is_pc_controller() then
			table.insert(buttons, {
				btn = "BTN_A",
				name_id = "menu_trophy_change_display_to_off"
			})
		end

		table.insert(buttons, {
			btn = "BTN_X",
			name_id = "menu_trophy_display_all",
			pc_btn = "menu_remove_item",
			callback = callback(self, self, "_show_all_trophies")
		})
		table.insert(buttons, {
			btn = "BTN_Y",
			name_id = "menu_trophy_hide_all",
			pc_btn = "menu_modify_item",
			callback = callback(self, self, "_hide_all_trophies")
		})

		button_panel_h = 10 + #buttons * medium_font_size
	else
		button_panel_h = 0
	end

	self._buttons = {}
	self._controllers_pc_mapping = {}
	self._controllers_mapping = {}
	local btn_x = 10

	for idx, btn_data in pairs(buttons) do
		local new_button = CustomSafehouseGuiButtonItem:new(buttons_panel, btn_data, btn_x, idx)
		self._buttons[idx] = new_button

		if btn_data.pc_btn then
			self._controllers_mapping[btn_data.pc_btn:key()] = new_button
		end
	end

	if button_panel_h > 0 then
		trophy_panel:set_h(self:info_panel():h() - button_panel_h - PANEL_PADDING)
	else
		trophy_panel:set_h(self:info_panel():h())
	end

	buttons_panel:set_h(button_panel_h)
	buttons_panel:set_bottom(self:info_panel():bottom())

	self._buttons_box_panel = BoxGuiObject:new(buttons_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	local scroll = ScrollablePanel:new(trophy_panel, "TrophyInfoPanel")

	scroll:on_canvas_updated_callback(callback(self, self, "update_info_panel_width"))

	self._trophy_box_panel = BoxGuiObject:new(scroll:panel(), {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self._info_scroll = scroll

	table.insert(self._scrollable_panels, scroll)

	local trophy_title = scroll:canvas():text({
		name = "TitleText",
		blend_mode = "add",
		align = "left",
		vertical = "top",
		valign = "top",
		halign = "left",
		layer = 1,
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.title,
		text = utf8.to_upper("Trophies"),
		w = scroll:canvas():w(),
		h = medium_font_size
	})
	local image_panel = scroll:canvas():panel({
		layer = 10,
		name = "TrophyImagePanel"
	})

	image_panel:set_w(scroll:canvas():w())
	image_panel:set_h(image_panel:w() / 2)
	image_panel:set_top(trophy_title:bottom() + PANEL_PADDING)

	local trophy_image = image_panel:bitmap({
		layer = 40,
		name = "TrophyImage",
		texture_rect = {
			0,
			0,
			512,
			256
		},
		w = image_panel:w(),
		h = image_panel:h()
	})
	local image_scanlines = image_panel:bitmap({
		texture = "guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_effect",
		name = "TrophyImageScanlines",
		wrap_mode = "wrap",
		layer = 50,
		texture_rect = {
			0,
			0,
			512,
			512
		},
		w = image_panel:w(),
		h = image_panel:h() * 4,
		y = image_panel:h() * 2 * -1
	})
	self._scanline_effect = image_scanlines
	self._image_outline = BoxGuiObject:new(image_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})

	self._image_outline:set_color(Color(0.2, 1, 1, 1))
	self._image_outline:set_blend_mode("add")

	local complete_banner = scroll:canvas():panel({
		name = "CompleteBannerPanel",
		h = small_font_size
	})

	complete_banner:set_top(image_panel:bottom() + PANEL_PADDING)
	complete_banner:rect({
		name = "CompleteBannerFill",
		alpha = 0.4,
		color = tweak_data.screen_colors.challenge_completed_color
	})

	local complete_text = complete_banner:text({
		blend_mode = "add",
		name = "CompleteText",
		vertical = "top",
		valign = "scale",
		align = "center",
		halign = "scale",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.challenge_completed_color:with_alpha(0.8),
		text = managers.localization:to_upper_text("menu_trophy_displayed")
	})
	local desc_text = scroll:canvas():text({
		name = "DescText",
		blend_mode = "add",
		wrap = true,
		align = "left",
		word_wrap = true,
		vertical = "top",
		valign = "top",
		halign = "left",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.title,
		text = managers.localization:text("menu_cs_daily_available"),
		w = scroll:canvas():w()
	})

	desc_text:set_top(image_panel:bottom() + PANEL_PADDING)
	self:make_fine_text(desc_text)

	local unlock_text = scroll:canvas():text({
		name = "ObjectiveHeader",
		blend_mode = "add",
		vertical = "top",
		align = "left",
		valign = "top",
		halign = "left",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.challenge_title,
		text = utf8.to_upper(managers.localization:text("menu_unlock_condition")),
		w = scroll:canvas():w()
	})

	self:make_fine_text(unlock_text)
	unlock_text:set_top(desc_text:bottom() + PANEL_PADDING)

	local objective_text = scroll:canvas():text({
		name = "ObjectiveText",
		blend_mode = "add",
		wrap = true,
		align = "left",
		word_wrap = true,
		vertical = "top",
		valign = "top",
		halign = "left",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.title,
		text = managers.localization:text("menu_cs_daily_available"),
		w = scroll:canvas():w()
	})

	objective_text:set_top(unlock_text:bottom())
	self:make_fine_text(objective_text)

	local reward_header = scroll:canvas():text({
		name = "RewardHeader",
		blend_mode = "add",
		vertical = "top",
		align = "left",
		valign = "top",
		halign = "left",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.challenge_title,
		text = managers.localization:to_upper_text("menu_reward"),
		w = scroll:canvas():w()
	})

	self:make_fine_text(reward_header)
	reward_header:set_top(objective_text:bottom() + PANEL_PADDING)

	local reward_text = scroll:canvas():text({
		name = "RewardText",
		blend_mode = "add",
		wrap = true,
		align = "left",
		word_wrap = true,
		vertical = "top",
		valign = "top",
		halign = "left",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.title,
		text = managers.localization:text("bm_cs_continental_coin_cost", {
			cost = tweak_data.safehouse.rewards.challenge
		}),
		w = scroll:canvas():w()
	})

	reward_text:set_top(reward_header:bottom())
	self:make_fine_text(reward_text)

	local progress_header = scroll:canvas():text({
		name = "ProgressHeader",
		blend_mode = "add",
		align = "left",
		vertical = "top",
		valign = "top",
		halign = "left",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.challenge_title,
		text = utf8.to_upper(managers.localization:text("menu_unlock_progress")),
		w = scroll:canvas():w(),
		h = small_font_size
	})

	self:make_fine_text(progress_header)
	progress_header:set_top(objective_text:bottom() + PANEL_PADDING)
	scroll:update_canvas_size()
end

function CustomSafehouseGuiPageTrophies:_setup_trophies_counter()
	local total = 0
	local completed = 0

	for _, trophy in ipairs(managers.custom_safehouse:trophies()) do
		if not trophy.hidden_in_list then
			total = total + 1

			if trophy.completed then
				completed = completed + 1
			end
		end
	end

	local text = managers.localization:to_upper_text("menu_cs_trophy_counter", {
		total = total,
		completed = completed
	})
	self._trophy_counter = self._gui._panel:text({
		visible = false,
		text = text,
		font = medium_font,
		font_size = medium_font_size,
		color = tweak_data.screen_colors.text
	})

	self:make_fine_text(self._trophy_counter)
	self._trophy_counter:set_right(self._gui._panel:w())
end

function CustomSafehouseGuiPageTrophies:set_active(active)
	self._trophy_counter:set_visible(active)

	return CustomSafehouseGuiPageTrophies.super.set_active(self, active)
end

function CustomSafehouseGuiPageTrophies:update_info_panel_width(new_width)
	local info_panel = self._info_scroll:canvas()
	local desc_text = info_panel:child("DescText")
	local objective_text = info_panel:child("ObjectiveText")
	local reward_text = info_panel:child("RewardText")
	local image_panel = info_panel:child("TrophyImagePanel")

	desc_text:set_w(new_width)
	objective_text:set_w(new_width)
	reward_text:set_w(new_width)
	image_panel:set_w(new_width)
	image_panel:set_h(new_width / 2)
	self._image_outline:close()

	self._image_outline = BoxGuiObject:new(image_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})

	self._image_outline:set_color(Color(0.2, 1, 1, 1))
	self._image_outline:set_blend_mode("add")

	if self._progress_items then
		for _, item in ipairs(self._progress_items) do
			item:set_w(new_width)
		end
	end

	if self._selected_trophy then
		self:set_trophy_info(self._selected_trophy, false)
	end
end

function CustomSafehouseGuiPageTrophies:set_trophy_info(trophy, update_size)
	local info_panel = self._info_scroll:canvas()
	local title_text = info_panel:child("TitleText")
	local image_panel = info_panel:child("TrophyImagePanel")
	local trophy_image = image_panel:child("TrophyImage")
	local complete_banner = info_panel:child("CompleteBannerPanel")
	local complete_text = complete_banner:child("CompleteText")
	local complete_fill = complete_banner:child("CompleteBannerFill")
	local desc_text = info_panel:child("DescText")
	local objective_header = info_panel:child("ObjectiveHeader")
	local objective_text = info_panel:child("ObjectiveText")
	local reward_header = info_panel:child("RewardHeader")
	local reward_text = info_panel:child("RewardText")
	local progress_header = info_panel:child("ProgressHeader")
	local data = trophy:trophy_data()

	title_text:set_text(utf8.to_upper(managers.localization:text(data.name_id)))
	desc_text:set_text(managers.localization:text(data.desc_id))
	trophy_image:set_image("guis/dlcs/chill/textures/pd2/trophies/" .. tostring(data.image_id))

	if data.completed then
		complete_banner:set_visible(true)
		desc_text:set_top(complete_banner:bottom() + PANEL_PADDING)
	else
		complete_banner:set_visible(false)
		desc_text:set_top(image_panel:bottom() + PANEL_PADDING)
	end

	if data.displayed then
		complete_text:set_text(managers.localization:to_upper_text("menu_trophy_displayed"))
		complete_text:set_color(tweak_data.screen_colors.challenge_completed_color)
		complete_fill:set_color(tweak_data.screen_colors.challenge_completed_color)
	else
		complete_text:set_text(managers.localization:to_upper_text("menu_trophy_not_displayed"))
		complete_text:set_color(tweak_data.screen_colors.important_1)
		complete_fill:set_color(tweak_data.screen_colors.important_1)
	end

	local _, _, _, h = desc_text:text_rect()

	desc_text:set_h(h)
	objective_header:set_top(desc_text:bottom() + PANEL_PADDING)
	objective_text:set_top(objective_header:bottom())
	reward_header:set_top(objective_text:bottom() + PANEL_PADDING)
	reward_text:set_top(reward_header:bottom())
	reward_header:set_visible(data.gives_reward ~= false)
	reward_text:set_visible(data.gives_reward ~= false)

	local macros = {}

	if #data.objectives > 0 then
		local max = 0

		for idx, objective in ipairs(data.objectives) do
			max = math.max(max, objective.max_progress)
		end

		macros.max_progress = tostring(max)
	end

	objective_text:set_text(managers.localization:text(data.objective_id, macros))

	local _, _, _, h = objective_text:text_rect()

	objective_text:set_h(h)

	if self._progress_items then
		for _, item in ipairs(self._progress_items) do
			item:destroy()
		end

		self._progress_items = {}
	end

	if data.show_progress then
		progress_header:set_visible(true)

		if data.gives_reward ~= false then
			progress_header:set_top(reward_text:bottom() + PANEL_PADDING)
		else
			progress_header:set_top(objective_text:bottom() + PANEL_PADDING)
		end

		self._progress_items = {}

		for idx, objective in ipairs(data.objectives) do
			if data.completed then
				objective.completed = true
				objective.progress = objective.max_progress
			end

			local item = CustomSafehouseGuiProgressItem:new(info_panel, objective)

			table.insert(self._progress_items, item)

			local pos = progress_header:bottom() + CustomSafehouseGuiProgressItem.h * (idx - 1)

			item:set_top(pos)
		end
	else
		progress_header:set_visible(false)
	end

	if update_size then
		self._info_scroll:update_canvas_size()
	end
end

function CustomSafehouseGuiPageTrophies:_show_all_trophies()
	for i, trophy in ipairs(self._trophies) do
		managers.custom_safehouse:set_trophy_displayed(trophy:trophy_data().id, true)
		trophy:refresh()
	end

	self:refresh()
end

function CustomSafehouseGuiPageTrophies:_hide_all_trophies()
	for i, trophy in ipairs(self._trophies) do
		managers.custom_safehouse:set_trophy_displayed(trophy:trophy_data().id, false)
		trophy:refresh()
	end

	self:refresh()
end

function CustomSafehouseGuiPageTrophies:_set_selected(trophy, skip_sound)
	if not trophy then
		return false
	end

	if self._selected_trophy then
		self._selected_trophy:set_selected(false)
	end

	self._selected_trophy = trophy

	self._selected_trophy:set_selected(true, not skip_sound)
	self:set_trophy_info(self._selected_trophy, true)

	local scroll_panel = self._trophies_scroll:scroll_panel()
	local y = self._trophies_scroll:canvas():y() + trophy:bottom()

	if scroll_panel:h() < y then
		self._trophies_scroll:perform_scroll(y - scroll_panel:h(), -1)
	else
		y = self._trophies_scroll:canvas():y() + trophy:top()

		if y < 0 then
			self._trophies_scroll:perform_scroll(math.abs(y), 1)
		end
	end

	if self._buttons[1] and self._buttons[1]:button_data().btn == "BTN_A" then
		self._buttons[1]:set_hidden(false)

		if trophy:trophy_data().completed then
			local text_id = trophy:trophy_data().displayed and "menu_trophy_change_display_to_off" or "menu_trophy_change_display_to_on"

			self._buttons[1]:set_text(managers.localization:to_upper_text(text_id))
		else
			self._buttons[1]:set_hidden(true)
		end

		self:update_info_panel_size()
	end
end

function CustomSafehouseGuiPageTrophies:refresh()
	CustomSafehouseGuiPageTrophies.super.refresh(self)
	self:_set_selected(self._selected_trophy, true)
end

function CustomSafehouseGuiPageTrophies:update_info_panel_size()
	local active_buttons = 0
	local button_panel_h = 0

	if not Global.game_settings.is_playing then
		for i, button in ipairs(self._buttons) do
			if not button:hidden() then
				active_buttons = active_buttons + 1

				button:reorder(active_buttons)
			end
		end

		button_panel_h = 10 + active_buttons * medium_font_size
	end

	local trophy_panel = self:info_panel():child("trophy_panel")
	local buttons_panel = self:info_panel():child("buttons_panel")

	if button_panel_h > 0 then
		trophy_panel:set_h(self:info_panel():h() - button_panel_h - PANEL_PADDING)
	else
		trophy_panel:set_h(self:info_panel():h())
	end

	self._info_scroll:set_size(self._info_scroll:panel():w(), trophy_panel:h())
	buttons_panel:set_h(button_panel_h)
	buttons_panel:set_bottom(self:info_panel():bottom())

	if self._buttons_box_panel then
		self._buttons_box_panel:close()

		self._buttons_box_panel = nil
	end

	if self._trophy_box_panel then
		self._trophy_box_panel:close()

		self._trophy_box_panel = nil
	end

	self._buttons_box_panel = BoxGuiObject:new(buttons_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self._trophy_box_panel = BoxGuiObject:new(self._info_scroll:panel(), {
		sides = {
			1,
			1,
			1,
			1
		}
	})
end

function CustomSafehouseGuiPageTrophies:update(t, dt)
	local cx, cy = managers.menu_component:get_right_controller_axis()

	if cy ~= 0 and self._info_scroll then
		self._info_scroll:perform_scroll(math.abs(cy * 500 * dt), math.sign(cy))
	end

	if self._scanline_effect then
		local h = self._scanline_effect:h() * 0.25 * -1

		self._scanline_effect:move(0, 10 * dt)

		if h <= self._scanline_effect:top() then
			self._scanline_effect:set_top(self._scanline_effect:top() + h)
		end
	end
end

function CustomSafehouseGuiPageTrophies:mouse_moved(button, x, y)
	if not self._active then
		return
	end

	for i, panel in pairs(self._scrollable_panels) do
		if panel then
			local values = {
				panel:mouse_moved(button, x, y)
			}

			if values[1] ~= nil then
				return unpack(values)
			end
		end
	end

	if self:panel():inside(x, y) then
		for idx, trophy in ipairs(self._trophies or {}) do
			if trophy:inside(x, y) then
				if self._selected_trophy ~= trophy then
					self:_set_selected(trophy)
				end

				return true, "link"
			end
		end
	end

	local used, pointer = nil

	for _, button in ipairs(self._buttons) do
		if button:inside(x, y) and not used then
			button:set_selected(true)

			pointer = "link"
			used = true
		else
			button:set_selected(false)
		end
	end

	return used, pointer
end

function CustomSafehouseGuiPageTrophies:confirm_pressed()
	if Global.game_settings.is_playing then
		return
	end

	if managers.menu:is_pc_controller() then
		for _, button in ipairs(self._buttons) do
			if button:is_selected() then
				button:trigger(self)

				return
			end
		end
	end

	if self._selected_trophy then
		self._selected_trophy:trigger(self)
	end
end

function CustomSafehouseGuiPageTrophies:mouse_pressed(button, x, y)
	if not self._active then
		return
	end

	for i, panel in pairs(self._scrollable_panels) do
		if panel then
			local values = {
				panel:mouse_pressed(button, x, y)
			}

			if values[1] ~= nil then
				return unpack(values)
			end
		end
	end

	if self:panel():inside(x, y) then
		for idx, trophy in ipairs(self._trophies or {}) do
			if trophy:inside(x, y) and button == Idstring("0") then
				trophy:trigger(self)

				return true
			end
		end
	end

	for _, button in ipairs(self._buttons) do
		if button:inside(x, y) then
			button:trigger()

			return true
		end
	end
end

function CustomSafehouseGuiPageTrophies:mouse_released(button, x, y)
	if not self._active then
		return
	end

	for i, panel in pairs(self._scrollable_panels) do
		if panel then
			local values = {
				panel:mouse_released(button, x, y)
			}

			if values[1] ~= nil then
				self._prevent_click = (self._prevent_click or 0) + 1

				return unpack(values)
			end
		end
	end
end

function CustomSafehouseGuiPageTrophies:mouse_wheel_up(x, y)
	if not self._active then
		return
	end

	for i, panel in pairs(self._scrollable_panels) do
		if panel then
			local values = {
				panel:scroll(x, y, 1)
			}

			if values[1] ~= nil then
				return unpack(values)
			end
		end
	end
end

function CustomSafehouseGuiPageTrophies:mouse_wheel_down(x, y)
	if not self._active then
		return
	end

	for i, panel in pairs(self._scrollable_panels) do
		if panel then
			local values = {
				panel:scroll(x, y, -1)
			}

			if values[1] ~= nil then
				return unpack(values)
			end
		end
	end
end

function CustomSafehouseGuiPageTrophies:move_up()
	if self._selected_trophy then
		self:_set_selected(self._selected_trophy:get_linked("up"))
		self._gui:update_legend()
	end
end

function CustomSafehouseGuiPageTrophies:move_down()
	if self._selected_trophy then
		self:_set_selected(self._selected_trophy:get_linked("down"))
		self._gui:update_legend()
	end
end

function CustomSafehouseGuiPageTrophies:get_legend()
	local legend = {}

	table.insert(legend, "move")

	if self._info_scroll:is_scrollable() then
		table.insert(legend, "scroll")
	end

	table.insert(legend, "back")

	return legend
end

CustomSafehouseGuiTrophyItem = CustomSafehouseGuiTrophyItem or class(CustomSafehouseGuiItem)

function CustomSafehouseGuiTrophyItem:init(panel, data, x, priority)
	CustomSafehouseGuiTrophyItem.super.init(self, panel, data)

	self._data = data
	self._priority = priority or 0
	self._is_complete = false
	self._panel = panel:panel({
		layer = 10,
		x = x,
		y = x,
		w = panel:w() - x * 2,
		h = large_font_size
	})
	local size = self._panel:h() - 16
	self._complete_checkbox = self._panel:bitmap({
		x = 8,
		y = 8,
		w = size,
		h = size
	})

	self._complete_checkbox:set_image("guis/textures/pd2/mission_briefing/gui_tickbox")

	self._complete_checkbox_highlight = self._panel:bitmap({
		x = 8,
		y = 8,
		w = size,
		h = size
	})

	self._complete_checkbox_highlight:set_image("guis/textures/pd2/mission_briefing/gui_tickbox")
	self._complete_checkbox_highlight:set_visible(false)

	self._btn_text = self._panel:text({
		text = "",
		name = "text",
		align = "left",
		blend_mode = "add",
		x = 10,
		layer = 1,
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.button_stage_3
	})

	self:set_text(managers.localization:text(data.name_id))

	self._select_rect = self._panel:rect({
		blend_mode = "add",
		name = "select_rect",
		halign = "scale",
		alpha = 0.3,
		valign = "scale",
		color = tweak_data.screen_colors.button_stage_3
	})

	self._select_rect:set_visible(false)

	if data.completed then
		self:complete()
	end

	self:refresh()
end

function CustomSafehouseGuiTrophyItem:trophy_data()
	return self._data
end

function CustomSafehouseGuiTrophyItem:set_text(text)
	self._btn_text:set_text(utf8.to_upper(text))

	local _, _, w, h = self._btn_text:text_rect()

	self._btn_text:set_size(w, h)
	self._btn_text:set_left(self._complete_checkbox:right() + 10)
	self._btn_text:set_top(10)
end

function CustomSafehouseGuiTrophyItem:inside(x, y)
	return self._panel:inside(x, y)
end

function CustomSafehouseGuiTrophyItem:show()
	self._select_rect:set_visible(true)
	self._complete_checkbox_highlight:set_visible(true)
	self._btn_text:set_alpha(1)

	if self:trophy_data().completed and not self:trophy_data().displayed then
		self._btn_text:set_color(tweak_data.screen_colors.important_1)
	else
		self._btn_text:set_color(tweak_data.screen_colors.button_stage_2)
	end
end

function CustomSafehouseGuiTrophyItem:hide()
	self._select_rect:set_visible(false)
	self._complete_checkbox_highlight:set_visible(false)
	self._btn_text:set_alpha(1)

	if self:trophy_data().completed and not self:trophy_data().displayed then
		self._btn_text:set_color(tweak_data.screen_colors.important_1)
		self._btn_text:set_alpha(0.8)
	else
		self._btn_text:set_color(tweak_data.screen_colors.button_stage_3)
	end
end

function CustomSafehouseGuiTrophyItem:top()
	return self._panel:top()
end

function CustomSafehouseGuiTrophyItem:bottom()
	return self._panel:bottom()
end

function CustomSafehouseGuiTrophyItem:visible()
	return self._select_rect:visible()
end

function CustomSafehouseGuiTrophyItem:refresh()
	if self._selected then
		self:show()
	else
		self:hide()
	end
end

function CustomSafehouseGuiTrophyItem:_update_position()
	self._panel:set_y((self._scroll_offset or 0) + (self._priority - 1) * large_font_size + self._priority)
end

function CustomSafehouseGuiTrophyItem:set_position(i)
	self._priority = i

	self:_update_position()
end

function CustomSafehouseGuiTrophyItem:set_scroll_offset(offset)
	self._scroll_offset = offset

	self:_update_position()
end

function CustomSafehouseGuiTrophyItem:priority()
	return self._priority
end

function CustomSafehouseGuiTrophyItem:complete()
	if not self._is_complete then
		self._is_complete = true
		self._priority = self._priority + #tweak_data.safehouse.trophies
		local complete_color = tweak_data.screen_color_grey

		self._complete_checkbox:set_image("guis/textures/pd2/mission_briefing/gui_tickbox_ready")
	end
end

function CustomSafehouseGuiTrophyItem:is_complete()
	return self._is_complete
end

function CustomSafehouseGuiTrophyItem:link(up, down)
	self._links = {
		up = up,
		down = down
	}
end

function CustomSafehouseGuiTrophyItem:get_linked(link)
	return self._links and self._links[link]
end

function CustomSafehouseGuiTrophyItem:trigger(parent)
	if not Global.game_settings.is_playing then
		managers.custom_safehouse:set_trophy_displayed(self:trophy_data().id, not self:trophy_data().displayed)
		self:refresh()

		if parent then
			parent:refresh()
		end
	end
end

CustomSafehouseGuiProgressItem = CustomSafehouseGuiProgressItem or class(CustomSafehouseGuiItem)
CustomSafehouseGuiProgressItem.h = small_font_size * 1.3

function CustomSafehouseGuiProgressItem:init(parent_panel, trophy_objective)
	self._parent = parent_panel
	self._objective = trophy_objective
	self._panel = parent_panel:panel({
		w = parent_panel:w(),
		h = self.h
	})
	self._text = self._panel:text({
		name = "text",
		blend_mode = "add",
		align = "left",
		vertical = "center",
		valign = "scale",
		halign = "scale",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text,
		text = managers.localization:text(tostring(trophy_objective.name_id)),
		w = self._panel:w(),
		h = self._panel:h()
	})

	if trophy_objective.max_progress > 1 then
		self._progress_panel = self._panel:panel({
			w = self._panel:w(),
			h = self._panel:h()
		})
		self._progress_outline = BoxGuiObject:new(self._progress_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		local color = trophy_objective.completed and tweak_data.screen_colors.challenge_completed_color or tweak_data.screen_colors.button_stage_3
		self._progress_fill = self._progress_panel:rect({
			w = self._panel:w() * trophy_objective.progress / trophy_objective.max_progress,
			color = color:with_alpha(0.4)
		})

		self._text:set_x(PANEL_PADDING)

		self._progress_text = self._panel:text({
			name = "progress_text",
			blend_mode = "add",
			align = "right",
			vertical = "center",
			valign = "scale",
			halign = "scale",
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text,
			text = tostring(trophy_objective.progress) .. "/" .. tostring(trophy_objective.max_progress),
			w = self._panel:w() - PANEL_PADDING * 2,
			h = self._progress_panel:h(),
			x = PANEL_PADDING
		})
	else
		local texture = "guis/textures/menu_tickbox"
		local texture_rect = {
			trophy_objective.completed and 24 or 0,
			0,
			24,
			24
		}
		self._checkbox = self._panel:bitmap({
			name = "checkbox",
			layer = 1,
			visible = true,
			valign = "scale",
			halign = "scale",
			texture = texture,
			texture_rect = texture_rect
		})

		self._checkbox:set_right(self._panel:w())
		self._checkbox:set_top(self._panel:h() * 0.5 - self._checkbox:h() * 0.5)
	end
end

function CustomSafehouseGuiProgressItem:destroy()
	self._parent:remove(self._panel)
end

function CustomSafehouseGuiProgressItem:top()
	return self._panel:top()
end

function CustomSafehouseGuiProgressItem:bottom()
	return self._panel:bottom()
end

function CustomSafehouseGuiProgressItem:set_top(y)
	return self._panel:set_top(y)
end

function CustomSafehouseGuiProgressItem:set_bottom(y)
	return self._panel:set_bottom(y)
end

function CustomSafehouseGuiProgressItem:set_w(w)
	self._panel:set_w(w)

	if alive(self._progress_panel) then
		self._progress_panel:set_w(w)
		self._progress_fill:set_w(w * self._objective.progress / self._objective.max_progress)
		self._progress_text:set_w(self._panel:w() - PANEL_PADDING * 2)
		self._progress_outline:close()

		self._progress_outline = BoxGuiObject:new(self._progress_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	if alive(self._checkbox) then
		self._checkbox:set_right(self._panel:w())
	end
end
