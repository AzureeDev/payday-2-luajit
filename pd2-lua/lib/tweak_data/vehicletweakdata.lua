VehicleTweakData = VehicleTweakData or class()

function VehicleTweakData:init(tweak_data)
	self:_init_data_falcogini()
	self:_init_data_muscle()
	self:_init_data_forklift()
	self:_init_data_forklift_2()
	self:_init_data_box_truck_1()
	self:_init_data_mower_1()
	self:_init_data_boat_rib_1()
	self:_init_data_blackhawk_1()
	self:_init_data_bike_1()
	self:_init_data_bike_2()
end

function VehicleTweakData:_init_data_falcogini()
	self.falcogini = {
		name = "Falcogini",
		hud_label_offset = 140,
		animations = {
			passenger_front = "drive_falcogini_passanger",
			vehicle_id = "falcogini",
			driver = "drive_falcogini_driver"
		},
		sound = {
			bump = "car_bumper_01",
			slip = "car_skid_01",
			door_close = "car_door_open",
			bump_rtpc = "car_bump_vel",
			bump_treshold = 5,
			slip_stop = "car_skid_stop_01",
			engine_rpm_rtpc = "car_falcogini_rpm",
			broken_engine = "falcogini_engine_broken_loop",
			engine_sound_event = "falcogini",
			hit = "car_hit_gen_01",
			lateral_slip_treshold = 0.25,
			fix_engine_stop = "falcogini_engine_fix_stop",
			hit_rtpc = "car_hit_vel",
			engine_start = "falcogini_engine_start",
			fix_engine_loop = "falcogini_engine_fix_loop",
			longitudal_slip_treshold = 0.8,
			engine_speed_rtpc = "car_falcogini_speed"
		},
		seats = {
			driver = {
				driving = true,
				name = "driver"
			},
			passenger_front = {
				name = "passenger_front",
				has_shooting_mode = true,
				allow_shooting = false,
				driving = false,
				shooting_pos = Vector3(50, -20, 50)
			}
		},
		loot_points = {loot = {name = "loot"}},
		damage = {max_health = 100000},
		max_speed = 200,
		max_rpm = 9000,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 2,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0, 2.5),
		fov = 75
	}
end

function VehicleTweakData:_init_data_muscle()
	self.muscle = {
		name = "Longfellow",
		hud_label_offset = 150,
		animations = {
			passenger_back_right = "drive_muscle_back_right",
			vehicle_id = "muscle",
			passenger_back_left = "drive_muscle_back_left",
			passenger_front = "drive_muscle_passanger",
			driver = "drive_muscle_driver"
		},
		sound = {
			broken_engine = "falcogini_engine_broken_loop",
			bump = "car_bumper_01",
			lateral_slip_treshold = 0.35,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 8,
			slip_stop = "car_skid_stop_01",
			slip = "car_skid_01",
			hit_rtpc = "car_hit_vel",
			engine_rpm_rtpc = "car_falcogini_rpm",
			longitudal_slip_treshold = 0.8,
			engine_speed_rtpc = "car_falcogini_speed",
			door_close = "car_door_open",
			engine_sound_event = "muscle",
			hit = "car_hit_gen_01"
		},
		seats = {
			driver = {
				driving = true,
				name = "driver"
			},
			passenger_front = {
				name = "passenger_front",
				has_shooting_mode = true,
				allow_shooting = false,
				driving = false,
				shooting_pos = Vector3(50, -20, 50)
			},
			passenger_back_left = {
				allow_shooting = false,
				name = "passenger_back_left",
				has_shooting_mode = true,
				driving = false
			},
			passenger_back_right = {
				allow_shooting = false,
				name = "passenger_back_right",
				has_shooting_mode = true,
				driving = false
			}
		},
		loot_points = {
			loot_left = {name = "loot_left"},
			loot_right = {name = "loot_right"},
			loot = {name = "loot"}
		},
		trunk_point = "trunk",
		damage = {max_health = 9000000},
		max_speed = 160,
		max_rpm = 8000,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 4,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0.2, 2.5),
		fov = 75
	}
