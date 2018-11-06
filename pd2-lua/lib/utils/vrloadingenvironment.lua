VRLoadingEnvironment = VRLoadingEnvironment or class()
VRLoadingEnvironment.STATE_START = 1
VRLoadingEnvironment.STATE_STOP = 2
VRLoadingEnvironment.STATE_RESUME = 3
VRLoadingEnvironment.STATE_FADEIN = 4
VRLoadingEnvironment.STATE_NONE = 5

function VRLoadingEnvironment:init(overlays)
	if overlays then
		self._overlays = overlays
	else
		if not rawget(_G, "Global") then
			self._states = {}

			return
		end

		Global.__vr_overlays = Global.__vr_overlays or {}
		self._overlays = Global.__vr_overlays
	end

	self._states = {
		[VRLoadingEnvironment.STATE_START] = {
			enter = callback(self, self, "_start_enter"),
			exit = callback(self, self, "_start_exit"),
			update = callback(self, self, "_start_update")
		},
		[VRLoadingEnvironment.STATE_STOP] = {
			enter = callback(self, self, "_stop_enter"),
			exit = callback(self, self, "_stop_exit"),
			update = callback(self, self, "_stop_update")
		},
		[VRLoadingEnvironment.STATE_FADEIN] = {
			enter = callback(self, self, "_fadein_enter"),
			exit = callback(self, self, "_fadein_exit"),
			update = callback(self, self, "_fadein_update")
		},
		[VRLoadingEnvironment.STATE_RESUME] = {
			no_timer = true,
			enter = callback(self, self, "_resume_enter"),
			exit = callback(self, self, "_resume_exit"),
			update = callback(self, self, "_resume_update")
		},
		[VRLoadingEnvironment.STATE_NONE] = {}
	}
	self._block_exec = false
	self._current_state = nil
	self._fade_black_t = 1
	self._fade_in_t = 1

	self:change_state(VRLoadingEnvironment.STATE_NONE)
end

function VRLoadingEnvironment:force_start()
	self:change_state(VRLoadingEnvironment.STATE_START)
end

function VRLoadingEnvironment:start(params)
	if self._current_state ~= VRLoadingEnvironment.STATE_RESUME and self._current_state ~= VRLoadingEnvironment.STATE_FADEIN and self._current_state ~= VRLoadingEnvironment.STATE_START then
		self:change_state(VRLoadingEnvironment.STATE_START, params)
	end
end

function VRLoadingEnvironment:stop()
	self:change_state(VRLoadingEnvironment.STATE_STOP)
end

function VRLoadingEnvironment:resume()
	self:change_state(VRLoadingEnvironment.STATE_RESUME)
end

function VRLoadingEnvironment:change_state(state, ...)
	print("[VRLoadingEnvironment] Change state ", state)

	if state < 1 or state > #self._states then
		print("[VRLoadingEnvironment] State ", state, " does not exist")

		return
	end

	if state == self._current_state then
		return
	end

	if self._current_state then
		local exit = self._states[self._current_state].exit

		if exit then
			exit(...)
		end
	end

	self._current_state = state
	local enter = self._states[self._current_state].enter

	if enter then
		enter(...)
	end

	self._state_update = self._states[self._current_state].update
	self._update_timer = not self._states[self._current_state].no_timer
end

function VRLoadingEnvironment:current_state()
	return self._current_state
end

function VRLoadingEnvironment:update(t, dt)
	if self._state_update then
		if self._update_timer then
			t = TimerManager:main():time()
			dt = TimerManager:main():delta_time()
		end

		self._state_update(t, dt)
	end
end

function VRLoadingEnvironment:find_overlay(name)
	local overlays = {}

	for _, o in ipairs(self._overlays) do
		if o.name == name or o.path == name then
			return o
		end
	end
end

function VRLoadingEnvironment:find_overlays(name)
	local overlays = {}

	for _, o in ipairs(self._overlays) do
		if o.name == name or o.path == name then
			table.insert(overlays, o)
		end
	end

	return overlays
end

function VRLoadingEnvironment:block_exec()
	return self._block_exec
end

function VRLoadingEnvironment:_start_enter(start_type)
	self._loading_spin = nil
	self._block_exec = true
	self._timer_t = TimerManager:main():time() + self._fade_black_t

	VRManager:fade_to_color(self._fade_black_t, Color(1, 0, 0, 0), false)
	VRManager:fade_to_color(self._fade_black_t, Color(1, 0, 0, 0), true)
	self:_show_loading_screen("loading")
	self:_fade_overlays(0)
end

function VRLoadingEnvironment:_start_exit()
	VRManager:set_skybox_override({
		Idstring("guis/dlcs/vr/textures/loading/loading_bg")
	})
	VRManager:suspend_rendering(true)
end

function VRLoadingEnvironment:_start_update(t, dt)
	self:_update_progress(t, dt)

	if self._timer_t < t then
		self:change_state(VRLoadingEnvironment.STATE_FADEIN)
	end
