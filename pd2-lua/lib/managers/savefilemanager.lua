core:import("CoreEvent")

SavefileManager = SavefileManager or class()
SavefileManager.SETTING_SLOT = 0
SavefileManager.AUTO_SAVE_SLOT = 1
SavefileManager.PROGRESS_SLOT = SystemInfo:platform() == Idstring("WIN32") and 98 or 2
SavefileManager.BACKUP_SLOT = SystemInfo:platform() == Idstring("WIN32") and 98 or 3
SavefileManager.MIN_SLOT = 0
SavefileManager.MAX_SLOT = SystemInfo:platform() == Idstring("WIN32") and 99 or 2
SavefileManager.MAX_PROFILE_SAVE_INTERVAL = 300

if SystemInfo:platform() == Idstring("X360") then
	SavefileManager.TASK_MIN_DURATION = 3
end

if _G.IS_VR then
	SavefileManager.SETTING_SLOT = 12
end

SavefileManager.VR_BETA_PROGRESS_SLOT = 96
SavefileManager.IDLE_TASK_TYPE = 1
SavefileManager.LOAD_TASK_TYPE = 2
SavefileManager.SAVE_TASK_TYPE = 3
SavefileManager.REMOVE_TASK_TYPE = 4
SavefileManager.CHECK_SPACE_REQUIRED_TASK_TYPE = 5
SavefileManager.ENUMERATE_SLOTS_TASK_TYPE = 6
SavefileManager.DEBUG_TASK_TYPE_NAME_LIST = {
	"Idle",
	"Loading",
	"Saving",
	"Removing",
	"CheckSpaceRequired"
}
SavefileManager.RESERVED_BYTES = 204800
SavefileManager.VERSION = 5

if SystemInfo:platform() == Idstring("PS3") then
	SavefileManager.VERSION_NAME = "1.03"
	SavefileManager.LOWEST_COMPATIBLE_VERSION = "1.02"
elseif SystemInfo:platform() == Idstring("PS4") then
	SavefileManager.VERSION_NAME = "01.00"
	SavefileManager.LOWEST_COMPATIBLE_VERSION = "01.00"
elseif SystemInfo:platform() == Idstring("XB1") then
	SavefileManager.VERSION_NAME = "1.0.0.0"
	SavefileManager.LOWEST_COMPATIBLE_VERSION = "1.0.0.0"
else
	SavefileManager.VERSION_NAME = "1.8"
	SavefileManager.LOWEST_COMPATIBLE_VERSION = "1.7"
end

SavefileManager.SAVE_SYSTEM = "steam_cloud"
SavefileManager._USER_ID_OVERRRIDE = nil

function SavefileManager:init()
	self._active_changed_callback_handler = CoreEvent.CallbackEventHandler:new()
	self._save_begin_callback_handler = CoreEvent.CallbackEventHandler:new()
	self._save_done_callback_handler = CoreEvent.CallbackEventHandler:new()
	self._load_begin_callback_handler = CoreEvent.CallbackEventHandler:new()
	self._load_done_callback_handler = CoreEvent.CallbackEventHandler:new()
	self._load_sequence_done_callback_handler = CoreEvent.CallbackEventHandler:new()
	self._current_task_type = self.IDLE_TASK_TYPE

	if not Global.savefile_manager then
		Global.savefile_manager = {meta_data_list = {}}
	end

	self._workspace = managers.gui_data:create_saferect_workspace()
	self._gui = self._workspace:panel():gui(Idstring("guis/savefile_manager"))
	self._gui_script = self._gui:script()

	self._workspace:hide()

	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "resolution_changed"))
	self._queued_tasks = {}
	self._savegame_hdd_space_required = false
	self._save_slots_to_load = {}

	SaveGameManager:set_max_nr_slots(self.MAX_SLOT - self.MIN_SLOT + 1)
end

function SavefileManager:resolution_changed()
	managers.gui_data:layout_workspace(self._workspace)
end

function SavefileManager:destroy()
	if self._workspace then
		managers.gui_data:destroy_workspace(self._workspace)

		self._workspace = nil
		self._gui = nil
		self._gui_script = nil
	end
end

function SavefileManager:active_user_changed()
	if managers.user.STORE_SETTINGS_ON_PROFILE then
		self:_clean_meta_data_list(true)

		local is_signed_in = managers.user:is_signed_in(nil)

		if is_signed_in then
			self:load_settings()
		end
	end
end

function SavefileManager:storage_changed()
	cat_print("savefile_manager", "[SavefileManager:storage_changed]")

	local storage_device_selected = managers.user:is_storage_selected(nil)

	if not managers.user.STORE_SETTINGS_ON_PROFILE then
		self:_clean_meta_data_list(true)
	end

	self:_clean_meta_data_list(false)

	if storage_device_selected then
		self._loading_sequence = true
		self._save_slots_to_load = {all = true}

		cat_print("savefile_manager", "[SavefileManager:storage_changed] Scanning all slots")

		if self._backup_data == nil and SystemInfo:platform() == Idstring("WIN32") then
			self:load_progress("local_hdd")
		end

		if self._vr_progress_data == nil then
			self:load_vr_beta_progress()
		end

		local task_data = {
			queued_in_save_manager = true,
			task_type = self.ENUMERATE_SLOTS_TASK_TYPE,
			user_index = managers.user:get_platform_id(),
			first_slot = self.MIN_SLOT,
			last_slot = self.MAX_SLOT
		}

		if SystemInfo:platform() == Idstring("WIN32") then
			task_data.save_system = self.SAVE_SYSTEM
		end

		self:_on_task_queued(task_data)
		SaveGameManager:iterate_savegame_slots(task_data, callback(self, self, "clbk_result_iterate_savegame_slots"))
	else
		Application:error("[SavefileManager:storage_changed] Unable to load meta data. Signed in: " .. tostring(managers.user:is_signed_in(nil)) .. ", Storage device selected: " .. tostring(storage_device_selected))
	end
end

