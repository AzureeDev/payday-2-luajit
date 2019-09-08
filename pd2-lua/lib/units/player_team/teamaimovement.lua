TeamAIMovement = TeamAIMovement or class(CopMovement)
local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_len = mvector3.length

function TeamAIMovement:_post_init()
	if managers.groupai:state():whisper_mode() then
		if not self._heat_listener_clbk and Network:is_server() then
			self._heat_listener_clbk = "TeamAIMovement" .. tostring(self._unit:key())

			managers.groupai:state():add_listener(self._heat_listener_clbk, {
				"whisper_mode"
			}, callback(self, self, "heat_clbk"))
		end

		self._unit:base():set_slot(self._unit, 24)
	else
		self:set_cool(false)
	end

	self._standing_nav_seg_id = self._nav_tracker:nav_segment()

	self:play_redirect("idle")

	self._last_position = Vector3()
end

function TeamAIMovement:set_character_anim_variables()
	local char_name = managers.criminals:character_name_by_unit(self._unit)

	if char_name and self._unit:damage() then
		local ai_character_id = managers.criminals:character_static_data_by_name(char_name).ai_character_id
		local sequence = tweak_data.blackmarket.characters[ai_character_id].sequence

		if sequence ~= self._current_sequence then
			self._unit:damage():run_sequence_simple(sequence)

			self._current_sequence = sequence
		end
	end

	HuskPlayerMovement.set_character_anim_variables(self)
	self._unit:inventory():preload_mask()
end

function TeamAIMovement:check_visual_equipment()
end

function TeamAIMovement:add_weapons()
	if Network:is_server() then
		local char_name = self._ext_base._tweak_table
		local loadout = managers.criminals:get_loadout_for(char_name)
		local crafted = managers.blackmarket:get_crafted_category_slot("primaries", loadout.primary_slot)

		if crafted then
			self._unit:inventory():add_unit_by_factory_blueprint(loadout.primary, false, false, crafted.blueprint, crafted.cosmetics)
		elseif loadout.primary then
			self._unit:inventory():add_unit_by_factory_name(loadout.primary, false, false, nil, "")
		else
			local weapon = self._ext_base:default_weapon_name("primary")
			local _ = weapon and self._unit:inventory():add_unit_by_factory_name(weapon, false, false, nil, "")
		end

		local sec_weap_name = self._ext_base:default_weapon_name("secondary")
		local _ = sec_weap_name and self._unit:inventory():add_unit_by_name(sec_weap_name)
	else
		TeamAIMovement.super.add_weapons(self)
	end
end

function TeamAIMovement:m_detect_pos()
	return self._m_head_pos
end

function TeamAIMovement:set_position(pos)
	CopMovement.set_position(self, pos)
	self:_upd_location()
end

function TeamAIMovement:set_m_pos(pos)
	CopMovement.set_m_pos(self, pos)
	self:_upd_location()
end

function TeamAIMovement:_upd_location()
	local nav_seg_id = self._nav_tracker:nav_segment()

	if self._standing_nav_seg_id ~= nav_seg_id then
		self._standing_nav_seg_id = nav_seg_id

		managers.groupai:state():on_criminal_nav_seg_change(self._unit, nav_seg_id)
	end
end

function TeamAIMovement:get_location_id()
	local metadata = managers.navigation:get_nav_seg_metadata(self._standing_nav_seg_id)

	return metadata and metadata.location_id
end

function TeamAIMovement:on_cuffed()
	self._unit:brain():set_logic("surrender")
	self._unit:network():send("arrested")
	self._unit:character_damage():on_arrested()
end

function TeamAIMovement:on_SPOOCed(enemy_unit)
	self._unit:character_damage():on_incapacitated()
end

function TeamAIMovement:is_SPOOC_attack_allowed()
	if alive(self.vehicle_unit) then
		return false
	end

	return true
end

function TeamAIMovement:on_discovered()
	if self._cool then
		self:_switch_to_not_cool()
	end
end

function TeamAIMovement:on_tase_ended()
	self._unit:character_damage():on_tase_ended()
end

function TeamAIMovement:tased()
	return self._unit:anim_data().tased
end

function TeamAIMovement:cool()
	return self._cool
end

