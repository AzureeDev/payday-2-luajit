core:module("SystemMenuManager")
core:import("CoreTable")
require("lib/managers/dialogs/Dialog")
require("lib/managers/menu/ExtendedUiElemets")
require("lib/managers/menu/BoxGuiObject")
require("lib/utils/gui/FineText")

DocumentDialog = DocumentDialog or class(Dialog)
DocumentDialog.PATH = "gamedata/"
DocumentDialog.FILE_EXTENSION = "credits"
DocumentDialog.FADE_IN_DURATION = 0.2
DocumentDialog.FADE_OUT_DURATION = 0.2
DocumentDialog.MOVE_AXIS_LIMIT = 0.4
DocumentDialog.MOVE_AXIS_DELAY = 0.4

function DocumentDialog:init(manager, data, is_title_outside)
	Dialog.init(self, manager, data)

	self._data.no_buttons = #self._data.button_list == 0

	if not self._data.focus_button then
		self._data.focus_button = 1
	end

	self._text_data = self:_create_text_data(data)
	self._text_data.is_title_outside = is_title_outside
	self._ws = self._data.ws or manager:_get_ws()
	self._panel_script = DocumentBoxGui:new(self, self._ws, self._data, self._text_data)

	self._panel_script:add_background()
	self._panel_script:set_centered()
	self._panel_script:set_layer(_G.tweak_data.gui.DIALOG_LAYER)
	self._panel_script:set_fade(0)

	self._controller = self._data.controller or manager:_get_controller()
	self._confirm_func = callback(self, self, "button_pressed_callback")
	self._cancel_func = callback(self, self, "dialog_cancel_callback")
end

function DocumentDialog:_create_text_data(data)
	local tweak_data = _G.tweak_data
	local text_data = {
		title = data.title and utf8.to_upper(data.title) or "",
		text = {}
	}
	local lang_key = SystemInfo:language():key()
	local languages = {
		[Idstring("english"):key()] = "english",
		[Idstring("french"):key()] = "french",
		[Idstring("russian"):key()] = "russian",
		[Idstring("dutch"):key()] = "dutch",
		[Idstring("german"):key()] = "german",
		[Idstring("italian"):key()] = "italian",
		[Idstring("spanish"):key()] = "spanish",
		[Idstring("japanese"):key()] = "japanese",
		[Idstring("schinese"):key()] = "schinese",
		[Idstring("korean"):key()] = "korean"
	}
	local file_name = languages[lang_key] and data.file_name .. "_" .. languages[lang_key] or data.file_name

	if not PackageManager:has(self.FILE_EXTENSION:id(), (self.PATH .. file_name):id()) then
		file_name = data.file_name
	end

	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), (self.PATH .. file_name):id())
	local font, font_size, color, link, bullet = nil

	for _, data in ipairs(list) do
		if data._meta == "text" then
			font = tweak_data.menu.pd2_small_font
			font_size = tweak_data.menu.pd2_small_font_size
			color = Color(1, 0.9, 0.9, 0.9)
			link, bullet = nil

			if data.type == "topic" then
				font = tweak_data.menu.pd2_medium_font
				font_size = tweak_data.menu.pd2_medium_font_size
				color = tweak_data.screen_colors.text
			elseif data.type == "hyperlink" then
				color = tweak_data.screen_colors.button_stage_2
				link = data.link
			elseif data.type == "bullet" then
				bullet = true
			end

			table.insert(text_data.text, {
				wrap = true,
				word_wrap = true,
				text = data.text,
				font = font,
				font_size = font_size,
				color = color,
				link = link,
				bullet = bullet
			})
		elseif data._meta == "br" then
			table.insert(text_data.text, {
				padding = data.size and tonumber(data.size) or 26
			})
		end
	end

	return text_data
end

