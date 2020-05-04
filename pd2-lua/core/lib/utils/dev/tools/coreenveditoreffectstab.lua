core:import("CoreEnvironmentFeeder")

CoreEnvEditor = CoreEnvEditor or class()

function CoreEnvEditor:init_effects_tab()
	self:create_effects_tab()
end

local function popuplate_list(list, items)
	list:clear_all()

	for _, item in ipairs(items) do
		local index = list:append_item(item)

		list:set_item_data(index, item)
	end
end

function CoreEnvEditor:create_effects_tab()
	self:create_tab("Effects")

	local gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "bloom_threshold", SingelSlider:new(self, self:get_tab("Effects"), "Bloom threshold", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Effects", "Bloom")

	gui = self:add_post_processors_param("bloom_combine_post_processor", "bloom_combine", "bloom_lense", "bloom_intensity", SingelSlider:new(self, self:get_tab("Effects"), "Bloom intensity", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Effects", "Bloom")

	gui = self:add_post_processors_param("bloom_combine_post_processor", "bloom_combine", "bloom_lense", "bloom_blur_size", SingelSlider:new(self, self:get_tab("Effects"), "Bloom blur size", nil, 1, 4, 1, 1))

	self:add_gui_element(gui, "Effects", "Bloom")

	gui = self:add_post_processors_param("bloom_combine_post_processor", "bloom_combine", "bloom_lense", "lense_intensity", SingelSlider:new(self, self:get_tab("Effects"), "Lense intensity", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Effects", "Lense")

	local panel = self._tabs.Effects.panel
	local panel_sizer = self._tabs.Effects.panel_box
	local all_effects = managers.environment_effects:effects_names()

	table.sort(all_effects)

	local environment_effect_sizer = EWS:BoxSizer("HORIZONTAL")
	local environment_active_effect_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "Active effects")
	local environment_effect_list_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "Effects")
	local environment_effect_control_sizer = EWS:BoxSizer("VERTICAL")
	self._active_effect_list = EWS:ListCtrl(panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	self._active_effect_list:clear_all()
	self._active_effect_list:set_min_size(Vector3(200, -1, 0))
	environment_active_effect_sizer:add(self._active_effect_list, 0, 0, "EXPAND")

	self._effect_list = EWS:ListCtrl(panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	environment_effect_list_sizer:add(self._effect_list, 0, 0, "EXPAND")
	popuplate_list(self._effect_list, all_effects)

	local effect_add = EWS:Button(panel, "<--", "", "BU_EXACTFIT,NO_BORDER")

	environment_effect_control_sizer:add(effect_add, 0, 0, "EXPAND")

	local effect_remove = EWS:Button(panel, "-->", "", "BU_EXACTFIT,NO_BORDER")

	environment_effect_control_sizer:add(effect_remove, 0, 0, "EXPAND")
	effect_add:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "add_effect"))
	effect_remove:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "remove_effect"))
	environment_effect_sizer:add(environment_active_effect_sizer, 0, 0, "EXPAND")
	environment_effect_sizer:add(environment_effect_control_sizer, 0, 0, "ALIGN_CENTER_VERTICAL")
	environment_effect_sizer:add(environment_effect_list_sizer, 0, 0, "EXPAND")
	panel_sizer:add(environment_effect_sizer, 0, 0, "EXPAND")
	self:build_tab("Effects")
end

function CoreEnvEditor:_move_selected_items(src, dst, valid_items)
	local items = src:selected_items()
	local dst_items = {}
	local count = dst:item_count()

	for i = 0, count - 1 do
		table.insert(dst_items, dst:get_item_data(i))
	end

	for i = #items, 1, -1 do
		local src_index = items[i]
		local data = src:get_item_data(src_index)

		if (not valid_items or valid_items and table.contains(valid_items, data)) and not table.contains(dst_items, data) then
			local dst_index = dst:append_item(data)

			dst:set_item_data(dst_index, data)
		end

		src:delete_item(src_index)
	end

	dst:sort(function (a, b)
		return b < a and 1 or 0
	end)
	self:_refresh_effect_list()
end

function CoreEnvEditor:_refresh_effect_list()
	local active_effects = {}
	local count = self._active_effect_list:item_count()

	for i = 0, count - 1 do
		table.insert(active_effects, self._active_effect_list:get_item_data(i))
	end

	self._environment_effects = active_effects

	table.sort(self._environment_effects)
	managers.environment_effects:set_active_effects(self._environment_effects)
end

function CoreEnvEditor:set_effect_data(active_effects)
	local all_effects = managers.environment_effects:effects_names()

	table.sort(all_effects)
	table.remove_condition(all_effects, function (effect)
		return table.contains(active_effects, effect)
	end)
	popuplate_list(self._effect_list, all_effects)
	popuplate_list(self._active_effect_list, active_effects)
end

function CoreEnvEditor:add_effect()
	self:_move_selected_items(self._effect_list, self._active_effect_list)
end

function CoreEnvEditor:remove_effect()
	self:_move_selected_items(self._active_effect_list, self._effect_list, managers.environment_effects:effects_names())
end
