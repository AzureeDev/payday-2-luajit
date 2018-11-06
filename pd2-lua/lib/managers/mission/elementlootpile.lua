core:import("CoreMissionScriptElement")

ElementLootPile = ElementLootPile or class(CoreMissionScriptElement.MissionScriptElement)

function ElementLootPile:init(...)
	ElementLootPile.super.init(self, ...)

	local max_loot = self:value("max_loot")
	self._remaining_loot = max_loot > 0 and max_loot or 10000000
	self._steal_SO_data = {}
end

function ElementLootPile:on_script_activated()
	ElementLootPile.super.on_script_activated(self)

	if not self._updator and Network:is_server() then
		self._updator = true

		self._mission_script:add_updator(self._id, callback(self, self, "update"))
	end

	self:on_set_enabled()
end

function ElementLootPile:on_set_enabled()
	if self:enabled() then
		self:register_steal_SO()
	else
		self:unregister_steal_SO()
	end
end

function ElementLootPile:update(t, dt)
	if self._next_steal_time ~= nil then
		self._next_steal_time = self._next_steal_time - dt

		if self._next_steal_time <= 0 then
			self._next_steal_time = nil

			if self:enabled() then
				self:register_steal_SO()
			end
		end
	end
end

function ElementLootPile:register_steal_SO()
	if self._remaining_loot <= 0 then
		return
	end

	local loot_index = self._remaining_loot
	local tweak_info = tweak_data.carry[self:value("carry_id")]
	local AI_carry = tweak_info.AI_carry

	if not AI_carry then
		return
	end

	local pos, rot = self:get_orientation()
	local tracker_pickup = managers.navigation:create_nav_tracker(pos, false)
	local pickup_nav_seg = tracker_pickup:nav_segment()
	local pickup_pos = tracker_pickup:field_position()
	local pickup_area = managers.groupai:state():get_area_from_nav_seg_id(pickup_nav_seg)

	managers.navigation:destroy_nav_tracker(tracker_pickup)

	local drop_pos, drop_nav_seg, drop_area = nil
	local drop_point = managers.groupai:state():get_safe_enemy_loot_drop_point(pickup_nav_seg)

	if drop_point then
		drop_pos = mvector3.copy(drop_point.pos)
		drop_nav_seg = drop_point.nav_seg
		drop_area = drop_point.area
	else
		self._next_steal_time = tonumber(self:value("retry_delay")) or 5

		return
	end

	local drop_objective = {
		type = "act",
		interrupt_health = 0.5,
		action_duration = 2,
		haste = "walk",
		pose = "crouch",
		interrupt_dis = 400,
		nav_seg = drop_nav_seg,
		pos = drop_pos,
		area = drop_area,
		fail_clbk = callback(self, self, "on_secure_SO_failed", loot_index),
		complete_clbk = callback(self, self, "on_secure_SO_completed", loot_index),
		action = {
			variant = "untie",
			align_sync = true,
			body_part = 1,
			type = "act"
		}
	}
	local pickup_objective = {
		destroy_clbk_key = false,
		type = "act",
		haste = "run",
		interrupt_health = 0.5,
		pose = "crouch",
		interrupt_dis = 100,
		nav_seg = pickup_nav_seg,
		area = pickup_area,
		pos = pickup_pos,
		fail_clbk = callback(self, self, "on_pickup_SO_failed", loot_index),
		complete_clbk = callback(self, self, "on_pickup_SO_completed", loot_index),
		action = {
			variant = "untie",
			align_sync = true,
			body_part = 1,
			type = "act"
		},
		action_duration = math.lerp(1, 2.5, math.random()),
		followup_objective = drop_objective
	}
	local so_descriptor = {
		interval = 0,
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = pickup_objective,
		search_pos = pickup_objective.pos,
		verification_clbk = callback(self, self, "clbk_pickup_SO_verification", loot_index),
		AI_group = AI_carry.SO_category,
		admin_clbk = callback(self, self, "on_pickup_SO_administered", loot_index)
	}
	local so_id = string.format("carrysteal_%i_pile_%s", loot_index, tostring(self._id))
	self._steal_SO_data[loot_index] = {
		SO_registered = true,
		picked_up = false,
		SO_id = so_id,
		pickup_area = pickup_area,
		pickup_objective = pickup_objective
	}

	managers.groupai:state():add_special_objective(so_id, so_descriptor)

	self._next_steal_time = tonumber(self:value("reissue_delay")) or 30
end

function ElementLootPile:unregister_steal_SO()
	for i, SO_data in pairs(self._steal_SO_data) do
		if SO_data.SO_registered then
			managers.groupai:state():remove_special_objective(SO_data.SO_id)
			managers.groupai:state():unregister_loot(self._unit:key())
		elseif SO_data.thief then
			local thief = SO_data.thief
			SO_data.thief = nil

			if SO_data.picked_up and SO_data.loot_unit and SO_data.loot_unit:carry_data() then
				SO_data.loot_unit:carry_data():unlink()
			end

			if alive(thief) then
				thief:brain():set_objective(nil)
			end
		end
	end

	self._steal_SO_data = {}
end

function ElementLootPile:on_pickup_SO_completed(loot_index, thief)
	if not self._steal_SO_data[loot_index] then
		return
	end

	self._steal_SO_data[loot_index].picked_up = true
	local pos, rot = self:get_orientation()
	local unit = managers.player:server_drop_carry(self:value("carry_id"), 1, true, false, 1, pos, rot, Vector3(0, 0, 0), 0, nil, nil)

	if alive(unit) and unit:carry_data() then
		unit:carry_data():link_to(thief)

		self._steal_SO_data[loot_index].loot_unit = unit
	end

	self._remaining_loot = self._remaining_loot - 1

	if self._remaining_loot > 0 then
		self:register_steal_SO()
	end
end

function ElementLootPile:on_pickup_SO_failed(loot_index, thief)
	if not self._steal_SO_data[loot_index] then
		return
	end

	self._steal_SO_data[loot_index] = nil

	if self._remaining_loot > 0 then
		self:register_steal_SO()
	end
end

function ElementLootPile:on_secure_SO_completed(loot_index, thief)
	if not self._steal_SO_data[loot_index] then
		return
	end

	local unit = self._steal_SO_data[loot_index].loot_unit

	if alive(unit) and unit:carry_data() then
		unit:carry_data():unlink()
	end

	managers.mission:call_global_event("loot_lost")

	self._steal_SO_data[loot_index] = nil
end

function ElementLootPile:on_secure_SO_failed(loot_index, thief)
	if not self._steal_SO_data[loot_index] then
		return
	end

	local unit = self._steal_SO_data[loot_index].loot_unit

	if alive(unit) and unit:carry_data() then
		unit:carry_data():unlink()
		unit:carry_data():_chk_register_steal_SO()
	end

	self._steal_SO_data[loot_index] = nil
end

function ElementLootPile:clbk_pickup_SO_verification(loot_index, candidate_unit)
	if not self._steal_SO_data[loot_index] or not self._steal_SO_data[loot_index].SO_id then
		return
	end

	if candidate_unit:movement():cool() then
		return
	end

	local nav_seg = candidate_unit:movement():nav_tracker():nav_segment()

	if not self._steal_SO_data[loot_index].pickup_area.nav_segs[nav_seg] then
		return
	end

	if not candidate_unit:base():char_tweak().steal_loot then
		return
	end

	return true
end

function ElementLootPile:on_pickup_SO_administered(loot_index, thief)
	if loot_index and self._steal_SO_data[loot_index] and not self._steal_SO_data[loot_index].thief then
		self._steal_SO_data[loot_index].SO_registered = false
	end
end
