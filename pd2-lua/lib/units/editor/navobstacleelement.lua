NavObstacleElement = NavObstacleElement or class(MissionElement)

function NavObstacleElement:init(unit)
	NavObstacleElement.super.init(self, unit)

	self._guis = {}
	self._obstacle_units = {}
	self._hed.obstacle_list = {}
	self._all_object_names = {}
	self._hed.operation = "add"

	table.insert(self._save_values, "obstacle_list")
	table.insert(self._save_values, "operation")
end

function NavObstacleElement:layer_finished()
	MissionElement.layer_finished(self)

	if self._hed.obstacle_unit_id then
		table.insert(self._hed.obstacle_list, {
			unit_id = self._hed.obstacle_unit_id,
			obj_name = self._hed.obstacle_obj_name
		})
	end

	for _, data in pairs(self._hed.obstacle_list) do
		local unit = managers.worlddefinition:get_unit_on_load(data.unit_id, callback(self, self, "load_unit"))

		if unit then
			self._obstacle_units[unit:unit_data().unit_id] = unit
		end
	end
end

function NavObstacleElement:load_unit(unit)
	if unit then
		self._obstacle_units[unit:unit_data().unit_id] = unit
	end
end

function NavObstacleElement:update_selected(t, dt, selected_unit, all_units)
	self:_check_alive_units_and_draw("selected", selected_unit, all_units)
end

function NavObstacleElement:update_unselected(t, dt, selected_unit, all_units)
	self:_check_alive_units_and_draw("unselected", selected_unit, all_units)
end

function NavObstacleElement:_check_alive_units_and_draw(type, selected_unit, all_units)
	local r = type == "selected" and 1 or 0.5
	local g = 0
	local b = 0

	for id, unit in pairs(self._obstacle_units) do
		if not alive(unit) then
			self:_remove_by_unit_id(id)

			self._obstacle_units[id] = nil
		elseif self:_should_draw_link(selected_unit, unit) then
			local params = {
				from_unit = self._unit,
				to_unit = unit,
				r = r,
				g = g,
				b = b
			}

			self:_draw_link(params)
			Application:draw(unit, r / 2, g / 2, b / 2)

			for _, data in pairs(self._hed.obstacle_list) do
				if data.unit_id == id then
					local obj = unit:get_object(data.obj_name)

					if obj then
						Application:draw(obj, r, g, b)
					end
				end
			end
		end
	end
end

function NavObstacleElement:draw_links_unselected(...)
	NavObstacleElement.super.draw_links_unselected(self, ...)
end

function NavObstacleElement:_select_unit_mask()
	return managers.slot:get_mask("all") - managers.slot:get_mask("mission_elements")
end

function NavObstacleElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = self:_select_unit_mask()
	})

	if ray and ray.unit then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

function NavObstacleElement:select_unit()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = self:_select_unit_mask()
	})

	if ray and ray.unit then
		self:_check_add_unit(ray.unit)
	end
end

function NavObstacleElement:_check_add_unit(unit)
	local all_object_names = self:_get_objects_by_unit(unit)
	self._obstacle_units[unit:unit_data().unit_id] = unit
	local obstacle_list_data = {
		unit_id = unit:unit_data().unit_id,
		obj_name = Idstring(self._unindent_obj_name(all_object_names[1]))
	}

	table.insert(self._hed.obstacle_list, obstacle_list_data)
	self:_add_unit(unit, all_object_names, obstacle_list_data)
end

function NavObstacleElement:_remove_by_unit_id(unit_id)
	local remove_entries = {}

	for id, entry in pairs(self._guis) do
		if entry.unit_id == unit_id then
			table.insert(remove_entries, id)
		end
	end

	for _, id in ipairs(remove_entries) do
		self:remove_entry(id)
	end

	for i, data in ipairs(clone(self._hed.obstacle_list)) do
		if data.unit_id == unit_id then
			table.remove(self._hed.obstacle_list, i)
		end
	end

	self:_remove_from_obstacle_list(unit_id)
end

function NavObstacleElement:remove_entry(id)
	local unit_id = self._guis[id].unit_id

	self._guis[id].unit_id_ctrlr:destroy()
	self._guis[id].obj_names:destroy()
	self._guis[id].name_ctrlr:destroy()
	self._guis[id].toolbar:destroy()

	self._guis[id] = nil

	self._panel:layout()

	for i, entry in pairs(clone(self._hed.obstacle_list)) do
		if entry.guis_id == id then
			table.remove(self._hed.obstacle_list, i)
		end
	end

	for _, guis in pairs(self._guis) do
		if guis.unit_id == unit_id then
			return
		end
	end

	self._obstacle_units[unit_id] = nil
