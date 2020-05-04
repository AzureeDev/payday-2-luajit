core:module("CorePortalLayer")
core:import("CoreStaticLayer")
core:import("CoreTable")
core:import("CoreEws")
core:import("CorePortalManager")

PortalLayer = PortalLayer or class(CoreStaticLayer.StaticLayer)

function PortalLayer:init(owner)
	PortalLayer.super.init(self, owner, "portal", {
		"portal"
	}, "portal_layer")

	self._portal_shapes = {}
	self.update_function = callback(self, self, "update_portal_shape")
	self._min = -30000
	self._max = 30000
	self._only_draw_selected = false
	self._dont_draw_boxes = false
	self._dont_draw_units = false
	self._portal_brush = Draw:brush()
	self._portal_point_unit = "core/units/portal_point/portal_point"
	self._portal_shape_unit = "core/units/portal_shape/portal_shape"
end

function PortalLayer:get_layer_name()
	return "Portal"
end

function PortalLayer:load(world_holder, offset)
	local portal_data = world_holder:create_world("world", self._save_name, offset)

	if not self:_old_load(portal_data) then
		for _, portal in ipairs(portal_data.portals) do
			local name = portal.name
			local r = 0.25 + math.rand(0.75)
			local g = 0.25 + math.rand(0.75)
			local b = 0.25 + math.rand(0.75)
			local draw_base = portal.draw_base or 0
			self._portal_shapes[name] = {
				portal = {},
				top = portal.top,
				bottom = portal.bottom,
				draw_base = draw_base,
				r = r,
				g = g,
				b = b
			}
			self._current_shape = self._portal_shapes[name]
			self._current_portal = self._portal_shapes[name].portal

			for _, data in ipairs(portal.points) do
				self:do_spawn_unit(self._portal_point_unit, data.position)
			end
		end

		for _, group in pairs(managers.portal:unit_groups()) do
			for _, shape in ipairs(group:shapes()) do
				local unit = PortalLayer.super.do_spawn_unit(self, self._portal_shape_unit, shape:position(), shape:rotation())
				unit:unit_data().portal_group_shape = shape

				unit:unit_data().portal_group_shape:set_unit(unit)
			end
		end
	end

	self:update_shapes_listbox(self._shapes_listbox)
	self:select_portal()
	self:update_groups_listbox()
	self:clear_selected_units()
end

function PortalLayer:_old_load(portal)
	if not portal._portal_shapes then
		return false
	end

	if portal._portal_shapes then
		for name, portal in pairs(portal._portal_shapes) do
			local r = 0.25 + math.rand(0.75)
			local g = 0.25 + math.rand(0.75)
			local b = 0.25 + math.rand(0.75)
			local draw_base = portal.draw_base or 0
			self._portal_shapes[name] = {
				portal = {},
				top = portal.top,
				bottom = portal.bottom,
				draw_base = draw_base,
				r = r,
				g = g,
				b = b
			}
			self._current_shape = self._portal_shapes[name]
			self._current_portal = self._portal_shapes[name].portal

			for _, data in ipairs(portal.portal) do
				self:do_spawn_unit(self._portal_point_unit, data.pos)
			end
		end
	end

	for _, group in pairs(managers.portal:unit_groups()) do
		for _, shape in ipairs(group:shapes()) do
			local unit = PortalLayer.super.do_spawn_unit(self, self._portal_shape_unit, shape:position(), shape:rotation())
			unit:unit_data().portal_group_shape = shape

			unit:unit_data().portal_group_shape:set_unit(unit)
		end
	end

	return true
end

function PortalLayer:save(save_params)
	local portals = {}
	local unit_groups = managers.portal:save_level_data()

	for name, data in pairs(self._portal_shapes) do
		local portal_data = {
			name = name,
			top = data.top,
			draw_base = data.draw_base,
			bottom = data.bottom,
			points = {}
		}

		for _, unit in ipairs(data.portal) do
			table.insert(portal_data.points, {
				position = unit:position(),
				rotation = unit:rotation()
			})
		end

		table.insert(portals, portal_data)
	end

	local t = {
		single_data_block = true,
		entry = self._save_name,
		data = {
			portals = portals,
			unit_groups = unit_groups
		}
	}

	self:_add_project_save_data(t.data)
	managers.editor:add_save_data(t)
end

function PortalLayer:get_portal_shapes()
	return self._portal_shapes
