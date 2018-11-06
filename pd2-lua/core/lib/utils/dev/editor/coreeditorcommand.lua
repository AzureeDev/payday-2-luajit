core:module("CoreEditorCommand")

EditorCommand = EditorCommand or class()
EditorCommand.__type = EditorCommand
EditorCommand.UnitValues = {}

function EditorCommand:init(layer)
	self._layer = layer
	self._values = {}
end

function EditorCommand:__tostring()
	return "[Command base]"
end

function EditorCommand:execute()
	print("Execute not implemented for EditorCommand")
end

function EditorCommand:undo()
	print("Undo not implemented for EditorCommand")
end

function EditorCommand:layer()
	return self._layer
end

function EditorCommand:value(val, default)
	self._values = self._values or {}
	local v = self._values[val]

	if v ~= nil then
		return v
	else
		return default
	end
end

ReferenceUnitCommand = ReferenceUnitCommand or class(EditorCommand)
ReferenceUnitCommand.__type = ReferenceUnitCommand
ReferenceUnitCommand.UnitValues = {
	"reference_unit",
	"selected_units"
}

function ReferenceUnitCommand:execute()
	if not self:are_unit_values_set() then
		self:save_unit_values()
	end
end

function ReferenceUnitCommand:are_unit_values_set()
	return self._values.__set
end

function ReferenceUnitCommand:save_unit_values()
	self._values.reference_unit = self._layer._selected_unit:unit_data().unit_id
	self._values.selected_units = {}

	for _, unit in ipairs(self._layer._selected_units) do
		table.insert(self._values.selected_units, unit:unit_data().unit_id)
	end

	self._values.__set = true
end

function ReferenceUnitCommand:get_saved_units()
	local reference_unit = managers.editor:unit_with_id(self:value("reference_unit")) or managers.editor:get_special_unit_with_id(self:value("reference_unit"))
	local units = {}

	for _, id in ipairs(self:value("selected_units")) do
		local unit = managers.editor:unit_with_id(id)

		if unit then
			table.insert(units, unit)
		end
	end

	return reference_unit, units
end

MoveUnitCommand = MoveUnitCommand or class(ReferenceUnitCommand)
MoveUnitCommand.__type = MoveUnitCommand
MoveUnitCommand.UnitValues = {
	"reference_unit",
	"selected_units"
}

function MoveUnitCommand:init(layer, command)
	MoveUnitCommand.super.init(self, layer)

	if command and command:are_unit_values_set() then
		self._values = command._values
	end
end

function MoveUnitCommand:save_unit_values()
	MoveUnitCommand.super.save_unit_values(self)

	local reference_unit, units = self:get_saved_units()

	if alive(reference_unit) then
		self._values.original_pos = reference_unit:unit_data().world_pos
	end
end

function MoveUnitCommand:execute(pos)
	MoveUnitCommand.super.execute(self)

	self._values.target_pos = pos or self._values.target_pos

	self:perform_move(self:value("target_pos"), self:get_saved_units())
end

function MoveUnitCommand:undo()
	self:perform_move(self:value("original_pos"), self:get_saved_units())
end

function MoveUnitCommand:perform_move(pos, reference, units)
	local reselect = false

	for _, unit in ipairs(self:layer():selected_units()) do
		if unit ~= reference and not table.contains(units, unit) then
			reselect = true
		end
	end

	if reselect then
		local select_units = {
			reference
		}

		for _, unit in ipairs(units) do
			table.insert(select_units, unit)
		end

		managers.editor:select_units(select_units)
	end

	for _, unit in ipairs(units) do
		if unit ~= reference then
			self:layer():set_unit_position(unit, pos, reference:rotation())
		end
	end

	if alive(reference) then
		reference:set_position(pos)

		reference:unit_data().world_pos = pos

		self:layer():_on_unit_moved(reference, pos)
	end
end

function MoveUnitCommand:__tostring()
	return string.format("[Command MoveUnit target: %s]", tostring(self:value("target_pos")))
end

RotateUnitCommand = RotateUnitCommand or class(ReferenceUnitCommand)
RotateUnitCommand.__type = RotateUnitCommand
RotateUnitCommand.UnitValues = {
	"reference_unit",
	"selected_units"
}

