core:module("SystemMenuManager")
require("lib/managers/dialogs/AchievementsDialog")

Xbox360AchievementsDialog = Xbox360AchievementsDialog or class(AchievementsDialog)

function Xbox360AchievementsDialog:init(manager, data)
	AchievementsDialog.init(self, manager, data)
end

function Xbox360AchievementsDialog:show()
	self._manager:event_dialog_shown(self)
	XboxLive:show_achievements_ui(self:get_platform_id())

	self._show_time = TimerManager:main():time()

	return true
end

function Xbox360AchievementsDialog:update(t, dt)
	if self._show_time and self._show_time ~= t and not Application:is_showing_system_dialog() then
		self:done_callback()
	end
end

function Xbox360AchievementsDialog:done_callback()
	self._show_time = nil

	AchievementsDialog.done_callback(self)
end
