require("lib/units/beings/player/states/vr/hand/PlayerHandState")

PlayerHandStateItem = PlayerHandStateItem or class(PlayerHandState)

function PlayerHandStateItem:init(hsm, name, hand_unit, sequence)
	PlayerHandStateItem.super.init(self, name, hsm, hand_unit, sequence)

	self._dynamic_geometry = hand_unit:get_object(Idstring("g_dyn_throw"))

	if self._dynamic_geometry then
		local length = 50

		self._dynamic_geometry:bezier_cylinder(Vector3(0, 0, 0), math.Y, math.Z, Vector3(length, 0, 0), Vector3(length * 0.5, 0, 0), Vector3(length * 0.5, 0, 0), Vector3(0, 0, 0), 2, 10, Color(1, 1, 1, 1))
		self._dynamic_geometry:set_visibility(false)
	end
end

function PlayerHandStateItem:_link_item(item_unit, body, offset)
	self._item_unit = item_unit

	if body then
		self._hand_unit:link(Idstring("g_glove"), item_unit)

		local body_obj = item_unit:body(body) or item_unit:body(0)

		body_obj:set_keyframed()

		self._body = body_obj

		self:set_bodies_colliding(false)
	else
		self._hand_unit:link(Idstring("g_glove"), item_unit, item_unit:orientation_object():name())
	end

	if offset then
		if type(offset) == "table" then
			self._item_unit:set_local_position(offset.position)
			self._item_unit:set_local_rotation(offset.rotation)

			local sequence = self._sequence

			if offset.grip then
				sequence = offset.grip
			end

			if self._hand_unit and sequence and self._hand_unit:damage():has_sequence(sequence) then
				self._hand_unit:damage():run_sequence_simple(sequence)
			end
		else
			self._item_unit:set_local_position(offset)
		end
	end

	self._item_unit:set_visible(true)
end

function PlayerHandStateItem:_prompt(prompt)
	self._prompt_data = prompt

	if prompt.btn_macros then
		prompt.macros = prompt.macros or {}

		for key, macro in pairs(prompt.btn_macros) do
			prompt.macros[key] = managers.localization:btn_macro(macro)
		end
	end

	local text = nil

	if prompt.text then
		text = prompt.text
	elseif prompt.text_id then
		text = managers.localization:to_upper_text(prompt.text_id, prompt.macros)
	end

	local offset = nil
	local hand_id = self:hsm():hand_id()

	if self._item_type == "mask" and alive(self._item_unit) then
		offset = Vector3(self._item_unit:oobb():size().x / 2 * (hand_id == 1 and -1 or 1))
	end

	managers.hud:link_watch_prompt_as_hand(self._hand_unit, hand_id, offset)
	managers.hud:show_interact({
		text = text
	})
	managers.hud:watch_prompt_panel():show()
end

function PlayerHandStateItem:item_type()
	return self._item_type
end

function PlayerHandStateItem:item_unit()
	return self._item_unit
end

function PlayerHandStateItem:switch_hands()
	self._switching_hands = true

	self:hsm():other_hand():change_state_by_name("item", {
		unit = self._item_unit,
		type = self._item_type,
		prompt = self._prompt_data
	})
	self:hsm():change_to_default()
end

function PlayerHandStateItem:at_enter(prev_state, params)
	PlayerHandStateItem.super.at_enter(self, prev_state, params)

	if not params then
		debug_pause("[PlayerHandStateItem:at_enter] Entered item state without params!")
	end

	if params.type ~= "magazine" then
		managers.player:player_unit():movement():current_state():_interupt_action_reload()
	end

	if alive(params.unit) then
		self:_link_item(params.unit, params.body, params.offset)
	end

	self._item_type = params.type
	self._controller_state = "item"

	if self._item_type == "mask" then
		for _, linked_unit in ipairs(self._item_unit:children()) do
			linked_unit:set_visible(true)
		end

		self._item_unit:set_visible(true)

		local offset = tweak_data.vr:get_offset_by_id(managers.blackmarket:equipped_mask().mask_id)

		if offset then
			self._item_unit:set_local_rotation(offset.rotation or Rotation())
			self._item_unit:set_local_position(offset.position or Vector3())
		end

		self._hand_unit:set_visible(false)

		self._controller_state = "mask"
	elseif self._item_type == "deployable" then
		self._controller_state = "equipment"

		self._hand_unit:damage():run_sequence_simple("ready")

		self._secondary_deployable = params.secondary
	elseif self._item_type == "throwable" then
		if self._dynamic_geometry then
			self._dynamic_geometry:set_visibility(true)
		end

		local offset = tweak_data.vr:get_offset_by_id(managers.blackmarket:equipped_grenade())

		if offset then
			self._item_unit:set_local_rotation(offset.rotation or Rotation())
			self._item_unit:set_local_position(offset.position or Vector3())

			local sequence = self._sequence

			if offset.grip then
				sequence = offset.grip
			end

			if self._hand_unit and sequence and self._hand_unit:damage():has_sequence(sequence) then
				self._hand_unit:damage():run_sequence_simple(sequence)
			end
		end
	end

	self:hsm():enter_controller_state(self._controller_state)

	if params.prompt then
		self:_prompt(params.prompt)
	end

	if self._item_type == "bag" or self._item_type == "deployable" or self._item_type == "throwable" then
		managers.hud:belt():set_state(self._secondary_deployable and "deployable_secondary" or self._item_type, "active")
	end

	if self._item_type == "deployable" then
		managers.hud:link_watch_prompt_as_hand(self._hand_unit, self:hsm():hand_id())
	end
