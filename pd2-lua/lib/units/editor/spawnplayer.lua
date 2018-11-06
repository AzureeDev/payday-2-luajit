SpawnPlayerHubElement = SpawnPlayerHubElement or class(HubElement)

function SpawnPlayerHubElement:init(unit)
	HubElement.init(self, unit)
	table.insert(self._save_values, "unit:position")
	table.insert(self._save_values, "unit:rotation")
end
