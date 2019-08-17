ChangeVanSkinUnitElement = ChangeVanSkinUnitElement or class(MissionElement)

function ChangeVanSkinUnitElement:init(unit)
	ChangeVanSkinUnitElement.super.init(self, unit)

	self._units = {}
	self._van_skins = {}

	for skin_id, data in pairs(tweak_data.van.skins) do
		table.insert(self._van_skins, skin_id)
	end

	table.sort(self._van_skins, function (a, b)
		return a < b
	end)

	self._hed.unit_ids = {}
	self._hed.target_skin = "default"

	table.insert(self._save_values, "unit_ids")
	table.insert(self._save_values, "target_skin")
end

function ChangeVanSkinUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	self._btn_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	self._btn_toolbar:add_tool("ADD_UNIT_LIST", "Add vehicle unit", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	self._btn_toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_unit_list_btn"), nil)
	self._btn_toolbar:add_tool("REMOVE_UNIT_LIST", "Remove vehicle unit", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	self._btn_toolbar:connect("REMOVE_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_unit_list_btn"), nil)
	self._btn_toolbar:realize()
	panel_sizer:add(self._btn_toolbar, 0, 1, "EXPAND,LEFT")
	self:_build_value_combobox(panel, panel_sizer, "target_skin", self._van_skins)

	local help = {
		text = "Changes the equipped skin for the escape van, if it is owned. Can be pointed at a van to change the skin immediately.",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end

function ChangeVanSkinUnitElement:layer_finished()
	MissionElement.layer_finished(self)

	for _, id in pairs(self._hed.unit_ids or {}) do
		local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "load_unit"))

		if unit then
			self._units[unit:unit_data().unit_id] = unit
		end
	end
end

function ChangeVanSkinUnitElement:load_unit(unit)
	if unit then
		self._units[unit:unit_data().unit_id] = unit
	end
end

function ChangeVanSkinUnitElement:update_selected()
	for _, id in pairs(self._hed.unit_ids or {}) do
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
				from_unit = self._unit,
				to_unit = unit
			}

			self:_draw_link(params)
			Application:draw(unit, 1, 0, 0)
		end
	end
end

function ChangeVanSkinUnitElement:update_unselected(t, dt, selected_unit, all_units)
	for _, id in pairs(self._hed.unit_ids or {}) do
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

function ChangeVanSkinUnitElement:draw_links_unselected(...)
	ChangeVanSkinUnitElement.super.draw_links_unselected(self, ...)

	for id, unit in pairs(self._units) do
		local params = {
			g = 0,
			b = 0,
			r = 0.5,
			from_unit = self._unit,
			to_unit = unit
		}

		self:_draw_link(params)
		Application:draw(unit, 0.5, 0, 0)
	end
end

function ChangeVanSkinUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

function ChangeVanSkinUnitElement:select_unit()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		local unit = ray.unit

		if self._units[unit:unit_data().unit_id] then
			self:_remove_unit(unit)
		elseif self:can_select_unit(unit) then
			self:_add_unit(unit)
		end
	end
end

function ChangeVanSkinUnitElement:_remove_unit(unit)
	self._units[unit:unit_data().unit_id] = nil

	table.delete(self._hed.unit_ids, unit:unit_data().unit_id)
end

function ChangeVanSkinUnitElement:_add_unit(unit)
	self._units[unit:unit_data().unit_id] = unit

	table.insert(self._hed.unit_ids, unit:unit_data().unit_id)
end

function ChangeVanSkinUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "select_unit"))
end

function ChangeVanSkinUnitElement:can_select_unit(unit)
	local default_sequence = (tweak_data.van.skins[tweak_data.van.default_skin_id] or {}).sequence_name

	return unit and unit.damage and unit:damage() and unit:damage():has_sequence(default_sequence)
end

function ChangeVanSkinUnitElement:add_unit_list_btn()
	local function f(unit)
		if self._units[unit:unit_data().unit_id] then
			return false
		end

		return self:can_select_unit(unit)
	end

	local dialog = SelectUnitByNameModal:new("Add Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		if not self._units[unit:unit_data().unit_id] then
			self:_add_unit(unit)
		end
	end
end

function ChangeVanSkinUnitElement:remove_unit_list_btn()
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
