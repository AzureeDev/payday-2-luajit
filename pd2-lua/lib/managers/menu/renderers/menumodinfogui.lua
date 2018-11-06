require("lib/managers/menu/renderers/MenuNodeBaseGui")

MenuModInfoGui = MenuModInfoGui or class(MenuNodeBaseGui)

function MenuModInfoGui:init(node, layer, parameters)
	MenuModInfoGui.super.init(self, node, layer, parameters)

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end
end

function MenuModInfoGui:close()
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(false)
	end

	MenuModInfoGui.super.close(self)
end

function MenuModInfoGui:setup()
	MenuModInfoGui.super.setup(self)

	local panel = self.safe_rect_panel:panel({
		name = "mod_main_panel",
		y = 40,
		w = self.safe_rect_panel:w() * 0.6,
		h = self.safe_rect_panel:h() * 0.65
	})

	panel:set_size(math.round(panel:w()), math.round(panel:h()))

	local title = self.safe_rect_panel:text({
		layer = 1,
		text = managers.localization:to_upper_text("menu_mods_installed_title"),
		font = self.medium_font,
		font_size = self.medium_font_size
	})

	self.make_fine_text(title)
	title:set_right(self.safe_rect_panel:right())
	self:create_gui_box(panel)
	panel:rect({
		name = "bg",
		alpha = 0.4,
		color = Color.black
	})
	panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur",
		render_template = "VertexColorTexturedBlur3D",
		layer = -1,
		w = panel:w(),
		h = panel:h()
	})

	self.mod_info_panel = panel:panel({})
	self._mod_main_panel = panel
end

