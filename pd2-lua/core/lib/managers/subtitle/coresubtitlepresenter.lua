core:module("CoreSubtitlePresenter")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreEvent")
core:import("CoreDebug")
core:import("CoreSubtitleSequence")

SubtitlePresenter = SubtitlePresenter or CoreClass.class()
DebugPresenter = DebugPresenter or CoreClass.class(SubtitlePresenter)
OverlayPresenter = OverlayPresenter or CoreClass.class(SubtitlePresenter)

function SubtitlePresenter:destroy()
end

function SubtitlePresenter:update(time, delta_time)
end

function SubtitlePresenter:show()
end

function SubtitlePresenter:hide()
end

function SubtitlePresenter:show_text(text, duration)
end

function SubtitlePresenter:preprocess_sequence(sequence)
	return sequence
end

function DebugPresenter:destroy()
	CoreDebug.cat_print("subtitle_manager", string.format("SubtitlePresenter is destroyed."))
end

function DebugPresenter:show()
	CoreDebug.cat_print("subtitle_manager", string.format("SubtitlePresenter is shown."))
end

function DebugPresenter:hide()
	CoreDebug.cat_print("subtitle_manager", string.format("SubtitlePresenter hides."))
end

function DebugPresenter:show_text(text, duration)
	CoreDebug.cat_print("subtitle_manager", string.format("SubtitlePresenter displays \"%s\" %s.", text, duration and string.format("for %g seconds", duration) or "until further notice"))
end

function OverlayPresenter:init(font_name, font_size)
	self:set_font(font_name or self:_default_font_name(), font_size or self:_default_font_size())
	self:_clear_workspace()

	self.__resolution_changed_id = managers.viewport:add_resolution_changed_func(CoreEvent.callback(self, self, "_on_resolution_changed"))
end

function OverlayPresenter:destroy()
	if self.__resolution_changed_id and managers.viewport then
		managers.viewport:remove_resolution_changed_func(self.__resolution_changed_id)
	end

	self.__resolution_changed_id = nil

	if CoreCode.alive(self.__subtitle_panel) then
		self.__subtitle_panel:stop()
		self.__subtitle_panel:clear()
	end

	self.__subtitle_panel = nil

	if CoreCode.alive(self.__ws) then
		self.__ws:gui():destroy_workspace(self.__ws)
	end

	self.__ws = nil
end

function OverlayPresenter:show()
	self.__ws:show()
end

function OverlayPresenter:hide()
	self.__ws:hide()
end

function OverlayPresenter:set_debug(enabled)
	if self.__ws then
		self.__ws:panel():set_debug(enabled)
	end
end

function OverlayPresenter:set_font(font_name, font_size)
	self.__font_name = assert(tostring(font_name), "Invalid font name parameter.")
	self.__font_size = assert(tonumber(font_size), "Invalid font size parameter.")

	if self.__subtitle_panel then
		for _, ui_element_name in ipairs({
			"layout",
			"label",
			"shadow"
		}) do
			local ui_element = self.__subtitle_panel:child(ui_element_name)

			if ui_element then
				ui_element:set_font(Idstring(self.__font_name))
				ui_element:set_font_size(self.__font_size)
			end
		end
	end

	local string_width_measure_text_field = CoreCode.alive(self.__ws) and self.__ws:panel():child("string_width")

	if string_width_measure_text_field then
		string_width_measure_text_field:set_font(Idstring(self.__font_name))
		string_width_measure_text_field:set_font_size(self.__font_size)
	end
end

function OverlayPresenter:set_width(pixels)
	local safe_width = self:_gui_width()
	self.__width = math.min(pixels, safe_width)

	if CoreCode.alive(self.__subtitle_panel) then
		self:_layout_text_field():set_width(self.__width)
	end
end

function OverlayPresenter:show_text(text, duration)
	local label = self.__subtitle_panel:child("label") or self.__subtitle_panel:text({
		name = "label",
		vertical = "bottom",
		word_wrap = true,
		wrap = true,
		align = "center",
		y = 1,
		x = 1,
		layer = 1,
		font = self.__font_name,
		font_size = self.__font_size,
		color = Color.white
	})
	local shadow = self.__subtitle_panel:child("shadow") or self.__subtitle_panel:text({
		y = 2,
		name = "shadow",
		vertical = "bottom",
		wrap = true,
		align = "center",
		word_wrap = true,
		visible = false,
		x = 2,
		layer = 0,
		font = self.__font_name,
		font_size = self.__font_size,
		color = Color.black:with_alpha(0.5)
	})

	label:set_text(text)
	shadow:set_text(text)
