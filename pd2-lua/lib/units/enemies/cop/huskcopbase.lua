HuskCopBase = HuskCopBase or class(CopBase)

function HuskCopBase:post_init()
	self._ext_movement = self._unit:movement()
	self._ext_anim = self._unit:anim_data()

	self._ext_movement:post_init()
	self._unit:brain():post_init()
	self:set_anim_lod(1)

	self._lod_stage = 1

	managers.enemy:register_enemy(self._unit)
	self:_chk_spawn_gear()
	self:enable_leg_arm_hitbox()
end

function HuskCopBase:pre_destroy(unit)
	if alive(self._headwear_unit) then
		self._headwear_unit:set_slot(0)
	end

	self._unit:brain():pre_destroy()
	self._ext_movement:pre_destroy()

	if unit:inventory() then
		unit:inventory():pre_destroy(unit)
	end

	UnitBase.pre_destroy(self, unit)
end
