CorePhysicsPushUnitElement = CorePhysicsPushUnitElement or class(MissionElement)
PhysicsPushUnitElement = PhysicsPushUnitElement or class(CorePhysicsPushUnitElement)

function PhysicsPushUnitElement:init(...)
	CorePhysicsPushUnitElement.init(self, ...)
end

function CorePhysicsPushUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.physicspush_range = 1000
	self._hed.physicspush_velocity = 100
	self._hed.physicspush_mass = 100

	table.insert(self._save_values, "physicspush_range")
	table.insert(self._save_values, "physicspush_velocity")
	table.insert(self._save_values, "physicspush_mass")
end

function CorePhysicsPushUnitElement:update_selected()
	Application:draw_sphere(self._unit:position(), self._hed.physicspush_range, 0, 1, 0)
end

function CorePhysicsPushUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local range_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Range")
	local range = EWS:Slider(panel, self._hed.physicspush_range, 1, 10000, "", "SL_LABELS")

	range_sizer:add(range, 0, 0, "EXPAND")
	range:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_element_data"), {
		value = "physicspush_range",
		ctrlr = range
	})
	range:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_element_data"), {
		value = "physicspush_range",
		ctrlr = range
	})

	local velocity_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Velocity")
	local velocity = EWS:Slider(panel, self._hed.physicspush_velocity, 1, 5000, "", "SL_LABELS")

	velocity_sizer:add(velocity, 0, 0, "EXPAND")
	velocity:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_element_data"), {
		value = "physicspush_velocity",
		ctrlr = velocity
	})
	velocity:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_element_data"), {
		value = "physicspush_velocity",
		ctrlr = velocity
	})

	local mass_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Mass")
	local mass = EWS:Slider(panel, self._hed.physicspush_mass, 1, 5000, "", "SL_LABELS")

	mass_sizer:add(mass, 0, 0, "EXPAND")
	mass:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_element_data"), {
		value = "physicspush_mass",
		ctrlr = mass
	})
	mass:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_element_data"), {
		value = "physicspush_mass",
		ctrlr = mass
	})
	panel_sizer:add(range_sizer, 0, 0, "EXPAND")
	panel_sizer:add(velocity_sizer, 0, 0, "EXPAND")
	panel_sizer:add(mass_sizer, 0, 0, "EXPAND")
end

function CorePhysicsPushUnitElement:add_to_mission_package()
	managers.editor:add_to_world_package({
		name = "core/physic_effects/hubelement_push",
		category = "physic_effects",
		continent = self._unit:unit_data().continent
	})
end
