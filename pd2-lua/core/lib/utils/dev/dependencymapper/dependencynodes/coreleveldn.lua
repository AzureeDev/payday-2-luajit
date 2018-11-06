core:module("CoreLevelDn")
core:import("CoreClass")
core:import("CoreDependencyNode")

LEVEL = CoreDependencyNode.LEVEL
UNIT = CoreDependencyNode.UNIT
LEVEL_BASE = "./data/levels/"
LEVEL_FILE = "./data/levels/%s/world.xml"
MISSION_FILE = "./data/levels/%s/mission.xml"
LEVEL_CONVERT = {
	player_start = "player"
}
LEVEL_SKIP = {
	unit_sequence = true,
	hub = true,
	environment_effect = true,
	worldcamera_trigger = true,
	cubemap_gizmo = true,
	music = true,
	music_mode = true,
	he_rumble = true,
	play_effect = true,
	physicspush = true,
	worldcamera = true,
	unit_sequence_trigger = true,
	area = true
}
LevelDependencyNode = LevelDependencyNode or CoreClass.class(CoreDependencyNode.DependencyNodeBase)

function LevelDependencyNode:init(name, get_dn_cb, database)
	self.super.init(self, LEVEL, nil, name, get_dn_cb, database)
end

function LevelDependencyNode:_parse()
	local file = string.format(LEVEL_FILE, self._name)
	local f = File:open(file, "r")
	local level_node = Node.from_xml(f:read())

	f:close()

	local file = string.format(MISSION_FILE, self._name)
	local f = File:open(file, "r")
	local mission_node = Node.from_xml(f:read())

	f:close()

	return {
		level_node,
		mission_node
	}
end

function LevelDependencyNode:_walkxml2dependencies(xmlnode, deps)
	local node_name = xmlnode:name()

	if node_name == "unit" then
		local unit_name = xmlnode:parameter("name")

		if unit_name ~= nil and not LEVEL_SKIP[unit_name] then
			unit_name = LEVEL_CONVERT[unit_name] or unit_name
			local dn = self._get_dn({
				name = unit_name,
				type_ = UNIT
			})

			deps:add(dn)

			if dn == nil then
				Application:error("When parsing Level: " .. self._name .. ", can not locate Unit: " .. unit_name)
			end
		end
	elseif node_name == "enemy" then
		local unit_name = xmlnode:parameter("name")

		if unit_name ~= nil then
			local dn = self._get_dn({
				name = unit_name,
				type_ = UNIT
			})

			deps:add(dn)

			if dn == nil then
				Application:error("When parsing Level: " .. self._name .. ", can not locate enemy-unit: " .. unit_name)
			end
		end
	end
end
