local ids_lod = Idstring("lod")
local ids_lod1 = Idstring("lod1")
local ids_ik_aim = Idstring("ik_aim")
CopBase = CopBase or class(UnitBase)
CopBase._anim_lods = {
	{
		2,
		500,
		100,
		5000
	},
	{
		2,
		0,
		100,
		1
	},
	{
		3,
		0,
		100,
		1
	}
}
CopBase._material_translation_map = {}
local character_path = ""
local char_map = tweak_data.character.character_map()

for _, data in pairs(char_map) do
	for _, character in ipairs(data.list) do
		character_path = data.path .. character .. "/" .. character
		CopBase._material_translation_map[tostring(Idstring(character_path):key())] = Idstring(character_path .. "_contour")
		CopBase._material_translation_map[tostring(Idstring(character_path .. "_contour"):key())] = Idstring(character_path)
	end
end

function CopBase:init(unit)
	UnitBase.init(self, unit, false)

	self._char_tweak = tweak_data.character[self._tweak_table]
	self._unit = unit
	self._visibility_state = true
	self._foot_obj_map = {
		right = self._unit:get_object(Idstring("RightToeBase")),
		left = self._unit:get_object(Idstring("LeftToeBase"))
	}
	self._is_in_original_material = true
	self._buffs = {}
end

function CopBase:post_init()
	self._ext_movement = self._unit:movement()
	self._ext_anim = self._unit:anim_data()

	self:set_anim_lod(1)

	self._lod_stage = 1

	self._ext_movement:post_init(true)
	self._unit:brain():post_init()
	managers.enemy:register_enemy(self._unit)

	self._allow_invisible = true

	self:_chk_spawn_gear()
	self:enable_leg_arm_hitbox()
end

function CopBase:enable_leg_arm_hitbox()
	if self._unit:damage() and self._unit:damage():has_sequence("leg_arm_hitbox") then
		self._unit:damage():run_sequence_simple("leg_arm_hitbox")
	else
		Application:error("Unit " .. tostring(self._unit) .. " has no 'leg_arm_hitbox' sequence! Leg and arm hitboxes will not be enabled.")
	end
end

function CopBase:_chk_spawn_gear()
	local tweak = tweak_data.narrative.jobs[managers.job:current_real_job_id()]

	if self._tweak_table == "spooc" and tweak and tweak.is_christmas_heist then
		local align_obj_name = Idstring("Head")
		local align_obj = self._unit:get_object(align_obj_name)
		self._headwear_unit = World:spawn_unit(Idstring("units/payday2/characters/ene_acc_spook_santa_hat/ene_acc_spook_santa_hat"), Vector3(), Rotation())

		self._unit:link(align_obj_name, self._headwear_unit, self._headwear_unit:orientation_object():name())
	end
end

function CopBase:has_tag(tag)
	local tags = self:char_tweak().tags

	return tags and table.contains(tags, tag) or false
end

function CopBase:has_all_tags(tags)
	local my_tags = self:char_tweak().tags

	return my_tags and table.contains_all(my_tags, tags) or false
end

function CopBase:has_any_tag(tags)
	local my_tags = self:char_tweak().tags

	return my_tags and table.contains_any(my_tags, tags) or false
end

function CopBase:default_weapon_name()
	local default_weapon_id = self._default_weapon_id
	local weap_ids = tweak_data.character.weap_ids

	for i_weap_id, weap_id in ipairs(weap_ids) do
		if default_weapon_id == weap_id then
			return tweak_data.character.weap_unit_names[i_weap_id]
		end
	end
end

function CopBase:visibility_state()
	return self._visibility_state
end

function CopBase:lod_stage()
	return self._lod_stage
end

function CopBase:set_allow_invisible(allow)
	self._allow_invisible = allow
end

function CopBase:set_visibility_state(stage)
	local state = stage and true

	if not state and not self._allow_invisible then
		state = true
		stage = 1
	end

	if self._lod_stage == stage then
		return
	end

	local inventory = self._unit:inventory()
	local weapon = inventory and inventory.get_weapon and inventory:get_weapon()

	if weapon then
		weapon:base():set_flashlight_light_lod_enabled(stage ~= 2 and not not stage)
	end

	if self._visibility_state ~= state then
		local unit = self._unit

		if inventory then
			inventory:set_visibility_state(state)
		end

		unit:set_visible(state)

		if self._headwear_unit then
			self._headwear_unit:set_visible(state)
		end

		if state or self._ext_anim.can_freeze and self._ext_anim.upper_body_empty then
			unit:set_animatable_enabled(ids_lod, state)
			unit:set_animatable_enabled(ids_ik_aim, state)
		end

		self._visibility_state = state
	end

	if state then
		self:set_anim_lod(stage)
		self._unit:movement():enable_update(true)

		if stage == 1 then
			self._unit:set_animatable_enabled(ids_lod1, true)
		elseif self._lod_stage == 1 then
			self._unit:set_animatable_enabled(ids_lod1, false)
		end
	end

	self._lod_stage = stage

	self:chk_freeze_anims()
