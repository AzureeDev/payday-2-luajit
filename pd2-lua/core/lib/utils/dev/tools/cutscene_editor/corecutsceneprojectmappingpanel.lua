require("core/lib/utils/dev/ews/CoreTableEditorPanel")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneEditorProject")

CoreCutsceneProjectMappingPanel = CoreCutsceneProjectMappingPanel or class(CoreTableEditorPanel)

function CoreCutsceneProjectMappingPanel:init(parent)
	self.super.init(self, parent)
	self:freeze()
	self:add_column("Project")
	self:add_column("Output")
	self:thaw()
end

function CoreCutsceneProjectMappingPanel:projects()
	return managers.database:list_entries_of_type("cutscene_project")
end

function CoreCutsceneProjectMappingPanel:mappings()
	local mappings = {}
	local list_ctrl = self.__list_ctrl
	local row_count = list_ctrl:item_count()

	for row = 0, row_count - 1 do
		local project = list_ctrl:get_item(row, 0)
		local output = list_ctrl:get_item(row, 1)
		mappings[project] = output
	end

	return mappings
end

function CoreCutsceneProjectMappingPanel:set_mappings(mappings, project_sort_func)
	self:freeze()
	self:clear()

	if mappings then
		for _, project in ipairs(table.map_keys(mappings, project_sort_func)) do
			local output = mappings[project]

			self:add_item(project, output)
		end
	end

	self.__list_ctrl:autosize_column(0)
	self.__list_ctrl:autosize_column(1)
	self:thaw()
end

function CoreCutsceneProjectMappingPanel:_sizer_with_editable_fields(parent)
	local sizer = EWS:BoxSizer("VERTICAL")
	local project_enabled = self:selected_item() ~= nil and not table.empty(self:projects())
	local project_label = EWS:StaticText(parent, "Project:")

	project_label:set_enabled(project_enabled)
	sizer:add(project_label, 0, 5, "TOP,LEFT,RIGHT")

	local project_dropdown = self:_create_project_dropdown(parent)

	project_dropdown:set_enabled(project_enabled)
	sizer:add(project_dropdown, 0, 5, "ALL,EXPAND")
	self:_create_labeled_text_field("Output", parent, sizer)

	if project_enabled then
		project_dropdown:set_focus()
	end

	return sizer
end

function CoreCutsceneProjectMappingPanel:_create_project_dropdown(parent)
	local value = self:selected_item_value("Project")
	local control = EWS:ComboBox(parent, "", "", "CB_DROPDOWN,CB_READONLY,CB_SORT")

	control:freeze()

	local first_value = nil

	for _, project in pairs(self:projects()) do
		first_value = first_value or project

		control:append(project)
	end

	if value then
		control:set_value(value)
	end

	control:set_min_size(control:get_min_size():with_x(0))
	control:connect("EVT_COMMAND_COMBOBOX_SELECTED", self:_make_control_edited_callback(control, "Project"))
	control:thaw()

	return control
end

function CoreCutsceneProjectMappingPanel:_refresh_buttons_panel()
	self.super._refresh_buttons_panel(self)
	self.__add_button:set_enabled(not table.empty(self:projects()))
end
