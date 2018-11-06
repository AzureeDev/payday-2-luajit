core:module("CoreUnitLinkCameraNode")
core:import("CoreTransformCameraNode")
core:import("CoreClass")
core:import("CoreCode")

UnitLinkCameraNode = UnitLinkCameraNode or CoreClass.class(CoreTransformCameraNode.TransformCameraNode)

function UnitLinkCameraNode:init(settings)
	UnitLinkCameraNode.super.init(self, settings)
end

function UnitLinkCameraNode.compile_settings(xml_node, settings)
	UnitLinkCameraNode.super.compile_settings(xml_node, settings)

	local xml_node_children = xml_node:children()

	for xml_child_node in xml_node_children do
		if xml_child_node:name() == "link" then
			assert(xml_child_node:has_parameter("object") and xml_child_node:has_parameter("connection"))

			local object_str = xml_child_node:parameter("object")
			local object = Idstring(object_str)
			local connection_type = xml_child_node:parameter("connection")

			if connection_type == "pos_x" then
				settings.link_x = object
			elseif connection_type == "pos_y" then
				settings.link_y = object
			elseif connection_type == "pos_z" then
				settings.link_z = object
			elseif connection_type == "pos" then
				settings.link_x = object
				settings.link_y = object
				settings.link_z = object
			elseif connection_type == "rot" then
				settings.link_rot = object
			elseif connection_type == "all" then
				settings.link_x = object
				settings.link_y = object
				settings.link_z = object
				settings.link_rot = object
			end
		end
	end
end

function UnitLinkCameraNode:set_unit(unit)
	local settings = self._settings

	if settings.link_x then
		self._link_x = unit:get_object(settings.link_x)
	end

	if settings.link_y then
		self._link_y = unit:get_object(settings.link_y)
	end

	if settings.link_z then
		self._link_z = unit:get_object(settings.link_z)
	end

	if settings.link_rot then
		self._link_rot = unit:get_object(settings.link_rot)
	end

	self._unit = unit
end

function UnitLinkCameraNode:update(t, dt, in_data, out_data)
	local local_position = self._local_position

	if CoreCode.alive(self._unit) then
		local link = self._link_x

		if link then
			mvector3.set_x(local_position, link:position().x)
		end

		link = self._link_y

		if link then
			mvector3.set_y(local_position, link:position().y)
		end

		link = self._link_z

		if link then
			mvector3.set_z(local_position, link:position().z)
		end

		link = self._link_rot

		if link then
			self._local_rotation = link:rotation()
		end
	end

	UnitLinkCameraNode.super.update(self, t, dt, in_data, out_data)
end
