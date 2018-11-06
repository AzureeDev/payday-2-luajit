UnitBreakdownView = UnitBreakdownView or class(CoreEditorEwsDialog)

function UnitBreakdownView:init(...)
	CoreEditorEwsDialog.init(self, nil, "Unit Breakdown", "unit_breakdown", Vector3(300, 150, 0), Vector3(600, 800, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP", ...)
	self:create_panel("VERTICAL")

	local panel = self._panel
	local panel_sizer = self._panel_sizer
	local tree_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "Units:")
	self._tree = EWS:TreeCtrl(panel, "", "")

	self._tree:connect("", "EVT_COMMAND_TREE_SEL_CHANGED", callback(self, self, "on_tree_ctrl_change"), "")
	self._tree:connect("", "EVT_LEFT_DCLICK", callback(self, self, "on_tree_ctrl_select"), "")
	tree_sizer:add(self._tree, 1, 1, "EXPAND")
	panel_sizer:add(tree_sizer, 1, 1, "EXPAND")

	local buttons_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "Filter:")
	self._filter_text = EWS:TextCtrl(panel, "", "", "")

	self._filter_text:connect("", "EVT_COMMAND_TEXT_UPDATED", callback(self, self, "on_update_filter"), "")
	buttons_sizer:add(self._filter_text, 0, 0, "EXPAND")

	self._refresh_btn = EWS:Button(self._panel, "Refresh", "", "BU_EXACTFIT,NO_BORDER")

	self._refresh_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_refresh_clicked"), "")
	buttons_sizer:add(self._refresh_btn, 0, 0, "EXPAND")
	panel_sizer:add(buttons_sizer, 0, 0, "EXPAND")

	local buttons_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "Options:")
	self._unique_check = EWS:CheckBox(panel, "Unique Only", "")

	self._unique_check:set_value(true)
	self._unique_check:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "on_unique_checked"), "")
	buttons_sizer:add(self._unique_check, 0, 0, "EXPAND")

	self._export_btn = EWS:Button(self._panel, "Export Units to CSV", "", "BU_EXACTFIT,NO_BORDER")

	self._export_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_export_clicked"), "")
	buttons_sizer:add(self._export_btn, 0, 0, "EXPAND")

	self._close_btn = EWS:Button(self._panel, "Close", "", "BU_EXACTFIT,NO_BORDER")

	self._close_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_close_clicked"), "")
	buttons_sizer:add(self._close_btn, 0, 0, "EXPAND")
	panel_sizer:add(buttons_sizer, 0, 0, "EXPAND")
	self._dialog_sizer:add(self._panel, 1, 1, "EXPAND")
	self._dialog:set_visible(true)
	self:perform_update()
end

function UnitBreakdownView:set_visible(visible)
	self._dialog:set_visible(visible)

	if visible then
		self:perform_update()
	else
		managers.editor._dialogs.unit_breakdown = nil
	end
end

function UnitBreakdownView:get_unit_name(unit)
	return unit:unit_data().name_id
end

function UnitBreakdownView:get_unit_path(unit)
	return unit:name():s()
end

function UnitBreakdownView:perform_update(name_filter, unique, name_func)
	local filter = self._filter_text:get_value()
	local unique = self._unique_check:get_value()
	local func = unique and self.get_unit_path or self.get_unit_name

	self:_perform_update(filter, unique, func)
end

