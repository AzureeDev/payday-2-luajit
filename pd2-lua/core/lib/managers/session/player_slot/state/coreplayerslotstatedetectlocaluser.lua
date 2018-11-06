core:module("CorePlayerSlotStateDetectLocalUser")
core:import("CorePlayerSlotStateLocalUserBound")
core:import("CorePlayerSlotStateInit")

DetectLocalUser = DetectLocalUser or class()

function DetectLocalUser:init()
	self.player_slot._perform_local_user_binding:task_started()
end

function DetectLocalUser:destroy()
	self.player_slot._perform_local_user_binding:task_completed()
end

function DetectLocalUser:transition()
	if self.player_slot._init:is_requested() then
		return CorePlayerSlotStateInit.Init
	end

	local input_provider_ids_pressed_start = self._input_manager:input_provider_id_that_presses_start()

	for _, input_provider_id in pairs(input_provider_ids_pressed_start) do
		local has_id = self.player_slot._local_user_manager:has_local_user_with_input_provider_id(input_provider_id)

		if not has_id then
			self.player_slot._local_user_manager:bind_local_user(self.player_slot, input_provider_id)

			return CorePlayerSlotStateLocalUserBound.LocalUserBound, self.player_slot:assigned_user()
		end
	end
end
