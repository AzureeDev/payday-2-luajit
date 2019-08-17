core:import("CoreEditorUtils")
core:import("CoreEws")

EditUnitVariation = EditUnitVariation or class(EditUnitBase)

function EditUnitVariation:init(editor)
	local panel, sizer = (editor or managers.editor):add_unit_edit_page({
		name = "Variations",
		class = self
	})
	self._panel = panel
	self._ctrls = {}
	self._element_guis = {}
	local all_variations_sizer = EWS:BoxSizer("VERTICAL")
	self._mesh_params = {
		default = "default",
		name = "Mesh:",
		ctrlr_proportions = 3,
		name_proportions = 1,
		tooltip = "Select a mesh variation from the combobox",
		sorted = true,
		sizer_proportions = 2,
		panel = panel,
		sizer = all_variations_sizer,
		options = {}
	}

	CoreEws.combobox(self._mesh_params)
	self._mesh_params.ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "change_variation"), nil)

	self._material_params = {
		default = "default",
		name = "Material:",
		ctrlr_proportions = 3,
		name_proportions = 1,
		tooltip = "Select a material variation from the combobox",
		sorted = true,
		sizer_proportions = 2,
		panel = panel,
		sizer = all_variations_sizer,
		options = {}
	}

	CoreEws.combobox(self._material_params)
	self._material_params.ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "change_material"), nil)
	sizer:add(all_variations_sizer, 0, 0, "EXPAND")

	self._avalible_material_groups = {}

	panel:layout()
	panel:set_enabled(false)
end

function EditUnitVariation:change_variation()
	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) then
			local mesh_variation = self._mesh_params.ctrlr:get_value()
			local reset = managers.sequence:get_reset_editable_state_sequence_list(unit:name())[1]

			if reset then
				managers.sequence:run_sequence_simple2(reset, "change_state", unit)
			end

			local variations = managers.sequence:get_editable_state_sequence_list(unit:name())

			if #variations > 0 then
				if mesh_variation == "default" then
					unit:unit_data().mesh_variation = "default"
				elseif table.contains(variations, mesh_variation) then
					managers.sequence:run_sequence_simple2(mesh_variation, "change_state", unit)

					unit:unit_data().mesh_variation = mesh_variation
				end
			end
		end
	end
end

function EditUnitVariation:change_material()
	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) then
			local material = self._material_params.ctrlr:get_value()
			local materials = self:get_material_configs_from_meta(unit:name())

			if table.contains(materials, material) then
				if material ~= "default" then
					unit:set_material_config(Idstring(material), true)
				end

				unit:unit_data().material = material
			end
		end
	end
end

function EditUnitVariation:is_editable(unit, units)
	if alive(unit) then
		local variations = managers.sequence:get_editable_state_sequence_list(unit:name())
		local materials = self:get_material_configs_from_meta(unit:name())

		if #variations > 0 or #materials > 0 then
			self._ctrls.unit = unit
			self._ctrls.units = units

			CoreEws.update_combobox_options(self._mesh_params, variations)
			CoreEws.change_combobox_value(self._mesh_params, self._ctrls.unit:unit_data().mesh_variation)
			self._mesh_params.ctrlr:set_enabled(#variations > 0)
			CoreEws.update_combobox_options(self._material_params, materials)
			CoreEws.change_combobox_value(self._material_params, self._ctrls.unit:unit_data().material)
			self._material_params.ctrlr:set_enabled(#materials > 0)

			return true
		end
	end

	return false
end

function EditUnitVariation:get_material_configs_from_meta(unit_name)
	self._avalible_material_groups = self._avalible_material_groups or {}

	if self._avalible_material_groups[unit_name:key()] then
		return self._avalible_material_groups[unit_name:key()]
	end

	local node = CoreEngineAccess._editor_unit_data(unit_name:id()):model_script_data()
	local available_groups = {}
	local groups = {}

	for child in node:children() do
		if child:name() == "metadata" and child:parameter("material_config_group") ~= "" then
			table.insert(groups, child:parameter("material_config_group"))
		end
	end

	if #groups > 0 then
		for _, entry in ipairs(managers.database:list_entries_of_type("material_config")) do
			local node = DB:load_node("material_config", entry)

			for _, group in ipairs(groups) do
				local group_name = node:has_parameter("group") and node:parameter("group")

				if group_name == group and not table.contains(available_groups, entry) then
					table.insert(available_groups, entry)
				end
			end
		end
	end

	self._avalible_material_groups[unit_name:key()] = available_groups

	return available_groups
end