function TeamAIMovement:downed()
	return self._unit:interaction()._active
end

function TeamAIMovement:set_cool(state)
	state = state and true or false

	if state == self._cool then
		return
	end

	local old_state = self._cool

	if state then
		self._cool = true

		if not self._heat_listener_clbk and Network:is_server() then
			self._heat_listener_clbk = "TeamAIMovement" .. tostring(self._unit:key())

			managers.groupai:state():add_listener(self._heat_listener_clbk, {
				"whisper_mode"
			}, callback(self, self, "heat_clbk"))
		end

		self._unit:base():set_slot(self._unit, 24)

		if self._unit:brain().on_cool_state_changed then
			self._unit:brain():on_cool_state_changed(true)
		end

		self:set_stance_by_code(1)
		self._unit:inventory():set_visibility_state(false)
	else
		self._not_cool_t = TimerManager:game():time()

		self:_switch_to_not_cool(true)
	end
end

function TeamAIMovement:heat_clbk(state)
	if self._cool and not state then
		self:_switch_to_not_cool()
	end
end

function TeamAIMovement:_switch_to_not_cool(instant)
	if not Network:is_server() then
		if instant then
			self._unit:inventory():set_visibility_state(true)
		end

		self._cool = false

		return
	end

	if self._heat_listener_clbk then
		managers.groupai:state():remove_listener(self._heat_listener_clbk)

		self._heat_listener_clbk = nil
	end

	if instant then
		if self._switch_to_not_cool_clbk_id then
			local mute_debug_pause = self._switch_to_not_cool_clbk_id == "dummy"

			managers.enemy:remove_delayed_clbk(self._switch_to_not_cool_clbk_id, mute_debug_pause)
		end

		self._switch_to_not_cool_clbk_id = "dummy"

		self:_switch_to_not_cool_clbk_func()
	elseif not self._switch_to_not_cool_clbk_id then
		self._switch_to_not_cool_clbk_id = "switch_to_not_cool_clbk" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._switch_to_not_cool_clbk_id, callback(self, self, "_switch_to_not_cool_clbk_func"), TimerManager:game():time() + math.random() * 1 + 0.5)
	end
end

function TeamAIMovement:_switch_to_not_cool_clbk_func()
	if self._switch_to_not_cool_clbk_id and self._cool then
		if self._unit:inventory():is_mask_unit_loaded() then
			self._switch_to_not_cool_clbk_id = nil
			self._cool = false
			self._not_cool_t = TimerManager:game():time()

			self._unit:base():set_slot(self._unit, 16)

			if self._unit:brain()._logic_data and self._unit:brain():is_available_for_assignment() then
				self._unit:brain():set_objective()
				self._unit:movement():action_request({
					sync = true,
					body_part = 1,
					type = "idle"
				})
			end

			self:set_stance_by_code(2)
			self._unit:brain():on_cool_state_changed(false)
			self._unit:inventory():set_visibility_state(true)
		else
			managers.enemy:add_delayed_clbk(self._switch_to_not_cool_clbk_id, callback(self, self, "_switch_to_not_cool_clbk_func"), TimerManager:game():time() + 1)
		end
	end
end

function TeamAIMovement:zipline_unit()
	return nil
end

function TeamAIMovement:current_state_name()
	return nil
end

function TeamAIMovement:pre_destroy()
	if self._heat_listener_clbk then
		managers.groupai:state():remove_listener(self._heat_listener_clbk)

		self._heat_listener_clbk = nil
	end

	if self._nav_tracker then
		managers.navigation:destroy_nav_tracker(self._nav_tracker)

		self._nav_tracker = nil
	end

	if self._switch_to_not_cool_clbk_id then
		managers.enemy:remove_delayed_clbk(self._switch_to_not_cool_clbk_id)

		self._switch_to_not_cool_clbk_id = nil
	end

	if self._link_data then
		self._link_data.parent:base():remove_destroy_listener("CopMovement" .. tostring(unit:key()))
	end

	if alive(self._rope) then
		self._rope:base():retract()

		self._rope = nil
	end

	self:_destroy_gadgets()

	for i_action, action in ipairs(self._active_actions) do
		if action and action.on_destroy then
			action:on_destroy()
		end
	end

	if self._attention and self._attention.destroy_listener_key then
		self._attention.unit:base():remove_destroy_listener(self._attention.destroy_listener_key)

		self._attention.destroy_listener_key = nil
	end
