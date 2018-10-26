require("lib/units/civilians/logics/CivilianLogicBase")
require("lib/units/civilians/logics/CivilianLogicInactive")
require("lib/units/civilians/logics/CivilianLogicIdle")
require("lib/units/civilians/logics/CivilianLogicFlee")
require("lib/units/civilians/logics/CivilianLogicSurrender")
require("lib/units/civilians/logics/CivilianLogicEscort")
require("lib/units/civilians/logics/CivilianLogicTravel")
require("lib/units/civilians/logics/CivilianLogicTrade")

CivilianBrain = CivilianBrain or class(CopBrain)
CivilianBrain.set_attention_settings = PlayerMovement.set_attention_settings
CivilianBrain._logics = {
	inactive = CivilianLogicInactive,
	idle = CivilianLogicIdle,
	surrender = CivilianLogicSurrender,
	flee = CivilianLogicFlee,
	escort = CivilianLogicEscort,
	travel = CivilianLogicTravel,
	trade = CivilianLogicTrade
}

function CivilianBrain:init(unit)
	self._unit = unit
	self._timer = TimerManager:game()

	self:set_update_enabled_state(false)

	self._current_logic = nil
	self._current_logic_name = nil
	self._active = true
	self._SO_access = managers.navigation:convert_access_flag(tweak_data.character[unit:base()._tweak_table].access)
	self._slotmask_enemies = managers.slot:get_mask("criminals")
	CopBrain._reload_clbks[unit:key()] = callback(self, self, "on_reload")
end

function CivilianBrain:update(unit, t, dt)
	local logic = self._current_logic

	if logic.update then
		local l_data = self._logic_data
		l_data.t = t
		l_data.dt = dt

		logic.update(l_data)
	end
end

function CivilianBrain:_reset_logic_data()
	CopBrain._reset_logic_data(self)

	self._logic_data.enemy_slotmask = nil
	self._logic_data.objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_civilian_objective_complete")
	self._logic_data.objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_civilian_objective_failed")
end

function CivilianBrain:is_available_for_assignment(objective)
	return self._current_logic.is_available_for_assignment(self._logic_data, objective)
end

function CivilianBrain:cancel_trade()
	if not self._active then
		return
	end

	self:set_logic("surrender")
end

function CivilianBrain:on_rescue_allowed_state(state)
	if self._current_logic.on_rescue_allowed_state then
		self._current_logic.on_rescue_allowed_state(self._logic_data, state)
	end
end

function CivilianBrain:wants_rescue()
	if self._dont_rescue then
		return false
	end

	if self._current_logic.wants_rescue then
		return self._current_logic.wants_rescue(self._logic_data)
	end
end

function CivilianBrain:on_cool_state_changed(state)
	if self._logic_data then
		self._logic_data.cool = state
	end

	if self._alert_listen_key then
		managers.groupai:state():remove_alert_listener(self._alert_listen_key)
	else
		self._alert_listen_key = "CopBrain" .. tostring(self._unit:key())
	end

	local alert_listen_filter, alert_types = nil

	if state then
		alert_listen_filter = managers.groupai:state():get_unit_type_filter("criminals_enemies_civilians")
		alert_types = {
			vo_distress = true,
			aggression = true,
			bullet = true,
			vo_intimidate = true,
			explosion = true,
			footstep = true,
			vo_cbt = true
		}
	else
		alert_listen_filter = managers.groupai:state():get_unit_type_filter("criminal")
		alert_types = {bullet = true}
	end

	managers.groupai:state():add_alert_listener(self._alert_listen_key, callback(self, self, "on_alert"), alert_listen_filter, alert_types, self._unit:movement():m_head_pos())
end

function CivilianBrain:on_hostage_move_interaction(interacting_unit, command)
	if not self._logic_data.is_tied then
		return
	end

	if command == "move" then
		local following_hostages = managers.groupai:state():get_following_hostages(interacting_unit)

		if following_hostages and tweak_data.player.max_nr_following_hostages <= table.size(following_hostages) then
			return
		end

		if not self._unit:anim_data().drop and self._unit:anim_data().tied then
			return
		end

		local stand_action_desc = {
			clamp_to_graph = true,
			variant = "stand_tied",
			body_part = 1,
			type = "act"
		}
		local action = self._unit:movement():action_request(stand_action_desc)

		if not action then
			return
		end

		self._unit:movement():set_stance("cbt", nil, true)

		local follow_objective = {
			interrupt_health = 0,
			distance = 500,
			type = "follow",
			lose_track_dis = 2000,
			stance = "cbt",
			interrupt_dis = 0,
			follow_unit = interacting_unit,
			nav_seg = interacting_unit:movement():nav_tracker():nav_segment(),
			fail_clbk = callback(self, self, "on_hostage_follow_objective_failed")
		}

		self:set_objective(follow_objective)
		self._unit:interaction():set_tweak_data("hostage_stay")
		self._unit:interaction():set_active(true, true)
		interacting_unit:sound():say("f38_any", true, false)

		self._following_hostage_contour_id = self._unit:contour():add("friendly", true)

		managers.groupai:state():on_hostage_follow(interacting_unit, self._unit, true)
	elseif command == "stay" then
		if not self._unit:anim_data().stand then
			return
		end

		self:set_objective({
			amount = 1,
			type = "surrender",
			aggressor_unit = interacting_unit
		})

		if not self._unit:anim_data().stand then
			return
		end

		local stand_action_desc = {
			clamp_to_graph = true,
			variant = "drop",
			body_part = 1,
			type = "act"
		}
		local action = self._unit:movement():action_request(stand_action_desc)

		if not action then
			return
		end

		self._unit:movement():set_stance("hos", nil, true)
		self._unit:interaction():set_tweak_data("hostage_move")
		self._unit:interaction():set_active(true, true)

		if alive(interacting_unit) then
			interacting_unit:sound():say("f02x_sin", true, false)
		end

		if self._following_hostage_contour_id then
			self._unit:contour():remove_by_id(self._following_hostage_contour_id, true)

			self._following_hostage_contour_id = nil
		end

		managers.groupai:state():on_hostage_follow(interacting_unit, self._unit, false)
	elseif command == "release" then
		self._logic_data.is_tied = nil

		if self._logic_data.objective and self._logic_data.objective.type == "follow" then
			self:set_objective(nil)
		end

		self._unit:movement():set_stance("hos", nil, true)

		local stand_action_desc = {
			variant = "panic",
			body_part = 1,
			type = "act"
		}
		local action = self._unit:movement():action_request(stand_action_desc)

		if not action then
			return
		end

		self._unit:interaction():set_tweak_data("intimidate")
		self._unit:interaction():set_active(false, true)

		if self._following_hostage_contour_id then
			self._unit:contour():remove_by_id(self._following_hostage_contour_id, true)

			self._following_hostage_contour_id = nil
		end

		managers.groupai:state():on_hostage_follow(interacting_unit, self._unit, false)
	end

	return true
end

function CivilianBrain:on_hostage_follow_objective_failed(unit)
	if not unit:character_damage():dead() then
		if not self._logic_data.objective or self._logic_data.objective.is_default or self._logic_data.objective.type == "surrender" then
			self:on_hostage_move_interaction(nil, "stay")
		else
			self:on_hostage_move_interaction(nil, "release")
		end
	end
end

function CivilianBrain:is_tied()
	return self._logic_data.is_tied
end

function CivilianBrain:save(save_data)
	CivilianBrain.super.save(self, save_data)

	local my_save_data = save_data.brain

	if self._following_hostage_contour_id then
		my_save_data.following_hostage_contour = true
	end
end

