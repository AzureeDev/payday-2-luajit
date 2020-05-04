MenuBackdropGUI = MenuBackdropGUI or class()

function MenuBackdropGUI:init(ws, gui_data_manager, fixed_dt)
	self._fixed_dt = fixed_dt
	self._gui_data_manager = gui_data_manager
	self._gui_data_scene_gui = (self._gui_data_manager or managers.gui_data):get_scene_gui()
	self._workspace = ws or (self._gui_data_manager or managers.gui_data):create_fullscreen_16_9_workspace()
	local src_width, src_height = (self._gui_data_manager or managers.gui_data):get_base_res()
	self.BASE_RES = {
		w = src_width,
		h = src_height
	}

	if not ws then
		self._black_bg_ws = self._gui_data_scene_gui:create_screen_workspace()

		if _G.IS_VR then
			self._black_bg_ws:set_pinned_screen(true)
		end

		self._black_bg_ws:panel():rect({
			valign = "scale",
			name = "bg",
			halign = "scale",
			layer = -1000,
			color = Color.black
		})

		if managers and managers.viewport then
			self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "resolution_changed"))
		end

		self._my_workspace = true
	end

	self._panel = self._workspace:panel():panel({
		valign = "grow",
		name = "panel",
		layer = 0,
		halign = "grow"
	})

	self._panel:panel({
		valign = "grow",
		name = "base_layer",
		layer = 0,
		halign = "grow"
	})
	self._panel:panel({
		valign = "grow",
		name = "pattern_layer",
		layer = 1,
		halign = "grow"
	})
	self._panel:panel({
		valign = "grow",
		name = "item_background_layer",
		layer = 2,
		halign = "grow"
	})
	self._panel:panel({
		valign = "grow",
		name = "particles_layer",
		layer = 3,
		halign = "grow"
	})
	self._panel:panel({
		valign = "grow",
		name = "light_layer",
		layer = 4,
		halign = "grow"
	})
	self._panel:panel({
		valign = "grow",
		name = "item_foreground_layer",
		layer = 5,
		halign = "grow"
	})
	self:setup_saferect_shape()

	self._layer_layers = {}

	for i = 1, 6 do
		table.insert(self._layer_layers, 0)
	end

	self:_create_base_layer()
	self:set_particles_object("guis/textures/pd2/menu_backdrop/bd_particles", 2, 2, 6)
	self:enable_light(true)
end

function MenuBackdropGUI:setup_saferect_shape()
	local saferect_shape = {}
	local safe_scaled_size = (self._gui_data_manager or managers.gui_data):safe_scaled_size()
	local temp_saferect_panel = self._panel:panel({
		name = "temp_saferect_panel",
		w = safe_scaled_size.w,
		h = safe_scaled_size.h
	})

	temp_saferect_panel:set_center(self._panel:w() * 0.5, self._panel:h() * 0.5)

	saferect_shape = {
		temp_saferect_panel:shape()
	}
	saferect_shape.x = saferect_shape[1]
	saferect_shape.y = saferect_shape[2]
	saferect_shape.w = saferect_shape[3]
	saferect_shape.h = saferect_shape[4]
	saferect_shape.width = saferect_shape.w
	saferect_shape.height = saferect_shape.h

	self._panel:remove(temp_saferect_panel)

	self._saferect_shape = saferect_shape
end

function MenuBackdropGUI:create_black_borders()
	if self._black_bg_ws then
		self._gui_data_scene_gui:destroy_workspace(self._black_bg_ws)

		self._black_bg_ws = nil
	end

	self._gui_data_scene_gui = managers.gui_data:get_scene_gui()
	self._black_bg_ws = self._gui_data_scene_gui:create_screen_workspace()

	if _G.IS_VR then
		self._black_bg_ws:set_pinned_screen(true)
	end

	self._black_bg_ws:panel():rect({
		valign = "scale",
		name = "bg",
		halign = "scale",
		layer = -1000,
		color = Color.black
	})
end

