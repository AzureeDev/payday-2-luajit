NPCBowWeaponBase = NPCBowWeaponBase or class(NewNPCRaycastWeaponBase)

function NPCBowWeaponBase:init(...)
	NPCBowWeaponBase.super.init(self, ...)
end

function NPCBowWeaponBase:fire_blank(direction, impact)
	self:_sound_singleshot()

	if self:weapon_tweak_data().has_fire_animation then
		self:tweak_data_anim_play("fire")
	end
end

NPCCrossBowWeaponBase = NPCCrossBowWeaponBase or class(NPCBowWeaponBase)
