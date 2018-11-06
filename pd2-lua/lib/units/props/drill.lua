Drill = Drill or class(UnitBase)
Drill.active_drills = Drill.active_drills or 0
Drill.jammed_drills = Drill.jammed_drills or 0
Drill.on_hit_autorepair_chance = 0.5
Drill._drill_remind_clbk_id = "_drill_remind_clbk"

function Drill.get_upgrades(drill_unit, player)
	local is_drill = drill_unit:base() and drill_unit:base().is_drill
	local is_saw = drill_unit:base() and drill_unit:base().is_saw
	local upgrades = nil

	if is_drill or is_saw then
		local player_skill = PlayerSkill
		upgrades = {
			auto_repair_level_1 = player_skill.skill_level("player", "drill_autorepair_1", 0, player),
			auto_repair_level_2 = player_skill.skill_level("player", "drill_autorepair_2", 0, player),
			speed_upgrade_level = player_skill.skill_level("player", "drill_speed_multiplier", 0, player),
			silent_drill = player_skill.has_skill("player", "silent_drill", player),
			reduced_alert = player_skill.has_skill("player", "drill_alert_rad", player)
		}
	end

	return upgrades
end

function Drill.create_upgrades(auto_repair_level_1, auto_repair_level_2, speed_upgrade_level, silent_drill, reduced_alert)
	return {
		auto_repair_level_1 = auto_repair_level_1,
		auto_repair_level_2 = auto_repair_level_2,
		speed_upgrade_level = speed_upgrade_level,
		silent_drill = silent_drill,
		reduced_alert = reduced_alert
	}
end

function Drill:init(unit)
	Drill.super.init(self, unit, false)

	self._unit = unit
	self._jammed = false
	self._jammed_count = 0
	self._powered = true
	self._use_effect = true
	self._active_effect_name = "effects/payday2/environment/drill"
	self._pos = unit:position()
	self._skill_upgrades = {}

	managers.groupai:state():on_editor_sim_unit_spawned(unit)

	self._peer_ids = {}
	self._auto_restart_chance = false
end

function Drill:start()
	self:_start_drill_effect()

	if not self.started then
		self.started = true
		Drill.active_drills = Drill.active_drills + 1

		if Network:is_server() then
			if not self._nav_tracker and managers.navigation:is_data_ready() then
				if self._sabotage_align_obj_name then
					self._nav_tracker = managers.navigation:create_nav_tracker(self._unit:get_object(Idstring(self._sabotage_align_obj_name)):position())
				else
					self._nav_tracker = managers.navigation:create_nav_tracker(self._pos)
				end
			end

			self:_register_sabotage_SO()
		end

		if not managers.groupai:state():enemy_weapons_hot() then
			self:_set_attention_state(true)
			self:_set_alert_state(true)

			if not self.is_hacking_device then
				managers.dialog:queue_narrator_dialog("drl_wrn_snd", {})
			end

			if not self._ene_weap_hot_listen_id then
				self._ene_weap_hot_listen_id = "Drill_ene_w_hot" .. tostring(self._unit:key())

				managers.groupai:state():add_listener(self._ene_weap_hot_listen_id, {
					"enemy_weapons_hot"
				}, callback(self, self, "clbk_enemy_weapons_hot"))
			end
		end
	end
end

function Drill:stop()
	self:set_jammed(false)
end

function Drill:done()
	self:set_jammed(false)
	self:_kill_drill_effect()

	if self.started then
		self.started = nil
		Drill.active_drills = Drill.active_drills - 1
	end

	if self._alert_clbk_id then
		managers.enemy:remove_delayed_clbk(self._alert_clbk_id)

		self._alert_clbk_id = nil
	end

	self:_unregister_sabotage_SO()
end

function Drill:_start_drill_effect()
	if self._drill_effect then
		return
	end

	if self._use_effect then
		local params = {
			effect = Idstring(self._active_effect_name),
			parent = self._unit:get_object(Idstring("e_drill_particles"))
		}
		self._drill_effect = World:effect_manager():spawn(params)
	end
end

function Drill:_kill_drill_effect()
	if not self._drill_effect then
		return
	end

	if self._use_effect then
		World:effect_manager():fade_kill(self._drill_effect)
	end

	self._drill_effect = nil
end

