local tmp_vec1 = Vector3()

core:module("CoreElementArea")
core:import("CoreShapeManager")
core:import("CoreMissionScriptElement")
core:import("CoreTable")

ElementAreaTrigger = ElementAreaTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementAreaTrigger:init(...)
	ElementAreaTrigger.super.init(self, ...)

	self._last_project_amount_all = 0
	self._shapes = {}
	self._shape_elements = {}
	self._rules_elements = {}

	if not self._values.use_shape_element_ids then
		if not self._values.shape_type or self._values.shape_type == "box" then
			self:_add_shape(CoreShapeManager.ShapeBoxMiddle:new({
				position = self._values.position,
				rotation = self._values.rotation,
				width = self._values.width,
				depth = self._values.depth,
				height = self._values.height
			}))
		elseif self._values.shape_type == "cylinder" then
			self:_add_shape(CoreShapeManager.ShapeCylinderMiddle:new({
				position = self._values.position,
				rotation = self._values.rotation,
				height = self._values.height,
				radius = self._values.radius
			}))
		end
	end

	self._inside = {}
end

function ElementAreaTrigger:on_script_activated()
	self._on_script_activated_done = true

	if self._values.use_shape_element_ids then
		for _, id in ipairs(self._values.use_shape_element_ids) do
			local element = self:get_mission_element(id)

			table.insert(self._shape_elements, element)
		end
	end

	if self._values.rules_element_ids then
		for _, id in ipairs(self._values.rules_element_ids) do
			local element = self:get_mission_element(id)

			table.insert(self._rules_elements, element)
		end
	end

	self._mission_script:add_save_state_cb(self._id)

	if self._values.enabled then
		self:add_callback()
	end
end

function ElementAreaTrigger:_add_shape(shape)
	table.insert(self._shapes, shape)
end

function ElementAreaTrigger:get_shapes()
	return self._shapes
end

function ElementAreaTrigger:is_inside(pos)
	for _, shape in ipairs(self._shapes) do
		if shape:is_inside(pos) then
			return true
		end
	end

	return false
end

function ElementAreaTrigger:_is_inside(pos)
	if self:is_inside(pos) then
		return true
	end

	for _, element in ipairs(self._shape_elements) do
		local use = self._values.use_disabled_shapes or element:enabled()

		if use and element:is_inside(pos) then
			return true
		end
	end

	return false
end

function ElementAreaTrigger:set_enabled(enabled)
	if not enabled and Network:is_server() and self._values.trigger_on == "both" then
		for _, unit in ipairs(CoreTable.clone(self._inside)) do
			self:sync_exit_area(unit)
		end
	end

	ElementAreaTrigger.super.set_enabled(self, enabled)

	if enabled then
		self:add_callback()
	else
		self._inside = {}

		self:remove_callback()
	end
end

function ElementAreaTrigger:add_callback()
	if not self._callback then
		self._callback = self._mission_script:add(callback(self, self, "update_area"), self._values.interval)
	end
end

function ElementAreaTrigger:remove_callback()
	if self._callback then
		self._mission_script:remove(self._callback)

		self._callback = nil
	end
end

function ElementAreaTrigger:on_executed(instigator, ...)
	if not self._values.enabled then
		return
	end

	ElementAreaTrigger.super.on_executed(self, instigator, ...)

	if not self._values.enabled then
		self:remove_callback()
	end
end

function ElementAreaTrigger:instigators()
	if self._values.unit_ids then
		local instigators = {}

		if Network:is_server() then
			for _, id in ipairs(self._values.unit_ids) do
				local unit = Application:editor() and managers.editor:layer("Statics"):created_units_pairs()[id] or managers.worlddefinition:get_unit(id)

				if alive(unit) then
					table.insert(instigators, unit)
				end
			end
		end

		return instigators
	end

	local instigators = self:project_instigators()

	for _, id in ipairs(self._values.spawn_unit_elements) do
		local element = self:get_mission_element(id)

		if element then
			for _, unit in ipairs(element:units()) do
				table.insert(instigators, unit)
			end
		end
	end

	return instigators
