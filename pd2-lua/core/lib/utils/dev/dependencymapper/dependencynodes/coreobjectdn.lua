core:module("CoreObjectDn")
core:import("CoreClass")
core:import("CoreDependencyNode")

OBJECT = CoreDependencyNode.OBJECT
MODEL = CoreDependencyNode.MODEL
MATERIAL_CONFIG = CoreDependencyNode.MATERIAL_CONFIG
ObjectDependencyNode = ObjectDependencyNode or CoreClass.class(CoreDependencyNode.DependencyNodeBase)

function ObjectDependencyNode:init(name, get_dn_cb, database)
	self.super.init(self, OBJECT, "object", name, get_dn_cb, database)
end

function ObjectDependencyNode:_walkxml2dependencies(xmlnode, deps)
	local node_name = xmlnode:name()

	if node_name == "diesel" then
		local materials_name = xmlnode:parameter("materials")

		if materials_name ~= nil then
			local dn = self._get_dn({
				name = materials_name,
				type_ = MATERIAL_CONFIG
			})

			deps:add(dn)

			if dn == nil then
				Application:error("When parsing object: " .. self._name .. ", can not locate material_config: " .. materials_name)
			end
		end

		local diesel_file = xmlnode:parameter("file")

		if diesel_file ~= nil then
			local dn = self._get_dn({
				name = diesel_file,
				type_ = MODEL
			})

			deps:add(dn)

			if dn == nil then
				Application:error("When parsing object: " .. self._name .. ", can not locate model: " .. diesel_file)
			end
		end
	end
end
