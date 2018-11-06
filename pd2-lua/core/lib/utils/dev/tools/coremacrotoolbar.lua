CoreMacroToolbar = CoreMacroToolbar or class()

function CoreMacroToolbar:init(toolbar_panel, toolbar_box, default_icon, macro_file, self_str)
	self._toolbar_panel = toolbar_panel
	self._toolbar_box = toolbar_box
	self._default_icon = default_icon
	self._macro_file = macro_file
	self._self_str = self_str

	self:reload_macros()
end

function CoreMacroToolbar:reload_macros()
	if self._macros then
		for name, macro in pairs(self._macros) do
			macro._ews:destroy()
		end
	end

	self._macros = {}
	local node = File:parse_xml(self._macro_file)

	if node then
		for macro in node:children() do
			local icon_path = macro:parameter("icon")

			if icon_path == "DEFAULT" or icon_path == "" then
				icon_path = self._default_icon
			end

			local name = macro:parameter("name")
			self._macros[name] = {
				_ews = EWS:BitmapButton(self._toolbar_panel, icon_path, "", "")
			}

			self._macros[name]._ews:set_tool_tip(name)

			self._macros[name]._func = loadstring("local self = " .. self._self_str .. "; " .. macro:parameter("code"))

			self._macros[name]._ews:connect("EVT_COMMAND_BUTTON_CLICKED", self._macros[name]._func, "")

			self._macros[name]._event = macro:parameter("event")

			self._toolbar_box:add(self._macros[name]._ews, 0, 2, "ALL")
		end

		self._toolbar_panel:layout()
	end
end

function CoreMacroToolbar:trigger_event(event_name)
	if self._macros then
		for _, macro in pairs(self._macros) do
			if macro._event == event_name then
				macro._func()
			end
		end
	end
end
