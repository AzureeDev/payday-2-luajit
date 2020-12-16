CrimeSpreeMissionsMenuComponent = CrimeSpreeMissionsMenuComponent or class(MenuGuiComponentGeneric)
local padding = 10
local size = 280
CrimeSpreeMissionsMenuComponent.button_size = {
	w = size * 0.6666666666666666,
	h = size * 0.5 * 0.6666666666666666,
	title_h = tweak_data.menu.pd2_medium_font_size + 4
}
CrimeSpreeMissionsMenuComponent.menu_nodes = {
	start_menu = "crime_spree_lobby",
	mission_end_menu = "main"
}

function CrimeSpreeMissionsMenuComponent:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({})

	if not Global.game_settings.is_playing then
		WalletGuiObject.set_wallet(self._ws:panel())
		WalletGuiObject.set_layer(30)
		WalletGuiObject.move_wallet(10, -10)
	end

	self._buttons = {}

	self:_setup()

	if managers.crime_spree:show_crash_dialog() then
		MenuCallbackHandler:show_crime_spree_crash_dialog()
		managers.crime_spree:clear_crash_dialog()
	end
end

function CrimeSpreeMissionsMenuComponent:close()
	WalletGuiObject.close_wallet(self._ws:panel())
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

function CrimeSpreeMissionsMenuComponent:_setup()
	local parent = self._ws:panel()

	if alive(self._panel) then
		parent:remove(self._panel)
	end

	self._panel = parent:panel({
		layer = self._init_layer
	})
	local w = (self.button_size.w + padding) * tweak_data.crime_spree.gui.missions_displayed - padding
	local h = self.button_size.h + self.button_size.title_h
	local bottom = parent:bottom() - tweak_data.menu.pd2_large_font_size * 1.5
	self._title_panel = self._panel:panel({})

	self._title_panel:set_w(w)
	self._title_panel:set_h(tweak_data.menu.pd2_medium_font_size)
	self._title_panel:set_right(parent:right())
	self._title_panel:set_bottom(bottom - h - 4)
	self._title_panel:text({
		layer = 51,
		vertical = "bottom",
		word_wrap = true,
		wrap = true,
		align = "left",
		halign = "left",
		valign = "bottom",
		text = managers.localization:to_upper_text("menu_cs_select_next_heist"),
		color = Color.white,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})

	self._buttons_panel = self._panel:panel({})

	self._buttons_panel:set_w(w)
	self._buttons_panel:set_h(h)
	self._buttons_panel:set_right(parent:right())
	self._buttons_panel:set_bottom(bottom)

	local default_index = nil

	for idx = 1, tweak_data.crime_spree.gui.missions_displayed do
		local data = managers.crime_spree:server_missions()[idx] or {}
		local btn = CrimeSpreeMissionButton:new(idx, self._buttons_panel, data)

		btn:set_callback(callback(self, self, "_select_mission", idx))
		table.insert(self._buttons, btn)

		if managers.crime_spree:current_mission() == data.id then
			default_index = idx
		end
	end

	if not managers.menu:is_pc_controller() then
		default_index = default_index or 1
	end

	if managers.crime_spree:has_consumable_value("mission_gui_selected_slot") then
		self:_set_button_index_selected(managers.crime_spree:consumable_value("mission_gui_selected_slot"), true)
	end

	if default_index then
		self:_set_button_index_selected(default_index, true)
	end

	self._host_failed_text = self._buttons_panel:text({
		halign = "right",
		vertical = "bottom",
		layer = 51,
		wrap = true,
		align = "right",
		word_wrap = true,
		y = 0,
		x = 0,
		valign = "bottom",
		text = managers.localization:text("menu_cs_host_failed_text"),
		color = Color.white,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})
	local _, _, _, h = self._host_failed_text:text_rect()

	self._host_failed_text:set_h(h)
	self._host_failed_text:set_bottom(self._buttons_panel:h())

	self._host_failed = self._buttons_panel:text({
		halign = "right",
		vertical = "bottom",
		layer = 51,
		wrap = true,
		align = "right",
		word_wrap = true,
		y = 0,
		x = 0,
		valign = "bottom",
		text = managers.localization:to_upper_text("menu_cs_host_failed"),
		color = Color.white,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})
	local _, _, _, h = self._host_failed:text_rect()

	self._host_failed:set_h(h)
	self._host_failed:set_bottom(self._host_failed_text:top())
	self:refresh()
