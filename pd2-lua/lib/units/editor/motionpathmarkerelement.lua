local bezier3 = require("lib/utils/Bezier3")
MotionpathMarkerUnitElement = MotionpathMarkerUnitElement or class(MissionElement)
MotionpathMarkerUnitElement._bezier_points = {}
MotionpathMarkerUnitElement._linked_markers = {}
MotionpathMarkerUnitElement.PATH_TYPES = {
	"airborne",
	"ground"
}

function MotionpathMarkerUnitElement:init(unit)
	MotionpathMarkerUnitElement.super.init(self, unit)
	self:_add_wp_options()

	self._hed.icon = "pd2_goto"
	self._hed.text_id = "debug_none"
	self._hed.cp_length = 10
	self._hed.path_type = "airborne"
	self._hed.marker_target_speed = 50
	self._hed.bridges = {}
	self._hed.markers = {
		units = {}
	}
	self._hed.path_id = nil
	self._hed.motion_state = "move"

	table.insert(self._save_values, "cp_length")
	table.insert(self._save_values, "markers")
	table.insert(self._save_values, "bridges")
	table.insert(self._save_values, "path_type")
	table.insert(self._save_values, "marker_target_speed")
	table.insert(self._save_values, "path_id")
	table.insert(self._save_values, "motion_state")
end

function MotionpathMarkerUnitElement:_add_text_options_from_file(path)
	local xml = SystemFS:parse_xml(Application:base_path() .. "../../assets/" .. path)

	if xml then
		for child in xml:children() do
			local s_id = child:parameter("id")

			if string.find(s_id, "wp_") then
				table.insert(self._text_options, s_id)
			end
		end
	end
end

function MotionpathMarkerUnitElement:_add_wp_options()
	self._text_options = {
		"debug_none"
	}

	self:_add_text_options_from_file("strings/system_text.strings")
end

function MotionpathMarkerUnitElement:_set_text()
	self._text:set_value(managers.localization:text(self._hed.text_id))
end

function MotionpathMarkerUnitElement:set_element_data(params, ...)
	MotionpathMarkerUnitElement.super.set_element_data(self, params, ...)

	if params.value == "text_id" then
		self:_set_text()
	end

	self:_recreate_motion_path(self._unit, true, false)
end

function MotionpathMarkerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function MotionpathMarkerUnitElement:add_trigger(id, outcome, callback)
	self._triggers[id] = {
		outcome = outcome,
		callback = callback
	}
end

function MotionpathMarkerUnitElement:on_unselected()
end

function MotionpathMarkerUnitElement:clear()
	local path = managers.motion_path:get_path_of_marker(self._unit:unit_data().unit_id)

	if path then
		MotionpathMarkerUnitElement._linked_markers = {}

		for _, marker_id in ipairs(path.markers) do
			local marker_unit = self:_get_unit(marker_id)

			if marker_unit then
				table.insert(MotionpathMarkerUnitElement._linked_markers, marker_unit)
			end
		end
	end

	local victim_id = self._unit:unit_data().unit_id
	local victim_child_unit = self:_get_unit(self._hed.markers.child)
	local victim_parent_unit = self:_get_unit(self._hed.markers.parent)

	if victim_child_unit then
		victim_child_unit:mission_element_data().markers.parent = self._hed.markers.parent
	end

	if victim_parent_unit then
		victim_parent_unit:mission_element_data().markers.child = self._hed.markers.child
	end

	local linked_markers = MotionpathMarkerUnitElement._linked_markers

	for i, candidate in ipairs(linked_markers) do
		if candidate:unit_data().unit_id == victim_id then
			table.remove(linked_markers, i)

			i = i - 1
		end
	end

	for i, candidate in ipairs(self._hed.bridges) do
		local marker_to = self:_get_unit(candidate.marker_to)

		if alive(marker_to) then
			local marker_to_bridges = marker_to:mission_element_data().bridges

			if marker_to_bridges then
				for i_bridge, bridge in ipairs(marker_to_bridges) do
					if bridge.marker_to == candidate.marker_from then
						table.remove(marker_to_bridges, i_bridge)
						self:_recreate_motion_path(marker_to, true, false)
					end
				end
			end
		end
	end

	if linked_markers[1] then
		self:_recreate_motion_path(linked_markers[1], true, false)
	end

	managers.motion_path:sanitize_paths()
end

