UiPlacer = UiPlacer or class()

function UiPlacer:init(x, y, padding_x, padding_y)
	self._padding_x = padding_x or 0
	self._padding_y = padding_y or 0
	x = x or 0
	y = y or 0
	self._start_x = x
	self._start_y = y
	self._left = x
	self._right = x
	self._top = y
	self._bottom = y
	self._most = {
		left = x + self._padding_x,
		right = x,
		top = y + self._padding_y,
		bottom = y
	}
	self._stack = {}
	self._first = true
end

function UiPlacer:create_branch(use_root_level, use_stack)
	local rtn = BranchPlacer:new(self)
	rtn._padding_x = self._padding_x
	rtn._padding_y = self._padding_y
	rtn._start_x = self._start_x
	rtn._start_y = self._start_y
	rtn._left = self._left
	rtn._right = self._right
	rtn._top = self._top
	rtn._bottom = self._bottom
	rtn._first = self._first
	rtn._keep = self._keep
	rtn._most = use_root_level and self._stack[1] or self._most
	rtn._stack = use_stack and self._stack or {}
end

function UiPlacer:set_padding(x, y)
	self._padding_x = x or self._padding_x
	self._padding_y = y or self._padding_y
end

function UiPlacer:set_keep_current(val)
	self._keep = val
end

function UiPlacer:stop_keeping()
	self._keep = nil
end

function UiPlacer:set_at_from(item)
	self:_update_most(item:left(), item:top(), item:rightbottom())

	if self._keep then
		if type(self._keep) == "number" then
			self._keep = self._keep - 1
			self._keep = self._keep > 0 and self._keep or nil
		end

		return
	end

	self._left, self._top = item:lefttop()
	self._right, self._bottom = item:rightbottom()
	self._first = nil
end

function UiPlacer:_update_most(l, t, r, b, from_branch)
	if from_branch then
		return
	end

	self._most.left = math.min(self._most.left, l)
	self._most.top = math.min(self._most.top, t)
	self._most.right = math.max(self._most.right, r)
	self._most.bottom = math.max(self._most.bottom, b)
end

function UiPlacer:set_start(x, y, dont_set_at)
	self._start_x = x or self._start_x
	self._start_y = y or self._start_y

	if dont_set_at then
		return
	end

	return self:set_at(x, y)
end

function UiPlacer:set_at(x, y)
	self._left = x or self._left
	self._right = x or self._right
	self._top = y or self._top
	self._bottom = y or self._bottom

	return x, y
end

function UiPlacer:_padd_x(val)
	if self._first then
		return val or 0
	end

	return val or self._padding_x
end

function UiPlacer:_padd_y(val)
	if self._first then
		return val or 0
	end

	return val or self._padding_y
end

function UiPlacer:add_right(item, padding)
	padding = self:_padd_x(padding)

	if item then
		item:set_lefttop(self._right + padding, self._top)
		self:set_at_from(item)
	else
		return self:set_at(self._right + padding, self._top)
	end

	return item
end

function UiPlacer:add_right_center(item, padding)
	padding = self:_padd_x(padding)

	if item then
		item:set_left(self._right + padding)
		item:set_center_y((self._top + self._bottom) / 2)
		self:set_at_from(item)
	else
		return self:set_at(self._right + padding, nil)
	end

	return item
end

function UiPlacer:add_left(item, padding)
	padding = self:_padd_x(padding)

	if item then
		item:set_righttop(self._left - padding, self._top)
		self:set_at_from(item)
	else
		return self:set_at(self._left - padding, self._top)
	end

	return item
end

function UiPlacer:add_left_center(item, padding)
	padding = self:_padd_x(padding)

	if item then
		item:set_right(self._left - padding)
		item:set_center_y((self._top + self._bottom) / 2)
		self:set_at_from(item)
	else
		return self:set_at(self._left - padding, nil)
	end

	return item
end

function UiPlacer:add_top(item, padding)
	padding = self:_padd_y(padding)

	if item then
		item:set_leftbottom(self._left, self._top - padding)
		self:set_at_from(item)
	else
		return self:set_at(self._left, self._top - padding)
	end

	return item
end

function UiPlacer:add_top_ralign(item, padding)
	padding = self:_padd_y(padding)

	if item then
		item:set_rightbottom(self._right, self._top - padding)
		self:set_at_from(item)
	else
		return self:set_at(self._left, self._top - padding)
	end

	return item
end

function UiPlacer:add_bottom(item, padding)
	padding = self:_padd_y(padding)

	if item then
		item:set_lefttop(self._left, self._bottom + padding)
		self:set_at_from(item)
	else
		return self:set_at(self._left, self._bottom + padding)
	end

	return item
