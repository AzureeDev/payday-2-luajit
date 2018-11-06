ExplosionDamageUnitElement = ExplosionDamageUnitElement or class(MissionElement)

function ExplosionDamageUnitElement:init(unit)
	ExplosionDamageUnitElement.super.init(self, unit)

	self._hed.range = 100
	self._hed.damage = 40

	table.insert(self._save_values, "range")
	table.insert(self._save_values, "damage")
end

function ExplosionDamageUnitElement:update_selected()
	local brush = Draw:brush()

	brush:set_color(Color(0.15, 1, 1, 1))

	local pen = Draw:pen(Color(0.15, 0.5, 0.5, 0.5))

	brush:sphere(self._unit:position(), self._hed.range, 4)
	pen:sphere(self._unit:position(), self._hed.range)
end

function ExplosionDamageUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "range", {
		floats = 0,
		min = 0
	}, "The range the explosion should reach")
	self:_build_value_number(panel, panel_sizer, "damage", {
		min = 0,
		floats = 0,
		max = 100
	}, "The damage from the explosion")
end
