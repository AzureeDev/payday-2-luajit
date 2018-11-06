SafehouseNPCSound = SafehouseNPCSound or class(CivilianHeisterSound)
SafehouseNPCSound.RND_MIN = 4
SafehouseNPCSound.RND_MAX = 6

function SafehouseNPCSound:init(unit)
	SafehouseNPCSound.super.init(self, unit)

	self._speech_t = 0
	local player_unit = managers.player:player_unit()
	local player_character = managers.criminals:character_name_by_unit(player_unit)
	local player_voice = "rb1"

	for idx, data in ipairs(tweak_data.criminals.characters) do
		if data.name == player_character then
			player_voice = data.static_data.voice

			break
		end
	end

	self:set_interactor_voice(player_voice)

	local level = managers.custom_safehouse:avarage_level()

	self:set_room_level(level)

	if self.character and tweak_data.safehouse.heisters[self.character].voice then
		self:set_voice(tweak_data.safehouse.heisters[self.character].voice)
	end
end

function SafehouseNPCSound:_randomize_speech_time()
	local offset = self.character and tweak_data.safehouse.heisters[self.character] and tweak_data.safehouse.heisters[self.character].idle_offset or 0
	self._speech_t = Application:time() + offset + math.random(self.RND_MIN, self.RND_MAX)
end

function SafehouseNPCSound:sound_callback(instance, event_type, unit, sound_source, label, identifier, position)
	if not alive(unit) then
		return
	end

	unit:sound():snd_clbk()

	if event_type == "end_of_event" then
		if unit:interaction() and unit:interaction()._reenable_ext then
			unit:interaction():_reenable_ext()
		end

		unit:sound()._speaking = nil
	end
end

function SafehouseNPCSound:update(unit, t, dt)
	local is_speaking = self:speaking(t)

	if self._speech_t <= t then
		local skip = false

		if self.character and tweak_data.safehouse.heisters[self.character] and tweak_data.safehouse.heisters[self.character].anim_lines then
			for _, line in ipairs(tweak_data.safehouse.heisters[self.character].anim_lines) do
				if line.line_type == "idle" and not self._unit:anim_data()[line.anim_value] then
					skip = true

					break
				end
			end
		end

		if not is_speaking and not skip then
			self:_sound_start_muttering()
			self._unit:set_extension_update_enabled(Idstring("sound"), false)
		else
			self:_randomize_speech_time()
		end
	end
end

function SafehouseNPCSound:sound_start(...)
	if self._snd_start_clbk then
		self._snd_start_clbk()

		self._snd_start_clbk = nil
	end
end

function SafehouseNPCSound:snd_clbk()
	if self._snd_clbk then
		self._snd_clbk()
	end
end

function SafehouseNPCSound:_on_muttering_done()
	self:_randomize_speech_time()
	self._unit:set_extension_update_enabled(Idstring("sound"), true)

	self._snd_clbk = nil
end

function SafehouseNPCSound:_sound_start_muttering(override_sound)
	if not self.character then
		debug_pause("[SafehouseNPCSound:_sound_start_muttering] no character set!")

		return
	end

	if self._unit:interaction()._reenable_ext then
		self._unit:interaction():set_active(false)
	end

	self._snd_clbk = callback(self, self, "_on_muttering_done")

	self:say(override_sound or string.format("Play_%s_idle", self.character), false, true)
end
