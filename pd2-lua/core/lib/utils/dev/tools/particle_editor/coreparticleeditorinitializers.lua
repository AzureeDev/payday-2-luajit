CoreParticleEditorInitializers = CoreParticleEditorInitializers or class()

function CoreParticleEditorInitializers:create_boxrandomposition()
	local initializer = CoreEffectStackMember:new("boxrandomposition", "initializer", "Position (Box Random)")

	initializer:set_description("Initializes particle positions randomly within a given box.")

	local help = [[
Determines how positions are treated:
relative - Positions are rotated with effect rotation
world - Positions are not rotated

Positions are always offsetted with effect position.]]
	local p = CoreEffectProperty:new("relative", "value_list", "effect", help)

	p:add_value("effect")
	p:add_value("world")
	initializer:add_property(p)

	help = "Box inside which particle positions will be randomly generated.\nCoordinates are in centimeters."
	p = CoreEffectProperty:new("box", "box", "", help)

	p:set_min_max(Vector3(-1, -1, -1), Vector3(1, 1, 1))
	initializer:add_property(p)

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomvelocity()
	local initializer = CoreEffectStackMember:new("boxrandomvelocity", "initializer", "Velocity (Box Random)")

	initializer:set_description("Initializes particle velocities randomly within a given box.")

	local help = [[
Determines how velocities are treated:
effect - Velocities are rotated with effect rotation
world - Velocities are not rotated

Velocities are always offsetted with effect spawn velocity.]]
	local p = CoreEffectProperty:new("relative", "value_list", "effect", help)

	p:add_value("effect")
	p:add_value("world")
	initializer:add_property(p)

	help = "Box inside which particle velocities will be randomly generated.\nCoordinates are in centimeters per second and relative to effect spawn point and rotation."
	p = CoreEffectProperty:new("box", "box", "", help)

	p:set_min_max(Vector3(-100, -100, -100), Vector3(100, 100, 100))
	initializer:add_property(p)

	return initializer
end

function CoreParticleEditorInitializers:create_centervelocity()
	local initializer = CoreEffectStackMember:new("centervelocity", "initializer", "Velocity (To/From Center)")

	initializer:set_description("Initializes particle velocities with a vector pointing to/from a point in space.")

	local help = "Determines what position channel to read from:\nlocal - local positions\nworld - world position"
	local p = CoreEffectProperty:new("channel", "value_list", "world", help)

	p:add_value("local")
	p:add_value("world")
	initializer:add_property(p)

	p = CoreEffectProperty:new("center", "vector3", "0 0 0", "Position (relative to effect) for which to direct velocities to/from")

	initializer:add_property(p)

	help = "Direct velocities to or from center"
	p = CoreEffectProperty:new("direction", "value_list", "from", help)

	p:add_value("to")
	p:add_value("from")
	initializer:add_property(p)

	p = CoreEffectProperty:new("min", "float", "100", "Minimum velocity (in cm/s)")

	initializer:add_property(p)

	p = CoreEffectProperty:new("max", "float", "100", "Maximum velocity (in cm/s)")

	initializer:add_property(p)

	p = CoreEffectProperty:new("jitter", "float", "10", "Random jitter added to velocity (in cm/s)")

	initializer:add_property(p)

	return initializer
end

function CoreParticleEditorInitializers:create_boxevenposition()
	local initializer = CoreEffectStackMember:new("boxevenposition", "initializer", "Position (Box Even Distribution)")

	initializer:set_description("Initializes particle positions evenly distributed within a given box.\nMay initialize positions outside box if the number of particles is not evenly dividable with the proportions of the box.")

	local help = [[
Determines how positions are treated:
relative - Positions are rotated with effect rotation
world - Positions are not rotated

Positions are always offsetted with effect position.]]
	local p = CoreEffectProperty:new("relative", "value_list", "effect", help)

	p:add_value("effect")
	p:add_value("world")
	initializer:add_property(p)

	help = "Box inside which particle positions will be generated.\nCoordinates are in centimeters and relative to effect spawn point and rotation."
	p = CoreEffectProperty:new("box", "box", "", help)

	p:set_min_max(Vector3(-1, -1, -1), Vector3(1, 1, 1))
	initializer:add_property(p)

	return initializer
end

