core:module("SystemMenuManager")
require("lib/managers/dialogs/Dialog")

PS3Dialog = PS3Dialog or class(Dialog)
PS3Dialog.BUTTON_TYPE_LIST = {
	"ok",
	"yes-no",
	"yes-no-back"
}

function PS3Dialog:show()
	local focus_button = self:focus_button()
	local button_text_list = self:button_text_list()
	local ps3_focus_button, button_type = nil

	if math.within(#button_text_list, 1, #self.BUTTON_TYPE_LIST) then
		button_type = self.BUTTON_TYPE_LIST[#button_text_list]

		if focus_button then
			if math.within(focus_button, 0, #self.BUTTON_TYPE_LIST) then
				ps3_focus_button = #button_text_list - focus_button
			else
				Application:error(string.format("[SystemMenuManager] Invalid focus button \"%g\" (it is not between 0 and 3) in dialog: %s", focus_button, self:to_string()))
			end
		end
	else
		Application:error(string.format("[SystemMenuManager] Invalid button count \"%g\" (should be between 1 and 3 buttons) in dialog: %s", #button_text_list, self:to_string()))
	end

	button_type = button_type or self.BUTTON_TYPE_LIST[1]
	ps3_focus_button = ps3_focus_button or 0
	local result = PS3:show_dialog(self:text(), button_type, ps3_focus_button)

	self._manager:event_dialog_shown(self)
	self:button_pressed(result and 0 or 1)

	return true
end

function PS3Dialog:button_pressed(button_index)
	Dialog.button_pressed(self, button_index + 1)
end
