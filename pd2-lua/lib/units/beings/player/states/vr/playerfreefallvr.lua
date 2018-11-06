PlayerFreefallVR = PlayerFreefall or Application:error("PlayerFreefallVR needs PlayerFreefall!")
local __init = PlayerFreefall.init

function PlayerFreefallVR:init(...)
	__init(self, ...)

	self._comfort_screen_setting_changed_clbk = callback(self, self, "_on_comfort_screen_setting_changed")
end

local __enter = PlayerFreefall.enter

function PlayerFreefallVR:enter(...)
	__enter(self, ...)

	if managers.vr:get_setting("zipline_screen") then
		self._camera_unit:base():set_hmd_tracking(false)
		managers.menu:open_menu("zipline")

		self._comfort_screen_active = true
	end

	managers.vr:add_setting_changed_callback("zipline_screen", self._comfort_screen_setting_changed_clbk)
end

local __exit = PlayerFreefall.exit

function PlayerFreefallVR:exit(...)
	__exit(self, ...)

	if managers.vr:get_setting("zipline_screen") then
		managers.menu:close_menu("zipline")
		self._camera_unit:base():set_hmd_tracking(true)

		self._comfort_screen_active = false
	end

	managers.vr:remove_setting_changed_callback("zipline_screen", self._comfort_screen_setting_changed_clbk)
end

function PlayerFreefallVR:_update_variables(t, dt)
	self._current_height = self._ext_movement:hmd_position().z
end

local __update_movement = PlayerFreefall._update_movement

function PlayerFreefallVR:_update_movement(t, dt)
	__update_movement(self, t, dt)
	self._unit:movement():set_ghost_position(self._unit:position())
end

function PlayerFreefallVR:_on_comfort_screen_setting_changed(setting, old, new)
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
