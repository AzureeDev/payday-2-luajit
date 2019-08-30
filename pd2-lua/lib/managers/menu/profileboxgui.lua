ProfileBoxGui = ProfileBoxGui or class(TextBoxGui)

function ProfileBoxGui:init(ws, title, text, content_data, config)
	config = config or {}
	config.h = config.h or 260
	config.w = config.w or 280
	local x, y = ws:size()
	config.x = config.x or 0
	config.y = config.y or y - config.h - CoreMenuRenderer.Renderer.border_height
	config.no_close_legend = true
	config.no_scroll_legend = true
	config.use_minimize_legend = true
	title = "Profile"
	self._stats_font_size = 14
	self._stats_items = self._stats_items or {}

	ProfileBoxGui.super.init(self, ws, title, text, content_data, config)
	self:set_layer(10)
end

function ProfileBoxGui:_profile_name()
	return managers.network.account:username()
end

function ProfileBoxGui:_profile_level()
	return "" .. managers.experience:current_level()
end

function ProfileBoxGui:update(t, dt)
	local name_panel = self._scroll_panel:child("profile_panel"):child("name_panel")
	local name = name_panel:child("name")

	if name_panel:w() < name:w() then
		if self._name_right then
			if name:x() < 0 then
				name:set_x(name:x() + dt * 10)
			else
				self._name_right = false
			end
		elseif name_panel:w() < name:right() then
			name:set_x(name:x() - dt * 10)
		else
			self._name_right = true
		end
	end
end

