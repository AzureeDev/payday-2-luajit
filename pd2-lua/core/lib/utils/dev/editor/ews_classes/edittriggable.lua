core:import("CoreEditorUtils")
core:import("CoreEws")

EditUnitTriggable = EditUnitTriggable or class(EditUnitBase)

function EditUnitTriggable:init(editor)
	local panel, sizer = (editor or managers.editor):add_unit_edit_page({
		name = "Sequences",
		class = self
	})
	self._panel = panel
	self._ctrls = {}
	self._element_guis = {}
	local sequence_sizer = EWS:BoxSizer("HORIZONTAL")
	self._triggers_params = {
		name = "Triggers:",
		name_proportions = 1,
		tooltip = "Select a sequence that should trigger other unit sequences",
		sorted = true,
		sizer_proportions = 1,
		ctrlr_proportions = 2,
		panel = panel,
		sizer = sequence_sizer,
		options = {}
	}

	CoreEws.combobox(self._triggers_params)
	self._triggers_params.ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "change_triggers"), self._triggers_params.ctrlr)

	self._btn_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	self._btn_toolbar:add_check_tool("ADD_UNIT", "Add unit by selecting in world", CoreEws.image_path("world_editor\\add_unit.png"), nil)
	self._btn_toolbar:connect("ADD_UNIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_unit_btn"), nil)
	self._btn_toolbar:add_tool("ADD_UNIT_LIST", "Add unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	self._btn_toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_unit_list_btn"), nil)
	self._btn_toolbar:realize()
	sequence_sizer:add(self._btn_toolbar, 0, 1, "EXPAND,LEFT")

	local paste_btn = EWS:Button(panel, "Paste", "", "BU_EXACTFIT,NO_BORDER")

	paste_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "paste_element"), nil)
	sizer:add(sequence_sizer, 0, 0, "EXPAND")
	sizer:add(paste_btn, 0, 0, "EXPAND")
	sizer:add(self:_build_scrolled_window(), 1, 0, "EXPAND")
	panel:layout()
	panel:set_enabled(false)
end

function EditUnitTriggable:_build_scrolled_window()
	self._scrolled_window = EWS:ScrolledWindow(self._panel, "", "VSCROLL")

	self._scrolled_window:set_scroll_rate(Vector3(0, 1, 0))
	self._scrolled_window:set_virtual_size_hints(Vector3(0, 0, 0), Vector3(1, -1, -1))

	self._scrolled_main_sizer = EWS:StaticBoxSizer(self._scrolled_window, "VERTICAL", "Trigger Sequences")

	self._scrolled_window:set_sizer(self._scrolled_main_sizer)

	return self._scrolled_window
end

function EditUnitTriggable:build_element_gui(data)
	local panel = EWS:Panel(self._scrolled_window, "", "TAB_TRAVERSAL")
	local sizer = EWS:BoxSizer("HORIZONTAL")
	local id = data.id or 0
	local trigger_name = data.trigger_name or "none"
	local name = Idstring("none")
	local unit_name = Idstring("none")

	if alive(data.notify_unit) then
		unit_name = data.notify_unit:name()
		name = data.notify_unit:unit_data().name_id
	end

	local sequences = {
		"none"
	}

	if #managers.sequence:get_triggable_sequence_list(unit_name) > 0 then
		sequences = managers.sequence:get_triggable_sequence_list(unit_name)
	end

	table.sort(sequences)

	local sequence = data.notify_unit_sequence or "none"
	local t = data.time or "-"

	panel:set_sizer(sizer)

	local copy_btn = EWS:Button(panel, "Copy", "", "BU_EXACTFIT,NO_BORDER")

	sizer:add(copy_btn, 0, 0, "EXPAND")

	local remove_btn = EWS:Button(panel, "Remove", "", "BU_EXACTFIT,NO_BORDER")

	sizer:add(remove_btn, 0, 0, "EXPAND")

	local name = EWS:TextCtrl(panel, name:s(), "", "TE_CENTRE,TE_READONLY")

	sizer:add(name, 3, 0, "EXPAND")

	local trigger = EWS:ComboBox(panel, "", "", "CB_DROPDOWN,CB_READONLY")

	for _, name in ipairs(sequences) do
		trigger:append(name)
	end

	trigger:set_value(sequence)
	sizer:add(trigger, 3, 0, "EXPAND")

	local time = EWS:TextCtrl(panel, t, "", "TE_CENTRE")

	sizer:add(time, 1, 0, "EXPAND")

	local ctrls = {
		id = id,
		trigger_name = trigger_name,
		trigger = trigger,
		time = time
	}

	copy_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "copy_element"), ctrls)
	remove_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "remove_element"), ctrls)
	trigger:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "change_sequence"), ctrls)
	time:connect("EVT_CHAR", callback(nil, _G, "verify_number"), time)
	time:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "change_time"), ctrls)
	self._scrolled_main_sizer:add(panel, 0, 0, "EXPAND")
	table.insert(self._element_guis, panel)

	return panel
