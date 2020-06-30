require("lib/managers/menu/renderers/MenuNodeBaseGui")
require("lib/utils/InventoryDescription")

local function round_gui_object(object)
	if alive(object) then
		local x, y = object:world_position()

		object:set_world_position(math.round(x), math.round(y))

		if object.children then
			for i, d in ipairs(object:children()) do
				round_gui_object(d)
			end
		end
	end
end

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

MenuNodeCrimenetGui = MenuNodeCrimenetGui or class(MenuNodeGui)

function MenuNodeCrimenetGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true

	MenuNodeCrimenetGui.super.init(self, node, layer, parameters)
end

function MenuNodeCrimenetGui:_setup_item_panel(safe_rect, res)
	MenuNodeCrimenetGui.super._setup_item_panel(self, safe_rect, res)

	local padding = tweak_data.gui.crime_net.contract_gui.padding
	local width = tweak_data.gui.crime_net.contract_gui.width
	local height = tweak_data.gui.crime_net.contract_gui.height
	local contact_width = tweak_data.gui.crime_net.contract_gui.contact_width
	local y_offset = 0
	local safe_rect_size = managers.gui_data:scaled_size()
	local header_font_size = tweak_data.menu.pd2_large_font_size
	local header_outside_offset = header_font_size + height / 2 - safe_rect_size.height / 2

	if header_outside_offset > 0 then
		y_offset = header_outside_offset
	end

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("right")
	end

	local right = (self.item_panel:parent():w() + width) * 0.5 - padding
	local bottom = (self.item_panel:parent():h() + height) * 0.5 - padding + y_offset

	self.item_panel:set_rightbottom(right, bottom)
	self:_set_topic_position()
	round_gui_object(self.item_panel)
end

function MenuNodeCrimenetGui:_setup_item_panel_parent(safe_rect, shape)
	shape = shape or {}
	shape.x = shape.x or safe_rect.x
	shape.y = shape.y or safe_rect.y
	shape.w = shape.w or safe_rect.width
	shape.h = shape.h or safe_rect.height

	MenuNodeCrimenetGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeCrimenetGui:_mid_align()
	local safe_rect = self:_scaled_size()

	return safe_rect.width - tweak_data.gui.crime_net.contract_gui.contact_width
end

function MenuNodeCrimenetGui:_right_align(align_line_proportions)
	return self:_mid_align() + self._align_line_padding
end

function MenuNodeCrimenetGui:_left_align(align_line_proportions)
	return self:_mid_align() - self._align_line_padding
end

function MenuNodeCrimenetGui:_world_right_align()
	local safe_rect = self:_scaled_size()

	return safe_rect.x + self:_mid_align() + self._align_line_padding
end

function MenuNodeCrimenetGui:_world_left_align()
	local safe_rect = self:_scaled_size()

	return safe_rect.x + self:_mid_align() - self._align_line_padding
end

function MenuNodeCrimenetGui:_align_marker(row_item)
	MenuNodeCrimenetGui.super._align_marker(self, row_item)
	self._marker_data.marker:set_world_right(self.item_panel:world_right())
end

MenuNodeCrimenetFiltersGui = MenuNodeCrimenetFiltersGui or class(MenuNodeGui)

function MenuNodeCrimenetFiltersGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true
	self.static_y = node:parameters().static_y

	MenuNodeCrimenetFiltersGui.super.init(self, node, layer, parameters)
end

function MenuNodeCrimenetFiltersGui:close(...)
	MenuNodeCrimenetFiltersGui.super.close(self, ...)
end

