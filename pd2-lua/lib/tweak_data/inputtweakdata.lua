InputTweakData = InputTweakData or class()

function InputTweakData:init(tweak_data)
	self.gamepad = {
		aim_assist_move_speed = 10,
		aim_assist_move_th_min = 0.1,
		aim_assist_gradient_min = 0.6,
		aim_assist_gradient_max_distance = 3000,
		look_speed_dead_zone = 0.02,
		aim_assist_snap_speed = 200,
		aim_assist_gradient_max = 0.8,
		look_speed_fast = 340,
		look_speed_transition_occluder = 0.95,
		aim_assist_look_speed = 20,
		look_speed_steel_sight = 60,
		look_speed_transition_to_fast = 0.55,
		aim_assist_move_th_max = 0.9,
		uses_keyboard = true,
		look_speed_transition_zone = 0.95,
		aim_assist_use_sticky_aim = true,
		look_speed_standard = 110,
		deprecated = {
			look_speed_fast = 360,
			look_speed_transition_to_fast = 0.5,
			aim_assist_snap_speed = 200,
			uses_keyboard = true,
			look_speed_dead_zone = 0.1,
			look_speed_transition_zone = 0.8,
			look_speed_transition_occluder = 0.95,
			aim_assist_use_sticky_aim = false,
			look_speed_steel_sight = 60,
			look_speed_standard = 120
		}
	}

	local function valid_range(data, var, b, c, ex_b, ex_c)
		local a = data[var]
		local valid = true

		if not ex_b then
			valid = valid and b <= a
		else
			valid = valid and b < a
		end

		if not ex_c then
			valid = valid and a <= c
		else
			valid = valid and a < c
		end

		if not valid then
			Application:error("" .. var .. " value is " .. a .. " it should be in the range [" .. b .. (ex_b and "<" or "<=") .. var .. (ex_c and "<" or "<=") .. c .. "]")
		end
	end

	valid_range(self.gamepad, "look_speed_dead_zone", 0, 1, true, false)
	valid_range(self.gamepad, "look_speed_transition_zone", 0, 1, true, true)
	valid_range(self.gamepad, "look_speed_transition_occluder", 0, 1, true, true)
	valid_range(self.gamepad, "aim_assist_gradient_min", 0, 1, false, false)
	valid_range(self.gamepad, "aim_assist_gradient_max", 0, 1, false, false)
	valid_range(self.gamepad, "aim_assist_move_th_min", 0, 1, false, false)
	valid_range(self.gamepad, "aim_assist_move_th_max", 0, 1, false, false)
	print("[InputTweakData] Init")
end
