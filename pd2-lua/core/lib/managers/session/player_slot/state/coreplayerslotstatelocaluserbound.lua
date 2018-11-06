core:module("CorePlayerSlotStateLocalUserBound")
core:import("CorePlayerSlotStateInit")

LocalUserBound = LocalUserBound or class()

function LocalUserBound:init(local_user)
	self._local_user = local_user
end

function LocalUserBound:destroy()
end

function LocalUserBound:transition()
	if self.player_slot._init:is_requested() then
		return CorePlayerSlotStateInit.Init
	end
end
