require("core/lib/utils/dev/ews/CoreFilteredTreePanel")

CoreAnimationStateTreePanel = CoreAnimationStateTreePanel or class(CoreFilteredTreePanel)

function CoreAnimationStateTreePanel:init(parent_frame, unit)
	self.super.init(self, parent_frame)
	self:set_unit(unit)
end

function CoreAnimationStateTreePanel:unit()
	return self._unit
end

function CoreAnimationStateTreePanel:set_unit(unit)
	self._unit = unit

	self:_refresh_tree()
end

function CoreAnimationStateTreePanel:_refresh_tree()
	self:_tree_control():freeze()
	self:_tree_control():clear()

	if self:unit() then
		local state_machine = self:unit():anim_state_machine()

		if state_machine then
			local sorted_states = table.sorted_copy(state_machine:config():states(), function (a, b)
				return a:name():s() < b:name():s()
			end)

			for _, state in ipairs(sorted_states) do
				self:_tree_control():append_path(state:name():s())
			end
		end
	end

	self:_tree_control():thaw()
end
