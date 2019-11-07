local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local IS_WIN_32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not IS_WIN_32
local TOP_ADJUSTMENT = NOT_WIN_32 and 55 or 55
local BOT_ADJUSTMENT = NOT_WIN_32 and 60 or 60
local PAGE_TAB_H = medium_font_size + 10
local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.68 or 0.71
local BOX_GAP = 13.5
MenuGuiComponentGeneric = MenuGuiComponentGeneric or class(MenuGuiComponent)

function MenuGuiComponentGeneric:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({})
	self._event_listener = EventListenerHolder:new()

	self._event_listener:add(self, {
		"refresh"
	}, callback(self, self, "_on_refresh_event"))

	self._node = node
	self.make_fine_text = BlackMarketGui.make_fine_text
	self._rec_round_object = NewSkillTreeGui._rec_round_object
	self._tabs = {}
	self._tabs_data = {}

	self:populate_tabs_data(self._tabs_data)

	local component_data = self._node:parameters().menu_component_data
	local is_start_page = not component_data and true or false

	self:_setup(is_start_page, component_data)
	self:set_layer(10)
end

function MenuGuiComponentGeneric:close()
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

function MenuGuiComponentGeneric:event_listener()
	return self._event_listener
end

function MenuGuiComponentGeneric:call_refresh()
	self._event_listener:call("refresh")
end

function MenuGuiComponentGeneric:_on_refresh_event()
	self:refresh()
end

function MenuGuiComponentGeneric:set_layer(layer)
	if alive(self._panel) then
		self._panel:set_layer(self._init_layer + layer)
	end
end

function MenuGuiComponentGeneric:populate_tabs_data(tabs_data)
end

function MenuGuiComponentGeneric:_start_page_data()
	local data = {
		topic_id = "dialog_ok"
	}

	return data
end

function MenuGuiComponentGeneric:tabs_panel()
	return self._tabs_panel
end

function MenuGuiComponentGeneric:page_panel()
	return self._page_panel
end

function MenuGuiComponentGeneric:info_panel()
	return self._info_panel
end

function MenuGuiComponentGeneric:_setup(is_start_page, component_data)
	self._data = component_data or self:_start_page_data()

	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end

	self._panel = self._ws:panel():panel({
		layer = self._init_layer
	})

	self:_setup_panel_size()

	if self._data.close_contract_gui then
		managers.menu_component:close_contract_gui()
	end

	self:_add_page_title()

	if not self._data.no_back_button then
		self:_add_back_button()
	end

	self:_add_panels()
	self:_add_tabs()
	self:_add_legend()

	if not self._data.no_blur_background then
		self:_blur_background()
	end

	self:_rec_round_object(self._panel)
	self:set_active_page(1)
end

function MenuGuiComponentGeneric:_setup_panel_size()
end

function MenuGuiComponentGeneric:_add_page_title()
	if alive(self._panel:child("title_text")) then
		self._panel:remove(self._panel:child("title_text"))
	end

	self._title_text = self._panel:text({
		name = "title_text",
		text = self._data.topic_id and managers.localization:to_upper_text(self._data.topic_id, self._data.topic_params) or "",
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.text
	})

	self:make_fine_text(self._title_text)

	if self._data.topic_range_color then
		self._title_text:set_range_color(self._data.topic_range_color.from, self._data.topic_range_color.to, self._data.topic_range_color.color)
	end

	if MenuBackdropGUI then
		if alive(self._fullscreen_panel:child("title_text_bg")) then
			self._fullscreen_panel:remove(self._fullscreen_panel:child("title_text_bg"))
		end

		local bg_text = self._fullscreen_panel:text({
			name = "title_text_bg",
			vertical = "top",
			h = 90,
			alpha = 0.4,
			align = "left",
			text = self._title_text:text(),
			font_size = massive_font_size,
			font = massive_font,
			color = tweak_data.screen_colors.button_stage_3
		})
		local x, y = managers.gui_data:safe_to_full_16_9(self._title_text:world_x(), self._title_text:world_center_y())

		bg_text:set_world_left(x)
		bg_text:set_world_center_y(y)
		bg_text:move(-13, 9)
		MenuBackdropGUI.animate_bg_text(self, bg_text)
	end
end

