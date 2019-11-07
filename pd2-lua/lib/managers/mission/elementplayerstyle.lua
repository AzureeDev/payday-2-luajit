core:import("CoreMissionScriptElement")

ElementPlayerStyle = ElementPlayerStyle or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPlayerStyle:init(...)
	ElementPlayerStyle.super.init(self, ...)
end

function ElementPlayerStyle:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

function ElementPlayerStyle:client_on_executed(...)
	self:on_executed(...)
end

function ElementPlayerStyle:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self:_trigger_sequence()

	self._is_activated = true

	ElementPlayerStyle.super.on_executed(self, instigator)
end

function ElementPlayerStyle:save(data)
	data.activated = self._is_activated
end

function ElementPlayerStyle:load(data)
	if data.activated then
		self:_trigger_sequence()
	end
end

function ElementPlayerStyle:_trigger_sequence()
	if managers.criminals then
		managers.criminals:set_active_player_style(self._values.style)
	end
end
