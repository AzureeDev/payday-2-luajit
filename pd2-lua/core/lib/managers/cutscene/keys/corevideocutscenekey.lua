require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")

CoreVideoCutsceneKey = CoreVideoCutsceneKey or class(CoreCutsceneKeyBase)
CoreVideoCutsceneKey.ELEMENT_NAME = "video"
CoreVideoCutsceneKey.NAME = "Video Playback"

CoreVideoCutsceneKey:register_serialized_attribute("video", "")
CoreVideoCutsceneKey:register_serialized_attribute("gui_layer", 2, tonumber)
CoreVideoCutsceneKey:register_serialized_attribute("loop", 0, tonumber)
CoreVideoCutsceneKey:register_serialized_attribute("speed", 1, tonumber)

function CoreVideoCutsceneKey:__tostring()
	return string.format("Play video \"%s\".", self:video())
end

function CoreVideoCutsceneKey:can_evaluate_with_player(player)
	return true
end

function CoreVideoCutsceneKey:play(player, undo, fast_forward)
	local video_ws = managers.cutscene:video_workspace()
	local was_paused = self._paused
	self._paused = false

	if undo then
		self:_stop()
	else
		if alive(self._video_object) then
			if was_paused then
				self:_play_video(video_ws)
			end

			if self:loop() < self._video_object:loop_count() then
				self:_stop()
				managers.cutscene:_cleanup(true)
				managers.overlay_effect:play_effect(tweak_data.player.overlay.cutscene_fade_out)
			end
		elseif self:video() ~= "" then
			self:_play_video(video_ws)
		end

		return true
	end
end

function CoreVideoCutsceneKey:unload(player)
	self:_stop()
end

function CoreVideoCutsceneKey:update(player, time)
	if self.is_in_cutscene_editor then
		self:_handle_cutscene_editor_scrubbing(time)
	end
end

function CoreVideoCutsceneKey:is_valid_video(value)
	if self.is_in_cutscene_editor then
		return value ~= nil and value ~= "" and SystemFS:exists(value) and not SystemFS:is_dir(value)
	else
		return value ~= nil and value ~= ""
	end
end

function CoreVideoCutsceneKey:on_attribute_changed(attribute_name, value, previous_value)
	self:_stop()
end

function CoreVideoCutsceneKey:_handle_cutscene_editor_scrubbing(time)
	if self._last_evaluated_time then
		if time == self._last_evaluated_time then
			self._stopped_frame_count = (self._stopped_frame_count or 0) + 1

			if self._stopped_frame_count > 5 then
				self._stopped_frame_count = nil

				self:pause()
			end
		else
			self._stopped_frame_count = nil

			if alive(self._video_object) and (time < self._last_evaluated_time or time - self._last_evaluated_time > 1) then
				self._video_object:goto_time(time)
			end

			self:resume()
		end
	end

	self._last_evaluated_time = time
end

function CoreVideoCutsceneKey:_play_video(video_ws)
	if not alive(self._video_object) or self:video() ~= self._video_played or self:loop() ~= self._loop_played or self:speed() ~= self._speed_played then
		video_ws:panel():clear()
		video_ws:show()
		video_ws:panel():rect({
			width = video_ws:width(),
			height = video_ws:height(),
			color = Color.black
		})

		self._video_object = video_ws:panel():video({
			video = self:video(),
			loop = self:loop() > 0,
			speed = self:speed(),
			layer = self:gui_layer()
		})
		self._video_played = self:video()
		self._loop_played = self:loop()
		self._speed_played = self:speed()
		local width, height = get_fit_size(self._video_object:video_width(), self._video_object:video_height(), video_ws:width(), video_ws:height())

		self._video_object:set_size(width, height)
		self._video_object:set_center(video_ws:width() / 2, video_ws:height() / 2)
		self._video_object:set_volume_gain(Global.video_sound_volume or 1)
	end

	self._video_object:play()
end

function CoreVideoCutsceneKey:_stop()
	if alive(self._video_object) then
		local video_ws = managers.cutscene:video_workspace()

		video_ws:panel():clear()
		video_ws:hide()

		self._video_object = nil
	end

	self._last_evaluated_time = nil
end

function CoreVideoCutsceneKey:pause()
	if not self._paused and alive(self._video_object) then
		self._video_object:pause()

		self._paused = true
	end
end

function CoreVideoCutsceneKey:resume()
	if self._paused and alive(self._video_object) then
		self._video_object:play()

		self._paused = false
	end
end
