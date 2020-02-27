HuskTeamAIBase = HuskTeamAIBase or class(HuskCopBase)
HuskTeamAIBase.set_loadout = TeamAIBase.set_loadout
HuskTeamAIBase.remove_upgrades = TeamAIBase.remove_upgrades

function HuskTeamAIBase:default_weapon_name()
	return TeamAIBase.default_weapon_name(self)
end

function HuskTeamAIBase:post_init()
	self._ext_anim = self._unit:anim_data()

	self._unit:movement():post_init()
	self:set_anim_lod(1)

	self._lod_stage = 1
	self._allow_invisible = true

	TeamAIBase._register(self)
	managers.occlusion:remove_occlusion(self._unit)
end

function HuskTeamAIBase:nick_name()
	return TeamAIBase.nick_name(self)
end

function HuskTeamAIBase:on_death_exit()
	HuskTeamAIBase.super.on_death_exit(self)
	TeamAIBase.unregister(self)
	self:set_slot(self._unit, 0)
end

function HuskTeamAIBase:pre_destroy(unit)
	self:remove_upgrades()
	unit:movement():pre_destroy()
	unit:inventory():pre_destroy(unit)
	TeamAIBase.unregister(self)
	UnitBase.pre_destroy(self, unit)
end

function HuskTeamAIBase:load(data)
	self._tweak_table = data.base.tweak_table or self._tweak_table
	local character_name = self._tweak_table

	if character_name then
		local old_unit = managers.criminals:character_unit_by_name(character_name)

		if old_unit then
			local peer = managers.network:session():peer_by_unit(old_unit)

			if peer then
				managers.network:session():on_peer_lost(peer, peer:id())
			end
		end

		local loadout = managers.blackmarket:unpack_henchman_loadout_string(data.base.loadout)

		managers.blackmarket:verfify_recived_crew_loadout(loadout, true)
		managers.groupai:state():set_unit_teamAI(self._unit, character_name, tweak_data.levels:get_default_team_ID("player"), data.base.visual_seed, loadout)
	end
end

function HuskTeamAIBase:chk_freeze_anims()
end

function HuskTeamAIBase:unregister()
	TeamAIBase.unregister(self)
end

function HuskTeamAIBase:character_name()
	return managers.criminals:character_name_by_unit(self._unit)
end