end

function EditUnitTriggable:change_sequence(ctrls)
	self._ctrls.unit:damage():set_trigger_sequence_name(ctrls.id, ctrls.trigger_name, ctrls.trigger:get_value())
end

function EditUnitTriggable:change_time(ctrls)
	self._ctrls.unit:damage():set_trigger_sequence_time(ctrls.id, ctrls.trigger_name, ctrls.time:get_value())
end

function EditUnitTriggable:remove_element(ctrls)
	self._ctrls.unit:damage():remove_trigger_data(ctrls.trigger_name, ctrls.id)
	self:update_element_gui()
end

function EditUnitTriggable:clear_element_gui()
	self._scrolled_main_sizer:clear()

	for _, gui in ipairs(self._element_guis) do
		gui:destroy()
	end

	self._element_guis = {}
end

function EditUnitTriggable:add_unit_btn()
	if not managers.editor then
		return
	end

	local cb = self._btn_toolbar:tool_state("ADD_UNIT") and callback(self, self, "add_unit") or nil

	managers.editor:set_trigger_add_unit(cb)
end

function EditUnitTriggable:add_unit_list_btn()
	local function f(unit)
		return #managers.sequence:get_triggable_sequence_list(unit:name()) > 0
	end

	local dialog = SelectUnitByNameModal:new("Add Trigger Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		self:add_unit(unit)
	end
end

function EditUnitTriggable:update_element_gui()
	self:clear_element_gui()

	local trigger_name_list = self._ctrls.unit:damage():get_trigger_name_list()

	if trigger_name_list then
		for _, trigger_name in ipairs(trigger_name_list) do
			local trigger_data = self._ctrls.unit:damage():get_trigger_data_list(trigger_name)

			if trigger_data and #trigger_data > 0 then
				for _, data in ipairs(trigger_data) do
					if data.trigger_name == self._triggers_params.ctrlr:get_value() and alive(data.notify_unit) then
						self:build_element_gui(data)
					end
				end
			end
		end
	end

	if #self._element_guis == 0 then
		local panel = self:build_element_gui({})

		panel:set_enabled(false)
	end

	self._scrolled_window:fit_inside()
	managers.editor:layout_edit_panel()
end

function EditUnitTriggable:copy_element(ctrls)
	local trigger_data = self._ctrls.unit:damage():get_trigger_data(ctrls.trigger_name, ctrls.id)
	self._copied_trigger_data = trigger_data
end

function EditUnitTriggable:paste_element()
	if self._copied_trigger_data then
		if alive(self._copied_trigger_data.notify_unit) and self._copied_trigger_data.notify_unit:damage() then
			self._ctrls.unit:damage():add_trigger_sequence(self._copied_trigger_data.trigger_name, self._copied_trigger_data.notify_unit_sequence, self._copied_trigger_data.notify_unit, self._copied_trigger_data.time, nil, nil, true)
			self:update_element_gui()
		else
			self._copied_trigger_data = nil
		end
	end
end

function EditUnitTriggable:add_unit(unit)
	local triggable_sequences = managers.sequence:get_triggable_sequence_list(unit:name())

	if #triggable_sequences > 0 then
		self._ctrls.unit:damage():add_trigger_sequence(self._triggers_params.ctrlr:get_value(), triggable_sequences[1], unit, 0, nil, nil, true)
		self:update_element_gui()
	end
end

function EditUnitTriggable:change_triggers()
	if alive(self._ctrls.unit) then
		self:update_element_gui()
	end
end

function EditUnitTriggable:is_editable(unit)
	if alive(unit) and unit:damage() then
		local triggers = managers.sequence:get_trigger_list(unit:name())

		if #triggers > 0 then
			self._ctrls.unit = unit

			CoreEws.update_combobox_options(self._triggers_params, triggers)
			CoreEws.change_combobox_value(self._triggers_params, triggers[1])
			self:update_element_gui()

			return true
		end
	end

	self._btn_toolbar:set_tool_state("ADD_UNIT", false)
	self:add_unit_btn()

	return false
end

function EditUnitTriggable:dialog_closed()
	self._btn_toolbar:set_tool_state("ADD_UNIT", false)
	self:add_unit_btn()
end
