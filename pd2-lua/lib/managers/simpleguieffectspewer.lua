SimpleGUIEffectSpewer = SimpleGUIEffectSpewer or class()
SimpleGUIEffectSpewer.DEFAULT_PARTICLE_TEXTURES = {
	"guis/textures/pd2/particles/bulb",
	"guis/textures/pd2/particles/spark"
}

function SimpleGUIEffectSpewer:_particles_update(t, dt)
	local dead_particles = {}
	local particle_live_p = 1

	self._particle_panel:set_visible(self._spew_panel:tree_visible())

	for key, particle_data in pairs(self.__living_particles) do
		particle_data.pt = particle_data.pt + dt
		particle_live_p = particle_data.plive_time == 0 and 1 or particle_data.pt / particle_data.plive_time

		particle_data.particle:set_alpha(math.clamp(math.sin((particle_live_p + 0.2) * 150), 0, 1))

		if self._particle_acceleration ~= 0 then
			particle_data.particle_speed = particle_data.particle_speed + self._particle_acceleration * dt
		end

		if particle_data.speed_sway_speed ~= 0 and particle_data.speed_sway_distance ~= 0 then
			particle_data.speed_sway_t = particle_data.speed_sway_t + dt
			particle_data.particle_speed = particle_data.particle_speed + math.sin(particle_data.speed_sway_speed * particle_data.speed_sway_t) * particle_data.speed_sway_distance
		end

		local sx, sy = particle_data.particle:center()

		particle_data.particle:move(particle_data.dir_x * particle_data.particle_speed * dt, particle_data.dir_y * particle_data.particle_speed * dt)

		if self._particle_gravity ~= 0 then
			particle_data.gravity = particle_data.gravity + dt * self._particle_gravity

			particle_data.particle:move(0, dt * particle_data.gravity)
		end

		if particle_data.sway_speed ~= 0 and particle_data.sway_distance ~= 0 then
			particle_data.sway_t = particle_data.sway_t + dt

			particle_data.particle:move(math.cos(particle_data.sway_t * particle_data.sway_speed) * -particle_data.dir_y * particle_data.sway_distance, math.cos(particle_data.sway_t * particle_data.sway_speed) * particle_data.dir_x * particle_data.sway_distance)
		end

		if particle_data.flip_speed ~= 0 then
			local dimension = self._particle_flip_dimension or particle_data.w

			if dimension <= particle_data.particle:w() then
				particle_data.flip_bit = true
			elseif particle_data.particle:w() <= -dimension then
				particle_data.flip_bit = false
			end

			local cx, cy = particle_data.particle:center()

			if particle_data.flip_bit then
				particle_data.particle:grow(-dt * particle_data.flip_speed, 0)
			else
				particle_data.particle:grow(dt * particle_data.flip_speed, 0)
			end

			particle_data.particle:set_center(cx, cy)
		end

		if particle_data.plive_time <= particle_data.pt then
			table.insert(dead_particles, key)
		else
			local ex, ey = particle_data.particle:center()
			local dir_x = ex - sx
			local dir_y = ey - sy
			local magnitude = (dir_x * dir_x + dir_y * dir_y)^0.5
			local rotation = particle_data.particle:rotation()
			local can_rotate = false

			if self._particle_rotation_speed ~= 0 then
				rotation = rotation + self._particle_rotation_speed * dt
				can_rotate = true
			elseif magnitude ~= 0 then
				dir_x = dir_x / magnitude
				dir_y = dir_y / magnitude
				rotation = math.atan2(dir_y, dir_x)
				can_rotate = math.abs(rotation - particle_data.start_rotation) < 90
			end

			if can_rotate then
				particle_data.particle:set_rotation(rotation)
			end
		end
	end

	for i, dead_particle_key in ipairs(dead_particles) do
		self._particle_panel:remove(self.__living_particles[dead_particle_key].particle)

		self.__living_particles[dead_particle_key] = nil
	end
end

