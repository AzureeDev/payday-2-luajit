CopDamage = CopDamage or class()
CopDamage._all_event_types = {
	"dmg_rcv",
	"light_hurt",
	"hurt",
	"heavy_hurt",
	"death",
	"shield_knock",
	"stun",
	"counter_tased",
	"taser_tased",
	"knock_down",
	"stagger"
}
CopDamage._ATTACK_VARIANTS = {
	"explosion",
	"stun",
	"fire",
	"healed",
	"graze"
}
CopDamage._HEALTH_GRANULARITY = 512
CopDamage.WEAPON_TYPE_GRANADE = 1
CopDamage.WEAPON_TYPE_BULLET = 2
CopDamage.WEAPON_TYPE_FLAMER = 3
CopDamage._ON_STUN_ACCURACY_DECREASE = 0.5
CopDamage._ON_STUN_ACCURACY_DECREASE_TIME = 5
CopDamage.EVENT_IDS = {
	FINAL_LOWER_HEALTH_PERCENTAGE_LIMIT = 1
}
CopDamage.DEBUG_HP = CopDamage.DEBUG_HP or false
CopDamage._event_listeners = EventListenerHolder:new()

function CopDamage.register_listener(key, event_types, clbk)
	CopDamage._event_listeners:add(key, event_types, clbk)
end

function CopDamage.unregister_listener(key)
	CopDamage._event_listeners:remove(key)
end

function CopDamage._notify_listeners(event, ...)
	CopDamage._event_listeners:call(event, ...)
end

function CopDamage.MAD_3_ACHIEVEMENT(attack_data)
	if attack_data.variant ~= "melee" and attack_data.attacker_unit and alive(attack_data.attacker_unit) and not attack_data.attacker_unit:base().tased then
		managers.job:set_memory("mad_3", false)
	end
end

CopDamage._hurt_severities = {
	heavy = "heavy_hurt",
	fire = "fire_hurt",
	poison = "poison_hurt",
	explode = "expl_hurt",
	light = "light_hurt",
	moderate = "hurt",
	none = false
}
CopDamage._impact_bones = {}
local impact_bones_tmp = {
	"Hips",
	"Spine",
	"Spine1",
	"Spine2",
	"Neck",
	"Head",
	"LeftShoulder",
	"LeftArm",
	"LeftForeArm",
	"RightShoulder",
	"RightArm",
	"RightForeArm",
	"LeftUpLeg",
	"LeftLeg",
	"LeftFoot",
	"RightUpLeg",
	"RightLeg",
	"RightFoot"
}

for i, k in ipairs(impact_bones_tmp) do
	local name_ids = Idstring(impact_bones_tmp[i])
	CopDamage._impact_bones[name_ids:key()] = name_ids
end

impact_bones_tmp = nil
local mvec_1 = Vector3()
local mvec_2 = Vector3()

function CopDamage:init(unit)
	self._unit = unit
	local char_tweak = tweak_data.character[unit:base()._tweak_table]
	self._immune_to_knockback = char_tweak.damage.immune_to_knockback
	self._HEALTH_INIT = char_tweak.HEALTH_INIT
	self._HEALTH_INIT = managers.modifiers:modify_value("CopDamage:InitialHealth", self._HEALTH_INIT, unit:base()._tweak_table)
	self._health = self._HEALTH_INIT
	self._health_ratio = 1
	self._HEALTH_INIT_PRECENT = self._HEALTH_INIT / self._HEALTH_GRANULARITY
	self._autotarget_data = {
		fast = unit:get_object(Idstring("Spine1"))
	}

	if not char_tweak.do_not_drop_ammo then
		self._pickup = "ammo"
	end

	self._listener_holder = EventListenerHolder:new()

	if char_tweak.permanently_invulnerable or self.immortal then
		self:set_invulnerable(true)
	end

	self._char_tweak = char_tweak
	self._spine2_obj = unit:get_object(Idstring("Spine2"))

	if self._head_body_name then
		self._ids_head_body_name = Idstring(self._head_body_name)
		self._head_body_key = self._unit:body(self._head_body_name):key()
	end

	self._ids_plate_name = Idstring("body_plate")
	self._has_plate = true
	local body = self._unit:body("mover_blocker")

	if body then
		body:add_ray_type(Idstring("trip_mine"))
	end

	self._last_time_unit_got_fire_damage = nil
	self._last_time_unit_got_fire_effect = nil
	self._temp_flame_redir_res = nil
	self._active_fire_bone_effects = {}

	if CopDamage.DEBUG_HP then
		self:_create_debug_ws()
	end

	self._tase_effect_table = {
		effect = Idstring("effects/payday2/particles/character/taser_hittarget"),
		parent = self._spine2_obj
	}

	self:_set_lower_health_percentage_limit(self._char_tweak.LOWER_HEALTH_PERCENTAGE_LIMIT)

	self._has_been_staggered = false

	local function clbk()
		self._has_been_staggered = false
	end

	managers.player:register_message(Message.ResetStagger, self, clbk)

	self._accuracy_multiplier = 1
end

function CopDamage:is_immune_to_shield_knockback()
	return self._immune_to_knockback
end

function CopDamage:accuracy_multiplier()
	return self._accuracy_multiplier or 1
end

function CopDamage:set_accuracy_multiplier(mul)
	if mul then
		self._accuracy_multiplier = mul
	end
end

function CopDamage:get_last_time_unit_got_fire_damage()
	return self._last_time_unit_got_fire_damage
end

function CopDamage:set_last_time_unit_got_fire_damage(time)
	self._last_time_unit_got_fire_damage = time
end

function CopDamage:get_temp_flame_redir_res()
	return self._temp_flame_redir_res
end

function CopDamage:set_temp_flame_redir_res(value)
	self._temp_flame_redir_res = value
end

function CopDamage:get_damage_type(damage_percent, category)
	local hurt_table = self._char_tweak.damage.hurt_severity[category or "bullet"]
	local dmg = damage_percent / self._HEALTH_GRANULARITY

	if hurt_table.health_reference == "full" then
		-- Nothing
	elseif hurt_table.health_reference == "current" then
		dmg = math.min(1, self._HEALTH_INIT * dmg / self._health)
	else
		dmg = math.min(1, self._HEALTH_INIT * dmg / hurt_table.health_reference)
	end

	local zone = nil

	for i_zone, test_zone in ipairs(hurt_table.zones) do
		if i_zone == #hurt_table.zones or dmg < test_zone.health_limit then
			zone = test_zone

			break
		end
	end

	local rand_nr = math.random()
	local total_w = 0

	for sev_name, hurt_type in pairs(self._hurt_severities) do
		local weight = zone[sev_name]

		if weight and weight > 0 then
			total_w = total_w + weight

			if rand_nr <= total_w then
				return hurt_type or "dmg_rcv"
			end
		end
	end

	return "dmg_rcv"
end

function CopDamage:is_head(body)
	local head = self._head_body_name and body and body:name() == self._ids_head_body_name

	return head
end

function CopDamage:_dismember_body_part(attack_data)
	Application:debug("CopDamage:_dismember_body_part( attack_data )")

	local hit_body_part = attack_data.body_name
	hit_body_part = hit_body_part or attack_data.col_ray.body:name()
	local sound = "split_gen_head"

	if hit_body_part == Idstring("body") then
		sound = "split_gen_body"
	end

	Application:trace("CopDamage:_dismember_body_part( attack_data ) - sound: ", inspect(sound))
	self._unit:sound():play(sound, nil, nil)

	local dismembers = {
		[Idstring("head"):key()] = "dismember_head",
		[Idstring("body"):key()] = "dismember_body_top",
		[Idstring("hit_Head"):key()] = "dismember_head",
		[Idstring("hit_Body"):key()] = "dismember_body_top",
		[Idstring("hit_RightUpLeg"):key()] = "dismember_r_upper_leg",
		[Idstring("hit_LeftUpLeg"):key()] = "dismember_l_upper_leg",
		[Idstring("hit_RightArm"):key()] = "dismember_r_upper_arm",
		[Idstring("hit_LeftArm"):key()] = "dismember_l_upper_arm",
		[Idstring("hit_RightForeArm"):key()] = "dismember_r_lower_arm",
		[Idstring("hit_LeftForeArm"):key()] = "dismember_l_lower_arm",
		[Idstring("hit_RightLeg"):key()] = "dismember_r_lower_leg",
		[Idstring("hit_LeftLeg"):key()] = "dismember_l_lower_leg",
		[Idstring("rag_Head"):key()] = "dismember_head",
		[Idstring("rag_RightUpLeg"):key()] = "dismember_r_upper_leg",
		[Idstring("rag_LeftUpLeg"):key()] = "dismember_l_upper_leg",
		[Idstring("rag_RightArm"):key()] = "dismember_r_upper_arm",
		[Idstring("rag_LeftArm"):key()] = "dismember_l_upper_arm",
		[Idstring("rag_RightForeArm"):key()] = "dismember_r_lower_arm",
		[Idstring("rag_LeftForeArm"):key()] = "dismember_l_lower_arm",
		[Idstring("rag_RightLeg"):key()] = "dismember_r_lower_leg",
		[Idstring("rag_LeftLeg"):key()] = "dismember_l_lower_leg"
	}

	if self._unit:damage():has_sequence(dismembers[hit_body_part:key()]) then
		self._unit:damage():run_sequence_simple(dismembers[hit_body_part:key()])
	end
end

function CopDamage:_check_special_death_conditions(variant, body, attacker_unit, weapon_unit)
	local special_deaths = self._unit:base():char_tweak().special_deaths

	if not special_deaths or not special_deaths[variant] then
		return
	end

	local body_data = special_deaths[variant][body:name():key()]

	if not body_data then
		return
	end

	local attacker_name = managers.criminals:character_name_by_unit(attacker_unit)

	if not body_data.character_name or body_data.character_name ~= attacker_name then
		return
	end

	if body_data.weapon_id and alive(weapon_unit) then
		local factory_id = weapon_unit:base()._factory_id

		if not factory_id then
			return
		end

		if weapon_unit:base():is_npc() then
			factory_id = utf8.sub(factory_id, 1, -5)
		end

		local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)

		if body_data.weapon_id == weapon_id then
			if self._unit:damage():has_sequence(body_data.sequence) then
				self._unit:damage():run_sequence_simple(body_data.sequence)
			end

			if body_data.special_comment and attacker_unit == managers.player:player_unit() then
				return body_data.special_comment
			end
		end
	end
end

function CopDamage:is_friendly_fire(unit)
	if not unit then
		return false
	end

	if unit:movement():team() ~= self._unit:movement():team() and unit:movement():friendly_fire() then
		return false
	end

	return not unit:movement():team().foes[self._unit:movement():team().id]
end

function CopDamage:check_medic_heal()
	if self._unit:anim_data() and self._unit:anim_data().act then
		return false
	end

	local medic = managers.enemy:get_nearby_medic(self._unit)

	return medic and medic:character_damage():heal_unit(self._unit)
end

