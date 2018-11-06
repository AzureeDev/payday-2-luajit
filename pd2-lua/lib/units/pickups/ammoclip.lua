AmmoClip = AmmoClip or class(Pickup)
AmmoClip.EVENT_IDS = {
	bonnie_share_ammo = 1,
	register_grenade = 16
}
local CABLE_TIE_GET_CHANCE = 0.2
local CABLE_TIE_GET_AMOUNT = 1

function AmmoClip:init(unit)
	AmmoClip.super.init(self, unit)

	self._ammo_type = ""
	self._ammo_box = self._unit:name() == Idstring("units/pickups/ammo/ammo_pickup")

	if self._ammo_box then
		self:reload_contour()
	end
end

function AmmoClip:reload_contour()
	if self._ammo_box and self._unit:contour() then
		if managers.user:get_setting("ammo_contour") then
			self._unit:contour():add("deployable_selected")
		else
			self._unit:contour():remove("deployable_selected")
		end
	end
end

function AmmoClip:_pickup(unit)
	if self._picked_up then
		return
	end

	local player_manager = managers.player
	local inventory = unit:inventory()

	if not unit:character_damage():dead() and inventory then
		local picked_up = false

		if self._projectile_id then
			if managers.blackmarket:equipped_projectile() == self._projectile_id and not player_manager:got_max_grenades() then
				player_manager:add_grenade_amount(self._ammo_count or 1)

				picked_up = true
			end
		else
			local available_selections = {}

			for i, weapon in pairs(inventory:available_selections()) do
				if inventory:is_equipped(i) then
					table.insert(available_selections, 1, weapon)
				else
					table.insert(available_selections, weapon)
				end
			end

			local success, add_amount = nil

			for _, weapon in ipairs(available_selections) do
				if not self._weapon_category or self._weapon_category == weapon.unit:base():weapon_tweak_data().categories[1] then
					success, add_amount = weapon.unit:base():add_ammo(1, self._ammo_count)
					picked_up = success or picked_up

					if self._ammo_count then
						self._ammo_count = math.max(math.floor(self._ammo_count - add_amount), 0)
					end

					if picked_up and tweak_data.achievement.pickup_sticks and self._weapon_category == tweak_data.achievement.pickup_sticks.weapon_category then
						managers.achievment:award_progress(tweak_data.achievement.pickup_sticks.stat)
					end
				end
			end
		end

		if picked_up then
			self._picked_up = true
			local rand = math.random()

			if rand <= CABLE_TIE_GET_CHANCE and self._ammo_box then
				managers.player:add_cable_ties(CABLE_TIE_GET_AMOUNT)
			end

			if not self._projectile_id and not self._weapon_category then
				local restored_health = nil

				if not unit:character_damage():is_downed() and player_manager:has_category_upgrade("temporary", "loose_ammo_restore_health") and not player_manager:has_activate_temporary_upgrade("temporary", "loose_ammo_restore_health") then
					player_manager:activate_temporary_upgrade("temporary", "loose_ammo_restore_health")

					local values = player_manager:temporary_upgrade_value("temporary", "loose_ammo_restore_health", 0)

					if values ~= 0 then
						local restore_value = math.random(values[1], values[2])
						local num_more_hp = 1

						if player_manager:num_connected_players() > 0 then
							num_more_hp = player_manager:num_players_with_more_health()
						end

						local base = tweak_data.upgrades.loose_ammo_restore_health_values.base
						local sync_value = math.round(math.clamp(restore_value - base, 0, 13))
						restore_value = restore_value * (tweak_data.upgrades.loose_ammo_restore_health_values.multiplier or 0.1)
						local percent_inc = player_manager:upgrade_value("player", "gain_life_per_players", 0) * num_more_hp + 1

						print("[AmmoClip:_pickup] Percent increase for health pickup is: ", percent_inc - 1)

						restore_value = restore_value * percent_inc
						local damage_ext = unit:character_damage()

						if not damage_ext:need_revive() and not damage_ext:dead() and not damage_ext:is_berserker() then
							damage_ext:restore_health(restore_value, true)
							unit:sound():play("pickup_ammo_health_boost", nil, true)
						end

						if player_manager:has_category_upgrade("player", "loose_ammo_restore_health_give_team") then
							managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", 2 + sync_value)
						end
					end
				end

				if player_manager:has_category_upgrade("temporary", "loose_ammo_give_team") and not player_manager:has_activate_temporary_upgrade("temporary", "loose_ammo_give_team") then
					player_manager:activate_temporary_upgrade("temporary", "loose_ammo_give_team")
					managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", AmmoClip.EVENT_IDS.bonnie_share_ammo)
				end
			elseif self._projectile_id then
				player_manager:register_grenade(managers.network:session():local_peer():id())
				managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", AmmoClip.EVENT_IDS.register_grenade)
			end

			if Network:is_client() then
				managers.network:session():send_to_host("sync_pickup", self._unit)
			end

			unit:sound():play(self._pickup_event or "pickup_ammo", nil, true)
			self:consume()

			if self._ammo_box then
				player_manager:send_message(Message.OnAmmoPickup, nil, unit)
			end

			return true
		end
	end

	return false
end

function AmmoClip:sync_net_event(event, peer)
	local player = managers.player:local_player()

	if not alive(player) or not player:character_damage() or player:character_damage():is_downed() or player:character_damage():dead() then
		return
	end

	if event == AmmoClip.EVENT_IDS.bonnie_share_ammo then
		local inventory = player:inventory()

		if inventory then
			local picked_up = false

			for id, weapon in pairs(inventory:available_selections()) do
				picked_up = weapon.unit:base():add_ammo(tweak_data.upgrades.loose_ammo_give_team_ratio or 0.25) or picked_up
			end

			if picked_up then
				player:sound():play(self._pickup_event or "pickup_ammo", nil, true)

				for id, weapon in pairs(inventory:available_selections()) do
					managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
				end
			end
		end
	elseif event == AmmoClip.EVENT_IDS.register_grenade then
		if peer and not self._grenade_registered then
			managers.player:register_grenade(peer:id())

			self._grenade_registered = true
		end
	elseif AmmoClip.EVENT_IDS.bonnie_share_ammo < event then
		local damage_ext = player:character_damage()

		if not damage_ext:need_revive() and not damage_ext:dead() and not damage_ext:is_berserker() then
			local restore_value = event - 2 + (tweak_data.upgrades.loose_ammo_restore_health_values.base or 3)
			restore_value = restore_value * (tweak_data.upgrades.loose_ammo_restore_health_values.multiplier or 0.1)
			restore_value = restore_value * (tweak_data.upgrades.loose_ammo_give_team_health_ratio or 0.35)

			if damage_ext:restore_health(restore_value, true, true) then
				player:sound():play("pickup_ammo_health_boost", nil, true)
			end
		end
	end
end
