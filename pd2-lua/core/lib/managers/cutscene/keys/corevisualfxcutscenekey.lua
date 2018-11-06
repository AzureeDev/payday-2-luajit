require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")
core:import("CoreEngineAccess")

CoreVisualFXCutsceneKey = CoreVisualFXCutsceneKey or class(CoreCutsceneKeyBase)
CoreVisualFXCutsceneKey.ELEMENT_NAME = "visual_fx"
CoreVisualFXCutsceneKey.NAME = "Visual Effect"

CoreVisualFXCutsceneKey:register_serialized_attribute("unit_name", "")
CoreVisualFXCutsceneKey:register_serialized_attribute("object_name", "")
CoreVisualFXCutsceneKey:register_serialized_attribute("effect", "")
CoreVisualFXCutsceneKey:register_serialized_attribute("duration", nil, tonumber)
CoreVisualFXCutsceneKey:register_serialized_attribute("offset", Vector3(0, 0, 0), CoreCutsceneKeyBase.string_to_vector)
CoreVisualFXCutsceneKey:register_serialized_attribute("rotation", Rotation(), CoreCutsceneKeyBase.string_to_rotation)
CoreVisualFXCutsceneKey:register_serialized_attribute("force_synch", false, toboolean)

CoreVisualFXCutsceneKey.control_for_effect = CoreCutsceneKeyBase.standard_combo_box_control

function CoreVisualFXCutsceneKey:__tostring()
	return "Trigger visual effect \"" .. self:effect() .. "\" on \"" .. self:object_name() .. " in " .. self:unit_name() .. "\"."
end

function CoreVisualFXCutsceneKey:can_evaluate_with_player(player)
	return true
end

function CoreVisualFXCutsceneKey:prime(player)
end

function CoreVisualFXCutsceneKey:unload(player)
	self:stop()
end

function CoreVisualFXCutsceneKey:play(player, undo, fast_forward)
	if undo then
		self:stop()
	elseif not fast_forward then
		self:stop()
		self:prime(player)

		local effect_manager = World:effect_manager()
		local parent_object = self:_unit_object(self:unit_name(), self:object_name(), true)
		local effect_id = effect_manager:spawn({
			effect = self:effect(),
			parent = parent_object,
			position = self:offset(),
			rotation = self:rotation(),
			force_synch = self:force_synch()
		})

		function self._effect_abort_func()
			effect_manager:kill(effect_id)
		end
	end
end

function CoreVisualFXCutsceneKey:update(player, time)
	if self:duration() and self:duration() < time then
		self:stop()
	end
end

function CoreVisualFXCutsceneKey:is_valid_unit_name(value)
	return value == nil or value == "" or CoreCutsceneKeyBase.is_valid_unit_name(self, value)
end

function CoreVisualFXCutsceneKey:is_valid_object_name(value)
	return value == nil or value == "" or table.contains(self:_unit_object_names(self:unit_name()), value) or false
end

function CoreVisualFXCutsceneKey:is_valid_effect(effect)
	return DB:has("effect", effect)
end

function CoreVisualFXCutsceneKey:is_valid_duration(value)
	return value == nil or value > 0
end

function CoreVisualFXCutsceneKey:is_valid_offset(value)
	return value ~= nil
end

function CoreVisualFXCutsceneKey:is_valid_rotation(value)
	return value ~= nil
end

function CoreVisualFXCutsceneKey:refresh_control_for_unit_name(control)
	self.super.refresh_control_for_unit_name(self, control, self:unit_name())
	control:append("")

	if self:unit_name() == "" then
		control:set_value("")
	end
end

function CoreVisualFXCutsceneKey:refresh_control_for_object_name(control)
	self.super.refresh_control_for_object_name(self, control, self:unit_name(), self:object_name())
	control:append("")

	if self:object_name() == "" or not self:is_valid_object_name(self:object_name()) then
		self:set_object_name("")
		control:set_value("")
	end

	control:set_enabled(self:unit_name() ~= "")
end

function CoreVisualFXCutsceneKey:refresh_control_for_effect(control)
	control:freeze()
	control:clear()

	local value = self:effect()

	for _, name in ipairs(managers.database:list_entries_of_type("effect")) do
		control:append(name)

		if name == value then
			control:set_value(value)
		end
	end

	control:thaw()
end

function CoreVisualFXCutsceneKey:on_attribute_before_changed(attribute_name, value, previous_value)
	self:stop()
end

function CoreVisualFXCutsceneKey:stop()
	if self._effect_abort_func then
		self._effect_abort_func()

		self._effect_abort_func = nil
	end
end
