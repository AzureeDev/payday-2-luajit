if core then
	core:module("CoreGuiDataManager")
end

GuiDataManager = GuiDataManager or class()

function GuiDataManager:init(scene_gui, res, safe_rect_pixels, safe_rect, static_aspect_ratio)
	self._ws_size_data = {}
	self._scene_gui = scene_gui
	self._static_resolution = res
	self._safe_rect_pixels = safe_rect_pixels
	self._safe_rect = safe_rect
	self._static_aspect_ratio = static_aspect_ratio

	self:_setup_workspace_data()

	self._workspace_configuration = {}
end

function GuiDataManager:destroy()
end

function GuiDataManager:create_saferect_workspace(workspace_object, scene)
	local ws = (scene or self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)
	self._workspace_configuration[ws:key()] = {
		workspace_object = workspace_object
	}

	self:layout_workspace(ws)

	return ws
end

function GuiDataManager:create_fullscreen_workspace(workspace_object, scene)
	local ws = (scene or self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)
	self._workspace_configuration[ws:key()] = {
		workspace_object = workspace_object
	}

	self:layout_fullscreen_workspace(ws)

	return ws
end

function GuiDataManager:create_fullscreen_16_9_workspace(workspace_object, scene)
	local ws = (scene or self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)
	self._workspace_configuration[ws:key()] = {
		workspace_object = workspace_object
	}

	self:layout_fullscreen_16_9_workspace(ws)

	return ws
end

function GuiDataManager:create_corner_saferect_workspace(workspace_object, scene)
	local ws = (scene or self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)
	self._workspace_configuration[ws:key()] = {
		workspace_object = workspace_object
	}

	self:layout_corner_saferect_workspace(ws)

	return ws
end

function GuiDataManager:create_1280_workspace(workspace_object, scene)
	local ws = (scene or self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)
	self._workspace_configuration[ws:key()] = {
		workspace_object = workspace_object
	}

	self:layout_1280_workspace(ws)

	return ws
end

function GuiDataManager:create_corner_saferect_1280_workspace(workspace_object, scene)
	local ws = (scene or self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)
	self._workspace_configuration[ws:key()] = {
		workspace_object = workspace_object
	}

	self:layout_corner_saferect_1280_workspace(ws)

	return ws
end

function GuiDataManager:destroy_workspace(ws)
	if not ws then
		return
	end

	if ws then
		self._workspace_configuration[ws:key()] = nil
	end

	ws:gui():destroy_workspace(ws)
end

function GuiDataManager:get_scene_gui()
	return self._scene_gui or Overlay:gui()
end

function GuiDataManager:_get_safe_rect_pixels()
	if self._safe_rect_pixels then
		return self._safe_rect_pixels
	end

	return managers.viewport:get_safe_rect_pixels()
end

function GuiDataManager:_get_safe_rect()
	if self._safe_rect then
		return self._safe_rect
	end

	return managers.viewport:get_safe_rect()
end

function GuiDataManager:_aspect_ratio()
	if self._static_aspect_ratio then
		return self._static_aspect_ratio
	end

	return managers.viewport:aspect_ratio()
end

local base_res = {
	x = 1280,
	y = 720
}

function GuiDataManager:get_base_res()
	return base_res.x, base_res.y
end

