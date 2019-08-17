core:module("CoreWireLayer")
core:import("CoreLayer")
core:import("CoreEditorSave")
core:import("CoreTable")
core:import("CoreMath")
core:import("CoreEws")

WireLayer = WireLayer or class(CoreLayer.Layer)

function WireLayer:init(owner, save_name, units_vector, slot_mask)
	WireLayer.super.init(self, owner, save_name or "wires")

	self._current_pos = Vector3(0, 0, 0)
	self._current_rot = Rotation()
	self._ctrlrs = {}
	self._mid_point_align = 0.5

	self:load_unit_map_from_vector(units_vector or {
		"wire"
	})

	self._unit_name = ""
	self._target_name = Idstring("a_target")
	self._middle_name = Idstring("a_bender")
	self._slot_mask = managers.slot:get_mask(slot_mask or "wires")
end

function WireLayer:save()
	for _, unit in ipairs(self._created_units) do
		local target = unit:get_object(self._target_name)
		local t_pos = math.vector_to_string(target:position())
		local t_rot = target:rotation()
		local wire_data = {
			target_pos = target:position(),
			target_rot = target:rotation(),
			slack = unit:wire_data().slack
		}
		local t = {
			entry = self._save_name,
			continent = unit:unit_data().continent and unit:unit_data().continent:name(),
			data = {
				unit_data = CoreEditorSave.save_data_table(unit),
				wire_data = wire_data
			}
		}

		self:_add_project_unit_save_data(unit, t.data)
		managers.editor:add_save_data(t)
		managers.editor:add_to_world_package({
			category = "units",
			name = unit:name():s(),
			continent = unit:unit_data().continent
		})
	end
end

function WireLayer:update_unit_settings()
	WireLayer.super.update_unit_settings(self)

	if self._selected_unit then
		CoreEws.change_slider_and_number_value(self._slack_params, self._selected_unit:wire_data().slack)
	else
		CoreEws.change_slider_and_number_value(self._slack_params, 0)
	end
end

function WireLayer:spawn_unit()
	if self._grab then
		return
	end

	if not self._creating_wire then
		self:clear_selected_units()

		local unit = self:do_spawn_unit(self._unit_name, self._current_pos, self._current_rot)

		if self._selected_unit then
			self._creating_wire = true

			self._selected_unit:orientation_object():set_position(self._current_pos)
			self._selected_unit:get_object(self._target_name):set_position(self._current_pos)

			self._selected_point = nil
		end
	else
		self._creating_wire = false
		self._selected_point = self._selected_unit:get_object(self._target_name)
	end
end

function WireLayer:set_select_unit(unit)
	WireLayer.super.set_select_unit(self, unit)

	self._selected_point = nil

	if self._selected_unit then
		self._selected_point = self._selected_unit:get_object(self._target_name)
	end
end

function WireLayer:delete_selected_unit()
	if self._selected_unit then
		for _, unit in ipairs(CoreTable.clone(self._selected_units)) do
			self:delete_unit(unit)
		end
	end
end

function WireLayer:delete_unit(unit)
	WireLayer.super.delete_unit(self, unit)

	self._creating_wire = nil
	self._selected_point = nil
end

function WireLayer:grab_point()
	self._grab = true
end

function WireLayer:release_grab_point()
	self._grab = false
end

