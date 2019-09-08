CoreCutsceneKeyBase = CoreCutsceneKeyBase or class()

function CoreCutsceneKeyBase:init(key_collection)
	self:set_key_collection(key_collection)
end

function CoreCutsceneKeyBase:load(key_node, loading_class)
	loading_class = loading_class or self

	if loading_class.super and loading_class.super.load then
		loading_class.super.load(self, key_node, loading_class.super)
	end

	if loading_class == CoreCutsceneKeyBase and key_node:parameter("frame") then
		self:set_frame(tonumber(key_node:parameter("frame")))
	end

	for attribute, transform_func in pairs(loading_class.__serialized_attributes or {}) do
		local string_value = key_node:parameter(attribute)

		if string_value then
			self["__" .. attribute] = transform_func(string_value)
		end
	end
end

function CoreCutsceneKeyBase:populate_from_editor(cutscene_editor)
	self:set_frame(cutscene_editor:playhead_position())
end

function CoreCutsceneKeyBase:set_key_collection(key_collection)
	self.__key_collection = key_collection
end

function CoreCutsceneKeyBase:set_cast(cast)
	self._cast = cast
end

function CoreCutsceneKeyBase:clone()
	return clone(self)
end

function CoreCutsceneKeyBase:prime(player)
end

function CoreCutsceneKeyBase:unload(player)
end

function CoreCutsceneKeyBase:type_name()
	return self.NAME or "Unknown"
end

function CoreCutsceneKeyBase:_key_collection()
	return self.__key_collection
end

function CoreCutsceneKeyBase:frame()
	return self._frame or 0
end

function CoreCutsceneKeyBase:set_frame(frame)
	self._frame = frame
end

function CoreCutsceneKeyBase:time()
	return self:frame() / 30
end

function CoreCutsceneKeyBase:preceeding_key(properties)
	return self:_key_collection() and self:_key_collection():last_key_before(self:time(), self.ELEMENT_NAME, properties)
end

function CoreCutsceneKeyBase:can_evaluate_with_player(player)
	return player ~= nil
end

function CoreCutsceneKeyBase:is_valid(debug_output)
	for _, attribute_name in ipairs(self:attribute_names()) do
		if not self:is_valid_attribute_value(attribute_name, self:attribute_value(attribute_name)) then
			if debug_output then
				Application:error("Attribute \"" .. attribute_name .. "\" is invalid.")
			end

			return false
		end
	end

	return true
end

function CoreCutsceneKeyBase:is_valid_attribute_value(attribute_name, value)
	local validator_func = self["is_valid_" .. attribute_name]

	return validator_func == nil or validator_func(self, value)
end

function CoreCutsceneKeyBase:is_valid_object_name(object_name, unit_name)
	return object_name and table.contains(self:_unit_object_names(unit_name or self:unit_name()), object_name) or false
end

function CoreCutsceneKeyBase:is_valid_unit_name(unit_name)
	return table.contains(self:_unit_names(), unit_name)
end

function CoreCutsceneKeyBase:_unit_names()
	local unit_names = self._cast and self._cast:unit_names() or {}

	for unit_name, _ in pairs(managers.cutscene and managers.cutscene:cutscene_actors_in_world() or {}) do
		table.insert(unit_names, unit_name)
	end

	table.sort(unit_names)

	return unit_names
end

function CoreCutsceneKeyBase:_unit_type(unit_name)
	local unit = self:_unit(unit_name, true)

	return unit and unit:name()
end

function CoreCutsceneKeyBase:_unit_object_names(unit_name)
	local unit_type_info = managers.cutscene:actor_database():unit_type_info(self:_unit_type(unit_name))

	return unit_type_info and unit_type_info:object_names() or {}
end

function CoreCutsceneKeyBase:_unit_initial_object_visibility(unit_name, object_name)
	local unit_type_info = managers.cutscene:actor_database():unit_type_info(self:_unit_type(unit_name))

	return unit_type_info and unit_type_info:initial_object_visibility(object_name)
