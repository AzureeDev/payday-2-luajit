ObjectivesManager = ObjectivesManager or class()
ObjectivesManager.PATH = "gamedata/objectives"
ObjectivesManager.FILE_EXTENSION = "objective"
ObjectivesManager.FULL_PATH = ObjectivesManager.PATH .. "." .. ObjectivesManager.FILE_EXTENSION
ObjectivesManager.REMINDER_INTERVAL = 240

function ObjectivesManager:init()
	self._objectives = {}
	self._active_objectives = {}
	self._remind_objectives = {}
	self._completed_objectives = {}
	self._completed_objectives_ordered = {}
	self._read_objectives = {}
	self._objectives_level_id = {}

	self:_parse_objectives()
end

function ObjectivesManager:_parse_objectives()
	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), self.PATH:id())

	for _, data in ipairs(list) do
		if data._meta == "objective" then
			self:_parse_objective(data)
		else
			Application:error("Unknown node \"" .. tostring(data._meta) .. "\" in \"" .. self.FULL_PATH .. "\". Expected \"objective\" node.")
		end
	end
end

function ObjectivesManager:_parse_objective(data)
	local id = data.id
	local text = managers.localization:text(data.text)
	local description = managers.localization:text(data.description)
	local prio = data.prio
	local amount = data.amount
	local amount_text = data.amount_text and managers.localization:text(data.amount_text)
	local level_id = data.level_id
	local xp_weight = data.xp_weight
	local sub_objectives = {}

	for _, sub in ipairs(data) do
		local sub_text = managers.localization:text(sub.text)
		sub_objectives[sub.id] = {
			id = sub.id,
			text = sub_text
		}
	end

	self._objectives[id] = {
		text = text,
		description = description,
		prio = prio,
		id = id,
		amount = amount,
		current_amount = amount and 0 or nil,
		amount_text = amount_text,
		sub_objectives = sub_objectives,
		level_id = level_id,
		xp_weight = xp_weight
	}

	if level_id then
		self._objectives_level_id[level_id] = self._objectives_level_id[level_id] or {}
		self._objectives_level_id[level_id][id] = {xp_weight = xp_weight or 0}
	end
end

function ObjectivesManager:update(t, dt)
	for id, data in pairs(self._remind_objectives) do
		if data.next_t < t then
			self:_remind_objetive(id)
		end
	end

	if self._delayed_presentation then
		self._delayed_presentation.t = self._delayed_presentation.t - dt

		if self._delayed_presentation.t <= 0 then
			managers.hud:activate_objective(self._delayed_presentation.activate_params)

			if self._delayed_presentation.mid_text_params then
				managers.hud:present_mid_text(self._delayed_presentation.mid_text_params)
			end

			self._delayed_presentation = nil
		end
	end
end

function ObjectivesManager:_remind_objetive(id, title_id)
	if not Application:editor() and managers.platform:presence() ~= "Playing" then
		return
	end

	if self._remind_objectives[id] then
		self._remind_objectives[id].next_t = Application:time() + self.REMINDER_INTERVAL
	end

	if managers.user:get_setting("objective_reminder") then
		title_id = title_id or "hud_objective_reminder"
		local objective = self._objectives[id]
		local title_message = managers.localization:text(title_id)
		local text = objective.text

		managers.hud:present_mid_text({
			time = 4,
			text = text,
			title = title_message
		})
	end

	managers.hud:remind_objective(id)
end

function ObjectivesManager:get_stinger_id()
	local job_tweak = tweak_data.narrative.jobs[managers.job:current_real_job_id()]

	if job_tweak and job_tweak.objective_stinger then
		return job_tweak.objective_stinger
	end

	return "stinger_objectivecomplete"
end

function ObjectivesManager:update_objective(id, load_data)
	self:activate_objective(id, load_data, {title_message = managers.localization:text("mission_objective_updated")})
end

function ObjectivesManager:complete_and_activate_objective(id, load_data, data)
	local delay_presentation = next(self._active_objectives) and true or nil

	for name, data in pairs(clone(self._active_objectives)) do
		self:complete_objective(name)
	end

	data = data or {}
	data.delay_presentation = delay_presentation or nil

	self:activate_objective(id, nil, data)
end

function ObjectivesManager:remove_and_activate_objective(id, load_data, data)
	local delay_presentation = next(self._active_objectives) and true or nil

	for name, data in pairs(clone(self._active_objectives)) do
		self:remove_objective(name)
	end

	data = data or {}
	data.delay_presentation = delay_presentation or nil

	self:activate_objective(id, nil, data)
