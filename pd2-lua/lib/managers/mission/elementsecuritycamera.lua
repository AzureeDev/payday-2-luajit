core:import("CoreMissionScriptElement")

ElementSecurityCamera = ElementSecurityCamera or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSecurityCamera:init(...)
	ElementSecurityCamera.super.init(self, ...)

	self._triggers = {}
end

function ElementSecurityCamera:on_executed(instigator)
	if not self._values.enabled or Network:is_client() then
		return
	end

	if not self._values.camera_u_id then
		return
	end

	local camera_unit = self:_fetch_unit_by_unit_id(self._values.camera_u_id)

	if not camera_unit then
		return
	end

	local ai_state = self._values.ai_enabled and true or false
	local settings = nil

	if ai_state or self._values.apply_settings then
		settings = {
			yaw = self._values.yaw,
			pitch = self._values.pitch,
			fov = self._values.fov,
			detection_range = self._values.detection_range * 100,
			suspicion_range = self._values.suspicion_range * 100,
			detection_delay = {
				self._values.detection_delay_min,
				self._values.detection_delay_max
			}
		}
	end

	camera_unit:base():set_detection_enabled(ai_state, settings, self)
	ElementSpecialObjective.super.on_executed(self, instigator)
end

function ElementSecurityCamera:client_on_executed(...)
end

function ElementSecurityCamera:_fetch_unit_by_unit_id(unit_id)
	local unit = nil

	if Application:editor() then
		unit = managers.editor:unit_with_id(tonumber(unit_id))
	else
		unit = managers.worlddefinition:get_unit_on_load(tonumber(unit_id), callback(self, self, "_load_unit"))
	end

	return unit
end

function ElementSecurityCamera._load_unit(unit)
end

function ElementSecurityCamera:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

function ElementSecurityCamera:on_destroyed()
	if not self._values.enabled then
		return
	end

	self._values.destroyed = true

	self:check_triggers("destroyed")
end

function ElementSecurityCamera:on_alarm()
	if not self._values.enabled then
		return
	end

	self._values.alarm = true

	self:check_triggers("alarm")
end

function ElementSecurityCamera:add_trigger(id, type, callback)
	self._triggers[type] = self._triggers[type] or {}
	self._triggers[type][id] = {
		callback = callback
	}
end

function ElementSecurityCamera:remove_trigger(id, type)
	if self._triggers[type] then
		self._triggers[type][id] = nil
	end
end

function ElementSecurityCamera:check_triggers(type, instigator)
	if not self._triggers[type] then
		return
	end

	for id, cb_data in pairs(self._triggers[type]) do
		cb_data.callback(instigator)
	end
end

function ElementSecurityCamera:save(data)
	data.enabled = self._values.enabled
	data.destroyed = self._values.destroyed
end

function ElementSecurityCamera:load(data)
	self:set_enabled(data.enabled)

	self._values.destroyed = data.destroyed
end
