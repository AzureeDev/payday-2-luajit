core:import("CoreMissionScriptElement")

ElementExplosion = ElementExplosion or class(ElementFeedback)

function ElementExplosion:init(...)
	ElementExplosion.super.init(self, ...)

	if Application:editor() and self._values.explosion_effect ~= "none" then
		CoreEngineAccess._editor_load(self.IDS_EFFECT, self._values.explosion_effect:id())
	end
end

function ElementExplosion:client_on_executed(...)
	self:on_executed(...)
end

function ElementExplosion:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	print("ElementExplosion:on_executed( instigator )")

	local pos, rot = self:get_orientation()
	local player = managers.player:player_unit()

	if player then
		player:character_damage():damage_explosion({
			position = pos,
			range = self._values.range,
			damage = self._values.player_damage
		})
	end

	managers.explosion:spawn_sound_and_effects(pos, rot:z(), self._values.range, self._values.explosion_effect, self._values.sound_event)

	if Network:is_server() then
		managers.explosion:detect_and_give_dmg({
			curve_pow = 5,
			player_damage = 0,
			hit_pos = pos,
			range = self._values.range,
			collision_slotmask = managers.slot:get_mask("explosion_targets"),
			damage = self._values.damage,
			no_raycast_check_characters = self._values.no_raycast_check_characters
		})
		managers.network:session():send_to_peers_synched("element_explode_on_client", pos, rot:z(), self._values.damage, self._values.range, 5)
	end

	ElementExplosion.super.on_executed(self, instigator)
end
