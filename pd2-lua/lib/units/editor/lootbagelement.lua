LootBagUnitElement = LootBagUnitElement or class(MissionElement)
LootBagUnitElement.USES_POINT_ORIENTATION = true

function LootBagUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._test_units = {}
	self._hed.spawn_dir = Vector3(0, 0, 1)
	self._hed.push_multiplier = 0
	self._hed.carry_id = "none"
	self._hed.from_respawn = false
end

function LootBagUnitElement:save(list)
	if self._hed.push_multiplier ~= 0 then
		list.spawn_dir = self._hed.spawn_dir
		list.push_multiplier = self._hed.push_multiplier
	end

	list.carry_id = self._hed.carry_id
	list.from_respawn = self._hed.from_respawn
end

function LootBagUnitElement:test_element()
	local unit_name = "units/payday2/pickups/gen_pku_lootbag/gen_pku_lootbag"
	local throw_distance_multiplier = 1

	if self._hed.carry_id ~= "none" then
		unit_name = tweak_data.carry[self._hed.carry_id].unit or unit_name
		local carry_type = tweak_data.carry[self._hed.carry_id].type
		throw_distance_multiplier = tweak_data.carry.types[carry_type].throw_distance_multiplier or throw_distance_multiplier
	end

	local unit = safe_spawn_unit(unit_name, self._unit:position(), self._unit:rotation())

	table.insert(self._test_units, unit)

	local push_value = self._hed.push_multiplier and self._hed.spawn_dir * self._hed.push_multiplier or 0

	unit:push(100, 600 * push_value * throw_distance_multiplier)
end

function LootBagUnitElement:stop_test_element()
	for _, unit in ipairs(self._test_units) do
		if alive(unit) then
			World:delete_unit(unit)
		end
	end

	self._test_units = {}
end

function LootBagUnitElement:update_selected(time, rel_time)
	Application:draw_arrow(self._unit:position(), self._unit:position() + self._hed.spawn_dir * 50, 0.75, 0.75, 0.75, 0.1)
end

function LootBagUnitElement:update_editing(time, rel_time)
	local kb = Input:keyboard()
	local speed = 60 * rel_time

	if kb:down(Idstring("left")) then
		self._hed.spawn_dir = self._hed.spawn_dir:rotate_with(Rotation(speed, 0, 0))
	end

	if kb:down(Idstring("right")) then
		self._hed.spawn_dir = self._hed.spawn_dir:rotate_with(Rotation(-speed, 0, 0))
	end

	if kb:down(Idstring("up")) then
		self._hed.spawn_dir = self._hed.spawn_dir:rotate_with(Rotation(0, 0, speed))
	end

	if kb:down(Idstring("down")) then
		self._hed.spawn_dir = self._hed.spawn_dir:rotate_with(Rotation(0, 0, -speed))
	end

	local from = self._unit:position()
	local to = from + self._hed.spawn_dir * 100000
	local ray = managers.editor:unit_by_raycast({
		from = from,
		to = to,
		mask = managers.slot:get_mask("statics_layer")
	})

	if ray and ray.unit then
		Application:draw_sphere(ray.position, 25, 1, 0, 0)
	end
end

function LootBagUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "push_multiplier", {
		floats = 1,
		min = 0
	}, "Use this to add a velocity to a physic push on the spawned unit")
	self:_build_value_combobox(panel, panel_sizer, "carry_id", table.list_add({
		"none"
	}, tweak_data.carry:get_carry_ids()), "Select a carry_id to be created.")
	self:_build_value_checkbox(panel, panel_sizer, "from_respawn")
end

LootBagTriggerUnitElement = LootBagTriggerUnitElement or class(MissionElement)
LootBagTriggerUnitElement.SAVE_UNIT_POSITION = false
LootBagTriggerUnitElement.SAVE_UNIT_ROTATION = false
LootBagTriggerUnitElement.LINK_ELEMENTS = {
	"elements"
}

function LootBagTriggerUnitElement:init(unit)
	LootBagTriggerUnitElement.super.init(self, unit)

	self._hed.elements = {}
	self._hed.trigger_type = "load"

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "trigger_type")
end

function LootBagTriggerUnitElement:draw_links(t, dt, selected_unit, all_units)
	LootBagTriggerUnitElement.super.draw_links(self, t, dt, selected_unit)

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

function LootBagTriggerUnitElement:update_editing()
end

function LootBagTriggerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring("units/dev_tools/mission_elements/point_loot_bag/point_loot_bag") then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function LootBagTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function LootBagTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"point_loot_bag/point_loot_bag"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_combobox(panel, panel_sizer, "trigger_type", {
		"load",
		"spawn"
	}, "Select a trigger type for the selected elements")
	self:_add_help_text("This element is a trigger to point_loot_bag element.")
end
