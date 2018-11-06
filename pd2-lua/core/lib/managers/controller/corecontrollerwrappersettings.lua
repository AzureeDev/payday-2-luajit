core:module("CoreControllerWrapperSettings")

ControllerWrapperSettings = ControllerWrapperSettings or class()

function ControllerWrapperSettings:init(wrapper_type, node, core_setting, debug_path)
	self._wrapper_type = wrapper_type
	self._connection_list = {}
	self._connection_map = {}
	self._editable_connection_map = {}
	self._unselectable_input_map = {}

	if node then
		for _, setting_node in ipairs(node) do
			local element_name = setting_node._meta

			if element_name == "connections" then
				for _, connection_node in ipairs(setting_node) do
					local element_name = connection_node._meta
					local name = connection_node.name

					if not name then
						Application:error(self:get_origin(debug_path) .. " controller \"" .. tostring(element_name) .. "\" input had no name attribute.")
					elseif element_name == "button" then
						if self._connection_map[name] then
							Application:error(self:get_origin(debug_path) .. " Duplicate controller button connection (name: \"" .. tostring(name) .. "\"). Overwriting existing one.")
						end

						self:set_connection(name, ControllerWrapperButton:new(connection_node))
					elseif element_name == "axis" then
						if self._connection_map[name] then
							Application:error(self:get_origin(debug_path) .. " Duplicate controller axis connection (name: \"" .. tostring(name) .. "\"). Overwriting existing one.")
						end

						self:set_connection(name, ControllerWrapperAxis:new(connection_node))
					else
						Application:error(self:get_origin(debug_path) .. " Invalid element \"" .. tostring(element_name) .. "\" inside \"connections\" element.")
					end
				end
			elseif element_name == "editable" then
				for _, editable_node in ipairs(setting_node) do
					local element_name = editable_node._meta

					if element_name == ControllerWrapperEditable.TYPE then
						local name = editable_node.name

						if not name then
							Application:error(self:get_origin(debug_path) .. " Editable input element had no name attribute.")
						else
							if self._editable_connection_map[name] then
								Application:error(self:get_origin(debug_path) .. " Duplicate controller editable connection (name: \"" .. tostring(name) .. "\"). Overwriting existing one.")
							end

							self:set_editable_connection(name, ControllerWrapperEditable:new(editable_node))
						end
					else
						Application:error(self:get_origin(debug_path) .. " Invalid element \"" .. tostring(element_name) .. "\" inside \"editable\" element.")
					end
				end
			elseif element_name == "unselectable" then
				for _, unselectable_node in ipairs(setting_node) do
					local element_name = unselectable_node._meta

					if element_name == ControllerWrapperUnselectable.TYPE then
						local input_name = unselectable_node.name

						if not input_name then
							Application:error(self:get_origin(debug_path) .. " Unselectable input element had no name attribute.")
						else
							if self._unselectable_input_map[input_name] then
								Application:error(self:get_origin(debug_path) .. " Duplicate controller unselectable connection (name: \"" .. tostring(input_name) .. "\"). Overwriting existing one.")
							end

							self:set_unselectable_input(input_name, ControllerWrapperUnselectable:new(unselectable_node))
						end
					else
						Application:error(self:get_origin(debug_path) .. " Invalid element \"" .. tostring(element_name) .. "\" inside \"unselectable\" element.")
					end
				end
			else
				Application:error(self:get_origin(debug_path) .. " Invalid element \"" .. tostring(name) .. "\" inside \"" .. tostring(self._wrapper_type) .. "\" element.")
			end
		end
	end

	if core_setting then
		self:merge(core_setting, false)
	end

	self:validate()
end

function ControllerWrapperSettings:merge(setting, overwrite)
	for name, connection in pairs(setting:get_connection_map()) do
		if overwrite or not self._connection_map[name] then
			self:set_connection(name, connection)
		end
	end

	for name, editable_connection in pairs(setting:get_editable_connection_map()) do
		if overwrite or not self._editable_connection_map[name] then
			self._editable_connection_map[name] = editable_connection
		end
	end

	for name, unselectable_input in pairs(setting:get_unselectable_input_map()) do
		if overwrite or not self._unselectable_input_map[name] then
			self._unselectable_input_map[name] = unselectable_input
		end
	end
