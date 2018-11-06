function CoreEditor:build_configuration()
	self._config = {}
	local frame_size_height = 400
	local frame_size_width = 500
	self._configuration = EWS:Dialog(nil, "Configuration", "_configuration", Vector3(-1, -1, 0), Vector3(frame_size_width, frame_size_height), "")
	local main_sizer = EWS:BoxSizer("VERTICAL")

	self._configuration:set_sizer(main_sizer)

	local notebook = EWS:Notebook(self._configuration, "_notebook", "NB_TOP,NB_MULTILINE")

	self:_add_general_page(notebook)
	self:_add_backup_page(notebook)
	self:_add_edit_page(notebook)
	self:_add_notes_page(notebook)
	self:_add_slave_page(notebook)
	main_sizer:add(notebook, 1, 0, "EXPAND")

	local buttons_sizer = EWS:BoxSizer("HORIZONTAL")
	local ok_button = EWS:Button(self._configuration, "OK", "", "")

	ok_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_configuration_ok"), self._configuration)
	buttons_sizer:add(ok_button, 0, 0, "EXPAND")

	local cancel_button = EWS:Button(self._configuration, "Cancel", "", "")

	cancel_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_configuration_cancel"), self._configuration)
	buttons_sizer:add(cancel_button, 0, 0, "EXPAND")

	local apply_button = EWS:Button(self._configuration, "Apply", "", "")

	apply_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_configuration_apply"), self._configuration)
	buttons_sizer:add(apply_button, 0, 0, "EXPAND")
	main_sizer:add(buttons_sizer, 0, 0, "ALIGN_RIGHT")
	notebook:fit()
end

function CoreEditor:_add_general_page(notebook)
	local page_general = EWS:Panel(notebook, "_general", "")
	local general_sizer = EWS:StaticBoxSizer(page_general, "VERTICAL", "")

	page_general:set_sizer(general_sizer)

	local timestamp = EWS:CheckBox(page_general, "Use Timestamp", "")

	timestamp:set_value(self._use_timestamp)

	self._config._use_timestamp = timestamp

	general_sizer:add(timestamp, 0, 0, "EXPAND")

	local reset_camera_on_new = EWS:CheckBox(page_general, "Reset Camera on New/Load", "")

	reset_camera_on_new:set_value(self._reset_camera_on_new)

	self._config._reset_camera_on_new = reset_camera_on_new

	general_sizer:add(reset_camera_on_new, 0, 0, "EXPAND")

	local enable_revision_number = EWS:CheckBox(page_general, "Enable Revision Number", "")

	enable_revision_number:set_value(self._enable_revision_number)

	self._config._enable_revision_number = {
		ctrlr = enable_revision_number,
		callback = self.on_enable_revision_number and callback(self, self, "on_enable_revision_number")
	}

	general_sizer:add(enable_revision_number, 0, 0, "EXPAND")

	local undo_sizer = EWS:StaticBoxSizer(page_general, "VERTICAL", "Undo [Beta]:")
	local use_beta_undo = EWS:CheckBox(page_general, "Enable Undo", "")

	use_beta_undo:set_value(self._use_beta_undo)

	self._config._use_beta_undo = use_beta_undo

	undo_sizer:add(use_beta_undo, 0, 0, "EXPAND")

	local undo_debug_mode = EWS:CheckBox(page_general, "Verbose Undo", "")

	undo_debug_mode:set_value(self._undo_debug)

	self._config._undo_debug = undo_debug_mode

	undo_sizer:add(undo_debug_mode, 0, 0, "EXPAND")

	local undo_history_spinner = EWS:StaticBoxSizer(page_general, "VERTICAL", "Undo History Size:")
	local undo_history_spin = EWS:SpinCtrl(page_general, self._undo_history, "_undo_history_spin", "")

	undo_history_spin:set_range(1, 1000)

	self._config._undo_history = undo_history_spin

	undo_history_spinner:add(undo_history_spin, 0, 0, "ALIGN_RIGHT")
	undo_sizer:add(undo_history_spinner, 0, 0, "EXPAND")
	general_sizer:add(undo_sizer, 1, 0, "EXPAND")
	notebook:add_page(page_general, "General", true)
end

function CoreEditor:_add_backup_page(notebook)
	local page_backup = EWS:Panel(notebook, "_backup", "")
	local backup_sizer = EWS:BoxSizer("VERTICAL")

	page_backup:set_sizer(backup_sizer)

	local autosave_sizer = EWS:StaticBoxSizer(page_backup, "VERTICAL", "Automatic Save:")
	local autosave_spin_sizer = EWS:StaticBoxSizer(page_backup, "VERTICAL", "Time( minutes ) between automatic save")
	local autosave_spin = EWS:SpinCtrl(page_backup, self._autosave_time, "_autosave_spin", "")

	autosave_spin:set_range(0, 60)

	self._config._autosave_time = autosave_spin

	autosave_spin_sizer:add(autosave_spin, 0, 0, "ALIGN_RIGHT")
	autosave_sizer:add(autosave_spin_sizer, 0, 0, "EXPAND")
	backup_sizer:add(autosave_sizer, 1, 0, "EXPAND")
	notebook:add_page(page_backup, "Backup", false)
end