function ProfileBoxGui:_create_text_box(ws, title, text, content_data, config)
	ProfileBoxGui.super._create_text_box(self, ws, title, text, content_data, config)

	local profile_panel = self._scroll_panel:panel({
		name = "profile_panel",
		h = 600,
		x = 0,
		layer = 1,
		w = self._scroll_panel:w()
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data(table.random({
		"mask_clown",
		"mask_alien"
	}) .. math.random(4))
	local avatar = profile_panel:bitmap({
		name = "avatar",
		layer = 0,
		visible = true,
		y = 10,
		x = 0,
		texture = texture,
		texture_rect = rect
	})

	profile_panel:gradient({
		y = 10,
		name = "avatar_indicator",
		blend_mode = "add",
		visible = false,
		orientation = "vertical",
		x = 0,
		layer = 1,
		gradient_points = {
			0,
			Color(0, 1, 0.6588235294117647, 0),
			0.5,
			Color(0, 0.6039215686274509, 0.4, 0),
			1,
			Color(1, 0.8, 0.19607843137254902, 0)
		},
		w = avatar:w(),
		h = avatar:h()
	})

	local name_panel = profile_panel:panel({
		name = "name_panel",
		w = self._panel:w() - (avatar:right() + 16) - 64
	})

	name_panel:set_left(avatar:right() + 16)
	name_panel:set_y(avatar:y())

	local name = name_panel:text({
		y = 0,
		name = "name",
		vertical = "top",
		hvertical = "top",
		align = "left",
		halign = "left",
		x = 0,
		layer = 0,
		text = self:_profile_name(),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = Color(0.8, 1, 0.8)
	})
	local _, _, tw, th = name:text_rect()

	name_panel:set_h(th)
	name:set_h(th)
	name:set_w(tw + 4)

	local level = profile_panel:text({
		name = "level",
		vertical = "center",
		hvertical = "center",
		align = "right",
		blend_mode = "normal",
		halign = "right",
		x = 16,
		layer = 0,
		text = self:_profile_level(),
		font = tweak_data.menu.small_font_noshadow,
		font_size = tweak_data.menu.small_font_size,
		y = math.round(0),
		color = Color(0.8, 1, 0.8)
	})
	local _, _, sw, sh = level:text_rect()

	level:set_size(sw, sh)
	level:set_right(math.floor(profile_panel:w()))
	level:set_center_y(math.round(name_panel:center_y()))

	local texture, rect = tweak_data.hud_icons:get_icon_data("icon_equipped")
	local arrow = profile_panel:bitmap({
		name = "arrow",
		layer = 0,
		visible = false,
		texture = texture,
		texture_rect = rect,
		x = avatar:right()
	})

	arrow:set_center_y(name_panel:center_y())
	self:_add_statistics()

	if #self._stats_items == 0 then
		profile_panel:set_h(74)
	else
		profile_panel:set_h(math.ceil(self._stats_items[#self._stats_items]:bottom()) + 10)
	end

	self._scroll_panel:set_h(math.max(self._scroll_panel:h(), profile_panel:h()))
	self:_set_scroll_indicator()
end

function ProfileBoxGui:_add_statistics()
	self:_add_stats({
		name = "achievements",
		type = "progress",
		topic = string.upper("Achievements:"),
		data = managers.achievment:total_unlocked() / managers.achievment:total_amount(),
		text = "" .. managers.achievment:total_unlocked() .. "/" .. managers.achievment:total_amount()
	})
	self:_add_stats({
		type = "progress",
		topic = managers.localization:text("menu_stats_level_progress"),
		data = managers.experience:current_level() / managers.experience:level_cap(),
		text = "" .. managers.experience:current_level() .. "/" .. managers.experience:level_cap()
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_money"),
		data = managers.experience:total_cash_string()
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_time_played"),
		data = managers.statistics:time_played() .. " " .. managers.localization:text("menu_stats_time")
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_total_kills"),
		data = "" .. managers.statistics:total_kills()
	})
end

function ProfileBoxGui:_add_stats(params)
	local y = 64

	for _, panel in ipairs(self._stats_items) do
		y = y + panel:h() + 4
	end

	local xo = 4
	local panel = self._scroll_panel:child("profile_panel"):panel({
		name = params.name,
		y = y,
		w = self._scroll_panel:child("profile_panel"):w()
	})
	local topic = panel:text({
		name = "topic",
		halign = "left",
		vertical = "center",
		align = "left",
		y = 0,
		layer = 2,
		font = tweak_data.menu.small_font,
		font_size = self._stats_font_size,
		color = Color.white,
		x = xo,
		w = panel:w(),
		text = params.topic
	})
	local x, y, w, h = topic:text_rect()

	topic:set_h(math.ceil(h))
	panel:set_h(math.ceil(h))

	if params.type == "text" then
		local text = panel:text({
			name = "text",
			halign = "right",
			align = "right",
			vertical = "center",
			valign = "center",
			y = 0,
			layer = 2,
			font = tweak_data.menu.small_font,
			font_size = self._stats_font_size,
			color = Color.white,
			x = -xo,
			h = h,
			w = self._scroll_panel:child("profile_panel"):w(),
			text = params.data
		})
	end

	if params.type == "progress" then
		h = h + 4

		topic:set_h(math.ceil(h))
		panel:set_h(math.ceil(h))

		local bg = panel:rect({
			name = "bg",
			y = 0,
			x = 0,
			layer = 0,
			w = panel:w(),
			h = h,
			color = Color.black:with_alpha(0.5)
		})
		local bar = panel:gradient({
			halign = "center",
			name = "bar",
			vertical = "center",
			align = "center",
			orientation = "vertical",
			x = 2,
			layer = 1,
			gradient_points = {
				0,
				Color(1, 1, 0.6588235294117647, 0),
				1,
				Color(1, 0.6039215686274509, 0.4, 0)
			},
			y = bg:y() + 2,
			w = (bg:w() - 4) * params.data,
			h = bg:h() - 4
		})
		local text = panel:text({
			name = "bar_text",
			halign = "right",
			align = "right",
			vertical = "center",
			valign = "center",
			y = 0,
			layer = 2,
			font = tweak_data.menu.small_font,
			font_size = self._stats_font_size,
			color = Color.white,
			x = -xo,
			h = h,
			w = bg:w(),
			text = params.text or "" .. math.floor(params.data * 100) .. "%"
		})
	end

	table.insert(self._stats_items, panel)
end

function ProfileBoxGui:mouse_pressed(button, x, y)
	if not self:can_take_input() then
		return
	end

	if button == Idstring("0") and self._panel:child("info_area"):inside(x, y) then
		local profile_panel = self._scroll_panel:child("profile_panel")
		local name_panel = profile_panel:child("name_panel")

		if name_panel:inside(x, y) then
			self:_trigger_stats()

			return true
		elseif profile_panel:child("avatar"):inside(x, y) then
			self:_trigger_profile()

			return true
		elseif profile_panel:child("achievements") and profile_panel:child("achievements"):inside(x, y) then
			self:_trigger_achievements()

			return true
		end
	end
end

function ProfileBoxGui:_trigger_stats()
	Steam:overlay_activate("game", "Stats")
end

function ProfileBoxGui:_trigger_profile()
	Steam:user(managers.network.account:player_id()):open_overlay("steamid")
end

function ProfileBoxGui:_trigger_achievements()
	Steam:overlay_activate("game", "Achievements")
end

function ProfileBoxGui:mouse_moved(x, y)
	if not self:can_take_input() then
		return
	end

	local pointer = nil
	local inside_info = self._panel:child("info_area"):inside(x, y)
	local profile_panel = self._scroll_panel:child("profile_panel")
	local name_panel = profile_panel:child("name_panel")
	local inside = inside_info and name_panel:inside(x, y)

	name_panel:child("name"):set_color(inside and Color.white or Color(0.8, 1, 0.8))
	profile_panel:child("level"):set_color(inside and Color.white or Color(0.8, 1, 0.8))
	profile_panel:child("arrow"):set_visible(inside)

	if inside then
		pointer = "link"
	end

	local inside = inside_info and profile_panel:child("avatar"):inside(x, y)

	profile_panel:child("avatar_indicator"):set_visible(inside)

	if inside then
		pointer = "link"
	end

	if profile_panel:child("achievements") then
		local inside = inside_info and profile_panel:child("achievements"):inside(x, y)

		profile_panel:child("achievements"):child("topic"):set_color(inside and Color(0.8, 1, 0.8) or Color.white)
		profile_panel:child("achievements"):child("bar_text"):set_color(inside and Color(0.8, 1, 0.8) or Color.white)

		if inside then
			pointer = "link"
		end
	end

	local inside = inside_info and profile_panel:inside(x, y)
	pointer = pointer or inside and "arrow"

	return false, pointer
end

function ProfileBoxGui:_check_scroll_indicator_states()
	ProfileBoxGui.super._check_scroll_indicator_states(self)
end

function ProfileBoxGui:set_size(x, y)
	ProfileBoxGui.super.set_size(self, x, y)

	local profile_panel = self._scroll_panel:child("profile_panel")
end

function ProfileBoxGui:set_visible(visible)
	ProfileBoxGui.super.set_visible(self, visible)
end

function ProfileBoxGui:close()
	ProfileBoxGui.super.close(self)
end

LobbyProfileBoxGui = LobbyProfileBoxGui or class(ProfileBoxGui)

function LobbyProfileBoxGui:init(ws, title, text, content_data, config, peer_id)
	self._peer_id = peer_id

	LobbyProfileBoxGui.super.init(self, ws, title, text, content_data, config)
end

function LobbyProfileBoxGui:_trigger_stats()
	local peer = managers.network:session():peer(self._peer_id)
	local user = Steam:user(peer:ip())

	user:open_overlay("stats")
end

function LobbyProfileBoxGui:_trigger_profile()
	local peer = managers.network:session():peer(self._peer_id)
	local user = Steam:user(peer:ip())

	user:open_overlay("steamid")
end

function LobbyProfileBoxGui:_trigger_achievements()
	local peer = managers.network:session():peer(self._peer_id)
	local user = Steam:user(peer:ip())

	user:open_overlay("achievements")
end

function LobbyProfileBoxGui:_profile_name()
	return managers.network:session():peer(self._peer_id):name()
end

function LobbyProfileBoxGui:_profile_level()
	local peer = managers.network:session():peer(self._peer_id)
	local user = Steam:user(peer:ip())

	return "" .. (peer:profile("level") or user:rich_presence("level"))
end

function LobbyProfileBoxGui:_add_statistics()
end

ViewCharacterProfileBoxGui = ViewCharacterProfileBoxGui or class(ProfileBoxGui)

function ViewCharacterProfileBoxGui:init(ws, title, text, content_data, config, user)
	self._user = user

	ViewCharacterProfileBoxGui.super.init(self, ws, title, text, content_data, config)
end

function ViewCharacterProfileBoxGui:_trigger_stats()
	self._user:open_overlay("stats")
end

function ViewCharacterProfileBoxGui:_trigger_profile()
	self._user:open_overlay("steamid")
end

function ViewCharacterProfileBoxGui:_trigger_achievements()
	self._user:open_overlay("achievements")
end

function ViewCharacterProfileBoxGui:_profile_name()
	return self._user:name()
end

function ViewCharacterProfileBoxGui:_profile_level()
	return "" .. self._user:rich_presence("level")
end

function ViewCharacterProfileBoxGui:_add_statistics()
end
