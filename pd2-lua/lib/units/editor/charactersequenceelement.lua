CharacterSequenceElement = SequenceCharacterElement or class(MissionElement)
CharacterSequenceElement.SAVE_UNIT_POSITION = false
CharacterSequenceElement.SAVE_UNIT_ROTATION = false
CharacterSequenceElement.LINK_ELEMENTS = {
	"elements"
}

function CharacterSequenceElement:init(unit)
	CharacterSequenceElement.super.init(self, unit)

	self._hed.elements = {}
	self._hed.sequence = ""

	table.insert(self._save_values, "use_instigator")
	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "sequence")
end

function CharacterSequenceElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"ai_spawn_enemy",
		"ai_spawn_civilian"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_checkbox(panel, panel_sizer, "use_instigator")

	local text = EWS:TextCtrl(panel, self._hed.sequence, "", "TE_PROCESS_ENTER")

	text:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "sequence",
		ctrlr = text
	})
	text:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "sequence",
		ctrlr = text
	})
	panel_sizer:add(text, 0, 0, "EXPAND")
end

function CharacterSequenceElement:draw_links(t, dt, selected_unit, all_units)
	CharacterSequenceElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

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

function CharacterSequenceElement:on_lmb()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and (string.find(ray.unit:name():s(), "ai_spawn_enemy", 1, true) or string.find(ray.unit:name():s(), "ai_spawn_civilian", 1, true)) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CharacterSequenceElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "on_lmb"))
end

function CharacterSequenceElement:update_editing()
end
