CoreParticleEditorSimulators = CoreParticleEditorSimulators or class()

function CoreParticleEditorSimulators:create_velocityintegrator()
	local simulator = CoreEffectStackMember:new("velocityintegrator", "simulator", "Velocity Integrator")

	simulator:set_description("Adds velocity * dt to position.")

	local help = "Determines which position channel integration is performed on:\nworld - world positions are modified\nlocal - local positions are modified."
	local p = CoreEffectProperty:new("channel", "value_list", "world", help)

	p:add_value("world")
	p:add_value("local")
	simulator:add_property(p)

	return simulator
end

function CoreParticleEditorSimulators:create_trail()
	local simulator = CoreEffectStackMember:new("trail", "simulator", "Trail")

	simulator:set_description("Copies position and orientation to buffer")
	simulator:add_property(CoreEffectProperty:new("size", "int", "3", "Number of positions"))

	local p = CoreEffectProperty:new("mode", "variant", "frequency", "Determines mode in which simulator operates:\nIf set to frequency, particle positions and rotations are copied at a set interval\nIf set to distance, particle positions and rotations are copied when distance exceeds a certain threshold")

	p:add_variant("frequency", CoreEffectProperty:new("frequency", "float", "1", "Frequency of position and orientation being copied to buffer"))
	p:add_variant("distance", CoreEffectProperty:new("distance", "float", "100", "Distance required before position and rotation is copied to buffer"))
	simulator:add_property(p)

	return simulator
end

function CoreParticleEditorSimulators:create_scaledvelocityintegrator()
	local simulator = CoreEffectStackMember:new("scaledvelocityintegrator", "simulator", "Velocity Integrator (scaled)")

	simulator:set_description("Adds velocity * dt * scale to position. Scale is determined by a key curve.")

	local help = "Determines which position channel integration is performed on:\nworld - world positions are modified\nlocal - local positions are modified."
	local p = CoreEffectProperty:new("channel", "value_list", "world", help)

	p:add_value("world")
	p:add_value("local")
	simulator:add_property(p)

	help = "If set, age will be read per particle, otherwise atom age is used"

	simulator:add_property(CoreEffectProperty:new("per_particle_age", "boolean", "false", help))

	help = "Determines how velocity is scaled over time."
	local scale_keys = CoreEffectProperty:new("scale_keys", "keys", "", help)

	scale_keys:set_key_type("float")
	scale_keys:add_key({
		v = "1",
		t = 0
	})
	scale_keys:set_min_max_keys(1, 4)
	simulator:add_property(scale_keys)

	return simulator
end

function CoreParticleEditorSimulators:create_eventtick()
	local simulator = CoreEffectStackMember:new("eventtick", "simulator", "Event Tick")

	simulator:set_description("Triggers an event for every particle position at a set frequency.")
	simulator:add_property(CoreEffectProperty:new("frequency", "float", "1", "Frequency of event ticks (hz)"))
	simulator:add_property(CoreEffectProperty:new("jitter", "float", "0", "Random interval for ticks to occur around event tick period, in seconds "))
	simulator:add_property(CoreEffectProperty:new("use_velocity", "boolean", "false", "If set, particle velocity will be read and included in event"))
	simulator:add_property(CoreEffectProperty:new("use_rotation", "boolean", "false", "If set, particle rotation will be read and included in event"))

	return simulator
end

function CoreParticleEditorSimulators:create_particleworldcollision()
	local simulator = CoreEffectStackMember:new("particleworldcollision", "simulator", "Particle <-> World Collision")

	simulator:set_description("Simulates collisions between particles with a fixed radius and a slice of the world.")
	simulator:add_property(CoreEffectProperty:new("radius", "float", "5", "Radius of particles"))
	simulator:add_property(CoreEffectProperty:new("elasticity", "percentage", "0.5", "Elasticity of collisions"))

	return simulator
end

function CoreParticleEditorSimulators:create_anglevelocityintegrator()
	local simulator = CoreEffectStackMember:new("anglevelocityintegrator", "simulator", "Angle Velocity Integrator")

	simulator:set_description("Adds angle velocity * dt to angle.")

	return simulator
end

