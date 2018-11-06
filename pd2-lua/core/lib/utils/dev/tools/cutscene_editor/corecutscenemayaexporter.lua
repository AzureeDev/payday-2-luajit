require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneFrameVisitor")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneMayaExporterCurve")

CoreCutsceneMayaExporter = CoreCutsceneMayaExporter or class(CoreCutsceneFrameVisitor)
CoreCutsceneMayaExporter.MAYA_VERSION = 8.5

function CoreCutsceneMayaExporter:init(parent_window, cutscene_editor, start_frame, end_frame, output_path)
	self.super.init(self, parent_window, cutscene_editor, start_frame, end_frame)

	self.__output_path = output_path
	self.__sampled_units = {}
	self.__curve_sets = {}

	assert(type(self.__output_path) == "string", "Must supply a valid output path.")
end

function CoreCutsceneMayaExporter:add_unit(unit_name, unit)
	local existing_unit = self.__sampled_units[unit_name]

	if existing_unit == nil then
		self.__sampled_units[unit_name] = unit
	elseif existing_unit ~= unit then
		error(string.format("Duplicate unit name \"%s\" used for \"%s\" and \"%s\".", unit_name, existing_unit:name(), unit:name()))
	end
end

function CoreCutsceneMayaExporter:_visit_frame(frame)
	self:_sample_animation_curves()
end

function CoreCutsceneMayaExporter:_done(aborted)
	if not aborted then
		local file = io.open(self.__output_path, "w")

		self:_write_header(file)
		self:_write_hierarchies(file)
		self:_write_camera_node(file, self:_combined_camera_node_name())
		self:_write_animation_curves(file)
		io.close(file)
	end
end

function CoreCutsceneMayaExporter:_combined_camera_node_name()
	local node_name = "camera_directed"

	while self.__sampled_units[node_name] ~= nil do
		local node_name, num_suffix = string.match(node_name, "(.-)(%d*)$")
		num_suffix = tonumber(num_suffix)
		node_name = node_name_without_num_suffix .. (num_suffix and num_suffix + 1 or "")
	end

	return node_name
end

