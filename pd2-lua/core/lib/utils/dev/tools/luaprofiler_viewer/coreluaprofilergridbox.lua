core:module("CoreLuaProfilerGridBox")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreKeywordArguments")

local parse_kwargs = CoreKeywordArguments.parse_kwargs
local DEFAULT = Vector3(1, 1, 1)
local HIGHLIGHTED = Vector3(0.8, 0.8, 1)
local PERCENT = 0
local SECONDS = 1
local PLAIN = 2
local DEFAULT_FORMAT = PERCENT
LuaProfilerGridBox = LuaProfilerGridBox or CoreClass.class()

function LuaProfilerGridBox:init(...)
	local args = CoreKeywordArguments.KeywordArguments:new(...)
	self._ews_parent = args:mandatory_object("parent")

	args:assert_all_consumed()

	self._lpd = nil
	self.panel = EWS:Panel(self._ews_parent, "", "")
	self._listctrl = EWS:ListCtrl(self.panel, "", "LC_REPORT,LC_SINGLE_SEL")
	self._item2fnid = {}
	self._baseheader = {
		"Func",
		"File",
		"Line",
		"Total time",
		"Local time",
		"Children time",
		"No. Calls",
		"No. Sub Calls"
	}
	self._sortcolumn = 1
	self._sortreverse = false
	self._displayformat = DEFAULT_FORMAT

	self._listctrl:connect("EVT_COMMAND_LIST_ITEM_SELECTED", CoreEvent.callback(self, self, "_on_select"))
	self._listctrl:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", CoreEvent.callback(self, self, "_on_activate"))
	self._listctrl:connect("EVT_COMMAND_LIST_COL_CLICK", CoreEvent.callback(self, self, "_on_column"))

	self.box_sizer = EWS:BoxSizer("HORIZONTAL")

	self.box_sizer:add(self._listctrl, 1, 0, "EXPAND")
	self.panel:set_sizer(self.box_sizer)
end

function LuaProfilerGridBox:set_treeview(...)
	self._treeview = parse_kwargs({
		...
	}, "table:treeview")
end

function LuaProfilerGridBox:destroy()
	self._lpd = nil
	self._item2fnid = {}

	self._listctrl:clear_all()
	self._listctrl:destroy()

	self._listctrl = nil
	self._treeview = nil
end

function LuaProfilerGridBox:set_profilerdata(...)
	self._lpd, self._displayformat = parse_kwargs({
		...
	}, "userdata:lpd", "number:displayformat")
	self._highlightedfuncnode = nil
	self._item2fnid = {}

	for fnid = 0, self._lpd:numfuncnodes() - 1 do
		table.insert(self._item2fnid, fnid)
	end

	self._listctrl:clear_all()

	for _, n in ipairs(self._baseheader) do
		self._listctrl:append_column(n, "")
	end

	for i = 0, self._lpd:numheaders() - 1 do
		local name = self._lpd:headername(i)

		self._listctrl:append_column("Diff " .. string.capitalize(name), "")
		self._listctrl:append_column("Peak " .. string.capitalize(name), "")
	end

	self:_redraw()
end

function LuaProfilerGridBox:set_displayformat(...)
	self._displayformat = parse_kwargs({
		...
	}, "number:displayformat")

	if self._lpd ~= nil then
		local frametime = self._lpd:frametime()

		for i, fnid in ipairs(self._item2fnid) do
			if self._displayformat ~= SECONDS then
				self._listctrl:set_item(i - 1, 3, string.format("%6.3f %%", 100 * self._lpd:fn_total_time(fnid) / frametime))
				self._listctrl:set_item(i - 1, 4, string.format("%6.3f %%", 100 * self._lpd:fn_local_time(fnid) / frametime))
				self._listctrl:set_item(i - 1, 5, string.format("%6.3f %%", 100 * self._lpd:fn_children_time(fnid) / frametime))
			else
				self._listctrl:set_item(i - 1, 3, string.format("%8.3f ms", 1000 * self._lpd:fn_total_time(fnid)))
				self._listctrl:set_item(i - 1, 4, string.format("%8.3f ms", 1000 * self._lpd:fn_local_time(fnid)))
				self._listctrl:set_item(i - 1, 5, string.format("%8.3f ms", 1000 * self._lpd:fn_children_time(fnid)))
			end
		end
	end
end

