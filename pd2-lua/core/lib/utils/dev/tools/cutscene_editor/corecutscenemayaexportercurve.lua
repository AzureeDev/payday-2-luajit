CoreCutsceneMayaExporterCurve = CoreCutsceneMayaExporterCurve or class()
CoreCutsceneMayaExporterCurveSet = CoreCutsceneMayaExporterCurveSet or class()
local SAMPLED_COMPONENTS = {
	"x",
	"y",
	"z"
}
local ROTATION_ACCESS_METHODS = {
	z = "roll",
	x = "yaw",
	y = "pitch"
}
local VALID_MAYA_NODE_TYPES = {}

for _, char in ipairs({
	"A",
	"L",
	"T",
	"U"
}) do
	table.insert(VALID_MAYA_NODE_TYPES, "animCurveT" .. char)
	table.insert(VALID_MAYA_NODE_TYPES, "animCurveU" .. char)
end

function CoreCutsceneMayaExporterCurve:init(maya_node_type, node_name, attribute_name)
	self.__samples = {}
	self.__sample_count = 0
	self.__maya_node_type = assert(tostring(maya_node_type), "Must supply a valid maya node type.")
	self.__node_name = assert(tostring(node_name), "Must supply a valid node name.")
	self.__attribute_name = assert(tostring(attribute_name), "Must supply a valid attribute name.")

	assert(table.contains(VALID_MAYA_NODE_TYPES, self.__maya_node_type), string.format("Unsupported maya node type \"%s\". Only subclasses of animCurve are supported.", self.__maya_node_type))
	assert(string.match(self.__node_name, "^%l"), string.format("Unsupported node name \"%s\". Must start with a lower-case letter.", self.__node_name))
end

function CoreCutsceneMayaExporterCurve:add_sample(frame, value)
	if frame ~= (self.__previous_frame or -1) + 1 then
		self.__previous_value = nil
	end

	if value ~= self.__previous_value then
		self.__samples[frame] = value
		self.__sample_count = self.__sample_count + 1
		self.__previous_value = value
	end

	self.__previous_frame = frame
end

function CoreCutsceneMayaExporterCurve:last_added_value()
	return self.__previous_value
end

function CoreCutsceneMayaExporterCurve:write(file)
	if self.__sample_count >= 1 then
		local curve_name = string.gsub(self.__node_name, "[:|]", "_") .. "_" .. self.__attribute_name

		file:write(string.format("createNode %s -name \"%s\";\n", self.__maya_node_type, curve_name))
		file:write("\tsetAttr \".tangentType\" 5;\n")
		file:write("\tsetAttr \".weightedTangents\" no;\n")

		if self.__sample_count == 1 then
			file:write("\tsetAttr -size 1 \".keyTimeValue[0]\"")
		else
			file:write(string.format("\tsetAttr -size %i \".keyTimeValue[0:%i]\"", self.__sample_count, self.__sample_count - 1))
		end

		local max_frame = table.maxn(self.__samples)

		for frame = 0, max_frame do
			local value = self.__samples[frame]

			if value ~= nil then
				file:write(string.format(" %i %g", frame, value))
			end
		end

		file:write(";\n")
		file:write(string.format("connectAttr \"%s.output\" \"%s.%s\";\n", curve_name, self.__node_name, self.__attribute_name))
	end
end

function CoreCutsceneMayaExporterCurveSet:init(target_object_name)
	self.__curves = {}

	for _, axis in ipairs(SAMPLED_COMPONENTS) do
		self.__curves["t" .. axis] = CoreCutsceneMayaExporterCurve:new("animCurveTL", target_object_name, "t" .. axis)
		self.__curves["r" .. axis] = CoreCutsceneMayaExporterCurve:new("animCurveTA", target_object_name, "r" .. axis)
	end
end

function CoreCutsceneMayaExporterCurveSet:add_sample(frame, object)
	local position = object:local_position()
	local rotation = object:new_local_rotation()

	for _, component in ipairs(SAMPLED_COMPONENTS) do
		local position_value = position[component]

		self.__curves["t" .. component]:add_sample(frame, position_value)

		local method = ROTATION_ACCESS_METHODS[component]
		local rotation_value = rotation[method](rotation)

		self.__curves["r" .. component]:add_sample(frame, rotation_value)
	end
end

function CoreCutsceneMayaExporterCurveSet:write(file)
	for _, curve in pairs(self.__curves) do
		curve:write(file)
	end
end
