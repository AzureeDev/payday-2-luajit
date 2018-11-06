BodyBagsBagBase = BodyBagsBagBase or class(UnitBase)

function BodyBagsBagBase.spawn(pos, rot, upgrade_lvl, peer_id)
	local unit_name = "units/payday2/equipment/gen_equipment_bodybags_bag/gen_equipment_bodybags_bag"
	local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

	managers.network:session():send_to_peers_synched("sync_equipment_setup", unit, upgrade_lvl, peer_id or 0)
	unit:base():setup(upgrade_lvl)

	return unit
end

function BodyBagsBagBase:set_server_information(peer_id)
	self._server_information = {
		owner_peer_id = peer_id
	}

	managers.network:session():peer(peer_id):set_used_deployable(true)
end

function BodyBagsBagBase:server_information()
	return self._server_information
end

function BodyBagsBagBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	self._is_attachable = true
	self._max_bodybag_amount = tweak_data.upgrades.bodybag_crate_base

	self._unit:sound_source():post_event("ammo_bag_drop")

	if Network:is_client() then
		self._validate_clbk_id = "bodybags_bag_validate" .. tostring(unit:key())

		managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
	end
end

function BodyBagsBagBase:get_name_id()
	return "bodybags_bag"
end

function BodyBagsBagBase:_clbk_validate()
	self._validate_clbk_id = nil

	if not self._was_dropin then
		local peer = managers.network:session():server_peer()

		peer:mark_cheater(VoteManager.REASON.many_assets)
	end
end

function BodyBagsBagBase:sync_setup(upgrade_lvl, peer_id)
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	managers.player:verify_equipment(peer_id, "bodybags_bag")
	self:setup(upgrade_lvl)
end

function BodyBagsBagBase:setup()
	self._bodybag_amount = tweak_data.upgrades.bodybag_crate_base
	self._empty = false

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

function BodyBagsBagBase:update(unit, t, dt)
	self:_check_body()
end

function BodyBagsBagBase:_check_body()
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

function BodyBagsBagBase:server_set_dynamic()
	self:_set_dynamic()

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", 2)
	end
end

function BodyBagsBagBase:sync_net_event(event_id)
	if event_id == 1 then
		self:sync_bodybag_taken(1)
	elseif event_id == 2 then
		self:_set_dynamic()
	end
end

function BodyBagsBagBase:_set_dynamic()
	self._is_dynamic = true

	self._unit:body("dynamic"):set_enabled(true)
end

function BodyBagsBagBase:take_bodybag(unit)
	if self._empty then
		return
	end

	local can_take_bodybag = self:_can_take_bodybag() and 1 or 0

	if can_take_bodybag == 1 then
		unit:sound():play("pickup_ammo")
		managers.player:add_body_bags_amount(1)
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", 1)

		self._bodybag_amount = self._bodybag_amount - 1

		managers.mission:call_global_event("player_refill_bodybagsbag")
	end

	if self._bodybag_amount <= 0 then
		self:_set_empty()
	end

	self:_set_visual_stage()

	return can_take_bodybag
end

function BodyBagsBagBase:_set_visual_stage()
	if alive(self._unit) and self._unit:damage() then
		local state = "state_" .. tostring(math.clamp(self._max_bodybag_amount - self._bodybag_amount, 0, self._max_bodybag_amount))

		if self._unit:damage():has_sequence(state) then
			self._unit:damage():run_sequence_simple(state)
		end
	end
end

function BodyBagsBagBase:sync_bodybag_taken(amount)
	self._bodybag_amount = self._bodybag_amount - amount

	if self._bodybag_amount <= 0 then
		self:_set_empty()
	end

	self:_set_visual_stage()
end

function BodyBagsBagBase:_can_take_bodybag(unit)
	if self._empty or self._bodybag_amount < 1 or managers.player:has_max_body_bags() then
		return false
	end

	return true
end

function BodyBagsBagBase:_set_empty()
	self._empty = true

	if alive(self._unit) then
		self._unit:interaction():set_active(false)
	end
end

function BodyBagsBagBase:save(data)
	local state = {
		bodybag_amount = self._bodybag_amount,
		is_dynamic = self._is_dynamic
	}
	data.BodyBagsBagBase = state
end

function BodyBagsBagBase:load(data)
	local state = data.BodyBagsBagBase
	self._bodybag_amount = state.bodybag_amount

	if state.is_dynamic then
		self:_set_dynamic()
	end

	if self._bodybag_amount <= 0 then
		self:_set_empty()
	end

	self:_set_visual_stage()

	self._was_dropin = true
end

function BodyBagsBagBase:destroy()
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end
end

CustomBodyBagsBagBase = CustomBodyBagsBagBase or class(BodyBagsBagBase)

function CustomBodyBagsBagBase:init(unit)
	CustomBodyBagsBagBase.super.init(self, unit)

	self._is_attachable = self.is_attachable or false

	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	self:setup(self.upgrade_lvl or 0)
end

function CustomBodyBagsBagBase:_set_empty()
	self._empty = true

	if alive(self._unit) then
		self._unit:interaction():set_active(false)
	end

	if self._unit:damage():has_sequence("empty") then
		self._unit:damage():run_sequence_simple("empty")
	end
end
