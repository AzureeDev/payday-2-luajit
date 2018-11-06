require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")

CoreUnitCallbackCutsceneKey = CoreUnitCallbackCutsceneKey or class(CoreCutsceneKeyBase)
CoreUnitCallbackCutsceneKey.ELEMENT_NAME = "unit_callback"
CoreUnitCallbackCutsceneKey.NAME = "Unit Callback"

CoreUnitCallbackCutsceneKey:register_serialized_attribute("unit_name", "")
CoreUnitCallbackCutsceneKey:register_serialized_attribute("extension", "")
CoreUnitCallbackCutsceneKey:register_serialized_attribute("method", "")
CoreUnitCallbackCutsceneKey:register_serialized_attribute("enabled", true, toboolean)
CoreUnitCallbackCutsceneKey:register_serialized_attribute("arguments")
CoreUnitCallbackCutsceneKey:attribute_affects("unit_name", "extension")
CoreUnitCallbackCutsceneKey:attribute_affects("extension", "method")
CoreUnitCallbackCutsceneKey:attribute_affects("method", "arguments")

CoreUnitCallbackCutsceneKey.control_for_unit_name = CoreCutsceneKeyBase.standard_combo_box_control
CoreUnitCallbackCutsceneKey.control_for_extension = CoreCutsceneKeyBase.standard_combo_box_control
CoreUnitCallbackCutsceneKey.control_for_method = CoreCutsceneKeyBase.standard_combo_box_control

function CoreUnitCallbackCutsceneKey:__tostring()
	return "Call " .. self:unit_name() .. ":" .. self:extension() .. "():" .. self:method() .. "(" .. self:arguments_string() .. ")"
end

function CoreUnitCallbackCutsceneKey:arguments_string()
	return string.join(", ", table.collect(self._method_params and self._method_params[self:method()] or {}, function (p)
		return p:inspect()
	end))
end

function CoreUnitCallbackCutsceneKey:load(key_node, loading_class)
	self.super.load(self, key_node, loading_class)

	self._method_params = {}
	local params = {}

	for param_node in key_node:children() do
		local param = CoreUnitCallbackCutsceneKeyParam:new()

		param:load(param_node)
		table.insert(params, param)
	end

	if self:is_valid_method(self:method()) then
		self._method_params[self:method()] = params
	end
end

function CoreUnitCallbackCutsceneKey:_save_under(parent_node)
	local key_node = self.super._save_under(self, parent_node)

	for _, param in ipairs(self._method_params and self._method_params[self:method()] or {}) do
		if not param:is_nil() then
			param:_save_under(key_node)
		end
	end

	return key_node
end

function CoreUnitCallbackCutsceneKey:play(player, undo, fast_forward)
	if self:enabled() then
		local method_name = undo and "undo_" .. self:method() or self:method()

		self:_invoke_if_exists(method_name, player)
	end
end

function CoreUnitCallbackCutsceneKey:skip(player)
	if self:enabled() then
		self:_invoke_if_exists("skip_" .. self:method(), player)
	end
end

function CoreUnitCallbackCutsceneKey:is_valid_unit_name(unit_name)
	return self.super.is_valid_unit_name(self, unit_name) and not table.empty(self:_unit_extension_info(unit_name))
end

function CoreUnitCallbackCutsceneKey:is_valid_extension(extension)
	local methods = self:_unit_extension_info(self:unit_name())[extension]

	return methods and not table.empty(methods)
end

function CoreUnitCallbackCutsceneKey:is_valid_method(method)
	return method ~= nil and not string.begins(method, "undo_") and not string.begins(method, "skip_")
end

function CoreUnitCallbackCutsceneKey:refresh_control_for_extension(control)
	control:freeze()
	control:clear()

	local unit_extensions = table.find_all_values(table.map_keys(self:_unit_extension_info(self:unit_name())), function (e)
		return self:is_valid_extension(e)
	end)

	if not table.empty(unit_extensions) then
		control:set_enabled(true)

		local value = self:extension()

		for _, extension in ipairs(unit_extensions) do
			control:append(extension)

			if extension == value then
				control:set_value(value)
			end
		end
	else
		control:set_enabled(false)
	end

	control:thaw()
end

function CoreUnitCallbackCutsceneKey:refresh_control_for_method(control)
	control:freeze()
	control:clear()

	local methods = self:_unit_extension_info(self:unit_name())[self:extension()]

	if methods then
		control:set_enabled(true)

		local value = self:method()

		for _, method in ipairs(table.map_keys(methods)) do
			control:append(method)

			if method == value then
				control:set_value(value)
			end
		end
	else
		control:set_enabled(false)
	end

	control:thaw()
end

