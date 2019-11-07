TimerGui = TimerGui or class()
TimerGui.themes = {
	default = {}
}
TimerGui.themes.default.hide_background = false
TimerGui.themes.default.timer_color = tweak_data.hud.prime_color
TimerGui.themes.default.working_text_color = TimerGui.themes.default.timer_color
TimerGui.themes.default.time_header_text_color = TimerGui.themes.default.timer_color
TimerGui.themes.default.time_text_color = TimerGui.themes.default.timer_color
TimerGui.themes.old = {
	hide_background = true,
	timer_color = Color(0.3, 0.5, 0.3),
	timer_background_color = Color(0.2, 0.1, 0.2, 0.1)
}
TimerGui.themes.old.working_text_color = TimerGui.themes.old.timer_color
TimerGui.themes.old.time_header_text_color = TimerGui.themes.old.timer_color
TimerGui.themes.old.time_text_color = TimerGui.themes.old.timer_color
TimerGui.themes.old.bg_rect_color = Color.black
TimerGui.themes.old.bg_rect_blend_mode = "mul"
TimerGui.themes.old.jammed = {
	bg_rect = Color(0.1, 0, 0),
	bg_rect_blend_mode = "mul"
}
TimerGui.themes.old.upgrade_color_0 = Color(0, 0, 0)
TimerGui.themes.old.upgrade_color_1 = Color(0.3, 0.6, 0.3)
TimerGui.themes.old.upgrade_color_2 = Color(0.8, 1, 0.8)
TimerGui.themes.blue = {
	hide_background = true,
	timer_color = Color(0.4, 0.6, 0.8)
}
TimerGui.themes.blue.working_text_color = TimerGui.themes.blue.timer_color
TimerGui.themes.blue.time_header_text_color = TimerGui.themes.blue.timer_color
TimerGui.themes.blue.time_text_color = TimerGui.themes.blue.timer_color
TimerGui.themes.blue.bg_rect_color = Color(0.4, 0, 0, 0)
TimerGui.themes.blue.jammed = {
	bg_rect = Color(0.1, 0, 0)
}
TimerGui.themes.blue.upgrade_color_0 = Color(0, 0, 0)
TimerGui.themes.blue.upgrade_color_1 = Color(0.2, 0.3, 0.4)
TimerGui.themes.blue.upgrade_color_2 = TimerGui.themes.blue.timer_color
TimerGui.themes.custom_background = {
	hide_background = true,
	timer_color = Color(0.8, 0.8, 0.8)
}
TimerGui.themes.custom_background.working_text_color = TimerGui.themes.custom_background.timer_color
TimerGui.themes.custom_background.time_header_text_color = TimerGui.themes.custom_background.timer_color
TimerGui.themes.custom_background.time_text_color = TimerGui.themes.custom_background.timer_color
TimerGui.themes.custom_background.bg_rect_color = Color(0, 0, 0, 0)
TimerGui.themes.custom_background.jammed = {
	bg_rect = Color(0.1, 0, 0)
}
TimerGui.themes.custom_background.upgrade_color_0 = Color(0, 0, 0)
TimerGui.themes.custom_background.upgrade_color_1 = Color(0.2, 0.3, 0.4)
TimerGui.themes.custom_background.upgrade_color_2 = TimerGui.themes.custom_background.timer_color
TimerGui.themes.bry_control_display = {
	hide_background = true,
	timer_color = Color(1, 0.956, 0.494)
}
TimerGui.themes.bry_control_display.working_text_color = TimerGui.themes.bry_control_display.timer_color
TimerGui.themes.bry_control_display.time_header_text_color = TimerGui.themes.bry_control_display.timer_color
TimerGui.themes.bry_control_display.time_text_color = TimerGui.themes.bry_control_display.timer_color
TimerGui.themes.bry_control_display.jammed = {
	bg_rect = Color(0.1, 0, 0)
}
TimerGui.themes.bry_control_display.upgrade_color_0 = Color(0, 0, 0)
TimerGui.themes.bry_control_display.upgrade_color_1 = Color(0.2, 0.3, 0.4)
TimerGui.themes.bry_control_display.upgrade_color_2 = TimerGui.themes.bry_control_display.timer_color
TimerGui.themes.vit_control_display = {
	hide_background = true,
	timer_color = Color(0, 1, 0.7)
}
TimerGui.themes.vit_control_display.working_text_color = TimerGui.themes.vit_control_display.timer_color
TimerGui.themes.vit_control_display.time_header_text_color = TimerGui.themes.vit_control_display.timer_color
TimerGui.themes.vit_control_display.time_text_color = TimerGui.themes.vit_control_display.timer_color
TimerGui.themes.vit_control_display.jammed = {
	bg_rect = Color(0.1, 0, 0)
}
TimerGui.themes.vit_control_display.upgrade_color_0 = Color(0, 0, 0)
TimerGui.themes.vit_control_display.upgrade_color_1 = Color(0.2, 0.3, 0.4)
TimerGui.themes.vit_control_display.upgrade_color_2 = TimerGui.themes.vit_control_display.timer_color
TimerGui.themes.mex_hack_display = {
	hide_background = true,
	timer_color = Color(0.9, 0.9, 0.9)
}
TimerGui.themes.mex_hack_display.working_text_color = TimerGui.themes.mex_hack_display.timer_color
TimerGui.themes.mex_hack_display.time_header_text_color = TimerGui.themes.mex_hack_display.timer_color
TimerGui.themes.mex_hack_display.time_header_text_font_size = 0
TimerGui.themes.mex_hack_display.time_text_color = TimerGui.themes.mex_hack_display.timer_color
TimerGui.themes.mex_hack_display.time_text_font_size = 100
TimerGui.themes.mex_hack_display.jammed = {
	bg_rect = Color(0.1, 0, 0)
}
TimerGui.themes.mex_hack_display.upgrade_color_0 = Color(0, 0, 0)
TimerGui.themes.mex_hack_display.upgrade_color_1 = Color(0.2, 0.3, 0.4)
TimerGui.themes.mex_hack_display.upgrade_color_2 = TimerGui.themes.mex_hack_display.timer_color
TimerGui.themes.mex_hack_display.working_text_font_size = 0
TimerGui.themes.mex_hack_display.timer_lenght = 0
TimerGui.themes.lxy_control_display = {
	hide_background = true,
	jammed = {}
}
TimerGui.themes.lxy_control_display.jammed.bg_rect = Color(0.1, 0, 0, 0)
TimerGui.themes.lxy_control_display.upgrade_color_0 = Color(0, 0, 0)
TimerGui.themes.lxy_control_display.upgrade_color_1 = Color(0.2, 0.3, 0.4)
TimerGui.themes.lxy_control_display.upgrade_color_2 = TimerGui.themes.lxy_control_display.timer_color
TimerGui.themes.lxy_control_display.timer_color = Color(0.5, 1, 0.3, 0.3)
TimerGui.themes.lxy_control_display.working_text_font = Idstring("fonts/font_eurostile_ext")
TimerGui.themes.lxy_control_display.working_text_font_size = 120
TimerGui.themes.lxy_control_display.working_text_color = Color(0.75, 1, 0.3, 0.3)
TimerGui.themes.lxy_control_display.time_header_text_font = Idstring("fonts/font_eurostile_ext")
TimerGui.themes.lxy_control_display.time_header_text_font_size = 50
TimerGui.themes.lxy_control_display.time_header_text_color = Color(0.75, 1, 0.3, 0.3)
TimerGui.themes.lxy_control_display.time_text_font = Idstring("fonts/font_eurostile_ext")
TimerGui.themes.lxy_control_display.time_text_font_size = 90
TimerGui.themes.lxy_control_display.time_text_color = Color(0.75, 1, 0.3, 0.3)
TimerGui.upgrade_colors = {
	upgrade_color_0 = tweak_data.screen_colors.item_stage_3,
	upgrade_color_1 = tweak_data.screen_colors.text,
	upgrade_color_2 = tweak_data.hud.prime_color
}
TimerGui.EVENT_IDS = {
	jammed = 1,
	unjammed = 2
}