function CoreParticleEditorSimulators:create_planecollision()
	local simulator = CoreEffectStackMember:new("planecollision", "simulator", "Plane Collision")

	simulator:set_description("Simulates collision with a plane with set origin and normal. Parameters are runtime modifiable by script.")
	simulator:add_property(CoreEffectProperty:new("name", "string", "", "Name of simulator.\nThis is an optional parameter which must be set if script wants to edit exposed parameters in simulator runtime."))

	local help = "Determines how plane coordinates are treated:\nrelative - Center and normal are rotated with effect rotation, and offset with effect position\nworld - Center and normal are not rotated or offset"
	local p = CoreEffectProperty:new("relative", "value_list", "effect", help)

	p:add_value("effect")
	p:add_value("world")
	simulator:add_property(p)

	help = "Center of plane.\nCoordinates are in centimeters and world coordinates.\nParameter is runtime modifiable by script by referencing effect/atom name/simulator name/center"

	simulator:add_property(CoreEffectProperty:new("center", "vector3", "0 0 0", help))

	help = [[
Normal of plane.
Coordinates are in centimeters and world coordinates.
Coordinates are in centimeters and world coordinates.
Parameter is runtime modifiable by script by referencing effect/atom name/simulator name/normal]]

	simulator:add_property(CoreEffectProperty:new("normal", "vector3", "0 0 1", help))

	help = "Elasticity of collision.\nThis is a value between 0 and 1 describing amount of velocity particles should retain after collision."

	simulator:add_property(CoreEffectProperty:new("elasticity", "percentage", "1", help))

	help = "Minimum impact velocity (cm/s) required to generate an event - if set too low, this will continously spawn events for resting particles."

	simulator:add_property(CoreEffectProperty:new("event_threshold_velocity", "float", "100", help))

	return simulator
end

function CoreParticleEditorSimulators:create_constantacceleration()
	local simulator = CoreEffectStackMember:new("constantacceleration", "simulator", "Constant Acceleration")

	simulator:set_description("Accelerates particles with a set acceleration. If this value must be runtime modifiable, use variableacceleration.")

	local help = [[
Determines how acceleration is treated:
world - Acceleration is not transformed
effect - Acceleration is transformed with effect system transform
effect_inverse - Acceleration is transformed with inverse effect system transform,
this means that it has the given direction when transformed by the effect system transform.
use this for local position effects where acceleration is still expressed in world coordinates]]
	local p = CoreEffectProperty:new("relative", "value_list", "world", help)

	p:add_value("effect")
	p:add_value("world")
	p:add_value("effect_inverse")
	simulator:add_property(p)

	help = "Acceleration.\nCoordinates are in centimeters/s^2."

	simulator:add_property(CoreEffectProperty:new("acceleration", "vector3", "0 0 -982", help))

	return simulator
end

function CoreParticleEditorSimulators:create_windacceleration()
	local simulator = CoreEffectStackMember:new("windacceleration", "simulator", "Wind Acceleration")

	simulator:set_description("Accelerates particles with global wind.")

	local help = "Radius (cm) that particles are considered to have - this affects how much wind the particle picks up, and thus how fast it will accelerate to wind speed.\nThe default value is that of a regulation size ping pong ball."

	simulator:add_property(CoreEffectProperty:new("radius", "float", "2", help))

	help = "Mass (kg) that particles are considered to have - this affects how much wind the particle picks up, and thus how fast it will accelerate to wind speed.\nThe default value is that of a regulation size ping pong ball."

	simulator:add_property(CoreEffectProperty:new("mass", "float", "0.0027", help))

	return simulator
end

function CoreParticleEditorSimulators:create_intervalrandomvelocity()
	local simulator = CoreEffectStackMember:new("intervalrandomvelocity", "simulator", "Interval Random Velocity")

	simulator:set_description("Randomly changes velocity of particles at a set interval.")

	local help = [[
Determines how velocities are treated:
effect - Velocities are rotated with effect rotation
world - Velocities are not rotated

Velocities are always offsetted with effect spawn velocity.]]
	local p = CoreEffectProperty:new("relative", "value_list", "effect", help)

	p:add_value("effect")
	p:add_value("world")
	simulator:add_property(p)

	help = "Box inside which particle velocities will be randomly generated.\nCoordinates are in cm/s."
	local p = CoreEffectProperty:new("box", "box", "", help)

	p:set_min_max(Vector3(-100, -100, -100), Vector3(100, 100, 100))
	simulator:add_property(p)
	simulator:add_property(CoreEffectProperty:new("frequency", "float", "0.5", "Frequency at which velocities will be reassigned (hz)"))

	return simulator
end

