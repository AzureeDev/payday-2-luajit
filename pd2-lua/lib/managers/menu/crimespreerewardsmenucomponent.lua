CrimeSpreeRewardsMenuComponent = CrimeSpreeRewardsMenuComponent or class(MenuGuiComponentGeneric)
CrimeSpreeRewardsMenuComponent.menu_nodes = {
	start_menu = "crime_spree_lobby",
	mission_end_menu = "main"
}
local padding = 10
local card_size = 180

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function CrimeSpreeRewardsMenuComponent:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({})
	self._buttons = {}

	self:_setup()
end

function CrimeSpreeRewardsMenuComponent:close()
	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end

	if alive(self._text_header) then
		self._ws:panel():remove(self._text_header)
	end

	if alive(self._fullscreen_panel) then
		self._fullscreen_ws:panel():remove(self._fullscreen_panel)
	end

	managers.menu_component:post_event("count_1_finished")
end

function CrimeSpreeRewardsMenuComponent:_setup()
	self._exp_data = {
		total = managers.experience:total(),
		current_level = managers.experience:current_level(),
		reached_cap = managers.experience:reached_level_cap(),
		next_level_data = managers.experience:next_level_data()
	}

	print(inspect(self._exp_data))

	self._rewards_table = managers.crime_spree:calculate_rewards()

	managers.crime_spree:on_spree_complete()

	local parent = self._ws:panel()

	if alive(self._panel) then
		parent:remove(self._panel)
	end

	self._panel = self._ws:panel():panel({
		layer = 51
	})
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		layer = 50
	})

	self._fullscreen_panel:rect({
		alpha = 0.75,
		layer = 0,
		color = Color.black
	})

	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h()
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	blur:animate(func)
	self._panel:set_w(800)
	self._panel:set_h(500)
	self._panel:set_center_x(parent:center_x())
	self._panel:set_center_y(parent:center_y())
	self._panel:rect({
		alpha = 0.4,
		layer = -1,
		color = Color.black
	})

	self._text_header = self._ws:panel():text({
		vertical = "top",
		align = "left",
		layer = 51,
		text = managers.localization:to_upper_text("menu_cs_rewards"),
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local x, y, w, h = self._text_header:text_rect()

	self._text_header:set_size(self._panel:w(), h)
	self._text_header:set_left(self._panel:left())
	self._text_header:set_bottom(self._panel:top())
	BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local progress_bar_h = 24
	self._progress_panel = self._panel:panel({
		layer = 10,
		w = self._panel:w() * 0.8,
		h = progress_bar_h + tweak_data.menu.pd2_medium_font_size
	})

	self._progress_panel:set_center_x(self._panel:w() * 0.5)
	self._progress_panel:set_center_y(self._panel:h() * 0.5)
	self._progress_panel:text({
		vertical = "top",
		align = "left",
		text = managers.localization:to_upper_text("menu_cs_generating_rewards"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})

	self._progress_text = self._progress_panel:text({
		text = "",
		vertical = "top",
		align = "right",
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})
	local progress_bar_panel = self._progress_panel:panel({
		h = progress_bar_h
	})

	progress_bar_panel:set_bottom(self._progress_panel:h())
	BoxGuiObject:new(progress_bar_panel:panel({
		layer = 100
	}), {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._progress_bar = progress_bar_panel:rect({
		alpha = 0.8,
		blend_mode = "add",
		color = tweak_data.screen_colors.button_stage_2
	})
end

function CrimeSpreeRewardsMenuComponent:_setup_gui()
	self._progress_panel:animate(callback(self, self, "fade_out"), 0.5, 0)

	local panel_w = math.floor(self._panel:w() / 3)
	self._rewards_panel = self._panel:panel({})

	self:_create_experience_reward(1, panel_w)
	self:_create_cash_reward(2, panel_w)
	self:_create_coins_reward(3, panel_w)
end

function CrimeSpreeRewardsMenuComponent:mouse_wheel_up(x, y)
	if self._list_scroll then
		return self._list_scroll:scroll(x, y, 1)
	end
end

function CrimeSpreeRewardsMenuComponent:mouse_wheel_down(x, y)
	if self._list_scroll then
		return self._list_scroll:scroll(x, y, -1)
	end
end

function CrimeSpreeRewardsMenuComponent:confirm_pressed()
	if self._selected_item and self._selected_item:callback() then
		self._selected_item:callback()()
	end
end

function CrimeSpreeRewardsMenuComponent:mouse_moved(o, x, y)
	if not managers.menu:is_pc_controller() then
		return
	end

	local used, pointer = nil
	self._selected_item = nil

	for idx, btn in ipairs(self._buttons) do
		btn:set_selected(btn:inside(x, y))

		if btn:is_selected() then
			self._selected_item = btn
			pointer = "link"
			used = true
		end
	end

	return used, pointer
end

function CrimeSpreeRewardsMenuComponent:mouse_pressed(o, button, x, y)
	for idx, btn in ipairs(self._buttons) do
		if btn:is_selected() and btn:callback() then
			btn:callback()()

			return true
		end
	end
end

function CrimeSpreeRewardsMenuComponent:_close_rewards()
	managers.menu:close_menu("menu_main")
	managers.menu:open_menu("menu_main")
end

function CrimeSpreeRewardsMenuComponent:create_card(panel, icon, size)
	local rotation = math.rand(-10, 10)
	local texture, rect, coords = tweak_data.hud_icons:get_icon_data(icon or "downcard_overkill_deck")
	local upcard = panel:bitmap({
		name = "upcard",
		halign = "scale",
		valign = "scale",
		layer = 20,
		texture = texture,
		w = math.round(0.7111111111111111 * size),
		h = size
	})

	upcard:set_rotation(rotation)
	upcard:set_center_x(panel:w() * 0.5)
	upcard:set_y(panel:w() * 0.5 - upcard:w() * 0.5)
	upcard:hide()

	if coords then
		local tl = Vector3(coords[1][1], coords[1][2], 0)
		local tr = Vector3(coords[2][1], coords[2][2], 0)
		local bl = Vector3(coords[3][1], coords[3][2], 0)
		local br = Vector3(coords[4][1], coords[4][2], 0)

		upcard:set_texture_coordinates(tl, tr, bl, br)
	else
		upcard:set_texture_rect(unpack(rect))
	end

	return upcard
end

function CrimeSpreeRewardsMenuComponent:_create_experience_reward(idx, panel_w)
	self._exp_panel = self._rewards_panel:panel({
		x = panel_w * (idx - 1),
		w = panel_w
	})
	local card = self:create_card(self._exp_panel, tweak_data.crime_spree:get_reward_icon("experience"), card_size)
	local level_circle = self._exp_panel:bitmap({
		texture = "guis/textures/pd2/endscreen/exp_ring",
		name = "level_circle",
		render_template = "VertexColorTexturedRadial",
		alpha = 0,
		blend_mode = "add",
		rotation = 360,
		layer = 1,
		w = card:w(),
		h = card:w(),
		color = Color.white
	})

	level_circle:set_center_x(self._exp_panel:w() * 0.5)
	level_circle:set_top(card:bottom() + padding)
	level_circle:set_color(Color(0, 1, 1))

	local level_text = self._exp_panel:text({
		name = "level_text",
		vertical = "center",
		align = "center",
		alpha = 0,
		layer = 1,
		text = tostring(self._exp_data.current_level),
		w = card:w(),
		h = card:w(),
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})

	level_text:set_left(level_circle:left())
	level_text:set_top(level_circle:top())

	local experience_title = self._exp_panel:text({
		vertical = "center",
		name = "experience_title",
		alpha = 0,
		align = "center",
		layer = 1,
		text = managers.localization:to_upper_text("menu_experience"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	experience_title:set_center_x(self._exp_panel:w() * 0.5)
	experience_title:set_top(level_circle:bottom() + padding)

	local text = self._exp_data.reached_cap and managers.localization:to_upper_text("menu_reached_level_cap") or managers.experience:experience_string(self._exp_data.total - self:get_reward("experience"))
	local experience_text = self._exp_panel:text({
		vertical = "center",
		name = "experience_text",
		alpha = 0,
		align = "center",
		layer = 1,
		text = text,
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	experience_text:set_center_x(self._exp_panel:w() * 0.5)
	experience_text:set_top(experience_title:bottom())

	local experience_gained = self._exp_panel:text({
		vertical = "center",
		name = "experience_gained",
		alpha = 0,
		align = "center",
		layer = 1,
		text = "+" .. managers.experience:experience_string(self:get_reward("experience")),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	experience_gained:set_center_x(self._exp_panel:w() * 0.5)
	experience_gained:set_top(experience_text:bottom())
end

function CrimeSpreeRewardsMenuComponent:_create_cash_reward(idx, panel_w)
	self._cash_panel = self._rewards_panel:panel({
		x = panel_w * (idx - 1),
		w = panel_w
	})
	local card = self:create_card(self._cash_panel, tweak_data.crime_spree:get_reward_icon("cash"), card_size)
	local got_cash = self:get_reward("cash") * tweak_data:get_value("money_manager", "offshore_rate")
	local cash_title = self._cash_panel:text({
		vertical = "center",
		name = "cash_title",
		alpha = 0,
		align = "center",
		layer = 1,
		text = managers.localization:to_upper_text("menu_cash_spending"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	cash_title:set_center_x(self._cash_panel:w() * 0.5)
	cash_title:set_top(card:bottom() + padding)

	local cash_text = self._cash_panel:text({
		vertical = "center",
		name = "cash_text",
		alpha = 0,
		align = "center",
		layer = 1,
		text = managers.experience:cash_string(managers.money:total() - got_cash),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	cash_text:set_center_x(self._cash_panel:w() * 0.5)
	cash_text:set_top(cash_title:bottom())

	local cash_gained = self._cash_panel:text({
		vertical = "center",
		name = "cash_gained",
		alpha = 0,
		align = "center",
		layer = 1,
		text = "+" .. managers.experience:cash_string(got_cash),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	cash_gained:set_center_x(self._cash_panel:w() * 0.5)
	cash_gained:set_top(cash_text:bottom())

	local got_offshore = self:get_reward("cash") * (1 - tweak_data:get_value("money_manager", "offshore_rate"))
	local offshore_title = self._cash_panel:text({
		vertical = "center",
		name = "offshore_title",
		alpha = 0,
		align = "center",
		layer = 1,
		text = managers.localization:to_upper_text("menu_offshore_account"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	offshore_title:set_center_x(self._cash_panel:w() * 0.5)
	offshore_title:set_top(cash_gained:bottom() + padding)

	local offshore_text = self._cash_panel:text({
		vertical = "center",
		name = "offshore_text",
		alpha = 0,
		align = "center",
		layer = 1,
		text = managers.experience:cash_string(managers.money:offshore() - got_offshore),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	offshore_text:set_center_x(self._cash_panel:w() * 0.5)
	offshore_text:set_top(offshore_title:bottom())

	local offshore_gained = self._cash_panel:text({
		vertical = "center",
		name = "offshore_gained",
		alpha = 0,
		align = "center",
		layer = 1,
		text = "+" .. managers.experience:cash_string(got_offshore),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	offshore_gained:set_center_x(self._cash_panel:w() * 0.5)
	offshore_gained:set_top(offshore_text:bottom())
end

function CrimeSpreeRewardsMenuComponent:_create_coins_reward(idx, panel_w)
	self._coins_panel = self._rewards_panel:panel({
		x = panel_w * (idx - 1),
		w = panel_w
	})
	local card = self:create_card(self._coins_panel, tweak_data.crime_spree:get_reward_icon("continental_coins"), card_size)
	local coins_title = self._coins_panel:text({
		vertical = "center",
		name = "coins_title",
		alpha = 0,
		align = "center",
		layer = 1,
		text = managers.localization:to_upper_text("menu_cs_coins"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	coins_title:set_center_x(self._coins_panel:w() * 0.5)
	coins_title:set_top(card:bottom() + padding)

	local coins = 0
	coins = managers.custom_safehouse:coins()
	local coins_text = self._coins_panel:text({
		vertical = "center",
		name = "coins_text",
		alpha = 0,
		align = "center",
		layer = 1,
		text = managers.experience:cash_string(math.floor(coins - self:get_reward("continental_coins")), ""),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	coins_text:set_center_x(self._coins_panel:w() * 0.5)
	coins_text:set_top(coins_title:bottom())

	local coins_gained = self._coins_panel:text({
		vertical = "center",
		name = "coins_gained",
		alpha = 0,
		align = "center",
		layer = 1,
		text = "+" .. managers.experience:cash_string(math.floor(self:get_reward("continental_coins")), ""),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		h = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	coins_gained:set_center_x(self._coins_panel:w() * 0.5)
	coins_gained:set_top(coins_text:bottom())
end

function CrimeSpreeRewardsMenuComponent:get_reward(id)
	return (self._rewards_table or {})[id] or 0
end

function CrimeSpreeRewardsMenuComponent:_add_item_textures(lootdrop_data, panel)
	local item_id = lootdrop_data.item_entry
	local category = lootdrop_data.type_items

	if category == "weapon_mods" or category == "weapon_bonus" then
		category = "mods"
	end

	if category == "colors" then
		local colors = tweak_data.blackmarket.colors[item_id].colors
		local bg = panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg",
			layer = 1,
			w = panel:h(),
			h = panel:h()
		})
		local c1 = panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/icons/colors/color_01",
			layer = 0,
			w = panel:h(),
			h = panel:h()
		})
		local c2 = panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/icons/colors/color_02",
			layer = 0,
			w = panel:h(),
			h = panel:h()
		})

		c1:set_color(colors[1])
		c2:set_color(colors[2])
	else
		local texture_loaded_clbk = callback(self, self, "_texture_loaded_clbk", {
			panel = panel,
			is_pattern = category == "textures" and true or false
		})
		local texture_path = nil

		if category == "textures" then
			texture_path = tweak_data.blackmarket.textures[item_id].texture
		elseif category == "cash" then
			texture_path = "guis/textures/pd2/blackmarket/cash_drop"
		elseif category == "xp" then
			texture_path = "guis/textures/pd2/blackmarket/xp_drop"
		elseif category == "safes" then
			local td = tweak_data.economy[category] and tweak_data.economy[category][item_id]

			if td then
				local guis_catalog = "guis/"
				local bundle_folder = td.texture_bundle_folder

				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				local path = category .. "/"
				texture_path = guis_catalog .. path .. item_id
			else
				texture_path = "guis/dlcs/cash/safes/default/safes/default_01"
			end
		elseif category == "drills" then
			local td = tweak_data.economy[category] and tweak_data.economy[category][item_id]

			if td then
				local guis_catalog = "guis/"
				local bundle_folder = td.texture_bundle_folder

				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				local path = category .. "/"
				texture_path = guis_catalog .. path .. item_id
			else
				texture_path = "guis/dlcs/cash/safes/default/drills/default_01"
			end
		else
			local guis_catalog = "guis/"
			local tweak_data_category = category == "mods" and "weapon_mods" or category
			local guis_id = item_id

			if tweak_data.blackmarket[tweak_data_category] and tweak_data.blackmarket[tweak_data_category][item_id] and tweak_data.blackmarket[tweak_data_category][item_id].guis_id then
				guis_id = tweak_data.blackmarket[tweak_data_category][item_id].guis_id
			end

			local bundle_folder = tweak_data.blackmarket[tweak_data_category] and tweak_data.blackmarket[tweak_data_category][guis_id] and tweak_data.blackmarket[tweak_data_category][guis_id].texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			texture_path = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(category) .. "/" .. tostring(guis_id)
		end

		Application:debug("Requesting Texture", texture_path)

		if DB:has(Idstring("texture"), texture_path) then
			TextureCache:request(texture_path, "NORMAL", texture_loaded_clbk, 100)
		else
			Application:error("[HUDLootScreen]", "Texture not in DB", texture_path)
			panel:rect({
				color = Color.red
			})
		end
	end
end

function CrimeSpreeRewardsMenuComponent:_texture_loaded_clbk(params, texture_idstring)
	if not alive(self._loot_panel) then
		TextureCache:unretrieve(texture_idstring)

		return
	end

	local is_pattern = params.is_pattern
	local panel = params.panel
	local item = panel:bitmap({
		blend_mode = "normal",
		texture = texture_idstring
	})

	TextureCache:unretrieve(texture_idstring)

	if is_pattern then
		local texture, rect, coords = tweak_data.hud_icons:get_icon_data("upcard_pattern")

		item:set_image(texture)
		item:set_texture_rect(unpack(rect))
		item:set_w(math.round(0.7111111111111111 * panel:h()))
		item:set_h(panel:h())
	end

	local texture_width = item:texture_width()
	local texture_height = item:texture_height()
	local panel_width = panel:w()
	local panel_height = panel:h()

	if texture_width == 0 or texture_height == 0 or panel_width == 0 or panel_height == 0 then
		Application:error("HUDLootScreen:texture_loaded_clbk():", texture_idstring)
		Application:debug("HUDLootScreen:", "texture_width " .. texture_width, "texture_height " .. texture_height, "panel_width " .. panel_width, "panel_height " .. panel_height)
		panel:remove(item)

		local rect = panel:rect({
			blend_mode = "add",
			rotation = 360,
			color = Color.red
		})

		rect:set_center(panel:w() * 0.5, panel:h() * 0.5)

		return
	end

	local s = math.min(texture_width, texture_height)
	local dw = texture_width / s
	local dh = texture_height / s

	if not is_pattern then
		local _dw = dw / math.max(dw, dh)
		local _dh = dh / math.max(dw, dh)

		item:set_size(math.round(_dw * panel_width), math.round(_dh * panel_height))
	end

	item:set_rotation(360)
	item:set_center(panel:w() * 0.5, panel:h() * 0.5)
end

CrimeSpreeRewardsMenuComponent.states = {
	{
		"_start_animation",
		0
	},
	{
		"_update_experience",
		0.5
	},
	{
		"_update_cash",
		0.5
	},
	{
		"_update_coins",
		0.5
	},
	{
		"_fade_out_exp_panels",
		0.5
	},
	{
		"_update_cosmetic_drops",
		0.5
	},
	{
		"_cleanup_cosmetic_drops",
		0
	},
	{
		"_update_loot_drops",
		0.5
	},
	{
		"_cleanup_loot_drops",
		0
	},
	{
		"_update_rewards_list",
		0.5
	}
}

function CrimeSpreeRewardsMenuComponent:update(t, dt)
	if managers.crime_spree:is_generating_rewards() then
		local current, total = managers.crime_spree:reward_generation_progress()
		local complete = managers.crime_spree:has_finished_generating_rewards()

		if alive(self._progress_text) then
			self._progress_text:set_text(string.format("%i/%i", complete and total or current, total))

			if alive(self._progress_bar) then
				self._progress_bar:set_w(self._progress_panel:w() * (complete and 1 or current / total))
			end
		end

		if complete then
			self:_setup_gui()
		end

		return
	end

	if self._wait_t then
		self._wait_t = self._wait_t - dt

		if self._wait_t < 0 then
			self._wait_t = nil
		end

		return
	end

	if not self._current_state then
		self:next_state()

		return
	end

	local cx, cy = managers.menu_component:get_right_controller_axis()

	if cy ~= 0 and self._list_scroll then
		self._list_scroll:perform_scroll(math.abs(cy * 500 * dt), math.sign(cy))
	end

	if not CrimeSpreeRewardsMenuComponent.states[self._current_state] then
		return
	end

	local func = CrimeSpreeRewardsMenuComponent.states[self._current_state][1]

	if self[func] then
		self[func](self, t, dt)
	end

	for idx, btn in ipairs(self._buttons) do
		btn:update(t, dt)
	end
end

function CrimeSpreeRewardsMenuComponent:next_state(wait_t)
	self._current_state = (self._current_state or 0) + 1
	local t = CrimeSpreeRewardsMenuComponent.states[self._current_state] and CrimeSpreeRewardsMenuComponent.states[self._current_state][2] or 0

	if t > 0 or wait_t then
		self:wait(wait_t or t)
	end
end

function CrimeSpreeRewardsMenuComponent:wait(t)
	self._wait_t = t
end

function CrimeSpreeRewardsMenuComponent:set_text(element, text, delay)
	if delay then
		wait(delay)
	end

	element:set_text(text)
end

function CrimeSpreeRewardsMenuComponent:flip_card(card)
	local start_rot = card:rotation()
	local start_w = card:w()
	local cx, cy = card:center()
	local start_rotation = card:rotation()
	local end_rotation = start_rotation * -1
	local diff = end_rotation - start_rotation

	card:set_valign("scale")
	card:set_halign("scale")
	card:show()
	managers.menu_component:post_event("loot_flip_card")
	over(0.25, function (p)
		card:set_rotation(start_rotation + math.sin(p * 45 + 45) * diff)

		if card:rotation() == 0 then
			card:set_rotation(360)
		end

		card:set_w(start_w * math.sin(p * 90))
		card:set_center(cx, cy)
	end)
end

function CrimeSpreeRewardsMenuComponent:flip_item_card(card, item_type, delay)
	local start_rot = card:rotation()
	local start_w = card:w()
	local cx, cy = card:center()
	local start_rotation = card:rotation()
	local end_rotation = start_rotation * -1
	local diff = end_rotation - start_rotation

	card:set_valign("scale")
	card:set_halign("scale")
	card:show()

	if delay then
		wait(delay)
	end

	managers.menu_component:post_event("loot_flip_card")
	over(0.25, function (p)
		card:set_rotation(start_rotation + math.sin(p * 45) * diff)

		if card:rotation() == 0 then
			card:set_rotation(360)
		end

		card:set_w(start_w * math.cos(p * 90))
		card:set_center(cx, cy)
	end)

	local texture, rect, coords = tweak_data.hud_icons:get_icon_data(item_type or "downcard_overkill_deck")

	card:set_image(texture)
	card:set_texture_rect(unpack(rect))
	over(0.25, function (p)
		card:set_rotation(start_rotation + math.sin(p * 45 + 45) * diff)

		if card:rotation() == 0 then
			card:set_rotation(360)
		end

		card:set_w(start_w * math.sin(p * 90))
		card:set_center(cx, cy)
	end)
end

function CrimeSpreeRewardsMenuComponent:fade_in(element, duration, delay)
	if delay then
		wait(delay)
	end

	over(duration, function (p)
		element:set_alpha(math.lerp(0, 1, p))
	end)
end

function CrimeSpreeRewardsMenuComponent:fade_out(element, duration, delay)
	if delay then
		wait(delay)
	end

	over(duration, function (p)
		element:set_alpha(math.lerp(1, 0, p))
	end)
end

function CrimeSpreeRewardsMenuComponent:count_text(element, cash_string, start_val, end_val, duration, delay)
	if delay then
		wait(delay)
	end

	local v = start_val

	managers.menu_component:post_event("count_1")
	over(duration, function (p)
		v = math.lerp(start_val, end_val, p)

		element:set_text(managers.experience:cash_string(v, cash_string))
	end)
	managers.menu_component:post_event("count_1_finished")
end

function CrimeSpreeRewardsMenuComponent:fill_circle(element, start, target, duration, delay)
	if delay then
		wait(delay)
	end

	over(duration, function (p)
		local v = math.lerp(start, target, p)

		element:set_color(Color(v, 1, 1))
	end)
end

function CrimeSpreeRewardsMenuComponent:post_event(element, event, delay)
	if delay then
		wait(delay)
	end

	managers.menu:post_event(event)
end

function CrimeSpreeRewardsMenuComponent:_start_animation(t, dt)
	self:next_state()
end

function CrimeSpreeRewardsMenuComponent:_update_experience()
	local t = 0

	local function wait(x)
		t = t + x
	end

	local fade_in_t = 0.2
	local count_t = 1.5
	local panel = self._exp_panel
	local card = panel:child("upcard")
	local experience_text = panel:child("experience_text")
	local experience_title = panel:child("experience_title")
	local experience_gained = panel:child("experience_gained")
	local level_circle = panel:child("level_circle")
	local level_text = panel:child("level_text")

	card:animate(callback(self, self, "flip_card"))

	t = t + 0.25

	level_circle:animate(callback(self, self, "fade_in"), fade_in_t, t)
	level_text:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 0.25

	experience_title:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 0.25

	experience_text:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 0.5

	experience_gained:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 1
	local fill_percent = managers.experience:next_level_data().current_points / managers.experience:next_level_data().points
	local start_exp = self._exp_data.total
	local current_exp = self._exp_data.total + self:get_reward("experience")

	experience_gained:animate(callback(self, self, "count_text"), "+", self:get_reward("experience"), 0, count_t, t)

	if not self._exp_data.reached_cap then
		experience_text:animate(callback(self, self, "count_text"), "", start_exp, current_exp, count_t, t)
		level_text:animate(callback(self, self, "count_text"), "", self._exp_data.current_level, managers.experience:current_level(), count_t, t)
		level_circle:animate(callback(self, self, "fill_circle"), 0, fill_percent, count_t, t)
	else
		level_circle:animate(callback(self, self, "fill_circle"), 0, 1, count_t, t)
	end

	t = t + count_t + 0.25

	experience_gained:animate(callback(self, self, "fade_out"), fade_in_t, t)

	t = t + 0.5

	self:next_state(t - 0.5)
end

function CrimeSpreeRewardsMenuComponent:_update_cash(t, dt)
	local t = 0

	local function wait(x)
		t = t + x
	end

	local fade_in_t = 0.2
	local count_t = 1.5
	local panel = self._cash_panel
	local card = panel:child("upcard")
	local cash_title = panel:child("cash_title")
	local cash_text = panel:child("cash_text")
	local cash_gained = panel:child("cash_gained")
	local offshore_title = panel:child("offshore_title")
	local offshore_text = panel:child("offshore_text")
	local offshore_gained = panel:child("offshore_gained")

	card:animate(callback(self, self, "flip_card"))

	t = t + 0.25

	cash_title:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 0.25

	cash_text:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 0.5

	cash_gained:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 1
	local got_cash = self:get_reward("cash") * tweak_data:get_value("money_manager", "offshore_rate")
	local start_cash = managers.money:total() - got_cash
	local current_cash = managers.money:total()

	cash_gained:animate(callback(self, self, "count_text"), "+$", got_cash, 0, count_t, t)
	cash_text:animate(callback(self, self, "count_text"), nil, start_cash, current_cash, count_t, t)

	t = t + count_t + 0.5

	cash_gained:animate(callback(self, self, "fade_out"), fade_in_t, t)

	t = t + 0.25

	offshore_title:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 0.25

	offshore_text:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 0.5

	offshore_gained:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 1
	local got_offshore = self:get_reward("cash") * (1 - tweak_data:get_value("money_manager", "offshore_rate"))
	local start_offshore = managers.money:offshore() - got_offshore
	local current_offshore = managers.money:offshore()

	offshore_gained:animate(callback(self, self, "count_text"), "+$", got_offshore, 0, count_t, t)
	offshore_text:animate(callback(self, self, "count_text"), nil, start_offshore, current_offshore, count_t, t)

	t = t + count_t + 0.5

	offshore_gained:animate(callback(self, self, "fade_out"), fade_in_t, t)

	t = t + 0.25

	self:next_state(t - 0.5)
end

function CrimeSpreeRewardsMenuComponent:_update_coins(t, dt)
	local t = 0

	local function wait(x)
		t = t + x
	end

	local fade_in_t = 0.2
	local count_t = 1.5
	local panel = self._coins_panel
	local card = panel:child("upcard")
	local coins_title = panel:child("coins_title")
	local coins_text = panel:child("coins_text")
	local coins_gained = panel:child("coins_gained")

	card:animate(callback(self, self, "flip_card"))

	t = t + 0.25

	coins_title:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 0.25

	coins_text:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 0.5

	coins_gained:animate(callback(self, self, "fade_in"), fade_in_t, t)

	t = t + 1
	local start_coins = 0
	local current_coins = 0
	start_coins = math.floor(managers.custom_safehouse:coins() - self:get_reward("continental_coins"))
	current_coins = math.floor(managers.custom_safehouse:coins())

	coins_gained:animate(callback(self, self, "count_text"), "+", self:get_reward("continental_coins"), 0, count_t, t)
	coins_text:animate(callback(self, self, "count_text"), "", start_coins, current_coins, count_t, t)

	t = t + count_t + 0.25

	coins_gained:animate(callback(self, self, "fade_out"), fade_in_t, t)

	t = t + 0.5

	self:next_state(t - 0.5)
end

function CrimeSpreeRewardsMenuComponent:_fade_out_exp_panels()
	local t = 0
	local fade_t = 0.5

	self._exp_panel:animate(callback(self, self, "fade_out"), fade_t, t)
	self._cash_panel:animate(callback(self, self, "fade_out"), fade_t, t)
	self._coins_panel:animate(callback(self, self, "fade_out"), fade_t, t)

	t = t + fade_t

	self:next_state(t)
end

function CrimeSpreeRewardsMenuComponent:_update_cosmetic_drops()
	self._cosmetics_panel = self._panel:panel({
		x = padding,
		y = padding,
		w = self._panel:w() - padding * 2,
		h = self._panel:h() - padding * 2
	})
	local cosmetic_rewards = managers.crime_spree:cosmetic_rewards()

	table.sort(cosmetic_rewards, function (a, b)
		return a.type < b.type
	end)

	local t = 0
	local card_types = {
		continental_coins = "upcard_coins",
		armor = "upcard_cosmetic"
	}

	for i, reward in ipairs(cosmetic_rewards) do
		local card_panel = self._cosmetics_panel:panel({
			w = self._cosmetics_panel:w() * 0.5,
			h = self._cosmetics_panel:h() * 0.5
		})

		card_panel:set_center_x(self._cosmetics_panel:w() * 0.5)
		card_panel:set_center_y(self._cosmetics_panel:h() * 0.4)

		local icon_panel = card_panel:panel({
			alpha = 0
		})
		local name_panel = self._cosmetics_panel:panel({
			alpha = 0,
			h = 128,
			w = self._cosmetics_panel:w()
		})

		name_panel:set_top(card_panel:bottom())

		local card = self:create_card(card_panel, "downcard_overkill_deck", card_panel:h() * 0.9)

		card:set_center_x(card_panel:w() * 0.5)
		card:set_center_y(card_panel:h() * 0.5)
		card:set_alpha(0)

		local texture, bg_texure, item_name, rarity_name = nil
		local rarity_color = tweak_data.screen_colors.text

		if reward.type == "armor" then
			local td = tweak_data.economy.armor_skins[reward.id]
			local guis_catalog = "guis/"
			local bundle_folder = td.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			item_name = managers.localization:to_upper_text(td.name_id)
			texture = guis_catalog .. "armor_skins/" .. reward.id
			bg_texure = managers.blackmarket:get_cosmetic_rarity_bg(td.rarity or "common")
			local rtd = tweak_data.economy.rarities[td.rarity]
			rarity_name = managers.localization:to_upper_text(rtd.name_id)
			rarity_color = rtd.color or tweak_data.screen_colors.text
		elseif reward.type == "continental_coins" then
			texture = "guis/dlcs/chill/textures/pd2/safehouse/continental_coins_drop"
			item_name = managers.experience:cash_string(reward.amount, "") .. " " .. managers.localization:to_upper_text("menu_cs_coins")
			rarity_name = managers.localization:to_upper_text("menu_cs_all_cosmetics_obtained")
		end

		if texture then
			local cosmetic_icon = icon_panel:bitmap({
				blend_mode = "normal",
				stream = true,
				layer = 2,
				texture = texture
			})

			cosmetic_icon:set_center_x(icon_panel:w() * 0.5)
			cosmetic_icon:set_center_y(icon_panel:h() * 0.5)
		end

		if bg_texure then
			local rarity_icon = icon_panel:bitmap({
				blend_mode = "normal",
				stream = true,
				layer = 1,
				texture = bg_texure
			})

			rarity_icon:set_center_x(icon_panel:w() * 0.5)
			rarity_icon:set_center_y(icon_panel:h() * 0.5)
		end

		local font = tweak_data.menu.pd2_large_font
		local font_size = tweak_data.menu.pd2_large_font_size * 0.75
		local name = name_panel:text({
			vertical = "center",
			align = "center",
			layer = 1,
			text = item_name or "missing name",
			h = font_size,
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})

		if rarity_name then
			local rarity = name_panel:text({
				vertical = "center",
				align = "center",
				layer = 1,
				text = rarity_name,
				h = font_size,
				font_size = font_size,
				font = font,
				color = rarity_color
			})

			name:set_top(rarity:bottom())
		end

		t = t + 1

		card:animate(callback(self, self, "fade_in"), 0.25, t)

		t = t + 1

		card:animate(callback(self, self, "flip_item_card"), card_types[reward.type] or "upcard_cosmetic", t)

		t = t + 1.5

		card:animate(callback(self, self, "fade_out"), 0.5, t)
		icon_panel:animate(callback(self, self, "fade_in"), 0.5, t)

		t = t + 0.2

		name_panel:animate(callback(self, self, "fade_in"), 0.5, t)
		icon_panel:animate(callback(self, self, "post_event"), "stinger_levelup", t)

		t = t + 3

		icon_panel:animate(callback(self, self, "fade_out"), 0.5, t)
		name_panel:animate(callback(self, self, "fade_out"), 0.5, t)

		t = t + 0.5
	end

	self:next_state(t + 1)
end

function CrimeSpreeRewardsMenuComponent:_cleanup_cosmetic_drops()
	if alive(self._cosmetics_panel) then
		self._panel:remove(self._cosmetics_panel)
	end

	self:next_state(0)
end

function CrimeSpreeRewardsMenuComponent:_update_loot_drops()
	local loot_drops = managers.crime_spree:loot_drops()

	if #loot_drops < 1 then
		self:next_state(0)

		return
	end

	self._loot_panel = self._panel:panel({
		x = padding,
		y = padding,
		w = self._panel:w() - padding * 2,
		h = self._panel:h() - padding * 2
	})
	local loot_params = {
		loot = managers.experience:cash_string(#loot_drops, "")
	}
	local drops_remaining = self._loot_panel:text({
		vertical = "bottom",
		name = "drops_remaining",
		align = "left",
		layer = 1,
		text = managers.localization:to_upper_text("menu_cs_loot_drops_remaining", loot_params),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(drops_remaining)
	drops_remaining:set_left(self._loot_panel:left())
	drops_remaining:set_bottom(self._loot_panel:bottom() - padding)

	self._loot_scroll = ScrollablePanel:new(self._loot_panel, "loot_scroll", {
		padding = 0
	})
	local num_items = #loot_drops
	local items_per_line = 6
	local max_lines = 3
	local max_items = items_per_line * max_lines
	local item_size = self._loot_scroll:canvas():w() / items_per_line
	local max_pages = 3
	local c = 0
	local intial_delay = 0
	local end_t = 0

	for i = 1, math.min(num_items, max_items * max_pages), 1 do
		local lootdrop_data = loot_drops[i]
		local card_types = {
			weapon_mods = "upcard_weapon",
			xp = "upcard_xp",
			materials = "upcard_material",
			safes = "upcard_safe",
			cash = "upcard_cash",
			masks = "upcard_mask",
			colors = "upcard_color",
			textures = "upcard_pattern",
			drills = "upcard_drill",
			weapon_bonus = "upcard_weapon_bonus"
		}
		local panel = self._loot_scroll:canvas():panel({
			x = item_size * (c % items_per_line),
			y = item_size * math.floor(c / items_per_line),
			w = item_size,
			h = item_size
		})
		local card = self:create_card(panel, "downcard_overkill_deck", item_size * 0.8)

		card:set_center_x(panel:w() * 0.5)
		card:set_center_y(panel:h() * 0.5)
		card:set_alpha(0)

		local size = 0.75
		local item_panel = panel:panel({
			alpha = 0,
			x = panel:w() * (1 - size) * 0.5,
			y = panel:h() * (1 - size) * 0.5,
			w = panel:w() * size,
			h = panel:h() * size,
			color = Color(math.random(), math.random(), math.random())
		})

		self:_add_item_textures(lootdrop_data, item_panel)

		local t = 0
		t = t + 1 + intial_delay

		card:animate(callback(self, self, "fade_in"), 0.25, t)

		t = t + 0.5 + c * 0.2

		card:animate(callback(self, self, "flip_item_card"), card_types[lootdrop_data.type_items], t)

		loot_params.loot = managers.experience:cash_string(num_items - i, "")
		local new_text = managers.localization:to_upper_text("menu_cs_loot_drops_remaining", loot_params)

		drops_remaining:animate(callback(self, self, "set_text"), new_text, t)

		t = t + 1

		item_panel:animate(callback(self, self, "fade_in"), 0.25, t)
		card:animate(callback(self, self, "fade_out"), 0.25, t)

		t = t + 2 + max_items * 0.5 * 0.2

		item_panel:animate(callback(self, self, "fade_out"), 0.25, t)

		c = c + 1

		if max_items <= c then
			c = 0
			intial_delay = t
		end

		end_t = t
	end

	if num_items > max_items * max_pages then
		local more_text = self._loot_scroll:canvas():text({
			vertical = "center",
			align = "center",
			alpha = 0,
			text = managers.localization:text("menu_cs_loot_drops_not_shown", {
				remaining = tostring(num_items - max_items * max_pages)
			}),
			font_size = tweak_data.menu.pd2_large_font_size,
			font = tweak_data.menu.pd2_large_font,
			color = tweak_data.screen_colors.text
		})
		local t = end_t

		more_text:animate(callback(self, self, "fade_in"), 0.25, t)
		more_text:animate(callback(self, self, "fade_out"), 0.25, t + 2)

		end_t = end_t + 2.5
	end

	self._loot_scroll:update_canvas_size()
	self:next_state(end_t)
end

function CrimeSpreeRewardsMenuComponent:_cleanup_loot_drops()
	if alive(self._loot_panel) then
		self._panel:remove(self._loot_panel)
	end

	self:next_state(0)
end

function CrimeSpreeRewardsMenuComponent:_update_rewards_list()
	self._list_panel = self._panel:panel({
		x = padding,
		y = padding,
		w = self._panel:w() - padding * 2,
		h = self._panel:h() - padding * 2 - tweak_data.menu.pd2_large_font_size
	})
	self._list_scroll = ScrollablePanel:new(self._list_panel, "loot_scroll", {
		force_scroll_indicators = true,
		padding = 0
	})
	local count = 0
	local fade_in_t = 0.25
	local fade_in_delay = fade_in_t / 4
	local size = tweak_data.menu.pd2_small_font_size

	local function add_reward_text(text, color)
		local reward_text = self._list_scroll:canvas():text({
			alpha = 0,
			vertical = "bottom",
			align = "left",
			layer = 1,
			text = text,
			x = padding,
			y = padding + (size + 2) * count,
			h = size,
			font_size = size,
			font = tweak_data.menu.pd2_small_font,
			color = color or tweak_data.screen_colors.text
		})

		reward_text:animate(callback(self, self, "fade_in"), fade_in_t, count * fade_in_delay)

		count = count + 1
	end

	add_reward_text(managers.localization:to_upper_text("menu_experience") .. " " .. managers.experience:cash_string(self:get_reward("experience"), ""))

	local spending = self:get_reward("cash") * tweak_data:get_value("money_manager", "offshore_rate")
	local offshore = self:get_reward("cash") * (1 - tweak_data:get_value("money_manager", "offshore_rate"))

	add_reward_text(managers.localization:to_upper_text("menu_cash_spending") .. ": " .. managers.experience:cash_string(spending))
	add_reward_text(managers.localization:to_upper_text("menu_offshore_account") .. ": " .. managers.experience:cash_string(offshore))

	if self:get_reward("continental_coins") > 0 then
		add_reward_text(managers.localization:to_upper_text("menu_cs_coins") .. ": " .. managers.experience:cash_string(self:get_reward("continental_coins"), ""))
	end

	add_reward_text("")

	local cosmetic_rewards = managers.crime_spree:cosmetic_rewards()

	for i, reward in ipairs(cosmetic_rewards) do
		if reward.type == "armor" then
			local td = tweak_data.economy.armor_skins[reward.id]
			local name = managers.localization:text(td.name_id)
			local col = tweak_data.economy.rarities[td.rarity].color or tweak_data.screen_colors.text

			add_reward_text(managers.localization:text("menu_cs_reward_armor_skin", {
				skin = name
			}), col)
		elseif reward.type == "continental_coins" then
			add_reward_text(managers.experience:cash_string(reward.amount, "") .. " " .. managers.localization:to_upper_text("menu_cs_coins"))
		end
	end

	if #cosmetic_rewards > 0 then
		add_reward_text("")
	end

	local loot_drops = managers.crime_spree:loot_drops()

	for _, lootdrop_data in ipairs(loot_drops) do
		local td, text, color = nil
		local item_id = lootdrop_data.item_entry
		local category = lootdrop_data.type_items

		if category == "weapon_mods" or category == "weapon_bonus" then
			category = "mods"
		end

		if category == "colors" then
			td = tweak_data.blackmarket.colors[item_id]
		elseif category == "textures" then
			td = tweak_data.blackmarket.textures[item_id]
		elseif category == "cash" then
			text = false
			td = tweak_data.blackmarket.cash[item_id]
		elseif category == "xp" then
			text = false
			td = tweak_data.blackmarket.xp[item_id]
		elseif category == "safes" then
			td = tweak_data.economy[category] and tweak_data.economy[category][item_id]
		elseif category == "drills" then
			td = tweak_data.economy[category] and tweak_data.economy[category][item_id]
		else
			local tweak_data_category = category == "mods" and "weapon_mods" or category
			td = tweak_data.blackmarket[tweak_data_category][item_id]
		end

		if text == nil then
			if td.name_id then
				local gv = lootdrop_data.global_value
				text = managers.localization:text("bm_menu_" .. tostring(category)) .. ": " .. managers.localization:text(td.name_id)
				color = tweak_data.lootdrop.global_values[gv] and tweak_data.lootdrop.global_values[gv].color or tweak_data.screen_colors.text
			else
				text = tostring(item_id) .. " - " .. tostring(category)
			end
		end

		if text then
			add_reward_text(text, color)
		end
	end

	self._list_scroll:update_canvas_size()

	self._button_panel = self._panel:panel({
		alpha = 0,
		y = self._panel:h() - tweak_data.menu.pd2_large_font_size,
		h = tweak_data.menu.pd2_large_font_size - padding
	})

	self._button_panel:animate(callback(self, self, "fade_in"), 0, 1)

	local btn = CrimeSpreeButton:new(self._button_panel)

	btn:set_text(managers.localization:to_upper_text("dialog_ok"))
	btn:set_callback(callback(self, self, "_close_rewards"))
	btn:set_selected(true)

	self._selected_item = btn

	table.insert(self._buttons, btn)
	self:next_state(0)
end
