core:import("CoreMenuNodeGui")

MenuNodeKitGui = MenuNodeKitGui or class(MenuNodeGui)

function MenuNodeKitGui:init(node, layer, parameters)
	MenuNodeKitGui.super.init(self, node, layer, parameters)
end

function MenuNodeKitGui:_setup_item_panel_parent(safe_rect, shape)
	MenuNodeKitGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeKitGui:_update_scaled_values()
	MenuNodeKitGui.super._update_scaled_values(self)

	self.font_size = tweak_data.menu.kit_default_font_size
end

function MenuNodeKitGui:resolution_changed()
	self:_update_scaled_values()
	MenuNodeKitGui.super.resolution_changed(self)
end
