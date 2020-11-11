require("lib/managers/menu/ExtendedPanel")
require("lib/managers/menu/BoxGuiObject")

InfamyCardGui = InfamyCardGui or class()

function InfamyCardGui:init(unit)
	self._unit = unit
	self._data = nil
	self._cull_distance = self._cull_distance or 5000
	self._size_multiplier = self._size_multiplier or 1
	self._gui_object = self._gui_object or "c_box"
	self._new_gui = World:newgui()

	self:add_workspace(self._unit:get_object(Idstring(self._gui_object)))
	self._unit:set_extension_update_enabled(Idstring("digital_gui"), false)
end

function InfamyCardGui:add_workspace(gui_object)
	local gui_size = 200
	local x_size = 6
	local x_offset = x_size / 2
	local y_size = 9
	local y_offset = y_size / 2
	local depth_offset = 0.3
	local gui_width = gui_size
	local suit_height = gui_size * 1.5
	local text_height = gui_size * 1.25
	self._icon_ws = self._new_gui:create_linked_workspace(gui_width, suit_height, gui_object, Vector3(x_offset, depth_offset, y_offset), Vector3(-x_size, 0, 0), Vector3(0, 0, -y_size))
	self._icon_gui = ExtendedPanel:new(self._icon_ws:panel())
	self._text_ws = self._new_gui:create_linked_workspace(gui_width, text_height, gui_object, Vector3(x_offset, depth_offset, y_offset), Vector3(-x_size, 0, 0), Vector3(0, 0, -y_size))
	self._text_gui = ExtendedPanel:new(self._text_ws:panel())
end

function InfamyCardGui:show_rank(rank)
	self:clear_gui()

	self._data = {
		rank = rank
	}

	if self._unit:damage() then
		self._unit:damage():run_sequence_simple("enable_card_blank")
	end

	local rank_icon, icon_texture_rect = managers.experience:rank_icon_data(rank)
	local icon_color = (Color.white - (managers.experience:rank_icon_color(rank) or Color(0, 0, 0))):with_alpha(1)
	local tx, ty, tw, th = unpack(icon_texture_rect)
	local icon_w = 30
	local icon_h = 30
	local left_top_icon = self._icon_gui:bitmap({
		y = 9,
		blend_mode = "sub",
		x = 4,
		texture = rank_icon,
		texture_rect = {
			tx,
			ty,
			tw,
			th
		},
		color = icon_color,
		w = icon_w,
		h = icon_h
	})

	left_top_icon:set_render_template(Idstring("OverlayVertexColorTextured"))

	local right_bottom_icon = self._icon_gui:bitmap({
		blend_mode = "sub",
		texture = rank_icon,
		texture_rect = {
			tx + tw,
			ty + th,
			-tw,
			-th
		},
		color = icon_color,
		x = self._icon_gui:w() - 3 - icon_w,
		y = self._icon_gui:h() - 7 - icon_h,
		w = icon_w,
		h = icon_h
	})

	right_bottom_icon:set_render_template(Idstring("OverlayVertexColorTextured"))

	local font = tweak_data.menu.pd2_massive_font
	local font_size = tweak_data.menu.pd2_massive_font_size * 1.5
	local rank_string = managers.experience:rank_string(rank, managers.user:get_setting("infamy_roman_card")) or ""
	local rank_text = self._text_gui:text({
		vertical = "center",
		align = "center",
		blend_mode = "sub",
		layer = 1,
		font = font,
		font_size = font_size,
		text = rank_string,
		color = icon_color
	})

	ExtendedPanel.make_fine_text(rank_text)

	local needed_width = self._text_gui:w() - 30
	local width = rank_text:w()

	rank_text:set_width(needed_width)
	rank_text:set_center(self._text_gui:w() * 0.5 + 1, self._text_gui:h() * 0.525 + 1)
	rank_text:set_render_template(Idstring("OverlayText"))

	local scaled_font_size = math.floor(font_size * math.min(needed_width / width, 1))

	rank_text:set_font_size(scaled_font_size)
end

function InfamyCardGui:show_texture(texture, texture_rect)
	self:clear_gui()

	self._data = {
		texture = texture,
		texture_rect = texture_rect
	}

	if self._unit:damage() then
		self._unit:damage():run_sequence_simple("enable_card_blank")
	end

	local icon = self._icon_gui:bitmap({
		h = 128,
		blend_mode = "sub",
		w = 128,
		texture = texture,
		texture_rect = texture_rect,
		color = Color(1, 1, 1, 1)
	})

	icon:set_center(self._icon_gui:w() / 2, self._icon_gui:h() / 2)
	icon:set_render_template(Idstring("VertexColorTextured"))
end

function InfamyCardGui:show_experience_boost()
	self:show_texture("guis/dlcs/infamous/textures/pd2/infamous_tree/infamous_tree_atlas", {
		128,
		128,
		128,
		128
	})
end

function InfamyCardGui:show_join_stinger()
	self:show_texture("guis/textures/pd2/skilltree_2/ace_symbol")
end

function InfamyCardGui:set_visible(visible)
	self._visible = visible

	self._icon_gui:set_visible(visible)
	self._text_gui:set_visible(visible)
end

function InfamyCardGui:is_visible()
	return self._visible
end

function InfamyCardGui:update()
end

function InfamyCardGui:hide()
	self._ws:hide()
end

function InfamyCardGui:show()
	self._ws:show()
end

function InfamyCardGui:lock_gui()
	self._icon_ws:set_cull_distance(self._cull_distance)
	self._icon_ws:set_frozen(true)
	self._text_ws:set_cull_distance(self._cull_distance)
	self._text_ws:set_frozen(true)
end

function InfamyCardGui:refresh_gui(override_data)
	if not self._data then
		return
	end

	if override_data then
		self._data = override_data
	end

	if self._data.rank then
		self:show_rank(self._data.rank)
	elseif self._data.texture then
		self:show_texture(self._data.texture, self._data.texture_rect)
	end
end

function InfamyCardGui:clear_gui()
	if alive(self._icon_gui) then
		self._icon_gui:clear()
	end

	if alive(self._text_gui) then
		self._text_gui:clear()
	end
end

function InfamyCardGui:destroy()
	if not alive(self._new_gui) then
		return
	end

	if alive(self._icon_ws) then
		self._new_gui:destroy_workspace(self._icon_ws)

		self._icon_ws = nil
		self._icon_gui = nil
	end

	if alive(self._text_ws) then
		self._new_gui:destroy_workspace(self._text_ws)

		self._text_ws = nil
		self._text_gui = nil
	end

	self._new_gui = nil
end
