CoreCutsceneKey = CoreCutsceneKey or {
	_classes = {}
}

function CoreCutsceneKey:create(element_name, key_collection)
	return assert(self._classes[element_name], "Element name \"" .. tostring(element_name) .. "\" does not match any registered cutscene key type."):new(key_collection)
end

function CoreCutsceneKey:register_class(path)
	require(path)

	local class_name = assert(string.match(path, ".*[\\/](.*)"), "Malformed class path supplied for cutscene key type.")
	local class = assert(rawget(_G, class_name), "The class should be named like the file.")
	local element_name = assert(class.ELEMENT_NAME, "Class does not have required ELEMENT_NAME string member.")

	if Application:ews_enabled() then
		class.COLOUR = class.COLOUR or self:next_available_colour()
	end

	CoreCutsceneKey._classes[element_name] = class
end

function CoreCutsceneKey:types()
	local sorted_types = {}

	for _, class in pairs(self._classes) do
		table.insert(sorted_types, class)
	end

	table.sort(sorted_types, function (a, b)
		return a.NAME < b.NAME
	end)

	return sorted_types
end

function CoreCutsceneKey:next_available_colour()
	self._colour_index = (self._colour_index or 0) + 1

	if self._colour_index > #self:colour_palette() then
		self._colour_index = 1
	end

	return self:colour_palette()[self._colour_index]
end

function CoreCutsceneKey:colour_palette()
	if self._colour_palette == nil then
		local hex_values = {
			"468966",
			"FFF0A5",
			"FFB03B",
			"B64926",
			"445878",
			"046380",
			"ADCF4F",
			"4A1A2C",
			"8E3557",
			"CCB689",
			"7EBE74",
			"756D43",
			"664689",
			"A5FFF0",
			"3BFFB0",
			"26B649",
			"784458",
			"800463",
			"4FADCF",
			"2C4A1A",
			"578E35",
			"89CCB6",
			"747EBE",
			"43756D",
			"896646",
			"F0A5FF",
			"B03BFF",
			"4926B6",
			"587844",
			"638004",
			"CF4FAD",
			"1A2C4A",
			"35578E",
			"B689CC",
			"BE747E",
			"6D4375"
		}
		self._colour_palette = table.collect(hex_values, function (hex)
			return Color(hex)
		end)
	end

	return self._colour_palette
end

CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreChangeCameraAttributeCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreChangeCameraCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreChangeEnvCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreDepthOfFieldCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreDiscontinuityCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreGuiCallbackCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreGuiCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreLocatorConstraintCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreObjectVisibleCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreOverlayFXCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreSequenceCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreShakeCameraCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreSimpleAnimationCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreSoundCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreSpawnUnitCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreSubtitleCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreTimerSpeedCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreUnitCallbackCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreUnitVisibleCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreVideoCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreVisualFXCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreVolumeSetCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreZoomCameraCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreChangeShadowCutsceneKey")
CoreCutsceneKey:register_class("core/lib/managers/cutscene/keys/CoreLightGroupCutsceneKey")
