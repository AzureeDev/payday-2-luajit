PlayerStatsGui = PlayerStatsGui or class()
local system_font = "core/fonts/system_font"
local small_font = tweak_data.menu.pd2_small_font
local medium_font = tweak_data.menu.pd2_medium_font
local large_font = tweak_data.menu.pd2_large_font
local massive_font = tweak_data.menu.pd2_massive_font
local system_font_size = 12
local small_font_size = tweak_data.menu.pd2_small_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local ICON_TEXTURE_WIDTH = 64
local ICON_TEXTURE_HEIGHT = 64
local ICON_TEXT_WIDTH = ICON_TEXTURE_WIDTH + 26 + 40
local ICON_TEXT_HEIGHT = system_font_size * 2
local ICON_PADDING_WIDTH = 16
local ICON_PADDING_HEIGHT = 16
local ICON_WIDTH = math.max(ICON_TEXTURE_WIDTH, ICON_TEXT_WIDTH) + ICON_PADDING_WIDTH * 2
local ICON_HEIGHT = ICON_TEXTURE_HEIGHT + ICON_TEXT_HEIGHT + ICON_PADDING_HEIGHT * 2

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

PlayerStatsGui.WINDOWS = {
	desktop = {
		bg_texture = "desktop_bg",
		header_right_text = "You are currently logged in as Com_G_Hauk",
		header_left_text = "FedNet 2.1.0.0b",
		icons = {
			["1_1"] = {
				text = "@menu_stats_player_folder;",
				over_texture = "icon_char_over",
				open_window = "main_suspect",
				texture = "icon_char"
			},
			["2_1"] = {
				texture = "icon_folder",
				over_texture = "icon_folder_over",
				text = "Modus Operandi [Loadout]"
			},
			["1_2"] = {
				texture = "icon_folder",
				over_texture = "icon_folder_over",
				text = "Heist Database"
			},
			["2_2"] = {
				texture = "icon_folder",
				over_texture = "icon_folder_over",
				text = ""
			},
			["1_3"] = {
				texture = "icon_weapons",
				over_texture = "icon_weapons_over",
				text = "Firearms Database"
			},
			["2_4"] = {
				texture = "icon_folder",
				over_texture = "icon_folder_over",
				text = "Agency Assets [UPDATED]"
			},
			["2_5"] = {
				texture = "icon_folder",
				over_texture = "icon_folder_over",
				text = "Internal memos"
			}
		}
	},
	main_suspect = {
		w = 800,
		title_text = "@menu_stats_player_title;",
		h = 600,
		header_right_text = "",
		add_close_btn = true,
		header_left_text = "FedNet | Root > @menu_stats_player_folder;",
		window_footer = "window_footer",
		y = 50,
		x = 225,
		content = {
			{
				text = "BLOCK 1",
				type = "text",
				align = "center",
				font = medium_font,
				font_size = medium_font_size
			},
			{
				h = 10,
				type = "divider"
			},
			{
				text = "Player Time",
				value = "_get_player_time",
				type = "text_value"
			},
			{
				text = "Player Level",
				value = "_get_player_level",
				type = "text_value"
			},
			{
				text = "Player Rank",
				value = "_get_player_rank",
				type = "text_value"
			},
			{
				h = 10,
				type = "divider"
			},
			{
				data = "_get_heists_pie_chart_data",
				size = 150,
				type = "pie_chart"
			},
			{
				h = 10,
				type = "divider"
			},
			{
				text = "Some weapon$NL;100%$NL;145 / 544",
				texture = "icon_weapons_over",
				h = 100,
				type = "image",
				w = 100
			},
			{
				h = 10,
				type = "divider"
			},
			{
				h = 10,
				type = "divider"
			},
			{
				text = "BLOCK 1",
				type = "text",
				align = "center",
				font = medium_font,
				font_size = medium_font_size
			},
			{
				h = 10,
				type = "divider"
			},
			{
				text = "Player Time",
				value = "_get_player_time",
				type = "text_value"
			},
			{
				text = "Player Level",
				value = "_get_player_level",
				type = "text_value"
			},
			{
				text = "Player Rank",
				value = "_get_player_rank",
				type = "text_value"
			},
			{
				h = 10,
				type = "divider"
			},
			{
				data = "_get_heists_pie_chart_data",
				size = 150,
				type = "pie_chart"
			},
			{
				h = 10,
				type = "divider"
			},
			{
				text = "Some weapon$NL;100%$NL;145 / 544",
				texture = "icon_weapons_over",
				h = 100,
				type = "image",
				w = 100
			}
		}
	}
}

