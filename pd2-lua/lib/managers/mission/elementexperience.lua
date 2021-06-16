core:import("CoreMissionScriptElement")

ElementExperience = ElementExperience or class(CoreMissionScriptElement.MissionScriptElement)

function ElementExperience:init(...)
	ElementExperience.super.init(self, ...)
end

function ElementExperience:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
	ElementExperience.super.on_script_activated(self)
end

function ElementExperience:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	managers.experience:mission_xp_award(self._values.amount)
	ElementExperience.super.on_executed(self, instigator)
end

function ElementExperience:client_on_executed(...)
	self:on_executed(...)
end

function ElementExperience:save(data)
	data.save_me = true
	data.enabled = self._values.enabled
end

function ElementExperience:load(data)
	self:set_enabled(data.enabled)
end