function MenuGuiComponentGeneric:_add_back_button()
	self._panel:text({
		vertical = "bottom",
		name = "back_button",
		align = "right",
		text = utf8.to_upper(managers.localization:text("menu_back")),
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	self:make_fine_text(self._panel:child("back_button"))
	self._panel:child("back_button"):set_right(self._panel:w())
	self._panel:child("back_button"):set_bottom(self._panel:h())
	self._panel:child("back_button"):set_visible(managers.menu:is_pc_controller())

	if MenuBackdropGUI and managers.menu:is_pc_controller() then
		local bg_back = self._fullscreen_panel:text({
			name = "back_button",
			vertical = "bottom",
			h = 90,
			alpha = 0.4,
			align = "right",
			layer = 0,
			text = utf8.to_upper(managers.localization:text("menu_back")),
			font_size = massive_font_size,
			font = massive_font,
			color = tweak_data.screen_colors.button_stage_3
		})
		local x, y = managers.gui_data:safe_to_full_16_9(self._panel:child("back_button"):world_right(), self._panel:child("back_button"):world_center_y())

		bg_back:set_world_right(x)
		bg_back:set_world_center_y(y)
		bg_back:move(13, -9)
		MenuBackdropGUI.animate_bg_text(self, bg_back)
	end
end

function MenuGuiComponentGeneric:_blur_background()
	local black_rect = self._fullscreen_panel:rect({
		layer = 1,
		color = Color(0.4, 0, 0, 0)
	})
	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		layer = -1,
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h()
	})

	local function func(o)
		over(0.6, function (p)
			o:set_alpha(p)
		end)
	end

	blur:animate(func)
end

function MenuGuiComponentGeneric:_add_panels()
	local h = self._panel:h() - TOP_ADJUSTMENT - PAGE_TAB_H

	if not self._data.no_back_button then
		h = h - BOT_ADJUSTMENT
	end

	self._page_panel = self._panel:panel({
		name = "PageRootPanel",
		layer = 1,
		w = self._panel:w() * WIDTH_MULTIPLIER,
		h = h
	})

	self._page_panel:set_top(TOP_ADJUSTMENT + PAGE_TAB_H)
	self._page_panel:set_left(0)

	self._tabs_panel = self._panel:panel({
		name = "TabPanel",
		w = self._page_panel:w(),
		h = PAGE_TAB_H
	})

	self._tabs_panel:set_top(TOP_ADJUSTMENT + 2)
	self._tabs_panel:set_left(0)

	self._tabs_scroll_panel = self._tabs_panel:panel({
		w = self._tabs_panel:w(),
		h = self._tabs_panel:h()
	})
	self._info_panel = self._panel:panel({
		name = "InfoRootPanel",
		layer = 1,
		w = self._panel:w() * (1 - WIDTH_MULTIPLIER) - BOX_GAP,
		h = self._page_panel:h()
	})

	self._info_panel:set_world_top(self._page_panel:world_y())
	self._info_panel:set_right(self._panel:w())

	self._outline_panel = self._page_panel:panel({
		layer = 10
	})
	self._outline_box = BoxGuiObject:new(self._outline_panel, self._data.outline_data or {
		sides = {
			1,
			1,
			2,
			2
		}
	})

	if self._data.outline_data and self._data.outline_data.layer then
		self._outline_box:set_layer(self._data.outline_data.layer)
	end
end

