CoreEffectPropertyContainer = CoreEffectPropertyContainer or class()

function CoreEffectPropertyContainer:init(name)
	self._name = name
	self._properties = {}
	self._description = ""
end

function CoreEffectPropertyContainer:ui_name()
	if self._ui_name then
		return self._ui_name
	else
		return self:name()
	end
end

function CoreEffectPropertyContainer:properties()
	return self._properties
end

function CoreEffectPropertyContainer:add_property(p)
	table.insert(self._properties, p)
end

function CoreEffectPropertyContainer:get_property(name)
	for _, p in ipairs(self._properties) do
		if p:name() == name then
			return p
		end
	end

	return nil
end

function CoreEffectPropertyContainer:validate_properties()
	local ret = {
		message = "",
		valid = true
	}

	for _, p in ipairs(self._properties) do
		ret = p:validate()

		if not ret.valid then
			return ret
		end
	end

	return ret
end

function CoreEffectPropertyContainer:set_description(d)
	self._description = d
end

function CoreEffectPropertyContainer:description()
	return self._description
end

function CoreEffectPropertyContainer:name()
	return self._name
end

function CoreEffectPropertyContainer:set_name(n)
	self._name = n
end

function CoreEffectPropertyContainer:save_properties(node)
	for _, p in ipairs(self._properties) do
		p:save(node)
	end
end

function CoreEffectPropertyContainer:load_properties(node)
	for _, p in ipairs(self._properties) do
		p:load(node)
	end
end

function CoreEffectPropertyContainer:fill_property_container_sheet(window, view)
	local property_container = self

	window:freeze()
	window:destroy_children()

	local top_sizer = EWS:StaticBoxSizer(window, "VERTICAL", property_container:ui_name())
	local grid_sizer = EWS:FlexGridSizer(0, 2, 4, 0)

	grid_sizer:add_growable_col(1, 1)
	top_sizer:add(grid_sizer, 1, 0, "EXPAND")
	window:set_sizer(top_sizer)

	if property_container:description() ~= "" then
		set_widget_box_help(window, property_container:name(), property_container:description(), view)
	end

	for i, p in ipairs(property_container:properties()) do
		if p._visible then
			local name_text = EWS:StaticText(window, p:name(), "", "")

			set_widget_box_help(name_text, property_container:name() .. " / " .. p:name(), p:help(), view)
			grid_sizer:add(name_text, 0, 2, "LEFT,RIGHT,ALIGN_CENTER_VERTICAL")

			local w = p:create_widget(window, view)

			grid_sizer:add(w, 1, 0, "EXPAND")

			if i ~= #property_container:properties() then
				local la = EWS:StaticLine(window, "", "LI_HORIZONTAL")

				la:set_min_size(Vector3(10, 2, 0))
				grid_sizer:add(la, 0, 0, "EXPAND")

				local lb = EWS:StaticLine(window, "", "LI_HORIZONTAL")

				lb:set_min_size(Vector3(10, 2, 0))
				grid_sizer:add(lb, 1, 0, "EXPAND")
			end
		end
	end

	window:set_min_size(top_sizer:get_min_size())
	window:layout()
	window:thaw()
	topdown_layout(window)
end

CoreEffectProperty = CoreEffectProperty or class()

function CoreEffectProperty:init(name, ptype, value, help)
	self._name = name
	self._type = ptype
	self._value = value
	self._help = help
	self._values = {}
	self._variants = {}
	self._can_be_infinite = false
	self._silent = false
	self._save_to_child = true
	self._list_objects = {}
	self._list_members = {}
	self._min_name = "min"
	self._max_name = "max"
	self._visible = true

	if self._type == "keys" then
		self._looping = false
	end
end

function CoreEffectProperty:set_custom_validator(f)
	self._custom_validator = f
end

function CoreEffectProperty:set_range(a, b)
	self._min_range = a
	self._max_range = b
end

function CoreEffectProperty:set_min_max_name(a, b)
	self._min_name = a
	self._max_name = b
end

function CoreEffectProperty:set_presets(t)
	self._presets = t
end

function CoreEffectProperty:set_key_type(t)
	if t == "angle" then
		t = "float"
	elseif t == "time" then
		t = "float"
	elseif t == "opacity" then
		t = "float"
	end

	self._key_type = t
	self._keys = {}
	self._silent = true
end