function SimpleGUIEffectSpewer:_spew_update(t, dt)
	self.__particle_spawn_t = self.__particle_spawn_t - dt

	while self.__particle_spawn_t <= 0 do
		if self._max_num_particles == 0 or table.size(self.__living_particles) < self._max_num_particles then
			local rot = math.rand(self._min_spew_angle, self._max_spew_angle)

			if rot == 0 then
				rot = 360
			end

			local new_particle = self._particle_panel:bitmap({
				texture = self._particle_textures[math.random(#self._particle_textures)],
				rotation = rot,
				blend_mode = self._particle_blend_mode
			})
			local ratio = new_particle:texture_width() / new_particle:texture_height()
			local w = math.random(self._min_particle_w, self._max_particle_w) * ratio
			local h = math.random(self._min_particle_h, self._max_particle_h)

			new_particle:set_size(w, h)

			local wx, wy = self._spew_panel:world_center()

			if self._ws_converter then
				local func = callback(managers.gui_data, managers.gui_data, self._ws_converter)

				if func then
					wx, wy = func(wx, wy)
				end
			end

			new_particle:set_world_center(wx, wy)

			local red = 1
			local green = 1
			local blue = 1

			if self._particle_colors then
				local red_data = self._particle_colors.red or {
					1,
					1
				}
				local green_data = self._particle_colors.green or {
					1,
					1
				}
				local blue_data = self._particle_colors.blue or {
					1,
					1
				}
				red = type(red_data) == "number" and red_data or math.rand(red_data[1], red_data[2])
				green = type(green_data) == "number" and green_data or math.rand(green_data[1], green_data[2])
				blue = type(blue_data) == "number" and blue_data or math.rand(blue_data[1], blue_data[2])
			end

			new_particle:set_color(Color(red, green, blue))

			local dir_x = math.cos(rot)
			local dir_y = math.sin(rot)
			local sway_distance = math.rand(self._min_particle_sway_distance, self._max_particle_sway_distance)
			local sway_speed = math.rand(self._min_particle_sway_speed, self._max_particle_sway_speed)
			local speed_sway_distance = math.rand(self._min_particle_speed_sway_distance, self._max_particle_speed_sway_distance)
			local speed_sway_speed = math.rand(self._min_particle_speed_sway_speed, self._max_particle_speed_sway_speed)
			local particle_speed = math.rand(self._min_particle_speed, self._max_particle_speed)
			local plive_time = math.rand(self._min_plive_time, self._max_plive_time)
			local particle_flip_speed = math.rand(self._min_particle_flip_speed, self._max_particle_flip_speed)

			if self.__living_particles[new_particle:key()] and alive(self.__living_particles[new_particle:key()].particle) then
				Application:error("[SimpleGUIEffectSpewer] Particle already exists:", new_particle:key())
				self._particle_panel:remove(self.__living_particles[new_particle:key()].particle)

				self.__living_particles[new_particle:key()] = nil
			end

			self.__living_particles[new_particle:key()] = {
				gravity = 0,
				pt = 0,
				particle = new_particle,
				w = w,
				h = h,
				dir_x = dir_x,
				dir_y = dir_y,
				particle_speed = particle_speed,
				plive_time = plive_time,
				start_rotation = rot,
				sway_distance = sway_distance,
				sway_speed = sway_speed,
				sway_t = math.rand(1),
				speed_sway_speed = speed_sway_speed,
				speed_sway_distance = speed_sway_distance,
				speed_sway_t = math.rand(1),
				flip_speed = particle_flip_speed,
				flip_dir = math.random() < 0.5 and -1 or 1
			}
		end

		self.__particle_spawn_interval = self._fixed_spew_rate and self.__particle_spawn_interval or math.rand(self._min_spawn_interval, self._max_spawn_interval)

		if self._max_num_particles <= table.size(self.__living_particles) then
			self.__particle_spawn_t = self.__particle_spawn_interval
		else
			self.__particle_spawn_t = self.__particle_spawn_t + self.__particle_spawn_interval
		end
	end
end

function SimpleGUIEffectSpewer:animation_update(o)
	local t = 0
	local dt = coroutine.yield()
	self.__spew_time = math.rand(self._min_spew_time, self._max_spew_time)
	self.__particle_spawn_interval = math.rand(self._min_spawn_interval, self._max_spawn_interval)
	self.__particle_spawn_t = self._spew_at_start and 0 or self.__particle_spawn_interval
	self.__living_particles = {}
	local done = false

	while not done do
		done = true

		if t <= self.__spew_time then
			self:_spew_update(t, dt)

			done = false
		end

		if table.size(self.__living_particles) > 0 then
			self:_particles_update(t, dt)

			done = false
		end

		dt = coroutine.yield()
		t = t + dt

		if not alive(self._particle_panel) or not alive(self._spew_panel) then
			if alive(self._spew_panel) and alive(self._spew_parent_panel) then
				self._spew_parent_panel:remove(self._spew_panel)
			end

			if alive(self._particle_panel) then
				self._ws:panel():remove(self._particle_panel)
			end

			return
		end
	end

	self._spew_parent_panel:remove(self._spew_panel)
	self._ws:panel():remove(self._particle_panel)
end

function SimpleGUIEffectSpewer:init(params)
	params = params or {
		spawn_interval = 0.1,
		plive_time = 1,
		spew_time = 1
	}
	self._ws = params.ws or managers.menu_component:fullscreen_ws()
	self._particle_panel = self._ws:panel():panel()

	self._particle_panel:set_alpha(params.particle_alpha or 1)

	self._spew_parent_panel = params.parent_panel or self._particle_panel
	self._spew_panel_x = params.x or self._spew_parent_panel:w() / 2
	self._spew_panel_y = params.y or self._spew_parent_panel:h() / 2
	self._ws_converter = params.ws_converter or nil
	self._layer = params.layer or 0
	self._max_num_particles = params.max_num_particles or 0
	self._min_spew_time = params.min_spew_time or params.spew_time or 0
	self._max_spew_time = params.max_spew_time or params.spew_time or 0
	self._min_plive_time = params.min_plive_time or params.plive_time or 0
	self._max_plive_time = params.max_plive_time or params.plive_time or 0
	self._min_spawn_interval = params.min_spawn_interval or params.spawn_interval or 0
	self._max_spawn_interval = params.max_spawn_interval or params.spawn_interval or 0
	self._min_particle_speed = params.min_particle_speed or params.particle_speed or 10
	self._max_particle_speed = params.max_particle_speed or params.particle_speed or 10
	self._min_spew_angle = params.min_spew_angle or params.spew_angle or 0
	self._max_spew_angle = params.max_spew_angle or params.spew_angle or 360
	self._min_particle_w = params.min_particle_w or params.particle_w or 32
	self._max_particle_w = params.max_particle_w or params.particle_w or 32
	self._min_particle_h = params.min_particle_h or params.particle_h or 32
	self._max_particle_h = params.max_particle_h or params.particle_h or 32
	self._min_particle_end_w = params.min_particle_end_w or params.particle_w or 32
	self._max_particle_end_w = params.max_particle_end_w or params.particle_w or 32
	self._min_particle_end_h = params.min_particle_end_h or params.particle_h or 32
	self._max_particle_end_h = params.max_particle_end_h or params.particle_h or 32
	self._min_particle_sway_distance = params.min_particle_sway_distance or params.min_sway_distance or params.particle_sway_distance or params.sway_distance or 0
	self._max_particle_sway_distance = params.max_particle_sway_distance or params.max_sway_distance or params.particle_sway_distance or params.sawy_distance or 0
	self._min_particle_sway_speed = params.min_particle_sway_speed or params.min_sway_speed or params.particle_sway_speed or params.sway_speed or 0
	self._max_particle_sway_speed = params.max_particle_sway_speed or params.max_sway_speed or params.particle_sway_speed or params.sawy_speed or 0
	self._min_particle_speed_sway_distance = params.min_particle_speed_sway_distance or params.min_speed_sway_distance or params.particle_speed_sway_distance or params.speed_sway_distance or 0
	self._max_particle_speed_sway_distance = params.max_particle_speed_sway_distance or params.max_speed_sway_distance or params.particle_speed_sway_distance or params.speed_sawy_distance or 0
	self._min_particle_speed_sway_speed = params.min_particle_speed_sway_speed or params.min_speed_sway_speed or params.particle_speed_sway_speed or params.speed_sway_speed or 0
	self._max_particle_speed_sway_speed = params.max_particle_speed_sway_speed or params.max_speed_sway_speed or params.particle_speed_sway_speed or params.speed_sawy_speed or 0
	self._min_particle_flip_speed = params.min_particle_flip_speed or params.particle_flip_speed or 0
	self._max_particle_flip_speed = params.max_particle_flip_speed or params.particle_flip_speed or 0
	self._particle_flip_dimension = params.particle_flip_dimension or nil
	self._particle_acceleration = params.particle_acceleration or 0
	self._particle_gravity = params.particle_gravity or params.gravity or 0
	self._particle_rotation_speed = params.particle_rotation_speed or params.rotation_speed or 0
	self._particle_blend_mode = params.particle_blend_mode or "add"
	self._particle_colors = params.particle_colors
	self._particle_textures = params.particle_textures or self.DEFAULT_PARTICLE_TEXTURES or {}
	self._spew_at_start = params.spew_at_start or false
	self._fixed_spew_rate = params.fixed_spew_rate or false
	self._spew_panel = self._spew_parent_panel:panel({
		h = 9,
		w = 9,
		x = self._spew_panel_x - 5,
		y = self._spew_panel_y - 5,
		layer = self._layer
	})
	self._update_thread = self._particle_panel:animate(callback(self, self, "animation_update"))

	self._particle_panel:set_layer(self._layer)
end

function SimpleGUIEffectSpewer.lootdrop_drill_drop_flip_card(panel)
	local color = tweak_data.economy.rarities.legendary.color
	local particle_colors = {
		green = 0,
		blue = 0,
		red = 1
	}

	SimpleGUIEffectSpewer:new({
		spawn_interval = 0.1,
		plive_time = 6,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		particle_alpha = 1,
		particle_rotation_speed = 180,
		particle_colors = particle_colors,
		particle_w = panel:h() * 6,
		particle_h = panel:h() * 6,
		particle_textures = {
			"guis/dlcs/infamous/textures/pd2/infamous_tree/spinner_01_df"
		},
		layer = panel:world_layer() - 1,
		parent_panel = panel
	})
	SimpleGUIEffectSpewer:new({
		spawn_interval = 0.1,
		plive_time = 6,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		particle_alpha = 1,
		particle_rotation_speed = -180,
		particle_colors = particle_colors,
		particle_w = panel:h() * 6,
		particle_h = panel:h() * 6,
		particle_textures = {
			"guis/dlcs/infamous/textures/pd2/infamous_tree/spinner_02_df"
		},
		layer = panel:world_layer() - 1,
		parent_panel = panel
	})
end

function SimpleGUIEffectSpewer.lootdrop_drill_drop_show_wait(panel)
	managers.menu_component:post_event("cash_loot_drop_drill_intro")
end

function SimpleGUIEffectSpewer.lootdrop_drill_drop_show_item(panel)
	managers.menu_component:post_event("cash_loot_drop_drill_reveal")

	local color = tweak_data.economy.rarities.legendary.color
	local particle_colors = {
		red = {
			color.red - 0.2,
			color.red + 0.8
		},
		green = {
			color.green - 0.8,
			color.green + 0.2
		},
		blue = {
			color.blue - 0.8,
			color.blue + 0.2
		}
	}

	for i = 1, 4 do
		SimpleGUIEffectSpewer:new({
			min_particle_speed = 10,
			min_plive_time = 0.65,
			max_num_particles = 25,
			particle_w = 8,
			spew_time = 0.44,
			max_particle_speed = 30,
			particle_sway_distance = 4.4,
			max_plive_time = 1.9,
			gravity = 50,
			particle_h = 8,
			particle_rotation_speed = 180,
			spawn_interval = 0.09,
			particle_sway_speed = 180,
			particle_colors = particle_colors,
			particle_textures = {
				"guis/textures/pd2/particles/bulb"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			min_plive_time = 0.65,
			max_num_particles = 35,
			particle_alpha = 0.6,
			spew_time = 0.44,
			particle_speed_sway_speed = 90,
			gravity = 75,
			min_particle_speed = 15,
			max_particle_speed = 45,
			particle_sway_distance = 4.4,
			max_plive_time = 1.9,
			particle_w = 12,
			particle_h = 12,
			particle_rotation_speed = 90,
			particle_speed_sway_distance = 5,
			spawn_interval = 0.09,
			particle_sway_speed = 180,
			particle_colors = particle_colors,
			particle_textures = {
				"guis/textures/pd2/particles/bulb"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			particle_w = 4,
			max_num_particles = 60,
			particle_h = 4,
			min_plive_time = 0.1,
			spawn_interval = 0.09,
			min_particle_speed = 415,
			spew_time = 0.2,
			max_particle_speed = 605,
			max_plive_time = 0.45,
			particle_colors = particle_colors,
			particle_textures = {
				"guis/textures/pd2/particles/spark"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			particle_w = 8,
			max_num_particles = 35,
			particle_h = 8,
			min_plive_time = 0.2,
			spawn_interval = 0.08,
			min_particle_speed = 395,
			spew_time = 0.4,
			max_particle_speed = 505,
			max_plive_time = 0.35,
			particle_colors = particle_colors,
			particle_textures = {
				"guis/textures/pd2/particles/spark"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			spawn_interval = 0.1,
			plive_time = 1.9,
			max_num_particles = 2,
			spew_at_start = true,
			particle_speed = 0,
			spew_time = 0,
			particle_alpha = 0.2,
			particle_colors = particle_colors,
			particle_w = panel:h() * 2.5,
			particle_h = panel:h() * 2.5,
			particle_textures = {
				"guis/textures/pd2/particles/fill"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			spawn_interval = 0.1,
			plive_time = 1.5,
			max_num_particles = 1,
			spew_at_start = true,
			particle_speed = 0,
			spew_time = 0,
			particle_alpha = 0.4,
			particle_colors = particle_colors,
			particle_w = panel:h() * 1.55,
			particle_h = panel:h() * 1.55,
			particle_textures = {
				"guis/textures/pd2/particles/fill"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			spawn_interval = 0.1,
			plive_time = 2,
			max_num_particles = 2,
			spew_at_start = true,
			particle_speed = 0,
			spew_time = 0,
			particle_alpha = 0.1,
			particle_colors = particle_colors,
			particle_w = panel:h() * 4,
			particle_h = panel:h() * 4,
			particle_textures = {
				"guis/textures/pd2/particles/fill"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
	end
end

function SimpleGUIEffectSpewer.lootdrop_safe_drop_flip_card(panel)
	local color = tweak_data.economy.rarities.legendary.color
	local particle_colors = {
		green = 1,
		blue = 1,
		red = 1
	}

	SimpleGUIEffectSpewer:new({
		spawn_interval = 0.1,
		plive_time = 6,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		particle_alpha = 0.6,
		particle_rotation_speed = 180,
		particle_colors = particle_colors,
		particle_w = panel:h() * 4,
		particle_h = panel:h() * 4,
		particle_textures = {
			"guis/dlcs/infamous/textures/pd2/infamous_tree/spinner_01_df"
		},
		layer = panel:world_layer() - 1,
		parent_panel = panel
	})
	SimpleGUIEffectSpewer:new({
		spawn_interval = 0.1,
		plive_time = 6,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		particle_alpha = 0.6,
		particle_rotation_speed = -180,
		particle_colors = particle_colors,
		particle_w = panel:h() * 4,
		particle_h = panel:h() * 4,
		particle_textures = {
			"guis/dlcs/infamous/textures/pd2/infamous_tree/spinner_02_df"
		},
		layer = panel:world_layer() - 1,
		parent_panel = panel
	})
end

function SimpleGUIEffectSpewer.lootdrop_safe_drop_show_wait(panel)
	managers.menu_component:post_event("cash_loot_drop_intro")
end

function SimpleGUIEffectSpewer.lootdrop_safe_drop_show_item(panel)
	local color = tweak_data.economy.rarities.legendary.color
	local particle_colors = {
		red = {
			color.red - 0.2,
			color.red + 0.2
		},
		green = {
			color.green - 0.2,
			color.green + 0.2
		},
		blue = {
			color.blue - 0.2,
			color.blue + 0.2
		}
	}

	for i = 1, 4 do
		SimpleGUIEffectSpewer:new({
			min_particle_speed = 10,
			min_plive_time = 0.65,
			max_num_particles = 25,
			particle_w = 8,
			spew_time = 0.44,
			max_particle_speed = 30,
			particle_sway_distance = 4.4,
			max_plive_time = 1.9,
			gravity = 50,
			particle_h = 8,
			particle_rotation_speed = 180,
			spawn_interval = 0.09,
			particle_sway_speed = 180,
			particle_colors = particle_colors,
			particle_textures = {
				"guis/textures/pd2/particles/bulb"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			min_plive_time = 0.65,
			max_num_particles = 35,
			particle_alpha = 0.6,
			spew_time = 0.44,
			particle_speed_sway_speed = 90,
			gravity = 75,
			min_particle_speed = 15,
			max_particle_speed = 45,
			particle_sway_distance = 4.4,
			max_plive_time = 1.9,
			particle_w = 12,
			particle_h = 12,
			particle_rotation_speed = 90,
			particle_speed_sway_distance = 5,
			spawn_interval = 0.09,
			particle_sway_speed = 180,
			particle_colors = particle_colors,
			particle_textures = {
				"guis/textures/pd2/particles/bulb"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			particle_w = 4,
			max_num_particles = 60,
			particle_h = 4,
			min_plive_time = 0.1,
			spawn_interval = 0.09,
			min_particle_speed = 415,
			spew_time = 0.2,
			max_particle_speed = 605,
			max_plive_time = 0.45,
			particle_colors = particle_colors,
			particle_textures = {
				"guis/textures/pd2/particles/spark"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			particle_w = 8,
			max_num_particles = 35,
			particle_h = 8,
			min_plive_time = 0.2,
			spawn_interval = 0.08,
			min_particle_speed = 395,
			spew_time = 0.4,
			max_particle_speed = 505,
			max_plive_time = 0.35,
			particle_colors = particle_colors,
			particle_textures = {
				"guis/textures/pd2/particles/spark"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			spawn_interval = 0.1,
			plive_time = 1.9,
			max_num_particles = 2,
			spew_at_start = true,
			particle_speed = 0,
			spew_time = 0,
			particle_alpha = 0.2,
			particle_colors = particle_colors,
			particle_w = panel:h() * 2.5,
			particle_h = panel:h() * 2.5,
			particle_textures = {
				"guis/textures/pd2/particles/fill"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			spawn_interval = 0.1,
			plive_time = 1.5,
			max_num_particles = 1,
			spew_at_start = true,
			particle_speed = 0,
			spew_time = 0,
			particle_alpha = 0.4,
			particle_colors = particle_colors,
			particle_w = panel:h() * 1.55,
			particle_h = panel:h() * 1.55,
			particle_textures = {
				"guis/textures/pd2/particles/fill"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
		SimpleGUIEffectSpewer:new({
			spawn_interval = 0.1,
			plive_time = 2,
			max_num_particles = 2,
			spew_at_start = true,
			particle_speed = 0,
			spew_time = 0,
			particle_alpha = 0.1,
			particle_colors = particle_colors,
			particle_w = panel:h() * 4,
			particle_h = panel:h() * 4,
			particle_textures = {
				"guis/textures/pd2/particles/fill"
			},
			parent_panel = panel,
			layer = panel:world_layer() + 10
		})
	end

	managers.menu_component:post_event("cash_loot_drop_reveal")
end

function SimpleGUIEffectSpewer.get_sample_boom()
	local ws = managers.menu_component:fullscreen_ws()

	return {
		spawn_interval = 0.04,
		max_num_particles = 35,
		min_particle_speed = 175,
		min_plive_time = 0.6,
		spew_time = 0.5,
		max_particle_speed = 225,
		particle_sway_distance = 0.5,
		max_plive_time = 1,
		particle_sway_speed = 360,
		particle_colors = {
			red = {
				0.8,
				1
			},
			green = {
				0.7,
				0.9
			},
			blue = {
				0,
				0.1
			}
		},
		particle_textures = {
			"guis/textures/pd2/particles/bulb"
		}
	}, {
		particle_w = 16,
		max_num_particles = 20,
		particle_h = 16,
		min_plive_time = 0.4,
		spawn_interval = 0.05,
		min_particle_speed = 375,
		spew_time = 0.6,
		max_particle_speed = 425,
		max_plive_time = 0.6,
		particle_colors = {
			red = {
				0.8,
				1
			},
			green = {
				0.7,
				0.9
			},
			blue = {
				0,
				0.1
			}
		},
		particle_textures = {
			"guis/textures/pd2/particles/spark"
		}
	}, {
		spawn_interval = 0.1,
		plive_time = 1.6,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		particle_alpha = 0.8,
		layer = 1,
		particle_colors = {
			green = 0.8,
			blue = 0.1,
			red = 0.8
		},
		particle_w = ws:panel():h() / 2,
		particle_h = ws:panel():h() / 2,
		particle_textures = {
			"guis/textures/pd2/particles/fill"
		}
	}, {
		spawn_interval = 0.1,
		plive_time = 1.5,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		particle_alpha = 0.8,
		layer = 1,
		particle_colors = {
			green = 0.5,
			blue = 0.1,
			red = 0.8
		},
		particle_w = ws:panel():h(),
		particle_h = ws:panel():h(),
		particle_textures = {
			"guis/textures/pd2/particles/fill"
		}
	}, {
		spawn_interval = 0.1,
		plive_time = 0.8,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		particle_alpha = 0.8,
		layer = 1,
		particle_colors = {
			green = 0.5,
			blue = 0.1,
			red = 0.8
		},
		particle_w = ws:panel():h(),
		particle_h = ws:panel():h(),
		particle_textures = {
			"guis/textures/pd2/particles/fill"
		}
	}
end

function SimpleGUIEffectSpewer.sample_boom()
	local spewers = {
		SimpleGUIEffectSpewer.get_sample_boom()
	}

	for i, spewer in ipairs(spewers) do
		SimpleGUIEffectSpewer:new(spewer)
	end
end

function SimpleGUIEffectSpewer.get_skill_spewers(x, y, panel, color)
	local ws = managers.menu_component:fullscreen_ws()
	local skill_color = color or tweak_data.screen_colors.button_stage_3
	local colors = {
		red = {
			skill_color.red - 0.1,
			skill_color.red + 0.1
		},
		green = {
			skill_color.green - 0.1,
			skill_color.green + 0.1
		},
		blue = {
			skill_color.blue - 0.1,
			skill_color.blue + 0.1
		}
	}

	return {
		spew_time = 0.4,
		min_plive_time = 0.4,
		max_num_particles = 35,
		particle_sway_speed = 180,
		ws_converter = "safe_to_full_16_9",
		min_particle_speed = 100,
		gravity = 50,
		max_particle_speed = 155,
		particle_sway_distance = 0.4,
		max_plive_time = 0.6,
		particle_w = 8,
		particle_h = 8,
		spawn_interval = 0.06,
		particle_colors = colors,
		particle_alpha = skill_color.alpha,
		particle_textures = {
			"guis/textures/pd2/particles/bulb"
		},
		x = x,
		y = y,
		parent_panel = panel,
		layer = (panel and panel:layer() or 0) + 2
	}, {
		spew_time = 0.2,
		min_plive_time = 0.2,
		max_num_particles = 35,
		ws_converter = "safe_to_full_16_9",
		min_particle_speed = 255,
		max_particle_speed = 305,
		max_plive_time = 0.3,
		particle_w = 4,
		particle_h = 4,
		spawn_interval = 0.05,
		particle_colors = colors,
		particle_alpha = skill_color.alpha,
		particle_textures = {
			"guis/textures/pd2/particles/spark"
		},
		x = x,
		y = y,
		parent_panel = panel,
		layer = (panel and panel:layer() or 0) + 2
	}, {
		spawn_interval = 0.1,
		plive_time = 1.6,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		ws_converter = "safe_to_full_16_9",
		particle_colors = colors,
		particle_w = ws:panel():h() * 0.25,
		particle_h = ws:panel():h() * 0.25,
		particle_alpha = skill_color.alpha * 0.8,
		particle_textures = {
			"guis/textures/pd2/particles/fill"
		},
		x = x,
		y = y,
		parent_panel = panel,
		layer = (panel and panel:layer() or 0) + 3
	}, {
		spawn_interval = 0.1,
		plive_time = 1.5,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		ws_converter = "safe_to_full_16_9",
		particle_colors = colors,
		particle_alpha = skill_color.alpha * 0.8,
		particle_w = ws:panel():h() * 0.35,
		particle_h = ws:panel():h() * 0.35,
		particle_textures = {
			"guis/textures/pd2/particles/fill"
		},
		x = x,
		y = y,
		parent_panel = panel,
		layer = (panel and panel:layer() or 0) + 3
	}, {
		spawn_interval = 0.1,
		plive_time = 0.8,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		ws_converter = "safe_to_full_16_9",
		particle_colors = colors,
		particle_alpha = skill_color.alpha * 0.8,
		particle_w = ws:panel():h() * 0.45,
		particle_h = ws:panel():h() * 0.45,
		particle_textures = {
			"guis/textures/pd2/particles/fill"
		},
		x = x,
		y = y,
		parent_panel = panel,
		layer = (panel and panel:layer() or 0) + 3
	}
end

function SimpleGUIEffectSpewer.item_sell(x, y, layer)
	local ws = managers.menu_component:fullscreen_ws()
	local skill_color = Color(255, 215, 0)
	local colors = {
		red = {
			skill_color.red - 0.1,
			skill_color.red + 0.1
		},
		green = {
			skill_color.green - 0.1,
			skill_color.green + 0.1
		},
		blue = {
			skill_color.blue - 0.1,
			skill_color.blue + 0.1
		}
	}
	local spewers = {
		{
			max_particle_w = 32,
			min_particle_w = -32,
			min_particle_speed = 125,
			spew_time = 0.35,
			min_particle_flip_speed = 125,
			max_num_particles = 35,
			particle_flip_dimension = 32,
			max_particle_speed = 195,
			max_spew_angle = 0,
			ws_converter = "safe_to_full_16_9",
			max_plive_time = 0.9,
			gravity = 325,
			particle_h = 32,
			particle_blend_mode = "normal",
			min_plive_time = 0.7,
			max_particle_flip_speed = 225,
			spawn_interval = 0.015,
			min_spew_angle = -180,
			x = x,
			y = y,
			particle_colors = colors,
			particle_alpha = skill_color.alpha,
			particle_textures = {
				"guis/textures/pd2/particles/bulb"
			},
			layer = layer
		}
	}

	for i, spewer in ipairs(spewers) do
		SimpleGUIEffectSpewer:new(spewer)
	end
end

function SimpleGUIEffectSpewer.skill_up(x, y, panel)
	local spewers = {
		SimpleGUIEffectSpewer.get_skill_spewers(x, y, panel)
	}

	for i, spewer in ipairs(spewers) do
		SimpleGUIEffectSpewer:new(spewer)
	end
end

function SimpleGUIEffectSpewer.infamous_up(x, y, panel)
	local spewers = {
		SimpleGUIEffectSpewer.get_skill_spewers(x, y, panel)
	}

	for i, spewer in ipairs(spewers) do
		spewer.particle_w = spewer.particle_w and math.floor(spewer.particle_w * 1.4)
		spewer.particle_h = spewer.particle_h and math.floor(spewer.particle_h * 1.4)

		SimpleGUIEffectSpewer:new(spewer)
	end
end

function SimpleGUIEffectSpewer.get_daily_reward_spewers(x, y, panel, color)
	local ws = managers.menu_component:fullscreen_ws()
	local skill_color = color or tweak_data.screen_colors.button_stage_3
	local colors = {
		red = {
			skill_color.red - 0.1,
			skill_color.red + 0.1
		},
		green = {
			skill_color.green - 0.1,
			skill_color.green + 0.1
		},
		blue = {
			skill_color.blue - 0.1,
			skill_color.blue + 0.1
		}
	}

	return {
		spew_time = 0.6,
		min_plive_time = 0.8,
		max_num_particles = 60,
		min_spew_angle = -120,
		ws_converter = "safe_to_full_16_9",
		min_particle_speed = 250,
		gravity = 500,
		max_particle_speed = 300,
		max_spew_angle = -60,
		max_plive_time = 1.4,
		particle_w = 12,
		particle_h = 12,
		spawn_interval = 0.02,
		particle_colors = colors,
		particle_alpha = skill_color.alpha,
		particle_textures = {
			"guis/textures/pd2/particles/bulb"
		},
		x = x,
		y = y,
		parent_panel = panel,
		layer = (panel and panel:layer() or 0) + 2
	}, {
		spew_time = 0.4,
		min_plive_time = 0.2,
		max_num_particles = 35,
		ws_converter = "safe_to_full_16_9",
		min_particle_speed = 255,
		max_particle_speed = 305,
		max_plive_time = 0.3,
		particle_w = 4,
		particle_h = 4,
		spawn_interval = 0.05,
		particle_colors = colors,
		particle_alpha = skill_color.alpha,
		particle_textures = {
			"guis/textures/pd2/particles/spark"
		},
		x = x,
		y = y,
		parent_panel = panel,
		layer = (panel and panel:layer() or 0) + 2
	}, {
		spawn_interval = 0.1,
		plive_time = 1.6,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		ws_converter = "safe_to_full_16_9",
		particle_colors = colors,
		particle_w = ws:panel():h() * 0.25,
		particle_h = ws:panel():h() * 0.25,
		particle_alpha = skill_color.alpha * 0.8,
		particle_textures = {
			"guis/textures/pd2/particles/fill"
		},
		x = x,
		y = y,
		parent_panel = panel,
		layer = (panel and panel:layer() or 0) + 3
	}, {
		spawn_interval = 0.1,
		plive_time = 1.5,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		ws_converter = "safe_to_full_16_9",
		particle_colors = colors,
		particle_alpha = skill_color.alpha * 0.8,
		particle_w = ws:panel():h() * 0.35,
		particle_h = ws:panel():h() * 0.35,
		particle_textures = {
			"guis/textures/pd2/particles/fill"
		},
		x = x,
		y = y,
		parent_panel = panel,
		layer = (panel and panel:layer() or 0) + 3
	}, {
		spawn_interval = 0.1,
		plive_time = 0.8,
		max_num_particles = 1,
		spew_at_start = true,
		particle_speed = 0,
		spew_time = 0,
		ws_converter = "safe_to_full_16_9",
		particle_colors = colors,
		particle_alpha = skill_color.alpha * 0.8,
		particle_w = ws:panel():h() * 0.45,
		particle_h = ws:panel():h() * 0.45,
		particle_textures = {
			"guis/textures/pd2/particles/fill"
		},
		x = x,
		y = y,
		parent_panel = panel,
		layer = (panel and panel:layer() or 0) + 3
	}
end

function SimpleGUIEffectSpewer.claim_daily_reward(x, y, panel)
	local spewers = {
		SimpleGUIEffectSpewer.get_daily_reward_spewers(x, y, panel, Color(255, 255, 168, 0) / 255 * 0.8)
	}

	for i, spewer in ipairs(spewers) do
		spewer.particle_w = spewer.particle_w and math.floor(spewer.particle_w * 1.4)
		spewer.particle_h = spewer.particle_h and math.floor(spewer.particle_h * 1.4)

		SimpleGUIEffectSpewer:new(spewer)
	end
end
