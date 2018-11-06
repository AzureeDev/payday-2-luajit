AkimboShotgunBase = AkimboShotgunBase or class(AkimboWeaponBase)

function AkimboShotgunBase:init(...)
	AkimboShotgunBase.super.init(self, ...)
	self:setup_default()
end

function AkimboShotgunBase:setup_default()
	ShotgunBase.setup_default(self)
end

function AkimboShotgunBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	return ShotgunBase._fire_raycast(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
end

function AkimboShotgunBase:get_damage_falloff(damage, col_ray, user_unit)
	return ShotgunBase.get_damage_falloff(self, damage, col_ray, user_unit)
end

function AkimboShotgunBase:run_and_shoot_allowed()
	return ShotgunBase.run_and_shoot_allowed(self)
end

function AkimboShotgunBase:_update_stats_values()
	ShotgunBase._update_stats_values(self)
end

NPCAkimboShotgunBase = NPCAkimboShotgunBase or class(NPCAkimboWeaponBase)
