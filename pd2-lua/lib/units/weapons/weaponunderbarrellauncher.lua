WeaponUnderbarrelLauncher = WeaponUnderbarrelLauncher or class(WeaponUnderbarrel)
WeaponUnderbarrelLauncher.GADGET_TYPE = "underbarrel_launcher"

function WeaponUnderbarrelLauncher:init(unit)
	WeaponUnderbarrelLauncher.super.init(self, unit)

	self._launcher_projectile = self.launcher_projectile
end

function WeaponUnderbarrelLauncher:set_launcher_projectile(launcher_projectile)
	self._launcher_projectile = launcher_projectile
end

local mvec_spread_direction = Vector3()

function WeaponUnderbarrelLauncher:_fire_raycast(weapon_base, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local projectile_type = self._launcher_projectile

	if weapon_base:weapon_tweak_data() and weapon_base:weapon_tweak_data().projectile_types then
		projectile_type = weapon_base:weapon_tweak_data().projectile_types[projectile_type] or projectile_type
	end

	local projectile_type_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile_type)
	self._ammo_data = {
		launcher_grenade = projectile_type
	}
	local unit = nil
	local spread_x, spread_y = weapon_base:_get_spread(user_unit)
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()
	local theta = math.random() * 360
	local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
	local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

	mvector3.set(mvec_spread_direction, direction)
	mvector3.add(mvec_spread_direction, right * math.rad(ax))
	mvector3.add(mvec_spread_direction, up * math.rad(ay))
	self:_adjust_throw_z(mvec_spread_direction)

	mvec_spread_direction = mvec_spread_direction * 1
	local spawn_offset = self:_get_spawn_offset()
	self._dmg_mul = dmg_mul or 1

	if not self._client_authoritative then
		if Network:is_client() then
			managers.network:session():send_to_host("request_throw_projectile", projectile_type_index, from_pos, mvec_spread_direction)
		else
			unit = ProjectileBase.throw_projectile(projectile_type, from_pos, mvec_spread_direction, managers.network:session():local_peer():id())
		end
	else
		unit = ProjectileBase.throw_projectile(projectile_type, from_pos, mvec_spread_direction, managers.network:session():local_peer():id())
	end

	managers.statistics:shot_fired({
		hit = false,
		weapon_unit = weapon_base._unit
	})
	self:on_shot()
	weapon_base:check_bullet_objects()

	return {}
end

function WeaponUnderbarrelLauncher:_adjust_throw_z(m_vec)
end

function WeaponUnderbarrelLauncher:_get_spawn_offset()
	return 0
end