end

function ControllerWrapperSettings:validate()
	for connection_name, editable_connection in pairs(self._editable_connection_map) do
		local connection = self._connection_map[connection_name]

		if not connection then
			self._editable_connection_map[connection_name] = nil

			Application:error(tostring(editable_connection) .. " Connection \"" .. tostring(connection_name) .. "\" that was supposed to be editable did not exist. It is no longer editable.")
		else
			local input_name_list = connection:get_input_name_list()

			for _, input_name in ipairs(input_name_list) do
				local unselectable_input = self._unselectable_input_map[input_name]

				if unselectable_input then
					local invalid = nil

					if #input_name_list > 1 and not connection:get_any_input() then
						invalid = unselectable_input:get_multi()
					else
						invalid = unselectable_input:get_single()
					end

					if invalid then
						self._editable_connection_map[connection_name] = nil

						Application:error(tostring(unselectable_input) .. " Connection \"" .. tostring(connection_name) .. "\" was editable but its input \"" .. tostring(input_name) .. "\" is unselectable. It is no longer editable.")
					end
				end
			end
		end
	end
end

function ControllerWrapperSettings:populate_data(data)
	local sub_data = {}
	local connection_list = nil

	for _, connection in pairs(self._connection_map) do
		if not connection_list then
			connection_list = {
				_meta = "connections"
			}

			table.insert(sub_data, connection_list)
		end

		connection:populate_data(connection_list)
	end

	local editable_list = nil

	for _, editable in pairs(self._editable_connection_map) do
		if not editable_list then
			editable_list = {
				_meta = "editable"
			}

			table.insert(sub_data, editable_list)
		end

		editable:populate_data(editable_list)
	end

	local unselectable_list = nil

	for _, unselectable in pairs(self._unselectable_input_map) do
		if not unselectable_list then
			unselectable_list = {
				_meta = "unselectable"
			}

			table.insert(sub_data, unselectable_list)
		end

		unselectable:populate_data(unselectable_list)
	end

	data[self._wrapper_type] = sub_data
end

function ControllerWrapperSettings:wrapper_type()
	return self._wrapper_type
end

function ControllerWrapperSettings:get_connection_list()
	return self._connection_list
end

function ControllerWrapperSettings:get_connection_map()
	return self._connection_map
end

function ControllerWrapperSettings:get_connection(name)
	return self._connection_map[name]
end

function ControllerWrapperSettings:set_connection(name, connection)
	self._connection_map[name] = connection

	table.insert(self._connection_list, name)
end

function ControllerWrapperSettings:get_editable_connection_map()
	return self._editable_connection_map
end

function ControllerWrapperSettings:get_editable_connection(name)
	return self._editable_connection_map[name]
end

function ControllerWrapperSettings:set_editable_connection(name, editable)
	self._editable_connection_map[name] = editable
end

function ControllerWrapperSettings:get_unselectable_input_map()
	return self._unselectable_input_map
end

function ControllerWrapperSettings:get_unselectable_input(input_name)
	return self._unselectable_input_map[input_name]
end

function ControllerWrapperSettings:set_unselectable_input(input_name, unselectable)
	self._unselectable_input_map[input_name] = unselectable
end

function ControllerWrapperSettings:get_origin(debug_path)
	if debug_path then
		return string.format("[Controller][File: %s]", tostring(debug_path))
	else
		return "[Controller]"
	end
end

ControllerWrapperConnection = ControllerWrapperConnection or class()
ControllerWrapperConnection.TYPE = "generic"
ControllerWrapperConnection.DEFAULT_MIN_SRC_RANGE = 0
ControllerWrapperConnection.DEFAULT_MAX_SRC_RANGE = 1
ControllerWrapperConnection.DEFAULT_MIN_DEST_RANGE = 0
ControllerWrapperConnection.DEFAULT_MAX_DEST_RANGE = 1
ControllerWrapperConnection.DEFAULT_CONNECT_SRC_TYPE = "button"
ControllerWrapperConnection.DEFAULT_CONNECT_DEST_TYPE = "button"

