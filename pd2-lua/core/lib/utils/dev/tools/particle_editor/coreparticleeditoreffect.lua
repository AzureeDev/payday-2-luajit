CoreEffectStackMember = CoreEffectStackMember or class(CoreEffectPropertyContainer)

function CoreEffectStackMember:init(name, stacktype, ui_name)
	self.super.init(self, name)

	self._stacktype = stacktype
	self._ui_name = ui_name
end

function CoreEffectStackMember:save(node)
	local n = node:make_child(self:name())

	self:save_properties(n)
end

function CoreEffectStackMember:access()
	local ret = {}

	if self._stacktype == "initializer" then
		local n = Node("initializerstack")

		self:save(n)

		ret = World:effect_manager():query_initializer_access_pattern(n)
	elseif self._stacktype == "simulator" then
		local n = Node("simulatorstack")

		self:save(n)

		ret = World:effect_manager():query_simulator_access_pattern(n)
	elseif self._stacktype == "visualizer" then
		local n = Node("visualizerstack")

		self:save(n)

		ret = World:effect_manager():query_visualizer_access_pattern(n)
	else
		assert(false, "Unhandled stacktype")
	end

	return ret
end

function CoreEffectStackMember:reads_writes()
	local reads = {}
	local writes = {}
	local access = self:access()

	for _, a in ipairs(access) do
		if a.access == "WRITE" then
			writes[a.component] = "FULL"
		elseif a.access == "READ" then
			reads[a.component] = "FULL"
		elseif a.access == "WRITE_READ" or a.access == "READ_WRITE" then
			writes[a.component] = "FULL"
			reads[a.component] = "FULL"
		elseif a.access == "READ_WRITE_SOME" then
			reads[a.component] = "FULL"
			writes[a.component] = "SOME"
		elseif a.access == "WRITE_SOME" then
			writes[a.component] = "SOME"
		else
			assert(false, "Unhandled enum")
		end
	end

	return reads, writes
end

CoreEffectStack = CoreEffectStack or class()

function CoreEffectStack:init(stacktype)
	self._type = stacktype
	self._stack = {}
end

function CoreEffectStack:stack()
	return self._stack
end

function CoreEffectStack:member(i)
	return self._stack[i]
end

function CoreEffectStack:add_member(member)
	table.insert(self._stack, member)
end

function CoreEffectStack:insert_member(member, i)
	table.insert(self._stack, i, member)
end

function CoreEffectStack:move_down(idx)
	if idx == #self._stack then
		return
	end

	local e = self._stack[idx]

	table.remove(self._stack, idx)
	table.insert(self._stack, idx + 1, e)
end

function CoreEffectStack:move_up(idx)
	if idx == 1 then
		return
	end

	local e = self._stack[idx]

	table.remove(self._stack, idx)
	table.insert(self._stack, idx - 1, e)
end

function CoreEffectStack:remove(idx)
	table.remove(self._stack, idx)
end

function CoreEffectStack:validate(channels)
	local ret = {
		valid = true,
		message = "",
		node = nil
	}

	if #self._stack == 0 then
		ret.valid = false
		ret.message = self._type .. " stack is empty"

		return ret
	end

	if self._type == "visualizer" then
		for _, m in ipairs(self._stack) do
			if m:name() == "trail" then
				local num_backlog = tonumber(m:get_property("size")._value)
				local tesselation = tonumber(m:get_property("tesselation")._value)
				local l = 1 + num_backlog * (tesselation + 1)

				if l >= 80 then
					ret.valid = false
					ret.message = "Trail visualizer has a too high tesselation or backlog size, decrease tesselation or backlog"
					m._valid_properties = false

					return ret
				end
			end
		end
	end

	local position_written = false

	for _, m in ipairs(self._stack) do
		ret = m:validate_properties()

		if not ret.valid then
			ret.message = self._type .. "stack, " .. m:name() .. " - " .. ret.message
			m._valid_properties = false

			return ret
		end

		m._valid_properties = true
		local access = m:access()

		for _, a in ipairs(access) do
			if a.access == "WRITE" or a.access == "WRITE_READ" then
				channels[a.component] = true

				if a.component == "POSITION" then
					position_written = true
				end
			elseif a.access == "READ" or a.access == "READ_WRITE" or a.access == "READ_WRITE_SOME" then
				if not channels[a.component] then
					ret.valid = false
					ret.message = m:name() .. " in " .. self._type .. "stack reads from " .. a.component .. " before it has beeen written"

					return ret
				end

				if a.access == "READ_WRITE" then
					channels[a.component] = true

					if a.component == "POSITION" then
						position_written = true
					end
				end
			end
		end
	end

	if self._type == "simulator" and not position_written then
		ret.valid = false
		ret.message = "Position channel not fully written in simulator stack, this is needed for effect bounding box to be valid"

		return ret
	end

	return ret
