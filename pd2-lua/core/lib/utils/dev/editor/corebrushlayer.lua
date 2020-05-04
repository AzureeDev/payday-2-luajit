core:module("CoreBrushLayer")
core:import("CoreLayer")
core:import("CoreUnit")
core:import("CoreEngineAccess")
core:import("CoreEws")
core:import("CoreTable")
core:import("CoreEditorUtils")

BrushLayer = BrushLayer or class(CoreLayer.Layer)

function BrushLayer:init(owner, dont_load_unit_map)
	BrushLayer.super.init(self, owner, "brush")

	self._brush_names = {}
	self._brush_types = {}
	self._brush_size = 15
	self._brush_density = 3
	self._brush_pressure = 1
	self._random_roll = 0
	self._spraying = false
	self._erasing = false
	self._brush_height = 40
	self._angle_override = 0
	self._offset = 0
	self._visible = true
	self._erase_with_pressure = false
	self._erase_with_units = false
	self._overide_surface_normal = false
	self._brush_on_editor_bodies = false

	self:load_unit_map_from_vector(CoreEditorUtils.layer_type("brush"))

	self._place_slot_mask = managers.slot:get_mask("brush_placeable")
	self._brush_slot_mask = managers.slot:get_mask("brushes")
	self._unit_brushes = {}
	self._brushed_path = "core/temp/editor_temp/brushes"

	self:load_brushes()
end

function BrushLayer:load(world_holder, offset)
	world_holder:create_world("world", self._save_name, offset)

	self._amount_dirty = true
end

function BrushLayer:save(save_params)
	local file_name = "massunit"
	local t = {
		single_data_block = true,
		entry = self._save_name,
		data = {
			file = file_name
		}
	}

	self:_add_project_save_data(t.data)
	managers.editor:add_save_data(t)
	self:_save_brushfile(save_params.dir .. "\\" .. file_name .. ".massunit")
end

function BrushLayer:_save_brushfile(path)
	MassUnitManager:save(path)
	managers.editor:add_to_world_package({
		category = "massunits",
		name = managers.database:entry_path(path:s())
	})

	for _, unit_name in ipairs(MassUnitManager:list()) do
		managers.editor:add_to_world_package({
			category = "units",
			name = unit_name:s()
		})
	end
end

function BrushLayer:reposition_all()
	managers.editor:output("Reposition all brushes:")

	for name, unit in pairs(self._unit_map) do
		name = self:get_real_name(name)
		local unit = safe_spawn_unit(name, Vector3(0, 0, 20000), Rotation(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)))

		if unit then
			local dynamic_unit = false
			local index = 0

			while index < unit:num_bodies() and not dynamic_unit do
				if unit:body_by_index(index):dynamic() then
					dynamic_unit = true
				end

				index = index + 1
			end

			World:delete_unit(unit)

			if dynamic_unit then
				managers.editor:output(" * Skipped unit type " .. name .. " it seems to be dynamic")
			else
				local nudged_units = 0
				local positions = MassUnitManager:unit_positions(name)

				if #positions > 0 then
					local rotations = MassUnitManager:unit_rotations(name)

					MassUnitManager:delete_units(name)

					for counter = 1, #positions do
						local rot = rotations[counter]
						local pos = positions[counter]
						local from = pos + rot:z() * 50
						local to = pos - rot:z() * 110
						local ray_type = self._brush_on_editor_bodies and "body editor" or "body"
						local ray = managers.editor:select_unit_by_raycast(self._place_slot_mask, ray_type, from, to)

						if ray then
							local brush_header = self:add_brush_header(name)
							local correct_pos = brush_header:spawn_brush(ray.position, rotations[counter])
							self._amount_dirty = true
							local nudge_length = (ray.position - correct_pos):length()

							if nudge_length > 0.05 then
								nudged_units = nudged_units + 1
							end
						else
							Application:error(" * Lost one of type", name, "- it was too alone at:", pos)
							managers.editor:output(" * Lost one of type " .. name .. " - it was too alone at: " .. pos)
						end
					end
				end

				if nudged_units > 0 then
					managers.editor:output(" * Nudged " .. nudged_units .. " units of type " .. name)
				end
			end
		end
	end
end

function BrushLayer:reload()
	for name, unit in pairs(self._unit_map) do
		name = self:get_real_name(name)
	end