function ControllerWrapperConnection:init(node)
	if node then
		self._name = node.name
		local input_name = nil
		local attribute = "input"
		local count = 1

		repeat
			input_name = node[attribute]

			if input_name then
				self._input_name_list = self._input_name_list or {}

				table.insert(self._input_name_list, input_name)

				count = count + 1
				attribute = "input" .. count
			end
		until not input_name

		self._controller_id = node.controller

		if node.debug == true then
			self._debug = true
		end

		if node.enabled == false then
			self._disabled = true
		end

		if node.any_input == false then
			self._single_input = true
		end

		if node.unique == true then
			self._unique = true
		end

		self._delay = tonumber(node.delay)
		self._min_src_range = tonumber(node.min_src_range)
		self._max_src_range = tonumber(node.max_src_range)
		self._min_dest_range = tonumber(node.min_dest_range)
		self._max_dest_range = tonumber(node.max_dest_range)

		for _, child in ipairs(node) do
			local child_name = child._meta

			if child_name == ControllerWrapperDelayConnection.TYPE then
				local delay_connection = ControllerWrapperDelayConnection:new(child)
				self._delay_connection_list = self._delay_connection_list or {}

				table.insert(self._delay_connection_list, delay_connection)
			end
		end
	end
end

function ControllerWrapperConnection:set_name(name)
	self._name = name
end

function ControllerWrapperConnection:get_name()
	return self._name
end

function ControllerWrapperConnection:set_input_name_list(input_name_list)
	if input_name_list and next(input_name_list) then
		self._input_name_list = input_name_list
	else
		self._input_name_list = nil
	end
end

function ControllerWrapperConnection:get_input_name_list()
	return self._input_name_list or {}
end

function ControllerWrapperConnection:get_controller_id()
	return self._controller_id
end

function ControllerWrapperConnection:set_controller_id(controller_id)
	self._controller_id = controller_id
end

function ControllerWrapperConnection:set_debug(debug)
	if debug then
		self._debug = true
	else
		self._debug = nil
	end
end

function ControllerWrapperConnection:get_debug()
	return self._debug
end

function ControllerWrapperConnection:set_enabled(enabled)
	if not enabled then
		self._disabled = true
	else
		self._disabled = nil
	end
end

function ControllerWrapperConnection:get_enabled()
	return not self._disabled
end

function ControllerWrapperConnection:set_any_input(any_input)
	if not any_input then
		self._single_input = true
	else
		self._single_input = nil
	end
end

function ControllerWrapperConnection:get_any_input()
	return not self._single_input
end

function ControllerWrapperConnection:set_delay(delay)
	if self._delay ~= 0 then
		self._delay = delay
	else
		self._delay = nil
	end
end

function ControllerWrapperConnection:get_delay()
	return self._delay or 0
end

function ControllerWrapperConnection:set_delay_connection_list(delay_connection_list)
	if self._delay_connection_list and next(self._delay_connection_list) then
		self._delay_connection_list = delay_connection_list
	else
		self._delay_connection_list = nil
	end
end

function ControllerWrapperConnection:get_delay_connection_list()
	return self._delay_connection_list or {}
end

function ControllerWrapperConnection:set_range(min_src, max_src, min_dest, max_dest)
	if min_src ~= self.DEFAULT_MIN_SRC_RANGE then
		self._min_src_range = min_src
	else
		self._min_src_range = nil
	end

	if max_src ~= self.DEFAULT_MAX_SRC_RANGE then
		self._max_src_range = max_src
	else
		self._max_src_range = nil
	end

	if min_dest ~= self.DEFAULT_MIN_DEST_RANGE then
		self._min_dest_range = min_dest
	else
		self._min_dest_range = nil
	end

	if max_dest ~= self.DEFAULT_MAX_DEST_RANGE then
		self._max_dest_range = max_dest
	else
		self._max_dest_range = nil
	end
