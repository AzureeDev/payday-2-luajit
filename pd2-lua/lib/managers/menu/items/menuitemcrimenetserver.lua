core:import("CoreMenuItem")

MenuItemCrimeNetServer = MenuItemCrimeNetServer or class(CoreMenuItem.Item)
MenuItemCrimeNetServer.TYPE = "crimenet_server"

function MenuItemCrimeNetServer:init(data_node, parameters)
	MenuItemCrimeNetServer.super.init(self, data_node, parameters)

	self._type = MenuItemCrimeNetServer.TYPE
end

function MenuItemCrimeNetServer:setup_gui(node, row_item)
	local scaled_size = managers.gui_data:scaled_size()
	local color = Color.white
	local friend_color = tweak_data.screen_colors.friend_color
	local regular_color = tweak_data.screen_colors.regular_color
	local lobby = row_item.item:parameters().lobby
	local attributes_numbers = managers.network.matchmake:_lobby_to_numbers(lobby)
	local host_name = lobby:key_value("owner_name")
	local level_id = tweak_data.levels:get_level_name_from_index(attributes_numbers[1] % 1000)
	local name_id = level_id and tweak_data.levels[level_id] and tweak_data.levels[level_id].name_id
	local level_name = name_id and managers.localization:text(name_id) or "LEVEL NAME ERROR"
	local difficulty_id = attributes_numbers[2]
	local difficulty = tweak_data:index_to_difficulty(difficulty_id)
	local job_id = tweak_data.narrative:get_job_name_from_index(math.floor(attributes_numbers[1] / 1000))
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

	for i = 1, 4 do
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
	local job_tweak = tweak_data.narrative:job_data(job_id)
	local job_string = job_id and managers.localization:to_upper_text(job_tweak.name_id) or level_name or "NO JOB"
	local job_name = side_panel:text({
		name = "job_name",
		vertical = "center",
		blend_mode = "normal",
		layer = 0,
		text = job_string,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = mutators and tweak_data.screen_colors.mutators_color_text or color
	})
	local _, _, w, h = host_name:text_rect()

	host_name:set_size(w, h)
	host_name:set_position(0, 0)

	local _, _, w, h = job_name:text_rect()

	job_name:set_size(w, h)
	job_name:set_position(0, host_name:bottom() - 2)

	local difficulty_panel = server_panel:panel({
		x = 36,
		y = job_name:bottom() + 2
	})
	local desired_difficulty = difficulty_id - 2
	local start_difficulty = 1
	local num_difficulties = Global.SKIP_OVERKILL_290 and 5 or 6
	local x = 0
	local y = 0

	for i = start_difficulty, num_difficulties do
		local skull = difficulty_panel:bitmap({
			texture = "guis/textures/pd2/cn_miniskull",
			h = 16,
			layer = 0,
			w = 12,
			x = x,
			y = y,
			texture_rect = {
				0,
				0,
				12,
				16
			},
			alpha = desired_difficulty < i and 0.5 or 1,
			blend_mode = desired_difficulty < i and "normal" or "add",
			color = desired_difficulty < i and Color.black or tweak_data.screen_colors.risk
		})
		x = x + 11
	end

	row_item.gui_panel:set_left(node:_mid_align())
	row_item.gui_panel:set_w(scaled_size.width - row_item.gui_panel:left())
	row_item.gui_panel:set_h(server_panel:h() + 20)

	local max_w = math.max(host_name:right(), job_name:right(), x + 11) + 10

	server_panel:set_w(marker_dot:right() + max_w)
	side_panel:set_w(max_w)
	server_panel:set_x(row_item.gui_panel:w() * 0.5 - server_panel:w() * 0.5)
	server_panel:set_y(10)

	return true
end

function MenuItemCrimeNetServer:reload(row_item, node)
	MenuItemCrimeNetServer.super.reload(self, row_item, node)
	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemCrimeNetServer:highlight_row_item(node, row_item, mouse_over)
	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemCrimeNetServer:fade_row_item(node, row_item, mouse_over)
	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemCrimeNetServer:_set_row_item_state(node, row_item)
	if row_item.highlighted then
		-- Nothing
	end
end

function MenuItemCrimeNetServer:menu_unselected_visible()
	return false
end

function MenuItemCrimeNetServer:on_delete_row_item(row_item, ...)
	MenuItemCrimeNetServer.super.on_delete_row_item(self, row_item, ...)
end
