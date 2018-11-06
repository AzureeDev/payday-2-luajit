require("core/lib/utils/dev/ews/CoreAnimationStateTreePanel")

CorePuppeteer = CorePuppeteer or class()
CorePuppeteer.EDITOR_TITLE = "Puppeteer"

function CorePuppeteer:init(unit)
	if not unit and managers.editor then
		unit = managers.editor:selected_unit()
	end

	unit = unit or World:selected_unit()

	self:_create_window(unit):set_visible(true)
	CoreEWS.check_news(self._window, "puppeteer", true)

	if managers.editor then
		self._selected_unit_callback = managers.editor:add_selected_unit_callback(callback(self, self, "_on_selected_unit_changed"))
	end
end

function CorePuppeteer:_create_window(unit)
	self._window = EWS:Frame(CorePuppeteer.EDITOR_TITLE, Vector3(100, 500, 0), Vector3(255, 450, 0), "STAY_ON_TOP,RESIZE_BORDER,CLOSE_BOX,CAPTION,SYSTEM_MENU,CLIP_CHILDREN")

	self._window:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "_on_close"), "")

	local main_box = EWS:BoxSizer("VERTICAL")

	self._window:set_sizer(main_box)

	self._state_tree_panel = CoreAnimationStateTreePanel:new(self._window, unit)

	self._state_tree_panel:add_to_sizer(main_box, 1, 0, "EXPAND")
	self._state_tree_panel:connect("EVT_COMMAND_TREE_ITEM_ACTIVATED", callback(self, self, "_on_tree_item_activated"))
	main_box:add(self:_create_options_panel(), 0, 0, "EXPAND")

	return self._window
end

function CorePuppeteer:_create_options_panel()
	local panel = EWS:Panel(self._window, "", "")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local time_multiplier_slider = EWS:Slider(panel, TimerManager:game_animation():multiplier() * 100, 0, 100, "", "")

	time_multiplier_slider:connect("EVT_SCROLL_CHANGED", callback(self, self, "_on_time_multiplier_slider_updated"), time_multiplier_slider)
	time_multiplier_slider:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "_on_time_multiplier_slider_updated"), time_multiplier_slider)
	panel_sizer:add(EWS:StaticText(panel, "Playback Rate:"), 0, 8, "TOP,LEFT,EXPAND")
	panel_sizer:add(time_multiplier_slider, 0, 0, "EXPAND")

	self._drive_movement_checkbox = EWS:CheckBox(panel, "Drive Position")
	self._drive_movement_checkbox_callback = callback(self, self, "_on_drive_movement_checkbox_clicked")

	self._drive_movement_checkbox:connect("EVT_COMMAND_CHECKBOX_CLICKED", self._drive_movement_checkbox_callback)
	panel_sizer:add(self._drive_movement_checkbox, 0, 8, "ALL,EXPAND")

	return panel
end

function CorePuppeteer:set_position(newpos)
	self._window:set_position(newpos)
end

function CorePuppeteer:update(time, delta_time)
	self._state_tree_panel:update(time, delta_time)
end

function CorePuppeteer:destroy()
	if alive(self._window) then
		self._window:destroy()

		self._window = nil
	end
end

function CorePuppeteer:close()
	if managers.editor and self._selected_unit_callback then
		managers.editor:remove_selected_unit_callback(self._selected_unit_callback)
	end

	self._window:destroy()
end

function CorePuppeteer:unit()
	if self._state_tree_panel then
		return self._state_tree_panel:unit()
	end
end

function CorePuppeteer:_on_close()
	managers.toolhub:close(CorePuppeteer.EDITOR_TITLE)
end

function CorePuppeteer:_on_tree_item_activated(data, event)
	local tree_node = event:get_item()

	if tree_node and not tree_node:has_children() then
		self:unit():play_state(tree_node:path():id())
	end
end

function CorePuppeteer:_on_drive_movement_checkbox_clicked(data, event)
	if not self:unit() then
		return
	end

	self:unit():set_driving(iff(event:is_checked(), "animation", "script"))
end

function CorePuppeteer:_on_time_multiplier_slider_updated(slider, event)
	TimerManager:game_animation():set_multiplier(slider:get_value() / 100)
end

function CorePuppeteer:_on_selected_unit_changed(selected_unit)
	if selected_unit == self:unit() then
		return
	end

	if self._state_tree_panel then
		self._state_tree_panel:set_unit(selected_unit)
	end

	if self._drive_movement_checkbox then
		self._drive_movement_checkbox:set_value(selected_unit and selected_unit:driving() == "animation")
	end
end
