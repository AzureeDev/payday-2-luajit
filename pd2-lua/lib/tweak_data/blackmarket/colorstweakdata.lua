function BlackMarketTweakData:_init_colors(tweak_data)
	self.colors = {}
	local white = Color.white
	local black = Color.black
	local red = Color.red
	local green = Color.green
	local blue = Color.blue
	local yellow = Color.yellow
	local magenta = Color(255, 255, 0, 255) / 255
	local cyan = Color(255, 0, 255, 255) / 255
	local light_gray = Color(255, 191, 191, 191) / 255
	local gray = Color(255, 128, 128, 128) / 255
	local dark_gray = Color(255, 64, 64, 64) / 255
	local blood_red = Color(255, 138, 17, 9) / 255
	local orange = Color(255, 255, 94, 15) / 255
	local light_brown = Color(255, 204, 115, 35) / 255
	local bright_yellow = Color(255, 255, 207, 76) / 255
	local lime_green = Color(255, 0, 166, 81) / 255
	local purple = Color(255, 154, 68, 220) / 255
	local pink = Color(255, 255, 122, 230) / 255
	local brown = Color(255, 128, 70, 13) / 255
	local navy_blue = Color(255, 40, 52, 86) / 255
	local matte_blue = Color(255, 56, 97, 168) / 255
	local olive_green = Color(255, 72, 90, 50) / 255
	local gray_blue = Color(255, 12, 68, 84) / 255
	local light_blue = Color(255, 126, 198, 238) / 255
	local bone_white = Color(255, 255, 238, 151) / 255
	local turquoise = Color(255, 0, 209, 157) / 255
	local matte_purple = Color(255, 107, 84, 144) / 255
	local coral_red = Color(255, 213, 36, 53) / 255
	local leaf_green = Color(255, 104, 191, 54) / 255
	local dark_green = Color(255, 7, 61, 9) / 255
	local warm_yellow = Color(255, 250, 157, 7) / 255
	local dark_red = Color(255, 110, 15, 22) / 255
	local cobalt_blue = Color(255, 0, 93, 199) / 255
	local toxic_green = Color(255, 167, 248, 87) / 255
	local nothing = Color(0, 0, 0, 0) / 255
	local skin_pink = Color(255, 230, 147, 140) / 255
	local sea_blue = Color(255, 6, 55, 56) / 255
	local dark_purple = Color(255, 107, 0, 74) / 255
	local scary_green = Color(255, 92, 255, 117) / 255
	self.colors.white_solid = {
		colors = {
			white,
			white
		},
		name_id = "bm_clr_white_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 7
	}
	self.colors.black_solid = {
		colors = {
			black,
			black
		},
		name_id = "bm_clr_black_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 10
	}
	self.colors.red_solid = {
		colors = {
			red,
			red
		},
		name_id = "bm_clr_red_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.blue_solid = {
		colors = {
			blue,
			blue
		},
		name_id = "bm_clr_blue_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 8
	}
	self.colors.green_solid = {
		colors = {
			green,
			green
		},
		name_id = "bm_clr_green_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 8
	}
	self.colors.cyan_solid = {
		colors = {
			cyan,
			cyan
		},
		name_id = "bm_clr_cyan_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 8
	}
	self.colors.magenta_solid = {
		colors = {
			magenta,
			magenta
		},
		name_id = "bm_clr_magenta_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 7
	}
	self.colors.yellow_solid = {
		colors = {
			yellow,
			yellow
		},
		name_id = "bm_clr_yellow_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.colors.light_gray_solid = {
		colors = {
			light_gray,
			light_gray
		},
		name_id = "bm_clr_light_gray_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 7
	}
	self.colors.dark_gray_solid = {
		colors = {
			dark_gray,
			dark_gray
		},
		name_id = "bm_clr_dark_gray_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 8
	}
	self.colors.gray_solid = {
		colors = {
			gray,
			gray
		},
		name_id = "bm_clr_gray_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.colors.pink_solid = {
		colors = {
			pink,
			pink
		},
		name_id = "bm_clr_pink_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 7
	}
	self.colors.purple_solid = {
		colors = {
			purple,
			purple
		},
		name_id = "bm_clr_purple_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 8
	}
	self.colors.blood_red_solid = {
		colors = {
			blood_red,
			blood_red
		},
		name_id = "bm_clr_blood_red_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 9
	}
	self.colors.orange_solid = {
		colors = {
			orange,
			orange
		},
		name_id = "bm_clr_orange_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 8
	}
	self.colors.light_brown_solid = {
		colors = {
			light_brown,
			light_brown
		},
		name_id = "bm_clr_light_brown_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.colors.brown_solid = {
		colors = {
			brown,
			brown
		},
		name_id = "bm_clr_brown_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 8
	}
	self.colors.navy_blue_solid = {
		colors = {
			navy_blue,
			navy_blue
		},
		name_id = "bm_clr_navy_blue_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 7
	}
	self.colors.light_blue_solid = {
		colors = {
			light_blue,
			light_blue
		},
		name_id = "bm_clr_light_blue_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.leaf_green_solid = {
		colors = {
			leaf_green,
			leaf_green
		},
		name_id = "bm_clr_leaf_green_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 8
	}
	self.colors.warm_yellow_solid = {
		colors = {
			warm_yellow,
			warm_yellow
		},
		name_id = "bm_clr_warm_yellow_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.colors.dark_red_solid = {
		colors = {
			dark_red,
			dark_red
		},
		name_id = "bm_clr_dark_red_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.dark_green_solid = {
		colors = {
			dark_green,
			dark_green
		},
		name_id = "bm_clr_dark_green_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.colors.nothing = {
		colors = {
			nothing,
			nothing
		},
		name_id = "bm_clr_nothing",
		value = 0
	}
	self.colors.black_white = {
		colors = {
			black,
			white
		},
		name_id = "bm_clr_black_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.red_black = {
		colors = {
			red,
			black
		},
		name_id = "bm_clr_red_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		dlc = "preorder",
		value = 1
	}
	self.colors.yellow_blue = {
		colors = {
			yellow,
			blue
		},
		name_id = "bm_clr_yellow_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.red_blue = {
		colors = {
			red,
			blue
		},
		name_id = "bm_clr_red_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.light_gray_dark_gray = {
		colors = {
			light_gray,
			dark_gray
		},
		name_id = "bm_clr_light_gray_dark_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.magenta_cyan = {
		colors = {
			magenta,
			cyan
		},
		name_id = "bm_clr_magenta_cyan",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.green_red = {
		colors = {
			green,
			red
		},
		name_id = "bm_clr_green_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.orange_blue = {
		colors = {
			orange,
			blue
		},
		name_id = "bm_clr_orange_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.green_olive_green = {
		colors = {
			green,
			olive_green
		},
		name_id = "bm_clr_green_olive_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.yellow_orange = {
		colors = {
			yellow,
			orange
		},
		name_id = "bm_clr_yellow_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.light_brown_matte_blue = {
		colors = {
			light_brown,
			matte_blue
		},
		name_id = "bm_clr_light_brown_matte_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.turquoise_purple = {
		colors = {
			turquoise,
			purple
		},
		name_id = "bm_clr_turquoise_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.orange_gray_blue = {
		colors = {
			orange,
			gray_blue
		},
		name_id = "bm_clr_orange_gray_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.coral_red_matte_blue = {
		colors = {
			coral_red,
			matte_blue
		},
		name_id = "bm_clr_coral_red_matte_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.toxic_green_dark_green = {
		colors = {
			toxic_green,
			dark_green
		},
		name_id = "bm_clr_toxic_green_dark_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.warm_yellow_matte_purple = {
		colors = {
			warm_yellow,
			matte_purple
		},
		name_id = "bm_clr_warm_yellow_matte_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.bright_yellow_brown = {
		colors = {
			bright_yellow,
			brown
		},
		name_id = "bm_clr_bright_yellow_brown",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.coral_red_lime_green = {
		colors = {
			coral_red,
			lime_green
		},
		name_id = "bm_clr_coral_red_lime_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.white_matte_blue = {
		colors = {
			white,
			matte_blue
		},
		name_id = "bm_clr_white_matte_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.red_dark_red = {
		colors = {
			red,
			dark_red
		},
		name_id = "bm_clr_red_dark_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.bone_white_magenta = {
		colors = {
			bone_white,
			magenta
		},
		name_id = "bm_clr_bone_white_magenta",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.cobalt_blue_navy_blue = {
		colors = {
			cobalt_blue,
			navy_blue
		},
		name_id = "bm_clr_cobalt_blue_navy_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.toxic_green_leaf_green = {
		colors = {
			toxic_green,
			leaf_green
		},
		name_id = "bm_clr_toxic_green_leaf_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.light_brown_brown = {
		colors = {
			light_brown,
			brown
		},
		name_id = "bm_clr_light_brown_brown",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.bright_yellow_turquoise = {
		colors = {
			bright_yellow,
			turquoise
		},
		name_id = "bm_clr_bright_yellow_turquoise",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.light_blue_gray_blue = {
		colors = {
			light_blue,
			gray_blue
		},
		name_id = "bm_clr_light_blue_gray_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.pink_matte_purple = {
		colors = {
			pink,
			matte_purple
		},
		name_id = "bm_clr_pink_matte_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.bone_white_purple = {
		colors = {
			bone_white,
			purple
		},
		name_id = "bm_clr_bone_white_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.light_blue_cobalt_blue = {
		colors = {
			light_blue,
			cobalt_blue
		},
		name_id = "bm_clr_light_blue_cobalt_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.coral_red_gray_blue = {
		colors = {
			coral_red,
			gray_blue
		},
		name_id = "bm_clr_coral_red_gray_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.leaf_green_blood_red = {
		colors = {
			leaf_green,
			blood_red
		},
		name_id = "bm_clr_leaf_green_blood_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.cobalt_blue_pink = {
		colors = {
			cobalt_blue,
			pink
		},
		name_id = "bm_clr_cobalt_blue_pink",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.bright_yellow_olive_green = {
		colors = {
			bright_yellow,
			olive_green
		},
		name_id = "bm_clr_bright_yellow_olive_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 1
	}
	self.colors.bone_white_light_blue = {
		colors = {
			bone_white,
			light_blue
		},
		name_id = "bm_clr_bone_white_light_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 1
	}
	self.colors.coral_red_dark_red = {
		colors = {
			coral_red,
			dark_red
		},
		name_id = "bm_clr_coral_red_dark_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.turquoise_pink = {
		colors = {
			turquoise,
			pink
		},
		name_id = "bm_clr_turquoise_pink",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 1
	}
	self.colors.white_brown = {
		colors = {
			white,
			brown
		},
		name_id = "bm_clr_white_brown",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 1
	}
	self.colors.blue_light_blue = {
		colors = {
			blue,
			light_blue
		},
		name_id = "bm_clr_blue_light_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.toxic_green_matte_purple = {
		colors = {
			toxic_green,
			matte_purple
		},
		name_id = "bm_clr_toxic_green_matte_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.orange_matte_blue = {
		colors = {
			orange,
			matte_blue
		},
		name_id = "bm_clr_orange_matte_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.warm_yellow_navy_blue = {
		colors = {
			warm_yellow,
			navy_blue
		},
		name_id = "bm_clr_warm_yellow_navy_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.bright_yellow_dark_gray = {
		colors = {
			bright_yellow,
			dark_gray
		},
		name_id = "bm_clr_bright_yellow_dark_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.white_magenta = {
		colors = {
			white,
			magenta
		},
		name_id = "bm_clr_white_magenta",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.cyan_purple = {
		colors = {
			cyan,
			purple
		},
		name_id = "bm_clr_cyan_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.white_black = {
		colors = {
			white,
			black
		},
		name_id = "bm_clr_white_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.light_gray_blood_red = {
		colors = {
			light_gray,
			blood_red
		},
		name_id = "bm_clr_light_gray_blood_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.colors.blood_red_white = {
		colors = {
			blood_red,
			white
		},
		name_id = "bm_clr_blood_red_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.colors.bone_white_navy_blue = {
		colors = {
			bone_white,
			navy_blue
		},
		name_id = "bm_clr_bone_white_navy_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.warm_yellow_olive_green = {
		colors = {
			warm_yellow,
			olive_green
		},
		name_id = "bm_clr_warm_yellow_olive_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.cyan_orange = {
		colors = {
			cyan,
			orange
		},
		name_id = "bm_clr_cyan_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_orange = {
		colors = {
			dark_gray,
			orange
		},
		name_id = "bm_clr_dark_gray_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.light_brown_navy_blue = {
		colors = {
			light_brown,
			navy_blue
		},
		name_id = "bm_clr_light_brown_navy_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.orange_purple = {
		colors = {
			orange,
			purple
		},
		name_id = "bm_clr_orange_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.light_blue_brown = {
		colors = {
			light_blue,
			brown
		},
		name_id = "bm_clr_light_blue_brown",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.green_blood_red = {
		colors = {
			green,
			blood_red
		},
		name_id = "bm_clr_green_blood_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.cyan_blue = {
		colors = {
			cyan,
			blue
		},
		name_id = "bm_clr_cyan_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.yellow_orange = {
		colors = {
			yellow,
			orange
		},
		name_id = "bm_clr_yellow_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.colors.light_gray_dark_gray = {
		colors = {
			light_gray,
			dark_gray
		},
		name_id = "bm_clr_light_gray_dark_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.gray_black = {
		colors = {
			gray,
			black
		},
		name_id = "bm_clr_gray_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.white_dark_gray = {
		colors = {
			white,
			dark_gray
		},
		name_id = "bm_clr_white_dark_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.colors.white_brown = {
		colors = {
			white,
			brown
		},
		name_id = "bm_clr_white_brown",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.white_navy_blue = {
		colors = {
			white,
			navy_blue
		},
		name_id = "bm_clr_white_navy_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.white_purple = {
		colors = {
			white,
			purple
		},
		name_id = "bm_clr_white_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.black_coral_red = {
		colors = {
			black,
			coral_red
		},
		name_id = "bm_clr_black_coral_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.black_orange = {
		colors = {
			black,
			orange
		},
		name_id = "bm_clr_black_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.black_cobalt_blue = {
		colors = {
			black,
			cobalt_blue
		},
		name_id = "bm_clr_black_cobalt_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.black_leaf_green = {
		colors = {
			black,
			leaf_green
		},
		name_id = "bm_clr_black_leaf_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.red_white = {
		colors = {
			red,
			white
		},
		name_id = "bm_clr_red_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.leaf_green_white = {
		colors = {
			leaf_green,
			white
		},
		name_id = "bm_clr_leaf_green_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.orange_white = {
		colors = {
			orange,
			white
		},
		name_id = "bm_clr_orange_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.cobalt_blue_white = {
		colors = {
			cobalt_blue,
			white
		},
		name_id = "bm_clr_cobalt_blue_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.warm_yellow_white = {
		colors = {
			warm_yellow,
			white
		},
		name_id = "bm_clr_warm_yellow_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.black_bright_yellow = {
		colors = {
			black,
			bright_yellow
		},
		name_id = "bm_clr_black_bright_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.warm_yellow_bright_yellow = {
		colors = {
			warm_yellow,
			bright_yellow
		},
		name_id = "bm_clr_warm_yellow_bright_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.black_magenta = {
		colors = {
			black,
			magenta
		},
		name_id = "bm_clr_black_magenta",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.navy_blue_light_blue = {
		colors = {
			navy_blue,
			light_blue
		},
		name_id = "bm_clr_navy_blue_light_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.dark_red_orange = {
		colors = {
			dark_red,
			orange
		},
		name_id = "bm_clr_dark_red_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.scary_green_solid = {
		colors = {
			scary_green,
			scary_green
		},
		name_id = "bm_clr_scary_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.dark_purple_solid = {
		colors = {
			dark_purple,
			dark_purple
		},
		name_id = "bm_clr_dark_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.sea_blue_solid = {
		colors = {
			sea_blue,
			sea_blue
		},
		name_id = "bm_clr_sea_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.skin_pink_solid = {
		colors = {
			skin_pink,
			skin_pink
		},
		name_id = "bm_clr_skin_pink",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.black_red = {
		colors = {
			black,
			red
		},
		name_id = "bm_clr_black_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 1
	}
	self.colors.blue_yellow = {
		colors = {
			blue,
			yellow
		},
		name_id = "bm_clr_blue_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.colors.blue_red = {
		colors = {
			blue,
			red
		},
		name_id = "bm_clr_blue_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.dark_grey_light_gray = {
		colors = {
			dark_gray,
			light_gray
		},
		name_id = "bm_clr_dark_grey_light_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.orange_yellow = {
		colors = {
			orange,
			yellow
		},
		name_id = "bm_clr_orange_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.colors.black_gray = {
		colors = {
			black,
			gray
		},
		name_id = "bm_clr_black_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.orange_black = {
		colors = {
			orange,
			black
		},
		name_id = "bm_clr_orange_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.white_red = {
		colors = {
			white,
			red
		},
		name_id = "bm_clr_white_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.bright_yellow_black = {
		colors = {
			bright_yellow,
			black
		},
		name_id = "bm_clr_bright_yellow_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.scary_green_black = {
		colors = {
			scary_green,
			black
		},
		name_id = "bm_clr_scary_green_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.skin_pink_black = {
		colors = {
			skin_pink,
			black
		},
		name_id = "bm_clr_skin_pink_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.sea_blue_black = {
		colors = {
			sea_blue,
			black
		},
		name_id = "bm_clr_sea_blue_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_purple_black = {
		colors = {
			dark_purple,
			black
		},
		name_id = "bm_clr_dark_purple_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.scary_green_white = {
		colors = {
			scary_green,
			white
		},
		name_id = "bm_clr_scary_green_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.skin_pink_white = {
		colors = {
			skin_pink,
			white
		},
		name_id = "bm_clr_skin_pink_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.sea_blue_white = {
		colors = {
			sea_blue,
			white
		},
		name_id = "bm_clr_sea_blue_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_purple_white = {
		colors = {
			dark_purple,
			white
		},
		name_id = "bm_clr_dark_purple_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.scary_green_red = {
		colors = {
			scary_green,
			red
		},
		name_id = "bm_clr_scary_green_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.skin_pink_red = {
		colors = {
			skin_pink,
			red
		},
		name_id = "bm_clr_skin_pink_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.sea_blue_red = {
		colors = {
			sea_blue,
			red
		},
		name_id = "bm_clr_sea_blue_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_purple_red = {
		colors = {
			dark_purple,
			red
		},
		name_id = "bm_clr_dark_purple_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.scary_green_green = {
		colors = {
			scary_green,
			green
		},
		name_id = "bm_clr_scary_green_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.skin_pink_green = {
		colors = {
			skin_pink,
			green
		},
		name_id = "bm_clr_skin_pink_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.sea_blue_green = {
		colors = {
			sea_blue,
			green
		},
		name_id = "bm_clr_sea_blue_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_purple_green = {
		colors = {
			dark_purple,
			green
		},
		name_id = "bm_clr_dark_purple_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.scary_green_blue = {
		colors = {
			scary_green,
			blue
		},
		name_id = "bm_clr_scary_green_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.skin_pink_blue = {
		colors = {
			skin_pink,
			blue
		},
		name_id = "bm_clr_skin_pink_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.sea_blue_blue = {
		colors = {
			sea_blue,
			blue
		},
		name_id = "bm_clr_sea_blue_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_purple_blue = {
		colors = {
			dark_purple,
			blue
		},
		name_id = "bm_clr_dark_purple_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.scary_green_yellow = {
		colors = {
			scary_green,
			yellow
		},
		name_id = "bm_clr_scary_green_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.skin_pink_yellow = {
		colors = {
			skin_pink,
			yellow
		},
		name_id = "bm_clr_skin_pink_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.sea_blue_yellow = {
		colors = {
			sea_blue,
			yellow
		},
		name_id = "bm_clr_sea_blue_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_purple_yellow = {
		colors = {
			dark_purple,
			yellow
		},
		name_id = "bm_clr_dark_purple_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.scary_green_gray = {
		colors = {
			scary_green,
			gray
		},
		name_id = "bm_clr_scary_green_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.skin_pink_gray = {
		colors = {
			skin_pink,
			gray
		},
		name_id = "bm_clr_skin_pink_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.sea_blue_gray = {
		colors = {
			sea_blue,
			gray
		},
		name_id = "bm_clr_sea_blue_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_purple_gray = {
		colors = {
			dark_purple,
			gray
		},
		name_id = "bm_clr_dark_purple_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.scary_green_orange = {
		colors = {
			scary_green,
			orange
		},
		name_id = "bm_clr_scary_green_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.skin_pink_orange = {
		colors = {
			skin_pink,
			orange
		},
		name_id = "bm_clr_skin_pink_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.sea_blue_orange = {
		colors = {
			sea_blue,
			orange
		},
		name_id = "bm_clr_sea_blue_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_purple_orange = {
		colors = {
			dark_purple,
			orange
		},
		name_id = "bm_clr_dark_purple_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.red_gray = {
		colors = {
			red,
			gray
		},
		name_id = "bm_clr_red_grey",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.red_scary_green = {
		colors = {
			red,
			scary_green
		},
		name_id = "bm_clr_red_scary_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.red_dark_gray = {
		colors = {
			red,
			dark_gray
		},
		name_id = "bm_clr_red_dark_grey",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.red_orange = {
		colors = {
			red,
			orange
		},
		name_id = "bm_clr_red_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.orange_gray = {
		colors = {
			orange,
			gray
		},
		name_id = "bm_clr_orange_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.orange_turquoise = {
		colors = {
			orange,
			turquoise
		},
		name_id = "bm_clr_orange_turquoise",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 8
	}
	self.colors.warm_yellow_light_blue = {
		colors = {
			warm_yellow,
			light_blue
		},
		name_id = "bm_clr_warm_yellow_light_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.warm_yellow_purple = {
		colors = {
			warm_yellow,
			purple
		},
		name_id = "bm_clr_warm_yellow_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.warm_yellow_solid = {
		colors = {
			warm_yellow,
			warm_yellow
		},
		name_id = "bm_clr_warm_yellow_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.warm_yellow_dark_red = {
		colors = {
			warm_yellow,
			dark_red
		},
		name_id = "bm_clr_warm_yellow_dark_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.turquoise_black = {
		colors = {
			turquoise,
			black
		},
		name_id = "bm_clr_turquoise_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.turquoise_white = {
		colors = {
			turquoise,
			white
		},
		name_id = "bm_clr_turquoise_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.turquoise_warm_yellow = {
		colors = {
			turquoise,
			warm_yellow
		},
		name_id = "bm_clr_turquoise_warm_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.turquoise_solid = {
		colors = {
			turquoise,
			turquoise
		},
		name_id = "bm_clr_turquoise_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.turquoise_gray = {
		colors = {
			turquoise,
			gray
		},
		name_id = "bm_clr_turquoise_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.blue_white = {
		colors = {
			blue,
			white
		},
		name_id = "bm_clr_blue_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.blue_black = {
		colors = {
			blue,
			black
		},
		name_id = "bm_clr_blue_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.blue_navy_blue = {
		colors = {
			blue,
			navy_blue
		},
		name_id = "bm_clr_blue_navy_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.blue_gray = {
		colors = {
			blue,
			gray
		},
		name_id = "bm_clr_blue_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.white_yellow = {
		colors = {
			white,
			yellow
		},
		name_id = "bm_clr_white_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.white_orange = {
		colors = {
			white,
			orange
		},
		name_id = "bm_clr_white_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.white_dark_red = {
		colors = {
			white,
			dark_red
		},
		name_id = "bm_clr_white_dark_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.white_cyan = {
		colors = {
			white,
			cyan
		},
		name_id = "bm_clr_white_cyan",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.white_scary_green = {
		colors = {
			white,
			scary_green
		},
		name_id = "bm_clr_white_scary_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_white = {
		colors = {
			dark_gray,
			white
		},
		name_id = "bm_clr_dark_gray_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_black = {
		colors = {
			dark_gray,
			black
		},
		name_id = "bm_clr_dark_gray_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_coral_red = {
		colors = {
			dark_gray,
			coral_red
		},
		name_id = "bm_clr_dark_gray_coral_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_cobalt_blue = {
		colors = {
			dark_gray,
			cobalt_blue
		},
		name_id = "bm_clr_dark_gray_cobalt_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_turquoise = {
		colors = {
			dark_gray,
			turquoise
		},
		name_id = "bm_clr_dark_gray_turquoise",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_green = {
		colors = {
			dark_gray,
			green
		},
		name_id = "bm_clr_dark_gray_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_yellow = {
		colors = {
			dark_gray,
			yellow
		},
		name_id = "bm_clr_dark_gray_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_magenta = {
		colors = {
			dark_gray,
			magenta
		},
		name_id = "bm_clr_dark_gray_magenta",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_dark_red = {
		colors = {
			dark_gray,
			dark_red
		},
		name_id = "bm_clr_dark_gray_dark_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_purple = {
		colors = {
			dark_gray,
			purple
		},
		name_id = "bm_clr_dark_gray_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_gray_bright_yellow = {
		colors = {
			dark_gray,
			bright_yellow
		},
		name_id = "bm_clr_dark_gray_bright_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.coral_red_white = {
		colors = {
			coral_red,
			white
		},
		name_id = "bm_clr_coral_red_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.coral_red_dark_gray = {
		colors = {
			coral_red,
			dark_gray
		},
		name_id = "bm_clr_coral_red_dark_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.coral_red_black = {
		colors = {
			coral_red,
			black
		},
		name_id = "bm_clr_coral_red_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.coral_red_light_gray = {
		colors = {
			coral_red,
			light_gray
		},
		name_id = "bm_clr_coral_red_light_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.coral_red_solid = {
		colors = {
			coral_red,
			coral_red
		},
		name_id = "bm_clr_coral_red_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_red_red = {
		colors = {
			dark_red,
			red
		},
		name_id = "bm_clr_dark_red_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_red_bright_yellow = {
		colors = {
			dark_red,
			bright_yellow
		},
		name_id = "bm_clr_dark_red_bright_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_red_black = {
		colors = {
			dark_red,
			black
		},
		name_id = "bm_clr_dark_red_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.dark_red_gray = {
		colors = {
			dark_red,
			gray
		},
		name_id = "bm_clr_dark_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.blood_red_toxic_green = {
		colors = {
			blood_red,
			toxic_green
		},
		name_id = "bm_clr_blood_red_toxic_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.blood_red_cobalt_blue = {
		colors = {
			blood_red,
			cobalt_blue
		},
		name_id = "bm_clr_blood_red_cobalt_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.light_brown_black = {
		colors = {
			light_brown,
			black
		},
		name_id = "bm_clr_light_brown_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.light_brown_white = {
		colors = {
			light_brown,
			white
		},
		name_id = "bm_clr_light_brown_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.light_brown_gray = {
		colors = {
			light_brown,
			gray
		},
		name_id = "bm_clr_light_brown_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.bright_yellow_solid = {
		colors = {
			bright_yellow,
			bright_yellow
		},
		name_id = "bm_clr_bright_yellow_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.bright_yellow_dark_red = {
		colors = {
			bright_yellow,
			dark_red
		},
		name_id = "bm_clr_bright_yellow_dark_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.colors.turquoise_black = {
		colors = {
			turquoise,
			black
		},
		name_id = "bm_clr_turquoise_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.purple_black = {
		colors = {
			purple,
			black
		},
		name_id = "bm_clr_purple_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.purple_white = {
		colors = {
			purple,
			white
		},
		name_id = "bm_clr_purple_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.purple_cyan = {
		colors = {
			purple,
			cyan
		},
		name_id = "bm_clr_purple_cyan",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.black_cyan = {
		colors = {
			black,
			cyan
		},
		name_id = "bm_clr_black_cyan",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.black_green = {
		colors = {
			black,
			green
		},
		name_id = "bm_clr_black_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.black_yellow = {
		colors = {
			black,
			yellow
		},
		name_id = "bm_clr_black_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.black_gray = {
		colors = {
			black,
			gray
		},
		name_id = "bm_clr_black_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.yellow_black = {
		colors = {
			yellow,
			black
		},
		name_id = "bm_clr_yellow_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.yellow_white = {
		colors = {
			yellow,
			white
		},
		name_id = "bm_clr_yellow_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.yellow_gray = {
		colors = {
			yellow,
			gray
		},
		name_id = "bm_clr_yellow_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.yellow_dark_gray = {
		colors = {
			yellow,
			dark_gray
		},
		name_id = "bm_clr_yellow_dark_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.yellow_red = {
		colors = {
			yellow,
			red
		},
		name_id = "bm_clr_yellow_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.leaf_green_black = {
		colors = {
			leaf_green,
			black
		},
		name_id = "bm_clr_leaf_green_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.leaf_green_dark_green = {
		colors = {
			leaf_green,
			dark_green
		},
		name_id = "bm_clr_leaf_green_dark_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.dark_green_leaf_green = {
		colors = {
			dark_green,
			leaf_green
		},
		name_id = "bm_clr_dark_green_leaf_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.colors.cobalt_blue_solid = {
		colors = {
			cobalt_blue,
			cobalt_blue
		},
		name_id = "bm_clr_cobalt_blue_solid",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.cobalt_blue_warm_yellow = {
		colors = {
			cobalt_blue,
			warm_yellow
		},
		name_id = "bm_clr_cobalt_blue_warm_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.cobalt_blue_gray = {
		colors = {
			cobalt_blue,
			gray
		},
		name_id = "bm_clr_cobalt_blue_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.cobalt_blue_orange = {
		colors = {
			cobalt_blue,
			orange
		},
		name_id = "bm_clr_cobalt_blue_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.cobalt_blue_black = {
		colors = {
			cobalt_blue,
			black
		},
		name_id = "bm_clr_cobalt_blue_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.magenta_black = {
		colors = {
			magenta,
			black
		},
		name_id = "bm_clr_magenta_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.magenta_white = {
		colors = {
			magenta,
			white
		},
		name_id = "bm_clr_magenta_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.magenta_yellow = {
		colors = {
			magenta,
			yellow
		},
		name_id = "bm_clr_magenta_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.magenta_warm_yellow = {
		colors = {
			magenta,
			warm_yellow
		},
		name_id = "bm_clr_magenta_warm_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.magenta_dark_gray = {
		colors = {
			magenta,
			dark_gray
		},
		name_id = "bm_clr_magenta_dark_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_white = {
		colors = {
			gray,
			white
		},
		name_id = "bm_clr_gray_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_purple = {
		colors = {
			gray,
			purple
		},
		name_id = "bm_clr_gray_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_cobalt_blue = {
		colors = {
			gray,
			cobalt_blue
		},
		name_id = "bm_clr_gray_cobalt_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_turquoise = {
		colors = {
			gray,
			turquoise
		},
		name_id = "bm_clr_gray_turquoise",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_green = {
		colors = {
			gray,
			green
		},
		name_id = "bm_clr_gray_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_yellow = {
		colors = {
			gray,
			yellow
		},
		name_id = "bm_clr_gray_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_magenta = {
		colors = {
			gray,
			magenta
		},
		name_id = "bm_clr_gray_magenta",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_dark_red = {
		colors = {
			gray,
			dark_red
		},
		name_id = "bm_clr_gray_dark_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_orange = {
		colors = {
			gray,
			orange
		},
		name_id = "bm_clr_gray_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_red = {
		colors = {
			gray,
			red
		},
		name_id = "bm_clr_gray_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.gray_bright_yellow = {
		colors = {
			gray,
			bright_yellow
		},
		name_id = "bm_clr_gray_bright_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.light_blue_black = {
		colors = {
			light_blue,
			black
		},
		name_id = "bm_clr_light_blue_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.light_blue_white = {
		colors = {
			light_blue,
			white
		},
		name_id = "bm_clr_light_blue_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.light_blue_bright_yellow = {
		colors = {
			light_blue,
			bright_yellow
		},
		name_id = "bm_clr_light_blue_bright_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.light_blue_coral_red = {
		colors = {
			light_blue,
			coral_red
		},
		name_id = "bm_clr_light_blue_coral_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.light_blue_navy_blue = {
		colors = {
			light_blue,
			navy_blue
		},
		name_id = "bm_clr_light_blue_navy_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.light_blue_orange = {
		colors = {
			light_blue,
			orange
		},
		name_id = "bm_clr_light_blue_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.pink_yellow = {
		colors = {
			pink,
			yellow
		},
		name_id = "bm_clr_pink_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.pink_cobalt_blue = {
		colors = {
			pink,
			cobalt_blue
		},
		name_id = "bm_clr_pink_cobalt_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.pink_black = {
		colors = {
			pink,
			black
		},
		name_id = "bm_clr_pink_black",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.pink_white = {
		colors = {
			pink,
			white
		},
		name_id = "bm_clr_pink_white",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.pink_navy_blue = {
		colors = {
			pink,
			navy_blue
		},
		name_id = "bm_clr_pink_navy_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.colors.pink_gray = {
		colors = {
			pink,
			gray
		},
		name_id = "bm_clr_pink_gray",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	local free_dlcs = tweak_data:free_dlc_list()

	for _, data in pairs(self.colors) do
		if free_dlcs[data.dlc] then
			data.dlc = nil
		end
	end
end