function MotionpathMarkerUnitElement:_is_infinite_loop(candidate_unit)
	local linked_markers = MotionpathMarkerUnitElement._linked_markers
	local candidate_unit_id = candidate_unit:unit_data().unit_id

	for _, marker_unit in ipairs(linked_markers) do
		if candidate_unit_id == marker_unit:mission_element_data().markers.child or candidate_unit_id == marker_unit:mission_element_data().markers.parent then
			Application:trace("MotionpathMarkerUnitElement:_is_infinite_loop(candidate_unit) loop")

			return true
		end
	end

	return false
end

function MotionpathMarkerUnitElement:_bridge_exists(unit_id_from, unit_id_to)
	for idx, bridge in ipairs(self._hed.bridges) do
		if bridge.marker_from == unit_id_from and bridge.marker_to == unit_id_to or bridge.marker_from == unit_id_to and bridge.marker_to == unit_id_from then
			return idx
		end
	end

	return -1
end

function MotionpathMarkerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		local unit_to = ray.unit
		local unit_id = unit_to:unit_data().unit_id

		if ray.unit:name() == Idstring("units/dev_tools/mission_elements/motion_path_marker/motion_path_marker") then
			local unit_id_from = self._unit:unit_data().unit_id
			local path_from = managers.motion_path:get_path_of_marker(unit_id_from)
			local path_to = managers.motion_path:get_path_of_marker(unit_id)

			if path_from and path_to and path_from.id ~= path_to.id then
				local bridge_id = self:_bridge_exists(unit_id_from, unit_id)

				if bridge_id > -1 then
					table.remove(self._hed.bridges, bridge_id)
				else
					table.insert(self._hed.bridges, {
						marker_from = unit_id_from,
						marker_to = unit_id,
						path_id = path_to.id,
						distance = mvector3.distance(self._unit:position(), unit_to:position())
					})
				end

				self:_recreate_motion_path(self._unit, true, false)

				return
			end

			if not self:_is_infinite_loop(ray.unit) then
				if self._hed.markers.child == unit_id then
					self._hed.markers.child = nil
					ray.unit:mission_element_data().markers.parent = nil
				else
					self._hed.markers.child = unit_id
					ray.unit:mission_element_data().markers.parent = self._unit:unit_data().unit_id
				end
			else
				Application:error("MotionpathMarkerUnitElement:add_element() - Possible infinite loop detected. Unit not linked.")
			end
		else
			local index = table.index_of(self._hed.markers.units, unit_id)

			if self._hed.markers.units and index > -1 then
				print("MotionpathMarkerUnitElement:add_element() Removing unit_id: ", unit_id)
				table.remove(self._hed.markers.units, index)
				print(inspect(self._hed.markers.units))
			else
				if not self._hed.markers.units then
					self._hed.markers.units = {}
				end

				print("MotionpathMarkerUnitElement:add_element() Adding unit_id: ", unit_id, self._unit:unit_data().unit_id)
				managers.motion_path:remove_unit_from_paths(unit_id)
				table.insert(self._hed.markers.units, unit_id)
				print(inspect(self._hed.markers.units))
			end
		end

		self:_recreate_motion_path(self._unit, true, false)
	end
end

function MotionpathMarkerUnitElement:remove_unit(unit_id)
	local index = table.index_of(self._hed.markers.units, unit_id)

	if self._hed.markers.units and index > -1 then
		table.remove(self._hed.markers.units, index)
	end
end

function MotionpathMarkerUnitElement:draw_links(t, dt, selected_unit, all_units)
	MotionpathMarkerUnitElement.super.draw_links(self, t, dt, selected_unit)

	if self._hed.markers.child then
		local unit = all_units[self._hed.markers.child]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw and unit then
			self:_draw_link({
				g = 0.849,
				b = 0.01,
				r = 0.514,
				from_unit = unit,
				to_unit = self._unit
			})
		end
	end

	if self._hed.markers.units then
		for _, linked_unit in ipairs(self._hed.markers.units) do
			local unit = self:_get_unit(linked_unit)
			local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

			if draw and alive(unit) and alive(self._unit) then
				self:_draw_link({
					g = 0.449,
					b = 0.01,
					r = 0.8,
					from_unit = unit,
					to_unit = self._unit
				})
			end
		end
	end

	if self._hed.bridges then
		for _, bridge in ipairs(self._hed.bridges) do
			local marker_from = all_units[bridge.marker_from]
			local marker_to = all_units[bridge.marker_to]

			if alive(marker_from) and alive(marker_to) then
				self:_draw_link({
					g = 1,
					b = 0.01,
					r = 1,
					from_unit = marker_from,
					to_unit = marker_to
				})
			end
		end
	end
