core:module("CoreVector3SpinCtrl")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreFloatSpinCtrl")

Vector3SpinCtrl = Vector3SpinCtrl or CoreClass.mixin(CoreClass.class(), CoreEvent.BasicEventHandling)

function Vector3SpinCtrl:init(parent, min, max, step, value, name, dec, style)
	assert(parent)

	self._min = min or Vector3(0, 0, 0)
	self._max = max or Vector3(1, 1, 1)
	self._step = step or 0.1
	self._dec = dec or 1
	self._value = value or self._min
	self._name = name or ""
	self._style = style or ""
	local s = string.find(self._style, "V3_VERTICAL")
	local layout = s and "VERTICAL" or "HORIZONTAL"
	local vec_3_type = not string.find(self._style, "VECTOR2TYPE")
	self._panel = EWS:Panel(parent)
	local box = EWS:StaticBoxSizer(self._panel, layout, self._name)
	self._x = CoreFloatSpinCtrl.FloatSpinCtrl:new(self._panel, self._min.x, self._max.x, self._step, self._value.x, self._dec, self._style)

	self._x:connect("", "EVT_FLOAT_SPIN_CTRL_UPDATED", callback(self, self, "_updated"), "")
	self._x:connect("", "EVT_FLOAT_SPIN_CTRL_ENTER", callback(self, self, "_enter"), "")
	box:add(self._x:window(), 1, 0, "EXPAND")

	self._y = CoreFloatSpinCtrl.FloatSpinCtrl:new(self._panel, self._min.y, self._max.y, self._step, self._value.y, self._dec, self._style)

	self._y:connect("", "EVT_FLOAT_SPIN_CTRL_UPDATED", callback(self, self, "_updated"), "")
	self._y:connect("", "EVT_FLOAT_SPIN_CTRL_ENTER", callback(self, self, "_enter"), "")
	box:add(self._y:window(), 1, 0, "EXPAND")

	if vec_3_type then
		self._z = CoreFloatSpinCtrl.FloatSpinCtrl:new(self._panel, self._min.z, self._max.z, self._step, self._value.z, self._dec, self._style)

		self._z:connect("", "EVT_FLOAT_SPIN_CTRL_UPDATED", callback(self, self, "_updated"), "")
		self._z:connect("", "EVT_FLOAT_SPIN_CTRL_ENTER", callback(self, self, "_enter"), "")
		box:add(self._z:window(), 1, 0, "EXPAND")
	end

	self._panel:set_sizer(box)
end

function Vector3SpinCtrl:window()
	return self._panel
end

function Vector3SpinCtrl:get_value()
	return Vector3(self._x:get_value(), self._y:get_value(), self._z:get_value())
end

function Vector3SpinCtrl:set_value(value)
	self._x:set_value(value.x)
	self._y:set_value(value.y)
	self._z:set_value(value.z)
end

function Vector3SpinCtrl:change_value(value)
	self._x:change_value(value.x)
	self._y:change_value(value.y)
	self._z:change_value(value.z)
end

function Vector3SpinCtrl:_updated()
	self:_send_event("EVT_VECTOR3_SPIN_CTRL_UPDATED", self:get_value())
end

function Vector3SpinCtrl:_enter()
	self:_send_event("EVT_VECTOR3_SPIN_CTRL_ENTER", self:get_value())
end
