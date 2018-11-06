require("core/lib/utils/dev/ews/tree_control/CoreBaseTreeNode")

CoreEWSTreeCtrlTreeNode = CoreEWSTreeCtrlTreeNode or class(CoreBaseTreeNode)

function CoreEWSTreeCtrlTreeNode:init(ews_tree_ctrl, item_id, checkbox_style)
	self._checkbox_style = checkbox_style
	self._tree_ctrl = assert(ews_tree_ctrl, "nil argument supplied as ews_tree_ctrl")
	self._item_id = assert(item_id, "nil argument supplied as item_id")

	self:set_state(0)
end

function CoreEWSTreeCtrlTreeNode:id()
	return self._item_id
end

function CoreEWSTreeCtrlTreeNode:expand(recurse)
	self._tree_ctrl:expand(self._item_id)

	if recurse then
		for _, child in ipairs(self:children()) do
			child:expand(true)
		end
	end
end

function CoreEWSTreeCtrlTreeNode:collapse(recurse)
	self._tree_ctrl:collapse(self._item_id)

	if recurse then
		for _, child in ipairs(self:children()) do
			child:collapse(true)
		end
	end
end

function CoreEWSTreeCtrlTreeNode:set_selected(state)
	if state == nil then
		state = true
	end

	self._tree_ctrl:select_item(self._item_id, state)
end

function CoreEWSTreeCtrlTreeNode:state(state)
	if self._checkbox_style then
		return self._tree_ctrl:get_item_image(self._item_id, "NORMAL")
	else
		return 0
	end
end

function CoreEWSTreeCtrlTreeNode:set_state(state)
	if self._checkbox_style then
		self:_change_state(state)
	end
end

function CoreEWSTreeCtrlTreeNode:checkbox_style()
	return self._checkbox_style
end

function CoreEWSTreeCtrlTreeNode:set_checkbox_style(style)
	self._checkbox_style = style
end

function CoreEWSTreeCtrlTreeNode:set_image(image, item_state)
	self._tree_ctrl:set_item_image(self._item_id, image, item_state or "NORMAL")
end

function CoreEWSTreeCtrlTreeNode:get_image(item_state)
	return self._tree_ctrl:get_item_image(self._item_id, item_state or "NORMAL")
end

function CoreEWSTreeCtrlTreeNode:_change_state(state)
	self._tree_ctrl:set_item_image(self._item_id, state, "NORMAL")
end

function CoreEWSTreeCtrlTreeNode:text()
	return self._tree_ctrl:get_item_text(self._item_id)
end

function CoreEWSTreeCtrlTreeNode:parent()
	local parent_id = self._tree_ctrl:get_parent(self._item_id)

	if parent_id ~= -1 and self._tree_ctrl:get_parent(parent_id) ~= -1 then
		return CoreEWSTreeCtrlTreeNode:new(self._tree_ctrl, parent_id, self._checkbox_style)
	end
end

function CoreEWSTreeCtrlTreeNode:children()
	return table.collect(self._tree_ctrl:get_children(self._item_id), function (child_id)
		return CoreEWSTreeCtrlTreeNode:new(self._tree_ctrl, child_id, self._checkbox_style)
	end)
end

function CoreEWSTreeCtrlTreeNode:append(text)
	return CoreEWSTreeCtrlTreeNode:new(self._tree_ctrl, self._tree_ctrl:append(self._item_id, text), self._checkbox_style)
end

function CoreEWSTreeCtrlTreeNode:remove()
	self._tree_ctrl:remove(self._item_id)
end

function CoreEWSTreeCtrlTreeNode:has_children()
	return table.getn(self._tree_ctrl:get_children(self._item_id)) > 0
end
