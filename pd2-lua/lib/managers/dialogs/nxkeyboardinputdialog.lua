core:module("SystemMenuManager")
require("lib/managers/dialogs/KeyboardInputDialog")

NXKeyboardInputDialog = NXKeyboardInputDialog or class(KeyboardInputDialog)

function NXKeyboardInputDialog:show()
	local data = {
		title = self:title(),
		text = self:input_text(),
		filter = self:filter(),
		limit = self:max_count() or 0,
		callback = callback(self, self, "done_callback"),
		max_text_len = 16,
		min_text_len = 1
	}
	NXKeyboardInputDialog.last_typed_string = NX64Online:display_keyboard(data)
	NXKeyboardInputDialog.keyboard_just_closed = true

	if NXKeyboardInputDialog.last_typed_string then
		self._manager:event_dialog_shown(self)
	end

	return NXKeyboardInputDialog.last_typed_string ~= nil
end

function NXKeyboardInputDialog:done_callback(input_text, success)
	KeyboardInputDialog.done_callback(self, success, input_text)
end
