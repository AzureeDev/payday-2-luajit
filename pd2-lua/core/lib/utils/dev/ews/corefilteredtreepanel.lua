require("core/lib/utils/dev/ews/tree_control/CoreFilteredTreeControl")

CoreFilteredTreePanel = CoreFilteredTreePanel or class()

function CoreFilteredTreePanel:init(parent_frame)
	self:_create_panel(parent_frame)

	self._tree_refresh_timeout = 0
end

function CoreFilteredTreePanel:add_to_sizer(sizer, proportion, border, flags)
	return sizer:add(self._panel, proportion, border, flags)
end

function CoreFilteredTreePanel:connect(event_type, script_callback, script_data)
	return self:_tree_control():connect(event_type, script_callback, script_data)
end

function CoreFilteredTreePanel:update(time, delta_time)
	if self._tree_refresh_timeout > 0 then
		self._tree_refresh_timeout = self._tree_refresh_timeout - delta_time

		if self._tree_refresh_timeout <= 0 and self:_tree_control() then
			self._tree_refresh_timeout = 0

			self:_tree_control():refresh_tree()
		end
	end
end

function CoreFilteredTreePanel:_tree_control()
	return self._filtered_tree_control
end

function CoreFilteredTreePanel:_create_panel(parent_frame)
	self._panel = EWS:Panel(parent_frame, "", "")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	self._panel:set_sizer(panel_sizer)

	local filter_panel, filter_text_ctrl = self:_create_filter_bar_panel(self._panel)

	panel_sizer:add(filter_panel, 0, 0, "EXPAND")

	self._filtered_tree_control = CoreFilteredTreeControl:new(self._panel)

	self._filtered_tree_control:add_to_sizer(panel_sizer, 1, 0, "EXPAND")
	self._filtered_tree_control:add_filter(function (node)
		return string.find(node:path(), filter_text_ctrl:get_value(), 1, true)
	end)
	filter_text_ctrl:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "_on_filter_text_updated"))
	filter_text_ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "_on_filter_enter_pressed"))
end

function CoreFilteredTreePanel:_create_filter_bar_panel(parent_frame)
	local panel = EWS:Panel(parent_frame, "", "")
	local panel_sizer = EWS:BoxSizer("HORIZONTAL")

	panel:set_sizer(panel_sizer)

	local image = EWS:BitmapButton(panel, CoreEWS.image_path("magnifying_glass_32x32.png"), "", "NO_BORDER")

	panel_sizer:add(image, 0, 5, "TOP,BOTTOM,LEFT,EXPAND")

	local filter_text_ctrl = EWS:TextCtrl(panel, "", "", "")

	panel_sizer:add(filter_text_ctrl, 1, 5, "LEFT,RIGHT,ALIGN_CENTER_VERTICAL")

	return panel, filter_text_ctrl
end

function CoreFilteredTreePanel:_on_filter_text_updated()
	self._tree_refresh_timeout = 0.25
end

function CoreFilteredTreePanel:_on_filter_enter_pressed()
	if self._tree_refresh_timeout > 0 then
		self._tree_refresh_timeout = 0

		self:_tree_control():refresh_tree()
	end

	self:_tree_control():expand(true)
end
