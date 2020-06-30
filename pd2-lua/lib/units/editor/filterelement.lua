FilterUnitElement = FilterUnitElement or class(MissionElement)

function FilterUnitElement:init(unit)
	FilterUnitElement.super.init(self, unit)

	self._hed.difficulty_easy = true
	self._hed.difficulty_normal = true
	self._hed.difficulty_hard = true
	self._hed.difficulty_overkill = true
	self._hed.difficulty_overkill_145 = true
	self._hed.difficulty_easy_wish = nil
	self._hed.difficulty_overkill_290 = nil
	self._hed.difficulty_sm_wish = nil
	self._hed.player_1 = true
	self._hed.player_2 = true
	self._hed.player_3 = true
	self._hed.player_4 = true
	self._hed.platform_win32 = true
	self._hed.platform_ps3 = true
	self._hed.platform_pc_only = false
	self._hed.platform_xb1_only = false
	self._hed.platform_ps4_only = false
	self._hed.mode_assault = true
	self._hed.mode_control = true

	table.insert(self._save_values, "difficulty_easy")
	table.insert(self._save_values, "difficulty_normal")
	table.insert(self._save_values, "difficulty_hard")
	table.insert(self._save_values, "difficulty_overkill")
	table.insert(self._save_values, "difficulty_overkill_145")
	table.insert(self._save_values, "difficulty_easy_wish")
	table.insert(self._save_values, "difficulty_overkill_290")
	table.insert(self._save_values, "difficulty_sm_wish")
	table.insert(self._save_values, "player_1")
	table.insert(self._save_values, "player_2")
	table.insert(self._save_values, "player_3")
	table.insert(self._save_values, "player_4")
	table.insert(self._save_values, "platform_win32")
	table.insert(self._save_values, "platform_ps3")
	table.insert(self._save_values, "platform_pc_only")
	table.insert(self._save_values, "platform_xb1_only")
	table.insert(self._save_values, "platform_ps4_only")
	table.insert(self._save_values, "mode_assault")
	table.insert(self._save_values, "mode_control")
end

function FilterUnitElement:post_init(...)
	FilterUnitElement.super.post_init(self, ...)
	self:_check_convertion()
end

function FilterUnitElement:_check_convertion()
	if self._hed.difficulty_overkill_290 == nil then
		self._hed.difficulty_overkill_290 = self._hed.difficulty_overkill_145
	end

	if self._hed.difficulty_easy_wish == nil then
		self._hed.difficulty_easy_wish = self._hed.difficulty_overkill_290
	end

	if self._hed.difficulty_sm_wish == nil then
		self._hed.difficulty_sm_wish = self._hed.difficulty_overkill_290
	end
end