function MenuBackdropGUI:_set_black_borders(manager)
	return

	local manager = self._gui_data_manager or managers.gui_data

	manager:layout_fullscreen_workspace(self._blackborder_workspace)

	local top_border = self._blackborder_workspace:panel():child("top_border")
	local bottom_border = self._blackborder_workspace:panel():child("bottom_border")
	local border_w = self._blackborder_workspace:panel():w()
	local border_h = (self._blackborder_workspace:panel():h() - self.BASE_RES.h) / 2

	top_border:set_position(0, -2)
	top_border:set_size(border_w, border_h + 2)
	bottom_border:set_position(0, self.BASE_RES.h + border_h)
	bottom_border:set_size(border_w, border_h + 2)
end

function MenuBackdropGUI:resolution_changed()
	local manager = self._gui_data_manager or managers.gui_data

	manager:layout_fullscreen_16_9_workspace(self._workspace)
	self:_set_black_borders(manager)
end

function MenuBackdropGUI:_get_correct_fullscreen_texture_size(texture_width, texture_height)
	local aspect = self.BASE_RES.w / self.BASE_RES.h
	local sw = math.min(texture_width, texture_height * aspect)
	local sh = math.min(texture_height, texture_width / aspect)
	local dw = texture_width / sw
	local dh = texture_height / sh

	return dw * self.BASE_RES.w, dh * self.BASE_RES.h
end

function MenuBackdropGUI:set_fullscreen_bitmap_shape(gui_object, size_mod)
	local dw, dh = self:_get_correct_fullscreen_texture_size(gui_object:texture_width(), gui_object:texture_height())

	gui_object:set_size(dw * size_mod, dh * size_mod)
	gui_object:set_center(self.BASE_RES.w * 0.5, self.BASE_RES.h * 0.5)
end

function MenuBackdropGUI:_set_layers_of_layer(layer, set_to)
	self._layer_layers[layer] = set_to

	self:_update_layers()
end

function MenuBackdropGUI:_update_layers()
	local layers_name_table = {
		"base_layer",
		"pattern_layer",
		"item_background_layer",
		"particles_layer",
		"light_layer",
		"item_foreground_layer"
	}
	local num_layers = 0
	local layer = nil

	for i, layer_name in ipairs(layers_name_table) do
		layer = self._panel:child(layer_name)

		layer:set_layer(num_layers)

		num_layers = num_layers + self._layer_layers[i]
	end

	layer:set_layer(num_layers)
end

function MenuBackdropGUI:_create_base_layer()
	local base_layer = self._panel:child("base_layer")

	base_layer:clear()
	self:_set_layers_of_layer(1, 1)

	local bd_base_layer = base_layer:bitmap({
		texture = "guis/textures/pd2/menu_backdrop/bd_baselayer",
		name = "bd_base_layer"
	})

	self:set_fullscreen_bitmap_shape(bd_base_layer, 1)
end

function MenuBackdropGUI:enable_light(enabled)
	local light_layer = self._panel:child("light_layer")

	light_layer:clear()

	if not enabled then
		self:_set_layers_of_layer(5, 0)

		return
	end

	self:_set_layers_of_layer(5, 1)

	local bd_light = light_layer:bitmap({
		texture = "guis/textures/pd2/menu_backdrop/bd_light",
		name = "bd_light"
	})

	bd_light:set_size(light_layer:size())
	bd_light:set_alpha(0)
	bd_light:set_blend_mode("add")

	local function light_flicker_animation(o)
		local alpha = 0
		local acceleration = 0
		local wanted_alpha = math.rand(1) * 0.3
		local flicker_up = true

		while true do
			wait(math.rand(0.1), self._fixed_dt)
			over(math.rand(0.3), function (p)
				o:set_alpha(math.lerp(alpha, wanted_alpha, p))
			end, self._fixed_dt)

			flicker_up = not flicker_up
			alpha = o:alpha()
			wanted_alpha = math.rand(flicker_up and alpha or 0, not flicker_up and alpha or 0.3)
		end
	end

	bd_light:animate(light_flicker_animation)