function CoreEffectProperty:set_min_max(mi, ma)
	self._min = mi.x .. " " .. mi.y .. " " .. mi.z
	self._max = ma.x .. " " .. ma.y .. " " .. ma.z
end

function CoreEffectProperty:add_key(k)
	table.insert(self._keys, k)
end

function CoreEffectProperty:set_min_max_keys(mi, ma)
	self._min_keys = mi
	self._max_keys = ma
end

function CoreEffectProperty:set_save_to_child(b)
	self._save_to_child = b
end

function CoreEffectProperty:set_can_be_infinite(b)
	self._can_be_infinite = true
end

function CoreEffectProperty:set_silent(b)
	self._silent = b
end

function CoreEffectProperty:set_object(name, p)
	self._list_objects[name] = p
end

function CoreEffectProperty:set_compound_container(p)
	self._compound_container = p
end

function CoreEffectProperty:validate()
	local ret = {
		message = "",
		valid = true
	}

	if self._type == "value_list" then
		local function contains(l, v)
			for _, value in ipairs(l) do
				if type(value) == "userdata" and type(v) == "string" or type(value) == "string" and type(v) == "userdata" then
					if value:s() == v:s() then
						return true
					end
				elseif value == v then
					return true
				end
			end

			return false
		end

		if not contains(self._values, self._value) then
			ret.valid = false
			ret.message = self._name .. " has a value which is not in the list"

			return ret
		end
	elseif self._type == "variant" then
		return self._variants[self._value]:validate()
	elseif self._type == "compound" then
		ret = self._compound_container:validate_properties()

		if not ret.valid then
			return ret
		end
	elseif self._type == "list_objects" then
		for _, p in ipairs(self._list_members) do
			ret = p:validate()

			if not ret.valid then
				ret.message = self._name .. " - " .. ret.message

				return ret
			end
		end
	elseif self._type == "int" then
		if not tonumber(self._value) then
			ret.valid = false
			ret.message = self._value .. " is not a valid integer"

			return ret
		end
	elseif self._type == "vector3" then
		if not math.string_is_good_vector(self._value) then
			ret.valid = false
			ret.message = self._value .. " is not a valid vector3"

			return ret
		end
	elseif self._type == "percentage" then
		local v = tonumber(self._value)

		if not v or v < 0 or v > 1 then
			ret.valid = false
			ret.message = self._value .. " is not a valid number in [0,1]"

			return ret
		end
	elseif self._type == "color" then
		local c = nil

		if math.string_is_good_vector(self._value) then
			c = math.string_to_vector(self._value)
		end

		if not c or c.x < 0 or c.x > 255 or c.y < 0 or c.y > 255 or c.z < 0 or c.z > 255 then
			ret.valid = false
			ret.message = self._value .. " is not a valid color"

			return ret
		end
	elseif self._type == "opacity" then
		local c = tonumber(self._value)

		if not c or c < 0 or c > 255 then
			ret.valid = false
			ret.message = self._value .. " is not a valid opacity"

			return ret
		end
	elseif self._type == "time" then
		local t = tonumber(self._value)

		if not t or not self._can_be_infinite and t < 0 then
			ret.valid = false
			ret.message = self._value .. " is not a valid time"

			return ret
		end
	elseif self._type == "angle" then
		local a = tonumber(self._value)

		if not a then
			ret.valid = false
			ret.message = self._value .. " is not a valid angle"
		end
	elseif self._type == "float" then
		local a = tonumber(self._value)

		if not a then
			ret.valid = false
			ret.message = self._value .. " is not a valid float"
		elseif self._min_range and self._max_range and (a < self._min_range or self._max_range < a) then
			ret.valid = false
			ret.message = self._value .. " is out of range (" .. self._min_range .. ", " .. self._max_range .. ")"
		end
	elseif self._type == "texture" then
		if not DB:has("texture", self._value) then
			ret.valid = false
			ret.message = "texture " .. self._value .. " does not exist"

			return ret
		end
	elseif self._type == "unit" then
		if not DB:has("unit", self._value) then
			ret.valid = false
			ret.message = "unit " .. self._value .. " does not exist"

			return ret
		end
	elseif self._type == "effect" then
		if not DB:has("effect", self._value) or self._value == "" then
			ret.valid = false
			ret.message = "effect " .. self._value .. " does not exist"

			return ret
		end
	elseif self._type == "keys" then
		if #self._keys < self._min_keys then
			ret.valid = false
			ret.message = "Too few keys"

			return ret
		end

		if self._max_keys < #self._keys then
			ret.valid = false
			ret.message = "Too many keys"

			return ret
		end

		for _, k in ipairs(self._keys) do
			if not tonumber(k.t) then
				ret.valid = false
				ret.message = "time value invalid"

				return ret
			end

			local temp = CoreEffectProperty:new("", self._key_type, k.v, "")
			ret = temp:validate()

			if not ret.valid then
				ret.message = "Invalid key - " .. ret.message

				return ret
			end
		end
	end

	if ret.valid and self._custom_validator then
		return self:_custom_validator()
	end

	return ret