end

function ElementAreaTrigger:project_instigators()
	return {}
end

function ElementAreaTrigger:project_amount_all()
	return nil
end

function ElementAreaTrigger:project_amount_inside()
	return #self._inside
end

function ElementAreaTrigger:is_instigator_valid(unit)
	return true
end

function ElementAreaTrigger:debug_draw()
	if self._values.instigator == "loot" or self._values.instigator == "unique_loot" then
		for _, shape in ipairs(self._shapes) do
			shape:draw(0, 0, self._values.enabled and 0 or 1, self._values.enabled and 1 or 0, 0, 0.2)
		end

		for _, shape_element in ipairs(self._shape_elements) do
			for _, shape in ipairs(shape_element:get_shapes()) do
				shape:draw(0, 0, self._values.enabled and 0 or 1, self._values.enabled and 1 or 0, 0, 0.2)
			end
		end
	end
end

function ElementAreaTrigger:update_area()
	if not self._values.enabled then
		return
	end

	if self._values.trigger_on == "on_empty" then
		if Network:is_server() then
			self._inside = {}

			for _, unit in ipairs(self:instigators()) do
				if alive(unit) then
					self:_should_trigger(unit)
				end
			end

			if #self._inside == 0 then
				self:on_executed()
			end
		end
	else
		local instigators = self:instigators()

		if #instigators == 0 and Network:is_server() then
			if self:_should_trigger(nil) then
				self:_check_amount(nil)
			end
		else
			for _, unit in ipairs(instigators) do
				if alive(unit) then
					if Network:is_client() then
						self:_client_check_state(unit)
					elseif self:_should_trigger(unit) then
						self:_check_amount(unit)
					end
				end
			end
		end
	end
end

function ElementAreaTrigger:sync_enter_area(unit)
	table.insert(self._inside, unit)

	if self._values.trigger_on == "on_enter" or self._values.trigger_on == "both" or self._values.trigger_on == "while_inside" then
		self:_check_amount(unit)
	end
end

function ElementAreaTrigger:sync_exit_area(unit)
	table.delete(self._inside, unit)

	if self._values.trigger_on == "on_exit" or self._values.trigger_on == "both" then
		self:_check_amount(unit)
	end
end

function ElementAreaTrigger:sync_while_in_area(unit)
	self:_check_amount(unit)
end

function ElementAreaTrigger:_check_amount(unit)
	if self._values.trigger_on == "on_enter" then
		local amount = self._values.amount == "all" and self:project_amount_all()
		amount = amount or tonumber(self._values.amount)

		self:_clean_destroyed_units()

		local inside = self:project_amount_inside()

		if inside > 0 and (amount and amount <= inside or not amount) then
			self:on_executed(unit)
		end
	elseif self:is_instigator_valid(unit) then
		self:on_executed(unit)
	end
end

function ElementAreaTrigger:_should_trigger(unit)
	if alive(unit) then
		local rule_ok = self:_check_instigator_rules(unit)
		local inside = nil

		if unit:movement() then
			inside = self:_is_inside(unit:movement():m_pos())
		else
			unit:m_position(tmp_vec1)

			inside = self:_is_inside(tmp_vec1)
		end

		if table.contains(self._inside, unit) then
			if not inside or not rule_ok then
				table.delete(self._inside, unit)

				if self._values.trigger_on == "on_exit" or self._values.trigger_on == "both" then
					return true
				end
			end
		elseif inside and rule_ok then
			table.insert(self._inside, unit)

			if self._values.trigger_on == "on_enter" or self._values.trigger_on == "both" then
				return true
			end
		end

		if self._values.trigger_on == "while_inside" and inside and rule_ok then
			return true
		end
	end

	if self._values.amount == "all" then
		local project_amount_all = self:project_amount_all()

		if project_amount_all ~= self._last_project_amount_all then
			self._last_project_amount_all = project_amount_all

			self:_clean_destroyed_units()

			return true
		end
	end

	return false
