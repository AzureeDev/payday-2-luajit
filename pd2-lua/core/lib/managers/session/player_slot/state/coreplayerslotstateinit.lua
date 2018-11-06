core:module("CorePlayerSlotStateInit")
core:import("CorePlayerSlotStateDetectLocalUser")
core:import("CorePlayerSlotStateLocalUserDebugBind")

Init = Init or class()

function Init:init()
	self.player_slot._init:task_started()
end

function Init:destroy()
	self.player_slot._init:task_completed()
end

function Init:transition()
	if self.player_slot._perform_debug_local_user_binding:is_requested() then
		return CorePlayerSlotStateLocalUserDebugBind.LocalUserDebugBind
	elseif self.player_slot._perform_local_user_binding:is_requested() then
		return CorePlayerSlotStateDetectLocalUser.DetectLocalUser
	end
end