end

function CoreCutsceneKeyBase:_unit_extension_info(unit_name)
	local unit_type_info = managers.cutscene:actor_database():unit_type_info(self:_unit_type(unit_name))

	return unit_type_info and unit_type_info:extensions() or {}
end

function CoreCutsceneKeyBase:_unit_animation_groups(unit_name)
	local unit_type_info = managers.cutscene:actor_database():unit_type_info(self:_unit_type(unit_name))

	return unit_type_info and unit_type_info:animation_groups() or {}
end

function CoreCutsceneKeyBase:_unit(unit_name, allow_nil)
	local unit = self._cast and self._cast:unit(unit_name)

	if unit == nil and managers.cutscene then
		unit = managers.cutscene:cutscene_actors_in_world()[unit_name]
	end

	assert(allow_nil or unit, "Unit \"" .. (unit_name or "nil") .. "\" not found in cast or world.")

	return unit
end

function CoreCutsceneKeyBase:_unit_object(unit_name, object_name, allow_nil)
	local unit = self:_unit(unit_name, allow_nil)
	local object = unit and unit:get_object(object_name)

	assert(allow_nil or object, "Object \"" .. (object_name or "nil") .. "\" not found in unit \"" .. (unit_name or "nil") .. "\".")

	return object
end

function CoreCutsceneKeyBase:_unit_extension(unit_name, extension_name, allow_nil)
	local unit = self:_unit(unit_name, allow_nil)
	local extension_func = unit and unit[extension_name]
	local extension = type(extension_func) == "function" and extension_func(unit) or nil

	assert(allow_nil or extension, "Extension \"" .. (extension_name or "nil") .. "\" not found in unit \"" .. (unit_name or "nil") .. "\".")

	return extension
end

function CoreCutsceneKeyBase:_unit_is_owned_by_level(unit_name)
	return managers.cutscene and managers.cutscene:cutscene_actors_in_world()[unit_name] ~= nil
end

function CoreCutsceneKeyBase:play(player, undo, fast_forward)
	assert(type(self.evaluate) == "function", "Cutscene key must define the \"evaluate\" method to use the default CoreCutsceneKeyBase:play method.")

	if undo then
		if type(self.revert) == "function" then
			self:revert(player)
		else
			local preceeding_key = self:preceeding_key({
				unit_name = self.unit_name and self:unit_name(),
				object_name = self.object_name and self:object_name()
			})

			if preceeding_key then
				preceeding_key:evaluate(player, false)
			end
		end
	else
		self:evaluate(player, fast_forward)
	end
end

function CoreCutsceneKeyBase:_save_under(parent_node)
	local element_name = assert(self.ELEMENT_NAME, "Required string member ELEMENT_NAME not declared in cutscene key class.")
	local key_node = parent_node:make_child(element_name)

	key_node:set_parameter("frame", tostring(self:frame()))

	local exclude_defaults = true

	for _, attribute_name in ipairs(self:attribute_names(exclude_defaults)) do
		key_node:set_parameter(attribute_name, tostring(self:attribute_value(attribute_name)))
	end

	return key_node
end

function CoreCutsceneKeyBase:attribute_names(exclude_defaults, _class, _destination)
	_class = _class or getmetatable(self)
	_destination = _destination or {}

	if _class.super then
		CoreCutsceneKeyBase.attribute_names(self, exclude_defaults, _class.super, _destination)
	end

	for _, attribute_name in ipairs(_class.__serialized_attribute_order or {}) do
		if not exclude_defaults or self["__" .. attribute_name] ~= nil then
			table.insert(_destination, attribute_name)
		end
	end

	return _destination
end

function CoreCutsceneKeyBase:attribute_value(attribute_name)
	return self[attribute_name] and self[attribute_name](self)
end