function CopDamage:damage_bullet(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	if self._has_plate and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_plate_name and not attack_data.armor_piercing then
		local armor_pierce_roll = math.rand(1)
		local armor_pierce_value = 0

		if attack_data.attacker_unit == managers.player:player_unit() and not attack_data.weapon_unit:base().thrower_unit then
			armor_pierce_value = armor_pierce_value + attack_data.weapon_unit:base():armor_piercing_chance()
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("player", "armor_piercing_chance", 0)
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance", 0)
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_2", 0)

			if attack_data.weapon_unit:base():got_silencer() then
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_silencer", 0)
			end

			if attack_data.weapon_unit:base():is_category("saw") then
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("saw", "armor_piercing_chance", 0)
			end
		elseif attack_data.attacker_unit:base() and attack_data.attacker_unit:base().sentry_gun then
			local owner = attack_data.attacker_unit:base():get_owner()

			if alive(owner) then
				if owner == managers.player:player_unit() then
					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("sentry_gun", "armor_piercing_chance", 0)
					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("sentry_gun", "armor_piercing_chance_2", 0)
				else
					armor_pierce_value = armor_pierce_value + (owner:base():upgrade_value("sentry_gun", "armor_piercing_chance") or 0)
					armor_pierce_value = armor_pierce_value + (owner:base():upgrade_value("sentry_gun", "armor_piercing_chance_2") or 0)
				end
			end
		end

		if armor_pierce_roll >= armor_pierce_value then
			return
		end
	end

	local result = nil
	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage

	if self._unit:base():char_tweak().DAMAGE_CLAMP_BULLET then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_BULLET)
	end

	damage = damage * (self._marked_dmg_mul or 1)

	if self._marked_dmg_mul and self._marked_dmg_dist_mul then
		local dst = mvector3.distance(attack_data.origin, self._unit:position())
		local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

		if spott_dst[1] < dst then
			damage = damage * spott_dst[2]
		end
	end

	if self._unit:movement():cool() then
		damage = self._HEALTH_INIT
	end

	local headshot = false
	local headshot_multiplier = 1

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			managers.hud:on_crit_confirmed()

			damage = crit_damage
			attack_data.critical_hit = true
		else
			managers.hud:on_hit_confirmed()
		end

		headshot_multiplier = managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)

		if tweak_data.character[self._unit:base()._tweak_table].priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end

		if head then
			managers.player:on_headshot_dealt()

			headshot = true
		end
	end

	if not self._char_tweak.ignore_headshot and not self._damage_reduction_multiplier and head then
		if self._char_tweak.headshot_dmg_mul then
			damage = damage * self._char_tweak.headshot_dmg_mul * headshot_multiplier
		else
			damage = self._health * 10
		end
	end

	if attack_data.weapon_unit:base().get_add_head_shot_mul then
		local add_head_shot_mul = attack_data.weapon_unit:base():get_add_head_shot_mul()

		if not head and add_head_shot_mul and self._char_tweak and self._char_tweak.access ~= "tank" then
			local tweak_headshot_mul = math.max(0, self._char_tweak.headshot_dmg_mul - 1)
			local mul = tweak_headshot_mul * add_head_shot_mul + 1
			damage = damage * mul
		end
	end

	damage = self:_apply_damage_reduction(damage)
	attack_data.raw_damage = damage
	attack_data.headshot = head
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			if head then
				managers.player:on_lethal_headshot_dealt(attack_data.attacker_unit, attack_data)

				if math.random(10) < damage then
					self:_spawn_head_gadget({
						position = attack_data.col_ray.body:position(),
						rotation = attack_data.col_ray.body:rotation(),
						dir = attack_data.col_ray.ray
					})
				end
			end

			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "bullet", headshot)
		end
	else
		attack_data.damage = damage
		local result_type = not self._char_tweak.immune_to_knock_down and (attack_data.knock_down and "knock_down" or attack_data.stagger and not self._has_been_staggered and "stagger") or self:get_damage_type(damage_percent, "bullet")
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
			managers.statistics:killed_by_anyone(data)
		end

		if attack_data.attacker_unit == managers.player:player_unit() then
			local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.weapon_unit)

			self:_comment_death(attack_data.attacker_unit, self._unit, special_comment)
			self:_show_death_hint(self._unit:base()._tweak_table)

			local attacker_state = managers.player:current_state()
			data.attacker_state = attacker_state

			managers.statistics:killed(data)
			self:_check_damage_achievements(attack_data, head)

			if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
				managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
			end

			if is_civilian then
				managers.money:civilian_killed()
			end
		elseif attack_data.attacker_unit:in_slot(managers.slot:get_mask("criminals_no_deployables")) then
			self:_AI_comment_death(attack_data.attacker_unit, self._unit)
		elseif attack_data.attacker_unit:base().sentry_gun then
			if Network:is_server() then
				local server_info = attack_data.weapon_unit:base():server_information()

				if server_info and server_info.owner_peer_id ~= managers.network:session():local_peer():id() then
					local owner_peer = managers.network:session():peer(server_info.owner_peer_id)

					if owner_peer then
						owner_peer:send_queued_sync("sync_player_kill_statistic", data.name, data.head_shot and true or false, data.weapon_unit, data.variant, data.stats_name)
					end
				else
					data.attacker_state = managers.player:current_state()

					managers.statistics:killed(data)
				end
			end

			local sentry_attack_data = deep_clone(attack_data)
			sentry_attack_data.attacker_unit = attack_data.attacker_unit:base():get_owner()

			if sentry_attack_data.attacker_unit == managers.player:player_unit() then
				self:_check_damage_achievements(sentry_attack_data, head)
			else
				self._unit:network():send("sync_damage_achievements", sentry_attack_data.weapon_unit, sentry_attack_data.attacker_unit, sentry_attack_data.damage, sentry_attack_data.col_ray and sentry_attack_data.col_ray.distance, head)
			end
		end
	end

	local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local attacker = attack_data.attacker_unit

	if attacker:id() == -1 then
		attacker = self._unit
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	local variant = nil

	if result.type == "knock_down" then
		variant = 1
	elseif result.type == "stagger" then
		variant = 2
		self._has_been_staggered = true
	elseif result.type == "healed" then
		variant = 3
	else
		variant = 0
	end

	self:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height, variant)
	self:_on_damage_received(attack_data)

	if not is_civilian then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	result.attack_data = attack_data

	return result
end

function CopDamage:client_check_damage_achievements(weapon_unit, attacker_unit, damage, distance, head_shot)
	if attacker_unit ~= managers.player:player_unit() then
		return
	end

	local fake_ray = {
		distance = distance
	}
	local attack_data = {
		weapon_unit = weapon_unit,
		attacker_unit = attacker_unit,
		col_ray = fake_ray,
		damage = damage
	}

	self:_check_damage_achievements(attack_data, head_shot)
end

