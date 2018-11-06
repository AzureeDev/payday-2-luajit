PlayerSound = PlayerSound or class()

function PlayerSound:init(unit)
	self._unit = unit

	unit:base():post_init()

	local ss = unit:sound_source()

	ss:set_switch("robber", "rb3")

	if unit:base().is_local_player then
		ss:set_switch("int_ext", "first")
	else
		ss:set_switch("int_ext", "third")
	end
end

function PlayerSound:destroy(unit)
	if unit:base() then
		unit:base():pre_destroy(unit)
	end
end

function PlayerSound:_play(sound_name, source_name)
	local source = nil

	if source_name then
		source = Idstring(source_name)
	end

	local event = self._unit:sound_source(source):post_event(sound_name, self.sound_callback, self._unit, "marker", "end_of_event")

	return event
end

function PlayerSound:sound_callback(instance, event_type, unit, sound_source, label, identifier, position)
	if not alive(unit) then
		return
	end

	if event_type == "end_of_event" then
		managers.hud:set_mugshot_talk(unit:unit_data().mugshot_id, false)

		unit:sound()._speaking = nil
	end
end

function PlayerSound:play(sound_name, source_name, sync)
	local event_id = nil

	if type(sound_name) == "number" then
		event_id = sound_name
		sound_name = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(sound_name)
		source_name = source_name or ""

		self._unit:network():send("unit_sound_play", event_id, source_name)
	end

	local event = self:_play(sound_name or event_id, source_name)

	return event
end

function PlayerSound:stop(source_name)
	local source = nil

	if source_name then
		source = Idstring(source_name)
	end

	self._unit:sound_source(source):stop()
end

function PlayerSound:play_footstep(foot, material_name)
	if self._last_material ~= material_name then
		self._last_material = material_name
		local material_name = tweak_data.materials[material_name:key()]

		self._unit:sound_source(Idstring("root")):set_switch("materials", material_name or "no_material")
	end

	self:_play(self._unit:movement():running() and "footstep_run" or "footstep_walk")
end

function PlayerSound:play_land(material_name)
	if self._last_material ~= material_name then
		self._last_material = material_name
		local material_name = tweak_data.materials[material_name:key()]

		self._unit:sound_source(Idstring("root")):set_switch("materials", material_name or "concrete")
	end

	self:_play("footstep_land")
end

function PlayerSound:play_whizby(params)
	self:_play("bullet_whizby_medium")
end

function PlayerSound:say(sound_name, sync, important_say, ignore_prefix, callback)
	if self._last_speech and self._speaking then
		self._last_speech:stop()

		self._speaking = nil
	end

	local event_id = nil

	if type(sound_name) == "number" then
		event_id = sound_name
		sound_name = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(sound_name)

		self._unit:network():send("say", event_id)
	end

	self._last_speech = self:_play(sound_name or event_id, nil, true, callback)

	if important_say and self._last_speech then
		managers.hud:set_mugshot_talk(self._unit:unit_data().mugshot_id, true)

		self._speaking = true
	end

	return self._last_speech
end

function PlayerSound:speaking()
	return self._speaking
end

function PlayerSound:set_voice(voice)
	self._unit:sound_source():set_switch("robber", voice)
end