function SavefileManager:check_space_required()
	local task_data = {
		queued_in_save_manager = true,
		task_type = self.CHECK_SPACE_REQUIRED_TASK_TYPE,
		user_index = managers.user:get_platform_id(),
		first_slot = self.MIN_SLOT,
		last_slot = self.MAX_SLOT
	}

	self:_on_task_queued(task_data)
	SaveGameManager:iterate_savegame_slots(task_data, callback(self, self, "clbk_result_space_required"))
end

function SavefileManager:setting_changed()
	self:_set_setting_changed(true)
end

function SavefileManager:save_game(slot, cache_only)
	self:_save(slot, cache_only)
end

function SavefileManager:save_setting(is_user_initiated_action)
	if self:_is_saving_setting_allowed(is_user_initiated_action) then
		self:_save(self.SETTING_SLOT, false)
	end
end

function SavefileManager:save_progress(save_system)
	if self:_is_saving_progress_allowed() then
		self:_save(self.PROGRESS_SLOT, nil, save_system)

		Global.savefile_manager.backup_save_enabled = SystemInfo:platform() == Idstring("WIN32")
	end
end

function SavefileManager:load_progress(save_system)
	self:_load(self.PROGRESS_SLOT, nil, save_system)
end

function SavefileManager:load_game(slot, cache_only)
	self:_load(slot, cache_only)
end

function SavefileManager:load_settings()
	self:_load(self.SETTING_SLOT)
end

function SavefileManager:current_game_cache_slot()
	return Global.savefile_manager.current_game_cache_slot
end

function SavefileManager:update(t, dt)
	self:update_gui_visibility()

	if self._loading_sequence and not next(self._save_slots_to_load) and not self:_is_loading() then
		self:_on_load_sequence_complete()
	end
end

function SavefileManager:_is_loading()
	for i, task_data in ipairs(self._queued_tasks) do
		if task_data.task_type == self.LOAD_TASK_TYPE or task_data.task_type == self.ENUMERATE_SLOTS_TASK_TYPE then
			return true
		end
	end
end

function SavefileManager:_on_load_sequence_complete()
	cat_print("savefile_manager", "[SavefileManager:_on_load_sequence_complete]", Application:time())

	self._loading_sequence = nil

	self._load_sequence_done_callback_handler:dispatch()
end

function SavefileManager:is_in_loading_sequence()
	return self._loading_sequence
end

function SavefileManager:break_loading_sequence()
	cat_print("savefile_manager", "SavefileManager:break_loading_sequence()")

	self._try_again = nil
	self._loading_sequence = nil
	self._save_slots_to_load = {}

	for i, task_data in ipairs(self._queued_tasks) do
		SaveGameManager:abort(task_data)
	end

	self._queued_tasks = {}

	managers.system_menu:close("savefile_try_again")
	managers.system_menu:close("savefile_new_safefile")
end

function SavefileManager:paused_update(t, dt)
	self:update_gui_visibility()
end

function SavefileManager:update_current_task_type()
	local current_task_data = self._queued_tasks[1]

	self:_set_current_task_type(current_task_data and current_task_data.task_type or self.IDLE_TASK_TYPE)
end

function SavefileManager:update_gui_visibility()
	if self._hide_gui_time and self._hide_gui_time <= TimerManager:wall():time() then
		self._workspace:hide()
		self._gui_script:set_text("")

		self._hide_gui_time = nil
	end
end

function SavefileManager:debug_get_task_name(task_type)
	return self.DEBUG_TASK_TYPE_NAME_LIST[task_type] or "Invalid"
end

function SavefileManager:is_active()
	return next(self._queued_tasks) and true or false
end

function SavefileManager:get_save_info_list(include_empty_slot)
	local data_list = {}
	local save_info_list = {}

	for slot, meta_data in pairs(Global.savefile_manager.meta_data_list) do
		if meta_data.is_synched_text and (not include_empty_slot or slot ~= self.AUTO_SAVE_SLOT) and slot ~= self.SETTING_SLOT and slot ~= self.PROGRESS_SLOT then
			table.insert(data_list, {
				slot = slot,
				text = meta_data.text,
				sort_list = meta_data.sort_list
			})
		end
	end

	local function sort_func(data1, data2)
		return self:_compare_sort_list(data1.sort_list, data2.sort_list) < 0
	end

	table.sort(data_list, sort_func)

	for _, data in ipairs(data_list) do
		table.insert(save_info_list, SavefileInfo:new(data.slot, data.text))
	end

	if include_empty_slot then
		for empty_slot = 0, self.MAX_SLOT, 1 do
			local meta_data = Global.savefile_manager.meta_data_list[empty_slot]

			if empty_slot ~= self.SETTING_SLOT and empty_slot ~= self.PROGRESS_SLOT and empty_slot ~= self.AUTO_SAVE_SLOT and (not meta_data or not meta_data.is_synched_text) then
				local save_info = SavefileInfo:new(empty_slot, managers.localization:text("savefile_empty"))

				table.insert(save_info_list, 1, save_info)

				break
			end
		end
	end

	return save_info_list
end

function SavefileManager:add_active_changed_callback(callback_func)
	self._active_changed_callback_handler:add(callback_func)
end

function SavefileManager:remove_active_changed_callback(callback_func)
	self._active_changed_callback_handler:remove(callback_func)
end

function SavefileManager:add_save_begin_callback(callback_func)
	self._save_begin_callback_handler:add(callback_func)
end

function SavefileManager:remove_save_begin_callback(callback_func)
	self._save_begin_callback_handler:remove(callback_func)
end

function SavefileManager:add_save_done_callback(callback_func)
	self._save_done_callback_handler:add(callback_func)
end

function SavefileManager:remove_save_done_callback(callback_func)
	self._save_done_callback_handler:remove(callback_func)
end

function SavefileManager:add_load_begin_callback(callback_func)
	self._load_begin_callback_handler:add(callback_func)
end

function SavefileManager:remove_load_begin_callback(callback_func)
	self._load_begin_callback_handler:remove(callback_func)
end

function SavefileManager:add_load_done_callback(callback_func)
	self._load_done_callback_handler:add(callback_func)
end

function SavefileManager:remove_load_done_callback(callback_func)
	self._load_done_callback_handler:remove(callback_func)
end

function SavefileManager:add_load_sequence_done_callback_handler(callback_func)
	self._load_sequence_done_callback_handler:add(callback_func)