end

function BrushLayer:clear_all()
	local confirm = EWS:message_box(Global.frame_panel, "This will delete all brushes in this level, are you sure?", "Brush", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	MassUnitManager:delete_all_units()

	self._amount_dirty = true
end

function BrushLayer:clear_unit()
	local confirm = EWS:message_box(Global.frame_panel, "This will delete all selected brushes in this level, are you sure?", "Brush", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	for _, name in ipairs(self._brush_names) do
		MassUnitManager:delete_units(Idstring(name))
	end

	self._amount_more_dirty = true
end

function BrushLayer:clear_units_by_name(name)
	local confirm = EWS:message_box(Global.frame_panel, "This will delete all " .. name .. " brushes in this level, are you sure?", "Brush", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	MassUnitManager:delete_units(Idstring(name))

	self._amount_more_dirty = true
end

function BrushLayer:_on_amount_updated()
	local brush_stats, total = self:get_brush_stats()

	self._debug_units_total:set_label("Units Total: " .. total.amount)
	self._debug_units_unique:set_label("Units Unique: " .. total.unique)

	if self._debug_list and self._debug_list:visible() then
		self._debug_list:fill_unit_list()
	end
end

function BrushLayer:set_visibility(cb)
	self._visible = cb:get_value()

	MassUnitManager:set_visibility(self._visible)
end

function BrushLayer:select()
end

function BrushLayer:spray_units()
	if not self._visible then
		return
	end

	self:erase_units_release()

	self._spraying = true
end

function BrushLayer:spray_units_release()
	if self._spraying then
		self._spraying = false
	end
end

function BrushLayer:erase_units()
	if not self._visible then
		return
	end

	self:spray_units_release()

	self._erasing = true
end

function BrushLayer:erase_units_release()
	if self._erasing then
		self._erasing = false
	end
end

function BrushLayer:update(time, rel_time)
	if self._amount_dirty then
		self._amount_dirty = nil

		self:_on_amount_updated()
	end

	if self._amount_more_dirty then
		self._amount_more_dirty = nil
		self._amount_dirty = true
	end

	local from = self._owner:get_cursor_look_point(0)
	local to = self._owner:get_cursor_look_point(5000)
	local ray_type = self._brush_on_editor_bodies and "body editor" or "body"
	local ray = managers.editor:select_unit_by_raycast(self._place_slot_mask, ray_type)
	local base, tip = nil

	if ray then
		Application:draw_circle(ray.position + ray.normal * 0.1, self._brush_size, 0, 0.7, 0, ray.normal)
		Application:draw_circle(ray.position + ray.normal * 0.1 + ray.normal * self._offset, self._brush_size, 0, 1, 0, ray.normal)

		base = ray.position - ray.normal * 40 - ray.normal * self._offset
		tip = ray.position + ray.normal * self._brush_height + ray.normal * self._offset

		Application:draw_circle(tip, self._brush_size, 0, 0.7, 0, ray.normal)
	else
		local ray_normal = (to - from):normalized()
		base = from + ray_normal * 1000
		tip = from + ray_normal * 10000
		local tunnel = 9000

		while tunnel > 0 do
			Application:draw_circle(base + ray_normal * tunnel, self._brush_size, 0.3 + 0.7 * tunnel / 9000, 0, 0, ray_normal)

			tunnel = tunnel * 0.9 - 100
		end

		Application:draw_circle(base, self._brush_size, 0.3, 0.2, 0.2, ray_normal)
	end

	if self._spraying and ray or self._erasing then
		local units = World:find_units_quick("cylinder", base, tip, self._brush_size, self._brush_slot_mask)
		local area = 3.1416 * math.pow(self._brush_size / 100, 2)
		local density = #units / area

		if self._spraying then
			local created = 0

			while created < self._brush_pressure and density <= self._brush_density do
				local nudge_amount = 1 - math.rand(self._brush_size * self._brush_size) / (self._brush_size * self._brush_size)
				local rand_nudge = ray.normal:random_orthogonal() * self._brush_size * nudge_amount
				local place_ray = managers.editor:select_unit_by_raycast(self._place_slot_mask, ray_type, tip + rand_nudge, base + rand_nudge)

				self:create_brush(place_ray)

				created = created + 1
				density = (#units + created) / area
			end

			if self._brush_density == 0 then
				self:spray_units_release()
			end
		elseif self._erasing then
			if self._erase_with_pressure and ray then
				local removed = 0

				while removed < self._brush_pressure and removed < #units do
					removed = removed + 1
					local found = true

					if self._erase_with_units then
						found = false

						while not found and removed <= #units do
							if table.contains(self._brush_names, units[removed]:name():s()) then
								found = true
							else
								removed = removed + 1
							end
						end
					end

					if found then
						World:delete_unit(units[removed])

						self._amount_dirty = true
					end
				end

				if self._brush_density == 0 then
					self:erase_units_release()
				end
			else
				for _, brush in ipairs(units) do
					if not self._erase_with_units or self._erase_with_units and table.contains(self._brush_names, brush:name():s()) then
						World:delete_unit(brush)

						self._amount_dirty = true
					end
				end
			end
		end
	end

	if self._debug_draw_unit_orientation then
		self:_draw_unit_orientations()
	end
end

function BrushLayer:_draw_unit_orientations()
	local brush_stats = self:get_brush_stats()

	for _, stats in ipairs(brush_stats) do
		for i = 1, stats.amount do
			Application:draw_rotation(stats.positions[i], stats.rotations[i])
		end
	end
end

function BrushLayer:add_brush_header(name)
	if not self._brush_types[name] then
		local header = BrushHeader:new()

		header:set_name(name)

		self._brush_types[name] = header

		return header
	else
		return self._brush_types[name]
	end
end

function BrushLayer:create_brush(ray)
	if #self._brush_names > 0 and ray then
		local name = self._brush_names[math.floor(1 + math.rand(#self._brush_names))]

		self:add_brush_header(name)

		local brush_type = self._brush_types[name]
		local at = Vector3(0, 0, 1)
		local up = self._overide_surface_normal and Vector3(0, 0, 1) or ray.normal
		local rand_rotator = Rotation(up, math.rand(self._random_roll) - self._random_roll / 2)

		if self._angle_override ~= 0 then
			rand_rotator = Rotation(up, self._angle_override)
		end

		local right = nil

		if math.abs(up.z) > 0.7 then
			local camera_rot = self._owner._vp:camera():rotation()

			if camera_rot:z():dot(up) < 0.7 then
				right = camera_rot:z():cross(up):rotate_with(rand_rotator)
				at = up:cross(right)
			else
				at = up:cross(camera_rot:x()):rotate_with(rand_rotator)
				right = at:cross(up)
			end
		else
			right = at:cross(up):rotate_with(rand_rotator)
			at = up:cross(right)
		end

		brush_type:spawn_brush(ray.position + up * self._offset, Rotation(right, at, up))

		self._amount_dirty = true
	end
end

function BrushLayer:build_panel(notebook)
	cat_print("editor", "BrushLayer:build_panel")

	self._ews_panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	self._main_sizer = EWS:BoxSizer("HORIZONTAL")

	self._ews_panel:set_sizer(self._main_sizer)

	self._sizer = EWS:BoxSizer("VERTICAL")
	local ctrl_sizer = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL")

	ctrl_sizer:add(self:create_slider("Random Roll [deg]", "_random_roll", 0, 360), 0, 0, "EXPAND")
	ctrl_sizer:add(self:create_slider("Radius [cm]", "_brush_size", 1, 1000), 0, 0, "EXPAND")
	ctrl_sizer:add(self:create_slider("Density [/m2]", "_brush_density", 0, 30), 0, 0, "EXPAND")
	ctrl_sizer:add(self:create_slider("Pressure", "_brush_pressure", 1, 20), 0, 0, "EXPAND")
	ctrl_sizer:add(self:create_slider("Height [cm]", "_brush_height", 10, 1000), 0, 0, "EXPAND")
	ctrl_sizer:add(self:create_slider("Angle [deg]", "_angle_override", 0, 360), 0, 0, "EXPAND")
	ctrl_sizer:add(self:create_slider("Offset [cm]", "_offset", -30, 1000, 0), 0, 0, "EXPAND")

	local pressure_cb = EWS:CheckBox(self._ews_panel, "Use Pressure when Erasing", "")

	pressure_cb:set_value(self._erase_with_pressure)
	ctrl_sizer:add(pressure_cb, 0, 5, "SHAPED,TOP")
	pressure_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_erase_with_pressure",
		cb = pressure_cb
	})

	local erase_cb = EWS:CheckBox(self._ews_panel, "Erase with selected units", "")

	erase_cb:set_value(self._erase_with_units)
	ctrl_sizer:add(erase_cb, 0, 0, "SHAPED")
	erase_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_erase_with_units",
		cb = erase_cb
	})

	local force_up_cb = EWS:CheckBox(self._ews_panel, "Override surface normal rotation", "")

	force_up_cb:set_value(self._overide_surface_normal)
	ctrl_sizer:add(force_up_cb, 0, 0, "SHAPED")
	force_up_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_overide_surface_normal",
		cb = force_up_cb
	})

	local brush_on_editor_bodies_cb = EWS:CheckBox(self._ews_panel, "Brush on editor bodies", "")

	brush_on_editor_bodies_cb:set_value(self._brush_on_editor_bodies)
	ctrl_sizer:add(brush_on_editor_bodies_cb, 0, 0, "SHAPED")
	brush_on_editor_bodies_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_brush_on_editor_bodies",
		cb = brush_on_editor_bodies_cb
	})
	self._sizer:add(ctrl_sizer, 0, 0, "EXPAND")

	local btn_sizer = EWS:StaticBoxSizer(self._ews_panel, "HORIZONTAL", "")
	local reposition_btn = EWS:Button(self._ews_panel, "Reposition All", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(reposition_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	reposition_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "reposition_all"), nil)

	local reload_btn = EWS:Button(self._ews_panel, "Reload", "", "BU_EXACTFIT,NO_BORDER")

	reload_btn:set_enabled(false)
	reload_btn:set_tool_tip("Need engine support to implement fully")
	btn_sizer:add(reload_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	reload_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "reload"), nil)

	local clear_unit_btn = EWS:Button(self._ews_panel, "Clear Unit", "", "BU_EXACTFIT,NO_BORDER")

	clear_unit_btn:set_enabled(true)
	clear_unit_btn:set_tool_tip("This will clear all brushes")
	btn_sizer:add(clear_unit_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	clear_unit_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "clear_unit"), nil)

	local clear_all_btn = EWS:Button(self._ews_panel, "Clear All", "", "BU_EXACTFIT,NO_BORDER")

	clear_all_btn:set_enabled(true)
	clear_all_btn:set_tool_tip("This will clear all brushes")
	btn_sizer:add(clear_all_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	clear_all_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "clear_all"), nil)

	local visible_cb = EWS:CheckBox(self._ews_panel, "Visible", "", "ALIGN_RIGHT")

	visible_cb:set_value(self._visible)
	btn_sizer:add(visible_cb, 1, 10, "ALIGN_CENTER_VERTICAL,RIGHT")
	visible_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_visibility"), visible_cb)
	self._sizer:add(btn_sizer, 0, 0, "EXPAND")

	local debug_sizer = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL", "Debug")

	self._sizer:add(debug_sizer, 0, 0, "EXPAND")

	local toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_NODIVIDER")

	debug_sizer:add(toolbar, 1, 1, "EXPAND,BOTTOM")
	toolbar:add_check_tool("DEBUG_DRAW", "Draw unit orientations", CoreEws.image_path("image_16x16.png"), "Draw unit orientations")
	toolbar:set_tool_state("DEBUG_DRAW", self._debug_draw_unit_orientation)
	toolbar:connect("DEBUG_DRAW", "EVT_COMMAND_MENU_SELECTED", callback(nil, CoreEditorUtils, "toolbar_toggle"), {
		value = "_debug_draw_unit_orientation",
		class = self,
		toolbar = toolbar
	})
	toolbar:add_tool("DEBUG_LIST", "Open debug list", CoreEws.image_path("magnifying_glass_16x16.png"), "Open debug list")
	toolbar:connect("DEBUG_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_open_debug_list"), nil)
	toolbar:realize()

	self._debug_units_total = EWS:StaticText(self._ews_panel, "Units Total:", "", "ALIGN_LEFT")
	self._debug_units_unique = EWS:StaticText(self._ews_panel, "Units Unique:", "", "ALIGN_LEFT")

	debug_sizer:add(self._debug_units_total, 0, 0, "EXPAND")
	debug_sizer:add(self._debug_units_unique, 0, 0, "EXPAND")

	local units_params = {
		style = "LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING",
		unit_events = {
			"EVT_COMMAND_LIST_ITEM_DESELECTED"
		}
	}

	self._sizer:add(self:build_units(units_params), 1, 0, "EXPAND")

	local btn_sizer = EWS:BoxSizer("HORIZONTAL")
	local create_brush_btn = EWS:Button(self._ews_panel, "Create Brush", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(create_brush_btn, 0, 5, "RIGHT")

	local remove_brush_btn = EWS:Button(self._ews_panel, "Remove Brush", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(remove_brush_btn, 0, 5, "RIGHT")
	self._sizer:add(btn_sizer, 0, 0, "EXPAND")

	local brushes_sizer = EWS:StaticBoxSizer(self._ews_panel, "HORIZONTAL", "Brushes")
	local brushes = EWS:ListBox(self._ews_panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	for name, _ in pairs(self._unit_brushes) do
		brushes:append(name)
	end

	brushes_sizer:add(brushes, 1, 0, "EXPAND")
	self._sizer:add(brushes_sizer, 1, 0, "EXPAND")
	self._main_sizer:add(self._sizer, 2, 2, "LEFT,RIGHT,EXPAND")

	self._brushes_ctrlr = brushes

	brushes:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "select_brush"), {
		brushes = brushes
	})
	create_brush_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "show_create_brush"), {
		brushes = brushes
	})
	remove_brush_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "remove_brush"), brushes)

	return self._ews_panel