end

function ControllerWrapperConnection:get_range()
	return self._min_src_range or self.DEFAULT_MIN_SRC_RANGE, self._max_src_range or self.DEFAULT_MAX_SRC_RANGE, self._min_dest_range or self.DEFAULT_MIN_DEST_RANGE, self._max_dest_range or self.DEFAULT_MAX_DEST_RANGE
end

function ControllerWrapperConnection:set_connect_src_type(connect_src_type)
	if self._connect_src_type ~= self.DEFAULT_CONNECT_SRC_TYPE then
		self._connect_src_type = connect_src_type
	else
		self._connect_src_type = nil
	end
end

function ControllerWrapperConnection:get_connect_src_type()
	return self._connect_src_type or self.DEFAULT_CONNECT_SRC_TYPE
end

function ControllerWrapperConnection:set_connect_dest_type(connect_dest_type)
	if self._connect_dest_type ~= self.DEFAULT_CONNECT_DEST_TYPE then
		self._connect_dest_type = connect_dest_type
	else
		self._connect_dest_type = nil
	end
end

function ControllerWrapperConnection:get_connect_dest_type()
	return self._connect_dest_type or self.DEFAULT_CONNECT_DEST_TYPE
end

function ControllerWrapperConnection:populate_data(data)
	local sub_data = {
		_meta = self.TYPE
	}

	self:populate_data_attributes(sub_data)

	if self._delay_connection_list then
		for _, delay_connection in ipairs(self._delay_connection_list) do
			delay_connection:populate_data(sub_data)
		end
	end

	table.insert(data, sub_data)
end

function ControllerWrapperConnection:populate_data_attributes(sub_data)
	sub_data.name = self._name
	sub_data.controller = self._controller_id
	sub_data.delay = self._delay
	sub_data.min_src_range = self._min_src_range
	sub_data.max_src_range = self._max_src_range
	sub_data.min_dest_range = self._min_dest_range
	sub_data.max_dest_range = self._max_dest_range
	sub_data.connect_src_type = self._connect_src_type
	sub_data.connect_dest_type = self._connect_dest_type

	if self._debug then
		sub_data.debug = true
	end

	if self._disabled then
		sub_data.enabled = false
	end

	if self._single_input then
		sub_data.any_input = false
	end

	if self._input_name_list then
		for index, input_name in ipairs(self._input_name_list) do
			local attribute = "input"

			if index > 1 then
				attribute = attribute .. index
			end

			sub_data[attribute] = input_name
		end
	end
end

function ControllerWrapperConnection:get_unique()
	return self._unique
end

function ControllerWrapperConnection:__tostring(additional_info)
	return string.format("[Controller][Connection][Type: %s, Name: %s, Input: %s, Controller: %s, Debug: %s, Enabled: %s, Any input: %s, Delay: %s%s]", tostring(self.TYPE), tostring(self._name), self._input_name_list and table.concat_map(self._input_name_list, true, "N/A") or "", tostring(self._controller_id), tostring(self._debug), tostring(not self._disabled), tostring(not self._single_input), tostring(self._delay), tostring(additional_info or ""))
end

ControllerWrapperButton = ControllerWrapperButton or class(ControllerWrapperConnection)
ControllerWrapperButton.TYPE = "button"

function ControllerWrapperButton:init(node)
	ControllerWrapperButton.super.init(self, node)
end

function ControllerWrapperButton:__tostring(additional_info)
	return ControllerWrapperConnection.__tostring(self, additional_info)
end

