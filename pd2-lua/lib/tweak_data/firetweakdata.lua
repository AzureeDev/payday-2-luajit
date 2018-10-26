FireTweakData = FireTweakData or class()

function FireTweakData:init(tweak_data)
	self.fire_bones = {
		"Spine",
		"LeftArm",
		"RightArm",
		"LeftLeg",
		"RightLeg"
	}
	self.effects = {
		endless = {
			expensive = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_endless",
			cheap = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_endless_cheap",
			normal = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_endless_no_light"
		},
		short = {
			expensive = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire",
			cheap = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_cheap",
			normal = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_cheap"
		},
		[5] = {
			expensive = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_5s",
			cheap = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_5s_cheap",
			normal = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_5s_cheap"
		},
		[7] = {
			expensive = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_7s",
			cheap = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_7s_cheap",
			normal = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_7s_cheap"
		},
		[9] = {
			expensive = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_9s",
			cheap = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_9s_cheap",
			normal = "effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_9s_cheap"
		}
	}
	self.effects_cost = {
		"expensive",
		"normal",
		"normal",
		"cheap",
		"cheap"
	}
	self.fire_death_anims = {
		[0] = {
			duration = 3,
			effect = "short"
		},
		{
			duration = 9,
			effect = 9
		},
		{
			duration = 5,
			effect = 5
		},
		{
			duration = 5,
			effect = 5
		},
		{
			duration = 7,
			effect = 7
		},
		{
			duration = 3,
			effect = "short"
		}
	}
end

