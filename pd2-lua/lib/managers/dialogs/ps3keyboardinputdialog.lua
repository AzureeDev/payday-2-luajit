core:module("SystemMenuManager")
require("lib/managers/dialogs/KeyboardInputDialog")

PS3KeyboardInputDialog = PS3KeyboardInputDialog or class(KeyboardInputDialog)

function PS3KeyboardInputDialog:show()
	local data = {
		title = self:title(),
		text = self:input_text(),
		filter = self:filter(),
		limit = self:max_count() or 0,
		callback = callback(self, self, "done_callback")
	}

	PS3:display_keyboard(data)

	local success = PS3:is_displaying_box()

	if success then
		self._manager:event_dialog_shown(self)
	end

	return success
end

function PS3KeyboardInputDialog:done_callback(input_text, success)
	KeyboardInputDialog.done_callback(self, success, input_text)
end
