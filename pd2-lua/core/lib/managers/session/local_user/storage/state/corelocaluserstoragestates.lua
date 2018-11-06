core:module("CoreLocalUserStorageStates")

Init = Init or class()

function Init:transition()
	if self.storage._load:is_requested() then
		return Loading
	end
end

DetectSignOut = DetectSignOut or class()

function DetectSignOut:init()
end

Loading = Loading or class(DetectSignOut)

function Loading:init()
	DetectSignOut.init(self)
	self.storage:_start_load_task()
end

function Loading:destroy()
	self.storage:_close_load_task()
end

function Loading:transition()
	local status = self.storage:_load_status()

	if not status then
		return
	end

	if status == SaveData.OK then
		return Ready
	elseif status == SaveData.FILE_NOT_FOUND then
		return NoSaveGameFound
	else
		return LoadError
	end
end

Ready = Ready or class()

function Ready:init()
	self.storage:_set_stable_for_loading()
end

function Ready:destroy()
	self.storage:_not_stable_for_loading()
end

function Ready:transition()
end

NoSaveGameFound = NoSaveGameFound or class()

function NoSaveGameFound:init()
	self.storage:_set_stable_for_loading()
end

function NoSaveGameFound:transition()
	self.storage:_not_stable_for_loading()
end

LoadError = LoadError or class()

function LoadError:transition()
end