ControllerWrapperAxis = ControllerWrapperAxis or class(ControllerWrapperConnection)
ControllerWrapperAxis.TYPE = "axis"
ControllerWrapperAxis.IS_AXIS = true
ControllerWrapperAxis.DEFAULT_MIN_SRC_RANGE = -1
ControllerWrapperAxis.DEFAULT_MAX_SRC_RANGE = 1
ControllerWrapperAxis.DEFAULT_MIN_DEST_RANGE = -1
ControllerWrapperAxis.DEFAULT_MAX_DEST_RANGE = 1
ControllerWrapperAxis.DEFAULT_CONNECT_SRC_TYPE = "axis"
ControllerWrapperAxis.DEFAULT_CONNECT_DEST_TYPE = "axis"
ControllerWrapperAxis.ONE_VECTOR = Vector3(1, 1, 1)

function ControllerWrapperAxis:init(node)
	ControllerWrapperAxis.super.init(self, node)

	self._multiplier = self.ONE_VECTOR
	self._inversion = self.ONE_VECTOR
	self._inversion_unmodified = self.ONE_VECTOR
	self._INVERSION_MODIFIER = self.ONE_VECTOR

	if node then
		local multiplier = node.multiplier

		if multiplier and multiplier.type_name == Vector3.type_name then
			self:set_multiplier(multiplier)
		end

		self:set_lerp(tonumber(node.lerp))

		local init_lerp_axis = node.init_lerp_axis

		if init_lerp_axis and init_lerp_axis.type_name == Vector3.type_name then
			self:set_init_lerp_axis(init_lerp_axis)
		end

		self:set_pad_bottom(tonumber(node.pad_bottom))
		self:set_pad_top(tonumber(node.pad_top))
		self:set_soft_top(tonumber(node.soft_top))

		if node.no_limit == true then
			self._no_limit = true
		end

		local inversion_modifier = node.inversion_modifier

		if inversion_modifier and inversion_modifier.type_name == Vector3.type_name then
			self._INVERSION_MODIFIER = inversion_modifier

			self:set_inversion()
		end

		local inversion = node.inversion

		if inversion and inversion.type_name == Vector3.type_name then
			self:set_inversion(inversion)
		end
	end

	if node then
		self._btn_connections = {}

		self:read_axis_btns(node)
	end
end

function ControllerWrapperAxis:read_axis_btns(node)
	for _, child in ipairs(node) do
		local child_name = child._meta

		if (child_name == "button" or child_name == "axis") and child.name and child.input then
			self._btn_connections[child.name] = {
				type = child_name,
				name = child.input
			}

			if child.dir then
				self._btn_connections[child.name].dir = child.dir
			end

			if child.range1 then
				self._btn_connections[child.name].range1 = child.range1
			end

			if child.range2 then
				self._btn_connections[child.name].range2 = child.range2
			end
		end
	end
end

function ControllerWrapperAxis:print_output(output, indent)
	output:print(string.rep("\t", indent) .. "<" .. self.TYPE .. self:get_output_attributes() .. "")

	if self:has_children() then
		output:puts(">")
		self:print_output_children(output, indent + 1)
		output:puts(string.rep("\t", indent) .. "</" .. self.TYPE .. ">")
	elseif self._btn_connections then
		output:puts(">")
		self:print_output_axis_btns(output, indent + 1)
		output:puts(string.rep("\t", indent) .. "</" .. self.TYPE .. ">")
	else
		output:puts("/>")
	end
end

function ControllerWrapperAxis:print_output_axis_btns(output, indent)
	for btn, con in pairs(self._btn_connections) do
		if con.type == "button" then
			output:puts(string.rep("\t", indent) .. string.format("<%s name=\"%s\" input=\"%s\"/>", con.type, btn, con.name))
		elseif con.type == "axis" then
			output:puts(string.rep("\t", indent) .. string.format("<%s name=\"%s\" input=\"%s\" dir=\"%s\" range1=\"%s\" range2=\"%s\"/>", con.type, btn, con.name, con.dir, con.range1, con.range2))
		end
	end
end

function ControllerWrapperAxis:set_multiplier(multiplier)
	self._multiplier = multiplier or self.ONE_VECTOR
end

function ControllerWrapperAxis:get_multiplier()
	return self._multiplier
end

function ControllerWrapperAxis:set_lerp(lerp)
	self._lerp = lerp and math.clamp(lerp, 0, 1)
