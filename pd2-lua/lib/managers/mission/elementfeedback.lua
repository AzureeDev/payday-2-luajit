core:import("CoreMissionScriptElement")

ElementFeedback = ElementFeedback or class(CoreMissionScriptElement.MissionScriptElement)
ElementFeedback.IDS_EFFECT = Idstring("effect")

function ElementFeedback:init(...)
	ElementFeedback.super.init(self, ...)

	self._feedback = managers.feedback:create(self._values.effect)

	if Application:editor() and self._values.above_camera_effect ~= "none" then
		CoreEngineAccess._editor_load(self.IDS_EFFECT, self._values.above_camera_effect:id())
	end
end

function ElementFeedback:client_on_executed(...)
	self:on_executed(...)
end

function ElementFeedback:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local player = managers.player:player_unit()

	if player then
		self._feedback:set_unit(player)
		self._feedback:set_enabled("rumble", self._values.use_rumble)
		self._feedback:set_enabled("camera_shake", self._values.use_camera_shake)

		local multiplier = self:_calc_multiplier(player)
		local params = {}

		self:_check_value(params, "camera_shake", "name", self._values.camera_shake_effect)
		self:_check_value(params, "camera_shake", "multiplier", multiplier)
		self:_check_value(params, "camera_shake", "amplitude", self._values.camera_shake_amplitude)
		self:_check_value(params, "camera_shake", "frequency", self._values.camera_shake_frequency)
		self:_check_value(params, "camera_shake", "attack", self._values.camera_shake_attack)
		self:_check_value(params, "camera_shake", "sustain", self._values.camera_shake_sustain)
		self:_check_value(params, "camera_shake", "decay", self._values.camera_shake_decay)
		self:_check_value(params, "rumble", "multiplier_data", multiplier)
		self:_check_value(params, "rumble", "peak", self._values.rumble_peak)
		self:_check_value(params, "rumble", "attack", self._values.rumble_attack)
		self:_check_value(params, "rumble", "sustain", self._values.rumble_sustain)
		self:_check_value(params, "rumble", "release", self._values.rumble_release)
		self._feedback:set_enabled("above_camera_effect", multiplier >= 1 - self._values.above_camera_effect_distance)
		table.insert(params, "above_camera_effect")
		table.insert(params, "effect")
		table.insert(params, self._values.above_camera_effect)
		self._feedback:play(unpack(params))
	end

	ElementFeedback.super.on_executed(self, instigator)
end

function ElementFeedback:_check_value(params, cat, setting, value)
	if not value then
		return
	end

	if type_name(value) == "string" or value >= 0 then
		table.insert(params, cat)
		table.insert(params, setting)
		table.insert(params, value)
	end
end

function ElementFeedback:_calc_multiplier(player)
	if self._values.range == 0 then
		return 1
	end

	local pos, _ = self:get_orientation(true)
	local distance = (pos - player:position()):length()
	local mul = math.clamp(1 - distance / self._values.range, 0, 1)

	return mul
end
