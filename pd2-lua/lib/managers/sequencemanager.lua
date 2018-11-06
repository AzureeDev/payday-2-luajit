core:module("SequenceManager")
core:import("CoreSequenceManager")
core:import("CoreClass")

SequenceManager = SequenceManager or class(CoreSequenceManager.SequenceManager)

function SequenceManager:init()
	SequenceManager.super.init(self, managers.slot:get_mask("body_area_damage"), managers.slot:get_mask("area_damage_blocker"), managers.slot:get_mask("unit_area_damage"))
	self:register_event_element_class(InteractionElement)

	self._proximity_masks.players = managers.slot:get_mask("players")
end

InteractionElement = InteractionElement or class(CoreSequenceManager.BaseElement)
InteractionElement.NAME = "interaction"

function InteractionElement:init(node, unit_element)
	InteractionElement.super.init(self, node, unit_element)

	self._enabled = self:get("enabled")
end

function InteractionElement:activate_callback(env)
	local enabled = self:run_parsed_func(env, self._enabled)

	if env.dest_unit:interaction() then
		env.dest_unit:interaction():set_active(enabled)
	else
		Application:error("Unit " .. tostring(env.dest_unit:name()) .. " doesn't have the interaction extension.")
	end
end

CoreClass.override_class(CoreSequenceManager.SequenceManager, SequenceManager)