end

function CoreEffectStack:save(node)
	local stack = node:make_child(self._type .. "stack")

	for _, m in ipairs(self._stack) do
		m:save(stack)
	end
end

function CoreEffectStack:load(node)
	for child1 in node:children() do
		if child1:name() == self._type .. "stack" then
			for child2 in child1:children() do
				local creator = stack_members[self._type][child2:name()]

				assert(creator, "Could not resolve creator for member type")

				local m = creator()

				m:load_properties(child2)
				table.insert(self._stack, m)
			end

			return
		end
	end
end

CoreEffectAtom = CoreEffectAtom or class(CoreEffectPropertyContainer)

function CoreEffectAtom:init(name)
	self.super.init(self, name)

	local help = [[
Defines the minimum and maximum number of particles in the atom
The minimum number will be used if the effect quality setting is at the lowest,
the maximum number if the effect quality setting is at the highest, otherwise in between the two.
Test how your effect looks at minimum and maximum quality
using the Play Lowest Quality Once and Play Highest Quality Once buttons.
The default playback mode is the medium quality.]]

	self:add_property(CoreEffectProperty:new("min_size", "int", "1", help))
	self:add_property(CoreEffectProperty:new("max_size", "int", "1", help))

	help = "Defines the lifetime of the atom - can be -1 which means infinite, or a set number of seconds"
	local p = CoreEffectProperty:new("lifetime", "time", "1", help)

	p:set_can_be_infinite(true)
	self:add_property(p)

	help = "Defines the start time of the atom, relative to effect spawn time. The atom will not be updated or rendered during this time."
	local p = CoreEffectProperty:new("random_start_time", "variant", "false", help)

	p:add_variant("false", CoreEffectProperty:new("start_time", "time", "0", "Start time for atom"))

	local random_start_time = CoreEffectProperty:new("start_time", "compound", "", "")

	random_start_time:set_save_to_child(false)

	local random_start_time_container = CoreEffectPropertyContainer:new("random_start_time")

	random_start_time_container:add_property(CoreEffectProperty:new("min_start_time", "time", "0", "Minimum start time"))
	random_start_time_container:add_property(CoreEffectProperty:new("max_start_time", "time", "0", "Maximum start time"))
	random_start_time:set_compound_container(random_start_time_container)
	p:add_variant("true", random_start_time)
	self:add_property(p)

	p = CoreEffectProperty:new("preroll", "time", "0", [[
Preroll time for the atom, in seconds.
Atom will appear to have already lived for this time when it is spawned.
This is an expensive parameter - each second corresponds to a number of iterations of the atom simulation stack.

Note that only this effect in isolation will be processed - events generated will be processed after preroll.
This means that effects depending on event handlers being called per frame will not work well with preroll.

The maximum preroll time is 5s. This limitation is for preventing stalls during spawn.
Only infinite-lifetime effects may be prerolled. This limitation is here since the effects that are most
in need of preroll are infinite lifetime effects - other effects should be designed to reach the same
effect by construction of the initializer stack.]])

	self:add_property(p)
	self:add_property(CoreEffectProperty:new("inherit_velocity_multiplier", "float", "1", "Multiplier for inherited initial velocity- 0 means no velocity, 2 means double velocity."))

	p = CoreEffectProperty:new("fade_in_start", "value_list", "-1", "Distance (in meters) at which an effect starts fading in. -1 means no fading.\nSmooth fading only works for effects with a visualizer that respects opacity, other effects will just disappear when they reach the cull distance.")

	p:add_value("-1")
	p:add_value("0")
	p:add_value("0.5")
	p:add_value("1")
	p:add_value("2")
	p:add_value("5")
	p:add_value("7")
	p:add_value("10")
	p:add_value("15")
	p:add_value("20")
	p:add_value("50")
	p:add_value("80")
	p:add_value("100")
	p:add_value("200")
	p:add_value("300")
	p:add_value("400")
	p:add_value("500")
	p:add_value("600")
	p:add_value("700")
	p:add_value("800")
	p:add_value("900")
	p:add_value("1000")
	self:add_property(p)

	p = CoreEffectProperty:new("fade_in_length", "value_list", "0", "Distance (in meters) over which to fade in effect. 0 means no fading.")

	p:add_value("0")
	p:add_value("0.5")
	p:add_value("1")
	p:add_value("2")
	p:add_value("5")
	p:add_value("7")
	p:add_value("10")
	p:add_value("15")
	p:add_value("20")
	p:add_value("50")
	self:add_property(p)

	p = CoreEffectProperty:new("fade_out_start", "value_list", "-1", "Distance (in meters) past which an effect starts fading out. -1 means no fading.\nThe distance past fade_out_start over which effect will be faded is calculated by a factor.\nSmooth fading only works for effects with a visualizer that respects opacity, other effects will just disappear when they reach the cull distance.")

	p:add_value("-1")
	p:add_value("2")
	p:add_value("3")
	p:add_value("5")
	p:add_value("10")
	p:add_value("20")
	p:add_value("50")
	p:add_value("65")
	p:add_value("80")
	p:add_value("100")
	p:add_value("200")
	p:add_value("300")
	p:add_value("400")
	p:add_value("500")
	p:add_value("600")
	p:add_value("700")
	p:add_value("800")
	p:add_value("900")
	p:add_value("1000")
	self:add_property(p)

	help = "Determines what happens when an atom is spawned at a location which is not visible.\nkill - atom will be killed immediately without being initialized and updated\ninitialize - atom will be initialized and updated at least once, after this the cull policy will apply if the atom is still culled"
	p = CoreEffectProperty:new("spawn_cull_policy", "value_list", "kill", help)

	p:add_value("kill")
	p:add_value("initialize")
	self:add_property(p)

	help = [[
Determines what happens when atom is culled:
kill - removes the atom from world
freeze - stops updating atom
update - keeps updating atom, only use this when absolutely required since it is expensive
update_render - keeps both updating and rendering atom, only use this when absolutely positively required since it is expensive

The update_render option is required for screen aligned effects to be rendered]]
	p = CoreEffectProperty:new("cull_policy", "value_list", "kill", help)

	p:add_value("kill")
	p:add_value("freeze")
	p:add_value("update")
	p:add_value("update_render")
	self:add_property(p)

	help = "Defines the period of time in seconds that the atom must be culled before the cull policy is applied.\nIf for example set to 1, and cull_policy is kill, an atom that is not visible will remain alive for 1 second before being removed."

	self:add_property(CoreEffectProperty:new("cull_gracetime", "time", "0", help))

	help = [[
If this is set to a value >= 0, the given value will be used as the max radius for the visual representation of a particle
You do not need to set this value if the visualizer uses a key curve or a constant for determining its size,
but if the size is dependent on channel input you must set it to get a valid radius.

The max visual radius of a particle is used for building the bounding volume, so if this value is too low
the effect will be culled while still visible]]

	self:add_property(CoreEffectProperty:new("max_particle_radius", "float", "-1", help))

	help = "Soundbank for sound to be played at atom creation. May be empty."

	self:add_property(CoreEffectProperty:new("soundbank", "sound", "", help))

	help = "Cue for sound to be played at atom creation. If empty, no sound is played."

	self:add_property(CoreEffectProperty:new("cue", "sound", "", help))

	help = "If set, sound will be played in ambient mode."

	self:add_property(CoreEffectProperty:new("ambient", "boolean", "false", help))

	help = "If the effect uses particle-world collision, and this is set to effect, grab position will be rotated with effect transform"
	p = CoreEffectProperty:new("grab_relative", "value_list", "effect", help)

	p:add_value("effect")
	p:add_value("world")
	self:add_property(p)

	help = "If the effect uses particle-world collision, a copy of the world geometry will be grabbed around this point"

	self:add_property(CoreEffectProperty:new("grab_pos", "vector3", "0 0 0", help))

	help = "If the effect uses particle-world collision, this radius specifies the region around the grab point within which geometry will be grabbed.\nNote that there is a cap on the amount of geometry that is grabbed - setting a very high radius may result in geometry\nfar from the expected collision area to be grabbed, while ignoring geometry in the collision area."

	self:add_property(CoreEffectProperty:new("grab_radius", "float", "200", help))

	help = "If the effect uses particle-world collision and this parameter is set, faces pointing away from grab position will be included in collision grab."

	self:add_property(CoreEffectProperty:new("grab_backfacing", "boolean", "false", help))

	help = "Internal event listeners - these are listeners capable of handling events spawned by the simulators with a fixed behaviour.\nFor more advanced event handling, script callbacks can be registered with effect instances at runtime."
	p = CoreEffectProperty:new("event_listeners", "list_objects", "", help)

	local function create_event_types()
		local event_types = CoreEffectProperty:new("event", "value_list", "collision", "Type of event that handler should respond to")

		event_types:add_value("collision")
		event_types:add_value("particleparticle_collision")
		event_types:add_value("tick")
		event_types:add_value("teleport")

		return event_types
	end

	local function create_effect_spawn_property()
		local effect_spawn_property = CoreEffectProperty:new("effect_spawn", "compound", "", "")

		effect_spawn_property:set_save_to_child(false)

		local effect_spawn_container = CoreEffectPropertyContainer:new("effect_spawn")

		effect_spawn_container:add_property(create_event_types())
		effect_spawn_container:add_property(CoreEffectProperty:new("effect", "effect", "", "Effect that should be spawned in response to event"))
		effect_spawn_property:set_compound_container(effect_spawn_container)

		return effect_spawn_property
	end

	local function create_effect_spawn_once_property()
		local effect_spawn_once_property = CoreEffectProperty:new("effect_spawn_once_drag", "compound", "", "")

		effect_spawn_once_property:set_save_to_child(false)

		local effect_spawn_once_container = CoreEffectPropertyContainer:new("effect_spawn_once_drag")

		effect_spawn_once_container:add_property(create_event_types())
		effect_spawn_once_container:add_property(CoreEffectProperty:new("effect", "effect", "", "Effect that should be spawned and dragged in response to event"))
		effect_spawn_once_property:set_compound_container(effect_spawn_once_container)

		return effect_spawn_once_property
	end

	local function create_play_sound_property()
		local play_sound = CoreEffectProperty:new("play_sound", "compound", "", "")

		play_sound:set_save_to_child(false)

		local play_sound_container = CoreEffectPropertyContainer:new("play_sound")

		play_sound_container:add_property(create_event_types())
		play_sound_container:add_property(CoreEffectProperty:new("once_then_drag", "boolean", "false", "If set, sound will only be played once at first event, and then dragged to each new event location"))
		play_sound_container:add_property(CoreEffectProperty:new("bank", "bank", "", "Soundbank for sound to be played in response to event"))
		play_sound_container:add_property(CoreEffectProperty:new("cue", "cue", "", "Cue for sound to be played in response to event"))

		help = "If set, sound will be played in ambient mode."

		play_sound_container:add_property(CoreEffectProperty:new("ambient", "boolean", "false", help))
		play_sound:set_compound_container(play_sound_container)

		return play_sound
	end

	p:set_object("effect_spawn", create_effect_spawn_property())
	p:set_object("effect_spawn_once_drag", create_effect_spawn_once_property())
	p:set_object("play_sound", create_play_sound_property())
	self:add_property(p)

	p = CoreEffectProperty:new("timeline", "timeline", "", "")

	p:set_timeline_init_callback_name("timeline_init")
	self:add_property(p)

	self._stacks = {
		initializer = CoreEffectStack:new("initializer"),
		simulator = CoreEffectStack:new("simulator"),
		visualizer = CoreEffectStack:new("visualizer")
	}
