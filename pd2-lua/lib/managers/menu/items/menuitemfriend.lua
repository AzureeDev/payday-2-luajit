core:import("CoreMenuItem")

MenuItemFriend = MenuItemFriend or class(CoreMenuItem.Item)
MenuItemFriend.TYPE = "friend"

function MenuItemFriend:init(data_node, parameters)
	CoreMenuItem.Item.init(self, data_node, parameters)

	self._type = MenuItemFriend.TYPE
end