function FilterUnitElement:_build_panel(panel, panel_sizer)
	self:_check_convertion()
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(h_sizer, 0, 0, "EXPAND")

	local difficulty_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Difficulty")

	h_sizer:add(difficulty_sizer, 1, 0, "EXPAND")

	local difficulty_easy = EWS:CheckBox(panel, "Easy", "")

	difficulty_easy:set_value(self._hed.difficulty_easy)
	difficulty_easy:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "difficulty_easy",
		ctrlr = difficulty_easy
	})
	difficulty_sizer:add(difficulty_easy, 0, 0, "EXPAND")

	local difficulty_normal = EWS:CheckBox(panel, "Normal", "")

	difficulty_normal:set_value(self._hed.difficulty_normal)
	difficulty_normal:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "difficulty_normal",
		ctrlr = difficulty_normal
	})
	difficulty_sizer:add(difficulty_normal, 0, 0, "EXPAND")

	local difficulty_hard = EWS:CheckBox(panel, "Hard", "")

	difficulty_hard:set_value(self._hed.difficulty_hard)
	difficulty_hard:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "difficulty_hard",
		ctrlr = difficulty_hard
	})
	difficulty_sizer:add(difficulty_hard, 0, 0, "EXPAND")

	local difficulty_overkill = EWS:CheckBox(panel, "Very Hard", "")

	difficulty_overkill:set_value(self._hed.difficulty_overkill)
	difficulty_overkill:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "difficulty_overkill",
		ctrlr = difficulty_overkill
	})
	difficulty_sizer:add(difficulty_overkill, 0, 0, "EXPAND")

	local difficulty_overkill_145 = EWS:CheckBox(panel, "Overkill", "")

	difficulty_overkill_145:set_value(self._hed.difficulty_overkill_145)
	difficulty_overkill_145:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "difficulty_overkill_145",
		ctrlr = difficulty_overkill_145
	})
	difficulty_sizer:add(difficulty_overkill_145, 0, 0, "EXPAND")

	local difficulty_easy_wish = EWS:CheckBox(panel, "Easy Wish", "")

	difficulty_easy_wish:set_value(self._hed.difficulty_easy_wish)
	difficulty_easy_wish:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "difficulty_easy_wish",
		ctrlr = difficulty_easy_wish
	})
	difficulty_sizer:add(difficulty_easy_wish, 0, 0, "EXPAND")

	local difficulty_overkill_290 = EWS:CheckBox(panel, "Death Wish", "")

	difficulty_overkill_290:set_value(self._hed.difficulty_overkill_290)
	difficulty_overkill_290:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "difficulty_overkill_290",
		ctrlr = difficulty_overkill_290
	})
	difficulty_sizer:add(difficulty_overkill_290, 0, 0, "EXPAND")

	local difficulty_sm_wish = EWS:CheckBox(panel, "SM Wish", "")

	difficulty_sm_wish:set_value(self._hed.difficulty_sm_wish)
	difficulty_sm_wish:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "difficulty_sm_wish",
		ctrlr = difficulty_sm_wish
	})
	difficulty_sizer:add(difficulty_sm_wish, 0, 0, "EXPAND")

	local players_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Players")

	h_sizer:add(players_sizer, 1, 0, "EXPAND")

	local player_1 = EWS:CheckBox(panel, "One Player", "")

	player_1:set_value(self._hed.player_1)
	player_1:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "player_1",
		ctrlr = player_1
	})
	players_sizer:add(player_1, 0, 0, "EXPAND")

	local player_2 = EWS:CheckBox(panel, "Two Players", "")

	player_2:set_value(self._hed.player_2)
	player_2:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "player_2",
		ctrlr = player_2
	})
	players_sizer:add(player_2, 0, 0, "EXPAND")

	local player_3 = EWS:CheckBox(panel, "Three Players", "")

	player_3:set_value(self._hed.player_3)
	player_3:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "player_3",
		ctrlr = player_3
	})
	players_sizer:add(player_3, 0, 0, "EXPAND")

	local player_4 = EWS:CheckBox(panel, "Four Players", "")

	player_4:set_value(self._hed.player_4)
	player_4:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "player_4",
		ctrlr = player_4
	})
	players_sizer:add(player_4, 0, 0, "EXPAND")

	local platform_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Platform")

	h_sizer:add(platform_sizer, 1, 0, "EXPAND")

	local platform_win32 = EWS:CheckBox(panel, "Steam and Currgen", "")

	platform_win32:set_value(self._hed.platform_win32)
	platform_win32:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "platform_win32",
		ctrlr = platform_win32
	})
	platform_sizer:add(platform_win32, 0, 0, "EXPAND")

	local platform_ps3 = EWS:CheckBox(panel, "Oldgen", "")

	platform_ps3:set_value(self._hed.platform_ps3)
	platform_ps3:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "platform_ps3",
		ctrlr = platform_ps3
	})
	platform_sizer:add(platform_ps3, 0, 0, "EXPAND")

	local platform_pc_only = EWS:CheckBox(panel, "Steam", "")

	platform_pc_only:set_value(self._hed.platform_pc_only)
	platform_pc_only:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "platform_pc_only",
		ctrlr = platform_pc_only
	})
	platform_sizer:add(platform_pc_only, 0, 0, "EXPAND")

	local platform_xb1_only = EWS:CheckBox(panel, "Xbox One", "")

	platform_xb1_only:set_value(self._hed.platform_xb1_only)
	platform_xb1_only:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "platform_xb1_only",
		ctrlr = platform_xb1_only
	})
	platform_sizer:add(platform_xb1_only, 0, 0, "EXPAND")

	local platform_ps4_only = EWS:CheckBox(panel, "PS4", "")

	platform_ps4_only:set_value(self._hed.platform_ps4_only)
	platform_ps4_only:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "platform_ps4_only",
		ctrlr = platform_ps4_only
	})
	platform_sizer:add(platform_ps4_only, 0, 0, "EXPAND")

	local mode_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Mode")

	h_sizer:add(mode_sizer, 1, 0, "EXPAND")

	local mode_control = EWS:CheckBox(panel, "Control", "")

	mode_control:set_value(self._hed.mode_control == nil and true or self._hed.mode_control)
	mode_control:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "mode_control",
		ctrlr = mode_control
	})
	mode_sizer:add(mode_control, 0, 0, "EXPAND")

	local mode_assault = EWS:CheckBox(panel, "Assault", "")

	mode_assault:set_value(self._hed.mode_assault == nil and true or self._hed.mode_assault)
	mode_assault:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "mode_assault",
		ctrlr = mode_assault
	})
	mode_sizer:add(mode_assault, 0, 0, "EXPAND")
end