end

function MenuBackdropGUI:set_pattern(bitmap_texture, alpha, blend_mode)
	local bg_layer = self._panel:child("pattern_layer")

	bg_layer:clear()
	self:_set_layers_of_layer(2, 1)

	if not bitmap_texture then
		return bg_layer
	end

	local object = bg_layer:bitmap({
		name = "object",
		texture = bitmap_texture,
		blend_mode = blend_mode
	})

	self:set_fullscreen_bitmap_shape(object, 1.25)
	object:set_alpha(alpha or 0.2)

	local function mechanic_animation(o)
		local corner_left = -bg_layer:w() * 0.2
		local corner_right = -bg_layer:w() * 0.05
		local corner_top = -bg_layer:h() * 0.2
		local corner_bottom = -bg_layer:h() * 0.05
		local start_x = o:x()
		local start_y = o:y()

		math.random()
		math.random()
		math.random()
		math.random()

		local wanted_x = math.random(corner_left, corner_right)
		local wanted_y = math.random(corner_top, corner_bottom)
		local move_on_x_axis = wanted_x < wanted_y
		local diff = move_on_x_axis and wanted_x - start_x or wanted_y - start_y
		local dir = diff == 0 and 0 or diff / math.abs(diff)
		local overshoot = move_on_x_axis and math.rand(bg_layer:w() * 0.02) or math.rand(bg_layer:h() * 0.02) * dir
		local dir_moved = 0

		local function move_one_axis(p)
			if move_on_x_axis then
				o:set_x(math.lerp(start_x, wanted_x, p))
			else
				o:set_y(math.lerp(start_y, wanted_y, p))
			end
		end

		local function overshoot_one_axis(p)
			if move_on_x_axis then
				o:set_x(math.lerp(wanted_x, wanted_x + overshoot, p))
			else
				o:set_y(math.lerp(wanted_y, wanted_y + overshoot, p))
			end
		end

		local function bringback_one_axis(p)
			if move_on_x_axis then
				o:set_x(math.lerp(wanted_x + overshoot, wanted_x, p))
			else
				o:set_y(math.lerp(wanted_y + overshoot, wanted_y, p))
			end
		end

		math.random()
		math.random()

		while true do
			wait(math.rand(0.1), self._fixed_dt)
			over(math.abs(diff / 20), move_one_axis, self._fixed_dt)
			over(math.abs(overshoot / 20), overshoot_one_axis, self._fixed_dt)
			wait(math.rand(0.1), self._fixed_dt)
			over(math.abs(overshoot / 200), bringback_one_axis, self._fixed_dt)

			dir_moved = dir_moved + 1

			if dir_moved == 2 then
				start_x = wanted_x
				start_y = wanted_y
				wanted_x = math.random(corner_left, corner_right)
				wanted_y = math.random(corner_top, corner_bottom)
				dir_moved = 0
			end

			move_on_x_axis = not move_on_x_axis
			diff = move_on_x_axis and wanted_x - start_x or wanted_y - start_y
			dir = diff == 0 and 0 or diff / math.abs(diff)
			overshoot = move_on_x_axis and math.random(bg_layer:w() * 0.008) or math.random(bg_layer:h() * 0.008) * dir
		end
	end

	object:animate(mechanic_animation)

	return object
end

function MenuBackdropGUI:set_particles_object(bitmap_texture, row, column, num_particles)
	local particles_layer = self._panel:child("particles_layer")

	particles_layer:clear()

	self._row = row
	self._column = column
	self._bitmap_texture = bitmap_texture

	self:_set_layers_of_layer(4, 1)

	for i = 1, num_particles do
		self:_create_particle()
	end
end