function MenuModInfoGui:set_mod_info(item)
	self.mod_info_panel:clear()

	if alive(self._scroll_bar_panel) then
		self.safe_rect_panel:remove(self._scroll_bar_panel)
	end

	self._scroll_bar_panel = nil

	if self._scroll_up_box then
		self._scroll_up_box:close()

		self._scroll_up_box = nil
	end

	if self._scroll_down_box then
		self._scroll_down_box:close()

		self._scroll_down_box = nil
	end

	if self.safe_rect_panel:child("info_title") then
		self.safe_rect_panel:remove(self.safe_rect_panel:child("info_title"))
	end

	local params = item:parameters() or {}

	if params.back or params.pd2_corner then
		return
	end

	local mods = self.node:parameters().mods
	local modded_content = self.node:parameters().modded_content
	local mod_name = params.name
	local mod_data = mods and mods[mod_name]
	local conflicted_panel = self.mod_info_panel:panel({
		y = 10,
		name = "conflicted"
	})
	local modded_panel = self.mod_info_panel:panel({
		name = "modded"
	})
	local title = self.safe_rect_panel:text({
		name = "info_title",
		layer = 1,
		text = managers.localization:to_upper_text("menu_mods_info_title", {
			mod = mod_name
		}),
		font = self.medium_font,
		font_size = self.medium_font_size
	})

	self.make_fine_text(title)

	if mod_data then
		local text = conflicted_panel:text({
			y = 0,
			x = 10,
			layer = 1,
			text = managers.localization:to_upper_text("menu_mods_conflict_title"),
			font = self.medium_font,
			font_size = self.medium_font_size,
			w = conflicted_panel:w() - 20
		})
		local _, _, _, h = text:text_rect()

		text:set_h(h)

		local cy = h
		local conflict_text_title = text

		conflict_text_title:hide()

		local text = modded_panel:text({
			y = 0,
			x = 10,
			layer = 1,
			text = managers.localization:to_upper_text("menu_mods_modded_title"),
			font = self.medium_font,
			font_size = self.medium_font_size,
			w = conflicted_panel:w() - 20
		})
		local _, _, _, h = text:text_rect()

		text:set_h(h)

		local my = h
		local mod_text_title = text

		mod_text_title:hide()

		local conflicted_mods = {}

		for _, path in ipairs(mod_data.content) do
			if mod_data.conflicted[Idstring(path):key()] then
				for _, conflict_mod in ipairs(mod_data.conflicted[Idstring(path):key()]) do
					if conflict_mod ~= mod_name then
						conflicted_mods[conflict_mod] = conflicted_mods[conflict_mod] or {}

						table.insert(conflicted_mods[conflict_mod], path)
					end
				end

				conflict_text_title:show()
			else
				text = modded_panel:text({
					wrap = true,
					x = 20,
					layer = 1,
					text = path,
					font = self.small_font,
					font_size = self.small_font_size,
					y = my,
					w = modded_panel:w() - 30
				})
				_, _, _, h = text:text_rect()

				text:set_h(h)
				text:set_color(tweak_data.screen_colors.text)

				my = my + math.ceil(h)

				mod_text_title:show()
			end
		end

		local sorted_conflicts = {}

		for mod, conflicts in pairs(conflicted_mods) do
			table.insert(sorted_conflicts, mod)
		end

		table.sort(sorted_conflicts)

		for _, mod in ipairs(sorted_conflicts) do
			text = conflicted_panel:text({
				wrap = true,
				x = 20,
				layer = 1,
				text = utf8.to_upper(mod) .. ":",
				font = self.small_font,
				font_size = self.small_font_size,
				y = cy,
				w = conflicted_panel:w() - 30
			})
			_, _, _, h = text:text_rect()

			text:set_h(h)

			cy = cy + math.ceil(h)

			for _, path in ipairs(conflicted_mods[mod]) do
				text = conflicted_panel:text({
					wrap = true,
					x = 25,
					layer = 1,
					text = path,
					font = self.small_font,
					font_size = self.small_font_size,
					y = cy,
					w = conflicted_panel:w() - 35
				})
				_, _, _, h = text:text_rect()

				text:set_h(h)
				text:set_color(tweak_data.screen_colors.important_1)

				cy = cy + math.ceil(h)
			end

			cy = cy + 10
		end

		conflicted_panel:set_h(cy)
		modded_panel:set_y(conflict_text_title:visible() and conflicted_panel:bottom() or 10)
		modded_panel:set_h(my)
		self.mod_info_panel:set_y(0)
		self.mod_info_panel:set_h(modded_panel:bottom() + 10)

		if self._mod_main_panel:h() < self.mod_info_panel:h() then
			self._scroll_up_box = BoxGuiObject:new(self._mod_main_panel, {
				sides = {
					0,
					0,
					2,
					0
				}
			})
			self._scroll_down_box = BoxGuiObject:new(self._mod_main_panel, {
				sides = {
					0,
					0,
					0,
					2
				}
			})

			self._scroll_up_box:hide()
			self._scroll_down_box:show()

			self._scroll_bar_panel = self.safe_rect_panel:panel({
				w = 20,
				name = "scroll_bar_panel",
				h = self._mod_main_panel:h()
			})

			self._scroll_bar_panel:set_world_left(self._mod_main_panel:world_right())
			self._scroll_bar_panel:set_world_top(self._mod_main_panel:world_top())

			local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
			local scroll_up_indicator_arrow = self._scroll_bar_panel:bitmap({
				name = "scroll_up_indicator_arrow",
				layer = 2,
				blend_mode = "add",
				texture = texture,
				texture_rect = rect,
				color = Color.white
			})

			scroll_up_indicator_arrow:set_center_x(self._scroll_bar_panel:w() / 2)

			local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
			local scroll_down_indicator_arrow = self._scroll_bar_panel:bitmap({
				name = "scroll_down_indicator_arrow",
				layer = 2,
				blend_mode = "add",
				rotation = 180,
				texture = texture,
				texture_rect = rect,
				color = Color.white
			})

			scroll_down_indicator_arrow:set_bottom(self._scroll_bar_panel:h())
			scroll_down_indicator_arrow:set_center_x(self._scroll_bar_panel:w() / 2)

			local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()

			self._scroll_bar_panel:rect({
				alpha = 0.05,
				w = 4,
				color = Color.black,
				y = scroll_up_indicator_arrow:bottom(),
				h = bar_h
			}):set_center_x(self._scroll_bar_panel:w() / 2)

			bar_h = scroll_down_indicator_arrow:bottom() - scroll_up_indicator_arrow:top()
			local scroll_bar = self._scroll_bar_panel:panel({
				name = "scroll_bar",
				layer = 2,
				h = bar_h
			})
			local scroll_bar_box_panel = scroll_bar:panel({
				w = 4,
				name = "scroll_bar_box_panel",
				valign = "scale",
				halign = "scale"
			})
			self._scroll_bar_box_class = BoxGuiObject:new(scroll_bar_box_panel, {
				sides = {
					2,
					2,
					0,
					0
				}
			})

			self._scroll_bar_box_class:set_aligns("scale", "scale")
			self._scroll_bar_box_class:set_blend_mode("add")
			scroll_bar_box_panel:set_w(8)
			scroll_bar_box_panel:set_center_x(scroll_bar:w() / 2)
			scroll_bar:set_top(scroll_up_indicator_arrow:top())
			scroll_bar:set_center_x(scroll_up_indicator_arrow:center_x())
			self:set_scroll_indicators(0)
		end
	end
end

function MenuModInfoGui:check_pressed_scroll_bar(button, x, y)
	if alive(self._scroll_bar_panel) and self._scroll_bar_panel:visible() then
		local scroll_bar = self._scroll_bar_panel:child("scroll_bar")

		if button == Idstring("0") then
			if scroll_bar:inside(x, y) then
				self._grabbed_scroll_bar = true
				self._current_scroll_bar_y = y

				return true
			end

			if self._scroll_bar_panel:child("scroll_up_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_up_indicator_arrow"):inside(x, y) then
				self:set_scroll_indicators(self._scroll_y and self._scroll_y + 20)

				return true
			end

			if self._scroll_bar_panel:child("scroll_down_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_down_indicator_arrow"):inside(x, y) then
				self:set_scroll_indicators(self._scroll_y and self._scroll_y - 20)

				return true
			end
		elseif self._scroll_bar_panel:inside(x, y) or self._mod_main_panel:inside(x, y) then
			if button == Idstring("mouse wheel down") then
				self:previous_page()

				return true
			elseif button == Idstring("mouse wheel up") then
				self:next_page()

				return true
			end
		end
	end

	return false
