WeaponLaser = WeaponLaser or class(WeaponGadgetBase)
WeaponLaser.GADGET_TYPE = "laser"

function WeaponLaser:init(unit)
	WeaponLaser.super.init(self, unit)

	self._on_event = "gadget_laser_aim_on"
	self._off_event = "gadget_laser_aim_off"
	local obj = self._unit:get_object(Idstring("a_laser"))
	self._laser_obj = obj
	self._max_distance = 3000
	self._scale_distance = 1000
	self._g_laser = self._unit:get_object(Idstring("g_laser"))
	self._g_indicator = self._unit:get_object(Idstring("g_indicator"))
	self._spot_angle_end = 0
	self._light = World:create_light("spot|specular")

	self._light:set_spot_angle_end(3)
	self._light:set_far_range(75)
	self._light:set_near_range(40)
	self._light:link(obj)
	self._light:set_rotation(Rotation(obj:rotation():z(), -obj:rotation():x(), -obj:rotation():y()))

	self._themes = {
		default = {
			light = Vector3(0, 10, 0),
			glow = Vector3(0, 0.2, 0),
			brush = Color(0.05, 0, 1, 0)
		},
		cop_sniper = {
			light = Vector3(10, 0, 0),
			glow = Vector3(0.2, 0, 0),
			brush = Color(0.15, 1, 0, 0)
		},
		turret_module_active = {
			light = Vector3(10, 0, 0),
			glow = Vector3(0.2, 0, 0),
			brush = Color(0.15, 1, 0, 0)
		},
		turret_module_rearming = {
			light = Vector3(10, 0, 0),
			glow = Vector3(0.2, 0.2, 0),
			brush = Color(0.11, 1, 1, 0)
		},
		turret_module_mad = {
			light = Vector3(10, 0, 0),
			glow = Vector3(0, 0.2, 0),
			brush = Color(0.15, 0, 1, 0)
		}
	}
	self._theme_type = "default"
	self._light_color = Vector3()

	mvector3.set(self._light_color, self._themes[self._theme_type].light)
	self._light:set_color(self._light_color)
	self._light:set_enable(false)

	self._light_glow = World:create_light("spot|specular")

	self._light_glow:set_spot_angle_end(20)
	self._light_glow:set_far_range(75)
	self._light_glow:set_near_range(40)

	self._light_glow_color = Vector3()

	mvector3.set(self._light_glow_color, self._themes[self._theme_type].glow)
	self._light_glow:set_color(self._light_glow_color)
	self._light_glow:set_enable(false)
	self._light_glow:link(obj)
	self._light_glow:set_rotation(Rotation(obj:rotation():z(), -obj:rotation():x(), -obj:rotation():y()))

	self._slotmask = managers.slot:get_mask("bullet_impact_targets")
	self._brush = Draw:brush(self._themes[self._theme_type].brush, "VertexColor")

	self._brush:set_blend_mode("opacity_add")
end

function WeaponLaser:set_position(pos)
	self._custom_position = pos
end

function WeaponLaser:set_rotation(rot)
	self._custom_rotation = rot
end
local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec_l_dir = Vector3()

function WeaponLaser:update(unit, t, dt)
	local rotation = self._custom_rotation or self._laser_obj:rotation()

	mrotation.y(rotation, mvec_l_dir)

	local from = mvec1

	if self._custom_position then
		mvector3.set(from, self._laser_obj:local_position())
		mvector3.rotate_with(from, rotation)
		mvector3.add(from, self._custom_position)
	else
		mvector3.set(from, self._laser_obj:position())
	end

	local to = mvec2

	mvector3.set(to, mvec_l_dir)
	mvector3.multiply(to, self._max_distance)
	mvector3.add(to, from)

	local ray = self._unit:raycast("ray", from, to, "slot_mask", self._slotmask, self._ray_ignore_units and "ignore_unit" or nil, self._ray_ignore_units)

	if ray then
		if not self._is_npc then
			self._light:set_spot_angle_end(self._spot_angle_end)

			self._spot_angle_end = math.lerp(1, 18, ray.distance / self._max_distance)

			self._light_glow:set_spot_angle_end(math.lerp(8, 80, ray.distance / self._max_distance))

			local scale = (math.clamp(ray.distance, self._max_distance - self._scale_distance, self._max_distance) - (self._max_distance - self._scale_distance)) / self._scale_distance
			scale = 1 - scale

			self._light:set_multiplier(scale)
			self._light_glow:set_multiplier(scale * 0.1)
		end

		self._brush:cylinder(ray.position, from, self._is_npc and 0.5 or 0.25)

		local pos = mvec1

		mvector3.set(pos, mvec_l_dir)
		mvector3.multiply(pos, 50)
		mvector3.negate(pos)
		mvector3.add(pos, ray.position)
		self._light:set_final_position(pos)
		self._light_glow:set_final_position(pos)
	else
		self._light:set_final_position(to)
		self._light_glow:set_final_position(to)
		self._brush:cylinder(from, to, self._is_npc and 0.5 or 0.25)
	end

	self._custom_position = nil
	self._custom_rotation = nil
end

function WeaponLaser:_check_state(current_state)
	WeaponLaser.super._check_state(self, current_state)
	self._light:set_enable(self._on)
	self._light_glow:set_enable(self._on)
	self._g_laser:set_visibility(self._on)
	self._g_indicator:set_visibility(self._on)
	self._unit:set_extension_update_enabled(Idstring("base"), self._on)
end

function WeaponLaser:set_npc()
	self._is_npc = true
end

function WeaponLaser:destroy(unit)
	WeaponLaser.super.destroy(self, unit)

	if alive(self._light) then
		World:delete_light(self._light)
	end

	if alive(self._light_glow) then
		World:delete_light(self._light_glow)
	end
end

function WeaponLaser:set_color_by_theme(type)
	self._theme_type = type
	local theme = self._themes[type] or self._themes.default

	mvector3.set(self._light_color, theme.light)
	self._light:set_color(self._light_color)
	mvector3.set(self._light_glow_color, theme.glow)
	self._light_glow:set_color(self._light_glow_color)
	self._brush:set_color(theme.brush)
end

function WeaponLaser:theme_type()
	return self._theme_type
end

function WeaponLaser:set_color(color)
	if not color then
		return
	end

	self._color = color
	self._light_color = Vector3(color.r * 10, color.g * 10, color.b * 10)

	self._light:set_color(self._light_color)

	self._light_glow_color = Vector3(color.r * 0.2, color.g * 0.2, color.b * 0.2)

	self._light_glow:set_color(self._light_glow_color)
	self._brush:set_color(color)
end

function WeaponLaser:color()
	return self._color or tweak_data.custom_colors.defaults.laser
end

function WeaponLaser:set_max_distace(dis)
	self._max_distance = dis
end

function WeaponLaser:add_ray_ignore_unit(unit)
	self._ray_ignore_units = self._ray_ignore_units or {}

	table.insert(self._ray_ignore_units, unit)
end

