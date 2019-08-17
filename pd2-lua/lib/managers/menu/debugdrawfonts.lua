DebugDrawFonts = DebugDrawFonts or class()

function DebugDrawFonts:init(ws)
	self._ws = ws
	self._panel = ws:panel():panel({
		layer = 1000
	})
	self._toggle = false
	local massive_font = tweak_data.menu.pd2_massive_font
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local small_font = tweak_data.menu.pd2_small_font
	local massive_font_size = tweak_data.menu.pd2_massive_font_size
	local large_font_size = tweak_data.menu.pd2_large_font_size
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local text_of_texts_id = "debug_debug_font_draw_text"
	local macroes_of_texts = {}
	local localized_text = managers.localization:text(text_of_texts_id, macroes_of_texts)
	local width = self._panel:w() - 60
	local height = self._panel:h() - 60
	local left_side = self._panel:panel()

	left_side:set_size(width / 2 - 5, height)
	left_side:set_position(40, 40)
	left_side:rect({
		alpha = 0.4,
		color = Color.black
	})

	local right_side = self._panel:panel()

	right_side:set_size(width / 2 - 5, height)
	right_side:set_righttop(self._panel:w() - 40, 40)
	right_side:rect({
		alpha = 0.4,
		color = Color.white
	})

	local blur = self._panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		layer = -1,
		w = self._panel:w(),
		h = self._panel:h()
	})

	local function func(o)
		over(0.6, function (p)
			o:set_alpha(p)
		end)
	end

	blur:animate(func)

	local fonts = {
		{
			large_font,
			large_font_size
		},
		{
			medium_font,
			medium_font_size
		},
		{
			small_font,
			small_font_size
		}
	}
	local sides = {
		left_side,
		right_side
	}
	local x = 10

	for i, side in pairs(sides) do
		local y = 10

		for _, font_data in ipairs(fonts) do
			local text = side:text({
				wrap = true,
				word_wrap = true,
				layer = 2,
				font = font_data[1],
				font_size = font_data[2],
				x = x,
				y = y,
				text = localized_text,
				w = side:w() - 2 * x
			})

			if i == 2 then
				text:set_text(utf8.to_upper(text:text()))
			end

			local _, _, tw, th = text:text_rect()
			y = y + math.round(th + 0)
			local text = side:text({
				wrap = true,
				word_wrap = true,
				layer = 2,
				font = font_data[1],
				font_size = font_data[2],
				x = x,
				y = y,
				text = localized_text,
				w = side:w() - 2 * x
			})

			if i == 2 then
				text:set_text(utf8.to_upper(text:text()))
			end

			local _, _, tw, th = text:text_rect()

			text:set_size(tw, th)
			side:rect({
				alpha = 0.6,
				layer = 1,
				color = i == 1 and Color.white or Color.black
			}):set_shape(text:shape())

			y = y + math.round(th + 20)
		end
	end
end

function DebugDrawFonts:toggle_debug()
	self._toggle = not self._toggle

	self._panel:set_debug(self._toggle)
end

function DebugDrawFonts:reload()
	self:close()
	self:init(self._ws)
end

function DebugDrawFonts:set_enabled(enabled)
	self._panel:set_visible(enabled)
end

function DebugDrawFonts:close()
	self._panel:parent():remove(self._panel)
end