function MenuNodeCrimenetFiltersGui:_setup_item_panel(safe_rect, res)
	MenuNodeCrimenetFiltersGui.super._setup_item_panel(self, safe_rect, res)

	local max_layer = 10000
	local min_layer = 0
	local child_layer = 0

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("right")

		child_layer = child:layer()

		if child_layer > 0 then
			min_layer = math.min(min_layer, child_layer)
		end

		max_layer = math.max(max_layer, child_layer)
	end

	for _, child in ipairs(self.item_panel:children()) do
		-- Nothing
	end

	self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions))
	self.item_panel:set_center(self.item_panel:parent():w() / 2, self.item_panel:parent():h() / 2)

	local static_y = self.static_y and safe_rect.height * self.static_y

	if static_y and static_y < self.item_panel:y() then
		self.item_panel:set_y(static_y)
	end

	self.item_panel:set_position(math.round(self.item_panel:x()), math.round(self.item_panel:y()))
	round_gui_object(self.item_panel)

	if alive(self.box_panel) then
		self.item_panel:parent():remove(self.box_panel)

		self.box_panel = nil
	end

	self.box_panel = self.item_panel:parent():panel()

	self.box_panel:set_x(self.item_panel:x())
	self.box_panel:set_w(self.item_panel:w())

	if self._align_data.panel:h() < self.item_panel:h() then
		self.box_panel:set_y(0)
		self.box_panel:set_h(self.item_panel:parent():h())
	else
		self.box_panel:set_y(self.item_panel:top())
		self.box_panel:set_h(self.item_panel:h())
	end

	self.box_panel:grow(20, 20)
	self.box_panel:move(-10, -10)
	self.box_panel:set_layer(51)

	self.boxgui = BoxGuiObject:new(self.box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self.boxgui:set_clipping(false)
	self.boxgui:set_layer(1000)
	self.box_panel:rect({
		rotation = 360,
		color = tweak_data.screen_colors.dark_bg
	})
	self._align_data.panel:set_left(self.box_panel:left())
	self._list_arrows.up:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.up:set_world_top(self._align_data.panel:world_top() - 10)
	self._list_arrows.up:set_width(self.box_panel:width())
	self._list_arrows.up:set_rotation(360)
	self._list_arrows.up:set_layer(1050)
	self._list_arrows.down:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.down:set_world_bottom(self._align_data.panel:world_bottom() + 10)
	self._list_arrows.down:set_width(self.box_panel:width())
	self._list_arrows.down:set_rotation(360)
	self._list_arrows.down:set_layer(1050)
	self:_set_topic_position()
end

function MenuNodeCrimenetFiltersGui:_setup_item_panel_parent(safe_rect, shape)
	shape = shape or {}
	shape.x = shape.x or safe_rect.x
	shape.y = shape.y or safe_rect.y + 0
	shape.w = shape.w or safe_rect.width
	shape.h = shape.h or safe_rect.height - 0

	MenuNodeCrimenetFiltersGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeCrimenetFiltersGui:_setup_item_rows(node)
	MenuNodeCrimenetFiltersGui.super._setup_item_rows(self, node)
end

function MenuNodeCrimenetFiltersGui:reload_item(item)
	MenuNodeCrimenetFiltersGui.super.reload_item(self, item)

	local row_item = self:row_item(item)

	if row_item and alive(row_item.gui_panel) then
		row_item.gui_panel:set_halign("right")
		row_item.gui_panel:set_right(self.item_panel:w())
	end
end

function MenuNodeCrimenetFiltersGui:_align_marker(row_item)
	MenuNodeCrimenetFiltersGui.super._align_marker(self, row_item)

	if row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_world_right(row_item.gui_panel:world_right())

		return
	end

	self._marker_data.marker:set_world_right(self.item_panel:world_right())
end

function MenuNodeCrimenetFiltersGui:_highlight_row_item(row_item, mouse_over)
	MenuNodeCrimenetFiltersGui.super._highlight_row_item(self, row_item, mouse_over)
end

MenuNodeCrimenetSpecialGui = MenuNodeCrimenetSpecialGui or class(MenuNodeCrimenetFiltersGui)

function MenuNodeCrimenetSpecialGui:_setup_item_panel(safe_rect, res)
	MenuNodeCrimenetSpecialGui.super._setup_item_panel(self, safe_rect, res)

	if alive(self.item_panel:parent():child("special_title_text")) then
		self.item_panel:parent():remove(self.item_panel:parent():child("special_title_text"))
	end

	local title_text = self.item_panel:parent():text({
		name = "special_title_text",
		blend_mode = "add",
		layer = 51,
		text = managers.localization:to_upper_text(self.title_id or "menu_cn_contract_broker_title"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(title_text)
	title_text:set_left(self.box_panel:left())
	title_text:set_bottom(self.box_panel:top())

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end
end

function MenuNodeCrimenetSpecialGui:previous_page()
	local item = self.node:item("contact_filter")

	if managers.menu:active_menu() and managers.menu:active_menu().logic and item and item:previous() then
		managers.menu_component:post_event("selection_previous")
		managers.menu:active_menu().logic:trigger_item(true, item)
	end
end

function MenuNodeCrimenetSpecialGui:next_page()
	local item = self.node:item("contact_filter")

	if managers.menu:active_menu() and managers.menu:active_menu().logic and item and item:next() then
		managers.menu_component:post_event("selection_next")
		managers.menu:active_menu().logic:trigger_item(true, item)
	end
end

function MenuNodeCrimenetSpecialGui:input_focus()
	return false
end

function MenuNodeCrimenetSpecialGui:close()
	MenuNodeCrimenetSpecialGui.super.close(self)

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(false)
	end
end

MenuNodeCrimenetSmartMatchmakingGui = MenuNodeCrimenetSmartMatchmakingGui or class(MenuNodeCrimenetSpecialGui)
MenuNodeCrimenetSmartMatchmakingGui.title_id = "menu_cn_smart_matchmaking_title"
MenuNodeCrimenetCasinoGui = MenuNodeCrimenetCasinoGui or class(MenuNodeGui)
MenuNodeCrimenetCasinoGui.PRECISION = "%.1f"

function MenuNodeCrimenetCasinoGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true

	MenuNodeCrimenetCasinoGui.super.init(self, node, layer, parameters)
	self:_setup_layout()
end

function MenuNodeCrimenetCasinoGui:_setup_item_panel(safe_rect, res)
	MenuNodeCrimenetCasinoGui.super._setup_item_panel(self, safe_rect, res)

	local width, height, space_x, space_y, start_x = self:_get_sizes(safe_rect.width, safe_rect.height)

	self.item_panel:set_right(start_x + width)
	self.item_panel:set_bottom(self.item_panel:parent():h() - space_y - tweak_data.menu.pd2_large_font_size)
end

function MenuNodeCrimenetCasinoGui:_get_sizes(safe_width, safe_height)
	local space_x = safe_width * 0.05
	local space_y = safe_width * 0.05
	local width = safe_width * 0.42
	local height = safe_height - tweak_data.menu.pd2_large_font_size * 2 - space_y * 2
	local start_x = safe_width - (width + space_x) * 2

	return width, height, space_x, space_y, start_x
end

function MenuNodeCrimenetCasinoGui:_set_cards(amount, card)
	local texture, rect, coords = tweak_data.hud_icons:get_icon_data(card or "downcard_overkill_deck")
	local offset = 20
	local count = amount == 0 and 3 or amount
	local height = nil
	local width = math.round(0.7111111111111111 * self._betting_cards_panel:h())
	local x_offset = 0
	local y_offset = 0

	if amount == 0 then
		height = self._betting_cards_panel:h() * 0.6
		x_offset = math.round(0.7111111111111111 * height / 2)
		y_offset = (self._betting_cards_panel:h() - height) / 2
	else
		height = self._betting_cards_panel:h()
	end

	local x = self._betting_cards_panel:w() / 2 - count * (width + offset) / 2
	local flip_cards = nil

	if amount > 0 or self._current_amount ~= amount then
		self._current_amount = amount
		flip_cards = true
	end

	for i = 1, 3 do
		if coords then
			self._betting_cards[i]:set_texture_coordinates(Vector3(coords[1][1], coords[1][2], 0), Vector3(coords[2][1], coords[2][2], 0), Vector3(coords[3][1], coords[3][2], 0), Vector3(coords[4][1], coords[4][2], 0))
		else
			self._betting_cards[i]:set_texture_rect(unpack(rect))
		end

		self._betting_cards[i]:set_alpha(amount > 0 and 1 or 0.25)
		self._betting_cards[i]:set_w(math.round(0.7111111111111111 * height))
		self._betting_cards[i]:set_h(height)
		self._betting_cards[i]:set_x(x + x_offset)
		self._betting_cards[i]:set_y(y_offset)

		x = x + width + offset

		if flip_cards then
			self._betting_cards[i]:set_rotation(math.random(14) - 7)
			self._betting_cards[i]:animate(callback(self, self, "flipcard", self._betting_cards[i]), 1.5)
		end

		self._betting_cards[i]:set_visible(MenuCallbackHandler:casino_betting_visible() and count > 0)

		count = count - 1
	end
end

function MenuNodeCrimenetCasinoGui:flipcard(bitmap)
	local start_w = bitmap:w()
	local cx, cy = bitmap:center()

	over(0.25, function (p)
		bitmap:set_w(start_w * math.sin(p * 90))
		bitmap:set_center(cx, cy)
	end)
end

function MenuNodeCrimenetCasinoGui:_round_value(value)
	local mult = 10

	return math.floor(value * mult + 0.5) / mult
end

function MenuNodeCrimenetCasinoGui:_setup_layout()
	local parent_layer = managers.menu:active_menu().renderer:selected_node():layer()
	self._panel = self.ws:panel():panel({
		layer = parent_layer + 1
	})
	local width, height, space_x, space_y, start_x = self:_get_sizes(self._panel:w(), self._panel:h())
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local small_font = tweak_data.menu.pd2_small_font
	local large_font_size = tweak_data.menu.pd2_large_font_size
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local option_size = self._panel:w() * (1 - self._align_line_proportions)
	local content_offset = 20
	local text_title = self._panel:text({
		blend_mode = "add",
		text = managers.localization:to_upper_text("menu_casino_title_main"),
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.text
	})
	local _, _, w, h = text_title:text_rect()
	self._main_panel = self._panel:panel({
		x = 0,
		y = h,
		w = self._panel:w(),
		h = self._panel:h() - h
	})
	local text_betting = self._main_panel:text({
		blend_mode = "add",
		text = managers.localization:to_upper_text("menu_casino_title_betting"),
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.text
	})

	text_betting:set_position(start_x, 0)

	local _, _, _, h = text_betting:text_rect()

	text_betting:set_h(h)

	self._betting_panel = self._main_panel:panel({
		layer = 1,
		y = text_betting:bottom(),
		w = width,
		h = height
	})

	self._betting_panel:set_x(text_betting:x())
	BoxGuiObject:new(self._betting_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local text_options = self._main_panel:panel({
		layer = 1,
		w = width - option_size,
		h = self.item_panel:h()
	})

	text_options:set_x(self._betting_panel:x())
	text_options:set_y(self.item_panel:y())

	local betting_titles = {
		{
			id = "prefer",
			text = "menu_casino_option_prefer_title"
		},
		{
			id = "infamous",
			text = "menu_casino_option_infamous_title"
		},
		{
			id = "safecards",
			text = "menu_casino_option_safecard_title"
		},
		{
			skip = true
		},
		{
			skip = true
		}
	}
	self._betting_titles = {}
	local i = 1
	local y = 0

	for _, item in ipairs(self.row_items) do
		if item.type ~= "divider" then
			if not betting_titles[i].skip then
				self._betting_titles[betting_titles[i].id] = text_options:text({
					align = "right",
					blend_mode = "add",
					text = managers.localization:to_upper_text(betting_titles[i].text),
					y = y,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.text
				})
			end

			i = i + 1
		end

		y = y + item.gui_panel:h()
	end

	self._betting_carddeck = {
		textures = "upcard_pattern",
		colors = "upcard_color",
		materials = "upcard_material",
		weapon_mods = "upcard_weapon",
		cash = "upcard_cash",
		masks = "upcard_mask",
		xp = "upcard_xp",
		none = "downcard_overkill_deck"
	}
	self._betting_cards_panel = self._betting_panel:panel({
		layer = 1,
		x = content_offset,
		y = content_offset + 15,
		w = self._betting_panel:w() - content_offset * 2
	})

	self._betting_cards_panel:set_h((self.item_panel:y() - content_offset * 2) * 0.6)

	local texture, rect, coords = tweak_data.hud_icons:get_icon_data(self._betting_carddeck.none)
	self._betting_cards = {}

	for i = 1, 3 do
		self._betting_cards[i] = self._betting_cards_panel:bitmap({
			name = "upcard",
			halign = "scale",
			blend_mode = "add",
			valign = "scale",
			layer = 1,
			texture = texture,
			w = math.round(0.7111111111111111 * self._betting_cards_panel:h()),
			h = self._betting_cards_panel:h()
		})

		self._betting_cards[i]:set_rotation(math.random(14) - 7)
		self._betting_cards[i]:set_visible(MenuCallbackHandler:casino_betting_visible())
	end

	self:_set_cards(0)

	self._stats_panel = self._main_panel:panel({
		layer = 1,
		x = text_betting:x(),
		y = text_betting:bottom(),
		w = width,
		h = height / 2 - space_y / 2
	})

	self._stats_panel:set_x(self._betting_panel:right() + space_x)
	BoxGuiObject:new(self._stats_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local text_stats = self._main_panel:text({
		blend_mode = "add",
		text = managers.localization:to_upper_text("menu_casino_title_stats"),
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.text
	})
	local _, _, _, h = text_stats:text_rect()

	text_stats:set_h(h)
	text_stats:set_x(self._stats_panel:x())
	text_stats:set_bottom(self._betting_panel:top())

	self._stats_cards = {
		"weapon_mods",
		"masks",
		"materials",
		"textures",
		"colors"
	}
	local stat_columns = {
		{
			name = "base",
			color = Color(0.5, 0.5, 0.5),
			color_inf = Color(1, 0.1, 1)
		},
		{
			name = "bets",
			color = tweak_data.screen_colors.risk
		},
		{
			name = "skill",
			color = tweak_data.screen_colors.resource
		},
		{
			name = "total",
			color = tweak_data.screen_colors.text,
			color_inf = Color(1, 0.1, 1)
		}
	}
	self._stat_values = {}
	local title_width = 150
	local column_width = 70
	local text_panel = nil
	local x = title_width + column_width * 0.55
	local y = content_offset

	for _, column in pairs(stat_columns) do
		self._stats_panel:text({
			blend_mode = "add",
			text = managers.localization:to_upper_text("menu_casino_stat_" .. column.name),
			x = x,
			y = y,
			font_size = small_font_size,
			font = small_font,
			color = column.color or tweak_data.screen_colors.text
		})

		x = x + column_width
	end

	y = content_offset + small_font_size + 10

	for _, stat in pairs(self._stats_cards) do
		self._stat_values[stat] = {}
		x = title_width

		for _, column in pairs(stat_columns) do
			text_panel = self._stats_panel:panel({
				layer = 1,
				x = x,
				y = y,
				w = column_width,
				h = small_font_size
			})
			self._stat_values[stat][column.name] = text_panel:text({
				blend_mode = "add",
				alpha = 1,
				align = "right",
				font_size = small_font_size,
				font = small_font,
				color = column.color or tweak_data.screen_colors.text
			})
			x = x + column_width
		end

		y = y + small_font_size
	end

	y = content_offset + small_font_size + 10

	for _, stat in pairs(self._stats_cards) do
		text_panel = self._stats_panel:panel({
			x = 0,
			layer = 1,
			y = y,
			w = title_width,
			h = small_font_size
		})
		self._stat_values[stat].title = text_panel:text({
			blend_mode = "add",
			align = "right",
			alpha = 1,
			text = managers.localization:to_upper_text("menu_casino_stat_" .. stat),
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text
		})
		y = y + small_font_size
	end

	self._infamous_values = {}
	y = y + small_font_size
	text_panel = self._stats_panel:panel({
		x = 0,
		layer = 1,
		y = y,
		w = title_width,
		h = small_font_size
	})

	text_panel:text({
		blend_mode = "add",
		align = "right",
		text = managers.localization:to_upper_text("bm_global_value_infamous"),
		font_size = small_font_size,
		font = small_font,
		color = Color(1, 0.1, 1)
	})

	x = title_width

	for _, column in pairs(stat_columns) do
		text_panel = self._stats_panel:panel({
			layer = 1,
			x = x,
			y = y,
			w = column_width,
			h = small_font_size
		})
		self._infamous_values[column.name] = text_panel:text({
			blend_mode = "add",
			align = "right",
			font_size = small_font_size,
			font = small_font,
			color = column.color_inf or column.color or tweak_data.screen_colors.text,
			alpha = column.alpha or 1
		})
		x = x + column_width
	end

	local stars = managers.experience:level_to_stars()
	local item_pc = tweak_data.lootdrop.STARS[stars].pcs[1]
	local skip_types = {
		xp = true,
		cash = true
	}
	local droppable_items = managers.lootdrop:droppable_items(item_pc, true, skip_types)
	local pc = stars * 10
	local weighted_type_chance = tweak_data.lootdrop.WEIGHTED_TYPE_CHANCE[pc]
	local sum = 0

	for type, items in pairs(droppable_items) do
		sum = sum + weighted_type_chance[type]
	end

	self._base_chances = {}

	for _, item in pairs(self._stats_cards) do
		self._base_chances[item] = 0
	end

	for type, items in pairs(droppable_items) do
		self._base_chances[type] = self:_round_value(weighted_type_chance[type] / sum * 100)
	end

	for _, stat in pairs(self._stats_cards) do
		local value = string.format(MenuNodeCrimenetCasinoGui.PRECISION, self._base_chances[stat])

		self._stat_values[stat].base:set_text(value .. "%")
		self._stat_values[stat].total:set_text(value .. "%")
	end

	local items_total = 0
	local items_infamous = 0

	for type, items in pairs(droppable_items) do
		items_total = items_total + #items

		for _, item in pairs(items) do
			if item.global_value == "infamous" then
				items_infamous = items_infamous + 1
			end
		end
	end

	local _, infamous_base_chance, infamous_mod = managers.lootdrop:infamous_chance({
		disable_difficulty = true
	})
	local infamous_chance = items_total > 0 and infamous_base_chance * items_infamous / items_total or 0
	self._infamous_chance = {
		base = infamous_chance,
		skill = infamous_mod
	}
	local value = self:_round_value(infamous_chance * 100)
	local skill = self:_round_value((infamous_chance * infamous_mod - infamous_chance) * 100)
	self._infamous_chance.value_base = value
	self._infamous_chance.value_skill = skill

	self._infamous_values.base:set_text(string.format(MenuNodeCrimenetCasinoGui.PRECISION, value) .. "%")
	self._infamous_values.skill:set_text(infamous_mod > 1 and "+" .. string.format(MenuNodeCrimenetCasinoGui.PRECISION, skill) .. "%" or "")
	self._infamous_values.total:set_text(string.format(MenuNodeCrimenetCasinoGui.PRECISION, value + skill) .. "%")

	self._breakdown_panel = self._main_panel:panel({
		layer = 1,
		w = width,
		h = self._betting_panel:h() - self._stats_panel:h() - space_y
	})

	self._breakdown_panel:set_x(self._stats_panel:x())
	self._breakdown_panel:set_top(self._stats_panel:bottom() + space_y)
	BoxGuiObject:new(self._breakdown_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local text_breakdown = self._main_panel:text({
		blend_mode = "add",
		text = managers.localization:to_upper_text("menu_casino_title_breakdown"),
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.text
	})
	local _, _, _, h = text_breakdown:text_rect()

	text_breakdown:set_h(h)
	text_breakdown:set_x(self._breakdown_panel:x())
	text_breakdown:set_bottom(self._breakdown_panel:top())

	self._breakdown_titles = self._breakdown_panel:text({
		blend_mode = "add",
		x = content_offset,
		y = content_offset,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})
	self._breakdown_costs = self._breakdown_panel:text({
		blend_mode = "add",
		x = self._breakdown_panel:w() * 0.4,
		y = content_offset,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.risk
	})
	self._offshore_text = self._main_panel:text({
		blend_mode = "add",
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})

	self:set_offshore_text()

	local _, _, w, h = self._offshore_text:text_rect()

	self._offshore_text:set_h(h)
	self._offshore_text:set_x(self._betting_panel:x())
	self._offshore_text:set_y(self._betting_panel:bottom() + h + 16)

	local secured_cards = 0
	local increase_infamous = false
	local preferred_card = "none"
	local text_string = managers.localization:to_upper_text("menu_casino_total_bet", {
		casino_bet = managers.experience:cash_string(managers.money:get_cost_of_casino_fee(secured_cards, increase_infamous, preferred_card))
	})
	self._total_bet = self._panel:text({
		blend_mode = "add",
		align = "right",
		text = text_string,
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.text
	})
	local _, _, _, h = self._total_bet:text_rect()

	self._total_bet:set_h(h)
	self._total_bet:set_right(self._breakdown_panel:right())
	self._total_bet:set_y(self._betting_panel:bottom() + h + 16)
	self:set_update_values(preferred_card, secured_cards, increase_infamous, false, false)
end

function MenuNodeCrimenetCasinoGui:set_update_values(preferred_card, secured_cards, increase_infamous, infamous_enabled, safecards_enabled)
	local breakdown_titles = managers.localization:to_upper_text("menu_casino_cost_fee") .. ":"
	local breakdown_costs = managers.experience:cash_string(managers.money:get_cost_of_casino_entrance())

	if preferred_card ~= "none" then
		breakdown_titles = breakdown_titles .. "\n" .. managers.localization:to_upper_text("menu_casino_option_prefer_title") .. ":"
		breakdown_costs = breakdown_costs .. "\n" .. managers.experience:cash_string(tweak_data:get_value("casino", "prefer_cost"))
	end

	if increase_infamous then
		breakdown_titles = breakdown_titles .. "\n" .. managers.localization:to_upper_text("menu_casino_option_infamous_title") .. ":"
		breakdown_costs = breakdown_costs .. "\n" .. managers.experience:cash_string(tweak_data:get_value("casino", "infamous_cost"))
	end

	if secured_cards > 0 then
		breakdown_titles = breakdown_titles .. "\n" .. managers.localization:to_upper_text("menu_casino_option_safecard_title") .. ":"

		for i = 1, secured_cards do
			breakdown_costs = breakdown_costs .. "\n" .. managers.experience:cash_string(tweak_data:get_value("casino", "secure_card_cost", i))
		end
	end

	self._breakdown_titles:set_text(breakdown_titles)
	self._breakdown_costs:set_text(breakdown_costs)

	local text_string = managers.localization:to_upper_text("menu_casino_total_bet", {
		casino_bet = managers.experience:cash_string(managers.money:get_cost_of_casino_fee(secured_cards, increase_infamous, preferred_card))
	})

	self._total_bet:set_text(text_string)

	local nbr_types = 0

	for _, card in pairs(self._stats_cards) do
		for _, item in pairs(self._stat_values[card]) do
			item:set_alpha((secured_cards == 0 or preferred_card == "none") and 1 or 0.5)
		end

		nbr_types = nbr_types + ((self._base_chances[card] > 0 or card == preferred_card) and 1 or 0)
	end

	if preferred_card == "none" then
		for _, card in pairs(self._stats_cards) do
			self._stat_values[card].bets:set_text("")
			self._stat_values[card].total:set_text(string.format(MenuNodeCrimenetCasinoGui.PRECISION, self._base_chances[card]) .. "%")
		end

		self:_set_cards(0)
	elseif nbr_types > 1 then
		local secured_value = 100 * secured_cards
		local preferred_chance = tweak_data:get_value("casino", "prefer_chance") * 100 * (3 - secured_cards)
		local preferred_left = preferred_chance / (nbr_types - 1)

		for _, card in pairs(self._stats_cards) do
			local non_secured_value = self._base_chances[card] * (3 - secured_cards)

			if preferred_card ~= "none" then
				non_secured_value = non_secured_value + (card == preferred_card and preferred_chance or -preferred_left)

				if non_secured_value < 0 then
					non_secured_value = 0
				end
			end

			local value = (non_secured_value + (card == preferred_card and secured_value or 0)) / 3 - self._base_chances[card]
			value = self:_round_value(value)

			self._stat_values[card].bets:set_text(value == 0 and "" or (value > 0 and "+" .. string.format(MenuNodeCrimenetCasinoGui.PRECISION, value) or string.format(MenuNodeCrimenetCasinoGui.PRECISION, value)) .. "%")
			self._stat_values[card].total:set_text(string.format(MenuNodeCrimenetCasinoGui.PRECISION, value + self._base_chances[card]) .. "%")

			if card == preferred_card then
				for _, item in pairs(self._stat_values[card]) do
					item:set_alpha(1)
				end
			end
		end

		self:_set_cards(secured_cards, secured_cards > 0 and self._betting_carddeck[preferred_card])
	end

	local base_value = self._infamous_chance.value_base + self._infamous_chance.value_skill
	local bets_value = increase_infamous and self:_round_value(base_value * tweak_data:get_value("casino", "infamous_chance") - base_value) or 0

	self._infamous_values.bets:set_text(increase_infamous and "+" .. string.format(MenuNodeCrimenetCasinoGui.PRECISION, bets_value) .. "%" or "")
	self._infamous_values.total:set_text(string.format(MenuNodeCrimenetCasinoGui.PRECISION, base_value + bets_value) .. "%")

	if self._betting_titles.safecards then
		self._betting_titles.safecards:set_alpha(safecards_enabled and 1 or 0.5)
	end

	if self._betting_titles.infamous then
		self._betting_titles.infamous:set_alpha(infamous_enabled and 1 or 0.5)
	end
end

function MenuNodeCrimenetCasinoGui:set_offshore_text()
	self._offshore_text:set_text(managers.localization:to_upper_text("menu_offshore_account") .. ": " .. managers.experience:cash_string(managers.money:offshore()))
end

MenuNodeCrimenetContactInfoGui = MenuNodeCrimenetContactInfoGui or class(MenuNodeGui)
MenuNodeCrimenetContactInfoGui.WIDTH = 600
MenuNodeCrimenetContactInfoGui.HEIGHT = 515
MenuNodeCrimenetContactInfoGui.MENU_WIDTH = 220
MenuNodeCrimenetContactInfoGui.PADDING = 10
MenuNodeCrimenetContactInfoGui.CODEX_TEXT_ID = "menu_contact_info_title"
MenuNodeCrimenetContactInfoGui.SOUND_SOURCE_NAME = "MenuNodeCrimenetContactInfoGui"
MenuNodeCrimenetContactInfoGui.FILE_ICONS_TEXTURE = "guis/textures/pd2/codex_pages"
MenuNodeCrimenetContactInfoGui.FILE_ICONS = {
	selected = {
		0,
		0,
		17,
		23
	},
	unselected = {
		20,
		0,
		17,
		23
	},
	locked = {
		40,
		0,
		17,
		23
	}
}

function MenuNodeCrimenetContactInfoGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true
	self._codex_text = managers.localization:to_upper_text(self.CODEX_TEXT_ID)
	self._current_file = 0
	self._sound_source = SoundDevice:create_source(self.SOUND_SOURCE_NAME)
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	self._file_icons = self.FILE_ICONS

	MenuNodeCrimenetContactInfoGui.super.init(self, node, layer, parameters)
	managers.menu_component:disable_crimenet()
	self:_setup_layout()

	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:deactivate_controller_mouse()
	end
end

function MenuNodeCrimenetContactInfoGui:_setup_item_panel_parent(safe_rect, shape)
	local x = safe_rect.x + safe_rect.width / 2 - self.WIDTH / 2 + self.PADDING
	local y = safe_rect.y + safe_rect.height / 2 - self.HEIGHT / 2 + self.PADDING
	shape = shape or {}
	shape.x = shape.x or x
	shape.y = shape.y or y
	shape.w = shape.w or self.MENU_WIDTH
	shape.h = shape.h or self.HEIGHT - 2 * self.PADDING - tweak_data.menu.pd2_small_font_size

	MenuNodeCrimenetContactInfoGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeCrimenetContactInfoGui:set_contact_info(id, name, files, override_file, sub_text)
	self._files = files
	local files_menu = self._files_menu
	local num_files = #files

	files_menu:clear()

	if num_files > 1 then
		files_menu:set_h(26)

		local size = files_menu:h() - 4

		for i = 1, num_files do
			local file_icons = self._files[i] and self._files[i].icon_rect or self._file_icons
			local is_locked = self._files[i] and self:is_file_locked(self._files[i].lock)
			local texture_rect = is_locked and file_icons.locked or file_icons.unselected

			files_menu:bitmap({
				h = 23,
				y = 0,
				w = 17,
				texture = self._files[i] and self._files[i].icon or self.FILE_ICONS_TEXTURE,
				texture_rect = texture_rect,
				x = (i - 1) * 20
			})
		end
	else
		files_menu:set_h(0)
	end

	local contact_desc_text = self._panel:child("contact_desc_text")

	contact_desc_text:set_top(files_menu:bottom())

	local contact_title_text = self._panel:child("contact_title_text")

	contact_title_text:set_text((sub_text or self._codex_text) .. ": " .. name)
	make_fine_text(contact_title_text)

	local contact_desc_title_text = self._panel:child("contact_desc_title_text")

	contact_desc_title_text:set_text((sub_text or self._codex_text) .. ": " .. name)
	make_fine_text(contact_desc_title_text)
	self:set_file(override_file)

	self._current_contact_info = id

	round_gui_object(self._panel)
end

function MenuNodeCrimenetContactInfoGui:set_empty()
	local video_panel = self._panel:child("video_panel")

	if video_panel and alive(video_panel:child("video")) then
		video_panel:remove(video_panel:child("video"))
	end

	if video_panel and alive(video_panel:child("image")) then
		video_panel:remove(video_panel:child("image"))
	end

	local contact_desc_text = self._panel:child("contact_desc_text")

	contact_desc_text:set_text("")
end

function MenuNodeCrimenetContactInfoGui:set_file(index)
	self:set_empty()

	if self._files[index] and self:is_file_locked(self._files[index].lock) then
		local i = 1
		local num_files = self._files and #self._files or 0

		while self:is_file_locked(self._files[i].lock) do
			i = i + 1

			if num_files < i then
				return
			end
		end

		index = i
	end

	self._current_file = index or 1

	self:_set_file()
end

function MenuNodeCrimenetContactInfoGui:_set_file()
	local file = self._files[self._current_file]
	local desc_id = file.desc_localized
	local video = file.videos and file.videos[math.random(#file.videos)]
	local image = file.images and file.images[math.random(#file.images)]
	local post_event = file.post_event
	local lock = file.lock
	local contact_desc_text = self._panel:child("contact_desc_text")

	contact_desc_text:set_text(desc_id)
	self._sound_source:stop()

	if post_event then
		self._sound_source:post_event(post_event)
	end

	local video_panel = self._panel:child("video_panel")

	if video then
		video_panel:video({
			blend_mode = "add",
			name = "video",
			loop = true,
			video = "movies/codex/" .. video,
			width = video_panel:w(),
			height = video_panel:h(),
			color = tweak_data.screen_colors.button_stage_2
		})
	end

	if image then
		local image_gui = video_panel:bitmap({
			name = "image",
			blend_mode = "add",
			texture = image,
			width = video_panel:w(),
			height = video_panel:h()
		})
		local texture_width = image_gui:texture_width()
		local texture_height = image_gui:texture_height()
		local panel_width = video_panel:w()
		local panel_height = video_panel:h()
		local tw = texture_width
		local th = texture_height
		local pw = panel_width
		local ph = panel_height
		local sw = math.min(pw, ph * tw / th)
		local sh = math.min(ph, pw / (tw / th))

		image_gui:set_size(math.round(sw), math.round(sh))
		image_gui:set_center(video_panel:w() * 0.5, video_panel:h() * 0.5)
	end

	local files_menu = self._files_menu

	for i, file in ipairs(files_menu:children()) do
		local file_icons = self._files[i] and self._files[i].icon_rect or self._file_icons
		local is_locked = self:is_file_locked(self._files[i].lock)
		local texture_rect = is_locked and file_icons.locked or i == self._current_file and file_icons.selected or file_icons.unselected

		file:set_texture_rect(unpack(texture_rect))
	end
end

function MenuNodeCrimenetContactInfoGui:is_file_locked(lock_callback)
	if not lock_callback then
		return
	end

	if type(lock_callback) == "string" then
		local callback_handler = managers.menu:active_menu() and managers.menu:active_menu().callback_handler

		if callback_handler then
			local clbk = callback(callback_handler, callback_handler, lock_callback)

			if clbk then
				return clbk()
			end
		end
	elseif type(lock_callback) == "boolean" then
		return lock_callback
	elseif type(lock_callback) == "function" then
		return lock_callback()
	end

	return false
end

function MenuNodeCrimenetContactInfoGui:change_file(diff)
	if not self._files or #self._files <= 1 then
		return
	end

	local num_files = #self._files
	local current_file = self._current_file or 0
	local new_file = math.clamp(current_file + diff, 1, num_files)
	local newer_file = nil

	while self:is_file_locked(self._files[new_file].lock) do
		newer_file = math.clamp(new_file + diff, 1, num_files)

		if newer_file == new_file then
			new_file = current_file

			break
		else
			new_file = newer_file
		end
	end

	if new_file ~= self._current_file then
		managers.menu_component:post_event("highlight")
		self:set_file(new_file)
	end
end

function MenuNodeCrimenetContactInfoGui:get_contact_info()
	return self._current_contact_info or ""
end

function MenuNodeCrimenetContactInfoGui:mouse_moved(o, x, y)
	local files_menu = self._files_menu
	local is_inside = false
	local highlighted_file = nil

	if alive(files_menu) then
		for i, file in ipairs(files_menu:children()) do
			local file_icons = self._files[i] and self._files[i].icon_rect or self._file_icons
			local is_locked = self._files[i] and self:is_file_locked(self._files[i].lock)
			local texture_rect = file_icons and (is_locked and file_icons.locked or i == self._current_file and file_icons.selected or file:inside(x, y) and file_icons.selected or file_icons.unselected)
			local texture_alpha = self._file_alphas and (is_locked and self._file_alphas.locked or i == self._current_file and self._file_alphas.selected or file:inside(x, y) and self._file_alphas.selected or self._file_alphas.unselected)

			if texture_rect then
				file:set_texture_rect(unpack(texture_rect))
			end

			if texture_alpha then
				file:set_alpha(texture_alpha)
			end

			if file:inside(x, y) then
				is_inside = i
				highlighted_file = self._current_file ~= i and i
			end
		end
	end

	if highlighted_file and self._highlighted_file ~= highlighted_file then
		managers.menu_component:post_event("highlight")

		self._highlighted_file = highlighted_file
	elseif not highlighted_file then
		self._highlighted_file = false
	end

	local is_locked = is_inside and self:is_file_locked(self._files[is_inside] and self._files[is_inside].lock)

	return is_inside, self._file_pressed and (self._file_pressed == is_inside and "link" or "arrow") or is_inside and not is_locked and "link" or "arrow"
end

function MenuNodeCrimenetContactInfoGui:mouse_pressed(button, x, y)
	local files_menu = self._files_menu

	if alive(files_menu) then
		for i, file in ipairs(files_menu:children()) do
			if file:inside(x, y) and not self:is_file_locked(self._files[i].lock) then
				self._file_pressed = i

				return
			end
		end
	end

	self._file_pressed = false

	if self._item_panel_parent:inside(x, y) then
		if button == Idstring("mouse wheel down") then
			return self:wheel_scroll_start(-1)
		elseif button == Idstring("mouse wheel up") then
			return self:wheel_scroll_start(1)
		end
	end
end

function MenuNodeCrimenetContactInfoGui:mouse_released(button, x, y)
	if self._file_pressed and self._file_pressed ~= self._current_file then
		local files_menu = self._files_menu

		if alive(files_menu) then
			local file = files_menu:children()[self._file_pressed]

			if file and file:inside(x, y) then
				self:set_file(self._file_pressed)
				managers.menu_component:post_event("menu_enter")
			end
		end
	end

	self._file_pressed = false
end

function MenuNodeCrimenetContactInfoGui:previous_page()
	self:change_file(-1)
end

function MenuNodeCrimenetContactInfoGui:next_page()
	self:change_file(1)
end

function MenuNodeCrimenetContactInfoGui:input_focus()
	return false
end

function MenuNodeCrimenetContactInfoGui:_setup_item_panel(safe_rect, res)
	MenuNodeCrimenetContactInfoGui.super._setup_item_panel(self, safe_rect, res)
	self:_setup_menu()
end

function MenuNodeCrimenetContactInfoGui:_setup_menu()
	if not self._init_finish then
		return
	end

	local safe_rect = managers.gui_data:scaled_size()

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("right")
	end

	self:_set_topic_position()
	self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions) + 4)
	self.item_panel:set_world_position(self._panel:world_position())
	self.item_panel:move(self.PADDING, self.PADDING)

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("left")
	end

	self.item_panel:set_w(self.MENU_WIDTH)
	self._align_data.panel:set_left(self.item_panel:left())

	local row_x = 0

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.icon) then
			row_item.icon:set_left(0)
		end

		if alive(row_item.gui_panel) then
			row_x = math.max(row_x, row_item.gui_panel:world_x())
		end
	end

	if self._back_row_item and alive(self._back_row_item.gui_text) then
		self._back_row_item.gui_text:set_w(self.MENU_WIDTH)
		self._back_row_item.gui_text:set_world_left(math.round(self._panel:world_left() + self.PADDING * 2))
		self._back_row_item.gui_text:set_world_bottom(math.round(self._panel:world_bottom() - self.PADDING))
	end

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.gui_panel) then
			row_item.gui_panel:set_w(self.MENU_WIDTH)
		end
	end

	for _, child in ipairs(self.item_panel:children()) do
		child:set_world_y(math.round(child:world_y()))
	end

	self._list_arrows.up:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.up:set_world_top(self._align_data.panel:world_top() - 1)
	self._list_arrows.up:set_width(self._item_panel_parent:w())
	self._list_arrows.down:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.down:set_world_bottom(self._align_data.panel:world_bottom() + 1)
	self._list_arrows.down:set_width(self._item_panel_parent:w())
end

function MenuNodeCrimenetContactInfoGui:_fade_row_item(row_item)
	MenuNodeCrimenetContactInfoGui.super._fade_row_item(self, row_item)

	if row_item.icon then
		row_item.icon:set_left(0)
	end
end

function MenuNodeCrimenetContactInfoGui:_highlight_row_item(row_item, mouse_over)
	MenuNodeCrimenetContactInfoGui.super._highlight_row_item(self, row_item, mouse_over)

	if row_item.icon then
		row_item.icon:set_left(0)
	end
end

function MenuNodeCrimenetContactInfoGui:refresh_gui(node)
	self:update_item_icon_visibility()

	local row_x = 0

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.icon) then
			row_item.icon:set_left(0)
		end

		if alive(row_item.gui_panel) then
			row_x = math.max(row_x, row_item.gui_panel:world_x())
		end
	end
end

function MenuNodeCrimenetContactInfoGui:_setup_layout()
	local safe_rect = managers.gui_data:scaled_size()
	local mc_full_ws = managers.menu_component:fullscreen_ws()
	local ws = self.ws

	if alive(self._fullscreen_panel) then
		mc_full_ws:panel():remove(self._fullscreen_panel)
	end

	if alive(ws:panel():child("main_panel")) then
		ws:panel():remove(ws:panel():child("main_panel"))
	end

	local panel = ws:panel():panel({
		name = "main_panel"
	})
	self._fullscreen_panel = mc_full_ws:panel():panel({
		layer = 50
	})
	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self._fullscreen_panel:w(),
		h = self._fullscreen_panel:h()
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	blur:animate(func)

	local width = self.WIDTH
	local height = self.HEIGHT
	self._panel = panel:panel({
		layer = 51,
		h = height,
		w = width
	})

	self._panel:set_center(panel:w() / 2, panel:h() / 2)
	self._panel:rect({
		layer = 0,
		color = tweak_data.screen_colors.dark_bg
	})
	BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local title_text = panel:text({
		name = "title_text",
		layer = 51,
		text = self._codex_text,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(title_text)
	title_text:set_left(self._panel:left())
	title_text:set_bottom(self._panel:top() - 2)

	local contact_title_text = self._panel:text({
		name = "contact_title_text",
		layer = 52,
		text = self._codex_text .. ": ",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(contact_title_text)
	contact_title_text:set_left(self.MENU_WIDTH + self.PADDING * 3)
	contact_title_text:set_top(self.PADDING)

	local video_panel = self._panel:panel({
		name = "video_panel",
		layer = 2,
		w = self.WIDTH - self.MENU_WIDTH - self.PADDING * 5
	})

	video_panel:set_h(video_panel:w() / 1.7777777777777777)
	video_panel:set_top(contact_title_text:bottom() + self.PADDING)
	video_panel:set_left(contact_title_text:left())

	local box = BoxGuiObject:new(video_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})

	box:set_color(Color(0.2, 1, 1, 1))
	box:set_blend_mode("add")

	local contact_desc_title_text = self._panel:text({
		name = "contact_desc_title_text",
		layer = 52,
		text = self._codex_text .. ": ",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(contact_desc_title_text)
	contact_desc_title_text:set_left(contact_title_text:left())
	contact_desc_title_text:set_top(video_panel:bottom() + self.PADDING)
	contact_desc_title_text:hide()

	local files_menu = self._panel:panel({
		name = "files_menu",
		h = 26,
		x = contact_desc_title_text:x(),
		y = contact_desc_title_text:y(),
		w = video_panel:w()
	})
	self._files_menu = files_menu
	local contact_desc_text = self._panel:text({
		text = "",
		name = "contact_desc_text",
		wrap = true,
		word_wrap = true,
		layer = 52,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(contact_desc_text)
	contact_desc_text:set_left(files_menu:left())
	contact_desc_text:set_top(files_menu:bottom())
	contact_desc_text:set_w(video_panel:w())
	contact_desc_text:set_h(self._panel:h() - self.PADDING - contact_desc_text:top())

	self._init_finish = true

	self:_setup_menu()
end

function MenuNodeCrimenetContactInfoGui:gui_node_custom(row_item)
	row_item.gui_panel = self._item_panel_parent:panel({
		w = 3,
		h = 3,
		layer = self.layers.items
	})
	row_item.gui_pd2_panel = self.ws:panel():panel({
		layer = self.layers.items
	})
	local row_item_panel = row_item.gui_pd2_panel
	row_item.gui_text = row_item_panel:text({
		blend_mode = "add",
		vertical = "bottom",
		align = "left",
		y = 0,
		x = 0,
		layer = 0,
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.button_stage_3,
		text = utf8.to_upper(row_item.text),
		render_template = Idstring("VertexColorTextured")
	})
	local _, _, w, h = row_item.gui_text:text_rect()

	row_item.gui_text:set_size(math.round(w), math.round(h))

	self._back_row_item = row_item
end

function MenuNodeCrimenetContactInfoGui:_align_marker(row_item)
	MenuNodeCrimenetContactInfoGui.super._align_marker(self, row_item)

	if row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_visible(true)
		self._marker_data.gradient:set_visible(true)
		self._marker_data.gradient:set_rotation(360)
		self._marker_data.marker:set_height(64 * row_item.gui_text:height() / 32)
		self._marker_data.gradient:set_height(64 * row_item.gui_text:height() / 32)
		self._marker_data.marker:set_w(self.MENU_WIDTH)
		self._marker_data.gradient:set_w(self._marker_data.marker:w())
		self._marker_data.marker:set_left(row_item.menu_unselected:x())
		self._marker_data.marker:set_world_center_y(row_item.gui_text:world_center_y())
		self._marker_data.marker:set_y(math.round(self._marker_data.marker:y()))

		return
	end
end

function MenuNodeCrimenetContactInfoGui:close()
	self._fullscreen_panel:parent():remove(self._fullscreen_panel)

	self._fullscreen_panel = nil
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(false)
	end

	self._sound_source:stop()

	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:activate_controller_mouse()
	end

	MenuNodeCrimenetContactInfoGui.super.close(self)
	managers.menu_component:enable_crimenet()
end

MenuNodeCrimenetContactShortGui = MenuNodeCrimenetContactShortGui or class(MenuNodeGui)
MenuNodeCrimenetContactShortGui.WIDTH = 700
MenuNodeCrimenetContactShortGui.HEIGHT = 250
MenuNodeCrimenetContactShortGui.MENU_WIDTH = 220
MenuNodeCrimenetContactShortGui.PADDING = 10

function MenuNodeCrimenetContactShortGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	MenuNodeCrimenetContactShortGui.super.init(self, node, layer, parameters)
	managers.menu_component:disable_crimenet()
	self:_setup_layout()

	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:deactivate_controller_mouse()
	end
end

function MenuNodeCrimenetContactShortGui:_setup_item_panel_parent(safe_rect, shape)
	local x = safe_rect.x + safe_rect.width / 2 - self.WIDTH / 2 + self.PADDING
	local y = safe_rect.y + safe_rect.height / 2 - self.HEIGHT / 2 + self.PADDING
	shape = shape or {}
	shape.x = shape.x or x
	shape.y = shape.y or y
	shape.w = shape.w or self.MENU_WIDTH
	shape.h = shape.h or self.HEIGHT - 2 * self.PADDING - tweak_data.menu.pd2_small_font_size

	MenuNodeCrimenetContactShortGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeCrimenetContactShortGui:set_contact_info(id, name, files, override_file, sub_text)
	self._files = files
	local files_menu = self._files_menu
	local num_files = #files

	files_menu:clear()

	if num_files > 1 then
		files_menu:set_h(26)

		local size = files_menu:h() - 4

		for i = 1, num_files do
			local file_icons = self._files[i] and self._files[i].icon_rect or self._file_icons
			local is_locked = self._files[i] and self:is_file_locked(self._files[i].lock)
			local texture_rect = is_locked and file_icons.locked or file_icons.unselected

			files_menu:bitmap({
				h = 23,
				y = 0,
				w = 17,
				texture = self._files[i] and self._files[i].icon or self.FILE_ICONS_TEXTURE,
				texture_rect = texture_rect,
				x = (i - 1) * 20
			})
		end
	else
		files_menu:set_h(0)
	end

	local contact_desc_text = self._panel:child("contact_desc_text")

	contact_desc_text:set_top(files_menu:bottom())

	local contact_title_text = self._panel:child("contact_title_text")

	make_fine_text(contact_title_text)

	local contact_desc_title_text = self._panel:child("contact_desc_title_text")

	make_fine_text(contact_desc_title_text)
	self:set_file(override_file)

	self._current_contact_info = id
end

function MenuNodeCrimenetContactShortGui:mouse_moved(o, x, y)
	local files_menu = self._files_menu
	local is_inside = false
	local highlighted_file = nil

	if alive(files_menu) then
		for i, file in ipairs(files_menu:children()) do
			local file_icons = self._files[i] and self._files[i].icon_rect or self._file_icons
			local is_locked = self._files[i] and self:is_file_locked(self._files[i].lock)
			local texture_rect = file_icons and (is_locked and file_icons.locked or i == self._current_file and file_icons.selected or file:inside(x, y) and file_icons.selected or file_icons.unselected)
			local texture_alpha = self._file_alphas and (is_locked and self._file_alphas.locked or i == self._current_file and self._file_alphas.selected or file:inside(x, y) and self._file_alphas.selected or self._file_alphas.unselected)

			if texture_rect then
				file:set_texture_rect(unpack(texture_rect))
			end

			if texture_alpha then
				file:set_alpha(texture_alpha)
			end

			if file:inside(x, y) then
				is_inside = i
				highlighted_file = self._current_file ~= i and i
			end
		end
	end

	if highlighted_file and self._highlighted_file ~= highlighted_file then
		managers.menu_component:post_event("highlight")

		self._highlighted_file = highlighted_file
	elseif not highlighted_file then
		self._highlighted_file = false
	end

	local is_locked = is_inside and self:is_file_locked(self._files[is_inside] and self._files[is_inside].lock)

	return is_inside, self._file_pressed and (self._file_pressed == is_inside and "link" or "arrow") or is_inside and not is_locked and "link" or "arrow"
end

function MenuNodeCrimenetContactShortGui:mouse_pressed(button, x, y)
	local files_menu = self._files_menu

	if alive(files_menu) then
		for i, file in ipairs(files_menu:children()) do
			if file:inside(x, y) and not self:is_file_locked(self._files[i].lock) then
				self._file_pressed = i

				return
			end
		end
	end

	self._file_pressed = false
end

function MenuNodeCrimenetContactShortGui:mouse_released(button, x, y)
	if self._file_pressed and self._file_pressed ~= self._current_file then
		local files_menu = self._files_menu

		if alive(files_menu) then
			local file = files_menu:children()[self._file_pressed]

			if file and file:inside(x, y) then
				self:set_file(self._file_pressed)
				managers.menu_component:post_event("menu_enter")
			end
		end
	end

	self._file_pressed = false
end

function MenuNodeCrimenetContactShortGui:previous_page()
end

function MenuNodeCrimenetContactShortGui:next_page()
end

function MenuNodeCrimenetContactShortGui:input_focus()
	return false
end

function MenuNodeCrimenetContactShortGui:_setup_item_panel(safe_rect, res)
	MenuNodeCrimenetContactShortGui.super._setup_item_panel(self, safe_rect, res)
	self:_setup_menu()
end

function MenuNodeCrimenetContactShortGui:_setup_menu()
	if not self._init_finish then
		return
	end

	local safe_rect = managers.gui_data:scaled_size()

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("right")
	end

	self:_set_topic_position()

	local y_offs = 20

	self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions) + 4)
	self.item_panel:set_world_position(self._panel:world_position())
	self.item_panel:move(self.PADDING, self.PADDING + y_offs)

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("left")
	end

	self.item_panel:set_w(self.MENU_WIDTH)
	self._align_data.panel:set_left(self.item_panel:left())

	local row_x = 0

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.icon) then
			row_item.icon:set_left(0)
		end

		if alive(row_item.gui_panel) then
			row_x = math.max(row_x, row_item.gui_panel:world_x())
		end
	end

	if self._back_row_item and alive(self._back_row_item.gui_text) then
		self._back_row_item.gui_text:set_w(self.MENU_WIDTH)
		self._back_row_item.gui_text:set_world_left(math.round(self._panel:world_left() + self.PADDING * 2))
		self._back_row_item.gui_text:set_world_bottom(math.round(self._panel:world_bottom() - self.PADDING))
	end

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.gui_panel) then
			row_item.gui_panel:set_w(self.MENU_WIDTH)
		end
	end

	for _, child in ipairs(self.item_panel:children()) do
		child:set_world_y(math.round(child:world_y()))
	end

	self._list_arrows.up:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.up:set_world_top(self._align_data.panel:world_top() - 1)
	self._list_arrows.up:set_width(self._item_panel_parent:w())
	self._list_arrows.down:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.down:set_world_bottom(self._align_data.panel:world_bottom() + 1)
	self._list_arrows.down:set_width(self._item_panel_parent:w())
	round_gui_object(self.item_panel)
end

function MenuNodeCrimenetContactShortGui:_fade_row_item(row_item)
	MenuNodeCrimenetContactShortGui.super._fade_row_item(self, row_item)

	if row_item.icon then
		row_item.icon:set_left(0)
	end
end

function MenuNodeCrimenetContactShortGui:_highlight_row_item(row_item, mouse_over)
	MenuNodeCrimenetContactShortGui.super._highlight_row_item(self, row_item, mouse_over)

	if row_item.icon then
		row_item.icon:set_left(0)
	end
end

function MenuNodeCrimenetContactShortGui:refresh_gui(node)
	self:update_item_icon_visibility()

	local row_x = 0

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.icon) then
			row_item.icon:set_left(0)
		end

		if alive(row_item.gui_panel) then
			row_x = math.max(row_x, row_item.gui_panel:world_x())
		end
	end
end

function MenuNodeCrimenetContactShortGui:_setup_layout()
	local safe_rect = managers.gui_data:scaled_size()
	local mc_full_ws = managers.menu_component:fullscreen_ws()
	local ws = self.ws

	if alive(self._fullscreen_panel) then
		mc_full_ws:panel():remove(self._fullscreen_panel)
	end

	if alive(ws:panel():child("main_panel")) then
		ws:panel():remove(ws:panel():child("main_panel"))
	end

	local panel = ws:panel():panel({
		name = "main_panel"
	})
	self._fullscreen_panel = mc_full_ws:panel():panel({
		layer = 50
	})
	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self._fullscreen_panel:w(),
		h = self._fullscreen_panel:h()
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	blur:animate(func)

	local width = self.WIDTH
	local height = self.HEIGHT
	self._panel = panel:panel({
		layer = 51,
		h = height,
		w = width
	})

	self._panel:set_center(panel:w() / 2, panel:h() / 2)
	self._panel:rect({
		layer = 0,
		color = tweak_data.screen_colors.dark_bg
	})
	BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local header_panel = self._panel:panel({
		layer = 51,
		h = height,
		w = width
	})

	header_panel:move(self.PADDING * 0.5, self.PADDING * 0.5)

	local header_text = header_panel:text({
		name = "header_text",
		layer = 51,
		text = managers.localization:to_upper_text("short_basics_header"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(header_text)

	local desc_panel = self._panel:panel({
		layer = 51,
		h = height * 0.5,
		w = width * 0.5
	})

	desc_panel:move(self.PADDING * 2, 90)

	local desc_text = desc_panel:text({
		name = "desc_text",
		wrap = true,
		layer = 51,
		text = managers.localization:text("short_basics_desc"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(header_text)

	local reward_panel_w_offs = -50
	local reward_panel_h_offs = 20
	local reward_panel = self._panel:panel({
		layer = 51,
		h = height - reward_panel_h_offs,
		w = width / 2 + reward_panel_w_offs
	})

	reward_panel:set_left(width - width / 2 - reward_panel_w_offs)
	reward_panel:set_top(reward_panel_h_offs)

	local reward_text = reward_panel:text({
		name = "rewards_text",
		layer = 51,
		text = managers.localization:to_upper_text("short_basics_rewards"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(reward_text)
	reward_text:set_bottom(25)

	local x_text_offs = 65
	local gfx_offs = 5
	local gfx_w = 40
	local gfx_h = 48
	local cash_y = 78
	local exp_y = 134
	local loot_y = 192
	local gfx_y_offs = 10
	local cash_drop_text = reward_panel:text({
		name = "cash_drop_text",
		layer = 51,
		text = managers.localization:to_upper_text("short_basics_cash"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(cash_drop_text)
	cash_drop_text:set_bottom(cash_y)
	cash_drop_text:set_left(x_text_offs)

	local exp_text = reward_panel:text({
		name = "exp_text",
		layer = 51,
		text = managers.localization:to_upper_text("short_basics_experience"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(exp_text)
	exp_text:set_bottom(exp_y)
	exp_text:set_left(x_text_offs)

	local loot_drop_text = reward_panel:text({
		name = "loot_drop_text",
		layer = 51,
		text = managers.localization:to_upper_text("short_basics_loot"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(loot_drop_text)
	loot_drop_text:set_bottom(loot_y)
	loot_drop_text:set_left(x_text_offs)

	local texture_atlas = "guis/textures/pd2/lootscreen/loot_cards"
	local texture_rect = {
		384,
		0,
		128,
		180
	}
	local cash_bitmap = reward_panel:bitmap({
		name = "cash_bitmap",
		blend_mode = "normal",
		layer = 51,
		texture = texture_atlas,
		texture_rect = texture_rect,
		w = gfx_w,
		h = gfx_h
	})

	cash_bitmap:set_bottom(cash_y + gfx_y_offs)
	cash_bitmap:set_left(gfx_offs)

	local texture_rect = {
		0,
		180,
		128,
		180
	}
	local exp_bitmap = reward_panel:bitmap({
		name = "cash_bitmap",
		blend_mode = "normal",
		layer = 51,
		texture = texture_atlas,
		texture_rect = texture_rect,
		w = gfx_w,
		h = gfx_h
	})

	exp_bitmap:set_bottom(exp_y + gfx_y_offs)
	exp_bitmap:set_left(gfx_offs)

	local texture_rect = {
		640,
		180,
		128,
		180
	}
	local loot_bitmap = reward_panel:bitmap({
		name = "cash_bitmap",
		blend_mode = "normal",
		layer = 51,
		texture = texture_atlas,
		texture_rect = texture_rect,
		w = gfx_w,
		h = gfx_h
	})

	loot_bitmap:set_bottom(loot_y + gfx_y_offs)
	loot_bitmap:set_left(gfx_offs)

	local title_text = panel:text({
		name = "title_text",
		layer = 51,
		text = managers.localization:to_upper_text("menu_contact_info_short"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(title_text)
	title_text:set_left(self._panel:left())
	title_text:set_bottom(self._panel:top() - 2)

	self._init_finish = true

	self:_setup_menu()
	round_gui_object(panel)
end

function MenuNodeCrimenetContactShortGui:gui_node_custom(row_item)
	row_item.gui_panel = self._item_panel_parent:panel({
		w = 3,
		h = 3,
		layer = self.layers.items
	})
	row_item.gui_pd2_panel = self.ws:panel():panel({
		layer = self.layers.items
	})
	local row_item_panel = row_item.gui_pd2_panel
	row_item.gui_text = row_item_panel:text({
		blend_mode = "add",
		vertical = "bottom",
		align = "left",
		y = 0,
		x = 0,
		layer = 0,
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.button_stage_3,
		text = utf8.to_upper(row_item.text),
		render_template = Idstring("VertexColorTextured")
	})
	local _, _, w, h = row_item.gui_text:text_rect()

	row_item.gui_text:set_size(math.round(w), math.round(h))

	self._back_row_item = row_item
end

function MenuNodeCrimenetContactShortGui:_align_marker(row_item)
	MenuNodeCrimenetContactShortGui.super._align_marker(self, row_item)

	if row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_visible(true)
		self._marker_data.gradient:set_visible(true)
		self._marker_data.gradient:set_rotation(360)
		self._marker_data.marker:set_height(64 * row_item.gui_text:height() / 32)
		self._marker_data.gradient:set_height(64 * row_item.gui_text:height() / 32)
		self._marker_data.marker:set_w(self.MENU_WIDTH)
		self._marker_data.gradient:set_w(self._marker_data.marker:w())
		self._marker_data.marker:set_left(row_item.menu_unselected:x())
		self._marker_data.marker:set_world_center_y(row_item.gui_text:world_center_y())
		self._marker_data.marker:set_y(math.round(self._marker_data.marker:y()))

		return
	end
end

function MenuNodeCrimenetContactShortGui:close()
	self._fullscreen_panel:parent():remove(self._fullscreen_panel)

	self._fullscreen_panel = nil
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(false)
	end

	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:activate_controller_mouse()
	end

	MenuNodeCrimenetContactShortGui.super.close(self)
	managers.menu_component:enable_crimenet()
end

MenuNodeCrimenetContactChillGui = MenuNodeCrimenetContactChillGui or class(MenuNodeGui)
MenuNodeCrimenetContactChillGui.WIDTH = 700
MenuNodeCrimenetContactChillGui.HEIGHT = 250
MenuNodeCrimenetContactChillGui.MENU_WIDTH = 220
MenuNodeCrimenetContactChillGui.PADDING = 10

function MenuNodeCrimenetContactChillGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	MenuNodeCrimenetContactChillGui.super.init(self, node, layer, parameters)
	managers.menu_component:disable_crimenet()
	self:_setup_layout()

	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:deactivate_controller_mouse()
	end
end

function MenuNodeCrimenetContactChillGui:_setup_item_panel_parent(safe_rect, shape)
	local x = safe_rect.x + safe_rect.width / 2 - self.WIDTH / 2 + self.PADDING
	local y = safe_rect.y + safe_rect.height / 2 - self.HEIGHT / 2 + self.PADDING
	shape = shape or {}
	shape.x = shape.x or x
	shape.y = shape.y or y
	shape.w = shape.w or self.WIDTH - self.PADDING * 2
	shape.h = shape.h or self.HEIGHT

	MenuNodeCrimenetContactChillGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeCrimenetContactChillGui:set_contact_info(id, name, files, override_file, sub_text)
	self._files = files
	local files_menu = self._files_menu
	local num_files = #files

	files_menu:clear()

	if num_files > 1 then
		files_menu:set_h(26)

		local size = files_menu:h() - 4

		for i = 1, num_files do
			local file_icons = self._files[i] and self._files[i].icon_rect or self._file_icons
			local is_locked = self._files[i] and self:is_file_locked(self._files[i].lock)
			local texture_rect = is_locked and file_icons.locked or file_icons.unselected

			files_menu:bitmap({
				h = 23,
				y = 0,
				w = 17,
				texture = self._files[i] and self._files[i].icon or self.FILE_ICONS_TEXTURE,
				texture_rect = texture_rect,
				x = (i - 1) * 20
			})
		end
	else
		files_menu:set_h(0)
	end

	local contact_desc_text = self._panel:child("contact_desc_text")

	contact_desc_text:set_top(files_menu:bottom())

	local contact_title_text = self._panel:child("contact_title_text")

	make_fine_text(contact_title_text)

	local contact_desc_title_text = self._panel:child("contact_desc_title_text")

	make_fine_text(contact_desc_title_text)
	self:set_file(override_file)

	self._current_contact_info = id
end

function MenuNodeCrimenetContactChillGui:mouse_moved(o, x, y)
	local files_menu = self._files_menu
	local is_inside = false
	local highlighted_file = nil

	if alive(files_menu) then
		for i, file in ipairs(files_menu:children()) do
			local file_icons = self._files[i] and self._files[i].icon_rect or self._file_icons
			local is_locked = self._files[i] and self:is_file_locked(self._files[i].lock)
			local texture_rect = file_icons and (is_locked and file_icons.locked or i == self._current_file and file_icons.selected or file:inside(x, y) and file_icons.selected or file_icons.unselected)
			local texture_alpha = self._file_alphas and (is_locked and self._file_alphas.locked or i == self._current_file and self._file_alphas.selected or file:inside(x, y) and self._file_alphas.selected or self._file_alphas.unselected)

			if texture_rect then
				file:set_texture_rect(unpack(texture_rect))
			end

			if texture_alpha then
				file:set_alpha(texture_alpha)
			end

			if file:inside(x, y) then
				is_inside = i
				highlighted_file = self._current_file ~= i and i
			end
		end
	end

	if highlighted_file and self._highlighted_file ~= highlighted_file then
		managers.menu_component:post_event("highlight")

		self._highlighted_file = highlighted_file
	elseif not highlighted_file then
		self._highlighted_file = false
	end

	local is_locked = is_inside and self:is_file_locked(self._files[is_inside] and self._files[is_inside].lock)

	return is_inside, self._file_pressed and (self._file_pressed == is_inside and "link" or "arrow") or is_inside and not is_locked and "link" or "arrow"
end

function MenuNodeCrimenetContactChillGui:mouse_pressed(button, x, y)
	local files_menu = self._files_menu

	if alive(files_menu) then
		for i, file in ipairs(files_menu:children()) do
			if file:inside(x, y) and not self:is_file_locked(self._files[i].lock) then
				self._file_pressed = i

				return
			end
		end
	end

	self._file_pressed = false
end

function MenuNodeCrimenetContactChillGui:mouse_released(button, x, y)
	if self._file_pressed and self._file_pressed ~= self._current_file then
		local files_menu = self._files_menu

		if alive(files_menu) then
			local file = files_menu:children()[self._file_pressed]

			if file and file:inside(x, y) then
				self:set_file(self._file_pressed)
				managers.menu_component:post_event("menu_enter")
			end
		end
	end

	self._file_pressed = false
end

function MenuNodeCrimenetContactChillGui:previous_page()
	self:change_file(-1)
end

function MenuNodeCrimenetContactChillGui:next_page()
	self:change_file(1)
end

function MenuNodeCrimenetContactChillGui:input_focus()
	return false
end

function MenuNodeCrimenetContactChillGui:_setup_item_panel(safe_rect, res)
	MenuNodeCrimenetContactChillGui.super._setup_item_panel(self, safe_rect, res)
	self:_setup_menu()
end

function MenuNodeCrimenetContactChillGui:_setup_menu()
	if not self._init_finish then
		return
	end

	local safe_rect = managers.gui_data:scaled_size()

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("right")
	end

	self:_set_topic_position()

	local y_offs = 119

	self.item_panel:set_righttop(self._item_panel_parent:w(), self.PADDING + y_offs)
end

function MenuNodeCrimenetContactChillGui:set_difficulty(difficulty)
	self._difficulty = difficulty
end

function MenuNodeCrimenetContactChillGui:get_difficulty()
	return self._difficulty or "normal"
end

function MenuNodeCrimenetContactChillGui:set_one_down(one_down)
	self._one_down = one_down
end

function MenuNodeCrimenetContactChillGui:get_one_down()
	return self._one_down or false
end

function MenuNodeCrimenetContactChillGui:_fade_row_item(row_item)
	MenuNodeCrimenetContactChillGui.super._fade_row_item(self, row_item)

	if row_item.icon then
		row_item.icon:set_left(0)
	end
end

function MenuNodeCrimenetContactChillGui:_highlight_row_item(row_item, mouse_over)
	MenuNodeCrimenetContactChillGui.super._highlight_row_item(self, row_item, mouse_over)

	if row_item.icon then
		row_item.icon:set_left(0)
	end
end

function MenuNodeCrimenetContactChillGui:refresh_gui(node)
	self:update_item_icon_visibility()

	local row_x = 0

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.icon) then
			row_item.icon:set_left(0)
		end

		if alive(row_item.gui_panel) then
			row_x = math.max(row_x, row_item.gui_panel:world_x())
		end
	end
end

function MenuNodeCrimenetContactChillGui:_setup_layout()
	local safe_rect = managers.gui_data:scaled_size()
	local mc_full_ws = managers.menu_component:fullscreen_ws()
	local ws = self.ws

	if alive(self._fullscreen_panel) then
		mc_full_ws:panel():remove(self._fullscreen_panel)
	end

	if alive(ws:panel():child("main_panel")) then
		ws:panel():remove(ws:panel():child("main_panel"))
	end

	local panel = ws:panel():panel({
		name = "main_panel"
	})
	self._fullscreen_panel = mc_full_ws:panel():panel({
		layer = 50
	})
	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self._fullscreen_panel:w(),
		h = self._fullscreen_panel:h()
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	blur:animate(func)

	local width = self.WIDTH
	local height = self.HEIGHT
	self._panel = panel:panel({
		layer = 51,
		h = height,
		w = width
	})

	self._panel:set_center(panel:w() / 2, panel:h() / 2)
	self._panel:rect({
		layer = 0,
		color = tweak_data.screen_colors.dark_bg
	})
	BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local reward_panel_w_offs = -50
	local reward_panel_h_offs = 20
	local header_panel = self._panel:panel({
		layer = 51,
		h = height,
		w = width
	})

	header_panel:move(self.PADDING * 0.5, self.PADDING * 0.5)

	local header_text = header_panel:text({
		name = "header_text",
		layer = 51,
		text = managers.localization:to_upper_text("chill_combat_header"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(header_text)

	local desc_panel = self._panel:panel({
		layer = 51,
		h = height * 0.5,
		w = width * 0.5
	})

	desc_panel:move(self.WIDTH * 0.5, 10)

	local desc_text = desc_panel:text({
		name = "desc_text",
		wrap = true,
		layer = 51,
		text = managers.localization:text("chill_combat_desc"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(header_text)

	local reward_panel = self._panel:panel({
		layer = 51,
		h = height,
		w = width
	})

	reward_panel:set_left(self.PADDING)
	reward_panel:set_top(reward_panel_h_offs)

	local reward_text = reward_panel:text({
		name = "rewards_text",
		layer = 51,
		text = managers.localization:to_upper_text("chill_combat_rewards"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(reward_text)
	reward_text:set_bottom(30)

	local x_text_offs = 65
	local gfx_offs = 5
	local gfx_w = 40
	local gfx_h = 48
	local cash_y = 78
	local exp_y = 134
	local loot_y = 192
	local gfx_y_offs = 10
	local cash_drop_text = reward_panel:text({
		name = "cash_drop_text",
		layer = 51,
		text = managers.localization:to_upper_text("short_basics_cash"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(cash_drop_text)
	cash_drop_text:set_bottom(cash_y)
	cash_drop_text:set_left(x_text_offs)

	local exp_text = reward_panel:text({
		name = "exp_text",
		layer = 51,
		text = managers.localization:to_upper_text("short_basics_experience"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(exp_text)
	exp_text:set_bottom(exp_y)
	exp_text:set_left(x_text_offs)

	local loot_drop_text = reward_panel:text({
		name = "loot_drop_text",
		layer = 51,
		text = managers.localization:to_upper_text("short_basics_loot"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(loot_drop_text)
	loot_drop_text:set_bottom(loot_y)
	loot_drop_text:set_left(x_text_offs)

	local texture_atlas = "guis/textures/pd2/lootscreen/loot_cards"
	local texture_rect = {
		384,
		0,
		128,
		180
	}
	local cash_bitmap = reward_panel:bitmap({
		name = "cash_bitmap",
		blend_mode = "normal",
		layer = 51,
		texture = texture_atlas,
		texture_rect = texture_rect,
		w = gfx_w,
		h = gfx_h
	})

	cash_bitmap:set_bottom(cash_y + gfx_y_offs)
	cash_bitmap:set_left(gfx_offs)

	local texture_rect = {
		0,
		180,
		128,
		180
	}
	local exp_bitmap = reward_panel:bitmap({
		name = "cash_bitmap",
		blend_mode = "normal",
		layer = 51,
		texture = texture_atlas,
		texture_rect = texture_rect,
		w = gfx_w,
		h = gfx_h
	})

	exp_bitmap:set_bottom(exp_y + gfx_y_offs)
	exp_bitmap:set_left(gfx_offs)

	local texture_rect = {
		640,
		180,
		128,
		180
	}
	local loot_bitmap = reward_panel:bitmap({
		name = "cash_bitmap",
		blend_mode = "normal",
		layer = 51,
		texture = texture_atlas,
		texture_rect = texture_rect,
		w = gfx_w,
		h = gfx_h
	})

	loot_bitmap:set_bottom(loot_y + gfx_y_offs)
	loot_bitmap:set_left(gfx_offs)

	local title_text = panel:text({
		name = "title_text",
		layer = 51,
		text = managers.localization:to_upper_text("menu_contact_info_chill_combat"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(title_text)
	title_text:set_left(self._panel:left())
	title_text:set_bottom(self._panel:top() - 2)

	self._init_finish = true

	self:_setup_menu()
	round_gui_object(panel)
end

function MenuNodeCrimenetContactChillGui:remove_blur()
	if self._fullscreen_panel then
		self._fullscreen_panel:parent():remove(self._fullscreen_panel)

		self._fullscreen_panel = nil
	end
end

function MenuNodeCrimenetContactChillGui:close()
	self:remove_blur()

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(false)
	end

	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:activate_controller_mouse()
	end

	MenuNodeCrimenetContactChillGui.super.close(self)
	managers.menu_component:enable_crimenet()
end

MenuNodeCrimenetGageAssignmentGui = MenuNodeCrimenetGageAssignmentGui or class(MenuNodeCrimenetContactInfoGui)
MenuNodeCrimenetGageAssignmentGui.WIDTH = 1000
MenuNodeCrimenetGageAssignmentGui.HEIGHT = 530
MenuNodeCrimenetGageAssignmentGui.MENU_WIDTH = 220
MenuNodeCrimenetGageAssignmentGui.PADDING = 10
MenuNodeCrimenetGageAssignmentGui.CODEX_TEXT_ID = "menu_gage_assignment_title"
MenuNodeCrimenetGageAssignmentGui.SOUND_SOURCE_NAME = "MenuNodeCrimenetGageAssignmentGui"

function MenuNodeCrimenetGageAssignmentGui:set_contact_info(id, name, files, override_file)
	self:unretrieve_textures()

	self._requested_textures = {}

	self._info_panel:clear()

	local ids = Idstring(id)
	local num_assignments = 5
	local is_assignment = tweak_data.gage_assignment:exists(id)

	if is_assignment then
		local right_width = (self._info_panel:w() - self.PADDING * (num_assignments - 1)) / num_assignments
		local left_width = self._info_panel:w() - self.PADDING - right_width
		local left_panel = self._info_panel:panel({
			name = "left_panel",
			x = 0,
			y = 0,
			w = left_width
		})
		local right_panel = self._info_panel:panel({
			name = "right_panel",
			y = 0,
			x = left_panel:right() + self.PADDING,
			w = right_width,
			h = right_width * 1.75
		})
		local rewards = tweak_data.gage_assignment:get_value(id, "rewards") or {}
		local reward_width = (left_panel:w() - self.PADDING * 4) / 3
		local reward_height = (left_panel:h() - self.PADDING * 3) / 2
		local all_weapon_families = managers.weapon_factory:get_all_weapon_families()
		local all_weapon_categories = managers.weapon_factory:get_all_weapon_categories()

		for i, data in ipairs(rewards) do
			local x = (i - 1) % 3
			local y = math.ceil(i / 3) - 1
			local panel = left_panel:panel({
				x = self.PADDING + x * (self.PADDING + reward_width),
				y = self.PADDING + y * (self.PADDING + reward_height),
				w = reward_width,
				h = reward_height
			})
			local item_panel = panel:panel({
				h = panel:w() * 0.5
			})

			item_panel:set_center_y(panel:h() * 0.25)

			local item_text = panel:text({
				text = "",
				name = "item_text",
				wrap = true,
				align = "center",
				word_wrap = true,
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.text
			})

			item_text:set_shape(0, item_panel:bottom() + self.PADDING / 2, panel:w(), panel:h() - item_panel:bottom() - self.PADDING / 2)

			local part_name_id = tweak_data.blackmarket[data[2]][data[3]].name_id
			local text_sting = managers.localization:text(part_name_id)

			if data[2] == "weapon_mods" then
				local weapon_uses_part = managers.weapon_factory:get_weapons_uses_part(data[3]) or {}
				text_sting = text_sting .. "\n("

				if managers.localization:exists(part_name_id .. "_fits") then
					text_sting = text_sting .. managers.localization:text(part_name_id .. "_fits")
				elseif #weapon_uses_part == 1 then
					local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(weapon_uses_part[1])
					text_sting = text_sting .. managers.weapon_factory:get_weapon_name_by_weapon_id(weapon_id)
				else
					local all_families = deep_clone(all_weapon_families)
					local all_categories = deep_clone(all_weapon_categories)
					local family, weapon_id, category = nil

					for i, factory_id in ipairs(weapon_uses_part) do
						family = tweak_data.weapon.factory[factory_id].family

						if family then
							table.delete(all_families[family], factory_id)
						end

						weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)
						category = tweak_data.weapon[weapon_id].category

						if category then
							table.delete(all_categories[category], factory_id)
						end
					end

					local need_string = true
					local categories = {}

					for category, weapons in pairs(all_categories) do
						if #weapons == 0 then
							table.insert(categories, category)
						end
					end

					if #categories > 0 then
						for i, category in ipairs(categories) do
							text_sting = text_sting .. managers.localization:text("menu_" .. category)

							if i < #categories then
								text_sting = text_sting .. ", "
							end
						end

						need_string = false
					end

					if need_string then
						local families = {}

						for family, weapons in pairs(all_families) do
							if #weapons == 0 then
								table.insert(families, family)
							end
						end

						if #families > 0 then
							for i, family in ipairs(families) do
								text_sting = text_sting .. managers.localization:text("menu_family_" .. family)

								if i < #families then
									text_sting = text_sting .. ", "
								end
							end

							need_string = false
						end

						if need_string then
							if #weapon_uses_part < 4 then
								for i, factory_id in ipairs(weapon_uses_part) do
									text_sting = text_sting .. managers.weapon_factory:get_weapon_name_by_factory_id(factory_id)

									if i < #weapon_uses_part then
										text_sting = text_sting .. ", "
									end
								end
							else
								print("[MenuNodeCrimenetGageAssignmentGui]", i, inspect(all_categories), inspect(all_families))
							end
						end
					end
				end

				text_sting = text_sting .. ")"
			end

			item_text:set_text(text_sting)
			item_text:set_world_position(math.round(item_text:world_x()), math.round(item_text:world_y()))
			self:populate_item_panel(item_panel, data)
		end

		self:create_insigna(right_panel, id)
		BoxGuiObject:new(left_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		BoxGuiObject:new(right_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	elseif ids == Idstring("_introduction") then
		local introduction_text = self._info_panel:text({
			name = "introduction_text",
			wrap = true,
			word_wrap = true,
			text = managers.localization:text("menu_gage_assignment_introduction_desc"),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})
	elseif ids == Idstring("_summary") then
		local width = (self._info_panel:w() - self.PADDING * (num_assignments - 1)) / num_assignments
		local x = 0
		local summary_panel = self._info_panel:panel({
			name = "summary_panel"
		})

		summary_panel:set_h(width * 1.75)
		summary_panel:set_bottom(self._info_panel:h())

		for i, node in ipairs(self.node:items()) do
			if tweak_data.gage_assignment:exists(node:parameters().name) then
				local panel = summary_panel:panel({
					name = node:parameters().name
				})

				panel:set_w(width)
				panel:set_x(x)
				self:create_insigna(panel, node:parameters().name)

				x = panel:right() + self.PADDING
			end
		end

		local summary_text = self._info_panel:text({
			name = "summary_text",
			wrap = true,
			word_wrap = true,
			text = managers.localization:text("menu_gage_assignment_summary_desc"),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})

		summary_text:set_h(summary_panel:top() - self.PADDING)
		BoxGuiObject:new(summary_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	elseif ids == Idstring("_video") then
		local video_panel = self._info_panel:panel()

		video_panel:rect({
			alpha = 0.85,
			valign = "scale",
			halign = "scale",
			color = Color.black
		})

		local video = video_panel:video({
			loop = true,
			video = "movies/tutorials/gage_assignment",
			blend_mode = "add",
			halign = "scale",
			layer = 1,
			valign = "scale"
		})
		local video_width = video:video_width()
		local video_height = video:video_height()
		local ratio = video_width / video_height
		local sh = math.min(self._info_panel:h(), self._info_panel:w() / ratio)
		local sw = math.min(self._info_panel:w(), self._info_panel:h() * ratio)

		video_panel:set_size(sw, sh)
		video:play()
		BoxGuiObject:new(video_panel, {
			sides = {
				2,
				2,
				2,
				2
			}
		})
	end

	local contact_title_text = self._panel:child("contact_title_text")

	if is_assignment then
		contact_title_text:set_text(managers.localization:to_upper_text(tweak_data.gage_assignment:get_value(id, "reward_id")))
	else
		contact_title_text:set_text(utf8.to_upper(name))
	end

	make_fine_text(contact_title_text)

	self._current_contact_info = id

	round_gui_object(self._info_panel)
end

function MenuNodeCrimenetGageAssignmentGui:create_insigna(panel, assignment)
	local assignment_insignia = panel:panel({
		w = panel:w(),
		h = panel:w() * 2
	})
	local progress, to_aquire, completed = managers.gage_assignment:get_assignment_data(assignment)
	local dlc = tweak_data.gage_assignment:get_value(assignment, "dlc")
	local has_dlc = not dlc or managers.dlc:is_dlc_unlocked(dlc)
	local progress_text = panel:text({
		text = "",
		name = "progress_text",
		wrap = true,
		align = "center",
		word_wrap = true,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	progress_text:set_text(tostring(progress) .. "/" .. tostring(to_aquire))
	make_fine_text(progress_text)
	progress_text:set_bottom(panel:h())
	progress_text:set_center_x(panel:w() / 2)
	progress_text:set_position(math.round(progress_text:x()), math.round(progress_text:y()))

	local step = 2
	local x = self.PADDING
	local max_aquire = tweak_data.gage_assignment:get_max_aquire()
	local w = (panel:w() - x * 2 - step * (max_aquire - 1)) / max_aquire
	local rounded_width = math.max(math.round(w), 1)
	local diff = panel:w() - (w * max_aquire + step * (max_aquire - 1) + x * 2)
	x = math.clamp(math.round(x + diff / 2), 0, panel:w())
	local padding = x
	local w = math.max((panel:w() - x * 2 - step * (to_aquire - 1)) / to_aquire, 1)
	local rounded_width = math.round(w)
	local estimated_width = x * 2 + step * (to_aquire - 1) + rounded_width * to_aquire
	diff = panel:w() - (w * to_aquire + x * 2)

	if to_aquire > 1 then
		step = math.clamp(diff / (to_aquire - 1), 0, 2)
	end

	local w = math.max((panel:w() - x * 2 - step * (to_aquire - 1)) / to_aquire, 1)
	local rounded_width = math.round(w)
	local pin_bottom = progress_text:top() - self.PADDING / 2
	local pin, is_progressed = nil
	local mvec1 = Vector3()
	local mvec2 = Vector3()

	for i = 1, to_aquire do
		is_progressed = i <= progress
		pin = panel:rect({
			x = x,
			w = w,
			h = is_progressed and 10 or 3,
			color = Color.white,
			alpha = is_progressed and 1 or 0.3
		})

		pin:set_bottom(pin_bottom)

		x = pin:right() + step
	end

	local insignia = tweak_data.gage_assignment:get_value(assignment, "insignia")

	if insignia then
		local texture_count = managers.menu_component:request_texture(insignia, callback(self, self, "texture_done_clbk", {
			assignment_insignia,
			false,
			"add"
		}))

		table.insert(self._requested_textures, {
			texture_count = texture_count,
			texture = insignia
		})
	else
		assignment_insignia:rect({
			blend_mode = "add",
			color = Color.red
		})
	end
end

function MenuNodeCrimenetGageAssignmentGui:populate_item_panel(item_panel, item_data)
	local global_value, category, item_id = unpack(item_data)

	if category == "weapon_mods" then
		category = "mods"
	end

	if category == "colors" then
		local colors = tweak_data.blackmarket.colors[item_id].colors
		local bg = item_panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg",
			layer = 1,
			w = item_panel:h(),
			h = item_panel:h()
		})
		local c1 = item_panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/icons/colors/color_01",
			layer = 0,
			w = item_panel:h(),
			h = item_panel:h()
		})
		local c2 = item_panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/icons/colors/color_02",
			layer = 0,
			w = item_panel:h(),
			h = item_panel:h()
		})

		c1:set_color(colors[1])
		c2:set_color(colors[2])
		bg:set_center(item_panel:w() / 2, item_panel:h() / 2)
		c1:set_center(bg:center())
		c2:set_center(bg:center())
	else
		local texture_path = nil

		if category == "textures" then
			texture_path = tweak_data.blackmarket.textures[item_id] and tweak_data.blackmarket.textures[item_id].texture

			if not texture_path then
				Application:error("Pattern missing", item_id)

				return
			end
		elseif category == "cash" then
			texture_path = "guis/textures/pd2/blackmarket/cash_drop"
		elseif category == "xp" then
			texture_path = "guis/textures/pd2/blackmarket/xp_drop"
		else
			local guis_catalog = "guis/"
			local tweak_data_category = category == "mods" and "weapon_mods" or category
			local bundle_folder = tweak_data.blackmarket[tweak_data_category] and tweak_data.blackmarket[tweak_data_category][item_id] and tweak_data.blackmarket[tweak_data_category][item_id].texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			texture_path = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(category) .. "/" .. tostring(item_id)
		end

		if DB:has(Idstring("texture"), texture_path) then
			local texture_count = managers.menu_component:request_texture(texture_path, callback(self, self, "texture_done_clbk", {
				item_panel,
				category == "textures"
			}))

			table.insert(self._requested_textures, {
				texture_count = texture_count,
				texture = texture_path
			})
		else
			Application:error("[MenuNodeCrimenetGageAssignmentGui]", item_id, "Texture not in DB", texture_path)
			item_panel:rect({
				color = Color.red
			})
		end
	end
end

function MenuNodeCrimenetGageAssignmentGui:unretrieve_textures()
	if self._requested_textures then
		for i, data in pairs(self._requested_textures) do
			managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
		end
	end

	self._requested_textures = nil
end

function MenuNodeCrimenetGageAssignmentGui:texture_done_clbk(params, texture_ids)
	local panel = params[1]
	local is_pattern = params[2]
	local blend_mode = params[3] or "normal"
	local color = params[4]
	local texture_rect = params[5]
	local image = panel:bitmap({
		name = "texture",
		texture = texture_ids,
		texture_rect = texture_rect,
		blend_mode = blend_mode
	})

	if is_pattern then
		image:set_render_template(Idstring("VertexColorTexturedPatterns"))
	end

	if color then
		image:set_color(color)
	end

	local texture_width = texture_rect and texture_rect[3] or image:texture_width()
	local texture_height = texture_rect and texture_rect[4] or image:texture_height()
	local panel_width = panel:w()
	local panel_height = panel:h()
	local tw = texture_width
	local th = texture_height
	local pw = panel_width
	local ph = panel_height

	if tw == 0 or th == 0 then
		Application:error("[MenuNodeCrimenetGageAssignmentGui:texture_done_clbk] Texture size error!:", "width", tw, "height", th)

		tw = 1
		th = 1
	end

	local sw = math.min(pw, ph * tw / th)
	local sh = math.min(ph, pw / (tw / th))

	image:set_size(math.round(sw), math.round(sh))
	image:set_center(panel:w() * 0.5, panel:h() * 0.5)
end

function MenuNodeCrimenetGageAssignmentGui:_setup_layout()
	local safe_rect = managers.gui_data:scaled_size()
	local mc_full_ws = managers.menu_component:fullscreen_ws()
	local ws = self.ws

	if alive(self._fullscreen_panel) then
		mc_full_ws:panel():remove(self._fullscreen_panel)
	end

	if alive(ws:panel():child("main_panel")) then
		ws:panel():remove(ws:panel():child("main_panel"))
	end

	local panel = ws:panel():panel({
		name = "main_panel"
	})
	self._fullscreen_panel = mc_full_ws:panel():panel({
		layer = 50
	})
	local width = self.WIDTH
	local height = self.HEIGHT
	self._panel = panel:panel({
		layer = 51,
		h = height,
		w = width
	})

	self:_set_panel_position(panel)
	self._panel:rect({
		layer = 0,
		color = tweak_data.screen_colors.dark_bg
	})
	BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local title_text = panel:text({
		name = "title_text",
		layer = 51,
		text = self._codex_text,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(title_text)
	title_text:set_left(self._panel:left())
	title_text:set_bottom(self._panel:top() - 2)

	local contact_title_text = self._panel:text({
		text = " ",
		name = "contact_title_text",
		layer = 52,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(contact_title_text)
	contact_title_text:set_left(self.MENU_WIDTH + self.PADDING * 3)
	contact_title_text:set_top(self.PADDING)

	self._info_panel = self._panel:panel({
		layer = 1,
		x = self.MENU_WIDTH + self.PADDING * 3,
		y = contact_title_text:bottom() + self.PADDING
	})

	self._info_panel:set_w(self._panel:w() - self._info_panel:x() - self.PADDING)
	self._info_panel:set_h(self._panel:h() - self._info_panel:y() - self.PADDING)
	self:_setup_blur()

	self._init_finish = true

	self:_setup_menu()
	round_gui_object(panel)
end

function MenuNodeCrimenetGageAssignmentGui:_setup_blur()
	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self._fullscreen_panel:w(),
		h = self._fullscreen_panel:h()
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	blur:animate(func)
end

function MenuNodeCrimenetGageAssignmentGui:_set_panel_position(panel)
	self._panel:set_center(panel:w() / 2, panel:h() / 2)
end

function MenuNodeCrimenetGageAssignmentGui:set_file(index)
end

function MenuNodeCrimenetGageAssignmentGui:close()
	self:unretrieve_textures()
	MenuNodeCrimenetGageAssignmentGui.super.close(self)
end

MenuNodeCrimenetChallengeGui = MenuNodeCrimenetChallengeGui or class(MenuNodeCrimenetGageAssignmentGui)
MenuNodeCrimenetChallengeGui.WIDTH = 900
MenuNodeCrimenetChallengeGui.HEIGHT = 500
MenuNodeCrimenetChallengeGui.MENU_WIDTH = 315
MenuNodeCrimenetChallengeGui.PADDING = 10
MenuNodeCrimenetChallengeGui.CODEX_TEXT_ID = "menu_cn_challenge_title"
MenuNodeCrimenetChallengeGui.SOUND_SOURCE_NAME = "MenuNodeCrimenetChallengeGui"

function MenuNodeCrimenetChallengeGui:init(node, layer, parameters)
	MenuNodeCrimenetChallengeGui.super.init(self, node, layer, parameters)

	self._file_icons = nil
	self._file_alphas_all = {
		mouse_over = 1,
		locked = 0.4,
		unavailable = 1,
		selected = 1,
		unselected = 0.8
	}
	self._file_alphas_single = {
		mouse_over = 1,
		locked = 0.4,
		unavailable = 1,
		selected = 1,
		unselected = 0.4
	}
	self._file_alphas = self._file_alphas_all
end

function MenuNodeCrimenetChallengeGui:_create_timestamp_string_extended(timestamp)
	local minutes = 59 - tonumber(Application:date("%M"))
	local seconds = 59 - tonumber(Application:date("%S"))
	local expire_string = ""

	if timestamp >= 24 then
		expire_string = managers.localization:text("menu_challenge_expire_time_extended_with_days", {
			days = math.floor(timestamp / 24),
			hours = timestamp % 24,
			minutes = minutes,
			seconds = seconds
		})
	elseif timestamp >= 0 then
		expire_string = managers.localization:text("menu_challenge_expire_time_extended", {
			hours = timestamp,
			minutes = minutes,
			seconds = seconds
		})
	else
		expire_string = managers.localization:text("menu_challenge_about_to_expire_extended")
	end

	return expire_string
end

function MenuNodeCrimenetChallengeGui:set_contact_info(id, name, files, override_file)
	self:unretrieve_textures()

	self._requested_textures = {}

	self._info_panel:clear()

	self._files = {}

	if not id then
		local contact_title_text = self._panel:child("contact_title_text")

		contact_title_text:set_text(" ")
		make_fine_text(contact_title_text)

		return
	end

	local contact_title = name
	local ids = Idstring(id)
	local challenge = managers.challenge:get_active_challenge(id, ids:key())
	self._set_file_on_mouse_over = false
	self._file_alphas = self._file_alphas_all
	self._confirm_reward = false

	if challenge then
		self._file_alphas = self._file_alphas_single
		self._set_file_on_mouse_over = challenge.reward_type == "single"
		self._confirm_reward = challenge.reward_type == "single"
		contact_title = managers.localization:text("menu_challenge_title_" .. (challenge.category or "daily"), {
			name = name
		})
		local desc_text = self._info_panel:text({
			name = "desc_text",
			wrap = true,
			word_wrap = true,
			blend_mode = "add",
			text = challenge.desc_s or managers.localization:text(challenge.desc_id),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})

		desc_text:grow(-desc_text:left(), 0)

		local _, _, _, h = desc_text:text_rect()

		desc_text:set_h(h)

		local y = desc_text:bottom()
		local objective_title_text = self._info_panel:text({
			name = "objective_title_text",
			blend_mode = "add",
			text = managers.localization:to_upper_text("menu_challenge_objective_title"),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.challenge_title
		})

		make_fine_text(objective_title_text)
		objective_title_text:set_top(y + tweak_data.menu.pd2_small_font_size)

		y = objective_title_text:bottom()

		if challenge.objective_s or challenge.objective_id then
			local objective_text = self._info_panel:text({
				name = "objectives_text",
				wrap = true,
				word_wrap = true,
				blend_mode = "add",
				text = challenge.objective_s or managers.localization:text(challenge.objective_id),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.text
			})

			objective_text:set_left(objective_title_text:left() + 0)
			objective_text:set_top(y)
			objective_text:grow(-objective_text:left(), 0)

			local _, _, _, h = objective_text:text_rect()

			objective_text:set_h(h)

			y = objective_text:bottom()
		end

		for _, objective in ipairs(challenge.objectives or {}) do
			if objective.desc_s or objective.desc_id then
				local name_text = self._info_panel:text({
					blend_mode = "add",
					name = "name_text_objective_" .. tostring(_),
					text = objective.name_s or objective.name_id and managers.localization:text(objective.name_id) or "",
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					color = tweak_data.screen_colors.text
				})
				local desc_text = self._info_panel:text({
					blend_mode = "add",
					name = "desc_text_objective_" .. tostring(_),
					text = objective.desc_s or objective.desc_id and managers.localization:text(objective.desc_id, {
						progress = objective.progress and managers.money:add_decimal_marks_to_string(tostring(objective.progress)),
						max_progress = objective.max_progress and managers.money:add_decimal_marks_to_string(tostring(objective.max_progress))
					}) or "",
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					color = tweak_data.screen_colors.text
				})

				make_fine_text(name_text)
				make_fine_text(desc_text)
				name_text:set_left(objective_title_text:left() + 15)
				name_text:set_top(y)
				desc_text:set_left(name_text:right())
				desc_text:set_top(y)

				y = math.max(name_text:bottom(), desc_text:bottom())
			end
		end

		local rewards_panel = nil

		if challenge.rewards and #challenge.rewards > 0 then
			local x = self.PADDING
			local min_height = 64
			local height = math.clamp(self._info_panel:h() - y - self.PADDING * 2 - tweak_data.menu.pd2_small_font_size - 0, min_height, 128)
			local width = math.min((self._info_panel:w() - self.PADDING * (#challenge.rewards - 1)) / #challenge.rewards, height)
			rewards_panel = self._info_panel:panel({
				layer = 10,
				name = "rewards_panel"
			})

			rewards_panel:set_w((width - 2 * self.PADDING) * #challenge.rewards + self.PADDING * (#challenge.rewards + 1))
			rewards_panel:set_h(height)
			rewards_panel:set_bottom(self._info_panel:h() - 0)
			rewards_panel:set_right(self._info_panel:w())

			local files_menu = rewards_panel:panel({
				name = "files_menu"
			})
			local locked = nil
			local unavailable = not challenge.completed
			local next_x = nil

			if challenge.reward_type == "single" then
				-- Nothing
			end

			for i, reward in ipairs(challenge.rewards) do
				local panel = files_menu:panel({
					name = tostring(i),
					x = x,
					y = self.PADDING,
					width = width - 2 * self.PADDING,
					height = rewards_panel:height() - 2 * self.PADDING
				})

				self:create_reward(panel, reward, challenge)

				x = next_x and x + next_x or panel:right() + self.PADDING
				locked = reward.rewarded

				table.insert(self._files, {
					lock = locked,
					unavailable = unavailable
				})
			end

			self._files_menu = files_menu

			self:set_file(1)
			BoxGuiObject:new(rewards_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		end

		if challenge.reward_s or challenge.reward_id then
			local reward_title_text = self._info_panel:text({
				name = "reward_title_text",
				wrap = true,
				word_wrap = true,
				blend_mode = "add",
				text = challenge.rewarded and managers.localization:to_upper_text("menu_cn_rewarded") or managers.localization:to_upper_text("menu_challenge_reward_title"),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.challenge_title
			})

			make_fine_text(reward_title_text)

			local reward_text = self._info_panel:text({
				name = "rewards_text",
				wrap = true,
				word_wrap = true,
				blend_mode = "add",
				text = challenge.reward_s or managers.localization:text(challenge.reward_id),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.text
			})

			if alive(rewards_panel) then
				reward_title_text:set_top(rewards_panel:top())
				reward_text:set_w(rewards_panel:left() - self.PADDING)
			else
				reward_title_text:set_top(y + tweak_data.menu.pd2_small_font_size)
			end

			reward_text:set_left(reward_title_text:left() + 0)
			reward_text:set_top(reward_title_text:bottom())
			reward_text:grow(-reward_text:left(), 0)

			local _, _, _, h = reward_text:text_rect()

			reward_text:set_h(h)

			y = reward_text:bottom()
		end

		if not challenge.rewarded then
			local timestamp = challenge.timestamp
			local interval = challenge.interval
			local expire_timestamp = interval + timestamp
			local current_timestamp = managers.challenge:get_timestamp()
			local expire_time = expire_timestamp - current_timestamp
			local expire_string = self:_create_timestamp_string_extended(expire_time)
			local expire_text = self._info_panel:text({
				name = "expire_text",
				alpha = 1,
				blend_mode = "add",
				text = utf8.to_upper(expire_string),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = expire_time <= 4 and tweak_data.screen_colors.important_1 or tweak_data.screen_colors.important_2
			})

			make_fine_text(expire_text)
			expire_text:set_bottom((alive(rewards_panel) and rewards_panel:top() or self._info_panel:h()) - self.PADDING)
			expire_text:set_width(self._info_panel:w())
			expire_text:set_align("center")

			local expire_bg = self._info_panel:rect({
				name = "expire_bg",
				blend_mode = "add",
				color = tweak_data.screen_colors.important_2,
				alpha = expire_time == 0 and 0.6 or expire_time <= 4 and 0.5 or 0.3
			})

			expire_bg:set_shape(expire_text:shape())

			self._expire_text = expire_text
		end
	elseif ids == Idstring("_introduction") then
		local introduction_text = self._info_panel:text({
			name = "introduction_text",
			wrap = true,
			word_wrap = true,
			blend_mode = "add",
			text = managers.localization:text("menu_challenge_introduction_desc"),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})
	elseif ids == Idstring("_summary") then
		local summary_text = self._info_panel:text({
			name = "summary_text",
			wrap = true,
			word_wrap = true,
			blend_mode = "add",
			text = managers.localization:text("menu_challenge_summary_desc"),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})
	end

	local contact_title_text = self._panel:child("contact_title_text")

	contact_title_text:set_text(utf8.to_upper(contact_title))
	make_fine_text(contact_title_text)
	contact_title_text:set_range_color(0, utf8.len(contact_title_text:text()) - utf8.len(name), tweak_data.screen_colors.challenge_title)
	contact_title_text:set_blend_mode("add")

	self._current_contact_info = id
	self._current_challenge = challenge
end

function MenuNodeCrimenetChallengeGui:update(t, dt)
	MenuNodeCrimenetChallengeGui.super.update(self, t, dt)

	if alive(self._expire_text) and self._current_challenge then
		local challenge = self._current_challenge
		local timestamp = challenge.timestamp
		local interval = challenge.interval
		local expire_timestamp = interval + timestamp
		local current_timestamp = managers.challenge:get_timestamp()
		local expire_time = expire_timestamp - current_timestamp
		local expire_string = self:_create_timestamp_string_extended(expire_time)

		self._expire_text:set_text(utf8.to_upper(expire_string))
		self._expire_text:set_color(expire_time <= 4 and tweak_data.screen_colors.important_1 or tweak_data.screen_colors.important_2)
		self._expire_text:set_alpha(expire_time == 0 and 1 or 0.9)
	end
end

function MenuNodeCrimenetChallengeGui:create_reward(panel, reward, challenge)
	local texture, texture_path, texture_rect = nil
	local is_pattern = false
	local reward_string = ""

	if reward.name_s or reward.name_id then
		reward_string = reward.name_s or managers.localization:text(reward.name_id)
	end

	local reward_panel = panel:panel({
		name = "reward_icon",
		y = tweak_data.menu.pd2_small_font_size * 0,
		h = panel:h() - tweak_data.menu.pd2_small_font_size * 1
	})

	if reward.choose_weapon_reward then
		texture_path = "guis/textures/pd2/icon_modbox_df"
		reward_string = managers.localization:text("menu_challenge_choose_weapon_mod")
	elseif #reward > 0 then
		texture_path = reward.texture_path or "guis/textures/pd2/icon_reward"
		texture_rect = reward.texture_rect
		reward_string = reward.name_s or managers.localization:text(reward.name_id or "menu_challenge_choose_reward")
	else
		local id = reward.item_entry
		local category = reward.type_items
		local td = tweak_data:get_raw_value("blackmarket", category, id)

		if td then
			local guis_catalog = "guis/"
			local bundle_folder = td.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			if category == "textures" then
				texture_path = td.texture
				is_pattern = true
			elseif category == "cash" then
				texture_path = "guis/textures/pd2/blackmarket/cash_drop"
				reward_string = managers.experience:cash_string(managers.money:get_loot_drop_cash_value(tweak_data.blackmarket[category][id].value_id))
			elseif category == "xp" then
				texture_path = "guis/textures/pd2/blackmarket/xp_drop"
				reward_string = managers.localization:text("menu_challenge_xp_drop")
			else
				if category == "weapon_mods" or category == "weapon_bonus" then
					category = "mods"
				end

				texture_path = guis_catalog .. "textures/pd2/blackmarket/icons/" .. category .. "/" .. id
				reward_string = managers.localization:text(td.name_id)
			end
		end
	end

	local color = false

	if challenge.completed and not reward.rewarded then
		local glow = panel:bitmap({
			texture = "guis/textures/pd2/hot_cold_glow",
			blend_mode = "add",
			alpha = 0,
			rotation = 360,
			layer = -1,
			w = math.min(panel:w(), panel:h()) * 1.5,
			h = math.min(panel:w(), panel:h()) * 1.5,
			color = tweak_data.screen_colors.challenge_completed_color
		})

		glow:set_center(reward_panel:center())

		local function glow_anim(o)
			local dt = nil

			while true do
				over(5, function (p)
					o:set_alpha(math.abs(math.sin(p * 360)) * 0.4)
				end)
			end
		end

		glow:animate(glow_anim)
	end

	local reward_text = panel:text({
		name = "reward_text",
		blend_mode = "add",
		rotation = 360,
		text = reward_string,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})

	make_fine_text(reward_text)
	reward_text:set_top(reward_panel:bottom() + tweak_data.menu.pd2_small_font_size * 0.5 - self.PADDING)
	reward_text:set_center_x(reward_panel:center_x())
	reward_text:set_visible(true)

	if color then
		reward_text:set_color(color)
	end

	if DB:has(Idstring("texture"), texture_path) then
		local texture_count = managers.menu_component:request_texture(texture_path, callback(self, self, "texture_done_clbk", {
			reward_panel,
			is_pattern,
			"add",
			color,
			texture_rect
		}))

		table.insert(self._requested_textures, {
			texture_count = texture_count,
			texture = texture_path
		})
	end

	panel:set_script({
		texture_path = texture_path
	})
end

function MenuNodeCrimenetChallengeGui:_highlight_row_item(row_item, mouse_over)
	MenuNodeCrimenetChallengeGui.super._highlight_row_item(self, row_item, mouse_over)

	self._highlighted_name = row_item.item and row_item.item:name()

	self:_set_file()
end

function MenuNodeCrimenetChallengeGui:set_file(index)
	MenuNodeCrimenetChallengeGui.super.super.set_file(self, index)
end

function MenuNodeCrimenetChallengeGui:_set_file()
	local files_menu = self._files_menu

	if alive(files_menu) then
		for i, file in ipairs(files_menu:children()) do
			local is_locked = self:is_file_locked(self._files[i] and self._files[i].lock)
			local is_unavailable = self:is_file_locked(self._files[i] and self._files[i].unavailable)
			local texture_alpha = is_locked and self._file_alphas.locked or is_unavailable and self._file_alphas.unavailable or i == self._current_file and self._file_alphas.selected or self._file_alphas.unselected

			file:set_alpha(texture_alpha)
			file:child("reward_text"):set_visible(not is_locked and not is_unavailable and i == self._current_file)
		end
	end
end

function MenuNodeCrimenetChallengeGui:set_empty()
end

function MenuNodeCrimenetChallengeGui:close()
	MenuNodeCrimenetChallengeGui.super.close(self)
	MenuCallbackHandler:save_progress()
end

function MenuNodeCrimenetChallengeGui:mouse_moved(o, x, y)
	if not self._info_panel:inside(x, y) then
		return
	end

	local files_menu = self._files_menu
	local is_inside = false
	local highlighted_file = nil

	if alive(files_menu) then
		local inside, inside_text = nil
		local visible_texts = {}

		for i, file in ipairs(files_menu:children()) do
			inside = file:inside(x, y)
			local is_locked = self:is_file_locked(self._files[i] and self._files[i].lock)
			local is_unavailable = self:is_file_locked(self._files[i] and self._files[i].unavailable)
			local texture_alpha = is_locked and self._file_alphas.locked or is_unavailable and self._file_alphas.unavailable or self._file_alphas and (i == self._current_file and self._file_alphas.selected or inside and self._file_alphas.mouse_over or self._file_alphas.unselected)

			if texture_alpha then
				file:set_alpha(texture_alpha)
			end

			file:child("reward_text"):set_visible(not is_locked and not is_unavailable and i == self._current_file or inside)

			if file:child("reward_text"):visible() then
				table.insert(visible_texts, file:child("reward_text"))
			end

			if inside then
				inside_text = file:child("reward_text")
				is_inside = i
				highlighted_file = self._current_file ~= i and i
			end
		end

		local texts_colliding = false

		if #visible_texts > 1 then
			for i = 1, #visible_texts - 1 do
				if visible_texts[i]:world_left() < visible_texts[i + 1]:world_right() and visible_texts[i + 1]:world_left() < visible_texts[i]:world_right() then
					texts_colliding = true

					break
				end
			end

			if texts_colliding then
				for i, text in ipairs(visible_texts) do
					text:hide()
				end

				if inside_text then
					inside_text:show()
				elseif self._current_file then
					files_menu[self._current_file]:child("reward_text"):show()
				end
			end
		end
	end

	if highlighted_file and self._highlighted_file ~= highlighted_file then
		managers.menu_component:post_event("highlight")

		self._highlighted_file = highlighted_file

		if self._set_file_on_mouse_over then
			self:set_file(self._highlighted_file)
		end
	elseif not highlighted_file then
		self._highlighted_file = false
	end

	local is_locked = is_inside and (self:is_file_locked(self._files[is_inside] and self._files[is_inside].lock) or self:is_file_locked(self._files[is_inside] and self._files[is_inside].unavailable))

	return is_inside, self._file_pressed and (self._file_pressed == is_inside and not is_locked and "link" or "arrow") or is_inside and not is_locked and "link" or "arrow"
end

function MenuNodeCrimenetChallengeGui:mouse_pressed(button, x, y)
	local files_menu = self._files_menu

	if alive(files_menu) then
		for i, file in ipairs(files_menu:children()) do
			if file:inside(x, y) and not self:is_file_locked(self._files[i].lock) and not self:is_file_locked(self._files[i].unavailable) then
				self._file_pressed = i

				self:set_file(self._file_pressed)
				managers.menu_component:post_event("highlight")

				return
			end
		end
	end

	self._file_pressed = false
end

function MenuNodeCrimenetChallengeGui:mouse_released(button, x, y)
	if self._file_pressed and self._file_pressed == self._current_file then
		local files_menu = self._files_menu

		if alive(files_menu) and button == Idstring("0") then
			local file = files_menu:children()[self._file_pressed]

			if file and file:inside(x, y) then
				if self._confirm_reward then
					local rewards_panel = self._info_panel:child("rewards_panel")
					local files_menu = rewards_panel:child("files_menu")
					local reward = files_menu:child(tostring(self._file_pressed))

					if reward and reward:child("reward_text") then
						local file_pressed = self._file_pressed
						local params = {
							reward = reward:child("reward_text"):text(),
							image = reward:has_script() and reward:script().texture_path,
							yes_func = function ()
								self:claim_reward(file_pressed)
							end
						}

						managers.menu:show_challenge_warn_choose_reward(params)
					end
				else
					self:claim_reward(self._file_pressed)
				end
			end
		end
	end

	self._file_pressed = false
end

function MenuNodeCrimenetChallengeGui:claim_reward(index)
	local reward = managers.challenge:on_give_reward(self._current_contact_info, nil, index)

	if reward then
		if reward.choose_weapon_reward then
			managers.menu:open_node("choose_weapon_reward")
		else
			managers.menu:show_challenge_reward(reward)
		end
	end
end

function MenuNodeCrimenetChallengeGui:special_btn_pressed(button)
	if button == Idstring("menu_challenge_claim") then
		self:claim_reward(self._current_file)
	end
end

function MenuNodeCrimenetChallengeGui:refresh_gui(node)
	if not self._init_finish then
		return
	end

	if self._back_row_item and alive(self._back_row_item.gui_pd2_panel) then
		self._back_row_item.gui_pd2_panel:parent():remove(self._back_row_item.gui_pd2_panel)

		self._back_row_item = nil
	end

	local old_menu_unslected_lefts = {}
	local old_menu_unslected_tops = {}

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.menu_unselected) then
			old_menu_unslected_lefts[_] = row_item.menu_unselected:left()
			old_menu_unslected_tops[_] = row_item.menu_unselected:top()
		end
	end

	local old_y = self.item_panel:world_y()

	self:_clear_gui()
	self:_setup_panels(node)
	self:_setup_item_rows(node)
	self:_set_item_positions()
	self:_set_topic_position()
	self:update_item_icon_visibility()

	local row_x = 0

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.icon) then
			row_item.icon:set_left(0)
		end

		if alive(row_item.menu_unselected) then
			if old_menu_unslected_lefts[_] then
				row_item.menu_unselected:set_left(old_menu_unslected_lefts[_])
			end

			if old_menu_unslected_tops[_] then
				row_item.menu_unselected:set_top(old_menu_unslected_tops[_])
			end
		end

		if alive(row_item.gui_panel) then
			row_x = math.max(row_x, row_item.gui_panel:world_x())
		end
	end

	local selected_item = self._current_contact_info and node:item(self._current_contact_info)

	if selected_item then
		local parameters = selected_item:parameters() or {}
		local id = parameters.name
		local name_id = parameters.text_id
		local files = parameters.files

		self:set_contact_info(id, name_id, files, 1)
	else
		self:set_contact_info()
	end

	self.item_panel:set_world_y(old_y)
	managers.menu_component:disable_crimenet()
end

function MenuNodeCrimenetChallengeGui:_align_marker(row_item)
	MenuNodeCrimenetChallengeGui.super._align_marker(self, row_item)

	if row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_visible(true)
		self._marker_data.gradient:set_visible(true)
		self._marker_data.gradient:set_rotation(360)
		self._marker_data.marker:set_height(64 * row_item.gui_text:height() / 32)
		self._marker_data.gradient:set_height(64 * row_item.gui_text:height() / 32)
		self._marker_data.marker:set_w(self.MENU_WIDTH)
		self._marker_data.gradient:set_w(self._marker_data.marker:w())
		self._marker_data.marker:set_left(row_item.menu_unselected:x())
		self._marker_data.marker:set_world_center_y(row_item.gui_text:world_center_y())
		self._marker_data.marker:set_y(math.round(self._marker_data.marker:y()))

		return
	end
end

function MenuNodeCrimenetChallengeGui:_clear_gui()
	local to = #self.row_items

	for i = 1, to do
		local row_item = self.row_items[i]

		if alive(row_item.gui_panel) then
			row_item.gui_panel:parent():remove(row_item.gui_panel)

			row_item.gui_panel = nil

			if alive(row_item.menu_unselected) then
				row_item.menu_unselected:parent():remove(row_item.menu_unselected)

				row_item.menu_unselected = nil
			end
		end

		if alive(row_item.gui_info_panel) then
			self.safe_rect_panel:remove(row_item.gui_info_panel)
		end

		if alive(row_item.icon) then
			row_item.icon:parent():remove(row_item.icon)
		end

		self.row_items[i] = nil
	end

	self._list_arrows.up:parent():remove(self._list_arrows.up)
	self._list_arrows.down:parent():remove(self._list_arrows.down)
	self.item_panel:clear()

	self.row_items = {}
end

function MenuNodeCrimenetChallengeGui:_setup_item_panel_parent(safe_rect, shape)
	local x = safe_rect.x + safe_rect.width / 2 - self.WIDTH / 2 + self.PADDING
	local y = safe_rect.y + safe_rect.height / 2 - self.HEIGHT / 2 + self.PADDING
	shape = shape or {}
	shape.x = shape.x or x
	shape.y = shape.y or y
	shape.w = shape.w or self.MENU_WIDTH
	shape.h = shape.h or self.HEIGHT - 2 * self.PADDING - tweak_data.menu.pd2_small_font_size

	MenuNodeCrimenetChallengeGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeCrimenetChallengeGui:_setup_menu()
	if not self._init_finish then
		return
	end

	local safe_rect = managers.gui_data:scaled_size()

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("right")
	end

	self:_set_topic_position()
	self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions) + 4)
	self.item_panel:set_world_position(self._panel:world_position())
	self.item_panel:move(self.PADDING, self.PADDING)

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("left")
	end

	self.item_panel:set_w(self.MENU_WIDTH)
	self._align_data.panel:set_left(self.item_panel:left())
	self:update_item_icon_visibility()

	local row_x = 0

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.icon) then
			row_item.icon:set_left(0)
		end

		if alive(row_item.gui_panel) then
			row_x = math.max(row_x, row_item.gui_panel:world_x())
		end
	end

	if self._back_row_item and alive(self._back_row_item.gui_text) then
		self._back_row_item.gui_text:set_w(self.MENU_WIDTH)
		self._back_row_item.gui_text:set_world_left(math.round(self._panel:world_left() + self.PADDING * 2))
		self._back_row_item.gui_text:set_world_bottom(math.round(self._panel:world_bottom() - self.PADDING))
	end

	for _, row_item in pairs(self.row_items) do
		if alive(row_item.gui_panel) then
			row_item.gui_panel:set_w(self.MENU_WIDTH)
		end
	end

	for _, child in ipairs(self.item_panel:children()) do
		child:set_world_y(math.round(child:world_y()))
	end

	self._list_arrows.up:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.up:set_world_top(self._align_data.panel:world_top())
	self._list_arrows.up:set_width(self._item_panel_parent:w())
	self._list_arrows.down:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.down:set_world_bottom(self._align_data.panel:world_bottom())
	self._list_arrows.down:set_width(self._item_panel_parent:w())
end

MenuNodeChooseWeaponRewardGui = MenuNodeChooseWeaponRewardGui or class(MenuNodeCrimenetFiltersGui)

function MenuNodeChooseWeaponRewardGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true
	self.static_y = node:parameters().static_y

	MenuNodeChooseWeaponRewardGui.super.init(self, node, layer, parameters)

	if alive(self.item_panel:parent():child("special_title_text")) then
		self.item_panel:parent():remove(self.item_panel:parent():child("special_title_text"))
	end

	local title_text = self.item_panel:parent():text({
		name = "special_title_text",
		blend_mode = "add",
		layer = 51,
		text = managers.localization:to_upper_text("menu_challenge_claim_reward_title"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(title_text)
	title_text:set_left(self.box_panel:left())
	title_text:set_bottom(self.box_panel:top())
end

function MenuNodeChooseWeaponRewardGui:_setup_item_panel(safe_rect, res)
	MenuNodeChooseWeaponRewardGui.super._setup_item_panel(self, safe_rect, res)

	local max_layer = 10000
	local min_layer = 0
	local child_layer = 0

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("right")

		child_layer = child:layer()

		if child_layer > 0 then
			min_layer = math.min(min_layer, child_layer)
		end

		max_layer = math.max(max_layer, child_layer)
	end

	for _, child in ipairs(self.item_panel:children()) do
		-- Nothing
	end

	self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions))
	self.item_panel:set_center(self.item_panel:parent():w() / 2, self.item_panel:parent():h() / 2)

	local static_y = self.static_y and safe_rect.height * self.static_y

	if static_y and static_y < self.item_panel:y() then
		self.item_panel:set_y(static_y)
	end

	self.item_panel:set_position(math.round(self.item_panel:x()), math.round(self.item_panel:y()))
	round_gui_object(self.item_panel)

	if alive(self.box_panel) then
		self.item_panel:parent():remove(self.box_panel)

		self.box_panel = nil
	end

	self.box_panel = self.item_panel:parent():panel()

	self.box_panel:set_x(self.item_panel:x())
	self.box_panel:set_w(self.item_panel:w())

	if self._align_data.panel:h() < self.item_panel:h() then
		self.box_panel:set_y(0)
		self.box_panel:set_h(self.item_panel:parent():h())
	else
		self.box_panel:set_y(self.item_panel:top())
		self.box_panel:set_h(self.item_panel:h())
	end

	self.box_panel:grow(116, 20)
	self.box_panel:move(-106, -10)
	self.box_panel:set_layer(51)

	self.boxgui = BoxGuiObject:new(self.box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self.boxgui:set_clipping(false)
	self.boxgui:set_layer(1000)
	self.box_panel:rect({
		rotation = 360,
		color = tweak_data.screen_colors.dark_bg
	})
	self._align_data.panel:set_left(self.box_panel:left())
	self._list_arrows.up:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.up:set_world_top(self._align_data.panel:world_top() - 10)
	self._list_arrows.up:set_width(self.box_panel:width())
	self._list_arrows.up:set_rotation(360)
	self._list_arrows.up:set_layer(1050)
	self._list_arrows.down:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.down:set_world_bottom(self._align_data.panel:world_bottom() + 10)
	self._list_arrows.down:set_width(self.box_panel:width())
	self._list_arrows.down:set_rotation(360)
	self._list_arrows.down:set_layer(1050)
	self:_set_topic_position()

	local icon = self.box_panel:bitmap({
		blend_mode = "add",
		texture = "guis/textures/pd2/icon_modbox_df",
		h = 96,
		w = 96,
		layer = 1
	})

	icon:set_position(10, 10)

	local droppable_parts = managers.blackmarket:get_lootdropable_mods_by_weapon_id(self.node:parameters().listed_weapon, self.node:parameters().listed_global_value, true)
	local count = 0
	local inv_count = 0

	for _, part_data in ipairs(droppable_parts) do
		count = count + 1

		if managers.blackmarket:get_item_amount(part_data[2], "weapon_mods", part_data[1], true) ~= 0 then
			inv_count = inv_count + 1
		end
	end

	self._owned_text = self.box_panel:text({
		blend_mode = "add",
		text = managers.localization:to_upper_text("menu_challenge_num_owned_mods", {
			inv_count = tostring(inv_count),
			count = tostring(count)
		}),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})

	make_fine_text(self._owned_text)
end

function MenuNodeChooseWeaponRewardGui:_reposition_items(highlighted_row_item)
	MenuNodeChooseWeaponRewardGui.super._reposition_items(self, highlighted_row_item)

	if alive(self._owned_text) then
		self._owned_text:set_world_top(self.row_items[3].gui_text:world_bottom())
		self._owned_text:set_world_left(self.row_items[3].gui_text:world_left())
	end
end

MenuNodeChooseWeaponCosmeticGui = MenuNodeChooseWeaponCosmeticGui or class(MenuNodeCrimenetFiltersGui)

function MenuNodeChooseWeaponCosmeticGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true
	self.static_y = node:parameters().static_y

	MenuNodeChooseWeaponCosmeticGui.super.init(self, node, layer, parameters)
end

function MenuNodeChooseWeaponCosmeticGui:_setup_item_panel(safe_rect, res)
	MenuNodeChooseWeaponCosmeticGui.super._setup_item_panel(self, safe_rect, res)

	local max_layer = 10000
	local min_layer = 0
	local child_layer = 0

	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("right")

		child_layer = child:layer()

		if child_layer > 0 then
			min_layer = math.min(min_layer, child_layer)
		end

		max_layer = math.max(max_layer, child_layer)
	end

	for _, child in ipairs(self.item_panel:children()) do
		-- Nothing
	end

	self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions))
	self.item_panel:set_right(self.item_panel:parent():w() - 10)
	self.item_panel:set_top(103)

	local static_y = self.static_y and safe_rect.height * self.static_y

	if static_y and static_y < self.item_panel:y() then
		self.item_panel:set_y(static_y)
	end

	self.item_panel:set_position(math.round(self.item_panel:x()), math.round(self.item_panel:y()))
	round_gui_object(self.item_panel)

	if alive(self.box_panel) then
		self.item_panel:parent():remove(self.box_panel)

		self.box_panel = nil
	end

	self.box_panel = self.item_panel:parent():panel()

	self.box_panel:set_x(self.item_panel:x())
	self.box_panel:set_w(self.item_panel:w())

	if self._align_data.panel:h() < self.item_panel:h() then
		self.box_panel:set_y(0)
		self.box_panel:set_h(self.item_panel:parent():h())
	else
		self.box_panel:set_y(self.item_panel:top())
		self.box_panel:set_h(self.item_panel:h())
	end

	self.box_panel:grow(20, 20)
	self.box_panel:move(-10, -10)
	self.box_panel:set_layer(51)

	self.boxgui = BoxGuiObject:new(self.box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self.boxgui:set_clipping(false)
	self.boxgui:set_layer(1000)
	self.box_panel:rect({
		rotation = 360,
		color = tweak_data.screen_colors.dark_bg
	})

	if alive(self.blur_panel) then
		self.item_panel:parent():remove(self.blur_panel)

		self.blur_panel = nil
	end

	self.blur_panel = self.item_panel:parent():panel()
	local blur = self.blur_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self.box_panel:w(),
		h = self.blur_panel:h() - 70 - self.box_panel:top()
	})

	blur:set_top(self.box_panel:top())
	blur:set_left(self.box_panel:left())

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	blur:animate(func)

	local blur2 = self.blur_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self.blur_panel:w() - blur:width(),
		h = self.blur_panel:h() / 4
	})

	blur2:set_bottom(blur:bottom())
	blur2:set_left(0)
	blur2:animate(func)
	self.blur_panel:set_layer(50)
	self._align_data.panel:set_left(self.box_panel:left())
	self._list_arrows.up:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.up:set_world_top(self._align_data.panel:world_top() - 10)
	self._list_arrows.up:set_width(self.box_panel:width())
	self._list_arrows.up:set_rotation(360)
	self._list_arrows.up:set_layer(1050)
	self._list_arrows.down:set_world_left(self._align_data.panel:world_left())
	self._list_arrows.down:set_world_bottom(self._align_data.panel:world_bottom() + 10)
	self._list_arrows.down:set_width(self.box_panel:width())
	self._list_arrows.down:set_rotation(360)
	self._list_arrows.down:set_layer(1050)
	self:_set_topic_position()
end

function MenuNodeChooseWeaponCosmeticGui:_reposition_items(highlighted_row_item)
	MenuNodeChooseWeaponCosmeticGui.super._reposition_items(self, highlighted_row_item)

	if alive(self._owned_text) then
		self._owned_text:set_world_top(self.row_items[3].gui_text:world_bottom())
		self._owned_text:set_world_left(self.row_items[3].gui_text:world_left())
	end
end

function MenuNodeChooseWeaponCosmeticGui:close(...)
	MenuNodeEconomySafe.super.close(self, ...)
	managers.environment_controller:set_dof_distance(10, false)
end

MenuNodeDOFGui = MenuNodeDOFGui or class(MenuNodeGui)

function MenuNodeDOFGui:init(...)
	MenuNodeDOFGui.super.init(self, ...)
	managers.environment_controller:set_dof_setting("standard")
	managers.environment_controller:set_dof_distance(100, true)
end

function MenuNodeDOFGui:close(...)
	MenuNodeDOFGui.super.close(self, ...)
	managers.environment_controller:set_dof_distance(10, false)
end

MenuNodeOpenContainerGui = MenuNodeOpenContainerGui or class(MenuNodeBaseGui)

function MenuNodeOpenContainerGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.halign = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true

	MenuNodeOpenContainerGui.super.init(self, node, layer, parameters)
end

function MenuNodeOpenContainerGui:refresh_gui(...)
	MenuNodeOpenContainerGui.super.refresh_gui(self, ...)
	self:setup(true)
end

function MenuNodeOpenContainerGui:setup(half_fade)
	local container_data = self.node:parameters().container_data

	if not container_data or not tweak_data.economy.contents[container_data.content] then
		managers.menu:back()

		return
	end

	local drill_amount = managers.blackmarket:get_inventory_tradable_item_amount("drills", container_data.drill)
	local safe_amount = managers.blackmarket:get_inventory_tradable_item_amount("safes", container_data.safe)
	local padding = 10
	local content_padding = 1

	if self._drill_amount == drill_amount and self._safe_amount == safe_amount and container_data.content == self._content then
		self.item_panel:set_world_left(self._safe_panel:world_right() + padding - self.node:parameters().align_line_proportions * self.item_panel:w())
		self.item_panel:set_world_center_y(self._safe_panel:world_center_y())

		return
	end

	self:unretrieve_textures()
	MenuNodeOpenContainerGui.super.setup(self)

	self._drill_amount = drill_amount
	self._safe_amount = safe_amount
	local content_td = tweak_data.economy.contents[container_data.content]

	if alive(self.safe_rect_panel:child("open_safe_panel")) then
		self.safe_rect_panel:remove(self.safe_rect_panel:child("open_safe_panel"))
	end

	if alive(self.safe_rect_panel:child("info_panel")) then
		self.safe_rect_panel:remove(self.safe_rect_panel:child("info_panel"))
	end

	if alive(self._fullscreen_panel) then
		self._fullscreen_panel:parent():remove(self._fullscreen_panel)
	end

	self._content = container_data.content
	self._panel = self.safe_rect_panel:panel({
		layer = 151,
		name = "open_safe_panel"
	})
	local safe_w = self._panel:w() - 20 - 40
	local safe_h = self._panel:h() - 20 - 40
	local wanted_width = (3 * safe_h - padding) / 2.5
	local wanted_height = (2.5 * safe_w + padding) / 3
	local w = safe_w
	local h = safe_h
	w = wanted_width
	h = (2.5 * wanted_width + padding) / 3
	local mc_full_ws = managers.menu_component:fullscreen_ws()
	self._fullscreen_panel = mc_full_ws:panel():panel({
		layer = 150,
		name = "open_contatiner"
	})
	local bg = self._fullscreen_panel:rect({
		alpha = 0,
		color = Color.black
	})

	bg:animate(function (o)
		over(0.25, function (p)
			o:set_alpha(math.sin(p * 90) * 0.5 * (half_fade and 0.5 or 1) + (half_fade and 0.25 or 0))
		end)
	end)
	self._panel:animate(function (o)
		over(0.15, function (p)
			o:set_alpha(math.sin(p * 90) * (half_fade and 0.5 or 1) + (half_fade and 0.5 or 0))
		end)
	end)
	self._panel:set_size(w + 20, h + 20)
	self._panel:set_center(self.safe_rect_panel:w() / 2, self.safe_rect_panel:h() / 2)

	local info_panel = self.safe_rect_panel:panel({
		name = "info_panel",
		layer = 151,
		w = (safe_w - w) * 0.75,
		h = self._panel:h()
	})

	info_panel:set_right(self.safe_rect_panel:w())
	info_panel:set_top(self._panel:top())
	self._panel:set_right(info_panel:left() - 10)

	self.boxgui = BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._panel:rect({
		alpha = 0.6,
		color = Color.black
	})

	local data = self.node:parameters().container_data
	local panel = self._panel:panel({
		y = 10,
		x = 10,
		layer = 1,
		w = self._panel:w() - 20,
		h = self._panel:h() - 20
	})
	self._legend_panel = panel:panel({
		h = tweak_data.menu.pd2_medium_font_size
	})
	local title_text = container_data.show_only and managers.localization:to_upper_text("menu_steam_market_content_" .. container_data.content) or managers.localization:to_upper_text("menu_ti_steam_open_safe_title", {
		name = managers.localization:text(tweak_data.economy.safes[data.safe].name_id),
		type = managers.localization:text("bm_menu_safe")
	})
	local title = panel:text({
		text = title_text,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})

	managers.menu_component:add_colors_to_text_object(title, unpack({
		tweak_data.screen_colors.text,
		tweak_data.screen_colors.text
	}))

	local content_height = w / 2
	local drill_safe_size = h - content_height - padding

	if not tweak_data.economy.safes[container_data.safe].free then
		local drill_panel = panel:panel({
			name = "drill",
			w = drill_safe_size,
			h = drill_safe_size
		})
		local td = tweak_data.economy.drills[container_data.drill]
		local guis_catalog = "guis/"
		local bundle_folder = td.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		local path = "drills/"
		local bitmap_texture = guis_catalog .. path .. container_data.drill
		local drill_bitmap_panel = drill_panel:panel()

		drill_bitmap_panel:set_size(drill_panel:width() * 0.65, drill_panel:height() * 0.65)
		drill_bitmap_panel:set_center(drill_panel:width() / 2, drill_panel:width() / 2)

		local blend_mode = "add"

		if not managers.blackmarket:have_inventory_tradable_item("drills", data.drill) then
			drill_bitmap_panel:set_alpha(0.5)

			local blend_mode = "add"
		end

		self:request_texture(bitmap_texture, drill_bitmap_panel, true, blend_mode)

		local amount_text = drill_panel:text({
			text = "x" .. tostring(drill_amount),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size
		})

		make_fine_text(amount_text)
		amount_text:set_center_x(drill_panel:w() / 2)
		amount_text:set_bottom(drill_panel:h() - 10)
	end

	local safe_panel = panel:panel({
		name = "safe",
		w = drill_safe_size,
		h = drill_safe_size
	})

	safe_panel:set_center_x(panel:w() / 2)

	self._safe_panel = safe_panel
	local td = tweak_data.economy.safes[container_data.safe]
	local guis_catalog = "guis/"
	local bundle_folder = td.texture_bundle_folder

	if bundle_folder then
		guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
	end

	local path = "safes/"
	local bitmap_texture = guis_catalog .. path .. container_data.safe
	local safe_bitmap_panel = safe_panel:panel()

	safe_bitmap_panel:set_size(safe_panel:width() * 0.8, safe_panel:height() * 0.8)
	safe_bitmap_panel:set_center(safe_panel:width() / 2, safe_panel:width() / 2)
	self:request_texture(bitmap_texture, safe_bitmap_panel, true, "add")

	local amount_text = safe_panel:text({
		text = "x" .. tostring(safe_amount),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})

	make_fine_text(amount_text)
	amount_text:set_center_x(safe_panel:w() / 2)
	amount_text:set_bottom(safe_panel:h() - 10)

	if container_data.active_market_bundle then
		local is_pc_controller = managers.menu:is_pc_controller()
		local is_steam_controller = managers.menu:is_steam_controller()
		local prev_button = is_steam_controller and managers.localization:steam_btn("bumper_l") or is_pc_controller and "<" or managers.localization:get_default_macro("BTN_BOTTOM_L")
		local next_button = is_steam_controller and managers.localization:steam_btn("bumper_r") or is_pc_controller and ">" or managers.localization:get_default_macro("BTN_BOTTOM_R")
		local prev_panel = safe_panel:panel({
			name = "prev_panel"
		})
		local next_panel = safe_panel:panel({
			name = "next_panel"
		})
		local prev_text = prev_panel:text({
			name = "prev_text",
			text = prev_button,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size
		})
		local next_text = next_panel:text({
			name = "next_text",
			text = next_button,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size
		})
		local color = managers.menu:is_pc_controller() and tweak_data.screen_colors.button_stage_3 or Color.white

		prev_text:set_color(color)
		next_text:set_color(color)
		make_fine_text(prev_text)
		make_fine_text(next_text)
		prev_panel:set_size(prev_text:size())
		next_panel:set_size(next_text:size())
		prev_panel:set_lefttop(0, safe_bitmap_panel:y() + 10)
		next_panel:set_righttop(safe_panel:w(), safe_bitmap_panel:y() + 10)

		if is_pc_controller then
			table.insert(self._text_buttons, {
				highlighted = false,
				panel = prev_panel,
				text = prev_text,
				clbk = callback(self, self, "prev_container"),
				highlighted_color = tweak_data.screen_colors.button_stage_2,
				default_color = tweak_data.screen_colors.button_stage_3,
				params = {}
			})
			table.insert(self._text_buttons, {
				highlighted = false,
				panel = next_panel,
				text = next_text,
				clbk = callback(self, self, "next_container"),
				highlighted_color = tweak_data.screen_colors.button_stage_2,
				default_color = tweak_data.screen_colors.button_stage_3,
				params = {}
			})
		end
	end

	local contents = {}

	for category, content_data in pairs(content_td.contains) do
		for _, entry in ipairs(content_data) do
			table.insert(contents, {
				category = category,
				entry = entry
			})
		end
	end

	local x_td, y_td, x_rtd, y_rtd = nil

	local function sort_func(x, y)
		x_td = (x.category == "weapon_skins" and tweak_data.blackmarket.weapon_skins or tweak_data.economy[x.category])[x.entry]
		y_td = (y.category == "weapon_skins" and tweak_data.blackmarket.weapon_skins or tweak_data.economy[y.category])[y.entry]
		x_rtd = tweak_data.economy.rarities[x_td.rarity or "common"]
		y_rtd = tweak_data.economy.rarities[y_td.rarity or "common"]

		if x_rtd.index ~= y_rtd.index then
			return x_rtd.index < y_rtd.index
		end

		return x.entry < y.entry
	end

	table.sort(contents, sort_func)

	local content_panel = panel:panel({
		name = "content",
		h = content_height
	})

	content_panel:set_top(safe_panel:bottom() + padding)

	local num_of_items = #contents
	local num_per_row = math.ceil(num_of_items^0.5)
	local size = (content_panel:w() - (num_per_row + 1) * content_padding) / num_per_row
	local x = content_padding
	local y = content_padding
	local new_content, c_td = nil

	for i, content in ipairs(contents) do
		local is_weapon_skin = content.category == "weapon_skins"
		local show_skins = is_weapon_skin
		local is_armor_skin = content.category == "armor_skins"
		show_skins = show_skins or is_armor_skin
		c_td = (content.category == "weapon_skins" and tweak_data.blackmarket.weapon_skins or tweak_data.economy[content.category])[content.entry]
		new_content = content_panel:panel({
			layer = 1,
			name = i,
			x = x,
			y = y,
			w = size,
			h = size / 2
		})

		if is_weapon_skin or is_armor_skin then
			local texture_path, rarity_path = nil

			if is_weapon_skin then
				texture_path, rarity_path = managers.blackmarket:get_weapon_icon_path(managers.blackmarket:get_weapon_id_by_cosmetic_id(content.entry), {
					id = content.entry
				})

				self:request_texture(texture_path, new_content, true)
			elseif is_armor_skin then
				local guis_catalog = "guis/"
				local bundle_folder = c_td.texture_bundle_folder

				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				texture_path = guis_catalog .. "armor_skins/" .. content.entry
				rarity_path = managers.blackmarket:get_cosmetic_rarity_bg(c_td.rarity or "common")
				local scale = 0.7
				local armor_panel = new_content:panel({
					w = new_content:w() * scale,
					h = new_content:h() * scale
				})

				armor_panel:set_center(new_content:w() * 0.5, new_content:h() * 0.5)
				self:request_texture(texture_path, armor_panel, true)
			end

			local rarity_bitmap = new_content:bitmap({
				blend_mode = "add",
				layer = -1,
				name = i .. "_bg",
				texture = rarity_path,
				x = x,
				y = y
			})
			local texture_width = rarity_bitmap:texture_width()
			local texture_height = rarity_bitmap:texture_height()
			local panel_width = new_content:w()
			local panel_height = new_content:h()
			local tw = texture_width
			local th = texture_height
			local pw = panel_width
			local ph = panel_height

			if tw == 0 or th == 0 then
				Application:error("[MenuNodeOpenContainerGui] BG Texture size error!:", "width", tw, "height", th)

				tw = 1
				th = 1
			end

			local sw = math.min(pw, ph * tw / th)
			local sh = math.min(ph, pw / (tw / th))

			rarity_bitmap:set_size(math.round(sw), math.round(sh))
			rarity_bitmap:set_center(new_content:w() * 0.5, new_content:h() * 0.5)

			local select_box_panel = new_content:panel()
			local select_box = BoxGuiObject:new(select_box_panel, {
				sides = {
					2,
					2,
					2,
					2
				}
			})

			select_box:set_color(Color(0, 0, 0, 0))

			if is_weapon_skin then
				table.insert(self._text_buttons, {
					highlighted = false,
					panel = new_content,
					clbk = callback(self, self, "weapon_cosmetics_callback"),
					image = select_box,
					highlighted_color = Color(1, 1, 1),
					default_color = Color(0, 0, 0, 0),
					params = {
						quality = "mint",
						weapon_id = managers.blackmarket:get_weapon_id_by_cosmetic_id(content.entry),
						cosmetic_id = content.entry
					}
				})
			elseif is_armor_skin then
				table.insert(self._text_buttons, {
					highlighted = false,
					panel = new_content,
					clbk = callback(self, self, "armor_cosmetics_callback"),
					image = select_box,
					highlighted_color = Color(1, 1, 1),
					default_color = Color(0, 0, 0, 0),
					params = {
						armor = true,
						cosmetic_id = content.entry
					}
				})
			end
		elseif content.category == "contents" and c_td.rarity == "legendary" then
			self:request_texture(content.texture_path or "guis/dlcs/cash/textures/pd2/safe_raffle/icon_legendary", new_content, true)
		end

		x = i % num_per_row * size + content_padding * (i % num_per_row + 1)
		y = math.floor(i / num_per_row) * size / 2 + content_padding / 2 * (math.floor(i / num_per_row) + 1)
	end

	local divider_panel = panel:panel({
		h = 4,
		name = "divider_panel"
	})

	divider_panel:set_top(safe_panel:bottom() + padding)
	BoxGuiObject:new(divider_panel, {
		sides = {
			0,
			0,
			2,
			0
		}
	})
	self.item_panel:set_world_left(safe_panel:world_right() + padding - self.node:parameters().align_line_proportions * self.item_panel:w())
	self.item_panel:set_world_center_y(safe_panel:world_center_y())
	info_panel:set_world_top(content_panel:world_top())
	info_panel:set_h(self._panel:bottom() - info_panel:top())
	info_panel:rect({
		alpha = 0.6,
		color = Color.black
	})
	BoxGuiObject:new(info_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._info_panel = info_panel:panel({
		y = 10,
		x = 10,
		layer = 1,
		w = info_panel:w() - 20,
		h = info_panel:h() - 2
	})
end

function MenuNodeOpenContainerGui:update_info(button)
	if button == self._selected_button then
		return
	end

	self._selected_button = button

	self._info_panel:clear()

	if button then
		if button.params.weapon_id then
			local title_text = self._info_panel:text({
				wrap = true,
				blend_mode = "add",
				wrap_word = true,
				text = utf8.to_upper(managers.weapon_factory:get_weapon_name_by_weapon_id(button.params.weapon_id)) .. " | " .. managers.localization:to_upper_text(tweak_data.blackmarket.weapon_skins[button.params.cosmetic_id].name_id),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.economy.rarities[tweak_data.blackmarket.weapon_skins[button.params.cosmetic_id].rarity].color
			})

			make_fine_text(title_text)

			local desc, colors = InventoryDescription.create_description_item({
				instance_id = 0,
				category = "weapon_skins",
				entry = button.params.cosmetic_id
			}, tweak_data.blackmarket.weapon_skins[button.params.cosmetic_id], {
				default = tweak_data.screen_colors.text,
				mods = tweak_data.screen_colors.text
			}, true)
			local desc_text = self._info_panel:text({
				wrap = true,
				word_wrap = true,
				blend_mode = "add",
				text = desc,
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.text
			})

			managers.menu_component:add_colors_to_text_object(desc_text, unpack(colors))
			make_fine_text(desc_text)
			desc_text:set_top(title_text:bottom() + 5)
		elseif button.params.armor then
			local c_td = tweak_data.economy.armor_skins[button.params.cosmetic_id]
			local title_text = self._info_panel:text({
				wrap = true,
				blend_mode = "add",
				wrap_word = true,
				text = utf8.to_upper(managers.localization:to_upper_text(c_td.name_id)),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.economy.rarities[c_td.rarity].color
			})

			make_fine_text(title_text)

			local desc, colors = InventoryDescription.create_description_item({
				instance_id = 0,
				category = "armor_skins",
				entry = button.params.cosmetic_id
			}, c_td, {
				default = tweak_data.screen_colors.text,
				mods = tweak_data.screen_colors.text
			}, true)
			local desc_text = self._info_panel:text({
				wrap = true,
				word_wrap = true,
				blend_mode = "add",
				text = desc,
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.text
			})

			managers.menu_component:add_colors_to_text_object(desc_text, unpack(colors))
			make_fine_text(desc_text)
			desc_text:set_top(title_text:bottom() + 5)
		end
	end

	self:update_legends(button)
end

function MenuNodeOpenContainerGui:update_legends(button)
	self._legend_panel:clear()

	if button then
		local show_preview, show_search = nil

		if button.params.weapon_id then
			show_preview = true
			show_search = true
		elseif button.params.armor then
			show_preview = false
			show_search = true
		end

		local preview_text, preview_icon, search_text, search_icon = nil

		if show_preview then
			preview_text = self._legend_panel:text({
				text = managers.localization:to_upper_text("menu_mouse_preview"),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.text
			})

			make_fine_text(preview_text)

			preview_icon = self._legend_panel:bitmap({
				texture = "guis/textures/pd2/mouse_buttons",
				name = "icon",
				h = 23,
				blend_mode = "add",
				w = 17,
				texture_rect = {
					18,
					1,
					17,
					23
				}
			})

			preview_text:set_right(self._legend_panel:w())
			preview_icon:set_right(preview_text:left())
		end

		if show_search then
			search_text = self._legend_panel:text({
				text = managers.localization:to_upper_text("menu_mouse_search_market"),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.text
			})

			make_fine_text(search_text)

			search_icon = self._legend_panel:bitmap({
				texture = "guis/textures/pd2/mouse_buttons",
				name = "icon",
				h = 23,
				blend_mode = "add",
				w = 17,
				texture_rect = {
					1,
					1,
					17,
					23
				}
			})

			search_text:set_right(show_preview and preview_icon:left() - 4 or self._legend_panel:w())
			search_icon:set_right(search_text:left())
		end
	end
end

function MenuNodeOpenContainerGui:weapon_cosmetics_callback(button, data)
	if button == Idstring("1") then
		managers.blackmarket:view_weapon_platform_with_cosmetics(data.weapon_id, {
			id = data.cosmetic_id,
			quality = data.cosmetic_quality
		}, function ()
			managers.menu:open_node("inventory_tradable_container_preview_node", {
				{
					id = data.cosmetic_id,
					quality = data.cosmetic_quality
				}
			})
			managers.menu_component:hide_blackmarket_gui()
		end)
	elseif button == Idstring("0") then
		MenuCallbackHandler:steam_find_item_from_community(nil, data)
	end
end

function MenuNodeOpenContainerGui:armor_cosmetics_callback(button, data)
	if button == Idstring("1") then
		-- Nothing
	elseif button == Idstring("0") then
		MenuCallbackHandler:steam_find_item_from_community(nil, data)
	end
end

function MenuNodeOpenContainerGui:prev_container()
	local data = self.node:parameters().container_data
	local market_bundle = data.active_market_bundle - 1

	if market_bundle == 0 then
		market_bundle = data.num_bundles
	end

	self:open_container(market_bundle)
end

function MenuNodeOpenContainerGui:next_container()
	local data = self.node:parameters().container_data
	local market_bundle = data.active_market_bundle % data.num_bundles + 1

	self:open_container(market_bundle)
end

function MenuNodeOpenContainerGui:open_container(market_bundle)
	local data = self.node:parameters().container_data
	local active_bundle = data.market_bundles[market_bundle]
	data.content = active_bundle.content
	data.drill = active_bundle.drill
	data.safe = active_bundle.safe
	data.active_market_bundle = market_bundle

	if managers.menu_component._blackmarket_gui and managers.menu_component._blackmarket_gui._market_bundles then
		managers.menu_component._blackmarket_gui._data.active_market_bundle = market_bundle
	end

	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node_stack()
	end
end

function MenuNodeOpenContainerGui:previous_page()
	local data = self.node:parameters().container_data

	if data.active_market_bundle then
		managers.menu_component:post_event("menu_enter")
		self:prev_container()
	end
end

function MenuNodeOpenContainerGui:next_page()
	local data = self.node:parameters().container_data

	if data.active_market_bundle then
		managers.menu_component:post_event("menu_enter")
		self:next_container()
	end
end

function MenuNodeOpenContainerGui:set_visible(visible)
	MenuNodeOpenContainerGui.super.set_visible(self, visible)
	self._fullscreen_panel:set_visible(visible)
end

function MenuNodeOpenContainerGui:_setup_item_panel(...)
	MenuNodeOpenContainerGui.super._setup_item_panel(self, ...)

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end
end

function MenuNodeOpenContainerGui:close()
	MenuNodeOpenContainerGui.super.close(self)

	if alive(self._fullscreen_panel) then
		self._fullscreen_panel:parent():remove(self._fullscreen_panel)
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(false)
	end
end

MenuNodeContainerPreviewGui = MenuNodeContainerPreviewGui or class(MenuNodeGui)

function MenuNodeContainerPreviewGui:init(node, layer, parameters)
	MenuNodeContainerPreviewGui.super.init(self, node, layer, parameters)

	if alive(self.safe_rect_panel:child("title_text")) then
		self.safe_rect_panel:remove(self.safe_rect_panel:child("title_text"))
	end

	local data = node:parameters().menu_component_data

	if data and data.id then
		local tweak = tweak_data.blackmarket.weapon_skins[data.id]
		local title_string = ""

		if tweak.weapon_id then
			title_string = utf8.to_upper(managers.weapon_factory:get_weapon_name_by_weapon_id(tweak.weapon_id)) .. " | "
		end

		title_string = title_string .. managers.localization:text(tweak.name_id)

		if data.quality then
			title_string = title_string .. ", " .. managers.localization:text(tweak_data.economy.qualities[data.quality].name_id)
		end

		if data.bonus then
			local bonus = tweak.bonus

			if bonus then
				title_string = title_string .. ", " .. managers.localization:text("menu_bm_inventory_bonus")
			end
		end

		self.safe_rect_panel:text({
			name = "title_text",
			text = title_string,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.economy.rarities[tweak.rarity].color or tweak_data.screen_colors.text
		})
	end
end

function MenuNodeContainerPreviewGui:close(...)
	MenuNodeContainerPreviewGui.super.close(self, ...)
	managers.menu_component:show_blackmarket_gui()
end
