CoreParticleEditorVisualizers = CoreParticleEditorVisualizers or class()

function CoreParticleEditorVisualizers:create_billboard()
	local visualizer = CoreEffectStackMember:new("billboard", "visualizer", "Billboard")

	visualizer:set_description("Visualizes particles using quads with different alignment and blending schemes and a set texture")

	local help = "Texture used assigned to the billboards."

	visualizer:add_property(CoreEffectProperty:new("texture", "texture", "core/textures/default_texture_df", help))

	local intensities = LightIntensityDB:list()
	local defintensity = ""
	local p = CoreEffectProperty:new("intensity", "value_list", defintensity, "Intensity of billboards - choose a template that corresponds closest to the intensity range you want.\nTo scale the intensity over time, use the color.")

	p:add_value("")

	for _, i in ipairs(intensities) do
		p:add_value(i:s())
	end

	visualizer:add_property(p)

	help = [[
Determines alignment type of billboard:
camera_facing - billboard is always facing camera position, use this for ex. smoke particles
normal_locked - billboard rotates around particle normal trying to face camera as much as possible, use this for ex. spark particles
axialz_locked - billboard rotates around world Z trying to face camera as much as possible
normal_facing - billboard faces particle normal
screen_aligned - billboard faces camera near clip plane
NOTE: for screen_aligned billboards you will want to set the atom to never cull,
and play it in (0,0,0) (move the gizmo using the Move To Origo button)]]
	p = CoreEffectProperty:new("billboard_type", "value_list", "camera_facing", help)

	p:add_value("camera_facing")
	p:add_value("normal_locked")
	p:add_value("axialz_locked")
	p:add_value("normal_facing")
	p:add_value("screen_aligned")
	p:add_value("rotation_aligned")
	visualizer:add_property(p)

	help = "If positions are read, this channel will be used"
	local p = CoreEffectProperty:new("rotation_channel", "value_list", "world_rotation", help)

	p:add_value("rotation")
	p:add_value("world_rotation")
	visualizer:add_property(p)

	help = [[
Determines how billboard is blended against the background:
add - color becomes color of destination + billboard alpha * billboard color
normal - color becomes color of destination * (1 - billboard alpha) + billboard alpha * billboard color
premultiplied - color becomes color of destination + billboard color
add_no_alpha - color becomes color of destination + billboard color]]
	p = CoreEffectProperty:new("blend_mode", "value_list", "normal", help)

	p:add_value("normal")
	p:add_value("add")
	p:add_value("premultiplied")
	p:add_value("add_no_alpha")

	p._visible = false

	visualizer:add_property(p)

	help = "Determines method used to render billboard:\n\tHalo - no lighting"
	p = CoreEffectProperty:new("render_template", "value_list", "effect_op", help)

	p:add_value("effect_op")
	p:add_value("effect_op_halo")
	p:add_value("effect_op_add")
	p:add_value("effect_op_glow")
	p:add_value("effect_blood")
	p:add_value("effect_money")
	p:add_value("effect_money_menu")
	p:add_value("effect_geometry_fade_out")
	p:add_value("effect_geometry_fade_out_add")
	p:add_value("heat_shimmer")
	visualizer:add_property(p)

	help = "The uv origo of the billboard - billboard will be centered on this point when rendered"

	visualizer:add_property(CoreEffectProperty:new("origo", "vector2", "0.5 0.5", help))

	help = "Determines if a different age is assigned to each particle - this requires an AGE channel to be created.\nIf this is not set, age is age of atom."

	visualizer:add_property(CoreEffectProperty:new("per_particle_age", "boolean", "false", help))

	help = [[
Size of particle
constant - use constant value
keys - use key curve over time
channel - read from channel
scaled_channel - read from channel, scale with key curve]]
	p = CoreEffectProperty:new("size_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("size", "vector2", "100 100", "Constant size of particle"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local size_keys = CoreEffectProperty:new("size_keys", "keys", "", "")

	size_keys:set_key_type("vector2")
	size_keys:add_key({
		v = "100 100",
		t = 0
	})
	size_keys:set_min_max_keys(1, 4)
	size_keys:set_presets({
		{
			"Grow",
			{
				{
					0,
					Vector3(100, 100, 0)
				},
				{
					2,
					Vector3(200, 200, 0)
				}
			}
		},
		{
			"Shrink",
			{
				{
					0,
					Vector3(200, 200, 0)
				},
				{
					2,
					Vector3(100, 100, 0)
				}
			}
		},
		{
			"Grow And Shrink",
			{
				{
					0,
					Vector3(100, 100, 0)
				},
				{
					1,
					Vector3(200, 200, 0)
				},
				{
					2,
					Vector3(100, 100, 0)
				}
			}
		}
	})
	p:add_variant("keys", size_keys)

	local size_scale_keys = CoreEffectProperty:new("size_scale_keys", "keys", "", "")

	size_scale_keys:set_key_type("vector2")
	size_scale_keys:add_key({
		v = "1 1",
		t = 0
	})
	size_scale_keys:set_min_max_keys(1, 4)
	p:add_variant("scaled_channel", size_scale_keys)
	visualizer:add_property(p)

	help = [[
Color of particle
constant - use constant value
keys - use key curve over time
channel - read from channel
scaled_channel - read from channel, scale with key curve]]
	p = CoreEffectProperty:new("color_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("color", "color", "255 255 255", "Constant color of particle"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local color_keys = CoreEffectProperty:new("color_keys", "keys", "", "")

	color_keys:set_key_type("color")
	color_keys:add_key({
		v = "255 255 255",
		t = 0
	})
	color_keys:set_min_max_keys(1, 4)
	p:add_variant("keys", color_keys)

	local color_scale_keys = CoreEffectProperty:new("color_scale_keys", "keys", "", "")

	color_scale_keys:set_key_type("vector3")
	color_scale_keys:add_key({
		v = "1 1 1",
		t = 0
	})
	color_scale_keys:set_min_max_keys(1, 4)
	p:add_variant("scaled_channel", color_scale_keys)
	visualizer:add_property(p)

	help = [[
Opacity of particle
constant - use constant value
keys - use key curve over time
channel - read from channel
scaled_channel - read from channel, scale with key curve]]
	p = CoreEffectProperty:new("opacity_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("opacity", "opacity", "255", "Constant opacity of particle"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local opacity_keys = CoreEffectProperty:new("opacity_keys", "keys", "", "")

	opacity_keys:set_key_type("opacity")
	opacity_keys:add_key({
		v = "255",
		t = 0
	})
	opacity_keys:set_min_max_keys(1, 4)
	p:add_variant("keys", opacity_keys)

	local opacity_scale_keys = CoreEffectProperty:new("opacity_scale_keys", "keys", "", "")

	opacity_scale_keys:set_key_type("float")
	opacity_scale_keys:add_key({
		v = "1",
		t = 0
	})
	opacity_scale_keys:set_min_max_keys(1, 4)
	p:add_variant("scaled_channel", opacity_scale_keys)
	visualizer:add_property(p)

	help = [[
Rotation of particle
constant - use constant value
keys - use key curve over time
channel - read from channel
scaled_channel - read from channel, scale with key curve]]
	p = CoreEffectProperty:new("rotation_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("rotation", "angle", "0", "Constant rotation of particle"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local rotation_keys = CoreEffectProperty:new("rotation_keys", "keys", "", "")

	rotation_keys:set_key_type("angle")
	rotation_keys:add_key({
		v = "0",
		t = 0
	})
	rotation_keys:set_min_max_keys(1, 4)
	rotation_keys:set_presets({
		{
			"Spin Then Pan",
			{
				{
					0,
					Vector3(0, 0, 0)
				},
				{
					1,
					Vector3(3600, 0, 0)
				}
			}
		},
		{
			"Spin",
			{
				{
					0,
					Vector3(0, 0, 0)
				},
				{
					2,
					Vector3(7200, 0, 0)
				}
			}
		},
		{
			"Spin Fast Then Slow",
			{
				{
					0,
					Vector3(0, 0, 0)
				},
				{
					1,
					Vector3(3600, 0, 0)
				},
				{
					2,
					Vector3(5400, 0, 0)
				}
			}
		}
	})
	p:add_variant("keys", rotation_keys)

	local rotation_scale_keys = CoreEffectProperty:new("rotation_scale_keys", "keys", "", "")

	rotation_scale_keys:set_key_type("float")
	rotation_scale_keys:add_key({
		v = "1",
		t = 0
	})
	rotation_scale_keys:set_min_max_keys(1, 4)
	p:add_variant("scaled_channel", rotation_scale_keys)
	visualizer:add_property(p)

	help = "Axis around which to apply angular rotation.\nThis parameter ONLY APPLIES for rotation_aligned billboards."

	visualizer:add_property(CoreEffectProperty:new("rotation_axis", "vector3", "0 0 1", help))

	help = "Size of uv rectangle referenced by billboard.\nIf you are using an uv animation controller, this is the uv size of the frame."

	visualizer:add_property(CoreEffectProperty:new("uv_size", "vector2", "1 1", help))

	help = [[
UV offset of particle
constant - use constant value
keys - uv animation, stepping between the uv offsets of each frame over time
channel - read from channel]]
	p = CoreEffectProperty:new("uv_offset_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("uv_offset", "vector2", "0 0", "const uv offset of particles"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local uv_animation = CoreEffectPropertyContainer:new("uv_animation")

	uv_animation:set_description("Steps between uv offsets within a texture containing all the frames of an animation.")
	uv_animation:add_property(CoreEffectProperty:new("frame_start", "vector2", "0 0", "UV offset of first frame"))
	uv_animation:add_property(CoreEffectProperty:new("primary_step_direction", "string", "+x", "Primary step direction"))
	uv_animation:add_property(CoreEffectProperty:new("secondary_step_direction", "string", "+y", "Secondary step direction"))
	uv_animation:add_property(CoreEffectProperty:new("num_frames", "int", "16", "Number of frames contained in texture"))

	local q = CoreEffectProperty:new("fps", "float", "30", "fps that animation should play at")

	q:set_range(1, 100000)
	uv_animation:add_property(q)
	uv_animation:add_property(CoreEffectProperty:new("loop", "boolean", "false", "If set, animation will loop back to first frame"))

	local uv_animation_prop = CoreEffectProperty:new("", "compound", "")

	uv_animation_prop:set_compound_container(uv_animation)
	uv_animation_prop:set_save_to_child(false)
	p:add_variant("keys", uv_animation_prop)
	visualizer:add_property(p)

	return visualizer
end

function CoreParticleEditorVisualizers:create_trail()
	local visualizer = CoreEffectStackMember:new("trail", "visualizer", "Trail")

	visualizer:set_description("Visualizes particles using quads with different alignment and blending schemes and a set texture")
	visualizer:add_property(CoreEffectProperty:new("size", "int", "1", "The number of segments in the trail"))

	local p = CoreEffectProperty:new("trail_type", "value_list", "custom_aligned", "If set to normal_locked, trail segments will always try to face camera while remaining locked around each particle Z")

	p:add_value("custom_aligned")
	p:add_value("normal_locked")
	visualizer:add_property(p)
	visualizer:add_property(CoreEffectProperty:new("tesselation", "int", "3", "The number of segments created in between segments by interpolation"))
	visualizer:add_property(CoreEffectProperty:new("curvature", "percentage", "0.1", "Determines how much particle rotation at segment points influence curve interpolation, larger values will result in wilder curves - curve becomes unstable for values > 0.5"))
	visualizer:add_property(CoreEffectProperty:new("tile_uv", "boolean", "false", "If set, uv is tiled between each segment, if not set, uv is stretched across length of trail"))
	visualizer:add_property(CoreEffectProperty:new("tiles_per_meter", "float", "1", "If uv is tiling, it will tile with this interval"))

	local help = "Texture used assigned to the billboards."

	visualizer:add_property(CoreEffectProperty:new("texture", "texture", "core/texture/default_texture_df", help))

	local intensities = LightIntensityDB:list()
	local defintensity = ""
	p = CoreEffectProperty:new("intensity", "value_list", defintensity, "Intensity of billboards - choose a template that corresponds closest to the intensity range you want.\nTo scale the intensity over time, use the color.")

	p:add_value("")

	for _, i in ipairs(intensities) do
		p:add_value(i:s())
	end

	visualizer:add_property(p)

	help = [[
Determines how billboard is blended against the background:
add - color becomes color of destination + billboard alpha * billboard color
normal - color becomes color of destination * (1 - billboard alpha) + billboard alpha * billboard color
premultiplied - color becomes color of destination + billboard color
add_no_alpha - color becomes color of destination + billboard color]]
	p = CoreEffectProperty:new("blend_mode", "value_list", "normal", help)

	p:add_value("normal")
	p:add_value("add")
	p:add_value("premultiplied")
	p:add_value("add_no_alpha")

	p._visible = false

	visualizer:add_property(p)

	help = "Determines method used to render billboard:\n\tHalo - no lighting"
	p = CoreEffectProperty:new("render_template", "value_list", "effect_op", help)

	p:add_value("effect_op")
	p:add_value("effect_op_halo")
	p:add_value("effect_op_add")
	p:add_value("effect_op_glow")
	p:add_value("effect_blood")
	p:add_value("effect_money")
	p:add_value("effect_money_menu")
	p:add_value("effect_geometry_fade_out")
	p:add_value("effect_geometry_fade_out_add")
	p:add_value("heat_shimmer")
	visualizer:add_property(p)

	help = "Determines if a different age is assigned to each particle - this requires an AGE channel to be created.\nIf this is not set, age is age of atom."

	visualizer:add_property(CoreEffectProperty:new("per_particle_age", "boolean", "false", help))

	help = [[
Color of particle
constant - use constant value
keys - use key curve over time
channel - read from channel
scaled_channel - read from channel, scale with key curve]]
	p = CoreEffectProperty:new("color_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("color", "color", "255 255 255", "Constant color of particle"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local color_keys = CoreEffectProperty:new("color_keys", "keys", "", "")

	color_keys:set_key_type("color")
	color_keys:add_key({
		v = "255 255 255",
		t = 0
	})
	color_keys:set_min_max_keys(1, 4)
	p:add_variant("keys", color_keys)

	local color_scale_keys = CoreEffectProperty:new("color_scale_keys", "keys", "", "")

	color_scale_keys:set_key_type("vector3")
	color_scale_keys:add_key({
		v = "1 1 1",
		t = 0
	})
	color_scale_keys:set_min_max_keys(1, 4)
	p:add_variant("scaled_channel", color_scale_keys)
	visualizer:add_property(p)

	local color_multiplier_keys = CoreEffectProperty:new("color_multiplier_keys", "keys", "", "Multiplier for color over length")

	color_multiplier_keys:set_key_type("vector3")
	color_multiplier_keys:add_key({
		v = "1 1 1",
		t = 0
	})
	color_multiplier_keys:set_min_max_keys(1, 4)
	visualizer:add_property(color_multiplier_keys)

	help = [[
Opacity of particle
constant - use constant value
keys - use key curve over time
channel - read from channel
scaled_channel - read from channel, scale with key curve]]
	p = CoreEffectProperty:new("opacity_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("opacity", "opacity", "255", "Constant opacity of particle"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local opacity_keys = CoreEffectProperty:new("opacity_keys", "keys", "", "")

	opacity_keys:set_key_type("opacity")
	opacity_keys:add_key({
		v = "255",
		t = 0
	})
	opacity_keys:set_min_max_keys(1, 4)
	p:add_variant("keys", opacity_keys)

	local opacity_scale_keys = CoreEffectProperty:new("opacity_scale_keys", "keys", "", "")

	opacity_scale_keys:set_key_type("float")
	opacity_scale_keys:add_key({
		v = "1",
		t = 0
	})
	opacity_scale_keys:set_min_max_keys(1, 4)
	p:add_variant("scaled_channel", opacity_scale_keys)
	visualizer:add_property(p)

	local opacity_multiplier_keys = CoreEffectProperty:new("opacity_multiplier_keys", "keys", "", "Multiplier for opacity over length")

	opacity_multiplier_keys:set_key_type("float")
	opacity_multiplier_keys:add_key({
		v = "1",
		t = 0
	})
	opacity_multiplier_keys:set_min_max_keys(1, 4)
	visualizer:add_property(opacity_multiplier_keys)

	help = [[
Width of trail
constant - use constant value
keys - use key curve over length of trail
channel - read from channel
scaled_channel - read from channel, scale over length with key curve]]
	p = CoreEffectProperty:new("width_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("width", "float", "50", "Constant width of trail"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local width_keys = CoreEffectProperty:new("width_keys", "keys", "", "")

	width_keys:set_key_type("float")
	width_keys:add_key({
		v = "50",
		t = 0
	})
	width_keys:set_min_max_keys(1, 4)
	p:add_variant("keys", width_keys)

	local width_scale_keys = CoreEffectProperty:new("width_scale_keys", "keys", "", "")

	width_scale_keys:set_key_type("float")
	width_scale_keys:add_key({
		v = "1",
		t = 0
	})
	width_scale_keys:set_min_max_keys(1, 4)
	p:add_variant("scaled_channel", width_scale_keys)
	visualizer:add_property(p)

	help = "Size of uv rectangle referenced by billboard.\nIf you are using an uv animation controller, this is the uv size of the frame."

	visualizer:add_property(CoreEffectProperty:new("uv_size", "vector2", "1 1", help))

	help = [[
UV offset of particle
constant - use constant value
keys - uv animation, stepping between the uv offsets of each frame over time
channel - read from channel]]
	p = CoreEffectProperty:new("uv_offset_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("uv_offset", "vector2", "0 0", "const uv offset of particles"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local uv_animation = CoreEffectPropertyContainer:new("uv_animation")

	uv_animation:set_description("Steps between uv offsets within a texture containing all the frames of an animation.")
	uv_animation:add_property(CoreEffectProperty:new("frame_start", "vector2", "0 0", "UV offset of first frame"))
	uv_animation:add_property(CoreEffectProperty:new("primary_step_direction", "string", "+x", "Primary step direction"))
	uv_animation:add_property(CoreEffectProperty:new("secondary_step_direction", "string", "+y", "Secondary step direction"))
	uv_animation:add_property(CoreEffectProperty:new("num_frames", "int", "16", "Number of frames contained in texture"))
	uv_animation:add_property(CoreEffectProperty:new("fps", "float", "30", "fps that animation should play at"))
	uv_animation:add_property(CoreEffectProperty:new("loop", "boolean", "false", "If set, animation will loop back to first frame"))

	local uv_animation_prop = CoreEffectProperty:new("", "compound", "")

	uv_animation_prop:set_compound_container(uv_animation)
	uv_animation_prop:set_save_to_child(false)
	p:add_variant("keys", uv_animation_prop)
	visualizer:add_property(p)

	return visualizer
end

function CoreParticleEditorVisualizers:create_light()
	local visualizer = CoreEffectStackMember:new("light", "visualizer", "Light")

	visualizer:set_description("Visualizes particles using lights with positions aligned to the particles")

	local help = "Determines if a different age is assigned to each particle - this requires an AGE channel to be created.\nIf this is not set, age is age of atom."

	visualizer:add_property(CoreEffectProperty:new("per_particle_age", "boolean", "false", help))

	help = "Determines if light casts shadows."

	visualizer:add_property(CoreEffectProperty:new("shadow_caster", "boolean", "false", help))

	help = "Determines if light has specular component."

	visualizer:add_property(CoreEffectProperty:new("specular", "boolean", "false", help))

	help = [[
Color of light
constant - use constant value
keys - use key curve over time
channel - read from channel]]
	local p = CoreEffectProperty:new("color_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("color", "color", "255 255 255", "Constant color of light"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local color_keys = CoreEffectProperty:new("color_keys", "keys", "", "")

	color_keys:set_key_type("color")
	color_keys:add_key({
		v = "255 255 255",
		t = 0
	})
	color_keys:set_min_max_keys(1, 4)
	p:add_variant("keys", color_keys)
	visualizer:add_property(p)

	help = [[
Multiplier of light
constant - use constant value
keys - use key curve over time
channel - read from channel]]
	p = CoreEffectProperty:new("multiplier_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("multiplier", "float", "1", "Constant multiplier of light"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local multiplier_keys = CoreEffectProperty:new("multiplier_keys", "keys", "", "")

	multiplier_keys:set_key_type("float")
	multiplier_keys:add_key({
		v = "1.0",
		t = 0
	})
	multiplier_keys:set_min_max_keys(1, 4)
	p:add_variant("keys", multiplier_keys)
	visualizer:add_property(p)

	help = [[
Far range of light
constant - use constant value
keys - use key curve over time
channel - read from channel]]
	p = CoreEffectProperty:new("far_range_input", "variant", "constant", help)

	p:add_variant("constant", CoreEffectProperty:new("far_range", "float", "100", "Constant far range of light"))
	p:add_variant("channel", CoreEffectProperty:new("", "null", "", ""))

	local far_range_keys = CoreEffectProperty:new("far_range_keys", "keys", "", "")

	far_range_keys:set_key_type("float")
	far_range_keys:add_key({
		v = "100",
		t = 0
	})
	far_range_keys:set_min_max_keys(1, 4)
	p:add_variant("keys", far_range_keys)
	visualizer:add_property(p)

	return visualizer
end

function CoreParticleEditorVisualizers:create_model()
	local visualizer = CoreEffectStackMember:new("model", "visualizer", "Model")

	visualizer:set_description("Visualizes particles using models picked from a unit")

	local help = "Name of model/diesel database entry"

	visualizer:add_property(CoreEffectProperty:new("model", "model", "core/units/widgets", help))

	local help = "Name of object/mesh in model."

	visualizer:add_property(CoreEffectProperty:new("object", "object", "g_z", help))

	local help = "Name of material config."

	visualizer:add_property(CoreEffectProperty:new("material_config", "material_config", "core/material_configs/widgets_materials", help))

	return visualizer
end
