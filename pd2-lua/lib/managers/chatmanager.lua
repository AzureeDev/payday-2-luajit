ChatManager = ChatManager or class()
ChatManager.GAME = 1
ChatManager.CREW = 2
ChatManager.GLOBAL = 3

function ChatManager:init()
	self:_setup()
end

function ChatManager:_setup()
	self._chatlog = {}
	self._receivers = {}
	self._muted_peers = {}
end

function ChatManager:register_receiver(channel_id, receiver)
	self._receivers[channel_id] = self._receivers[channel_id] or {}

	table.insert(self._receivers[channel_id], receiver)
end

function ChatManager:unregister_receiver(channel_id, receiver)
	if not self._receivers[channel_id] then
		return
	end

	for i, rec in ipairs(self._receivers[channel_id]) do
		if rec == receiver then
			table.remove(self._receivers[channel_id], i)

			break
		end
	end
end

function ChatManager:send_message(channel_id, sender, message)
	if managers.network:session() then
		sender = managers.network:session():local_peer()

		managers.network:session():send_to_peers_ip_verified("send_chat_message", channel_id, message)
		self:receive_message_by_peer(channel_id, sender, message)
	else
		self:receive_message_by_name(channel_id, sender, message)
	end
end

function ChatManager:feed_system_message(channel_id, message)
	if not Global.game_settings.single_player then
		self:_receive_message(channel_id, managers.localization:to_upper_text("menu_system_message"), message, tweak_data.system_chat_color)
	end
end

function ChatManager:receive_message_by_peer(channel_id, peer, message)
	if self:is_peer_muted(peer) then
		return
	end

	local color_id = peer:id()
	local color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
	local rank = peer:level() == nil and managers.experience:current_rank() or peer:rank()
	local icon = managers.experience:rank_icon(rank)

	self:_receive_message(channel_id, peer:name(), message, tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors], icon)
end