end

function BrushLayer:show_create_brush(data)
	if #self._brush_names > 0 then
		local name = EWS:get_text_from_user(Global.frame_panel, "Enter name for the new brush configuration:", "Create brush", "new_brush", Vector3(-1, -1, 0), true)

		if name and name ~= "" then
			if self._unit_brushes[name] then
				self:show_create_brush(data)
			else
				self._unit_brushes[name] = CoreTable.clone(self._brush_names)

				data.brushes:append(name)
				self:save_brushes()

				for i = 0, data.brushes:nr_items() - 1 do
					if data.brushes:get_string(i) == name then
						data.brushes:select_index(i)

						break
					end
				end

				self:select_brush(data)
			end
		end
	end
end

function BrushLayer:hide_create_brush(data)
	data.dialog:end_modal()

	self._cancel_dialog = data.cancel
end

function BrushLayer:remove_brush(brushes)
	local i = brushes:selected_index()

	if i >= 0 then
		self._unit_brushes[brushes:get_string(i)] = nil

		brushes:remove(i)
		self:save_brushes()

		self._brush_names = {}
	end
end

function BrushLayer:save_brushes()
	local f = SystemFS:open(managers.database:base_path() .. self._brushed_path .. ".xml", "w")

	f:puts("<brushes>")

	for name, unit_names in pairs(self._unit_brushes) do
		f:puts("\t<brush name=\"" .. name .. "\">")

		for _, unit_name in ipairs(unit_names) do
			f:puts("\t\t<unit name=\"" .. unit_name .. "\"/>")
		end

		f:puts("\t</brush>")
	end

	f:puts("</brushes>")
	f:close()
	managers.database:recompile(self._brushed_path)
