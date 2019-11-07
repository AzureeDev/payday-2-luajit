core:import("CoreMenuNodeGui")

MenuNodeGui = MenuNodeGui or class(CoreMenuNodeGui.NodeGui)

function MenuNodeGui:init(node, layer, parameters)
	local name = node:parameters().name
	local lang_mods = {
		[Idstring("german"):key()] = name == "kit" and 0.95 or name == "challenges_active" and 0.875 or name == "challenges_awarded" and 0.875 or 0.9,
		[Idstring("french"):key()] = name == "kit" and 0.975 or name == "challenges_active" and 0.874 or name == "challenges_awarded" and 0.874 or name == "upgrades_support" and 0.875 or 0.9,
		[Idstring("italian"):key()] = name == "kit" and 0.975 or name == "challenges_active" and 0.875 or name == "challenges_awarded" and 0.875 or 0.95,
		[Idstring("spanish"):key()] = name == "kit" and 1 or name == "challenges_active" and 0.84 or name == "challenges_awarded" and 0.84 or (name == "upgrades_assault" or name == "upgrades_sharpshooter" or name == "upgrades_support") and 0.975 or 0.925,
		[Idstring("english"):key()] = name == "challenges_active" and 0.925 or name == "challenges_awarded" and 0.925 or 1
	}
	local mod = lang_mods[SystemInfo:language():key()] or 1
	self._align_line_proportions = node:parameters().align_line_proportions or 0.65
	self._align_line_padding = 10 * tweak_data.scale.align_line_padding_multiplier
	self._use_info_rect = node:parameters().use_info_rect or node:parameters().use_info_rect == nil and true
	self._stencil_align = node:parameters().stencil_align or "right"
	self._stencil_align_percent = node:parameters().stencil_align_percent or 0
	self._stencil_image = node:parameters().stencil_image
	self._scene_state = node:parameters().scene_state
	self._no_menu_wrapper = true
	self._is_loadout = node:parameters().is_loadout
	self._align = node:parameters().align or "mid"
	self._bg_visible = node:parameters().hide_bg
	self._bg_visible = self._bg_visible == nil
	self._bg_area = node:parameters().area_bg
	self._bg_area = not self._bg_area and "full" or self._bg_area
	self.row_item_color = tweak_data.screen_colors.button_stage_3
	self.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	self.row_item_disabled_text_color = tweak_data.menu.default_disabled_text_color
	self.item_panel_h = node:parameters().item_panel_h

	MenuNodeGui.super.init(self, node, layer, parameters)

	if node:parameters().no_item_parent then
		self._item_panel_parent:set_visible(false)
	end
end

function MenuNodeGui:align_line_padding()
	return self._align_line_padding
end

function MenuNodeGui:_mid_align()
	local safe_rect = self:_scaled_size()

	return safe_rect.width * self._align_line_proportions
end

function MenuNodeGui:_right_align(align_line_proportions)
	local safe_rect = self:_scaled_size()

	return safe_rect.width * (align_line_proportions or self._align_line_proportions) + self._align_line_padding
end

function MenuNodeGui:_left_align(align_line_proportions)
	local safe_rect = self:_scaled_size()

	return safe_rect.width * (align_line_proportions or self._align_line_proportions) - self._align_line_padding
end

function MenuNodeGui:_world_right_align()
	local safe_rect = self:_scaled_size()

	return safe_rect.x + safe_rect.width * self._align_line_proportions + self._align_line_padding
end

function MenuNodeGui:_world_left_align()
	local safe_rect = self:_scaled_size()

	return safe_rect.x + safe_rect.width * self._align_line_proportions - self._align_line_padding
end

local mvector_tl = Vector3()
local mvector_tr = Vector3()
local mvector_bl = Vector3()
local mvector_br = Vector3()

function MenuNodeGui:_setup_panels(node)
	MenuNodeGui.super._setup_panels(self, node)

	local safe_rect_pixels = self:_scaled_size()
	local res = RenderSettings.resolution
	self._topic_panel2 = self.ws:panel():panel({
		visible = not self._no_menu_wrapper,
		x = safe_rect_pixels.x,
		y = safe_rect_pixels.y,
		w = safe_rect_pixels.width,
		h = tweak_data.load_level.upper_saferect_border
	})
	self._topic_line = self._topic_panel2:bitmap({
		texture = "guis/textures/headershadow",
		y = 0,
		layer = self.layers.items,
		color = Color.white,
		w = safe_rect_pixels.width - self:_mid_align()
	})
	self._topic_text2 = self._topic_panel2:text({
		vertical = "bottom",
		halign = "right",
		align = "right",
		y = 0,
		x = 0,
		valign = "bottom",
		text = node:parameters().topic_id and managers.localization:text(node:parameters().topic_id) or "Topic",
		w = safe_rect_pixels.width,
		font_size = tweak_data.menu.topic_font_size,
		font = self.font,
		color = self.row_item_color,
		layer = self.layers.items + 1
	})
	local _, _, w, h = self._topic_text2:text_rect()

	self._topic_text2:set_h(h)

	self._items_bottom_line = self._item_panel_parent:bitmap({
		texture = "guis/textures/headershadowdown",
		y = 0,
		visible = not self._no_menu_wrapper,
		layer = self.layers.items,
		color = Color.white,
		w = safe_rect_pixels.width - self:_mid_align()
	})

	self:_create_align(node)
	self:_create_marker(node)

	local w = 200
	local h = 20
	local base = 20
	local height = 15
	self._list_arrows = {}
	local aw = safe_rect_pixels.width - self:_mid_align()
	self._list_arrows.up = self.ws:panel():bitmap({
		texture = "guis/textures/pd2/shared_lines",
		y = 0,
		visible = false,
		wrap_mode = "wrap",
		x = self:_mid_align(),
		w = aw,
		layer = self.layers.items + 2
	})
	self._list_arrows.down = self.ws:panel():bitmap({
		texture = "guis/textures/pd2/shared_lines",
		y = 0,
		visible = false,
		wrap_mode = "wrap",
		x = self:_mid_align(),
		w = aw,
		layer = self.layers.items + 2
	})
	local x = math.random(1, 255)
	local y = math.random(0, math.round(self._list_arrows.up:texture_height() / 2 - 1)) * 2
	local w = aw
	local h = 2

	mvector3.set_static(mvector_tl, x, y, 0)
	mvector3.set_static(mvector_tr, x + w, y, 0)
	mvector3.set_static(mvector_bl, x, y + h, 0)
	mvector3.set_static(mvector_br, x + w, y + h, 0)
	self._list_arrows.up:set_texture_coordinates(mvector_tl, mvector_tr, mvector_bl, mvector_br)

	local x = math.random(1, 255)
	local y = math.random(0, math.round(self._list_arrows.down:texture_height() / 2 - 1)) * 2
	local w = aw
	local h = 2

	mvector3.set_static(mvector_tl, x, y, 0)
	mvector3.set_static(mvector_tr, x + w, y, 0)
	mvector3.set_static(mvector_bl, x, y + h, 0)
	mvector3.set_static(mvector_br, x + w, y + h, 0)
	self._list_arrows.down:set_texture_coordinates(mvector_tl, mvector_tr, mvector_bl, mvector_br)

	self._info_bg_rect = self.safe_rect_panel:rect({
		visible = false,
		x = 0,
		y = tweak_data.load_level.upper_saferect_border,
		w = safe_rect_pixels.width * 0.41,
		h = safe_rect_pixels.height - tweak_data.load_level.upper_saferect_border * 2,
		layer = self.layers.first,
		color = Color(0.5, 0, 0, 0)
	})

	self:_create_legends(node)

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.renderer:set_stencil_image(self._stencil_image)
		active_menu.renderer:set_stencil_align(self._stencil_align, self._stencil_align_percent)
		active_menu.renderer:set_bg_visible(self._bg_visible)
		active_menu.renderer:set_bg_area(self._bg_area)
	end

	if self._scene_state and managers.menu_scene then
		managers.menu_scene:set_scene_template(self._scene_state)
	end

	local mini_info = self.safe_rect_panel:panel({
		w = 0,
		h = 0,
		x = 0,
		y = 0
	})
	local mini_text = mini_info:text({
		halign = "top",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		text = "",
		y = 0,
		x = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = Color.white,
		layer = self.layers.items
	})

	mini_info:set_width((self._info_bg_rect:w() - tweak_data.menu.info_padding * 2) * 2)
	mini_text:set_width(mini_info:w())
	mini_info:set_height(100)
	mini_text:set_height(100)
	mini_info:set_top(self._info_bg_rect:bottom() + tweak_data.menu.info_padding)
	mini_text:set_top(0)
	mini_info:set_left(tweak_data.menu.info_padding)
	mini_text:set_left(0)

	self._mini_info_text = mini_text

	if node.mini_info then
		self:set_mini_info(node.mini_info)
	end