end

function CoreEffectProperty:name()
	return self._name
end

function CoreEffectProperty:add_value(v)
	table.insert(self._values, v)
end

function CoreEffectProperty:add_variant(name, prop)
	self._variants[name] = prop
end

function CoreEffectProperty:on_change(widget_view)
end

function CoreEffectProperty:on_commit(widget_view)
	if self._type == "null" then
		return
	end

	if self._value ~= widget_view.widget:get_value() then
		self._value = widget_view.widget:get_value()

		widget_view.view:update_view(false)
	end
end

function CoreEffectProperty:on_set_variant(widget_view_variant)
	local combo = widget_view_variant.combo
	local view = widget_view_variant.view
	local variant_panel = widget_view_variant.variant_panel
	local container = widget_view_variant.container
	local container_sizer = widget_view_variant.container_sizer
	self._value = combo:get_value()
	local variant = self._variants[self._value]

	variant_panel:destroy_children()

	local sizer = EWS:BoxSizer("VERTICAL")
	local p = variant:create_widget(variant_panel, view)

	sizer:add(p, 1, 0, "EXPAND")
	variant_panel:set_sizer(sizer)
	variant_panel:set_min_size(sizer:get_min_size())
	container:set_min_size(container_sizer:get_min_size())
	container:parent():layout()

	if widget_view_variant.update then
		view:update_view(false)
	end
end

function CoreEffectProperty:set_timeline_init_callback_name(c)
	self._timeline_init_callback = c
end

function create_text_field(parent, view, prop)
	local field = EWS:TextCtrl(parent, prop._value, "", "TE_PROCESS_ENTER")

	field:set_min_size(Vector3(20, 20, 0))
	field:connect("EVT_COMMAND_TEXT_UPDATED", callback(prop, prop, "on_change", {
		widget = field,
		view = view
	}))
	field:connect("EVT_COMMAND_TEXT_ENTER", callback(prop, prop, "on_commit", {
		widget = field,
		view = view
	}))
	field:connect("EVT_KILL_FOCUS", callback(prop, prop, "on_commit", {
		widget = field,
		view = view
	}))

	return field
end

function create_color_selector(parent, view, prop)
	local button = EWS:Button(parent, " ", "", "BU_EXACTFIT")

	local function on_click(vars)
		local cdlg = EWS:ColourDialog(vars.button, true, math.string_to_vector(vars.prop._value) * 0.00392156862745098)

		if cdlg:show_modal() then
			local c = cdlg:get_colour() * 255
			vars.prop._value = c.x .. " " .. c.y .. " " .. c.z

			vars:update_colour()
			vars.view:update_view(false)
		end
	end

	local function update_colour(vars)
		local c = math.string_to_vector(vars.prop._value)

		vars.button:set_background_colour(c.x, c.y, c.z)
	end

	local vars = {
		button = button,
		prop = prop,
		view = view,
		update_colour = update_colour
	}

	button:connect("EVT_COMMAND_BUTTON_CLICKED", on_click, vars)
	update_colour(vars)

	return button
end

function create_texture_selector(parent, view, prop)
	local panel = EWS:Panel(parent, "", "")
	local panel_sizer = EWS:BoxSizer("HORIZONTAL")

	panel:set_sizer(panel_sizer)

	local field = create_text_field(panel, view, prop)
	local browse_button = EWS:Button(panel, "...", "", "BU_EXACTFIT")

	panel_sizer:add(field, 1, 0, "EXPAND")
	panel_sizer:add(browse_button, 0, 0, "EXPAND")

	local function on_browse_button_click()
		local path = managers.database:open_file_dialog(panel, "Textures (*.dds)|*.dds", view._last_texture_dir)

		if path then
			prop._value = managers.database:entry_path(path)
			view._last_texture_dir = dir_name(path)

			field:change_value(prop._value)
			view:update_view(false)
		end
	end

	browse_button:connect("EVT_COMMAND_BUTTON_CLICKED", on_browse_button_click, nil)

	return panel