function WireLayer:update(t, dt)
	WireLayer.super.update(self, t, dt)

	local ray = self._owner:select_unit_by_raycast(self._slot_mask)

	if ray then
		Application:draw_sphere(ray.position, 50, 1, 1, 0)
	end

	local p1 = self._owner:get_cursor_look_point(0)
	local p2 = self._owner:get_cursor_look_point(25000)
	local ray = World:raycast(p1, p2, nil, 1, 11, 15, 20, 21, 24, 35, 38)

	if ray then
		self._current_pos = ray.position
		local n = ray.normal
		local u_rot = Rotation()
		local z = n
		local x = (u_rot:x() - z * z:dot(u_rot:x())):normalized()
		local y = z:cross(x)
		local rot = Rotation(x, y, z)
		self._current_rot = rot
	end

	for _, unit in ipairs(self._selected_units) do
		if alive(unit) then
			local co = unit:get_object(Idstring("co_cable"))

			if co then
				Application:draw(co, 0, 1, 0)
			end
		end
	end

	Application:draw_sphere(self._current_pos, 10, 0, 1, 0)

	if self._selected_unit then
		if self._creating_wire or self._grab then
			local dot = self._current_rot:y():dot(self._selected_unit:rotation():y())
			dot = (dot - 1) / -2
			self._current_rot = self._current_rot * Rotation(180 * dot, 0, 0)
		end

		Application:draw_sphere(self._selected_unit:get_object(self._middle_name):position(), 15, 0, 0, 1)

		local co = self._selected_unit:get_object(Idstring("co_cable"))

		if co then
			Application:draw(co, 0, 1, 0)
		end

		if self._creating_wire then
			local s_pos = self._selected_unit:orientation_object():position()

			self._selected_unit:get_object(self._target_name):set_position(self._current_pos)
			self._selected_unit:get_object(self._target_name):set_rotation(self._current_rot)
			self._selected_unit:set_moving()
			self:set_midpoint()
		end
	end

	if self._selected_point then
		Application:draw_sphere(self._selected_point:position(), 25, 1, 1, 0)

		if self._grab then
			local s_pos = self._selected_unit:orientation_object():position()

			self._selected_point:set_position(self._current_pos)
			self._selected_point:set_rotation(self._current_rot)
			self._selected_unit:set_moving()
			self:set_midpoint()
		end
	end

	Application:draw_rotation(self._current_pos, self._current_rot)
end

function WireLayer:build_panel(notebook)
	cat_print("editor", "WireLayer:build_panel")

	self._ews_triggers = {}
	self._ews_panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	self._main_sizer = EWS:BoxSizer("HORIZONTAL")

	self._ews_panel:set_sizer(self._main_sizer)

	self._sizer = EWS:BoxSizer("VERTICAL")

	self:build_name_id()
	self._sizer:add(self:build_units(), 1, 0, "EXPAND")

	local slack_sizer = EWS:BoxSizer("VERTICAL")

	self._sizer:add(slack_sizer, 1, 0, "EXPAND")

	local slack_params = {
		value = 0,
		name = "Slack:",
		ctrlr_proportions = 4,
		slider_ctrlr_proportions = 3,
		name_proportions = 1,
		number_ctrlr_proportions = 1,
		min = 0,
		floats = 0,
		max = 2500,
		panel = self._ews_panel,
		sizer = slack_sizer
	}

	CoreEws.slider_and_number_controller(slack_params)
	slack_params.slider_ctrlr:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "change_slack"), nil)
	slack_params.slider_ctrlr:connect("EVT_SCROLL_CHANGED", callback(self, self, "change_slack"), nil)
	slack_params.number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "change_slack"), nil)
	slack_params.number_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "change_slack"), nil)

	self._slack_params = slack_params

	self._main_sizer:add(self._sizer, 1, 0, "EXPAND")

	return self._ews_panel
end

function WireLayer:change_slack(wire_slack)
	if self._selected_unit then
		self._selected_unit:wire_data().slack = self._slack_params.value

		self._selected_unit:set_moving()
		self:set_midpoint()
	end
end

function WireLayer:set_midpoint()
	if self._selected_unit then
		CoreMath.wire_set_midpoint(self._selected_unit, self._selected_unit:orientation_object():name(), self._target_name, self._middle_name)
	end
end

function WireLayer:deselect()
	WireLayer.super.deselect(self)
end

function WireLayer:clear()
	WireLayer.super.clear(self)

	self._selected_point = nil
end

function WireLayer:get_help(text)
	local t = "\t"
	local n = "\n"
	text = text .. "Select unit:     Click left mouse button on either attach point" .. n
	text = text .. "Create unit:     Click rigth mouse button (once the spawn, twice to attach target position)" .. n
	text = text .. "Remove unit:     Press delete"

	return text
end

function WireLayer:add_triggers()
	WireLayer.super.add_triggers(self)

	local vc = self._editor_data.virtual_controller

	vc:add_trigger(Idstring("destroy"), callback(self, self, "delete_selected_unit"))
	vc:add_trigger(Idstring("rmb"), callback(self, self, "spawn_unit"))
	vc:add_trigger(Idstring("emb"), callback(self, self, "grab_point"))
	vc:add_release_trigger(Idstring("emb"), callback(self, self, "release_grab_point"))

	for k, cb in pairs(self._ews_triggers) do
		vc:add_trigger(Idstring(k), cb)
	end
end

function WireLayer:deactivate()
	WireLayer.super.deactivate(self)
	WireLayer.super.deselect(self)
end

function WireLayer:clear_triggers()
	self._editor_data.virtual_controller:clear_triggers()
end