end

function MenuNodeGui:set_mini_info(text)
	self._mini_info_text:set_text(text)
end

function MenuNodeGui:_create_legends(node)
	local safe_rect_pixels = self:_scaled_size()
	local res = RenderSettings.resolution
	local visible = not managers.menu:is_pc_controller()
	local is_pc = managers.menu:is_pc_controller()

	if alive(self.ws:panel():child("legend_panel")) then
		self.ws:panel():remove(self.ws:panel():child("legend_panel"))
	end

	self._legends_panel = self.ws:panel():panel({
		name = "legend_panel",
		visible = visible,
		x = safe_rect_pixels.x,
		y = safe_rect_pixels.y,
		w = safe_rect_pixels.width,
		h = safe_rect_pixels.height
	})
	local t_text = ""
	local has_pc_legend = false
	local visible_callback_name, visible_callback = nil

	for i, legend in ipairs(node:legends()) do
		visible_callback_name = legend.visible_callback
		visible_callback = nil

		if visible_callback_name then
			visible_callback = callback(node.callback_handler, node.callback_handler, visible_callback_name)
		end

		if (not is_pc or legend.pc) and (not visible_callback or visible_callback(self)) then
			has_pc_legend = has_pc_legend or legend.pc
			local spacing = i > 1 and "  |  " or ""
			t_text = t_text .. spacing .. utf8.to_upper(managers.localization:text(legend.string_id, {
				BTN_UPDATE = managers.localization:btn_macro("menu_update"),
				BTN_BACK = managers.localization:btn_macro("back")
			}))
		end
	end

	if is_pc then
		self._legends_panel:set_visible(has_pc_legend)
	end

	local text = self._legends_panel:text({
		text = t_text,
		font = self.legends_font or self.font,
		font_size = self.legends_font_size or self.font_size,
		color = self.color,
		layer = self.layers.items
	})
	local _, _, w, h = text:text_rect()

	text:set_size(w, h)
	self:_layout_legends()
end

function MenuNodeGui:_create_align(node)
	self._align_data = {
		panel = self._item_panel_parent:panel({
			y = 0,
			x = self:_left_align(),
			w = self._align_line_padding * 2,
			h = self._item_panel_parent:h(),
			layer = self.layers.marker
		})
	}
end

function MenuNodeGui:_create_marker(node)
	self._marker_data = {}
	local width, _ = managers.gui_data:get_base_res()
	local height = 10
	self._marker_data.marker = self.item_panel:panel({
		y = 0,
		x = 0,
		w = width,
		h = height,
		layer = self.layers.marker
	})
	self._marker_data.gradient = self._marker_data.marker:bitmap({
		texture = "guis/textures/menu_selected",
		blend_mode = "add",
		y = 0,
		x = 0,
		layer = 0,
		alpha = self.marker_alpha or 0.6
	})

	if self.marker_color then
		self._marker_data.gradient:set_color(self.marker_color)
	end
end

function MenuNodeGui:_setup_item_panel_parent(safe_rect, shape)
	local res = RenderSettings.resolution
	shape = shape or {}
	local x = shape.x or safe_rect.x
	local y = shape.y or safe_rect.y + CoreMenuRenderer.Renderer.border_height
	local w = shape.w or safe_rect.width
	local h = shape.h or self.item_panel_h or safe_rect.height - CoreMenuRenderer.Renderer.border_height * 2

	self._item_panel_parent:set_shape(x, y, w, h)
	self._align_data.panel:set_h(self._item_panel_parent:h())
	self._list_arrows.up:set_h(2)
	self._list_arrows.up:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.up:set_world_top(self._align_data.panel:world_top())
	self._list_arrows.down:set_h(2)
	self._list_arrows.down:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.down:set_world_bottom(self._align_data.panel:world_bottom())
	self._legends_panel:set_bottom(self.ws:panel():bottom())
	self._item_panel_parent:set_y(self._item_panel_parent:y() + 0 * tweak_data.scale.menu_arrow_padding_multiplier + (self._is_loadout and 300 or 0))
	self._item_panel_parent:set_h(self._item_panel_parent:h() - 0 * tweak_data.scale.menu_arrow_padding_multiplier)
end

function MenuNodeGui:_setup_item_panel(safe_rect, res)
	if self._align == "mid" and false then
		self._item_panel_y = self._item_panel_y or {
			first = self._item_panel_parent:h() / 2,
			current = self._item_panel_parent:h() / 2
		}

		if self:_item_panel_height() < self._item_panel_parent:h() then
			self._item_panel_y.target = self._item_panel_parent:h() / 2
		end

		self.item_panel:set_shape(0, self.item_panel:y(), safe_rect.width, self:_item_panel_height())

		if not self._item_panel_y then
			self.item_panel:set_center_y(self._item_panel_parent:h() / 2)
		elseif self._item_panel_y.first then
			self.item_panel:set_center_y(self._item_panel_parent:h() / 2)

			self._item_panel_y.first = nil
		end
	else
		local y = self:_item_panel_height() < self._item_panel_parent:h() and 0 or self.item_panel:y()

		self.item_panel:set_shape(0, y, safe_rect.width, self:_item_panel_height())
	end

	self.item_panel:set_w(safe_rect.width)
	self:_set_topic_position()

	if self._item_panel_parent:h() < self.item_panel:h() then
		self._list_arrows.up:set_visible(true)
		self._list_arrows.down:set_visible(true)
		self._list_arrows.up:set_color(self._list_arrows.up:color():with_alpha(0.5))
	end
end

function MenuNodeGui:_set_topic_position()
	self._topic_panel2:set_right(self.item_panel:right())

	local bottom = self.item_panel:top() + self._item_panel_parent:y()

	if bottom < self._item_panel_parent:y() then
		bottom = self._item_panel_parent:y() or bottom
	end

	self._topic_panel2:set_bottom(bottom)
	self._topic_text2:set_rightbottom(self._topic_panel2:size())
	self._topic_line:set_rightbottom(self._topic_panel2:size())
	self._items_bottom_line:set_y(self.item_panel:bottom())
	self._items_bottom_line:set_right(self.item_panel:right())
end

