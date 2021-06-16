PlayerProfileGuiObject = PlayerProfileGuiObject or class()

function PlayerProfileGuiObject:init(ws)
	local panel = ws:panel():panel()
	local COLOR_TRANSPARENT = Color(180, 255, 255, 255) / 255
	local next_level_data = managers.experience:next_level_data() or {}
	local max_left_len = 0
	local max_right_len = 0
	local font = tweak_data.menu.pd2_small_font
	local font_size = tweak_data.menu.pd2_small_font_size
	local bg_ring = panel:bitmap({
		texture = "guis/textures/pd2/level_ring_small",
		y = 25,
		alpha = 0.4,
		x = 10,
		w = (font_size + 1) * 4,
		h = (font_size + 1) * 4,
		color = Color.black
	})
	local exp_ring = panel:bitmap({
		texture = "guis/textures/pd2/level_ring_small",
		render_template = "VertexColorTexturedRadial",
		blend_mode = "add",
		y = 25,
		x = 10,
		layer = 1,
		w = (font_size + 1) * 4,
		h = (font_size + 1) * 4,
		color = Color((next_level_data.current_points or 1) / (next_level_data.points or 1), 1, 1)
	})
	local player_text = panel:text({
		y = 10,
		font = font,
		font_size = font_size,
		text = tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name()),
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(player_text)
	player_text:set_top(panel:top())

	local player_level = managers.experience:current_level()
	local player_rank = managers.experience:current_rank()
	local is_infamous = player_rank > 0
	local player_level_panel = panel:panel({})
	local level_string = tostring(player_level)

	if is_infamous then
		local max_w = 0
		local rank_string = managers.experience:rank_string(player_rank)
		local use_linebreak = true
		local rank_text, level_text = nil

		if use_linebreak then
			rank_text = player_level_panel:text({
				vertical = "top",
				align = "center",
				rotation = 360,
				layer = 1,
				font = tweak_data.menu.pd2_medium_font,
				font_size = tweak_data.menu.pd2_medium_font_size - 5,
				text = "[" .. rank_string .. "]",
				color = tweak_data.screen_colors.infamy_color
			})
			level_text = player_level_panel:text({
				vertical = "top",
				align = "center",
				rotation = 360,
				layer = 1,
				font = tweak_data.menu.pd2_medium_font,
				font_size = tweak_data.menu.pd2_medium_font_size - 5,
				text = level_string,
				color = tweak_data.screen_colors.text
			})

			self:_make_fine_text(rank_text)
			self:_make_fine_text(level_text)

			max_w = math.max(max_w, rank_text:w(), level_text:w())
		else
			local text_string, name_color_ranges = managers.experience:gui_string(player_level, player_rank)
			level_text = player_level_panel:text({
				vertical = "top",
				align = "center",
				rotation = 360,
				layer = 1,
				font = tweak_data.menu.pd2_medium_font,
				font_size = tweak_data.menu.pd2_medium_font_size - 5,
				text = text_string,
				color = tweak_data.screen_colors.text
			})

			for _, color_range in ipairs(name_color_ranges) do
				level_text:set_range_color(color_range.start, color_range.stop, color_range.color)
			end

			self:_make_fine_text(level_text)

			max_w = math.max(max_w, level_text:w())
		end

		local scale = math.min(font_size * 2 / max_w, 1)
		local height_reduction = 4 * scale

		level_text:set_w(max_w)
		level_text:set_font_size(level_text:font_size() * scale)

		local x, y, w, h = level_text:text_rect()

		level_text:set_h(math.ceil(h - height_reduction))

		if rank_text then
			rank_text:set_w(max_w)
			rank_text:set_font_size(rank_text:font_size() * scale)

			local x, y, w, h = rank_text:text_rect()

			rank_text:set_h(math.ceil(h - height_reduction))
			rank_text:set_y(level_text:bottom())
		end

		player_level_panel:set_w(max_w)

		local panel_h = (rank_text or level_text):bottom() + 2

		player_level_panel:set_h(panel_h)
		player_level_panel:set_center(exp_ring:center())
	else
		local level_text = player_level_panel:text({
			vertical = "center",
			align = "center",
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			text = level_string,
			color = tweak_data.screen_colors.text
		})

		self:_make_fine_text(level_text)
		level_text:set_font_size(level_text:font_size() * math.min(font_size * 2 / level_text:w(), 1))
		player_level_panel:set_size(level_text:size())
	end

	local text_offset = 10
	local money_text = panel:text({
		text = self:get_text("menu_cash", {
			money = managers.money:total_string()
		}),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(money_text)
	managers.menu_component:make_color_text(money_text, COLOR_TRANSPARENT)
	money_text:set_left(math.round(exp_ring:right() + text_offset))
	money_text:set_top(math.round(exp_ring:top()))

	max_left_len = math.max(max_left_len, money_text:w())
	local total_money_text = panel:text({
		text = "##" .. self:get_text("hud_offshore_account") .. "##: " .. managers.experience:cash_string(managers.money:offshore()),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(total_money_text)
	managers.menu_component:make_color_text(total_money_text, COLOR_TRANSPARENT)
	total_money_text:set_left(math.round(exp_ring:right() + text_offset))
	total_money_text:set_top(math.round(money_text:bottom()))

	max_left_len = math.max(max_left_len, total_money_text:w())
	local skillpoint_top = math.round(total_money_text:bottom())
	local unlocked = false
	local coins = 0
	unlocked = managers.custom_safehouse:unlocked()
	coins = managers.custom_safehouse:coins()

	if unlocked then
		local coin_text = panel:text({
			text = "##" .. self:get_text("menu_es_coins_progress") .. "##: " .. managers.experience:cash_string(math.floor(coins), ""),
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})

		self:_make_fine_text(coin_text)
		managers.menu_component:make_color_text(coin_text, COLOR_TRANSPARENT)
		coin_text:set_left(math.round(exp_ring:right() + text_offset))
		coin_text:set_top(skillpoint_top)

		max_left_len = math.max(max_left_len, coin_text:w())
		skillpoint_top = math.round(coin_text:bottom())
	end

	local skillpoints = managers.skilltree:points()
	local skill_text, skill_glow = nil

	if skillpoints > 0 then
		skill_text = panel:text({
			layer = 1,
			text = self:get_text("menu_spendable_skill_points", {
				points = tostring(skillpoints)
			}),
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})

		self:_make_fine_text(skill_text)
		managers.menu_component:make_color_text(skill_text, COLOR_TRANSPARENT)
		skill_text:set_left(math.round(exp_ring:right() + text_offset))
		skill_text:set_top(skillpoint_top)

		max_left_len = math.max(max_left_len, skill_text:w())
		local skill_icon = panel:bitmap({
			w = 16,
			texture = "guis/textures/pd2/shared_skillpoint_symbol",
			h = 16,
			layer = 1
		})

		skill_icon:set_right(skill_text:left())
		skill_icon:set_center_y(skill_text:center_y() + 1)

		skill_glow = panel:bitmap({
			texture = "guis/textures/pd2/crimenet_marker_glow",
			blend_mode = "add",
			layer = 0,
			w = panel:w(),
			h = skill_text:h() * 2,
			color = tweak_data.screen_colors.button_stage_3
		})

		skill_glow:set_center_y(skill_icon:center_y())
	end

	local font_scale = 1
	self._panel = panel

	self._panel:set_size(exp_ring:w() + max_left_len + 15 + max_right_len + 10, math.max(skill_text and skill_text:bottom() or 0, bg_ring:bottom()) + 8)
	self._panel:set_bottom(self._panel:parent():h() - 60)
	bg_ring:move(-5, 0)
	exp_ring:move(-5, 0)
	player_level_panel:set_center(exp_ring:center())

	if skill_glow then
		local function animate_new_skillpoints(o)
			while true do
				over(1, function (p)
					o:set_alpha(math.lerp(0.4, 0.85, math.sin(p * 180)))
				end)
			end
		end

		skill_glow:set_w(self._panel:w())
		skill_glow:set_center_x(skill_text and skill_text:center_x() or 0)
		skill_glow:animate(animate_new_skillpoints)
	end

	self:_rec_round_object(panel)
end

function PlayerProfileGuiObject:_rec_round_object(object)
	local x, y, w, h = object:shape()

	object:set_shape(math.round(x), math.round(y), math.round(w), math.round(h))

	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end
end

function PlayerProfileGuiObject:get_text(text, macros)
	return utf8.to_upper(managers.localization:text(text, macros))
end

function PlayerProfileGuiObject:_make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function PlayerProfileGuiObject:close()
	if self._panel and alive(self._panel) then
		self._panel:parent():remove(self._panel)

		self._panel = nil
	end
end