end

function UiPlacer:add_bottom_ralign(item, padding)
	padding = self:_padd_y(padding)

	if item then
		item:set_righttop(self._right, self._bottom + padding)
		self:set_at_from(item)
	else
		return self:set_at(self._right, self._bottom + padding)
	end

	return item
end

function UiPlacer:new_row(padding_x, padding_y)
	padding_x = padding_x or 0
	padding_y = self:_padd_y(padding_y)

	self:set_at(self._start_x + padding_x, math.max(self._most.bottom, self._bottom) + padding_y)

	self._first = true
end

function UiPlacer:add_row(item, padding_x, padding_y)
	self:new_row(padding_x, padding_y)

	return self:add_right(item)
end

function UiPlacer:is_first_in_row()
	return self._first
end

function UiPlacer:_push(x, y)
	table.insert(self._stack, {
		self._start_x,
		self._start_y,
		self._most
	})

	self._start_x = x
	self._start_y = y
	self._most = {
		left = x + self._padding_x,
		top = y + self._padding_y,
		right = x,
		bottom = y
	}
end

function UiPlacer:push()
	table.insert(self._stack, {
		self._start_x,
		self._start_y,
		self._most
	})

	self._most = {
		bottom = -9999,
		right = -9999,
		left = self._most.right + 9999,
		top = self._most.bottom + 9999
	}
end

function UiPlacer:push_right()
	self:_push(self._right, self._top)
end

function UiPlacer:push_left()
	self:_push(self._left, self._top)
end

function UiPlacer:push_top()
	self:_push(self._left, self._top)
end

function UiPlacer:push_bottom()
	self:_push(self._left, self._bottom)
end

function UiPlacer:pop()
	self._left = self._most.left
	self._top = self._most.top
	self._right = self._most.right
	self._bottom = self._most.bottom
	local most = nil
	self._start_x, self._start_y, most = unpack(table.remove(self._stack))
	self._most.left = math.min(self._most.left, most.left)
	self._most.top = math.min(self._most.top, most.top)
	self._most.right = math.max(self._most.right, most.right)
	self._most.bottom = math.max(self._most.bottom, most.bottom)
end

function UiPlacer:corners()
	return self._left, self._top, self._right, self._bottom
end

function UiPlacer:current_right()
	return self._right
end

function UiPlacer:current_left()
	return self._left
end

function UiPlacer:current_top()
	return self._top
end

function UiPlacer:current_bottom()
	return self._bottom
end

function UiPlacer:current_center()
	return self._left + (self._right - self._left) / 2, self._top + (self._bottom - self._top) / 2
end

function UiPlacer:most()
	return self._most
end

function UiPlacer:most_corners()
	return self._most.left, self._most.top, self._most.right, self._most.bottom
end

function UiPlacer:most_rightbottom()
	return self._most.right, self._most.bottom
end

function UiPlacer:most_leftbottom()
	return self._most.left, self._most.bottom
end

BranchPlacer = BranchPlacer or class(UiPlacer)

function BranchPlacer:init(placer)
	self._from = placer
end

function BranchPlacer:_update_most(a, b, c, d, branch)
	self._from:_update_most(a, b, c, d, true)
	BranchPlacer.super._update_most(a, b, c, d, branch)
end

ResizingPlacer = ResizingPlacer or class(UiPlacer)

function ResizingPlacer:init(panel, config)
	self._panel = panel
	self._border_padding_x = config.border_x or config.border or 0
	self._border_padding_y = config.border_y or config.border or 0

	ResizingPlacer.super.init(self, config.x or self._border_padding_x, config.y or self._border_padding_y, config.padding_x or config.padding, config.padding_y or config.padding)
end

function ResizingPlacer:clear(keep_stack)
	if not keep_stack and #self._stack > 0 then
		self._start_x, self._start_y = unpack(self._stack[1])
		self._stack = {}
	end

	local x, y = self:set_at(self._start_x, self._start_y)
	self._most = {
		left = x + self._padding_x,
		right = x,
		top = y + self._padding_y,
		bottom = y
	}
	self._first = true
end

function ResizingPlacer:_update_most(...)
	ResizingPlacer.super._update_most(self, ...)

	if self._panel._ensure_size then
		self._panel:_ensure_size(self._most.right + self._border_padding_x, self._most.bottom + self._border_padding_y)
	else
		self._panel:set_size(self._most.right + self._border_padding_x, self._most.bottom + self._border_padding_y)
	end
end