end

function SavefileManager:remove_load_sequence_done_callback_handler(callback_func)
	self._load_sequence_done_callback_handler:remove(callback_func)
end

function SavefileManager:_clean_meta_data_list(is_setting_slot)
	if is_setting_slot then
		Global.savefile_manager.meta_data_list[self.SETTING_SLOT] = nil
	else
		local empty_list = nil

		for slot in pairs(Global.savefile_manager.meta_data_list) do
			if slot ~= self.SETTING_SLOT then
				empty_list = true

				break
			end
		end

		if empty_list then
			local setting_meta_data = Global.savefile_manager.meta_data_list[self.SETTING_SLOT]
			Global.savefile_manager.meta_data_list = {}
			Global.savefile_manager.meta_data_list[self.SETTING_SLOT] = setting_meta_data
		end
	end
end

function SavefileManager:_save(slot, cache_only, save_system)
	cat_print("savefile_manager", "[SavefileManager] Saving to slot \"" .. tostring(slot) .. "\". Cache only: " .. tostring(cache_only))

	local is_setting_slot = slot == self.SETTING_SLOT
	local is_progress_slot = slot == self.PROGRESS_SLOT

	self._save_begin_callback_handler:dispatch(slot, is_setting_slot, cache_only)
	self:_save_cache(slot)

	if cache_only then
		self:_save_done(slot, cache_only, nil, nil, true)

		return
	end

	if is_setting_slot then
		self:_set_setting_changed(false)
	end

	if is_setting_slot and managers.user.STORE_SETTINGS_ON_PROFILE then
		Global.savefile_manager.safe_profile_save_time = TimerManager:wall():time() + self.MAX_PROFILE_SAVE_INTERVAL
		local task_data = {
			queued_in_save_manager = false,
			task_type = self.SAVE_TASK_TYPE,
			first_slot = slot
		}

		self:_on_task_queued(task_data)
		managers.user:save_setting_map(callback(self, self, "clbk_result_save_platform_setting", task_data))
	else
		local meta_data = self:_meta_data(slot)
		local task_data = {
			queued_in_save_manager = true,
			date_format = "%c",
			max_queue_size = 1,
			first_slot = slot,
			task_type = self.SAVE_TASK_TYPE,
			user_index = managers.user:get_platform_id()
		}

		if SystemInfo:platform() == Idstring("PS3") then
			task_data.title = managers.localization:text("savefile_game_title")

			if is_setting_slot then
				task_data.disable_ownership_check = true
			end

			task_data.small_icon_path = "ICON0.PNG"
		end

		task_data.subtitle = managers.localization:text(is_setting_slot and "savefile_setting" or "savefile_progress", {VERSION = self.LOWEST_COMPATIBLE_VERSION})
		task_data.details = managers.localization:text(is_setting_slot and "savefile_setting_description" or "savefile_progress_description")
		task_data.data = {meta_data.cache}

		if SystemInfo:distribution() == Idstring("STEAM") then
			task_data.save_system = save_system or "steam_cloud"
		end

		self:_on_task_queued(task_data)
		SaveGameManager:save(task_data, callback(self, self, "clbk_result_save"))
	end
end

function SavefileManager:_save_cache(slot)
	cat_print("savefile_manager", "[SavefileManager] Saves slot \"" .. tostring(slot) .. "\" to cache.")

	local is_setting_slot = slot == self.SETTING_SLOT

	if is_setting_slot then
		self:_set_cache(slot, nil)
	else
		local old_slot = Global.savefile_manager.current_game_cache_slot

		if old_slot then
			self:_set_cache(old_slot, nil)
		end

		self:_set_current_game_cache_slot(slot)
	end

	local cache = {
		version = SavefileManager.VERSION,
		version_name = SavefileManager.VERSION_NAME
	}

	if is_setting_slot then
		managers.user:save(cache)
		managers.music:save_settings(cache)

		if _G.IS_VR then
			managers.vr:save(cache)
		end
	else
		managers.player:save(cache)
		managers.experience:save(cache)
		managers.upgrades:save(cache)
		managers.money:save(cache)
		managers.statistics:save(cache)
		managers.skilltree:save(cache)
		managers.blackmarket:save(cache)
		managers.mission:save_job_values(cache)
		managers.job:save(cache)
		managers.dlc:save(cache)
		managers.infamy:save(cache)
		managers.features:save(cache)
		managers.gage_assignment:save(cache)
		managers.music:save_profile(cache)
		managers.challenge:save(cache)
		managers.multi_profile:save(cache)
		managers.ban_list:save(cache)
		managers.crimenet:save(cache)
		managers.custom_safehouse:save(cache)
		managers.butler_mirroring:save(cache)
		managers.mutators:save(cache)
		managers.tango:save(cache)
		managers.crime_spree:save(cache)
		managers.achievment:save(cache)
		managers.story:save(cache)
		managers.promo_unlocks:save(cache)
		managers.generic_side_jobs:save(cache)
		managers.skirmish:save(cache)
	end

	if SystemInfo:distribution() == Idstring("STEAM") then
		cache.user_id = self._USER_ID_OVERRRIDE or Steam:userid()

		cat_print("savefile_manager", "[SavefileManager:_save_cache] user_id:", cache.user_id)
	end

	self:_set_cache(slot, cache)
	self:_set_synched_cache(slot, false)

	return cache
end

function SavefileManager:_save_done(slot, cache_only, task_data, slot_data, success)
	cat_print("savefile_manager", "[SavefileManager] Done saving to slot \"" .. tostring(slot) .. "\". Cache only: " .. tostring(cache_only) .. ", Success: " .. tostring(success))

	if not success then
		self:_set_cache(slot, nil)
	end

	if not cache_only then
		self:_set_corrupt(slot, not success)
	end

	self:_set_synched_cache(slot, success and not cache_only)

	local is_setting_slot = slot == self.SETTING_SLOT

	if is_setting_slot and not success then
		self:_set_setting_changed(true)
	end

	self._save_done_callback_handler:dispatch(slot, success, is_setting_slot, cache_only)

	if not success then
		local dialog_data = {title = managers.localization:text("dialog_error_title")}
		local ok_button = {text = managers.localization:text("dialog_ok")}
		dialog_data.button_list = {ok_button}
		dialog_data.text = managers.localization:text("dialog_fail_save_game_corrupt")

		if SystemInfo:platform() == Idstring("PS4") then
			managers.system_menu:ps4_add_init_show(dialog_data)
		else
			managers.system_menu:show(dialog_data)
		end
	end
