core:module("SystemMenuManager")
require("lib/managers/dialogs/BaseDialog")

AchievementsDialog = AchievementsDialog or class(BaseDialog)

function AchievementsDialog:done_callback()
	if self._data.callback_func then
		self._data.callback_func()
	end

	self:fade_out_close()
end
