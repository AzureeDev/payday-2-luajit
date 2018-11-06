ScriptLocations = ScriptLocations or class()

function ScriptLocations:init(unit)
end

function ScriptLocations:setup(callback)
	if callback then
		self._unit:set_extension_update_enabled("roaming_data", true)
	else
		self._unit:set_extension_update_enabled("roaming_data", false)
	end

	self._updator = callback
end
