SecurityLockGui = SecurityLockGui or class()

function SecurityLockGui:init(unit)
	self._unit = unit
	self._visible = true
	self._powered = true
	self._gui_start = self._gui_start or "prop_timer_gui_start"
	self._gui_working = "prop_timer_gui_working"
	self._gui_done = "prop_timer_gui_done"
	self._cull_distance = self._cull_distance or 5000
	self._size_multiplier = self._size_multiplier or 1
	self._gui_object = self._gui_object or "gui_name"
	self._bars = self._bars or 3
	self._done_bars = {}
	self._5sec_bars = {}
	self._new_gui = World:newgui()

	self:add_workspace(self._unit:get_object(Idstring(self._gui_object)))
	self:setup()
	self._unit:set_extension_update_enabled(Idstring("timer_gui"), false)

	self._update_enabled = false
end

function SecurityLockGui:add_workspace(gui_object)
	self._ws = self._new_gui:create_object_workspace(0, 0, gui_object, Vector3(0, 0, 0))
	self._gui = self._ws:panel():gui(Idstring("guis/security_lock_gui"))
	self._gui_script = self._gui:script()
end

function SecurityLockGui:setup()
	self._gui_script.working_text:set_render_template(Idstring("VertexColorTextured"))
	self._gui_script.time_header_text:set_render_template(Idstring("VertexColorTextured"))
	self._gui_script.time_text:set_render_template(Idstring("VertexColorTextured"))
	self._gui_script.screen_background:set_size(self._gui_script.screen_background:parent():size())

	local gui_w, gui_h = self._gui_script.screen_background:parent():size()
	local pad = 64
	local bar_pad = 16

	for i = 1, 3 do
		local icon = self._gui_script["timer_icon" .. i]
		local timer_bg = self._gui_script["timer" .. i .. "_background"]
		local timer = self._gui_script["timer" .. i]
		local title = self._gui_script["timer" .. i .. "_title"]
		local visible = i <= self._bars

		icon:set_visible(visible)
		timer_bg:set_visible(visible)
		timer:set_visible(visible)
		title:set_visible(visible)
		title:set_render_template(Idstring("VertexColorTextured"))
		icon:set_size(132, 132)
		icon:set_x(pad)
		icon:set_y(pad + icon:h() * (i - 1) + pad * (i - 1) + 350)

		local w, h = icon:size()

		timer_bg:set_h(h / 2)
		timer:set_h(timer_bg:h() - 8)
		title:set_h(h / 2)
		title:set_text(managers.localization:text("prop_security_lock_title", {
			NR = i
		}))
		title:set_font_size(h / 2 * self._size_multiplier)
		title:set_top(icon:top())
		title:set_left(icon:right() + pad)
		title:set_w(gui_w - (pad * 3 + w))
		timer_bg:set_bottom(icon:bottom())
		timer_bg:set_left(icon:right() + pad / 2)
		timer_bg:set_w(gui_w - (pad * 3 + w))
		timer:set_h(timer_bg:h() - bar_pad)
		timer:set_w(timer_bg:w() - bar_pad)
		timer:set_center(timer_bg:center())

		self._timer_lenght = timer:w()

		timer:set_w(0)
	end

	self._gui_script.working_text:set_center_x(self._gui_script.working_text:parent():w() / 2)
	self._gui_script.working_text:set_center_y(self._gui_script.working_text:parent():h() / 1.25)
	self._gui_script.working_text:set_font_size(80 * self._size_multiplier)
	self._gui_script.working_text:set_text(managers.localization:text(self._gui_start))
	self._gui_script.working_text:set_visible(true)
	self._gui_script.time_header_text:set_font_size(80 * self._size_multiplier)
	self._gui_script.time_header_text:set_visible(false)
	self._gui_script.time_header_text:set_center_x(self._gui_script.working_text:parent():w() / 2)
	self._gui_script.time_header_text:set_center_y(self._gui_script.working_text:parent():h() / 1.25)
	self._gui_script.time_text:set_font_size(110 * self._size_multiplier)
	self._gui_script.time_text:set_visible(false)
	self._gui_script.time_text:set_center_x(self._gui_script.working_text:parent():w() / 2)
	self._gui_script.time_text:set_center_y(self._gui_script.working_text:parent():h() / 1.15)

	self._original_colors = {}

	for _, child in ipairs(self._gui_script.panel:children()) do
		self._original_colors[child:key()] = child:color()
	end
end

