require("core/lib/utils/dev/ews/sequencer/CoreCutsceneSequencerTrackBehaviour")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneFootage")

CoreCutsceneSequencerPanel = CoreCutsceneSequencerPanel or mixin(class(), BasicEventHandling)

function CoreCutsceneSequencerPanel:init(parent_frame)
	self:_create_panel(parent_frame)

	self._tree_refresh_timeout = 0
	self._track_behaviour = EditableTrackBehaviour:new()

	self._track_behaviour:set_delegate(self)
end

function CoreCutsceneSequencerPanel:update(time, delta_time)
	local current_mouse_event = EWS:MouseEvent("EVT_MOTION")
	self._previous_mouse_event = self._previous_mouse_event or current_mouse_event

	if current_mouse_event:get_position() ~= self._previous_mouse_event:get_position() then
		self:_send_event("EVT_SYSTEM_WIDE_MOTION", current_mouse_event)
	end

	if current_mouse_event:left_is_down() == false and self._previous_mouse_event:left_is_down() == true then
		self:_send_event("EVT_SYSTEM_WIDE_LEFT_UP", current_mouse_event)
	end

	self._previous_mouse_event = current_mouse_event
end

function CoreCutsceneSequencerPanel:panel()
	return self._panel
end

function CoreCutsceneSequencerPanel:freeze()
	self._ruler:freeze()
	self:audio_track():freeze()
	self:key_track():freeze()

	for _, track in ipairs(self:film_tracks()) do
		track:freeze()
	end
end

function CoreCutsceneSequencerPanel:thaw()
	self._ruler:thaw()
	self:audio_track():thaw()
	self:key_track():thaw()

	for _, track in ipairs(self:film_tracks()) do
		track:thaw()
	end
end

function CoreCutsceneSequencerPanel:ruler()
	return self._ruler
end

function CoreCutsceneSequencerPanel:audio_track()
	return self._audio_track
end

function CoreCutsceneSequencerPanel:key_track()
	return self._key_track
end

function CoreCutsceneSequencerPanel:film_tracks()
	return self._film_tracks
end

function CoreCutsceneSequencerPanel:tracks()
	if self._tracks == nil then
		self._tracks = {}

		table.insert(self._tracks, self:key_track())

		for _, track in ipairs(self:film_tracks()) do
			table.insert(self._tracks, track)
		end
	end

	return self._tracks
end

function CoreCutsceneSequencerPanel:track_at_screen_position(screen_position)
	return table.find_value(self:tracks(), function (track)
		return track:point_is_inside(screen_position)
	end)
end

function CoreCutsceneSequencerPanel:pixels_per_division()
	return self._ruler:pixels_per_major_division()
end

function CoreCutsceneSequencerPanel:units_per_division()
	return self._ruler:units_per_major_division()
end

function CoreCutsceneSequencerPanel:set_units(pixels_per_division, units_per_division)
	self._ruler:set_major_divisions(pixels_per_division, units_per_division)
	self:audio_track():set_units_from_ruler(self._ruler)
	self:key_track():set_units_from_ruler(self._ruler)

	for _, track in ipairs(self:film_tracks()) do
		track:set_units_from_ruler(self._ruler)
	end
end

function CoreCutsceneSequencerPanel:active_film_track()
	return self._active_film_track
end

function CoreCutsceneSequencerPanel:set_active_film_track(active_track)
	self._active_film_track = active_track

	for _, track in ipairs(self:film_tracks()) do
		track:set_background_colour(self:_track_background_colour(track == self._active_film_track):unpack())
	end

	self:_send_event("EVT_EVALUATE_FRAME_AT_PLAYHEAD", {
		position = function ()
			return position
		end
	})
end

function CoreCutsceneSequencerPanel:film_clips()
	return table.inject(self:film_tracks(), {}, function (accumulated, track)
		return table.list_union(accumulated, track:clips())
	end)
end

function CoreCutsceneSequencerPanel:selected_items()
	return table.list_union(self:selected_film_clips(), self:selected_audio_clips(), self:selected_keys())
end

function CoreCutsceneSequencerPanel:selected_film_clips()
	return table.inject(self:film_tracks(), {}, function (accumulated, track)
		return table.list_union(accumulated, track:selected_clips())
	end)
end

function CoreCutsceneSequencerPanel:selected_audio_clips()
	return self:audio_track():selected_clips()
end

function CoreCutsceneSequencerPanel:selected_keys()
	return self:key_track():selected_clips()
end

