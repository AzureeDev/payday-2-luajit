BikeDrivingExt = BikeDrivingExt or class(VehicleDrivingExt)

function BikeDrivingExt:init(unit)
	BikeDrivingExt.super.init(self, unit)

	self._wheel_idle = false
	self._front_spin = self._unit:get_object(Idstring(self.front_spin_obj))
	self._front_wheel = self._unit:get_object(Idstring("anim_tire_front_left"))
	self._back_spin = self._unit:get_object(Idstring(self.back_spin_obj))
	self._back_wheel = self._unit:get_object(Idstring("anim_tire_rear_left"))

	if self._front_spin == nil then
		Application:error("[DRIVING]", "bike doesn't contain front_spin_obj var definition in unit file")
	end

	if self._back_spin == nil then
		Application:error("[DRIVING]", "bike doesn't contain back_spin_obj var definition in unit file")
	end
end

function BikeDrivingExt:update(unit, t, dt)
	BikeDrivingExt.super.update(self, unit, t, dt)

	if self._seats.driver.occupant then
		self._front_spin:set_local_rotation(Rotation(Vector3(1, 0, 0), self._front_wheel:local_rotation():pitch()))
		self._back_spin:set_local_rotation(Rotation(Vector3(1, 0, 0), self._back_wheel:local_rotation():pitch()))

		local steer = self._unit:vehicle():get_steer()

		if steer == 0 and not self._wheel_idle then
			self._unit:anim_set_time(Idstring("anim_tilt_left"), 0)
			self._unit:anim_set_time(Idstring("anim_tilt_right"), 0)
			self._unit:anim_stop(Idstring("anim_tilt_left"))
			self._unit:anim_stop(Idstring("anim_tilt_right"))

			if self._seats.driver.occupant ~= managers.player:player_unit() then
				self._unit:anim_set_time(Idstring("anim_steering_wheel_left"), 0)
				self._unit:anim_set_time(Idstring("anim_steering_wheel_right"), 0)
				self._unit:anim_stop(Idstring("anim_steering_wheel_left"))
				self._unit:anim_stop(Idstring("anim_steering_wheel_right"))
			end

			self._wheel_idle = true
		end

		local use_tilt = true
		use_tilt = not _G.IS_VR

		if steer > 0 then
			self._unit:anim_stop(Idstring("anim_tilt_right"))

			local tilt_anim_length = self._unit:anim_length(Idstring("anim_tilt_left"))
			local steer_anim_length = self._unit:anim_length(Idstring("anim_steering_wheel_left"))

			if use_tilt then
				self._unit:anim_set_time(Idstring("anim_tilt_left"), math.abs(steer) * tilt_anim_length)
				self._unit:anim_play(Idstring("anim_tilt_left"))
			end

			if self._seats.driver.occupant ~= managers.player:player_unit() then
				self._unit:anim_stop(Idstring("anim_steering_wheel_right"))
				self._unit:anim_set_time(Idstring("anim_steering_wheel_left"), math.abs(steer) * steer_anim_length)
				self._unit:anim_play(Idstring("anim_steering_wheel_left"))
			end

			self._wheel_idle = false
		end

		if steer < 0 then
			self._unit:anim_stop(Idstring("anim_tilt_left"))

			local left_length_fix = 0.5
			local tilt_anim_length = self._unit:anim_length(Idstring("anim_tilt_right"))
			local steer_anim_length = self._unit:anim_length(Idstring("anim_steering_wheel_right"))

			if use_tilt then
				self._unit:anim_set_time(Idstring("anim_tilt_right"), math.abs(steer) * tilt_anim_length)
				self._unit:anim_play(Idstring("anim_tilt_right"))
			end

			if self._seats.driver.occupant ~= managers.player:player_unit() then
				if use_tilt then
					self._unit:anim_set_time(Idstring("anim_tilt_right"), math.abs(steer) * tilt_anim_length * left_length_fix)
					self._unit:anim_play(Idstring("anim_tilt_right"))
				end

				self._unit:anim_stop(Idstring("anim_steering_wheel_left"))
				self._unit:anim_set_time(Idstring("anim_steering_wheel_right"), math.abs(steer) * steer_anim_length * left_length_fix)
				self._unit:anim_play(Idstring("anim_steering_wheel_right"))
			end

			self._wheel_idle = false
		end
	end
end
