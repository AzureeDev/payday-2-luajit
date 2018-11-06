core:module("SystemMenuManager")
require("lib/managers/dialogs/KeyboardInputDialog")

Xbox360KeyboardInputDialog = Xbox360KeyboardInputDialog or class(KeyboardInputDialog)

function Xbox360KeyboardInputDialog:show()
	self._manager:event_dialog_shown(self)

	local end_parameter_list = {}

	table.insert(end_parameter_list, self:max_count())
	table.insert(end_parameter_list, callback(self, self, "done_callback"))
	XboxLive:show_keyboard_ui(self:get_platform_id(), self:input_type(), self:input_text(), self:title(), self:text(), unpack(end_parameter_list))

	return true
end

function Xbox360KeyboardInputDialog:done_callback(input_text)
	KeyboardInputDialog.done_callback(self, true, input_text)
end
