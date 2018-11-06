TrackBehaviour = TrackBehaviour or class()
EditableTrackBehaviour = EditableTrackBehaviour or class(TrackBehaviour)
ClipDragTrackBehaviour = ClipDragTrackBehaviour or class(TrackBehaviour)
MovePlayheadTrackBehaviour = MovePlayheadTrackBehaviour or class(TrackBehaviour)
BoxSelectionTrackBehaviour = BoxSelectionTrackBehaviour or class(TrackBehaviour)

function TrackBehaviour:init()
	self._default_behaviour = self
end

function TrackBehaviour:set_delegate(track_behaviour_delegate)
	self._delegate = track_behaviour_delegate

	return self
end

function TrackBehaviour:set_default_behaviour(behaviour)
	self._default_behaviour = behaviour

	return self
end

function TrackBehaviour:populate_from(behaviour)
	self._default_behaviour = behaviour._default_behaviour
	self._delegate = behaviour._delegate

	return self
end

function TrackBehaviour:change_behaviour(new_behaviour)
	self:_invoke_on_delegate("change_track_behaviour", new_behaviour:populate_from(self))

	return self
end

function TrackBehaviour:restore_default_behaviour()
	self:change_behaviour(self._default_behaviour)

	return self
end

function TrackBehaviour:_delegate_supports(method_name)
	return self._delegate and type(self._delegate[method_name]) == "function"
end

function TrackBehaviour:_invoke_on_delegate(method_name, ...)
	if self._delegate == nil then
		error("Failed to call required delegate method \"" .. method_name .. "\" - no delegate object has been assigned")
	else
		local func = self._delegate[method_name]

		if type(func) == "function" then
			return func(self._delegate, ...)
		else
			error("Failed to call required delegate method \"" .. method_name .. "\" - method not defined")
		end
	end
end

EditableTrackBehaviour.CLIP_EDGE_HANDLE_WIDTH = 6

function EditableTrackBehaviour:init()
	self.super.init(self)
end

function EditableTrackBehaviour:on_mouse_motion(sender, track, event)
	if sender.clips and sender == track then
		local clip_below_cursor = sender:clip_at_event(event)

		if clip_below_cursor then
			local drag_mode = self:_drag_mode(clip_below_cursor, event:get_position(sender))

			if drag_mode == "LEFT_EDGE" or drag_mode == "RIGHT_EDGE" then
				return EWS:set_cursor("SIZEWE")
			end
		end

		EWS:set_cursor(nil)
	end
end

function EditableTrackBehaviour:on_mouse_left_down(sender, track, event)
	if not sender.clips then
		self:change_behaviour(MovePlayheadTrackBehaviour:new())
	elseif sender == track then
		local item_below_cursor = sender:clip_at_event(event)

		if item_below_cursor then
			if item_below_cursor:selected() then
				if event:control_down() then
					self:_set_item_selected(item_below_cursor, false)
				end
			else
				if not event:control_down() then
					self:_invoke_on_delegate("deselect_all_items")
				end

				self:_set_item_selected(item_below_cursor, true)
			end

			if item_below_cursor:selected() then
				local drag_mode = self:_drag_mode(item_below_cursor, event:get_position(sender))

				if self:_delegate_supports("_signal_drag") then
					self:_invoke_on_delegate("_signal_drag", item_below_cursor, drag_mode)
				end

				self:change_behaviour(ClipDragTrackBehaviour:new(item_below_cursor, event:get_position(sender), drag_mode))
			end
		else
			if not event:control_down() then
				self:_invoke_on_delegate("deselect_all_items")
			end

			self:_invoke_on_delegate("_on_start_box_selection", event)
			self:change_behaviour(BoxSelectionTrackBehaviour:new())
		end
	end

	event:skip()
end

function EditableTrackBehaviour:_set_item_selected(item, selected)
	if self:_delegate_supports("set_item_selected") then
		self:_invoke_on_delegate("set_item_selected", item, selected)
	else
		item:set_selected(selected)
	end
end

function EditableTrackBehaviour:_drag_mode(clip, position)
	if clip:point_is_near_edge(position, "LEFT_EDGE", -EditableTrackBehaviour.CLIP_EDGE_HANDLE_WIDTH) then
		return "LEFT_EDGE"
	elseif clip:point_is_near_edge(position, "RIGHT_EDGE", -EditableTrackBehaviour.CLIP_EDGE_HANDLE_WIDTH) then
		return "RIGHT_EDGE"
	else
		return "CLIP"
	end
end

ClipDragTrackBehaviour.SNAP_RADIUS = 10

function ClipDragTrackBehaviour:init(clip, drag_start, mode)
	self.super.init(self)

	self._clip = clip
	self._clip_initial_start_time = self._clip:start_time()
	self._clip_initial_end_time = self._clip:end_time()
	self._mode = mode or "CLIP"
	self._drag_start = drag_start
	self._previous_mouse_position = self._drag_start
	self._snapped_edge = "LEFT"

	if self._mode == "RIGHT_EDGE" then
		self._snapped_edge = "RIGHT"
	end
end