function MenuNodeGui:_create_menu_item(row_item)
	local safe_rect = self:_scaled_size()
	local align_x = safe_rect.width * self._align_line_proportions

	if row_item.gui_panel then
		self.item_panel:remove(row_item.gui_panel)
	end

	if alive(row_item.gui_pd2_panel) then
		row_item.gui_pd2_panel:parent():remove(row_item.gui_pd2_panel)
	end

	if row_item.item:parameters().back then
		row_item.item:parameters().back = false
		row_item.item:parameters().pd2_corner = true
	end

	if row_item.item:parameters().gui_node_custom then
		self:gui_node_custom(row_item)
	elseif row_item.item:parameters().back then
		row_item.gui_panel = self._item_panel_parent:panel({
			w = 30,
			h = 30,
			layer = self.layers.items
		})
		row_item.unselected = row_item.gui_panel:bitmap({
			texture = "guis/textures/menu_unselected",
			y = 0,
			visible = false,
			x = 0,
			layer = -1,
			h = row_item.gui_panel:h(),
			w = row_item.gui_panel:w()
		})
		row_item.selected = row_item.gui_panel:bitmap({
			texture = "guis/textures/menu_selected",
			y = 0,
			visible = false,
			x = 0,
			layer = 0,
			h = row_item.gui_panel:h(),
			w = row_item.gui_panel:w()
		})
		row_item.shadow = row_item.gui_panel:bitmap({
			texture = "guis/textures/headershadowdown",
			visible = false,
			layer = self.layers.items
		})
		row_item.shadow_bottom = row_item.gui_panel:bitmap({
			texture = "guis/textures/headershadowdown",
			rotation = 180,
			visible = false,
			layer = self.layers.items
		})
		row_item.arrow_selected = row_item.gui_panel:bitmap({
			texture = "guis/textures/menu_arrows",
			y = 0,
			blend_mode = "add",
			visible = false,
			x = 0,
			texture_rect = {
				0,
				0,
				24,
				24
			},
			h = row_item.gui_panel:w(),
			w = row_item.gui_panel:w(),
			layer = self.layers.items
		})
		row_item.arrow_unselected = row_item.gui_panel:bitmap({
			texture = "guis/textures/menu_arrows",
			y = 0,
			blend_mode = "add",
			visible = true,
			x = 0,
			texture_rect = {
				24,
				0,
				24,
				24
			},
			h = row_item.gui_panel:w(),
			w = row_item.gui_panel:w(),
			layer = self.layers.items
		})
	elseif row_item.item:parameters().pd2_corner then
		row_item.gui_panel = self._item_panel_parent:panel({
			w = 3,
			h = 3,
			layer = self.layers.items
		})
		row_item.gui_pd2_panel = self.ws:panel():panel({
			layer = self.layers.items
		})
		local row_item_panel = managers.menu:is_pc_controller() and row_item.gui_pd2_panel or row_item.gui_panel
		row_item.gui_text = row_item_panel:text({
			blend_mode = "add",
			vertical = "bottom",
			align = "right",
			y = 0,
			x = 0,
			layer = 0,
			font_size = tweak_data.menu.pd2_large_font_size * (row_item.item:parameters().scale or 1),
			font = tweak_data.menu.pd2_large_font,
			color = tweak_data.screen_colors.button_stage_3,
			text = utf8.to_upper(row_item.text),
			render_template = Idstring("VertexColorTextured")
		})
		local _, _, w, h = row_item.gui_text:text_rect()

		row_item.gui_text:set_size(math.round(w), math.round(h))

		if managers.menu:is_pc_controller() then
			local x = row_item.gui_pd2_panel:w()
			local y = row_item.gui_pd2_panel:h()
			local item = self.corner_items[table.size(self.corner_items)]

			if item and alive(item.gui_text) then
				x = x - item.gui_text:w() - 30
			end

			row_item.gui_text:set_rightbottom(x, y)
		else
			row_item.gui_text:set_rotation(360)
			row_item.gui_text:set_right(row_item.gui_pd2_panel:w())

			local item = self.corner_items[table.size(self.corner_items)]

			if item and alive(item.gui_text) then
				row_item.gui_text:set_top(item.gui_text:bottom())
			end
		end

		if MenuBackdropGUI and managers.menu:is_pc_controller() and not row_item.item:parameters().no_bg_text then
			local bg_text = row_item.gui_pd2_panel:text({
				vertical = "bottom",
				h = 90,
				alpha = 0.4,
				align = "right",
				rotation = 360,
				layer = -1,
				text = utf8.to_upper(row_item.text),
				font_size = tweak_data.menu.pd2_massive_font_size,
				font = tweak_data.menu.pd2_massive_font,
				color = tweak_data.screen_colors.button_stage_3
			})

			bg_text:set_right(row_item.gui_text:right())
			bg_text:set_center_y(row_item.gui_text:center_y())
			bg_text:move(13, -9)
			MenuBackdropGUI.animate_bg_text(self, bg_text)
		end

		if not table.contains(self.corner_items, row_item) then
			table.insert(self.corner_items, row_item)
		end
	elseif row_item.type == "level" then
		row_item.gui_panel = self:_text_item_part(row_item, self.item_panel, self:_right_align())

		row_item.gui_panel:set_text(utf8.to_upper(row_item.gui_panel:text()))

		row_item.gui_level_panel = self._item_panel_parent:panel({
			y = 0,
			visible = false,
			x = 0,
			layer = self.layers.items,
			w = self:_left_align(),
			h = self._item_panel_parent:h()
		})
		local level_data = row_item.item:parameters().level_id
		level_data = tweak_data.levels[level_data]
		local description = level_data and level_data.briefing_id and managers.localization:text(level_data.briefing_id) or "Missing description text"
		local image = level_data and level_data.loading_image or "guis/textures/menu/missing_level"
		row_item.level_title = row_item.gui_level_panel:text({
			word_wrap = false,
			vertical = "top",
			h = 128,
			wrap = false,
			align = "left",
			w = 50,
			layer = 1,
			text = utf8.to_upper(row_item.gui_panel:text()),
			font = self.font,
			font_size = self.font_size,
			color = row_item.color
		})
		row_item.level_text = row_item.gui_level_panel:text({
			word_wrap = true,
			vertical = "top",
			h = 128,
			wrap = true,
			align = "left",
			w = 50,
			layer = 1,
			text = utf8.to_upper(description),
			font = tweak_data.menu.small_font,
			font_size = tweak_data.menu.small_font_size,
			color = row_item.color
		})

		self:_align_normal(row_item)
	elseif row_item.type == "chat" then
		row_item.gui_panel = self.item_panel:panel({
			h = 100,
			w = self.item_panel:w()
		})
		row_item.chat_output = row_item.gui_panel:gui(Idstring("guis/chat/textscroll"), {
			valign = "grow",
			h = 120,
			halign = "grow",
			w = 500,
			layer = self.layers.items
		})
		row_item.chat_input = row_item.gui_panel:gui(Idstring("guis/chat/chat_input"), {
			valign = "bottom",
			y = 125,
			h = 25,
			halign = "grow",
			w = 500,
			layer = self.layers.items
		})
		row_item.chat_input:script().enter_callback = callback(self, self, "_cb_chat", row_item)
		row_item.chat_input:script().esc_callback = callback(self, self, "_cb_unlock", row_item)
		row_item.chat_input:script().typing_callback = callback(self, self, "_cb_lock", row_item)
		row_item.border = row_item.gui_panel:rect({
			h = 2,
			visible = false,
			w = 800,
			layer = self.layers.items,
			color = tweak_data.hud.prime_color
		})

		self:_align_chat(row_item)
	elseif row_item.type == "friend" then
		local cot_align = row_item.align == "right" and "left" or row_item.align == "left" and "right" or row_item.align
		row_item.gui_panel = self.item_panel:panel({
			w = self.item_panel:w()
		})
		row_item.color_mod = (row_item.item:parameters().signin_status == "uninvitable" or row_item.item:parameters().signin_status == "not_signed_in") and 0.75 or 1
		row_item.friend_name = self:_text_item_part(row_item, row_item.gui_panel, self:_right_align())

		row_item.friend_name:set_color(row_item.friend_name:color() * row_item.color_mod)

		row_item.signin_status = self:_text_item_part(row_item, row_item.gui_panel, self:_left_align())

		row_item.signin_status:set_align(cot_align)
		row_item.signin_status:set_color(row_item.signin_status:color() * row_item.color_mod)

		local status_text = managers.localization:text("menu_friends_" .. row_item.item:parameters().signin_status)

		row_item.signin_status:set_text(utf8.to_upper(status_text))
		self:_align_friend(row_item)
	elseif not row_item.item:setup_gui(self, row_item) then
		local cot_align = row_item.align == "right" and "left" or row_item.align == "left" and "right" or row_item.align
		row_item.gui_panel = self:_text_item_part(row_item, self.item_panel, self:_right_align() + (row_item.is_expanded and 20 or 0))
		row_item.current_of_total = self:_text_item_part(row_item, self.item_panel, self:_right_align(), cot_align)

		row_item.current_of_total:set_font_size(20)
		row_item.current_of_total:set_visible(false)

		if row_item.item:parameters().current then
			row_item.current_of_total:set_visible(true)
			row_item.current_of_total:set_color(row_item.color)
			row_item.current_of_total:set_text("(" .. row_item.item:parameters().current .. "/" .. row_item.item:parameters().total .. ")")
		end

		if row_item.help_text then
			-- Nothing
		end

		if row_item.item:parameters().trial_buy then
			self:_setup_trial_buy(row_item)
		end

		if row_item.item:parameters().fake_disabled then
			self:_setup_fake_disabled(row_item)
		end

		if row_item.item:parameters().icon then
			row_item.icon = self.item_panel:bitmap({
				texture = row_item.item:parameters().icon,
				rotation = row_item.item:parameters().icon_rotation or 360,
				visible = row_item.item:icon_visible(),
				layer = self.layers.items + 1
			})
		end

		self:_align_normal(row_item)
	end

	local visible = row_item.item:menu_unselected_visible(self, row_item) and not row_item.item:parameters().back
	row_item.menu_unselected = self.item_panel:bitmap({
		texture = "guis/textures/menu_unselected",
		y = 0,
		visible = false,
		x = 0,
		layer = self.layers.items - 2
	})

	row_item.menu_unselected:set_color(row_item.item:parameters().is_expanded and Color(0.5, 0.5, 0.5) or Color.white)
