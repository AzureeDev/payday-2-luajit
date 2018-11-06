core:module("CorePrefHud")

PrefHud = PrefHud or class()
PrefHud.CONFIG_FILE_PATH = "core/settings/prefhud"
PrefHud.CONFIG_FILE_EXTENSION = "prefhud"

function PrefHud:init()
	self._const = {
		_bar_y = 14,
		_bar_space = 5,
		_bar_bg_x = 400,
		_bar_bg_y = 200
	}
	self._const._bar_x = self._const._bar_bg_x - self._const._bar_space * 2
	self._upd_interval = 0.1

	self:load_config()
	self:build_gui()
	self:hide()
end

function PrefHud:remove_counter(name)
	self._counters[name] = nil
end

function PrefHud:remove_all_counters()
	self._counters = {}
end

function PrefHud:add_counter(name, sort, min, mid, max, precision, inv, inv_colors, call_str)
	self._counters[name] = {
		_current_value = 0,
		_raw_value = 0,
		_sort = sort or table.size(self._counters) + 1,
		_min = min or 0,
		_mid = mid or 0.5,
		_max = max or 1,
		_inv = inv,
		_inv_colors = inv_colors,
		_precision = precision or 0,
		_call = call_str,
		_func = loadstring("return " .. call_str)
	}
end

function PrefHud:load_config()
	assert(DB:has(self.CONFIG_FILE_EXTENSION, self.CONFIG_FILE_PATH), "[CorePrefHud] Can't open \"" .. tostring(self.CONFIG_FILE_PATH) .. "." .. tostring(self.CONFIG_FILE_EXTENSION) .. "\".")

	local data = PackageManager:script_data(Idstring(self.CONFIG_FILE_EXTENSION), Idstring(self.CONFIG_FILE_PATH))
	self._counters = {}

	for _, sub_data in ipairs(data) do
		if sub_data._meta == "counter" then
			self:add_counter(sub_data.name, tonumber(sub_data.sort), tonumber(sub_data.min), tonumber(sub_data.mid), tonumber(sub_data.max), sub_data.precision, sub_data.inv == "true", sub_data.inv_colors == "true", sub_data.call)
		end
	end
end

function PrefHud:build_gui()
	if self._workspace then
		Overlay:newgui():destroy_workspace(self._workspace)
	end

	local res = RenderSettings.resolution
	local safe_rect = 0.05

	if SystemInfo:platform() == Idstring("WIN32") then
		safe_rect = 0
	end

	self._workspace = Overlay:newgui():create_sub_screen_workspace(1000, 1000, res.x * safe_rect, res.y * safe_rect)
	self._gui = self._workspace:panel():gui(Idstring("core/guis/core_prefhud"))
	self._panel = self._gui:panel()
	local c = self._const

	self._gui:child("bar_bg"):set_shape(0, 0, c._bar_bg_x, table.size(self._counters) * (c._bar_y + c._bar_space) + c._bar_space * 2)
	self._panel:set_size(c._bar_bg_x, table.size(self._counters) * (c._bar_y + c._bar_space) + c._bar_space * 2)

	local i = 0
	local s, v, k = nil

	while i < table.size(self._counters) do
		for it_k, it_v in pairs(self._counters) do
			if not it_v._obj and it_v._sort <= (s or it_v._sort) then
				s = it_v._sort
				v = it_v
				k = it_k
			end
		end

		s = nil
		v._obj = self._panel:rect()

		v._obj:set_layer(1)
		v._obj:set_color(Color(0, 1, 0))
		v._obj:set_shape(c._bar_space, c._bar_space + i * (c._bar_y + c._bar_space), c._bar_x, c._bar_y)

		v._text_obj = self._panel:text()

		v._text_obj:set_layer(2)
		v._text_obj:set_position(c._bar_space, c._bar_space + i * (c._bar_y + c._bar_space))
		v._text_obj:set_text(k .. ": " .. tostring(string.format("%." .. v._precision .. "f", v._raw_value)))
		v._text_obj:set_color(Color(0, 0, 0))
		v._text_obj:set_font(Idstring("core/fonts/system_font"))
		v._text_obj:set_font_size(c._bar_y)

		i = i + 1
	end
end

function PrefHud:show()
	self._workspace:show()

	self._visible = true
end

function PrefHud:hide()
	self._workspace:hide()

	self._visible = false
end

function PrefHud:toggle()
	if self._visible then
		self:hide()
	else
		self:show()
	end
end

function PrefHud:update_bars(t, dt)
	if self._upd_interval <= (self._prev_upd or self._upd_interval) then
		self._prev_upd = 0

		for k, v in pairs(self._counters) do
			local raw_value = v._func()

			if raw_value == nil then
				raw_value = 0
			end

			v._raw_value = raw_value
			local value = math.clamp(raw_value, 0, v._max)
			v._current_value = value

			if v._inv then
				value = v._max - value
			end

			if v._max <= value then
				if v._inv_colors then
					v._obj:set_color(Color(0.8, 0, 0))
				else
					v._obj:set_color(Color(0, 0.8, 0))
				end
			elseif v._mid <= value and value <= v._max then
				local t = (value - v._mid) / (v._max - v._mid)

				if v._inv_colors then
					v._obj:set_color(math.lerp(Color(0.8, 0.8, 0), Color(0.8, 0, 0), t))
				else
					v._obj:set_color(math.lerp(Color(0.8, 0.8, 0), Color(0, 0.8, 0), t))
				end
			elseif v._min <= value and value <= v._mid then
				local t = (value - v._min) / (v._mid - v._min)

				if v._inv_colors then
					v._obj:set_color(math.lerp(Color(0, 0.8, 0), Color(0.8, 0.8, 0), t))
				else
					v._obj:set_color(math.lerp(Color(0.8, 0, 0), Color(0.8, 0.8, 0), t))
				end
			elseif v._inv_colors then
				v._obj:set_color(Color(0, 0.8, 0))
			else
				v._obj:set_color(Color(0.8, 0, 0))
			end

			local proc = value / v._max

			v._obj:set_width(self._const._bar_x * proc)
			v._text_obj:set_text(k .. ": " .. tostring(string.format("%." .. v._precision .. "f", v._raw_value)))
		end
	else
		self._prev_upd = self._prev_upd + dt
	end
end

local ids_win32 = Idstring("WIN32")
local ids_left_ctrl = Idstring("left ctrl")
local ids_f1 = Idstring("f1")
local is_win32 = SystemInfo:platform() == ids_win32

function PrefHud:update_keys()
end

function PrefHud:update(t, dt)
	if self._visible then
		self:update_bars(t, dt)
	end

	self:update_keys()
end

function PrefHud:paused_update(t, dt)
	self:update(t, dt)
end

function PrefHud:destroy()
	if alive(self._workspace) then
		Overlay:newgui():destroy_workspace(self._workspace)
	end
end
