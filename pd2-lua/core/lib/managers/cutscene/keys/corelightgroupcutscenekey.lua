require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")

CoreLightGroupCutsceneKey = CoreLightGroupCutsceneKey or class(CoreCutsceneKeyBase)
CoreLightGroupCutsceneKey.ELEMENT_NAME = "light_group"
CoreLightGroupCutsceneKey.NAME = "Light Group"

CoreLightGroupCutsceneKey:register_serialized_attribute("group", "")
CoreLightGroupCutsceneKey:register_serialized_attribute("enable", false, toboolean)
CoreLightGroupCutsceneKey:attribute_affects("group", "enable")

function CoreLightGroupCutsceneKey:__tostring()
	return string.format("Change light group, %s stateto %s.", self:group(), tostring(self:enable()))
end

function CoreLightGroupCutsceneKey:prime()
	self:_build_group_cache()
end

function CoreLightGroupCutsceneKey:evaluate()
	local group = assert(self:_light_groups()[self:group()], "Could not find group!")

	for _, unit in ipairs(group) do
		self:_enable_lights(unit, self:enable())
	end
end

function CoreLightGroupCutsceneKey:revert()
	local prev_key = self:preceeding_key({
		group = self:group()
	})

	if prev_key then
		prev_key:evaluate()
	else
		local group = assert(self:_light_groups()[self:group()], "Could not find group!")

		for _, unit in ipairs(group) do
			self:_enable_lights(unit, false)
		end
	end
end

function CoreLightGroupCutsceneKey:unload()
	for group_name, group in pairs(self:_light_groups()) do
		for _, unit in ipairs(group) do
			self:_enable_lights(unit, false)
		end
	end
end

function CoreLightGroupCutsceneKey:can_evaluate_with_player(player)
	return true
end

function CoreLightGroupCutsceneKey:is_valid_group(name)
	for group_name, _ in pairs(self:_light_groups()) do
		if group_name == name then
			return true
		end
	end
end

function CoreLightGroupCutsceneKey:is_valid_enable()
	return true
end

function CoreLightGroupCutsceneKey:on_attribute_changed(attribute_name, value, previous_value)
	if attribute_name == "group" or attribute_name == "enable" and not value then
		self:_eval_prev_group()
	end
end

function CoreLightGroupCutsceneKey:_light_groups()
	if not self._light_groups_cache then
		self:_build_group_cache()
	end

	return self._light_groups_cache
end

function CoreLightGroupCutsceneKey:_enable_lights(unit, enabled)
	local lights = unit:get_objects_by_type("light")

	if #lights == 0 then
		Application:stack_dump_error("[CoreLightGroupCutsceneKey] No lights in unit: " .. unit:name())
	end

	for _, light in ipairs(lights) do
		light:set_enable(enabled)
	end
end

function CoreLightGroupCutsceneKey:_build_group_cache()
	self._light_groups_cache = {}

	for key, unit in pairs(managers.cutscene:cutscene_actors_in_world()) do
		local identifier, name, id = string.match(key, "(.+)_(.+)_(.+)")

		if identifier == "lightgroup" then
			if not self._light_groups_cache[name] then
				self._light_groups_cache[name] = {}
			end

			table.insert(self._light_groups_cache[name], unit)
			self:_enable_lights(unit, false)
		end
	end
end

function CoreLightGroupCutsceneKey:_eval_prev_group()
	local prev_key = self:preceeding_key({
		group = self:group()
	})

	if prev_key then
		prev_key:evaluate()
	else
		self:evaluate()
	end
end

function CoreLightGroupCutsceneKey:refresh_control_for_group(control)
	control:freeze()
	control:clear()

	local value = self:group()

	for group_name, _ in pairs(self:_light_groups()) do
		control:append(group_name)

		if group_name == value then
			control:set_value(group_name)
		end
	end

	control:thaw()
end

function CoreLightGroupCutsceneKey:check_box_control(parent_frame, callback_func)
	local control = EWS:CheckBox(parent_frame, "Enable", "", "")

	control:set_min_size(control:get_min_size():with_x(0))
	control:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback_func)

	return control
end

function CoreLightGroupCutsceneKey:refresh_control_for_enable(control)
	control:set_value(self:enable())
end

CoreLightGroupCutsceneKey.control_for_group = CoreCutsceneKeyBase.standard_combo_box_control
CoreLightGroupCutsceneKey.control_for_enable = CoreLightGroupCutsceneKey.check_box_control
