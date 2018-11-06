FriendsBoxGui = FriendsBoxGui or class(TextBoxGui)

function FriendsBoxGui:init(ws, title, text, content_data, config, type)
	self._type = type
	config = config or {}
	config.h = 300
	config.w = 300
	local x, y = ws:size()
	config.x = x - config.w
	config.y = y - config.h - CoreMenuRenderer.Renderer.border_height + 10
	config.no_close_legend = true
	config.no_scroll_legend = true
	self._default_font_size = tweak_data.menu.default_font_size
	self._topic_state_font_size = 22
	self._ingame_color = Color(0.8, 1, 0.8)
	self._online_color = Color(0.6, 0.8, 1)
	self._offline_color = Color(0.5, 0.5, 0.5)

	FriendsBoxGui.super.init(self, ws, title, text, content_data, config)

	self._users = {}

	self:update_friends()
	self:set_layer(10)
end

function FriendsBoxGui:_create_friend_action_gui_by_user(user_data)
	if self._friend_action_gui then
		self._friend_action_gui:close()
	end

	local user = user_data.user
	local offline = user_data.main_state == "offline"
	local data = {
		button_list = {}
	}
	local my_lobby_id = managers.network.matchmake.lobby_handler and managers.network.matchmake.lobby_handler:id()
	local user_lobby_id = user:lobby() and user:lobby():id()

	if not my_lobby_id and user_lobby_id and not user_data.payday1 and not Global.game_settings.single_player then
		local join_game = {
			text = "Join Game",
			id_name = "join_game"
		}

		table.insert(data.button_list, join_game)
	end

	if not offline and managers.network.matchmake.lobby_handler and not user_lobby_id then
		local invite = {
			text = "Invite",
			id_name = "invite"
		}

		table.insert(data.button_list, invite)
	end

	local chat_button = {
		text = "Message",
		id_name = "message"
	}

	table.insert(data.button_list, chat_button)

	local profile_button = {
		text = "View profile",
		id_name = "view_profile"
	}

	table.insert(data.button_list, profile_button)

	local achievements_button = {
		text = "View achievements",
		id_name = "view_achievements"
	}

	table.insert(data.button_list, achievements_button)

	local stats_button = {
		text = "View stats",
		id_name = "view_stats"
	}

	table.insert(data.button_list, stats_button)

	local outfit = user:rich_presence("outfit")

	if outfit ~= "" and managers.menu_scene then
		local view_character_button = {
			text = "View character",
			id_name = "view_character"
		}

		table.insert(data.button_list, view_character_button)
	end

	data.focus_button = 1
	local h = 78 + #data.button_list * 24
	self._friend_action_gui = TextBoxGui:new(self._ws, nil, nil, data, {
		only_buttons = true,
		no_close_legend = true,
		y = 0,
		w = 200,
		x = 0,
		h = h
	})

	self._friend_action_gui:set_layer(self:layer() + 20)
end

function FriendsBoxGui:set_layer(layer)
	FriendsBoxGui.super.set_layer(self, layer)

	if self._friend_action_gui then
		self._friend_action_gui:set_layer(layer + 20)
	end
end