function MenuBackdropGUI:_create_particle()
	local particles_layer = self._panel:child("particles_layer")
	local texture_rect_x = (math.random(self._row) - 1) * 32
	local texture_rect_y = (math.random(self._column) - 1) * 32
	local particle = particles_layer:bitmap({
		alpha = 0,
		h = 32,
		w = 32,
		texture = self._bitmap_texture,
		texture_rect = {
			texture_rect_x,
			texture_rect_y,
			32,
			32
		}
	})
	local from_longside = math.random(2) == 1
	local otherside_start = math.random(2) == 1
	local cx = from_longside and math.random(self.BASE_RES.w) or otherside_start and -32 or self.BASE_RES.w + 32
	local cy = not from_longside and math.random(self.BASE_RES.h) or otherside_start and -32 or self.BASE_RES.h + 32

	particle:set_center(cx, cy)
	particle:rotate(math.rand(180))

	local function particle_animation(o, self)
		local start_x = o:center_x()
		local start_y = o:center_y()
		otherside_start = not otherside_start
		local end_x = from_longside and math.random(self.BASE_RES.w) or otherside_start and -32 or self.BASE_RES.w + 32
		local end_y = not from_longside and math.random(self.BASE_RES.h) or otherside_start and -32 or self.BASE_RES.h + 32
		local diff_x = end_x - start_x
		local diff_y = end_y - start_y
		local distance = diff_x * diff_x + diff_y * diff_y
		distance = math.sqrt(distance)
		local dir_x = diff_x * 1 / distance
		local dir_y = diff_y * 1 / distance
		local dt = 0
		local t = 0
		local seconds = distance / math.random(20, 26)
		local wave_t = 0
		local wave_length = math.random(5, 15)
		local alpha_t = 0
		local start_alpha = 0
		local next_alpha = start_alpha

		wait(math.rand(2), self._fixed_dt)
		over(0.2, function (p)
			o:set_alpha(math.lerp(0, start_alpha, p))
		end, self._fixed_dt)

		while true do
			dt = coroutine.yield()
			t = t + (self._fixed_dt and 0.03333333333333333 or dt)

			if seconds <= t then
				break
			end

			wave_t = wave_t + dt * math.rand(0.5, 1.5)
			alpha_t = alpha_t + dt * math.rand(0.25, 0.75)

			o:set_center(math.lerp(start_x, end_x, t / seconds), math.lerp(start_y, end_y, t / seconds))
			o:move(math.sin(wave_t * 90) * -dir_y * wave_length, math.sin(wave_t * 90) * dir_x * wave_length)
			o:set_alpha(next_alpha * math.clamp(seconds - t, 0, 1) * math.clamp(t, 0, 1))

			next_alpha = math.abs(math.sin(alpha_t * 90)) * 0.5 + 0.5

			o:set_blend_mode("add")
		end

		self:_remove_particle(o)
	end

	particle:animate(particle_animation, self)
end

function MenuBackdropGUI:_remove_particle(o)
	local particles_layer = self._panel:child("particles_layer")

	particles_layer:remove(o)
	self:_create_particle()
end

function MenuBackdropGUI:get_new_base_layer()
	local new_layer = self._panel:child("base_layer"):panel({
		layer = self._layer_layers[1]
	})

	self:_set_layers_of_layer(1, self._layer_layers[1] + 1)

	return new_layer
end

function MenuBackdropGUI:get_new_background_layer()
	local new_layer = self._panel:child("item_background_layer"):panel({
		layer = self._layer_layers[3]
	})

	self:_set_layers_of_layer(3, self._layer_layers[3] + 1)

	return new_layer
end

function MenuBackdropGUI:get_new_foreground_layer()
	local new_layer = self._panel:child("item_foreground_layer"):panel({
		layer = self._layer_layers[3]
	})

	self:_set_layers_of_layer(6, self._layer_layers[6] + 1)

	return new_layer
end

function MenuBackdropGUI:set_abstract_background_layers(num_layers)
	self:_set_layers_of_layer(3, num_layers)
end

function MenuBackdropGUI:set_abstract_foreground_layers(num_layers)
	self:_set_layers_of_layer(6, num_layers)
end

