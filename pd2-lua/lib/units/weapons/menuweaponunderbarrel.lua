WeaponUnderbarrel = WeaponUnderbarrel or class(WeaponGadgetBase)

function WeaponUnderbarrel:init(...)
	WeaponUnderbarrel.super.init(self, ...)
end

WeaponUnderbarrelLauncher = WeaponUnderbarrelLauncher or class(WeaponUnderbarrel)
WeaponUnderbarrelRaycast = WeaponUnderbarrelRaycast or class(WeaponUnderbarrel)
WeaponUnderbarrelShotgunRaycast = WeaponUnderbarrelShotgunRaycast or class(WeaponUnderbarrelRaycast)
