local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
InGameHeisterInteractionInitiator = InGameHeisterInteractionInitiator or class()

function InGameHeisterInteractionInitiator:modify_node(original_node, data)
	local node = original_node

	node:clean_items()

	local params = {
		visible_callback = "is_pc_controller",
		name = "accept",
		callback = "heister_interaction_resume_game",
		text_id = "civilian_heister_daily_info_ok",
		align = "center",
		help_id = "menu_diff_help"
	}
	local data_node = {}
	local new_item = node:create_item(data_node, params)

	new_item:set_enabled(true)
	node:add_item(new_item)
	node:set_default_item_name(self.DEFAULT_ITEM)
	node:select_item(self.DEFAULT_ITEM)

	return node
end

function InGameHeisterInteractionInitiator:refresh_node(node)
	return node
end

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

InGameHeisterInteractionGui = InGameHeisterInteractionGui or class(MenuNodeGui)
InGameHeisterInteractionGui.WIDTH = 740
InGameHeisterInteractionGui.HEIGHT = 400
InGameHeisterInteractionGui.MENU_WIDTH = 220
InGameHeisterInteractionGui.PADDING = 10

function InGameHeisterInteractionGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true

	InGameHeisterInteractionGui.super.init(self, node, layer, parameters)
	self:_setup_default()

	if managers.custom_safehouse:has_rewarded_daily() then
		self._complete_t = 1.1

		self:_setup_daily_complete()
	else
		self:_setup_layout()
	end

	managers.menu_component:post_event("pop_up_safehouse")
end

function InGameHeisterInteractionGui:_setup_item_panel_parent(safe_rect, shape)
	local x = safe_rect.x + safe_rect.width / 2 - self.WIDTH / 2 + self.PADDING
	local y = safe_rect.y + safe_rect.height / 2 - self.HEIGHT / 2 + self.PADDING
	shape = {
		x = x,
		y = y,
		w = self.WIDTH,
		h = self.HEIGHT
	}

	InGameHeisterInteractionGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function InGameHeisterInteractionGui:set_contact_info(id, name, files, override_file, sub_text)
end

function InGameHeisterInteractionGui:mouse_moved(button, x, y)
	local button_highlighted = false

	if not button_highlighted then
		for _, button in ipairs(self._reward_buttons) do
			if not button_highlighted and button:inside(x, y) then
				button:set_selected(true)

				button_highlighted = true
			else
				button:set_selected(false)
			end
		end
	end

	if button_highlighted then
		return button_highlighted, "link"
	end
end

function InGameHeisterInteractionGui:mouse_pressed(button, x, y)
	for idx, button in pairs(self._reward_buttons or {}) do
		if button:inside(x, y) then
			button:trigger()

			return true
		end
	end
end

function InGameHeisterInteractionGui:mouse_released(button, x, y)
	if self._file_pressed and self._file_pressed ~= self._current_file then
		local files_menu = self._files_menu

		if alive(files_menu) then
			local file = files_menu:children()[self._file_pressed]

			if file and file:inside(x, y) then
				self:set_file(self._file_pressed)
				managers.menu_component:post_event("menu_enter")
			end
		end
	end

	self._file_pressed = false
end

function InGameHeisterInteractionGui:previous_page()
	self:change_file(-1)
end

function InGameHeisterInteractionGui:next_page()
	self:change_file(1)
end

function InGameHeisterInteractionGui:input_focus()
	return false
end

function InGameHeisterInteractionGui:_setup_item_panel(safe_rect, res)
	InGameHeisterInteractionGui.super._setup_item_panel(self, safe_rect, res)
end

function InGameHeisterInteractionGui:_setup_menu()
	if not self._init_finish then
		return
	end

	if self._setup_menu_done then
		return
	end

	local safe_rect = managers.gui_data:scaled_size()

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("right")
	end

	self:_set_topic_position()

	local y_offs = 160

	self.item_panel:set_w(self.WIDTH)
	self.item_panel:move(-80, self.HEIGHT - 35)

	self._setup_menu_done = true
end

function InGameHeisterInteractionGui:_fade_row_item(row_item)
	InGameHeisterInteractionGui.super._fade_row_item(self, row_item)

	if row_item.icon then
		row_item.icon:set_left(0)
	end
end

function InGameHeisterInteractionGui:_highlight_row_item(row_item, mouse_over)
	InGameHeisterInteractionGui.super._highlight_row_item(self, row_item, mouse_over)

	if row_item.icon then
		row_item.icon:set_left(0)
	end
end

function InGameHeisterInteractionGui:refresh_gui(node)
	return node