end

function CoreEffectAtom:collect_stack_time_events()
	local ret = {}

	local function traverse_property(pref, ret, p)
		if p._type == "time" then
			table.insert(ret, {
				pref .. p:name(),
				p,
				"_value"
			})
		elseif p._type == "variant" then
			traverse_property(pref, ret, p._variants[p._value])
		elseif p._type == "compound" then
			for _, q in ipairs(p._compound_container) do
				traverse_property(pref, ret, q)
			end
		elseif p._type == "keys" then
			for _, k in ipairs(p._keys) do
				table.insert(ret, {
					pref .. p:name(),
					k,
					"t"
				})
			end
		end
	end

	for _, stack in pairs(self._stacks) do
		for _, member in ipairs(stack._stack) do
			for _, p in ipairs(member._properties) do
				local pref = stack._type .. "/" .. member:name() .. "/"

				traverse_property(pref, ret, p)
			end
		end
	end

	return ret
end

function CoreEffectAtom:collect_time_events()
	local start_time = self:get_property("random_start_time")._variants.false
	local lifetime = self:get_property("lifetime")
	local ret = self:collect_stack_time_events()

	for _, e in ipairs(ret) do
		local name = e[1]
		local t = tonumber(e[2][e[3]]) + tonumber(start_time._value)
		e[2] = {
			t
		}
		e[3] = 1
	end

	table.insert(ret, {
		"start_time",
		start_time,
		"_value"
	})

	if tonumber(lifetime._value) >= 0 then
		table.insert(ret, {
			"end_time",
			{
				tonumber(start_time._value) + tonumber(lifetime._value)
			},
			1
		})
	end

	return ret
