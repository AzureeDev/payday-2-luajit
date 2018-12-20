require("lib/units/beings/player/states/vr/hand/PlayerHandState")

PlayerHandStateBow = PlayerHandStateBow or class(PlayerHandState)

function PlayerHandStateBow:init(hsm, name, hand_unit, sequence)
	PlayerHandStateBow.super.init(self, name, hsm, hand_unit, sequence)
end

function PlayerHandStateBow:_link_weapon(weapon_unit)
	if not alive(weapon_unit) then
		return
	end

	if not alive(self._weapon_unit) then
		self._weapon_unit = weapon_unit

		self._weapon_unit:base():on_enabled()
		self._weapon_unit:base():set_visibility_state(true)
		self._weapon_unit:base():check_bullet_objects()
	end
end

function PlayerHandStateBow:_unlink_weapon()
	if alive(self._weapon_unit) then
		self._weapon_unit:base():set_visibility_state(false)
		self._weapon_unit:base():on_disabled()

		self._weapon_unit = nil
	end
end

function PlayerHandStateBow:at_enter(prev_state)
	PlayerHandStateBow.super.at_enter(self, prev_state)

	if alive(managers.player:player_unit()) then
		self:_link_weapon(managers.player:player_unit():inventory():equipped_unit())
	end

	self._hand_unit:melee():set_weapon_unit(self._weapon_unit)
	self:hsm():enter_controller_state("empty")

	local sequence = self._sequence
	local tweak = tweak_data.vr:get_offset_by_id(self._weapon_unit:base().name_id)

	if tweak.grip then
		sequence = tweak.grip
	end

	if self._hand_unit and sequence and self._hand_unit:damage():has_sequence(sequence) then
		self._hand_unit:damage():run_sequence_simple(sequence)
	end
end

function PlayerHandStateBow:at_exit(next_state)
	self._hand_unit:melee():set_weapon_unit()
	self:_unlink_weapon()
	PlayerHandStateBow.super.at_exit(self, next_state)
end

function PlayerHandStateBow:gripping_string()
	return self._gripping_string
end

function PlayerHandStateBow:can_grip_string()
	return self._can_grip_string
end

function PlayerHandStateBow:_interrupt_grip()
	if self._gripping_string then
		self._interrupted = true
	end
end

function PlayerHandStateBow:_check_string_haptic(progress)
	local haptic_granularity = 0.04
	progress = math.sin(math.deg(progress))

	if not self._last_progress or haptic_granularity < math.abs(progress - self._last_progress) then
		self._last_progress = progress

		managers.vr:hand_state_machine():controller():get_controller("vr"):trigger_haptic_pulse(self:hsm():other_hand():hand_id() - 1, 0, 700)
	end
end

local hand_to_hand = Vector3()
local other_hand = Vector3()
local weapon_pos = Vector3()
local weapon_rot = Rotation()

function PlayerHandStateBow:update(t, dt)
	if alive(self._weapon_unit) then
		mvector3.set(weapon_pos, self:hsm():position())

		local controller = managers.vr:hand_state_machine():controller()

		if self._gripping_string then
			mrotation.set_look_at(weapon_rot, hand_to_hand, self:hsm():rotation():z())
			self._weapon_unit:set_rotation(weapon_rot)
			self._weapon_unit:base():set_gadget_rotation(weapon_rot)
		else
			local rot = self:hsm():rotation()

			self._weapon_unit:set_rotation(rot)
			self._weapon_unit:base():set_gadget_rotation(rot)
		end

		local body = managers.weapon_factory:get_part_from_weapon_by_type("lower_reciever", self._weapon_unit:base()._parts)
		local offset = tweak_data.vr:get_offset_by_id("bow", self._weapon_unit:base().name_id)
		local string_obj = body and alive(body.unit) and body.unit:get_object(offset and offset.string_object or Idstring("a_string_1"))

		if alive(string_obj) and self:hsm():other_hand():current_state_name() == "weapon" then
			mvector3.set(other_hand, self:hsm():other_hand():position())

			local string_dis_sq = mvector3.distance_sq(string_obj:position(), other_hand)
			local interact_btn = "primary_attack"

			if self._can_grip_string and not self._gripping_string and controller:get_input_bool(interact_btn) and not self._interrupted then
				self._gripping_string = true

				self:hsm():enter_controller_state("point")
				self:hsm():other_hand():enter_controller_state("arrow")
				self._weapon_unit:base():check_bullet_objects()
			end

			if string_dis_sq < 225 and self._weapon_unit:base():get_ammo_remaining_in_clip() > 0 then
				self._can_grip_string = true
			elseif not self._gripping_string then
				self._can_grip_string = false
			end

			if controller:get_input_released(interact_btn) then
				self._interrupted = nil
			end

			if controller:get_input_pressed("secondary_attack") then
				self:_interrupt_grip()
			end

			if self._gripping_string then
				if not controller:get_input_bool(interact_btn) or self._interrupted then
					self._gripping_string = nil

					self:hsm():enter_controller_state("empty")
					self:hsm():other_hand():exit_controller_state("arrow")
					self._weapon_unit:base():set_charge_multiplier(0)
					self._weapon_unit:base():check_bullet_objects()
					self:hsm():other_hand():current_state():lock_hand_orientation(nil)
				else
					local other_hand_dis = mvector3.direction(hand_to_hand, self:hsm():position(), other_hand)

					mvector3.negate(hand_to_hand)

					local min = 10
					local max = 50

					if offset and offset.string_distance then
						min, max = unpack(offset.string_distance)
					end

					local progress = math.clamp((other_hand_dis - min) / max, 0, 1)

					self._weapon_unit:base():set_charge_multiplier(progress)
					self:_check_string_haptic(progress)

					local pos = string_obj:position()
					local rot = self._weapon_unit:rotation()

					if offset and offset.position then
						pos = pos + offset.position:rotate_with(self._weapon_unit:rotation())
					end

					self:hsm():other_hand():current_state():lock_hand_orientation(pos, rot)
				end
			end
		end

		local tweak = tweak_data.vr:get_offset_by_id(self._weapon_unit:base().name_id)

		if tweak and tweak.position then
			mvector3.add(weapon_pos, tweak.position:rotate_with(self._weapon_unit:rotation()))
			self._weapon_unit:set_position(weapon_pos)
			self._weapon_unit:set_moving(2)
			self._weapon_unit:base():set_gadget_position(weapon_pos)
		end
	end
end
