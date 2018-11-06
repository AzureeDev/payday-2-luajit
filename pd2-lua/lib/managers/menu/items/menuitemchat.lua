core:import("CoreMenuItem")

MenuItemChat = MenuItemChat or class(CoreMenuItem.Item)
MenuItemChat.TYPE = "chat"

function MenuItemChat:init(data_node, parameters)
	CoreMenuItem.Item.init(self, data_node, parameters)

	self._type = MenuItemChat.TYPE
end