function TimerGui:init(unit)
	self._unit = unit
	self._visible = true
	self._powered = true
	self._jam_times = 3
	self._jammed = false
	self._can_jam = false
	self._show_seconds = true
	self._gui_start = self._gui_start or "prop_timer_gui_start"
	self._gui_working = "prop_timer_gui_working"
	self._gui_malfunction = "prop_timer_gui_malfunction"
	self._gui_done = "prop_timer_gui_done"
	self._cull_distance = self._cull_distance or 5000
	self._size_multiplier = self._size_multiplier or 1
	self._gui_object = self._gui_object or "gui_name"
	self._new_gui = World:newgui()

	self:add_workspace(self._unit:get_object(Idstring(self._gui_object)))
	self:setup()
	self._unit:set_extension_update_enabled(Idstring("timer_gui"), false)

	self._update_enabled = false
end

function TimerGui:set_can_jam(can_jam)
	self._can_jam = can_jam
end

function TimerGui:set_jam_times(amount)
	if not self._can_jam then
		Application:error("[Drill]", "This Drill cannot jam, use another one.")

		return
	end

	if amount == 0 then
		Application:error("[Drill]", "jam times cannot be set below 1")

		return
	end

	self._jam_times = amount
end

function TimerGui:set_override_timer(override_timer)
	self._override_timer = override_timer
