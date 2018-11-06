require("lib/managers/menu/renderers/MenuNodeBaseGui")

MenuNodeJukeboxGui = MenuNodeJukeboxGui or class(MenuNodeBaseGui)

function MenuNodeJukeboxGui:init(node, layer, parameters)
	parameters.align = "left"
	parameters._align_line_proportions = 0.5

	MenuNodeJukeboxGui.super.init(self, node, layer, parameters)
	self.item_panel:set_y(self.item_panel:parent():y() + 165)
	self:_set_topic_position()

	node:parameters().block_back = true
	node:parameters().allow_pause_menu = true
end

function MenuNodeJukeboxGui:close()
	MenuNodeJukeboxGui.super.close(self)
end
