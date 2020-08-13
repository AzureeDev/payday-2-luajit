MissionAssetsManager = MissionAssetsManager or class()
MissionAssetsManager.ALLOW_CLIENTS_UNLOCK = true

function MissionAssetsManager:init()
	self:_setup()
end

function MissionAssetsManager:_setup()
	self._requested_textures = {}
	self._asset_textures_in_loading = {}
	self._asset_textures_loaded = {}
	local assets = {}
	Global.asset_manager = {
		assets = assets
	}
	self._global = Global.asset_manager
	self._tweak_data = tweak_data.assets
	self._money_spent = 0
	self._triggers = {}

	self:_setup_mission_assets()
end

function MissionAssetsManager:_setup_mission_assets()
	local is_host = Network:is_server() or Global.game_settings.single_player
	local current_stage = managers.job:current_level_id()

	if managers.crime_spree and managers.crime_spree:is_active() then
		local mission = managers.crime_spree:get_mission(managers.crime_spree:current_mission())
		current_stage = mission and mission.level and mission.level.level_id
	end

	if not current_stage or not is_host then
		return
	end

	for id, asset in pairs(self._tweak_data) do
		if asset.stages and (type(asset.stages) == "table" and table.contains(asset.stages, current_stage) or asset.stages == "all" and (not asset.exclude_stages or not table.contains(asset.exclude_stages, current_stage))) then
			local requirements = {
				saved_job_lock = nil,
				job_lock = nil,
				money_lock = nil,
				upgrade_lock = nil,
				achievment_lock = nil,
				risk_lock = nil,
				dlc_lock = nil
			}
			local can_unlock = false
			local require_to_unlock = asset.require_to_unlock or "all"

			if asset.money_lock then
				requirements.money_lock = false
				can_unlock = true
			end

			if asset.saved_job_lock then
				local saved_job_lock = asset.saved_job_lock

				if type(saved_job_lock) == "table" then
					local saved_job_value = managers.mission:get_saved_job_value(saved_job_lock[1]) or 0
					local operator = saved_job_lock[2] or "=="
					local check_value = saved_job_lock[3] or 0
					local function_string = "return " .. tostring(tonumber(saved_job_value) or 0) .. operator .. tostring(tonumber(check_value) or 0)
					requirements.saved_job_lock = loadstring(function_string)() or false
				else
					requirements.saved_job_lock = managers.mission:get_saved_job_value(saved_job_lock) or false
				end

				can_unlock = requirements.saved_job_lock and can_unlock or false
			end

			if asset.job_lock then
				local job_lock = asset.job_lock

				if type(job_lock) == "table" then
					local job_value = managers.mission:get_job_value(job_lock[1]) or 0
					local operator = job_lock[2] or "=="
					local check_value = job_lock[3] or 0
					local function_string = "return " .. tostring(tonumber(job_value) or 0) .. operator .. tostring(tonumber(check_value) or 0)
					requirements.job_lock = loadstring(function_string)() or false
				else
					requirements.job_lock = managers.mission:get_job_value(job_lock) or false
				end

				can_unlock = requirements.job_lock and can_unlock or false
			end

			if asset.upgrade_lock then
				requirements.upgrade_lock = managers.player:has_category_upgrade(asset.upgrade_lock.category, asset.upgrade_lock.upgrade)
				can_unlock = requirements.upgrade_lock and can_unlock or false
			end

			if asset.achievment_lock then
				requirements.achievment_lock = managers.achievment:exists(asset.achievment_lock) and managers.achievment:get_info(asset.achievment_lock).awarded
				can_unlock = requirements.achievment_lock and can_unlock or false
			end

			if asset.dlc_lock then
				requirements.dlc_lock = managers.dlc:is_dlc_unlocked(asset.dlc_lock)
				can_unlock = requirements.dlc_lock and can_unlock or false
			end

			if asset.risk_lock then
				requirements.risk_lock = managers.job:current_difficulty_stars() == asset.risk_lock
				can_unlock = requirements.risk_lock and can_unlock or false
			end

			local needs_any = Idstring(require_to_unlock) == Idstring("any")
			local unlocked = true
			local local_only = asset.local_only

			if needs_any and asset.money_lock then
				can_unlock = true
			end

			for id, exist in pairs(requirements) do
				if exist then
					if needs_any then
						unlocked = true

						break
					end
				else
					unlocked = false

					if not needs_any then
						break
					end
				end
			end

			local show = unlocked or can_unlock or asset.visible_if_locked

			if local_only then
				show = nil
				unlocked = true
				can_unlock = true
			end

			table.insert(self._global.assets, {
				id = id,
				unlocked = unlocked,
				show = show,
				can_unlock = can_unlock,
				no_mystery = asset.no_mystery,
				local_only = local_only
			})
		end
	end

	table.sort(self._global.assets, function (x, y)
		if x.local_only ~= y.local_only then
			return x.local_only
		elseif x.show ~= y.show then
			return x.show
		elseif x.unlocked ~= y.unlocked then
			return x.unlocked
		end

		if x.no_mystery ~= y.no_mystery then
			return x.no_mystery
		end

		if self._tweak_data[x.id].money_lock and self._tweak_data[y.id].money_lock then
			return self._tweak_data[x.id].money_lock < self._tweak_data[y.id].money_lock
		elseif self._tweak_data[x.id].money_lock then
			return true
		elseif self._tweak_data[y.id].money_lock then
			return false
		else
			return x.id < y.id
		end
	end)
