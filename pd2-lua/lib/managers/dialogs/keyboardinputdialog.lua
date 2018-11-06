core:module("SystemMenuManager")
require("lib/managers/dialogs/BaseDialog")

KeyboardInputDialog = KeyboardInputDialog or class(BaseDialog)

function KeyboardInputDialog:title()
	return self._data.title or ""
end

function KeyboardInputDialog:text()
	return self._data.text or ""
end

function KeyboardInputDialog:input_text()
	return self._data.input_text
end

function KeyboardInputDialog:input_type()
	return self._data.input_type or "default"
end

function KeyboardInputDialog:max_count()
	return self._data.max_count
end

function KeyboardInputDialog:filter()
	return self._data.filter
end

function KeyboardInputDialog:done_callback(success, input_text)
	if self._data.callback_func then
		self._data.callback_func(success, input_text)
	end

	self:fade_out_close()
end

function KeyboardInputDialog:to_string()
	return string.format("%s, Title: %s, Text: %s, Input text: %s, Max count: %s, Filter: %s", tostring(BaseDialog.to_string(self)), tostring(self._data.title), tostring(self._data.text), tostring(self._data.input_text), tostring(self._data.max_count), tostring(self._data.filter))
end
