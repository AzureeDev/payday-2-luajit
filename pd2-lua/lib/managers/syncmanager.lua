SyncManager = SyncManager or class()

function SyncManager:init()
	self._units = {}
	self._synced_units = {}
end

function SyncManager:add_managed_unit(unit_id, script)
	self._units[unit_id] = script
end

function SyncManager:get_managed_unit(id)
	return self._units[id]
end

function SyncManager:add_synced_outfit_unit(unit_id, type, data_string)
	self._synced_units[unit_id] = {
		type = type,
		data = data_string
	}

	managers.network:session():send_to_peers_synched("sync_synced_unit_outfit", unit_id, type, data_string)
end

function SyncManager:remove_synced_outfit_unit(unit_id)
	self._synced_units[unit_id] = nil
end

function SyncManager:resync_all()
	for _, peer in pairs(managers.network:session():peers()) do
		self:send_all_synced_units_to(peer)
	end
end

function SyncManager:send_all_synced_units_to(peer)
	if type(peer) == "number" then
		local find_peer = peer
		peer = nil

		for _, m_peer in pairs(managers.network:session():peers()) do
			if m_peer:id() == find_peer then
				peer = m_peer

				break
			end
		end
	end

	if peer then
		for id, data in pairs(self._synced_units) do
			managers.network:session():send_to_peer(peer, "sync_synced_unit_outfit", id, data.type, data.data)
		end
	end
end

SyncManager.sync_functions = {
	weapon = "handle_synced_weapon_blueprint",
	vault_cash = "handle_synced_vault_cash",
	offshore_gui = "handle_synced_offshore_gui",
	mask = "handle_synced_mask_blueprint"
}

function SyncManager:on_received_synced_outfit(unit_id, type, outfit_string)
	print("[SyncManager] received synced blueprint", type, outfit_string)

	local callback = self[SyncManager.sync_functions[type]]

	if callback then
		callback(self, unit_id, outfit_string)
	else
		Application:error(string.format("[SyncManager] Received invalid outfit type '%s'", tostring(type)))
	end
end

function SyncManager:add_synced_weapon_blueprint(unit_id, factory_id, blueprint)
	local blueprint_string = managers.weapon_factory:blueprint_to_string(factory_id, blueprint)
	blueprint_string = factory_id .. " " .. blueprint_string

	self:add_synced_outfit_unit(unit_id, "weapon", blueprint_string)
	print("[SyncManager] added synced weapon:", unit_id, blueprint_string)
end

function SyncManager:handle_synced_weapon_blueprint(unit_id, data_string)
	local unit_element = self:get_managed_unit(unit_id)

	if unit_element then
		local data = string.split(data_string or "", " ")

		if data then
			local weapon_id = data[1]
			local blueprint_string = string.gsub(data_string, data[1] .. " ", "")
			local blueprint = managers.weapon_factory:unpack_blueprint_from_string(weapon_id, blueprint_string)

			if weapon_id and blueprint then
				unit_element:assemble_weapon(weapon_id, blueprint)
			end
		end
	end
end

function SyncManager:add_synced_mask_blueprint(unit_id, mask_id, blueprint)
	local blueprint_string = string.format("%s %s-%s %s %s", tostring(mask_id), tostring(blueprint.color_a.id), tostring(blueprint.color_b.id), tostring(blueprint.pattern.id), tostring(blueprint.material.id))

	self:add_synced_outfit_unit(unit_id, "mask", blueprint_string)
	print("[SyncManager] added synced mask: ", unit_id, blueprint_string)
end

function SyncManager:handle_synced_mask_blueprint(unit_id, data_string)
	local unit_element = self:get_managed_unit(unit_id)

	if unit_element then
		local mask_id, blueprint = self:_get_mask_id_and_blueprint(data_string)

		unit_element:assemble_mask(mask_id, blueprint)
	end
end

function SyncManager:_get_mask_id_and_blueprint(data_string)
	local data = string.split(data_string or "", " ")
	local mask_id = data[1]
	local color_data = string.split(data[2] or "", "-")
	local blueprint = {
		color_a = {
			id = color_data[1] or "nothing"
		},
		color_b = {
			id = color_data[2] or "nothing"
		},
		pattern = {
			id = data[3] or "no_color_no_material"
		},
		material = {
			id = data[4] or "plastic"
		}
	}

	return mask_id, blueprint
end

function SyncManager:add_synced_offshore_gui(unit_id, visibility, displayed_cash)
	local blueprint = string.format("%s %s", tostring(visibility), tostring(displayed_cash))

	self:add_synced_outfit_unit(unit_id, "offshore_gui", blueprint)
	print("[SyncManager] added synced offshore: ", unit_id, blueprint)
end

function SyncManager:handle_synced_offshore_gui(unit_id, data_string)
	local data = string.split(data_string, " ")
	local unit_element = self:get_managed_unit(unit_id)

	if unit_element then
		unit_element:set_visible(toboolean(data[1]))
		unit_element:update_offshore(tonumber(data[2]))
	end
end

function SyncManager:add_synced_vault_cash(unit_id, tier)
	local blueprint = string.format("%s", tostring(tier))

	self:add_synced_outfit_unit(unit_id, "vault_cash", blueprint)
	print("[SyncManager] added synced vault: ", unit_id, blueprint)
end

function SyncManager:handle_synced_vault_cash(unit_id, data_string)
	local target_tier = tonumber(data_string)
	local unit_element = self:get_managed_unit(unit_id)

	if unit_element and target_tier then
		unit_element:set_active_tier(target_tier)
	end
end