function RotateUnitCommand:init(layer, command)
	RotateUnitCommand.super.init(self, layer)

	if command and command:are_unit_values_set() then
		self._values = _G.clone(command._values)
	end
end

function RotateUnitCommand:save_unit_values()
	MoveUnitCommand.super.save_unit_values(self)

	self._values.rot_add = Rotation()
end

function RotateUnitCommand:execute(rot)
	RotateUnitCommand.super.execute(self)

	self._values.rot_add = rot and self._values.rot_add * rot or self._values.rot_add
	rot = rot or self._values.rot_add

	self:perform_rotation(rot or self._values.rot_add, self:get_saved_units())
end

function RotateUnitCommand:undo()
	self:perform_rotation(self:value("rot_add"):inverse(), self:get_saved_units())
end

function RotateUnitCommand:perform_rotation(rot, reference, units)
	local rot = rot * reference:rotation()

	reference:set_rotation(rot)
	self:layer():_on_unit_rotated(reference, rot)

	for _, unit in ipairs(units) do
		if unit ~= reference then
			self:layer():set_unit_position(unit, reference:position(), rot)
			self:layer():set_unit_rotation(unit, rot)
		end
	end
end

function RotateUnitCommand:__tostring()
	return string.format("[Command RotateUnit target: %s]", tostring(self:value("rot_add")))
end

HideUnitsCommand = HideUnitsCommand or class(EditorCommand)
HideUnitsCommand.__type = HideUnitsCommand
HideUnitsCommand.UnitValues = {
	"units"
}

function HideUnitsCommand:execute(units, hidden)
	if not self._values.units then
		self._values.units = {}

		for _, unit in ipairs(units) do
			table.insert(self._values.units, unit:unit_data().unit_id)
		end

		self._values.hide = hidden
	end

	if hidden == nil then
		hidden = self:value("hide")
	end

	self:hide_units(self:value("units"), hidden)
end

function HideUnitsCommand:undo()
	self:hide_units(self:value("units"), not self:value("hide"))
end

function HideUnitsCommand:hide_units(units, hidden)
	for _, unit_id in ipairs(units) do
		local unit = managers.editor:unit_with_id(unit_id)

		if alive(unit) and unit:enabled() then
			managers.editor:set_unit_visible(unit, not hidden)
		end
	end
end

function HideUnitsCommand:__tostring()
	return string.format("[Command HideUnits hidden: %s]", tostring(self:value("hide")))
end

SpawnUnitCommand = SpawnUnitCommand or class(EditorCommand)
SpawnUnitCommand.__type = SpawnUnitCommand
SpawnUnitCommand.UnitValues = {
	"spawned_unit"
}

function SpawnUnitCommand:execute(name, pos, rot, to_continent_name, prefered_id)
	if name and pos and rot then
		self._values.args = {
			name,
			pos,
			rot,
			to_continent_name,
			prefered_id
		}
	end

	local unit = self:layer():create_unit(unpack(self._values.args))

	table.insert(self:layer()._created_units, unit)

	self:layer()._created_units_pairs[unit:unit_data().unit_id] = unit

	self:layer():set_select_unit(unit)

	self._values.spawned_unit = unit:unit_data().unit_id

	return unit
end

function SpawnUnitCommand:undo()
	local unit = managers.editor:unit_with_id(self:value("spawned_unit"))

	if alive(unit) then
		self:layer():delete_unit(unit, true)
	end
end

function SpawnUnitCommand:__tostring()
	return string.format("[Command SpawnUnit %s]", tostring(self._values.args[1]))
end

DeleteStaticUnitCommand = DeleteStaticUnitCommand or class(EditorCommand)
DeleteStaticUnitCommand.__type = DeleteStaticUnitCommand
DeleteStaticUnitCommand.__priority = 1000000
DeleteStaticUnitCommand.UnitValues = {
	"unit"
}
DeleteStaticUnitCommand.IgnoredRestoreKeys = {
	"id",
	"name_id",
	"continent"
}

