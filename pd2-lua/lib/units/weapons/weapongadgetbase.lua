WeaponGadgetBase = WeaponGadgetBase or class(UnitBase)
WeaponGadgetBase.GADGET_TYPE = ""

function WeaponGadgetBase:init(unit)
	WeaponGadgetBase.super.init(self, unit)

	self._on = false
end

function WeaponGadgetBase:set_npc()
end

function WeaponGadgetBase:set_state(on, sound_source, current_state)
	if not self:is_bipod() and not self:is_underbarrel() then
		self:_set_on(on, sound_source)
	end

	self:_check_state(current_state)
end

function WeaponGadgetBase:_set_on(on, sound_source)
	if self._on ~= on and sound_source and (self._on_event or self._off_event) then
		sound_source:post_event(on and self._on_event or self._off_event)
	end

	self._on = on
end

function WeaponGadgetBase:is_usable()
	return true
end

function WeaponGadgetBase:set_on()
	self._on = true

	self:_check_state()
end

function WeaponGadgetBase:set_off()
	self._on = false

	self:_check_state()
end

function WeaponGadgetBase:toggle()
	self._on = not self._on

	self:_check_state()
end

function WeaponGadgetBase:is_on()
	return self._on
end

function WeaponGadgetBase:toggle_requires_stance_update()
	return false
end

function WeaponGadgetBase:_check_state(current_state)
end

function WeaponGadgetBase:is_bipod()
	return false
end

function WeaponGadgetBase:is_underbarrel()
	return false
end

function WeaponGadgetBase:overrides_weapon_firing()
	return self:is_underbarrel()
end

function WeaponGadgetBase:destroy(unit)
	WeaponGadgetBase.super.pre_destroy(self, unit)
end
