CivilianBase = CivilianBase or class(CopBase)

function CivilianBase:post_init()
	self._ext_movement = self._unit:movement()
	self._ext_anim = self._unit:anim_data()

	self:set_anim_lod(1)

	self._lod_stage = 1
	local spawn_state = nil

	if self._spawn_state then
		if self._spawn_state ~= "" then
			spawn_state = self._spawn_state
		end
	else
		spawn_state = "civilian/spawn/loop"
	end

	if spawn_state then
		self._ext_movement:play_state(spawn_state)
	end

	self._unit:anim_data().idle_full_blend = true

	self._ext_movement:post_init()
	self._unit:brain():post_init()
	managers.enemy:register_civilian(self._unit)
	self:enable_leg_arm_hitbox()
end

function CivilianBase:default_weapon_name()
end