end

function CrimeSpreeMissionsMenuComponent:update_mission(btn_idx)
	for idx, btn in ipairs(self._buttons) do
		if btn._type == "CrimeSpreeMissionButton" and (btn_idx == nil or btn:index() == btn_idx) then
			btn:update_mission(managers.crime_spree:server_missions()[btn:index()])
		end
	end
end

function CrimeSpreeMissionsMenuComponent:randomize_crimespree(btn_idx)
	managers.crime_spree:select_mission(false)
	self:_select_mission(0)

	for idx, btn in ipairs(self._buttons) do
		if btn._type == "CrimeSpreeMissionButton" and (btn_idx == nil or btn:index() == btn_idx) then
			btn:randomize(managers.crime_spree:server_missions()[btn:index()])
		end
	end
end

function CrimeSpreeMissionsMenuComponent:is_randomizing()
	for idx, btn in ipairs(self._buttons) do
		if btn._type == "CrimeSpreeMissionButton" and btn:is_randomizing() then
			return true
		end
	end

	return false
end

function CrimeSpreeMissionsMenuComponent:selection_index()
	return self._selected_button or 0
end

function CrimeSpreeMissionsMenuComponent:move_selection(dir)
	if not self:_is_host() then
		return false
	end

	self:_set_button_index_selected(self._selected_button, false)

	self._selected_button = self:selection_index() + dir

	if self._selected_button > #self._buttons then
		self._selected_button = 1
	elseif self._selected_button < 1 then
		self._selected_button = #self._buttons
	end

	self:_set_button_index_selected(self._selected_button, true)
end

function CrimeSpreeMissionsMenuComponent:_select_mission(idx)
	if self._selected_button ~= idx then
		self:_set_button_index_selected(self._selected_button, false)
	end

	self._selected_button = idx

	self:_set_button_index_selected(idx, true)
end

function CrimeSpreeMissionsMenuComponent:_set_button_index_selected(idx, selected)
	if not idx then
		return false
	end

	self._selected_button = idx
	local btn = self._buttons[idx]

	if btn then
		btn:set_selected(selected)
		btn:set_active(selected)
		managers.crime_spree:select_mission(btn:mission_id())

		if managers.crime_spree:_is_host() then
			managers.menu_component:post_event("menu_enter")
		end

		managers.crime_spree:send_crime_spree_mission_data(btn:index(), btn:mission_id(), true)
	end
end

function CrimeSpreeMissionsMenuComponent:get_selected_index()
	for idx, btn in ipairs(self._buttons) do
		if btn._type == "CrimeSpreeMissionButton" and btn:is_active() then
			return btn:index()
		end
	end
end

function CrimeSpreeMissionsMenuComponent:_is_host()
	return Network:is_server() or Global.game_settings.single_player
end

function CrimeSpreeMissionsMenuComponent:refresh()
	local hide = managers.crime_spree:server_has_failed()

	for idx, btn in ipairs(self._buttons) do
		if hide then
			btn:panel():hide()
		else
			btn:panel():show()
		end
	end

	self._host_failed_text:set_visible(hide)
	self._host_failed:set_visible(hide)
	self._title_panel:set_visible(not hide)
end

function CrimeSpreeMissionsMenuComponent.get_height()
	return CrimeSpreeMissionsMenuComponent.button_size.h + CrimeSpreeMissionsMenuComponent.button_size.title_h + tweak_data.menu.pd2_medium_font_size
end

function CrimeSpreeMissionsMenuComponent:update(t, dt)
	local randomizing = self:is_randomizing()

	for idx, btn in ipairs(self._buttons) do
		btn:update(t, dt)
	end

	if not managers.menu:is_pc_controller() and randomizing and not self:is_randomizing() then
		self:_select_mission(1)
	end
end

function CrimeSpreeMissionsMenuComponent:mouse_moved(o, x, y)
	if not self:_is_host() or not managers.menu:is_pc_controller() then
		return
	end

	local used, pointer = nil

	for idx, btn in ipairs(self._buttons) do
		btn:set_selected(btn:inside(x, y))

		if btn:is_selected() then
			pointer = "link"
			used = true
		end
	end

	return used, pointer
end