end

function MissionAssetsManager:init_finalize()
	local is_server = Network:is_server() or Global.game_settings.single_player
	local current_stage = managers.job:current_level_id()

	if not current_stage or not is_server then
		return
	end

	self:create_asset_textures()
end

function MissionAssetsManager:clear()
	Global.asset_manager = nil
	self._money_spent = 0
end

function MissionAssetsManager:reset()
	Global.asset_manager = nil
	local old_triggers = self._triggers

	self:_setup()

	self._triggers = old_triggers
end

function MissionAssetsManager:on_simulation_ended()
	self:reset()
end

function MissionAssetsManager:on_profile_switch()
	local assets_to_update = {}
	self._locally_unlocked_assets = self._locally_unlocked_assets or {}

	for _, id in pairs(self._locally_unlocked_assets) do
		if self._tweak_data[id].upgrade_lock and not self:get_asset_can_unlock_by_id(id) then
			table.insert(assets_to_update, id)
		end
	end

	if #assets_to_update ~= 0 then
		local string_table = self:_make_string_index_table(assets_to_update)

		if Network:is_server() then
			self:server_recheck_assets(string_table)
		else
			managers.network:session():send_to_host("server_recheck_assets", string_table)
		end
	end
end

function MissionAssetsManager:on_peer_removed(peer_id)
	local asset_ids_to_relock = {}

	for _, asset in ipairs(self._global.assets) do
		local td = self:get_asset_tweak_data_by_id(asset.id)

		if asset.unlocked and td.upgrade_lock and asset.peer_id and asset.peer_id == peer_id then
			table.insert(asset_ids_to_relock, asset.id)

			asset.peer_id = ""
		end
	end

	if #asset_ids_to_relock ~= 0 then
		local string_table = self:_make_string_index_table(asset_ids_to_relock)

		self:server_recheck_assets(string_table)
	end
end

function MissionAssetsManager:add_trigger(id, type, asset_id, callback)
	self._triggers[type] = self._triggers[type] or {}
	self._triggers[type][id] = {
		id = asset_id,
		callback = callback
	}
end

function MissionAssetsManager:check_triggers(type)
	if not self._triggers[type] then
		return
	end

	for id, cb_data in pairs(self._triggers[type]) do
		local asset = self:_get_asset_by_id(cb_data.id)

		if type ~= "asset" or asset and asset.unlocked and not asset.is_triggered then
			cb_data.callback()

			if asset then
				asset.is_triggered = true

				self:trigger_asset_tweak(cb_data.id)
			end
		end
	end
end

function MissionAssetsManager:trigger_asset_tweak(asset_id)
	local asset_tweak_data = tweak_data.assets[asset_id]

	if not asset_tweak_data then
		return
	end

	local set_job_value = asset_tweak_data.set_job_value

	if set_job_value then
		managers.mission:set_job_value(set_job_value[1], set_job_value[2])
	end

	local set_saved_job_value = asset_tweak_data.set_saved_job_value

	if set_saved_job_value then
		managers.mission:set_saved_job_value(set_saved_job_value[1], set_saved_job_value[2])
	end
end

function MissionAssetsManager:unlock_asset(asset_id, is_show_chat_message)
	if Idstring(asset_id) == Idstring("none") then
		return
	end

	if not self:is_unlock_asset_allowed() then
		return
	end

	if Network:is_server() then
		if not self:get_asset_triggered_by_id(asset_id) then
			self._money_spent = self._money_spent + managers.money:on_buy_mission_asset(asset_id)

			self:server_unlock_asset(asset_id, is_show_chat_message)
			self:_on_asset_unlocked(asset_id)
		end
	elseif self.ALLOW_CLIENTS_UNLOCK and not self:get_asset_unlocked_by_id(asset_id) then
		self._money_spent = self._money_spent + managers.money:on_buy_mission_asset(asset_id)

		managers.network:session():send_to_host("server_unlock_asset", asset_id, is_show_chat_message)
		self:_on_asset_unlocked(asset_id)
	end

	if WalletGuiObject then
		WalletGuiObject.refresh()
	end