end

function ObjectivesManager:activate_objective(id, load_data, data)
	if not id or not self._objectives[id] then
		Application:stack_dump_error("Bad id to activate objective, " .. tostring(id) .. ".")

		return
	end

	local objective = self._objectives[id]

	for _, sub_objective in pairs(objective.sub_objectives) do
		sub_objective.completed = false
	end

	objective.current_amount = load_data and load_data.current_amount or data and data.amount and 0 or objective.current_amount
	objective.amount = load_data and load_data.amount or data and data.amount or objective.amount
	local activate_params = {
		id = id,
		text = objective.text,
		sub_objectives = objective.sub_objectives,
		amount = objective.amount,
		current_amount = objective.current_amount,
		amount_text = objective.amount_text
	}
	self._delayed_presentation = nil

	if data and data.delay_presentation then
		self._delayed_presentation = {
			t = 1,
			activate_params = activate_params
		}
	else
		managers.hud:activate_objective(activate_params)
	end

	if not load_data then
		local title_message = data and data.title_message or managers.localization:text("mission_objective_activated")
		local text = objective.text

		if self._delayed_presentation then
			self._delayed_presentation.mid_text_params = {
				time = 4,
				text = text,
				title = title_message,
				event = self:get_stinger_id()
			}
		else
			managers.hud:present_mid_text({
				time = 4,
				text = text,
				title = title_message,
				event = self:get_stinger_id()
			})
		end
	end

	self._active_objectives[id] = objective
	self._remind_objectives[id] = {next_t = Application:time() + self.REMINDER_INTERVAL}
end

function ObjectivesManager:activate_objective_countdown(id, load_data, data)
	if not id or not self._objectives[id] then
		Application:stack_dump_error("Bad id to activate objective, " .. tostring(id) .. ".")

		return
	end

	local objective = self._objectives[id]

	for _, sub_objective in pairs(objective.sub_objectives) do
		sub_objective.completed = false
	end

	objective.current_amount = load_data and load_data.current_amount or data and data.amount and 0 or objective.current_amount
	objective.amount = load_data and load_data.amount or data and data.amount or objective.amount
	objective.countdown = true
	local activate_params = {
		id = id,
		text = objective.text,
		sub_objectives = objective.sub_objectives,
		amount = objective.amount,
		current_amount = objective.amount - objective.current_amount,
		amount_text = objective.amount_text
	}
	self._delayed_presentation = nil

	if data and data.delay_presentation then
		self._delayed_presentation = {
			t = 1,
			activate_params = activate_params
		}
	else
		managers.hud:activate_objective(activate_params)
	end

	if not load_data then
		local title_message = data and data.title_message or managers.localization:text("mission_objective_activated")
		local text = objective.text

		if self._delayed_presentation then
			self._delayed_presentation.mid_text_params = {
				time = 4,
				text = text,
				title = title_message,
				event = self:get_stinger_id()
			}
		else
			managers.hud:present_mid_text({
				time = 4,
				text = text,
				title = title_message,
				event = self:get_stinger_id()
			})
		end
	end

	self._active_objectives[id] = objective
	self._remind_objectives[id] = {next_t = Application:time() + self.REMINDER_INTERVAL}
end

function ObjectivesManager:remove_objective(id, load_data)
	if not load_data then
		if not id or not self._objectives[id] then
			Application:stack_dump_error("Bad id to remove objective, " .. tostring(id) .. ".")

			return
		end

		if not self._active_objectives[id] then
			return
		end
	end

	local objective = self._objectives[id]

	managers.hud:complete_objective({
		remove = true,
		id = id,
		text = objective.text
	})

	self._active_objectives[id] = nil
	self._remind_objectives[id] = nil

	if self._delayed_presentation and self._delayed_presentation.activate_params.id == id then
		self._delayed_presentation = nil
	end
end

