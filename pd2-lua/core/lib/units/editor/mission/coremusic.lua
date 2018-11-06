CoreMusicUnitElement = CoreMusicUnitElement or class(MissionElement)
MusicUnitElement = MusicUnitElement or class(CoreMusicUnitElement)

function MusicUnitElement:init(...)
	CoreMusicUnitElement.init(self, ...)
end

function CoreMusicUnitElement:init(unit)
	MissionElement.init(self, unit)
	table.insert(self._save_values, "music_event")
	table.insert(self._save_values, "use_instigator")
end

function CoreMusicUnitElement:test_element()
	if self._hed.music_event then
		managers.editor:set_wanted_mute(false)
		managers.music:post_event(self._hed.music_event)
	end
end

function CoreMusicUnitElement:stop_test_element()
	managers.editor:set_wanted_mute(true)
	managers.music:stop()
end

function CoreMusicUnitElement:_set_category(params)
	local value = params.value

	CoreEws.update_combobox_options(self._music_params, managers.music:music_events(value))
	CoreEws.change_combobox_value(self._music_params, managers.music:music_events(value)[1])

	self._hed.music_event = self._music_params.value
end

function CoreMusicUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local paths = clone(managers.music:music_paths())

	if #paths <= 0 then
		local help = {
			text = "No music available in project!",
			panel = panel,
			sizer = panel_sizer
		}

		self:add_help_text(help)

		return
	end

	self._hed.music_event = self._hed.music_event or managers.music:music_events(paths[1])[1]
	local path_value = managers.music:music_path(self._hed.music_event)

	CoreEws.combobox_and_list({
		name = "Category:",
		panel = panel,
		sizer = panel_sizer,
		options = paths,
		value = path_value,
		value_changed_cb = callback(self, self, "_set_category")
	})

	local _, music_params = self:_build_value_combobox(panel, panel_sizer, "music_event", managers.music:music_events(path_value))
	self._music_params = music_params

	self:_build_value_checkbox(panel, panel_sizer, "use_instigator")
end