end

function SavefileManager:clbk_result_load_vr_beta_progress(task_data, result_data)
	cat_print("savefile_manager", "[SavefileManager:clbk_result_load_vr_beta_progress]")

	if not self:_on_task_completed(task_data) then
		return
	end

	if type_name(result_data) == "table" then
		for slot, slot_data in pairs(result_data) do
			if slot == SavefileManager.VR_BETA_PROGRESS_SLOT then
				self._vr_progress_data = false

				if slot_data.status == "OK" then
					local cache = slot_data.data
					local version = cache.version or 0
					local version_name = cache.version_name

					if SystemInfo:distribution() == Idstring("STEAM") and cache.user_id ~= (self._USER_ID_OVERRRIDE or Steam:userid()) then
						cat_print("savefile_manager", "[SavefileManager:clbk_result_load_backup] User ID missmatch. cache.user_id:", cache.user_id, ". expected user id:", self._USER_ID_OVERRRIDE or Steam:userid())
					elseif version <= SavefileManager.VERSION then
						cat_print("savefile_manager", "[SavefileManager:clbk_result_load_backup] vr beta progress loaded")

						self._vr_progress_data = {save_data = slot_data}
					else
						Application:error("[SavefileManager:clbk_result_load_backup] vr beta progress is wrong version")
					end
				end
			end
		end
	end
end

