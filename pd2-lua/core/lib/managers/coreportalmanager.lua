core:module("CorePortalManager")
core:import("CoreShapeManager")

PortalManager = PortalManager or class()
PortalManager.EFFECT_MANAGER = World:effect_manager()

function PortalManager:init()
	self._portal_shapes = {}
	self._all_units = {}
	self._all_effects = {}
	self._unit_groups = {}
	self._check_positions = {}
	self._hide_list = {}
	self._deactivate_funtion = callback(self, self, "unit_deactivated")
end

function PortalManager:clear()
	for _, portal in ipairs(self._portal_shapes) do
		portal:show_all()
	end

	self._portal_shapes = {}
	self._all_units = {}
	self._unit_groups = {}
	self._hide_list = {}
end

function PortalManager:pseudo_reset()
	for _, unit in ipairs(managers.editor:layer("Statics"):created_units()) do
		if alive(unit) then
			unit:unit_data()._visibility_counter = 0
		end
	end

	for _, group in pairs(self._unit_groups) do
		group._is_inside = false

		for _, unit in ipairs(managers.editor:layer("Statics"):created_units()) do
			if group._ids[unit:unit_data().unit_id] and alive(unit) then
				unit:set_visible(true)

				unit:unit_data()._visibility_counter = 0
			end
		end
	end
end

