require("lib/units/beings/player/states/vr/hand/PlayerHandState")

PlayerHandStateBelt = PlayerHandStateBelt or class(PlayerHandState)

function PlayerHandStateBelt:init(hsm, name, hand_unit, sequence)
	PlayerHandStateBelt.super.init(self, name, hsm, hand_unit, sequence)
end

function PlayerHandStateBelt:at_enter(prev_state)
	PlayerHandStateBelt.super.at_enter(self, prev_state)
	self._hsm:enter_controller_state("belt")

	self._belt_button = self:hsm():hand_id() == 1 and "belt_right" or "belt_left"

	managers.vr:hand_state_machine():controller():get_controller("vr"):trigger_haptic_pulse(self:hsm():hand_id() - 1, 0, 700)
end

function PlayerHandStateBelt:at_exit(next_state)
	PlayerHandStateBelt.super.at_exit(self, next_state)
	self._hsm:exit_controller_state("belt")
	self._hsm:exit_controller_state("ability")

	if self._belt_state then
		managers.hud:belt():set_selected(self._belt_state, false)
	end

	self._belt_state = nil
end

function PlayerHandStateBelt:update(t, dt)
	local belt_state = nil

	for _, state in ipairs(managers.hud:belt():valid_interactions()) do
		if managers.hud:belt():interacting(state, self._hand_unit:position()) then
			belt_state = state
		end
	end

	if belt_state ~= self._belt_state then
		if self._belt_state then
			managers.hud:belt():set_selected(self._belt_state, false)
		end

		if belt_state then
			managers.hud:belt():set_selected(belt_state, true)
		end

		if self._belt_state == "throwable" and managers.blackmarket:has_equipped_ability() then
			self._hsm:exit_controller_state("ability")
		elseif belt_state == "throwable" and managers.blackmarket:has_equipped_ability() then
			self._hsm:enter_controller_state("ability")
		end

		self._belt_state = belt_state
	end

	if self._belt_state then
		local player = managers.player:player_unit()

		if self._belt_state == "reload" and self._hsm:default_state_name() == "weapon" and (self._hsm:other_hand():default_state_name() ~= "bow" or managers.vr:hand_state_machine():controller():get_input_pressed(self._belt_button)) and player:movement():current_state():can_trigger_reload() then
			player:movement():current_state():trigger_reload()
			managers.hud:belt():trigger_reload()
			self:hsm():change_to_default()
		end

		if managers.vr:hand_state_machine():controller():get_input_pressed(self._belt_button) then
			if self._belt_state == "weapon" then
				local hsm = self:hsm()
				local inv = player:inventory()
				local _, wanted_selection = player:inventory():get_next_selection()

				player:movement():current_state():swap_weapon(wanted_selection)
				player:sound():play("m4_equip")
				player:inventory():equip_selection(wanted_selection, true)
				hsm:set_default_state("weapon")
				hsm:other_hand():set_default_state("idle")
			elseif self._belt_state == "bag" then
				local carry_id = managers.player:get_my_carry_data().carry_id
				local unit_name = tweak_data.carry[carry_id].unit

				if unit_name then
					unit_name = string.match(unit_name, "/([^/]*)$")
					unit_name = "units/pd2_dlc_vr/equipment/" .. unit_name .. "_vr"
				else
					unit_name = "units/pd2_dlc_vr/equipment/gen_pku_lootbag_vr"
				end

				local unit = World:spawn_unit(Idstring(unit_name), self._hand_unit:position(), self._hand_unit:rotation() * Rotation(0, 0, -90))

				self._hsm:change_state_by_name("item", {
					body = "hinge_body_1",
					type = "bag",
					unit = unit,
					offset = Vector3(0, 15, 0),
					prev_state = self._prev_state,
					prompt = {
						text_id = "hud_instruct_throw_bag",
						btn_macros = {
							BTN_USE_ITEM = "use_item_vr"
						}
					}
				})
			elseif self._belt_state == "deployable" or self._belt_state == "deployable_secondary" then
				self._hsm:change_state_by_name("item", {
					type = "deployable",
					prev_state = self._prev_state,
					secondary = self._belt_state == "deployable_secondary"
				})
			elseif self._belt_state == "throwable" then
				local grenade_entry = managers.blackmarket:equipped_grenade()
				local grenade_unit = World:spawn_unit(Idstring(tweak_data.blackmarket.projectiles[grenade_entry].unit_dummy), Vector3(0, 0, 0), Rotation())

				self._hsm:change_state_by_name("item", {
					type = "throwable",
					unit = grenade_unit,
					prev_state = self._prev_state
				})
			elseif self._belt_state == "melee" then
				self._hsm:change_state_by_name("melee", {
					prev_state = self._prev_state
				})
			elseif self._belt_state == "reload" and self._hsm:default_state_name() ~= "weapon" then
				local weap_base = player:inventory():equipped_unit():base()

				if player:movement():current_state():can_grab_mag() then
					local mag_unit = weap_base:spawn_belt_magazine_unit(weap_base.akimbo and Vector3(-5, 0, 0) or Vector3())

					if mag_unit then
						local second_mag = nil

						if weap_base.akimbo then
							second_mag = weap_base:spawn_belt_magazine_unit()

							mag_unit:link(mag_unit:orientation_object():name(), second_mag)
						end

						local offset = tweak_data.vr:get_offset_by_id("magazine", weap_base.name_id)

						if weap_base:reload_object_name() then
							for _, mag in ipairs({
								mag_unit,
								second_mag
							}) do
								local reload_obj = mag:get_object(Idstring(weap_base:reload_object_name()))

								reload_obj:set_position(mag:position())
								reload_obj:set_visibility(true)
							end
						end

						self._hsm:change_state_by_name("item", {
							type = "magazine",
							unit = mag_unit,
							offset = offset,
							prev_state = self._prev_state
						})
						managers.hud:belt():trigger_reload()
						player:movement():current_state():grab_mag()
					end
				end
			end
		end
	end
end
