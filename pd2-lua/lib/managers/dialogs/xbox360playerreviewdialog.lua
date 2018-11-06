core:module("SystemMenuManager")
require("lib/managers/dialogs/PlayerReviewDialog")

Xbox360PlayerReviewDialog = Xbox360PlayerReviewDialog or class(PlayerReviewDialog)

function Xbox360PlayerReviewDialog:init(manager, data)
	PlayerReviewDialog.init(self, manager, data)
end

function Xbox360PlayerReviewDialog:show()
	self._manager:event_dialog_shown(self)

	local player_id = self:player_id()

	if player_id then
		XboxLive:show_player_review_ui(self:get_platform_id(), self:player_id())
	else
		Application:error("[SystemMenuManager] Unable to display player review dialog since no player id was specified.")
	end

	self._show_time = TimerManager:main():time()

	return true
end

function Xbox360PlayerReviewDialog:update(t, dt)
	if self._show_time and self._show_time ~= t and not Application:is_showing_system_dialog() then
		self:done_callback()
	end
end

function Xbox360PlayerReviewDialog:done_callback()
	self._show_time = nil

	PlayerReviewDialog.done_callback(self)
end