end

function MissionAssetsManager:_on_asset_unlocked(asset_id)
	self._locally_unlocked_assets = self._locally_unlocked_assets or {}

	if not table.contains(self._locally_unlocked_assets, asset_id) then
		table.insert(self._locally_unlocked_assets, asset_id)
	end

	self._awarded_assets = self._awarded_assets or {}

	if not table.contains(self._awarded_assets, asset_id) then
		local asset_tweak_data = self._tweak_data[asset_id]

		if asset_tweak_data and asset_tweak_data.award_achievement then
			managers.achievment:award(asset_tweak_data.award_achievement)
		end

		if asset_tweak_data and asset_tweak_data.progress_stat then
			managers.achievment:award_progress(asset_tweak_data.progress_stat)
		end

		table.insert(self._awarded_assets, asset_id)
	end
end

function MissionAssetsManager:server_unlock_asset(asset_id, is_show_chat_message, peer)
	if not self:is_unlock_asset_allowed() then
		return
	end

	peer = peer or managers.network:session():local_peer()
	self:_get_asset_by_id(asset_id).peer_id = peer:id()

	managers.network:session():send_to_peers_synched("sync_unlock_asset", asset_id, is_show_chat_message, peer:id())
	self:sync_unlock_asset(asset_id, is_show_chat_message, peer)
end

function MissionAssetsManager:sync_unlock_asset(asset_id, is_show_chat_message, peer)
	local asset = self:_get_asset_by_id(asset_id)

	if not asset then
		Application:error("sync_set_asset_enabled: No asset with id:", asset_id)

		return
	end

	if asset.unlocked then
		Application:error("sync_set_asset_enabled: Asset already unlocked:", asset_id)

		return
	end

	asset.unlocked = true

	managers.menu_component:unlock_asset_mission_briefing_gui(asset_id)
	self:trigger_asset_tweak(asset_id)

	if managers.chat and peer then
		local asset_tweak_data = tweak_data.assets[asset_id]

		if asset_tweak_data and is_show_chat_message then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_unlocked_asset", {
				name = peer:name(),
				asset = managers.localization:text(asset_tweak_data.name_id)
			}))
		end
	end
end

function MissionAssetsManager:server_recheck_assets(string_table)
	if string_table == "" then
		return
	end

	local asset_ids = self:_read_string_index_table(string_table)

	for _, id in ipairs(asset_ids) do
		local td = self:get_asset_tweak_data_by_id(id)

		if not td.upgrade_lock then
			return
		end
	end

	managers.network:session():send_to_peers_synched("sync_relock_assets", string_table)
	self:sync_relock_assets(string_table)
end

function MissionAssetsManager:sync_relock_assets(string_table)
	local asset_ids = self:_read_string_index_table(string_table)

	if #asset_ids ~= 0 then
		for _, id in ipairs(asset_ids) do
			local asset = self:_get_asset_by_id(id)
			asset.unlocked = false
			self._locally_unlocked_assets = self._locally_unlocked_assets or {}

			for i, asset_id in pairs(self._locally_unlocked_assets) do
				if asset_id == id then
					self._locally_unlocked_assets[i] = nil

					managers.money:refund_mission_asset(id)

					if WalletGuiObject then
						WalletGuiObject.refresh()
					end
				end
			end
		end

		self:reload_textures()
	end
end

function MissionAssetsManager:unlock_all_availible_assets()
	for _, asset in pairs(self._global.assets) do
		if asset.show and not asset.unlocked and self:get_asset_can_unlock_by_id(asset.id) then
			self:unlock_asset(asset.id, true)
		end
	end
end

function MissionAssetsManager:_get_asset_by_id(id)
	for _, asset in pairs(self._global.assets) do
		if asset.id == id then
			return asset
		end
	end
end

