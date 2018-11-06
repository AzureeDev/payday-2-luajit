core:import("CoreEditorUtils")

CoreEditorGroups = CoreEditorGroups or class()

function CoreEditorGroups:init()
	self._groups = {}
	self._group_names = {}
end

function CoreEditorGroups:groups()
	return self._groups
end

function CoreEditorGroups:group_names()
	return self._group_names
end

function CoreEditorGroups:update(t, dt)
	for _, group in pairs(self._groups) do
		group:draw(t, dt)
	end
end

function CoreEditorGroups:create(name, reference, units)
	if not table.contains(self._group_names, name) then
		table.insert(self._group_names, name)
	end

	local group = CoreEditorGroup:new(name, reference, units)
	self._groups[name] = group

	return group
end

function CoreEditorGroups:add(name, units)
	local group = self._groups[name]

	group:add(units)
end

function CoreEditorGroups:remove(name)
	table.delete(self._group_names, name)
	self._groups[name]:remove()

	self._groups[name] = nil
end

function CoreEditorGroups:clear()
end

function CoreEditorGroups:group_name()
	local name = EWS:get_text_from_user(Global.frame_panel, "Enter name for the new group:", "Create Group", self:new_group_name(), Vector3(-1, -1, 0), true)

	if name and name ~= "" then
		if self._groups[name] then
			self:group_name()
		else
			return name
		end
	end

	return nil
end

function CoreEditorGroups:new_group_name()
	local s = "Group0"
	local i = 1

	while self._groups[s .. i] do
		i = i + 1

		if i > 9 then
			s = "Group"
		end
	end

	return s .. i
end

function CoreEditorGroups:save()
	for _, name in ipairs(self._group_names) do
		local group = self._groups[name]

		if group then
			local units = {}

			for _, unit in ipairs(group:units()) do
				table.insert(units, unit:unit_data().unit_id)
			end

			local t = {
				entry = "editor_groups",
				continent = group:continent() and group:continent_name(),
				data = {
					name = group:name(),
					reference = group:reference():unit_data().unit_id,
					continent = group:continent() and group:continent_name(),
					units = units
				}
			}

			managers.editor:add_save_data(t)
		end
	end
end

function CoreEditorGroups:load(world_holder, offset)
	local load_data = world_holder:create_world("world", "editor_groups", offset)
	local group_names = load_data.group_names
	local groups = {}

	for name, data in pairs(load_data.groups) do
		if #data.units > 0 then
			local reference = managers.worlddefinition:get_unit(data.reference)
			local units = {}

			for _, unit in ipairs(data.units) do
				table.insert(units, managers.worlddefinition:get_unit(unit))
			end

			local continent = nil

			if data.continent then
				continent = managers.editor:continent(data.continent)
			end

			if not table.contains(units, reference) then
				reference = units[1]

				cat_error("editor", "Changed reference for group,", name, ".")
			end

			groups[name] = {
				reference = reference,
				units = units,
				continent = continent
			}
		else
			table.delete(group_names, name)
			cat_error("editor", "Removed old group", name, "since it didnt contain any units.")
		end
	end

	for _, name in ipairs(group_names) do
		if not groups[name].reference then
			managers.editor:output_error("Reference unit is nil since there are no units left in group. Will remove, " .. name .. ".")
		else
			local group = self:create(name, groups[name].reference, groups[name].units)

			group:set_continent(groups[name].continent)
		end
	end
end

function CoreEditorGroups:load_group()
	local path = managers.database:open_file_dialog(Global.frame, "XML-file (*.xml)|*.xml")

	if path then
		self:load_group_file(path)
	end
end