end

function TimerGui:add_workspace(gui_object)
	self._ws = self._new_gui:create_object_workspace(0, 0, gui_object, Vector3(0, 0, 0))
	self._gui = self._ws:panel():gui(Idstring("guis/timer_gui"))
	self._gui_script = self._gui:script()
end

function TimerGui:get_upgrade_icon_color(upgrade_color)
	if not self.THEME then
		return TimerGui.upgrade_colors[upgrade_color]
	end

	local theme = TimerGui.themes[self.THEME]

	return theme and theme[upgrade_color] or TimerGui.upgrade_colors[upgrade_color]
end

function TimerGui:_set_theme(theme_name)
	local theme = TimerGui.themes[theme_name]

	if not theme then
		return
	end

	self._gui_script.drill_screen_background:set_visible(not theme.hide_background)

	if theme.timer_lenght then
		self._timer_lenght = theme.timer_lenght

		self._gui_script.timer_background:set_w(theme.timer_lenght)
	end

	if theme.timer_color then
		self._gui_script.timer:set_color(theme.timer_color)
	end

	if theme.timer_background_color then
		self._gui_script.timer_background:set_color(theme.timer_background_color)
	end

	if theme.working_text_color then
		self._gui_script.working_text:set_color(theme.working_text_color)
	end

	if theme.working_text_font then
		self._gui_script.working_text:set_font(theme.working_text_font)
	end

	if theme.working_text_font_size then
		print("[TimerGui] theme.working_text_font_size", theme.working_text_font_size)
		self._gui_script.working_text:set_font_size(theme.working_text_font_size)
	end

	if theme.time_header_text_color then
		self._gui_script.time_header_text:set_color(theme.time_header_text_color)
	end

	if theme.time_header_text_font then
		self._gui_script.time_header_text:set_font(theme.time_header_text_font)
	end

	if theme.time_header_text_font_size then
		print("[TimerGui] theme.time_header_text_font_size", theme.time_header_text_font_size)
		self._gui_script.time_header_text:set_font_size(theme.time_header_text_font_size)
	end

	if theme.time_text_color then
		self._gui_script.time_text:set_color(theme.time_text_color)
	end

	if theme.time_text_font then
		self._gui_script.time_text:set_font(theme.time_text_font)
	end

	if theme.time_text_font_size then
		print("[TimerGui] theme.time_header_text_font_size", theme.time_text_font_size)
		self._gui_script.time_text:set_font_size(theme.time_text_font_size)
	end

	self._gui_script.bg_rect:set_visible(theme.bg_rect_color and true or false)

	if theme.bg_rect_color then
		self._gui_script.bg_rect:set_color(theme.bg_rect_color)
	end

	if theme.bg_rect_blend_mode then
		self._gui_script.bg_rect:set_blend_mode(theme.bg_rect_blend_mode)
	end

	if theme.bg_rect_render_template then
		self._gui_script.bg_rect:set_render_template(theme.bg_rect_render_template)
	end

	self:_set_original_colors()
end

