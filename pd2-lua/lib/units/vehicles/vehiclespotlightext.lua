VehicleSpotlightExt = VehicleSpotlightExt or class()
VehicleSpotlightExt.UP_VECTOR = Vector3(0, 0, 1)
VehicleSpotlightExt.SPOTLIGHT_NORMAL = Vector3(0, 1, 0)

function VehicleSpotlightExt:init(unit)
	self._unit = unit

	self._unit:set_extension_update_enabled(Idstring("vehicle_spotlight"), true)
	self:_init_tweak_data()
end

function VehicleSpotlightExt:_init_tweak_data()
	local spotlight_data = tweak_data.spotlights[self._tweak_data]
	self._wiggle = {
		x = {
			ang = math.random(spotlight_data.wiggle.ang[1] or 0, spotlight_data.wiggle.ang[2] or 0),
			speed = math.random(spotlight_data.wiggle.speed[1] or 0, spotlight_data.wiggle.speed[2] or 0)
		},
		y = {
			ang = math.random(spotlight_data.wiggle.ang[1] or 0, spotlight_data.wiggle.ang[2] or 0),
			speed = math.random(spotlight_data.wiggle.speed[1] or 0, spotlight_data.wiggle.speed[2] or 0)
		}
	}
	self._neutral_direction = spotlight_data.neutral_direction or Vector3(0, 0, 0)
	self._speed = spotlight_data.tracking_speed
	self._target_slot = spotlight_data.targetting.slot or 12
	self._target_search_t = spotlight_data.targetting.search_t or 3
	self._max_target_distance = spotlight_data.targetting.max_distance or 4000
	self._next_target_search_t = self._next_target_search_t or spotlight_data.targetting.search_t
	self._targetting_body = self._unit:get_object(Idstring(spotlight_data.targetting.body or "a_body"))
	self._target = nil
	self._objects = {}

	for _, name in ipairs(spotlight_data.objects) do
		local obj = self._unit:get_object(Idstring(name))

		if alive(obj) then
			table.insert(self._objects, {
				obj,
				Vector3()
			})
		end
	end
end

function VehicleSpotlightExt:update(unit, t, dt)
	self._next_target_search_t = self._next_target_search_t - dt

	if self._next_target_search_t <= 0 then
		self._next_target_search_t = self._target_search_t
		self._target = self:find_new_target()
	end

	local target_direction = nil
	target_direction = (not alive(self._target) or self._target:position()) and (self._neutral_direction or Vector3(0, 0, 0))

	for _, obj_pair in ipairs(self._objects) do
		local obj = obj_pair[1]
		local direction = obj_pair[2]
		local td = target_direction

		if alive(self._target) then
			td = target_direction - obj:position()
		end

		mvector3.lerp(direction, direction, td, dt * self._speed)

		local right = direction:cross(VehicleSpotlightExt.UP_VECTOR):normalized()
		local up = direction:cross(right):normalized()
		local ax = math.sin(t * self._wiggle.x.speed) * self._wiggle.x.ang
		local ay = math.cos(t * self._wiggle.y.speed) * self._wiggle.y.ang
		local rot = Rotation(direction, VehicleSpotlightExt.SPOTLIGHT_NORMAL)
		local offset_x = 0
		local offset_y = 0

		if type_name(obj) == "Light" then
			offset_y = 90
		end

		obj:set_rotation(rot * Rotation(ax + offset_x, ay + offset_y, 0))
	end
end

function VehicleSpotlightExt:find_new_target()
	local best_target = {
		nil,
		0
	}
	local potential_targets = World:find_units_quick("all", self._target_slot)

	for _, unit in ipairs(potential_targets) do
		local char_tweak = tweak_data.character[unit:base() and unit:base()._tweak_table]

		if char_tweak and char_tweak.spotlight_important then
			local weight = mvector3.distance_sq(unit:position(), self._targetting_body:position())

			if weight <= self._max_target_distance then
				weight = weight / self._max_target_distance * char_tweak.spotlight_important

				if best_target[2] < weight then
					best_target[1] = unit
					best_target[2] = weight
				end
			end
		end
	end

	return best_target[1]
end