end

function VehicleTweakData:_init_data_forklift()
	self.forklift = {
		name = "Forklift",
		hud_label_offset = 220,
		animations = {
			passenger_front = "drive_forklift_passanger",
			vehicle_id = "forklift",
			driver = "drive_forklift_driver"
		},
		sound = {
			engine_sound_event = "forklift",
			slip_stop = "car_skid_stop_01",
			lateral_slip_treshold = 10,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 5,
			going_reverse_stop = "forklift_reverse_warning_stop",
			slip = "car_skid_01",
			bump = "car_bumper_01",
			engine_start = "forklift_start",
			hit_rtpc = "car_hit_vel",
			longitudal_slip_treshold = 10,
			engine_speed_rtpc = "car_falcogini_speed",
			door_close = "sit_down_in_forklift",
			engine_rpm_rtpc = "car_falcogini_rpm",
			going_reverse = "forklift_reverse_warning",
			hit = "car_hit_gen_01"
		},
		seats = {
			driver = {
				driving = true,
				name = "driver"
			},
			passenger_front = {
				allow_shooting = true,
				name = "passenger_front",
				has_shooting_mode = false,
				driving = false
			}
		},
		loot_points = {loot_left = {name = "loot"}},
		damage = {max_health = 9000000},
		max_speed = 20,
		max_rpm = 1600,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 3,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0, 7.5),
		fov = 70
	}
end

function VehicleTweakData:_init_data_forklift_2()
	self.forklift_2 = {
		name = "Forklift",
		hud_label_offset = 220,
		animations = {
			driver = "drive_forklift_driver",
			vehicle_id = "forklift"
		},
		sound = {
			engine_sound_event = "forklift",
			slip_stop = "car_skid_stop_01",
			lateral_slip_treshold = 10,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 5,
			going_reverse_stop = "forklift_reverse_warning_stop",
			slip = "car_skid_01",
			bump = "car_bumper_01",
			engine_start = "forklift_start",
			hit_rtpc = "car_hit_vel",
			longitudal_slip_treshold = 10,
			engine_speed_rtpc = "car_falcogini_speed",
			door_close = "sit_down_in_forklift",
			engine_rpm_rtpc = "car_falcogini_rpm",
			going_reverse = "forklift_reverse_warning",
			hit = "car_hit_gen_01"
		},
		seats = {driver = {
			driving = true,
			name = "driver"
		}},
		loot_points = {loot_left = {name = "loot"}},
		damage = {max_health = 100000},
		max_speed = 20,
		max_rpm = 1600,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 0,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0, 7.5),
		fov = 70
	}
end

function VehicleTweakData:_init_data_box_truck_1()
	self.box_truck_1 = {
		name = "Truck",
		hud_label_offset = 325,
		animations = {
			passenger_back_right = "drive_truck_back_right",
			vehicle_id = "truck",
			passenger_back_left = "drive_truck_back_left",
			passenger_front = "drive_truck_passanger",
			driver = "drive_truck_driver"
		},
		sound = {
			broken_engine = "falcogini_engine_broken_loop",
			bump = "car_bumper_01",
			lateral_slip_treshold = 0.35,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 8,
			slip_stop = "car_skid_stop_01",
			slip = "car_skid_01",
			hit_rtpc = "car_hit_vel",
			engine_rpm_rtpc = "car_falcogini_rpm",
			longitudal_slip_treshold = 0.98,
			engine_speed_rtpc = "car_falcogini_speed",
			door_close = "car_door_open",
			engine_sound_event = "drive_truck",
			hit = "car_hit_gen_01"
		},
		seats = {
			driver = {
				driving = true,
				name = "driver"
			},
			passenger_front = {
				name = "passenger_front",
				has_shooting_mode = true,
				allow_shooting = false,
				driving = false,
				shooting_pos = Vector3(50, 0, 50)
			},
			passenger_back_left = {
				allow_shooting = true,
				name = "passenger_back_left",
				has_shooting_mode = true,
				driving = false
			},
			passenger_back_right = {
				allow_shooting = true,
				name = "passenger_back_right",
				has_shooting_mode = true,
				driving = false
			}
		},
		loot_points = {
			loot_left = {name = "loot_left"},
			loot_right = {name = "loot_right"}
		},
		damage = {max_health = 900000},
		max_speed = 160,
		max_rpm = 8000,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 50,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0.2, 2.5),
		fov = 75
	}
