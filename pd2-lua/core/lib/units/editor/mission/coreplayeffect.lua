core:import("CoreEngineAccess")

CorePlayEffectUnitElement = CorePlayEffectUnitElement or class(MissionElement)
CorePlayEffectUnitElement.USES_POINT_ORIENTATION = true
PlayEffectUnitElement = PlayEffectUnitElement or class(CorePlayEffectUnitElement)

function PlayEffectUnitElement:init(...)
	CorePlayEffectUnitElement.init(self, ...)
end

function CorePlayEffectUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.effect = "none"
	self._hed.screen_space = false
	self._hed.base_time = 0
	self._hed.random_time = 0
	self._hed.max_amount = 0

	table.insert(self._save_values, "effect")
	table.insert(self._save_values, "screen_space")
	table.insert(self._save_values, "base_time")
	table.insert(self._save_values, "random_time")
	table.insert(self._save_values, "max_amount")
end

function CorePlayEffectUnitElement:test_element()
	if self._hed.effect ~= "none" then
		self:stop_test_element()
		CoreEngineAccess._editor_load(Idstring("effect"), self._hed.effect:id())

		local position = self._hed.screen_space and Vector3() or self._unit:position()
		local rotation = self._hed.screen_space and Rotation() or self._unit:rotation()
		self._effect = World:effect_manager():spawn({
			effect = self._hed.effect:id(),
			position = position,
			rotation = rotation
		})
	end
end

function CorePlayEffectUnitElement:stop_test_element()
	if self._effect then
		World:effect_manager():kill(self._effect)

		self._effect = false
	end
end

function CorePlayEffectUnitElement:_effect_options()
	local effect_options = {
		"none"
	}

	for _, name in ipairs(managers.database:list_entries_of_type("effect")) do
		table.insert(effect_options, name)
	end

	return effect_options
end

function CorePlayEffectUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_checkbox(panel, panel_sizer, "screen_space", "Play in Screen Space")
	self:_build_value_combobox(panel, panel_sizer, "effect", self:_effect_options(), "Select and effect from the combobox")
	self:_build_value_number(panel, panel_sizer, "base_time", {
		floats = 2,
		min = 0
	}, "This is the minimum time to wait before spawning next effect")
	self:_build_value_number(panel, panel_sizer, "random_time", {
		floats = 2,
		min = 0
	}, "Random time is added to minimum time to give the time between effect spawns")
	self:_build_value_number(panel, panel_sizer, "max_amount", {
		floats = 0,
		min = 0
	}, "Maximum amount of spawns when repeating effects (0 = unlimited)")

	local help = {
		text = [[
Choose an effect from the combobox. Use "Play in Screen Space" if the effect is set up to be played like that. 

Use base time and random time if you want to repeat playing the effect, keep them at 0 to only play it once. "Base Time" is the minimum time between effects. "Random Time" is added to base time to set the total time until next effect. "Max Amount" can be used to set how many times the effect should be repeated (when base time and random time are used). 

Be sure not to use a looping effect when using repeat or the effects will add to each other and wont be stoppable after run simulation or by calling kill or fade kill.]],
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end

function CorePlayEffectUnitElement:add_to_mission_package()
	if self._hed.effect and self._hed.effect ~= "none" then
		managers.editor:add_to_world_package({
			category = "effects",
			name = self._hed.effect,
			continent = self._unit:unit_data().continent
		})
	end
end

CoreStopEffectUnitElement = CoreStopEffectUnitElement or class(MissionElement)
CoreStopEffectUnitElement.LINK_ELEMENTS = {
	"elements"
}
StopEffectUnitElement = StopEffectUnitElement or class(CoreStopEffectUnitElement)

function StopEffectUnitElement:init(...)
	CoreStopEffectUnitElement.init(self, ...)
end

function CoreStopEffectUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.operation = "fade_kill"
	self._hed.elements = {}

	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "elements")
end

function CoreStopEffectUnitElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0,
				b = 0,
				r = 0.75,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function CoreStopEffectUnitElement:get_links_to_unit(...)
	CoreStopEffectUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "operator", ...)
end

function CoreStopEffectUnitElement:update_editing()
end

function CoreStopEffectUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and string.find(ray.unit:name():s(), "env_effect_play", 1, true) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CoreStopEffectUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreStopEffectUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"env_effect_play"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_combobox(panel, panel_sizer, "operation", {
		"kill",
		"fade_kill"
	}, "Select a kind of operation to perform on the added effects")
end
