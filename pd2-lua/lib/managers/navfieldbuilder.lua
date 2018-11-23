NavFieldBuilder = NavFieldBuilder or class()
NavFieldBuilder._VERSION = 5

function NavFieldBuilder:init()
	self._door_access_types = {
		walk = 1
	}
	self._opposite_side_str = {
		x_neg = "x_pos",
		y_pos = "y_neg",
		y_neg = "y_pos",
		x_pos = "x_neg"
	}
	self._perp_pos_dir_str_map = {
		x_neg = "y_pos",
		y_pos = "x_pos",
		y_neg = "x_pos",
		x_pos = "y_pos"
	}
	self._perp_neg_dir_str_map = {
		x_neg = "y_neg",
		y_pos = "x_neg",
		y_neg = "x_neg",
		x_pos = "y_neg"
	}
	self._dim_str_map = {
		x_neg = "x",
		y_pos = "y",
		y_neg = "y",
		x_pos = "x"
	}
	self._perp_dim_str_map = {
		x_neg = "y",
		y_pos = "x",
		y_neg = "x",
		x_pos = "y"
	}
	self._neg_dir_str_map = {
		x_neg = true,
		y_neg = true
	}
	self._x_dir_str_map = {
		x_neg = true,
		x_pos = true
	}
	self._dir_str_to_vec = {
		x_pos = Vector3(1, 0, 0),
		x_neg = Vector3(-1, 0, 0),
		y_pos = Vector3(0, 1, 0),
		y_neg = Vector3(0, -1, 0)
	}
	self._ground_padding = 35
	self._wall_padding = 24
	self._max_nr_rooms = 20000
	self._room_height = 70
	self._grid_size = 25
	self._air_ray_rad = self._grid_size * 1.2
	self._gnd_ray_rad = self._grid_size * 0.9
	self._room_dimention_max = 1000
	self._raycast_dis_max = 10000
	self._max_fall = 800
	self._up_vec = Vector3(0, 0, self._ground_padding + self._grid_size)
	self._down_vec = Vector3(0, 0, -self._max_fall)
	self._slotmask = managers.slot:get_mask("AI_graph_obstacle_check")
	self._rooms = {}
	self._room_doors = {}
	self._visibility_groups = {}
	self._nav_segments = {}
	self._geog_segments = {}
	self._geog_segment_size = 500
	self._nr_geog_segments = nil
	self._geog_segment_offset = nil
end

function NavFieldBuilder:clear()
	self._geog_segments = {}
	self._nr_geog_segments = nil
	self._geog_segment_offset = nil
	self._rooms = {}
	self._room_doors = {}
	self._visibility_groups = {}
	self._nav_segments = {}
	self._building = nil
	self._progress_dialog_cancel = nil

	self:_reenable_all_blockers()

	self._helper_blockers = nil
	self._new_blockers = nil
end

function NavFieldBuilder:update(t, dt)
	if self._building then
		if self._progress_dialog_cancel then
			self._progress_dialog_cancel = nil

			self:clear()
			self:_destroy_progress_bar()

			self._building = nil
		else
			self._building.task_clbk(self)
		end
	end
end

function NavFieldBuilder:_create_build_progress_bar(title, num_divistions)
	if not self._progress_dialog then
		self._progress_dialog = EWS:ProgressDialog(Global.frame_panel, title, "", num_divistions, "PD_AUTO_HIDE,PD_SMOOTH,PD_CAN_ABORT,PD_ELAPSED_TIME,PD_ESTIMATED_TIME,PD_REMAINING_TIME")

		self._progress_dialog:set_focus()
		self._progress_dialog:update()
	end
end

function NavFieldBuilder:_destroy_progress_bar()
	if self._progress_dialog then
		self._progress_dialog:destroy()

		self._progress_dialog = nil
	end
end

function NavFieldBuilder:set_field_data(data)
	for i, k in pairs(data) do
		self[i] = k
	end
end

function NavFieldBuilder:set_segment_state(id, state)
	self._nav_segments[id].no_access = not state and true or nil
end

function NavFieldBuilder:build_nav_segments(build_settings, complete_clbk)
	self._build_complete_clbk = complete_clbk
	local all_vis_groups = self._visibility_groups

	for i_room, room in ipairs(self._rooms) do
		if not room.segment then
			room.segment = all_vis_groups[room.vis_group].seg
		end
	end

	for index, segment_settings in ipairs(build_settings) do
		self:delete_segment(segment_settings.id)
	end

	self._nr_geog_segments = nil

	self:start_build_nav_segment(build_settings, 1)
end

function NavFieldBuilder:build_visibility_graph(complete_clbk, all_visible, ray_dis, pos_filter, neg_filter)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-6, warpins: 1 ---
	local all_rooms = self._rooms
	local all_vis_groups = self._visibility_groups

	--- END OF BLOCK #0 ---

	FLOW; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #1 7-9, warpins: 1 ---
	if not room.segment then

		-- Decompilation error in this vicinity:
		--- BLOCK #2 10-13, warpins: 1 ---
		room.segment = all_vis_groups[room.vis_group].seg
		--- END OF BLOCK #2 ---



	end

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #2 10-13, warpins: 1 ---
	room.segment = all_vis_groups[room.vis_group].seg
	--- END OF BLOCK #2 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #3 14-15, warpins: 2 ---
	room.vis_group = nil
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 16-17, warpins: 2 ---
	--- END OF BLOCK #4 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #5 18-22, warpins: 1 ---
	self._visibility_groups = {}
	local all_vis_groups = self._visibility_groups
	--- END OF BLOCK #5 ---

	slot2 = if all_visible then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 23-28, warpins: 1 ---
	local seg_to_vis_group_map = {}
	local nr_vis_groups = 0
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 29-46, warpins: 1 ---
	local new_vis_group = {}
	new_vis_group.rooms = {}
	new_vis_group.pos = nav_seg.pos
	new_vis_group.vis_groups = {}
	new_vis_group.seg = nav_seg_id

	table.insert(all_vis_groups, new_vis_group)

	nr_vis_groups = nr_vis_groups + 1
	seg_to_vis_group_map[nav_seg_id] = nr_vis_groups
	nav_seg.vis_groups = {
		nr_vis_groups
	}
	--- END OF BLOCK #7 ---

	FLOW; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #8 47-48, warpins: 2 ---
	--- END OF BLOCK #8 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #9 49-51, warpins: 1 ---
	--- END OF BLOCK #9 ---

	if nr_vis_groups > 1 then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 52-55, warpins: 1 ---
	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #11 56-57, warpins: 1 ---
	local visible_groups = vis_group.vis_groups
	local i = 1
	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 58-58, warpins: 2 ---
	--- END OF BLOCK #12 ---

	FLOW; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #13 59-60, warpins: 1 ---
	--- END OF BLOCK #13 ---

	if i ~= i_vis_group then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 61-62, warpins: 1 ---
	visible_groups[i] = true
	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 63-65, warpins: 2 ---
	i = i + 1
	--- END OF BLOCK #15 ---

	if nr_vis_groups < i then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 66-67, warpins: 2 ---
	--- END OF BLOCK #16 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #17 68-71, warpins: 2 ---
	--- END OF BLOCK #17 ---

	FLOW; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #18 72-78, warpins: 1 ---
	local i_vis_group = seg_to_vis_group_map[room.segment]
	room.vis_group = i_vis_group
	all_vis_groups[i_vis_group].rooms[i_room] = true

	--- END OF BLOCK #18 ---

	FLOW; TARGET BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #19 79-80, warpins: 2 ---
	--- END OF BLOCK #19 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #20 81-92, warpins: 1 ---
	self:_generate_geographic_segments()
	self:_generate_coarse_navigation_graph()
	self:_cleanup_room_data_1()
	complete_clbk()

	return

	--- END OF BLOCK #20 ---

	FLOW; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #21 93-115, warpins: 2 ---
	self._build_complete_clbk = complete_clbk
	self._room_visibility_data = {}

	self:_create_build_progress_bar("Building Visibility Graph", 5)

	self._building = {}
	self._building.task_clbk = self._commence_vis_graph_build
	self._building.pos_vis_filter = pos_filter
	self._building.neg_vis_filter = neg_filter
	self._building.ray_dis = ray_dis
	local nr_rooms = #self._rooms
	--- END OF BLOCK #21 ---

	if nr_rooms == 1 then
	JUMP TO BLOCK #22
	else
	JUMP TO BLOCK #23
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #22 116-122, warpins: 1 ---
	self._building.stage = 2
	self._room_visibility_data[1] = {}
	--- END OF BLOCK #22 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #23 123-136, warpins: 1 ---
	local i_room_a = 1
	local i_room_b = 2
	local room_a = all_rooms[i_room_a]
	local room_b = all_rooms[i_room_b]
	self._building.stage = 1
	self._building.current_i_room_a = i_room_a
	self._building.current_i_room_b = i_room_b
	self._building.new_pair = true
	--- END OF BLOCK #23 ---

	FLOW; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #26 143-144, warpins: 2 ---
	self._building.stage = self._building.stage or 2

	return
	--- END OF BLOCK #26 ---



end

function NavFieldBuilder:_chk_room_vis_filter(room_a, room_b, pos_filter, neg_filter)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local seg_low, seg_high = math.min_max(room_a.segment, room_b.segment)

	--- END OF BLOCK #0 ---

	if seg_low ~= seg_high then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 8-10, warpins: 1 ---
	--- END OF BLOCK #1 ---

	slot7 = if pos_filter[seg_low] then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 11-14, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot7 = if pos_filter[seg_low][seg_high] then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 15-17, warpins: 2 ---
	return true
	--- END OF BLOCK #3 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #4 18-20, warpins: 2 ---
	--- END OF BLOCK #4 ---

	slot7 = if neg_filter[seg_low] then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 21-24, warpins: 1 ---
	--- END OF BLOCK #5 ---

	slot7 = if neg_filter[seg_low][seg_high] then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 25-26, warpins: 1 ---
	return false
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 27-28, warpins: 4 ---
	return nil
	--- END OF BLOCK #7 ---



end

function NavFieldBuilder:delete_segment(id)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-5, warpins: 1 ---
	local all_vis_groups = self._visibility_groups
	local all_rooms = self._rooms
	local all_blockers = self._helper_blockers
	local i_room = #self._rooms
	--- END OF BLOCK #0 ---

	FLOW; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #1 6-8, warpins: 2 ---
	--- END OF BLOCK #1 ---

	if i_room > 0 then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 9-9, warpins: 1 ---
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 10-13, warpins: 1 ---
	local room = all_rooms[i_room]

	--- END OF BLOCK #3 ---

	slot7 = if room.segment then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 14-16, warpins: 1 ---
	--- END OF BLOCK #4 ---

	if room.segment == id then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 17-25, warpins: 1 ---
	self:_trash_room(i_room)
	self:_destroy_room(i_room)
	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #6 26-30, warpins: 1 ---
	--- END OF BLOCK #6 ---

	if all_vis_groups[room.vis_group].seg == id then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 31-38, warpins: 1 ---
	self:_trash_room(i_room)
	self:_destroy_room(i_room)

	--- END OF BLOCK #7 ---

	FLOW; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #8 39-40, warpins: 4 ---
	i_room = i_room - 1
	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #9 41-44, warpins: 1 ---
	local all_nav_segments = self._nav_segments
	local seg = all_nav_segments[id]

	--- END OF BLOCK #9 ---

	slot7 = if not seg then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 45-45, warpins: 1 ---
	return

	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 46-51, warpins: 2 ---
	all_nav_segments[id] = nil

	--- END OF BLOCK #11 ---

	for test_seg_id, test_seg in pairs(all_nav_segments)


	LOOP BLOCK #12
	GO OUT TO BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #12 52-54, warpins: 1 ---
	test_seg.neighbours[id] = nil
	--- END OF BLOCK #12 ---

	FLOW; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #13 55-56, warpins: 2 ---
	--- END OF BLOCK #13 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #14 57-58, warpins: 1 ---
	local owned_vis_groups = seg.vis_groups
	local index_owned_vis_group = #owned_vis_groups
	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 59-61, warpins: 3 ---
	--- END OF BLOCK #15 ---

	if index_owned_vis_group > 0 then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 62-62, warpins: 1 ---
	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 63-75, warpins: 1 ---
	local i_owned_vis_group = owned_vis_groups[index_owned_vis_group]

	print("removing vis group", i_owned_vis_group, "at index", index_owned_vis_group)
	self:_destroy_vis_group(i_owned_vis_group)

	index_owned_vis_group = index_owned_vis_group - 1
	local i = index_owned_vis_group

	--- END OF BLOCK #17 ---

	FLOW; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #18 76-78, warpins: 2 ---
	--- END OF BLOCK #18 ---

	if i > 0 then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 79-79, warpins: 1 ---
	--- END OF BLOCK #19 ---

	FLOW; TARGET BLOCK #20



	-- Decompilation error in this vicinity:
	--- BLOCK #20 80-82, warpins: 1 ---
	--- END OF BLOCK #20 ---

	if i_owned_vis_group < owned_vis_groups[i] then
	JUMP TO BLOCK #21
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #21 83-91, warpins: 1 ---
	print("adjusting trash vis_group", owned_vis_groups[i], "at", i)

	owned_vis_groups[i] = owned_vis_groups[i] - 1
	--- END OF BLOCK #21 ---

	FLOW; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #22 92-93, warpins: 2 ---
	i = i - 1

	--- END OF BLOCK #22 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #23 94-94, warpins: 0 ---
	--- END OF BLOCK #23 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #24 95-97, warpins: 1 ---
	--- END OF BLOCK #24 ---

	slot10 = if self._helper_blockers then
	JUMP TO BLOCK #25
	else
	JUMP TO BLOCK #29
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #25 98-101, warpins: 1 ---
	--- END OF BLOCK #25 ---

	for u_id, segment in pairs(all_blockers)


	LOOP BLOCK #26
	GO OUT TO BLOCK #29



	-- Decompilation error in this vicinity:
	--- BLOCK #26 102-103, warpins: 1 ---
	--- END OF BLOCK #26 ---

	if segment == id then
	JUMP TO BLOCK #27
	else
	JUMP TO BLOCK #28
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #27 104-105, warpins: 1 ---
	all_blockers[u_id] = nil

	--- END OF BLOCK #27 ---

	FLOW; TARGET BLOCK #28



	-- Decompilation error in this vicinity:
	--- BLOCK #28 106-107, warpins: 3 ---
	--- END OF BLOCK #28 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #25



	-- Decompilation error in this vicinity:
	--- BLOCK #29 108-108, warpins: 2 ---
	return
	--- END OF BLOCK #29 ---



end

function NavFieldBuilder:_destroy_vis_group(i_vis_group)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-12, warpins: 1 ---
	local all_rooms = self._rooms
	local all_nav_segments = self._nav_segments
	local all_vis_groups = self._visibility_groups
	local vis_group = table.remove(all_vis_groups, i_vis_group)

	--- END OF BLOCK #0 ---

	for i_room, room in ipairs(all_rooms)


	LOOP BLOCK #1
	GO OUT TO BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #1 13-15, warpins: 1 ---
	--- END OF BLOCK #1 ---

	slot11 = if room.vis_group then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 16-18, warpins: 1 ---
	--- END OF BLOCK #2 ---

	if i_vis_group < room.vis_group then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 19-21, warpins: 1 ---
	room.vis_group = room.vis_group - 1

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 22-23, warpins: 4 ---
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #5 24-27, warpins: 1 ---
	--- END OF BLOCK #5 ---

	for i_seg, seg in pairs(all_nav_segments)


	LOOP BLOCK #6
	GO OUT TO BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #6 28-32, warpins: 1 ---
	local owned_vis_groups = seg.vis_groups

	--- END OF BLOCK #6 ---

	for index_owned_vis_group, i_owned_vis_group in ipairs(owned_vis_groups)


	LOOP BLOCK #7
	GO OUT TO BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #7 33-34, warpins: 1 ---
	--- END OF BLOCK #7 ---

	if i_vis_group < i_owned_vis_group then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 35-36, warpins: 1 ---
	owned_vis_groups[index_owned_vis_group] = i_owned_vis_group - 1

	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 37-38, warpins: 3 ---
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #10 39-40, warpins: 2 ---
	--- END OF BLOCK #10 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #11 41-44, warpins: 1 ---
	--- END OF BLOCK #11 ---

	for _, test_vis_group in ipairs(all_vis_groups)


	LOOP BLOCK #12
	GO OUT TO BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #12 45-52, warpins: 1 ---
	local visible_vis_groups = test_vis_group.vis_groups
	visible_vis_groups[i_vis_group] = nil
	local new_list = {}

	--- END OF BLOCK #12 ---

	for i_visibile_group, _ in pairs(visible_vis_groups)


	LOOP BLOCK #13
	GO OUT TO BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #13 53-54, warpins: 1 ---
	--- END OF BLOCK #13 ---

	if i_vis_group < i_visibile_group then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 55-58, warpins: 1 ---
	new_list[i_visibile_group - 1] = true
	--- END OF BLOCK #14 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #15 59-60, warpins: 1 ---
	new_list[i_visibile_group] = true
	--- END OF BLOCK #15 ---

	FLOW; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #16 61-62, warpins: 3 ---
	--- END OF BLOCK #16 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #17 63-63, warpins: 1 ---
	test_vis_group.vis_groups = new_list

	--- END OF BLOCK #17 ---

	FLOW; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #18 64-65, warpins: 2 ---
	--- END OF BLOCK #18 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #19 66-66, warpins: 1 ---
	return
	--- END OF BLOCK #19 ---



end

function NavFieldBuilder:start_build_nav_segment(build_settings, segment_index)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-26, warpins: 1 ---
	self:_create_build_progress_bar("Building Navigation Segments", 6)

	local build_seg = build_settings[segment_index]
	self._building = {}
	self._building.build_settings = build_settings
	self._building.segment_index = segment_index
	self._building.task_clbk = self._commence_nav_field_build
	self._building.stage = 1
	local nav_segment_id = build_seg.id
	self._building.id = nav_segment_id
	self._new_blockers = {}
	--- END OF BLOCK #0 ---

	slot5 = if not self._helper_blockers then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 27-27, warpins: 1 ---
	slot5 = {}
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 28-31, warpins: 2 ---
	self._helper_blockers = slot5
	--- END OF BLOCK #2 ---

	slot5 = if not self._disabled_blockers then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 32-32, warpins: 1 ---
	slot5 = {}
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 33-57, warpins: 2 ---
	self._disabled_blockers = slot5
	self._nav_segments[nav_segment_id] = {
		build_seg.strategic_area_id,
		pos = build_seg.position,
		vis_groups = {},
		neighbours = {},
		location_id = build_seg.location_id
	}
	local all_blockers = World:find_units_quick("all", 15)
	local to_remove = {}

	--- END OF BLOCK #4 ---

	for u_id, segment in pairs(self._helper_blockers)


	LOOP BLOCK #5
	GO OUT TO BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #5 58-60, warpins: 1 ---
	local verified = nil

	--- END OF BLOCK #5 ---

	if segment ~= nav_segment_id then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 61-64, warpins: 1 ---
	--- END OF BLOCK #6 ---

	for _, blocker_unit in ipairs(all_blockers)


	LOOP BLOCK #7
	GO OUT TO BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #7 65-70, warpins: 1 ---
	local u_id_ = blocker_unit:unit_data().unit_id
	--- END OF BLOCK #7 ---

	if u_id_ == u_id then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 71-72, warpins: 1 ---
	verified = true

	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #9 73-74, warpins: 2 ---
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #10 75-76, warpins: 3 ---
	--- END OF BLOCK #10 ---

	slot12 = if not verified then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 77-81, warpins: 1 ---
	table.insert(to_remove, u_id)
	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 82-83, warpins: 3 ---
	--- END OF BLOCK #12 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #13 84-87, warpins: 1 ---
	--- END OF BLOCK #13 ---

	for _, u_id in ipairs(to_remove)


	LOOP BLOCK #14
	GO OUT TO BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #14 88-90, warpins: 1 ---
	self._helper_blockers[u_id] = nil

	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 91-92, warpins: 2 ---
	--- END OF BLOCK #15 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #16 93-96, warpins: 1 ---
	--- END OF BLOCK #16 ---

	for _, blocker_unit in ipairs(all_blockers)


	LOOP BLOCK #17
	GO OUT TO BLOCK #20



	-- Decompilation error in this vicinity:
	--- BLOCK #17 97-104, warpins: 1 ---
	local u_id = blocker_unit:unit_data().unit_id
	local blocker_segment = self._helper_blockers[u_id]

	--- END OF BLOCK #17 ---

	slot13 = if blocker_segment then
	JUMP TO BLOCK #18
	else
	JUMP TO BLOCK #19
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #18 105-108, warpins: 1 ---
	self:_disable_blocker(blocker_unit)

	--- END OF BLOCK #18 ---

	FLOW; TARGET BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #19 109-110, warpins: 3 ---
	--- END OF BLOCK #19 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #20 111-140, warpins: 1 ---
	local start_pos_rounded = self:_round_pos_to_grid_center(build_seg.position) + Vector3(self._grid_size * 0.5, self._grid_size * 0.5, 0)
	local ground_ray = self:_sphere_ray(start_pos_rounded + self._up_vec, start_pos_rounded + self._down_vec, self._gnd_ray_rad)

	self:_analyse_room("x_pos", start_pos_rounded:with_z(ground_ray.position.z))

	return
	--- END OF BLOCK #20 ---



end

