SentryGunEquipment = SentryGunEquipment or class()
SentryGunEquipment._DAMAGE_EFFECTS_1 = 0.5
SentryGunEquipment._DAMAGE_EFFECTS_2 = 0.25

function SentryGunEquipment:init(unit)
	self._unit = unit
	local event_listener = unit:event_listener()

	event_listener:add("SentryGunEquipment_on_damage_received", {
		"on_damage_received"
	}, callback(self, self, "_on_damage_received_event"))
	event_listener:add("SentryGunEquipment_on_death_event", {
		"on_death"
	}, callback(self, self, "_on_death_event"))
	event_listener:add("SentryGunEquipment_on_destroy_unit", {
		"on_destroy_unit"
	}, callback(self, self, "_on_destroy_unit"))
end

function SentryGunEquipment:_on_damage_received_event(health_ratio)
	if health_ratio < self._DAMAGE_EFFECTS_2 then
		self:_check_sound()

		if not self._second_pass_active then
			self._unit:damage():run_sequence_simple("damage_second_pass")
		end
	elseif health_ratio < self._DAMAGE_EFFECTS_1 then
		self:_check_sound()
		self._unit:damage():run_sequence_simple("damage_first_pass")
	end
end

function SentryGunEquipment:_on_death_event()
	self._unit:sound_source():post_event("wp_sentrygun_destroy")
	self._unit:damage():run_sequence_simple("destroyed")
end

function SentryGunEquipment:_on_destroy_unit()
	if self._broken_loop_snd_event then
		self._broken_loop_snd_event:stop()

		self._broken_loop_snd_event = nil
	end

	self._unit:damage():run_sequence_simple("remove_effects")
end

function SentryGunEquipment:_check_sound()
	if not self._broken_loop_snd_event then
		self._broken_loop_snd_event = self._unit:sound_source():post_event("wp_sentrygun_broken_loop")
	end
end
