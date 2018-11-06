core:module("SystemMenuManager")
require("lib/managers/dialogs/SelectUserDialog")

Xbox360SelectUserDialog = Xbox360SelectUserDialog or class(SelectUserDialog)

function Xbox360SelectUserDialog:init(manager, data)
	SelectUserDialog.init(self, manager, data)

	local count = self._data.count

	if count and count ~= 1 and count ~= 2 and count ~= 4 then
		if count > 2 then
			self._data.count = 4
		else
			self._data.count = 1
		end
	end
end

function Xbox360SelectUserDialog:show()
	self._manager:event_dialog_shown(self)

	local wrapper_index = managers.controller:get_default_wrapper_index()
	local controller_index = managers.controller:get_controller_index_list(wrapper_index)
	local controller = Input:controller(controller_index)

	print("[Xbox360SelectUserDialog:show] wrapper_index", wrapper_index, "controller_index", controller_index, "controller:type()", controller:type())

	if controller:type() == "xb1_controller" then
		XboxLive:show_signin_ui(controller)

		self._show_time = TimerManager:main():time()
	end

	return true
end

function Xbox360SelectUserDialog:update(t, dt)
	if self._show_time and self._show_time ~= t and not XboxLive:is_showing_user_dialog() and not self._manager:_is_engine_delaying_signin_change() then
		self:done_callback()
	end
end

function Xbox360SelectUserDialog:done_callback()
	self._show_time = nil

	SelectUserDialog.done_callback(self)
end