function PlayerStatsGui:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._node = node
	self._panel = self._ws:panel():panel()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()
	self._window_stack = {}
	local prefix = "guis/dlcs/gordon/textures/pd2/stats/"
	self._textures = {
		desktop_bg = {
			ready = false,
			texture = prefix .. "fbifiles_bg",
			texture_rect = {
				0,
				0,
				1706,
				1024
			}
		},
		icon_char = {
			ready = false,
			texture = prefix .. "fbifiles_icon_char"
		},
		icon_char_over = {
			ready = false,
			texture = prefix .. "fbifiles_icon_char_over"
		},
		icon_folder = {
			ready = false,
			texture = prefix .. "fbifiles_icon_folder"
		},
		icon_folder_over = {
			ready = false,
			texture = prefix .. "fbifiles_icon_folder_over"
		},
		icon_weapons = {
			ready = false,
			texture = prefix .. "fbifiles_icon_weapons"
		},
		icon_weapons_over = {
			ready = false,
			texture = prefix .. "fbifiles_icon_weapons_over"
		},
		window_header_l = {
			ready = false,
			texture = prefix .. "fbifiles_window_header_l"
		},
		window_header_m = {
			ready = false,
			texture = prefix .. "fbifiles_window_header_m"
		},
		window_header_r = {
			ready = false,
			texture = prefix .. "fbifiles_window_header_r"
		},
		window_footer = {
			rotation = 0,
			ready = false,
			texture = prefix .. "fbifiles_window_header_m"
		},
		close_btn = {
			ready = false,
			texture = prefix .. "fbifiles_window_header_l"
		},
		close_btn_over = {
			ready = false,
			texture = prefix .. "fbifiles_window_header_r"
		}
	}
	self._requesting = true
	local texture_loaded_clbk = callback(self, self, "clbk_texture_loaded")

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			texture_data.index = managers.menu_component:request_texture(texture_data.texture, texture_loaded_clbk)
		end
	end

	self._requesting = false

	self:_chk_load_complete()
end

function PlayerStatsGui:_set_window_icon_position(window, icon, x, y)
	if not type(x) == "number" or not type(y) == "number" then
		return
	end

	if not window.icons then
		return
	end

	if window.icons[y] and window.icons[y][x] then
		return
	end

	local old_x = icon._x
	local old_y = icon._y

	if window.icons[old_y] and window.icons[old_y][old_x] then
		window.icons[old_y][old_x] = nil

		if table.size(window.icons[old_y]) == 0 then
			window.icons[old_y] = nil
		end
	end

	window.icons[y] = window.icons[y] or {}
	window.icons[y][x] = icon

	icon.panel:set_position((x - 1) * ICON_WIDTH, (y - 1) * ICON_HEIGHT)

	icon._x = x
	icon._y = y
end

