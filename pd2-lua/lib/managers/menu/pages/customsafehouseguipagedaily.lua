local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local done_icon = "guis/textures/menu_singletick"
local reward_icon = "guis/textures/pd2/icon_reward"
local selected_icon = "guis/textures/scrollarrow"
local done_rotation = 0
local reward_rotation = 0
local selected_rotation = 270
local PANEL_PADDING = 10
local LINE_PADDING = 4
local REWARD_SIZE = 128
CustomSafehouseGuiPageDaily = CustomSafehouseGuiPageDaily or class(CustomSafehouseGuiPage)

function CustomSafehouseGuiPageDaily:init(page_id, page_panel, fullscreen_panel, gui)
	CustomSafehouseGuiPageDaily.super.init(self, page_id, page_panel, fullscreen_panel, gui)

	self.make_fine_text = BlackMarketGui.make_fine_text
	self._create_timestamp_string_extended = MenuNodeCrimenetChallengeGui._create_timestamp_string_extended
	self._go_to_safehouse = CustomSafehouseGuiPageMap._go_to_safehouse
	self.go_to_safehouse = CustomSafehouseGuiPageMap.go_to_safehouse
	self._panel_original_h = self:panel():h()
	self._buttons = {}
	self._scrollable_panels = {}
	self._reward_buttons = {}
	local w = self:info_panel():w()

	self:info_panel():grow(-w, 0)
	self:panel():grow(w, 0)
	self:_setup_side_menu()

	if not managers.menu:is_pc_controller() then
		self:_setup_daily_info()
	end
end

function CustomSafehouseGuiPageDaily:set_active(active)
	if active and managers.features:can_announce("safehouse_dailies") then
		managers.features:announce_feature("safehouse_dailies")
	end

	return CustomSafehouseGuiPageDaily.super.set_active(self, active)
end

function CustomSafehouseGuiPageDaily:select_challenge(id, skip_sound)
	self:finish_animation()
	self:_setup_challenge(id)

	self._current_challenge = id

	self:_update_buttons()

	if not skip_sound then
		managers.menu_component:post_event("menu_enter")
	end

	self._gui:update_legend()
end

function CustomSafehouseGuiPageDaily:_setup_side_menu()
	local side_panel_parent = self:daily_panel():panel({
		layer = 10,
		name = "SidePanel"
	})

	side_panel_parent:set_w((self:daily_panel():w() - PANEL_PADDING * 2) * 0.25)
	side_panel_parent:set_h(self:daily_panel():h() - PANEL_PADDING * 2)

	self._side_panel = ScrollablePanel:new(side_panel_parent, "SidePanel", {
		padding = PANEL_PADDING
	})

	table.insert(self._scrollable_panels, self._side_panel)

	local categories = {
		"safehouse_daily",
		"daily",
		"weekly",
		"monthly"
	}

	if managers.dlc:has_dlc("tango") then
		table.insert(categories, "tango")
	end

	for _, side_job_dlc in ipairs(managers.generic_side_jobs:side_jobs()) do
		if side_job_dlc.manager:can_progress() then
			table.insert(categories, side_job_dlc.manager.category)
		end
	end

	self._side_panel_buttons = {}
	self._side_panel_categories = {}
	local challenges = {}
	self._challenges = {}

	for _, challenge in pairs(managers.challenge:get_all_active_challenges()) do
		local category = challenge.category or "daily"
		challenges[category] = challenges[category] or {}
		local chall = {
			data = deep_clone(challenge)
		}
		chall.data.category = category
		chall.id = challenge.id

		table.insert(challenges[category], chall)

		self._challenges[chall.id] = chall.data
	end

	for k, v in pairs(challenges) do
		v.category_id = "menu_challenge_div_cat_" .. k
	end

	local current_daily = managers.custom_safehouse:get_daily_challenge()
	local daily_data = deep_clone(current_daily)
	daily_data.name_id = daily_data.id
	daily_data.category = "safehouse_daily"
	challenges.safehouse_daily = {
		{
			id = current_daily.id,
			data = daily_data
		},
		category_id = "menu_cs_div_safehouse_daily"
	}
	self._challenges[current_daily.id] = challenges.safehouse_daily[1].data

	if managers.dlc:has_dlc("tango") then
		challenges.tango = {
			category_id = "menu_tango"
		}

		for _, tango_data in ipairs(managers.tango:challenges()) do
			local data = deep_clone(tango_data)
			data.name_id = tango_data.name_id
			data.category = "tango"
			local tango_challenge = {
				id = tango_data.id,
				data = data
			}

			table.insert(challenges.tango, tango_challenge)

			self._challenges[tango_challenge.id] = tango_challenge.data
		end
	end

	for _, side_job_dlc in ipairs(managers.generic_side_jobs:side_jobs()) do
		if side_job_dlc.manager:can_progress() then
			challenges[side_job_dlc.manager.category] = {
				category_id = side_job_dlc.manager.category_id
			}

			for _, challenge_data in ipairs(side_job_dlc.manager:challenges()) do
				local data = deep_clone(challenge_data)
				data.name_id = challenge_data.name_id
				data.category = side_job_dlc.manager.category
				local challenge = {
					id = challenge_data.id,
					data = data
				}

				table.insert(challenges[side_job_dlc.manager.category], challenge)

				self._challenges[challenge.id] = challenge.data
			end
		end
	end

	local current_y = 0
	local first = true

	for _, category in ipairs(categories) do
		if challenges[category] then
			local category_item = {
				text = self._side_panel:canvas():text({
					y = current_y,
					text = managers.localization:to_upper_text(challenges[category].category_id),
					font = small_font,
					font_size = small_font_size
				})
			}

			self:make_fine_text(category_item.text)

			current_y = current_y + category_item.text:h()

			table.insert(self._side_panel_categories, category_item)

			for i, challenge in ipairs(challenges[category]) do
				local completed = self:is_safehouse_daily(challenge.id) and managers.custom_safehouse:has_completed_daily(challenge.id) or challenge.data.completed
				local rewarded = self:is_safehouse_daily(challenge.id) and managers.custom_safehouse:has_rewarded_daily(challenge.id) or challenge.data.rewarded
				local icon = rewarded and done_icon or completed and reward_icon
				local color = rewarded and tweak_data.screen_colors.text:with_alpha(0.5) or completed and tweak_data.screen_colors.challenge_completed_color
				local button_data = {
					align = "left",
					name_id = challenge.data.name_id,
					y = current_y,
					custom = challenge.id,
					icon = icon,
					color = color or tweak_data.screen_colors.button_stage_3,
					selected_color = color or tweak_data.screen_colors.button_stage_2
				}
				local button = CustomSafehouseGuiButtonItemWithIcon:new(self._side_panel:canvas(), button_data, 0, i)

				self:make_fine_text(button._btn_text)

				current_y = current_y + button._btn_text:h()

				table.insert(self._side_panel_buttons, button)

				if first then
					button:set_selected(true, false)
					button:set_icon(selected_icon)
					button:icon():set_rotation(selected_rotation)

					first = false

					self:select_challenge(challenge.id, true)
				end
			end
		end
	end

	self._side_panel:update_canvas_size()
