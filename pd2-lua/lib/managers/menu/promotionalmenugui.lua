require("lib/managers/menu/items/PromotionalMenuButton")

PromotionalMenuGui = PromotionalMenuGui or class(MenuGuiComponent)

function PromotionalMenuGui:init(ws, fullscreen_ws, node)
	self._fullscreen_ws = managers.gui_data:create_fullscreen_16_9_workspace()
	self._ws = managers.gui_data:create_saferect_workspace()
	self._node = node
	self._panel = self._ws:panel():panel()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		layer = -100
	})
	self.make_fine_text = BlackMarketGui.make_fine_text
	self._buttons = {}
	self._selection = {
		1,
		1
	}
	self._selection_map = {}
end

function PromotionalMenuGui:close()
	if alive(self._ws) then
		managers.gui_data:destroy_workspace(self._ws)

		self._ws = nil
	end

	if alive(self._fullscreen_ws) then
		managers.gui_data:destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end
end

function PromotionalMenuGui:_idx(x, y)
	local i = (y - 1) * self._menu_data.layout.x + x - 1

	return i
end

function PromotionalMenuGui:setup(menu_data, theme_data)
	self._menu_data = menu_data
	self._theme_data = theme_data
	local padding = menu_data.padding or 10

	if self._theme_data.backgrounds then
		local bg_panel = self._fullscreen_ws:panel({
			layer = -100
		})

		for idx, data in ipairs(self._theme_data.backgrounds) do
			if data.type == "image" then
				bg_panel:bitmap({
					texture = data.image,
					color = data.color,
					blend_mode = data.blend_mode or "normal",
					x = data.x or 0,
					y = data.y or 0,
					w = data.w or bg_panel:w(),
					h = data.h or bg_panel:h(),
					layer = idx
				})
			elseif data.type == "video" then
				bg_panel:video({
					name = "video",
					loop = true,
					video = data.video,
					width = data.w or bg_panel:w(),
					height = data.h or bg_panel:h(),
					blend_mode = data.blend_mode or "mul",
					alpha = data.alpha or 1,
					color = data.color or tweak_data.screen_colors.button_stage_3,
					layer = idx
				})
			elseif data.type == "color" then
				bg_panel:rect({
					color = data.color or Color.white,
					alpha = data.alpha or 1,
					blend_mode = data.blend_mode or "add",
					layer = idx
				})
			end
		end
	end

	local panel_size = math.min(self._panel:w() * menu_data.size, self._panel:h() * menu_data.size)
	self._items_panel = self._panel:panel({
		layer = 100,
		w = panel_size,
		h = panel_size
	})

	self._items_panel:set_center_y(self._panel:h() * 0.5)
	self._items_panel:set_right(self._panel:right() - self._items_panel:top())

	local w = math.floor((panel_size - padding * (menu_data.layout.x - 1)) / menu_data.layout.x)
	local h = math.floor((panel_size - padding * (menu_data.layout.y - 1)) / menu_data.layout.y)

	for _, btn_data in ipairs(menu_data.buttons) do
		local _x = math.floor((w + padding) * (btn_data.position[1] - 1))
		local _y = math.floor((h + padding) * (btn_data.position[2] - 1))
		local _w = math.floor(btn_data.size[1] * w + (btn_data.size[1] - 1) * padding)
		local _h = math.floor(btn_data.size[2] * h + (btn_data.size[2] - 1) * padding)
		btn_data.x = _x
		btn_data.y = _y
		btn_data.w = _w
		btn_data.h = _h
		local type_class = btn_data.type and _G[btn_data.type] or PromotionalMenuButton
		local btn = type_class:new(self, self._items_panel, btn_data, theme_data)

		table.insert(self._buttons, btn)

		local _x, _y = nil

		for x = 1, btn_data.size[1] do
			_x = x + btn:position()[1] - 1

			for y = 1, btn_data.size[2] do
				_y = y + btn:position()[2] - 1
				self._selection_map[self:_idx(_x, _y)] = btn
			end
		end
	end

	self:_add_back_button()

	for _, btn in ipairs(self._buttons) do
		if btn:can_be_selected() then
			self:move_selection(btn:position()[1] - 1, btn:position()[2] - 1, true)

			break
		end
	end
end

