CoreAiArea = CoreAiArea or class()

function CoreAiArea:init(unit, surface_name, obj_name, xml)
	self._unit = unit
	self._spawn_point_index = 1
	self._obj = self._unit:get_object(Idstring(obj_name))
	self._nav = Search:nav(surface_name .. obj_name)

	self._nav:set_reference_object(self._obj)

	self._spawn_points = {}

	self:find_spawnpoints(xml)
end

function CoreAiArea:spawn(unit_name, spawn_point_name)
	local spawn_point = nil

	if spawn_point_name ~= "" then
		spawn_point = self._unit:get_object(Idstring(spawn_point_name))
	else
		if self._spawn_point_index > #self._spawn_points then
			return
		end

		spawn_point = self._spawn_points[self._spawn_point_index]
		self._spawn_point_index = self._spawn_point_index + 1
	end

	local ray = World:raycast("ray", spawn_point:position() + spawn_point:rotation():z() * 100, spawn_point:position() - spawn_point:rotation():z() * 500, "slot_mask", managers.slot:get_mask("statics"))

	if ray then
		local unit = safe_spawn_unit(unit_name, ray.position)

		if unit:base() ~= nil and unit:base().link ~= nil then
			unit:base():link(self._unit, self._obj, self._nav)
		end

		return unit
	end
end

function CoreAiArea:find_spawnpoints(xml)
	for point in xml:children() do
		if point:name() == "ai_spawn_point" and point:parameter("name") ~= "" then
			local object = self._unit:get_object(Idstring(point:parameter("name")))

			if object ~= nil then
				cat_print("spawn_system", "[" .. self._unit:name() .. "] AI spawn point found: " .. point:parameter("name"))
				table.insert(self._spawn_points, object)
			end
		end
	end
end

CoreSpawnSystem = CoreSpawnSystem or class()

function CoreSpawnSystem:init(unit)
	self._unit = unit
	self._post_init = false
	self._ai_surface_name = "surface_generic_spawner_"
	self._ai_spawn_areas = {}

	self:read_spawn_xml()
end

function CoreSpawnSystem:get_linked_unit_list()
	local linked_unit_list = {}

	if self._linked_unit_map then
		for _, unit_map in pairs(self._linked_unit_map) do
			for _, unit in pairs(unit_map) do
				table.insert(linked_unit_list, unit)
			end
		end
	end

	return linked_unit_list
end

function CoreSpawnSystem:destroy()
	if self._linked_unit_map then
		for _, unit_map in pairs(self._linked_unit_map) do
			for _, unit in pairs(unit_map) do
				if alive(unit) then
					cat_print("spawn_system", "[CoreSpawnSystem] Destroy unit: " .. unit:name())
					unit:set_slot(0)
				end
			end
		end
	end
end

function CoreSpawnSystem:update(unit, t, dt)
	if self._delayed_var_and_cb_init then
		for lv2, unit in pairs(self._delayed_var_and_cb_init) do
			self:set_var_and_cb(unit, lv2)
		end

		self._delayed_var_and_cb_init = nil
	end

	self._unit:set_extension_update_enabled("spawn_system", false)

	self._post_init = true
end

function CoreSpawnSystem:get_child_unit(socket_name, unit_name)
	if self._linked_unit_map then
		local unit_map = self._linked_unit_map[socket_name]

		if unit_map then
			return unit_map[unit_name]
		end
	end

	return nil
end

function CoreSpawnSystem:init_ai_area(name, xml)
	local object = self._unit:get_object(Idstring(name))

	if not self._ai_spawn_areas[object:name()] then
		self._ai_spawn_areas[object:name()] = CoreAiArea:new(self._unit, self._ai_surface_name, object:name(), xml)
	end
end

function CoreSpawnSystem:find_spawn_node(xml)
	for spawn_node in xml:children() do
		if spawn_node:name() == "spawn" then
			cat_print("spawn_system", "[CoreSpawnSystem] Found spawn node on: " .. self._unit:name())

			return spawn_node
		end
	end

	Application:error("[CoreSpawnSystem] Could not find spawn node on: " .. self._unit:name())
end

