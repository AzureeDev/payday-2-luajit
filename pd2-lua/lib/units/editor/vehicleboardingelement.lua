VehicleBoardingElement = VehicleBoardingElement or class(MissionElement)
VehicleBoardingElement.SAVE_UNIT_POSITION = false
VehicleBoardingElement.SAVE_UNIT_ROTATION = false

function VehicleBoardingElement:init(unit)
	VehicleBoardingElement.super.init(self, unit)

	self._hed.vehicle = nil
	self._hed.operation = "embark"

	table.insert(self._save_values, "vehicle")
	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "seats_order")
end

function VehicleBoardingElement:update_editing()
end

function VehicleBoardingElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		mask = managers.slot:get_mask("vehicles")
	})

	if not ray then
		return
	end

	local element_data = ray.unit:mission_element_data()
	local is_vehicle = ray.unit:vehicle_driving() ~= nil

	if not is_vehicle then
		return
	end

	local id = ray.unit:unit_data().unit_id

	if is_vehicle then
		if self._hed.vehicle == id then
			self:set_vehicle(nil)
		else
			self:set_vehicle(ray.unit)
		end
	end
end

function VehicleBoardingElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function VehicleBoardingElement:set_vehicle(vehicle_unit)
	if self._vehicle_unit == vehicle_unit then
		return
	end

	self._vehicle_unit = vehicle_unit
	self._hed.vehicle = vehicle_unit and vehicle_unit:unit_data().unit_id
	self._hed.seats_order = nil

	self:_update_gui()
end

function VehicleBoardingElement:vehicle_unit()
	if not self._vehicle_unit or self._vehicle_unit:unit_data().unit_id ~= self._hed.vehicle then
		self._vehicle_unit = managers.editor:unit_with_id(self._hed.vehicle)
	end

	return self._vehicle_unit
end

function VehicleBoardingElement:draw_links(t, dt, selected_unit, all_units)
	VehicleBoardingElement.super.draw_links(self, t, dt, selected_unit)

	if self._hed.vehicle then
		local unit = self:vehicle_unit()
		local draw = unit and (not selected_unit or unit == selected_unit or self._unit == selected_unit)

		if draw then
			self:_draw_link({
				g = 0.75,
				b = 0,
				r = 0,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function VehicleBoardingElement:_update_gui()
	local vehicle_unit = self:vehicle_unit()
	local seats_interface_enabled = not not vehicle_unit

	self._seats_list:set_enabled(seats_interface_enabled)
	self._move_up_button:set_enabled(seats_interface_enabled)
	self._move_down_button:set_enabled(seats_interface_enabled)
	self:_populate_seats_list()
end

function VehicleBoardingElement:_populate_seats_list()
	self._seats_list:clear()

	local vehicle = self:vehicle_unit()

	if not vehicle then
		return
	end

	if not self._hed.seats_order then
		self._hed.seats_order = {}

		for seat_name, _ in pairs(vehicle:vehicle_driving()._seats) do
			table.insert(self._hed.seats_order, seat_name)
		end
	end

	for i, seat_name in ipairs(self._hed.seats_order) do
		self._seats_list:append(seat_name)
	end
end

function VehicleBoardingElement:_move_up_clicked(button, event)
	self:_move_seat_in_direction("up")
end

function VehicleBoardingElement:_move_down_clicked(button, event)
	self:_move_seat_in_direction("down")
end

function VehicleBoardingElement:_move_seat_in_direction(direction)
	local seat_index = self._seats_list:selected_index() + 1
	local swap_index = nil

	if direction == "up" then
		swap_index = seat_index - 1

		if seat_index <= 1 then
			return
		end
	elseif direction == "down" then
		swap_index = seat_index + 1

		if seat_index > #self._hed.seats_order - 1 then
			return
		end
	end

	local temp = self._hed.seats_order[swap_index]
	self._hed.seats_order[swap_index] = self._hed.seats_order[seat_index]
	self._hed.seats_order[seat_index] = temp

	self:_populate_seats_list()
	self._seats_list:select_index(swap_index - 1)
end

function VehicleBoardingElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = nil

	self:_build_value_combobox(panel, panel_sizer, "operation", {
		"embark",
		"disembark"
	}, "Specify wether heisters will enter or exit the vehicle")

	local seats_label = EWS:StaticText(panel, "")

	seats_label:set_label("Seat priority:")
	panel_sizer:add(seats_label, 0, 0, "EXPAND")

	self._seats_list = EWS:ListBox(panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB")

	panel_sizer:add(self._seats_list, 0, 0, "EXPAND")

	self._move_up_button = EWS:Button(panel, "Move Up")

	self._move_up_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_move_up_clicked"), nil)
	panel_sizer:add(self._move_up_button, 0, 0, "EXPAND")

	self._move_down_button = EWS:Button(panel, "Move Down")

	self._move_down_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_move_down_clicked"), nil)
	panel_sizer:add(self._move_down_button, 0, 0, "EXPAND")
	self:_update_gui()
end
