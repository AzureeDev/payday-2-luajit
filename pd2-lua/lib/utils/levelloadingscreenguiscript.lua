require("lib/managers/menu/BoxGuiObject")

function alive(obj)
	if obj and obj:alive() then
		return true
	end

	return false
end

function Idstring(str)
	return str
end

local function make_fine_text(text_obj)
	local x, y, w, h = text_obj:text_rect()

	text_obj:set_size(w, h)
	text_obj:set_position(math.round(text_obj:x()), math.round(text_obj:y()))
end

local function shrinkwrap(panel, padding)
	padding = padding or {}
	local padding_top = padding[1] or 0
	local padding_right = padding[2] or padding_top
	local padding_bottom = padding[3] or padding_top
	local padding_left = padding[4] or padding_right
	local children = panel:children()
	local min_x = math.huge
	local max_x = -math.huge
	local min_y = math.huge
	local max_y = -math.huge

	for _, child in ipairs(children) do
		if child:world_left() < min_x then
			min_x = child:world_left()
		end

		if max_x < child:world_right() then
			max_x = child:world_right()
		end

		if child:world_top() < min_y then
			min_y = child:world_top()
		end

		if max_y < child:world_bottom() then
			max_y = child:world_bottom()
		end
	end

	local offset_x = min_x - panel:world_x()
	local offset_y = min_y - panel:world_y()

	if min_x ~= 0 or min_y ~= 0 then
		for _, child in ipairs(children) do
			child:set_x(child:x() - offset_x + padding_left)
			child:set_y(child:y() - offset_y + padding_top)
		end
	end

	panel:set_world_position(min_x - padding_left, min_y - padding_top)
	panel:set_size(max_x - min_x + padding_right + padding_left, max_y - min_y + padding_top + padding_bottom)
end

LevelLoadingScreenGuiScript = LevelLoadingScreenGuiScript or class()

function LevelLoadingScreenGuiScript:init(scene_gui, res, progress, base_layer)
	self._scene_gui = scene_gui
	self._res = res
	self._base_layer = base_layer
	self._level_tweak_data = arg.load_level_data.level_tweak_data
	self._gui_tweak_data = arg.load_level_data.gui_tweak_data
	self._menu_tweak_data = arg.load_level_data.menu_tweak_data
	self._scale_tweak_data = arg.load_level_data.scale_tweak_data
	self._gui_data = arg.load_level_data.gui_data
	self._workspace_size = self._gui_data.workspace_size
	self._saferect_size = self._gui_data.saferect_size
	local challenges = arg.load_level_data.challenges
	local safe_rect_pixels = self._gui_data.safe_rect_pixels
	local safe_rect = self._gui_data.safe_rect
	local aspect_ratio = self._gui_data.aspect_ratio
	self._safe_rect_pixels = safe_rect_pixels
	self._safe_rect = safe_rect
	self._gui_data_manager = GuiDataManager:new(self._scene_gui, res, safe_rect_pixels, safe_rect, aspect_ratio)
	self._back_drop_gui = MenuBackdropGUI:new(nil, self._gui_data_manager, true)

	self._back_drop_gui:set_pattern("guis/textures/loading/loading_foreground", 1)

	local base_panel = self._back_drop_gui:get_new_base_layer()
	local level_image = base_panel:bitmap({
		layer = 0,
		texture = self._gui_data.bg_texture
	})

	level_image:set_alpha(0.5)

	local level_image_ratio = level_image:texture_width() / level_image:texture_height()

	level_image:set_size(level_image:parent():h() * level_image_ratio, level_image:parent():h())
	level_image:set_center_x(level_image:parent():w() / 2)
	level_image:set_y(0)

	local background_fullpanel = self._back_drop_gui:get_new_background_layer()
	local background_safepanel = self._back_drop_gui:get_new_background_layer()

	self._back_drop_gui:set_panel_to_saferect(background_safepanel)

	if arg.load_level_data.tip then
		self._loading_hint = self:_make_loading_hint(background_safepanel, arg.load_level_data.tip)
	end

	self._indicator = background_safepanel:bitmap({
		texture = "guis/textures/icon_loading",
		name = "indicator",
		layer = 0
	})
	self._level_title_text = background_safepanel:text({
		y = 0,
		vertical = "bottom",
		h = 36,
		text_id = "debug_loading_level",
		font_size = 36,
		align = "left",
		font = "fonts/font_large_mf",
		halign = "left",
		layer = 0,
		color = Color.white
	})

	self._level_title_text:set_text(utf8.to_upper(self._level_title_text:text()))

	local _, _, w, h = self._level_title_text:text_rect()

	self._level_title_text:set_size(w, h)
	self._indicator:set_right(self._indicator:parent():w())
	self._level_title_text:set_right(self._indicator:left())

	local bg_loading_text = background_fullpanel:text({
		vertical = "top",
		h = 80,
		text_id = "debug_loading_level",
		font_size = 80,
		align = "right",
		font = "fonts/font_eroded",
		y = 0,
		layer = 0,
		color = Color(0.3, 0.3803921568627451, 0.8392156862745098, 1)
	})

	bg_loading_text:set_text(utf8.to_upper(bg_loading_text:text()))

	local x = self._level_title_text:world_right()
	local y = self._level_title_text:world_center_y()

	bg_loading_text:set_world_right(x)
	bg_loading_text:set_world_center_y(y)
	bg_loading_text:move(13, 3)
	self._back_drop_gui:animate_bg_text(bg_loading_text)

	local coords = arg.load_level_data.controller_coords

	if coords then
		self._controller = self:_make_controller_hint(background_safepanel, coords)

		if arg.load_level_data.tip then
			self._controller:move(0, -110)
		end
	end
