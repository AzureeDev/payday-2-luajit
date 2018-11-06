UnitDamageTriggerUnitElement = UnitDamageTriggerUnitElement or class(MissionElement)

function UnitDamageTriggerUnitElement:init(unit)
	UnitDamageTriggerUnitElement.super.init(self, unit)

	self._units = {}
	self._hed.unit_ids = {}
	self._hed.damage_types = ""

	table.insert(self._save_values, "unit_ids")
	table.insert(self._save_values, "damage_types")
end

function UnitDamageTriggerUnitElement:layer_finished()
	MissionElement.layer_finished(self)

	for _, id in pairs(self._hed.unit_ids) do
		local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "load_unit"))

		if unit then
			self._units[unit:unit_data().unit_id] = unit
		end
	end
end

function UnitDamageTriggerUnitElement:load_unit(unit)
	if unit then
		self._units[unit:unit_data().unit_id] = unit
	end
end

function UnitDamageTriggerUnitElement:update_selected()
	for _, id in pairs(self._hed.unit_ids) do
		if not alive(self._units[id]) then
			table.delete(self._hed.unit_ids, id)

			self._units[id] = nil
		end
	end

	for id, unit in pairs(self._units) do
		if not alive(unit) then
			table.delete(self._hed.unit_ids, id)

			self._units[id] = nil
		else
			local params = {
				g = 0,
				b = 0,
				r = 1,
				from_unit = unit,
				to_unit = self._unit
			}

			self:_draw_link(params)
			Application:draw(unit, 1, 0, 0)
		end
	end
end

function UnitDamageTriggerUnitElement:update_unselected(t, dt, selected_unit, all_units)
	for _, id in pairs(self._hed.unit_ids) do
		if not alive(self._units[id]) then
			table.delete(self._hed.unit_ids, id)

			self._units[id] = nil
		end
	end

	for id, unit in pairs(self._units) do
		if not alive(unit) then
			table.delete(self._hed.unit_ids, id)

			self._units[id] = nil
		end
	end
end

function UnitDamageTriggerUnitElement:draw_links_unselected(...)
	UnitDamageTriggerUnitElement.super.draw_links_unselected(self, ...)

	for id, unit in pairs(self._units) do
		local params = {
			g = 0,
			b = 0,
			r = 0.5,
			from_unit = unit,
			to_unit = self._unit
		}

		self:_draw_link(params)
		Application:draw(unit, 0.5, 0, 0)
	end
end

function UnitDamageTriggerUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

function UnitDamageTriggerUnitElement:select_unit()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		local unit = ray.unit

		if unit.damage and unit:damage() then
			if self._units[unit:unit_data().unit_id] then
				self:_remove_unit(unit)
			else
				self:_add_unit(unit)
			end
		else
			self:add_on_executed(unit)
		end
	end
end

function UnitDamageTriggerUnitElement:_remove_unit(unit)
	self._units[unit:unit_data().unit_id] = nil

	table.delete(self._hed.unit_ids, unit:unit_data().unit_id)
end

function UnitDamageTriggerUnitElement:_add_unit(unit)
	self._units[unit:unit_data().unit_id] = unit

	table.insert(self._hed.unit_ids, unit:unit_data().unit_id)
end

function UnitDamageTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "select_unit"))
end

function UnitDamageTriggerUnitElement:add_unit_list_btn()
	local function f(unit)
		if self._units[unit:unit_data().unit_id] then
			return false
		end

		return unit.damage and unit:damage()
	end

	local dialog = SelectUnitByNameModal:new("Add Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		if not self._units[unit:unit_data().unit_id] then
			self:_add_unit(unit)
		end
	end
end

function UnitDamageTriggerUnitElement:remove_unit_list_btn()
	local function f(unit)
		return self._units[unit:unit_data().unit_id]
	end

	local dialog = SelectUnitByNameModal:new("Remove Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		if self._units[unit:unit_data().unit_id] then
			self:_remove_unit(unit)
		end
	end
end

function UnitDamageTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	self._btn_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	self._btn_toolbar:add_tool("ADD_UNIT_LIST", "Add unit damage reporter from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	self._btn_toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_unit_list_btn"), nil)
	self._btn_toolbar:add_tool("REMOVE_UNIT_LIST", "Remove unit damage reporter from unit list", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	self._btn_toolbar:connect("REMOVE_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_unit_list_btn"), nil)
	self._btn_toolbar:realize()
	panel_sizer:add(self._btn_toolbar, 0, 1, "EXPAND,LEFT")

	local dmg_sizer = EWS:BoxSizer("HORIZONTAL")

	dmg_sizer:add(EWS:StaticText(panel, "Damage Types Filter:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local dmg_types = EWS:TextCtrl(panel, self._hed.damage_types, "", "TE_PROCESS_ENTER")

	dmg_types:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "damage_types",
		ctrlr = dmg_types
	})
	dmg_types:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "damage_types",
		ctrlr = dmg_types
	})
	dmg_sizer:add(dmg_types, 2, 0, "ALIGN_CENTER_VERTICAL")
	panel_sizer:add(dmg_sizer, 0, 0, "EXPAND")
	self:add_help_text({
		text = "logic_counter_operator elements will use the reported <damage> as the amount to add/subtract/set.\nDamage types can be filtered by specifying specific damage types separated by spaces.",
		panel = panel,
		sizer = panel_sizer
	})
end