function Drill:_kill_jammed_effect()
	if not self._jammed_effect then
		return
	end

	if self._use_effect then
		World:effect_manager():fade_kill(self._jammed_effect)
	end

	self._jammed_effect = nil
end

function Drill:set_jammed(jammed)
	if jammed then
		jammed = true
	else
		jammed = false
	end

	if self._jammed == jammed then
		return
	end

	self._jammed = jammed

	if self._jammed then
		self._jammed_count = self._jammed_count + 1

		self:_kill_drill_effect()

		if self._use_effect then
			local params = {
				effect = Idstring("effects/payday2/environment/drill_jammed"),
				parent = self._unit:get_object(Idstring("e_drill_particles"))
			}
			self._jammed_effect = World:effect_manager():spawn(params)
		end

		self:_reset_melee_autorepair()

		if self._autorepair and not self._autorepair_clbk_id then
			self._autorepair_clbk_id = "Drill_autorepair" .. tostring(self._unit:key())

			managers.enemy:add_delayed_clbk(self._autorepair_clbk_id, callback(self, self, "clbk_autorepair"), TimerManager:game():time() + 5 + 15 * math.random())
		end
	elseif self._jammed_effect then
		self:_kill_jammed_effect()
		self:_start_drill_effect()

		if not self.is_hacking_device and not self.is_saw and not managers.groupai:state():whisper_mode() then
			managers.groupai:state():teammate_comment(nil, "g22", self._unit:position(), true, 500, false)
		end

		if self._autorepair_clbk_id then
			managers.enemy:remove_delayed_clbk(self._autorepair_clbk_id)

			self._autorepair_clbk_id = nil
		end

		if self._bain_report_sabotage_clbk_id then
			managers.enemy:remove_delayed_clbk(self._bain_report_sabotage_clbk_id)

			self._bain_report_sabotage_clbk_id = nil
		end
	end

	self:_change_num_jammed_drills(self._jammed and 1 or -1)

	if Network:is_server() then
		if jammed then
			self:_unregister_sabotage_SO()
		else
			self:_register_sabotage_SO()
		end
	end
end

function Drill:_change_num_jammed_drills(d)
	Drill.jammed_drills = Drill.jammed_drills + d

	if Drill.jammed_drills > 0 and not Drill._drll_remind_clbk then
		Drill._drll_remind_clbk = callback(self, self, "_drill_remind_clbk")

		managers.enemy:add_delayed_clbk(Drill._drill_remind_clbk_id, Drill._drll_remind_clbk, Application:time() + 20)
	end

	if Drill.jammed_drills <= 0 and Drill._drll_remind_clbk then
		managers.enemy:remove_delayed_clbk(Drill._drill_remind_clbk_id)

		Drill._drll_remind_clbk = nil
	end
end

Drill.REMINDER_COMMENTS = {
	default = {},
	drill = {
		"d01x_sin",
		"d02x_sin"
	},
	hacking_device = {},
	saw = {
		"d05",
		"d05"
	}
}

function Drill:_drill_remind_clbk()
	if not managers.groupai:state():whisper_mode() then
		local device = self.is_drill and "drill" or self.is_saw and "saw" or self.is_hacking_device and "hacking_device" or "default"
		local reminder = Drill.REMINDER_COMMENTS[device] or Drill.REMINDER_COMMENTS.default[self._jammed_count <= 1 and 1 or 2]

		if reminder then
			managers.groupai:state():teammate_comment(nil, reminder, nil, false, nil, false)
		end
	end

	managers.enemy:add_delayed_clbk(Drill._drill_remind_clbk_id, Drill._drll_remind_clbk, Application:time() + 45)
end

function Drill:save(data)
	local state = {
		skill_upgrades = self._skill_upgrades
	}
	data.Drill = state
end

function Drill:load(data)
	local state = data.Drill

	self:set_skill_upgrades(state.skill_upgrades)
end

function Drill:set_powered(powered)
	if (self._powered or false) == (powered or false) then
		return
	end

	self._powered = powered

	if not self._powered then
		self:_kill_drill_effect()
	else
		self:_start_drill_effect()

		if not self.is_hacking_device and not self.is_saw and not managers.groupai:state():whisper_mode() then
			managers.groupai:state():teammate_comment(nil, "g22", self._unit:position(), true, 500, false)
		end
	end

	if Network:is_server() then
		if not powered then
			self:_unregister_sabotage_SO()
		else
			self:_register_sabotage_SO()
		end
	end