end

function PortalLayer:update(time, rel_time)
	if not self._dont_draw then
		if not self._only_draw_selected then
			for name, group in pairs(managers.portal:unit_groups()) do
				group:draw(time, rel_time, 0.6, self._dont_draw_boxes, self._dont_draw_units)
			end
		end

		if self._current_group then
			self._current_group:draw(time, rel_time, 1, self._dont_draw_boxes, self._dont_draw_units)
		end
	end

	if self._draw_units_in_no_portal_state then
		self:_draw_units_in_no_portal(time, rel_time, 1)
	end

	if self._draw_not_current then
		self:_draw_units_in_not_current_portal(time, rel_time, 1)
	end

	PortalLayer.super.update(self, time, rel_time)

	if self.update_function then
		self.update_function(time, rel_time)
	end
end

function PortalLayer:update_portal_shape(time, rel_time)
	self:draw_limit()
	self:calc_mid_point()
end

function PortalLayer:draw_limit()
	for n, data in pairs(self._portal_shapes) do
		self:draw_portal(data)
	end
end

function PortalLayer:draw_portal(data)
	if self._only_draw_selected and data.portal ~= self._current_portal then
		return
	end

	local puls = 0.8 + (1 + math.sin(Application:time() * 100)) / 10
	local int = 1 * puls
	local portal = data.portal
	local min = self._min + data.draw_base
	local max = self._max + data.draw_base

	if data.bottom ~= 0 or data.top ~= 0 then
		min = data.bottom
		max = data.top
	end

	if portal ~= self._current_portal then
		int = 0.6 * puls
	end

	local r = data.r * int
	local g = data.g * int
	local b = data.b * int

	self._portal_brush:set_color(Color(0.75, r, g, b))

	for i = 1, #portal do
		local s_point = portal[i]
		local e_point = portal[i + 1]

		if i == #portal then
			e_point = portal[1]
		end

		local s_pos = s_point:position()
		local e_pos = e_point:position()
		local dir = Vector3(e_pos.x, e_pos.y, 0) - Vector3(s_pos.x, s_pos.y, 0)
		local length = dir:length()
		dir = dir:normalized()
		local c1 = Vector3(s_pos.x, s_pos.y, min)
		local c2 = Vector3(s_pos.x, s_pos.y, max)
		local c3 = Vector3(e_pos.x, e_pos.y, max)
		local c4 = Vector3(e_pos.x, e_pos.y, min)

		self._portal_brush:quad(c1, c2, c3, c4)
		Application:draw_cylinder(Vector3(s_pos.x, s_pos.y, min), Vector3(s_pos.x, s_pos.y, max), 50, 1 * int, 1 * int, 0 * int)
	end
end

function PortalLayer:_draw_units_in_no_portal()
	self._portal_brush:set_color(Color(0.75, 1, 0, 0))

	for _, unit in pairs(managers.editor:layer("Statics"):created_units()) do
		if unit:visible() and not unit:unit_data().only_visible_in_editor and not unit:unit_data().only_exists_in_editor and not managers.portal:unit_in_any_unit_group(unit) then
			self._portal_brush:unit(unit)
		end
	end
end

function PortalLayer:_draw_units_in_not_current_portal()
	if not self._current_group then
		return
	end

	self._portal_brush:set_color(Color(0.75, 0, 0, 1))

	for _, unit in pairs(managers.editor:layer("Statics"):created_units()) do
		if unit:visible() and not unit:unit_data().only_visible_in_editor and not unit:unit_data().only_exists_in_editor and not self._current_group:unit_in_group(unit) then
			self._portal_brush:unit(unit)
		end
	end
end

