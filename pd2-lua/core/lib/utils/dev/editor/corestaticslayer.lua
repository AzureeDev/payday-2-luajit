core:module("CoreStaticsLayer")
core:import("CoreStaticLayer")
core:import("CoreEditorUtils")
core:import("CoreEws")

StaticsLayer = StaticsLayer or class(CoreStaticLayer.StaticLayer)

function StaticsLayer:init(owner)
	local types = CoreEditorUtils.layer_type("statics")

	StaticsLayer.super.init(self, owner, "statics", types, "statics_layer")

	self._uses_continents = true
end

function StaticsLayer:build_panel(notebook)
	StaticsLayer.super.build_panel(self, notebook)

	return self._ews_panel, true
end

function StaticsLayer:add_btns_to_toolbar(...)
	StaticsLayer.super.add_btns_to_toolbar(self, ...)
	self._btn_toolbar:add_tool("MOVE_TO_CONTINENT", "Move to continent", CoreEws.image_path("toolbar\\copy_folder_16x16.png"), "Move to continent")
	self._btn_toolbar:connect("MOVE_TO_CONTINENT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_move_to_continent"), nil)
end

function StaticsLayer:_on_gui_move_to_continent()
	if #self._selected_units == 0 then
		return
	end

	local continent = nil
	local continents = table.map_keys(managers.editor:continents())

	table.delete(continents, managers.editor:current_continent_name())

	if #continents > 1 then
		local dialog = EWS:SingleChoiceDialog(Global.frame_panel, "Select which continent to move units:", "Continents", continents, "")

		dialog:show_modal()

		continent = dialog:get_string_selection()

		if not continent or continent == "" then
			return nil
		end
	else
		continent = continents[1]
	end

	self:move_to_continent(continent)
end

function StaticsLayer:set_enabled(enabled)
	if not enabled then
		managers.editor:output_warning("Don't want to disable Statics layer since it would cause all dynamics to fall.")
	end

	return false
end
