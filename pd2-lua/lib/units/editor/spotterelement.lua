SpotterUnitElement = SpotterUnitElement or class(MissionElement)
SpotterUnitElement.USES_POINT_ORIENTATION = true
SpotterUnitElement.ON_EXECUTED_ALTERNATIVES = {
	"on_outlined",
	"on_spotted"
}

function SpotterUnitElement:init(unit)
	SpotterUnitElement.super.init(self, unit)
end

function SpotterUnitElement:update_selected(time, rel_time)
	local brush = Draw:brush(Color.white:with_alpha((1 - (math.sin(time * 100) + 1) / 2) * 0.15))
	local len = (math.sin(time * 100) + 1) / 2 * 3000

	brush:cone(self._unit:position(), self._unit:position() + self._unit:rotation():y() * len, len)
	brush:set_color(Color.white:with_alpha(0.15))
	brush:cone(self._unit:position(), self._unit:position() + self._unit:rotation():y() * 3000, 3000)
	Application:draw_cone(self._unit:position(), self._unit:position() + self._unit:rotation():y() * 3000, 3000, 0.75, 0.75, 0.75, 0.1)
end

function SpotterUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
end
