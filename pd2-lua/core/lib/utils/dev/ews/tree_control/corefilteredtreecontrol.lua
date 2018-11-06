require("core/lib/utils/dev/ews/tree_control/CoreManagedTreeControl")
require("core/lib/utils/dev/ews/tree_control/CoreTreeNode")

CoreFilteredTreeControl = CoreFilteredTreeControl or class(CoreManagedTreeControl)

function CoreFilteredTreeControl:init(parent_frame, styles)
	self.super.init(self, parent_frame, styles)

	self._virtual_root_node = CoreTreeNode:new()

	self._virtual_root_node:set_callback("on_append", callback(self, self, "_on_node_appended"))
	self._virtual_root_node:set_callback("on_remove", callback(self, self, "_on_node_removed"))

	self._filters = {}
	self._freeze_count = 0
end

function CoreFilteredTreeControl:add_filter(predicate)
	table.insert(self._filters, predicate)
	self:refresh_tree()

	return predicate
end

function CoreFilteredTreeControl:remove_filter(predicate)
	table.delete(self._filters, predicate)
	self:refresh_tree()
end

function CoreFilteredTreeControl:refresh_tree()
	if self._freeze_count ~= 0 then
		return
	end

	self:freeze()
	self:_view_tree_root():remove_children()

	local function append_to_visible_tree(child)
		if self:_node_passes_filters(child) then
			self:_view_tree_root():append_path(child:path())
		end

		return true
	end

	self:_tree_root():for_each_child(append_to_visible_tree, true)
	self:thaw(true)
end

function CoreFilteredTreeControl:_node_passes_filters(node)
	for _, predicate in ipairs(self._filters) do
		if not predicate(node) then
			return false
		end
	end

	return true
end

function CoreFilteredTreeControl:_on_node_appended(new_node)
	local visible_parent_node = self:_view_tree_root()

	if new_node:parent() then
		visible_parent_node = self:_view_tree_root():child_at_path(new_node:parent():path())
	end

	if visible_parent_node and self:_node_passes_filters(new_node) then
		visible_parent_node:append_copy_of_node(new_node)
	end
end

function CoreFilteredTreeControl:_on_node_removed(removed_node)
	local visible_node = self:_view_tree_root():child_at_path(removed_node:path())

	if visible_node then
		visible_node:remove()
	end
end

function CoreFilteredTreeControl:clear()
	self.super.clear(self)
	self:refresh_tree()
end

function CoreFilteredTreeControl:_tree_root()
	return self._virtual_root_node
end

function CoreFilteredTreeControl:freeze()
	if self._freeze_count == 0 then
		self.super.freeze(self)
	end

	self._freeze_count = self._freeze_count + 1
end

function CoreFilteredTreeControl:thaw(already_refreshed)
	self._freeze_count = self._freeze_count - 1

	if self._freeze_count == 0 then
		if not already_refreshed then
			self:refresh_tree()
		end

		self.super.thaw(self)
	end
end
