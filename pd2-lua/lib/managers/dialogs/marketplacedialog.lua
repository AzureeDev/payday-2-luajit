core:module("SystemMenuManager")
require("lib/managers/dialogs/BaseDialog")

MarketplaceDialog = MarketplaceDialog or class(BaseDialog)

function MarketplaceDialog:done_callback()
	if self._data.callback_func then
		self._data.callback_func()
	end

	self:fade_out_close()
end

function MarketplaceDialog:item_type()
	return self._data.item_type
end

function MarketplaceDialog:item_id()
	return self._data.item_id
end

function MarketplaceDialog:to_string()
	return string.format("%s, Item type: %s, Item id: %s", tostring(BaseDialog.to_string(self)), tostring(self._data.item_type), tostring(self._data.item_id))
end