function TimerGui:_set_original_colors()
	self._original_colors = {}

	for _, child in ipairs(self._gui_script.panel:children()) do
		self._original_colors[child:key()] = child:color()
	end
end

function TimerGui:setup()
	self._gui_script.working_text:set_render_template(Idstring("Text"))
	self._gui_script.time_header_text:set_render_template(Idstring("Text"))
	self._gui_script.time_text:set_render_template(Idstring("Text"))
	self._gui_script.drill_screen_background:set_size(self._gui_script.drill_screen_background:parent():size())
	self._gui_script.timer:set_h(120 * self._size_multiplier)
	self._gui_script.timer:set_w(self._gui_script.timer:parent():w() - self._gui_script.timer:parent():w() / 5)
	self._gui_script.timer:set_center_x(self._gui_script.timer:parent():w() * 0.5)
	self._gui_script.timer:set_center_y(self._gui_script.timer:parent():h() * 0.5 + 45 * self._size_multiplier)
	self._gui_script.timer:set_y(math.round(self._gui_script.timer:y()))

	self._timer_lenght = self._gui_script.timer:w()

	self._gui_script.timer_background:set_h(self._gui_script.timer:h() + 20 * self._size_multiplier)
	self._gui_script.timer_background:set_w(self._gui_script.timer:w() + 20 * self._size_multiplier)
	self._gui_script.timer_background:set_center(self._gui_script.timer:center())
	self._gui_script.timer:set_w(0)
	self._gui_script.working_text:set_center_x(self._gui_script.working_text:parent():w() / 2)
	self._gui_script.working_text:set_center_y(self._gui_script.working_text:parent():h() / 2.75)
	self._gui_script.working_text:set_font_size(110 * self._size_multiplier)
	self._gui_script.working_text:set_text(managers.localization:text(self._gui_start))
	self._gui_script.working_text:set_visible(true)
	self._gui_script.time_header_text:set_font_size(80 * self._size_multiplier)
	self._gui_script.time_header_text:set_visible(false)
	self._gui_script.time_header_text:set_center_x(self._gui_script.working_text:parent():w() / 2)
	self._gui_script.time_header_text:set_center_y(self._gui_script.working_text:parent():h() / 1.325)
	self._gui_script.time_text:set_font_size(110 * self._size_multiplier)
	self._gui_script.time_text:set_visible(false)
	self._gui_script.time_text:set_center_x(self._gui_script.working_text:parent():w() / 2)
	self._gui_script.time_text:set_center_y(self._gui_script.working_text:parent():h() / 1.125)

	if self.THEME then
		self:_set_theme(self.THEME)
	end

	self._original_colors = {}

	self._gui_script.panel:set_alpha(1)

	for _, child in ipairs(self._gui_script.panel:children()) do
		self._original_colors[child:key()] = child:color()
	end

	self._gui_script.panel:set_alpha(1)
end

function TimerGui:reset()
	self._started = false

	if self._unit:interaction() and self._start_tweak_data then
		self._unit:interaction():set_tweak_data(self._start_tweak_data)
		self._unit:interaction():set_active(true)
	end
end

function TimerGui:stop_and_reset()
	self._started = false

	self:_set_done()
	self:post_event(self._done_event)

	if self._unit:interaction() and self._start_tweak_data then
		self._unit:interaction():set_tweak_data(self._start_tweak_data)
		self._unit:interaction():set_active(false)
	end
end

function TimerGui:_start(timer, current_timer)
	self._started = true
	self._done = false
	self._timer = timer or 5
	self._current_timer = current_timer or self._timer
	self._time_left = self._current_timer * math.max(self._timer_multiplier or 1, 0.01)

	self._gui_script.timer:set_w(self._timer_lenght * (1 - self._current_timer / self._timer))
	self._gui_script.working_text:set_text(managers.localization:text(self._gui_working))
	self._unit:set_extension_update_enabled(Idstring("timer_gui"), true)

	self._update_enabled = true

	self:post_event(self._start_event)
	self._gui_script.time_header_text:set_visible(true)
	self._gui_script.time_text:set_visible(true)

	if self._show_seconds then
		self._gui_script.time_text:set_text(math.floor(self._time_left or self._current_timer) .. " " .. managers.localization:text("prop_timer_gui_seconds"))
	else
		self._gui_script.time_text:set_text(math.floor(self._time_left or self._current_timer))
	end

	self._unit:base():start()

	if Network:is_client() then
		return
	end

	self:_set_jamming_values()
