core:import("CoreSubtitlePresenter")

DramaExt = DramaExt or class()

function DramaExt:init(unit)
	self._unit = unit
	self._cue = nil
end

function DramaExt:name()
	return self.character_name
end

function DramaExt:play_sound(sound, sound_source)
	self._cue = self._cue or {}
	self._cue.sound = sound
	self._cue.sound_source = sound_source
	local playing = self._unit:sound_source(sound_source):post_event(sound, self.sound_callback, self._unit, "marker", "end_of_event")

	if not playing then
		Application:error("[DramaExt:play_cue] Wasn't able to play sound event " .. sound)
		Application:stack_dump()
		self:sound_callback(nil, "end_of_event", self._unit, sound_source, nil, nil, nil)
	end
end

function DramaExt:play_subtitle(string_id, duration)
	self._cue = self._cue or {}
	self._cue.string_id = string_id

	managers.subtitle:set_visible(true)
	managers.subtitle:set_enabled(true)

	if not duration or duration == 0 then
		managers.subtitle:show_subtitle(string_id, 100000)
	else
		managers.subtitle:show_subtitle(string_id, duration)
	end
end

function DramaExt:stop_cue()
	if self._cue then
		if self._cue.string_id then
			managers.subtitle:set_visible(false)
			managers.subtitle:set_enabled(false)
		end

		if self._cue.sound then
			self._unit:sound_source(self._cue.sound_source):stop()
		end

		self._cue = nil
	end
end

function DramaExt:sound_callback(instance, event_type, unit, sound_source, label, identifier, position)
	if event_type == "end_of_event" then
		managers.subtitle:set_visible(false)
		managers.subtitle:set_enabled(false)
		managers.dialog:finished()
	elseif event_type == "marker" and sound_source then
		managers.subtitle:set_visible(true)
		managers.subtitle:set_enabled(true)
		managers.subtitle:show_subtitle(sound_source, DramaExt:_subtitle_len(sound_source))
	end
end

function DramaExt:_subtitle_len(id)
	local duration = self:_length_from_tweak(id)

	if duration == nil then
		local text = managers.localization:text(id)
		duration = text:len() * tweak_data.dialog.DURATION_PER_CHAR
	end

	if duration < tweak_data.dialog.MINIMUM_DURATION then
		duration = tweak_data.dialog.MINIMUM_DURATION
	end

	return duration
end

function DramaExt:_length_from_tweak(id)
	local subtitles_tweak = tweak_data.subtitles.jobs[managers.job:current_real_job_id()]

	if subtitles_tweak and subtitles_tweak[id] then
		return subtitles_tweak[id] + tweak_data.subtitles.additional_time
	end

	return nil
end