end

function Drill:_register_sabotage_SO()
	if self._sabotage_SO_id or not managers.navigation:is_data_ready() or not self._unit:timer_gui() or not self._unit:timer_gui()._can_jam or not self._sabotage_align_obj_name then
		return
	end

	local field_pos = self._nav_tracker:field_position()
	local field_z = self._nav_tracker:field_z() - 25
	local height = self._pos.z - field_z
	local act_anim = "sabotage_device_" .. (height > 100 and "high" or height > 60 and "mid" or "low")
	local align_obj = self._unit:get_object(Idstring(self._sabotage_align_obj_name))
	local objective_rot = align_obj:rotation()
	local objective_pos = align_obj:position()
	self._SO_area = managers.groupai:state():get_area_from_nav_seg_id(self._nav_tracker:nav_segment())
	local followup_objective = {
		attitude = "avoid",
		scan = true,
		stance = "hos",
		type = "defend_area",
		interrupt_health = 1,
		interrupt_dis = 500,
		nav_seg = self._nav_tracker:nav_segment(),
		area = self._SO_area
	}
	local objective = {
		type = "act",
		interrupt_health = 1,
		stance = "hos",
		haste = "run",
		scan = true,
		interrupt_dis = 800,
		nav_seg = self._nav_tracker:nav_segment(),
		area = self._SO_area,
		pos = objective_pos,
		rot = objective_rot,
		fail_clbk = callback(self, self, "on_sabotage_SO_failed"),
		complete_clbk = callback(self, self, "on_sabotage_SO_completed"),
		action_start_clbk = callback(self, self, "on_sabotage_SO_started"),
		followup_objective = followup_objective,
		action = {
			align_sync = true,
			type = "act",
			body_part = 1,
			variant = act_anim,
			blocks = {
				light_hurt = -1,
				action = -1,
				aim = -1
			}
		}
	}
	local so_descriptor = {
		interval = 0,
		search_dis_sq = 1000000,
		AI_group = "enemies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = field_pos,
		verification_clbk = callback(self, self, "clbk_sabotage_SO_verification"),
		access = managers.navigation:convert_access_filter_to_number({
			"gangster",
			"security",
			"security_patrol",
			"cop",
			"fbi",
			"swat",
			"murky",
			"sniper",
			"spooc",
			"tank",
			"taser"
		}),
		admin_clbk = callback(self, self, "on_sabotage_SO_administered")
	}
	self._sabotage_SO_id = "drill_sabotage" .. tostring(self._unit:key())

	managers.groupai:state():add_special_objective(self._sabotage_SO_id, so_descriptor)
end

function Drill:_unregister_sabotage_SO()
	if self._sabotage_SO_id then
		managers.groupai:state():remove_special_objective(self._sabotage_SO_id)

		self._sabotage_SO_id = nil
	elseif self._saboteur then
		local saboteur = self._saboteur
		self._saboteur = nil

		if alive(saboteur) then
			saboteur:brain():set_objective(nil)
		end
	end
end

function Drill:on_sabotage_SO_administered(receiver_unit)
	if self._saboteur then
		debug_pause("[Drill:on_sabotage_SO_administered] Already had a saboteur", receiver_unit, self._saboteur)
	end

	self._saboteur = receiver_unit
	self._sabotage_SO_id = nil
end

function Drill:on_sabotage_SO_failed(saboteur)
	if self._saboteur then
		self._saboteur = nil

		self:_register_sabotage_SO()
	end
end

function Drill:on_sabotage_SO_completed(saboteur)
	self._saboteur = nil
end

function Drill:on_sabotage_SO_started(saboteur)
	if not self._saboteur or self._saboteur:key() ~= saboteur:key() then
		debug_pause_unit(self._unit, "[Drill:on_sabotage_SO_started] wrong saboteur", self._unit, saboteur, self._saboteur)
	end

	self._saboteur = nil

	self._unit:timer_gui():set_jammed(true)

	if not self._bain_report_sabotage_clbk_id then
		self._bain_report_sabotage_clbk_id = "Drill_bain_report_sabotage" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._bain_report_sabotage_clbk_id, callback(self, self, "clbk_bain_report_sabotage"), TimerManager:game():time() + 2 + 4 * math.random())
	end