function PortalManager:add_portal(polygon_tbl, min, max)
	cat_print("portal", "add_portal", #polygon_tbl)

	if #polygon_tbl > 0 then
		table.insert(self._portal_shapes, PortalShape:new(polygon_tbl, min, max))
	end
end

function PortalManager:add_unit(unit)
	if unit:unit_data().ignore_portal then
		return
	end

	local added = nil

	for _, group in pairs(self._unit_groups) do
		added = group:add_unit(unit) or added
	end

	if added then
		return
	end

	for _, portal in ipairs(self._portal_shapes) do
		local added, amount = portal:add_unit(unit)

		if added then
			self._all_units[unit:key()] = (self._all_units[unit:key()] or 0) + amount
			local inverse = unit:unit_data().portal_visible_inverse
			local i = 0

			if not portal:is_inside() then
				if inverse then
					i = 1
				else
					i = -1
				end
			end

			self:change_visibility(unit, i, inverse)
		end
	end
end

function PortalManager:remove_dynamic_unit(unit)
	self:remove_unit(unit)

	local check_body = unit:body(unit:orientation_object()) or unit:body(0)

	if alive(check_body) then
		check_body:set_activate_tag("dynamic_portal")
		check_body:set_deactivate_tag("dynamic_portal")
	end

	unit:add_body_activation_callback(self._deactivate_funtion)
end

function PortalManager:unit_deactivated(tag, unit, body, activated)
	if not activated then
		cat_print("portal", "should add unit here", tag, unit, body, activated)
		self:add_unit(unit)
		unit:remove_body_activation_callback(self._deactivate_funtion)
	end
end

function PortalManager:remove_unit(unit)
	cat_print("portal", "remove_unit", unit, unit:visible())

	self._all_units[unit:key()] = nil

	for _, portal in ipairs(self._portal_shapes) do
		portal:remove_unit(unit)
	end

	unit:set_visible(true)
end

function PortalManager:delete_unit(unit)
	for name, group in pairs(self._unit_groups) do
		group:remove_unit_id(unit)
	end
end

function PortalManager:change_visibility(unit, i, inverse)
	self._all_units[unit:key()] = self._all_units[unit:key()] + i

	if self._all_units[unit:key()] == 0 then
		unit:set_visible(inverse ~= false)
	elseif not unit:visible() ~= inverse then
		unit:set_visible(inverse ~= true)
	end
end

function PortalManager:add_effect(effect)
	effect.id = self.EFFECT_MANAGER:spawn(effect)
	self._all_effects[effect] = 0

	for _, portal in ipairs(self._portal_shapes) do
		local added, amount = portal:add_effect(effect)

		if added then
			self._all_effects[effect] = self._all_effects[effect] + amount
		end
	end
end

function PortalManager:change_effect_visibility(effect, i)
	self._all_effects[effect] = self._all_effects[effect] + i

	if self._all_effects[effect] == 0 then
		effect.hidden = true

		self.EFFECT_MANAGER:set_frozen(effect.id, true)
		self.EFFECT_MANAGER:set_hidden(effect.id, true)
	elseif effect.hidden then
		effect.hidden = false

		self.EFFECT_MANAGER:set_frozen(effect.id, false)
		self.EFFECT_MANAGER:set_hidden(effect.id, false)
	end
end

function PortalManager:restart_effects()
	for _, portal in ipairs(self._portal_shapes) do
		portal:clear_effects()
	end

	local restart = {}

	for e, n in pairs(self._all_effects) do
		restart[e] = n
	end

	self._all_effects = {}

	for effect, _ in pairs(restart) do
		if effect.id then
			self.EFFECT_MANAGER:kill(effect.id)
		end

		self:add_effect(effect)
	end

	restart = nil
end

function PortalManager:render()
	for _, portal in ipairs(self._portal_shapes) do
		portal:update(TimerManager:wall():time(), TimerManager:wall():delta_time())
	end

	for _, group in pairs(self._unit_groups) do
		group:update(TimerManager:wall():time(), TimerManager:wall():delta_time())
	end

	local unit_id, unit = next(self._hide_list)

	if alive(unit) then
		unit:set_visible(false)

		self._hide_list[unit_id] = nil
	end

	while table.remove(self._check_positions) do
	end
end

function PortalManager:add_to_hide_list(unit)
	self._hide_list[unit:unit_data().unit_id] = unit
end

function PortalManager:remove_from_hide_list(unit)
	self._hide_list[unit:unit_data().unit_id] = nil
end

function PortalManager:debug_draw_border(polygon, min, max)
	local step = 500
	local time = 10
	local tbl = polygon:to_table()

	for x = 2, #tbl, 1 do
		local length = 0

		while time > length do
			if min and max then
				local start = Vector3(tbl[x - 1].x, tbl[x - 1].y, max)
				local stop = Vector3(tbl[x].x, tbl[x].y, max)
				local stop_vertical = Vector3(tbl[x - 1].x, tbl[x - 1].y, min)

				Application:draw_line(start, stop, 1, 0, 0)
				Application:draw_line(start, stop_vertical, 0, 1, 0)
			else
				local start = Vector3(tbl[x - 1].x, tbl[x - 1].y, step * length)
				local stop = Vector3(tbl[x].x, tbl[x].y, step * length)
				local stop_vertical = Vector3(tbl[x - 1].x, tbl[x - 1].y, step * (length + 1))

				Application:draw_line(start, stop, 1, 0, 0)
				Application:draw_line(start, stop_vertical, 0, 1, 0)
			end

			length = length + 1
		end
	end
end

function PortalManager:unit_groups()
	return self._unit_groups
end

function PortalManager:unit_group_on_shape(in_shape)
	for _, group in pairs(self._unit_groups) do
		for _, shape in ipairs(group:shapes()) do
			if shape == in_shape then
				return group
			end
		end
	end
end

function PortalManager:rename_unit_group(name, new_name)
	if self._unit_groups[new_name] then
		return false
	end

	local group = self._unit_groups[name]
	self._unit_groups[name] = nil
	self._unit_groups[new_name] = group

	group:rename(new_name)

	return true
end

function PortalManager:unit_group(name)
	return self._unit_groups[name]
end

function PortalManager:add_unit_group(name)
	local group = PortalUnitGroup:new(name)
	self._unit_groups[name] = group

	return group
end

function PortalManager:remove_unit_group(name)
	self._unit_groups[name] = nil
end

function PortalManager:clear_unit_groups()
	self._unit_groups = {}
end

function PortalManager:group_name()
	local name = "group"
	local i = 1

	while self._unit_groups[name .. i] do
		i = i + 1
	end

	return name .. i
end

function PortalManager:check_positions()
	if #self._check_positions > 0 then
		return self._check_positions
	end

	for _, vp in ipairs(managers.viewport:all_really_active_viewports()) do
		local camera = vp:camera()

		if alive(camera) and vp:is_rendering_scene("World") then
			table.insert(self._check_positions, camera:position())
		end
	end

	return self._check_positions
end

function PortalManager:unit_in_any_unit_group(unit)
	for name, group in pairs(self._unit_groups) do
		if group:unit_in_group(unit) then
			return true
		end
	end

	return false
end

function PortalManager:save(t)
	local t = t or ""
	local s = ""

	for name, group in pairs(self._unit_groups) do
		s = s .. t .. "\t<unit_group name=\"" .. name .. "\">\n"

		for _, shape in ipairs(group:shapes()) do
			s = s .. shape:save(t .. "\t\t") .. "\n"
		end

		s = s .. t .. "\t</unit_group>\n"
	end

	return s
end

function PortalManager:save_level_data()
	local t = {}

	for name, group in pairs(self._unit_groups) do
		local shapes = {}

		for _, shape in ipairs(group:shapes()) do
			table.insert(shapes, shape:save_level_data())
		end

		t[name] = {
			shapes = shapes,
			ids = group:ids()
		}
	end

	return t
end

PortalShape = PortalShape or class()

function PortalShape:init(polygon_tbl, min, max)
	self._polygon = ScriptPolygon2D(polygon_tbl)
	self._units = {}
	self._inverse_units = {}
	self._effects = {}
	self._is_inside = true
	self._min = min
	self._max = max
end

function PortalShape:add_unit(unit)
	if self:inside(unit:position()) then
		self._units[unit:key()] = unit
		local inverse = unit:unit_data().portal_visible_inverse

		if inverse then
			unit:set_visible(false)
		end

		return true, inverse and -1 or 1, self
	end
end

function PortalShape:remove_unit(unit)
	self._units[unit:key()] = nil
end

function PortalShape:add_effect(effect)
	if self:inside(effect.position) then
		table.insert(self._effects, effect)

		return true, 1
	end
end

function PortalShape:clear_effects()
	self._effects = {}
end

function PortalShape:show_all()
	for _, unit in pairs(self._units) do
		if alive(unit) then
			unit:set_visible(true)
		end
	end
end

function PortalShape:inside(pos)
	local is_inside = self._polygon:inside(pos)

	if is_inside and self._min and self._max then
		local z = pos.z

		if self._min < z and z < self._max then
			return true
		else
			return false
		end
	end

	return is_inside
end

function PortalShape:is_inside()
	return self._is_inside
end

function PortalShape:update(time, rel_time)
	local is_inside = false

	for _, pos in ipairs(managers.portal:check_positions()) do
		is_inside = self:inside(pos)

		if is_inside then
			break
		end
	end

	if self._is_inside ~= is_inside then
		self._is_inside = is_inside

		for _, unit in pairs(self._units) do
			self:_change_visibility(unit)
		end

		for _, effect in ipairs(self._effects) do
			local i = self._is_inside and 1 or -1

			managers.portal:change_effect_visibility(effect, i)
		end
	end
end

function PortalShape:_change_visibility(unit)
	if alive(unit) then
		local inverse = unit:unit_data().portal_visible_inverse
		local i = self._is_inside ~= inverse and 1 or -1

		managers.portal:change_visibility(unit, i, inverse)
	end
end

PortalUnitGroup = PortalUnitGroup or class()

function PortalUnitGroup:init(name)
	self._name = name
	self._shapes = {}
	self._ids = {}
	self._r = 0.5 + math.rand(0.5)
	self._g = 0.5 + math.rand(0.5)
	self._b = 0.5 + math.rand(0.5)
	self._units = {}
	self._is_inside = false
end

function PortalUnitGroup:rename(new_name)
	self._name = new_name
end

function PortalUnitGroup:name()
	return self._name
end

function PortalUnitGroup:shapes()
	return self._shapes
end

function PortalUnitGroup:ids()
	return self._ids
end

function PortalUnitGroup:set_ids(ids)
	self._ids = ids or self._ids
end

function PortalUnitGroup:add_shape(params)
	local shape = PortalUnitGroupShape:new(params)

	table.insert(self._shapes, shape)

	return shape
end

function PortalUnitGroup:remove_shape(shape)
	shape:destroy()
	table.delete(self._shapes, shape)
end

function PortalUnitGroup:add_unit(unit)
	if self._ids[unit:unit_data().unit_id] then
		unit:unit_data()._visibility_counter = unit:unit_data()._visibility_counter or 0

		self:_change_visibility(unit, self._is_inside and 1 or 0)
		table.insert(self._units, unit)

		return true
	end

	return false
end

function PortalUnitGroup:add_unit_id(unit)
	if self._ids[unit:unit_data().unit_id] then
		self:remove_unit_id(unit)

		return
	end

	self._ids[unit:unit_data().unit_id] = true
end

function PortalUnitGroup:remove_unit_id(unit)
	self._ids[unit:unit_data().unit_id] = nil
end

function PortalUnitGroup:lock_units()
	for slot4, slot5 in ipairs(self._units) do
	end
end

function PortalUnitGroup:inside(pos)
	for _, shape in ipairs(self._shapes) do
		if shape:is_inside(pos) then
			return true
		end
	end

	return false
end

function PortalUnitGroup:update(t, dt)
	local is_inside = false

	for _, pos in ipairs(managers.portal:check_positions()) do
		is_inside = self:inside(pos)

		if is_inside then
			break
		end
	end

	if self._is_inside ~= is_inside then
		self._is_inside = is_inside
		local diff = self._is_inside and 1 or -1

		self:_change_units_visibility(diff)
	end
end

function PortalUnitGroup:_change_units_visibility(diff)
	for _, unit in pairs(self._units) do
		self:_change_visibility(unit, diff)
	end
end

function PortalUnitGroup:_change_units_visibility_in_editor(diff)
	for _, unit in ipairs(managers.editor:layer("Statics"):created_units()) do
		if self._ids[unit:unit_data().unit_id] then
			self:_change_visibility(unit, diff)
		end
	end
end

function PortalUnitGroup:_change_visibility(unit, diff)
	if alive(unit) then
		unit:unit_data()._visibility_counter = unit:unit_data()._visibility_counter + diff

		if unit:unit_data()._visibility_counter > 0 then
			unit:set_visible(true)
			managers.portal:remove_from_hide_list(unit)
		else
			managers.portal:add_to_hide_list(unit)
		end
	end
end

function PortalUnitGroup:unit_in_group(unit)
	return self._ids[unit:unit_data().unit_id] and true or false
end

function PortalUnitGroup:draw(t, dt, mul, skip_shapes, skip_units)
	local r = self._r * mul
	local g = self._g * mul
	local b = self._b * mul
	local brush = Draw:brush()

	brush:set_color(Color(0.25, r, g, b))

	if not skip_units then
		for _, unit in ipairs(managers.editor:layer("Statics"):created_units()) do
			if self._ids[unit:unit_data().unit_id] then
				brush:unit(unit)
				Application:draw(unit, r, g, b)
			end
		end
	end

	if not skip_shapes then
		for _, shape in ipairs(self._shapes) do
			shape:draw(t, dt, r, g, b)
			shape:draw_outline(t, dt, r / 2, g / 2, b / 2)
		end
	end
end

PortalUnitGroupShape = PortalUnitGroupShape or class(CoreShapeManager.ShapeBox)

function PortalUnitGroupShape:init(params)
	params.type = "box"

	PortalUnitGroupShape.super.init(self, params)
end

function PortalUnitGroupShape:draw(t, dt, r, g, b)
	PortalUnitGroupShape.super.draw(self, t, dt, r, g, b)

	if alive(self._unit) then
		Application:draw(self._unit, r, g, b)
	end
end