function PlayerStatsGui:_create_window_icon(window, icon_data, pos)
	if not window.panel or not alive(window.panel) then
		return
	end

	local content_panel = window.panel:child("content_panel")

	if not alive(content_panel) then
		return
	end

	local icon_texture = icon_data.texture and self._textures[icon_data.texture] or self._textures.icon_folder
	local icon_over_texture = icon_data.over_texture and self._textures[icon_data.over_texture] or self._textures.icon_folder_over
	local icon_text = icon_data.text and managers.localization:format_text(icon_data.text) or ""
	local panel = content_panel:panel({
		layer = 1,
		w = ICON_WIDTH,
		h = ICON_HEIGHT
	})
	local icon_bitmap = panel:bitmap({
		name = "icon_bitmap",
		layer = 1,
		texture = icon_texture.texture,
		texture_rect = icon_texture.texture_rect,
		w = ICON_TEXTURE_WIDTH,
		h = ICON_TEXTURE_HEIGHT
	})
	local icon_bitmap_over = panel:bitmap({
		name = "icon_bitmap_over",
		visible = false,
		layer = 1,
		texture = icon_over_texture.texture,
		texture_rect = icon_over_texture.texture_rect,
		w = ICON_TEXTURE_WIDTH,
		h = ICON_TEXTURE_HEIGHT
	})
	local icon_text = panel:text({
		name = "icon_text",
		wrap = true,
		align = "center",
		vertical = "top",
		word_wrap = true,
		layer = 1,
		w = ICON_TEXT_WIDTH,
		h = ICON_TEXT_HEIGHT,
		text = icon_text,
		font = system_font,
		font_size = system_font_size,
		color = tweak_data.screen_colors.text
	})
	local icon_text_over = panel:rect({
		name = "icon_text_over",
		visible = false,
		color = Color.white
	})

	icon_bitmap:set_top(ICON_PADDING_HEIGHT)
	icon_bitmap:set_center_x(panel:w() / 2)
	icon_bitmap_over:set_top(ICON_PADDING_HEIGHT)
	icon_bitmap_over:set_center_x(panel:w() / 2)
	icon_text:set_top(icon_bitmap:bottom())
	icon_text:set_center_x(panel:w() / 2)

	local _, _, tw, th = icon_text:text_rect()

	if tw == 0 or th == 0 then
		icon_text_over:set_size(0, 0)
		icon_text_over:set_alpha(0)
	else
		icon_text_over:set_size(tw + 2, th + 2)
	end

	icon_text_over:set_top(icon_bitmap:bottom() - 1)
	icon_text_over:set_center_x(panel:w() / 2)

	local select_x = math.min(icon_bitmap:left(), icon_text:left())
	local select_y = math.min(icon_bitmap:top(), icon_text:top())
	local select_w = math.max(icon_bitmap:right(), icon_text:right()) - select_x
	local select_h = math.max(icon_bitmap:bottom(), icon_text:bottom()) - select_y
	local select_panel = panel:panel({
		name = "select_panel",
		x = select_x,
		y = select_y,
		w = select_w,
		h = select_h
	})
	local icon = {
		panel = panel,
		open_window = icon_data.open_window,
		data = icon_data
	}
	local positions = string.split(pos, "_")
	local x = math.clamp(math.floor(tonumber(positions[1])), 1, window._max_icons_columns)
	local y = math.clamp(math.floor(tonumber(positions[2])), 1, window._max_icons_rows)

	self:_set_window_icon_position(window, icon, x, y)
end

function PlayerStatsGui:close_window()
	if #self._window_stack > 1 then
		local window = table.remove(self._window_stack)

		if window then
			window.panel:parent():remove(window.panel)
		end
	end
end

