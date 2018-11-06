HUDHitDirectionVR = HUDHitDirection or class("HUDHitDirectionVR needs HUDHitDirection!")
local __init = HUDHitDirection.init

function HUDHitDirectionVR:init(hud)
	local old_panel = hud.panel
	hud.panel = managers.hud:full_hmd_panel()

	__init(self, hud)

	hud.panel = old_panel
	local w, h = self._hud_panel:size()
	local size = h < w and w or h

	self._hit_direction_panel:set_size(size, size)
	self._hit_direction_panel:set_position(0, 0)
end

function HUDHitDirectionVR:_add_hit_indicator(damage_origin, damage_type, fixed_angle)
	damage_type = damage_type or HUDHitDirection.DAMAGE_TYPES.HEALTH
	local hit = self._hit_direction_panel:gradient({
		rotation = 0,
		visible = true
	})

	hit:set_center(self._hud_panel:w() * 0.5, self._hud_panel:h() * 0.5)

	local data = {
		duration = 0.8,
		origin = damage_origin,
		damage_type = damage_type,
		fixed_angle = fixed_angle
	}

	hit:animate(callback(self, self, "_animate"), data, callback(self, self, "_remove"))
end

function HUDHitDirectionVR:_get_indicator_intensity_multiplier(damage_type)
	if damage_type == HUDHitDirection.DAMAGE_TYPES.HEALTH and alive(managers.player:player_unit()) then
		return 1 + 1 - managers.player:player_unit():character_damage():health_ratio()
	end

	return 1
end

function HUDHitDirectionVR:_animate(indicator, data, remove_func)
	data.t = data.duration
	data.col_start = 0.7
	data.col = 0.4
	local intensity_multiplier = self:_get_indicator_intensity_multiplier(data.damage_type)

	while data.t > 0 do
		local dt = coroutine.yield()
		data.t = data.t - dt
		data.col = math.clamp(data.col - dt, 0, 1)

		if alive(indicator) then
			local color = self:_get_indicator_color(data.damage_type, data.col / data.col_start):with_alpha(0.5 * intensity_multiplier)

			indicator:set_gradient_points({
				0,
				color,
				0.5,
				color:with_alpha(0),
				1,
				color:with_alpha(0)
			})
			indicator:set_alpha(data.t / data.duration)

			if managers.player:player_unit() then
				local ply_camera = managers.player:player_unit():camera()

				if ply_camera then
					local target_vec = ply_camera:position() - data.origin
					local angle = data.fixed_angle or target_vec:to_polar_with_reference(ply_camera:forward(), math.UP).spin
					local rounded_angle = math.round(angle / 90) * 90

					indicator:set_rotation(270 - rounded_angle)
				end
			end
		end
	end

	remove_func(indicator, data)
end
