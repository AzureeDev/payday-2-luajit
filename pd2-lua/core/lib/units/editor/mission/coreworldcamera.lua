CoreWorldCameraUnitElement = CoreWorldCameraUnitElement or class(MissionElement)
WorldCameraUnitElement = WorldCameraUnitElement or class(CoreWorldCameraUnitElement)

function WorldCameraUnitElement:init(...)
	CoreWorldCameraUnitElement.init(self, ...)
end

function CoreWorldCameraUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.worldcamera = "none"
	self._hed.worldcamera_sequence = "none"

	table.insert(self._save_values, "worldcamera")
	table.insert(self._save_values, "worldcamera_sequence")
end

function CoreWorldCameraUnitElement:test_element()
	if self._hed.worldcamera_sequence ~= "none" then
		managers.worldcamera:play_world_camera_sequence(self._hed.worldcamera_sequence)
	elseif self._hed.worldcamera ~= "none" then
		managers.worldcamera:play_world_camera(self._hed.worldcamera)
	end
end

function CoreWorldCameraUnitElement:selected()
	MissionElement.selected(self)
	self:_populate_worldcameras()

	if not managers.worldcamera:all_world_cameras()[self._hed.worldcamera] then
		self._hed.worldcamera = "none"

		self._worldcameras:set_value(self._hed.worldcamera)
	end

	self:_populate_sequences()

	if not managers.worldcamera:all_world_camera_sequences()[self._hed.worldcamera_sequence] then
		self._hed.worldcamera_sequence = "none"

		self._sequences:set_value(self._hed.worldcamera_sequence)
	end
end

function CoreWorldCameraUnitElement:_populate_worldcameras()
	self._worldcameras:clear()
	self._worldcameras:append("none")

	for _, name in ipairs(self:_sorted_worldcameras()) do
		self._worldcameras:append(name)
	end

	self._worldcameras:set_value(self._hed.worldcamera)
end

function CoreWorldCameraUnitElement:_populate_sequences()
	self._sequences:clear()
	self._sequences:append("none")

	for _, name in ipairs(self:_sorted_worldcamera_sequences()) do
		self._sequences:append(name)
	end

	self._sequences:set_value(self._hed.worldcamera_sequence)
end

function CoreWorldCameraUnitElement:_sorted_worldcameras()
	local t = {}

	for name, _ in pairs(managers.worldcamera:all_world_cameras()) do
		table.insert(t, name)
	end

	table.sort(t)

	return t
end

function CoreWorldCameraUnitElement:_sorted_worldcamera_sequences()
	local t = {}

	for name, _ in pairs(managers.worldcamera:all_world_camera_sequences()) do
		table.insert(t, name)
	end

	table.sort(t)

	return t
end

function CoreWorldCameraUnitElement:select_camera_btn()
	local dialog = SelectNameModal:new("Select camera", self:_sorted_worldcameras())

	if dialog:cancelled() then
		return
	end

	for _, worldcamera in ipairs(dialog:_selected_item_assets()) do
		self._hed.worldcamera = worldcamera

		self._worldcameras:set_value(self._hed.worldcamera)
	end
end

function CoreWorldCameraUnitElement:select_sequence_btn()
	local dialog = SelectNameModal:new("Select sequence", self:_sorted_worldcamera_sequences())

	if dialog:cancelled() then
		return
	end

	for _, worldcamera_sequence in ipairs(dialog:_selected_item_assets()) do
		self._hed.worldcamera_sequence = worldcamera_sequence

		self._sequences:set_value(self._hed.worldcamera_sequence)
	end
end

function CoreWorldCameraUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local sequence_sizer = EWS:BoxSizer("HORIZONTAL")

	sequence_sizer:add(EWS:StaticText(self._panel, "Sequence:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	self._sequences = EWS:ComboBox(self._panel, "", "", "CB_DROPDOWN,CB_READONLY")

	self:_populate_sequences()
	self._sequences:set_value(self._hed.worldcamera_sequence)
	self._sequences:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "worldcamera_sequence",
		ctrlr = self._sequences
	})
	sequence_sizer:add(self._sequences, 3, 0, "EXPAND")

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("SELECT_EFFECT", "Select sequence", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("SELECT_EFFECT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "select_sequence_btn"), nil)
	toolbar:realize()
	sequence_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
	self._panel_sizer:add(sequence_sizer, 0, 0, "EXPAND")

	local worldcamera_sizer = EWS:BoxSizer("HORIZONTAL")

	worldcamera_sizer:add(EWS:StaticText(self._panel, "Camera:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	self._worldcameras = EWS:ComboBox(self._panel, "", "", "CB_DROPDOWN,CB_READONLY")

	self:_populate_worldcameras()
	self._worldcameras:set_value(self._hed.worldcamera)
	self._worldcameras:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "worldcamera",
		ctrlr = self._worldcameras
	})
	worldcamera_sizer:add(self._worldcameras, 3, 0, "EXPAND")

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("SELECT_EFFECT", "Select camera", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("SELECT_EFFECT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "select_camera_btn"), nil)
	toolbar:realize()
	worldcamera_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
	self._panel_sizer:add(worldcamera_sizer, 0, 0, "EXPAND")
end