end

function TimerGui:_set_jamming_values()
	if not self._can_jam then
		return
	end

	self._jamming_intervals = {}
	local jammed_times = math.random(self._jam_times)
	local interval = self._timer / jammed_times

	for i = 1, jammed_times, 1 do
		local start = interval / 2
		self._jamming_intervals[i] = start + math.rand(start / 1.25)
	end

	self._current_jam_timer = table.remove(self._jamming_intervals, 1)
end

function TimerGui:set_timer_multiplier(multiplier)
	self._timer_multiplier = multiplier
end

function TimerGui:set_skill(skill)
	if self._skill == nil or self._skill < skill then
		self._skill = skill
	end
end

function TimerGui:set_background_icons(background_icons)
	local panel = self._gui_script.panel
	local background_icons_panel = panel:child("background_icons_panel") or panel:panel({
		name = "background_icons_panel"
	})

	background_icons_panel:rect({
		layer = 3,
		color = Color.green
	})

	for _, child in ipairs(background_icons_panel:children()) do
		self._original_colors[child:key()] = nil
	end

	background_icons_panel:clear()

	local alpha = self._gui_script.panel:alpha()

	self._gui_script.panel:set_alpha(1)

	self._original_colors = self._original_colors or {}

	for i, icon_data in ipairs(background_icons) do
		local icon = background_icons_panel:bitmap(icon_data)
		self._original_colors[icon:key()] = icon_data.color or icon:color()
	end

	self._gui_script.panel:set_alpha(alpha)
end

function TimerGui:start(timer)
	timer = self._override_timer or timer

	if not self._started then
		self:_start(timer)

		if managers.network:session() then
			managers.network:session():send_to_peers_synched("start_timer_gui", self._unit, timer)
		end
	end

	if not self._powered then
		self:set_powered(true)
	end

	if self._jammed then
		self:set_jammed(false)
	end
end

function TimerGui:sync_start(timer)
	self:_start(timer)
end

function TimerGui:update(unit, t, dt)
	if self._jammed then
		self._gui_script.drill_screen_background:set_color(self._gui_script.drill_screen_background:color():with_alpha(0.5 + (math.sin(t * 750) + 1) / 4))
		self._gui_script.bg_rect:set_color(self._gui_script.bg_rect:color():with_alpha(0.5 + (math.sin(t * 750) + 1) / 4))

		return
	end

	if not self._powered then
		return
	end

	local dt_mod = math.max(self._timer_multiplier or 1, 0.01)

	if self._current_jam_timer then
		self._current_jam_timer = self._current_jam_timer - dt / dt_mod

		if self._current_jam_timer <= 0 then
			self:set_jammed(true)

			self._current_jam_timer = table.remove(self._jamming_intervals, 1)

			return
		end
	end

	self._current_timer = self._current_timer - dt / dt_mod
	self._time_left = self._current_timer * dt_mod

	if self._show_seconds then
		self._gui_script.time_text:set_text(math.floor(self._time_left or self._current_timer) .. " " .. managers.localization:text("prop_timer_gui_seconds"))
	else
		self._gui_script.time_text:set_text(math.floor(self._time_left or self._current_timer))
	end

	self._gui_script.timer:set_w(self._timer_lenght * (1 - self._current_timer / self._timer))

	if self._current_timer <= 0 then
		self._unit:set_extension_update_enabled(Idstring("timer_gui"), false)

		self._update_enabled = false

		self:done()
	else
		self._gui_script.working_text:set_color(self._gui_script.working_text:color():with_alpha(0.5 + (math.sin(t * 750) + 1) / 4))
	end
end

function TimerGui:set_visible(visible)
	self._visible = visible

	self._gui:set_visible(visible)
end

function TimerGui:is_visible()
	return self._visible
end

function TimerGui:sync_net_event(event_id)
	if event_id == TimerGui.EVENT_IDS.jammed then
		self:_set_jammed(true)
	elseif event_id == TimerGui.EVENT_IDS.unjammed then
		self:_set_jammed(false)
	end
