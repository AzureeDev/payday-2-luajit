TimeSpeedManager = TimeSpeedManager or class()

function TimeSpeedManager:init()
	self._pausable_timer = TimerManager:pausable()
	self._game_timer = TimerManager:game()
	self._game_anim_timer = TimerManager:game_animation()
	self._game_speed_rtpc = 1
end

function TimeSpeedManager:update()
	if self._playing_effects then
		self:_update_playing_effects()
	end
end

function TimeSpeedManager:_update_playing_effects()
	local slowest_speed = nil
	local playing_effects = self._playing_effects

	if playing_effects then
		local all_affected_timers = self._affected_timers

		for timer_key, timer_info in pairs(all_affected_timers) do
			timer_info.mul = 1
		end

		for effect_id, effect in pairs(playing_effects) do
			local time = effect.timer:time()
			local effect_speed = nil

			if time < effect.fade_in_delay_end_t then
				-- Nothing
			elseif time < effect.fade_in_end_t then
				effect_speed = math.lerp(1, effect.desc.speed, ((time - effect.fade_in_delay_end_t) / effect.desc.fade_in)^0.5)
			elseif not effect.sustain_end_t or time < effect.sustain_end_t then
				effect_speed = effect.desc.speed
			elseif time < effect.effect_end_t then
				effect_speed = math.lerp(effect.desc.speed, 1, ((time - effect.sustain_end_t) / effect.desc.fade_out)^0.5)
			else
				self:_on_effect_expired(effect_id)
			end

			if effect_speed then
				for timer_key, affect_timer in pairs(effect.affect_timers) do
					local timer_info = self._affected_timers[timer_key]
					timer_info.mul = math.min(timer_info.mul, effect_speed)
				end

				slowest_speed = not slowest_speed and effect_speed or math.min(slowest_speed, effect_speed)
			end
		end

		local game_speed_rtpc_changed = false

		if slowest_speed then
			if slowest_speed < 0.5 then
				if self._game_speed_rtpc ~= 0 then
					self._game_speed_rtpc = 0
					game_speed_rtpc_changed = true
				end
			elseif slowest_speed > 1.5 then
				if self._game_speed_rtpc ~= 2 then
					self._game_speed_rtpc = 2
					game_speed_rtpc_changed = true
				end
			elseif self._game_speed_rtpc ~= 1 then
				self._game_speed_rtpc = 1
				game_speed_rtpc_changed = true
			end
		elseif self._game_speed_rtpc ~= 1 then
			self._game_speed_rtpc = 1
			game_speed_rtpc_changed = true
		end

		if game_speed_rtpc_changed then
			SoundDevice:set_rtpc("game_speed", self._game_speed_rtpc)
		end

		if self._affected_timers then
			for timer_key, timer_info in pairs(all_affected_timers) do
				timer_info.timer:set_multiplier(timer_info.mul)
			end
		end
	end
end

function TimeSpeedManager:play_effect(id, effect_desc)
	local effect = {
		desc = effect_desc,
		timer = effect_desc.timer == "pausable" and self._pausable_timer or self._game_timer
	}
	effect.start_t = effect.timer:time()
	effect.fade_in_delay_end_t = effect.start_t + (effect_desc.fade_in_delay or 0)
	effect.fade_in_end_t = effect.fade_in_delay_end_t + effect_desc.fade_in
	effect.sustain_end_t = effect_desc.sustain and effect.fade_in_end_t + effect_desc.sustain
	effect.effect_end_t = effect.sustain_end_t and effect.sustain_end_t + (effect_desc.fade_out or 0)

	if effect_desc.affect_timer then
		if type(effect_desc.affect_timer) == "table" then
			effect.affect_timers = {}

			for _, timer_name in ipairs(effect_desc.affect_timer) do
				local timer = TimerManager:timer(Idstring(timer_name))
				effect.affect_timers[timer:key()] = timer
			end
		else
			local timer = TimerManager:timer(Idstring(effect_desc.affect_timer))
			effect.affect_timers = {
				[timer:key()] = timer
			}
		end
	else
		effect.affect_timers = {
			[self._game_timer:key()] = self._game_timer,
			[self._game_anim_timer:key()] = self._game_anim_timer
		}
	end

	self._affected_timers = self._affected_timers or {}

	for timer_key, affect_timer in pairs(effect.affect_timers) do
		if self._affected_timers[timer_key] then
			self._affected_timers[timer_key].ref_count = self._affected_timers[timer_key].ref_count + 1
		else
			self._affected_timers[timer_key] = {
				ref_count = 1,
				mul = 1,
				timer = affect_timer
			}
		end
	end

	self._playing_effects = self._playing_effects or {}
	self._playing_effects[id] = effect

	if effect_desc.sync and managers.network:session() and not managers.network:session():closing() then
		local affect_timers_str = ""

		if effect_desc.affect_timer then
			if type(effect_desc.affect_timer) == "table" then
				for _, timer_name in ipairs(effect_desc.affect_timer) do
					affect_timers_str = affect_timers_str .. timer_name .. ";"
				end
			else
				affect_timers_str = effect_desc.affect_timer .. ";"
			end
		end

		managers.network:session():send_to_peers_synched("start_timespeed_effect", id, effect_desc.timer, affect_timers_str, effect_desc.speed, effect_desc.fade_in or 0, effect_desc.sustain or 0, effect_desc.fade_out or 0)
	end
end

function TimeSpeedManager:stop_effect(id, fade_out_duration)
	if not self._playing_effects then
		return
	end

	if managers.network:session() and not managers.network:session():closing() then
		local effect_instance = self._playing_effects[id]

		if effect_instance and effect_instance.desc.sync then
			local sync_fade_out_duration = nil

			if fade_out_duration and fade_out_duration ~= 0 then
				sync_fade_out_duration = fade_out_duration
			else
				sync_fade_out_duration = 0
			end

			managers.network:session():send_to_peers_synched("start_timespeed_effect", id, sync_fade_out_duration)
		end
	end

	if fade_out_duration and fade_out_duration ~= 0 then
		local effect_instance = self._playing_effects[id]

		if not effect_instance then
			return
		end

		local t = effect_instance.timer:time()
		effect_instance.sustain_end_t = t
		effect_instance.effect_end_t = t + fade_out_duration
	else
		self:_on_effect_expired(id)
	end
end

function TimeSpeedManager:_on_effect_expired(effect_id)
	local effect = self._playing_effects[effect_id]

	for timer_key, affect_timer in pairs(effect.affect_timers) do
		local timer_info = self._affected_timers[timer_key]

		if timer_info.ref_count == 1 then
			timer_info.timer:set_multiplier(1)

			self._affected_timers[timer_key] = nil
		else
			timer_info.ref_count = timer_info.ref_count - 1
		end
	end

	self._playing_effects[effect_id] = nil

	if not next(self._playing_effects) then
		self._playing_effects = nil
		self._affected_timers = nil
	end
end

function TimeSpeedManager:in_effect()
	return self._playing_effects and true
end

function TimeSpeedManager:destroy()
	while self._playing_effects do
		local eff_id, eff = next(self._playing_effects)

		self:_on_effect_expired(eff_id)
	end

	SoundDevice:set_rtpc("game_speed", 1)
end
