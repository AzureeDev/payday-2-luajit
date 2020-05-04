DigitalGui = DigitalGui or class()
DigitalGui.COLORS = {
	black = Color(0, 0, 0),
	white = Color(1, 1, 1),
	red = Color(0.8, 0, 0),
	green = Color(0, 0.8, 0),
	blue = Color(0, 0, 0.8),
	yellow = Color(0.8, 0.8, 0),
	orange = Color(0.8, 0.4, 0),
	light_red = Color(0.8, 0.4, 0.4),
	light_blue = Color(0.4, 0.6, 0.8),
	light_green = Color(0.6, 0.8, 0.4),
	light_yellow = Color(0.8, 0.8, 0.4),
	light_orange = Color(0.8, 0.6, 0.4)
}
DigitalGui.GUI_EVENT_IDS = {
	syncronize = 1,
	timer_set = 2,
	timer_start_count_up = 3,
	timer_start_count_down = 4,
	timer_pause = 5,
	timer_resume = 6,
	number_set = 7
}
DigitalGui.NUMBER_CLAMP = 99999

function DigitalGui:init(unit)
	self._unit = unit
	self._visible = true
	self.WIDTH = self.WIDTH or 640
	self.HEIGHT = self.HEIGHT or 360
	self.TYPE = self.TYPE or "timer"
	self.NUMBER_DIGITS = self.NUMBER_DIGITS or 3
	self.TIMER_PRECISION = self.TIMER_PRECISION or 0
	self.FONT = self.FONT or "fonts/font_digital"
	self.FONT_SIZE = self.FONT_SIZE or 180
	self.COLOR_TYPE = self.COLOR_TYPE or "light_yellow"
	self.BG_COLOR_TYPE = self.BG_COLOR_TYPE or nil
	self.DIGIT_COLOR = DigitalGui.COLORS[self.COLOR_TYPE]

	if self.BG_COLOR_TYPE then
		self.BG_COLOR = DigitalGui.COLORS[self.BG_COLOR_TYPE]
	end

	self.display_format = self.display_format or "{minutes}:{seconds}"
	self._number = self._number or 0
	self._timer = self._timer or 0
	self._floored_last_timer = self._timer + 1
	self._next_timer_sync = Application:time() + 9
	self._gui_object = self._gui_object or "gui_object"
	self._new_gui = World:gui()

	self:add_workspace(self._unit:get_object(Idstring(self._gui_object)))
	self:setup()
	self._unit:set_extension_update_enabled(Idstring("digital_gui"), false)
end

function DigitalGui:add_workspace(gui_object)
	self._ws = self._new_gui:create_object_workspace(self.WIDTH, self.HEIGHT, gui_object, Vector3(0, 0, 0))
	self._panel = self._ws:panel()
end

function DigitalGui:setup()
	self._panel:clear()

	if self.BG_COLOR then
		self._bg_rect = self._panel:rect({
			layer = -1,
			color = self.BG_COLOR
		})
	end

	local font_size = self.FONT_SIZE
	self._title_text = self._panel:text({
		y = 0,
		vertical = "center",
		align = "center",
		text = "01:23",
		visible = true,
		layer = 0,
		font = self.FONT,
		font_size = font_size,
		color = self.DIGIT_COLOR
	})

	if self.RENDER_TEMPLATE then
		self._title_text:set_render_template(Idstring(self.RENDER_TEMPLATE))
	end

	if self.BLEND_MODE then
		self._title_text:set_blend_mode(self.BLEND_MODE)
	end

	if self.TYPE == "timer" then
		self:_update_timer_text()
	else
		self:_update_number_text()
	end
end

function DigitalGui:is_timer()
	return self.TYPE == "timer"
end

function DigitalGui:is_number()
	return self.TYPE == "number"
end

function DigitalGui:is_precision_timer()
	return self:is_timer() and self:timer_precision() > 0
end

function DigitalGui:timer_precision()
	return self.TIMER_PRECISION
end

