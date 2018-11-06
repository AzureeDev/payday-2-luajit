core:module("CoreDynamicsLayer")
core:import("CoreDynamicLayer")
core:import("CoreEditorUtils")

DynamicsLayer = DynamicsLayer or class(CoreDynamicLayer.DynamicLayer)

function DynamicsLayer:init(owner)
	local types = CoreEditorUtils.layer_type("dynamics")

	DynamicsLayer.super.init(self, owner, "dynamics", types, "dynamics_layer")

	self._uses_continents = true
end