end

function LevelLoadingScreenGuiScript:update(progress, t, dt)
	self._indicator:rotate(180 * dt)
end

function LevelLoadingScreenGuiScript:_make_loading_hint(parent, tip)
	local container = parent:panel()
	local hint_text_width = 450
	local hint_title_top_offset = 5
	local font = "fonts/font_medium_mf"
	local font_size = 24
	local hint_image = container:bitmap({
		height = 192,
		width = 192,
		texture = "guis/textures/loading/hints/" .. tip.image
	})
	local hint_title = container:text({
		text = tip.title,
		font = font,
		font_size = font_size,
		color = Color.white
	})
	local hint_box = container:panel()
	local hint_text = hint_box:text({
		wrap = true,
		word_wrap = true,
		text = tip.text,
		font = font,
		font_size = font_size,
		color = Color.white,
		width = hint_text_width
	})
	local hint_index_text = hint_box:text({
		text = string.format("%d / %d", tip.index, tip.total),
		font = font,
		font_size = font_size,
		color = Color(0.3, 1, 1, 1)
	})

	make_fine_text(hint_title)
	make_fine_text(hint_text)
	make_fine_text(hint_index_text)
	hint_box:set_width(hint_text_width + 187 + 16)
	hint_box:set_height(142)
	hint_text:set_lefttop(187, 16)
	hint_index_text:set_rightbottom(hint_box:width() - 16, hint_box:height() - 16)
	hint_title:set_leftbottom(hint_text:left(), hint_box:top())
	hint_image:set_center_y(hint_box:center_y())
	BoxGuiObject:new(hint_box, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	shrinkwrap(container)
	container:set_center_x(parent:width() * 0.5 - 20)
	container:set_bottom(parent:height() - 50)

	return container
end

function LevelLoadingScreenGuiScript:_make_controller_hint(parent, coords)
	local container = parent:panel()
	local font = arg.load_level_data.coords_font or "fonts/font_medium_mf"
	local font_size = arg.load_level_data.coords_font_size or 24

	if not arg.load_level_data.controller_shapes then
		local controller_shapes = {
			{
				position = {
					cy = 0.5,
					cx = 0.5
				},
				texture_rect = {
					0,
					0,
					512,
					256
				}
			}
		}
	end

	local controllers = {}
	local controller, position = nil

	for i, shape in ipairs(controller_shapes) do
		controller = container:bitmap({
			texture = arg.load_level_data.controller_image or "guis/textures/controller",
			layer = i,
			texture_rect = shape.texture_rect
		})
		position = shape.position or {}

		controller:set_center(container:w() * (position.cx or 0.5), container:h() * (position.cy or 0.5))

		if position.x then
			if position.x < 0 then
				controller:set_right(container:w() + position.x)
			else
				controller:set_left(position.x)
			end
		end

		if position.y then
			if position.y < 0 then
				controller:set_bottom(container:h() + position.y)
			else
				controller:set_top(position.y)
			end
		end

		controller:move(position.mx or 0, position.my or 0)
		table.insert(controllers, controller)
	end

	for id, data in pairs(coords) do
		controller = controllers[data.c or 1]
		data.text = container:text({
			name = data.id,
			text = data.string,
			font_size = font_size,
			font = font,
			align = data.align,
			vertical = data.vertical,
			color = data.color
		})
		local _, _, w, h = data.text:text_rect()

		data.text:set_size(w, h)

		if data.x then
			local x = controller:x() + data.x
			local y = controller:y() + data.y

			if data.align == "left" then
				data.text:set_left(x)
			elseif data.align == "right" then
				data.text:set_right(x)
			elseif data.align == "center" then
				data.text:set_center_x(x)
			end

			if data.vertical == "top" then
				data.text:set_top(y)
			elseif data.vertical == "bottom" then
				data.text:set_bottom(y)
			else
				data.text:set_center_y(y)
			end
		end
	end

	return container
end

function LevelLoadingScreenGuiScript:destroy()
	if alive(self._saferect) then
		self._scene_gui:destroy_workspace(self._saferect)

		self._saferect = nil
	end

	if alive(self._fullrect) then
		self._scene_gui:destroy_workspace(self._fullrect)

		self._fullrect = nil
	end

	if alive(self._ws) then
		self._scene_gui:destroy_workspace(self._ws)

		self._ws = nil
	end

	if self._back_drop_gui then
		self._back_drop_gui:destroy()

		self._back_drop_gui = nil
	end
end

function LevelLoadingScreenGuiScript:visible()
	return self._ws:visible()
end

function LevelLoadingScreenGuiScript:set_visible(visible)
	if visible then
		self._ws:show()
	else
		self._ws:hide()
	end
end
