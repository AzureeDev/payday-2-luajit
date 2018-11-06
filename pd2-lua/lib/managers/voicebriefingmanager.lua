core:import("CoreSubtitlePresenter")

VoiceBriefingManager = VoiceBriefingManager or class()

function VoiceBriefingManager:init()
	self:_clear_event()
	self:_setup()
end

function VoiceBriefingManager:_setup()
	self._sound_source = SoundDevice:create_source("VoiceBriefingManager")

	managers.subtitle:set_presenter(CoreSubtitlePresenter.OverlayPresenter:new(tweak_data.menu.pd2_medium_font, tweak_data.menu.pd2_medium_font_size))
end

function VoiceBriefingManager:_set_parameters(params)
	params = params or {}
	self._params.show_subtitle = params.show_subtitle and true or false

	if params.listener then
		self:add_listener(params.listener)
	end

	if params.listeners then
		for _, listener in pairs(params.listeners) do
			self:add_listener(listener)
		end
	end
end

function VoiceBriefingManager:_debug_callback(...)
	Application:debug(inspect({
		...
	}))
	self:_sound_callback(...)
end

function VoiceBriefingManager:_sound_callback(instance, sound_source, event_type, cookie, label, identifier, position)
	if event_type == "end_of_event" then
		self:_end_of_event(cookie)
	elseif event_type == "marker" then
		if label then
			self:_play_subtitle(label, cookie)
		end
	elseif event_type == "duration" then
		self:_set_duration(label, cookie)
	end
end

function VoiceBriefingManager:_end_of_event(cookie)
	if self._listeners_enabled then
		for _, listener in ipairs(self._listeners) do
			if listener.end_of_event then
				listener.clbk("end_of_event", self._event_name, cookie)
			end
		end
	end

	self:_clear_event()
end

function VoiceBriefingManager:_play_subtitle(string_id, cookie)
	local duration = self:_subtitle_len(string_id)

	if self._params.show_subtitle then
		managers.subtitle:set_visible(true)
		managers.subtitle:set_enabled(true)
		managers.subtitle:show_subtitle(string_id, duration)
	end

	if self._listeners_enabled then
		for _, listener in ipairs(self._listeners) do
			if listener.marker then
				listener.clbk("marker", string_id, duration, cookie)
			end
		end
	end
end

function VoiceBriefingManager:_set_duration(duration, cookie)
	if self._listeners_enabled then
		for _, listener in ipairs(self._listeners) do
			if listener.duration then
				listener.clbk("duration", duration, cookie)
			end
		end
	end
end

function VoiceBriefingManager:_subtitle_len(id)
	local text = managers.localization:text(id)
	local duration = text:len() * tweak_data.dialog.DURATION_PER_CHAR

	if duration < tweak_data.dialog.MINIMUM_DURATION then
		duration = tweak_data.dialog.MINIMUM_DURATION
	end

	return duration
end

function VoiceBriefingManager:_check_event_ok()
	if not self._event_instance then
		if self._event_name ~= "nothing" then
			Application:error("[VoiceBriefingManager:_check_event_ok] Wasn't able to play sound event " .. tostring(self._event_name))
			Application:stack_dump()
		end

		self._post_event_enabled = false

		self:_sound_callback(nil, nil, "end_of_event", nil, self._event_name, nil, nil, nil)

		self._post_event_enabled = true

		return false
	end

	return true
end

function VoiceBriefingManager:_clear_event()
	self._event_name = nil
	self._event_instance = nil
	self._listeners = {}
	self._params = {}

	managers.subtitle:set_visible(false)
	managers.subtitle:set_enabled(false)

	self._post_event_enabled = true
	self._listeners_enabled = true
end

function VoiceBriefingManager:post_event_simple(event_name)
	if not event_name or not self._post_event_enabled then
		return
	end

	self:stop_event()
	self:_set_parameters({
		show_subtitle = true
	})

	self._event_name = event_name
	self._event_instance = self._sound_source:post_event(event_name, callback(self, self, "_sound_callback"), nil, "marker", "end_of_event")

	return self:_check_event_ok()
end

function VoiceBriefingManager:post_event(event_name, params)
	if not event_name or not self._post_event_enabled then
		return
	end

	self:stop_event()
	self:_set_parameters(params)

	self._event_name = event_name
	self._event_instance = self._sound_source:post_event(event_name, callback(self, self, "_sound_callback"), params and params.cookie or nil, "marker", "duration", "end_of_event")
	self._event_cookie = params and params.cookie

	return self:_check_event_ok()
end

function VoiceBriefingManager:event_playing()
	return self._event_instance and true or false
end

function VoiceBriefingManager:stop_event(skip_end_of_event)
	if self._event_instance then
		self._event_instance:stop()

		if not skip_end_of_event then
			self:_end_of_event(self._event_cookie)
		else
			self:_clear_event()
		end
	end

	self._event_cookie = nil
end

function VoiceBriefingManager:add_listener(listener)
	table.insert(self._listeners, listener)
end