end

function MotionpathMarkerUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

function MotionpathMarkerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local cp_length_params = {
		name = "Control Point Length:",
		ctrlr_proportions = 2,
		slider_ctrlr_proportions = 3,
		name_proportions = 1,
		number_ctrlr_proportions = 1,
		min = 1,
		floats = 3,
		max = 10000,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.cp_length
	}

	CoreEws.slider_and_number_controller(cp_length_params)
	cp_length_params.slider_ctrlr:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_element_data"), {
		value = "cp_length",
		ctrlr = cp_length_params.number_ctrlr
	})
	cp_length_params.slider_ctrlr:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_element_data"), {
		value = "cp_length",
		ctrlr = cp_length_params.number_ctrlr
	})
	cp_length_params.number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "cp_length",
		ctrlr = cp_length_params.number_ctrlr
	})
	cp_length_params.number_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "cp_length",
		ctrlr = cp_length_params.number_ctrlr
	})
	self:_build_value_combobox(panel, panel_sizer, "motion_state", {
		"move",
		"wait"
	}, "Units on this marker will either wait or move through it.")

	local speed_params = {
		name_proportions = 1,
		name = "Speed [km/h]:",
		ctrlr_proportions = 2,
		tooltip = "Set the target unit speed at this marker in km/h. Set to -1 to ignore.",
		min = -1,
		floats = 1,
		max = 1000,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.marker_target_speed
	}
	local speed_ctrlr = CoreEWS.number_controller(speed_params)

	speed_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "marker_target_speed",
		ctrlr = speed_ctrlr
	})
	speed_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "marker_target_speed",
		ctrlr = speed_ctrlr
	})

	local add_marker_btn = EWS:Button(panel, "Insert Marker", "", "BU_EXACTFIT,NO_BORDER")

	panel_sizer:add(add_marker_btn, 0, 5, "RIGHT")
	add_marker_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_add_marker_to_path"), nil)
	self:_add_help_text("De Casteljau - Bezier spline end point and control point vector.")
end

local b2 = {
	100,
	500,
	100,
	200,
	1000,
	100,
	1000,
	500
}
local b21 = {
	1000,
	100,
	1000,
	100,
	1600,
	500,
	1600,
	500
}
local scale = 0.1
local width = 0
local angle_tolerance = 0
local cusp_limit = 0

function MotionpathMarkerUnitElement:update_unselected(t, dt, selected_unit, all_units)
end

function MotionpathMarkerUnitElement:update_selected(t, dt, selected_unit, all_units)
	Application:draw_cylinder(self._unit:position(), self._unit:position() + self._unit:rotation():y() * self._hed.cp_length, 10, 0.514, 0.849, 0.01)
	self:_recreate_motion_path(selected_unit, false, true)
end

function MotionpathMarkerUnitElement:_add_marker_to_path()
	local target_marker_id = self._hed.markers.child or self._hed.markers.parent

	if not target_marker_id then
		return
	end

	local target_marker = self:_get_unit(target_marker_id)
	local path = managers.motion_path:get_path_of_marker(target_marker_id)

	if not path then
		return
	end

	local middle_point = self:_get_middle_point(path, self._unit:unit_data().unit_id, target_marker_id)
	local continent_name = managers.editor:current_continent():name()
	local new_unit = managers.editor._current_layer:create_unit("units/dev_tools/mission_elements/motion_path_marker/motion_path_marker", middle_point.point, Rotation(0, 0, 0), continent_name)

	if new_unit then
		managers.editor._current_layer:add_unit_to_created_units(new_unit)
	end

	if target_marker_id == self._hed.markers.child then
		self._hed.markers.child = new_unit:unit_data().unit_id
		new_unit:mission_element_data().markers.parent = self._unit:unit_data().unit_id
		new_unit:mission_element_data().markers.child = target_marker_id
		target_marker:mission_element_data().markers.parent = new_unit:unit_data().unit_id
	else
		self._hed.markers.parent = new_unit:unit_data().unit_id
		new_unit:mission_element_data().markers.child = self._unit:unit_data().unit_id
		new_unit:mission_element_data().markers.parent = target_marker_id
		target_marker:mission_element_data().markers.child = new_unit:unit_data().unit_id
	end

	self:_recreate_motion_path(self._unit, true, false)
