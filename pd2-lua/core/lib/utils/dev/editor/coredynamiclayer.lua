core:module("CoreDynamicLayer")
core:import("CoreLayer")
core:import("CoreTable")

DynamicLayer = DynamicLayer or class(CoreLayer.Layer)

function DynamicLayer:init(owner, save_name, units_vector, slot_mask)
	DynamicLayer.super.init(self, owner, save_name)
	self:load_unit_map_from_vector(units_vector)

	self._unit_name = ""
	self._slot_mask = managers.slot:get_mask(slot_mask)
	self._distance = 1000
	self._unit_picked = false
end

function DynamicLayer:pickup_unit()
	if self._selected_unit and not self._unit_picked then
		self._up = self._selected_unit:rotation():z()
		self._forward = self._selected_unit:rotation():y()
		self._lift_effect = World:play_physic_effect(Idstring("core/physic_effects/editor_lift"), self._selected_unit, self._owner:get_cursor_look_point(self._distance), self._up, self._forward)
		self._unit_picked = true
	end
end

function DynamicLayer:spawn_unit()
	if self._selected_unit and self._unit_picked then
		self:release_unit()
	else
		local pos = self._current_pos
		local rot = Rotation(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1))

		self:do_spawn_unit(self._unit_name, pos, rot)
	end
end

function DynamicLayer:do_spawn_unit(name, pos, rot)
	local unit = DynamicLayer.super.do_spawn_unit(self, name, pos, rot)

	if unit then
		self:set_distance(math.clamp(unit:bounding_sphere_radius() * 2, 100, 1500))
		self:pickup_unit()
	end

	return unit
end

function DynamicLayer:set_distance(d)
	self._distance = math.clamp(d, 100, 4000)

	self._ews_distance:set_value(self._distance)
end

function DynamicLayer:set_select_unit(unit)
	if self._selected_unit and self._selected_unit == unit then
		if not self._unit_picked then
			self:pickup_unit()
		else
			self:release_unit()
		end
	else
		self:release_unit()
		DynamicLayer.super.set_select_unit(self, unit)
	end
end

function DynamicLayer:release_unit()
	if self._selected_unit and self._unit_picked and World:is_playing_physic_effect(self._lift_effect) then
		World:stop_physic_effect(self._lift_effect)
	end

	self._unit_picked = false
end

function DynamicLayer:delete_selected_unit()
	if self._selected_unit then
		self:release_unit()

		for _, unit in ipairs(CoreTable.clone(self._selected_units)) do
			if table.contains(self._created_units, unit) then
				self:delete_unit(unit)
			else
				managers.editor:output_warning("" .. unit:unit_data().name_id .. " belongs to " .. managers.editor:unit_in_layer_name(unit) .. " and cannot be deleted from here.")
			end
		end
	end
end

