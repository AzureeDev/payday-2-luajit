CoreEnvEditor = CoreEnvEditor or class()

function CoreEnvEditor:create_interface()
	local gui = self:add_sky_param("sun_ray_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Sun color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_sky_param("sun_ray_color_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Sun intensity", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "fog_start_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Fog start color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "fog_far_low_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Fog far low color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "fog_min_range", SingelSlider:new(self, self:get_tab("Global illumination"), "Fog min range", nil, 0, 5000, 1, 1))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "fog_max_range", SingelSlider:new(self, self:get_tab("Global illumination"), "Fog max range", nil, 0, 500000, 1, 1))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "fog_max_density", SingelSlider:new(self, self:get_tab("Global illumination"), "Fog max density", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "sky_top_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Ambient top color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "sky_top_color_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Ambient top scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "sky_bottom_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Ambient bottom color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "sky_bottom_color_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Ambient bottom scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "ambient_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Ambient color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "ambient_color_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Ambient color scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "ambient_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Ambient scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "ambient_falloff_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Ambient falloff scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "deferred_lighting", "apply_ambient", "effect_light_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Effect lighting scale", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_underlay_param("sky", "color0", EnvEdColorBox:new(self, self:get_tab("Skydome"), "Color top"))

	self:add_gui_element(gui, "Skydome", "Sky")

	gui = self:add_underlay_param("sky", "color0_scale", SingelSlider:new(self, self:get_tab("Skydome"), "Color top scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Skydome", "Sky")

	gui = self:add_underlay_param("sky", "color2", EnvEdColorBox:new(self, self:get_tab("Skydome"), "Color low"))

	self:add_gui_element(gui, "Skydome", "Sky")

	gui = self:add_underlay_param("sky", "color2_scale", SingelSlider:new(self, self:get_tab("Skydome"), "Color low scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Skydome", "Sky")

	local gui = self:add_sky_param("underlay", PathBox:new(self, self:get_tab("Skydome"), "Underlay"))

	self:add_gui_element(gui, "Skydome", "Sky")

	gui = self:add_sky_param("global_texture", DBPickDialog:new(self, self:get_tab("Skydome"), "Global cubemap", "texture"))

	self:add_gui_element(gui, "Skydome", "Sky")

	gui = self:add_sky_param("global_world_overlay_texture", DBPickDialog:new(self, self:get_tab("Global textures"), "Global world overlay texture", "texture"))

	self:add_gui_element(gui, "Global textures", "World")

	gui = self:add_sky_param("global_world_overlay_mask_texture", DBPickDialog:new(self, self:get_tab("Global textures"), "Global world overlay mask texture", "texture"))

	self:add_gui_element(gui, "Global textures", "World")
end

function CoreEnvEditor:create_simple_interface()
end