end

function ControllerWrapperAxis:get_lerp()
	return self._lerp
end

function ControllerWrapperAxis:set_init_lerp_axis(init_lerp_axis)
	self._init_lerp_axis = init_lerp_axis
end

function ControllerWrapperAxis:get_init_lerp_axis()
	return self._init_lerp_axis
end

function ControllerWrapperAxis:set_pad_bottom(pad_bottom)
	self._pad_bottom = pad_bottom and math.clamp(pad_bottom, 0, 1)
end

function ControllerWrapperAxis:get_pad_bottom()
	return self._pad_bottom
end

function ControllerWrapperAxis:set_pad_top(pad_top)
	self._pad_top = pad_top and math.clamp(pad_top, 0, 1)
end

function ControllerWrapperAxis:get_pad_top()
	return self._pad_top
end

function ControllerWrapperAxis:set_soft_top(soft_top)
	self._soft_top = soft_top and math.clamp(soft_top, 0, 1)
end

function ControllerWrapperAxis:get_soft_top()
	return self._soft_top
end

function ControllerWrapperAxis:set_no_limit(no_limit)
	if no_limit then
		self._no_limit = true
	else
		self._no_limit = nil
	end
end

function ControllerWrapperAxis:get_no_limit()
	return self._no_limit
end

function ControllerWrapperAxis:set_inversion(inversion)
	self._inversion_unmodified = inversion or self.ONE_VECTOR
	self._inversion = Vector3(self._inversion_unmodified.x * self._INVERSION_MODIFIER.x, self._inversion_unmodified.y * self._INVERSION_MODIFIER.y, self._inversion_unmodified.z * self._INVERSION_MODIFIER.z)
end

function ControllerWrapperAxis:get_inversion_unmodified()
	return self._inversion_unmodified
end

function ControllerWrapperAxis:get_inversion()
	return self._inversion
end

function ControllerWrapperAxis:get_output_attributes()
	local additional_attributes = ""

	if self._multiplier and (self._multiplier.x ~= 1 or self._multiplier.y ~= 1 or self._multiplier.z ~= 1) then
		additional_attributes = additional_attributes .. string.format(" multiplier=\"%g %g %g\"", self._multiplier.x, self._multiplier.y, self._multiplier.z)
	end

	if self._lerp then
		additional_attributes = additional_attributes .. string.format(" lerp=\"%g\"", self._lerp)

		if self._init_lerp_axis and (self._init_lerp_axis.x ~= 1 or self._init_lerp_axis.y ~= 1 or self._init_lerp_axis.z ~= 1) then
			additional_attributes = additional_attributes .. string.format(" init_lerp_axis=\"%g %g %g\"", self._init_lerp_axis.x, self._init_lerp_axis.y, self._init_lerp_axis.z)
		end
	end

	if self._pad_bottom and self._pad_bottom ~= 0 then
		additional_attributes = additional_attributes .. string.format(" pad_bottom=\"%g\"", self._pad_bottom)
	end

	if self._pad_top and self._pad_top ~= 0 then
		additional_attributes = additional_attributes .. string.format(" pad_top=\"%g\"", self._pad_top)
	end

	if self._soft_top and self._soft_top ~= 0 then
		additional_attributes = additional_attributes .. string.format(" soft_top=\"%g\"", self._soft_top)
	end

	if self._no_limit then
		additional_attributes = additional_attributes .. string.format(" no_limit=\"%s\"", tostring(not not self._no_limit))
	end

	if self._inversion and (self._inversion.x ~= 1 or self._inversion.y ~= 1 or self._inversion.z ~= 1) then
		additional_attributes = additional_attributes .. string.format(" inversion=\"%g %g %g\"", self._inversion.x, self._inversion.y, self._inversion.z)
	end

	return ControllerWrapperConnection.get_output_attributes(self) .. additional_attributes
end

