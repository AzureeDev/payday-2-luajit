core:import("CoreMenuItem")

MenuItemCrimeNetSkirmishServer = MenuItemCrimeNetSkirmishServer or class(CoreMenuItem.Item)
MenuItemCrimeNetSkirmishServer.TYPE = "crimenet_server"

function MenuItemCrimeNetSkirmishServer:init(data_node, parameters)
	MenuItemCrimeNetSkirmishServer.super.init(self, data_node, parameters)

	self._type = MenuItemCrimeNetSkirmishServer.TYPE
end

function MenuItemCrimeNetSkirmishServer:setup_gui(node, row_item)
	local scaled_size = managers.gui_data:scaled_size()
	local color = tweak_data.screen_colors.skirmish_color
	local friend_color = tweak_data.screen_colors.friend_color
	local regular_color = tweak_data.screen_colors.regular_color
	local lobby = row_item.item:parameters().lobby
	local attributes_numbers = managers.network.matchmake:_lobby_to_numbers(lobby)
	local host_name = lobby:key_value("owner_name")
	local state_string_id = tweak_data:index_to_server_state(attributes_numbers[4])
	local state_name = state_string_id and managers.localization:text("menu_lobby_server_state_" .. state_string_id) or "UNKNOWN"
	local state = attributes_numbers[4]
	local num_plrs = attributes_numbers[5]
	local mutators = false
	local mkey = lobby:key_value("mutators")

	if mkey ~= "value_missing" and mkey ~= "value_pending" then
		local num_mutators = tonumber(mkey)
		mutators = num_mutators and num_mutators > 0
	end

	local is_friend = false

	if Steam:logged_on() and Steam:friends() then
		local owner_id = lobby:key_value("owner_id")

		for _, friend in ipairs(Steam:friends()) do
			if friend:id() == owner_id then
				is_friend = true

				break
			end
		end
	end

	local is_weekly = tonumber(lobby:key_value("skirmish")) == SkirmishManager.LOBBY_WEEKLY
	row_item.gui_panel = node.item_panel:panel({
		w = node.item_panel:w()
	})
	local server_panel = row_item.gui_panel:panel({
		name = "server",
		h = 64,
		y = 32,
		x = 10,
		layer = 100,
		w = row_item.gui_panel:w() - 20
	})
	local marker_dot = server_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_join",
		name = "marker_dot",
		h = 64,
		y = 22,
		w = 32,
		x = 2,
		layer = 1,
		color = mutators and tweak_data.screen_colors.mutators_color or color
	})
	local cx, cy = nil

	for i = 1, 4, 1 do
		cx = 5 + 6 * (i - 1)
		cy = 30
		local player_marker = server_panel:bitmap({
			texture = "guis/textures/pd2/crimenet_marker_peerflag",
			h = 16,
			w = 8,
			blend_mode = "normal",
			layer = 2,
			name = tostring(i),
			color = mutators and tweak_data.screen_colors.mutators_color or color,
			visible = i <= num_plrs
		})

		player_marker:set_position(cx, cy)
	end

	local side_panel = server_panel:panel({
		x = 36
	})
	local host_name = side_panel:text({
		name = "host_name",
		vertical = "center",
		blend_mode = "add",
		text = lobby:key_value("owner_name"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = is_friend and friend_color or regular_color
	})
	local skirmish_label = side_panel:text({
		name = "skirmish_label",
		vertical = "center",
		blend_mode = "normal",
		layer = 0,
		text = managers.localization:to_upper_text(is_weekly and "menu_weekly_skirmish" or "menu_skirmish"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = mutators and tweak_data.screen_colors.mutators_color_text or color
	})
	local state_label = side_panel:text({
		name = "state_label",
		vertical = "center",
		blend_mode = "add",
		text = state_name,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = color
	})
	local _, _, w, h = host_name:text_rect()

	host_name:set_size(w, h)
	host_name:set_position(0, 0)

	local _, _, w, h = skirmish_label:text_rect()

	skirmish_label:set_size(w, h)
	skirmish_label:set_position(0, host_name:bottom() - 2)

	local _, _, w, h = state_label:text_rect()

	state_label:set_size(w, h)
	state_label:set_position(0, skirmish_label:bottom() - 2)
	row_item.gui_panel:set_left(node:_mid_align())
	row_item.gui_panel:set_w(scaled_size.width - row_item.gui_panel:left())
	row_item.gui_panel:set_h(server_panel:h() + 20)

	local max_w = math.max(host_name:right(), skirmish_label:right()) + 10

	server_panel:set_w(marker_dot:right() + max_w)
	side_panel:set_w(max_w)
	server_panel:set_x(row_item.gui_panel:w() * 0.5 - server_panel:w() * 0.5)
	server_panel:set_y(10)

	return true
end

function MenuItemCrimeNetSkirmishServer:reload(row_item, node)
	MenuItemCrimeNetSkirmishServer.super.reload(self, row_item, node)
	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemCrimeNetSkirmishServer:highlight_row_item(node, row_item, mouse_over)
	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemCrimeNetSkirmishServer:fade_row_item(node, row_item, mouse_over)
	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemCrimeNetSkirmishServer:_set_row_item_state(node, row_item)
	if row_item.highlighted then
		-- Nothing
	end
end

function MenuItemCrimeNetSkirmishServer:menu_unselected_visible()
	return false
end

function MenuItemCrimeNetSkirmishServer:on_delete_row_item(row_item, ...)
	MenuItemCrimeNetSkirmishServer.super.on_delete_row_item(self, row_item, ...)
end
