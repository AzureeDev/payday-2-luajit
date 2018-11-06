CoreMaterialEditor = CoreMaterialEditor or class()

function CoreMaterialEditor:live_update_parameter(name, param_type, param_ui_type, value)
	if alive(self._selected_unit) then
		table.insert(self._live_update_parameter_list, {
			_name = name,
			_param_type = param_type,
			_param_ui_type = param_ui_type,
			_value = value
		})
	end
end

function CoreMaterialEditor:_get_node(node, name)
	for n in node:children() do
		if n:name() == name then
			return n
		end
	end
end

function CoreMaterialEditor:_get_all_nodes(node, name)
	local t = {}

	for n in node:children() do
		if n:name() == name then
			table.insert(t, n)
		end
	end

	return t
end

function CoreMaterialEditor:_find_node(node, name, key, value)
	for n in node:children() do
		if n:parameter(key) == value and (not name or n:name() == name) then
			return n
		end
	end
end

function CoreMaterialEditor:_find_all_nodes(node, name, key, value)
	local t = {}

	for n in node:children() do
		if n:parameter(key) == value and (not name or n:name() == name) then
			table.insert(t, n)
		end
	end

	return t
end

function CoreMaterialEditor:_read_config()
	self._global_material_config_name = self.PROJECT_GLOBAL_GONFIG_NAME

	if not managers.database:has(managers.database:base_path() .. self._global_material_config_name) then
		self._global_material_config_name = self.CORE_GLOBAL_GONFIG_NAME

		if not managers.database:has(managers.database:base_path() .. self._global_material_config_name) then
			error("Could not find the global material config file!")
		end
	end

	local settings = managers.database:load_node(managers.database:base_path() .. self.SETTINGS_FILE)

	if settings then
		for setting in settings:children() do
			if setting:name() == "remote" and setting:parameter("host") then
				self._remote_host = setting:parameter("host")
			end
		end
	end
end

function CoreMaterialEditor:_write_config()
	local file = assert(SystemFS:open(managers.database:base_path() .. self.SETTINGS_FILE, "w"))
	local str = "<material_editor>\n"

	if self._remote_host then
		str = string.format("%s\t<remote host=\"%s\"/>\n", str, self._remote_host)
	end

	file:write(string.format("%s</material_editor>", str))
	file:close()
end

function CoreMaterialEditor:_freeze_frame()
	self._main_frame:freeze()
end

function CoreMaterialEditor:_unfreeze_frame()
	self._main_frame:layout()
	self._main_frame:thaw()
	self._main_frame:refresh()
end

function CoreMaterialEditor:_freeze_output()
	self._lock_output = true
end

function CoreMaterialEditor:_unfreeze_output()
	self._lock_output = nil
end

function CoreMaterialEditor:_remot_compile()
	local defines = nil

	for k, v in pairs(self._shader_defines) do
		if v._checked then
			defines = defines and defines .. " " .. k or k
		end
	end

	local cmd = string.format("start /D \"%score\\utils\\shader_server\" lua5.1.exe client.lua %s %s %s %s", managers.database:base_path(), self._remote_host, Application:short_game_name(), self._compilable_shader_combo_box:get_value(), defines)

	assert(os.execute(cmd) == 0)
end

function CoreMaterialEditor:_create_make_file(rebuild)
	local make_params, temp_params = self:_get_make_params()
	local file = SystemFS:open(managers.database:base_path() .. self.TEMP_PATH .. "make.xml", "w")

	file:write("<make>\n")
	file:write("\t<silent_fail/>\n")

	if rebuild then
		file:write("\t<rebuild/>\n")
	else
		file:write("\t<compile shader=\"" .. self._compilable_shader_combo_box:get_value() .. "\" defines=\"")

		local defines = nil

		for k, v in pairs(self._shader_defines) do
			if v._checked then
				if not defines then
					defines = k
				else
					defines = defines .. " " .. k
				end
			end
		end

		file:write((defines or "") .. "\"/>\n")
	end

	file:write("\t<file_io\n")

	for k, v in pairs(make_params) do
		file:write("\t\t" .. k .. "=\"" .. string.gsub(v, "/", "\\") .. "\"\n")
	end

	file:write("\t/>\n</make>\n")
	file:close()

	return make_params, temp_params