function DocumentDialog:mouse_moved(o, x, y)
	if not alive(self._panel_script) then
		managers.mouse_pointer:set_pointer_image("arrow")

		return
	end

	local used, pointer = self._panel_script:mouse_moved(o, x, y)

	managers.mouse_pointer:set_pointer_image(pointer or "arrow")

	self._mouse_x = x
	self._mouse_y = y
end

function DocumentDialog:mouse_pressed(o, button, x, y)
	if not alive(self._panel_script) then
		return false, "arrow"
	end

	if button == Idstring("0") then
		self._is_holding_mouse_button = true

		self._panel_script:mouse_pressed(button, x, y)
	elseif button == Idstring("mouse wheel up") then
		self._panel_script:mouse_wheel_up(x, y)
	elseif button == Idstring("mouse wheel down") then
		self._panel_script:mouse_wheel_down(x, y)
	end
end

function DocumentDialog:mouse_released(o, button, x, y)
	if button == Idstring("0") then
		self._is_holding_mouse_button = false

		self._panel_script:mouse_released(button, x, y)

		local used, pointer = self._panel_script:mouse_moved(self, x, y)

		managers.mouse_pointer:set_pointer_image(pointer or "arrow")
	end
end

function DocumentDialog:mouse_clicked(o, button, x, y)
	if button == Idstring("0") then
		self._panel_script:mouse_clicked(o, button, x, y)
	end
end

function DocumentDialog:update(t, dt)
	if self._fade_in_time then
		local alpha = math.clamp((t - self._fade_in_time) / self.FADE_IN_DURATION, 0, 1)

		self._panel_script:set_fade(alpha)

		if alpha == 1 and not self._data.delay_input then
			self:set_input_enabled(true)

			self._fade_in_time = nil
		end
	end

	if self._fade_out_time then
		local alpha = math.clamp(1 - (t - self._fade_out_time) / self.FADE_OUT_DURATION, 0, 1)

		self._panel_script:set_fade(alpha)

		if alpha == 0 then
			self._fade_out_time = nil

			self:close()
		end
	end

	if self._data.delay_input then
		self._data.delay_input = self._data.delay_input - dt

		if self._data.delay_input < 0 then
			self:set_input_enabled(true)

			self._data.delay_input = nil
		end
	end

	if self._input_enabled then
		self:update_input(t, dt)
	end

	if self._is_holding_mouse_button then
		if self._mouse_x == self._old_x and self._mouse_y == self._old_y then
			self:mouse_moved(self, self._mouse_x, self._mouse_y)
		end

		self._old_x = self._mouse_x
		self._old_y = self._mouse_y
	end
end

function DocumentDialog:update_input(t, dt)
	if self._data.no_buttons then
		return
	end

	local dir, move_time = nil
	local move = self._controller:get_input_axis("menu_move")

	if self._controller:get_input_bool("menu_down") or move.y < -self.MOVE_AXIS_LIMIT then
		dir = 1
	elseif self._controller:get_input_bool("menu_up") or self.MOVE_AXIS_LIMIT < move.y then
		dir = -1
	end

	if dir then
		if self._move_button_dir == dir and self._move_button_time and t < self._move_button_time + self.MOVE_AXIS_DELAY then
			move_time = self._move_button_time or t
		else
			self._panel_script:change_focus_button(dir)

			move_time = t
		end
	end

	self._move_button_dir = dir
	self._move_button_time = move_time

	if managers.controller:get_default_wrapper_type() ~= "pc" and managers.controller:get_default_wrapper_type() ~= "steam" then
		if managers.controller:get_default_wrapper_type() == "vr" then
			-- Nothing
		else
			local scroll = self._controller:get_input_axis("look")

			if self.MOVE_AXIS_LIMIT < scroll.y then
				self._panel_script:scroll_up(-scroll.y * 250 * dt)
			elseif scroll.y < -self.MOVE_AXIS_LIMIT then
				self._panel_script:scroll_down(-math.abs(scroll.y) * 250 * dt)
			end
		end
	end
end

