DummyCivilianBase = DummyCivilianBase or class()

function DummyCivilianBase:init(unit)
	self._unit = unit

	unit:set_driving("animation")
	unit:set_animation_lod(1, 500000, 500, 500000)
end

function DummyCivilianBase:play_state(state_name, at_time)
	local result = self._unit:play_state(Idstring(state_name), at_time)

	return result ~= Idstring("") and result
end

function DummyCivilianBase:anim_clbk_spear_spawn(unit)
	self:_spawn_spear()
end

function DummyCivilianBase:anim_clbk_spear_unspawn(unit)
	self:_unspawn_spear()
end

function DummyCivilianBase:_spawn_spear()
	if not alive(self._spear) then
		self._spear = World:spawn_unit(Idstring("units/test/beast/weapon/native_spear"), Vector3(), Rotation())

		self._unit:link(Idstring("a_weapon_right_front"), self._spear, self._spear:orientation_object():name())
	end
end

function DummyCivilianBase:_unspawn_spear()
	if alive(self._spear) then
		self._spear:set_slot(0)

		self._spear = nil
	end
end

function DummyCivilianBase:destroy(unit)
	self:_unspawn_spear()
end