function CoreEditorGroups:load_group_file(path)
	local name = self:group_name()

	if not name then
		return
	end

	local node = SystemFS:parse_xml(path)
	local layer_name = "Statics"

	if node:has_parameter("layer") then
		layer_name = node:parameter("layer")
	end

	local layer = managers.editor:layer(layer_name)
	local pos = managers.editor:current_layer():current_pos()

	managers.editor:change_layer_notebook(layer_name)

	local reference = nil
	local units = {}

	if pos then
		for unit in node:children() do
			local rot, new_unit = nil

			if unit:name() == "ref_unit" then
				reference = layer:do_spawn_unit(unit:parameter("name"), pos)
				new_unit = reference
			else
				local pos = pos + math.string_to_vector(unit:parameter("local_pos"))
				local rot = math.string_to_rotation(unit:parameter("local_rot"))
				new_unit = layer:do_spawn_unit(unit:parameter("name"), pos, rot)
			end

			for setting in unit:children() do
				if setting:name() == "light" then
					self:parse_light(new_unit, setting)
				elseif setting:name() == "variation" then
					self:parse_variation(new_unit, setting)
				elseif setting:name() == "material_variation" then
					self:parse_material_variation(new_unit, setting)
				elseif setting:name() == "editable_gui" then
					self:parse_editable_gui(new_unit, setting)
				end
			end

			table.insert(units, new_unit)
		end

		self:create(name, reference, units)
		layer:select_group(self._groups[name])
	end
end

function CoreEditorGroups:parse_light(unit, node)
	local light = unit:get_object(Idstring(node:parameter("name")))

	if not light then
		return
	end

	light:set_enable(toboolean(node:parameter("enabled")))
	light:set_far_range(tonumber(node:parameter("far_range")))
	light:set_color(math.string_to_vector(node:parameter("color")))
	light:set_spot_angle_start(tonumber(node:parameter("angle_start")))
	light:set_spot_angle_end(tonumber(node:parameter("angle_end")))
	light:set_multiplier(LightIntensityDB:lookup(Idstring(node:parameter("multiplier"))))

	if node:has_parameter("falloff_exponent") then
		light:set_falloff_exponent(tonumber(node:parameter("falloff_exponent")))
	end
end

function CoreEditorGroups:parse_variation(unit, node)
	local variation = node:parameter("value")

	if variation ~= "default" then
		unit:unit_data().mesh_variation = variation

		managers.sequence:run_sequence_simple2(unit:unit_data().mesh_variation, "change_state", unit)
	end
end

function CoreEditorGroups:parse_material_variation(unit, node)
	local material_variation = node:parameter("value")

	if material_variation ~= "default" then
		unit:unit_data().material = material_variation

		unit:set_material_config(unit:unit_data().material, true)
	end
end

function CoreEditorGroups:parse_editable_gui(unit, node)
	unit:editable_gui():set_text(node:parameter("text"))
	unit:editable_gui():set_font_color(math.string_to_vector(node:parameter("font_color")))
	unit:editable_gui():set_font_size(tonumber(node:parameter("font_size")))
	unit:editable_gui():set_font(node:parameter("font"))
	unit:editable_gui():set_align(node:parameter("align"))
	unit:editable_gui():set_vertical(node:parameter("vertical"))
	unit:editable_gui():set_blend_mode(node:parameter("blend_mode"))
	unit:editable_gui():set_render_template(node:parameter("render_template"))
	unit:editable_gui():set_wrap(node:parameter("wrap") == "true")
	unit:editable_gui():set_word_wrap(node:parameter("word_wrap") == "true")
	unit:editable_gui():set_alpha(tonumber(node:parameter("alpha")))
	unit:editable_gui():set_shape(string.split(node:parameter("shape"), " "))
end

CoreEditorGroup = CoreEditorGroup or class()

function CoreEditorGroup:init(name, reference, units)
	self._name = name
	self._reference = reference
	self._units = {}
	self._continent = managers.editor:current_continent()

	for _, unit in ipairs(units) do
		self:add_unit(unit)
	end

	self._closed = true
end

function CoreEditorGroup:closed()
	return self._closed
end

function CoreEditorGroup:set_closed(closed)
	self._closed = closed
end

function CoreEditorGroup:name()
	return self._name
end

function CoreEditorGroup:units()
	return self._units
end

function CoreEditorGroup:continent()
	return self._continent
end

function CoreEditorGroup:set_continent(continent)
	self._continent = continent
