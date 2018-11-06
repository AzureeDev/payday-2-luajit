CoreXMLTextCtrl = CoreXMLTextCtrl or class()

function CoreXMLTextCtrl:init(parent, value, id, syntax_colors, style)
	if syntax_colors then
		self._syntax_colors = syntax_colors
	else
		self._syntax_colors = {
			NODE = Vector3(50, 50, 255),
			KEY = Vector3(250, 50, 50),
			VALUE = Vector3(0, 0, 0),
			NORMAL = Vector3(0, 0, 0)
		}
	end

	self._text_ctrl = EWS:TextCtrl(parent, value or "", id or "", style or "TE_MULTILINE,TE_RICH2,TE_DONTWRAP")

	self._text_ctrl:set_default_style_font_family("FONTFAMILY_TELETYPE")
	self._text_ctrl:set_default_style_font_size(10)
end

function CoreXMLTextCtrl:update(t)
	self._skip_event = nil

	if self._check_syntax then
		if self._last_syntax_check then
			if t - self._last_syntax_check > 3 then
				local text = self._text_ctrl:get_value()
				self._last_syntax_check = nil
				self._check_syntax = nil
				self._skip_event = true

				if Node("node"):try_read_xml(text) then
					local node = Node("node")

					node:read_xml("<n>\n" .. text .. "</n>\n")

					if node:num_children() > 0 then
						self._text_ctrl:freeze()
						self._text_ctrl:set_value("")
						self:_draw_text_with_color("", node)
						self:_set_tc_color("NORMAL")
						self._text_ctrl:thaw()
						self._text_ctrl:set_insertion_point(0)
						self._text_ctrl:show_position(0)
						self._text_ctrl:update()
					end

					self._xml_ok = true
				else
					self._xml_ok = nil
				end
			end
		else
			self._last_syntax_check = t
		end
	end
end

function CoreXMLTextCtrl:text_ctrl()
	return self._text_ctrl
end

function CoreXMLTextCtrl:xml_ok()
	return self._xml_ok == true
end

function CoreXMLTextCtrl:check()
	self._check_syntax = true
	self._last_syntax_check = 0
end

function CoreXMLTextCtrl:set_value(value)
	self._text_ctrl:set_value(value)
	self:check()
	self:update(math.huge)
end

function CoreXMLTextCtrl:_on_text_change()
	if not self._skip_event then
		self._check_syntax = true
		self._last_syntax_check = nil
	end
end

function CoreXMLTextCtrl:_draw_text_with_color(level, node)
	for child in node:children() do
		self:_set_tc_color("NODE")
		self._text_ctrl:append(level .. "<" .. child:name())

		for k, v in pairs(child:parameters()) do
			self:_set_tc_color("KEY")
			self._text_ctrl:append(" " .. k .. "=")
			self:_set_tc_color("VALUE")
			self._text_ctrl:append("\"" .. v .. "\"")
		end

		self:_set_tc_color("NODE")

		if child:num_children() == 0 then
			self._text_ctrl:append("/>\n")
		else
			self._text_ctrl:append(">\n")
			self:_draw_text_with_color(level .. "    ", child)
			self._text_ctrl:append(level .. "</" .. child:name() .. ">\n")
		end
	end
end

function CoreXMLTextCtrl:_set_tc_color(color)
	self._text_ctrl:set_default_style_colour(self._syntax_colors[color])
end
