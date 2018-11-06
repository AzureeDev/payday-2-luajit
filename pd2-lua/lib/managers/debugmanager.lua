core:module("DebugManager")
core:import("CoreDebugManager")
core:import("CoreClass")

DebugManager = DebugManager or class(CoreDebugManager.DebugManager)

function DebugManager:qa_debug(username)
	self:set_qa_debug_enabled(username, true)
end

function DebugManager:get_qa_debug_enabled()
	return self._qa_debug_enabled
end

function DebugManager:set_qa_debug_enabled(username, enabled)
	enabled = not not enabled
	local cat_print_list = {
		"qa"
	}

	for _, cat in ipairs(cat_print_list) do
		Global.category_print[cat] = enabled
	end

	self._qa_debug_enabled = enabled
end

CoreClass.override_class(CoreDebugManager.DebugManager, DebugManager)
