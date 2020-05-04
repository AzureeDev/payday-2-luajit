core:module("CoreDebugManager")
core:import("CoreEngineAccess")
core:import("CoreSequenceManager")
core:import("CoreDebug")
core:import("CoreClass")
core:import("CoreTable")
core:import("CoreEngineAccess")

DebugManager = DebugManager or class()
DebugManager.ROT_LINE_LENGTH = 20
DebugManager.reload = true

function DebugManager:init()
	self._enabled = false
	self._enabled_paused = false
	DebugManager.reload = false
	self._system_list = {
		gui = GUIDebug:new(),
		func = FuncDebug:new(),
		pos = PosDebug:new(),
		rot = RotDebug:new(),
		graph = GraphDebug:new(),
		hijack = HijackDebug:new(),
		simple = SimpleDebug:new(),
		print = PrintDebug:new(),
		profiler = ProfilerDebug:new(),
		macro = MacroDebug:new(self),
		mem = MemoryDebug:new(),
		console = ConsoleDebug:new(),
		menu = MenuDebug:new()
	}

	for name, system in pairs(self._system_list) do
		self[name] = system
	end

	self.pos:set_max_count("ray", 10)
	self.pos:set_skip_lines("ray", true)
end

function DebugManager:destroy()
	for _, system in pairs(self._system_list) do
		if system.destroy then
			system:destroy()
		end
	end
end

function DebugManager:update(t, dt)
	if self._enabled then
		if DebugManager.reload then
			self:reloaded()
		end

		for _, system in pairs(self._system_list) do
			system:update(t, dt)
		end
	end
end

function DebugManager:paused_update(t, dt)
	if self._enabled_paused then
		if DebugManager.reload then
			self:reloaded()
		end

		for _, system in pairs(self._system_list) do
			system:paused_update(t, dt)
		end
	end
end

function DebugManager:reloaded()
	DebugManager.reload = false

	for _, system in pairs(self._system_list) do
		system:reloaded()
	end
end

function DebugManager:clear(...)
	for _, system in pairs(self._system_list) do
		system:clear(...)
	end
end

function DebugManager:toggle_enabled()
	self:set_enabled(not self._enabled)
end

function DebugManager:toggle_enabled_paused()
	self:set_enabled_paused(not self._enabled_paused)
end

function DebugManager:toggle_enabled_all()
	self:set_enabled(not self._enabled)
	self:set_enabled_paused(not self._enabled_paused)

	for _, system in pairs(self._system_list) do
		system:toggle_enabled()
	end
end

function DebugManager:enabled()
	return self._enabled
end

function DebugManager:enabled_paused()
	return self._enabled_paused
end

function DebugManager:set_enabled(enabled)
	if self._enabled ~= enabled then
		if enabled then
			Global.render_debug.draw_enabled = true
		end

		self._enabled = enabled
	end
end

function DebugManager:set_enabled_paused(enabled)
	if self._enabled_paused ~= enabled then
		if enabled then
			Global.render_debug.draw_enabled = true
		end

		self._enabled_paused = enabled
	end
end

function DebugManager:set_systems_enabled(enabled, include_non_preferred)
	for system_name, system in pairs(self._system_list) do
		if include_non_preferred or not system.IS_PREFERRED_DISABLED then
			system:set_enabled(enabled)
		end
	end
end

function DebugManager:set_enabled_all(enabled, include_non_preferred)
	self:set_enabled(enabled)
	self:set_enabled_paused(enabled)
	self:set_systems_enabled(enabled, include_non_preferred)
end

function DebugManager.trim_list(list, max_count)
	if max_count > 0 then
		while max_count < #list do
			table.remove(list, 1)
		end
	end
end

