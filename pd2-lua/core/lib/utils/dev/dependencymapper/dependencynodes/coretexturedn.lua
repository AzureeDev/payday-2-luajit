core:module("CoreTextureDn")
core:import("CoreClass")
core:import("CoreDependencyNode")

TEXTURE = CoreDependencyNode.TEXTURE
TextureDependencyNode = TextureDependencyNode or CoreClass.class(CoreDependencyNode.DependencyNodeBase)

function TextureDependencyNode:init(name, get_dn_cb, database)
	self.super.init(self, TEXTURE, "texture", name, get_dn_cb, database)
end

function TextureDependencyNode:_parse()
	return {}
end