function PlayerStatsGui:open_window(name)
	local params = self.WINDOWS[name]

	if not params then
		return false
	end

	local window = {}
	local layer = #self._window_stack * 10
	local x = params.x or self._fullscreen_panel:x()
	local y = params.y or self._fullscreen_panel:y()
	local w = math.max(params.w or params.width or self._fullscreen_panel:w(), 1)
	local h = math.max(params.h or params.height or self._fullscreen_panel:h(), 1)
	local panel = self._fullscreen_panel:panel({
		x = x,
		y = y,
		w = w,
		h = h,
		layer = layer
	})
	window.panel = panel
	local bg_texture = params.bg_texture and self._textures[params.bg_texture]
	local window_header_l = params.window_header_l and self._textures[params.window_header_l] or self._textures.window_header_l
	local window_header_m = params.window_header_m and self._textures[params.window_header_m] or self._textures.window_header_m
	local window_header_r = params.window_header_r and self._textures[params.window_header_r] or self._textures.window_header_r
	local window_footer = params.window_footer and self._textures[params.window_footer]
	local close_btn = params.close_btn and self._textures[params.close_btn] or self._textures.close_btn
	local close_btn_over = params.close_btn_over and self._textures[params.close_btn_over] or self._textures.close_btn_over
	local header_left_text = params.header_left_text and managers.localization:format_text(params.header_left_text) or ""
	local header_right_text = params.header_right_text and managers.localization:format_text(params.header_right_text) or ""
	local add_close_btn = params.add_close_btn or false
	local title_text = params.title_text and managers.localization:format_text(params.title_text) or false
	local icons = params.icons
	local content = params.content

	if bg_texture then
		panel:bitmap({
			name = "bg",
			layer = 0,
			texture = bg_texture.texture,
			texture_rect = bg_texture.texture_rect,
			w = panel:w(),
			h = panel:h()
		})
	else
		panel:rect({
			alpha = 0.6,
			name = "bg",
			layer = 0,
			color = Color.black,
			w = panel:w(),
			h = panel:h()
		})
	end

	local header_panel = panel:panel({
		name = "header",
		h = 32,
		layer = 2
	})

	header_panel:bitmap({
		name = "header_l",
		h = 32,
		w = 32,
		texture = window_header_l.texture,
		texture_rect = window_header_l.texture_rect,
		rotation = window_header_l.rotation
	})
	header_panel:bitmap({
		name = "header_m",
		h = 32,
		x = 32,
		texture = window_header_m.texture,
		texture_rect = window_header_m.texture_rect,
		rotation = window_header_m.rotation,
		w = header_panel:w() - 64
	})
	header_panel:bitmap({
		name = "header_r",
		h = 32,
		w = 32,
		texture = window_header_r.texture,
		texture_rect = window_header_r.texture_rect,
		rotation = window_header_r.rotation,
		x = header_panel:w() - 32
	})
	header_panel:text({
		vertical = "center",
		name = "left_text",
		h = 24,
		align = "left",
		x = 24,
		layer = 1,
		text = header_left_text,
		font = system_font,
		font_size = system_font_size,
		color = tweak_data.screen_colors.text
	})
	header_panel:text({
		name = "right_text",
		h = 24,
		vertical = "center",
		align = "right",
		layer = 1,
		text = header_right_text,
		font = system_font,
		font_size = system_font_size,
		w = header_panel:w() - 5,
		color = tweak_data.screen_colors.text
	})

	if add_close_btn then
		local close_btn = panel:bitmap({
			name = "close_btn",
			h = 18,
			layer = 4,
			w = 18,
			alpha = 0.8,
			texture = close_btn.texture,
			texture_rect = close_btn.texture_rect,
			color = Color.black
		})
		local close_btn_over = panel:bitmap({
			name = "close_btn_over",
			h = 18,
			layer = 4,
			alpha = 0.8,
			w = 18,
			visible = false,
			texture = close_btn_over.texture,
			texture_rect = close_btn_over.texture_rect_over,
			color = Color.white
		})

		close_btn:set_righttop(panel:w() - 3, 3)
		close_btn_over:set_righttop(panel:w() - 3, 3)
	end

	local header_h = 24
	local footer_h = 0

	if window_footer then
		local footer = panel:bitmap({
			name = "footer",
			h = 8,
			layer = 2,
			texture = window_footer.texture,
			texture_rect = window_footer.texture_rect,
			rotation = window_footer.rotation,
			w = panel:w()
		})

		footer:set_leftbottom(0, panel:h())

		footer_h = 8
	end

	if title_text then
		local title_panel = panel:panel({
			name = "title",
			y = 24,
			layer = 1,
			w = panel:w(),
			h = large_font_size + 28
		})

		title_panel:text({
			vertical = "center",
			align = "center",
			y = 8,
			layer = 1,
			text = title_text,
			font = large_font,
			font_size = large_font_size,
			h = title_panel:h() - 8,
			color = tweak_data.screen_colors.text
		})
		title_panel:rect({
			layer = 0,
			color = tweak_data.screen_colors.ghost_color:with_alpha(0.7)
		})

		header_h = title_panel:bottom()
	end

	local w = math.min(panel:w(), self._panel:w())
	local h = math.min(panel:h() - header_h - footer_h, self._panel:h() - header_h)
	local content_panel = panel:panel({
		name = "content_panel",
		layer = 1,
		w = w,
		h = h
	})

	content_panel:set_center(panel:w() / 2, (panel:h() - header_h - footer_h) / 2 + header_h)
	content_panel:set_position(math.round(content_panel:x()), math.round(content_panel:y()))

	local num_columns = math.floor(content_panel:w() / ICON_WIDTH)
	local num_rows = math.floor(content_panel:h() / ICON_HEIGHT)
	window._max_icons_columns = num_columns
	window._max_icons_rows = num_rows

	if icons and table.size(icons) > 0 then
		window.icons = {}

		for pos, icon_data in pairs(icons) do
			self:_create_window_icon(window, icon_data, pos)
		end
	end

	local scroll_panel = content_panel:panel({
		layer = 1,
		name = "scroll_panel"
	})

	if content then
		local panel, type = nil
		local x = 10
		local y = 10
		window.content = {}

		for _, data in ipairs(content) do
			type = data.type

			if not data.unlock or callback(self, self, data.unlock)() then
				panel = scroll_panel:panel({
					h = 0,
					name = _,
					x = x,
					y = y,
					w = content_panel:w() - 20
				})

				if type == "text_value" then
					local text = panel:text({
						name = "text",
						text = (data.text and managers.localization:format_text(data.text) or "") .. ": ",
						font = data.font or small_font,
						font_size = data.font_size or small_font_size,
						color = data.color or tweak_data.screen_colors.text
					})
					local value = panel:text({
						name = "value",
						text = callback(self, self, data.value)(),
						font = data.font or small_font,
						font_size = data.font_size or small_font_size,
						color = data.color or tweak_data.screen_colors.text
					})

					make_fine_text(text)
					make_fine_text(value)
					text:set_position(0, 0)
					value:set_position(text:right(), 0)
					panel:set_size(math.max(text:right(), value:right()), math.max(text:bottom(), value:bottom()))
				elseif type == "image" then
					local texture = data.texture and self._textures[data.texture] or self._textures.icon_folder
					local image = panel:bitmap({
						name = "image",
						w = data.width or data.w,
						h = data.height or data.h,
						texture = texture.texture,
						texture_rect = texture.texture_rect,
						color = data.color or Color.white,
						alpha = data.alpha or 1
					})
					local text = panel:text({
						name = "text",
						text = data.text and managers.localization:format_text(data.text) or "",
						font = data.font or small_font,
						font_size = data.font_size or small_font_size,
						color = data.color or tweak_data.screen_colors.text
					})

					make_fine_text(text)
					text:set_left(image:right() + 5)
					text:set_center_y(image:center_y())
					panel:set_size(math.max(image:right(), text:right()), math.max(image:bottom(), text:bottom()))
				elseif type == "pie_chart" then
					panel:set_h(data.size or 50)

					local pie_chart_data = callback(self, self, data.data)()
					local pie_chart = managers.menu_component:create_pie_chart(panel, pie_chart_data, {
						data.height or data.h,
						w = data.width or data.w
					})
				elseif type == "text" then
					local text = panel:text({
						name = "text",
						text = data.text and managers.localization:format_text(data.text) or "",
						align = data.align or "left",
						font = data.font or small_font,
						font_size = data.font_size or small_font_size,
						color = data.color or tweak_data.screen_colors.text
					})
					local _, _, _, h = text:text_rect()

					text:set_h(h)
					panel:set_size(text:right(), text:bottom())
				elseif type == "divider" then
					panel:set_h(data.height or data.h or 0)
				end

				y = panel:bottom()
			end

			table.insert(window.content, {
				panel = panel,
				type = type
			})
		end

		scroll_panel:set_h(y)
	end

	self._window_stack[#self._window_stack + 1] = window

	self:update_content_visibility()
end

function PlayerStatsGui:_create_start_window()
	self:open_window("desktop")
end

function PlayerStatsGui:clbk_texture_loaded(tex_name)
	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready and tex_name == Idstring(texture_data.texture) then
			texture_data.ready = true
		end
	end

	self:_chk_load_complete()
end

function PlayerStatsGui:_chk_load_complete()
	if self._requesting then
		return
	end

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			return
		end
	end

	self:_create_start_window()
end

function PlayerStatsGui:_get_icon_from_pos(x, y)
	local active_window = self._window_stack[#self._window_stack]

	if active_window and active_window.icons and active_window.panel and alive(active_window.panel) then
		local content_panel = active_window.panel:child("content_panel")
		local pos_x = math.ceil((x - content_panel:x()) / ICON_WIDTH)
		local pos_y = math.ceil((y - content_panel:y()) / ICON_HEIGHT)

		if pos_x > 0 and pos_x <= active_window._max_icons_columns and pos_y > 0 and pos_y <= active_window._max_icons_rows then
			return active_window.icons[pos_y] and active_window.icons[pos_y][pos_x]
		end
	end
end

function PlayerStatsGui:mouse_released(button, x, y)
	if self._icon_pressed and self._icon_pressed.open_window then
		local x, y = managers.mouse_pointer:modified_fullscreen_16_9_mouse_pos()
		local icon = self:_get_icon_from_pos(x, y)

		if icon == self._icon_pressed then
			self:open_window(self._icon_pressed.open_window)
		end
	end

	self._icon_pressed = nil
end

function PlayerStatsGui:mouse_pressed(button, x, y)
	local x, y = managers.mouse_pointer:modified_fullscreen_16_9_mouse_pos()
	local icon = self:_get_icon_from_pos(x, y)

	if icon and icon.over then
		self._icon_pressed = icon
	else
		self._icon_pressed = nil
		local active_window = self._window_stack[#self._window_stack]
		local close_btn = active_window.panel:child("close_btn")
		local close_btn_over = active_window.panel:child("close_btn_over")

		if alive(close_btn) and close_btn:inside(x, y) then
			self:close_window()
		end
	end
end

function PlayerStatsGui:mouse_moved(o, x, y)
	local used = false
	local pointer = "arrow"
	local active_window = self._window_stack[#self._window_stack]

	if not active_window or not alive(active_window.panel) then
		return used, pointer
	end

	local x, y = managers.mouse_pointer:modified_fullscreen_16_9_mouse_pos()
	local icon = self:_get_icon_from_pos(x, y)

	if icon and icon.panel:child("select_panel"):inside(x, y) then
		icon.panel:set_debug(true)

		if not icon.over then
			icon.over = true

			icon.panel:child("icon_bitmap"):hide()
			icon.panel:child("icon_bitmap_over"):show()
			icon.panel:child("icon_text"):set_color(Color.black)
			icon.panel:child("icon_text_over"):show()
			managers.menu_component:post_event("highlight")

			if self._selected_icon then
				self._selected_icon.over = false

				self._selected_icon.panel:child("icon_bitmap"):show()
				self._selected_icon.panel:child("icon_bitmap_over"):hide()
				self._selected_icon.panel:child("icon_text"):set_color(Color.white)
				self._selected_icon.panel:child("icon_text_over"):hide()
			end

			self._selected_icon = icon
		end

		used = true
		pointer = "link"
	elseif self._selected_icon and self._selected_icon.over then
		self._selected_icon.over = false

		self._selected_icon.panel:child("icon_bitmap"):show()
		self._selected_icon.panel:child("icon_bitmap_over"):hide()
		self._selected_icon.panel:child("icon_text"):set_color(Color.white)
		self._selected_icon.panel:child("icon_text_over"):hide()

		self._selected_icon = nil
	end

	if not used then
		local close_btn = active_window.panel:child("close_btn")
		local close_btn_over = active_window.panel:child("close_btn_over")

		if alive(close_btn) and alive(close_btn_over) then
			local inside = close_btn:inside(x, y)

			if inside then
				if close_btn:visible() then
					close_btn:hide()
					close_btn_over:show()
				end

				used = true
				pointer = "link"
			elseif close_btn_over:visible() then
				close_btn:show()
				close_btn_over:hide()
			end
		end
	end

	return used, pointer
end

function PlayerStatsGui:back_callback()
	local block_back = #self._window_stack > 1 and true or false

	if block_back then
		self:close_window()
	end

	return block_back
end

function PlayerStatsGui:input_focus()
end

function PlayerStatsGui:update_content_visibility()
	local active_window = self._window_stack[#self._window_stack]

	if active_window and active_window.content and alive(active_window.panel) then
		local content_panel = active_window.panel:child("content_panel")
		local scroll_panel = content_panel:child("scroll_panel")

		for _, content in ipairs(active_window.content) do
			if content.type == "pie_chart" then
				content.panel:set_visible(content.panel:top() + scroll_panel:top() >= 0 and content.panel:bottom() + scroll_panel:top() <= content_panel:h())
			end
		end
	end
end

function PlayerStatsGui:close()
	for tex_id, texture_data in pairs(self._textures) do
		if texture_data.index then
			managers.menu_component:unretrieve_texture(texture_data.texture, texture_data.index)

			texture_data.ready = false
		end
	end

	if alive(self._panel) then
		self._ws:panel():remove(self._panel)

		self._panel = nil
	end

	if alive(self._fullscreen_panel) then
		self._fullscreen_ws:panel():remove(self._fullscreen_panel)

		self._fullscreen_panel = nil
	end
end

function PlayerStatsGui:_get_player_time()
	return "_get_player_time"
end

function PlayerStatsGui:_get_player_level()
	local player_level = managers.experience:current_level()

	return tostring(player_level)
end

function PlayerStatsGui:_get_player_rank()
	local player_rank = managers.experience:current_rank()

	return managers.experience:rank_string(player_rank)
end

function PlayerStatsGui:_get_heists_pie_chart_data()
	local data = {}

	for i = 1, 4 do
		table.insert(data, {
			name = "NAME" .. tostring(i),
			value = i * 2
		})
	end

	return data
end