function ControllerWrapperAxis:__tostring(additional_info)
	return ControllerWrapperConnection.__tostring(self, tostring(additional_info or "") .. ", Multiplier: " .. tostring(self._multiplier) .. ", Lerp: " .. tostring(self._lerp) .. ", Initial lerp axis: " .. tostring(self._init_lerp_axis) .. ", Pad bottom: " .. tostring(self._pad_bottom) .. ", Pad top: " .. tostring(self._pad_top) .. ", Soft top: " .. tostring(self._soft_top) .. ", No limit: " .. tostring(self._no_limit) .. ", Inversion: " .. tostring(self._inversion))
end

ControllerWrapperDelayConnection = ControllerWrapperDelayConnection or class()
ControllerWrapperDelayConnection.TYPE = "delay"

function ControllerWrapperDelayConnection:init(node)
	if node then
		self._name = node.name
	end
end

function ControllerWrapperDelayConnection:set_name(name)
	self._name = name
end

function ControllerWrapperDelayConnection:get_name()
	return self._name
end

function ControllerWrapperDelayConnection:populate_data(data)
	local list = data.connections
	local sub_data = {
		_meta = self.TYPE
	}

	if not list then
		list = {}
		data.connections = list
	end

	sub_data.name = self._name

	table.insert(list, sub_data)
end

function ControllerWrapperDelayConnection:__tostring(additional_info)
	return string.format("[Controller][DelayConnection][Name: %s%s]", tostring(self._name), tostring(additional_info))
end

ControllerWrapperEditable = ControllerWrapperEditable or class()
ControllerWrapperEditable.TYPE = "connection"

function ControllerWrapperEditable:init(node)
	self._connection_name = node.name
	self._caption = node.caption or self._connection_name
	self._locale_id = node.locale_id
end

function ControllerWrapperEditable:get_connection_name()
	return self._connection_name
end

function ControllerWrapperEditable:set_connection_name(connection_name)
	self._connection_name = connection_name
end

function ControllerWrapperEditable:get_caption()
	return self._caption
end

function ControllerWrapperEditable:set_caption(caption)
	self._caption = caption or self._connection_name
end

function ControllerWrapperEditable:get_locale_id()
	return self._locale_id
end

function ControllerWrapperEditable:set_locale_id(locale_id)
	self._locale_id = locale_id
end

function ControllerWrapperEditable:populate_data(data)
	local sub_data = {
		_meta = self.TYPE,
		name = self._connection_name,
		caption = self._caption,
		locale_id = self._locale_id
	}

	table.insert(data, sub_data)
end

function ControllerWrapperEditable:__tostring(additional_info)
	return string.format("[Editable connection name: %s, Caption: %s, Locale id: %s]", tostring(self._connection_name), tostring(self._caption), tostring(self._locale_id))
end

ControllerWrapperUnselectable = ControllerWrapperUnselectable or class()
ControllerWrapperUnselectable.TYPE = "input"

function ControllerWrapperUnselectable:init(node)
	self._input_name = node.name

	if node.single ~= false then
		self._single = true
	end

	if node.multi ~= false then
		self._multi = true
	end
end

function ControllerWrapperUnselectable:get_input_name()
	return self._input_name
end

function ControllerWrapperUnselectable:set_input_name(input_name)
	self._input_name = input_name
end

function ControllerWrapperUnselectable:get_single()
	return self._single
end

function ControllerWrapperUnselectable:set_single(single)
	if single then
		self._single = true
	else
		self._single = nil
	end
end

function ControllerWrapperUnselectable:get_multi()
	return self._multi
end

function ControllerWrapperUnselectable:set_multi(multi)
	if multi then
		self._multi = true
	else
		self._multi = nil
	end
end

function ControllerWrapperUnselectable:populate_data(data)
	local sub_data = {
		_meta = self.TYPE,
		name = self._input_name
	}

	if not self._single then
		sub_data.single = not not self._single
	end

	if not self._multi then
		sub_data.multi = not not self._sing_multile
	end

	table.insert(data, sub_data)
end

function ControllerWrapperUnselectable:__tostring(additional_info)
	return string.format("[Unselectable input name: \"%s\"]", tostring(self._input_name))
end
