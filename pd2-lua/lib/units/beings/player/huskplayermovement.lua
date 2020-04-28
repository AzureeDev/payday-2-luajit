require("lib/utils/ArmAnimator")

local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_div = mvector3.divide
local mvec3_norm = mvector3.normalize
local mvec3_len = mvector3.length
local mvec3_dot = mvector3.dot
local mvec3_set_z = mvector3.set_z
local mvec3_z = mvector3.z
local mvec3_set_len = mvector3.set_length
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local tmp_rot1 = Rotation()
local tmp_rot2 = Rotation()
local tmp_rot3 = Rotation()
local cbt_stance_code = 3
local sync_action_force = {
	force = true
}
local sync_action_force_and_execute = {
	force = true,
	execute = true
}
HuskPlayerMovement = HuskPlayerMovement or class()
HuskPlayerMovement._ids_base = Idstring("base")
HuskPlayerMovement._calc_suspicion_ratio_and_sync = PlayerMovement._calc_suspicion_ratio_and_sync
HuskPlayerMovement.on_suspicion = PlayerMovement.on_suspicion
HuskPlayerMovement.state_enter_time = PlayerMovement.state_enter_time
HuskPlayerMovement.SO_access = PlayerMovement.SO_access
HuskPlayerMovement.rescue_SO_verification = PlayerBleedOut.rescue_SO_verification
HuskPlayerMovement.set_team = PlayerMovement.set_team
HuskPlayerMovement.team = PlayerMovement.team
HuskPlayerMovement.sync_net_event = PlayerMovement.sync_net_event
HuskPlayerMovement.set_friendly_fire = PlayerMovement.set_friendly_fire
HuskPlayerMovement.friendly_fire = PlayerMovement.friendly_fire
HuskPlayerMovement.action_prerequisites = {
	land = {
		target_action = "land",
		current_type = {
			"ground"
		},
		last_type = {
			"air"
		}
	},
	fall = {
		target_action = "fall",
		current_type = {
			"air"
		},
		last_type = {
			"ground"
		},
		not_last_type = {
			"air"
		},
		not_last_action = {
			"jump"
		}
	},
	zipline_start = {
		target_action = "zipline_start",
		current_type = {
			"zipline"
		},
		last_type = {
			"ground",
			"air"
		}
	},
	zipline_end = {
		target_action = "zipline_end",
		current_type = {
			"ground",
			"air"
		},
		last_type = {
			"zipline"
		}
	}
}
HuskPlayerMovement._walk_anim_velocities = {
	stand = {
		ntl = {
			walk = {
				bwd = 156.4,
				l = 150.36,
				fwd = 183.48,
				r = 152.15
			},
			run = {
				bwd = 402.62,
				l = 405.06,
				fwd = 381.35,
				r = 405.06
			}
		},
		cbt = {
			walk = {
				bwd = 208.27,
				l = 192.75,
				fwd = 208.27,
				r = 192.75
			},
			run = {
				bwd = 416.77,
				l = 416.35,
				fwd = 414.73,
				r = 411.9
			},
			sprint = {
				79,
				35,
				14,
				9,
				fwd = 672,
				l = 488,
				bwd = 547,
				r = 547
			}
		}
	},
	crouch = {
		cbt = {
			walk = {
				bwd = 163.74,
				l = 152.14,
				fwd = 174.45,
				r = 162.85
			},
			run = {
				bwd = 268.68,
				l = 282.93,
				fwd = 312.25,
				r = 282.93
			}
		}
	}
}
HuskPlayerMovement._walk_anim_velocities.stand.hos = HuskPlayerMovement._walk_anim_velocities.stand.cbt
HuskPlayerMovement._walk_anim_velocities.crouch.hos = HuskPlayerMovement._walk_anim_velocities.crouch.cbt
HuskPlayerMovement._walk_anim_lengths = {
	stand = {
		ntl = {
			walk = {
				bwd = 31,
				l = 29,
				fwd = 31,
				r = 31
			},
			run = {
				bwd = 17,
				l = 20,
				fwd = 26,
				r = 20
			}
		},
		cbt = {
			walk = {
				bwd = 26,
				l = 26,
				fwd = 26,
				r = 26
			},
			run = {
				bwd = 18,
				l = 18,
				fwd = 19,
				r = 20
			},
			sprint = {
				bwd = 16,
				l = 16,
				fwd = 16,
				r = 19
			},
			run_start = {
				bwd = 25,
				l = 27,
				fwd = 29,
				r = 24
			},
			run_start_turn = {
				bwd = 26,
				l = 37,
				r = 26
			},
			run_stop = {
				bwd = 23,
				l = 28,
				fwd = 29,
				r = 31
			}
		}
	},
	crouch = {
		cbt = {
			walk = {
				bwd = 31,
				l = 27,
				fwd = 31,
				r = 28
			},
			run = {
				bwd = 20,
				l = 19,
				fwd = 21,
				r = 19
			},
			run_start = {
				bwd = 16,
				l = 30,
				fwd = 31,
				r = 22
			},
			run_start_turn = {
				bwd = 28,
				l = 21,
				r = 21
			},
			run_stop = {
				bwd = 25,
				l = 28,
				fwd = 27,
				r = 26
			}
		}
	},
	wounded = {
		cbt = {
			walk = {
				bwd = 29,
				l = 29,
				fwd = 28,
				r = 29
			},
			run = {
				bwd = 18,
				l = 19,
				fwd = 19,
				r = 19
			}
		}
	},
	panic = {
		ntl = {
			run = {
				bwd = 15,
				l = 15,
				fwd = 15,
				r = 16
			}
		}
	}
}

for pose, stances in pairs(HuskPlayerMovement._walk_anim_lengths) do
	for stance, speeds in pairs(stances) do
		for speed, sides in pairs(speeds) do
			for side, speed in pairs(sides) do
				sides[side] = speed * 0.03333
			end
		end
	end
end

HuskPlayerMovement._walk_anim_lengths.stand.hos = HuskPlayerMovement._walk_anim_lengths.stand.cbt
HuskPlayerMovement._walk_anim_lengths.crouch.hos = HuskPlayerMovement._walk_anim_lengths.crouch.cbt
HuskPlayerMovement._matching_walk_anims = {
	fwd = {
		bwd = true
	},
	bwd = {
		fwd = true
	},
	l = {
		r = true
	},
	r = {
		l = true
	}
}
HuskPlayerMovement._stance_names = {
	"ntl",
	"hos",
	"cbt",
	"wnd"
}
HuskPlayerMovement._look_modifier_name = Idstring("action_upper_body")
HuskPlayerMovement._head_modifier_name = Idstring("look_head")
HuskPlayerMovement._arm_modifier_name = Idstring("aim_r_arm")
HuskPlayerMovement._mask_off_modifier_name = Idstring("look_mask_off")
HuskPlayerMovement.clean_states = {
	civilian = true,
	clean = true,
	mask_off = true
}

function HuskPlayerMovement:init(unit)
	self._unit = unit
	self._machine = unit:anim_state_machine()
	self._crouch_detection_offset_z = mvec3_z(tweak_data.player.stances.default.crouched.head.translation)
	self._m_pos = unit:position()
	self._m_rot = unit:rotation()
	self._auto_firing = 0
	self._firing = 0
	self._look_dir = self._m_rot:y()
	self._sync_look_dir = nil
	self._look_ang_vel = 0
	self._move_data = nil
	self._last_vel_z = 0
	self._sync_pos = nil
	self._sync_fall_dt = 0
	self._nav_tracker = nil
	self._look_modifier = self._machine:get_modifier(self._look_modifier_name)
	self._head_modifier = self._machine:get_modifier(self._head_modifier_name)
	self._arm_modifier = self._machine:get_modifier(self._arm_modifier_name)
	self._mask_off_modifier = self._machine:get_modifier(self._mask_off_modifier_name)
	self._aim_up_expire_t = nil
	self._is_weapon_gadget_on = nil
	local stance = {}
	self._stance = stance
	self._vehicle_shooting_stance = PlayerDriving.STANCE_NORMAL
	stance.names = self._stance_names
	stance.values = {
		1,
		0,
		0
	}
	stance.blend = {
		0.8,
		0.5,
		0.3
	}
	stance.code = 1
	stance.name = "ntl"
	stance.owner_stance_code = 1
	self._m_stand_pos = mvector3.copy(self._m_pos)

	mvector3.set_z(self._m_stand_pos, self._m_pos.z + 140)

	self._m_com = math.lerp(self._m_pos, self._m_stand_pos, 0.5)
	self._obj_head = unit:get_object(Idstring("Head"))
	self._obj_spine = unit:get_object(Idstring("Spine1"))
	self._m_head_rot = Rotation(self._look_dir, math.UP)
	self._m_head_pos = self._obj_head:position()
	self._m_detect_pos = mvector3.copy(self._m_head_pos)
	self._m_newest_pos = mvector3.copy(self._m_pos)
	self._footstep_style = nil
	self._footstep_event = ""
	self._state = "mask_off"
	self._state_enter_t = TimerManager:game():time()
	self._pose_code = 1
	self._tase_effect_table = {
		effect = Idstring("effects/payday2/particles/character/taser_hittarget"),
		parent = self._unit:get_object(Idstring("e_taser"))
	}
	self._sequenced_events = {}
	self._synced_suspicion = false
	self._suspicion_ratio = false
	self._SO_access = managers.navigation:convert_access_flag("teamAI1")
	self._slotmask_gnd_ray = managers.slot:get_mask("player_ground_check")

	self:set_friendly_fire(true)

	self._arm_animation_enabled = managers.user:get_setting("arm_animation")
	self._arm_animator = ArmAnimator:new(self._machine, callback(self, self, "clbk_arm_animator"))
	self._primary_hand = 0
	self._desired_primary_hand = 0
	self._weapon_align_points = {
		unit:get_object(Idstring("a_weapon_right_front")),
		unit:get_object(Idstring("a_weapon_left_front"))
	}
end

function HuskPlayerMovement:post_init()
	self._ext_anim = self._unit:anim_data()

	self._unit:inventory():add_listener("HuskPlayerMovement", {
		"equip"
	}, callback(self, self, "clbk_inventory_event"))

	if managers.navigation:is_data_ready() then
		self._nav_tracker = managers.navigation:create_nav_tracker(self._unit:position())
		self._standing_nav_seg_id = self._nav_tracker:nav_segment()
		self._pos_rsrv_id = managers.navigation:get_pos_reservation_id()
	end

	if not self._unit:inventory()._equipped_selection then
		self._unit:inventory():synch_equipped_weapon(2)
	end

	self._attention_handler = CharacterAttentionObject:new(self._unit)

	self._attention_handler:setup_attention_positions(self._m_detect_pos, nil)

	self._enemy_weapons_hot_listen_id = "PlayerMovement" .. tostring(self._unit:key())

	managers.groupai:state():add_listener(self._enemy_weapons_hot_listen_id, {
		"enemy_weapons_hot"
	}, callback(self, PlayerMovement, "clbk_enemy_weapons_hot"))
	self._unit:network():send("set_arm_setting", ArmSetting.SET_ARM_ANIMATOR_PRESENT, self._arm_animation_enabled and 1 or 0)
end

function HuskPlayerMovement:set_character_anim_variables()
	local char_name = managers.criminals:character_name_by_unit(self._unit)

	if not char_name then
		return
	end

	local char_index = 1

	self._machine:set_global("husk" .. tostring(char_index), 1)
	self:check_visual_equipment()

	local color_id = managers.criminals:character_color_id_by_unit(self._unit)

	self._unit:contour():update_materials()
	self._unit:contour():add("teammate", nil, nil, color_id and tweak_data.peer_vector_colors[color_id])
end

function HuskPlayerMovement:check_visual_equipment()
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local deploy_data = managers.player:get_synced_deployable_equipment(peer_id)

	if deploy_data then
		self:set_visual_deployable_equipment(deploy_data.deployable, deploy_data.amount)
	end

	local carry_data = managers.player:get_synced_carry(peer_id)

	if carry_data then
		self:set_visual_carry(carry_data.carry_id)
	end
end

function HuskPlayerMovement:set_visual_deployable_equipment(deployable, amount)
	local visible = amount > 0
	local tweak_data = tweak_data.equipments[deployable]
	local object_name = tweak_data.visual_object
	local object_name_ids = Idstring(object_name)
	self._current_visual_deployable_equipment = self._current_visual_deployable_equipment or object_name_ids

	if self._current_visual_deployable_equipment ~= object_name_ids then
		self._unit:get_object(self._current_visual_deployable_equipment):set_visibility(false)

		self._current_visual_deployable_equipment = object_name_ids
	end

	self._unit:get_object(object_name_ids):set_visibility(visible)
end

function HuskPlayerMovement:carry_id()
	return self._carry_id
end

function HuskPlayerMovement:set_visual_carry(carry_id)
	self._carry_id = carry_id

	if carry_id then
		if tweak_data.carry[carry_id].visual_unit_name then
			self:_create_carry_unit(tweak_data.carry[carry_id].visual_unit_name)

			return
		end

		local object_name = tweak_data.carry[carry_id].visual_object or "g_lootbag"
		self._current_visual_carry_object = self._unit:get_object(Idstring(object_name))

		self._current_visual_carry_object:set_visibility(true)
	elseif alive(self._current_visual_carry_object) then
		self._current_visual_carry_object:set_visibility(false)

		self._current_visual_carry_object = nil
	else
		self:_destroy_current_carry_unit()
	end
end

function HuskPlayerMovement:_destroy_current_carry_unit()
	if alive(self._current_carry_unit) then
		self._current_carry_unit:set_slot(0)

		self._current_carry_unit = nil
	end
end

function HuskPlayerMovement:_create_carry_unit(unit_name)
	self:_destroy_current_carry_unit()

	self._current_carry_unit = safe_spawn_unit(Idstring(unit_name), self._unit:position())
	local objects = {
		"Spine",
		"Spine1",
		"Spine2",
		"LeftShoulder",
		"RightShoulder",
		"LeftUpLeg",
		"RightUpLeg"
	}

	self._unit:link(Idstring("Hips"), self._current_carry_unit, self._current_carry_unit:orientation_object():name())

	for _, o_name in ipairs(objects) do
		self._current_carry_unit:get_object(Idstring(o_name)):link(self._unit:get_object(Idstring(o_name)))
		self._current_carry_unit:get_object(Idstring(o_name)):set_position(self._unit:get_object(Idstring(o_name)):position())
		self._current_carry_unit:get_object(Idstring(o_name)):set_rotation(self._unit:get_object(Idstring(o_name)):rotation())
	end
end

function HuskPlayerMovement:set_movement_updator(func)
	self._updator_movement = func
end

function HuskPlayerMovement:clear_movement_updator()
	self._updator_movement = nil
end

function HuskPlayerMovement:set_attention_updator(func)
	self._updator_attention = func
end

function HuskPlayerMovement:clear_attention_updator()
	self._updator_attention = nil
end

function HuskPlayerMovement:_has_finished_loading()
	return not self._load_data
end

function HuskPlayerMovement:_use_weapon_fire_dir()
	return self._arm_animator:enabled() and not self._arm_animator:is_blocked()
	return false
end

function HuskPlayerMovement:update(unit, t, dt)
	if not self:_has_finished_loading() then
		return
	end

	self:_calculate_m_pose()

	if self._updator_movement then
		self:_updator_movement(t, dt)
	else
		self:_upd_move_standard(t, dt)
	end

	if self._updator_attention then
		self:_updator_attention(t, dt)
	else
		self:_upd_attention_standard(t, dt)
	end

	self:_upd_stance(t)

	local panel_id = managers.criminals:character_data_by_unit(self._unit) and managers.criminals:character_data_by_unit(self._unit).panel_id

	if panel_id then
		if self._state == "civilian" then
			managers.hud:hide_player_gear(panel_id)
		else
			managers.hud:show_player_gear(panel_id)
		end
	end

	if not self._peer_weapon_spawned and alive(self._unit) then
		local inventory = self._unit:inventory()

		if inventory and inventory.check_peer_weapon_spawn then
			self._peer_weapon_spawned = inventory:check_peer_weapon_spawn()
		else
			self._peer_weapon_spawned = true
		end
	end

	if self._auto_firing >= 2 and not self._ext_anim.reload then
		local equipped_weapon = self._unit:inventory():equipped_unit()

		if alive(equipped_weapon) and equipped_weapon:base().auto_trigger_held then
			equipped_weapon:base():auto_trigger_held(self._look_dir, true, self._firing, self:_use_weapon_fire_dir())

			self._aim_up_expire_t = TimerManager:game():time() + 2
		end
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

	if self._delayed_redirects then
		for i, redirect in ipairs(self._delayed_redirects) do
			redirect.t = redirect.t - dt

			if redirect.t <= 0 then
				self:play_redirect(unpack(redirect.args))
				table.remove(self._delayed_redirects, i)
			end
		end
	end

	if self._retry_sync_movement_state_driving then
		self._retry_sync_movement_state_driving = nil

		if self._state == "driving" then
			self:_sync_movement_state_driving()
		end
	end

	self._arm_animator:update(t, dt)
end

function HuskPlayerMovement:enable_update()
end

function HuskPlayerMovement:sync_look_dir(fwd, yaw, pitch)
	mvector3.normalize(fwd)

	self._sync_look_dir = fwd

	if self._arm_animator:enabled() then
		self._arm_animator:set_look_dir(yaw, pitch)
	end
end

function HuskPlayerMovement:sync_arm_frame_pose(frame_index, pose)
	if self._arm_animation_enabled then
		if not self._arm_animator:enabled() then
			self._arm_animator:set_enabled(true)
			self:refresh_primary_hand()
		end

		local r, l = nil
		local base = self._unit:inventory():equipped_unit():base()

		if base:enabled() then
			local interact = self._ext_anim.interact
			local akimbo = base.AKIMBO and not interact
			local melee = self._ext_anim.melee
			local skip_l = melee and self._melee_hand and self._melee_hand == 0
			local skip_r = melee and self._melee_hand and self._melee_hand == 1

			if (akimbo or self._primary_hand == 0) and not skip_r then
				r = self._weapon_align_points[1]:local_rotation()
			end

			if (akimbo or self._primary_hand == 1) and not skip_l then
				l = self._weapon_align_points[2]:local_rotation()
			end
		end

		self._arm_animator:record_keyframe(frame_index, pose, r, l)
	else
		self._unit:network():send("set_arm_setting", ArmSetting.SET_ARM_ANIMATOR_PRESENT, 0)
	end
end

function HuskPlayerMovement:set_arm_setting(setting_id, setting_param)
	if self._arm_animation_enabled and setting_id == ArmSetting.SET_ARM_ANIMATOR_ENABLED then
		if setting_param > 0 then
			self._arm_animator:set_enabled(true)
			self:refresh_primary_hand()
		else
			self._arm_animator:set_enabled(false)
			self:refresh_primary_hand(true)

			if self._ext_anim.melee and alive(self._machine) then
				self._machine:stop_segment(Idstring("upper_body_ext"))
				self._machine:stop_segment(Idstring("upper_body"))
			end
		end
	end
end

function HuskPlayerMovement:set_primary_hand(hand)
	self._desired_primary_hand = hand

	self:refresh_primary_hand()
end

function HuskPlayerMovement:primary_hand()
	return self._primary_hand
end