function CopDamage:_check_damage_achievements(attack_data, head)
	local attack_weapon = attack_data.weapon_unit
	local is_weapon_valid = alive(attack_weapon) and attack_weapon:base()

	if not is_weapon_valid then
		return
	end

	if CopDamage.is_civilian(self._unit:base()._tweak_table) then
		return
	end

	if attack_weapon:base().thrower_unit then
		return
	end

	if managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.pump_action.mask and attack_weapon:base().is_category and attack_weapon:base():is_category("shotgun") then
		managers.achievment:award_progress(tweak_data.achievement.pump_action.stat)
	end

	local enemy_base = self._unit:base()
	local unit_type = enemy_base._tweak_table
	local unit_weapon = enemy_base._default_weapon_id
	local unit_anim = self._unit.anim_data and self._unit:anim_data()
	local achievements = tweak_data.achievement.enemy_kill_achievements or {}
	local current_mask_id = managers.blackmarket:equipped_mask().mask_id
	local attack_weapon_type = attack_weapon:base()._type
	local weapons_pass, weapon_pass, fire_mode_pass, ammo_pass, enemy_pass, enemy_weapon_pass, mask_pass, hiding_pass, head_pass, steelsight_pass, distance_pass, zipline_pass, rope_pass, one_shot_pass, weapon_type_pass, level_pass, part_pass, parts_pass, timer_pass, cop_pass, gangster_pass, civilian_pass, count_no_reload_pass, count_pass, count_in_row_pass, diff_pass, complete_count_pass, critical_pass, variant_pass, attack_weapon_type_pass, vip_pass, tags_all_pass, tags_any_pass, player_state_pass, all_pass, memory = nil
	local kill_count_no_reload = managers.job:get_memory("kill_count_no_reload_" .. tostring(attack_weapon:base()._name_id), true)
	kill_count_no_reload = (kill_count_no_reload or 0) + 1

	managers.job:set_memory("kill_count_no_reload_" .. tostring(attack_weapon:base()._name_id), kill_count_no_reload, true)

	local kill_count_carry_or_not = managers.job:get_memory("kill_count_" .. (managers.player:is_carrying() and "carry" or "no_carry"), true)
	kill_count_carry_or_not = (kill_count_carry_or_not or 0) + 1

	managers.job:set_memory("kill_count_" .. (managers.player:is_carrying() and "carry" or "no_carry"), kill_count_carry_or_not, true)

	local is_cop = CopDamage.is_cop(enemy_base._tweak_table)
	local weapon_category = {}

	if attack_weapon:base().weapon_tweak_data then
		weapon_category = attack_weapon:base():weapon_tweak_data().categories
	end

	for achievement, achievement_data in pairs(achievements) do
		weapon_type_pass = not achievement_data.weapon_type or weapon_category and table.contains(weapon_category, achievement_data.weapon_type)
		weapons_pass = not achievement_data.weapons or table.contains(achievement_data.weapons, attack_weapon:base()._name_id)
		weapon_pass = not achievement_data.weapon or attack_weapon:base().name_id == achievement_data.weapon
		fire_mode_pass = not achievement_data.fire_mode or attack_weapon:base():fire_mode() == achievement_data.fire_mode
		ammo_pass = not achievement_data.total_ammo or attack_weapon:base():get_ammo_total() == achievement_data.total_ammo
		one_shot_pass = not achievement_data.one_shot or attack_data.damage == self._HEALTH_INIT
		enemy_pass = not achievement_data.enemy or unit_type == achievement_data.enemy
		enemy_weapon_pass = not achievement_data.enemy_weapon or unit_weapon == achievement_data.enemy_weapon
		mask_pass = not achievement_data.mask or current_mask_id == achievement_data.mask
		hiding_pass = not achievement_data.hiding or unit_anim and unit_anim.hide
		head_pass = not achievement_data.in_head or head
		distance_pass = not achievement_data.distance or attack_data.col_ray and attack_data.col_ray.distance and achievement_data.distance <= attack_data.col_ray.distance
		zipline_pass = not achievement_data.on_zipline or attack_data.attacker_unit and attack_data.attacker_unit:movement():zipline_unit()
		rope_pass = not achievement_data.on_rope or self._unit:movement() and self._unit:movement():rope_unit()
		level_pass = not achievement_data.level_id or (managers.job:current_level_id() or "") == achievement_data.level_id
		steelsight_pass = achievement_data.in_steelsight == nil or attack_data.attacker_unit and attack_data.attacker_unit:movement() and not not attack_data.attacker_unit:movement():current_state():in_steelsight() == not not achievement_data.in_steelsight
		count_no_reload_pass = not achievement_data.count_no_reload or achievement_data.count_no_reload <= kill_count_no_reload
		count_pass = not achievement_data.kill_count or achievement_data.weapon and managers.statistics:session_killed_by_weapon(achievement_data.weapon) == achievement_data.kill_count
		diff_pass = not achievement_data.difficulty or table.contains(achievement_data.difficulty, Global.game_settings.difficulty)
		cop_pass = not achievement_data.is_cop or is_cop
		tags_all_pass = not achievement_data.enemy_tags_all or enemy_base:has_all_tags(achievement_data.enemy_tags_all)
		tags_any_pass = not achievement_data.enemy_tags_any or enemy_base:has_any_tag(achievement_data.enemy_tags_any)
		player_state_pass = not achievement_data.player_state or achievement_data.player_state == managers.player:current_state()
		complete_count_pass = not achievement_data.complete_count

		if achievement_data.complete_count and achievement_data.weapons then
			local total = 0

			for _, weapon in ipairs(achievement_data.weapons) do
				total = total + managers.statistics:session_killed_by_weapon(weapon)
			end

			complete_count_pass = total == achievement_data.complete_count
		end

		if achievement_data.enemies then
			enemy_pass = false

			for _, enemy in pairs(achievement_data.enemies) do
				if enemy == unit_type then
					enemy_pass = true

					break
				end
			end
		end

		part_pass = not achievement_data.part_id or attack_weapon:base().has_part and attack_weapon:base():has_part(achievement_data.part_id)
		parts_pass = not achievement_data.parts

		if achievement_data.parts and attack_weapon:base().has_part then
			for _, part_id in ipairs(achievement_data.parts) do
				if attack_weapon:base():has_part(part_id) then
					parts_pass = true

					break
				end
			end
		end

		critical_pass = not achievement_data.critical

		if achievement_data.critical then
			critical_pass = attack_data.critical_hit
		end

		variant_pass = not achievement_data.variant

		if achievement_data.variant then
			variant_pass = (type(achievement_data.variant) ~= "table" or table.contains(achievement_data.variant, attack_data.variant)) and attack_data.variant == achievement_data.variant
		end

		attack_weapon_type_pass = not achievement_data.attack_weapon_type

		if achievement_data.attack_weapon_type then
			attack_weapon_type_pass = (type(achievement_data.attack_weapon_type) ~= "table" or table.contains(achievement_data.attack_weapon_type, attack_weapon_type)) and achievement_data.attack_weapon_type == attack_weapon_type
		end

		vip_pass = not achievement_data.is_vip
		all_pass = weapon_type_pass and weapons_pass and weapon_pass and fire_mode_pass and ammo_pass and one_shot_pass and enemy_pass and enemy_weapon_pass and mask_pass and hiding_pass and head_pass and distance_pass and zipline_pass and rope_pass and level_pass and part_pass and parts_pass and steelsight_pass and cop_pass and count_no_reload_pass and count_pass and diff_pass and complete_count_pass and critical_pass and variant_pass and attack_weapon_type_pass and vip_pass and tags_all_pass and tags_any_pass and player_state_pass
		timer_pass = not achievement_data.timer

		if all_pass and achievement_data.timer then
			memory = managers.job:get_memory(achievement, true)
			local t = TimerManager:game():time()

			if memory then
				table.insert(memory, t)

				for i = #memory, 1, -1 do
					if achievement_data.timer <= t - memory[i] then
						table.remove(memory, i)
					end
				end

				timer_pass = achievement_data.count <= #memory

				managers.job:set_memory(achievement, memory, true)
			else
				managers.job:set_memory(achievement, {
					t
				}, true)
			end
		end

		all_pass = all_pass and timer_pass
		count_in_row_pass = not achievement_data.count_in_row

		if achievement_data.count_in_row then
			memory = managers.job:get_memory(achievement, true) or 0

			if memory then
				if all_pass then
					memory = memory + 1
					count_in_row_pass = achievement_data.count_in_row <= memory
				else
					memory = false
				end

				managers.job:set_memory(achievement, memory, true)
			end
		end

		all_pass = all_pass and count_in_row_pass

		if all_pass and not managers.achievment:award_data(achievement_data) then
			Application:debug("[CopDamage] enemy_kill_achievements:", achievement)
		end
	end

	if unit_type == "spooc" then
		local spooc_action = self._unit:movement()._active_actions[1]

		if spooc_action and spooc_action:type() == "spooc" then
			if spooc_action:is_flying_strike() then
				if attack_weapon:base().is_category and attack_weapon:base():is_category(tweak_data.achievement.in_town_you_are_law.weapon_type) then
					managers.achievment:award(tweak_data.achievement.in_town_you_are_law.award)
				end
			elseif not spooc_action:has_striken() and attack_weapon:base().name_id == tweak_data.achievement.dont_push_it.weapon then
				managers.achievment:award(tweak_data.achievement.dont_push_it.award)
			end
		end
	end
end

function CopDamage.is_civilian(type)
	return type == "civilian" or type == "civilian_female" or type == "bank_manager" or type == "robbers_safehouse"
end

function CopDamage.is_gangster(type)
	return type == "gangster" or type == "biker_escape" or type == "mobster" or type == "mobster_boss" or type == "biker" or type == "biker_boss" or type == "bolivian" or type == "drug_lord_boss" or type == "drug_lord_boss_stealth" or type == "captain"
end

function CopDamage.is_cop(type)
	return not CopDamage.is_civilian(type) and not CopDamage.is_gangster(type)
end

function CopDamage:_show_death_hint(type)
	if CopDamage.is_civilian(type) and not self._unit:base().enemy then
		-- Nothing
	end
end

function CopDamage:_comment_death(attacker, killed_unit, special_comment)
	local victim_base = killed_unit:base()

	if special_comment then
		PlayerStandard.say_line(attacker:sound(), special_comment)
	elseif victim_base:has_tag("tank") then
		PlayerStandard.say_line(attacker:sound(), "g30x_any")
	elseif victim_base:has_tag("spooc") then
		PlayerStandard.say_line(attacker:sound(), "g33x_any")
	elseif victim_base:has_tag("taser") then
		PlayerStandard.say_line(attacker:sound(), "g32x_any")
	elseif victim_base:has_tag("shield") then
		PlayerStandard.say_line(attacker:sound(), "g31x_any")
	elseif victim_base:has_tag("sniper") then
		PlayerStandard.say_line(attacker:sound(), "g35x_any")
	elseif victim_base:has_tag("medic") then
		PlayerStandard.say_line(attacker:sound(), "g36x_any")
	end
end

function CopDamage:_AI_comment_death(unit, killed_unit)
	local victim_base = killed_unit:base()

	if victim_base:has_tag("tank") then
		unit:sound():say("g30x_any", true)
	elseif victim_base:has_tag("spooc") then
		unit:sound():say("g33x_any", true)
	elseif victim_base:has_tag("taser") then
		unit:sound():say("g32x_any", true)
	elseif victim_base:has_tag("shield") then
		unit:sound():say("g31x_any", true)
	elseif victim_base:has_tag("sniper") then
		unit:sound():say("g35x_any", true)
	elseif victim_base:has_tag("medic") then
		unit:sound():say("g36x_any", true)
	end
end

function CopDamage:damage_fire(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local result = nil
	local damage = attack_data.damage
	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)
		damage = crit_damage

		if attack_data.weapon_unit and attack_data.variant ~= "stun" and not attack_data.is_fire_dot_damage then
			if critical_hit then
				managers.hud:on_crit_confirmed()
			else
				managers.hud:on_hit_confirmed()
			end
		end
	end

	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "fire")
		end
	else
		attack_data.damage = damage
		local result_type = attack_data.variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "fire")
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local headshot_multiplier = 1

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			damage = crit_damage
		end

		headshot_multiplier = managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)

		if tweak_data.character[self._unit:base()._tweak_table].priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end

		if head then
			managers.player:on_headshot_dealt()
		end
	end

	if not self._damage_reduction_multiplier and head then
		if self._char_tweak.headshot_dmg_mul then
			damage = damage * self._char_tweak.headshot_dmg_mul * headshot_multiplier
		else
			damage = self._health * 10
		end
	end

	if self._head_body_name and attack_data.variant ~= "stun" then
		head = attack_data.col_ray.body and self._head_body_key and attack_data.col_ray.body:key() == self._head_body_key
		local body = self._unit:body(self._head_body_name)
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker and alive(attacker) and attacker:id() == -1 then
		attacker = self._unit
	end

	local attacker_unit = attack_data.attacker_unit

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = head,
			is_molotov = attack_data.is_molotov
		}

		if not attack_data.is_fire_dot_damage or data.is_molotov then
			managers.statistics:killed_by_anyone(data)
		end

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and alive(attack_data.weapon_unit) and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		if attacker_unit and alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)

			if not attack_data.is_fire_dot_damage or data.is_molotov then
				managers.statistics:killed(data)
			end

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	local weapon_unit = attack_data.weapon_unit or attacker

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	if not attack_data.is_fire_dot_damage then
		local fire_dot_data = attack_data.fire_dot_data
		local flammable = nil
		local char_tweak = tweak_data.character[self._unit:base()._tweak_table]
		flammable = char_tweak.flammable == nil and true or char_tweak.flammable
		local distance = 1000
		local hit_loc = attack_data.col_ray.hit_position

		if hit_loc and attacker_unit and attacker_unit.position then
			distance = mvector3.distance(hit_loc, attacker_unit:position())
		end

		local fire_dot_max_distance = 3000
		local fire_dot_trigger_chance = 30

		if fire_dot_data then
			fire_dot_max_distance = tonumber(fire_dot_data.dot_trigger_max_distance)
			fire_dot_trigger_chance = tonumber(fire_dot_data.dot_trigger_chance)
		end

		local start_dot_damage_roll = math.random(1, 100)
		local start_dot_dance_antimation = false

		if flammable and not attack_data.is_fire_dot_damage and distance < fire_dot_max_distance and start_dot_damage_roll <= fire_dot_trigger_chance then
			managers.fire:add_doted_enemy(self._unit, TimerManager:game():time(), attack_data.weapon_unit, fire_dot_data.dot_length, fire_dot_data.dot_damage, attack_data.attacker_unit, attack_data.is_molotov)

			start_dot_dance_antimation = true
		end

		if fire_dot_data then
			fire_dot_data.start_dot_dance_antimation = start_dot_dance_antimation
			attack_data.fire_dot_data = fire_dot_data
		end
	end

	self:_send_fire_attack_result(attack_data, attacker, damage_percent, attack_data.is_fire_dot_damage, attack_data.col_ray.ray, attack_data.result.type == "healed")
	self:_on_damage_received(attack_data)

	if not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end
end

