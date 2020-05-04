core:module("CoreLuaProfilerTreeBox")
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
local DEFAULT_INFOKEY = "total_time"
LuaProfilerTreeBox = LuaProfilerTreeBox or CoreClass.class()

function LuaProfilerTreeBox:init(...)
	local args = CoreKeywordArguments.KeywordArguments:new(...)
	self._ews_parent = args:mandatory_object("parent")

	args:assert_all_consumed()

	self._lpd = nil
	self.panel = EWS:Panel(self._ews_parent, "", "")
	self._treectrl = EWS:TreeCtrl(self.panel, "", "TR_HAS_BUTTONS")
	self._displayformat = DEFAULT_FORMAT
	self.__on_item_expanded_cb = CoreEvent.callback(self, self, "_on_item_expanded")

	self._treectrl:connect("EVT_COMMAND_TREE_SEL_CHANGED", CoreEvent.callback(self, self, "_on_select"))
	self._treectrl:connect("EVT_COMMAND_TREE_ITEM_EXPANDED", self.__on_item_expanded_cb)

	self.box_sizer = EWS:BoxSizer("HORIZONTAL")

	self.box_sizer:add(self._treectrl, 1, 1, "EXPAND")
	self.panel:set_sizer(self.box_sizer)
end

function LuaProfilerTreeBox:set_gridview(...)
	self._gridview = parse_kwargs({
		...
	}, "table:gridview")
end

function LuaProfilerTreeBox:destroy()
	self._lpd = nil

	self._treectrl:clear()
	self._treectrl:destroy()

	self._treectrl = nil
	self._gridview = nil
end

function LuaProfilerTreeBox:set_profilerdata(...)
	self._lpd, self._displayformat = parse_kwargs({
		...
	}, "userdata:lpd", "number:displayformat")

	self:_redraw()
end

function LuaProfilerTreeBox:set_displayformat(...)
	self._displayformat = parse_kwargs({
		...
	}, "number:displayformat")

	if self._lpd then
		function relabel(cnid)
			if self._lpd:cn_treenodeid(cnid) ~= -1 then
				local label = self:_makelabel(cnid)
				local tnid = self._lpd:cn_treenodeid(cnid)

				self._treectrl:set_item_text(tnid, label)
				self._treectrl:set_item_text_colour(tnid, Vector3(0, 0, 0))

				for i = 0, self._lpd:cn_numchildren(cnid) - 1 do
					relabel(self._lpd:cn_child(cnid, i))
				end

				for i = 0, self._lpd:cn_numexpensivechildren(cnid) - 1 do
					local echild = self._lpd:cn_expensivechild(cnid, i)
					local tnid = self._lpd:cn_treenodeid(echild)

					if tnid ~= -1 then
						self._treectrl:set_item_text_colour(tnid, Vector3(1, 0, 0))
					end
				end
			end
		end

		relabel(self._lpd:rootcallnode())
	end
end

function LuaProfilerTreeBox:_redraw()
	if self._lpd then
		self:_clear()
		self:_populate_rootnode()
		self:_populate_plus2(self._lpd:rootcallnode())

		local treenodeid = self._lpd:cn_treenodeid(self._lpd:rootcallnode())

		self._treectrl:expand(treenodeid)
	end
end

function LuaProfilerTreeBox:_clear()
	local function clear_treenodeid(cnid)
		if self._lpd:cn_treenodeid(cnid) ~= -1 then
			self._lpd:cn_settreenodeid(cnid, -1)

			for i = 0, self._lpd:cn_numchildren(cnid) - 1 do
				clear_treenodeid(self._lpd:cn_child(cnid, i))
			end
		end
	end

	clear_treenodeid(self._lpd:rootcallnode())
	self._treectrl:clear()
end

function LuaProfilerTreeBox:_populate_rootnode()
	local rnid = self._lpd:rootcallnode()
	local label = self:_makelabel(rnid)
	local treerootid = self._treectrl:append_root(label)

	self._lpd:cn_settreenodeid(rnid, treerootid)
end

function LuaProfilerTreeBox:_populate_plus2(cnid, plus1)
	local populated_children = false

	for i = 0, self._lpd:cn_numchildren(cnid) - 1 do
		local child_id = self._lpd:cn_child(cnid, i)

		if self._lpd:cn_treenodeid(child_id) == -1 then
			populated_children = true
			local label = self:_makelabel(child_id)
			local tnid = self._treectrl:append(self._lpd:cn_treenodeid(cnid), label)

			self._lpd:cn_settreenodeid(child_id, tnid)
		end

		if not plus1 then
			self:_populate_plus2(child_id, true)
		end
	end

	if populated_children then
		for i = 0, self._lpd:cn_numexpensivechildren(cnid) - 1 do
			local echild = self._lpd:cn_expensivechild(cnid, i)
			local tnid = self._lpd:cn_treenodeid(echild)

			self._treectrl:set_item_text_colour(tnid, Vector3(1, 0, 0))
		end
	end
end

function LuaProfilerTreeBox:_populate_path(cnid)
	local nodes2expand = {}

	while cnid ~= self._lpd:rootcallnode() do
		cnid = self._lpd:cn_parent(cnid)

		table.insert(nodes2expand, cnid)
	end

	for i = #nodes2expand, 1, -1 do
		self:_populate_plus2(nodes2expand[i])
	end
