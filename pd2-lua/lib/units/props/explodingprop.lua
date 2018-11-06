ExplodingProp = ExplodingProp or class()
ExplodingProp.DETONATE_EVENT_ID = 1
ExplodingProp.EXTENSION = "base"

function ExplodingProp:init(unit)
	self._unit = unit
end

function ExplodingProp:detonate(pos, range, damage, player_damage)
	if not pos or not range or not damage or not player_damage then
		Application:error("Invalid parameters sent to ExplodingProp-extension. Pos: " .. tostring(pos) .. ", Range: " .. tostring(range) .. ", Damage: " .. tostring(damage) .. ", Player damage: " .. tostring(player_damage) .. ", Unit: " .. tostring(self._unit:name():t()))

		return
	elseif self._unit:id() == -1 then
		Application:error("Unit needs to be network synced when using ExplodingProp-extension. Unit: " .. tostring(self._unit:name():t()))

		return
	end

	local effect_params = {
		sound_event = "grenade_explode",
		effect = "effects/payday2/particles/explosions/grenade_explosion",
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		feedback_range = range * 2
	}

	if Network:is_server() then
		local normal = math.UP
		local slot_mask = managers.slot:get_mask("explosion_targets")
		local damage_params = {
			player_damage = 0,
			curve_pow = 3,
			no_raycast_check_characters = false,
			hit_pos = pos,
			range = range,
			collision_slotmask = slot_mask,
			damage = damage,
			ignore_unit = self._unit
		}

		managers.explosion:give_local_player_dmg(pos, range, player_damage)
		managers.explosion:play_sound_and_effects(pos, normal, range, effect_params)
		managers.explosion:detect_and_give_dmg(damage_params)

		if self._unit[self.EXTENSION](self._unit) ~= self then
			Application:error("Invalid extension name on ExplodingProp-extension. Should be \"" .. self.EXTENSION .. "\". Unit: " .. tostring(self._unit:name():t()))
		else
			managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, self.EXTENSION, ExplodingProp.DETONATE_EVENT_ID)
		end
	else
		if not self._data_list then
			self._data_list = {}
		end

		table.insert(self._data_list, {
			range = range,
			damage = damage,
			player_damage = player_damage,
			pos = pos,
			effect_params = effect_params
		})
		self:_check_detonation_ready()
	end
end

function ExplodingProp:sync_net_event(event_id)
	if event_id == ExplodingProp.DETONATE_EVENT_ID then
		self:_detonate_on_client()
	end
end

function ExplodingProp:_detonate_on_client()
	self._recieved_detonate_on_client = true

	self:_check_detonation_ready()
end

function ExplodingProp:_check_detonation_ready()
	if not self._recieved_detonate_on_client then
		return
	end

	if self._data_list == nil then
		return
	end

	local data = table.remove(self._data_list, 1)

	managers.explosion:give_local_player_dmg(data.pos, data.range, data.player_damage)
	managers.explosion:explode_on_client(data.pos, math.UP, nil, data.damage, data.range, 5, data.effect_params)

	if not next(self._data_list) then
		self._data_list = nil
	end
end