end

function MenuNodeGui:_setup_trial_buy(row_item)
	row_item.row_item_color = Color(1, 1, 0.6588235294117647, 0)

	row_item.gui_panel:set_color(row_item.row_item_color)
end

function MenuNodeGui:_setup_fake_disabled(row_item)
	row_item.row_item_color = row_item.disabled_color

	row_item.gui_panel:set_color(row_item.row_item_color)
end

function MenuNodeGui:_create_info_panel(row_item)
	row_item.gui_info_panel = self.safe_rect_panel:panel({
		y = 0,
		visible = false,
		x = 0,
		layer = self.layers.first,
		w = self:_left_align(),
		h = self._item_panel_parent:h()
	})
	row_item.help_title = row_item.gui_info_panel:text({
		halign = "top",
		vertical = "top",
		align = "left",
		y = 0,
		x = 0,
		font_size = self.font_size,
		font = row_item.font,
		color = Color.white,
		layer = self.layers.items,
		text = utf8.to_upper(row_item.text)
	})
	row_item.help_text = row_item.gui_info_panel:text({
		halign = "top",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		y = 0,
		x = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = Color.white,
		layer = self.layers.items,
		text = utf8.to_upper(row_item.help_text)
	})
end

function MenuNodeGui:_set_lobby_campaign(row_item)
	if not MenuNodeGui.lobby_campaign then
		self:_create_lobby_campaign(row_item)
	else
		row_item.level_id = MenuNodeGui.lobby_campaign.level_id
		row_item.gui_info_panel = MenuNodeGui.lobby_campaign.gui_info_panel
		row_item.level_title = MenuNodeGui.lobby_campaign.level_title
		row_item.level_briefing = MenuNodeGui.lobby_campaign.level_briefing
	end
end

function MenuNodeGui:_create_lobby_campaign(row_item)
	row_item.gui_info_panel = self.safe_rect_panel:panel({
		y = 0,
		visible = false,
		x = 0,
		layer = self.layers.items,
		w = self:_left_align(),
		h = self._item_panel_parent:h()
	})
	row_item.level_id = Global.game_settings.level_id
	row_item.level_title = row_item.gui_info_panel:text({
		halign = "top",
		vertical = "top",
		align = "left",
		y = 0,
		x = 0,
		font_size = self.font_size,
		font = row_item.font,
		color = Color.white,
		layer = self.layers.items,
		text = string.upper(managers.localization:text(tweak_data.levels[row_item.level_id].name_id))
	})
	local briefing_text = string.upper(managers.localization:text(tweak_data.levels[row_item.level_id].briefing_id))
	row_item.level_briefing = row_item.gui_info_panel:text({
		halign = "top",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		y = 0,
		x = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = Color.white,
		layer = self.layers.items,
		text = briefing_text
	})
	MenuNodeGui.lobby_campaign = {
		level_id = Global.game_settings.level_id,
		gui_info_panel = row_item.gui_info_panel,
		level_movie = row_item.level_movie,
		level_title = row_item.level_title,
		level_briefing = row_item.level_briefing
	}
end

function MenuNodeGui:_align_lobby_campaign(row_item)
	self:_align_item_gui_info_panel(row_item.gui_info_panel)

	local w = row_item.gui_info_panel:w()
	local _, _, _, h = row_item.level_title:text_rect()

	row_item.level_title:set_size(w, h)
	row_item.level_title:set_position(0, (row_item.level_movie and row_item.level_movie:bottom() or 0) + tweak_data.menu.info_padding)
	row_item.level_briefing:set_w(w)
	row_item.level_briefing:set_shape(row_item.level_briefing:text_rect())
	row_item.level_briefing:set_x(0)
	row_item.level_briefing:set_top(row_item.level_title:bottom() + tweak_data.menu.info_padding)
end

function MenuNodeGui:_highlight_lobby_campaign(row_item)
	if row_item.level_id ~= Global.game_settings.level_id then
		self:_reload_lobby_campaign(row_item)
	end

	row_item.gui_info_panel:set_visible(true)
end

function MenuNodeGui:_fade_lobby_campaign(row_item)
	row_item.gui_info_panel:set_visible(false)
end

function MenuNodeGui:_reload_lobby_campaign(row_item)
	if MenuNodeGui.lobby_campaign.level_id == Global.game_settings.level_id then
		return
	end

	if row_item.level_id ~= MenuNodeGui.lobby_campaign.level_id then
		row_item.level_id = MenuNodeGui.lobby_campaign.level_id
		row_item.gui_info_panel = MenuNodeGui.lobby_campaign.gui_info_panel
		row_item.level_title = MenuNodeGui.lobby_campaign.level_title
		row_item.level_briefing = MenuNodeGui.lobby_campaign.level_briefing

		return
	end

	row_item.level_id = Global.game_settings.level_id
	local text = string.upper(managers.localization:text(tweak_data.levels[row_item.level_id].name_id))

	row_item.level_title:set_text(text)

	local briefing_text = string.upper(managers.localization:text(tweak_data.levels[row_item.level_id].briefing_id))

	row_item.level_briefing:set_text(briefing_text)

	local _, _, _, h = row_item.level_briefing:text_rect()

	row_item.level_briefing:set_h(h)

	MenuNodeGui.lobby_campaign = {
		level_id = Global.game_settings.level_id,
		gui_info_panel = row_item.gui_info_panel,
		level_movie = row_item.level_movie,
		level_title = row_item.level_title,
		level_briefing = row_item.level_briefing
	}
end

function MenuNodeGui:_create_lobby_difficulty(row_item)
	row_item.gui_info_panel = self.safe_rect_panel:panel({
		y = 0,
		visible = false,
		x = 0,
		layer = self.layers.items,
		w = self:_left_align(),
		h = self._item_panel_parent:h()
	})
	row_item.difficulty_title = row_item.gui_info_panel:text({
		halign = "top",
		vertical = "top",
		align = "left",
		y = 0,
		x = 0,
		font_size = self.font_size,
		font = row_item.font,
		color = Color.white,
		layer = self.layers.items,
		text = utf8.to_upper(row_item.text)
	})
	row_item.help_text = row_item.gui_info_panel:text({
		halign = "top",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		y = 0,
		x = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = Color.white,
		layer = self.layers.items,
		text = utf8.to_upper(managers.localization:text("menu_difficulty_help"))
	})
	row_item.difficulty_help_text = row_item.gui_info_panel:text({
		halign = "top",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		y = 0,
		x = 0,
		font = tweak_data.menu.small_font,
		font_size = tweak_data.menu.small_font_size,
		color = Color.white,
		layer = self.layers.items,
		text = ut8f.to_upper("sdsd")
	})
