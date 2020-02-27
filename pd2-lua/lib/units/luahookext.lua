require("lib/managers/AchievmentManager")

LuaHookExt = LuaHookExt or class()

function LuaHookExt:award(trophy_stat)
	managers.custom_safehouse:award(trophy_stat)
end
