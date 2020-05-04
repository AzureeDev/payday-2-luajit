SkirmishBriefingProgress = SkirmishBriefingProgress or class(GUIObjectWrapper)

function SkirmishBriefingProgress:init(parent, config)
	local panel = parent:panel(config)

	SkirmishBriefingProgress.super.init(self, panel)

	self._config = deep_clone(config)

	self:redraw()

	if not self._config.static_wave then
		panel:animate(callback(self, self, "_sniff_for_wave_change"))
	end
end

function SkirmishBriefingProgress:_sniff_for_wave_change()
	local last_sniffed_wave = nil

	while true do
		local current_wave = managers.skirmish:current_wave_number()

		if last_sniffed_wave ~= current_wave then
			last_sniffed_wave = current_wave

			self:redraw()
		end

		coroutine.yield()
	end
end

function SkirmishBriefingProgress:redraw()
	if self._canvas then
		self._gui_obj:remove(self._canvas)
	end

	self._canvas = self._gui_obj:panel()
	local start_wave, end_wave = managers.skirmish:wave_range()
	local current_wave = self._config.static_wave or managers.skirmish:current_wave_number() or start_wave
	local wave_diff = end_wave - start_wave
	local padding = 6
	local progress = math.max((current_wave - 1) / wave_diff, 0)
	local bar_width = self._config.w - padding * 2
	local progress_bar = ProgressBar:new(self._canvas, {
		name = "progress_bar",
		h = 8,
		progress_color = tweak_data.screen_colors.skirmish_color,
		back_color = tweak_data.screen_colors.text:with_alpha(0.4),
		w = bar_width
	}, progress + 2 / bar_width)

	progress_bar:set_center_x(self._canvas:width() * 0.5)
	progress_bar:set_center_y(self._canvas:height() * 0.5)

	if self._config.align_top then
		progress_bar:set_valign("bottom")
		progress_bar:set_bottom(self._canvas:height())
	end

	local indicator_top = self._canvas:height()

	for i = 0, wave_diff do
		local wave_number = start_wave + i
		local wave_progress = i / wave_diff
		local color = progress >= wave_progress and tweak_data.screen_colors.skirmish_color or tweak_data.screen_colors.text:with_alpha(0.4)
		local wave_indicator = nil

		if wave_number == start_wave or wave_number == end_wave or wave_number == current_wave then
			wave_indicator = SkirmishProgressWaveNumber:new(self._canvas, {
				wave_number = wave_number,
				color = color
			})

			wave_indicator:set_bottom(progress_bar:top() - 2)
		else
			wave_indicator = self._canvas:rect({
				w = 4,
				h = 4,
				color = color
			})

			wave_indicator:set_bottom(progress_bar:top())
		end

		wave_indicator:set_center_x(progress_bar:x() + progress_bar:width() * wave_progress)

		indicator_top = math.min(indicator_top, wave_indicator:top())

		if self._config.align_top then
			wave_indicator:set_valign("bottom")
		end
	end

	if self._config.align_top then
		self._canvas:set_h(self._canvas:height() - indicator_top)
		self._gui_obj:set_h(self._canvas:height())
	end
end

SkirmishProgressWaveNumber = SkirmishProgressWaveNumber or class(GUIObjectWrapper)

function SkirmishProgressWaveNumber:init(parent, config)
	local panel = parent:panel()

	SkirmishProgressWaveNumber.super.init(self, panel)

	local wave_number = FineText:new(panel, {
		name = "wave_number",
		text = tostring(config.wave_number),
		font = config.font or tweak_data.menu.pd2_small_font,
		font_size = config.font_size or tweak_data.menu.pd2_small_font_size,
		color = config.color
	})
	local texture, texture_rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local arrow = panel:bitmap({
		name = "arrow",
		h = 6,
		w = 12,
		rotation = 180,
		texture = texture,
		texture_rect = texture_rect,
		color = config.color
	})
	local width = math.max(wave_number:width(), arrow:width())

	wave_number:set_center_x(width * 0.5)
	arrow:set_center_x(width * 0.5)
	arrow:set_top(wave_number:bottom() + 2)
	panel:set_width(width)
	panel:set_height(arrow:bottom())
end