function DocumentDialog:set_input_enabled(enabled)
	if not self._input_enabled ~= not enabled then
		if enabled then
			self._controller:add_trigger("confirm", self._confirm_func)

			if managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" or managers.controller:get_default_wrapper_type() == "vr" then
				self._controller:add_trigger("toggle_menu", self._cancel_func)

				self._mouse_id = managers.mouse_pointer:get_id()
				self._removed_mouse = nil
				local data = {
					mouse_move = callback(self, self, "mouse_moved"),
					mouse_press = callback(self, self, "mouse_pressed"),
					mouse_release = callback(self, self, "mouse_released"),
					mouse_click = callback(self, self, "mouse_clicked"),
					id = self._mouse_id
				}

				managers.mouse_pointer:use_mouse(data)
			else
				self._removed_mouse = nil

				self._controller:add_trigger("cancel", self._cancel_func)
				managers.mouse_pointer:disable()
			end
		else
			self._panel_script:release_scroll_bar()
			self._controller:remove_trigger("confirm", self._confirm_func)

			if managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" or managers.controller:get_default_wrapper_type() == "vr" then
				self._controller:remove_trigger("toggle_menu", self._cancel_func)
			else
				self._controller:remove_trigger("cancel", self._cancel_func)
			end

			self:remove_mouse()
		end

		self._input_enabled = enabled

		managers.controller:set_menu_mode_enabled(enabled)
	end
end

function DocumentDialog:fade_in()
	DocumentDialog.super.fade_in(self)

	self._fade_in_time = TimerManager:main():time()
end

function DocumentDialog:fade_out_close()
	managers.menu:post_event("prompt_exit")
	self:fade_out()
end

function DocumentDialog:fade_out()
	self._fade_out_time = TimerManager:main():time()

	if managers.menu:active_menu() then
		managers.menu:active_menu().renderer:disable_input(0.2)
	end

	self:set_input_enabled(false)
end

function DocumentDialog:is_closing()
	return self._fade_out_time ~= nil
end

function DocumentDialog:show()
	managers.menu:post_event("prompt_enter")
	self._manager:event_dialog_shown(self)

	return true
end

function DocumentDialog:hide()
	self:set_input_enabled(false)

	self._fade_in_time = nil

	self._panel_script:set_fade(0)
	self._manager:event_dialog_hidden(self)
end

function DocumentDialog:_close_dialog_gui()
	self:set_input_enabled(false)
	self._panel_script:close()
	managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback)
end

function DocumentDialog:close()
	self:_close_dialog_gui()
	Dialog.close(self)
end

function DocumentDialog:force_close()
	self:_close_dialog_gui()
	Dialog.force_close(self)
end

function DocumentDialog:resolution_changed_callback()
end

function DocumentDialog:remove_mouse()
	if not self._removed_mouse then
		self._removed_mouse = true

		if managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" or managers.controller:get_default_wrapper_type() == "vr" then
			managers.mouse_pointer:remove_mouse(self._mouse_id)
		else
			managers.mouse_pointer:enable()
		end

		self._mouse_id = nil
	end
end

function DocumentDialog:button_pressed_callback()
	self:remove_mouse()
	self:button_pressed(self._panel_script:get_focus_button())
end

function DocumentDialog:dialog_cancel_callback()
	if #self._data.button_list == 1 then
		self:remove_mouse()
		self:button_pressed(1)
	end

	for i, btn in ipairs(self._data.button_list) do
		if btn.cancel_button then
			self:remove_mouse()
			self:button_pressed(i)

			return
		end
	end
end

DocumentBoxGui = DocumentBoxGui or class(_G.GrowPanel)

function DocumentBoxGui:init(dialog, ws, data, text_data)
	self._ws = ws
	self._data = data
	self._dialog = dialog
	self._text_data = text_data
	local ws_width = self._ws:panel():width()
	local ws_height = self._ws:panel():height()
	local gui_width = ws_width - 660
	local gui_height = ws_height - 70

	DocumentBoxGui.super.init(self, self._ws:panel(), {
		border_x = 20,
		padding_y = 0,
		padding_x = 0,
		border_y = 10,
		fixed_w = self._data.width or gui_width,
		fixed_h = self._data.height or gui_height
	})
	self:_create_boxgui()
	self:set_focus_button(data.focus_button)
