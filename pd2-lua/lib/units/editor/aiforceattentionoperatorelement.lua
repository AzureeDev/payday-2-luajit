AIForceAttentionOperatorElement = AIForceAttentionOperatorElement or class(MissionElement)
local element_unit_name_id = Idstring("units/dev_tools/mission_elements/ai_force_attention/ai_force_attention")
local valid_operations = {
	"disable"
}
local element_label_base = "Operating On: "

function AIForceAttentionOperatorElement:init(unit)
	AIForceAttentionOperatorElement.super.init(self, unit)

	self._hed.operation = "disable"
	self._hed.element_id = nil

	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "element_id")
end

function AIForceAttentionOperatorElement:select_element(label)
	local function f(unit)
		if self._hed.att_unit_id == unit:unit_data().unit_id then
			return false
		end

		return managers.editor:layer("Mission"):category_map()[unit:type():s()] and unit:name() == element_unit_name_id
	end

	local dialog = SingleSelectUnitByNameModal:new("Select Unit", f)
	local unit = dialog:_selected_item_unit()
	self._hed.element_id = unit and unit:unit_data().unit_id or self._hed.element_id

	if unit then
		label:set_label(element_label_base .. unit:unit_data().name_id)
	end
end

function AIForceAttentionOperatorElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local element_unit_panel_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "Force Attention Element")

	panel_sizer:add(element_unit_panel_sizer, 0, 1, "EXPAND,LEFT")

	local element_unit = self._hed.element_id and managers.editor:unit_with_id(self._hed.element_id)
	local element_unit_label_text = element_label_base .. (element_unit and element_unit:unit_data().name_id or "None")
	local element_unit_label = EWS:StaticText(panel, element_unit_label_text, "ELEMENT_UNIT_LABEL", nil)
	local select_element_unit_btn = EWS:BitmapButton(panel, CoreEws.image_path("world_editor\\unit_by_name_list.png"), "SELECT_ELEMENT_UNIT", nil)

	select_element_unit_btn:set_tool_tip("Select force attention element to operate on")
	select_element_unit_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "select_element", element_unit_label), nil)
	element_unit_panel_sizer:add(select_element_unit_btn, 0, 1, "EXPAND,LEFT")
	element_unit_panel_sizer:add(element_unit_label, 0, 5, "EXPAND,LEFT")
	self:_build_value_combobox(panel, panel_sizer, "operation", valid_operations)
	self:_add_help_text("Controls an 'ai_force_attention' unit.")
end
