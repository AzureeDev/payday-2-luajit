if Application == nil then
	Application = setmetatable({}, {})

	function Application:ews_enabled()
		return false
	end
end

if Global == nil then
	Global = setmetatable({}, {})
end

Global.category_print = Global.category_print or {}
Global.category_print_initialized = Global.category_print_initialized or {}

require("core/lib/system/CorePatchLua")
require("core/lib/system/CorePatchEngine")
require("core/lib/system/CoreModule")
require("core/lib/system/CoreModules")
core:import("CoreExtendLua")

managers = managers or {}

core:_add_to_pristine_and_global("managers", managers)
core:_copy_module_to_global("CoreClass")
core:_copy_module_to_global("CoreCode")
core:_copy_module_to_global("CoreDebug")
core:_copy_module_to_global("CoreEvent")
core:_copy_module_to_global("CoreEws")
core:_copy_module_to_global("CoreInput")
core:_copy_module_to_global("CoreMath")
core:_copy_module_to_global("CoreOldModule")
core:_copy_module_to_global("CoreString")
core:_copy_module_to_global("CoreTable")
core:_copy_module_to_global("CoreUnit")
core:_copy_module_to_global("CoreXml")
core:_copy_module_to_global("CoreApp")
core:_close_pristine_namespace()
core:import("CoreDatabaseManager")

managers.database = managers.database or CoreDatabaseManager.DatabaseManager:new()