end

function CoreEffectAtom:scale_timeline(istart, iend, tstart, tend)
	local events = self:collect_stack_time_events()
	local start_time = self:get_property("random_start_time")._variants.false
	local lifetime = self:get_property("lifetime")
	local end_time = {
		"end_time",
		lifetime,
		"_value"
	}

	if tonumber(lifetime._value) >= 0 then
		table.insert(events, end_time)
	end

	local start_time_v = tonumber(start_time._value)

	for _, e in ipairs(events) do
		e[2][e[3]] = e[2][e[3]] + start_time_v
	end

	table.insert(events, {
		"start_time",
		start_time,
		"_value"
	})

	for _, e in ipairs(events) do
		local name = e[1]
		local t = tonumber(e[2][e[3]])

		if t <= istart then
			t = t + tstart - istart
		elseif iend <= t then
			t = t + tend - iend
		else
			local rel = 0

			if iend - istart ~= 0 then
				rel = (t - istart) / (iend - istart)
			end

			t = tstart + rel * (tend - tstart)
		end

		e[2][e[3]] = t
	end

	local new_start_time_v = tonumber(start_time._value)

	for _, e in ipairs(events) do
		if e[2] ~= start_time then
			e[2][e[3]] = e[2][e[3]] - new_start_time_v
		end
	end
