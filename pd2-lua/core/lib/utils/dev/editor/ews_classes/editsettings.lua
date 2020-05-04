core:import("CoreEditorUtils")
core:import("CoreEws")

EditUnitSettings = EditUnitSettings or class(EditUnitBase)

function EditUnitSettings:init(editor)
	local panel, sizer = (editor or managers.editor):add_unit_edit_page({
		name = "Settings",
		class = self
	})
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")
	local settings_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Core")
	local cutscene_actor_sizer = EWS:BoxSizer("HORIZONTAL")

	cutscene_actor_sizer:add(EWS:StaticText(panel, "Cutscene Actor:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local cutscene_actor_name = EWS:StaticText(panel, "", 0, "ALIGN_CENTRE,ST_NO_AUTORESIZE")

	cutscene_actor_sizer:add(cutscene_actor_name, 2, 0, "ALIGN_CENTER_VERTICAL")

	local cutscene_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	cutscene_toolbar:add_tool("US_ADD_CUTSCENE_ACTOR", "Add this unit as an actor.", CoreEws.image_path("plus_16x16.png"), "Add this unit as an actor.")
	cutscene_toolbar:connect("US_ADD_CUTSCENE_ACTOR", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_cutscene_actor"), nil)
	cutscene_toolbar:add_tool("US_REMOVE_CUTSCENE_ACTOR", "Remove this unit as an actor.", CoreEws.image_path("toolbar\\delete_16x16.png"), "Add this unit as an actor.")
	cutscene_toolbar:connect("US_REMOVE_CUTSCENE_ACTOR", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_cutscene_actor"), nil)
	cutscene_toolbar:realize()
	cutscene_actor_sizer:add(cutscene_toolbar, 0, 0, "EXPAND")
	settings_sizer:add(cutscene_actor_sizer, 0, 5, "EXPAND,BOTTOM")

	local disable_shadows = EWS:CheckBox(panel, "Disable Shadows", "")

	disable_shadows:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_disable_shadows"), nil)
	settings_sizer:add(disable_shadows, 1, 5, "EXPAND,BOTTOM")

	local disable_collision = EWS:CheckBox(panel, "Disable Collision", "")

	disable_collision:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_disable_collision"), nil)
	settings_sizer:add(disable_collision, 1, 5, "EXPAND,BOTTOM")

	local delayed_load = EWS:CheckBox(panel, "Delayed Load", "")

	delayed_load:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_delayed_load"), nil)
	settings_sizer:add(delayed_load, 1, 5, "EXPAND,BOTTOM")

	local hide_on_projection_light = EWS:CheckBox(panel, "Hide On Projection Light", "")

	hide_on_projection_light:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_hide_on_projection_light"), nil)
	settings_sizer:add(hide_on_projection_light, 1, 5, "EXPAND,BOTTOM")

	local disable_on_ai_graph = EWS:CheckBox(panel, "Disable On AI Graph", "")

	disable_on_ai_graph:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_disable_on_ai_graph"), nil)
	settings_sizer:add(disable_on_ai_graph, 1, 5, "EXPAND,BOTTOM")
	horizontal_sizer:add(settings_sizer, 0, 0, "ALIGN_LEFT")
	sizer:add(horizontal_sizer, 1, 0, "ALIGN_LEFT,EXPAND")

	self._ctrls = {
		cutscene_actor_name = cutscene_actor_name,
		cutscene_actor_toolbar = cutscene_toolbar,
		disable_shadows = disable_shadows,
		disable_collision = disable_collision,
		delayed_load = delayed_load,
		hide_on_projection_light = hide_on_projection_light,
		disable_on_ai_graph = disable_on_ai_graph
	}

	panel:layout()
	panel:set_enabled(false)

	self._panel = panel
end

function EditUnitSettings:add_cutscene_actor()
	local name = EWS:get_text_from_user(Global.frame_panel, "Enter name for cutscene actor:", "Add cutscene actor", "", Vector3(-1, -1, 0), true)

	if name and name ~= "" then
		self._ctrls.unit:unit_data().cutscene_actor = name

		if managers.cutscene:register_cutscene_actor(self._ctrls.unit) then
			self._ctrls.cutscene_actor_name:set_value(name)
			self._ctrls.cutscene_actor_toolbar:set_tool_enabled("US_REMOVE_CUTSCENE_ACTOR", true)
		else
			self._ctrls.unit:unit_data().cutscene_actor = nil

			self:add_cutscene_actor()
		end
	end
end

function EditUnitSettings:remove_cutscene_actor()
	managers.cutscene:unregister_cutscene_actor(self._ctrls.unit)

	self._ctrls.unit:unit_data().cutscene_actor = nil

	self._ctrls.cutscene_actor_name:set_value("")
end

function EditUnitSettings:set_disable_shadows()
	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) then
			unit:unit_data().disable_shadows = self._ctrls.disable_shadows:get_value()

			unit:set_shadows_disabled(unit:unit_data().disable_shadows)
		end
	end
end

function EditUnitSettings:set_disable_collision()
	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) then
			local disable = self._ctrls.disable_collision:get_value()
			unit:unit_data().disable_collision = disable

			for index = 0, unit:num_bodies() - 1 do
				local body = unit:body(index)

				if body then
					body:set_collisions_enabled(not disable)
					body:set_collides_with_mover(not disable)
				end
			end
		end
	end
end

function EditUnitSettings:set_delayed_load()
	local delayed = self._ctrls.delayed_load:get_value()

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) then
			unit:unit_data().delayed_load = delayed
		end
	end
end

function EditUnitSettings:set_hide_on_projection_light()
	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) then
			unit:unit_data().hide_on_projection_light = self._ctrls.hide_on_projection_light:get_value() or nil
		end
	end
end

function EditUnitSettings:set_disable_on_ai_graph()
	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) then
			unit:unit_data().disable_on_ai_graph = self._ctrls.disable_on_ai_graph:get_value() or nil
		end
	end
end

function EditUnitSettings:is_editable(unit, units)
	if alive(unit) then
		self._ctrls.unit = unit
		self._ctrls.units = units

		self._ctrls.cutscene_actor_name:set_value(self._ctrls.unit:unit_data().cutscene_actor or "")
		self._ctrls.cutscene_actor_toolbar:set_tool_enabled("US_REMOVE_CUTSCENE_ACTOR", self._ctrls.unit:unit_data().cutscene_actor)
		self._ctrls.disable_shadows:set_value(self._ctrls.unit:unit_data().disable_shadows)
		self._ctrls.disable_collision:set_value(self._ctrls.unit:unit_data().disable_collision or false)
		self._ctrls.delayed_load:set_value(self._ctrls.unit:unit_data().delayed_load or false)
		self._ctrls.hide_on_projection_light:set_value(self._ctrls.unit:unit_data().hide_on_projection_light)
		self._ctrls.disable_on_ai_graph:set_value(self._ctrls.unit:unit_data().disable_on_ai_graph)

		return true
	end

	return false
end