function PromotionalMenuGui:_add_back_button()
	local back_button = self._panel:text({
		vertical = "bottom",
		name = "back",
		blend_mode = "add",
		align = "right",
		layer = 40,
		text = managers.localization:text("menu_back"),
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3
	})

	self:make_fine_text(back_button)
	back_button:set_right(self._panel:w() - 10)
	back_button:set_bottom(self._panel:h() - 10)
	back_button:set_visible(managers.menu:is_pc_controller())

	self._back_button = back_button
	local bg_back = self._fullscreen_panel:text({
		name = "back_button",
		vertical = "bottom",
		h = 90,
		align = "right",
		alpha = 0.4,
		blend_mode = "add",
		layer = 1,
		text = utf8.to_upper(managers.localization:text("menu_back")),
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	local x, y = managers.gui_data:safe_to_full_16_9(self._panel:child("back"):world_right(), self._panel:child("back"):world_center_y())

	bg_back:set_world_right(x)
	bg_back:set_world_center_y(y)
	bg_back:move(13, -9)
	bg_back:set_visible(managers.menu:is_pc_controller())
end

function PromotionalMenuGui:_get_selected_button()
	local idx = self:_idx(self._selection[1], self._selection[2])

	return self._selection_map[idx]
end

function PromotionalMenuGui:_set_selection(btn, force)
	if force or btn:position()[1] == self._selection[1] and btn:position()[2] == self._selection[2] then
		for _, b in ipairs(self._buttons) do
			if btn ~= b then
				b:set_selected(false)
			end
		end

		self._selection[1] = btn:position()[1]
		self._selection[2] = btn:position()[2]

		btn:set_selected(true)
	end
end

function PromotionalMenuGui:move_selection(mx, my, force)
	local last_btn = self:_get_selected_button()
	local itr = 1

	repeat
		self._selection[1] = math.clamp(self._selection[1] + mx, 1, self._menu_data.layout.x)
		self._selection[2] = math.clamp(self._selection[2] + my, 1, self._menu_data.layout.y)
		local new_btn = self:_get_selected_button()

		if new_btn and not new_btn:can_be_selected() then
			self._selection[1] = math.clamp(self._selection[1] + math.sign(mx) * new_btn:size()[1], 1, self._menu_data.layout.x)
			self._selection[2] = math.clamp(self._selection[2] + math.sign(my) * new_btn:size()[2], 1, self._menu_data.layout.y)
		end

		itr = itr + 1
	until last_btn ~= self:_get_selected_button() or self._menu_data.layout.x < itr

	if last_btn ~= self:_get_selected_button() or force then
		if last_btn then
			last_btn:set_selected(false)
		end

		self:_set_selection(self:_get_selected_button(), true)
	end
end

function PromotionalMenuGui:input_focus()
	return 1
end

function PromotionalMenuGui:mouse_moved(button, x, y)
	local used, pointer = nil

	if alive(self._back_button) then
		if self._back_button:inside(x, y) then
			if not self._back_button_highlighted then
				self._back_button:set_color(tweak_data.screen_colors.button_stage_2)

				self._back_button_highlighted = true

				managers.menu:post_event("highlight")
			end

			pointer = "link"
			used = true
		else
			self._back_button:set_color(tweak_data.screen_colors.button_stage_3)

			self._back_button_highlighted = false
		end
	end

	for _, btn in ipairs(self._buttons) do
		if not used and btn:inside(x, y) then
			self:_set_selection(btn, true)

			pointer = "link"
			used = true
		end
	end

	return used, pointer
end

function PromotionalMenuGui:move_up()
	self:move_selection(0, -1)
end

function PromotionalMenuGui:move_down()
	self:move_selection(0, 1)
end

function PromotionalMenuGui:move_left()
	self:move_selection(-1, 0)
end

function PromotionalMenuGui:move_right()
	self:move_selection(1, 0)
end

function PromotionalMenuGui:mouse_clicked(o, button, x, y)
	if alive(self._back_button) and self._back_button:inside(x, y) then
		managers.menu:back(true)

		return true
	end

	for _, btn in ipairs(self._buttons) do
		if btn:inside(x, y) then
			btn:trigger()

			return true
		end
	end
end

function PromotionalMenuGui:confirm_pressed()
	local btn = self:_get_selected_button()

	if btn then
		btn:trigger()
	end
end
