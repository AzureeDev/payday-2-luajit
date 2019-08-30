MenuNodeCreditsGui = MenuNodeCreditsGui or class(MenuNodeGui)
MenuNodeCreditsGui.PATH = "gamedata/"
MenuNodeCreditsGui.FILE_EXTENSION = "credits"

function MenuNodeCreditsGui:init(node, layer, parameters)
	MenuNodeCreditsGui.super.init(self, node, layer, parameters)
	self:_build_credits_panel(node._parameters.credits_file)
	managers.music:post_event(managers.music:jukebox_menu_track("credits"))
end

function MenuNodeCreditsGui:_build_credits_panel(file)
	local lang_key = SystemInfo:language():key()
	local files = {
		[Idstring("german"):key()] = "_german",
		[Idstring("french"):key()] = "_french",
		[Idstring("spanish"):key()] = "_spanish",
		[Idstring("italian"):key()] = "_italian"
	}

	if Application:region() == Idstring("eu") and file == "eula" then
		files[Idstring("english"):key()] = "_uk"
	end

	if (file == "eula" or file == "trial") and files[lang_key] then
		file = file .. files[lang_key] or file
	end

	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), (self.PATH .. file):id())
	local ypos = 0
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local res = RenderSettings.resolution
	local global_scale = 1
	local side_padding = 200
	self._fullscreen_ws = managers.gui_data:create_fullscreen_16_9_workspace()
	self._clipping_panel = self._fullscreen_ws:panel():panel({})
	local bg = self._clipping_panel:rect({
		visible = true,
		color = Color.black / 2,
		layer = self.layers.background
	})

	bg:set_top(0)
	bg:set_left(0)
	bg:set_height(self._clipping_panel:height())
	bg:set_width(self._clipping_panel:width())

	local text_offset = self._clipping_panel:height() - 50
	self._credits_panel = self._clipping_panel:panel({
		x = safe_rect_pixels.x + side_padding,
		y = text_offset,
		w = safe_rect_pixels.width - side_padding * 2,
		h = self._fullscreen_ws:panel():h()
	})

	self._credits_panel:set_center_x(self._credits_panel:parent():w() / 2)

	local text_width = self._credits_panel:width()

	bg:set_width(text_width)
	bg:set_size(self._clipping_panel:size())
	self._clipping_panel:gradient({
		y = 0,
		visible = false,
		orientation = "vertical",
		x = 0,
		w = self._clipping_panel:width(),
		h = 75 * global_scale,
		layer = self.layers.items + 1,
		gradient_points = {
			0,
			Color(1, 0, 0, 0),
			1,
			Color(0, 0, 0, 0)
		}
	})
	self._clipping_panel:gradient({
		visible = false,
		orientation = "vertical",
		x = 0,
		y = self._clipping_panel:height() - 75 * global_scale,
		w = self._clipping_panel:width(),
		h = 75 * global_scale,
		layer = self.layers.items + 1,
		gradient_points = {
			0,
			Color(0, 0, 0, 0),
			1,
			Color(1, 0, 0, 0)
		}
	})

	local function animate_fade_in(o)
		over(1, function (p)
			o:set_alpha(p)
		end)
	end

	bg:animate(animate_fade_in)

	local blur = self._fullscreen_ws:panel():bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h(),
		layer = self.layers.background - 1
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	blur:animate(func)

	local commands = {}

	for _, data in ipairs(list) do
		if data._meta == "text" then
			local height = 50
			local color = Color(1, 1, 0, 0)

			if data.type == "title" then
				height = 24
				color = Color(255, 0, 161, 255) / 255
			elseif data.type == "name" then
				height = 24
				color = Color(1, 0.9, 0.9, 0.9)
			elseif data.type == "fill" then
				height = 26
				color = Color(1, 1, 1, 1)
			elseif data.type == "song" then
				height = 24
				color = Color(1, 0.8, 0.8, 0.8)
			elseif data.type == "song-credit" then
				height = 24
				color = Color(1, 0.5, 0.5, 0.5)
			elseif data.type == "image-text" then
				height = 24
				color = Color(1, 0.5, 0.5, 0.5)
			elseif data.type == "eula" then
				height = 22
				color = Color(1, 0.7, 0.7, 0.7)
			end

			height = height * global_scale
			local text_field = self._credits_panel:text({
				vertical = "bottom",
				h = 0,
				wrap = true,
				align = "center",
				word_wrap = true,
				halign = "left",
				x = 0,
				text = data.text,
				y = ypos,
				w = text_width,
				font_size = height,
				font = self.font,
				color = color,
				layer = self.layers.items
			})
			local _, _, _, h = text_field:text_rect()

			text_field:set_height(h)

			ypos = ypos + h
		elseif data._meta == "image" then
			local scale = (data.scale or 1) * global_scale
			local bitmap = self._credits_panel:bitmap({
				x = 0,
				layer = self.layers.items,
				y = ypos,
				texture = data.src
			})

			print(res.x, bitmap:width() * scale)
			bitmap:set_width(bitmap:width() * scale)
			bitmap:set_height(bitmap:height() * scale)
			bitmap:set_center_x(self._credits_panel:width() / 2)

			ypos = ypos + bitmap:height()
		elseif data._meta == "br" then
			ypos = ypos + 28 * global_scale
		elseif data._meta == "command" then
			table.insert(commands, {
				pos = ypos - text_offset + (data.offset or 0) * global_scale + self._clipping_panel:height() / 2,
				cmd = data.cmd,
				param = data.param
			})
		end
	end

	self._credits_panel:set_height(ypos + 50)

	local function scroll_func(o)
		local y = o:top()
		local speed = 50 * global_scale

		while true do
			y = y - coroutine.yield() * speed

			o:set_top(math.round(y))

			if commands[1] and y < -commands[1].pos then
				local cmd = table.remove(commands, 1)

				if cmd.cmd == "speed" then
					speed = cmd.param * global_scale
				elseif cmd.cmd == "close" then
					managers.menu:back()

					return
				elseif cmd.cmd == "stop" then
					return
				end
			end
		end
	end

	self._credits_panel_thread = self._credits_panel:animate(scroll_func)
end

function MenuNodeCreditsGui:_setup_panels(node)
	MenuNodeCreditsGui.super._setup_panels(self, node)
end

function MenuNodeCreditsGui:_create_menu_item(row_item)
	MenuNodeCreditsGui.super._create_menu_item(self, row_item)
end

function MenuNodeCreditsGui:_setup_item_panel_parent(safe_rect)
	MenuNodeCreditsGui.super._setup_item_panel_parent(self, safe_rect)
end

function MenuNodeCreditsGui:_setup_item_panel(safe_rect, res)
	MenuNodeCreditsGui.super._setup_item_panel(self, safe_rect, res)
end

function MenuNodeCreditsGui:resolution_changed()
	MenuNodeCreditsGui.super.resolution_changed(self)
end

function MenuNodeCreditsGui:set_visible(visible)
	MenuNodeCreditsGui.super.set_visible(self, visible)

	if visible then
		self._fullscreen_ws:show()
	else
		self._fullscreen_ws:hide()
	end
end

function MenuNodeCreditsGui:close(...)
	self._credits_panel:stop(self._credits_panel_thread)
	managers.gui_data:destroy_workspace(self._fullscreen_ws)
	MenuNodeCreditsGui.super.close(self, ...)
	managers.music:post_event(managers.music:jukebox_menu_track("mainmenu"))
end
