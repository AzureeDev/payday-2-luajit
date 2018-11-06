require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")

CoreSoundCutsceneKey = CoreSoundCutsceneKey or class(CoreCutsceneKeyBase)
CoreSoundCutsceneKey.ELEMENT_NAME = "sound"
CoreSoundCutsceneKey.NAME = "Sound"

CoreSoundCutsceneKey:register_serialized_attribute("bank", "")
CoreSoundCutsceneKey:register_serialized_attribute("cue", "")
CoreSoundCutsceneKey:register_serialized_attribute("unit_name", "")
CoreSoundCutsceneKey:register_serialized_attribute("object_name", "")
CoreSoundCutsceneKey:register_serialized_attribute("sync_to_video", false, toboolean)
CoreSoundCutsceneKey:attribute_affects("bank", "cue")

CoreSoundCutsceneKey.control_for_unit_name = CoreCutsceneKeyBase.standard_combo_box_control
CoreSoundCutsceneKey.control_for_object_name = CoreCutsceneKeyBase.standard_combo_box_control
CoreSoundCutsceneKey.control_for_bank = CoreCutsceneKeyBase.standard_combo_box_control

function CoreSoundCutsceneKey:__tostring()
	return "Trigger sound \"" .. self:bank() .. "/" .. self:cue() .. "\" on \"" .. self:unit_name() .. "\"."
end

function CoreSoundCutsceneKey:prime(player)
	self:sound():prime()
end

function CoreSoundCutsceneKey:skip(player)
	self:stop()
end

function CoreSoundCutsceneKey:can_evaluate_with_player(player)
	return true
end

function CoreSoundCutsceneKey:play(player, undo, fast_forward)
	if undo then
		self:stop()
	elseif not fast_forward then
		if self:unit_name() ~= "" and self:object_name() ~= "" then
			self:sound():set_output(self:_unit_object(self:unit_name(), self:object_name()))
		end

		self:_trigger_sound()
	end
end

function CoreSoundCutsceneKey:update(player, time)
	if self.is_in_cutscene_editor then
		self:handle_cutscene_editor_scrubbing(player, time)
	end
end

function CoreSoundCutsceneKey:handle_cutscene_editor_scrubbing(player, time)
	if self._last_evaluated_time then
		if time == self._last_evaluated_time then
			self._stopped_frame_count = (self._stopped_frame_count or 0) + 1

			if self._stopped_frame_count > 10 then
				self._stopped_frame_count = nil

				self:stop()
			end
		else
			self._stopped_frame_count = nil

			if self._sound_abort_func == nil or time < self._last_evaluated_time or time - self._last_evaluated_time > 1 then
				self:_trigger_sound(time)
			end
		end
	end

	self._last_evaluated_time = time
end

function CoreSoundCutsceneKey:is_valid_unit_name(unit_name)
	return unit_name == nil or unit_name == "" or CoreCutsceneKeyBase.is_valid_unit_name(self, unit_name)
end

function CoreSoundCutsceneKey:is_valid_object_name(object_name)
	return object_name == nil or object_name == "" or CoreCutsceneKeyBase.is_valid_object_name(self, object_name)
end

function CoreSoundCutsceneKey:is_valid_bank(bank)
	return bank and bank ~= "" and table.contains(Sound:soundbanks(), bank)
end

function CoreSoundCutsceneKey:is_valid_cue(cue)
	return cue and cue ~= "" and self:is_valid_bank(self:bank()) and Sound:make_bank(self:bank(), cue) ~= nil
end

function CoreSoundCutsceneKey:refresh_control_for_bank(control)
	control:freeze()
	control:clear()

	local value = self:bank()

	for _, bank_name in ipairs(Sound:soundbanks()) do
		control:append(bank_name)

		if bank_name == value then
			control:set_value(value)
		end
	end

	control:thaw()
end

function CoreSoundCutsceneKey:refresh_control_for_unit_name(control)
	CoreCutsceneKeyBase.refresh_control_for_unit_name(self, control)
	control:append("")

	if self:unit_name() == "" then
		control:set_value("")
	end
end

function CoreSoundCutsceneKey:refresh_control_for_object_name(control)
	CoreCutsceneKeyBase.refresh_control_for_object_name(self, control)
	control:append("")

	if self:object_name() == "" then
		control:set_value("")
	end
end

function CoreSoundCutsceneKey:on_attribute_before_changed(attribute_name, value, previous_value)
	if attribute_name ~= "sync_to_video" then
		self:stop()
	end
end

function CoreSoundCutsceneKey:on_attribute_changed(attribute_name, value, previous_value)
	if attribute_name == "bank" or attribute_name == "cue" then
		self._sound = nil

		if self:is_valid() then
			self:prime()
		end
	end
end

function CoreSoundCutsceneKey:sound()
	if self._sound == nil then
		self._sound = assert(Sound:make_bank(self:bank(), self:cue()), "Sound \"" .. self:bank() .. "/" .. self:cue() .. "\" not found.")
	end

	return self._sound
end

function CoreSoundCutsceneKey:stop()
	if self._sound_abort_func then
		self._sound_abort_func()

		self._sound_abort_func = nil
	end

	self._last_evaluated_time = nil
end

function CoreSoundCutsceneKey:_trigger_sound(offset)
	self:stop()

	local instance = self:sound():play(self:sync_to_video() and "running_offset" or "offset", offset or 0)

	if alive(instance) then
		function self._sound_abort_func()
			if alive(instance) and instance:is_playing() then
				instance:stop()
			end
		end
	end
end
