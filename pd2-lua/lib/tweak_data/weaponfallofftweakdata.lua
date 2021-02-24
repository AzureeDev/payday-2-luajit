WeaponFalloffTemplate = WeaponFalloffTemplate or class()

function WeaponFalloffTemplate.setup_weapon_falloff_templates()
	local weapon_falloff_templates = {
		ASSAULT_FALL_LOW = {}
	}
	weapon_falloff_templates.ASSAULT_FALL_LOW.optimal_distance = 0
	weapon_falloff_templates.ASSAULT_FALL_LOW.optimal_range = 1500
	weapon_falloff_templates.ASSAULT_FALL_LOW.near_falloff = 0
	weapon_falloff_templates.ASSAULT_FALL_LOW.far_falloff = 1000
	weapon_falloff_templates.ASSAULT_FALL_LOW.near_multiplier = 1
	weapon_falloff_templates.ASSAULT_FALL_LOW.far_multiplier = 1.5
	weapon_falloff_templates.ASSAULT_FALL_MEDIUM = {
		optimal_distance = 0,
		optimal_range = 1700,
		near_falloff = 0,
		far_falloff = 1000,
		near_multiplier = 1,
		far_multiplier = 1.4
	}
	weapon_falloff_templates.ASSAULT_FALL_HIGH = {
		optimal_distance = 0,
		optimal_range = 2000,
		near_falloff = 0,
		far_falloff = 1000,
		near_multiplier = 1,
		far_multiplier = 1.5
	}
	weapon_falloff_templates.SHOTGUN_FALL_PRIMARY_LOW = {
		optimal_distance = 300,
		optimal_range = 600,
		near_falloff = 300,
		far_falloff = 400,
		near_multiplier = 1.3,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.SHOTGUN_FALL_PRIMARY_MEDIUM = {
		optimal_distance = 500,
		optimal_range = 1000,
		near_falloff = 500,
		far_falloff = 500,
		near_multiplier = 1.3,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.SHOTGUN_FALL_PRIMARY_HIGH = {
		optimal_distance = 500,
		optimal_range = 1000,
		near_falloff = 500,
		far_falloff = 1000,
		near_multiplier = 1.3,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.SNIPER_RDM_LOW = {
		optimal_distance = 400,
		optimal_range = 1600,
		near_falloff = 0,
		far_falloff = 500,
		near_multiplier = 0.7,
		far_multiplier = 1.6
	}
	weapon_falloff_templates.SNIPER_FALL_MEDIUM = {
		optimal_distance = 400,
		optimal_range = 1500,
		near_falloff = 200,
		far_falloff = 500,
		near_multiplier = 0.6,
		far_multiplier = 1.7
	}
	weapon_falloff_templates.SNIPER_FALL_HIGH = {
		optimal_distance = 500,
		optimal_range = 1500,
		near_falloff = 0,
		far_falloff = 1000,
		near_multiplier = 0.5,
		far_multiplier = 2
	}
	weapon_falloff_templates.SNIPER_FALL_VERYHIGH = {
		optimal_distance = 600,
		optimal_range = 2000,
		near_falloff = 0,
		far_falloff = 500,
		near_multiplier = 0.5,
		far_multiplier = 1.5
	}
	weapon_falloff_templates.LMG_FALL_MEDIUM = {
		optimal_distance = 0,
		optimal_range = 2500,
		near_falloff = 0,
		far_falloff = 1000,
		near_multiplier = 1,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.LMG_FALL_HIGH = {
		optimal_distance = 0,
		optimal_range = 3000,
		near_falloff = 0,
		far_falloff = 1000,
		near_multiplier = 1,
		far_multiplier = 0.8
	}
	weapon_falloff_templates.AKI_PISTOL_FALL_LOW = {
		optimal_distance = 300,
		optimal_range = 1000,
		near_falloff = 0,
		far_falloff = 300,
		near_multiplier = 1.5,
		far_multiplier = 0.8
	}
	weapon_falloff_templates.AKI_PISTOL_FALL_MEDIUM = {
		optimal_distance = 300,
		optimal_range = 1000,
		near_falloff = 0,
		far_falloff = 400,
		near_multiplier = 1.4,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.AKI_PISTOL_FALL_HIGH = {
		optimal_distance = 300,
		optimal_range = 1000,
		near_falloff = 0,
		far_falloff = 500,
		near_multiplier = 1.3,
		far_multiplier = 0.6
	}
	weapon_falloff_templates.AKI_PISTOL_FALL_VERYHIGH = {
		optimal_distance = 300,
		optimal_range = 1000,
		near_falloff = 0,
		far_falloff = 600,
		near_multiplier = 1.2,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.AKI_SMG_FALL_LOW = {
		optimal_distance = 500,
		optimal_range = 900,
		near_falloff = 0,
		far_falloff = 0,
		near_multiplier = 1.3,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.AKI_SMG_FALL_MEDIUM = {
		optimal_distance = 400,
		optimal_range = 900,
		near_falloff = 100,
		far_falloff = 100,
		near_multiplier = 1.3,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.AKI_SMG_FALL_HIGH = {
		optimal_distance = 300,
		optimal_range = 1000,
		near_falloff = 0,
		far_falloff = 100,
		near_multiplier = 1.2,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.AKI_SHOTGUN_FALL_LOW = {
		optimal_distance = 300,
		optimal_range = 900,
		near_falloff = 300,
		far_falloff = 100,
		near_multiplier = 1.3,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.AKI_SHOTGUN_FALL_MEDIUM = {
		optimal_distance = 400,
		optimal_range = 1000,
		near_falloff = 200,
		far_falloff = 200,
		near_multiplier = 1.3,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.AKI_SHOTGUN_FALL_HIGH = {
		optimal_distance = 0,
		optimal_range = 1000,
		near_falloff = 0,
		far_falloff = 500,
		near_multiplier = 1.1,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.PISTOL_FALL_LOW = {
		optimal_distance = 500,
		optimal_range = 700,
		near_falloff = 0,
		far_falloff = 100,
		near_multiplier = 1.3,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.PISTOL_FALL_MEDIUM = {
		optimal_distance = 700,
		optimal_range = 1000,
		near_falloff = 200,
		far_falloff = 100,
		near_multiplier = 1.3,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.PISTOL_FALL_HIGH = {
		optimal_distance = 1000,
		optimal_range = 1000,
		near_falloff = 500,
		far_falloff = 100,
		near_multiplier = 1.3,
		far_multiplier = 0.6
	}
	weapon_falloff_templates.PISTOL_FALL_VERYHIGH = {
		optimal_distance = 1000,
		optimal_range = 1000,
		near_falloff = 500,
		far_falloff = 100,
		near_multiplier = 1.4,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.SMG_FALL_LOW = {
		optimal_distance = 0,
		optimal_range = 1200,
		near_falloff = 0,
		far_falloff = 500,
		near_multiplier = 1,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.SMG_FALL_MEDIUM = {
		optimal_distance = 0,
		optimal_range = 1300,
		near_falloff = 0,
		far_falloff = 500,
		near_multiplier = 1,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.SMG_FALL_HIGH = {
		optimal_distance = 0,
		optimal_range = 1400,
		near_falloff = 0,
		far_falloff = 500,
		near_multiplier = 1,
		far_multiplier = 0.6
	}
	weapon_falloff_templates.SHOTGUN_FALL_SECONDARY_LOW = {
		optimal_distance = 300,
		optimal_range = 600,
		near_falloff = 0,
		far_falloff = 400,
		near_multiplier = 1.3,
		far_multiplier = 0.1
	}
	weapon_falloff_templates.SHOTGUN_FALL_SECONDARY_MEDIUM = {
		optimal_distance = 400,
		optimal_range = 600,
		near_falloff = 200,
		far_falloff = 400,
		near_multiplier = 1.3,
		far_multiplier = 0.1
	}
	weapon_falloff_templates.SHOTGUN_FALL_SECONDARY_HIGH = {
		optimal_distance = 400,
		optimal_range = 600,
		near_falloff = 400,
		far_falloff = 300,
		near_multiplier = 1.1,
		far_multiplier = 0.1
	}
	weapon_falloff_templates.SHOTGUN_FALL_SECONDARY_VERYHIGH = {
		optimal_distance = 400,
		optimal_range = 600,
		near_falloff = 100,
		far_falloff = 200,
		near_multiplier = 1.2,
		far_multiplier = 0.5
	}

	return weapon_falloff_templates
end
