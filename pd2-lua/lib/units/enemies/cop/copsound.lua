CopSound = CopSound or class()

function CopSound:init(unit)
	self._unit = unit
	self._speak_expire_t = 0
	local char_tweak = tweak_data.character[unit:base()._tweak_table]

	self:set_voice_prefix(nil)

	local nr_variations = char_tweak.speech_prefix_count
	self._prefix = (char_tweak.speech_prefix_p1 or "") .. (nr_variations and tostring(math.random(nr_variations)) or "") .. (char_tweak.speech_prefix_p2 or "") .. "_"

	if self._unit:base():char_tweak().spawn_sound_event then
		self._unit:sound():play(self._unit:base():char_tweak().spawn_sound_event, nil, nil)
	end

	unit:base():post_init()
end

function CopSound:destroy(unit)
	if alive(unit) and unit:base() then
		unit:base():pre_destroy(unit)
	end
end

function CopSound:set_voice_prefix(index)
	local char_tweak = tweak_data.character[self._unit:base()._tweak_table]
	local nr_variations = char_tweak.speech_prefix_count

	if index and (index < 1 or nr_variations < index) then
		debug_pause_unit(self._unit, "[CopSound:set_voice_prefix] Invalid prefix index:", index, ". nr_variations:", nr_variations)
	end

	self._prefix = (char_tweak.speech_prefix_p1 or "") .. (nr_variations and tostring(index or math.random(nr_variations)) or "") .. (char_tweak.speech_prefix_p2 or "") .. "_"
end

function CopSound:_play(sound_name, source_name, clbk)
	local source = nil

	if source_name then
		source = Idstring(source_name)
	end

	local event = nil

	if clbk then
		event = self._unit:sound_source(source):post_event(sound_name, clbk, nil, "end_of_event")
	else
		event = self._unit:sound_source(source):post_event(sound_name)
	end

	return event
end

function CopSound:play(sound_name, source_name, sync)
	local event_id = nil

	if type(sound_name) == "number" then
		event_id = sound_name
		sound_name = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(sound_name)
		local sync_source_name = source_name or ""

		self._unit:network():send("unit_sound_play", event_id, sync_source_name)
	end

	local event = self:_play(sound_name or event_id, source_name)

	return event
end

function CopSound:corpse_play(sound_name, source_name, sync, important, clbk)
	local event_id = nil

	if type(sound_name) == "number" then
		event_id = sound_name
		sound_name = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(sound_name)
		local sync_source_name = source_name or ""
		local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id

		managers.network:session():send_to_peers_synched("corpse_sound_play", u_id, event_id, sync_source_name)
	end

	local event = self:_play(sound_name or event_id, source_name, clbk)

	if not event then
		Application:error("[CopSound:corpse_play] event not found in Wwise", sound_name, event_id, self._unit)
		Application:stack_dump("error")

		return
	end

	return event
end

function CopSound:stop(source_name)
	local source = nil

	if source_name then
		source = Idstring(source_name)
	end

	self._unit:sound_source(source):stop()
end

function CopSound:say(sound_name, sync, skip_prefix, important, callback)
	if self._last_speech then
		self._last_speech:stop()
	end

	local full_sound = nil

	if skip_prefix then
		full_sound = sound_name
	else
		full_sound = self._prefix .. sound_name
	end

	local event_id = nil

	if type(full_sound) == "number" then
		event_id = full_sound
		full_sound = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(full_sound)

		self._unit:network():send("say", event_id)
	end

	self._last_speech = self:_play(full_sound or event_id)

	if not self._last_speech then
		return
	end

	self._speak_expire_t = TimerManager:game():time() + 2
end

function CopSound:sync_say_str(full_sound)
	if self._last_speech then
		self._last_speech:stop()
	end

	self._last_speech = self:play(full_sound)
end

function CopSound:speaking(t)
	return t < self._speak_expire_t
end

function CopSound:anim_clbk_play_sound(unit, queue_name)
	self:_play(queue_name)
end

function CopSound:anim_clbk_stop_sound(unit, source_name)
	if source_name and source_name == Idstring("") then
		self:stop()

		return
	end

	self:stop(source_name)
end
