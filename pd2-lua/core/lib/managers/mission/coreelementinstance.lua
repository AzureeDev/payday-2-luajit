core:module("CoreElementInstance")
core:import("CoreMissionScriptElement")

ElementInstanceInput = ElementInstanceInput or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInstanceInput:init(...)
	ElementInstanceInput.super.init(self, ...)

	if self._values.instance_name then
		managers.world_instance:register_input_element(self._values.instance_name, self._values.event, self)
	end
end

function ElementInstanceInput:client_on_executed(...)
end

function ElementInstanceInput:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementInstanceInput.super.on_executed(self, instigator)
end

ElementInstanceOutput = ElementInstanceOutput or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInstanceOutput:init(...)
	ElementInstanceOutput.super.init(self, ...)
end

function ElementInstanceOutput:on_created()
	self._output_elements = managers.world_instance:get_registered_output_event_elements(self._values.instance_name, self._values.event)
end

function ElementInstanceOutput:client_on_executed(...)
end

function ElementInstanceOutput:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._output_elements then
		for _, element in ipairs(self._output_elements) do
			element:on_executed(instigator)
		end
	end

	ElementInstanceOutput.super.on_executed(self, instigator)
end

ElementInstanceInputEvent = ElementInstanceInputEvent or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInstanceInputEvent:init(...)
	ElementInstanceInputEvent.super.init(self, ...)
end

function ElementInstanceInputEvent:on_created()
end

function ElementInstanceInputEvent:client_on_executed(...)
end

function ElementInstanceInputEvent:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.instance then
		local input_elements = managers.world_instance:get_registered_input_elements(self._values.instance, self._values.event)

		if input_elements then
			for _, element in ipairs(input_elements) do
				element:on_executed(instigator)
			end
		end
	elseif self._values.event_list then
		for _, event_list_data in ipairs(self._values.event_list) do
			local input_elements = managers.world_instance:get_registered_input_elements(event_list_data.instance, event_list_data.event)

			if input_elements then
				for _, element in ipairs(input_elements) do
					element:on_executed(instigator)
				end
			end
		end
	end

	ElementInstanceInputEvent.super.on_executed(self, instigator)
end

ElementInstanceOutputEvent = ElementInstanceOutputEvent or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInstanceOutputEvent:init(...)
	ElementInstanceOutputEvent.super.init(self, ...)

	if self._values.instance then
		managers.world_instance:register_output_event_element(self._values.instance, self._values.event, self)
	end

	if self._values.event_list then
		for _, event_list_data in ipairs(self._values.event_list) do
			managers.world_instance:register_output_event_element(event_list_data.instance, event_list_data.event, self)
		end
	end
end

function ElementInstanceOutputEvent:client_on_executed(...)
end

function ElementInstanceOutputEvent:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementInstanceOutputEvent.super.on_executed(self, instigator)
end

ElementInstancePoint = ElementInstancePoint or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInstancePoint:client_on_executed(...)
end

function ElementInstancePoint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self:_create()
	ElementInstancePoint.super.on_executed(self, instigator)
end

function ElementInstancePoint:_create()
	if self._has_created then
		return
	end

	self._has_created = true

	if Network:is_server() then
		self._mission_script:add_save_state_cb(self._id)
	end

	if self._values.instance then
		managers.world_instance:custom_create_instance(self._values.instance, {
			position = self._values.position,
			rotation = self._values.rotation
		})
	elseif Application:editor() then
		managers.editor:output_error("[ElementInstancePoint:_create()] No instance defined in [" .. self._editor_name .. "]")
	end
end

function ElementInstancePoint:save(data)
	data.has_created = self._has_created
end

function ElementInstancePoint:load(data)
	if data.has_created then
		self:_create()
	end
end

ElementInstanceParams = ElementInstanceParams or class(CoreMissionScriptElement.MissionScriptElement)
ElementInstanceSetParams = ElementInstanceSetParams or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInstanceSetParams:init(...)
	ElementInstanceOutputEvent.super.init(self, ...)

	if not self._values.apply_on_execute then
		self:_apply_instance_params()
	end
end

function ElementInstanceSetParams:client_on_executed(...)
	self:on_executed(...)
end

function ElementInstanceSetParams:_apply_instance_params()
	if self._values.instance then
		managers.world_instance:set_instance_params(self._values.instance, self._values.params)
	elseif Application:editor() then
		managers.editor:output_error("[ElementInstanceSetParams:_apply_instance_params()] No instance defined in [" .. self._editor_name .. "]")
	end
end

function ElementInstanceSetParams:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.apply_on_execute then
		self:_apply_instance_params()
	end

	ElementInstanceSetParams.super.on_executed(self, instigator)
end