end

function CoreEditorGroup:continent_name()
	return tostring(self._continent and self._continent:name())
end

function CoreEditorGroup:add(units)
end

function CoreEditorGroup:add_unit(unit)
	if not unit then
		return
	end

	table.insert(self._units, unit)

	unit:unit_data().editor_groups = unit:unit_data().editor_groups or {}

	table.insert(unit:unit_data().editor_groups, self)
end

function CoreEditorGroup:remove_unit(unit)
	table.delete(self._units, unit)
	table.delete(unit:unit_data().editor_groups, self)

	if unit == self._reference then
		if #self._units > 0 then
			self._reference = self._units[1]
		else
			managers.editor:remove_group(self._name)
		end
	end
end

function CoreEditorGroup:remove()
	for _, unit in ipairs(self._units) do
		table.delete(unit:unit_data().editor_groups, self)
	end
end

function CoreEditorGroup:reference()
	return self._reference
end

function CoreEditorGroup:set_reference(reference)
	self._reference = reference
end

function CoreEditorGroup:save_to_file()
	local path = managers.database:save_file_dialog(Global.frame, true, "XML-file (*.xml)|*.xml", self:name())

	if path then
		local f = SystemFS:open(path, "w")

		f:puts("<group name=\"" .. self:name() .. "\" layer=\"" .. managers.editor:current_layer_name() .. "\">")
		f:puts("\t<ref_unit name=\"" .. self._reference:name():s() .. "\">")
		self:save_edited_settings(f, "\t\t", self._reference)
		f:puts("\t</ref_unit>")

		for _, unit in ipairs(self._units) do
			if unit ~= self._reference then
				local name = unit:name():s()
				local local_pos = unit:unit_data().local_pos
				local local_rot = unit:unit_data().local_rot
				local x = string.format("%.4f", local_pos.x)
				local y = string.format("%.4f", local_pos.y)
				local z = string.format("%.4f", local_pos.z)
				local_pos = "" .. x .. " " .. y .. " " .. z
				local yaw = string.format("%.4f", local_rot:yaw())
				local pitch = string.format("%.4f", local_rot:pitch())
				local roll = string.format("%.4f", local_rot:roll())
				local_rot = "" .. yaw .. " " .. pitch .. " " .. roll

				f:puts("\t<unit name=\"" .. name .. "\" local_pos=\"" .. local_pos .. "\" local_rot=\"" .. local_rot .. "\">")
				self:save_edited_settings(f, "\t\t", unit)
				f:puts("\t</unit>")
			end
		end

		f:puts("</group>")
		SystemFS:close(f)
	end
end

function CoreEditorGroup:save_edited_settings(...)
	self:save_lights(...)
	self:save_variation(...)
	self:save_editable_gui(...)
end

function CoreEditorGroup:save_lights(file, t, unit, data_table)
	local lights = CoreEditorUtils.get_editable_lights(unit) or {}

	for _, light in ipairs(lights) do
		local c_s = "" .. light:color().x .. " " .. light:color().y .. " " .. light:color().z
		local as = light:spot_angle_start()
		local ae = light:spot_angle_end()
		local multiplier = CoreEditorUtils.get_intensity_preset(light:multiplier()):s()
		local falloff_exponent = light:falloff_exponent()

		file:puts(t .. "<light name=\"" .. light:name():s() .. "\" enabled=\"" .. tostring(light:enable()) .. "\" far_range=\"" .. light:far_range() .. "\" color=\"" .. c_s .. "\" angle_start=\"" .. as .. "\" angle_end=\"" .. ae .. "\" multiplier=\"" .. multiplier .. "\" falloff_exponent=\"" .. falloff_exponent .. "\"/>")
	end
end

function CoreEditorGroup:save_variation(file, t, unit, data_table)
	if unit:unit_data().mesh_variation and #managers.sequence:get_editable_state_sequence_list(unit:name()) > 0 then
		file:puts(t .. "<variation value=\"" .. unit:unit_data().mesh_variation .. "\"/>")
	end

	if unit:unit_data().material and unit:unit_data().material ~= "default" then
		file:puts(t .. "<material_variation value=\"" .. unit:unit_data().material .. "\"/>")
	end