end

function MotionpathMarkerUnitElement:_get_middle_point(path, selected_marker_id, target_marker_id)
	local selected_point_offset, target_point_offset = nil

	for idx, checkpoint in pairs(path.marker_checkpoints) do
		if checkpoint == selected_marker_id then
			selected_point_offset = idx
		end

		if checkpoint == target_marker_id then
			target_point_offset = idx
		end
	end

	local offset = math.min(selected_point_offset, target_point_offset) + math.round(math.abs(selected_point_offset - target_point_offset) / 2) + 1

	return path.points[offset]
end

function MotionpathMarkerUnitElement:_recreate_motion_path(selected_unit, force_update, skip_recreate)
	if not force_update and (self._last_marker_pos == selected_unit:position() or self._last_marker_pos == selected_unit:position()) then
		return
	end

	self._last_marker_pos = selected_unit:position()
	self._last_marker_rot = selected_unit:rotation()
	local current_marker_unit = selected_unit
	local parent_marker_unit = self:_get_unit(selected_unit:mission_element_data().markers.parent)

	while parent_marker_unit and alive(parent_marker_unit) do
		current_marker_unit = parent_marker_unit
		parent_marker_unit = self:_get_unit(parent_marker_unit:mission_element_data().markers.parent)
	end

	MotionpathMarkerUnitElement._linked_markers = {}
	local linked_markers = MotionpathMarkerUnitElement._linked_markers

	table.insert(linked_markers, current_marker_unit)

	local path_length = 0
	local child_marker_unit = self:_get_unit(current_marker_unit:mission_element_data().markers.child)
	local last_child = current_marker_unit

	while child_marker_unit and alive(child_marker_unit) do
		local distance = mvector3.distance(last_child:position(), child_marker_unit:position())
		path_length = path_length + distance

		table.insert(linked_markers, 1, child_marker_unit)

		last_child = child_marker_unit
		child_marker_unit = self:_get_unit(child_marker_unit:mission_element_data().markers.child)
	end

	local bline = {}
	local entire_path_points = {}
	local units_on_path = {}
	local marker_checkpoints = {}
	local bridges_from_this_path = {}

	for i = 1, #linked_markers do
		local from_unit = linked_markers[i]
		local to_unit = linked_markers[i + 1]

		if from_unit and to_unit then
			for i, bridge in ipairs(from_unit:mission_element_data().bridges) do
				table.insert(bridges_from_this_path, bridge)
			end

			marker_checkpoints[#entire_path_points + 1] = from_unit:unit_data().unit_id
			bline = self:_build_points(from_unit, to_unit)
			local n1 = self:bez_draw("bline", bline, 1)

			table.insert(self._bezier_points, 1, Vector3(from_unit:position().x, from_unit:position().y, from_unit:position().z))

			if from_unit and not from_unit:mission_element_data().markers.child then
				local units_on_marker = from_unit:mission_element_data().markers.units

				if units_on_marker then
					for _, linked_unit_id in ipairs(units_on_marker) do
						local unit_and_position = {
							unit = linked_unit_id,
							target_checkpoint = #entire_path_points + 1,
							initial_checkpoint = #entire_path_points + 1
						}

						print("adding unit: ", linked_unit_id, inspect(from_unit:mission_element_data()))
						table.insert(units_on_path, unit_and_position)
					end
				end
			end

			local units_on_marker = to_unit:mission_element_data().markers.units

			if units_on_marker then
				for _, linked_unit_id in ipairs(units_on_marker) do
					local unit_and_position = {
						unit = linked_unit_id,
						target_checkpoint = #entire_path_points + 1,
						initial_checkpoint = #entire_path_points + 1
					}

					table.insert(units_on_path, unit_and_position)
				end
			end

			local points_in_batch = #self._bezier_points
			local z_step = (to_unit:position().z - from_unit:position().z) / points_in_batch
			local speed_step = (to_unit:mission_element_data().marker_target_speed - from_unit:mission_element_data().marker_target_speed) / points_in_batch
			local current_z = from_unit:position().z
			local current_speed = to_unit:mission_element_data().marker_target_speed
			local final_speed = nil

			for _, point in ipairs(self._bezier_points) do
				current_z = current_z + z_step
				final_speed = current_speed == -1 and -1 or (current_speed + speed_step) * 27.77

				table.insert(entire_path_points, {
					point = point:with_z(current_z),
					speed = final_speed
				})
			end
		end
	end

	if entire_path_points then
		for j = 1, #entire_path_points do
			if entire_path_points[j + 1] then
				Application:draw_line(entire_path_points[j].point, entire_path_points[j + 1].point, 1, 1, 1)
			end
		end
	end

	for i, bridge in ipairs(linked_markers[#linked_markers]:mission_element_data().bridges) do
		table.insert(bridges_from_this_path, bridge)
	end

	marker_checkpoints[#entire_path_points] = linked_markers[#linked_markers]:unit_data().unit_id
	local marker_ids = {}

	for _, marker in ipairs(linked_markers) do
		table.insert(marker_ids, marker:unit_data().unit_id)
	end

	local first_marker_id = nil

	if linked_markers[1] then
		first_marker_id = linked_markers[1]:unit_data().unit_id
	end

	local path_id, path_type = nil
	local existing_path = managers.motion_path:get_path_of_marker(first_marker_id)

	if existing_path then
		path_id = existing_path.id
		path_type = existing_path.path_type
		self._hed.path_type = existing_path.path_type
	else
		path_id = managers.motion_path:get_path_id(marker_ids)
		path_type = self._hed.path_type or "airborne"
	end

	local entire_path_points_reverse = {}

	for i = 1, #entire_path_points do
		table.insert(entire_path_points_reverse, 1, {
			point = entire_path_points[i].point,
			speed = entire_path_points[#entire_path_points - i + 1].speed
		})
	end

	for _, bridge in ipairs(bridges_from_this_path) do
		local path_to = managers.motion_path:get_path_of_marker(bridge.marker_to)

		if path_to then
			bridge.path_id = path_to.id
		else
			bridge.path_id = nil
		end
	end

	local path = {
		id = path_id,
		path_type = path_type,
		length = path_length,
		bridges = bridges_from_this_path,
		points = entire_path_points,
		points_bck = entire_path_points_reverse,
		markers = marker_ids,
		units = units_on_path,
		marker_checkpoints = marker_checkpoints
	}
	self._hed.path_id = path_id

	managers.motion_path:update_path(path, skip_recreate)
end

function MotionpathMarkerUnitElement:_get_unit(unit_id)
	if Application:editor() then
		return managers.editor:unit_with_id(unit_id)
	else
		return managers.worlddefinition:get_unit(unit_id)
	end
end

function MotionpathMarkerUnitElement:_build_points(from_unit, to_unit)
	local cp1 = from_unit:position() + from_unit:rotation():y() * from_unit:mission_element_data().cp_length * -1
	local x1 = from_unit:position().x
	local y1 = from_unit:position().y
	local x2 = cp1.x
	local y2 = cp1.y
	local x3 = 0
	local y3 = 0
	local x4 = 0
	local y4 = 0
	x4 = to_unit:position().x
	y4 = to_unit:position().y
	local cp2 = to_unit:position() + to_unit:rotation():y() * to_unit:mission_element_data().cp_length
	x3 = cp2.x
	y3 = cp2.y

	return {
		x1,
		y1,
		x2,
		y2,
		x3,
		y3,
		x4,
		y4
	}
end

function MotionpathMarkerUnitElement:bez_interpolate(x1, y1, x2, y2, x3, y3, x4, y4, ...)
	local n = 0
	self._bezier_points = {}

	bezier3.interpolate(function (s, x, y)
		table.insert(self._bezier_points, Vector3(x, y, 500))

		n = n + 1
	end, x1, y1, x2, y2, x3, y3, x4, y4, scale, angle_tolerance, cusp_limit)

	return n
end

function MotionpathMarkerUnitElement:bez_draw(id, b, t)
	local x, y, w, h = bezier3.bounding_box(unpack(b))
	local ax1, ay1, ax2, ay2, ax3, ay3, ax4, ay4, bx1, by1, bx2, by2, bx3, by3, bx4, by4 = bezier3.split(t, unpack(b))
	local n1 = self:bez_interpolate(ax1, ay1, ax2, ay2, ax3, ay3, ax4, ay4, "#ffff00")

	return n1
end
