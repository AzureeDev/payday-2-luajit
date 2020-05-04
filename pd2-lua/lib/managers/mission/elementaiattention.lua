core:import("CoreMissionScriptElement")

ElementAIAttention = ElementAIAttention or class(CoreMissionScriptElement.MissionScriptElement)

function ElementAIAttention:init(...)
	ElementAIAttention.super.init(self, ...)
end

function ElementAIAttention:on_executed(instigator)
	if not self._values.enabled or Network:is_client() then
		return
	end

	if self._values.use_instigator then
		self:_apply_attention_on_unit(instigator, nil)
	elseif self._values.instigator_ids then
		local units = self:_select_units_from_spawners()

		if units then
			for _, unit in ipairs(units) do
				self:_apply_attention_on_unit(unit, nil)
			end
		end
	elseif self._values.att_obj_u_id then
		local unit = self:_fetch_unit_by_unit_id(self._values.att_obj_u_id)

		if unit then
			local handler = unit:attention()

			self:_chk_link_att_object(unit, handler)
			self:_apply_attention_on_unit(unit, handler)
		end
	end

	ElementSpecialObjective.super.on_executed(self, instigator)
end

function ElementAIAttention:operation_remove()
end

function ElementAIAttention:_select_units_from_spawners()
	local candidates = {}

	for _, element_id in ipairs(self._values.instigator_ids) do
		local spawn_element = managers.mission:get_element_by_id(element_id)

		for _, unit in ipairs(spawn_element:units()) do
			if alive(unit) and managers.navigation:check_access(self._values.SO_access, unit:brain():SO_access(), 0) and unit:brain():is_available_for_assignment() then
				table.insert(candidates, unit)
			end
		end
	end

	local wanted_nr_units = nil

	if self._values.trigger_times <= 0 then
		wanted_nr_units = 1
	else
		wanted_nr_units = self._values.trigger_times
	end

	wanted_nr_units = math.min(wanted_nr_units, #candidates)
	local chosen_units = {}

	for i = 1, wanted_nr_units do
		local chosen_unit = table.remove(candidates, math.random(#candidates))

		table.insert(chosen_units, chosen_unit)
	end

	return chosen_units
end

function ElementAIAttention:_get_attention_handler_from_unit(unit)
	return alive(unit) and (unit:movement() and unit:movement():attention_handler() or unit:brain() and unit:brain():attention_handler())
end

function ElementAIAttention:_create_attention_settings()
	local preset = self._values.preset

	if preset == "none" then
		return
	end

	local setting_desc = tweak_data.attention.settings[preset]

	if setting_desc then
		local settings = PlayerMovement._create_attention_setting_from_descriptor(self, setting_desc, preset)

		return settings
	else
		debug_pause("[ElementAIAttention:_get_attention_settings] inexistent preset", preset, "element ID", self._id)
	end
end

function ElementAIAttention:_create_override_attention_settings(unit)
	local preset = self._values.override

	if preset == "none" then
		return
	end

	local setting_desc = tweak_data.attention.settings[preset]

	if setting_desc then
		local clbk_receiver_class = nil

		if unit:base().is_local_player or unit:base().is_husk_player then
			clbk_receiver_class = unit:movement()
		else
			clbk_receiver_class = unit:brain()
		end

		if not clbk_receiver_class then
			debug_pause_unit(unit, "[ElementAIAttention:_create_override_attention_settings] cannot override attention for:", unit)

			return
		end

		local settings = PlayerMovement._create_attention_setting_from_descriptor(clbk_receiver_class, setting_desc, self._values.preset)

		return settings
	else
		debug_pause("[ElementAIAttention:_get_attention_settings] inexistent preset", preset, "element ID", self._id)
	end
end

function ElementAIAttention:_apply_attention_on_unit(unit, handler)
	local handler = handler or self:_get_attention_handler_from_unit(unit)

	if handler then
		if self._values.operation == "add" then
			local settings = self:_create_attention_settings()

			if settings then
				handler:add_attention(settings)
			else
				debug_pause("[ElementAIAttention:_apply_attention_on_unit] inexistent preset", self._values.preset, "element ID", self._id)
			end
		elseif self._values.operation == "set" then
			if self._values.preset == "none" then
				handler:set_attention(nil)
			else
				local settings = self:_create_attention_settings()

				if settings then
					handler:set_attention(settings)
				else
					debug_pause("[ElementAIAttention:_apply_attention_on_unit] inexistent preset", self._values.preset, "element ID", self._id)
				end
			end
		elseif self._values.operation == "override" then
			if self._values.preset == "none" then
				debug_pause("[ElementAIAttention:_apply_attention_on_unit] override operation missing preset param", self._values.preset, self._values.override)
			else
				local settings = self._values.override ~= "none" and self:_create_override_attention_settings(unit)

				handler:override_attention(self._values.preset, settings)
			end
		end
	elseif alive(unit) then
		debug_pause("[ElementAIAttention:_apply_attention_on_unit] unit missing attention handler", instigator, "element ID", self._id)
	end
end

function ElementAIAttention:_chk_link_att_object(unit, handler)
	if not self._values.parent_u_id then
		return
	end

	local parent_unit = self:_fetch_unit_by_unit_id(self._values.parent_u_id)

	if not parent_unit then
		debug_pause("[ElementAIAttention:_chk_link_att_object] could not find parent unit. element ID", self._id)

		return
	end

	handler:link(parent_unit, self._values.parent_obj_name, self._values.local_pos)
end

function ElementAIAttention:_fetch_unit_by_unit_id(unit_id)
	local unit = nil

	if Application:editor() then
		unit = managers.editor:unit_with_id(tonumber(unit_id))
	else
		unit = managers.worlddefinition:get_unit_on_load(tonumber(unit_id), callback(self, self, "_load_unit"))
	end

	return unit
end

function ElementAIAttention._load_unit(unit)
end
