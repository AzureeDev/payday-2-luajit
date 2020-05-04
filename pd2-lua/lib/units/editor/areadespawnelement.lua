AreaDespawnElement = AreaDespawnElement or class(ShapeUnitElement)
AreaDespawnElement.LINK_ELEMENTS = {
	"shape_elements"
}

function AreaDespawnElement:init(unit)
	AreaDespawnElement.super.init(self, unit)

	self._hed.test_type = "unit_position"
	self._hed.shape_elements = nil

	table.insert(self._save_values, "test_type")
	table.insert(self._save_values, "shape_elements")
end

function AreaDespawnElement:post_init()
	self:build_slots_map()
end

function AreaDespawnElement:build_slots_map()
	self._slots_map = {}

	for _, slot in ipairs(self._hed.slots or {}) do
		self._slots_map[slot] = true
	end
end

function AreaDespawnElement:update_editing()
end

function AreaDespawnElement:update_selected(t, dt, selected_unit, all_units)
	if self._hed.shape_elements then
		for _, id in ipairs(self._hed.shape_elements) do
			local unit = all_units[id]
			local shape = unit:mission_element():get_shape()

			shape:draw(t, dt, 0.85, 0.85, 0.85)
		end
	else
		AreaDespawnElement.super.update_selected(self, t, dt, selected_unit, all_units)
	end
end

function AreaDespawnElement:add_shape()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if not ray then
		return
	end

	if getmetatable(ray.unit:mission_element()) ~= ShapeUnitElement then
		return
	end

	self._hed.shape_elements = self._hed.shape_elements or {}
	local id = ray.unit:unit_data().unit_id

	if table.contains(self._hed.shape_elements, id) then
		table.delete(self._hed.shape_elements, id)
	else
		table.insert(self._hed.shape_elements, id)
	end

	if #self._hed.shape_elements == 0 then
		self._hed.shape_elements = nil
	end

	self:_set_shape_type()
end

function AreaDespawnElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_shape"))
end

function AreaDespawnElement:draw_links(t, dt, selected_unit, all_units)
	if self._hed.shape_elements then
		for _, id in ipairs(self._hed.shape_elements) do
			local unit = all_units[id]

			if self:_should_draw_link(selected_unit, unit) then
				local r, g, b = unit:mission_element():get_link_color()

				self:_draw_link({
					from_unit = unit,
					to_unit = self._unit,
					r = r,
					g = g,
					b = b
				})
			end
		end
	end
end

function AreaDespawnElement:_set_shape_type()
	if self._hed.shape_elements then
		self._depth_params.number_ctrlr:set_enabled(false)
		self._width_params.number_ctrlr:set_enabled(false)
		self._height_params.number_ctrlr:set_enabled(false)
		self._radius_params.number_ctrlr:set_enabled(false)
		self._sliders.depth:set_enabled(false)
		self._sliders.width:set_enabled(false)
		self._sliders.height:set_enabled(false)
		self._sliders.radius:set_enabled(false)
		self._shape_type_params.ctrlr:set_enabled(false)
	else
		self._shape_type_params.ctrlr:set_enabled(true)
		AreaDespawnElement.super._set_shape_type(self)
	end
end

function AreaDespawnElement:set_element_data(data)
	if data.ctrlr == self._slots_presets_list.ctrlr then
		local slot_mask = managers.slot:get_mask(data.ctrlr:get_value())
		local slots = {}

		for match in string.gmatch(tostring(slot_mask), "%d+") do
			slots[tonumber(match)] = true
		end

		for i = 1, 63 do
			self._slot_boxes[i]:set_value(slots[i])

			self._slots_map[i] = slots[i]
		end
	else
		AreaDespawnElement.super.set_element_data(self, data)
	end
end

function AreaDespawnElement:new_save_values(...)
	local save_values = AreaDespawnElement.super.new_save_values(self, ...)
	save_values.slots = self._slots_map and table.map_keys(self._slots_map) or {}

	return save_values
end

function AreaDespawnElement:_slot_box_clicked(data)
	if data.ctrlr:get_value() then
		self._slots_map[data.slot] = true
	else
		self._slots_map[data.slot] = nil
	end
end

function AreaDespawnElement:_build_panel(panel, panel_sizer)
	if not self._slots_map then
		self:build_slots_map()
	end

	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local _, test_type_list = self:_build_value_combobox(panel, panel_sizer, "test_type", {
		"unit_position",
		"intersection"
	})

	test_type_list.ctrlr:set_value(self._hed.test_type)
	panel_sizer:add_spacer(0, 10)

	local slot_masks = table.map_keys(managers.slot._masks)
	local _, slots_presets_list = self:_build_value_combobox(panel, panel_sizer, "", slot_masks, "", "Slots presets")
	self._slots_presets_list = slots_presets_list

	panel_sizer:add_spacer(0, 2)

	local slots_sizer = EWS:BoxSizer("HORIZONTAL")
	local slots_label = EWS:StaticText(panel, "Slots:")
	local slots_matrix_sizer = EWS:BoxSizer("VERTICAL")
	local slot_boxes = {}
	local slot_box_callback = callback(self, self, "_slot_box_clicked")

	for i = 0, 7 do
		local row_sizer = EWS:BoxSizer("HORIZONTAL")

		for j = 0, 7 do
			local slot_number = i * 8 + j
			local checkbox = EWS:CheckBox(panel, tostring(slot_number), "")

			checkbox:set_value(self._slots_map[slot_number])

			slot_boxes[slot_number] = checkbox

			if slot_number == 0 then
				checkbox:set_enabled(false)
			else
				checkbox:connect("EVT_COMMAND_CHECKBOX_CLICKED", slot_box_callback, {
					ctrlr = checkbox,
					slot = slot_number
				})
			end

			row_sizer:add(checkbox, 1, 0, "EXPAND,LEFT")
		end

		slots_matrix_sizer:add(row_sizer, 0, 0, "EXPAND")
	end

	self._slot_boxes = slot_boxes

	slots_sizer:add(slots_label, 1, 0, "EXPAND")
	slots_sizer:add(slots_matrix_sizer, 2, 0, "EXPAND")
	panel_sizer:add(slots_sizer, 0, 0, "EXPAND")
	panel_sizer:add_spacer(0, 10)
	AreaDespawnElement.super._build_panel(self, panel, panel_sizer)
end