function CrimeSpreeMissionsMenuComponent:mouse_pressed(o, button, x, y)
	return self:confirm_pressed()
end

function CrimeSpreeMissionsMenuComponent:confirm_pressed()
	if not self:_is_host() then
		return nil
	end

	for idx, btn in ipairs(self._buttons) do
		if btn:is_selected() and btn:callback() then
			btn:callback()()

			return true
		end
	end
end

function CrimeSpreeMissionsMenuComponent:dummy_trigger()
	return self:confirm_pressed()
end

function CrimeSpreeMissionsMenuComponent:move_left()
	self:move_selection(-1)
end

function CrimeSpreeMissionsMenuComponent:move_right()
	self:move_selection(1)
end

function CrimeSpreeMissionsMenuComponent:input_focus()
end

CrimeSpreeMissionButton = CrimeSpreeMissionButton or class(MenuGuiItem)
CrimeSpreeMissionButton._type = "CrimeSpreeMissionButton"
CrimeSpreeMissionButton.RandomState = {
	Cleanup = 5,
	Rollback = 3,
	Done = 4,
	Slow = 2,
	Spin = 1
}

function CrimeSpreeMissionButton:init(idx, parent, mission_data)
	self._idx = idx
	self._mission_data = mission_data
	self._panel = parent:panel({
		layer = 60,
		name = "mission_" .. tostring(self._mission_data.id),
		w = CrimeSpreeMissionsMenuComponent.button_size.w,
		h = CrimeSpreeMissionsMenuComponent.button_size.h + CrimeSpreeMissionsMenuComponent.button_size.title_h,
		x = (CrimeSpreeMissionsMenuComponent.button_size.w + padding) * (idx - 1)
	})
	self._image_panel = self._panel:panel({
		h = self._panel:h() - CrimeSpreeMissionsMenuComponent.button_size.title_h
	})
	self._mission_bg = self._image_panel:rect({
		layer = -2,
		color = Color.black
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data(mission_data.icon)

	if not texture or not DB:has(Idstring("texture"), texture) then
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas"
		rect = {
			0,
			0,
			280,
			140
		}
	end

	self._mission_image = self._image_panel:bitmap({
		blend_mode = "add",
		name = "mission_image",
		layer = 9,
		stream = true,
		texture = texture,
		texture_rect = rect,
		w = self._panel:w(),
		h = self._panel:h()
	})
	local image_scanlines = self._image_panel:bitmap({
		texture = "guis/dlcs/chill/textures/pd2/rooms/safehouse_room_preview_effect",
		name = "scalines",
		layer = 11,
		wrap_mode = "wrap",
		texture_rect = {
			0,
			0,
			512,
			512
		},
		w = self._panel:w(),
		h = self._panel:h()
	})
	local h = tweak_data.menu.pd2_medium_font_size
	self._info_panel = self._panel:panel({
		layer = 50,
		h = h
	})

	self._info_panel:set_top(padding * 0.5)

	local h = CrimeSpreeMissionsMenuComponent.button_size.title_h
	local level_name_bg = self._panel:rect({
		y = self._panel:h() - h,
		h = h,
		color = Color(0.05, 0.05, 0.05)
	})
	self._highlight_name = self._panel:rect({
		layer = 1,
		y = self._panel:h() - h,
		h = h,
		color = tweak_data.screen_colors.button_stage_3
	})
	self._level_text = self._panel:text({
		halign = "center",
		vertical = "center",
		layer = 51,
		align = "center",
		text = "",
		y = 0,
		x = 0,
		valign = "center",
		color = Color.white,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})

	BlackMarketGui.make_fine_text(self, self._level_text)
	self._level_text:set_center_x(self._panel:w() * 0.5)

	self._info_text = self._info_panel:text({
		halign = "center",
		vertical = "center",
		layer = 1,
		align = "center",
		text = "",
		y = 0,
		x = 0,
		valign = "center",
		color = Color.white,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})

	self:update_info_text(self._mission_data)

	self._bg = self._panel:rect({
		alpha = 0.4,
		layer = -1,
		color = Color.black
	})
	self._highlight = self._panel:rect({
		blend_mode = "add",
		layer = -1,
		color = tweak_data.screen_colors.button_stage_3
	})
	self._blur = self._panel:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		halign = "scale",
		alpha = 1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = self._panel:w(),
		h = self._panel:h()
	})
	self._border_panel = self._panel:panel({
		layer = 20
	})

	BoxGuiObject:new(self._border_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._active_border = BoxGuiObject:new(self._border_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})

	self:update_button_text()
	self:refresh()
