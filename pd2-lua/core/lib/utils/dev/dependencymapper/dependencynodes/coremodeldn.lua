core:module("CoreModelDn")
core:import("CoreClass")
core:import("CoreDependencyNode")

MODEL = CoreDependencyNode.MODEL
ModelDependencyNode = ModelDependencyNode or CoreClass.class(CoreDependencyNode.DependencyNodeBase)

function ModelDependencyNode:init(name, get_dn_cb, database)
	self.super.init(self, MODEL, "model", name, get_dn_cb, database)
end

function ModelDependencyNode:_parse()
	return {}
end