function PortalLayer:_auto_fill()
	if not self._current_group then
		return
	end

	local confirm = EWS:message_box(Global.frame_panel, "Fill group " .. self._current_group:name() .. " with units?", "Portals", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	for _, unit in pairs(managers.editor:layer("Statics"):created_units()) do
		if unit:visible() and not unit:unit_data().only_visible_in_editor and not unit:unit_data().only_exists_in_editor and not self._current_group:unit_in_group(unit) and self._current_group:inside(unit:position()) then
			self._current_group:add_unit_id(unit)
		end
	end
end

function PortalLayer:toggle_portal_system()
	self._use_portal_system = not self._use_portal_system

	if self._use_portal_system then
		CorePortalManager.PortalUnitGroup._change_units_visibility_old = CorePortalManager.PortalUnitGroup._change_units_visibility
		CorePortalManager.PortalUnitGroup._change_units_visibility = CorePortalManager.PortalUnitGroup._change_units_visibility_in_editor
	else
		CorePortalManager.PortalUnitGroup._change_units_visibility = CorePortalManager.PortalUnitGroup._change_units_visibility_old
	end

	managers.portal:pseudo_reset()
end

function PortalLayer:build_panel(notebook)
	PortalLayer.super.build_panel(self, notebook)

	local dont_draw = EWS:CheckBox(self._ews_panel, "Don't draw portals", "")

	dont_draw:set_value(self._dont_draw)
	self._sizer:add(dont_draw, 0, 2, "EXPAND,TOP,BOTTOM")
	dont_draw:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_dont_draw",
		cb = dont_draw
	})

	local only_draw_selected = EWS:CheckBox(self._ews_panel, "Only draw current", "")

	only_draw_selected:set_value(self._only_draw_selected)
	self._sizer:add(only_draw_selected, 0, 2, "EXPAND,TOP,BOTTOM")
	only_draw_selected:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_only_draw_selected",
		cb = only_draw_selected
	})
	only_draw_selected:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "on_only_draw_current"), nil)

	local dont_draw_boxes = EWS:CheckBox(self._ews_panel, "Don't draw portal shapes", "")

	dont_draw_boxes:set_value(self._dont_draw_boxes)
	self._sizer:add(dont_draw_boxes, 0, 2, "EXPAND,TOP,BOTTOM")
	dont_draw_boxes:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_dont_draw_boxes",
		cb = dont_draw_boxes
	})

	local dont_draw_units = EWS:CheckBox(self._ews_panel, "Don't draw portal units", "")

	dont_draw_units:set_value(self._dont_draw_units)
	self._sizer:add(dont_draw_units, 0, 2, "EXPAND,TOP,BOTTOM")
	dont_draw_units:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_dont_draw_units",
		cb = dont_draw_units
	})

	local draw_nonportaled = EWS:CheckBox(self._ews_panel, "Draw non-portaled units", "")

	draw_nonportaled:set_value(self._draw_units_in_no_portal_state)
	self._sizer:add(draw_nonportaled, 0, 2, "EXPAND,TOP,BOTTOM")
	draw_nonportaled:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_draw_units_in_no_portal_state",
		cb = draw_nonportaled
	})

	local draw_not_current = EWS:CheckBox(self._ews_panel, "Draw units not in current portal", "")

	draw_not_current:set_value(self._draw_not_current)
	self._sizer:add(draw_not_current, 0, 2, "EXPAND,TOP,BOTTOM")
	draw_not_current:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_draw_not_current",
		cb = draw_not_current
	})

	local draw_not_current = EWS:CheckBox(self._ews_panel, "Activate portal system in editor", "")

	draw_not_current:set_value(self._use_portal_system)
	self._sizer:add(draw_not_current, 0, 2, "EXPAND,TOP,BOTTOM")
	draw_not_current:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "toggle_portal_system"))

	self._portal_panel = EWS:Panel(self._ews_panel, "", "TAB_TRAVERSAL")
	local portal_sizer = EWS:StaticBoxSizer(self._portal_panel, "VERTICAL", "Portals")

	self._portal_panel:set_sizer(portal_sizer)

	local btn_sizer = EWS:BoxSizer("HORIZONTAL")
	local new_btn = EWS:Button(self._portal_panel, "Create New", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(new_btn, 0, 5, "RIGHT,BOTTOM,TOP,EXPAND")

	local delete_btn = EWS:Button(self._portal_panel, "Delete", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(delete_btn, 0, 5, "RIGHT,BOTTOM,TOP,EXPAND")
	portal_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local portals = EWS:ListBox(self._portal_panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")
	self._shapes_listbox = portals

	self:update_shapes_listbox(portals)
	portal_sizer:add(portals, 1, 0, "EXPAND")
	portals:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "select_portal"), portals)
	new_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "new_portal"), portals)
	delete_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "delete_portal"), portals)
	portal_sizer:add(EWS:StaticText(self._portal_panel, "Draw Base", 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")

	local draw_base = EWS:Slider(self._portal_panel, 0, -15000, 15000, "", "")

	portal_sizer:add(draw_base, 0, 0, "EXPAND")
	draw_base:connect("EVT_SCROLL_CHANGED", callback(self, self, "change_draw_base"), draw_base)
	draw_base:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "change_draw_base"), draw_base)

	local spin_sizer = EWS:StaticBoxSizer(self._portal_panel, "HORIZONTAL", "Top/Bottom [m]")
	local top_spin = EWS:SpinCtrl(self._portal_panel, 0, "", "")

	top_spin:set_range(-500, 500)
	top_spin:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_spin"), {
		value = "top",
		spin = top_spin
	})
	top_spin:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_spin"), {
		value = "top",
		spin = top_spin
	})

	self._ews_triggers.set_portal_top = callback(self, self, "set_height", {
		value = "top",
		spin = top_spin
	})

	spin_sizer:add(top_spin, 1, 0, "EXPAND")

	local bottom_spin = EWS:SpinCtrl(self._portal_panel, 0, "", "")

	bottom_spin:set_range(-500, 500)
	bottom_spin:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_spin"), {
		value = "bottom",
		spin = bottom_spin
	})
	bottom_spin:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_spin"), {
		value = "bottom",
		spin = bottom_spin
	})

	self._ews_triggers.set_portal_bottom = callback(self, self, "set_height", {
		value = "bottom",
		spin = bottom_spin
	})

	spin_sizer:add(bottom_spin, 1, 0, "EXPAND")
	portal_sizer:add(spin_sizer, 0, 0, "EXPAND")

	self._ctrlrs = {
		draw_base = draw_base,
		top_spin = {
			value = "top",
			spin = top_spin
		},
		bottom_spin = {
			value = "bottom",
			spin = bottom_spin
		},
		portals = portals
	}

	self._sizer:add(self._portal_panel, 2, 0, "EXPAND")

	self._portal_groups = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL", "Groups")
	self._unit_group_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_NODIVIDER")

	self._unit_group_toolbar:add_tool("CREATE_NEW", "Create new group", CoreEws.image_path("world_editor\\new_portal_group.png"), "Create new group")
	self._unit_group_toolbar:connect("CREATE_NEW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "new_group"), nil)
	self._unit_group_toolbar:add_tool("RENAME", "Rename group", CoreEws.image_path("toolbar\\rename2_16x16.png"), "Rename group")
	self._unit_group_toolbar:connect("RENAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "rename_group"), nil)
	self._unit_group_toolbar:add_tool("DELETE", "Delete group", CoreEws.image_path("toolbar\\delete_16x16.png"), "Delete group")
	self._unit_group_toolbar:connect("DELETE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "delete_group"), nil)
	self._unit_group_toolbar:add_tool("ADD_UNIT_LIST", "Add unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	self._unit_group_toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_unit_list_btn"), nil)
	self._unit_group_toolbar:add_tool("REMOVE_UNIT_LIST", "Remove units from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	self._unit_group_toolbar:connect("REMOVE_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_unit_list_btn"), nil)
	self._unit_group_toolbar:add_tool("FILL_WITH_UNITS", "Fill portal group with units", CoreEws.image_path("toolbar\\fill_16x16.png"), nil)
	self._unit_group_toolbar:connect("FILL_WITH_UNITS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_auto_fill"), nil)
	self._unit_group_toolbar:realize()
	self._portal_groups:add(self._unit_group_toolbar, 0, 1, "EXPAND,BOTTOM")

	local groups = EWS:ListBox(self._ews_panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")
	self._groups_listbox = groups

	self._portal_groups:add(groups, 1, 0, "EXPAND")
	groups:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "select_group"), groups)

	self._ctrlrs.groups = groups

	self._sizer:add(self._portal_groups, 2, 0, "EXPAND")

	return self._ews_panel
end

function PortalLayer:on_only_draw_current()
	self:set_unit_visible_state()
end

function PortalLayer:set_unit_visible_state()
	for n, data in pairs(self._portal_shapes) do
		for _, unit in ipairs(data.portal) do
			local visible = not self._only_draw_selected or self._current_portal and self._current_portal == data.portal

			managers.editor:set_unit_visible(unit, visible)
		end
	end
end

function PortalLayer:change_draw_base(draw_base)
	local i = self._ctrlrs.portals:selected_index()

	if i > -1 then
		local name = self._ctrlrs.portals:get_string(i)

		if self._portal_shapes[name] then
			self._portal_shapes[name].draw_base = draw_base:get_value()
		end
	end
end

function PortalLayer:update_spin(data)
	local i = self._ctrlrs.portals:selected_index()

	if i > -1 then
		local name = self._ctrlrs.portals:get_string(i)

		if self._portal_shapes[name] then
			self._portal_shapes[name][data.value] = data.spin:get_value() * 100
		end
	end
end

function PortalLayer:set_height(data)
	local i = self._ctrlrs.portals:selected_index()

	if i > -1 then
		local name = self._ctrlrs.portals:get_string(i)

		if self._portal_shapes[name] then
			local value = math.round(managers.editor:camera_position().z / 100)

			data.spin:set_value(value)
		end
	end
end

function PortalLayer:clone()
	managers.editor:freeze_gui_lists()

	if self._selected_unit and not self:condition() then
		local clone_units = self._selected_units

		if managers.editor:using_groups() then
			self._clone_create_group = true
		end

		self._selected_units = {}

		for _, unit in ipairs(clone_units) do
			local new_unit = self:do_spawn_unit(unit:name():s(), unit:position(), unit:rotation())

			if new_unit then
				self:remove_name_id(new_unit)

				new_unit:unit_data().name_id = self:get_name_id(new_unit, unit:unit_data().name_id)

				managers.editor:unit_name_changed(new_unit)
				self:clone_edited_values(new_unit, unit)
			end
		end

		self:set_select_unit(nil)
		self:update_unit_settings()
	end

	managers.editor:thaw_gui_lists()
	self:_cloning_done()
end

function PortalLayer:clone_edited_values(unit, source)
	PortalLayer.super.clone_edited_values(self, unit, source)

	if unit:name() == Idstring(self._portal_shape_unit) then
		local source_props = source:unit_data().portal_group_shape._properties
		local props = unit:unit_data().portal_group_shape._properties
		props.depth = source_props.depth
		props.height = source_props.height
		props.width = source_props.width
	end
end

function PortalLayer:click_select_unit()
	if self._ctrl:down(Idstring("add_to_portal_unit_group")) and self._current_group then
		local ray = managers.editor:unit_by_raycast({
			ray_type = "body editor",
			sample = true,
			mask = 1
		})

		if ray and ray.unit then
			self._current_group:add_unit_id(ray.unit)
		end

		return
	end

	PortalLayer.super.click_select_unit(self)
end

function PortalLayer:set_select_unit(unit)
	for name, data in pairs(self._portal_shapes) do
		if table.contains(data.portal, unit) then
			self:set_selection_shapes_listbox(self._shapes_listbox, name)
			self:select_portal()

			self._current_group = nil
		end
	end

	if alive(unit) and unit:unit_data().portal_group_shape then
		self._current_group = managers.portal:unit_group_on_shape(unit:unit_data().portal_group_shape)

		self:set_selection_groups_listbox(self._current_group:name())

		self._current_portal = nil
	end

	PortalLayer.super.set_select_unit(self, unit)
end

function PortalLayer:do_spawn_unit(name, pos, rot)
	if name == self._portal_point_unit and not self._current_portal then
		managers.editor:output("Create or select a portal first!")

		return
	end

	if name == self._portal_shape_unit and not self._current_group then
		managers.editor:output("Create or select a group first!")

		return
	end

	local unit = PortalLayer.super.do_spawn_unit(self, name, pos, rot)

	if alive(unit) then
		if unit:name() == Idstring(self._portal_point_unit) then
			self:create_portal_point(unit, pos)
		elseif unit:name() == Idstring(self._portal_shape_unit) then
			local shape = self._current_group:add_shape({})
			unit:unit_data().portal_group_shape = shape

			unit:unit_data().portal_group_shape:set_unit(unit)

			self._current_shape_panel = unit:unit_data().portal_group_shape:panel(self._ews_panel, self._portal_groups)

			self:set_portal_shape_gui()
		end
	end

	return unit
end

function PortalLayer:set_portal_shape_gui()
	if self._current_shape_panel and self._current_shape_panel:extension().alive then
		self._current_shape_panel:set_visible(false)
	end

	if alive(self._selected_unit) and self._selected_unit:name() == Idstring(self._portal_shape_unit) then
		local shape = self._selected_unit:unit_data().portal_group_shape

		if shape then
			self._current_shape_panel = shape:panel(self._ews_panel, self._portal_groups)

			self._current_shape_panel:set_visible(true)
		end
	end

	self._ews_panel:layout()
end

function PortalLayer:create_portal_point(unit, pos)
	table.insert(self._current_portal, unit)
end

function PortalLayer:new_portal(portals)
	local name = "portal1"
	local i = 1

	while self._portal_shapes["portal" .. i] do
		i = i + 1
		name = "portal" .. i
	end

	local r = 0.25 + math.rand(0.75)
	local g = 0.25 + math.rand(0.75)
	local b = 0.25 + math.rand(0.75)
	self._portal_shapes[name] = {
		draw_base = 0,
		top = 0,
		bottom = 0,
		portal = {},
		r = r,
		g = g,
		b = b
	}

	self:update_shapes_listbox(portals)
	self:set_selection_shapes_listbox(portals, name)
	self:select_portal()
	self:clear_selected_units()
end

function PortalLayer:delete_portal(portals)
	local i = portals:selected_index()

	if i < 0 then
		return
	end

	local name = portals:get_string(i)
	local to_delete = CoreTable.clone(self._portal_shapes[name].portal)

	for _, unit in ipairs(to_delete) do
		self:delete_unit(unit)
	end

	if not alive(self._selected_unit) then
		self:clear_selected_units()
	end

	self._portal_shapes[name] = nil

	self:update_shapes_listbox(portals)
	self:select_portal()
	self:update_unit_settings()
end

function PortalLayer:update_shapes_listbox(portals)
	portals:clear()

	for name, _ in pairs(self._portal_shapes) do
		portals:append(name)
	end
end

function PortalLayer:set_selection_shapes_listbox(portals, name)
	for i = 0, portals:nr_items() - 1 do
		if name == portals:get_string(i) then
			portals:select_index(i)
		end
	end
end

function PortalLayer:select_portal()
	local i = self._ctrlrs.portals:selected_index()

	if i >= 0 then
		local name = self._ctrlrs.portals:get_string(i)

		if self._current_shape ~= self._portal_shapes[name] then
			self._current_shape = self._portal_shapes[name]
			self._current_portal = self._portal_shapes[name].portal
			self._current_group = nil

			self._ctrlrs.top_spin.spin:set_value(self._portal_shapes[name].top / 100)
			self._ctrlrs.bottom_spin.spin:set_value(self._portal_shapes[name].bottom / 100)
			self._ctrlrs.draw_base:set_value(self._portal_shapes[name].draw_base)
			self:clear_selected_units()
		end
	else
		self._current_shape = nil
		self._current_portal = nil
	end

	self:set_unit_visible_state()
end

function PortalLayer:select_group()
	local i = self._ctrlrs.groups:selected_index()

	if i > -1 then
		local name = self._ctrlrs.groups:get_string(i)

		if self._current_group ~= managers.portal:unit_group(name) then
			self._current_group = managers.portal:unit_group(name)
			self._current_portal = nil
		end
	else
		self._current_group = nil
	end
end

function PortalLayer:new_group()
	local name = managers.portal:group_name()
	name = EWS:get_text_from_user(Global.frame_panel, "Enter name for the new portal group:", "New portal group", name, Vector3(-1, -1, 0), true)

	if name and name ~= "" then
		if managers.portal:unit_group(name) then
			self:new_group()
		else
			self._current_group = managers.portal:add_unit_group(name)
			self._current_portal = nil

			self:update_groups_listbox()
			self:set_selection_groups_listbox(name)
		end
	end
end

function PortalLayer:rename_group()
	local groups = self._ctrlrs.groups
	local i = groups:selected_index()

	if i < 0 then
		return
	end

	local name = groups:get_string(i)
	local new_name = EWS:get_text_from_user(Global.frame_panel, "Enter name for the portal group:", "Rename portal group", name, Vector3(-1, -1, 0), true)

	if new_name and new_name ~= "" then
		if managers.portal:unit_group(new_name) then
			self:rename_group()
		else
			managers.portal:rename_unit_group(name, new_name)

			self._current_group = managers.portal:unit_group(new_name)
			self._current_portal = nil

			self:update_groups_listbox()
			self:set_selection_groups_listbox(new_name)
		end
	end
end

function PortalLayer:delete_group()
	local groups = self._ctrlrs.groups
	local i = groups:selected_index()

	if i < 0 then
		return
	end

	local name = groups:get_string(i)

	if not alive(self._selected_unit) then
		self:clear_selected_units()
	end

	local group = managers.portal:unit_group(name)

	for _, shape in ipairs(CoreTable.clone(group:shapes())) do
		if alive(shape:unit()) then
			self:delete_unit(shape:unit())
		end
	end

	managers.portal:remove_unit_group(name)

	if self._current_group and self._current_group:name() == name then
		self._current_group = nil
	end

	self:update_groups_listbox()
	self:update_unit_settings()
end

function PortalLayer:add_unit_list_btn()
	local groups = self._ctrlrs.groups
	local i = groups:selected_index()

	if i < 0 then
		return
	end

	local name = groups:get_string(i)
	local group = managers.portal:unit_group(name)

	local function f(unit)
		return unit:slot() == 1
	end

	local dialog = rawget(_G, "SelectUnitByNameModal"):new("Add Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		group:add_unit_id(unit)
	end
end

function PortalLayer:remove_unit_list_btn()
	local groups = self._ctrlrs.groups
	local i = groups:selected_index()

	if i < 0 then
		return
	end

	local name = groups:get_string(i)
	local group = managers.portal:unit_group(name)

	local function f(unit)
		return group:ids()[unit:unit_data().unit_id]
	end

	local dialog = rawget(_G, "SelectUnitByNameModal"):new("Remove Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		group:remove_unit_id(unit)
	end
end

function PortalLayer:update_groups_listbox()
	self._ctrlrs.groups:clear()

	for name, _ in pairs(managers.portal:unit_groups()) do
		self._ctrlrs.groups:append(name)
	end
end

function PortalLayer:set_selection_groups_listbox(name)
	local groups = self._ctrlrs.groups

	for i = 0, groups:nr_items() - 1 do
		if name == groups:get_string(i) then
			groups:select_index(i)
		end
	end
end

function PortalLayer:delete_unit(unit)
	if unit:name() == Idstring(self._portal_point_unit) then
		for name, shape in pairs(self._portal_shapes) do
			table.delete(shape.portal, unit)
		end
	end

	if unit:name() == Idstring(self._portal_shape_unit) and unit:unit_data().portal_group_shape then
		local group = managers.portal:unit_group_on_shape(unit:unit_data().portal_group_shape)

		group:remove_shape(unit:unit_data().portal_group_shape)
	end

	PortalLayer.super.delete_unit(self, unit)
end

function PortalLayer:calc_mid_point()
	if not self._current_portal then
		return
	end

	if alive(self._selected_unit) and self._selected_unit:name() == Idstring(self._portal_point_unit) then
		local i = table.get_vector_index(self._current_portal, self._selected_unit)

		if i < #self._current_portal then
			self._mid_pos = self._selected_unit:position() + (self._current_portal[i + 1]:position() - self._selected_unit:position()) / 2
		else
			self._mid_pos = self._selected_unit:position() + (self._current_portal[1]:position() - self._selected_unit:position()) / 2
		end

		Application:draw_sphere(self._mid_pos, 30, 1, 1, 1)
		Application:draw_line(Vector3(self._mid_pos.x, self._mid_pos.y, self._min), Vector3(self._mid_pos.x, self._mid_pos.y, 15000), 1, 1, 1)
	end
end

function PortalLayer:insert()
	if not alive(self._selected_unit) or self._selected_unit:name() ~= Idstring(self._portal_point_unit) then
		return
	end

	local i = table.get_vector_index(self._current_portal, self._selected_unit)
	self._selected_unit = self:do_spawn_unit(self._portal_point_unit, self._mid_pos)

	table.remove(self._current_portal)
	table.insert(self._current_portal, i + 1, self._selected_unit)
end

function PortalLayer:replace_unit()
	managers.editor:output_error("Can't replace or reload portal units.")
end

function PortalLayer:update_unit_settings()
	PortalLayer.super.update_unit_settings(self)
	self:set_portal_shape_gui()
end

function PortalLayer:clear()
	self._portal_shapes = {}

	self:update_shapes_listbox(self._shapes_listbox)
	self:select_portal()
	PortalLayer.super.clear(self)
	managers.portal:clear()

	self._current_group = nil

	self:update_groups_listbox()
end

function PortalLayer:add_triggers()
	PortalLayer.super.add_triggers(self)

	local vc = self._editor_data.virtual_controller

	vc:add_trigger(Idstring("enter"), callback(self, self, "insert"))
end
