core:import("CoreEnvironmentFeeder")

ShadowBlock = ShadowBlock or CoreClass.class()

function ShadowBlock:init()
	self._parameters = {}
end

function ShadowBlock:map()
	return self._parameters
end

function ShadowBlock:set(key, value)
	self._parameters[key] = value
end

function ShadowBlock:get(key)
	return self._parameters[key]
end

CoreEnvEditor = CoreEnvEditor or class()

function CoreEnvEditor:init_shadow_tab()
	self._shadow_blocks = {}
	self._shadow_params = {}

	self:create_shadow_tab()
	self:parse_shadow_data()

	self._debug_pen = Draw:pen()
end

function CoreEnvEditor:load_shadow_data(block)
	for k, v in pairs(block:map()) do
		local param = self._shadow_params[k]

		if param then
			param:set_value(v)
		end
	end
end

function CoreEnvEditor:parse_shadow_data()
	local values = {
		slice0 = managers.viewport:get_environment_value(self._env_path, CoreEnvironmentFeeder.PostShadowSlice0Feeder.DATA_PATH_KEY),
		slice1 = managers.viewport:get_environment_value(self._env_path, CoreEnvironmentFeeder.PostShadowSlice1Feeder.DATA_PATH_KEY),
		slice2 = managers.viewport:get_environment_value(self._env_path, CoreEnvironmentFeeder.PostShadowSlice2Feeder.DATA_PATH_KEY),
		slice3 = managers.viewport:get_environment_value(self._env_path, CoreEnvironmentFeeder.PostShadowSlice3Feeder.DATA_PATH_KEY),
		shadow_slice_overlap = managers.viewport:get_environment_value(self._env_path, CoreEnvironmentFeeder.PostShadowSliceOverlapFeeder.DATA_PATH_KEY),
		shadow_slice_depths = managers.viewport:get_environment_value(self._env_path, CoreEnvironmentFeeder.PostShadowSliceDepthsFeeder.DATA_PATH_KEY)
	}
	local block = self:convert_to_block(values)
	self._shadow_blocks[self._env_path] = block

	self:load_shadow_data(block)
end

function CoreEnvEditor:set_params_enabled(b)
	for _, v in pairs(self._shadow_params) do
		cat_print("debug", "enabling " .. _)
		v._slider:set_enabled(b)
	end
end

function CoreEnvEditor:clear_param_sliders()
	for k, v in pairs(self._shadow_params) do
		v:set_value(1)
	end
end

function CoreEnvEditor:serialize(str)
	for k, v in pairs(self._shadow_params) do
		self._shadow_blocks[str]:set(k, v:get_value())
	end
end

function CoreEnvEditor:convert_to_block(values)
	local block = ShadowBlock:new()

	block:set("d0", values.shadow_slice_depths.x)
	block:set("d1", values.shadow_slice_depths.y)
	block:set("d2", values.shadow_slice_depths.z)
	block:set("d3", values.slice3.y)
	block:set("o1", values.shadow_slice_overlap.x)
	block:set("o2", values.shadow_slice_overlap.y)
	block:set("o3", values.shadow_slice_overlap.z)

	return block
end

function CoreEnvEditor:shadow_feed_params(feed_params)
	local interface_params = self._posteffect.post_processors.shadow_processor.effects.shadow_rendering.modifiers.shadow_modifier.params
	local fov_ratio = managers.environment_controller:fov_ratio()
	local d0 = interface_params.d0:get_value() * fov_ratio
	local d1 = interface_params.d1:get_value() * fov_ratio
	local d2 = interface_params.d2:get_value() * fov_ratio
	local d3 = interface_params.d3:get_value() * fov_ratio
	local o1 = interface_params.o1:get_value() * fov_ratio
	local o2 = interface_params.o2:get_value() * fov_ratio
	local o3 = interface_params.o3:get_value() * fov_ratio
	local s0 = Vector3(0, d0, 0)
	local s1 = Vector3(d0 - o1, d1, 0)
	local s2 = Vector3(d1 - o2, d2, 0)
	local s3 = Vector3(d2 - o3, d3, 0)
	local shadow_slice_depths = Vector3(d0, d1, d2)
	local shadow_slice_overlaps = Vector3(o1, o2, o3)
	feed_params.slice0 = s0
	feed_params.slice1 = s1
	feed_params.slice2 = s2
	feed_params.slice3 = s3
	feed_params.shadow_slice_depths = shadow_slice_depths
	feed_params.shadow_slice_overlap = shadow_slice_overlaps

	return feed_params
