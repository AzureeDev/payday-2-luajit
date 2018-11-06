FineText = FineText or class(GUIObjectWrapper)

function FineText:init(parent, config)
	config = config or {}
	config.font_size = config.font_size or tweak_data.menu.pd2_medium_font_size
	config.font = config.font or tweak_data.menu.pd2_medium_font
	config.color = config.color or tweak_data.screen_colors.text
	local text_obj = parent:text(config)

	FineText.super.init(self, text_obj)
	self:shrink_wrap()
end

function FineText:shrink_wrap()
	local x, y, w, h = self._gui_obj:text_rect()

	if self._gui_obj:wrap() then
		w = self._gui_obj:width()
	end

	self._gui_obj:set_size(w, h)
	self._gui_obj:set_world_position(math.round(x), math.round(y))
end

function FineText:set_text(...)
	self._gui_obj:set_text(...)
	self:shrink_wrap()
end

function FineText:set_color(...)
	self._gui_obj:set_color(...)
end

function FineText:set_range_color(...)
	self._gui_obj:set_range_color(...)
end

function FineText:clear_range_color(...)
	self._gui_obj:clear_range_color(...)
end

function FineText:text()
	return self._gui_obj:text()
end

function FineText:color()
	return self._gui_obj:color()
end
