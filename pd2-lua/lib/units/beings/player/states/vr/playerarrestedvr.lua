PlayerArrestedVR = PlayerArrested or Application:error("PlayerArrestedVR needs PlayerArrested!")
local __enter = PlayerArrested.enter
local __exit = PlayerArrested.exit
local __destroy = PlayerArrested.destroy

function PlayerArrestedVR:enter(...)
	__enter(self, ...)
	self._ext_movement:set_orientation_state("cuffed", self._unit:position())
	self._unit:hand():set_cuffed(true)
	self:set_belt_and_hands_enabled(false)
end

function PlayerArrestedVR:exit(...)
	__exit(self, ...)
	self._ext_movement:set_orientation_state("none")
	self._unit:hand():set_cuffed(false)
	self:set_belt_and_hands_enabled(true)
end

function PlayerArrestedVR:destroy()
	if managers.network:session() then
		self:set_belt_and_hands_enabled(true)
	end

	__destroy(self)
end

local mvec_pos_new = Vector3()
local mvec_hmd_delta = Vector3()

function PlayerArrestedVR:_update_movement(t, dt)
	local pos_new = mvec_pos_new

	mvector3.set(pos_new, self._ext_movement:ghost_position())

	local hmd_delta = mvec_hmd_delta

	mvector3.set(hmd_delta, self._ext_movement:hmd_delta())
	mvector3.set_z(hmd_delta, 0)
	mvector3.rotate_with(hmd_delta, self._camera_base_rot)
	mvector3.add(pos_new, hmd_delta)
	self._ext_movement:set_ghost_position(pos_new)
end

function PlayerArrestedVR:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	if self._unit:character_damage()._arrested_timer <= 0 and not self._timer_finished then
		self._timer_finished = true

		managers.hud:pd_stop_timer()
		managers.hud:pd_show_text()
		PlayerStandard.say_line(self, "s21x_sin")
	end

	if self._equip_weapon_expire_t and self._equip_weapon_expire_t <= t then
		self._equip_weapon_expire_t = nil
	end

	if self._unequip_weapon_expire_t and t >= self._unequip_weapon_expire_t + 0.5 then
		self._unequip_weapon_expire_t = nil
	end

	self:_update_foley(t, input)

	local new_action = self:_check_action_interact(t, input)
end

function PlayerArrestedVR:set_belt_and_hands_enabled(enabled)
	if not enabled then
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
