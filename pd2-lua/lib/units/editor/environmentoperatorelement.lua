EnvironmentOperatorElement = EnvironmentOperatorElement or class(MissionElement)
EnvironmentOperatorElement.ACTIONS = {
	"set",
	"enable_global_override",
	"disable_global_override"
}

function EnvironmentOperatorElement:init(unit)
	EnvironmentOperatorElement.super.init(self, unit)

	self._hed.operation = "set"
	self._hed.environment = ""
	self._hed.blend_time = 0
	self._hed.elements = {}

	table.insert(self._save_values, "environment")
	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "blend_time")

	self._actions = EnvironmentOperatorElement.ACTIONS
end

function EnvironmentOperatorElement:clear(...)
	Application:trace("EnvironmentOperatorElement:clear !!!!!!!!!!!!!!!!!!!   ", self._old_default_environment)
end

function EnvironmentOperatorElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "operation", self._actions, "Select an operation for the selected elements")
	self:_build_value_combobox(panel, panel_sizer, "environment", managers.database:list_entries_of_type("environment"), "Select an environment to use")
	self:_build_value_number(panel, panel_sizer, "blend_time", {
		floats = 2,
		min = 0
	}, "How long this environment should blend in over")
end
