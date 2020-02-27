core:module("SystemMenuManager")
require("lib/managers/dialogs/GenericDialog")
require("lib/managers/menu/TextBoxGui")

DrillConvertDialog = DrillConvertDialog or class(GenericDialog)

function DrillConvertDialog:init(manager, data, is_title_outside)
	Dialog.init(self, manager, data)

	if not self._data.focus_button then
		if #self._button_text_list > 0 then
			self._data.focus_button = #self._button_text_list
		else
			self._data.focus_button = 1
		end
	end

	self._ws = self._data.ws or manager:_get_ws()
	local text_config = {
		no_close_legend = true,
		no_scroll_legend = true,
		title_font = data.title_font,
		title_font_size = data.title_font_size,
		font = data.font,
		font_size = data.font_size,
		w = data.w or 420,
		h = data.h or 400,
		use_indicator = data.indicator or data.no_buttons,
		is_title_outside = is_title_outside,
		use_text_formating = data.use_text_formating,
		text_formating_color = data.text_formating_color,
		text_formating_color_table = data.text_formating_color_table,
		text_blend_mode = data.text_blend_mode
	}
	self._panel_script = DrillConvertBoxGui:new(self._ws, self._data.title or "", self._data.text or "", self._data, text_config)

	self._panel_script:add_background()
	self._panel_script:set_layer(_G.tweak_data.gui.DIALOG_LAYER)
	self._panel_script:set_centered()
	self._panel_script:set_fade(0)

	self._controller = self._data.controller or manager:_get_controller()
	self._confirm_func = callback(self, self, "button_pressed_callback")
	self._cancel_func = callback(self, self, "dialog_cancel_callback")
	self._resolution_changed_callback = callback(self, self, "resolution_changed_callback")

	managers.viewport:add_resolution_changed_func(self._resolution_changed_callback)

	if data.counter then
		self._counter = data.counter
		self._counter_time = self._counter[1]
	end

	self._sound_event = data.sound_event
end

function DrillConvertDialog:fade_in()
	DrillConvertDialog.super.fade_in(self)

	self._start_sound_t = self._sound_event and TimerManager:main():time() + 0.2
end

function DrillConvertDialog:update(t, dt)
	DrillConvertDialog.super.update(self, t, dt)

	if self._start_sound_t and self._start_sound_t < t then
		managers.menu_component:post_event(self._sound_event)

		self._start_sound_t = nil
	end
end

function DrillConvertDialog:fade_out_close()
	self._conversion_ended = self._panel_script:chk_close()

	if self._conversion_ended then
		self:fade_out()
	end

	managers.menu:post_event("prompt_exit")
end

function DrillConvertDialog:remove_mouse()
	if not self._conversion_ended then
		return
	end

	if not self._removed_mouse then
		self._removed_mouse = true

		if managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" or managers.controller:get_default_wrapper_type() == "vr" then
			managers.mouse_pointer:remove_mouse(self._mouse_id)
		else
			managers.mouse_pointer:enable()
		end

		self._mouse_id = nil
	end
end

function DrillConvertDialog:button_pressed_callback()
	if self._data.no_buttons then
		return
	end

	self:remove_mouse()
	self:button_pressed(self._panel_script:get_focus_button())
end

function DrillConvertDialog:dialog_cancel_callback()
	if SystemInfo:platform() ~= Idstring("WIN32") then
		return
	end

	if self._data.no_buttons then
		return
	end

	if #self._data.button_list == 1 then
		self:remove_mouse()
		self:button_pressed(1)
	end

	for i, btn in ipairs(self._data.button_list) do
		if btn.cancel_button then
			self:remove_mouse()
			self:button_pressed(i)

			return
		end
	end
end

DrillConvertBoxGui = DrillConvertBoxGui or class(_G.TextBoxGui)
DrillConvertBoxGui.TEXT = ""

function DrillConvertBoxGui:init(...)
	local ws, title, text, content_data, config = ...
	config.forced_h = 210
	config.w = 600
	config.is_title_outside = true

	DrillConvertBoxGui.super.init(self, ...)