end

function CrimeSpreeMissionButton:refresh()
	self._bg:set_visible(not self:is_selected())
	self._highlight:set_visible(self:is_active() or self:is_selected())
	self._highlight_name:set_visible(self:is_active() or self:is_selected())
	self._active_border:set_visible(self:is_active())
end

function CrimeSpreeMissionButton:inside(x, y)
	return self._panel:inside(x, y)
end

function CrimeSpreeMissionButton:panel()
	return self._panel
end

function CrimeSpreeMissionButton:index()
	return self._idx
end

function CrimeSpreeMissionButton:callback()
	return self._callback
end

function CrimeSpreeMissionButton:set_callback(clbk)
	self._callback = clbk
end

function CrimeSpreeMissionButton:is_randomizing()
	return self._randomize ~= nil
end

function CrimeSpreeMissionButton:update(t, dt)
	if self._randomize then
		if self._randomize.state == CrimeSpreeMissionButton.RandomState.Spin then
			self._randomize.t = self._randomize.t - dt
			local speed = math.clamp(self._randomize.t * tweak_data.crime_spree.gui.spin_speed, unpack(tweak_data.crime_spree.gui.spin_speed_limit))

			self:_move_random_texts(speed, dt)

			if self._randomize.t <= 0 then
				self._randomize.t = nil
				self._randomize.state = CrimeSpreeMissionButton.RandomState.Slow
			end
		elseif self._randomize.state == CrimeSpreeMissionButton.RandomState.Slow then
			local slow_time = {
				0.1,
				0.3
			}
			local speed = tweak_data.crime_spree.gui.spin_speed_limit[1]

			if self._randomize.t then
				speed = speed * self._randomize.t / slow_time[2]
			end

			self:_move_random_texts(speed, dt)

			if not self._randomize.t and math.abs(self._level_text:y() - self:button_text_h()) < 2 then
				self._randomize.t = math.rand(unpack(slow_time))
			end

			if self._randomize.t then
				self._randomize.t = self._randomize.t - dt

				if self._randomize.t <= 0 then
					self._randomize.t = nil
					self._randomize.state = CrimeSpreeMissionButton.RandomState.Rollback
				end
			end
		elseif self._randomize.state == CrimeSpreeMissionButton.RandomState.Rollback then
			local speed = (self._level_text:y() - self:button_text_h()) * dt

			self:_move_random_texts(-200, dt)

			local dis = self._level_text:y() - self:button_text_h()

			if dis < 0.1 then
				self._randomize.state = CrimeSpreeMissionButton.RandomState.Done
			end
		elseif self._randomize.state == CrimeSpreeMissionButton.RandomState.Done then
			local fade_out_t = 0.5

			self:update_button_text()
			self:update_info_text()

			if not self._randomize.t then
				self._randomize.t = fade_out_t
			else
				self._randomize.t = self._randomize.t - dt

				for i, text in ipairs(self._random_texts) do
					if i > 1 then
						text:set_alpha(self._randomize.t / fade_out_t)
					end
				end

				self._info_panel:set_alpha(1 - self._randomize.t / fade_out_t)
				self._mission_image:set_alpha(1 - self._randomize.t / fade_out_t)
				self._mission_bg:set_alpha(1 - self._randomize.t / fade_out_t)

				if self._randomize.t <= 0 then
					self._randomize.state = CrimeSpreeMissionButton.RandomState.Cleanup
				end
			end
		elseif self._randomize.state == CrimeSpreeMissionButton.RandomState.Cleanup then
			self:_cleanup_random_texts()

			self._randomize = nil
		end
	end
end

function CrimeSpreeMissionButton:randomize(mission_data)
	self._mission_data = mission_data
	self._randomize = {
		state = CrimeSpreeMissionButton.RandomState.Spin,
		t = math.rand(unpack(tweak_data.crime_spree.gui.randomize_time))
	}

	self._info_panel:set_alpha(0)
	self._mission_image:set_alpha(0)
	self._mission_bg:set_alpha(0)
	self:_create_random_texts()
end

