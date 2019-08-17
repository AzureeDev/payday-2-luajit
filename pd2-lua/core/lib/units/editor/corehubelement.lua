CoreHubElement = CoreHubElement or class()
HubElement = HubElement or class(CoreHubElement)

function HubElement:init(...)
	CoreHubElement.init(self, ...)
end

function CoreHubElement:init(unit)
	self._unit = unit
	self._hed = self._unit:hub_element_data()
	self._ud = self._unit:unit_data()

	self._unit:anim_play(1)

	self._save_values = {}
	self._mission_trigger_values = {}
	self._update_selected_on = false
	self._parent_panel = managers.editor:hub_element_panel()
	self._parent_sizer = managers.editor:hub_element_sizer()
	self._panels = {}
	self._arrow_brush = Draw:brush()

	self:_createicon()
end

function CoreHubElement:_createicon()
	local iconsize = 128

	if Global.iconsize then
		iconsize = Global.iconsize
	end

	if self._icon == nil then
		return
	end

	local root = self._unit:get_object(Idstring("c_hub_element_sphere"))

	if root == nil then
		return
	end

	if self._iconcolor == nil then
		self._iconcolor = "fff"
	end

	self._icon_gui = World:newgui()

	self._icon_gui:preload("core/guis/core_edit_icon")

	local pos = self._unit:position() - Vector3(iconsize / 2, iconsize / 2, 0)
	self._icon_ws = self._icon_gui:create_linked_workspace(64, 64, root, pos, Vector3(iconsize, 0, 0), Vector3(0, iconsize, 0))

	self._icon_ws:set_billboard(self._icon_ws.BILLBOARD_BOTH)
	self._icon_ws:panel():gui("core/guis/core_edit_icon")

	self._icon_script = self._icon_ws:panel():gui("core/guis/core_edit_icon"):script()

	self._icon_script:seticon(self._icon, tostring(self._iconcolor))
end

function CoreHubElement:_create_panel()
	if self._panel then
		return
	end

	self._panel, self._panel_sizer = self:_add_panel(self._parent_panel, self._parent_sizer)
end

function CoreHubElement:_build_panel()
	self._panel = nil
end

function CoreHubElement:panel(id, parent, parent_sizer)
	if id then
		if self._panels[id] then
			return self._panels[id]
		end

		local panel, panel_sizer = self:_add_panel(parent, parent_sizer)

		self:_build_panel(panel, panel_sizer)

		self._panels[id] = panel

		return self._panels[id]
	end

	if not self._panel then
		self:_build_panel()
	end

	return self._panel
end