end

function CustomSafehouseGuiPageDaily:_update_buttons()
	for _, button in ipairs(self._side_panel_buttons) do
		local id = button:get_custom_data()
		local is_safehouse_daily = self:is_safehouse_daily(id)
		local completed, rewarded = nil

		if is_safehouse_daily then
			rewarded = managers.custom_safehouse:has_rewarded_daily()
			completed = managers.custom_safehouse:has_completed_daily()
		else
			local challenge = managers.challenge:get_active_challenge(id)
			challenge = challenge or managers.tango:get_challenge(id)

			for _, side_job_dlc in ipairs(managers.generic_side_jobs:side_jobs()) do
				if side_job_dlc.manager:can_progress() then
					challenge = challenge or side_job_dlc.manager:get_challenge(id)
				end
			end

			rewarded = challenge and challenge.rewarded
			completed = challenge and challenge.completed
		end

		if rewarded then
			button:set_color(tweak_data.screen_colors.text:with_alpha(0.5))
			button:set_icon(done_icon)
			button:icon():set_rotation(done_rotation)
		elseif completed then
			button:set_color(tweak_data.screen_colors.challenge_completed_color)
			button:set_icon(reward_icon)
			button:icon():set_rotation(reward_rotation)
		else
			button:set_color(tweak_data.screen_colors.button_stage_3, tweak_data.screen_colors.button_stage_2)
			button:set_icon(nil)
		end

		if button:is_selected() then
			button:set_icon(selected_icon)
			button:icon():set_rotation(selected_rotation)
		end
	end
end

