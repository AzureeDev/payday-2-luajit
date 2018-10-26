HuskPlayerDamage = HuskPlayerDamage or class()

function HuskPlayerDamage:init(unit)
	self._unit = unit
	self._spine2_obj = unit:get_object(Idstring("Spine2"))
	self._listener_holder = EventListenerHolder:new()
	self._mission_damage_blockers = {}
	local level_tweak = tweak_data.levels[managers.job:current_level_id()]

	if level_tweak and level_tweak.is_safehouse and not level_tweak.is_safehouse_combat then
		self:set_mission_damage_blockers("damage_fall_disabled", true)
		self:set_mission_damage_blockers("invulnerable", true)
	end
end

function HuskPlayerDamage:_call_listeners(damage_info)
	CopDamage._call_listeners(self, damage_info)
end

function HuskPlayerDamage:add_listener(...)
	CopDamage.add_listener(self, ...)
end

function HuskPlayerDamage:remove_listener(key)
	CopDamage.remove_listener(self, key)
end

function HuskPlayerDamage:sync_damage_bullet(attacker_unit, damage, i_body, height_offset)
	local attack_data = {
		attacker_unit = attacker_unit,
		attack_dir = attacker_unit and attacker_unit:movement():m_pos() - self._unit:movement():m_pos() or Vector3(1, 0, 0),
		pos = mvector3.copy(self._unit:movement():m_head_pos()),
		result = {
			variant = "bullet",
			type = "hurt"
		}
	}

	self:_call_listeners(attack_data)
end

function HuskPlayerDamage:shoot_pos_mid(m_pos)
	self._spine2_obj:m_position(m_pos)
end

function HuskPlayerDamage:can_attach_projectiles()
	return false
end

function HuskPlayerDamage:set_last_down_time(down_time)
	self._last_down_time = down_time
end

function HuskPlayerDamage:down_time()
	return self._last_down_time
end

function HuskPlayerDamage:arrested()
	return self._unit:movement():current_state_name() == "arrested"
end

function HuskPlayerDamage:incapacitated()
	return self._unit:movement():current_state_name() == "incapacitated"
end

function HuskPlayerDamage:set_mission_damage_blockers(type, state)
	self._mission_damage_blockers[type] = state
end

function HuskPlayerDamage:get_mission_blocker(type)
	return self._mission_damage_blockers[type]
end

function HuskPlayerDamage:dead()
end

function HuskPlayerDamage:damage_bullet(attack_data)
	if managers.mutators:is_mutator_active(MutatorFriendlyFire) then
		self:_send_damage_to_owner(attack_data)
	end
end

function HuskPlayerDamage:damage_melee(attack_data)
	if managers.mutators:is_mutator_active(MutatorFriendlyFire) then
		self:_send_damage_to_owner(attack_data)
	end
end

function HuskPlayerDamage:damage_fire(attack_data)
	if managers.mutators:is_mutator_active(MutatorFriendlyFire) then
		attack_data.damage = attack_data.damage * 0.2

		self:_send_damage_to_owner(attack_data)
	end
end

function HuskPlayerDamage:_send_damage_to_owner(attack_data)
	local peer_id = managers.criminals:character_peer_id_by_unit(self._unit)
	local damage = managers.mutators:modify_value("HuskPlayerDamage:FriendlyFireDamage", attack_data.damage)

	managers.network:session():send_to_peers("sync_friendly_fire_damage", peer_id, attack_data.attacker_unit, damage, attack_data.variant)

	if attack_data.attacker_unit == managers.player:player_unit() then
		managers.hud:on_hit_confirmed()
	end

	managers.job:set_memory("trophy_flawless", true, false)
end

