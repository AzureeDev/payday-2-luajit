TvGui = TvGui or class()

function TvGui:init(unit)
	self._unit = unit
	self._visible = true
	self._gui_object = self._gui_object or "gui_name"
	self._new_gui = World:newgui()

	self:add_workspace(self._unit:get_object(Idstring(self._gui_object)))
	self:setup()
	self._unit:set_extension_update_enabled(Idstring("tv_gui"), false)
end

function TvGui:add_workspace(gui_object)
	self._ws = self._new_gui:create_object_workspace(0, 0, gui_object, Vector3(0, 0, 0))
end

function TvGui:setup()
	self._video_panel = self._ws:panel():video({
		loop = true,
		visible = true,
		layer = 10,
		video = self._video
	})

	if not _G.IS_VR then
		self._video_panel:set_render_template(Idstring("gui:DIFFUSE_TEXTURE:VERTEX_COLOR:VERTEX_COLOR_ALPHA"))
	end

	if not self._playing then
		self._video_panel:pause()
	end
end

function TvGui:start()
	if not self._playing then
		self._video_panel:play()

		self._playing = true
	end
end

function TvGui:pause()
	if self._playing then
		self._video_panel:pause()

		self._playing = nil
	end
end

function TvGui:stop()
	if self._playing then
		self._video_panel:pause()
		self._video_panel:rewind()

		self._playing = nil
	end
end

function TvGui:lock_gui()
	self._ws:set_cull_distance(self._cull_distance)
	self._ws:set_frozen(true)
end

function TvGui:destroy()
	if alive(self._new_gui) and alive(self._ws) then
		self._new_gui:destroy_workspace(self._ws)

		self._ws = nil
		self._new_gui = nil
	end
end

function TvGui:save(data)
	data.TvGui = {
		playing = self._playing,
		play_position = self._video_panel:current_frame()
	}
end

function TvGui:load(data)
	if data.TvGui.playing then
		self._video_panel:play()

		self._playing = true
	end

	self._video_panel:goto_frame(data.TvGui.play_position)
end