function CustomSafehouseGuiPageDaily:_setup_daily_info()
	local buttons = {}
	local show_play_safehouse_btn = (Global.game_settings.single_player or Network:is_server() or not managers.network:session()) and not self._gui._in_game

	if show_play_safehouse_btn then
		table.insert(buttons, {
			btn = "BTN_X",
			name_id = "menu_cs_enter_safehouse",
			pc_btn = "menu_remove_item",
			callback = callback(self, self, "go_to_safehouse")
		})
	end

	if not managers.menu:is_pc_controller() then
		table.insert(buttons, {
			btn = "BTN_A",
			name_id = "menu_cs_select_challenge"
		})
		table.insert(buttons, {
			btn = "BTN_Y",
			name_id = "menu_cs_claim_reward",
			pc_btn = "menu_modify_item",
			callback = callback(self, self, "claim_reward")
		})
	end

	self._info_container = self:info_panel():panel({
		h = self:info_panel():h()
	})

	if #buttons > 0 then
		self._buttons_container = self:info_panel():panel({
			h = small_font_size * #buttons + PANEL_PADDING * 2
		})

		self._buttons_container:set_bottom(self:info_panel():bottom())
		BoxGuiObject:new(self._buttons_container, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		self._info_container:set_h(self:info_panel():h() - self._buttons_container:h() - PANEL_PADDING)
	end

	self._buttons = {}
	self._controllers_mapping = {}

	if #buttons > 0 then
		local btn_x = PANEL_PADDING

		for btn, btn_data in pairs(buttons) do
			local new_button = CustomSafehouseGuiButtonItem:new(self._buttons_container, btn_data, btn_x, btn)
			self._buttons[btn] = new_button

			if btn_data.pc_btn then
				self._controllers_mapping[btn_data.pc_btn:key()] = new_button
			end
		end
	end

	local scroll = ScrollablePanel:new(self._info_container, "ChallengeInfoPanel")

	BoxGuiObject:new(scroll:panel(), {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	table.insert(self._scrollable_panels, scroll)

	local text_title = scroll:canvas():text({
		name = "TitleText",
		blend_mode = "add",
		align = "left",
		vertical = "top",
		valign = "scale",
		halign = "scale",
		layer = 1,
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.title,
		text = utf8.to_upper(managers.localization:text("menu_cs_daily_title")),
		w = scroll:canvas():w(),
		h = medium_font_size
	})
	local text_desc = scroll:canvas():text({
		name = "DescText",
		wrap = true,
		align = "left",
		vertical = "top",
		valign = "top",
		blend_mode = "add",
		halign = "left",
		word_wrap = true,
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.title,
		text = managers.localization:text("menu_cs_daily_desc", {
			NL = "\n"
		}),
		w = scroll:canvas():w(),
		h = medium_font_size,
		w = scroll:canvas():w()
	})

	text_desc:set_top(text_title:bottom() + PANEL_PADDING)
	self:make_fine_text(text_desc)
	scroll:update_canvas_size()
end

function CustomSafehouseGuiPageDaily:daily_panel()
	if not self._daily_panel then
		self._daily_panel = self:panel():panel({})
	end

	return self._daily_panel
end

function CustomSafehouseGuiPageDaily:challenge_panel()
	if not self._challenge_panel then
		local challenge_panel_w = self:daily_panel():w() - self._side_panel:panel():w()
		local side_right = self._side_panel:panel():right()
		self._challenge_panel = self:daily_panel():panel({
			h = self:daily_panel():h() - PANEL_PADDING * 2,
			w = challenge_panel_w - PANEL_PADDING * 2,
			x = side_right + 7,
			y = PANEL_PADDING
		})
	end

	return self._challenge_panel
end

function CustomSafehouseGuiPageDaily:is_safehouse_daily(id)
	return managers.custom_safehouse:get_daily(id) and true or false
end

function CustomSafehouseGuiPageDaily:_setup_challenge(id)
	self._reward_buttons = {}

	self:challenge_panel():clear()

	local is_safehouse_daily = self:is_safehouse_daily(id)

	if is_safehouse_daily and managers.custom_safehouse:has_completed_daily() and managers.custom_safehouse:has_rewarded_daily() then
		self:_setup_safehouse_daily_complete()

		return
	end

	local daily_challenge = self._challenges[id]

	if not daily_challenge then
		Application:error("[CustomSafehouseGuiPageDaily:_setup_challenge] invalid challenge:", id)

		return
	end

	local daily_info = tweak_data.safehouse:get_daily_data(daily_challenge.id)
	daily_info = daily_info or daily_challenge
	local challenge_h = self:challenge_panel():h()
	local rewards_container = nil

	if daily_challenge.rewards then
		rewards_container = self:challenge_panel():panel({
			w = self:challenge_panel():w(),
			h = REWARD_SIZE + PANEL_PADDING + small_font_size
		})

		rewards_container:set_bottom(self:challenge_panel():bottom() - PANEL_PADDING)

		challenge_h = challenge_h - rewards_container:h() - PANEL_PADDING
	end

	local title_text = managers.localization:to_upper_text(daily_challenge.name_id)
	local title = self:challenge_panel():text({
		text = title_text,
		font = medium_font,
		font_size = medium_font_size,
		selection_color = tweak_data.screen_colors.challenge_title
	})

	if daily_challenge.category ~= "menu" then
		local prefix_id = daily_challenge.category == "safehouse_daily" and "menu_cs_div_safehouse_daily" or "menu_challenge_div_cat_" .. daily_challenge.category
		local prefix_text = prefix_id and managers.localization:to_upper_text(prefix_id) .. ": "
		local prefix_len = utf8.len(prefix_text)

		title:set_text(prefix_text .. title:text())
		title:set_selection(0, prefix_len)
	end

	self:make_fine_text(title)

	local scroll_container = self:challenge_panel():panel({
		y = title:bottom() + PANEL_PADDING,
		h = challenge_h - title:h() - PANEL_PADDING * 2
	})
	local scroll = ScrollablePanel:new(scroll_container, "ChallengePanel", {
		padding = 0.001
	})

	scroll:on_canvas_updated_callback(callback(self, self, "_update_daily_panel_size"))

	self._challenge_scroll = scroll

	table.insert(self._scrollable_panels, scroll)

	local current_y = 0
	local description_text = scroll:canvas():text({
		blend_mode = "add",
		name = "DescText",
		word_wrap = true,
		wrap = true,
		align = "left",
		vertical = "top",
		valign = "scale",
		halign = "scale",
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.title,
		text = managers.localization:text(daily_info.desc_id)
	})

	description_text:set_top(0)

	local _, _, _, h = description_text:text_rect()

	description_text:set_h(h)

	current_y = description_text:bottom()

	if daily_info.objective_id or daily_info.objectives then
		local objective_title = scroll:canvas():text({
			name = "ObjectiveHeader",
			blend_mode = "add",
			align = "left",
			vertical = "top",
			valign = "scale",
			halign = "scale",
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.challenge_title,
			text = utf8.to_upper(managers.localization:text("menu_challenge_objective_title")),
			w = scroll:canvas():w(),
			h = small_font_size
		})

		objective_title:set_top(current_y + PANEL_PADDING * 2)

		current_y = objective_title:bottom()
		local macros = {}

		if daily_challenge.trophy and daily_challenge.trophy.objectives and #daily_challenge.trophy.objectives > 0 then
			local max = 0

			for idx, objective in ipairs(daily_challenge.trophy.objectives) do
				max = math.max(max, objective.max_progress)
			end

			macros.max_progress = tostring(max)
		end

		local objective_count = daily_info.objectives and #daily_info.objectives or 1

		for i = 1, objective_count do
			if daily_info.objectives and daily_info.objectives[i] then
				local max = daily_info.objectives[i].max_progress
				local current = daily_info.objectives[i].progress

				if max and current then
					macros.max_progress = tostring(max)
					macros.progress = tostring(current)
				end
			end

			local objective_str = managers.localization:text(daily_info.objective_id or daily_info.objectives[i].desc_id, macros)

			print("daily_info.objectives[i].display: ", daily_info.objectives[i].display)

			if daily_info.objectives[i].display == false then
				objective_str = ""
			end

			local objective_text = scroll:canvas():text({
				name = "ObjectiveText",
				blend_mode = "add",
				wrap = true,
				align = "left",
				word_wrap = true,
				vertical = "top",
				valign = "scale",
				halign = "scale",
				layer = 1,
				font_size = small_font_size,
				font = small_font,
				color = tweak_data.screen_colors.title,
				text = objective_str,
				w = scroll:canvas():w()
			})

			objective_text:set_top(current_y)

			local _, _, _, h = objective_text:text_rect()

			objective_text:set_h(h)

			current_y = objective_text:bottom()
		end
	end

	if daily_info.show_progress then
		local progress_title = scroll:canvas():text({
			name = "ProgressHeader",
			blend_mode = "add",
			vertical = "top",
			align = "left",
			valign = "scale",
			halign = "scale",
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.challenge_title,
			text = utf8.to_upper(managers.localization:text("menu_unlock_progress")),
			w = scroll:canvas():w()
		})

		progress_title:set_top(current_y + PANEL_PADDING * 2)
		self:make_fine_text(progress_title)

		current_y = progress_title:bottom()
		self._progress_items = {}
		local objectives = daily_challenge.trophy and daily_challenge.trophy.objectives or daily_challenge.objectives

		for idx, objective in ipairs(objectives) do
			local item = CustomSafehouseGuiProgressItem:new(scroll:canvas(), objective)

			table.insert(self._progress_items, item)

			local pos = current_y

			item:set_top(pos)

			current_y = item:bottom()
		end
	end

	if daily_challenge.rewards then
		local updated_challenge = self:is_safehouse_daily(id) and managers.custom_safehouse:get_daily_challenge() or managers.challenge:get_active_challenge(id)
		updated_challenge = updated_challenge or managers.tango:get_challenge(id)

		for _, side_job_dlc in ipairs(managers.generic_side_jobs:side_jobs()) do
			if side_job_dlc.manager:can_progress() then
				updated_challenge = updated_challenge or side_job_dlc.manager:get_challenge(id)
			end
		end

		updated_challenge = updated_challenge or daily_challenge
		local rewards_panel = rewards_container:panel({
			w = REWARD_SIZE * #daily_challenge.rewards,
			h = REWARD_SIZE
		})

		rewards_panel:set_x(rewards_container:w() - rewards_panel:w())
		rewards_panel:set_y(rewards_container:h() - rewards_panel:h())
		BoxGuiObject:new(rewards_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		local reward_title = rewards_container:text({
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
			text = updated_challenge.rewarded and managers.localization:to_upper_text("menu_cn_rewarded") or managers.localization:to_upper_text("menu_reward"),
			w = rewards_container:w()
		})

		self:make_fine_text(reward_title)
		reward_title:set_top(rewards_panel:top())

		local first = true

		for idx, reward in ipairs(updated_challenge.rewards) do
			local reward_item = CustomSafehouseGuiRewardItem:new(self, rewards_panel, idx, reward, id)

			table.insert(self._reward_buttons, reward_item)

			if not managers.menu:is_pc_controller() then
				reward_item:set_selected(first)

				first = false
			end
		end

		if daily_challenge.reward_s or daily_challenge.reward_id then
			local reward_text = rewards_container:text({
				blend_mode = "add",
				name = "RewardBody",
				wrap = true,
				layer = 1,
				font_size = small_font_size,
				font = small_font,
				text = daily_challenge.reward_s or managers.localization:text(daily_challenge.reward_id),
				w = rewards_container:w() - rewards_panel:w()
			})

			self:make_fine_text(reward_text)
			reward_text:set_top(reward_title:bottom())
		elseif daily_challenge.reward_type == "tango" then
			local reward_macros = {}

			for _, reward_data in ipairs(daily_challenge.rewards) do
				if reward_data.tango_mask then
					if tweak_data.blackmarket.masks[reward_data.tango_mask] then
						reward_macros.mask = managers.localization:text(tweak_data.blackmarket.masks[reward_data.tango_mask].name_id)
					end
				elseif reward_data.item_entry then
					local entry = tweak_data:get_raw_value("blackmarket", reward_data.type_items, reward_data.item_entry)

					if entry then
						reward_macros[reward_data.type_items == "masks" and "mask" or reward_data.type_items] = managers.localization:text(entry.name_id)
					end
				end
			end

			local reward_text = rewards_container:text({
				blend_mode = "add",
				name = "RewardBody",
				wrap = true,
				layer = 1,
				font_size = small_font_size,
				font = small_font,
				text = managers.localization:text("menu_tango_reward", reward_macros),
				w = rewards_container:w() - rewards_panel:w()
			})

			self:make_fine_text(reward_text)
			reward_text:set_top(reward_title:bottom())
		end

		local expiry_panel = rewards_container:panel({
			visible = false,
			w = rewards_container:w(),
			h = small_font_size
		})

		expiry_panel:set_bottom(rewards_panel:top() - PANEL_PADDING)
		expiry_panel:rect({
			color = tweak_data.screen_colors.important_2:with_alpha(0.2)
		})

		self._expire_panel = expiry_panel
		local expiry_time = expiry_panel:text({
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
		self._expire_timer = expiry_time
	end

	scroll:update_canvas_size()
end

function CustomSafehouseGuiPageDaily:_update_daily_panel_size(new_width)
	if not self._challenge_scroll or not alive(self._challenge_scroll:panel()) then
		return
	end

	local canvas = self._challenge_scroll:canvas()
	local desc_text = canvas:child("DescText")
	local objective_title = canvas:child("ObjectiveHeader")
	local objective_text = canvas:child("ObjectiveText")

	if new_width == desc_text:w() then
		return
	end

	desc_text:set_w(new_width)

	local _, _, _, h = desc_text:text_rect()

	desc_text:set_h(h)

	if alive(objective_title) then
		objective_title:set_top(desc_text:bottom() + PANEL_PADDING * 2)
	end

	if alive(objective_text) then
		objective_text:set_w(new_width)

		local _, _, _, h = objective_text:text_rect()

		objective_text:set_h(h)
		objective_text:set_top(objective_title:bottom())
	end

	if self._progress_items then
		local progress_title = canvas:child("ProgressHeader")

		if progress_title then
			progress_title:set_top(objective_text:bottom() + h + PANEL_PADDING * 2)

			for idx, item in ipairs(self._progress_items) do
				item:set_w(new_width - (self._challenge_scroll:is_scrollable() and PANEL_PADDING * 2 or 0))
				item:set_top(idx == 1 and progress_title:bottom() or self._progress_items[idx - 1]:bottom())
			end
		end
	end
end

function CustomSafehouseGuiPageDaily:complete_panel()
	if not alive(self._complete_panel) then
		self._complete_panel = self:challenge_panel():panel({})
	end

	return self._complete_panel
end

function CustomSafehouseGuiPageDaily:_setup_safehouse_daily_complete()
	self._reward_buttons = {}

	self:challenge_panel():clear()
	self:challenge_panel():set_h(self:daily_panel():h() - PANEL_PADDING * 2)

	local scroll = ScrollablePanel:new(self:complete_panel(), "DailyPanel")

	BoxGuiObject:new(scroll:panel(), {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._challenge_scroll = scroll

	table.insert(self._scrollable_panels, scroll)

	local header = scroll:canvas():text({
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
		w = scroll:canvas():w()
	})

	self:make_fine_text(header)
	header:set_center_x(scroll:panel():center_x())
	header:set_y(scroll:panel():center_y() - medium_font_size * 3)

	local timer_panel = scroll:canvas():panel({
		name = "DailyRenewPanel",
		w = scroll:canvas():w() * 0.9,
		h = medium_font_size
	})

	timer_panel:set_left(scroll:panel():w() * 0.5 - timer_panel:w() * 0.5)
	timer_panel:set_top(header:bottom() + PANEL_PADDING)
	timer_panel:rect({
		color = tweak_data.screen_colors.challenge_title:with_alpha(0.4)
	})

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
	local text = scroll:canvas():text({
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
		w = scroll:canvas():w() * 0.7
	})
	local _, _, _, text_h = text:text_rect()

	text:set_h(text_h)
	text:set_center_x(scroll:panel():center_x())
	text:set_top(timer_panel:bottom() + PANEL_PADDING)
	scroll:update_canvas_size()
end

function CustomSafehouseGuiPageDaily:_set_selected(item)
	if self._selected_item then
		self._selected_item:set_selected(false)
	end

	self._selected_item = item

	if item then
		self._selected_item:set_selected(true)
	end
end

function CustomSafehouseGuiPageDaily:_create_renew_timestamp_string_extended(timestamp)
	local minutes = 59 - tonumber(Application:date("%M"))
	local seconds = 59 - tonumber(Application:date("%S"))
	local expire_string = ""

	if timestamp >= 24 then
		expire_string = managers.localization:text("menu_daily_renew_time_extended_with_days", {
			days = math.floor(timestamp / 24),
			hours = timestamp % 24,
			minutes = minutes,
			seconds = seconds
		})
	elseif timestamp >= 0 then
		expire_string = managers.localization:text("menu_daily_renew_time_extended", {
			hours = timestamp,
			minutes = minutes,
			seconds = seconds
		})
	else
		expire_string = managers.localization:text("menu_daily_rewnew_soon")
	end

	return expire_string
end

function CustomSafehouseGuiPageDaily:update_renew_timer()
	if alive(self._renew_timer) then
		local challenge = managers.custom_safehouse:get_daily_challenge()
		local expire_timestamp = challenge.timestamp + managers.custom_safehouse:interval_til_new_daily()
		local current_timestamp = managers.custom_safehouse:get_timestamp()
		local expire_time = expire_timestamp - current_timestamp
		local expire_string = self:_create_renew_timestamp_string_extended(expire_time)

		self._renew_timer:set_text(expire_string)
	end
end

function CustomSafehouseGuiPageDaily:move_button(dir)
	local current_button = nil

	for i, button in ipairs(self._side_panel_buttons) do
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

	if next_button > #self._side_panel_buttons then
		next_button = 1
	elseif next_button < 1 then
		next_button = #self._side_panel_buttons
	end

	local to_select = self._side_panel_buttons[next_button]

	to_select:set_selected(true)
	self:_scroll_to_show(to_select._panel)
end

function CustomSafehouseGuiPageDaily:_scroll_to_show(top_or_item, bottom)
	local top = nil

	if top_or_item.top and top_or_item.bottom then
		top = top_or_item:top() - 24
		bottom = top_or_item:bottom()
	end

	bottom = bottom - self._side_panel:scroll_panel():h()
	local cur = -self._side_panel:canvas():y()

	if top < cur then
		self._side_panel:scroll_to(top)
	elseif cur < bottom then
		self._side_panel:scroll_to(bottom)
	end
end

function CustomSafehouseGuiPageDaily:move_reward_button(dir)
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

function CustomSafehouseGuiPageDaily:_update_controller(t, dt)
	if managers.system_menu and managers.system_menu:is_active() then
		return
	end

	local cx, cy = managers.menu_component:get_right_controller_axis()

	if cy ~= 0 and self._challenge_scroll then
		self._challenge_scroll:perform_scroll(math.abs(cy * 500 * dt), math.sign(cy))
	end
end

function CustomSafehouseGuiPageDaily:confirm_pressed()
	for _, button in ipairs(self._side_panel_buttons) do
		if button:is_selected() then
			self:select_challenge(button:get_custom_data())

			break
		end
	end
end

function CustomSafehouseGuiPageDaily:move_up()
	self:move_button(-1)
end

function CustomSafehouseGuiPageDaily:move_down()
	self:move_button(1)
end

function CustomSafehouseGuiPageDaily:move_left()
	self:move_reward_button(-1)
end

function CustomSafehouseGuiPageDaily:move_right()
	self:move_reward_button(1)
end

function CustomSafehouseGuiPageDaily:claim_reward()
	for _, button in ipairs(self._reward_buttons) do
		if button:is_selected() then
			button:trigger()

			break
		end
	end
end

function CustomSafehouseGuiPageDaily:update(t, dt)
	if not self._active then
		return
	end

	if not managers.menu:is_pc_controller() then
		self:_update_controller(t, dt)
	end

	if self:is_safehouse_daily(self._current_challenge) and managers.custom_safehouse:is_daily_new() then
		managers.custom_safehouse:mark_daily_as_seen()
	end

	if self._challenge_scroll and alive(self._challenge_scroll:panel()) then
		local is_safehouse_daily = self:is_safehouse_daily(self._current_challenge)

		if is_safehouse_daily and managers.custom_safehouse:has_completed_daily() or not is_safehouse_daily and self._challenges[self._current_challenge] and self._challenges[self._current_challenge].completed then
			self:update_renew_timer()

			if alive(self._expire_panel) then
				self._expire_panel:set_visible(false)
			end
		elseif alive(self._expire_timer) then
			local expire_string = ""

			if is_safehouse_daily then
				local challenge = managers.custom_safehouse:get_daily_challenge()
				local timestamp = challenge.timestamp
				local expire_timestamp = managers.custom_safehouse:daily_challenge_interval() + timestamp
				local current_timestamp = managers.custom_safehouse:get_timestamp()
				local expire_time = expire_timestamp - current_timestamp
				expire_string = self:_create_timestamp_string_extended(expire_time)
			else
				local challenge = self._challenges[self._current_challenge]

				if challenge and challenge.timestamp then
					local timestamp = challenge.timestamp
					local expire_timestamp = challenge.interval + timestamp
					local current_timestamp = managers.challenge:get_timestamp()
					local expire_time = expire_timestamp - current_timestamp
					expire_string = self:_create_timestamp_string_extended(expire_time)
				end
			end

			if utf8.len(expire_string) > 0 then
				self._expire_timer:set_text(expire_string)
				self._expire_panel:set_visible(true)
			end
		end
	end

	self:_update_animation(t, dt)
end

function CustomSafehouseGuiPageDaily:_update_animation(t, dt)
	if self._anim_state and self[self._anim_state] then
		self[self._anim_state](self, t, dt)
	end
end

function CustomSafehouseGuiPageDaily:_update_hide_daily(t, dt)
	if alive(self:daily_panel()) and alive(self:challenge_panel()) then
		self._complete_t = (self._complete_t or 0) + dt

		if self._complete_t > 1 then
			local h = self:challenge_panel():h()
			h = h - h * 4 * dt

			self:challenge_panel():set_h(h)

			if self._anim_box then
				self._anim_box:close()
			end

			if h <= 1 then
				self._complete_t = nil

				self:set_animation_state("_update_show_complete")
			else
				self._anim_box = BoxGuiObject:new(self:challenge_panel(), {
					sides = {
						1,
						1,
						0,
						2
					}
				})
			end
		end
	end
end

function CustomSafehouseGuiPageDaily:_update_show_complete(t, dt)
	local title = self._challenge_scroll:canvas():child("DailyCompleteTitle")
	local info = self._challenge_scroll:canvas():child("DailyCompleteInfo")
	local panel = self._challenge_scroll:canvas():child("DailyRenewPanel")

	if not title or not info or not panel then
		return
	end

	if not self._complete_panel then
		self:_setup_safehouse_daily_complete()
		self._challenge_scroll:canvas():child("DailyCompleteTitle"):set_visible(false)
		self._challenge_scroll:canvas():child("DailyCompleteInfo"):set_visible(false)
		self._challenge_scroll:canvas():child("DailyRenewPanel"):set_visible(false)
		self._renew_timer:set_visible(false)
	end

	self._complete_t = (self._complete_t or 0) + dt
	local base_time = 0.8
	local step_time = 0.5

	if base_time < self._complete_t and not title:visible() then
		title:set_visible(true)
		managers.menu_component:post_event("box_tick")
	end

	if self._complete_t > base_time + step_time and not panel:visible() then
		panel:set_visible(true)
		self._renew_timer:set_visible(true)
		managers.menu_component:post_event("box_tick")
	end

	if self._complete_t > base_time + step_time * 2 and not info:visible() then
		info:set_visible(true)
		managers.menu_component:post_event("box_tick")
		self:finish_animation()
	end
end

function CustomSafehouseGuiPageDaily:set_animation_state(state)
	self._anim_state = state
end

function CustomSafehouseGuiPageDaily:finish_animation()
	self:challenge_panel():set_h(self:daily_panel():h() - PANEL_PADDING * 2)
	self:set_animation_state(nil)
end

function CustomSafehouseGuiPageDaily:mouse_moved(button, x, y)
	if not self._active then
		return
	end

	for i, panel in pairs(self._scrollable_panels) do
		if panel and alive(panel:panel()) then
			local values = {
				panel:mouse_moved(button, x, y)
			}

			if values[1] ~= nil then
				return unpack(values)
			end
		end
	end

	local button_highlighted = false

	for _, button in ipairs(self._buttons) do
		if not button_highlighted and button:inside(x, y) then
			button:set_selected(true)

			button_highlighted = true
		else
			button:set_selected(false)
		end
	end

	if not button_highlighted then
		for _, button in ipairs(self._side_panel_buttons) do
			if not button_highlighted and button:inside(x, y) then
				button:set_selected(true)

				button_highlighted = true
			else
				button:set_selected(false)
			end
		end
	end

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

function CustomSafehouseGuiPageDaily:mouse_clicked(o, button, x, y)
	if not self._active then
		return
	end

	for idx, button in pairs(self._buttons or {}) do
		if button:inside(x, y) then
			button:trigger()

			return true
		end
	end

	for _, button in pairs(self._side_panel_buttons or {}) do
		if button:inside(x, y) then
			self:select_challenge(button:get_custom_data())

			return true
		end
	end

	for idx, button in pairs(self._reward_buttons or {}) do
		if button:inside(x, y) then
			button:trigger()

			return true
		end
	end
end

function CustomSafehouseGuiPageDaily:mouse_pressed(button, x, y)
	if not self._active then
		return
	end

	for i, panel in pairs(self._scrollable_panels) do
		if panel and alive(panel:panel()) then
			local values = {
				panel:mouse_pressed(button, x, y)
			}

			if values[1] ~= nil then
				return unpack(values)
			end
		end
	end
end

function CustomSafehouseGuiPageDaily:mouse_released(button, x, y)
	if not self._active then
		return
	end

	for i, panel in pairs(self._scrollable_panels) do
		if panel and alive(panel:panel()) then
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

function CustomSafehouseGuiPageDaily:mouse_wheel_up(x, y)
	if not self._active then
		return
	end

	for i, panel in pairs(self._scrollable_panels) do
		if panel and alive(panel:panel()) then
			local values = {
				panel:scroll(x, y, 1)
			}

			if values[1] ~= nil then
				return unpack(values)
			end
		end
	end
end

function CustomSafehouseGuiPageDaily:mouse_wheel_down(x, y)
	if not self._active then
		return
	end

	for i, panel in pairs(self._scrollable_panels) do
		if panel and alive(panel:panel()) then
			local values = {
				panel:scroll(x, y, -1)
			}

			if values[1] ~= nil then
				return unpack(values)
			end
		end
	end
end

function CustomSafehouseGuiPageDaily:get_legend()
	local legend = {}
	local id = self._current_challenge

	if id then
		local challenge = managers.challenge:get_active_challenge(id)

		if challenge then
			local completed = self:is_safehouse_daily(id) and managers.custom_safehouse:has_completed_daily(id) or challenge.completed
			local rewarded = self:is_safehouse_daily(id) and managers.custom_safehouse:has_rewarded_daily(id) or challenge.rewarded

			if completed and not rewarded then
				table.insert(legend, "claim_reward")
			end
		end
	end

	if self._challenge_scroll:is_scrollable() then
		table.insert(legend, "scroll")
	end

	table.insert(legend, "move")
	table.insert(legend, "back")

	return legend
end

CustomSafehouseGuiRewardItem = CustomSafehouseGuiRewardItem or class(CustomSafehouseGuiItem)

function CustomSafehouseGuiRewardItem:init(daily_page, panel, order, reward_data, id, is_safehouse_daily)
	self._daily_page = daily_page
	self._reward = reward_data or {}
	self._order = order or 0
	self._id = id
	self._is_safehouse_daily = is_safehouse_daily or false
	local texture_path, texture_rect, reward_string = nil
	local is_pattern = false
	local is_material = false
	local is_weapon = false
	local is_weapon_mod = false

	if reward_data[1] == "safehouse_coins" then
		texture_path = "guis/dlcs/chill/textures/pd2/safehouse/continental_coins_drop"
		reward_string = managers.localization:text("menu_es_safehouse_reward_coins", {
			amount = managers.experience:cash_string(reward_data[2], "")
		})
		self._is_safehouse_daily = true
	elseif reward_data.choose_weapon_reward then
		texture_path = "guis/textures/pd2/icon_modbox_df"
		reward_string = managers.localization:text("menu_challenge_choose_weapon_mod")
	elseif #reward_data > 0 then
		texture_path = reward_data.texture_path or "guis/textures/pd2/icon_reward"
		texture_rect = reward_data.texture_rect
		reward_string = reward_data.name_s or managers.localization:text(reward_data.name_id or "menu_challenge_choose_reward")
	elseif reward_data.item_entry then
		local id = reward_data.item_entry
		local category = reward_data.type_items
		local td = tweak_data:get_raw_value("blackmarket", category, id) or tweak_data:get_raw_value(category, id)

		if td then
			local guis_catalog = "guis/"
			local bundle_folder = td.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			if category == "textures" then
				texture_path = td.texture
				reward_string = managers.localization:text(td.name_id)
				is_pattern = true
			elseif category == "cash" then
				texture_path = "guis/textures/pd2/blackmarket/cash_drop"
				reward_string = managers.experience:cash_string(managers.money:get_loot_drop_cash_value(td.value_id))
			elseif category == "xp" then
				texture_path = "guis/textures/pd2/blackmarket/xp_drop"
				reward_string = managers.localization:text("menu_challenge_xp_drop")
			else
				if category == "weapon_mods" or category == "weapon_bonus" then
					category = "mods"
					is_weapon_mod = true
				end

				if category == "weapon" then
					category = "weapons"
					is_weapon = true
				end

				is_material = category == "materials"
				texture_path = guis_catalog .. "textures/pd2/blackmarket/icons/" .. category .. "/" .. id
				reward_string = managers.localization:text(td.name_id)
			end
		end
	elseif reward_data.tango_weapon_part then
		texture_path = "guis/dlcs/tng/textures/pd2/blackmarket/icons/side_job_rewards/gage_mod_rewards"
		reward_string = managers.localization:text("menu_tango_reward_weapon_part")
	end

	self._panel = panel:panel({
		w = REWARD_SIZE,
		h = REWARD_SIZE
	})

	self._panel:set_x((self._order - 1) * REWARD_SIZE)

	if reward_data.rewarded then
		self._panel:set_alpha(0.5)
	end

	self._text = self._panel:text({
		name = "text",
		wrap = true,
		align = "center",
		vertical = "bottom",
		valign = "scale",
		blend_mode = "add",
		halign = "scale",
		word_wrap = true,
		layer = 1,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.title,
		text = reward_string,
		w = self._panel:w(),
		h = small_font_size * 2
	})

	BlackMarketGui.make_fine_text(self, self._text)
	self._text:set_bottom(self._panel:bottom() - PANEL_PADDING * 0.5)
	self._text:set_x(self._panel:w() * 0.5 - self._text:w() * 0.5)

	self._image = self._panel:bitmap({
		layer = 1,
		texture = texture_path,
		texture_rect = texture_rect
	})
	local ratio_w = self._image:w() / self._image:h()
	local ratio_h = self._image:h() / self._image:w()

	if self._image:h() < self._image:w() then
		ratio_w = 1
		ratio_h = self._image:h() / self._image:w()
	else
		ratio_w = self._image:w() / self._image:h()
		ratio_h = 1
	end

	self._image:set_w(panel:h() * 0.8 * ratio_w)
	self._image:set_h(panel:h() * 0.8 * ratio_h)
	self._image:set_bottom(self._text:top() + PANEL_PADDING)
	self._image:set_x(self._panel:w() * 0.5 - self._image:w() * 0.5)

	if is_pattern then
		self._image:set_render_template(Idstring("VertexColorTexturedPatterns"))
		self._image:set_blend_mode("normal")
	end

	if is_material then
		self._image:set_w(panel:h() * 0.7 * ratio_w)
		self._image:set_h(panel:h() * 0.7 * ratio_h)
	end

	if is_weapon or is_weapon_mod then
		self._image:set_center_y(self._panel:h() * 0.5)
	end

	local completed = self._is_safehouse_daily and managers.custom_safehouse:has_completed_daily() or managers.challenge:get_active_challenge(id) and managers.challenge:get_active_challenge(id).completed
	completed = completed or managers.tango:get_challenge(self._id) and managers.tango:get_challenge(self._id).completed

	for _, side_job_dlc in ipairs(managers.generic_side_jobs:side_jobs()) do
		if side_job_dlc.manager:can_progress() then
			completed = completed or side_job_dlc.manager:get_challenge(self._id) and side_job_dlc.manager:get_challenge(self._id).completed
		end
	end

	if completed and not reward_data.rewarded then
		local function glow_anim(o)
			while true do
				over(5, function (p)
					o:set_alpha(math.abs(math.sin(p * 360)) * 0.6)
				end)
			end
		end

		local glow_size = math.min(self._panel:w(), self._panel:h()) * 1.5
		self._glow = self._panel:bitmap({
			texture = "guis/textures/pd2/hot_cold_glow",
			blend_mode = "add",
			alpha = 0,
			rotation = 360,
			layer = -1,
			w = glow_size,
			h = glow_size,
			color = tweak_data.screen_colors.challenge_completed_color
		})

		self._glow:set_center(self._panel:w() * 0.5, self._panel:h() * 0.5)
		self._glow:animate(glow_anim)

		if not managers.menu:is_pc_controller() then
			self._border = BoxGuiObject:new(self._panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})

			self._border:hide()
		end
	end

	self:set_active(true)
end

function CustomSafehouseGuiRewardItem:panel()
	return self._panel
end

function CustomSafehouseGuiRewardItem:refresh()
	if managers.menu:is_pc_controller() then
		self._text:set_visible(self._selected or self._reward.completed)
	else
		self._text:set_visible(true)
	end
end

function CustomSafehouseGuiRewardItem:inside(x, y)
	return self._panel:inside(x, y)
end

function CustomSafehouseGuiRewardItem:trigger()
	if self:is_active() then
		if self._is_safehouse_daily and managers.custom_safehouse:has_completed_daily() and not managers.custom_safehouse:has_rewarded_daily() then
			managers.menu_component:post_event("menu_skill_investment")
			self._glow:stop()
			self._glow:set_alpha(0)
			self:set_active(false)
			managers.custom_safehouse:reward_daily()
			SimpleGUIEffectSpewer.claim_daily_reward(self._image:center_x(), self._image:center_y(), self._panel)
			self._daily_page:set_animation_state("_update_hide_daily")
		elseif managers.challenge:get_active_challenge(self._id) and managers.challenge:get_active_challenge(self._id).completed then
			if managers.challenge:is_choose_weapon_unrewarded(self._id, nil, self._order) then
				managers.menu:open_node("choose_weapon_reward_safehouse", {
					{
						reward_data = {
							self._id,
							[3] = self._order
						}
					}
				})
			else
				local reward = managers.challenge:on_give_reward(self._id, nil, self._order)

				if reward then
					managers.menu_component:post_event("menu_skill_investment")
					self._glow:stop()
					self._glow:set_alpha(0)
					self:set_active(false)

					if reward.choose_weapon_reward then
						debug_pause("Trying to reward random weapon mod the wrong way!")
						managers.menu:open_node("choose_weapon_reward_safehouse")
					else
						managers.menu:show_challenge_reward(reward)
					end

					self._daily_page:select_challenge(self._id)
				end
			end
		elseif managers.tango:get_challenge(self._id) and managers.tango:get_challenge(self._id).completed and not managers.tango:get_challenge(self._id).rewarded and not managers.tango:has_already_claimed_reward(self._id, self._order) then
			managers.menu_component:post_event("menu_skill_investment")
			self._glow:stop()
			self._glow:set_alpha(0)
			self:set_active(false)
			managers.tango:claim_reward(self._id, self._order)
			self._daily_page:select_challenge(self._id)
		else
			for _, side_job_dlc in ipairs(managers.generic_side_jobs:side_jobs()) do
				local challenge = side_job_dlc.manager:get_challenge(self._id)

				if challenge then
					if challenge.completed and not challenge.rewarded and not side_job_dlc.manager:has_already_claimed_reward(self._id, self._order) then
						managers.menu_component:post_event("menu_skill_investment")
						self._glow:stop()
						self._glow:set_alpha(0)
						self:set_active(false)
						side_job_dlc.manager:claim_reward(self._id, self._order)
						self._daily_page:select_challenge(self._id)
					end

					break
				end
			end
		end

		self._daily_page:_update_buttons()
	end
end

function CustomSafehouseGuiRewardItem:set_selected(selected, ...)
	CustomSafehouseGuiRewardItem.super.set_selected(self, selected, ...)

	if self._border then
		self._border:set_visible(selected)

		if not selected then
			self._panel:set_alpha(0.5)
		else
			self._panel:set_alpha(1)
		end
	end
end
