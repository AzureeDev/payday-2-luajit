core:module("SystemMenuManager")
require("lib/managers/dialogs/Dialog")

Xbox360Dialog = Xbox360Dialog or class(Dialog)

function Xbox360Dialog:show()
	local focus_button = self:focus_button()

	if focus_button then
		focus_button = focus_button - 1
	else
		focus_button = 0
	end

	local button_text_list = self:button_text_list()
	local success = Application:display_message_box_dialog(self:get_platform_id(), self:title(), self:text(), focus_button, callback(self, self, "button_pressed"), false, unpack(button_text_list))

	if success then
		self._manager:event_dialog_shown(self)
	end

	return success
end

function Xbox360Dialog:button_pressed(button_index)
	if button_index == -1 then
		button_index = self:focus_button() or 1

		cat_print("dialog_manager", "[SystemMenuManager] Dialog aborted. Defaults to focus button.")
	end

	Dialog.button_pressed(self, button_index + 1)
end

function Xbox360Dialog:blocks_exec()
	return false
end