end

function BrushLayer:load_brushes()
	if DB:has("xml", self._brushed_path) then
		local node = DB:load_node("xml", self._brushed_path)

		for brush in node:children() do
			local name = brush:parameter("name")
			local unit_names = {}

			for unit in brush:children() do
				table.insert(unit_names, unit:parameter("name"))
			end

			self._unit_brushes[name] = unit_names
		end
	end
end

function BrushLayer:create_slider(name, value, s_value, e_value, default_value)
	local slider_sizer = EWS:BoxSizer("VERTICAL")

	slider_sizer:add(EWS:StaticText(self._ews_panel, name, "", "ALIGN_LEFT"), 0, 0, "EXPAND")

	local slider_params = {
		floats = 0,
		slider_ctrlr_proportions = 3,
		number_ctrlr_proportions = 1,
		panel = self._ews_panel,
		sizer = slider_sizer,
		value = default_value or s_value,
		min = s_value,
		max = e_value
	}

	CoreEws.slider_and_number_controller(slider_params)
	slider_params.slider_ctrlr:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_slider"), {
		slider_params = slider_params,
		value = value
	})
	slider_params.slider_ctrlr:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_slider"), {
		slider_params = slider_params,
		value = value
	})
	slider_params.number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_slider"), {
		slider_params = slider_params,
		value = value
	})
	slider_params.number_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "update_slider"), {
		slider_params = slider_params,
		value = value
	})

	return slider_sizer
