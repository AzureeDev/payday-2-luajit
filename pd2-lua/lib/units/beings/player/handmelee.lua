HandMelee = HandMelee or class()

function HandMelee:init(hand_unit)
	self._hand_unit = hand_unit
end

function HandMelee:has_weapon()
	return self._entry == "weapon" and alive(self._weapon_unit) and self._weapon_unit:enabled() and self._weapon_unit:visible()
end

function HandMelee:has_melee_weapon()
	return self._entry ~= "weapon" and alive(self._melee_unit) and not self:has_custom_weapon()
end

function HandMelee:has_custom_weapon()
	return alive(self._custom_unit)
end

function HandMelee:set_melee_unit(unit)
	self._melee_unit = unit
	self._entry = alive(unit) and managers.blackmarket:equipped_melee_weapon() or self:has_custom_weapon() and "custom" or "weapon"
end

function HandMelee:set_fist(entry)
	self._melee_unit = self._hand_unit
	self._entry = entry
end

function HandMelee:set_weapon_unit(unit)
	self._weapon_unit = unit

	if not alive(unit) then
		return
	end

	self._entry = "weapon"
	local weapon_base = self._weapon_unit:base()
	self._bayonet_entry = managers.blackmarket:equipped_bayonet(weapon_base.name_id)
	self._bayonet_unit = self._bayonet_entry and weapon_base._parts[self._bayonet_entry].unit
	self._weapon_id = weapon_base.name_id
end

function HandMelee:set_custom_unit(unit, id)
	self._custom_unit = unit

	if not alive(unit) then
		return
	end

	self._entry = "weapon"
	self._custom_id = id
end

function HandMelee:unit()
	if self:has_weapon() then
		return self._weapon_unit
	elseif self:has_melee_weapon() then
		return self._melee_unit
	end
end

local ray_vec = Vector3(0, 0, 0)
local ray_pen = Draw:pen()

function HandMelee:_get_hitpoint()
	if self:has_weapon() then
		if alive(self._bayonet_unit) then
			if tweak_data.vr.melee_offsets.bayonets[self._bayonet_entry] and tweak_data.vr.melee_offsets.bayonets[self._bayonet_entry].hit_point then
				return self._bayonet_unit:position() + tweak_data.vr.melee_offsets.bayonets[self._bayonet_entry].hit_point:rotate_with(self._bayonet_unit:rotation())
			end

			local hit_point = self._bayonet_unit:position() + Vector3(0, self._bayonet_unit:oobb():size().y, 0):rotate_with(self._bayonet_unit:rotation())
			hit_point = hit_point - Vector3(0, self._bayonet_unit:oobb():distance_to_point(hit_point), 0):rotate_with(self._bayonet_unit:rotation())

			return hit_point
		elseif tweak_data.vr.melee_offsets.custom[self._weapon_id] and tweak_data.vr.melee_offsets.custom[self._weapon_id].hit_point then
			return self._weapon_unit:position() + tweak_data.vr.melee_offsets.custom[self._weapon_id].hit_point:rotate_with(self._weapon_unit:rotation())
		else
			local length = self._weapon_unit:oobb():size().y
			local hit_point = self._weapon_unit:position() + Vector3(0, length, 0):rotate_with(self._weapon_unit:rotation())
			hit_point = hit_point - Vector3(0, self._weapon_unit:oobb():distance_to_point(hit_point), 0):rotate_with(self._weapon_unit:rotation())

			return hit_point, length
		end
	elseif self:has_melee_weapon() then
		local vr_offset = tweak_data.vr.melee_offsets.weapons[self._entry]

		if vr_offset and vr_offset.hit_point then
			return self._melee_unit:position() + vr_offset.hit_point:rotate_with(self._melee_unit:rotation())
		end

		local hit_point = self._melee_unit:position() + Vector3(0, self._melee_unit:oobb():size().y, 0):rotate_with(self._melee_unit:rotation())
		hit_point = hit_point - Vector3(0, self._melee_unit:oobb():distance_to_point(hit_point), 0):rotate_with(self._melee_unit:rotation())

		return hit_point
	elseif self:has_custom_weapon() then
		if tweak_data.vr.melee_offsets.custom[self._custom_id] and tweak_data.vr.melee_offsets.custom[self._custom_id].hit_point then
			return self._custom_unit:position() + tweak_data.vr.melee_offsets.custom[self._custom_id].hit_point:rotate_with(self._custom_unit:rotation())
		end

		local hit_point = self._custom_unit:position() + Vector3(0, self._custom_unit:oobb():size().y, 0):rotate_with(self._custom_unit:rotation())
		hit_point = hit_point - Vector3(0, self._custom_unit:oobb():distance_to_point(hit_point), 0):rotate_with(self._custom_unit:rotation())

		return hit_point
	end
