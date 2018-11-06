PlayerEquipmentVR = PlayerEquipment

function PlayerEquipmentVR:_m_deploy_rot()
	local active_hand = self._unit:hand():get_active_hand("deployable") or self._unit:hand():get_active_hand("weapon")

	if not active_hand then
		return Rotation()
	end

	return active_hand:rotation()
end

function PlayerEquipmentVR:dummy_unit()
	return alive(self._dummy_unit) and self._dummy_unit
end

function PlayerEquipmentVR:valid_look_at_placement(equipment_data)
	local active_hand = self._unit:hand():get_active_hand("deployable") or self._unit:hand():get_active_hand("weapon")

	if not active_hand then
		return false
	end

	local from = active_hand:position()
	local to = from + active_hand:rotation():y() * 200
	local ray = self._unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {}, "ray_type", "equipment_placement")

	if ray and equipment_data and equipment_data.dummy_unit then
		local pos = ray.position
		local rot = Rotation(ray.normal, math.UP)

		if not alive(self._dummy_unit) then
			self._dummy_unit = World:spawn_unit(Idstring(equipment_data.dummy_unit), pos, rot)

			self:_disable_contour(self._dummy_unit)
		end

		self._dummy_unit:set_position(pos)
		self._dummy_unit:set_rotation(rot)
	end

	if alive(self._dummy_unit) then
		self._dummy_unit:set_enabled(ray and true or false)
	end

	return ray
end

function PlayerEquipmentVR:valid_shape_placement(equipment_id, equipment_data)
	local active_hand = self._unit:hand():get_active_hand("deployable") or self._unit:hand():get_active_hand("weapon")

	if not active_hand then
		return false
	end

	local from = active_hand:position()
	local to = from + active_hand:rotation():y() * 220
	local ray = self._unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {}, "ray_type", "equipment_placement")
	local valid = ray and true or false

	if ray then
		local pos = ray.position
		local rot = active_hand:rotation()
		rot = Rotation(rot:yaw(), 0, 0)

		if not alive(self._dummy_unit) then
			self._dummy_unit = World:spawn_unit(Idstring(equipment_data.dummy_unit), pos, rot)

			self:_disable_contour(self._dummy_unit)
		end

		self._dummy_unit:set_position(pos)
		self._dummy_unit:set_rotation(rot)

		valid = valid and math.dot(ray.normal, math.UP) > 0.25
		local find_start_pos, find_end_pos, find_radius = nil

		if equipment_id == "ammo_bag" then
			find_start_pos = pos + math.UP * 20
			find_end_pos = pos + math.UP * 21
			find_radius = 12
		elseif equipment_id == "doctor_bag" then
			find_start_pos = pos + math.UP * 22
			find_end_pos = pos + math.UP * 28
			find_radius = 15
		else
			find_start_pos = pos + math.UP * 30
			find_end_pos = pos + math.UP * 40
			find_radius = 17
		end

		local bodies = self._dummy_unit:find_bodies("intersect", "capsule", find_start_pos, find_end_pos, find_radius, managers.slot:get_mask("trip_mine_placeables") + 14 + 25)

		for _, body in ipairs(bodies) do
			if body:unit() ~= self._dummy_unit and body:has_ray_type(Idstring("body")) then
				valid = false

				break
			end
		end
	end

	if alive(self._dummy_unit) then
		self._dummy_unit:set_enabled(valid)
	end

	return valid and ray
end

function PlayerEquipment:throw_projectile()
	local active_hand = self._unit:hand():get_active_hand("throwable") or self._unit:hand():get_active_hand("weapon")

	if not active_hand then
		return false
	end

	local projectile_entry = managers.blackmarket:equipped_projectile()
	local projectile_data = tweak_data.blackmarket.projectiles[projectile_entry]
	local from = active_hand:position()
	local dir = active_hand:rotation():y()
	local pos = from + dir * 30 + Vector3(0, 0, 0)
	local say_line = projectile_data.throw_shout or "g43"

	if say_line and say_line ~= true then
		self._unit:sound():play(say_line, nil, true)
	end

	local projectile_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile_entry)

	if not projectile_data.client_authoritative then
		if Network:is_client() then
			managers.network:session():send_to_host("request_throw_projectile", projectile_index, pos, dir)
		else
			ProjectileBase.throw_projectile(projectile_entry, pos, dir, managers.network:session():local_peer():id())
			managers.player:verify_grenade(managers.network:session():local_peer():id())
		end
	else
		ProjectileBase.throw_projectile(projectile_entry, pos, dir, managers.network:session():local_peer():id())
		managers.player:verify_grenade(managers.network:session():local_peer():id())
	end

	managers.player:on_throw_grenade()
end

function PlayerEquipment:throw_grenade()
	local active_hand = self._unit:hand():get_active_hand("throwable") or self._unit:hand():get_active_hand("weapon")

	if not active_hand then
		return false
	end

	local from = active_hand:position()
	local dir = active_hand:rotation():y()
	local pos = from + dir * 30 + Vector3(0, 0, 0)

	self._unit:sound():play("g43", nil, true)

	local projectile_entry = managers.blackmarket:equipped_grenade()
	local grenade_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile_entry)

	if Network:is_client() then
		managers.network:session():send_to_host("request_throw_projectile", grenade_index, pos, dir)
	else
		ProjectileBase.throw_projectile(projectile_entry, pos, dir, managers.network:session():local_peer():id())
		managers.player:verify_grenade(managers.network:session():local_peer():id())
	end

	managers.player:on_throw_grenade()
end
