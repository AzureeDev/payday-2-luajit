core:module("CoreEnvironmentAreaManager")
core:import("CoreShapeManager")
core:import("CoreEnvironmentFeeder")

EnvironmentAreaManager = EnvironmentAreaManager or class()
EnvironmentAreaManager.POSITION_OFFSET = 50

function EnvironmentAreaManager:init()
	self._areas = {}
	self._blocks = 0

	self:set_default_transition_time(0.1)
	self:set_default_bezier_curve({
		0,
		0,
		1,
		1
	})

	local skip_default_list = {
		[CoreEnvironmentFeeder.UnderlayPathFeeder.FILTER_CATEGORY] = true,
		[CoreEnvironmentFeeder.CubeMapTextureFeeder.FILTER_CATEGORY] = true,
		[CoreEnvironmentFeeder.WorldOverlayTextureFeeder.FILTER_CATEGORY] = true,
		[CoreEnvironmentFeeder.WorldOverlayMaskTextureFeeder.FILTER_CATEGORY] = true,
		[CoreEnvironmentFeeder.PostShadowSlice0Feeder.FILTER_CATEGORY] = true
	}
	local default_filter_list = {}

	for name, data_path_key_list in pairs(managers.viewport:get_predefined_environment_filter_map()) do
		if not skip_default_list[name] then
			for _, data_path_key in ipairs(data_path_key_list) do
				table.insert(default_filter_list, data_path_key)
			end
		end
	end

	self:set_default_filter_list(default_filter_list)
end

function EnvironmentAreaManager:set_default_transition_time(time)
	self._default_transition_time = time
end

function EnvironmentAreaManager:default_transition_time()
	return self._default_transition_time
end

function EnvironmentAreaManager:set_default_bezier_curve(bezier_curve)
	self._default_bezier_curve = bezier_curve
end

function EnvironmentAreaManager:default_bezier_curve()
	return self._default_bezier_curve
end

function EnvironmentAreaManager:set_default_filter_list(filter_list)
	self._default_filter_list = filter_list
end

function EnvironmentAreaManager:default_filter_list()
	if self._default_filter_list then
		return table.list_copy(self._default_filter_list)
	else
		return nil
	end
end

function EnvironmentAreaManager:default_prio()
	return 100
end

function EnvironmentAreaManager:areas()
	return self._areas
end

function EnvironmentAreaManager:add_area(area_params)
	local area = EnvironmentArea:new(area_params)

	table.insert(self._areas, area)
	self:prio_order_areas()

	return area
end

function EnvironmentAreaManager:prio_order_areas()
	table.sort(self._areas, function (a, b)
		return a:is_higher_prio(b:prio())
	end)
end

function EnvironmentAreaManager:remove_area(area)
	for _, vp in ipairs(managers.viewport:viewports()) do
		vp:on_environment_area_removed(area)
	end

	table.delete(self._areas, area)
end

function EnvironmentAreaManager:update(t, dt)
	local vps = managers.viewport:all_really_active_viewports()

	for _, vp in ipairs(vps) do
		if self._blocks > 0 then
			return
		end

		vp:update_environment_area(self._areas, self.POSITION_OFFSET)
	end
end

function EnvironmentAreaManager:environment_at_position(pos)
	local environment = managers.viewport:default_environment()

	for _, area in ipairs(self._areas) do
		if area:is_inside(pos) then
			environment = area:environment()

			break
		end
	end

	return environment
end

function EnvironmentAreaManager:add_block()
	self._blocks = self._blocks + 1
end

function EnvironmentAreaManager:remove_block()
	self._blocks = self._blocks - 1
end

EnvironmentArea = EnvironmentArea or class(CoreShapeManager.ShapeBox)

function EnvironmentArea:init(params)
	params.type = "box"

	EnvironmentArea.super.init(self, params)

	self._properties.name = params.name
	self._properties.environment = params.environment or managers.viewport:game_default_environment()
	self._properties.permanent = params.permanent or false
	self._properties.transition_time = params.transition_time or managers.environment_area:default_transition_time()
	self._properties.bezier_curve = params.bezier_curve or managers.environment_area:default_bezier_curve()
	self._properties.filter_list = params.filter_list or managers.environment_area:default_filter_list()
	self._properties.prio = params.prio or managers.environment_area:default_prio()

	self:_generate_id()
end

function EnvironmentArea:_generate_id()
	local filter_list_id = ""

	if self._properties.filter_list then
		for _, data_path_key in pairs(self._properties.filter_list) do
			filter_list_id = filter_list_id .. "," .. data_path_key
		end
	end

	self._id = (self._properties.environment .. filter_list_id):key()
end

function EnvironmentArea:save_level_data()
	local unit = self:unit()

	if unit then
		self._properties.name = self._unit:unit_data().name_id
	end

	return EnvironmentArea.super.save_level_data(self)
end

function EnvironmentArea:set_unit(unit)
	EnvironmentArea.super.set_unit(self, unit)

	if unit and self._properties.name then
		return self._properties.name
	else
		return nil
	end
end

function EnvironmentArea:id()
	return self._id
end

function EnvironmentArea:environment()
	return self:property("environment")
end

function EnvironmentArea:set_environment(environment)
	self:set_property_string("environment", environment)
	self:_generate_id()
end

function EnvironmentArea:permanent()
	return self:property("permanent")
end

function EnvironmentArea:set_permanent(permanent)
	self._properties.permanent = permanent
end

function EnvironmentArea:transition_time()
	return self:property("transition_time")
end

function EnvironmentArea:set_transition_time(time)
	self._properties.transition_time = time
end

function EnvironmentArea:bezier_curve()
	return self:property("bezier_curve")
end

function EnvironmentArea:set_bezier_curve(bezier_curve)
	self._properties.bezier_curve = bezier_curve
end

function EnvironmentArea:filter_list()
	return self:property("filter_list")
end

function EnvironmentArea:set_filter_list(filter_list)
	self._properties.filter_list = filter_list

	self:_generate_id()
end

function EnvironmentArea:prio()
	return self:property("prio")
end

function EnvironmentArea:set_prio(prio)
	if self._properties.prio ~= prio then
		self._properties.prio = prio

		managers.environment_area:prio_order_areas()
	end
end

function EnvironmentArea:is_higher_prio(min_prio)
	if min_prio then
		return self._properties.prio < min_prio
	else
		return true
	end
end