end

function CoreEffectAtom:extend_timeline(istart, iend, tstart, tend)
	local events = self:collect_stack_time_events()
	local start_time = self:get_property("random_start_time")._variants.false
	local lifetime = self:get_property("lifetime")
	local end_time = {
		"end_time",
		lifetime,
		"_value"
	}

	if tonumber(lifetime._value) >= 0 then
		table.insert(events, end_time)
	end

	local start_time_v = tonumber(start_time._value)

	for _, e in ipairs(events) do
		e[2][e[3]] = e[2][e[3]] + start_time_v
	end

	table.insert(events, {
		"start_time",
		start_time,
		"_value"
	})

	for _, e in ipairs(events) do
		local name = e[1]
		local t = tonumber(e[2][e[3]])

		if t <= istart then
			t = t + tstart - istart
		elseif iend <= t then
			t = t + tend - iend
		end

		e[2][e[3]] = t
	end

	local new_start_time_v = tonumber(start_time._value)

	for _, e in ipairs(events) do
		if e[2] ~= start_time then
			e[2][e[3]] = e[2][e[3]] - new_start_time_v
		end
	end
end

function CoreEffectAtom:validate()
	local ret = {
		valid = true,
		message = "",
		node = nil
	}
	ret = self:validate_properties()

	if not ret.valid then
		return ret
	end

	local lifetime = tonumber(self:get_property("lifetime"):value())

	if not lifetime then
		ret.valid = false
		ret.message = "Invalid lifetime for atom " .. self:name()

		return ret
	end

	local preroll = tonumber(self:get_property("preroll"):value())

	if not preroll or preroll < 0 or preroll > 5 then
		ret.valid = false
		ret.message = "Invalid preroll time for atom " .. self:name() .. ", must be between 0 and 5 seconds"

		return ret
	end

	if lifetime >= 0 and preroll ~= 0 then
		ret.valid = false
		ret.message = "Atom " .. self:name() .. " cannot have  a preroll time set - only infinite-lifetime atoms can have a preroll time"

		return ret
	end

	local channels = {}
	ret = self._stacks.initializer:validate(channels)

	if not ret.valid then
		return ret
	end

	ret = self._stacks.simulator:validate(channels)

	if not ret.valid then
		return ret
	end

	ret = self._stacks.visualizer:validate(channels)

	if not ret.valid then
		return ret
	end

	return ret
