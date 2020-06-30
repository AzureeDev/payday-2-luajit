core:import("CoreMissionScriptElement")

ElementVehicleBoarding = ElementVehicleBoarding or class(CoreMissionScriptElement.MissionScriptElement)

function ElementVehicleBoarding:init(...)
	ElementVehicleBoarding.super.init(self, ...)
end

function ElementVehicleBoarding:get_vehicle()
	if Global.running_simulation then
		return managers.editor:unit_with_id(self._values.vehicle)
	else
		return managers.worlddefinition:get_unit(self._values.vehicle)
	end
end

function ElementVehicleBoarding:client_on_executed(...)
	self:on_executed(...)
end

function ElementVehicleBoarding:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local vehicle = self:get_vehicle()
	local vehicle_ext = vehicle:vehicle_driving()
	local ordered_seats = {}
	local seat_names = {}
	local seat_index = nil
	local team_ai = {}
	local players = {}

	for i = #self._values.seats_order, 1, -1 do
		local seat_name = self._values.seats_order[i]

		table.insert(ordered_seats, vehicle_ext:get_seat_by_name(seat_name))
		table.insert(seat_names, seat_name)
	end

	local function player_cmp(a, b)
		return b.peer_id < a.peer_id
	end

	for _, heister in pairs(managers.criminals:characters()) do
		if heister.taken then
			if heister.data.ai then
				table.insert(team_ai, heister)
			else
				table.insert_sorted(players, heister, player_cmp)
			end
		end
	end

	if self._values.operation == "embark" then
		if Network:is_server() then
			seat_index = #ordered_seats - (#team_ai + #players) + 1

			for _, heister in ipairs(team_ai) do
				if alive(heister.unit) then
					local seat = ordered_seats[seat_index]
					seat_index = seat_index + 1
					local movement_ext = heister.unit:movement()
					local brain_ext = heister.unit:brain()
					local damage_ext = heister.unit:character_damage()

					vehicle_ext:_create_seat_SO(seat, true)

					local so_data = seat.drive_SO_data
					so_data.unit = heister.unit
					so_data.ride_objective.action.align_sync = true

					damage_ext:revive_instant()
					brain_ext:set_objective(so_data.ride_objective)
					managers.network:session():send_to_peers("sync_ai_vehicle_action", "enter", vehicle, seat.name, heister.unit)

					movement_ext.vehicle_unit = vehicle
					movement_ext.vehicle_seat = seat

					movement_ext:set_position(seat.object:position())
					movement_ext:set_rotation(seat.object:rotation())
					movement_ext:action_request(so_data.ride_objective.action)
				end
			end
		else
			seat_index = #ordered_seats - #players + 1
		end

		for _, heister in ipairs(players) do
			local seat = ordered_seats[seat_index]
			seat_index = seat_index + 1

			if alive(heister.unit) and heister.unit == managers.player:player_unit() then
				local object = vehicle:get_object(Idstring(VehicleDrivingExt.INTERACTION_PREFIX .. seat.name)) or seat.object

				managers.player:enter_vehicle(vehicle, object)

				break
			end
		end
	elseif self._values.operation == "disembark" then
		local player = managers.player:player_unit()
		local movement_ext = player:movement()

		if movement_ext:current_state_name() == "driving" then
			movement_ext:current_state():cb_leave()
		end
	end

	ElementVehicleBoarding.super.on_executed(self, instigator)
end

function ElementVehicleBoarding:save(data)
	data.enabled = self._values.enabled
end

function ElementVehicleBoarding:load(data)
	self:set_enabled(data.enabled)
end