function CoreCutsceneSequencerPanel:add_film_clip(track_index, offset, cutscene_id, from, to, camera)
	local track = assert(self:film_tracks()[track_index], "Film track index out of bounds.")
	local footage = assert(core_or_local("CutsceneFootage", managers.cutscene:get_cutscene(cutscene_id)), "Cutscene \"" .. cutscene_id .. "\" does not exist.")
	local clip = footage:create_clip(from, to, camera)

	return track:add_clip(clip, offset - from)
end

function CoreCutsceneSequencerPanel:add_audio_clip(offset, sound)
end

function CoreCutsceneSequencerPanel:add_cutscene_key(cutscene_key)
	local sequencer_key = EWS:SequencerKey()

	sequencer_key:set_colour(cutscene_key.COLOUR:unpack())
	sequencer_key:offset_by(cutscene_key:frame())
	sequencer_key:set_metadata(cutscene_key)

	return self:key_track():add_clip(sequencer_key)
end

function CoreCutsceneSequencerPanel:remove_items(clip_list)
	self:freeze()

	local removed_count = 0

	for _, clip in ipairs(clip_list) do
		self:_send_event("EVT_REMOVE_ITEM", clip)

		if self:audio_track():remove_clip(clip) or self:key_track():remove_clip(clip) then
			removed_count = removed_count + 1
		else
			for _, track in ipairs(self:film_tracks()) do
				if track:remove_clip(clip) then
					removed_count = removed_count + 1

					break
				end
			end
		end
	end

	self:thaw()
	self:_send_event("EVT_EVALUATE_FRAME_AT_PLAYHEAD", {
		position = function ()
			return position
		end
	})

	return removed_count
end

function CoreCutsceneSequencerPanel:remove_all_items()
	self:freeze()

	for _, clip in ipairs(self:audio_track():clips()) do
		self:_send_event("EVT_REMOVE_ITEM", clip)
	end

	self:audio_track():remove_all_clips()

	for _, clip in ipairs(self:key_track():clips()) do
		self:_send_event("EVT_REMOVE_ITEM", clip)
	end

	self:key_track():remove_all_clips()

	for _, track in ipairs(self:film_tracks()) do
		for _, clip in ipairs(track:clips()) do
			self:_send_event("EVT_REMOVE_ITEM", clip)
		end

		track:remove_all_clips()
	end

	self:_send_event("EVT_EVALUATE_FRAME_AT_PLAYHEAD", {
		position = function ()
			return position
		end
	})
	self:thaw()
end

function CoreCutsceneSequencerPanel:set_item_selected(item, selected)
	item:set_selected(selected)
	self:_send_event("EVT_SELECTION_CHANGED")
end

function CoreCutsceneSequencerPanel:select_all_clips()
	self:audio_track():select_all_clips()
	self:key_track():select_all_clips()

	for _, track in ipairs(self:film_tracks()) do
		track:select_all_clips()
	end

	self:_send_event("EVT_SELECTION_CHANGED")
end

function CoreCutsceneSequencerPanel:deselect_all_items()
	self:audio_track():deselect_all_clips()
	self:key_track():deselect_all_clips()

	for _, track in ipairs(self:film_tracks()) do
		track:deselect_all_clips()
	end

	self:_send_event("EVT_SELECTION_CHANGED")
end

function CoreCutsceneSequencerPanel:playhead_position()
	return self._ruler:playhead_position()
end

function CoreCutsceneSequencerPanel:set_playhead_position(position)
	local current_position = self:playhead_position()
	position = math.max(position, 0)

	if position ~= current_position then
		self._ruler:set_playhead_position(position)

		for _, ornament in ipairs(self._playhead_ornaments) do
			ornament:set_time(position)
		end

		self:_evaluate_frame_at_playhead()
	end
end

function CoreCutsceneSequencerPanel:_evaluate_frame_at_playhead()
	self:_send_event("EVT_EVALUATE_FRAME_AT_PLAYHEAD", {
		position = function ()
			return self:playhead_position()
		end
	})
end

function CoreCutsceneSequencerPanel:_signal_drag(dragged_clip, drag_mode)
	self:_send_event("EVT_DRAG_ITEM", dragged_clip, drag_mode)
end

function CoreCutsceneSequencerPanel:zoom_around(time, offset_in_window, delta)
	self._scrolled_area:freeze()

	local new_pixels_per_division = self:pixels_per_division() + delta

	self:set_units(new_pixels_per_division, self:units_per_division())

	local scroll_offset = self:key_track():units_to_pixels(time) - offset_in_window

	self._scrolled_area:scroll(Vector3(scroll_offset / self._scrolled_area:scroll_pixels_per_unit().x, -1, 0))
	self._scrolled_area:thaw()
