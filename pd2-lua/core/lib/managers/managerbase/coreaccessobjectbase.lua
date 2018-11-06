core:module("CoreAccessObjectBase")

AccessObjectBase = AccessObjectBase or class()

function AccessObjectBase:init(manager, name)
	self.__manager = manager
	self.__name = name
	self.__active_requested = false
	self.__really_activated = false
end

function AccessObjectBase:name()
	return self.__name
end

function AccessObjectBase:active()
	return self.__active_requested
end

function AccessObjectBase:active_requested()
	return self.__active_requested
end

function AccessObjectBase:really_active()
	return self.__really_activated
end

function AccessObjectBase:set_active(active)
	if self.__active_requested ~= active then
		self.__active_requested = active

		self.__manager:_prioritize_and_activate()
	end
end

function AccessObjectBase:_really_activate()
	self.__really_activated = true
end

function AccessObjectBase:_really_deactivate()
	self.__really_activated = false
end