function CoreParticleEditorSimulators:create_variableacceleration()
	local simulator = CoreEffectStackMember:new("variableacceleration", "simulator", "Variable Acceleration")

	simulator:set_description("Accelerates particles with a set acceleration.\nAcceleration is runtime modifiable by script by referencing effect/atom name/simulator name/acceleration.")
	simulator:add_property(CoreEffectProperty:new("name", "string", "", "Name of simulator.\nThis is an optional parameter which must be set if script wants to edit exposed parameters in simulator runtime."))

	local help = [[
Determines how acceleration is treated:
world - Acceleration is not transformed
effect - Acceleration is transformed with effect system transform
effect_inverse - Acceleration is transformed with inverse effect system transform,
this means that it has the given direction when transformed by the effect system transform.
use this for local position effects where acceleration is still expressed in world coordinates]]
	local p = CoreEffectProperty:new("relative", "value_list", "world", help)

	p:add_value("effect")
	p:add_value("world")
	p:add_value("effect_inverse")
	simulator:add_property(p)

	help = "Acceleration.\nCoordinates are in centimeters/s^2.\nAcceleration is runtime modifiable by script by referencing effect/atom name/simulator name/acceleration (type Vector3)."

	simulator:add_property(CoreEffectProperty:new("acceleration", "vector3", "0 0 -982", help))

	return simulator
end

function CoreParticleEditorSimulators:create_variablesize()
	local simulator = CoreEffectStackMember:new("variablesize", "simulator", "Variable Size")

	simulator:set_description("Continously writes a set size to the size channel. The size may be changed runtime by the script.")
	simulator:add_property(CoreEffectProperty:new("name", "string", "", "Name of simulator.\nThis is an optional parameter which must be set if script wants to edit exposed parameters in simulator runtime."))

	local help = "Size.\nCoordinates are in centimeters.\nSize is runtime modifiable by script by referencing effect/atom name/simulator name/size (type Vector2)."

	simulator:add_property(CoreEffectProperty:new("size", "vector2", "100 100", help))

	return simulator
end

function CoreParticleEditorSimulators:create_variableopacity()
	local simulator = CoreEffectStackMember:new("variableopacity", "simulator", "Variable Opacity")

	simulator:set_description("Continously writes a set opacity to the opacity channel. The opacity may be changed runtime by the script.")
	simulator:add_property(CoreEffectProperty:new("name", "string", "", "Name of simulator.\nThis is an optional parameter which must be set if script wants to edit exposed parameters in simulator runtime."))

	local help = "Opacity.\nOpacity is runtime modifiable by script by referencing effect/atom name/simulator name/opacity (type float)."

	simulator:add_property(CoreEffectProperty:new("opacity", "float", "255", help))

	return simulator
end

function CoreParticleEditorSimulators:create_rotationbyvelocity()
	local simulator = CoreEffectStackMember:new("rotationbyvelocity", "simulator", "Rotation By Velocity")

	simulator:set_description("Rotates particles so that the Z axis is pointing towards the velocity vector\nThe rotation is not done instantly but with a lerp at a set angular velocity.")

	local help = "Angular velocity of rotation towards velocity vector (degrees / second)."

	simulator:add_property(CoreEffectProperty:new("velocity", "float", "360", help))

	return simulator
end

