core:module("CoreInputManager")
core:import("CoreInputContextFeeder")
core:import("CoreInputSettingsReader")

InputManager = InputManager or class()

function InputManager:init()
	local settings_reader = CoreInputSettingsReader.SettingsReader:new()
	self._layer_descriptions = settings_reader:layer_descriptions()
	self._feeders = {}
	self._input_provider_to_feeder = {}
end

function InputManager:destroy()
end

function InputManager:update(t, dt)
	for _, feeder in pairs(self._feeders) do
		feeder:update()
	end
end

function InputManager:input_provider_id_that_presses_start()
	local layer_description_ids = {}
	local count = Input:num_real_controllers()

	for i = 1, count do
		local controller = Input:controller(i)

		if controller:connected() and controller:pressed(Idstring("start")) then
			table.insert(layer_description_ids, controller)
		end
	end

	return layer_description_ids
end

function InputManager:debug_primary_input_provider_id()
	local count = Input:num_real_controllers()
	local best_controller = nil

	for i = 1, count do
		local controller = Input:controller(i)

		if controller:connected() then
			if controller:type() == "xbox360" then
				best_controller = controller

				break
			elseif best_controller == nil then
				best_controller = controller
			end
		end
	end

	assert(best_controller, "You need at least one compatible controller plugged in")

	return best_controller
end

function InputManager:_create_input_provider_for_controller(engine_controller)
	local feeder = CoreInputContextFeeder.Feeder:new(engine_controller, self._layer_descriptions)
	local input_provider = feeder:input_provider()
	self._input_provider_to_feeder[input_provider] = feeder
	self._feeders[feeder] = feeder

	return input_provider
end

function InputManager:_destroy_input_provider(input_provider)
	local feeder = self._input_provider_to_feeder[input_provider]
	self._feeders[feeder] = nil
end
