core:module("CoreMenuStateLegal")
core:import("CoreMenuStateIntroScreens")

Legal = Legal or class()

function Legal:init()
	self._start_time = TimerManager:game():time()
end

function Legal:transition()
	local current_time = TimerManager:game():time()
	local time_until_intro_screens = 1

	if current_time >= self._start_time + time_until_intro_screens then
		return CoreMenuStateIntroScreens.IntroScreens
	end
end
