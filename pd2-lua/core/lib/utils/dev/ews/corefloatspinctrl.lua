core:module("CoreFloatSpinCtrl")
core:import("CoreClass")
core:import("CoreEvent")

INVALID_COLOR = {
	255,
	128,
	128
}
FloatSpinCtrl = FloatSpinCtrl or CoreClass.mixin(CoreClass.class(), CoreEvent.BasicEventHandling)

function FloatSpinCtrl:init(parent, min, max, step, value, dec, style)
	assert(parent)

	self._min = min or 0
	self._max = max or 1
	self._step = step or 0.1
	self._dec = dec or 1
	self._value = value or self._min
	self._style = style or ""
	self._use_colors = not string.find(self._style, "TC_NO_COLOR")

	self:_add_style(string.find(self._style, "SP_HORIZONTAL") and "SP_HORIZONTAL" or "SP_VERTICAL")

	self._panel = EWS:Panel(parent)
	local box = EWS:BoxSizer("HORIZONTAL")
	self._text = EWS:TextCtrl(self._panel, "", str, "TE_PROCESS_ENTER")

	self._text:connect("", "EVT_COMMAND_TEXT_UPDATED", callback(self, self, "_text_update_cb"), "")
	self._text:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "_text_enter_cb"), "")
	box:add(self._text, 1, 0, "EXPAND")

	self._btn = EWS:SpinButton(self._panel, "", self._sp_style)

	self._btn:set_min_size(Vector3(16, 1, 1))
	self._btn:connect("", "EVT_SCROLL_LINEUP", callback(self, self, "_btn_up_cb"), "")
	self._btn:connect("", "EVT_SCROLL_LINEDOWN", callback(self, self, "_btn_down_cb"), "")
	box:add(self._btn, 0, 0, "EXPAND")
	self._panel:set_sizer(box)

	self._bg_color = self._text:background_colour()

	self:_update_text()
end

function FloatSpinCtrl:window()
	return self._panel
end

function FloatSpinCtrl:get_value()
	return self._value
end

function FloatSpinCtrl:set_value(value)
	self._value = math.clamp(value, self._min, self._max)

	self:_update_text(true)
end

function FloatSpinCtrl:change_value(value)
	self._value = math.clamp(value, self._min, self._max)

	self:_update_text()
end

function FloatSpinCtrl:_btn_up_cb()
	self._value = math.clamp(self._value + self._step, self._min, self._max)

	self:_set_valid(true)
	self:_update_text()
	self:_send_event("EVT_FLOAT_SPIN_CTRL_SCROLL_UP", self:get_value())
	self:_send_event("EVT_FLOAT_SPIN_CTRL_UPDATED", self:get_value())
end

function FloatSpinCtrl:_btn_down_cb()
	self._value = math.clamp(self._value - self._step, self._min, self._max)

	self:_set_valid(true)
	self:_update_text()
	self:_send_event("EVT_FLOAT_SPIN_CTRL_SCROLL_DOWN", self:get_value())
	self:_send_event("EVT_FLOAT_SPIN_CTRL_UPDATED", self:get_value())
end

function FloatSpinCtrl:_text_update_cb(data, event)
	local value = tonumber(event:get_string())

	if value and self._min <= value and value <= self._max then
		self:_set_valid(true)

		self._value = value

		self:_send_event("EVT_FLOAT_SPIN_CTRL_TEXT", self:get_value())
		self:_send_event("EVT_FLOAT_SPIN_CTRL_UPDATED", self:get_value())
	else
		self:_set_valid(false)
	end
end

function FloatSpinCtrl:_text_enter_cb(data, event)
	self._value = math.clamp(tonumber(event:get_string()) or 0, self._min, self._max)

	self:_set_valid(true)
	self:_update_text()
	self:_send_event("EVT_FLOAT_SPIN_CTRL_ENTER", self:get_value())
	self:_send_event("EVT_FLOAT_SPIN_CTRL_UPDATED", self:get_value())
end

function FloatSpinCtrl:_update_text(send_event)
	local str = string.format("%0." .. tostring(self._dec) .. "f", self._value)

	if send_event then
		self._text:set_value(str)
	else
		self._text:change_value(str)
	end
end

function FloatSpinCtrl:_set_valid(valid)
	if self._use_colors then
		if valid then
			self._text:set_background_colour(self._bg_color.x, self._bg_color.y, self._bg_color.z)
		else
			self._text:set_background_colour(unpack(INVALID_COLOR))
		end

		self._text:refresh()
	end
end

function FloatSpinCtrl:_add_style(style)
	self._sp_style = self._sp_style and self._sp_style .. "," .. style or style
end