end

function CoreCutsceneSequencerPanel:_create_panel(parent_frame)
	self._panel = EWS:Panel(parent_frame)
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	self._panel:set_sizer(panel_sizer)

	self._ruler = EWS:SequencerRuler(self._panel)

	self._ruler:set_playhead_bitmap(CoreEWS.image_path("sequencer\\playhead.png"))
	self._ruler:set_major_divisions(100, 500)
	self:_connect_mouse_events(self._ruler)
	self:_connect_mouse_events(self._ruler, true)
	panel_sizer:add(self._ruler, 0, 0, "EXPAND")

	self._scrolled_area = EWS:ScrolledWindow(self._panel)

	panel_sizer:add(self._scrolled_area, 1, 0, "EXPAND")
	self._scrolled_area:set_scrollbars(Vector3(1, 1, 1), Vector3(1, 1, 1), Vector3(0, 0, 0), false)

	local scrolled_area_sizer = EWS:BoxSizer("VERTICAL")

	self._scrolled_area:set_sizer(scrolled_area_sizer)
	self._scrolled_area:connect("EVT_PAINT", callback(self, self, "_on_scrolled_area_paint"))

	self._playhead_ornaments = {}
	self._box_selection_ornaments = {}
	self._audio_track = responder_map({
		remove_clip = false,
		default = {}
	})
	self._key_track = EWS:SequencerTrack(self._scrolled_area)

	self._key_track:set_min_size(Vector3(self._key_track:get_min_size().x, self._key_track:get_min_size().y * 3, 0))
	self._key_track:set_units(100, 500)
	self._key_track:set_icon_bitmap(CoreEWS.image_path("sequencer\\track_icon_key.bmp"), 10)
	self._key_track:set_background_colour(self:_track_background_colour(true):unpack())
	self:_connect_mouse_events(self._key_track)
	scrolled_area_sizer:add(self._key_track, 0, 0, "EXPAND")
	self:_create_ornaments_for_track(self._key_track)

	self._film_tracks = {}

	for i = 1, 10 do
		local track = EWS:SequencerTrack(self._scrolled_area)

		track:set_icon_bitmap(CoreEWS.image_path("sequencer\\track_icon_film.bmp"), 7)
		track:set_background_colour(self:_track_background_colour(false):unpack())
		self:_connect_mouse_events(track)
		scrolled_area_sizer:add(track, 0, 0, "EXPAND")
		self:_create_ornaments_for_track(track)
		table.insert(self._film_tracks, track)
	end

	self:set_active_film_track(self._film_tracks[1])
	self:set_playhead_position(0)
end

function CoreCutsceneSequencerPanel:_create_ornaments_for_track(track)
	local playhead_ornament = EWS:SequencerLineOrnament()

	table.insert(self._playhead_ornaments, track:add_ornament(playhead_ornament))

	local box_selection_ornament = EWS:SequencerBoxSelectionOrnament()

	box_selection_ornament:set_fill_style("FDIAGONAL_HATCH")
	table.insert(self._box_selection_ornaments, track:add_ornament(box_selection_ornament))
end

function CoreCutsceneSequencerPanel:_track_background_colour(active)
	local colour = EWS:get_system_colour("3DFACE")

	if not active then
		colour = colour * 0.8
	end

	return colour
end

function CoreCutsceneSequencerPanel:_show_film_track_context_menu(track, event)
	local clip_below_cursor = track:clip_at_event(event)

	if clip_below_cursor then
		local menu = self:_camera_menu(clip_below_cursor)

		self._panel:popup_menu(menu, Vector3(-1, -1, 0))
	end
end

