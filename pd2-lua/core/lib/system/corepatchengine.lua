function Idstring:id()
	return self
end

function string:id()
	return Idstring(self)
end

function string:t()
	return Idstring(self):t()
end

function string:s()
	return self
end

function string:key()
	return Idstring(self):key()
end

function string:raw()
	return Idstring(self):raw()
end

if Vector3 then
	function Vector3.__concat(o1, o2)
		return tostring(o1) .. tostring(o2)
	end

	function Vector3:flat(v)
		return math.cross(math.cross(v, self), v)
	end

	function Vector3:orthogonal(ratio)
		return self:orthogonal_func()(ratio)
	end

	function Vector3:orthogonal_func(start_dir)
		local rot = Rotation(self, start_dir or Vector3(0, 0, -1))

		return function (ratio)
			return (-rot:z() * math.cos(180 + 360 * ratio) + rot:x() * math.cos(90 + 360 * ratio)):normalized()
		end
	end

	function Vector3:unpack()
		return self.x, self.y, self.z
	end
end

if Color then
	function Color:unpack()
		return self.r, self.g, self.b
	end
end

local AppClass = getmetatable(Application)

if AppClass then
	function AppClass:draw_box(s_pos, e_pos, r, g, b)
		Application:draw_line(s_pos, Vector3(e_pos.x, s_pos.y, s_pos.z), r, g, b)
		Application:draw_line(s_pos, Vector3(s_pos.x, e_pos.y, s_pos.z), r, g, b)
		Application:draw_line(Vector3(e_pos.x, e_pos.y, s_pos.z), Vector3(s_pos.x, e_pos.y, s_pos.z), r, g, b)
		Application:draw_line(Vector3(e_pos.x, e_pos.y, s_pos.z), Vector3(e_pos.x, s_pos.y, s_pos.z), r, g, b)
		Application:draw_line(s_pos, Vector3(s_pos.x, s_pos.y, e_pos.z), r, g, b)
		Application:draw_line(Vector3(s_pos.x, e_pos.y, s_pos.z), Vector3(s_pos.x, e_pos.y, e_pos.z), r, g, b)
		Application:draw_line(Vector3(e_pos.x, s_pos.y, s_pos.z), Vector3(e_pos.x, s_pos.y, e_pos.z), r, g, b)
		Application:draw_line(Vector3(e_pos.x, e_pos.y, s_pos.z), Vector3(e_pos.x, e_pos.y, e_pos.z), r, g, b)
		Application:draw_line(Vector3(s_pos.x, s_pos.y, e_pos.z), Vector3(e_pos.x, s_pos.y, e_pos.z), r, g, b)
		Application:draw_line(Vector3(s_pos.x, s_pos.y, e_pos.z), Vector3(s_pos.x, e_pos.y, e_pos.z), r, g, b)
		Application:draw_line(Vector3(e_pos.x, e_pos.y, e_pos.z), Vector3(s_pos.x, e_pos.y, e_pos.z), r, g, b)
		Application:draw_line(Vector3(e_pos.x, e_pos.y, e_pos.z), Vector3(e_pos.x, s_pos.y, e_pos.z), r, g, b)
	end

	function AppClass:draw_box_rotation(pos, rot, width, depth, height, r, g, b)
		local c1 = pos
		local c2 = pos + rot:x() * width
		local c3 = pos + rot:y() * depth
		local c4 = pos + rot:x() * width + rot:y() * depth
		local c5 = c1 + rot:z() * height
		local c6 = c2 + rot:z() * height
		local c7 = c3 + rot:z() * height
		local c8 = c4 + rot:z() * height

		Application:draw_line(c1, c2, r, g, b)
		Application:draw_line(c1, c3, r, g, b)
		Application:draw_line(c2, c4, r, g, b)
		Application:draw_line(c3, c4, r, g, b)
		Application:draw_line(c1, c5, r, g, b)
		Application:draw_line(c2, c6, r, g, b)
		Application:draw_line(c3, c7, r, g, b)
		Application:draw_line(c4, c8, r, g, b)
		Application:draw_line(c5, c6, r, g, b)
		Application:draw_line(c5, c7, r, g, b)
		Application:draw_line(c6, c8, r, g, b)
		Application:draw_line(c7, c8, r, g, b)
	end

	function AppClass:draw_rotation_size(pos, rot, size)
		Application:draw_line(pos, pos + rot:x() * size, 1, 0, 0)
		Application:draw_line(pos, pos + rot:y() * size, 0, 1, 0)
		Application:draw_line(pos, pos + rot:z() * size, 0, 0, 1)
	end

	function AppClass:draw_arrow(from, to, r, g, b, scale)
		scale = scale or 1
		local len = (to - from):length()
		local dir = (to - from):normalized()
		local arrow_end_pos = from + dir * (len - 100 * scale)

		Application:draw_cylinder(from, arrow_end_pos, 10 * scale, r, g, b)
		Application:draw_cone(to, arrow_end_pos, 40 * scale, r, g, b)
	end

	function AppClass:stack_dump_error(...)
		Application:error(...)
		Application:stack_dump()
	end
end

if Draw then
	Draw:pen()

	function Pen:arrow(from, to, scale)
		scale = scale or 1
		local len = (to - from):length()
		local dir = (to - from):normalized()
		local arrow_end_pos = from + dir * (len - 100 * scale)

		self:cylinder(from, arrow_end_pos, 10 * scale)
		self:cone(to, arrow_end_pos, 40 * scale)
	end
end

local SteamClass = getmetatable(Steam)

if SteamClass then
	local steam_http_request = Steam.http_request
	local requests = {}
	local current_request, check_requests_func, request_done_func = nil

	function request_done_func(success, page)
		if current_request then
			local request_clbk = current_request[2]
			current_request = nil

			request_clbk(success, page)
		end

		check_requests_func()
	end

	function check_requests_func()
		if not current_request then
			current_request = table.remove(requests, 1)

			if current_request then
				if current_request[3] and type(current_request[3]) == "table" then
					steam_http_request(Steam, current_request[1], request_done_func, current_request[3])
				else
					steam_http_request(Steam, current_request[1], request_done_func)
				end
			end
		end
	end

	function SteamClass:http_request(path, clbk, id_key)
		if id_key then
			if current_request and current_request[3] and current_request[3] == id_key then
				return
			end

			for _, d in ipairs(requests) do
				if d[3] and d[3] == id_key then
					requests[_] = {
						path,
						clbk,
						id_key
					}

					check_requests_func()

					return
				end
			end
		end

		table.insert(requests, {
			path,
			clbk,
			id_key
		})
		check_requests_func()
	end
end
