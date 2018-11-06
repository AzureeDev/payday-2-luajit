AIForceAttentionElement = AIForceAttentionElement or class(MissionElement)
local att_unit_label_base = "Selected Unit: "
local included_units_label_base = "Included Units: "
local excluded_units_label_base = "Excluded Units: "
local all_spawn_types = {
	"ai_spawn_enemy",
	"ai_enemy_group",
	"ai_spawn_civilian",
	"ai_civilian_group",
	"point_spawn_player"
}
local enemy_spawn_types = {
	"ai_spawn_enemy",
	"ai_enemy_group"
}

function AIForceAttentionElement:init(unit)
	AIForceAttentionElement.super.init(self, unit)

	self._hed.att_unit_id = nil
	self._hed.affected_units = {}
	self._hed.use_force_spawned = false
	self._hed.ignore_vis_blockers = false
	self._hed.include_all_force_spawns = false
	self._hed.included_units = {}
	self._hed.excluded_units = {}
	self._hed.is_spawn = false

	table.insert(self._save_values, "att_unit_id")
	table.insert(self._save_values, "affected_units")
	table.insert(self._save_values, "use_force_spawned")
	table.insert(self._save_values, "included_units")
	table.insert(self._save_values, "excluded_units")
	table.insert(self._save_values, "ignore_vis_blockers")
	table.insert(self._save_values, "include_all_force_spawns")
	table.insert(self._save_values, "is_spawn")
end

function AIForceAttentionElement:select_att_unit(label)
	local function f(unit)
		if self._hed.att_unit_id == unit:unit_data().unit_id then
			return false
		end

		return managers.editor:layer("Mission"):category_map()[unit:type():s()]
	end

	local dialog = SingleSelectUnitByNameModal:new("Select Unit", f)
	local unit = dialog:_selected_item_unit()
	self._hed.att_unit_id = unit and unit:unit_data().unit_id or self._hed.att_unit_id

	if unit then
		for _, name in ipairs(all_spawn_types) do
			if string.find(unit:name():s(), name, 1, true) then
				self._hed.is_spawn = true

				break
			end
		end

		label:set_label(att_unit_label_base .. unit:unit_data().name_id)
	end
end

function AIForceAttentionElement:remove_att_unit(label)
	self._hed.att_unit_id = nil

	label:set_label(att_unit_label_base .. "None")
end

