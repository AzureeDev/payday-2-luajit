CinematicCameraUnitElement = CinematicCameraUnitElement or class(MissionElement)
CinematicCameraUnitElement.ON_EXECUTED_ALTERNATIVES = {
	"camera_done"
}

function CinematicCameraUnitElement:init(unit)
	CinematicCameraUnitElement.super.init(self, unit)

	self._hed.state = "none"
	self._camera_unit = safe_spawn_unit(Idstring("units/pd2_cinematics/cs_camera/cs_camera"), self._unit:position(), self._unit:rotation())

	self._unit:link(self._unit:orientation_object():name(), self._camera_unit, self._camera_unit:orientation_object():name())
	table.insert(self._save_values, "state")
end

function CinematicCameraUnitElement:layer_finished(...)
	CinematicCameraUnitElement.super.layer_finished(self, ...)
	self:_on_state_changed()
end

function CinematicCameraUnitElement:selected(...)
	CinematicCameraUnitElement.super.selected(self, ...)
end

function CinematicCameraUnitElement:deselected(...)
	CinematicCameraUnitElement.super.deselected(self, ...)
end

function CinematicCameraUnitElement:test_element()
	self._camera_unit:base():start()

	if self._hed.state ~= "none" then
		-- Nothing
	end
end

function CinematicCameraUnitElement:stop_test_element()
	self._camera_unit:base():stop()
	self._camera_unit:base():play_state(Idstring("std/empty"), 1, 0)
end

function CinematicCameraUnitElement:_get_states()
	local states = {}

	for _, state in ipairs(self._camera_unit:anim_state_machine():config():states()) do
		table.insert(states, state:name():s())
	end

	table.sort(states)

	return states
end

function CinematicCameraUnitElement:_show_camera_gui()
	self._camera_unit:base():create_ews()
end

function CinematicCameraUnitElement:_on_state_changed()
	self._camera_unit:base():set_current_state_name(self._hed.state)
end

function CinematicCameraUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local states_params = {
		default = "none",
		name = "State:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select a state",
		sorted = true,
		panel = panel,
		sizer = panel_sizer,
		options = self:_get_states(),
		value = self._hed.state
	}
	local states = CoreEWS.combobox(states_params)

	states:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "state",
		ctrlr = states
	})
	states:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_on_state_changed"), nil)

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("SELECT", "Open camera player", CoreEws.image_path("sequencer\\clip_icon_camera_00.png"), nil)
	toolbar:connect("SELECT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_show_camera_gui"), nil)
	toolbar:realize()
	panel_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")

	local help = {
		text = "Select a state to play on the camera",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end

function CinematicCameraUnitElement:destroy(...)
	if alive(self._camera_unit) then
		World:delete_unit(self._camera_unit)
	end

	CinematicCameraUnitElement.super.destroy(self, ...)
end

function CinematicCameraUnitElement:add_to_mission_package()
	local unit_name = Idstring("units/pd2_cinematics/cs_camera/cs_camera")

	managers.editor:add_to_world_package({
		category = "units",
		name = unit_name:s(),
		continent = self._unit:unit_data().continent
	})
end