end

function MenuNodeGui:_align_lobby_difficulty(row_item)
	local w = row_item.gui_info_panel:w()

	row_item.difficulty_title:set_shape(row_item.difficulty_title:text_rect())
	row_item.difficulty_title:set_position(0, 0)
	row_item.help_text:set_w(w)
	row_item.help_text:set_shape(row_item.help_text:text_rect())
	row_item.help_text:set_x(0)
	row_item.help_text:set_top(row_item.difficulty_title:bottom() + tweak_data.menu.info_padding)
	self:_align_lobby_difficulty_help_text(row_item)
end

function MenuNodeGui:_align_lobby_difficulty_help_text(row_item)
	local w = row_item.gui_info_panel:w()

	row_item.difficulty_help_text:set_w(w)

	local _, _, tw, th = row_item.difficulty_help_text:text_rect()

	row_item.difficulty_help_text:set_h(th)
	row_item.difficulty_help_text:set_x(0)
	row_item.difficulty_help_text:set_top(row_item.help_text:bottom() + tweak_data.menu.info_padding * 2)
end

function MenuNodeGui:_highlight_lobby_difficulty(row_item)
	row_item.gui_info_panel:set_visible(true)
end

function MenuNodeGui:_fade_lobby_difficulty(row_item)
	row_item.gui_info_panel:set_visible(false)
end

function MenuNodeGui:_reload_lobby_difficulty(row_item)
	row_item.difficulty_help_text:set_text(utf8.to_upper(managers.localization:text("menu_difficulty_" .. Global.game_settings.difficulty .. "_help")))
	self:_align_lobby_difficulty_help_text(row_item)
end

function MenuNodeGui:_align_friend(row_item)
	local safe_rect = self:_scaled_size()

	row_item.friend_name:set_font_size(self.font_size)

	local x, y, w, h = row_item.friend_name:text_rect()

	row_item.friend_name:set_height(h)
	row_item.friend_name:set_right(row_item.friend_name:parent():w())
	row_item.gui_panel:set_height(h)

	if row_item.icon then
		row_item.icon:set_left(row_item.gui_panel:right())
		row_item.icon:set_center_y(row_item.gui_panel:center_y())
		row_item.icon:set_color(row_item.gui_panel:color())
	end

	row_item.signin_status:set_font_size(self.font_size)
	row_item.signin_status:set_height(h)

	if row_item.align == "right" then
		row_item.signin_status:set_left(self:_right_align() - row_item.gui_panel:x() - 100)
	elseif row_item.align == "left" then
		row_item.signin_status:set_right(self:_left_align())
	else
		row_item.signin_status:set_right(self:_left_align())
	end
end

function MenuNodeGui:activate_customize_controller(item)
	local row_item = self:row_item(item)

	self.ws:connect_keyboard(Input:keyboard())
	self.ws:connect_mouse(Input:mouse())

	self._listening_to_input = true
	self._skip_first_activate_key = true

	local function f(o, key)
		self:_key_press(o, key, "keyboard", item)
	end

	row_item.controller_binding:set_text("_")
	row_item.controller_binding:key_release(f)

	local function f(o, key)
		self:_key_press(o, key, "mouse", item)
	end

	row_item.controller_binding:mouse_click(f)

	local function f(index, key)
		self:_key_press(row_item.controller_binding, key, "mouse", item, true)
	end

	self._mouse_wheel_up_trigger = Input:mouse():add_trigger(Input:mouse():button_index(Idstring("mouse wheel up")), f)
	self._mouse_wheel_down_trigger = Input:mouse():add_trigger(Input:mouse():button_index(Idstring("mouse wheel down")), f)
end

function MenuNodeGui:_key_press(o, key, input_id, item, no_add)
	if managers.system_menu:is_active() then
		return
	end

	if self._skip_first_activate_key then
		self._skip_first_activate_key = false

		if input_id == "mouse" then
			if key == Idstring("0") then
				return
			end
		elseif input_id == "keyboard" and key == Idstring("enter") then
			return
		end
	end

	local row_item = self:row_item(item)

	if key == Idstring("esc") then
		self:_end_customize_controller(o, item)

		return
	end

	local key_name = "" .. (input_id == "mouse" and Input:mouse():button_name_str(key) or Input:keyboard():button_name_str(key))

	if not no_add and input_id == "mouse" then
		key_name = "mouse " .. key_name or key_name
	end

	local forbidden_btns = {
		"esc",
		"tab",
		"num abnt c1",
		"num abnt c2",
		"@",
		"ax",
		"convert",
		"kana",
		"kanji",
		"no convert",
		"oem 102",
		"stop",
		"unlabeled",
		"yen",
		"mouse 8",
		"mouse 9",
		""
	}

	for _, btn in ipairs(forbidden_btns) do
		if Idstring(btn) == key then
			managers.menu:show_key_binding_forbidden({
				KEY = key_name
			})
			self:_end_customize_controller(o, item)

			return
		end
	end

	local button_category = MenuCustomizeControllerCreator.CONTROLS_INFO[item:parameters().button].category
	local connections = managers.controller:get_settings(managers.controller:get_default_wrapper_type()):get_connection_map()

	for _, name in ipairs(MenuCustomizeControllerCreator.controls_info_by_category(button_category)) do
		local connection = connections[name]

		if connection._btn_connections then
			for name, btn_connection in pairs(connection._btn_connections) do
				if btn_connection.name == key_name and item:parameters().binding ~= btn_connection.name then
					managers.menu:show_key_binding_collision({
						KEY = key_name,
						MAPPED = managers.localization:text(MenuCustomizeControllerCreator.CONTROLS_INFO[name].text_id)
					})
					self:_end_customize_controller(o, item)

					return
				end
			end
		else
			for _, b_name in ipairs(connection:get_input_name_list()) do
				if tostring(b_name) == key_name and item:parameters().binding ~= b_name then
					managers.menu:show_key_binding_collision({
						KEY = key_name,
						MAPPED = managers.localization:text(MenuCustomizeControllerCreator.CONTROLS_INFO[name].text_id)
					})
					self:_end_customize_controller(o, item)

					return
				end
			end
		end
	end

	if item:parameters().axis then
		connections[item:parameters().axis]._btn_connections[item:parameters().button].name = key_name

		managers.controller:set_user_mod(item:parameters().connection_name, {
			axis = item:parameters().axis,
			button = item:parameters().button,
			connection = key_name
		})

		item:parameters().binding = key_name
	else
		connections[item:parameters().button]:set_controller_id(input_id)
		connections[item:parameters().button]:set_input_name_list({
			key_name
		})
		managers.controller:set_user_mod(item:parameters().connection_name, {
			button = item:parameters().button,
			connection = key_name,
			controller_id = input_id
		})

		item:parameters().binding = key_name
	end

	managers.controller:rebind_connections()
	self:_end_customize_controller(o, item)
end

function MenuNodeGui:_end_customize_controller(o, item)
	self.ws:disconnect_keyboard()
	self.ws:disconnect_mouse()
	o:key_press(nil)
	o:key_release(nil)
	o:mouse_click(nil)
	o:mouse_release(nil)
	Input:mouse():remove_trigger(self._mouse_wheel_up_trigger)
	Input:mouse():remove_trigger(self._mouse_wheel_down_trigger)
	setup:add_end_frame_clbk(function ()
		self._listening_to_input = false
	end)
	item:dirty()
end