function CoreEditor:_add_edit_page(notebook)
	local page_edit = EWS:Panel(notebook, "_edit", "")
	local edit_sizer = EWS:StaticBoxSizer(page_edit, "VERTICAL", "")

	page_edit:set_sizer(edit_sizer)

	local edit_invert_move_shift = EWS:CheckBox(page_edit, "Invert move shift", "")

	edit_invert_move_shift:set_value(self._invert_move_shift)

	self._config._invert_move_shift = edit_invert_move_shift

	edit_sizer:add(edit_invert_move_shift, 0, 0, "EXPAND")

	local edit_always_global_select_unit = EWS:CheckBox(page_edit, "Always global select unit", "")

	edit_always_global_select_unit:set_value(self._always_global_select_unit)

	self._config._always_global_select_unit = edit_always_global_select_unit

	edit_sizer:add(edit_always_global_select_unit, 0, 0, "EXPAND")

	local edit_dialogs_stay_on_top = EWS:CheckBox(page_edit, "Dialogs stay on top", "")

	edit_dialogs_stay_on_top:set_value(self._dialogs_stay_on_top)

	self._config._dialogs_stay_on_top = edit_dialogs_stay_on_top

	edit_sizer:add(edit_dialogs_stay_on_top, 0, 0, "EXPAND")

	local save_edit_setting_values = EWS:CheckBox(page_edit, "Save edit setting values on quit", "")

	save_edit_setting_values:set_value(self._save_edit_setting_values)

	self._config._save_edit_setting_values = save_edit_setting_values

	edit_sizer:add(save_edit_setting_values, 0, 0, "EXPAND")

	local save_dialog_states = EWS:CheckBox(page_edit, "Keep dialog states", "")

	save_dialog_states:set_value(self._save_dialog_states)

	self._config._save_dialog_states = save_dialog_states

	edit_sizer:add(save_dialog_states, 0, 0, "EXPAND")
	notebook:add_page(page_edit, "Edit", false)
end

function CoreEditor:_add_notes_page(notebook)
	local page_notes = EWS:Panel(notebook, "_notes", "")
	local notes_sizer = EWS:StaticBoxSizer(page_notes, "VERTICAL", "")

	page_notes:set_sizer(notes_sizer)

	local note_text = EWS:TextCtrl(page_notes, self._notes, "", "TE_MULTILINE,TE_RICH2,TE_DONTWRAP,VSCROLL,ALWAYS_SHOW_SB")
	self._config._notes = note_text

	notes_sizer:add(note_text, 1, 0, "EXPAND")
	notebook:add_page(page_notes, "Notes", false)
end

function CoreEditor:_add_slave_page(notebook)
	local page_slave = EWS:Panel(notebook, "_slave", "")
	local slave_page_sizer = EWS:BoxSizer("VERTICAL")

	page_slave:set_sizer(slave_page_sizer)

	local slave_sizer = EWS:StaticBoxSizer(page_slave, "VERTICAL", "")
	local slave_host_name_sizer = EWS:StaticBoxSizer(page_slave, "HORIZONTAL", "Host / Port / LSPort: (0 is default.)")
	local slave_host_name = EWS:TextCtrl(page_slave, self._slave_host_name or "", "", "")
	self._config._slave_host_name = slave_host_name

	slave_host_name_sizer:add(slave_host_name, 2, 0, "EXPAND")

	local slave_port = EWS:SpinCtrl(page_slave, self._slave_port or 0, "", "")

	slave_port:set_range(0, 65535)

	self._config._slave_port = slave_port

	slave_host_name_sizer:add(slave_port, 1, 0, "")

	local slave_lsport = EWS:SpinCtrl(page_slave, self._slave_lsport or 0, "", "")

	slave_lsport:set_range(0, 65535)

	self._config._slave_lsport = slave_lsport

	slave_host_name_sizer:add(slave_lsport, 1, 0, "")
	slave_sizer:add(slave_host_name_sizer, 0, 0, "EXPAND")

	local slave_batches_sizer = EWS:StaticBoxSizer(page_slave, "VERTICAL", "Number of batches per cycle:")
	local slave_batches = EWS:SpinCtrl(page_slave, self._slave_num_batches or 1, "", "")

	slave_batches:set_range(1, 64)

	self._config._slave_num_batches = slave_batches

	slave_batches_sizer:add(slave_batches, 0, 0, "ALIGN_RIGHT")
	slave_sizer:add(slave_batches_sizer, 0, 0, "EXPAND")
	slave_page_sizer:add(slave_sizer, 1, 0, "EXPAND")
	notebook:add_page(page_slave, "Slave System", false)
end

function CoreEditor:on_configuration_ok()
	self:on_configuration_apply()
	self._configuration:end_modal()
end

function CoreEditor:on_configuration_cancel()
	for value, data in pairs(self._config) do
		local ctrlr = data.ctrlr or data

		ctrlr:set_value(self[value])
	end

	self._configuration:end_modal()
end

function CoreEditor:on_configuration_apply()
	for value, data in pairs(self._config) do
		local ctrlr = data.ctrlr or data
		local changed = false

		if type(self[value]) == "number" then
			changed = self[value] ~= tonumber(ctrlr:get_value())
			self[value] = tonumber(ctrlr:get_value())
		else
			changed = self[value] ~= ctrlr:get_value()
			self[value] = ctrlr:get_value()
		end

		if data.callback then
			data.callback(changed, self[value])
		end
	end

	self:save_configuration()

	if managers.slave:connected() then
		managers.slave:set_batch_count(self._slave_num_batches)
	end
end