end

function TimerGui:set_jammed(jammed)
	if managers.network:session() then
		local event_id = jammed and TimerGui.EVENT_IDS.jammed or TimerGui.EVENT_IDS.unjammed

		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "timer_gui", event_id)
	end

	self:_set_jammed(jammed)
end

function TimerGui:_set_jammed(jammed)
	self._jammed = jammed

	if self._jammed then
		if self._unit:damage() then
			if self._unit:damage():has_sequence("set_is_jammed") then
				self._unit:damage():run_sequence_simple("set_is_jammed")
			end

			if self._unit:damage():has_sequence("jammed_trigger") then
				self._unit:damage():run_sequence_simple("jammed_trigger")
			end
		end

		for _, child in ipairs(self._gui_script.panel:children()) do
			local theme = TimerGui.themes[self.THEME]

			if child.children then
				for _, grandchild in ipairs(child:children()) do
					local color = self._original_colors[grandchild:key()]
					local c = Color(color.a, 1, 0, 0)

					grandchild:set_color(c)
				end
			else
				local color = self._original_colors[child:key()]
				local jammed_color = theme and theme.jammed and theme.jammed[child:name()] or Color.red
				local c = jammed_color:with_alpha(color.a)

				child:set_color(c)

				local blend_mode = theme and theme.jammed and theme.jammed[child:name() .. "_blend_mode"]

				if blend_mode then
					child:set_blend_mode(blend_mode)
				end
			end
		end

		self._gui_script.working_text:set_text(managers.localization:text(self._gui_malfunction))
		self._gui_script.time_text:set_text(managers.localization:text("prop_timer_gui_error"))

		if self._unit:interaction() then
			if self._jammed_tweak_data then
				self._unit:interaction():set_tweak_data(self._jammed_tweak_data)
			end

			self._unit:interaction():set_active(true)
		end

		self:post_event(self._jam_event)
	else
		for _, child in ipairs(self._gui_script.panel:children()) do
			if child.children then
				for _, grandchild in ipairs(child:children()) do
					grandchild:set_color(self._original_colors[grandchild:key()])
				end
			else
				child:set_color(self._original_colors[child:key()])
			end
		end

		self._gui_script.working_text:set_text(managers.localization:text(self._gui_working))
		self._gui_script.time_text:set_text(math.floor(self._time_left or self._current_timer) .. " " .. managers.localization:text("prop_timer_gui_seconds"))
		self._gui_script.drill_screen_background:set_color(self._gui_script.drill_screen_background:color():with_alpha(1))
		self:post_event(self._resume_event)

		local theme = TimerGui.themes[self.THEME]

		if theme and theme.bg_rect_blend_mode then
			self._gui_script.bg_rect:set_blend_mode(theme.bg_rect_blend_mode)
		end

		if self._unit:interaction() then
			self._unit:interaction():set_active(false)
		end
	end

	self._unit:base():set_jammed(jammed)

	if self._unit:mission_door_device() then
		self._unit:mission_door_device():report_jammed_state(jammed)
	end
end

function TimerGui:set_powered(powered, enable_interaction)
	self:_set_powered(powered, enable_interaction)
end

function TimerGui:_set_powered(powered, enable_interaction)
	self._powered = powered

	if not self._powered then
		for _, child in ipairs(self._gui_script.panel:children()) do
			if child.children then
				for _, grandchild in ipairs(child:children()) do
					local color = self._original_colors[grandchild:key()]
					local c = Color(color.a, 1, 0, 0)

					grandchild:set_color(c)
				end
			else
				local color = self._original_colors[child:key()]
				local c = Color(color.a, 1, 0, 0)

				child:set_color(c)
			end
		end

		self:post_event(self._power_off_event or self._jam_event)

		if enable_interaction and self._unit:interaction() then
			self._powered_interaction_enabled = enable_interaction

			if self._jammed_tweak_data then
				self._unit:interaction():set_tweak_data(self._jammed_tweak_data)
			end

			self._unit:interaction():set_active(true)
		end

		self:post_event(self._power_off_event or self._jam_event)
	else
		for _, child in ipairs(self._gui_script.panel:children()) do
			if child.children then
				for _, grandchild in ipairs(child:children()) do
					grandchild:set_color(self._original_colors[grandchild:key()])
				end
			else
				child:set_color(self._original_colors[child:key()])
			end
		end

		self:post_event(self._resume_event)

		if self._powered_interaction_enabled then
			self._powered_interaction_enabled = nil

			if self._unit:mission_door_device() then
				self._unit:mission_door_device():report_resumed()
			end
		end
	end

	self._unit:base():set_powered(powered)