function NavFieldBuilder:_commence_nav_field_build()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	if self._building.stage == 1 then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-8, warpins: 1 ---
	self:_expand_rooms()

	--- END OF BLOCK #1 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #2 9-12, warpins: 1 ---
	--- END OF BLOCK #2 ---

	if self._building.stage == 2 then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 13-16, warpins: 1 ---
	--- END OF BLOCK #3 ---

	slot1 = if not self._building.sorted_rooms then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 17-25, warpins: 1 ---
	self._building.sorted_rooms = {}
	local build_id = self._building.id

	--- END OF BLOCK #4 ---

	for i_room, room in ipairs(self._rooms)

	LOOP BLOCK #5
	GO OUT TO BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #5 26-28, warpins: 1 ---
	--- END OF BLOCK #5 ---

	if room.segment == build_id then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 29-34, warpins: 1 ---
	self:_sort_room_by_area(i_room, self._building.sorted_rooms)
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 35-36, warpins: 3 ---
	--- END OF BLOCK #7 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #8 37-55, warpins: 2 ---
	self:_update_progress_bar(2, "Merging Room " .. tostring(self._building.sorted_rooms[#self._building.sorted_rooms]))

	local done = self:_merge_rooms()
	--- END OF BLOCK #8 ---

	slot1 = if done then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #26
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 56-59, warpins: 1 ---
	--- END OF BLOCK #9 ---

	slot2 = if not self._building.second_pass then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 60-62, warpins: 1 ---
	self._building.stage = 3
	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 63-69, warpins: 2 ---
	self._building.second_pass = nil
	self._building.sorted_rooms = nil

	--- END OF BLOCK #11 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #12 70-73, warpins: 1 ---
	--- END OF BLOCK #12 ---

	if self._building.stage == 3 then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 74-77, warpins: 1 ---
	--- END OF BLOCK #13 ---

	for i_room, room in ipairs(self._rooms)

	LOOP BLOCK #14
	GO OUT TO BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #14 78-82, warpins: 1 ---
	--- END OF BLOCK #14 ---

	if room.segment == self._building.id then
	JUMP TO BLOCK #15
	else
	JUMP TO BLOCK #16
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #15 83-86, warpins: 1 ---
	self:_create_room_doors(i_room)

	--- END OF BLOCK #15 ---

	FLOW; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #16 87-88, warpins: 3 ---
	--- END OF BLOCK #16 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #17 89-92, warpins: 1 ---
	self._building.stage = 4

	--- END OF BLOCK #17 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #18 93-96, warpins: 1 ---
	--- END OF BLOCK #18 ---

	if self._building.stage == 4 then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #20
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 97-108, warpins: 1 ---
	self:_update_progress_bar(3, "Calculating door heights")
	self:_calculate_door_heights()

	self._building.stage = 5

	--- END OF BLOCK #19 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #20 109-112, warpins: 1 ---
	--- END OF BLOCK #20 ---

	if self._building.stage == 5 then
	JUMP TO BLOCK #21
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #21 113-124, warpins: 1 ---
	self:_update_progress_bar(4, "Cleaning Up room_data")
	self:_cleanup_room_data()

	self._building.stage = 6

	--- END OF BLOCK #21 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #22 125-128, warpins: 1 ---
	--- END OF BLOCK #22 ---

	if self._building.stage == 6 then
	JUMP TO BLOCK #23
	else
	JUMP TO BLOCK #26
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #23 129-144, warpins: 1 ---
	self:_set_new_blockers_used()
	self:_reenable_all_blockers()
	self:_destroy_progress_bar()

	--- END OF BLOCK #23 ---

	if self._building.segment_index == #self._building.build_settings then
	JUMP TO BLOCK #24
	else
	JUMP TO BLOCK #25
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #24 145-149, warpins: 1 ---
	self._building = false

	self._build_complete_clbk()
	--- END OF BLOCK #24 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #25 150-157, warpins: 1 ---
	self:start_build_nav_segment(self._building.build_settings, self._building.segment_index + 1)

	--- END OF BLOCK #25 ---

	FLOW; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #26 158-158, warpins: 9 ---
	return
	--- END OF BLOCK #26 ---



end

function NavFieldBuilder:_expand_rooms()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local progress = nil

	local function can_room_expand(expansion_data)

		-- Decompilation error in this vicinity:
		--- BLOCK #0 1-2, warpins: 1 ---
		--- END OF BLOCK #0 ---

		slot0 = if expansion_data then
		JUMP TO BLOCK #1
		else
		JUMP TO BLOCK #5
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #1 3-6, warpins: 1 ---
		--- END OF BLOCK #1 ---

		for side, seg_list in pairs(expansion_data)

		LOOP BLOCK #2
		GO OUT TO BLOCK #5



		-- Decompilation error in this vicinity:
		--- BLOCK #2 7-11, warpins: 1 ---
		--- END OF BLOCK #2 ---

		slot6 = if next(seg_list)

		 then
		JUMP TO BLOCK #3
		else
		JUMP TO BLOCK #4
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #3 12-13, warpins: 1 ---
		return true
		--- END OF BLOCK #3 ---

		FLOW; TARGET BLOCK #4



		-- Decompilation error in this vicinity:
		--- BLOCK #4 14-15, warpins: 3 ---
		--- END OF BLOCK #4 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #1



		-- Decompilation error in this vicinity:
		--- BLOCK #5 16-16, warpins: 2 ---
		return
		--- END OF BLOCK #5 ---



	end

	local function expand_room(room)

		-- Decompilation error in this vicinity:
		--- BLOCK #0 1-6, warpins: 1 ---
		local expansion_data = room.expansion_segments
		local progress = nil

		--- END OF BLOCK #0 ---

		for dir_str, exp_dir_data in pairs(expansion_data)

		LOOP BLOCK #1
		GO OUT TO BLOCK #15



		-- Decompilation error in this vicinity:
		--- BLOCK #1 7-10, warpins: 1 ---
		--- END OF BLOCK #1 ---

		for i_segment, segment in pairs(exp_dir_data)

		LOOP BLOCK #2
		GO OUT TO BLOCK #12



		-- Decompilation error in this vicinity:
		--- BLOCK #2 11-17, warpins: 1 ---
		--- END OF BLOCK #2 ---

		if self._max_nr_rooms <= #self._rooms then
		JUMP TO BLOCK #3
		else
		JUMP TO BLOCK #4
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #3 18-23, warpins: 1 ---
		print("!\t\tError. Room # limit exceeded")

		exp_dir_data[i_segment] = nil
		--- END OF BLOCK #3 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #12



		-- Decompilation error in this vicinity:
		--- BLOCK #4 24-41, warpins: 1 ---
		local new_enter_pos = Vector3()
		local size_1 = segment[1][self._perp_dim_str_map[dir_str]] + self._grid_size * 0.5
		slot15 = room.borders[dir_str]
		--- END OF BLOCK #4 ---

		slot16 = if self._neg_dir_str_map[dir_str] then
		JUMP TO BLOCK #5
		else
		JUMP TO BLOCK #6
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #5 42-43, warpins: 1 ---
		slot16 = -1
		--- END OF BLOCK #5 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #7



		-- Decompilation error in this vicinity:
		--- BLOCK #6 44-44, warpins: 1 ---
		slot16 = 1
		--- END OF BLOCK #6 ---

		FLOW; TARGET BLOCK #7



		-- Decompilation error in this vicinity:
		--- BLOCK #7 45-89, warpins: 2 ---
		local size_2 = slot15 + slot16 * self._grid_size * 0.5

		mvector3["set_" .. self._perp_dim_str_map[dir_str]](new_enter_pos, size_1)
		mvector3["set_" .. self._dim_str_map[dir_str]](new_enter_pos, size_2)
		mvector3.set_z(new_enter_pos, segment[1].z)

		local gnd_ray = self:_sphere_ray(new_enter_pos + self._up_vec, new_enter_pos + self._down_vec, self._gnd_ray_rad)

		--- END OF BLOCK #7 ---

		slot16 = if gnd_ray then
		JUMP TO BLOCK #8
		else
		JUMP TO BLOCK #9
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #8 90-96, warpins: 1 ---
		mvector3.set_z(new_enter_pos, gnd_ray.position.z)
		--- END OF BLOCK #8 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #10



		-- Decompilation error in this vicinity:
		--- BLOCK #9 97-132, warpins: 1 ---
		Application:error("! Error. NavFieldBuilder:_expand_rooms() ground ray failed! segment", segment[1], segment[2])
		Application:draw_cylinder(new_enter_pos + self._up_vec, new_enter_pos + self._down_vec, self._gnd_ray_rad, 1, 0, 0)
		managers.navigation:_draw_room(room, true)
		Application:set_pause(true)

		progress = false
		--- END OF BLOCK #9 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #12



		-- Decompilation error in this vicinity:
		--- BLOCK #10 133-143, warpins: 1 ---
		local new_i_room = self:_analyse_room(dir_str, new_enter_pos)
		local new_room = self._rooms[new_i_room]
		progress = true

		--- END OF BLOCK #10 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #12



		-- Decompilation error in this vicinity:
		--- BLOCK #11 144-145, warpins: 1 ---
		--- END OF BLOCK #11 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #1



		-- Decompilation error in this vicinity:
		--- BLOCK #12 146-147, warpins: 4 ---
		--- END OF BLOCK #12 ---

		slot2 = if progress then
		JUMP TO BLOCK #13
		else
		JUMP TO BLOCK #14
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #13 148-148, warpins: 1 ---
		--- END OF BLOCK #13 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #15



		-- Decompilation error in this vicinity:
		--- BLOCK #14 149-150, warpins: 2 ---
		--- END OF BLOCK #14 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #0



		-- Decompilation error in this vicinity:
		--- BLOCK #15 151-151, warpins: 2 ---
		return progress
		--- END OF BLOCK #15 ---



	end

	--- END OF BLOCK #0 ---

	for i_room, room in ipairs(self._rooms)


	LOOP BLOCK #1
	GO OUT TO BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #1 8-8, warpins: 1 ---
	local expansion_segments = room.expansion_segments

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 9-10, warpins: 3 ---
	--- END OF BLOCK #2 ---

	slot1 = if not progress then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 11-15, warpins: 1 ---
	--- END OF BLOCK #3 ---

	slot10 = if can_room_expand(expansion_segments)

	 then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 16-16, warpins: 1 ---
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 17-37, warpins: 1 ---
	local text = "expanding room " .. tostring(i_room) .. " of " .. tostring(#self._rooms)

	self:_update_progress_bar(1, text)

	progress = expand_room(room)
	--- END OF BLOCK #5 ---

	slot1 = if progress then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 38-38, warpins: 1 ---
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #7 39-39, warpins: 0 ---
	--- END OF BLOCK #7 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #8 40-41, warpins: 4 ---
	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #9 42-43, warpins: 1 ---
	--- END OF BLOCK #9 ---

	slot1 = if not progress then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 44-49, warpins: 1 ---
	self._building.stage = 2
	self._building.second_pass = true

	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 50-51, warpins: 2 ---
	return
	--- END OF BLOCK #11 ---



end

function NavFieldBuilder:_merge_rooms()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local function _remove_room_from_sorted_list(i_room, sorted_rooms)

		-- Decompilation error in this vicinity:
		--- BLOCK #0 1-4, warpins: 1 ---
		--- END OF BLOCK #0 ---

		for sort_index, sorted_i_room in ipairs(sorted_rooms)

		LOOP BLOCK #1
		GO OUT TO BLOCK #4



		-- Decompilation error in this vicinity:
		--- BLOCK #1 5-6, warpins: 1 ---
		--- END OF BLOCK #1 ---

		if sorted_i_room == i_room then
		JUMP TO BLOCK #2
		else
		JUMP TO BLOCK #3
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #2 7-12, warpins: 1 ---
		table.remove(sorted_rooms, sort_index)

		--- END OF BLOCK #2 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #4



		-- Decompilation error in this vicinity:
		--- BLOCK #3 13-14, warpins: 2 ---
		--- END OF BLOCK #3 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #0



		-- Decompilation error in this vicinity:
		--- BLOCK #4 15-15, warpins: 2 ---
		return
		--- END OF BLOCK #4 ---



	end

	local function _dispose_trash_rooms(trash_rooms, sorted_rooms)

		-- Decompilation error in this vicinity:
		--- BLOCK #0 1-4, warpins: 1 ---
		--- END OF BLOCK #0 ---

		for i, i_room in pairs(trash_rooms)

		LOOP BLOCK #1
		GO OUT TO BLOCK #10



		-- Decompilation error in this vicinity:
		--- BLOCK #1 5-13, warpins: 1 ---
		self:_destroy_room(i_room)
		--- END OF BLOCK #1 ---

		for next_i, next_i_room in pairs(trash_rooms)


		LOOP BLOCK #2
		GO OUT TO BLOCK #5



		-- Decompilation error in this vicinity:
		--- BLOCK #2 14-15, warpins: 1 ---
		--- END OF BLOCK #2 ---

		if i_room < next_i_room then
		JUMP TO BLOCK #3
		else
		JUMP TO BLOCK #4
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #3 16-17, warpins: 1 ---
		trash_rooms[next_i] = next_i_room - 1

		--- END OF BLOCK #3 ---

		FLOW; TARGET BLOCK #4



		-- Decompilation error in this vicinity:
		--- BLOCK #4 18-19, warpins: 3 ---
		--- END OF BLOCK #4 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #1



		-- Decompilation error in this vicinity:
		--- BLOCK #5 20-27, warpins: 1 ---
		_remove_room_from_sorted_list(i_room, sorted_rooms)
		--- END OF BLOCK #5 ---

		for sort_index, room_index in ipairs(sorted_rooms)


		LOOP BLOCK #6
		GO OUT TO BLOCK #9



		-- Decompilation error in this vicinity:
		--- BLOCK #6 28-29, warpins: 1 ---
		--- END OF BLOCK #6 ---

		if i_room < room_index then
		JUMP TO BLOCK #7
		else
		JUMP TO BLOCK #8
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #7 30-31, warpins: 1 ---
		sorted_rooms[sort_index] = room_index - 1

		--- END OF BLOCK #7 ---

		FLOW; TARGET BLOCK #8



		-- Decompilation error in this vicinity:
		--- BLOCK #8 32-33, warpins: 3 ---
		--- END OF BLOCK #8 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #5



		-- Decompilation error in this vicinity:
		--- BLOCK #9 34-35, warpins: 2 ---
		--- END OF BLOCK #9 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #0



		-- Decompilation error in this vicinity:
		--- BLOCK #10 36-36, warpins: 1 ---
		return
		--- END OF BLOCK #10 ---



	end

	local function _find_walls_on_side(room, side)

		-- Decompilation error in this vicinity:
		--- BLOCK #0 1-62, warpins: 1 ---
		local all_doors = self._room_doors
		local borders = room.borders
		local fwd_border = borders[side]
		local along_dim = self._perp_dim_str_map[side]
		local perp_dim = self._dim_str_map[side]
		local left_corner = Vector3()
		local right_corner = Vector3()

		mvector3["set_" .. along_dim](left_corner, borders[self._perp_neg_dir_str_map[side]])
		mvector3["set_" .. perp_dim](left_corner, fwd_border)
		mvector3["set_" .. along_dim](right_corner, borders[self._perp_pos_dir_str_map[side]])
		mvector3["set_" .. perp_dim](right_corner, fwd_border)

		local walls = {}
		walls[1] = {
			left_corner,
			right_corner
		}

		--- END OF BLOCK #0 ---

		for _, neighbour_data in ipairs(room.neighbours[side])


		LOOP BLOCK #1
		GO OUT TO BLOCK #3



		-- Decompilation error in this vicinity:
		--- BLOCK #1 63-70, warpins: 1 ---
		walls = self:_remove_seg_from_seg_list(walls, neighbour_data.overlap, along_dim)

		--- END OF BLOCK #1 ---

		FLOW; TARGET BLOCK #2



		-- Decompilation error in this vicinity:
		--- BLOCK #2 71-72, warpins: 2 ---
		--- END OF BLOCK #2 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #0



		-- Decompilation error in this vicinity:
		--- BLOCK #3 73-73, warpins: 1 ---
		return walls
		--- END OF BLOCK #3 ---



	end

	local function _get_room_expandable_borders(room)

		-- Decompilation error in this vicinity:
		--- BLOCK #0 1-6, warpins: 1 ---
		local expandable_sides = {}
		local neighbours = room.neighbours

		--- END OF BLOCK #0 ---

		for side, obstacle_types in pairs(room.expansion)


		LOOP BLOCK #1
		GO OUT TO BLOCK #17



		-- Decompilation error in this vicinity:
		--- BLOCK #1 7-20, warpins: 1 ---
		local opp_side = self._opposite_side_str[side]
		local dim = self._perp_dim_str_map[side]

		--- END OF BLOCK #1 ---

		slot10 = if not next(_find_walls_on_side(room, side))

		 then
		JUMP TO BLOCK #2
		else
		JUMP TO BLOCK #16
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #2 21-26, warpins: 1 ---
		local exp_seg = {}
		local neighbour_block = nil

		--- END OF BLOCK #2 ---

		for _, neighbour_data in pairs(neighbours[side])


		LOOP BLOCK #3
		GO OUT TO BLOCK #11



		-- Decompilation error in this vicinity:
		--- BLOCK #3 27-33, warpins: 1 ---
		local neighbour = self._rooms[neighbour_data.room]
		--- END OF BLOCK #3 ---

		slot18 = if neighbour.expansion then
		JUMP TO BLOCK #4
		else
		JUMP TO BLOCK #5
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #4 34-35, warpins: 1 ---
		local neighbour_expansion = neighbour.expansion[opp_side]
		--- END OF BLOCK #4 ---

		FLOW; TARGET BLOCK #5



		-- Decompilation error in this vicinity:
		--- BLOCK #5 36-38, warpins: 2 ---
		local overlap = neighbour_data.overlap

		--- END OF BLOCK #5 ---

		slot18 = if neighbour_expansion then
		JUMP TO BLOCK #6
		else
		JUMP TO BLOCK #7
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #6 39-47, warpins: 1 ---
		--- END OF BLOCK #6 ---

		slot20 = if self:_seg_to_seg_list_intersection_bool(neighbour_expansion.stairs, overlap, dim)

		 then
		JUMP TO BLOCK #7
		else
		JUMP TO BLOCK #9
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #7 48-49, warpins: 2 ---
		neighbour_block = true

		--- END OF BLOCK #7 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #11



		-- Decompilation error in this vicinity:
		--- BLOCK #8 50-50, warpins: 0 ---
		--- END OF BLOCK #8 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #10



		-- Decompilation error in this vicinity:
		--- BLOCK #9 51-57, warpins: 1 ---
		self:_append_seg_to_seg_list(exp_seg, overlap, dim)

		--- END OF BLOCK #9 ---

		FLOW; TARGET BLOCK #10



		-- Decompilation error in this vicinity:
		--- BLOCK #10 58-59, warpins: 3 ---
		--- END OF BLOCK #10 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #2



		-- Decompilation error in this vicinity:
		--- BLOCK #11 60-61, warpins: 2 ---
		--- END OF BLOCK #11 ---

		slot11 = if not neighbour_block then
		JUMP TO BLOCK #12
		else
		JUMP TO BLOCK #16
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #12 62-64, warpins: 1 ---
		--- END OF BLOCK #12 ---

		if #exp_seg == 1 then
		JUMP TO BLOCK #13
		else
		JUMP TO BLOCK #16
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #13 65-74, warpins: 1 ---
		--- END OF BLOCK #13 ---

		if exp_seg[1][1][dim] == room.borders[self._perp_neg_dir_str_map[side]] then
		JUMP TO BLOCK #14
		else
		JUMP TO BLOCK #16
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #14 75-84, warpins: 1 ---
		--- END OF BLOCK #14 ---

		if exp_seg[1][2][dim] == room.borders[self._perp_pos_dir_str_map[side]] then
		JUMP TO BLOCK #15
		else
		JUMP TO BLOCK #16
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #15 85-86, warpins: 1 ---
		expandable_sides[side] = true

		--- END OF BLOCK #15 ---

		FLOW; TARGET BLOCK #16



		-- Decompilation error in this vicinity:
		--- BLOCK #16 87-88, warpins: 7 ---
		--- END OF BLOCK #16 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #0



		-- Decompilation error in this vicinity:
		--- BLOCK #17 89-89, warpins: 1 ---
		return expandable_sides
		--- END OF BLOCK #17 ---



	end

	local function _is_larger_than_neighbours(room, dir_str)

		-- Decompilation error in this vicinity:
		--- BLOCK #0 1-6, warpins: 1 ---
		local area = room.area

		--- END OF BLOCK #0 ---

		for index_neightbour, neighbour_data in pairs(room.neighbours[dir_str])


		LOOP BLOCK #1
		GO OUT TO BLOCK #4



		-- Decompilation error in this vicinity:
		--- BLOCK #1 7-13, warpins: 1 ---
		local i_neighbour_room = neighbour_data.room
		local neighbour_area = self._rooms[i_neighbour_room].area

		--- END OF BLOCK #1 ---

		if area < neighbour_area then
		JUMP TO BLOCK #2
		else
		JUMP TO BLOCK #3
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #2 14-15, warpins: 1 ---
		return false
		--- END OF BLOCK #2 ---

		FLOW; TARGET BLOCK #3



		-- Decompilation error in this vicinity:
		--- BLOCK #3 16-17, warpins: 3 ---
		--- END OF BLOCK #3 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #0



		-- Decompilation error in this vicinity:
		--- BLOCK #4 18-19, warpins: 1 ---
		return true
		--- END OF BLOCK #4 ---



	end

	local sorted_rooms = self._building.sorted_rooms
	--- END OF BLOCK #0 ---

	FLOW; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #1 8-11, warpins: 2 ---
	--- END OF BLOCK #1 ---

	if #sorted_rooms > 0 then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #38
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 12-12, warpins: 1 ---
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 13-22, warpins: 1 ---
	local i_room = sorted_rooms[#sorted_rooms]
	local room = self._rooms[i_room]
	local expandable_borders = _get_room_expandable_borders(room)
	local exp_border = next(expandable_borders)

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 23-24, warpins: 6 ---
	--- END OF BLOCK #4 ---

	slot10 = if exp_border then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #37
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 25-25, warpins: 1 ---
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 26-32, warpins: 1 ---
	--- END OF BLOCK #6 ---

	slot11 = if self:_chk_room_side_too_long(room.borders, exp_border)

	 then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 33-37, warpins: 1 ---
	--- END OF BLOCK #7 ---

	slot11 = if expandable_borders[self._perp_neg_dir_str_map[exp_border]] then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 38-40, warpins: 1 ---
	exp_border = self._perp_neg_dir_str_map[exp_border]
	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #9 41-45, warpins: 1 ---
	--- END OF BLOCK #9 ---

	slot11 = if expandable_borders[self._perp_pos_dir_str_map[exp_border]] then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 46-48, warpins: 1 ---
	exp_border = self._perp_pos_dir_str_map[exp_border]
	--- END OF BLOCK #10 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 49-64, warpins: 4 ---
	local border_seg = self:_get_border_segment(room.height, room.borders, exp_border)
	local clip_size = self:_room_expansion_space_at_side(room.borders, exp_border)

	--- END OF BLOCK #11 ---

	for index_neighbour, neighbour_data in pairs(room.neighbours[exp_border])


	LOOP BLOCK #12
	GO OUT TO BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #12 65-77, warpins: 1 ---
	local neighbour_room = self._rooms[neighbour_data.room]
	local neighbour_borders = neighbour_room.borders
	local neighbour_clip_size = self:_room_retract_space_at_side(neighbour_room, self._opposite_side_str[exp_border], border_seg)
	--- END OF BLOCK #12 ---

	if neighbour_clip_size < clip_size then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 78-78, warpins: 1 ---
	clip_size = neighbour_clip_size

	--- END OF BLOCK #13 ---

	FLOW; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #14 79-80, warpins: 3 ---
	--- END OF BLOCK #14 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #15 81-83, warpins: 1 ---
	--- END OF BLOCK #15 ---

	if clip_size > 0 then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #30
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 84-89, warpins: 1 ---
	--- END OF BLOCK #16 ---

	slot13 = if _is_larger_than_neighbours(room, exp_border)

	 then
	JUMP TO BLOCK #17
	else
	JUMP TO BLOCK #30
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #17 90-97, warpins: 1 ---
	local new_rooms, trash_rooms, shrunk_rooms = self:_expand_room_over_neighbours(i_room, exp_border, clip_size)

	--- END OF BLOCK #17 ---

	slot13 = if new_rooms then
	JUMP TO BLOCK #18
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #18 98-101, warpins: 1 ---
	--- END OF BLOCK #18 ---

	for _, i_new_room in pairs(new_rooms)

	LOOP BLOCK #19
	GO OUT TO BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #19 102-106, warpins: 1 ---
	--- END OF BLOCK #19 ---

	slot21 = if not self._rooms[i_new_room].trashed then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 107-111, warpins: 1 ---
	self:_sort_room_by_area(i_new_room, sorted_rooms)
	--- END OF BLOCK #20 ---

	FLOW; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #21 112-113, warpins: 3 ---
	--- END OF BLOCK #21 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #22 114-115, warpins: 2 ---
	--- END OF BLOCK #22 ---

	slot15 = if shrunk_rooms then
	JUMP TO BLOCK #23
	else
	JUMP TO BLOCK #27
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #23 116-119, warpins: 1 ---
	--- END OF BLOCK #23 ---

	for _, i_shrunk_room in pairs(shrunk_rooms)

	LOOP BLOCK #24
	GO OUT TO BLOCK #27



	-- Decompilation error in this vicinity:
	--- BLOCK #24 120-124, warpins: 1 ---
	--- END OF BLOCK #24 ---

	slot21 = if not self._rooms[i_shrunk_room].trashed then
	JUMP TO BLOCK #25
	else
	JUMP TO BLOCK #26
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #25 125-130, warpins: 1 ---
	self:_sort_room_by_area(i_shrunk_room, sorted_rooms, true)
	--- END OF BLOCK #25 ---

	FLOW; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #26 131-132, warpins: 3 ---
	--- END OF BLOCK #26 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #23



	-- Decompilation error in this vicinity:
	--- BLOCK #27 133-134, warpins: 2 ---
	--- END OF BLOCK #27 ---

	slot14 = if trash_rooms then
	JUMP TO BLOCK #28
	else
	JUMP TO BLOCK #29
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #28 135-142, warpins: 1 ---
	_dispose_trash_rooms(trash_rooms, sorted_rooms)

	i_room = sorted_rooms[#sorted_rooms]
	room = self._rooms[i_room]
	--- END OF BLOCK #28 ---

	FLOW; TARGET BLOCK #29



	-- Decompilation error in this vicinity:
	--- BLOCK #29 143-151, warpins: 2 ---
	expandable_borders = _get_room_expandable_borders(room)
	exp_border = next(expandable_borders)
	--- END OF BLOCK #29 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #30 152-158, warpins: 2 ---
	expandable_borders[exp_border] = nil
	--- END OF BLOCK #30 ---

	slot13 = if expandable_borders[self._opposite_side_str[exp_border]] then
	JUMP TO BLOCK #31
	else
	JUMP TO BLOCK #32
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #31 159-161, warpins: 1 ---
	exp_border = self._opposite_side_str[exp_border]
	--- END OF BLOCK #31 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #32 162-166, warpins: 1 ---
	--- END OF BLOCK #32 ---

	slot13 = if expandable_borders[self._perp_neg_dir_str_map[exp_border]] then
	JUMP TO BLOCK #33
	else
	JUMP TO BLOCK #34
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #33 167-169, warpins: 1 ---
	exp_border = self._perp_neg_dir_str_map[exp_border]
	--- END OF BLOCK #33 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #34 170-174, warpins: 1 ---
	--- END OF BLOCK #34 ---

	slot13 = if expandable_borders[self._perp_pos_dir_str_map[exp_border]] then
	JUMP TO BLOCK #35
	else
	JUMP TO BLOCK #36
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #35 175-177, warpins: 1 ---
	exp_border = self._perp_pos_dir_str_map[exp_border]
	--- END OF BLOCK #35 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #36 178-179, warpins: 1 ---
	exp_border = nil

	--- END OF BLOCK #36 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #37 180-186, warpins: 1 ---
	table.remove(sorted_rooms)

	return
	--- END OF BLOCK #37 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #38 187-189, warpins: 1 ---
	return true
	--- END OF BLOCK #38 ---



end

function NavFieldBuilder:_sort_room_by_area(i_room, room_list, resort)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-2, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot3 = if resort then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 3-6, warpins: 1 ---
	--- END OF BLOCK #1 ---

	for sort_index, i_sorted_room in ipairs(room_list)

	LOOP BLOCK #2
	GO OUT TO BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #2 7-8, warpins: 1 ---
	--- END OF BLOCK #2 ---

	if i_room == i_sorted_room then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 9-14, warpins: 1 ---
	table.remove(room_list, sort_index)

	--- END OF BLOCK #3 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #4 15-16, warpins: 2 ---
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #5 17-20, warpins: 3 ---
	local room = self._rooms[i_room]
	local area = room.area
	local search_i = #room_list
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 21-23, warpins: 2 ---
	--- END OF BLOCK #6 ---

	if search_i > 0 then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 24-24, warpins: 1 ---
	--- END OF BLOCK #7 ---

	FLOW; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #8 25-30, warpins: 1 ---
	local i_test_room = room_list[search_i]
	local test_room = self._rooms[i_test_room]
	local test_area = test_room.area
	--- END OF BLOCK #8 ---

	if test_area <= area then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 31-31, warpins: 1 ---
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #10 32-33, warpins: 1 ---
	search_i = search_i - 1

	--- END OF BLOCK #10 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #11 34-40, warpins: 2 ---
	table.insert(room_list, search_i + 1, i_room)

	return
	--- END OF BLOCK #11 ---



end

function NavFieldBuilder:_update_progress_bar(percent_complete, text)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-3, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot3 = if self._progress_dialog then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 4-11, warpins: 1 ---
	local result = self._progress_dialog:update_bar(percent_complete, text)
	--- END OF BLOCK #1 ---

	slot3 = if not result then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 12-27, warpins: 1 ---
	local confirm = EWS:message_box(Global.frame_panel, "Cancel calculation?", "AI", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	--- END OF BLOCK #2 ---

	if confirm == "NO" then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 28-32, warpins: 1 ---
	self._progress_dialog:resume()

	return

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 33-34, warpins: 2 ---
	self._progress_dialog_cancel = true

	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 35-35, warpins: 3 ---
	return
	--- END OF BLOCK #5 ---



end

function NavFieldBuilder:_get_border_segment(height, borders, side)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-68, warpins: 1 ---
	local seg = {}
	seg[1] = Vector3()
	seg[MULTRES] = Vector3()

	mvector3["set_" .. self._dim_str_map[side]](seg[1], borders[side])
	mvector3["set_" .. self._dim_str_map[side]](seg[2], borders[side])
	mvector3["set_" .. self._perp_dim_str_map[side]](seg[1], borders[self._perp_neg_dir_str_map[side]])
	mvector3["set_" .. self._perp_dim_str_map[side]](seg[2], borders[self._perp_pos_dir_str_map[side]])

	local pos_z = self._get_room_height_at_pos(height, borders, seg[1])

	mvector3.set_z(seg[1], pos_z)

	local pos_z = self._get_room_height_at_pos(height, borders, seg[2])

	mvector3.set_z(seg[2], pos_z)

	return seg
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_expand_room_over_neighbours(i_room, exp_border, clip_size)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-8, warpins: 1 ---
	local room = self._rooms[i_room]
	local neighbours = room.neighbours[exp_border]
	local expand_vec = self._dir_str_to_vec[exp_border] * clip_size
	local new_rooms, trash_rooms, shrunk_rooms = nil
	--- END OF BLOCK #0 ---

	FLOW; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #1 9-9, warpins: 2 ---
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 10-14, warpins: 1 ---
	local new_room = nil

	--- END OF BLOCK #2 ---

	for index_neighbour, neighbour_data in pairs(neighbours)


	LOOP BLOCK #3
	GO OUT TO BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #3 15-25, warpins: 1 ---
	local clip_segment = neighbour_data.overlap
	new_room = self:_split_room_for_retraction(neighbour_data.room, self._opposite_side_str[exp_border], clip_segment)
	--- END OF BLOCK #3 ---

	slot10 = if new_room then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 26-27, warpins: 1 ---
	--- END OF BLOCK #4 ---

	slot7 = if not new_rooms then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 28-28, warpins: 1 ---
	new_rooms = {}

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 29-34, warpins: 2 ---
	table.insert(new_rooms, new_room)

	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #7 35-36, warpins: 2 ---
	--- END OF BLOCK #7 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #8 37-38, warpins: 2 ---
	--- END OF BLOCK #8 ---

	slot10 = if not new_room then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #1
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 39-43, warpins: 1 ---
	local retract_rooms = {}

	--- END OF BLOCK #9 ---

	for index_neighbour, neighbour_data in pairs(neighbours)

	LOOP BLOCK #10
	GO OUT TO BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #10 44-48, warpins: 1 ---
	table.insert(retract_rooms, neighbour_data)
	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 49-50, warpins: 2 ---
	--- END OF BLOCK #11 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #12 51-55, warpins: 1 ---
	--- END OF BLOCK #12 ---

	for obs_type, seg_list in pairs(room.expansion[exp_border])

	LOOP BLOCK #13
	GO OUT TO BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #13 56-59, warpins: 1 ---
	--- END OF BLOCK #13 ---

	for i_seg, seg in pairs(seg_list)


	LOOP BLOCK #14
	GO OUT TO BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #14 60-65, warpins: 1 ---
	seg[1] = seg[1] + expand_vec
	seg[2] = seg[2] + expand_vec

	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 66-67, warpins: 2 ---
	--- END OF BLOCK #15 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #16 68-69, warpins: 2 ---
	--- END OF BLOCK #16 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #17 70-73, warpins: 1 ---
	--- END OF BLOCK #17 ---

	for _, neighbour_data in pairs(retract_rooms)


	LOOP BLOCK #18
	GO OUT TO BLOCK #56



	-- Decompilation error in this vicinity:
	--- BLOCK #18 74-84, warpins: 1 ---
	local clip_segment = neighbour_data.overlap
	--- END OF BLOCK #18 ---

	if clip_segment[1][self._perp_dim_str_map[exp_border]] ~= room.borders[self._perp_neg_dir_str_map[exp_border]] then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #20
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 85-86, warpins: 1 ---
	slot17 = false
	--- END OF BLOCK #19 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #20 87-87, warpins: 1 ---
	local want_neg_data = true
	--- END OF BLOCK #20 ---

	FLOW; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #21 88-97, warpins: 2 ---
	--- END OF BLOCK #21 ---

	if clip_segment[2][self._perp_dim_str_map[exp_border]] ~= room.borders[self._perp_pos_dir_str_map[exp_border]] then
	JUMP TO BLOCK #22
	else
	JUMP TO BLOCK #23
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #22 98-99, warpins: 1 ---
	slot18 = false
	--- END OF BLOCK #22 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #23 100-100, warpins: 1 ---
	local want_pos_data = true
	--- END OF BLOCK #23 ---

	FLOW; TARGET BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #24 101-112, warpins: 2 ---
	local destroy, new_data = self:_clip_room_border(neighbour_data.room, self._opposite_side_str[exp_border], clip_size, clip_segment, want_neg_data, want_pos_data)
	--- END OF BLOCK #24 ---

	slot19 = if destroy then
	JUMP TO BLOCK #25
	else
	JUMP TO BLOCK #28
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #25 113-114, warpins: 1 ---
	--- END OF BLOCK #25 ---

	slot8 = if not trash_rooms then
	JUMP TO BLOCK #26
	else
	JUMP TO BLOCK #27
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #26 115-115, warpins: 1 ---
	trash_rooms = {}

	--- END OF BLOCK #26 ---

	FLOW; TARGET BLOCK #27



	-- Decompilation error in this vicinity:
	--- BLOCK #27 116-121, warpins: 2 ---
	table.insert(trash_rooms, neighbour_data.room)

	--- END OF BLOCK #27 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #31



	-- Decompilation error in this vicinity:
	--- BLOCK #28 122-123, warpins: 1 ---
	--- END OF BLOCK #28 ---

	slot9 = if not shrunk_rooms then
	JUMP TO BLOCK #29
	else
	JUMP TO BLOCK #30
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #29 124-124, warpins: 1 ---
	shrunk_rooms = {}

	--- END OF BLOCK #29 ---

	FLOW; TARGET BLOCK #30



	-- Decompilation error in this vicinity:
	--- BLOCK #30 125-129, warpins: 2 ---
	table.insert(shrunk_rooms, neighbour_data.room)
	--- END OF BLOCK #30 ---

	FLOW; TARGET BLOCK #31



	-- Decompilation error in this vicinity:
	--- BLOCK #31 130-131, warpins: 2 ---
	--- END OF BLOCK #31 ---

	slot20 = if new_data then
	JUMP TO BLOCK #32
	else
	JUMP TO BLOCK #55
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #32 132-135, warpins: 1 ---
	--- END OF BLOCK #32 ---

	for side, neighbour_list in pairs(new_data.neighbours)

	LOOP BLOCK #33
	GO OUT TO BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #33 136-139, warpins: 1 ---
	--- END OF BLOCK #33 ---

	for neighbour_index, neighbour_data in pairs(neighbour_list)

	LOOP BLOCK #34
	GO OUT TO BLOCK #37



	-- Decompilation error in this vicinity:
	--- BLOCK #34 140-152, warpins: 1 ---
	self:_append_neighbour(room.neighbours[side], neighbour_data, side)

	--- END OF BLOCK #34 ---

	slot31 = if self._rooms[neighbour_data.room].neighbours then
	JUMP TO BLOCK #35
	else
	JUMP TO BLOCK #36
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #35 153-175, warpins: 1 ---
	local new_data = {}
	new_data.room = i_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_append_neighbour(self._rooms[neighbour_data.room].neighbours[self._opposite_side_str[side]], new_data, self._opposite_side_str[side])

	--- END OF BLOCK #35 ---

	FLOW; TARGET BLOCK #36



	-- Decompilation error in this vicinity:
	--- BLOCK #36 176-177, warpins: 3 ---
	--- END OF BLOCK #36 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #33



	-- Decompilation error in this vicinity:
	--- BLOCK #37 178-179, warpins: 2 ---
	--- END OF BLOCK #37 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #32



	-- Decompilation error in this vicinity:
	--- BLOCK #38 180-181, warpins: 1 ---
	--- END OF BLOCK #38 ---

	slot19 = if not destroy then
	JUMP TO BLOCK #39
	else
	JUMP TO BLOCK #40
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #39 182-191, warpins: 1 ---
	neighbour_data.overlap[1] = neighbour_data.overlap[1] + expand_vec
	neighbour_data.overlap[2] = neighbour_data.overlap[2] + expand_vec

	--- END OF BLOCK #39 ---

	FLOW; TARGET BLOCK #40



	-- Decompilation error in this vicinity:
	--- BLOCK #40 192-195, warpins: 2 ---
	--- END OF BLOCK #40 ---

	slot21 = if new_data.expansion[exp_border] then
	JUMP TO BLOCK #41
	else
	JUMP TO BLOCK #48
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #41 196-200, warpins: 1 ---
	--- END OF BLOCK #41 ---

	for obs_type, seg_list in pairs(new_data.expansion[exp_border])

	LOOP BLOCK #42
	GO OUT TO BLOCK #48



	-- Decompilation error in this vicinity:
	--- BLOCK #42 201-204, warpins: 1 ---
	--- END OF BLOCK #42 ---

	for i_seg, seg in pairs(seg_list)

	LOOP BLOCK #43
	GO OUT TO BLOCK #47



	-- Decompilation error in this vicinity:
	--- BLOCK #43 205-209, warpins: 1 ---
	--- END OF BLOCK #43 ---

	for obs_type, old_seg_list in pairs(room.expansion[exp_border])


	LOOP BLOCK #44
	GO OUT TO BLOCK #46



	-- Decompilation error in this vicinity:
	--- BLOCK #44 210-219, warpins: 1 ---
	room.expansion[exp_border][obs_type] = self:_remove_seg_from_seg_list(old_seg_list, seg, self._perp_dim_str_map[exp_border])

	--- END OF BLOCK #44 ---

	FLOW; TARGET BLOCK #45



	-- Decompilation error in this vicinity:
	--- BLOCK #45 220-221, warpins: 2 ---
	--- END OF BLOCK #45 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #43



	-- Decompilation error in this vicinity:
	--- BLOCK #46 222-223, warpins: 2 ---
	--- END OF BLOCK #46 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #42



	-- Decompilation error in this vicinity:
	--- BLOCK #47 224-225, warpins: 2 ---
	--- END OF BLOCK #47 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #41



	-- Decompilation error in this vicinity:
	--- BLOCK #48 226-229, warpins: 2 ---
	--- END OF BLOCK #48 ---

	for side, obs_data in pairs(new_data.expansion)

	LOOP BLOCK #49
	GO OUT TO BLOCK #55



	-- Decompilation error in this vicinity:
	--- BLOCK #49 230-233, warpins: 1 ---
	--- END OF BLOCK #49 ---

	for obs_type, seg_list in pairs(obs_data)

	LOOP BLOCK #50
	GO OUT TO BLOCK #54



	-- Decompilation error in this vicinity:
	--- BLOCK #50 234-237, warpins: 1 ---
	--- END OF BLOCK #50 ---

	for i_seg, seg in pairs(seg_list)

	LOOP BLOCK #51
	GO OUT TO BLOCK #53



	-- Decompilation error in this vicinity:
	--- BLOCK #51 238-246, warpins: 1 ---
	self:_append_seg_to_seg_list(room.expansion[side][obs_type], seg, self._perp_dim_str_map[side])

	--- END OF BLOCK #51 ---

	FLOW; TARGET BLOCK #52



	-- Decompilation error in this vicinity:
	--- BLOCK #52 247-248, warpins: 2 ---
	--- END OF BLOCK #52 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #50



	-- Decompilation error in this vicinity:
	--- BLOCK #53 249-250, warpins: 2 ---
	--- END OF BLOCK #53 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #49



	-- Decompilation error in this vicinity:
	--- BLOCK #54 251-252, warpins: 2 ---
	--- END OF BLOCK #54 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #48



	-- Decompilation error in this vicinity:
	--- BLOCK #55 253-254, warpins: 3 ---
	--- END OF BLOCK #55 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #56 255-260, warpins: 1 ---
	slot11 = room.borders[exp_border]
	--- END OF BLOCK #56 ---

	slot12 = if self._neg_dir_str_map[exp_border] then
	JUMP TO BLOCK #57
	else
	JUMP TO BLOCK #58
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #57 261-262, warpins: 1 ---
	slot12 = -1
	--- END OF BLOCK #57 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #59



	-- Decompilation error in this vicinity:
	--- BLOCK #58 263-263, warpins: 1 ---
	slot12 = 1
	--- END OF BLOCK #58 ---

	FLOW; TARGET BLOCK #59



	-- Decompilation error in this vicinity:
	--- BLOCK #59 264-282, warpins: 2 ---
	local new_border = slot11 + clip_size * slot12
	room.borders[exp_border] = new_border
	room.area = self:_calc_room_area(room.borders)

	self:_find_room_height_from_expansion(room.expansion, room.height, "x_pos")

	return new_rooms, trash_rooms, shrunk_rooms
	--- END OF BLOCK #59 ---



end

function NavFieldBuilder:_room_expansion_space_at_side(borders, exp_border)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-9, warpins: 1 ---
	local length_size = math.abs(borders[exp_border] - borders[self._opposite_side_str[exp_border]])

	return length_size
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_room_retract_space_at_side(room, side, border_line)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-16, warpins: 1 ---
	local borders = room.borders
	local expansion = room.expansion
	local perp_neg_side = self._perp_neg_dir_str_map[side]
	local perp_pos_side = self._perp_pos_dir_str_map[side]
	local side_dim = self._dim_str_map[side]
	local side_perp_dim = self._perp_dim_str_map[side]
	local max_obstacle, min_obstacle = nil

	--- END OF BLOCK #0 ---

	if border_line[1][side_perp_dim] < borders[perp_neg_side] then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 17-21, warpins: 1 ---
	--- END OF BLOCK #1 ---

	for i_seg, seg in pairs(expansion[perp_neg_side].stairs)


	LOOP BLOCK #2
	GO OUT TO BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #2 22-23, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot10 = if max_obstacle then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 24-27, warpins: 1 ---
	--- END OF BLOCK #3 ---

	if max_obstacle < seg[2][side_dim] then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 28-29, warpins: 2 ---
	max_obstacle = seg[2][side_dim]
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 30-31, warpins: 2 ---
	--- END OF BLOCK #5 ---

	slot11 = if min_obstacle then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 32-35, warpins: 1 ---
	--- END OF BLOCK #6 ---

	if seg[1][side_dim] < min_obstacle then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 36-37, warpins: 2 ---
	min_obstacle = seg[1][side_dim]

	--- END OF BLOCK #7 ---

	FLOW; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #8 38-39, warpins: 3 ---
	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #9 40-44, warpins: 2 ---
	--- END OF BLOCK #9 ---

	if borders[perp_pos_side] < border_line[2][side_perp_dim] then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 45-49, warpins: 1 ---
	--- END OF BLOCK #10 ---

	for i_seg, seg in pairs(expansion[perp_pos_side].stairs)


	LOOP BLOCK #11
	GO OUT TO BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #11 50-51, warpins: 1 ---
	--- END OF BLOCK #11 ---

	slot10 = if max_obstacle then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #13
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 52-55, warpins: 1 ---
	--- END OF BLOCK #12 ---

	if max_obstacle < seg[2][side_dim] then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 56-57, warpins: 2 ---
	max_obstacle = seg[2][side_dim]
	--- END OF BLOCK #13 ---

	FLOW; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #14 58-59, warpins: 2 ---
	--- END OF BLOCK #14 ---

	slot11 = if min_obstacle then
	JUMP TO BLOCK #15
	else
	JUMP TO BLOCK #16
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #15 60-63, warpins: 1 ---
	--- END OF BLOCK #15 ---

	if seg[1][side_dim] < min_obstacle then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 64-65, warpins: 2 ---
	min_obstacle = seg[1][side_dim]
	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 66-67, warpins: 3 ---
	--- END OF BLOCK #17 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #18 68-72, warpins: 2 ---
	local clamp_length = nil
	--- END OF BLOCK #18 ---

	slot13 = if self._neg_dir_str_map[side] then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 73-74, warpins: 1 ---
	--- END OF BLOCK #19 ---

	slot11 = if min_obstacle then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 75-77, warpins: 1 ---
	clamp_length = min_obstacle - borders[side]
	--- END OF BLOCK #20 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #25



	-- Decompilation error in this vicinity:
	--- BLOCK #21 78-83, warpins: 1 ---
	clamp_length = borders[self._opposite_side_str[side]] - borders[side]
	--- END OF BLOCK #21 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #25



	-- Decompilation error in this vicinity:
	--- BLOCK #22 84-85, warpins: 1 ---
	--- END OF BLOCK #22 ---

	slot10 = if max_obstacle then
	JUMP TO BLOCK #23
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #23 86-88, warpins: 1 ---
	clamp_length = borders[side] - max_obstacle
	--- END OF BLOCK #23 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #25



	-- Decompilation error in this vicinity:
	--- BLOCK #24 89-93, warpins: 1 ---
	clamp_length = borders[side] - borders[self._opposite_side_str[side]]

	--- END OF BLOCK #24 ---

	FLOW; TARGET BLOCK #25



	-- Decompilation error in this vicinity:
	--- BLOCK #25 94-94, warpins: 4 ---
	return clamp_length
	--- END OF BLOCK #25 ---



end

function NavFieldBuilder:_split_room_for_retraction(i_room, side, clip_segment)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-20, warpins: 1 ---
	local room = self._rooms[i_room]
	local borders = room.borders
	local clip_perp_dim = self._perp_dim_str_map[side]
	local perp_neg_side = self._perp_neg_dir_str_map[side]
	local perp_pos_side = self._perp_pos_dir_str_map[side]
	local clip_line = {}
	clip_line[1] = clip_segment[1][clip_perp_dim]
	clip_line[2] = clip_segment[2][clip_perp_dim]
	--- END OF BLOCK #0 ---

	if clip_line[1] ~= borders[perp_neg_side] then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 21-22, warpins: 1 ---
	slot10 = false
	--- END OF BLOCK #1 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #2 23-23, warpins: 1 ---
	local overlaps_neg = true
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 24-27, warpins: 2 ---
	--- END OF BLOCK #3 ---

	if clip_line[2] ~= borders[perp_pos_side] then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 28-29, warpins: 1 ---
	slot11 = false
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #5 30-30, warpins: 1 ---
	local overlaps_pos = true
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 31-32, warpins: 2 ---
	--- END OF BLOCK #6 ---

	slot10 = if overlaps_neg then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 33-34, warpins: 1 ---
	--- END OF BLOCK #7 ---

	slot11 = if not overlaps_pos then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 35-36, warpins: 2 ---
	--- END OF BLOCK #8 ---

	slot10 = if overlaps_neg then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 37-39, warpins: 1 ---
	--- END OF BLOCK #9 ---

	slot12 = if not clip_line[2] then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 40-40, warpins: 2 ---
	local split_pos = clip_line[1]
	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 41-47, warpins: 2 ---
	local new_i_room = self:_split_room(i_room, split_pos, clip_perp_dim)

	return new_i_room
	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 48-48, warpins: 2 ---
	return
	--- END OF BLOCK #12 ---



end

function NavFieldBuilder:_clip_room_border(i_room, side, clip_amount, clip_segment, want_neg_data, want_pos_data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-52, warpins: 1 ---
	local room = self._rooms[i_room]
	local borders = room.borders
	local neighbours = room.neighbours
	local expansion = room.expansion
	local expansion_segments = room.expansion_segments
	local new_data = {}
	local lower_neighbours = {}
	lower_neighbours.x_pos = {}
	lower_neighbours.x_neg = {}
	lower_neighbours.y_pos = {}
	lower_neighbours.y_neg = {}
	local upper_neighbours = {}
	upper_neighbours.x_pos = {}
	upper_neighbours.x_neg = {}
	upper_neighbours.y_pos = {}
	upper_neighbours.y_neg = {}
	local is_clip_side_neg = self._neg_dir_str_map[side]
	local clip_dim = self._dim_str_map[side]
	local clip_perp_dim = self._perp_dim_str_map[side]
	local perp_neg_side = self._perp_neg_dir_str_map[side]
	local perp_pos_side = self._perp_pos_dir_str_map[side]
	local opp_side = self._opposite_side_str[side]
	local clip_line = {}
	clip_line[1] = clip_segment[1][clip_perp_dim]
	clip_line[2] = clip_segment[2][clip_perp_dim]
	local my_length = math.abs(borders[side] - borders[opp_side])
	--- END OF BLOCK #0 ---

	if clip_amount < my_length then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #39
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 53-66, warpins: 1 ---
	local lower_expansion_data = {}
	local upper_expansion_data = {}
	lower_expansion_data[perp_neg_side] = {}
	lower_expansion_data[perp_pos_side] = {}
	upper_expansion_data[perp_neg_side] = {}
	upper_expansion_data[perp_pos_side] = {}
	--- END OF BLOCK #1 ---

	slot25 = if self._neg_dir_str_map[side] then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 67-70, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot25 = if not (borders[side] + clip_amount) then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 71-72, warpins: 2 ---
	slot25 = borders[side] - clip_amount
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 73-95, warpins: 2 ---
	borders[side] = slot25
	local clip_pos = Vector3()

	mvector3["set_" .. clip_dim](clip_pos, borders[side])
	mvector3["set_" .. clip_perp_dim](clip_pos, borders[perp_neg_side])
	--- END OF BLOCK #4 ---

	for obs_type, obs_list in pairs(expansion[perp_neg_side])


	LOOP BLOCK #5
	GO OUT TO BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #5 96-105, warpins: 1 ---
	local lower_part, upper_part = self:_split_segment_list_at_position(obs_list, clip_pos, clip_dim)
	upper_expansion_data[perp_neg_side][obs_type] = upper_part
	lower_expansion_data[perp_neg_side][obs_type] = lower_part
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 106-107, warpins: 2 ---
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #7 108-127, warpins: 1 ---
	local lower_part, upper_part = self:_split_side_neighbours(neighbours[perp_neg_side], clip_pos, clip_dim)
	lower_neighbours[perp_neg_side] = lower_part
	upper_neighbours[perp_neg_side] = upper_part

	mvector3["set_" .. clip_perp_dim](clip_pos, borders[perp_pos_side])
	--- END OF BLOCK #7 ---

	for obs_type, obs_list in pairs(expansion[perp_pos_side])


	LOOP BLOCK #8
	GO OUT TO BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #8 128-137, warpins: 1 ---
	local lower_part, upper_part = self:_split_segment_list_at_position(obs_list, clip_pos, clip_dim)
	upper_expansion_data[perp_pos_side][obs_type] = upper_part
	lower_expansion_data[perp_pos_side][obs_type] = lower_part
	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 138-139, warpins: 2 ---
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #10 140-149, warpins: 1 ---
	local lower_part, upper_part = self:_split_side_neighbours(neighbours[perp_pos_side], clip_pos, clip_dim)
	lower_neighbours[perp_pos_side] = lower_part
	upper_neighbours[perp_pos_side] = upper_part
	--- END OF BLOCK #10 ---

	slot15 = if is_clip_side_neg then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 150-159, warpins: 1 ---
	new_data.expansion = lower_expansion_data
	new_data.neighbours = lower_neighbours
	expansion[perp_neg_side] = upper_expansion_data[perp_neg_side]
	expansion[perp_pos_side] = upper_expansion_data[perp_pos_side]

	--- END OF BLOCK #11 ---

	for neighbour_index, neighbour_data in pairs(lower_neighbours[perp_neg_side])

	LOOP BLOCK #12
	GO OUT TO BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #12 160-166, warpins: 1 ---
	self:_update_neighbour_data(neighbour_data.room, i_room, nil, perp_pos_side)
	--- END OF BLOCK #12 ---

	FLOW; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #13 167-168, warpins: 2 ---
	--- END OF BLOCK #13 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #14 169-172, warpins: 1 ---
	--- END OF BLOCK #14 ---

	for neighbour_index, neighbour_data in pairs(lower_neighbours[perp_pos_side])

	LOOP BLOCK #15
	GO OUT TO BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #15 173-179, warpins: 1 ---
	self:_update_neighbour_data(neighbour_data.room, i_room, nil, perp_neg_side)

	--- END OF BLOCK #15 ---

	FLOW; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #16 180-181, warpins: 2 ---
	--- END OF BLOCK #16 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #17 182-186, warpins: 1 ---
	neighbours[perp_neg_side] = upper_neighbours[perp_neg_side]
	neighbours[perp_pos_side] = upper_neighbours[perp_pos_side]
	--- END OF BLOCK #17 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #25



	-- Decompilation error in this vicinity:
	--- BLOCK #18 187-196, warpins: 1 ---
	new_data.expansion = upper_expansion_data
	new_data.neighbours = upper_neighbours
	expansion[perp_neg_side] = lower_expansion_data[perp_neg_side]
	expansion[perp_pos_side] = lower_expansion_data[perp_pos_side]

	--- END OF BLOCK #18 ---

	for neighbour_index, neighbour_data in pairs(upper_neighbours[perp_neg_side])

	LOOP BLOCK #19
	GO OUT TO BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #19 197-203, warpins: 1 ---
	self:_update_neighbour_data(neighbour_data.room, i_room, nil, perp_pos_side)
	--- END OF BLOCK #19 ---

	FLOW; TARGET BLOCK #20



	-- Decompilation error in this vicinity:
	--- BLOCK #20 204-205, warpins: 2 ---
	--- END OF BLOCK #20 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #21 206-209, warpins: 1 ---
	--- END OF BLOCK #21 ---

	for neighbour_index, neighbour_data in pairs(upper_neighbours[perp_pos_side])

	LOOP BLOCK #22
	GO OUT TO BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #22 210-216, warpins: 1 ---
	self:_update_neighbour_data(neighbour_data.room, i_room, nil, perp_neg_side)

	--- END OF BLOCK #22 ---

	FLOW; TARGET BLOCK #23



	-- Decompilation error in this vicinity:
	--- BLOCK #23 217-218, warpins: 2 ---
	--- END OF BLOCK #23 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #24 219-222, warpins: 1 ---
	neighbours[perp_neg_side] = lower_neighbours[perp_neg_side]
	neighbours[perp_pos_side] = lower_neighbours[perp_pos_side]
	--- END OF BLOCK #24 ---

	FLOW; TARGET BLOCK #25



	-- Decompilation error in this vicinity:
	--- BLOCK #25 223-224, warpins: 2 ---
	--- END OF BLOCK #25 ---

	slot5 = if not want_neg_data then
	JUMP TO BLOCK #26
	else
	JUMP TO BLOCK #27
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #26 225-230, warpins: 1 ---
	new_data.expansion[perp_neg_side] = {}
	new_data.neighbours[perp_neg_side] = {}
	--- END OF BLOCK #26 ---

	FLOW; TARGET BLOCK #27



	-- Decompilation error in this vicinity:
	--- BLOCK #27 231-232, warpins: 2 ---
	--- END OF BLOCK #27 ---

	slot6 = if not want_pos_data then
	JUMP TO BLOCK #28
	else
	JUMP TO BLOCK #29
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #28 233-238, warpins: 1 ---
	new_data.expansion[perp_pos_side] = {}
	new_data.neighbours[perp_pos_side] = {}
	--- END OF BLOCK #28 ---

	FLOW; TARGET BLOCK #29



	-- Decompilation error in this vicinity:
	--- BLOCK #29 239-255, warpins: 2 ---
	local mid_space = self:_get_border_segment(room.height, room.borders, side)
	expansion[side].spaces = {
		mid_space
	}
	local retract_vec = self._dir_str_to_vec[opp_side] * clip_amount

	--- END OF BLOCK #29 ---

	for neighbour_index, neighbour_data in pairs(neighbours[side])


	LOOP BLOCK #30
	GO OUT TO BLOCK #32



	-- Decompilation error in this vicinity:
	--- BLOCK #30 256-262, warpins: 1 ---
	local overlap = neighbour_data.overlap
	overlap[1] = overlap[1] + retract_vec
	overlap[2] = overlap[2] + retract_vec

	--- END OF BLOCK #30 ---

	FLOW; TARGET BLOCK #31



	-- Decompilation error in this vicinity:
	--- BLOCK #31 263-264, warpins: 2 ---
	--- END OF BLOCK #31 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #29



	-- Decompilation error in this vicinity:
	--- BLOCK #32 265-268, warpins: 1 ---
	--- END OF BLOCK #32 ---

	for neighbour_index, neighbour_data in pairs(neighbours[perp_neg_side])


	LOOP BLOCK #33
	GO OUT TO BLOCK #35



	-- Decompilation error in this vicinity:
	--- BLOCK #33 269-285, warpins: 1 ---
	local new_data = {}
	new_data.room = i_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_update_neighbour_data(neighbour_data.room, i_room, new_data, perp_pos_side)
	--- END OF BLOCK #33 ---

	FLOW; TARGET BLOCK #34



	-- Decompilation error in this vicinity:
	--- BLOCK #34 286-287, warpins: 2 ---
	--- END OF BLOCK #34 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #32



	-- Decompilation error in this vicinity:
	--- BLOCK #35 288-291, warpins: 1 ---
	--- END OF BLOCK #35 ---

	for neighbour_index, neighbour_data in pairs(neighbours[perp_pos_side])


	LOOP BLOCK #36
	GO OUT TO BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #36 292-308, warpins: 1 ---
	local new_data = {}
	new_data.room = i_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_update_neighbour_data(neighbour_data.room, i_room, new_data, perp_neg_side)

	--- END OF BLOCK #36 ---

	FLOW; TARGET BLOCK #37



	-- Decompilation error in this vicinity:
	--- BLOCK #37 309-310, warpins: 2 ---
	--- END OF BLOCK #37 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #35



	-- Decompilation error in this vicinity:
	--- BLOCK #38 311-322, warpins: 1 ---
	room.area = self:_calc_room_area(borders)

	self:_find_room_height_from_expansion(expansion, room.height, side)

	--- END OF BLOCK #38 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #44



	-- Decompilation error in this vicinity:
	--- BLOCK #39 323-328, warpins: 1 ---
	new_data.expansion = {}
	new_data.neighbours = {}
	--- END OF BLOCK #39 ---

	slot5 = if want_neg_data then
	JUMP TO BLOCK #40
	else
	JUMP TO BLOCK #41
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #40 329-334, warpins: 1 ---
	new_data.expansion[perp_neg_side] = expansion[perp_neg_side]
	new_data.neighbours[perp_neg_side] = neighbours[perp_neg_side]
	--- END OF BLOCK #40 ---

	FLOW; TARGET BLOCK #41



	-- Decompilation error in this vicinity:
	--- BLOCK #41 335-336, warpins: 2 ---
	--- END OF BLOCK #41 ---

	slot6 = if want_pos_data then
	JUMP TO BLOCK #42
	else
	JUMP TO BLOCK #43
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #42 337-342, warpins: 1 ---
	new_data.expansion[perp_pos_side] = expansion[perp_pos_side]
	new_data.neighbours[perp_pos_side] = neighbours[perp_pos_side]
	--- END OF BLOCK #42 ---

	FLOW; TARGET BLOCK #43



	-- Decompilation error in this vicinity:
	--- BLOCK #43 343-355, warpins: 2 ---
	new_data.expansion[opp_side] = expansion[opp_side]
	new_data.neighbours[opp_side] = neighbours[opp_side]

	self:_trash_room(i_room)

	return true, new_data
	--- END OF BLOCK #43 ---

	FLOW; TARGET BLOCK #44



	-- Decompilation error in this vicinity:
	--- BLOCK #44 356-358, warpins: 2 ---
	return false, new_data
	--- END OF BLOCK #44 ---



end

function NavFieldBuilder:_split_room(i_room, split_pos_along_dim, split_dim)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-11, warpins: 1 ---
	local room = self._rooms[i_room]
	local borders = room.borders
	local expansion = room.expansion
	local new_room = self:_create_empty_room()
	new_room.segment = room.segment
	--- END OF BLOCK #0 ---

	if split_dim == "x" then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 12-13, warpins: 1 ---
	slot8 = "x_pos"
	--- END OF BLOCK #1 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #2 14-14, warpins: 1 ---
	local split_side = "y_pos"
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 15-44, warpins: 2 ---
	local split_perp_neg_side = self._perp_neg_dir_str_map[split_side]
	local split_perp_pos_side = self._perp_pos_dir_str_map[split_side]
	local split_perp_dim = self._perp_dim_str_map[split_side]
	local split_opp_side = self._opposite_side_str[split_side]
	local split_pos = Vector3()

	mvector3["set_" .. split_dim](split_pos, split_pos_along_dim)
	mvector3["set_" .. split_perp_dim](split_pos, borders[split_perp_neg_side])
	--- END OF BLOCK #3 ---

	for obs_type, obs_list in pairs(expansion[split_perp_neg_side])


	LOOP BLOCK #4
	GO OUT TO BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #4 45-55, warpins: 1 ---
	local lower_part, upper_part = self:_split_segment_list_at_position(obs_list, split_pos, split_dim)
	expansion[split_perp_neg_side][obs_type] = upper_part
	new_room.expansion[split_perp_neg_side][obs_type] = lower_part
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 56-57, warpins: 2 ---
	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #6 58-80, warpins: 1 ---
	local lower_part, upper_part = self:_split_side_neighbours(room.neighbours[split_perp_neg_side], split_pos, split_dim)
	room.neighbours[split_perp_neg_side] = upper_part
	new_room.neighbours[split_perp_neg_side] = lower_part

	mvector3["set_" .. split_perp_dim](split_pos, borders[split_perp_pos_side])
	--- END OF BLOCK #6 ---

	for obs_type, obs_list in pairs(expansion[split_perp_pos_side])


	LOOP BLOCK #7
	GO OUT TO BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #7 81-91, warpins: 1 ---
	local lower_part, upper_part = self:_split_segment_list_at_position(obs_list, split_pos, split_dim)
	expansion[split_perp_pos_side][obs_type] = upper_part
	new_room.expansion[split_perp_pos_side][obs_type] = lower_part
	--- END OF BLOCK #7 ---

	FLOW; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #8 92-93, warpins: 2 ---
	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #9 94-220, warpins: 1 ---
	local lower_part, upper_part = self:_split_side_neighbours(room.neighbours[split_perp_pos_side], split_pos, split_dim)
	room.neighbours[split_perp_pos_side] = upper_part
	new_room.neighbours[split_perp_pos_side] = lower_part
	local space = {}
	space[1] = Vector3()
	space[MULTRES] = Vector3()

	mvector3["set_" .. split_dim](space[1], split_pos_along_dim)
	mvector3["set_" .. split_dim](space[2], split_pos_along_dim)
	mvector3["set_" .. split_perp_dim](space[1], borders[split_perp_neg_side])
	mvector3["set_" .. split_perp_dim](space[2], borders[split_perp_pos_side])

	local pos_z = self._get_room_height_at_pos(room.height, borders, space[1])

	mvector3.set_z(space[1], pos_z)

	pos_z = self._get_room_height_at_pos(room.height, borders, space[2])

	mvector3.set_z(space[2], pos_z)

	new_room.expansion[split_side] = {
		spaces = {
			space
		},
		walls = {},
		stairs = {},
		cliffs = {},
		unsorted = {}
	}
	new_room.expansion[split_opp_side] = room.expansion[split_opp_side]
	expansion[split_opp_side] = {
		spaces = {
			{
				space[1],
				space[2]
			}
		},
		walls = {},
		stairs = {},
		cliffs = {},
		unsorted = {}
	}
	new_room.neighbours[split_side] = {
		{
			room = i_room,
			overlap = {
				space[1],
				space[2]
			}
		}
	}
	local i_new_room = #self._rooms + 1

	--- END OF BLOCK #9 ---

	for neighbour_index, neighbour_data in pairs(room.neighbours[split_opp_side])

	LOOP BLOCK #10
	GO OUT TO BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #10 221-226, warpins: 1 ---
	--- END OF BLOCK #10 ---

	slot26 = if self._rooms[neighbour_data.room].neighbours then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 227-253, warpins: 1 ---
	self:_update_neighbour_data(neighbour_data.room, i_room, nil, split_side)

	local new_data = {}
	new_data.room = i_new_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_append_neighbour(self._rooms[neighbour_data.room].neighbours[split_side], new_data, split_side)

	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 254-255, warpins: 3 ---
	--- END OF BLOCK #12 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #13 256-314, warpins: 1 ---
	new_room.neighbours[split_opp_side] = room.neighbours[split_opp_side]
	room.neighbours[split_opp_side] = {
		{
			room = i_new_room,
			overlap = {
				space[1],
				space[2]
			}
		}
	}
	new_room.borders[split_side] = split_pos_along_dim
	new_room.borders[split_opp_side] = room.borders[split_opp_side]
	new_room.borders[split_perp_neg_side] = room.borders[split_perp_neg_side]
	new_room.borders[split_perp_pos_side] = room.borders[split_perp_pos_side]
	room.borders[split_opp_side] = split_pos_along_dim

	self:_find_room_height_from_expansion(new_room.expansion, new_room.height, "x_pos")
	self:_find_room_height_from_expansion(room.expansion, room.height, "x_pos")

	room.area = self:_calc_room_area(room.borders)
	new_room.area = self:_calc_room_area(new_room.borders)

	--- END OF BLOCK #13 ---

	for neighbour_index, neighbour_data in pairs(new_room.neighbours[split_perp_neg_side])

	LOOP BLOCK #14
	GO OUT TO BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #14 315-320, warpins: 1 ---
	--- END OF BLOCK #14 ---

	slot26 = if self._rooms[neighbour_data.room].neighbours then
	JUMP TO BLOCK #15
	else
	JUMP TO BLOCK #16
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #15 321-347, warpins: 1 ---
	self:_update_neighbour_data(neighbour_data.room, i_room, nil, split_perp_pos_side)

	local new_data = {}
	new_data.room = i_new_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_append_neighbour(self._rooms[neighbour_data.room].neighbours[split_perp_pos_side], new_data, split_perp_pos_side)
	--- END OF BLOCK #15 ---

	FLOW; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #16 348-349, warpins: 3 ---
	--- END OF BLOCK #16 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #17 350-354, warpins: 1 ---
	--- END OF BLOCK #17 ---

	for neighbour_index, neighbour_data in pairs(new_room.neighbours[split_perp_pos_side])

	LOOP BLOCK #18
	GO OUT TO BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #18 355-360, warpins: 1 ---
	--- END OF BLOCK #18 ---

	slot26 = if self._rooms[neighbour_data.room].neighbours then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #20
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 361-387, warpins: 1 ---
	self:_update_neighbour_data(neighbour_data.room, i_room, nil, split_perp_neg_side)

	local new_data = {}
	new_data.room = i_new_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_append_neighbour(self._rooms[neighbour_data.room].neighbours[split_perp_neg_side], new_data, split_perp_neg_side)
	--- END OF BLOCK #19 ---

	FLOW; TARGET BLOCK #20



	-- Decompilation error in this vicinity:
	--- BLOCK #20 388-389, warpins: 3 ---
	--- END OF BLOCK #20 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #21 390-394, warpins: 1 ---
	--- END OF BLOCK #21 ---

	for neighbour_index, neighbour_data in pairs(room.neighbours[split_perp_neg_side])


	LOOP BLOCK #22
	GO OUT TO BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #22 395-411, warpins: 1 ---
	local new_data = {}
	new_data.room = i_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_update_neighbour_data(neighbour_data.room, i_room, new_data, split_perp_pos_side)
	--- END OF BLOCK #22 ---

	FLOW; TARGET BLOCK #23



	-- Decompilation error in this vicinity:
	--- BLOCK #23 412-413, warpins: 2 ---
	--- END OF BLOCK #23 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #24 414-418, warpins: 1 ---
	--- END OF BLOCK #24 ---

	for neighbour_index, neighbour_data in pairs(room.neighbours[split_perp_pos_side])


	LOOP BLOCK #25
	GO OUT TO BLOCK #27



	-- Decompilation error in this vicinity:
	--- BLOCK #25 419-435, warpins: 1 ---
	local new_data = {}
	new_data.room = i_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_update_neighbour_data(neighbour_data.room, i_room, new_data, split_perp_neg_side)
	--- END OF BLOCK #25 ---

	FLOW; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #26 436-437, warpins: 2 ---
	--- END OF BLOCK #26 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #27 438-442, warpins: 1 ---
	self:_add_room(new_room)

	return i_new_room
	--- END OF BLOCK #27 ---



end

function NavFieldBuilder:_create_empty_room()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-17, warpins: 1 ---
	local room = {}
	room.neighbours = {}
	room.expansion = {}
	room.borders = {}
	room.height = {}
	room.doors = {}
	room.expansion_segments = {}

	--- END OF BLOCK #0 ---

	for dir_str, perp_neg_dir_str in pairs(self._perp_neg_dir_str_map)


	LOOP BLOCK #1
	GO OUT TO BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #1 18-39, warpins: 1 ---
	room.expansion[dir_str] = {
		walls = {},
		spaces = {},
		stairs = {},
		cliffs = {},
		unsorted = {}
	}
	room.expansion_segments[dir_str] = {}
	room.neighbours[dir_str] = {}
	room.doors[dir_str] = {}

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 40-41, warpins: 2 ---
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #3 42-42, warpins: 1 ---
	return room
	--- END OF BLOCK #3 ---



end

function NavFieldBuilder:_cleanup_room_data()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	for i_room, room in ipairs(self._rooms)


	LOOP BLOCK #1
	GO OUT TO BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-15, warpins: 1 ---
	local clean_room = {}
	clean_room.doors = room.doors
	clean_room.borders = room.borders
	clean_room.height = room.height
	clean_room.segment = room.segment
	self._rooms[i_room] = clean_room

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 16-17, warpins: 2 ---
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #3 18-18, warpins: 1 ---
	return
	--- END OF BLOCK #3 ---



end

function NavFieldBuilder:_cleanup_room_data_1()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	for i_room, room in ipairs(self._rooms)


	LOOP BLOCK #1
	GO OUT TO BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-6, warpins: 1 ---
	room.segment = nil

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 7-8, warpins: 2 ---
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #3 9-9, warpins: 1 ---
	return
	--- END OF BLOCK #3 ---



end

function NavFieldBuilder:_calculate_door_heights()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	for i_door, door in ipairs(self._room_doors)


	LOOP BLOCK #1
	GO OUT TO BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-48, warpins: 1 ---
	local room_1 = self._rooms[door.rooms[1]]
	local room_2 = self._rooms[door.rooms[2]]
	local room_1_z = self._get_room_height_at_pos(room_1.height, room_1.borders, door.pos)
	local room_2_z = self._get_room_height_at_pos(room_2.height, room_2.borders, door.pos)
	door.pos = door.pos:with_z((room_1_z + room_2_z) * 0.5)
	room_1_z = self._get_room_height_at_pos(room_1.height, room_1.borders, door.pos1)
	room_2_z = self._get_room_height_at_pos(room_2.height, room_2.borders, door.pos1)
	door.pos1 = door.pos1:with_z((room_1_z + room_2_z) * 0.5)

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 49-50, warpins: 2 ---
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #3 51-51, warpins: 1 ---
	return
	--- END OF BLOCK #3 ---



end

function NavFieldBuilder:_calculate_geographic_segment_borders(i_seg)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-32, warpins: 1 ---
	local seg_borders = {}
	local nr_seg_x = self._nr_geog_segments.x
	local seg_offset = self._geog_segment_offset
	local seg_size = self._geog_segment_size
	local grid_coorids = {}
	grid_coorids[1] = 1 + (i_seg - 1) % nr_seg_x
	grid_coorids[MULTRES] = math.ceil(i_seg / nr_seg_x)
	seg_borders.x_pos = seg_offset.x + grid_coorids[1] * seg_size
	seg_borders.x_neg = seg_borders.x_pos - seg_size
	seg_borders.y_pos = seg_offset.y + grid_coorids[2] * seg_size
	seg_borders.y_neg = seg_borders.y_pos - seg_size

	return seg_borders
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_generate_geographic_segments()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-20, warpins: 1 ---
	self:_update_progress_bar(8, "Creating geographic segments")

	local tab_ins = table.insert
	local m_ceil = math.ceil
	local segments = {}
	self._geog_segments = segments
	local seg_size = self._geog_segment_size
	local level_limit_x_pos = -1000000
	local level_limit_x_neg = 1000000
	local level_limit_y_pos = -1000000
	local level_limit_y_neg = 1000000

	--- END OF BLOCK #0 ---

	for i_room, room in ipairs(self._rooms)


	LOOP BLOCK #1
	GO OUT TO BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #1 21-24, warpins: 1 ---
	local borders = room.borders
	--- END OF BLOCK #1 ---

	if level_limit_x_pos < borders.x_pos then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 25-25, warpins: 1 ---
	level_limit_x_pos = borders.x_pos
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 26-28, warpins: 2 ---
	--- END OF BLOCK #3 ---

	if borders.x_neg < level_limit_x_neg then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 29-29, warpins: 1 ---
	level_limit_x_neg = borders.x_neg
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 30-32, warpins: 2 ---
	--- END OF BLOCK #5 ---

	if level_limit_y_pos < borders.y_pos then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 33-33, warpins: 1 ---
	level_limit_y_pos = borders.y_pos
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 34-36, warpins: 2 ---
	--- END OF BLOCK #7 ---

	if borders.y_neg < level_limit_y_neg then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 37-37, warpins: 1 ---
	level_limit_y_neg = borders.y_neg
	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 38-39, warpins: 3 ---
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #10 40-66, warpins: 1 ---
	local safety_margin = 0
	level_limit_x_pos = level_limit_x_pos + safety_margin
	level_limit_x_neg = level_limit_x_neg - safety_margin
	level_limit_y_pos = level_limit_y_pos + safety_margin
	level_limit_y_neg = level_limit_y_neg - safety_margin
	self._geog_segment_offset = Vector3(level_limit_x_neg, level_limit_y_neg, 2000)
	local seg_offset = self._geog_segment_offset
	local nr_seg_x = math.ceil((level_limit_x_pos - level_limit_x_neg) / seg_size)
	local nr_seg_y = math.ceil((level_limit_y_pos - level_limit_y_neg) / seg_size)
	self._nr_geog_segments = {
		x = nr_seg_x,
		y = nr_seg_y
	}
	local i_seg = 1
	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 67-69, warpins: 2 ---
	--- END OF BLOCK #11 ---

	if i_seg <= nr_seg_x * nr_seg_y then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 70-70, warpins: 1 ---
	--- END OF BLOCK #12 ---

	FLOW; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #13 71-80, warpins: 1 ---
	local segment = {}
	local seg_borders = self:_calculate_geographic_segment_borders(i_seg)
	local nr_rooms = 0

	--- END OF BLOCK #13 ---

	for i_room, room in ipairs(self._rooms)


	LOOP BLOCK #14
	GO OUT TO BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #14 81-87, warpins: 1 ---
	local room_borders = room.borders

	--- END OF BLOCK #14 ---

	slot23 = if self._check_room_overlap_bool(seg_borders, room_borders)

	 then
	JUMP TO BLOCK #15
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #15 88-90, warpins: 1 ---
	--- END OF BLOCK #15 ---

	slot23 = if not segment.rooms then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 91-91, warpins: 1 ---
	slot23 = {}
	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 92-96, warpins: 2 ---
	segment.rooms = slot23
	segment.rooms[i_room] = true
	nr_rooms = nr_rooms + 1

	--- END OF BLOCK #17 ---

	FLOW; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #18 97-98, warpins: 3 ---
	--- END OF BLOCK #18 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #19 99-103, warpins: 1 ---
	--- END OF BLOCK #19 ---

	slot17 = if next(segment)

	 then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 104-104, warpins: 1 ---
	segments[i_seg] = segment
	--- END OF BLOCK #20 ---

	FLOW; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #21 105-106, warpins: 2 ---
	i_seg = i_seg + 1
	--- END OF BLOCK #21 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #22 107-107, warpins: 1 ---
	i_seg = nr_seg_x * nr_seg_y
	--- END OF BLOCK #22 ---

	FLOW; TARGET BLOCK #23



	-- Decompilation error in this vicinity:
	--- BLOCK #23 108-110, warpins: 2 ---
	--- END OF BLOCK #23 ---

	if i_seg > 0 then
	JUMP TO BLOCK #24
	else
	JUMP TO BLOCK #28
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #24 111-111, warpins: 1 ---
	--- END OF BLOCK #24 ---

	FLOW; TARGET BLOCK #25



	-- Decompilation error in this vicinity:
	--- BLOCK #25 112-114, warpins: 1 ---
	--- END OF BLOCK #25 ---

	if segments[i_seg] == false then
	JUMP TO BLOCK #26
	else
	JUMP TO BLOCK #27
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #26 115-116, warpins: 1 ---
	segments[i_seg] = nil
	--- END OF BLOCK #26 ---

	FLOW; TARGET BLOCK #27



	-- Decompilation error in this vicinity:
	--- BLOCK #27 117-118, warpins: 2 ---
	i_seg = i_seg - 1

	--- END OF BLOCK #27 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #23



	-- Decompilation error in this vicinity:
	--- BLOCK #28 119-119, warpins: 1 ---
	return
	--- END OF BLOCK #28 ---



end

function NavFieldBuilder:_round_pos_to_grid_center(pos)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-28, warpins: 1 ---
	local rounded_pos = Vector3()

	mvector3.set_z(rounded_pos, pos.z)

	local round_x = pos.x - pos.x % self._grid_size

	mvector3.set_x(rounded_pos, round_x)

	local round_y = pos.y - pos.y % self._grid_size

	mvector3.set_y(rounded_pos, round_y)

	return rounded_pos
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_add_room(room)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-3, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot2 = if not room.area then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 4-11, warpins: 1 ---
	debug_pause("[NavFieldBuilder:_add_room] missing area", inspect(room))

	room.area = 0

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 12-17, warpins: 2 ---
	table.insert(self._rooms, room)

	return
	--- END OF BLOCK #2 ---



end

function NavFieldBuilder:_trash_room(i_room)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-5, warpins: 1 ---
	local room = self._rooms[i_room]

	--- END OF BLOCK #0 ---

	slot3 = if room.doors then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 6-9, warpins: 1 ---
	--- END OF BLOCK #1 ---

	for side, door_list in pairs(room.doors)


	LOOP BLOCK #2
	GO OUT TO BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #2 10-15, warpins: 1 ---
	local opp_side = self._opposite_side_str[side]

	--- END OF BLOCK #2 ---

	for _, i_door in pairs(door_list)


	LOOP BLOCK #3
	GO OUT TO BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #3 16-21, warpins: 1 ---
	local door = self._room_doors[i_door]
	--- END OF BLOCK #3 ---

	if door.rooms[1] == i_room then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 22-25, warpins: 1 ---
	--- END OF BLOCK #4 ---

	slot15 = if not door.rooms[2] then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 26-27, warpins: 2 ---
	local i_neighbour = door.rooms[1]
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 28-35, warpins: 2 ---
	local neigh_doors = self._rooms[i_neighbour].doors[opp_side]

	--- END OF BLOCK #6 ---

	for neigh_door_index, i_neigh_door in pairs(neigh_doors)

	LOOP BLOCK #7
	GO OUT TO BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #7 36-37, warpins: 1 ---
	--- END OF BLOCK #7 ---

	if i_door == i_neigh_door then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 38-47, warpins: 1 ---
	table.remove(neigh_doors, neigh_door_index)
	self:_destroy_door(i_door)

	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #9 48-49, warpins: 2 ---
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #10 50-51, warpins: 3 ---
	--- END OF BLOCK #10 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #11 52-53, warpins: 2 ---
	--- END OF BLOCK #11 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #12 54-58, warpins: 2 ---
	room.trashed = true

	--- END OF BLOCK #12 ---

	slot3 = if room.neighbours then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 59-62, warpins: 1 ---
	--- END OF BLOCK #13 ---

	for side, neighbour_list in pairs(room.neighbours)


	LOOP BLOCK #14
	GO OUT TO BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #14 63-68, warpins: 1 ---
	local opp_side = self._opposite_side_str[side]

	--- END OF BLOCK #14 ---

	for i_neighbour, neighbour_data in pairs(neighbour_list)

	LOOP BLOCK #15
	GO OUT TO BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #15 69-75, warpins: 1 ---
	self:_update_neighbour_data(neighbour_data.room, i_room, nil, opp_side)
	--- END OF BLOCK #15 ---

	FLOW; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #16 76-77, warpins: 2 ---
	--- END OF BLOCK #16 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #17 78-79, warpins: 2 ---
	--- END OF BLOCK #17 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #18 80-83, warpins: 2 ---
	--- END OF BLOCK #18 ---

	for i_door, door in pairs(self._room_doors)


	LOOP BLOCK #19
	GO OUT TO BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #19 84-87, warpins: 1 ---
	--- END OF BLOCK #19 ---

	if i_room < door.rooms[1] then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 88-92, warpins: 1 ---
	door.rooms[1] = door.rooms[1] - 1
	--- END OF BLOCK #20 ---

	FLOW; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #21 93-96, warpins: 2 ---
	--- END OF BLOCK #21 ---

	if i_room < door.rooms[2] then
	JUMP TO BLOCK #22
	else
	JUMP TO BLOCK #23
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #22 97-101, warpins: 1 ---
	door.rooms[2] = door.rooms[2] - 1

	--- END OF BLOCK #22 ---

	FLOW; TARGET BLOCK #23



	-- Decompilation error in this vicinity:
	--- BLOCK #23 102-103, warpins: 3 ---
	--- END OF BLOCK #23 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #24 104-104, warpins: 1 ---
	return
	--- END OF BLOCK #24 ---



end

function NavFieldBuilder:_destroy_room(i_room)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-9, warpins: 1 ---
	table.remove(self._rooms, i_room)
	--- END OF BLOCK #0 ---

	for i_test_room, test_room in ipairs(self._rooms)

	LOOP BLOCK #1
	GO OUT TO BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #1 10-12, warpins: 1 ---
	--- END OF BLOCK #1 ---

	slot7 = if not test_room.trashed then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 13-15, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot7 = if test_room.neighbours then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 16-19, warpins: 1 ---
	--- END OF BLOCK #3 ---

	for side, neighbour_list in pairs(test_room.neighbours)

	LOOP BLOCK #4
	GO OUT TO BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #4 20-23, warpins: 1 ---
	--- END OF BLOCK #4 ---

	for i_neighbour, neighbour_data in pairs(neighbour_list)


	LOOP BLOCK #5
	GO OUT TO BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #5 24-26, warpins: 1 ---
	--- END OF BLOCK #5 ---

	if i_room < neighbour_data.room then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 27-29, warpins: 1 ---
	neighbour_data.room = neighbour_data.room - 1

	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 30-31, warpins: 3 ---
	--- END OF BLOCK #7 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #8 32-33, warpins: 2 ---
	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #9 34-35, warpins: 4 ---
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #10 36-36, warpins: 1 ---
	return
	--- END OF BLOCK #10 ---



end

function NavFieldBuilder:_add_door(door)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-8, warpins: 1 ---
	table.insert(self._room_doors, door)

	return #self._room_doors
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_destroy_door(i_door)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-9, warpins: 1 ---
	table.remove(self._room_doors, i_door)
	--- END OF BLOCK #0 ---

	for i_room, room in ipairs(self._rooms)

	LOOP BLOCK #1
	GO OUT TO BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #1 10-13, warpins: 1 ---
	--- END OF BLOCK #1 ---

	for side, door_list in pairs(room.doors)

	LOOP BLOCK #2
	GO OUT TO BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #2 14-17, warpins: 1 ---
	--- END OF BLOCK #2 ---

	for door_index, i_test_door in pairs(door_list)


	LOOP BLOCK #3
	GO OUT TO BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #3 18-19, warpins: 1 ---
	--- END OF BLOCK #3 ---

	if i_door < i_test_door then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 20-21, warpins: 1 ---
	door_list[door_index] = i_test_door - 1

	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 22-23, warpins: 3 ---
	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #6 24-25, warpins: 2 ---
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #7 26-27, warpins: 2 ---
	--- END OF BLOCK #7 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #8 28-28, warpins: 1 ---
	return
	--- END OF BLOCK #8 ---



end

function NavFieldBuilder:_analyse_room(enter_dir_str, enter_pos)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-46, warpins: 1 ---
	local opp_dir_str_map = self._opposite_side_str
	local perp_pos_dir_str_map = self._perp_pos_dir_str_map
	local perp_neg_dir_str_map = self._perp_neg_dir_str_map
	local neg_dir_str_map = self._neg_dir_str_map
	local x_dir_str_map = self._x_dir_str_map
	local dir_vec_map = self._dir_str_to_vec
	local room = {}
	room.neighbours = {}
	local expansion = {}
	room.expansion = expansion
	local borders = {}
	room.borders = borders
	local height = {}
	room.height = height
	local expandable_sides_map = {}
	room.inclination = {}
	local expansion_segments = {}
	room.expansion_segments = expansion_segments
	room.doors = {}
	borders.x_pos = enter_pos.x + self._grid_size * 0.5
	borders.x_neg = enter_pos.x - self._grid_size * 0.5
	borders.y_pos = enter_pos.y + self._grid_size * 0.5
	borders.y_neg = enter_pos.y - self._grid_size * 0.5

	--- END OF BLOCK #0 ---

	for dir_str, perp_neg_dir_str in pairs(perp_neg_dir_str_map)


	LOOP BLOCK #1
	GO OUT TO BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #1 47-69, warpins: 1 ---
	room.expansion[dir_str] = {
		walls = {},
		spaces = {},
		stairs = {},
		cliffs = {},
		unsorted = {}
	}
	expansion_segments[dir_str] = {}
	expandable_sides_map[dir_str] = true
	room.neighbours[dir_str] = {}
	room.doors[dir_str] = {}

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 70-71, warpins: 2 ---
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #3 72-116, warpins: 1 ---
	self:_measure_init_room_expansion(room, enter_pos)

	local expanding_side = enter_dir_str
	local i_room = #self._rooms + 1

	self:_expand_room_borders(expanding_side, room, expandable_sides_map, i_room)
	self:_fill_room_expansion_segments(room.expansion, expansion_segments, room.neighbours)
	self:_find_room_height_from_expansion(expansion, height, "x_pos")

	room.area = self:_calc_room_area(borders)
	room.segment = self._building.id

	self:_add_room(room)
	--- END OF BLOCK #3 ---

	slot17 = if managers.navigation._draw_data then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 117-123, warpins: 1 ---
	managers.navigation:_draw_room(room, true)

	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 124-124, warpins: 2 ---
	return i_room
	--- END OF BLOCK #5 ---



end

function NavFieldBuilder:_fill_room_expansion_segments(expansion, expansion_segments, neighbours)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	for side, obs_types in pairs(expansion)


	LOOP BLOCK #1
	GO OUT TO BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-10, warpins: 1 ---
	local perp_dim = self._perp_dim_str_map[side]

	--- END OF BLOCK #1 ---

	for i_seg, segment in pairs(obs_types.spaces)

	LOOP BLOCK #2
	GO OUT TO BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #2 11-19, warpins: 1 ---
	table.insert(expansion_segments[side], {
		segment[1],
		segment[2]
	})
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 20-21, warpins: 2 ---
	--- END OF BLOCK #3 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #4 22-25, warpins: 1 ---
	--- END OF BLOCK #4 ---

	for i_seg, segment in pairs(obs_types.stairs)

	LOOP BLOCK #5
	GO OUT TO BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #5 26-34, warpins: 1 ---
	table.insert(expansion_segments[side], {
		segment[1],
		segment[2]
	})
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 35-36, warpins: 2 ---
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #7 37-40, warpins: 1 ---
	--- END OF BLOCK #7 ---

	for i_neighbour, neighbour_data in pairs(neighbours[side])


	LOOP BLOCK #8
	GO OUT TO BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #8 41-47, warpins: 1 ---
	expansion_segments[side] = self:_remove_seg_from_seg_list(expansion_segments[side], neighbour_data.overlap, perp_dim)

	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 48-49, warpins: 2 ---
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #10 50-51, warpins: 2 ---
	--- END OF BLOCK #10 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #11 52-52, warpins: 1 ---
	return
	--- END OF BLOCK #11 ---



end

function NavFieldBuilder:_create_room_doors(i_room)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local room = self._rooms[i_room]
	local neighbours = room.neighbours

	--- END OF BLOCK #0 ---

	for side, neightbour_list in pairs(neighbours)


	LOOP BLOCK #1
	GO OUT TO BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #1 8-12, warpins: 1 ---
	slot9 = room.doors
	--- END OF BLOCK #1 ---

	slot10 = if not room.doors[side] then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 13-13, warpins: 1 ---
	slot10 = {}
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 14-18, warpins: 2 ---
	slot9[side] = slot10

	--- END OF BLOCK #3 ---

	for neighbour_index, neightbour_data in pairs(neightbour_list)


	LOOP BLOCK #4
	GO OUT TO BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #4 19-27, warpins: 1 ---
	local i_neighbour = neightbour_data.room
	local line = neightbour_data.overlap
	local neighbour_room = self._rooms[i_neighbour]
	local door = {}
	--- END OF BLOCK #4 ---

	slot18 = if self._neg_dir_str_map[side] then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 28-32, warpins: 1 ---
	door.rooms = {
		i_neighbour,
		i_room
	}
	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #6 33-36, warpins: 1 ---
	door.rooms = {
		i_room,
		i_neighbour
	}
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 37-70, warpins: 2 ---
	door.pos = neightbour_data.overlap[1]
	door.pos1 = neightbour_data.overlap[2]
	door.center = (door.pos + door.pos1) * 0.5
	local i_door = self:_add_door(door)

	table.insert(room.doors[side], i_door)
	table.insert(neighbour_room.doors[self._opposite_side_str[side]], i_door)
	--- END OF BLOCK #7 ---

	slot19 = if self._rooms[i_neighbour].neighbours then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 71-76, warpins: 1 ---
	--- END OF BLOCK #8 ---

	for _, neighbours_neighbour_list in pairs(self._rooms[i_neighbour].neighbours)

	LOOP BLOCK #9
	GO OUT TO BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #9 77-80, warpins: 1 ---
	--- END OF BLOCK #9 ---

	for i_n, neighbours_neighbour_data in pairs(neighbours_neighbour_list)

	LOOP BLOCK #10
	GO OUT TO BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #10 81-83, warpins: 1 ---
	--- END OF BLOCK #10 ---

	if neighbours_neighbour_data.room == i_room then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 84-89, warpins: 1 ---
	table.remove(neighbours_neighbour_list, i_n)

	--- END OF BLOCK #11 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #12 90-91, warpins: 2 ---
	--- END OF BLOCK #12 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #13 92-93, warpins: 3 ---
	--- END OF BLOCK #13 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #14 94-95, warpins: 3 ---
	--- END OF BLOCK #14 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #15 96-97, warpins: 2 ---
	--- END OF BLOCK #15 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #16 98-98, warpins: 1 ---
	return
	--- END OF BLOCK #16 ---



end

function NavFieldBuilder:_expand_room_borders(expanding_side, room, expandable_sides_map, i_room)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-9, warpins: 1 ---
	local opp_dir_str_map = self._opposite_side_str
	local perp_pos_dir_str_map = self._perp_pos_dir_str_map
	local perp_neg_dir_str_map = self._perp_neg_dir_str_map
	local neg_dir_str_map = self._neg_dir_str_map
	local x_dir_str_map = self._x_dir_str_map
	local dir_vec_map = self._dir_str_to_vec
	local borders = room.borders
	local expansion = room.expansion
	local neighbours = room.neighbours
	--- END OF BLOCK #0 ---

	FLOW; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #1 10-11, warpins: 20 ---
	--- END OF BLOCK #1 ---

	slot1 = if expanding_side then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #91
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 12-12, warpins: 1 ---
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 13-17, warpins: 1 ---
	local dir_str = expanding_side
	local exp_data = expansion[dir_str]
	--- END OF BLOCK #3 ---

	slot16 = if exp_data.unsorted then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 18-21, warpins: 1 ---
	--- END OF BLOCK #4 ---

	slot16 = if not exp_data.unsorted[1] then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 22-23, warpins: 2 ---
	local unsorted_space = exp_data.spaces[1]

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 24-25, warpins: 2 ---
	--- END OF BLOCK #6 ---

	slot16 = if not unsorted_space then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 26-26, warpins: 1 ---
	return

	--- END OF BLOCK #7 ---

	FLOW; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #8 27-45, warpins: 2 ---
	exp_data.unsorted = nil
	local opp_dir_str = opp_dir_str_map[dir_str]
	local perp_pos_dir_str = perp_pos_dir_str_map[dir_str]
	local perp_neg_dir_str = perp_neg_dir_str_map[dir_str]
	local dir_vec = dir_vec_map[dir_str]
	local expand_dim = self._dim_str_map[dir_str]
	local along_dim = self._perp_dim_str_map[dir_str]
	local res_expansion, expansion_blocked = self:_expansion_check_obstacles(dir_str, dir_vec, unsorted_space, room.inclination)
	--- END OF BLOCK #8 ---

	slot24 = if expansion_blocked then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #25
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 46-53, warpins: 1 ---
	expansion[dir_str] = res_expansion
	local new_neighbours = self:_expansion_check_neighbours(dir_str, unsorted_space)
	--- END OF BLOCK #9 ---

	slot25 = if new_neighbours then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #16
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 54-58, warpins: 1 ---
	neighbours[dir_str] = new_neighbours

	--- END OF BLOCK #10 ---

	for _, neighbour_data in pairs(new_neighbours)


	LOOP BLOCK #11
	GO OUT TO BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #11 59-64, warpins: 1 ---
	local neighbour = self._rooms[neighbour_data.room]
	--- END OF BLOCK #11 ---

	slot32 = if neighbour.expansion_segments then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #13
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 65-73, warpins: 1 ---
	neighbour.expansion_segments[opp_dir_str] = self:_remove_seg_from_seg_list(neighbour.expansion_segments[opp_dir_str], neighbour_data.overlap, along_dim)
	--- END OF BLOCK #12 ---

	FLOW; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #13 74-76, warpins: 2 ---
	--- END OF BLOCK #13 ---

	slot32 = if neighbour.neighbours then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 77-93, warpins: 1 ---
	local new_data = {}
	new_data.room = i_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_append_neighbour(neighbour.neighbours[opp_dir_str], new_data, opp_dir_str)

	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 94-95, warpins: 3 ---
	--- END OF BLOCK #15 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #16 96-100, warpins: 2 ---
	expandable_sides_map[dir_str] = nil
	--- END OF BLOCK #16 ---

	slot26 = if expandable_sides_map[opp_dir_str] then
	JUMP TO BLOCK #17
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #17 101-102, warpins: 1 ---
	expanding_side = opp_dir_str
	--- END OF BLOCK #17 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #18 103-105, warpins: 1 ---
	--- END OF BLOCK #18 ---

	slot26 = if expandable_sides_map[perp_neg_dir_str] then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 106-112, warpins: 1 ---
	local is_too_long, is_longest = self:_chk_room_side_too_long(borders, perp_neg_dir_str)
	--- END OF BLOCK #19 ---

	slot26 = if not is_too_long then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #1
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 113-114, warpins: 1 ---
	expanding_side = perp_neg_dir_str
	--- END OF BLOCK #20 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #21 115-117, warpins: 1 ---
	--- END OF BLOCK #21 ---

	slot26 = if expandable_sides_map[perp_pos_dir_str] then
	JUMP TO BLOCK #22
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #22 118-124, warpins: 1 ---
	local is_too_long, is_longest = self:_chk_room_side_too_long(borders, perp_pos_dir_str)
	--- END OF BLOCK #22 ---

	slot26 = if not is_too_long then
	JUMP TO BLOCK #23
	else
	JUMP TO BLOCK #1
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #23 125-126, warpins: 1 ---
	expanding_side = perp_pos_dir_str
	--- END OF BLOCK #23 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #24 127-128, warpins: 1 ---
	expanding_side = nil
	--- END OF BLOCK #24 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #25 129-142, warpins: 1 ---
	local old_border = borders[dir_str]
	local new_border = self:_calculate_expanded_border(dir_str, old_border, self._grid_size)
	local new_neighbours = self:_expansion_check_neighbours(dir_str, unsorted_space)
	--- END OF BLOCK #25 ---

	slot27 = if new_neighbours then
	JUMP TO BLOCK #26
	else
	JUMP TO BLOCK #32
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #26 143-149, warpins: 1 ---
	neighbours[dir_str] = new_neighbours
	expandable_sides_map[dir_str] = nil

	--- END OF BLOCK #26 ---

	for _, neighbour_data in pairs(new_neighbours)


	LOOP BLOCK #27
	GO OUT TO BLOCK #32



	-- Decompilation error in this vicinity:
	--- BLOCK #27 150-155, warpins: 1 ---
	local neighbour = self._rooms[neighbour_data.room]
	--- END OF BLOCK #27 ---

	slot34 = if neighbour.expansion_segments then
	JUMP TO BLOCK #28
	else
	JUMP TO BLOCK #29
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #28 156-164, warpins: 1 ---
	neighbour.expansion_segments[opp_dir_str] = self:_remove_seg_from_seg_list(neighbour.expansion_segments[opp_dir_str], neighbour_data.overlap, along_dim)
	--- END OF BLOCK #28 ---

	FLOW; TARGET BLOCK #29



	-- Decompilation error in this vicinity:
	--- BLOCK #29 165-167, warpins: 2 ---
	--- END OF BLOCK #29 ---

	slot34 = if neighbour.neighbours then
	JUMP TO BLOCK #30
	else
	JUMP TO BLOCK #31
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #30 168-184, warpins: 1 ---
	local new_data = {}
	new_data.room = i_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_append_neighbour(neighbour.neighbours[opp_dir_str], new_data, opp_dir_str)
	--- END OF BLOCK #30 ---

	FLOW; TARGET BLOCK #31



	-- Decompilation error in this vicinity:
	--- BLOCK #31 185-186, warpins: 3 ---
	--- END OF BLOCK #31 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #32 187-188, warpins: 2 ---
	--- END OF BLOCK #32 ---

	slot27 = if not new_neighbours then
	JUMP TO BLOCK #33
	else
	JUMP TO BLOCK #38
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #33 189-192, warpins: 1 ---
	--- END OF BLOCK #33 ---

	for obstacle_type, obstacle_segments in pairs(res_expansion)

	LOOP BLOCK #34
	GO OUT TO BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #34 193-196, warpins: 1 ---
	--- END OF BLOCK #34 ---

	for i_obs_seg, obstacle_segment in pairs(obstacle_segments)

	LOOP BLOCK #35
	GO OUT TO BLOCK #37



	-- Decompilation error in this vicinity:
	--- BLOCK #35 197-212, warpins: 1 ---
	mvector3["set_" .. expand_dim](obstacle_segment[1], new_border)
	mvector3["set_" .. expand_dim](obstacle_segment[2], new_border)

	--- END OF BLOCK #35 ---

	FLOW; TARGET BLOCK #36



	-- Decompilation error in this vicinity:
	--- BLOCK #36 213-214, warpins: 2 ---
	--- END OF BLOCK #36 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #34



	-- Decompilation error in this vicinity:
	--- BLOCK #37 215-216, warpins: 2 ---
	--- END OF BLOCK #37 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #33



	-- Decompilation error in this vicinity:
	--- BLOCK #38 217-218, warpins: 2 ---
	--- END OF BLOCK #38 ---

	slot27 = if new_neighbours then
	JUMP TO BLOCK #39
	else
	JUMP TO BLOCK #40
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #39 219-220, warpins: 1 ---
	expansion[dir_str] = res_expansion
	--- END OF BLOCK #39 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #41



	-- Decompilation error in this vicinity:
	--- BLOCK #40 221-223, warpins: 1 ---
	expansion[dir_str].unsorted = res_expansion.spaces
	--- END OF BLOCK #40 ---

	FLOW; TARGET BLOCK #41



	-- Decompilation error in this vicinity:
	--- BLOCK #41 224-225, warpins: 2 ---
	--- END OF BLOCK #41 ---

	slot27 = if not new_neighbours then
	JUMP TO BLOCK #42
	else
	JUMP TO BLOCK #70
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #42 226-289, warpins: 1 ---
	borders[dir_str] = new_border
	local perp_neg_space = {}
	perp_neg_space[1] = Vector3()
	perp_neg_space[MULTRES] = Vector3()

	mvector3["set_" .. along_dim](perp_neg_space[1], borders[perp_neg_dir_str])
	mvector3["set_" .. along_dim](perp_neg_space[2], borders[perp_neg_dir_str])
	mvector3["set_" .. expand_dim](perp_neg_space[1], math.min(borders[dir_str], old_border))
	mvector3["set_" .. expand_dim](perp_neg_space[2], math.max(borders[dir_str], old_border))
	mvector3.set_z(perp_neg_space[1], unsorted_space[1].z)
	mvector3.set_z(perp_neg_space[2], unsorted_space[1].z)

	local perp_expansion = expansion[perp_neg_dir_str]

	--- END OF BLOCK #42 ---

	slot30 = if perp_expansion.unsorted then
	JUMP TO BLOCK #43
	else
	JUMP TO BLOCK #44
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #43 290-296, warpins: 1 ---
	self:_append_seg_to_seg_list(perp_expansion.unsorted, perp_neg_space, expand_dim)

	--- END OF BLOCK #43 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #56



	-- Decompilation error in this vicinity:
	--- BLOCK #44 297-307, warpins: 1 ---
	local res_expansion, expansion_blocked = self:_expansion_check_obstacles(perp_neg_dir_str, dir_vec_map[perp_neg_dir_str], perp_neg_space, room.inclination)

	--- END OF BLOCK #44 ---

	for obstacle_type, obstacle_segments in pairs(res_expansion)

	LOOP BLOCK #45
	GO OUT TO BLOCK #49



	-- Decompilation error in this vicinity:
	--- BLOCK #45 308-311, warpins: 1 ---
	--- END OF BLOCK #45 ---

	for i_obs_seg, obstacle_segment in pairs(obstacle_segments)

	LOOP BLOCK #46
	GO OUT TO BLOCK #48



	-- Decompilation error in this vicinity:
	--- BLOCK #46 312-317, warpins: 1 ---
	self:_append_seg_to_seg_list(perp_expansion[obstacle_type], obstacle_segment, expand_dim)

	--- END OF BLOCK #46 ---

	FLOW; TARGET BLOCK #47



	-- Decompilation error in this vicinity:
	--- BLOCK #47 318-319, warpins: 2 ---
	--- END OF BLOCK #47 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #45



	-- Decompilation error in this vicinity:
	--- BLOCK #48 320-321, warpins: 2 ---
	--- END OF BLOCK #48 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #44



	-- Decompilation error in this vicinity:
	--- BLOCK #49 322-323, warpins: 1 ---
	--- END OF BLOCK #49 ---

	slot31 = if expansion_blocked then
	JUMP TO BLOCK #50
	else
	JUMP TO BLOCK #51
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #50 324-325, warpins: 1 ---
	expandable_sides_map[perp_neg_dir_str] = nil
	--- END OF BLOCK #50 ---

	FLOW; TARGET BLOCK #51



	-- Decompilation error in this vicinity:
	--- BLOCK #51 326-332, warpins: 2 ---
	local new_neighbours = self:_expansion_check_neighbours(perp_neg_dir_str, perp_neg_space)

	--- END OF BLOCK #51 ---

	slot32 = if new_neighbours then
	JUMP TO BLOCK #52
	else
	JUMP TO BLOCK #56
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #52 333-345, warpins: 1 ---
	self:_append_neighbour(neighbours[perp_neg_dir_str], new_neighbours[1], perp_neg_dir_str)

	local neighbour = self._rooms[new_neighbours[1].room]
	--- END OF BLOCK #52 ---

	slot34 = if neighbour.expansion_segments then
	JUMP TO BLOCK #53
	else
	JUMP TO BLOCK #54
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #53 346-355, warpins: 1 ---
	neighbour.expansion_segments[perp_pos_dir_str] = self:_remove_seg_from_seg_list(neighbour.expansion_segments[perp_pos_dir_str], new_neighbours[1].overlap, expand_dim)
	--- END OF BLOCK #53 ---

	FLOW; TARGET BLOCK #54



	-- Decompilation error in this vicinity:
	--- BLOCK #54 356-358, warpins: 2 ---
	--- END OF BLOCK #54 ---

	slot34 = if neighbour.neighbours then
	JUMP TO BLOCK #55
	else
	JUMP TO BLOCK #56
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #55 359-377, warpins: 1 ---
	local new_data = {}
	new_data.room = i_room
	new_data.overlap = {
		new_neighbours[1].overlap[1],
		new_neighbours[1].overlap[2]
	}

	self:_append_neighbour(neighbour.neighbours[perp_pos_dir_str], new_data, perp_pos_dir_str)

	--- END OF BLOCK #55 ---

	FLOW; TARGET BLOCK #56



	-- Decompilation error in this vicinity:
	--- BLOCK #56 378-440, warpins: 4 ---
	local perp_pos_space = {}
	perp_pos_space[1] = Vector3()
	perp_pos_space[MULTRES] = Vector3()

	mvector3["set_" .. along_dim](perp_pos_space[1], borders[perp_pos_dir_str])
	mvector3["set_" .. along_dim](perp_pos_space[2], borders[perp_pos_dir_str])
	mvector3["set_" .. expand_dim](perp_pos_space[1], math.min(borders[dir_str], old_border))
	mvector3["set_" .. expand_dim](perp_pos_space[2], math.max(borders[dir_str], old_border))
	mvector3.set_z(perp_pos_space[1], unsorted_space[2].z)
	mvector3.set_z(perp_pos_space[2], unsorted_space[2].z)

	local perp_expansion = expansion[perp_pos_dir_str]

	--- END OF BLOCK #56 ---

	slot32 = if perp_expansion.unsorted then
	JUMP TO BLOCK #57
	else
	JUMP TO BLOCK #58
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #57 441-447, warpins: 1 ---
	self:_append_seg_to_seg_list(perp_expansion.unsorted, perp_pos_space, expand_dim)

	--- END OF BLOCK #57 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #70



	-- Decompilation error in this vicinity:
	--- BLOCK #58 448-458, warpins: 1 ---
	local res_expansion, expansion_blocked = self:_expansion_check_obstacles(perp_pos_dir_str, dir_vec_map[perp_pos_dir_str], perp_pos_space, room.inclination)

	--- END OF BLOCK #58 ---

	for obstacle_type, obstacle_segments in pairs(res_expansion)

	LOOP BLOCK #59
	GO OUT TO BLOCK #63



	-- Decompilation error in this vicinity:
	--- BLOCK #59 459-462, warpins: 1 ---
	--- END OF BLOCK #59 ---

	for i_obs_seg, obstacle_segment in pairs(obstacle_segments)

	LOOP BLOCK #60
	GO OUT TO BLOCK #62



	-- Decompilation error in this vicinity:
	--- BLOCK #60 463-468, warpins: 1 ---
	self:_append_seg_to_seg_list(perp_expansion[obstacle_type], obstacle_segment, expand_dim)

	--- END OF BLOCK #60 ---

	FLOW; TARGET BLOCK #61



	-- Decompilation error in this vicinity:
	--- BLOCK #61 469-470, warpins: 2 ---
	--- END OF BLOCK #61 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #59



	-- Decompilation error in this vicinity:
	--- BLOCK #62 471-472, warpins: 2 ---
	--- END OF BLOCK #62 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #58



	-- Decompilation error in this vicinity:
	--- BLOCK #63 473-474, warpins: 1 ---
	--- END OF BLOCK #63 ---

	slot33 = if expansion_blocked then
	JUMP TO BLOCK #64
	else
	JUMP TO BLOCK #65
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #64 475-476, warpins: 1 ---
	expandable_sides_map[perp_pos_dir_str] = nil
	--- END OF BLOCK #64 ---

	FLOW; TARGET BLOCK #65



	-- Decompilation error in this vicinity:
	--- BLOCK #65 477-483, warpins: 2 ---
	local new_neighbours = self:_expansion_check_neighbours(perp_pos_dir_str, perp_pos_space)

	--- END OF BLOCK #65 ---

	slot34 = if new_neighbours then
	JUMP TO BLOCK #66
	else
	JUMP TO BLOCK #70
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #66 484-496, warpins: 1 ---
	self:_append_neighbour(neighbours[perp_pos_dir_str], new_neighbours[1], perp_pos_dir_str)

	local neighbour = self._rooms[new_neighbours[1].room]
	--- END OF BLOCK #66 ---

	slot36 = if neighbour.expansion_segments then
	JUMP TO BLOCK #67
	else
	JUMP TO BLOCK #68
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #67 497-506, warpins: 1 ---
	neighbour.expansion_segments[perp_neg_dir_str] = self:_remove_seg_from_seg_list(neighbour.expansion_segments[perp_neg_dir_str], new_neighbours[1].overlap, expand_dim)
	--- END OF BLOCK #67 ---

	FLOW; TARGET BLOCK #68



	-- Decompilation error in this vicinity:
	--- BLOCK #68 507-509, warpins: 2 ---
	--- END OF BLOCK #68 ---

	slot36 = if neighbour.neighbours then
	JUMP TO BLOCK #69
	else
	JUMP TO BLOCK #70
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #69 510-528, warpins: 1 ---
	local new_data = {}
	new_data.room = i_room
	new_data.overlap = {
		new_neighbours[1].overlap[1],
		new_neighbours[1].overlap[2]
	}

	self:_append_neighbour(neighbour.neighbours[perp_neg_dir_str], new_data, perp_neg_dir_str)

	--- END OF BLOCK #69 ---

	FLOW; TARGET BLOCK #70



	-- Decompilation error in this vicinity:
	--- BLOCK #70 529-530, warpins: 5 ---
	--- END OF BLOCK #70 ---

	slot27 = if new_neighbours then
	JUMP TO BLOCK #71
	else
	JUMP TO BLOCK #80
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #71 531-533, warpins: 1 ---
	--- END OF BLOCK #71 ---

	slot28 = if expandable_sides_map[opp_dir_str] then
	JUMP TO BLOCK #72
	else
	JUMP TO BLOCK #73
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #72 534-535, warpins: 1 ---
	expanding_side = opp_dir_str
	--- END OF BLOCK #72 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #73 536-538, warpins: 1 ---
	--- END OF BLOCK #73 ---

	slot28 = if expandable_sides_map[perp_neg_dir_str] then
	JUMP TO BLOCK #74
	else
	JUMP TO BLOCK #76
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #74 539-545, warpins: 1 ---
	local is_too_long, is_longest = self:_chk_room_side_too_long(borders, perp_neg_dir_str)
	--- END OF BLOCK #74 ---

	slot28 = if not is_too_long then
	JUMP TO BLOCK #75
	else
	JUMP TO BLOCK #1
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #75 546-547, warpins: 1 ---
	expanding_side = perp_neg_dir_str
	--- END OF BLOCK #75 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #76 548-550, warpins: 1 ---
	--- END OF BLOCK #76 ---

	slot28 = if expandable_sides_map[perp_pos_dir_str] then
	JUMP TO BLOCK #77
	else
	JUMP TO BLOCK #79
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #77 551-557, warpins: 1 ---
	local is_too_long, is_longest = self:_chk_room_side_too_long(borders, perp_pos_dir_str)
	--- END OF BLOCK #77 ---

	slot28 = if not is_too_long then
	JUMP TO BLOCK #78
	else
	JUMP TO BLOCK #1
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #78 558-559, warpins: 1 ---
	expanding_side = perp_pos_dir_str
	--- END OF BLOCK #78 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #79 560-561, warpins: 1 ---
	expanding_side = nil
	--- END OF BLOCK #79 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #80 562-568, warpins: 1 ---
	local is_too_long, is_longest = self:_chk_room_side_too_long(borders, dir_str)
	--- END OF BLOCK #80 ---

	slot28 = if is_too_long then
	JUMP TO BLOCK #81
	else
	JUMP TO BLOCK #86
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #81 569-571, warpins: 1 ---
	--- END OF BLOCK #81 ---

	slot30 = if expandable_sides_map[perp_neg_dir_str] then
	JUMP TO BLOCK #82
	else
	JUMP TO BLOCK #83
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #82 572-573, warpins: 1 ---
	expanding_side = perp_neg_dir_str
	--- END OF BLOCK #82 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #83 574-576, warpins: 1 ---
	--- END OF BLOCK #83 ---

	slot30 = if expandable_sides_map[perp_pos_dir_str] then
	JUMP TO BLOCK #84
	else
	JUMP TO BLOCK #85
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #84 577-578, warpins: 1 ---
	expanding_side = perp_pos_dir_str
	--- END OF BLOCK #84 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #85 579-580, warpins: 1 ---
	expanding_side = nil
	--- END OF BLOCK #85 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #86 581-582, warpins: 1 ---
	--- END OF BLOCK #86 ---

	slot29 = if is_longest then
	JUMP TO BLOCK #87
	else
	JUMP TO BLOCK #1
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #87 583-585, warpins: 1 ---
	--- END OF BLOCK #87 ---

	slot30 = if expandable_sides_map[perp_neg_dir_str] then
	JUMP TO BLOCK #88
	else
	JUMP TO BLOCK #89
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #88 586-587, warpins: 1 ---
	expanding_side = perp_neg_dir_str
	--- END OF BLOCK #88 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #89 588-590, warpins: 1 ---
	--- END OF BLOCK #89 ---

	slot30 = if expandable_sides_map[perp_pos_dir_str] then
	JUMP TO BLOCK #90
	else
	JUMP TO BLOCK #1
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #90 591-592, warpins: 1 ---
	expanding_side = perp_pos_dir_str

	--- END OF BLOCK #90 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #91 593-596, warpins: 1 ---
	--- END OF BLOCK #91 ---

	for dir_str, _ in pairs(expandable_sides_map)

	LOOP BLOCK #92
	GO OUT TO BLOCK #103



	-- Decompilation error in this vicinity:
	--- BLOCK #92 597-600, warpins: 1 ---
	--- END OF BLOCK #92 ---

	slot19 = if expansion[dir_str].unsorted then
	JUMP TO BLOCK #93
	else
	JUMP TO BLOCK #102
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #93 601-608, warpins: 1 ---
	--- END OF BLOCK #93 ---

	if table.size(expansion[dir_str].unsorted)

	 > 0 then
	JUMP TO BLOCK #94
	else
	JUMP TO BLOCK #102
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #94 609-626, warpins: 1 ---
	local expand_seg = expansion[dir_str].unsorted[1]
	local res_expansion, expansion_blocked = self:_expansion_check_obstacles(dir_str, dir_vec_map[dir_str], expand_seg, room.inclination)
	expansion[dir_str] = res_expansion
	local new_neighbours = self:_expansion_check_neighbours(dir_str, expand_seg)
	--- END OF BLOCK #94 ---

	slot22 = if new_neighbours then
	JUMP TO BLOCK #95
	else
	JUMP TO BLOCK #101
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #95 627-631, warpins: 1 ---
	neighbours[dir_str] = new_neighbours

	--- END OF BLOCK #95 ---

	for _, neighbour_data in pairs(new_neighbours)


	LOOP BLOCK #96
	GO OUT TO BLOCK #101



	-- Decompilation error in this vicinity:
	--- BLOCK #96 632-637, warpins: 1 ---
	local neighbour = self._rooms[neighbour_data.room]
	--- END OF BLOCK #96 ---

	slot29 = if neighbour.expansion_segments then
	JUMP TO BLOCK #97
	else
	JUMP TO BLOCK #98
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #97 638-649, warpins: 1 ---
	neighbour.expansion_segments[opp_dir_str_map[dir_str]] = self:_remove_seg_from_seg_list(neighbour.expansion_segments[opp_dir_str_map[dir_str]], neighbour_data.overlap, self._perp_dim_str_map[dir_str])
	--- END OF BLOCK #97 ---

	FLOW; TARGET BLOCK #98



	-- Decompilation error in this vicinity:
	--- BLOCK #98 650-652, warpins: 2 ---
	--- END OF BLOCK #98 ---

	slot29 = if neighbour.neighbours then
	JUMP TO BLOCK #99
	else
	JUMP TO BLOCK #100
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #99 653-670, warpins: 1 ---
	local new_data = {}
	new_data.room = i_room
	new_data.overlap = {
		neighbour_data.overlap[1],
		neighbour_data.overlap[2]
	}

	self:_append_neighbour(neighbour.neighbours[opp_dir_str_map[dir_str]], new_data, opp_dir_str_map[dir_str])

	--- END OF BLOCK #99 ---

	FLOW; TARGET BLOCK #100



	-- Decompilation error in this vicinity:
	--- BLOCK #100 671-672, warpins: 3 ---
	--- END OF BLOCK #100 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #95



	-- Decompilation error in this vicinity:
	--- BLOCK #101 673-675, warpins: 2 ---
	expansion[dir_str].unsorted = nil

	--- END OF BLOCK #101 ---

	FLOW; TARGET BLOCK #102



	-- Decompilation error in this vicinity:
	--- BLOCK #102 676-677, warpins: 4 ---
	--- END OF BLOCK #102 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #91



	-- Decompilation error in this vicinity:
	--- BLOCK #103 678-678, warpins: 1 ---
	return
	--- END OF BLOCK #103 ---



end

function NavFieldBuilder:_append_neighbour(neighbours, new_neighbour, dir_str)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local appended = nil
	local along_dim = self._perp_dim_str_map[dir_str]

	--- END OF BLOCK #0 ---

	for neighbour_index, neighbour_data in pairs(neighbours)


	LOOP BLOCK #1
	GO OUT TO BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #1 8-11, warpins: 1 ---
	local i_neighbour = neighbour_data.room
	--- END OF BLOCK #1 ---

	if new_neighbour.room == i_neighbour then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 12-20, warpins: 1 ---
	appended = true
	--- END OF BLOCK #2 ---

	if new_neighbour.overlap[1][along_dim] < neighbour_data.overlap[1][along_dim] then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 21-24, warpins: 1 ---
	neighbour_data.overlap[1] = new_neighbour.overlap[1]
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 25-32, warpins: 2 ---
	--- END OF BLOCK #4 ---

	if neighbour_data.overlap[2][along_dim] < new_neighbour.overlap[2][along_dim] then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 33-36, warpins: 1 ---
	neighbour_data.overlap[2] = new_neighbour.overlap[2]

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 37-38, warpins: 4 ---
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #7 39-40, warpins: 1 ---
	--- END OF BLOCK #7 ---

	slot4 = if not appended then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 41-45, warpins: 1 ---
	table.insert(neighbours, new_neighbour)

	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 46-46, warpins: 2 ---
	return
	--- END OF BLOCK #9 ---



end

function NavFieldBuilder:_update_neighbour_data(i_room, i_neighbour, new_data, dir_str)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-5, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot5 = if self._rooms[i_room].neighbours then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 6-15, warpins: 1 ---
	local along_dim = self._perp_dim_str_map[dir_str]
	local neighbours = self._rooms[i_room].neighbours[dir_str]

	--- END OF BLOCK #1 ---

	for neighbour_index, neighbour_data in pairs(neighbours)


	LOOP BLOCK #2
	GO OUT TO BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #2 16-18, warpins: 1 ---
	--- END OF BLOCK #2 ---

	if neighbour_data.room == i_neighbour then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 19-20, warpins: 1 ---
	neighbours[neighbour_index] = nil

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 21-22, warpins: 3 ---
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #5 23-24, warpins: 1 ---
	--- END OF BLOCK #5 ---

	slot3 = if new_data then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 25-29, warpins: 1 ---
	table.insert(neighbours, new_data)

	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 30-30, warpins: 3 ---
	return
	--- END OF BLOCK #7 ---



end

function NavFieldBuilder:_split_side_neighbours(neighbours_list, split_pos, seg_dim)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local low_seg_list = {}
	local high_seg_list = {}
	local split_length = split_pos[seg_dim]

	--- END OF BLOCK #0 ---

	for index_neighbour, neighbour_data in pairs(neighbours_list)


	LOOP BLOCK #1
	GO OUT TO BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #1 8-16, warpins: 1 ---
	local test_seg = neighbour_data.overlap
	local room = neighbour_data.room
	local test_min = test_seg[1][seg_dim]
	local test_max = test_seg[2][seg_dim]
	local new_segment1, new_segment2 = nil

	--- END OF BLOCK #1 ---

	if split_length <= test_min then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 17-24, warpins: 1 ---
	table.insert(high_seg_list, {
		overlap = test_seg,
		room = room
	})
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #3 25-26, warpins: 1 ---
	--- END OF BLOCK #3 ---

	if test_max <= split_length then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 27-34, warpins: 1 ---
	table.insert(low_seg_list, {
		overlap = test_seg,
		room = room
	})

	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #5 35-69, warpins: 1 ---
	local mid_pos = split_pos:with_z(math.lerp(test_seg[1].z, test_seg[2].z, (split_length - test_min) / (test_max - test_min)))
	local new_segment1 = {}
	new_segment1[1] = test_seg[1]
	new_segment1[2] = mid_pos
	local new_segment2 = {}
	new_segment2[1] = mid_pos
	new_segment2[2] = test_seg[2]

	table.insert(low_seg_list, {
		overlap = new_segment1,
		room = room
	})
	table.insert(high_seg_list, {
		overlap = new_segment2,
		room = room
	})

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 70-71, warpins: 4 ---
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #7 72-74, warpins: 1 ---
	return low_seg_list, high_seg_list
	--- END OF BLOCK #7 ---



end

function NavFieldBuilder:_chk_room_side_too_long(borders, dir_str)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-19, warpins: 1 ---
	local exp_side_len = math.abs(borders[dir_str] - borders[self._opposite_side_str[dir_str]])
	local perp_side_len = borders[self._perp_pos_dir_str_map[dir_str]] - borders[self._perp_neg_dir_str_map[dir_str]]
	local room_dim_ratio = exp_side_len / perp_side_len
	--- END OF BLOCK #0 ---

	if room_dim_ratio >= 2 then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 20-23, warpins: 1 ---
	--- END OF BLOCK #1 ---

	if exp_side_len < self._grid_size * 4 then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 24-25, warpins: 2 ---
	slot6 = false
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #3 26-26, warpins: 1 ---
	slot6 = true
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 27-29, warpins: 2 ---
	--- END OF BLOCK #4 ---

	if room_dim_ratio <= 1 then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 30-31, warpins: 1 ---
	slot7 = false
	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #6 32-32, warpins: 1 ---
	slot7 = true

	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 33-33, warpins: 2 ---
	return slot6, slot7
	--- END OF BLOCK #7 ---



end

function NavFieldBuilder:_append_seg_to_seg_list(seg_list, seg, seg_dim)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-5, warpins: 1 ---
	local appended, i_app_seg = nil

	--- END OF BLOCK #0 ---

	for i_seg, test_seg in pairs(seg_list)


	LOOP BLOCK #1
	GO OUT TO BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #1 6-11, warpins: 1 ---
	--- END OF BLOCK #1 ---

	if test_seg[1][seg_dim] == seg[2][seg_dim] then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 12-16, warpins: 1 ---
	test_seg[1] = seg[1]
	appended = 1
	i_app_seg = i_seg
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #3 17-17, warpins: 0 ---
	--- END OF BLOCK #3 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #4 18-23, warpins: 1 ---
	--- END OF BLOCK #4 ---

	if test_seg[2][seg_dim] == seg[1][seg_dim] then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 24-28, warpins: 1 ---
	test_seg[2] = seg[2]
	appended = 2
	i_app_seg = i_seg

	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #6 29-30, warpins: 3 ---
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #7 31-32, warpins: 3 ---
	--- END OF BLOCK #7 ---

	slot4 = if not appended then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 33-42, warpins: 1 ---
	table.insert(seg_list, {
		seg[1],
		seg[2]
	})

	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #9 43-44, warpins: 1 ---
	--- END OF BLOCK #9 ---

	if appended == 1 then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #16
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 45-51, warpins: 1 ---
	local app_pos = seg_list[i_app_seg][1][seg_dim]

	--- END OF BLOCK #10 ---

	for i_test_seg, test_seg in pairs(seg_list)


	LOOP BLOCK #11
	GO OUT TO BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #11 52-55, warpins: 1 ---
	--- END OF BLOCK #11 ---

	if app_pos <= test_seg[2][seg_dim] then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 56-59, warpins: 1 ---
	--- END OF BLOCK #12 ---

	if test_seg[1][seg_dim] < app_pos then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 60-68, warpins: 1 ---
	seg_list[i_app_seg][1] = test_seg[1]

	table.remove(seg_list, i_test_seg)

	--- END OF BLOCK #13 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #14 69-70, warpins: 3 ---
	--- END OF BLOCK #14 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #15 71-71, warpins: 1 ---
	--- END OF BLOCK #15 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #16 72-73, warpins: 1 ---
	--- END OF BLOCK #16 ---

	if appended == 2 then
	JUMP TO BLOCK #17
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #17 74-80, warpins: 1 ---
	local app_pos = seg_list[i_app_seg][2][seg_dim]

	--- END OF BLOCK #17 ---

	for i_test_seg, test_seg in pairs(seg_list)


	LOOP BLOCK #18
	GO OUT TO BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #18 81-84, warpins: 1 ---
	--- END OF BLOCK #18 ---

	if test_seg[1][seg_dim] <= app_pos then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 85-88, warpins: 1 ---
	--- END OF BLOCK #19 ---

	if app_pos < test_seg[2][seg_dim] then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 89-97, warpins: 1 ---
	seg_list[i_app_seg][2] = test_seg[2]

	table.remove(seg_list, i_test_seg)

	--- END OF BLOCK #20 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #21 98-99, warpins: 3 ---
	--- END OF BLOCK #21 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #22 100-100, warpins: 6 ---
	return
	--- END OF BLOCK #22 ---



end

function NavFieldBuilder:_remove_seg_from_seg_list(seg_list, seg, seg_dim)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-5, warpins: 1 ---
	local new_seg_list = {}

	--- END OF BLOCK #0 ---

	for i_seg, test_seg in pairs(seg_list)


	LOOP BLOCK #1
	GO OUT TO BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #1 6-12, warpins: 1 ---
	local new_segment1, new_segment2 = nil
	--- END OF BLOCK #1 ---

	if test_seg[2][seg_dim] > seg[1][seg_dim] then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 13-18, warpins: 1 ---
	--- END OF BLOCK #2 ---

	if seg[2][seg_dim] <= test_seg[1][seg_dim] then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 19-20, warpins: 2 ---
	new_segment1 = test_seg
	--- END OF BLOCK #3 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #4 21-26, warpins: 1 ---
	--- END OF BLOCK #4 ---

	if seg[1][seg_dim] <= test_seg[1][seg_dim] then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 27-32, warpins: 1 ---
	--- END OF BLOCK #5 ---

	if test_seg[2][seg_dim] <= seg[2][seg_dim] then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 33-33, warpins: 1 ---
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #7 34-39, warpins: 2 ---
	--- END OF BLOCK #7 ---

	if test_seg[1][seg_dim] < seg[1][seg_dim] then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 40-45, warpins: 1 ---
	--- END OF BLOCK #8 ---

	if seg[2][seg_dim] < test_seg[2][seg_dim] then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 46-58, warpins: 1 ---
	new_segment1 = {
		test_seg[1],
		seg[1]
	}
	new_segment2 = {
		seg[2],
		test_seg[2]
	}
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #10 59-64, warpins: 2 ---
	--- END OF BLOCK #10 ---

	if seg[1][seg_dim] <= test_seg[1][seg_dim] then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 65-71, warpins: 1 ---
	new_segment1 = {
		seg[2],
		test_seg[2]
	}
	--- END OF BLOCK #11 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #12 72-77, warpins: 1 ---
	new_segment1 = {
		test_seg[1],
		seg[1]
	}

	--- END OF BLOCK #12 ---

	FLOW; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #13 78-79, warpins: 5 ---
	--- END OF BLOCK #13 ---

	slot10 = if new_segment1 then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 80-84, warpins: 1 ---
	table.insert(new_seg_list, new_segment1)
	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 85-86, warpins: 2 ---
	--- END OF BLOCK #15 ---

	slot11 = if new_segment2 then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 87-91, warpins: 1 ---
	table.insert(new_seg_list, new_segment2)

	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 92-93, warpins: 3 ---
	--- END OF BLOCK #17 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #18 94-94, warpins: 1 ---
	return new_seg_list
	--- END OF BLOCK #18 ---



end

function NavFieldBuilder:_split_segment_list_at_position(seg_list, split_pos, seg_dim)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local low_seg_list = {}
	local high_seg_list = {}
	local split_length = split_pos[seg_dim]

	--- END OF BLOCK #0 ---

	for i_seg, test_seg in pairs(seg_list)


	LOOP BLOCK #1
	GO OUT TO BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #1 8-14, warpins: 1 ---
	local test_min = test_seg[1][seg_dim]
	local test_max = test_seg[2][seg_dim]
	local new_segment1, new_segment2 = nil

	--- END OF BLOCK #1 ---

	if split_length <= test_min then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 15-20, warpins: 1 ---
	table.insert(high_seg_list, test_seg)
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #3 21-22, warpins: 1 ---
	--- END OF BLOCK #3 ---

	if test_max <= split_length then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 23-28, warpins: 1 ---
	table.insert(low_seg_list, test_seg)

	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #5 29-59, warpins: 1 ---
	local mid_pos = split_pos:with_z(math.lerp(test_seg[1].z, test_seg[2].z, (split_length - test_min) / (test_max - test_min)))
	local new_segment1 = {}
	new_segment1[1] = test_seg[1]
	new_segment1[2] = mid_pos
	local new_segment2 = {}
	new_segment2[1] = mid_pos
	new_segment2[2] = test_seg[2]

	table.insert(low_seg_list, new_segment1)
	table.insert(high_seg_list, new_segment2)

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 60-61, warpins: 4 ---
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #7 62-64, warpins: 1 ---
	return low_seg_list, high_seg_list
	--- END OF BLOCK #7 ---



end

function NavFieldBuilder:_seg_to_seg_list_intersection_bool(seg_list, seg, seg_dim)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-8, warpins: 1 ---
	local seg_min = seg[1][seg_dim]
	local seg_max = seg[2][seg_dim]

	--- END OF BLOCK #0 ---

	for i_seg, test_seg in pairs(seg_list)


	LOOP BLOCK #1
	GO OUT TO BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #1 9-12, warpins: 1 ---
	--- END OF BLOCK #1 ---

	if seg_max > test_seg[1][seg_dim] then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 13-16, warpins: 1 ---
	--- END OF BLOCK #2 ---

	if test_seg[2][seg_dim] > seg_min then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 17-18, warpins: 1 ---
	return true
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 19-20, warpins: 4 ---
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #5 21-21, warpins: 1 ---
	return
	--- END OF BLOCK #5 ---



end

function NavFieldBuilder:_expansion_check_obstacles(dir_str, dir_vec, exp_space, inclination)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-32, warpins: 1 ---
	local x_dir_str_map = self._x_dir_str_map
	local expand_dim = self._dim_str_map[dir_str]
	local along_dim = self._perp_dim_str_map[dir_str]
	local grid_size = self._grid_size
	local padding_gnd = self._ground_padding
	local padding_wall = self._wall_padding
	local air_ray_rad = self._air_ray_rad
	local gnd_ray_rad = self._gnd_ray_rad
	local along_vec = Vector3()

	mvector3["set_" .. along_dim](along_vec, grid_size * 0.5)

	local along_vec_inclination = exp_space[2] - exp_space[1]

	mvector3.normalize(along_vec_inclination)

	local inclination_init = inclination[expand_dim]
	--- END OF BLOCK #0 ---

	slot16 = if self._neg_dir_str_map[dir_str] then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 33-33, warpins: 1 ---
	inclination_init = -inclination_init
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 34-60, warpins: 2 ---
	local step_vec = 2 * along_vec
	local seg_size_grid = (exp_space[2][along_dim] - exp_space[1][along_dim]) / grid_size
	local travel_seg = {}
	travel_seg[1] = exp_space[1] + along_vec
	travel_seg[2] = exp_space[2] - along_vec
	local measuring = {}
	local pos_along_border = travel_seg[1]
	local res_expansion = {}
	res_expansion.walls = {}
	res_expansion.stairs = {}
	res_expansion.spaces = {}
	res_expansion.cliffs = {}
	local prev_air_pos = nil
	local i_grid = 0
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 61-61, warpins: 2 ---
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 62-72, warpins: 1 ---
	local obstacle_found = nil
	local back_ground_ray = self:_sphere_ray(pos_along_border + self._up_vec, pos_along_border + self._down_vec, gnd_ray_rad)

	--- END OF BLOCK #4 ---

	slot25 = if not back_ground_ray then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 73-85, warpins: 1 ---
	Application:draw_cylinder(pos_along_border + self._up_vec, pos_along_border + self._down_vec, gnd_ray_rad, 1, 0, 0)

	return res_expansion

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 86-105, warpins: 2 ---
	local air_pos = pos_along_border:with_z(back_ground_ray.position.z + padding_gnd + air_ray_rad)
	local air_from_pos = air_pos - dir_vec * grid_size
	local air_to_pos = air_pos + dir_vec * (padding_wall + grid_size)
	local air_ray = self:_bundle_ray(air_from_pos, air_to_pos, air_ray_rad)
	--- END OF BLOCK #6 ---

	slot29 = if not air_ray then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 106-123, warpins: 1 ---
	local air_from_pos = air_to_pos - dir_vec * (gnd_ray_rad + 2)
	local air_to_pos = air_from_pos - along_vec_inclination:normalized() * (padding_wall + grid_size * 0.5 - 1)
	air_ray = self:_bundle_ray(air_from_pos, air_to_pos, air_ray_rad * 0.8)
	--- END OF BLOCK #7 ---

	FLOW; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #8 124-125, warpins: 2 ---
	--- END OF BLOCK #8 ---

	slot29 = if not air_ray then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 126-143, warpins: 1 ---
	local air_from_pos = air_to_pos - dir_vec * (gnd_ray_rad + 2)
	local air_to_pos = air_from_pos + along_vec_inclination:normalized() * (padding_wall + grid_size * 0.5 - 1)
	air_ray = self:_bundle_ray(air_from_pos, air_to_pos, air_ray_rad * 0.8)
	--- END OF BLOCK #9 ---

	FLOW; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #10 144-145, warpins: 2 ---
	--- END OF BLOCK #10 ---

	slot29 = if air_ray then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #13
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 146-153, warpins: 1 ---
	obstacle_found = "walls"

	--- END OF BLOCK #11 ---

	slot30 = if air_ray.unit:in_slot(15)
	 then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #44
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 154-158, warpins: 1 ---
	self:_on_helper_hit(air_ray.unit)

	--- END OF BLOCK #12 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #44



	-- Decompilation error in this vicinity:
	--- BLOCK #13 159-179, warpins: 1 ---
	local void_ray_rad = grid_size * 0.5
	local ray_rad_dif = gnd_ray_rad - void_ray_rad
	local front_air_pos = air_pos + dir_vec * grid_size * 2 - step_vec * 1.5
	local front_ray = self:_bundle_ray(air_pos, front_air_pos, air_ray_rad)
	local front_gnd_pos = math.step(front_air_pos, air_pos, void_ray_rad + 1)
	--- END OF BLOCK #13 ---

	slot33 = if not front_ray then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 180-188, warpins: 1 ---
	slot35 = self:_sphere_ray(front_gnd_pos + self._up_vec, front_gnd_pos + self._down_vec, void_ray_rad)
	--- END OF BLOCK #14 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #15 189-190, warpins: 1 ---
	slot35 = false
	--- END OF BLOCK #15 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #16 191-191, warpins: 0 ---
	local front_ground_ray = true

	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 192-193, warpins: 3 ---
	--- END OF BLOCK #17 ---

	slot33 = if not front_ray then
	JUMP TO BLOCK #18
	else
	JUMP TO BLOCK #20
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #18 194-195, warpins: 1 ---
	--- END OF BLOCK #18 ---

	slot35 = if front_ground_ray then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #37
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 196-207, warpins: 1 ---
	--- END OF BLOCK #19 ---

	if math.abs(front_ground_ray.position.z + ray_rad_dif - back_ground_ray.position.z)

	 < 40 then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #37
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 208-226, warpins: 2 ---
	front_air_pos = air_pos + dir_vec * grid_size * 2
	front_ray = self:_bundle_ray(air_pos, front_air_pos, air_ray_rad)
	front_gnd_pos = math.step(front_air_pos, air_pos, void_ray_rad + 1)
	--- END OF BLOCK #20 ---

	slot33 = if not front_ray then
	JUMP TO BLOCK #21
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #21 227-236, warpins: 1 ---
	front_ground_ray = self:_sphere_ray(front_gnd_pos + self._up_vec, front_gnd_pos + self._down_vec, void_ray_rad)
	--- END OF BLOCK #21 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #22 237-238, warpins: 1 ---
	front_ground_ray = false
	--- END OF BLOCK #22 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #23 239-239, warpins: 0 ---
	front_ground_ray = true

	--- END OF BLOCK #23 ---

	FLOW; TARGET BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #24 240-241, warpins: 3 ---
	--- END OF BLOCK #24 ---

	slot33 = if not front_ray then
	JUMP TO BLOCK #25
	else
	JUMP TO BLOCK #27
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #25 242-243, warpins: 1 ---
	--- END OF BLOCK #25 ---

	slot35 = if front_ground_ray then
	JUMP TO BLOCK #26
	else
	JUMP TO BLOCK #36
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #26 244-255, warpins: 1 ---
	--- END OF BLOCK #26 ---

	if math.abs(front_ground_ray.position.z + ray_rad_dif - back_ground_ray.position.z)

	 < 40 then
	JUMP TO BLOCK #27
	else
	JUMP TO BLOCK #36
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #27 256-276, warpins: 2 ---
	front_air_pos = air_pos + dir_vec * grid_size * 2 + step_vec * 1.5
	front_ray = self:_bundle_ray(air_pos, front_air_pos, air_ray_rad)
	front_gnd_pos = math.step(front_air_pos, air_pos, void_ray_rad + 1)
	--- END OF BLOCK #27 ---

	slot33 = if not front_ray then
	JUMP TO BLOCK #28
	else
	JUMP TO BLOCK #29
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #28 277-286, warpins: 1 ---
	front_ground_ray = self:_sphere_ray(front_gnd_pos + self._up_vec, front_gnd_pos + self._down_vec, void_ray_rad)
	--- END OF BLOCK #28 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #31



	-- Decompilation error in this vicinity:
	--- BLOCK #29 287-288, warpins: 1 ---
	front_ground_ray = false
	--- END OF BLOCK #29 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #31



	-- Decompilation error in this vicinity:
	--- BLOCK #30 289-289, warpins: 0 ---
	front_ground_ray = true

	--- END OF BLOCK #30 ---

	FLOW; TARGET BLOCK #31



	-- Decompilation error in this vicinity:
	--- BLOCK #31 290-291, warpins: 3 ---
	--- END OF BLOCK #31 ---

	slot33 = if not front_ray then
	JUMP TO BLOCK #32
	else
	JUMP TO BLOCK #38
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #32 292-293, warpins: 1 ---
	--- END OF BLOCK #32 ---

	slot35 = if front_ground_ray then
	JUMP TO BLOCK #33
	else
	JUMP TO BLOCK #35
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #33 294-305, warpins: 1 ---
	--- END OF BLOCK #33 ---

	if math.abs(front_ground_ray.position.z + ray_rad_dif - back_ground_ray.position.z)

	 < 40 then
	JUMP TO BLOCK #34
	else
	JUMP TO BLOCK #35
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #34 306-306, warpins: 1 ---
	--- END OF BLOCK #34 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #35 307-308, warpins: 2 ---
	obstacle_found = "cliffs"
	--- END OF BLOCK #35 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #36 309-310, warpins: 2 ---
	obstacle_found = "cliffs"
	--- END OF BLOCK #36 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #37 311-311, warpins: 2 ---
	obstacle_found = "cliffs"
	--- END OF BLOCK #37 ---

	FLOW; TARGET BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #38 312-313, warpins: 5 ---
	--- END OF BLOCK #38 ---

	slot24 = if not obstacle_found then
	JUMP TO BLOCK #39
	else
	JUMP TO BLOCK #42
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #39 314-325, warpins: 1 ---
	local front_air_pos = air_pos + dir_vec * grid_size
	local front_ground_ray = self:_sphere_ray(front_air_pos + self._up_vec, front_air_pos + self._down_vec, gnd_ray_rad)
	--- END OF BLOCK #39 ---

	slot37 = if front_ground_ray then
	JUMP TO BLOCK #40
	else
	JUMP TO BLOCK #42
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #40 326-338, warpins: 1 ---
	local climb_vec = front_ground_ray.position - back_ground_ray.position
	local inclination = climb_vec.z / self._grid_size
	local abs_inc_diff = math.abs(inclination_init - inclination)
	--- END OF BLOCK #40 ---

	if abs_inc_diff > 0.5 then
	JUMP TO BLOCK #41
	else
	JUMP TO BLOCK #42
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #41 339-339, warpins: 1 ---
	obstacle_found = "stairs"
	--- END OF BLOCK #41 ---

	FLOW; TARGET BLOCK #42



	-- Decompilation error in this vicinity:
	--- BLOCK #42 340-341, warpins: 4 ---
	--- END OF BLOCK #42 ---

	slot24 = if not obstacle_found then
	JUMP TO BLOCK #43
	else
	JUMP TO BLOCK #44
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #43 342-342, warpins: 1 ---
	obstacle_found = "spaces"
	--- END OF BLOCK #43 ---

	FLOW; TARGET BLOCK #44



	-- Decompilation error in this vicinity:
	--- BLOCK #44 343-345, warpins: 4 ---
	--- END OF BLOCK #44 ---

	slot30 = if measuring[obstacle_found] then
	JUMP TO BLOCK #45
	else
	JUMP TO BLOCK #47
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #45 346-348, warpins: 1 ---
	--- END OF BLOCK #45 ---

	if i_grid == seg_size_grid - 1 then
	JUMP TO BLOCK #46
	else
	JUMP TO BLOCK #52
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #46 349-374, warpins: 1 ---
	local meas_obs_type = next(measuring)
	local measured_seg = measuring[meas_obs_type]
	measured_seg[2] = pos_along_border + along_vec
	local ground_ray = self:_sphere_ray(pos_along_border + self._up_vec, pos_along_border + self._down_vec, gnd_ray_rad)

	mvector3.set_z(measured_seg[2], ground_ray.position.z)
	table.insert(res_expansion[obstacle_found], measured_seg)

	--- END OF BLOCK #46 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #52



	-- Decompilation error in this vicinity:
	--- BLOCK #47 375-379, warpins: 1 ---
	local meas_obs_type = next(measuring)
	--- END OF BLOCK #47 ---

	slot30 = if meas_obs_type then
	JUMP TO BLOCK #48
	else
	JUMP TO BLOCK #49
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #48 380-403, warpins: 1 ---
	local measured_seg = measuring[meas_obs_type]
	measured_seg[2] = pos_along_border - along_vec
	local ground_ray = self:_sphere_ray(pos_along_border + self._up_vec, pos_along_border + self._down_vec, gnd_ray_rad)

	mvector3.set_z(measured_seg[2], ground_ray.position.z)
	table.insert(res_expansion[meas_obs_type], measured_seg)

	measuring[meas_obs_type] = nil
	--- END OF BLOCK #48 ---

	FLOW; TARGET BLOCK #49



	-- Decompilation error in this vicinity:
	--- BLOCK #49 404-406, warpins: 2 ---
	--- END OF BLOCK #49 ---

	if i_grid == seg_size_grid - 1 then
	JUMP TO BLOCK #50
	else
	JUMP TO BLOCK #51
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #50 407-437, warpins: 1 ---
	local measured_seg = {}
	measured_seg[1] = pos_along_border - along_vec
	measured_seg[2] = pos_along_border + along_vec
	local ground_ray = self:_sphere_ray(pos_along_border + self._up_vec, pos_along_border + self._down_vec, gnd_ray_rad)

	mvector3.set_z(measured_seg[1], ground_ray.position.z)
	mvector3.set_z(measured_seg[2], ground_ray.position.z)
	table.insert(res_expansion[obstacle_found], measured_seg)

	--- END OF BLOCK #50 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #52



	-- Decompilation error in this vicinity:
	--- BLOCK #51 438-455, warpins: 1 ---
	local new_seg = {}
	new_seg[1] = pos_along_border - along_vec
	local ground_ray = self:_sphere_ray(pos_along_border + self._up_vec, pos_along_border + self._down_vec, gnd_ray_rad)

	mvector3.set_z(new_seg[1], ground_ray.position.z)

	measuring[obstacle_found] = new_seg
	--- END OF BLOCK #51 ---

	FLOW; TARGET BLOCK #52



	-- Decompilation error in this vicinity:
	--- BLOCK #52 456-471, warpins: 4 ---
	pos_along_border = pos_along_border + step_vec
	i_grid = i_grid + 1

	mvector3.set_z(pos_along_border, math.lerp(travel_seg[1].z, travel_seg[2].z, i_grid / seg_size_grid))

	--- END OF BLOCK #52 ---

	if seg_size_grid <= i_grid then
	JUMP TO BLOCK #53
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #53 472-477, warpins: 1 ---
	slot24 = res_expansion

	--- END OF BLOCK #53 ---

	slot25 = if not next(res_expansion.walls)
	 then
	JUMP TO BLOCK #54
	else
	JUMP TO BLOCK #56
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #54 478-482, warpins: 1 ---
	--- END OF BLOCK #54 ---

	slot25 = if not next(res_expansion.stairs)

	 then
	JUMP TO BLOCK #55
	else
	JUMP TO BLOCK #56
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #55 483-485, warpins: 1 ---
	slot25 = next(res_expansion.cliffs)

	--- END OF BLOCK #55 ---

	FLOW; TARGET BLOCK #56



	-- Decompilation error in this vicinity:
	--- BLOCK #56 486-486, warpins: 3 ---
	return slot24, slot25
	--- END OF BLOCK #56 ---



end

function NavFieldBuilder:_expansion_check_neighbours(dir_str, exp_space)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-28, warpins: 1 ---
	local opp_dir_str_map = self._opposite_side_str
	local perp_pos_dir_str_map = self._perp_pos_dir_str_map
	local perp_neg_dir_str_map = self._perp_neg_dir_str_map
	local neg_dir_str_map = self._neg_dir_str_map
	local x_dir_str_map = self._x_dir_str_map
	local dir_vec_map = self._dir_str_to_vec
	local dim_str_map = self._dim_str_map
	local perp_dim_str_map = self._perp_dim_str_map
	local expand_dim = dim_str_map[dir_str]
	local along_dim = perp_dim_str_map[dir_str]
	local expand_border = exp_space[1][dim_str_map[dir_str]]
	local expand_seg = {}
	expand_seg[1] = exp_space[1][perp_dim_str_map[dir_str]]
	expand_seg[2] = exp_space[2][perp_dim_str_map[dir_str]]
	local neighbours = {}
	local opp_dir_str = opp_dir_str_map[dir_str]

	--- END OF BLOCK #0 ---

	for i_room, test_room in ipairs(self._rooms)


	LOOP BLOCK #1
	GO OUT TO BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #1 29-33, warpins: 1 ---
	local test_borders = test_room.borders
	local test_border = test_room.borders[opp_dir_str]
	--- END OF BLOCK #1 ---

	if expand_border == test_border then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 34-47, warpins: 1 ---
	local test_border_seg = {}
	test_border_seg[1] = test_borders[perp_neg_dir_str_map[dir_str]]
	test_border_seg[2] = test_borders[perp_pos_dir_str_map[dir_str]]
	local overlap_line = self:_chk_line_overlap(test_border_seg, expand_seg)
	--- END OF BLOCK #2 ---

	slot25 = if overlap_line then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 48-134, warpins: 1 ---
	local overlap_seg = {}
	overlap_seg[1] = Vector3()
	overlap_seg[MULTRES] = Vector3()

	mvector3["set_" .. dim_str_map[dir_str]](overlap_seg[1], expand_border)
	mvector3["set_" .. perp_dim_str_map[dir_str]](overlap_seg[1], overlap_line[1])

	local z1_test_room = self._get_room_height_at_pos(test_room.height, test_room.borders, overlap_seg[1])
	local z1_exp_room = math.lerp(exp_space[1].z, exp_space[2].z, (overlap_line[1] - exp_space[1][along_dim]) / (exp_space[2][along_dim] - exp_space[1][along_dim]))

	mvector3["set_" .. dim_str_map[dir_str]](overlap_seg[2], expand_border)
	mvector3["set_" .. perp_dim_str_map[dir_str]](overlap_seg[2], overlap_line[2])

	local z2_test_room = self._get_room_height_at_pos(test_room.height, test_room.borders, overlap_seg[2])
	local z2_exp_room = math.lerp(exp_space[1].z, exp_space[2].z, (overlap_line[2] - exp_space[1][along_dim]) / (exp_space[2][along_dim] - exp_space[1][along_dim]))
	local min_h_diff = 150

	--- END OF BLOCK #3 ---

	if min_h_diff < z1_test_room - z1_exp_room then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 135-137, warpins: 1 ---
	--- END OF BLOCK #4 ---

	if min_h_diff >= z2_test_room - z2_exp_room then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 138-141, warpins: 2 ---
	--- END OF BLOCK #5 ---

	if z1_test_room - z1_exp_room < -min_h_diff then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 142-145, warpins: 1 ---
	--- END OF BLOCK #6 ---

	if z2_test_room - z2_exp_room < -min_h_diff then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 146-146, warpins: 1 ---
	--- END OF BLOCK #7 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #8 147-165, warpins: 2 ---
	mvector3.set_z(overlap_seg[1], (z1_test_room + z1_exp_room) * 0.5)
	mvector3.set_z(overlap_seg[2], (z2_test_room + z2_exp_room) * 0.5)
	table.insert(neighbours, {
		room = i_room,
		overlap = overlap_seg
	})
	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 166-167, warpins: 6 ---
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #10 168-172, warpins: 1 ---
	--- END OF BLOCK #10 ---

	slot17 = if next(neighbours)

	 then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 173-173, warpins: 1 ---
	slot17 = neighbours

	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 174-174, warpins: 2 ---
	return slot17
	--- END OF BLOCK #12 ---



end

function NavFieldBuilder:_on_helper_hit(unit)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local unit_id = unit:unit_data().unit_id
	self._new_blockers[unit_id] = unit

	return
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_set_new_blockers_used()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	for unit_id, unit in pairs(self._new_blockers)


	LOOP BLOCK #1
	GO OUT TO BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-8, warpins: 1 ---
	self._helper_blockers[unit_id] = self._building.id
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 9-10, warpins: 2 ---
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #3 11-13, warpins: 1 ---
	self._new_blockers = nil

	return
	--- END OF BLOCK #3 ---



end

function NavFieldBuilder:_disable_blocker(unit)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-11, warpins: 1 ---
	local u_id = unit:unit_data().unit_id
	self._disabled_blockers[u_id] = unit

	unit:set_enabled(false)

	return
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_enable_blocker(unit)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-12, warpins: 1 ---
	local u_id = unit:unit_data().unit_id
	self._disabled_blockers[u_id] = nil

	unit:set_enabled(true)

	return
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_reenable_all_blockers()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-3, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot1 = if self._disabled_blockers then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 4-7, warpins: 1 ---
	--- END OF BLOCK #1 ---

	for _, blocker_unit in pairs(self._disabled_blockers)

	LOOP BLOCK #2
	GO OUT TO BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #2 8-12, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot6 = if alive(blocker_unit)
	 then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 13-16, warpins: 1 ---
	blocker_unit:set_enabled(true)

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 17-18, warpins: 3 ---
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #5 19-21, warpins: 2 ---
	self._disabled_blockers = nil

	return
	--- END OF BLOCK #5 ---



end

function NavFieldBuilder:_disable_all_blockers()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-9, warpins: 1 ---
	local all_blockers = World:find_units_quick("all", 15)
	--- END OF BLOCK #0 ---

	slot2 = if not self._disabled_blockers then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 10-10, warpins: 1 ---
	slot2 = {}
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 11-15, warpins: 2 ---
	self._disabled_blockers = slot2

	--- END OF BLOCK #2 ---

	for _, unit in ipairs(all_blockers)

	LOOP BLOCK #3
	GO OUT TO BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #3 16-19, warpins: 1 ---
	self:_disable_blocker(unit)

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 20-21, warpins: 2 ---
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #5 22-22, warpins: 1 ---
	return
	--- END OF BLOCK #5 ---



end

function NavFieldBuilder:_chk_line_overlap(line1, line2)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-12, warpins: 1 ---
	local overlap_max = math.min(line1[2], line2[2])
	local overlap_min = math.max(line1[1], line2[1])
	--- END OF BLOCK #0 ---

	if overlap_min < overlap_max then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 13-16, warpins: 1 ---
	slot5 = {
		overlap_min,
		overlap_max
	}
	--- END OF BLOCK #1 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #2 17-18, warpins: 1 ---
	slot5 = false
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #3 19-19, warpins: 0 ---
	slot5 = true

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 20-20, warpins: 3 ---
	return slot5
	--- END OF BLOCK #4 ---



end

function NavFieldBuilder:_measure_init_room_expansion(room, enter_pos)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-12, warpins: 1 ---
	local perp_pos_dir_str_map = self._perp_pos_dir_str_map
	local perp_neg_dir_str_map = self._perp_neg_dir_str_map
	local dim_str_map = self._dim_str_map
	local perp_dim_str_map = self._perp_dim_str_map
	local borders = room.borders
	local expansion = room.expansion
	local height = room.height
	local inclination = room.inclination

	--- END OF BLOCK #0 ---

	for dir_str, perp_neg_dir_str in pairs(perp_neg_dir_str_map)


	LOOP BLOCK #1
	GO OUT TO BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #1 13-70, warpins: 1 ---
	local perp_pos_dir_str = perp_pos_dir_str_map[dir_str]
	local dim_str = dim_str_map[dir_str]
	local perp_dim_str = perp_dim_str_map[dir_str]
	local init_space = {}
	init_space[1] = Vector3()
	init_space[MULTRES] = Vector3()

	mvector3["set_" .. dim_str](init_space[1], borders[dir_str])
	mvector3["set_" .. dim_str](init_space[2], borders[dir_str])
	mvector3["set_" .. perp_dim_str](init_space[1], borders[perp_neg_dir_str])
	mvector3["set_" .. perp_dim_str](init_space[2], borders[perp_pos_dir_str])
	mvector3.set_z(init_space[1], enter_pos.z)
	mvector3.set_z(init_space[2], enter_pos.z)
	table.insert(expansion[dir_str].unsorted, init_space)

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 71-72, warpins: 2 ---
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #3 73-86, warpins: 1 ---
	local ray_from_pos = expansion.x_pos.unsorted[1][2]
	local ground_ray = self:_sphere_ray(ray_from_pos + self._up_vec, ray_from_pos + self._down_vec, self._gnd_ray_rad)
	--- END OF BLOCK #3 ---

	slot12 = if ground_ray then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 87-90, warpins: 1 ---
	--- END OF BLOCK #4 ---

	slot13 = if not ground_ray.position.z then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 91-91, warpins: 2 ---
	slot13 = enter_pos.z
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 92-123, warpins: 2 ---
	height.xp_yp = slot13

	mvector3.set_z(expansion.x_pos.unsorted[1][2], height.xp_yp)
	mvector3.set_z(expansion.y_pos.unsorted[1][2], height.xp_yp)

	local ray_from_pos = expansion.x_pos.unsorted[1][1]
	ground_ray = self:_sphere_ray(ray_from_pos + self._up_vec, ray_from_pos + self._down_vec, self._gnd_ray_rad)
	--- END OF BLOCK #6 ---

	slot12 = if ground_ray then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 124-127, warpins: 1 ---
	--- END OF BLOCK #7 ---

	slot14 = if not ground_ray.position.z then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 128-128, warpins: 2 ---
	slot14 = enter_pos.z
	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 129-160, warpins: 2 ---
	height.xp_yn = slot14

	mvector3.set_z(expansion.x_pos.unsorted[1][1], height.xp_yn)
	mvector3.set_z(expansion.y_neg.unsorted[1][2], height.xp_yn)

	local ray_from_pos = expansion.x_neg.unsorted[1][2]
	ground_ray = self:_sphere_ray(ray_from_pos + self._up_vec, ray_from_pos + self._down_vec, self._gnd_ray_rad)
	--- END OF BLOCK #9 ---

	slot12 = if ground_ray then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 161-164, warpins: 1 ---
	--- END OF BLOCK #10 ---

	slot15 = if not ground_ray.position.z then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 165-165, warpins: 2 ---
	slot15 = enter_pos.z
	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 166-197, warpins: 2 ---
	height.xn_yp = slot15

	mvector3.set_z(expansion.x_neg.unsorted[1][2], height.xn_yp)
	mvector3.set_z(expansion.y_pos.unsorted[1][1], height.xn_yp)

	local ray_from_pos = expansion.x_neg.unsorted[1][1]
	ground_ray = self:_sphere_ray(ray_from_pos + self._up_vec, ray_from_pos + self._down_vec, self._gnd_ray_rad)
	--- END OF BLOCK #12 ---

	slot12 = if ground_ray then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 198-201, warpins: 1 ---
	--- END OF BLOCK #13 ---

	slot16 = if not ground_ray.position.z then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 202-202, warpins: 2 ---
	slot16 = enter_pos.z
	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 203-244, warpins: 2 ---
	height.xn_yn = slot16

	mvector3.set_z(expansion.x_neg.unsorted[1][1], height.xn_yn)
	mvector3.set_z(expansion.y_neg.unsorted[1][1], height.xn_yn)

	local z_x_pos = (height.xp_yp + height.xp_yn) * 0.5
	local z_x_neg = (height.xn_yp + height.xn_yn) * 0.5
	local z_y_pos = (height.xp_yp + height.xn_yp) * 0.5
	local z_y_neg = (height.xp_yn + height.xn_yn) * 0.5
	inclination.x = (z_x_pos - z_x_neg) / self._grid_size
	inclination.y = (z_y_pos - z_y_neg) / self._grid_size

	return
	--- END OF BLOCK #15 ---



end

function NavFieldBuilder:_calculate_expanded_border(dir_str, border, grid_step)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot4 = if self._neg_dir_str_map[dir_str] then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-7, warpins: 1 ---
	--- END OF BLOCK #1 ---

	slot4 = if not (border - grid_step) then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 8-8, warpins: 2 ---
	slot4 = border + grid_step

	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 9-9, warpins: 2 ---
	return slot4
	--- END OF BLOCK #3 ---



end

function NavFieldBuilder:_find_room_height_from_expansion(expansion, height, side)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-5, warpins: 1 ---
	local y_max, y_min = nil

	--- END OF BLOCK #0 ---

	for obs_type, obs_list in pairs(expansion[side])

	LOOP BLOCK #1
	GO OUT TO BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #1 6-9, warpins: 1 ---
	--- END OF BLOCK #1 ---

	for i_obs, obs_seg in pairs(obs_list)


	LOOP BLOCK #2
	GO OUT TO BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #2 10-11, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot5 = if y_min then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 12-15, warpins: 1 ---
	--- END OF BLOCK #3 ---

	if obs_seg[1].y < y_min then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 16-20, warpins: 2 ---
	height.xp_yn = obs_seg[1].z
	y_min = obs_seg[1].y
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 21-22, warpins: 2 ---
	--- END OF BLOCK #5 ---

	slot4 = if y_max then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 23-26, warpins: 1 ---
	--- END OF BLOCK #6 ---

	if y_max < obs_seg[2].y then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 27-31, warpins: 2 ---
	height.xp_yp = obs_seg[2].z
	y_max = obs_seg[2].y
	--- END OF BLOCK #7 ---

	FLOW; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #8 32-33, warpins: 3 ---
	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #9 34-35, warpins: 2 ---
	--- END OF BLOCK #9 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #10 36-42, warpins: 1 ---
	y_max, y_min = nil

	--- END OF BLOCK #10 ---

	for obs_type, obs_list in pairs(expansion[self._opposite_side_str[side]])

	LOOP BLOCK #11
	GO OUT TO BLOCK #20



	-- Decompilation error in this vicinity:
	--- BLOCK #11 43-46, warpins: 1 ---
	--- END OF BLOCK #11 ---

	for i_obs, obs_seg in pairs(obs_list)


	LOOP BLOCK #12
	GO OUT TO BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #12 47-48, warpins: 1 ---
	--- END OF BLOCK #12 ---

	slot5 = if y_min then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 49-52, warpins: 1 ---
	--- END OF BLOCK #13 ---

	if obs_seg[1].y < y_min then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 53-57, warpins: 2 ---
	height.xn_yn = obs_seg[1].z
	y_min = obs_seg[1].y
	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 58-59, warpins: 2 ---
	--- END OF BLOCK #15 ---

	slot4 = if y_max then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 60-63, warpins: 1 ---
	--- END OF BLOCK #16 ---

	if y_max < obs_seg[2].y then
	JUMP TO BLOCK #17
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #17 64-68, warpins: 2 ---
	height.xn_yp = obs_seg[2].z
	y_max = obs_seg[2].y

	--- END OF BLOCK #17 ---

	FLOW; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #18 69-70, warpins: 3 ---
	--- END OF BLOCK #18 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #19 71-72, warpins: 2 ---
	--- END OF BLOCK #19 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #20 73-73, warpins: 1 ---
	return
	--- END OF BLOCK #20 ---



end

function NavFieldBuilder._get_room_height_at_pos(height, borders, pos)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-33, warpins: 1 ---
	local lerp_x = (pos.x - borders.x_neg) / (borders.x_pos - borders.x_neg)
	local lerp_y = (pos.y - borders.y_neg) / (borders.y_pos - borders.y_neg)
	local side_x_pos_z = math.lerp(height.xp_yn, height.xp_yp, lerp_y)
	local side_x_neg_z = math.lerp(height.xn_yn, height.xn_yp, lerp_y)
	local plane_z = math.lerp(side_x_neg_z, side_x_pos_z, lerp_x)

	return plane_z
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_ground_ray(air_pos)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-12, warpins: 1 ---
	return World:raycast("ray", air_pos, air_pos + self._down_vec, "slot_mask", self._slotmask, "ray_type", "walk")
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_sphere_ray(from, to, raycast_radius)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-13, warpins: 1 ---
	return World:raycast("ray", from, to, "slot_mask", self._slotmask, "sphere_cast_radius", raycast_radius, "ray_type", "walk")
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_bundle_ray(from, to, raycast_radius)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-22, warpins: 1 ---
	return World:raycast("ray", from, to, "slot_mask", self._slotmask, "sphere_cast_radius", raycast_radius, "bundle", math.max(3, math.ceil(raycast_radius)), "ray_type", "walk")
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_check_line_z_overlap_bool(overlap_room_borders, ext_room_borders, overlap_room_height, ext_room_height, dir_str, clamp_a, segment)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-2, warpins: 1 ---
	--- END OF BLOCK #0 ---

	if dir_str ~= "x_pos" then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 3-4, warpins: 1 ---
	--- END OF BLOCK #1 ---

	if dir_str ~= "x_neg" then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 5-6, warpins: 1 ---
	slot8 = false
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #3 7-7, warpins: 2 ---
	local is_x = true
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 8-10, warpins: 2 ---
	local seg_pos_1, seg_pos_2 = nil
	--- END OF BLOCK #4 ---

	slot8 = if is_x then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 11-23, warpins: 1 ---
	seg_pos_1 = Vector3(clamp_a, segment[1], 0)
	seg_pos_2 = Vector3(clamp_a, segment[2], 0)
	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #6 24-35, warpins: 1 ---
	seg_pos_1 = Vector3(segment[1], clamp_a, 0)
	seg_pos_2 = Vector3(segment[2], clamp_a, 0)
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 36-69, warpins: 2 ---
	local exp_z_1 = self._get_room_height_at_pos(ext_room_height, ext_room_borders, seg_pos_1)
	local exp_z_2 = self._get_room_height_at_pos(ext_room_height, ext_room_borders, seg_pos_2)

	mvector3.set_z(seg_pos_1, exp_z_1)
	mvector3.set_z(seg_pos_2, exp_z_2)

	local overlap_z_1 = self._get_room_height_at_pos(overlap_room_height, overlap_room_borders, seg_pos_1)
	local overlap_z_2 = self._get_room_height_at_pos(overlap_room_height, overlap_room_borders, seg_pos_2)
	local min_h_diff = 150

	--- END OF BLOCK #7 ---

	if min_h_diff < overlap_z_1 - exp_z_1 then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 70-72, warpins: 1 ---
	--- END OF BLOCK #8 ---

	if min_h_diff >= overlap_z_2 - exp_z_2 then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 73-76, warpins: 2 ---
	--- END OF BLOCK #9 ---

	if overlap_z_1 - exp_z_1 < -min_h_diff then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 77-80, warpins: 1 ---
	--- END OF BLOCK #10 ---

	if overlap_z_2 - exp_z_2 < -min_h_diff then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 81-82, warpins: 2 ---
	return false
	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 83-84, warpins: 3 ---
	return true
	--- END OF BLOCK #12 ---



end

function NavFieldBuilder._check_room_overlap_bool(rect_1, rect_2)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	if rect_2.y_pos >= rect_1.y_neg then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-8, warpins: 1 ---
	--- END OF BLOCK #1 ---

	if rect_1.y_pos >= rect_2.y_neg then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 9-12, warpins: 1 ---
	--- END OF BLOCK #2 ---

	if rect_1.x_pos >= rect_2.x_neg then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 13-16, warpins: 1 ---
	--- END OF BLOCK #3 ---

	if rect_2.x_pos < rect_1.x_neg then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 17-18, warpins: 4 ---
	slot2 = false
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #5 19-19, warpins: 1 ---
	slot2 = true

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 20-20, warpins: 2 ---
	return slot2
	--- END OF BLOCK #6 ---



end

function NavFieldBuilder:_commence_vis_graph_build()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	if self._building.stage == 1 then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-33, warpins: 1 ---
	local i_room_a = self._building.current_i_room_a
	local i_room_b = self._building.current_i_room_b
	local text = "Checking visibility between " .. tostring(i_room_a) .. " and " .. tostring(i_room_b) .. " of " .. tostring(#self._rooms)

	self:_update_progress_bar(1, text)

	local complete = self:_create_room_to_room_visibility_data(self._building)
	--- END OF BLOCK #1 ---

	slot4 = if complete then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 34-46, warpins: 1 ---
	self._building.stage = 2
	self._building.current_i_room_a = nil
	self._building.current_i_room_b = nil
	self._building.old_rays = nil

	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #3 47-50, warpins: 1 ---
	--- END OF BLOCK #3 ---

	if self._building.stage == 2 then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 51-62, warpins: 1 ---
	self:_update_progress_bar(2, "creating visibility groups")
	self:_create_visibility_groups()

	self._building.stage = 3

	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #5 63-66, warpins: 1 ---
	--- END OF BLOCK #5 ---

	if self._building.stage == 3 then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 67-80, warpins: 1 ---
	self:_update_progress_bar(3, "linking visibility groups")
	self:_link_visibility_groups()

	self._room_visibility_data = nil
	self._building.stage = 4

	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #7 81-84, warpins: 1 ---
	--- END OF BLOCK #7 ---

	if self._building.stage == 4 then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 85-96, warpins: 1 ---
	self:_update_progress_bar(4, "generating geographic segments")
	self:_generate_geographic_segments()

	self._building.stage = 5

	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #9 97-100, warpins: 1 ---
	--- END OF BLOCK #9 ---

	if self._building.stage == 5 then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 101-121, warpins: 1 ---
	self:_update_progress_bar(5, "generating coarse navigation graph")
	self:_generate_coarse_navigation_graph()
	self:_cleanup_room_data_1()
	self:_reenable_all_blockers()

	self._building = false

	self:_destroy_progress_bar()
	self._build_complete_clbk()

	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 122-122, warpins: 7 ---
	return
	--- END OF BLOCK #11 ---



end

function NavFieldBuilder:_create_room_to_room_visibility_data(build_data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-9, warpins: 1 ---
	local i_room_a = build_data.current_i_room_a
	local i_room_b = build_data.current_i_room_b
	local all_rooms = self._rooms
	local nr_rooms = #all_rooms
	local room_a = all_rooms[i_room_a]
	local room_b = all_rooms[i_room_b]
	local current_nr_raycasts = 0
	local max_nr_raycasts = 300
	local ray_dis = build_data.ray_dis
	--- END OF BLOCK #0 ---

	FLOW; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #1 10-10, warpins: 2 ---
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 11-14, warpins: 1 ---
	local filtered, visibility, nr_raycasts, rays_x_a, rays_y_a, rays_x_b, rays_y_b = nil
	--- END OF BLOCK #2 ---

	slot18 = if build_data.new_pair then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 15-17, warpins: 1 ---
	--- END OF BLOCK #3 ---

	slot18 = if not build_data.pos_vis_filter then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 18-20, warpins: 1 ---
	--- END OF BLOCK #4 ---

	slot18 = if build_data.neg_vis_filter then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 21-30, warpins: 2 ---
	visibility = self:_chk_room_vis_filter(room_a, room_b, build_data.pos_vis_filter, build_data.neg_vis_filter)
	--- END OF BLOCK #5 ---

	if visibility ~= nil then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 31-32, warpins: 1 ---
	filtered = true
	nr_raycasts = 1
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 33-35, warpins: 4 ---
	--- END OF BLOCK #7 ---

	slot18 = if not build_data.old_rays then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 36-36, warpins: 1 ---
	local old_rays = {}
	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 37-38, warpins: 2 ---
	--- END OF BLOCK #9 ---

	slot11 = if not filtered then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #19
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 39-45, warpins: 1 ---
	slot20 = self
	slot19 = self._chk_room_to_room_visibility
	slot21 = room_a
	slot22 = room_b
	--- END OF BLOCK #10 ---

	slot23 = if not old_rays.x_a then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 46-46, warpins: 1 ---
	slot23 = 1
	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 47-49, warpins: 2 ---
	--- END OF BLOCK #12 ---

	slot24 = if not old_rays.y_a then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 50-50, warpins: 1 ---
	slot24 = 1
	--- END OF BLOCK #13 ---

	FLOW; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #14 51-53, warpins: 2 ---
	--- END OF BLOCK #14 ---

	slot25 = if not old_rays.x_b then
	JUMP TO BLOCK #15
	else
	JUMP TO BLOCK #16
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #15 54-54, warpins: 1 ---
	slot25 = 1
	--- END OF BLOCK #15 ---

	FLOW; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #16 55-57, warpins: 2 ---
	--- END OF BLOCK #16 ---

	slot26 = if not old_rays.y_b then
	JUMP TO BLOCK #17
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #17 58-58, warpins: 1 ---
	slot26 = 1
	--- END OF BLOCK #17 ---

	FLOW; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #18 59-67, warpins: 2 ---
	visibility, nr_raycasts, rays_x_a, rays_y_a, rays_x_b, rays_y_b = slot19(slot20, slot21, slot22, slot23, slot24, slot25, slot26, max_nr_raycasts - current_nr_raycasts, ray_dis)
	--- END OF BLOCK #18 ---

	FLOW; TARGET BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #19 68-70, warpins: 2 ---
	current_nr_raycasts = current_nr_raycasts + nr_raycasts
	--- END OF BLOCK #19 ---

	slot19 = if not filtered then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 71-72, warpins: 1 ---
	--- END OF BLOCK #20 ---

	slot19 = if not visibility then
	JUMP TO BLOCK #21
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #21 73-73, warpins: 1 ---
	local pair_completed = not rays_x_a

	--- END OF BLOCK #21 ---

	FLOW; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #22 74-75, warpins: 3 ---
	--- END OF BLOCK #22 ---

	slot12 = if visibility then
	JUMP TO BLOCK #23
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #23 76-80, warpins: 1 ---
	self:_set_rooms_visible(i_room_a, i_room_b)

	--- END OF BLOCK #23 ---

	FLOW; TARGET BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #24 81-82, warpins: 2 ---
	--- END OF BLOCK #24 ---

	slot19 = if pair_completed then
	JUMP TO BLOCK #25
	else
	JUMP TO BLOCK #37
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #25 83-84, warpins: 1 ---
	build_data.old_rays = nil
	--- END OF BLOCK #25 ---

	FLOW; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #26 85-85, warpins: 2 ---
	--- END OF BLOCK #26 ---

	FLOW; TARGET BLOCK #27



	-- Decompilation error in this vicinity:
	--- BLOCK #27 86-87, warpins: 1 ---
	--- END OF BLOCK #27 ---

	if i_room_b == nr_rooms then
	JUMP TO BLOCK #28
	else
	JUMP TO BLOCK #33
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #28 88-91, warpins: 1 ---
	--- END OF BLOCK #28 ---

	slot20 = if not self._room_visibility_data[i_room_a] then
	JUMP TO BLOCK #29
	else
	JUMP TO BLOCK #30
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #29 92-94, warpins: 1 ---
	self._room_visibility_data[i_room_a] = {}

	--- END OF BLOCK #29 ---

	FLOW; TARGET BLOCK #30



	-- Decompilation error in this vicinity:
	--- BLOCK #30 95-99, warpins: 2 ---
	--- END OF BLOCK #30 ---

	if i_room_a == #self._rooms - 1 then
	JUMP TO BLOCK #31
	else
	JUMP TO BLOCK #32
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #31 100-102, warpins: 1 ---
	return true

	--- END OF BLOCK #31 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #34



	-- Decompilation error in this vicinity:
	--- BLOCK #32 103-107, warpins: 1 ---
	i_room_a = i_room_a + 1
	i_room_b = i_room_a + 1
	room_a = all_rooms[i_room_a]
	room_b = all_rooms[i_room_b]
	--- END OF BLOCK #32 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #34



	-- Decompilation error in this vicinity:
	--- BLOCK #33 108-109, warpins: 1 ---
	i_room_b = i_room_b + 1
	room_b = all_rooms[i_room_b]
	--- END OF BLOCK #33 ---

	FLOW; TARGET BLOCK #34



	-- Decompilation error in this vicinity:
	--- BLOCK #34 110-112, warpins: 3 ---
	build_data.new_pair = true
	--- END OF BLOCK #34 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #35 113-114, warpins: 0 ---
	--- END OF BLOCK #35 ---

	if i_room_a == nr_rooms then
	JUMP TO BLOCK #36
	else
	JUMP TO BLOCK #26
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #36 115-115, warpins: 1 ---
	--- END OF BLOCK #36 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #37 116-122, warpins: 1 ---
	old_rays.x_a = rays_x_a
	old_rays.y_a = rays_y_a
	old_rays.x_b = rays_x_b
	old_rays.y_b = rays_y_b
	build_data.old_rays = old_rays
	build_data.new_pair = nil
	--- END OF BLOCK #37 ---

	FLOW; TARGET BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #38 123-124, warpins: 3 ---
	--- END OF BLOCK #38 ---

	if current_nr_raycasts == max_nr_raycasts then
	JUMP TO BLOCK #39
	else
	JUMP TO BLOCK #1
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #39 125-127, warpins: 1 ---
	build_data.current_i_room_a = i_room_a
	build_data.current_i_room_b = i_room_b

	return
	--- END OF BLOCK #39 ---



end

function NavFieldBuilder:_chk_room_to_room_visibility(room_a, room_b, old_rays_x_a, old_rays_y_a, old_rays_x_b, old_rays_y_b, nr_raycasts_allowed, ray_dis)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-67, warpins: 1 ---
	local borders_a = room_a.borders
	local borders_b = room_b.borders
	local min_ray_dis = ray_dis
	local nr_rays_x_a = math.max(2, 1 + math.floor((borders_a.x_pos - borders_a.x_neg) / min_ray_dis))
	local nr_rays_y_a = math.max(2, 1 + math.floor((borders_a.y_pos - borders_a.y_neg) / min_ray_dis))
	local nr_rays_x_b = math.max(2, 1 + math.floor((borders_b.x_pos - borders_b.x_neg) / min_ray_dis))
	local nr_rays_y_b = math.max(2, 1 + math.floor((borders_b.y_pos - borders_b.y_neg) / min_ray_dis))
	local nr_rays = 0
	local i_ray_x_a = old_rays_x_a
	local i_ray_y_a = old_rays_y_a
	local i_ray_x_b = old_rays_x_b
	local i_ray_y_b = old_rays_y_b
	local pos_from = Vector3()
	local pos_to = Vector3()
	local mvec3_set_static = mvector3.set_static
	local mvec3_set_z = mvector3.set_z
	local m_lerp = math.lerp
	local x_a, x_b, y_a, y_b = nil
	--- END OF BLOCK #0 ---

	FLOW; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #1 68-69, warpins: 2 ---
	--- END OF BLOCK #1 ---

	if i_ray_x_a <= nr_rays_x_a then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #38
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 70-70, warpins: 1 ---
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 71-72, warpins: 1 ---
	--- END OF BLOCK #3 ---

	if i_ray_x_a == 1 then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 73-75, warpins: 1 ---
	--- END OF BLOCK #4 ---

	slot26 = if not borders_a.x_neg then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 76-77, warpins: 2 ---
	--- END OF BLOCK #5 ---

	if i_ray_x_a == nr_rays_x_a then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 78-80, warpins: 1 ---
	--- END OF BLOCK #6 ---

	slot26 = if not borders_a.x_pos then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 81-86, warpins: 2 ---
	x_a = m_lerp(borders_a.x_neg, borders_a.x_pos, i_ray_x_a / nr_rays_x_a)
	--- END OF BLOCK #7 ---

	FLOW; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #8 87-88, warpins: 4 ---
	--- END OF BLOCK #8 ---

	if i_ray_y_a <= nr_rays_y_a then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #37
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 89-89, warpins: 1 ---
	--- END OF BLOCK #9 ---

	FLOW; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #10 90-91, warpins: 1 ---
	--- END OF BLOCK #10 ---

	if i_ray_y_a == 1 then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 92-94, warpins: 1 ---
	--- END OF BLOCK #11 ---

	slot28 = if not borders_a.y_neg then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 95-96, warpins: 2 ---
	--- END OF BLOCK #12 ---

	if i_ray_y_a == nr_rays_y_a then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 97-99, warpins: 1 ---
	--- END OF BLOCK #13 ---

	slot28 = if not borders_a.y_pos then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 100-105, warpins: 2 ---
	y_a = m_lerp(borders_a.y_neg, borders_a.y_pos, i_ray_y_a / nr_rays_y_a)

	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 106-120, warpins: 3 ---
	mvec3_set_static(pos_from, x_a, y_a)

	local room_a_z = self._get_room_height_at_pos(room_a.height, room_a.borders, pos_from) + 120

	mvec3_set_z(pos_from, room_a_z)

	--- END OF BLOCK #15 ---

	FLOW; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #16 121-122, warpins: 2 ---
	--- END OF BLOCK #16 ---

	if i_ray_x_b <= nr_rays_x_b then
	JUMP TO BLOCK #17
	else
	JUMP TO BLOCK #36
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #17 123-123, warpins: 1 ---
	--- END OF BLOCK #17 ---

	FLOW; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #18 124-125, warpins: 1 ---
	--- END OF BLOCK #18 ---

	if i_ray_x_b == 1 then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #20
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 126-128, warpins: 1 ---
	--- END OF BLOCK #19 ---

	slot27 = if not borders_b.x_neg then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #23
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 129-130, warpins: 2 ---
	--- END OF BLOCK #20 ---

	if i_ray_x_b == nr_rays_x_b then
	JUMP TO BLOCK #21
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #21 131-133, warpins: 1 ---
	--- END OF BLOCK #21 ---

	slot27 = if not borders_b.x_pos then
	JUMP TO BLOCK #22
	else
	JUMP TO BLOCK #23
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #22 134-139, warpins: 2 ---
	x_b = m_lerp(borders_b.x_neg, borders_b.x_pos, i_ray_x_b / nr_rays_x_b)
	--- END OF BLOCK #22 ---

	FLOW; TARGET BLOCK #23



	-- Decompilation error in this vicinity:
	--- BLOCK #23 140-141, warpins: 4 ---
	--- END OF BLOCK #23 ---

	if i_ray_y_b <= nr_rays_y_b then
	JUMP TO BLOCK #24
	else
	JUMP TO BLOCK #35
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #24 142-142, warpins: 1 ---
	--- END OF BLOCK #24 ---

	FLOW; TARGET BLOCK #25



	-- Decompilation error in this vicinity:
	--- BLOCK #25 143-145, warpins: 1 ---
	nr_rays = nr_rays + 1
	--- END OF BLOCK #25 ---

	if i_ray_y_b == 1 then
	JUMP TO BLOCK #26
	else
	JUMP TO BLOCK #27
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #26 146-148, warpins: 1 ---
	--- END OF BLOCK #26 ---

	slot29 = if not borders_b.y_neg then
	JUMP TO BLOCK #27
	else
	JUMP TO BLOCK #30
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #27 149-150, warpins: 2 ---
	--- END OF BLOCK #27 ---

	if i_ray_y_b == nr_rays_y_b then
	JUMP TO BLOCK #28
	else
	JUMP TO BLOCK #29
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #28 151-153, warpins: 1 ---
	--- END OF BLOCK #28 ---

	slot29 = if not borders_b.y_pos then
	JUMP TO BLOCK #29
	else
	JUMP TO BLOCK #30
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #29 154-159, warpins: 2 ---
	y_b = m_lerp(borders_b.y_neg, borders_b.y_pos, i_ray_y_b / nr_rays_y_b)

	--- END OF BLOCK #29 ---

	FLOW; TARGET BLOCK #30



	-- Decompilation error in this vicinity:
	--- BLOCK #30 160-187, warpins: 3 ---
	mvec3_set_static(pos_to, x_b, y_b)

	local room_b_z = self._get_room_height_at_pos(room_b.height, room_b.borders, pos_to) + 120

	mvec3_set_z(pos_to, room_b_z)

	local vis_ray = World:raycast("ray", pos_from, pos_to, "slot_mask", self._slotmask, "ray_type", "vis_graph")

	--- END OF BLOCK #30 ---

	slot32 = if not vis_ray then
	JUMP TO BLOCK #31
	else
	JUMP TO BLOCK #32
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #31 188-191, warpins: 1 ---
	return true, nr_rays
	--- END OF BLOCK #31 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #34



	-- Decompilation error in this vicinity:
	--- BLOCK #32 192-193, warpins: 1 ---
	--- END OF BLOCK #32 ---

	if nr_rays == nr_raycasts_allowed then
	JUMP TO BLOCK #33
	else
	JUMP TO BLOCK #34
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #33 194-200, warpins: 1 ---
	return false, nr_rays, i_ray_x_a, i_ray_y_a, i_ray_x_b, i_ray_y_b + 1

	--- END OF BLOCK #33 ---

	FLOW; TARGET BLOCK #34



	-- Decompilation error in this vicinity:
	--- BLOCK #34 201-202, warpins: 3 ---
	i_ray_y_b = i_ray_y_b + 1
	--- END OF BLOCK #34 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #23



	-- Decompilation error in this vicinity:
	--- BLOCK #35 203-205, warpins: 1 ---
	i_ray_y_b = 1
	i_ray_x_b = i_ray_x_b + 1
	--- END OF BLOCK #35 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #36 206-208, warpins: 1 ---
	i_ray_x_b = 1
	i_ray_y_a = i_ray_y_a + 1
	--- END OF BLOCK #36 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #37 209-211, warpins: 1 ---
	i_ray_y_a = 1
	i_ray_x_a = i_ray_x_a + 1

	--- END OF BLOCK #37 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #38 212-214, warpins: 1 ---
	return false, nr_rays
	--- END OF BLOCK #38 ---



end

function NavFieldBuilder:_set_rooms_visible(i_room_a, i_room_b)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-9, warpins: 1 ---
	local room_a = self._rooms[i_room_a]
	local room_b = self._rooms[i_room_b]
	slot5 = self._room_visibility_data
	--- END OF BLOCK #0 ---

	slot6 = if not self._room_visibility_data[i_room_a] then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 10-10, warpins: 1 ---
	slot6 = {}
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 11-16, warpins: 2 ---
	slot5[i_room_a] = slot6
	slot5 = self._room_visibility_data
	--- END OF BLOCK #2 ---

	slot6 = if not self._room_visibility_data[i_room_b] then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 17-17, warpins: 1 ---
	slot6 = {}
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 18-27, warpins: 2 ---
	slot5[i_room_b] = slot6
	self._room_visibility_data[i_room_a][i_room_b] = true
	self._room_visibility_data[i_room_b][i_room_a] = true

	return
	--- END OF BLOCK #4 ---



end

function NavFieldBuilder:_create_visibility_groups(nav_seg_id)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local all_rooms = self._rooms
	local nav_segments = self._nav_segments
	self._visibility_groups = {}
	local vis_groups = self._visibility_groups
	--- END OF BLOCK #0 ---

	slot1 = if nav_seg_id then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 8-11, warpins: 1 ---
	nav_segments[nav_seg_id].vis_groups = {}

	--- END OF BLOCK #1 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #2 12-15, warpins: 1 ---
	--- END OF BLOCK #2 ---

	for nav_seg_id, nav_seg in pairs(nav_segments)


	LOOP BLOCK #3
	GO OUT TO BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #3 16-17, warpins: 1 ---
	nav_seg.vis_groups = {}
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 18-19, warpins: 2 ---
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #5 20-23, warpins: 2 ---
	local sorted_vis_list = self:_sort_rooms_according_to_visibility()
	local search_index = #sorted_vis_list
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 24-26, warpins: 2 ---
	--- END OF BLOCK #6 ---

	if search_index > 0 then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #13
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 27-27, warpins: 1 ---
	--- END OF BLOCK #7 ---

	FLOW; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #8 28-34, warpins: 1 ---
	local search_i = sorted_vis_list[search_index].i_room
	--- END OF BLOCK #8 ---

	slot8 = if not self._rooms[search_i].vis_group then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 35-62, warpins: 1 ---
	local search_stack = {}
	search_stack[1] = search_i
	local searched_rooms = {}
	local room = all_rooms[search_i]
	local pos = self:_calculate_room_center(room)
	local segment = room.segment
	local my_vis_group = {}
	my_vis_group.rooms = {}
	my_vis_group.pos = pos
	my_vis_group.vis_groups = {}
	my_vis_group.seg = segment

	table.insert(vis_groups, my_vis_group)

	local i_vis_group = #vis_groups

	table.insert(nav_segments[segment].vis_groups, i_vis_group)

	--- END OF BLOCK #9 ---

	FLOW; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #10 63-63, warpins: 2 ---
	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 64-91, warpins: 1 ---
	local top_stack_room_i = search_stack[1]
	my_vis_group.rooms[top_stack_room_i] = true

	self:_add_visible_neighbours_to_stack(top_stack_room_i, search_stack, searched_rooms, self._room_visibility_data[top_stack_room_i], my_vis_group.rooms, my_vis_group.pos)

	searched_rooms[top_stack_room_i] = true
	all_rooms[top_stack_room_i].vis_group = i_vis_group

	table.remove(search_stack, 1)
	--- END OF BLOCK #11 ---

	slot16 = if not next(search_stack)

	 then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 92-93, warpins: 2 ---
	search_index = search_index - 1

	--- END OF BLOCK #12 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #13 94-94, warpins: 1 ---
	return
	--- END OF BLOCK #13 ---



end

function NavFieldBuilder:_add_visible_neighbours_to_stack(i_room, search_stack, searched_rooms, vip_list, rooms_in_group, node_pos)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local rooms = self._rooms
	local room = rooms[i_room]
	local segment = room.segment

	--- END OF BLOCK #0 ---

	for side_str, door_list in pairs(room.doors)

	LOOP BLOCK #1
	GO OUT TO BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #1 8-11, warpins: 1 ---
	--- END OF BLOCK #1 ---

	for i_door, door_id in pairs(door_list)


	LOOP BLOCK #2
	GO OUT TO BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #2 12-17, warpins: 1 ---
	local door_data = self._room_doors[door_id]
	--- END OF BLOCK #2 ---

	if door_data.rooms[1] == i_room then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 18-21, warpins: 1 ---
	--- END OF BLOCK #3 ---

	slot21 = if not door_data.rooms[2] then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 22-23, warpins: 2 ---
	local i_neighbour_room = door_data.rooms[1]
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 24-27, warpins: 2 ---
	local neighbour_room = rooms[i_neighbour_room]
	--- END OF BLOCK #5 ---

	slot23 = if vip_list[i_neighbour_room] then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 28-30, warpins: 1 ---
	--- END OF BLOCK #6 ---

	slot23 = if not searched_rooms[i_neighbour_room] then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 31-33, warpins: 1 ---
	--- END OF BLOCK #7 ---

	slot23 = if not neighbour_room.vis_group then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 34-36, warpins: 1 ---
	--- END OF BLOCK #8 ---

	if segment == neighbour_room.segment then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 37-41, warpins: 1 ---
	local accepted = true

	--- END OF BLOCK #9 ---

	for i_room, _ in pairs(rooms_in_group)


	LOOP BLOCK #10
	GO OUT TO BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #10 42-46, warpins: 1 ---
	--- END OF BLOCK #10 ---

	slot29 = if not self._room_visibility_data[i_neighbour_room][i_room] then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 47-48, warpins: 1 ---
	accepted = false

	--- END OF BLOCK #11 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #12 49-50, warpins: 2 ---
	--- END OF BLOCK #12 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #13 51-52, warpins: 2 ---
	--- END OF BLOCK #13 ---

	slot23 = if accepted then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 53-57, warpins: 1 ---
	table.insert(search_stack, i_neighbour_room)

	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 58-59, warpins: 7 ---
	--- END OF BLOCK #15 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #16 60-61, warpins: 2 ---
	--- END OF BLOCK #16 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #17 62-62, warpins: 1 ---
	return
	--- END OF BLOCK #17 ---



end

function NavFieldBuilder:_sort_rooms_according_to_visibility()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-5, warpins: 1 ---
	local sorted_vis_list = {}

	--- END OF BLOCK #0 ---

	for i_room, vis_room_list in ipairs(self._room_visibility_data)


	LOOP BLOCK #1
	GO OUT TO BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #1 6-16, warpins: 1 ---
	local my_borders = self._rooms[i_room].borders
	local my_total_area = self:_calc_room_area(my_borders)
	local my_data = {}
	my_data.i_room = i_room
	my_data.area = my_total_area
	local search_index = #sorted_vis_list
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 17-19, warpins: 2 ---
	--- END OF BLOCK #2 ---

	if search_index > 0 then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 20-23, warpins: 1 ---
	--- END OF BLOCK #3 ---

	if my_total_area < sorted_vis_list[search_index].area then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 24-24, warpins: 1 ---
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 25-26, warpins: 1 ---
	search_index = search_index - 1

	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #6 27-32, warpins: 2 ---
	table.insert(sorted_vis_list, search_index + 1, my_data)

	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 33-34, warpins: 2 ---
	--- END OF BLOCK #7 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #8 35-35, warpins: 1 ---
	return sorted_vis_list
	--- END OF BLOCK #8 ---



end

function NavFieldBuilder:_calc_room_area(borders)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-8, warpins: 1 ---
	return (borders.x_pos - borders.x_neg) * (borders.y_pos - borders.y_neg)
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_calculate_room_center(room)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-23, warpins: 1 ---
	local borders = room.borders
	local pos = Vector3((borders.x_pos + borders.x_neg) * 0.5, (borders.y_pos + borders.y_neg) * 0.5, 0)
	local pos_z = self._get_room_height_at_pos(room.height, borders, pos)

	mvector3.set_z(pos, pos_z)

	return pos
	--- END OF BLOCK #0 ---



end

function NavFieldBuilder:_link_visibility_groups()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	for i_group, group in ipairs(self._visibility_groups)

	LOOP BLOCK #1
	GO OUT TO BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-8, warpins: 1 ---
	--- END OF BLOCK #1 ---

	for i_room, _ in pairs(group.rooms)


	LOOP BLOCK #2
	GO OUT TO BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #2 9-14, warpins: 1 ---
	local visible_rooms = self._room_visibility_data[i_room]

	--- END OF BLOCK #2 ---

	for i_vis_room, _ in pairs(visible_rooms)


	LOOP BLOCK #3
	GO OUT TO BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #3 15-21, warpins: 1 ---
	local test_vis_group = self._rooms[i_vis_room].vis_group
	--- END OF BLOCK #3 ---

	slot18 = if not group.vis_groups[test_vis_group] then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 22-23, warpins: 1 ---
	--- END OF BLOCK #4 ---

	if test_vis_group ~= i_group then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 24-26, warpins: 1 ---
	group.vis_groups[test_vis_group] = true

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 27-28, warpins: 4 ---
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #7 29-30, warpins: 2 ---
	--- END OF BLOCK #7 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #1



	-- Decompilation error in this vicinity:
	--- BLOCK #8 31-32, warpins: 2 ---
	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #9 33-33, warpins: 1 ---
	return
	--- END OF BLOCK #9 ---



end

function NavFieldBuilder:_generate_coarse_navigation_graph()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-9, warpins: 1 ---
	local neg_dir_str = self._neg_dir_str_map
	local all_vis_groups = self._visibility_groups
	local all_segments = self._nav_segments
	local all_rooms = self._rooms
	local all_doors = self._room_doors

	--- END OF BLOCK #0 ---

	for seg_id, seg in pairs(self._nav_segments)


	LOOP BLOCK #1
	GO OUT TO BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #1 10-11, warpins: 1 ---
	seg.neighbours = {}

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 12-13, warpins: 2 ---
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #3 14-17, warpins: 1 ---
	--- END OF BLOCK #3 ---

	for seg_id, seg in pairs(self._nav_segments)


	LOOP BLOCK #4
	GO OUT TO BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #4 18-24, warpins: 1 ---
	local my_discovered_segments = {}
	local neighbours = seg.neighbours
	local vis_groups = seg.vis_groups

	--- END OF BLOCK #4 ---

	for _, i_vis_group in ipairs(vis_groups)


	LOOP BLOCK #5
	GO OUT TO BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #5 25-27, warpins: 1 ---
	local vis_group = all_vis_groups[i_vis_group]
	--- END OF BLOCK #5 ---

	slot19 = if vis_group then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #20
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 28-32, warpins: 1 ---
	local group_rooms = vis_group.rooms

	--- END OF BLOCK #6 ---

	for i_room, _ in pairs(group_rooms)


	LOOP BLOCK #7
	GO OUT TO BLOCK #20



	-- Decompilation error in this vicinity:
	--- BLOCK #7 33-37, warpins: 1 ---
	local room = all_rooms[i_room]

	--- END OF BLOCK #7 ---

	for dir_str, door_list in pairs(room.doors)


	LOOP BLOCK #8
	GO OUT TO BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #8 38-42, warpins: 1 ---
	local is_neg = neg_dir_str[dir_str]

	--- END OF BLOCK #8 ---

	for door_index, id_door in pairs(door_list)


	LOOP BLOCK #9
	GO OUT TO BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #9 43-46, warpins: 1 ---
	local door = all_doors[id_door]
	slot39 = door.rooms
	--- END OF BLOCK #9 ---

	slot32 = if is_neg then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 47-48, warpins: 1 ---
	slot40 = 1
	--- END OF BLOCK #10 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #11 49-49, warpins: 1 ---
	slot40 = 2
	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 50-54, warpins: 2 ---
	local i_neighbour_room = slot39[slot40]
	local neighbour_seg_id = all_rooms[i_neighbour_room].segment
	--- END OF BLOCK #12 ---

	if neighbour_seg_id ~= seg_id then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 55-57, warpins: 1 ---
	local neighbour_doors = neighbours[neighbour_seg_id]
	--- END OF BLOCK #13 ---

	slot41 = if not neighbour_doors then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 58-70, warpins: 1 ---
	neighbour_doors = {}
	neighbours[neighbour_seg_id] = neighbour_doors
	all_segments[neighbour_seg_id].neighbours[seg_id] = neighbour_doors
	my_discovered_segments[neighbour_seg_id] = true

	table.insert(neighbour_doors, id_door)
	--- END OF BLOCK #14 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #15 71-73, warpins: 1 ---
	--- END OF BLOCK #15 ---

	slot42 = if my_discovered_segments[neighbour_seg_id] then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 74-78, warpins: 1 ---
	table.insert(neighbour_doors, id_door)

	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 79-80, warpins: 5 ---
	--- END OF BLOCK #17 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #8



	-- Decompilation error in this vicinity:
	--- BLOCK #18 81-82, warpins: 2 ---
	--- END OF BLOCK #18 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #19 83-84, warpins: 2 ---
	--- END OF BLOCK #19 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #20 85-86, warpins: 3 ---
	--- END OF BLOCK #20 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #21 87-88, warpins: 2 ---
	--- END OF BLOCK #21 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #22 89-89, warpins: 1 ---
	return
	--- END OF BLOCK #22 ---



end

function NavFieldBuilder:set_nav_seg_metadata(nav_seg_id, param_name, param_value)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-3, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot4 = if not self._nav_segments then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 4-4, warpins: 1 ---
	return

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 5-8, warpins: 2 ---
	local nav_seg = self._nav_segments[nav_seg_id]

	--- END OF BLOCK #2 ---

	slot4 = if not nav_seg then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 9-9, warpins: 1 ---
	return

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 10-11, warpins: 2 ---
	nav_seg[param_name] = param_value

	return
	--- END OF BLOCK #4 ---



end
