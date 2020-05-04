require("core/lib/utils/dev/ews/CoreTableEditorPanel")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneEditorProject")

CoreCutsceneAnimationPatchesPanel = CoreCutsceneAnimationPatchesPanel or class(CoreTableEditorPanel)

function CoreCutsceneAnimationPatchesPanel:init(parent)
	self.super.init(self, parent)

	self.__unit_types = {}

	self:freeze()
	self:add_column("Unit Name")
	self:add_column("Blend Set")
	self:add_column("Animation")
	self:thaw()
end

function CoreCutsceneAnimationPatchesPanel:unit_types()
	return self.__unit_types or {}
end

function CoreCutsceneAnimationPatchesPanel:set_unit_types(unit_types)
	assert(type(unit_types) == "table" and table.true_for_all(table.map_values(unit_types), function (v)
		return DB:has("unit", tostring(v):id())
	end), "Expected unit_types to be a table mapping actor names to Unit type names.")

	self.__unit_types = unit_types

	self:_refresh_fields_panel()
	self:_refresh_buttons_panel()
end

function CoreCutsceneAnimationPatchesPanel:patches()
	local patches = {}
	local list_ctrl = self.__list_ctrl
	local row_count = list_ctrl:item_count()

	for row = 0, row_count - 1 do
		local unit_name = list_ctrl:get_item(row, 0)
		local blend_set = list_ctrl:get_item(row, 1)
		local animation = list_ctrl:get_item(row, 2)
		patches[unit_name] = patches[unit_name] or {}
		patches[unit_name][blend_set] = animation
	end

	return patches
end

function CoreCutsceneAnimationPatchesPanel:set_patches(patches)
	self:freeze()
	self:clear()

	for unit_name, overrides in pairs(patches or {}) do
		for blend_set, animation in pairs(overrides) do
			self:add_item(unit_name, blend_set, animation)
		end
	end

	self:thaw()
end

function CoreCutsceneAnimationPatchesPanel:_sizer_with_editable_fields(parent)
	local sizer = EWS:BoxSizer("VERTICAL")
	local unit_name_enabled = self:selected_item() ~= nil and not table.empty(self:unit_types())
	local unit_name_label = EWS:StaticText(parent, "Unit Name:")

	unit_name_label:set_enabled(unit_name_enabled)
	sizer:add(unit_name_label, 0, 5, "TOP,LEFT,RIGHT")

	local unit_name_dropdown = self:_create_unit_name_dropdown(parent)

	unit_name_dropdown:set_enabled(unit_name_enabled)
	sizer:add(unit_name_dropdown, 0, 5, "ALL,EXPAND")
	self:_create_labeled_text_field("Blend Set", parent, sizer)

	local animation_text_field = self:_create_animation_text_field(parent)

	sizer:add(animation_text_field, 0, 0, "EXPAND")

	if unit_name_enabled then
		unit_name_dropdown:set_focus()
	end

	return sizer
end

function CoreCutsceneAnimationPatchesPanel:_create_unit_name_dropdown(parent)
	local value = self:selected_item_value("Unit Name")
	local control = EWS:ComboBox(parent, "", "", "CB_DROPDOWN,CB_READONLY,CB_SORT")

	control:freeze()

	local first_value = nil

	for unit_name, _ in pairs(self:unit_types()) do
		first_value = first_value or unit_name

		control:append(unit_name)
	end

	if value then
		control:set_value(value)
	end

	control:set_min_size(control:get_min_size():with_x(0))
	control:connect("EVT_COMMAND_COMBOBOX_SELECTED", self:_make_control_edited_callback(control, "Unit Name"))
	control:thaw()

	return control
end

function CoreCutsceneAnimationPatchesPanel:_create_animation_text_field(parent)
	local sizer = EWS:BoxSizer("HORIZONTAL")
	local labeled_text_field_sizer = EWS:BoxSizer("VERTICAL")
	local text_ctrl = self:_create_labeled_text_field("Animation", parent, labeled_text_field_sizer)
	local button = EWS:Button(parent, "Browse...")

	button:set_enabled(self:selected_item() ~= nil)
	button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_browse_for_animation"), text_ctrl)
	sizer:add(labeled_text_field_sizer, 1, 0, "EXPAND")
	sizer:add(button, 0, 4, "BOTTOM,RIGHT,ALIGN_BOTTOM")

	return sizer
end

function CoreCutsceneAnimationPatchesPanel:_refresh_buttons_panel()
	self.super._refresh_buttons_panel(self)
	self.__add_button:set_enabled(not table.empty(self:unit_types()))
end

function CoreCutsceneAnimationPatchesPanel:_on_browse_for_animation(text_ctrl)
	local dir, path = self:_absolute_dir_and_path(text_ctrl:get_value())
	dir = dir or self.__default_dir or managers.database:base_path() .. "data"
	path = path or ""
	local dialog = EWS:FileDialog(self:_top_level_window(), "Select an Animation File", dir, path, "Diesel Animation (*.diesel)|*.diesel", "OPEN,FILE_MUST_EXIST")

	if dialog:show_modal() then
		self.__default_dir = dialog:get_directory()
		local relative_path = string.match(dialog:get_path(), "^" .. managers.database:base_path() .. "(.*)")

		text_ctrl:set_value(relative_path)
	end
end

function CoreCutsceneAnimationPatchesPanel:_absolute_dir_and_path(relative_path)
	relative_path = Application:nice_path(relative_path or "", false)

	if string.begins(relative_path, "data\\") then
		local absolute_path = managers.database:base_path() .. relative_path
		local absolute_dir = string.match(absolute_path, "^(.+)\\")

		return absolute_dir, absolute_path
	else
		return nil, nil
	end
end
