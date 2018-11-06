EnableSoundEnvironmentElement = EnableSoundEnvironmentElement or class(MissionElement)

function EnableSoundEnvironmentElement:init(unit)
	EnableSoundEnvironmentElement.super.init(self, unit)

	self._hed.enable = true
	self._hed.elements = {}

	table.insert(self._save_values, "enable")
	table.insert(self._save_values, "elements")
end

function EnableSoundEnvironmentElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	self._btn_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	self._btn_toolbar:add_tool("ADD_UNIT_LIST", "Add unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	self._btn_toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_unit_list_btn"), nil)
	self._btn_toolbar:realize()
	panel_sizer:add(self._btn_toolbar, 0, 1, "EXPAND,LEFT")

	local enable_sound_env = EWS:CheckBox(panel, "Enable", "")

	enable_sound_env:set_value(self._hed.enable)
	enable_sound_env:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "enable",
		ctrlr = enable_sound_env
	})
	panel_sizer:add(enable_sound_env, 0, 0, "EXPAND")
end

function EnableSoundEnvironmentElement:update_editing()
end

function EnableSoundEnvironmentElement:update_selected(t, dt)
	for _, area in ipairs(managers.sound_environment:areas()) do
		for _, name in ipairs(self._hed.elements) do
			if area:name() == name then
				self:_draw_link({
					g = 0.5,
					b = 1,
					r = 0.9,
					from_unit = self._unit,
					to_unit = area:unit()
				})
			end
		end
	end
end

function EnableSoundEnvironmentElement:update_unselected()
	for _, name in ipairs(self._hed.elements) do
		for _, area in ipairs(managers.sound_environment:areas()) do
			if area:name() == name and not alive(area:unit()) then
				self:_add_or_remove_graph(name)
			end
		end
	end
end

function EnableSoundEnvironmentElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and string.find(ray.unit:name():s(), "core/units/sound_environment/sound_environment", 1, true) then
		for _, area in ipairs(managers.sound_environment:areas()) do
			if area:unit():key() == ray.unit:key() then
				self:_add_or_remove_graph(area:name())

				return
			end
		end
	end
end

function EnableSoundEnvironmentElement:remove_links(unit)
	for _, area in ipairs(managers.sound_environment:areas()) do
		if area:unit():key() == unit:key() then
			for _, name in ipairs(self._hed.elements) do
				if name == area:name() then
					table.delete(self._hed.elements, name)
				end
			end
		end
	end
end

function EnableSoundEnvironmentElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function EnableSoundEnvironmentElement:add_unit_list_btn()
	local function f(unit)
		return unit:type() == Idstring("sound")
	end

	local dialog = SelectUnitByNameModal:new("Add Trigger Unit", f)
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	for _, unit in ipairs(dialog:selected_units()) do
		for _, area in ipairs(managers.sound_environment:areas()) do
			if area:unit():key() == unit:key() then
				self:_add_or_remove_graph(area:name())

				return
			end
		end
	end
end

function EnableSoundEnvironmentElement:_add_or_remove_graph(id)
	if table.contains(self._hed.elements, id) then
		table.delete(self._hed.elements, id)
	else
		table.insert(self._hed.elements, id)
	end
end
