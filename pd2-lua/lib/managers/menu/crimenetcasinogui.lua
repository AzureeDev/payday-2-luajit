CrimeNetCasinoGui = CrimeNetCasinoGui or class()

function CrimeNetCasinoGui:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._panel = self._ws:panel():panel({
		layer = 51
	})
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		layer = 50
	})

	self._fullscreen_panel:rect({
		alpha = 0.75,
		layer = 0,
		color = Color.black
	})

	self._node = node
	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		layer = 1,
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h()
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	blur:animate(func)

	local medium_font = tweak_data.menu.pd2_medium_font
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	self._button_panel = self._panel:panel({
		layer = 1
	})
	local button_exit = self._button_panel:text({
		name = "button_exit",
		align = "right",
		blend_mode = "add",
		layer = 1,
		text = managers.localization:to_upper_text("menu_casino_choice_exit", {
			BTN_X = managers.localization:btn_macro("menu_casino_exit")
		}),
		font = medium_font,
		font_size = medium_font_size,
		color = tweak_data.screen_colors.text
	})
	local _, _, w, h = button_exit:text_rect()

	button_exit:set_w(w)
	button_exit:set_h(h)
	button_exit:set_right(self._panel:right())
	button_exit:set_bottom(self._panel:bottom())
	button_exit:set_visible(managers.menu:is_pc_controller())

	local button_bet = self._button_panel:text({
		name = "button_bet",
		align = "right",
		blend_mode = "add",
		layer = 1,
		text = managers.localization:to_upper_text("menu_casino_choice_bet", {
			BTN_X = managers.localization:btn_macro("menu_casino_bet")
		}),
		font = medium_font,
		font_size = medium_font_size,
		color = tweak_data.screen_colors.text
	})
	local _, _, w, h = button_bet:text_rect()

	button_bet:set_w(w)
	button_bet:set_h(h)
	button_bet:set_right(self._panel:right())
	button_bet:set_bottom(button_exit:top())
	button_bet:set_visible(managers.menu:is_pc_controller())

	if managers.menu:is_pc_controller() then
		button_bet:set_color(tweak_data.screen_colors.button_stage_3)
		button_exit:set_color(tweak_data.screen_colors.button_stage_3)
	end

	self:can_afford()

	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:deactivate_controller_mouse()
	end
end

function CrimeNetCasinoGui:close()
	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:activate_controller_mouse()
	end

	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

function CrimeNetCasinoGui:mouse_moved(x, y)
	if alive(self._button_panel) then
		if self._button_bet_highlight and self._can_afford then
			self._button_panel:child("button_bet"):set_color(tweak_data.screen_colors.button_stage_3)

			self._button_bet_highlight = false
		end

		if self._button_exit_highlight then
			self._button_panel:child("button_exit"):set_color(tweak_data.screen_colors.button_stage_3)

			self._button_exit_highlight = false
		end

		if self._can_afford and self._button_panel:child("button_bet"):inside(x, y) then
			if not self._button_bet_highlight then
				self._button_bet_highlight = true

				self._button_panel:child("button_bet"):set_color(tweak_data.screen_colors.button_stage_2)
			end

			return true, "link"
		elseif self._button_panel:child("button_exit"):inside(x, y) then
			if not self._button_exit_highlight then
				self._button_exit_highlight = true

				self._button_panel:child("button_exit"):set_color(tweak_data.screen_colors.button_stage_2)
			end

			return true, "link"
		end
	end

	return false, "arrow"
end

function CrimeNetCasinoGui:mouse_pressed(button, x, y)
	if alive(self._button_panel) then
		if self._button_panel:child("button_bet"):inside(x, y) then
			self:_place_bet()
		elseif self._button_panel:child("button_exit"):inside(x, y) then
			self:_exit()
		end
	end
end

function CrimeNetCasinoGui:special_btn_pressed(button)
	if button == Idstring("start_bet") then
		self:_place_bet()

		return true
	end

	return false
end