function CopDamage:damage_dot(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local result = nil
	local damage = attack_data.damage
	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			attack_data.variant = "healed"
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, attack_data.variant or "dot", nil, attack_data.weapon_id)
		end
	else
		attack_data.damage = damage
		local result_type = attack_data.hurt_animation and self:get_damage_type(damage_percent, attack_data.variant) or "dmg_rcv"
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	local attacker_unit = attack_data.attacker_unit

	if result.type == "death" then
		local variant = attack_data.weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[attack_data.weapon_id] and "melee" or attack_data.variant
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = variant,
			head_shot = head,
			weapon_id = attack_data.weapon_id
		}

		managers.statistics:killed_by_anyone(data)

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	self:_send_dot_attack_result(attack_data, attacker, damage_percent, attack_data.variant, attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)
end

function CopDamage:damage_explosion(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local result = nil
	local damage = attack_data.damage
	damage = managers.modifiers:modify_value("CopDamage:DamageExplosion", damage, self._unit:base()._tweak_table)

	if self._unit:base():char_tweak().DAMAGE_CLAMP_EXPLOSION then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_EXPLOSION)
	end

	damage = damage * (self._char_tweak.damage.explosion_damage_mul or 1)
	damage = damage * (self._marked_dmg_mul or 1)

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)
		damage = crit_damage

		if attack_data.weapon_unit and attack_data.variant ~= "stun" then
			if critical_hit then
				managers.hud:on_crit_confirmed()
			else
				managers.hud:on_hit_confirmed()
			end
		end
	end

	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			attack_data.variant = "healed"
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
		end
	else
		attack_data.damage = damage
		local result_type = attack_data.variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "explosion")
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local head = nil

	if self._head_body_name and attack_data.variant ~= "stun" then
		head = attack_data.col_ray.body and self._head_body_key and attack_data.col_ray.body:key() == self._head_body_key
		local body = self._unit:body(self._head_body_name)

		self:_spawn_head_gadget({
			position = body:position(),
			rotation = body:rotation(),
			dir = -attack_data.col_ray.ray
		})
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	result.ignite_character = attack_data.ignite_character

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = head
		}

		managers.statistics:killed_by_anyone(data)

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and attack_data.weapon_unit and attack_data.weapon_unit:base().weapon_tweak_data and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		self:chk_killshot(attacker_unit, "explosion")

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(attack_data.pos, attack_data.col_ray.ray)
	end

	self:_send_explosion_attack_result(attack_data, attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)

	if not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end

function CopDamage:damage_simple(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local result = nil
	local damage = attack_data.damage

	if self._unit:base():char_tweak().DAMAGE_CLAMP_SHOCK then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_SHOCK)
	end

	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			attack_data.variant = "healed"
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
		end
	else
		attack_data.damage = damage
		local result_type = self:get_damage_type(damage_percent)
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		managers.statistics:killed_by_anyone(data)

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and attack_data.weapon_unit and attack_data.weapon_unit:base().weapon_tweak_data and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		self:chk_killshot(attacker_unit, "shock")

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(attack_data.pos, attack_data.attack_dir)
	end

	local i_result = ({
		healed = 3,
		knock_down = 1,
		stagger = 2
	})[result.type] or 0

	self:_send_simple_attack_result(attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), i_result)
	self:_on_damage_received(attack_data)

	if not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end

function CopDamage:stun_hit(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local result = {
		type = "concussion",
		variant = attack_data.variant
	}
	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local damage_percent = 0
	local attacker = attack_data.attacker_unit

	self:_send_stun_attack_result(attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)
	self:_create_stun_exit_clbk()
end

function CopDamage:_create_stun_exit_clbk()
	if not self._stun_exit_clbk then
		self._stun_exit_clbk = true

		self._listener_holder:add("after_stun_accuracy", {
			"on_exit_hurt"
		}, callback(self, self, "_on_stun_hit_exit"))
	end
end

function CopDamage:_on_stun_hit_exit()
	self:set_accuracy_multiplier(self._ON_STUN_ACCURACY_DECREASE)

	local function f()
		self:set_accuracy_multiplier(1)
	end

	managers.enemy:add_delayed_clbk("ResetAccuracy", f, TimerManager:game():time() + self._ON_STUN_ACCURACY_DECREASE_TIME)

	self._stun_exit_clbk = nil

	self._listener_holder:remove("after_stun_accuracy")
end

function CopDamage:roll_critical_hit(attack_data)
	local damage = attack_data.damage

	if not self:can_be_critical(attack_data) then
		return false, damage
	end

	local critical_hits = self._char_tweak.critical_hits or {}
	local critical_hit = false
	local critical_value = (critical_hits.base_chance or 0) + managers.player:critical_hit_chance() * (critical_hits.player_chance_multiplier or 1)

	if critical_value > 0 then
		local critical_roll = math.rand(1)
		critical_hit = critical_roll < critical_value
	end

	if critical_hit then
		local critical_damage_mul = critical_hits.damage_mul or self._char_tweak.headshot_dmg_mul

		if critical_damage_mul then
			damage = damage * critical_damage_mul
		else
			damage = self._health * 10
		end
	end

	return critical_hit, damage
end

function CopDamage:can_be_critical(attack_data)
	local LOG_CATEGORY = "[GameSystem_CriticalHit] "
	local weapon_unit_base = nil

	if alive(attack_data.weapon_unit) then
		weapon_unit_base = attack_data.weapon_unit:base()
	end

	if weapon_unit_base == nil then
		print(LOG_CATEGORY, "No weapon unit in attack data, so CAN CRIT")

		return true
	end

	local weapon_type = nil
	local damage_type = attack_data.variant

	if weapon_unit_base.thrower_unit then
		local unit_base = weapon_unit_base._unit:base()

		if unit_base._tweak_projectile_entry then
			weapon_type = unit_base._tweak_projectile_entry
		elseif unit_base._projectile_entry then
			weapon_type = unit_base._projectile_entry
		end
	elseif weapon_unit_base.weapon_tweak_data then
		local weapon_td = weapon_unit_base:weapon_tweak_data()
		weapon_type = weapon_td.categories[1]
	elseif weapon_unit_base.get_name_id then
		weapon_type = weapon_unit_base:get_name_id()
	end

	local damage_crit_data = tweak_data.weapon_disable_crit_for_damage[weapon_type]

	if not damage_crit_data then
		print(LOG_CATEGORY, "No damage tweak data for ", weapon_type, "CAN CRIT. (you can add tweak data at \"weapon_disable_crit_for_damage\")")

		return true
	end

	local is_damage_type_can_crit = damage_crit_data[damage_type]

	if is_damage_type_can_crit then
		print(LOG_CATEGORY, "Tweak data found for ", weapon_type, ": ", damage_type, "CAN CRIT")

		return true
	end

	print(LOG_CATEGORY, "Tweak data found for ", weapon_type, ": ", damage_type, "NO CRIT")

	return false
end

function CopDamage:damage_tase(attack_data)
	if self._dead or self._invulnerable then
		if self._invulnerable then
			print("INVULNERABLE!  Not tasing.")
		end

		return
	end

	if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return "friendly_fire"
	end

	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	self._tase_effect = World:effect_manager():spawn(self._tase_effect_table)
	local result = nil
	local damage = attack_data.damage

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)
		damage = crit_damage

		if attack_data.weapon_unit then
			if critical_hit then
				managers.hud:on_crit_confirmed()
			else
				managers.hud:on_hit_confirmed()
			end
		end
	end

	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._health <= damage then
		attack_data.damage = self._health
		result = {
			variant = "bullet",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attack_data.attacker_unit, "tase")
	else
		attack_data.damage = damage
		local type = "taser_tased"

		if not self._char_tweak.damage.hurt_severity.tase then
			type = "none"
		end

		result = {
			type = type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local head = nil

	if self._head_body_name then
		head = attack_data.col_ray.body and self._head_body_key and attack_data.col_ray.body:key() == self._head_body_key
		local body = self._unit:body(self._head_body_name)

		self:_spawn_head_gadget({
			position = body:position(),
			rotation = body:rotation(),
			dir = -attack_data.col_ray.ray
		})
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = head
		}

		managers.statistics:killed_by_anyone(data)

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	local variant = result.variant == "heavy" and 1 or 0

	self:_send_tase_attack_result(attack_data, damage_percent, variant)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:_dismember_condition(attack_data)
	local dismember_victim = false
	local target_is_spook = false

	if alive(attack_data.col_ray.unit) and attack_data.col_ray.unit:base() then
		target_is_spook = attack_data.col_ray.unit:base()._tweak_table == "spooc"
	end

	local criminal_name = managers.criminals:local_character_name()
	local criminal_melee_weapon = managers.blackmarket:equipped_melee_weapon()
	local weapon_charged = false

	if attack_data.charge_lerp_value then
		weapon_charged = attack_data.charge_lerp_value > 0.5
	end

	if target_is_spook and weapon_charged and criminal_name == "dragon" and criminal_melee_weapon == "sandsteel" then
		dismember_victim = true
	end

	return dismember_victim
end

