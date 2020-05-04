require("lib/managers/menu/renderers/MenuNodeBaseGui")

MenuNodePrePlanningGui = MenuNodePrePlanningGui or class(MenuNodeBaseGui)

function MenuNodePrePlanningGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.row_item_disabled_text_color = Color(1, 0.3, 0.3, 0.3)
	parameters.marker_alpha = 1
	parameters.to_upper = true
	parameters._align_line_proportions = 0.75
	parameters.height_padding = 10
	parameters.tooltip_height = node:parameters().tooltip_height or 265

	if node:parameters().name == "preplanning_type" or node:parameters().name == "preplanning_plan" then
		parameters.row_item_disabled_text_color = tweak_data.screen_colors.important_1
		self.marker_disabled_color = tweak_data.screen_colors.important_1:with_alpha(0.2)
	end

	MenuNodePrePlanningGui.super.init(self, node, layer, parameters)
end

function MenuNodePrePlanningGui:setup()
	MenuNodePrePlanningGui.super.setup(self)

	if managers.menu:is_pc_controller() then
		self:create_text_button({
			text_to_upper = true,
			text_id = "menu_back",
			right = self.safe_rect_panel:w() - 10,
			bottom = self.safe_rect_panel:h() - 10,
			font = self.large_font,
			font_size = self.large_font_size,
			clbk = callback(MenuCallbackHandler, MenuCallbackHandler, "menu_back")
		})
	end
end

function MenuNodePrePlanningGui:_setup_item_panel_parent(safe_rect, shape)
	local res = RenderSettings.resolution
	shape = shape or {}
	shape.x = shape.x or safe_rect.x
	shape.y = shape.y or safe_rect.y + 0
	shape.w = shape.w or safe_rect.width
	shape.h = shape.h or safe_rect.height - 0
	local x = shape.x
	local y = shape.y + 10
	local w = shape.w
	local h = shape.h - self.tooltip_height

	self._item_panel_parent:set_shape(x, y, w, h)
	self._align_data.panel:set_y(0)
	self._align_data.panel:set_h(self._item_panel_parent:h())
	self._list_arrows.up:hide()
	self._list_arrows.down:hide()
	self._legends_panel:set_right(self.ws:panel():right() - 10)
	self._legends_panel:set_bottom(self.ws:panel():bottom() - 5)
end

function MenuNodePrePlanningGui:_setup_item_panel(safe_rect, res)
	local extra = 14

	self.item_panel:set_shape(0, self.item_panel:y(), safe_rect.width * (1 - self._align_line_proportions) + extra, self:_item_panel_height())
	self.item_panel:set_right(self.item_panel:parent():w() - 20)
	self:_rec_round_object(self.item_panel)

	if alive(self.box_panel) then
		self.item_panel:parent():remove(self.box_panel)

		self.box_panel = nil
	end

	local box_h = math.min(self._item_panel_parent:h(), self.item_panel:h())
	self.box_panel = self.item_panel:parent():panel()

	self.box_panel:set_x(self.item_panel:x())
	self.box_panel:set_y(0)
	self.box_panel:set_w(self.item_panel:w())
	self.box_panel:set_h(box_h)
	self.box_panel:grow(20, 0)
	self.box_panel:move(-10, -0)
	self.box_panel:set_layer(self.layers.background)

	self.boxgui = BoxGuiObject:new(self.box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self.boxgui:set_clipping(false)
	self.boxgui:set_layer(self.layers.last)
	self.box_panel:rect({
		alpha = 0.3,
		rotation = 360,
		layer = -1,
		color = Color.black
	})
	self.box_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur",
		rotation = 360,
		render_template = "VertexColorTexturedBlur3D",
		layer = -2,
		w = self.box_panel:w(),
		h = self.box_panel:h()
	})

	if alive(self._icon_panel) then
		self._icon_panel:parent():remove(self._icon_panel)

		self._icon_panel = nil
	end

	self._icon_panel = self._item_panel_parent:panel({
		name = "icons"
	})

	self._align_data.panel:set_left(self.box_panel:left())
	self:_create_tooltip()
	self:_set_topic_position()

	if self._item_panel_parent:h() < self.item_panel:h() then
		self._list_arrows.up:set_visible(true)
		self._list_arrows.down:set_visible(true)
		self._list_arrows.up:set_color(self._list_arrows.up:color():with_alpha(0.5))
		self._list_arrows.up:set_w(self.box_panel:w())
		self._list_arrows.up:set_h(2)
		self._list_arrows.up:set_world_left(self._align_data.panel:world_left())
		self._list_arrows.up:set_world_top(self._align_data.panel:world_top())
		self._list_arrows.down:set_w(self.box_panel:w())
		self._list_arrows.down:set_h(2)
		self._list_arrows.down:set_world_left(self._align_data.panel:world_left())
		self._list_arrows.down:set_world_bottom(self._align_data.panel:world_bottom())
	end
