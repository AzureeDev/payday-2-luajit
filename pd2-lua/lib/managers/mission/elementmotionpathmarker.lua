core:import("CoreMissionScriptElement")

ElementMotionpathMarker = ElementMotionpathMarker or class(CoreMissionScriptElement.MissionScriptElement)

function ElementMotionpathMarker:init(...)
	ElementMotionpathMarker.super.init(self, ...)

	self._network_execute = true

	if self._values.icon == "guis/textures/VehicleMarker" then
		self._values.icon = "wp_standard"
	end
end

function ElementMotionpathMarker:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

function ElementMotionpathMarker:client_on_executed(...)
	self:on_executed(...)
end

function ElementMotionpathMarker:on_executed(instigator)
	ElementMotionpathMarker.super.on_executed(self, instigator)
end

function ElementMotionpathMarker:operation_remove()
end

function ElementMotionpathMarker:save(data)
	data.enabled = self._values.enabled
	data.motion_state = self._values.motion_state
end

function ElementMotionpathMarker:load(data)
	self:set_enabled(data.enabled)

	self._values.motion_state = data.motion_state
end

function ElementMotionpathMarker:add_trigger(trigger_id, outcome, callback)
	managers.motion_path:add_trigger(self._id, self._values.path_id, trigger_id, outcome, callback)
end

function ElementMotionpathMarker:motion_operation_goto_marker(checkpoint_marker_id, goto_marker_id)
	managers.motion_path:operation_goto_marker(checkpoint_marker_id, goto_marker_id)
end

function ElementMotionpathMarker:motion_operation_teleport_to_marker(checkpoint_marker_id, teleport_to_marker_id)
	managers.motion_path:operation_teleport_to_marker(checkpoint_marker_id, teleport_to_marker_id)
end

function ElementMotionpathMarker:motion_operation_set_motion_state(state)
	self._values.motion_state = state
end

function ElementMotionpathMarker:motion_operation_set_rotation(operator_id)
	managers.motion_path:operation_set_unit_target_rotation(self._id, operator_id)
end