function MissionAssetsManager:_is_asset_unlockable(id)
	local asset_tweak_data = self:get_asset_tweak_data_by_id(id)

	if not asset_tweak_data then
		return false
	end

	local upgrade_lock, achievment_lock, dlc_lock = nil
	local can_unlock = true

	if asset_tweak_data.upgrade_lock then
		upgrade_lock = managers.player:has_category_upgrade(asset_tweak_data.upgrade_lock.category, asset_tweak_data.upgrade_lock.upgrade) or false
		can_unlock = upgrade_lock and can_unlock or false
	end

	if asset_tweak_data.achievment_lock then
		achievment_lock = managers.achievment:exists(asset_tweak_data.achievment_lock) and managers.achievment:get_info(asset_tweak_data.achievment_lock).awarded or false
		can_unlock = achievment_lock and can_unlock or false
	end

	if asset_tweak_data.dlc_lock then
		dlc_lock = managers.dlc:is_dlc_unlocked(asset_tweak_data.dlc_lock) or false
		can_unlock = dlc_lock and can_unlock or false
	end

	return can_unlock
end

function MissionAssetsManager:get_asset_can_unlock_by_id(id)
	local is_host = Network:is_server() or Global.game_settings.single_player
	local is_client = not is_host
	local asset = self:_get_asset_by_id(id)

	if not self:is_unlock_asset_allowed() then
		return false
	end

	if asset then
		local asset_tweak_data = self._tweak_data[id]

		if self.ALLOW_CLIENTS_UNLOCK and is_client and asset_tweak_data.server_lock and asset and asset.can_unlock then
			return true
		end

		if asset_tweak_data and asset_tweak_data.no_mystery and asset_tweak_data.money_lock then
			return self:_is_asset_unlockable(id)
		end
	end

	return false
end

function MissionAssetsManager:get_every_asset_ids()
	local asset_ids = {}

	for id, asset in pairs(tweak_data.assets) do
		table.insert(asset_ids, id)
	end

	return asset_ids
end

function MissionAssetsManager:get_all_asset_ids(only_visible)
	local asset_ids = {}

	for _, asset in ipairs(self._global.assets) do
		local is_visible = not only_visible or asset.show
		local is_local_only = asset.local_only and self:_is_asset_unlockable(asset.id)

		if is_visible or is_local_only then
			table.insert(asset_ids, asset.id)
		end
	end

	return asset_ids
end

function MissionAssetsManager:get_unlocked_asset_ids(only_can_unlock)
	local asset_ids = {}

	for _, asset in ipairs(self._global.assets) do
		if asset.unlocked and (not only_can_unlock or asset.can_unlock) then
			table.insert(asset_ids, asset.id)
		end
	end

	return asset_ids
end

function MissionAssetsManager:get_locked_asset_ids(only_can_unlock)
	local asset_ids = {}

	for _, asset in ipairs(self._global.assets) do
		if asset.show and not asset.unlocked and (not only_can_unlock or self:_is_asset_unlockable(asset.id)) then
			table.insert(asset_ids, asset.id)
		end
	end

	return asset_ids
end

function MissionAssetsManager:get_default_asset_id()
	return "none"
end

function MissionAssetsManager:get_asset_visible_by_id(id)
	local asset = self:_get_asset_by_id(id)

	return asset and asset.show or false
end

function MissionAssetsManager:get_asset_unlocked_by_id(id)
	local asset = self:_get_asset_by_id(id)

	return asset and asset.unlocked or false
end

function MissionAssetsManager:get_asset_triggered_by_id(id)
	local asset = self:_get_asset_by_id(id)

	return asset and asset.is_triggered or false
end

function MissionAssetsManager:get_asset_no_mystery_by_id(id)
	local asset = self:_get_asset_by_id(id)

	return asset and asset.no_mystery or false
end

function MissionAssetsManager:get_asset_tweak_data_by_id(id)
	return self._tweak_data[id]
end

function MissionAssetsManager:get_asset_unlock_text_by_id(id)
	local asset_tweak_data = self._tweak_data[id]
	local prefix = "menu_asset_lock_"
	local text = "unable_to_unlock"

	if asset_tweak_data.no_mystery then
		if not self:is_unlock_asset_allowed() then
			text = "game_started"
		elseif asset_tweak_data.upgrade_lock then
			text = asset_tweak_data.upgrade_lock.upgrade
		elseif asset_tweak_data.achievment_lock then
			text = "achv_" .. asset_tweak_data.achievment_lock
		elseif asset_tweak_data.job_lock then
			text = "jval_" .. asset_tweak_data.job_lock
		elseif asset_tweak_data.saved_job_lock then
			text = "sjval_" .. asset_tweak_data.saved_job_lock
		elseif asset_tweak_data.dlc_lock then
			text = "dlc_" .. asset_tweak_data.dlc_lock
		end
	end

	return prefix .. text