function CopDamage:damage_melee(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return "friendly_fire"
	end

	local result = nil
	local is_civlian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local is_gangster = CopDamage.is_gangster(self._unit:base()._tweak_table)
	local is_cop = not is_civlian and not is_gangster
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			managers.hud:on_crit_confirmed()

			damage = crit_damage
			attack_data.critical_hit = true
		else
			managers.hud:on_hit_confirmed()
		end

		if tweak_data.achievement.cavity.melee_type == attack_data.name_id and not CopDamage.is_civilian(self._unit:base()._tweak_table) then
			managers.achievment:award(tweak_data.achievement.cavity.award)
		end
	end

	damage = damage * (self._marked_dmg_mul or 1)

	if self._unit:movement():cool() then
		damage = self._HEALTH_INIT
	end

	local damage_effect = attack_data.damage_effect
	local damage_effect_percent = nil
	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			damage_effect_percent = 1
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "melee")
		end
	else
		attack_data.damage = damage
		damage_effect = math.clamp(damage_effect, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
		damage_effect_percent = math.ceil(damage_effect / self._HEALTH_INIT_PRECENT)
		damage_effect_percent = math.clamp(damage_effect_percent, 1, self._HEALTH_GRANULARITY)
		local result_type = attack_data.shield_knock and self._char_tweak.damage.shield_knocked and "shield_knock" or attack_data.variant == "counter_tased" and "counter_tased" or attack_data.variant == "taser_tased" and "taser_tased" or attack_data.variant == "counter_spooc" and "expl_hurt" or self:get_damage_type(damage_effect_percent, "melee") or "fire_hurt"
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local dismember_victim = false
	local snatch_pager = false

	if result.type == "death" then
		if self:_dismember_condition(attack_data) then
			self:_dismember_body_part(attack_data)

			dismember_victim = true
		end

		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			name_id = attack_data.name_id,
			variant = attack_data.variant
		}

		managers.statistics:killed_by_anyone(data)

		if attack_data.attacker_unit == managers.player:player_unit() then
			self:_comment_death(attack_data.attacker_unit, self._unit)
			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if not is_civlian and managers.groupai:state():whisper_mode() and managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.cant_hear_you_scream.mask then
				managers.achievment:award_progress(tweak_data.achievement.cant_hear_you_scream.stat)
			end

			mvector3.set(mvec_1, self._unit:position())
			mvector3.subtract(mvec_1, attack_data.attacker_unit:position())
			mvector3.normalize(mvec_1)
			mvector3.set(mvec_2, self._unit:rotation():y())

			local from_behind = mvector3.dot(mvec_1, mvec_2) >= 0

			if is_cop and Global.game_settings.level_id == "nightclub" and attack_data.name_id and attack_data.name_id == "fists" then
				managers.achievment:award_progress(tweak_data.achievement.final_rule.stat)
			end

			if is_civlian then
				managers.money:civilian_killed()
			elseif math.rand(1) < managers.player:upgrade_value("player", "melee_kill_snatch_pager_chance", 0) then
				snatch_pager = true
				self._unit:unit_data().has_alarm_pager = false
			end
		end
	end

	if tweak_data.blackmarket.melee_weapons[attack_data.name_id] then
		local achievements = tweak_data.achievement.enemy_melee_hit_achievements or {}
		local melee_type = tweak_data.blackmarket.melee_weapons[attack_data.name_id].type
		local enemy_base = self._unit:base()
		local enemy_movement = self._unit:movement()
		local enemy_type = enemy_base._tweak_table
		local unit_weapon = enemy_base._default_weapon_id
		local health_ratio = managers.player:player_unit():character_damage():health_ratio() * 100
		local melee_pass, melee_weapons_pass, type_pass, enemy_pass, enemy_weapon_pass, diff_pass, health_pass, level_pass, job_pass, jobs_pass, enemy_count_pass, tags_all_pass, tags_any_pass, all_pass, cop_pass, gangster_pass, civilian_pass, stealth_pass, on_fire_pass, behind_pass, result_pass, mutators_pass, critical_pass, action_pass, is_dropin_pass = nil

		for achievement, achievement_data in pairs(achievements) do
			melee_pass = not achievement_data.melee_id or achievement_data.melee_id == attack_data.name_id
			melee_weapons_pass = not achievement_data.melee_weapons or table.contains(achievement_data.melee_weapons, attack_data.name_id)
			type_pass = not achievement_data.melee_type or melee_type == achievement_data.melee_type
			result_pass = not achievement_data.result or attack_data.result.type == achievement_data.result
			enemy_pass = not achievement_data.enemy or enemy_type == achievement_data.enemy
			enemy_weapon_pass = not achievement_data.enemy_weapon or unit_weapon == achievement_data.enemy_weapon
			behind_pass = not achievement_data.from_behind or from_behind
			diff_pass = not achievement_data.difficulty or table.contains(achievement_data.difficulty, Global.game_settings.difficulty)
			health_pass = not achievement_data.health or health_ratio <= achievement_data.health
			level_pass = not achievement_data.level_id or (managers.job:current_level_id() or "") == achievement_data.level_id
			job_pass = not achievement_data.job or managers.job:current_real_job_id() == achievement_data.job
			jobs_pass = not achievement_data.jobs or table.contains(achievement_data.jobs, managers.job:current_real_job_id())
			enemy_count_pass = not achievement_data.enemy_kills or achievement_data.enemy_kills.count <= managers.statistics:session_enemy_killed_by_type(achievement_data.enemy_kills.enemy, "melee")
			tags_all_pass = not achievement_data.enemy_tags_all or enemy_base:has_all_tags(achievement_data.enemy_tags_all)
			tags_any_pass = not achievement_data.enemy_tags_any or enemy_base:has_any_tag(achievement_data.enemy_tags_any)
			cop_pass = not achievement_data.is_cop or is_cop
			gangster_pass = not achievement_data.is_gangster or is_gangster
			civilian_pass = not achievement_data.is_not_civilian or not is_civlian
			stealth_pass = not achievement_data.is_stealth or managers.groupai:state():whisper_mode()
			on_fire_pass = not achievement_data.is_on_fire or managers.fire:is_set_on_fire(self._unit)
			is_dropin_pass = achievement_data.is_dropin == nil or achievement_data.is_dropin == managers.statistics:is_dropin()

			if achievement_data.enemies then
				enemy_pass = false

				for _, enemy in pairs(achievement_data.enemies) do
					if enemy == enemy_type then
						enemy_pass = true

						break
					end
				end
			end

			mutators_pass = managers.mutators:check_achievements(achievement_data)
			critical_pass = not achievement_data.critical

			if achievement_data.critical then
				critical_pass = attack_data.critical_hit
			end

			action_pass = true

			if achievement_data.action then
				local action = enemy_movement:get_action(achievement_data.action.body_part)
				local action_type = action and action:type()
				action_pass = action_type == achievement_data.action.type
			end

			all_pass = melee_pass and melee_weapons_pass and type_pass and enemy_pass and enemy_weapon_pass and behind_pass and diff_pass and health_pass and level_pass and job_pass and jobs_pass and cop_pass and gangster_pass and civilian_pass and stealth_pass and on_fire_pass and enemy_count_pass and tags_all_pass and tags_any_pass and result_pass and mutators_pass and critical_pass and action_pass and is_dropin_pass

			if all_pass then
				if achievement_data.stat then
					managers.achievment:award_progress(achievement_data.stat)
				elseif achievement_data.award then
					managers.achievment:award(achievement_data.award)
				elseif achievement_data.challenge_stat then
					managers.challenge:award_progress(achievement_data.challenge_stat)
				elseif achievement_data.trophy_stat then
					managers.custom_safehouse:award(achievement_data.trophy_stat)
				elseif achievement_data.challenge_award then
					managers.challenge:award(achievement_data.challenge_award)
				end
			end
		end
	end

	local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local variant = nil

	if result.type == "shield_knock" then
		variant = 1
	elseif result.type == "counter_tased" then
		variant = 2
	elseif result.type == "expl_hurt" then
		variant = 4
	elseif snatch_pager then
		variant = 3
	elseif result.type == "taser_tased" then
		variant = 5
	elseif dismember_victim then
		variant = 6
	elseif result.type == "healed" then
		variant = 7
	else
		variant = 0
	end

	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())

	self:_send_melee_attack_result(attack_data, damage_percent, damage_effect_percent, hit_offset_height, variant, body_index)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:damage_mission(attack_data)
	if self._dead or (self._invulnerable or self._immortal) and not attack_data.forced then
		return
	end

	if self.immortal and self.is_escort then
		if attack_data.backup_so then
			attack_data.backup_so:on_executed(self._unit)
		end

		return
	end

	local result = nil
	local damage_percent = self._HEALTH_GRANULARITY
	attack_data.damage = self._health
	result = {
		type = "death",
		variant = attack_data.variant
	}

	self:die(attack_data)

	attack_data.result = result
	attack_data.attack_dir = self._unit:rotation():y()
	attack_data.pos = self._unit:position()

	if attack_data.attacker_unit == managers.player:local_player() and CopDamage.is_civilian(self._unit:base()._tweak_table) then
		managers.money:civilian_killed()
	end

	self:_send_explosion_attack_result(attack_data, self._unit, damage_percent, self:_get_attack_variant_index("explosion"), attack_data.col_ray and attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:get_ranged_attack_autotarget_data_fast()
	return {
		object = self._autotarget_data.fast
	}
end

function CopDamage:get_ranged_attack_autotarget_data(shoot_from_pos, aim_vec)
	local autotarget_data = nil
	autotarget_data = {
		body = self._unit:body("b_spine1")
	}
	local dis = mvector3.distance(shoot_from_pos, self._unit:position())

	if dis > 3500 then
		autotarget_data = {
			body = self._unit:body("b_spine1")
		}
	else
		self._aim_bodies = {}

		table.insert(self._aim_bodies, self._unit:body("b_right_thigh"))
		table.insert(self._aim_bodies, self._unit:body("b_left_thigh"))
		table.insert(self._aim_bodies, self._unit:body("b_head"))
		table.insert(self._aim_bodies, self._unit:body("b_left_lower_arm"))
		table.insert(self._aim_bodies, self._unit:body("b_right_lower_arm"))

		local uncovered_body, best_angle = nil

		for i, body in ipairs(self._aim_bodies) do
			local body_pos = body:center_of_mass()
			local body_vec = body_pos - shoot_from_pos
			local body_angle = body_vec:angle(aim_vec)

			if not best_angle or body_angle < best_angle then
				local aim_ray = World:raycast("ray", shoot_from_pos, body_pos, "sphere_cast_radius", 30, "bundle", 4, "slot_mask", managers.slot:get_mask("melee_equipment"))

				if not aim_ray then
					uncovered_body = body
					best_angle = body_angle
				end
			end
		end

		if uncovered_body then
			autotarget_data = {
				body = uncovered_body
			}
		else
			autotarget_data = {
				body = self._unit:body("b_spine1")
			}
		end
	end

	return autotarget_data
end

function CopDamage:get_impact_segment(position)
	local closest_dist_sq, closest_bone = nil

	for _, bone_name in pairs(self._impact_bones) do
		local bone_obj = self._unit:get_object(bone_name)
		local bone_dist_sq = mvector3.distance_sq(position, bone_obj:position())

		if not closest_bone or bone_dist_sq < closest_dist_sq then
			closest_bone = bone_obj
			closest_dist_sq = bone_dist_sq
		end
	end

	local parent_bone, child_bone, closest_child = nil
	closest_dist_sq = nil

	for _, bone_obj in ipairs(closest_bone:children()) do
		if self._impact_bones[bone_obj:name():key()] then
			local bone_dist_sq = mvector3.distance_sq(position, bone_obj:position())

			if not closest_dist_sq or bone_dist_sq < closest_dist_sq then
				closest_child = bone_obj
				closest_dist_sq = bone_dist_sq
			end
		end
	end

	local bone_obj = closest_bone:parent()

	if bone_obj and self._impact_bones[bone_obj:name():key()] then
		local bone_dist_sq = mvector3.distance_sq(position, bone_obj:position())

		if not closest_dist_sq or bone_dist_sq < closest_dist_sq then
			parent_bone = bone_obj
			child_bone = closest_bone
		end
	end

	if not parent_bone then
		parent_bone = closest_bone
		child_bone = closest_child
	end

	return parent_bone, child_bone
end

function CopDamage:_spawn_head_gadget(params)
	if not self._head_gear then
		return
	end

	if self._head_gear_object then
		if self._nr_head_gear_objects then
			for i = 1, self._nr_head_gear_objects, 1 do
				local head_gear_obj_name = self._head_gear_object .. tostring(i)

				self._unit:get_object(Idstring(head_gear_obj_name)):set_visibility(false)
			end
		else
			self._unit:get_object(Idstring(self._head_gear_object)):set_visibility(false)
		end

		if self._head_gear_decal_mesh then
			local mesh_name_idstr = Idstring(self._head_gear_decal_mesh)

			self._unit:decal_surface(mesh_name_idstr):set_mesh_material(mesh_name_idstr, Idstring("flesh"))
		end
	end

	local unit = World:spawn_unit(Idstring(self._head_gear), params.position, params.rotation)

	if not params.skip_push then
		local dir = math.UP - params.dir / 2
		dir = dir:spread(25)
		local body = unit:body(0)

		body:push_at(body:mass(), dir * math.lerp(300, 650, math.random()), unit:position() + Vector3(math.rand(1), math.rand(1), math.rand(1)))
	end

	self._head_gear = false
end

function CopDamage:dead()
	return self._dead
end

function CopDamage:_remove_debug_gui()
	if alive(self._gui) and alive(self._ws) then
		self._gui:destroy_workspace(self._ws)

		self._ws = nil
		self._gui = nil
	end
end

function CopDamage:_check_friend_4(attack_data)
	if tweak_data:difficulty_to_index(Global.game_settings.difficulty) >= 5 then
		local weapon_unit = attack_data.weapon_unit or attack_data.attacker_unit
		local projectile_entry = alive(weapon_unit) and weapon_unit:base()._projectile_entry

		if (self._unit:base()._tweak_table == "drug_lord_boss" or self._unit:base()._tweak_table == "drug_lord_boss_stealth") and projectile_entry == "rocket_ray_frag" then
			managers.achievment:award("friend_4")
		end
	end
end

function CopDamage:die(attack_data)
	if self._immortal then
		debug_pause("Immortal character died!")
	end

	local variant = attack_data.variant

	self:_check_friend_4(attack_data)
	CopDamage.MAD_3_ACHIEVEMENT(attack_data)
	self:_remove_debug_gui()
	self._unit:base():set_slot(self._unit, 17)

	if alive(managers.interaction:active_unit()) then
		managers.interaction:active_unit():interaction():selected()
	end

	self:drop_pickup()
	self._unit:inventory():drop_shield()

	if self._unit:unit_data().mission_element then
		self._unit:unit_data().mission_element:event("death", self._unit)

		if not self._unit:unit_data().alerted_event_called then
			self._unit:unit_data().alerted_event_called = true

			self._unit:unit_data().mission_element:event("alerted", self._unit)
		end
	end

	if self._unit:movement() then
		self._unit:movement():remove_giveaway()
	end

	variant = variant or "bullet"
	self._health = 0
	self._health_ratio = 0
	self._dead = true

	self:set_mover_collision_state(false)

	if self._death_sequence then
		if self._unit:damage() and self._unit:damage():has_sequence(self._death_sequence) then
			self._unit:damage():run_sequence_simple(self._death_sequence)
		else
			debug_pause_unit(self._unit, "[CopDamage:die] does not have death sequence", self._death_sequence, self._unit)
		end
	end

	if self._unit:base():char_tweak().die_sound_event then
		self._unit:sound():play(self._unit:base():char_tweak().die_sound_event, nil, nil)
	end

	self:_on_death()
	managers.mutators:notify(Message.OnCopDamageDeath, self, attack_data)
end

function CopDamage:set_mover_collision_state(state)
	local change_state = nil

	if state then
		if self._mover_collision_state then
			if self._mover_collision_state == -1 then
				self._mover_collision_state = nil
				change_state = true
			else
				self._mover_collision_state = self._mover_collision_state + 1
			end
		end
	elseif self._mover_collision_state then
		self._mover_collision_state = self._mover_collision_state - 1
	else
		self._mover_collision_state = -1
		change_state = true
	end

	if change_state then
		local body = self._unit:body("mover_blocker")

		if body then
			body:set_enabled(state)
		end
	end
end

function CopDamage:anim_clbk_mover_collision_state(unit, state)
	state = state == "true" and true or false

	self:set_mover_collision_state(state)
end

function CopDamage:drop_pickup(extra)
	if self._pickup then
		local tracker = self._unit:movement():nav_tracker()
		local position = tracker:lost() and tracker:field_position() or tracker:position()
		local rotation = self._unit:rotation()

		mvector3.set(mvec_1, position)

		if extra then
			mvector3.set_static(mvec_2, math.random(20, 50) * (math.random(1, 2) * 2 - 3), math.random(20, 50) * (math.random(1, 2) * 2 - 3), 0)
			mvector3.add(mvec_1, mvec_2)
		end

		local level_data = tweak_data.levels[managers.job:current_level_id()]

		if level_data and level_data.drop_pickups_to_ground then
			mvector3.set(mvec_2, math.UP)
			mvector3.multiply(mvec_2, -200)
			mvector3.add(mvec_2, mvec_1)

			local ray = self._unit:raycast("ray", mvec_1, mvec_2, "slot_mask", managers.slot:get_mask("bullet_impact_targets"))

			if ray then
				mvector3.set(mvec_1, ray.hit_position)
			end
		end

		managers.game_play_central:spawn_pickup({
			name = self._pickup,
			position = mvec_1,
			rotation = rotation
		})
	end
end

function CopDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, variant, death)
	if self._dead then
		return
	end

	local body = self._unit:body(i_body)
	local head = self._head_body_name and body and body:name() == self._ids_head_body_name
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + hit_offset_height)

	attack_data.pos = hit_pos
	attack_data.attacker_unit = attacker_unit
	attack_data.variant = "bullet"
	local attack_dir, distance = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()
		distance = mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	local shotgun_push, result = nil

	if death then
		if head and math.random(10) < damage then
			self:_spawn_head_gadget({
				position = body:position(),
				rotation = body:rotation(),
				dir = attack_dir
			})
		end

		result = {
			variant = "bullet",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "bullet")

		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			variant = attack_data.variant
		}

		if data.weapon_unit then
			self:_check_special_death_conditions("bullet", body, attacker_unit, data.weapon_unit)
			managers.statistics:killed_by_anyone(data)

			if data.weapon_unit:base():weapon_tweak_data().is_shotgun then
				shotgun_push = true
			end
		end
	else
		local result_type = variant == 1 and "knock_down" or variant == 2 and "stagger" or self:get_damage_type(damage_percent, "bullet")

		if variant == 3 then
			result_type = "healed"
		end

		result = {
			variant = "bullet",
			type = result_type
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.variant = "bullet"
	attack_data.attacker_unit = attacker_unit
	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	self:_send_sync_bullet_attack_result(attack_data, hit_offset_height)
	self:_on_damage_received(attack_data)

	if shotgun_push then
		managers.game_play_central:do_shotgun_push(self._unit, hit_pos, attack_dir, distance)
	end
end

function CopDamage:chk_killshot(attacker_unit, variant, headshot, weapon_id)
	if attacker_unit and attacker_unit == managers.player:player_unit() then
		managers.player:on_killshot(self._unit, variant, headshot, weapon_id)
	end
end

function CopDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, death, direction, weapon_unit)
	if self._dead then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}
	local result = nil

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)

		local data = {
			variant = "explosion",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = weapon_unit or attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "explosion")
		result = {
			type = result_type,
			variant = variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if self._head_body_name then
		local body = self._unit:body(self._head_body_name)

		self:_spawn_head_gadget({
			skip_push = true,
			position = body:position(),
			rotation = body:rotation(),
			dir = Vector3()
		})
	end

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		managers.hud:on_hit_confirmed()
		managers.statistics:shot_fired({
			hit = true,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		})
	end

	if result.type == "death" then
		local data = {
			variant = "explosion",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		}
		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		self:chk_killshot(attacker_unit, "explosion")

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end
		end
	end

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	if not self._no_blood then
		local hit_pos = mvector3.copy(self._unit:movement():m_pos())

		mvector3.set_z(hit_pos, hit_pos.z + 100)
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_explosion_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

function CopDamage:sync_damage_stun(attacker_unit, damage_percent, i_attack_variant, death, direction)
	if self._dead then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}
	local result = nil
	local result_type = "concussion"
	result = {
		type = result_type,
		variant = variant
	}
	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		managers.hud:on_hit_confirmed()
	end

	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_on_damage_received(attack_data)
	self:_create_stun_exit_clbk()
