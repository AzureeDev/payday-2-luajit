CustomSafehouseFilterUnitElement = CustomSafehouseFilterUnitElement or class(MissionElement)

function CustomSafehouseFilterUnitElement:init(unit)
	CustomSafehouseFilterUnitElement.super.init(self, unit)

	self._hed.room_id = tweak_data.safehouse.rooms[1].room_id
	self._hed.room_tier = "1"
	self._hed.tier_check = "current"
	self._hed.check_type = "equal"

	table.insert(self._save_values, "room_id")
	table.insert(self._save_values, "room_tier")
	table.insert(self._save_values, "tier_check")
	table.insert(self._save_values, "check_type")
end

function CustomSafehouseFilterUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	if not self._character_rooms then
		self._character_rooms = {}

		for idx, room in ipairs(tweak_data.safehouse.rooms) do
			table.insert(self._character_rooms, room.room_id)
		end
	end

	self._character_box = self:_build_value_combobox(panel, panel_sizer, "room_id", self._character_rooms, "Select a room from the combobox")

	self._character_box:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "room_id",
		ctrlr = self._character_box
	})

	local tiers = {}

	for i = 1, #tweak_data.safehouse.prices.rooms do
		table.insert(tiers, tostring(i))
	end

	self._tier_box = self:_build_value_combobox(panel, panel_sizer, "room_tier", tiers, "Select a tier from the combobox")

	self:_build_value_combobox(panel, panel_sizer, "tier_check", {
		"current",
		"highest_unlocked"
	}, "Select which tier operation to perform")
	self:_build_value_combobox(panel, panel_sizer, "check_type", {
		"equal",
		"less_than",
		"greater_than",
		"less_or_equal",
		"greater_or_equal"
	}, "Select which check operation to perform")
	self:_add_help_text("Will only execute if the current/highest unlocked tier of the characters room is <operator> the specified tier.")
end

function CustomSafehouseFilterUnitElement:set_element_data(data)
	CustomSafehouseFilterUnitElement.super.set_element_data(self, data)

	if data.ctrlr == self._character_box then
		local current_selection = self._tier_box:get_selection()

		self._tier_box:clear()

		local num_tiers = managers.custom_safehouse:get_room_max_tier(self._character_box:get_value())
		local tiers = {}

		for i = 1, num_tiers do
			self._tier_box:append(tostring(i))
		end

		self._tier_box:set_selection(math.clamp(current_selection, 0, num_tiers))
	end
end

CustomSafehouseTrophyFilterUnitElement = CustomSafehouseTrophyFilterUnitElement or class(MissionElement)

function CustomSafehouseTrophyFilterUnitElement:init(unit)
	CustomSafehouseTrophyFilterUnitElement.super.init(self, unit)

	self._hed.trophy = ""
	self._hed.check_type = "unlocked"

	table.insert(self._save_values, "trophy")
	table.insert(self._save_values, "check_type")
end

function CustomSafehouseTrophyFilterUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	if not self._trophy_ids then
		self._trophy_ids = {}

		for idx, trophy in ipairs(tweak_data.safehouse.trophies) do
			table.insert(self._trophy_ids, trophy.id)
		end
	end

	self:_build_value_combobox(panel, panel_sizer, "trophy", self._trophy_ids, "")
	self:_build_value_combobox(panel, panel_sizer, "check_type", {
		"unlocked",
		"locked"
	}, "Check if the trophy is unlocked or locked")
end

CustomSafehouseAwardTrophyUnitElement = CustomSafehouseAwardTrophyUnitElement or class(MissionElement)

function CustomSafehouseAwardTrophyUnitElement:init(unit)
	CustomSafehouseAwardTrophyUnitElement.super.init(self, unit)

	self._hed.trophy = ""
	self._hed.objective_id = ""
	self._hed.award_instigator = false
	self._hed.players_from_start = nil

	table.insert(self._save_values, "trophy")
	table.insert(self._save_values, "objective_id")
	table.insert(self._save_values, "award_instigator")
	table.insert(self._save_values, "players_from_start")
end

function CustomSafehouseAwardTrophyUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	if not self._trophy_ids then
		self._trophy_ids = {}

		for idx, trophy in ipairs(tweak_data.safehouse.trophies) do
			table.insert(self._trophy_ids, trophy.id)
		end

		for idx, trophy in ipairs(tweak_data.safehouse.dailies) do
			table.insert(self._trophy_ids, trophy.id)
		end
	end

	local objectives = {
		"select a trophy"
	}

	if self._hed.trophy then
		local id = self._hed.trophy
		local trophy = managers.custom_safehouse:get_trophy(id) or managers.custom_safehouse:get_daily(id)

		if trophy then
			objectives = {}

			for idx, objective in ipairs(trophy.objectives) do
				table.insert(objectives, objective.achievement_id or objective.progress_id)
			end
		end
	end

	self._trophy_box = self:_build_value_combobox(panel, panel_sizer, "trophy", self._trophy_ids, "Select a trophy from the combobox")

	self._trophy_box:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "trophy",
		ctrlr = self._trophy_box
	})

	self._objective_box = self:_build_value_combobox(panel, panel_sizer, "objective_id", objectives, "Select a trophy objective from the combobox")

	self._objective_box:set_value(self._hed.objective_id)
	self:_build_value_checkbox(panel, panel_sizer, "award_instigator", "Award only the instigator (Player or driver in vehicle)?")
	self:_build_value_checkbox(panel, panel_sizer, "players_from_start", "Only award to players that joined from start.")
	self:_add_help_text("Awards a Safehouse Trophy.")
end

function CustomSafehouseAwardTrophyUnitElement:set_element_data(data)
	CustomSafehouseAwardTrophyUnitElement.super.set_element_data(self, data)

	if data.ctrlr == self._trophy_box then
		local id = self._trophy_box:get_value()
		local trophy = managers.custom_safehouse:get_trophy(id) or managers.custom_safehouse:get_daily(id)

		self._objective_box:clear()

		for idx, objective in ipairs(trophy.objectives) do
			self._objective_box:append(objective.achievement_id or objective.progress_id)
		end

		self._objective_box:set_selection(0)
	end
end
