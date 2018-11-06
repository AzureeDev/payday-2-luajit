core:module("CoreViewportManager")
core:import("CoreApp")
core:import("CoreCode")
core:import("CoreEvent")
core:import("CoreManagerBase")
core:import("CoreScriptViewport")
core:import("CoreEnvironmentManager")

ViewportManager = ViewportManager or class(CoreManagerBase.ManagerBase)

function ViewportManager:init(aspect_ratio)
	ViewportManager.super.init(self, "viewport")
	assert(type(aspect_ratio) == "number")

	self._aspect_ratio = aspect_ratio
	self._resolution_changed_event_handler = CoreEvent.CallbackEventHandler:new()
	self._env_manager = CoreEnvironmentManager.EnvironmentManager:new()
	Global.render_debug.render_sky = true
	self._current_camera_position = Vector3()

	if Application:editor() then
		self:preload_environment("core/environments/default")
	end
end

function ViewportManager:update(t, dt)
	for i, svp in ipairs(self:_all_really_active()) do
		svp:_update(i, t, dt)
	end
end

function ViewportManager:paused_update(t, dt)
	self:update(t, dt)
end

function ViewportManager:render()
	for i, svp in ipairs(self:_all_really_active()) do
		svp:_render(i)
	end
end

function ViewportManager:end_frame(t, dt)
	if self._render_settings_change_map then
		local is_resolution_changed = self._render_settings_change_map.resolution ~= nil

		for setting_name, setting_value in pairs(self._render_settings_change_map) do
			RenderSettings[setting_name] = setting_value
		end

		self._render_settings_change_map = nil

		Application:apply_render_settings()
		Application:save_render_settings()

		if is_resolution_changed then
			self:resolution_changed()
		end
	end

	self._current_camera = nil
	self._current_camera_position_updated = nil
	self._current_camera_rotation = nil
end

function ViewportManager:destroy()
	local _, svp = next(self:_all_ao())

	while svp do
		svp:destroy()

		_, svp = next(self:_all_ao())
	end

	self._env_manager:destroy()
end

function ViewportManager:new_vp(x, y, width, height, name, priority)
	local name = name or ""
	local prio = priority or CoreManagerBase.PRIO_DEFAULT
	local svp = CoreScriptViewport._ScriptViewport:new(x, y, width, height, self, name)

	self:_add_accessobj(svp, prio)

	return svp
end

function ViewportManager:vp_by_name(name)
	return self:_ao_by_name(name)
end

function ViewportManager:active_viewports()
	return self:_all_active_requested_by_prio(CoreManagerBase.PRIO_DEFAULT)
end

function ViewportManager:all_really_active_viewports()
	return self:_all_really_active()
end

function ViewportManager:num_active_viewports()
	return #self:active_viewports()
end

function ViewportManager:first_active_viewport()
	local all_active = self:_all_really_active()

	return #all_active > 0 and all_active[1] or nil
end

function ViewportManager:viewports()
	return self:_all_ao()
end

function ViewportManager:add_resolution_changed_func(func)
	self._resolution_changed_event_handler:add(func)

	return func
end

function ViewportManager:remove_resolution_changed_func(func)
	self._resolution_changed_event_handler:remove(func)
end

function ViewportManager:resolution_changed()
	managers.gui_data:resolution_changed()

	if rawget(_G, "tweak_data").resolution_changed then
		rawget(_G, "tweak_data"):resolution_changed()
	end

	for i, svp in ipairs(self:viewports()) do
		svp:_resolution_changed(i)
	end

	self._resolution_changed_event_handler:dispatch()
end

function ViewportManager:editor_reload_environment(name)
	self._env_manager:editor_reload(name)
end

function ViewportManager:editor_add_environment_created_callback(func)
	self._env_manager:editor_add_created_callback(func)
end

function ViewportManager:preload_environment(name)
	self._env_manager:preload_environment(name)
end

function ViewportManager:get_predefined_environment_filter_map()
	return self._env_manager:get_predefined_environment_filter_map()
end

function ViewportManager:get_environment_value(path, data_path_key)
	return self._env_manager:get_value(path, data_path_key)
end

function ViewportManager:has_data_path_key(data_path_key)
	return self._env_manager:has_data_path_key(data_path_key)
end

function ViewportManager:is_deprecated_data_path(data_path)
	return self._env_manager:is_deprecated_data_path(data_path)
end

function ViewportManager:create_global_environment_modifier(data_path_key, is_override, modifier_func)
	for _, vp in ipairs(self:viewports()) do
		vp:create_environment_modifier(data_path_key, is_override, modifier_func)
	end

	self._env_manager:set_global_environment_modifier(data_path_key, is_override, modifier_func)

	return data_path_key
end

function ViewportManager:destroy_global_environment_modifier(data_path_key)
	for _, vp in ipairs(self:viewports()) do
		vp:destroy_environment_modifier(data_path_key)
	end

	self._env_manager:set_global_environment_modifier(data_path_key, nil, nil)
end

function ViewportManager:update_global_environment_value(data_path_key)
	for _, vp in ipairs(self:viewports()) do
		vp:update_environment_value(data_path_key)
	end
end

function ViewportManager:set_default_environment(default_environment_path, blend_duration, blend_bezier_curve)
	self._env_manager:set_default_environment(default_environment_path)

	for _, viewport in ipairs(self:viewports()) do
		viewport:on_default_environment_changed(default_environment_path, blend_duration, blend_bezier_curve)
	end
end

function ViewportManager:default_environment()
	return self._env_manager:default_environment()
end

function ViewportManager:game_default_environment()
	return self._env_manager:game_default_environment()
end