end

function ElementAreaTrigger:_check_instigator_rules(unit)
	for _, element in ipairs(self._rules_elements) do
		if not element:check_rules(self._values.instigator, unit) then
			return false
		end
	end

	return true
end

function ElementAreaTrigger:_clean_destroyed_units()
	local i = 1

	if next(self._inside) then
		while next(self._inside) and i <= #self._inside do
			if alive(self._inside[i]) then
				i = i + 1
			else
				table.remove(self._inside, i)
			end
		end
	end
end

function ElementAreaTrigger:_client_check_state(unit)
	local rule_ok = self:_check_instigator_rules(unit)
	local inside = self:_is_inside(unit:position())

	if table.contains(self._inside, unit) then
		if not inside or not rule_ok then
			table.delete(self._inside, unit)
			managers.network:session():send_to_host("to_server_area_event", 2, self._id, unit)
		elseif self._values.trigger_on == "while_inside" then
			managers.network:session():send_to_host("to_server_area_event", 3, self._id, unit)
		end
	elseif inside and rule_ok then
		table.insert(self._inside, unit)
		managers.network:session():send_to_host("to_server_area_event", 1, self._id, unit)
	end
end

function ElementAreaTrigger:operation_set_interval(interval)
	self._values.interval = interval

	self:remove_callback()

	if self._values.enabled then
		self:add_callback()
	end
end

function ElementAreaTrigger:operation_set_use_disabled_shapes(use_disabled_shapes)
	self._values.use_disabled_shapes = use_disabled_shapes
end

function ElementAreaTrigger:operation_clear_inside()
	self._inside = {}
end

function ElementAreaTrigger:save(data)
	data.enabled = self._values.enabled
	data.interval = self._values.interval
	data.use_disabled_shapes = self._values.use_disabled_shapes
end

function ElementAreaTrigger:load(data)
	if not self._on_script_activated_done then
		self:on_script_activated()
	end

	self:set_enabled(data.enabled)
	self:operation_set_interval(data.interval)

	self._values.use_disabled_shapes = data.use_disabled_shapes
end

ElementAreaOperator = ElementAreaOperator or class(CoreMissionScriptElement.MissionScriptElement)

function ElementAreaOperator:init(...)
	ElementAreaOperator.super.init(self, ...)
end

function ElementAreaOperator:client_on_executed(...)
	self:on_executed(...)
end

function ElementAreaOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			if self._values.apply_on_interval then
				element:operation_set_interval(self._values.interval)
			end

			if self._values.apply_on_use_disabled_shapes then
				element:operation_set_use_disabled_shapes(self._values.use_disabled_shapes)
			end

			if self._values.operation == "clear_inside" then
				element:operation_clear_inside()
			end
		end
	end

	ElementAreaOperator.super.on_executed(self, instigator)
end

ElementAreaReportTrigger = ElementAreaReportTrigger or class(ElementAreaTrigger)

function ElementAreaReportTrigger:update_area()
	if not self._values.enabled then
		return
	end

	local instigators = self:instigators()

	if #instigators == 0 and Network:is_server() then
		self:_check_state(nil)
	else
		for _, unit in ipairs(instigators) do
			if alive(unit) then
				if Network:is_client() then
					self:_client_check_state(unit)
				elseif Network:is_server() then
					self:_check_state(unit)
				end
			end
		end
	end
end

