MenuNodeHiddenGui = MenuNodeHiddenGui or class(MenuNodeGui)

function MenuNodeHiddenGui:_create_menu_item(row_item)
	MenuNodeHiddenGui.super._create_menu_item(self, row_item)
	row_item.gui_panel:hide()
end