end

function Drill:clbk_sabotage_SO_verification(candidate_unit)
	if not self._sabotage_SO_id then
		debug_pause_unit(self._unit, "[Drill:clbk_sabotage_SO_verification] SO is not registered", self._unit, candidate_unit)

		return
	end

	local nav_seg = candidate_unit:movement():nav_tracker():nav_segment()

	if self._SO_area.nav_segs[nav_seg] and not candidate_unit:movement():cool() then
		return true
	end
end

function Drill:_set_attention_state(state)
	if self.ignore_detection then
		if self._attention_handler then
			self._attention_handler:set_attention(nil)

			self._attention_handler = nil
		end

		return
	end

	if state then
		if not self._attention_setting then
			self._attention_handler = AIAttentionObject:new(self._unit, true)

			if self._attention_obj_name then
				self._attention_handler:set_detection_object_name(self._attention_obj_name)
			end

			local descriptor = self._alert_radius and "drill_civ_ene_ntl" or "drill_silent_civ_ene_ntl"
			local attention_setting = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data.attention.settings[descriptor], descriptor)

			self._attention_handler:set_attention(attention_setting)
		end
	elseif self._attention_handler then
		self._attention_handler:set_attention(nil)

		self._attention_handler = nil
	end
end

function Drill:update_attention_settings(descriptor)
	local tweak_data = tweak_data.attention.settings[descriptor]

	if tweak_data and self._attention_handler then
		local attention_setting = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data, descriptor)

		self._attention_handler:set_attention(attention_setting)
	end
end

function Drill:clbk_enemy_weapons_hot()
	managers.groupai:state():remove_listener(self._ene_weap_hot_listen_id)

	self._ene_weap_hot_listen_id = nil

	self:_set_attention_state(false)
	self:_set_alert_state(false)
end

