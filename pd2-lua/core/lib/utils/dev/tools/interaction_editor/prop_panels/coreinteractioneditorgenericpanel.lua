core:module("CoreInteractionEditorGenericPanel")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreFloatSpinCtrl")

NAME = "generic"
InteractionEditorGenericPanel = InteractionEditorGenericPanel or CoreClass.class()

function InteractionEditorGenericPanel:init(parent, box, owner)
	self._scrolled_window = EWS:ScrolledWindow(parent, "", "HSCROLL")

	self._scrolled_window:set_scrollbars(Vector3(8, 8, 1), Vector3(1, 1, 1), Vector3(0, 0, 0), false)
	box:add(self._scrolled_window, 1, 0, "EXPAND")

	self._lua_widgets = {}
	self._events = {}
	self._owner = owner
	self._update_prop_cb = callback(self, self, "on_update_prop")
	self._add_pat_cb = callback(self, self, "on_add_pat")
	self._remove_pat_cb = callback(self, self, "on_remove_pat")
	self._list_box_update_cb = callback(self, self, "on_list_box_update")
end

function InteractionEditorGenericPanel:window()
	return self._scrolled_window
end

function InteractionEditorGenericPanel:set_visible(b, desc, node)
	if b then
		self:_disconnect_events()
		self._scrolled_window:destroy_children()

		self._lua_widgets = {}
		self._events = {}

		self:_build_ui(desc, node)
		self:_connect_events()
	end

	self._scrolled_window:set_visible(b)
end

function InteractionEditorGenericPanel:_new_pattern_name()
	local name = EWS:get_text_from_user(self._scrolled_window, "New instance name:", "Instance", "", Vector3(-1, -1, -1), true)

	if string.find(name, "[^%w_]") then
		-- Nothing
	end

	return name
end

function InteractionEditorGenericPanel:_could_not_add_pat(name)
	EWS:message_box(self._scrolled_window, name and "Could not instance: " .. name or "Could not instance!", "Instance", "OK,ICON_ERROR", Vector3(-1, -1, -1))
end

function InteractionEditorGenericPanel:_disconnect_events()
	for _, v in ipairs(self._events) do
		v.widget:disconnect(v.t, v.cb)
	end
end

function InteractionEditorGenericPanel:_connect_events()
	for _, v in ipairs(self._events) do
		v.widget:connect(v.t, v.cb, v)
	end
end

