core:module("SystemMenuManager")
require("lib/managers/dialogs/GenericDialog")

SpecializationDialog = SpecializationDialog or class(GenericDialog)

function SpecializationDialog:init(manager, data, is_title_outside)
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
	self._panel_script = _G.SpecializationBoxGui:new(self._ws, self._data.title or "", self._data.text or "", self._data, text_config)

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

function SpecializationDialog:fade_in()
	SpecializationDialog.super.fade_in(self)

	self._start_sound_t = self._sound_event and TimerManager:main():time() + 0.2
end

function SpecializationDialog:update(t, dt)
	SpecializationDialog.super.update(self, t, dt)

	if self._start_sound_t and self._start_sound_t < t then
		managers.menu_component:post_event(self._sound_event)

		self._start_sound_t = nil
	end
end

function SpecializationDialog:fade_out_close()
	self._conversion_ended = self._panel_script:chk_close()

	if self._conversion_ended then
		self:fade_out()
	end

	managers.menu:post_event("prompt_exit")
end

function SpecializationDialog:remove_mouse()
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
