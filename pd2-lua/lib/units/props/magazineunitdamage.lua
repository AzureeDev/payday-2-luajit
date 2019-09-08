MagazineUnitDamage = MagazineUnitDamage or class(UnitDamage)
local ray_from = Vector3()
local ray_to = Vector3()
local empty_idstr = Idstring("")
local idstr_concrete = Idstring("concrete")
local idstr_no_material = Idstring("no_material")

function MagazineUnitDamage:play_collision_sfx(other_unit, position, normal, collision_velocity)
	mvector3.set(ray_from, position)
	mvector3.set(ray_to, normal)
	mvector3.multiply(ray_to, -10)
	mvector3.add(ray_to, position)

	local material_name, sound_switch_name = nil
	local slot_mask = managers.slot:get_mask("footstep")
	local collision_ray = World:raycast("ray", ray_from, ray_to, "slot_mask", slot_mask, "ignore_unit", self._unit)

	if collision_ray and collision_ray.unit then
		material_name = World:pick_decal_material(collision_ray.unit, ray_from, ray_to, slot_mask)
	end

	material_name = material_name ~= empty_idstr and material_name

	if material_name then
		sound_switch_name = material_name
	else
		sound_switch_name = idstr_concrete
	end

	local ss = SoundDevice:create_source("collision")

	ss:set_position(position)
	ss:set_switch("materials", self:material_name(sound_switch_name))
	ss:post_event(self._collision_event)
end

function MagazineUnitDamage:material_name(idstring)
	local material = tweak_data.materials[idstring:key()]

	if not material then
		Application:error("Sound for material not found: " .. tostring(idstring))

		material = "no_material"
	end

	return material
end
