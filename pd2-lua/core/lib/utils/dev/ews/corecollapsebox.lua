CoreCollapseBox = CoreCollapseBox or class()

function CoreCollapseBox:init(parent, orientation, caption, expanded_size, expand, style)
	self._caption = caption or ""
	self._expand = not expand
	self._parent = parent
	self._expanded_size = expanded_size
	self._panel = EWS:Panel(self._parent, "", "")
	self._box = style == "NO_BORDER" and EWS:BoxSizer("VERTICAL") or EWS:StaticBoxSizer(self._panel, "VERTICAL", "")

	self._panel:set_sizer(self._box)

	self._btn = EWS:Button(self._panel, "", "", "NO_BORDER")

	self._btn:set_font_weight("FONTWEIGHT_BOLD")
	self:connect("", "EVT_COMMAND_BUTTON_CLICKED", self._cb, self)
	self._box:add(self._btn, 0, 0, "EXPAND")

	self._lower_panel = EWS:Panel(self._panel, "", style == "NO_BORDER" and "SIMPLE_BORDER" or "")

	if self._expanded_size then
		self._lower_panel:set_min_size(self._expanded_size)
	end

	self._lower_box = EWS:BoxSizer(orientation)

	self._lower_panel:set_sizer(self._lower_box)
	self._box:add(self._lower_panel, 1, 4, style == "NO_BORDER" and "LEFT,RIGHT,EXPAND" or "EXPAND")
	self:_cb()
end

function CoreCollapseBox:connect(id, event, cb, data)
	self._btn:connect(id, event, cb, data)
end

function CoreCollapseBox:panel()
	return self._panel
end

function CoreCollapseBox:lower_panel()
	return self._lower_panel
end

function CoreCollapseBox:box()
	return self._lower_box
end

function CoreCollapseBox:expanded()
	return self._expand
end

function CoreCollapseBox:expanded_size()
	return self._expanded_size
end

function CoreCollapseBox:set_expand(b)
	self._expand = not expand

	self:_cb()
end

function CoreCollapseBox:set_expanded_size(v)
	self._parent:freeze()

	self._expanded_size = v

	self._lower_panel:set_sizer(v)
	self._parent:layout()
	self._parent:thaw()
	self._parent:refresh()
end

function CoreCollapseBox:_cb()
	self._expand = not self._expand

	self._parent:freeze()

	local icon = self._expand and "[-]" or "[+]"

	self._lower_panel:set_visible(self._expand)
	self._btn:set_caption(icon .. " " .. self._caption)
	self._parent:layout()
	self._parent:thaw()
	self._parent:refresh()
end
