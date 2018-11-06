PlayerFatalVR = PlayerFatal or Application:error("PlayerFatalVR need PlayerFatal!")
PlayerFatalVR._update_movement = PlayerBleedOutVR._update_movement
PlayerFatalVR._start_action_dead = PlayerBleedOutVR._start_action_bleedout
PlayerFatalVR._end_action_dead = PlayerBleedOutVR._end_action_bleedout
local __enter = PlayerFatal.enter
local __exit = PlayerFatal.exit
local __destroy = PlayerFatal.destroy

function PlayerFatalVR:enter(...)
	__enter(self, ...)
	self._ext_movement:set_orientation_state("incapacitated", self._unit:position())
end

function PlayerFatalVR:exit(state_data, new_state_name)
	self._ext_movement:set_orientation_state("none")

	local exit_data = __exit(self, state_data, new_state_name) or {}

	if new_state_name == "carry" then
		exit_data.skip_hand_carry = true
	end

	return exit_data
end

function PlayerFatalVR:destroy()
	if managers.network:session() then
		self:set_belt_and_hands_enabled(true)
	end

	__destroy(self)
end

function PlayerFatalVR:set_belt_and_hands_enabled(enabled)
	if not enabled then
		self._weapon_hand_id = self._unit:hand():get_active_hand_id("weapon")

		if self._weapon_hand_id then
			local akimbo_id = self._unit:hand():get_active_hand_id("akimbo")

			if akimbo_id then
				self._unit:hand():set_default_state(akimbo_id, "idle")
			end

			local bow_hand_id = self._unit:hand():get_active_hand_id("bow")

			if bow_hand_id then
				self._unit:hand():set_default_state(bow_hand_id, "idle")
			end

			self._unit:hand():_set_hand_state(self._weapon_hand_id, "idle")
			self._unit:hand():_change_hand_to_default(PlayerHand.other_hand_id(self._weapon_hand_id))
		end

		local belt_states = {
			melee = managers.hud:belt():state("melee"),
			deployable = managers.hud:belt():state("deployable"),
			deployable_secondary = managers.hud:belt():state("deployable_secondary"),
			throwable = managers.hud:belt():state("throwable"),
			weapon = managers.hud:belt():state("weapon"),
			bag = managers.hud:belt():state("bag")
		}

		for id, state in pairs(belt_states) do
			if state ~= "disabled" then
				managers.hud:belt():set_state(id, "disabled")
			end
		end
	else
		if self._weapon_hand_id and self._unit:hand() then
			self._unit:hand():_set_hand_state(self._weapon_hand_id, "weapon")
		end

		managers.hud:belt():set_state("melee", "default")
		managers.hud:belt():set_state("weapon", "default")
		managers.hud:belt():set_state("throwable", managers.player:get_grenade_amount(managers.network:session():local_peer():id()) > 0 and "default" or "invalid")
		managers.hud:belt():set_state("bag", managers.player:is_carrying() and "default" or "inactive")

		for slot, equipment in ipairs({
			managers.player:equipment_in_slot(1),
			managers.player:equipment_in_slot(2)
		}) do
			local amount = managers.player:get_equipment_amount(equipment)

			managers.hud:belt():set_state(slot == 1 and "deployable" or "deployable_secondary", amount > 0 and "default" or "invalid")
		end
	end
end