function CoreSpawnSystem:set_var_and_cb_delayed(new_unit, lv2)
	if not self._post_init then
		self._delayed_var_and_cb_init = self._delayed_var_and_cb_init or {}
		self._delayed_var_and_cb_init[lv2] = new_unit
	else
		self:set_var_and_cb(new_unit, lv2)
	end
end

function CoreSpawnSystem:set_var_and_cb(new_unit, lv2)
	for lv3 in lv2:children() do
		if lv3:name() == "variables" and lv3:parameter("extension") ~= "" then
			cat_print("spawn_system", "Found variable block for: " .. lv3:parameter("extension"))

			for lv4 in lv3:children() do
				if lv4:name() == "var" and lv4:parameter("name") ~= "" and lv4:parameter("val") ~= "" then
					cat_print("spawn_system", "Set variable: " .. lv4:parameter("name") .. "='" .. tostring(lv4:parameter("val") .. "'"))

					local meta = getmetatable(new_unit)
					local func = meta[lv3:parameter("extension")](new_unit)
					func[lv4:parameter("name")] = lv4:parameter("val")
				end
			end
		end
	end

	for lv3 in lv2:children() do
		local lv3_name = lv3:parameter("name")

		if lv3:name() == "callback" and lv3_name ~= "" and lv3:parameter("extension") ~= "" then
			cat_print("spawn_system", "Building callback '" .. lv3_name .. "' in extension '" .. lv3:parameter("extension") .. "'.")

			local function_arg = {}

			for num_arg = 1, table.size(lv3:parameter_map()) - 2 do
				local key = "param" .. tostring(num_arg)

				if lv3:parameter(key) ~= "" then
					cat_print("spawn_system", "Found parameter: " .. key .. "=\"" .. tostring(lv3:parameter(key)) .. "\"")
					table.insert(function_arg, lv3:parameter(key))
				end
			end

			cat_print("spawn_system", "Call callback!")

			local meta = getmetatable(new_unit)
			local func = meta[lv3:parameter("extension")](new_unit)

			func[lv3_name](new_unit:base(), unpack(function_arg))
		end
	end
end

function CoreSpawnSystem:read_spawn_xml()
	local xml_data = self:find_spawn_node(PackageManager:unit_data(self._unit:name():id()):model_script_data())

	if xml_data then
		for lv1 in xml_data:children() do
			local lv1_element_name = lv1:name()
			local lv1_name = lv1:parameter("name")

			if lv1_element_name == "ai_area" and lv1_name ~= "" then
				cat_print("spawn_system", "[CoreSpawnSystem] AI area defined: " .. lv1_name)
				self:init_ai_area(lv1_name, lv1)

				for lv2 in lv1:children() do
					local lv2_name = lv2:parameter("name")

					if lv2:name() == "unit" and lv2_name ~= "" then
						cat_print("spawn_system", "[CoreSpawnSystem] Spawning unit: " .. lv2_name)

						local new_unit = self._ai_spawn_areas[lv1_name]:spawn(lv2_name, lv2:parameter("spawn_point"))
						self._linked_unit_map = self._linked_unit_map or {}
						local unit_map = self._linked_unit_map[lv1_name] or {}
						unit_map[lv2_name] = new_unit
						self._linked_unit_map[lv1_name] = unit_map

						self:set_var_and_cb_delayed(new_unit, lv2)
					end
				end
			end

			if lv1_element_name == "socket" and lv1_name ~= "" then
				for lv2 in lv1:children() do
					if lv2:name() == "unit" then
						self._enabled_unit_map = self._enabled_unit_map or {}
						local unit_map = self._enabled_unit_map[lv1_name] or {}
						local enabled = lv2:parameter("enabled") ~= "false"
						unit_map[lv2:parameter("name")] = enabled
						self._enabled_unit_map[lv1_name] = unit_map

						if enabled then
							self:setup_unit(lv1, lv2)
						end
					end
				end
			end
		end
	end

	if not self._delayed_var_and_cb_init then
		self._unit:set_extension_update_enabled("spawn_system", false)

		self._post_init = true
	end
end

