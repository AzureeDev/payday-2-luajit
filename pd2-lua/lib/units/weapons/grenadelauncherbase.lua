GrenadeLauncherBase = GrenadeLauncherBase or class(ProjectileWeaponBase)
GrenadeLauncherContinousReloadBase = GrenadeLauncherContinousReloadBase or class(GrenadeLauncherBase)

function GrenadeLauncherContinousReloadBase:init(...)
	GrenadeLauncherContinousReloadBase.super.init(self, ...)

	self._use_shotgun_reload = true
end

function GrenadeLauncherContinousReloadBase:shotgun_shell_data()
	return nil
end