function HuskPlayerMovement:refresh_primary_hand(force)
	local enabled = self:arm_animation_enabled()

	if not enabled and not force then
		return
	end

	if enabled then
		self._primary_hand = self._desired_primary_hand

		if self._arm_animator:is_state_blocked("bow") then
			self._primary_hand = 1

			self._arm_animator:set_primary_hand(self._primary_hand)
		elseif self._arm_animator:is_state_blocked("arrested") then
			self._primary_hand = 0

			self._arm_animator:set_primary_hand(self._primary_hand)
		elseif self._ext_anim.melee then
			self._use_primary_melee_hand = self._primary_hand ~= self._melee_hand

			self._arm_animator:set_primary_hand(self._melee_hand)

			local weapon = self._unit:inventory():equipped_unit()

			if weapon and not self._use_primary_melee_hand then
				if weapon:base().AKIMBO then
					weapon:base():on_melee_item_hidden(true)
					weapon:base():on_melee_item_shown(false)
				else
					weapon:base():on_enabled()
				end
			end
		else
			self._arm_animator:set_primary_hand(self._primary_hand)
		end
	else
		self._primary_hand = 0
	end

	self._unit:inventory():refresh_primary_hand()
end

function HuskPlayerMovement:arm_animation_enabled()
	return self._arm_animation_enabled and self._arm_animator:enabled()
end

function HuskPlayerMovement:arm_animation_blocked()
	return self._arm_animation_enabled and self._arm_animator:enabled() and self._arm_animator:is_blocked()
end

function HuskPlayerMovement:unblock_melee()
	if not self:arm_animation_enabled() then
		return
	end

	if self._ext_anim.reload then
		return
	end

	if self._melee_equipped then
		self:sync_melee_start()
	end
end

function HuskPlayerMovement:block_melee()
	if not self:arm_animation_enabled() then
		return
	end

	if self._ext_anim.melee then
		if alive(self._machine) then
			self._machine:stop_segment(Idstring("upper_body_ext"))
		end

		if alive(self._unit:inventory():equipped_unit()) then
			if self._unit:inventory():equipped_unit():base().AKIMBO then
				self._unit:inventory():equipped_unit():base():on_melee_item_hidden(self._use_primary_melee_hand)
				self._unit:inventory():equipped_unit():base():on_melee_item_hidden(not self._use_primary_melee_hand)
			else
				self._unit:inventory():equipped_unit():base():on_enabled()
				self._unit:inventory():equipped_unit():base():apply_grip(true)
			end
		end
	end
end

function HuskPlayerMovement:anim_clbk_reload_exit()
	self:unblock_melee()
end

function HuskPlayerMovement:on_weapon_add()
	self:refresh_primary_hand()
end

function HuskPlayerMovement:clbk_arm_animator(enabled)
	if not self:arm_animation_enabled() then
		return
	end

	if enabled then
		self:unblock_melee()
	else
		self:block_melee()
	end
end

function HuskPlayerMovement:set_look_dir_instant(fwd)
	mvector3.set(self._look_dir, fwd)
	self._look_modifier:set_target_y(self._look_dir)

	self._sync_look_dir = nil
end

function HuskPlayerMovement:m_pos()
	return self._m_pos
end

function HuskPlayerMovement:m_stand_pos()
	return self._m_stand_pos
end

function HuskPlayerMovement:m_com()
	return self._m_com
end

function HuskPlayerMovement:m_head_rot()
	return self._m_head_rot
end

function HuskPlayerMovement:m_head_pos()
	return self._m_head_pos
end

function HuskPlayerMovement:m_detect_pos()
	return self._m_detect_pos
end

function HuskPlayerMovement:m_newest_pos()
	return self._m_newest_pos
end

function HuskPlayerMovement:m_rot()
	return self._m_rot
end

function HuskPlayerMovement:get_object(object_name)
	return self._unit:get_object(object_name)
end

function HuskPlayerMovement:detect_look_dir()
	return self._sync_look_dir or self._look_dir
end

function HuskPlayerMovement:look_dir()
	return self._look_dir
end