function ObjectivesManager:complete_objective(id, load_data)
	if not load_data then
		if not id or not self._objectives[id] then
			Application:stack_dump_error("Bad id to complete objective, " .. tostring(id) .. ".")

			return
		end

		if not self._active_objectives[id] then
			if not self._completed_objectives[id] then
				self._completed_objectives[id] = self._objectives[id]

				table.insert(self._completed_objectives_ordered, 1, id)
			end

			Application:error("Tried to complete objective " .. tostring(id) .. ". This objective has never been given to the player.")

			return
		end
	end

	local objective = self._objectives[id]

	if objective.amount then
		objective.current_amount = objective.current_amount + 1

		managers.hud:update_amount_objective({
			id = id,
			text = objective.text,
			amount_text = objective.amount_text,
			amount = objective.amount,
			current_amount = objective.current_amount
		})

		if objective.current_amount < objective.amount then
			self:_remind_objetive(id, "mission_objective_updated")

			return
		end

		objective.current_amount = 0
	end

	managers.hud:complete_objective({
		id = id,
		text = objective.text
	})
	managers.statistics:objective_completed()

	self._completed_objectives[id] = objective

	table.insert(self._completed_objectives_ordered, 1, id)

	self._active_objectives[id] = nil
	self._remind_objectives[id] = nil

	if self._delayed_presentation and self._delayed_presentation.activate_params.id == id then
		self._delayed_presentation = nil
	end
end

function ObjectivesManager:complete_sub_objective(id, sub_id, load_data)
	if not load_data then
		if not id or not self._objectives[id] then
			Application:stack_dump_error("Bad id to complete objective, " .. tostring(id) .. ".")

			return
		end

		if not self._active_objectives[id] then
			if not self._completed_objectives[id] then
				self._completed_objectives[id] = self._objectives[id]

				table.insert(self._completed_objectives_ordered, 1, id)
			end

			Application:error("Tried to complete objective " .. tostring(id) .. ". This objective has never been given to the player.")

			return
		end
	end

	local objective = self._objectives[id]
	local sub_objective = objective.sub_objectives[sub_id]

	if not sub_objective then
		Application:error("No sub objective " .. tostring(sub_id) .. ". For objective " .. tostring(id) .. "")

		return
	end

	sub_objective.completed = true

	managers.hud:complete_sub_objective({
		text = objective.text,
		sub_id = sub_id
	})

	local completed = true

	for _, sub_objective in pairs(objective.sub_objectives) do
		if not sub_objective.completed then
			completed = false

			break
		end
	end

	if completed then
		self:complete_objective(id)
	end
end

function ObjectivesManager:complete_objective_countdown(id, load_data)
	if not load_data then
		if not id or not self._objectives[id] then
			Application:stack_dump_error("Bad id to complete objective, " .. tostring(id) .. ".")

			return
		end

		if not self._active_objectives[id] then
			if not self._completed_objectives[id] then
				self._completed_objectives[id] = self._objectives[id]

				table.insert(self._completed_objectives_ordered, 1, id)
			end

			Application:error("Tried to complete objective " .. tostring(id) .. ". This objective has never been given to the player.")

			return
		end
	end

	local objective = self._objectives[id]

	if objective.amount then
		objective.current_amount = objective.current_amount + 1

		managers.hud:update_amount_objective({
			id = id,
			text = objective.text,
			amount_text = objective.amount_text,
			amount = objective.amount,
			current_amount = objective.amount - objective.current_amount
		})

		if objective.current_amount < objective.amount then
			self:_remind_objetive(id, "mission_objective_updated")

			return
		end

		objective.current_amount = 0
	end

	managers.hud:complete_objective({
		id = id,
		text = objective.text
	})
	managers.statistics:objective_completed()

	self._completed_objectives[id] = objective

	table.insert(self._completed_objectives_ordered, 1, id)

	self._active_objectives[id] = nil
	self._remind_objectives[id] = nil

	if self._delayed_presentation and self._delayed_presentation.activate_params.id == id then
		self._delayed_presentation = nil
	end
end

function ObjectivesManager:objective_is_active(id)
	return self._active_objectives[id]
end

function ObjectivesManager:objective_is_completed(id)
	return self._completed_objectives[id]
end

function ObjectivesManager:get_objective(id)
	return self._objectives[id]
end

function ObjectivesManager:get_all_objectives()
	local res = {}

	mix(res, self._active_objectives, self._completed_objectives)

	return res
end

function ObjectivesManager:get_active_objectives()
	return self._active_objectives
end

function ObjectivesManager:get_completed_objectives()
	return self._completed_objectives
end

function ObjectivesManager:get_completed_objectives_ordered()
	return self._completed_objectives_ordered
end

function ObjectivesManager:objectives_by_name()
	local t = {}

	for name, _ in pairs(self._objectives) do
		table.insert(t, name)
	end

	table.sort(t)

	return t
