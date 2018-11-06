core:module("CoreGameDn")
core:import("CoreClass")
core:import("CoreDependencyNode")

GAME = CoreDependencyNode.GAME
LEVEL = CoreDependencyNode.LEVEL
LEVELS_FILE = "./dev/build_info/levels.xml"
GameDependencyNode = GameDependencyNode or CoreClass.class(CoreDependencyNode.DependencyNodeBase)

function GameDependencyNode:init(name, get_dn_cb, database)
	self.super.init(self, GAME, nil, name, get_dn_cb, database)
end

function GameDependencyNode:_parse()
	local f = File:open(LEVELS_FILE, "r")
	local xmlnode = Node.from_xml(f:read())

	f:close()

	return {
		xmlnode
	}
end

function GameDependencyNode:_walkxml2dependencies(xmlnode, deps)
	local node_name = xmlnode:name()
	local name = xmlnode:parameter("name")

	if node_name == "level" and name ~= nil then
		local name = string.gsub(name, "_stage%d", "")
		local dn = self._get_dn({
			name = name,
			type_ = LEVEL
		})

		deps:add(dn)

		if dn == nil then
			Application:error("When parsing levels.xml, can not find Level: " .. name)
		end
	end
end