end

function CopDamage:sync_damage_fire(attacker_unit, damage_percent, start_dot_dance_antimation, death, direction, weapon_type, weapon_id, healed)
	if self._dead then
		return
	end

	local variant = "fire"
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local is_fire_dot_damage = false
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}
	local result = nil

	if weapon_type then
		local fire_dot = nil

		if weapon_type == CopDamage.WEAPON_TYPE_GRANADE then
			fire_dot = tweak_data.projectiles[weapon_id].fire_dot_data
		elseif weapon_type == CopDamage.WEAPON_TYPE_BULLET then
			if tweak_data.weapon.factory.parts[weapon_id].custom_stats then
				fire_dot = tweak_data.weapon.factory.parts[weapon_id].custom_stats.fire_dot_data
			end
		elseif weapon_type == CopDamage.WEAPON_TYPE_FLAMER and tweak_data.weapon[weapon_id].fire_dot_data then
			fire_dot = tweak_data.weapon[weapon_id].fire_dot_data
		end

		attack_data.fire_dot_data = fire_dot

		if attack_data.fire_dot_data then
			attack_data.fire_dot_data.start_dot_dance_antimation = start_dot_dance_antimation
		end
	end

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "fire")

		local data = {
			variant = "fire",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			is_molotov = weapon_id == "molotov"
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "fire")

		if healed then
			result_type = "healed"
		end

		result = {
			variant = "bullet",
			type = result_type
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.ignite_character = true
	attack_data.is_fire_dot_damage = is_fire_dot_damage
	attack_data.is_synced = true
	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if self._head_body_name then
		local body = self._unit:body(self._head_body_name)

		self:_spawn_head_gadget({
			skip_push = true,
			position = body:position(),
			rotation = body:rotation(),
			dir = Vector3()
		})
	end

	if result.type == "death" then
		local data = {
			variant = "fire",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		}
		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end
		end
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_fire_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

function CopDamage:sync_damage_dot(attacker_unit, damage_percent, death, variant, hurt_animation, weapon_id)
	if self._dead then
		return
	end

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}
	local result = nil

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, variant or "dot", nil, weapon_id)

		local real_variant = weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[weapon_id] and "melee" or attack_data.variant
		local data = {
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = not weapon_id and attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			variant = real_variant,
			name_id = weapon_id
		}

		if data.weapon_unit or data.name_id then
			managers.statistics:killed_by_anyone(data)
		end
	else
		local result_type = nil
		result_type = variant == "healed" and "healed" or hurt_animation and self:get_damage_type(damage_percent, variant) or "dmg_rcv"
		result = {
			variant = "bullet",
			type = result_type
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.variant = variant
	attack_data.result = result
	attack_data.damage = damage
	attack_data.weapon_id = weapon_id
	attack_data.is_synced = true

	self:_on_damage_received(attack_data)
end

function CopDamage:sync_damage_simple(attacker_unit, damage_percent, i_attack_variant, i_result, death)
	if self._dead then
		return
	end

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + 100)

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	attack_data.pos = hit_pos
	attack_data.attacker_unit = attacker_unit
	attack_data.variant = variant
	local attack_dir, distance = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()
		distance = mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	local result = nil

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, variant)

		local data = {
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			variant = attack_data.variant
		}

		if data.weapon_unit then
			managers.statistics:killed_by_anyone(data)
		end
	else
		local result_type = i_result == 1 and "knock_down" or i_result == 2 and "stagger" or self:get_damage_type(damage_percent)

		if i_result == 3 then
			result_type = "healed"
		end

		result = {
			type = result_type,
			variant = variant
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	self:_on_damage_received(attack_data)
end

function CopDamage:_sync_dismember(attacker_unit)
	local dismember_victim = false

	if not attacker_unit then
		return dismember_victim
	end

	local attacker_name = managers.criminals:character_name_by_unit(attacker_unit)
	local peer_id = managers.network:session():peer_by_unit(attacker_unit):id()
	local peer = managers.network:session():peer(peer_id)
	local attacker_weapon = peer:melee_id()

	if attacker_name == "dragon" and attacker_weapon == "sandsteel" then
		Application:trace("CopDamage:_dismember_body_part : not yakuza with katana")

		dismember_victim = true
	end

	return dismember_victim
end

function CopDamage:sync_damage_melee(attacker_unit, damage_percent, damage_effect_percent, i_body, hit_offset_height, variant, death)
	local attack_data = {
		variant = "melee",
		attacker_unit = attacker_unit
	}
	local body = self._unit:body(i_body)
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local result = nil

	if death then
		if self:_sync_dismember(attacker_unit) and variant == 6 then
			attack_data.body_name = body:name()

			self:_dismember_body_part(attack_data)
		end

		result = {
			variant = "melee",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "melee")

		local data = {
			variant = "melee",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = variant == 1 and "shield_knock" or variant == 2 and "counter_tased" or variant == 5 and "taser_tased" or variant == 4 and "expl_hurt" or self:get_damage_type(damage_effect_percent, "bullet") or "fire_hurt"
		result = {
			variant = "melee",
			type = result_type
		}

		self:_apply_damage_to_health(damage)

		attack_data.variant = result_type
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if variant == 3 then
		self._unit:unit_data().has_alarm_pager = false
	end

	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(self._unit:movement():m_pos() + Vector3(0, 0, hit_offset_height), attack_dir)
	end

	self:_send_sync_melee_attack_result(attack_data, hit_offset_height)
	self:_on_damage_received(attack_data)
end

function CopDamage:sync_damage_tase(attacker_unit, damage_percent, variant, death)
	if self._dead then
		return
	end

	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	self._tase_effect = World:effect_manager():spawn(self._tase_effect_table)
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		attacker_unit = attacker_unit,
		variant = variant
	}
	local result = nil

	if death then
		result = {
			variant = "bullet",
			type = "death"
		}

		self:die("bullet")
		self:chk_killshot(attacker_unit, "tase")

		local data = {
			variant = "melee",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name
		}

		managers.statistics:killed_by_anyone(data)
	else
		result = {
			type = "taser_tased",
			variant = variant == 1 and "heavy" or "light"
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_tase_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

CopDamage.BODY_INDEX_MAX = 23

function CopDamage:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height, variant)
	if CopDamage.BODY_INDEX_MAX < body_index then
		Application:error(string.format("Attempted to send a bullet attack body index higher than %i, clamping! (was %i)", CopDamage.BODY_INDEX_MAX, body_index))

		body_index = CopDamage.BODY_INDEX_MAX
	end

	self._unit:network():send("damage_bullet", attacker, damage_percent, body_index, hit_offset_height, variant, self._dead and true or false)
end

function CopDamage:_send_explosion_attack_result(attack_data, attacker, damage_percent, i_attack_variant, direction)
	self._unit:network():send("damage_explosion_fire", attacker, damage_percent, i_attack_variant, self._dead and true or false, direction, attack_data.weapon_unit)
end

function CopDamage:_send_stun_attack_result(attacker, damage_percent, i_attack_variant, direction)
	self._unit:network():send("damage_explosion_stun", attacker, damage_percent, i_attack_variant, self._dead and true or false, direction)
end

function CopDamage:_send_fire_attack_result(attack_data, attacker, damage_percent, is_fire_dot_damage, direction, healed)
	local weapon_type, weapon_unit = nil

	if attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:base()._grenade_entry == "molotov" or attack_data.is_molotov then
		weapon_type = CopDamage.WEAPON_TYPE_GRANADE
		weapon_unit = "molotov"
	elseif alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()._name_id ~= nil and tweak_data.weapon[attack_data.weapon_unit:base()._name_id] ~= nil and tweak_data.weapon[attack_data.weapon_unit:base()._name_id].fire_dot_data ~= nil then
		weapon_type = CopDamage.WEAPON_TYPE_FLAMER
		weapon_unit = attack_data.weapon_unit:base()._name_id
	elseif alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()._parts then
		for part_id, part in pairs(attack_data.weapon_unit:base()._parts) do
			if tweak_data.weapon.factory.parts[part_id].custom_stats and tweak_data.weapon.factory.parts[part_id].custom_stats.fire_dot_data then
				weapon_type = CopDamage.WEAPON_TYPE_BULLET
				weapon_unit = part_id
			end
		end
	end

	local start_dot_dance_antimation = attack_data.fire_dot_data and attack_data.fire_dot_data.start_dot_dance_antimation
	damage_percent = math.clamp(damage_percent, 0, 512)

	self._unit:network():send("damage_fire", attacker, damage_percent, start_dot_dance_antimation, self._dead and true or false, direction, weapon_type, weapon_unit, healed)
end

function CopDamage:_send_dot_attack_result(attack_data, attacker, damage_percent, variant, direction)
	self._unit:network():send("damage_dot", attacker, damage_percent, self._dead and true or false, variant, attack_data.hurt_animation, attack_data.weapon_id)
end

function CopDamage:_send_tase_attack_result(attack_data, damage_percent, variant)
	self._unit:network():send("damage_tase", attack_data.attacker_unit, damage_percent, variant, self._dead and true or false)
end

function CopDamage:_send_melee_attack_result(attack_data, damage_percent, damage_effect_percent, hit_offset_height, variant, body_index)
	body_index = math.clamp(body_index, 0, 128)

	self._unit:network():send("damage_melee", attack_data.attacker_unit, damage_percent, damage_effect_percent, body_index, hit_offset_height, variant, self._dead and true or false)
end

function CopDamage:_send_simple_attack_result(attacker, damage_percent, i_attack_variant, i_result)
	self._unit:network():send("damage_simple", attacker, damage_percent, i_attack_variant, i_result, self._dead and true or false)
end

function CopDamage:_send_sync_bullet_attack_result(attack_data, hit_offset_height)
end

function CopDamage:_send_sync_explosion_attack_result(attack_data)
end

function CopDamage:_send_sync_tase_attack_result(attack_data)
end

function CopDamage:_send_sync_melee_attack_result(attack_data, hit_offset_height)
end

function CopDamage:_send_sync_fire_attack_result(attack_data)
end

function CopDamage:sync_death(damage)
	if self._dead then
		return
	end
end

function CopDamage:_on_damage_received(damage_info)
	self:build_suppression("max", nil)
	self:_call_listeners(damage_info)
	CopDamage._notify_listeners("on_damage", damage_info)

	if damage_info.result.type == "death" then
		managers.enemy:on_enemy_died(self._unit, damage_info)

		for c_key, c_data in pairs(managers.groupai:state():all_char_criminals()) do
			if c_data.engaged[self._unit:key()] then
				debug_pause_unit(self._unit:key(), "dead AI engaging player", self._unit, c_data.unit)
			end
		end
	end

	if self._dead and self._unit:movement():attention() then
		debug_pause_unit(self._unit, "[CopDamage:_on_damage_received] dead AI", self._unit, inspect(self._unit:movement():attention()))
	end

	local attacker_unit = damage_info and damage_info.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() then
		if attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
		elseif attacker_unit:base().sentry_gun then
			attacker_unit = attacker_unit:base():get_owner()
		end
	end

	if attacker_unit == managers.player:player_unit() and damage_info then
		managers.player:on_damage_dealt(self._unit, damage_info)
	end

	if damage_info.variant == "melee" then
		managers.statistics:register_melee_hit()
	end

	self:_update_debug_ws(damage_info)
end

function CopDamage:_on_death(variant)
	managers.player:chk_store_armor_health_kill_counter(self._unit, variant)
	managers.player:chk_wild_kill_counter(self._unit, variant)
end

function CopDamage:_call_listeners(damage_info)
	self._listener_holder:call(damage_info.result.type, self._unit, damage_info)
end

function CopDamage:add_listener(key, events, clbk)
	events = events or self._all_event_types

	self._listener_holder:add(key, events, clbk)
end

function CopDamage:call_listener(key, ...)
	self._listener_holder:call(key, ...)
end

function CopDamage:remove_listener(key)
	self._listener_holder:remove(key)
end

function CopDamage:set_pickup(pickup)
	self._pickup = pickup
end

function CopDamage:pickup()
	return self._pickup
end

function CopDamage:health_ratio()
	return self._health_ratio
end

function CopDamage:convert_to_criminal(health_multiplier)
	self:set_mover_collision_state(false)

	self._health = self._HEALTH_INIT
	self._health_ratio = 1
	self._damage_reduction_multiplier = health_multiplier

	self._unit:set_slot(16)
end

function CopDamage:set_invulnerable(state)
	if state then
		self._invulnerable = (self._invulnerable or 0) + 1
	elseif self._invulnerable then
		if self._invulnerable == 1 then
			self._invulnerable = nil
		else
			self._invulnerable = self._invulnerable - 1
		end
	end
end

function CopDamage:set_immortal(immortal)
	self._immortal = immortal
end

function CopDamage:build_suppression(amount, panic_chance)
	if self._dead or not self._char_tweak.suppression then
		return
	end

	local t = TimerManager:game():time()
	local sup_tweak = self._char_tweak.suppression

	if panic_chance and (panic_chance == -1 or panic_chance > 0 and sup_tweak.panic_chance_mul > 0 and math.random() < panic_chance * sup_tweak.panic_chance_mul) then
		amount = "panic"
	end

	local amount_val = nil

	if amount == "max" or amount == "panic" then
		amount_val = (sup_tweak.brown_point or sup_tweak.react_point)[2]
	elseif Network:is_server() and self._suppression_hardness_t and t < self._suppression_hardness_t then
		amount_val = amount * 0.5
	else
		amount_val = amount
	end

	if not Network:is_server() then
		local sync_amount = nil

		if amount == "panic" then
			sync_amount = 16
		elseif amount == "max" then
			sync_amount = 15
		else
			local sync_amount_ratio = nil

			if sup_tweak.brown_point then
				if sup_tweak.brown_point[2] <= 0 then
					sync_amount_ratio = 1
				else
					sync_amount_ratio = amount_val / sup_tweak.brown_point[2]
				end
			elseif sup_tweak.react_point[2] <= 0 then
				sync_amount_ratio = 1
			else
				sync_amount_ratio = amount_val / sup_tweak.react_point[2]
			end

			sync_amount = math.clamp(math.ceil(sync_amount_ratio * 15), 1, 15)
		end

		managers.network:session():send_to_host("suppression", self._unit, sync_amount)

		return
	end

	if self._suppression_data then
		self._suppression_data.value = math.min(self._suppression_data.brown_point or self._suppression_data.react_point, self._suppression_data.value + amount_val)
		self._suppression_data.last_build_t = t
		self._suppression_data.decay_t = t + self._suppression_data.duration

		managers.enemy:reschedule_delayed_clbk(self._suppression_data.decay_clbk_id, self._suppression_data.decay_t)
	else
		local duration = math.lerp(sup_tweak.duration[1], sup_tweak.duration[2], math.random())
		local decay_t = t + duration
		self._suppression_data = {
			value = amount_val,
			last_build_t = t,
			decay_t = decay_t,
			duration = duration,
			react_point = sup_tweak.react_point and math.lerp(sup_tweak.react_point[1], sup_tweak.react_point[2], math.random()),
			brown_point = sup_tweak.brown_point and math.lerp(sup_tweak.brown_point[1], sup_tweak.brown_point[2], math.random()),
			decay_clbk_id = "CopDamage_suppression" .. tostring(self._unit:key())
		}

		managers.enemy:add_delayed_clbk(self._suppression_data.decay_clbk_id, callback(self, self, "clbk_suppression_decay"), decay_t)
	end

	if not self._suppression_data.brown_zone and self._suppression_data.brown_point and self._suppression_data.brown_point <= self._suppression_data.value then
		self._suppression_data.brown_zone = true

		self._unit:brain():on_suppressed(amount == "panic" and "panic" or true)
	elseif amount == "panic" then
		self._unit:brain():on_suppressed("panic")
	end

	if not self._suppression_data.react_zone and self._suppression_data.react_point and self._suppression_data.react_point <= self._suppression_data.value then
		self._suppression_data.react_zone = true

		self._unit:movement():on_suppressed(amount == "panic" and "panic" or true)
	elseif amount == "panic" then
		self._unit:movement():on_suppressed("panic")
	end
end

function CopDamage:clbk_suppression_decay()
	local sup_data = self._suppression_data
	self._suppression_data = nil

	if not alive(self._unit) or self._dead then
		return
	end

	if sup_data.react_zone then
		self._unit:movement():on_suppressed(false)
	end

	if sup_data.brown_zone then
		self._unit:brain():on_suppressed(false)
	end

	self._suppression_hardness_t = TimerManager:game():time() + 30
end

function CopDamage:last_suppression_t()
	return self._suppression_data and self._suppression_data.last_build_t
end

function CopDamage:focus_delay_mul()
	return 1
end

function CopDamage:shoot_pos_mid(m_pos)
	self._spine2_obj:m_position(m_pos)
end

function CopDamage:on_marked_state(state, bonus_distance_damage)
	if state then
		self._marked_dmg_mul = self._marked_dmg_mul or tweak_data.upgrades.values.player.marked_enemy_damage_mul
		self._marked_dmg_dist_mul = bonus_distance_damage
	else
		self._marked_dmg_mul = nil
		self._marked_dmg_dist_mul = nil
	end
end

function CopDamage:_get_attack_variant_index(variant)
	local attack_variants = CopDamage._ATTACK_VARIANTS

	for i, test_variant in ipairs(attack_variants) do
		if variant == test_variant then
			return i
		end
	end

	debug_pause("variant not found!", variant, inspect(attack_variants))

	return 1
end

function CopDamage:_create_debug_ws()
	self._gui = World:newgui()
	local obj = self._unit:get_object(Idstring("Head"))
	self._ws = self._gui:create_linked_workspace(100, 100, obj, obj:position() + obj:rotation():y() * 25, obj:rotation():x() * 50, obj:rotation():y() * 50)

	self._ws:set_billboard(self._ws.BILLBOARD_BOTH)
	self._ws:panel():text({
		name = "health",
		vertical = "top",
		visible = true,
		font_size = 30,
		align = "left",
		font = "fonts/font_medium_shadow_mf",
		y = 0,
		render_template = "OverlayVertexColorTextured",
		layer = 1,
		text = "" .. self._health,
		color = Color.white
	})
	self._ws:panel():text({
		name = "ld",
		vertical = "top",
		visible = true,
		font_size = 30,
		align = "left",
		text = "",
		font = "fonts/font_medium_shadow_mf",
		y = 30,
		render_template = "OverlayVertexColorTextured",
		layer = 1,
		color = Color.white
	})
	self._ws:panel():text({
		name = "variant",
		vertical = "top",
		visible = true,
		font_size = 30,
		align = "left",
		text = "",
		font = "fonts/font_medium_shadow_mf",
		y = 60,
		render_template = "OverlayVertexColorTextured",
		layer = 1,
		color = Color.white
	})
	self:_update_debug_ws()
end

function CopDamage:_update_debug_ws(damage_info)
	if alive(self._ws) then
		local str = string.format("HP: %.2f", self._health)

		self._ws:panel():child("health"):set_text(str)
		self._ws:panel():child("ld"):set_text(string.format("LD: %.2f", damage_info and damage_info.damage or 0))
		self._ws:panel():child("variant"):set_text("V: " .. (damage_info and damage_info.variant or "N/A"))

		local vc = Color.white

		if damage_info and damage_info.variant then
			vc = damage_info.variant == "fire" and Color.red or damage_info.variant == "melee" and Color.yellow or Color.white
		end

		self._ws:panel():child("variant"):set_color(vc)

		local function func(o)
			local mt = 0.25
			local t = mt

			while t >= 0 do
				local dt = coroutine.yield()
				t = math.clamp(t - dt, 0, mt)
				local v = t / mt
				local a = 1
				local r = 1
				local g = 0.25 + 0.75 * (1 - v)
				local b = 0.25 + 0.75 * (1 - v)

				o:set_color(Color(a, r, g, b))
			end
		end

		self._ws:panel():child("ld"):animate(func)

		if damage_info and damage_info.damage > 0 then
			local text = self._ws:panel():text({
				font_size = 20,
				vertical = "center",
				h = 40,
				visible = true,
				w = 40,
				align = "center",
				render_template = "OverlayVertexColorTextured",
				font = "fonts/font_medium_shadow_mf",
				y = -20,
				rotation = 360,
				layer = 1,
				text = string.format("%.2f", damage_info.damage),
				color = Color.white
			})

			local function func2(o, dir)
				local mt = 8
				local t = mt

				while t > 0 do
					local dt = coroutine.yield()
					t = math.clamp(t - dt, 0, mt)
					local speed = dt * 100

					o:move(dir * speed, (1 - math.abs(dir)) * -speed)
					text:set_alpha(t / mt)
				end

				self._ws:panel():remove(o)
			end

			local dir = math.sin(Application:time() * 1000)

			text:set_rotation(dir * 90)
			text:animate(func2, dir)
		end
	end
end

function CopDamage:save(data)
	local save_health = self._health ~= self._HEALTH_INIT

	if managers.crime_spree:is_active() then
		save_health = save_health or managers.crime_spree:has_active_modifier_of_type("ModifierEnemyHealthAndDamage")
	end

	if save_health then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.health = self._health
		data.char_dmg.health_init = self._HEALTH_INIT
	end

	if self._invulnerable then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.invulnerable = self._invulnerable
	end

	if self._immortal then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.immortal = self._immortal
	end

	if self._unit:in_slot(16) then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.is_converted = true
	end

	if self._lower_health_percentage_limit then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.lower_health_percentage_limit = self._lower_health_percentage_limit
	end

	if self._dead then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.is_dead = true
	end
end

function CopDamage:load(data)
	if not data.char_dmg then
		return
	end

	if data.char_dmg.health then
		self._health = data.char_dmg.health
		self._HEALTH_INIT = data.char_dmg.health_init or self._HEALTH_INIT
		self._health_ratio = self._health / self._HEALTH_INIT
	end

	if data.char_dmg.invulnerable then
		self._invulnerable = data.char_dmg.invulnerable
	end

	self._immortal = data.char_dmg.immortal or self._immortal

	if data.char_dmg.is_converted then
		self._unit:set_slot(16)
		managers.groupai:state():sync_converted_enemy(self._unit)
		self:set_mover_collision_state(false)

		local add_contour = true
		local tweak_name = alive(self._unit) and self._unit:base() and self._unit:base()._tweak_table

		if tweak_name then
			local char_tweak_data = tweak_data.character[tweak_name]

			if char_tweak_data then
				add_contour = not char_tweak_data.ignores_contours
			end
		end

		if add_contour then
			self._unit:contour():add("friendly", false)
		end
	end

	if data.char_dmg.lower_health_percentage_limit then
		self:_set_lower_health_percentage_limit(data.char_dmg.lower_health_percentage_limit)
	end

	if data.char_dmg.is_dead then
		self._dead = true

		self:_remove_debug_gui()
		self._unit:base():set_slot(self._unit, 17)
		self._unit:inventory():drop_shield()
		self:set_mover_collision_state(false)

		if self._unit:base():has_tag("civilian") then
			managers.enemy:on_civilian_died(self._unit, {})
		else
			managers.enemy:on_enemy_died(self._unit, {})
		end
	end
end

function CopDamage:_apply_damage_to_health(damage)
	self._health = self._health - damage
	self._health_ratio = self._health / self._HEALTH_INIT
end

function CopDamage:host_set_final_lower_health_percentage_limit()
	self:_set_lower_health_percentage_limit(self._char_tweak.FINAL_LOWER_HEALTH_PERCENTAGE_LIMIT)
	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "character_damage", CopDamage.EVENT_IDS.FINAL_LOWER_HEALTH_PERCENTAGE_LIMIT)