function Drill:set_skill_upgrades(upgrades)
	if self._disable_upgrades then
		return
	end

	local background_icons = {}
	local timer_gui_ext = self._unit:timer_gui()
	local background_icon_template = {
		texture = "guis/textures/pd2/skilltree/",
		alpha = 1,
		h = 128,
		y = 100,
		w = 128,
		x = 30,
		layer = 2
	}
	local background_icon_x = 30

	local function add_bg_icon_func(bg_icon_table, texture_name, color)
		local icon_data = deep_clone(background_icon_template)
		icon_data.texture = icon_data.texture .. texture_name
		icon_data.color = color
		icon_data.x = background_icon_x

		table.insert(bg_icon_table, icon_data)

		background_icon_x = background_icon_x + icon_data.w + 2
	end

	if self.is_drill or self.is_saw then
		local drill_speed_multiplier = tweak_data.upgrades.values.player.drill_speed_multiplier
		local drill_alert_rad = tweak_data.upgrades.values.player.drill_alert_rad[1]
		local current_speed_upgrade = self._skill_upgrades.speed_upgrade_level or 0
		local timer_multiplier = 1

		if upgrades.speed_upgrade_level and upgrades.speed_upgrade_level >= 2 or current_speed_upgrade >= 2 then
			timer_multiplier = drill_speed_multiplier[2]

			add_bg_icon_func(background_icons, "drillgui_icon_faster", timer_gui_ext:get_upgrade_icon_color("upgrade_color_2"))

			upgrades.speed_upgrade_level = 2
		elseif upgrades.speed_upgrade_level and upgrades.speed_upgrade_level >= 1 or current_speed_upgrade >= 1 then
			timer_multiplier = drill_speed_multiplier[1]

			add_bg_icon_func(background_icons, "drillgui_icon_faster", timer_gui_ext:get_upgrade_icon_color("upgrade_color_1"))

			upgrades.speed_upgrade_level = 1
		else
			add_bg_icon_func(background_icons, "drillgui_icon_faster", timer_gui_ext:get_upgrade_icon_color("upgrade_color_0"))

			upgrades.speed_upgrade_level = 0
		end

		local got_reduced_alert = upgrades.reduced_alert or false
		local current_reduced_alert = self._skill_upgrades.reduced_alert or false
		local got_silent_drill = upgrades.silent_drill or false
		local current_silent_drill = self._skill_upgrades.silent_drill or false
		local auto_repair_level_1 = upgrades.auto_repair_level_1 or 0
		local auto_repair_level_2 = upgrades.auto_repair_level_2 or 0
		local current_auto_repair_level_1 = self._skill_upgrades.auto_repair_level_1 or 0
		local current_auto_repair_level_2 = self._skill_upgrades.auto_repair_level_2 or 0

		timer_gui_ext:set_timer_multiplier(timer_multiplier)

		if got_silent_drill or current_silent_drill then
			self:set_alert_radius(nil)
			timer_gui_ext:set_skill(BaseInteractionExt.SKILL_IDS.aced)

			upgrades.silent_drill = true
			upgrades.reduced_alert = true

			add_bg_icon_func(background_icons, "drillgui_icon_silent", timer_gui_ext:get_upgrade_icon_color("upgrade_color_2"))
		elseif got_reduced_alert or current_reduced_alert then
			self:set_alert_radius(drill_alert_rad)
			timer_gui_ext:set_skill(BaseInteractionExt.SKILL_IDS.basic)

			upgrades.reduced_alert = true

			add_bg_icon_func(background_icons, "drillgui_icon_silent", timer_gui_ext:get_upgrade_icon_color("upgrade_color_1"))
		else
			self:set_alert_radius(tweak_data.upgrades.drill_alert_radius or 2500)
			timer_gui_ext:set_skill(BaseInteractionExt.SKILL_IDS.none)
			add_bg_icon_func(background_icons, "drillgui_icon_silent", timer_gui_ext:get_upgrade_icon_color("upgrade_color_0"))
		end

		if auto_repair_level_1 > 0 or current_auto_repair_level_1 > 0 or auto_repair_level_2 > 0 or current_auto_repair_level_2 > 0 then
			upgrades.auto_repair_level_1 = current_auto_repair_level_1
			upgrades.auto_repair_level_2 = current_auto_repair_level_2
			local drill_autorepair_chance = 0

			if current_auto_repair_level_1 < auto_repair_level_1 then
				current_auto_repair_level_1 = auto_repair_level_1
				upgrades.auto_repair_level_1 = auto_repair_level_1
			end

			if current_auto_repair_level_2 < auto_repair_level_2 then
				current_auto_repair_level_2 = auto_repair_level_2
				upgrades.auto_repair_level_2 = auto_repair_level_2
			end

			if current_auto_repair_level_1 > 0 then
				drill_autorepair_chance = drill_autorepair_chance + tweak_data.upgrades.values.player.drill_autorepair_2[1]
			end

			if current_auto_repair_level_2 > 0 then
				drill_autorepair_chance = drill_autorepair_chance + tweak_data.upgrades.values.player.drill_autorepair_1[1]
			end

			if Network:is_server() and math.random() < drill_autorepair_chance then
				self:set_autorepair(true)
			end

			add_bg_icon_func(background_icons, "drillgui_icon_restarter", timer_gui_ext:get_upgrade_icon_color("upgrade_color_1"))
		else
			add_bg_icon_func(background_icons, "drillgui_icon_restarter", timer_gui_ext:get_upgrade_icon_color("upgrade_color_0"))
		end

		self._skill_upgrades = deep_clone(upgrades)
	end

	timer_gui_ext:set_background_icons(background_icons)
	timer_gui_ext:update_sound_event()
end

function Drill:get_skill_upgrades()
	return self._skill_upgrades or {}
end

function Drill:set_autorepair(state)
	if self._skill_upgrades.auto_repair_level_1 and self._skill_upgrades.auto_repair_level_1 > 0 or self._skill_upgrades.auto_repair_level_2 and self._skill_upgrades.auto_repair_level_2 > 0 then
		return
	end

	self._autorepair = state

	if state then
		if self._jammed and not self._autorepair_clbk_id then
			self._autorepair_clbk_id = "Drill_autorepair" .. tostring(self._unit:key())

			managers.enemy:add_delayed_clbk(self._autorepair_clbk_id, callback(self, self, "clbk_autorepair"), TimerManager:game():time() + 5 + 15 * math.random())
		end
	elseif self._autorepair_clbk_id then
		managers.enemy:remove_delayed_clbk(self._autorepair_clbk_id)

		self._autorepair_clbk_id = nil
	end
end