end

function VehicleTweakData:_init_data_mower_1()
	self.mower_1 = {
		name = "Lawn Mower",
		hud_label_offset = 80,
		animations = {
			driver = "drive_mower_1_driver",
			vehicle_id = "mower_1"
		},
		sound = {
			engine_sound_event = "forklift",
			slip_stop = "car_skid_stop_01",
			lateral_slip_treshold = 10,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 5,
			going_reverse_stop = "forklift_reverse_warning_stop",
			slip = "car_skid_01",
			bump = "car_bumper_01",
			engine_start = "forklift_start",
			hit_rtpc = "car_hit_vel",
			longitudal_slip_treshold = 10,
			engine_speed_rtpc = "car_falcogini_speed",
			door_close = "sit_down_in_forklift",
			engine_rpm_rtpc = "car_falcogini_rpm",
			going_reverse = "forklift_reverse_warning",
			hit = "car_hit_gen_01"
		},
		seats = {driver = {
			driving = true,
			name = "driver"
		}},
		loot_points = {loot_left = {name = "loot"}},
		damage = {max_health = 9000000},
		max_speed = 20,
		max_rpm = 1600,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 1,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0, 3.5),
		fov = 70
	}
end

function VehicleTweakData:_init_data_boat_rib_1()
	self.boat_rib_1 = {
		name = "Rib Boat",
		hud_label_offset = 1,
		animations = {
			passenger_back_right = "drive_boat_rib_1_back_right",
			vehicle_id = "boat_rib_1",
			passenger_back_left = "drive_boat_rib_1_back_left",
			passenger_front = "drive_boat_rib_1_passanger",
			driver = "drive_boat_rib_1_driver"
		},
		sound = {
			engine_sound_event = "drive_rubber_boat",
			slip_stop = "car_silence",
			lateral_slip_treshold = 0.2,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 0.3,
			going_reverse_stop = "car_silence",
			slip = "water_splash_skid",
			bump = "water_splash_bump",
			engine_start = "car_silence",
			hit_rtpc = "car_hit_vel",
			longitudal_slip_treshold = 0.2,
			engine_speed_rtpc = "car_falcogini_speed",
			door_close = "car_silence",
			engine_rpm_rtpc = "car_falcogini_rpm",
			going_reverse = "car_silence",
			hit = "water_splash_skid"
		},
		seats = {
			driver = {
				driving = true,
				name = "driver"
			},
			passenger_front = {
				allow_shooting = true,
				name = "passenger_front",
				has_shooting_mode = false,
				driving = false
			},
			passenger_back_left = {
				allow_shooting = true,
				name = "passenger_back_left",
				has_shooting_mode = false,
				driving = false
			},
			passenger_back_right = {
				allow_shooting = true,
				name = "passenger_back_right",
				has_shooting_mode = false,
				driving = false
			}
		},
		loot_points = {loot_left = {name = "loot"}},
		damage = {max_health = 9000000},
		max_speed = 20,
		max_rpm = 1600,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 1,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0, 3.5),
		fov = 70
	}
end