function CoreCutsceneKeyBase:attribute_value_from_string(attribute_name, string_value)
	if string_value == "" then
		return nil
	else
		local transform_func = self.__serialized_attributes[attribute_name]

		return transform_func(string_value)
	end
end

function CoreCutsceneKeyBase:set_attribute_value_from_string(attribute_name, string_value)
	local value = self:attribute_value_from_string(attribute_name, string_value)

	return self["set_" .. attribute_name](self, value)
end

function CoreCutsceneKeyBase:register_control(control_name)
	self:register_serialized_attribute(control_name, nil, nil)
end

function CoreCutsceneKeyBase:register_serialized_attribute(attribute_name, default, transform_func)
	local class_table = self
	class_table.__serialized_attributes = class_table.__serialized_attributes or {}
	class_table.__serialized_attributes[attribute_name] = transform_func or tostring
	class_table.__serialized_attribute_order = class_table.__serialized_attribute_order or {}

	if not table.contains(class_table.__serialized_attribute_order, attribute_name) then
		table.insert(class_table.__serialized_attribute_order, attribute_name)
	end

	class_table[attribute_name] = function (instance)
		local value = instance["__" .. attribute_name]

		return value == nil and default or value
	end

	class_table["set_" .. attribute_name] = function (instance, value)
		local previous_value = instance["__" .. attribute_name]

		if instance.on_attribute_before_changed then
			instance:on_attribute_before_changed(attribute_name, value, previous_value)
		end

		if instance["is_valid_" .. attribute_name] and not instance["is_valid_" .. attribute_name](instance, value, previous_value) then
			return false
		else
			instance["__" .. attribute_name] = iff(value == default, nil, value)

			if instance.on_attribute_changed then
				instance:on_attribute_changed(attribute_name, value, previous_value)
			end

			return true
		end
	end
end

function CoreCutsceneKeyBase:attribute_affects(changed, ...)
	local class_table = self
	class_table.__control_dependencies = class_table.__control_dependencies or {}
	local affected_attribute_names = table.list_union(class_table.__control_dependencies[changed] or {}, {
		...
	})
	class_table.__control_dependencies[changed] = affected_attribute_names
end

function CoreCutsceneKeyBase:populate_sizer_with_editable_attributes(grid_sizer, parent_frame)
	for _, attribute_name in ipairs(self:attribute_names()) do
		local control = nil

		local function on_control_edited()
			local value_is_valid = self:validate_control_for_attribute(attribute_name)

			if value_is_valid then
				local value = control:get_value()
				value = value == nil and "" or tostring(value)

				self:set_attribute_value_from_string(attribute_name, value)
				self:refresh_controls_dependent_on(attribute_name)
				parent_frame:fit_inside()
			end
		end

		control = self:control_for_attribute(attribute_name, parent_frame, on_control_edited)
		self.__controls = self.__controls or {}
		self.__controls[attribute_name] = control

		self:refresh_control_for_attribute(attribute_name)

		local control_type = type_name(control)

		if control_type == "EWSPanel" then
			grid_sizer:add(control, 1, 0, "EXPAND")
		else
			if not table.contains({
				"EWSCheckBox",
				"EWSButton",
				"EWSBitmapButton",
				"EWSStaticLine"
			}, control_type) then
				local label = self:attribute_label(attribute_name)

				if label then
					grid_sizer:add(EWS:StaticText(parent_frame, label .. ":"), 0, 5, "TOP,LEFT,RIGHT")
				end
			end

			grid_sizer:add(control_type == "table" and control.panel and control:panel() or control, 0, 5, "ALL,EXPAND")
		end
	end
end

function CoreCutsceneKeyBase:attribute_label(attribute_name)
	if self["label_for_" .. attribute_name] then
		return self["label_for_" .. attribute_name](self)
	else
		return string.pretty(attribute_name, true)
	end
end

