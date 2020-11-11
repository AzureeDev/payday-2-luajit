PlayerTweakData = PlayerTweakData or class()

function PlayerTweakData:_set_easy()
	self.damage.automatic_respawn_time = 150
end

function PlayerTweakData:_set_normal()
	self.damage.automatic_respawn_time = 120
end

function PlayerTweakData:_set_hard()
	self.damage.automatic_respawn_time = 220
	self.damage.DOWNED_TIME_DEC = 7
	self.damage.DOWNED_TIME_MIN = 5
end

function PlayerTweakData:_set_overkill()
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.DOWNED_TIME_MIN = 5
end

function PlayerTweakData:_set_overkill_145()
	self.damage.DOWNED_TIME_DEC = 15
	self.damage.DOWNED_TIME_MIN = 1
end

function PlayerTweakData:_set_easy_wish()
	self.damage.DOWNED_TIME_DEC = 20
	self.damage.DOWNED_TIME_MIN = 1
	self.suspicion.max_value = 12
	self.suspicion.range_mul = 1.4
	self.suspicion.buildup_mul = 1.4
	self.damage.BLEED_OT_TIME = 10
	self.damage.LIVES_INIT = 4
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.damage.REVIVE_HEALTH_STEPS = {
		0.1
	}
end

function PlayerTweakData:_set_overkill_290()
	self.damage.DOWNED_TIME_DEC = 20
	self.damage.DOWNED_TIME_MIN = 1
	self.suspicion.max_value = 12
	self.suspicion.range_mul = 1.4
	self.suspicion.buildup_mul = 1.4
	self.damage.BLEED_OT_TIME = 10
	self.damage.LIVES_INIT = 4
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.damage.REVIVE_HEALTH_STEPS = {
		0.1
	}
end

function PlayerTweakData:_set_sm_wish()
	self.damage.DOWNED_TIME_DEC = 20
	self.damage.DOWNED_TIME_MIN = 1
	self.suspicion.max_value = 12
	self.suspicion.range_mul = 1.4
	self.suspicion.buildup_mul = 1.4
	self.damage.BLEED_OT_TIME = 10
	self.damage.LIVES_INIT = 4
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.damage.REVIVE_HEALTH_STEPS = {
		0.1
	}
end

function PlayerTweakData:_set_singleplayer()
	self.damage.REGENERATE_TIME = 1.75
end

function PlayerTweakData:_set_multiplayer()
end

function PlayerTweakData:init()
	local is_console = SystemInfo:platform() ~= Idstring("WIN32")
	local is_vr = false
	is_vr = _G.IS_VR
	self.arrest = {
		aggression_timeout = 60,
		arrest_timeout = 240
	}
	self.put_on_mask_time = 2
	self.gravity = -982
	self.terminal_velocity = -5500
	self.damage = {}

	if is_console then
		self.damage.ARMOR_INIT = 5
	else
		self.damage.ARMOR_INIT = 2
	end

	self.damage.DODGE_INIT = 0
	self.damage.HEALTH_REGEN = 0
	self.damage.ARMOR_STEPS = 1
	self.damage.ARMOR_DAMAGE_REDUCTION = 0
	self.damage.ARMOR_DAMAGE_REDUCTION_STEPS = {
		1,
		0.6,
		0.7,
		0.8,
		0.9,
		0.95,
		0.96,
		0.97,
		0.98,
		0.99
	}

	if is_vr then
		self.damage.HEALTH_INIT = 23
	else
		self.damage.HEALTH_INIT = 23
	end

	self.damage.LIVES_INIT = 4

	if is_console then
		self.damage.REGENERATE_TIME = 2.35
	else
		self.damage.REGENERATE_TIME = 3
	end

	self.damage.REVIVE_HEALTH_STEPS = {
		0.4
	}
	self.damage.BLEED_OT_TIME = 40
	self.damage.TASED_TIME = 10
	self.damage.TASED_RECOVER_TIME = 1
	self.damage.BLEED_OUT_HEALTH_INIT = 10
	self.damage.DOWNED_TIME = 30
	self.damage.DOWNED_TIME_DEC = 5
	self.damage.DOWNED_TIME_MIN = 10
	self.damage.ARRESTED_TIME = 60
	self.damage.INCAPACITATED_TIME = 30
	self.damage.MIN_DAMAGE_INTERVAL = 0.45
	self.damage.respawn_time_penalty = 30
	self.damage.base_respawn_time_penalty = 5
	self.damage.automatic_assault_ai_trade_time = 120
	self.damage.automatic_assault_ai_trade_time_max = 180
	self.fall_health_damage = 4
	self.fall_damage_alert_size = 250
	self.SUSPICION_OFFSET_LERP = 0.75
	self.long_dis_interaction = {
		intimidate_range_enemies = 1000,
		highlight_range = 3000,
		intimidate_range_civilians = 1000,
		intimidate_range_teammates = 100000,
		intimidate_strength = 0.5
	}
	self.suppression = {
		receive_mul = 10,
		decay_start_delay = 1,
		spread_mul = 1,
		tolerance = 1,
		max_value = 20,
		autohit_chance_mul = 1
	}
	self.suspicion = {
		range_mul = 1,
		max_value = 8,
		buildup_mul = 1
	}
	self.alarm_pager = {
		first_call_delay = {
			2,
			4
		},
		call_duration = {
			{
				6,
				6
			},
			{
				6,
				6
			}
		},
		nr_of_calls = {
			2,
			2
		},
		bluff_success_chance = {
			1,
			1,
			1,
			1,
			0
		},
		bluff_success_chance_w_skill = {
			1,
			1,
			1,
			1,
			0
		}
	}
	self.max_nr_following_hostages = 1
	self.TRANSITION_DURATION = 0.23
	self.stances = {
		default = {
			standard = {
				head = {},
				shoulders = {},
				vel_overshot = {}
			},
			crouched = {
				head = {},
				shoulders = {},
				vel_overshot = {}
			},
			steelsight = {
				shoulders = {},
				vel_overshot = {}
			}
		}
	}
	self.stances.default.standard.head.translation = Vector3(0, 0, 145)
	self.stances.default.standard.head.rotation = Rotation()
	self.stances.default.standard.shakers = {
		breathing = {}
	}
	self.stances.default.standard.shakers.breathing.amplitude = 0.3
	self.stances.default.crouched.shakers = {
		breathing = {}
	}
	self.stances.default.crouched.shakers.breathing.amplitude = 0.25
	self.stances.default.steelsight.shakers = {
		breathing = {}
	}
	self.stances.default.steelsight.shakers.breathing.amplitude = 0.025
	self.stances.default.mask_off = deep_clone(self.stances.default.standard)
	self.stances.default.mask_off.head.translation = Vector3(0, 0, 160)
	self.stances.default.clean = deep_clone(self.stances.default.mask_off)
	self.stances.default.civilian = deep_clone(self.stances.default.mask_off)
	local pivot_head_translation = Vector3()
	local pivot_head_rotation = Rotation()
	local pivot_shoulder_translation = Vector3()
	local pivot_shoulder_rotation = Rotation()
	self.stances.default.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.default.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.default.standard.vel_overshot.yaw_neg = 6
	self.stances.default.standard.vel_overshot.yaw_pos = -6
	self.stances.default.standard.vel_overshot.pitch_neg = -10
	self.stances.default.standard.vel_overshot.pitch_pos = 10
	self.stances.default.standard.vel_overshot.pivot = Vector3(0, 0, 0)
	self.stances.default.standard.FOV = 65
	self.stances.default.crouched.head.translation = Vector3(0, 0, 75)
	self.stances.default.crouched.head.rotation = Rotation()
	local pivot_head_translation = Vector3()
	local pivot_head_rotation = Rotation()
	self.stances.default.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.default.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.default.crouched.vel_overshot.yaw_neg = 6
	self.stances.default.crouched.vel_overshot.yaw_pos = -6
	self.stances.default.crouched.vel_overshot.pitch_neg = -10
	self.stances.default.crouched.vel_overshot.pitch_pos = 10
	self.stances.default.crouched.vel_overshot.pivot = Vector3(0, 0, 0)
	self.stances.default.crouched.FOV = self.stances.default.standard.FOV
	local pivot_head_translation = Vector3(0, 0, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.default.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.default.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.default.steelsight.vel_overshot.yaw_neg = 4
	self.stances.default.steelsight.vel_overshot.yaw_pos = -4
	self.stances.default.steelsight.vel_overshot.pitch_neg = -2
	self.stances.default.steelsight.vel_overshot.pitch_pos = 2
	self.stances.default.steelsight.vel_overshot.pivot = pivot_shoulder_translation
	self.stances.default.steelsight.zoom_fov = true
	self.stances.default.steelsight.FOV = self.stances.default.standard.FOV
	self.stances.jowi = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.391, 45.0507, -3.38766)
	local pivot_shoulder_rotation = Rotation(-0.326422, 0.247368, -0.0156885)
	local pivot_head_translation = Vector3(10.95, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.jowi.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.jowi.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.jowi.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 42, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.jowi.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.jowi.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.jowi.steelsight.zoom_fov = false
	self.stances.jowi.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.jowi.steelsight.vel_overshot.yaw_neg = 5
	self.stances.jowi.steelsight.vel_overshot.yaw_pos = -5
	self.stances.jowi.steelsight.vel_overshot.pitch_neg = -12
	self.stances.jowi.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10.95, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.jowi.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.jowi.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.jowi.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)

	self:_init_new_stances()

	self.movement_state = {
		standard = {}
	}
	self.movement_state.standard.movement = {
		speed = {},
		jump_velocity = {
			xy = {}
		},
		multiplier = {}
	}
	self.movement_state.standard.movement.speed.STANDARD_MAX = 350
	self.movement_state.standard.movement.speed.RUNNING_MAX = 575
	self.movement_state.standard.movement.speed.CROUCHING_MAX = 225
	self.movement_state.standard.movement.speed.STEELSIGHT_MAX = 185
	self.movement_state.standard.movement.speed.INAIR_MAX = 185
	self.movement_state.standard.movement.speed.CLIMBING_MAX = 200
	self.movement_state.standard.movement.jump_velocity.z = 470
	self.movement_state.standard.movement.jump_velocity.xy.run = self.movement_state.standard.movement.speed.RUNNING_MAX * 1
	self.movement_state.standard.movement.jump_velocity.xy.walk = self.movement_state.standard.movement.speed.STANDARD_MAX * 1.2

	if is_vr then
		self.movement_state.standard.movement.multiplier.run = 1.3
		self.movement_state.standard.movement.multiplier.walk = 1
		self.movement_state.standard.movement.multiplier.crouch = 1
		self.movement_state.standard.movement.multiplier.climb = 1
	end

	self.movement_state.interaction_delay = 1.5
	self.movement_state.stamina = {}

	if is_vr then
		self.movement_state.stamina.STAMINA_INIT = 50
	else
		self.movement_state.stamina.STAMINA_INIT = 50
	end

	self.movement_state.stamina.STAMINA_REGEN_RATE = 3
	self.movement_state.stamina.STAMINA_DRAIN_RATE = 2
	self.movement_state.stamina.STAMINA_DRAIN_RATE_WARP = 3
	self.movement_state.stamina.REGENERATE_TIME = 1
	self.movement_state.stamina.MIN_STAMINA_THRESHOLD = 4
	self.movement_state.stamina.JUMP_STAMINA_DRAIN = 2
	self.camera = {
		MIN_SENSITIVITY = 0.1,
		MAX_SENSITIVITY = 1.7
	}
	self.omniscience = {
		start_t = 3.5,
		interval_t = 1,
		sense_radius = 1000,
		target_resense_t = 15
	}

	self:_init_parachute()
end

function PlayerTweakData:_init_parachute()
	self.freefall = {
		gravity = 982,
		terminal_velocity = 7000,
		movement = {}
	}
	self.freefall.movement.forward_speed = 150
	self.freefall.movement.rotation_speed = 15
	self.freefall.camera = {
		target_pitch = -45,
		limits = {}
	}
	self.freefall.camera.limits.spin = 30
	self.freefall.camera.limits.pitch = 10
	self.freefall.camera.tilt = {
		max = 5,
		speed = 2
	}
	self.freefall.camera.shake = {
		min = 0,
		max = 0.2
	}
	self.parachute = {
		gravity = self.freefall.gravity,
		terminal_velocity = 600,
		movement = {}
	}
	self.parachute.movement.forward_speed = 250
	self.parachute.movement.rotation_speed = 30
	self.parachute.camera = {
		target_pitch = -5,
		limits = {}
	}
	self.parachute.camera.limits.spin = 90
	self.parachute.camera.limits.pitch = 60
	self.parachute.camera.tilt = {
		max = self.freefall.camera.tilt.max,
		speed = self.freefall.camera.shake.max
	}
end

