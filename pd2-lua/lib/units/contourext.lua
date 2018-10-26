ContourExt = ContourExt or class()
local idstr_contour = Idstring("contour")
local idstr_material = Idstring("material")
local idstr_contour_color = Idstring("contour_color")
local idstr_contour_opacity = Idstring("contour_opacity")
ContourExt._types = {
	teammate = {
		persistence = 0.3,
		priority = 5,
		ray_check = true
	},
	teammate_downed = {
		priority = 4,
		color = tweak_data.contour.character.downed_color
	},
	teammate_downed_selected = {
		priority = 3,
		color = tweak_data.contour.character_interactable.selected_color
	},
	teammate_dead = {
		priority = 4,
		color = tweak_data.contour.character.dead_color
	},
	teammate_cuffed = {
		priority = 4,
		color = tweak_data.contour.character.downed_color
	},
	friendly = {
		priority = 3,
		material_swap_required = true,
		color = tweak_data.contour.character.friendly_color
	},
	drunk_pilot = {priority = 5},
	boris = {priority = 5},
	taxman = {
		priority = 5,
		color = tweak_data.contour.character_interactable.standard_color
	},
	mark_unit = {
		priority = 4,
		fadeout = 4.5,
		trigger_marked_event = true,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_dangerous = {
		priority = 4,
		fadeout = 9,
		trigger_marked_event = true,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_dangerous_damage_bonus = {
		priority = 4,
		damage_bonus = true,
		fadeout = 9,
		trigger_marked_event = true,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_dangerous_damage_bonus_distance = {
		priority = 4,
		damage_bonus = true,
		fadeout = 9,
		damage_bonus_distance = 1,
		trigger_marked_event = true,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_friendly = {
		priority = 3,
		color = tweak_data.contour.character.friendly_color
	},
	mark_enemy = {
		fadeout = 4.5,
		priority = 5,
		material_swap_required = true,
		fadeout_silent = 13.5,
		trigger_marked_event = true,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_enemy_damage_bonus = {
		fadeout = 4.5,
		priority = 4,
		material_swap_required = true,
		damage_bonus = true,
		fadeout_silent = 13.5,
		trigger_marked_event = true,
		color = tweak_data.contour.character.more_dangerous_color
	},
	mark_enemy_damage_bonus_distance = {
		fadeout = 4.5,
		priority = 4,
		material_swap_required = true,
		damage_bonus = true,
		damage_bonus_distance = 1,
		fadeout_silent = 13.5,
		trigger_marked_event = true,
		color = tweak_data.contour.character.more_dangerous_color
	},
	highlight = {
		priority = 4,
		color = tweak_data.contour.interactable.standard_color
	},
	highlight_character = {
		priority = 6,
		material_swap_required = true,
		color = tweak_data.contour.interactable.standard_color
	},
	generic_interactable = {
		priority = 2,
		material_swap_required = true,
		color = tweak_data.contour.character_interactable.standard_color
	},
	generic_interactable_selected = {
		priority = 1,
		material_swap_required = true,
		color = tweak_data.contour.character_interactable.selected_color
	},
	hostage_trade = {
		priority = 1,
		material_swap_required = true,
		color = tweak_data.contour.character_interactable.standard_color
	},
	deployable_selected = {
		priority = 1,
		unique = true,
		color = tweak_data.contour.deployable.selected_color
	},
	deployable_disabled = {
		priority = 2,
		unique = true,
		color = tweak_data.contour.deployable.disabled_color
	},
	deployable_active = {
		priority = 3,
		unique = true,
		color = tweak_data.contour.deployable.active_color
	},
	deployable_interactable = {
		priority = 4,
		unique = true,
		color = tweak_data.contour.deployable.interact_color
	},
	medic_heal = {
		priority = 1,
		material_swap_required = true,
		fadeout = 2,
		color = tweak_data.contour.character.heal_color
	}
}
ContourExt.indexed_types = {}

for name, preset in pairs(ContourExt._types) do
	table.insert(ContourExt.indexed_types, name)
end

table.sort(ContourExt.indexed_types)

if #ContourExt.indexed_types > 32 then
	Application:error("[ContourExt] max # contour presets exceeded!")
end

ContourExt._MAX_ID = 100000
ContourExt._next_id = 1

function ContourExt:init(unit)
	self._unit = unit

	self._unit:set_extension_update_enabled(idstr_contour, false)

	ContourExt._slotmask_world_geometry = ContourExt._slotmask_world_geometry or managers.slot:get_mask("world_geometry")
	self._contour_list = self._contour_list or {}

	if self.init_contour then
		self:add(self.init_contour, nil, nil)
	end
end

function ContourExt:apply_to_linked(func_name, ...)
	if self._unit.spawn_manager and self._unit:spawn_manager() and self._unit:spawn_manager():linked_units() then
		for unit_id, _ in pairs(self._unit:spawn_manager():linked_units()) do
			local unit_entry = self._unit:spawn_manager():spawned_units()[unit_id]

			if unit_entry and alive(unit_entry.unit) and unit_entry.unit:contour() then
				local contour_ext = unit_entry.unit:contour()

				contour_ext[func_name](contour_ext, ...)
			end
		end
	end
end

function ContourExt:add(type, sync, multiplier)
	if Global.debug_contour_enabled then
		return
	end

	local data = self._types[type]
	local fadeout = data.fadeout

	if data.fadeout_silent and self._unit:base():char_tweak().silent_priority_shout then
		fadeout = data.fadeout_silent
	end

	if multiplier and multiplier > 1 then
		fadeout = fadeout * multiplier
	end

	self._contour_list = self._contour_list or {}

	if sync then
		local u_id = self._unit:id()

		if u_id == -1 then
			u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id
		end

		managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, u_id, table.index_of(ContourExt.indexed_types, type), true, multiplier or 1)
	end

	local should_trigger_marked_event = data.trigger_marked_event

	for _, setup in ipairs(self._contour_list) do
		if setup.type == type then
			if fadeout then
				setup.fadeout_t = TimerManager:game():time() + fadeout
			elseif not self._types[setup.type].unique then
				setup.ref_c = (setup.ref_c or 0) + 1
			end

			return setup
		end

		if self._types[setup.type].trigger_marked_event then
			should_trigger_marked_event = false
		end
	end

	local setup = {
		ref_c = 1,
		type = type,
		fadeout_t = fadeout and TimerManager:game():time() + fadeout or nil,
		sync = sync
	}
	local old_preset_type = self._contour_list[1] and self._contour_list[1].type
	local i = 1

	while self._contour_list[i] and self._types[self._contour_list[i].type].priority <= data.priority do
		i = i + 1
	end

	table.insert(self._contour_list, i, setup)

	if old_preset_type ~= setup.type then
		self:_apply_top_preset()
	end

	if not self._update_enabled then
		self:_chk_update_state()
	end

	self:apply_to_linked("add", type, sync, multiplier)

	if should_trigger_marked_event and self._unit:unit_data().mission_element then
		self._unit:unit_data().mission_element:event("marked", self._unit)
	end

	return setup
end

function ContourExt:change_color(type, color)
	if not self._contour_list then
		return
	end

	for i, setup in ipairs(self._contour_list) do
		if setup.type == type then
			setup.color = color

			self:_upd_color()

			break
		end
	end

	self:apply_to_linked("change_color", type, color)
end

function ContourExt:flash(type_or_id, frequency)
	if not self._contour_list then
		return
	end

	for i, setup in ipairs(self._contour_list) do
		if setup.type == type_or_id or setup == type_or_id then
			setup.flash_frequency = frequency and frequency > 0 and frequency or nil
			setup.flash_t = setup.flash_frequency and TimerManager:game():time() + setup.flash_frequency or nil
			setup.flash_on = nil

			self:_chk_update_state()

			break
		end
	end

	self:apply_to_linked("flash", type_or_id, frequency)
end

function ContourExt:is_flashing()
	if not self._contour_list then
		return
	end

	for i, setup in ipairs(self._contour_list) do
		if setup.flash_frequency then
			return true
		end
	end
end

function ContourExt:remove(type, sync)
	if not self._contour_list then
		return
	end

	local contour_list = clone(self._contour_list)

	for i, setup in ipairs(contour_list) do
		if setup.type == type then
			self:_remove(i, sync)

			if self._update_enabled then
				self:_chk_update_state()
			end

			break
		end
	end

	self:apply_to_linked("remove", type, sync)
end

function ContourExt:remove_by_id(id, sync)
	if not self._contour_list then
		return
	end

	local remove_type = id.type

	for i, setup in ipairs(self._contour_list) do
		if setup == id then
			self:_remove(i, sync)

			if self._update_enabled then
				self:_chk_update_state()
			end

			break
		end
	end

	self:apply_to_linked("remove", remove_type, sync)
end

function ContourExt:has_id(id)
	for i, setup in ipairs(self._contour_list) do
		if setup.type == id then
			return true
		end
	end

	return false
end

function ContourExt:_clear()
	self._contour_list = nil
	self._materials = nil
end

function ContourExt:_remove(index, sync)
	local setup = self._contour_list and self._contour_list[index]

	if not setup then
		return
	end

	local contour_type = setup.type
	local data = self._types[setup.type]

	if setup.ref_c and setup.ref_c > 1 then
		setup.ref_c = setup.ref_c - 1

		return
	end

	if #self._contour_list == 1 then
		managers.occlusion:add_occlusion(self._unit)

		if data.material_swap_required then
			self._unit:base():set_material_state(true)
			self._unit:base():set_allow_invisible(true)
		else
			for _, material in ipairs(self._materials) do
				material:set_variable(idstr_contour_opacity, 0)
			end
		end

		if data.damage_bonus then
			self._unit:character_damage():on_marked_state(false)
		end
	end

	self._last_opacity = nil

	table.remove(self._contour_list, index)

	if #self._contour_list == 0 then
		self:_clear()
	elseif index == 1 then
		self:_apply_top_preset()
	end

	if sync then
		local u_id = self._unit:id()

		if u_id == -1 then
			u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id
		end

		managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, u_id, table.index_of(ContourExt.indexed_types, contour_type), false, 1)
	end

	if data.trigger_marked_event then
		local should_trigger_unmarked_event = true

		for _, setup in ipairs(self._contour_list or {}) do
			if self._types[setup.type].trigger_marked_event then
				should_trigger_unmarked_event = false

				break
			end
		end

		if should_trigger_unmarked_event and self._unit:unit_data().mission_element then
			self._unit:unit_data().mission_element:event("unmarked", self._unit)
		end
	end
end

function ContourExt:update(unit, t, dt)
	local index = 1

	while self._contour_list and index <= #self._contour_list do
		local setup = self._contour_list[index]
		local data = self._types[setup.type]
		local is_current = index == 1

		if data.ray_check and unit:movement() then
			local turn_on = nil

			if is_current then
				local cam_pos = managers.viewport:get_current_camera_position()

				if cam_pos then
					turn_on = mvector3.distance_sq(cam_pos, unit:movement():m_com()) > 16000000
					turn_on = turn_on or unit:raycast("ray", unit:movement():m_com(), cam_pos, "slot_mask", self._slotmask_world_geometry, "report")
				end

				if turn_on then
					self:_upd_opacity(1)

					setup.last_turned_on_t = t
				elseif not setup.last_turned_on_t or data.persistence < t - setup.last_turned_on_t then
					if is_current then
						self:_upd_opacity(0)
					end

					setup.last_turned_on_t = nil
				end
			end
		end

		if setup.flash_t and setup.flash_t < t then
			setup.flash_t = t + setup.flash_frequency
			setup.flash_on = not setup.flash_on

			self:_upd_opacity(setup.flash_on and 1 or 0)
		end

		if setup.fadeout_t and setup.fadeout_t < t then
			self:_remove(index)
			self:_chk_update_state()
		else
			index = index + 1
		end
	end
end

function ContourExt:_upd_opacity(opacity, is_retry)
	if opacity == self._last_opacity then
		return
	end

	if Global.debug_contour_enabled and opacity == 1 then
		return
	end

	self._last_opacity = opacity
	self._materials = self._materials or self._unit:get_objects_by_type(idstr_material)

	for _, material in ipairs(self._materials) do
		if not alive(material) then
			self:update_materials()

			if not is_retry then
				self:_upd_opacity(opacity, true)
			end

			return
		end

		material:set_variable(idstr_contour_opacity, opacity)
	end

	self:apply_to_linked("_upd_opacity", opacity, is_retry)
end

function ContourExt:_upd_color(is_retry)
	if not self._contour_list or #self._contour_list == 0 then
		return
	end

	local color = self._types[self._contour_list[1].type].color or self._contour_list[1].color

	if not color then
		return
	end

	self._materials = self._materials or self._unit:get_objects_by_type(idstr_material)

	for _, material in ipairs(self._materials) do
		if not alive(material) then
			self:update_materials()

			if not is_retry then
				self:_upd_color(true)
			end

			break
		end

		material:set_variable(idstr_contour_color, color)
	end

	self:apply_to_linked("_upd_color", is_retry)
end

function ContourExt:_apply_top_preset()
	local setup = self._contour_list[1]
	local data = self._types[setup.type]
	self._last_opacity = nil

	if data.material_swap_required then
		self._materials = nil
		self._last_opacity = nil

		if self._unit:base():is_in_original_material() then
			self._unit:base():swap_material_config(callback(self, ContourExt, "material_applied", true))
		else
			self:material_applied()
		end
	else
		managers.occlusion:remove_occlusion(self._unit)
		self:material_applied()
	end
end

function ContourExt:material_applied(material_was_swapped)
	if not self._contour_list then
		return
	end

	local setup = self._contour_list[1]
	local data = self._types[setup.type]

	if data.damage_bonus then
		self._unit:character_damage():on_marked_state(true, data.damage_bonus_distance)
	end

	if material_was_swapped then
		managers.occlusion:remove_occlusion(self._unit)
		self._unit:base():set_allow_invisible(false)
		self:update_materials()
	else
		self._materials = nil

		self:_upd_color()

		if not data.ray_check then
			self:_upd_opacity(1)
		end
	end
end

function ContourExt:_chk_update_state()
	local needs_update = nil

	if self._contour_list and next(self._contour_list) then
		for i, setup in ipairs(self._contour_list) do
			if setup.fadeout_t or self._types[setup.type].ray_check or setup.flash_t then
				needs_update = true

				break
			end
		end
	end

	if self._update_enabled ~= needs_update then
		self._update_enabled = needs_update

		self._unit:set_extension_update_enabled(idstr_contour, needs_update and true or false)
	end
end

function ContourExt:update_materials()
	if self._contour_list and next(self._contour_list) then
		self._materials = nil

		self:_upd_color()

		self._last_opacity = nil

		self:_upd_opacity(1)
	end
end

function ContourExt:save(data)
	if self._contour_list then
		for _, setup in ipairs(self._contour_list) do
			if setup.type == "highlight_character" and setup.sync then
				data.highlight_character = setup

				return
			end
		end
	end
end

function ContourExt:load(data)
	if data and data.highlight_character then
		self:add(data.highlight_character.type)
	end
end

