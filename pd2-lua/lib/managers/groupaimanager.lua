require("lib/managers/group_ai_states/GroupAIStateBase")
require("lib/managers/group_ai_states/GroupAIStateEmpty")
require("lib/managers/group_ai_states/GroupAIStateBesiege")
require("lib/managers/group_ai_states/GroupAIStateStreet")

GroupAIManager = GroupAIManager or class()

function GroupAIManager:init()
	self:set_state("empty")

	self._event_listener_holder = EventListenerHolder:new()
end

function GroupAIManager:add_event_listener(...)
	self._event_listener_holder:add(...)
end

function GroupAIManager:remove_event_listener(...)
	self._event_listener_holder:remove(...)
end

function GroupAIManager:dispatch_event(...)
	self._event_listener_holder:call(...)
end

function GroupAIManager:update(t, dt)
	self._state:update(t, dt)
end

function GroupAIManager:paused_update(t, dt)
	self._state:paused_update(t, dt)
end

function GroupAIManager:set_state(name)
	if name == "empty" then
		self._state = GroupAIStateEmpty:new()
	elseif name == "street" then
		self._state = GroupAIStateStreet:new()
	elseif name == "besiege" or name == "airport" or name == "zombie_apocalypse" then
		local level_tweak = managers.job:current_level_data()
		self._state = GroupAIStateBesiege:new(level_tweak and level_tweak.group_ai_state or "besiege")
	else
		Application:error("[GroupAIManager:set_state] inexistent state name", name)

		return
	end

	self._state_name = name
end

function GroupAIManager:state()
	return self._state
end

function GroupAIManager:state_name()
	return self._state_name
end

function GroupAIManager:state_names()
	return {
		"empty",
		"airport",
		"besiege",
		"street",
		"zombie_apocalypse"
	}
end

function GroupAIManager:on_simulation_started()
	self:set_state(self:state_name())
end

function GroupAIManager:on_simulation_ended()
	self._state:on_simulation_ended()
end

function GroupAIManager:visualization_enabled()
	return self._state._draw_enabled
end
