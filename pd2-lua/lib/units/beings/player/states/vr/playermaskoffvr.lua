PlayerMaskOffVR = PlayerMaskOff
local __enter_default = PlayerMaskOff._enter
local __exit_default = PlayerMaskOff.exit
local __check_use_item_default = PlayerMaskOff._check_use_item

function PlayerMaskOffVR:_enter(enter_data)
	__enter_default(self, enter_data)

	local mask_unit_name = nil
	local equipped_mask = managers.blackmarket:equipped_mask()
	local peer_id = managers.network:session():local_peer():id()
	local blueprint = nil
	local mask_id = equipped_mask.mask_id and managers.blackmarket:get_real_mask_id(equipped_mask.mask_id, peer_id)

	if mask_id then
		mask_unit_name = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, peer_id)
		blueprint = equipped_mask.blueprint
	else
		mask_unit_name = tweak_data.blackmarket.masks[equipped_mask.mask_id].unit
	end

	self._mask_unit = World:spawn_unit(Idstring(mask_unit_name), Vector3(0, 0, 0), Rotation(0, 0, 0))
	local glass_id_string = Idstring("glass")
	local mtr_hair_solid_id_string = Idstring("mtr_hair_solid")
	local mtr_hair_effect_id_string = Idstring("mtr_hair_effect")
	local mtr_bloom_glow_id_string = Idstring("mtr_bloom_glow")
	local glow_id_strings = {}

	for i = 1, 5 do
		glow_id_strings[Idstring("glow" .. tostring(i)):key()] = true
	end

	local sweep_id_strings = {}

	for i = 1, 5 do
		sweep_id_strings[Idstring("sweep" .. tostring(i)):key()] = true
	end

	for _, material in ipairs(self._mask_unit:get_objects_by_type(Idstring("material"))) do
		if material:name() == glass_id_string then
			material:set_render_template(Idstring("opacity:CUBE_ENVIRONMENT_MAPPING:CUBE_FRESNEL:DIFFUSE_TEXTURE:FPS"))
		elseif material:name() == mtr_hair_solid_id_string then
			-- Nothing
		elseif material:name() == mtr_hair_effect_id_string then
			-- Nothing
		elseif material:name() == mtr_bloom_glow_id_string then
			material:set_render_template(Idstring("generic:DEPTH_SCALING:DIFFUSE_TEXTURE:SELF_ILLUMINATION:SELF_ILLUMINATION_BLOOM"))
		elseif glow_id_strings[material:name():key()] then
			material:set_render_template(Idstring("effect:BLEND_ADD:DIFFUSE0_TEXTURE"))
		elseif sweep_id_strings[material:name():key()] then
			material:set_render_template(Idstring("effect:BLEND_ADD:DIFFUSE0_TEXTURE:DIFFUSE0_THRESHOLD_SWEEP"))
		else
			material:set_render_template(Idstring("solid_mask:DEPTH_SCALING"))
		end
	end

	if blueprint then
		self._mask_unit:base():apply_blueprint(blueprint)
	end

	self._mask_unit:set_timer(managers.player:player_timer())
	self._mask_unit:set_animation_timer(managers.player:player_timer())
	self._mask_unit:anim_stop()

	if not tweak_data.blackmarket.masks[mask_id].type then
		local backside = World:spawn_unit(Idstring("units/payday2/masks/msk_fps_back_straps/msk_fps_back_straps"), Vector3(0, 0, 0), Rotation(0, 0, 0))

		for _, material in ipairs(backside:get_objects_by_type(Idstring("material"))) do
			material:set_render_template(Idstring("generic:DEPTH_SCALING:DIFFUSE_TEXTURE:NORMALMAP:SKINNED_3WEIGHTS"))
		end

		backside:set_timer(managers.player:player_timer())
		backside:set_animation_timer(managers.player:player_timer())
		self._mask_unit:link(self._mask_unit:orientation_object():name(), backside, backside:orientation_object():name())
	end

	self._unit:hand():link_mask(self._mask_unit)
	managers.hud:belt():set_visible(false)
end

function PlayerMaskOffVR:exit(state_data, new_state_name)
	if alive(self._mask_unit) then
		for _, linked_unit in ipairs(self._mask_unit:children()) do
			linked_unit:unlink()
			World:delete_unit(linked_unit)
		end

		self._unit:hand():unlink_mask(new_state_name)
		World:delete_unit(self._mask_unit)

		self._mask_unit = nil
	end

	managers.hud:belt():set_visible(true)

	local exit_data = __exit_default(self, state_data, new_state_name)

	if self._was_instant then
		exit_data = exit_data or {}
		exit_data.skip_mask_anim = true
		self._was_instant = nil
	end

	return exit_data
end

function PlayerMaskOffVR:_check_use_item(t, input)
	if input.btn_use_item_press then
		local action_forbidden = self._use_item_expire_t or self:_changing_weapon() or self:_interacting()

		if not action_forbidden then
			local mask_hand = self._unit:hand():get_active_hand("mask")

			if mask_hand then
				local hand_pos = mask_hand:position()
				local head_pos = self._unit:movement():m_head_pos()

				if mvector3.distance_sq(hand_pos, head_pos) < 500 then
					self._was_instant = true

					managers.network:session():send_to_peers_synched("sync_teammate_progress", 3, false, "mask_on_action", 0, true)
					PlayerStandard.say_line(self, "a01x_any", true)
					managers.player:set_player_state("standard")
					managers.achievment:award("no_one_cared_who_i_was")

					return
				end
			end
		end
	end

	return __check_use_item_default(self, t, input)
end

local __start_action_state_standard = PlayerMaskOff._start_action_state_standard

function PlayerMaskOffVR:_start_action_state_standard(...)
	managers.hud:link_interaction_hud(self._unit:hand():mask_hand_unit())
	__start_action_state_standard(self, ...)
end

function PlayerMaskOffVR:_can_run()
	return false
end

function PlayerMaskOffVR:_can_jump()
	return false
end

function PlayerMaskOffVR:_can_duck()
	return false
end