function CoreCutsceneMayaExporter:_write_header(file)
	file:write(string.format("//Maya ASCII %.1f scene\n", self.MAYA_VERSION))
	file:write(string.format("requires maya \"%.1f\";\n", self.MAYA_VERSION))
	file:write("currentUnit -l centimeter -a degree -t ntsc;\n")
	file:write("createNode transform -s -n \"persp\";\n")
	file:write("\tsetAttr \".v\" no;\n")
	file:write("\tsetAttr \".t\" -type \"double3\" 28 -29 21 ;\n")
	file:write("\tsetAttr \".r\" -type \"double3\" 62.482924915355788 -3.1805546814635168e-015 43.994913994745808;\n")
	file:write("createNode camera -s -n \"perspShape\" -p \"persp\";\n")
	file:write("\tsetAttr -k off \".v\" no;\n")
	file:write("\tsetAttr \".fl\" 34.999999999999993;\n")
	file:write("\tsetAttr \".ncp\" 1;\n")
	file:write("\tsetAttr \".fcp\" 10000;\n")
	file:write("\tsetAttr \".coi\" 45.453272709454041;\n")
	file:write("\tsetAttr \".imn\" -type \"string\" \"persp\";\n")
	file:write("\tsetAttr \".den\" -type \"string\" \"persp_depth\";\n")
	file:write("\tsetAttr \".man\" -type \"string\" \"persp_mask\";\n")
	file:write("\tsetAttr \".hc\" -type \"string\" \"viewSet -p %camera\";\n")
	file:write("createNode transform -s -n \"top\";\n")
	file:write("\tsetAttr \".v\" no;\n")
	file:write("\tsetAttr \".t\" -type \"double3\" 0 0 100.1 ;\n")
	file:write("createNode camera -s -n \"topShape\" -p \"top\";\n")
	file:write("\tsetAttr -k off \".v\" no;\n")
	file:write("\tsetAttr \".rnd\" no;\n")
	file:write("\tsetAttr \".coi\" 100.1;\n")
	file:write("\tsetAttr \".ow\" 30;\n")
	file:write("\tsetAttr \".imn\" -type \"string\" \"top\";\n")
	file:write("\tsetAttr \".den\" -type \"string\" \"top_depth\";\n")
	file:write("\tsetAttr \".man\" -type \"string\" \"top_mask\";\n")
	file:write("\tsetAttr \".hc\" -type \"string\" \"viewSet -t %camera\";\n")
	file:write("\tsetAttr \".o\" yes;\n")
	file:write("createNode transform -s -n \"front\";\n")
	file:write("\tsetAttr \".v\" no;\n")
	file:write("\tsetAttr \".t\" -type \"double3\" 0 -100.1 0 ;\n")
	file:write("\tsetAttr \".r\" -type \"double3\" 89.999999999999986 0 0 ;\n")
	file:write("createNode camera -s -n \"frontShape\" -p \"front\";\n")
	file:write("\tsetAttr -k off \".v\" no;\n")
	file:write("\tsetAttr \".rnd\" no;\n")
	file:write("\tsetAttr \".coi\" 100.1;\n")
	file:write("\tsetAttr \".ow\" 30;\n")
	file:write("\tsetAttr \".imn\" -type \"string\" \"front\";\n")
	file:write("\tsetAttr \".den\" -type \"string\" \"front_depth\";\n")
	file:write("\tsetAttr \".man\" -type \"string\" \"front_mask\";\n")
	file:write("\tsetAttr \".hc\" -type \"string\" \"viewSet -f %camera\";\n")
	file:write("\tsetAttr \".o\" yes;\n")
	file:write("createNode transform -s -n \"side\";\n")
	file:write("\tsetAttr \".v\" no;\n")
	file:write("\tsetAttr \".t\" -type \"double3\" 100.1 0 0 ;\n")
	file:write("\tsetAttr \".r\" -type \"double3\" 90 4.7708320221952799e-014 89.999999999999986;\n")
	file:write("createNode camera -s -n \"sideShape\" -p \"side\";\n")
	file:write("\tsetAttr -k off \".v\" no;\n")
	file:write("\tsetAttr \".rnd\" no;\n")
	file:write("\tsetAttr \".coi\" 100.1;\n")
	file:write("\tsetAttr \".ow\" 30;\n")
	file:write("\tsetAttr \".imn\" -type \"string\" \"side\";\n")
	file:write("\tsetAttr \".den\" -type \"string\" \"side_depth\";\n")
	file:write("\tsetAttr \".man\" -type \"string\" \"side_mask\";\n")
	file:write("\tsetAttr \".hc\" -type \"string\" \"viewSet -s %camera\";\n")
	file:write("\tsetAttr \".o\" yes;\n")
	file:write("createNode lightLinker -n \"lightLinker1\";\n")
	file:write("\tsetAttr -s 2 \".lnk\";\n")
	file:write("\tsetAttr -s 2 \".slnk\";\n")
	file:write("createNode displayLayerManager -n \"layerManager\";\n")
	file:write("createNode displayLayer -n \"defaultLayer\";\n")
	file:write("createNode renderLayerManager -n \"renderLayerManager\";\n")
	file:write("createNode renderLayer -n \"defaultRenderLayer\";\n")
	file:write("\tsetAttr \".g\" yes;\n")
	file:write("select -ne :time1;\n")
	file:write("\tsetAttr \".o\" 0;\n")
	file:write("createNode script -name \"sceneConfigurationScriptNode\";\n")
	file:write("\tsetAttr \".before\" -type \"string\" \"playbackOptions -loop once -minTime " .. self.__start_frame .. " -maxTime " .. self.__end_frame .. " -animationStartTime " .. self.__start_frame .. " -animationEndTime " .. self.__end_frame .. "\";\n")
	file:write("\tsetAttr \".scriptType\" 6;\n")
end

function CoreCutsceneMayaExporter:_write_hierarchies(file)
	for unit_name, unit in pairs(self.__sampled_units) do
		if string.begins(unit_name, "camera") then
			self:_write_camera_node(file, unit_name)
		elseif string.begins(unit_name, "locator") then
			file:write(string.format("createNode transform -name \"%s\";\n", unit_name))
			file:write(string.format("createNode locator -name \"%sShape\" -parent \"%s\";\n", unit_name, unit_name))
			file:write("\tsetAttr -keyable off \".visibility\";\n")
		else
			local object = unit:orientation_object()

			file:write(string.format("createNode transform -name \"%s\";\n", self:_maya_node_name(unit_name, object)))
			file:write("\taddAttr -longName \"unitTypeName\" -dataType \"string\";\n")
			file:write("\tsetAttr -type \"string\" \".unitTypeName\" " .. unit:name() .. ";\n")

			for _, child in ipairs(object.children and object:children() or {}) do
				self:_write_hierarchy_entry_for_object(file, unit_name, child, object)
			end
		end
	end
end

function CoreCutsceneMayaExporter:_write_hierarchy_entry_for_object(file, unit_name, object, parent_object)
	if self:_should_export(unit_name, object) then
		local object_name = self:_maya_node_name(unit_name, object)
		local full_object_name = self:_maya_node_name(unit_name, object, true)
		local full_parent_object_name = parent_object and self:_maya_node_name(unit_name, parent_object, true)

		file:write(string.format("createNode joint -name \"%s\"", object_name))

		if full_parent_object_name then
			file:write(string.format(" -parent \"%s\"", full_parent_object_name))
		end

		file:write(";\n")

		if full_parent_object_name then
			file:write(string.format("\tconnectAttr \"%s.scale\" \"%s.inverseScale\";\n", full_parent_object_name, full_object_name))
		end
	end

	for _, child in ipairs(object.children and object:children() or {}) do
		self:_write_hierarchy_entry_for_object(file, unit_name, child, object)
	end