function GuiDataManager:_setup_workspace_data()
	print("[GuiDataManager:_setup_workspace_data]")

	self._saferect_data = {}
	self._corner_saferect_data = {}
	self._fullrect_data = {}
	self._fullrect_16_9_data = {}
	self._fullrect_1280_data = {}
	self._corner_saferect_1280_data = {}
	local safe_rect = self:_get_safe_rect_pixels()
	local scaled_size = self:scaled_size()
	local res = self._static_resolution or RenderSettings.resolution
	local w = scaled_size.width
	local h = scaled_size.height
	local sh = math.min(safe_rect.height, safe_rect.width / (w / h))
	local sw = math.min(safe_rect.width, safe_rect.height * w / h)
	local x = res.x / 2 - sh * w / h / 2
	local y = res.y / 2 - sw / (w / h) / 2
	self._safe_x = x
	self._safe_y = y
	self._saferect_data.w = w
	self._saferect_data.h = h
	self._saferect_data.width = self._saferect_data.w
	self._saferect_data.height = self._saferect_data.h
	self._saferect_data.x = x
	self._saferect_data.y = y
	self._saferect_data.on_screen_width = sw
	local h_c = w / (safe_rect.width / safe_rect.height)
	h = math.max(h, h_c)
	local w_c = h_c / h
	w = math.max(w, w / w_c)
	self._corner_saferect_data.w = w
	self._corner_saferect_data.h = h
	self._corner_saferect_data.width = self._corner_saferect_data.w
	self._corner_saferect_data.height = self._corner_saferect_data.h
	self._corner_saferect_data.x = safe_rect.x
	self._corner_saferect_data.y = safe_rect.y
	self._corner_saferect_data.on_screen_width = safe_rect.width
	sh = base_res.x / self:_aspect_ratio()
	h = math.max(base_res.y, sh)
	sw = sh / h
	w = math.max(base_res.x, base_res.x / sw)
	self._fullrect_data.w = w
	self._fullrect_data.h = h
	self._fullrect_data.width = self._fullrect_data.w
	self._fullrect_data.height = self._fullrect_data.h
	self._fullrect_data.x = 0
	self._fullrect_data.y = 0
	self._fullrect_data.on_screen_width = res.x
	self._fullrect_data.convert_x = math.floor((w - self._saferect_data.w) / 2)
	self._fullrect_data.convert_y = (h - scaled_size.height) / 2
	self._fullrect_data.corner_convert_x = math.floor((self._fullrect_data.width - self._corner_saferect_data.width) / 2)
	self._fullrect_data.corner_convert_y = math.floor((self._fullrect_data.height - self._corner_saferect_data.height) / 2)
	w = base_res.x
	h = base_res.y
	sh = math.min(res.y, res.x / (w / h))
	sw = math.min(res.x, res.y * w / h)
	x = res.x / 2 - sh * w / h / 2
	y = res.y / 2 - sw / (w / h) / 2
	self._fullrect_16_9_data.w = w
	self._fullrect_16_9_data.h = h
	self._fullrect_16_9_data.width = self._fullrect_16_9_data.w
	self._fullrect_16_9_data.height = self._fullrect_16_9_data.h
	self._fullrect_16_9_data.x = x
	self._fullrect_16_9_data.y = y
	self._fullrect_16_9_data.on_screen_width = sw
	self._fullrect_16_9_data.convert_x = math.floor((self._fullrect_16_9_data.w - self._saferect_data.w) / 2)
	self._fullrect_16_9_data.convert_y = (self._fullrect_16_9_data.h - self._saferect_data.h) / 2
	local aspect = math.clamp(res.x / res.y, 1, 1.7777777777777777)
	w = base_res.x
	h = base_res.x / aspect
	sw = math.min(res.x, res.y * aspect)
	sh = sw / w * h
	x = (res.x - sw) / 2
	y = (res.y - sh) / 2
	self._fullrect_1280_data.w = w
	self._fullrect_1280_data.h = h
	self._fullrect_1280_data.width = self._fullrect_1280_data.w
	self._fullrect_1280_data.height = self._fullrect_1280_data.h
	self._fullrect_1280_data.x = x
	self._fullrect_1280_data.y = y
	self._fullrect_1280_data.on_screen_width = sw
	self._fullrect_1280_data.sw = sw
	self._fullrect_1280_data.sh = sh
	self._fullrect_1280_data.aspect = aspect
	self._fullrect_1280_data.convert_x = math.floor((self._fullrect_data.w - self._fullrect_1280_data.w) / 2)
	self._fullrect_1280_data.convert_y = math.floor((self._fullrect_data.h - self._fullrect_1280_data.h) / 2)
	w = scaled_size.width
	h = scaled_size.width / aspect
	sw = math.min(safe_rect.width, safe_rect.height * aspect)
	sh = sw / w * h
	x = (res.x - sw) / 2
	y = (res.y - sh) / 2
	self._corner_saferect_1280_data.w = w
	self._corner_saferect_1280_data.h = h
	self._corner_saferect_1280_data.width = self._corner_saferect_1280_data.w
	self._corner_saferect_1280_data.height = self._corner_saferect_1280_data.h
	self._corner_saferect_1280_data.x = x
	self._corner_saferect_1280_data.y = y
	self._corner_saferect_1280_data.on_screen_width = sw
end

function GuiDataManager:layout_workspace(ws)
	self:_set_layout(ws, self._saferect_data)
end

function GuiDataManager:layout_fullscreen_workspace(ws)
	self:_set_layout(ws, self._fullrect_data)
end

function GuiDataManager:layout_fullscreen_16_9_workspace(ws)
	self:_set_layout(ws, self._fullrect_16_9_data)
end

function GuiDataManager:layout_corner_saferect_workspace(ws)
	self:_set_layout(ws, self._corner_saferect_data)
end

function GuiDataManager:layout_1280_workspace(ws)
	self:_set_layout(ws, self._fullrect_1280_data)
end

function GuiDataManager:layout_corner_saferect_1280_workspace(ws)
	self:_set_layout(ws, self._corner_saferect_1280_data)