function CoreParticleEditorInitializers:create_trail()
	local initializer = CoreEffectStackMember:new("trail", "initializer", "Trail")

	initializer:add_property(CoreEffectProperty:new("size", "int", "3", "Number of segments in trail"))

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomrotation()
	local initializer = CoreEffectStackMember:new("boxrandomrotation", "initializer", "Rotation (Box Random)")

	initializer:set_description("Initializes particle rotations to random values, with the normal within a specified box and a random angle around the normal.")

	local help = "Determines how rotations are treated:\nrelative - Rotations are rotated with effect rotation (and output to WORLD_ROTATION channel)\nworld - Rotations are not rotated (and output to ROTATION channel)"
	local p = CoreEffectProperty:new("relative", "value_list", "effect", help)

	p:add_value("effect")
	p:add_value("world")
	initializer:add_property(p)

	help = "Box within which normal will be randomized."
	p = CoreEffectProperty:new("box", "box", "", help)

	p:set_min_max(Vector3(-10, -10, 1), Vector3(10, 10, 1))
	initializer:add_property(p)
	initializer:add_property(CoreEffectProperty:new("min_rot", "float", "0", "Min angle around normal"))
	initializer:add_property(CoreEffectProperty:new("max_rot", "float", "365", "Max angle around normal"))

	return initializer
end

function CoreParticleEditorInitializers:create_constantage()
	local initializer = CoreEffectStackMember:new("constantage", "initializer", "Age (Constant)")

	initializer:set_description("Initializes particle ages to specified value.\nThis initializer is useful if you want to create a set of particles that are very old, for initializing\neffect surface type effects.")

	local help = "Age that particles should have assigned (in seconds)."

	initializer:add_property(CoreEffectProperty:new("age", "time", "99999", help))

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomage()
	local initializer = CoreEffectStackMember:new("boxrandomage", "initializer", "Age (Box Random)")

	initializer:set_description("Initializes particle ages within specified range.")
	initializer:add_property(CoreEffectProperty:new("min", "time", "0", "Lower bound of time value"))
	initializer:add_property(CoreEffectProperty:new("max", "time", "1", "Upper bound of time value"))

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomcolor()
	local initializer = CoreEffectStackMember:new("boxrandomcolor", "initializer", "Color (Box Random)")

	initializer:set_description("Initializes particle colors within a range of colors.")

	local help = "Minimum color."

	initializer:add_property(CoreEffectProperty:new("min", "color", "0 0 0", help))

	help = "Maximum color."

	initializer:add_property(CoreEffectProperty:new("max", "color", "255 255 255", help))

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomcolorgradient()
	local initializer = CoreEffectStackMember:new("boxrandomcolorgradient", "initializer", "Color (Box Random Gradient)")

	initializer:set_description("Initializes particle colors with a base color and randomized gradients of this color.")

	local help = "Color"

	initializer:add_property(CoreEffectProperty:new("color", "color", "255 255 255", help))

	help = "Minimum multiplier for base color"

	initializer:add_property(CoreEffectProperty:new("min", "percentage", "0", help))

	help = "Maximum multiplier for base color"

	initializer:add_property(CoreEffectProperty:new("max", "percentage", "1", help))

	return initializer
end

function CoreParticleEditorInitializers:create_localboxrandomposition()
	local initializer = CoreEffectStackMember:new("localboxrandomposition", "initializer", "Local Position (Box Random)")

	initializer:set_description("Initializes particle positions randomly within a given box.\nThe positions are written to the local position channel, and are not transformed by effect orientation.")

	local help = "Box within which normal will be randomized."
	local p = CoreEffectProperty:new("box", "box", "", help)

	p:set_min_max(Vector3(-1, -1, -1), Vector3(1, 1, 1))
	initializer:add_property(p)

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomangle()
	local initializer = CoreEffectStackMember:new("boxrandomangle", "initializer", "Angle (Box Random)")

	initializer:set_description("Initializes angles randomly using a box distribution.")

	local help = "Minimum angle (degrees)."

	initializer:add_property(CoreEffectProperty:new("min", "float", "0", help))

	help = "Maximum angle (degrees)."

	initializer:add_property(CoreEffectProperty:new("max", "float", "360", help))

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomanglevelocity()
	local initializer = CoreEffectStackMember:new("boxrandomanglevelocity", "initializer", "Angle Velocity (Box Random)")

	initializer:set_description("Initializes angle velocities randomly using a box distribution.")

	local help = "Minimum angle velocity (degrees/s)."

	initializer:add_property(CoreEffectProperty:new("min", "float", "180", help))

	help = "Maximum angle velocity (degrees/s)."

	initializer:add_property(CoreEffectProperty:new("max", "float", "-180", help))

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomopacity()
	local initializer = CoreEffectStackMember:new("boxrandomopacity", "initializer", "Opacity (Box Random)")

	initializer:set_description("Initializes opacities randomly using a box distribution.")

	local help = "Minimum opacity (0 - 255)."

	initializer:add_property(CoreEffectProperty:new("min", "opacity", "0", help))

	help = "Maximum opacity (0 - 255)."

	initializer:add_property(CoreEffectProperty:new("max", "opacity", "255", help))

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomsize()
	local initializer = CoreEffectStackMember:new("boxrandomsize", "initializer", "Size (Box Random)")

	initializer:set_description("Initializes sizes randomly using a box distribution.")

	local help = "Minimum size (cm)."

	initializer:add_property(CoreEffectProperty:new("min", "vector2", "100 100", help))

	help = "Maximum size (cm)."

	initializer:add_property(CoreEffectProperty:new("max", "vector2", "200 200", help))

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomaspectsize()
	local initializer = CoreEffectStackMember:new("boxrandomaspectsize", "initializer", "Size (Box Random Aspect)")

	initializer:set_description("Initializes sizes randomly with a certain aspect using a box distribution.")

	local help = "Base size."

	initializer:add_property(CoreEffectProperty:new("size", "vector2", "100 100", help))

	help = "Min multiplier"

	initializer:add_property(CoreEffectProperty:new("min", "float", "0.5", help))

	help = "Max multiplier"

	initializer:add_property(CoreEffectProperty:new("max", "float", "1.5", help))

	return initializer
