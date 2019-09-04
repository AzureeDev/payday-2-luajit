core:import("CoreEngineAccess")
require("core/lib/managers/cutscene/keys/CoreSetupCutsceneKeyBase")

CoreSpawnUnitCutsceneKey = CoreSpawnUnitCutsceneKey or class(CoreSetupCutsceneKeyBase)
CoreSpawnUnitCutsceneKey.ELEMENT_NAME = "spawn_unit"
CoreSpawnUnitCutsceneKey.NAME = "Spawn Unit"

CoreSpawnUnitCutsceneKey:register_serialized_attribute("name", "")
CoreSpawnUnitCutsceneKey:register_serialized_attribute("unit_category", "")
CoreSpawnUnitCutsceneKey:register_serialized_attribute("unit_type", "")
CoreSpawnUnitCutsceneKey:register_control("database_browser_button")
CoreSpawnUnitCutsceneKey:register_control("divider")
CoreSpawnUnitCutsceneKey:register_serialized_attribute("parent_unit_name", "")
CoreSpawnUnitCutsceneKey:register_serialized_attribute("parent_object_name", "")
CoreSpawnUnitCutsceneKey:register_serialized_attribute("offset", Vector3(0, 0, 0), CoreCutsceneKeyBase.string_to_vector)
CoreSpawnUnitCutsceneKey:register_serialized_attribute("rotation", Rotation(), CoreCutsceneKeyBase.string_to_rotation)
CoreSpawnUnitCutsceneKey:attribute_affects("unit_category", "unit_type")
CoreSpawnUnitCutsceneKey:attribute_affects("parent_unit_name", "parent_object_name")

CoreSpawnUnitCutsceneKey.control_for_unit_category = CoreSetupCutsceneKeyBase.standard_combo_box_control
CoreSpawnUnitCutsceneKey.control_for_unit_type = CoreSetupCutsceneKeyBase.standard_combo_box_control
CoreSpawnUnitCutsceneKey.control_for_divider = CoreSetupCutsceneKeyBase.standard_divider_control
CoreSpawnUnitCutsceneKey.control_for_parent_unit_name = CoreSetupCutsceneKeyBase.standard_combo_box_control
CoreSpawnUnitCutsceneKey.control_for_parent_object_name = CoreSetupCutsceneKeyBase.standard_combo_box_control

function CoreSpawnUnitCutsceneKey:__tostring()
	return string.format("Spawn %s named \"%s\".", self:unit_type(), self:name())
end

function CoreSpawnUnitCutsceneKey:prime(player)
	self:_spawn_unit()
end

function CoreSpawnUnitCutsceneKey:unload(player)
	if self._cast then
		self:_delete_unit()
	end
end

function CoreSpawnUnitCutsceneKey:play(player, undo, fast_forward)
	self:_reparent_unit()
end

function CoreSpawnUnitCutsceneKey:is_valid_unit_category(unit_category)
	if not Application:ews_enabled() then
		return true
	else
		return unit_category ~= nil and table.contains(managers.database:list_unit_types(), unit_category)
	end
end

function CoreSpawnUnitCutsceneKey:is_valid_unit_type(unit_type)
	return unit_type ~= nil and DB:has("unit", unit_type)
end

function CoreSpawnUnitCutsceneKey:is_valid_name(name)
	if name == nil or #name <= 3 or string.match(name, "[a-z_0-9]+") ~= name then
		return false
	end

	local existing_unit = self:_unit(name, true)

	return existing_unit == nil or existing_unit == self._spawned_unit
end

function CoreSpawnUnitCutsceneKey:control_for_database_browser_button(parent_frame)
	local button = EWS:Button(parent_frame, "Pick From Database Browser", "", "")

	button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_database_browser_button_clicked"), button)

	return button
end

function CoreSpawnUnitCutsceneKey:refresh_control_for_unit_category(control)
	control:freeze()
	control:clear()

	local value = self:unit_category()

	for _, unit_category in ipairs(managers.database:list_unit_types()) do
		control:append(unit_category)

		if unit_category == value then
			control:set_value(value)
		end
	end

	control:thaw()
end

function CoreSpawnUnitCutsceneKey:refresh_control_for_unit_type(control)
	control:freeze()
	control:clear()

	local value = self:unit_type()

	for _, unit_type in ipairs(managers.database:list_units_of_type(self:unit_category())) do
		control:append(unit_type)

		if unit_type == value then
			control:set_value(value)
		end
	end

	control:thaw()
