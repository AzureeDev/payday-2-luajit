core:module("SystemMenuManager")
require("lib/managers/dialogs/BaseDialog")

DeleteFileDialog = DeleteFileDialog or class(BaseDialog)

function DeleteFileDialog:done_callback(success)
	if self._data.callback_func then
		self._data.callback_func(success)
	end

	self:fade_out_close()
end