function CoreSpawnSystem:setup_unit(lv1, lv2)
	local lv1_name = lv1:parameter("name")
	local lv2_name = lv2:parameter("name")

	cat_print("spawn_system", "[CoreSpawnSystem] Spawn unit '" .. lv2_name .. "' in socket '" .. lv1_name .. "'.")

	local new_unit = nil
	local object = self._unit:get_object(Idstring(lv1_name))

	if MassUnitManager:can_spawn_unit(lv2_name) then
		cat_print("spawn_system", "Spawning mass unit!")

		new_unit = MassUnitManager:spawn_unit(lv2_name, object:position(), object:rotation())
	else
		new_unit = safe_spawn_unit(lv2_name:id(), object:position(), object:rotation())
	end

	self._linked_unit_map = self._linked_unit_map or {}
	local unit_map = self._linked_unit_map[lv1_name] or {}
	unit_map[lv2_name] = new_unit
	self._linked_unit_map[lv1_name] = unit_map

	if lv2:parameter("link_object") ~= "" then
		if new_unit:base() and new_unit:base().link then
			new_unit:base():link(self._unit, lv1_name, lv2:parameter("link_object"))

			if new_unit:base().link_object then
				for lv3 in lv2:children() do
					if lv3:name() == "object" and lv3:parameter("name") ~= "" and lv3:parameter("socket") ~= "" then
						new_unit:base():link_object(self._unit, lv3:parameter("socket"), lv3:parameter("name"))
					end
				end
			end
		else
			self._unit:link(lv1_name, new_unit, lv2:parameter("link_object"))

			for lv3 in lv2:children() do
				local lv3_name = lv3:parameter("name")

				if lv3:name() == "object" and lv3:parameter("name") ~= "" and lv3:parameter("socket") ~= "" then
					local socket_object = self._unit:get_object(Idstring(lv3:parameter("socket")))

					new_unit:get_object(Idstring(lv3_name)):link(socket_object)
					new_unit:get_object(Idstring(lv3_name)):set_local_position(Vector3())
					new_unit:get_object(Idstring(lv3_name)):set_local_rotation(Rotation())
				end
			end
		end
	else
		cat_print("spawn_system", "Spawning only! (No linking.)")
	end

	self._linked_unit_map = self._linked_unit_map or {}
	local unit_map = self._linked_unit_map[lv1_name] or {}
	unit_map[lv2_name] = new_unit
	self._linked_unit_map[lv1_name] = unit_map

	self:set_var_and_cb_delayed(new_unit, lv2)
end

function CoreSpawnSystem:set_unit_enabled(socket_name, unit_name, enabled)
	local unit_map = self._enabled_unit_map[socket_name]

	if unit_map then
		local was_enabled = unit_map[unit_name]

		if was_enabled == nil then
			Application:error("Unable to set enabled state \"" .. tostring(enabled) .. "\" on unit name \"" .. tostring(unit_name) .. "\" and socket name \"" .. tostring(socket_name) .. "\". It doesn't exist.")
		elseif not was_enabled ~= not enabled then
			if enabled then
				self:setup_unit(self:get_socket_nodes(socket_name, unit_name))
			else
				local unit = self._linked_unit_map[socket_name][unit_name]
				self._linked_unit_map[socket_name][unit_name] = nil

				if alive(unit) then
					unit:set_slot(0)
				end
			end

			unit_map[unit_name] = enabled
		end
	else
		Application:error("Unable to set enabled state \"" .. tostring(enabled) .. "\" on unit name \"" .. tostring(unit_name) .. "\" and socket name \"" .. tostring(socket_name) .. "\". It was either not disabled or it doesn't exist.")
	end
end

function CoreSpawnSystem:get_socket_nodes(socket_name, unit_name)
	local xml_data = self:find_spawn_node(PackageManager:unit_data(self._unit:name():id()):model_script_data())

	if xml_data then
		for lv1 in xml_data:children() do
			local lv1_name = lv1:parameter("name")

			if lv1:name() == "socket" and lv1_name == socket_name then
				for lv2 in lv1:children() do
					local lv2_name = lv2:parameter("name")

					if lv2:name() == "unit" and lv2_name == unit_name then
						return lv1, lv2
					end
				end
			end
		end
	end
end