end

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	if text:wrap() == true then
		text:set_h(h)
	else
		text:set_size(w, h)
	end

	text:set_position(math.round(text:x()), math.round(text:y()))
end

function DrillConvertBoxGui:_create_text_box(ws, title, text, content_data, config)
	local main = DrillConvertBoxGui.super._create_text_box(self, ws, title, text, content_data, config)
	local drills_to_convert = content_data.drills_to_convert
	local num_drills = table.size(drills_to_convert)
	local progress_panel = main:child("lower_static_panel")
	local progress_bar = progress_panel:child("progress_bar")
	local progress_end = progress_panel:child("progress_end")
	local info_area = self._text_box:child("info_area")
	local buttons_panel = info_area:child("buttons_panel")

	buttons_panel:hide()

	self._anim_data = {
		progress_bar = progress_bar,
		end_progress_width = progress_end:right() - progress_bar:left(),
		drills_to_convert = drills_to_convert,
		num_drills = num_drills
	}
end

function DrillConvertBoxGui:_create_lower_static_panel(lower_static_panel)
	local tweak_data = _G.tweak_data
	local progress_panel = lower_static_panel
	local progress_text = progress_panel:text({
		blend_mode = "add",
		x = 10,
		layer = 1,
		text = managers.localization:to_upper_text("menu_st_spec_xp_progress"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})

	make_fine_text(progress_text)

	local progress_bg = progress_panel:rect({
		alpha = 0.4,
		layer = 1,
		h = progress_text:h(),
		color = Color.black
	})

	progress_bg:set_position(progress_text:right() + 4, progress_text:top())
	progress_bg:set_w(progress_panel:w() - progress_bg:left() - 5 - 10)

	local progress_bar = progress_panel:rect({
		blend_mode = "add",
		name = "progress_bar",
		alpha = 1,
		layer = 2,
		color = Color.white
	})

	progress_bar:set_shape(progress_bg:shape())
	progress_bar:set_w(0)
	progress_bar:grow(0, -4)
	progress_bar:move(2, 0)
	progress_bar:set_center_y(progress_bg:center_y())

	local progress_end = progress_panel:rect({
		blend_mode = "add",
		name = "progress_end",
		alpha = 1,
		layer = 3,
		color = Color.white
	})

	progress_end:set_shape(progress_bg:shape())
	progress_end:set_w(2)
	progress_end:grow(0, -4)
	progress_end:set_center_y(progress_bg:center_y())
	progress_end:set_right(progress_bg:right())
	progress_panel:set_size(progress_end:right(), progress_text:h())
end

function DrillConvertBoxGui:chk_close()
	return self._anim_data and table.size(self._anim_data.drills_to_convert) == 0
end

function DrillConvertBoxGui._update(o, self)
	local info_area = self._text_box:child("info_area")
	local buttons_panel = info_area:child("buttons_panel")
	local drills_left, num_drills, end_progress_width = nil

	while true do
		local dt = coroutine.yield()

		if self._up_alpha then
			self._up_alpha.current = math.step(self._up_alpha.current, self._up_alpha.target, dt * 5)

			self._text_box:child("scroll_up_indicator_shade"):set_alpha(self._up_alpha.current)
			self._text_box:child("scroll_up_indicator_arrow"):set_color(self._text_box:child("scroll_up_indicator_arrow"):color():with_alpha(self._up_alpha.current))
		end

		if self._down_alpha then
			self._down_alpha.current = math.step(self._down_alpha.current, self._down_alpha.target, dt * 5)

			self._text_box:child("scroll_down_indicator_shade"):set_alpha(self._down_alpha.current)
			self._text_box:child("scroll_down_indicator_arrow"):set_color(self._text_box:child("scroll_down_indicator_arrow"):color():with_alpha(self._down_alpha.current))
		end

		if self._anim_data and not self._anim_data.done then
			drills_left = table.size(self._anim_data.drills_to_convert)
			num_drills = self._anim_data.num_drills
			end_progress_width = self._anim_data.end_progress_width

			self._anim_data.progress_bar:set_width((1 - drills_left / num_drills) * end_progress_width)

			if drills_left == 0 then
				buttons_panel:show()

				self._anim_datadone = true
			end
		end
	end
end
