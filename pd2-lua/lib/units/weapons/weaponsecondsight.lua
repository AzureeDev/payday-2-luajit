WeaponSecondSight = WeaponSecondSight or class(WeaponGadgetBase)
WeaponSecondSight.GADGET_TYPE = "second_sight"

function WeaponSecondSight:init(unit)
	WeaponSecondSight.super.init(self, unit)

	if self._use_sound then
		self._on_event = self._on_event or "gadget_magnifier_on"
		self._off_event = self._off_event or "gadget_magnifier_off"
	end

	if self._use_anims then
		self._anim_state = self._on

		if self.anim then
			self._anim = Idstring(self.anim)
		end
	end
end

function WeaponSecondSight:_check_state(current_state)
	if current_state and current_state.in_steelsight and current_state:in_steelsight() then
		current_state:_start_action_steelsight(Application:time(), self._on)
	end

	if self._use_anims and self._anim_state ~= self._on then
		self._anim_state = self._on

		self:play_anim()
	end

	WeaponSecondSight.super._check_state(self, current_state)
end

function WeaponSecondSight:toggle_requires_stance_update()
	return true
end

function WeaponSecondSight:play_anim()
	if not self._anim then
		return
	end

	local length = self._unit:anim_length(self._anim)
	local speed = self._anim_state and 1 or -1

	self._unit:anim_play_to(self._anim, self._anim_state and length or 0, speed)
end

function WeaponSecondSight:destroy(unit)
	WeaponSecondSight.super.destroy(self, unit)
end