function CrimeNetCasinoGui:can_afford()
	local secured_cards, increase_infamous, preferred_card = self:_crimenet_casino_additional_cost()
	local can_afford = managers.money:can_afford_casino_fee(secured_cards, increase_infamous, preferred_card)

	if self._can_afford ~= can_afford then
		local button = self._button_panel:child("button_bet")

		if can_afford then
			button:set_color(self._button_bet_highlight and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
			button:set_text(managers.localization:to_upper_text("menu_casino_choice_bet", {
				BTN_X = managers.localization:btn_macro("menu_casino_bet")
			}))
			button:set_visible(managers.menu:is_pc_controller())
		else
			button:set_color(tweak_data.screen_colors.important_1)
			button:set_text(managers.localization:to_upper_text("menu_cn_premium_cannot_buy"))
			button:set_visible(true)
		end

		local _, _, w, h = button:text_rect()

		button:set_w(w)
		button:set_h(h)
		button:set_right(self._panel:right())

		self._can_afford = can_afford
	end
end

function CrimeNetCasinoGui:_crimenet_casino_additional_cost()
	local card1 = managers.menu:active_menu().logic:selected_node():item("secure_card_1") and managers.menu:active_menu().logic:selected_node():item("secure_card_1"):value() == "on" and 1 or 0
	local card2 = managers.menu:active_menu().logic:selected_node():item("secure_card_2") and managers.menu:active_menu().logic:selected_node():item("secure_card_2"):value() == "on" and 1 or 0
	local card3 = managers.menu:active_menu().logic:selected_node():item("secure_card_3") and managers.menu:active_menu().logic:selected_node():item("secure_card_3"):value() == "on" and 1 or 0
	local secure_cards = card1 + card2 + card3
	local increase_infamous = managers.menu:active_menu().logic:selected_node():item("increase_infamous") and managers.menu:active_menu().logic:selected_node():item("increase_infamous"):value() == "on"
	local preferred_card = managers.menu:active_menu().logic:selected_node():item("preferred_item") and managers.menu:active_menu().logic:selected_node():item("preferred_item"):value() or "none"

	return secure_cards, increase_infamous, preferred_card
end

function CrimeNetCasinoGui:_place_bet()
	if self._betting then
		return
	end

	local secure_cards, increase_infamous, preferred_card = self:_crimenet_casino_additional_cost()

	if not managers.money:can_afford_casino_fee(secure_cards, increase_infamous, preferred_card) then
		return
	end

	local params = {
		contract_fee = managers.experience:cash_string(managers.money:get_cost_of_casino_fee(secure_cards, increase_infamous, preferred_card)),
		offshore = managers.experience:cash_string(managers.money:offshore()),
		yes_func = callback(self, self, "_crimenet_casino_pay_fee")
	}

	managers.menu:show_confirm_pay_casino_fee(params)
end

function CrimeNetCasinoGui:_exit()
	managers.menu:active_menu().logic:navigate_back(true)
end

function CrimeNetCasinoGui:_crimenet_casino_pay_fee()
	self._betting = true
	local secure_cards, increase_infamous, preferred_card = self:_crimenet_casino_additional_cost()

	if not managers.money:can_afford_casino_fee(secure_cards, increase_infamous, preferred_card) then
		return
	end

	if managers.menu:active_menu().logic:selected_node():item("preferred_item") then
		managers.money:on_buy_casino_fee(secure_cards, increase_infamous, preferred_card)
		managers.menu:active_menu().renderer:selected_node():set_offshore_text()

		local node_data = {
			preferred_item = preferred_card,
			secure_cards = secure_cards,
			increase_infamous = increase_infamous,
			back_callback = callback(self, self, "_crimenet_casino_lootdrop_back")
		}

		managers.menu:open_node("crimenet_contract_casino_lootdrop", {
			node_data
		})
	end
end

function CrimeNetCasinoGui:_crimenet_casino_lootdrop_back()
	local done = managers.menu_component:check_lootdrop_casino_done()

	if done then
		self._betting = nil
	end

	return not done
end
