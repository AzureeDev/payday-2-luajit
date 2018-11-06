WaypointExt = WaypointExt or class()

function WaypointExt:init(unit)
	self._unit = unit
	WaypointExt.debug_ext = self
	self._is_active = false
end

function WaypointExt:destroy()
	self:remove_waypoint()
end

function WaypointExt:add_waypoint(icon_name, pos_z_offset, pos_locator, map_icon, show_on_hud)
	if self._is_active then
		self:remove_waypoint()
	end

	self._icon_name = icon_name or "pd2_goto"
	self._pos_z_offset = pos_z_offset and Vector3(0, 0, pos_z_offset) or Vector3(0, 0, 0)
	self._pos_locator = pos_locator
	self._map_icon = map_icon
	self._show_on_hud = show_on_hud
	local rotation = self._pos_locator and self._unit:get_object(Idstring(self._pos_locator)):rotation() or self._unit:rotation()
	local position = self._pos_locator and self._unit:get_object(Idstring(self._pos_locator)):position() or self._unit:position()
	position = position + self._pos_z_offset
	self._icon_pos = position
	self._icon_rot = rotation
	self._waypoint_data = {
		present_timer = 0,
		radius = 200,
		waypoint_origin = "waypoint_extension",
		blend_mode = "add",
		no_sync = true,
		waypoint_type = "unit_waypoint",
		icon = self._icon_name,
		map_icon = map_icon,
		unit = self._unit,
		position = position,
		rotation = rotation,
		color = Color(1, 1, 1),
		show_on_screen = show_on_hud or show_on_hud == nil and true
	}
	self._icon_id = tostring(self._unit:key())

	managers.hud:add_waypoint(self._icon_id, self._waypoint_data)
	self._unit:set_extension_update_enabled(Idstring("waypoint"), true)

	self._is_active = true
end

function WaypointExt:remove_waypoint()
	if self._icon_id then
		managers.hud:remove_waypoint(self._icon_id)

		self._icon_id = nil
		self._icon_pos = nil
		self._waypoint_data = nil
	end

	self._unit:set_extension_update_enabled(Idstring("waypoint"), false)

	self._is_active = false
end

function WaypointExt:update(t, dt)
	if self._icon_pos then
		local position = self._pos_locator and self._unit:get_object(Idstring(self._pos_locator)):position() or self._unit:position()
		position = position + self._pos_z_offset

		mvector3.set(self._icon_pos, position)

		local rotation = self._pos_locator and self._unit:get_object(Idstring(self._pos_locator)):rotation() or self._unit:rotation()

		mrotation.set_yaw_pitch_roll(self._icon_rot, rotation:yaw(), rotation:pitch(), rotation:roll())
	end
end

function WaypointExt:save(save_data)
	save_data.Waypoint = {
		active = self._is_active,
		icon_name = self._icon_name,
		pos_z_offset = self._pos_z_offset and self._pos_z_offset.z,
		pos_locator = self._pos_locator,
		map_icon = self._map_icon,
		show_on_hud = self._show_on_hud
	}
end

function WaypointExt:load(save_data)
	if save_data.Waypoint then
		if save_data.Waypoint.active and not self._is_active then
			local icon_name = save_data.Waypoint.icon_name
			local pos_z_offset = save_data.Waypoint.pos_z_offset
			local pos_locator = save_data.Waypoint.pos_locator
			local map_icon = save_data.Waypoint.map_icon
			local show_on_hud = save_data.Waypoint.show_on_hud

			self:add_waypoint(icon_name, pos_z_offset, pos_locator, map_icon, show_on_hud)
		elseif not save_data.Waypoint.active and self._is_active then
			self:remove_waypoint()
		end
	end
end