end

function LuaProfilerTreeBox:_on_item_expanded(_, tree_event)
	local tnid = tree_event:get_item()
	local cnid = self._lpd:find_callnode(tnid)

	self:_populate_plus2(cnid)
end

function LuaProfilerTreeBox:_makelabel(cnid)
	local frametime = self._lpd:frametime()
	local label = ""

	if cnid == self._lpd:rootcallnode() then
		if self._displayformat == PERCENT then
			label = label .. string.format("%6.2f%% LUA", 100 * self._lpd:cn_value(cnid) / frametime)
		elseif self._displayformat == SECONDS then
			label = label .. string.format("%6.2fms LUA", 1000 * self._lpd:cn_value(cnid))
		elseif self._displayformat == PLAIN then
			label = label .. string.format("LUA")
		end
	else
		if self._displayformat == PERCENT then
			label = label .. string.format("%6.3f%%  ", 100 * self._lpd:cn_value(cnid) / frametime)
		elseif self._displayformat == SECONDS then
			label = label .. string.format("%6.3fms  ", 1000 * self._lpd:cn_value(cnid))
		elseif self._displayformat == PLAIN then
			label = label .. string.format("%s    ", self._lpd:cn_value(cnid))
		end

		local fnid = self._lpd:cn_funcnode(cnid)
		label = label .. string.format("%s (%s/%s)", self._lpd:fn_func(fnid), self._lpd:fn_file(fnid), self._lpd:fn_line(fnid))

		if self._lpd:cn_num_acc_nodes(cnid) > 1 then
			label = label .. string.format(" x%d", self._lpd:cn_num_acc_nodes(cnid))
		end
	end

	return label
end

function LuaProfilerTreeBox:deselect_and_expand(...)
	local fnid = parse_kwargs({
		...
	}, "number:fnid")

	self._treectrl:disconnect("EVT_COMMAND_TREE_ITEM_EXPANDED", self.__on_item_expanded_cb)
	self:_collapse_all()
	self:_clear_highlights()
	self._treectrl:unselect_all_items()

	for i = 0, self._lpd:fn_numcallnodes(fnid) - 1 do
		self:_populate_path(self._lpd:fn_callnode(fnid, i))
	end

	for i = 0, self._lpd:fn_numcallnodes(fnid) - 1 do
		self:_expand_path(self._lpd:fn_callnode(fnid, i))
		self:_highlight_callnode(self._lpd:fn_callnode(fnid, i))
	end

	self._treectrl:connect("EVT_COMMAND_TREE_ITEM_EXPANDED", self.__on_item_expanded_cb)
end

function LuaProfilerTreeBox:_collapse_all()
	function collapse(cnid)
		tnid = self._lpd:cn_treenodeid(cnid)

		if tnid ~= -1 then
			self._treectrl:collapse(tnid)

			for i = 0, self._lpd:cn_numchildren(cnid) - 1 do
				local child_id = self._lpd:cn_child(cnid, i)

				collapse(child_id)
			end
		end
	end

	collapse(self._lpd:rootcallnode())
end

function LuaProfilerTreeBox:_expand_path(cnid)
	while cnid ~= self._lpd:rootcallnode() do
		cnid = self._lpd:cn_parent(cnid)

		self._treectrl:expand(self._lpd:cn_treenodeid(cnid))
	end
end

function LuaProfilerTreeBox:deselect_and_highlight(...)
	local fnid = parse_kwargs({
		...
	}, "number:fnid")

	self._treectrl:unselect_all_items()
	self:_highlight_funcnode(fnid)
end

function LuaProfilerTreeBox:_clear_highlights()
	function clear_highlight(cnid)
		local tnid = self._lpd:cn_treenodeid(cnid)

		if tnid ~= -1 then
			self._treectrl:set_item_background_colour(tnid, Vector3(1, 1, 1))

			for i = 0, self._lpd:cn_numchildren(cnid) - 1 do
				local child_id = self._lpd:cn_child(cnid, i)

				clear_highlight(child_id)
			end
		end
	end

	clear_highlight(self._lpd:rootcallnode())
end

function LuaProfilerTreeBox:_highlight_funcnode(fnid)
	self:_clear_highlights()

	for i = 0, self._lpd:fn_numcallnodes(fnid) - 1 do
		local cnid = self._lpd:fn_callnode(fnid, i)

		self:_highlight_callnode(cnid)
	end
end

function LuaProfilerTreeBox:_highlight_callnode(cnid)
	local tnid = self._lpd:cn_treenodeid(cnid)

	if tnid ~= -1 then
		self._treectrl:set_item_background_colour(tnid, HIGHLIGHTED)
	end
end

function LuaProfilerTreeBox:_on_select()
	local tnid = self._treectrl:selected_item()

	if tnid ~= -1 then
		local cnid = self._lpd:find_callnode(tnid)
		local fnid = self._lpd:cn_funcnode(cnid)

		self:_highlight_funcnode(fnid)
		self._gridview:deselect_and_highlight({
			fnid = fnid
		})
	end
end