function MenuGuiComponentGeneric:_add_tabs()
	local tab_x = 0
	local bumper_offsets = 7

	if (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and #self._tabs_data > 1 then
		local button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_l") or managers.localization:get_default_macro("BTN_BOTTOM_L")
		local prev_page = self._tabs_panel:text({
			y = 0,
			name = "prev_page",
			layer = 2,
			font_size = medium_font_size,
			font = medium_font,
			color = tweak_data.screen_colors.text,
			text = button
		})
		local _, _, w, h = prev_page:text_rect()

		prev_page:set_size(w, h)
		prev_page:set_top(bumper_offsets)
		prev_page:set_left(tab_x)
		prev_page:set_visible((self._active_page or 1) > 1)
		self._tabs_scroll_panel:move(w + 15, 0)
		self._tabs_scroll_panel:grow(-(w + 15), 0)
	end

	for index, tab_data in ipairs(self._tabs_data) do
		local page_class = tab_data.page_class and _G[tab_data.page_class] or MenuGuiTabPage
		local tab_page = page_class:new(tab_data.name_id, self._page_panel, self._fullscreen_panel, self)
		local tab_item = MenuGuiTabItem:new(index, tab_data.name_id, tab_page, self, tab_x, self._tabs_scroll_panel)
		tab_x = tab_item:next_page_position()

		table.insert(self._tabs, {
			tab = tab_item,
			page = tab_page,
			width_multiplier = tab_data.width_multiplier ~= nil and tab_data.width_multiplier or WIDTH_MULTIPLIER
		})
	end

	if (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and #self._tabs_data > 1 then
		local button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_r") or managers.localization:get_default_macro("BTN_BOTTOM_R")
		local next_page = self._tabs_panel:text({
			y = 0,
			name = "next_page",
			layer = 2,
			font_size = medium_font_size,
			font = medium_font,
			color = tweak_data.screen_colors.text,
			text = button
		})
		local _, _, w, h = next_page:text_rect()

		next_page:set_size(w, h)
		next_page:set_top(bumper_offsets)
		next_page:set_right(self._tabs_panel:w())
		self._tabs_scroll_panel:grow(-(w + 15), 0)
		next_page:set_visible((self._active_page or 1) < #self._tabs_data)
	end
end

function MenuGuiComponentGeneric:_add_legend()
	if not managers.menu:is_pc_controller() then
		self._legends_panel = self._panel:panel({
			w = self._panel:w() * 0.75,
			h = tweak_data.menu.pd2_medium_font_size
		})

		self._legends_panel:set_rightbottom(self._panel:w(), self._panel:h())
		self._legends_panel:text({
			text = "",
			name = "text",
			vertical = "bottom",
			align = "right",
			blend_mode = "add",
			halign = "right",
			valign = "bottom",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})
	end
end

function MenuGuiComponentGeneric:set_active_page(new_index, play_sound)
	if new_index == self._active_page or new_index <= 0 or new_index > #self._tabs then
		return false
	end

	local active_page = self._tabs[self._active_page] and self._tabs[self._active_page].page
	local active_tab = self._tabs[self._active_page] and self._tabs[self._active_page].tab
	local new_page = self._tabs[new_index] and self._tabs[new_index].page
	local new_tab = self._tabs[new_index] and self._tabs[new_index].tab
	local tab_width = self._tabs[new_index] and self._tabs[new_index].width_multiplier

	if active_page then
		active_page:set_active(false)
	end

	if active_tab then
		active_tab:set_active(false)
	end

	if new_page then
		new_page:set_active(true)
	end

	if new_tab then
		new_tab:set_active(true)

		self._selected_page = new_tab:page()
	end

	local prev_page = self._tabs_panel:child("prev_page")

	if prev_page then
		prev_page:set_visible(new_index > 1)
	end

	local next_page = self._tabs_panel:child("next_page")

	if prev_page then
		next_page:set_visible(new_index < #self._tabs)
	end

	if play_sound then
		managers.menu_component:post_event("highlight")
	end

	self._page_panel:set_w(self._panel:w() * tab_width)
	self._info_panel:set_w(self._panel:w() * (1 - tab_width) - BOX_GAP)
	self._outline_panel:set_w(self._page_panel:w())

	if self._outline_box then
		self._outline_box:close()
	end

	self._outline_box = BoxGuiObject:new(self._outline_panel, self._data.outline_data or {
		sides = {
			1,
			1,
			2,
			2
		}
	})

	if self._data.outline_data and self._data.outline_data.layer then
		self._outline_box:set_layer(self._data.outline_data.layer)
	end

	self._active_page = new_index

	self:update_legend()

	return true
end

function MenuGuiComponentGeneric:update_legend()
	if not managers.menu:is_pc_controller() then
		local legend_items = {}

		if self._selected_page then
			legend_items = self._selected_page:get_legend()
		end

		local legends = {}

		if table.contains(legend_items, "move") then
			legends[#legends + 1] = {
				string_id = "menu_legend_preview_move"
			}
		end

		if table.contains(legend_items, "scroll") then
			legends[#legends + 1] = {
				string_id = "menu_legend_scroll"
			}
		end

		if table.contains(legend_items, "select") then
			legends[#legends + 1] = {
				string_id = "menu_legend_select"
			}
		end

		if table.contains(legend_items, "claim_reward") then
			legends[#legends + 1] = {
				string_id = "menu_legend_claim_reward"
			}
		end

		if table.contains(legend_items, "back") then
			legends[#legends + 1] = {
				string_id = "menu_legend_back"
			}
		end

		if table.contains(legend_items, "zoom") then
			legends[#legends + 1] = {
				string_id = "menu_legend_preview_zoom"
			}
		end

		local legend_text = ""

		for i, legend in ipairs(legends) do
			local spacing = i > 1 and "  |  " or ""
			local macros = {}
			legend_text = legend_text .. spacing .. managers.localization:to_upper_text(legend.string_id, macros)
		end

		if self._legends_panel then
			self._legends_panel:child("text"):set_text(legend_text)
		end
	end
end

function MenuGuiComponentGeneric:update(t, dt)
	if self._selected_page then
		return self._selected_page:update(t, dt)
	end
end

function MenuGuiComponentGeneric:mouse_clicked(o, button, x, y)
	if not self._panel then
		return
	end

	if self._panel:child("back_button") and self._panel:child("back_button"):inside(x, y) then
		managers.menu:back(true)

		return true
	end

	if self._selected_tab then
		self:set_active_page(self._selected_tab:index(), true)

		return
	end

	for index, tab_data in ipairs(self._tabs or {}) do
		local used = tab_data.page:mouse_clicked(o, button, x, y)

		if used then
			return used
		end
	end
end

function MenuGuiComponentGeneric:mouse_pressed(button, x, y)
	if self._selected_page then
		return self._selected_page:mouse_pressed(button, x, y)
	end
end

function MenuGuiComponentGeneric:mouse_released(button, x, y)
	if self._selected_page then
		return self._selected_page:mouse_released(button, x, y)
	end
end

function MenuGuiComponentGeneric:mouse_wheel_up(x, y)
	if self._selected_page then
		return self._selected_page:mouse_wheel_up(x, y)
	end
end

function MenuGuiComponentGeneric:mouse_wheel_down(x, y)
	if self._selected_page then
		return self._selected_page:mouse_wheel_down(x, y)
	end
end

function MenuGuiComponentGeneric:mouse_moved(button, x, y)
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	local used = false
	local pointer = nil
	self.mouse_moved_update_order = self.mouse_moved_update_order or {
		self.update_back_button_hover,
		self.update_tabs_hover,
		self.update_pages_hover
	}

	for i, func in ipairs(self.mouse_moved_update_order) do
		used, pointer = func(self, button, x, y)

		if used then
			return used, pointer
		end
	end

	return used, pointer
end

function MenuGuiComponentGeneric:input_focus()
	return 1
end

function MenuGuiComponentGeneric:move_up()
	if self._selected_page then
		return self._selected_page:move_up()
	end
end

function MenuGuiComponentGeneric:move_down()
	if self._selected_page then
		return self._selected_page:move_down()
	end
end

function MenuGuiComponentGeneric:move_left()
	if self._selected_page then
		return self._selected_page:move_left()
	end
end

function MenuGuiComponentGeneric:move_right()
	if self._selected_page then
		return self._selected_page:move_right()
	end
end

function MenuGuiComponentGeneric:next_page()
	if self._active_page ~= nil then
		return self:set_active_page(self._active_page + 1)
	end
end

function MenuGuiComponentGeneric:previous_page()
	if self._active_page ~= nil then
		return self:set_active_page(self._active_page - 1)
	end
end

function MenuGuiComponentGeneric:confirm_pressed()
	if self._selected_page then
		return self._selected_page:confirm_pressed()
	end
end

function MenuGuiComponentGeneric:special_btn_pressed(button)
	if self._selected_page then
		self._selected_page:special_btn_pressed(button)
	end
end

function MenuGuiComponentGeneric:update_back_button_hover(button, x, y)
	if not self._panel or not self._panel:child("back_button") then
		return
	end

	if self._panel:child("back_button"):inside(x, y) then
		if not self._back_button_highlighted then
			self._back_button_highlighted = true

			self._panel:child("back_button"):set_color(tweak_data.screen_colors.button_stage_2)
			managers.menu_component:post_event("highlight")
		end

		return true, "link"
	elseif self._back_button_highlighted then
		self._back_button_highlighted = false

		self._panel:child("back_button"):set_color(tweak_data.screen_colors.button_stage_3)
	end
end

function MenuGuiComponentGeneric:update_tabs_hover(button, x, y)
	if not self._tabs or #self._tabs < 2 then
		return
	end

	if not self._selected_tab or not self._selected_tab:inside(x, y) then
		if self._selected_tab then
			self._selected_tab:set_selected(false)

			self._selected_tab = nil
		end

		for _, tab_data in ipairs(self._tabs) do
			if tab_data.tab:inside(x, y) then
				tab_data.tab:set_selected(true)

				self._selected_tab = tab_data.tab

				return true, "link"
			end
		end
	elseif not self._selected_tab:is_active() then
		return true, "link"
	end
end

function MenuGuiComponentGeneric:update_pages_hover(button, x, y)
	if not self._tabs then
		return
	end

	for index, tab_data in ipairs(self._tabs) do
		local used, pointer = tab_data.page:mouse_moved(button, x, y)

		if used then
			return used, pointer
		end
	end
end
