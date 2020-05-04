CopActionWarp = CopActionWarp or class()

function CopActionWarp:init(action_desc, common_data)
	self._unit = common_data.unit
	self._dynamic_bodies = {}
	local nr_bodies = self._unit:num_bodies()

	for i = 0, nr_bodies - 1 do
		local body = self._unit:body(i)

		if body:dynamic() then
			body:set_keyframed()
			table.insert(self._dynamic_bodies, body)
		end
	end

	self._i_update = 0

	if action_desc.position then
		common_data.ext_movement:set_position(action_desc.position)
	end

	if action_desc.rotation then
		common_data.ext_movement:set_rotation(action_desc.rotation)
	end

	if Network:is_server() then
		local sync_pos, has_sync_pos = nil

		if action_desc.position then
			has_sync_pos = true
			sync_pos = mvector3.copy(action_desc.position)
		else
			has_sync_pos = false
			sync_pos = Vector3()
		end

		local sync_yaw, has_rotation = nil

		if action_desc.rotation then
			has_rotation = true
			local yaw = mrotation.yaw(action_desc.rotation)

			if yaw < 0 then
				yaw = 360 + yaw
			end

			sync_yaw = 1 + math.ceil(yaw * 254 / 360)
		else
			has_rotation = false
		end

		common_data.ext_network:send("action_warp_start", has_sync_pos, sync_pos, has_rotation, sync_yaw)

		if self._unit:movement() and self._unit:movement().set_should_stay then
			self._unit:movement():set_should_stay(false)
		end
	end

	common_data.ext_movement:enable_update()

	return true
end

function CopActionWarp:update(t)
	if self._i_update < 1 then
		self._i_update = self._i_update + 1

		return
	end

	self._expired = true

	for i, body in ipairs(self._dynamic_bodies) do
		body:set_dynamic()
	end
end

function CopActionWarp:type()
	return "warp"
end

function CopActionWarp:expired()
	return self._expired
end

function CopActionWarp:need_upd()
	return true
end

function CopActionWarp:chk_block(action_type, t)
	if action_type == "death" then
		return false
	end

	return true
end
