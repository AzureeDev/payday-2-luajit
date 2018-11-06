core:module("CoreMaterialconfigDn")
core:import("CoreClass")
core:import("CoreDependencyNode")

MATERIAL_CONFIG = CoreDependencyNode.MATERIAL_CONFIG
MATERIALS_FILE = CoreDependencyNode.MATERIALS_FILE
TEXTURE = CoreDependencyNode.TEXTURE
Material_configDependencyNode = Material_configDependencyNode or CoreClass.class(CoreDependencyNode.DependencyNodeBase)

function Material_configDependencyNode:init(name, get_dn_cb, database)
	self.super.init(self, MATERIAL_CONFIG, "material_config", name, get_dn_cb, database)
end

function Material_configDependencyNode:_walkxml2dependencies(xmlnode, deps)
	local mf = self._get_dn({
		name = "Materialsfile",
		type_ = MATERIALS_FILE
	})

	deps:add(mf)

	local node_name = xmlnode:name()

	if node_name ~= "material" then
		local texture_name = xmlnode:parameter("file")

		if texture_name ~= nil then
			local dn = self._get_dn({
				name = texture_name,
				type_ = TEXTURE
			})

			deps:add(dn)

			if dn == nil then
				Application:error("When parsing material: " .. self._name .. ", can not locate texture: " .. texture_name)
			end
		end
	end
end