function Drill:clbk_autorepair()
	self._autorepair_clbk_id = nil

	if alive(self._unit) then
		self._unit:timer_gui():set_jammed(false)
		self._unit:interaction():set_active(false, true)
	end
end

function Drill:_set_alert_state(state)
	if self.ignore_detection then
		state = false
	end

	self._alert_state = state

	if state and self._alert_radius then
		self:_register_investigate_SO()
	else
		self:_unregister_investigate_SO()
	end
end

function Drill:set_alert_radius(radius)
	if radius then
		self._alert_radius = radius

		if self._alert_state then
			self:_register_investigate_SO()
		end
	else
		self._alert_radius = nil

		self:_unregister_investigate_SO()
		self:update_attention_settings("drill_silent_civ_ene_ntl")
	end
end

function Drill:_register_investigate_SO()
	if self._investigate_SO_data then
		return
	end

	if not Network:is_server() or not managers.navigation:is_data_ready() then
		return
	end

	local SO_category = "enemies"
	local SO_filter = managers.navigation:convert_SO_AI_group_to_access(SO_category)
	local investigate_pos = Vector3()
	local my_rot = self._unit:rotation()

	mrotation.y(my_rot, investigate_pos)
	mvector3.multiply(investigate_pos, -200)
	mvector3.add(investigate_pos, self._unit:position())
	mvector3.set_z(investigate_pos, mvector3.z(self._nav_tracker:field_position()))

	local investigate_pos_tracker = managers.navigation:create_nav_tracker(investigate_pos, true)
	investigate_pos = investigate_pos_tracker:field_position()

	managers.navigation:destroy_nav_tracker(investigate_pos_tracker)

	local investigate_fwd = Vector3()

	mvector3.direction(investigate_fwd, investigate_pos, self._nav_tracker:field_position())

	local investigate_rot = Rotation(investigate_fwd, math.UP)
	local investigate_nav_seg = self._nav_tracker:nav_segment()
	local investigate_area = managers.groupai:state():get_area_from_nav_seg_id(investigate_nav_seg)
	local investigate_objective = {
		pose = "stand",
		type = "free",
		interrupt_health = 1,
		stance = "ntl",
		haste = "walk",
		interrupt_dis = -1,
		nav_seg = investigate_nav_seg,
		area = investigate_area,
		pos = investigate_pos,
		rot = investigate_rot,
		fail_clbk = callback(self, self, "on_investigate_SO_failed"),
		complete_clbk = callback(self, self, "on_investigate_SO_completed"),
		action_duration = math.lerp(3, 8, math.random())
	}
	local so_descriptor = {
		interval = 0,
		base_chance = 1,
		AI_group = "enemies",
		chance_inc = 0,
		usage_amount = 1,
		objective = investigate_objective,
		search_pos = self._nav_tracker:field_position(),
		verification_clbk = callback(self, self, "clbk_investigate_SO_verification"),
		admin_clbk = callback(self, self, "on_investigate_SO_administered")
	}
	local so_id = "Drill_investigate" .. tostring(self._unit:key())
	self._investigate_SO_data = {
		SO_registered = true,
		SO_id = so_id
	}

	managers.groupai:state():add_special_objective(so_id, so_descriptor)
end

function Drill:_unregister_investigate_SO()
	if not self._investigate_SO_data then
		return
	end

	if self._investigate_SO_data.SO_registered then
		managers.groupai:state():remove_special_objective(self._investigate_SO_data.SO_id)
	elseif self._investigate_SO_data.receiver_unit then
		local receiver_unit = self._investigate_SO_data.receiver_unit
		self._investigate_SO_data.receiver_unit = nil

		if alive(receiver_unit) then
			receiver_unit:brain():set_objective(nil)
		end
	end

	self._investigate_SO_data = nil
end