end

function BrushLayer:set_unit_name(units)
	self._brush_names = {}
	local selected = units:selected_items()

	for _, i in ipairs(selected) do
		local name = self:get_real_name(units:get_item_data(i))

		table.insert(self._brush_names, name)
	end

	local i = self._brushes_ctrlr:selected_index()

	if i > -1 then
		self._brushes_ctrlr:deselect_index(i)
	end
end

function BrushLayer:select_brush(data)
	self._brush_names = {}
	local i = data.brushes:selected_index()

	if i < 0 then
		return
	end

	for _, name in ipairs(self._unit_brushes[data.brushes:get_string(i)]) do
		table.insert(self._brush_names, name)
	end
end

function BrushLayer:update_slider(data)
	self[data.value] = data.slider_params.value
end

function BrushLayer:_on_gui_open_debug_list()
	self._debug_list = _G.BrushLayerDebug:new()
end

function BrushLayer:get_brush_stats()
	local brush_stats = {}
	local total = {
		unique = 0,
		amount = 0
	}

	for _, unit_name in ipairs(MassUnitManager:list()) do
		local rotations = MassUnitManager:unit_rotations(unit_name)
		local positions = MassUnitManager:unit_positions(unit_name)
		local stats = {
			unit_name = unit_name,
			amount = #rotations,
			positions = positions,
			rotations = rotations
		}

		table.insert(brush_stats, stats)

		total.amount = total.amount + #rotations
		total.unique = total.unique + 1
	end

	return brush_stats, total
