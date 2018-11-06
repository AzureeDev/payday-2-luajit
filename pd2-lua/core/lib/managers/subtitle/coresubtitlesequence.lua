core:module("CoreSubtitleSequence")
core:import("CoreClass")

SubtitleSequence = SubtitleSequence or CoreClass.class()
Subtitle = Subtitle or CoreClass.class()
StringIDSubtitle = StringIDSubtitle or CoreClass.class(Subtitle)

function SubtitleSequence:init(sequence_node)
	if sequence_node then
		self:_load_from_xml(sequence_node)
	end
end

function SubtitleSequence:name()
	return self:parameters().name or ""
end

function SubtitleSequence:duration()
	return self.__subtitles and self.__subtitles[#self.__subtitles]:end_time()
end

function SubtitleSequence:parameters()
	return self.__parameters or {}
end

function SubtitleSequence:subtitles()
	return self.__subtitles or {}
end

function SubtitleSequence:add_subtitle(subtitle)
	self.__subtitles = self.__subtitles or {}

	table.insert_sorted(self.__subtitles, subtitle, function (a, b)
		return a:start_time() < b:start_time()
	end)
end

function SubtitleSequence:_load_from_xml(sequence_node)
	assert(managers.localization, "Localization Manager not ready.")
	assert(sequence_node and sequence_node:name() == "sequence", "Attempting to construct from non-sequence XML node.")
	assert(sequence_node:parameter("name"), "Sequence must have a name.")

	self.__parameters = sequence_node:parameter_map()
	self.__subtitles = {}

	for node in sequence_node:children() do
		local string_id = self:_xml_assert(node:parameter("text_id"), node, string.format("Sequence \"%s\" has entries without text_ids.", self:name()))

		if not managers.localization:exists(string_id) then
			self:_report_bad_string_id(string_id)
		end

		local start_time = self:_xml_assert(tonumber(node:parameter("time")), node, string.format("Sequence \"%s\" has entries without valid times.", self:name()))
		local subtitle = StringIDSubtitle:new(string_id, start_time, tonumber(node:parameter("duration") or 2))

		self:add_subtitle(CoreClass.freeze(subtitle))
	end

	CoreClass.freeze(self.__subtitles)
end

function SubtitleSequence:_report_bad_string_id(string_id)
	Localizer:lookup(string_id)
end

function SubtitleSequence:_xml_assert(condition, node, message)
	return condition or error(string.format("Error parsing \"%s\" - %s", string.gsub(node:file(), "^.*[/\\]", ""), message))
end

function Subtitle:init(string_data, start_time, duration)
	self.__string_data = string_data ~= nil and assert(tostring(string_data), "Invalid string argument.") or ""
	self.__start_time = assert(tonumber(start_time), "Invalid start time argument.")
	self.__duration = duration ~= nil and assert(tonumber(duration), "Invalid duration argument.") or nil
end

function Subtitle:string()
	return self.__string_data
end

function Subtitle:start_time()
	return self.__start_time
end

function Subtitle:end_time()
	return self:start_time() + (self:duration() or math.huge)
end

function Subtitle:duration()
	return self.__duration
end

function Subtitle:is_active_at_time(time)
	return self:start_time() < time and time < self:end_time()
end

function StringIDSubtitle:string()
	assert(managers.localization, "Localization Manager not ready.")

	return managers.localization:text(self.__string_data)
end