end

function MenuNodePrePlanningGui:_set_topic_position()
	self._icon_panel:set_shape(self.item_panel:shape())
end

function MenuNodePrePlanningGui:scroll_update(dt)
	local scrolled = MenuNodePrePlanningGui.super.super.scroll_update(self, dt)
	local scroll_top = self.item_panel:top() < 0
	local scroll_bottom = self._item_panel_parent:h() < self.item_panel:bottom()

	self._list_arrows.up:set_visible(scroll_top)
	self._list_arrows.down:set_visible(scroll_bottom)

	if scroll_top or scroll_bottom then
		local top = self._item_panel_parent:world_top()
		local bottom = self._item_panel_parent:world_bottom()
		local row_item_top, row_item_bottom = nil

		for i, row_item in ipairs(self.row_items) do
			if row_item and row_item.gui_panel then
				row_item_top = row_item.gui_panel:world_top()
				row_item_bottom = row_item.gui_panel:world_bottom()

				if (row_item_top >= top or top >= row_item_bottom) and row_item_top < bottom and bottom < row_item_bottom then
					-- Nothing
				end
			end
		end
	end

	return scrolled
end

function MenuNodePrePlanningGui:_create_tooltip()
	if alive(self._tooltip) then
		self._tooltip:parent():remove(self._tooltip)

		self._tooltip = nil
	end

	self._tooltip = self.ws:panel():panel({
		layer = self.layers.items
	})

	self._tooltip:set_w(self.box_panel:w())
	self._tooltip:set_top(self.box_panel:bottom() + self._item_panel_parent:top() + 5)
	self._tooltip:set_left(self.box_panel:left())

	local title = self._tooltip:text({
		text = " ",
		name = "title",
		y = 10,
		x = 10,
		font = self.font,
		font_size = self.font_size,
		color = tweak_data.screen_colors.text
	})

	self.make_fine_text(title)

	local icon = self._tooltip:bitmap({
		name = "icon",
		h = 48,
		w = 48,
		texture = tweak_data.preplanning.gui.type_icons_path,
		texture_rect = {
			0,
			0,
			32,
			32
		}
	})

	icon:set_top(title:bottom() + 5)
	icon:set_left(title:left() + 5)

	local description = self._tooltip:text({
		word_wrap = true,
		name = "description",
		blend_mode = "add",
		wrap = true,
		text = " ",
		y = 10,
		x = 10,
		font = self.font,
		font_size = self.font_size,
		color = tweak_data.screen_colors.text
	})

	description:set_top(icon:top())
	description:set_left(icon:right() + 5)
	description:set_width(self._tooltip:w() - 10 - description:left())
	description:set_kern(description:kern())

	local x, y, w, h = description:text_rect()

	description:set_h(h)

	local error_text = self._tooltip:text({
		word_wrap = true,
		name = "error",
		blend_mode = "add",
		wrap = true,
		text = " ",
		y = 10,
		x = 10,
		font = self.font,
		font_size = self.font_size,
		color = tweak_data.screen_colors.important_1
	})

	error_text:set_top(description:bottom() + 5)
	error_text:set_left(icon:right() + 5)
	error_text:set_width(self._tooltip:w() - 10 - error_text:left())
	error_text:set_kern(error_text:kern())

	local x, y, w, h = error_text:text_rect()

	error_text:set_h(h)

	local bottom = math.max(title:bottom(), icon:bottom(), description:bottom(), error_text:bottom()) + 10

	self._tooltip:set_h(bottom)

	local boxgui = BoxGuiObject:new(self._tooltip, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	boxgui:set_clipping(false)
	boxgui:set_layer(1000)

	self._tooltip_boxgui = boxgui
	local bg = self._tooltip:rect({
		name = "bg",
		valign = "grow",
		halign = "grow",
		alpha = 0.3,
		rotation = 360,
		layer = -1,
		color = Color.black
	})
	local blur = self._tooltip:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur",
		halign = "grow",
		valign = "grow",
		render_template = "VertexColorTexturedBlur3D",
		layer = -2,
		w = self._tooltip:w(),
		h = self._tooltip:h()
	})
end