function PlayerTweakData:_init_new_stances()
	self.stances.new_m4 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.685, 23.0133, -1.93524)
	local pivot_shoulder_rotation = Rotation(0.106674, -0.0849742, 0.628573)
	local pivot_head_translation = Vector3(8.5, 17, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_m4.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_m4.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_m4.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.new_m4.steelsight.vel_overshot.pitch_neg = -17
	self.stances.new_m4.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 10, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_m4.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_m4.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_m4.steelsight.FOV = self.stances.new_m4.standard.FOV
	self.stances.new_m4.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.new_m4.steelsight.vel_overshot.yaw_neg = 8
	self.stances.new_m4.steelsight.vel_overshot.yaw_pos = -8
	self.stances.new_m4.steelsight.vel_overshot.pitch_neg = -17
	self.stances.new_m4.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(6.5, 15.5, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_m4.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_m4.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_m4.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.glock_18c = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.49051, 38.6474, -5.09399)
	local pivot_shoulder_rotation = Rotation(0.0999949, -0.687702, 0.630304)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.glock_18c.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.glock_18c.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.glock_18c.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.glock_18c.standard.vel_overshot.yaw_neg = 10
	self.stances.glock_18c.standard.vel_overshot.yaw_pos = -10
	self.stances.glock_18c.standard.vel_overshot.pitch_neg = -13
	self.stances.glock_18c.standard.vel_overshot.pitch_pos = 13
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.glock_18c.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.glock_18c.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.glock_18c.steelsight.FOV = self.stances.glock_18c.standard.FOV
	self.stances.glock_18c.steelsight.zoom_fov = false
	self.stances.glock_18c.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.glock_18c.steelsight.vel_overshot.yaw_neg = 8
	self.stances.glock_18c.steelsight.vel_overshot.yaw_pos = -8
	self.stances.glock_18c.steelsight.vel_overshot.pitch_neg = -8
	self.stances.glock_18c.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.glock_18c.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.glock_18c.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.glock_18c.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.amcar = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6917, 23.0126, -1.48061)
	local pivot_shoulder_rotation = Rotation(0.106673, -0.0849742, 0.628574)
	local pivot_head_translation = Vector3(7.5, 17, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.amcar.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.amcar.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.amcar.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.amcar.standard.vel_overshot.yaw_neg = -6
	self.stances.amcar.standard.vel_overshot.yaw_pos = 6
	self.stances.amcar.standard.vel_overshot.pitch_neg = 5
	self.stances.amcar.standard.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(0, 14, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.amcar.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.amcar.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.amcar.steelsight.FOV = self.stances.amcar.standard.FOV
	self.stances.amcar.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.amcar.steelsight.vel_overshot.yaw_neg = -2
	self.stances.amcar.steelsight.vel_overshot.yaw_pos = 4
	self.stances.amcar.steelsight.vel_overshot.pitch_neg = 5
	self.stances.amcar.steelsight.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(6.5, 15.5, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.amcar.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.amcar.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.amcar.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.amcar.crouched.vel_overshot.yaw_neg = -6
	self.stances.amcar.crouched.vel_overshot.yaw_pos = 6
	self.stances.amcar.crouched.vel_overshot.pitch_neg = 5
	self.stances.amcar.crouched.vel_overshot.pitch_pos = -5
	self.stances.m16 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6859, 23.0235, -1.48418)
	local pivot_shoulder_rotation = Rotation(0.107116, -0.0847403, 0.629498)
	local pivot_head_translation = Vector3(7.5, 17, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m16.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m16.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m16.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, 0)
	self.stances.m16.standard.vel_overshot.yaw_neg = -6
	self.stances.m16.standard.vel_overshot.yaw_pos = 6
	self.stances.m16.standard.vel_overshot.pitch_neg = 10
	self.stances.m16.standard.vel_overshot.pitch_pos = -10
	local pivot_head_translation = Vector3(0, 14, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m16.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m16.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m16.steelsight.FOV = self.stances.m16.standard.FOV
	self.stances.m16.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.m16.steelsight.vel_overshot.yaw_neg = -4
	self.stances.m16.steelsight.vel_overshot.yaw_pos = 4
	self.stances.m16.steelsight.vel_overshot.pitch_neg = 8
	self.stances.m16.steelsight.vel_overshot.pitch_pos = -8
	local pivot_head_translation = Vector3(6.5, 15.5, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m16.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m16.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m16.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, 0)
	self.stances.m16.crouched.vel_overshot.yaw_neg = -4
	self.stances.m16.crouched.vel_overshot.yaw_pos = 4
	self.stances.m16.crouched.vel_overshot.pitch_neg = 8
	self.stances.m16.crouched.vel_overshot.pitch_pos = -8
	self.stances.olympic = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6863, 23.0172, -1.48667)
	local pivot_shoulder_rotation = Rotation(0.106659, -0.0849794, 0.628571)
	local pivot_head_translation = Vector3(10, 16, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.olympic.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.olympic.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.olympic.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, 0)
	local pivot_head_translation = Vector3(0, 14, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.olympic.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.olympic.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.olympic.steelsight.FOV = self.stances.olympic.standard.FOV
	self.stances.olympic.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.olympic.steelsight.vel_overshot.yaw_neg = 8
	self.stances.olympic.steelsight.vel_overshot.yaw_pos = -8
	self.stances.olympic.steelsight.vel_overshot.pitch_neg = -17
	self.stances.olympic.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(9, 15, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.olympic.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.olympic.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.olympic.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.ak74 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6155, 40.3833, -4.9875)
	local pivot_shoulder_rotation = Rotation(0.106684, -0.0855388, 0.628213)
	local pivot_head_translation = Vector3(8, 32, -2.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ak74.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ak74.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ak74.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.ak74.standard.vel_overshot.yaw_neg = -5
	self.stances.ak74.standard.vel_overshot.yaw_pos = 5
	self.stances.ak74.standard.vel_overshot.pitch_neg = 7
	self.stances.ak74.standard.vel_overshot.pitch_pos = -7
	local pivot_head_translation = Vector3(6, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ak74.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ak74.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ak74.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.ak74.crouched.vel_overshot.yaw_neg = -4
	self.stances.ak74.crouched.vel_overshot.yaw_pos = 4
	self.stances.ak74.crouched.vel_overshot.pitch_neg = 5
	self.stances.ak74.crouched.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(0, 30, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ak74.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ak74.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ak74.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.ak74.steelsight.vel_overshot.yaw_neg = -4
	self.stances.ak74.steelsight.vel_overshot.yaw_pos = 4
	self.stances.ak74.steelsight.vel_overshot.pitch_neg = 5
	self.stances.ak74.steelsight.vel_overshot.pitch_pos = -5
	self.stances.akm = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6154, 40.3836, -4.98362)
	local pivot_shoulder_rotation = Rotation(0.106679, -0.0865338, 0.627546)
	local pivot_head_translation = Vector3(9, 33, -2.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.akm.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.akm.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.akm.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.akm.standard.vel_overshot.yaw_neg = -5
	self.stances.akm.standard.vel_overshot.yaw_pos = 5
	self.stances.akm.standard.vel_overshot.pitch_neg = 7
	self.stances.akm.standard.vel_overshot.pitch_pos = -7
	local pivot_head_translation = Vector3(6, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.akm.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.akm.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.akm.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.akm.crouched.vel_overshot.yaw_neg = -4
	self.stances.akm.crouched.vel_overshot.yaw_pos = 4
	self.stances.akm.crouched.vel_overshot.pitch_neg = 5
	self.stances.akm.crouched.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(0, 30, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.akm.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.akm.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.akm.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.akm.steelsight.vel_overshot.yaw_neg = -4
	self.stances.akm.steelsight.vel_overshot.yaw_pos = 4
	self.stances.akm.steelsight.vel_overshot.pitch_neg = 5
	self.stances.akm.steelsight.vel_overshot.pitch_pos = -5
	self.stances.akmsu = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6185, 40.3877, -4.72286)
	local pivot_shoulder_rotation = Rotation(0.106697, -0.0845095, 0.62863)
	local pivot_head_translation = Vector3(9, 32, -2.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.akmsu.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.akmsu.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.akmsu.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.akmsu.standard.vel_overshot.yaw_neg = 10
	self.stances.akmsu.standard.vel_overshot.yaw_pos = -10
	self.stances.akmsu.standard.vel_overshot.pitch_neg = -20
	self.stances.akmsu.standard.vel_overshot.pitch_pos = 20
	local pivot_head_translation = Vector3(7, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.akmsu.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.akmsu.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.akmsu.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	local pivot_head_translation = Vector3(0, 30, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.akmsu.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.akmsu.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.akmsu.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.akmsu.steelsight.vel_overshot.yaw_neg = 10
	self.stances.akmsu.steelsight.vel_overshot.yaw_pos = -10
	self.stances.akmsu.steelsight.vel_overshot.pitch_neg = -20
	self.stances.akmsu.steelsight.vel_overshot.pitch_pos = 20
	self.stances.saiga = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(7.41774, 29.7226, -1.95727)
	local pivot_shoulder_rotation = Rotation(0.106196, -0.0625882, 0.630612)
	local pivot_head_translation = Vector3(8.5, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.saiga.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.saiga.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.saiga.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	local pivot_head_translation = Vector3(7.5, 31, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.saiga.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.saiga.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.saiga.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	local pivot_head_translation = Vector3(0, 30, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.saiga.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.saiga.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.saiga.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.saiga.steelsight.vel_overshot.yaw_neg = 10
	self.stances.saiga.steelsight.vel_overshot.yaw_pos = -10
	self.stances.saiga.steelsight.vel_overshot.pitch_neg = -20
	self.stances.saiga.steelsight.vel_overshot.pitch_pos = 20
	self.stances.ak5 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6877, 15.6166, -2.8033)
	local pivot_shoulder_rotation = Rotation(0.106298, -0.085067, 0.62852)
	local pivot_head_translation = Vector3(8, 11, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ak5.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ak5.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ak5.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.ak5.standard.vel_overshot.yaw_neg = 10
	self.stances.ak5.standard.vel_overshot.yaw_pos = -10
	self.stances.ak5.standard.vel_overshot.pitch_neg = -10
	self.stances.ak5.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(-0.017, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ak5.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ak5.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ak5.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.ak5.steelsight.vel_overshot.yaw_neg = 4
	self.stances.ak5.steelsight.vel_overshot.yaw_pos = -4
	self.stances.ak5.steelsight.vel_overshot.pitch_neg = -17
	self.stances.ak5.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(7, 10, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ak5.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ak5.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ak5.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.aug = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.76358, 14.9033, -4.43681)
	local pivot_shoulder_rotation = Rotation(0.106171, -0.0839854, 0.627887)
	local pivot_head_translation = Vector3(8.5, 16, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.aug.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.aug.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.aug.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.aug.standard.vel_overshot.yaw_neg = 8
	self.stances.aug.standard.vel_overshot.yaw_pos = -8
	self.stances.aug.standard.vel_overshot.pitch_neg = -10
	self.stances.aug.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 17, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.aug.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.aug.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.aug.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.aug.steelsight.vel_overshot.yaw_neg = 4
	self.stances.aug.steelsight.vel_overshot.yaw_pos = -4
	self.stances.aug.steelsight.vel_overshot.pitch_neg = -17
	self.stances.aug.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(7, 14, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.aug.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.aug.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.aug.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.g36 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.4764, 24.8875, -1.1479)
	local pivot_shoulder_rotation = Rotation(0.157971, -0.000391207, -0.00105803)
	local pivot_head_translation = Vector3(9.5, 15, -1.25)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.g36.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g36.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g36.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
	local pivot_head_translation = Vector3(0, 17, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.g36.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g36.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g36.steelsight.FOV = self.stances.g36.standard.FOV
	self.stances.g36.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.g36.steelsight.vel_overshot.yaw_neg = 5
	self.stances.g36.steelsight.vel_overshot.yaw_pos = -5
	self.stances.g36.steelsight.vel_overshot.pitch_neg = -17
	self.stances.g36.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(8, 15, -2.25)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.g36.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g36.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g36.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
	self.stances.p90 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.946, 24.3419, -1.02894)
	local pivot_shoulder_rotation = Rotation(0.2128, 0.969032, 0.196812)
	local pivot_head_translation = Vector3(11, 22, -1.25)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.p90.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.p90.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.p90.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
	self.stances.p90.standard.vel_overshot.yaw_neg = 10
	self.stances.p90.standard.vel_overshot.yaw_pos = -10
	self.stances.p90.standard.vel_overshot.pitch_neg = -15
	self.stances.p90.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 20, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.p90.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.p90.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.p90.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, 0)
	self.stances.p90.steelsight.vel_overshot.yaw_neg = 5
	self.stances.p90.steelsight.vel_overshot.yaw_pos = -5
	self.stances.p90.steelsight.vel_overshot.pitch_neg = -17
	self.stances.p90.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(10, 21, -2.25)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.p90.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.p90.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.p90.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
	self.stances.new_m14 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9676, 22.9989, -4.06557)
	local pivot_shoulder_rotation = Rotation(5.57069e-05, 0.000588677, -0.000347486)
	local pivot_head_translation = Vector3(12, 12, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_m14.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_m14.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_m14.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -12, 0)
	self.stances.new_m14.standard.vel_overshot.yaw_neg = -5
	self.stances.new_m14.standard.vel_overshot.yaw_pos = 5
	self.stances.new_m14.standard.vel_overshot.pitch_neg = 5
	self.stances.new_m14.standard.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(0, 10, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_m14.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_m14.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_m14.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -5, 0)
	self.stances.new_m14.steelsight.vel_overshot.yaw_neg = -4
	self.stances.new_m14.steelsight.vel_overshot.yaw_pos = 4
	self.stances.new_m14.steelsight.vel_overshot.pitch_neg = 3
	self.stances.new_m14.steelsight.vel_overshot.pitch_pos = -3
	local pivot_head_translation = Vector3(11, 11, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_m14.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_m14.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_m14.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -12, 0)
	self.stances.new_m14.crouched.vel_overshot.yaw_neg = -6
	self.stances.new_m14.crouched.vel_overshot.yaw_pos = 6
	self.stances.new_m14.crouched.vel_overshot.pitch_neg = 4
	self.stances.new_m14.crouched.vel_overshot.pitch_pos = -4
	self.stances.mp9 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6394, 18.2098, -7.33357)
	local pivot_shoulder_rotation = Rotation(0.106663, -0.0849746, 0.628575)
	local pivot_head_translation = Vector3(8, 12, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mp9.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mp9.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mp9.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, 0)
	self.stances.mp9.standard.vel_overshot.yaw_neg = 10
	self.stances.mp9.standard.vel_overshot.yaw_pos = -10
	self.stances.mp9.standard.vel_overshot.pitch_neg = -5
	self.stances.mp9.standard.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(0, 10, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mp9.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mp9.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mp9.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -5, 0)
	self.stances.mp9.steelsight.vel_overshot.yaw_neg = 4
	self.stances.mp9.steelsight.vel_overshot.yaw_pos = -4
	self.stances.mp9.steelsight.vel_overshot.pitch_neg = -8
	self.stances.mp9.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(7, 11, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mp9.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mp9.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mp9.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, 0)
	self.stances.deagle = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.47169, 40.6363, -2.73086)
	local pivot_shoulder_rotation = Rotation(0.100026, -0.68821, 0.629665)
	local pivot_head_translation = Vector3(7.25, 30, -2.25)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.deagle.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.deagle.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.deagle.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.deagle.standard.vel_overshot.yaw_neg = -5
	self.stances.deagle.standard.vel_overshot.yaw_pos = 5
	self.stances.deagle.standard.vel_overshot.pitch_neg = 4
	self.stances.deagle.standard.vel_overshot.pitch_pos = -4
	local pivot_head_translation = Vector3(-0.02, 35, 0.25)
	local pivot_head_rotation = Rotation(0, 0.5, 0)
	self.stances.deagle.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.deagle.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.deagle.steelsight.zoom_fov = false
	self.stances.deagle.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.deagle.steelsight.vel_overshot.yaw_neg = -4
	self.stances.deagle.steelsight.vel_overshot.yaw_pos = 2
	self.stances.deagle.steelsight.vel_overshot.pitch_neg = 2
	self.stances.deagle.steelsight.vel_overshot.pitch_pos = -2
	local pivot_head_translation = Vector3(5.5, 28, -2.75)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.deagle.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.deagle.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.deagle.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.new_mp5 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.1556, 18.7259, -0.82696)
	local pivot_shoulder_rotation = Rotation(0.099627, -0.686915, 0.628999)
	local pivot_head_translation = Vector3(9, 14, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_mp5.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_mp5.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_mp5.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.new_mp5.standard.vel_overshot.yaw_neg = 10
	self.stances.new_mp5.standard.vel_overshot.yaw_pos = -10
	self.stances.new_mp5.standard.vel_overshot.pitch_neg = -5
	self.stances.new_mp5.standard.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(0, 10, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_mp5.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_mp5.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_mp5.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -5, 0)
	self.stances.new_mp5.steelsight.vel_overshot.yaw_neg = 4
	self.stances.new_mp5.steelsight.vel_overshot.yaw_pos = -4
	self.stances.new_mp5.steelsight.vel_overshot.pitch_neg = -8
	self.stances.new_mp5.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(8, 13, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_mp5.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_mp5.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_mp5.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.colt_1911 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.51072, 41.1823, -3.19592)
	local pivot_shoulder_rotation = Rotation(0.0999825, -0.688529, 0.630296)
	local pivot_head_translation = Vector3(7, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.colt_1911.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.colt_1911.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.colt_1911.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.colt_1911.standard.vel_overshot.yaw_neg = 10
	self.stances.colt_1911.standard.vel_overshot.yaw_pos = -10
	self.stances.colt_1911.standard.vel_overshot.pitch_neg = -8
	self.stances.colt_1911.standard.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(0, 42, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.colt_1911.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.colt_1911.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.colt_1911.steelsight.zoom_fov = false
	self.stances.colt_1911.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.colt_1911.steelsight.vel_overshot.yaw_neg = 8
	self.stances.colt_1911.steelsight.vel_overshot.yaw_pos = -8
	self.stances.colt_1911.steelsight.vel_overshot.pitch_neg = -12
	self.stances.colt_1911.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(6, 31, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.colt_1911.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.colt_1911.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.colt_1911.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.mac10 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.58064, 35.6629, -3.22447)
	local pivot_shoulder_rotation = Rotation(0.105495, 0.0134994, 0.63323)
	local pivot_head_translation = Vector3(8, 22, -2.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mac10.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mac10.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mac10.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.mac10.standard.vel_overshot.yaw_neg = 15
	self.stances.mac10.standard.vel_overshot.yaw_pos = -15
	self.stances.mac10.standard.vel_overshot.pitch_neg = -15
	self.stances.mac10.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 23, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mac10.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mac10.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mac10.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, 0)
	self.stances.mac10.steelsight.vel_overshot.yaw_neg = 15
	self.stances.mac10.steelsight.vel_overshot.yaw_pos = -15
	self.stances.mac10.steelsight.vel_overshot.pitch_neg = -18
	self.stances.mac10.steelsight.vel_overshot.pitch_pos = 18
	local pivot_head_translation = Vector3(6, 18, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mac10.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mac10.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mac10.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.r870 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.662, 3.33648, -4.35027)
	local pivot_shoulder_rotation = Rotation(0.106662, -0.0849799, 0.628576)
	local pivot_head_translation = Vector3(9.5, 6, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.r870.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.r870.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.r870.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.r870.standard.vel_overshot.yaw_neg = -5
	self.stances.r870.standard.vel_overshot.yaw_pos = 3
	self.stances.r870.standard.vel_overshot.pitch_neg = 2
	self.stances.r870.standard.vel_overshot.pitch_pos = -3
	local pivot_head_translation = Vector3(-0.01, 10, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.r870.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.r870.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.r870.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.r870.steelsight.vel_overshot.yaw_neg = -3
	self.stances.r870.steelsight.vel_overshot.yaw_pos = 3
	self.stances.r870.steelsight.vel_overshot.pitch_neg = 2
	self.stances.r870.steelsight.vel_overshot.pitch_pos = -2
	local pivot_head_translation = Vector3(8.5, 5, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.r870.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.r870.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.r870.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.glock_17 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.48582, 38.7727, -5.49358)
	local pivot_shoulder_rotation = Rotation(0.100007, -0.687692, 0.630291)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.glock_17.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.glock_17.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.glock_17.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.glock_17.standard.vel_overshot.yaw_neg = 10
	self.stances.glock_17.standard.vel_overshot.yaw_pos = -10
	self.stances.glock_17.standard.vel_overshot.pitch_neg = -13
	self.stances.glock_17.standard.vel_overshot.pitch_pos = 13
	local pivot_head_translation = Vector3(0, 35, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.glock_17.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.glock_17.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.glock_17.steelsight.FOV = self.stances.glock_17.standard.FOV
	self.stances.glock_17.steelsight.zoom_fov = false
	self.stances.glock_17.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.glock_17.steelsight.vel_overshot.yaw_neg = 8
	self.stances.glock_17.steelsight.vel_overshot.yaw_pos = -8
	self.stances.glock_17.steelsight.vel_overshot.pitch_neg = -8
	self.stances.glock_17.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.glock_17.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.glock_17.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.glock_17.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.huntsman = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6562, 32.9715, -6.73279)
	local pivot_shoulder_rotation = Rotation(0.106667, -0.0844876, 0.629223)
	local pivot_head_translation = Vector3(8, 21, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.huntsman.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.huntsman.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.huntsman.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	local pivot_head_translation = Vector3(0, 25, -0.4)
	local pivot_head_rotation = Rotation(0, 1, 0)
	self.stances.huntsman.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.huntsman.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.huntsman.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.huntsman.steelsight.vel_overshot.yaw_neg = 12
	self.stances.huntsman.steelsight.vel_overshot.yaw_pos = -12
	self.stances.huntsman.steelsight.vel_overshot.pitch_neg = -12
	self.stances.huntsman.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(7, 20, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.huntsman.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.huntsman.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.huntsman.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.b92fs = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.50078, 40.9225, -4.15296)
	local pivot_shoulder_rotation = Rotation(0.100096, -0.687684, 0.630857)
	local pivot_head_translation = Vector3(6.5, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.b92fs.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.b92fs.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.b92fs.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	local pivot_head_translation = Vector3(0, 37, 0.1)
	local pivot_head_rotation = Rotation(0, 0.5, 0)
	self.stances.b92fs.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.b92fs.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.b92fs.steelsight.zoom_fov = false
	self.stances.b92fs.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.b92fs.steelsight.vel_overshot.yaw_neg = 5
	self.stances.b92fs.steelsight.vel_overshot.yaw_pos = -5
	self.stances.b92fs.steelsight.vel_overshot.pitch_neg = -12
	self.stances.b92fs.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(5, 30, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.b92fs.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.b92fs.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.b92fs.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.new_raging_bull = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.43999, 43.8644, -2.22393)
	local pivot_shoulder_rotation = Rotation(0.100024, -0.688276, 0.608057)
	local pivot_head_translation = Vector3(8, 33, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_raging_bull.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_raging_bull.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_raging_bull.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.new_raging_bull.standard.vel_overshot.yaw_neg = -5
	self.stances.new_raging_bull.standard.vel_overshot.yaw_pos = 2
	self.stances.new_raging_bull.standard.vel_overshot.pitch_neg = 5
	self.stances.new_raging_bull.standard.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(0, 36, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_raging_bull.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_raging_bull.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_raging_bull.steelsight.zoom_fov = false
	self.stances.new_raging_bull.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.new_raging_bull.steelsight.vel_overshot.yaw_neg = -5
	self.stances.new_raging_bull.steelsight.vel_overshot.yaw_pos = 2
	self.stances.new_raging_bull.steelsight.vel_overshot.pitch_neg = 5
	self.stances.new_raging_bull.steelsight.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(7, 32, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.new_raging_bull.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.new_raging_bull.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.new_raging_bull.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)

	self:_init_saw()
	self:_init_serbu()
	self:_init_usp()
	self:_init_g22c()
	self:_init_judge()
	self:_init_m45()
	self:_init_s552()
	self:_init_ppk()
	self:_init_mp7()
	self:_init_scar()
	self:_init_p226()
	self:_init_hk21()
	self:_init_m249()
	self:_init_rpk()
	self:_init_m95()
	self:_init_msr()
	self:_init_r93()
	self:_init_akm_gold()
	self:_init_fal()
	self:_init_benelli()
	self:_init_striker()
	self:_init_ksg()
	self:_init_scorpion()
	self:_init_tec9()
	self:_init_uzi()
	self:_init_gre_m79()
	self:_init_g3()
	self:_init_galil()
	self:_init_famas()
	self:_init_x_1911()
	self:_init_x_b92fs()
	self:_init_x_deagle()
	self:_init_g26()
	self:_init_spas12()
	self:_init_mg42()
	self:_init_c96()
	self:_init_sterling()
	self:_init_mosin()
	self:_init_m1928()
	self:_init_l85a2()
	self:_init_hs2000()
	self:_init_vhs()
	self:_init_m134()
	self:_init_rpg7()
	self:_init_cobray()
	self:_init_b682()
	self:_init_x_g22c()
	self:_init_x_g17()
	self:_init_x_usp()
	self:_init_flamethrower_mk2()
	self:_init_m32()
	self:_init_aa12()
	self:_init_peacemaker()
	self:_init_winchester1874()
	self:_init_plainsrider()
	self:_init_mateba()
	self:_init_asval()
	self:_init_sub2000()
	self:_init_wa2000()
	self:_init_polymer()
	self:_init_hunter()
	self:_init_baka()
	self:_init_arblast()
	self:_init_frankish()
	self:_init_long()
	self:_init_par()
	self:_init_sparrow()
	self:_init_model70()
	self:_init_m37()
	self:_init_china()
	self:_init_sr2()
	self:_init_x_sr2()
	self:_init_pl14()
	self:_init_x_mp5()
	self:_init_x_akmsu()
	self:_init_tecci()
	self:_init_hajk()
	self:_init_boot()
	self:_init_packrat()
	self:_init_schakal()
	self:_init_desertfox()
	self:_init_x_packrat()
	self:_init_rota()
	self:_init_arbiter()
	self:_init_contraband()
	self:_init_ray()
	self:_init_tti()
	self:_init_siltstone()
	self:_init_flint()
	self:_init_coal()
	self:_init_lemming()
	self:_init_chinchilla()
	self:_init_x_chinchilla()
	self:_init_sbl()
	self:_init_m1897()
	self:_init_model3()
	self:_init_x_model3()
	self:_init_shepheard()
	self:_init_x_shepheard()
	self:_init_breech()
	self:_init_ching()
	self:_init_erma()
	self:_init_ecp()
	self:_init_shrew()
	self:_init_x_shrew()
	self:_init_basset()
	self:_init_x_basset()
	self:_init_corgi()
	self:_init_slap()
	self:_init_x_coal()
	self:_init_x_baka()
	self:_init_x_cobray()
	self:_init_x_erma()
	self:_init_x_hajk()
	self:_init_x_m45()
	self:_init_x_m1928()
	self:_init_x_mac10()
	self:_init_x_mp7()
	self:_init_x_mp9()
	self:_init_x_olympic()
	self:_init_x_p90()
	self:_init_x_polymer()
	self:_init_x_schakal()
	self:_init_x_scorpion()
	self:_init_x_sterling()
	self:_init_x_tec9()
	self:_init_x_uzi()
	self:_init_x_2006m()
	self:_init_x_breech()
	self:_init_x_c96()
	self:_init_x_g18c()
	self:_init_x_hs2000()
	self:_init_x_p226()
	self:_init_x_pl14()
	self:_init_x_ppk()
	self:_init_x_rage()
	self:_init_x_sparrow()
	self:_init_x_judge()
	self:_init_x_rota()
	self:_init_shuno()
	self:_init_system()
	self:_init_komodo()
	self:_init_elastic()
	self:_init_legacy()
	self:_init_x_legacy()
	self:_init_coach()
	self:_init_beer()
	self:_init_x_beer()
	self:_init_czech()
	self:_init_x_czech()
	self:_init_stech()
	self:_init_x_stech()
	self:_init_holt()
	self:_init_x_holt()
	self:_init_m60()
	self:_init_r700()
end

function PlayerTweakData:_init_hs2000()
	self.stances.hs2000 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.48582, 38.7727, -5.49358)
	local pivot_shoulder_rotation = Rotation(0.100007, -0.687692, 0.630291)
	local pivot_head_translation = Vector3(5, 32, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hs2000.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hs2000.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hs2000.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.hs2000.standard.vel_overshot.yaw_neg = 10
	self.stances.hs2000.standard.vel_overshot.yaw_pos = -10
	self.stances.hs2000.standard.vel_overshot.pitch_neg = -13
	self.stances.hs2000.standard.vel_overshot.pitch_pos = 13
	local pivot_head_translation = Vector3(0, 35, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hs2000.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hs2000.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hs2000.steelsight.FOV = self.stances.hs2000.standard.FOV
	self.stances.hs2000.steelsight.zoom_fov = false
	self.stances.hs2000.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.hs2000.steelsight.vel_overshot.yaw_neg = 8
	self.stances.hs2000.steelsight.vel_overshot.yaw_pos = -8
	self.stances.hs2000.steelsight.vel_overshot.pitch_neg = -8
	self.stances.hs2000.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(4, 30, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hs2000.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hs2000.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hs2000.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
end

function PlayerTweakData:_init_mg42()
	self.stances.mg42 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6654, 35.1711, 0.821937)
	local pivot_shoulder_rotation = Rotation(0.106614, -0.0857193, 0.628153)
	local pivot_head_translation = Vector3(8, 32, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mg42.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mg42.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mg42.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.mg42.standard.vel_overshot.yaw_neg = 10
	self.stances.mg42.standard.vel_overshot.yaw_pos = -10
	self.stances.mg42.standard.vel_overshot.pitch_neg = -10
	self.stances.mg42.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(3, 30, -2)
	local pivot_head_rotation = Rotation(0, 0, -2)
	self.stances.mg42.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mg42.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mg42.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -58, 0)
	self.stances.mg42.steelsight.vel_overshot.yaw_neg = 10
	self.stances.mg42.steelsight.vel_overshot.yaw_pos = -10
	self.stances.mg42.steelsight.vel_overshot.pitch_neg = -10
	self.stances.mg42.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(7, 31, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mg42.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mg42.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mg42.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -55, 0)
	self.stances.mg42.bipod = {
		shoulders = {},
		vel_overshot = {}
	}
	local pivot_head_translation = Vector3(0, 0, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mg42.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mg42.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mg42.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -0, 0)
	self.stances.mg42.bipod.vel_overshot.yaw_neg = 0
	self.stances.mg42.bipod.vel_overshot.yaw_pos = 0
	self.stances.mg42.bipod.vel_overshot.pitch_neg = 0
	self.stances.mg42.bipod.vel_overshot.pitch_pos = 0
	self.stances.mg42.bipod.FOV = 50
end

function PlayerTweakData:_init_c96()
	self.stances.c96 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.44668, 44.0211, -4.39106)
	local pivot_shoulder_rotation = Rotation(0.100022, -0.68821, 0.62967)
	local pivot_head_translation = Vector3(10, 34, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.c96.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.c96.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.c96.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.c96.standard.vel_overshot.yaw_neg = 10
	self.stances.c96.standard.vel_overshot.yaw_pos = -10
	self.stances.c96.standard.vel_overshot.pitch_neg = -10
	self.stances.c96.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 30, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.c96.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.c96.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.c96.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -58, 0)
	self.stances.c96.steelsight.vel_overshot.yaw_neg = 10
	self.stances.c96.steelsight.vel_overshot.yaw_pos = -10
	self.stances.c96.steelsight.vel_overshot.pitch_neg = -10
	self.stances.c96.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9, 33, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.c96.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.c96.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.c96.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -55, 0)
end

function PlayerTweakData:_init_sterling()
	self.stances.sterling = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(7.80696, 10.985, -5.26646)
	local pivot_shoulder_rotation = Rotation(-0.0963392, 0.125283, -7.44771)
	local pivot_head_translation = Vector3(6, 11, -5)
	local pivot_head_rotation = Rotation(0, 0, -15)
	self.stances.sterling.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sterling.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sterling.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.sterling.standard.vel_overshot.yaw_neg = 10
	self.stances.sterling.standard.vel_overshot.yaw_pos = -10
	self.stances.sterling.standard.vel_overshot.pitch_neg = -10
	self.stances.sterling.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 20, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sterling.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sterling.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sterling.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -38, 0)
	self.stances.sterling.steelsight.vel_overshot.yaw_neg = 10
	self.stances.sterling.steelsight.vel_overshot.yaw_pos = -10
	self.stances.sterling.steelsight.vel_overshot.pitch_neg = -10
	self.stances.sterling.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(5, 12, -4)
	local pivot_head_rotation = Rotation(0, 0, -13)
	self.stances.sterling.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sterling.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sterling.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
end

function PlayerTweakData:_init_mosin()
	self.stances.mosin = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.65829, 40.5137, -4.02908)
	local pivot_shoulder_rotation = Rotation(0.106703, -0.0851106, 0.628477)
	local pivot_head_translation = Vector3(8, 32, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mosin.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mosin.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mosin.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.mosin.standard.vel_overshot.yaw_neg = 15
	self.stances.mosin.standard.vel_overshot.yaw_pos = -15
	self.stances.mosin.standard.vel_overshot.pitch_neg = -15
	self.stances.mosin.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 35, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mosin.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mosin.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mosin.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.mosin.steelsight.vel_overshot.yaw_neg = 0
	self.stances.mosin.steelsight.vel_overshot.yaw_pos = -0
	self.stances.mosin.steelsight.vel_overshot.pitch_neg = -0
	self.stances.mosin.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(8, 35, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mosin.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mosin.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mosin.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_g26()
	self.stances.g26 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.49051, 38.6474, -5.09399)
	local pivot_shoulder_rotation = Rotation(0.0999949, -0.687702, 0.630304)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.g26.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g26.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g26.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.g26.standard.vel_overshot.yaw_neg = 10
	self.stances.g26.standard.vel_overshot.yaw_pos = -10
	self.stances.g26.standard.vel_overshot.pitch_neg = -13
	self.stances.g26.standard.vel_overshot.pitch_pos = 13
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.g26.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g26.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g26.steelsight.FOV = self.stances.g26.standard.FOV
	self.stances.g26.steelsight.zoom_fov = false
	self.stances.g26.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.g26.steelsight.vel_overshot.yaw_neg = 8
	self.stances.g26.steelsight.vel_overshot.yaw_pos = -8
	self.stances.g26.steelsight.vel_overshot.pitch_neg = -8
	self.stances.g26.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.g26.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g26.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g26.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_x_1911()
	self.stances.x_1911 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.4939, 42.8789, -1.11447)
	local pivot_shoulder_rotation = Rotation(-0.347954, 0.253161, 0.281029)
	local pivot_head_translation = Vector3(10.95, 32, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_1911.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_1911.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_1911.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 42, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_1911.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_1911.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_1911.steelsight.zoom_fov = false
	self.stances.x_1911.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_1911.steelsight.vel_overshot.yaw_neg = 5
	self.stances.x_1911.steelsight.vel_overshot.yaw_pos = -5
	self.stances.x_1911.steelsight.vel_overshot.pitch_neg = -12
	self.stances.x_1911.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10.95, 34, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_1911.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_1911.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_1911.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_b92fs()
	self.stances.x_b92fs = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.1926, 42.656, -1.92934)
	local pivot_shoulder_rotation = Rotation(-0.291899, 0.237935, -0.510313)
	local pivot_head_translation = Vector3(11, 32, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_b92fs.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_b92fs.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_b92fs.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10, 42, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_b92fs.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_b92fs.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_b92fs.steelsight.zoom_fov = false
	self.stances.x_b92fs.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_b92fs.steelsight.vel_overshot.yaw_neg = 5
	self.stances.x_b92fs.steelsight.vel_overshot.yaw_pos = -5
	self.stances.x_b92fs.steelsight.vel_overshot.pitch_neg = -12
	self.stances.x_b92fs.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10.95, 34, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_b92fs.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_b92fs.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_b92fs.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_deagle()
	self.stances.x_deagle = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.4931, 42.3369, -0.596629)
	local pivot_shoulder_rotation = Rotation(-0.34809, 0.254047, 0.28066)
	local pivot_head_translation = Vector3(10.95, 32, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_deagle.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_deagle.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_deagle.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 42, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_deagle.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_deagle.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_deagle.steelsight.zoom_fov = false
	self.stances.x_deagle.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_deagle.steelsight.vel_overshot.yaw_neg = 5
	self.stances.x_deagle.steelsight.vel_overshot.yaw_pos = -5
	self.stances.x_deagle.steelsight.vel_overshot.pitch_neg = -12
	self.stances.x_deagle.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10.95, 34, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_deagle.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_deagle.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_deagle.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_spas12()
	self.stances.spas12 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6114, 29.7816, -4.5667)
	local pivot_shoulder_rotation = Rotation(0.106488, -0.0856018, 0.629234)
	local pivot_head_translation = Vector3(10, 25, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.spas12.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.spas12.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.spas12.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.spas12.standard.vel_overshot.yaw_neg = 10
	self.stances.spas12.standard.vel_overshot.yaw_pos = -10
	self.stances.spas12.standard.vel_overshot.pitch_neg = -10
	self.stances.spas12.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 32, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.spas12.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.spas12.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.spas12.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -58, 0)
	self.stances.spas12.steelsight.vel_overshot.yaw_neg = 10
	self.stances.spas12.steelsight.vel_overshot.yaw_pos = -10
	self.stances.spas12.steelsight.vel_overshot.pitch_neg = -10
	self.stances.spas12.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9, 24, -5.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.spas12.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.spas12.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.spas12.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -55, 0)
end

function PlayerTweakData:_init_saw()
	self.stances.saw = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.1399, 11.1007, -9.93544)
	local pivot_shoulder_rotation = Rotation(0.145081, 4.12987, 0.620396)
	local pivot_head_translation = Vector3(10, 3, -7)
	local pivot_head_rotation = Rotation(3, 3, 0)
	self.stances.saw.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.saw.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.saw.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.saw.standard.vel_overshot.yaw_neg = -5
	self.stances.saw.standard.vel_overshot.yaw_pos = 5
	self.stances.saw.standard.vel_overshot.pitch_neg = 5
	self.stances.saw.standard.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(8, 2, -5)
	local pivot_head_rotation = Rotation(3, 3, 0)
	self.stances.saw.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.saw.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.saw.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.saw.steelsight.zoom_fov = false
	self.stances.saw.steelsight.vel_overshot.yaw_neg = -5
	self.stances.saw.steelsight.vel_overshot.yaw_pos = 5
	self.stances.saw.steelsight.vel_overshot.pitch_neg = 5
	self.stances.saw.steelsight.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(9, 2, -8)
	local pivot_head_rotation = Rotation(3, 3, 0)
	self.stances.saw.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.saw.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.saw.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
end

function PlayerTweakData:_init_serbu()
	self.stances.serbu = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6628, 3.33715, -4.34531)
	local pivot_shoulder_rotation = Rotation(0.106663, -0.0849789, 0.628574)
	local pivot_head_translation = Vector3(7.5, 1, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.serbu.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.serbu.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.serbu.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.serbu.standard.vel_overshot.yaw_neg = 6
	self.stances.serbu.standard.vel_overshot.yaw_pos = -6
	self.stances.serbu.standard.vel_overshot.pitch_neg = -4
	self.stances.serbu.standard.vel_overshot.pitch_pos = 4
	local pivot_head_translation = Vector3(0, 5, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.serbu.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.serbu.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.serbu.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.serbu.steelsight.vel_overshot.yaw_neg = 5
	self.stances.serbu.steelsight.vel_overshot.yaw_pos = -4
	self.stances.serbu.steelsight.vel_overshot.pitch_neg = -5
	self.stances.serbu.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(6, 0, -4)
	local pivot_head_rotation = Rotation(-0, -0, 0)
	self.stances.serbu.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.serbu.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.serbu.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_usp()
	self.stances.usp = deep_clone(self.stances.colt_1911)
	local pivot_shoulder_translation = Vector3(8.51087, 41.182, -3.19589)
	local pivot_shoulder_rotation = Rotation(0.0996996, -0.686868, 0.630304)
	local pivot_head_translation = Vector3(7, 31, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.usp.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.usp.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.usp.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.usp.standard.vel_overshot.yaw_neg = 10
	self.stances.usp.standard.vel_overshot.yaw_pos = -10
	self.stances.usp.standard.vel_overshot.pitch_neg = -8
	self.stances.usp.standard.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(0, 38, 0.1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.usp.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.usp.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.usp.steelsight.zoom_fov = false
	self.stances.usp.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.usp.steelsight.vel_overshot.yaw_neg = 8
	self.stances.usp.steelsight.vel_overshot.yaw_pos = -8
	self.stances.usp.steelsight.vel_overshot.pitch_neg = -12
	self.stances.usp.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(6, 30, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.usp.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.usp.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.usp.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_g22c()
	self.stances.g22c = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.49051, 38.6474, -5.09399)
	local pivot_shoulder_rotation = Rotation(0.0999949, -0.687702, 0.630304)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.g22c.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g22c.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g22c.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.g22c.standard.vel_overshot.yaw_neg = 10
	self.stances.g22c.standard.vel_overshot.yaw_pos = -10
	self.stances.g22c.standard.vel_overshot.pitch_neg = -13
	self.stances.g22c.standard.vel_overshot.pitch_pos = 13
	local pivot_head_translation = Vector3(-0.005, 37, 0.3)
	local pivot_head_rotation = Rotation(0, 0.3, 0)
	self.stances.g22c.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g22c.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g22c.steelsight.FOV = self.stances.g22c.standard.FOV
	self.stances.g22c.steelsight.zoom_fov = false
	self.stances.g22c.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.g22c.steelsight.vel_overshot.yaw_neg = 8
	self.stances.g22c.steelsight.vel_overshot.yaw_pos = -8
	self.stances.g22c.steelsight.vel_overshot.pitch_neg = -8
	self.stances.g22c.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.g22c.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g22c.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g22c.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_judge()
	self.stances.judge = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.51217, 43.8759, -2.44869)
	local pivot_shoulder_rotation = Rotation(0.0994018, -0.689525, 0.618385)
	local pivot_head_translation = Vector3(8, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.judge.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.judge.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.judge.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.judge.standard.vel_overshot.yaw_neg = -5
	self.stances.judge.standard.vel_overshot.yaw_pos = 2
	self.stances.judge.standard.vel_overshot.pitch_neg = 5
	self.stances.judge.standard.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(0, 36, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.judge.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.judge.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.judge.steelsight.zoom_fov = false
	self.stances.judge.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.judge.steelsight.vel_overshot.yaw_neg = -5
	self.stances.judge.steelsight.vel_overshot.yaw_pos = 2
	self.stances.judge.steelsight.vel_overshot.pitch_neg = 5
	self.stances.judge.steelsight.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(7, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.judge.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.judge.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.judge.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_m45()
	self.stances.m45 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6061, 29.2595, -7.04746)
	local pivot_shoulder_rotation = Rotation(0.106669, -0.0850032, 0.628573)
	local pivot_head_translation = Vector3(11, 24, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m45.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m45.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m45.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.m45.standard.vel_overshot.yaw_neg = 15
	self.stances.m45.standard.vel_overshot.yaw_pos = -15
	self.stances.m45.standard.vel_overshot.pitch_neg = -15
	self.stances.m45.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 20, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m45.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m45.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m45.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.m45.steelsight.vel_overshot.yaw_neg = 10
	self.stances.m45.steelsight.vel_overshot.yaw_pos = -10
	self.stances.m45.steelsight.vel_overshot.pitch_neg = -10
	self.stances.m45.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(10, 23, -5.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m45.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m45.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m45.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_s552()
	self.stances.s552 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6163, 22.0889, -4.002)
	local pivot_shoulder_rotation = Rotation(0.106688, -0.0847366, 0.628588)
	local pivot_head_translation = Vector3(10.5, 14, -2.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.s552.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.s552.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.s552.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.s552.standard.vel_overshot.yaw_neg = 12
	self.stances.s552.standard.vel_overshot.yaw_pos = -12
	self.stances.s552.standard.vel_overshot.pitch_neg = -12
	self.stances.s552.standard.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(0, 12, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.s552.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.s552.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.s552.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, 0)
	self.stances.s552.steelsight.vel_overshot.yaw_neg = 10
	self.stances.s552.steelsight.vel_overshot.yaw_pos = -10
	self.stances.s552.steelsight.vel_overshot.pitch_neg = -10
	self.stances.s552.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9.5, 13, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.s552.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.s552.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.s552.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_ppk()
	self.stances.ppk = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.49608, 40.6427, -4.65654)
	local pivot_shoulder_rotation = Rotation(0.0989007, -0.686519, 0.631465)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ppk.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ppk.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ppk.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ppk.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ppk.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ppk.steelsight.zoom_fov = false
	self.stances.ppk.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.ppk.steelsight.vel_overshot.yaw_neg = 5
	self.stances.ppk.steelsight.vel_overshot.yaw_pos = -5
	self.stances.ppk.steelsight.vel_overshot.pitch_neg = -12
	self.stances.ppk.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(6, 30, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ppk.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ppk.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ppk.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_mp7()
	self.stances.mp7 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6576, 18.2065, -5.75727)
	local pivot_shoulder_rotation = Rotation(0.106663, -0.0849503, 0.628575)
	local pivot_head_translation = Vector3(9, 14, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mp7.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mp7.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mp7.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.mp7.standard.vel_overshot.yaw_neg = 15
	self.stances.mp7.standard.vel_overshot.yaw_pos = -15
	self.stances.mp7.standard.vel_overshot.pitch_neg = -15
	self.stances.mp7.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 14, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mp7.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mp7.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mp7.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.mp7.steelsight.vel_overshot.yaw_neg = 10
	self.stances.mp7.steelsight.vel_overshot.yaw_pos = -10
	self.stances.mp7.steelsight.vel_overshot.pitch_neg = -10
	self.stances.mp7.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(8, 13, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mp7.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mp7.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mp7.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_scar()
	self.stances.scar = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.7114, 19.4921, -0.0225505)
	local pivot_shoulder_rotation = Rotation(0.106672, -0.0849742, 0.628574)
	local pivot_head_translation = Vector3(9.5, 15, -1.25)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.scar.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.scar.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.scar.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.scar.standard.vel_overshot.yaw_neg = 10
	self.stances.scar.standard.vel_overshot.yaw_pos = -10
	self.stances.scar.standard.vel_overshot.pitch_neg = -10
	self.stances.scar.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 12, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.scar.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.scar.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.scar.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.scar.steelsight.vel_overshot.yaw_neg = 10
	self.stances.scar.steelsight.vel_overshot.yaw_pos = -10
	self.stances.scar.steelsight.vel_overshot.pitch_neg = -10
	self.stances.scar.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(8.5, 14, -2.25)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.scar.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.scar.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.scar.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_p226()
	self.stances.p226 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.45416, 39.1301, -4.58611)
	local pivot_shoulder_rotation = Rotation(0.100083, -0.688408, 0.630516)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.p226.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.p226.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.p226.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.p226.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.p226.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.p226.steelsight.zoom_fov = false
	self.stances.p226.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.p226.steelsight.vel_overshot.yaw_neg = 5
	self.stances.p226.steelsight.vel_overshot.yaw_pos = -5
	self.stances.p226.steelsight.vel_overshot.pitch_neg = -12
	self.stances.p226.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.p226.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.p226.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.p226.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_hk21()
	self.stances.hk21 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.545, 11.3934, -3.33201)
	local pivot_shoulder_rotation = Rotation(4.78916e-05, 0.00548037, -0.00110991)
	local pivot_head_translation = Vector3(8, 6, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hk21.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hk21.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hk21.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.hk21.standard.vel_overshot.yaw_neg = 15
	self.stances.hk21.standard.vel_overshot.yaw_pos = -15
	self.stances.hk21.standard.vel_overshot.pitch_neg = -15
	self.stances.hk21.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(8, 10, -1)
	local pivot_head_rotation = Rotation(0.2, 0.2, -8)
	self.stances.hk21.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hk21.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hk21.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.hk21.steelsight.vel_overshot.yaw_neg = 10
	self.stances.hk21.steelsight.vel_overshot.yaw_pos = -10
	self.stances.hk21.steelsight.vel_overshot.pitch_neg = -10
	self.stances.hk21.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(7, 5, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hk21.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hk21.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hk21.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.hk21.bipod = {
		shoulders = {},
		vel_overshot = {}
	}
	local pivot_head_translation = Vector3(0, 0, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hk21.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hk21.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hk21.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -0, 0)
	self.stances.hk21.bipod.vel_overshot.yaw_neg = 0
	self.stances.hk21.bipod.vel_overshot.yaw_pos = 0
	self.stances.hk21.bipod.vel_overshot.pitch_neg = 0
	self.stances.hk21.bipod.vel_overshot.pitch_pos = 0
	self.stances.hk21.bipod.FOV = 50
	self.stances.hk21.bipod.shakers = {
		breathing = {}
	}
	self.stances.hk21.bipod.shakers.breathing.amplitude = 0
end

function PlayerTweakData:_init_m249()
	self.stances.m249 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.7056, 4.38842, -0.747177)
	local pivot_shoulder_rotation = Rotation(0.106618, -0.084954, 0.62858)
	local pivot_head_translation = Vector3(11, 13, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m249.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m249.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m249.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.m249.standard.vel_overshot.yaw_neg = 15
	self.stances.m249.standard.vel_overshot.yaw_pos = -15
	self.stances.m249.standard.vel_overshot.pitch_neg = -15
	self.stances.m249.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(9.5, 11, -2)
	local pivot_head_rotation = Rotation(0, 0, -5)
	self.stances.m249.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m249.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m249.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.m249.steelsight.vel_overshot.yaw_neg = 10
	self.stances.m249.steelsight.vel_overshot.yaw_pos = -10
	self.stances.m249.steelsight.vel_overshot.pitch_neg = -10
	self.stances.m249.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(10, 12, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m249.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m249.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m249.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.m249.bipod = {
		shoulders = {},
		vel_overshot = {}
	}
	local pivot_head_translation = Vector3(0, 6, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m249.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m249.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m249.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.m249.bipod.vel_overshot.yaw_neg = 0
	self.stances.m249.bipod.vel_overshot.yaw_pos = 0
	self.stances.m249.bipod.vel_overshot.pitch_neg = 0
	self.stances.m249.bipod.vel_overshot.pitch_pos = 0
	self.stances.m249.bipod.FOV = 50
	self.stances.m249.bipod.shakers = {
		breathing = {}
	}
	self.stances.m249.bipod.shakers.breathing.amplitude = 0
end

function PlayerTweakData:_init_rpk()
	self.stances.rpk = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6138, 27.7178, -4.97323)
	local pivot_shoulder_rotation = Rotation(0.106543, -0.0842801, 0.628575)
	local pivot_head_translation = Vector3(11, 35, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.rpk.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rpk.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rpk.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.rpk.standard.vel_overshot.yaw_neg = 15
	self.stances.rpk.standard.vel_overshot.yaw_pos = -15
	self.stances.rpk.standard.vel_overshot.pitch_neg = -15
	self.stances.rpk.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(6, 30, -1)
	local pivot_head_rotation = Rotation(0, 0, -5)
	self.stances.rpk.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rpk.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rpk.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.rpk.steelsight.vel_overshot.yaw_neg = 10
	self.stances.rpk.steelsight.vel_overshot.yaw_pos = -10
	self.stances.rpk.steelsight.vel_overshot.pitch_neg = -10
	self.stances.rpk.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(8, 35, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.rpk.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rpk.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rpk.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.rpk.bipod = {
		shoulders = {},
		vel_overshot = {}
	}
	local pivot_head_translation = Vector3(0, 0, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.rpk.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rpk.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rpk.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -0, 0)
	self.stances.rpk.bipod.vel_overshot.yaw_neg = 0
	self.stances.rpk.bipod.vel_overshot.yaw_pos = 0
	self.stances.rpk.bipod.vel_overshot.pitch_neg = 0
	self.stances.rpk.bipod.vel_overshot.pitch_pos = 0
	self.stances.rpk.bipod.FOV = 50
end

function PlayerTweakData:_init_m95()
	self.stances.m95 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(12.8734, 21.463, -2.5494)
	local pivot_shoulder_rotation = Rotation(0.113234, 0.518279, 0.627416)
	local pivot_head_translation = Vector3(11, 25, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m95.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m95.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m95.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.m95.standard.vel_overshot.yaw_neg = 15
	self.stances.m95.standard.vel_overshot.yaw_pos = -15
	self.stances.m95.standard.vel_overshot.pitch_neg = -15
	self.stances.m95.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 0, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m95.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m95.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m95.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.m95.steelsight.vel_overshot.yaw_neg = 0
	self.stances.m95.steelsight.vel_overshot.yaw_pos = -0
	self.stances.m95.steelsight.vel_overshot.pitch_neg = -0
	self.stances.m95.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(10, 23, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m95.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m95.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m95.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_msr()
	self.stances.msr = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.66059, 40.8349, -3.2711)
	local pivot_shoulder_rotation = Rotation(0.106694, -0.0848914, 0.628555)
	local pivot_head_translation = Vector3(13, 34, -4.75)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.msr.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.msr.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.msr.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.msr.standard.vel_overshot.yaw_neg = 15
	self.stances.msr.standard.vel_overshot.yaw_pos = -15
	self.stances.msr.standard.vel_overshot.pitch_neg = -15
	self.stances.msr.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 35, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.msr.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.msr.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.msr.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.msr.steelsight.vel_overshot.yaw_neg = 0
	self.stances.msr.steelsight.vel_overshot.yaw_pos = -0
	self.stances.msr.steelsight.vel_overshot.pitch_neg = -0
	self.stances.msr.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(11.5, 37, -4.75)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.msr.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.msr.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.msr.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_r93()
	self.stances.r93 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6121, 45.4383, -4.45108)
	local pivot_shoulder_rotation = Rotation(0.10666, -0.0849622, 0.628577)
	local pivot_head_translation = Vector3(11, 34, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.r93.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.r93.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.r93.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.r93.standard.vel_overshot.yaw_neg = 15
	self.stances.r93.standard.vel_overshot.yaw_pos = -15
	self.stances.r93.standard.vel_overshot.pitch_neg = -15
	self.stances.r93.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 30, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.r93.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.r93.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.r93.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.r93.steelsight.vel_overshot.yaw_neg = 0
	self.stances.r93.steelsight.vel_overshot.yaw_pos = -0
	self.stances.r93.steelsight.vel_overshot.pitch_neg = -0
	self.stances.r93.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(10, 33, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.r93.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.r93.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.r93.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_akm_gold()
	self.stances.akm_gold = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6155, 40.3836, -4.98357)
	local pivot_shoulder_rotation = Rotation(0.10669, -0.0864947, 0.627576)
	local pivot_head_translation = Vector3(8, 33, -2.5)
	local pivot_head_rotation = Rotation(0.4, 0.4, 0)
	self.stances.akm_gold.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.akm_gold.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.akm_gold.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.akm_gold.standard.vel_overshot.yaw_neg = -5
	self.stances.akm_gold.standard.vel_overshot.yaw_pos = 5
	self.stances.akm_gold.standard.vel_overshot.pitch_neg = 7
	self.stances.akm_gold.standard.vel_overshot.pitch_pos = -7
	local pivot_head_translation = Vector3(7, 32, -3)
	local pivot_head_rotation = Rotation(0.2, 0.2, 0)
	self.stances.akm_gold.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.akm_gold.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.akm_gold.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.akm_gold.crouched.vel_overshot.yaw_neg = -4
	self.stances.akm_gold.crouched.vel_overshot.yaw_pos = 4
	self.stances.akm_gold.crouched.vel_overshot.pitch_neg = 5
	self.stances.akm_gold.crouched.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(0, 30, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.akm_gold.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.akm_gold.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.akm_gold.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.akm_gold.steelsight.vel_overshot.yaw_neg = -4
	self.stances.akm_gold.steelsight.vel_overshot.yaw_pos = 4
	self.stances.akm_gold.steelsight.vel_overshot.pitch_neg = 5
	self.stances.akm_gold.steelsight.vel_overshot.pitch_pos = -5
end

function PlayerTweakData:_init_fal()
	self.stances.fal = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6398, 30.1141, -4.37184)
	local pivot_shoulder_rotation = Rotation(0.106667, -0.0849355, 0.628585)
	local pivot_head_translation = Vector3(8, 25, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.fal.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.fal.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.fal.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.fal.standard.vel_overshot.yaw_neg = 10
	self.stances.fal.standard.vel_overshot.yaw_pos = -10
	self.stances.fal.standard.vel_overshot.pitch_neg = -10
	self.stances.fal.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 22, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.fal.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.fal.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.fal.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.fal.steelsight.vel_overshot.yaw_neg = 10
	self.stances.fal.steelsight.vel_overshot.yaw_pos = -10
	self.stances.fal.steelsight.vel_overshot.pitch_neg = -10
	self.stances.fal.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(7, 24, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.fal.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.fal.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.fal.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_benelli()
	self.stances.benelli = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6379, 10.7686, -5.37323)
	local pivot_shoulder_rotation = Rotation(0.106579, -0.0858935, 0.628813)
	local pivot_head_translation = Vector3(10, 12, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.benelli.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.benelli.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.benelli.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.benelli.standard.vel_overshot.yaw_neg = 10
	self.stances.benelli.standard.vel_overshot.yaw_pos = -10
	self.stances.benelli.standard.vel_overshot.pitch_neg = -10
	self.stances.benelli.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.benelli.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.benelli.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.benelli.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.benelli.steelsight.vel_overshot.yaw_neg = 10
	self.stances.benelli.steelsight.vel_overshot.yaw_pos = -10
	self.stances.benelli.steelsight.vel_overshot.pitch_neg = -10
	self.stances.benelli.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9, 11, -5.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.benelli.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.benelli.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.benelli.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
end

function PlayerTweakData:_init_striker()
	self.stances.striker = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6546, 11.9418, -3.67491)
	local pivot_shoulder_rotation = Rotation(0.106666, -0.0849691, 0.628576)
	local pivot_head_translation = Vector3(8, 16, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.striker.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.striker.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.striker.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.striker.standard.vel_overshot.yaw_neg = 10
	self.stances.striker.standard.vel_overshot.yaw_pos = -10
	self.stances.striker.standard.vel_overshot.pitch_neg = -10
	self.stances.striker.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 22, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.striker.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.striker.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.striker.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.striker.steelsight.vel_overshot.yaw_neg = 10
	self.stances.striker.steelsight.vel_overshot.yaw_pos = -10
	self.stances.striker.steelsight.vel_overshot.pitch_neg = -10
	self.stances.striker.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(7, 15, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.striker.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.striker.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.striker.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_ksg()
	self.stances.ksg = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(7.3474, 41.4691, -0.669275)
	local pivot_shoulder_rotation = Rotation(4.3342e-05, 5.7573e-05, -0.150059)
	local pivot_head_translation = Vector3(10, 23, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ksg.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ksg.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ksg.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.ksg.standard.vel_overshot.yaw_neg = 10
	self.stances.ksg.standard.vel_overshot.yaw_pos = -10
	self.stances.ksg.standard.vel_overshot.pitch_neg = -10
	self.stances.ksg.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 26, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ksg.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ksg.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ksg.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.ksg.steelsight.vel_overshot.yaw_neg = 10
	self.stances.ksg.steelsight.vel_overshot.yaw_pos = -10
	self.stances.ksg.steelsight.vel_overshot.pitch_neg = -10
	self.stances.ksg.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9, 22, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ksg.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ksg.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ksg.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
end

function PlayerTweakData:_init_scorpion()
	self.stances.scorpion = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6316, 28.7626, -6.54143)
	local pivot_shoulder_rotation = Rotation(0.106668, -0.0849211, 0.628574)
	local pivot_head_translation = Vector3(10, 18, -3.25)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.scorpion.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.scorpion.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.scorpion.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.scorpion.standard.vel_overshot.yaw_neg = 10
	self.stances.scorpion.standard.vel_overshot.yaw_pos = -10
	self.stances.scorpion.standard.vel_overshot.pitch_neg = -10
	self.stances.scorpion.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 15, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.scorpion.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.scorpion.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.scorpion.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.scorpion.steelsight.vel_overshot.yaw_neg = 10
	self.stances.scorpion.steelsight.vel_overshot.yaw_pos = -10
	self.stances.scorpion.steelsight.vel_overshot.pitch_neg = -10
	self.stances.scorpion.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9, 17, -4.25)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.scorpion.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.scorpion.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.scorpion.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
end

function PlayerTweakData:_init_tec9()
	self.stances.tec9 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.0476, 19.994, -4.43386)
	local pivot_shoulder_rotation = Rotation(5.01575e-05, 0.000580993, -0.000339375)
	local pivot_head_translation = Vector3(9, 21, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.tec9.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.tec9.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.tec9.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.tec9.standard.vel_overshot.yaw_neg = 15
	self.stances.tec9.standard.vel_overshot.yaw_pos = -15
	self.stances.tec9.standard.vel_overshot.pitch_neg = -15
	self.stances.tec9.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.tec9.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.tec9.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.tec9.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, 0)
	self.stances.tec9.steelsight.vel_overshot.yaw_neg = 15
	self.stances.tec9.steelsight.vel_overshot.yaw_pos = -15
	self.stances.tec9.steelsight.vel_overshot.pitch_neg = -18
	self.stances.tec9.steelsight.vel_overshot.pitch_pos = 18
	local pivot_head_translation = Vector3(8, 20, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.tec9.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.tec9.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.tec9.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_uzi()
	self.stances.uzi = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6614, 15.1429, -5.83008)
	local pivot_shoulder_rotation = Rotation(0.106665, -0.0849744, 0.628574)
	local pivot_head_translation = Vector3(10, 13, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.uzi.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.uzi.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.uzi.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.uzi.standard.vel_overshot.yaw_neg = 10
	self.stances.uzi.standard.vel_overshot.yaw_pos = -10
	self.stances.uzi.standard.vel_overshot.pitch_neg = -10
	self.stances.uzi.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 16, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.uzi.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.uzi.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.uzi.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.uzi.steelsight.vel_overshot.yaw_neg = 10
	self.stances.uzi.steelsight.vel_overshot.yaw_pos = -10
	self.stances.uzi.steelsight.vel_overshot.pitch_neg = -10
	self.stances.uzi.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9, 12, -5.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.uzi.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.uzi.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.uzi.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
end

function PlayerTweakData:_init_gre_m79()
	self.stances.gre_m79 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6363, 52.3198, -7.34957)
	local pivot_shoulder_rotation = Rotation(0.106995, -2.19204, 0.629449)
	local pivot_head_translation = Vector3(11, 45, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.gre_m79.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.gre_m79.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.gre_m79.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	local pivot_head_translation = Vector3(0, 40, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.gre_m79.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.gre_m79.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.gre_m79.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.gre_m79.steelsight.vel_overshot.yaw_neg = 12
	self.stances.gre_m79.steelsight.vel_overshot.yaw_pos = -12
	self.stances.gre_m79.steelsight.vel_overshot.pitch_neg = -12
	self.stances.gre_m79.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10, 44, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.gre_m79.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.gre_m79.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.gre_m79.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
end

function PlayerTweakData:_init_g3()
	self.stances.g3 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6681, 21.5458, -1.73827)
	local pivot_shoulder_rotation = Rotation(0.106686, -0.0859334, 0.627737)
	local pivot_head_translation = Vector3(8.5, 15, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.g3.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g3.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g3.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.g3.standard.vel_overshot.yaw_neg = 10
	self.stances.g3.standard.vel_overshot.yaw_pos = -10
	self.stances.g3.standard.vel_overshot.pitch_neg = -5
	self.stances.g3.standard.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(-0.03, 17, 0.16)
	local pivot_head_rotation = Rotation(0.01, 0, 0)
	self.stances.g3.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g3.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g3.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -28, 0)
	self.stances.g3.steelsight.vel_overshot.yaw_neg = 10
	self.stances.g3.steelsight.vel_overshot.yaw_pos = -10
	self.stances.g3.steelsight.vel_overshot.pitch_neg = -5
	self.stances.g3.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(7.5, 14, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.g3.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.g3.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.g3.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_galil()
	self.stances.galil = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6632, 22.0834, -3.76603)
	local pivot_shoulder_rotation = Rotation(0.106684, -0.084986, 0.628584)
	local pivot_head_translation = Vector3(7.5, 16, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.galil.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.galil.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.galil.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.galil.standard.vel_overshot.yaw_neg = 10
	self.stances.galil.standard.vel_overshot.yaw_pos = -10
	self.stances.galil.standard.vel_overshot.pitch_neg = -10
	self.stances.galil.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 8, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.galil.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.galil.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.galil.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -28, 0)
	self.stances.galil.steelsight.vel_overshot.yaw_neg = 10
	self.stances.galil.steelsight.vel_overshot.yaw_pos = -10
	self.stances.galil.steelsight.vel_overshot.pitch_neg = -10
	self.stances.galil.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(6.5, 15, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.galil.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.galil.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.galil.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_famas()
	self.stances.famas = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(12.4436, 37.0136, -1.75668)
	local pivot_shoulder_rotation = Rotation(2.58365, -0.0849733, 0.628574)
	local pivot_head_translation = Vector3(10, 30, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.famas.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.famas.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.famas.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.famas.standard.vel_overshot.yaw_neg = 10
	self.stances.famas.standard.vel_overshot.yaw_pos = -10
	self.stances.famas.standard.vel_overshot.pitch_neg = -10
	self.stances.famas.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 30, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.famas.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.famas.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.famas.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -38, 0)
	self.stances.famas.steelsight.vel_overshot.yaw_neg = 10
	self.stances.famas.steelsight.vel_overshot.yaw_pos = -10
	self.stances.famas.steelsight.vel_overshot.pitch_neg = -10
	self.stances.famas.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9, 29, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.famas.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.famas.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.famas.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
end

function PlayerTweakData:_init_m1928()
	self.stances.m1928 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.45353, 11.6248, -3.99483)
	local pivot_shoulder_rotation = Rotation(4.14593e-05, 0.000589104, -0.000400527)
	local pivot_head_translation = Vector3(8, 6, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m1928.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m1928.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m1928.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.m1928.standard.vel_overshot.yaw_neg = 10
	self.stances.m1928.standard.vel_overshot.yaw_pos = -3
	self.stances.m1928.standard.vel_overshot.pitch_neg = -10
	self.stances.m1928.standard.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(0, 12, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m1928.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m1928.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m1928.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.m1928.steelsight.vel_overshot.yaw_neg = 5
	self.stances.m1928.steelsight.vel_overshot.yaw_pos = -5
	self.stances.m1928.steelsight.vel_overshot.pitch_neg = -5
	self.stances.m1928.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(7, 5, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m1928.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m1928.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m1928.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
end

function PlayerTweakData:_init_l85a2()
	self.stances.l85a2 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.42267, 25.5584, -1.05883)
	local pivot_shoulder_rotation = Rotation(4.09795e-05, 0.000566906, -0.000322727)
	local pivot_head_translation = Vector3(10, 23.5, -0.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.l85a2.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.l85a2.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.l85a2.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.l85a2.standard.vel_overshot.yaw_neg = 10
	self.stances.l85a2.standard.vel_overshot.yaw_pos = -10
	self.stances.l85a2.standard.vel_overshot.pitch_neg = -10
	self.stances.l85a2.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.l85a2.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.l85a2.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.l85a2.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.l85a2.steelsight.vel_overshot.yaw_neg = 10
	self.stances.l85a2.steelsight.vel_overshot.yaw_pos = -10
	self.stances.l85a2.steelsight.vel_overshot.pitch_neg = -10
	self.stances.l85a2.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9, 22.5, -1.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.l85a2.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.l85a2.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.l85a2.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
end

function PlayerTweakData:_init_hs2000()
	self.stances.hs2000 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.49184, 38.238, -5.36848)
	local pivot_shoulder_rotation = Rotation(0.100076, -0.685838, 0.630525)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hs2000.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hs2000.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hs2000.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hs2000.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hs2000.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hs2000.steelsight.zoom_fov = false
	self.stances.hs2000.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.hs2000.steelsight.vel_overshot.yaw_neg = 5
	self.stances.hs2000.steelsight.vel_overshot.yaw_pos = -5
	self.stances.hs2000.steelsight.vel_overshot.pitch_neg = -12
	self.stances.hs2000.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hs2000.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hs2000.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hs2000.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_vhs()
	self.stances.vhs = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.43018, 11.2164, -1.79026)
	local pivot_shoulder_rotation = Rotation(4.53633e-05, 0.000316602, -0.000338188)
	local pivot_head_translation = Vector3(9, 14, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.vhs.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.vhs.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.vhs.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.vhs.standard.vel_overshot.yaw_neg = 10
	self.stances.vhs.standard.vel_overshot.yaw_pos = -10
	self.stances.vhs.standard.vel_overshot.pitch_neg = -10
	self.stances.vhs.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 12, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.vhs.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.vhs.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.vhs.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.vhs.steelsight.vel_overshot.yaw_neg = 4
	self.stances.vhs.steelsight.vel_overshot.yaw_pos = -4
	self.stances.vhs.steelsight.vel_overshot.pitch_neg = -4
	self.stances.vhs.steelsight.vel_overshot.pitch_pos = 4
	local pivot_head_translation = Vector3(8, 13, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.vhs.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.vhs.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.vhs.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_m134()
	self.stances.m134 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(4.11438, 35.5734, -13.4323)
	local pivot_shoulder_rotation = Rotation(-1.22503e-05, 0.00110689, 0.000282252)
	local pivot_head_translation = Vector3(2, 24, -14)
	local pivot_head_rotation = Rotation(0, 0, -14)
	self.stances.m134.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m134.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m134.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.m134.standard.vel_overshot.yaw_neg = 20
	self.stances.m134.standard.vel_overshot.yaw_pos = -20
	self.stances.m134.standard.vel_overshot.pitch_neg = -20
	self.stances.m134.standard.vel_overshot.pitch_pos = 20
	local pivot_head_translation = Vector3(0, 21, -12)
	local pivot_head_rotation = Rotation(0, 0, -12)
	self.stances.m134.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m134.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m134.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.m134.steelsight.vel_overshot.yaw_neg = 10
	self.stances.m134.steelsight.vel_overshot.yaw_pos = -10
	self.stances.m134.steelsight.vel_overshot.pitch_neg = -10
	self.stances.m134.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 22, -10)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m134.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m134.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m134.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
end

function PlayerTweakData:_init_rpg7()
	self.stances.rpg7 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.60744, 14.1008, 1.8554)
	local pivot_shoulder_rotation = Rotation(4.08927e-05, 0.000580566, -0.000338095)
	local pivot_head_translation = Vector3(8, 12, 3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.rpg7.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rpg7.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rpg7.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.rpg7.standard.vel_overshot.yaw_neg = 4
	self.stances.rpg7.standard.vel_overshot.yaw_pos = -4
	self.stances.rpg7.standard.vel_overshot.pitch_neg = -4
	self.stances.rpg7.standard.vel_overshot.pitch_pos = 4
	local pivot_head_translation = Vector3(0, 12, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.rpg7.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rpg7.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rpg7.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.rpg7.steelsight.vel_overshot.yaw_neg = 10
	self.stances.rpg7.steelsight.vel_overshot.yaw_pos = -10
	self.stances.rpg7.steelsight.vel_overshot.pitch_neg = -10
	self.stances.rpg7.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(8, 13, 4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.rpg7.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rpg7.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rpg7.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_cobray()
	self.stances.cobray = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.27773, 14.4497, -5.83427)
	local pivot_shoulder_rotation = Rotation(5.61873e-05, 0.000580566, -0.000341083)
	local pivot_head_translation = Vector3(10, 12, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.cobray.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.cobray.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.cobray.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.cobray.standard.vel_overshot.yaw_neg = 10
	self.stances.cobray.standard.vel_overshot.yaw_pos = -10
	self.stances.cobray.standard.vel_overshot.pitch_neg = -10
	self.stances.cobray.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.cobray.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.cobray.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.cobray.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.cobray.steelsight.vel_overshot.yaw_neg = 10
	self.stances.cobray.steelsight.vel_overshot.yaw_pos = -10
	self.stances.cobray.steelsight.vel_overshot.pitch_neg = -10
	self.stances.cobray.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9, 11, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.cobray.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.cobray.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.cobray.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
end

function PlayerTweakData:_init_b682()
	self.stances.b682 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.47311, 22.1434, -6.31211)
	local pivot_shoulder_rotation = Rotation(-1.83462e-05, 0.00105637, 0.000352956)
	local pivot_head_translation = Vector3(9, 21, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.b682.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.b682.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.b682.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.b682.standard.vel_overshot.yaw_neg = 14
	self.stances.b682.standard.vel_overshot.yaw_pos = -14
	self.stances.b682.standard.vel_overshot.pitch_neg = -14
	self.stances.b682.standard.vel_overshot.pitch_pos = 14
	local pivot_head_translation = Vector3(0, 24.8, -0.5)
	local pivot_head_rotation = Rotation(0, 0.3, 0)
	self.stances.b682.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.b682.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.b682.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.b682.steelsight.vel_overshot.yaw_neg = 10
	self.stances.b682.steelsight.vel_overshot.yaw_pos = -10
	self.stances.b682.steelsight.vel_overshot.pitch_neg = -10
	self.stances.b682.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(8, 20, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.b682.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.b682.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.b682.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_x_g22c()
	self.stances.x_g22c = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.4939, 42.8789, -1.11447)
	local pivot_shoulder_rotation = Rotation(-0.347954, 0.253161, 0.281029)
	local pivot_head_translation = Vector3(10.95, 32, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_g22c.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_g22c.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_g22c.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 42, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_g22c.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_g22c.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_g22c.steelsight.zoom_fov = false
	self.stances.x_g22c.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_g22c.steelsight.vel_overshot.yaw_neg = 5
	self.stances.x_g22c.steelsight.vel_overshot.yaw_pos = -5
	self.stances.x_g22c.steelsight.vel_overshot.pitch_neg = -12
	self.stances.x_g22c.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10.95, 34, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_g22c.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_g22c.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_g22c.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_g17()
	self.stances.x_g17 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.4939, 42.8789, -1.11447)
	local pivot_shoulder_rotation = Rotation(-0.347954, 0.253161, 0.281029)
	local pivot_head_translation = Vector3(10.95, 32, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_g17.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_g17.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_g17.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 42, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_g17.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_g17.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_g17.steelsight.zoom_fov = false
	self.stances.x_g17.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_g17.steelsight.vel_overshot.yaw_neg = 5
	self.stances.x_g17.steelsight.vel_overshot.yaw_pos = -5
	self.stances.x_g17.steelsight.vel_overshot.pitch_neg = -12
	self.stances.x_g17.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10.95, 34, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_g17.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_g17.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_g17.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_usp()
	self.stances.x_usp = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.4939, 42.8789, -1.11447)
	local pivot_shoulder_rotation = Rotation(-0.347954, 0.253161, 0.281029)
	local pivot_head_translation = Vector3(10.95, 32, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_usp.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_usp.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_usp.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 42, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_usp.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_usp.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_usp.steelsight.zoom_fov = false
	self.stances.x_usp.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_usp.steelsight.vel_overshot.yaw_neg = 5
	self.stances.x_usp.steelsight.vel_overshot.yaw_pos = -5
	self.stances.x_usp.steelsight.vel_overshot.pitch_neg = -12
	self.stances.x_usp.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10.95, 34, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_usp.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_usp.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_usp.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_flamethrower_mk2()
	self.stances.flamethrower_mk2 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.7639, 15.2768, -1.63551)
	local pivot_shoulder_rotation = Rotation(0.108359, -0.086669, 0.631366)
	local pivot_head_translation = Vector3(12, 16, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.flamethrower_mk2.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.flamethrower_mk2.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.flamethrower_mk2.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	local pivot_head_translation = Vector3(5, 15, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.flamethrower_mk2.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.flamethrower_mk2.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.flamethrower_mk2.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.flamethrower_mk2.steelsight.vel_overshot.yaw_neg = 12
	self.stances.flamethrower_mk2.steelsight.vel_overshot.yaw_pos = -12
	self.stances.flamethrower_mk2.steelsight.vel_overshot.pitch_neg = -12
	self.stances.flamethrower_mk2.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(11, 14, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.flamethrower_mk2.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.flamethrower_mk2.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.flamethrower_mk2.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_m32()
	self.stances.m32 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.64378, 20.8785, -3.22036)
	local pivot_shoulder_rotation = Rotation(4.72901e-05, 0.000589027, -0.000340069)
	local pivot_head_translation = Vector3(8.5, 22, -2.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m32.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m32.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m32.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.m32.standard.vel_overshot.yaw_neg = 10
	self.stances.m32.standard.vel_overshot.yaw_pos = -10
	self.stances.m32.standard.vel_overshot.pitch_neg = -10
	self.stances.m32.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m32.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m32.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m32.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.m32.steelsight.vel_overshot.yaw_neg = 10
	self.stances.m32.steelsight.vel_overshot.yaw_pos = -10
	self.stances.m32.steelsight.vel_overshot.pitch_neg = -10
	self.stances.m32.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(7.5, 21, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m32.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m32.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m32.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
end

function PlayerTweakData:_init_aa12()
	self.stances.aa12 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.2307, 17.5519, -1.27527)
	local pivot_shoulder_rotation = Rotation(6.51011e-06, -0.000117821, -8.70849e-05)
	local pivot_head_translation = Vector3(10, 13, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.aa12.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.aa12.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.aa12.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.aa12.standard.vel_overshot.yaw_neg = 10
	self.stances.aa12.standard.vel_overshot.yaw_pos = -10
	self.stances.aa12.standard.vel_overshot.pitch_neg = -10
	self.stances.aa12.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.aa12.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.aa12.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.aa12.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.aa12.steelsight.vel_overshot.yaw_neg = 10
	self.stances.aa12.steelsight.vel_overshot.yaw_pos = -10
	self.stances.aa12.steelsight.vel_overshot.pitch_neg = -10
	self.stances.aa12.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(9, 12, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.aa12.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.aa12.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.aa12.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
end

function PlayerTweakData:_init_peacemaker()
	self.stances.peacemaker = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.43932, 54.0601, -3.55138)
	local pivot_shoulder_rotation = Rotation(0.10003, -0.688227, 0.629666)
	local pivot_head_translation = Vector3(6, 42, -2)
	local pivot_head_rotation = Rotation(1, 1, -5)
	self.stances.peacemaker.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.peacemaker.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.peacemaker.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.peacemaker.standard.vel_overshot.yaw_neg = -5
	self.stances.peacemaker.standard.vel_overshot.yaw_pos = 2
	self.stances.peacemaker.standard.vel_overshot.pitch_neg = 5
	self.stances.peacemaker.standard.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(0, 40, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.peacemaker.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.peacemaker.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.peacemaker.steelsight.zoom_fov = false
	self.stances.peacemaker.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -37, 0)
	self.stances.peacemaker.steelsight.vel_overshot.yaw_neg = -5
	self.stances.peacemaker.steelsight.vel_overshot.yaw_pos = 2
	self.stances.peacemaker.steelsight.vel_overshot.pitch_neg = 5
	self.stances.peacemaker.steelsight.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(4, 42, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.peacemaker.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.peacemaker.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.peacemaker.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_winchester1874()
	self.stances.winchester1874 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6097, 49.1694, -8.4901)
	local pivot_shoulder_rotation = Rotation(0.00124311, -0.086311, 0.630106)
	local pivot_head_translation = Vector3(12, 49, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.winchester1874.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.winchester1874.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.winchester1874.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.winchester1874.standard.vel_overshot.yaw_neg = 15
	self.stances.winchester1874.standard.vel_overshot.yaw_pos = -15
	self.stances.winchester1874.standard.vel_overshot.pitch_neg = -15
	self.stances.winchester1874.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 42, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.winchester1874.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.winchester1874.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.winchester1874.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.winchester1874.steelsight.vel_overshot.yaw_neg = 0
	self.stances.winchester1874.steelsight.vel_overshot.yaw_pos = -0
	self.stances.winchester1874.steelsight.vel_overshot.pitch_neg = -0
	self.stances.winchester1874.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(11, 48, -5.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.winchester1874.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.winchester1874.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.winchester1874.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_sbl()
	self.stances.sbl = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6196, 42, -7)
	local pivot_shoulder_rotation = Rotation(0.000950045, -0.086319, 0.630619)
	local pivot_head_translation = Vector3(12, 49, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sbl.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sbl.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sbl.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.sbl.standard.vel_overshot.yaw_neg = 15
	self.stances.sbl.standard.vel_overshot.yaw_pos = -15
	self.stances.sbl.standard.vel_overshot.pitch_neg = -15
	self.stances.sbl.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 43, 1.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sbl.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sbl.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sbl.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.sbl.steelsight.vel_overshot.yaw_neg = 0
	self.stances.sbl.steelsight.vel_overshot.yaw_pos = -0
	self.stances.sbl.steelsight.vel_overshot.pitch_neg = -0
	self.stances.sbl.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(11, 48, -5.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sbl.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sbl.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sbl.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_plainsrider()
	self.stances.plainsrider = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(6.53874, 36.6672, -17.3943)
	local pivot_shoulder_rotation = Rotation(0.00233964, 0.00195501, 55.0004)
	local pivot_head_translation = Vector3(11, 36, -13)
	local pivot_head_rotation = Rotation(0, 0, 35)
	self.stances.plainsrider.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.plainsrider.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.plainsrider.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.plainsrider.standard.vel_overshot.yaw_neg = 15
	self.stances.plainsrider.standard.vel_overshot.yaw_pos = -15
	self.stances.plainsrider.standard.vel_overshot.pitch_neg = -15
	self.stances.plainsrider.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(1.1, 48, -3)
	local pivot_head_rotation = Rotation(3, 8.5, 35)
	self.stances.plainsrider.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.plainsrider.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.plainsrider.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.plainsrider.steelsight.vel_overshot.yaw_neg = 12
	self.stances.plainsrider.steelsight.vel_overshot.yaw_pos = -12
	self.stances.plainsrider.steelsight.vel_overshot.pitch_neg = -12
	self.stances.plainsrider.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(9, 34, -14)
	local pivot_head_rotation = Rotation(0, 0, 42)
	self.stances.plainsrider.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.plainsrider.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.plainsrider.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
end

function PlayerTweakData:_init_mateba()
	self.stances.mateba = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.52839, 40.2153, -3.77382)
	local pivot_shoulder_rotation = Rotation(0.0991125, -0.687691, 0.607803)
	local pivot_head_translation = Vector3(9, 31, -3.75)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mateba.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mateba.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mateba.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(0, 42, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mateba.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mateba.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mateba.steelsight.zoom_fov = false
	self.stances.mateba.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.mateba.steelsight.vel_overshot.yaw_neg = 5
	self.stances.mateba.steelsight.vel_overshot.yaw_pos = -5
	self.stances.mateba.steelsight.vel_overshot.pitch_neg = -12
	self.stances.mateba.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(8, 30, -4.75)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.mateba.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mateba.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mateba.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_asval()
	self.stances.asval = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.5798, 44.2632, -6.39698)
	local pivot_shoulder_rotation = Rotation(0.108567, -0.0851526, 0.630769)
	local pivot_head_translation = Vector3(8, 43, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.asval.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.asval.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.asval.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(0, 35, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.asval.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.asval.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.asval.steelsight.zoom_fov = false
	self.stances.asval.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.asval.steelsight.vel_overshot.yaw_neg = 5
	self.stances.asval.steelsight.vel_overshot.yaw_pos = -5
	self.stances.asval.steelsight.vel_overshot.pitch_neg = -12
	self.stances.asval.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(7, 42, -3.7)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.asval.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.asval.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.asval.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_sub2000()
	self.stances.sub2000 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.5282, 18.097, -5.00149)
	local pivot_shoulder_rotation = Rotation(0.00116612, 0.000628372, -0.000528199)
	local pivot_head_translation = Vector3(10, 19, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sub2000.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sub2000.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sub2000.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(0, 22, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sub2000.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sub2000.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sub2000.steelsight.zoom_fov = false
	self.stances.sub2000.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.sub2000.steelsight.vel_overshot.yaw_neg = 5
	self.stances.sub2000.steelsight.vel_overshot.yaw_pos = -5
	self.stances.sub2000.steelsight.vel_overshot.pitch_neg = -12
	self.stances.sub2000.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(9, 18, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sub2000.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sub2000.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sub2000.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_wa2000()
	self.stances.wa2000 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.5287, 10.4677, 0.247723)
	local pivot_shoulder_rotation = Rotation(0.000398715, -0.000868289, -0.000330621)
	local pivot_head_translation = Vector3(10, 14, 1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.wa2000.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.wa2000.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.wa2000.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(0, 20, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.wa2000.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.wa2000.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.wa2000.steelsight.zoom_fov = false
	self.stances.wa2000.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.wa2000.steelsight.vel_overshot.yaw_neg = 0
	self.stances.wa2000.steelsight.vel_overshot.yaw_pos = -0
	self.stances.wa2000.steelsight.vel_overshot.pitch_neg = -0
	self.stances.wa2000.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(9, 13, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.wa2000.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.wa2000.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.wa2000.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_polymer()
	self.stances.polymer = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.97257, 14.5029, -1.63302)
	local pivot_shoulder_rotation = Rotation(3.95253e-05, 0.000647161, 0.000284306)
	local pivot_head_translation = Vector3(8.25, 15, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.polymer.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.polymer.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.polymer.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.polymer.standard.vel_overshot.yaw_neg = 10
	self.stances.polymer.standard.vel_overshot.yaw_pos = -2
	self.stances.polymer.standard.vel_overshot.pitch_neg = -10
	self.stances.polymer.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 10, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.polymer.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.polymer.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.polymer.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.polymer.steelsight.vel_overshot.yaw_neg = 10
	self.stances.polymer.steelsight.vel_overshot.yaw_pos = -10
	self.stances.polymer.steelsight.vel_overshot.pitch_neg = -10
	self.stances.polymer.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(7.25, 14, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.polymer.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.polymer.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.polymer.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_hunter()
	self.stances.hunter = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.5286, 37.1301, -5.39847)
	local pivot_shoulder_rotation = Rotation(4.53226e-05, 0.000561889, -0.000335053)
	local pivot_head_translation = Vector3(9, 30, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hunter.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hunter.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hunter.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.hunter.standard.vel_overshot.yaw_neg = 10
	self.stances.hunter.standard.vel_overshot.yaw_pos = -10
	self.stances.hunter.standard.vel_overshot.pitch_neg = -10
	self.stances.hunter.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 10, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hunter.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hunter.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hunter.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.hunter.steelsight.vel_overshot.yaw_neg = 10
	self.stances.hunter.steelsight.vel_overshot.yaw_pos = -10
	self.stances.hunter.steelsight.vel_overshot.pitch_neg = -10
	self.stances.hunter.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(8, 29, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hunter.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hunter.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hunter.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
end

function PlayerTweakData:_init_baka()
	self.stances.baka = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.33471, 13.913, -0.0159556)
	local pivot_shoulder_rotation = Rotation(0.001265, 0.00210433, -0.000365091)
	local pivot_head_translation = Vector3(7, 16, 1.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.baka.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.baka.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.baka.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.baka.standard.vel_overshot.yaw_neg = 9
	self.stances.baka.standard.vel_overshot.yaw_pos = -9
	self.stances.baka.standard.vel_overshot.pitch_neg = -9
	self.stances.baka.standard.vel_overshot.pitch_pos = 9
	local pivot_head_translation = Vector3(-1.88, 16, 5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.baka.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.baka.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.baka.steelsight.zoom_fov = false
	self.stances.baka.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.baka.steelsight.vel_overshot.yaw_neg = 15
	self.stances.baka.steelsight.vel_overshot.yaw_pos = -15
	self.stances.baka.steelsight.vel_overshot.pitch_neg = -15
	self.stances.baka.steelsight.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(6, 15, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.baka.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.baka.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.baka.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
end

function PlayerTweakData:_init_arblast()
	self.stances.arblast = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.3759, 27.2897, -11.445)
	local pivot_shoulder_rotation = Rotation(-2.2432e-05, 0.00111043, 0.000302449)
	local pivot_head_translation = Vector3(7, 25, -8)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.arblast.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.arblast.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.arblast.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.arblast.standard.vel_overshot.yaw_neg = 10
	self.stances.arblast.standard.vel_overshot.yaw_pos = -10
	self.stances.arblast.standard.vel_overshot.pitch_neg = -10
	self.stances.arblast.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 22, -4)
	local pivot_head_rotation = Rotation(0, 5, 0)
	self.stances.arblast.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.arblast.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.arblast.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.arblast.steelsight.vel_overshot.yaw_neg = 10
	self.stances.arblast.steelsight.vel_overshot.yaw_pos = -10
	self.stances.arblast.steelsight.vel_overshot.pitch_neg = -10
	self.stances.arblast.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(6, 24, -9)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.arblast.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.arblast.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.arblast.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
end

function PlayerTweakData:_init_frankish()
	self.stances.frankish = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.376, 27.2898, -11.4456)
	local pivot_shoulder_rotation = Rotation(0.000581843, 0.000485653, 0.000157514)
	local pivot_head_translation = Vector3(7, 25, -8)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.frankish.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.frankish.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.frankish.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.frankish.standard.vel_overshot.yaw_neg = 10
	self.stances.frankish.standard.vel_overshot.yaw_pos = -10
	self.stances.frankish.standard.vel_overshot.pitch_neg = -10
	self.stances.frankish.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 32, -4)
	local pivot_head_rotation = Rotation(0, 5, 0)
	self.stances.frankish.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.frankish.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.frankish.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.frankish.steelsight.vel_overshot.yaw_neg = 10
	self.stances.frankish.steelsight.vel_overshot.yaw_pos = -10
	self.stances.frankish.steelsight.vel_overshot.pitch_neg = -10
	self.stances.frankish.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(6, 24, -9)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.frankish.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.frankish.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.frankish.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
end

function PlayerTweakData:_init_long()
	self.stances.long = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(6.50446, 35.57, -17.2983)
	local pivot_shoulder_rotation = Rotation(0.00224909, 0.00268967, 54.9997)
	local pivot_head_translation = Vector3(10, 42, -14)
	local pivot_head_rotation = Rotation(0, 0, 35)
	self.stances.long.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.long.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.long.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.long.standard.vel_overshot.yaw_neg = 15
	self.stances.long.standard.vel_overshot.yaw_pos = -15
	self.stances.long.standard.vel_overshot.pitch_neg = -15
	self.stances.long.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(2.1, 48, -4)
	local pivot_head_rotation = Rotation(1.2, 5.5, 35)
	self.stances.long.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.long.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.long.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.long.steelsight.vel_overshot.yaw_neg = 12
	self.stances.long.steelsight.vel_overshot.yaw_pos = -12
	self.stances.long.steelsight.vel_overshot.pitch_neg = -12
	self.stances.long.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10, 42, -14)
	local pivot_head_rotation = Rotation(0, 0, 42)
	self.stances.long.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.long.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.long.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
end

function PlayerTweakData:_init_par()
	self.stances.par = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.7056, 4.38842, -0.747177)
	local pivot_shoulder_rotation = Rotation(0.106618, -0.084954, 0.62858)
	local pivot_head_translation = Vector3(10, 5, -1)
	local pivot_head_rotation = Rotation(0.4, 0.4, 0)
	self.stances.par.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.par.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.par.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.par.standard.vel_overshot.yaw_neg = 8
	self.stances.par.standard.vel_overshot.yaw_pos = -8
	self.stances.par.standard.vel_overshot.pitch_neg = -8
	self.stances.par.standard.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(6, 4, 2)
	local pivot_head_rotation = Rotation(0, 0, -5)
	self.stances.par.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.par.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.par.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.par.steelsight.vel_overshot.yaw_neg = 6
	self.stances.par.steelsight.vel_overshot.yaw_pos = -6
	self.stances.par.steelsight.vel_overshot.pitch_neg = -6
	self.stances.par.steelsight.vel_overshot.pitch_pos = 6
	local pivot_head_translation = Vector3(9, 4, -2)
	local pivot_head_rotation = Rotation(0.2, 0.2, 0)
	self.stances.par.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.par.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.par.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.par.bipod = {
		shoulders = {},
		vel_overshot = {}
	}
	local pivot_head_translation = Vector3(0, 6, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.par.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.par.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.par.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.par.bipod.vel_overshot.yaw_neg = 0
	self.stances.par.bipod.vel_overshot.yaw_pos = 0
	self.stances.par.bipod.vel_overshot.pitch_neg = 0
	self.stances.par.bipod.vel_overshot.pitch_pos = 0
	self.stances.par.bipod.FOV = 50
	self.stances.par.bipod.shakers = {
		breathing = {}
	}
	self.stances.par.bipod.shakers.breathing.amplitude = 0
end

function PlayerTweakData:_init_sparrow()
	self.stances.sparrow = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.44539, 43.3056, -4.70979)
	local pivot_shoulder_rotation = Rotation(0.100026, -0.68821, 0.629665)
	local pivot_head_translation = Vector3(6.5, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sparrow.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sparrow.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sparrow.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sparrow.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sparrow.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sparrow.steelsight.zoom_fov = false
	self.stances.sparrow.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.sparrow.steelsight.vel_overshot.yaw_neg = 5
	self.stances.sparrow.steelsight.vel_overshot.yaw_pos = -5
	self.stances.sparrow.steelsight.vel_overshot.pitch_neg = -12
	self.stances.sparrow.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(5.5, 31, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sparrow.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sparrow.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sparrow.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_model70()
	self.stances.model70 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(7.96526, 39.0739, -3.92198)
	local pivot_shoulder_rotation = Rotation(4.36208e-05, 0.000603618, -0.000330838)
	local pivot_head_translation = Vector3(10, 42, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.model70.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.model70.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.model70.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -55, 0)
	self.stances.model70.standard.vel_overshot.yaw_neg = 12
	self.stances.model70.standard.vel_overshot.yaw_pos = -12
	self.stances.model70.standard.vel_overshot.pitch_neg = -12
	self.stances.model70.standard.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(0, 47, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.model70.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.model70.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.model70.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.model70.steelsight.vel_overshot.yaw_neg = 0
	self.stances.model70.steelsight.vel_overshot.yaw_pos = -0
	self.stances.model70.steelsight.vel_overshot.pitch_neg = -0
	self.stances.model70.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(9, 41, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.model70.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.model70.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.model70.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_m37()
	self.stances.m37 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.27651, 19.3937, -6.03765)
	local pivot_shoulder_rotation = Rotation(4.57709e-05, 0.00055666, -0.000335693)
	local pivot_head_translation = Vector3(7.5, 22, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m37.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m37.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m37.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.m37.standard.vel_overshot.yaw_neg = 15
	self.stances.m37.standard.vel_overshot.yaw_pos = -5
	self.stances.m37.standard.vel_overshot.pitch_neg = -10
	self.stances.m37.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 25, -0.2)
	local pivot_head_rotation = Rotation(0, 0.5, 0)
	self.stances.m37.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m37.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m37.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.m37.steelsight.vel_overshot.yaw_neg = 3
	self.stances.m37.steelsight.vel_overshot.yaw_pos = -3
	self.stances.m37.steelsight.vel_overshot.pitch_neg = -10
	self.stances.m37.steelsight.vel_overshot.pitch_pos = 2
	local pivot_head_translation = Vector3(6.5, 21, -7)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m37.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m37.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m37.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_m1897()
	self.stances.m1897 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.27651, 15, -6)
	local pivot_shoulder_rotation = Rotation(4.57709e-05, 0.00055666, -0.000335693)
	local pivot_head_translation = Vector3(7.5, 22, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m1897.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m1897.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m1897.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.m1897.standard.vel_overshot.yaw_neg = 15
	self.stances.m1897.standard.vel_overshot.yaw_pos = -5
	self.stances.m1897.standard.vel_overshot.pitch_neg = -10
	self.stances.m1897.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 20, -0.2)
	local pivot_head_rotation = Rotation(0, 0.5, 0)
	self.stances.m1897.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m1897.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m1897.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.m1897.steelsight.vel_overshot.yaw_neg = 3
	self.stances.m1897.steelsight.vel_overshot.yaw_pos = -3
	self.stances.m1897.steelsight.vel_overshot.pitch_neg = -10
	self.stances.m1897.steelsight.vel_overshot.pitch_pos = 2
	local pivot_head_translation = Vector3(6.5, 21, -7)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m1897.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m1897.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m1897.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_china()
	self.stances.china = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(12.6957, 28.6528, -8.7)
	local pivot_shoulder_rotation = Rotation(4.47095e-05, 0.000589182, -0.000337808)
	local pivot_head_translation = Vector3(12, 18, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.china.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.china.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.china.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.china.standard.vel_overshot.yaw_neg = -5
	self.stances.china.standard.vel_overshot.yaw_pos = 5
	self.stances.china.standard.vel_overshot.pitch_neg = 5
	self.stances.china.standard.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(0, 25, -1)
	local pivot_head_rotation = Rotation(0, 2, 0)
	self.stances.china.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.china.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.china.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.china.steelsight.vel_overshot.yaw_neg = -5
	self.stances.china.steelsight.vel_overshot.yaw_pos = 5
	self.stances.china.steelsight.vel_overshot.pitch_neg = 5
	self.stances.china.steelsight.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(11, 17, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.china.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.china.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.china.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_sr2()
	self.stances.sr2 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.46072, 17.5362, -5.3306)
	local pivot_shoulder_rotation = Rotation(4.59269e-05, 0.000782065, -0.000335783)
	local pivot_head_translation = Vector3(7, 20, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sr2.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sr2.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sr2.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.sr2.standard.vel_overshot.yaw_neg = 10
	self.stances.sr2.standard.vel_overshot.yaw_pos = -10
	self.stances.sr2.standard.vel_overshot.pitch_neg = -10
	self.stances.sr2.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sr2.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sr2.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sr2.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.sr2.steelsight.vel_overshot.yaw_neg = 10
	self.stances.sr2.steelsight.vel_overshot.yaw_pos = -10
	self.stances.sr2.steelsight.vel_overshot.pitch_neg = -10
	self.stances.sr2.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(6, 19, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.sr2.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.sr2.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.sr2.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
end

function PlayerTweakData:_init_x_sr2()
	self.stances.x_sr2 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.95, 28, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_sr2.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_sr2.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_sr2.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_sr2.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_sr2.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_sr2.steelsight.zoom_fov = false
	self.stances.x_sr2.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_sr2.steelsight.vel_overshot.yaw_neg = 5
	self.stances.x_sr2.steelsight.vel_overshot.yaw_pos = -5
	self.stances.x_sr2.steelsight.vel_overshot.pitch_neg = -12
	self.stances.x_sr2.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10.95, 28, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_sr2.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_sr2.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_sr2.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_pl14()
	self.stances.pl14 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.44347, 40.2309, -5.37017)
	local pivot_shoulder_rotation = Rotation(0.100314, -0.688477, 0.629269)
	local pivot_head_translation = Vector3(6.5, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.pl14.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.pl14.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.pl14.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.pl14.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.pl14.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.pl14.steelsight.zoom_fov = false
	self.stances.pl14.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.pl14.steelsight.vel_overshot.yaw_neg = 5
	self.stances.pl14.steelsight.vel_overshot.yaw_pos = -5
	self.stances.pl14.steelsight.vel_overshot.pitch_neg = -12
	self.stances.pl14.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(5.5, 31, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.pl14.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.pl14.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.pl14.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_mp5()
	self.stances.x_mp5 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.95, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mp5.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mp5.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mp5.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mp5.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mp5.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mp5.steelsight.zoom_fov = false
	self.stances.x_mp5.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_mp5.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_mp5.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_mp5.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_mp5.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.95, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mp5.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mp5.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mp5.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_akmsu()
	self.stances.x_akmsu = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.95, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_akmsu.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_akmsu.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_akmsu.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 42, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_akmsu.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_akmsu.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_akmsu.steelsight.zoom_fov = false
	self.stances.x_akmsu.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_akmsu.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_akmsu.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_akmsu.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_akmsu.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.95, 37, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_akmsu.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_akmsu.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_akmsu.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_tecci()
	self.stances.tecci = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.2307, 11.2773, -3.55915)
	local pivot_shoulder_rotation = Rotation(5.14897e-05, 0.00122516, -0.000332118)
	local pivot_head_translation = Vector3(8.5, 12, -1.2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.tecci.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.tecci.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.tecci.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.tecci.steelsight.vel_overshot.pitch_neg = -17
	self.stances.tecci.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 10, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.tecci.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.tecci.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.tecci.steelsight.FOV = self.stances.tecci.standard.FOV
	self.stances.tecci.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.tecci.steelsight.vel_overshot.yaw_neg = 8
	self.stances.tecci.steelsight.vel_overshot.yaw_pos = -8
	self.stances.tecci.steelsight.vel_overshot.pitch_neg = -17
	self.stances.tecci.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(8.5, 11.5, -2.2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.tecci.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.tecci.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.tecci.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_hajk()
	self.stances.hajk = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.18603, 10.1026, -1.49307)
	local pivot_shoulder_rotation = Rotation(5.61948e-05, 0.000937625, -0.00030285)
	local pivot_head_translation = Vector3(9, 14, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hajk.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hajk.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hajk.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.hajk.steelsight.vel_overshot.pitch_neg = -17
	self.stances.hajk.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 10, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hajk.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hajk.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hajk.steelsight.FOV = self.stances.hajk.standard.FOV
	self.stances.hajk.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.hajk.steelsight.vel_overshot.yaw_neg = 8
	self.stances.hajk.steelsight.vel_overshot.yaw_pos = -8
	self.stances.hajk.steelsight.vel_overshot.pitch_neg = -17
	self.stances.hajk.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(8.5, 11.5, -2.2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.hajk.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hajk.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hajk.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_boot()
	self.stances.boot = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.33495, 21.5547, -4.86749)
	local pivot_shoulder_rotation = Rotation(0.00091203, 0.000168071, -0.000324595)
	local pivot_head_translation = Vector3(11, 26, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.boot.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.boot.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.boot.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.boot.steelsight.vel_overshot.pitch_neg = -17
	self.stances.boot.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 23, -0.3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.boot.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.boot.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.boot.steelsight.FOV = self.stances.boot.standard.FOV
	self.stances.boot.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.boot.steelsight.vel_overshot.yaw_neg = 1
	self.stances.boot.steelsight.vel_overshot.yaw_pos = -1
	self.stances.boot.steelsight.vel_overshot.pitch_neg = -5
	self.stances.boot.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(10, 25, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.boot.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.boot.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.boot.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_packrat()
	self.stances.packrat = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.43619, 40.2227, -6.04893)
	local pivot_shoulder_rotation = Rotation(0.100209, -0.688219, 0.630716)
	local pivot_head_translation = Vector3(10, 32, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.packrat.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.packrat.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.packrat.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -60, 0)
	self.stances.packrat.steelsight.vel_overshot.pitch_neg = -17
	self.stances.packrat.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 29, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.packrat.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.packrat.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.packrat.steelsight.FOV = self.stances.packrat.standard.FOV
	self.stances.packrat.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.packrat.steelsight.vel_overshot.yaw_neg = 1
	self.stances.packrat.steelsight.vel_overshot.yaw_pos = -1
	self.stances.packrat.steelsight.vel_overshot.pitch_neg = -5
	self.stances.packrat.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(9, 31, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.packrat.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.packrat.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.packrat.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_schakal()
	self.stances.schakal = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(7.87628, 9.54151, -2.2033)
	local pivot_shoulder_rotation = Rotation(5.55797e-05, 0.000568586, -0.000334093)
	local pivot_head_translation = Vector3(11, 18, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.schakal.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.schakal.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.schakal.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.schakal.steelsight.vel_overshot.pitch_neg = -17
	self.stances.schakal.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 15, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.schakal.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.schakal.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.schakal.steelsight.FOV = self.stances.schakal.standard.FOV
	self.stances.schakal.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.schakal.steelsight.vel_overshot.yaw_neg = 1
	self.stances.schakal.steelsight.vel_overshot.yaw_pos = -1
	self.stances.schakal.steelsight.vel_overshot.pitch_neg = -5
	self.stances.schakal.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(10, 17, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.schakal.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.schakal.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.schakal.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_desertfox()
	self.stances.desertfox = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(7.4322, 8.2886, -4.55909)
	local pivot_shoulder_rotation = Rotation(-0.18072, 0.18035, -0.180208)
	local pivot_head_translation = Vector3(11, 13, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.desertfox.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.desertfox.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.desertfox.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.desertfox.steelsight.vel_overshot.pitch_neg = -17
	self.stances.desertfox.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 23, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.desertfox.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.desertfox.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.desertfox.steelsight.FOV = self.stances.desertfox.standard.FOV
	self.stances.desertfox.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.desertfox.steelsight.vel_overshot.yaw_neg = 1
	self.stances.desertfox.steelsight.vel_overshot.yaw_pos = -1
	self.stances.desertfox.steelsight.vel_overshot.pitch_neg = -5
	self.stances.desertfox.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(10, 12, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.desertfox.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.desertfox.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.desertfox.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)

	function PlayerTweakData:_init_x_packrat()
		self.stances.x_packrat = deep_clone(self.stances.default)
		local pivot_shoulder_translation = Vector3(11.4939, 42.8789, -1.11447)
		local pivot_shoulder_rotation = Rotation(-0.347954, 0.253161, 0.281029)
		local pivot_head_translation = Vector3(10.95, 32, -4)
		local pivot_head_rotation = Rotation(0, 0, 0)
		self.stances.x_packrat.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
		self.stances.x_packrat.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		self.stances.x_packrat.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
		local pivot_head_translation = Vector3(10.95, 42, -3)
		local pivot_head_rotation = Rotation(0, 0, 0)
		self.stances.x_packrat.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
		self.stances.x_packrat.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		self.stances.x_packrat.steelsight.zoom_fov = false
		self.stances.x_packrat.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
		self.stances.x_packrat.steelsight.vel_overshot.yaw_neg = 5
		self.stances.x_packrat.steelsight.vel_overshot.yaw_pos = -5
		self.stances.x_packrat.steelsight.vel_overshot.pitch_neg = -12
		self.stances.x_packrat.steelsight.vel_overshot.pitch_pos = 12
		local pivot_head_translation = Vector3(10.95, 34, -4)
		local pivot_head_rotation = Rotation(0, 0, 0)
		self.stances.x_packrat.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
		self.stances.x_packrat.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		self.stances.x_packrat.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	end
end

function PlayerTweakData:_init_rota()
	self.stances.rota = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.4444, 18.1551, -2.51491)
	local pivot_shoulder_rotation = Rotation(4.7187e-05, 0.000580673, -0.000338008)
	local pivot_head_translation = Vector3(11, 17, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.rota.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rota.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rota.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.rota.standard.vel_overshot.yaw_neg = 15
	self.stances.rota.standard.vel_overshot.yaw_pos = -5
	self.stances.rota.standard.vel_overshot.pitch_neg = -10
	self.stances.rota.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 25, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.rota.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rota.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rota.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.rota.steelsight.vel_overshot.yaw_neg = 3
	self.stances.rota.steelsight.vel_overshot.yaw_pos = -3
	self.stances.rota.steelsight.vel_overshot.pitch_neg = -10
	self.stances.rota.steelsight.vel_overshot.pitch_pos = 2
	local pivot_head_translation = Vector3(10, 16, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.rota.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rota.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rota.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_arbiter()
	self.stances.arbiter = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(12.6007, 11.9289, 1.92507)
	local pivot_shoulder_rotation = Rotation(7.38981e-05, -0.000869142, -0.0013114)
	local pivot_head_translation = Vector3(11, 20, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.arbiter.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.arbiter.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.arbiter.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.arbiter.standard.vel_overshot.yaw_neg = 15
	self.stances.arbiter.standard.vel_overshot.yaw_pos = -15
	self.stances.arbiter.standard.vel_overshot.pitch_neg = -15
	self.stances.arbiter.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 20, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.arbiter.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.arbiter.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.arbiter.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.arbiter.steelsight.vel_overshot.yaw_neg = 0
	self.stances.arbiter.steelsight.vel_overshot.yaw_pos = -0
	self.stances.arbiter.steelsight.vel_overshot.pitch_neg = -0
	self.stances.arbiter.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(10, 19, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.arbiter.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.arbiter.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.arbiter.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_contraband()
	self.stances.contraband = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.5287, 22.9343, -2.3085)
	local pivot_shoulder_rotation = Rotation(6.99405e-05, 0.000377474, -0.000677576)
	local pivot_head_translation = Vector3(11, 20, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.contraband.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.contraband.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.contraband.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.contraband.standard.vel_overshot.yaw_neg = 15
	self.stances.contraband.standard.vel_overshot.yaw_pos = -15
	self.stances.contraband.standard.vel_overshot.pitch_neg = -15
	self.stances.contraband.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 20, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.contraband.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.contraband.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.contraband.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.contraband.steelsight.vel_overshot.yaw_neg = 3
	self.stances.contraband.steelsight.vel_overshot.yaw_pos = -3
	self.stances.contraband.steelsight.vel_overshot.pitch_neg = -10
	self.stances.contraband.steelsight.vel_overshot.pitch_pos = 2
	local pivot_head_translation = Vector3(10, 19, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.contraband.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.contraband.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.contraband.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_ray()
	self.stances.ray = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(2.48815, 7.60753, -5.20907)
	local pivot_shoulder_rotation = Rotation(0.106386, -0.085203, 0.628541)
	local pivot_head_translation = Vector3(3, 12, -2.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ray.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ray.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ray.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.ray.standard.vel_overshot.yaw_neg = -5
	self.stances.ray.standard.vel_overshot.yaw_pos = 1
	self.stances.ray.standard.vel_overshot.pitch_neg = 5
	self.stances.ray.standard.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(0, 10, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ray.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ray.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ray.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.ray.steelsight.vel_overshot.yaw_neg = -3
	self.stances.ray.steelsight.vel_overshot.yaw_pos = 3
	self.stances.ray.steelsight.vel_overshot.pitch_neg = 5
	self.stances.ray.steelsight.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(2, 9, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ray.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ray.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ray.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.ray.crouched.vel_overshot.yaw_neg = -5
	self.stances.ray.crouched.vel_overshot.yaw_pos = 5
	self.stances.ray.crouched.vel_overshot.pitch_neg = 5
	self.stances.ray.crouched.vel_overshot.pitch_pos = -5
end

function PlayerTweakData:_init_tti()
	self.stances.tti = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.36916, 15.8528, -0.934953)
	local pivot_shoulder_rotation = Rotation(-0.000713286, 0.00034839, -5.86914e-05)
	local pivot_head_translation = Vector3(8.5, 17, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.tti.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.tti.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.tti.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.tti.standard.vel_overshot.yaw_neg = -6
	self.stances.tti.standard.vel_overshot.yaw_pos = 6
	self.stances.tti.standard.vel_overshot.pitch_neg = 10
	self.stances.tti.standard.vel_overshot.pitch_pos = -10
	local pivot_head_translation = Vector3(0, 14, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.tti.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.tti.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.tti.steelsight.zoom_fov = false
	self.stances.tti.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.tti.steelsight.vel_overshot.yaw_neg = -0.5
	self.stances.tti.steelsight.vel_overshot.yaw_pos = 0.5
	self.stances.tti.steelsight.vel_overshot.pitch_neg = 1.5
	self.stances.tti.steelsight.vel_overshot.pitch_pos = -1.5
	local pivot_head_translation = Vector3(7.5, 16, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.tti.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.tti.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.tti.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.tti.crouched.vel_overshot.yaw_neg = -4
	self.stances.tti.crouched.vel_overshot.yaw_pos = 4
	self.stances.tti.crouched.vel_overshot.pitch_neg = 8
	self.stances.tti.crouched.vel_overshot.pitch_pos = -8
end

function PlayerTweakData:_init_siltstone()
	self.stances.siltstone = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.42981, 34.8465, -3.24468)
	local pivot_shoulder_rotation = Rotation(0.000198032, -7.19335e-05, -0.00179495)
	local pivot_head_translation = Vector3(8.5, 40, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.siltstone.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.siltstone.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.siltstone.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.siltstone.standard.vel_overshot.yaw_neg = -6
	self.stances.siltstone.standard.vel_overshot.yaw_pos = 6
	self.stances.siltstone.standard.vel_overshot.pitch_neg = 10
	self.stances.siltstone.standard.vel_overshot.pitch_pos = -10
	local pivot_head_translation = Vector3(0, 32, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.siltstone.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.siltstone.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.siltstone.steelsight.zoom_fov = false
	self.stances.siltstone.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.siltstone.steelsight.vel_overshot.yaw_neg = -0.5
	self.stances.siltstone.steelsight.vel_overshot.yaw_pos = 0.5
	self.stances.siltstone.steelsight.vel_overshot.pitch_neg = 1.5
	self.stances.siltstone.steelsight.vel_overshot.pitch_pos = -1.5
	local pivot_head_translation = Vector3(7.5, 39, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.siltstone.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.siltstone.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.siltstone.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.siltstone.crouched.vel_overshot.yaw_neg = -4
	self.stances.siltstone.crouched.vel_overshot.yaw_pos = 4
	self.stances.siltstone.crouched.vel_overshot.pitch_neg = 8
	self.stances.siltstone.crouched.vel_overshot.pitch_pos = -8
end

function PlayerTweakData:_init_flint()
	self.stances.flint = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.2469, 16.6957, -4.38158)
	local pivot_shoulder_rotation = Rotation(8.23052e-05, 0.000324433, -0.000804522)
	local pivot_head_translation = Vector3(10, 20, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.flint.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.flint.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.flint.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.flint.standard.vel_overshot.yaw_neg = -3
	self.stances.flint.standard.vel_overshot.yaw_pos = 3
	self.stances.flint.standard.vel_overshot.pitch_neg = 5
	self.stances.flint.standard.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(9, 19, -5.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.flint.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.flint.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.flint.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.flint.crouched.vel_overshot.yaw_neg = -2
	self.stances.flint.crouched.vel_overshot.yaw_pos = 2
	self.stances.flint.crouched.vel_overshot.pitch_neg = 3
	self.stances.flint.crouched.vel_overshot.pitch_pos = -3
	local pivot_head_translation = Vector3(0, 24, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.flint.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.flint.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.flint.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.flint.steelsight.vel_overshot.yaw_neg = -2
	self.stances.flint.steelsight.vel_overshot.yaw_pos = 2
	self.stances.flint.steelsight.vel_overshot.pitch_neg = 3
	self.stances.flint.steelsight.vel_overshot.pitch_pos = -3
end

function PlayerTweakData:_init_coal()
	self.stances.coal = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.6275, 30.2986, -3.54447)
	local pivot_shoulder_rotation = Rotation(5.21439e-05, 0.000583994, -0.000339108)
	local pivot_head_translation = Vector3(10, 33, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.coal.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.coal.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.coal.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.coal.standard.vel_overshot.yaw_neg = -5
	self.stances.coal.standard.vel_overshot.yaw_pos = 5
	self.stances.coal.standard.vel_overshot.pitch_neg = 7
	self.stances.coal.standard.vel_overshot.pitch_pos = -7
	local pivot_head_translation = Vector3(0, 24, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.coal.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.coal.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.coal.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.coal.steelsight.vel_overshot.yaw_neg = -4
	self.stances.coal.steelsight.vel_overshot.yaw_pos = 4
	self.stances.coal.steelsight.vel_overshot.pitch_neg = 5
	self.stances.coal.steelsight.vel_overshot.pitch_pos = -5
	local pivot_head_translation = Vector3(9, 32, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.coal.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.coal.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.coal.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.coal.crouched.vel_overshot.yaw_neg = -4
	self.stances.coal.crouched.vel_overshot.yaw_pos = 4
	self.stances.coal.crouched.vel_overshot.pitch_neg = 5
	self.stances.coal.crouched.vel_overshot.pitch_pos = -5
end

function PlayerTweakData:_init_lemming()
	self.stances.lemming = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.44788, 38.6251, -5.22182)
	local pivot_shoulder_rotation = Rotation(0.100018, -0.688258, 0.629664)
	local pivot_head_translation = Vector3(10, 32, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.lemming.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.lemming.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.lemming.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.lemming.steelsight.vel_overshot.pitch_neg = -17
	self.stances.lemming.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 29, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.lemming.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.lemming.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.lemming.steelsight.FOV = self.stances.lemming.standard.FOV
	self.stances.lemming.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.lemming.steelsight.vel_overshot.yaw_neg = 1
	self.stances.lemming.steelsight.vel_overshot.yaw_pos = -1
	self.stances.lemming.steelsight.vel_overshot.pitch_neg = -5
	self.stances.lemming.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(9, 31, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.lemming.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.lemming.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.lemming.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_chinchilla()
	self.stances.chinchilla = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.43099, 44.68, -2.92959)
	local pivot_shoulder_rotation = Rotation(0.100017, -0.688284, 0.608061)
	local pivot_head_translation = Vector3(10, 35, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.chinchilla.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.chinchilla.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.chinchilla.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.chinchilla.steelsight.vel_overshot.pitch_neg = -17
	self.stances.chinchilla.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 29, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.chinchilla.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.chinchilla.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.chinchilla.steelsight.FOV = self.stances.chinchilla.standard.FOV
	self.stances.chinchilla.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.chinchilla.steelsight.vel_overshot.yaw_neg = 1
	self.stances.chinchilla.steelsight.vel_overshot.yaw_pos = -1
	self.stances.chinchilla.steelsight.vel_overshot.pitch_neg = -5
	self.stances.chinchilla.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(9, 34, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.chinchilla.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.chinchilla.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.chinchilla.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_x_chinchilla()
	self.stances.x_chinchilla = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.0014, 44.6795, -2.91751)
	local pivot_shoulder_rotation = Rotation(0.100034, -0.688648, 0.42562)
	local pivot_head_translation = Vector3(9, 33, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_chinchilla.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_chinchilla.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_chinchilla.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.x_chinchilla.steelsight.vel_overshot.pitch_neg = -17
	self.stances.x_chinchilla.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(9, 40, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_chinchilla.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_chinchilla.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_chinchilla.steelsight.FOV = self.stances.x_chinchilla.standard.FOV
	self.stances.x_chinchilla.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.x_chinchilla.steelsight.vel_overshot.yaw_neg = 1
	self.stances.x_chinchilla.steelsight.vel_overshot.yaw_pos = -1
	self.stances.x_chinchilla.steelsight.vel_overshot.pitch_neg = -5
	self.stances.x_chinchilla.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(9, 32, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_chinchilla.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_chinchilla.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_chinchilla.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_model3()
	self.stances.model3 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.43099, 44.68, -2.92959)
	local pivot_shoulder_rotation = Rotation(0.100017, -0.688284, 0.608061)
	local pivot_head_translation = Vector3(10, 35, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.model3.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.model3.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.model3.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.model3.steelsight.vel_overshot.pitch_neg = -17
	self.stances.model3.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 29, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.model3.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.model3.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.model3.steelsight.FOV = self.stances.model3.standard.FOV
	self.stances.model3.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.model3.steelsight.vel_overshot.yaw_neg = 1
	self.stances.model3.steelsight.vel_overshot.yaw_pos = -1
	self.stances.model3.steelsight.vel_overshot.pitch_neg = -5
	self.stances.model3.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(9, 34, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.model3.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.model3.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.model3.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_x_model3()
	self.stances.x_model3 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(9.0014, 44.6795, -2.91751)
	local pivot_shoulder_rotation = Rotation(0.100034, -0.688648, 0.42562)
	local pivot_head_translation = Vector3(9, 33, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_model3.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_model3.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_model3.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.x_model3.steelsight.vel_overshot.pitch_neg = -17
	self.stances.x_model3.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(9, 40, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_model3.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_model3.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_model3.steelsight.FOV = self.stances.x_model3.standard.FOV
	self.stances.x_model3.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.x_model3.steelsight.vel_overshot.yaw_neg = 1
	self.stances.x_model3.steelsight.vel_overshot.yaw_pos = -1
	self.stances.x_model3.steelsight.vel_overshot.pitch_neg = -5
	self.stances.x_model3.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(9, 32, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_model3.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_model3.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_model3.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_shepheard()
	self.stances.shepheard = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.7119, 20.9514, -1.5095)
	local pivot_shoulder_rotation = Rotation(6.84226e-05, 0.000472966, -0.000622561)
	local pivot_head_translation = Vector3(10.5, 17, -2.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.shepheard.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.shepheard.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.shepheard.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.shepheard.steelsight.vel_overshot.pitch_neg = -17
	self.stances.shepheard.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 24, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.shepheard.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.shepheard.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.shepheard.steelsight.FOV = self.stances.shepheard.standard.FOV
	self.stances.shepheard.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.shepheard.steelsight.vel_overshot.yaw_neg = 1
	self.stances.shepheard.steelsight.vel_overshot.yaw_pos = -1
	self.stances.shepheard.steelsight.vel_overshot.pitch_neg = -5
	self.stances.shepheard.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(9.5, 16, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.shepheard.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.shepheard.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.shepheard.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_x_shepheard()
	self.stances.x_shepheard = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.8081, 23.3412, 1.673)
	local pivot_shoulder_rotation = Rotation(0.17741, -0.514444, 0.970515)
	local pivot_head_translation = Vector3(10.95, 19, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_shepheard.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_shepheard.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_shepheard.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 26, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_shepheard.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_shepheard.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_shepheard.steelsight.zoom_fov = false
	self.stances.x_shepheard.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_shepheard.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_shepheard.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_shepheard.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_shepheard.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.95, 17, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_shepheard.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_shepheard.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_shepheard.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_breech()
	self.stances.breech = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.14622, 27.4494, -3.81421)
	local pivot_shoulder_rotation = Rotation(0.160076, -0.075191, -0.10197)
	local pivot_head_translation = Vector3(10, 27, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.breech.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.breech.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.breech.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.breech.steelsight.vel_overshot.pitch_neg = -17
	self.stances.breech.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 35, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.breech.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.breech.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.breech.steelsight.FOV = self.stances.breech.standard.FOV
	self.stances.breech.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -27, 0)
	self.stances.breech.steelsight.vel_overshot.yaw_neg = 5
	self.stances.breech.steelsight.vel_overshot.yaw_pos = -5
	self.stances.breech.steelsight.vel_overshot.pitch_neg = -7
	self.stances.breech.steelsight.vel_overshot.pitch_pos = 7
	local pivot_head_translation = Vector3(9, 26, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.breech.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.breech.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.breech.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_ching()
	self.stances.ching = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.895, 16.2585, -2.67599)
	local pivot_shoulder_rotation = Rotation(4.6449e-05, 0.000568613, -0.000336067)
	local pivot_head_translation = Vector3(10, 18, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ching.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ching.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ching.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -22, 0)
	self.stances.ching.standard.vel_overshot.yaw_neg = -2
	self.stances.ching.standard.vel_overshot.yaw_pos = 2
	self.stances.ching.standard.vel_overshot.pitch_neg = 2
	self.stances.ching.standard.vel_overshot.pitch_pos = -2
	local pivot_head_translation = Vector3(0, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ching.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ching.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ching.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
	self.stances.ching.steelsight.vel_overshot.yaw_neg = -2
	self.stances.ching.steelsight.vel_overshot.yaw_pos = 2
	self.stances.ching.steelsight.vel_overshot.pitch_neg = 1
	self.stances.ching.steelsight.vel_overshot.pitch_pos = -1
	local pivot_head_translation = Vector3(9, 17, -5.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ching.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ching.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ching.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -22, 0)
	self.stances.ching.crouched.vel_overshot.yaw_neg = -3
	self.stances.ching.crouched.vel_overshot.yaw_pos = 3
	self.stances.ching.crouched.vel_overshot.pitch_neg = 2
	self.stances.ching.crouched.vel_overshot.pitch_pos = -2
end

function PlayerTweakData:_init_erma()
	self.stances.erma = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.49394, 27.436, -2.76126)
	local pivot_shoulder_rotation = Rotation(4.62656e-05, 0.000556874, -0.000332545)
	local pivot_head_translation = Vector3(8, 26, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.erma.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.erma.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.erma.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.erma.standard.vel_overshot.yaw_neg = 15
	self.stances.erma.standard.vel_overshot.yaw_pos = -15
	self.stances.erma.standard.vel_overshot.pitch_neg = -15
	self.stances.erma.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 24, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.erma.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.erma.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.erma.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -28, 0)
	self.stances.erma.steelsight.vel_overshot.yaw_neg = 10
	self.stances.erma.steelsight.vel_overshot.yaw_pos = -10
	self.stances.erma.steelsight.vel_overshot.pitch_neg = -10
	self.stances.erma.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(7, 25, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.erma.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.erma.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.erma.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_ecp()
	self.stances.ecp = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(3.56467, 19.1489, -4.35772)
	local pivot_shoulder_rotation = Rotation(0.000122739, 0.00080217, -6.66219e-05)
	local pivot_head_translation = Vector3(4, 18, -3)
	local pivot_head_rotation = Rotation(0, 0, 1)
	self.stances.ecp.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ecp.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ecp.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -22, 0)
	self.stances.ecp.standard.vel_overshot.yaw_neg = 5
	self.stances.ecp.standard.vel_overshot.yaw_pos = -5
	self.stances.ecp.standard.vel_overshot.pitch_neg = -5
	self.stances.ecp.standard.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(0, 24, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ecp.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ecp.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ecp.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
	self.stances.ecp.steelsight.vel_overshot.yaw_neg = -2
	self.stances.ecp.steelsight.vel_overshot.yaw_pos = 2
	self.stances.ecp.steelsight.vel_overshot.pitch_neg = 1
	self.stances.ecp.steelsight.vel_overshot.pitch_pos = -1
	local pivot_head_translation = Vector3(3, 17, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.ecp.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.ecp.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.ecp.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -22, 0)
	self.stances.ecp.crouched.vel_overshot.yaw_neg = -3
	self.stances.ecp.crouched.vel_overshot.yaw_pos = 3
	self.stances.ecp.crouched.vel_overshot.pitch_neg = 2
	self.stances.ecp.crouched.vel_overshot.pitch_pos = -2
end

function PlayerTweakData:_init_shrew()
	self.stances.shrew = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.45918, 40.2496, -4.0125)
	local pivot_shoulder_rotation = Rotation(0.100786, -0.68813, 0.629919)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.shrew.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.shrew.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.shrew.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.shrew.standard.vel_overshot.yaw_neg = 10
	self.stances.shrew.standard.vel_overshot.yaw_pos = -10
	self.stances.shrew.standard.vel_overshot.pitch_neg = -13
	self.stances.shrew.standard.vel_overshot.pitch_pos = 13
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.shrew.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.shrew.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.shrew.steelsight.FOV = self.stances.shrew.standard.FOV
	self.stances.shrew.steelsight.zoom_fov = false
	self.stances.shrew.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.shrew.steelsight.vel_overshot.yaw_neg = 8
	self.stances.shrew.steelsight.vel_overshot.yaw_pos = -8
	self.stances.shrew.steelsight.vel_overshot.pitch_neg = -8
	self.stances.shrew.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.shrew.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.shrew.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.shrew.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_x_shrew()
	self.stances.x_shrew = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.4139, 42.291, -2.06512)
	local pivot_shoulder_rotation = Rotation(-0.000180056, 0.00124487, -0.000512829)
	local pivot_head_translation = Vector3(10.95, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_shrew.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_shrew.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_shrew.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 42, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_shrew.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_shrew.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_shrew.steelsight.zoom_fov = false
	self.stances.x_shrew.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_shrew.steelsight.vel_overshot.yaw_neg = 5
	self.stances.x_shrew.steelsight.vel_overshot.yaw_pos = -5
	self.stances.x_shrew.steelsight.vel_overshot.pitch_neg = -12
	self.stances.x_shrew.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(10.95, 32, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_shrew.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_shrew.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_shrew.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_basset()
	self.stances.basset = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.8411, 23.0275, -2.16914)
	local pivot_shoulder_rotation = Rotation(4.34121e-05, -0.00103616, -0.000334039)
	local pivot_head_translation = Vector3(10, 20, -3)
	local pivot_head_rotation = Rotation(0, 0, 1)
	self.stances.basset.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.basset.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.basset.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -22, 0)
	self.stances.basset.standard.vel_overshot.yaw_neg = 5
	self.stances.basset.standard.vel_overshot.yaw_pos = -5
	self.stances.basset.standard.vel_overshot.pitch_neg = -5
	self.stances.basset.standard.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(0, 24, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.basset.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.basset.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.basset.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
	self.stances.basset.steelsight.vel_overshot.yaw_neg = -2
	self.stances.basset.steelsight.vel_overshot.yaw_pos = 2
	self.stances.basset.steelsight.vel_overshot.pitch_neg = 1
	self.stances.basset.steelsight.vel_overshot.pitch_pos = -1
	local pivot_head_translation = Vector3(9, 19, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.basset.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.basset.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.basset.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -22, 0)
	self.stances.basset.crouched.vel_overshot.yaw_neg = -3
	self.stances.basset.crouched.vel_overshot.yaw_pos = 3
	self.stances.basset.crouched.vel_overshot.pitch_neg = 2
	self.stances.basset.crouched.vel_overshot.pitch_pos = -2
end

function PlayerTweakData:_init_x_basset()
	self.stances.x_basset = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.582, 24.5843, -11.4445)
	local pivot_shoulder_rotation = Rotation(0.177415, -0.514434, 0.970513)
	local pivot_head_translation = Vector3(10.95, 20, -14)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_basset.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_basset.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_basset.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_basset.standard.vel_overshot.yaw_neg = -5
	self.stances.x_basset.standard.vel_overshot.yaw_pos = 5
	self.stances.x_basset.standard.vel_overshot.pitch_neg = 12
	self.stances.x_basset.standard.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.95, 32, -12)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_basset.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_basset.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_basset.steelsight.zoom_fov = false
	self.stances.x_basset.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_basset.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_basset.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_basset.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_basset.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.95, 22, -13)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_basset.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_basset.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_basset.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_basset.crouched.vel_overshot.yaw_neg = -5
	self.stances.x_basset.crouched.vel_overshot.yaw_pos = 5
	self.stances.x_basset.crouched.vel_overshot.pitch_neg = 12
	self.stances.x_basset.crouched.vel_overshot.pitch_pos = -12
end

function PlayerTweakData:_init_corgi()
	self.stances.corgi = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.8414, 20.7689, -4.23194)
	local pivot_shoulder_rotation = Rotation(2.71007e-05, -0.00103648, -0.000739368)
	local pivot_head_translation = Vector3(10, 18, -3)
	local pivot_head_rotation = Rotation(0, 0, 1)
	self.stances.corgi.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.corgi.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.corgi.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -22, 0)
	self.stances.corgi.standard.vel_overshot.yaw_neg = 5
	self.stances.corgi.standard.vel_overshot.yaw_pos = -5
	self.stances.corgi.standard.vel_overshot.pitch_neg = -5
	self.stances.corgi.standard.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(0, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.corgi.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.corgi.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.corgi.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
	self.stances.corgi.steelsight.vel_overshot.yaw_neg = -2
	self.stances.corgi.steelsight.vel_overshot.yaw_pos = 2
	self.stances.corgi.steelsight.vel_overshot.pitch_neg = 1
	self.stances.corgi.steelsight.vel_overshot.pitch_pos = -1
	local pivot_head_translation = Vector3(9, 19, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.corgi.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.corgi.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.corgi.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -22, 0)
	self.stances.corgi.crouched.vel_overshot.yaw_neg = -3
	self.stances.corgi.crouched.vel_overshot.yaw_pos = 3
	self.stances.corgi.crouched.vel_overshot.pitch_neg = 2
	self.stances.corgi.crouched.vel_overshot.pitch_pos = -2
end

function PlayerTweakData:_init_slap()
	self.stances.slap = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(6.62696, 28.6192, -5.18681)
	local pivot_shoulder_rotation = Rotation(3.37723e-05, 0.000599136, -0.000336921)
	local pivot_head_translation = Vector3(6, 24, -3)
	local pivot_head_rotation = Rotation(0, 0, 1)
	self.stances.slap.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.slap.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.slap.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -22, 0)
	self.stances.slap.standard.vel_overshot.yaw_neg = 5
	self.stances.slap.standard.vel_overshot.yaw_pos = -5
	self.stances.slap.standard.vel_overshot.pitch_neg = -5
	self.stances.slap.standard.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(0, 18, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.slap.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.slap.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.slap.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
	self.stances.slap.steelsight.vel_overshot.yaw_neg = -2
	self.stances.slap.steelsight.vel_overshot.yaw_pos = 2
	self.stances.slap.steelsight.vel_overshot.pitch_neg = 1
	self.stances.slap.steelsight.vel_overshot.pitch_pos = -1
	local pivot_head_translation = Vector3(4, 19, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.slap.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.slap.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.slap.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -22, 0)
	self.stances.slap.crouched.vel_overshot.yaw_neg = -3
	self.stances.slap.crouched.vel_overshot.yaw_pos = 3
	self.stances.slap.crouched.vel_overshot.pitch_neg = 2
	self.stances.slap.crouched.vel_overshot.pitch_pos = -21
end

function PlayerTweakData:_init_x_coal()
	self.stances.x_coal = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(21.7292, 50.4726, -2.2322)
	local pivot_shoulder_rotation = Rotation(-0.000329317, 9.74379e-05, -0.000336547)
	local pivot_head_translation = Vector3(21, 35, -8)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_coal.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_coal.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_coal.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(21, 59, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_coal.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_coal.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_coal.steelsight.zoom_fov = false
	self.stances.x_coal.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_coal.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_coal.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_coal.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_coal.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(21, 39, -8)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_coal.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_coal.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_coal.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_baka()
	self.stances.x_baka = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 50, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_baka.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_baka.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_baka.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 70, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_baka.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_baka.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_baka.steelsight.zoom_fov = false
	self.stances.x_baka.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_baka.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_baka.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_baka.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_baka.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 47, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_baka.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_baka.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_baka.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_cobray()
	self.stances.x_cobray = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 45, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_cobray.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_cobray.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_cobray.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 66, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_cobray.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_cobray.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_cobray.steelsight.zoom_fov = false
	self.stances.x_cobray.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_cobray.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_cobray.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_cobray.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_cobray.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 42, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_cobray.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_cobray.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_cobray.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_erma()
	self.stances.x_erma = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 42, -8)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_erma.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_erma.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_erma.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 56, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_erma.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_erma.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_erma.steelsight.zoom_fov = false
	self.stances.x_erma.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_erma.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_erma.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_erma.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_erma.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 38, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_erma.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_erma.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_erma.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_hajk()
	self.stances.x_hajk = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -8)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_hajk.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_hajk.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_hajk.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 56, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_hajk.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_hajk.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_hajk.steelsight.zoom_fov = false
	self.stances.x_hajk.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_hajk.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_hajk.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_hajk.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_hajk.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_hajk.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_hajk.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_hajk.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_m45()
	self.stances.x_m45 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_m45.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_m45.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_m45.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 56, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_m45.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_m45.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_m45.steelsight.zoom_fov = false
	self.stances.x_m45.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_m45.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_m45.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_m45.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_m45.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_m45.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_m45.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_m45.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_m1928()
	self.stances.x_m1928 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_m1928.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_m1928.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_m1928.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 56, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_m1928.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_m1928.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_m1928.steelsight.zoom_fov = false
	self.stances.x_m1928.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_m1928.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_m1928.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_m1928.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_m1928.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_m1928.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_m1928.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_m1928.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_mac10()
	self.stances.x_mac10 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 48, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mac10.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mac10.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mac10.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 66, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mac10.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mac10.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mac10.steelsight.zoom_fov = false
	self.stances.x_mac10.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_mac10.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_mac10.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_mac10.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_mac10.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 45, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mac10.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mac10.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mac10.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_mp7()
	self.stances.x_mp7 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 47, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mp7.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mp7.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mp7.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 66, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mp7.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mp7.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mp7.steelsight.zoom_fov = false
	self.stances.x_mp7.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_mp7.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_mp7.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_mp7.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_mp7.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 45, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mp7.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mp7.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mp7.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_mp9()
	self.stances.x_mp9 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 50, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mp9.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mp9.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mp9.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 66, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mp9.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mp9.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mp9.steelsight.zoom_fov = false
	self.stances.x_mp9.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_mp9.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_mp9.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_mp9.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_mp9.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 47, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_mp9.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_mp9.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_mp9.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_olympic()
	self.stances.x_olympic = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -7)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_olympic.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_olympic.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_olympic.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 56, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_olympic.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_olympic.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_olympic.steelsight.zoom_fov = false
	self.stances.x_olympic.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_olympic.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_olympic.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_olympic.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_olympic.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_olympic.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_olympic.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_olympic.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_p90()
	self.stances.x_p90 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(21.7292, 50.4726, -2.2322)
	local pivot_shoulder_rotation = Rotation(-0.000329317, 9.74379e-05, -0.000336547)
	local pivot_head_translation = Vector3(21, 42, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_p90.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_p90.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_p90.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(21, 59, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_p90.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_p90.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_p90.steelsight.zoom_fov = false
	self.stances.x_p90.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_p90.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_p90.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_p90.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_p90.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(21, 39, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_p90.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_p90.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_p90.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_polymer()
	self.stances.x_polymer = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_polymer.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_polymer.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_polymer.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 56, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_polymer.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_polymer.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_polymer.steelsight.zoom_fov = false
	self.stances.x_polymer.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_polymer.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_polymer.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_polymer.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_polymer.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_polymer.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_polymer.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_polymer.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_schakal()
	self.stances.x_schakal = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_schakal.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_schakal.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_schakal.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 56, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_schakal.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_schakal.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_schakal.steelsight.zoom_fov = false
	self.stances.x_schakal.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_schakal.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_schakal.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_schakal.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_schakal.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_schakal.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_schakal.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_schakal.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_scorpion()
	self.stances.x_scorpion = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_scorpion.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_scorpion.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_scorpion.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 66, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_scorpion.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_scorpion.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_scorpion.steelsight.zoom_fov = false
	self.stances.x_scorpion.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_scorpion.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_scorpion.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_scorpion.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_scorpion.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_scorpion.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_scorpion.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_scorpion.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_sterling()
	self.stances.x_sterling = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(21.7292, 50.4726, -2.2322)
	local pivot_shoulder_rotation = Rotation(-0.000329317, 9.74379e-05, -0.000336547)
	local pivot_head_translation = Vector3(21, 39, -8)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_sterling.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_sterling.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_sterling.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(21, 59, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_sterling.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_sterling.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_sterling.steelsight.zoom_fov = false
	self.stances.x_sterling.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_sterling.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_sterling.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_sterling.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_sterling.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(21, 37, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_sterling.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_sterling.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_sterling.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_tec9()
	self.stances.x_tec9 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 50, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_tec9.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_tec9.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_tec9.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 66, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_tec9.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_tec9.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_tec9.steelsight.zoom_fov = false
	self.stances.x_tec9.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_tec9.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_tec9.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_tec9.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_tec9.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 47, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_tec9.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_tec9.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_tec9.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_uzi()
	self.stances.x_uzi = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 49, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_uzi.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_uzi.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_uzi.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 66, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_uzi.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_uzi.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_uzi.steelsight.zoom_fov = false
	self.stances.x_uzi.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_uzi.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_uzi.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_uzi.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_uzi.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 47, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_uzi.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_uzi.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_uzi.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_2006m()
	self.stances.x_2006m = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 35, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_2006m.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_2006m.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_2006m.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 56, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_2006m.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_2006m.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_2006m.steelsight.zoom_fov = false
	self.stances.x_2006m.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_2006m.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_2006m.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_2006m.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_2006m.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 34, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_2006m.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_2006m.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_2006m.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_breech()
	self.stances.x_breech = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 35, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_breech.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_breech.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_breech.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 56, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_breech.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_breech.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_breech.steelsight.zoom_fov = false
	self.stances.x_breech.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_breech.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_breech.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_breech.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_breech.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 34, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_breech.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_breech.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_breech.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_c96()
	self.stances.x_c96 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 35, -7)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_c96.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_c96.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_c96.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_c96.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_c96.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_c96.steelsight.zoom_fov = false
	self.stances.x_c96.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_c96.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_c96.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_c96.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_c96.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 34, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_c96.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_c96.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_c96.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_g18c()
	self.stances.x_g18c = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_g18c.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_g18c.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_g18c.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_g18c.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_g18c.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_g18c.steelsight.zoom_fov = false
	self.stances.x_g18c.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_g18c.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_g18c.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_g18c.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_g18c.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_g18c.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_g18c.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_g18c.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_hs2000()
	self.stances.x_hs2000 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_hs2000.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_hs2000.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_hs2000.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_hs2000.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_hs2000.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_hs2000.steelsight.zoom_fov = false
	self.stances.x_hs2000.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_hs2000.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_hs2000.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_hs2000.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_hs2000.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_hs2000.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_hs2000.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_hs2000.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_lemming()
	self.stances.x_lemming = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_lemming.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_lemming.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_lemming.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_lemming.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_lemming.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_lemming.steelsight.zoom_fov = false
	self.stances.x_lemming.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_lemming.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_lemming.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_lemming.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_lemming.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_lemming.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_lemming.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_lemming.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_p226()
	self.stances.x_p226 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_p226.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_p226.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_p226.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_p226.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_p226.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_p226.steelsight.zoom_fov = false
	self.stances.x_p226.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_p226.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_p226.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_p226.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_p226.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_p226.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_p226.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_p226.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_peacemaker()
	self.stances.x_peacemaker = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_peacemaker.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_peacemaker.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_peacemaker.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_peacemaker.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_peacemaker.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_peacemaker.steelsight.zoom_fov = false
	self.stances.x_peacemaker.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_peacemaker.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_peacemaker.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_peacemaker.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_peacemaker.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_peacemaker.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_peacemaker.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_peacemaker.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_pl14()
	self.stances.x_pl14 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_pl14.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_pl14.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_pl14.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_pl14.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_pl14.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_pl14.steelsight.zoom_fov = false
	self.stances.x_pl14.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_pl14.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_pl14.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_pl14.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_pl14.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_pl14.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_pl14.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_pl14.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_ppk()
	self.stances.x_ppk = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_ppk.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_ppk.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_ppk.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_ppk.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_ppk.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_ppk.steelsight.zoom_fov = false
	self.stances.x_ppk.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_ppk.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_ppk.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_ppk.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_ppk.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_ppk.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_ppk.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_ppk.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_rage()
	self.stances.x_rage = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 32, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_rage.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_rage.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_rage.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_rage.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_rage.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_rage.steelsight.zoom_fov = false
	self.stances.x_rage.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_rage.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_rage.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_rage.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_rage.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 34, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_rage.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_rage.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_rage.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_sparrow()
	self.stances.x_sparrow = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_sparrow.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_sparrow.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_sparrow.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_sparrow.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_sparrow.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_sparrow.steelsight.zoom_fov = false
	self.stances.x_sparrow.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_sparrow.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_sparrow.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_sparrow.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_sparrow.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_sparrow.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_sparrow.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_sparrow.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_judge()
	self.stances.x_judge = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.4, 34, -7)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_judge.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_judge.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_judge.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.4, 46, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_judge.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_judge.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_judge.steelsight.zoom_fov = false
	self.stances.x_judge.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_judge.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_judge.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_judge.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_judge.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.4, 33, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_judge.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_judge.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_judge.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_x_rota()
	self.stances.x_rota = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_rota.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_rota.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_rota.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_rota.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_rota.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_rota.steelsight.zoom_fov = false
	self.stances.x_rota.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_rota.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_rota.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_rota.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_rota.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_rota.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_rota.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_rota.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_shuno()
	self.stances.shuno = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(7.51824, 28.414, -10.4346)
	local pivot_shoulder_rotation = Rotation(-0.552457, 0.0015095, -0.000355581)
	local pivot_head_translation = Vector3(2, 28, -15)
	local pivot_head_rotation = Rotation(0, 0, -5)
	self.stances.shuno.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.shuno.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.shuno.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, -10)
	self.stances.shuno.standard.vel_overshot.yaw_neg = -10
	self.stances.shuno.standard.vel_overshot.yaw_pos = 10
	self.stances.shuno.standard.vel_overshot.pitch_neg = 20
	self.stances.shuno.standard.vel_overshot.pitch_pos = -20
	local pivot_head_translation = Vector3(1, 27, -11)
	local pivot_head_rotation = Rotation(0, 0, -12)
	self.stances.shuno.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.shuno.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.shuno.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.shuno.steelsight.vel_overshot.yaw_neg = -5
	self.stances.shuno.steelsight.vel_overshot.yaw_pos = 5
	self.stances.shuno.steelsight.vel_overshot.pitch_neg = 10
	self.stances.shuno.steelsight.vel_overshot.pitch_pos = -10
	local pivot_head_translation = Vector3(2, 25, -13)
	local pivot_head_rotation = Rotation(0, 0, -8)
	self.stances.shuno.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.shuno.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.shuno.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
end

function PlayerTweakData:_init_system()
	self.stances.system = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.3456, 14.9643, -6.50593)
	local pivot_shoulder_rotation = Rotation(9.27922e-05, 0.000287294, -0.000913965)
	local pivot_head_translation = Vector3(8, 12, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.system.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.system.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.system.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	local pivot_head_translation = Vector3(4, 18, -1)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.system.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.system.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.system.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.system.steelsight.vel_overshot.yaw_neg = 12
	self.stances.system.steelsight.vel_overshot.yaw_pos = -12
	self.stances.system.steelsight.vel_overshot.pitch_neg = -12
	self.stances.system.steelsight.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(8, 12, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.system.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.system.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.system.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_komodo()
	self.stances.komodo = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.0169, 20.9827, -4.40513)
	local pivot_shoulder_rotation = Rotation(6.55088e-05, -0.000647214, -0.00119165)
	local pivot_head_translation = Vector3(8, 12, -2)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.komodo.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.komodo.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.komodo.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	local pivot_head_translation = Vector3(0, 12, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.komodo.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.komodo.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.komodo.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.komodo.steelsight.vel_overshot.yaw_neg = 5
	self.stances.komodo.steelsight.vel_overshot.yaw_pos = -5
	self.stances.komodo.steelsight.vel_overshot.pitch_neg = -5
	self.stances.komodo.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(7, 12, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.komodo.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.komodo.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.komodo.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
end

function PlayerTweakData:_init_elastic()
	self.stances.elastic = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(15.328, 54.4645, -10.5711)
	local pivot_shoulder_rotation = Rotation(0.515132, 0.430888, 56.0449)
	local pivot_head_translation = Vector3(10, 35, -10)
	local pivot_head_rotation = Rotation(0, 0, 60)
	self.stances.elastic.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.elastic.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.elastic.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.elastic.standard.vel_overshot.yaw_neg = 15
	self.stances.elastic.standard.vel_overshot.yaw_pos = -15
	self.stances.elastic.standard.vel_overshot.pitch_neg = -15
	self.stances.elastic.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 23, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.elastic.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.elastic.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.elastic.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.elastic.steelsight.vel_overshot.yaw_neg = 0
	self.stances.elastic.steelsight.vel_overshot.yaw_pos = 0
	self.stances.elastic.steelsight.vel_overshot.pitch_neg = 0
	self.stances.elastic.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(8, 33, -10)
	local pivot_head_rotation = Rotation(0, 0, 60)
	self.stances.elastic.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.elastic.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.elastic.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
end

function PlayerTweakData:_init_legacy()
	self.stances.legacy = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.43673, 36.8199, -6.54269)
	local pivot_shoulder_rotation = Rotation(0.101406, -0.687195, 0.629709)
	local pivot_head_translation = Vector3(10, 31, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.legacy.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.legacy.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.legacy.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.legacy.steelsight.vel_overshot.pitch_neg = -17
	self.stances.legacy.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 29, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.legacy.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.legacy.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.legacy.steelsight.FOV = self.stances.lemming.standard.FOV
	self.stances.legacy.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -15, 0)
	self.stances.legacy.steelsight.vel_overshot.yaw_neg = 1
	self.stances.legacy.steelsight.vel_overshot.yaw_pos = -1
	self.stances.legacy.steelsight.vel_overshot.pitch_neg = -5
	self.stances.legacy.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(9, 31, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.legacy.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.legacy.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.legacy.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
end

function PlayerTweakData:_init_x_legacy()
	self.stances.x_legacy = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.1326, 41.1752, -3.20809)
	local pivot_shoulder_rotation = Rotation(2.1268e-06, 1.05169e-06, -0.838063)
	local pivot_head_translation = Vector3(10.95, 29, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_legacy.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_legacy.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_legacy.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -56, 0)
	local pivot_head_translation = Vector3(10.7, 46, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_legacy.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_legacy.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_legacy.steelsight.zoom_fov = false
	self.stances.x_legacy.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	self.stances.x_legacy.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_legacy.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_legacy.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_legacy.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.95, 27, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_legacy.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_legacy.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_legacy.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -56, 0)
end

function PlayerTweakData:_init_coach()
	self.stances.coach = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.7495, 27.138, -6.31249)
	local pivot_shoulder_rotation = Rotation(3.9432e-05, 0.000561356, -0.000336387)
	local pivot_head_translation = Vector3(8, 20, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.coach.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.coach.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.coach.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.coach.standard.vel_overshot.yaw_neg = 10
	self.stances.coach.standard.vel_overshot.yaw_pos = -10
	self.stances.coach.standard.vel_overshot.pitch_neg = -10
	self.stances.coach.standard.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(0, 30.5, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.coach.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.coach.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.coach.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.coach.steelsight.vel_overshot.yaw_neg = 10
	self.stances.coach.steelsight.vel_overshot.yaw_pos = -10
	self.stances.coach.steelsight.vel_overshot.pitch_neg = -10
	self.stances.coach.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(7, 20, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.coach.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.coach.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.coach.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -25, 0)
end

function PlayerTweakData:_init_beer()
	self.stances.beer = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.66726, 32.1883, -2.86906)
	local pivot_shoulder_rotation = Rotation(4.44732e-05, 0.000568556, 0.000264643)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.beer.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.beer.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.beer.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.beer.standard.vel_overshot.yaw_neg = 10
	self.stances.beer.standard.vel_overshot.yaw_pos = -10
	self.stances.beer.standard.vel_overshot.pitch_neg = -13
	self.stances.beer.standard.vel_overshot.pitch_pos = 13
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.beer.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.beer.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.beer.steelsight.FOV = self.stances.beer.standard.FOV
	self.stances.beer.steelsight.zoom_fov = false
	self.stances.beer.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.beer.steelsight.vel_overshot.yaw_neg = 8
	self.stances.beer.steelsight.vel_overshot.yaw_pos = -8
	self.stances.beer.steelsight.vel_overshot.pitch_neg = -8
	self.stances.beer.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.beer.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.beer.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.beer.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_x_beer()
	self.stances.x_beer = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.3477, 43.0448, -2.16278)
	local pivot_shoulder_rotation = Rotation(1.99716e-07, 1.26747e-06, -0.185805)
	local pivot_head_translation = Vector3(10.5, 39, -7)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_beer.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_beer.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_beer.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_beer.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_beer.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_beer.steelsight.zoom_fov = false
	self.stances.x_beer.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_beer.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_beer.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_beer.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_beer.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_beer.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_beer.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_beer.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_czech()
	self.stances.czech = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.66723, 30.1231, -3.12016)
	local pivot_shoulder_rotation = Rotation(3.37549e-05, 0.000953238, -0.000301382)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.czech.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.czech.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.czech.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.czech.standard.vel_overshot.yaw_neg = 10
	self.stances.czech.standard.vel_overshot.yaw_pos = -10
	self.stances.czech.standard.vel_overshot.pitch_neg = -13
	self.stances.czech.standard.vel_overshot.pitch_pos = 13
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.czech.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.czech.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.czech.steelsight.FOV = self.stances.czech.standard.FOV
	self.stances.czech.steelsight.zoom_fov = false
	self.stances.czech.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.czech.steelsight.vel_overshot.yaw_neg = 8
	self.stances.czech.steelsight.vel_overshot.yaw_pos = -8
	self.stances.czech.steelsight.vel_overshot.pitch_neg = -8
	self.stances.czech.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.czech.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.czech.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.czech.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_x_czech()
	self.stances.x_czech = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(11.4072, 41.148, -2.49424)
	local pivot_shoulder_rotation = Rotation(-2.10775e-06, 3.55069e-10, -0.0193039)
	local pivot_head_translation = Vector3(10.5, 32, -7)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_czech.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_czech.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_czech.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -56, 0)
	local pivot_head_translation = Vector3(10.5, 40, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_czech.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_czech.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_czech.steelsight.zoom_fov = false
	self.stances.x_czech.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_czech.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_czech.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_czech.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_czech.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 30, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_czech.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_czech.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_czech.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_stech()
	self.stances.stech = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.46191, 38.5443, -3.96121)
	local pivot_shoulder_rotation = Rotation(0.100041, -0.688248, 0.629668)
	local pivot_head_translation = Vector3(7, 31, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.stech.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.stech.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.stech.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -35, 0)
	self.stances.stech.standard.vel_overshot.yaw_neg = 10
	self.stances.stech.standard.vel_overshot.yaw_pos = -10
	self.stances.stech.standard.vel_overshot.pitch_neg = -13
	self.stances.stech.standard.vel_overshot.pitch_pos = 13
	local pivot_head_translation = Vector3(0, 37, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.stech.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.stech.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.stech.steelsight.FOV = self.stances.stech.standard.FOV
	self.stances.stech.steelsight.zoom_fov = false
	self.stances.stech.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -40, 0)
	self.stances.stech.steelsight.vel_overshot.yaw_neg = 8
	self.stances.stech.steelsight.vel_overshot.yaw_pos = -8
	self.stances.stech.steelsight.vel_overshot.pitch_neg = -8
	self.stances.stech.steelsight.vel_overshot.pitch_pos = 8
	local pivot_head_translation = Vector3(6, 30, -4)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.stech.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.stech.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.stech.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end

function PlayerTweakData:_init_x_stech()
	self.stances.x_stech = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.5, 39, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_stech.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_stech.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_stech.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.5, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_stech.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_stech.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_stech.steelsight.zoom_fov = false
	self.stances.x_stech.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_stech.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_stech.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_stech.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_stech.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.5, 37, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_stech.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_stech.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_stech.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_holt()
	self.stances.holt = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(8.43514, 38.6107, -6.42505)
	local pivot_shoulder_rotation = Rotation(0.0999955, -0.688249, 0.629656)
	local pivot_head_translation = Vector3(7.8, 32, -4)
	local pivot_head_rotation = Rotation(0, 1.5, -3)
	self.stances.holt.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.holt.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.holt.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
	self.stances.holt.steelsight.vel_overshot.pitch_neg = -17
	self.stances.holt.steelsight.vel_overshot.pitch_pos = 17
	local pivot_head_translation = Vector3(0, 29, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.holt.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.holt.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.holt.steelsight.FOV = self.stances.lemming.standard.FOV
	self.stances.holt.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -7, 0)
	self.stances.holt.steelsight.vel_overshot.yaw_neg = 1
	self.stances.holt.steelsight.vel_overshot.yaw_pos = -1
	self.stances.holt.steelsight.vel_overshot.pitch_neg = -5
	self.stances.holt.steelsight.vel_overshot.pitch_pos = 5
	local pivot_head_translation = Vector3(5, 28, -6)
	local pivot_head_rotation = Rotation(-0, 0, -3)
	self.stances.holt.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.holt.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.holt.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -20, 0)
end

function PlayerTweakData:_init_x_holt()
	self.stances.x_holt = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.9257, 47.3309, -0.659333)
	local pivot_shoulder_rotation = Rotation(-7.3371e-08, -8.32429e-06, -1.70755e-06)
	local pivot_head_translation = Vector3(10.95, 40, -3.5)
	local pivot_head_rotation = Rotation(0, -2, 0)
	self.stances.x_holt.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_holt.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_holt.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -86, 0)
	local pivot_head_translation = Vector3(10.95, 46, -3)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.x_holt.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_holt.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_holt.steelsight.zoom_fov = false
	self.stances.x_holt.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
	self.stances.x_holt.steelsight.vel_overshot.yaw_neg = -5
	self.stances.x_holt.steelsight.vel_overshot.yaw_pos = 5
	self.stances.x_holt.steelsight.vel_overshot.pitch_neg = 12
	self.stances.x_holt.steelsight.vel_overshot.pitch_pos = -12
	local pivot_head_translation = Vector3(10.95, 37, -3)
	local pivot_head_rotation = Rotation(-1, 3, 0)
	self.stances.x_holt.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.x_holt.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.x_holt.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -36, 0)
end

function PlayerTweakData:_init_m60()
	self.stances.m60 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.7056, 4.38842, -0.747177)
	local pivot_shoulder_rotation = Rotation(0.106618, -0.084954, 0.62858)
	local pivot_head_translation = Vector3(11, 9, -3.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m60.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m60.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m60.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -10, 0)
	self.stances.m60.standard.vel_overshot.yaw_neg = 15
	self.stances.m60.standard.vel_overshot.yaw_pos = -15
	self.stances.m60.standard.vel_overshot.pitch_neg = -15
	self.stances.m60.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(7.5, 6, -2)
	local pivot_head_rotation = Rotation(0, 0, -5)
	self.stances.m60.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m60.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m60.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -18, 0)
	self.stances.m60.steelsight.vel_overshot.yaw_neg = 10
	self.stances.m60.steelsight.vel_overshot.yaw_pos = -10
	self.stances.m60.steelsight.vel_overshot.pitch_neg = -10
	self.stances.m60.steelsight.vel_overshot.pitch_pos = 10
	local pivot_head_translation = Vector3(10, 5, -4.5)
	local pivot_head_rotation = Rotation(0, 0, -5)
	self.stances.m60.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m60.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m60.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
	self.stances.m60.bipod = {
		shoulders = {},
		vel_overshot = {}
	}
	local pivot_head_translation = Vector3(0, 6, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.m60.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m60.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m60.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.m60.bipod.vel_overshot.yaw_neg = 0
	self.stances.m60.bipod.vel_overshot.yaw_pos = 0
	self.stances.m60.bipod.vel_overshot.pitch_neg = 0
	self.stances.m60.bipod.vel_overshot.pitch_pos = 0
	self.stances.m60.bipod.FOV = 50
	self.stances.m60.bipod.shakers = {
		breathing = {}
	}
	self.stances.m60.bipod.shakers.breathing.amplitude = 0
end

function PlayerTweakData:_init_r700()
	self.stances.r700 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(7.96548, 39.0752, -3.76283)
	local pivot_shoulder_rotation = Rotation(-3.68456e-05, 1.02449e-05, 0.00104715)
	local pivot_head_translation = Vector3(10, 42, -5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.r700.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.r700.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.r700.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -55, 0)
	self.stances.r700.standard.vel_overshot.yaw_neg = 12
	self.stances.r700.standard.vel_overshot.yaw_pos = -12
	self.stances.r700.standard.vel_overshot.pitch_neg = -12
	self.stances.r700.standard.vel_overshot.pitch_pos = 12
	local pivot_head_translation = Vector3(0, 47, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.r700.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.r700.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.r700.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.r700.steelsight.vel_overshot.yaw_neg = 0
	self.stances.r700.steelsight.vel_overshot.yaw_pos = -0
	self.stances.r700.steelsight.vel_overshot.pitch_neg = -0
	self.stances.r700.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(9, 41, -6)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.r700.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.r700.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.r700.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end
