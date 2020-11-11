LobbyCharacterData = LobbyCharacterData or class()

function LobbyCharacterData:init(panel, peer)
	self._parent = panel
	self._peer = peer
	self._panel = panel:panel({
		w = 128,
		h = 128
	})
	local peer_id = peer:id()
	local local_peer = managers.network:session() and managers.network:session():local_peer()
	local rank = peer == local_peer and managers.experience:current_rank() or peer:rank()
	local color_id = peer_id
	local color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
	local name_text = self._panel:text({
		vertical = "top",
		name = "name",
		blend_mode = "add",
		align = "center",
		text = "",
		layer = 0,
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = color
	})

	name_text:set_text(peer:name() or "")

	local state_text = self._panel:text({
		vertical = "top",
		name = "state",
		blend_mode = "add",
		align = "center",
		text = "",
		layer = 0,
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})

	state_text:set_top(name_text:bottom())
	state_text:set_center_x(name_text:center_x())

	local texture, texture_rect = managers.experience:rank_icon_data(rank)
	local infamy_icon = self._panel:bitmap({
		name = "infamy_icon",
		h = 16,
		w = 16,
		texture = texture,
		texture_rect = texture_rect,
		color = color
	})

	infamy_icon:set_right(name_text:x())
	infamy_icon:set_top(name_text:y() + 4)

	self._name_text = name_text
	self._state_text = state_text
	self._infamy_icon = infamy_icon
	local level = managers.crime_spree:get_peer_spree_level(peer:id())
	local level_text = level >= 0 and managers.localization:text("menu_cs_level", {
		level = managers.experience:cash_string(level, "")
	}) or ""
	local spree_text = self._panel:text({
		vertical = "top",
		name = "spree_level",
		blend_mode = "add",
		align = "center",
		text = "",
		layer = 0,
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.crime_spree_risk
	})
	self._spree_text = spree_text

	self:update_character()

	if Global.game_settings.single_player then
		self._panel:set_visible(false)
	end
end

function LobbyCharacterData:destroy()
	if alive(self._parent) and alive(self._panel) then
		self._parent:remove(self._panel)
	end
end

function LobbyCharacterData:panel()
	return self._panel
end

function LobbyCharacterData:_can_update()
	return self._peer and managers.network:session()
end

function LobbyCharacterData:set_alpha(new_alpha)
	self._panel:set_alpha(new_alpha)
end

function LobbyCharacterData:update_peer_id(new_peer_id)
	if not self:_can_update() then
		return
	end

	if new_peer_id then
		local peer = managers.network:session():peer(new_peer_id)
		self._peer = peer

		self:set_alpha(peer and 1 or 0)
	end
end

function LobbyCharacterData:update_character()
	if not self:_can_update() then
		return
	end

	local peer = self._peer
	local local_peer = managers.network:session() and managers.network:session():local_peer()
	local name_text = peer:name()
	local show_infamy = false
	local experience, color_ranges = nil
	local player_level = peer == local_peer and managers.experience:current_level() or peer:level()
	local player_rank = peer == local_peer and managers.experience:current_rank() or peer:rank()

	if player_level then
		local color_range_offset = utf8.len(name_text) + 2
		experience, color_ranges = managers.experience:gui_string(player_level, player_rank, color_range_offset)
		name_text = name_text .. " (" .. experience .. ")"
	end

	show_infamy = player_rank > 0

	self._name_text:set_text(name_text)
	self._infamy_icon:set_visible(show_infamy)

	for _, color_range in ipairs(color_ranges or {}) do
		self._name_text:set_range_color(color_range.start, color_range.stop, color_range.color)
	end

	if managers.crime_spree:is_active() then
		local level = managers.crime_spree:get_peer_spree_level(peer:id())

		if level >= 0 then
			local level_text = managers.localization:text("menu_cs_level", {
				level = managers.experience:cash_string(level, "")
			})

			self._spree_text:set_text(level_text)
		else
			self._spree_text:set_text("")
		end
	else
		self._spree_text:set_text("")
	end

	self:update_character_menu_state(nil)
	self:sort_text_and_reposition()
end

function LobbyCharacterData:update_character_menu_state(new_state)
	if not self:_can_update() then
		return
	end

	local state_text = new_state and managers.localization:to_upper_text("menu_lobby_menu_state_" .. new_state) or self._state_text:text()

	self._state_text:set_text(state_text)
	self:sort_text_and_reposition()
end

function LobbyCharacterData:update_position()
	if not self:_can_update() then
		return
	end

	local pos = managers.menu_scene:character_screen_position(self._peer:id())

	self._panel:set_center(pos.x, pos.y)
end

function LobbyCharacterData:sort_text_and_reposition()
	local order = {
		self._name_text,
		self._state_text
	}

	if managers.crime_spree:is_active() then
		table.insert(order, 1, self._spree_text)
	end

	local max_w = 0

	for i, text in ipairs(order) do
		local _, _, w = self:make_fine_text(text)
		max_w = math.max(max_w, w)

		if i > 1 then
			text:set_top(order[i - 1]:bottom())
		else
			text:set_top(0)
		end
	end

	local extra_padding = 16

	self._panel:set_w(max_w + extra_padding * 2)

	for i, text in ipairs(order) do
		text:set_center_x(self._panel:w() * 0.5)
	end

	self._infamy_icon:set_right(self._name_text:x())
	self._infamy_icon:set_top(self._name_text:y() + 4)
	self:update_position()
end

function LobbyCharacterData:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))

	return x, y, w, h
end
