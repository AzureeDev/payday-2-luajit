MenuNodeUpdatesGui = MenuNodeUpdatesGui or class(MenuNodeGui)
MenuNodeUpdatesGui.PADDING = 10

function MenuNodeUpdatesGui:init(node, layer, parameters)
	MenuNodeUpdatesGui.super.init(self, node, layer, parameters)

	self._tweak_data = tweak_data.gui[node and node:parameters().tweak_data_name or "content_updates"]
	self._node = node

	self:setup()

	if self._tweak_data.db_url then
		if self._panel then
			local previous_content_updates = self._panel:child("previous_content_updates")

			local function animate_loading_texture(o)
				local time = coroutine.yield()
				local start_rotation = o:rotation()

				while true do
					o:set_rotation(start_rotation + time * 180)

					time = time + coroutine.yield() * 2
				end
			end

			local ws = self.ws
			local panel = ws and ws:panel():child("MenuNodeUpdatesGui")
			local desc_text = panel and panel:child("latest_description")

			if alive(desc_text) then
				local bitmap = self._panel:bitmap({
					texture = "guis/textures/pd2/endscreen/exp_ring",
					alpha = 0.75,
					h = 32,
					w = 32,
					render_template = "VertexColorTexturedRadial",
					layer = 2,
					color = Color(0.1, 1, 1)
				})

				bitmap:set_position(desc_text:position())
				bitmap:animate(animate_loading_texture)

				local loading_text = self._panel:text({
					text = managers.localization:to_upper_text("menu_http_loading"),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					color = tweak_data.screen_colors.text
				})

				self:make_fine_text(loading_text)
				loading_text:set_left(bitmap:right())
				loading_text:set_center_y(bitmap:center_y())

				self._loading_bitmap = bitmap
				self._loading_text = loading_text
			end
		end

		Steam:http_request(self._tweak_data.db_url, callback(self, self, "_db_result_recieved"))
	end
end

function MenuNodeUpdatesGui:_db_result_recieved(success, page)
	if not self then
		return
	end

	local item_list = self._tweak_data.item_list
	local num_items = self._tweak_data.num_items or 5
	local items_source = {}
	local items = {}
	local prefix = "##1##"
	local item_start = string.find(page, prefix)

	for index = 1, #item_list do
		local item = item_list[index]

		if item and item.use_db then
			local suffix = index == num_items and "##end##" or "##" .. tonumber(index + 1) .. "##"
			local item_end = string.find(page, suffix)
			items_source["fav" .. tostring(index)] = string.sub(page, item_start, item_end)
			item_start = item_end
		end
	end

	for item_id, s in pairs(items_source) do
		local title_text = self:_get_text(s, "<h2>", "</h2>")
		local desc_text = self:_get_text(s, "<p>", "</p>")
		local link_text = self:_get_text(self:_get_text(s, "<iframe", "</iframe>") or "", "src=\"", "\" ")

		if not string.find(link_text, "http:") then
			link_text = "http:" .. link_text
		end

		items[item_id] = {
			title = title_text,
			desc = desc_text,
			link = link_text
		}
	end

	self._db_items = items

	if alive(self._loading_bitmap) then
		self._loading_bitmap:parent():remove(self._loading_bitmap)
	end

	if alive(self._loading_text) then
		self._loading_text:parent():remove(self._loading_text)
	end

	for i, text in pairs(self._previous_update_texts) do
		if self._db_items[i] then
			text:set_text(self._db_items[i].title or " ")
			self:make_fine_text(text)
		end
	end

	self:set_latest_text()
end

function MenuNodeUpdatesGui:_get_text(s, sp, ep)
	local result = {}
	local len = string.len(s)
	local i = 1
	local s1, e1 = string.find(s, sp, 1, true)

	if not e1 then
		return ""
	end

	local s2, e2 = string.find(s, ep, e1, true)

	return string.sub(s, e1 + 1, s2 - 1) or ""
end

function MenuNodeUpdatesGui:_get_db_text(id, category)
	if not self._db_items then
		return
	end

	if not self._db_items[id] then
		return
	end

	return self._db_items[id][category]
end