function AIForceAttentionElement:add_included_units(label)
	local function f(unit)
		if table.contains(self._hed.included_units, unit:unit_data().unit_id) or table.contains(self._hed.excluded_units, unit:unit_data().unit_id) then
			return false
		end

		local is_spawn = false

		for _, name in ipairs(enemy_spawn_types) do
			if string.find(unit:name():s(), name, 1, true) then
				is_spawn = true
			end
		end

		return is_spawn and managers.editor:layer("Mission"):category_map()[unit:type():s()]
	end

	local dialog = SelectUnitByNameModal:new("Add Units", f)
	local units = dialog:selected_units()
	self._hed.included_units = {}

	for _, unit in pairs(units) do
		table.insert(self._hed.included_units, unit:unit_data().unit_id)
	end

	label:set_label(included_units_label_base .. #self._hed.included_units)
end

function AIForceAttentionElement:remove_included_units(label)
	local function f(unit)
		return table.contains(self._hed.included_units, unit:unit_data().unit_id)
	end

	local dialog = SelectUnitByNameModal:new("Remove Units", f)
	local units = dialog:selected_units()

	for _, unit in pairs(units) do
		table.delete(self._hed.included_units, unit:unit_data().unit_id)
	end

	label:set_label(included_units_label_base .. #self._hed.included_units)
end

function AIForceAttentionElement:add_excluded_units(label)
	local function f(unit)
		if table.contains(self._hed.excluded_units, unit:unit_data().unit_id) or table.contains(self._hed.included_units, unit:unit_data().unit_id) then
			return false
		end

		local is_spawn = false

		for _, name in ipairs(enemy_spawn_types) do
			if string.find(unit:name():s(), name, 1, true) then
				is_spawn = true
			end
		end

		return is_spawn and managers.editor:layer("Mission"):category_map()[unit:type():s()]
	end

	local dialog = SelectUnitByNameModal:new("Add Units", f)
	local units = dialog:selected_units()
	self._hed.excluded_units = {}

	for _, unit in pairs(units) do
		table.insert(self._hed.excluded_units, unit:unit_data().unit_id)
	end

	label:set_label(excluded_units_label_base .. #self._hed.excluded_units)
end

function AIForceAttentionElement:remove_excluded_units(label)
	local function f(unit)
		return table.contains(self._hed.excluded_units, unit:unit_data().unit_id)
	end

	local dialog = SelectUnitByNameModal:new("Remove Units", f)
	local units = dialog:selected_units()

	for _, unit in pairs(units) do
		table.delete(self._hed.excluded_units, unit:unit_data().unit_id)
	end

	label:set_label(excluded_units_label_base .. #self._hed.excluded_units)
end

function AIForceAttentionElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local affected_panel_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Affected Units")

	panel_sizer:add(affected_panel_sizer, 0, 1, "EXPAND,LEFT")
	panel_sizer:add_spacer(0, 4)
	self:_build_value_checkbox(panel, affected_panel_sizer, "ignore_vis_blockers", "Allows the affected units to shoot through vis_blockers")
	affected_panel_sizer:add_spacer(0, 2)
	self:_build_value_checkbox(panel, affected_panel_sizer, "include_all_force_spawns", "Includes all units that don't participate in the group AI")
	affected_panel_sizer:add_spacer(0, 4)

	local included_units_panel_sizer = EWS:BoxSizer("HORIZONTAL")

	affected_panel_sizer:add(included_units_panel_sizer, 0, 1, "EXPAND,LEFT")

	local included_units_label_text = included_units_label_base .. #self._hed.included_units
	local included_units_label = EWS:StaticText(panel, included_units_label_text, "INCLUDED_UNITS_LABEL", nil)
	local add_included_unit_btn = EWS:BitmapButton(panel, CoreEws.image_path("world_editor\\unit_by_name_list.png"), "ADD_INCLUDED_UNITS", nil)

	add_included_unit_btn:set_tool_tip("Add included units from unit list")
	add_included_unit_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "add_included_units", included_units_label), nil)

	local remove_included_unit_btn = EWS:BitmapButton(panel, CoreEws.image_path("toolbar\\delete_16x16.png"), "REMOVE_INCLUDED_UNITS", nil)

	remove_included_unit_btn:set_tool_tip("Remove included units from unit list")
	remove_included_unit_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "remove_included_units", included_units_label), nil)
	included_units_panel_sizer:add(add_included_unit_btn, 0, 1, "EXPAND,LEFT")
	included_units_panel_sizer:add(remove_included_unit_btn, 0, 1, "EXPAND,LEFT")
	included_units_panel_sizer:add(included_units_label, 0, 5, "EXPAND,LEFT")
	affected_panel_sizer:add_spacer(0, 4)

	local excluded_units_panel_sizer = EWS:BoxSizer("HORIZONTAL")

	affected_panel_sizer:add(excluded_units_panel_sizer, 0, 1, "EXPAND,LEFT")

	local excluded_units_label_text = excluded_units_label_base .. #self._hed.excluded_units
	local excluded_units_label = EWS:StaticText(panel, excluded_units_label_text, "EXCLUDED_UNITS_LABEL", nil)
	local add_excluded_unit_btn = EWS:BitmapButton(panel, CoreEws.image_path("world_editor\\unit_by_name_list.png"), "ADD_EXCLUDED_UNITS", nil)

	add_excluded_unit_btn:set_tool_tip("Add excluded units from unit list")
	add_excluded_unit_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "add_excluded_units", excluded_units_label), nil)

	local remove_excluded_unit_btn = EWS:BitmapButton(panel, CoreEws.image_path("toolbar\\delete_16x16.png"), "REMOVE_EXCLUDED_UNITS", nil)

	remove_excluded_unit_btn:set_tool_tip("Remove excluded units from unit list")
	remove_excluded_unit_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "remove_excluded_units", excluded_units_label), nil)
	excluded_units_panel_sizer:add(add_excluded_unit_btn, 0, 1, "EXPAND,LEFT")
	excluded_units_panel_sizer:add(remove_excluded_unit_btn, 0, 1, "EXPAND,LEFT")
	excluded_units_panel_sizer:add(excluded_units_label, 0, 5, "EXPAND,LEFT")

	local att_unit_panel_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "Attention Unit")

	panel_sizer:add(att_unit_panel_sizer, 0, 1, "EXPAND,LEFT")
	panel_sizer:add_spacer(0, 4)

	local att_unit = self._hed.att_unit_id and managers.editor:unit_with_id(self._hed.att_unit_id)
	local att_unit_label_text = att_unit_label_base .. (att_unit and att_unit:unit_data().name_id or "None")
	local att_unit_label = EWS:StaticText(panel, att_unit_label_text, "ATT_UNIT_LABEL", nil)
	local select_att_unit_btn = EWS:BitmapButton(panel, CoreEws.image_path("world_editor\\unit_by_name_list.png"), "SELECT_ATT_UNIT", nil)

	select_att_unit_btn:set_tool_tip("Select unit from unit list")
	select_att_unit_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "select_att_unit", att_unit_label), nil)

	local remove_att_unit_btn = EWS:BitmapButton(panel, CoreEws.image_path("toolbar\\delete_16x16.png"), "REMOVE_ATT_UNIT", nil)

	remove_att_unit_btn:set_tool_tip("Removes selected unit")
	remove_att_unit_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "remove_att_unit", att_unit_label), nil)
	att_unit_panel_sizer:add(select_att_unit_btn, 0, 1, "EXPAND,LEFT")
	att_unit_panel_sizer:add(remove_att_unit_btn, 0, 1, "EXPAND,LEFT")
	att_unit_panel_sizer:add(att_unit_label, 0, 5, "EXPAND,LEFT")
	self:_add_help_text("Select a unit to force the AI's attention to. The 'Affected Units' panel allows you to control which units are affected by this and their behaviour.")
end