end

local header_text_desc_height = 80
local obj_text_desc_height = 60

function InGameHeisterInteractionGui:_setup_default()
	local daily_challenge = managers.custom_safehouse:get_daily_challenge()
	local daily_info = tweak_data.safehouse:get_daily_data(daily_challenge.id)
	local safe_rect = managers.gui_data:scaled_size()
	local mc_full_ws = managers.menu_component:fullscreen_ws()
	local ws = self.ws

	if alive(self._fullscreen_panel) then
		mc_full_ws:panel():remove(self._fullscreen_panel)
	end

	if alive(ws:panel():child("main_panel")) then
		ws:panel():remove(ws:panel():child("main_panel"))
	end

	local main_panel = ws:panel():panel({
		name = "main_panel"
	})
	self._main_panel = main_panel
	self._fullscreen_panel = mc_full_ws:panel():panel({
		layer = 0
	})
	local width = self.WIDTH
	local height = self.HEIGHT
	self._panel = main_panel:panel({
		layer = 1,
		h = height,
		w = width
	})

	self._panel:set_center(self._main_panel:w() / 2, self._main_panel:h() / 2)
	self._panel:rect({
		alpha = 0.6,
		layer = 0,
		color = Color.black
	})
	BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local txt = managers.localization:to_upper_text("menu_cs_div_safehouse_daily") .. ": "
	local header_panel = self._panel:panel({
		layer = 1,
		h = small_font_size,
		w = width - self.PADDING * 2
	})

	header_panel:move(self.PADDING * 0.5, self.PADDING * 0.5)

	local header_text = header_panel:text({
		name = "header_text",
		layer = 1,
		text = txt,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.challenge_title
	})

	make_fine_text(header_text)

	local header_text_desc = header_panel:text({
		name = "header_text_desc",
		layer = 51,
		x = header_text:width(),
		h = header_text_desc_height,
		text = managers.localization:to_upper_text(daily_info.id),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(header_text_desc)
end

function InGameHeisterInteractionGui:_setup_layout()
	self._reward_buttons = {}
	local daily_challenge = managers.custom_safehouse:get_daily_challenge()
	local daily_info = tweak_data.safehouse:get_daily_data(daily_challenge.id)
	local reward_panel_w_offs = -50
	local reward_panel_h_offs = 20
	local reward_panel_pos = nil
	local width = self.WIDTH
	local height = self.HEIGHT
	self._scroll_panel = self._panel:panel({
		h = height - small_font_size * 3 - self.PADDING * 2,
		w = width - self.PADDING * 2
	})
	self._anim_box = BoxGuiObject:new(self._scroll_panel, {
		sides = {
			0,
			0,
			0,
			2
		}
	})

	self._scroll_panel:move(self.PADDING, self.PADDING + small_font_size)

	local desc_panel = self._scroll_panel:panel({
		layer = 1,
		h = header_text_desc_height,
		w = self._scroll_panel:w()
	})
	local desc_text = desc_panel:text({
		name = "desc_text",
		wrap = true,
		layer = 1,
		text = managers.localization:text(daily_info.desc_id),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})
	local obj_panel = self._scroll_panel:panel({
		layer = 1,
		h = small_font_size,
		w = self._scroll_panel:w()
	})

	obj_panel:move(self.PADDING * 0.5, header_text_desc_height)

	local obj_text = obj_panel:text({
		name = "objective_text",
		layer = 1,
		text = managers.localization:to_upper_text("hud_objective"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.challenge_title
	})

	make_fine_text(obj_text)

	local obj_desc_panel = self._scroll_panel:panel({
		layer = 1,
		h = obj_text_desc_height,
		w = self._scroll_panel:w()
	})

	obj_desc_panel:move(self.PADDING * 0.5, header_text_desc_height + small_font_size)

	local macros = {}

	if daily_challenge.trophy and daily_challenge.trophy.objectives and #daily_challenge.trophy.objectives > 0 then
		local max = 0

		for idx, objective in ipairs(daily_challenge.trophy.objectives) do
			max = math.max(max, objective.max_progress)
		end

		macros.max_progress = tostring(max)
	end

	local obj_desc_text = obj_desc_panel:text({
		name = "objective_desc_text",
		wrap = true,
		layer = 1,
		text = managers.localization:text(daily_info.objective_id, macros),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(obj_desc_text)

	local expire_panel_pos = header_text_desc_height + small_font_size + obj_desc_panel:h()
	local expire_panel = self._scroll_panel:panel({
		layer = 1,
		h = small_font_size,
		w = width
	})

	expire_panel:move(self.PADDING * 0.5, expire_panel_pos)
	expire_panel:rect({
		color = tweak_data.screen_colors.important_2:with_alpha(0.2)
	})

	local expire_text = expire_panel:text({
		blend_mode = "add",
		name = "ExpiryTime",
		vertical = "top",
		valign = "top",
		align = "center",
		text = "",
		halign = "center",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.important_2:with_alpha(0.3)
	})
	self._expire_time_text = expire_text
	self._expire_panel = expire_panel
	local reward_panel_pos = expire_panel_pos + expire_panel:h()
	local reward_panel = self._scroll_panel:panel({
		h = 128,
		layer = 1,
		w = self._scroll_panel:w()
	})

	reward_panel:move(self.PADDING * 0.5, reward_panel_pos)

	local reward_header = reward_panel:text({
		name = "reward_text",
		layer = 51,
		text = managers.localization:to_upper_text("menu_reward"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.challenge_title
	})

	make_fine_text(reward_header)

	local first = true

	for idx, reward in ipairs(daily_challenge.rewards) do
		local reward_item = CustomSafehouseGuiRewardItem:new(self, reward_panel, idx, reward, daily_info.id, true)

		reward_item._panel:move(self._scroll_panel:w() - self.PADDING * 2 - 128 * idx, 0)
		table.insert(self._reward_buttons, reward_item)

		if not managers.menu:is_pc_controller() then
			reward_item:set_selected(first)

			first = false
		end
	end

	if daily_challenge.reward_id then
		local reward_text = reward_panel:text({
			blend_mode = "add",
			name = "RewardBody",
			wrap = true,
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			text = managers.localization:text(daily_challenge.reward_id)
		})

		reward_text:move(0, 20)
		make_fine_text(reward_text)
	end

	self._init_finish = true

	if managers.custom_safehouse:is_daily_new() then
		managers.custom_safehouse:mark_daily_as_seen()
	end

	self:_setup_menu()
	self:set_animation_state("_update_daily")
end

function InGameHeisterInteractionGui:_setup_daily_complete()
	self._reward_buttons = {}
	local width = self.WIDTH
	local height = self.HEIGHT
	local y_offs = 80
	self._daily_complete_panel = self._panel:panel({
		h = height - self.PADDING * 2,
		w = width - self.PADDING * 2
	})

	self._daily_complete_panel:move(self.PADDING, self.PADDING + small_font_size)

	local header = self._daily_complete_panel:text({
		name = "DailyCompleteTitle",
		blend_mode = "add",
		vertical = "top",
		align = "center",
		valign = "top",
		halign = "center",
		layer = 1,
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.challenge_title,
		text = utf8.to_upper(managers.localization:text("menu_es_daily_complete")),
		w = self._daily_complete_panel:w()
	})
	self._complete_header_text = header

	make_fine_text(header)
	header:set_center_x(self._daily_complete_panel:center_x())
	header:set_y(self._daily_complete_panel:center_y() - medium_font_size * 3 - y_offs)

	local timer_panel = self._daily_complete_panel:panel({
		name = "DailyRenewPanel",
		w = self._daily_complete_panel:w() * 0.9,
		h = medium_font_size
	})

	timer_panel:set_left(self._daily_complete_panel:panel():w() * 0.5 - timer_panel:w() * 0.5)
	timer_panel:set_top(header:bottom() + self.PADDING)
	timer_panel:rect({
		color = tweak_data.screen_colors.challenge_title:with_alpha(0.4)
	})

	self._complete_timer_panel = timer_panel
	local timer_text = timer_panel:text({
		blend_mode = "add",
		name = "TimerText",
		vertical = "top",
		valign = "top",
		align = "center",
		text = "",
		halign = "center",
		layer = 1,
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.challenge_title:with_alpha(1)
	})
	self._renew_timer = timer_text
	local text = self._daily_complete_panel:text({
		name = "DailyCompleteInfo",
		blend_mode = "add",
		vertical = "top",
		align = "center",
		valign = "top",
		halign = "center",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text,
		text = managers.localization:text("menu_es_daily_complete_desc"),
		w = self._daily_complete_panel:w() * 0.7
	})
	local _, _, _, text_h = text:text_rect()

	text:set_h(text_h)
	text:set_center_x(self._daily_complete_panel:center_x())
	text:set_top(timer_panel:bottom() + self.PADDING)

	self._complete_info = text
	self._init_finish = true

	self:set_animation_state("_update_show_complete")
	self._complete_info:set_visible(false)
	self._complete_timer_panel:set_visible(false)
	self._complete_header_text:set_visible(false)
	self:_setup_menu()
end

function InGameHeisterInteractionGui:update(t, dt)
	self:_update_animation(t, dt)
end

function InGameHeisterInteractionGui:set_animation_state(state)
	self._anim_state = state
end

function InGameHeisterInteractionGui:_update_daily(t, dt)
	if alive(self._expire_time_text) then
		local expire_string = ""
		local challenge = managers.custom_safehouse:get_daily_challenge()
		local timestamp = challenge.timestamp
		local expire_timestamp = managers.custom_safehouse:daily_challenge_interval() + timestamp
		local current_timestamp = managers.custom_safehouse:get_timestamp()
		local expire_time = expire_timestamp - current_timestamp
		expire_string = MenuNodeCrimenetChallengeGui._create_timestamp_string_extended(self, expire_time)

		self._expire_time_text:set_text(expire_string)
		self._expire_panel:set_visible(true)
	end
end

function InGameHeisterInteractionGui:_update_hide_daily(t, dt)
	self._complete_t = (self._complete_t or 0) + dt

	if self._complete_t > 1 then
		local h = self._scroll_panel:h()
		h = h - h * 4 * dt

		self._scroll_panel:set_h(h)

		if self._anim_box then
			self._anim_box:close()
		end

		if h <= 1 then
			self._complete_t = 0

			self:set_animation_state("_update_show_complete")
			self._scroll_panel:clear()
			self:_setup_daily_complete()
		else
			self._anim_box = BoxGuiObject:new(self._scroll_panel, {
				sides = {
					0,
					0,
					0,
					2
				}
			})
		end
	end
end

function InGameHeisterInteractionGui:_update_show_complete(t, dt)
	self._complete_t = (self._complete_t or 0) + dt
	local base_time = 0.8
	local step_time = 0.5

	if base_time < self._complete_t and self._complete_header_text and not self._complete_header_text:visible() then
		self._complete_header_text:set_visible(true)
		managers.menu_component:post_event("box_tick")
	end

	if self._complete_t > base_time + step_time and self._complete_info and not self._complete_info:visible() then
		self._complete_info:set_visible(true)
		managers.menu_component:post_event("box_tick")
	end

	if self._complete_t > base_time + step_time * 2 and self._complete_timer_panel and not self._complete_timer_panel:visible() then
		self._complete_timer_panel:set_visible(true)
		managers.menu_component:post_event("box_tick")
		self:set_animation_state("_update_renew_daily")
	end
end

function InGameHeisterInteractionGui:_update_renew_daily(t, dt)
	if alive(self._renew_timer) then
		local challenge = managers.custom_safehouse:get_daily_challenge()
		local expire_timestamp = challenge.timestamp + managers.custom_safehouse:interval_til_new_daily()
		local current_timestamp = managers.custom_safehouse:get_timestamp()
		local expire_time = expire_timestamp - current_timestamp
		local expire_string = CustomSafehouseGuiPageDaily._create_renew_timestamp_string_extended(self, expire_time)

		self._renew_timer:set_text(expire_string)
	end
end

function InGameHeisterInteractionGui:_update_animation(t, dt)
	if self._anim_state and self[self._anim_state] then
		self[self._anim_state](self, t, dt)
	end
end

function InGameHeisterInteractionGui:close()
	MenuNodeCrimenetContactChillGui.super.close(self)
end

function InGameHeisterInteractionGui:move_reward_button(dir)
	if not self._reward_buttons or #self._reward_buttons == 0 then
		return
	end

	local current_button = nil

	for i, button in ipairs(self._reward_buttons) do
		if button:is_selected() then
			button:set_selected(false)

			current_button = i
		end
	end

	if not current_button then
		current_button = 1
		dir = 0
	end

	if dir > 0 then
		dir = 1
	elseif dir < 0 then
		dir = -1
	end

	local next_button = current_button + dir

	if next_button > #self._reward_buttons then
		next_button = 1
	elseif next_button < 1 then
		next_button = #self._reward_buttons
	end

	self._reward_buttons[next_button]:set_selected(true)
end

function InGameHeisterInteractionGui:special_btn_pressed(button)
	if button == Idstring("menu_modify_item") then
		for _, btn in pairs(self._reward_buttons) do
			btn:trigger()
		end
	end
end

function InGameHeisterInteractionGui:move_left()
	self:move_reward_button(-1)
end

function InGameHeisterInteractionGui:move_right()
	self:move_reward_button(1)
end

function InGameHeisterInteractionGui:_update_buttons()
end
