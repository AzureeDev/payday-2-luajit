local enum = 0

local function set_enum()
	enum = enum + 1

	return enum
end

EditorMessage = {}
EditorMessage.OnUnitRemoved = set_enum()
EditorMessage.OnUnitRestored = set_enum()

