require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")

CoreUnitVisibleCutsceneKey = CoreUnitVisibleCutsceneKey or class(CoreCutsceneKeyBase)
CoreUnitVisibleCutsceneKey.ELEMENT_NAME = "unit_visible"
CoreUnitVisibleCutsceneKey.NAME = "Unit Visibility"

CoreUnitVisibleCutsceneKey:register_serialized_attribute("unit_name", "")
CoreUnitVisibleCutsceneKey:register_serialized_attribute("visible", true, toboolean)

function CoreUnitVisibleCutsceneKey:__tostring()
	return (self:visible() and "Show" or "Hide") .. " \"" .. self:unit_name() .. "\"."
end

function CoreUnitVisibleCutsceneKey:unload()
	if self._cast then
		self:play(nil, true)
	end
end

function CoreUnitVisibleCutsceneKey:play(player, undo, fast_forward)
	assert(type(self.evaluate) == "function", "Cutscene key must define the \"evaluate\" method to use the default CoreCutsceneKeyBase:play method.")

	if undo then
		local preceeding_key = self:preceeding_key({
			unit_name = self:unit_name()
		})

		if preceeding_key then
			preceeding_key:evaluate(player, false)
		else
			self:evaluate(player, false, true)
		end
	else
		self:evaluate(player, fast_forward)
	end
end

function CoreUnitVisibleCutsceneKey:evaluate(player, fast_forward, visible)
	assert(self._cast)

	visible = visible or self:visible()
	local cast_member = self._cast:unit(self:unit_name())

	if cast_member then
		self._cast:set_unit_visible(self:unit_name(), visible)
	else
		local unit_in_world = self:_unit(self:unit_name(), true)

		if unit_in_world then
			set_unit_and_children_visible(unit_in_world, visible)
		end
	end
end