function InteractionEditorGenericPanel:_build_ui(desc, node)
	self._prop_box = EWS:BoxSizer("VERTICAL")
	local properties = desc:node_properties(node)

	if #properties > 0 then
		local static_prop_box = EWS:StaticBoxSizer(self._scrolled_window, "VERTICAL", "Properties")

		for _, prop in ipairs(properties) do
			local prop_type = desc:property_type(node, prop)
			local prop_value = desc:property_value(node, prop)
			local box = EWS:StaticBoxSizer(self._scrolled_window, "VERTICAL", prop)
			local widget = nil

			if prop_type == "number" then
				local w = CoreFloatSpinCtrl.FloatSpinCtrl:new(self._scrolled_window, 0, 1, 0.05, prop_value)
				local d = {
					t = "EVT_FLOAT_SPIN_CTRL_UPDATED",
					widget = w,
					cb = self._update_prop_cb,
					dtype = prop_type,
					desc = desc,
					node = node,
					prop = prop
				}

				w:connect(d.t, d.cb, d)
				table.insert(self._events, d)
				table.insert(self._lua_widgets, w)

				widget = w:window()
			elseif prop_type == "vector3" then
				local w = CoreVector3SpinCtrl.FloatVector3Ctrl:new(self._scrolled_window, Vector3(0, 0, 0), Vector3(1, 1, 1), Vector3(0.05, 0.05, 0.05), prop_value)
				local d = {
					t = "EVT_VECTOR3_SPIN_CTRL_UPDATED",
					widget = w,
					cb = self._update_prop_cb,
					dtype = prop_type,
					desc = desc,
					node = node,
					prop = prop
				}

				w:connect(d.t, d.cb, d)
				table.insert(self._events, d)
				table.insert(self._lua_widgets, w)

				widget = w:window()
			elseif prop_type == "boolean" then
				widget = EWS:CheckBox(self._scrolled_window, "", "", "")

				widget:set_value(prop_value)

				local d = {
					t = "EVT_COMMAND_CHECKBOX_CLICKED",
					widget = widget,
					cb = self._update_prop_cb,
					dtype = prop_type,
					desc = desc,
					node = node,
					prop = prop
				}

				widget:connect(d.t, d.cb, d)
				table.insert(self._events, d.t)
			elseif prop_type == "string" then
				widget = EWS:TextCtrl(self._scrolled_window, prop_value:s(), "", "")
				local d = {
					t = "EVT_COMMAND_TEXT_ENTER",
					widget = widget,
					cb = self._update_prop_cb,
					dtype = prop_type,
					desc = desc,
					node = node,
					prop = prop
				}

				widget:connect(d.t, d.cb, d)
				table.insert(self._events, d)

				d = {
					t = "EVT_KILL_FOCUS",
					widget = widget,
					cb = self._update_prop_cb,
					dtype = prop_type,
					desc = desc,
					node = node,
					prop = prop
				}

				widget:connect(d.t, d.cb, d)
				table.insert(self._events, d)
			elseif prop_type == "event" then
				widget = EWS:TextCtrl(self._scrolled_window, tostring(prop_value), "", "")

				widget:set_enabled(false)
			else
				widget = EWS:TextCtrl(self._scrolled_window, tostring(prop_value), "", "")
				local d = {
					t = "EVT_COMMAND_TEXT_ENTER",
					widget = widget,
					cb = self._update_prop_cb,
					dtype = prop_type,
					desc = desc,
					node = node,
					prop = prop
				}

				widget:connect(d.t, d.cb, d)
				table.insert(self._events, d)

				d = {
					t = "EVT_KILL_FOCUS",
					widget = widget,
					cb = self._update_prop_cb,
					dtype = prop_type,
					desc = desc,
					node = node,
					prop = prop
				}

				widget:connect(d.t, d.cb, d)
				table.insert(self._events, d)
			end

			box:add(widget, 0, 0, "EXPAND")
			static_prop_box:add(box, 0, 2, "EXPAND,ALL")
		end

		self._prop_box:add(static_prop_box, 0, 2, "EXPAND,ALL")
	end

	local patterns = desc:node_patterns(node)

	if #patterns > 0 then
		local static_patterns_box = EWS:StaticBoxSizer(self._scrolled_window, "VERTICAL", "Patterns")
		local cb_box = EWS:BoxSizer("HORIZONTAL")
		local combo_box = EWS:ComboBox(self._scrolled_window, "", "", "CB_SORT,CB_READONLY")
		local add_btn = EWS:Button(self._scrolled_window, "Add", "", "")
		local list_box = EWS:ListBox(self._scrolled_window, "", "")
		local remove_btn = EWS:Button(self._scrolled_window, "Remove", "", "")
		local list_box_sizer = EWS:BoxSizer("VERTICAL")

		cb_box:add(combo_box, 1, 2, "EXPAND,ALL")
		cb_box:add(add_btn, 0, 2, "EXPAND,ALL")

		for _, pat in ipairs(patterns) do
			combo_box:append(pat)
		end

		for _, prop in ipairs(properties) do
			local pat = desc:property_pattern(node, prop)

			if pat then
				local pat_type = desc:pattern_type(node, pat)

				list_box:append(prop .. " - " .. pat_type)
			end
		end

		for _, trans in ipairs(desc:node_inputs(node)) do
			local pat = desc:transput_pattern(node, trans)

			if pat then
				local pat_type = desc:pattern_type(node, pat)

				list_box:append(trans .. " - " .. pat_type)
			end
		end

		for _, trans in ipairs(desc:node_outputs(node)) do
			local pat = desc:transput_pattern(node, trans)

			if pat then
				local pat_type = desc:pattern_type(node, pat)

				list_box:append(trans .. " - " .. pat_type)
			end
		end

		combo_box:set_value(patterns[1])
		remove_btn:set_enabled(false)

		local d = {
			t = "EVT_COMMAND_BUTTON_CLICKED",
			widget = add_btn,
			cb = self._add_pat_cb,
			combo_box = combo_box,
			list_box = list_box,
			desc = desc,
			node = node
		}

		add_btn:connect(d.t, d.cb, d)

		d = {
			t = "EVT_COMMAND_LISTBOX_SELECTED",
			widget = list_box,
			cb = self._list_box_update_cb,
			remove_btn = remove_btn,
			desc = desc,
			node = node
		}

		list_box:connect(d.t, d.cb, d)

		d = {
			t = "EVT_COMMAND_BUTTON_CLICKED",
			widget = remove_btn,
			cb = self._remove_pat_cb,
			list_box = list_box,
			desc = desc,
			node = node
		}

		remove_btn:connect(d.t, d.cb, d)
		list_box_sizer:add(list_box, 1, 2, "EXPAND,ALL")
		list_box_sizer:add(remove_btn, 0, 2, "EXPAND,ALL")
		static_patterns_box:add(cb_box, 0, 0, "EXPAND")
		static_patterns_box:add(list_box_sizer, 1, 0, "EXPAND")
		self._prop_box:add(static_patterns_box, 1, 2, "EXPAND,ALL")
	end

	self._scrolled_window:set_sizer(self._prop_box)