end

function DocumentBoxGui:layer()
	return self._panel:layer()
end

function DocumentBoxGui:add_background()
	if alive(self._fullscreen_ws) then
		managers.gui_data:destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end

	self._fullscreen_ws = managers.gui_data:create_fullscreen_workspace()
	self._background = self._fullscreen_ws:panel():bitmap({
		texture = "guis/textures/test_blur_df",
		name = "bg",
		alpha = 0,
		valign = "grow",
		render_template = "VertexColorTexturedBlur3D",
		layer = 0,
		color = Color.white,
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h()
	})
	self._background2 = self._fullscreen_ws:panel():rect({
		blend_mode = "normal",
		name = "bg2",
		halign = "grow",
		alpha = 0,
		valign = "grow",
		layer = 0,
		color = Color.black
	})
end

function DocumentBoxGui:set_centered()
	self._panel:set_center(self._ws:panel():center())
end

function DocumentBoxGui:_create_boxgui()
	local tweak_data = _G.tweak_data
	local menu_manager = _G.managers.menu
	local FineText = _G.FineText
	local BoxGuiObject = _G.BoxGuiObject
	local GrowPanel = _G.GrowPanel
	local TextButton = _G.TextButton
	local ScrollableList = _G.ScrollableList
	local TextLegendsBar = _G.TextLegendsBar
	local ButtonLegendsBar = _G.ButtonLegendsBar

	self._panel:rect({
		alpha = 0.8,
		layer = -1,
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

	local title_text = self._placer:add_row(FineText:new(self._panel, {
		text = self._text_data.title,
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		color = tweak_data.screen_colors.text
	}), 0, 26)
	local button_sub_title_text = nil

	if self._data.button_sub_title then
		button_sub_title_text = FineText:new(self._panel, {
			wrap = true,
			align = "right",
			word_wrap = true,
			text = self._data.button_sub_title,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			w = self._panel:width() - 40
		})
	end

	local text_height = self._panel:h() - self._placer:current_bottom() - 26 - 14 - 35 - (menu_manager:is_pc_controller() and 21 * #self._data.button_list or 21) - (button_sub_title_text and button_sub_title_text:h() + 5 or 0)
	local scroll_config = {
		input_focus = true,
		scrollbar_padding = 10,
		scroll_w = 4,
		x_padding = 0,
		input = true,
		update = self._scroll_update,
		h = text_height,
		w = self._panel:width() - 40
	}
	local canvas_config = {
		border_y = 0,
		border_x = 0,
		padding_y = 5,
		padding_x = 0,
		padding = 5
	}
	local text_panel = self._placer:add_row(ScrollableList:new(self, scroll_config, canvas_config), 0, 26)
	self._text_panel = text_panel
	local bullet_texture, bullet_rect = tweak_data.hud_icons:get_icon_data("icon_equipped")
	local text_config = nil
	local text_canvas = text_panel:canvas()
	local text_placer = text_canvas:placer()

	for _, data in ipairs(self._text_data.text) do
		text_placer:new_row(10, data.padding)
		text_canvas:grow(0, data.padding)

		if data.bullet then
			text_placer:add_right(text_canvas:bitmap({
				texture = bullet_texture,
				texture_rect = bullet_rect
			}), 15)
		end

		if data.text then
			text_config = CoreTable.clone(data)
			text_config.w = text_canvas:w() - text_placer:current_right()

			if data.link then
				text_object = text_placer:add_right(TextButton:new(text_canvas, text_config, callback(self, self, "hyperlink_pressed", data.link)))
			else
				text_object = text_placer:add_right(FineText:new(text_canvas, text_config))
			end
		end
	end

	text_panel:scroll_item().scroll_indicators = {
		up_no_scroll = BoxGuiObject:new(text_panel, {
			sides = {
				3,
				3,
				1,
				0
			}
		}),
		up_scroll = BoxGuiObject:new(text_panel, {
			sides = {
				3,
				3,
				2,
				0
			}
		}),
		down_no_scroll = BoxGuiObject:new(text_panel, {
			sides = {
				4,
				4,
				0,
				1
			}
		}),
		down_scroll = BoxGuiObject:new(text_panel, {
			sides = {
				4,
				4,
				0,
				2
			}
		})
	}

	if button_sub_title_text then
		self._placer:add_row(button_sub_title_text, 0, 5)
	end

	if menu_manager:is_pc_controller() then
		self._legends = ButtonLegendsBar:new(self, nil, {
			wrap = true,
			w = self._panel:width() - 40
		})
	else
		self._legends = TextLegendsBar:new(self, nil, {
			wrap = true,
			w = self._panel:width() - 40
		})
	end

	self._placer:add_row(self._legends, 0, 14)

	for index, button in ipairs(self._data.button_list) do
		self._legends:add_item({
			text = button.text,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			force_break = menu_manager:is_pc_controller(),
			func = callback(self, self, "button_pressed", index)
		})
	end

	if not menu_manager:is_pc_controller() then
		self._legends:add_item("menu_legend_scroll")
	end
end

function DocumentBoxGui:_scroll_update(dt)
	local element, step = nil

	for element_name, data in pairs(self._alphas) do
		step = dt == -1 and 1 or dt * data.speed
		data.current = math.step(data.current, data.target, step)
		element = self:panel():child(element_name)

		if alive(element) then
			element:set_alpha(data.current)
		end
	end

	if self._alphas.scroll_up_indicator_arrow.target == 1 then
		self.scroll_indicators.up_scroll:show()
		self.scroll_indicators.up_no_scroll:hide()
	else
		self.scroll_indicators.up_scroll:hide()
		self.scroll_indicators.up_no_scroll:show()
	end

	if self._alphas.scroll_down_indicator_arrow.target == 1 then
		self.scroll_indicators.down_scroll:show()
		self.scroll_indicators.down_no_scroll:hide()
	else
		self.scroll_indicators.down_scroll:hide()
		self.scroll_indicators.down_no_scroll:show()
	end
end

function DocumentBoxGui:button_pressed(index)
	self._dialog:button_pressed(index)
end

function DocumentBoxGui:hyperlink_pressed(link)
	if SystemInfo:platform() == Idstring("WIN32") and SystemInfo:distribution() == Idstring("STEAM") then
		Steam:overlay_activate("url", link)
	end
end

function DocumentBoxGui:scroll_up(value)
	self._text_panel:perform_scroll(-value)
end

function DocumentBoxGui:scroll_down(value)
	self._text_panel:perform_scroll(value)
end

function DocumentBoxGui:release_scroll_bar()
	self._text_panel:scroll_item():release_scroll_bar()
end

function DocumentBoxGui:set_focus_button(button)
end

function DocumentBoxGui:change_focus_button(dir)
end

function DocumentBoxGui:get_focus_button()
	return 1
end

function DocumentBoxGui:set_fade(fade)
	self:_set_alpha(fade)

	if alive(self._background) then
		self._background:set_alpha(fade * 0.9)
	end

	if alive(self._background2) then
		self._background2:set_alpha(fade * 0.3)
	end
end

function DocumentBoxGui:_set_alpha(alpha)
	self._panel:set_alpha(alpha)
	self._panel:set_visible(alpha ~= 0)
end

function DocumentBoxGui:visible()
	return self._visible
end

function DocumentBoxGui:close()
	self:remove_self()

	if alive(self._background) then
		self._fullscreen_ws:panel():remove(self._background)
	end

	if alive(self._background2) then
		self._fullscreen_ws:panel():remove(self._background2)
	end

	if alive(self._fullscreen_ws) then
		managers.gui_data:destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end
end