function ViewportManager:editor_reset_environment()
	for _, vp in ipairs(self:active_viewports()) do
		vp:set_environment(self:game_default_environment(), nil, nil, nil, nil)
	end
end

function ViewportManager:set_override_environment(environment_path, blend_duration, blend_bezier_curve)
	self._env_manager:set_override_environment(environment_path)

	for _, viewport in ipairs(self:viewports()) do
		viewport:on_override_environment_changed(environment_path, blend_duration, blend_bezier_curve)
	end
end

function ViewportManager:move_to_front(vp)
	self:_move_ao_to_front(vp)
end

function ViewportManager:_viewport_destroyed(vp)
	self:_del_accessobj(vp)

	self._current_camera = nil
end

function ViewportManager:_get_environment_manager()
	return self._env_manager
end

function ViewportManager:_prioritize_and_activate()
	local old_first_vp = self:first_active_viewport()

	ViewportManager.super._prioritize_and_activate(self)

	local first_vp = self:first_active_viewport()

	if old_first_vp ~= first_vp then
		if old_first_vp then
			old_first_vp:set_first_viewport(false)
		end

		if first_vp then
			first_vp:set_first_viewport(true)
		end
	end
end

function ViewportManager:first_active_world_viewport()
	for _, vp in ipairs(self:active_viewports()) do
		if vp:is_rendering_scene("World") then
			return vp
		end
	end
end

function ViewportManager:get_current_camera()
	if self._current_camera then
		return self._current_camera
	end

	local vps = self:_all_really_active()
	self._current_camera = #vps > 0 and vps[1]:camera()

	return self._current_camera
end

function ViewportManager:get_current_camera_position()
	if self._current_camera_position_updated then
		return self._current_camera_position
	end

	if self:get_current_camera() then
		self:get_current_camera():m_position(self._current_camera_position)

		self._current_camera_position_updated = true
	end

	return self._current_camera_position
end

function ViewportManager:get_current_camera_rotation()
	if self._current_camera_rotation then
		return self._current_camera_rotation
	end

	self._current_camera_rotation = self:get_current_camera() and self:get_current_camera():rotation()

	return self._current_camera_rotation
end

function ViewportManager:get_active_vp()
	return self:active_vp():vp()
end

function ViewportManager:active_vp()
	local vps = self:active_viewports()

	return #vps > 0 and vps[1]
end

local is_win32 = SystemInfo:platform() == Idstring("WIN32")
local is_ps4 = SystemInfo:platform() == Idstring("PS4")
local is_xb1 = SystemInfo:platform() == Idstring("XB1")

function ViewportManager:get_safe_rect()
	local a = is_win32 and 0.032 or (is_ps4 or is_xb1) and 0.05 or 0.075
	local b = 1 - a * 2

	return {
		x = a,
		y = a,
		width = b,
		height = b
	}
end

function ViewportManager:get_safe_rect_pixels()
	local res = RenderSettings.resolution
	local safe_rect_scale = self:get_safe_rect()
	local safe_rect_pixels = {
		x = math.round(safe_rect_scale.x * res.x),
		y = math.round(safe_rect_scale.y * res.y),
		width = math.round(safe_rect_scale.width * res.x),
		height = math.round(safe_rect_scale.height * res.y)
	}

	return safe_rect_pixels
end

function ViewportManager:set_resolution(resolution)
	if RenderSettings.resolution ~= resolution or self._render_settings_change_map and self._render_settings_change_map.resolution ~= resolution then
		self._render_settings_change_map = self._render_settings_change_map or {}
		self._render_settings_change_map.resolution = resolution
	end
end

function ViewportManager:is_fullscreen()
	if self._render_settings_change_map and self._render_settings_change_map.fullscreen ~= nil then
		return self._render_settings_change_map.fullscreen
	else
		return RenderSettings.fullscreen
	end
end

function ViewportManager:set_fullscreen(fullscreen)
	if not RenderSettings.fullscreen ~= not fullscreen or self._render_settings_change_map and not self._render_settings_change_map.fullscreen ~= not fullscreen then
		self._render_settings_change_map = self._render_settings_change_map or {}
		self._render_settings_change_map.fullscreen = not not fullscreen
	end
end

function ViewportManager:set_aspect_ratio(aspect_ratio)
	if RenderSettings.aspect_ratio ~= aspect_ratio or self._render_settings_change_map and self._render_settings_change_map.aspect_ratio ~= aspect_ratio then
		self._render_settings_change_map = self._render_settings_change_map or {}
		self._render_settings_change_map.aspect_ratio = aspect_ratio
		self._aspect_ratio = aspect_ratio
	end
end

function ViewportManager:set_vsync(vsync)
	if RenderSettings.v_sync ~= vsync or self._render_settings_change_map and self._render_settings_change_map.v_sync ~= vsync then
		self._render_settings_change_map = self._render_settings_change_map or {}
		self._render_settings_change_map.v_sync = vsync
		self._v_sync = vsync
	end
end

function ViewportManager:set_adapter_index(adapter_index)
	if RenderSettings.adapter_index ~= adapter_index or self._render_settings_change_map and self._render_settings_change_map.adapter_index ~= adapter_index then
		self._render_settings_change_map = self._render_settings_change_map or {}
		self._render_settings_change_map.adapter_index = adapter_index
	end
end

function ViewportManager:reset_viewport_settings()
	Application:reset_render_settings({
		"adapter_index",
		"aspect_ratio",
		"fullscreen",
		"resolution",
		"v_sync"
	})

	self._render_settings_change_map = nil

	self:resolution_changed()
end

function ViewportManager:aspect_ratio()
	return self._aspect_ratio
end

function ViewportManager:set_aspect_ratio2(aspect_ratio)
	self._aspect_ratio = aspect_ratio
end