function DebugManager.draw_pos_list(list, skip_lines)
	local old_point = nil

	for index, point in ipairs(list) do
		DebugManager.draw_point(index, #list, old_point, point, skip_lines)

		old_point = point
	end
end

function DebugManager.draw_point(index, count, old_point, point, skip_lines)
	local color = nil

	if point._color then
		color = point._color
	else
		color = DebugManager.get_color_by_index(index, count)
	end

	if not skip_lines and old_point then
		local dir = (point._pos - old_point._pos):normalized()

		Application:draw_line_unpaused(old_point._pos, point._pos, unpack(color))
		Application:draw_cone(point._pos, point._pos - dir * point._radius * 2, point._radius, unpack(color))
	else
		Application:draw_sphere_unpaused(point._pos, point._radius, unpack(color))
	end
end

function DebugManager.draw_rot_list(list)
	for index, point in ipairs(list) do
		local color = nil

		if point._color then
			color = point._color
		else
			color = DebugManager.get_color_by_index(index, #list)
		end

		Application:draw_sphere_unpaused(point._pos, point._radius, unpack(color))
		Application:draw_line_unpaused(point._pos, point._pos + point._rot:x() * DebugManager.ROT_LINE_LENGTH, 1, 0, 0)
		Application:draw_line_unpaused(point._pos, point._pos + point._rot:y() * DebugManager.ROT_LINE_LENGTH, 0, 1, 0)
		Application:draw_line_unpaused(point._pos, point._pos + point._rot:z() * DebugManager.ROT_LINE_LENGTH, 0, 0, 1)
	end
end

function DebugManager.get_color_by_index(index, count)
	local scale = nil

	if count > 1 then
		scale = (index - 1) / (count - 1)
	else
		scale = 0
	end

	return DebugManager.get_color(scale)
end

function DebugManager.get_color(scale)
	if scale < 0.25 then
		local b = DebugManager.get_interval_brightness(scale, 0, 0.25)

		return {
			1,
			b,
			0
		}
	elseif scale < 0.5 then
		local b = DebugManager.get_interval_brightness(scale, 0.25, 0.5)

		return {
			1 - b,
			1,
			0
		}
	elseif scale < 0.75 then
		local b = DebugManager.get_interval_brightness(scale, 0.5, 0.75)

		return {
			0,
			1,
			b
		}
	else
		local b = DebugManager.get_interval_brightness(scale, 0.75, 1)

		return {
			0,
			1 - b,
			1
		}
	end
end

function DebugManager.get_interval_brightness(scale, min, max)
	return (scale - min) / (max - min)
end

function DebugManager.args_to_string(...)
	local s = ""

	for i, arg in pairs({
		...
	}) do
		if i > 1 then
			s = s .. "    " .. tostring(arg)
		else
			s = tostring(arg)
		end
	end

	return s
end

function DebugManager:qa_debug(username)
end

DebugPoint = DebugPoint or class()

function DebugPoint:init(pos, rot, red, green, blue, radius)
	self._pos = pos
	self._rot = rot

	if red then
		self._color = {
			red or 1,
			green or 1,
			blue or 1
		}
	end

	self._radius = radius or 5
end

DebugFunction = DebugFunction or class()

function DebugFunction:init(func, start_delay, interval, call_count)
	self._func = func
	start_delay = tonumber(start_delay)
	self._start_time = start_delay and TimerManager:wall():time() + start_delay
	self._interval = tonumber(interval)
	self._last_call_time = nil
	self._call_count = tonumber(call_count)
end

function DebugFunction:update(t, dt)
	local can_start = not self._start_time or self._start_time <= t
	local interval_done = not self._last_call_time or not self._interval or self._interval <= t - self._last_call_time

	if can_start and interval_done then
		local remove, new_interval, new_call_count = self._func(t, dt, self._num_calls_to_make, self._start_time, self._interval)
		self._interval = tonumber(new_interval) or self._interval
		self._call_count = tonumber(new_call_count) or self._call_count
		self._last_call_time = t

		if self._call_count then
			self._call_count = self._call_count - 1
			remove = remove or self._call_count <= 0
		end

		return remove
	else
		return false
	end
end

DebugRaycast = DebugRaycast or class()
DebugRaycast.MAX_ARROW_SIZE = 8

function DebugRaycast:init(copy_ray_wrapper)
	self._arrow_size = nil
	self._distance = nil
	self._radius = copy_ray_wrapper and copy_ray_wrapper:radius()
	self._bundle = copy_ray_wrapper and copy_ray_wrapper:bundle()
	self._color = copy_ray_wrapper and copy_ray_wrapper:color() or {
		1,
		1,
		1
	}
	self._normal = copy_ray_wrapper and copy_ray_wrapper:normal() or nil
	self._normal_color = copy_ray_wrapper and copy_ray_wrapper:normal_color() or {
		0,
		0,
		0
	}
	self._from = copy_ray_wrapper and copy_ray_wrapper:from()
	self._to = copy_ray_wrapper and copy_ray_wrapper:to()

	self:update_from_to_vars()
end

function DebugRaycast:from()
	return self._from
end

function DebugRaycast:set_from(from)
	self._from = from

	if self._to then
		self._dir = (self._to - self._from):normalized()
	end
end

function DebugRaycast:to()
	return self._to
end

function DebugRaycast:set_to(to)
	self._to = to

	self:update_from_to_vars()
end

function DebugRaycast:update_from_to_vars()
	if self._from and self._to then
		self._dir = (self._to - self._from):normalized()
		self._distance = (self._to - self._from):length()

		if self._distance < self.MAX_ARROW_SIZE then
			self._arrow_size = self._distance
		else
			self._arrow_size = self.MAX_ARROW_SIZE
		end
	end
end

function DebugRaycast:radius()
	return self._radius
end

function DebugRaycast:set_radius(radius)
	self._radius = radius
end

function DebugRaycast:bundle()
	return self._bundle
end

function DebugRaycast:set_bundle(bundle)
	self._bundle = bundle
end

function DebugRaycast:color()
	return self._color
end

function DebugRaycast:set_color(red, green, blue)
	self._color = {
		red or 1,
		green or 1,
		blue or 1
	}
end

function DebugRaycast:normal()
	return self._normal
end

function DebugRaycast:set_normal(normal)
	self._normal = normal
end

function DebugRaycast:normal_color()
	return self._normal_color
end

function DebugRaycast:set_normal_color(red, green, blue)
	self._normal_color = {
		red or 1,
		green or 1,
		blue or 1
	}
end

function DebugRaycast:update(t, dt)
	if self._from and self._to then
		if self._radius then
			if self._bundle then
				Application:draw_line_unpaused(self._from, self._to, unpack(self._color))

				local orthogonal_func = self._dir:orthogonal_func()

				for i = 1, self._bundle - 1 do
					local ratio = (i - 1) / (self._bundle - 1)
					local offset = orthogonal_func(ratio) * self._radius

					Application:draw_line_unpaused(self._from + offset, self._to + offset, unpack(self._color))
				end
			else
				Application:draw_cylinder(self._from, self._to, self._radius, unpack(self._color))
				Application:draw_sphere_unpaused(self._from, self._radius, unpack(self._color))
				Application:draw_sphere_unpaused(self._to, self._radius, unpack(self._color))
			end
		else
			Application:draw_line_unpaused(self._from, self._to, unpack(self._color))
		end

		Application:draw_sphere_unpaused(self._from, self._arrow_size / 2, unpack(self._color))
		Application:draw_cone(self._to, self._to - self._dir * self._arrow_size, self._arrow_size / 2, unpack(self._color))

		if self._normal then
			Application:draw_line_unpaused(self._to, self._to + self._normal * 100, unpack(self._normal_color))
		end
	end
end

DebugProfilerCounter = DebugProfilerCounter or class()

function DebugProfilerCounter:init(name, index, obj, func_name, color, min, max, enabled, graph_enabled, gui_enabled, instance_override)
	self._instance_override = instance_override
	self._old_func = nil
	self._new_func = nil
	self._name = tostring(name)
	self._index = tonumber(index)
	self._obj = obj
	self._func_name = func_name
	self._enabled = false
	self._graph_enabled = false
	self._gui_enabled = false

	self:set_color(color)
	self:set_range(min, max)
	self:set_enabled(enabled)
	self:set_graph_enabled(graph_enabled)
	self:set_gui_enabled(gui_enabled)

	self._initialized = true

	if self._graph_enabled then
		self:update_graph()
	end

	self:update_gui()
end

function DebugProfilerCounter:reload()
	if not self._instance_override and self._enabled then
		self._old_func = nil

		self:set_enabled(false)
		self:set_enabled(true)
	end
end

function DebugProfilerCounter:name()
	return self._name
end

function DebugProfilerCounter:index()
	return self._index
end

function DebugProfilerCounter:set_index(index)
	if self._index and self._gui_enabled then
		managers.debug.gui:set(self._index, nil)
	end

	self._index = tonumber(index)

	self:update_gui()
end

function DebugProfilerCounter:enabled()
	return self._enabled
end

function DebugProfilerCounter:set_enabled(enabled)
	enabled = not not enabled

	if self._enabled ~= enabled then
		if enabled then
			local obj_class = getmetatable(self._obj)

			if not obj_class then
				self._instance_override = true
				obj_class = self._obj
			end

			local meta_func = obj_class[self._func_name]
			local instance_func = self._obj[self._func_name]
			local name = self._name
			local old_func, obj = nil

			if self._instance_override or self._instance_override == nil and meta_func ~= instance_func then
				old_func = instance_func
				self._instance_override = true
				obj = self._obj
			else
				old_func = meta_func
				self._instance_override = false
				obj = obj_class
			end

			self._old_func = self._old_func or old_func

			function self._new_func(...)
				local id = Profiler:start(name)
				local return_list = {
					old_func(...)
				}

				Profiler:stop(id)

				return unpack(return_list)
			end

			rawset(obj, self._func_name, self._new_func)
			Application:console_command("profiler add " .. self._name)
		else
			Application:console_command("profiler remove " .. self._name)

			if self._old_func then
				local obj = nil

				if self._instance_override then
					obj = self._obj
				else
					obj = getmetatable(self._obj)
				end

				rawset(obj, self._func_name, self._old_func)
			end
		end

		self._enabled = enabled

		self:update_graph()
		self:update_gui()
	end
end

function DebugProfilerCounter:graph_enabled()
	return self._graph_enabled
end

function DebugProfilerCounter:set_graph_enabled(enabled)
	enabled = not not enabled

	if self._graph_enabled ~= enabled then
		self._graph_enabled = enabled

		self:update_graph()
		self:update_gui()
	end
end

function DebugProfilerCounter:gui_enabled()
	return self._gui_enabled
end

function DebugProfilerCounter:set_gui_enabled(enabled)
	enabled = not not enabled

	if self._gui_enabled ~= enabled then
		if self._index and self._gui_enabled then
			managers.debug.gui:set(self._index, nil)
		end

		self._gui_enabled = enabled

		self:update_gui()
	end
end

function DebugProfilerCounter:range()
	return self._min, self._max
end

function DebugProfilerCounter:set_range(min, max)
	self._min = tonumber(min) or 0
	self._max = math.max(self._min, tonumber(max) or 100)

	self:update_graph()
end

function DebugProfilerCounter:color()
	return self._color
end

function DebugProfilerCounter:set_color(color)
	if color and color.type_name ~= "Color" then
		color = nil
	end

	self._color = color or Color(1, 1, 1, 1)
	self._color = Color(self._color.a, math.round(math.clamp(self._color.r, 0, 1) * 15) / 15, math.round(math.clamp(self._color.g, 0, 1) * 15) / 15, math.round(math.clamp(self._color.b, 0, 1) * 15) / 15)

	self:update_graph()
	self:update_gui()
end

function DebugProfilerCounter:update_graph()
	if self._initialized then
		if self._enabled and self._graph_enabled then
			Application:console_command("graph counter " .. self._name .. " color " .. string.format("%X%X%X", self._color.r * 15, self._color.g * 15, self._color.b * 15) .. " range " .. self._min .. " " .. self._max)
		else
			Application:console_command("graph hide " .. self._name)
		end
	end
end

function DebugProfilerCounter:update_gui()
	if self._initialized and self._index and self._gui_enabled then
		managers.debug.gui:set(self._index, nil)

		if self._enabled and self._graph_enabled then
			managers.debug.gui:set(self._index, self._name)
			managers.debug.gui:set_color(self._index, self._color.r, self._color.g, self._color.b, self._color.a)
		end
	end
end

BaseDebug = BaseDebug or class()

function BaseDebug:init()
	self._enabled = false
end

function BaseDebug:clear()
end

function BaseDebug:update(t, dt)
end

function BaseDebug:paused_update(t, dt)
	self:update(t, dt)
end

function BaseDebug:set_enabled(enabled)
	self._enabled = enabled
end

function BaseDebug:get_enabled()
	return self._enabled
end

function BaseDebug:toggle_enabled()
	self:set_enabled(not self._enabled)
end

function BaseDebug:reloaded()
end

FuncDebug = FuncDebug or class(BaseDebug)

function FuncDebug:init()
	FuncDebug.super.init(self)

	self._func_list = {}
end

function FuncDebug:update(t, dt)
	for index, wrapped_func in pairs(self._func_list) do
		if wrapped_func:update(t, dt) then
			self:remove(index)
		end
	end
end

function FuncDebug:clear()
	FuncDebug.super.clear(self)

	self._func_list = {}
end

function FuncDebug:add(func, start_delay, interval, call_count)
	self:set(#self._func_list + 1, func, start_delay, interval, call_count)
end

function FuncDebug:set(index, func, start_delay, interval, call_count)
	index = index or 1

	if func then
		if type(func) == "function" then
			self._func_list[index] = DebugFunction:new(func, start_delay, interval, call_count)
		else
			cat_error("debug", "Tried to set invalid function \"" .. tostring(func) .. "\" to index \"" .. tostring(index) .. "\".")
		end
	else
		self:remove(index)
	end
end

function FuncDebug:delete(func, all)
	local count = 0

	for index, wrapped_func in ipairs(self._func_list) do
		if wrapped_func:get_func() == func then
			self:remove(index)

			count = count + 1

			if not all then
				break
			end
		end
	end

	return count
end

function FuncDebug:remove(index)
	self._func_list[index] = nil
end

PosDebug = PosDebug or class(BaseDebug)

function PosDebug:init()
	PosDebug.super.init(self)

	self._pos_list = {}
	self._max_pos_count = 200
	self._max_pos_count_map = {}
	self._skip_lines_map = {}
end

function PosDebug:update(t, dt)
	for list_index, list in pairs(self._pos_list) do
		DebugManager.draw_pos_list(list, self._skip_lines_map[list_index])
	end
end

function PosDebug:clear(list_index)
	PosDebug.super.clear(self)

	if not list_index then
		self._pos_list = {}
	else
		self._pos_list[list_index] = nil
	end
end

function PosDebug:get_skip_lines(list_index)
	return self._skip_lines_map[list_index]
end

function PosDebug:set_skip_lines(list_index, skip_lines)
	self._skip_lines_map[list_index] = skip_lines
end

function PosDebug:add(pos, list_index, red, green, blue, radius)
	list_index = list_index or 1

	self:set(self:get_count(list_index) + 1, pos, list_index, red, green, blue, radius)
end

function PosDebug:add_list(list, list_index, red, green, blue, radius)
	for index, point in ipairs(list) do
		self:set(index, point, list_index, red, green, blue, radius)
	end
end

function PosDebug:set(index, pos, list_index, red, green, blue, radius)
	if not pos or type(pos) == "userdata" and pos.type_name == "Vector3" then
		local point = nil

		if pos then
			point = DebugPoint:new(pos, nil, red, green, blue, radius)
		end

		list_index = list_index or 1
		self._pos_list[list_index] = self._pos_list[list_index] or {}
		self._pos_list[list_index][index] = point

		DebugManager.trim_list(self._pos_list[list_index], self:get_max_count(list_index))
	else
		cat_error("debug", "Tried to set invalid position \"" .. tostring(pos) .. "\" to index \"" .. tostring(index) .. "\".")
	end
end

function PosDebug:remove(index, list_index)
	list_index = list_index or 1

	if self._pos_list[list_index] then
		table.remove(self._pos_list[list_index], index)

		if #self._pos_list[list_index] == 0 then
			self._pos_list[list_index] = nil
		end
	end
end

function PosDebug:get(index, list_index)
	list_index = list_index or 1

	if self._pos_list[list_index] and #self._pos_list[list_index] > 0 then
		return index and self._pos_list[list_index][index] or self._pos_list[list_index][#self._pos_list[list_index]]
	end

	return nil
end

function PosDebug:get_count(list_index)
	if list_index then
		if self._pos_list[list_index] then
			return #self._pos_list[list_index]
		else
			return 0
		end
	else
		return #self._pos_list
	end
end

function PosDebug:get_max_count(list_index)
	return list_index and self._max_pos_count_map[list_index] or self._max_pos_count
end

function PosDebug:set_max_count(list_index, max_count)
	if list_index then
		self._max_pos_count_map[list_index] = tonumber(max_count)
	else
		self._max_pos_count = tonumber(max_count) or self._max_pos_count
	end

	for list_index, list in pairs(self._pos_list) do
		DebugManager.trim_list(list, self:get_max_count(list_index))
	end
end

RotDebug = RotDebug or class(BaseDebug)

function RotDebug:init()
	RotDebug.super.init(self)

	self._rot_list = {}
	self._max_rot_count = 200
	self._max_rot_count_map = {}
end

function RotDebug:update(t, dt)
	for _, list in pairs(self._rot_list) do
		DebugManager.draw_rot_list(list)
	end
end

function RotDebug:clear(list_index)
	RotDebug.super.clear(self)

	if not list_index then
		self._rot_list = {}
	else
		self._rot_list[list_index] = nil
	end
end

function RotDebug:add(pos, list_index, rot, red, green, blue, radius)
	list_index = list_index or 1

	self:set(self:get_count(list_index) + 1, pos, list_index, rot, red, green, blue, radius)
end

function RotDebug:set(index, pos, list_index, rot, red, green, blue, radius)
	if pos and (type(pos) ~= "userdata" or pos.type_name ~= "Vector3") then
		cat_error("debug", "Tried to set invalid position \"" .. tostring(pos) .. "\" to index \"" .. tostring(index) .. "\".")
	elseif rot and (type(rot) ~= "userdata" or rot.type_name ~= "Rotation") then
		cat_error("debug", "Tried to set invalid rotation \"" .. tostring(rot) .. "\" to index \"" .. tostring(index) .. "\".")
	else
		local point = nil

		if pos and rot then
			point = DebugPoint:new(pos, rot, red, green, blue, radius)
		end

		list_index = list_index or 1
		self._rot_list[list_index] = self._rot_list[list_index] or {}
		self._rot_list[list_index][index] = point

		DebugManager.trim_list(self._rot_list[list_index], self._max_rot_count)
	end
end

function RotDebug:remove(index, list_index)
	list_index = list_index or 1

	if self._rot_list[list_index] then
		table.remove(self._rot_list[list_index], index)

		if #self._rot_list[list_index] == 0 then
			self._rot_list[list_index] = nil
		end
	end
end

function RotDebug:get_count(list_index)
	if list_index then
		if self._rot_list[list_index] then
			return #self._rot_list[list_index]
		else
			return 0
		end
	else
		return #self._rot_list
	end
end

function RotDebug:get_max_count(list_index)
	return list_index and self._max_rot_count_map[list_index] or self._max_rot_count
end

function RotDebug:set_max_count(list_index, max_count)
	if list_index then
		self._max_rot_count_map[list_index] = tonumber(max_count)
	else
		self._max_rot_count = tonumber(max_count) or self._max_rot_count
	end

	for list_index, list in pairs(self._rot_list) do
		DebugManager.trim_list(list, self:get_max_count(list_index))
	end
end

GUIDebug = GUIDebug or class(BaseDebug)
GUIDebug.GUI_TEXT_COUNT = 60

function GUIDebug:init()
	GUIDebug.super.init(self)

	self._text_func = {}
end

function GUIDebug:destroy()
	if alive(self._workspace) then
		managers.gui_data:destroy_workspace(self._workspace)

		self._workspace = nil
	end
end

function GUIDebug:update(t, dt)
	for index, func in pairs(self._text_func) do
		local s = DebugManager.args_to_string(func(t, dt))

		self._text[index]:set_text(s)
	end
end

function GUIDebug:clear()
	GUIDebug.super.clear(self)

	if self._workspace ~= nil then
		for _, text in ipairs(self._text) do
			text:set_text("")
			text:set_color(Color(1, 0, 0))
		end

		self._workspace:panel():clear()
		managers.gui_data:destroy_workspace(self._workspace)

		self._workspace = nil
		self._panel = nil
		self._text = nil
		self._text_func = {}
	end
end

function GUIDebug:set_enabled(enabled)
	if self._workspace and self._enabled ~= enabled then
		if enabled then
			self._workspace:show()
		else
			self._workspace:hide()
		end
	end

	BaseDebug.set_enabled(self, enabled)
end

function GUIDebug:setup()
	self._workspace = managers.gui_data:create_fullscreen_workspace()
	local gui = self._workspace:panel():gui(Idstring("core/guis/core_debug_manager"))
	self._panel = gui:panel()
	self._text = {}
	local config = {
		font = "core/fonts/diesel",
		font_size = 16,
		color = Color(255, 0, 0),
		x = 45,
		y = 25,
		layer = 1000000
	}

	for i = 1, self.GUI_TEXT_COUNT do
		self._text[i] = self._panel:text(config)
		config.y = config.y + self._text[i]:line_height()
	end

	if self._enabled then
		self._workspace:show()
	else
		self._workspace:hide()
	end
end

function GUIDebug:set_func(index, func)
	if index >= 1 and index <= self.GUI_TEXT_COUNT then
		if self._workspace == nil then
			self:setup()
		end

		self._text_func[index] = func
	end
end

function GUIDebug:get(index)
	if index >= 1 and index <= self.GUI_TEXT_COUNT then
		if self._workspace == nil then
			self:setup()
		end

		if self._text_func[index] then
			return self._text_func[index](TimerManager:wall():time(), TimerManager:wall():delta_time())
		elseif self._text[index] then
			return self._text[index]:text()
		else
			return nil
		end
	end
end

function GUIDebug:set(index, ...)
	if index >= 1 and index <= self.GUI_TEXT_COUNT then
		if self._workspace == nil then
			self:setup()
		end

		local s = DebugManager.args_to_string(...)

		self._text[index]:set_text(s)

		self._text_func[index] = nil
	end
end

function GUIDebug:get(index)
	if index >= 1 and index <= self.GUI_TEXT_COUNT then
		if self._workspace == nil then
			self:setup()
		end

		return self._text[index]:text()
	end
end

function GUIDebug:set_color(index, red, green, blue, alpha)
	if index >= 1 and index <= self.GUI_TEXT_COUNT then
		if self._workspace == nil then
			self:setup()
		end

		self._text[index]:set_color(Color(math.min(alpha or 1, 1), red or 1, green or 1, blue or 1))
	end
end

GraphDebug = GraphDebug or class(PosDebug)
GraphDebug.AXIS_ARROW_SIZE = 20
GraphDebug.GUI_WORLD_WIDTH = 1000
GraphDebug.GUI_WORLD_HEIGHT = 250

function GraphDebug:init()
	GraphDebug.super.init(self)

	self._size = 500
	self._cam_offset = Vector3(0, 1000, 200)
	self._is_fixed_rot = false
	self._fixed_rot = nil
	self._invalidated = true
	self._max_x = nil
	self._min_x = nil
	self._max_y = nil
	self._min_y = nil
	self._max_z = nil
	self._min_z = nil
	self._span_x = nil
	self._span_y = nil
	self._span_z = nil
	self._scale_x = nil
	self._scale_y = nil
	self._scale_z = nil
	self._workspace_map = nil
	self._visible = false
	self._camera = nil
	self._fixed_range = nil
end

function GraphDebug:set_fixed_range(fixed_range)
	self._fixed_range = fixed_range

	if fixed_range then
		self:set_range(Vector3(self._min_x or 0, self._min_y or 0, self._min_z or 0), Vector3(self._max_x or 0, self._max_y or 0, self._max_z or 0))
	end
end

function GraphDebug:set_range(min, max)
	self._min_x = min.x
	self._max_x = max.x
	self._min_y = min.y
	self._max_y = max.y
	self._min_z = min.z
	self._max_z = max.z
	self._span_x = self._max_x - self._min_x
	self._span_y = self._max_y - self._min_y
	self._span_z = self._max_z - self._min_z

	if self._span_x > 0 then
		self._scale_x = self._size / self._span_x
	else
		self._scale_x = 0
	end

	if self._span_y > 0 then
		self._scale_y = self._size / self._span_y
	else
		self._scale_y = 0
	end

	if self._span_z > 0 then
		self._scale_z = self._size / self._span_z
	else
		self._scale_z = 0
	end
end

function GraphDebug:update(t, dt)
	if next(self._pos_list) then
		if not self._workspace_map then
			self:setup()
		end

		local camera = self._camera or managers.viewport and managers.viewport:get_current_camera()
		local rotation, origo = nil

		if camera then
			rotation = camera:rotation()
			origo = camera:position() + rotation:y() * self._cam_offset.y + rotation:z() * self._cam_offset.z
			rotation = self._fixed_rot or rotation
		else
			origo = Vector3()
			rotation = self._fixed_rot or Rotation()
		end

		if self._invalidated then
			if not self._fixed_range then
				local min_x = 0
				local max_x = 0
				local min_y = 0
				local max_y = 0
				local min_z = 0
				local max_z = 0

				for list_index, list in pairs(self._pos_list) do
					for index, point in ipairs(list) do
						if point._pos.x < min_x then
							min_x = point._pos.x
						end

						if max_x < point._pos.x then
							max_x = point._pos.x
						end

						if point._pos.y < min_y then
							min_y = point._pos.y
						end

						if max_y < point._pos.y then
							max_y = point._pos.y
						end

						if point._pos.z < min_z then
							min_z = point._pos.z
						end

						if max_z < point._pos.z then
							max_z = point._pos.z
						end
					end
				end

				self:set_range(Vector3(min_x, min_y, min_z), Vector3(max_x, max_y, max_z))
			end

			self._invalidated = false
		end

		local offset = Vector3(self._min_x + self._span_x / 2, self._min_y + self._span_y / 2, self._min_z + self._span_z / 2)
		local offset_origo = origo - self:get_scaled_pos(offset):rotate_with(rotation)
		local offset_max_x = offset_origo + Vector3(self._max_x * self._scale_x, 0, 0):rotate_with(rotation)
		local offset_max_y = offset_origo + Vector3(0, self._max_y * self._scale_y, 0):rotate_with(rotation)
		local offset_max_z = offset_origo + Vector3(0, 0, self._max_z * self._scale_z):rotate_with(rotation)
		local offset_min_x = offset_origo + Vector3(self._min_x * self._scale_x, 0, 0):rotate_with(rotation)
		local offset_min_y = offset_origo + Vector3(0, self._min_y * self._scale_y, 0):rotate_with(rotation)
		local offset_min_z = offset_origo + Vector3(0, 0, self._min_z * self._scale_z):rotate_with(rotation)

		Application:draw_line_unpaused(offset_min_x, offset_max_x, 1, 0, 0)
		Application:draw_line_unpaused(offset_min_y, offset_max_y, 0, 1, 0)
		Application:draw_line_unpaused(offset_min_z, offset_max_z, 0, 0, 1)
		Application:draw_cone(offset_max_x + Vector3(GraphDebug.AXIS_ARROW_SIZE, 0, 0):rotate_with(rotation), offset_max_x, GraphDebug.AXIS_ARROW_SIZE / 4, 1, 0, 0)
		Application:draw_cone(offset_max_y + Vector3(0, GraphDebug.AXIS_ARROW_SIZE, 0):rotate_with(rotation), offset_max_y, GraphDebug.AXIS_ARROW_SIZE / 4, 0, 1, 0)
		Application:draw_cone(offset_max_z + Vector3(0, 0, GraphDebug.AXIS_ARROW_SIZE):rotate_with(rotation), offset_max_z, GraphDebug.AXIS_ARROW_SIZE / 4, 0, 0, 1)

		local old_point = nil

		for list_index, list in pairs(self._pos_list) do
			old_point = nil

			for index, point in ipairs(list) do
				local graph_point = CoreTable.clone(point)
				graph_point._pos = offset_origo + self:get_scaled_pos(point._pos):rotate_with(rotation)

				DebugManager.draw_point(index, #list, old_point, graph_point, self._skip_lines_map[list_index])

				old_point = graph_point
			end
		end

		self:set_gui_text("max_x", offset_max_x, rotation, "", self._max_x)
		self:set_gui_text("max_y", offset_max_y, Rotation(-rotation:x(), rotation:z()), "", self._max_y)
		self:set_gui_text("max_z", offset_max_z, rotation, "", self._max_z)
		self:set_gui_text("min_x", offset_min_x, rotation, "", self._min_x)
		self:set_gui_text("min_y", offset_min_y, Rotation(-rotation:x(), rotation:z()), "", self._min_y)
		self:set_gui_text("min_z", offset_min_z, rotation, "", self._min_z)
		self:set_visible(true)
	elseif self._workspace_map then
		self:set_visible(false)
	end
end

function GraphDebug:set_gui_text(id, position, rotation, label, value)
	local workspace = self._workspace_map[id]
	local gui_text = workspace:panel():child(0)

	gui_text:set_text(string.format("%s%g", label, value))

	local w, h = self:get_text_size(gui_text)

	gui_text:set_world_shape(self.GUI_WORLD_WIDTH / 2 - w, self.GUI_WORLD_HEIGHT / 2 - h, w * 2, h * 2)
	workspace:set_world(self.GUI_WORLD_WIDTH, self.GUI_WORLD_HEIGHT, position - Vector3(self.GUI_WORLD_WIDTH / 2, 0, -self.GUI_WORLD_HEIGHT / 2):rotate_with(rotation), rotation:x() * self.GUI_WORLD_WIDTH, -rotation:z() * self.GUI_WORLD_HEIGHT)
end

function GraphDebug:get_text_size(gui_text)
	local w = 0
	local h = 0

	for i = 1, #gui_text:text() do
		local char_x, char_y, char_w, char_h = gui_text:character_rect(i - 1)
		w = w + char_w
		h = math.max(h, char_h)
	end

	return w, h
end

function GraphDebug:get_scaled_pos(pos)
	return Vector3(pos.x * self._scale_x, pos.y * self._scale_y, pos.z * self._scale_z)
end

function GraphDebug:setup()
	self._workspace_map = {}
	local text_config = {
		font = "core/fonts/diesel",
		font_size = 50,
		color = Color(1, 0, 0),
		vertical = "bottom",
		align = "left"
	}

	self:create_gui_text("min_x", text_config)

	text_config.align = "right"

	self:create_gui_text("max_x", text_config)

	text_config.color = Color(0, 1, 0)

	self:create_gui_text("max_y", text_config)

	text_config.align = "left"

	self:create_gui_text("min_y", text_config)

	text_config.color = Color(0, 0, 1)
	text_config.align = "right"

	self:create_gui_text("min_z", text_config)

	text_config.vertical = "top"

	self:create_gui_text("max_z", text_config)
end

function GraphDebug:get_camera()
	return self._camera
end

function GraphDebug:set_camera(camera)
	self._camera = camera
end

function GraphDebug:create_gui_text(id, config)
	local workspace = World:gui():create_world_workspace(self.GUI_WORLD_WIDTH, self.GUI_WORLD_HEIGHT, Vector3(), Vector3(1, 0, 0), Vector3(0, 0, 1))
	self._workspace_map[id] = workspace
	local gui_text = workspace:panel():text(config)

	workspace:hide()
end

function GraphDebug:clear(list_index)
	GraphDebug.super.clear(self, list_index)

	self._invalidated = true
end

function GraphDebug:set_size(size)
	self._size = size
	self._invalidated = true
end

function GraphDebug:get_size()
	return self._size
end

function GraphDebug:set_offset(offset)
	self._cam_offset = offset
end

function GraphDebug:get_offset()
	return self._cam_offset
end

function GraphDebug:set_is_fixed_rot(is_fixed_rot)
	self._is_fixed_rot = is_fixed_rot
end

function GraphDebug:is_fixed_rot()
	return self._is_fixed_rot
end

function GraphDebug:set_fixed_rot(fixed_rot)
	self._fixed_rot = fixed_rot
end

function GraphDebug:get_fixed_rot()
	return self._fixed_rot
end

function GraphDebug:set(index, pos, list_index, red, green, blue, radius)
	list_index = list_index or 1

	if type(pos) == "number" then
		local count = self:get_count(list_index)
		local max_count = self:get_max_count(list_index)
		local x = self:get_count(list_index)

		if max_count ~= -1 and max_count <= count then
			self:scroll_number_list(list_index, count - max_count + 1)

			x = x - 1
		end

		pos = Vector3(x, 0, pos)
	end

	GraphDebug.super.set(self, index, pos, list_index, red, green, blue, radius or 0)

	self._invalidated = true
end

function GraphDebug:set_max_count(list_index, max_count)
	if list_index then
		local list = self._pos_list[list_index]

		if list and max_count < #list then
			self:scroll_number_list(list_index, #list - max_count - 1)

			self._invalidated = true
		end
	else
		for list_index, list in pairs(self._pos_list) do
			if max_count < #list then
				self:scroll_number_list(list_index, #list - max_count - 1)

				self._invalidated = true
			end
		end
	end

	GraphDebug.super.set_max_count(self, list_index, max_count)
end

function GraphDebug:scroll_number_list(list_index, scroll)
	for _, point in ipairs(self._pos_list[list_index]) do
		point._pos = Vector3(point._pos.x - scroll, point._pos.y, point._pos.z)
	end
end

function GraphDebug:remove(list_index, ...)
	GraphDebug.super.remove(self, list_index, ...)

	self._invalidated = true
end

function GraphDebug:set_enabled(enabled)
	if self._enabled ~= enabled then
		if enabled then
			if not self._workspace_map then
				self:setup()
			end

			self:set_visible(true)
		elseif self._workspace_map then
			self:set_visible(false)
		end
	end

	GraphDebug.super.set_enabled(self, enabled)
end

function GraphDebug:set_visible(visible)
	if not self._visible ~= not visible then
		self._visible = visible

		for _, workspace in pairs(self._workspace_map) do
			if visible then
				workspace:show()
			else
				workspace:hide()
			end
		end
	end
end

HijackDebug = HijackDebug or class(BaseDebug)

function HijackDebug:init()
	HijackDebug.super.init(self)

	self._ray_list = {}
	self._hijack_ray_enabled = false
	self._old_func_list = {}
	self._hijack_ray_func = callback(self, self, "default_hijacked_ray_func")
	self._ray_obj_list = {
		[World:key()] = World
	}
	self._hijacked_statemachine_map = nil
end

function HijackDebug:update(t, dt)
	for _, ray in pairs(self._ray_list) do
		ray:update(t, dt)
	end
end

function HijackDebug:clear()
	HijackDebug.super.clear(self)

	self._ray_list = {}
end

function HijackDebug:add_ray_obj(obj)
	if obj.key then
		self._ray_obj_list[obj:key()] = obj

		if self._hijack_ray_enabled then
			self:set_hijack_ray_obj(obj, true)
		end
	end
end

function HijackDebug:delete_ray_obj(obj)
	if obj.key then
		self._ray_obj_list[obj:key()] = nil

		if self._hijack_ray_enabled then
			self:set_hijack_ray_obj(obj, false)
		end
	end
end

function HijackDebug:reset_ray_obj_list()
	self:clear_ray_obj_list()

	self._ray_obj_list[World:key()] = World
end

function HijackDebug:clear_ray_obj_list()
	for _, obj in pairs(self._ray_obj_list) do
		self:delete_ray_obj(obj)
	end
end

function HijackDebug:ray_enabled()
	return self._hijack_ray_enabled
end

function HijackDebug:set_ray_enabled(enabled)
	if self._hijack_ray_enabled ~= enabled then
		self._hijack_ray_enabled = enabled

		for _, obj in pairs(self._ray_obj_list) do
			self:set_hijack_ray_obj(obj, enabled)
		end
	end
end

function HijackDebug:set_hijack_ray_obj(obj, enabled)
	if not obj.alive or alive(obj) then
		local meta_table = getmetatable(obj)

		if enabled then
			if not self._old_func_list[obj:key()] then
				self._old_func_list[obj:key()] = meta_table.raycast
				meta_table.raycast = callback(self, self, "hijacked_ray")
			end
		elseif self._old_func_list[obj:key()] then
			meta_table.raycast = self._old_func_list[obj:key()]
			self._old_func_list[obj:key()] = nil
		end
	elseif obj:key() then
		self._old_func_list[obj:key()] = nil
	end
end

function HijackDebug:is_hijack_ray_obj(obj)
	return (not obj.alive or alive(obj)) and self._old_func_list[obj:key()] ~= nil
end

function HijackDebug:set_hijack_ray_func(func)
	if func then
		self._hijack_ray_func = func
	else
		self._hijack_ray_func = callback(self, self, "default_hijacked_ray_func")
	end
end

function HijackDebug:hijacked_ray(obj, ...)
	if self._old_func_list[obj:key()] then
		return self._hijack_ray_func(obj, self._old_func_list[obj:key()], ...)
	else
		return nil
	end
end

function HijackDebug:default_hijacked_ray_func(obj, old_func, ...)
	local param_list = {
		...
	}
	local ray = old_func(obj, ...)
	local point_list = nil
	local ray_wrapper = DebugRaycast:new()

	if ray then
		ray_wrapper:set_from(ray.position - ray.ray * ray.distance)
		ray_wrapper:set_to(ray.position)
		ray_wrapper:set_color(1, 0, 0)
		ray_wrapper:set_normal(ray.normal)
		ray_wrapper:set_normal_color(0, 0, 1)
	else
		ray_wrapper:set_color(0, 1, 0)
	end

	if type(param_list[1]) == "string" then
		local trajectory_dir, trajectory_len, trajectory_gravity, trajectory_wind, trajectory_drag = nil
		local i = 1

		while i < #param_list do
			local param = param_list[i]

			if param == "ray" then
				ray_wrapper:set_from(ray_wrapper:from() or param_list[i + 1])
				ray_wrapper:set_to(ray_wrapper:to() or param_list[i + 2])

				i = i + 2
			elseif param == "sphere_cast_radius" then
				ray_wrapper:set_radius(param_list[i + 1])

				i = i + 1
			elseif param == "slot_mask" then
				i = i + 1

				while i < #param_list and type(param_list[i + 1]) ~= "string" do
					i = i + 1
				end
			elseif param == "bundle" then
				ray_wrapper:set_bundle(param_list[i + 1])

				i = i + 1
			elseif param == "ignore_body" or param == "ignore_unit" or param == "target_body" or param == "target_unit" or param == "passed" or param == "ray_type" then
				i = i + 1
			elseif param == "trajectory" then
				local from = param_list[i + 1]

				ray_wrapper:set_from(from)

				if not ray_wrapper:to() then
					trajectory_dir = param_list[i + 2]:normalized()
					trajectory_len = param_list[i + 3]
				end

				i = i + 3
			elseif param == "gravity" then
				trajectory_gravity = param_list[i + 1]
				i = i + 1
			elseif param == "wind" then
				trajectory_wind = param_list[i + 1]
				i = i + 1
			elseif param == "drag" then
				trajectory_drag = param_list[i + 1]
				i = i + 1
			elseif param == "points" then
				point_list = param_list[i + 1]
				i = i + 1
			else
				while i < #param_list and type(param_list[i + 1]) ~= "string" do
					i = i + 1
				end
			end

			i = i + 1
		end

		if point_list then
			local to_index = nil

			if ray and ray.hit_segment then
				to_index = ray.hit_segment
			else
				to_index = #point_list
			end

			for i = 2, to_index do
				ray_wrapper = DebugRaycast:new(ray_wrapper)

				ray_wrapper:set_from(point_list[i - 1])
				ray_wrapper:set_to(point_list[i])

				if i < to_index then
					table.insert(self._ray_list, ray_wrapper)
				end
			end
		elseif trajectory_dir then
			trajectory_gravity = trajectory_gravity or Vector3(0, 0, -982)
			local to = ray_wrapper:from() + trajectory_dir * trajectory_len + trajectory_gravity * trajectory_len

			if trajectory_wind then
				to = to + trajectory_wind * (trajectory_drag or 1) * trajectory_len
			end

			ray_wrapper:set_to(to)
		end
	else
		ray_wrapper:set_from(ray_wrapper:from() or param_list[1])
		ray_wrapper:set_to(ray_wrapper:to() or param_list[2])
	end

	table.insert(self._ray_list, ray_wrapper)

	return ray
end

function HijackDebug:reloaded()
	self:set_ray_enabled(false)
end

function HijackDebug:hijack_statemachine(unit, unit_state_func, machine_state_func, redirect_func)
	local machine = unit:anim_state_machine()

	if machine then
		local unit_key = unit:key()
		self._hijacked_statemachine_map = self._hijacked_statemachine_map or {}

		if not self._hijacked_statemachine_map[unit_key] then
			self:hijack_func(unit, "play_state", unit_state_func or callback(self, self, "play_unit_state"))
			self:hijack_func(unit, "play_redirect", redirect_func or callback(self, self, "play_redirect"))
			self:hijack_func(machine, "play", machine_state_func or callback(self, self, "play_machine_state"))
			self:hijack_func(machine, "play_redirect", redirect_func or callback(self, self, "play_redirect"))

			self._hijacked_statemachine_map[unit_key] = unit

			cat_print("debug", "Hijacked play and play_redirect.")
		else
			self:unhijack_func(machine, "play")
			self:unhijack_func(machine, "play_redirect")
			self:unhijack_func(unit, "play_state")
			self:unhijack_func(unit, "play_redirect")

			self._hijacked_statemachine_map[unit_key] = nil

			cat_print("debug", "Unhijacked play and play_redirect.")
		end
	else
		cat_error("debug", "No state machine on unit \"" .. unit:name() .. "\".")
	end
end

function HijackDebug:hijack_func(obj, func_name, func, is_metatable)
	local meta = nil
	meta = is_metatable and obj or getmetatable(obj) or obj

	rawset(meta, "hijacked_" .. func_name, rawget(meta, func_name))
	rawset(meta, func_name, func)
end

function HijackDebug:unhijack_func(obj, func_name, is_metatable)
	local meta = nil
	meta = is_metatable and obj or getmetatable(obj) or obj

	rawset(meta, func_name, rawget(meta, "hijacked_" .. func_name))
	rawset(meta, "hijacked_" .. func_name, nil)
end

function HijackDebug:play_unit_state(unit, state)
	local result = unit:hijacked_play_state(state)

	if #result > 0 then
		cat_debug("debug", "STATE \"" .. tostring(state) .. "\" --> \"" .. tostring(result) .. "\".")
	end

	return result
end

function HijackDebug:play_machine_state(machine, state)
	local result = machine:hijacked_play(state)

	if #result > 0 then
		cat_debug("debug", "STATE \"" .. tostring(state) .. "\" --> \"" .. tostring(result) .. "\".")
	end

	return result
end

function HijackDebug:play_redirect(machine_or_unit, redirect)
	local result = machine_or_unit:hijacked_play_redirect(redirect)

	if #result > 0 then
		cat_debug("debug", "REDIRECT \"" .. tostring(redirect) .. "\" --> \"" .. tostring(result) .. "\".")
	end

	return result
end

SimpleDebug = SimpleDebug or class(BaseDebug)

function SimpleDebug:init()
	SimpleDebug.super.init(self)

	self._depricate_list = {}
end

function SimpleDebug:add_depricate(dep_type, depricate_time, ...)
	local dep = {
		type = dep_type,
		time = TimerManager:wall():time(),
		duration = depricate_time,
		arg = {
			...
		}
	}

	table.insert(self._depricate_list, dep)
end

function SimpleDebug:draw_depricate(dep, red, green, blue)
	if dep.type == "line" then
		Application:draw_line(dep.arg[1], dep.arg[2], red, green, blue)
	elseif dep.type == "sphere" then
		Application:draw_sphere(dep.arg[1], dep.arg[2], red, green, blue)
	end
end

function SimpleDebug:draw_line(start_pos, end_pos, depricate_time)
	self:add_depricate("line", depricate_time, start_pos, end_pos)
end

function SimpleDebug:draw_sphere(pos, radie, depricate_time)
	self:add_depricate("sphere", depricate_time, pos, radie)
end

function SimpleDebug:update(time, rel_time)
	local remove_list = {}

	for index, dep in ipairs(self._depricate_list) do
		local elapsed_time = time - dep.time

		if dep.duration < elapsed_time then
			table.insert(remove_list, index)
		else
			local green = (dep.duration - elapsed_time) / dep.duration
			local red = 1 - green

			self:draw_depricate(dep, red, green, 0)
		end
	end

	for i, index in ipairs(remove_list) do
		table.remove(self._depricate_list, index)
	end
end

function SimpleDebug:clear()
	SimpleDebug.super.clear(self)

	self._depricate_list = {}
end

PrintDebug = PrintDebug or class(BaseDebug)

function PrintDebug:xml_file(file, indent, indent_string)
	if not file or not SystemFS:exists(file) then
		cat_error("debug", "\"" .. tostring(file) .. "\" does not exist.")
	elseif SystemFS:is_dir(file) then
		cat_error("debug", "\"" .. tostring(file) .. "\" is a directory.")
	else
		local name, ext = string.match(file, "^([^.]*).(.*)$")
		local root = DB:load_node(ext, name)

		self:node(root, indent, indent_string)
	end
end

function PrintDebug:node(node, indent, indent_string)
	indent = indent or 0
	indent_string = indent_string or "\t"
	local str = string.rep(tostring(indent_string), indent) .. "<" .. tostring(node:name())

	for k, v in pairs(node:parameter_map()) do
		str = str .. " " .. tostring(k) .. "=\"" .. tostring(v) .. "\""
	end

	if node:num_children() > 0 then
		cat_print("debug", str .. ">")

		for child_node in node:children() do
			self:node(child_node, indent + 1, indent_string)
		end

		cat_print("debug", string.rep(tostring(indent_string), indent) .. "</" .. tostring(node:name()) .. ">")
	else
		cat_print("debug", str .. "/>")
	end
end

ProfilerDebug = ProfilerDebug or class(BaseDebug)

function ProfilerDebug:init()
	ProfilerDebug.super.init(self)

	self._counter_list = {}
	self._counter_map = {}
end

function ProfilerDebug:clear()
	ProfilerDebug.super.clear(self)

	for _, counter in pairs(self._counter_map) do
		counter:set_enabled(false)
	end

	self._counter_list = {}
	self._counter_map = {}
end

function ProfilerDebug:add_counter(counter_name, obj, func_name, color, min_range, max_range, disabled, graph_disabled, gui_disabled, print_counter, override_class)
	local counter = self._counter_map[counter_name]

	if counter then
		self:remove_counter(counter, print_counter, false)
	end

	local index = #self._counter_list + 1
	counter = DebugProfilerCounter:new(counter_name, index, obj, func_name, color, min_range, max_range, not disabled, not graph_disabled, not gui_disabled, override_class)
	self._counter_map[counter_name] = counter

	table.insert(self._counter_list, counter)

	if print_counter then
		cat_debug("Add " .. index .. ": " .. tostring(counter_name))
	end
end

function ProfilerDebug:remove_index(index, print_counter, skip_color_update)
	local counter = self._counter_list[index]

	if counter then
		self:remove_counter(counter, print_counter, skip_color_update)
	end
end

function ProfilerDebug:remove_name(counter_name, print_counter, skip_color_update)
	local counter = self._counter_map[counter_name]

	if counter then
		self:remove_counter(counter, print_counter, skip_color_update)
	end
end

function ProfilerDebug:remove_counter(counter, print_counter, skip_color_update)
	if counter then
		local index = counter:index()

		counter:set_enabled(false)

		self._counter_map[counter:name()] = nil

		table.remove(self._counter_list, index)

		for i = index, #self._counter_list do
			self._counter_list[i]:set_index(i)
		end

		if not skip_color_update then
			self:update_colors()
		end

		if print_counter then
			cat_debug("Remove " .. index .. ": " .. tostring(counter:name()))
		end
	end
end

function ProfilerDebug:update_colors()
	for index, counter in ipairs(self._counter_list) do
		local color_list = DebugManager.get_color_by_index(index, #self._counter_list)
		local color = Color(1, color_list[1], color_list[2], color_list[3])

		counter:set_color(color)
	end
end

function ProfilerDebug:set_unit_enabled(unit, enabled, function_name_list, ignore_map, include_only_map, min_range, max_range, disabled, graph_disabled, gui_disabled, print_counters, class_override)
	if alive(unit) and unit.type_name == "Unit" then
		function_name_list = function_name_list or {
			"update"
		}

		for _, extension_name in ipairs(unit:extensions()) do
			for _, function_name in ipairs(function_name_list) do
				local counter_name = unit:name() .. ":" .. extension_name .. ":" .. tostring(function_name) .. "()"

				self:remove_name(counter_name, print_counters, true)

				if enabled then
					local extension = unit[extension_name](unit)

					if extension.update and (not ignore_map or not ignore_map[extension_name]) and (not include_only_map or include_only_map[extension_name]) then
						self:add_counter(counter_name, extension, function_name, nil, min_range, max_range, disabled, graph_disabled, gui_disabled, print_counters, not class_override)
					end
				end
			end
		end

		self:update_colors()
	end
end

function ProfilerDebug:set_managers_enabled(enabled, ignore_map, include_only_map, min_range, max_range, disabled, graph_disabled, gui_disabled, print_counters)
	for manager_name, manager in pairs(managers) do
		local counter_name = "managers." .. manager_name .. ":update()"

		self:remove_name(counter_name, print_counters, true)

		if enabled and type(manager) == "table" and manager.update and (not ignore_map or not ignore_map[manager_name]) and (not include_only_map or include_only_map[manager_name]) then
			self:add_counter(counter_name, manager, "update", nil, min_range, max_range, disabled, graph_disabled, gui_disabled, print_counters, nil)
		end
	end

	self:update_colors()
end

function ProfilerDebug:reloaded()
	for _, counter in ipairs(self._counter_list) do
		counter:reload()
	end
end

function ProfilerDebug:toggle_compare_find(slotmask, find_type, radius, length, count, bundle_count, func_name)
	local f = nil
	local list = {}
	local result = nil

	if func_name ~= "find_units" and func_name ~= "find_bodies" and func_name ~= "find_units_quick" then
		cat_error("debug", "Invalid function: " .. tostring(func_name))

		return
	end

	if not tonumber(radius) then
		cat_error("debug", "Invalid radius: " .. tostring(radius))

		return
	end

	if not tonumber(length) then
		cat_error("debug", "Invalid length: " .. tostring(length))

		return
	end

	if not tonumber(count) then
		cat_error("debug", "Invalid count: " .. tostring(count))

		return
	end

	if not tonumber(bundle_count) then
		cat_error("debug", "Invalid bundle count: " .. tostring(bundle_count))

		return
	end

	local can_intersect = func_name ~= "find_units_quick"

	if find_type == "cone" or find_type == "cylinder" or find_type == "capsule" then
		function f(from, to)
			result = World[func_name](World, "force_slot", find_type, from, to, radius, slotmask)
		end

		table.insert(list, {
			func = f,
			counter = "find_" .. find_type
		})

		function f(from, to)
			result = World[func_name](World, "force_physics", find_type, from, to, radius, slotmask)
		end

		table.insert(list, {
			func = f,
			counter = "find_" .. find_type .. "_physics"
		})

		if can_intersect then
			function f(from, to)
				result = World[func_name](World, "intersect", "force_slot", find_type, from, to, radius, slotmask)
			end

			table.insert(list, {
				func = f,
				counter = "find_" .. find_type .. "_intersect"
			})

			function f(from, to)
				result = World[func_name](World, "intersect", "force_physics", find_type, from, to, radius, slotmask)
			end

			table.insert(list, {
				func = f,
				counter = "find_" .. find_type .. "_intersect_physics"
			})
		end
	elseif find_type == "sphere" then
		function f(from, to)
			result = World[func_name](World, "force_slot", find_type, from, radius, slotmask)
		end

		table.insert(list, {
			func = f,
			counter = "find_" .. find_type
		})

		function f(from, to)
			result = World[func_name](World, "force_physics", find_type, from, radius, slotmask)
		end

		table.insert(list, {
			func = f,
			counter = "find_" .. find_type .. "_physics"
		})

		if can_intersect then
			function f(from, to)
				result = World[func_name](World, "intersect", "force_slot", find_type, from, radius, slotmask)
			end

			table.insert(list, {
				func = f,
				counter = "find_" .. find_type .. "_intersect"
			})

			function f(from, to)
				result = World[func_name](World, "intersect", "force_physics", find_type, from, radius, slotmask)
			end

			table.insert(list, {
				func = f,
				counter = "find_" .. find_type .. "_intersect_physics"
			})
		end
	else
		cat_error("debug", "Invalid type: " .. find_type)

		return
	end

	Application:console_command("stats counters")

	if Global.spherecast_cost_counter_list then
		for index, counter in ipairs(Global.spherecast_cost_counter_list) do
			Application:console_command("profiler remove " .. counter)
			Application:console_command("graph hide " .. counter)
			managers.debug.gui:set(index, nil)
		end

		managers.debug.func:set(1, nil)

		Global.spherecast_cost_counter_list = nil

		return
	end

	function f(from, to)
		result = World:raycast("ray", from, to, "sphere_cast_radius", radius, "bundle", bundle_count, "slot_mask", slotmask)
	end

	table.insert(list, {
		counter = "bundlecast",
		func = f
	})

	function f(from, to)
		result = World:raycast("ray", from, to, "sphere_cast_radius", radius, "slot_mask", slotmask)
	end

	table.insert(list, {
		counter = "spherecast",
		func = f
	})

	Global.spherecast_cost_counter_list = {}

	for index, data in ipairs(list) do
		table.insert(Global.spherecast_cost_counter_list, data.counter)
		Application:console_command("profiler add " .. data.counter)

		local r, g, b = unpack(DebugManager.get_color_by_index(index, #list))

		Application:console_command(string.format("graph counter %s color %X%X%X range 0 20", data.counter, r * 15, g * 15, b * 15))
		managers.debug.gui:set(index, data.counter)
		managers.debug.gui:set_color(index, r, g, b)
	end

	managers.debug:set_enabled(true)
	managers.debug:set_enabled_paused(true)
	managers.debug.func:set_enabled(true)
	managers.debug.gui:set_enabled(true)
	managers.debug.func:set(1, function ()
		local rand_list = {}

		for i = #list, 1, -1 do
			local rand_index = math.random(#list)

			table.insert(rand_list, list[rand_index])
			table.remove(list, rand_index)
		end

		list = rand_list
		local camera = managers.viewport and managers.viewport:get_current_camera()

		if not camera then
			cat_error("debug", "No camera available.")
			managers.debug.func:set(1, nil)

			return
		end

		local rot = camera:rotation()
		local dir = rot:y()
		local from = camera:position() + dir * 1000
		local to = from + dir * length

		if find_type == "cone" then
			Application:draw_cone(from, to, radius, 1, 1, 1)
		elseif find_type == "sphere" then
			Application:draw_sphere(from, radius, 1, 1, 1)
		else
			Application:draw_cylinder(from, to, radius, 1, 1, 1)
		end

		local id = nil

		for _, data in ipairs(rand_list) do
			id = Profiler:start(data.counter)

			for i = 1, count do
				data.func(from, to)
			end

			Profiler:stop(id)
		end
	end)
	cat_debug("debug", "Unit count: " .. #World:find_units_quick("all", slotmask))
end

MacroDebug = MacroDebug or class(BaseDebug)
MacroDebug.DEFAULT_LINE_DURATION = 2

function MacroDebug:init()
	MacroDebug.super.init(self)

	self._default_push_velocity_dir = math.UP
	self._default_push_velocity_length = 1000
	self._default_push_mass = 100000
	self._default_spawn_cam_offset = 1000
	self._default_multi_spawn_unit_offset = 300
	self._default_multi_spawn_unit_count = 10
	self._verbose_unit_map = {}
	self._profile_unit_map = {}
end

function MacroDebug:get_ray(skip_last_unit_assign)
	local cam = managers.viewport:get_current_camera()
	local from = cam and cam:position() or Vector3()
	local to = from + (cam and cam:rotation():y() or Vector3(0, 1, 0)) * 100000
	local ray = World:raycast("ray", from, to, "ray_type", "body editor phantom bullet")

	if ray then
		self:set_last_ray(ray)

		if not skip_last_unit_assign then
			self:set_last_unit(ray.unit)
		end

		managers.debug.pos:add(ray.position, "ray", nil, nil, nil, 10)
		managers.debug:set_enabled(true)
		managers.debug:set_enabled_paused(true)
		managers.debug.pos:set_enabled(true)
	end

	return ray
end

function MacroDebug:set_last_ray(ray)
	self._last_ray = ray

	rawset(_G, "r", ray)
end

function MacroDebug:get_last_ray()
	return self._last_ray
end

function MacroDebug:set_last_unit(unit)
	self._last_unit = unit
	self._last_unit_name = alive(unit) and unit:name() or nil

	rawset(_G, "u", unit)
end

function MacroDebug:get_last_unit()
	return self._last_unit
end

function MacroDebug:ray()
	local ray = self:get_ray()

	if ray then
		self:print_unit_info(ray.unit)
		cat_print("debug", "Body: " .. tostring(ray.body:name():t()) .. ", Pos: " .. tostring(ray.position) .. ", Len: " .. string.format("%.3f", ray.distance))
	else
		cat_error("debug", "No unit found.")
	end
end

function MacroDebug:print_unit_info(unit)
	if alive(unit) then
		local unit_file, object_file, sequence_file, anim_machine = self:get_unit_files(unit)
		local unit_string = "Name: " .. tostring(unit:name():t()) .. ", Slot:" .. tostring(unit:slot()) .. ", Author: " .. tostring(unit:author():t())

		if #anim_machine > 0 then
			unit_string = unit_string .. ", Anim: " .. tostring(anim_machine)
		end

		cat_print("debug", unit_string)
		cat_print("debug", "Unit:     " .. tostring(unit_file))
		cat_print("debug", "Object:   " .. tostring(object_file))

		if sequence_file then
			cat_print("debug", "Sequence: " .. sequence_file)
		end
	elseif unit then
		cat_error("debug", "Unit is dead.")
	else
		cat_error("debug", "Unit is nil.")
	end
end

function MacroDebug:get_unit_files(unit)
	local object_file, unit_file = nil
	local unit_data = PackageManager:unit_data(unit:name():id())
	local base = Application:base_path() .. "..\\..\\assets\\"
	local unit_name = tostring(unit:name():t())
	local unit_file = base .. unit_name .. ".unit"
	local object_file = base .. unit_name .. ".object"
	local relative_sequence_file = managers.sequence:get_sequence_file(unit_name)
	local sequence_file = relative_sequence_file and base .. tostring(relative_sequence_file:t()) .. "." .. CoreSequenceManager.SequenceManager.SEQUENCE_FILE_EXTENSION

	return self:get_cleaned_path(unit_file), self:get_cleaned_path(object_file), self:get_cleaned_path(sequence_file), tostring(unit_data:anim() and unit_data:anim():t())
end

function MacroDebug:get_cleaned_path(path)
	if path then
		local clean_path = string.gsub(tostring(path), "(.-)[/\\]+(.-)", "%1/%2")
		local hit_count = nil

		repeat
			clean_path, hit_count = string.gsub(clean_path, "/[^/:]+/%.%.", "")
		until hit_count == 0

		return clean_path
	else
		return nil
	end
end

function MacroDebug:ray_push(velocity_dir, velocity_length, mass)
	local ray = self:get_ray()

	if ray then
		self:push(ray.unit, velocity_dir or ray.ray, velocity_length, mass)
		cat_print("debug", "Unit: " .. tostring(ray.unit:name():t()) .. ", Body: " .. tostring(ray.body:name():t()))
	else
		cat_error("debug", "No unit found.")
	end
end

function MacroDebug:push(unit, velocity_dir, velocity_length, mass)
	velocity_dir = velocity_dir or self._default_push_velocity_dir
	velocity_length = velocity_length or self._default_push_velocity_length
	local effect_name = Idstring("core/physic_effects/debugmanager_push")

	CoreEngineAccess._editor_load(Idstring("physic_effect"), effect_name)
	World:play_physic_effect(effect_name, unit, velocity_dir * velocity_length, mass or self._default_push_mass)
end

function MacroDebug:ray_gravitate(multiplier)
	local ray = self:get_ray()

	if ray then
		self:gravitate(ray.unit, multiplier)
		cat_print("debug", "Unit: " .. tostring(ray.unit:name():t()) .. ", Body: " .. tostring(ray.body:name():t()))
	else
		cat_error("debug", "No unit found.")
	end
end

function MacroDebug:gravitate(unit, multiplier)
	local effect_name = Idstring("core/physic_effects/debugmanager_gravitate")

	CoreEngineAccess._editor_load(Idstring("physic_effect"), effect_name)
	World:play_physic_effect(effect_name, unit, -World:gravity() * (multiplier or 1))
end

function MacroDebug:stop_gravitate()
	local effect_name_str = "core/physic_effects/debugmanager_gravitate"
	local effect_name = Idstring(effect_name_str)

	CoreEngineAccess._editor_load(Idstring("physic_effect"), effect_name)
	World:stop_physic_effect(effect_name_str)
end

function MacroDebug:ray_hover(multiplier)
	local ray = self:get_ray()

	if ray then
		self:hover(ray.unit, multiplier)
		cat_print("debug", "Unit: " .. tostring(ray.unit:name():t()) .. ", Body: " .. tostring(ray.body:name():t()))
	else
		cat_error("debug", "No unit found.")
	end
end

function MacroDebug:hover(unit, multiplier)
	local effect_name = Idstring("core/physic_effects/debugmanager_hover")

	CoreEngineAccess._editor_load(Idstring("physic_effect"), effect_name)
	World:play_physic_effect(effect_name, unit, -World:gravity() * (multiplier or 1))
end

function MacroDebug:stop_hover()
	local effect_name_str = "core/physic_effects/debugmanager_hover"
	local effect_name = Idstring(effect_name_str)

	CoreEngineAccess._editor_load(Idstring("physic_effect"), effect_name)
	World:stop_physic_effect(effect_name_str)
end

function MacroDebug:effect(effect)
	local cam = managers.viewport:get_current_camera()
	local effect_manager = World:effect_manager()

	effect_manager:spawn({
		effect = effect:id(),
		position = (cam and cam:position() or Vector3()) + (cam and cam:rotation():y() or math.Y) * 200,
		normal = math.UP
	})
end

function MacroDebug:ray_run_sequence(sequence, damage_type, source_unit, dest_body, normal, position, direction, damage, velocity, params)
	local ray = self:get_ray()

	if ray then
		cat_print("debug", "Unit: " .. tostring(ray.unit:name():t()) .. ", Body: " .. tostring(ray.body:name():t()))

		local damage_ext = ray.unit:damage()

		if damage_ext then
			if damage_ext.run_sequence then
				damage_ext:run_sequence(sequence, damage_type or "bullet", source_unit or ray.unit, dest_body or ray.body, normal or ray.normal, position or ray.position, direction or ray.ray, damage or 0, velocity or ray.ray * 1000, params)
			else
				cat_error("debug", "Damage extension lacks run_sequence-function.")
			end
		else
			cat_error("debug", "No damage extension.")
		end
	else
		cat_error("debug", "No unit found.")
	end
end

function MacroDebug:ray_select_unit()
	local ray = self:get_ray()

	if ray then
		cat_print("debug", "Unit: " .. tostring(ray.unit:name():t()) .. ", Body: " .. tostring(ray.body:name():t()))
		self:select_unit(ray.unit)
	else
		cat_error("debug", "No unit found.")
	end
end

function MacroDebug:select_unit(unit)
	local selected_unit = World:selected_unit()

	self:set_last_unit(unit or self._last_unit)

	if alive(self._last_unit) and alive(selected_unit) and self._last_unit:key() == selected_unit:key() then
		World:select_unit()
	else
		World:select_unit(self._last_unit)
	end
end

function MacroDebug:anim_verbose(unit)
	local selected_unit = World:selected_unit()

	self:set_last_unit(unit or self._last_unit or selected_unit)

	if alive(self._last_unit) then
		World:select_unit(self._last_unit)

		if self._verbose_unit_map[self._last_unit:key()] then
			self._verbose_unit_map[self._last_unit:key()] = nil

			Application:console_command("animation verbose off")
		else
			self._verbose_unit_map[self._last_unit:key()] = true

			Application:console_command("animation modifiers")
			Application:console_command("animation playing")
			Application:console_command("animation verbose")
		end
	end
end

function MacroDebug:spawn(unit_name, pos, rot)
	unit_name = unit_name or self._last_unit_name

	if DB:has("unit", unit_name) then
		local cam = managers.viewport:get_current_camera()
		local pos = pos or cam and cam:position() + cam:rotation():y() * self._default_spawn_cam_offset or Vector3()
		local rot = rot or cam and cam:rotation() or Rotation()

		CoreEngineAccess._editor_load(Idstring("unit"), unit_name:id())

		local unit = World:spawn_unit(unit_name:id(), pos, rot)

		if alive(unit) then
			self:set_last_unit(unit)
		end
	else
		cat_print("debug", "Tried to spawn non-existing unit \"" .. tostring(unit_name:t()) .. "\".")
	end
end

function MacroDebug:multi_spawn(unit_name, unit_offset, count_x, count_y, count_z, pos, rot)
	local cam = managers.viewport:get_current_camera()
	local cam_rot = cam and cam:rotation() or Rotation()
	local pos = pos or cam:position() + cam_rot:y() * self._default_spawn_cam_offset
	unit_offset = unit_offset or self._default_multi_spawn_unit_offset
	count_x = (count_x or self._default_multi_spawn_unit_count) - 1
	count_y = (count_y or 1) - 1
	count_z = (count_z or 1) - 1

	for z = 0, count_z do
		local z_offset = cam_rot:y() * (count_z / 2 - z) * unit_offset

		for y = 0, count_y do
			local yz_offset = z_offset + cam_rot:z() * (count_y / 2 - y) * unit_offset

			for x = 0, count_x do
				local offset = yz_offset + cam_rot:x() * (count_x / 2 - x) * unit_offset

				self:spawn(unit_name, pos + offset, rot)
			end
		end
	end
end

function MacroDebug:ray_profile_unit(function_name_list, ignore_map, include_only_map, min_range, max_range, disabled, graph_disabled, gui_disabled, print_counters, instance_override)
	local ray = self:get_ray()

	if ray then
		cat_print("debug", "Unit: " .. ray.unit:name() .. ", Body: " .. ray.body:name())
		self:profile_unit(ray.unit)
	else
		cat_error("debug", "No unit found.")
	end
end

function MacroDebug:profile_unit(unit, function_name_list, ignore_map, include_only_map, min_range, max_range, disabled, graph_disabled, gui_disabled, print_counters, instance_override)
	if alive(unit) then
		self:set_last_unit(unit)
	end

	if alive(self._last_unit) then
		local enabled = not self._profile_unit_map[self._last_unit:key()]

		managers.debug.profiler:set_unit_enabled(self._last_unit, enabled, function_name_list, ignore_map, include_only_map, min_range, max_range, disabled, graph_disabled, gui_disabled, print_counters, instance_override)

		self._profile_unit_map[self._last_unit:key()] = enabled
	end
end

function MacroDebug:unit_goto(add_to_path, unit, pos)
	unit = unit or self:get_last_unit()

	if alive(unit) and unit:base() and unit:base().debug_goto then
		if not pos then
			local ray = self:get_ray(true)

			if ray then
				pos = ray.position
			else
				cat_error("debug", "No position available to do a goto-action with.")
			end
		end

		if pos then
			unit:base():debug_goto(add_to_path, pos)
		end
	else
		cat_error("debug", "Goto-action not available on unit \"" .. tostring(unit) .. "\".")
	end
end

function MacroDebug:fps(graph)
	if not self._check_fps and not self._check_fps_pause_time then
		managers.debug:set_enabled(true)
		managers.debug:set_enabled_paused(true)
		managers.debug.gui:set_enabled(true)
		self:set_enabled(true)

		self._check_fps = true
		self._check_fps_graph = graph
		self._check_fps_time = nil
		self._check_fps_count = nil
		self._check_fps_min = nil
		self._check_fps_max = nil
		self._check_fps_old = nil

		managers.debug.gui:set_color(1, 1, 1, 1)
		managers.debug.gui:set_color(2, 0, 0, 1)
		managers.debug.gui:set_color(3, 0, 1, 0)
		managers.debug.gui:set_color(4, 1, 0, 0)

		if graph then
			managers.debug.graph:set_enabled(true)
			managers.debug.graph:set_max_count(1, 50)
			managers.debug.graph:set_max_count(2, 50)
			managers.debug.graph:set_max_count(3, 50)
			managers.debug.graph:set_max_count(4, 50)
		end
	else
		if self._check_fps_graph then
			managers.debug.graph:clear(1)
			managers.debug.graph:clear(2)
			managers.debug.graph:clear(3)
			managers.debug.graph:clear(4)
			managers.debug.graph:set_max_count(1, managers.debug.pos:get_max_count(nil))
			managers.debug.graph:set_max_count(2, managers.debug.pos:get_max_count(nil))
			managers.debug.graph:set_max_count(3, managers.debug.pos:get_max_count(nil))
			managers.debug.graph:set_max_count(4, managers.debug.pos:get_max_count(nil))
		end

		self._check_fps_pause_time = nil
		self._check_fps = nil
		self._check_fps_graph = nil
		self._check_fps_time = nil
		self._check_fps_count = nil
		self._check_fps_min = nil
		self._check_fps_max = nil
		self._check_fps_old = nil

		managers.debug.gui:set(1, nil)
		managers.debug.gui:set_color(1, 1, 0, 0)
		managers.debug.gui:set(2, nil)
		managers.debug.gui:set_color(2, 1, 0, 0)
		managers.debug.gui:set(3, nil)
		managers.debug.gui:set_color(3, 1, 0, 0)
		managers.debug.gui:set(4, nil)
		managers.debug.gui:set_color(4, 1, 0, 0)
	end
end

function MacroDebug:is_fps_enabled()
	return self._check_fps or self._check_fps_pause_time
end

function MacroDebug:set_fps_paused(paused)
	if not paused ~= not self._check_fps_pause_time then
		self:toggle_fps_paused()
	end
end

function MacroDebug:toggle_fps_paused()
	local wall_time = TimerManager:wall():time()

	if self._check_fps_pause_time then
		if self._check_fps_time then
			self._check_fps_time = self._check_fps_time + wall_time - self._check_fps_pause_time
		end

		self._check_fps = true
		self._check_fps_pause_time = nil
	elseif self._check_fps then
		self._check_fps = nil
		self._check_fps_pause_time = wall_time
	end
end

function MacroDebug:test_spawn_all(layer_name, sub_type)
	if not managers.editor then
		cat_error("debug", "Need to run this in the editor.")
	elseif not layer_name then
		local allowed_layer_name_map = {
			Statics = true
		}

		for next_layer_name, layer in pairs(managers.editor._layers) do
			if allowed_layer_name_map[next_layer_name] then
				layer:test_spawn(sub_type)
			end
		end
	else
		local layer = managers.editor._layers[layer_name]

		if not layer then
			cat_error("debug", "Layer name \"" .. tostring(layer_name) .. "\" doesn't exists.")
		else
			layer:test_spawn(sub_type)
		end
	end
end

function MacroDebug:set_draw_unit_enabled(unit_name, is_enabled, draw_camera_line, draw_on_top, red, green, blue, disabled_color_scale)
	local unit_name_id = nil

	if type(unit_name) == "string" then
		unit_name_id = Idstring(unit_name)
	else
		unit_name_id = unit_name
	end

	local unit_name_id_key = unit_name_id:key()

	if is_enabled then
		local unit_list = World:find_units_quick("all")
		local draw_unit_list = {}

		for _, unit in ipairs(unit_list) do
			if unit:name() == unit_name_id then
				table.insert(draw_unit_list, unit)
			end
		end

		if not next(draw_unit_list) then
			cat_error("debug", "No unit found.")

			return
		end

		managers.debug:set_enabled(true)
		managers.debug:set_enabled_paused(true)
		self:set_enabled(true)

		disabled_color_scale = disabled_color_scale or 0.5
		local pen = Draw:pen(Color(red or 1, green or 1, blue or 1), draw_on_top and "no_z" or "normal")
		local disabled_red = (red or 1) * disabled_color_scale
		local disabled_green = (red or 1) * disabled_color_scale
		local disabled_blue = (red or 1) * disabled_color_scale
		local disabled_pen = Draw:pen(Color(disabled_red, disabled_green, disabled_blue), draw_on_top and "no_z" or "normal")
		local data = {
			draw_unit_list = draw_unit_list,
			draw_camera_line = draw_camera_line,
			pen = pen,
			disabled_pen = disabled_pen
		}
		self._draw_unit_map = self._draw_unit_map or {}
		self._draw_unit_map[unit_name_id_key] = data
	elseif self._draw_unit_map and self._draw_unit_map[unit_name_id_key] then
		self._draw_unit_map[unit_name_id_key] = nil

		if not next(self._draw_unit_map) then
			self._draw_unit_map = nil
		end
	end
end

function MacroDebug:get_file_list_by_type(file_type)
	local index = "indices/types/" .. tostring(file_type)
	local file = DB:has("index", index) and DB:open("index", index) or nil

	if file == nil then
		return {}
	else
		local data = file:read()

		file:close()

		return string.split(data, "[\r\n]")
	end
end

function MacroDebug:get_asset_path()
	local is_assetslocation_arg = nil
	local relative_path = "../../assets/"

	for _, v in ipairs(Application:argv()) do
		if v == "-assetslocation" then
			is_assetslocation_arg = true
		elseif is_assetslocation_arg then
			relative_path = v .. "/assets/"

			break
		end
	end

	return self:get_cleaned_path(Application:nice_path(Application:base_path() .. relative_path, true))
end

function MacroDebug:check_dangerous_network_slot(slot_list)
	slot_list = slot_list or {
		0
	}
	local asset_path = self:get_asset_path()
	local unit_file_list = self:get_file_list_by_type("unit")
	local found_unit_file_map = {}

	for _, unit_file in ipairs(unit_file_list) do
		local unit_node = DB:load_node("unit", unit_file)
		local network_sync, object_file = nil
		local original_slot = tonumber(unit_node:parameter("slot"))

		for child_node in unit_node:children() do
			local child_node_name = child_node:name()

			if child_node_name == "network" then
				local sync_type = child_node:parameter("sync")

				if sync_type and sync_type ~= "none" then
					network_sync = sync_type
				else
					network_sync = false
				end
			elseif child_node_name == "object" then
				object_file = child_node:parameter("file")
			end
		end

		if network_sync and object_file and DB:has("object", object_file) then
			local object_node = DB:load_node("object", object_file)
			local object_sequence_node = nil
			local unit_file_path = asset_path .. tostring(unit_file) .. ".unit"
			local object_file_path = asset_path .. tostring(object_file) .. ".object"

			local function check_slot_func(slot, sequence_file_path)
				if table.contains(slot_list, tonumber(slot)) then
					local sub_map = found_unit_file_map[slot]

					if not sub_map then
						sub_map = {}
						found_unit_file_map[slot] = sub_map
					end

					sub_map[unit_file] = {
						unit = unit_file_path,
						object = object_file_path,
						sequence = sequence_file_path,
						sync = network_sync,
						original_slot = original_slot,
						slot = slot
					}

					return true
				else
					return false
				end
			end

			check_slot_func(original_slot, nil)

			for child_node in object_node:children() do
				local child_node_name = child_node:name()

				if child_node_name == "sequence_manager" then
					object_sequence_node = child_node

					break
				end
			end

			if object_sequence_node then
				local sequence_file = object_sequence_node:parameter("file")
				local sequence_file_path = asset_path .. tostring(sequence_file) .. ".sequence_manager"

				if sequence_file and DB:has("sequence_manager", sequence_file) then
					local sequence_data = PackageManager:editor_load_script_data(Idstring("sequence_manager"), Idstring(sequence_file))

					local function find_slot_func(map, recursive_func)
						for k, v in pairs(map) do
							if type(v) == "table" then
								if k == "slot" then
									local slot = v.slot

									if check_slot_func(slot, sequence_file_path) then
										return true
									end
								end

								if recursive_func(v, recursive_func) then
									return true
								end
							end
						end

						return false
					end

					find_slot_func(sequence_data, find_slot_func)
				else
					Application:error("Object " .. tostring(object_file) .. " has an invalid <sequence_manager file=\"...\"/> node.")
				end
			end
		end
	end

	for _, list in pairs(found_unit_file_map) do
		for unit_name, data in pairs(list) do
			cat_print("debug", "Slot: " .. (data.original_slot ~= data.slot and tostring(data.original_slot) .. " -> " or "") .. tostring(data.slot) .. ", Sync: " .. tostring(data.sync) .. ", Name: " .. tostring(unit_name) .. "\nUnit file: " .. data.unit .. "\nObject file: " .. data.object .. (data.sequence and "\nSequence file: " .. data.sequence or "") .. "\n")
		end
	end

	return found_unit_file_map
end

function MacroDebug:update(t, dt)
	if self._check_fps then
		local wall_time = TimerManager:wall():time()
		local fps, avg_fps = nil

		if not self._check_fps_time then
			self._check_fps_time = wall_time
			self._check_fps_count = 0
		else
			local duration = wall_time - self._check_fps_time
			self._check_fps_count = self._check_fps_count + 1

			if duration > 0 then
				avg_fps = self._check_fps_count / duration
			end

			if dt > 0 then
				fps = 1 / dt

				if (not self._check_fps_min or fps < self._check_fps_min) and self._check_fps_old and self._check_fps_old - fps < 5 then
					self._check_fps_min = fps
				end

				if (not self._check_fps_max or self._check_fps_max < fps) and self._check_fps_old and fps - self._check_fps_old < 5 then
					self._check_fps_max = fps
				end

				self._check_fps_old = fps
			end

			if fps then
				managers.debug.gui:set(1, "FPS: " .. string.format("%.1f", fps))
			else
				managers.debug.gui:set(1, "FPS: " .. tostring(fps))
			end

			if avg_fps then
				managers.debug.gui:set(2, "AVG: " .. string.format("%.1f", avg_fps))
			else
				managers.debug.gui:set(2, "AVG: " .. tostring(avg_fps))
			end

			if self._check_fps_max then
				managers.debug.gui:set(3, "MAX: " .. string.format("%.1f", self._check_fps_max))
			else
				managers.debug.gui:set(3, "MAX: " .. tostring(self._check_fps_max))
			end

			if self._check_fps_min then
				managers.debug.gui:set(4, "MIN: " .. string.format("%.1f", self._check_fps_min))
			else
				managers.debug.gui:set(4, "MIN: " .. tostring(self._check_fps_min))
			end

			if self._check_fps_graph and fps and avg_fps and self._check_fps_max and self._check_fps_min then
				managers.debug.graph:add(fps or 0, 1, 1, 1, 1)
				managers.debug.graph:add(avg_fps or 0, 2, 0, 0, 1)
				managers.debug.graph:add(self._check_fps_max or 0, 3, 0, 1, 0)
				managers.debug.graph:add(self._check_fps_min or 0, 4, 1, 0, 0)
			end
		end
	end

	if self._draw_unit_map then
		local remove_data_map = nil

		for unit_name_id_key, data in pairs(self._draw_unit_map) do
			local remove_unit_list = nil

			for i, unit in ipairs(data.draw_unit_list) do
				if not alive(unit) then
					remove_unit_list = remove_unit_list or {}

					table.insert(remove_unit_list, i)
				else
					local pen = unit:enabled() and unit:visible() and data.pen or data.disabled_pen

					pen:draw(unit)

					if data.draw_camera_line then
						local cam = managers.viewport:get_current_camera()
						local rot = cam and cam:rotation() or Rotation()

						pen:line(unit:position(), (cam and cam:position() or Vector3()) + rot:y() * 10 - rot:z() * 1)
					end
				end
			end

			if remove_unit_list then
				for i, remove_index in ipairs(remove_unit_list) do
					table.remove(data.draw_unit_list, remove_index - i + 1)
				end

				if not next(data.draw_unit_list) then
					remove_data_map = remove_data_map or {}
					remove_data_map[unit_name_id_key] = true
				end
			end
		end

		if remove_data_map then
			for remove_unit_name_id_key in pairs(remove_data_map) do
				self._draw_unit_map[remove_unit_name_id_key] = nil
			end

			if not next(self._draw_unit_map) then
				self._draw_unit_map = nil
			end
		end
	end
end

function MacroDebug:clear()
	MacroDebug.super.clear(self)

	if self._check_fps then
		self:fps()
	end

	self._draw_unit_map = nil
end

function MacroDebug:toggle_endurance_damage_hook(skip_print, line_duration)
	line_duration = line_duration or self.DEFAULT_LINE_DURATION

	if self._endurance_damage_hook then
		managers.debug.hijack:unhijack_func(CoreSequenceManager.EnduranceElement, "activate", true)
		cat_debug("debug", "Disabled endurance damage hook.")

		self._endurance_damage_hook = nil
	elseif not skip_print or line_duration and line_duration > 0 then
		managers.debug.hijack:hijack_func(CoreSequenceManager.EnduranceElement, "activate", callback(self, self, "_hijacked_endurance_activate", {
			skip_print = skip_print,
			line_duration = line_duration
		}), true)
		cat_debug("debug", "Enabled endurance damage hook. Output: " .. tostring(not skip_print) .. ", Line duration: " .. tostring(line_duration))

		self._endurance_damage_hook = true
	else
		cat_debug("debug", "Ignored endurance damage hook. Output: " .. tostring(not skip_print) .. ", Line duration: " .. tostring(line_duration))
	end
end

function MacroDebug:_hijacked_endurance_activate(option_map, endurance, env)
	if not option_map.skip_print then
		cat_print("debug", string.format("Damage: %d, Type: %s, Unit: %s, Body: %s", env.damage, env.damage_type, env.dest_unit:name(), env.dest_body:name()))
	end

	if option_map.line_duration > 0 then
		managers.debug.simple:draw_line(env.pos, env.pos - env.dir * 200, option_map.line_duration)
	end

	endurance:hijacked_activate(env)
end

MemoryDebug = MemoryDebug or class(BaseDebug)
MemoryDebug.CALC_TYPE_FUNC_MAP = DebugManager.CALC_TYPE_FUNC_MAP or {
	table = "add_calc_table",
	boolean = "add_calc_boolean",
	function = "add_calc_function",
	string = "add_calc_string",
	userdata = "add_calc_userdata",
	number = "add_calc_number"
}
MemoryDebug.PRIMITIVE_VALUE_TYPE_MAP = DebugManager.PRIMITIVE_VALUE_TYPE_MAP or {
	boolean = true,
	string = true,
	number = true
}

function MemoryDebug:extensions()
	local unit_list = World:find_units_quick("all")
	local extension_class_map = {}
	local extension_data_list = {}

	for _, unit in ipairs(unit_list) do
		local extension_list = unit:extensions()

		for _, extension_name in ipairs(extension_list) do
			local extension_instance = unit[extension_name](unit)
			local extension_class = getmetatable(extension_instance)
			local class_name_string = CoreDebug.class_name(extension_class, _M)
			local data = extension_class_map[class_name_string]
			data = data or {
				count = 0,
				unit_count = {},
				unit_list = {}
			}
			data.count = data.count + 1

			table.insert(data.unit_list, unit)

			local unit_name = unit:name()
			data.unit_count[unit_name] = (data.unit_count[unit_name] or 0) + 1
			extension_class_map[class_name_string] = data
		end
	end

	return extension_class_map
end

function MemoryDebug:find_instance(find_value, is_meta_data, print_path, find_all, seen_map, map)
	if find_value ~= nil then
		local function func(path, key, value, populate_map, info_map, seen_map, func)
			return self:find_instance_callback(print_path, path, key, value, populate_map, info_map, seen_map, find_value, is_meta_data, find_all)
		end

		return self:traverse_instances(func, seen_map, map)
	else
		return nil, nil
	end
end

function MemoryDebug:find_instance_callback(print_path, path, key, value, populate_map, info_map, seen_map, find_value, is_meta_data, find_all)
	local found = nil

	if is_meta_data then
		if getmetatable(value) == find_value or getmetatable(key) == find_value then
			found = true
		end
	elseif value == find_value or key == find_value then
		found = true
	end

	if found then
		populate_map[key] = value

		if print_path then
			if path then
				path = path .. "."
			else
				path = ""
			end

			cat_print("debug", path .. tostring(key))
		end
	end

	return found, find_all
end

function MemoryDebug:traverse_instances(func, seen_map, map)
	seen_map = seen_map or {}
	local populate_map = {}
	local info_map = {
		found_count = 0,
		count = 0,
		seen_count = 0
	}

	if map then
		self:traverse_instances_recursively(nil, nil, map, func, populate_map, info_map, seen_map)
	else
		local global_map = {}

		self:traverse_instances_recursively(nil, "_G", _G, func, global_map, info_map, seen_map)

		if next(global_map) ~= nil then
			populate_map._G = global_map
		end

		local unit_list = World:unit_manager():get_units()
		local unit_map = {}
		local next_unit_map = {}
		local next_extension_map = {}
		local unit_name, path = nil

		for _, unit in ipairs(unit_list) do
			unit_name = unit:name()
			path = "Units." .. unit_name

			for index, extension_name in ipairs(unit:extensions()) do
				self:traverse_instances_recursively(path, extension_name, unit[extension_name](unit), func, next_extension_map, info_map, seen_map)

				if next(next_extension_map) ~= nil then
					next_unit_map[extension_name] = next_extension_map
					next_extension_map = {}
				end
			end

			if next(next_unit_map) ~= nil then
				unit_map[unit:name()] = next_unit_map
				next_unit_map = {}
			end
		end

		if next(unit_map) ~= nil then
			populate_map.Units = unit_map
		end
	end

	if next(populate_map) ~= nil then
		return populate_map, info_map
	else
		return nil, info_map
	end
end

function MemoryDebug:traverse_instances_recursively(path, key, value, func, populate_map, info_map, seen_map)
	info_map.count = info_map.count + 1

	if not seen_map[value] then
		info_map.seen_count = info_map.seen_count + 1
		local found, find_again = func(path, key, value, populate_map, info_map, seen_map, func)

		if found then
			info_map.found_count = info_map.found_count + 1
		end

		if not find_again then
			seen_map[value] = true
		end

		if type(value) == "table" then
			local next_populate_map = {}

			if path then
				if type(key) == "number" then
					path = path .. "[" .. key .. "]"
				else
					path = path .. "." .. tostring(key)
				end
			else
				path = key
			end

			for next_key, next_value in pairs(value) do
				self:traverse_instances_recursively(path, next_key, next_value, func, next_populate_map, info_map, seen_map)

				if next(next_populate_map) ~= nil then
					populate_map[next_key] = next_populate_map
					next_populate_map = {}
				end
			end
		end
	end
end

function MemoryDebug:calc(map, seen_map)
	local global_populate_map = nil

	if map ~= nil then
		local function func(path, key, value, populate_map, info_map, seen_map, func)
			global_populate_map = global_populate_map or populate_map

			if key ~= nil then
				self:add_calc(key, value, false, global_populate_map)
				self:add_calc(key, value, true, global_populate_map)
			end

			return true, false
		end

		return self:traverse_instances(func, seen_map, map)
	else
		return nil, nil
	end
end

function MemoryDebug:add_calc(key, value, is_key, populate_map)
	local check_value = is_key and key or value
	local check_value_type = type(check_value)

	if is_key then
		local bits = 128
		populate_map.key_bits = (populate_map.key_bits or 0) + bits
		populate_map.key_count = (populate_map.key_count or 0) + 1
		populate_map.total_bits = (populate_map.total_bits or 0) + bits
	end

	local is_same_primitive_key = is_key and not self.PRIMITIVE_VALUE_TYPE_MAP[check_value_type] and key == value

	if not is_same_primitive_key then
		if check_value_type then
			local func_name = self.CALC_TYPE_FUNC_MAP[check_value_type]

			if func_name then
				local bits = self[func_name](self, check_value, populate_map)
				local bits_name = check_value_type .. "_bits"
				local count_name = check_value_type .. "_count"
				populate_map[bits_name] = (populate_map[bits_name] or 0) + bits
				populate_map[count_name] = (populate_map[count_name] or 0) + 1
				populate_map.total_bits = (populate_map.total_bits or 0) + bits
			else
				Application:error("Unsupported value type \"" .. tostring(check_value_type) .. "\" (is key: " .. tostring(is_key) .. ").")
			end
		else
			Application:error("Nil type for value \"" .. tostring(check_value) .. "\" (is key: " .. tostring(is_key) .. ").")
		end
	end
end

function MemoryDebug:add_calc_string(value, populate_map)
	return #value * 2 * 8
end

function MemoryDebug:add_calc_number(value, populate_map)
	return 32
end

function MemoryDebug:add_calc_boolean(value, populate_map)
	return 1
end

function MemoryDebug:add_calc_userdata(value, populate_map)
	return 128
end

function MemoryDebug:add_calc_table(value, populate_map)
	return 0
end

function MemoryDebug:add_calc_function(value, populate_map)
	return 128
end

ConsoleDebug = ConsoleDebug or class(BaseDebug)
ConsoleDebug.IS_PREFERRED_DISABLED = true

function ConsoleDebug:init()
	ConsoleDebug.super.init(self)
end

function ConsoleDebug:destroy()
	self:clear()
end

function ConsoleDebug:set_enabled(enabled)
	local was_enabled = self._enabled

	ConsoleDebug.super.set_enabled(self, enabled)

	if not was_enabled ~= not enabled then
		if enabled then
			self:setup_controller()
			managers.debug.hijack:hijack_func(_G, "print", callback(self, self, "hijacked_print"), true)
			managers.debug.hijack:hijack_func(Application, "debug", callback(self, self, "hijacked_debug"))
			managers.debug.hijack:hijack_func(Application, "error", callback(self, self, "hijacked_error"))
			managers.debug.hijack:hijack_func(Application, "stack_dump", callback(self, self, "hijacked_stack_dump"))

			if not alive(self._workspace) then
				self:setup()
			end

			self:invalidate()
		else
			self:destroy_controller()
			managers.debug.hijack:unhijack_func(_G, "print", true)
			managers.debug.hijack:unhijack_func(Application, "debug")
			managers.debug.hijack:unhijack_func(Application, "error")
			managers.debug.hijack:unhijack_func(Application, "stack_dump")
		end
	end
end

function ConsoleDebug:hijacked_print(...)
	_G.hijacked_print(...)
	self:add_print(...)
end

function ConsoleDebug:hijacked_debug(app, ...)
	app:hijacked_debug(...)
	self:add_debug(...)
end

function ConsoleDebug:hijacked_error(app, ...)
	app:hijacked_error(...)
	self:add_error(...)
end

function ConsoleDebug:hijacked_stack_dump(app, ...)
	app:hijacked_stack_dump(...)
	self:add_print(self:get_stack_dump_text(3))
end

function ConsoleDebug:get_stack_dump_text(skip_level)
	local text = nil
	local level = (skip_level or 0) + 1

	while true do
		local info = debug.getinfo(level, "Sl")

		if not info then
			break
		else
			if text then
				text = text .. "\n"
			else
				text = ""
			end

			if info.what == "C" then
				text = text .. string.format("%s:%d (C++ method)", info.source, info.currentline)
			else
				text = text .. string.format("%s:%d", info.source, info.currentline)
			end
		end

		level = level + 1
	end

	return text or ""
end

function ConsoleDebug:clear()
	ConsoleDebug.super.clear(self)

	if alive(self._workspace) then
		self._workspace:panel():clear()
		managers.gui_data:destroy_workspace(self._workspace)
	end

	self:destroy_controller()

	self._workspace = nil
	self._panel = nil
	self._text_gui = nil
	self._text_list = nil
	self._command_text_gui = nil
	self._scroll = nil
end

function ConsoleDebug:toggle_visible()
	self:set_visible(not self:get_visible())
end

function ConsoleDebug:set_visible(visible)
	if not self._visible ~= not visible then
		self._visible = visible

		if not alive(self._workspace) then
			self:setup()
		end

		if visible then
			self._workspace:show()
		else
			self._workspace:hide()
		end
	end
end

function ConsoleDebug:get_visible()
	return self._visible
end

function ConsoleDebug:add_print(...)
	self:add_text(self:get_arg_text(...), Color(1, 0, 1))
end

function ConsoleDebug:add_debug(...)
	self:add_text(self:get_arg_text(...), Color(0.23529411764705882, 0.6352941176470588, 0.2627450980392157))
end

function ConsoleDebug:add_error(...)
	self:add_text(self:get_arg_text(...), Color(1, 0, 0))
end

function ConsoleDebug:get_arg_text(...)
	local text = ""

	for i, arg in ipairs({
		...
	}) do
		if i > 1 then
			text = text .. "\t"
		end

		text = text .. tostring(arg)
	end

	return text
end

function ConsoleDebug:add_text(text, color)
	if not alive(self._workspace) then
		self:setup()
	end

	local formatted_text = string.gsub(tostring(text), "\t", "    ")
	local text_data = {
		time = TimerManager:wall():time(),
		text = formatted_text,
		color = color
	}

	table.insert(self._text_list, text_data)

	if self._scroll > 0 then
		self._scroll = self._scroll + 1
	end

	self:invalidate()
end

function ConsoleDebug:invalidate()
	if alive(self._workspace) then
		local old_command_text = ""

		if alive(self._command_text_gui) then
			old_command_text = self._command_text_gui:text()
		end

		self._panel:clear()

		local floored_scroll = math.floor(self._scroll)
		local index = #self._text_list - floored_scroll
		local config = {
			font = "core/fonts/diesel",
			font_size = 15,
			layer = 1000000,
			wrap = true,
			width = self._panel:width()
		}
		local y = self._panel:height() - config.font_size
		config.color = Color.white
		config.text = old_command_text
		self._command_text_gui = self._panel:text(config)

		self._command_text_gui:enter_text(function (o, s)
			o:replace_text(s)
		end)
		self._command_text_gui:key_press(function (o, key)
			local s, e = o:selection()

			if key == Idstring("enter") or key == Idstring("num enter") then
				local text = o:text()

				o:set_text("")
				Application:console_command(text)
			elseif key == Idstring("backspace") then
				if s == e and s > 0 then
					o:set_selection(s - 1, e)
				end

				o:replace_text("")
			elseif key == Idstring("delete") then
				if s == e and s < utf8.len(o:text()) then
					o:set_selection(s, e + 1)
				end

				o:replace_text("")
			elseif key == Idstring("left") then
				if s < e then
					o:set_selection(s, s)
				elseif s > 0 then
					o:set_selection(s - 1, s - 1)
				end
			elseif key == Idstring("right") then
				if s < e then
					o:set_selection(e, e)
				elseif s < utf8.len(o:text()) then
					o:set_selection(s + 1, s + 1)
				end
			end
		end)

		local command_text_height = math.max(self._command_text_gui:line_height() * self._command_text_gui:number_of_lines(), config.font_size)
		y = y - command_text_height

		self._command_text_gui:set_height(command_text_height)
		self._command_text_gui:set_y(y)

		y = y - command_text_height
		local remainder_scroll = self._scroll - floored_scroll
		local scroll_first = remainder_scroll > 0

		while index > 0 and y > 0 do
			local text_data = self._text_list[index]
			config.color = text_data.color or Color.white
			config.text = string.format("[%.2f] %s", text_data.time, text_data.text)
			local text_gui = self._panel:text(config)
			local height = text_gui:line_height() * text_gui:number_of_lines()

			if scroll_first then
				y = y + remainder_scroll * height
				scroll_first = false
			end

			y = y - height

			text_gui:set_height(height)
			text_gui:set_y(y)

			index = index - 1
		end
	end
end

function ConsoleDebug:setup()
	self._workspace = managers.gui_data:create_fullscreen_workspace()
	local keyboard = Input:keyboard()

	if keyboard and keyboard:enabled() and keyboard:connected() then
		self._workspace:connect_keyboard(keyboard)
	end

	local gui = self._workspace:panel():gui(Idstring("core/guis/core_debug_manager"))
	local safe_rect = managers.viewport:get_safe_rect_pixels()
	local config = {
		x = safe_rect.x,
		y = safe_rect.y,
		width = safe_rect.width,
		height = safe_rect.height,
		halign = "grow",
		valign = "grow"
	}
	self._panel = gui:panel(config)

	if self._visible then
		self._workspace:show()
	else
		self._workspace:hide()
	end

	self._text_list = {}
	self._scroll = 0

	self:setup_controller()
end

function ConsoleDebug:setup_controller()
	if not self._controller and self._enabled then
		self._controller = managers.controller:create_controller("core_debug_console", nil, true)

		self._controller:add_trigger("toggle_console", callback(self, self, "toggle_visible"))
		self._controller:add_trigger("console_scroll_page_up", callback(self, self, "scroll_page_up"))
		self._controller:add_trigger("console_scroll_page_down", callback(self, self, "scroll_page_down"))
		self._controller:enable()
	end
end

function ConsoleDebug:destroy_controller()
	if self._controller then
		self._controller:destroy()

		self._controller = nil
	end
end

function ConsoleDebug:update(t, dt)
	if self._enabled and self._visible and self._scroll then
		local up = self._controller:get_input_float("console_scroll_up")
		local down = self._controller:get_input_float("console_scroll_down")
		local y = up - down

		if y ~= 0 then
			self:set_scroll(self._scroll + y * dt * 10)
		end
	end
end

function ConsoleDebug:scroll_page_up()
	if self._scroll and self._visible then
		self:add_scroll(10)
	end
end

function ConsoleDebug:scroll_page_down()
	if self._scroll and self._visible then
		self:add_scroll(-10)
	end
end

function ConsoleDebug:add_scroll(scroll)
	self:set_scroll(self._scroll + scroll)
end

function ConsoleDebug:set_scroll(scroll)
	local old_scroll = self._scroll
	self._scroll = math.clamp(scroll, 0, math.max(0, #self._text_list - 1))

	if old_scroll ~= self._scroll then
		self:invalidate()
	end
end

MenuDebug = MenuDebug or class(BaseDebug)
MenuDebug.IS_PREFERRED_DISABLED = true

function MenuDebug:init()
	MenuDebug.super.init(self)
end

function MenuDebug:destroy()
	self:destroy_controller()

	if alive(self._workspace) then
		managers.gui_data:destroy_workspace(self._workspace)

		self._workspace = nil
		self._panel = nil
		self._option_panel = nil
		self._background_rect = nil
	end

	if self._resolution_changed_callback_id then
		managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)

		self._resolution_changed_callback_id = nil
	end
end

function MenuDebug:destroy_controller()
	if self._controller then
		self:set_controller_triggers_enabled(self._controller, false)
		self._controller:destroy()

		self._controller = nil
	end
end

function MenuDebug:set_enabled(enabled)
	local was_enabled = self._enabled

	MenuDebug.super.set_enabled(self, enabled)

	if not was_enabled ~= not enabled then
		local data_controller = self._menu_data and self._menu_data.controller

		if data_controller then
			self:set_controller_triggers_enabled(data_controller, enabled)
		end

		if enabled then
			if not data_controller then
				self:setup_controller()
			end

			self:setup_menu()
		else
			self:destroy()
		end
	end
end

function MenuDebug:toggle_visible()
	self:set_visible(not self:get_visible())
end

function MenuDebug:set_visible(visible)
	local always_visible = self._menu_data and self._menu_data.always_visible

	if not self._visible ~= not visible and (visible or not always_visible) then
		self._visible = visible

		if self._workspace then
			if visible then
				self._workspace:show()
			else
				self._workspace:hide()

				if self._menu_data and self._menu_data.auto_reset then
					self._current_menu_data = nil
					self._prev_menu_data_list = nil
					self._prev_menu_index_list = nil
					self._current_menu_index = nil

					self:setup_menu()
				end
			end
		end
	end
end

function MenuDebug:get_visible()
	return self._visible
end

function MenuDebug:clear()
	MenuDebug.super.clear(self)

	self._menu_data = nil

	self:setup_menu()
end

function MenuDebug:setup_controller()
	if not self._controller then
		self._controller = managers.controller:create_controller("core_debug_menu", nil, true)

		self:set_controller_triggers_enabled(self._controller, true)
		self._controller:set_enabled(true)
	end
end

function MenuDebug:set_controller_triggers_enabled(controller, enabled)
	if enabled then
		if not self._toggle_visible_func then
			self._toggle_visible_func = callback(self, self, "toggle_visible")
			self._change_selection_down_func = callback(self, self, "change_selection", -1)
			self._change_selection_up_func = callback(self, self, "change_selection", 1)
			self._confirm_func = callback(self, self, "confirm_button_pressed")
			self._cancel_func = callback(self, self, "cancel_button_pressed")
			self._left_func = callback(self, self, "left_button_pressed")
			self._right_func = callback(self, self, "right_button_pressed")
		end

		controller:add_trigger("toggle_menu", self._toggle_visible_func)
		controller:add_trigger("menu_up", self._change_selection_down_func)
		controller:add_trigger("menu_down", self._change_selection_up_func)
		controller:add_trigger("confirm", self._confirm_func)
		controller:add_trigger("cancel", self._cancel_func)
		controller:add_trigger("menu_left", self._left_func)
		controller:add_trigger("menu_right", self._right_func)
	elseif self._toggle_visible_func then
		controller:remove_trigger("toggle_menu", self._toggle_visible_func)
		controller:remove_trigger("menu_up", self._change_selection_down_func)
		controller:remove_trigger("menu_down", self._change_selection_up_func)
		controller:remove_trigger("confirm", self._confirm_func)
		controller:remove_trigger("cancel", self._cancel_func)
		controller:remove_trigger("menu_left", self._left_func)
		controller:remove_trigger("menu_right", self._right_func)

		self._toggle_visible_func = nil
		self._change_selection_down_func = nil
		self._change_selection_up_func = nil
		self._confirm_func = nil
		self._cancel_func = nil
		self._left_func = nil
		self._right_func = nil
	end
end

function MenuDebug:change_selection(change)
	local max_index = math.max(self._current_menu_data and #self._current_menu_data or 1, 1)
	self._current_menu_index = ((self._current_menu_index or 1) + change - 1) % max_index + 1

	self:setup_menu()
end

function MenuDebug:confirm_button_pressed()
	if self._current_menu_data then
		local next_menu_data = self._current_menu_data[self._current_menu_index or 1]

		if next_menu_data then
			if #next_menu_data > 0 then
				self._prev_menu_data_list = self._prev_menu_data_list or {}

				table.insert(self._prev_menu_data_list, self._current_menu_data)

				self._prev_menu_index_list = self._prev_menu_index_list or {}

				table.insert(self._prev_menu_index_list, self._current_menu_index or 1)

				self._current_menu_data = next_menu_data
				self._current_menu_index = nil

				self:setup_menu()
			end

			if next_menu_data.callback_func then
				next_menu_data:callback_func()
			end
		end
	end
end

function MenuDebug:cancel_button_pressed()
	if self._prev_menu_data_list then
		local prev_menu_data = self._prev_menu_data_list[#self._prev_menu_data_list]

		table.remove(self._prev_menu_data_list, #self._prev_menu_data_list)

		local prev_menu_index = self._prev_menu_index_list[#self._prev_menu_index_list]

		table.remove(self._prev_menu_index_list, #self._prev_menu_index_list)

		if not next(self._prev_menu_data_list) then
			self._prev_menu_data_list = nil
			self._prev_menu_index_list = nil
		end

		self._current_menu_data = prev_menu_data
		self._current_menu_index = prev_menu_index

		self:setup_menu()
	else
		self:set_visible(false)
	end
end

function MenuDebug:left_button_pressed()
	if self._current_menu_data then
		local menu_data = self._current_menu_data[self._current_menu_index or 1]

		if menu_data then
			local callback_func = menu_data.left_callback_func

			if callback_func then
				callback_func(self._current_menu_data)
			end
		end
	end
end

function MenuDebug:right_button_pressed()
	if self._current_menu_data then
		local menu_data = self._current_menu_data[self._current_menu_index or 1]

		if menu_data then
			local callback_func = menu_data.right_callback_func

			if callback_func then
				callback_func(self._current_menu_data)
			end
		end
	end
end

function MenuDebug:setup_menu()
	if not self._resolution_changed_callback_id then
		self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "setup_menu"))
	end

	if not alive(self._workspace) then
		self._workspace = managers.gui_data:create_fullscreen_workspace()
		self._panel = self._workspace:panel()
	else
		self._panel:clear()
	end

	if self._visible then
		self._workspace:show()
	else
		self._workspace:hide()
	end

	self._option_panel = self._panel:panel()
	self._current_menu_data = self._current_menu_data or self._menu_data
	self._background_rect = nil

	if self._current_menu_data then
		local bg_color = self._current_menu_data.bg_color or self._menu_data.bg_color

		if bg_color then
			self._background_rect = self._panel:rect({
				color = bg_color
			})
		end

		local option_config = {
			layer = 1
		}
		local t = TimerManager:main():time()
		local dt = TimerManager:main():delta_time()

		for index, option_data in ipairs(self._current_menu_data) do
			option_config.font = option_data.font or self._menu_data.font or "core/fonts/diesel"
			option_config.text = option_data.text_func and option_data.text_func(t, dt, option_data) or option_data.text or tostring(index)

			if index == (self._current_menu_index or 1) then
				option_config.color = option_data.select_color or self._menu_data.select_color or Color.green
			else
				option_config.color = option_data.color or self._menu_data.color or Color.red
			end

			if not self._preloaded_font_list or not self._preloaded_font_list[option_config.font] then
				managers.gui_data:get_scene_gui():preload_font(option_config.font)

				self._preloaded_font_list = self._preloaded_font_list or {}
				self._preloaded_font_list[option_config.font] = true
			end

			self._option_panel:text(option_config)
		end

		self:setup_menu_shape()
	end
end

function MenuDebug:setup_menu_shape()
	local res = RenderSettings.resolution
	local option_spacing = self._current_menu_data.option_spacing or 5
	local option_w = 0
	local option_h = 0
	local select_y = 0

	self._panel:set_shape(0, 0, res.x, res.y)

	if self._background_rect then
		self._background_rect:set_shape(0, 0, res.x, res.y)
	end

	for index, option in ipairs(self._option_panel:children()) do
		local option_data = self._current_menu_data[index]

		option:set_font_size(option_data.font_size or self._menu_data.font_size or 20)

		local x, y, w, h = option:text_rect()

		if option_w < w then
			option_w = w
		end

		if index == (self._current_menu_index or 0) then
			select_y = option_h + h / 2
		end

		option:set_shape(0, option_h, w, h)

		option_h = option_h + h + option_spacing
	end

	if option_h > 0 then
		option_h = option_h - option_spacing
	end

	local panel_y = (res.y - option_h) / 2
	local safe_rect = managers.viewport:get_safe_rect_pixels()
	local fade_dist = 200

	if safe_rect.height < option_h then
		panel_y = panel_y - select_y + option_h / 2

		for _, option in ipairs(self._option_panel:children()) do
			local center_dist = math.abs(panel_y + option:y() - safe_rect.y - safe_rect.height / 2)
			local edge_dist = safe_rect.height / 2 - center_dist
			local fade = nil

			if fade_dist > 0 then
				fade = math.clamp(edge_dist / fade_dist, 0, 1)
			elseif edge_dist > 0 then
				fade = 1
			else
				fade = 0
			end

			local color = option:color()

			option:set_color(color:with_alpha(color.alpha * fade))
		end
	end

	for _, option in ipairs(self._option_panel:children()) do
		local x, y, w, h = option:text_rect()

		option:set_x((option_w - w) / 2)
	end

	self._option_panel:set_shape((res.x - option_w) / 2, panel_y, option_w, option_h)
end

function MenuDebug:set(menu_data)
	local old_data_controller = self._menu_data and self._menu_data.controller

	if old_data_controller then
		self:set_controller_triggers_enabled(old_data_controller, false)
	end

	self._menu_data = menu_data
	self._current_menu_data = nil
	self._prev_menu_data_list = nil
	self._prev_menu_index_list = nil
	self._current_menu_index = nil

	self:setup_menu()

	local data_controller = self._menu_data and self._menu_data.controller

	if data_controller then
		self:destroy_controller()
		self:set_controller_triggers_enabled(data_controller, self._enabled)
	end
end

function MenuDebug:get_level()
	return self._prev_menu_data_list and #self._prev_menu_data_list or 0
end

function MenuDebug:update(t, dt)
	dt = TimerManager:main():delta_time()
	t = TimerManager:main():time()

	if self._current_menu_data then
		local shape_changed = nil

		for index, option_data in ipairs(self._current_menu_data) do
			local func = option_data.text_func

			if func then
				local option = self._option_panel:child(index - 1)
				local old_text = option:text()
				local new_text = func(t, dt, option_data)
				shape_changed = shape_changed or old_text ~= new_text

				option:set_text(new_text)
			end
		end

		if shape_changed then
			self:setup_menu_shape()
		end
	end
end