function MenuNodeGui:_cb_chat(row_item)
	local chat_text = row_item.chat_input:child("text"):text()

	if chat_text and tostring(chat_text) ~= "" then
		local name = managers.network:session():local_peer():name()
		local say = name .. ": " .. tostring(chat_text)

		self:_say(say, row_item, managers.network:session():local_peer():id())
		managers.network:session():send_to_peers("sync_chat_message", say)
	end

	self._chatbox_typing = false

	row_item.chat_input:child("text"):set_text("")
	row_item.chat_input:child("text"):set_selection(0, 0)
end

function MenuNodeGui:sync_say(message, row_item, id)
	self:_say(message, row_item, id)
end

function MenuNodeGui:_say(message, row_item, id)
	if managers.menu:active_menu() then
		managers.menu:active_menu().renderer:post_event("prompt_exit")
	end

	local s = row_item.chat_output:script()
	local i = utf8.find_char(message, ":")

	s.box_print(message, tweak_data.chat_colors[id] or tweak_data.chat_colors[#tweak_data.chat_colors], i)
end

function MenuNodeGui:_cb_unlock()
end

function MenuNodeGui:_cb_lock()
end

function MenuNodeGui:_text_item_part(row_item, panel, align_x, text_align)
	local new_text = panel:text({
		halign = "left",
		vertical = "center",
		y = 0,
		font_size = self.font_size,
		x = align_x,
		align = text_align or row_item.align or "left",
		font = row_item.font,
		color = row_item.item:parameters().color or row_item.color,
		layer = self.layers.items,
		blend_mode = self.row_item_blend_mode or "normal",
		text = row_item.to_upper and utf8.to_upper(row_item.text) or row_item.text,
		render_template = Idstring("VertexColorTextured")
	})
	local color_ranges = row_item.color_ranges

	if color_ranges then
		for _, color_range in ipairs(color_ranges) do
			new_text:set_range_color(color_range.start, color_range.stop, color_range.color)
		end
	end

	return new_text
end

function MenuNodeGui:scroll_update(dt)
	local scrolled = MenuNodeGui.super.scroll_update(self, dt)

	if math.round(self.item_panel:world_y()) - math.round(self._item_panel_parent:world_y()) > -4 then
		self._list_arrows.up:set_color(self._list_arrows.up:color():with_alpha(0))
	else
		self._list_arrows.up:set_color(self._list_arrows.up:color():with_alpha(1))
	end

	if math.round(self.item_panel:world_bottom()) - math.round(self._item_panel_parent:world_bottom()) < 4 then
		self._list_arrows.down:set_color(self._list_arrows.down:color():with_alpha(0))
	else
		self._list_arrows.down:set_color(self._list_arrows.down:color():with_alpha(1))
	end

	self:update_item_icon_visibility()

	if scrolled then
		local row_item = self._highlighted_item and self:row_item(self._highlighted_item)

		if row_item then
			self:_align_marker(row_item)
		end
	end

	return scrolled
end

function MenuNodeGui:reload_item(item)
	local type = item:type()
	local row_item = self:row_item(item)

	if row_item then
		row_item.color = item:enabled() and (row_item.highlighted and (row_item.hightlight_color or self.row_item_hightlight_color) or row_item.row_item_color or self.row_item_color) or row_item.disabled_color
	end

	if not item:reload(row_item, self) then
		if type == "expand" then
			self:_reload_expand(item)
		elseif type == "friend" then
			self:_reload_friend(item)
		else
			MenuNodeGui.super.reload_item(self, item)
		end
	end

	if self._highlighted_item and self._highlighted_item == item and row_item then
		self:_align_marker(row_item)
	end
end

function MenuNodeGui:_collaps_others(my_item)
	for _, row_item in ipairs(self.row_items) do
		local item = row_item.item
		local type = item:type()

		if my_item ~= item and type == "expand" and not item:is_parent_to_item(my_item) and item:expanded() then
			item:toggle()
			self:_reload_expand(item)
		end
	end
end

function MenuNodeGui:_reload_expand(item)
	local row_item = self:row_item(item)

	item:reload(row_item, self)

	if item:expanded() then
		self:_collaps_others(item)
	end

	local need_repos = false

	if item:can_expand() then
		if item:expanded() then
			need_repos = item:expand(self, row_item)
		else
			need_repos = item:collaps(self, row_item)
		end
	end

	if need_repos then
		self:need_repositioning()
		row_item.node:select_item(item:name())
		self:_reposition_items(row_item)
	end
end

function MenuNodeGui:_delete_row_item(item)
	for i, row_item in ipairs(self.row_items) do
		if row_item.item == item then
			if alive(row_item.gui_pd2_panel) then
				row_item.gui_pd2_panel:parent():remove(row_item.gui_pd2_panel)
			end

			break
		end
	end

	if table.contains(self.corner_items, row_item) then
		table.delete(self.corner_items, row_item)
	end

	MenuNodeGui.super._delete_row_item(self, item)
end

function MenuNodeGui:_clear_gui()
	for i, row_item in ipairs(self.row_items) do
		if alive(row_item.gui_pd2_panel) then
			row_item.gui_pd2_panel:parent():remove(row_item.gui_pd2_panel)
		end
	end

	MenuNodeGui.super._clear_gui(self)
end

function MenuNodeGui:need_repositioning()
	self:_setup_size()
	self:scroll_setup()
	self:_set_item_positions()
end

function MenuNodeGui:update_item_icon_visibility()
	for _, row_item in pairs(self.row_items) do
		if alive(row_item.icon) then
			row_item.icon:set_visible(row_item.item:icon_visible() and self._item_panel_parent:world_y() <= row_item.icon:world_y() and row_item.icon:world_bottom() <= self._item_panel_parent:world_bottom())
		end
	end
end

function MenuNodeGui:_reload_friend(item)
	local row_item = self:row_item(item)
	local status_text = managers.localization:text("menu_friends_" .. row_item.item:parameters().signin_status)

	row_item.signin_status:set_text(utf8.to_upper(status_text))
end

function MenuNodeGui:_setup_item_size(row_item)
	local type = row_item.item:type()

	if type == "level" then
		self:_setup_level_size(row_item)
	end
end

function MenuNodeGui:_setup_level_size(row_item)
	local padding = 24

	row_item.gui_level_panel:set_shape(0, 0, self:_left_align(), self._item_panel_parent:h())

	local w = row_item.gui_level_panel:w() - padding * 2

	row_item.level_title:set_shape(padding, 24, w, row_item.gui_level_panel:w())
	row_item.level_text:set_shape(padding, 66, w, row_item.gui_level_panel:w())
end

function MenuNodeGui:_set_help_text(text_id, localize)
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.renderer:set_bottom_text(text_id, localize)
	end
end

function MenuNodeGui:_highlight_row_item(row_item, mouse_over)
	if row_item then
		row_item.highlighted = true

		self:_set_help_text(row_item.item:parameters().help_id, row_item.item:parameters().localize_help ~= false)
		self:_align_marker(row_item)

		row_item.color = row_item.item:enabled() and (row_item.hightlight_color or self.row_item_hightlight_color) or row_item.disabled_color

		if row_item.type == "NOTHING" then
			-- Nothing
		elseif row_item.type == "column" then
			for _, gui in ipairs(row_item.gui_columns) do
				gui:set_color(row_item.color)
				gui:set_font(tweak_data.menu.pd2_medium_font_id)
			end
		elseif row_item.type == "server_column" then
			for _, gui in ipairs(row_item.gui_columns) do
				gui:set_color(row_item.color)
				gui:set_font(tweak_data.menu.pd2_medium_font_id)
			end

			row_item.gui_info_panel:set_visible(true)
		elseif row_item.type == "level" then
			row_item.gui_level_panel:set_visible(true)
			MenuNodeGui.super._highlight_row_item(self, row_item)
		elseif row_item.type == "friend" then
			row_item.friend_name:set_color(row_item.color * row_item.color_mod)
			row_item.friend_name:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_no_outline_id)
			row_item.signin_status:set_color(row_item.color * row_item.color_mod)
			row_item.signin_status:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_no_outline_id)
		elseif row_item.type == "chat" then
			self.ws:connect_keyboard(Input:keyboard())
			row_item.border:set_visible(true)

			if not mouse_over then
				row_item.chat_input:script().set_focus(true)
			end
		elseif row_item.item:parameters().back then
			row_item.arrow_selected:set_visible(true)
			row_item.arrow_unselected:set_visible(false)
		elseif row_item.item:parameters().pd2_corner then
			row_item.gui_text:set_color(tweak_data.screen_colors.button_stage_2)
		elseif not row_item.item:highlight_row_item(self, row_item, mouse_over) then
			if row_item.gui_panel.set_text then
				row_item.gui_panel:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.pd2_medium_font_id)
			end

			if row_item.gui_info_panel then
				row_item.gui_info_panel:set_visible(true)
			end

			MenuNodeGui.super._highlight_row_item(self, row_item)

			if row_item.icon then
				row_item.icon:set_left(row_item.gui_panel:right())
				row_item.icon:set_center_y(row_item.gui_panel:center_y())
				row_item.icon:set_color(row_item.gui_panel:color())
			end
		end

		local active_menu = managers.menu:active_menu()

		if active_menu then
			if row_item.item:parameters().stencil_image then
				active_menu.renderer:set_stencil_image(row_item.item:parameters().stencil_image)
			else
				active_menu.renderer:set_stencil_image(self._stencil_image)
			end
		end
	end
