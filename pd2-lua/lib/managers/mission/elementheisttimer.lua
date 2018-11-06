core:import("CoreElementTimer")

ElementHeistTimer = ElementHeistTimer or class(CoreElementTimer.ElementTimer)

function ElementHeistTimer:timer_operation_start()
	ElementHeistTimer.super.timer_operation_start(self)
	managers.game_play_central:start_inverted_heist_timer(self._timer)
end

function ElementHeistTimer:timer_operation_pause()
	ElementHeistTimer.super.timer_operation_pause(self)
	managers.game_play_central:stop_heist_timer()
end

function ElementHeistTimer:timer_operation_add_time(time)
	ElementHeistTimer.super.timer_operation_add_time(self, time)
	managers.game_play_central:modify_heist_timer(time)
end

function ElementHeistTimer:timer_operation_subtract_time(time)
	ElementHeistTimer.super.timer_operation_subtract_time(self, time)
	managers.game_play_central:modify_heist_timer(-time)
end
