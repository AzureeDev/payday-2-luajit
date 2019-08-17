local padding = 10
local large_padding = 32
CrimeSpreeMissionEndOptions = CrimeSpreeMissionEndOptions or class(MenuGuiComponentGeneric)

function CrimeSpreeMissionEndOptions:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({})
	self._node = node

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

function CrimeSpreeMissionEndOptions:close()
	WalletGuiObject.close_wallet(self._ws:panel())
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

function CrimeSpreeMissionEndOptions:_setup()
	local parent = self._ws:panel()

	if alive(self._panel) then
		parent:remove(self._panel)
	end

	self._panel = parent:panel({
		layer = self._init_layer
	})
	self._button_panel = self._panel:panel({})
	local buttons = {
		{
			callback = "perform_select",
			pd2_corner = true,
			text_id = "menu_cs_select_modifier",
			visible_callback = {
				"is_server",
				"crime_spree_not_failed",
				"show_crime_spree_select_modifier"
			}
		},
		{
			callback = "perform_start",
			pd2_corner = true,
			text_id = "menu_cs_start",
			visible_callback = {
				"is_server",
				"crime_spree_not_failed",
				"show_crime_spree_start"
			}
		},
		{
			callback = "perform_reroll",
			pd2_corner = true,
			text_id = "menu_cs_reroll",
			corner_idx = 2,
			visible_callback = {
				"is_server",
				"crime_spree_not_failed",
				"show_crime_spree_reroll"
			}
		},
		{
			callback = "perform_continue",
			pd2_corner = true,
			text_id = "menu_cs_continue",
			visible_callback = {
				"crime_spree_in_progress",
				"crime_spree_failed"
			}
		}
	}
	local list_idx = 0
	local corner_idx, default_idx = nil

	for idx, btn in ipairs(buttons) do
		local visible = true

		for _, visible_callback in ipairs(btn.visible_callback) do
			if not MenuCallbackHandler[visible_callback] or not MenuCallbackHandler[visible_callback](MenuCallbackHandler) then
				visible = false

				break
			end
		end

		if visible then
			local font = tweak_data.menu.pd2_medium_font
			local font_size = tweak_data.menu.pd2_medium_font_size

			if btn.pd2_corner then
				font = tweak_data.menu.pd2_large_font
				font_size = tweak_data.menu.pd2_large_font_size * (corner_idx and 0.8 or 1)
			end

			local button = CrimeSpreeButton:new(self._button_panel, font, font_size)

			button:set_text(managers.localization:to_upper_text(btn.text_id))
			button:set_callback(callback(self, self, btn.callback))

			if btn.pd2_corner then
				if managers.menu:is_pc_controller() then
					button:shrink_wrap_button()

					if corner_idx then
						button:panel():set_right(corner_idx:panel():left() - large_padding)
					else
						button:panel():set_right(self._button_panel:right())
					end
				else
					button:panel():set_right(self._button_panel:right())

					if self._buttons[#self._buttons] then
						button:panel():set_top(self._buttons[#self._buttons]:panel():bottom() + 1 + padding)
					else
						button:panel():set_top(tweak_data.menu.pd2_large_font_size + list_idx * (tweak_data.menu.pd2_medium_font_size + 1))
					end
				end

				corner_idx = button

				if not default_idx then
					default_idx = #self._buttons + 1
				end
			else
				button:panel():set_top(tweak_data.menu.pd2_large_font_size + list_idx * (tweak_data.menu.pd2_medium_font_size + 1))
				button:panel():set_right(self._button_panel:right())

				list_idx = list_idx + 1
			end

			table.insert(self._buttons, button)
		end
	end

	if not managers.menu:is_pc_controller() and default_idx then
		self:_move_selection(default_idx)
	end
end

function CrimeSpreeMissionEndOptions:perform_edit()
	managers.menu:open_node("edit_game_settings", {})
end

function CrimeSpreeMissionEndOptions:perform_return()
	MenuCallbackHandler:return_to_crime_spree_lobby()
end

function CrimeSpreeMissionEndOptions:perform_select()
	MenuCallbackHandler:crime_spree_select_modifier()
end

function CrimeSpreeMissionEndOptions:perform_start()
	MenuCallbackHandler:crime_spree_start_game()
end

function CrimeSpreeMissionEndOptions:perform_reroll()
	MenuCallbackHandler:crime_spree_reroll()
end

function CrimeSpreeMissionEndOptions:perform_continue()
	MenuCallbackHandler:crime_spree_continue()
end

function CrimeSpreeMissionEndOptions:update(t, dt)
	for idx, btn in ipairs(self._buttons) do
		btn:update(t, dt)
	end
end

function CrimeSpreeMissionEndOptions:confirm_pressed()
	if self._selected_item and self._selected_item:callback() then
		self._selected_item:callback()()
	end
end

function CrimeSpreeMissionEndOptions:mouse_moved(o, x, y)
	if not managers.menu:is_pc_controller() then
		return
	end

	local used, pointer = nil
	self._selected_item = nil

	for idx, btn in ipairs(self._buttons) do
		btn:set_selected(btn:inside(x, y))

		if btn:is_selected() then
			self._selected_item = btn
			self._selected_idx = idx
			pointer = "link"
			used = true
		end
	end

	return used, pointer
end

function CrimeSpreeMissionEndOptions:mouse_pressed(o, button, x, y)
	for idx, btn in ipairs(self._buttons) do
		if btn:is_selected() and btn:callback() then
			btn:callback()()

			return true
		end
	end
end

function CrimeSpreeMissionEndOptions:move_up()
	self:_move_selection(-1)
end

function CrimeSpreeMissionEndOptions:move_down()
	self:_move_selection(1)
end

function CrimeSpreeMissionEndOptions:_move_selection(dir)
	if dir and dir ~= 0 then
		if self._selected_idx and self._buttons[self._selected_idx] then
			self._buttons[self._selected_idx]:set_selected(false)
		end

		self._selected_idx = (self._selected_idx or 0) + dir

		if self._selected_idx < 1 then
			self._selected_idx = #self._buttons
		end

		if self._selected_idx > #self._buttons then
			self._selected_idx = 1
		end

		self._selected_item = self._buttons[self._selected_idx]

		if self._selected_item then
			self._selected_item:set_selected(true)
		end
	end
end
