core:module("SystemMenuManager")
require("lib/managers/dialogs/GenericDialog")

NewUnlockDialog = NewUnlockDialog or class(GenericDialog)

function NewUnlockDialog:init(manager, data, is_title_outside)
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
	local image_config = {
		layer = 2,
		keep_ratio = true,
		video_start_paused = true,
		padding = 10,
		w = data.image_w or 128,
		h = data.image_h or 128,
		textures = data.textures,
		texture = data.texture,
		render_template = data.render_template,
		shapes = data.shapes,
		halign = data.image_halign,
		valign = data.image_valign,
		video = data.video,
		blend_mode = data.image_blend_mode,
		video_loop = data.video_loop
	}

	if not data.texture and not data.video and not data.shapes and not data.textures then
		image_config.w = 0
		image_config.h = 0
	end

	self._panel_script = _G.ImageBoxGui:new(self._ws, self._data.title or "", self._data.text or "", self._data, text_config, image_config)

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

function NewUnlockDialog:fade_in()
	NewUnlockDialog.super.fade_in(self)
	self._panel_script:set_video_paused(false)

	self._start_sound_t = self._sound_event and TimerManager:main():time() + 0.2
end

function NewUnlockDialog:update(t, dt)
	NewUnlockDialog.super.update(self, t, dt)

	if self._start_sound_t and self._start_sound_t < t then
		managers.menu_component:post_event(self._sound_event)

		self._start_sound_t = nil
	end
end
