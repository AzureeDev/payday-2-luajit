core:module("SystemMenuManager")
core:import("CoreDebug")

BaseDialog = BaseDialog or class()

function BaseDialog:init(manager, data)
	self._manager = manager
	self._data = data or {}
end

function BaseDialog:id()
	return self._data.id
end

function BaseDialog:priority()
	return self._data.priority or 0
end

function BaseDialog:get_platform_id()
	return managers.user:get_platform_id(self._data.user_index) or 0
end

function BaseDialog:is_generic()
	return self._data.is_generic
end

function BaseDialog:fade_in()
end

function BaseDialog:fade_out_close()
	self:close()
end

function BaseDialog:fade_out()
	self:close()
end

function BaseDialog:force_close()
end

function BaseDialog:close()
	self._manager:event_dialog_closed(self)
end

function BaseDialog:is_closing()
	return false
end

function BaseDialog:show()
	Application:error("[SystemMenuManager] Unable to display dialog since the logic for it hasn't been implemented.")

	return false
end

function BaseDialog:_get_ws()
	return self._ws
end

function BaseDialog:_get_controller()
	return self._controller
end

function BaseDialog:to_string()
	return string.format("Class: %s, Id: %s, User index: %s", CoreDebug.class_name(getmetatable(self), _M), tostring(self._data.id), tostring(self._data.user_index))
end

function BaseDialog:blocks_exec()
	return true
end
