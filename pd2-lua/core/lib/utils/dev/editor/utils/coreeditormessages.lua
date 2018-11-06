local enum = 0

local function set_enum()
	enum = enum + 1

	return enum
end

EditorMessage = {
	OnUnitRemoved = set_enum(),
	OnUnitRestored = set_enum()
}
