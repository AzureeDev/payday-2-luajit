ServerStatusBoxGui = ServerStatusBoxGui or class(TextBoxGui)

function ServerStatusBoxGui:init(ws, title, text, content_data, config)
	config = config or {}
	config.h = config.h or 130
	config.w = config.w or 280
	local x, y = ws:size()
	config.x = config.x or 0
	config.y = config.y or 1
	config.no_close_legend = true
	config.no_scroll_legend = true
	config.use_minimize_legend = true
	title = "Server Info"

	ServerStatusBoxGui.super.init(self, ws, title, text, content_data, config)
	self:set_layer(10)
end

function ServerStatusBoxGui:update(t, dt)
end

function ServerStatusBoxGui:_make_nice_text(text)
	local _, _, w, h = text:text_rect()

	text:set_size(w, h)
end

function ServerStatusBoxGui:_create_text_box(ws, title, text, content_data, config)
	ServerStatusBoxGui.super._create_text_box(self, ws, title, text, content_data, config)

	local is_server = Network:is_server()
	local server_peer = managers.network:session() and (is_server and managers.network:session():local_peer() or managers.network:session():server_peer()) or nil
	local server_name = server_peer and server_peer:name() or ""
	local server_panel = self._scroll_panel:panel({
		name = "server_panel",
		h = 60,
		x = 0,
		layer = 1,
		w = self._scroll_panel:w()
	})
	local font_size = tweak_data.menu.lobby_info_font_size
	local server_title = server_panel:text({
		name = "server_title",
		vertical = "center",
		w = 256,
		align = "left",
		layer = 1,
		text = string.upper(managers.localization:text("menu_lobby_server_title")),
		font = tweak_data.menu.default_font,
		font_size = font_size,
		h = font_size
	})
	local server_text = server_panel:text({
		vertical = "center",
		name = "server_text",
		w = 256,
		align = "left",
		layer = 1,
		text = string.upper("" .. server_name),
		font = tweak_data.menu.default_font,
		color = tweak_data.hud.prime_color,
		font_size = font_size,
		h = font_size
	})
	local server_state_title = server_panel:text({
		name = "server_state_title",
		vertical = "center",
		w = 256,
		align = "left",
		layer = 1,
		text = string.upper(managers.localization:text("menu_lobby_server_state_title")),
		font = tweak_data.menu.default_font,
		font_size = font_size,
		h = font_size
	})
	local server_state_text = server_panel:text({
		vertical = "center",
		name = "server_state_text",
		w = 256,
		align = "left",
		layer = 1,
		text = string.upper(managers.localization:text(self._server_state_string_id or "menu_lobby_server_state_in_lobby")),
		font = tweak_data.menu.default_font,
		color = tweak_data.hud.prime_color,
		font_size = font_size,
		h = font_size
	})

	self:_make_nice_text(server_title)
	self:_make_nice_text(server_text)
	server_text:set_right(server_panel:w())
	self:_make_nice_text(server_state_title)
	self:_make_nice_text(server_state_text)
	server_state_title:set_y(24)
	server_state_text:set_righttop(server_panel:w(), 24)
	server_panel:set_h(server_state_title:bottom())
	self._scroll_panel:set_h(math.max(self._scroll_panel:h(), server_panel:h()))
	self:_set_scroll_indicator()
end

function ServerStatusBoxGui:mouse_pressed(button, x, y)
	if not self:can_take_input() then
		return
	end

	if button == Idstring("0") and self._panel:child("info_area"):inside(x, y) then
		-- Nothing
	end
end

function ServerStatusBoxGui:mouse_moved(x, y)
	if not self:can_take_input() then
		return
	end

	local pointer = nil

	return false, pointer
end

function ServerStatusBoxGui:_check_scroll_indicator_states()
	ServerStatusBoxGui.super._check_scroll_indicator_states(self)
end

function ServerStatusBoxGui:set_size(x, y)
	ServerStatusBoxGui.super.set_size(self, x, y)
end

function ServerStatusBoxGui:set_server_info_state(state)
	print("ServerStatusBoxGui:set_server_info_state", state)

	local s = ""

	if state == "loading" then
		s = string.upper(managers.localization:text("menu_lobby_server_state_loading"))
	end

	self._scroll_panel:child("server_panel"):child("server_state_text"):set_text(string.upper(s))
end
