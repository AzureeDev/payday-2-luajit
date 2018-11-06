CriminalActionWalk = CriminalActionWalk or class(CopActionWalk)
CriminalActionWalk._anim_block_presets = {
	block_all = {
		light_hurt = -1,
		shoot = -1,
		turn = -1,
		stand = -1,
		death = -1,
		dodge = -1,
		crouch = -1,
		walk = -1,
		act = -1,
		hurt = -1,
		heavy_hurt = -1,
		idle = -1,
		action = -1
	},
	block_lower = {
		light_hurt = -1,
		turn = -1,
		crouch = -1,
		stand = -1,
		death = -1,
		dodge = -1,
		heavy_hurt = -1,
		walk = -1,
		act = -1,
		hurt = -1,
		idle = -1
	},
	block_upper = {
		crouch = -1,
		shoot = -1,
		action = -1,
		stand = -1
	},
	block_none = {
		crouch = -1,
		stand = -1
	}
}
CriminalActionWalk._walk_anim_velocities = HuskPlayerMovement._walk_anim_velocities
CriminalActionWalk._walk_anim_lengths = HuskPlayerMovement._walk_anim_lengths

function CriminalActionWalk:init(action_desc, common_data)
	if common_data.ext_movement:carrying_bag() then
		local can_run = tweak_data.carry.types[tweak_data.carry[common_data.ext_movement:carry_id()].type].can_run

		if not can_run and action_desc.variant == "run" then
			action_desc.variant = "walk"
		end
	end

	return CriminalActionWalk.super.init(self, action_desc, common_data)
end

function CriminalActionWalk:_get_max_walk_speed()
	local speed = deep_clone(CriminalActionWalk.super._get_max_walk_speed(self))

	if self._ext_movement:carrying_bag() then
		local speed_modifier = tweak_data.carry.types[tweak_data.carry[self._ext_movement:carry_id()].type].move_speed_modifier

		for k, v in pairs(speed) do
			speed[k] = v * speed_modifier
		end
	end

	return speed
end

function CriminalActionWalk:_get_current_max_walk_speed(move_dir)
	local speed = CriminalActionWalk.super._get_current_max_walk_speed(self, move_dir)

	if self._ext_movement:carrying_bag() then
		local speed_modifier = tweak_data.carry.types[tweak_data.carry[self._ext_movement:carry_id()].type].move_speed_modifier
		speed = speed * speed_modifier
	end

	return speed
end
