DoctorBagBase = DoctorBagBase or class(UnitBase)
DoctorBagBase.amount_upgrade_lvl_shift = 2
DoctorBagBase.damage_reduce_lvl_shift = 4

function DoctorBagBase.spawn(pos, rot, bits, peer_id)
	local unit_name = "units/payday2/equipment/gen_equipment_medicbag/gen_equipment_medicbag"
	local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

	managers.network:session():send_to_peers_synched("sync_equipment_setup", unit, bits, peer_id or 0)
	unit:base():setup(bits)

	return unit
end

function DoctorBagBase:set_server_information(peer_id)
	self._server_information = {owner_peer_id = peer_id}

	managers.network:session():peer(peer_id):set_used_deployable(true)
end

function DoctorBagBase:server_information()
	return self._server_information
end

function DoctorBagBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	self._is_attachable = true

	self._unit:sound_source():post_event("ammo_bag_drop")

	self._max_amount = tweak_data.upgrades.doctor_bag_base + managers.player:upgrade_value_by_level("doctor_bag", "amount_increase", 1)

	if Network:is_client() then
		self._validate_clbk_id = "doctor_bag_validate" .. tostring(unit:key())

		managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
	end

	self._damage_reduction_upgrade = false
end

function DoctorBagBase:get_name_id()
	return "doctor_bag"
end

function DoctorBagBase:_clbk_validate()
	self._validate_clbk_id = nil

	if not self._was_dropin then
		local peer = managers.network:session():server_peer()

		peer:mark_cheater(VoteManager.REASON.many_assets)
	end
end

function DoctorBagBase:sync_setup(bits, peer_id)
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	managers.player:verify_equipment(peer_id, "doctor_bag")
	self:setup(bits)
end

function DoctorBagBase:setup(bits)
	local amount_upgrade_lvl, dmg_reduction_lvl = self:_get_upgrade_levels(bits)
	self._damage_reduction_upgrade = dmg_reduction_lvl ~= 0
	self._amount = tweak_data.upgrades.doctor_bag_base + managers.player:upgrade_value_by_level("doctor_bag", "amount_increase", amount_upgrade_lvl)

	self:_set_visual_stage()

	if Network:is_server() and self._is_attachable then
		local from_pos = self._unit:position() + self._unit:rotation():z() * 10
		local to_pos = self._unit:position() + self._unit:rotation():z() * -10
		local ray = self._unit:raycast("ray", from_pos, to_pos, "slot_mask", managers.slot:get_mask("world_geometry"))

		if ray then
			self._attached_data = {
				body = ray.body,
				position = ray.body:position(),
				rotation = ray.body:rotation(),
				index = 1,
				max_index = 3
			}

			self._unit:set_extension_update_enabled(Idstring("base"), true)
		end
	end
end

function DoctorBagBase:update(unit, t, dt)
	self:_check_body()
end

function DoctorBagBase:_check_body()
	if self._is_dynamic then
		return
	end

	if not alive(self._attached_data.body) then
		self:server_set_dynamic()

		return
	end

	if self._attached_data.index == 1 then
		if not self._attached_data.body:enabled() then
			self:server_set_dynamic()
		end
	elseif self._attached_data.index == 2 then
		if not mrotation.equal(self._attached_data.rotation, self._attached_data.body:rotation()) then
			self:server_set_dynamic()
		end
	elseif self._attached_data.index == 3 and mvector3.not_equal(self._attached_data.position, self._attached_data.body:position()) then
		self:server_set_dynamic()
	end

	self._attached_data.index = (self._attached_data.index < self._attached_data.max_index and self._attached_data.index or 0) + 1
end

function DoctorBagBase:server_set_dynamic()
	self:_set_dynamic()

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", 1)
	end
end

function DoctorBagBase:sync_net_event(event_id)
	self:_set_dynamic()
end

function DoctorBagBase:_set_dynamic()
	self._is_dynamic = true

	self._unit:body("dynamic"):set_enabled(true)
end

function DoctorBagBase:take(unit)
	if self._empty then
		return
	end

	if self._damage_reduction_upgrade then
		managers.player:activate_temporary_upgrade("temporary", "first_aid_damage_reduction")
	end

	local taken = self:_take(unit)

	if taken > 0 then
		unit:sound():play("pickup_ammo")
		managers.network:session():send_to_peers_synched("sync_doctor_bag_taken", self._unit, taken)
		managers.mission:call_global_event("player_refill_doctorbag")
	end

	if self._amount <= 0 then
		self:_set_empty()
	else
		self:_set_visual_stage()
	end

	return taken > 0
end

function DoctorBagBase:_set_visual_stage()
	local percentage = self._amount / self._max_amount

	if self._unit:damage() then
		local state = "state_" .. math.ceil(percentage * 4)

		if self._unit:damage():has_sequence(state) then
			self._unit:damage():run_sequence_simple(state)
		end
	end
end

function DoctorBagBase:sync_taken(amount)
	self._amount = self._amount - amount

	if self._amount <= 0 then
		self:_set_empty()
	else
		self:_set_visual_stage()
	end
end

function DoctorBagBase:_take(unit)
	local taken = 1
	self._amount = self._amount - taken

	unit:character_damage():recover_health()

	local rally_skill_data = unit:movement():rally_skill_data()

	if rally_skill_data then
		rally_skill_data.morale_boost_delay_t = (managers.player:has_category_upgrade("player", "morale_boost") or managers.player:has_enabled_cooldown_upgrade("cooldown", "long_dis_revive")) and 0 or nil
	end

	return taken
end

function DoctorBagBase:_set_empty()
	self._empty = true

	self._unit:set_slot(0)
end

function DoctorBagBase:_get_upgrade_levels(bits)
	local dmg_reduction = Bitwise:rshift(bits, DoctorBagBase.damage_reduce_lvl_shift)
	local amount_lvl = Bitwise:rshift(bits, DoctorBagBase.amount_upgrade_lvl_shift) % 2 ^ DoctorBagBase.amount_upgrade_lvl_shift

	return amount_lvl, dmg_reduction
end

function DoctorBagBase:save(data)
	local state = {
		amount = self._amount,
		is_dynamic = self._is_dynamic
	}
	data.DoctorBagBase = state
end

function DoctorBagBase:load(data)
	local state = data.DoctorBagBase
	self._amount = state.amount

	if state.is_dynamic then
		self:_set_dynamic()
	end

	self:_set_visual_stage()

	self._was_dropin = true
end

function DoctorBagBase:destroy()
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end
end
CustomDoctorBagBase = CustomDoctorBagBase or class(DoctorBagBase)

function CustomDoctorBagBase:init(unit)
	CustomDoctorBagBase.super.init(self, unit)

	self._is_attachable = self.is_attachable or false

	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	self:setup(self.upgrade_lvl or 0)
end

function CustomDoctorBagBase:_set_empty()
	self._empty = true

	if alive(self._unit) then
		self._unit:interaction():set_active(false)
	end

	if self._unit:damage():has_sequence("empty") then
		self._unit:damage():run_sequence_simple("empty")
	end
end