function LuaProfilerGridBox:_redraw()
	if self._lpd ~= nil then
		self:_sort_funcnodes()
		self._listctrl:delete_all_items()

		local frametime = self._lpd:frametime()

		for i, fnid in ipairs(self._item2fnid) do
			self._listctrl:insert_item(i - 1, self._lpd:fn_func(fnid))
			self._listctrl:set_item(i - 1, 1, self._lpd:fn_file(fnid))
			self._listctrl:set_item(i - 1, 2, self._lpd:fn_line(fnid))

			if self._displayformat ~= SECONDS then
				self._listctrl:set_item(i - 1, 3, string.format("%6.3f %%", 100 * self._lpd:fn_total_time(fnid) / frametime))
				self._listctrl:set_item(i - 1, 4, string.format("%6.3f %%", 100 * self._lpd:fn_local_time(fnid) / frametime))
				self._listctrl:set_item(i - 1, 5, string.format("%6.3f %%", 100 * self._lpd:fn_children_time(fnid) / frametime))
			else
				self._listctrl:set_item(i - 1, 3, string.format("%8.3f ms", 1000 * self._lpd:fn_total_time(fnid)))
				self._listctrl:set_item(i - 1, 4, string.format("%8.3f ms", 1000 * self._lpd:fn_local_time(fnid)))
				self._listctrl:set_item(i - 1, 5, string.format("%8.3f ms", 1000 * self._lpd:fn_children_time(fnid)))
			end

			self._listctrl:set_item(i - 1, 6, self._lpd:fn_num_calls(fnid))
			self._listctrl:set_item(i - 1, 7, self._lpd:fn_num_sub_calls(fnid))

			local j = 8

			for k = 0, self._lpd:numheaders() - 1 do
				self._listctrl:set_item(i - 1, j, string.format("%s", self._lpd:fn_diff(fnid, k)))
				self._listctrl:set_item(i - 1, j + 1, string.format("%s", self._lpd:fn_peak(fnid, k)))

				j = j + 2
			end
		end

		if self._highlightedfuncnode then
			self:_highlight(self._highlightedfuncnode)
		end
	end
end

function LuaProfilerGridBox:_sort_funcnodes()
	local convert = nil

	if self._sortcolumn == 1 then
		function convert(fnid)
			return string.lower(self._lpd:fn_func(fnid))
		end
	elseif self._sortcolumn == 2 then
		function convert(fnid)
			return string.lower(self._lpd:fn_file(fnid))
		end
	elseif self._sortcolumn == 3 then
		function convert(fnid)
			return tonumber(self._lpd:fn_line(fnid))
		end
	elseif self._sortcolumn == 4 then
		function convert(fnid)
			return self._lpd:fn_total_time(fnid)
		end
	elseif self._sortcolumn == 5 then
		function convert(fnid)
			return self._lpd:fn_local_time(fnid)
		end
	elseif self._sortcolumn == 6 then
		function convert(fnid)
			return self._lpd:fn_children_time(fnid)
		end
	elseif self._sortcolumn == 7 then
		function convert(fnid)
			return self._lpd:fn_num_calls(fnid)
		end
	elseif self._sortcolumn == 8 then
		function convert(fnid)
			return self._lpd:fn_num_sub_calls(fnid)
		end
	else
		local i = self._sortcolumn - 9
		local index = math.floor(i / 2)

		if i % 2 == 0 then
			function convert(fnid)
				return self._lpd:fn_diff(fnid, index)
			end
		else
			function convert(fnid)
				return self._lpd:fn_peak(fnid, index)
			end
		end
	end

	function sort(fn1, fn2)
		if self._sortreverse then
			return convert(fn2) < convert(fn1)
		else
			return convert(fn1) < convert(fn2)
		end
	end

	table.sort(self._item2fnid, sort)
end

function LuaProfilerGridBox:deselect_and_highlight(...)
	local fnid = parse_kwargs({
		...
	}, "number:fnid")

	self._listctrl:set_item_selected(self._listctrl:selected_item(), false)
	self:_highlight(fnid)
end

function LuaProfilerGridBox:_highlight(fnid)
	self._highlightedfuncnode = fnid

	for i, fnid_ in ipairs(self._item2fnid) do
		if fnid_ == fnid then
			self._listctrl:set_item_background_colour(i - 1, HIGHLIGHTED)
		else
			self._listctrl:set_item_background_colour(i - 1, DEFAULT)
		end
	end
end

function LuaProfilerGridBox:_on_select()
	local i = self._listctrl:selected_item()

	self._treeview:deselect_and_highlight({
		fnid = self._item2fnid[i + 1]
	})
	self:_highlight(self._item2fnid[i + 1])
end

function LuaProfilerGridBox:_on_activate()
	local i = self._listctrl:selected_item()

	self._treeview:deselect_and_expand({
		fnid = self._item2fnid[i + 1]
	})
end

function LuaProfilerGridBox:_on_column(id, f)
	local column = f:get_column() + 1

	if column == self._sortcolumn then
		self._sortreverse = not self._sortreverse
	else
		self._sortcolumn = column
		self._sortreverse = false
	end

	self:_redraw()
end