function UnitBreakdownView:_perform_update(name_filter, require_unique, name_func)
	name_filter = name_filter and (type(name_filter) == "string" or nil) and string.trim(name_filter)

	if require_unique == nil then
		require_unique = false
	end

	name_func = name_func or self.get_unit_name

	self._tree:clear()
	self:get_continents()

	self._layer_units = {}
	local expand_nodes = {}
	self._root_world = self._tree:append_root("World")

	table.insert(expand_nodes, self._root_world)

	self._root_continents = self._tree:append(self._root_world, "Continents")

	table.insert(expand_nodes, self._root_continents)

	for continent_idx, data in pairs(self._ordered_continents) do
		self._layer_units[data.name] = {}
		local continent_units = self._layer_units[data.name]
		local node_name = string.format("%s [%i]", data.name, #data.continent._units)
		local continent_id = self._tree:append(self._root_continents, node_name)

		table.insert(expand_nodes, continent_id)

		local unique_instances = {}

		for layer_name, layer in pairs(managers.editor:layers()) do
			if layer:uses_continents() and layer_name ~= "Instances" then
				local layer_node = self._tree:append(continent_id, layer_name)
				continent_units[layer_name] = {}

				for i, unit in pairs(layer:created_units()) do
					if unit:unit_data().continent == data.continent then
						if not unit:unit_data().instance then
							local unit_name = tostring(name_func(self, unit))

							if not name_filter or string.find(unit_name, name_filter) then
								local insert_to_layer = true

								if require_unique then
									for _, unit in pairs(continent_units[layer_name]) do
										if name_func(self, unit) == unit_name then
											insert_to_layer = false

											break
										end
									end
								end

								if insert_to_layer then
									table.insert(continent_units[layer_name], unit)
								end
							end
						elseif not table.contains(unique_instances, unit:unit_data().instance) and (not name_filter or string.find(unit:unit_data().instance, name_filter)) then
							table.insert(unique_instances, unit:unit_data().instance)
						end
					end
				end

				table.sort(continent_units[layer_name], function (a, b)
					return a:unit_data().unit_id < b:unit_data().unit_id
				end)

				for i, unit in ipairs(continent_units[layer_name]) do
					self._tree:append(layer_node, string.format("%s [%i]", name_func(self, unit), unit:unit_data().unit_id))
				end

				if #continent_units[layer_name] > 0 then
					self._tree:set_item_text(layer_node, string.format("%s [%i]", layer_name, #continent_units[layer_name]))
				end
			end
		end

		local name = string.format("Instances %s", #unique_instances > 0 and string.format("[%i]", #unique_instances) or "")
		local instances_id = self._tree:append(continent_id, name)

		for i, instance_name in ipairs(unique_instances) do
			self._tree:append(instances_id, instance_name)
		end
	end

	self._root_layers = self._tree:append(self._root_world, "Layers")

	table.insert(expand_nodes, self._root_layers)

	for layer_name, layer in pairs(managers.editor:layers()) do
		if not layer:uses_continents() then
			local layer_node = self._tree:append(self._root_layers, string.format("%s [%i]", layer_name, #layer:created_units()))

			for i, unit in pairs(layer:created_units()) do
				if not name_filter or string.find(name_func(self, unit), name_filter) then
					self._tree:append(layer_node, string.format("%s [%i]", name_func(self, unit), unit:unit_data().unit_id))
				end
			end
		end
	end

	for i, node in ipairs(expand_nodes) do
		self._tree:expand(node)
	end
end

function UnitBreakdownView:get_continents()
	local continents = managers.editor:continents()
	self._ordered_continents = {}

	for name, continent in pairs(continents) do
		table.insert(self._ordered_continents, {
			name = name,
			continent = continent
		})
	end

	table.sort(self._ordered_continents, function (a, b)
		return a.name < b.name
	end)
end

function UnitBreakdownView:on_tree_ctrl_change()
end

function UnitBreakdownView:on_tree_ctrl_select()
	local id = self._tree:selected_item()
	local layer = self:_get_layer(id)
	local continent = layer and self:_get_continent(id)

	if layer and continent then
		managers.editor:change_layer_name(layer)
		managers.editor:set_continent(continent)

		if layer == "Instances" then
			local instances_layer = managers.editor:layers()[layer]

			if instances_layer and instances_layer.select_instance then
				local name = self._tree:get_item_text(id)

				instances_layer:select_instance(name, true)
			end
		else
			local unique = self._unique_check:get_value()

			if unique then
				self:select_units_by_path(path)
			else
				self:select_unit_by_tree_id(id)
			end
		end
	end
end

function UnitBreakdownView:select_unit_by_tree_id(id)
	local text = self._tree:get_item_text(id)
	local unit_id = string.match(text, "%[(.*)%]")

	if unit_id then
		unit_id = tonumber(unit_id)

		if unit_id then
			managers.editor:select_unit_by_unit_id(unit_id)
		end
	end
end

function UnitBreakdownView:select_units_by_path(path)
end

function UnitBreakdownView:_get_layer(selected_item_id)
	if selected_item_id then
		local layer_id = self._tree:get_parent(selected_item_id)

		if layer_id and layer_id > 0 then
			local text = self._tree:get_item_text(layer_id)
			local layer_split = string.split(text, "%[")

			if layer_split and #layer_split > 0 then
				local layer_name = string.trim(layer_split[1])

				if managers.editor:layers()[layer_name] then
					return layer_name
				end
			end
		end
	end

	return nil
end

function UnitBreakdownView:_get_continent(selected_item_id)
	if selected_item_id then
		local layer_id = self._tree:get_parent(selected_item_id)

		if layer_id and layer_id > 0 then
			local continent_id = self._tree:get_parent(layer_id)

			if continent_id and continent_id > 0 then
				local text = self._tree:get_item_text(continent_id)
				local cont_split = string.split(text, "%[")

				if cont_split and #cont_split > 0 then
					local continent_name = string.trim(cont_split[1])

					if managers.editor:continents()[continent_name] then
						return continent_name
					end
				end
			end
		end
	end
end

function UnitBreakdownView:on_update_filter()
end

function UnitBreakdownView:on_refresh_clicked()
	self:perform_update()
end

function UnitBreakdownView:on_unique_checked()
	self:perform_update()
end

function UnitBreakdownView:on_close_clicked()
	self:set_visible(false)
end

function UnitBreakdownView:on_export_clicked()
	if not self._layer_units then
		Application:set_clipboard("[No Data]")

		return
	end

	local export_text = ""
	local sep_char = "\t"
	local unit_format = "%s,%s,%s,%s,%s,%s,%s"
	unit_format = string.gsub(unit_format, ",", sep_char)
	local export_layers = {
		"Statics"
	}
	local exclude_prefixes = {
		"units/dev_tools/",
		"core/units/light_omni"
	}

	for _, continent_table in pairs(self._layer_units) do
		for _, layer_name in ipairs(export_layers) do
			for idx, unit in pairs(continent_table[layer_name]) do
				local name = unit:name():s()
				local allow_export = true

				for _, prefix in ipairs(exclude_prefixes) do
					if string.sub(name, 1, #prefix) == prefix then
						allow_export = false

						break
					end
				end

				if allow_export then
					local split_name = string.split(name, "/")
					local unit_data = string.format(unit_format, "LEAVE AS IS", "0", "NONE", "", split_name and split_name[#split_name] or name, name, "")
					export_text = export_text .. (export_text ~= "" and "\n" or "") .. unit_data
				end
			end
		end
	end

	Application:set_clipboard(export_text)
end