end

function TimerGui:done()
	self:_set_done()

	if self._unit:damage() then
		self._unit:damage():run_sequence_simple("timer_done")
	end

	self:post_event(self._done_event)

	if self._unit:mission_door_device() then
		self._unit:mission_door_device():report_completed()
	end
end

function TimerGui:is_playing_done_event()
	return self._is_playing_done_event
end

function TimerGui:add_listener_to_done_event(clbk)
	self._done_event_listeners = self._done_event_listeners or {}

	table.insert(self._done_event_listeners, clbk)
end

function TimerGui:on_done_event_ended()
	self._is_playing_done_event = false

	if self._done_event_listeners then
		for _, clbk in ipairs(self._done_event_listeners) do
			clbk(self._unit)
		end

		self._done_event_listeners = nil
	end
end

function TimerGui:_set_done()
	self._done = true

	self._gui_script.timer:set_w(self._timer_lenght)
	self._gui_script.working_text:set_color(self._gui_script.working_text:color():with_alpha(1))
	self._gui_script.working_text:set_text(managers.localization:text(self._gui_done))
	self._gui_script.time_header_text:set_visible(false)
	self._gui_script.time_text:set_visible(false)
	self._unit:base():done()
end

function TimerGui:update_sound_event()
	if self._done or not self._started or self._jammed or not self._powered then
		return
	end

	self:post_event(self._resume_event)
end

function TimerGui:hide()
	self._ws:hide()
end

function TimerGui:show()
	self._ws:show()
end

function TimerGui:lock_gui()
	self._ws:set_cull_distance(self._cull_distance)
	self._ws:set_frozen(true)
end

function TimerGui:destroy()
	if alive(self._new_gui) and alive(self._ws) then
		self._new_gui:destroy_workspace(self._ws)

		self._ws = nil
		self._new_gui = nil
	end
end

function TimerGui:save(data)
	local state = {
		update_enabled = self._update_enabled,
		timer = self._timer,
		current_timer = self._current_timer,
		jammed = self._jammed,
		powered = self._powered,
		powered_interaction_enabled = self._powered_interaction_enabled,
		done = self._done,
		visible = self._visible,
		timer_multiplier = self._timer_multiplier,
		skill = self._skill
	}
	data.TimerGui = state
end

function TimerGui:load(data)
	local state = data.TimerGui

	self:set_skill(state.skill or 1)

	if state.done then
		self:_set_done()
	elseif state.update_enabled then
		self:_start(state.timer, state.current_timer)

		if state.jammed then
			self:_set_jammed(state.jammed)
		end

		if not state.powered then
			self:_set_powered(state.powered, state.powered_interaction_enabled)
		end

		if not state.jammed and self._unit:interaction() and self._unit:interaction().check_for_upgrade then
			self._unit:interaction():check_for_upgrade()
		end
	end

	self:set_visible(state.visible)
	self:set_timer_multiplier(state.timer_multiplier or 1)
end

function TimerGui:post_event(event)
	if not event then
		return
	end

	local sound_event = event

	if event == self._start_event or event == self._resume_event or event == self._done_event then
		if self._skill == 3 then
			sound_event = sound_event .. "_aced"
		elseif self._skill == 2 then
			sound_event = sound_event .. "_basic"
		end
	end

	local clbk, cookie = nil
	local flags = {}

	if event == self._done_event then
		self._is_playing_done_event = true
		clbk = callback(self, self, "on_done_event_ended")

		table.insert(flags, "end_of_event")
	end

	self._unit:sound_source():post_event(sound_event, clbk, cookie, unpack(flags))
end

DrillTimerGui = DrillTimerGui or class(TimerGui)