end

function PlayerHandStateItem:at_exit(next_state, hide_item)
	self:hsm():exit_controller_state(self._controller_state)

	if self._dynamic_geometry then
		self._dynamic_geometry:set_visibility(false)
	end

	if self._item_type == "mask" then
		self._hand_unit:set_visible(true)
	end

	if not self._switching_hands then
		managers.hud:watch_prompt_panel():hide()

		if hide_item or self._item_type == "mask" then
			self:_hide_unit()
		else
			self:_remove_unit()
		end
	end

	PlayerHandStateItem.super.at_exit(self, next_state)

	self._switching_hands = false
end

function PlayerHandStateItem:_remove_unit()
	if alive(self._item_unit) then
		for _, linked_unit in ipairs(self._item_unit:children()) do
			linked_unit:unlink()
			World:delete_unit(linked_unit)
		end

		self._item_unit:unlink()
		World:delete_unit(self._item_unit)
	end

	if self._item_type == "deployable" then
		managers.player:player_unit():equipment():on_deploy_interupted()
	end
end

function PlayerHandStateItem:_hide_unit()
	if alive(self._item_unit) then
		for _, linked_unit in ipairs(self._item_unit:children()) do
			linked_unit:set_visible(false)
		end

		self._item_unit:set_visible(false)
	end

	if self._item_type == "deployable" then
		managers.player:player_unit():equipment():on_deploy_interupted()
	end
end

function PlayerHandStateItem:set_warping(warping)
	if not warping then
		self._wants_dynamic = true

		return
	end

	if self._body then
		self:set_bodies_dynamic(not warping, self._body)
	end
end

function PlayerHandStateItem:set_bodies_dynamic(dynamic, ignore_body)
	if alive(self._item_unit) then
		for i = 0, self._item_unit:num_bodies() - 1 do
			local body = self._item_unit:body(i)

			if not ignore_body or body ~= ignore_body then
				if dynamic then
					body:set_dynamic()
				else
					body:set_keyframed()
				end
			end
		end
	end
end

function PlayerHandStateItem:set_bodies_colliding(colliding)
	if alive(self._item_unit) then
		for i = 0, self._item_unit:num_bodies() - 1 do
			self._item_unit:body(i):set_collisions_enabled(colliding)
		end
	end
end

function PlayerHandStateItem:update(t, dt)
	if self._wants_dynamic then
		self._dynamic_t = t + 0.05
		self._wants_dynamic = false
	end

	if self._dynamic_t and self._dynamic_t < t then
		self:set_bodies_dynamic(true, self._body)

		self._dynamic_t = nil
	end

	local controller = managers.vr:hand_state_machine():controller()

	if controller:get_input_pressed("use_item_vr") and self._item_type == "throwable" and not managers.player:player_unit():hand():check_hand_through_wall(self:hsm():hand_id()) then
		managers.player:player_unit():equipment():throw_projectile(self._hand_unit)

		if not managers.vr:get_setting("keep_items_in_hand") or not managers.player:can_throw_grenade() then
			self:_remove_unit()
			managers.player:player_unit():movement():current_state():set_throwing_projectile(self:hsm():hand_id())
			self:hsm():change_to_default()
		end
	end

	if self._item_type ~= "mask" and self._item_type ~= "magazine" and (controller:get_input_pressed("unequip") or controller:get_input_released("use_item")) then
		if not self._item_type == "bag" or controller:get_input_pressed("unequip") then
			managers.hud:belt():set_state(self._secondary_deployable and "deployable_secondary" or self._item_type, "default")
		end

		local should_keep_item = managers.vr:get_setting("keep_items_in_hand") and self._item_type == "deployable" and managers.player:can_use_selected_equipment()

		if not should_keep_item or controller:get_input_pressed("unequip") then
			self:hsm():change_to_default()
		end
	end

	if self._item_type == "deployable" then
		local equipment_id = managers.player:equipment_in_slot(self._secondary_deployable and 2 or 1)

		if managers.player:selected_equipment_id() ~= equipment_id then
			managers.player:switch_equipment()
		end

		local valid = managers.player:check_equipment_placement_valid(managers.player:player_unit(), equipment_id)

		if not valid then
			self._hand_unit:damage():run_sequence_simple("ready_warning")
		else
			self._hand_unit:damage():run_sequence_simple("ready")
		end
	elseif self._item_type == "magazine" then
		local player = managers.player:player_unit()
		local weapon = player:inventory():equipped_unit()
		local mag_locator = weapon:get_object(Idstring("a_m"))
		local offset = tweak_data.vr:get_offset_by_id("magazine", weapon:base().name_id)
		local mag_pos = nil

		if mag_locator and not offset.weapon_offset then
			mag_pos = mag_locator:position()
			mag_pos = mag_pos - offset.position:rotate_with(weapon:rotation())
		else
			mag_pos = weapon:position()

			if offset.weapon_offset then
				mag_pos = mag_pos + offset.weapon_offset:rotate_with(weapon:rotation())
			end
		end

		if mvector3.distance_sq(self._hand_unit:position(), mag_pos) < 400 then
			player:movement():current_state():trigger_reload()
			self:hsm():change_to_default()
		end
	end
end

function PlayerHandStateItem:swipe_transition(next_state, params)
	params.unit = alive(self._item_unit) and self._item_unit
	params.type = self._item_type
	params.prompt = self._prompt_data

	self:at_exit(next_state, true)
	next_state:at_enter(self, params)
end