end

function VRLoadingEnvironment:_stop_enter()
	self._timer_t = TimerManager:main():time() + self._fade_black_t

	VRManager:fade_to_color(self._fade_black_t, Color(1, 0, 0, 0), false)
	VRManager:fade_to_color(self._fade_black_t, Color(1, 0, 0, 0), true)
end

function VRLoadingEnvironment:_stop_exit()
	VRManager:suspend_rendering(false)
	VRManager:clear_skybox_override()
	self:_remove_overlays()
	VRManager:fade_to_color(1, Color(0, 0, 0, 0), false)
	VRManager:fade_to_color(1, Color(0, 0, 0, 0), true)
end

function VRLoadingEnvironment:_stop_update(t, dt)
	self:_fade_overlays((self._timer_t - t) / self._fade_black_t)
	self:_update_progress(t, dt)

	if self._timer_t < t then
		self:change_state(VRLoadingEnvironment.STATE_NONE)
	end
end

function VRLoadingEnvironment:_fadein_enter()
	self._timer_t = TimerManager:main():time() + self._fade_in_t

	VRManager:fade_to_color(self._fade_in_t, Color(0, 0, 0, 0), false)
	VRManager:fade_to_color(self._fade_in_t, Color(0, 0, 0, 0), true)
end

function VRLoadingEnvironment:_fadein_exit()
	self._block_exec = false
end

function VRLoadingEnvironment:_fadein_update(t, dt)
	self:_fade_overlays(1 - (self._timer_t - t) / self._fade_in_t)
	self:_update_progress(t, dt)

	if self._timer_t < t then
		self:change_state(VRLoadingEnvironment.STATE_RESUME)
	end
end

function VRLoadingEnvironment:_resume_enter()
end

function VRLoadingEnvironment:_resume_exit()
end

function VRLoadingEnvironment:_resume_update(t, dt)
	self:_update_progress(t, dt)
end

function VRLoadingEnvironment:_fade_overlays(alpha)
	alpha = math.clamp(alpha, 0, 1)

	for _, o in ipairs(self._overlays) do
		local c = o.config.color or Color(1, 1, 1, 1)
		local range = c.alpha
		c = c:with_alpha(range * alpha)

		o.overlay:set_color(c)
	end
end

function VRLoadingEnvironment:_update_progress(t, dt)
	self._loading_spin = self._loading_spin or self:find_overlay("loading_spin")

	if not self._loading_spin then
		return
	end

	self._loading_spin.t = self._loading_spin.t ~= nil and self._loading_spin.t + dt or 0
	local overlay = self._loading_spin.overlay

	overlay:set_transform_linked(self._loading_spin.parent, Vector3(0, 0, 0), Rotation(0, 0, self._loading_spin.t * 360 % 360))
end

function VRLoadingEnvironment:_show_loading_screen(name)
	local config = tweak_data.vr.loading_screens[name]

	if config then
		self:_remove_overlays()

		local overlays = {}

		for n, c in pairs(config) do
			table.insert(overlays, {
				n,
				c,
				""
			})
		end

		while #overlays ~= 0 do
			local current = overlays[1]

			table.remove(overlays, 1)

			local name = current[1]
			local config = current[2]
			local path = current[3] .. "/" .. name
			local parent = current[4]
			local overlay = self:_create_overlay(path, name, config, parent)

			table.insert(Global.__vr_overlays, {
				name = name,
				path = path,
				overlay = overlay,
				parent = parent,
				config = config
			})

			if config.children then
				for n, c in pairs(config.children) do
					table.insert(overlays, {
						n,
						c,
						path,
						overlay
					})
				end
			end
		end
	end
end

function VRLoadingEnvironment:_remove_overlays()
	for _, o in ipairs(Global.__vr_overlays) do
		if alive(o.overlay) then
			o.overlay:destroy()
		end
	end

	Global.__vr_overlays = {}
	self._overlays = Global.__vr_overlays
	self._loading_spin = nil
end

function VRLoadingEnvironment:_create_overlay(path, name, config, parent)
	local overlay = VRManager:create_overlay(path, name)

	if config.texture then
		overlay:set_texture(config.texture)
	end

	if parent then
		overlay:set_transform_linked(parent, config.position or Vector3(0, 0, 0), config.rotation or Rotation())
	else
		overlay:set_transform_world(config.position or Vector3(0, 0, 0), config.rotation or Rotation())
	end

	print("[VRLoadingEnvironment] ", path, name, overlay, parent)
	overlay:set_visible(config.visible or false)
	overlay:set_order(config.order or 0)
	overlay:set_width(config.width or 100)

	if config.color then
		overlay:set_color(config.color)
	end

	if config.bounds then
		overlay:set_texture_bounds(unpack(config.bounds))
	end

	return overlay
end
