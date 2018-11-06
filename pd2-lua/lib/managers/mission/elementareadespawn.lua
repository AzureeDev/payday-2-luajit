core:import("CoreElementShape")

ElementAreaDespawn = ElementAreaDespawn or class(CoreElementShape.ElementShape)

function ElementAreaDespawn:init(...)
	ElementAreaDespawn.super.init(self, ...)

	self._shape_elements = {
		self
	}
end

function ElementAreaDespawn:on_script_activated()
	ElementAreaDespawn.super.on_script_activated(self)

	if not self._values.shape_elements then
		return
	end

	self._shape_elements = {}

	for _, id in ipairs(self._values.shape_elements) do
		local element = self:get_mission_element(id)

		table.insert(self._shape_elements, element)
	end
end

function ElementAreaDespawn:_find_units_in_shape(shape_element)
	local shape_values = shape_element:values()
	local shape_type = shape_values.shape_type
	local position = shape_values.position
	local rotation = shape_values.rotation
	local slot_mask = World:make_slot_mask(unpack(self._values.slots))
	local find_params = nil

	if shape_type == "box" then
		local box_x = Vector3(shape_values.width * 0.5, 0, 0):rotate_with(rotation)
		local box_y = Vector3(0, shape_values.depth * 0.5, 0):rotate_with(rotation)
		local box_z = Vector3(0, 0, shape_values.height * 0.5):rotate_with(rotation)
		find_params = {
			"obb",
			shape_values.position,
			box_x,
			box_y,
			box_z,
			slot_mask
		}
	elseif shape_type == "cylinder" then
		local center = shape_values.position
		local half_z = Vector3(0, 0, shape_values.height * 0.5):rotate_with(rotation)
		local base = center - half_z
		local tip = center + half_z
		find_params = {
			"cylinder",
			base,
			tip,
			shape_values.radius,
			slot_mask
		}
	end

	if self._values.test_type == "unit_position" then
		return World:find_units_quick(unpack(find_params))
	elseif self._values.test_type == "intersect" then
		return World:find_units("intersect", unpack(find_params))
	end
end

function ElementAreaDespawn:on_executed(instigator)
	if not self._values.enabled or #self._values.slots == 0 then
		return
	end

	for _, shape_element in ipairs(self._shape_elements) do
		for _, unit in ipairs(self:_find_units_in_shape(shape_element)) do
			if alive(unit) then
				unit:set_slot(0)
			end
		end
	end

	ElementAreaDespawn.super.on_executed(self, instigator)
end

function ElementAreaDespawn:save(data)
	data.enabled = self._values.enabled
end

function ElementAreaDespawn:load(data)
	self:set_enabled(data.enabled)
end