end

function BrushLayer:activate(...)
	BrushLayer.super.activate(self, ...)

	if self._debug_list then
		self._debug_list:set_visible(self._was_debug_list_visible)

		self._was_debug_list_visible = nil
	end
end

function BrushLayer:deactivate(...)
	BrushLayer.super.deactivate(self, ...)

	if self._debug_list then
		self._was_debug_list_visible = self._debug_list:visible()

		self._debug_list:set_visible(false)
	end
end

function BrushLayer:clear()
	MassUnitManager:delete_all_units()

	self._amount_dirty = true
end

function BrushLayer:add_triggers()
	local vc = self._editor_data.virtual_controller

	vc:add_trigger(Idstring("lmb"), callback(self, self, "spray_units"))
	vc:add_release_trigger(Idstring("lmb"), callback(self, self, "spray_units_release"))
	vc:add_trigger(Idstring("rmb"), callback(self, self, "erase_units"))
	vc:add_release_trigger(Idstring("rmb"), callback(self, self, "erase_units_release"))
end

function BrushLayer:get_help(text)
	local t = "\t"
	local n = "\n"
	text = text .. "Spawn brush:   Point and hold down left mouse button" .. n
	text = text .. "Remove brush:  Point and hold down right mouse button" .. n

	return text
end

function BrushLayer:get_layer_name()
	return "Props brush"
end

BrushHeader = BrushHeader or class()

function BrushHeader:init()
	self._name = ""
	self._distance = 0
end

function BrushHeader:set_name(name)
	self._name = name

	if self._name then
		CoreUnit.editor_load_unit(self._name)
	end

	self:setup_brush_distance()
end

function BrushHeader:setup_brush_distance()
	if self._name then
		local node = CoreEngineAccess._editor_unit_data(self._name:id()):script_data()

		if node then
			for data in node:children() do
				if data:name() == "brush" then
					self._distance = tonumber(data:parameter("distance"))
				end
			end
		end
	end
end

function BrushHeader:get_spawn_dist()
	return self._distance
end

function BrushHeader:spawn_brush(position, rotation)
	position = position + rotation:z() * self:get_spawn_dist()

	MassUnitManager:spawn_unit(Idstring(self._name), position, rotation)

	return position
end