end

function CoreCutsceneMayaExporter:_write_camera_node(file, camera_name)
	file:write("createNode transform -name \"" .. camera_name .. "\";\n")
	file:write(string.format("createNode camera -name \"%sShape\" -parent \"%s\";\n", camera_name, camera_name))
	file:write("\tsetAttr -keyable off \".visibility\";\n")
	file:write("\tsetAttr \".renderable\" no;\n")
	file:write("\tsetAttr \".cameraAperture\" -type \"double2\" 1.78 1.0;\n")
	file:write("\tsetAttr \".lensSqueezeRatio\" 1.0;\n")
	file:write("\tsetAttr \".filmFit\" 0;\n")
	file:write("\tsetAttr \".nearClipPlane\" 1;\n")
	file:write("\tsetAttr \".farClipPlane\" 10000;\n")
	file:write("\tsetAttr \".orthographicWidth\" 30;\n")
	file:write("\tsetAttr \".imageName\" -type \"string\" \"" .. camera_name .. "\";\n")
	file:write("\tsetAttr \".depthName\" -type \"string\" \"" .. camera_name .. "_depth\";\n")
	file:write("\tsetAttr \".maskName\" -type \"string\" \"" .. camera_name .. "_mask\";\n")
end

function CoreCutsceneMayaExporter:_write_animation_curves(file)
	for unit_name, curve_sets in pairs(self.__curve_sets) do
		for _, curve_set in pairs(curve_sets) do
			curve_set:write(file)
		end
	end

	if self.__combined_camera_focal_length_curve then
		self.__combined_camera_focal_length_curve:write(file)
	end
end

function CoreCutsceneMayaExporter:_sample_animation_curves()
	for unit_name, unit in pairs(self.__sampled_units) do
		if string.begins(unit_name, "camera") or string.begins(unit_name, "locator") then
			local object = assert(unit:get_object("locator"), "Object \"locator\" not found inside locator Unit.")

			self:_curve_set(unit_name, object):add_sample(self.__frame, object)
		else
			self:_sample_animation_curves_for_hierarchy(unit_name, unit:orientation_object())
		end
	end

	local cutscene_player = self.__cutscene_editor._player
	local camera_object = cutscene_player:_camera_object()

	if camera_object then
		self:_curve_set(self:_combined_camera_node_name(), "just_an_identifier"):add_sample(self.__frame, camera_object)
		self:_combined_camera_focal_length_curve():add_sample(self.__frame, self:_fov_to_focal_length(cutscene_player:camera_attributes().fov))
	end
end

function CoreCutsceneMayaExporter:_sample_animation_curves_for_hierarchy(unit_name, object)
	if self:_should_export(unit_name, object) then
		self:_curve_set(unit_name, object):add_sample(self.__frame, object)
	end

	for _, child in ipairs(object.children and object:children() or {}) do
		self:_sample_animation_curves_for_hierarchy(unit_name, child)
	end
end

function CoreCutsceneMayaExporter:_curve_set(unit_name, object)
	local curve_sets_for_unit = self.__curve_sets[unit_name]
	local curve_set = curve_sets_for_unit and curve_sets_for_unit[object]

	if curve_set == nil then
		if curve_sets_for_unit == nil then
			curve_sets_for_unit = {}
			self.__curve_sets[unit_name] = curve_sets_for_unit
		end

		local target_object_name = self:_maya_node_name(unit_name, object, true)
		curve_set = CoreCutsceneMayaExporterCurveSet:new(target_object_name)
		curve_sets_for_unit[object] = curve_set
	end

	return curve_set
end

function CoreCutsceneMayaExporter:_combined_camera_focal_length_curve()
	if self.__combined_camera_focal_length_curve == nil then
		self.__combined_camera_focal_length_curve = CoreCutsceneMayaExporterCurve:new("animCurveTU", self:_combined_camera_node_name() .. "Shape", "focalLength")
	end

	return self.__combined_camera_focal_length_curve
end

function CoreCutsceneMayaExporter:_fov_to_focal_length(fov)
	local focal_length = math.tan(math.deg(0.00872665 * fov))

	return 0.89 / (focal_length * 0.03937)
end

function CoreCutsceneMayaExporter:_should_export(unit_name, object)
	return type_name(object) == "Object3D"
end

function CoreCutsceneMayaExporter:_maya_node_name(unit_name, object, full_path)
	if string.begins(unit_name, "camera") or string.begins(unit_name, "locator") then
		return unit_name
	end

	local valid_node_name = string.match(unit_name, "^%d") and "actor" .. unit_name or unit_name
	local long_name = valid_node_name .. ":" .. object:name()
	local parent = full_path and object:parent()

	return parent and parent:parent() and parent:parent():parent() and self:_maya_node_name(unit_name, parent, full_path) .. "|" .. long_name or long_name
end
