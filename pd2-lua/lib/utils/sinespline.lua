SineSpline = SineSpline or class()

function SineSpline:init(position_table, nr_subseg, curviness, first_control_point, last_control_point)
	self._segments = position_table
	self._manual_first_control_point = first_control_point
	self._manual_last_control_point = last_control_point
	self._curviness = curviness
	self._nr_subseg = nr_subseg
	self._control_points = {}

	if first_control_point then
		self._control_points[1] = {
			p2 = first_control_point
		}
	end

	if last_control_point then
		self._control_points[#position_table] = {
			p1 = last_control_point
		}
	end
end

function SineSpline:prepare_walk_data(backward)
	if #self._segments > 1 then
		self._mvec3_1 = Vector3()
		self._mvec3_2 = Vector3()

		if backward then
			local nr_seg = #self._segments

			if not self._control_points[nr_seg - 1] then
				self:_extract_control_points_at_index(nr_seg - 1)
			end

			if not self._control_points[nr_seg] then
				self:_extract_control_points_at_index(nr_seg)
			end

			local next_subseg = self._segments[nr_seg]
			local cur_subseg = self:_position_at_time_on_segment((self._nr_subseg - 1) / self._nr_subseg, self._segments[nr_seg - 1], self._segments[nr_seg], self._control_points[nr_seg].p1, self._control_points[nr_seg - 1].p2)
			local subseg_len = mvector3.distance(cur_subseg, next_subseg)
			local playtime_data = {
				seg_i = nr_seg - 1,
				subseg_i = self._nr_subseg - 1,
				subseg_start = cur_subseg,
				subseg_end = next_subseg,
				subseg_dis = subseg_len,
				subseg_len = subseg_len
			}
			self._playtime_data = playtime_data
		else
			if not self._control_points[2] then
				self:_extract_control_points_at_index(2)
			end

			if not self._control_points[1] then
				self:_extract_control_points_at_index(1)
			end

			local cur_subseg = self._segments[1]
			local next_subseg = self:_position_at_time_on_segment(1 / self._nr_subseg, cur_subseg, self._segments[2], self._control_points[2].p1, self._control_points[1].p2)
			local subseg_len = mvector3.distance(cur_subseg, next_subseg)
			local playtime_data = {
				seg_i = 1,
				subseg_i = 1,
				subseg_start = cur_subseg,
				subseg_end = next_subseg,
				subseg_dis = 0,
				subseg_len = subseg_len
			}
			self._playtime_data = playtime_data
		end
	end
end

function SineSpline:delete_walk_data()
	self._mvec3_1 = nil
	self._mvec3_2 = nil
	self._control_points = {}
	self._playtime_data = nil
end

function SineSpline:_position_at_time_on_segment(seg_t, pos_start, pos_end, p1, p2)
	mvector3.lerp(self._mvec3_1, pos_start, p2, seg_t)
	mvector3.lerp(self._mvec3_2, p1, pos_end, seg_t)

	local xpo = (math.sin((seg_t * 2 - 1) * 90) + 1) * self._curviness

	return math.lerp(self._mvec3_1, self._mvec3_2, xpo)
end

