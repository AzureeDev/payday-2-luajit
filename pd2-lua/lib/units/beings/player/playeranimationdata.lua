PlayerAnimationData = PlayerAnimationData or class()

function PlayerAnimationData:init(unit)
	self._unit = unit
end

function PlayerAnimationData:anim_clbk_footstep_l(unit)
	self._footstep = "l"

	unit:base():anim_data_clbk_footstep("left")
end

function PlayerAnimationData:anim_clbk_footstep_r(unit)
	self._footstep = "r"

	unit:base():anim_data_clbk_footstep("right")
end

function PlayerAnimationData:anim_clbk_startfoot_l(unit)
	self._footstep = "l"
end

function PlayerAnimationData:anim_clbk_startfoot_r(unit)
	self._footstep = "r"
end

function PlayerAnimationData:foot()
	return self._footstep
end

function PlayerAnimationData:anim_clbk_upper_body_empty(unit)
	unit:anim_state_machine():stop_segment(Idstring("upper_body"))
end

function PlayerAnimationData:anim_clbk_base_empty(unit)
	unit:anim_state_machine():stop_segment(Idstring("base"))
end

function PlayerAnimationData:anim_clbk_death_exit(unit)
	unit:movement():on_death_exit()
	unit:base():on_death_exit()

	if unit:inventory() then
		unit:inventory():on_death_exit()
	end
end
