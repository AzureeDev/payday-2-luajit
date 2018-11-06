core:module("CoreColorPickerPanel")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreColorPickerDraggables")
core:import("CoreColorPickerFields")

ColorPickerPanel = ColorPickerPanel or CoreClass.mixin(CoreClass.class(), CoreEvent.BasicEventHandling)

function ColorPickerPanel:init(parent_frame, enable_alpha, orientation, enable_value)
	assert(orientation == "HORIZONTAL" or orientation == "VERTICAL")
	self:_create_panel(parent_frame, enable_alpha, orientation, enable_value)
end

function ColorPickerPanel:panel()
	return self._panel
end

function ColorPickerPanel:color()
	return self._fields:color()
end

function ColorPickerPanel:set_color(color)
	self._draggables:set_color(color)
	self._fields:set_color(color)
end

function ColorPickerPanel:update(time, delta_time)
	self._draggables:update(time, delta_time)
	self._fields:update(time, delta_time)
end

function ColorPickerPanel:_create_panel(parent_frame, enable_alpha, orientation, enable_value)
	self._panel = EWS:Panel(parent_frame)
	local panel_sizer = EWS:BoxSizer(orientation)

	self._panel:set_sizer(panel_sizer)

	self._draggables = CoreColorPickerDraggables.ColorPickerDraggables:new(self._panel, enable_alpha, enable_value)
	self._fields = CoreColorPickerFields.ColorPickerFields:new(self._panel, enable_alpha, enable_value)

	self._draggables:connect("EVT_COLOR_UPDATED", CoreEvent.callback(self, self, "_on_color_updated"), self._draggables)
	self._fields:connect("EVT_COLOR_UPDATED", CoreEvent.callback(self, self, "_on_color_updated"), self._fields)
	self._draggables:connect("EVT_COLOR_CHANGED", CoreEvent.callback(self, self, "_on_color_changed"), self._draggables)
	self._fields:connect("EVT_COLOR_CHANGED", CoreEvent.callback(self, self, "_on_color_changed"), self._fields)
	panel_sizer:add(self._draggables:panel(), 0, 0, "EXPAND")
	panel_sizer:add(self._fields:panel(), 1, 0, "EXPAND")
end

function ColorPickerPanel:_on_color_updated(sender, color)
	table.exclude({
		self._draggables,
		self._fields
	}, sender)[1]:set_color(color)
	self:_send_event("EVT_COLOR_UPDATED", color)
end

function ColorPickerPanel:_on_color_changed(sender, color)
	self:_send_event("EVT_COLOR_CHANGED", color)
end