function MenuNodePrePlanningGui:_update_tooltip(item)
	if not item then
		if alive(self._tooltip) then
			self._tooltip:hide()
		end

		return
	end

	local row_item = self:row_item(item)

	if row_item and alive(self._tooltip) then
		local tooltip = item:parameters().tooltip

		if tooltip then
			local title = self._tooltip:child("title")
			local description = self._tooltip:child("description")
			local icon = self._tooltip:child("icon")
			local error_text = self._tooltip:child("error")

			title:set_text(tooltip.name)
			self.make_fine_text(title)

			local tx, ty, tw, th = nil

			if tooltip.texture_rect then
				tx, ty, tw, th = unpack(tooltip.texture_rect)

				icon:set_image(tooltip.texture, tx, ty, tw, th)
			else
				icon:set_image(tooltip.texture)
			end

			description:set_text(tooltip.desc)
			description:set_kern(description:kern())

			local x, y, w, h = description:text_rect()

			description:set_h(h)

			local text = ""

			if tooltip.errors and tooltip.errors[1] then
				text = text .. tooltip.errors[1]
			end

			error_text:set_top(description:bottom() + 5)
			error_text:set_text(text)
			error_text:set_kern(description:kern())

			local x, y, w, h = error_text:text_rect()

			error_text:set_h(h)

			local bottom = math.max(title:bottom(), icon:bottom(), description:bottom(), error_text:bottom()) + 10

			self._tooltip:set_h(bottom)
			self._tooltip_boxgui:create_sides(self._tooltip, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
			self._tooltip:show()
		else
			self._tooltip:hide()
		end
	end
end

function MenuNodePrePlanningGui:_align_marker(row_item)
	if self.marker_color then
		self._marker_data.gradient:set_color(row_item.item:enabled() and self.marker_color or self.marker_disabled_color or row_item.disabled_color)
	end

	self._marker_data.marker:show()
	self._marker_data.marker:set_width(self:_scaled_size().width - self._marker_data.marker:left())
	self._marker_data.marker:set_height(64 * row_item.gui_panel:height() / 32)
	self._marker_data.marker:set_center_y(row_item.gui_panel:center_y())
	self._marker_data.marker:set_world_right(self.item_panel:world_right())
	self._marker_data.gradient:show()
	self._marker_data.gradient:set_rotation(0)
	self._marker_data.gradient:set_width(self._marker_data.marker:width())
	self._marker_data.gradient:set_height(self._marker_data.marker:height())

	if self._marker_data.back_marker then
		self._marker_data.back_marker:set_visible(false)
	end
end

function MenuNodePrePlanningGui:_rec_round_object(object)
	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end

	local x, y = object:position()

	object:set_position(math.round(x), math.round(y))
end

function MenuNodePrePlanningGui:reload_item(item)
	MenuNodePrePlanningGui.super.reload_item(self, item)

	local row_item = self:row_item(item)

	if row_item and alive(row_item.gui_panel) then
		row_item.gui_panel:set_halign("right")
		row_item.gui_panel:set_right(self.item_panel:w())
	end
end

function MenuNodePrePlanningGui:highlight_item(item, mouse_over)
	MenuNodePrePlanningGui.super.highlight_item(self, item, mouse_over)
	managers.menu_component:set_preplanning_selected_element_item(item)
	self:_update_tooltip(item)

	if not managers.menu:is_pc_controller() then
		managers.menu_component:set_preplanning_map_position_to_item(item)
	end
end

function MenuNodePrePlanningGui:trigger_item(item)
	if item and item:enabled() then
		-- Nothing
	end
end

function MenuNodePrePlanningGui:_fade_row_item(row_item)
	MenuNodePrePlanningGui.super._fade_row_item(self, row_item)

	if row_item.icon then
		row_item.icon:set_left(-2)
	end
end

function MenuNodePrePlanningGui:_highlight_row_item(row_item, mouse_over)
	MenuNodePrePlanningGui.super._highlight_row_item(self, row_item, mouse_over)

	if row_item.icon then
		row_item.icon:set_left(-2)
	end
end

function MenuNodePrePlanningGui:refresh_gui(node)
	MenuNodePrePlanningGui.super.refresh_gui(self, node)
end

function MenuNodePrePlanningGui:_set_item_positions()
	MenuNodePrePlanningGui.super._set_item_positions(self)
	self._icon_panel:clear()

	local my_peer_id = managers.network:session():local_peer():id()
	local node_params = self.node:parameters()
	local item, icon, texture_rect, texture, texture_color, tooltip, reserved_data = nil

	for i, row_item in pairs(self.row_items) do
		item = row_item.item

		if item then
			tooltip = item:parameters().tooltip
			reserved_data = node_params.current_type and managers.preplanning:get_reserved_mission_element(item:name())

			if tooltip and (reserved_data or node_params.current_category) then
				texture = tooltip.texture
				texture_rect = tooltip.texture_rect
				texture_color = Color.white

				if row_item.gui_panel then
					local new_icon = self._icon_panel:bitmap({
						h = 24,
						w = 24,
						name = item:name(),
						texture = texture,
						texture_rect = texture_rect,
						color = texture_color,
						layer = self.layers.items
					})

					new_icon:set_world_right(row_item.gui_panel:world_left() - 2)
					new_icon:set_world_center_y(row_item.gui_panel:world_center_y())

					if reserved_data then
						if item:enabled() then
							row_item.hightlight_color = tweak_data.screen_colors.text
							row_item.row_item_color = tweak_data.screen_colors.text
							row_item.color = tweak_data.screen_colors.text

							row_item.gui_panel:set_color(row_item.color)
						end

						local peer_marker = self._icon_panel:rect({
							blend_mode = "add",
							alpha = 0.36,
							color = tooltip.menu_color or Color.white,
							layer = self.layers.marker
						})

						peer_marker:set_width(row_item.gui_panel:w() + new_icon:w())
						peer_marker:set_height(row_item.gui_panel:h())
						peer_marker:set_world_center_y(row_item.gui_panel:world_center_y())
						peer_marker:set_world_right(row_item.gui_panel:world_right())
					end
				end
			end

			local votes = item:parameters().votes

			if votes and row_item.gui_panel then
				local new_icon, prev_icon = nil
				local num_votes = 0

				for peer_id, voted in pairs(votes.players) do
					if voted then
						new_icon = self._icon_panel:bitmap({
							texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_voting",
							blend_mode = "add",
							texture_rect = {
								0,
								0,
								24,
								24
							},
							w = row_item.gui_panel:h(),
							h = row_item.gui_panel:h(),
							color = tweak_data.chat_colors[peer_id] or tweak_data.chat_colors[#tweak_data.chat_colors],
							layer = self.layers.items
						})

						new_icon:set_world_right(prev_icon and prev_icon:world_left() - 2 or row_item.gui_panel:world_right() - 2)
						new_icon:set_world_center_y(row_item.gui_panel:world_center_y())

						num_votes = num_votes + 1
						prev_icon = new_icon
					end
				end

				for i = 1, managers.criminals.MAX_NR_CRIMINALS - num_votes do
					new_icon = self._icon_panel:bitmap({
						texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_voting",
						blend_mode = "add",
						texture_rect = {
							32,
							0,
							24,
							24
						},
						w = row_item.gui_panel:h(),
						h = row_item.gui_panel:h(),
						layer = self.layers.items
					})

					new_icon:set_world_right(prev_icon and prev_icon:world_left() - 2 or row_item.gui_panel:world_right() - 2)
					new_icon:set_world_center_y(row_item.gui_panel:world_center_y())

					prev_icon = new_icon
				end
			end
		end
	end
end

function MenuNodePrePlanningGui:test_clbk(...)
	print(inspect({
		...
	}))
end

function MenuNodePrePlanningGui:mouse_moved(o, x, y)
	local used, icon = MenuNodePrePlanningGui.super.mouse_moved(self, o, x, y)

	return used, icon
end

function MenuNodePrePlanningGui:mouse_pressed(button, x, y)
	if button == Idstring("0") or button == Idstring("1") then
		for _, row_item in pairs(self.row_items) do
			if row_item.gui_panel and row_item.gui_panel:inside(x, y) and self._item_panel_parent:inside(x, y) and row_item.type ~= "divider" then
				managers.menu_component:set_preplanning_map_position_to_item(row_item.item)

				break
			end
		end
	end

	if MenuNodePrePlanningGui.super.mouse_pressed(self, button, x, y) then
		return true
	end
end

function MenuNodePrePlanningGui:mouse_released(button, x, y)
	if MenuNodePrePlanningGui.super.mouse_released(self, button, x, y) then
		return true
	end
end

function MenuNodePrePlanningGui:confirm_pressed()
	MenuNodePrePlanningGui.super.confirm_pressed(self)
end

function MenuNodePrePlanningGui:previous_page()
	MenuNodePrePlanningGui.super.previous_page(self)
end

function MenuNodePrePlanningGui:next_page()
	MenuNodePrePlanningGui.super.next_page(self)
end

function MenuNodePrePlanningGui:move_up()
	MenuNodePrePlanningGui.super.move_up(self)
end

function MenuNodePrePlanningGui:move_down()
	MenuNodePrePlanningGui.super.move_down(self)
end

function MenuNodePrePlanningGui:move_left()
	MenuNodePrePlanningGui.super.move_left(self)
end

function MenuNodePrePlanningGui:move_right()
	MenuNodePrePlanningGui.super.move_right(self)
end

function MenuNodePrePlanningGui:close()
	MenuNodePrePlanningGui.super.close(self)
end
