CoreCutsceneFrameExporterDialog = CoreCutsceneFrameExporterDialog or class()

function CoreCutsceneFrameExporterDialog:init(editor_self, editor_callback, parent_window, folder_name, start_frame, end_frame)
	self.__editor_self = editor_self
	self.__editor_callback = editor_callback
	self.__start_frame = start_frame
	self.__end_frame = end_frame
	self.__window = EWS:Frame("Export to Playblast", Vector3(100, 500, 0), Vector3(300, 180, 0), "DEFAULT_DIALOG_STYLE,FRAME_FLOAT_ON_PARENT", parent_window)

	self.__window:set_icon(CoreEWS.image_path("film_reel_16x16.png"))
	self.__window:set_background_colour((EWS:get_system_colour("3DFACE") * 255):unpack())
	self.__window:connect("EVT_CLOSE_WINDOW", callback(self, self, "_on_exit"))

	local sizer = EWS:BoxSizer("VERTICAL")

	self.__window:set_sizer(sizer)

	local folder_name_sizer = self:_create_folder_name_box(folder_name)

	sizer:add(folder_name_sizer, 0, 2, "ALL,EXPAND")

	local frame_range_sizer = self:_create_range_box(start_frame, end_frame)

	sizer:add(frame_range_sizer, 0, 2, "ALL,EXPAND")

	local button_sizer = self:_create_button_box()

	sizer:add(button_sizer, 0, 5, "TOP,LEFT,ALIGN_RIGHT")
	self.__window:set_visible(true)
end

function CoreCutsceneFrameExporterDialog:_create_folder_name_box(folder_name)
	local folder_name_sizer = EWS:StaticBoxSizer(self.__window, "VERTICAL", "Enter a name for the new folder")
	self.__folder_name_ctrl = EWS:TextCtrl(self.__window, folder_name)

	folder_name_sizer:add(self.__folder_name_ctrl, 0, 2, "ALL,EXPAND")

	return folder_name_sizer
end

function CoreCutsceneFrameExporterDialog:_create_range_box(start_frame, end_frame)
	local frame_range_sizer = EWS:StaticBoxSizer(self.__window, "HORIZONTAL", "Frame range")
	local all_button = EWS:RadioButton(self.__window, "All", "frame_range", "ALIGN_CENTER_VERTICAL")
	self.__range_button = EWS:RadioButton(self.__window, "Frames", "frame_range", "ALIGN_CENTER_VERTICAL")

	all_button:set_value(true)
	frame_range_sizer:add(all_button, 0, 2, "ALL,EXPAND")
	frame_range_sizer:add(self.__range_button, 0, 2, "ALL,EXPAND")

	self.__start_frame_ctrl = EWS:TextCtrl(self.__window, start_frame)
	self.__end_frame_ctrl = EWS:TextCtrl(self.__window, end_frame)

	self.__start_frame_ctrl:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "_on_range_ctrl_update"))
	self.__end_frame_ctrl:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "_on_range_ctrl_update"))
	frame_range_sizer:add(EWS:StaticText(self.__window, "from: "), 0, 2, "TOP,LEFT,ALIGN_CENTER_VERTICAL")
	frame_range_sizer:add(self.__start_frame_ctrl, 1, 2, "TOP,ALIGN_RIGHT")
	frame_range_sizer:add(EWS:StaticText(self.__window, "to: "), 0, 2, "TOP,LEFT,ALL,ALIGN_CENTER_VERTICAL")
	frame_range_sizer:add(self.__end_frame_ctrl, 1, 2, "TOP,ALIGN_RIGHT")

	return frame_range_sizer
end

function CoreCutsceneFrameExporterDialog:_create_button_box()
	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local ok_button = EWS:Button(self.__window, "OK")
	local cancel_button = EWS:Button(self.__window, "Cancel")

	ok_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_ok_clicked"))
	cancel_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_exit"))
	button_sizer:add(ok_button, 0, 2, "ALL,ALIGN_RIGHT")
	button_sizer:add(cancel_button, 0, 2, "ALL,ALIGN_RIGHT")

	return button_sizer
end

function CoreCutsceneFrameExporterDialog:_destroy_window()
	if alive(self.__window) then
		self.__window:destroy()
	end

	self.__window = nil
end

function CoreCutsceneFrameExporterDialog:update(time, delta_time)
	if not alive(self.__window) then
		return true
	end
end

function CoreCutsceneFrameExporterDialog:_on_exit()
	self:_destroy_window()
end

function CoreCutsceneFrameExporterDialog:_on_ok_clicked()
	local folder_name = self:_folder_name_input()
	local start_frame, end_frame = nil

	if self.__range_button:get_value() == true then
		start_frame, end_frame = self:_start_end_frame_input()
	else
		end_frame = self.__end_frame
		start_frame = self.__start_frame
	end

	if folder_name and start_frame and end_frame then
		self:_destroy_window()
		self.__editor_callback(self.__editor_self, start_frame, end_frame, folder_name)
	end
end

function CoreCutsceneFrameExporterDialog:_on_range_ctrl_update()
	self.__range_button:set_value(true)
end

function CoreCutsceneFrameExporterDialog:_folder_name_input()
	local folder_name = self.__folder_name_ctrl:get_value()

	if folder_name then
		if string.len(folder_name) <= 3 then
			EWS:MessageDialog(self.__window, "The folder name is too short.", "Invalid Folder Name", "OK,ICON_EXCLAMATION"):show_modal()

			return nil
		elseif string.match(folder_name, "[a-z_0-9]+") ~= folder_name then
			EWS:MessageDialog(self.__window, "The folder name may only contain lower-case letters, numbers and underscores.", "Invalid Folder Name", "OK,ICON_EXCLAMATION"):show_modal()

			return nil
		elseif SystemFS:exists("/frames/" .. folder_name) and EWS:MessageDialog(self.__window, "A folder with that name already exists. Do you want to replace it?", "Replace Existing?", "YES_NO,NO_DEFAULT,ICON_EXCLAMATION"):show_modal() == "ID_NO" then
			return nil
		end
	end

	return folder_name
end

function CoreCutsceneFrameExporterDialog:_start_end_frame_input()
	local start_frame = self.__start_frame_ctrl:get_value()
	local end_frame = self.__end_frame_ctrl:get_value()

	if string.match(start_frame, "[0-9]+") ~= start_frame then
		EWS:MessageDialog(self.__window, "The starting frame is not a valid number.", "Invalid Input", "OK,ICON_EXCLAMATION"):show_modal()

		return nil
	elseif string.match(end_frame, "[0-9]+") ~= end_frame then
		EWS:MessageDialog(self.__window, "The ending frame is not a valid number.", "Invalid Input", "OK,ICON_EXCLAMATION"):show_modal()

		return nil
	elseif tonumber(end_frame) < tonumber(start_frame) then
		EWS:MessageDialog(self.__window, "The ending frame number is smaller than the starting frame number.", "Invalid Range", "OK,ICON_EXCLAMATION"):show_modal()

		return nil
	elseif tonumber(self.__end_frame) < tonumber(end_frame) then
		EWS:MessageDialog(self.__window, "The ending frame number does not exist in the active film track.", "Invalid Range", "OK,ICON_EXCLAMATION"):show_modal()

		return nil
	end

	end_frame = end_frame + 1

	return start_frame, end_frame
end
