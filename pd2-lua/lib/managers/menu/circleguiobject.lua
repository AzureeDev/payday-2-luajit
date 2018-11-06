CircleGuiObject = CircleGuiObject or class()

function CircleGuiObject:init(panel, config)
	self._panel = panel
	self._radius = config.radius or 20
	self._sides = config.sides or 10
	self._total = config.total or 1
	config.triangles = self:_create_triangles(config)
	config.w = self._radius * 2
	config.h = self._radius * 2
	self._circle = self._panel:polygon(config)
end

function CircleGuiObject:_create_triangles(config)
	local amount = 360 * (config.current or 1) / (config.total or 1)
	local s = self._radius
	local triangles = {}
	local step = 360 / self._sides

	for i = step, amount, step do
		local mid = Vector3(self._radius, self._radius, 0)

		table.insert(triangles, mid)
		table.insert(triangles, mid + Vector3(math.sin(i) * self._radius, -math.cos(i) * self._radius, 0))
		table.insert(triangles, mid + Vector3(math.sin(i - step) * self._radius, -math.cos(i - step) * self._radius, 0))
	end

	return triangles
end

function CircleGuiObject:set_current(current)
	local triangles = self:_create_triangles({
		current = current,
		total = self._total
	})

	self._circle:clear()
	self._circle:add_triangles(triangles)
end

function CircleGuiObject:set_position(x, y)
	self._circle:set_position(x, y)
end

function CircleGuiObject:set_align(h, v)
	v = v or h

	self._circle:set_halign(h)
	self._circle:set_valign(v)
end

function CircleGuiObject:set_layer(layer)
	self._circle:set_layer(layer)
end

function CircleGuiObject:layer()
	return self._circle:layer()
end

function CircleGuiObject:remove()
	self._panel:remove(self._circle)
end

CircleBitmapGuiObject = CircleBitmapGuiObject or class()

function CircleBitmapGuiObject:init(panel, config)
	self._panel = panel
	self._radius = config.radius or 20
	self._sides = config.sides or 64
	self._total = config.total or 1
	self._size = 128
	config.texture_rect = nil
	config.texture = config.image or "guis/textures/pd2/hud_progress_active"
	config.w = self._radius * 2
	config.h = self._radius * 2
	self._circle = self._panel:bitmap(config)

	self._circle:set_render_template(Idstring("VertexColorTexturedRadial"))

	self._alpha = self._circle:color().alpha

	self._circle:set_color(self._circle:color():with_red(0))

	if config.use_bg then
		local bg_config = deep_clone(config)
		bg_config.texture = config.bg or "guis/textures/pd2/hud_progress_bg"
		bg_config.layer = bg_config.layer - 1
		bg_config.blend_mode = "normal"
		self._bg_circle = self._panel:bitmap(bg_config)
	end
end

function CircleBitmapGuiObject:radius()
	return self._radius
end

function CircleBitmapGuiObject:set_current(current)
	local j = math.mod(math.floor(current), 8)
	local i = math.floor(current / 8)

	self._circle:set_color(Color(self._alpha, current, self._circle:color().blue, self._circle:color().green))
end

function CircleBitmapGuiObject:position()
	return self._circle:position()
end

function CircleBitmapGuiObject:set_align(h, v)
	v = v or h

	self._circle:set_halign(h)
	self._circle:set_valign(v)

	if self._bg_circle then
		self._bg_circle:set_halign(h)
		self._bg_circle:set_valign(v)
	end
end

function CircleBitmapGuiObject:set_position(x, y)
	self._circle:set_position(x, y)

	if self._bg_circle then
		self._bg_circle:set_position(x, y)
	end
end

function CircleBitmapGuiObject:set_visible(visible)
	self._circle:set_visible(visible)

	if self._bg_circle then
		self._bg_circle:set_visible(visible)
	end
end

function CircleBitmapGuiObject:visible()
	return self._circle:visible()
end

function CircleBitmapGuiObject:set_alpha(alpha)
	self._circle:set_alpha(alpha)
end

function CircleBitmapGuiObject:alpha()
	self._circle:alpha()
end

function CircleBitmapGuiObject:set_color(color)
	self._circle:set_color(color)
end

function CircleBitmapGuiObject:color()
	return self._circle:color()
end

function CircleBitmapGuiObject:size()
	return self._circle:size()
end

function CircleBitmapGuiObject:set_image(texture)
	self._circle:set_image(texture)
end

function CircleBitmapGuiObject:set_layer(layer)
	self._circle:set_layer(layer)

	if self._bg_circle then
		self._bg_circle:set_layer(layer - 1)
	end
end

function CircleBitmapGuiObject:layer()
	return self._circle:layer()
end

function CircleBitmapGuiObject:remove()
	self._panel:remove(self._circle)

	if self._bg_circle then
		self._panel:remove(self._bg_circle)
	end

	self._panel = nil
end

function CircleBitmapGuiObject:set_depth_mode(mode)
	self._circle:configure({
		depth_mode = mode
	})

	if self._bg_circle then
		self._bg_circle:configure({
			depth_mode = mode
		})
	end
end
