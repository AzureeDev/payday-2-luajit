core:import("CoreEnvironmentEffectsManager")

local is_editor = Application:editor()
EnvironmentEffectsManager = EnvironmentEffectsManager or class(CoreEnvironmentEffectsManager.EnvironmentEffectsManager)

function EnvironmentEffectsManager:init()
	EnvironmentEffectsManager.super.init(self)
	self:add_effect("rain", RainEffect:new(tweak_data.env_effect.rain))
	self:add_effect("rain_only", RainEffect:new(tweak_data.env_effect.rain_only))
	self:add_effect("snow", RainEffect:new(tweak_data.env_effect.snow))
	self:add_effect("snow_slow", RainEffect:new(tweak_data.env_effect.snow_slow))

	if not _G.IS_VR then
		self:add_effect("raindrop_screen", RainDropScreenEffect:new())
	end

	self:add_effect("lightning", LightningEffect:new(tweak_data.env_effect.lightning))
	self:add_effect("lightning_tag", LightningEffect:new(tweak_data.env_effect.lightning_tag))

	self._camera_position = Vector3()
	self._camera_rotation = Rotation()
end

function EnvironmentEffectsManager:set_active_effects(effects)
	for effect_name, effect in pairs(self._effects) do
		if not table.contains(effects, effect_name) then
			if table.contains(self._current_effects, effect) then
				effect:stop()
				table.delete(self._current_effects, effect)
			end
		else
			self:use(effect_name)
		end
	end
end

function EnvironmentEffectsManager:update(t, dt)
	self._camera_position = managers.viewport:get_current_camera_position()
	self._camera_rotation = managers.viewport:get_current_camera_rotation()

	EnvironmentEffectsManager.super.update(self, t, dt)
end

function EnvironmentEffectsManager:camera_position()
	return self._camera_position
end

function EnvironmentEffectsManager:camera_rotation()
	return self._camera_rotation
end

EnvironmentEffect = EnvironmentEffect or class()

function EnvironmentEffect:init(default)
	self._default = default
end

function EnvironmentEffect:load_effects()
end

function EnvironmentEffect:update(t, dt)
end

function EnvironmentEffect:start()
end

function EnvironmentEffect:stop()
end

function EnvironmentEffect:default()
	return self._default
end

RainEffect = RainEffect or class(EnvironmentEffect)
local ids_rain_post_processor = Idstring("rain_post_processor")
local ids_rain_ripples = Idstring("rain_ripples")
local ids_rain_off = Idstring("rain_off")

function RainEffect:init(effect_data)
	EnvironmentEffect.init(self)

	self._effect_data = effect_data or {}
	self._effect_name = self._effect_data.effect_name or Idstring("effects/particles/rain/rain_01_a")
	self._ripples = self._effect_data.ripples
end

function RainEffect:load_effects()
	if is_editor then
		CoreEngineAccess._editor_load(Idstring("effect"), self._effect_name)
	end
end

function RainEffect:update(t, dt)
	if self._ripples then
		local vp = managers.viewport:first_active_viewport()

		if vp and self._vp ~= vp then
			vp:vp():set_post_processor_effect("World", ids_rain_post_processor, ids_rain_ripples)

			if alive(self._vp) then
				self._vp:vp():set_post_processor_effect("World", ids_rain_post_processor, ids_rain_off)
			end

			self._vp = vp
		end
	end

	local c_rot = managers.environment_effects:camera_rotation()

	if not c_rot then
		return
	end

	local c_pos = managers.environment_effects:camera_position()

	if not c_pos then
		return
	end

	World:effect_manager():move_rotate(self._effect, c_pos, c_rot)
end

function RainEffect:start()
	self._effect = World:effect_manager():spawn({
		effect = self._effect_name,
		position = Vector3(),
		rotation = Rotation()
	})
end

function RainEffect:stop()
	World:effect_manager():kill(self._effect)

	self._effect = nil

	if self._ripples and alive(self._vp) then
		self._vp:vp():set_post_processor_effect("World", ids_rain_post_processor, ids_rain_off)

		self._vp = nil
	end
end

LightningEffect = LightningEffect or class(EnvironmentEffect)

function LightningEffect:init(effect_data)
	EnvironmentEffect.init(self)

	self._effect_data = effect_data or {}
end

function LightningEffect:load_effects()
end

function LightningEffect:_update_wait_start()
	if Underlay:loaded() then
		self:start()
	end
end

function LightningEffect:_update(t, dt)
	if not self._started then
		return
	end

	if not self._sky_material or not self._sky_material:alive() then
		self._sky_material = Underlay:material(Idstring("sky"))
	end

	if self._flashing then
		self:_update_function(t, dt)
	end

	if self._sound_delay then
		self._sound_delay = self._sound_delay - dt

		if self._sound_delay <= 0 then
			self._sound_delay = nil
		end
	end

	self._next = self._next - dt

	if self._next <= 0 then
		self:_set_lightning_values()
		self:_make_lightning()

		self._update_function = self._update_first

		self:_set_next_timer()

		self._flashing = true
	end
