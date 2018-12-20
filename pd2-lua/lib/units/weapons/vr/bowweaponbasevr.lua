BowWeaponBaseVR = BowWeaponBase or Application:error("BowWeaponBaseVR requires BowWeaponBase!")

function BowWeaponBaseVR:charge_multiplier()
	if self._is_tased_shot then
		return 1
	end

	return self._charge_multiplier
end

function BowWeaponBaseVR:set_charge_multiplier(multiplier)
	self._charge_multiplier = multiplier

	self:tweak_data_anim_set_progress("charge", multiplier)
end

function BowWeaponBaseVR:tweak_data_anim_set_progress(anim, progress)
	local orig_anim = anim
	local unit_anim = self:_get_tweak_data_weapon_animation(orig_anim)
	local data = tweak_data.weapon.factory[self._factory_id]

	if data.animations and data.animations[unit_anim] then
		local anim_name = data.animations[unit_anim]
		local ids_anim_name = Idstring(anim_name)
		local length = self._unit:anim_length(ids_anim_name)

		self._unit:anim_set_time(ids_anim_name, progress * length)
	end

	for part_id, data in pairs(self._parts) do
		if data.animations and data.animations[unit_anim] then
			local anim_name = data.animations[unit_anim]
			local ids_anim_name = Idstring(anim_name)
			local length = data.unit:anim_length(ids_anim_name)

			data.unit:anim_set_time(ids_anim_name, progress * length)
		end
	end
end

local __update_bullet_objects = NewRaycastWeaponBase._update_bullet_objects

function BowWeaponBaseVR:_update_bullet_objects(ammo_func)
	local hand = managers.player:player_unit():hand()
	local bow_hand_id = hand:get_active_hand_id("bow")
	local weapon_hand_id = hand:get_active_hand_id("weapon")
	local weapon_state = weapon_hand_id and hand:current_hand_state(weapon_hand_id)

	if bow_hand_id then
		if not hand:current_hand_state(bow_hand_id):gripping_string() then
			if weapon_state then
				local ammo_base = self:ammo_base()

				if ammo_base[ammo_func](ammo_base) > 0 then
					weapon_state:link_arrow_unit(self)
				else
					weapon_state:unlink_arrow_unit()
				end
			end

			ammo_func = "empty"
		elseif weapon_state then
			weapon_state:unlink_arrow_unit()
		end
	end

	return __update_bullet_objects(self, ammo_func)
end

function BowWeaponBaseVR:empty()
	return 0
end

local __update_fire_object = BowWeaponBase._update_fire_object

function BowWeaponBaseVR:_update_fire_object()
	local fire = managers.weapon_factory:get_part_from_weapon_by_type("ammo", self._parts)

	if not fire then
		return __update_fire_object(self)
	end

	self:change_fire_object(fire.unit:orientation_object())
end

function BowWeaponBaseVR:_adjust_throw_z(vec)
end
