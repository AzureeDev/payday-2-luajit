MenuNodeLobbyCountdownGui = MenuNodeLobbyCountdownGui or class(MenuNodeGui)

function MenuNodeLobbyCountdownGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true

	MenuNodeLobbyCountdownGui.super.init(self, node, layer, parameters)
	self:setup(node)
end

function MenuNodeLobbyCountdownGui:setup(node)
end

function MenuNodeLobbyCountdownGui:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(x), math.round(y))

	return x, y, w, h
end

function MenuNodeLobbyCountdownGui:_setup_item_panel(safe_rect, res)
	MenuNodeLobbyCountdownGui.super._setup_item_panel(self, safe_rect, res)
	self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions))
	self.item_panel:set_center(self.item_panel:parent():w() * 0.5, self.item_panel:parent():h() * 0.5)

	local static_y = self.static_y and safe_rect.height * self.static_y

	if static_y and static_y < self.item_panel:y() then
		self.item_panel:set_y(static_y)
	end

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
		self.box_panel:set_h(math.max(self.item_panel:parent():h() * (1 - self._align_line_proportions) * 1.25, self.item_panel:h()))
	end

	self.box_panel:set_center(self.box_panel:parent():w() * 0.5, self.box_panel:parent():h() * 0.5)
	self.item_panel:set_bottom(self.box_panel:bottom())
	self.box_panel:grow(20, 20)
	self.box_panel:move(-10, -10)
	self.box_panel:set_layer(151)

	self._texture_panel = self.box_panel:panel({
		w = 128,
		h = 128,
		layer = 10
	})

	self._texture_panel:set_center(self.box_panel:w() * 0.5, self.box_panel:h() * 0.5)
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

	self._text_panel = self.box_panel:panel({
		halign = "grow",
		layer = 1100,
		y = 10,
		x = 10,
		valign = "grow",
		w = self.box_panel:w() - 20,
		h = self.box_panel:h() * 0.3
	})
	local title = self._text_panel:text({
		halign = "grow",
		name = "title_text",
		text = managers.localization:to_upper_text("menu_mutators_lobby_wait_title"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		h = tweak_data.menu.pd2_medium_font_size
	})
	local desc = self._text_panel:text({
		name = "desc_text",
		wrap = true,
		word_wrap = true,
		halign = "grow",
		text = managers.localization:text("menu_mutators_lobby_wait_desc"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		h = tweak_data.menu.pd2_medium_font_size,
		y = title:bottom() + 5,
		w = self._text_panel:w(),
		h = self._text_panel:h() - title:bottom()
	})
	self._countdown_panel = self.box_panel:panel({
		w = 128,
		h = 128
	})

	self._countdown_panel:set_center_x(self.box_panel:w() * 0.25)
	self._countdown_panel:set_top(self._text_panel:bottom())

	self._countdown_radial = self._countdown_panel:bitmap({
		texture = "guis/dlcs/coco/textures/pd2/hud_absorb_shield",
		name = "countdown_radial",
		h = 128,
		w = 128,
		alpha = 1,
		layer = 2,
		blend_mode = "add",
		render_template = "VertexColorTexturedRadial",
		texture_rect = {
			64,
			0,
			-64,
			64
		}
	})

	self._countdown_radial:set_color(Color(1, 1, 0, 0))
	self._countdown_radial:set_center(self._countdown_panel:w() * 0.5, self._countdown_panel:h() * 0.5)

	self._countdown_text = self._countdown_panel:text({
		name = "countdown_text",
		vertical = "center",
		alpha = 1,
		align = "center",
		layer = 3,
		text = "88",
		halign = "center",
		valign = "center",
		font = tweak_data.menu.pd2_massive_font,
		font_size = tweak_data.menu.pd2_massive_font_size,
		h = tweak_data.menu.pd2_massive_font_size
	})

	self:make_fine_text(self._countdown_text)
	self._countdown_text:set_center(self._countdown_panel:w() * 0.5, self._countdown_panel:h() * 0.5 + 5)

	local peer_panel_h = tweak_data.menu.pd2_small_font_size + 10
	self._peers_panel = self.box_panel:panel({
		w = self.box_panel:w() - self._countdown_panel:right(),
		h = peer_panel_h * 4
	})

	self._peers_panel:set_right(self.box_panel:w() - 10)
	self._peers_panel:set_top(self._text_panel:bottom())

	local max_name_w = 0

	for i, peer in ipairs(managers.network:session():all_peers()) do
		local peer_ready = peer:id() == managers.network:session():local_peer():id() or managers.mutators:is_peer_ready(peer:id())
		local peer_panel = self._peers_panel:panel({
			halign = "grow",
			layer = 1100,
			name = "peer_" .. tostring(i),
			h = peer_panel_h,
			y = peer_panel_h * (i - 1)
		})
		local checkbox = peer_panel:bitmap({
			texture = "guis/textures/menu_tickbox",
			name = "check",
			h = 24,
			w = 24,
			alpha = 1,
			layer = 2,
			blend_mode = "add",
			halign = "right",
			texture_rect = {
				peer_ready and 24 or 0,
				0,
				24,
				24
			}
		})

		checkbox:set_right(peer_panel:right())
		checkbox:set_center_y(peer_panel:h() * 0.5)

		local name = peer_panel:text({
			halign = "right",
			align = "right",
			name = "name",
			text = peer:name(),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			h = tweak_data.menu.pd2_small_font_size
		})
		local _, _, w, _ = name:text_rect()

		name:set_w(w)
		name:set_right(checkbox:left() - 5)
		name:set_center_y(peer_panel:h() * 0.5)

		max_name_w = math.max(max_name_w, w)
	end

	local name_expand_w = math.max((max_name_w - self._countdown_panel:w()) - 30, 0)

	self.box_panel:grow(name_expand_w, 0)
	self._peers_panel:grow(name_expand_w, 0)
	self.box_panel:set_center(self.box_panel:parent():w() * 0.5, self.box_panel:parent():h() * 0.5)
	self.item_panel:set_right(self.box_panel:right() - 10)

	self.boxgui = BoxGuiObject:new(self.box_panel, {sides = {
		1,
		1,
		1,
		1
	}})

	self.boxgui:set_clipping(false)
	self.boxgui:set_layer(1000)
	self.box_panel:rect({
		alpha = 0.8,
		rotation = 360,
		color = Color.black
	})
end

function MenuNodeLobbyCountdownGui:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function MenuNodeLobbyCountdownGui:_setup_item_panel_parent(safe_rect, shape)
	shape = shape or {}
	shape.x = shape.x or safe_rect.x
	shape.y = shape.y or safe_rect.y + 0
	shape.w = shape.w or safe_rect.width
	shape.h = shape.h or safe_rect.height - 0

	MenuNodeLobbyCountdownGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeLobbyCountdownGui:_rec_round_object(object)
	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end

	local x, y = object:position()

	object:set_position(math.round(x), math.round(y))
end

function MenuNodeLobbyCountdownGui:_setup_item_rows(node)
	MenuNodeLobbyCountdownGui.super._setup_item_rows(self, node)
end

function MenuNodeLobbyCountdownGui:reload_item(item)
	MenuNodeLobbyCountdownGui.super.reload_item(self, item)

	local row_item = self:row_item(item)

	if row_item and alive(row_item.gui_panel) then
		row_item.gui_panel:set_halign("right")
		row_item.gui_panel:set_right(self.item_panel:w())
	end
end

function MenuNodeLobbyCountdownGui:_align_marker(row_item)
	MenuNodeLobbyCountdownGui.super._align_marker(self, row_item)

	if row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_world_right(row_item.gui_panel:world_right())

		return
	end

	self._marker_data.marker:set_world_right(self.item_panel:world_right())
end

function MenuNodeLobbyCountdownGui:close()
	MenuNodeLobbyCountdownGui.super.close(self)
end

function MenuNodeLobbyCountdownGui:update(t, dt)
	MenuNodeLobbyCountdownGui.super.update(self, t, dt)

	self._t = math.sin(t * 60) * 0.5 + 0.5

	self._countdown_radial:set_color(Color(1, self._t, 0, 0))
	self._countdown_radial:set_rotation(math.floor(t % 2 * 360) - self._t)

	local time = math.floor(managers.mutators:lobby_delay() - TimerManager:main():time())
	local time_str = tostring(time == 0 and "0" or time)

	self._countdown_text:set_text(time_str)
	self:make_fine_text(self._countdown_text)
	self._countdown_text:set_center(self._countdown_panel:w() * 0.5, self._countdown_panel:h() * 0.5 + 5)

	if (self._time or nil) ~= time then
		self._countdown_text:animate(MenuNodeLobbyCountdownGui.animate_flash_text)

		self._time = time
	end

	for i, peer in ipairs(managers.network:session():all_peers()) do
		if i > 1 then
			local panel = self._peers_panel:child("peer_" .. tostring(i))

			if panel then
				local checkbox = panel:child("check")
				local peer_ready = peer:id() == managers.network:session():local_peer():id() or managers.mutators:is_peer_ready(peer:id())

				checkbox:set_texture_rect(peer_ready and 24 or 0, 0, 24, 24)
			end
		end
	end

	if time < 0 and not self._started then
		print("start the game start the game start the game start the game start the game start the game start the game")
		managers.mutators:force_all_ready()
		MenuCallbackHandler:start_the_game()

		self._started = true
	end
end

function MenuNodeLobbyCountdownGui.animate_flash_text(text)
	local dur = 0.5
	local t = 0

	while t < dur do
		local dt = coroutine.yield()
		t = t + dt

		text:set_color(math.lerp(tweak_data.screen_colors.button_stage_2, tweak_data.screen_colors.text, t / dur))
	end
end

