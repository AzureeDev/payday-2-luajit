HUDChatVR = HUDChat
HUDChatVR.old_init = HUDChat.init

function HUDChatVR:init(ws, hud)
	local old_panel = hud.panel
	hud.panel = managers.hud:tablet_page("left_page")

	managers.hud:add_page_callback("left", "on_interact", callback(self, self, "_on_interact"))
	managers.hud:add_page_callback("left", "on_focus", callback(self, self, "_on_page_focus"))
	self:old_init(managers.hud:tablet_ws(), hud)
	self._panel:set_bottom(self._hud_panel:h())

	hud.panel = old_panel
end

HUDChatVR.default_layout_output_panel = HUDChat._layout_output_panel

function HUDChatVR:_layout_output_panel()
	self:default_layout_output_panel()
	self._panel:child("output_panel"):set_bottom(self._panel:h())
end

function HUDChatVR:_on_interact(position)
	self:_on_focus()
end

function HUDChatVR:_on_page_focus(focus)
	if not focus then
		self:_loose_focus()
	end
end

function HUDChatVR:esc_key_callback()
	self:_loose_focus()
end

function HUDChatVR:_animate_fade_output()
end

function HUDChatVR:_animate_show_component(o)
	o:set_alpha(1)
end
