CorePointOrientationUnitElement = CorePointOrientationUnitElement or class(MissionElement)
PointOrientationUnitElement = PointOrientationUnitElement or class(CorePointOrientationUnitElement)

function PointOrientationUnitElement:init(...)
	PointOrientationUnitElement.super.init(self, ...)
end

function CorePointOrientationUnitElement:init(unit)
	CorePointOrientationUnitElement.super.init(self, unit)
end

function CorePointOrientationUnitElement:update_selected(...)
	CorePointOrientationUnitElement.super.update_selected(self, ...)
	self:_draw_orientation()
end

function CorePointOrientationUnitElement:update_unselected(...)
	CorePointOrientationUnitElement.super.update_unselected(self, ...)
	self:_draw_orientation()
end

function CorePointOrientationUnitElement:_draw_orientation()
	local len = 25
	local scale = 0.05

	Application:draw_arrow(self._unit:position(), self._unit:position() + self._unit:rotation():x() * len, 1, 0, 0, scale)
	Application:draw_arrow(self._unit:position(), self._unit:position() + self._unit:rotation():y() * len, 0, 1, 0, scale)
	Application:draw_arrow(self._unit:position(), self._unit:position() + self._unit:rotation():z() * len, 0, 0, 1, scale)
end