end

function GuiDataManager:_set_linked_ws(ws, obj, screen_data)
	local rot = obj:rotation()
	local size = obj:oobb():size()
	local w = size.x
	local h = size.y
	local on_screen_height = screen_data.on_screen_width / screen_data.w * screen_data.h
	local gui = ws:gui()
	local scale_w = w / gui:width()
	local scale_h = h / gui:height()
	local x_axis = Vector3(scale_w * screen_data.on_screen_width, 0, 0)

	mvector3.rotate_with(x_axis, rot)

	local y_axis = Vector3(0, scale_h * on_screen_height, 0)

	mvector3.rotate_with(y_axis, rot)

	local center = Vector3(w / 2, h / 2, 0)

	mvector3.rotate_with(center, rot)

	local offset = Vector3(screen_data.x * scale_w, screen_data.y * scale_h, 0)

	mvector3.rotate_with(offset, rot)
	ws:set_linked(screen_data.w, screen_data.h, obj, obj:position() - center + offset, x_axis, y_axis)
end

function GuiDataManager:_set_layout(ws, screen_data)
	self._ws_size_data[ws:key()] = screen_data

	if self._workspace_objects then
		local conf = self._workspace_configuration[ws:key()]
		local is_screen = conf and conf.workspace_object == "screen"

		if not is_screen then
			local obj = conf and conf.workspace_object and self._workspace_objects[conf.workspace_object] or self._workspace_objects.default

			if obj then
				self:_set_linked_ws(ws, obj, screen_data)

				return
			end
		end
	end

	ws:set_screen(screen_data.w, screen_data.h, screen_data.x, screen_data.y, screen_data.on_screen_width)
end

function GuiDataManager:scaled_size()
	local w = math.round(self:_get_safe_rect().width * base_res.x)
	local h = math.round(self:_get_safe_rect().height * base_res.y)

	return {
		x = 0,
		y = 0,
		width = w,
		height = h
	}
end

function GuiDataManager:safe_scaled_size()
	return self._saferect_data
end

function GuiDataManager:corner_scaled_size()
	return self._corner_saferect_data
end

function GuiDataManager:full_scaled_size()
	return self._fullrect_data
end

function GuiDataManager:full_16_9_size()
	return self._fullrect_16_9_data
end

function GuiDataManager:full_1280_size()
	return self._fullrect_1280_data
end

function GuiDataManager:convert_pos(...)
	local x, y = self:convert_pos_float(...)

	return math.round(x), math.round(y)
end

function GuiDataManager:convert_pos_float(from_ws, to_ws, in_x, in_y)
	local from = self._ws_size_data[from_ws:key()]
	local to = self._ws_size_data[to_ws:key()]

	if not from or not to then
		return
	end

	local scale = from.on_screen_width / from.w
	local x = in_x * scale + from.x
	local y = in_y * scale + from.y
	local scale = to.on_screen_width / to.w

	return (x - to.x) / scale, (y - to.y) / scale
end

function GuiDataManager:full_to_full_16_9(in_x, in_y)
	return self:safe_to_full_16_9(self:full_to_safe(in_x, in_y))
end

function GuiDataManager:safe_to_full_16_9(in_x, in_y)
	return self._fullrect_16_9_data.convert_x + in_x, self._fullrect_16_9_data.convert_y + in_y
end

function GuiDataManager:full_16_9_to_safe(in_x, in_y)
	return in_x - self._fullrect_16_9_data.convert_x, in_y - self._fullrect_16_9_data.convert_y
end

function GuiDataManager:safe_to_full(in_x, in_y)
	return self._fullrect_data.convert_x + in_x, self._fullrect_data.convert_y + in_y
end

function GuiDataManager:full_to_safe(in_x, in_y)
	return in_x - self._fullrect_data.convert_x, in_y - self._fullrect_data.convert_y
end

function GuiDataManager:corner_safe_to_full(in_x, in_y)
	return self._fullrect_data.corner_convert_x + in_x, self._fullrect_data.corner_convert_y + in_y
end

function GuiDataManager:y_safe_to_full(in_y)
	return self._fullrect_data.convert_y + in_y
end

function GuiDataManager:resolution_changed()
	self:_setup_workspace_data()
end

function GuiDataManager:set_scene_gui(gui)
	self._scene_gui = gui
end

function GuiDataManager:set_workspace_objects(workspace_objects)
	self._workspace_objects = workspace_objects
end

function GuiDataManager:add_workspace_object(name, workspace_object)
	self._workspace_objects = self._workspace_objects or {}
	self._workspace_objects[name] = workspace_object
end