function Drill:clbk_investigate_SO_verification(candidate_unit)
	if not self._investigate_SO_data or not self._investigate_SO_data.SO_id then
		debug_pause_unit(self._unit, "[Drill:clbk_investigate_SO_verification] SO is not registered", self._unit, candidate_unit, inspect(self._investigate_SO_data))

		return
	end

	if not candidate_unit:movement():cool() then
		return
	end

	local candidate_listen_pos = candidate_unit:movement():m_head_pos()
	local sound_source_pos = self._unit:position()
	local ray = self._unit:raycast("ray", candidate_listen_pos, sound_source_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")

	if ray then
		local my_dis = mvector3.distance(candidate_listen_pos, sound_source_pos)

		if my_dis > (self._alert_radius or 900) * 0.5 then
			return
		end
	end

	return true
end

function Drill:on_investigate_SO_administered(receiver_unit)
	if self._investigate_SO_data.receiver_unit then
		debug_pause("[Drill:on_investigate_SO_administered] Already had a receiver_unit!!!!", thief, self._investigate_SO_data.receiver_unit)
	end

	self._investigate_SO_data.receiver_unit = receiver_unit
	self._investigate_SO_data.SO_registered = false
end

function Drill:on_investigate_SO_completed(receiver_unit)
	if receiver_unit ~= self._investigate_SO_data.receiver_unit then
		debug_pause_unit(receiver_unit, "[Drill:on_investigate_SO_completed] idiot thinks he is investigating", receiver_unit)

		return
	end

	self:_register_investigate_SO()
end

function Drill:on_investigate_SO_failed(receiver_unit)
	if not self._investigate_SO_data.receiver_unit then
		return
	end

	if receiver_unit ~= self._investigate_SO_data.receiver_unit then
		debug_pause_unit(receiver_unit, "[CarryData:on_pickup_SO_failed] idiot thinks he is investigating", receiver_unit)

		return
	end

	self._investigate_SO_data = nil

	self:_register_investigate_SO()
end

function Drill:attention_handler()
	return self._attention_handler
end

function Drill:clbk_bain_report_sabotage()
	self._bain_report_sabotage_clbk_id = nil

	if self._jammed then
		managers.dialog:queue_narrator_dialog("csod_01", {})
	end
end

function Drill:set_attention_state(state)
	self:_set_attention_state(state)
end

function Drill:destroy()
	if self._alert_clbk_id then
		managers.enemy:remove_delayed_clbk(self._alert_clbk_id)

		self._alert_clbk_id = nil
	end

	if self._ene_weap_hot_listen_id then
		managers.groupai:state():remove_listener(self._ene_weap_hot_listen_id)

		self._ene_weap_hot_listen_id = nil
	end

	self:_set_attention_state(false)

	if self._autorepair_clbk_id then
		managers.enemy:remove_delayed_clbk(self._autorepair_clbk_id)

		self._autorepair_clbk_id = nil
	end

	if self._bain_report_sabotage_clbk_id then
		managers.enemy:remove_delayed_clbk(self._bain_report_sabotage_clbk_id)

		self._bain_report_sabotage_clbk_id = nil
	end

	self:_unregister_sabotage_SO()
	self:_unregister_investigate_SO()
	self:_kill_jammed_effect()
	self:_kill_drill_effect()
	self:set_jammed(false)
end

function Drill:_reset_melee_autorepair()
	self._peer_ids = {}
end

function Drill:on_melee_hit(peer_id)
	if self._disable_upgrades then
		return
	end

	if not self:_does_peer_exist(peer_id) and self._jammed then
		table.insert(self._peer_ids, peer_id)

		local rand = math.random()

		if rand < Drill.on_hit_autorepair_chance then
			self._unit:timer_gui():set_jammed(false)
			self._unit:interaction():set_active(false, true)
			self._unit:interaction():check_for_upgrade()

			if self._kickstarter_success_sequence then
				self._unit:damage():run_sequence_simple(self._kickstarter_success_sequence)
			end
		end
	end
end

function Drill:_does_peer_exist(peer_id)
	local count = #self._peer_ids

	for i = 1, count, 1 do
		if self._peer_ids[i] == peer_id then
			return true
		end
	end

	return false
end

function Drill:compare_skill_upgrades(skill_upgrades)
	if self._disable_upgrades then
		return false
	end

	return self._skill_upgrades.auto_repair_level_1 < skill_upgrades.auto_repair_level_1 or self._skill_upgrades.auto_repair_level_2 < skill_upgrades.auto_repair_level_2 or self._skill_upgrades.speed_upgrade_level < skill_upgrades.speed_upgrade_level or skill_upgrades.silent_drill and not self._skill_upgrades.silent_drill or skill_upgrades.reduced_alert and not self._skill_upgrades.reduced_alert
end
