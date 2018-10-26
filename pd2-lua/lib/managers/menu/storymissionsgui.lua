require("lib/managers/menu/ExtendedUiElemets")

local padding = 10
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
StoryMissionsGui = StoryMissionsGui or class(ExtendedPanel)

function StoryMissionsGui:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._node = node

	StoryMissionsGui.super.init(self, self._ws:panel())

	self._fullscreen_panel = ExtendedPanel:new(self._fullscreen_ws:panel())

	self._fullscreen_panel:rect({
		alpha = 0.4,
		layer = -1,
		color = Color.black
	})

	local y = large_font_size + padding * 2
	self._main_panel = ExtendedPanel:new(self, {
		input = true,
		x = padding,
		y = y,
		w = self:w() - padding * 2,
		h = (self:h() - y) - massive_font_size
	})

	if not managers.menu:is_pc_controller() then
		self._legends = TextLegendsBar:new(self, {
			font = medium_font,
			font_size = medium_font_size
		})

		self._legends:add_items({
			"menu_legend_back",
			"menu_legend_scroll",
			{
				id = "select",
				enabled = false,
				text = managers.localization:to_upper_text("menu_legend_claim_reward", {BTN_Y = managers.localization:key_to_btn_text("a", true)})
			},
			{
				enabled = false,
				text_id = "menu_legend_sm_start_mission",
				id = "start_mission",
				binding = "menu_update",
				func = callback(self, self, "_start_mission_general")
			}
		})
		self._legends:set_rightbottom(self:w(), self:h())
	end

	self._side_scroll = ScrollableList:new(self._main_panel, {
		padding = 5,
		input = true,
		w = self._main_panel:w() * 0.25
	})

	BoxGuiObject:new(ExtendedPanel:new(self._side_scroll, {layer = 100}), {sides = {
		1,
		1,
		2,
		2
	}})

	self._info_scroll = ScrollableList:new(self._main_panel, {
		padding = 5,
		input = true,
		x = self._side_scroll:right() + padding,
		w = (self._main_panel:w() - self._side_scroll:w()) - padding
	}, {padding_y = 10})

	BoxGuiObject:new(ExtendedPanel:new(self._info_scroll, {layer = 100}), {sides = {
		1,
		1,
		2,
		2
	}})
	self:_add_title()
	self:_add_back_button()
	self:_update_side()
	self:_update_info()
end

function StoryMissionsGui:close()
	if managers.briefing:event_playing() then
		managers.briefing:stop_event()
	end

	if alive(self._fullscreen_panel) then
		self._fullscreen_panel:remove_self()
	end

	self:remove_self()
end

function StoryMissionsGui:_add_title()
	self._title = self:text({
		name = "title",
		vertical = "top",
		align = "left",
		blend_mode = "add",
		layer = 10,
		x = padding,
		y = padding,
		font_size = large_font_size,
		font = large_font,
		h = large_font_size,
		color = tweak_data.screen_colors.title,
		text = managers.localization:to_upper_text("menu_story_missions")
	})
end