function CoreCutsceneKeyBase:attribute_is_boolean(attribute_name)
	return self:attribute_value_from_string(attribute_name, "true") == true and self:attribute_value_from_string(attribute_name, "false") == false
end

function CoreCutsceneKeyBase:control_for_attribute(attribute_name, parent_frame, callback_func)
	if self["control_for_" .. attribute_name] then
		return self["control_for_" .. attribute_name](self, parent_frame, callback_func)
	elseif self:attribute_is_boolean(attribute_name) then
		local control = EWS:CheckBox(parent_frame, self:attribute_label(attribute_name))

		control:set_min_size(control:get_min_size():with_x(0))
		control:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback_func)

		return control
	else
		local control = EWS:TextCtrl(parent_frame, "")

		control:set_min_size(control:get_min_size():with_x(0))
		control:connect("EVT_COMMAND_TEXT_UPDATED", callback_func)

		return control
	end
end

function CoreCutsceneKeyBase:refresh_control_for_attribute(attribute_name)
	local control = self.__controls and self.__controls[attribute_name]

	if control and (control.alive == nil or alive(control)) then
		if self["refresh_control_for_" .. attribute_name] then
			self["refresh_control_for_" .. attribute_name](self, control)
		elseif self:attribute_is_boolean(attribute_name) then
			control:set_value(self:attribute_value(attribute_name))
		elseif control.change_value ~= nil then
			local value = self:attribute_value(attribute_name)

			if type(value) == "number" then
				value = string.format("%g", value)
			end

			control:change_value(tostring(value == nil and "" or value))
		end

		self:validate_control_for_attribute(attribute_name)
	elseif self.__controls then
		self.__controls[attribute_name] = nil
	end
end

function CoreCutsceneKeyBase:refresh_controls_dependent_on(attribute_name, refreshed_controls)
	refreshed_controls = refreshed_controls or {}

	if refreshed_controls[attribute_name] == nil then
		for _, dependant_attribute_name in ipairs(self.__control_dependencies and self.__control_dependencies[attribute_name] or {}) do
			self:refresh_control_for_attribute(dependant_attribute_name)

			refreshed_controls[dependant_attribute_name] = true

			self:refresh_controls_dependent_on(dependant_attribute_name, refreshed_controls)
		end
	end
end

function CoreCutsceneKeyBase:validate_control_for_attribute(attribute_name)
	local control = self.__controls and self.__controls[attribute_name]

	if control == nil then
		return false
	elseif table.contains({
		"EWSPanel",
		"EWSCheckBox",
		"EWSRadioButton",
		"EWSSlider",
		"EWSButton",
		"EWSBitmapButton",
		"EWSStaticLine",
		"EWSColorWell"
	}, type_name(control)) then
		return true
	end

	local value_is_valid = self:is_valid_attribute_value(attribute_name, self:attribute_value_from_string(attribute_name, control:get_value()))
	local colour = value_is_valid and EWS:get_system_colour("WINDOW") or Color("ff9999")

	control:set_background_colour((colour * 255):unpack())

	if type_name(control) ~= "table" then
		control:refresh()
		control:update()
	end

	return value_is_valid
end

function CoreCutsceneKeyBase:standard_divider_control(parent_frame)
	local control = EWS:StaticLine(parent_frame)

	control:set_min_size(control:get_min_size():with_x(0))

	return control
end

function CoreCutsceneKeyBase:standard_combo_box_control(parent_frame, callback_func)
	local control = EWS:ComboBox(parent_frame, "", "", "CB_DROPDOWN,CB_READONLY,CB_SORT")

	control:set_min_size(control:get_min_size():with_x(0))
	control:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback_func)

	return control
end

function CoreCutsceneKeyBase:standard_combo_box_control_refresh(attribute_name, values)
	local function refresh_func(self, control)
		control:freeze()
		control:clear()

		local attribute_value = self:attribute_value(attribute_name)

		for _, entry in ipairs(values) do
			local value = tostring(entry)

			control:append(value)

			if value == attribute_value then
				control:set_value(value)
			end
		end

		control:thaw()
	end

	return refresh_func
