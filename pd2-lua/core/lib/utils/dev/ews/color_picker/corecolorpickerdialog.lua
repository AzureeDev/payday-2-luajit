core:module("CoreColorPickerDialog")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreEws")
core:import("CoreColorPickerPanel")

ColorPickerDialog = ColorPickerDialog or CoreClass.mixin(CoreClass.class(), CoreEvent.BasicEventHandling)
ColorPickerDialog.EDITOR_TITLE = "Color Picker"

function ColorPickerDialog:init(parent_frame, enable_alpha, orientation, enable_value)
	orientation = orientation or "HORIZONTAL"

	assert(orientation == "HORIZONTAL" or orientation == "VERTICAL", "Invalid orientation.")

	local frame_size = orientation == "HORIZONTAL" and Vector3(366, 166) or Vector3(186, 300, 0)
	self._window = EWS:Frame(ColorPickerDialog.EDITOR_TITLE, Vector3(-1, -1, 0), frame_size, "SYSTEM_MENU,CAPTION,CLOSE_BOX,CLIP_CHILDREN", parent_frame)
	local sizer = EWS:BoxSizer("HORIZONTAL")

	self._window:set_sizer(sizer)
	self._window:set_icon(CoreEws.image_path("toolbar/color_16x16.png"))
	self._window:connect("", "EVT_CLOSE_WINDOW", CoreEvent.callback(self, self, "_on_close"), "")

	self._picker_panel = CoreColorPickerPanel.ColorPickerPanel:new(self._window, enable_alpha, orientation, enable_value)

	self._picker_panel:connect("EVT_COLOR_UPDATED", CoreEvent.callback(self, self, "_on_color_updated"), self._picker_panel)
	self._picker_panel:connect("EVT_COLOR_CHANGED", CoreEvent.callback(self, self, "_on_color_changed"), self._picker_panel)
	sizer:add(self._picker_panel:panel(), 0, 0, "EXPAND")
	self:set_visible(true)
end

function ColorPickerDialog:update(time, delta_time)
	self._picker_panel:update(time, delta_time)
end

function ColorPickerDialog:color()
	return self._picker_panel:color()
end

function ColorPickerDialog:set_color(color)
	self._picker_panel:set_color(color)
end

function ColorPickerDialog:set_position(newpos)
	self._window:set_position(newpos)
end

function ColorPickerDialog:set_visible(visible)
	self._window:set_visible(visible)
end

function ColorPickerDialog:center(window)
	self._window:set_position(window:get_position() + window:get_size() * 0.5 - self._window:get_size() * 0.5)
end

function ColorPickerDialog:close()
	self._window:destroy()
end

function ColorPickerDialog:_on_color_updated(sender, color)
	self:_send_event("EVT_COLOR_UPDATED", color)
end

function ColorPickerDialog:_on_color_changed(sender, color)
	self:_send_event("EVT_COLOR_CHANGED", color)
end

function ColorPickerDialog:_on_close()
	self._window:set_visible(false)
	self:_send_event("EVT_CLOSE_WINDOW", self._window)
	managers.toolhub:close(ColorPickerDialog.EDITOR_TITLE)
end