end

function create_effect_selector(parent, view, prop)
	local panel = EWS:Panel(parent, "", "")
	local panel_sizer = EWS:BoxSizer("HORIZONTAL")

	panel:set_sizer(panel_sizer)

	local field = create_text_field(panel, view, prop)
	local browse_button = EWS:Button(panel, "...", "", "BU_EXACTFIT")

	panel_sizer:add(field, 1, 0, "EXPAND")
	panel_sizer:add(browse_button, 0, 0, "EXPAND")

	local function on_browse_button_click()
		local path = managers.database:open_file_dialog(panel, "Effects (*.effect)|*.effect", view._last_used_dir)

		if path then
			prop._value = managers.database:entry_path(path)
			view._last_used_dir = dir_name(path)

			field:change_value(prop._value)
			view:update_view(false)
		end
	end

	browse_button:connect("EVT_COMMAND_BUTTON_CLICKED", on_browse_button_click, nil)

	return panel
end

function create_percentage_slider(parent, view, prop)
	local slider = EWS:Slider(parent, tonumber(prop._value) * 100, 0, 100, "", "")

	local function on_thumbtrack(vars)
		vars.prop._value = "" .. vars.slider:get_value() / 100

		vars.view:update_view(false)
	end

	slider:connect("EVT_SCROLL_THUMBRELEASE", on_thumbtrack, {
		slider = slider,
		view = view,
		prop = prop
	})

	return slider
end

function create_check(parent, view, prop)
	local check = EWS:CheckBox(parent, "", "", "")

	local function on_check(vars)
		vars.prop._value = "false"

		if vars.check:get_value() then
			vars.prop._value = "true"
		end

		vars.view:update_view(false)
	end

	check:set_value(prop._value == "true")
	check:connect("EVT_COMMAND_CHECKBOX_CLICKED", on_check, {
		check = check,
		view = view,
		prop = prop
	})

	return check
end

function create_key_curve_widget(parent, view, prop)
	local function refresh_list(vars)
		local listbox = vars.listbox
		local prop = vars.prop

		listbox:clear()

		for _, k in ipairs(prop._keys) do
			listbox:append("t = " .. k.t .. ", v = " .. k.v)
		end

		vars.view:update_view(false)
	end

	local function on_add(vars)
		local listbox = vars.listbox
		local t = vars.t
		local v = vars.v
		local prop = vars.prop

		if #prop._keys < prop._max_keys then
			prop:add_key({
				t = t:get_value(),
				v = v:get_value()
			})
			vars:refresh_list()
		end
	end

	local function on_remove(vars)
		local listbox = vars.listbox
		local t = vars.t
		local v = vars.v
		local prop = vars.prop

		if listbox:selected_index() < 0 then
			return
		end

		if prop._min_keys < #prop._keys then
			table.remove(prop._keys, listbox:selected_index() + 1)
			vars:refresh_list()
		end
	end

	local function on_select(vars)
		local listbox = vars.listbox
		local t = vars.t
		local v = vars.v
		local prop = vars.prop

		if listbox:selected_index() < 0 then
			return
		end

		t:set_value(prop._keys[listbox:selected_index() + 1].t)
		v:set_value(prop._keys[listbox:selected_index() + 1].v)
	end

	local function on_set(vars)
		local listbox = vars.listbox
		local t = vars.t
		local v = vars.v
		local prop = vars.prop

		if listbox:selected_index() < 0 then
			return
		end

		prop._keys[listbox:selected_index() + 1].t = t:get_value()
		prop._keys[listbox:selected_index() + 1].v = v:get_value()

		vars:refresh_list()
	end

	local panel = EWS:Panel(parent, "", "")
	local listbox = EWS:ListBox(panel, "", "LB_SINGLE,LB_HSCROLL")
	local add_button = EWS:Button(panel, "Add", "", "BU_EXACTFIT")
	local remove_button = EWS:Button(panel, "Remove", "", "BU_EXACTFIT")
	local t = EWS:TextCtrl(panel, "0", "", "TE_PROCESS_ENTER")

	t:set_min_size(Vector3(40, 20, 0))

	local v = EWS:TextCtrl(panel, "0 0 0", "", "TE_PROCESS_ENTER")

	v:set_min_size(Vector3(40, 20, 0))

	local top_sizer = EWS:BoxSizer("VERTICAL")

	top_sizer:add(listbox, 1, 0, "EXPAND")

	local row_sizer = EWS:BoxSizer("HORIZONTAL")

	row_sizer:add(add_button, 0, 4, "ALL")
	row_sizer:add(remove_button, 0, 4, "ALL")
	top_sizer:add(row_sizer, 0, 0, "EXPAND")

	row_sizer = EWS:BoxSizer("HORIZONTAL")

	row_sizer:add(EWS:StaticText(panel, "t = ", "", ""), 0, 4, "ALIGN_CENTER_VERTICAL,LEFT,RIGHT")
	row_sizer:add(t, 0, 0, "")
	row_sizer:add(EWS:StaticText(panel, "v = ", "", ""), 0, 4, "ALIGN_CENTER_VERTICAL,LEFT,RIGHT")
	row_sizer:add(v, 1, 0, "EXPAND")
	top_sizer:add(row_sizer, 0, 0, "EXPAND")
	panel:set_sizer(top_sizer)

	local vars = {
		listbox = listbox,
		t = t,
		v = v,
		prop = prop,
		refresh_list = refresh_list,
		view = view
	}

	refresh_list(vars)
	add_button:connect("EVT_COMMAND_BUTTON_CLICKED", on_add, vars)
	remove_button:connect("EVT_COMMAND_BUTTON_CLICKED", on_remove, vars)
	v:connect("EVT_COMMAND_TEXT_ENTER", on_set, vars)
	listbox:connect("EVT_COMMAND_LISTBOX_SELECTED", on_select, vars)
	listbox:select_index(0)
	on_select(vars)

	return panel
