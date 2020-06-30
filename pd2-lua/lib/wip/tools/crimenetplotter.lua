CrimeNetPlotter = CrimeNetPlotter or class()

function CrimeNetPlotter:init()
	self:create()
end

function CrimeNetPlotter:create()
	if self._ws then
		managers.gui_data:destroy_workspace(self._ws)
	end

	self._ws = managers.gui_data:create_fullscreen_workspace()

	self._ws:connect_mouse(Input:mouse())

	self._panel = self._ws:panel()
	self._crimenet = self._panel:bitmap({
		texture = "guis/textures/crimenet_map",
		layer = 10000
	})

	self._crimenet:mouse_press(callback(self, self, "mouse_press"))
	self._crimenet:mouse_release(callback(self, self, "mouse_release"))
	self._crimenet:mouse_move(callback(self, self, "mouse_move"))

	self._pointer = self._panel:rect({
		w = 2,
		h = 2,
		layer = 10002,
		color = Color.red
	})
	self._pure_lines = {}
	self._lines = {}
	self._temp_lines = {}
	self._old_polylines = {}

	if tweak_data.gui.crime_net.regions then
		for i, d in ipairs(tweak_data.gui.crime_net.regions) do
			local polyline = self._panel:polyline({
				line_width = 1,
				layer = 10001,
				color = Color.blue,
				closed = d.closed
			})
			local lines = {}

			for i = 1, #d[1] do
				table.insert(lines, Vector3(d[1][i], d[2][i], 0))
			end

			polyline:set_points(lines)
			table.insert(self._old_polylines, polyline)
		end
	end

	self._crimenet:stop()
	self._crimenet:animate(callback(self, self, "updator"))
end

function CrimeNetPlotter:updator()
	local dt = nil

	while true do
		dt = coroutine.yield()
		local x, y = self._ws:mouse_position()

		self._pointer:set_center(x, y)
	end
end

function CrimeNetPlotter:mouse_press(o, button, x, y)
	if button == Idstring("0") then
		if not self._polylines then
			self._polylines = self._panel:polyline({
				line_width = 1,
				layer = 10001,
				color = Color.green
			})
		end

		table.insert(self._pure_lines, Vector3(x - self._crimenet:x(), y - self._crimenet:y(), 0))
		table.insert(self._lines, Vector3(x - self._crimenet:x(), y - self._crimenet:y(), 0))
		self._polylines:set_points(self._lines)
	elseif button == Idstring("1") then
		self._grabbed_x = x
		self._grabbed_y = y
	elseif self._polylines then
		local text = "{ {"

		for i, d in ipairs(self._pure_lines) do
			text = text .. d.x .. (i ~= #self._pure_lines and ", " or "}, {")
		end

		for i, d in ipairs(self._pure_lines) do
			text = text .. d.y .. (i ~= #self._pure_lines and ", " or "} }")
		end

		print(text)
		self._polylines:set_points(self._lines)
		table.insert(self._old_polylines, self._polylines)
		self._polylines:set_color(Color(0.5, 0.5, 0.5))
		self._polylines:set_closed(true)

		self._polylines = nil
		self._lines = {}
		self._pure_lines = {}
	end
end

function CrimeNetPlotter:mouse_release(o, button, x, y)
	self._grabbed_x = nil
	self._grabbed_y = nil
end

function CrimeNetPlotter:mouse_move(o, x, y)
	if self._grabbed_x then
		self._crimenet:move(x - self._grabbed_x, 0)

		self._grabbed_x = x
	end

	if self._grabbed_y then
		self._crimenet:move(0, y - self._grabbed_y)

		self._grabbed_y = y
	end

	if self._polylines then
		self._temp_lines = {}

		for i, d in ipairs(self._lines) do
			table.insert(self._temp_lines, d)
		end

		table.insert(self._temp_lines, Vector3(x - self._crimenet:x(), y - self._crimenet:y(), 0))
		self._polylines:set_points(self._temp_lines)
		self._polylines:set_position(self._crimenet:position())
	end

	for i, d in ipairs(self._old_polylines) do
		d:set_position(self._crimenet:position())
	end
end

function CrimeNetPlotter:close()
	if self._ws then
		managers.gui_data:destroy_workspace(self._ws)
	end
end