function SineSpline:walk(delta_dis)
	local result_pos = nil

	if #self._segments > 1 then
		local segments = self._segments
		local play_data = self._playtime_data
		local new_subseg_dis = play_data.subseg_dis + delta_dis

		if new_subseg_dis < 0 then
			local undershot = new_subseg_dis

			repeat
				if play_data.subseg_i == 1 then
					if play_data.seg_i == 1 then
						play_data.subseg_dis = 0

						return segments[1], undershot
					else
						play_data.seg_i = play_data.seg_i - 1

						if not self._control_points[play_data.seg_i] then
							self:_extract_control_points_at_index(play_data.seg_i)
						end

						play_data.subseg_i = self._nr_subseg
						play_data.subseg_start = self:_position_at_time_on_segment((self._nr_subseg - 1) / self._nr_subseg, segments[play_data.seg_i], segments[play_data.seg_i + 1], self._control_points[play_data.seg_i + 1].p1, self._control_points[play_data.seg_i].p2)
						play_data.subseg_end = segments[play_data.seg_i + 1]
						play_data.subseg_len = mvector3.distance(play_data.subseg_start, play_data.subseg_end)
						new_subseg_dis = play_data.subseg_len + undershot
					end
				else
					play_data.subseg_i = play_data.subseg_i - 1
					play_data.subseg_end = play_data.subseg_start
					play_data.subseg_start = self:_position_at_time_on_segment(play_data.subseg_i / self._nr_subseg, segments[play_data.seg_i], segments[play_data.seg_i + 1], self._control_points[play_data.seg_i + 1].p1, self._control_points[play_data.seg_i].p2)
					play_data.subseg_len = mvector3.distance(play_data.subseg_start, play_data.subseg_end)
					new_subseg_dis = play_data.subseg_len + undershot
				end
			until new_subseg_dis > 0

			play_data.subseg_dis = new_subseg_dis

			return math.lerp(play_data.subseg_start, play_data.subseg_end, play_data.subseg_dis / play_data.subseg_len), play_data.subseg_i == 1 and undershot
		else
			while play_data.subseg_len < new_subseg_dis do
				local overshot = new_subseg_dis - play_data.subseg_len

				if play_data.subseg_i == self._nr_subseg then
					if play_data.seg_i == #segments - 1 then
						play_data.subseg_dis = play_data.subseg_len

						return segments[#segments], overshot
					else
						play_data.seg_i = play_data.seg_i + 1

						if not self._control_points[play_data.seg_i + 1] then
							self:_extract_control_points_at_index(play_data.seg_i + 1)
						end

						play_data.subseg_i = 1
						play_data.subseg_start = segments[play_data.seg_i]
						play_data.subseg_end = self:_position_at_time_on_segment(1 / self._nr_subseg, segments[play_data.seg_i], segments[play_data.seg_i + 1], self._control_points[play_data.seg_i + 1].p1, self._control_points[play_data.seg_i].p2)
						play_data.subseg_len = mvector3.distance(play_data.subseg_start, play_data.subseg_end)
						new_subseg_dis = overshot
					end
				else
					play_data.subseg_i = play_data.subseg_i + 1
					play_data.subseg_start = play_data.subseg_end
					play_data.subseg_end = self:_position_at_time_on_segment(play_data.subseg_i / self._nr_subseg, segments[play_data.seg_i], segments[play_data.seg_i + 1], self._control_points[play_data.seg_i + 1].p1, self._control_points[play_data.seg_i].p2)
					play_data.subseg_len = mvector3.distance(play_data.subseg_start, play_data.subseg_end)
					new_subseg_dis = overshot
				end
			end
		end

		play_data.subseg_dis = new_subseg_dis

		return math.lerp(play_data.subseg_start, play_data.subseg_end, play_data.subseg_dis / play_data.subseg_len), play_data.subseg_i == self._nr_subseg and play_data.subseg_len - play_data.subseg_dis
	else
		return self._segments[1]
	end
end

function SineSpline:_extract_control_points_at_index(index)
	local segments = self._segments
	local control_points = self._control_points
	local pos = segments[index]
	local segment_control_points = {}

	if index == #segments then
		if control_points[#segments - 1] then
			local last_seg = pos - segments[#segments - 1]
			local last_vec = (control_points[#segments - 1].p2 or segments[1]) - segments[#segments - 1]
			local last_angle = last_vec:angle(last_seg)
			local last_rot = last_seg:cross(last_vec)
			last_rot = Rotation(last_rot, 180 - 2 * last_angle)
			local w_vec = pos + last_vec:rotate_with(last_rot)
			segment_control_points.p1 = w_vec
		else
			segment_control_points.p1 = pos
		end
	elseif index == 1 then
		if control_points[2] then
			local first_vec = control_points[2].p1 - segments[2]
			local first_seg = segments[2] - segments[1]
			local first_angle = first_vec:angle(first_seg)
			local first_rot = first_seg:cross(first_vec)
			first_rot = Rotation(first_rot, 180 - 2 * first_angle)
			local w_vec = segments[1] + first_vec:rotate_with(first_rot)
			segment_control_points.p2 = w_vec
		else
			segment_control_points.p2 = pos
		end
	else
		local tan_seg = segments[index + 1] - segments[index - 1]

		mvector3.set_length(tan_seg, mvector3.distance(pos, segments[index - 1]) * self._curviness)

		segment_control_points.p1 = pos - tan_seg

		mvector3.set_length(tan_seg, mvector3.distance(pos, segments[index + 1]) * self._curviness)

		segment_control_points.p2 = pos + tan_seg
	end

	self._control_points[index] = segment_control_points
end
