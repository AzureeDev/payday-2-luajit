core:module("CoreInputContextFeeder")
core:import("CoreInputProvider")

Feeder = Feeder or class()

function Feeder:init(engine_controller, input_layer_descriptions)
	self._engine_controller = engine_controller
	self._device_type = self._engine_controller:type()
	self._input_provider = CoreInputProvider.Provider:new(input_layer_descriptions)
	self._previous_state = {}
end

function Feeder:input_provider()
	return self._input_provider
end

function Feeder:update(t, dt)
	local target_input_context = self._input_provider:context()

	if not target_input_context then
		return
	end

	local context_description = target_input_context:_context_description()
	local device_layout_description = context_description:device_layout_description(self._device_type)

	if device_layout_description == nil then
		return
	end

	local binds = device_layout_description:binds()
	local input_data = target_input_context:input()
	local controller = self._engine_controller

	for hardware_name, bind in pairs(binds) do
		local input_data_name = bind.input_target_description:target_name()
		local control_type = bind.type_name
		local data = nil

		if control_type == "axis" then
			assert(controller:has_axis(Idstring(hardware_name)), "Binding '" .. hardware_name .. "'")

			data = controller:axis(Idstring(hardware_name))
		elseif control_type == "button" then
			assert(controller:has_button(Idstring(hardware_name)), "Binding '" .. hardware_name .. "'")

			data = controller:pressed(Idstring(hardware_name))
		else
			error("Bad!")
		end

		input_data[input_data_name] = data
	end
end
