AnimationTweakData = AnimationTweakData or class()

function AnimationTweakData:init()
	self.hold_types = {
		bullpup = {
			weight = 1000
		},
		uzi = {
			weight = 1001
		}
	}
	self.animation_redirects = {
		mp5 = "new_mp5",
		beretta92 = "b92fs",
		raging_bull = "new_raging_bull",
		m14 = "new_m14",
		m4 = "new_m4",
		ben = "benelli",
		c45 = "colt_1911",
		g17 = "glock_17"
	}
end
