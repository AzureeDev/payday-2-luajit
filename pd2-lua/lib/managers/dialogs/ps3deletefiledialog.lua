core:module("SystemMenuManager")
require("lib/managers/dialogs/DeleteFileDialog")

PS3DeleteFileDialog = PS3DeleteFileDialog or class(DeleteFileDialog)

function PS3DeleteFileDialog:show()
	self._manager:event_dialog_shown(self)
	self:done_callback(true)

	return true
end
