InstigatorRuleUnitElement = InstigatorRuleUnitElement or class(MissionElement)
InstigatorRuleUnitElement.SAVE_UNIT_POSITION = false
InstigatorRuleUnitElement.SAVE_UNIT_ROTATION = false

function InstigatorRuleUnitElement:init(unit)
	InstigatorRuleUnitElement.super.init(self, unit)

	self._hed.instigator = "none"
	self._hed.rules = {}
	self._hed.invert = false

	table.insert(self._save_values, "instigator")
	table.insert(self._save_values, "rules")
	table.insert(self._save_values, "invert")
end

function InstigatorRuleUnitElement:destroy(unit)
	managers.vehicle:remove_listener(unit:name():s())
	InstigatorRuleUnitElement.super.destroy(self, unit)
end

function InstigatorRuleUnitElement:_rule_updated(category, value)
	self._hed.rules[self._hed.instigator] = self._hed.rules[self._hed.instigator] or {}
	self._hed.rules[self._hed.instigator][category] = #value > 0 and value or nil
end

function InstigatorRuleUnitElement:_instigator_changed(params)
	self:_update_rules_panel()
end

function InstigatorRuleUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local instigator_params = {
		name = "Instigator:",
		name_proportions = 1,
		tooltip = "Select an instigator type for the area",
		sorted = false,
		ctrlr_proportions = 2,
		panel = panel,
		sizer = panel_sizer,
		options = managers.mission:area_instigator_categories(),
		value = self._hed.instigator
	}
	local instigator = CoreEWS.combobox(instigator_params)

	instigator:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "instigator",
		ctrlr = instigator
	})
	instigator:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_instigator_changed"), {
		ctrlr = instigator
	})
	self:_build_value_checkbox(panel, panel_sizer, "invert", "Check this to have the rule inverted, i.e. exclude one unit from triggering the connected element", "Invert rule")

	self._rules_panel = EWS:Panel(panel, "rules_panel", "TAB_TRAVERSAL")
	self._rules_panel_sizer = EWS:BoxSizer("VERTICAL")

	self._rules_panel:set_sizer(self._rules_panel_sizer)
	self._rules_panel:destroy_children()
	panel_sizer:add(self._rules_panel, 1, 1, "EXPAND")
	self:_update_rules_panel()
	managers.vehicle:add_listener(self._unit:name():s(), {
		"on_add",
		"on_remove"
	}, callback(self, self, "_update_rules_panel"))
end

function InstigatorRuleUnitElement:_update_rules_panel(panel, panel_sizer)
	panel = self._rules_panel
	panel_sizer = self._rules_panel_sizer

	self._rules_panel:destroy_children()

	local instigator = self._hed.instigator

	if instigator == "player" then
		local states_params = {
			name = "Player states:",
			tooltip = "Select player state rules",
			panel = panel,
			sizer = panel_sizer,
			options = managers.player:player_states(),
			value = self._hed.rules[instigator] and self._hed.rules[instigator].states,
			updated_callback = callback(self, self, "_rule_updated", "states")
		}
		local states = CoreEws.list_selector(states_params)
		local carry_ids_params = {
			name = "Carry ids:",
			tooltip = "Select player carry ids rules",
			panel = panel,
			sizer = panel_sizer,
			options = tweak_data.carry:get_carry_ids(),
			value = self._hed.rules[instigator] and self._hed.rules[instigator].carry_ids,
			updated_callback = callback(self, self, "_rule_updated", "carry_ids")
		}
		local states = CoreEws.list_selector(carry_ids_params)
		local options = {}

		for name, _ in pairs(tweak_data.equipments.specials) do
			table.insert(options, name)
		end

		local mission_equipment_params = {
			name = "Mission equipment:",
			tooltip = "Select player mission equipment rules",
			panel = panel,
			sizer = panel_sizer,
			options = options,
			value = self._hed.rules[instigator] and self._hed.rules[instigator].mission_equipment,
			updated_callback = callback(self, self, "_rule_updated", "mission_equipment")
		}
		local states = CoreEws.list_selector(mission_equipment_params)
	elseif instigator == "enemies" then
		local carry_ids_params = {
			name = "Enemy name:",
			tooltip = "Select enemy names rules",
			panel = panel,
			sizer = panel_sizer,
			options = SpawnEnemyUnitElement._options,
			value = self._hed.rules[instigator] and self._hed.rules[instigator].enemy_names,
			updated_callback = callback(self, self, "_rule_updated", "enemy_names")
		}
		local states = CoreEws.list_selector(carry_ids_params)
		local pickups_params = {
			name = "Pickup:",
			tooltip = "Select a pickup rule",
			panel = panel,
			sizer = panel_sizer,
			options = PickupUnitElement.get_options(),
			value = self._hed.rules[instigator] and self._hed.rules[instigator].pickup,
			updated_callback = callback(self, self, "_rule_updated", "pickup")
		}
		local pickup = CoreEws.list_selector(pickups_params)
	elseif instigator == "civilians" then
		local civilian_names_params = {
			name = "Civilian name:",
			tooltip = "Select civilian names rules",
			panel = panel,
			sizer = panel_sizer,
			options = SpawnCivilianUnitElement._options,
			value = self._hed.rules[instigator] and self._hed.rules[instigator].civilian_names,
			updated_callback = callback(self, self, "_rule_updated", "civilian_names")
		}
		local states = CoreEws.list_selector(civilian_names_params)
		local pickups_params = {
			name = "Pickup:",
			tooltip = "Select a pickup rule",
			panel = panel,
			sizer = panel_sizer,
			options = PickupUnitElement.get_options(),
			value = self._hed.rules[instigator] and self._hed.rules[instigator].pickup,
			updated_callback = callback(self, self, "_rule_updated", "pickup")
		}
		local pickup = CoreEws.list_selector(pickups_params)
	elseif instigator == "loot" then
		local params = {
			name = "Carry ids:",
			tooltip = "Select a loot carry id rule",
			panel = panel,
			sizer = panel_sizer,
			options = tweak_data.carry:get_carry_ids(),
			value = self._hed.rules[instigator] and self._hed.rules[instigator].carry_ids,
			updated_callback = callback(self, self, "_rule_updated", "carry_ids")
		}
		local list = CoreEws.list_selector(params)
	elseif instigator == "vehicle" then
		local options = {}

		for _, unit in pairs(managers.vehicle:get_all_vehicles()) do
			if alive(unit) then
				table.insert(options, unit:name():s())
			end
		end

		local vehicle_names_params = {
			name = "Vehicle name:",
			tooltip = "Select vehicle name rules",
			panel = panel,
			sizer = panel_sizer,
			options = options,
			value = self._hed.rules[instigator] and self._hed.rules[instigator].vehicle_names,
			updated_callback = callback(self, self, "_rule_updated", "vehicle_names")
		}
		local states = CoreEws.list_selector(vehicle_names_params)
	end

	self._rules_panel:layout()
	self._panel:layout()
	managers.editor:layer("Mission"):do_layout()
end