function CrimeSpreeMissionButton:update_mission(mission_data)
	self._mission_data = mission_data

	self:update_button_text(nil, mission_data)
	self:update_info_text(mission_data)
end

function CrimeSpreeMissionButton:update_button_text(text, mission_data, dont_reset_pos)
	text = text or self._level_text
	mission_data = mission_data or self._mission_data
	local level_tweak = tweak_data.levels[mission_data.level.level_id] or {}

	text:set_text(managers.localization:to_upper_text(level_tweak.name_id))
	text:set_font_size(tweak_data.menu.pd2_small_font_size)

	local x, y, w, h = text:text_rect()

	if self._panel:w() <= w then
		text:set_font_size(tweak_data.menu.pd2_small_font_size * 0.8)
	end

	BlackMarketGui.make_fine_text(self, text)
	text:set_center_x(self._panel:w() * 0.5)

	if not dont_reset_pos then
		text:set_y(self:button_text_h())
	end
end

function CrimeSpreeMissionButton:button_text_h()
	return self._panel:h() - tweak_data.menu.pd2_small_font_size - 4
end

function CrimeSpreeMissionButton:update_info_text(mission_data)
	mission_data = mission_data or self._mission_data
	local text = ""
	local spacer = " "
	local category = self:_get_mission_category(mission_data)

	if category then
		local timer_text = managers.localization:get_default_macro("BTN_SPREE_" .. utf8.to_upper(category))
		text = text .. timer_text
	end

	local level_tweak = tweak_data.levels[mission_data.level.level_id]

	if level_tweak and level_tweak.ghost_bonus then
		local stealth_text = managers.localization:get_default_macro("BTN_SPREE_STEALTH")
		text = text .. spacer .. stealth_text
	end

	text = text .. spacer
	local len = utf8.len(text)
	local inc_text = managers.localization:text("menu_cs_lobby_mission_inc", {
		inc = mission_data.add
	})
	text = text .. inc_text

	self._info_text:set_text(text)
	self._info_text:set_range_color(len, len + utf8.len(inc_text), tweak_data.screen_colors.crime_spree_risk)

	local texture, rect = tweak_data.hud_icons:get_icon_data(mission_data.icon)

	if not texture or not DB:has(Idstring("texture"), texture) then
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas"
		rect = {
			0,
			0,
			280,
			140
		}
	end

	self._mission_image:set_image(texture)

	if rect then
		self._mission_image:set_texture_rect(unpack(rect))
	end
end

function CrimeSpreeMissionButton:_create_random_texts()
	self:_cleanup_random_texts()

	self._random_texts = {}

	table.insert(self._random_texts, self._level_text)

	for i = 1, 8 do
		local text = self._panel:text({
			halign = "center",
			vertical = "center",
			layer = 1,
			align = "center",
			text = "",
			y = 0,
			x = 0,
			valign = "center",
			color = Color.white,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size
		})

		table.insert(self._random_texts, text)
		self:update_button_text(text, managers.crime_spree:get_random_mission(), true)

		if i > 1 then
			text:set_bottom(self._random_texts[i]:top())
		else
			text:set_bottom(self._panel:top())
		end

		text:set_center_x(self._panel:w() * 0.5)
	end
end

function CrimeSpreeMissionButton:_cleanup_random_texts()
	if self._random_texts then
		for i, text in ipairs(self._random_texts) do
			if i > 1 then
				self._panel:remove(text)
			end
		end

		self._random_texts = nil
	end
end

function CrimeSpreeMissionButton:_move_random_texts(speed, dt)
	for i, text in ipairs(self._random_texts) do
		text:set_y(text:y() + speed * dt)

		if self._panel:h() < text:y() then
			local idx = (i - 1) % #self._random_texts

			if idx == 0 then
				idx = #self._random_texts or idx
			end

			text:set_bottom(self._random_texts[idx]:top())

			if i == 1 then
				self:update_button_text(nil, nil, true)
			else
				self:update_button_text(text, managers.crime_spree:get_random_mission(), true)
			end
		end
	end
end

function CrimeSpreeMissionButton:_get_mission_category(mission)
	if mission.add <= 5 then
		return "short"
	elseif mission.add <= 7 then
		return "medium"
	else
		return "long"
	end
end

function CrimeSpreeMissionButton:mission_id()
	return (self._mission_data or {}).id
end
