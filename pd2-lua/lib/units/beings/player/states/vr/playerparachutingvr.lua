PlayerParachutingVR = PlayerParachuting or Application:error("PlayerParachutingVR needs PlayerParachuting!")
local __init = PlayerParachuting.init

function PlayerParachutingVR:init(...)
	__init(self, ...)

	self._comfort_screen_setting_changed_clbk = callback(self, self, "_on_comfort_screen_setting_changed")
end

local __enter = PlayerParachuting.enter

function PlayerParachutingVR:enter(...)
	__enter(self, ...)

	if managers.vr:get_setting("zipline_screen") then
		self._camera_unit:base():set_hmd_tracking(false)
		managers.menu:open_menu("zipline")

		self._comfort_screen_active = true
	end

	managers.vr:add_setting_changed_callback("zipline_screen", self._comfort_screen_setting_changed_clbk)

	self._parachute_unit = safe_spawn_unit(Idstring("units/pd2_dlc_jerry/props/jry_equipment_parachute/jry_equipment_parachute"), self._unit:position() + Vector3(0, 0, 100), self._unit:rotation())

	self._parachute_unit:damage():run_sequence_simple("animation_unfold")
	self._unit:link(self._unit:orientation_object():name(), self._parachute_unit)
end

local __exit = PlayerParachuting.exit

function PlayerParachutingVR:exit(...)
	__exit(self, ...)

	if managers.vr:get_setting("zipline_screen") then
		managers.menu:close_menu("zipline")
		self._camera_unit:base():set_hmd_tracking(true)

		self._comfort_screen_active = false
	end

	managers.vr:remove_setting_changed_callback("zipline_screen", self._comfort_screen_setting_changed_clbk)
	self._parachute_unit:unlink()
	World:delete_unit(self._parachute_unit)
end

function PlayerParachutingVR:_update_variables(t, dt)
	self._current_height = self._ext_movement:hmd_position().z
end

local __update_movement = PlayerParachuting._update_movement
local hmd_delta = Vector3()
local ghost_pos = Vector3()

function PlayerParachutingVR:_update_movement(t, dt)
	__update_movement(self, t, dt)
	mvector3.set(hmd_delta, self._unit:movement():hmd_delta())
	mvector3.set_z(hmd_delta, 0)
	mvector3.rotate_with(hmd_delta, self._unit:rotation())
	mvector3.set(ghost_pos, self._unit:movement():ghost_position())
	mvector3.set_z(ghost_pos, self._unit:position().z)
	mvector3.add(ghost_pos, hmd_delta)
	self._unit:movement():set_ghost_position(ghost_pos, self._unit:position())
end

function PlayerParachutingVR:_on_comfort_screen_setting_changed(setting, old, new)
	if new then
		self._camera_unit:base():set_hmd_tracking(false)
		managers.menu:open_menu("zipline", 1)

		self._comfort_screen_active = true
	elseif self._comfort_screen_active then
		managers.menu:close_menu("zipline")
		self._camera_unit:base():set_hmd_tracking(true)

		self._comfort_screen_active = false
	end
end
