core:module("SystemMenuManager")
require("lib/managers/dialogs/SelectStorageDialog")

Xbox360SelectStorageDialog = Xbox360SelectStorageDialog or class(SelectStorageDialog)

function Xbox360SelectStorageDialog:show()
	local success = Application:display_device_selection_dialog(self:get_platform_id(), self:content_type(), not self:auto_select(), callback(self, self, "done_callback"), self:min_bytes(), false)

	if success then
		self._manager:event_dialog_shown(self)
	end

	return success
end