end

function CoreSpawnUnitCutsceneKey:refresh_control_for_parent_unit_name(control)
	control:freeze()
	control:clear()

	local unit_names = table.exclude(self:_unit_names(), self:name())

	if table.empty(unit_names) then
		control:set_enabled(false)
	else
		control:set_enabled(true)

		local value = self:parent_unit_name()

		for _, unit_name in pairs(unit_names) do
			control:append(unit_name)

			if unit_name == value then
				control:set_value(value)
			end
		end
	end

	control:thaw()
end

function CoreSpawnUnitCutsceneKey:refresh_control_for_parent_object_name(control)
	control:freeze()
	control:clear()

	local object_names = self:_unit_object_names(self:parent_unit_name())

	if #object_names == 0 then
		control:set_enabled(false)
	else
		control:set_enabled(true)

		local value = self:parent_object_name()

		for _, object_name in ipairs(object_names) do
			control:append(object_name)

			if object_name == value then
				control:set_value(value)
			end
		end
	end

	control:thaw()
end

function CoreSpawnUnitCutsceneKey:on_attribute_changed(attribute_name, value, previous_value)
	assert(self._cast)

	if self._spawned_unit == nil then
		self:_spawn_unit()
	elseif attribute_name == "unit_type" then
		self._cast:delete_unit(self:name())
		self:_spawn_unit()
	elseif attribute_name == "name" then
		local existing_unit = self:_unit(value, true)

		assert(existing_unit == nil or existing_unit == self._spawned_unit)
		self._cast:rename_unit(previous_value, value)
	elseif attribute_name == "parent_object_name" or attribute_name == "offset" or attribute_name == "rotation" then
		self:_reparent_unit()
	end
end

function CoreSpawnUnitCutsceneKey:_spawn_unit()
	if self:is_valid() and self._cast and self._cast:unit(self:name()) == nil then
		self._spawned_unit = self._cast:spawn_unit(self:name(), self:unit_type())

		self:_reparent_unit()
	end
end

function CoreSpawnUnitCutsceneKey:_delete_unit()
	if self:is_valid() and self._cast then
		self._cast:delete_unit(self:name())
	end
end

function CoreSpawnUnitCutsceneKey:_reparent_unit()
	if self._spawned_unit then
		self._spawned_unit:unlink()

		local parent_object = self:_unit_object(self:parent_unit_name(), self:parent_object_name(), true)

		if parent_object then
			local parent_unit = self:_unit(self:parent_unit_name())

			parent_unit:link(parent_object:name(), self._spawned_unit)
			self._spawned_unit:set_local_position(self:offset())
			self._spawned_unit:set_local_rotation(self:rotation())
			self._cast:_set_unit_and_children_visible(self._spawned_unit, self._cast:unit_visible(self:name()) and parent_unit:visible())
		end
	end
end

function CoreSpawnUnitCutsceneKey:update_gui(time, delta_time)
	if self._database_browser and self._database_browser:update(time, delta_time) then
		if alive(self._cutscene_editor_window) then
			self._cutscene_editor_window:set_enabled(true)
			self._cutscene_editor_window:set_focus()
		end

		self._cutscene_editor_window = nil
		self._database_browser = nil
	end
end

function CoreSpawnUnitCutsceneKey:_on_database_browser_button_clicked(button)
	self._cutscene_editor_window = button:parent()

	while self._cutscene_editor_window and type_name(self._cutscene_editor_window) ~= "EWSFrame" do
		self._cutscene_editor_window = self._cutscene_editor_window:parent()
	end

	assert(self._cutscene_editor_window, "Button is not inside a top-level window.")
	self._cutscene_editor_window:set_enabled(false)

	self._database_browser = CoreDBDialog:new("unit", self, self._on_database_browser_entry_selected, ProjectDatabase)
end

function CoreSpawnUnitCutsceneKey:_on_database_browser_entry_selected()
	local selected_entry = self._database_browser and self._database_browser:get_value()

	assert(selected_entry, "Callback should only be called if an entry was selected.")

	local unit_data = CoreEngineAccess._editor_unit_data(selected_entry:name():id())

	if unit_data then
		self:set_unit_category(unit_data:type():s())
		self:set_unit_type(unit_data:name():s())
		self:refresh_control_for_attribute("unit_category")
		self:refresh_control_for_attribute("unit_type")
	end
end