end

local mvec_delta = Vector3()
local mvec_bayonet_dir = Vector3()

function HandMelee:update(unit, t, dt)
	if not self:has_melee_weapon() and not self:has_weapon() and not self:has_custom_weapon() then
		if alive(self._weapon_unit) then
			self:set_melee_unit()
		else
			return
		end
	end

	local hit_point, length = self:_get_hitpoint()

	if not hit_point then
		return
	end

	local valid_hit = false
	local has_bayonet = self:has_weapon() and alive(self._bayonet_unit)

	if self:has_weapon() or self:has_custom_weapon() then
		local limit = 5
		local point = nil

		if has_bayonet then
			limit = 2.5
			point = mvector3.copy(self._hand_unit:position())
		else
			point = mvector3.copy(hit_point)
		end

		if length then
			limit = limit * length / 3
		end

		mvector3.subtract(point, managers.player:player_unit():position())

		self._avg_momentum = self._avg_momentum or Vector3()
		self._last_pos = self._last_pos or point
		local delta = mvec_delta

		mvector3.set(delta, point)
		mvector3.subtract(delta, self._last_pos)

		if has_bayonet then
			local bayonet_dir = mvec_bayonet_dir

			mvector3.set(bayonet_dir, self._bayonet_unit:rotation():y())

			local scalar = mvector3.dot(delta, bayonet_dir)

			mvector3.multiply(bayonet_dir, scalar)
			mvector3.set(delta, bayonet_dir)
		end

		mvector3.add(delta, self._avg_momentum)
		mvector3.divide(delta, 2)
		mvector3.set(self._avg_momentum, delta)

		self._last_pos = point

		if limit < mvector3.length_sq(self._avg_momentum) then
			valid_hit = true
		end
	else
		valid_hit = true
	end

	if valid_hit then
		local start_pos = self._hand_unit:position()

		if has_bayonet then
			start_pos = self._bayonet_unit:position()
		end

		local ray = self._hand_unit:raycast("ray", start_pos, hit_point, "slot_mask", managers.slot:get_mask("bullet_impact_targets"), "ray_type", "body melee")

		if ray then
			if not self._next_hit_t or self._next_hit_t < t then
				if self._next_full_hit_t and t < self._next_full_hit_t then
					local range = tweak_data.blackmarket.melee_weapons[self._entry].expire_t
					local current = range - (self._next_full_hit_t - t)
					local dmg_mul = current / range

					managers.player:mul_melee_damage(dmg_mul * dmg_mul)
				end

				managers.player:player_unit():movement():current_state():_do_melee_damage(t, has_bayonet, ray, self._entry, PlayerHand.hand_id(self._hand_unit:base():name()))

				self._next_hit_t = t + tweak_data.blackmarket.melee_weapons[self._entry].expire_t
				self._next_full_hit_t = self._next_hit_t
				self._charge_start_t = nil

				managers.player:reset_melee_dmg_multiplier()

				if self._charge_sound then
					self._charge_sound:stop()

					self._charge_sound = nil
				end
			end
		else
			self._next_hit_t = nil
		end
	end
end

function HandMelee:charge_start_t()
	return self._charge_start_t
end

function HandMelee:set_charge_start_t(t)
	if self._next_full_hit_t and t and t < self._next_full_hit_t then
		return
	end

	self._charge_start_t = t

	if t and not self._charge_sound then
		local tweak = tweak_data.blackmarket.melee_weapons[self._entry]

		if tweak.sounds and tweak.sounds.charge then
			self._charge_sound = managers.player:player_unit():sound():play(tweak.sounds.charge)
		end
	elseif not t and self._charge_sound then
		self._charge_sound:stop()

		self._charge_sound = nil
	end
end
