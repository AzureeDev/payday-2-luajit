local enum = 0

local function set_enum()
	enum = enum + 1

	return enum
end

ArmSetting = {
	SET_ARM_ANIMATOR_ENABLED = set_enum(),
	SET_ARM_ANIMATOR_PRESENT = set_enum()
}