function MenuBackdropGUI:background_layers()
	local num_layers = self._layer_layers[1] + self._layer_layers[2]

	return num_layers, self._layer_layers[3]
end

function MenuBackdropGUI:foreground_layers()
	local num_layers = self._layer_layers[1] + self._layer_layers[2] + self._layer_layers[3] + self._layer_layers[4] + self._layer_layers[5]

	return num_layers, self._layer_layers[6]
end

function MenuBackdropGUI:layer()
	return self._panel:layer()
end

function MenuBackdropGUI:set_layer(layer)
	return self._panel:set_layer(layer)
end

function MenuBackdropGUI:show()
	if self._panel then
		self._panel:show()
	end

	if _G.IS_VR then
		return
	end

	if self._blackborder_workspace then
		self._blackborder_workspace:show()
	end

	if self._black_bg_ws then
		self._black_bg_ws:panel():show()
	end
end

function MenuBackdropGUI:hide()
	if self._panel then
		self._panel:hide()
	end

	if self._blackborder_workspace then
		self._blackborder_workspace:hide()
	end

	if self._black_bg_ws then
		self._black_bg_ws:panel():hide()
	end
end

function MenuBackdropGUI:show_layer(layer)
	local layer_panel = self._panel:child(layer)

	if layer_panel then
		layer_panel:show()
	else
		print("MenuBackdropGUI:show_layer: Trying to show non-existing panel '" .. tostring(layer) .. "'.")
	end
end

function MenuBackdropGUI:hide_layer(layer)
	local layer_panel = self._panel:child(layer)

	if layer_panel then
		layer_panel:hide()
	else
		print("MenuBackdropGUI:show_layer: Trying to hide non-existing panel '" .. tostring(layer) .. "'.")
	end
end

function MenuBackdropGUI:panel()
	return self._panel
end

function MenuBackdropGUI:workspace()
	return self._workspace
end

function MenuBackdropGUI:saferect_shape()
	return self._saferect_shape
end

function MenuBackdropGUI:set_panel_to_saferect(panel)
	if not panel then
		return
	end

	local shape = self:saferect_shape()

	panel:set_shape(shape.x, shape.y, shape.w, shape.h)
end

function MenuBackdropGUI:animate_bg_text(text)
	local function animate_text(o)
		local left = true
		local target_speed = 10
		local speed = 15
		local dt = 0
		local start_x = o:x()

		while true do
			dt = coroutine.yield()

			if self._fixed_dt then
				dt = 0.03333333333333333
			end

			speed = speed + (target_speed - speed) * dt * 20

			o:move(speed * dt * (left and -1 or 1), 0)

			if math.abs(o:x() - start_x) > 10 then
				left = not left
				speed = 50
			end
		end
	end
end

function MenuBackdropGUI:update(t, dt)
end

function MenuBackdropGUI:mouse_moved(x, y)
	local particles = self._panel:child("particles_layer")
	local fx, fy = managers.gui_data:safe_to_full_16_9(x, y)

	for _, particle in ipairs(particles:children()) do
		if not particle:has_script() and particle:inside(fx, fy) then
			particle:stop()

			local function fade_anim(o, self)
				local alpha = o:alpha()

				over(0.2, function (p)
					o:set_alpha(math.lerp(alpha, 0, p))
				end)
				self:_remove_particle(o)
			end

			particle:animate(fade_anim, self)
			particle:script()

			return
		end
	end
end

function MenuBackdropGUI:close()
	self:destroy()
end

function MenuBackdropGUI:destroy()
	if self._blackborder_workspace then
		self._gui_data_scene_gui:destroy_workspace(self._blackborder_workspace)
	end

	if self._my_workspace then
		self._gui_data_scene_gui:destroy_workspace(self._workspace)
	else
		self._workspace:panel():remove(self._panel)
	end

	if self._black_bg_ws then
		self._gui_data_scene_gui:destroy_workspace(self._black_bg_ws)

		self._black_bg_ws = nil
	end

	if self._resolution_changed_callback_id then
		managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)
	end
end