function HuskPlayerMovement:_calculate_m_pose()
	mrotation.set_look_at(self._m_head_rot, self._look_dir, math.UP)
	self._obj_head:m_position(self._m_head_pos)
	self._obj_spine:m_position(self._m_com)

	local det_pos = self._m_detect_pos

	if self._move_data then
		local path = self._move_data.path

		mvector3.set(det_pos, path[#path])
		mvector3.set(self._m_newest_pos, det_pos)
	else
		mvector3.set(det_pos, self._m_pos)
		mvector3.set(self._m_newest_pos, self._m_pos)
	end

	local offset_z = self._pose_code == 2 and self._crouch_detection_offset_z or mvec3_z(self._m_head_pos) - mvec3_z(self._m_pos)

	mvec3_set_z(det_pos, mvec3_z(det_pos) + offset_z)
end

function HuskPlayerMovement:set_position(pos)
	mvector3.set(self._m_pos, pos)
	self._unit:set_position(pos)

	if self._nav_tracker then
		self._nav_tracker:move(pos)

		local nav_seg_id = self._nav_tracker:nav_segment()

		if self._standing_nav_seg_id ~= nav_seg_id then
			self._standing_nav_seg_id = nav_seg_id
			local metadata = managers.navigation:get_nav_seg_metadata(nav_seg_id)

			self._unit:base():set_suspicion_multiplier("area", metadata.suspicion_mul)
			self._unit:base():set_detection_multiplier("area", metadata.detection_mul and 1 / metadata.detection_mul or nil)
			managers.groupai:state():on_criminal_nav_seg_change(self._unit, nav_seg_id)
		end
	end
end

function HuskPlayerMovement:get_location_id()
	return self._standing_nav_seg_id and managers.navigation:get_nav_seg_metadata(self._standing_nav_seg_id).location_id or nil
end

function HuskPlayerMovement:set_rotation(rot)
	mrotation.set_yaw_pitch_roll(self._m_rot, rot:yaw(), 0, 0)
	self._unit:set_rotation(rot)
end

function HuskPlayerMovement:set_m_rotation(rot)
	mrotation.set_yaw_pitch_roll(self._m_rot, rot:yaw(), 0, 0)
end

function HuskPlayerMovement:nav_tracker()
	return self._nav_tracker
end

function HuskPlayerMovement:play_redirect(redirect_name, at_time)
	local result = self._unit:play_redirect(Idstring(redirect_name), at_time)
	result = result ~= Idstring("") and result

	if result then
		return result
	end

	print("[HuskPlayerMovement:play_redirect] redirect", redirect_name, "failed in", self._machine:segment_state(self._ids_base), self._machine:segment_state(Idstring("upper_body")))
	Application:stack_dump()
end

function HuskPlayerMovement:play_redirect_delayed(redirect_name, at_time, delay)
	if delay <= 0 then
		self:play_redirect(redirect_name, at_time)
	else
		self._delayed_redirects = self._delayed_redirects or {}

		table.insert(self._delayed_redirects, {
			t = delay,
			args = {
				redirect_name,
				at_time
			}
		})
	end
end

function HuskPlayerMovement:play_redirect_idstr(redirect_name, at_time)
	local result = self._unit:play_redirect(redirect_name, at_time)
	result = result ~= Idstring("") and result

	if result then
		return result
	end

	print("[HuskPlayerMovement:play_redirect_idstr] redirect", redirect_name, "failed in", self._machine:segment_state(self._ids_base), self._machine:segment_state(Idstring("upper_body")))
	Application:stack_dump()
end

function HuskPlayerMovement:play_state(state_name, at_time)
	local result = self._unit:play_state(Idstring(state_name), at_time)
	result = result ~= Idstring("") and result

	if result then
		return result
	end

	print("[HuskPlayerMovement:play_state] state", state_name, "failed in", self._machine:segment_state(self._ids_base), self._machine:segment_state(Idstring("upper_body")))
	Application:stack_dump()
end

function HuskPlayerMovement:play_state_idstr(state_name, at_time)
	local result = self._unit:play_state(state_name, at_time)
	result = result ~= Idstring("") and result

	if result then
		return result
	end

	print("[HuskPlayerMovement:play_state_idstr] state", state_name, "failed in", self._machine:segment_state(self._ids_base), self._machine:segment_state(Idstring("upper_body")))
	Application:stack_dump()
end

function HuskPlayerMovement:sync_melee_start(hand)
	if hand and hand > 0 then
		self._melee_hand = hand % 2

		if self._primary_hand ~= self._melee_hand then
			self._use_primary_melee_hand = true
		else
			self._use_primary_melee_hand = false
		end
	end

	self._melee_equipped = true

	if self:arm_animation_enabled() then
		if self._ext_anim.reload and alive(self._machine) then
			self._machine:stop_segment(Idstring("upper_body"))
		end

		if self:arm_animation_blocked() then
			return
		end
	elseif hand > 0 then
		return
	end

	self:destroy_magazine_in_hand()

	local use_ext = nil
	use_ext = self:arm_animation_enabled()
	local redir_res = self:play_redirect(use_ext and "melee_start_ext" or "melee_start")

	if redir_res and alive(self._unit:inventory():equipped_unit()) then
		if self._unit:inventory():equipped_unit():base().AKIMBO then
			self._unit:inventory():equipped_unit():base():on_melee_item_shown(self._use_primary_melee_hand or false)
		elseif self._use_primary_melee_hand then
			self._unit:inventory():equipped_unit():base():on_disabled()
		end
	end
end

function HuskPlayerMovement:sync_melee_stop()
	self._melee_equipped = false

	if self._ext_anim.melee then
		self:anim_cbk_unspawn_melee_item()

		self._ext_anim.melee = false

		if alive(self._machine) then
			self._machine:stop_segment(Idstring("upper_body_ext"))
		end
	end
end

function HuskPlayerMovement:sync_melee_discharge()
	local redir_res = self:play_redirect("melee_attack")

	if redir_res then
		-- Nothing
	end
end

function HuskPlayerMovement:anim_cbk_set_melee_start_state_vars(unit, name, segment_name)
	local state = self._unit:anim_state_machine():segment_state(segment_name or Idstring("upper_body"))
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local peer = managers.network:session():peer(peer_id)
	local melee_entry = peer:melee_id()
	local anim_global_param = tweak_data.blackmarket.melee_weapons[melee_entry].anim_global_param

	self._unit:anim_state_machine():set_parameter(state, anim_global_param, 1)
end

function HuskPlayerMovement:anim_cbk_set_melee_start_ext_state_vars(unit)
	self:anim_cbk_set_melee_start_state_vars(unit, nil, Idstring("upper_body_ext"))
end

function HuskPlayerMovement:anim_cbk_set_melee_charge_ext_state_vars(unit)
	self:anim_cbk_set_melee_start_state_vars(unit, nil, Idstring("upper_body_ext"))
end

function HuskPlayerMovement:anim_cbk_set_melee_charge_state_vars(unit)
	self:anim_cbk_set_melee_start_state_vars(unit)
end

function HuskPlayerMovement:anim_cbk_set_melee_discharge_state_vars(unit)
	self:anim_cbk_set_melee_start_state_vars(unit)
end

function HuskPlayerMovement:anim_cbk_set_melee_item_state_vars(unit)
	local state = self._unit:anim_state_machine():segment_state(Idstring("upper_body"))
	local anim_attack_vars = {
		"var1",
		"var2"
	}

	self._unit:anim_state_machine():set_parameter(state, anim_attack_vars[math.random(#anim_attack_vars)], 1)

	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local peer = managers.network:session():peer(peer_id)
	local melee_entry = peer:melee_id()
	local anim_global_param = tweak_data.blackmarket.melee_weapons[melee_entry].anim_global_param

	self._unit:anim_state_machine():set_parameter(state, anim_global_param, 1)
end

function HuskPlayerMovement:anim_cbk_spawn_melee_item(unit, graphic_object)
	if alive(self._melee_item_unit) or not managers.network:session() or not managers.network:session():peer_by_unit(self._unit) then
		return
	end

	local align_obj_name = Idstring("a_weapon_left_front")

	if self:arm_animation_enabled() then
		self:refresh_primary_hand()

		if self._melee_hand == 1 then
			align_obj_name = Idstring("a_weapon_right_front")
		end
	end

	local align_obj = self._unit:get_object(align_obj_name)
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local peer = managers.network:session():peer(peer_id)
	local melee_entry = peer:melee_id()
	local graphic_object_name = Idstring(graphic_object)
	local graphic_objects = tweak_data.blackmarket.melee_weapons[melee_entry].graphic_objects or {}
	local unit_name = tweak_data.blackmarket.melee_weapons[melee_entry].third_unit

	if unit_name then
		self._melee_item_unit = World:spawn_unit(Idstring(unit_name), align_obj:position(), align_obj:rotation())

		self._unit:link(align_obj:name(), self._melee_item_unit, self._melee_item_unit:orientation_object():name())

		if self:arm_animation_enabled() then
			local offset = tweak_data.vr.melee_offsets.weapons_npc[melee_entry]

			if offset then
				if offset.right and self._melee_hand == 1 then
					self._melee_item_unit:set_local_position(offset.right.position or Vector3())
					self._melee_item_unit:set_local_rotation(offset.right.rotation or Rotation())
				elseif offset.left and self._melee_hand == 0 then
					self._melee_item_unit:set_local_position(offset.left.position or Vector3())
					self._melee_item_unit:set_local_rotation(offset.left.rotation or Rotation())
				else
					self._melee_item_unit:set_local_position(offset.position or Vector3())
					self._melee_item_unit:set_local_rotation(offset.rotation or Rotation())
				end

				if offset.hidden_objects then
					for _, object in ipairs(offset.hidden_objects) do
						local obj = self._melee_item_unit:get_object(object)

						if obj then
							obj:set_visibility(false)
						end
					end
				end
			end
		end

		for a_object, g_object in pairs(graphic_objects) do
			local g_obj_name = Idstring(g_object)
			local g_obj = self._melee_item_unit:get_object(g_obj_name)

			g_obj:set_visibility(Idstring(a_object) == graphic_object_name)
		end

		if self._unit:inventory().on_melee_item_shown then
			self._unit:inventory():on_melee_item_shown()
		end
	end

	if alive(self._unit:inventory():equipped_unit()) then
		if self._unit:inventory():equipped_unit():base().AKIMBO then
			self._unit:inventory():equipped_unit():base():on_melee_item_shown(self._use_primary_melee_hand)
		elseif self._use_primary_melee_hand then
			self._unit:inventory():equipped_unit():base():on_disabled()
		end
	end
end

function HuskPlayerMovement:anim_cbk_unspawn_melee_item(unit)
	if alive(self._melee_item_unit) then
		self._melee_item_unit:unlink()
		World:delete_unit(self._melee_item_unit)

		self._melee_item_unit = nil
	end

	if self:arm_animation_enabled() then
		self:refresh_primary_hand()
	end

	if alive(self._unit:inventory():equipped_unit()) then
		if self._unit:inventory():equipped_unit():base().AKIMBO then
			self._unit:inventory():equipped_unit():base():on_melee_item_hidden(self._use_primary_melee_hand)
		elseif self._use_primary_melee_hand then
			self._unit:inventory():equipped_unit():base():on_enabled()
			self._unit:inventory():equipped_unit():base():apply_grip(true)
		end
	end

	if self._unit:inventory().on_melee_item_hidden then
		self._unit:inventory():on_melee_item_hidden()
	end
end

function HuskPlayerMovement:set_need_revive(need_revive, down_time)
	if self._need_revive == need_revive then
		return
	end

	self._unit:character_damage():set_last_down_time(down_time)

	self._need_revive = need_revive

	self._unit:interaction():set_active(need_revive, false, down_time)

	if Network:is_server() then
		if need_revive and not self._revive_SO_id and not self._revive_rescuer then
			self:_register_revive_SO()
		elseif not need_revive and (self._revive_SO_id or self._revive_rescuer or self._deathguard_SO_id) then
			self:_unregister_revive_SO()
		end
	end
end

function HuskPlayerMovement:_register_revive_SO()
	local followup_objective = {
		scan = true,
		type = "act",
		action = {
			variant = "crouch",
			body_part = 1,
			type = "act",
			blocks = {
				heavy_hurt = -1,
				hurt = -1,
				action = -1,
				aim = -1,
				walk = -1
			}
		}
	}
	local objective = {
		type = "revive",
		called = true,
		scan = true,
		destroy_clbk_key = false,
		follow_unit = self._unit,
		nav_seg = self._unit:movement():nav_tracker():nav_segment(),
		fail_clbk = callback(self, self, "on_revive_SO_failed"),
		complete_clbk = callback(self, self, "on_revive_SO_completed"),
		action = {
			align_sync = true,
			type = "act",
			body_part = 1,
			variant = self._state == "arrested" and "untie" or "revive",
			blocks = {
				light_hurt = -1,
				hurt = -1,
				action = -1,
				heavy_hurt = -1,
				aim = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction[self._state == "arrested" and "free" or "revive"].timer,
		followup_objective = followup_objective
	}
	local so_descriptor = {
		interval = 1,
		AI_group = "friendlies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = self._unit:position(),
		admin_clbk = callback(self, self, "on_revive_SO_administered"),
		verification_clbk = callback(HuskPlayerMovement, HuskPlayerMovement, "rescue_SO_verification", self._unit)
	}
	local so_id = "PlayerHusk_revive" .. tostring(self._unit:key())
	self._revive_SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)

	if not self._deathguard_SO_id then
		self._deathguard_SO_id = PlayerBleedOut._register_deathguard_SO(self._unit)
	end
end

function HuskPlayerMovement:_unregister_revive_SO()
	if self._deathguard_SO_id then
		PlayerBleedOut._unregister_deathguard_SO(self._deathguard_SO_id)

		self._deathguard_SO_id = nil
	end

	if self._revive_rescuer then
		local rescuer = self._revive_rescuer
		self._revive_rescuer = nil

		rescuer:brain():set_objective(nil)
	elseif self._revive_SO_id then
		managers.groupai:state():remove_special_objective(self._revive_SO_id)

		self._revive_SO_id = nil
	end

	if self._sympathy_civ then
		local sympathy_civ = self._sympathy_civ
		self._sympathy_civ = nil

		sympathy_civ:brain():set_objective(nil)
	end
end

function HuskPlayerMovement:set_need_assistance(need_assistance)
	if self._need_assistance == need_assistance then
		return
	end

	self._need_assistance = need_assistance

	if Network:is_server() then
		if need_assistance and not self._assist_SO_id then
			local objective = {
				scan = true,
				destroy_clbk_key = false,
				type = "follow",
				called = true,
				follow_unit = self._unit,
				nav_seg = self._unit:movement():nav_tracker():nav_segment()
			}
			local so_descriptor = {
				interval = 6,
				chance_inc = 0,
				search_dis_sq = 25000000,
				base_chance = 1,
				usage_amount = 1,
				AI_group = "friendlies",
				objective = objective,
				search_pos = self._unit:position()
			}
			local so_id = "PlayerHusk_assistance" .. tostring(self._unit:key())
			self._assist_SO_id = so_id

			managers.groupai:state():add_special_objective(so_id, so_descriptor)
		elseif not need_assistance and self._assist_SO_id then
			managers.groupai:state():remove_special_objective(self._assist_SO_id)

			self._assist_SO_id = nil
		end
	end
end

function HuskPlayerMovement:on_revive_SO_administered(receiver_unit)
	if self._revive_SO_id then
		self._revive_rescuer = receiver_unit
		self._revive_SO_id = nil
	end
end

function HuskPlayerMovement:on_revive_SO_failed(rescuer)
	if self._revive_rescuer then
		self._revive_rescuer = nil

		self:_register_revive_SO()
	end
end

function HuskPlayerMovement:on_revive_SO_completed(rescuer)
	self._revive_rescuer = nil

	self:_unregister_revive_SO()
end

function HuskPlayerMovement:need_revive()
	return self._need_revive
end

function HuskPlayerMovement:downed()
	return self._need_revive or self._need_assistance
end

function HuskPlayerMovement:_upd_attention_mask_off(dt)
	if not self._atention_on then
		self._atention_on = true

		self._machine:force_modifier(self._mask_off_modifier_name)
	end

	if self._sync_look_dir then
		local error_angle = self._sync_look_dir:angle(self._look_dir)
		local rot_speed_rel = math.pow(math.min(error_angle / 90, 1), 0.5)
		local rot_speed = math.lerp(40, 360, rot_speed_rel)
		local rot_amount = math.min(rot_speed * dt, error_angle)
		local error_axis = self._look_dir:cross(self._sync_look_dir)
		local rot_adj = Rotation(error_axis, rot_amount)
		self._look_dir = self._look_dir:rotate_with(rot_adj)
		local look_dir = self._look_dir

		if self._arm_animator:enabled() and self._arm_animator:is_facing_allowed() then
			look_dir = self._arm_animator:facing_dir()
		end

		self._mask_off_modifier:set_target_z(look_dir)

		if rot_amount == error_angle then
			self._sync_look_dir = nil
		end
	end
end

function HuskPlayerMovement:_upd_attention_standard(t, dt)
	if not self._atention_on then
		if self._ext_anim.bleedout then
			if self._sync_look_dir and self._sync_look_dir ~= self._look_dir then
				self._look_dir = mvector3.copy(self._sync_look_dir)
			end

			return
		else
			self._atention_on = true

			self._machine:force_modifier(self._look_modifier_name)
		end
	end

	self:_sync_look_direction(t, dt)
end

function HuskPlayerMovement:_sync_look_direction(t, dt)
	self._smooth_look = self._smooth_look or {
		current = Vector3(),
		target = Vector3()
	}

	if self._sync_look_dir then
		mvec3_set(self._smooth_look.target, self._sync_look_dir)

		self._sync_look_dir = nil
	end

	local st = dt * tweak_data.network.look_direction_smooth_step

	mvector3.step(self._smooth_look.current, self._smooth_look.current, self._smooth_look.target, st)
	mvec3_norm(self._smooth_look.current)

	if self._smooth_look.current then
		local tar_look_dir = tmp_vec1

		mvec3_set(tar_look_dir, self._smooth_look.current)

		local wait_for_turn = nil
		local hips_fwd = tmp_vec2

		mrotation.y(self._m_rot, hips_fwd)

		local hips_err_spin = tar_look_dir:to_polar_with_reference(hips_fwd, math.UP).spin
		local max_spin = 90
		local min_spin = -90

		if max_spin < hips_err_spin or hips_err_spin < min_spin then
			wait_for_turn = true

			if max_spin < hips_err_spin then
				mvector3.rotate_with(tar_look_dir, Rotation(max_spin - hips_err_spin))
			else
				mvector3.rotate_with(tar_look_dir, Rotation(min_spin - hips_err_spin))
			end
		end

		local error_angle = tar_look_dir:angle(self._look_dir)
		local rot_speed_rel = math.pow(math.min(error_angle / 90, 1), 0.5)
		local rot_speed = math.lerp(40, 360, rot_speed_rel)
		rot_speed = rot_speed * (self._stance.owner_stance_code == cbt_stance_code and 10 or 1)
		local rot_amount = math.min(rot_speed * dt, error_angle)
		local error_axis = self._look_dir:cross(tar_look_dir)
		local rot_adj = Rotation(error_axis, rot_amount)
		self._look_dir = self._look_dir:rotate_with(rot_adj)
		local look_dir = self._look_dir

		if self._arm_animator:enabled() and self._arm_animator:is_facing_allowed() then
			look_dir = self._arm_animator:facing_dir()
		end

		self._look_modifier:set_target_y(look_dir)

		if rot_amount == error_angle and not wait_for_turn then
			-- Nothing
		end
	end
end

function HuskPlayerMovement:_upd_attention_bleedout(t, dt)
	if self._sync_look_dir then
		local fwd = self._m_rot:y()

		if self._atention_on then
			if self._ext_anim.reload then
				self._atention_on = false
				local blend_out_t = 0.15

				self._machine:set_modifier_blend(self._head_modifier_name, blend_out_t)
				self._machine:set_modifier_blend(self._arm_modifier_name, blend_out_t)
				self._machine:forbid_modifier(self._head_modifier_name)
				self._machine:forbid_modifier(self._arm_modifier_name)
			end
		elseif self._ext_anim.bleedout_falling or self._ext_anim.reload then
			if self._sync_look_dir ~= self._look_dir then
				self._look_dir = mvector3.copy(self._sync_look_dir)
			end

			return
		else
			self._atention_on = true

			self._machine:force_modifier(self._head_modifier_name)
			self._machine:force_modifier(self._arm_modifier_name)
		end

		local error_angle = self._sync_look_dir:angle(self._look_dir)
		local rot_speed_rel = math.pow(math.min(error_angle / 90, 1), 0.5)
		local rot_speed = math.lerp(40, 360, rot_speed_rel)
		local rot_amount = math.min(rot_speed * dt, error_angle)
		local error_axis = self._look_dir:cross(self._sync_look_dir)
		local rot_adj = Rotation(error_axis, rot_amount)
		self._look_dir = self._look_dir:rotate_with(rot_adj)

		self._arm_modifier:set_target_y(self._look_dir)
		self._head_modifier:set_target_z(self._look_dir)

		local aim_polar = self._look_dir:to_polar_with_reference(fwd, math.UP)
		local aim_spin = aim_polar.spin
		local anim = self._machine:segment_state(self._ids_base)
		local fwd = 1 - math.clamp(math.abs(aim_spin / 90), 0, 1)

		self._machine:set_parameter(anim, "angle0", fwd)

		local bwd = math.clamp(math.abs(aim_spin / 90), 1, 2) - 1

		self._machine:set_parameter(anim, "angle180", bwd)

		local l = 1 - math.clamp(math.abs(aim_spin / 90 - 1), 0, 1)

		self._machine:set_parameter(anim, "angle90neg", l)

		local r = 1 - math.clamp(math.abs(aim_spin / 90 + 1), 0, 1)

		self._machine:set_parameter(anim, "angle90", r)

		if rot_amount == error_angle then
			self._sync_look_dir = nil
		end
	end
end

function HuskPlayerMovement:_upd_attention_incapcitated(t, dt)
end

function HuskPlayerMovement:_upd_attention_fatal(t, dt)
end

function HuskPlayerMovement:_upd_attention_dead(t, dt)
end

function HuskPlayerMovement:_upd_attention_zipline(t, dt)
	if self._sync_look_dir then
		if self._atention_on then
			if self._ext_anim.reload then
				self._atention_on = false
				local blend_out_t = 0.15

				self._machine:set_modifier_blend(self._head_modifier_name, blend_out_t)
				self._machine:set_modifier_blend(self._arm_modifier_name, blend_out_t)
				self._machine:forbid_modifier(self._head_modifier_name)
				self._machine:forbid_modifier(self._arm_modifier_name)
			end
		elseif self._ext_anim.reload then
			if self._sync_look_dir ~= self._look_dir then
				self._look_dir = mvector3.copy(self._sync_look_dir)
			end

			return
		else
			self._atention_on = true

			self._machine:force_modifier(self._head_modifier_name)
			self._machine:force_modifier(self._arm_modifier_name)
		end

		local max_yaw_from_rp = 90
		local min_yaw_from_rp = -90
		local root_yaw = mrotation.yaw(self._m_rot)
		local look_rot = tmp_rot1

		mrotation.set_look_at(look_rot, self._sync_look_dir, math.UP)

		local look_yaw = mrotation.yaw(look_rot)
		local look_yaw_relative = look_yaw - root_yaw

		if math.abs(look_yaw_relative) > 180 then
			look_yaw_relative = look_yaw_relative - math.sign(look_yaw_relative) * 180
		end

		local out_of_bounds = nil

		if max_yaw_from_rp < look_yaw_relative or look_yaw_relative < min_yaw_from_rp then
			out_of_bounds = true
			look_yaw_relative = math.clamp(look_yaw_relative, min_yaw_from_rp, max_yaw_from_rp)
		end

		local old_look_rot = tmp_rot2

		mrotation.set_look_at(old_look_rot, self._look_dir, math.UP)

		local old_look_yaw = mrotation.yaw(old_look_rot)
		local old_look_yaw_relative = old_look_yaw - root_yaw

		if math.abs(old_look_yaw_relative) > 180 then
			old_look_yaw_relative = old_look_yaw_relative - math.sign(old_look_yaw_relative) * 180
		end

		local yaw_diff = look_yaw_relative - old_look_yaw_relative
		local pitch_diff = mrotation.pitch(look_rot) - mrotation.pitch(old_look_rot)
		local yaw_step = math.lerp(40, 400, (math.min(math.abs(yaw_diff), 20) / 20)^2) * dt
		yaw_step = math.sign(yaw_diff) * math.min(yaw_step, math.abs(yaw_diff))
		local pitch_step = math.lerp(30, 250, (math.min(math.abs(pitch_diff), 20) / 20)^2) * dt
		pitch_step = math.sign(pitch_diff) * math.min(pitch_step, math.abs(pitch_diff))
		local new_yaw = old_look_yaw + yaw_step
		local out_of_bounds = nil

		if max_yaw_from_rp < new_yaw - root_yaw or min_yaw_from_rp > new_yaw - root_yaw then
			new_yaw = math.clamp(new_yaw, min_yaw_from_rp, max_yaw_from_rp)
		end

		if look_yaw_relative == 0 and new_yaw == look_yaw and pitch_diff == pitch_step and not out_of_bounds then
			self._sync_look_dir = nil
		end

		local new_rot = tmp_rot3

		mrotation.set_yaw_pitch_roll(new_rot, new_yaw, mrotation.pitch(old_look_rot) + pitch_step, 0)
		mrotation.y(new_rot, self._look_dir)
		self._arm_modifier:set_target_y(self._look_dir)
		self._head_modifier:set_target_z(self._look_dir)

		local aim_spin = new_yaw - root_yaw

		if math.abs(aim_spin) > 180 then
			aim_spin = aim_spin - math.sign(aim_spin) * 180
		end

		local anim = self._machine:segment_state(self._ids_base)
		local fwd = 1 - math.clamp(math.abs(aim_spin / 90), 0, 1)
		local l = math.clamp(aim_spin / max_yaw_from_rp, 0, 1)
		local r = math.clamp(aim_spin / min_yaw_from_rp, 0, 1)

		self._machine:set_parameter(anim, "fwd", fwd)
		self._machine:set_parameter(anim, "l", l)
		self._machine:set_parameter(anim, "r", r)
	end
end

function HuskPlayerMovement:_upd_attention_freefall(t, dt)
	if not self._atention_on then
		self._atention_on = true

		self._machine:force_modifier(self._head_modifier_name)
	end

	if self._sync_look_dir then
		self:update_sync_look_dir(t, dt)
	end
end

function HuskPlayerMovement:_upd_attention_parachute(t, dt)
	if not self._atention_on then
		self._atention_on = true

		self._machine:force_modifier(self._head_modifier_name)
	end

	if self._sync_look_dir then
		self:update_sync_look_dir(t, dt)
	end
end

function HuskPlayerMovement:_upd_attention_driving(t, dt)
	if self._driver and self._vehicle then
		local steer = self._vehicle:get_steer()
		local anim = self._machine:segment_state(self._ids_base)
		local r = math.clamp(-steer, 0, 1)
		local l = math.clamp(steer, 0, 1)
		local fwd = math.clamp(1 - steer, 0, 1)

		self._machine:set_parameter(anim, "fwd", fwd)
		self._machine:set_parameter(anim, "l", l)
		self._machine:set_parameter(anim, "r", r)
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:force_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)

		if self._sync_look_dir then
			self:update_sync_look_dir(t, dt)
		end

		return
	end

	if self._sync_look_dir then
		if self._atention_on then
			self._atention_on = false

			if self._ext_anim.reload then
				self._atention_on = false
				local blend_out_t = 0.15

				self._machine:set_modifier_blend(self._arm_modifier_name, blend_out_t)
				self._machine:set_modifier_blend(self._head_modifier_name, blend_out_t)
				self._machine:set_modifier_blend(self._look_modifier_name, blend_out_t)
				self._machine:forbid_modifier(self._head_modifier_name)
				self._machine:forbid_modifier(self._arm_modifier_name)
				self._machine:forbid_modifier(self._look_modifier_name)
			end
		elseif self._ext_anim.reload then
			if self._sync_look_dir ~= self._look_dir then
				self._look_dir = mvector3.copy(self._sync_look_dir)
			end

			return
		else
			self._atention_on = true

			if self._vehicle_shooting_stance == PlayerDriving.STANCE_NORMAL and not self._vehicle_allows_shooting then
				self._machine:forbid_modifier(self._look_modifier_name)
				self._machine:force_modifier(self._head_modifier_name)
				self._machine:forbid_modifier(self._arm_modifier_name)
			else
				self._machine:force_modifier(self._look_modifier_name)
				self._machine:forbid_modifier(self._head_modifier_name)
				self._machine:forbid_modifier(self._arm_modifier_name)
			end
		end

		self:update_sync_look_dir(t, dt)

		local fwd = self._m_rot:y()
		local spin = fwd:to_polar_with_reference(self._look_dir, math.UP).spin
		local anim = self._machine:segment_state(self._ids_base)
		local max_anim_spin = 120
		local min_anim_spin = -120
		local aim_spin = spin
		local anim = self._machine:segment_state(self._ids_base)
		local fwd = math.clamp(1 - math.abs(aim_spin) / 45, 0, 1)
		local bwd = math.clamp(1 - (180 - math.abs(aim_spin)) / 45, 0, 1)
		local l, r = nil

		if aim_spin > 0 then
			r = 1 - fwd - bwd
			l = 0
		else
			l = 1 - fwd - bwd
			r = 0
		end

		self._machine:set_parameter(anim, "fwd", fwd)
		self._machine:set_parameter(anim, "l", l)
		self._machine:set_parameter(anim, "r", r)
		self._machine:set_parameter(anim, "bwd", bwd)
		self._machine:set_parameter(anim, "team_ai", 0)
	end
end

function HuskPlayerMovement:_upd_attention_nothing(t, dt)
end

function HuskPlayerMovement:update_sync_look_dir(t, dt)
	local tar_look_dir = tmp_vec1

	mvec3_set(tar_look_dir, self._sync_look_dir)

	local error_angle = tar_look_dir:angle(self._look_dir)
	local rot_speed_rel = math.pow(math.min(error_angle / 90, 1), 0.5)
	local rot_speed = math.lerp(40, 360, rot_speed_rel)
	local rot_amount = math.min(rot_speed * dt, error_angle)
	local error_axis = self._look_dir:cross(tar_look_dir)
	local rot_adj = Rotation(error_axis, rot_amount)
	self._look_dir = self._look_dir:rotate_with(rot_adj)

	if self._vehicle_shooting_stance == PlayerDriving.STANCE_NORMAL and not self._vehicle_allows_shooting then
		self._head_modifier:set_target_z(self._look_dir)
	else
		self._look_modifier:set_target_y(self._look_dir)
		self._arm_modifier:set_target_y(self._look_dir)
		self._head_modifier:set_target_z(self._look_dir)
	end

	if rot_amount == error_angle then
		self._sync_look_dir = nil
	end
end

function HuskPlayerMovement:_upd_sequenced_events(t, dt)
	local sequenced_events = self._sequenced_events
	local next_event = sequenced_events[1]

	if not next_event then
		return
	end

	if next_event.commencing then
		return
	end

	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	local event_type = next_event.type

	self:_cleanup_previous_state(next_event.previous_state)

	if event_type == "move" then
		next_event.commencing = true

		self:_start_movement(next_event.path)
	elseif event_type == "bleedout" then
		if self:_start_bleedout(next_event) then
			table.remove(sequenced_events, 1)
		end
	elseif event_type == "fatal" then
		if self:_start_fatal(next_event) then
			table.remove(sequenced_events, 1)
		end
	elseif event_type == "incapacitated" then
		if self:_start_incapacitated(next_event) then
			table.remove(sequenced_events, 1)
		end
	elseif event_type == "tased" then
		if self:_start_tased(next_event) then
			table.remove(sequenced_events, 1)
		end
	elseif event_type == "standard" then
		if self:_start_standard(next_event) then
			table.remove(sequenced_events, 1)
		end
	elseif event_type == "dead" then
		if self:_start_dead(next_event) then
			table.remove(sequenced_events, 1)
		end
	elseif event_type == "arrested" then
		if self:_start_arrested(next_event) then
			table.remove(sequenced_events, 1)
		end
	elseif event_type == "zipline" then
		next_event.commencing = true

		self:_start_zipline(next_event)
	elseif event_type == "driving" then
		if self:_start_driving(next_event) then
			table.remove(sequenced_events, 1)
		end
	elseif event_type == "jump" then
		self:_start_jumping(next_event)
	elseif event_type == "pose" then
		self:_change_pose(next_event.code)
		table.remove(sequenced_events, 1)
	end

	local event_type = next_event and not next_event.commencing and next_event.type

	if event_type == "jerry1" then
		if self:_start_freefall(next_event) then
			table.remove(sequenced_events, 1)
		end
	elseif event_type == "jerry2" and self:_start_parachute(next_event) then
		table.remove(sequenced_events, 1)
	end
end

function HuskPlayerMovement:_add_sequenced_event(event_desc)
	table.insert(self._sequenced_events, event_desc)
end

function HuskPlayerMovement:_upd_stance(t)
	if self._aim_up_expire_t and self._aim_up_expire_t < t then
		self._aim_up_expire_t = nil

		self:_chk_change_stance()
	end

	local stance = self._stance

	if stance.transition then
		local transition = stance.transition

		if transition.next_upd_t < t then
			transition.next_upd_t = t + 0.033
			local values = stance.values
			local prog = (t - transition.start_t) / transition.duration

			if prog < 1 then
				local prog_smooth = math.clamp(math.bezier({
					0,
					0,
					1,
					1
				}, prog), 0, 1)
				local v_start = transition.start_values
				local v_end = transition.end_values
				local mlerp = math.lerp

				for i, v in ipairs(v_start) do
					values[i] = mlerp(v, v_end[i], prog_smooth)
				end
			else
				for i, v in ipairs(transition.end_values) do
					values[i] = v
				end

				if transition.delayed_shot then
					transition:delayed_shot(true)
				end

				stance.transition = nil
			end

			local names = stance.names

			for i, v in ipairs(values) do
				self._machine:set_global(names[i], values[i])
			end
		end
	end
end

function HuskPlayerMovement:_upd_slow_pos_reservation(t, dt)
	local slow_dist = 100

	mvec3_set(tmp_vec2, self._pos_reservation_slow.position)
	mvec3_sub(tmp_vec2, self._pos_reservation.position)

	if slow_dist < mvec3_norm(tmp_vec2) then
		mvec3_mul(tmp_vec2, slow_dist)
		mvec3_add(tmp_vec2, self._pos_reservation.position)
		mvec3_set(self._pos_reservation_slow.position, tmp_vec2)
		managers.navigation:move_pos_rsrv(self._pos_reservation)
	end
end

function HuskPlayerMovement:action_is(node_action, desired)
	if type(node_action) ~= "table" then
		return node_action == desired
	else
		return table.contains(node_action, desired)
	end
end

function HuskPlayerMovement:add_action(node, new_action)
	if not node.action then
		node.action = {}
	end

	if type(node.action) ~= "table" then
		local act = node.action
		node.action = {
			act,
			new_action
		}
	else
		table.insert(node.action, new_action)
	end
end

function HuskPlayerMovement:_override_last_node_type(new_type)
	if self._movement_path then
		local node = self._movement_path[#self._movement_path]

		if node then
			node.type = new_type
		end
	end
end

function HuskPlayerMovement:_override_last_node_action(new_action, add)
	if self._movement_path then
		local node = self._movement_path[#self._movement_path]

		if node then
			if add then
				self:add_action(node, new_action)
			else
				node.action = {
					new_action
				}
			end
		end
	end
end

function HuskPlayerMovement:_upd_displacement_pre_move(t, dt)
	self._m_start_pos = self._m_start_pos or Vector3()
	self._m_displacement = self._m_displacement or Vector3()

	mvector3.set(self._m_start_pos, self._m_pos)
end

function HuskPlayerMovement:_upd_displacement_post_move(t, dt)
	mvector3.subtract(self._m_start_pos, self._m_pos)

	local _t = not self._moving and self._moving_t and self._moving_t - t > 1 / tweak_data.network.player_tick_rate * 2 and 250 or 25

	mvector3.step(self._m_displacement, self._m_displacement, self._m_start_pos, dt * _t)
end

function HuskPlayerMovement:_upd_move_standard(t, dt)
	self:_upd_displacement_pre_move(t, dt)
	self:_update_air_time(t, dt)
	self:_update_zipline_time(t, dt)
	self:_update_position(t, dt)
	self:_update_zipline_sled(t, dt)
	self:_update_rotation_standard(t, dt)

	if self._desired_pose_code ~= nil then
		self:_change_pose(self._desired_pose_code)

		self._desired_pose_code = nil
	end

	self:_upd_displacement_post_move(t, dt)
	self:_update_animation_standard(t, dt)
end

function HuskPlayerMovement:_upd_move_no_animations(t, dt)
	self:_upd_displacement_pre_move(t, dt)
	self:_update_air_time(t, dt)
	self:_update_zipline_time(t, dt)
	self:_update_position(t, dt)
	self:_update_zipline_sled(t, dt)
	self:_upd_displacement_post_move(t, dt)
end

function HuskPlayerMovement:_upd_move_driving(t, dt)
	self:set_position(self.seat_third:position())
	self:set_rotation(self.seat_third:rotation())
end

function HuskPlayerMovement:_update_air_time(t, dt)
	if self._in_air then
		self._air_time = (self._air_time or 0) + dt

		if self._air_time > 1 then
			local on_ground = self:_chk_ground_ray(self:m_pos())

			if on_ground then
				self._in_air = false
				self._air_time = 0
			end
		end
	else
		self._air_time = 0
	end
end

function HuskPlayerMovement:_update_zipline_time(t, dt)
	if self._zipline and self._zipline.attached then
		self._zipline.t = (self._zipline.t or 0) + dt
	end
end

function HuskPlayerMovement:_update_zipline_sled(t, dt)
	if self._zipline and self._zipline.attached then
		local zipline = self._zipline and self._zipline.zipline_unit and self._zipline.zipline_unit:zipline()

		if zipline then
			local closest_pos = math.point_on_line(zipline:start_pos(), zipline:end_pos(), self:m_pos())
			local distance = (zipline:start_pos() - closest_pos):length()
			local length = (zipline:start_pos() - zipline:end_pos()):length()
			local t = distance / length

			zipline:update_and_get_pos_at_time_linear(math.clamp(t, 0, 1))
		end
	end
end

HuskPlayerMovement._catchup_actions = {
	bleedout = {
		action_negative = "_perform_catchup_bleedout_exit",
		action_positive = "_perform_catchup_bleedout_enter",
		decrement = "exit_bleedout",
		increment = "enter_bleedout"
	}
}

function HuskPlayerMovement:_perform_path_catchup()
	for id, catchup in pairs(self._catchup_actions) do
		catchup.index = 0
	end

	local node = nil

	for i = 1, #self._movement_path - 2, 1 do
		node = self._movement_path[1]

		for _, action_name in ipairs(node.action) do
			for _, catchup in pairs(self._catchup_actions) do
				catchup.index = catchup.index or 0

				if catchup.increment == action_name then
					catchup.index = catchup.index + 1
				elseif catchup.decrement == action_name then
					catchup.index = catchup.index - 1
				end
			end
		end

		table.remove(self._movement_path, 1)
	end

	self:set_position(self._movement_path[1].pos)

	for id, catchup in pairs(self._catchup_actions) do
		if catchup.action_positive and catchup.index > 0 then
			self[catchup.action_positive](self)
		elseif catchup.action_negative and catchup.index < 0 then
			self[catchup.action_negative](self)
		end
	end
end

function HuskPlayerMovement:_perform_catchup_bleedout_enter()
	self:_perform_movement_action_enter_bleedout()
end

function HuskPlayerMovement:_perform_catchup_bleedout_exit()
	self:_perform_movement_action_exit_bleedout()
end

function HuskPlayerMovement:_perform_catchup_zipline_start()
	self:_perform_movement_action_zipline_start()
end

function HuskPlayerMovement:_perform_catchup_zipline_end()
	self:_perform_movement_action_zipline_end()
end

function HuskPlayerMovement:_perform_catchup_teleport_start()
	self:_perform_movement_action_teleport_start()
end

function HuskPlayerMovement:_perform_catchup_teleport_end()
	self:_perform_movement_action_teleport_end()
end

function HuskPlayerMovement:force_start_moving()
	self._moving = true
end

function HuskPlayerMovement:_update_position(t, dt)
	local path_length = self._movement_path and #self._movement_path

	if not path_length then
		return
	end

	if tweak_data.network.player_husk_path_threshold < path_length then
		self:_perform_path_catchup()

		return
	end

	if not self._moving and self._movement_path and tweak_data.network.player_path_interpolation < #self._movement_path then
		self._moving = true
	end

	local destination = self._movement_path[1] and self._movement_path[1].pos

	if destination then
		local dist = mvector3.distance_sq(self._m_pos, destination)

		if dist > 10 then
			self._moving = true
		end
	end

	if self._moving then
		self._movement_t = self._movement_t or 0
		local final_pos = Vector3()
		local i = 1
		local remove_at = 1
		local move_speed = self:_get_max_move_speed(self._running) * dt * (self._movement_path[1] and self._movement_path[1].speed or 1)
		local remaining_move_speed = move_speed

		while remaining_move_speed > 0 do
			if not self._movement_path[i] then
				i = i - 1

				break
			end

			local dist = mvector3.distance(self._m_pos, self._movement_path[i].pos)

			if dist < remaining_move_speed then
				self:set_position(self._movement_path[i].pos)

				i = i + 1
				remove_at = i
				remaining_move_speed = remaining_move_speed - dist
				move_speed = remaining_move_speed
			else
				remaining_move_speed = 0
			end
		end

		if self._movement_path[i] then
			mvector3.step(final_pos, self._m_pos, self._movement_path[i] and self._movement_path[i].pos, move_speed)
			self:set_position(final_pos)
		end

		if remove_at > 1 then
			for x = 1, remove_at - 1, 1 do
				self:_perform_movement_action(1)

				self._last_path_position = self._movement_path[1].pos

				table.remove(self._movement_path, 1)
			end

			self._moving = #self._movement_path > 0

			if not self._moving then
				self._moving_t = t
			end
		end
	end

	local ground_z = self:_chk_floor_moving_pos()

	if ground_z then
		self._unit:set_position(self._m_pos:with_z(ground_z))
	end
end

function HuskPlayerMovement:_perform_movement_action(idx)
	local current_node = self._movement_path[idx]

	if not current_node or not current_node.action then
		return false
	end

	local consume = false
	local will_consume = false

	for _, action in ipairs(current_node.action) do
		local func = "_perform_movement_action_" .. action

		if self[func] then
			consume = self[func](self, idx, current_node)
		else
			Application:error("No husk function for action ", action, "!")

			consume = true
		end

		will_consume = consume or will_consume
	end

	self._last_node = self._movement_path[idx]

	if will_consume then
		self._movement_path[idx][2] = nil
	end
end

function HuskPlayerMovement:_perform_movement_action_jump(idx, node)
	self:play_redirect("jump_fwd")

	self._in_air_counter = math.max((self._in_air_counter or 0) + 1, 0)
	self._in_air = self._in_air_counter > 0
	self._air_time = tweak_data.player.movement_state.standard.movement.jump_velocity.z / tweak_data.player.gravity

	return true
end

function HuskPlayerMovement:_perform_movement_action_land(idx, node)
	self._unit:sound_source():post_event("footstep_npc_hardsole_land")

	self._in_air_counter = math.max((self._in_air_counter or 0) - 1, 0)
	self._in_air = self._in_air_counter > 0
	local vel_len, anim_velocity, anim_side = self:_get_animation_move_speed(TimerManager:game():delta_time())

	if anim_velocity and anim_side and not self._bleedout then
		self:play_redirect(anim_velocity .. "_" .. "fwd")
	end

	return true
end

function HuskPlayerMovement:_perform_movement_action_fall(idx, node)
	self:play_redirect("jump")

	self._in_air = true

	return true
end

function HuskPlayerMovement:_perform_movement_action_zipline_start(idx, node)
	if self._zipline then
		self._zipline.enabled = true
		self._zipline.attached = true
	end
end

function HuskPlayerMovement:_perform_movement_action_zipline_end(idx, node)
	if self._zipline then
		self._zipline.enabled = false
		self._zipline.attached = false
	end
end

function HuskPlayerMovement:_perform_movement_action_teleport_start(idx, node)
	local next_idx = idx and idx + 1 or #self._movement_path
	local next_node = self._movement_path[next_idx]

	if next_node then
		self:set_position(next_node.pos)
	end
end

function HuskPlayerMovement:_perform_movement_action_teleport_end(idx, node)
end

function HuskPlayerMovement:_perform_movement_action_enter_bleedout(idx, node)
	self._bleedout = true
	local redir_res = self:play_redirect("bleedout")

	if not redir_res then
		print("[HuskPlayerMovement:_start_bleedout] redirect failed in", self._machine:segment_state(self._ids_base), self._unit)
	end

	self:set_movement_updator(self._upd_move_no_animations)
	self:set_attention_updator(self._upd_attention_bleedout)
end

function HuskPlayerMovement:_perform_movement_action_exit_bleedout(idx, node)
	self._bleedout = false

	self:clear_movement_updator()
	self:clear_attention_updator()
end

function HuskPlayerMovement:_perform_movement_action_enter_arrested(idx, node)
	self._bleedout = true
	local redir_res = self:play_redirect("tied")

	if not redir_res then
		print("[HuskPlayerMovement:_start_arrested] redirect failed in", self._machine:segment_state(self._ids_base), self._unit)
	end

	self:set_movement_updator(self._upd_move_no_animations)
	self:set_attention_updator(self._upd_attention_incapcitated)
end

function HuskPlayerMovement:_perform_movement_action_exit_arrested(idx, node)
	self._bleedout = false

	self:clear_movement_updator()
	self:clear_attention_updator()
end

function HuskPlayerMovement:_update_rotation_standard(t, dt)
	if self._ext_anim.bleedout_enter or self._ext_anim.bleedout_exit or self._ext_anim.fatal_enter or self._ext_anim.fatal_exit then
		return
	end

	local look_dir_flat = self._look_dir:with_z(0)

	mvector3.normalize(look_dir_flat)

	if self._arm_animator:enabled() and self._arm_animator:is_facing_allowed() then
		look_dir_flat = self._arm_animator:facing_dir()
	end

	local leg_fwd_cur = self._m_rot:y()
	local waist_twist = look_dir_flat:to_polar_with_reference(leg_fwd_cur, math.UP).spin
	local abs_waist_twist = math.abs(waist_twist)
	local update_pose_forbidden = self._bleedout

	if not update_pose_forbidden then
		if self._pose_code == 1 then
			if not self._ext_anim.stand then
				self:play_redirect("stand")
			end
		elseif self._pose_code == 3 then
			if not self._ext_anim.prone then
				self:play_redirect("prone")
			end
		elseif not self._ext_anim.crouch then
			self:play_redirect("crouch")
		end
	end

	if self._turning then
		self:set_m_rotation(self._unit:rotation())

		if not self._ext_anim.turn then
			self._turning = nil

			self._unit:set_driving("orientation_object")
			self._machine:set_root_blending(true)
		end
	end

	local waist_twist_max = 70
	local sign_waist_twist = math.sign(waist_twist)
	local leg_max_angle_adj = math.min(abs_waist_twist, 120 * dt)
	local waist_twist_new = waist_twist - sign_waist_twist * leg_max_angle_adj

	if waist_twist_max < math.abs(waist_twist_new) then
		waist_twist_new = sign_waist_twist * waist_twist_max
	else
		waist_twist_new = waist_twist - sign_waist_twist * leg_max_angle_adj
	end

	local ik_rotation_forbidden = self._moving or self._turning or self._bleedout or self._in_air or self._zipline and self._zipline.attached

	if not ik_rotation_forbidden then
		local min_twist = -65
		local max_twist = 65

		if waist_twist > max_twist or waist_twist < min_twist then
			local angle = waist_twist
			local dir_str = angle > 0 and "l" or "r"
			local redir_name = "turn_" .. dir_str
			local redir_res = self:play_redirect(redir_name)

			if redir_res then
				self._turning = true
				local abs_angle = math.abs(angle)

				if abs_angle > 135 then
					self._machine:set_parameter(redir_res, "angle135", 1)
				elseif abs_angle > 90 then
					local lerp = (abs_angle - 90) / 45

					self._machine:set_parameter(redir_res, "angle135", lerp)
					self._machine:set_parameter(redir_res, "angle90", 1 - lerp)
				elseif abs_angle > 45 then
					local lerp = (abs_angle - 45) / 45

					self._machine:set_parameter(redir_res, "angle90", lerp)
					self._machine:set_parameter(redir_res, "angle45", 1 - lerp)
				else
					self._machine:set_parameter(redir_res, "angle45", 1)
				end

				self._unit:set_driving("animation")
				self._machine:set_root_blending(false)
			end
		end
	else
		local rotation_forbidden = self._bleedout

		if not rotation_forbidden then
			local leg_rot_new = Rotation(look_dir_flat, math.UP) * Rotation(-waist_twist_new)

			self:set_rotation(leg_rot_new)
		end
	end
end

function HuskPlayerMovement:_update_animation_standard(t, dt)
	if self._turning or self._bleedout then
		return
	end

	if self._zipline and self._zipline.attached then
		if not self._ext_anim.zipline then
			self:play_redirect("zipline")
		end

		return
	end

	local path_len_remaining = 100
	local vel_len, anim_velocity, anim_side = self:_get_animation_move_speed(dt)

	if math.abs(self._displacement_len) > 0.001 then
		local stance = self._stance.name
		local pose = self._ext_anim.pose

		if self._play_land_animation then
			self:play_redirect(anim_velocity .. "_" .. anim_side)

			self._play_land_animation = nil
		end

		if not self:_is_anim_move_speed_forbidden() then
			if not self._walk_anim_velocities[pose] or not self._walk_anim_velocities[pose][stance] or not self._walk_anim_velocities[pose][stance][anim_velocity] or not self._walk_anim_velocities[pose][stance][anim_velocity][anim_side] then
				return
			end

			local animated_walk_vel = self._walk_anim_velocities[pose][stance][anim_velocity][anim_side]
			local anim_speed = vel_len / animated_walk_vel

			self:_adjust_move_anim(anim_side, anim_velocity)
			self:_adjust_walk_anim_speed(dt, anim_speed)
		end
	elseif not self:_is_anim_idle_redirect_forbidden() and not self._in_air then
		self:play_redirect("idle")
	end
end

function HuskPlayerMovement:_get_animation_move_speed(dt)
	local vel_len, anim_velocity, anim_side = nil
	local displacement = self._m_displacement
	local displacement_len = mvector3.length(displacement)
	local _t = (self._displacement_len or displacement_len < 0) and 100 or 10
	self._displacement_len = math.step(self._displacement_len or 0, displacement_len, dt * _t)

	if math.abs(self._displacement_len) > 0.001 then
		local fwd_new = self._m_rot:y()
		local right_new = fwd_new:cross(math.UP)
		local walk_dir_flat = displacement * -1

		mvector3.normalize(walk_dir_flat)

		local fwd_dot = walk_dir_flat:dot(fwd_new)
		local right_dot = walk_dir_flat:dot(right_new)

		if math.abs(right_dot) < math.abs(fwd_dot) then
			if fwd_dot > 0 then
				anim_side = "fwd"
			else
				anim_side = "bwd"
			end
		elseif right_dot > 0 then
			anim_side = "r"
		else
			anim_side = "l"
		end

		vel_len = self._displacement_len / dt

		if self._stance.name == "ntl" then
			if self._ext_anim.run then
				if vel_len > 250 then
					anim_velocity = "run"
				else
					anim_velocity = "walk"
				end
			elseif vel_len > 300 then
				anim_velocity = "run"
			else
				anim_velocity = "walk"
			end
		elseif self._ext_anim.sprint then
			if vel_len > 450 and self._pose_code == 1 then
				anim_velocity = "sprint"
			elseif vel_len > 250 then
				anim_velocity = "run"
			else
				anim_velocity = "walk"
			end
		elseif self._ext_anim.run then
			if vel_len > 500 and self._pose_code == 1 then
				anim_velocity = "sprint"
			elseif vel_len > 250 then
				anim_velocity = "run"
			else
				anim_velocity = "walk"
			end
		elseif vel_len > 500 and self._pose_code == 1 then
			anim_velocity = "sprint"
		elseif vel_len > 300 then
			anim_velocity = "run"
		else
			anim_velocity = "walk"
		end
	end

	return vel_len, anim_velocity, anim_side
end

function HuskPlayerMovement:_is_slowdown_to_next_action()
	local event_desc = self._sequenced_events[2]

	return event_desc and event_desc.is_no_move_slowdown
end

function HuskPlayerMovement:_is_anim_move_redirect_forbidden(path_len_remaining)
	return not self._move_data or self._ext_anim.landing or self._ext_anim.jumping and path_len_remaining < 50
end

function HuskPlayerMovement:_is_anim_idle_redirect_forbidden()
	return self._ext_anim.idle or self._ext_anim.landing
end

function HuskPlayerMovement:_is_anim_move_speed_forbidden()
	return self._ext_anim.jumping or self._ext_anim.landing
end

function HuskPlayerMovement:_is_anim_stop_allowed()
	return self._ext_anim.jumping or self._ext_anim.landing and self._ext_anim.move
end

function HuskPlayerMovement:_is_start_move_velocity_max()
	return self._ext_anim.jumping
end

function HuskPlayerMovement:_upd_move_zipline(t, dt)
	if self._load_data then
		return
	end

	if not self._ext_anim.zipline then
		self:play_redirect("zipline")
	end

	local event_desc = self._sequenced_events[1]
	event_desc.current_time = math.min(1, event_desc.current_time + dt / event_desc.zipline_unit:zipline():total_time())

	self:set_position(event_desc.zipline_unit:zipline():update_and_get_pos_at_time(event_desc.current_time))

	if event_desc.current_time == 1 then
		self:on_exit_zipline()
	end

	local look_rot = tmp_rot1

	mrotation.set_look_at(look_rot, self._look_dir, math.UP)

	local look_yaw = mrotation.yaw(look_rot)
	local root_yaw = mrotation.yaw(self._m_rot)

	if math.abs(look_yaw - root_yaw) > 180 then
		root_yaw = root_yaw - math.sign(root_yaw) * 180
	end

	local yaw_diff = look_yaw - root_yaw
	local step = math.lerp(20, 220, math.min(math.abs(yaw_diff), 30) / 30) * dt
	step = math.sign(yaw_diff) * math.min(step, math.abs(yaw_diff))
	local new_rot = tmp_rot1

	mrotation.set_yaw_pitch_roll(new_rot, root_yaw + step, 0, 0)
	self:set_rotation(new_rot)
end

function HuskPlayerMovement:anim_clbk_exit_vehicle(unit)
	self:on_exit_vehicle()
end

function HuskPlayerMovement:_adjust_move_anim(side, speed)
	local anim_data = self._ext_anim

	if anim_data.haste == speed and anim_data["move_" .. side] then
		return
	end

	local redirect_name = speed .. "_" .. side
	local enter_t = nil
	local move_side = anim_data.move_side

	if move_side and (side == move_side or self._matching_walk_anims[side][move_side]) then
		local seg_rel_t = self._machine:segment_relative_time(self._ids_base)
		local pose = self._ext_anim.pose
		local stance = self._stance.name

		if not self._walk_anim_lengths[pose] or not self._walk_anim_lengths[pose][stance] or not self._walk_anim_lengths[pose][stance][speed] or not self._walk_anim_lengths[pose][stance][speed][side] then
			debug_pause_unit(self._unit, "[HuskPlayerMovement:_adjust_move_anim] Boom...", self._unit, "pose", pose, "stance", stance, "speed", speed, "side", side, self._machine:segment_state(self._ids_base))

			return
		end

		local walk_anim_length = self._walk_anim_lengths[pose][stance][speed][side]
		enter_t = seg_rel_t * walk_anim_length
	end

	local redir_res = self:play_redirect(redirect_name, enter_t)

	return redir_res
end

function HuskPlayerMovement:clear_movement_path()
	self._movement_path = {}
	self._movement_history = {}
end

function HuskPlayerMovement:sync_action_walk_nav_point(pos, speed, action, params)
	speed = speed or 1
	params = params or {}
	self._movement_path = self._movement_path or {}
	self._movement_history = self._movement_history or {}
	local path_len = #self._movement_path
	pos = pos or (path_len <= 0 or self._movement_path[path_len].pos) and mvector3.copy(self:m_pos())

	if Network:is_server() then
		if not self._pos_reservation then
			self._pos_reservation = {
				radius = 100,
				position = mvector3.copy(pos),
				filter = self._pos_rsrv_id
			}
			self._pos_reservation_slow = {
				radius = 100,
				position = mvector3.copy(pos),
				filter = self._pos_rsrv_id
			}

			managers.navigation:add_pos_reservation(self._pos_reservation)
			managers.navigation:add_pos_reservation(self._pos_reservation_slow)
		else
			self._pos_reservation.position = mvector3.copy(pos)

			managers.navigation:move_pos_rsrv(self._pos_reservation)
			self:_upd_slow_pos_reservation()
		end
	end

	local can_add = true

	if not params.force and path_len > 0 then
		local last_node = self._movement_path[path_len]

		if last_node then
			local dist_sq = mvector3.distance_sq(pos, last_node.pos)
			can_add = dist_sq > 4
		end
	end

	if can_add then
		local on_ground = self:_chk_ground_ray(pos)
		local type = "ground"

		if self._zipline and self._zipline.enabled then
			type = "zipline"
		elseif not on_ground then
			type = "air"
		end

		local prev_node = self._movement_history[#self._movement_history]

		if type == "ground" and prev_node and self:action_is(prev_node.action, "jump") then
			type = "air"
		end

		if type == "ground" then
			local ground_z = self:_chk_floor_moving_pos()

			if ground_z then
				mvector3.set_z(pos, ground_z)
			end
		end

		local node = {
			pos = pos,
			speed = speed,
			type = type,
			action = {
				action
			}
		}

		table.insert(self._movement_path, node)
		table.insert(self._movement_history, node)

		if not params.force then
			local len = #self._movement_history

			if len > 1 then
				self:_determine_node_action(#self._movement_history, node)
			end
		end

		for i = 1, #self._movement_history - tweak_data.network.player_path_history, 1 do
			table.remove(self._movement_history, 1)
		end

		if params.execute and #self._movement_path <= tweak_data.network.player_path_interpolation then
			self:force_start_moving()
		end
	end
end

function HuskPlayerMovement:_determine_node_action(idx, node)
	local last_node = self._movement_history[idx - 1]

	if not last_node then
		Application:error("Can not determine the action for a node without a prior node! idx: ", idx)

		return
	end

	local action, pass_current_type, pass_last_type, pass_not_last_type, pass_last_action, pass_not_last_action = nil

	for action_name, action_data in pairs(HuskPlayerMovement.action_prerequisites) do
		pass_current_type = action_data.current_type == nil or table.contains(action_data.current_type, node.type)
		pass_last_type = action_data.last_type == nil or table.contains(action_data.last_type, last_node.type)
		pass_not_last_type = action_data.not_last_type == nil or not table.contains(action_data.not_last_type, last_node.type)
		pass_last_action = action_data.last_action == nil

		if last_node.action and action_data.last_action then
			local pass = false

			for _, action in ipairs(last_node.action) do
				if table.contains(action_data.last_action, action) then
					pass = true

					break
				end
			end

			if pass then
				pass_last_action = true
			end
		end

		pass_not_last_action = action_data.not_last_action == nil

		if action_data.not_last_action then
			if last_node.action then
				for _, action in ipairs(last_node.action) do
					if table.contains(action_data.not_last_action, action) then
						pass_not_last_action = false

						break
					end
				end
			else
				pass_not_last_action = true
			end
		end

		if pass_current_type and pass_last_type and pass_not_last_type and pass_last_action and pass_not_last_action then
			action = action_data.target_action or action_name

			break
		end
	end

	self:add_action(node, action)
end

function HuskPlayerMovement:sync_action_change_pose(pose_code, pos)
	self._desired_pose_code = pose_code
end

function HuskPlayerMovement:current_state()
	return self
end

function HuskPlayerMovement:_start_movement(path)
	local data = {}
	self._move_data = data

	table.insert(path, 1, self._unit:position())

	data.path = path

	if self:_is_start_move_velocity_max() then
		data.velocity_len = self:_get_max_move_speed(true)
	else
		data.velocity_len = 0
	end

	local old_pos = path[1]
	local nr_nodes = #path
	local path_len = 0
	local i = 1

	while nr_nodes > i do
		mvector3.set(tmp_vec1, path[i + 1])
		mvector3.subtract(tmp_vec1, path[i])

		if mvector3.z(tmp_vec1) < 0 then
			mvector3.set_z(tmp_vec1, 0)
		end

		path_len = path_len + mvector3.length(tmp_vec1)
		i = i + 1
	end

	data.path_len = path_len
	data.prog_in_seg = 0
	data.seg_dir = Vector3()

	mvec3_set(data.seg_dir, path[2])
	mvec3_sub(data.seg_dir, path[1])

	if mvector3.z(data.seg_dir) < 0 then
		mvec3_set_z(data.seg_dir, 0)
	end

	data.seg_len = mvec3_norm(data.seg_dir)
end

function HuskPlayerMovement:_upd_attention_bipod(t, dt)
	self:_sync_look_direction(t, dt)
end

function HuskPlayerMovement:_upd_move_bipod(t, dt)
	if self._state == "standard" then
		self._attention_updator = callback(self, self, "_upd_attention_standard")
		self._movement_updator = callback(self, self, "_upd_move_standard")

		self._look_modifier:set_target_y(self._look_dir)

		return
	end

	if self._pose_code == 1 then
		if not self._ext_anim.stand then
			self:play_redirect("stand")
		end
	elseif self._pose_code == 3 then
		if not self._ext_anim.prone then
			self:play_redirect("prone")
		end
	elseif not self._ext_anim.crouch then
		self:play_redirect("crouch")
	end

	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local husk_bipod_data = managers.player:get_bipod_data_for_peer(peer_id)

	if not husk_bipod_data then
		return
	end

	local bipod_pos = husk_bipod_data.bipod_pos

	if not bipod_pos then
		local weapon = self._unit:inventory():equipped_unit()
		local bipod_obj = weapon:get_object(Idstring("a_bp"))

		if bipod_obj then
			bipod_pos = bipod_obj:position()
		else
			return
		end
	end

	if not bipod_pos then
		return
	end

	local body_pos = husk_bipod_data.body_pos
	body_pos = body_pos or Vector3(self._m_pos.x, self._m_pos.y, self._m_pos.z)
	self._stance.owner_stance_code = 3

	self:_chk_change_stance()

	if not self._sync_look_dir then
		self._sync_look_dir = self._look_dir
	end

	if not self._bipod_last_angle then
		self._bipod_last_angle = self._sync_look_dir:angle(self._look_dir)
	end

	self._unit:set_driving("script")

	local husk_original_look_direction = Vector3(self._look_dir.x, self._look_dir.y, 0)
	local target_angle = self._sync_look_dir:angle(self._look_dir)
	local rotate_direction = math.sign((self._sync_look_dir - self._look_dir):to_polar_with_reference(self._look_dir, math.UP).spin)
	local rotate_angle = target_angle * rotate_direction
	rotate_angle = math.lerp(self._bipod_last_angle, rotate_angle, dt * 2)

	if self._anim_playing == nil then
		self._anim_playing = false
	end

	local stop_threshold = 0.115

	if stop_threshold < math.abs(self._bipod_last_angle - rotate_angle) and not self._anim_playing and rotate_direction == -1 then
		self:play_redirect("walk_r", nil)

		self._anim_playing = true
	elseif stop_threshold < math.abs(self._bipod_last_angle - rotate_angle) and not self._anim_playing and rotate_direction == 1 then
		self:play_redirect("walk_l", nil)

		self._anim_playing = true
	elseif math.abs(self._bipod_last_angle - rotate_angle) < stop_threshold and self._anim_playing then
		self:play_redirect("idle", nil)

		self._anim_playing = false
	end

	self._bipod_last_angle = rotate_angle
	local new_x = math.cos(rotate_angle) * (body_pos.x - bipod_pos.x) - math.sin(rotate_angle) * (body_pos.y - bipod_pos.y) + bipod_pos.x
	local new_y = math.sin(rotate_angle) * (body_pos.x - bipod_pos.x) + math.cos(rotate_angle) * (body_pos.y - bipod_pos.y) + bipod_pos.y
	local new_pos = Vector3(new_x, new_y, self._m_pos.z)

	self:set_position(new_pos)

	local body_rotation = Rotation(husk_original_look_direction, math.UP) * Rotation(rotate_angle)

	self:set_rotation(body_rotation)
	managers.player:set_bipod_data_for_peer({
		peer_id = peer_id,
		bipod_pos = bipod_pos,
		body_pos = body_pos
	})
end

function HuskPlayerMovement:_start_standard(event_desc)
	self:set_need_revive(false)
	self:set_need_assistance(false)
	managers.hud:set_mugshot_normal(self._unit:unit_data().mugshot_id)

	if self.clean_states[self._state] then
		self._unit:set_slot(5)
		self:_change_pose(1)
		self._unit:inventory():hide_equipped_unit()
		self:_chk_change_stance()
	else
		self._unit:set_slot(3)

		if Network:is_server() then
			managers.groupai:state():on_player_weapons_hot()
		end

		managers.groupai:state():on_criminal_recovered(self._unit)
	end

	local previous_state = event_desc.previous_state

	if self.clean_states[self._state] and not self.clean_states[self._state] then
		local redir_res = self:play_redirect("equip")

		if redir_res then
			local weapon = self._unit:inventory():equipped_unit()

			if weapon then
				self._unit:inventory():show_equipped_unit()

				local weap_tweak = weapon:base():weapon_tweak_data()

				if type(weap_tweak.hold) == "table" then
					local num = #weap_tweak.hold + 1

					for i, hold_type in ipairs(weap_tweak.hold) do
						self._machine:set_parameter(redir_res, "to_" .. hold_type, num - i)
					end
				else
					self._machine:set_parameter(redir_res, "to_" .. weap_tweak.hold, 1)
				end
			end
		end
	end

	if not self._ext_anim.stand then
		local redir_res = self:play_redirect("stand")

		if not redir_res then
			self:play_state("std/stand/still/idle/look")
		end
	end

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	if self.clean_states[self._state] then
		self._attention_updator = callback(self, self, "_upd_attention_mask_off")
		self._movement_updator = callback(self, self, "_upd_move_standard")

		self._mask_off_modifier:set_target_z(self._look_dir)
	elseif self._state == "bipod" then
		local peer_id = managers.network:session():peer_by_unit(self._unit):id()
		self._attention_updator = callback(self, self, "_upd_attention_bipod")
		self._movement_updator = callback(self, self, "_upd_move_bipod")

		self._look_modifier:set_target_y(self._look_dir)
	else
		self._attention_updator = callback(self, self, "_upd_attention_standard")
		self._movement_updator = callback(self, self, "_upd_move_standard")

		self._look_modifier:set_target_y(self._look_dir)
	end

	self._last_vel_z = 0

	return true
end

function HuskPlayerMovement:_start_bleedout(event_desc)
	local redir_res = self:play_redirect("bleedout")

	if not redir_res then
		print("[HuskPlayerMovement:_start_bleedout] redirect failed in", self._machine:segment_state(self._ids_base), self._unit)

		return
	end

	self._unit:set_slot(3)
	managers.hud:set_mugshot_downed(self._unit:unit_data().mugshot_id)
	managers.groupai:state():on_criminal_disabled(self._unit)
	self._unit:interaction():set_tweak_data("revive")
	self:set_need_revive(true, event_desc.down_time)

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	return true
end

function HuskPlayerMovement:_start_tased(event_desc)
	local redir_res = self:play_redirect("tased")

	if not redir_res then
		print("[HuskPlayerMovement:_start_tased] redirect failed in", self._machine:segment_state(self._ids_base), self._unit)

		return
	end

	self._unit:set_slot(3)
	self:set_need_revive(false)
	managers.hud:set_mugshot_tased(self._unit:unit_data().mugshot_id)
	managers.groupai:state():on_criminal_disabled(self._unit, "electrified")

	self._tase_effect = World:effect_manager():spawn(self._tase_effect_table)

	self:set_need_assistance(true)

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self._attention_updator = callback(self, self, "_upd_attention_tased")
	self._movement_updator = callback(self, self, "_upd_move_downed")

	return true
end

function HuskPlayerMovement:_start_fatal(event_desc)
	local redir_res = self:play_redirect("fatal")

	if not redir_res then
		print("[HuskPlayerMovement:_start_fatal] redirect failed in", self._machine:segment_state(self._ids_base), self._unit)

		return
	end

	self._unit:set_slot(5)
	managers.hud:set_mugshot_downed(self._unit:unit_data().mugshot_id)
	managers.groupai:state():on_criminal_neutralized(self._unit)
	self._unit:interaction():set_tweak_data("revive")
	self:set_need_revive(true, event_desc.down_time)

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self._attention_updator = false
	self._movement_updator = callback(self, self, "_upd_move_downed")

	return true
end

function HuskPlayerMovement:_start_incapacitated(event_desc)
	local redir_res = self:play_redirect("incapacitated")

	if not redir_res then
		print("[HuskPlayerMovement:_start_incapacitated] redirect failed in", self._machine:segment_state(self._ids_base), self._unit)

		return
	end

	self:set_need_revive(true)

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self._attention_updator = false
	self._movement_updator = callback(self, self, "_upd_move_downed")

	return true
end

function HuskPlayerMovement:_start_dead(event_desc)
	local redir_res = self:play_redirect("death")

	if not redir_res then
		print("[HuskPlayerMovement:_start_dead] redirect failed in", self._machine:segment_state(self._ids_base), self._unit)

		return
	end

	if self._atention_on then
		local blend_out_t = 0.15

		self._machine:set_modifier_blend(self._look_modifier_name, blend_out_t)
		self._machine:set_modifier_blend(self._head_modifier_name, blend_out_t)
		self._machine:set_modifier_blend(self._arm_modifier_name, blend_out_t)
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self._attention_updator = false
	self._movement_updator = callback(self, self, "_upd_move_downed")

	return true
end

function HuskPlayerMovement:_start_arrested(event_desc)
	if not self._ext_anim.hands_tied then
		local redir_res = self:play_redirect("tied")

		if not redir_res then
			print("[HuskPlayerMovement:_start_arrested] redirect failed in", self._machine:segment_state(self._ids_base), self._unit)

			return
		end
	end

	self._unit:set_slot(5)
	managers.hud:set_mugshot_cuffed(self._unit:unit_data().mugshot_id)
	managers.groupai:state():on_criminal_neutralized(self._unit)
	self._unit:interaction():set_tweak_data("free")
	self:set_need_revive(true)

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self._attention_updator = callback(self, self, "_upd_attention_disarmed")
	self._movement_updator = false

	return true
end

function HuskPlayerMovement:_adjust_walk_anim_speed(dt, target_speed)
	local state = self._machine:segment_state(self._ids_base)
	local cur_speed = self._machine:get_speed(state)
	local max = 2
	local min = 0.05
	local new_speed = nil

	if cur_speed < target_speed and cur_speed < max then
		new_speed = target_speed
	elseif target_speed < cur_speed and min < cur_speed then
		new_speed = target_speed
	end

	if new_speed then
		self._machine:set_speed(state, math.clamp(new_speed, min, max))
	end
end

function HuskPlayerMovement:sync_shot_blank(impact, sub_id)
	if self.clean_states[self._state] then
		return
	end

	sub_id = self._arm_animator:enabled() and sub_id + 1 or 0
	local delay = self._stance.values[3] < 0.7
	local f = false

	if not delay then
		self:_shoot_blank(impact, sub_id)

		self._aim_up_expire_t = TimerManager:game():time() + 2
	else
		function f(impact)
			self:_shoot_blank(impact, sub_id)
		end
	end

	self:_change_stance(3, f)
end

function HuskPlayerMovement:sync_start_auto_fire_sound(sub_id)
	if self.clean_states[self._state] then
		return
	end

	sub_id = self._arm_animator:enabled() and sub_id + 1 or 0
	self._firing = self._firing or 0
	self._firing = bit.bor(self._firing, sub_id)

	if sub_id > 0 then
		local equipped_weapon = self._unit:inventory():equipped_unit()

		equipped_weapon:base():start_autofire(nil, sub_id)
		self:_change_stance(3, false)

		self._auto_firing = 2
		self._aim_up_expire_t = TimerManager:game():time() + 2

		return
	end

	if self._auto_firing <= 0 then
		local delay = self._stance.values[3] < 0.7

		if delay then
			self._auto_firing = 1

			local function f(t)
				local equipped_weapon = self._unit:inventory():equipped_unit()

				equipped_weapon:base():start_autofire()

				self._auto_firing = 2
			end

			self:_change_stance(3, f)
		else
			local equipped_weapon = self._unit:inventory():equipped_unit()

			equipped_weapon:base():start_autofire()
			self:_change_stance(3, false)

			self._auto_firing = 2
		end

		self._aim_up_expire_t = TimerManager:game():time() + 2
	end
end

function HuskPlayerMovement:sync_raise_weapon()
	if self.clean_states[self._state] then
		return
	end

	if self._auto_firing <= 0 then
		local delay = self._stance.values[3] < 0.7

		if delay then
			self._auto_firing = 1

			local function f(t)
				self._auto_firing = 2
			end

			self:_change_stance(3, f)
		else
			self:_change_stance(3, false)

			self._auto_firing = 2
		end

		self._aim_up_expire_t = TimerManager:game():time() + 2
	end
end

function HuskPlayerMovement:sync_stop_auto_fire_sound(sub_id)
	sub_id = self._arm_animator:enabled() and sub_id + 1 or 0
	self._firing = self._firing or 0
	self._firing = bit.band(self._firing, bit.bnot(sub_id))

	if sub_id > 0 then
		local equipped_weapon = self._unit:inventory():equipped_unit()

		equipped_weapon:base():stop_autofire(sub_id)

		if self._firing == 0 then
			self._auto_firing = 0
			local stance = self._stance

			if stance.transition then
				stance.transition.delayed_shot = nil
			end
		end

		return
	end

	local equipped_weapon = self._unit:inventory():equipped_unit()

	if equipped_weapon and equipped_weapon:base().shooting and equipped_weapon:base():shooting() then
		equipped_weapon:base():stop_autofire()
	end

	if self.clean_states[self._state] then
		return
	end

	if self._auto_firing > 0 then
		self._auto_firing = 0
		local stance = self._stance

		if stance.transition then
			stance.transition.delayed_shot = nil
		end
	end
end

function HuskPlayerMovement:set_cbt_permanent(on)
	self._is_weapon_gadget_on = on

	self:_chk_change_stance()
end

function HuskPlayerMovement:_shoot_blank(impact, sub_id)
	local equipped_weapon = self._unit:inventory():equipped_unit()

	if equipped_weapon and equipped_weapon:base().fire_blank then
		equipped_weapon:base():fire_blank(self._look_dir, impact, sub_id, self:_use_weapon_fire_dir())

		if self._aim_up_expire_t ~= -1 then
			self._aim_up_expire_t = TimerManager:game():time() + 2
		end
	end

	local anim_data = self._unit:anim_data()

	if not anim_data.base_no_recoil or anim_data.player_ignore_base_no_recoil then
		self:play_redirect("recoil_single")
	end
end

function HuskPlayerMovement:_equipped_weapon_base()
	local equipped_weapon = self._unit:inventory():equipped_unit()

	return alive(equipped_weapon) and equipped_weapon:base()
end

function HuskPlayerMovement:_equipped_weapon_crew_tweak_data()
	local equipped_weapon = self:_equipped_weapon_base()

	if equipped_weapon then
		return tweak_data.weapon[equipped_weapon._name_id]
	end
end

function HuskPlayerMovement:_equipped_weapon_tweak_data()
	local equipped_weapon = self:_equipped_weapon_base()

	if equipped_weapon and equipped_weapon.non_npc_name_id then
		local weapon_id = equipped_weapon:non_npc_name_id()

		if tweak_data.animation.animation_redirects[weapon_id] then
			weapon_id = tweak_data.animation.animation_redirects[weapon_id]
		end

		return tweak_data.weapon[weapon_id]
	end
end

HuskPlayerMovement.reload_time_fps = 30
HuskPlayerMovement.reload_times = {
	default = 2,
	rifle = 83 / HuskPlayerMovement.reload_time_fps,
	pistol = 46 / HuskPlayerMovement.reload_time_fps,
	shotgun = 83 / HuskPlayerMovement.reload_time_fps,
	bullpup = 74 / HuskPlayerMovement.reload_time_fps,
	uzi = 70 / HuskPlayerMovement.reload_time_fps,
	akimbo_pistol = 35 / HuskPlayerMovement.reload_time_fps
}
HuskPlayerMovement.str_is_shotgun_pump = "is_shotgun_pump"
HuskPlayerMovement.str_looped = "looped"

function HuskPlayerMovement:get_reload_animation_time(hold_type)
	if not hold_type then
		return self.reload_times.default
	end

	if type(hold_type) == "table" then
		for _, hold in ipairs(hold_type) do
			if self.reload_times[hold] then
				return self.reload_times[hold], hold
			end
		end

		return self.reload_times.default
	elseif self.reload_times[hold_type] then
		return self.reload_times[hold_type], hold_type
	else
		Application:stack_dump_error("No reload animation time found for hold type!", hold_type)

		return self.reload_times.default
	end
end

function HuskPlayerMovement:is_looped_reload(crew_tweak)
	if crew_tweak then
		return crew_tweak.usage == HuskPlayerMovement.str_is_shotgun_pump or crew_tweak.reload == HuskPlayerMovement.str_looped
	end

	return false
end

function HuskPlayerMovement:sync_reload_weapon(empty_reload, reload_speed_multiplier)
	local anim_multiplier = 1
	local anim_redirect = "reload"
	local anim_hold_type, anim_reload_type = nil

	self._arm_animator:set_state_blocked("reload", true)

	self._reload_speed_multiplier = reload_speed_multiplier
	local w_td = self:_equipped_weapon_tweak_data()
	local w_td_crew = self:_equipped_weapon_crew_tweak_data() or {}

	if w_td then
		if w_td_crew.hold == "bow" then
			return
		end

		local reload_anim_time, hold_type = self:get_reload_animation_time(w_td_crew.hold)
		local reload_time = 1
		local timers = w_td.timers
		local looped_reload = self:is_looped_reload(w_td_crew)

		if looped_reload then
			anim_redirect = "reload_looped_start"
		else
			if empty_reload == 1 then
				reload_time = timers.reload_empty
			else
				reload_time = timers.reload_not_empty
			end

			reload_time = (reload_time or 1) / (reload_speed_multiplier or 1)
			anim_multiplier = reload_anim_time / reload_time
		end

		if hold_type then
			anim_hold_type = "hold_" .. hold_type
		end

		if not looped_reload then
			if w_td_crew.reload then
				anim_reload_type = "reload_" .. w_td_crew.reload
			elseif hold_type then
				anim_reload_type = "reload_" .. hold_type
			end
		end
	else
		local equipped_weapon = self:_equipped_weapon_base()

		if equipped_weapon and equipped_weapon.non_npc_name_id then
			Application:error("No weapon tweak_data for weapon with id: ", equipped_weapon:non_npc_name_id())
		end
	end

	local redir_res = self:play_redirect(anim_redirect)

	if redir_res then
		self._machine:set_speed(redir_res, anim_multiplier)

		if anim_hold_type then
			self._machine:set_parameter(redir_res, anim_hold_type, 1)

			self._last_anim_hold_type = anim_hold_type
		end

		if anim_reload_type then
			self._machine:set_parameter(redir_res, anim_reload_type, 1)
		end

		self._reload_anim_type = anim_reload_type or anim_hold_type
	end
end

function HuskPlayerMovement:anim_clbk_start_reload_looped()
	local anim_multiplier = 1
	local w_td_crew = self:_equipped_weapon_crew_tweak_data() or {}

	if w_td_crew then
		anim_multiplier = w_td_crew.looped_reload_speed or 1
		anim_multiplier = anim_multiplier * (self._reload_speed_multiplier or 1)
	end

	local redir_res = self:play_redirect("reload_looped")

	if redir_res then
		self._machine:set_speed(redir_res, anim_multiplier)

		if self._last_anim_hold_type then
			self._machine:set_parameter(redir_res, self._last_anim_hold_type, 1)
		end
	end
end

function HuskPlayerMovement:sync_reload_weapon_interupt()
	self._arm_animator:set_state_blocked("reload", false)

	if self._ext_anim.reload then
		local w_td_crew = self:_equipped_weapon_crew_tweak_data() or {}

		if self:is_looped_reload(w_td_crew) then
			local redir_res = self:play_redirect("reload_looped_exit")

			if redir_res and self._last_anim_hold_type then
				self._machine:set_parameter(redir_res, self._last_anim_hold_type, 1)

				self._last_anim_hold_type = nil
			end
		end
	end

	if alive(self._magazine_unit) then
		self._magazine_unit:set_slot(0)

		self._magazine_unit = nil
	end
end

HuskPlayerMovement.magazine_collisions = {
	small = {
		Idstring("units/payday2/weapons/box_collision/box_collision_small_pistol"),
		Idstring("rp_box_collision_small")
	},
	medium = {
		Idstring("units/payday2/weapons/box_collision/box_collision_medium_ar"),
		Idstring("rp_box_collision_medium")
	},
	large = {
		Idstring("units/payday2/weapons/box_collision/box_collision_large_metal"),
		Idstring("rp_box_collision_large")
	},
	pistol = {
		Idstring("units/payday2/weapons/box_collision/box_collision_small_pistol"),
		Idstring("rp_box_collision_small")
	},
	smg = {
		Idstring("units/payday2/weapons/box_collision/box_collision_small_smg"),
		Idstring("rp_box_collision_small")
	},
	rifle = {
		Idstring("units/payday2/weapons/box_collision/box_collision_medium_ar"),
		Idstring("rp_box_collision_medium")
	},
	large_plastic = {
		Idstring("units/payday2/weapons/box_collision/box_collision_large_plastic"),
		Idstring("rp_box_collision_large")
	},
	large_metal = {
		Idstring("units/payday2/weapons/box_collision/box_collision_large_metal"),
		Idstring("rp_box_collision_large")
	}
}

function HuskPlayerMovement:_material_config_name(part_id, unit_name, use_cc_material_config)
	local unit_name = tweak_data.weapon.factory.parts[part_id].unit

	if use_cc_material_config and tweak_data.weapon.factory.parts[part_id].cc_thq_material_config then
		return tweak_data.weapon.factory.parts[part_id].cc_thq_material_config
	end

	if tweak_data.weapon.factory.parts[part_id].thq_material_config then
		return tweak_data.weapon.factory.parts[part_id].thq_material_config
	end

	local cc_string = use_cc_material_config and "_cc" or ""
	local thq_string = "_thq" or ""

	return Idstring(unit_name .. cc_string .. thq_string)
end

function HuskPlayerMovement:allow_dropped_magazines()
	return managers.weapon_factory:use_thq_weapon_parts()
end

local material_defaults = {
	diffuse_layer1_texture = Idstring("units/payday2_cash/safes/default/base_gradient/base_default_df"),
	diffuse_layer2_texture = Idstring("units/payday2_cash/safes/default/pattern_gradient/gradient_default_df"),
	diffuse_layer0_texture = Idstring("units/payday2_cash/safes/default/pattern/pattern_default_df"),
	diffuse_layer3_texture = Idstring("units/payday2_cash/safes/default/sticker/sticker_default_df")
}
local material_textures = {
	pattern = "diffuse_layer0_texture",
	sticker = "diffuse_layer3_texture",
	pattern_gradient = "diffuse_layer2_texture",
	base_gradient = "diffuse_layer1_texture"
}
local material_variables = {
	cubemap_pattern_control = "cubemap_pattern_control",
	pattern_pos = "pattern_pos",
	uv_scale = "uv_scale",
	uv_offset_rot = "uv_offset_rot",
	pattern_tweak = "pattern_tweak"
}

function HuskPlayerMovement:_spawn_magazine_unit(part_id, unit_name, pos, rot)
	local equipped_weapon = self._unit:inventory():equipped_unit()
	local is_thq = managers.weapon_factory:use_thq_weapon_parts()
	local use_cc_material_config = is_thq and equipped_weapon and equipped_weapon:base()._cosmetics_data and true or false
	local material_config_ids = Idstring("material_config")
	local magazine_unit = World:spawn_unit(unit_name, pos, rot)
	local new_material_config_ids = self:_material_config_name(part_id, magazine_unit, use_cc_material_config)

	if magazine_unit:material_config() ~= new_material_config_ids and DB:has(material_config_ids, new_material_config_ids) then
		magazine_unit:set_material_config(new_material_config_ids, true)
	end

	local materials = {}
	local unit_materials = magazine_unit:get_objects_by_type(Idstring("material")) or {}

	for _, m in ipairs(unit_materials) do
		if m:variable_exists(Idstring("wear_tear_value")) then
			table.insert(materials, m)
		end
	end

	local textures = {}
	local base_variable, base_texture, mat_variable, mat_texture, type_variable, type_texture, p_type, custom_variable, texture_key = nil
	local cosmetics_data = equipped_weapon:base():get_cosmetics_data()
	local cosmetics_quality = equipped_weapon:base()._cosmetics_quality
	local wear_tear_value = cosmetics_quality and tweak_data.economy.qualities[cosmetics_quality] and tweak_data.economy.qualities[cosmetics_quality].wear_tear_value or 1

	for _, material in pairs(materials) do
		material:set_variable(Idstring("wear_tear_value"), wear_tear_value)

		p_type = managers.weapon_factory:get_type_from_part_id(part_id)

		for key, variable in pairs(material_variables) do
			mat_variable = cosmetics_data.parts and cosmetics_data.parts[part_id] and cosmetics_data.parts[part_id][material:name():key()] and cosmetics_data.parts[part_id][material:name():key()][key]
			type_variable = cosmetics_data.types and cosmetics_data.types[p_type] and cosmetics_data.types[p_type][key]
			base_variable = cosmetics_data[key]

			if mat_variable or type_variable or base_variable then
				material:set_variable(Idstring(variable), mat_variable or type_variable or base_variable)
			end
		end

		for key, material_texture in pairs(material_textures) do
			mat_texture = cosmetics_data.parts and cosmetics_data.parts[part_id] and cosmetics_data.parts[part_id][material:name():key()] and cosmetics_data.parts[part_id][material:name():key()][key]
			type_texture = cosmetics_data.types and cosmetics_data.types[p_type] and cosmetics_data.types[p_type][key]
			base_texture = cosmetics_data[key]
			local texture_name = mat_texture or type_texture or base_texture

			if texture_name then
				if type_name(texture_name) ~= "Idstring" then
					texture_name = Idstring(texture_name)
				end

				Application:set_material_texture(material, Idstring(material_texture), texture_name, Idstring("normal"))
			end
		end
	end

	return magazine_unit
end

function HuskPlayerMovement:_set_unit_bullet_objects_visible(unit, bullet_objects, visible)
	if bullet_objects then
		local prefix = bullet_objects.prefix

		for i = 1, bullet_objects.amount, 1 do
			local object = unit:get_object(Idstring(prefix .. i))

			if object then
				object:set_visibility(visible)
			end
		end
	end
end

function HuskPlayerMovement:anim_clbk_show_magazine_in_hand(unit, name)
	if not self:allow_dropped_magazines() then
		return
	end

	self:destroy_magazine_in_hand()

	local w_td_crew = self:_equipped_weapon_crew_tweak_data()

	if not w_td_crew or not w_td_crew.pull_magazine_during_reload then
		return
	end

	local equipped_weapon = self._unit:inventory():equipped_unit()

	if alive(equipped_weapon) then
		if not equipped_weapon:base()._assembly_complete then
			return
		end

		for part_id, part_data in pairs(equipped_weapon:base()._parts) do
			local part = tweak_data.weapon.factory.parts[part_id]

			if part and part.type == "magazine" then
				part_data.unit:set_visible(false)

				self._magazine_data = {
					id = part_id,
					name = part_data.name,
					bullets = part.bullet_objects,
					weapon_data = w_td_crew,
					part_unit = part_data.unit,
					unit = self:_spawn_magazine_unit(part_id, part_data.name, part_data.unit:position(), part_data.unit:rotation())
				}

				self:_set_unit_bullet_objects_visible(self._magazine_data.unit, part.bullet_objects, false)
				self._unit:link((not self._primary_hand or self._primary_hand == 0) and Idstring("LeftHandMiddle2") or Idstring("RightHandMiddle2"), self._magazine_data.unit)

				break
			end
		end
	end
end

function HuskPlayerMovement:anim_clbk_spawn_dropped_magazine()
	if not self:allow_dropped_magazines() then
		return
	end

	local equipped_weapon = self._unit:inventory():equipped_unit()

	if alive(equipped_weapon) and not equipped_weapon:base()._assembly_complete then
		return
	end

	local ref_unit = nil
	local allow_throw = true

	if not self._magazine_data then
		local w_td_crew = self:_equipped_weapon_crew_tweak_data()

		if not w_td_crew or not w_td_crew.pull_magazine_during_reload then
			return
		end

		local attach_bone = (not self._primary_hand or self._primary_hand == 0) and Idstring("LeftHandMiddle2") or Idstring("RightHandMiddle2")
		local bone_hand = self._unit:get_object(attach_bone)

		self:anim_clbk_show_magazine_in_hand()

		if bone_hand then
			mvec3_set(tmp_vec1, self._magazine_data.unit:position())
			mvec3_sub(tmp_vec1, self._magazine_data.unit:oobb():center())
			mvec3_add(tmp_vec1, bone_hand:position())
			self._magazine_data.unit:set_position(tmp_vec1)
		end

		ref_unit = self._magazine_data.part_unit
		allow_throw = false
	end

	if self._magazine_data and alive(self._magazine_data.unit) then
		ref_unit = ref_unit or self._magazine_data.unit

		self._magazine_data.unit:set_visible(false)

		local pos = ref_unit:position()
		local rot = ref_unit:rotation()
		local dropped_mag = self:_spawn_magazine_unit(self._magazine_data.id, self._magazine_data.name, pos, rot)

		self:_set_unit_bullet_objects_visible(dropped_mag, self._magazine_data.bullets, false)

		local mag_size = self._magazine_data.weapon_data.pull_magazine_during_reload

		if type(mag_size) ~= "string" then
			mag_size = "medium"
		end

		mvec3_set(tmp_vec1, ref_unit:oobb():center())
		mvec3_sub(tmp_vec1, pos)
		mvec3_set(tmp_vec2, pos)
		mvec3_add(tmp_vec2, tmp_vec1)

		local dropped_col = World:spawn_unit(HuskPlayerMovement.magazine_collisions[mag_size][1], tmp_vec2, rot)

		dropped_col:link(HuskPlayerMovement.magazine_collisions[mag_size][2], dropped_mag)

		if allow_throw then
			if self._left_hand_direction then
				local throw_force = 10

				mvec3_set(tmp_vec1, self._left_hand_direction)
				mvec3_mul(tmp_vec1, self._left_hand_velocity or 3)
				mvec3_mul(tmp_vec1, math.random(25, 45))
				mvec3_mul(tmp_vec1, -1)
				dropped_col:push(throw_force, tmp_vec1)
			end
		else
			local throw_force = 10
			local _t = (self._reload_speed_multiplier or 1) - 1

			mvec3_set(tmp_vec1, equipped_weapon:rotation():z())
			mvec3_mul(tmp_vec1, math.lerp(math.random(65, 80), math.random(140, 160), _t))
			mvec3_mul(tmp_vec1, math.random() < 0.0005 and 10 or -1)
			dropped_col:push(throw_force, tmp_vec1)
		end

		managers.enemy:add_magazine(dropped_mag, dropped_col)
	end
end

function HuskPlayerMovement:anim_clbk_show_new_magazine_in_hand(unit, name)
	if not self:allow_dropped_magazines() then
		return
	end

	local equipped_weapon = self._unit:inventory():equipped_unit()

	if alive(equipped_weapon) and not equipped_weapon:base()._assembly_complete then
		return
	end

	if self._magazine_data and alive(self._magazine_data.unit) then
		self._magazine_data.unit:set_visible(true)

		local equipped_weapon = self._unit:inventory():equipped_unit()

		if alive(equipped_weapon) then
			for part_id, part_data in pairs(equipped_weapon:base()._parts) do
				local part = tweak_data.weapon.factory.parts[part_id]

				if part and part.type == "magazine" then
					self:_set_unit_bullet_objects_visible(self._magazine_data.unit, part.bullet_objects, true)
				end
			end
		end
	end
end

function HuskPlayerMovement:anim_clbk_hide_magazine_in_hand()
	self._arm_animator:set_state_blocked("reload", false)

	if not self:allow_dropped_magazines() then
		return
	end

	local equipped_weapon = self._unit:inventory():equipped_unit()

	if alive(equipped_weapon) and not equipped_weapon:base()._assembly_complete then
		return
	end

	local equipped_weapon = self._unit:inventory():equipped_unit()

	if alive(equipped_weapon) then
		for part_id, part_data in pairs(equipped_weapon:base()._parts) do
			local part = tweak_data.weapon.factory.parts[part_id]

			if part and part.type == "magazine" then
				part_data.unit:set_visible(true)
			end
		end
	end

	self:destroy_magazine_in_hand()
end

function HuskPlayerMovement:destroy_magazine_in_hand()
	if self._magazine_data then
		if alive(self._magazine_data.unit) then
			self._magazine_data.unit:set_slot(0)
		end

		self._magazine_data = nil
	end
end

function HuskPlayerMovement:_play_weapon_reload_animation_sfx(unit, event)
	if self:allow_dropped_magazines() then
		local equipped_weapon = self._unit:inventory():equipped_unit()

		if alive(equipped_weapon) then
			local ss = SoundDevice:create_source("reload")

			ss:set_position(equipped_weapon:position())
			ss:post_event(event)
		end
	end
end

HuskPlayerMovement.switch_weapon_times = {
	cbt = {
		equip = 0.8,
		unequip = 0.4666666666666667
	}
}

function HuskPlayerMovement:_can_play_weapon_switch_anim()
	local blocked_by_vehicle = self._vehicle and not self._vehicle_allows_shooting

	if self:downed() or self._ext_anim.bleedout or self._ext_anim.bleedout_falling or blocked_by_vehicle then
		return false
	end

	return true
end

function HuskPlayerMovement:sync_switch_weapon(unequip_multiplier, equip_multiplier)
	print("self:_can_play_weapon_switch_anim ", self:_can_play_weapon_switch_anim())

	if not self:_can_play_weapon_switch_anim() then
		return
	end

	self._switch_weapon_multipliers = {
		unequip = unequip_multiplier or 1,
		equip = equip_multiplier or 1
	}
	local redir_res = self:play_redirect("switch_weapon_enter")

	if redir_res then
		local anim_multiplier = 1
		local w_td = self:_equipped_weapon_tweak_data()

		if w_td then
			local unequip_time = w_td.timers.unequip / (self._switch_weapon_multipliers.unequip or 1)
			anim_multiplier = self.switch_weapon_times.cbt.unequip / unequip_time
		end

		self._machine:set_speed(redir_res, anim_multiplier)
	end

	self:destroy_magazine_in_hand()
end

function HuskPlayerMovement:anim_clbk_switch_weapon()
end

function HuskPlayerMovement:sync_equip_weapon()
	print("self:_can_play_weapon_switch_anim ", self:_can_play_weapon_switch_anim())

	if not self:_can_play_weapon_switch_anim() then
		return
	end

	if not self._switch_weapon_multipliers then
		self._switch_weapon_multipliers = {
			equip = 1,
			unequip = 1
		}
	end

	local redir_res = self:play_redirect("switch_weapon_exit")

	if redir_res then
		local anim_multiplier = 1
		local w_td = self:_equipped_weapon_tweak_data()

		if w_td then
			local equip_time = w_td.timers.equip / (self._switch_weapon_multipliers.equip or 1)
			anim_multiplier = self.switch_weapon_times.cbt.equip / equip_time
		end

		self._machine:set_speed(redir_res, anim_multiplier)
	end
end

function HuskPlayerMovement:sync_pose(pose_code)
	self:_change_pose(pose_code)
end

function HuskPlayerMovement:_change_stance(stance_code, delayed_shot)
	if self._stance.code and self._stance.code == stance_code then
		return
	end

	local stance = self._stance
	local end_values = {
		0,
		0,
		0,
		[stance_code] = 1
	}
	stance.code = stance_code
	stance.name = self._stance_names[stance_code]
	local start_values = {}

	for _, value in ipairs(stance.values) do
		table.insert(start_values, value)
	end

	local delay = stance.blend[stance_code]

	if delayed_shot then
		delay = delay * 0.3
	end

	local t = TimerManager:game():time()
	local transition = {
		end_values = end_values,
		start_values = start_values,
		duration = delay,
		start_t = t,
		next_upd_t = t + 0.07,
		delayed_shot = delayed_shot
	}
	stance.transition = transition
end

function HuskPlayerMovement:_get_pose_redirect(pose_code)
	return pose_code == 1 and "stand" or pose_code == 3 and "prone" or "crouch"
end

function HuskPlayerMovement:_change_pose(pose_code)
	local redirect = self:_get_pose_redirect(pose_code)
	self._pose_code = pose_code

	if self._ext_anim[redirect] then
		return
	end

	if self._load_data then
		return
	end

	local enter_t = nil
	local move_side = self._ext_anim.move_side

	if move_side then
		local seg_rel_t = self._machine:segment_relative_time(self._ids_base)
		local speed = self._ext_anim.run and "run" or "walk"
		local pose = self._ext_anim.pose
		local stance = self._stance.name

		if not self._walk_anim_lengths[pose] or not self._walk_anim_lengths[pose][stance] or not self._walk_anim_lengths[pose][stance][speed] or not self._walk_anim_lengths[pose][stance][speed][move_side] then
			debug_pause_unit(self._unit, "[HuskPlayerMovement:_change_pose] Boom...", self._unit, "pose", pose, "stance", stance, "speed", speed, "move_side", move_side, self._machine:segment_state(self._ids_base))

			return
		end

		local walk_anim_length = self._walk_anim_lengths[self._ext_anim.pose][self._stance.name][speed][move_side]
		enter_t = seg_rel_t * walk_anim_length
	end

	self:play_redirect(redirect, enter_t)
end

function HuskPlayerMovement:sync_movement_state(state, down_time)
	self._state_redirects = self._state_redirects or {
		jerry1 = "freefall",
		jerry2 = "parachute"
	}
	state = self._state_redirects[state] or state
	local previous_state = self._state
	self._state = state

	self:clear_movement_updator()
	self:clear_attention_updator()
	self:_cleanup_previous_state(previous_state)

	local func = "_sync_movement_state_" .. state

	if self[func] then
		local event_descriptor = {
			previous_state = previous_state,
			down_time = down_time
		}

		self[func](self, event_descriptor)
	else
		Application:error("No husk function for state ", func, "!")
	end
end

function HuskPlayerMovement:_sync_movement_state_standard(event_descriptor)
	if self:need_revive() then
		self:sync_action_walk_nav_point(nil, nil, "exit_bleedout", sync_action_force_and_execute)
	end

	self._arm_animator:clear_state_blocked()
	self:refresh_primary_hand()
	self:set_need_revive(false)
	self:set_need_assistance(false)
	managers.hud:set_mugshot_normal(self._unit:unit_data().mugshot_id)

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self._unit:set_slot(3)

	if Network:is_server() then
		managers.groupai:state():on_player_weapons_hot()
	end

	managers.groupai:state():on_criminal_recovered(self._unit)

	local previous_state = event_descriptor.previous_state
	local is_clean = self.clean_states[self._state]

	if self.clean_states[previous_state] and not is_clean then
		local redir_res = self:play_redirect("equip")

		if redir_res then
			local weapon = self._unit:inventory():equipped_unit()

			if weapon then
				self._unit:inventory():show_equipped_unit()

				local weap_tweak = weapon:base():weapon_tweak_data()

				if type(weap_tweak.hold) == "table" then
					local num = #weap_tweak.hold + 1

					for i, hold_type in ipairs(weap_tweak.hold) do
						self._machine:set_parameter(redir_res, "to_" .. hold_type, num - i)
					end
				else
					self._machine:set_parameter(redir_res, "to_" .. weap_tweak.hold, 1)
				end
			end
		end
	end

	self._unit:inventory():set_visibility_state(not is_clean)

	if not self._ext_anim.stand then
		local redir_res = self:play_redirect("stand")

		if not redir_res then
			self:play_state("std/stand/still/idle/look")
		end
	end
end

function HuskPlayerMovement:_sync_movement_state_carry(event_descriptor)
	self:_sync_movement_state_standard(event_descriptor)
end

function HuskPlayerMovement:_sync_movement_state_mask_off(event_descriptor)
	self:_sync_movement_state_standard(event_descriptor)
end

function HuskPlayerMovement:_sync_movement_state_civilian(event_descriptor)
	self:_sync_movement_state_standard(event_descriptor)
end

function HuskPlayerMovement:_sync_movement_state_clean(event_descriptor)
	self:_sync_movement_state_standard(event_descriptor)
end

function HuskPlayerMovement:_sync_movement_state_bipod(event_descriptor)
	self:_sync_movement_state_standard(event_descriptor)
end

function HuskPlayerMovement:_sync_movement_state_tased(event_descriptor)
	self:play_redirect("tased")
	self._arm_animator:set_state_blocked("tased", true)
	self._unit:set_slot(3)
	self:set_need_revive(false)
	managers.hud:set_mugshot_tased(self._unit:unit_data().mugshot_id)
	managers.groupai:state():on_criminal_disabled(self._unit, "electrified")

	self._tase_effect = World:effect_manager():spawn(self._tase_effect_table)

	self:set_need_assistance(true)

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self:set_attention_updator(self._upd_attention_nothing)
	self:set_movement_updator(self._upd_move_no_animations)
end

function HuskPlayerMovement:_sync_movement_state_bleed_out(event_descriptor)
	self._arm_animator:set_state_blocked("bleed_out", true)
	self._unit:set_slot(3)
	managers.hud:set_mugshot_downed(self._unit:unit_data().mugshot_id)
	managers.groupai:state():on_criminal_disabled(self._unit)
	self._unit:interaction():set_tweak_data("revive")
	self:set_need_revive(true, event_descriptor.down_time)

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self:sync_action_walk_nav_point(nil, nil, "enter_bleedout", sync_action_force_and_execute)
	self:set_attention_updator(self._upd_attention_bleedout)
end

function HuskPlayerMovement:_sync_movement_state_incapacitated(event_descriptor)
	self:_sync_movement_state_fatal(event_descriptor)
end

function HuskPlayerMovement:_sync_movement_state_fatal(event_descriptor)
	self._arm_animator:set_state_blocked("fatal", true)
	self:play_redirect("fatal")
	self._unit:set_slot(5)
	managers.hud:set_mugshot_downed(self._unit:unit_data().mugshot_id)
	managers.groupai:state():on_criminal_neutralized(self._unit)
	self._unit:interaction():set_tweak_data("revive")
	self:set_need_revive(true, event_descriptor.down_time)

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self:set_attention_updator(self._upd_attention_fatal)
	self:set_movement_updator(self._upd_move_no_animations)
end

function HuskPlayerMovement:_sync_movement_state_dead(event_descriptor)
	self._arm_animator:set_state_blocked("dead", true)

	local peer_id = managers.network:session():peer_by_unit(self._unit):id()

	managers.groupai:state():on_player_criminal_death(peer_id)
	self:play_redirect("death")

	if self._atention_on then
		local blend_out_t = 0.15

		self._machine:set_modifier_blend(self._look_modifier_name, blend_out_t)
		self._machine:set_modifier_blend(self._head_modifier_name, blend_out_t)
		self._machine:set_modifier_blend(self._arm_modifier_name, blend_out_t)
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self:set_attention_updator(self._upd_attention_dead)
	self:set_movement_updator(self._upd_move_no_animations)
end

function HuskPlayerMovement:_sync_movement_state_arrested(event_descriptor)
	self._arm_animator:set_state_blocked("arrested", true)
	self:refresh_primary_hand()
	self._unit:set_slot(5)
	managers.hud:set_mugshot_cuffed(self._unit:unit_data().mugshot_id)
	managers.groupai:state():on_criminal_neutralized(self._unit)
	self._unit:interaction():set_tweak_data("free")
	self:set_need_revive(true)

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self:sync_action_walk_nav_point(nil, nil, "enter_arrested", sync_action_force_and_execute)
end

function HuskPlayerMovement:_sync_movement_state_driving(event_descriptor)
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local vehicle_data = managers.player:get_vehicle_for_peer(peer_id)

	if not vehicle_data then
		self._retry_sync_movement_state_driving = true

		return false
	end

	local vehicle_unit = vehicle_data.vehicle_unit
	local vehicle_tweak_data = vehicle_unit:vehicle_driving()._tweak_data
	local animation = vehicle_tweak_data.animations[vehicle_data.seat]
	self._vehicle_allows_shooting = vehicle_tweak_data.seats[vehicle_data.seat].allow_shooting
	self._vehicle = vehicle_unit:vehicle()
	self._driver = false

	if vehicle_data.seat == "driver" then
		self._driver = true

		self._unit:inventory():hide_equipped_unit()
	end

	self._arm_animator:set_state_blocked("driving", true)
	self:play_redirect(animation)

	self.seat_third = vehicle_unit:get_object(Idstring(VehicleDrivingExt.THIRD_PREFIX .. vehicle_data.seat))
	self._sync_look_dir = self._look_dir

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self:set_position(self.seat_third:position())
	self:set_rotation(self.seat_third:rotation())
	self:set_movement_updator(self._upd_move_driving)
	self:set_attention_updator(self._upd_attention_driving)
end

function HuskPlayerMovement:_sync_movement_state_freefall(event_descriptor)
	if not self._ext_anim.freefall then
		self:play_redirect("freefall_fwd")
	end

	self._unit:inventory():hide_equipped_unit()

	self._sync_look_dir = self._look_dir
	self._last_vel_z = 360
	self._terminal_velocity = tweak_data.player.freefall.terminal_velocity
	self._gravity = tweak_data.player.freefall.gravity
	self._damping = tweak_data.player.freefall.gravity / tweak_data.player.freefall.terminal_velocity
	self._anim_name = "freefall"

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self:set_attention_updator(self._upd_attention_freefall)
	self:set_movement_updator(self._upd_move_no_animations)
end

function HuskPlayerMovement:_sync_movement_state_parachute(event_descriptor)
	self._unit:inventory():hide_equipped_unit()
	self:play_redirect("freefall_to_parachute")

	self._sync_look_dir = self._look_dir
	self._terminal_velocity = tweak_data.player.parachute.terminal_velocity
	self._damping = tweak_data.player.parachute.gravity / tweak_data.player.parachute.terminal_velocity
	self._gravity = tweak_data.player.parachute.gravity
	self._anim_name = "parachute"

	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self._parachute_unit = safe_spawn_unit(Idstring("units/pd2_dlc_jerry/props/jry_equipment_parachute/jry_equipment_parachute"), self._unit:position() + Vector3(0, 0, 100), self._unit:rotation())

	self._parachute_unit:damage():run_sequence_simple("animation_unfold")
	self._unit:link(self._unit:orientation_object():name(), self._parachute_unit)
	self:set_attention_updator(self._upd_attention_parachute)
	self:set_movement_updator(self._upd_move_no_animations)
end

function HuskPlayerMovement:on_cuffed()
	self._unit:network():send_to_unit({
		"sync_player_movement_state",
		self._unit,
		"arrested",
		0,
		self._unit:id()
	})
end

function HuskPlayerMovement:on_uncovered(enemy_unit)
	self._unit:network():send_to_unit({
		"suspect_uncovered",
		enemy_unit
	})
end

function HuskPlayerMovement:anim_clbk_footstep(unit)
	CopMovement.anim_clbk_footstep(self, unit, self._m_pos)
end

function HuskPlayerMovement:get_footstep_event()
	return CopMovement.get_footstep_event(self)
end

function HuskPlayerMovement:ground_ray()
end

function HuskPlayerMovement:clbk_inventory_event(unit, event)
	local weapon = self._unit:inventory():equipped_unit()

	if weapon then
		if self.clean_states[self._state] then
			self._unit:inventory():hide_equipped_unit()
		end

		if self._weapon_hold then
			for i, hold_type in ipairs(self._weapon_hold) do
				self._machine:set_global(hold_type, 0)
			end
		end

		if self._weapon_anim_global then
			self._machine:set_global(self._weapon_anim_global, 0)
		end

		self._weapon_hold = {}
		local weap_tweak = weapon:base():weapon_tweak_data()

		if type(weap_tweak.hold) == "table" then
			local num = #weap_tweak.hold + 1

			for i, hold_type in ipairs(weap_tweak.hold) do
				self._machine:set_global(hold_type, self:get_hold_type_weight(hold_type) or num - i)
				table.insert(self._weapon_hold, hold_type)
			end
		else
			self._machine:set_global(weap_tweak.hold, self:get_hold_type_weight(weap_tweak.hold) or 1)
			table.insert(self._weapon_hold, weap_tweak.hold)
		end

		local weapon_usage = weap_tweak.anim_usage or weap_tweak.usage

		if self:arm_animation_enabled() then
			self._arm_animator:set_state_blocked("bow", weapon_usage == "bow")
			self:refresh_primary_hand()
		end

		self._machine:set_global(weapon_usage, 1)

		self._weapon_anim_global = weapon_usage

		if self:_can_play_weapon_switch_anim() then
			self:play_state("std/stand/still/idle/look")
		end

		if self:arm_animation_enabled() then
			weapon:base():apply_grip(true)

			if self._ext_anim.melee then
				if weapon:base().AKIMBO then
					weapon:base():on_melee_item_shown(self._use_primary_melee_hand or false)
				elseif self._use_primary_melee_hand then
					weapon:base():on_disabled()
				end
			end
		end
	end
end

function HuskPlayerMovement:get_hold_type_weight(hold)
	if tweak_data.animation.hold_types[hold] then
		return tweak_data.animation.hold_types[hold].weight
	else
		return false
	end
end

function HuskPlayerMovement:current_state_name()
	return self._state
end

function HuskPlayerMovement:tased()
	return self._state == "tased"
end

function HuskPlayerMovement:on_death_exit()
end

function HuskPlayerMovement:load(data)
	self.update = HuskPlayerMovement._post_load
	self._load_data = data

	if data.movement.attentions then
		for _, setting_index in ipairs(data.movement.attentions) do
			local setting_name = tweak_data.attention:get_attention_name(setting_index)

			self:set_attention_setting_enabled(setting_name, true)
		end
	end

	self._team = managers.groupai:state():team_data(data.movement.team_id)
end

function HuskPlayerMovement:_post_load(unit, t, dt)
	if not managers.network:session() then
		return
	end

	local peer = managers.network:session():peer(self._load_data.movement.peer_id)

	if peer then
		local data = self._load_data
		self.update = nil
		self._load_data = nil
		local my_data = data.movement

		if not my_data then
			return
		end

		peer:set_outfit_string(my_data.outfit, my_data.outfit_version)
		UnitNetworkHandler.set_unit(UnitNetworkHandler, unit, my_data.character_name, my_data.outfit, my_data.outfit_version, my_data.peer_id, nil, data.visual_state and data.visual_state.visual_seed)

		if managers.network:session():peer_by_unit(unit) == nil then
			Application:error("[HuskPlayerBase:_post_load] A player husk who appears to not have an owning member was detached.")
			Network:detach_unit(unit)
			unit:set_slot(0)

			return
		end

		self:sync_movement_state(my_data.state_name, data.down_time)
		self:sync_pose(my_data.pose)

		if my_data.stance then
			self:sync_stance(my_data.stance)
		end

		local unit_rot = Rotation(my_data.look_fwd:with_z(0), math.UP)

		self:set_rotation(unit_rot)
		self:set_look_dir_instant(my_data.look_fwd)

		if data.zip_line_unit_id then
			self:on_enter_zipline(managers.worlddefinition:get_unit_on_load(data.zip_line_unit_id, callback(self, self, "on_enter_zipline")))
		end
	end
end

function HuskPlayerMovement:save(data)
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local character = managers.criminals:character_by_unit(self._unit)
	data.movement = {
		state_name = self._state,
		look_fwd = self:detect_look_dir(),
		pose = self._pose_code,
		stance = self._stance.code,
		peer_id = peer_id,
		visual_seed = character and character.visual_state and character.visual_state.visual_seed,
		character_name = character and character.name,
		outfit = managers.network:session():peer(peer_id):profile("outfit_string")
	}
	data.zip_line_unit_id = self:zipline_unit() and self:zipline_unit():editor_id()
	data.down_time = self._last_down_time
end

function HuskPlayerMovement:pre_destroy(unit)
	if self._pos_reservation then
		managers.navigation:unreserve_pos(self._pos_reservation)
		managers.navigation:unreserve_pos(self._pos_reservation_slow)

		self._pos_reservation = nil
		self._pos_reservation_slow = nil
	end

	self:set_need_revive(false)
	self:set_need_assistance(false)
	self._attention_handler:set_attention(nil)

	if self._nav_tracker then
		managers.navigation:destroy_nav_tracker(self._nav_tracker)

		self._nav_tracker = nil
	end

	if self._enemy_weapons_hot_listen_id then
		managers.groupai:state():remove_listener(self._enemy_weapons_hot_listen_id)

		self._enemy_weapons_hot_listen_id = nil
	end

	self:anim_cbk_unspawn_melee_item()
	self:_destroy_current_carry_unit()
end

function HuskPlayerMovement:set_attention_setting_enabled(setting_name, state)
	return PlayerMovement.set_attention_setting_enabled(self, setting_name, state, false)
end

function HuskPlayerMovement:clbk_attention_notice_sneak(observer_unit, status)
	return PlayerMovement.clbk_attention_notice_sneak(self, observer_unit, status)
end

function HuskPlayerMovement:_create_attention_setting_from_descriptor(setting_desc, setting_name)
	return PlayerMovement._create_attention_setting_from_descriptor(self, setting_desc, setting_name)
end

function HuskPlayerMovement:attention_handler()
	return self._attention_handler
end

function HuskPlayerMovement:_feed_suspicion_to_hud()
end

function HuskPlayerMovement:_apply_attention_setting_modifications(setting)
	setting.detection = self._unit:base():detection_settings()
	local weight_mul = self._unit:base():upgrade_value("player", "camouflage_bonus") or 1
	weight_mul = weight_mul * (self._unit:base():upgrade_value("player", "camouflage_multiplier") or 1)
	weight_mul = weight_mul * (self._unit:base():upgrade_value("player", "uncover_multiplier") or 1)

	if weight_mul and weight_mul ~= 1 then
		setting.weight_mul = (setting.weight_mul or 1) * weight_mul
	end
end

function HuskPlayerMovement:sync_call_civilian(civilian_unit)
	if not self._sympathy_civ and civilian_unit:brain():is_available_for_assignment({
		type = "revive"
	}) then
		local followup_objective = {
			interrupt_health = 1,
			interrupt_dis = -1,
			type = "free",
			action = {
				sync = true,
				body_part = 1,
				type = "idle"
			}
		}
		local objective = {
			type = "act",
			haste = "run",
			destroy_clbk_key = false,
			nav_seg = self:nav_tracker():nav_segment(),
			pos = self:nav_tracker():field_position(),
			fail_clbk = callback(self, self, "on_civ_revive_failed"),
			complete_clbk = callback(self, self, "on_civ_revive_completed"),
			action_start_clbk = callback(self, self, "on_civ_revive_started"),
			action = {
				align_sync = true,
				type = "act",
				body_part = 1,
				variant = "revive",
				blocks = {
					light_hurt = -1,
					hurt = -1,
					action = -1,
					heavy_hurt = -1,
					aim = -1,
					walk = -1
				}
			},
			action_duration = tweak_data.interaction.revive.timer,
			followup_objective = followup_objective
		}
		self._sympathy_civ = civilian_unit

		civilian_unit:brain():set_objective(objective)
	end
end

function HuskPlayerMovement:on_civ_revive_started(sympathy_civ)
	if self._unit:interaction():active() then
		self._unit:interaction():interact_start(sympathy_civ)
	end

	if self._revive_rescuer then
		local rescuer = self._revive_rescuer
		self._revive_rescuer = nil

		rescuer:brain():set_objective(nil)
	elseif self._revive_SO_id then
		managers.groupai:state():remove_special_objective(self._revive_SO_id)

		self._revive_SO_id = nil
	end
end

function HuskPlayerMovement:on_civ_revive_failed(sympathy_civ)
	if self._sympathy_civ then
		self._sympathy_civ = nil
	end
end

function HuskPlayerMovement:on_civ_revive_completed(sympathy_civ)
	if sympathy_civ ~= self._sympathy_civ then
		debug_pause_unit(sympathy_civ, "[HuskPlayerMovement:on_civ_revive_completed] idiot thinks he is reviving", sympathy_civ)

		return
	end

	self._sympathy_civ = nil

	if self._unit:interaction():active() then
		self._unit:interaction():interact(sympathy_civ)
	end

	self:_unregister_revive_SO()

	if self._unit:base():upgrade_value("player", "civilian_gives_ammo") then
		managers.game_play_central:spawn_pickup({
			name = "ammo",
			position = sympathy_civ:position(),
			rotation = Rotation()
		})
	end
end

function HuskPlayerMovement:sync_stance(stance_code)
	self._stance.owner_stance_code = stance_code

	self:_chk_change_stance()
end

function HuskPlayerMovement:_chk_change_stance()
	local wanted_stance_code = nil

	if self.clean_states[self._state] then
		wanted_stance_code = self._stance.owner_stance_code
	elseif self._is_weapon_gadget_on then
		wanted_stance_code = 3
	elseif self._aim_up_expire_t then
		wanted_stance_code = 3
	else
		wanted_stance_code = self._stance.owner_stance_code
	end

	if wanted_stance_code ~= self._stance.code then
		self:_change_stance(wanted_stance_code)
	end
end

function HuskPlayerMovement:sync_action_change_run(is_running)
	self._running = is_running
end

function HuskPlayerMovement:sync_action_change_speed(speed)
	self._synced_max_speed = speed
end

function HuskPlayerMovement:gravity()
	if self._state == "parachute" then
		return tweak_data.player.parachute.gravity
	elseif self._state == "freefall" then
		return tweak_data.player.freefall.gravity
	else
		return tweak_data.player.gravity
	end
end

function HuskPlayerMovement:terminal_velocity()
	if self._state == "parachute" then
		return tweak_data.player.parachute.terminal_velocity
	elseif self._state == "freefall" then
		return tweak_data.player.freefall.terminal_velocity
	else
		return tweak_data.player.terminal_velocity
	end
end

function HuskPlayerMovement:_get_max_move_speed(run)
	local my_tweak = tweak_data.player.movement_state.standard
	local move_speed = nil

	if self._pose_code == 2 then
		move_speed = my_tweak.movement.speed.CROUCHING_MAX * (self._unit:base():upgrade_value("player", "crouch_speed_multiplier") or 1)
	elseif run then
		move_speed = my_tweak.movement.speed.RUNNING_MAX * (self._unit:base():upgrade_value("player", "run_speed_multiplier") or 1)
	else
		move_speed = my_tweak.movement.speed.STANDARD_MAX * (self._unit:base():upgrade_value("player", "walk_speed_multiplier") or 1)
	end

	if self._synced_max_speed then
		move_speed = self._synced_max_speed
	end

	if self._in_air then
		local t = self._air_time or 0
		local air_speed = math.exp(t * self:gravity() / self:terminal_velocity())
		air_speed = air_speed * self:gravity()
		air_speed = math.abs(air_speed)
		move_speed = math.max(move_speed, air_speed)
		move_speed = math.min(move_speed, math.abs(self:terminal_velocity()))
	end

	local zipline = self._zipline and self._zipline.enabled and self._zipline.zipline_unit and self._zipline.zipline_unit:zipline()

	if zipline then
		local step = 100
		local t = math.clamp((self._zipline.t or 0) / zipline:total_time(), 0, 1)
		local speed = 1.1 * zipline:speed_at_time(t, 1 / step) / step
		move_speed = math.max(speed * zipline:speed(), move_speed)
	end

	local path_length = #self._movement_path - tweak_data.network.player_path_interpolation

	if path_length > 0 then
		local speed_boost = 1 + path_length / tweak_data.network.player_tick_rate
		move_speed = move_speed * math.clamp(speed_boost, 1, 3)
	end

	if not self._in_air and not zipline and self:carry_id() then
		local carry_tweak = tweak_data.carry[self:carry_id()]

		if carry_tweak then
			local type_tweak = tweak_data.carry.types[carry_tweak.type]

			if type_tweak and type_tweak.move_speed_modifier and type_tweak.move_speed_modifier < 1 then
				move_speed = move_speed * type_tweak.move_speed_modifier * (1 + type_tweak.move_speed_modifier)
			end
		end
	end

	return move_speed
end

function HuskPlayerMovement:_chk_ground_ray(check_pos, return_ray)
	local mover_radius = 60
	local up_pos = tmp_vec1

	mvec3_set(up_pos, math.UP)
	mvec3_mul(up_pos, 30 + mover_radius * 0.95)
	mvec3_add(up_pos, check_pos or self._m_pos)

	local down_pos = tmp_vec2

	mvec3_set(down_pos, math.UP)
	mvec3_mul(down_pos, -20 + mover_radius * 0.95)
	mvec3_add(down_pos, check_pos or self._m_pos)

	if return_ray then
		return World:raycast("ray", up_pos, down_pos, "slot_mask", self._slotmask_gnd_ray, "sphere_cast_radius", mover_radius, "ray_type", "walk")
	else
		return World:raycast("ray", up_pos, down_pos, "slot_mask", self._slotmask_gnd_ray, "sphere_cast_radius", mover_radius, "ray_type", "walk", "report")
	end
end

function HuskPlayerMovement:_chk_floor_moving_pos(pos)
	local ground_ray = self:_chk_ground_ray(pos, true)

	if ground_ray and ground_ray.body and math.abs(ground_ray.body:velocity().z) > 0 then
		return ground_ray.body:position().z
	end
end

function HuskPlayerMovement:sync_attention_setting(setting_name, state)
	if state then
		local setting_desc = tweak_data.attention.settings[setting_name]

		if setting_desc then
			local setting = self:_create_attention_setting_from_descriptor(setting_desc, setting_name)

			self._unit:movement():attention_handler():add_attention(setting)
		else
			debug_pause_unit(self._unit, "[PlayerMovement:add_attention_setting] invalid setting", setting_name, self._unit)
		end
	else
		self._unit:movement():attention_handler():remove_attention(setting_name)
	end
end

function HuskPlayerMovement:is_SPOOC_attack_allowed()
	if self._unit:character_damage():get_mission_blocker("invulnerable") then
		return false
	end

	if self._vehicle then
		return false
	end

	return true
end

function HuskPlayerMovement:is_taser_attack_allowed()
	if self._unit:character_damage():get_mission_blocker("invulnerable") or self._vehicle then
		return false
	end

	return true
end

function HuskPlayerMovement:on_enter_zipline(zipline_unit)
	local zipline = zipline_unit:zipline()

	if zipline then
		self._zipline = {
			enabled = true,
			type = "zipline",
			zipline_unit = zipline_unit
		}
	end
end

function HuskPlayerMovement:on_exit_zipline()
	if self._atention_on then
		self._machine:forbid_modifier(self._look_modifier_name)
		self._machine:forbid_modifier(self._head_modifier_name)
		self._machine:forbid_modifier(self._arm_modifier_name)
		self._machine:forbid_modifier(self._mask_off_modifier_name)

		self._atention_on = false
	end

	self._look_modifier:set_target_y(self._look_dir)

	local pos = self._zipline.zipline_unit:zipline():end_pos()
	local action = HuskPlayerMovement.action_prerequisites.zipline_end.target_action

	self:sync_action_walk_nav_point(pos, nil, action, sync_action_force)

	self._zipline.enabled = false
end

function HuskPlayerMovement:zipline_unit()
	if self._zipline and self._zipline.zipline_unit then
		return self._zipline.zipline_unit
	end
end

function HuskPlayerMovement:on_exit_vehicle()
	self._arm_animator:set_state_blocked("driving", false)

	self._vehicle = nil

	self._look_modifier:set_target_y(self._look_dir)

	self._vehicle_shooting_stance = PlayerDriving.STANCE_NORMAL

	self._unit:inventory():show_equipped_unit()

	if self._atention_on then
		self._atention_on = false
	end

	self._machine:forbid_modifier(self._look_modifier_name)
	self._machine:forbid_modifier(self._head_modifier_name)
	self._machine:forbid_modifier(self._arm_modifier_name)
	self._machine:forbid_modifier(self._mask_off_modifier_name)
	self:clear_movement_path()
end

function HuskPlayerMovement:sync_vehicle_change_stance(stance)
	local anim = self._machine:segment_state(self._ids_base)

	Application:trace("Current animation", inspect(anim))
	self._machine:set_parameter(anim, "shooting_stance", stance)

	self._vehicle_shooting_stance = stance
end

function HuskPlayerMovement:sync_action_jump(pos, jump_vec)
	self:_override_last_node_action("land", true)
	self:sync_action_walk_nav_point(pos, nil, "jump", sync_action_force)
end

function HuskPlayerMovement:sync_action_teleport(pos)
	self:sync_action_walk_nav_point(nil, nil, "teleport_start", sync_action_force)
	self:sync_action_walk_nav_point(pos, nil, "teleport_end", sync_action_force_and_execute)
end

function HuskPlayerMovement:_cleanup_previous_state(previous_state)
	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	if alive(self._parachute_unit) then
		local position = self._parachute_unit:position()
		local rotation = self._parachute_unit:rotation()

		self._parachute_unit:unlink()
		self._parachute_unit:set_slot(0)
		World:delete_unit(self._parachute_unit)

		self._parachute_unit = nil

		if previous_state == "jerry2" or previous_state == "parachute" then
			local unit = safe_spawn_unit(Idstring("units/pd2_dlc_jerry/props/jry_equipment_parachute/jry_equipment_parachute_ragdoll"), position, rotation)

			unit:damage():run_sequence_simple("make_dynamic")
		end

		self._unit:inventory():show_equipped_unit()
	end
end

function HuskPlayerMovement:anim_clbk_hide_akimbo_weapon()
	if alive(self._unit:inventory():equipped_unit()) and self._unit:inventory():equipped_unit():base().AKIMBO then
		self._unit:inventory():equipped_unit():base():on_melee_item_shown()
	end
end

function HuskPlayerMovement:anim_clbk_show_akimbo_weapon()
	if alive(self._unit:inventory():equipped_unit()) and self._unit:inventory():equipped_unit():base().AKIMBO then
		self._unit:inventory():equipped_unit():base():on_melee_item_hidden()
	end
end

function HuskPlayerMovement:sync_interaction_anim_start(tweak)
	self:destroy_magazine_in_hand()

	self._interaction_tweak = tweak

	if tweak == "revive" then
		self:play_redirect("revive_enter")
	else
		self:play_redirect("interact_enter")
	end
end

function HuskPlayerMovement:sync_interaction_anim_end()
	self:destroy_magazine_in_hand()

	if self._interaction_tweak == "revive" then
		self:play_redirect("revive_exit")
	else
		self:play_redirect("interact_exit")
	end

	self._interaction_tweak = nil
end

HuskPlayerMovement._gadgets = {
	aligns = {
		hand_l = Idstring("a_weapon_left_front"),
		hand_r = Idstring("a_weapon_right_front"),
		head = Idstring("Head")
	},
	needle = {
		Idstring("units/payday2/characters/npc_acc_syringe/npc_acc_syringe")
	}
}

function HuskPlayerMovement:spawn_wanted_items()
	if self._wanted_items then
		for _, spawn_info in ipairs(self._wanted_items) do
			self:_equip_item(unpack(spawn_info))
		end

		self._wanted_items = nil
	end
end

function HuskPlayerMovement:_equip_item(item_type, align_place, droppable)
	local align_name = self._gadgets.aligns[align_place]

	if not align_name then
		print("[HuskPlayerMovement:anim_clbk_equip_item] non existent align place:", align_place)

		return
	end

	local align_obj = self._unit:get_object(align_name)
	local available_items = self._gadgets[item_type]

	if not available_items then
		print("[HuskPlayerMovement:anim_clbk_equip_item] non existent item_type:", item_type)

		return
	end

	local item_name = available_items[math.random(available_items)]
	local item_unit = World:spawn_unit(item_name, align_obj:position(), align_obj:rotation())

	self._unit:link(align_name, item_unit, item_unit:orientation_object():name())

	self._equipped_items = self._equipped_items or {}
	self._equipped_items[align_place] = self._equipped_items[align_place] or {}

	table.insert(self._equipped_items[align_place], item_unit)
end

function HuskPlayerMovement:_destroy_items()
	if not self._equipped_items then
		return
	end

	for align_place, item_list in pairs(self._equipped_items) do
		for _, item_unit in ipairs(item_list) do
			if alive(item_unit) then
				item_unit:set_slot(0)
			end
		end
	end

	self._equipped_items = nil
end

function HuskPlayerMovement:anim_clbk_wanted_item(unit, item_type, align_place, droppable)
	self._wanted_items = self._wanted_items or {}

	if self:arm_animation_enabled() and not self:arm_animation_blocked() and self._primary_hand == 1 then
		align_place = "hand_r"
	end

	table.insert(self._wanted_items, {
		item_type,
		align_place,
		droppable
	})
	self:spawn_wanted_items()
end

function HuskPlayerMovement:anim_clbk_flush_wanted_items()
	self._wanted_items = nil

	self:_destroy_items()
end

function HuskPlayerMovement:is_vr()
	return self._is_vr
end

function HuskPlayerMovement:set_is_vr()
	self._is_vr = true
end