end

function ObjectivesManager:sub_objectives_by_name(id)
	local t = {}
	local objective = self._objectives[id]

	if objective then
		for name, _ in pairs(objective.sub_objectives) do
			table.insert(t, name)
		end
	end

	table.sort(t)

	return t
end

function ObjectivesManager:_get_xp(level_id, id)
	if not self._objectives_level_id[level_id] then
		Application:error("Had no xp for level", level_id)

		return 0
	end

	if not self._objectives_level_id[level_id][id] then
		Application:error("Had no xp for objective", id)

		return 0
	end

	local xp_weight = self:_get_real_xp_weight(level_id, self._objectives_level_id[level_id][id].xp_weight)

	return math.round(xp_weight * tweak_data:get_value("experience_manager", "total_level_objectives"))
end

function ObjectivesManager:_get_real_xp_weight(level_id, xp_weight)
	local total_xp_weight = self:_total_xp_weight(level_id)

	return xp_weight / total_xp_weight
end

function ObjectivesManager:_total_xp_weight(level_id)
	if not self._objectives_level_id[level_id] then
		return 0
	end

	local xp_weight = 0

	for obj, data in pairs(self._objectives_level_id[level_id]) do
		xp_weight = xp_weight + data.xp_weight
	end

	return xp_weight
end

function ObjectivesManager:_check_xp_weight(level_id)
	local total_xp = 0
	local total_xp_weight = self:_total_xp_weight(level_id)

	for obj, data in pairs(self._objectives_level_id[level_id]) do
		local xp = math.round(data.xp_weight / total_xp_weight * tweak_data:get_value("experience_manager", "total_level_objectives"))
		total_xp = total_xp + xp

		print(obj, xp)
	end

	print("total", total_xp)
end

function ObjectivesManager:total_objectives(level_id)
	if not self._objectives_level_id[level_id] then
		return 0
	end

	local i = 0

	for _, _ in pairs(self._objectives_level_id[level_id]) do
		i = i + 1
	end

	return i
end

function ObjectivesManager:save(data)
	if next(self._active_objectives) or next(self._completed_objectives) or next(self._read_objectives) then
		local state = {}
		local objective_map = {}
		state.completed_objectives_ordered = self._completed_objectives_ordered

		for name, objective in pairs(self._objectives) do
			local save_data = {}

			if self._active_objectives[name] then
				save_data.active = true
				save_data.current_amount = self._active_objectives[name].current_amount
				save_data.amount = self._active_objectives[name].amount
				save_data.countdown = self._active_objectives[name].countdown
				save_data.sub_objective = {}

				for sub_id, sub_objective in pairs(self._active_objectives[name].sub_objectives) do
					save_data.sub_objective[sub_id] = sub_objective.completed
				end
			end

			if self._completed_objectives[name] then
				save_data.complete = true
			end

			if self._read_objectives[name] then
				save_data.read = true
			end

			if next(save_data) then
				objective_map[name] = save_data
			end
		end

		state.objective_map = objective_map
		data.ObjectivesManager = state

		return true
	else
		return false
	end
end

function ObjectivesManager:load(data)
	local state = data.ObjectivesManager

	if state then
		self._completed_objectives_ordered = state.completed_objectives_ordered

		for name, save_data in pairs(state.objective_map) do
			local objective_data = self._objectives[name]

			if save_data.active then
				if save_data.countdown then
					self:activate_objective_countdown(name, {
						current_amount = save_data.current_amount,
						amount = save_data.amount
					})
				else
					self:activate_objective(name, {
						current_amount = save_data.current_amount,
						amount = save_data.amount
					})
				end

				for sub_id, completed in pairs(save_data.sub_objective) do
					if completed then
						self:complete_sub_objective(name, sub_id, {})
					end
				end
			end

			if save_data.complete then
				self._completed_objectives[name] = objective_data
			end

			if save_data.read then
				self._read_objectives[name] = true
			end
		end
	end
end

function ObjectivesManager:reset()
	self._active_objectives = {}
	self._completed_objectives = {}
	self._completed_objectives_ordered = {}
	self._read_objectives = {}
	self._remind_objectives = {}

	self:_parse_objectives()
end

function ObjectivesManager:set_read(id, is_read)
	self._read_objectives[id] = is_read
end

function ObjectivesManager:is_read(id)
	return self._read_objectives[id]
end