end

function MenuNodeGui:_align_marker(row_item)
	if row_item.item.hide_highlight then
		self._marker_data.marker:hide()

		return
	end

	self._marker_data.marker:show()

	if self.marker_color or row_item.marker_color then
		self._marker_data.gradient:set_color(row_item.item:enabled() and (row_item.marker_color or self.marker_color) or self.marker_disabled_color or row_item.disabled_color)
	end

	if row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_visible(true)
		self._marker_data.gradient:set_visible(true)
		self._marker_data.gradient:set_rotation(360)
		self._marker_data.marker:set_height(64 * row_item.gui_text:height() / 32)
		self._marker_data.gradient:set_height(64 * row_item.gui_text:height() / 32)
		self._marker_data.marker:set_w(self:_scaled_size().width - row_item.menu_unselected:x())
		self._marker_data.gradient:set_w(self._marker_data.marker:w())
		self._marker_data.marker:set_world_right(row_item.gui_text:world_right())
		self._marker_data.marker:set_world_center_y(row_item.gui_text:world_center_y() - 2)

		return
	end

	self._marker_data.marker:show()
	self._marker_data.gradient:set_rotation(0)
	self._marker_data.marker:set_height(64 * row_item.gui_panel:height() / 32)
	self._marker_data.gradient:set_height(64 * row_item.gui_panel:height() / 32)
	self._marker_data.marker:set_left(row_item.menu_unselected:x())
	self._marker_data.marker:set_center_y(row_item.gui_panel:center_y())

	local item_enabled = row_item.item:enabled()

	if item_enabled then
		-- Nothing
	end

	if row_item.item:parameters().back then
		self._marker_data.marker:set_visible(false)
	else
		self._marker_data.marker:set_visible(true)

		if self._marker_data.back_marker then
			self._marker_data.back_marker:set_visible(false)
		end
	end

	if row_item.type == "upgrade" then
		self._marker_data.marker:set_left(self:_mid_align())
	elseif row_item.type == "friend" then
		if row_item.align == "right" then
			self._marker_data.marker:move(-100, 0)
		else
			local _, _, w, _ = row_item.signin_status:text_rect()

			self._marker_data.marker:set_left(self:_left_align() - w - self._align_line_padding)
		end
	elseif row_item.type == "server_column" then
		self._marker_data.marker:set_left(row_item.gui_panel:x())
	elseif row_item.type == "customize_controller" then
		-- Nothing
	elseif row_item.type == "nothing" then
		if row_item.type == "slider" then
			self._marker_data.marker:set_left(self:_left_align() - row_item.gui_slider:width())
		elseif row_item.type == "kitslot" or row_item.type == "multi_choice" then
			if row_item.choice_panel then
				self._marker_data.marker:set_left(row_item.arrow_left:left() - self._align_line_padding + row_item.gui_panel:x())
			end
		elseif row_item.type == "toggle" then
			if row_item.gui_option then
				local x, y, w, h = row_item.gui_option:text_rect()

				self._marker_data.marker:set_left(self:_left_align() - w - self._align_line_padding + row_item.gui_panel:x())
			else
				self._marker_data.marker:set_left(row_item.gui_icon:x() - self._align_line_padding + row_item.gui_panel:x())
			end
		end
	end

	self._marker_data.marker:set_w(self:_scaled_size().width - self._marker_data.marker:left())
	self._marker_data.gradient:set_w(self._marker_data.marker:w())
	self._marker_data.gradient:set_visible(true)

	if row_item.type == "chat" then
		self._marker_data.gradient:set_visible(false)
	end
end

function MenuNodeGui:_fade_row_item(row_item)
	if row_item then
		row_item.highlighted = false
		row_item.color = row_item.item:enabled() and (row_item.row_item_color or self.row_item_color) or row_item.disabled_color

		if row_item.type == "NOTHING" then
			-- Nothing
		elseif row_item.type == "column" then
			for _, gui in ipairs(row_item.gui_columns) do
				gui:set_color(row_item.color)
				gui:set_font(tweak_data.menu.pd2_medium_font_id)
			end
		elseif row_item.type == "server_column" then
			for _, gui in ipairs(row_item.gui_columns) do
				gui:set_color(row_item.color)
				gui:set_font(tweak_data.menu.pd2_medium_font_id)
			end

			row_item.gui_info_panel:set_visible(false)
		elseif row_item.type == "level" then
			row_item.gui_level_panel:set_visible(false)
			MenuNodeGui.super._fade_row_item(self, row_item)
		elseif row_item.type == "friend" then
			row_item.friend_name:set_color(row_item.color * row_item.color_mod)
			row_item.friend_name:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.pd2_medium_font_id)
			row_item.signin_status:set_color(row_item.color * row_item.color_mod)
			row_item.signin_status:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.pd2_medium_font_id)
		elseif row_item.type == "chat" then
			row_item.border:set_visible(false)
			row_item.chat_input:script().set_focus(false)
			self.ws:disconnect_keyboard()
		elseif row_item.item:parameters().back then
			row_item.arrow_selected:set_visible(false)
			row_item.arrow_unselected:set_visible(true)
		elseif row_item.item:parameters().pd2_corner then
			row_item.gui_text:set_color(tweak_data.screen_colors.button_stage_3)
		elseif not row_item.item:fade_row_item(self, row_item) then
			if row_item.gui_panel.set_text then
				row_item.gui_panel:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.pd2_medium_font_id)
			end

			if row_item.gui_info_panel then
				row_item.gui_info_panel:set_visible(false)
			end

			MenuNodeGui.super._fade_row_item(self, row_item)

			if row_item.icon then
				row_item.icon:set_left(row_item.gui_panel:right())
				row_item.icon:set_center_y(row_item.gui_panel:center_y())
				row_item.icon:set_color(row_item.gui_panel:color())
			end
		end
	end
end

function MenuNodeGui:_align_item_gui_info_panel(panel)
	panel:set_shape(self._info_bg_rect:x() + tweak_data.menu.info_padding, self._info_bg_rect:y() + tweak_data.menu.info_padding, self._info_bg_rect:w() - tweak_data.menu.info_padding * 2, self._info_bg_rect:h() - tweak_data.menu.info_padding * 2)
end

local xl_pad = 64