function DigitalGui:update(unit, t, dt)
	if self.TYPE == "timer" and not self._timer_paused then
		if self._timer_count_up then
			self._timer = self._timer + dt
		elseif self._timer_count_down then
			self._timer = self._timer - dt
		end

		if Network:is_server() and self._next_timer_sync < Application:time() then
			self._next_timer_sync = Application:time() + 7 + math.rand(2)

			for peer_id, peer in pairs(managers.network:session():peers()) do
				local sync_time = math.clamp(self._timer + Network:qos(peer:rpc()).ping / 1000, 0, 100000)

				peer:send_queued_sync("sync_gui_net_event", self._unit, DigitalGui.GUI_EVENT_IDS.syncronize, sync_time)
			end
		end

		self:_update_timer_text()
	end
end

function DigitalGui:set_color_type(type)
	self.COLOR_TYPE = type
	self.DIGIT_COLOR = DigitalGui.COLORS[self.COLOR_TYPE]

	self._title_text:set_color(self.DIGIT_COLOR)
end

function DigitalGui:set_bg_color_type(type)
	self.BG_COLOR_TYPE = type
	self.BG_COLOR = self.BG_COLOR_TYPE and DigitalGui.COLORS[self.BG_COLOR_TYPE] or nil

	if self.BG_COLOR then
		self._bg_rect = self._bg_rect or self._panel:rect({
			layer = -1,
			color = self.BG_COLOR
		})

		self._bg_rect:set_color(self.BG_COLOR)
	elseif alive(self._bg_rect) then
		self._bg_rect:parent():remove(self._bg_rect)

		self._bg_rect = nil
	end
end

function DigitalGui:_set_number(new)
	self._number = math.clamp(new, 0, DigitalGui.NUMBER_CLAMP)
end

function DigitalGui:number_set(number, sync)
	self:_set_number(number)
	self:_update_number_text()

	if sync and Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_gui_net_event", self._unit, DigitalGui.GUI_EVENT_IDS.number_set, self._number)
	end
end

function DigitalGui:number_increase()
	self:_set_number(self._number + 1)
	self:_update_number_text()
end

function DigitalGui:number_decrease()
	self:_set_number(self._number - 1)
	self:_update_number_text()
end

function DigitalGui:_update_number_text()
	if self._number then
		self:_set_number(self._number < 0 and 0 or self._number)

		local zero = ""

		for i = 1, self.NUMBER_DIGITS - 1 do
			zero = zero .. (self._number < math.pow(10, i) and "0" or "")
		end

		self._title_text:set_text(zero .. self._number)
	elseif self._number == false then
		self._title_text:set_text("---")
	end
end

function DigitalGui:timer_start_count_up(sync)
	self._unit:set_extension_update_enabled(Idstring("digital_gui"), true)

	self._timer_paused = false
	self._timer_count_up = true
	self._timer_count_down = false

	if sync and Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_gui_net_event", self._unit, DigitalGui.GUI_EVENT_IDS.timer_start_count_up, 0)
	end
end

function DigitalGui:timer_start_count_down(sync)
	self._unit:set_extension_update_enabled(Idstring("digital_gui"), true)

	self._timer_paused = false
	self._timer_count_up = false
	self._timer_count_down = true

	if sync and Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_gui_net_event", self._unit, DigitalGui.GUI_EVENT_IDS.timer_start_count_down, 0)
	end
end

function DigitalGui:timer_pause(sync)
	self._unit:set_extension_update_enabled(Idstring("digital_gui"), false)

	self._timer_paused = true

	if sync and Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_gui_net_event", self._unit, DigitalGui.GUI_EVENT_IDS.timer_pause, 0)
	end
end

function DigitalGui:timer_resume(sync)
	self._unit:set_extension_update_enabled(Idstring("digital_gui"), true)

	self._timer_paused = false

	if sync and Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_gui_net_event", self._unit, DigitalGui.GUI_EVENT_IDS.timer_resume, 0)
	end
end

function DigitalGui:timer_set(timer, sync)
	self._timer = timer

	self:_update_timer_text()

	if sync and Network:is_server() then
		local sync_time = math.clamp(self._timer, 0, 100000)

		managers.network:session():send_to_peers_synched("sync_gui_net_event", self._unit, DigitalGui.GUI_EVENT_IDS.timer_set, sync_time)
	end
end

function DigitalGui:_timer_stop()
	self._unit:set_extension_update_enabled(Idstring("digital_gui"), false)

	self._timer_count_up = false
	self._timer_count_down = false
end

function DigitalGui:_sequence_trigger(sequence_name)
	if not Network:is_server() then
		return
	end

	if self._unit:damage():has_sequence(sequence_name) then
		self._unit:damage():run_sequence_simple(sequence_name)
	end
