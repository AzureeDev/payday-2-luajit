require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")

CoreLocatorConstraintCutsceneKey = CoreLocatorConstraintCutsceneKey or class(CoreCutsceneKeyBase)
CoreLocatorConstraintCutsceneKey.ELEMENT_NAME = "locator_constraint"
CoreLocatorConstraintCutsceneKey.NAME = "Locator Constraint"

CoreLocatorConstraintCutsceneKey:register_serialized_attribute("locator_name", "")
CoreLocatorConstraintCutsceneKey:register_serialized_attribute("parent_unit_name", "")
CoreLocatorConstraintCutsceneKey:register_serialized_attribute("parent_object_name", "")

CoreLocatorConstraintCutsceneKey.control_for_locator_name = CoreCutsceneKeyBase.standard_combo_box_control
CoreLocatorConstraintCutsceneKey.control_for_parent_unit_name = CoreCutsceneKeyBase.standard_combo_box_control
CoreLocatorConstraintCutsceneKey.control_for_parent_object_name = CoreCutsceneKeyBase.standard_combo_box_control

function CoreLocatorConstraintCutsceneKey:__tostring()
	local attach_point_name = "disabled"

	if self:parent_unit_name() ~= "" and self:parent_object_name() ~= "" then
		attach_point_name = string.format("\"%s/%s\"", self:parent_unit_name(), self:parent_object_name())
	end

	return string.format("Set constaint of locator \"%s\" to %s.", self:locator_name(), attach_point_name)
end

function CoreLocatorConstraintCutsceneKey:can_evaluate_with_player(player)
	return self._cast ~= nil
end

function CoreLocatorConstraintCutsceneKey:evaluate(player, fast_forward)
	local parent_object = self:_unit_object(self:parent_unit_name(), self:parent_object_name(), true)

	self:_constrain_locator_to_object(parent_object)
end

function CoreLocatorConstraintCutsceneKey:revert(player)
	local preceeding_key = self:preceeding_key({
		locator_name = self:locator_name()
	})

	if preceeding_key then
		preceeding_key:evaluate(player, false)
	else
		self:_constrain_locator_to_object(nil)
	end
end

function CoreLocatorConstraintCutsceneKey:update_gui(time, delta_time, player)
	local locator_object = self:_unit_object(self:locator_name(), "locator", true)

	if locator_object then
		local pen = Draw:pen()

		pen:set("no_z")
		pen:set(Color(1, 0.5, 0))
		pen:sphere(locator_object:position(), 1, 5, 1)

		local parent_object = self:_unit_object(self:parent_unit_name(), self:parent_object_name(), true)

		if parent_object then
			pen:set(Color(1, 0, 1))
			pen:line(locator_object:position(), parent_object:position())
			pen:rotation(parent_object:position(), parent_object:rotation(), 10)
			pen:set(Color(0, 1, 1))
			pen:sphere(parent_object:position(), 1, 10, 1)
		end
	end
end

function CoreLocatorConstraintCutsceneKey:is_valid_locator_name(locator_name)
	return string.begins(locator_name, "locator") and self:_unit_type(locator_name) == "locator"
end

function CoreLocatorConstraintCutsceneKey:is_valid_parent_unit_name(unit_name)
	return unit_name == nil or unit_name == "" or CoreCutsceneKeyBase.is_valid_unit_name(self, unit_name)
end

function CoreLocatorConstraintCutsceneKey:is_valid_parent_object_name(object_name)
	return object_name == nil or object_name == "" or CoreCutsceneKeyBase.is_valid_object_name(self, object_name, self:parent_unit_name())
end

function CoreLocatorConstraintCutsceneKey:refresh_control_for_locator_name(control)
	control:freeze()
	control:clear()

	local locator_names = table.find_all_values(self:_unit_names(), function (unit_name)
		return self:is_valid_locator_name(unit_name)
	end)

	for _, locator_name in ipairs(locator_names) do
		control:append(locator_name)
	end

	control:set_enabled(not table.empty(locator_names))
	control:append("")
	control:set_value(self:locator_name())
	control:thaw()
end

function CoreLocatorConstraintCutsceneKey:refresh_control_for_parent_unit_name(control)
	CoreCutsceneKeyBase.refresh_control_for_unit_name(self, control, self:parent_unit_name())
	control:append("")

	if self:parent_unit_name() == "" then
		control:set_value("")
	end
end

function CoreLocatorConstraintCutsceneKey:refresh_control_for_parent_object_name(control)
	CoreCutsceneKeyBase.refresh_control_for_object_name(self, control, self:parent_unit_name(), self:parent_object_name())
	control:append("")

	if self:parent_object_name() == "" then
		control:set_value("")
	end
end

function CoreLocatorConstraintCutsceneKey:on_attribute_before_changed(attribute_name, value, previous_value)
	self:revert(nil)
end

function CoreLocatorConstraintCutsceneKey:on_attribute_changed(attribute_name, value, previous_value)
	self:evaluate(nil)
end

function CoreLocatorConstraintCutsceneKey:_constrain_locator_to_object(parent_object)
	local locator_unit = self:_unit(self:locator_name(), true)

	if locator_unit == nil then
		return
	end

	if parent_object then
		locator_unit:set_animations_enabled(false)

		local locator_object = locator_unit:get_object("locator")
		local position = locator_object:position()
		local rotation = locator_object:rotation()
		local parent_unit = self:_unit(self:parent_unit_name())

		locator_object:set_local_position(Vector3(0, 0, 0))
		locator_object:set_local_rotation(Rotation())
		locator_object:link(parent_object)
		locator_object:set_position(position)
		locator_object:set_rotation(rotation)
		parent_unit:link(locator_unit)
	else
		local locator_object = locator_unit:get_object("locator")

		locator_object:unlink()
		locator_unit:unlink()
		locator_unit:set_animations_enabled(true)
	end
end