function MenuNodeGui:_align_info_panel(row_item)
	self:_align_item_gui_info_panel(row_item.gui_info_panel)
	row_item.help_title:set_font_size(self.font_size)
	row_item.help_title:set_shape(row_item.help_title:text_rect())
	row_item.help_title:set_position(0, 0)
	row_item.help_text:set_font_size(tweak_data.menu.pd2_small_font)
	row_item.help_text:set_w(row_item.gui_info_panel:w())
	row_item.help_text:set_shape(row_item.help_text:text_rect())
	row_item.help_text:set_x(0)
	row_item.help_text:set_top(row_item.help_title:bottom() + tweak_data.menu.info_padding)
end

function MenuNodeGui:_align_normal(row_item)
	local safe_rect = self:_scaled_size()

	row_item.gui_panel:set_font_size(row_item.font_size or self.font_size)

	local x, y, w, h = row_item.gui_panel:text_rect()

	row_item.gui_panel:set_height(h)
	row_item.gui_panel:set_left(self:_right_align() + (row_item.item:parameters().expand_value or 0))
	row_item.gui_panel:set_w(safe_rect.width - row_item.gui_panel:left())

	if row_item.icon then
		row_item.icon:set_left(row_item.gui_panel:right())
		row_item.icon:set_center_y(row_item.gui_panel:center_y())
		row_item.icon:set_color(row_item.gui_panel:color())
	end

	if row_item.gui_info_panel then
		self:_align_info_panel(row_item)
	end
end

function MenuNodeGui:_align_chat(row_item)
	local safe_rect = self:_scaled_size()

	row_item.chat_input:script().text:set_font_size(tweak_data.hud.chatinput_size)
	row_item.chat_input:set_h(25 * tweak_data.scale.chat_multiplier)
	row_item.chat_output:script().scrollus:set_font_size(tweak_data.hud.chatoutput_size)
	row_item.gui_panel:set_w(safe_rect.width / 2)
	row_item.gui_panel:set_right(safe_rect.width)
	row_item.gui_panel:set_h(118 * tweak_data.scale.chat_menu_h_multiplier + 25 * tweak_data.scale.chat_multiplier + 2)
	row_item.chat_input:set_w(row_item.gui_panel:w())
	row_item.chat_input:set_bottom(row_item.gui_panel:h())
	row_item.chat_input:set_right(row_item.gui_panel:w())
	row_item.border:set_w(row_item.chat_input:w())
	row_item.border:set_bottom(row_item.chat_input:top())

	local h = row_item.gui_panel:h() - row_item.chat_input:h() - 2

	row_item.chat_output:set_h(h)
	row_item.chat_output:set_w(row_item.gui_panel:w())
	row_item.chat_output:set_bottom(h)
	row_item.chat_output:set_right(row_item.gui_panel:w())

	if row_item.icon then
		row_item.icon:set_left(row_item.gui_panel:right())
		row_item.icon:set_center_y(row_item.gui_panel:center_y())
		row_item.icon:set_color(row_item.gui_panel:color())
	end
end

function MenuNodeGui:_update_scaled_values()
	self.font_size = self.font_size or tweak_data.menu.pd2_medium_font_size
	self.font = self.font or tweak_data.menu.pd2_medium_font
	self._align_line_padding = 10 * tweak_data.scale.align_line_padding_multiplier
end

function MenuNodeGui:resolution_changed()
	self:_update_scaled_values()

	local safe_rect = self:_scaled_size()
	local res = RenderSettings.resolution

	self._info_bg_rect:set_shape(0, tweak_data.load_level.upper_saferect_border, safe_rect.width * 0.41, safe_rect.height - tweak_data.load_level.upper_saferect_border * 2)

	for _, row_item in pairs(self.row_items) do
		if row_item.item:parameters().trial_buy then
			self:_setup_trial_buy(row_item)
		end

		if row_item.item:parameters().fake_disabled then
			self:_setup_fake_disabled(row_item)
		end

		if not row_item.item:reload(row_item, self) then
			if row_item.item:parameters().back then
				-- Nothing
			elseif row_item.item:parameters().pd2_corner then
				-- Nothing
			elseif row_item.type == "chat" then
				self:_align_chat(row_item)
			elseif row_item.type ~= "kitslot" and row_item.type ~= "server_column" then
				self:_align_normal(row_item)
			end
		end
	end

	MenuNodeGui.super.resolution_changed(self)
	self._align_data.panel:set_center_x(self:_mid_align())
	self._list_arrows.up:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.down:set_world_left(self._align_data.panel:world_left())
	self._legends_panel:set_shape(safe_rect.x, safe_rect.y, safe_rect.width, safe_rect.height)
	self:_layout_legends()
end

function MenuNodeGui:_layout_legends()
	local safe_rect = self:_scaled_size()
	local res = RenderSettings.resolution
	local text = self._legends_panel:child(0)
	local _, _, w, h = text:text_rect()

	self._legends_panel:set_h(h)

	local is_pc = managers.menu:is_pc_controller()

	if is_pc then
		text:set_center_x(self._legends_panel:w() / 2)
	else
		text:set_right(self._legends_panel:w())
	end

	text:set_bottom(self._legends_panel:h())
	self._legends_panel:set_bottom(self.ws:panel():bottom())
end

function MenuNodeGui:set_visible(visible)
	MenuNodeGui.super.set_visible(self, visible)

	if visible then
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.renderer:set_stencil_image(self._stencil_image)
			active_menu.renderer:set_stencil_align(self._stencil_align, self._stencil_align_percent)
			active_menu.renderer:set_stencil_image(self._stencil_image)
			active_menu.renderer:set_bg_visible(self._bg_visible)
			active_menu.renderer:set_bg_area(self._bg_area)
		end

		if self._scene_state and managers.menu_scene then
			managers.menu_scene:set_scene_template(self._scene_state)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		if visible and self.row_items and #self.row_items > 0 then
			for _, row_item in ipairs(self.row_items) do
				if row_item.highlighted then
					active_menu.renderer:set_bottom_text(row_item.item:parameters().help_id, row_item.item:parameters().localize_help ~= false)

					break
				end
			end
		else
			active_menu.renderer:set_bottom_text(nil)
		end
	end
end

function MenuNodeGui:close(...)
	for _, row_item in ipairs(self.row_items) do
		local item = row_item.item
		local type = item:type()

		if type == "expand" and item:expanded() then
			item:toggle()
			self:_reload_expand(item)
		end
	end

	MenuNodeGui.super.close(self, ...)
end

MenuNodeMainGui = MenuNodeMainGui or class(MenuNodeGui)

function MenuNodeMainGui:_setup_item_rows(node)
	MenuNodeMainGui.super._setup_item_rows(self, node)
	self:_add_version_string()
	managers.features:announce_feature("short_heists_available")

	if MenuCallbackHandler:enable_movie_theater() then
		managers.features:announce_feature("movie_theater_unlocked")
	end
end

function MenuNodeMainGui:set_visible(visible)
	MenuNodeMainGui.super.set_visible(self, visible)
	self:_add_version_string()
end

function MenuNodeMainGui:_add_version_string()
	if alive(self._version_string) then
		self._version_string:parent():remove(self._version_string)

		self._version_string = nil
	end

	if Application:debug_enabled() or SystemInfo:platform() == Idstring("WIN32") then
		local version = Application:version()
		self._version_string = self.ws:panel():text({
			name = "version_string",
			vertical = "bottom",
			align = "left",
			alpha = 0.5,
			text = version,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size
		})

		local function fade_in(o)
			local from = Color(0, 1, 1, 1)
			local to = Color(1, 1, 1, 1)
			local t = 0

			o:set_color(from)

			while t < 4 do
				local dt = coroutine.yield()
				t = t + dt
			end

			t = 0

			while t < 1 do
				local dt = coroutine.yield()
				t = t + dt

				o:set_color(from * (1 - t) + to * t)
			end

			o:set_color(to)
		end

		self._version_string:animate(fade_in)
	end
end