function DynamicLayer:update(t, dt)
	DynamicLayer.super.update(self, t, dt)

	local vc = self._editor_data.virtual_controller
	self._current_pos = self._owner:get_cursor_look_point(0)
	local ray = self._owner:select_unit_by_raycast(self._slot_mask)

	if ray then
		Application:draw_sphere(ray.position, self._marker_sphere_size, 1, 1, 0)
	end

	if self._selected_units then
		for _, unit in ipairs(self._selected_units) do
			if alive(unit) then
				Application:draw(unit, 1, 1, 1)
			end
		end
	end

	if self._selected_unit then
		Application:draw(self._selected_unit, 0, 1, 0)

		if self._unit_picked then
			if vc:down(Idstring("increase_dynamic_distance")) then
				self:set_distance(self._distance + 300 * dt)
			elseif vc:down(Idstring("decrease_dynamic_distance")) then
				self:set_distance(self._distance - 300 * dt)
			end

			local pos = self._owner:get_cursor_look_point(self._distance)

			World:set_physic_effect_parameter(self._lift_effect, 1, pos)
			World:set_physic_effect_parameter(self._lift_effect, 2, self._up)
			World:set_physic_effect_parameter(self._lift_effect, 3, self._forward)

			local draw_rot = Rotation(0, 0, 0)

			if self:local_rot() then
				draw_rot = self._selected_unit:rotation()
			end

			Application:draw_rotation(self._selected_unit:position(), draw_rot)
			Application:draw_circle(self._selected_unit:position(), 200, 1, 0, 0, draw_rot:x())
			Application:draw_circle(self._selected_unit:position(), 200, 0, 1, 0, draw_rot:y())
			Application:draw_circle(self._selected_unit:position(), 200, 0, 0, 1, draw_rot:z())

			local rot_speed = self:rotation_speed() * 30 * dt

			if self:shift() then
				rot_speed = rot_speed / 2
			end

			local u_rot = self._selected_unit:rotation()
			local rot_axis = nil

			if vc:down(Idstring("roll_left")) then
				rot_axis = self:local_rot() and u_rot:z() or Vector3(0, 0, 1)
			elseif vc:down(Idstring("roll_right")) then
				rot_axis = (self:local_rot() and u_rot:z() or Vector3(0, 0, 1)) * -1
			elseif vc:down(Idstring("pitch_right")) then
				rot_axis = self:local_rot() and u_rot:y() or Vector3(0, 1, 0)
			elseif vc:down(Idstring("pitch_left")) then
				rot_axis = (self:local_rot() and u_rot:y() or Vector3(0, 1, 0)) * -1
			elseif vc:down(Idstring("yaw_backward")) then
				rot_axis = self:local_rot() and u_rot:x() or Vector3(1, 0, 0)
			elseif vc:down(Idstring("yaw_forward")) then
				rot_axis = (self:local_rot() and u_rot:x() or Vector3(1, 0, 0)) * -1
			end

			if rot_axis then
				local rot = Rotation(rot_axis, rot_speed) * u_rot
				self._up = rot:z()
				self._forward = rot:y()
			end
		end
	end
end

function DynamicLayer:build_panel(notebook)
	cat_print("editor", "DynamicLayer:build_panel")

	self._ews_triggers = {}
	self._ews_panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	self._main_sizer = EWS:BoxSizer("HORIZONTAL")

	self._ews_panel:set_sizer(self._main_sizer)

	self._sizer = EWS:BoxSizer("VERTICAL")
	local distance_sizer = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL", "Distance (up/down)")
	self._ews_distance = EWS:Slider(self._ews_panel, self._distance, 100, 4000, "_distance", "")

	self._ews_distance:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_ews_distance"), self._ews_distance)
	self._ews_distance:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_ews_distance"), self._ews_distance)
	distance_sizer:add(self._ews_distance, 0, 0, "EXPAND")
	self._sizer:add(distance_sizer, 0, 0, "EXPAND")
	self:build_name_id()
	self._sizer:add(self:build_units(), 1, 0, "EXPAND")
	self._main_sizer:add(self._sizer, 2, 2, "LEFT,RIGHT,EXPAND")

	return self._ews_panel
end

function DynamicLayer:update_ews_distance(slider)
	self:set_distance(slider:get_value())
end

function DynamicLayer:deselect()
	if self._selected_unit then
		self:release_unit()
	end

	DynamicLayer.super.deselect(self)
end

function DynamicLayer:get_help(text)
	local t = "\t"
	local n = "\n"
	text = text .. "Select unit:     Click left mouse button" .. n
	text = text .. "                 (A physic selected unit will be released)" .. n
	text = text .. "Pick up unit:    Click left mouse button on an already selected unit" .. n
	text = text .. "Create unit:     Click rigth mouse button" .. n
	text = text .. "                 (A physic selected unit will be released first)" .. n
	text = text .. "Release unit:    Click middle mouse button" .. n
	text = text .. "Remove unit:     Press delete"

	return text
end

function DynamicLayer:add_triggers()
	DynamicLayer.super.add_triggers(self)

	local vc = self._editor_data.virtual_controller

	vc:add_trigger(Idstring("rmb"), callback(self, self, "spawn_unit"))
	vc:add_trigger(Idstring("mmb"), callback(self, self, "release_unit"))
	vc:add_trigger(Idstring("destroy"), callback(self, self, "delete_selected_unit"))

	for k, cb in pairs(self._ews_triggers) do
		vc:add_trigger(Idstring(k), cb)
	end
end

function DynamicLayer:deactivate()
	DynamicLayer.super.deactivate(self)
	DynamicLayer.super.deselect(self)
end

function DynamicLayer:clear_triggers()
	self._editor_data.virtual_controller:clear_triggers()
end
