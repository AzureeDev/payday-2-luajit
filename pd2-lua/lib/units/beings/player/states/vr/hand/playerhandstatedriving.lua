require("lib/units/beings/player/states/vr/hand/PlayerHandState")

PlayerHandStateDriving = PlayerHandStateDriving or class(PlayerHandState)
PlayerHandStateDriving.DEBUG = false

function PlayerHandStateDriving:init(hsm, name, hand_unit, sequence)
	PlayerHandStateDriving.super.init(self, name, hsm, hand_unit, sequence)

	self._grip_toggle_setting = managers.vr:get_setting("grip_toggle")
	self._grip_toggle_clbk = callback(self, self, "on_grip_toggle_setting_changed")

	managers.vr:add_setting_changed_callback("grip_toggle", self._grip_toggle_clbk)
end

function PlayerHandStateDriving:on_grip_toggle_setting_changed(setting, old, new)
	self._grip_toggle_setting = new
end

function PlayerHandStateDriving:at_enter(prev_state, params)
	PlayerHandStateDriving.super.at_enter(self, prev_state)
	self:hsm():enter_controller_state("driving")

	self._vehicle = managers.player:get_vehicle()
	self._tweak = tweak_data.vr.driving
	self._tweak = self._tweak[self._vehicle.vehicle_unit:vehicle_driving().tweak_data]

	if self._tweak.middle_pos and type(self._tweak.steering_pos) ~= "table" then
		self._start_vec = self._tweak.steering_pos - self._tweak.middle_pos
		self._two_handed = false
	elseif self._tweak.steering_pos then
		self._start_vec = self._tweak.steering_pos.left - self._tweak.steering_pos.right
		self._two_handed = true
	end

	self._hand_side = self:hsm():hand_id() == 1 and "right" or "left"
	self._grip_toggle = nil
end

function PlayerHandStateDriving:at_exit(next_state)
	PlayerHandStateDriving.super.at_exit(self, next_state)
end

function PlayerHandStateDriving:gripping_steering()
	return self._gripping_steering
end

function PlayerHandStateDriving:gripping_throttle()
	return self._gripping_throttle
end

local pen = Draw:pen()
local offset = Vector3()
local middle = Vector3()
local steering_vec = Vector3()
local throttle_vec = Vector3()
local throttle_rot = Rotation()
local exit = Vector3()