function FriendsBoxGui:update_friends()
	if not Steam:logged_on() then
		return
	end

	local new_users = {}
	local friends = self._type == "recent" and Steam:coplay_friends() or Steam:friends() or {}

	for _, user in ipairs(friends) do
		local main_state, sub_state = nil
		local state = user:state()
		local rich_presence_status = user:rich_presence("status")
		local rich_presence_level = user:rich_presence("level")
		local payday1 = rich_presence_level == ""
		local playing_this = user:playing_this()

		if playing_this then
			main_state = "ingame"
			sub_state = state .. (payday1 and " - PAYDAY 1" or "")
		elseif state == "online" or state == "away" then
			main_state = "online"
			sub_state = state
		else
			main_state = state
			sub_state = state
		end

		if user:lobby() then
			local numbers = managers.network.matchmake:_lobby_to_numbers(user:lobby())

			if #numbers > 0 then
				local level_id = tweak_data.levels:get_level_name_from_index(numbers[1])
				sub_state = managers.localization:text(tweak_data.levels[level_id] and tweak_data.levels[level_id].name_id or "SECRET LEVEL")
				sub_state = sub_state .. (payday1 and " - PAYDAY 1" or "")
			end
		elseif rich_presence_status == "" then
			if main_state == "ingame" then
				-- Nothing
			elseif main_state == "offline" then
				-- Nothing
			end
		else
			sub_state = rich_presence_status
		end

		if not self._users[user:id()] then
			self._users[user:id()] = {
				user = user,
				main_state = main_state,
				sub_state = sub_state,
				lobby = user:lobby(),
				level = rich_presence_level,
				payday1 = payday1
			}

			table.insert(new_users, user:id())
		end

		self._users[user:id()].user = user
		self._users[user:id()].current_main_state = main_state
		self._users[user:id()].current_sub_state = sub_state
		self._users[user:id()].current_lobby = user:lobby()
		self._users[user:id()].current_level = rich_presence_level
		self._users[user:id()].payday1 = payday1
	end

	local friends_panel = self._scroll_panel:child("friends_panel")
	local ingame_panel = friends_panel:child("ingame_panel")
	local online_panel = friends_panel:child("online_panel")
	local offline_panel = friends_panel:child("offline_panel")

	for _, user_id in ipairs(new_users) do
		local user = self._users[user_id].user
		local main_state = self._users[user_id].main_state
		local sub_state = self._users[user_id].sub_state
		local level = self._users[user_id].level

		if main_state == "ingame" then
			self:_create_user(ingame_panel, 0, user, "ingame", sub_state, level)
		elseif main_state == "online" or main_state == "away" then
			self:_create_user(online_panel, 0, user, "online", sub_state, level)
		else
			self:_create_user(offline_panel, 0, user, "offline", sub_state, level)
		end
	end

	for _, user in pairs(self._users) do
		if user.main_state ~= user.current_main_state then
			if user.main_state == "online" then
				online_panel:remove(online_panel:child(user.user:id()))
			elseif user.main_state == "ingame" then
				ingame_panel:remove(ingame_panel:child(user.user:id()))
			else
				offline_panel:remove(offline_panel:child(user.user:id()))
			end

			if user.current_main_state == "ingame" then
				self:_create_user(ingame_panel, 0, user.user, "ingame", user.sub_state, user.level)
			elseif user.current_main_state == "online" then
				self:_create_user(online_panel, 0, user.user, "online", user.sub_state, user.level)
			else
				self:_create_user(offline_panel, 0, user.user, "offline", user.sub_state, user.level)
			end

			user.main_state = user.current_main_state
		elseif user.sub_state ~= user.current_sub_state then
			self:_update_sub_state(user)

			user.sub_state = user.current_sub_state
		end

		if user.lobby ~= user.current_lobby then
			local panel = self:_get_user_panel(user.user:id())

			panel:child("lobby"):set_visible(user.current_lobby and true or false)

			user.lobby = user.current_lobby
		end

		if user.level ~= user.current_level then
			print("CHANGED LEVEL", user.level, user.current_level)

			user.level = user.current_level
			local panel = self:_get_user_panel(user.user:id())
			local user_level = panel:child("user_level")

			user_level:set_text(user.level)

			local _, _, w, h = user_level:text_rect()

			user_level:set_size(w, h)
			user_level:set_right(math.floor(panel:w()))
			user_level:set_center_y(math.round(panel:child("user_name"):center_y()))
			user_level:set_visible(true)
		end
	end

	self:_layout_friends_panel()
end

function FriendsBoxGui:_update_sub_state(user_data)
	local friends_panel = self._scroll_panel:child("friends_panel")
	local panel = nil

	if user_data.main_state == "ingame" then
		panel = friends_panel:child("ingame_panel")
	elseif user_data.main_state == "online" then
		panel = friends_panel:child("online_panel")
	else
		panel = friends_panel:child("offline_panel")
	end

	local user_panel = panel:child(user_data.user:id())
	local user_state = user_panel:child("user_state")

	user_state:set_text(string.upper(user_data.current_sub_state))

	local _, _, w, _ = user_state:text_rect()

	user_state:set_w(w)
end