end

function InteractionEditorGenericPanel:on_update_prop(data, event)
	local v = nil

	if data.dtype == "number" then
		v = tonumber(data.widget:get_value())
	elseif data.dtype == "string" then
		v = tostring(data.widget:get_value())
	else
		v = data.widget:get_value()
	end

	assert(data.desc:property_set(data.node, data.prop, v))
end

function InteractionEditorGenericPanel:on_add_pat(data, event)
	local system = assert(self._owner:active_system())
	local pat = data.combo_box:get_value()
	local name = self:_new_pattern_name()

	if name == "" then
		return
	end

	if not name then
		self:_could_not_add_pat(name)

		return
	end

	local full_name = data.desc:pattern_instantiate(data.node, pat, name)

	if not full_name then
		self:_could_not_add_pat(name)

		return
	end

	data.list_box:append(full_name)

	local node = assert(system:graph_node(data.node))
	local ptype = data.desc:pattern_type(data.node, pat)

	system:add_pattern_data(data.node, pat, ptype, name, full_name)

	if ptype == "input" then
		node:add_input(full_name)
		system:set_node_colors(node, data.node)
	elseif ptype == "output" then
		node:add_output(full_name)
		system:set_node_colors(node, data.node)
	end

	self._owner:ui():clean_prop_panel()
	self._owner:ui():rebuild_prop_panel(data.desc, data.node)
end

function InteractionEditorGenericPanel:on_remove_pat(data, event)
	local idx = data.list_box:selected_index()

	if idx > -1 then
		local selected = data.list_box:get_string(idx)
		local system = assert(self._owner:active_system())
		local node, pat, ptype, name, full_name = system:pattern_data(data.node, selected)

		system:remove_pattern_data(data.node, selected)

		if ptype == "input" then
			assert(system:desc():transput_remove(node, full_name))
			assert(system:graph_node(node)):remove_input(full_name)
		elseif ptype == "output" then
			assert(system:desc():transput_remove(node, full_name))
			assert(system:graph_node(node)):remove_output(full_name)
		else
			assert(system:desc():property_remove(node, full_name))
		end

		self._owner:ui():clean_prop_panel()
		self._owner:ui():rebuild_prop_panel(data.desc, data.node)
	end
end

function InteractionEditorGenericPanel:on_list_box_update(data, event)
	data.remove_btn:set_enabled(true)
end
