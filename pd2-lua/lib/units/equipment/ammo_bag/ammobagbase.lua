AmmoBagBase = AmmoBagBase or class(UnitBase)
AmmoBagBase._BULLET_STORM = {
	2.5,
	10
}
local dec_mul = 10000
local unit_name = "units/payday2/equipment/gen_equipment_ammobag/gen_equipment_ammobag"

function AmmoBagBase.spawn(pos, rot, ammo_upgrade_lvl, peer_id, bullet_storm_level)
	local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

	managers.network:session():send_to_peers_synched("sync_ammo_bag_setup", unit, ammo_upgrade_lvl, peer_id or 0, bullet_storm_level or 0)
	unit:base():setup(ammo_upgrade_lvl, bullet_storm_level)

	return unit
end

function AmmoBagBase:set_server_information(peer_id)
	self._server_information = {
		owner_peer_id = peer_id
	}

	managers.network:session():peer(peer_id):set_used_deployable(true)
end

function AmmoBagBase:server_information()
	return self._server_information
end

function AmmoBagBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	self._is_attachable = true
	self._bullet_storm_level = 0
	self._max_ammo_amount = tweak_data.upgrades.ammo_bag_base + managers.player:upgrade_value_by_level("ammo_bag", "ammo_increase", 1)

	self._unit:sound_source():post_event("ammo_bag_drop")

	if Network:is_client() then
		self._validate_clbk_id = "ammo_bag_validate" .. tostring(unit:key())

		managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
	end
end

function AmmoBagBase:get_name_id()
	return "ammo_bag"
end

function AmmoBagBase:_clbk_validate()
	self._validate_clbk_id = nil

	if not self._was_dropin then
		local peer = managers.network:session():server_peer()

		peer:mark_cheater(VoteManager.REASON.many_assets)
	end
end

function AmmoBagBase:sync_setup(ammo_upgrade_lvl, peer_id, bullet_storm_level)
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	managers.player:verify_equipment(peer_id, "ammo_bag")
	self:setup(ammo_upgrade_lvl, bullet_storm_level)
end

function AmmoBagBase:setup(ammo_upgrade_lvl, bullet_storm_level)
	self._bullet_storm_level = bullet_storm_level
	self._ammo_amount = tweak_data.upgrades.ammo_bag_base + managers.player:upgrade_value_by_level("ammo_bag", "ammo_increase", ammo_upgrade_lvl)

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

function AmmoBagBase:update(unit, t, dt)
	self:_check_body()
end

function AmmoBagBase:_check_body()
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

function AmmoBagBase:server_set_dynamic()
	self:_set_dynamic()

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", 1)
	end
end

function AmmoBagBase:sync_net_event(event_id)
	self:_set_dynamic()
end

function AmmoBagBase:_set_dynamic()
	self._is_dynamic = true

	self._unit:body("dynamic"):set_enabled(true)
end

function AmmoBagBase:take_ammo(unit)
	if self._empty then
		return false, false
	end

	local taken = self:_take_ammo(unit)

	if taken > 0 then
		unit:sound():play("pickup_ammo")
		managers.network:session():send_to_peers_synched("sync_ammo_bag_ammo_taken", self._unit, taken)
	end

	if self._ammo_amount <= 0 then
		self:_set_empty()
	else
		self:_set_visual_stage()
	end

	local bullet_storm = false

	if self._bullet_storm_level and self._bullet_storm_level > 0 then
		bullet_storm = self._BULLET_STORM[self._bullet_storm_level] * taken
	end

	return taken > 0, bullet_storm
end

function AmmoBagBase:_set_visual_stage()
	local percentage = self._ammo_amount / self._max_ammo_amount

	if self._unit:damage() then
		local state = "state_" .. math.ceil(percentage * 6)

		if self._unit:damage():has_sequence(state) then
			self._unit:damage():run_sequence_simple(state)
		end
	end
end

function AmmoBagBase:sync_ammo_taken(amount)
	amount = self:round_value(amount)
	self._ammo_amount = self:round_value(self._ammo_amount - amount)

	if self._ammo_amount <= 0 then
		self:_set_empty()
	else
		self:_set_visual_stage()
	end
end

function AmmoBagBase:_take_ammo(unit)
	local taken = 0
	local inventory = unit:inventory()

	if inventory then
		for _, weapon in pairs(inventory:available_selections()) do
			local took = self:round_value(weapon.unit:base():add_ammo_from_bag(self._ammo_amount))
			taken = taken + took
			self._ammo_amount = self:round_value(self._ammo_amount - took)

			if self._ammo_amount <= 0 then
				taken = self._max_ammo_amount

				self:_set_empty()

				return taken
			end
		end
	end

	return taken
end

function AmmoBagBase:_set_empty()
	self._ammo_amount = 0
	self._empty = true

	if Network:is_server() then
		self._unit:set_slot(0)
	else
		self._unit:set_enabled(false)
		self._unit:set_visible(false)
		self._unit:interaction():set_active(false)
	end
end

function AmmoBagBase:save(data)
	local state = {
		ammo_amount = self._ammo_amount,
		is_dynamic = self._is_dynamic,
		bullet_storm_level = self._bullet_storm_level
	}
	data.AmmoBagBase = state
end

function AmmoBagBase:load(data)
	local state = data.AmmoBagBase
	self._ammo_amount = state.ammo_amount
	self._bullet_storm_level = state.bullet_storm_level

	if state.is_dynamic then
		self:_set_dynamic()
	end

	self:_set_visual_stage()

	self._was_dropin = true
end

function AmmoBagBase:round_value(val)
	return math.floor(val * dec_mul) / dec_mul
end

function AmmoBagBase:destroy()
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end
end

CustomAmmoBagBase = CustomAmmoBagBase or class(AmmoBagBase)

function CustomAmmoBagBase:init(unit)
	CustomAmmoBagBase.super.init(self, unit)

	self._is_attachable = self.is_attachable or false

	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	self:setup(self.upgrade_lvl or 0)
end

function CustomAmmoBagBase:_set_empty()
	self._empty = true

	if alive(self._unit) then
		self._unit:interaction():set_active(false)
	end

	if self._unit:damage():has_sequence("empty") then
		self._unit:damage():run_sequence_simple("empty")
	end
end