end

function CoreCutsceneKeyBase:standard_percentage_slider_control(parent_frame, callback_func)
	local control = EWS:Slider(parent_frame, 0, 0, 100, "", "SL_AUTOTICKS")

	control:set_tick_freq(50)
	control:connect("EVT_SCROLL_CHANGED", callback_func)
	control:connect("EVT_SCROLL_THUMBTRACK", callback_func)

	return control
end

function CoreCutsceneKeyBase:standard_percentage_slider_control_refresh(attribute_name)
	local function refresh_func(self, control)
		local attribute_value = self:attribute_value(attribute_name)

		control:set_value(math.clamp(attribute_value * 100, 0, 100))
	end

	return refresh_func
end

CoreCutsceneKeyBase.control_for_unit_name = CoreCutsceneKeyBase.standard_combo_box_control
CoreCutsceneKeyBase.control_for_object_name = CoreCutsceneKeyBase.standard_combo_box_control

function CoreCutsceneKeyBase:refresh_control_for_unit_name(control, selected_unit_name)
	control:freeze()
	control:clear()

	local unit_names = self:_unit_names()

	if table.empty(unit_names) then
		control:set_enabled(false)
	else
		control:set_enabled(true)

		local value = selected_unit_name or self:unit_name()

		for _, unit_name in pairs(unit_names) do
			if self:is_valid_unit_name(unit_name) then
				control:append(unit_name)

				if unit_name == value then
					control:set_value(value)
				end
			end
		end
	end

	control:thaw()
end

function CoreCutsceneKeyBase:refresh_control_for_object_name(control, unit_name, selected_object_name)
	control:freeze()
	control:clear()

	local object_names = self:_unit_object_names(unit_name or self:unit_name())

	if #object_names == 0 then
		control:set_enabled(false)
	else
		control:set_enabled(true)

		local value = selected_object_name or self:object_name()

		for _, object_name in ipairs(object_names) do
			if self:is_valid_object_name(object_name, unit_name) then
				control:append(object_name)

				if object_name == value then
					control:set_value(value)
				end
			end
		end
	end

	control:thaw()
end

function CoreCutsceneKeyBase:on_gui_representation_changed(sender, sequencer_clip)
	self:set_frame(sequencer_clip:start_time())
end

function CoreCutsceneKeyBase:VOID()
	return nil
end

function CoreCutsceneKeyBase:TRUE()
	return true
end

function CoreCutsceneKeyBase.string_to_vector(string_value)
	local xyz_strings = {
		string.match(string_value, "Vector3%((%-?[%d%.]+), (%-?[%d%.]+), (%-?[%d%.]+)%)")
	}
	local xyz_numbers = table.collect(xyz_strings, tonumber)

	return #xyz_numbers == 3 and Vector3(unpack(xyz_numbers)) or nil
end

function CoreCutsceneKeyBase.string_to_rotation(string_value)
	local xyz_strings = {
		string.match(string_value, "Rotation%((%-?[%d%.]+), (%-?[%d%.]+), (%-?[%d%.]+)%)")
	}
	local xyz_numbers = table.collect(xyz_strings, tonumber)

	return #xyz_numbers == 3 and Rotation(unpack(xyz_numbers)) or nil
end

function CoreCutsceneKeyBase.string_to_color(string_value)
	local argb_strings = {
		string.match(string_value, "Color%(([%d%.]+) %* %(([%d%.]+), ([%d%.]+), ([%d%.]+)%)%)")
	}
	local argb_numbers = table.collect(argb_strings, tonumber)

	return #argb_numbers == 4 and Color(unpack(argb_numbers)) or nil
end

CoreCutsceneKeyBase:attribute_affects("unit_name", "object_name")