function FriendsBoxGui:_layout_friends_panel()
	local friends_panel = self._scroll_panel:child("friends_panel")
	local ingame_panel = friends_panel:child("ingame_panel")
	local online_panel = friends_panel:child("online_panel")
	local offline_panel = friends_panel:child("offline_panel")
	local ingame_text = friends_panel:child("ingame_text")
	local online_text = friends_panel:child("online_text")
	local offline_text = friends_panel:child("offline_text")
	local h = 0

	ingame_text:set_y(math.round(h))

	h = h + ingame_text:h()

	ingame_panel:set_y(math.round(h))

	h = h + self:_get_state_h(ingame_panel)

	online_text:set_y(math.round(h))

	h = h + online_text:h()

	online_panel:set_y(math.round(h))

	h = h + self:_get_state_h(online_panel)

	offline_text:set_y(math.round(h))

	h = h + offline_text:h()

	offline_panel:set_y(math.round(h))

	h = h + self:_get_state_h(offline_panel)

	friends_panel:set_h(math.ceil(h))
	self._scroll_panel:set_h(math.max(self._scroll_panel:h(), friends_panel:h()))
	self:_set_scroll_indicator()
	self:_check_scroll_indicator_states()
end

function FriendsBoxGui:_get_state_h(panel)
	local h = 0

	for _, child in ipairs(panel:children()) do
		child:set_y(math.ceil(h))

		h = h + child:h()
	end

	panel:set_h(h)

	return h
end

function FriendsBoxGui:_create_text_box(ws, title, text, content_data, config)
	FriendsBoxGui.super._create_text_box(self, ws, title, text, content_data, config)

	local friends_panel = self._scroll_panel:panel({
		h = 600,
		name = "friends_panel",
		x = 0,
		layer = 1
	})
	local ingame_panel = friends_panel:panel({
		h = 100,
		name = "ingame_panel",
		x = 0,
		layer = 0
	})
	local online_panel = friends_panel:panel({
		h = 100,
		name = "online_panel",
		x = 0,
		layer = 0
	})
	local offline_panel = friends_panel:panel({
		h = 100,
		name = "offline_panel",
		x = 0,
		layer = 0
	})
	local h = 0
	local ingame_text = friends_panel:text({
		vertical = "center",
		name = "ingame_text",
		hvertical = "center",
		align = "left",
		halign = "left",
		text = managers.localization:text("menu_ingame"),
		font = tweak_data.menu.default_font,
		font_size = self._topic_state_font_size,
		y = h,
		color = Color(0.75, 0.75, 0.75)
	})
	local _, _, tw, th = ingame_text:text_rect()

	ingame_text:set_size(tw, th)

	h = h + th
	local online_text = friends_panel:text({
		vertical = "center",
		name = "online_text",
		hvertical = "center",
		align = "left",
		halign = "left",
		text = managers.localization:text("menu_online"),
		font = tweak_data.menu.default_font,
		font_size = self._topic_state_font_size,
		y = h,
		color = Color(0.75, 0.75, 0.75)
	})
	local _, _, tw, th = online_text:text_rect()

	online_text:set_size(tw, th)

	h = h + th
	local offline_text = friends_panel:text({
		vertical = "center",
		name = "offline_text",
		hvertical = "center",
		align = "left",
		halign = "left",
		text = managers.localization:text("menu_offline"),
		font = tweak_data.menu.default_font,
		font_size = self._topic_state_font_size,
		y = h,
		color = Color(0.75, 0.75, 0.75)
	})
	local _, _, tw, th = offline_text:text_rect()

	offline_text:set_size(tw, th)

	h = h + th

	friends_panel:set_h(h)
	self._scroll_panel:set_h(math.max(self._scroll_panel:h(), friends_panel:h()))
	self:_set_scroll_indicator()
	self:_layout_friends_panel()
end

