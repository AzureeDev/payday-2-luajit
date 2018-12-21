VitHelicopterSync = VitHelicopterSync or class(UnitBase)

function VitHelicopterSync:init(unit)
	VitHelicopterSync.super.init(self, unit)

	if Network:is_server() then
		local driving_ext = unit:vehicle_driving()
		driving_ext.on_exit_vehicle = callback(self, self, "on_exit_vehicle")
	end
end

function VitHelicopterSync:on_landing_done()
	local player = managers.player:player_unit()
	local movement_ext = player:movement()

	if movement_ext:current_state_name() == "driving" then
		movement_ext:current_state():cb_leave()
	end
end

function VitHelicopterSync:on_exit_vehicle(player)
	local is_empty = self._unit:vehicle_driving():num_players_inside() == 0

	if is_empty then
		self._unit:damage():run_sequence_simple("event_vehicle_empty")
	end
end