function CoreHubElement:_add_panel(parent, parent_sizer)
	local panel = EWS:Panel(parent, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)
	panel_sizer:add(EWS:StaticText(panel, managers.editor:category_name(self._unit:name()), 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")
	panel_sizer:add(EWS:StaticLine(panel, "", "LI_HORIZONTAL"), 0, 0, "EXPAND")
	parent_sizer:add(panel, 1, 0, "EXPAND")
	panel:set_visible(false)
	panel:set_extension({
		alive = true
	})

	return panel, panel_sizer
end

function CoreHubElement:add_help_text(data)
	if data.panel and data.sizer then
		data.sizer:add(EWS:TextCtrl(data.panel, data.text, 0, "TE_MULTILINE,TE_READONLY,TE_WORDWRAP,TE_CENTRE"), 0, 5, "EXPAND,TOP,BOTTOM")
	end
end

function CoreHubElement:set_element_data(data)
	if data.callback then
		local he = self._unit:hub_element()

		he[data.callback](he, data.ctrlr, data.params)
	end

	if data.value then
		self._hed[data.value] = data.ctrlr:get_value()
		self._hed[data.value] = tonumber(self._hed[data.value]) or self._hed[data.value]
	end
end

function CoreHubElement:selected()
end

function CoreHubElement:update_selected()
end

function CoreHubElement:update_unselected()
end

function CoreHubElement:begin_editing()
end

function CoreHubElement:end_editing()
end

function CoreHubElement:clone_data()
end

function CoreHubElement:layer_finished()
end

function CoreHubElement:action_type()
	return self._action_type or self._type
end

function CoreHubElement:trigger_type()
	return self._trigger_type or self._type
end

function CoreHubElement:save_mission_action(file, t, hub, dont_save_values)
	local type = self:action_type()

	if type then
		local ha = hub:hub_element():get_hub_action(self._unit)

		file:puts(t .. "<action type=\"" .. type .. "\" name=\"" .. self:name() .. "\" mode=\"" .. ha.type .. "\" start_time=\"" .. ha.action_delay .. "\">")

		if not dont_save_values then
			for _, name in ipairs(self._save_values) do
				self:save_value(file, t, name)
			end
		end

		file:puts(t .. "</action>")
	end
end

function CoreHubElement:save_mission_action_enemy(file, t, hub)
	local ha = hub:hub_element():get_hub_action(self._unit)
	local pos = self._unit:position()
	local rot = self._unit:rotation()

	file:puts(t .. "<action type=\"" .. self:action_type() .. "\" name=\"" .. self:name() .. "\" mode=\"" .. ha.type .. "\" start_time=\"" .. ha.action_delay .. "\">")

	if ha.type == "" or ha.type == "create" then
		file:puts(t .. "\t<enemy name=\"" .. self._hed.enemy_name .. "\">")

		for _, name in ipairs(self._save_values) do
			self:save_value(file, t .. "\t", name)
		end

		file:puts(t .. "\t</enemy>")
	end

	file:puts(t .. "</action>")
end

function CoreHubElement:save_data(file, t)
	self:save_values(file, t)
end

function CoreHubElement:save_values(file, t)
	t = t .. "\t"

	file:puts(t .. "<values>")

	for _, name in ipairs(self._save_values) do
		self:save_value(file, t, name)
	end

	file:puts(t .. "</values>")
end

function CoreHubElement:save_value(file, t, name)
	t = t .. "\t"

	file:puts(save_value_string(self._hed, name, t, self._unit))
end

function CoreHubElement:save_mission_trigger(file, t, hub)
	if #self._mission_trigger_values > 0 then
		local type = self:trigger_type()

		if type then
			local ht = hub:hub_element():get_hub_trigger(self._unit)

			file:puts(t .. "<trigger type=\"" .. type .. "\" name=\"" .. self:name() .. "\" mode=\"" .. ht.type .. "\">")

			for _, name in ipairs(self._mission_trigger_values) do
				self:save_value(file, t, name)
			end

			file:puts(t .. "</trigger>")
		end
	end
end

function CoreHubElement:name()
	return self._unit:name() .. self._ud.unit_id
end

function CoreHubElement:load_data(data)
end

function CoreHubElement:get_color(type)
	if type then
		if type == "activate" or type == "enable" then
			return 0, 1, 0
		elseif type == "deactivate" or type == "disable" then
			return 1, 0, 0
		end
	end

	return 0, 1, 0
end

function CoreHubElement:draw_connections_selected()
	for _, hub in ipairs(self._hed.hubs) do
		local r = 1
		local g = 0.6
		local b = 0.2

		self:draw_arrow(self._unit, hub, r, g, b, true)
	end
end

function CoreHubElement:draw_connections_unselected()
end

function CoreHubElement:draw_arrow(from, to, r, g, b, thick)
	self._arrow_brush:set_color(Color(r, g, b))

	local mul = 1.2
	r = math.clamp(r * mul, 0, 1)
	g = math.clamp(g * mul, 0, 1)
	b = math.clamp(b * mul, 0, 1)
	from = from:position()
	to = to:position()
	local len = (from - to):length()
	local dir = (to - from):normalized()
	len = len - 50

	if thick then
		self._arrow_brush:cylinder(from, from + dir * len, 10)
		Application:draw_cylinder(from, from + dir * len, 10, r, g, b)
	else
		Application:draw_line(from, to, r, g, b)
	end

	self._arrow_brush:cone(to, to + (from - to):normalized() * 150, 48)
	Application:draw_cone(to, to + (from - to):normalized() * 150, 48, r, g, b)
end

function CoreHubElement:clear()
end

function CoreHubElement:action_types()
	return self._action_types
end

function CoreHubElement:timeline_color()
	return self._timeline_color
end

function CoreHubElement:add_triggers()
end

function CoreHubElement:clear_triggers()
end

function CoreHubElement:widget_affect_object()
	return nil
end

function CoreHubElement:use_widget_position()
	return nil
end

function CoreHubElement:set_enabled()
end

function CoreHubElement:set_disabled()
end

function CoreHubElement:set_update_selected_on(value)
	self._update_selected_on = value
end

function CoreHubElement:update_selected_on()
	return self._update_selected_on
end

function CoreHubElement:destroy()
	if self._panel then
		self._panel:extension().alive = false

		self._panel:destroy()
	end

	if self._icon_ws then
		self._icon_gui:destroy_workspace(self._icon_ws)

		self._icon_ws = nil
	end
end