function CoreCutsceneSequencerPanel:_camera_menu(clip)
	local metadata = clip:metadata()

	if metadata and metadata:footage() then
		local menu = EWS:Menu("")

		for _, camera_name in ipairs(metadata:footage():camera_names()) do
			menu:append_radio_item(camera_name, camera_name, "Use camera \"" .. camera_name .. "\" during this clip")

			if camera_name == metadata:camera() then
				menu:set_checked(camera_name, true)
			end
		end

		menu:connect("", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_set_camera_for_film_clip"), clip)

		return menu
	end

	local menu = EWS:Menu("")

	menu:append_item("NO_CAMERAS", "No Cameras", "")
	menu:set_enabled("NO_CAMERAS", false)

	return menu
end

function CoreCutsceneSequencerPanel:_on_set_camera_for_film_clip(clip, event)
	if clip and clip:metadata() then
		clip:metadata():set_camera(event:get_id())
		clip:set_icon_bitmap(clip:metadata():camera_icon_image())
		clip:set_watermark(clip:metadata():camera_watermark())
		self:_evaluate_frame_at_playhead()
	end
end

function CoreCutsceneSequencerPanel:_connect_mouse_events(component)
	component:connect("EVT_LEFT_DOWN", callback(self, self, "_on_mouse_left_down"), component)
	component:connect("EVT_RIGHT_UP", callback(self, self, "_on_mouse_right_up"), component)
	component:connect("EVT_MOUSEWHEEL", callback(self, self, "_on_mousewheel"), component)
	self:connect("EVT_SYSTEM_WIDE_MOTION", callback(self, self, "_on_mouse_motion"), component)
	self:connect("EVT_SYSTEM_WIDE_LEFT_UP", callback(self, self, "_on_mouse_left_up"), component)
end

function CoreCutsceneSequencerPanel:_propagate_event_to_all_components(behaviour_func_name, sender, event)
	local behaviour = self._track_behaviour
	local callback_func = behaviour[behaviour_func_name]

	if callback_func then
		callback_func(behaviour, sender, self._ruler, event)
		callback_func(behaviour, sender, self:audio_track(), event)
		callback_func(behaviour, sender, self:key_track(), event)

		for _, track in ipairs(self:film_tracks()) do
			callback_func(behaviour, sender, track, event)
		end
	else
		event:skip()
	end
end

function CoreCutsceneSequencerPanel:_on_mouse_left_down(sender, event)
	self._previous_mouse_event = EWS:MouseEvent("EVT_LEFT_DOWN")

	if sender ~= self._ruler and sender ~= self:audio_track() and sender ~= self:key_track() then
		self:set_active_film_track(sender)
	end

	self:_propagate_event_to_all_components("on_mouse_left_down", sender, event)
end

function CoreCutsceneSequencerPanel:_on_mouse_left_up(sender, event)
	self:_propagate_event_to_all_components("on_mouse_left_up", self:track_at_screen_position(event:get_position_on_screen()) or sender, event)
end

function CoreCutsceneSequencerPanel:_on_mouse_motion(sender, event)
	self:_propagate_event_to_all_components("on_mouse_motion", self:track_at_screen_position(event:get_position_on_screen()) or sender, event)
end

function CoreCutsceneSequencerPanel:_on_mouse_right_up(sender, event)
	if sender == self._ruler then
		return
	elseif sender == self:audio_track() then
		return
	elseif sender == self:key_track() then
		return
	else
		self:_show_film_track_context_menu(sender, event)
	end
end

function CoreCutsceneSequencerPanel:_on_mousewheel(track, event)
	self:_send_event("EVT_TRACK_MOUSEWHEEL", event, track)
end

function CoreCutsceneSequencerPanel:_on_start_box_selection(event)
	for _, selection_box in ipairs(self._box_selection_ornaments) do
		local cursor_position = event:get_position_on_screen()

		selection_box:set_start_point(cursor_position)
		selection_box:set_end_point(cursor_position)
		selection_box:set_visible(true)
	end
end

function CoreCutsceneSequencerPanel:_on_drag_box_selection(event)
	local all_clips_within_box = {}

	for _, selection_box in ipairs(self._box_selection_ornaments) do
		selection_box:set_end_point(event:get_position_on_screen())

		all_clips_within_box = table.list_add(all_clips_within_box, selection_box:clips_within_box())
	end

	for _, clip in ipairs(self._all_clips_within_box_at_last_update or {}) do
		clip:set_selected(false)
	end

	for _, clip in ipairs(all_clips_within_box) do
		clip:set_selected(true)
	end

	self._all_clips_within_box_at_last_update = all_clips_within_box
end

function CoreCutsceneSequencerPanel:_on_commit_box_selection(event)
	for _, selection_box in ipairs(self._box_selection_ornaments) do
		selection_box:set_visible(false)
	end

	self._all_clips_within_box_at_last_update = nil

	self:_send_event("EVT_SELECTION_CHANGED")
end

function CoreCutsceneSequencerPanel:_on_scrolled_area_paint(data, event)
	local x_offset = self._scrolled_area:calc_scrolled_position(Vector3(0, 0, 0)).x

	self._ruler:set_offset_pixels(x_offset)
	event:skip()
end

function CoreCutsceneSequencerPanel:change_track_behaviour(new_behaviour)
	self._track_behaviour = new_behaviour
end