end

function LightningEffect:start()
	if not Underlay:loaded() then
		self.update = self._update_wait_start

		return
	end

	print("[LightningEffect] Start")

	self._started = true
	self.update = self._update
	self._sky_material = Underlay:material(Idstring("sky"))
	self._original_color0 = self._sky_material:get_variable(Idstring("color0"))
	self._original_light_color = Global._global_light:color()
	self._original_sun_horizontal = Underlay:time(Idstring("sun_horizontal"))
	self._min_interval = self._effect_data.min_interval or 2
	self._rnd_interval = self._effect_data.rnd_interval or 10
	self._sound_source = SoundDevice:create_source("thunder")

	self:_set_next_timer()
end

function LightningEffect:stop()
	print("[LightningEffect] Stop")

	self._started = false

	if self._soundsource then
		self._soundsource:stop()
		self._soundsource:delete()

		self._soundsource = nil
	end

	self:_set_original_values()
end

function LightningEffect:_update_first(t, dt)
	self._first_flash_time = self._first_flash_time - dt

	if self._first_flash_time <= 0 then
		self:_set_original_values()

		self._update_function = self._update_pause
	end
end

function LightningEffect:_update_pause(t, dt)
	self._pause_flash_time = self._pause_flash_time - dt

	if self._pause_flash_time <= 0 then
		self:_make_lightning()

		self._update_function = self._update_second
	end
end

function LightningEffect:_update_second(t, dt)
	self._second_flash_time = self._second_flash_time - dt

	if self._second_flash_time <= 0 then
		self:_set_original_values()

		self._flashing = false
	end
end

function LightningEffect:_set_original_values()
	if alive(self._sky_material) then
		self._sky_material:set_variable(Idstring("color0"), self._original_color0)
	end

	if self._original_light_color then
		Global._global_light:set_color(self._original_light_color)
	end

	if self._original_sun_horizontal then
		Underlay:set_time(Idstring("sun_horizontal"), self._original_sun_horizontal)
	end
end

function LightningEffect:_make_lightning()
	if alive(self._sky_material) then
		self._sky_material:set_variable(Idstring("color0"), self._intensity_value)
	end

	Global._global_light:set_color(self._intensity_value)
	Underlay:set_time(Idstring("sun_horizontal"), self._flash_anim_time)

	if self._effect_data.event_name then
		self._sound_source:post_event(self._effect_data.event_name)
	end
end

function LightningEffect:_set_lightning_values()
	self._original_color0 = self._sky_material:get_variable(Idstring("color0"))
	self._original_light_color = Global._global_light:color()
	self._original_sun_horizontal = Underlay:time(Idstring("sun_horizontal"))
	self._first_flash_time = 0.1
	self._pause_flash_time = 0.1
	self._second_flash_time = 0.3
	self._flash_roll = math.rand(360)
	self._flash_dir = Rotation(0, 0, self._flash_roll):y()
	self._flash_anim_time = math.rand(0, 1)
	self._distance = math.rand(1)
	self._intensity_value = math.lerp(Vector3(2, 2, 2), Vector3(5, 5, 5), self._distance)
	local c_pos = managers.environment_effects:camera_position()

	if c_pos then
		local sound_speed = 30000
		self._sound_delay = self._distance * 2

		if self._sound_source then
			self._sound_source:set_rtpc("lightning_distance", self._distance * 4000)
		end
	end
end

function LightningEffect:_set_next_timer()
	self._next = self._min_interval + math.rand(self._rnd_interval)
end

RainDropEffect = RainDropEffect or class(EnvironmentEffect)

function RainDropEffect:init()
	EnvironmentEffect.init(self)

	self._under_roof = false
	self._slotmask = managers.slot:get_mask("statics")
end

function RainDropEffect:load_effects()
	if is_editor then
		CoreEngineAccess._editor_load(Idstring("effect"), self._effect_name)
	end
end

function RainDropEffect:update(t, dt)
end

function RainDropEffect:start()
	local t = {
		effect = self._effect_name,
		position = Vector3(),
		rotation = Rotation()
	}
	self._raindrops = World:effect_manager():spawn(t)
end

function RainDropEffect:stop()
	if self._raindrops then
		World:effect_manager():fade_kill(self._raindrops)

		self._raindrops = nil
	end
end

RainDropScreenEffect = RainDropScreenEffect or class(RainDropEffect)

function RainDropScreenEffect:init()
	RainDropEffect.init(self)

	self._effect_name = Idstring("effects/particles/rain/raindrop_screen")
end

CoreClass.override_class(CoreEnvironmentEffectsManager.EnvironmentEffectsManager, EnvironmentEffectsManager)