end

function CoreMaterialEditor:_run_compiler()
	local cmd = Application:nice_path(managers.database:root_path() .. "aux_assets\\engine\\bin\\shaderdev\\", true) .. "shaderdev -m \"" .. Application:nice_path(managers.database:base_path() .. self.TEMP_PATH .. "make.xml", false) .. "\" > \"" .. Application:nice_path(managers.database:base_path() .. self.TEMP_PATH .. "compile_log.txt", false) .. "\""
	local ret = os.execute(cmd)
	local file = SystemFS:open(managers.database:base_path() .. self.TEMP_PATH .. "compile_log.txt", "r")
	local log = file:read()

	file:close()
	CoreEWS.show_log(self._main_frame, log, ret == 0 and "Shader compiled OK!" or "Shader ERROR!")

	return ret == 0
end

function CoreMaterialEditor:_get_make_params()
	local shader = self._compilable_shaders[self._compilable_shader_combo_box:get_value()]
	local srcpath = managers.database:base_path() .. self.SHADER_PATH .. managers.database:entry_name(shader._entry)
	local tmppath = managers.database:base_path() .. self.TEMP_PATH
	local make_params = {}
	local temp_params = {}
	make_params.source = managers.database:base_path() .. shader._entry .. ".shader_source"
	make_params.working_directory = tmppath
	make_params.render_templates = srcpath .. ".render_template_database"
	make_params.win32d3d9 = tmppath .. managers.database:entry_name(shader._entry) .. ".d3d9.win32.shaders"
	make_params.win32d3d10 = tmppath .. managers.database:entry_name(shader._entry) .. ".d3d10.win32.shaders"
	make_params.ps3 = tmppath .. managers.database:entry_name(shader._entry) .. ".ps3.shaders"
	make_params.x360d3d9 = tmppath .. managers.database:entry_name(shader._entry) .. ".x360.shaders"
	make_params.lrb = tmppath .. managers.database:entry_name(shader._entry) .. ".lrb.shaders"
	temp_params.render_templates = tmppath .. managers.database:entry_name(shader._entry) .. ".render_template_database"
	temp_params.win32d3d9 = tmppath .. managers.database:entry_name(shader._entry) .. ".d3d9.win32.shaders"
	temp_params.win32d3d10 = tmppath .. managers.database:entry_name(shader._entry) .. ".d3d10.win32.shaders"
	temp_params.ps3 = tmppath .. managers.database:entry_name(shader._entry) .. ".ps3.shaders"
	temp_params.x360d3d9 = tmppath .. managers.database:entry_name(shader._entry) .. ".x360.shaders"
	temp_params.lrb = tmppath .. managers.database:entry_name(shader._entry) .. ".lrb.shaders"

	return make_params, temp_params
end

function CoreMaterialEditor:_cleanup_temp_files(temp_params)
	for k, v in pairs(temp_params) do
		os.remove(v)
	end

	os.remove(Application:nice_path(managers.database:base_path() .. self.TEMP_PATH .. "make.xml", false))
	os.remove(Application:nice_path(managers.database:base_path() .. self.TEMP_PATH .. "compile_log.txt", false))
end

function CoreMaterialEditor:_insert_libs_in_database(temp_params, make_params)
	assert(SystemFS:copy_file(temp_params.render_templates, make_params.render_templates), string.format("Could not copy %s -> %s", temp_params.render_templates, make_params.render_templates))
	self:_cleanup_temp_files(temp_params)
	managers.database:recompile()
end

function CoreMaterialEditor:_copy_to_remote_client()
end

