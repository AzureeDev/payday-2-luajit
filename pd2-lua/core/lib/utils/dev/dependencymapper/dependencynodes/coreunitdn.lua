core:module("CoreUnitDn")
core:import("CoreClass")
core:import("CoreDependencyNode")

UNIT = CoreDependencyNode.UNIT
OBJECT = CoreDependencyNode.OBJECT
MATERIAL_CONFIG = CoreDependencyNode.MATERIAL_CONFIG
CUTSCENE = CoreDependencyNode.CUTSCENE
UnitDependencyNode = UnitDependencyNode or CoreClass.class(CoreDependencyNode.DependencyNodeBase)

function UnitDependencyNode:init(name, get_dn_cb, database)
	self.super.init(self, UNIT, "unit", name, get_dn_cb, database)
end

function UnitDependencyNode:_walkxml2dependencies(xmlnode, deps)
	local node_name = xmlnode:name()

	if node_name == "depends_on" then
		local depends_on_unit = xmlnode:parameter("unit")

		if depends_on_unit ~= nil then
			local dn = self._get_dn({
				name = depends_on_unit,
				type_ = UNIT
			})

			deps:add(dn)

			if dn == nil then
				Application:error("When parsing Unit: " .. self._name .. ", can not locate depends-on-unit: " .. depends_on_unit)
			end
		end

		local depends_on_mc = xmlnode:parameter("material_config")

		if depends_on_mc ~= nil then
			local dn = self._get_dn({
				name = depends_on_mc,
				type_ = MATERIAL_CONFIG
			})

			deps:add(dn)

			if dn == nil then
				Application:error("When parsing Unit: " .. self._name .. ", can not locate depends-on-material_config: " .. depends_on_mc)
			end
		end
	elseif node_name == "model" then
		local object_name = xmlnode:parameter("file")

		if object_name ~= nil then
			local dn = self._get_dn({
				name = object_name,
				type_ = OBJECT
			})

			deps:add(dn)

			if dn == nil then
				Application:error("When parsing Unit: " .. self._name .. ", can not locate object: " .. object_name)
			end
		end
	elseif node_name == "extension" and xmlnode:parameter("name") == "cutscene_data" then
		local cutscene_name = string.gsub(self:name(), "cutscene_", "")
		local dn = self._get_dn({
			name = cutscene_name,
			type_ = CUTSCENE
		})

		deps:add(dn)

		if dn == nil then
			Application:error("When parsing Unit: " .. self._name .. ", can not locate cutscene: " .. cutscene_name)
		end
	end
end