function CoreParticleEditorSimulators:create_teleporter()
	local simulator = CoreEffectStackMember:new("teleporter", "simulator", "Teleporter")

	simulator:set_description([[
Teleports particles to an new location, by a frequency determined by the set particle lifetime and the size of the atom.
When a particle is teleported, its age is set to 0 and its position and velocity are reinitialized using a custom initializer -
the initializerstack does not apply. This simulator is made for creating effect surface type effects, where particles are reused,
for instance a smoke plume.
To make initial particles invisible, initialize their age to a high value and make the opacity at that time 0.]])
	simulator:add_property(CoreEffectProperty:new("name", "string", "", "Name of simulator, must be set if particle_lifetime will be changed runtime"))

	local help = [[
Lifetime of particle
constant - use constant value, this may also be modified runtime by the script
The name of the exposed variable is particle_lifetime. If this is set to -1, respawning is disabled.
keys - use key curve over time]]
	local lifetime_input = CoreEffectProperty:new("lifetime_input", "variant", "constant", help)
	local constant_lifetime = CoreEffectProperty:new("particle_lifetime", "time", "1", "Constant lifetime of particles")

	constant_lifetime:set_can_be_infinite(true)

	local function validate_lifetime(p)
		local ret = {
			message = "",
			valid = true
		}
		local a = tonumber(p._value)

		if not a or a == 0 then
			ret.message = "Invalid particle lifetime, can be < 0 (infinite) or > 0"
			ret.valid = false
		end

		return ret
	end

	constant_lifetime:set_custom_validator(validate_lifetime)
	lifetime_input:add_variant("constant", constant_lifetime)

	local lifetime_keys = CoreEffectProperty:new("lifetime_keys", "keys", "", "")

	lifetime_keys:set_key_type("time")
	lifetime_keys:add_key({
		v = "1",
		t = 0
	})
	lifetime_keys:set_min_max_keys(1, 4)
	lifetime_input:add_variant("keys", lifetime_keys)

	local lifetime_container = CoreEffectPropertyContainer:new("lifetime")

	lifetime_container:add_property(lifetime_input)

	local lifetime_prop = CoreEffectProperty:new("", "compound", "")

	lifetime_prop:set_compound_container(lifetime_container)
	lifetime_prop:set_save_to_child(false)

	local help = [[
Frequency of particle teleports
constant - use constant value, this may also be modified runtime by the script
The name of the exposed variable is particle_lifetime. If this is set to -1, respawning is disabled.
keys - use key curve over time]]
	local frequency_input = CoreEffectProperty:new("frequency_input", "variant", "constant", help)
	local constant_frequency = CoreEffectProperty:new("frequency", "time", "1", "Constant frequency of teleports")

	constant_frequency:set_can_be_infinite(true)
	frequency_input:add_variant("constant", constant_frequency)

	local frequency_keys = CoreEffectProperty:new("frequency_keys", "keys", "", "")

	frequency_keys:set_key_type("time")
	frequency_keys:add_key({
		v = "1",
		t = 0
	})
	frequency_keys:set_min_max_keys(1, 4)
	frequency_input:add_variant("keys", frequency_keys)

	local frequency_container = CoreEffectPropertyContainer:new("frequency")

	frequency_container:add_property(frequency_input)
	frequency_container:add_property(CoreEffectProperty:new("min_age", "time", "-1", "Do not teleport a particle unless it is this old"))

	local frequency_prop = CoreEffectProperty:new("", "compound", "")

	frequency_prop:set_compound_container(frequency_container)
	frequency_prop:set_save_to_child(false)

	local distance_container = CoreEffectPropertyContainer:new("distance")

	distance_container:add_property(CoreEffectProperty:new("teleport_dist", "float", "100", "Distance to move atom before teleport is triggered."))

	local distance_prop = CoreEffectProperty:new("", "compound", "")

	distance_prop:set_compound_container(distance_container)
	distance_prop:set_save_to_child(false)

	local tt = CoreEffectProperty:new("trigger_teleport", "variant", "time", "When to trigger teleport - either when atom has moved a certain distance or when a certain time has passed")

	tt:add_variant("time", lifetime_prop)
	tt:add_variant("frequency", frequency_prop)
	tt:add_variant("distance", distance_prop)
	simulator:add_property(tt)
	simulator:add_property(CoreEffectProperty:new("teleport_cap", "int", "1", "More particles than this will never be teleported per frame."))
	simulator:add_property(CoreEffectProperty:new("current_position", "boolean", "true", "If set, teleported particles will always be moved to current atom position.\nThis reduces lag, but will cause trails of particles to have uneven gaps depending on framerate.\nIf not set, teleported particles will be moved to the linear interpolated position for the time of teleport."))

	local p = CoreEffectProperty:new("channel", "value_list", "world", "Position channel that particles should be teleported within")

	p:add_value("world")
	p:add_value("local")
	simulator:add_property(p)

	p = CoreEffectProperty:new("normal_variation", "percentage", "0", "Determines how much random jitter normal should receive when particle is repositioned")

	simulator:add_property(p)

	p = CoreEffectProperty:new("teleport_event", "boolean", "false", "If set, teleporter will generate an event every time a particle is teleported")

	simulator:add_property(p)

	help = "Position initializer\ncircle - initializes positions in a circle around (0,0,1) relative to effect location"
	local position_variant = CoreEffectProperty:new("positioner", "variant", "circle", help)

	position_variant:set_silent(false)

	local p = CoreEffectProperty:new("circle", "compound", "")
	local circle_positioner = CoreEffectPropertyContainer:new("circle")

	circle_positioner:set_description("Initializes positions in a circle around (0,0,1) relative to effect location. Normal always points at (0,1,0).")
	circle_positioner:add_property(CoreEffectProperty:new("radius", "float", "100", "Radius of circle"))
	circle_positioner:add_property(CoreEffectProperty:new("on_edge", "boolean", "false", "If this flag is set, position will always lie at the edge of the circle"))
	p:set_compound_container(circle_positioner)
	position_variant:add_variant(p:name(), p)

	p = CoreEffectProperty:new("box", "compound", "")
	local box_positioner = CoreEffectPropertyContainer:new("box")

	box_positioner:set_description("Initializes positions in a box relative to effect location.")

	help = "Box inside which particle positions will be randomly generated.\nCoordinates are in cm."
	local q = CoreEffectProperty:new("positions", "box", "", help)

	q:set_min_max(Vector3(-100, -100, -100), Vector3(100, 100, 100))
	box_positioner:add_property(q)

	q = CoreEffectProperty:new("velocities", "box", "", "Box inside which particle normals will be randomly generated.\nNormal will be normalized.")

	q:set_min_max(Vector3(0, 1, 0), Vector3(0, 1, 0))
	q:set_min_max_name("min_normal", "max_normal")
	box_positioner:add_property(q)
	p:set_compound_container(box_positioner)
	position_variant:add_variant(p:name(), p)
	simulator:add_property(position_variant)

	help = "Velocity initializer\nnormal - initializes velocity along normal from positioner"
	local velocity_variant = CoreEffectProperty:new("velocity", "variant", "normal", help)

	velocity_variant:set_silent(true)

	p = CoreEffectProperty:new("normal", "compound", "")
	local normal_velocity = CoreEffectPropertyContainer:new("normal")

	normal_velocity:set_description("Initializes velocity randomly along normal from positioner")
	normal_velocity:add_property(CoreEffectProperty:new("min_velocity", "float", "0", "Minimum velocity"))
	normal_velocity:add_property(CoreEffectProperty:new("max_velocity", "float", "100", "Maximum velocity"))
	p:set_compound_container(normal_velocity)
	velocity_variant:add_variant(p:name(), p)
	simulator:add_property(velocity_variant)

	help = "Rotation initializer\nnone - no rotation is assigned\nrandom - initializes with a random rotation"
	local rotation_variant = CoreEffectProperty:new("rotation", "variant", "none", help)

	rotation_variant:set_silent(true)

	p = CoreEffectProperty:new("random_rotation", "compound", "")
	local random_rotation = CoreEffectPropertyContainer:new("random_rotation")

	random_rotation:set_description("Initializes particle rotations to random values, with the normal within a specified box and a random angle around the normal.")

	q = CoreEffectProperty:new("box", "box", "", "Box within which normal will be randomized.")

	q:set_min_max(Vector3(-10, -10, 1), Vector3(10, 10, 1))
	random_rotation:add_property(q)
	random_rotation:add_property(CoreEffectProperty:new("min_rot", "float", "0", "Min angle around normal"))
	random_rotation:add_property(CoreEffectProperty:new("max_rot", "float", "365", "Max angle around normal"))
	p:set_compound_container(random_rotation)
	rotation_variant:add_variant(p:name(), p)

	p = CoreEffectProperty:new("rotation", "", "", "No rotation assigned")

	p:set_silent(true)
	rotation_variant:add_variant("none", p)
	simulator:add_property(rotation_variant)

	return simulator
