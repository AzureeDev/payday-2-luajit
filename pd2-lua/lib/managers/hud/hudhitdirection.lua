HUDHitDirection = HUDHitDirection or class()
HUDHitDirection.UNIT_TYPE_HIT_PLAYER = 1
HUDHitDirection.UNIT_TYPE_HIT_VEHICLE = 2
HUDHitDirection.DAMAGE_TYPES = {
	HEALTH = 1,
	ARMOUR = 2,
	VEHICLE = 3
}
HUDHitDirection.PANEL_SIZE = 300

function HUDHitDirection:init(hud)
	self._hud_panel = hud.panel
	self._unit_type_hit = HUDHitDirection.UNIT_TYPE_HIT_PLAYER

	if self._hud_panel:child("hit_direction_panel") then
		self._hud_panel:remove(self._hud_panel:child("hit_direction_panel"))
	end

	self._hit_direction_panel = self._hud_panel:panel({
		halign = "center",
		name = "hit_direction_panel",
		visible = true,
		layer = -5,
		valign = "center",
		w = HUDHitDirection.PANEL_SIZE,
		h = HUDHitDirection.PANEL_SIZE
	})

	self._hit_direction_panel:set_center(self._hit_direction_panel:parent():w() * 0.5, self._hit_direction_panel:parent():h() * 0.5)
end

function HUDHitDirection:on_hit_direction(origin, damage_type, fixed_angle)
	self:_add_hit_indicator(origin or Vector3(0, 0, 0), damage_type, fixed_angle)
end

function HUDHitDirection:_add_hit_indicator(damage_origin, damage_type, fixed_angle)
	damage_type = damage_type or HUDHitDirection.DAMAGE_TYPES.HEALTH
	local hit = self._hit_direction_panel:bitmap({
		texture = "guis/textures/pd2/hitdirection",
		blend_mode = "add",
		alpha = 1,
		visible = true,
		rotation = 0,
		color = Color.white
	})

	hit:set_center(HUDHitDirection.PANEL_SIZE * 0.5, HUDHitDirection.PANEL_SIZE * 0.5)

	local data = {
		duration = 0.8,
		origin = damage_origin,
		damage_type = damage_type,
		bitmap = hit,
		fixed_angle = fixed_angle
	}

	hit:animate(callback(self, self, "_animate"), data, callback(self, self, "_remove"))
end

function HUDHitDirection:_get_indicator_color(damage_type, t)
	if damage_type == HUDHitDirection.DAMAGE_TYPES.HEALTH then
		return Color(1, t, t)
	elseif damage_type == HUDHitDirection.DAMAGE_TYPES.ARMOUR then
		return Color(t, 0.8, 1)
	elseif damage_type == HUDHitDirection.DAMAGE_TYPES.VEHICLE then
		return Color(1, 0.8, t)
	else
		return Color(1, t, t)
	end
end

function HUDHitDirection:_animate(indicator, data, remove_func)
	data.t = data.duration
	data.col_start = 0.7
	data.col = 0.4

	while data.t > 0 do
		local dt = coroutine.yield()
		data.t = data.t - dt
		data.col = math.clamp(data.col - dt, 0, 1)

		if alive(indicator) then
			indicator:set_color(self:_get_indicator_color(data.damage_type, data.col / data.col_start))
			indicator:set_alpha(data.t / data.duration)

			if managers.player:player_unit() then
				local ply_camera = managers.player:player_unit():camera()

				if ply_camera then
					local target_vec = ply_camera:position() - data.origin
					local angle = target_vec:to_polar_with_reference(ply_camera:forward(), math.UP).spin
					local r = HUDHitDirection.PANEL_SIZE * 0.4

					if data.fixed_angle ~= nil then
						angle = data.fixed_angle
					end

					indicator:set_rotation(90 - angle)
					indicator:set_center(HUDHitDirection.PANEL_SIZE * 0.5 - math.sin(angle + 180) * r, HUDHitDirection.PANEL_SIZE * 0.5 - math.cos(angle + 180) * r)
				end
			end
		end
	end

	remove_func(indicator, data)
end

function HUDHitDirection:_remove(indicator, data)
	self._hit_direction_panel:remove(indicator)
end

if _G.IS_VR then
	require("lib/managers/hud/vr/HUDHitDirectionVR")
end
