core:module("CoreCutsceneDn")
core:import("CoreClass")
core:import("CoreDependencyNode")

UNIT = CoreDependencyNode.UNIT
CUTSCENE = CoreDependencyNode.CUTSCENE
CutsceneDependencyNode = CutsceneDependencyNode or CoreClass.class(CoreDependencyNode.DependencyNodeBase)

function CutsceneDependencyNode:init(name, get_dn_cb, database)
	self.super.init(self, CUTSCENE, "cutscene", name, get_dn_cb, database)
end

function CutsceneDependencyNode:_walkxml2dependencies(xmlnode, deps)
	local node_name = xmlnode:name()

	if node_name == "unit" then
		local unit_name = xmlnode:parameter("type")

		if unit_name ~= nil then
			local dn = self._get_dn({
				name = unit_name,
				type_ = UNIT
			})

			deps:add(dn)

			if dn == nil then
				Application:error("When parsing cutscene: " .. self._name .. ", can not locate unit: " .. unit_name)
			end
		end
	elseif node_name == "spawn_unit" then
		local unit_name = xmlnode:parameter("unit_type")

		if unit_name ~= nil then
			local dn = self._get_dn({
				name = unit_name,
				type_ = UNIT
			})

			deps:add(dn)

			if dn == nil then
				Application:error("When parsing cutscene: " .. self._name .. ", can not locate unit: " .. unit_name)
			end
		end
	end
end