function FriendsBoxGui:_create_user(friends_panel, h, user, state, sub_state, level)
	local color = state == "online" and self._online_color or state == "ingame" and self._ingame_color or self._offline_color
	local panel = friends_panel:panel({
		layer = 0,
		name = user:id(),
		y = h
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data(table.random({
		"mask_clown",
		"mask_alien"
	}) .. math.random(4))
	local avatar = panel:bitmap({
		name = "avatar",
		layer = 0,
		visible = true,
		y = 0,
		x = 0,
		texture = texture,
		texture_rect = rect
	})
	local user_name = panel:text({
		y = 0,
		name = "user_name",
		vertical = "center",
		hvertical = "center",
		align = "left",
		halign = "left",
		layer = 0,
		text = user:name(),
		font = tweak_data.menu.default_font,
		font_size = self._default_font_size,
		x = 16 + avatar:right(),
		color = color
	})
	local _, _, tw, th = user_name:text_rect()

	user_name:set_size(tw, th)

	local user_level = panel:text({
		name = "user_level",
		vertical = "center",
		hvertical = "center",
		align = "right",
		blend_mode = "normal",
		halign = "right",
		x = 16,
		layer = 0,
		text = level,
		font = tweak_data.menu.small_font_noshadow,
		font_size = tweak_data.menu.small_font_size,
		y = math.round(0),
		color = color,
		visible = state ~= "offline"
	})
	local _, _, sw, sh = user_level:text_rect()

	user_level:set_size(sw, sh)
	user_level:set_right(math.floor(panel:w()))
	user_level:set_center_y(math.round(user_name:center_y()))

	local user_state = panel:text({
		name = "user_state",
		vertical = "center",
		hvertical = "center",
		align = "left",
		blend_mode = "normal",
		halign = "left",
		layer = 0,
		text = string.upper(sub_state),
		font = tweak_data.menu.small_font_noshadow,
		font_size = tweak_data.menu.small_font_size,
		x = 16 + avatar:right(),
		y = math.round(0 + th),
		color = color,
		visible = state ~= "offline"
	})
	local _, _, sw, sh = user_state:text_rect()

	user_state:set_size(sw, sh)
	panel:set_h(th + sh + 4)
	panel:rect({
		name = "marker_rect",
		visible = false,
		layer = -1,
		color = Color(0.5, 0.5, 0.5, 0.5)
	})

	local texture, rect = tweak_data.hud_icons:get_icon_data("icon_equipped")
	local arrow = panel:bitmap({
		name = "arrow",
		layer = 0,
		visible = false,
		texture = texture,
		texture_rect = rect,
		x = avatar:right()
	})

	arrow:set_center_y(user_name:center_y())

	local texture, rect = tweak_data.hud_icons:get_icon_data("icon_addon")
	local lobby = panel:bitmap({
		name = "lobby",
		layer = 0,
		visible = false,
		texture = texture,
		texture_rect = rect
	})

	lobby:set_center_y(user_state:center_y())
	lobby:set_right(panel:w())
end

function FriendsBoxGui:mouse_pressed(button, x, y)
	if self._friend_action_gui and self._friend_action_gui:visible() and self._friend_action_gui:in_info_area_focus(x, y) then
		if button == Idstring("0") then
			local focus_btn_id = self._friend_action_gui:get_focus_button_id()

			print("get_focus_button_id()", focus_btn_id)

			if focus_btn_id == "join_game" then
				print(" join game ", self._friend_action_user, self._friend_action_user:lobby())

				if self._friend_action_user:lobby() then
					managers.network.matchmake:join_server_with_check(self._friend_action_user:lobby():id())
				end
			elseif focus_btn_id == "message" then
				self._friend_action_user:open_overlay("chat")
			elseif focus_btn_id == "view_profile" then
				self._friend_action_user:open_overlay("steamid")
			elseif focus_btn_id == "view_achievements" then
				self._friend_action_user:open_overlay("achievements")
			elseif focus_btn_id == "view_stats" then
				self._friend_action_user:open_overlay("stats")
			elseif focus_btn_id == "view_character" then
				managers.menu:on_view_character(self._friend_action_user)
			elseif focus_btn_id == "invite" then
				print("send invite")

				if managers.network.matchmake.lobby_handler then
					self._friend_action_user:invite(managers.network.matchmake.lobby_handler:id())
				end
			end

			self:_hide_friend_action_user()
		end

		return true
	end

	if self:in_info_area_focus(x, y) and button == Idstring("0") then
		local user_panel = self:_inside_user(x, y)

		if user_panel then
			if self._users[user_panel:name()].current_lobby then
				managers.menu_component:criment_goto_lobby(self._users[user_panel:name()].lobby)
			end

			if self._friend_action_user ~= self._users[user_panel:name()].user then
				self._friend_action_user = self._users[user_panel:name()].user

				self:_create_friend_action_gui_by_user(self._users[user_panel:name()])

				x = x + 16
				y = y - 16

				if x + self._friend_action_gui:w() > self:x() + self:w() - 20 then
					x = self:x() + self:w() - 20 - self._friend_action_gui:w()
				end

				if y + self._friend_action_gui:h() > self:y() + self:h() then
					y = self:y() + self:h() - self._friend_action_gui:h()
				end

				self._friend_action_gui:set_position(x, y)
			else
				self:_hide_friend_action_user()
			end

			return true
		end
	end

	self:_hide_friend_action_user()
end

function FriendsBoxGui:_hide_friend_action_user()
	self._friend_action_user = nil

	if self._friend_action_gui then
		self._friend_action_gui:set_visible(false)
	end
end

function FriendsBoxGui:_inside_user(x, y)
	local friends_panel = self._scroll_panel:child("friends_panel")
	local ingame_panel = friends_panel:child("ingame_panel")
	local online_panel = friends_panel:child("online_panel")
	local offline_panel = friends_panel:child("offline_panel")

	for _, user_panel in ipairs(ingame_panel:children()) do
		if user_panel:inside(x, y) then
			return user_panel
		end
	end

	for _, user_panel in ipairs(online_panel:children()) do
		if user_panel:inside(x, y) then
			return user_panel
		end
	end

	for _, user_panel in ipairs(offline_panel:children()) do
		if user_panel:inside(x, y) then
			return user_panel
		end
	end

	return nil
end

function FriendsBoxGui:_get_user_panel(id)
	local friends_panel = self._scroll_panel:child("friends_panel")
	local ingame_panel = friends_panel:child("ingame_panel")
	local online_panel = friends_panel:child("online_panel")
	local offline_panel = friends_panel:child("offline_panel")

	return ingame_panel:child(id) or online_panel:child(id) or offline_panel:child(id)
end

function FriendsBoxGui:mouse_moved(x, y)
	if self._friend_action_gui and self._friend_action_gui:visible() and self._friend_action_gui:in_info_area_focus(x, y) then
		self._friend_action_gui:check_focus_button(x, y)

		return
	end

	local friends_panel = self._scroll_panel:child("friends_panel")

	self:_set_user_panels_state(x, y, friends_panel:child("ingame_panel"), self._ingame_color)
	self:_set_user_panels_state(x, y, friends_panel:child("online_panel"), self._online_color)
	self:_set_user_panels_state(x, y, friends_panel:child("offline_panel"), self._offline_color)
end

function FriendsBoxGui:_set_user_panels_state(x, y, panel, color)
	for _, user_panel in ipairs(panel:children()) do
		local inside = user_panel:inside(x, y)

		user_panel:child("arrow"):set_visible(inside)
		user_panel:child("user_name"):set_color(inside and Color.white or color)
		user_panel:child("user_state"):set_color(inside and Color.white or color)
	end
end

function FriendsBoxGui:_check_scroll_indicator_states()
	FriendsBoxGui.super._check_scroll_indicator_states(self)
end

function FriendsBoxGui:set_size(x, y)
	FriendsBoxGui.super.set_size(self, x, y)

	local friends_panel = self._scroll_panel:child("friends_panel")

	friends_panel:set_w(self._scroll_panel:w())

	local function f(friends_panel, panel)
		panel:set_w(friends_panel:w())

		for _, user_panel in ipairs(panel:children()) do
			user_panel:set_w(panel:w())
			user_panel:child("lobby"):set_right(user_panel:w())
		end
	end

	f(friends_panel, friends_panel:child("ingame_panel"))
	f(friends_panel, friends_panel:child("online_panel"))
	f(friends_panel, friends_panel:child("offline_panel"))
end

function FriendsBoxGui:set_visible(visible)
	if not visible then
		self:_hide_friend_action_user()
	end

	FriendsBoxGui.super.set_visible(self, visible)
end

function FriendsBoxGui:close()
	print("FriendsBoxGui:close()")
	FriendsBoxGui.super.close(self)

	if self._friend_action_gui then
		self._friend_action_gui:close()
	end
end