end

function topdown_layout(w)
	local q = w

	while q and q.type_name == "EWSPanel" do
		q:set_sizer_min_size()
		q:layout()
		q:refresh()

		q = q:parent()
	end
end

function CoreEffectProperty:create_widget(parent, view)
	local widget = nil

	if self._type == "value_list" then
		widget = EWS:ComboBox(parent, self._value, "", "CB_DROPDOWN,CB_READONLY")

		for _, v in ipairs(self._values) do
			widget:append(v)
		end

		widget:set_value(self._value)
		widget:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "on_commit", {
			widget = widget,
			view = view
		}))
	elseif self._type == "timeline" then
		widget = EWS:TimelineEdit(parent, "")

		view[self._timeline_init_callback](view, widget)
	elseif self._type == "vector3" or self._type == "vector2" then
		widget = EWS:Vector3Selector(parent, "", math.string_to_vector(self._value))

		widget:connect("EVT_SELECTOR_UPDATED", callback(self, self, "on_commit", {
			widget = widget,
			view = view
		}))

		if self._type == "vector2" then
			widget:set_vector2(true)
		end
	elseif self._type == "box" then
		widget = EWS:AABBSelector(parent, "", math.string_to_vector(self._min), math.string_to_vector(self._max))

		local function on_box_commit(widget_view)
			if math.string_to_vector(self._min) ~= widget_view.widget:get_min() or math.string_to_vector(self._max) ~= widget_view.widget:get_max() then
				local minv = widget_view.widget:get_min()
				local maxv = widget_view.widget:get_max()
				self._min = minv.x .. " " .. minv.y .. " " .. minv.z
				self._max = maxv.x .. " " .. maxv.y .. " " .. maxv.z

				widget_view.view:update_view(false)
			end
		end

		widget:connect("EVT_SELECTOR_UPDATED", on_box_commit, {
			widget = widget,
			view = view
		})
	elseif self._type == "variant" then
		widget = EWS:Panel(parent, "", "")
		local combo = EWS:ComboBox(widget, "", "", "CB_DROPDOWN,CB_READONLY")

		set_widget_help(combo, self._help)

		for vn, p in pairs(self._variants) do
			combo:append(vn)
		end

		local variant_panel = EWS:Panel(widget, "", "")
		local sizer = EWS:BoxSizer("VERTICAL")

		sizer:add(combo, 0, 0, "EXPAND")
		sizer:add(variant_panel, 1, 0, "EXPAND")
		combo:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "on_set_variant", {
			update = true,
			combo = combo,
			container = widget,
			view = view,
			variant_panel = variant_panel,
			container_sizer = sizer
		}))
		combo:set_value(self._value)
		widget:set_sizer(sizer)
		widget:set_min_size(sizer:get_min_size())
		self:on_set_variant({
			update = false,
			combo = combo,
			container = widget,
			view = view,
			variant_panel = variant_panel,
			container_sizer = sizer
		})
	elseif self._type == "compound" then
		widget = EWS:Panel(parent, "", "")

		self._compound_container:fill_property_container_sheet(widget, view)
	elseif self._type == "list_objects" then
		local function on_add_object(vars)
			table.insert(vars.property._list_members, deep_clone(self._list_objects[vars.combo:get_value()]))
			vars:fill_list()
			vars.view:update_view(false)
		end

		local function on_remove_object(vars)
			if vars.list_box:selected_index() < 0 then
				return
			end

			table.remove(vars.property._list_members, vars.list_box:selected_index() + 1)
			vars:fill_list()
			vars:on_select_object()
			vars.view:update_view(false)
		end

		local function on_select_object(vars)
			local top_sizer = EWS:BoxSizer("VERTICAL")

			vars.sheet:set_sizer(top_sizer)
			vars.sheet:destroy_children()

			if vars.list_box:selected_index() < 0 then
				vars.sheet:set_min_size(top_sizer:get_min_size())

				return
			end

			local w = vars.property._list_members[vars.list_box:selected_index() + 1]:create_widget(vars.sheet, vars.view)

			top_sizer:add(w, 1, 0, "EXPAND")
			vars.sheet:layout()
			vars.sheet:set_min_size(top_sizer:get_min_size())
			vars.container:set_min_size(vars.container_sizer:get_min_size())
			vars.container:parent():layout()
			vars.container:parent():refresh()
			topdown_layout(vars.sheet)
		end

		local function fill_list(vars)
			vars.list_box:clear()

			for _, p in ipairs(vars.property._list_members) do
				vars.list_box:append(p:name())
			end
		end

		widget = EWS:Panel(parent, "", "")
		local list_box = EWS:ListBox(widget, "", "LB_SINGLE,LB_HSCROLL")
		local remove_button = EWS:Button(widget, "Remove", "", "BU_EXACTFIT")
		local combo = EWS:ComboBox(widget, "", "", "CB_DROPDOWN,CB_READONLY")

		for n, p in pairs(self._list_objects) do
			combo:append(n)
			combo:set_value(n)
		end

		local add_button = EWS:Button(widget, "Add", "", "BU_EXACTFIT")
		local sheet = EWS:Panel(widget, "", "")
		local top_sizer = EWS:BoxSizer("VERTICAL")
		local vars = {
			property = self,
			combo = combo,
			container = widget,
			container_sizer = top_sizer,
			list_box = list_box,
			fill_list = fill_list,
			sheet = sheet,
			view = view,
			on_select_object = on_select_object
		}

		remove_button:connect("EVT_COMMAND_BUTTON_CLICKED", on_remove_object, vars)
		add_button:connect("EVT_COMMAND_BUTTON_CLICKED", on_add_object, vars)
		list_box:connect("EVT_COMMAND_LISTBOX_SELECTED", on_select_object, vars)
		fill_list(vars)

		local row_sizer = EWS:BoxSizer("HORIZONTAL")

		row_sizer:add(list_box, 1, 0, "EXPAND")
		row_sizer:add(remove_button, 0, 0, "")
		top_sizer:add(row_sizer, 0, 0, "EXPAND")

		row_sizer = EWS:BoxSizer("HORIZONTAL")

		row_sizer:add(combo, 1, 0, "EXPAND")
		row_sizer:add(add_button, 0, 0, "")
		top_sizer:add(row_sizer, 0, 0, "EXPAND")
		top_sizer:add(sheet, 1, 0, "EXPAND")
		widget:set_sizer(top_sizer)
	elseif self._type == "null" then
		widget = EWS:Panel(parent, "", "")
	elseif self._type == "color" then
		widget = create_color_selector(parent, view, self)
	elseif self._type == "texture" then
		widget = create_texture_selector(parent, view, self)
	elseif self._type == "effect" then
		widget = create_effect_selector(parent, view, self)
	elseif self._type == "percentage" then
		widget = create_percentage_slider(parent, view, self)
	elseif self._type == "keys" then
		widget = EWS:CurveSelector(parent, "", self._key_type:upper())

		for _, k in ipairs(self._keys) do
			local v = Vector3(0, 0, 0)
			local vs = k.v

			if self._key_type == "vector2" then
				vs = vs .. " 0"
			elseif self._key_type == "float" then
				vs = vs .. " 0 0"
			end

			v = math.string_to_vector(vs)

			widget:add_key(tonumber(k.t), v)
		end

		local function on_keys_commit(widget_view)
			local keys = widget_view.widget:get_keys()
			local prop = widget_view.prop
			prop._keys = {}

			for _, k in ipairs(keys) do
				local s = ""

				if prop._key_type == "vector2" then
					s = k.v.x .. " " .. k.v.y
				elseif prop._key_type == "float" then
					s = k.v.x .. ""
				else
					s = k.v.x .. " " .. k.v.y .. " " .. k.v.z
				end

				table.insert(prop._keys, {
					t = k.t,
					v = s
				})
			end

			self._looping = widget_view.widget:looping()

			widget_view.view:update_view(false)
		end

		widget:set_looping(self._looping)
		widget:connect("EVT_SELECTOR_UPDATED", on_keys_commit, {
			widget = widget,
			view = view,
			prop = self
		})
		widget:set_min_max_keys(self._min_keys, self._max_keys)

		if self._presets then
			widget:set_presets(self._presets)
		end
	elseif self._type == "boolean" then
		widget = create_check(parent, view, self)
	else
		widget = create_text_field(parent, view, self)
	end

	return widget