end

function MissionAssetsManager:is_unlock_asset_allowed()
	if game_state_machine:current_state_name() ~= "ingame_waiting_for_players" then
		return false
	end

	local check_is_dropin = game_state_machine and game_state_machine:current_state() and game_state_machine:current_state().check_is_dropin and game_state_machine:current_state():check_is_dropin()

	return not check_is_dropin
end

function MissionAssetsManager:get_money_spent()
	return self._money_spent
end

function MissionAssetsManager:sync_save(data)
	data.MissionAssetsManager = self._global
end

function MissionAssetsManager:sync_load(data)
	self._global = data.MissionAssetsManager

	self:create_asset_textures()
end

function MissionAssetsManager:clear_asset_textures()
	if self._requested_textures then
		for i, data in pairs(self._requested_textures) do
			managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
		end
	end

	self._requested_textures = {}
	self._asset_textures_in_loading = {}
	self._asset_textures_loaded = {}
end

function MissionAssetsManager:create_asset_textures()
	if managers.platform:presence() == "Playing" then
		Application:debug("[MissionAssetsManager] create_asset_textures(): ", managers.platform:presence())

		return
	end

	local all_visible_assets = self:get_all_asset_ids(true)
	local texture_loaded_clbk = callback(self, self, "texture_loaded_clbk")
	local texture = nil

	for _, asset_id in ipairs(all_visible_assets) do
		texture = self._tweak_data[asset_id].texture

		if not self._asset_textures_in_loading[Idstring(texture):key()] then
			self._asset_textures_in_loading[Idstring(texture):key()] = {
				asset_id,
				texture
			}
		else
			Application:error("[MissionAssetsManager:create_asset_textures] Same asset texture used twice!", "texture", texture)
		end
	end

	for _, data in pairs(self._asset_textures_in_loading) do
		local texture_count = managers.menu_component:request_texture(data[2], texture_loaded_clbk)

		table.insert(self._requested_textures, {
			texture_count = texture_count,
			texture = data[2]
		})
	end

	self:check_all_textures_loaded()
end

function MissionAssetsManager:get_asset_texture(asset_id)
	local texture = self._asset_textures_loaded[asset_id]

	if not texture then
		Application:error("[MissionAssetsManager] get_asset_texture(): Asset texture not loaded!", asset_id)
	end

	return texture
end

function MissionAssetsManager:texture_loaded_clbk(texture_idstring)
	if not self._asset_textures_in_loading or not self._asset_textures_in_loading[texture_idstring:key()] then
		return
	end

	local asset_texture_data = self._asset_textures_in_loading[texture_idstring:key()]
	local asset_id = asset_texture_data[1]
	local texture_path = asset_texture_data[2]

	if self._asset_textures_loaded[asset_id] then
		Application:error("[MissionAssetsManager] texture_loaded_clbk() Asset already got texture loaded.")

		return
	end

	self._asset_textures_loaded[asset_id] = texture_idstring
	self._asset_textures_in_loading[texture_idstring:key()] = nil

	Application:debug("[MissionAssetsManager] Texture loaded for asset", asset_id)
	self:check_all_textures_loaded()
end

function MissionAssetsManager:check_all_textures_loaded()
	if self:is_all_textures_loaded() or #self:get_all_asset_ids(true) == 0 then
		Application:debug("[MissionAssetsManager] Creating mission assets")
		managers.menu_component:create_asset_mission_briefing_gui()
	end
end

function MissionAssetsManager:is_all_textures_loaded()
	if not self._asset_textures_in_loading or not self._asset_textures_loaded then
		return false
	end

	return table.size(self._asset_textures_in_loading) == 0 and table.size(self._asset_textures_loaded) ~= 0
end

function MissionAssetsManager:reload_textures()
	self._requested_textures = {}
	self._asset_textures_in_loading = {}
	self._asset_textures_loaded = {}

	self:create_asset_textures()
end

function MissionAssetsManager:_make_string_index_table(asset_id_table)
	local string_table = ""

	for _, asset_id in ipairs(asset_id_table) do
		for i, g_asset in ipairs(self._global.assets) do
			if g_asset.id == asset_id then
				string_table = string_table .. tostring(i) .. ","

				break
			end
		end
	end

	return string_table
end

function MissionAssetsManager:_read_string_index_table(string_table)
	local asset_id_table = {}
	local table_with_strings = string.split(string_table, ",")

	for _, s in ipairs(table_with_strings) do
		table.insert(asset_id_table, self._global.assets[tonumber(s)].id)
	end

	return asset_id_table
end