end

function CoreEditorGroup:save_editable_gui(file, t, unit, data_table)
	if unit:editable_gui() then
		local text = unit:editable_gui():text()
		local font_color = unit:editable_gui():font_color()
		local font_size = unit:editable_gui():font_size()
		local font = unit:editable_gui():font()
		local align = unit:editable_gui():align()
		local vertical = unit:editable_gui():vertical()
		local blend_mode = unit:editable_gui():blend_mode()
		local render_template = unit:editable_gui():render_template()
		local wrap = unit:editable_gui():wrap()
		local word_wrap = unit:editable_gui():word_wrap()
		local alpha = unit:editable_gui():alpha()
		local shape = unit:editable_gui():shape()

		file:puts(t .. "<editable_gui text=\"" .. text .. "\" font_size=\"" .. font_size .. "\" font_color=\"" .. math.vector_to_string(font_color) .. "\" font=\"" .. font .. "\" align=\"" .. align .. "\" vertical=\"" .. vertical .. "\" blend_mode=\"" .. blend_mode .. "\" render_template=\"" .. render_template .. "\" wrap=\"" .. tostring(wrap) .. "\" word_wrap=\"" .. tostring(word_wrap) .. "\" alpha=\"" .. alpha .. "\" shape=\"" .. string.format("%s %s %s %s", unpack(shape)) .. "\"/>")
	end
end

function CoreEditorGroup:draw(t, dt)
	local i = 0.25

	if managers.editor:using_groups() then
		if self._continent ~= managers.editor:current_continent() then
			return
		end

		i = 0.65
	elseif not managers.editor:debug_draw_groups() then
		return
	end

	for _, unit in ipairs(self._units) do
		Application:draw(unit, 1 * i, 1 * i, 1 * i)
	end

	Application:draw(self._reference, 0, 1 * i, 0)
end

GroupPresetsDialog = GroupPresetsDialog or class(CoreEditorEwsDialog)

function GroupPresetsDialog:init(files, path)
	self._path = path

	CoreEditorEwsDialog.init(self, nil, "Group Presets", "", Vector3(300, 150, 0), Vector3(200, 300, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP")
	self:create_panel("VERTICAL")

	self._hide_on_create = true
	local option_sizer = EWS:BoxSizer("VERTICAL")
	local hide = EWS:CheckBox(self._panel, "Hide on create", "")

	hide:set_value(self._hide_on_create)
	hide:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "hide_on_create"), hide)
	hide:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	option_sizer:add(hide, 0, 2, "RIGHT,LEFT")
	self._panel_sizer:add(option_sizer, 0, 0, "ALIGN_RIGHT")

	self._list = EWS:ListBox(self._panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	self._panel_sizer:add(self._list, 1, 0, "EXPAND")

	for _, file in ipairs(files) do
		self._list:append(file)
	end

	self._list:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "select_group"), nil)
	self._list:connect("EVT_COMMAND_LISTBOX_DOUBLECLICKED", callback(self, self, "create_group"), nil)
	self._list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local create_btn = EWS:Button(self._panel, "Create", "", "")

	button_sizer:add(create_btn, 0, 2, "RIGHT,LEFT")
	create_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "create_group"), "")
	create_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local cancel_btn = EWS:Button(self._panel, "Cancel", "", "")

	button_sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self._dialog:set_visible(true)
end

function GroupPresetsDialog:select_group()
	local i = self._list:selected_index()

	if i > -1 then
		local name = self._list:get_string(i)
		self._file = managers.database:base_path() .. self._path .. "\\" .. name
	end
end

function GroupPresetsDialog:create_group()
	if self._file then
		if self._hide_on_create then
			self._dialog:set_visible(false)
		end

		managers.editor:groups():load_group_file(self._file)
	end
end

function GroupPresetsDialog:hide_on_create(hide)
	self._hide_on_create = hide:get_value()
end
