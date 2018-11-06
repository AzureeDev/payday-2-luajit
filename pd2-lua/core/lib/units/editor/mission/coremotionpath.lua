CoreMotionPathOperatorUnitElement = CoreMotionPathOperatorUnitElement or class(MissionElement)
CoreMotionPathOperatorUnitElement.LINK_ELEMENTS = {
	"elements"
}
MotionPathOperatorUnitElement = MotionPathOperatorUnitElement or class(CoreMotionPathOperatorUnitElement)

function MotionPathOperatorUnitElement:init(...)
	MotionPathOperatorUnitElement.super.init(self, ...)
end

function CoreMotionPathOperatorUnitElement:init(unit)
	CoreMotionPathOperatorUnitElement.super.init(self, unit)

	self._hed.operation = "none"
	self._hed.marker = nil
	self._hed.elements = {}
	self._hed.marker_ids = {}

	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "marker")
	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "marker_ids")
end

function CoreMotionPathOperatorUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreMotionPathOperatorUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.25,
				b = 0.25,
				r = 0.75,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end

	if self._hed.marker then
		local unit = all_units[self._hed.marker_ids[self._hed.marker]]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw and alive(unit) and alive(self._unit) then
			self:_draw_link({
				g = 0.55,
				b = 0.05,
				r = 0.95,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function CoreMotionPathOperatorUnitElement:get_links_to_unit(...)
	CoreMotionPathOperatorUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "operator", ...)
end

function CoreMotionPathOperatorUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

function CoreMotionPathOperatorUnitElement:update_selected()
	Application:draw_cone(self._unit:position(), self._unit:position() + self._unit:rotation():y() * 75, 35, 1, 1, 1)
end

function CoreMotionPathOperatorUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:name() == Idstring("units/dev_tools/mission_elements/motion_path_marker/motion_path_marker") then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CoreMotionPathOperatorUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreMotionPathOperatorUnitElement:_motion_path_markers()
	self._hed.marker_ids = {}
	local motion_path_markers = {
		"none"
	}
	local mission_elements = managers.worlddefinition._mission_element_units

	for _, me in pairs(mission_elements) do
		if alive(me) and me:name() == Idstring("units/dev_tools/mission_elements/motion_path_marker/motion_path_marker") then
			table.insert_sorted(motion_path_markers, me:unit_data().name_id)

			self._hed.marker_ids[me:unit_data().name_id] = me:unit_data().unit_id
		end
	end

	return motion_path_markers
end

function CoreMotionPathOperatorUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "operation", {
		"none",
		"goto_marker",
		"teleport",
		"move",
		"wait",
		"rotate",
		"activate_bridge",
		"deactivate_bridge"
	}, "Select an operation for the selected elements.")

	local markers_combo = self:_build_value_combobox(panel, panel_sizer, "marker", self:_motion_path_markers(), "Select motion path marker.")

	Application:debug("CoreMotionPathOperatorUnitElement:_build_panel( panel, panel_sizer ): ", markers_combo)
	markers_combo:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "on_executed_marker_selected"), nil)
	self:_add_help_text("This element can modify motion path marker elements. Select motion path marker elements to modify using insert and clicking on the elements.")
end

function CoreMotionPathOperatorUnitElement:on_executed_marker_selected()
	Application:debug("CoreMotionPathOperatorUnitElement:_build_panel( panel, panel_sizer ): ", self._hed.marker, self._hed.marker_ids[self._hed.marker])

	if self._hed.marker == "none" then
		self._hed.marker = nil
	end
end

CoreMotionPathTriggerUnitElement = CoreMotionPathTriggerUnitElement or class(MissionElement)
CoreMotionPathTriggerUnitElement.LINK_ELEMENTS = {
	"elements"
}
MotionPathTriggerUnitElement = MotionPathTriggerUnitElement or class(CoreMotionPathTriggerUnitElement)

function MotionPathTriggerUnitElement:init(...)
	MotionPathTriggerUnitElement.super.init(self, ...)
end

function CoreMotionPathTriggerUnitElement:init(unit)
	CoreMotionPathTriggerUnitElement.super.init(self, unit)

	self._hed.outcome = "marker_reached"
	self._hed.elements = {}

	table.insert(self._save_values, "outcome")
	table.insert(self._save_values, "elements")
end

function CoreMotionPathTriggerUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreMotionPathTriggerUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.85,
				b = 0.25,
				r = 0.85,
				from_unit = unit,
				to_unit = self._unit
			})
		end
	end
end

function CoreMotionPathTriggerUnitElement:get_links_to_unit(...)
	CoreMotionPathTriggerUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "trigger", ...)
end

function CoreMotionPathTriggerUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

function CoreMotionPathTriggerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:name() == Idstring("units/dev_tools/mission_elements/motion_path_marker/motion_path_marker") then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CoreMotionPathTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreMotionPathTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "outcome", {
		"marker_reached"
	}, "Select an outcome to trigger on")
	self:_add_help_text("This element is a trigger on motion path marker element.")
end
