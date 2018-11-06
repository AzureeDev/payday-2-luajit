core:module("SystemMenuManager")
require("lib/managers/dialogs/BaseDialog")

SelectStorageDialog = SelectStorageDialog or class(BaseDialog)

function SelectStorageDialog:content_type()
	return self._data.content_type or 1
end

function SelectStorageDialog:min_bytes()
	return self._data.min_bytes or 0
end

function SelectStorageDialog:auto_select()
	return self._data.auto_select
end

function SelectStorageDialog:done_callback(success, result)
	if self._data.callback_func then
		self._data.callback_func(success, result)
	end

	self:fade_out_close()
end

function SelectStorageDialog:to_string()
	return string.format("%s, Content type: %s, Min bytes: %s, Auto select: %s", tostring(BaseDialog.to_string(self)), tostring(self._data.content_type), tostring(self._data.min_bytes), tostring(self._data.auto_select))
end