function CoreUnitCallbackCutsceneKey:refresh_control_for_arguments(panel)
	panel:freeze()
	panel:destroy_children()

	local panel_sizer = EWS:BoxSizer("VERTICAL")
	local methods = self:_unit_extension_info(self:unit_name())[self:extension()]
	local method_arguments = methods and methods[self:method()] or {}

	if #method_arguments > 0 then
		local headline = EWS:StaticText(panel, "Method Arguments")

		headline:set_font_size(10)
		panel_sizer:add(EWS:StaticLine(panel), 0, 10, "TOP,EXPAND")
		panel_sizer:add(headline, 0, 5, "ALL,EXPAND")
		panel_sizer:add(EWS:StaticLine(panel), 0, 0, "EXPAND")

		for _, argument_name in ipairs(method_arguments) do
			local param = self:_param_with_name(argument_name)
			local value_field = EWS:TextCtrl(panel, "")

			value_field:set_min_size(value_field:get_min_size():with_x(0))
			value_field:connect("EVT_COMMAND_TEXT_UPDATED", function ()
				param.string_value = value_field:get_value()
			end)
			value_field:set_value(param.string_value)
			value_field:set_enabled(param.value_type ~= "nil")

			local type_options = {
				"nil",
				"string",
				"number",
				"bool",
				"unit"
			}
			local type_selector = EWS:ComboBox(panel, "", "", "CB_DROPDOWN,CB_READONLY")

			type_selector:connect("EVT_COMMAND_COMBOBOX_SELECTED", function ()
				param.value_type = type_selector:get_value()

				value_field:set_enabled(param.value_type ~= "nil")
			end)

			for _, option in ipairs(type_options) do
				type_selector:append(option)

				if param.value_type == option then
					type_selector:set_value(option)
				end
			end

			local type_and_value_sizer = EWS:BoxSizer("HORIZONTAL")

			type_and_value_sizer:add(type_selector, 0, 5, "RIGHT,EXPAND")
			type_and_value_sizer:add(value_field, 1, 0, "EXPAND")
			panel_sizer:add(EWS:StaticText(panel, string.pretty(param.name, true) .. ":"), 0, 5, "TOP,LEFT,RIGHT")
			panel_sizer:add(type_and_value_sizer, 0, 5, "ALL,EXPAND")
		end
	end

	panel:set_sizer(panel_sizer)
	panel:thaw()
end

function CoreUnitCallbackCutsceneKey:control_for_arguments(parent_frame, callback_func)
	local panel = EWS:Panel(parent_frame)

	return panel
end

function CoreUnitCallbackCutsceneKey:_invoke_if_exists(method_name, player)
	local extension = self:_unit_extension(self:unit_name(), self:extension(), true)

	if not extension then
		Application:error("Unit \"" .. self:unit_name() .. "\" does not have the extension \"" .. self:extension() .. "\".")

		return
	end

	local func = extension[method_name]

	if not func then
		Application:error(string.pretty(self:extension(), true) .. " extension on unit \"" .. self:unit_name() .. "\" does not support the call \"" .. method_name .. "\".")

		return
	end

	local params = self._method_params and self._method_params[self:method()] or {}
	local param_values = {}

	for index, param in ipairs(params) do
		local value = param:value(self, player)

		if value == nil and not param:is_nil() then
			local parameter_names = string.join(", ", table.collect(params, function (p)
				return p.name
			end))

			Application:error(string.format("Bad argument %s in call to %s:%s():%s(%s)", param:__tostring(), self:unit_name(), self:extension(), method_name, parameter_names))

			return
		else
			param_values[index] = value
		end
	end

	func(extension, table.unpack_sparse(param_values))
end

function CoreUnitCallbackCutsceneKey:_param_with_name(param_name)
	assert(self:is_valid_method(self:method()), "Method \"" .. self:method() .. "\" is invalid.")

	local params = self._method_params and self._method_params[self:method()]

	if params == nil then
		params = {}
		self._method_params = self._method_params or {}
		self._method_params[self:method()] = params
	end

	local param = table.find_value(params, function (p)
		return p.name == param_name
	end)

	if param == nil then
		param = CoreUnitCallbackCutsceneKeyParam.new()
		param.name = param_name

		table.insert(params, param)
	end

	return param
end

CoreUnitCallbackCutsceneKeyParam = CoreUnitCallbackCutsceneKeyParam or class()

function CoreUnitCallbackCutsceneKeyParam:__tostring()
	return tostring(self.name) .. "=" .. tostring(self:inspect())
end

function CoreUnitCallbackCutsceneKeyParam:init()
	self.value_type = "nil"
	self.name = "nil"
	self.string_value = ""
end

function CoreUnitCallbackCutsceneKeyParam:load(param_node)
	self.value_type = param_node:name()
	self.name = param_node:parameter("name")
	self.string_value = param_node:parameter("value")
end

function CoreUnitCallbackCutsceneKeyParam:value(cutscene_key)
	if not self:is_nil() then
		if self.value_type == "string" then
			return self.string_value
		elseif self.value_type == "number" then
			return tonumber(self.string_value)
		elseif self.value_type == "boolean" then
			return toboolean(self.string_value)
		elseif self.value_type == "unit" then
			return cutscene_key and cutscene_key:_unit(self.string_value, true)
		end
	end

	return nil
end

function CoreUnitCallbackCutsceneKeyParam:is_nil()
	return self.value_type == "nil"
end

function CoreUnitCallbackCutsceneKeyParam:inspect()
	return self.string_value
end

function CoreUnitCallbackCutsceneKeyParam:_save_under(parent_node)
	local param_node = parent_node:make_child(self.value_type)

	param_node:set_parameter("name", tostring(self.name))
	param_node:set_parameter("value", self.string_value)

	return param_node
end
