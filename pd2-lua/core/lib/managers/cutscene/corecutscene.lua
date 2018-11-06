require("core/lib/managers/cutscene/CoreCutsceneKeys")
require("core/lib/managers/cutscene/CoreCutsceneKeyCollection")

CoreCutscene = CoreCutscene or frozen_class()

mixin(CoreCutscene, CoreCutsceneKeyCollection)

local CUTSCENE_FRAMES_PER_SECOND = 30

function CoreCutscene:_all_keys_sorted_by_time()
	return self._keys or {}
end

function CoreCutscene:init(cutscene_node, cutscene_manager)
	assert(cutscene_node, "No cutscene XML node supplied.")
	assert(cutscene_manager, "Must supply a reference to the CutsceneManager.")

	self._name = cutscene_node:parameter("name")
	self._unit_name = cutscene_node:parameter("unit")
	self._frame_count = tonumber(cutscene_node:parameter("frames"))
	self._keys = {}
	self._unit_types = {}
	self._unit_animations = {}
	self._unit_blend_sets = {}
	self._camera_names = {}
	self._animation_blobs = self:_parse_animation_blobs(cutscene_node)

	for collection_node in cutscene_node:children() do
		if collection_node:name() == "controlled_units" then
			for child_node in collection_node:children() do
				local unit_name = child_node:parameter("name")
				self._unit_types[unit_name] = cutscene_manager:cutscene_actor_unit_type(self:_cutscene_specific_unit_type(child_node:parameter("type")))
				self._unit_animations[unit_name] = child_node:parameter("animation")
				self._unit_blend_sets[unit_name] = child_node:parameter("blend_set")

				if string.begins(unit_name, "camera") then
					table.insert(self._camera_names, unit_name)
				end
			end
		elseif collection_node:name() == "keys" then
			for child_node in collection_node:children() do
				local cutscene_key = CoreCutsceneKey:create(child_node:name(), self)

				cutscene_key:load(child_node)
				table.insert(self._keys, freeze(cutscene_key))
			end
		end
	end

	table.sort(self._camera_names)
	table.sort(self._keys, function (a, b)
		return a:frame() < b:frame()
	end)
	freeze(self._keys, self._unit_types, self._unit_animations, self._unit_blend_sets, self._camera_names)
end

function CoreCutscene:is_valid()
	return table.empty(self._unit_types) or DB:has("unit", self:unit_name())
end

function CoreCutscene:name()
	return self._name or ""
end

function CoreCutscene:unit_name()
	return self._unit_name or ""
end

function CoreCutscene:frames_per_second()
	return CUTSCENE_FRAMES_PER_SECOND
end

function CoreCutscene:frame_count()
	return self._frame_count or 1
end

function CoreCutscene:duration()
	return self:frame_count() / self:frames_per_second()
end

function CoreCutscene:is_optimized()
	return table.empty(self._unit_animations)
end

function CoreCutscene:has_cameras()
	return not table.empty(self._camera_names)
end

function CoreCutscene:has_unit(unit_name, include_units_spawned_through_keys)
	if self:controlled_unit_types()[unit_name] ~= nil then
		return true
	end

	if include_units_spawned_through_keys then
		for spawn_key in self:keys(CoreSpawnUnitCutsceneKey.ELEMENT_NAME) do
			if spawn_key:name() == unit_name then
				return true
			end
		end
	end

	return false
end

function CoreCutscene:controlled_unit_types()
	return self._unit_types
end

function CoreCutscene:camera_names()
	return self._camera_names
end

function CoreCutscene:default_camera()
	for _, name in ipairs(self:camera_names()) do
		return name
	end
end

function CoreCutscene:objects_in_unit(unit_name)
	return self:_actor_database_info(unit_name):object_names()
end

function CoreCutscene:extensions_on_unit(unit_name)
	return self:_actor_database_info(unit_name):extensions()
end

function CoreCutscene:animation_for_unit(unit_name)
	return self._unit_animations[unit_name]
end

function CoreCutscene:blend_set_for_unit(unit_name)
	return self._unit_blend_sets[unit_name] or "all"
end

function CoreCutscene:animation_blobs()
	return self._animation_blobs
end

function CoreCutscene:find_spawned_orientation_unit()
	local spawned_cutscene_units = World:unit_manager():get_units(managers.slot:get_mask("cutscenes"))

	for _, unit in ipairs(spawned_cutscene_units) do
		if unit:name() == self:unit_name() then
			return unit
		end
	end
end

function CoreCutscene:_parse_animation_blobs(cutscene_node)
	return self:_parse_animation_blob_list(cutscene_node) or self:_parse_single_animation_blob(cutscene_node)
end

function CoreCutscene:_parse_animation_blob_list(cutscene_node)
	for collection_node in cutscene_node:children() do
		if collection_node:name() == "animation_blobs" then
			local animation_blobs = {}

			for animation_blob_node in collection_node:children() do
				local value = animation_blob_node:name() == "part" and animation_blob_node:parameter("animation_blob") or nil

				if value then
					table.insert(animation_blobs, value)
				end
			end

			return animation_blobs
		end
	end

	return nil
end

function CoreCutscene:_parse_single_animation_blob(cutscene_node)
	for collection_node in cutscene_node:children() do
		if collection_node:name() == "controlled_units" then
			local animation_blob = collection_node:parameter("animation_blob")

			return animation_blob and {
				animation_blob
			}
		end
	end

	return nil
end

function CoreCutscene:_actor_database_info(unit_name)
	local unit_type = assert(self:controlled_unit_types()[unit_name], string.format("Unit \"%s\" is not in cutscene \"%s\".", unit_name, self:name()))
	local unit_info = assert(managers.cutscene:actor_database():unit_type_info(unit_type), string.format("Unit type \"%s\", used in cutscene \"%s\", is not registered in the actor database.", unit_type, self:name()))

	return unit_info
end

function CoreCutscene:_cutscene_specific_unit_type(unit_type)
	if unit_type ~= "locator" and DB:has("unit", unit_type .. "_cutscene") then
		unit_type = unit_type .. "_cutscene"
	end

	return unit_type
end

function CoreCutscene:_debug_persistent_keys()
	local persistent_keys = {}
	local unit_types = self:controlled_unit_types()

	for sequence_key in self:keys(CoreSequenceCutsceneKey.ELEMENT_NAME) do
		local unit_type = unit_types[sequence_key:unit_name()]
		persistent_keys[string.format("Sequence %s.%s", unit_type or "\"" .. sequence_key:unit_name() .. "\"", sequence_key:name())] = true
	end

	for callback_key in self:keys(CoreUnitCallbackCutsceneKey.ELEMENT_NAME) do
		local unit_type = unit_types[callback_key:unit_name()]
		persistent_keys[string.format("Callback %s:%s():%s()", unit_type or "\"" .. callback_key:unit_name() .. "\"", callback_key:extension(), callback_key:method())] = true
	end

	return persistent_keys
end
