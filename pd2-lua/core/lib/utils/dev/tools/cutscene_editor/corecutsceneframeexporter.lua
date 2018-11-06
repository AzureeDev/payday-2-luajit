require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneFrameVisitor")

CoreCutsceneFrameExporter = CoreCutsceneFrameExporter or class(CoreCutsceneFrameVisitor)

function CoreCutsceneFrameExporter:init(parent_window, cutscene_editor, start_frame, end_frame, collection_name)
	self.super.init(self, parent_window, cutscene_editor, start_frame, end_frame)

	self.__collection_name = assert(tostring(collection_name))
end

function CoreCutsceneFrameExporter:begin()
	self.super.begin(self)

	if not SystemFS:is_dir("/frames") then
		assert(SystemFS:exists("/frames") == false, "A root-level file named \"frames\" exists. Unable to create \"frames\" folder.")
		SystemFS:make_dir("/frames")
	end

	local output_dir = "/frames/" .. self.__collection_name

	if SystemFS:exists(output_dir) then
		SystemFS:delete_file(output_dir)
	end

	SystemFS:make_dir(output_dir)
	self:_disable_visual_aids()
end

function CoreCutsceneFrameExporter:_progress_message(frame)
	return "Writing image " .. self:_image_file_name(frame)
end

function CoreCutsceneFrameExporter:_visit_frame(frame)
	local file_path = string.format("/frames/%s/%s", self.__collection_name, self:_image_file_name(frame))

	Application:screenshot(file_path)
end

function CoreCutsceneFrameExporter:_cleanup()
	self:_enable_visual_aids()
	self.super._cleanup(self)
end

function CoreCutsceneFrameExporter:_image_file_name(frame)
	return string.format("%08i.tga", frame)
end

function CoreCutsceneFrameExporter:_enable_visual_aids()
	if self.__cutscene_editor_camera_was_enabled ~= nil then
		self.__cutscene_editor:set_cutscene_camera_enabled(self.__cutscene_editor_camera_was_enabled)
	end

	if managers.editor then
		if self.__editor_show_camera_info_was_enabled ~= nil then
			managers.editor:set_show_camera_info(self.__editor_show_camera_info_was_enabled)
		end

		if self.__editor_draw_grid_was_enabled ~= nil then
			managers.editor._layer_draw_grid = self.__editor_draw_grid_was_enabled
		end

		if self.__editor_show_marker_was_enabled ~= nil then
			managers.editor._layer_draw_marker = self.__editor_show_marker_was_enabled
		end

		if self.__editor_show_center_was_enabled ~= nil then
			managers.editor._show_center = self.__editor_show_center_was_enabled
		end
	end
end

function CoreCutsceneFrameExporter:_disable_visual_aids()
	self.__cutscene_editor_camera_was_enabled = self.__cutscene_editor:cutscene_camera_enabled()

	self.__cutscene_editor:set_cutscene_camera_enabled(true)

	if managers.editor then
		self.__editor_show_camera_info_was_enabled = managers.editor._show_camera_position == true
		self.__editor_draw_grid_was_enabled = managers.editor._layer_draw_grid == true
		self.__editor_show_marker_was_enabled = managers.editor._layer_draw_marker == true
		self.__editor_show_center_was_enabled = managers.editor._show_center == true

		managers.editor:set_show_camera_info(false)

		managers.editor._layer_draw_grid = false
		managers.editor._layer_draw_marker = false
		managers.editor._show_center = false
	end
end
