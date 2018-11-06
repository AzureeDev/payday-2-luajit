PlayerBleedOutVR = PlayerBleedOut or Application:error("PlayerBleedOutVR need PlayerBleedOut!")
local __update_movement = PlayerBleedOut._update_movement
local __enter = PlayerBleedOut.enter
local __exit = PlayerBleedOut.exit
local __destroy = PlayerBleedOut.destroy

function PlayerBleedOutVR:enter(...)
	__enter(self, ...)
	self._ext_movement:set_orientation_state("bleedout", self._unit:position())
end

function PlayerBleedOutVR:exit(state_data, new_state_name)
	self._ext_movement:set_orientation_state("none")

	local exit_data = __exit(self, state_data, new_state_name) or {}

	if new_state_name == "carry" then
		exit_data.skip_hand_carry = true
	end

	return exit_data
end

function PlayerBleedOutVR:destroy()
	if managers.network:session() then
		self:set_belt_and_hands_enabled(true)
	end

	__destroy(self)
end

local mvec_pos_new = Vector3()
local mvec_hmd_delta = Vector3()
local mvec_hmd_pos = Vector3()
local vec_ray_up = Vector3(0, 0, 200)
local vec_ray_down = Vector3(0, 0, 200)

function PlayerBleedOutVR:_update_movement(t, dt)
	__update_movement(self, t, dt)

	local pos_new = mvec_pos_new

	mvector3.set(pos_new, self._ext_movement:ghost_position())

	local hmd_pos = mvec_hmd_pos

	mvector3.set(hmd_pos, self._ext_movement:hmd_position())

	local move_unit = false
	local from = pos_new + vec_ray_up
	local to = pos_new - vec_ray_down
	local ray = self._unit:raycast("ray", from, to, "slot_mask", 1)

	if ray then
		mvector3.set_z(self._height_offset, hmd_pos.z * 0.6)
		mvector3.set_z(pos_new, ray.position.z - self._height_offset.z)
	else
		mvector3.set_z(pos_new, pos_new.z - self.WARP_SPEED * dt)

		move_unit = true
	end

	local hmd_delta = mvec_hmd_delta

	mvector3.set(hmd_delta, self._ext_movement:hmd_delta())
	mvector3.set_z(hmd_delta, 0)
	mvector3.rotate_with(hmd_delta, self._camera_base_rot)
	mvector3.add(pos_new, hmd_delta)
	self._ext_movement:set_ghost_position(pos_new, not move_unit and self._unit:position())
end

function PlayerBleedOutVR:_start_action_bleedout(t)
	self:_interupt_action_running(t)
	self._unit:kill_mover()
	self._unit:hand():set_custom_belt_height_ratio(0.8)

	self._height_offset = Vector3()

	self:set_belt_and_hands_enabled(false)

	self._state_data.downed = true
end

function PlayerBleedOutVR:_end_action_bleedout(t)
	self:_activate_mover(Idstring(self:_can_stand() and "stand" or "duck"))
	self._unit:mover():set_velocity(Vector3())

	local new_pos = self._ext_movement:ghost_position() + self._height_offset

	self._ext_movement:set_ghost_position(new_pos)
	self._unit:hand():set_custom_belt_height_ratio(nil)
	self:set_belt_and_hands_enabled(true)

	self._state_data.downed = false
end

function PlayerBleedOutVR:set_belt_and_hands_enabled(enabled)
	if not enabled then
		local disallowed_hand_id = self._unit:hand():get_active_hand_id("melee") or self._unit:hand():get_active_hand_id("deployable")

		if disallowed_hand_id then
			self._unit:hand():_change_hand_to_default(disallowed_hand_id)
		end

		self._bow_hand_id = self._unit:hand():get_active_hand_id("bow")

		if self._bow_hand_id then
			self._unit:hand():set_default_state(self._bow_hand_id, "idle")
		end

		local belt_states = {
			melee = managers.hud:belt():state("melee"),
			deployable = managers.hud:belt():state("deployable"),
			deployable_secondary = managers.hud:belt():state("deployable_secondary")
		}

		for id, state in pairs(belt_states) do
			if state ~= "disabled" then
				managers.hud:belt():set_state(id, "disabled")
			end
		end
	else
		if self._bow_hand_id and self._unit:hand() then
			self._unit:hand():set_default_state(self._bow_hand_id, "bow")
		end

		managers.hud:belt():set_state("melee", "default")

		for slot, equipment in ipairs({
			managers.player:equipment_in_slot(1),
			managers.player:equipment_in_slot(2)
		}) do
			local amount = managers.player:get_equipment_amount(equipment)

			managers.hud:belt():set_state(slot == 1 and "deployable" or "deployable_secondary", amount > 0 and "default" or "invalid")
		end
	end
end
