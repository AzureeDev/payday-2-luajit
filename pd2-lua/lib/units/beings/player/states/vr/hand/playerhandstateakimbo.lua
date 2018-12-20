require("lib/units/beings/player/states/vr/hand/PlayerHandState")

PlayerHandStateAkimbo = PlayerHandStateAkimbo or class(PlayerHandState)

function PlayerHandStateAkimbo:init(hsm, name, hand_unit, sequence)
	PlayerHandStateAkimbo.super.init(self, name, hsm, hand_unit, sequence)
end

function PlayerHandStateAkimbo:_link_weapon(weapon_unit)
	if not alive(self._weapon_unit) then
		self._weapon_unit = weapon_unit

		self._hand_unit:link(Idstring("g_glove"), weapon_unit, weapon_unit:orientation_object():name())
		self._weapon_unit:base():on_enabled()
		self._weapon_unit:set_visible(true)

		local tweak = tweak_data.vr.weapon_offsets.weapons[self._weapon_unit:base().name_id] or tweak_data.vr.weapon_offsets.default

		if tweak and tweak.position then
			self._weapon_unit:set_local_position(tweak.position)
		end
	end
end

function PlayerHandStateAkimbo:_unlink_weapon()
	if alive(self._weapon_unit) then
		self._weapon_unit:set_visible(false)
		self._weapon_unit:base():on_disabled()
		self._weapon_unit:unlink()

		self._weapon_unit = nil
	end
end

function PlayerHandStateAkimbo:at_enter(prev_state)
	PlayerHandStateAkimbo.super.at_enter(self, prev_state)

	if alive(managers.player:player_unit()) then
		local equipped_weapon = managers.player:player_unit():inventory():equipped_unit()

		if alive(equipped_weapon) and equipped_weapon:base().akimbo then
			self:_link_weapon(equipped_weapon:base()._second_gun)
		else
			self:hsm():set_default_state("idle")

			return
		end
	end

	self._hand_unit:melee():set_weapon_unit(self._weapon_unit)
	self:hsm():enter_controller_state("empty")
	self:hsm():enter_controller_state("akimbo")

	local sequence = self._sequence
	local tweak = tweak_data.vr:get_offset_by_id(self._weapon_unit:base().name_id)

	if tweak.grip then
		sequence = tweak.grip
	end

	if self._hand_unit and sequence and self._hand_unit:damage():has_sequence(sequence) then
		self._hand_unit:damage():run_sequence_simple(sequence)
	end
end

function PlayerHandStateAkimbo:at_exit(next_state)
	self:hsm():exit_controller_state("akimbo")
	self._hand_unit:melee():set_weapon_unit()
	self:_unlink_weapon()
	PlayerHandStateAkimbo.super.at_exit(self, next_state)
end

function PlayerHandStateAkimbo:set_wanted_weapon_kick(amount)
	self._wanted_weapon_kick = math.min((self._wanted_weapon_kick or 0) + amount * tweak_data.vr.weapon_kick.kick_mul, tweak_data.vr.weapon_kick.max_kick)
end

function PlayerHandStateAkimbo:update(t, dt)
	if self._weapon_kick then
		self._hand_unit:set_position(self:hsm():position() - self._hand_unit:rotation():y() * self._weapon_kick)
	end

	if self._wanted_weapon_kick then
		self._weapon_kick = self._weapon_kick or 0

		if self._weapon_kick < self._wanted_weapon_kick then
			self._weapon_kick = math.lerp(self._weapon_kick, self._wanted_weapon_kick, dt * tweak_data.vr.weapon_kick.kick_speed)
		else
			self._wanted_weapon_kick = 0
			self._weapon_kick = math.lerp(self._weapon_kick, self._wanted_weapon_kick, dt * tweak_data.vr.weapon_kick.return_speed)
		end
	end
end
