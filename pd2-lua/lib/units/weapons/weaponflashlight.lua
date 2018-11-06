WeaponFlashLight = WeaponFlashLight or class(WeaponGadgetBase)
WeaponFlashLight.GADGET_TYPE = "flashlight"

function WeaponFlashLight:init(unit)
	WeaponFlashLight.super.init(self, unit)

	self._on_event = "gadget_flashlight_on"
	self._off_event = "gadget_flashlight_off"
	self._a_flashlight_obj = self._unit:get_object(Idstring("a_flashlight"))
	local is_haunted = self:is_haunted()
	self._g_light = self._unit:get_object(Idstring("g_light"))
	local texture = is_haunted and "units/lights/spot_light_projection_textures/spotprojection_22_flashlight_df" or "units/lights/spot_light_projection_textures/spotprojection_11_flashlight_df"
	self._light = World:create_light("spot|specular|plane_projection", texture)
	self._light_multiplier = is_haunted and 2 or 2
	self._current_light_multiplier = self._light_multiplier

	self._light:set_spot_angle_end(60)
	self._light:set_far_range(is_haunted and 10000 or 1000)
	self._light:set_multiplier(self._current_light_multiplier)
	self._light:link(self._a_flashlight_obj)
	self._light:set_rotation(Rotation(self._a_flashlight_obj:rotation():z(), -self._a_flashlight_obj:rotation():x(), -self._a_flashlight_obj:rotation():y()))
	self._light:set_enable(false)

	local effect_path = is_haunted and "effects/particles/weapons/flashlight_spooky/fp_flashlight" or "effects/particles/weapons/flashlight/fp_flashlight_multicolor"
	self._light_effect = World:effect_manager():spawn({
		force_synch = true,
		effect = Idstring(effect_path),
		parent = self._a_flashlight_obj
	})

	World:effect_manager():set_hidden(self._light_effect, true)
end

function WeaponFlashLight:is_haunted()
	local job_id = managers.job and managers.job:current_job_id()
	local tweak = job_id and tweak_data.narrative.jobs[job_id]

	return tweak and tweak.is_halloween_level
end

function WeaponFlashLight:set_npc()
	if self._light_effect then
		World:effect_manager():kill(self._light_effect)
	end

	local obj = self._unit:get_object(Idstring("a_flashlight"))
	local is_haunted = self:is_haunted()
	local effect_path = is_haunted and "effects/particles/weapons/flashlight_spooky/flashlight" or "effects/particles/weapons/flashlight/flashlight_multicolor"
	self._light_effect = World:effect_manager():spawn({
		effect = Idstring(effect_path),
		parent = obj
	})

	World:effect_manager():set_hidden(self._light_effect, true)

	self._is_npc = true
end

function WeaponFlashLight:_check_state(current_state)
	WeaponFlashLight.super._check_state(self, current_state)
	self._light:set_enable(self._on)
	self._g_light:set_visibility(self._on)
	World:effect_manager():set_hidden(self._light_effect, not self._on)

	self._is_haunted = self:is_haunted()

	self._unit:set_extension_update_enabled(Idstring("base"), self._on)
end

function WeaponFlashLight:destroy(unit)
	WeaponFlashLight.super.destroy(self, unit)

	if alive(self._light) then
		World:delete_light(self._light)
	end

	if self._light_effect then
		World:effect_manager():kill(self._light_effect)

		self._light_effect = nil
	end
end

local mvec1 = Vector3()
local mrot1 = Rotation()
local mrot2 = Rotation()
WeaponFlashLight.HALLOWEEN_FLICKER = 1
WeaponFlashLight.HALLOWEEN_LAUGHTER = 2
WeaponFlashLight.HALLOWEEN_FROZEN = 3
WeaponFlashLight.HALLOWEEN_SPOOC = 4
WeaponFlashLight.HALLOWEEN_WARP = 5

function WeaponFlashLight:sync_net_event(event_id)
	if not self:is_haunted() then
		return
	end

	local t = Application:time()

	if event_id == self.HALLOWEEN_FLICKER then
		self._flicker_t = math.random(3) + math.rand(1)
	elseif event_id == self.HALLOWEEN_LAUGHTER then
		self._laughter_t = 2
	elseif event_id == self.HALLOWEEN_FROZEN then
		World:effect_manager():set_frozen(self._light_effect, true)

		self._frozen_t = t + 2.5

		self._light:set_local_rotation(self._light:rotation())
		self._light:set_local_position(self._light:position())
		self._light:unlink()
	elseif event_id == self.HALLOWEEN_SPOOC then
		if not self._is_npc then
			managers.player:on_hallowSPOOCed()
		end
	elseif event_id == self.HALLOWEEN_WARP then
		self._light_speed = math.random(30) + 15
	end
end