function CoreMaterialEditor:_find_unit_material(unit)
	local path = unit:material_config():s()
	local node = DB:has("material_config", path) and DB:load_node("material_config", path)

	if node then
		return node, managers.database:entry_expanded_path("material_config", path)
	end
end

function CoreMaterialEditor:_find_selected_unit()
	if managers.editor and managers.editor:selected_unit() and managers.editor:selected_unit() ~= self._selected_unit and not self._material_lock then
		self._selected_unit = managers.editor:selected_unit()
		self._live_update_parameter_list = {}
		local unit_material_node, unit_material_path = self:_find_unit_material(self._selected_unit)

		if unit_material_node and (not self._material_config_path or unit_material_path ~= self._material_config_path) and unit_material_node:parameter("version") == self.MATERIAL_CONFIG_VERSION_TAG and EWS:message_box(self._main_frame, "Do you want to open: " .. unit_material_path, "Open", "OK,CANCEL", Vector3(-1, -1, -1)) == "OK" then
			self:_save_current()
			self:_load_node(unit_material_path)
			self._start_dialog:end_modal()
		end
	end
end

function CoreMaterialEditor:_get_material()
	local units_in_world = World:find_units_quick("all")

	for _, unit_in_world in ipairs(units_in_world) do
		local material = unit_in_world:material(Idstring(self._current_material_node:parameter("name")))

		if material then
			return material
		end
	end
end

function CoreMaterialEditor:_create_rt_name(rt)
	table.sort(rt)

	local rt_str = "generic"

	for _, option in ipairs(rt) do
		rt_str = rt_str .. ":" .. option
	end

	return rt_str
end

function CoreMaterialEditor:_try_convert_parameter(mat, child, rt)
	if child:name() == "diffuse_texture" then
		table.insert(rt, "DIFFUSE_TEXTURE")
	elseif child:name() == "bump_normal_texture" then
		table.insert(rt, "NORMALMAP")
	else
		mat:remove_child_at(mat:index_of_child(child))
	end
end

function CoreMaterialEditor:_version_error(mat)
	local res = EWS:message_box(self._main_frame, "This material is not of the expected version! Do you want to convert it?", "Version", "YES_NO", Vector3(-1, -1, -1))

	if res == "YES" then
		local rt = {}

		mat:set_parameter("version", self.MATERIAL_VERSION_TAG)
		mat:clear_parameter("src")

		for child in mat:children() do
			self:_try_convert_parameter(mat, child, rt)
		end

		mat:set_parameter("render_template", self:_create_rt_name(rt))

		return true
	else
		return false
	end
end

function CoreMaterialEditor:_update_material(param)
	local material = self:_get_material()

	if material then
		if param._param_type == "texture" then
			local name_ids = Idstring(param._name)

			Application:set_material_texture(material, name_ids, Idstring(param._value), material:texture_type(name_ids), 0)
		elseif param._param_type == "vector3" or param._param_type == "scalar" then
			if param._name == "diffuse_color" then
				material:set_diffuse_color(param._value)
			elseif param._param_ui_type == "intensity" then
				material:set_variable(Idstring(param._name), LightIntensityDB:lookup(Idstring(param._value)))
			else
				material:set_variable(Idstring(param._name), param._value)
			end
		end
	end
end

function CoreMaterialEditor:_live_update()
	if alive(self._selected_unit) then
		for _, param in ipairs(self._live_update_parameter_list) do
			self:_update_material(param)
		end

		self._live_update_parameter_list = {}
	end
end

function CoreMaterialEditor:_check_valid_xml_on_save(node)
	local str = nil

	for mat in node:children() do
		for var in mat:children() do
			if var:parameter("file") == "[NONE]" then
				str = (str or "") .. var:name() .. "\n"
			end
		end
	end

	return str == nil, str
end

function CoreMaterialEditor:_set_channels_default_texture(node)
	for mat in node:children() do
		for var in mat:children() do
			if var:parameter("file") == "[NONE]" then
				var:set_parameter("file", self.DEFAULT_TEXTURE)
			end
		end
	end
end