end

function CoreParticleEditorSimulators:create_ager()
	local simulator = CoreEffectStackMember:new("ager", "simulator", "Ager")

	simulator:set_description("Adds timestep to age channel.")

	return simulator
end

function CoreParticleEditorSimulators:create_particleparticlecollision()
	local simulator = CoreEffectStackMember:new("particleparticlecollision", "simulator", "Particle <-> Particle Collision")

	simulator:set_description("Simulates collision between particles.\nNote that collions are only simulated between particles within the same atom and instance.\nAn event of type particleparticle_collision will be spawned whenever two particles collide (and total impact velocity is above threshold)")

	local help = "Radius of particles in cm."

	simulator:add_property(CoreEffectProperty:new("radius", "float", "1", help))

	local help = "Elasticity of collision.\nThis is a value between 0 and 1 determining how much velocity particle retains after a collision."

	simulator:add_property(CoreEffectProperty:new("elasticity", "percentage", "1", help))

	help = "Minimum total impact velocity (cm/s) required to generate an event - if set too low, this will continously spawn events for particles resting on each other."

	simulator:add_property(CoreEffectProperty:new("event_threshold_velocity", "float", "100", help))

	return simulator
end

function CoreParticleEditorSimulators:create_worldtransform()
	local simulator = CoreEffectStackMember:new("worldtransform", "simulator", "Local -> World Transform")

	simulator:set_description("Transforms local positions (and optionally rotations) to world coordinates.")

	local help = "If set, rotation channel will be read and transformed by effect transform into the world rotation channel."

	simulator:add_property(CoreEffectProperty:new("transform_rotations", "boolean", "false", help))

	return simulator
end