end

function NavObstacleElement:_remove_from_obstacle_list(unit_id)
	for i, entry in pairs(clone(self._hed.obstacle_list)) do
		if entry.unit_id == unit_id then
			table.remove(self._hed.obstacle_list, i)
		end
	end
end

function NavObstacleElement:_add_unit(unit, all_object_names, obstacle_list_data)
	local panel = self._panel
	local panel_sizer = self._panel_sizer
	local unit_id = EWS:StaticText(panel, "" .. unit:unit_data().name_id, 0, "")

	panel_sizer:add(unit_id, 0, 0, "EXPAND")

	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(h_sizer, 0, 1, "EXPAND,LEFT")

	local obj_names_params = {
		name = "Object:",
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "Select an object from the combobox",
		sorted = true,
		ctrlr_proportions = 2,
		panel = panel,
		sizer = h_sizer,
		options = all_object_names,
		value = self._get_indented_obj_name(nil, unit, obstacle_list_data.obj_name)
	}
	local obj_names = CoreEws.combobox(obj_names_params)
	self._guis_id = self._guis_id or 0
	self._guis_id = self._guis_id + 1
	obstacle_list_data.guis_id = self._guis_id
	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("SELECT", "Select dialog", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	toolbar:connect("SELECT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_entry"), self._guis_id)
	toolbar:realize()

	self._guis[self._guis_id] = {
		unit_id_ctrlr = unit_id,
		unit = unit,
		unit_id = unit:unit_data().unit_id,
		obj_names = obj_names,
		name_ctrlr = obj_names_params.name_ctrlr,
		toolbar = toolbar,
		guis_id = self._guis_id
	}

	h_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
	obj_names:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_obj_name_data"), self._guis_id)
	panel:layout()
end

function NavObstacleElement:set_obj_name_data(guis_id)
	local obj_name = self._guis[guis_id].obj_names:get_value()

	for i, entry in pairs(self._hed.obstacle_list) do
		if entry.guis_id == guis_id then
			entry.obj_name = Idstring(self._unindent_obj_name(obj_name))

			break
		end
	end
end

function NavObstacleElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "select_unit"))
end

function NavObstacleElement:select_unit_list_btn()
	local function f(unit)
		if not managers.editor:layer("Statics"):category_map()[unit:type():s()] then
			return false
		end

		return true
	end

	local dialog = SelectUnitByNameModal:new("Select Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		self:_check_add_unit(unit)
	end
end

function NavObstacleElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "operation", {
		"add",
		"remove"
	}, "Choose if you want to add or remove an obstacle.")

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("SELECT_UNIT_LIST", "Select unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("SELECT_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "select_unit_list_btn"), nil)
	toolbar:realize()
	panel_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")

	for _, data in pairs(clone(self._hed.obstacle_list)) do
		local unit = self._obstacle_units[data.unit_id]

		if not alive(unit) then
			self:_remove_by_unit_id(data.unit_id)
		elseif not unit:get_object(data.obj_name) then
			debug_pause("[NavObstacleElement:_build_panel] object", data.object_name, "not found in unit", unit, ". element ID ", self._unit:unit_data().unit_id)
			self:_remove_by_unit_id(data.unit_id)
		else
			local all_object_names = self:_get_objects_by_unit(unit)

			self:_add_unit(unit, all_object_names, data)
		end
	end
end

function NavObstacleElement:_get_objects_by_unit(unit)
	local all_object_names = {}

	if unit then
		local root_obj = unit:orientation_object()
		all_object_names = {}
		local tree_depth = 1
		local _process_object_tree = nil

		function _process_object_tree(obj, depth)
			local indented_name = obj:name():s()

			for i = 1, depth do
				indented_name = "-" .. indented_name
			end

			table.insert(all_object_names, indented_name)

			local children = obj:children()

			for _, child in ipairs(children) do
				_process_object_tree(child, depth + 1)
			end
		end

		_process_object_tree(root_obj, 0)
	end

	return all_object_names
end

function NavObstacleElement._unindent_obj_name(obj_name)
	while string.sub(obj_name, 1, 1) == "-" do
		obj_name = string.sub(obj_name, 2)
	end

	return obj_name
end

function NavObstacleElement._get_indented_obj_name(obj, parent, obj_name)
	if parent then
		obj = parent:get_object(obj_name) or obj
	end

	local obj_name = (obj_name or obj:name()):s()

	while obj:parent() do
		obj = obj:parent()
		obj_name = "-" .. obj_name
	end

	return obj_name
end