end

function CopDamage:sync_net_event(event_id)
	if event_id == CopDamage.EVENT_IDS.FINAL_LOWER_HEALTH_PERCENTAGE_LIMIT then
		self:_set_lower_health_percentage_limit(self._char_tweak.FINAL_LOWER_HEALTH_PERCENTAGE_LIMIT)
	end
end

function CopDamage:_set_lower_health_percentage_limit(lower_health_percentage_limit)
	self._lower_health_percentage_limit = lower_health_percentage_limit
end

function CopDamage:_apply_min_health_limit(damage, damage_percent)
	local lower_health_percentage_limit = self._lower_health_percentage_limit

	if lower_health_percentage_limit then
		local real_damage_percent = damage_percent / self._HEALTH_GRANULARITY
		local new_health_ratio = self._health_ratio - real_damage_percent

		if lower_health_percentage_limit > new_health_ratio then
			real_damage_percent = self._health_ratio - lower_health_percentage_limit
			damage_percent = math.floor(real_damage_percent * self._HEALTH_GRANULARITY)
			damage = damage_percent * self._HEALTH_INIT_PRECENT
		end
	end

	return damage, damage_percent
end

function CopDamage:melee_hit_sfx()
	return "hit_body"
end

function CopDamage:_apply_damage_reduction(damage)
	local damage_reduction = self._unit:movement():team().damage_reduction or 0

	if damage_reduction > 0 then
		damage = damage * (1 - damage_reduction)
	end

	if self._damage_reduction_multiplier then
		damage = damage * self._damage_reduction_multiplier
	end

	return damage
end

function CopDamage:destroy(...)
	self:_remove_debug_gui()
end

function CopDamage:can_kill()
	return not self._char_tweak.permanently_invulnerable and not self.immortal or not self._invulnerable
end
