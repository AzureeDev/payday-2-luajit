core:module("SystemMenuManager")
require("lib/managers/dialogs/PlayerDialog")

Xbox360PlayerDialog = Xbox360PlayerDialog or class(PlayerDialog)

function Xbox360PlayerDialog:init(manager, data)
	PlayerDialog.init(self, manager, data)
end

function Xbox360PlayerDialog:show()
	self._manager:event_dialog_shown(self)

	local player_id = self:player_id()

	if player_id then
		XboxLive:show_gamer_card_ui(self:get_platform_id(), self:player_id())
	else
		Application:error("[SystemMenuManager] Unable to display player dialog since no player id was specified.")
	end

	self._show_time = TimerManager:main():time()

	return true
end

function Xbox360PlayerDialog:update(t, dt)
	if self._show_time and self._show_time ~= t and not Application:is_showing_system_dialog() then
		self:done_callback()
	end
end

function Xbox360PlayerDialog:done_callback()
	self._show_time = nil

	PlayerDialog.done_callback(self)
end