end

function CoreEnvEditor:create_shadow_tab()
	local panel = EWS:Panel(self._main_notebook, "", "")
	local panel_box = EWS:BoxSizer("VERTICAL")
	local scrolled_window = EWS:ScrolledWindow(panel, "", "VSCROLL")

	scrolled_window:set_scroll_rate(Vector3(0, 1, 0))
	scrolled_window:set_virtual_size_hints(Vector3(0, 0, 0), Vector3(1, -1, -1))
	scrolled_window:set_virtual_size(Vector3(200, 2000, 0))

	local box = EWS:BoxSizer("VERTICAL")
	local settings_box = EWS:StaticBoxSizer(scrolled_window, "VERTICAL", "Settings")
	self._shadow_params.d0 = self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "d0", SingelSlider:new(self, scrolled_window, "First slice depth start", nil, 1, 10000, 1, 1, true))

	settings_box:add(self._shadow_params.d0._box, 0, 0, "EXPAND")

	self._shadow_params.d1 = self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "d1", SingelSlider:new(self, scrolled_window, "Second slice depth start", nil, 1, 10000, 1, 1, true))

	settings_box:add(self._shadow_params.d1._box, 0, 0, "EXPAND")

	self._shadow_params.d2 = self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "d2", SingelSlider:new(self, scrolled_window, "Third slice depth start", nil, 1, 10000, 1, 1, true))

	settings_box:add(self._shadow_params.d2._box, 0, 0, "EXPAND")

	self._shadow_params.d3 = self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "d3", SingelSlider:new(self, scrolled_window, "Third slice depth end", nil, 1, 50000, 1, 1, true))

	settings_box:add(self._shadow_params.d3._box, 0, 0, "EXPAND")

	self._shadow_params.o1 = self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "o1", SingelSlider:new(self, scrolled_window, "Blend overlap between first and second shadow slice", nil, 1, 10000, 1, 1, true))

	settings_box:add(self._shadow_params.o1._box, 0, 0, "EXPAND")

	self._shadow_params.o2 = self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "o2", SingelSlider:new(self, scrolled_window, "Blend overlap between second and third shadow slice", nil, 1, 10000, 1, 1, true))

	settings_box:add(self._shadow_params.o2._box, 0, 0, "EXPAND")

	self._shadow_params.o3 = self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "o3", SingelSlider:new(self, scrolled_window, "Blend overlap between third and forth shadow slice", nil, 1, 10000, 1, 1, true))

	settings_box:add(self._shadow_params.o3._box, 0, 0, "EXPAND")
	self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "slice0", DummyWidget:new())
	self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "slice1", DummyWidget:new())
	self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "slice2", DummyWidget:new())
	self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "slice3", DummyWidget:new())
	self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "shadow_slice_overlap", DummyWidget:new())
	self:add_post_processors_param("shadow_processor", "shadow_rendering", "shadow_modifier", "shadow_slice_depths", DummyWidget:new())
	box:add(settings_box, 0, 0, "EXPAND")
	scrolled_window:set_sizer(box)
	panel_box:add(scrolled_window, 1, 0, "EXPAND")
	panel:set_sizer(panel_box)
	self._main_notebook:add_page(panel, "Shadow slices", false)
end