function PlayerHandStateDriving:update(t, dt)
	local function offset_to_world(output, offset)
		mvector3.set(output, offset)
		mvector3.rotate_with(output, self._vehicle.vehicle_unit:rotation())
		mvector3.add(output, self._vehicle.vehicle_unit:position())

		if PlayerHandStateDriving.DEBUG then
			pen:sphere(output, 5)
		end
	end

	self._tweak = tweak_data.vr.driving
	self._tweak = self._tweak[self._vehicle.vehicle_unit:vehicle_driving().tweak_data]
	local controller = managers.vr:hand_state_machine():controller()
	local player_unit = managers.player:player_unit()

	if player_unit:movement():current_state_name() ~= "driving" then
		return
	end

	local current_player_state = player_unit:movement():current_state()
	local other_state = self:hsm():other_hand():current_state()

	if self._vehicle.seat == "driver" then
		local can_grip_steering = true

		if not self._two_handed and other_state:name() == "driving" and other_state:gripping_steering() then
			can_grip_steering = false
		end

		if self._tweak.steering_pos then
			if self._two_handed then
				offset_to_world(offset, self._tweak.steering_pos[self._hand_side])
				mvector3.set(middle, self:hsm():other_hand():hand_unit():position())
			else
				offset_to_world(offset, self._tweak.steering_pos)
				offset_to_world(middle, self._tweak.middle_pos)
			end

			local dis = mvector3.distance(self._hand_unit:position(), offset)

			if dis < 20 and can_grip_steering then
				if not self._close_steering then
					self._close_steering = true

					if not self._gripping_steering then
						self._hand_unit:damage():run_sequence_simple("ready")
						managers.controller:get_vr_controller():trigger_haptic_pulse(self:hsm():hand_id() - 1, 0, 700)
					end
				end
			elseif self._close_steering then
				if not self._gripping_steering then
					self._hand_unit:damage():run_sequence_simple("idle")
				end

				self._close_steering = false
			end

			local wants_steering = false

			if controller:get_input_pressed("interact_" .. self._hand_side) and (not self._grip_toggle_setting or not self._grip_toggle) then
				wants_steering = true
			end

			if self._close_steering and wants_steering then
				self._gripping_steering = true

				self._hand_unit:damage():run_sequence_simple("grip_wpn")
				current_player_state:set_help_text("steering", "gripping")

				self._grip_toggle = self._grip_toggle_setting
			elseif self._gripping_steering then
				local wants_release = not controller:get_input_bool("interact_" .. self._hand_side)

				if self._grip_toggle_setting then
					wants_release = controller:get_input_pressed("interact_" .. self._hand_side)
				end

				if wants_release then
					self._grip_toggle = nil
					self._gripping_steering = false

					self._hand_unit:damage():run_sequence_simple(self._close_steering and "ready" or "idle")
					current_player_state:set_steering()
					current_player_state:set_help_text("steering")
				end
			end

			local can_steer = self._gripping_steering

			if self._two_handed and (other_state:name() == "driving" and not other_state:gripping_steering() or self._hand_side == "right") then
				can_steer = false
			end

			if can_steer then
				mvector3.set(steering_vec, self._hand_unit:position())
				mvector3.subtract(steering_vec, middle)
				mvector3.rotate_with(steering_vec, self._vehicle.vehicle_unit:rotation():inverse())

				local steering_rot = Rotation:rotation_difference(Rotation(self._start_vec, math.UP), Rotation(math.UP, math.UP))

				mvector3.rotate_with(steering_vec, steering_rot)
				mvector3.set_y(steering_vec, 0)

				local angle = mvector3.angle(steering_vec, self._start_vec:rotate_with(steering_rot))

				if steering_vec.z > 0 then
					self._invert_angle = steering_vec.x < 0
				end

				if self._invert_angle then
					angle = angle * -1
				end

				if self._tweak.inverted then
					angle = angle * -1
				end

				local val = math.clamp(angle / self._tweak.max_angle, -0.99, 0.99)

				if math.abs(val) < 0.02 then
					val = 0
				end

				current_player_state:set_steering(val)
			end
		end

		if self._tweak.throttle then
			if self._tweak.throttle.type == "lever" then
				local can_grip_throttle = true
				local other_state = self:hsm():other_hand():current_state()

				if other_state:name() == "driving" and other_state:gripping_throttle() then
					can_grip_throttle = false
				end

				offset_to_world(offset, self._tweak.throttle.position)

				local dis = mvector3.distance(self._hand_unit:position(), offset)

				if dis < 20 and can_grip_throttle then
					if not self._close_throttle then
						self._close_throttle = true

						if not self._gripping_throttle then
							self._hand_unit:damage():run_sequence_simple("ready")
							managers.controller:get_vr_controller():trigger_haptic_pulse(self:hsm():hand_id() - 1, 0, 700)
						end
					end
				elseif self._close_throttle then
					if not self._gripping_throttle then
						self._hand_unit:damage():run_sequence_simple("idle")
					end

					self._close_throttle = false
				end

				local wants_throttle = false

				if controller:get_input_pressed("interact_" .. self._hand_side) and (not self._grip_toggle_setting or not self._grip_toggle) then
					wants_throttle = true
				end

				if self._close_throttle and wants_throttle then
					self._gripping_throttle = true

					self._hand_unit:damage():run_sequence_simple("grip_wpn")
					current_player_state:set_help_text("throttle", "lever")

					self._grip_toggle = self._grip_toggle_setting
				elseif self._gripping_throttle then
					local wants_release = not controller:get_input_bool("interact_" .. self._hand_side)

					if self._grip_toggle_setting then
						wants_release = controller:get_input_pressed("interact_" .. self._hand_side)
					end

					if wants_release then
						self._grip_toggle = nil
						self._gripping_throttle = false

						self._hand_unit:damage():run_sequence_simple(self._close_throttle and "ready" or "idle")
						current_player_state:set_throttle()
						current_player_state:set_help_text("throttle")
					end
				end

				if self._gripping_throttle then
					mvector3.set(throttle_vec, self._hand_unit:position())
					mvector3.subtract(throttle_vec, offset)
					mvector3.rotate_with(throttle_vec, self._vehicle.vehicle_unit:rotation():inverse())

					local len = throttle_vec.y / 10
					local val = math.clamp(len, -0.99, 0.99)

					if math.abs(len) < 0.1 then
						val = 0
					end

					current_player_state:set_throttle(val)
				end
			elseif self._tweak.throttle.type == "twist_grip" then
				if self._gripping_steering then
					if not self._two_handed or self._hand_side == self._tweak.throttle.hand then
						if not self._gripping_throttle then
							current_player_state:set_help_text("throttle", "twist_grip")
						end

						self._gripping_throttle = true

						mrotation.set_look_at(throttle_rot, (middle - offset):normalized(), math.UP)
						mrotation.multiply(throttle_rot, self._vehicle.vehicle_unit:rotation():inverse())
						mrotation.rotation_difference(throttle_rot, throttle_rot, self._hand_unit:rotation())

						local angle = throttle_rot:roll()
						local throttle_offset = self._tweak.throttle.offset or 0
						local val = angle + throttle_offset
						local max_angle = self._tweak.throttle.max_angle or 90
						val = math.clamp(val / max_angle, -0.99, 0.99)

						if math.abs(val) < 0.1 then
							val = 0
						end

						if self._tweak.throttle.inverted then
							val = val * -1
						end

						current_player_state:set_throttle(val)
					end
				elseif self._gripping_throttle then
					self._gripping_throttle = false

					current_player_state:set_throttle()
					current_player_state:set_help_text("throttle")
				end
			end
		end
	end

	local can_exit = not self._gripping_steering and not self._gripping_throttle

	if other_state:name() == "driving" then
		can_exit = can_exit and not other_state:gripping_steering() and not other_state:gripping_throttle()
	end

	if can_exit then
		if not self._tweak.exit_pos[self._vehicle.seat] then
			debug_pause("Seat " .. self._vehicle.seat .. " has no exit in " .. self._vehicle.vehicle_unit:vehicle_driving().tweak_data .. "!")

			return
		end

		offset_to_world(exit, self._tweak.exit_pos[self._vehicle.seat].position)

		local dis = mvector3.distance(self._hand_unit:position(), exit)

		if dis < 20 then
			if not self._close_exit then
				self._close_exit = true

				self._hand_unit:damage():run_sequence_simple("ready")
				managers.controller:get_vr_controller():trigger_haptic_pulse(self:hsm():hand_id() - 1, 0, 700)
			end
		elseif self._close_exit then
			self._hand_unit:damage():run_sequence_simple("idle")

			self._close_exit = false
		end

		if self._close_exit and controller:get_input_pressed("interact_" .. self._hand_side) then
			current_player_state:_start_action_exit_vehicle(t)
		end
	end
end
