core:module("CoreMenuStateStart")
core:import("CoreMenuStateAttract")

Start = Start or class()

function Start:init()
	self._start_time = TimerManager:game():time()
	local player_slots = self.pre_front_end.menu_state._player_slots
	self._primary_slot = player_slots:primary_slot()

	self._primary_slot:request_local_user_binding()

	local menu_handler = self.pre_front_end.menu_state._menu_handler

	menu_handler:start()
end

function Start:destroy()
	self._primary_slot:stop_local_user_binding()
end

function Start:transition()
	local current_time = TimerManager:game():time()
	local time_until_attract = 15

	if current_time >= self._start_time + time_until_attract then
		return CoreMenuStateAttract.Attract
	end
end
