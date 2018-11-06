core:module("SystemMenuManager")
require("lib/managers/dialogs/FriendsDialog")

Xbox360FriendsDialog = Xbox360FriendsDialog or class(FriendsDialog)

function Xbox360FriendsDialog:init(manager, data)
	FriendsDialog.init(self, manager, data)
end

function Xbox360FriendsDialog:show()
	self._manager:event_dialog_shown(self)
	XboxLive:show_friends_ui(self:get_platform_id())

	self._show_time = TimerManager:main():time()

	return true
end

function Xbox360FriendsDialog:update(t, dt)
	if self._show_time and self._show_time ~= t and not Application:is_showing_system_dialog() then
		self:done_callback()
	end
end

function Xbox360FriendsDialog:done_callback()
	self._show_time = nil

	FriendsDialog.done_callback(self)
end
