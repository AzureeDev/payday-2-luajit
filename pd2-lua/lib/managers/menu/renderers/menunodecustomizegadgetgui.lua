MenuNodeCustomizeGadgetGui = MenuNodeCustomizeGadgetGui or class(MenuNodeGui)
local padding = 10

function MenuNodeCustomizeGadgetGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true

	MenuNodeCustomizeGadgetGui.super.init(self, node, layer, parameters)
	self:setup(node)
end

function MenuNodeCustomizeGadgetGui:setup(node)
	local l_hue = node:item("laser_hue")
	local l_sat = node:item("laser_sat")
	local l_val = node:item("laser_val")
	local f_hue = node:item("flashlight_hue")
	local f_sat = node:item("flashlight_sat")
	local f_val = node:item("flashlight_val")
	local data = node:parameters().menu_component_data
	local part_id = data.name
	local colors = managers.blackmarket:get_part_custom_colors(data.category, data.slot, data.name)

	if colors.laser and l_hue and l_sat and l_val then
		local h, s, v = rgb_to_hsv(colors.laser.r, colors.laser.g, colors.laser.b)

		l_hue:set_value(h)
		l_sat:set_value(s)
		l_val:set_value(v)
	end

	if colors.flashlight and f_hue and f_sat and f_val then
		local h, s, v = rgb_to_hsv(colors.flashlight.r, colors.flashlight.g, colors.flashlight.b)

		f_hue:set_value(h)
		f_sat:set_value(s)
		f_val:set_value(v)
	end

	self:update_node_colors()
end

function MenuNodeCustomizeGadgetGui:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(x), math.round(y))

	return x, y, w, h
end

function MenuNodeCustomizeGadgetGui:_setup_item_panel(safe_rect, res)
	MenuNodeCustomizeGadgetGui.super._setup_item_panel(self, safe_rect, res)
	self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions))
	self.item_panel:set_center(self.item_panel:parent():w() / 2, self.item_panel:parent():h() / 2)

	local static_y = self.static_y and safe_rect.height * self.static_y

	if static_y and static_y < self.item_panel:y() then
		self.item_panel:set_y(static_y)
	end

	self.item_panel:set_position(math.round(self.item_panel:x()), math.round(self.item_panel:y()))
	self:_rec_round_object(self.item_panel)

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
	self.box_panel:set_layer(151)

	local data = self.node:parameters().menu_component_data
	local part_id = data.name
	local mod_td = tweak_data.weapon.factory.parts[part_id]
	local show_laser = mod_td.sub_type == "laser"
	local show_flashlight = mod_td.sub_type == "flashlight"

	if mod_td.adds then
		for _, part_id in ipairs(mod_td.adds) do
			local sub_type = tweak_data.weapon.factory.parts[part_id].sub_type
			show_laser = sub_type == "laser" or show_laser
			show_flashlight = sub_type == "flashlight" or show_flashlight
		end
	end

	local next_panel_h = padding + 2 + (tweak_data.menu.pd2_small_font_size + 1) * 3

	if show_laser then
		self._laser_panel = self.box_panel:panel({
			h = 32,
			layer = 10,
			x = padding,
			y = next_panel_h,
			w = self.box_panel:w() - padding * 2
		})

		self:_rec_round_object(self._laser_panel)

		self._laser_color = self._laser_panel:rect({
			alpha = 0.8,
			blend_mode = "add",
			color = Color.blue
		})
		next_panel_h = padding + 2 + (tweak_data.menu.pd2_small_font_size + 1) * 6 + 64
	end

	if show_flashlight then
		self._flashlight_panel = self.box_panel:panel({
			h = 32,
			layer = 10,
			x = padding,
			y = next_panel_h,
			w = self.box_panel:w() - padding * 2
		})

		self:_rec_round_object(self._flashlight_panel)

		self._flashlight_color = self._flashlight_panel:rect({
			alpha = 0.8,
			blend_mode = "add",
			color = Color.red
		})
	end

	self:update_node_colors()

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

function MenuNodeCustomizeGadgetGui:update_node_colors(node)
	node = node or self.node

	if not node then
		return
	end

	local colors = {}

	if alive(self._laser_color) then
		local l_hue = node:item("laser_hue")
		local l_sat = node:item("laser_sat")
		local l_val = node:item("laser_val")

		if l_hue and l_sat and l_val then
			local r, g, b = CoreMath.hsv_to_rgb(l_hue:value(), l_sat:value(), l_val:value())
			local col = Color(r, g, b)

			self._laser_color:set_color(col)

			colors.laser = col
		end
	end

	if alive(self._flashlight_color) then
		local f_hue = node:item("flashlight_hue")
		local f_sat = node:item("flashlight_sat")
		local f_val = node:item("flashlight_val")

		if f_hue and f_sat and f_val then
			local r, g, b = CoreMath.hsv_to_rgb(f_hue:value(), f_sat:value(), f_val:value())
			local col = Color(r, g, b)

			self._flashlight_color:set_color(col)

			colors.flashlight = col
		end
	end

	return colors
end

function MenuNodeCustomizeGadgetGui:_unretrieve_texture()
	if self._texture then
		managers.menu_component:unretrieve_texture(self._texture, self._texture_index)

		self._texture = nil
		self._texture_ids = nil
		self._texture_index = nil
	end
end

function MenuNodeCustomizeGadgetGui:_texture_done_callback(texture_ids)
	if self and alive(self._texture_panel) then
		self._texture_panel:bitmap({
			blend_mode = "add",
			texture = texture_ids,
			w = self._texture_panel:w(),
			h = self._texture_panel:h()
		})

		self._texture_index = false
	end
end

function MenuNodeCustomizeGadgetGui:get_recticle_texture_ids()
	return self._texture_ids
end

function MenuNodeCustomizeGadgetGui:_setup_item_panel_parent(safe_rect, shape)
	shape = shape or {}
	shape.x = shape.x or safe_rect.x
	shape.y = shape.y or safe_rect.y + 0
	shape.w = shape.w or safe_rect.width
	shape.h = shape.h or safe_rect.height - 0

	MenuNodeCustomizeGadgetGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeCustomizeGadgetGui:_rec_round_object(object)
	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end

	local x, y = object:position()

	object:set_position(math.round(x), math.round(y))
end

function MenuNodeCustomizeGadgetGui:_setup_item_rows(node)
	MenuNodeCustomizeGadgetGui.super._setup_item_rows(self, node)
end

function MenuNodeCustomizeGadgetGui:reload_item(item)
	MenuNodeCustomizeGadgetGui.super.reload_item(self, item)

	local row_item = self:row_item(item)

	if row_item and alive(row_item.gui_panel) then
		row_item.gui_panel:set_halign("right")
		row_item.gui_panel:set_right(self.item_panel:w())
	end
end

function MenuNodeCustomizeGadgetGui:_align_marker(row_item)
	MenuNodeCustomizeGadgetGui.super._align_marker(self, row_item)

	if row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_world_right(row_item.gui_panel:world_right())

		return
	end

	self._marker_data.marker:set_world_right(self.item_panel:world_right())
end

function MenuNodeCustomizeGadgetGui:close()
	self:_unretrieve_texture()
	MenuNodeCustomizeGadgetGui.super.close(self)
end