function VehicleTweakData:_init_data_blackhawk_1()
	self.blackhawk_1 = {
		name = "Blackhawk",
		hud_label_offset = 150,
		animations = {
			passenger_back_right = "drive_blackhawk_1_back_right",
			vehicle_id = "blackhawk_1",
			passenger_back_left = "drive_blackhawk_1_back_left",
			passenger_front = "drive_blackhawk_1_passanger",
			driver = "drive_blackhawk_1_driver"
		},
		sound = {
			broken_engine = "heli_silence",
			bump = "heli_silence",
			lateral_slip_treshold = 0.35,
			bump_rtpc = "heli_silence",
			bump_treshold = 8,
			slip_stop = "heli_silence",
			slip = "heli_silence",
			hit_rtpc = "heli_silence",
			engine_start = "heli_silence",
			engine_rpm_rtpc = "heli_silence",
			longitudal_slip_treshold = 0.8,
			engine_speed_rtpc = "heli_silence",
			door_close = "heli_silence",
			engine_sound_event = "heli_silence",
			hit = "heli_silence"
		},
		seats = {
			driver = {
				allow_shooting = false,
				name = "driver",
				has_shooting_mode = false,
				driving = false
			},
			passenger_front = {
				allow_shooting = false,
				name = "passenger_front",
				has_shooting_mode = false,
				driving = false
			},
			passenger_back_left = {
				allow_shooting = false,
				name = "passenger_back_left",
				has_shooting_mode = false,
				driving = false
			},
			passenger_back_right = {
				allow_shooting = false,
				name = "passenger_back_right",
				has_shooting_mode = false,
				driving = false
			}
		},
		loot_points = {
			loot_left = {name = "loot_left"},
			loot_right = {name = "loot_right"}
		},
		damage = {max_health = 9e+27},
		max_speed = 160,
		max_rpm = 8000,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 4,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0, 0),
		fov = 75
	}
end

function VehicleTweakData:_init_data_bike_1()
	self.bike_1 = {
		name = "Bike",
		hud_label_offset = 220,
		animations = {
			driver = "drive_bike_1_driver",
			vehicle_id = "bike_1"
		},
		sound = {
			slip = "mc_skid",
			hit_rtpc = "car_hit_vel",
			lateral_slip_treshold = 0.25,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 6,
			slip_stop = "mc_skid_stop",
			bump = "mc_bumper_01",
			engine_rpm_rtpc = "car_falcogini_rpm",
			engine_start = "mc_harley_start",
			longitudal_slip_treshold = 0.95,
			engine_speed_rtpc = "car_falcogini_speed",
			engine_sound_event = "mc_harley",
			hit = "mc_hit_gen_01"
		},
		seats = {driver = {
			driving = true,
			name = "driver"
		}},
		loot_points = {loot_left = {name = "loot"}},
		damage = {max_health = 18000000},
		max_speed = 180,
		max_rpm = 3000,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 0,
		interact_distance = 250,
		driver_camera_offset = Vector3(0, -4, 5),
		fov = 75,
		camera_limits = {driver = {
			pitch = 30,
			yaw = 30
		}}
	}
end

function VehicleTweakData:_init_data_bike_2()
	self.bike_2 = {
		name = "Rust's bike",
		hud_label_offset = 220,
		animations = {
			driver = "drive_bike_1_driver",
			vehicle_id = "bike_1"
		},
		sound = {
			slip = "mc_skid",
			hit_rtpc = "car_hit_vel",
			lateral_slip_treshold = 0.25,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 6,
			slip_stop = "mc_skid_stop",
			bump = "mc_bumper_01",
			engine_rpm_rtpc = "car_falcogini_rpm",
			engine_start = "mc_harley_start",
			longitudal_slip_treshold = 0.95,
			engine_speed_rtpc = "car_falcogini_speed",
			engine_sound_event = "mc_harley",
			hit = "mc_hit_gen_01"
		},
		seats = {driver = {
			driving = true,
			name = "driver"
		}},
		loot_points = {loot_left = {name = "loot"}},
		damage = {max_health = 18000000},
		max_speed = 180,
		max_rpm = 3000,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 0,
		interact_distance = 250,
		driver_camera_offset = Vector3(0, -4, 5),
		fov = 75,
		camera_limits = {driver = {
			pitch = 30,
			yaw = 30
		}}
	}
end

