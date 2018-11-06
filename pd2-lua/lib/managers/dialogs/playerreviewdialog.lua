core:module("SystemMenuManager")
require("lib/managers/dialogs/Dialog")

PlayerReviewDialog = PlayerReviewDialog or class(BaseDialog)

function PlayerReviewDialog:done_callback()
	if self._data.callback_func then
		self._data.callback_func()
	end

	self:fade_out_close()
end

function PlayerReviewDialog:player_id()
	return self._data.player_id
end

function PlayerReviewDialog:to_string()
	return string.format("%s, Player id: %s", tostring(BaseDialog.to_string(self)), tostring(self._data.player_id))
end
