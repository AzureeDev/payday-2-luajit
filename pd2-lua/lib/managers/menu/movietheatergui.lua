local large_font = tweak_data.menu.pd2_large_font
local large_font_size = tweak_data.menu.pd2_large_font_size
local movie_item_font = tweak_data.menu.pd2_large_font
local movie_item_font_size = 28
MovieListItem = MovieListItem or class(ListItem)
MovieListItem.HEIGHT = 60
MovieListItem.TEXT_OFFSET = 15
MovieListItem.SELECT_COLOR = tweak_data.screen_colors.button_stage_2
MovieListItem.NORMAL_COLOR = tweak_data.screen_colors.button_stage_3

function MovieListItem:init(parent, item, owner)
	local row_w = parent:row_w()

	MovieListItem.super.init(self, parent, {
		input = true,
		h = self.HEIGHT,
		w = row_w
	})

	self._owner = owner
	self._item = item
	self._title = self:fine_text({
		text = utf8.to_upper(item.title),
		font = movie_item_font,
		font_size = movie_item_font_size,
		color = self.NORMAL_COLOR,
		x = self.HEIGHT,
		y = self.TEXT_OFFSET
	})
	local type_text = ""

	if item.type then
		type_text = managers.localization:to_upper_text(item.type)
	end

	self._kindof = self:fine_text({
		text = type_text,
		font = movie_item_font,
		font_size = movie_item_font_size,
		color = self.NORMAL_COLOR,
		x = row_w / 2 - self.HEIGHT,
		y = self.TEXT_OFFSET
	})
	local time_text = "--:--"

	if item.duration then
		time_text = item.duration
	end

	self._time = self:fine_text({
		text = time_text,
		font = movie_item_font,
		font_size = movie_item_font_size,
		color = self.NORMAL_COLOR,
		x = row_w - 2 * self.HEIGHT,
		y = self.TEXT_OFFSET
	})
	self._click = self:panel()

	self._click:set_w(self:w())

	self._select_panel = self._panel:panel({
		layer = self:layer() - 1,
		w = self:w(),
		h = self:h()
	})

	self._select_panel:set_lefttop(self:lefttop())
	self._select_panel:rect({
		color = 0.6 * self.NORMAL_COLOR
	})

	if item.index % 2 == 0 then
		local grayed_panel = self._panel:panel({
			layer = self:layer() - 2,
			w = self:w(),
			h = self:h()
		})

		grayed_panel:set_lefttop(self:lefttop())
		grayed_panel:rect({
			color = Color.black:with_alpha(0.4)
		})
	end

	self:_selected_changed(false)
end

function MovieListItem:_selected_changed(state)
	self._select_panel:set_visible(state)
	self._title:set_color(state and self.SELECT_COLOR or self.NORMAL_COLOR)
	self._kindof:set_color(state and self.SELECT_COLOR or self.NORMAL_COLOR)
	self._time:set_color(state and self.SELECT_COLOR or self.NORMAL_COLOR)
end

function MovieListItem:mouse_clicked(o, button, x, y)
	if button == Idstring("0") and self._click:inside(x, y) then
		self._owner:play_movie(self._item)

		return true
	end

	MovieListItem.super.mouse_clicked(self, o, button, x, y)
end

MovieTheaterGui = MovieTheaterGui or class(ExtendedPanel)

function MovieTheaterGui:init(ws, fullscreen_ws, node)
	MovieTheaterGui.super.init(self, ws:panel())

	self._music_volume = (managers.user:get_setting("music_volume") or 100) / 100
	self._sfx_volume = (managers.user:get_setting("sfx_volume") or 100) / 100
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._node = node
	self._main_panel = ToggleInputPanel:new(self, {
		input = true
	})
	self._multiple = node:parameters().multiple or false

	if self._multiple then
		self:_create_movie_list()
	else
		self:_play_first_movie()
	end
end

function MovieTheaterGui:close()
	self:reset_video()
	self:remove_self()
end