end

function OverlayPresenter:preprocess_sequence(sequence)
	local new_sequence = CoreSubtitleSequence.SubtitleSequence:new()

	for _, subtitle in ipairs(sequence:subtitles()) do
		local subtitle_string = subtitle:string()
		local wrapped_lines = self:_split_string_into_lines(subtitle_string, sequence)
		local lines_per_batch = 2
		local batch_count = math.max(math.ceil(#wrapped_lines / lines_per_batch), 1)
		local batch_duration = subtitle:duration() / batch_count
		local batch = 0

		for line = 1, batch_count * lines_per_batch, 2 do
			local wrapped_string = table.concat({
				wrapped_lines[line],
				wrapped_lines[line + 1]
			}, "\n")

			new_sequence:add_subtitle(CoreSubtitleSequence.Subtitle:new(wrapped_string, subtitle:start_time() + batch_duration * batch, batch_duration))

			batch = batch + 1
		end
	end

	return new_sequence
end

function OverlayPresenter:_clear_workspace()
	if CoreCode.alive(self.__ws) then
		managers.gui_data:destroy_workspace(self.__ws)
	end

	self.__ws = managers.gui_data:create_saferect_workspace("screen", Overlay:gui())
	self.__subtitle_panel = self.__ws:panel():panel({
		layer = 150
	})

	self:_on_resolution_changed()
end

function OverlayPresenter:_split_string_into_lines(subtitle_string, owning_sequence)
	return self:_auto_word_wrap_string(subtitle_string)
end

function OverlayPresenter:_auto_word_wrap_string(subtitle_string)
	local layout_text_field = self:_layout_text_field()

	layout_text_field:set_text(subtitle_string)

	local line_breaks = table.collect(layout_text_field:line_breaks(), function (index)
		return index + 1
	end)
	local wrapped_lines = {}

	for line = 1, #line_breaks do
		local range_start = line_breaks[line]
		local range_end = line_breaks[line + 1]
		local string_range = utf8.sub(subtitle_string, range_start, (range_end or 0) - 1)

		table.insert(wrapped_lines, string.trim(string_range))
	end

	return wrapped_lines
end

function OverlayPresenter:_layout_text_field()
	assert(self.__subtitle_panel)

	return self.__subtitle_panel:child("layout") or self.__subtitle_panel:text({
		name = "layout",
		vertical = "bottom",
		word_wrap = true,
		wrap = true,
		align = "center",
		visible = false,
		width = self.__width,
		font = self.__font_name,
		font_size = self.__font_size
	})
end

function OverlayPresenter:_string_width(subtitle_string)
	local string_width_measure_text_field = self.__ws:panel():child("string_width") or self.__ws:panel():text({
		name = "string_width",
		wrap = false,
		visible = false,
		font = self.__font_name,
		font_size = self.__font_size
	})

	string_width_measure_text_field:set_text(subtitle_string)

	local x, y, width, height = string_width_measure_text_field:text_rect()

	return width
end

function OverlayPresenter:_on_resolution_changed()
	self:set_font(self.__font_name or self:_default_font_name(), self.__font_size or self:_default_font_size())

	local width = self:_gui_width()
	local height = self:_gui_height()
	local safe_rect = managers.gui_data:corner_scaled_size()

	managers.gui_data:layout_corner_saferect_workspace(self.__ws)
	self.__subtitle_panel:set_width(safe_rect.width)
	self.__subtitle_panel:set_height(safe_rect.height - 120)
	self.__subtitle_panel:set_x(0)
	self.__subtitle_panel:set_y(0)
	self:set_width(self:_string_width("The quick brown fox jumped over the lazy dog bla bla bla bla bla bla bla bla bla blah blah blah blah blah ."))

	local label = self.__subtitle_panel:child("label")

	if label then
		label:set_h(self.__subtitle_panel:h())
		label:set_w(self.__subtitle_panel:w())
	end

	local shadow = self.__subtitle_panel:child("shadow")

	if shadow then
		shadow:set_h(self.__subtitle_panel:h())
		shadow:set_w(self.__subtitle_panel:w())
	end
end

function OverlayPresenter:_gui_width()
	return self.__subtitle_panel:width()
end

function OverlayPresenter:_gui_height()
	return self.__subtitle_panel:width()
end

function OverlayPresenter:_default_font_name()
	return "core/fonts/system_font"
end

function OverlayPresenter:_default_font_size()
	return 22
end
