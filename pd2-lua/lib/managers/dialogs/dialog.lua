core:module("SystemMenuManager")
require("lib/managers/dialogs/BaseDialog")

Dialog = Dialog or class(BaseDialog)

function Dialog:init(manager, data)
	BaseDialog.init(self, manager, data)

	self._button_text_list = {}

	self:init_button_text_list()
end

function Dialog:init_button_text_list()
	local button_list = self._data.button_list

	if button_list then
		for _, button in ipairs(button_list) do
			table.insert(self._button_text_list, button.text or "ERROR")
		end
	end

	if #self._button_text_list == 0 and not self._data.no_buttons then
		Application:error("[SystemMenuManager] Invalid dialog with no button texts. Adds an ok-button.")

		self._data.button_list = self._data.button_list or {}
		self._data.button_list[1] = self._data.button_list[1] or {}
		self._data.button_list[1].text = "ERROR: OK"

		table.insert(self._button_text_list, self._data.button_list[1].text)
	end
end

function Dialog:title()
	return self._data.title
end

function Dialog:text()
	return self._data.text
end

function Dialog:focus_button()
	return self._data.focus_button
end

function Dialog:button_pressed(button_index)
	cat_print("dialog_manager", "[SystemMenuManager] Button index pressed: " .. tostring(button_index))

	local button_list = self._data.button_list

	self:fade_out_close()

	if button_list then
		local button = button_list[button_index]

		if button and button.callback_func then
			button.callback_func(button_index, button)
		end
	end

	local callback_func = self._data.callback_func

	if callback_func then
		callback_func(button_index, self._data)
	end
end

function Dialog:button_text_list()
	return self._button_text_list
end

function Dialog:to_string()
	local buttons = ""

	if self._data.button_list then
		for _, button in ipairs(self._data.button_list) do
			buttons = buttons .. "[" .. tostring(button.text) .. "]"
		end
	end

	return string.format("%s, Title: %s, Text: %s, Buttons: %s", tostring(BaseDialog.to_string(self)), tostring(self._data.title), tostring(self:_strip_to_string_text(self._data.text)), buttons)
end

function Dialog:_strip_to_string_text(text)
	return string.gsub(tostring(text), "\n", "\\n")
end