function WeaponFlashLight:update(unit, t, dt)
	mrotation.set_xyz(mrot1, self._a_flashlight_obj:rotation():z(), -self._a_flashlight_obj:rotation():x(), -self._a_flashlight_obj:rotation():y())

	if not self._is_haunted then
		self._light:link(self._a_flashlight_obj)
		self._light:set_rotation(mrot1)

		return
	end

	t = Application:time()

	self:update_flicker(t, dt)
	self:update_laughter(t, dt)
	self:update_frozen(t, dt)

	if not self._frozen_t then
		self._light_speed = self._light_speed or 1
		self._light_speed = math.step(self._light_speed, 1, dt * (math.random(4) + 2))
		self._light_rotation = (self._light_rotation or 0) + dt * -50 * self._light_speed

		mrotation.set_yaw_pitch_roll(mrot2, self._light_rotation, mrotation.pitch(mrot2), mrotation.roll(mrot2))
		mrotation.multiply(mrot1, mrot2)
		self._light:link(self._a_flashlight_obj)
		self._light:set_rotation(mrot1)
	end

	if not self._kittens_timer then
		self._kittens_timer = t + 25
	end

	if self._kittens_timer < t then
		if math.rand(1) < 0.75 then
			self:run_net_event(self.HALLOWEEN_FLICKER)

			self._kittens_timer = t + math.random(10) + 5
		elseif math.rand(1) < 0.35 then
			self:run_net_event(self.HALLOWEEN_WARP)

			self._kittens_timer = t + math.random(12) + 3
		elseif math.rand(1) < 0.3 then
			self:run_net_event(self.HALLOWEEN_FROZEN)

			self._kittens_timer = t + math.random(20) + 30
		elseif math.rand(1) < 0.25 then
			self:run_net_event(self.HALLOWEEN_LAUGHTER)

			self._kittens_timer = t + math.random(5) + 8
		elseif math.rand(1) < 0.15 then
			self:run_net_event(self.HALLOWEEN_SPOOC)

			self._kittens_timer = t + math.random(2) + 3
		else
			self._kittens_timer = t + math.random(5) + 3
		end
	end
end

function WeaponFlashLight:run_net_event(event_id)
	self:sync_net_event(event_id)
end

function WeaponFlashLight:update_flicker(t, dt)
	if self._flicker_t then
		self._flicker_t = math.max(0, self._flicker_t - dt)

		if self._flicker_t > 0.15 then
			self._current_light_multiplier = math.clamp(self._current_light_multiplier + (math.rand(40) - 20) * dt, 0, 5)
		else
			self._current_light_multiplier = math.lerp(self._current_light_multiplier, self._light_multiplier, 1 - self._flicker_t * 4)
		end

		self._light:set_multiplier(self._current_light_multiplier)

		if self._flicker_t == 0 then
			self._flicker_t = nil
		end
	end
end

function WeaponFlashLight:update_laughter(t, dt)
	if self._laughter_t then
		self._laughter_t = math.max(0, self._laughter_t - dt)
		local math_sin = math.sin(self._laughter_t * 720)

		mvector3.set_static(mvec1, 1, 0.6 + math_sin * 0.4, 0.7 + math_sin * 0.3)
		self._light:set_color(mvec1)

		local math_sin = math.sin(self._laughter_t * 720) * math.sin(self._laughter_t * 90)
		local math_cos = math.cos(self._laughter_t * 720) * math.sin(self._laughter_t * 90)

		mvector3.set_static(mvec1, -math_cos * 25, 0, math_sin * 25)
		self._light:set_local_position(mvec1)

		if self._laughter_t == 0 then
			self._laughter_t = nil
		end
	end
end

function WeaponFlashLight:update_frozen(t, dt)
	if self._frozen_t and self._frozen_t <= t then
		local obj = self._unit:get_object(Idstring("a_flashlight"))

		World:effect_manager():set_frozen(self._light_effect, false)
		self._light:set_local_rotation(Rotation())
		self._light:set_local_position(Vector3())

		self._frozen_t = nil
	end
end

WeaponFlashLight.EFFECT_OPACITY_MAX = 16
WeaponFlashLight.NPC_GLOW_OPACITY_MAX = 100
WeaponFlashLight.NPC_CONE_OPACITY_MAX = 8

function WeaponFlashLight:set_color(color)
	if self:is_haunted() then
		return
	end

	if not color then
		return
	end

	local opacity_ids = Idstring("opacity")
	local col_vec = Vector3(color.r, color.g, color.b)

	self._light:set_color(col_vec)

	if self._is_npc then
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera r"), opacity_ids, opacity_ids, color.r * WeaponFlashLight.NPC_GLOW_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera g"), opacity_ids, opacity_ids, color.g * WeaponFlashLight.NPC_GLOW_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera b"), opacity_ids, opacity_ids, color.b * WeaponFlashLight.NPC_GLOW_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone r"), opacity_ids, opacity_ids, color.r * WeaponFlashLight.NPC_CONE_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone g"), opacity_ids, opacity_ids, color.g * WeaponFlashLight.NPC_CONE_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone b"), opacity_ids, opacity_ids, color.b * WeaponFlashLight.NPC_CONE_OPACITY_MAX)
	else
		local r_ids = Idstring("red")
		local g_ids = Idstring("green")
		local b_ids = Idstring("blue")

		World:effect_manager():set_simulator_var_float(self._light_effect, r_ids, r_ids, opacity_ids, color.r * WeaponFlashLight.EFFECT_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, g_ids, g_ids, opacity_ids, color.g * WeaponFlashLight.EFFECT_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, b_ids, b_ids, opacity_ids, color.b * WeaponFlashLight.EFFECT_OPACITY_MAX)
	end
end

function WeaponFlashLight:color()
	local col = self._light:color()

	return Color(col.x, col.y, col.z)
end