function ElementAreaReportTrigger:_check_state(unit)
	self:_clean_destroyed_units()

	if alive(unit) then
		local rule_ok = self:_check_instigator_rules(unit)
		local inside = nil

		if unit:movement() then
			inside = self:_is_inside(unit:movement():m_pos())
		else
			unit:m_position(tmp_vec1)

			inside = self:_is_inside(tmp_vec1)
		end

		if inside and not rule_ok then
			self:_rule_failed(unit)
		end

		if table.contains(self._inside, unit) then
			if not inside or not rule_ok then
				self:_remove_inside(unit)
			elseif inside and rule_ok then
				self:_while_inside(unit)
			end
		elseif inside and rule_ok then
			self:_add_inside(unit)
		end
	end

	local project_amount_all = self:project_amount_all()

	if project_amount_all ~= self._last_project_amount_all then
		self._last_project_amount_all = project_amount_all

		self:_clean_destroyed_units()

		return true
	end

	return false
end

function ElementAreaReportTrigger:_add_inside(unit)
	table.insert(self._inside, unit)

	if self:_has_on_executed_alternative("while_inside") then
		self:on_executed(unit, "while_inside")
	else
		self:on_executed(unit, "enter")
	end

	self:_check_on_executed_reached_amount(unit)
end

function ElementAreaReportTrigger:_check_on_executed_reached_amount(unit)
	local amount = self._values.amount == "all" and self:project_amount_all()
	amount = amount or tonumber(self._values.amount)

	if amount == #self._inside and self:_has_on_executed_alternative("reached_amount") then
		self:on_executed(unit, "reached_amount")
	end
end

function ElementAreaReportTrigger:_while_inside(unit)
	if self:_has_on_executed_alternative("while_inside") then
		self:on_executed(unit, "while_inside")
	end
end

function ElementAreaReportTrigger:_rule_failed(unit)
	if self:_has_on_executed_alternative("rule_failed") then
		self:on_executed(unit, "rule_failed")
	end
end

function ElementAreaReportTrigger:_remove_inside(unit)
	table.delete(self._inside, unit)
	self:on_executed(unit, "leave")

	if #self._inside == 0 then
		self:on_executed(unit, "empty")
	end

	self:_check_on_executed_reached_amount(unit)
end

function ElementAreaReportTrigger:_remove_inside_by_index(index)
	table.remove(self._inside, index)
	self:on_executed(nil, "leave")

	if #self._inside == 0 then
		self:on_executed(nil, "empty")
	end

	self:_check_on_executed_reached_amount(nil)
end

function ElementAreaReportTrigger:_clean_destroyed_units()
	local i = 1

	if next(self._inside) then
		while next(self._inside) and i <= #self._inside do
			local unit = self._inside[i]

			if alive(unit) and (not unit:character_damage() or not unit:character_damage():dead()) then
				i = i + 1
			else
				if alive(unit) and unit:character_damage() and unit:character_damage():dead() then
					self:on_executed(unit, "on_death")
				end

				self:_remove_inside_by_index(i)
			end
		end
	end
end

function ElementAreaReportTrigger:_client_check_state(unit)
	local rule_ok = self:_check_instigator_rules(unit)
	local inside = self:_is_inside(unit:position())

	if table.contains(self._inside, unit) then
		if not inside or not rule_ok then
			table.delete(self._inside, unit)
			managers.network:session():send_to_host("to_server_area_event", 2, self._id, unit)
		end
	elseif inside and rule_ok then
		table.insert(self._inside, unit)
		managers.network:session():send_to_host("to_server_area_event", 1, self._id, unit)
	end

	if inside then
		if rule_ok then
			if self:_has_on_executed_alternative("while_inside") then
				managers.network:session():send_to_host("to_server_area_event", 3, self._id, unit)
			end
		elseif self:_has_on_executed_alternative("rule_failed") then
			managers.network:session():send_to_host("to_server_area_event", 4, self._id, unit)
		end
	end
end

function ElementAreaReportTrigger:sync_enter_area(unit)
	self:_add_inside(unit)
end

function ElementAreaReportTrigger:sync_exit_area(unit)
	self:_remove_inside(unit)
end

function ElementAreaReportTrigger:sync_while_in_area(unit)
	self:_while_inside(unit)
end

function ElementAreaReportTrigger:sync_rule_failed(unit)
	self:_rule_failed(unit)
end
