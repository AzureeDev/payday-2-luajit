NewsFeedGui = NewsFeedGui or class(TextBoxGui)
NewsFeedGui.PRESENT_TIME = 0.5
NewsFeedGui.SUSTAIN_TIME = 6
NewsFeedGui.REMOVE_TIME = 0.5
NewsFeedGui.MAX_NEWS = 5

function NewsFeedGui:init(ws)
	self._ws = ws

	self:_create_gui()
	self:make_news_request()
end

function NewsFeedGui:update(t, dt)
	if not self._titles then
		return
	end

	if self._news and #self._titles > 0 then
		local color = math.lerp(tweak_data.screen_colors.button_stage_2, tweak_data.screen_colors.button_stage_3, (1 + math.sin(t * 360)) / 2)

		self._title_panel:child("title"):set_color(self._mouse_over and tweak_data.screen_colors.button_stage_2 or color)

		if self._next then
			self._next = nil
			self._news.i = self._news.i + 1

			if self._news.i > #self._titles then
				self._news.i = 1
			end

			self._title_panel:child("title"):set_text(utf8.to_upper("(" .. self._news.i .. "/" .. #self._titles .. ") " .. self._titles[self._news.i]))

			local _, _, w, h = self._title_panel:child("title"):text_rect()

			self._title_panel:child("title"):set_h(h)
			self._title_panel:set_w(w + 10)
			self._title_panel:set_h(h)
			self._title_panel:set_left(self._panel:w())
			self._title_panel:set_bottom(self._panel:h())

			self._present_t = t + self.PRESENT_TIME
		end

		if self._present_t then
			self._title_panel:set_left(0 - (managers.gui_data:safe_scaled_size().x + self._title_panel:w()) * (self._present_t - t) / self.PRESENT_TIME)

			if self._present_t < t then
				self._title_panel:set_left(0)

				self._present_t = nil
				self._sustain_t = t + self.SUSTAIN_TIME
			end
		end

		if self._sustain_t and self._sustain_t < t then
			self._sustain_t = nil
			self._remove_t = t + self.REMOVE_TIME
		end

		if self._remove_t then
			self._title_panel:set_left(0 - (managers.gui_data:safe_scaled_size().x + self._title_panel:w()) * (1 - (self._remove_t - t) / self.REMOVE_TIME))

			if self._remove_t < t then
				self._title_panel:set_left(0 - (managers.gui_data:safe_scaled_size().x + self._title_panel:w()))

				self._remove_t = nil
				self._next = true
			end
		end
	end
end

function NewsFeedGui:make_news_request()
	if SystemInfo:distribution() == Idstring("STEAM") then
		print("make_news_request()")
		Steam:http_request("http://steamcommunity.com/games/218620/rss", callback(self, self, "news_result"))
	end
end

function NewsFeedGui:news_result(success, body)
	print("news_result()", success)

	if not alive(self._panel) then
		return
	end

	if success then
		self._titles = self:_get_text_block(body, "<title>", "</title>", self.MAX_NEWS)
		self._links = self:_get_text_block(body, "<link><![CDATA[", "]]></link>", self.MAX_NEWS)
		self._news = {
			i = 0
		}
		self._next = true

		self._panel:child("title_announcement"):set_visible(#self._titles > 0)
	end
end

function NewsFeedGui:_create_gui()
	local size = managers.gui_data:scaled_size()
	self._panel = self._ws:panel():panel({
		name = "main",
		h = 44,
		w = size.width / 2
	})

	self._panel:bitmap({
		texture = "guis/textures/textboxbg",
		name = "bg_bitmap",
		visible = false,
		layer = 0,
		color = Color.black,
		w = self._panel:w(),
		h = self._panel:h()
	})
	self._panel:text({
		visible = false,
		name = "title_announcement",
		vertical = "top",
		hvertical = "top",
		align = "left",
		halign = "left",
		rotation = 360,
		text = managers.localization:to_upper_text("menu_announcements"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = Color.white
	})

	self._title_panel = self._panel:panel({
		layer = 1,
		name = "title_panel"
	})

	self._title_panel:text({
		name = "title",
		vertical = "bottom",
		hvertical = "bottom",
		align = "left",
		text = "",
		halign = "left",
		rotation = 360,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = Color(0.75, 0.75, 0.75)
	})
	self._title_panel:set_right(-10)
	self._panel:set_bottom(self._panel:parent():h())
end

function NewsFeedGui:_get_text_block(s, sp, ep, max_results)
	local result = {}
	local len = string.len(s)
	local i = 1

	local function f(s, sp, ep, max_results)
		local s1, e1 = string.find(s, sp, 1, true)

		if not e1 then
			return
		end

		local s2, e2 = string.find(s, ep, e1, true)

		table.insert(result, string.sub(s, e1 + 1, s2 - 1))
	end

	while i < len and max_results > #result do
		local s1, e1 = string.find(s, "<item>", i, true)

		if not e1 then
			break
		end

		local s2, e2 = string.find(s, "</item>", e1, true)
		local item_s = string.sub(s, e1 + 1, s2 - 1)

		f(item_s, sp, ep, max_results)

		i = e1
	end

	return result
end

function NewsFeedGui:mouse_moved(x, y)
	local inside = self._panel:inside(x, y)
	self._mouse_over = inside

	return inside, inside and "link"
end

function NewsFeedGui:mouse_pressed(button, x, y)
	if not self._news then
		return
	end

	if button == Idstring("0") and self._panel:inside(x, y) then
		if MenuCallbackHandler:is_overlay_enabled() then
			Steam:overlay_activate("url", self._links[self._news.i])
		else
			managers.menu:show_enable_steam_overlay()
		end

		return true
	end
end

function NewsFeedGui:close()
	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end
end