function DeleteStaticUnitCommand:execute(unit)
	unit = unit or managers.editor:unit_with_id(self:value("id"))

	self:save_unit_values(unit)

	if self:layer():selected_unit() == unit then
		self:layer():set_reference_unit(nil)
		self:layer():update_unit_settings()
	end

	table.delete(self:layer()._created_units, unit)

	self:layer()._created_units_pairs[unit:unit_data().unit_id] = nil

	self:layer():remove_unit(unit)
end

function DeleteStaticUnitCommand:undo()
	local unit = self:layer():do_spawn_unit(self:value("name"), self:value("pos"), self:value("rot"), self:value("continent"), true, self:value("id"))

	self:restore_unit_values(unit)
	self:layer():set_name_id(unit, self._values.unit_data.name_id)
	self:layer():clone_edited_values(unit, unit)
end

function DeleteStaticUnitCommand:save_unit_values(unit)
	self._values.id = unit:unit_data().unit_id
	self._values.name = unit:name()
	self._values.pos = unit:position()
	self._values.rot = unit:rotation()
	self._values.continent = unit:unit_data().continent
	self._values.unit_data = unit:unit_data()
end

function DeleteStaticUnitCommand:restore_unit_values(unit)
	for key, value in pairs(self._values.unit_data) do
		if not table.contains(self.IgnoredRestoreKeys, key) then
			unit:unit_data()[key] = value
		end
	end
end

function DeleteStaticUnitCommand:__tostring()
	return string.format("[Command DeleteStaticUnit %s(%s)]", tostring(self._values.name), tostring(self._values.id))
end

MissionElementEditorCommand = MissionElementEditorCommand or class(EditorCommand)
MissionElementEditorCommand.__type = MissionElementEditorCommand

function MissionElementEditorCommand:init(mission_element)
	MissionElementEditorCommand.super.init(self, managers.editor:layer("Mission"))

	self._values.element_id = mission_element._unit:unit_data().unit_id
end

function MissionElementEditorCommand:get_self_mission_element()
	return managers.editor:unit_with_id(self._values.element_id):mission_element()
end

DeleteMissionElementCommand = DeleteMissionElementCommand or class(MissionElementEditorCommand)
DeleteMissionElementCommand.__type = DeleteMissionElementCommand
DeleteMissionElementCommand.__priority = 100000

function DeleteMissionElementCommand:execute(mission_element)
	mission_element = mission_element or self:get_self_mission_element()

	for idx, key in ipairs(mission_element._save_values) do
		self._values[key] = mission_element._hed[key]
	end
end

function DeleteMissionElementCommand:undo(is_final_action)
	local mission_element = self:get_self_mission_element()

	for idx, key in ipairs(mission_element._save_values) do
		mission_element._hed[key] = self._values[key]
	end

	if is_final_action then
		mission_element:destroy_panel()
		mission_element:panel()
		managers.editor:layer("Mission"):update_unit_settings()
	end
end

function DeleteMissionElementCommand:__tostring()
	return string.format("[Command DeleteMissionElement %s]", tostring(self._values.element_id))
end

MissionElementAddOnExecutedCommand = MissionElementAddOnExecutedCommand or class(MissionElementEditorCommand)
MissionElementAddOnExecutedCommand.__type = MissionElementAddOnExecutedCommand

function MissionElementAddOnExecutedCommand:execute(mission_element, unit, existing_params)
	mission_element = mission_element or self:get_self_mission_element()
	unit = unit or managers.editor:unit_with_id(self._values.params.id)
	local params = existing_params or self._values.params or {}
	params.id = unit:unit_data().unit_id
	params.delay = params.delay or 0
	params.alternative = params.alternative or mission_element.ON_EXECUTED_ALTERNATIVES and mission_element.ON_EXECUTED_ALTERNATIVES[1] or nil

	table.insert(mission_element._on_executed_units, unit)
	table.insert(mission_element._hed.on_executed, params)

	if mission_element._timeline then
		mission_element._timeline:add_element(unit, params)
	end

	mission_element:append_elements_sorted()
	mission_element:set_on_executed_element(unit)

	self._values.params = params
end

function MissionElementAddOnExecutedCommand:undo()
	local mission_element = self:get_self_mission_element()
	local remove_unit = managers.editor:unit_with_id(self._values.params.id)
	local command = MissionElementRemoveOnExecutedCommand:new(mission_element)

	command:execute(mission_element, remove_unit)
