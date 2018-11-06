core:import("CoreMenuItem")

MenuItemLevel = MenuItemLevel or class(CoreMenuItem.Item)
MenuItemLevel.TYPE = "level"

function MenuItemLevel:init(data_node, parameters)
	CoreMenuItem.Item.init(self, data_node, parameters)

	self._type = MenuItemLevel.TYPE
end