function ChatManager:receive_message_by_name(channel_id, name, message)
	self:_receive_message(channel_id, name, message, tweak_data.chat_colors[1] or tweak_data.chat_colors[#tweak_data.chat_colors])
end

function ChatManager:_receive_message(channel_id, name, message, color, icon)
	if not self._receivers[channel_id] then
		return
	end

	for i, receiver in ipairs(self._receivers[channel_id]) do
		receiver:receive_message(name, message, color, icon)
	end
end

function ChatManager:mute_peer(peer)
	if peer and peer:user_id() then
		self._muted_peers[peer:user_id()] = true
	end
end

function ChatManager:unmute_peer(peer)
	if peer and peer:user_id() then
		self._muted_peers[peer:user_id()] = nil
	end
end

function ChatManager:is_peer_muted(peer)
	if peer and peer:user_id() then
		return self._muted_peers[peer:user_id()] or false
	end

	return false
end

function ChatManager:save(data)
end

function ChatManager:load(data)
end

ChatBase = ChatBase or class()

function ChatBase:init()
end

function ChatBase:receive_message(name, message, color, icon)
end

ChatGui = ChatGui or class(ChatBase)
ChatGui.line_height = 22

function ChatGui:init(ws)
	self._ws = ws
	self._hud_panel = ws:panel()

	self:set_channel_id(ChatManager.GAME)

	self._panel_width = self._hud_panel:w() * 0.5
	self._output_width = self._panel_width - 15
	self._panel_height = 500
	self._max_lines = 15
	self._lines = {}
	self._esc_callback = callback(self, self, "esc_key_callback")
	self._enter_callback = callback(self, self, "enter_key_callback")
	self._typing_callback = 0
	self._skip_first = false
	self._hud_blur = self._hud_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "hud_blur",
		valign = "grow",
		halign = "grow",
		render_template = "VertexColorTexturedBlur3D",
		layer = -2
	})

	self._hud_blur:set_shape(self._hud_panel:shape())
	self._hud_blur:set_alpha(0)
	self._hud_blur:hide()

	self._panel = self._hud_panel:panel({
		name = "chat_panel",
		x = 0,
		valign = "bottom",
		h = self._panel_height,
		w = self._panel_width
	})

	self:set_leftbottom(0, 70)

	local chat_blur = self._panel:panel({
		name = "chat_blur"
	})
	local blur = chat_blur:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "chat_blur",
		valign = "grow",
		halign = "grow",
		render_template = "VertexColorTexturedBlur3D",
		layer = -2
	})

	blur:set_size(chat_blur:size())
	chat_blur:set_shape(self._panel:shape())
	chat_blur:set_h(math.round(ChatGui.line_height * self._max_lines) + 24)
	chat_blur:set_bottom(self._panel:h())
	chat_blur:hide()

	self._chat_blur_box = BoxGuiObject:new(chat_blur, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	local chat_bg = self._panel:rect({
		name = "chat_bg",
		valign = "grow",
		halign = "grow",
		alpha = 0,
		layer = -1,
		color = Color.black
	})

	chat_bg:set_shape(chat_blur:shape())

	local output_panel = self._panel:panel({
		name = "output_panel",
		h = 10,
		x = 20,
		layer = 1,
		w = self._output_width
	})
	local output_bg = output_panel:rect({
		name = "output_bg",
		valign = "grow",
		halign = "grow",
		alpha = 0,
		layer = -1,
		color = Color.black
	})
	local scroll_panel = output_panel:panel({
		name = "scroll_panel",
		x = 0,
		h = 10,
		w = self._output_width
	})
	self._scroll_indicator_box_class = BoxGuiObject:new(output_panel, {
		sides = {
			0,
			0,
			0,
			0
		}
	})
	local scroll_up_indicator_shade = output_panel:bitmap({
		texture = "guis/textures/headershadow",
		name = "scroll_up_indicator_shade",
		visible = false,
		rotation = 180,
		layer = 2,
		color = Color.white,
		w = output_panel:w()
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local scroll_up_indicator_arrow = self._panel:bitmap({
		name = "scroll_up_indicator_arrow",
		layer = 2,
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})
	local scroll_down_indicator_shade = output_panel:bitmap({
		texture = "guis/textures/headershadow",
		name = "scroll_down_indicator_shade",
		visible = false,
		layer = 2,
		color = Color.white,
		w = output_panel:w()
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local scroll_down_indicator_arrow = self._panel:bitmap({
		name = "scroll_down_indicator_arrow",
		layer = 2,
		rotation = 180,
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})
	local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()
	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar")
	local scroll_bar = self._panel:panel({
		w = 15,
		name = "scroll_bar",
		layer = 2,
		h = bar_h
	})
	local scroll_bar_box_panel = scroll_bar:panel({
		name = "scroll_bar_box_panel",
		halign = "scale",
		w = 4,
		x = 5,
		valign = "scale"
	})
	self._scroll_bar_box_class = BoxGuiObject:new(scroll_bar_box_panel, {
		sides = {
			2,
			2,
			0,
			0
		}
	})
	self._enabled = true

	if MenuCallbackHandler:is_win32() then
		self._num_new_messages = 0
		self._chat_button_show_string = managers.localization:to_upper_text("menu_cn_chat_show", {
			BTN_BACK = managers.localization:btn_macro("toggle_chat")
		})
		self._chat_button_hide_string = managers.localization:to_upper_text("menu_cn_chat_hide", {
			BTN_BACK = managers.localization:btn_macro("toggle_chat")
		})
		local chat_button_panel = self._hud_panel:panel({
			name = "chat_button_panel"
		})
		local chat_button = chat_button_panel:text({
			text = "",
			name = "chat_button",
			blend_mode = "add",
			layer = 40,
			font_size = tweak_data.menu.pd2_small_font_size,
			font = tweak_data.menu.pd2_small_font,
			color = tweak_data.screen_colors.button_stage_3
		})

		self:update_chat_button()
		chat_button:set_right(chat_button_panel:w() / 2)
		chat_button:set_bottom(chat_button_panel:h() - 11)

		local blur_object = chat_button_panel:bitmap({
			texture = "guis/textures/test_blur_df",
			name = "chat_button_blur",
			render_template = "VertexColorTexturedBlur3D",
			layer = chat_button:layer() - 2
		})

		blur_object:set_shape(chat_button:shape())
		chat_button_panel:hide()

		local new_msg_flash = chat_button_panel:bitmap({
			texture = "guis/textures/pd2/crimenet_marker_glow",
			name = "new_msg_flash",
			alpha = 0,
			blend_mode = "add",
			rotation = 360,
			w = (chat_button:w() + 20) * 2,
			h = (chat_button:h() + 10) * 2,
			layer = chat_button:layer() - 1,
			color = tweak_data.screen_colors.button_stage_3
		})

		new_msg_flash:set_center(chat_button:center())
	end

	output_panel:set_x(scroll_down_indicator_arrow:w() + 4)
	self:_create_input_panel()
	self:_layout_input_panel()
	self:_layout_output_panel(true)
	self:set_layer(20)

	if _G.IS_VR then
		Input:keyboard():clear()
	end
end

function ChatGui:start_hud_blur()
	local function func(o)
		over(0.6, function (p)
			o:set_alpha(math.lerp(0, 1, p))
		end)
	end

	self._hud_blur:animate(func)
end

function ChatGui:stop_hud_blur()
	self._hud_blur:stop()
	self._hud_blur:set_alpha(0)
end

function ChatGui:update_chat_button()
	local chat_button_panel = self._hud_panel:child("chat_button_panel")
	local chat_button = chat_button_panel:child("chat_button")
	local show_chat_string = not self._crimenet_chat_state
	local new_messages = self._num_new_messages
	local chat_string = show_chat_string and self._chat_button_show_string or self._chat_button_hide_string

	if new_messages and new_messages > 0 then
		chat_button:set_text(chat_string .. " (" .. tostring(new_messages) .. ")")
	else
		chat_button:set_text(chat_string)
	end

	local x, y, w, h = chat_button:text_rect()

	chat_button:set_size(math.ceil(w), math.ceil(h))
end

function ChatGui:start_notify_new_message()
	if MenuCallbackHandler:is_win32() then
		if not self._crimenet_chat_state and not self._notifying_new_msg then
			self._notifying_new_msg = true

			local function func(o)
				over(0.1, function (p)
					o:set_alpha(math.lerp(0, 0.6, p))
				end)

				while true do
					over(2, function (p)
						o:set_alpha(math.abs(math.cos(p * 360)) * 0.4 + 0.2)
					end)
				end
			end

			local chat_button_panel = self._hud_panel:child("chat_button_panel")
			local new_msg_flash = chat_button_panel:child("new_msg_flash")

			new_msg_flash:stop()
			new_msg_flash:animate(func)
		end

		if not self._crimenet_chat_state then
			self._num_new_messages = self._num_new_messages + 1

			self:update_chat_button()

			local chat_button_panel = self._hud_panel:child("chat_button_panel")
			local chat_button = chat_button_panel:child("chat_button")

			managers.menu_component:set_preplanning_drawboard(chat_button:right() + 15, chat_button:top())
			managers.menu_component:post_event("chat_ping")
		end
	end
end

function ChatGui:stop_notify_new_message()
	if MenuCallbackHandler:is_win32() and self._notifying_new_msg then
		self._notifying_new_msg = false
		local chat_button_panel = self._hud_panel:child("chat_button_panel")
		local new_msg_flash = chat_button_panel:child("new_msg_flash")

		new_msg_flash:stop()
		new_msg_flash:set_alpha(0)

		self._num_new_messages = 0

		self:update_chat_button()
	end
end

function ChatGui:set_leftbottom(left, bottom)
	self._panel:set_left(left)
	self._panel:set_bottom(self._panel:parent():h() - bottom)
end

function ChatGui:set_max_lines(max_lines)
	self._max_lines = max_lines

	self:_layout_output_panel(true)

	local chat_blur = self._panel:child("chat_blur")

	chat_blur:set_shape(self._panel:shape())
	chat_blur:set_h(math.round(ChatGui.line_height * self._max_lines) + 24)
	chat_blur:set_bottom(self._panel:h())
	self._chat_blur_box:create_sides(chat_blur, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local chat_bg = self._panel:child("chat_bg")

	chat_bg:set_shape(chat_blur:shape())
end

ChatGui.PRESETS = {
	default = {
		left = 0,
		bottom = 70,
		layer = 20
	},
	lobby = {
		left = 0,
		bottom = 50,
		layer = 20
	},
	crimenet = {
		chat_blur = true,
		left = 0,
		is_crimenet_chat = true,
		chat_bg_alpha = 0.75,
		bottom = 0,
		layer = tweak_data.gui.CRIMENET_CHAT_LAYER
	},
	preplanning = {
		chat_blur = true,
		left = 10,
		is_crimenet_chat = true,
		chat_bg_alpha = 0.75,
		chat_button_align = "left",
		bottom = 0,
		layer = tweak_data.gui.CRIMENET_CHAT_LAYER
	},
	inventory = {
		chat_button_y_offset = 25,
		left = 0,
		is_crimenet_chat = true,
		chat_bg_alpha = 0.75,
		chat_button_align = "left",
		chat_blur = true,
		bottom = 0,
		layer = tweak_data.gui.CRIMENET_CHAT_LAYER
	}
}
ChatGui.PRESETS.weapon_color_customize = deep_clone(ChatGui.PRESETS.inventory)
ChatGui.PRESETS.weapon_color_customize.chat_button_y_offset = 0

function ChatGui:set_params(params)
	if type(params) == "string" then
		params = self.PRESETS[params] or {}
	end

	if params.max_lines then
		self:set_max_lines(params.max_lines)
	end

	if params.left and params.bottom then
		self:set_leftbottom(params.left, params.bottom)
	end

	if params.layer then
		self._layer = params.layer

		self:set_layer(params.layer)
	end

	local chat_bg = self._panel:child("chat_bg")
	local chat_blur = self._panel:child("chat_blur")
	local hud_blur = self._hud_blur
	local output_bg = self._panel:child("output_panel"):child("output_bg")

	output_bg:set_alpha(params.output_bg_alpha or 0)
	chat_bg:set_alpha(params.chat_bg_alpha or 0)
	chat_blur:set_visible(params.chat_blur)
	hud_blur:set_visible(params.hud_blur)

	self._chat_button_align = nil

	if params.chat_button_align then
		self._chat_button_align = params.chat_button_align
	end

	self._chat_button_y_offset = nil

	if params.chat_button_y_offset then
		self._chat_button_y_offset = params.chat_button_y_offset
	end

	self._chat_button_x_offset = nil

	if params.chat_button_x_offset then
		self._chat_button_x_offset = params.chat_button_x_offset
	end

	if params.is_crimenet_chat then
		self:enable_crimenet_chat()
	else
		self:disable_crimenet_chat()
	end
end

function ChatGui:enable_crimenet_chat()
	if MenuCallbackHandler:is_win32() then
		self._is_crimenet_chat = true

		self:_hide_crimenet_chat()

		local chat_button_panel = self._hud_panel:child("chat_button_panel")

		chat_button_panel:show()
	end
end

function ChatGui:disable_crimenet_chat()
	if MenuCallbackHandler:is_win32() then
		self._is_crimenet_chat = false
		local chat_button_panel = self._hud_panel:child("chat_button_panel")

		chat_button_panel:hide()

		local output_panel = self._panel:child("output_panel")
		local output_alpha = output_panel:alpha()
		local has_new_messages = self._num_new_messages > 0

		self:_show_crimenet_chat()

		if output_alpha < 1 and not has_new_messages then
			output_panel:stop()
			output_panel:set_alpha(0)
		end
	end
end

function ChatGui:toggle_crimenet_chat()
	if MenuCallbackHandler:is_win32() then
		self._crimenet_chat_state = not self._crimenet_chat_state

		if self._crimenet_chat_state then
			self:_show_crimenet_chat()
		else
			self:_hide_crimenet_chat()
		end

		managers.menu_component:post_event("menu_enter")
	end
end

function ChatGui:set_crimenet_chat(state)
	if MenuCallbackHandler:is_win32() and self._crimenet_chat_state ~= state then
		self._crimenet_chat_state = state

		if self._crimenet_chat_state then
			self:_show_crimenet_chat()
		else
			self:_hide_crimenet_chat()
		end
	end
end

function ChatGui:get_chat_button_shape()
	local chat_button_panel = self._hud_panel:child("chat_button_panel")
	local chat_button = chat_button_panel and chat_button_panel:child("chat_button")

	if chat_button then
		return chat_button:shape()
	end
end

function ChatGui:_show_crimenet_chat()
	if SystemInfo:platform() == Idstring("WIN32") and managers.controller:get_default_wrapper_type() ~= "pc" then
		local desc = managers.localization:text("menu_chat_input")
		local id = Idstring("ChatGui:_show_crimenet_chat")
		local key = id:key()
		local params = {
			nil,
			nil,
			desc,
			60,
			""
		}

		local function func(submitted, submitted_text)
			if submitted then
				self:enter_text(nil, submitted_text)
				self:enter_key_callback()
			end
		end

		if managers.network.account:show_gamepad_text_input(key, func, params) then
			return
		elseif Input:keyboard() then
			-- Nothing
		elseif MenuCallbackHandler:is_overlay_enabled() then
			managers.menu:show_requires_big_picture()

			return
		else
			managers.menu:show_enable_steam_overlay()

			return
		end
	end

	local chat_bg = self._panel:child("chat_bg")
	local chat_blur = self._panel:child("chat_blur")
	local hud_blur = self._hud_blur
	local output_bg = self._panel:child("output_panel"):child("output_bg")
	self._crimenet_chat_state = true

	self:stop_notify_new_message()
	self:update_chat_button()

	local chat_button_panel = self._hud_panel:child("chat_button_panel")
	local chat_button = chat_button_panel:child("chat_button")

	if self._chat_button_align == "left" then
		chat_button:set_left(self._panel:left())
	elseif self._chat_button_align == "right" then
		chat_button:set_right(self._panel:right())
	else
		chat_button:set_right(chat_button_panel:w() / 2)
	end

	chat_button:set_bottom(chat_button_panel:h())
	chat_button:move(self._chat_button_x_offset or 0, -(self._chat_button_y_offset or 11))
	managers.menu_component:set_preplanning_drawboard(chat_button:right() + 15, chat_button:top())
	managers.menu_component:hide_preplanning_drawboard()

	local blur_object = chat_button_panel:child("chat_button_blur")

	blur_object:set_shape(chat_button:shape())

	local new_msg_flash = chat_button_panel:child("new_msg_flash")

	new_msg_flash:set_center(chat_button:center())
	self:set_output_alpha(1)
	self._panel:child("output_panel"):stop()
	self._panel:child("output_panel"):animate(callback(self, self, "_animate_fade_output"))
	self._panel:set_bottom(self._hud_panel:child("chat_button_panel"):child("chat_button"):top())
end

function ChatGui:_hide_crimenet_chat()
	local chat_bg = self._panel:child("chat_bg")
	local chat_blur = self._panel:child("chat_blur")
	local hud_blur = self._hud_blur
	local output_bg = self._panel:child("output_panel"):child("output_bg")

	self:_loose_focus()

	self._crimenet_chat_state = false

	self:update_chat_button()

	local chat_button_panel = self._hud_panel:child("chat_button_panel")
	local chat_button = chat_button_panel:child("chat_button")

	if self._chat_button_align == "left" then
		chat_button:set_left(self._panel:left())
	elseif self._chat_button_align == "right" then
		chat_button:set_right(self._panel:right())
	else
		chat_button:set_right(chat_button_panel:w() / 2)
	end

	chat_button:set_bottom(chat_button_panel:h())
	chat_button:move(self._chat_button_x_offset or 0, -(self._chat_button_y_offset or 11))
	managers.menu_component:set_preplanning_drawboard(chat_button:right() + 15, chat_button:top())

	local blur_object = chat_button_panel:child("chat_button_blur")

	blur_object:set_shape(chat_button:shape())

	local new_msg_flash = chat_button_panel:child("new_msg_flash")

	new_msg_flash:set_center(chat_button:center())
	self._panel:set_top(self._hud_panel:h())
end

function ChatGui:enabled()
	return self._enabled
end

function ChatGui:set_enabled(enabled)
	if not enabled then
		self:_loose_focus()
	end

	self._enabled = enabled
end

function ChatGui:hide()
	self._panel:hide()
	self._hud_blur:hide()
	self._hud_panel:child("chat_button_panel"):hide()
	self:set_enabled(false)

	local text = self._input_panel:child("input_text")

	text:set_text("")
	text:set_selection(0, 0)
end

function ChatGui:show()
	self._panel:show()
	self:set_enabled(true)
end

function ChatGui:set_layer(layer)
	self._panel:set_layer(layer)
	self._hud_blur:set_layer(layer - 2)

	if self._hud_panel:child("chat_button_panel") then
		self._hud_panel:child("chat_button_panel"):set_layer(layer + 1)
	end
end

function ChatGui:set_channel_id(channel_id)
	managers.chat:unregister_receiver(self._channel_id, self)

	self._channel_id = channel_id

	managers.chat:register_receiver(self._channel_id, self)
end

function ChatGui:esc_key_callback()
	if not self._enabled then
		return
	end

	self._esc_focus_delay = true

	self:_loose_focus()
end

local command_list = nil

if SystemInfo:platform() == Idstring("WIN32") then
	command_list = {
		[Idstring("ready"):key()] = true,
		[Idstring("fbi_files"):key()] = true,
		[Idstring("fbi_inspect"):key()] = true,
		[Idstring("fbi_search"):key()] = true
	}
else
	command_list = {
		[Idstring("ready"):key()] = true
	}
end

function ChatGui:enter_key_callback()
	if not self._enabled then
		return
	end

	local text = self._input_panel:child("input_text")
	local message = text:text()
	local command_key, command_args = nil

	if utf8.sub(message, 1, 1) == "/" then
		local command_string = utf8.sub(message, 2, utf8.len(message))
		command_args = string.split(command_string, " ") or {}

		if #command_args > 0 then
			command_key = Idstring(table.remove(command_args, 1))
		end
	end

	if command_key and command_list[command_key:key()] then
		if command_key == Idstring("ready") then
			managers.menu_component:on_ready_pressed_mission_briefing_gui()
		elseif SystemInfo:distribution() == Idstring("STEAM") then
			if command_key == Idstring("fbi_files") then
				Steam:overlay_activate("url", tweak_data.gui.fbi_files_webpage)
			elseif command_key == Idstring("fbi_search") then
				Steam:overlay_activate("url", tweak_data.gui.fbi_files_webpage .. (command_args[1] and "/suspect/" .. command_args[1] .. "/" or ""))
			elseif command_key == Idstring("fbi_inspect") then
				Steam:overlay_activate("url", tweak_data.gui.fbi_files_webpage .. (command_args[1] and "/modus/" .. command_args[1] .. "/" or ""))
			end
		end
	elseif string.len(message) > 0 then
		local u_name = managers.network.account:username()

		managers.chat:send_message(self._channel_id, u_name or "Offline", message)
	else
		self._enter_loose_focus_delay = true

		self:_loose_focus()
	end

	text:set_text("")
	text:set_selection(0, 0)
end

function ChatGui:_create_input_panel()
	self._input_panel = self._panel:panel({
		name = "input_panel",
		h = 24,
		alpha = 0,
		x = 0,
		layer = 1,
		w = self._panel_width
	})

	self._input_panel:rect({
		name = "focus_indicator",
		layer = 0,
		visible = false,
		color = Color.black:with_alpha(0.2)
	})

	local say = self._input_panel:text({
		y = 0,
		name = "say",
		vertical = "center",
		hvertical = "center",
		align = "left",
		blend_mode = "normal",
		halign = "left",
		x = 0,
		layer = 1,
		text = utf8.to_upper(managers.localization:text("debug_chat_say")),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = Color.white
	})
	local _, _, w, h = say:text_rect()

	say:set_size(w, self._input_panel:h())

	local input_text = self._input_panel:text({
		y = 0,
		name = "input_text",
		vertical = "center",
		wrap = true,
		align = "left",
		blend_mode = "normal",
		hvertical = "center",
		text = "",
		word_wrap = false,
		halign = "left",
		x = 0,
		layer = 1,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = Color.white
	})
	local caret = self._input_panel:rect({
		name = "caret",
		h = 0,
		y = 0,
		w = 0,
		x = 0,
		layer = 2,
		color = Color(0.05, 1, 1, 1)
	})

	self._input_panel:rect({
		valign = "grow",
		name = "input_bg",
		layer = -1,
		color = Color.black:with_alpha(0.5),
		h = self._input_panel:h()
	})
	self._input_panel:child("input_bg"):set_w(self._input_panel:w() - w)
	self._input_panel:child("input_bg"):set_x(w)
	self._input_panel:stop()
	self._input_panel:animate(callback(self, self, "_animate_hide_input"))
end

function ChatGui:_layout_output_panel(force_update_scroll_indicators)
	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")

	scroll_panel:set_w(self._output_width)
	output_panel:set_w(self._output_width)

	local line_height = ChatGui.line_height
	local max_lines = self._max_lines
	local lines = 0

	for i = #self._lines, 1, -1 do
		local line = self._lines[i][1]
		local line_bg = self._lines[i][2]
		local icon = self._lines[i][3]

		line:set_w(scroll_panel:w() - line:left())

		local _, _, w, h = line:text_rect()

		line:set_h(h)
		line_bg:set_w(w + line:left() + 2)
		line_bg:set_h(line_height * line:number_of_lines())

		lines = lines + line:number_of_lines()
	end

	local scroll_at_bottom = scroll_panel:bottom() == output_panel:h()

	output_panel:set_h(math.round(line_height * math.min(max_lines, lines)))
	scroll_panel:set_h(math.round(line_height * lines))

	local y = 0

	for i = #self._lines, 1, -1 do
		local line = self._lines[i][1]
		local line_bg = self._lines[i][2]
		local icon = self._lines[i][3]
		local _, _, w, h = line:text_rect()

		line:set_bottom(scroll_panel:h() - y)
		line_bg:set_bottom(line:bottom())

		if icon then
			icon:set_left(icon:left())
			icon:set_top(line:top() + 1)
			line:set_left(icon:right())
		else
			line:set_left(line:left())
		end

		y = y + line_height * line:number_of_lines()
	end

	output_panel:set_bottom(math.round(self._input_panel:top()))

	if lines <= max_lines or scroll_at_bottom then
		scroll_panel:set_bottom(output_panel:h())
	end

	self:set_scroll_indicators(force_update_scroll_indicators)
end

function ChatGui:_layout_input_panel()
	self._input_panel:set_w(self._panel_width - self._input_panel:x())

	local say = self._input_panel:child("say")
	local input_text = self._input_panel:child("input_text")

	input_text:set_left(say:right() + 4)
	input_text:set_w(self._input_panel:w() - input_text:left())
	self._input_panel:child("input_bg"):set_w(input_text:w())
	self._input_panel:child("input_bg"):set_x(input_text:x())

	local focus_indicator = self._input_panel:child("focus_indicator")

	focus_indicator:set_shape(input_text:shape())
	self._input_panel:set_y(self._input_panel:parent():h() - self._input_panel:h())
	self._input_panel:set_x(self._panel:child("output_panel"):x())
end

function ChatGui:set_scroll_indicators(force_update_scroll_indicators)
	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")
	local scroll_up_indicator_shade = output_panel:child("scroll_up_indicator_shade")
	local scroll_up_indicator_arrow = self._panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_shade = output_panel:child("scroll_down_indicator_shade")
	local scroll_down_indicator_arrow = self._panel:child("scroll_down_indicator_arrow")
	local scroll_bar = self._panel:child("scroll_bar")

	scroll_up_indicator_shade:set_top(0)
	scroll_down_indicator_shade:set_bottom(output_panel:h())
	scroll_up_indicator_arrow:set_righttop(output_panel:left() - 2, output_panel:top() + 2)
	scroll_down_indicator_arrow:set_rightbottom(output_panel:left() - 2, output_panel:bottom() - 2)

	local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()

	if scroll_panel:h() ~= 0 then
		local old_h = scroll_bar:h()

		scroll_bar:set_h(bar_h * output_panel:h() / scroll_panel:h())

		if old_h ~= scroll_bar:h() then
			self._scroll_bar_box_class:create_sides(scroll_bar:child("scroll_bar_box_panel"), {
				sides = {
					2,
					2,
					0,
					0
				}
			})
		end
	end

	local sh = scroll_panel:h() ~= 0 and scroll_panel:h() or 1

	scroll_bar:set_y(scroll_up_indicator_arrow:bottom() - scroll_panel:y() * (output_panel:h() - scroll_up_indicator_arrow:h() * 2) / sh)
	scroll_bar:set_center_x(scroll_up_indicator_arrow:center_x())

	local visible = output_panel:h() < scroll_panel:h()
	local scroll_up_visible = visible and scroll_panel:top() < 0
	local scroll_dn_visible = visible and output_panel:h() < scroll_panel:bottom()

	self:_layout_input_panel()
	scroll_bar:set_visible(visible)

	local update_scroll_indicator_box = force_update_scroll_indicators or false

	if scroll_up_indicator_arrow:visible() ~= scroll_up_visible then
		scroll_up_indicator_shade:set_visible(false)
		scroll_up_indicator_arrow:set_visible(scroll_up_visible)

		update_scroll_indicator_box = true
	end

	if scroll_down_indicator_arrow:visible() ~= scroll_dn_visible then
		scroll_down_indicator_shade:set_visible(false)
		scroll_down_indicator_arrow:set_visible(scroll_dn_visible)

		update_scroll_indicator_box = true
	end

	if update_scroll_indicator_box then
		self._scroll_indicator_box_class:create_sides(output_panel, {
			sides = {
				0,
				0,
				scroll_up_visible and 2 or 0,
				scroll_dn_visible and 2 or 0
			}
		})
	end
end

function ChatGui:set_size(x, y)
	ChatGui.super.set_size(self, x, y)
	self:_layout_input_panel()
	self:_layout_output_panel(true)
end

function ChatGui:input_focus()
	if self._esc_focus_delay then
		self._esc_focus_delay = nil

		return 1
	end

	if self._enter_loose_focus_delay then
		if not self._enter_loose_focus_delay_end then
			self._enter_loose_focus_delay_end = true

			setup:add_end_frame_clbk(callback(self, self, "enter_loose_focus_delay_end"))
		end

		return true
	end

	return self._focus
end

function ChatGui:enter_loose_focus_delay_end()
	self._enter_loose_focus_delay = nil
	self._enter_loose_focus_delay_end = nil
end

function ChatGui:special_btn_pressed(button)
	if MenuCallbackHandler:is_win32() and button == Idstring("toggle_chat") and not self._focus and self._is_crimenet_chat then
		self:toggle_crimenet_chat()

		return true
	end
end

function ChatGui:mouse_moved(x, y)
	if not self._enabled then
		return false, false
	end

	if self:moved_scroll_bar(x, y) then
		return true, "grab"
	end

	local chat_button_panel = self._hud_panel:child("chat_button_panel")

	if chat_button_panel and chat_button_panel:visible() then
		local chat_button = chat_button_panel:child("chat_button")

		if chat_button:inside(x, y) then
			if not self._chat_button_highlight then
				self._chat_button_highlight = true

				managers.menu_component:post_event("highlight")
				chat_button:set_color(tweak_data.screen_colors.button_stage_2)
			end

			return true, "link"
		elseif self._chat_button_highlight then
			self._chat_button_highlight = false

			chat_button:set_color(tweak_data.screen_colors.button_stage_3)
		end
	end

	if self._is_crimenet_chat and not self._crimenet_chat_state then
		return false, false
	end

	local inside = self._input_panel:inside(x, y)

	self._input_panel:child("focus_indicator"):set_visible(inside or self._focus)

	if self._panel:child("scroll_bar"):visible() and self._panel:child("scroll_bar"):inside(x, y) then
		return true, "hand"
	elseif self._panel:child("scroll_down_indicator_arrow"):visible() and self._panel:child("scroll_down_indicator_arrow"):inside(x, y) or self._panel:child("scroll_up_indicator_arrow"):visible() and self._panel:child("scroll_up_indicator_arrow"):inside(x, y) then
		return true, "link"
	end

	if self._focus then
		inside = not inside
	end

	return inside or self._focus, inside and "link" or "arrow"
end

function ChatGui:moved_scroll_bar(x, y)
	if self._grabbed_scroll_bar then
		self._current_y = self:scroll_with_bar(y, self._current_y)

		return true
	end

	return false
end

function ChatGui:scroll_with_bar(target_y, current_y)
	local line_height = ChatGui.line_height
	local diff = current_y - target_y

	if diff == 0 then
		return current_y
	end

	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")
	local scroll_ratio = output_panel:h() / scroll_panel:h()
	local dir = diff / math.abs(diff)

	while line_height <= math.abs(current_y - target_y) do
		current_y = current_y - line_height * dir * scroll_ratio

		if dir > 0 then
			self:scroll_up()
			self:set_scroll_indicators()
		elseif dir < 0 then
			self:scroll_down()
			self:set_scroll_indicators()
		end
	end

	return current_y
end

function ChatGui:mouse_released(o, button, x, y)
	if not self._enabled then
		return
	end

	self:release_scroll_bar()
end

function ChatGui:mouse_pressed(button, x, y)
	if not self._enabled then
		return
	end

	local chat_button_panel = self._hud_panel:child("chat_button_panel")

	if button == Idstring("0") and chat_button_panel and chat_button_panel:visible() then
		local chat_button = chat_button_panel:child("chat_button")

		if chat_button:inside(x, y) then
			self:toggle_crimenet_chat()

			return true
		end
	end

	if self._is_crimenet_chat and not self._crimenet_chat_state then
		return false, false
	end

	local inside = self._input_panel:inside(x, y)

	if inside then
		self:_on_focus()

		return true
	end

	if self._panel:child("output_panel"):inside(x, y) then
		if button == Idstring("mouse wheel down") then
			if self:mouse_wheel_down(x, y) then
				self:set_scroll_indicators()
				self:_on_focus()

				return true
			end
		elseif button == Idstring("mouse wheel up") then
			if self:mouse_wheel_up(x, y) then
				self:set_scroll_indicators()
				self:_on_focus()

				return true
			end
		elseif button == Idstring("0") and self:check_grab_scroll_panel(x, y) then
			self:set_scroll_indicators()
			self:_on_focus()

			return true
		end
	elseif button == Idstring("0") and self:check_grab_scroll_bar(x, y) then
		self:set_scroll_indicators()
		self:_on_focus()

		return true
	end

	return self:_loose_focus()
end

function ChatGui:check_grab_scroll_panel(x, y)
	return false
end

function ChatGui:check_grab_scroll_bar(x, y)
	local scroll_bar = self._panel:child("scroll_bar")

	if scroll_bar:visible() and scroll_bar:inside(x, y) then
		self._grabbed_scroll_bar = true
		self._current_y = y

		return true
	end

	if self._panel:child("scroll_up_indicator_arrow"):visible() and self._panel:child("scroll_up_indicator_arrow"):inside(x, y) then
		self:scroll_up(x, y)

		self._pressing_arrow_up = true

		return true
	end

	if self._panel:child("scroll_down_indicator_arrow"):visible() and self._panel:child("scroll_down_indicator_arrow"):inside(x, y) then
		self:scroll_down(x, y)

		self._pressing_arrow_down = true

		return true
	end

	return false
end

function ChatGui:release_scroll_bar()
	self._pressing_arrow_up = nil
	self._pressing_arrow_down = nil

	if self._grabbed_scroll_bar then
		self._grabbed_scroll_bar = nil

		return true
	end

	return false
end

function ChatGui:scroll_up()
	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")

	if output_panel:h() < scroll_panel:h() then
		if scroll_panel:top() == 0 then
			self._one_scroll_dn_delay = true
		end

		scroll_panel:set_top(math.min(0, scroll_panel:top() + ChatGui.line_height))

		return true
	end
end

function ChatGui:scroll_down()
	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")

	if output_panel:h() < scroll_panel:h() then
		if scroll_panel:bottom() == output_panel:h() then
			self._one_scroll_up_delay = true
		end

		scroll_panel:set_bottom(math.max(scroll_panel:bottom() - ChatGui.line_height, output_panel:h()))

		return true
	end
end

function ChatGui:mouse_wheel_up(x, y)
	if not self._enabled then
		return
	end

	if self._is_crimenet_chat and not self._crimenet_chat_state then
		return false, false
	end

	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")

	if self._one_scroll_up_delay then
		self._one_scroll_up_delay = nil

		return true
	end

	return self:scroll_up()
end

function ChatGui:mouse_wheel_down(x, y)
	if not self._enabled then
		return
	end

	if self._is_crimenet_chat and not self._crimenet_chat_state then
		return false, false
	end

	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")

	if self._one_scroll_dn_delay then
		self._one_scroll_dn_delay = nil

		return true
	end

	return self:scroll_down()
end

function ChatGui:open_page()
	self:_on_focus()

	if self._is_crimenet_chat then
		self:_show_crimenet_chat()
	end
end

function ChatGui:close_page()
	self:_loose_focus()
end

function ChatGui:_on_focus()
	if not self._enabled then
		return
	end

	if self._focus then
		return
	end

	self:start_hud_blur()

	local output_panel = self._panel:child("output_panel")

	output_panel:stop()
	output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
	self._input_panel:stop()
	self._input_panel:animate(callback(self, self, "_animate_show_input"))

	self._focus = true

	self._input_panel:child("focus_indicator"):set_color(Color(0, 0, 0):with_alpha(0.2))
	self._ws:connect_keyboard(Input:keyboard())

	if _G.IS_VR then
		Input:keyboard():show()
	end

	self._input_panel:key_press(callback(self, self, "key_press"))
	self._input_panel:key_release(callback(self, self, "key_release"))

	self._enter_text_set = false

	self._input_panel:child("input_bg"):animate(callback(self, self, "_animate_input_bg"))
	self:set_layer(tweak_data.gui.CRIMENET_CHAT_LAYER)
	self:update_caret()
end

function ChatGui:_loose_focus()
	if not self._focus then
		return false
	end

	self:stop_hud_blur()

	self._one_scroll_up_delay = nil
	self._one_scroll_dn_delay = nil
	self._focus = false

	self._input_panel:child("focus_indicator"):set_color(Color.black:with_alpha(0.2))
	self._ws:disconnect_keyboard()
	self._input_panel:key_press(nil)
	self._input_panel:enter_text(nil)
	self._input_panel:key_release(nil)
	self._panel:child("output_panel"):stop()
	self._panel:child("output_panel"):animate(callback(self, self, "_animate_fade_output"))
	self._input_panel:stop()
	self._input_panel:animate(callback(self, self, "_animate_hide_input"))

	local text = self._input_panel:child("input_text")

	text:stop()
	self._input_panel:child("input_bg"):stop()
	self:set_layer(self._layer or 20)
	self:update_caret()

	return true
end

function ChatGui:_shift()
	local k = Input:keyboard()

	return k:down("left shift") or k:down("right shift") or k:has_button("shift") and k:down("shift")
end

function ChatGui.blink(o)
	while true do
		o:set_color(Color(0, 1, 1, 1))
		wait(0.3)
		o:set_color(Color.white)
		wait(0.3)
	end
end

function ChatGui:set_blinking(b)
	local caret = self._input_panel:child("caret")

	if b == self._blinking then
		return
	end

	if b then
		caret:animate(self.blink)
	else
		caret:stop()
	end

	self._blinking = b

	if not self._blinking then
		caret:set_color(Color.white)
	end
end

function ChatGui:update_caret()
	local text = self._input_panel:child("input_text")
	local caret = self._input_panel:child("caret")
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()

	if s == 0 and e == 0 then
		if text:align() == "center" then
			x = text:world_x() + text:w() / 2
		else
			x = text:world_x()
		end

		y = text:world_y()
	end

	h = text:h()

	if w < 3 then
		w = 3
	end

	if not self._focus then
		w = 0
		h = 0
	end

	caret:set_world_shape(x, y + 2, w, h - 4)
	self:set_blinking(s == e and self._focus)

	local mid = x / self._input_panel:child("input_bg"):w()

	self._input_panel:child("input_bg"):set_color(Color.black:with_alpha(0.4))
end

function ChatGui:enter_text(o, s)
	if managers.hud and managers.hud:showing_stats_screen() then
		return
	end

	if self._skip_first then
		self._skip_first = false

		return
	end

	local text = self._input_panel:child("input_text")

	if type(self._typing_callback) ~= "number" then
		self._typing_callback()
	end

	text:replace_text(s)

	local lbs = text:line_breaks()

	if #lbs > 1 then
		local s = lbs[2]
		local e = utf8.len(text:text())

		text:set_selection(s, e)
		text:replace_text("")
	end

	self:update_caret()
end

function ChatGui:update_key_down(o, k)
	wait(0.6)

	local text = self._input_panel:child("input_text")

	while self._key_pressed == k do
		local s, e = text:selection()
		local n = utf8.len(text:text())
		local d = math.abs(e - s)

		if self._key_pressed == Idstring("backspace") then
			if s == e and s > 0 then
				text:set_selection(s - 1, e)
			end

			text:replace_text("")

			if utf8.len(text:text()) < 1 and type(self._esc_callback) ~= "number" then
				-- Nothing
			end
		elseif self._key_pressed == Idstring("delete") then
			if s == e and s < n then
				text:set_selection(s, e + 1)
			end

			text:replace_text("")

			if utf8.len(text:text()) < 1 and type(self._esc_callback) ~= "number" then
				-- Nothing
			end
		elseif self._key_pressed == Idstring("insert") then
			local clipboard = Application:get_clipboard() or ""

			text:replace_text(clipboard)

			local lbs = text:line_breaks()

			if #lbs > 1 then
				local s = lbs[2]
				local e = utf8.len(text:text())

				text:set_selection(s, e)
				text:replace_text("")
			end
		elseif self._key_pressed == Idstring("left") then
			if s < e then
				text:set_selection(s, s)
			elseif s > 0 then
				text:set_selection(s - 1, s - 1)
			end
		elseif self._key_pressed == Idstring("right") then
			if s < e then
				text:set_selection(e, e)
			elseif s < n then
				text:set_selection(s + 1, s + 1)
			end
		else
			self._key_pressed = false
		end

		self:update_caret()
		wait(0.03)
	end
end

function ChatGui:key_release(o, k)
	if self._key_pressed == k then
		self._key_pressed = false
	end
end

function ChatGui:key_press(o, k)
	if self._skip_first then
		if k == Idstring("enter") then
			self._skip_first = false
		end

		return
	end

	if not self._enter_text_set then
		self._input_panel:enter_text(callback(self, self, "enter_text"))

		self._enter_text_set = true
	end

	local text = self._input_panel:child("input_text")
	local s, e = text:selection()
	local n = utf8.len(text:text())
	local d = math.abs(e - s)
	self._key_pressed = k

	text:stop()
	text:animate(callback(self, self, "update_key_down"), k)

	if k == Idstring("backspace") then
		if s == e and s > 0 then
			text:set_selection(s - 1, e)
		end

		text:replace_text("")

		if utf8.len(text:text()) < 1 and type(self._esc_callback) ~= "number" then
			-- Nothing
		end
	elseif k == Idstring("delete") then
		if s == e and s < n then
			text:set_selection(s, e + 1)
		end

		text:replace_text("")

		if utf8.len(text:text()) < 1 and type(self._esc_callback) ~= "number" then
			-- Nothing
		end
	elseif k == Idstring("insert") then
		local clipboard = Application:get_clipboard() or ""

		text:replace_text(clipboard)

		local lbs = text:line_breaks()

		if #lbs > 1 then
			local s = lbs[2]
			local e = utf8.len(text:text())

			text:set_selection(s, e)
			text:replace_text("")
		end
	elseif k == Idstring("left") then
		if s < e then
			text:set_selection(s, s)
		elseif s > 0 then
			text:set_selection(s - 1, s - 1)
		end
	elseif k == Idstring("right") then
		if s < e then
			text:set_selection(e, e)
		elseif s < n then
			text:set_selection(s + 1, s + 1)
		end
	elseif self._key_pressed == Idstring("end") then
		text:set_selection(n, n)
	elseif self._key_pressed == Idstring("home") then
		text:set_selection(0, 0)
	elseif k == Idstring("enter") then
		if type(self._enter_callback) ~= "number" then
			self._enter_callback()
		end
	elseif k == Idstring("esc") and type(self._esc_callback) ~= "number" then
		text:set_text("")
		text:set_selection(0, 0)
		self._esc_callback()
	end

	self:update_caret()
end

function ChatGui:send_message(name, message)
end

function ChatGui:receive_message(name, message, color, icon)
	if not alive(self._panel) or not managers.network:session() then
		return
	end

	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")
	local local_peer = managers.network:session():local_peer()
	local peers = managers.network:session():peers()
	local len = utf8.len(name) + 1
	local x = 0
	local icon_bitmap = nil

	if icon then
		local icon_texture, icon_texture_rect = tweak_data.hud_icons:get_icon_data(icon)
		icon_bitmap = scroll_panel:bitmap({
			y = 1,
			texture = icon_texture,
			texture_rect = icon_texture_rect,
			color = color
		})
		x = icon_bitmap:right()
	end

	local line = scroll_panel:text({
		halign = "left",
		vertical = "top",
		hvertical = "top",
		wrap = true,
		align = "left",
		blend_mode = "normal",
		word_wrap = true,
		y = 0,
		layer = 0,
		text = name .. ": " .. message,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		x = x,
		w = scroll_panel:w() - x,
		color = color
	})
	local total_len = utf8.len(line:text())

	line:set_range_color(0, len, color)
	line:set_range_color(len, total_len, Color.white)

	local _, _, w, h = line:text_rect()

	line:set_h(h)

	local line_bg = scroll_panel:rect({
		hvertical = "top",
		halign = "left",
		layer = -1,
		color = Color.black:with_alpha(0.5)
	})

	line_bg:set_h(h)
	line:set_kern(line:kern())
	table.insert(self._lines, {
		line,
		line_bg,
		icon_bitmap
	})
	self:_layout_output_panel()

	if not self._focus then
		output_panel:stop()
		output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
		output_panel:animate(callback(self, self, "_animate_fade_output"))
		self:start_notify_new_message()
	end
end

function ChatGui:_animate_fade_output()
	if self._is_crimenet_chat then
		return
	end

	local wait_t = 10
	local fade_t = 1
	local t = 0

	while wait_t > t do
		local dt = coroutine.yield()
		t = t + dt
	end

	local t = 0

	while fade_t > t do
		local dt = coroutine.yield()
		t = t + dt

		self:set_output_alpha(1 - t / fade_t)
	end

	self:set_output_alpha(0)
end

function ChatGui:_animate_show_component(panel, start_alpha)
	local TOTAL_T = 0.25
	local t = 0
	start_alpha = start_alpha or 0

	while t < TOTAL_T do
		local dt = coroutine.yield()
		t = t + dt

		panel:set_alpha(start_alpha + t / TOTAL_T * (1 - start_alpha))
	end

	panel:set_alpha(1)
end

function ChatGui:_animate_show_input(input_panel)
	local TOTAL_T = 0.2
	local start_alpha = input_panel:alpha()
	local end_alpha = 1

	over(TOTAL_T, function (p)
		input_panel:set_alpha(math.lerp(start_alpha, end_alpha, p))
	end)
end

function ChatGui:_animate_hide_input(input_panel)
	local TOTAL_T = 0.2
	local start_alpha = input_panel:alpha()
	local end_alpha = 0.7

	over(TOTAL_T, function (p)
		input_panel:set_alpha(math.lerp(start_alpha, end_alpha, p))
	end)
end

function ChatGui:_animate_input_bg(input_bg)
	local t = 0

	while true do
		local dt = coroutine.yield()
		t = t + dt
		local a = 0.75 + (1 + math.sin(t * 200)) / 8

		input_bg:set_alpha(a)
	end
end

function ChatGui:set_output_alpha(alpha)
	self._panel:child("output_panel"):set_alpha(alpha)
end

function ChatGui:close(...)
	self._panel:child("output_panel"):stop()
	self._input_panel:stop()
	self._hud_panel:remove(self._panel)
	self._hud_panel:remove(self._hud_blur)
	self._hud_panel:remove(self._hud_panel:child("chat_button_panel"))
	managers.chat:unregister_receiver(self._channel_id, self)
end