function SecurityLockGui:_start(bar, timer, current_timer)
	self._current_bar = bar
	self._started = true
	self._done = false
	self._timer = timer or 5
	self._current_timer = current_timer or self._timer

	self._gui_script["timer_icon" .. self._current_bar]:set_image("units/world/architecture/secret_stash/props_textures/security_station_locked_df")
	self._gui_script["timer" .. self._current_bar]:set_w(self._timer_lenght * (1 - self._current_timer / self._timer))
	self._gui_script.working_text:set_visible(false)
	self._unit:set_extension_update_enabled(Idstring("timer_gui"), true)

	self._update_enabled = true

	self:post_event(self._start_event)
	self._gui_script.time_header_text:set_visible(true)
	self._gui_script.time_text:set_visible(true)
	self._gui_script.time_text:set_text(math.floor(self._current_timer) .. " " .. managers.localization:text("prop_timer_gui_seconds"))

	if Network:is_client() then
		return
	end
end

function SecurityLockGui:restart(bar, timer)
	self:start(bar, timer, true)
end

function SecurityLockGui:start(bar, timer, restart)
	if not restart and self._started then
		return
	end

	self:_start(bar, timer)

	if managers.network:session() then
		-- Nothing
	end
end

function SecurityLockGui:sync_start(bar, timer)
	self:_start(bar, timer)
end

function SecurityLockGui:update(unit, t, dt)
	if not self._powered then
		return
	end

	self._current_timer = self._current_timer - dt

	if not self._5sec_bars[self._current_bar] and self._current_timer < 5 then
		self._5sec_bars[self._current_bar] = true

		if self._unit:damage() then
			self._unit:damage():run_sequence_simple("5sec_" .. self._current_bar)
		end
	end

	self._gui_script.time_text:set_text(math.floor(self._current_timer) .. " " .. managers.localization:text("prop_timer_gui_seconds"))
	self._gui_script["timer" .. self._current_bar]:set_w(self._timer_lenght * (1 - self._current_timer / self._timer))

	if self._current_timer <= 0 then
		self._unit:set_extension_update_enabled(Idstring("timer_gui"), false)

		self._update_enabled = false

		self:done()
	else
		self._gui_script.working_text:set_color(self._gui_script.working_text:color():with_alpha(0.5 + (math.sin(t * 750) + 1) / 4))
	end
end

function SecurityLockGui:set_visible(visible)
	self._visible = visible

	self._gui:set_visible(visible)
end

function SecurityLockGui:set_powered(powered)
	self:_set_powered(powered)
end

function SecurityLockGui:_set_powered(powered)
	self._powered = powered

	if not self._powered then
		for _, child in ipairs(self._gui_script.panel:children()) do
			local color = self._original_colors[child:key()]
			local c = Color(0, 0, 0, 0)

			child:set_color(c)
		end
	else
		for _, child in ipairs(self._gui_script.panel:children()) do
			child:set_color(self._original_colors[child:key()])
		end
	end
end

function SecurityLockGui:done()
	self:_set_done()

	if self._unit:damage() then
		self._unit:damage():run_sequence_simple("done_" .. self._current_bar)
	end

	self:post_event(self._done_event)
end

function SecurityLockGui:_set_done(bar)
	bar = bar or self._current_bar
	self._done_bars[bar] = true
	self._done = true

	self._gui_script["timer_icon" .. bar]:set_image("units/world/architecture/secret_stash/props_textures/security_station_unlocked_df")
	self._gui_script["timer" .. bar]:set_w(self._timer_lenght)
	self._gui_script.working_text:set_color(self._gui_script.working_text:color():with_alpha(1))
	self._gui_script.working_text:set_visible(true)

	if self._bars == bar then
		self._gui_script.working_text:set_text(managers.localization:text(self._gui_done))
	else
		self._started = false
	end

	self._gui_script.time_header_text:set_visible(false)
	self._gui_script.time_text:set_visible(false)
end

function SecurityLockGui:post_event(event)
	if not event then
		return
	end

	self._unit:sound_source():post_event(event)
end

function SecurityLockGui:lock_gui()
	self._ws:set_cull_distance(self._cull_distance)
	self._ws:set_frozen(true)
end

function SecurityLockGui:destroy()
	if alive(self._new_gui) and alive(self._ws) then
		self._new_gui:destroy_workspace(self._ws)

		self._ws = nil
		self._new_gui = nil
	end
end

function SecurityLockGui:save(data)
	local state = {
		update_enabled = self._update_enabled,
		timer = self._timer,
		current_bar = self._current_bar,
		current_timer = self._current_timer,
		powered = self._powered,
		done = self._done,
		done_bars = self._done_bars,
		visible = self._visible
	}
	data.SecurityLockGui = state
end

function SecurityLockGui:load(data)
	local state = data.SecurityLockGui

	for bar, _ in pairs(state.done_bars) do
		self:_set_done(bar)
	end

	if state.update_enabled then
		self:_start(state.current_bar, state.timer, state.current_timer)
	end

	if not state.powered then
		self:_set_powered(state.powered)
	end

	self:set_visible(state.visible)
end