function ClipDragTrackBehaviour:on_mouse_motion(sender, track, event)
	self:_determine_snapped_edge(event:get_position(sender))

	local time_displacement = self:_time_displacement(sender, event)

	for _, clip in ipairs(track.selected_clips and track:selected_clips() or {}) do
		clip:drag(time_displacement, self._mode)

		local metadata = clip:metadata()

		if metadata and metadata.on_gui_representation_changed then
			metadata:on_gui_representation_changed(sender, clip)
		end
	end

	if sender == track and self:_delegate_supports("_signal_drag") then
		self:_invoke_on_delegate("_signal_drag", self._clip, self._mode)
	end

	self._previous_mouse_position = event:get_position(sender)

	event:skip()
end

function ClipDragTrackBehaviour:on_mouse_left_up(sender, track, event)
	for _, clip in ipairs(track.selected_clips and track:selected_clips() or {}) do
		clip:drag_commit()
	end

	self:restore_default_behaviour()
	event:skip()
end

function ClipDragTrackBehaviour:_determine_snapped_edge(position)
	if self._mode == "CLIP" then
		local drag_delta_x = position.x - self._previous_mouse_position.x

		if drag_delta_x > 0 then
			self._snapped_edge = "RIGHT"
		elseif drag_delta_x < 0 then
			self._snapped_edge = "LEFT"
		end
	end
end

function ClipDragTrackBehaviour:_time_displacement(track, event)
	local time_displacement = track:pixels_to_units(event:get_position(track).x - self._drag_start.x)

	if event:shift_down() then
		return time_displacement
	else
		local playhead_position = self:_delegate_supports("playhead_position") and self:_invoke_on_delegate("playhead_position") or nil
		local snapped_to_grid = self:_snap_to_grid(track, time_displacement)
		local snapped_to_clips = self:_snap_to_clips(track, time_displacement) or snapped_to_grid
		local snapped_to_playhead = playhead_position and self:_snap_to_time(playhead_position) or snapped_to_clips
		local unsnapped_time = self._drag_start.x + time_displacement
		local snap_radius = track:pixels_to_units(ClipDragTrackBehaviour.SNAP_RADIUS)

		if math.abs(self._drag_start.x + snapped_to_playhead - unsnapped_time) < snap_radius then
			return snapped_to_playhead
		elseif math.abs(self._drag_start.x + snapped_to_clips - unsnapped_time) < snap_radius then
			return snapped_to_clips
		elseif math.abs(self._drag_start.x + snapped_to_grid - unsnapped_time) < snap_radius then
			return snapped_to_grid
		else
			return time_displacement
		end
	end
end

function ClipDragTrackBehaviour:_snap_to_time(time)
	return time - self:_dragged_clip_edge_time()
end

function ClipDragTrackBehaviour:_snap_to_grid(track, time_displacement)
	local unsnapped_time = self:_dragged_clip_edge_time() + time_displacement

	return self:_snap_to_time(self:_closest_grid_line_time(unsnapped_time))
end

function ClipDragTrackBehaviour:_closest_grid_line_time(time)
	return math.max(0, math.round(time, 100))
end

function ClipDragTrackBehaviour:_dragged_clip_edge_time()
	if self._snapped_edge == "LEFT" then
		return self._clip_initial_start_time
	elseif self._snapped_edge == "RIGHT" then
		return self._clip_initial_end_time
	end
end

function ClipDragTrackBehaviour:_snap_to_clips(track, time_displacement)
	if not track.clips then
		return nil
	end

	local closest_snapped_displacement = nil

	local function update_closest_snapped_displacement(initial_time, displacement, clip_edge)
		local unsnapped_time = initial_time + displacement
		local snapped_displacement = clip_edge - initial_time

		if closest_snapped_displacement == nil then
			closest_snapped_displacement = snapped_displacement
		else
			local snapped_time = initial_time + snapped_displacement
			local snapped_displacement_diff = math.abs(snapped_time - unsnapped_time)
			local closest_snapped_time = initial_time + closest_snapped_displacement
			local closest_snapped_displacement_diff = math.abs(closest_snapped_time - unsnapped_time)

			if snapped_displacement_diff < closest_snapped_displacement_diff then
				closest_snapped_displacement = snapped_displacement
			end
		end
	end

	for _, clip in ipairs(track:clips()) do
		if not clip:selected() then
			if self._snapped_edge == "LEFT" then
				update_closest_snapped_displacement(self._clip_initial_start_time, time_displacement, clip:end_time())
			elseif self._snapped_edge == "RIGHT" then
				update_closest_snapped_displacement(self._clip_initial_end_time, time_displacement, clip:start_time())
			end
		end
	end

	return closest_snapped_displacement
end

function MovePlayheadTrackBehaviour:on_mouse_motion(sender, track, event)
	if sender == track then
		local pos = event:get_position()
		local time = sender:pixels_to_units(event:get_position(sender).x)

		self:_invoke_on_delegate("set_playhead_position", time)
	end

	event:skip()
end

function MovePlayheadTrackBehaviour:on_mouse_left_up(sender, track, event)
	if sender == track then
		self:on_mouse_motion(sender, track, event)
		self:restore_default_behaviour()
	end
end

function BoxSelectionTrackBehaviour:on_mouse_motion(sender, track, event)
	if sender == track then
		self:_invoke_on_delegate("_on_drag_box_selection", event)
	end

	event:skip()
end

function BoxSelectionTrackBehaviour:on_mouse_left_up(sender, track, event)
	if sender == track then
		self:on_mouse_motion(sender, track, event)
		self:_invoke_on_delegate("_on_commit_box_selection", event)
		self:restore_default_behaviour()
	end
end
