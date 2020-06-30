MenuNodeReticleSwitchGui = MenuNodeReticleSwitchGui or class(MenuNodeGui)

function MenuNodeReticleSwitchGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true

	MenuNodeReticleSwitchGui.super.init(self, node, layer, parameters)
	self:setup(node)
end

function MenuNodeReticleSwitchGui:setup(node)
	local color = node:item("reticle_color"):value()
	local type = node:item("reticle_type"):value()
	local data = node:parameters().menu_component_data
	local part_id = data.name
	local data_string = tostring(color) .. " " .. tostring(type)
	local texture = managers.blackmarket:get_texture_switch_from_data(data_string, part_id)

	self:set_reticle_texture(texture)
end

function MenuNodeReticleSwitchGui:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(x), math.round(y))

	return x, y, w, h
end

function MenuNodeReticleSwitchGui:_setup_item_panel(safe_rect, res)
	MenuNodeReticleSwitchGui.super._setup_item_panel(self, safe_rect, res)
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

	self._texture_panel = self.box_panel:panel({
		w = 128,
		h = 128,
		layer = 10
	})

	self._texture_panel:set_center(self.box_panel:w() / 2, self.box_panel:h() / 2)
	self:_set_reticle_texture(self._texture)

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

function MenuNodeReticleSwitchGui:update_item_dlc_locks()
	local node = self.node

	if not node then
		return
	end

	local type = node:item("reticle_type"):value()
	local color = node:item("reticle_color"):value()
	local type_data = tweak_data:get_raw_value("gui", "weapon_texture_switches", "types", "sight", type)
	local color_data = tweak_data:get_raw_value("gui", "weapon_texture_switches", "color_indexes", color)
	local type_dlc = type_data and type_data.dlc or false
	local color_dlc = color_data and color_data.dlc or false
	local pass_type = not type_dlc or managers.dlc:is_dlc_unlocked(type_dlc)
	local pass_color = not color_dlc or managers.dlc:is_dlc_unlocked(color_dlc)
	local type_row_item = self:row_item_by_name("reticle_type")
	type_row_item.hightlight_color = not pass_type and tweak_data.screen_colors.important_1
	type_row_item.row_item_color = not pass_type and tweak_data.screen_colors.important_1
	local color_row_item = self:row_item_by_name("reticle_color")
	color_row_item.hightlight_color = not pass_color and tweak_data.screen_colors.important_1
	color_row_item.row_item_color = not pass_color and tweak_data.screen_colors.important_1
	local confirm = node:item("confirm")
	local require_dlc = "dialog_require_dlc_"
	confirm:parameters().text_id = not pass_type and require_dlc .. type_dlc or not pass_color and require_dlc .. color_dlc or "dialog_apply"

	self:reload_item(node:item("reticle_type"))
	self:reload_item(node:item("reticle_color"))
	self:reload_item(node:item("confirm"))

	return pass_type and pass_color
end

function MenuNodeReticleSwitchGui:set_reticle_texture(texture)
	self:_set_reticle_texture(texture)
end

function MenuNodeReticleSwitchGui:_set_reticle_texture(texture)
	if texture and alive(self._texture_panel) and DB:has(Idstring("texture"), texture) then
		self._texture_panel:clear()
		self:_unretrieve_texture()

		self._texture = texture
		self._texture_ids = Idstring(texture)
		self._texture_index = managers.menu_component:request_texture(self._texture, callback(self, self, "_texture_done_callback"))
	end
end

function MenuNodeReticleSwitchGui:_unretrieve_texture()
	if self._texture then
		managers.menu_component:unretrieve_texture(self._texture, self._texture_index)

		self._texture = nil
		self._texture_ids = nil
		self._texture_index = nil
	end
end

function MenuNodeReticleSwitchGui:_texture_done_callback(texture_ids)
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

function MenuNodeReticleSwitchGui:get_recticle_texture_ids()
	return self._texture_ids
end

function MenuNodeReticleSwitchGui:_setup_item_panel_parent(safe_rect, shape)
	shape = shape or {}
	shape.x = shape.x or safe_rect.x
	shape.y = shape.y or safe_rect.y + 0
	shape.w = shape.w or safe_rect.width
	shape.h = shape.h or safe_rect.height - 0

	MenuNodeReticleSwitchGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeReticleSwitchGui:_rec_round_object(object)
	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end

	local x, y = object:position()

	object:set_position(math.round(x), math.round(y))
end

function MenuNodeReticleSwitchGui:_setup_item_rows(node)
	MenuNodeReticleSwitchGui.super._setup_item_rows(self, node)
end

function MenuNodeReticleSwitchGui:reload_item(item)
	MenuNodeReticleSwitchGui.super.reload_item(self, item)

	local row_item = self:row_item(item)

	if row_item and alive(row_item.gui_panel) then
		row_item.gui_panel:set_halign("right")
		row_item.gui_panel:set_right(self.item_panel:w())
	end
end

function MenuNodeReticleSwitchGui:_align_marker(row_item)
	MenuNodeReticleSwitchGui.super._align_marker(self, row_item)

	if row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_world_right(row_item.gui_panel:world_right())

		return
	end

	self._marker_data.marker:set_world_right(self.item_panel:world_right())
end

function MenuNodeReticleSwitchGui:close()
	self:_unretrieve_texture()
	MenuNodeReticleSwitchGui.super.close(self)
end