end

function CoreParticleEditorInitializers:create_boxrandomuvoffset()
	local initializer = CoreEffectStackMember:new("boxrandomuvoffset", "initializer", "UV Offset (Box Random Frame)")

	initializer:set_description("Initializes uv offsets randomly between frames in a texture.")
	initializer:add_property(CoreEffectProperty:new("uv_size", "vector2", "0.125 0.125", "The UV size of a frame"))
	initializer:add_property(CoreEffectProperty:new("frame_start", "vector2", "0 0", "UV offset of first frame"))
	initializer:add_property(CoreEffectProperty:new("primary_step_direction", "string", "+x", "Primary step direction"))
	initializer:add_property(CoreEffectProperty:new("secondary_step_direction", "string", "+y", "Secondary step direction"))
	initializer:add_property(CoreEffectProperty:new("num_frames", "int", "16", "Number of frames contained in texture"))

	return initializer
end

function CoreParticleEditorInitializers:create_worldtransform()
	local initializer = CoreEffectStackMember:new("worldtransform", "initializer", "Local -> World Transform")

	initializer:set_description("Transforms local positions (and optionally rotations) to world coordinates.")

	local help = "If set, rotation channel will be read and transformed by effect transform into the world rotation channel."

	initializer:add_property(CoreEffectProperty:new("transform_rotations", "boolean", "false", help))

	return initializer
end

function CoreParticleEditorInitializers:create_lightcone()
	local initializer = CoreEffectStackMember:new("lightcone", "initializer", "Light Cone")

	initializer:set_description("Constructs a string of positions along a vector, with associated sizes and opacities. Useful for creating light cones.\nThis initializer will not work very well with atoms of varying size, since the length of the cone will vary with the number of particles.")

	local help = "Vector in local space along which positions will be layed out."

	initializer:add_property(CoreEffectProperty:new("axis", "vector3", "0 0 1", help))

	help = "Distance along axis to place first billboard."

	initializer:add_property(CoreEffectProperty:new("start", "float", "0", help))

	help = "The distance to step between billboards with stepped distance as horizontal axis."
	local distance_keys = CoreEffectProperty:new("distance_keys", "keys", "", help)

	distance_keys:set_key_type("float")
	distance_keys:add_key({
		v = "20",
		t = 0
	})
	distance_keys:set_min_max_keys(1, 4)
	initializer:add_property(distance_keys)

	help = "The size of billboards along distance."
	local size_keys = CoreEffectProperty:new("size_keys", "keys", "", help)

	size_keys:set_key_type("vector2")
	size_keys:add_key({
		v = "100 100",
		t = 0
	})
	size_keys:set_min_max_keys(1, 4)
	initializer:add_property(size_keys)

	help = "The opacity of billboards along distance."
	local opacity_keys = CoreEffectProperty:new("opacity_keys", "keys", "", help)

	opacity_keys:set_key_type("opacity")
	opacity_keys:add_key({
		v = "255",
		t = 0
	})
	opacity_keys:set_min_max_keys(1, 4)
	initializer:add_property(opacity_keys)

	return initializer
end
