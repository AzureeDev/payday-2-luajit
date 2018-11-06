ShieldCopActionWalk = ShieldCopActionWalk or class(CopActionWalk)
ShieldCopActionWalk._walk_anim_velocities = {
	stand = {
		cbt = {
			walk = {
				bwd = 208,
				l = 227.5,
				fwd = 242.75,
				r = 208.75
			},
			run = {
				bwd = 281.88,
				l = 364.29,
				fwd = 342.5,
				r = 361.25
			},
			sprint = {
				bwd = 451,
				l = 582.86,
				fwd = 548,
				r = 578
			}
		}
	}
}
ShieldCopActionWalk._walk_anim_velocities.stand.ntl = ShieldCopActionWalk._walk_anim_velocities.stand.cbt
ShieldCopActionWalk._walk_anim_velocities.stand.hos = ShieldCopActionWalk._walk_anim_velocities.stand.cbt
ShieldCopActionWalk._walk_anim_velocities.stand.wnd = ShieldCopActionWalk._walk_anim_velocities.stand.cbt
ShieldCopActionWalk._walk_anim_velocities.crouch = ShieldCopActionWalk._walk_anim_velocities.stand
ShieldCopActionWalk._walk_anim_lengths = {
	stand = {
		cbt = {
			walk = {
				bwd = 24,
				l = 26,
				fwd = 28,
				r = 26
			},
			run = {
				bwd = 16,
				l = 21,
				fwd = 18,
				r = 21
			},
			sprint = {
				bwd = 16,
				l = 21,
				fwd = 18,
				r = 21
			},
			run_start = {
				bwd = 26,
				l = 27,
				fwd = 31,
				r = 29
			},
			run_start_turn = {
				bwd = 26,
				l = 37,
				r = 26
			},
			run_stop = {
				bwd = 29,
				l = 34,
				fwd = 28,
				r = 30
			}
		}
	}
}

for pose, stances in pairs(ShieldCopActionWalk._walk_anim_lengths) do
	for stance, speeds in pairs(stances) do
		for speed, sides in pairs(speeds) do
			for side, speed in pairs(sides) do
				sides[side] = speed * 0.03333
			end
		end
	end
end

ShieldCopActionWalk._walk_anim_lengths.stand.ntl = ShieldCopActionWalk._walk_anim_lengths.stand.cbt
ShieldCopActionWalk._walk_anim_lengths.stand.hos = ShieldCopActionWalk._walk_anim_lengths.stand.cbt
ShieldCopActionWalk._walk_anim_lengths.stand.wnd = ShieldCopActionWalk._walk_anim_lengths.stand.cbt
ShieldCopActionWalk._walk_anim_lengths.crouch = ShieldCopActionWalk._walk_anim_lengths.stand