end

function CoreEffectAtom:stack(stacktype)
	return self._stacks[stacktype]
end

function CoreEffectAtom:save(node)
	local a = node:make_child("atom")

	a:set_parameter("name", self:name())
	self:save_properties(a)
	self._stacks.initializer:save(a)
	self._stacks.simulator:save(a)
	self._stacks.visualizer:save(a)
end

function CoreEffectAtom:load(node)
	self._name = node:parameter("name")

	self:load_properties(node)
	self._stacks.initializer:load(node)
	self._stacks.simulator:load(node)
	self._stacks.visualizer:load(node)
end

CoreEffectDefinition = CoreEffectDefinition or class(CoreEffectPropertyContainer)

function CoreEffectDefinition:init()
	self.super.init(self, "")

	self._atoms = {}
	self._description = ""
	local p = CoreEffectProperty:new("use", "list_objects", "", "Effects referenced in this list will be included in this effect")
	local use_effect_prop = CoreEffectProperty:new("use", "compound", "", "")

	use_effect_prop:set_save_to_child(false)

	local use_effect_container = CoreEffectPropertyContainer:new("use")

	use_effect_container:add_property(CoreEffectProperty:new("name", "effect", "", "Effect that should be included in this one"))
	use_effect_prop:set_compound_container(use_effect_container)
	p:set_object("use", use_effect_prop)
	self:add_property(p)

	p = CoreEffectProperty:new("use_random", "list_objects", "", "One effect from each of the sets specified here will be chosen at random and included when this effect is spawned.\nThe typical case is to only have one set and several effects in it - \nif you specify several sets, this means you will get a random combination of one effect from each set.")
	local random_set_prop = CoreEffectProperty:new("use_random", "list_objects", "", "")

	random_set_prop:set_save_to_child(false)

	local random_effect_prop = CoreEffectProperty:new("effect", "compound", "", "")

	random_effect_prop:set_save_to_child(false)

	local random_effect_container = CoreEffectPropertyContainer:new("effect")

	random_effect_container:add_property(CoreEffectProperty:new("name", "effect", "", "Effect that should be included in this one"))
	random_effect_prop:set_compound_container(random_effect_container)
	random_set_prop:set_object("effect", random_effect_prop)
	p:set_object("use_random", random_set_prop)
	self:add_property(p)
	self:add_property(CoreEffectProperty:new("force_synch", "boolean", "false", "If set, effect will play on the main thread without frame lag\nThis is useful for parented effects where a frame lag is very noticeable.\nThe CPU cost for for effects with this flag set will end up on the main thread, so use only where required."))
end

function CoreEffectDefinition:find_atom(name)
	for _, atom in ipairs(self._atoms) do
		if atom:name() == name then
			return atom
		end
	end

	return nil
end

function CoreEffectDefinition:add_atom(atom)
	table.insert(self._atoms, atom)
end

function CoreEffectDefinition:remove_atom(atom)
	table.delete(self._atoms, atom)
end

function CoreEffectDefinition:validate()
	local ret = {
		valid = true,
		message = "",
		node = nil
	}
	ret = self:validate_properties()

	if not ret.valid then
		return ret
	end

	if #self._atoms < 1 then
		ret.valid = false
		ret.message = "Empty effect - create an atom and fill stacks"

		return ret
	end

	for _, atom in ipairs(self._atoms) do
		ret = atom:validate()

		if not ret.valid then
			return ret
		end
	end

	return ret
end

function CoreEffectDefinition:save(n)
	self:save_properties(n)

	for _, atom in ipairs(self._atoms) do
		atom:save(n)
	end
end

function CoreEffectDefinition:load(n)
	self:load_properties(n)

	for child in n:children() do
		if child:name() == "atom" then
			local atom = CoreEffectAtom:new("default")

			atom:load(child)
			table.insert(self._atoms, atom)
		end
	end
end