function SavefileManager:load_vr_beta_progress(slot, save_system)
	local task_data = {
		queued_in_save_manager = true,
		task_type = self.LOAD_TASK_TYPE,
		first_slot = slot or SavefileManager.VR_BETA_PROGRESS_SLOT,
		user_index = managers.user:get_platform_id()
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		task_data.save_system = save_system or "steam_cloud"
	end

	local load_callback_obj = callback(self, self, "clbk_result_load_vr_beta_progress")

	self:_on_task_queued(task_data)
	SaveGameManager:load(task_data, load_callback_obj)
end

function SavefileManager:_save_data_to_slot(target_slot, data, clbk, save_system)
	local task_data = {
		queued_in_save_manager = true,
		date_format = "%c",
		max_queue_size = 1,
		first_slot = target_slot,
		task_type = self.SAVE_TASK_TYPE,
		user_index = managers.user:get_platform_id(),
		subtitle = managers.localization:text("savefile_progress", {VERSION = self.LOWEST_COMPATIBLE_VERSION}),
		details = managers.localization:text("savefile_progress_description"),
		data = {data}
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		task_data.save_system = save_system or "steam_cloud"
	end

	local function save_callback_obj(task_data, result_data)
		if not self:_on_task_completed(task_data) then
			clbk(false)

			return
		end

		if type_name(result_data) == "table" then
			for slot, slot_data in pairs(result_data) do
				if slot == target_slot and slot_data.status == "OK" then
					clbk(true)

					return
				end
			end
		end

		clbk(false)
	end

	self:_on_task_queued(task_data)
	SaveGameManager:save(task_data, save_callback_obj)
end

function SavefileManager:clbk_result_load_copy_slot(src_slot, target_slot, task_data, result_data, clbk)
	if not self:_on_task_completed(task_data) then
		clbk(false)

		return
	end

	if type_name(result_data) == "table" then
		for slot, slot_data in pairs(result_data) do
			if slot == src_slot and slot_data.status == "OK" then
				self:_save_data_to_slot(target_slot, slot_data.data, clbk)

				return
			end
		end
	end

	clbk(false)
end

function SavefileManager:_copy_slot(src_slot, target_slot, clbk, save_system)
	local task_data = {
		queued_in_save_manager = true,
		task_type = self.LOAD_TASK_TYPE,
		first_slot = src_slot,
		user_index = managers.user:get_platform_id()
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		task_data.save_system = save_system or "steam_cloud"
	end

	local function load_callback_obj(td, rd)
		self:clbk_result_load_copy_slot(src_slot, target_slot, td, rd, clbk or function ()
		end)
	end

	self:_on_task_queued(task_data)
	SaveGameManager:load(task_data, load_callback_obj)
end

function SavefileManager:_load(slot, cache_only, save_system)
	cat_print("savefile_manager", "[SavefileManager] Loading slot \"" .. tostring(slot) .. "\". Cache only: " .. tostring(cache_only))

	local is_setting_slot = slot == self.SETTING_SLOT

	if not is_setting_slot then
		self:_set_current_game_cache_slot(slot)
	end

	self._load_begin_callback_handler:dispatch(slot, is_setting_slot, cache_only)

	local meta_data = self:_meta_data(slot)

	if cache_only or meta_data.is_synched_cache and meta_data.cache then
		self:_load_done(slot, cache_only)
	else
		if is_setting_slot then
			self:_set_cache(slot, nil)
		else
			self:_set_cache(Global.savefile_manager.current_game_cache_slot, nil)
		end

		if is_setting_slot and managers.user.STORE_SETTINGS_ON_PROFILE then
			local task_data = {
				queued_in_save_manager = false,
				task_type = self.LOAD_TASK_TYPE,
				first_slot = slot,
				user_index = managers.user:get_platform_id()
			}

			self:_on_task_queued(task_data)
			managers.user:load_platform_setting_map(callback(self, self, "clbk_result_load_platform_setting_map", task_data))
		else
			local task_data = {
				queued_in_save_manager = true,
				task_type = self.LOAD_TASK_TYPE,
				first_slot = slot,
				user_index = managers.user:get_platform_id()
			}

			if SystemInfo:platform() == Idstring("PS3") then
				task_data.disable_ownership_check = is_setting_slot
			end

			if SystemInfo:distribution() == Idstring("STEAM") then
				task_data.save_system = save_system or "steam_cloud"
			end

			local load_callback_obj = task_data.save_system == "local_hdd" and callback(self, self, "clbk_result_load_backup") or callback(self, self, "clbk_result_load")

			self:_on_task_queued(task_data)
			SaveGameManager:load(task_data, load_callback_obj)
		end
	end
end

function SavefileManager:_on_task_queued(task_data)
	cat_print("savefile_manager", "[SavefileManager:_on_task_queued]", inspect(task_data))

	if task_data.max_queue_size then
		local nr_tasks_found = 0
		local i_task = 1

		while i_task <= #self._queued_tasks do
			local test_task_data = self._queued_tasks[i_task]

			if test_task_data.task_type == task_data.task_type and test_task_data.save_system == task_data.save_system then
				nr_tasks_found = nr_tasks_found + 1

				if task_data.max_queue_size <= nr_tasks_found then
					SaveGameManager:abort(test_task_data)
					table.remove(self._queued_tasks, i_task)
				else
					i_task = i_task + 1
				end
			else
				i_task = i_task + 1
			end
		end
	end

	table.insert(self._queued_tasks, task_data)
	self:update_current_task_type()
end

function SavefileManager:_on_task_completed(task_data)
	cat_print("savefile_manager", "[SavefileManager:_on_task_completed]", inspect(task_data))

	for i, test_task_data in ipairs(self._queued_tasks) do
		if task_data == test_task_data then
			table.remove(self._queued_tasks, i)
			self:update_current_task_type()
			cat_print("savefile_manager", "found and removed")

			return true
		end
	end
end

function SavefileManager:_load_done(slot, cache_only, wrong_user, wrong_version)
	cat_print("savefile_manager", "[SavefileManager:_load_done]", slot, cache_only, wrong_user, wrong_version)

	local is_setting_slot = slot == self.SETTING_SLOT
	local is_progress_slot = slot == self.PROGRESS_SLOT
	local meta_data = self:_meta_data(slot)
	local success = meta_data.cache ~= nil

	cat_print("savefile_manager", "[SavefileManager] Done loading slot \"" .. tostring(slot) .. "\". Success: \"" .. tostring(success) .. "\".")

	if not cache_only then
		self:_set_corrupt(slot, not success)
		self:_set_synched_cache(slot, success)
	end

	if self._backup_data and is_progress_slot then
		local meta_data = self:_meta_data(slot)
		local cache = meta_data.cache

		if cache and managers.experience:chk_ask_use_backup(cache, self._backup_data.save_data.data) then
			self:_ask_load_backup("low_progress", true, {
				cache_only,
				wrong_user
			})

			return
		end
	end

	if self._vr_progress_data and is_progress_slot then
		local meta_data = self:_meta_data(slot)
		local cache = meta_data.cache

		if cache and managers.experience:chk_ask_use_backup(cache, self._vr_progress_data.save_data.data) then
			self:_ask_load_vr_progress(true, {
				cache_only,
				wrong_user
			})

			return
		end
	end

	local req_version = self:_load_cache(slot)
	success = req_version == nil and success or false

	self._load_done_callback_handler:dispatch(slot, success, is_setting_slot, cache_only)

	if not success and wrong_user then
		if not self._queued_wrong_user then
			self._queued_wrong_user = true

			managers.menu:show_savefile_wrong_user()
		end

		self._save_slots_to_load[slot] = nil
	elseif not success then
		self._try_again = self._try_again or {}
		local dialog_data = {title = managers.localization:text("dialog_error_title")}
		local ok_button = {text = managers.localization:text("dialog_ok")}
		dialog_data.button_list = {ok_button}

		if is_setting_slot or is_progress_slot then
			local at_init = false
			local error_msg = is_setting_slot and "dialog_fail_load_setting_" or is_progress_slot and "dialog_fail_load_progress_"
			error_msg = error_msg .. (req_version == nil and "corrupt" or "wrong_version")

			cat_print("savefile_manager", "ERROR: ", error_msg)

			if not self._try_again[slot] then
				local yes_button = {text = managers.localization:text("dialog_yes")}
				local no_button = {text = managers.localization:text("dialog_no")}
				dialog_data.button_list = {
					yes_button,
					no_button
				}
				dialog_data.id = "savefile_try_again"
				dialog_data.text = managers.localization:text(error_msg .. "_retry", {VERSION = req_version})

				if is_setting_slot then

					function yes_button.callback_func()
						self:load_settings()
					end
				elseif is_progress_slot then

					function yes_button.callback_func()
						self:load_progress()
					end
				end

				function no_button.callback_func()
					if is_progress_slot and self._backup_data then
						self:_ask_load_backup("progress_" .. (req_version == nil and "corrupt" or "wrong_version"), false)

						return
					else
						local rem_dialog_data = {
							title = managers.localization:text("dialog_error_title"),
							text = managers.localization:text(error_msg, {VERSION = req_version})
						}
						local ok_button = {
							text = managers.localization:text("dialog_ok"),
							callback_func = function ()
								self:_remove(slot)
							end
						}
						rem_dialog_data.button_list = {ok_button}

						managers.system_menu:show(rem_dialog_data)
					end
				end
				self._try_again[slot] = true
			else
				at_init = false

				if is_progress_slot and self._backup_data then
					self:_ask_load_backup("progress_" .. (req_version == nil and "corrupt" or "wrong_version"), false)

					return
				else
					dialog_data.text = managers.localization:text(error_msg, {VERSION = req_version})
					dialog_data.id = "savefile_new_safefile"

					function ok_button.callback_func()
						self:_remove(slot)
					end
				end
			end

			if at_init then
				managers.system_menu:add_init_show(dialog_data)
			else
				managers.system_menu:show(dialog_data)
			end
		else
			dialog_data.text = managers.localization:text("dialog_fail_load_game_corrupt")

			managers.system_menu:add_init_show(dialog_data)
		end
	elseif wrong_user then
		Global.savefile_manager.progress_wrong_user = true
		self._save_slots_to_load[slot] = nil

		if not self._queued_wrong_user then
			self._queued_wrong_user = true
			local dialog_data = {
				title = managers.localization:text("dialog_information_title"),
				text = managers.localization:text("dialog_load_wrong_user"),
				id = "wrong_user"
			}
			local ok_button = {text = managers.localization:text("dialog_ok")}
			dialog_data.button_list = {ok_button}

			managers.system_menu:add_init_show(dialog_data)
		end
	else
		self._save_slots_to_load[slot] = nil
	end
end

function SavefileManager:_remove(slot, save_system)
	local task_data = {
		queued_in_save_manager = true,
		first_slot = slot,
		task_type = self.REMOVE_TASK_TYPE,
		user_index = managers.user:get_platform_id()
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		task_data.save_system = save_system or "steam_cloud"
	end

	self._save_slots_to_load[slot] = nil

	self:_on_task_queued(task_data)
	SaveGameManager:remove(task_data, callback(self, self, "clbk_result_remove"))
end

function SavefileManager:_load_cache(slot)
	cat_print("savefile_manager", "[SavefileManager] Loads cached slot \"" .. tostring(slot) .. "\".")

	local meta_data = self:_meta_data(slot)
	local cache = meta_data.cache
	local is_setting_slot = slot == self.SETTING_SLOT

	if not is_setting_slot then
		self:_set_current_game_cache_slot(slot)
	end

	if cache then
		local version = cache.version or 0
		local version_name = cache.version_name

		if SavefileManager.VERSION < version then
			return version_name
		end

		if is_setting_slot then
			managers.user:load(cache, version)
			managers.music:load_settings(cache, version)

			if _G.IS_VR then
				managers.vr:load(cache, version)
			end

			self:_set_setting_changed(false)
		else
			managers.blackmarket:load(cache, version)
			managers.upgrades:load(cache, version)
			managers.experience:load(cache, version)
			managers.player:load(cache, version)
			managers.money:load(cache, version)
			managers.statistics:load(cache, version)
			managers.skilltree:load(cache, version)
			managers.mission:load_job_values(cache, version)
			managers.job:load(cache, version)
			managers.dlc:load(cache, version)
			managers.infamy:load(cache, version)
			managers.features:load(cache, version)
			managers.gage_assignment:load(cache, version)
			managers.music:load_profile(cache, version)
			managers.challenge:load(cache, version)
			managers.multi_profile:load(cache, version)
			managers.ban_list:load(cache, version)
			managers.crimenet:load(cache, version)
			managers.custom_safehouse:load(cache, version)
			managers.butler_mirroring:load(cache, version)
			managers.mutators:load(cache, version)
			managers.tango:load(cache, version)
			managers.crime_spree:load(cache, version)
			managers.achievment:load(cache, version)
			managers.story:load(cache, version)
			managers.promo_unlocks:load(cache, version)
			managers.generic_side_jobs:load(cache, version)
			managers.skirmish:load(cache, version)
		end
	else
		Application:error("[SavefileManager] Unable to load savefile from slot \"" .. tostring(slot) .. "\".")
		Application:stack_dump("error")
	end
end

function SavefileManager:_meta_data(slot)
	local meta_data = Global.savefile_manager.meta_data_list[slot]

	if not meta_data then
		meta_data = {
			is_synched_cache = false,
			is_synched_text = false,
			is_corrupt = false,
			slot = slot
		}
		Global.savefile_manager.meta_data_list[slot] = meta_data

		cat_print("savefile_manager", "[SavefileManager] Created meta data for slot \"" .. tostring(slot) .. "\".")
	end

	return meta_data
end

function SavefileManager:_set_current_task_type(task_type)
	local old_task_type = self._current_task_type

	if old_task_type ~= task_type then
		if Global.category_print.savefile_manager then
			cat_print("savefile_manager", "[SavefileManager] Changed current task from \"" .. self:debug_get_task_name(old_task_type) .. "\" to \"" .. self:debug_get_task_name(task_type) .. "\".")
		end

		self._current_task_type = task_type

		if task_type == self.IDLE_TASK_TYPE then
			self._active_changed_callback_handler:dispatch(false, task_type)
		elseif old_task_type == self.IDLE_TASK_TYPE then
			self._active_changed_callback_handler:dispatch(true, task_type)
		end

		local wall_time = TimerManager:wall():time()
		local ps3_ps4_load_enabled = true
		local is_ps3_ps4 = SystemInfo:platform() == Idstring("PS3") or SystemInfo:platform() == Idstring("PS4")
		local use_load_task_type = ps3_ps4_load_enabled and is_ps3_ps4 and task_type == self.LOAD_TASK_TYPE
		local check_t = ps3_ps4_load_enabled and is_ps3_ps4 and old_task_type == self.LOAD_TASK_TYPE and 0 or 3

		if task_type == self.SAVE_TASK_TYPE or task_type == self.REMOVE_TASK_TYPE or use_load_task_type then
			self._workspace:show()

			self._hide_gui_time = nil
			self._show_gui_time = self._show_gui_time or wall_time

			if task_type == self.SAVE_TASK_TYPE then
				self._gui_script:set_text(utf8.to_upper(managers.localization:text("savefile_saving")))
				self._gui_script.indicator:animate(self._gui_script.saving)
			elseif use_load_task_type then
				self._gui_script:set_text(utf8.to_upper(managers.localization:text("savefile_loading")))
				self._gui_script.indicator:animate(self._gui_script.saving)
			else
				self._gui_script:set_text(utf8.to_upper(managers.localization:text("savefile_removing")))
				self._gui_script.indicator:animate(self._gui_script.saving)
			end
		elseif self._show_gui_time then
			if check_t < wall_time - self._show_gui_time then
				self._hide_gui_time = wall_time
			elseif wall_time - self._show_gui_time > 1 then
				self._hide_gui_time = self._show_gui_time + check_t
			else
				self._hide_gui_time = self._show_gui_time + check_t
			end

			self._show_gui_time = nil
		end
	end
end

function SavefileManager:_set_current_game_cache_slot(current_game_cache_slot)
	local old_slot = Global.savefile_manager.current_game_cache_slot

	if old_slot ~= current_game_cache_slot then
		cat_print("savefile_manager", "[SavefileManager] Changed current cache slot from \"" .. tostring(old_slot) .. "\" to \"" .. tostring(current_game_cache_slot) .. "\".")

		if old_slot then
			self:_set_cache(old_slot, nil)
		end

		Global.savefile_manager.current_game_cache_slot = current_game_cache_slot
	end
end

function SavefileManager:_set_corrupt(slot, is_corrupt)
	local meta_data = self:_meta_data(slot)

	if not meta_data.is_corrupt ~= not is_corrupt then
		cat_print("savefile_manager", "[SavefileManager] Slot \"" .. tostring(slot) .. "\" changed corrupt state to \"" .. tostring(not not is_corrupt) .. "\".")

		meta_data.is_corrupt = is_corrupt
	end
end

function SavefileManager:_set_synched_cache(slot, is_synched_cache)
	local meta_data = self:_meta_data(slot)

	if not meta_data.is_synched_cache ~= not is_synched_cache then
		cat_print("savefile_manager", "[SavefileManager] Slot \"" .. tostring(slot) .. "\" changed synched cache state to \"" .. tostring(not not is_synched_cache) .. "\".")

		meta_data.is_synched_cache = is_synched_cache
	end
end

function SavefileManager:_set_cache(slot, cache, force)
	local meta_data = self:_meta_data(slot)

	if meta_data.cache ~= cache then
		cat_print("savefile_manager", "[SavefileManager] Slot \"" .. tostring(slot) .. "\" changed cache from \"" .. tostring(meta_data.cache) .. "\" to \"" .. tostring(cache) .. "\".")

		meta_data.cache = cache
	end
end

function SavefileManager:_set_setting_changed(setting_changed)
	if not Global.savefile_manager.setting_changed ~= not setting_changed then
		cat_print("savefile_manager", "[SavefileManager] Setting changed: \"" .. tostring(setting_changed) .. "\".")

		Global.savefile_manager.setting_changed = setting_changed
	end
end

function SavefileManager:_is_saving_progress_allowed()
	if not managers.user:is_signed_in(nil) then
		return false
	end

	if not managers.user:is_storage_selected(nil) then
		return false
	end

	if Global.savefile_manager.progress_wrong_user then
		return false
	end

	return true
end

function SavefileManager:_is_saving_setting_allowed(is_user_initiated_action)
	if not managers.user:is_signed_in(nil) then
		return false
	end

	if not Global.savefile_manager.setting_changed then
		cat_print("savefile_manager", "[SavefileManager] Skips saving setting. Setting is already saved.")

		return false
	elseif not is_user_initiated_action then
		local safe_time = Global.savefile_manager.safe_profile_save_time

		if safe_time then
			local time = TimerManager:wall():time()

			if time <= safe_time then
				cat_print("savefile_manager", string.format("[SavefileManager] Skips saving setting. Needs to be user initiated or triggered after %g seconds.", safe_time - time))

				return false
			else
				Global.savefile_manager.safe_profile_save_time = nil
			end
		end
	end

	return true
end

function SavefileManager:fetch_savegame_hdd_space_required()
	return self._savegame_hdd_space_required
end

function SavefileManager:_ask_load_vr_progress(has_progress, load_params)
	local dialog_data = {title = managers.localization:text("dialog_error_title")}
	local yes_button = {text = managers.localization:text("dialog_yes")}
	local no_button = {text = managers.localization:text("dialog_no")}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	function yes_button.callback_func()
		self._save_slots_to_load[self.PROGRESS_SLOT] = nil

		self:_set_cache(self.PROGRESS_SLOT, self._vr_progress_data.save_data.data)

		self._vr_progress_data = nil

		self:_load_cache(self.PROGRESS_SLOT)
	end

	if has_progress then

		function no_button.callback_func()
			self._vr_progress_data = nil

			self:_load_done(self.PROGRESS_SLOT, unpack(load_params))
		end
	else

		function no_button.callback_func()
			self._vr_progress_data = nil
			self._save_slots_to_load[self.PROGRESS_SLOT] = nil
		end
	end

	dialog_data.text = managers.localization:text("dialog_ask_load_vr_beta_progress")

	managers.system_menu:show(dialog_data)
end

function SavefileManager:_ask_load_backup(reason, dialog_at_init, load_params)
	dialog_at_init = false
	local dialog_data = {title = managers.localization:text("dialog_error_title")}
	local yes_button = {text = managers.localization:text("dialog_yes")}
	local no_button = {text = managers.localization:text("dialog_no")}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	function yes_button.callback_func()
		self._save_slots_to_load[self.PROGRESS_SLOT] = nil

		self:_set_cache(self.PROGRESS_SLOT, self._backup_data.save_data.data)

		self._backup_data = nil

		self:_load_cache(self.PROGRESS_SLOT)
	end

	function no_button.callback_func()
		self._backup_data = nil
		self._save_slots_to_load[self.PROGRESS_SLOT] = nil
	end

	if reason == "no_progress" or reason == "low_progress" then
		dialog_data.text = managers.localization:text("dialog_ask_load_progress_backup_low_lvl")

		if reason == "low_progress" then

			function no_button.callback_func()
				self._backup_data = nil

				self:_load_done(self.PROGRESS_SLOT, unpack(load_params))
			end
		end
	elseif reason == "progress_corrupt" or reason == "progress_wrong_version" then
		dialog_data.text = managers.localization:text("dialog_ask_load_progress_backup_" .. (reason == "progress_corrupt" and "corrupt" or "wrong_version"))

		function no_button.callback_func()
			self._backup_data = nil

			self:_remove(self.PROGRESS_SLOT)
		end
	end

	if dialog_at_init then
		managers.system_menu:add_init_show(dialog_data)
	else
		managers.system_menu:show(dialog_data)
	end
end

function SavefileManager:clbk_result_load_platform_setting_map(task_data, platform_setting_map)
	cat_print("savefile_manager", "[SavefileManager:clbk_result_load_platform_setting_map]")

	if not self:_on_task_completed(task_data) then
		return
	end

	local cache = nil

	if platform_setting_map then
		cache = managers.user:get_setting_map()
	end

	self:_set_cache(self.SETTING_SLOT, cache)
	self:_load_done(self.SETTING_SLOT, false)
end

function SavefileManager:clbk_result_load(task_data, result_data)
	cat_print("savefile_manager", "[SavefileManager:clbk_result_load]")

	if not self:_on_task_completed(task_data) then
		return
	end

	if type_name(result_data) == "table" then
		for slot, slot_data in pairs(result_data) do
			cat_print("savefile_manager", "slot:", slot, "\n", inspect(slot_data))

			local status = slot_data.status
			local cache, force_cache = nil
			local wrong_user = status == "WRONG_USER"
			local wrong_version = status == "WRONG_VERSION"

			if status == "OK" or wrong_user then
				cache = slot_data.data
			elseif status == "FILE_NOT_FOUND" then
				cache = self:_save_cache(slot)
			end

			if cache and SystemInfo:platform() == Idstring("WIN32") and cache.version ~= SavefileManager.VERSION then
				cache = nil
				wrong_version = true
			end

			if cache and SystemInfo:distribution() == Idstring("STEAM") and cache.user_id ~= (self._USER_ID_OVERRRIDE or Steam:userid()) then
				cat_print("savefile_manager", "[SavefileManager:clbk_result_load] User ID missmatch. cache.user_id:", cache.user_id, ". expected user id:", self._USER_ID_OVERRRIDE or Steam:userid())

				cache = nil
				wrong_user = true
			end

			self:_set_cache(slot, cache, force_cache)
			self:_load_done(slot, cache ~= nil, wrong_user, wrong_version)
		end
	else
		Application:error("[SavefileManager:clbk_result_load] error:", result_data)
	end
end

function SavefileManager:clbk_result_load_backup(task_data, result_data)
	cat_print("savefile_manager", "[SavefileManager:clbk_result_load_backup]")

	if not self:_on_task_completed(task_data) then
		return
	end

	if type_name(result_data) == "table" then
		for slot, slot_data in pairs(result_data) do
			cat_print("savefile_manager", "slot:", slot, "\n", inspect(slot_data))

			local status = slot_data.status

			if slot == self.BACKUP_SLOT then
				self._backup_data = false

				if status == "OK" then
					local cache = slot_data.data
					local version = cache.version or 0
					local version_name = cache.version_name

					if SystemInfo:distribution() == Idstring("STEAM") and cache.user_id ~= (self._USER_ID_OVERRRIDE or Steam:userid()) then
						cat_print("savefile_manager", "[SavefileManager:clbk_result_load_backup] User ID missmatch. cache.user_id:", cache.user_id, ". expected user id:", self._USER_ID_OVERRRIDE or Steam:userid())
					elseif version <= SavefileManager.VERSION then
						cat_print("savefile_manager", "[SavefileManager:clbk_result_load_backup] backup loaded")

						self._backup_data = {save_data = slot_data}
					else
						Application:error("[SavefileManager:clbk_result_load_backup] local savegame backup is wrong version")
					end
				end
			end
		end
	else
		Application:error("[SavefileManager:clbk_result_load_backup] error:", result_data)
	end
end

function SavefileManager:clbk_result_remove(task_data, result_data)
	cat_print("savefile_manager", "[SavefileManager:clbk_result_remove]", inspect(task_data), inspect(result_data))

	if not self:_on_task_completed(task_data) then
		return
	end
end

function SavefileManager:clbk_result_iterate_savegame_slots(task_data, result_data)
	cat_print("savefile_manager", "[SavefileManager:clbk_result_iterate_savegame_slots]", inspect(task_data), inspect(result_data))

	if not self:_on_task_completed(task_data) then
		return
	end

	self._save_slots_to_load = {}
	local found_progress_slot = nil

	if type_name(result_data) == "table" then
		for slot, slot_data in pairs(result_data) do
			cat_print("savefile_manager", "slot:", slot, "\n", inspect(slot_data))

			if slot == self.SETTING_SLOT then
				self._save_slots_to_load[slot] = true

				self:load_settings()
			elseif slot == self.PROGRESS_SLOT then
				self._save_slots_to_load[slot] = true
				found_progress_slot = true

				self:load_progress()
			end
		end
	else
		Application:error("[SavefileManager:clbk_result_iterate_savegame_slots] error:", result_data)
	end

	if not found_progress_slot and self._backup_data then
		self._save_slots_to_load[self.PROGRESS_SLOT] = true

		self:_ask_load_backup("no_progress", true)
	end

	if not found_progress_slot and self._vr_progress_data then
		self._save_slots_to_load[self.PROGRESS_SLOT] = true

		self:_ask_load_vr_progress(false)
	end
end

function SavefileManager:clbk_result_save(task_data, result_data)
	cat_print("savefile_manager", "[SavefileManager:clbk_result_save]")

	if not self:_on_task_completed(task_data) then
		return
	end

	if type_name(result_data) == "table" then
		for slot, slot_data in pairs(result_data) do
			cat_print("savefile_manager", "slot:", slot, "\n", inspect(slot_data))

			local success = slot_data.status == "OK"

			self:_save_done(slot, false, task_data, slot_data, success)
		end
	else
		Application:error("[SavefileManager:clbk_result_save] error:", result_data)
	end
end

function SavefileManager:clbk_result_save_platform_setting(task_data, success)
	cat_print("savefile_manager", "[SavefileManager:clbk_result_save_platform_setting]", inspect(task_data), success)

	if not self:_on_task_completed(task_data) then
		return
	end

	self:_save_done(self.SETTING_SLOT, false, nil, nil, success)

	if not success then
		managers.menu:show_save_settings_failed()
		self:_set_setting_changed(false)
	end
end

function SavefileManager:clbk_result_space_required(task_data, result_data)
	cat_print("savefile_manager", "[SavefileManager:clbk_result_space_required] table.size(result_data)", table.size(result_data))

	if not self:_on_task_completed(task_data) then
		return
	end

	if type_name(result_data) == "table" then
		if SystemInfo:platform() == Idstring("PS3") or SystemInfo:platform() == Idstring("PS4") then
			self._savegame_hdd_space_required = ((2 - table.size(result_data)) * self.RESERVED_BYTES) / 1024
		end
	else
		Application:error("[SavefileManager:clbk_result_space_required] error:", result_data)
	end
end
SavefileInfo = SavefileInfo or class()

function SavefileInfo:init(slot, text)
	self._slot = slot
	self._text = text
end

function SavefileInfo:slot()
	return self._slot
end

function SavefileInfo:text()
	return self._text
end

