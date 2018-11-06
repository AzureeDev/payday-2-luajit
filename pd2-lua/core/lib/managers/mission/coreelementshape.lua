local tmp_vec1 = Vector3()

core:module("CoreElementShape")
core:import("CoreShapeManager")
core:import("CoreMissionScriptElement")
core:import("CoreTable")

ElementShape = ElementShape or class(CoreMissionScriptElement.MissionScriptElement)

function ElementShape:init(...)
	ElementShape.super.init(self, ...)

	self._shapes = {}

	if not self._values.shape_type or self._values.shape_type == "box" then
		self:_add_shape(CoreShapeManager.ShapeBoxMiddle:new({
			position = self._values.position,
			rotation = self._values.rotation,
			width = self._values.width,
			depth = self._values.depth,
			height = self._values.height
		}))
	elseif self._values.shape_type == "cylinder" then
		self:_add_shape(CoreShapeManager.ShapeCylinderMiddle:new({
			position = self._values.position,
			rotation = self._values.rotation,
			height = self._values.height,
			radius = self._values.radius
		}))
	end
end

function ElementShape:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

function ElementShape:_add_shape(shape)
	table.insert(self._shapes, shape)
end

function ElementShape:get_shapes()
	return self._shapes
end

function ElementShape:is_inside(pos)
	for _, shape in ipairs(self._shapes) do
		if shape:is_inside(pos) then
			return true
		end
	end

	return false
end

function ElementShape:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementShape.super.on_executed(self, instigator)
end

function ElementShape:save(data)
	data.enabled = self._values.enabled
end

function ElementShape:load(data)
	self:set_enabled(data.enabled)
end