end

function CopBase:set_anim_lod(stage)
	self._unit:set_animation_lod(unpack(self._anim_lods[stage]))
end

function CopBase:on_death_exit()
	self._unit:set_animations_enabled(false)
end

function CopBase:chk_freeze_anims()
	if (not self._lod_stage or self._lod_stage > 1) and self._ext_anim.can_freeze and self._ext_anim.upper_body_empty then
		if not self._anims_frozen then
			self._anims_frozen = true

			self._unit:set_animations_enabled(false)
			self._ext_movement:on_anim_freeze(true)
		end
	elseif self._anims_frozen then
		self._anims_frozen = nil

		self._unit:set_animations_enabled(true)
		self._ext_movement:on_anim_freeze(false)
	end
end

function CopBase:anim_act_clbk(unit, anim_act, send_to_action)
	if send_to_action then
		unit:movement():on_anim_act_clbk(anim_act)
	elseif unit:unit_data().mission_element then
		unit:unit_data().mission_element:event(anim_act, unit)
	end
end

function CopBase:save(data)
	if self._unit:interaction() and self._unit:interaction().tweak_data == "hostage_trade" then
		data.is_hostage_trade = true
	elseif self._unit:interaction() and self._unit:interaction().tweak_data == "hostage_convert" then
		data.is_hostage_convert = true
	end

	data.buffs = {}

	for name, buff_list in pairs(self._buffs) do
		data.buffs[name] = {_total = buff_list._total}
	end
end

function CopBase:load(data)
	if data.is_hostage_trade then
		CopLogicTrade.hostage_trade(self._unit, true, false)
	elseif data.is_hostage_convert then
		self._unit:interaction():set_tweak_data("hostage_convert")
	end

	self._buffs = data.buffs
end

function CopBase:swap_material_config(material_applied_clbk)
	local new_material = self._material_translation_map[self._loading_material_key or tostring(self._unit:material_config():key())]

	if new_material then
		self._loading_material_key = new_material:key()
		self._is_in_original_material = not self._is_in_original_material

		self._unit:set_material_config(new_material, true, material_applied_clbk and callback(self, self, "on_material_applied", material_applied_clbk), 100)

		if not material_applied_clbk then
			self:on_material_applied()
		end
	else
		print("[CopBase:swap_material_config] fail", self._unit:material_config(), self._unit)
		Application:stack_dump()
	end
end

function CopBase:on_material_applied(material_applied_clbk)
	if not alive(self._unit) then
		return
	end

	self._loading_material_key = nil

	if self._unit:interaction() then
		self._unit:interaction():refresh_material()
	end

	if material_applied_clbk then
		material_applied_clbk()
	end
end

function CopBase:is_in_original_material()
	return self._is_in_original_material
end

function CopBase:set_material_state(original)
	if original and not self._is_in_original_material or not original and self._is_in_original_material then
		self:swap_material_config()
	end
end

function CopBase:char_tweak()
	return self._char_tweak
end

function CopBase:melee_weapon()
	return self._melee_weapon_table or self._char_tweak.melee_weapon or "weapon"
end

function CopBase:pre_destroy(unit)
	if alive(self._headwear_unit) then
		self._headwear_unit:set_slot(0)
	end

	unit:brain():pre_destroy(unit)
	self._ext_movement:pre_destroy()
	self._unit:inventory():pre_destroy()
	UnitBase.pre_destroy(self, unit)
end

function CopBase:_refresh_buff_total(name)
	local buff_list = self._buffs[name]
	local sum = 0

	for _, buff in pairs(buff_list.buffs) do
		sum = sum + buff
	end

	buff_list._total = sum

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_enemy_buff", self._unit, name, math.round(buff_list._total * 1000))
	end
end

function CopBase:_sync_buff_total(name, total)
	self._buffs[name] = self._buffs[name] or {}
	self._buffs[name]._total = total * 0.001
end

function CopBase:add_buff(name, value)
	if not Network:is_server() then
		return
	end

	local buff_list = self._buffs[name]

	if not buff_list then
		buff_list = {
			_next_id = 1,
			buffs = {}
		}
		self._buffs[name] = buff_list
	end

	local buff_list = self._buffs[name]
	local id = buff_list._next_id
	buff_list.buffs[id] = value
	buff_list._next_id = id + 1

	self:_refresh_buff_total(name)

	return id
end

function CopBase:remove_buff_by_id(name, id)
	if not Network:is_server() then
		return
	end

	local buff_list = self._buffs[name]

	if not buff_list then
		return
	end

	buff_list.buffs[id] = nil

	self:_refresh_buff_total(name)
end

function CopBase:get_total_buff(name)
	local buff_list = self._buffs[name]

	if not buff_list then
		return 0
	end

	if buff_list and buff_list._total then
		return buff_list._total
	end

	return 0
end