function MenuNodeUpdatesGui:setup()
	self:unretrieve_textures()

	self._next_page_highlighted = nil
	self._prev_page_highlighted = nil
	self._back_button_highlighted = nil
	local ws = self.ws
	local panel = ws:panel():child("MenuNodeUpdatesGui") or ws:panel():panel({
		name = "MenuNodeUpdatesGui"
	})
	self._panel = panel

	panel:clear()

	local title_text = managers.localization:to_upper_text(self._tweak_data.title_id or "menu_content_updates")

	panel:text({
		vertical = "top",
		align = "left",
		text = title_text,
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})

	local back_button = panel:text({
		vertical = "bottom",
		name = "back_button",
		align = "right",
		text = managers.localization:to_upper_text("menu_back"),
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3
	})

	self:make_fine_text(back_button)
	back_button:set_right(panel:w())
	back_button:set_bottom(panel:h())
	back_button:set_visible(managers.menu:is_pc_controller())

	if MenuBackdropGUI then
		local bg_text = panel:text({
			vertical = "top",
			alpha = 0.4,
			align = "left",
			rotation = 360,
			layer = -1,
			text = title_text,
			font_size = tweak_data.menu.pd2_massive_font_size,
			font = tweak_data.menu.pd2_massive_font,
			color = tweak_data.screen_colors.button_stage_3
		})

		self:make_fine_text(bg_text)
		bg_text:move(-13, -9)
		MenuBackdropGUI.animate_bg_text(self, bg_text)

		if managers.menu:is_pc_controller() then
			local bg_back = panel:text({
				vertical = "bottom",
				alpha = 0.4,
				align = "right",
				rotation = 360,
				layer = -1,
				text = managers.localization:to_upper_text("menu_back"),
				font_size = tweak_data.menu.pd2_massive_font_size,
				font = tweak_data.menu.pd2_massive_font,
				color = tweak_data.screen_colors.button_stage_3
			})

			self:make_fine_text(bg_back)
			bg_back:move(13, 9)
			MenuBackdropGUI.animate_bg_text(self, bg_back)
		end
	end

	self._requested_textures = {}
	local num_previous_updates = self._tweak_data.num_items or 5
	local current_page = self._node:parameters().current_page or 1
	local start_number = (current_page - 1) * num_previous_updates
	local content_updates = self._tweak_data.item_list or {}
	local previous_updates = {}
	local latest_update = content_updates[#content_updates - start_number]

	for i = #content_updates - start_number, math.max(#content_updates - num_previous_updates - start_number + 1, 1), -1 do
		table.insert(previous_updates, content_updates[i])
	end

	self._lastest_content_update = latest_update
	self._previous_content_updates = previous_updates
	self._num_previous_updates = num_previous_updates
	local latest_update_panel = panel:panel({
		name = "lastest_content_update",
		y = 70,
		x = 0,
		w = panel:w() / 2,
		h = panel:w() / 4
	})

	if SystemInfo:platform() ~= Idstring("WIN32") then
		latest_update_panel:set_w(latest_update_panel:w() * 0.8)
		latest_update_panel:set_h(latest_update_panel:w() * 0.5)
	end

	local selected = BoxGuiObject:new(latest_update_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})

	BoxGuiObject:new(latest_update_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._selects = {
		[latest_update.id] = selected
	}
	self._select_x = 1
	local w = panel:w()
	local padding = SystemInfo:platform() == Idstring("WIN32") and 30 or 5
	local dech_panel_h = SystemInfo:platform() == Idstring("WIN32") and latest_update_panel:h() or panel:h() / 2
	local latest_desc_panel = panel:panel({
		name = "latest_description",
		w = panel:w() - latest_update_panel:w() - padding,
		h = dech_panel_h,
		x = latest_update_panel:right() + padding,
		y = latest_update_panel:top()
	})

	BoxGuiObject:new(latest_desc_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local title_string = latest_update.name_id and managers.localization:to_upper_text(latest_update.name_id) or self:_get_db_text(latest_update.id, "title") or ""
	local date_string = latest_update.date_id and managers.localization:to_upper_text(latest_update.date_id) or self:_get_db_text(latest_update.id, "date") or ""
	local desc_string = latest_update.desc_id and managers.localization:text(latest_update.desc_id) or self:_get_db_text(latest_update.id, "desc") or ""
	local title_text = latest_desc_panel:text({
		name = "title_text",
		text = title_string,
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		color = tweak_data.screen_colors.text,
		x = self.PADDING,
		y = self.PADDING
	})
	local date_text = latest_desc_panel:text({
		name = "date_text",
		text = date_string,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text,
		x = self.PADDING
	})
	local desc_text = latest_desc_panel:text({
		name = "desc_text",
		wrap = true,
		word_wrap = true,
		text = desc_string,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		x = self.PADDING
	})
	local x, y, w, h = title_text:text_rect()

	title_text:set_size(w, h)

	local x, y, w, h = date_text:text_rect()

	date_text:set_size(w, h)
	date_text:set_top(title_text:bottom())
	desc_text:set_top(date_text:bottom())
	desc_text:set_size(latest_desc_panel:w() - self.PADDING * 2, latest_desc_panel:h() - desc_text:top() - self.PADDING)

	if self._tweak_data.button then
		local top_button = panel:panel({
			w = 32,
			name = "top_button",
			h = 32
		})
		local w = 0
		local h = 0

		if self._tweak_data.button.text_id then
			local text = top_button:text({
				vertical = "top",
				halign = "right",
				align = "right",
				valign = "top",
				text = managers.localization:to_upper_text(self._tweak_data.button.text_id),
				font_size = tweak_data.menu.pd2_medium_font_size,
				font = tweak_data.menu.pd2_medium_font,
				color = tweak_data.screen_colors.button_stage_3
			})
			local _, _, tw, th = self:make_fine_text(text)

			text:set_top(0)
			text:set_right(top_button:w())

			w = math.max(w, tw)
			h = math.max(h, th)
		end

		if self._tweak_data.button.image then
			local bitmap = top_button:bitmap({
				valign = "top",
				halign = "right",
				texture = self._tweak_data.button.image,
				color = tweak_data.screen_colors.button_stage_3
			})

			bitmap:set_top(0)
			bitmap:set_right(top_button:w())

			w = math.max(w, bitmap:w())
			h = math.max(h, bitmap:h())
		end

		top_button:set_size(w, h)
		top_button:set_bottom(latest_desc_panel:top())
		top_button:set_right(panel:w())
	end

	local small_width = w / num_previous_updates - self.PADDING * 2
	local previous_updates_panel = panel:panel({
		name = "previous_content_updates",
		x = 0,
		w = w,
		h = small_width / 2 + self.PADDING * 2,
		y = math.max(latest_update_panel:bottom(), latest_desc_panel:bottom()) + 30
	})
	local previous_update_text = panel:text({
		name = "previous_update_text",
		text = self._tweak_data.choice_id and managers.localization:to_upper_text(self._tweak_data.choice_id) or "",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	self:make_fine_text(previous_update_text)
	previous_update_text:set_leftbottom(previous_updates_panel:left(), previous_updates_panel:top())

	local data = nil
	self._previous_update_texts = {}

	for index, data in ipairs(previous_updates) do
		local w = small_width
		local h = small_width / 2
		local x = self.PADDING + (index - 1) * (w + self.PADDING * 2)
		local y = self.PADDING
		local content_panel = previous_updates_panel:panel({
			name = data.id,
			w = w,
			h = h,
			x = x,
			y = y
		})
		local texture_count = managers.menu_component:request_texture(data.image, callback(self, self, "texture_done_clbk", content_panel))

		table.insert(self._requested_textures, {
			texture_count = texture_count,
			texture = data.image
		})

		local text_string = data.name_id and managers.localization:to_upper_text(data.name_id) or self:_get_db_text(data.id, "desc") or " "
		local text = panel:text({
			name = data.name_id,
			text = text_string,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})

		self:make_fine_text(text)

		if index == 1 then
			previous_updates_panel:grow(0, text:h() + self.PADDING * 0.5)
		end

		text:set_world_x(content_panel:world_x())
		text:set_bottom(previous_updates_panel:bottom() - self.PADDING + 1)

		self._previous_update_texts[data.id] = text
		local selected = BoxGuiObject:new(content_panel, {
			sides = {
				2,
				2,
				2,
				2
			}
		})
		self._selects[data.id] = selected
	end

	BoxGuiObject:new(previous_updates_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	for i, box in pairs(self._selects) do
		box:hide()
	end

	self:set_latest_content(latest_update, true)

	self._current_page = current_page
	self._num_pages = math.ceil(#content_updates / num_previous_updates)

	if num_previous_updates < #content_updates then
		local num_pages = self._num_pages
		self._prev_page = panel:panel({
			name = "previous_page",
			w = tweak_data.menu.pd2_medium_font_size,
			h = tweak_data.menu.pd2_medium_font_size
		})
		self._next_page = panel:panel({
			name = "next_page",
			w = tweak_data.menu.pd2_medium_font_size,
			h = tweak_data.menu.pd2_medium_font_size
		})
		local prev_button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_l") or managers.menu:is_pc_controller() and "<" or managers.localization:get_default_macro("BTN_BOTTOM_L")
		local next_button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_r") or managers.menu:is_pc_controller() and ">" or managers.localization:get_default_macro("BTN_BOTTOM_R")
		local prev_text = self._prev_page:text({
			name = "text_obj",
			vertical = "center",
			align = "center",
			text = prev_button,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size
		})
		local next_text = self._next_page:text({
			name = "text_obj",
			vertical = "center",
			align = "center",
			text = next_button,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size
		})
		local page_text = panel:text({
			vertical = "center",
			align = "center",
			text = tostring(current_page) .. "/" .. tostring(num_pages),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text
		})

		self:make_fine_text(page_text)
		self._next_page:set_right(previous_updates_panel:right() - 10)
		self._next_page:set_bottom(previous_updates_panel:top() - 10)
		self._prev_page:set_right(self._next_page:left() - page_text:w() - 8)
		self._prev_page:set_bottom(self._next_page:bottom())
		page_text:set_center((self._prev_page:right() + self._next_page:left()) / 2, self._next_page:center_y() + 3)
		prev_text:set_color(not managers.menu:is_pc_controller() and Color.white or current_page > 1 and tweak_data.screen_colors.button_stage_3 or tweak_data.menu.default_disabled_text_color)
		next_text:set_color(not managers.menu:is_pc_controller() and Color.white or current_page < num_pages and tweak_data.screen_colors.button_stage_3 or tweak_data.menu.default_disabled_text_color)
	end
end

function MenuNodeUpdatesGui:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(x), math.round(y))

	return x, y, w, h
end

function MenuNodeUpdatesGui:texture_done_clbk(panel, texture_ids)
	panel:bitmap({
		name = "texture",
		texture = texture_ids,
		w = panel:w(),
		h = panel:h()
	})
end

function MenuNodeUpdatesGui:check_inside(x, y)
	local ws = self.ws
	local panel = ws:panel():child("MenuNodeUpdatesGui")
	local latest_update_panel = panel:child("lastest_content_update")
	local previous_updates_panel = panel:child("previous_content_updates")

	if latest_update_panel:inside(x, y) then
		return self._lastest_content_update
	elseif previous_updates_panel:inside(x, y) then
		local child = nil

		for index, data in ipairs(self._previous_content_updates) do
			child = previous_updates_panel:child(data.id)

			if alive(child) and child:inside(x, y) then
				self._select_x = index

				return data
			end
		end
	end

	return nil
end

function MenuNodeUpdatesGui:mouse_moved(o, x, y)
	local moved = self._mouse_x ~= x or self._mouse_y ~= y
	self._mouse_x = x
	self._mouse_y = y

	if alive(self._prev_page) then
		local text = self._prev_page:child("text_obj")

		if self._current_page > 1 then
			if self._prev_page:inside(x, y) then
				if not self._prev_page_highlighted then
					self._prev_page_highlighted = true

					managers.menu_component:post_event("highlight")
					text:set_color(tweak_data.screen_colors.button_stage_2)
				end

				return true, "link"
			elseif self._prev_page_highlighted then
				self._prev_page_highlighted = false

				text:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end
	end

	if alive(self._next_page) then
		local text = self._next_page:child("text_obj")
		local num_pages = self._num_pages

		if self._current_page < num_pages then
			if self._next_page:inside(x, y) then
				if not self._next_page_highlighted then
					self._next_page_highlighted = true

					managers.menu_component:post_event("highlight")
					text:set_color(tweak_data.screen_colors.button_stage_2)
				end

				return true, "link"
			elseif self._next_page_highlighted then
				self._next_page_highlighted = false

				text:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end
	end

	local ws = self.ws
	local panel = ws:panel():child("MenuNodeUpdatesGui")
	local back_button = panel:child("back_button")
	local back_highlighted = back_button:inside(x, y)

	if back_highlighted then
		if not self._back_button_highlighted then
			self._back_button_highlighted = true

			back_button:set_color(tweak_data.screen_colors.button_stage_2)
			managers.menu_component:post_event("highlight")
		end

		return true, self._pressed and "arrow" or "link"
	elseif self._back_button_highlighted then
		self._back_button_highlighted = false

		back_button:set_color(tweak_data.screen_colors.button_stage_3)
	end

	local top_button = panel:child("top_button")

	if alive(top_button) then
		local top_highlighted = top_button:inside(x, y)

		if top_highlighted then
			if not self._top_button_highlighted then
				self._top_button_highlighted = true

				for _, child in ipairs(top_button:children()) do
					child:set_color(tweak_data.screen_colors.button_stage_2)
				end

				managers.menu_component:post_event("highlight")
			end

			return true, self._pressed and "arrow" or "link"
		elseif self._top_button_highlighted then
			self._top_button_highlighted = false

			for _, child in ipairs(top_button:children()) do
				child:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end
	end

	local content_highlighted = self:check_inside(x, y)

	if self:set_latest_content(content_highlighted, moved) then
		return true, self._pressed and (self._pressed == content_highlighted and "link" or "arrow") or "link"
	end

	return false, "arrow"
end

function MenuNodeUpdatesGui:mouse_pressed(button, x, y)
	if alive(self._prev_page) and self._current_page > 1 and self._prev_page:inside(x, y) then
		self._node:parameters().current_page = self._current_page - 1

		self:setup()

		return
	end

	if alive(self._next_page) then
		local num_pages = self._num_pages

		if self._current_page < num_pages and self._next_page:inside(x, y) then
			self._node:parameters().current_page = self._current_page + 1

			self:setup()

			return
		end
	end

	self._pressed = self:check_inside(x, y)
	local ws = self.ws
	local panel = ws:panel():child("MenuNodeUpdatesGui")
	local back_button = panel:child("back_button")

	if back_button:inside(x, y) then
		managers.menu:back(true)

		return
	end

	local top_button = panel:child("top_button")

	if alive(top_button) and self._tweak_data.button and self._tweak_data.button.url and top_button:inside(x, y) then
		self:open_url(self._tweak_data.button.url)

		return
	end
end

function MenuNodeUpdatesGui:mouse_released(button, x, y)
	local released = self:check_inside(x, y)

	if released and released == self._pressed then
		self:open(released)
	end

	self._pressed = nil
end

function MenuNodeUpdatesGui:confirm_pressed()
	if self._content_highlighted then
		self:open(self._content_highlighted)
	end
end

function MenuNodeUpdatesGui:open(content_update)
	self._content_highlighted = content_update

	managers.player:set_content_update_viewed(content_update.id)

	local play_sound = true

	if SystemInfo:platform() == Idstring("WIN32") then
		if not MenuCallbackHandler:is_overlay_enabled() then
			managers.menu:show_enable_steam_overlay()

			play_sound = false
		elseif content_update.webpage then
			Steam:overlay_activate("url", content_update.webpage)
		elseif content_update.store then
			Steam:overlay_activate("store", content_update.store)
		elseif content_update.use_db then
			local webpage = self._db_items and self._db_items[content_update.id] and self._db_items[content_update.id].link

			if webpage then
				Steam:overlay_activate("url", webpage)
			else
				play_sound = false
			end
		else
			play_sound = false
		end
	elseif SystemInfo:platform() == Idstring("PS3") then
		if true or not managers.dlc:is_dlc_unlocked(content_update.id) then
			managers.dlc:buy_product(content_update.id)
		else
			play_sound = false
		end
	else
		play_sound = false
	end

	if play_sound then
		managers.menu_component:post_event("menu_enter")
	end
end

function MenuNodeUpdatesGui:open_url(url)
	if SystemInfo:platform() == Idstring("WIN32") then
		Steam:overlay_activate("url", url)
		managers.menu_component:post_event("menu_enter")
	end
end

function MenuNodeUpdatesGui:input_focus()
	return 1
end

function MenuNodeUpdatesGui:set_latest_text()
	if not self._content_highlighted then
		return
	end

	local ws = self.ws
	local panel = ws:panel():child("MenuNodeUpdatesGui")
	local latest_desc_panel = panel:child("latest_description")
	local title_string = self._content_highlighted.name_id and managers.localization:to_upper_text(self._content_highlighted.name_id) or self:_get_db_text(self._content_highlighted.id, "title") or ""
	local date_string = self._content_highlighted.date_id and managers.localization:to_upper_text(self._content_highlighted.date_id) or self:_get_db_text(self._content_highlighted.id, "date") or ""
	local desc_string = self._content_highlighted.desc_id and managers.localization:text(self._content_highlighted.desc_id) or self:_get_db_text(self._content_highlighted.id, "desc") or ""
	local title_text = latest_desc_panel:child("title_text")
	local date_text = latest_desc_panel:child("date_text")
	local desc_text = latest_desc_panel:child("desc_text")

	title_text:set_text(title_string)

	local x, y, w, h = title_text:text_rect()

	title_text:set_size(w, h)
	date_text:set_text(date_string)

	local x, y, w, h = date_text:text_rect()

	date_text:set_size(w, h)
	date_text:set_top(title_text:bottom())
	desc_text:set_text(desc_string)
	desc_text:set_top(date_text:bottom())
	desc_text:set_size(latest_desc_panel:w() - self.PADDING * 2, latest_desc_panel:h() - desc_text:top() - self.PADDING)
end

function MenuNodeUpdatesGui:set_latest_content(content_highlighted, moved, refresh)
	local result = false

	if content_highlighted then
		if moved and self._content_highlighted ~= content_highlighted then
			self._content_highlighted = content_highlighted
			self._lastest_content_update = content_highlighted

			managers.menu_component:post_event("highlight")

			local ws = self.ws
			local panel = ws:panel():child("MenuNodeUpdatesGui")
			local latest_update_panel = panel:child("lastest_content_update")

			if alive(latest_update_panel:child("texture")) then
				latest_update_panel:remove(latest_update_panel:child("texture"))
			end

			if self._lastest_texture_request then
				managers.menu_component:unretrieve_texture(self._lastest_texture_request.texture, self._lastest_texture_request.texture_count)
			end

			local texture = content_highlighted.image
			local texture_count = managers.menu_component:request_texture(texture, callback(self, self, "texture_done_clbk", latest_update_panel))
			self._lastest_texture_request = {
				texture_count = texture_count,
				texture = texture
			}

			self:set_latest_text()
		end

		result = true
	elseif self._content_highlighted then
		-- Nothing
	end

	for id, box in pairs(self._selects) do
		box:set_visible(self._content_highlighted and self._content_highlighted.id == id)
	end

	return result
end

function MenuNodeUpdatesGui:move_highlight(x, y)
	local ws = self.ws
	local panel = ws:panel():child("MenuNodeUpdatesGui")
	local latest_update_panel = panel:child("lastest_content_update")
	local previous_updates_panel = panel:child("previous_content_updates")
	local content_highlighted = self._content_highlighted

	if content_highlighted then
		self._select_x = self._select_x + x
	end

	local old_x = self._select_x
	self._select_x = math.clamp(self._select_x, 1, math.min(#self._previous_content_updates, self._num_previous_updates))
	local diff_x = old_x - self._select_x

	if diff_x < 0 then
		if self:previous_page() then
			self._select_x = self._num_previous_updates
			content_highlighted = self._previous_content_updates[self._select_x]

			self:set_latest_content(content_highlighted, true)
		end
	elseif diff_x > 0 then
		if self:next_page() then
			-- Nothing
		end
	else
		content_highlighted = self._previous_content_updates[self._select_x]

		self:set_latest_content(content_highlighted, true)
	end
end

function MenuNodeUpdatesGui:previous_page()
	if self._current_page > 1 then
		self._node:parameters().current_page = self._current_page - 1

		self:setup()

		return true
	end
end

function MenuNodeUpdatesGui:next_page()
	local num_pages = self._num_pages

	if self._current_page < num_pages then
		self._node:parameters().current_page = self._current_page + 1

		self:setup()

		return true
	end
end

function MenuNodeUpdatesGui:move_up()
end

function MenuNodeUpdatesGui:move_down()
end

function MenuNodeUpdatesGui:move_left()
	self:move_highlight(-1, 0)

	return true
end

function MenuNodeUpdatesGui:move_right()
	self:move_highlight(1, 0)

	return true
end

function MenuNodeUpdatesGui:unretrieve_textures()
	if self._requested_textures then
		for i, data in pairs(self._requested_textures) do
			managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
		end
	end

	if self._lastest_texture_request then
		managers.menu_component:unretrieve_texture(self._lastest_texture_request.texture, self._lastest_texture_request.texture_count)
	end

	self._requested_textures = nil
	self._lastest_texture_request = nil
end

function MenuNodeUpdatesGui:close()
	self:unretrieve_textures()
	MenuNodeUpdatesGui.super.close(self)
end

function MenuNodeUpdatesGui:_setup_panels(node)
	MenuNodeUpdatesGui.super._setup_panels(self, node)
end
