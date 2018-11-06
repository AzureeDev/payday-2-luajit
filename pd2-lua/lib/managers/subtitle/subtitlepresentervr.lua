core:module("CoreSubtitlePresenter")

OverlayPresenterVR = OverlayPresenterVR or class(OverlayPresenter)

function OverlayPresenterVR:_clear_workspace()
	if alive(self.__ws) then
		managers.gui_data:destroy_workspace(self.__ws)
	end

	self.__ws = managers.gui_data:create_saferect_workspace("mid")
	self.__subtitle_panel = self.__ws:panel():panel({
		layer = 150
	})

	self:_on_resolution_changed()
end

function OverlayPresenterVR:_on_resolution_changed()
	self:set_font(self.__font_name or self:_default_font_name(), self.__font_size or self:_default_font_size())

	local safe_rect = managers.gui_data:corner_scaled_size()

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

CoreClass.override_class(OverlayPresenter, OverlayPresenterVR)

IngamePresenterVR = IngamePresenterVR or class(OverlayPresenter)

function IngamePresenterVR:init(font_name, font_size, custom_ws)
	self.__ws = custom_ws

	IngamePresenterVR.super.init(self, font_name, font_size)
end

function IngamePresenterVR:_clear_workspace()
	if alive(self.__ws) then
		self.__ws:panel():clear()

		self.__subtitle_panel = self.__ws:panel():panel({
			layer = 150
		})

		self:_on_resolution_changed()
	end
end

function IngamePresenterVR:destroy()
	if self.__resolution_changed_id and managers.viewport then
		managers.viewport:remove_resolution_changed_func(self.__resolution_changed_id)
	end

	self.__resolution_changed_id = nil

	if CoreCode.alive(self.__subtitle_panel) then
		self.__subtitle_panel:stop()
		self.__subtitle_panel:clear()
	end

	self.__subtitle_panel = nil
end

function IngamePresenterVR:_on_resolution_changed()
	self:set_font(self.__font_name or self:_default_font_name(), self.__font_size or self:_default_font_size())
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

function IngamePresenterVR:show_text(...)
	IngamePresenterVR.super.show_text(self, ...)
	_G.VRManagerPD2.overlay_helper(self.__subtitle_panel)
	_G.VRManagerPD2.depth_disable_helper(self.__subtitle_panel)
end
