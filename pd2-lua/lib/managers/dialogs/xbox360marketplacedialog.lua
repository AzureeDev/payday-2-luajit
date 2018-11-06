core:module("SystemMenuManager")
require("lib/managers/dialogs/MarketplaceDialog")

Xbox360MarketplaceDialog = Xbox360MarketplaceDialog or class(MarketplaceDialog)

function Xbox360MarketplaceDialog:init(manager, data)
	MarketplaceDialog.init(self, manager, data)
end

function Xbox360MarketplaceDialog:show()
	self._manager:event_dialog_shown(self)

	local end_parameter_list = {}

	table.insert(end_parameter_list, self:item_type())
	table.insert(end_parameter_list, self:item_id())
	XboxLive:show_marketplace_ui(self:get_platform_id(), unpack(end_parameter_list))

	self._show_time = TimerManager:main():time()

	return true
end

function Xbox360MarketplaceDialog:update(t, dt)
	if self._show_time and self._show_time ~= t and not Application:is_showing_system_dialog() then
		self:done_callback()
	end
end

function Xbox360MarketplaceDialog:done_callback()
	self._show_time = nil

	MarketplaceDialog.done_callback(self)
end
