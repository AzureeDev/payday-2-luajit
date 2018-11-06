CoreWorldCameraTriggerUnitElement = CoreWorldCameraTriggerUnitElement or class(MissionElement)
WorldCameraTriggerUnitElement = WorldCameraTriggerUnitElement or class(CoreWorldCameraTriggerUnitElement)

function WorldCameraTriggerUnitElement:init(...)
	CoreWorldCameraTriggerUnitElement.init(self, ...)
end

function CoreWorldCameraTriggerUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.worldcamera_trigger_sequence = "none"
	self._hed.worldcamera_trigger_after_clip = "done"

	table.insert(self._save_values, "worldcamera_trigger_sequence")
	table.insert(self._save_values, "worldcamera_trigger_after_clip")
end

function CoreWorldCameraTriggerUnitElement:selected()
	MissionElement.selected(self)
	self:_populate_sequences()

	if not managers.worldcamera:all_world_camera_sequences()[self._hed.worldcamera_trigger_sequence] then
		self._hed.worldcamera_trigger_sequence = "none"

		self._sequences:set_value(self._hed.worldcamera_trigger_sequence)
	end

	self:_populate_after_clip()
end

function CoreWorldCameraTriggerUnitElement:_populate_sequences()
	self._sequences:clear()
	self._sequences:append("none")

	for name, _ in pairs(managers.worldcamera:all_world_camera_sequences()) do
		self._sequences:append(name)
	end

	self._sequences:set_value(self._hed.worldcamera_trigger_sequence)
end

function CoreWorldCameraTriggerUnitElement:_populate_after_clip()
	self._after_clip:clear()
	self._after_clip:append("done")

	local old_clip = self._hed.worldcamera_trigger_after_clip
	self._hed.worldcamera_trigger_after_clip = "done"

	if self._hed.worldcamera_trigger_sequence ~= "none" then
		local sequence = managers.worldcamera:world_camera_sequence(self._hed.worldcamera_trigger_sequence)

		for i, cam in ipairs(sequence) do
			self._after_clip:append(i)

			if i == old_clip then
				self._hed.worldcamera_trigger_after_clip = old_clip
			end
		end
	end

	self._after_clip:set_value(self._hed.worldcamera_trigger_after_clip)
end

function CoreWorldCameraTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local sequence_sizer = EWS:BoxSizer("HORIZONTAL")

	sequence_sizer:add(EWS:StaticText(self._panel, "Sequence:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	self._sequences = EWS:ComboBox(self._panel, "", "", "CB_DROPDOWN,CB_READONLY")

	self:_populate_sequences()
	self._sequences:set_value(self._hed.worldcamera_trigger_sequence)
	self._sequences:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "worldcamera_trigger_sequence",
		ctrlr = self._sequences
	})
	self._sequences:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_populate_after_clip"), nil)
	sequence_sizer:add(self._sequences, 3, 0, "EXPAND")
	self._panel_sizer:add(sequence_sizer, 0, 0, "EXPAND")

	local after_clip_sizer = EWS:BoxSizer("HORIZONTAL")

	after_clip_sizer:add(EWS:StaticText(self._panel, "After Clip:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	self._after_clip = EWS:ComboBox(self._panel, "", "", "CB_DROPDOWN,CB_READONLY")

	self:_populate_after_clip()
	self._after_clip:set_value(self._hed.worldcamera_trigger_after_clip)
	self._after_clip:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "worldcamera_trigger_after_clip",
		ctrlr = self._after_clip
	})
	after_clip_sizer:add(self._after_clip, 3, 0, "EXPAND")
	self._panel_sizer:add(after_clip_sizer, 0, 0, "EXPAND")
end