function MovieTheaterGui:_create_movie_list()
	local title_text = self._main_panel:text({
		layer = 1,
		text = managers.localization:to_upper_text("menu_movie_theater"),
		font = large_font,
		font_size = large_font_size,
		color = tweak_data.screen_colors.text
	})

	ExtendedPanel.make_fine_text(title_text)

	local t_y = title_text:bottom() + 30
	self._scroll = ScrollItemList:new(self._main_panel, {
		scrollbar_padding = 10,
		input_focus = true,
		bar_minimum_size = 16,
		input = true,
		padding = 0,
		y = t_y,
		h = self._main_panel:h() - t_y - 50,
		w = self._main_panel:w()
	}, {
		padding = 0
	})

	BoxGuiObject:new(self._scroll:scroll_item():scroll_panel(), {
		w = self._scroll:canvas():w(),
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local back_panel = self._main_panel:panel({
		layer = -1,
		w = self._scroll:canvas():w(),
		h = self._scroll:h()
	})

	back_panel:set_lefttop(self._scroll:lefttop())
	back_panel:rect({
		color = Color.black:with_alpha(0.4)
	})

	local canvas = self._scroll:canvas()

	if tweak_data.movies then
		for i, item in ipairs(tweak_data.movies) do
			item.index = i

			self._scroll:add_item(MovieListItem:new(canvas, item, self), true)
		end
	end
end

function MovieTheaterGui:_play_first_movie()
	if tweak_data.movies and #tweak_data.movies > 0 then
		local item = tweak_data.movies[1]

		self:play_movie(item, "nonblock_back")
	else
		managers.menu:back(true)
	end
end

function MovieTheaterGui:update(...)
	if alive(self._video_gui) and self._video_gui:loop_count() > 0 then
		self:reset_video()

		if not self._multiple then
			managers.menu:back(true)
		end
	end
end

function MovieTheaterGui:input_focus()
	return self._multiple and 1
end

function MovieTheaterGui:move_up()
	if alive(self._video_gui) then
		self:reset_video()
	else
		self._scroll:move_up()
	end
end

function MovieTheaterGui:move_down()
	if alive(self._video_gui) then
		self:reset_video()
	else
		self._scroll:move_down()
	end
end

function MovieTheaterGui:confirm_pressed()
	if alive(self._video_gui) then
		self:reset_video()
	elseif self._scroll:selected_item() and self._scroll:selected_item()._item then
		self:play_movie(self._scroll:selected_item()._item)
	end
end

function MovieTheaterGui:back_pressed()
	if alive(self._video_gui) then
		self:reset_video()
	end
end

function MovieTheaterGui:mouse_clicked(o, button, x, y)
	return MovieTheaterGui.super.mouse_clicked(self, o, button, x, y)
end

function MovieTheaterGui:play_movie(item, blockingtag)
	if alive(self._video_gui) then
		self:reset_video()
	end

	if not item.file or not DB:has(Idstring("movie"), Idstring(item.file)) then
		return
	end

	self:reset_video()

	local screen_width = self._fullscreen_ws:width()
	local screen_height = self._fullscreen_ws:height()
	local src_width, src_height = managers.gui_data:get_base_res()
	local dest_width, dest_height = nil

	if src_width / src_height > screen_width / screen_height then
		dest_width = screen_width
		dest_height = src_height * dest_width / src_width
	else
		dest_height = screen_height
		dest_width = src_width * dest_height / src_height
	end

	local x = (screen_width - dest_width) / 2
	local y = (screen_height - dest_height) / 2
	self._video_gui = self._fullscreen_ws:panel():video({
		video = item.file,
		x = x,
		y = y,
		width = dest_width,
		height = dest_height,
		layer = tweak_data.gui.ATTRACT_SCREEN_LAYER
	})

	self._video_gui:play()
	self._video_gui:set_volume_gain(managers.music:has_music_control() and self._sfx_volume or 0)
	managers.music:set_volume(0)
	SoundDevice:set_rtpc("option_sfx_volume", 0)
	managers.mouse_pointer:disable()

	self._node:parameters().block_back = (blockingtag or "block_back") == "block_back"
end

function MovieTheaterGui:reset_video()
	if alive(self._video_gui) then
		self._video_gui:stop()
		self._fullscreen_ws:panel():remove(self._video_gui)

		self._video_gui = nil
	end

	managers.mouse_pointer:enable()

	self._node:parameters().block_back = false

	managers.music:set_volume(self._music_volume)
	SoundDevice:set_rtpc("option_sfx_volume", self._sfx_volume * 100)
end