end

function CoreEffectProperty:help()
	return self._help
end

function CoreEffectProperty:save(node)
	if self._type == "null" then
		return
	end

	if self._type == "compound" then
		local n = nil

		if self._save_to_child then
			n = node:make_child(self._compound_container:name())
		else
			n = node
		end

		self._compound_container:save_properties(n)
	elseif self._type == "box" then
		if not self._silent then
			node:set_parameter(self._min_name, self._min)
			node:set_parameter(self._max_name, self._max)
		end
	elseif self._type == "list_objects" then
		for _, p in ipairs(self._list_members) do
			local n = node:make_child(p:name())

			p:save(n)
		end
	else
		if not self._silent then
			node:set_parameter(self._name, self._value)
		end

		if self._type == "variant" then
			self._variants[self._value]:save(node)
		elseif self._type == "keys" then
			local n = node:make_child(self._name)
			local ls = "false"

			if self._looping then
				ls = "true"
			end

			n:set_parameter("loop", ls)

			for _, k in ipairs(self._keys) do
				local kn = n:make_child("key")

				kn:set_parameter("t", k.t)
				kn:set_parameter("v", k.v)
			end
		end
	end
end

function CoreEffectProperty:load(node)
	if self._type == "null" then
		return
	end

	if self._type == "compound" then
		if self._save_to_child then
			for c in node:children() do
				if c:name() == self._compound_container:name() then
					self._compound_container:load_properties(c)
				end
			end
		else
			self._compound_container:load_properties(node)
		end
	elseif self._type == "box" then
		if not self._silent and node:has_parameter(self._min_name) then
			self._min = node:parameter(self._min_name)
			self._max = node:parameter(self._max_name)
		end
	elseif self._type == "list_objects" then
		for c in node:children() do
			local m = self._list_objects[c:name()]

			if m then
				m = deep_clone(m)

				m:load(c)
				table.insert(self._list_members, m)
			end
		end
	else
		if not self._silent and node:has_parameter(self._name) then
			self._value = node:parameter(self._name)
		end

		if self._type == "variant" then
			self._variants[self._value]:load(node)
		elseif self._type == "value_list" then
			local function contains(l, v)
				for _, value in ipairs(l) do
					if type(value) == "userdata" and type(v) == "string" or type(value) == "string" and type(v) == "userdata" then
						if value:s() == v:s() then
							return true
						end
					elseif value == v then
						return true
					end
				end

				return false
			end

			if not contains(self._values, self._value) then
				table.insert(self._values, self._value)
			end
		elseif self._type == "keys" then
			self._keys = {}

			for c in node:children() do
				if c:name() == self._name then
					if c:has_parameter("loop") then
						self._looping = c:parameter("loop") == "true"
					else
						self._looping = false
					end

					for kn in c:children() do
						local t = kn:parameter("t")
						local v = kn:parameter("v")

						self:add_key({
							t = t,
							v = v
						})
					end
				end
			end
		end
	end
end

function CoreEffectProperty:value()
	return self._value
end