function StoryMissionsGui:_add_back_button()
	if not managers.menu:is_pc_controller() then
		return
	end

	local back_button = TextButton:new(self, {
		blend = "add",
		text_id = "menu_back",
		font = large_font,
		font_size = large_font_size
	}, function ()
		managers.menu:force_back()
	end)

	back_button:set_right(self:w() - 10)
	back_button:set_bottom(self:h() - 10)

	self._back_button = back_button
	local bg_back = self._fullscreen_panel:text({
		name = "back_button",
		vertical = "bottom",
		h = 90,
		align = "right",
		alpha = 0.5,
		blend_mode = "add",
		layer = 1,
		text = utf8.to_upper(managers.localization:text("menu_back")),
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	local x, y = managers.gui_data:safe_to_full_16_9(self._back_button:world_right(), self._back_button:world_center_y())

	bg_back:set_world_right(x)
	bg_back:set_world_center_y(y)
	bg_back:move(13, -9)
end

function StoryMissionsGui:_change_legend(id, state)
	if self._legends then
		self._legends:set_item_enabled(id, state)
	end
end

function StoryMissionsGui:_update(mission)
	if mission and type(mission) == "string" then
		mission = managers.story:get_mission(mission)
	end

	self:_update_side(mission)
	self:_update_info(mission)
end

function StoryMissionsGui:_update_side(current)
	self._side_scroll:clear()

	local canvas = self._side_scroll:canvas()
	local placer = canvas:placer()
	local font_size = tweak_data.menu.pd2_small_font_size
	local tab_size = 20
	current = current or managers.story:current_mission()
	local all_done = current.completed and current.rewarded and current.last_mission

	for i, mission in table.reverse_ipairs(managers.story:missions_in_order()) do
		if mission.completed or i == current.order then
			local color = tweak_data.menu.default_disabled_text_color
			local icon = done_icon

			if i == current.order and not all_done then
				color = tweak_data.screen_colors.button_stage_3
				icon = selected_icon
			end

			local item = placer:add_row(StoryMissionsGuiSidebarItem:new(canvas, {
				text = managers.localization:to_upper_text(mission.name_id),
				icon = icon,
				icon_rotation = icon == selected_icon and -90 or 0
			}))

			item:set_color(color)
		end
	end
end

function StoryMissionsGui:_update_info(mission)
	self._info_scroll:clear()
	self:_change_legend("select", false)
	self:_change_legend("start_mission", false)

	self._select_btn = nil
	self._level_btns = {}
	self._selected_level_btn = nil

	if self._voice then
		managers.briefing:stop_event()
		self._voice.panel:remove_self()

		self._voice = nil
	end

	mission = mission or managers.story:current_mission()

	if not mission then
		return
	end

	local canvas = self._info_scroll:canvas()
	local placer = canvas:placer()
	local text_col = tweak_data.screen_colors.text

	if mission.completed and mission.rewarded and mission.last_mission then
		placer:add_row(canvas:fine_text({
			text_id = "menu_sm_all_done",
			font = medium_font,
			font_size = medium_font_size
		}))

		return
	end

	placer:add_row(canvas:fine_text({
		text = managers.localization:to_upper_text(mission.name_id),
		font = medium_font,
		font_size = medium_font_size,
		color = text_col
	}))
	placer:add_row(canvas:fine_text({
		wrap = true,
		word_wrap = true,
		text = managers.localization:text(mission.desc_id),
		font = small_font,
		font_size = small_font_size,
		color = text_col
	}))

	if mission.voice_line then
		self._voice = {}
		local h = small_font_size * 2 + 20
		local pad = 8
		self._voice.panel = ExtendedPanel:new(self, {
			w = 256,
			input = true,
			h = h
		})

		BoxGuiObject:new(self._voice.panel, {sides = {
			1,
			1,
			1,
			1
		}})

		self._voice.text = self._voice.panel:text({
			x = pad,
			y = pad,
			font = small_font,
			font_size = small_font_size,
			color = text_col,
			text = managers.localization:to_upper_text("menu_cn_message_playing")
		})
		self._voice.button = TextButton:new(self._voice.panel, {
			binding = "menu_toggle_voice_message",
			x = pad,
			font = small_font,
			font_size = small_font_size,
			text = managers.localization:to_upper_text("menu_stop_sound", {BTN_X = managers.localization:btn_macro("menu_toggle_voice_message")})
		}, callback(self, self, "toggle_voice_message", mission.voice_line))

		self._voice.button:set_bottom(self._voice.panel:h() - pad)
		self._voice.panel:set_world_right(self._info_scroll:world_right())
		self:toggle_voice_message(mission.voice_line)
	end

	placer:add_row(canvas:fine_text({
		text = managers.localization:to_upper_text("menu_challenge_objective_title"),
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.challenge_title
	}))
	placer:add_row(canvas:fine_text({
		wrap = true,
		word_wrap = true,
		text = managers.localization:text(mission.objective_id),
		font = small_font,
		font_size = small_font_size,
		color = text_col
	}), nil, 0)

	local locked = false

	if not mission.hide_progress then
		placer:add_row(canvas:fine_text({
			text = managers.localization:to_upper_text("menu_unlock_progress"),
			font = small_font,
			font_size = small_font_size,
			color = tweak_data.screen_colors.challenge_title
		}))

		local num_objective_groups = #mission.objectives
		local obj_padd_x = num_objective_groups > 1 and 15 or nil

		for i, objective_row in ipairs(mission.objectives) do
			for _, objective in ipairs(objective_row) do
				local text = placer:add_row(canvas:fine_text({
					wrap = true,
					word_wrap = true,
					text = managers.localization:text(objective.name_id),
					font = small_font,
					font_size = small_font_size,
					color = text_col
				}), obj_padd_x, 0)

				if not mission.completed and not objective.completed and objective.levels and (not objective.basic or not Network:is_server()) and not Network:is_client() then
					if objective.dlc and not managers.dlc:is_dlc_unlocked(objective.dlc) and not Global.game_settings.single_player then
						placer:add_right(canvas:fine_text({
							text = managers.localization:to_upper_text("menu_ultimate_edition_short"),
							font = small_font,
							font_size = small_font_size,
							color = tweak_data.screen_colors.dlc_color
						}), 5)
						placer:add_right(canvas:fine_text({
							text_id = "menu_sm_dlc_locked",
							font = small_font,
							font_size = small_font_size,
							color = tweak_data.screen_colors.important_1
						}), 5)

						locked = true
					else
						local btn = TextButton:new(canvas, {
							text_id = "menu_sm_start_level",
							font = small_font,
							font_size = small_font_size
						}, function ()
							managers.story:start_mission(mission, objective.progress_id)
						end)

						placer:add_right(btn, 10)
						table.insert(self._level_btns, btn)
						self:_change_legend("start_mission", true)

						if not self._selected_level_btn then
							self._selected_level_btn = btn

							if not managers.menu:is_pc_controller() then
								btn:_hover_changed(true)
							end
						end
					end
				end

				if objective.max_progress > 1 then
					local progress = placer:add_row(TextProgressBar:new(canvas, {
						h = small_font_size + 2,
						max = objective.max_progress,
						back_color = Color(0, 0, 0, 0),
						progress_color = tweak_data.screen_colors.challenge_completed_color:with_alpha(0.4)
					}, {
						font = small_font,
						font_size = small_font_size,
						color = text_col
					}, objective.progress), nil, 0)
					local box = BoxGuiObject:new(progress, {sides = {
						1,
						1,
						1,
						1
					}})
				else
					local texture_rect = {
						objective.completed and 24 or 0,
						0,
						24,
						24
					}
					local checkbox = canvas:bitmap({
						texture = "guis/textures/menu_tickbox",
						texture_rect = texture_rect
					})

					checkbox:set_right(canvas:w())
					checkbox:set_top(text:top())
				end
			end

			if i < num_objective_groups then
				placer:add_row(canvas:fine_text({
					text_id = "menu_sm_objectives_or",
					font = small_font,
					font_size = small_font_size,
					color = tweak_data.screen_colors.challenge_title
				}), nil, 0)
			end
		end
	end

	if locked then
		placer:add_row(canvas:fine_text({
			wrap = true,
			text_id = "menu_sm_dlc_locked_help_text",
			word_wrap = true,
			font = small_font,
			font_size = small_font_size,
			color = text_col
		}), nil, nil)
	end

	if mission.reward_id then
		local title = placer:add_row(canvas:fine_text({
			text = managers.localization:to_upper_text("menu_reward"),
			font = small_font,
			font_size = small_font_size,
			color = tweak_data.screen_colors.challenge_title
		}))
		local r_panel = GrowPanel:new(canvas, {input = true})
		local r_placer = r_panel:placer()

		for i, reward in ipairs(mission.rewards) do
			local item = StoryMissionGuiRewardItem:new(r_panel, reward)

			if r_placer:current_right() + item:w() < canvas:w() * 0.5 then
				r_placer:add_right(item)
			else
				r_placer:add_row(item)
			end
		end

		BoxGuiObject:new(r_panel, {sides = {
			1,
			1,
			1,
			1
		}})
		placer:add_row(r_panel, nil, 0)
		r_panel:set_right(canvas:w())

		local reward_text = canvas:fine_text({
			wrap = true,
			word_wrap = true,
			text_id = mission.reward_id,
			font = small_font,
			font_size = small_font_size,
			keep_w = r_panel:left() - title:left()
		})

		reward_text:set_lefttop(title:left(), r_panel:top())
		placer:set_at_from(reward_text)
	end

	if mission.completed then
		if not mission.rewarded then
			local item = placer:add_row(TextButton:new(canvas, {
				text_id = mission.last_mission and "menu_sm_claim_rewards" or "menu_sm_claim_rewards_goto_next",
				font = medium_font,
				font_size = medium_font_size
			}, function ()
				managers.story:claim_rewards(mission)
				managers.menu_component:post_event("menu_skill_investment")

				local dialog_data = {
					title = managers.localization:text("menu_sm_claim_rewards"),
					text = managers.localization:text(mission.reward_id)
				}
				local ok_button = {
					text = managers.localization:text("dialog_ok"),
					callback_func = function ()
						self:_update()
					end
				}
				dialog_data.button_list = {ok_button}

				managers.system_menu:show(dialog_data)
			end))

			item:set_right(canvas:w())

			self._select_btn = item

			self:_change_legend("select", true)
		elseif not mission.last_mission then
			local item = placer:add_row(TextButton:new(canvas, {
				text_id = "menu_sm_claim_goto_next",
				font = medium_font,
				font_size = medium_font_size
			}, function ()
				managers.story:_find_next_mission()
				self:_update()
			end))

			item:set_right(canvas:w())

			self._select_btn = item

			self:_change_legend("select", true)
		end
	end
end

function StoryMissionsGui:toggle_voice_message(message)
	if not self._voice then
		return
	end

	if managers.briefing:event_playing() then
		managers.briefing:stop_event()
		self._voice.text:set_text(managers.localization:to_upper_text("menu_cn_message_stopped"))
		self._voice.button:set_text(managers.localization:to_upper_text("menu_play_sound", {BTN_X = managers.localization:btn_macro("menu_toggle_voice_message")}))
	elseif message then
		managers.briefing:post_event(message, {
			show_subtitle = false,
			listener = {
				end_of_event = true,
				duration = true,
				clbk = callback(self, self, "sound_event_callback")
			}
		})
		self._voice.text:set_text(managers.localization:to_upper_text("menu_cn_message_playing"))
		self._voice.button:set_text(managers.localization:to_upper_text("menu_stop_sound", {BTN_X = managers.localization:btn_macro("menu_toggle_voice_message")}))
	end
end

function StoryMissionsGui:sound_event_callback(event_type, duration)
	if not self._voice or not alive(self._voice.text) then
		return
	end

	if event_type == "end_of_event" then
		self._voice.text:set_text(managers.localization:to_upper_text("menu_cn_message_stopped"))
		self._voice.button:set_text(managers.localization:to_upper_text("menu_play_sound", {BTN_X = managers.localization:btn_macro("menu_toggle_voice_message")}))
	end
end

function StoryMissionsGui:update()
	if not managers.menu:is_pc_controller() and self:allow_input() and (not managers.system_menu or not managers.system_menu:is_active() or not not managers.system_menu:is_closing()) then
		local axis_x, axis_y = managers.menu_component:get_right_controller_axis()

		if axis_y ~= 0 then
			self._side_scroll:perform_scroll(axis_y)
			self._info_scroll:perform_scroll(axis_y)
		end

		local menu_input = managers.menu:active_menu().input
		local up = menu_input:menu_up_input_bool()
		local down = menu_input:menu_down_input_bool()

		if up or down then
			self:_change_selected_level(up and 1 or -1)
		else
			self:_enable_selected_level_btns()
		end
	end
end

function StoryMissionsGui:_change_selected_level(axis)
	if self._change_level_btn_disabled then
		return
	end

	if self._level_btns and self._selected_level_btn then
		local index = table.get_vector_index(self._level_btns, self._selected_level_btn) - 1

		if not index then
			return
		end

		index = axis < 0 and index - 1 or index + 1
		index = index % #self._level_btns + 1

		self._selected_level_btn:_hover_changed(false)

		self._selected_level_btn = self._level_btns[index]

		self._selected_level_btn:_hover_changed(true)

		self._change_level_btn_disabled = true
	end
end

function StoryMissionsGui:_enable_selected_level_btns()
	self._change_level_btn_disabled = nil
end

function StoryMissionsGui:confirm_pressed()
	if alive(self._select_btn) then
		self._select_btn:_trigger()
	end
end

function StoryMissionsGui:_start_mission_general()
	if self._selected_level_btn then
		self._selected_level_btn:_trigger()

		return
	end

	managers.story:start_current()
end

function StoryMissionsGui:input_focus()
	return alive(self._panel) and self._panel:visible() and 1
end
StoryMissionsGuiSidebarItem = StoryMissionsGuiSidebarItem or class(ExtendedPanel)

function StoryMissionsGuiSidebarItem:init(panel, parameters)
	StoryMissionsGuiSidebarItem.super.init(self, panel)

	local font = tweak_data.menu.pd2_small_font
	local font_size = tweak_data.menu.pd2_small_font_size
	local tab_size = 20
	self._text = self:fine_text({
		text = parameters.text or "",
		font = font,
		font_size = font_size,
		x = tab_size,
		w = self:w(),
		h = font_size
	})
	self._icon = self:bitmap({
		y = 2,
		texture = parameters.icon,
		rotation = parameters.icon_rotation
	})

	self._icon:set_visible(parameters.icon)
	self:set_h(self._text:bottom())
end

function StoryMissionsGuiSidebarItem:set_text(text)
	self._text:set_text(text)
end

function StoryMissionsGuiSidebarItem:set_icon(icon)
	if icon then
		self._icon:set_visible(true)
		self._icon:set_image(icon)
	else
		self._icon:set_visible(false)
	end
end

function StoryMissionsGuiSidebarItem:set_color(color)
	self._text:set_color(color)
	self._icon:set_color(color)
end

local function set_defaults(target, source)
	target = target or {}

	for k, v in pairs(source) do
		if target[k] == nil then
			target[k] = v
		end
	end

	return target
end

StoryMissionGuiRewardItem = StoryMissionGuiRewardItem or class(ExtendedPanel)
StoryMissionGuiRewardItem.SIZE = 128

function StoryMissionGuiRewardItem:init(panel, reward_data, config)
	config = set_defaults(config, {
		input = true,
		w = self.SIZE,
		h = self.SIZE
	})

	StoryMissionGuiRewardItem.super.init(self, panel, config)

	local texture_path, texture_rect, reward_string = nil
	local is_pattern = false
	local is_material = false
	local is_weapon = false

	if reward_data[1] == "safehouse_coins" then
		texture_path = "guis/dlcs/chill/textures/pd2/safehouse/continental_coins_drop"
		reward_string = managers.localization:text("menu_es_safehouse_reward_coins", {amount = managers.experience:cash_string(reward_data[2], "")})
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

	local scale = is_material and 0.7 or 0.8
	self._image = self:fit_bitmap({
		texture = texture_path,
		texture_rect = texture_rect
	}, scale * self:w(), scale * self:h())

	self._image:set_center_y(self:h() * 0.5)
	self._image:set_center_x(self:w() * 0.5)

	if is_pattern then
		self._image:set_render_template(Idstring("VertexColorTexturedPatterns"))
		self._image:set_blend_mode("normal")
	end

	self._text = self:fine_text({
		vertical = "bottom",
		blend_mode = "add",
		align = "left",
		visible = false,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.title,
		text = reward_string,
		w = self:w(),
		h = small_font_size * 2
	})

	self.scale_font_to_fit(self._text, self:w())
	self._text:set_bottom(self:h())
	self._text:set_x(self:w() * 0.5 - self._text:w() * 0.5)
end

function StoryMissionGuiRewardItem:mouse_moved(button, x, y)
	self._text:set_visible(self:inside(x, y))
end