end

function DigitalGui:_round(num, idp)
	local mult = 10^(idp or 0)

	return math.floor(num * mult + 0.5) / mult
end

function DigitalGui:_update_timer_text()
	if self:timer_precision() <= 0 and math.floor(self._timer) == self._floored_last_timer then
		return
	end

	if self._timer_count_down and self._timer <= 0 then
		self:_sequence_trigger("timer_reach_zero")
		self:_timer_stop()
	end

	self._floored_last_timer = math.floor(self._timer)
	self._timer = self._timer < 0 and 0 or self._timer
	local precision = self:timer_precision()
	local is_precision = precision > 0
	local time = math.floor(self._timer)
	local minutes = math.floor(time / 60)
	time = time - minutes * 60
	local seconds = math.round(time)
	local milliseconds = 0

	if is_precision then
		seconds = math.floor(time)
		local ms_time = self._timer - math.floor(self._timer)
		local idp = 10^precision
		milliseconds = math.floor(self:_round(ms_time, (precision or 1) + 1) * idp)
		milliseconds = milliseconds % idp
	end

	local minutes_str = minutes < 10 and string.format("0%i", minutes) or tostring(minutes)
	local seconds_str = seconds < 10 and string.format("0%i", seconds) or tostring(seconds)
	local text = self.display_format
	text = string.gsub(text, "{minutes}", minutes_str)
	text = string.gsub(text, "{seconds}", seconds_str)

	if is_precision then
		local format_str = "%0" .. precision .. "i"
		local ms_str = string.format(format_str, milliseconds)
		text = string.gsub(text, "{milliseconds}", ms_str)
	end

	self._title_text:set_text(text)
end

function DigitalGui:set_visible(visible)
	self._visible = visible

	if visible then
		self._ws:show()
	else
		self._ws:hide()
	end
end

function DigitalGui:lock_gui()
	self._ws:set_cull_distance(self._cull_distance)
	self._ws:set_frozen(true)
end

function DigitalGui:sync_gui_net_event(event_id, value)
	if event_id == DigitalGui.GUI_EVENT_IDS.syncronize then
		self:timer_set(value)
	elseif event_id == DigitalGui.GUI_EVENT_IDS.timer_set then
		self:timer_set(value)
	elseif event_id == DigitalGui.GUI_EVENT_IDS.timer_start_count_up then
		self:timer_start_count_up()
	elseif event_id == DigitalGui.GUI_EVENT_IDS.timer_start_count_down then
		self:timer_start_count_down()
	elseif event_id == DigitalGui.GUI_EVENT_IDS.timer_pause then
		self:timer_pause()
	elseif event_id == DigitalGui.GUI_EVENT_IDS.timer_resume then
		self:timer_resume()
	elseif event_id == DigitalGui.GUI_EVENT_IDS.number_set then
		self:number_set(value)
	end
end

function DigitalGui:destroy()
	if alive(self._new_gui) and alive(self._ws) then
		self._new_gui:destroy_workspace(self._ws)

		self._ws = nil
		self._new_gui = nil
	end
end

function DigitalGui:save(data)
	local state = {
		timer_paused = self._timer_paused,
		timer = self._timer,
		number = self._number,
		timer_count_up = self._timer_count_up,
		timer_count_down = self._timer_count_down,
		COLOR_TYPE = self.COLOR_TYPE,
		BG_COLOR_TYPE = self.BG_COLOR_TYPE,
		visible = self._visible
	}
	data.DigitalGui = state
end

function DigitalGui:load(data)
	local state = data.DigitalGui
	self._timer_paused = state.timer_paused
	self._timer = state.timer
	self._number = state.number
	self._timer_count_up = state.timer_count_up
	self._timer_count_down = state.timer_count_down

	if self.TYPE == "timer" then
		self:_update_timer_text()
	elseif self.TYPE == "number" then
		self:_update_number_text()
	end

	if not self._timer_paused and (self._timer_count_up or self._timer_count_down) then
		self._unit:set_extension_update_enabled(Idstring("digital_gui"), true)
	end

	self:set_color_type(state.COLOR_TYPE)
	self:set_bg_color_type(state.BG_COLOR_TYPE)

	if state.visible ~= self._visible then
		self:set_visible(state.visible)
	end
end