end

function MissionElementAddOnExecutedCommand:__tostring()
	return string.format("[Command AddOnExecuted %s]", tostring(self._values.element_id))
end

MissionElementRemoveOnExecutedCommand = MissionElementRemoveOnExecutedCommand or class(MissionElementEditorCommand)
MissionElementRemoveOnExecutedCommand.__type = MissionElementRemoveOnExecutedCommand

function MissionElementRemoveOnExecutedCommand:execute(mission_element, unit)
	mission_element = mission_element or self:get_self_mission_element()
	unit = unit or managers.editor:unit_with_id(self._values.unit_id)
	self._values.unit_id = unit:unit_data().unit_id

	for _, on_executed in ipairs(mission_element._hed.on_executed) do
		if on_executed.id == unit:unit_data().unit_id then
			self._values.removed_on_executed = on_executed

			if mission_element._timeline then
				mission_element._timeline:remove_element(on_executed)
			end

			table.delete(mission_element._hed.on_executed, on_executed)
			table.delete(mission_element._on_executed_units, unit)
			mission_element:append_elements_sorted()

			return true
		end
	end

	return false
end

function MissionElementRemoveOnExecutedCommand:undo()
	local mission_element = self:get_self_mission_element()
	local add_unit = managers.editor:unit_with_id(self._values.removed_on_executed.id)
	local command = MissionElementAddOnExecutedCommand:new(mission_element)

	command:execute(mission_element, add_unit, self._values.removed_on_executed)
end

function MissionElementRemoveOnExecutedCommand:__tostring()
	return string.format("[Command RemoveOnExecuted %s]", tostring(self._values.element_id))
end

MissionElementAddLinkElementCommand = MissionElementAddLinkElementCommand or class(MissionElementEditorCommand)
MissionElementAddLinkElementCommand.__type = MissionElementAddLinkElementCommand

function MissionElementAddLinkElementCommand:execute(mission_element, link_name, unit_id)
	mission_element = mission_element or self:get_self_mission_element()
	link_name = link_name or self._values.link_name
	unit_id = unit_id or self._values.unit_id
	self._values.link_name = link_name
	self._values.unit_id = unit_id

	if mission_element._hed[link_name] and not table.contains(mission_element._hed[link_name], unit_id) then
		table.insert(mission_element._hed[link_name], unit_id)
		mission_element:on_added_link_element(link_name, unit_id)

		return true
	else
		return false
	end
end

function MissionElementAddLinkElementCommand:undo()
	local mission_element = self:get_self_mission_element()
	local command = MissionElementRemoveLinkElementCommand:new(mission_element)

	command:execute(mission_element, self:value("link_name"), self:value("unit_id"))
end

function MissionElementAddLinkElementCommand:__tostring()
	return string.format("[Command AddLinkElement [%s %s]]", tostring(self:value("link_name")), tostring(self:value("unit_id")))
end

MissionElementRemoveLinkElementCommand = MissionElementRemoveLinkElementCommand or class(MissionElementEditorCommand)
MissionElementRemoveLinkElementCommand.__type = MissionElementRemoveLinkElementCommand

function MissionElementRemoveLinkElementCommand:execute(mission_element, link_name, unit_id)
	mission_element = mission_element or self:get_self_mission_element()
	link_name = link_name or self._values.link_name
	unit_id = unit_id or self._values.unit_id
	self._values.link_name = link_name
	self._values.unit_id = unit_id

	if table.contains(mission_element._hed[link_name], unit_id) then
		table.delete(mission_element._hed[link_name], unit_id)
		mission_element:on_removed_link_element(link_name, unit_id)

		return true
	else
		return false
	end
end

function MissionElementRemoveLinkElementCommand:undo()
	local mission_element = self:get_self_mission_element()
	local command = MissionElementAddLinkElementCommand:new(mission_element)

	command:execute(mission_element, self:value("link_name"), self:value("unit_id"))
end

function MissionElementRemoveLinkElementCommand:__tostring()
	return string.format("[Command RemoveLinkElement [%s %s]]", tostring(self:value("link_name")), tostring(self:value("unit_id")))
end