end

function MenuModInfoGui:release_scroll_bar()
	if self._grabbed_scroll_bar then
		self._grabbed_scroll_bar = nil

		return true
	end

	return false
end

function MenuModInfoGui:moved_scroll_bar(x, y)
	if alive(self._scroll_bar_panel) then
		local scroll_bar = self._scroll_bar_panel:child("scroll_bar")

		if self._grabbed_scroll_bar then
			self._current_scroll_bar_y = self:scroll_with_bar(y, self._current_scroll_bar_y or 0)

			return true, "grab"
		elseif self._scroll_bar_panel:visible() and scroll_bar:inside(x, y) then
			return true, "hand"
		elseif self._scroll_bar_panel:child("scroll_up_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_up_indicator_arrow"):inside(x, y) then
			return true, "link"
		elseif self._scroll_bar_panel:child("scroll_down_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_down_indicator_arrow"):inside(x, y) then
			return true, "link"
		end
	end

	return false, "arrow"
end

function MenuModInfoGui:scroll_with_bar(target_y, current_y)
	if alive(self._scroll_bar_panel) then
		local diff = current_y - target_y

		if diff == 0 then
			return current_y
		end

		local scroll_diff = self._mod_main_panel:h() / self.mod_info_panel:h()

		self:set_scroll_indicators(self._scroll_y and self._scroll_y + diff / scroll_diff)

		return target_y
	end

	return current_y
end

function MenuModInfoGui:set_scroll_indicators(y)
	if alive(self._scroll_bar_panel) then
		self._scroll_y = math.clamp(y or 0, self._mod_main_panel:h() - self.mod_info_panel:h(), 0)

		self.mod_info_panel:set_y(self._scroll_y)

		local scroll_up_indicator_arrow = self._scroll_bar_panel:child("scroll_up_indicator_arrow")
		local scroll_down_indicator_arrow = self._scroll_bar_panel:child("scroll_down_indicator_arrow")
		local scroll_bar = self._scroll_bar_panel:child("scroll_bar")
		local bar_h = scroll_down_indicator_arrow:bottom() - scroll_up_indicator_arrow:top()
		local scroll_diff = self._mod_main_panel:h() / self.mod_info_panel:h()

		scroll_bar:set_h(bar_h * scroll_diff)
		scroll_bar:set_y(-self._scroll_y * scroll_diff)
		self._scroll_up_box:set_visible(self._scroll_y < 0)
		self._scroll_down_box:set_visible(self._mod_main_panel:h() < self.mod_info_panel:bottom())
		scroll_up_indicator_arrow:set_visible(self._scroll_y < 0)
		scroll_down_indicator_arrow:set_visible(self._mod_main_panel:h() < self.mod_info_panel:bottom())
		self._scroll_bar_panel:set_visible(self._mod_main_panel:h() < self.mod_info_panel:h())
	end
end

function MenuModInfoGui:highlight_item(item, mouse_over)
	MenuModInfoGui.super.highlight_item(self, item, mouse_over)
	self:set_mod_info(item)
end

function MenuModInfoGui:mouse_moved(o, x, y)
	local used, icon = MenuModInfoGui.super.mouse_moved(self, x, y)

	if not used then
		used, icon = self:moved_scroll_bar(x, y)
	end

	return used, icon
end

function MenuModInfoGui:mouse_pressed(button, x, y)
	local used = MenuModInfoGui.super.mouse_pressed(self, button, x, y)
	used = used or self:check_pressed_scroll_bar(button, x, y)

	return used
end

function MenuModInfoGui:mouse_released(button, x, y)
	MenuModInfoGui.super.mouse_pressed(self, button, x, y)
	self:release_scroll_bar()
end

function MenuModInfoGui:previous_page()
	if managers.menu:is_pc_controller() then
		self:set_scroll_indicators(self._scroll_y and self._scroll_y - 40)
	else
		self:set_scroll_indicators(self._scroll_y and self._scroll_y + 40)
	end
end

function MenuModInfoGui:next_page()
	if managers.menu:is_pc_controller() then
		self:set_scroll_indicators(self._scroll_y and self._scroll_y + 40)
	else
		self:set_scroll_indicators(self._scroll_y and self._scroll_y - 40)
	end
end

function MenuModInfoGui:update(t, dt)
	local cx, cy = managers.menu_component:get_right_controller_axis()

	if cy ~= 0 then
		self:set_scroll_indicators(self._scroll_y and self._scroll_y + cy * 500 * dt)
	end
end