end

function TeamAIMovement:save(save_data)
	TeamAIMovement.super.save(self, save_data)

	save_data.movement = save_data.movement or {}
	save_data.movement.should_stay = self._should_stay
	save_data.movement.has_bag = self:carrying_bag()
end

function TeamAIMovement:load(load_data)
	TeamAIMovement.super.load(self, load_data)

	if load_data.movement then
		self:set_should_stay(load_data.movement.should_stay)

		if load_data.movement.has_bag and Network:is_client() then
			managers.network:session():send_to_host("request_carried_bag_unit", self._unit)
		end
	end
end

function TeamAIMovement:set_should_stay(should_stay)
	if self._should_stay ~= should_stay then
		local panel = managers.criminals:character_data_by_unit(self._unit)

		if panel then
			managers.hud:set_ai_stopped(panel.panel_id, should_stay)
		end

		self._should_stay = should_stay

		managers.network:session():send_to_peers_synched("sync_team_ai_stopped", self._unit, should_stay)

		if should_stay then
			managers.groupai:state():upd_team_AI_distance()
		end
	end
end

function TeamAIMovement:chk_action_forbidden(action_type)
	if action_type == "walk" and self._should_stay then
		if Network:is_server() and self._unit:brain():objective() and (self._unit:brain():objective().type == "revive" or self._unit:brain():objective().forced) then
			return false
		end

		return true
	end

	return TeamAIMovement.super.chk_action_forbidden(self, action_type)
end

function TeamAIMovement:carrying_bag()
	return self._carry_unit and true or false
end

function TeamAIMovement:set_carrying_bag(unit)
	self._carry_unit = unit
end

function TeamAIMovement:carry_id()
	return self._carry_unit and self._carry_unit:carry_data():carry_id()
end

function TeamAIMovement:carry_data()
	return self._carry_unit and self._carry_unit:carry_data()
end

function TeamAIMovement:carry_tweak()
	return self:carry_id() and tweak_data.carry.types[tweak_data.carry[self:carry_id()].type]
end

function TeamAIMovement:throw_bag(target_unit, reason)
	if not self:carrying_bag() then
		return
	end

	local carry_unit = self._carry_unit
	self._was_carrying = {
		unit = carry_unit,
		reason = reason
	}

	carry_unit:carry_data():unlink()

	if Network:is_server() then
		self:sync_throw_bag(carry_unit, target_unit)
		managers.network:session():send_to_peers("sync_ai_throw_bag", self._unit, carry_unit, target_unit)
	end
end

function TeamAIMovement:was_carrying_bag()
	return self._was_carrying
end

function TeamAIMovement:sync_throw_bag(carry_unit, target_unit)
	if alive(target_unit) then
		local dir = target_unit:position() - self._unit:position()

		mvector3.set_z(dir, math.abs(dir.x + dir.y) * 0.5)

		local throw_distance_multiplier = tweak_data.carry.types[tweak_data.carry[carry_unit:carry_data():carry_id()].type].throw_distance_multiplier

		carry_unit:push(tweak_data.ai_carry.throw_force, (dir - carry_unit:velocity()) * throw_distance_multiplier)
	end
end

function TeamAIMovement:update(...)
	TeamAIMovement.super.update(self, ...)

	if self._pre_destroyed then
		return
	end

	if self._ext_anim and self._ext_anim.reload then
		if not alive(self._left_hand_obj) then
			self._left_hand_obj = self._unit:get_object(Idstring("LeftHandMiddle1"))
		end

		if alive(self._left_hand_obj) then
			if self._left_hand_pos then
				self._left_hand_direction = self._left_hand_direction or Vector3()

				mvec3_set(self._left_hand_direction, self._left_hand_pos)
				mvec3_sub(self._left_hand_direction, self._left_hand_obj:position())

				self._left_hand_velocity = mvec3_len(self._left_hand_direction)

				mvec3_norm(self._left_hand_direction)
			end

			self._left_hand_pos = self._left_hand_pos or Vector3()

			mvec3_set(self._left_hand_pos, self._left_hand_obj:position())
		end
	end
end
