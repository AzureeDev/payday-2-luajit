CrimeNetContractGui = CrimeNetContractGui or class()

function CrimeNetContractGui:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
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

	self._node = node
	local job_data = self._node:parameters().menu_component_data
	self._customizable = job_data.customize_contract or false
	self._smart_matchmaking = job_data.smart_matchmaking or false
	local font_size = tweak_data.menu.pd2_small_font_size
	local font = tweak_data.menu.pd2_small_font
	local risk_color = tweak_data.screen_colors.risk
	local padding = tweak_data.gui.crime_net.contract_gui.padding
	local half_padding = 0.5 * padding
	local double_padding = 2 * padding
	local width = tweak_data.gui.crime_net.contract_gui.width
	local height = tweak_data.gui.crime_net.contract_gui.height
	local text_w = tweak_data.gui.crime_net.contract_gui.text_width
	local contact_w = tweak_data.gui.crime_net.contract_gui.contact_width
	local contact_h = contact_w / 1.7777777777777777
	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		layer = 1,
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

	self._contact_text_header = self._panel:text({
		text = " ",
		vertical = "top",
		align = "left",
		layer = 1,
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local x, y, w, h = self._contact_text_header:text_rect()

	self._contact_text_header:set_size(width, h)
	self._contact_text_header:set_center_x(self._panel:w() * 0.5)

	self._contract_panel = self._panel:panel({
		layer = 5,
		h = height,
		w = width,
		x = self._contact_text_header:x(),
		y = self._contact_text_header:bottom()
	})

	self._contract_panel:set_center_y(self._panel:h() * 0.5)
	self._contact_text_header:set_bottom(self._contract_panel:top())

	if self._contact_text_header:y() < 0 then
		local y_offset = -self._contact_text_header:y()

		self._contact_text_header:move(0, y_offset)
		self._contract_panel:move(0, y_offset)
	end

	if not job_data.job_id then
		local bottom = self._contract_panel:bottom()

		self._contract_panel:set_h(160)
		self._contract_panel:set_bottom(bottom)
		self._contact_text_header:set_bottom(self._contract_panel:top())

		local host_name = job_data.host_name or ""
		local num_players = job_data.num_plrs or 1
		local server_text = managers.localization:to_upper_text("menu_lobby_server_title") .. " " .. host_name
		local players_text = managers.localization:to_upper_text("menu_players_online", {
			COUNT = tostring(num_players)
		})

		self._contact_text_header:set_text(server_text .. "\n" .. players_text)
		self._contact_text_header:set_font(tweak_data.menu.pd2_medium_font_id)
		self._contact_text_header:set_font_size(tweak_data.menu.pd2_medium_font_size)

		local x, y, w, h = self._contact_text_header:text_rect()

		self._contact_text_header:set_size(width, h)
		self._contact_text_header:set_top(self._contract_panel:top())
		self._contact_text_header:move(padding, padding)
		BoxGuiObject:new(self._contract_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		self._step = 1
		self._steps = {}

		return
	end

	BoxGuiObject:new(self._contract_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	job_data.job_id = job_data.job_id or "ukrainian_job"
	local narrative = tweak_data.narrative:job_data(job_data.job_id)
	local narrative_chains = tweak_data.narrative:job_chain(job_data.job_id)

	self._contact_text_header:set_text(managers.localization:to_upper_text("menu_cn_contract_title", {
		job = managers.localization:text(narrative.name_id)
	}))

	local last_bottom = 0
	local contract_text = self._contract_panel:text({
		vertical = "top",
		wrap = true,
		align = "left",
		wrap_word = true,
		text = managers.localization:text(narrative.briefing_id),
		w = text_w,
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text,
		x = padding,
		y = padding
	})
	local _, _, _, h = contract_text:text_rect()
	local scale = 1

	if h + contract_text:top() > math.round(self._contract_panel:h() * 0.5) - font_size then
		scale = (math.round(self._contract_panel:h() * 0.5) - font_size) / (h + contract_text:top())
	end

	contract_text:set_font_size(font_size * scale)
	self:make_fine_text(contract_text)

	last_bottom = contract_text:bottom()
	local is_job_ghostable = managers.job:is_job_ghostable(job_data.job_id)

	if is_job_ghostable then
		local min_ghost_bonus, max_ghost_bonus = managers.job:get_job_ghost_bonus(job_data.job_id)
		local min_ghost = math.round(min_ghost_bonus * 100)
		local max_ghost = math.round(max_ghost_bonus * 100)
		local min_string, max_string = nil

		if min_ghost == 0 and min_ghost_bonus ~= 0 then
			min_string = string.format("%0.2f", math.abs(min_ghost_bonus * 100))
		else
			min_string = tostring(math.abs(min_ghost))
		end

		if max_ghost == 0 and max_ghost_bonus ~= 0 then
			max_string = string.format("%0.2f", math.abs(max_ghost_bonus * 100))
		else
			max_string = tostring(math.abs(max_ghost))
		end

		local ghost_bonus_string = min_ghost_bonus == max_ghost_bonus and min_string or min_string .. "-" .. max_string
		local ghostable_text = self._contract_panel:text({
			vertical = "top",
			wrap = true,
			align = "left",
			wrap_word = true,
			blend_mode = "add",
			text = managers.localization:to_upper_text("menu_ghostable_job", {
				bonus = ghost_bonus_string
			}),
			w = text_w,
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.ghost_color
		})

		ghostable_text:set_position(contract_text:x(), last_bottom + padding)
		self:make_fine_text(ghostable_text)

		last_bottom = ghostable_text:bottom()
	end

	if tweak_data.narrative:is_job_locked(job_data.job_id) then
		local locked_text = self._contract_panel:text({
			font = tweak_data.menu.pd2_small_font,
			font_size = font_size,
			text = managers.localization:to_upper_text("bm_menu_vr_locked"),
			color = tweak_data.screen_colors.important_1
		})

		self:make_fine_text(locked_text)
		locked_text:set_position(contract_text:x(), last_bottom + padding)
	end

	local contact_panel = self._contract_panel:panel({
		w = contact_w,
		h = contact_h,
		x = text_w + double_padding,
		y = padding
	})
	local contact_image = contact_panel:rect({
		color = Color(0.3, 0, 0, 0)
	})
	local crimenet_videos = narrative.crimenet_videos

	if crimenet_videos then
		local variant = math.random(#crimenet_videos)

		contact_panel:video({
			blend_mode = "add",
			loop = true,
			video = "movies/" .. crimenet_videos[variant],
			width = contact_panel:w(),
			height = contact_panel:h(),
			color = tweak_data.screen_colors.button_stage_2
		})
	end

	local contact_text = self._contract_panel:text({
		text = managers.localization:to_upper_text(tweak_data.narrative.contacts[narrative.contact].name_id),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text
	})
	local x, y, w, h = contact_text:text_rect()

	contact_text:set_size(w, h)
	contact_text:set_position(contact_panel:left(), contact_panel:bottom() + half_padding)
	BoxGuiObject:new(contact_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local modifiers_text = self._contract_panel:text({
		name = "modifiers_text",
		vertical = "top",
		align = "left",
		text = managers.localization:to_upper_text("menu_cn_modifiers"),
		font = font,
		font_size = font_size,
		x = padding,
		color = tweak_data.screen_colors.text,
		w = text_w
	})

	self:make_fine_text(modifiers_text)
	modifiers_text:set_bottom(math.round(self._contract_panel:h() * 0.5))

	local next_top = modifiers_text:bottom()
	local one_down_active = job_data.one_down == 1

	if one_down_active then
		local one_down_warning_text = self._contract_panel:text({
			name = "one_down_warning_text",
			text = managers.localization:to_upper_text("menu_one_down"),
			font = font,
			font_size = font_size,
			color = tweak_data.screen_colors.one_down
		})

		self:make_fine_text(one_down_warning_text)
		one_down_warning_text:set_top(next_top)
		one_down_warning_text:set_left(double_padding)

		next_top = one_down_warning_text:bottom()
	end

	local ghost_bonus_mul = managers.job:get_ghost_bonus()
	local skill_bonus = managers.player:get_skill_exp_multiplier()
	local infamy_bonus = managers.player:get_infamy_exp_multiplier()
	local limited_bonus = tweak_data:get_value("experience_manager", "limited_bonus_multiplier") or 1
	local job_ghost = math.round(ghost_bonus_mul * 100)
	local job_ghost_string = tostring(math.abs(job_ghost))
	local has_ghost_bonus = ghost_bonus_mul > 0

	if job_ghost == 0 and ghost_bonus_mul ~= 0 then
		job_ghost_string = string.format("%0.2f", math.abs(ghost_bonus_mul * 100))
	end

	local ghost_color = tweak_data.screen_colors.ghost_color
	local ghost_warning_text = self._contract_panel:text({
		name = "ghost_color_warning_text",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		blend_mode = "normal",
		text = managers.localization:to_upper_text("menu_ghost_bonus", {
			exp_bonus = job_ghost_string
		}),
		font = font,
		font_size = font_size,
		color = ghost_color,
		w = text_w
	})

	self:make_fine_text(ghost_warning_text)
	ghost_warning_text:set_top(next_top)
	ghost_warning_text:set_left(double_padding)
	ghost_warning_text:set_visible(has_ghost_bonus)

	if ghost_warning_text:visible() then
		next_top = ghost_warning_text:bottom()
	end

	local job_heat_value = managers.job:get_job_heat(job_data.job_id)
	local ignore_heat = job_heat_value > 0 and self._customizable
	local job_heat_mul = ignore_heat and 0 or managers.job:get_job_heat_multipliers(job_data.job_id) - 1
	local job_heat = math.round(job_heat_mul * 100)
	local job_heat_string = tostring(math.abs(job_heat))
	local is_job_heated = job_heat ~= 0 or job_heat_mul ~= 0

	if job_heat == 0 and job_heat_mul ~= 0 then
		job_heat_string = string.format("%0.2f", math.abs(job_heat_mul * 100))
	end

	self._is_job_heated = is_job_heated
	local heat_color = managers.job:get_job_heat_color(job_data.job_id)
	local heat_text_id = "menu_heat_" .. (job_heat_mul > 0 and "warm" or job_heat_mul < 0 and "cold" or "ok")
	local heat_warning_text = self._contract_panel:text({
		name = "heat_warning_text",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		blend_mode = "normal",
		text = managers.localization:to_upper_text(heat_text_id, {
			job_heat = job_heat_string
		}),
		font = font,
		font_size = font_size,
		color = heat_color,
		w = text_w
	})

	self:make_fine_text(heat_warning_text)
	heat_warning_text:set_top(next_top)
	heat_warning_text:set_left(double_padding)
	heat_warning_text:set_visible(is_job_heated)

	self._heat_color = heat_color

	if heat_warning_text:visible() then
		next_top = heat_warning_text:bottom()
	end

	local pro_warning_text = self._contract_panel:text({
		name = "pro_warning_text",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		blend_mode = "normal",
		text = managers.localization:to_upper_text("menu_pro_warning"),
		font = font,
		font_size = font_size,
		color = tweak_data.screen_colors.pro_color,
		w = text_w
	})

	self:make_fine_text(pro_warning_text)
	pro_warning_text:set_h(pro_warning_text:h())
	pro_warning_text:set_left(double_padding)
	pro_warning_text:set_top(next_top)
	pro_warning_text:set_visible(narrative.professional)

	if pro_warning_text:visible() then
		next_top = pro_warning_text:bottom()
	end

	next_top = next_top + half_padding

	modifiers_text:set_visible(heat_warning_text:visible() or one_down_active or pro_warning_text:visible() or ghost_warning_text:visible())

	local risk_title = self._contract_panel:text({
		font = font,
		font_size = font_size,
		text = managers.localization:to_upper_text("menu_risk"),
		color = risk_color,
		x = padding
	})

	self:make_fine_text(risk_title)
	risk_title:set_top(next_top)

	local menu_risk_id = "menu_risk_pd"

	if job_data.difficulty == "hard" then
		menu_risk_id = "menu_risk_swat"
	elseif job_data.difficulty == "overkill" then
		menu_risk_id = "menu_risk_fbi"
	elseif job_data.difficulty == "overkill_145" then
		menu_risk_id = "menu_risk_special"
	elseif job_data.difficulty == "easy_wish" then
		menu_risk_id = "menu_risk_easy_wish"
	elseif job_data.difficulty == "overkill_290" then
		menu_risk_id = "menu_risk_elite"
	elseif job_data.difficulty == "sm_wish" then
		menu_risk_id = "menu_risk_sm_wish"
	end

	local risk_stats_panel = self._contract_panel:panel({
		name = "risk_stats_panel",
		w = text_w,
		x = padding
	})

	risk_stats_panel:set_h(risk_title:h() + half_padding)

	local plvl = managers.experience:current_level()
	local player_stars = math.max(math.ceil(plvl / 10), 1)
	local job_stars = math.ceil(narrative.jc / 10)
	local difficulty_stars = job_data.difficulty_id - 2
	local job_and_difficulty_stars = job_stars + difficulty_stars
	local rsx = 15
	local risks = {
		"risk_pd",
		"risk_swat",
		"risk_fbi",
		"risk_death_squad",
		"risk_easy_wish"
	}

	if not Global.SKIP_OVERKILL_290 then
		table.insert(risks, "risk_murder_squad")
		table.insert(risks, "risk_sm_wish")
	end

	local max_x = 0
	local max_y = 0

	for i, name in ipairs(risks) do
		if i ~= 1 then
			local texture, rect = tweak_data.hud_icons:get_icon_data(name)
			local active = false
			local color = active and i ~= 1 and risk_color or Color.white
			local alpha = active and 1 or 0.25
			local risk = self._contract_panel:bitmap({
				y = 0,
				x = 0,
				name = name,
				texture = texture,
				texture_rect = rect,
				alpha = alpha,
				color = color
			})

			risk:set_x(rsx)
			risk:set_top(math.round(risk_title:bottom()))

			rsx = rsx + risk:w() + 2
			local stat = managers.statistics:completed_job(job_data.job_id, tweak_data:index_to_difficulty(i + 1))
			local risk_stat = risk_stats_panel:text({
				align = "center",
				name = name,
				font = font,
				font_size = font_size,
				text = tostring(stat)
			})

			self:make_fine_text(risk_stat)
			risk_stat:set_world_center_x(risk:world_center_x() - 1)
			risk_stat:set_x(math.round(risk_stat:x()))

			local this_difficulty = i == difficulty_stars + 1
			active = i <= difficulty_stars + 1
			color = Color.white
			alpha = 0.5

			risk_stat:set_color(color)
			risk_stat:set_alpha(alpha)

			max_y = math.max(max_y, risk:bottom())
			max_x = math.max(max_x, risk:right() + half_padding)
			max_x = math.max(max_x, risk_stat:right() + risk_stats_panel:left() + padding)
		end
	end

	risk_stats_panel:set_top(math.round(max_y + 2))

	local stat = managers.statistics:completed_job(job_data.job_id, tweak_data:index_to_difficulty(difficulty_stars + 2))
	local risk_text = self._contract_panel:text({
		vertical = "top",
		name = "risk_text",
		wrap = true,
		align = "left",
		word_wrap = true,
		w = text_w - max_x,
		text = managers.localization:to_upper_text(menu_risk_id) .. " " .. managers.localization:to_upper_text("menu_stat_job_completed", {
			stat = tostring(stat)
		}) .. " ",
		font = font,
		font_size = font_size,
		color = risk_color,
		x = max_x
	})

	risk_text:set_top(math.round(risk_title:bottom() + 4))
	risk_text:set_h(risk_stats_panel:bottom() - risk_text:top())
	risk_text:hide()

	local potential_rewards_title = self._contract_panel:text({
		blend_mode = "add",
		font = font,
		font_size = font_size,
		text = managers.localization:to_upper_text(self._customizable and "menu_potential_rewards_min" or "menu_potential_rewards", {
			BTN_Y = managers.localization:btn_macro("menu_modify_item")
		}),
		color = managers.menu:is_pc_controller() and self._customizable and tweak_data.screen_colors.button_stage_3 or tweak_data.screen_colors.text,
		x = padding
	})

	self:make_fine_text(potential_rewards_title)
	potential_rewards_title:set_top(math.round(risk_stats_panel:bottom() + 4))

	local jobpay_title = self._contract_panel:text({
		x = 20,
		font = font,
		font_size = font_size,
		text = managers.localization:to_upper_text("cn_menu_contract_jobpay_header"),
		color = tweak_data.screen_colors.text
	})

	self:make_fine_text(jobpay_title)
	jobpay_title:set_top(math.round(potential_rewards_title:bottom()))

	self._potential_rewards_title = potential_rewards_title
	local experience_title = self._contract_panel:text({
		x = 20,
		font = font,
		font_size = font_size,
		text = managers.localization:to_upper_text("menu_experience"),
		color = tweak_data.screen_colors.text
	})

	self:make_fine_text(experience_title)
	experience_title:set_top(math.round(jobpay_title:bottom()))

	local sx = math.max(jobpay_title:right(), experience_title:right())
	sx = sx + 8
	local filled_star_rect = {
		0,
		32,
		32,
		32
	}
	local empty_star_rect = {
		32,
		32,
		32,
		32
	}
	local contract_visuals = job_data.contract_visuals or {}
	local cy = experience_title:center_y()
	local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[difficulty_stars + 1] or contract_visuals.min_mission_xp) or 0
	local total_xp, dissected_xp = managers.experience:get_contract_xp_by_stars(job_data.job_id, job_stars, difficulty_stars, narrative.professional, #narrative_chains, {
		ignore_heat = job_heat_value > 0 and self._customizable,
		mission_xp = xp_min
	})
	local base_xp, risk_xp, heat_base_xp, heat_risk_xp, ghost_base_xp, ghost_risk_xp = unpack(dissected_xp)
	local job_xp, add_xp, heat_add_xp, ghost_add_xp = self:_create_xp_appendices(sx, cy)
	cy = jobpay_title:center_y()
	local total_payout, base_payout, risk_payout = managers.money:get_contract_money_by_stars(job_stars, difficulty_stars, #narrative_chains, job_data.job_id)
	local job_cash = self._contract_panel:text({
		name = "job_cash",
		font = font,
		font_size = font_size,
		text = managers.experience:cash_string(0),
		color = tweak_data.screen_colors.text
	})

	self:make_fine_text(job_cash)
	job_cash:set_x(sx)
	job_cash:set_center_y(math.round(cy))

	local add_cash = self._contract_panel:text({
		text = "",
		name = "job_add_cash",
		font = font,
		font_size = font_size,
		color = risk_color
	})

	add_cash:set_text(" +" .. managers.experience:cash_string(math.round(0)))
	self:make_fine_text(add_cash)
	add_cash:set_x(math.round(job_cash:right()))
	add_cash:set_center_y(math.round(cy))

	local payday_money = math.round(total_payout)
	local payday_text = self._contract_panel:text({
		name = "payday_text",
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		text = managers.localization:to_upper_text("menu_payday", {
			MONEY = managers.experience:cash_string(0)
		}),
		color = tweak_data.screen_colors.text,
		x = padding
	})

	self:make_fine_text(payday_text)
	payday_text:set_bottom(self._contract_panel:h() - padding)

	self._briefing_event = narrative.briefing_event

	if self._briefing_event then
		self._briefing_len_panel = self._contract_panel:panel({
			w = contact_image:w(),
			h = 2 * (font_size + padding)
		})

		self._briefing_len_panel:rect({
			blend_mode = "add",
			name = "duration",
			w = 0,
			halign = "grow",
			alpha = 0.6,
			valign = "grow",
			color = tweak_data.screen_colors.button_stage_3:with_alpha(0.2)
		})
		self._briefing_len_panel:text({
			blend_mode = "add",
			name = "text",
			text = "",
			layer = 1,
			font = font,
			font_size = font_size,
			color = tweak_data.screen_colors.text,
			x = padding,
			y = padding
		})

		local button_text = self._briefing_len_panel:text({
			blend_mode = "add",
			name = "button_text",
			text = " ",
			layer = 1,
			font = font,
			font_size = font_size,
			color = tweak_data.screen_colors.text,
			x = padding,
			y = padding
		})
		local _, _, _, h = button_text:text_rect()

		self._briefing_len_panel:set_h(2 * (h + padding))

		if managers.menu:is_pc_controller() then
			button_text:set_color(tweak_data.screen_colors.button_stage_3)
		end

		BoxGuiObject:new(self._briefing_len_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		self._briefing_len_panel:set_position(contact_text:left(), contact_text:bottom() + padding)
	end

	self._tabs = {}
	self._pages = {}
	self._active_page = nil
	local tabs_panel = self._contract_panel:panel({
		y = 10,
		w = contact_w,
		h = contact_h,
		x = text_w + 20
	})

	tabs_panel:set_top((self._briefing_len_panel and self._briefing_len_panel:bottom() or contact_text:bottom()) + 10)
	tabs_panel:set_visible(false)

	local pages_panel = self._contract_panel:panel({})

	pages_panel:set_visible(false)

	local function add_tab(text_id)
		local prev_tab = self._tabs[#self._tabs]
		local tab_item = MenuGuiSmallTabItem:new(#self._tabs + 1, text_id, nil, self, 0, tabs_panel)

		table.insert(self._tabs, tab_item)

		if prev_tab then
			tab_item._page_panel:set_left(prev_tab:next_page_position())
		end

		if #self._tabs == 1 then
			tab_item:set_active(true)

			self._active_page = 1

			tabs_panel:set_visible(true)
			pages_panel:set_visible(true)
			tabs_panel:set_h(tab_item._page_panel:bottom())
			pages_panel:set_size(contact_w, contact_h - tabs_panel:h())
			pages_panel:set_lefttop(tabs_panel:left(), tabs_panel:bottom() - 2)
			BoxGuiObject:new(pages_panel, {
				sides = {
					1,
					1,
					2,
					1
				}
			})
			managers.menu:active_menu().input:set_force_input(true)
		end

		local page_panel = pages_panel:panel({})

		page_panel:set_visible(tab_item:is_active())
		table.insert(self._pages, page_panel)

		return page_panel
	end

	if job_data.mutators then
		managers.mutators:set_crimenet_lobby_data(job_data.mutators)

		local mutators_panel = add_tab("menu_cn_mutators_active")
		self._mutators_scroll = ScrollablePanel:new(mutators_panel, "mutators_scroll", {
			padding = 0
		})
		local _y = half_padding
		local mutators_list = {}
		local last_item = nil

		for mutator_id, mutator_data in pairs(job_data.mutators) do
			local mutator = managers.mutators:get_mutator_from_id(mutator_id)

			if mutator then
				table.insert(mutators_list, mutator)
			end
		end

		table.sort(mutators_list, function (a, b)
			return a:name() < b:name()
		end)

		for i, mutator in ipairs(mutators_list) do
			local mutator_text = self._mutators_scroll:canvas():text({
				name = "mutator_text_" .. tostring(i),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				text = mutator:name(),
				x = padding,
				y = _y,
				h = tweak_data.menu.pd2_small_font_size
			})
			_y = mutator_text:bottom() + 2
			last_item = mutator_text
		end

		last_item:set_h(last_item:h() + padding)
		self._mutators_scroll:update_canvas_size()
		managers.mutators:set_crimenet_lobby_data(nil)
	end

	if job_data.server == true then
		local content_panel = add_tab("menu_cn_game_settings")
		local _y = 7
		local add_back = true

		local function add_line(left_text, right_text)
			if right_text == nil or left_text == nil then
				return
			end

			if add_back then
				content_panel:rect({
					x = 8,
					layer = -1,
					y = _y,
					h = tweak_data.menu.pd2_small_font_size,
					w = content_panel:w() - 18,
					color = Color.black:with_alpha(0.7)
				})
			end

			add_back = not add_back
			left_text = managers.localization:to_upper_text(left_text)
			right_text = type(right_text) == "number" and tostring(right_text) or managers.localization:to_upper_text(right_text)
			local left = content_panel:text({
				align = "left",
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				text = left_text,
				x = padding,
				y = _y,
				h = tweak_data.menu.pd2_small_font_size,
				w = content_panel:w() - double_padding,
				color = Color(0.8, 0.8, 0.8)
			})
			local right = content_panel:text({
				align = "right",
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				text = right_text .. " ",
				x = padding,
				y = _y,
				h = tweak_data.menu.pd2_small_font_size,
				w = content_panel:w() - 20,
				color = Color(0.5, 0.5, 0.5)
			})
			_y = math.max(left:bottom(), right:bottom()) + 2
		end

		local server_data = job_data.server_data
		local tactics = {
			"menu_plan_loud",
			"menu_plan_stealth",
			[-1.0] = "menu_any"
		}
		local kick = {
			[0] = "menu_kick_disabled",
			"menu_kick_server",
			"menu_kick_vote"
		}
		local drop_in = {
			[0] = "menu_off",
			"menu_drop_in_on",
			"menu_drop_in_prompt",
			"menu_drop_in_stealth_prompt"
		}
		local permission = {
			"menu_public_game",
			"menu_friends_only_game",
			"menu_private_game"
		}

		add_line("menu_preferred_plan", tactics[server_data.job_plan])
		add_line("menu_kicking_allowed_option", kick[server_data.kick_option])
		add_line("menu_permission", permission[server_data.permission])
		add_line("menu_reputation_permission", server_data.min_level or 0)
		add_line("menu_toggle_drop_in", drop_in[server_data.drop_in])
	end

	if job_data.mods then
		local mods_presence = job_data.mods

		if mods_presence and mods_presence ~= "" and mods_presence ~= "1" then
			local content_panel = add_tab("menu_cn_game_mods")
			self._mods_tab = self._tabs[#self._tabs]
			self._mods_scroll = ScrollablePanel:new(content_panel, "mods_scroll", {
				padding = 0
			})
			self._mod_items = {}
			local _y = 7
			local add_back = true

			local function add_line(id, text, ignore_back)
				local canvas = self._mods_scroll:canvas()

				if add_back and not ignore_back then
					canvas:rect({
						x = 8,
						layer = -1,
						y = _y,
						h = tweak_data.menu.pd2_small_font_size,
						w = canvas:w() - 18,
						color = Color.black:with_alpha(0.7)
					})
				end

				add_back = not add_back
				text = string.upper(text)
				local left_text = canvas:text({
					align = "left",
					name = id,
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					text = text,
					x = padding,
					y = _y,
					h = tweak_data.menu.pd2_small_font_size,
					w = canvas:w() - double_padding,
					color = Color(0.8, 0.8, 0.8)
				})
				local highlight_text = canvas:text({
					blend_mode = "add",
					align = "left",
					visible = false,
					name = id,
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					text = text,
					x = padding,
					y = _y,
					h = tweak_data.menu.pd2_small_font_size,
					w = canvas:w() - double_padding,
					color = tweak_data.screen_colors.button_stage_2
				})
				_y = left_text:bottom() + 2

				return left_text, highlight_text
			end

			local splits = string.split(mods_presence, "|")

			for i = 1, #splits, 2 do
				local text, highlight = add_line(splits[i + 1] or "", splits[i] or "")

				table.insert(self._mod_items, {
					text,
					highlight
				})
			end

			add_line("spacer", "", true)
			self._mods_scroll:update_canvas_size()
		end
	end

	local days_multiplier = 0

	for i = 1, #narrative_chains, 1 do
		local day_mul = narrative.professional and tweak_data:get_value("experience_manager", "pro_day_multiplier", i) or tweak_data:get_value("experience_manager", "day_multiplier", i)
		days_multiplier = days_multiplier + day_mul - 1
	end

	days_multiplier = 1 + days_multiplier / #narrative_chains
	local last_day_mul = narrative.professional and tweak_data:get_value("experience_manager", "pro_day_multiplier", #narrative_chains) or tweak_data:get_value("experience_manager", "day_multiplier", #narrative_chains)
	self._data = {
		job_cash = base_payout,
		add_job_cash = risk_payout,
		experience = base_xp,
		add_experience = risk_xp,
		heat_experience = heat_base_xp,
		heat_add_experience = heat_risk_xp,
		ghost_experience = ghost_base_xp,
		ghost_add_experience = ghost_risk_xp,
		num_stages_string = tostring(#narrative_chains) .. " x ",
		payday_money = payday_money,
		counted_job_cash = 0,
		counted_job_xp = 0,
		counted_risk_cash = 0,
		counted_risk_xp = 0,
		counted_heat_xp = 0,
		counted_ghost_xp = 0,
		counted_payday_money = 0,
		stars = {
			job_and_difficulty_stars = job_and_difficulty_stars,
			job_stars = job_stars,
			difficulty_stars = difficulty_stars
		},
		gui_objects = {}
	}
	self._data.gui_objects.risk_stats_panel = risk_stats_panel
	self._data.gui_objects.risk_text = risk_text
	self._data.gui_objects.payday_text = payday_text
	self._data.gui_objects.job_cash = job_cash
	self._data.gui_objects.job_add_cash = add_cash
	self._data.gui_objects.heat_add_xp = heat_add_xp
	self._data.gui_objects.ghost_add_xp = ghost_add_xp
	self._data.gui_objects.add_xp = add_xp
	self._data.gui_objects.job_xp = job_xp
	self._data.gui_objects.risks = {
		"risk_pd",
		"risk_swat",
		"risk_fbi",
		"risk_death_squad",
		"risk_easy_wish"
	}

	if not Global.SKIP_OVERKILL_290 then
		table.insert(self._data.gui_objects.risks, "risk_murder_squad")
		table.insert(self._data.gui_objects.risks, "risk_sm_wish")
	end

	self._data.gui_objects.num_stars = 10
	self._wait_t = 0
	local reached_level_cap = managers.experience:reached_level_cap()
	local levelup_text = reached_level_cap and managers.localization:to_upper_text("menu_reached_level_cap") or managers.localization:to_upper_text("menu_levelup", {
		levels = string.format("%0.1d%%", 0)
	})
	local potential_level_up_text = self._contract_panel:text({
		blend_mode = "normal",
		name = "potential_level_up_text",
		visible = true,
		layer = 3,
		text = levelup_text,
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.hud_stats.potential_xp_color
	})

	self:make_fine_text(potential_level_up_text)
	potential_level_up_text:set_top(math.round(heat_add_xp:top()))
	self:_update_xp_appendices()

	self._data.gui_objects.potential_level_up_text = potential_level_up_text
	self._step = 1
	self._steps = {
		"set_time",
		"start_sound",
		"start_counter",
		"count_job_base",
		"end_counter",
		"count_difficulty_stars",
		"start_counter",
		"count_job_payday",
		"end_counter",
		"free_memory"
	}

	if self._customizable then
		if self._briefing_len_panel then
			self._briefing_len_panel:hide()
		end

		local premium_text = self._contract_panel:text({
			text = "  ",
			name = "premium_text",
			wrap = true,
			blend_mode = "add",
			word_wrap = true,
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.button_stage_3
		})

		premium_text:set_top(contact_text:bottom() + padding)
		premium_text:set_left(contact_text:left())
		premium_text:set_w(contact_image:w())
		self._contact_text_header:set_text(managers.localization:to_upper_text("menu_cn_premium_buy_desc") .. ": " .. managers.localization:to_upper_text(narrative.name_id))

		self._step = 1
		self._steps = {
			"start_sound",
			"set_all",
			"free_memory"
		}
	elseif self._smart_matchmaking then
		self._contact_text_header:set_text(managers.localization:to_upper_text("menu_smm_search_job") .. ": " .. managers.localization:to_upper_text(narrative.name_id))

		self._step = 1
		self._steps = {
			"set_time",
			"start_sound",
			"set_all",
			"free_memory"
		}
	end

	self._current_job_star = 0
	self._current_difficulty_star = 0
	self._post_event_params = {
		show_subtitle = false,
		listener = {
			end_of_event = true,
			duration = true,
			clbk = callback(self, self, "sound_event_callback")
		}
	}

	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:deactivate_controller_mouse()
	end

	self:_rec_round_object(self._panel)

	self._potential_show_max = false
end

function CrimeNetContractGui:_create_xp_appendices(x, y)
	local font_size = tweak_data.menu.pd2_small_font_size
	local font = tweak_data.menu.pd2_small_font
	local job_xp = self._contract_panel:text({
		text = "0",
		name = "job_xp",
		font = font,
		font_size = font_size,
		color = tweak_data.screen_colors.text
	})

	self:make_fine_text(job_xp)
	job_xp:set_x(x)
	job_xp:set_center_y(y)

	local add_xp = self._contract_panel:text({
		text = "",
		name = "add_xp",
		font = font,
		font_size = font_size,
		color = tweak_data.screen_colors.risk
	})

	add_xp:set_text(" +" .. math.round(0))
	self:make_fine_text(add_xp)
	add_xp:set_x(x)
	add_xp:set_center_y(y)

	local ghost_add_xp = self._contract_panel:text({
		text = "",
		name = "ghost_add_xp",
		font = font,
		font_size = font_size,
		color = tweak_data.screen_colors.ghost_color
	})

	ghost_add_xp:set_text(" +" .. math.round(0))
	self:make_fine_text(ghost_add_xp)
	ghost_add_xp:set_x(x)
	ghost_add_xp:set_center_y(y)
	ghost_add_xp:set_visible(managers.job:has_ghost_bonus())

	local heat_add_xp = self._contract_panel:text({
		text = "",
		name = "heat_add_xp",
		font = font,
		font_size = font_size,
		color = self._heat_color
	})

	heat_add_xp:set_text(" +" .. math.round(0))
	self:make_fine_text(heat_add_xp)
	heat_add_xp:set_x(x)
	heat_add_xp:set_center_y(y)
	heat_add_xp:set_visible(self._is_job_heated)
	job_xp:set_y(math.round(job_xp:y()))
	add_xp:set_y(math.round(job_xp:y()))
	heat_add_xp:set_y(math.round(job_xp:y()))
	ghost_add_xp:set_y(math.round(job_xp:y()))

	return job_xp, add_xp, heat_add_xp, ghost_add_xp
end

function CrimeNetContractGui:_update_xp_appendices()
	local job_xp = self._contract_panel:child("job_xp")
	local add_xp = self._contract_panel:child("add_xp")
	local ghost_add_xp = self._contract_panel:child("ghost_add_xp")
	local heat_add_xp = self._contract_panel:child("heat_add_xp")
	local potential_level_up_text = self._contract_panel:child("potential_level_up_text")

	self:make_fine_text(job_xp)
	self:make_fine_text(add_xp)
	self:make_fine_text(ghost_add_xp)
	self:make_fine_text(heat_add_xp)
	self:make_fine_text(potential_level_up_text)
	add_xp:set_left(job_xp:right())
	ghost_add_xp:set_left(add_xp:right())
	heat_add_xp:set_left(ghost_add_xp:visible() and ghost_add_xp:right() or add_xp:right())

	if alive(potential_level_up_text) then
		local x = heat_add_xp:visible() and heat_add_xp:right() or ghost_add_xp:visible() and ghost_add_xp:right() or add_xp:right()
		local fine_x = math.round(x)

		potential_level_up_text:set_left(fine_x + 4)
	end
end

function CrimeNetContractGui:_check_level_up(levels_gained)
	local gonna_level_up = levels_gained >= 1
	self._gonna_level_up = self._gonna_level_up or false

	if self._gonna_level_up ~= gonna_level_up then
		self._gonna_level_up = gonna_level_up
		local potential_level_up_text = self._contract_panel:child("potential_level_up_text")

		potential_level_up_text:stop()
		potential_level_up_text:set_alpha(1)
		potential_level_up_text:set_blend_mode("normal")

		if gonna_level_up then
			local function pulse_anim(o)
				o:set_blend_mode("add")

				while alive(o) do
					over(2, function (p)
						o:set_alpha((math.sin(p * 360) + 1) * 0.5 * 0.2 + 0.8)
					end)
				end
			end

			potential_level_up_text:animate(pulse_anim)
		end
	end
end

function CrimeNetContractGui:_rec_round_object(object)
	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end

	local x, y = object:position()

	object:set_position(math.round(x), math.round(y))
end

function CrimeNetContractGui:set_time(t, dt)
	self._wait_t = t + 1
	self._step = self._step + 1
end

function CrimeNetContractGui:start_sound(t, dt)
	self:toggle_post_event()

	self._step = self._step + 1
end

function CrimeNetContractGui:count_job_stars(t, dt)
	if self._data.stars.job_stars == 0 then
		self._step = self._step + 1

		return
	end

	self._current_job_star = self._current_job_star + 1
	local stars = self._data.stars.job_stars
	local gui_panel = self._contract_panel
	local xp = math.round(self._data.experience * self._current_job_star / stars)
	local gui_xp = self._data.gui_objects.job_xp
	local gui_add_xp = self._data.gui_objects.add_xp
	local gui_heat_add_xp = self._data.gui_objects.heat_add_xp

	gui_xp:set_text(managers.money:add_decimal_marks_to_string(tostring(xp)))
	self:make_fine_text(gui_xp)
	gui_add_xp:set_x(math.round(gui_xp:right()))
	gui_heat_add_xp:set_x(math.round(gui_add_xp:right()))

	if self._data.gui_objects.potential_level_up_text then
		if not managers.experience:reached_level_cap() then
			local gain_xp = xp + 0
			local levels_gained = managers.experience:get_levels_gained_from_xp(gain_xp)
			local levelup_text = managers.localization:to_upper_text("menu_levelup", {
				levels = string.format("%0.1d%%", levels_gained * 100)
			})

			self._data.gui_objects.potential_level_up_text:set_text(levelup_text)
			self:make_fine_text(self._data.gui_objects.potential_level_up_text)
			self:_check_level_up(levels_gained)
		end

		self._data.gui_objects.potential_level_up_text:set_left(math.round((gui_heat_add_xp:visible() and gui_heat_add_xp:right() or gui_add_xp:right()) + 4))
	end

	local job_cash = math.round(self._data.job_cash * self._current_job_star / stars)
	local gui_job_cash = self._data.gui_objects.job_cash
	local gui_job_add_cash = self._data.gui_objects.job_add_cash

	gui_job_cash:set_text(managers.experience:cash_string(job_cash))
	self:make_fine_text(gui_job_cash)
	gui_job_add_cash:set_x(math.round(gui_job_cash:right()))
	managers.menu_component:post_event("count_1_finished")

	self._counting_sound = false
	self._wait_t = t + 0.5

	if self._current_job_star == self._data.stars.job_stars then
		self._wait_t = t + 1
		self._step = self._step + 1
	end
end

function CrimeNetContractGui:count_difficulty_stars(t, dt)
	if self._data.stars.difficulty_stars == 0 then
		self._data.gui_objects.risk_text:show()

		self._step = self._step + 1
		self._wait_t = t + 0.5

		return
	end

	self._current_difficulty_star = self._current_difficulty_star + 1
	local stars = self._data.stars.difficulty_stars
	local gui_panel = self._contract_panel
	local step = self._current_difficulty_star / stars
	local risk_xp = math.round(self._data.add_experience * step)
	local heat_xp = math.round(self._data.heat_experience + self._data.heat_add_experience * step)
	local ghost_xp = math.round(self._data.ghost_experience + self._data.ghost_add_experience * step)
	local gui_add_xp = self._data.gui_objects.add_xp
	local gui_heat_add_xp = self._data.gui_objects.heat_add_xp
	local gui_ghost_add_xp = self._data.gui_objects.ghost_add_xp
	local risk_prefix = risk_xp >= 0 and " +" or " -"
	local heat_prefix = heat_xp >= 0 and " +" or " -"
	local ghost_prefix = ghost_xp >= 0 and " +" or " -"
	local abs_risk_xp = math.abs(risk_xp)
	local abs_heat_xp = math.abs(heat_xp)
	local abs_ghost_xp = math.abs(ghost_xp)

	gui_add_xp:set_text(risk_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_risk_xp)))
	self:make_fine_text(gui_add_xp)
	gui_heat_add_xp:set_text(heat_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_heat_xp)))
	self:make_fine_text(gui_heat_add_xp)
	gui_ghost_add_xp:set_text(ghost_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_ghost_xp)))
	self:make_fine_text(gui_ghost_add_xp)

	if self._data.gui_objects.potential_level_up_text and not managers.experience:reached_level_cap() then
		local gain_xp = self._data.experience + risk_xp + heat_xp + ghost_xp
		local levels_gained = managers.experience:get_levels_gained_from_xp(gain_xp)
		local levelup_text = managers.localization:to_upper_text("menu_levelup", {
			levels = string.format("%0.1d%%", levels_gained * 100)
		})

		self._data.gui_objects.potential_level_up_text:set_text(levelup_text)
		self:make_fine_text(self._data.gui_objects.potential_level_up_text)
		self:_check_level_up(levels_gained)
	end

	self:_update_xp_appendices()

	local job_cash = math.round(self._data.add_job_cash * self._current_difficulty_star / stars)
	local gui_job_cash = self._data.gui_objects.job_cash
	local gui_job_add_cash = self._data.gui_objects.job_add_cash

	gui_job_add_cash:set_text(" +" .. managers.experience:cash_string(job_cash))
	self:make_fine_text(gui_job_add_cash)
	gui_job_add_cash:set_x(math.round(gui_job_cash:right()))

	local child_name = self._data.gui_objects.risks[self._current_difficulty_star + 1]
	local gui_child = child_name and gui_panel:child(child_name)

	if alive(gui_child) then
		gui_child:set_alpha(1)
		gui_child:set_color(tweak_data.screen_colors.risk)
	end

	local gui_child = child_name and self._data.gui_objects.risk_stats_panel:child(child_name)

	if alive(gui_child) then
		local this_difficulty = self._current_difficulty_star == stars
		local active = self._current_difficulty_star <= stars
		local color = active and tweak_data.screen_colors.risk or Color.white
		local alpha = this_difficulty and 1 or 0.5

		gui_child:set_alpha(alpha)
		gui_child:set_color(color)
	end

	managers.menu_component:post_event("count_1_finished")

	self._counting_sound = false
	self._wait_t = t + 0.5

	if self._current_difficulty_star == self._data.stars.difficulty_stars then
		self._wait_t = t + 1
		self._step = self._step + 1

		self._data.gui_objects.risk_text:show()
	end
end

function CrimeNetContractGui:start_counter(t, dt)
	managers.menu_component:post_event("count_1")

	self._counting_sound = true
	self._step = self._step + 1
end

function CrimeNetContractGui:end_counter(t, dt)
	managers.menu_component:post_event("count_1_finished")

	self._counting_sound = false
	self._wait_t = t + 1.5
	self._step = self._step + 1
end

function CrimeNetContractGui:start_count_payday(t, dt)
	managers.menu_component:post_event("count_1")

	self._counting_sound = true
	self._step = self._step + 1
end

function CrimeNetContractGui:count_payday(t, dt)
	self._data.counted_payday_money = math.round(math.step(self._data.counted_payday_money, self._data.payday_money, dt * math.max(self._data.payday_money / (math.rand(1) + 3.5), 40000)))

	self._data.gui_objects.payday_text:set_text(managers.localization:to_upper_text("menu_payday", {
		MONEY = managers.experience:cash_string(self._data.counted_payday_money)
	}))
	self:make_fine_text(self._data.gui_objects.payday_text)

	if self._data.counted_payday_money == self._data.payday_money then
		self._step = self._step + 1
	end
end

function CrimeNetContractGui:end_count_payday(t, dt)
	managers.menu_component:post_event("count_1_finished")

	self._counting_sound = false
	self._wait_t = t + 1.5
	self._step = self._step + 1
end

function CrimeNetContractGui:count_job_base(t, dt)
	local tick = dt * math.max(self._data.experience / (math.rand(1) + 1.5), 4000)
	self._data.counted_job_xp = math.round(math.step(self._data.counted_job_xp, self._data.experience, tick))
	self._data.counted_heat_xp = math.round(math.step(self._data.counted_heat_xp, self._data.heat_experience, tick))
	self._data.counted_ghost_xp = math.round(math.step(self._data.counted_ghost_xp, self._data.ghost_experience, tick))
	local xp = self._data.counted_job_xp
	local heat_xp = self._data.counted_heat_xp
	local ghost_xp = self._data.counted_ghost_xp
	local gui_xp = self._data.gui_objects.job_xp
	local gui_add_xp = self._data.gui_objects.add_xp
	local gui_heat_add_xp = self._data.gui_objects.heat_add_xp
	local gui_ghost_add_xp = self._data.gui_objects.ghost_add_xp

	gui_xp:set_text(managers.money:add_decimal_marks_to_string(tostring(xp)))
	self:make_fine_text(gui_xp)

	local heat_prefix = heat_xp >= 0 and " +" or " -"
	local abs_heat_xp = math.abs(heat_xp)

	gui_heat_add_xp:set_text(heat_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_heat_xp)))
	self:make_fine_text(gui_heat_add_xp)

	local ghost_prefix = ghost_xp >= 0 and " +" or " -"
	local abs_ghost_xp = math.abs(ghost_xp)

	gui_ghost_add_xp:set_text(ghost_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_ghost_xp)))
	self:make_fine_text(gui_ghost_add_xp)

	if self._data.gui_objects.potential_level_up_text and not managers.experience:reached_level_cap() then
		local gain_xp = xp + heat_xp + ghost_xp
		local levels_gained = managers.experience:get_levels_gained_from_xp(gain_xp)
		local levelup_text = managers.localization:to_upper_text("menu_levelup", {
			levels = string.format("%0.1d%%", levels_gained * 100)
		})

		self._data.gui_objects.potential_level_up_text:set_text(levelup_text)
		self:make_fine_text(self._data.gui_objects.potential_level_up_text)
		self:_check_level_up(levels_gained)
	end

	self:_update_xp_appendices()

	self._data.counted_job_cash = math.round(math.step(self._data.counted_job_cash, self._data.job_cash, dt * math.max(self._data.job_cash / (math.rand(1) + 1.5), 80000)))
	local job_cash = self._data.counted_job_cash
	local gui_job_cash = self._data.gui_objects.job_cash
	local gui_job_add_cash = self._data.gui_objects.job_add_cash

	gui_job_cash:set_text(managers.experience:cash_string(job_cash))
	self:make_fine_text(gui_job_cash)
	gui_job_add_cash:set_x(math.round(gui_job_cash:right()))

	if self._data.counted_job_xp == self._data.experience and self._data.counted_job_cash == self._data.job_cash and self._data.counted_heat_xp == self._data.heat_experience and self._data.counted_ghost_xp == self._data.ghost_experience then
		self._step = self._step + 1
	end
end

function CrimeNetContractGui:count_job_risk(t, dt)
	self._data.counted_risk_xp = math.round(math.step(self._data.counted_risk_xp, self._data.add_experience, dt * math.max(self._data.add_experience / (math.rand(1) + 0.75), 40000)))
	self._data.counted_heat_xp = math.round(self._data.heat_experience + math.step(self._data.counted_heat_xp, self._data.heat_add_experience, dt * math.max(self._data.heat_add_experience / (math.rand(1) + 0.75), 40000)))
	local risk_xp = self._data.counted_risk_xp
	local heat_xp = self._data.counted_heat_xp
	local gui_xp = self._data.gui_objects.job_xp
	local gui_add_xp = self._data.gui_objects.add_xp
	local gui_heat_add_xp = self._data.gui_objects.heat_add_xp
	local risk_prefix = risk_xp >= 0 and " +" or " -"
	local heat_prefix = heat_xp >= 0 and " +" or " -"
	local abs_risk_xp = math.abs(risk_xp)
	local abs_heat_xp = math.abs(heat_xp)

	gui_add_xp:set_text(risk_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_risk_xp)))
	self:make_fine_text(gui_add_xp)
	gui_heat_add_xp:set_text(heat_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_heat_xp)))
	self:make_fine_text(gui_heat_add_xp)
	gui_heat_add_xp:set_x(math.round(gui_add_xp:right()))

	if self._data.gui_objects.potential_level_up_text then
		if not managers.experience:reached_level_cap() then
			local gain_xp = self._data.experience + risk_xp + heat_xp
			local levels_gained = managers.experience:get_levels_gained_from_xp(gain_xp)
			local levelup_text = managers.localization:to_upper_text("menu_levelup", {
				levels = string.format("%0.1d%%", levels_gained * 100)
			})

			self._data.gui_objects.potential_level_up_text:set_text(levelup_text)
			self:make_fine_text(self._data.gui_objects.potential_level_up_text)
			self:_check_level_up(levels_gained)
		end

		self._data.gui_objects.potential_level_up_text:set_left(math.round((gui_heat_add_xp:visible() and gui_heat_add_xp:right() or gui_add_xp:right()) + 4))
	end

	self._data.counted_risk_cash = math.round(math.step(self._data.counted_risk_cash, self._data.add_job_cash, dt * math.max(self._data.job_cash / (math.rand(1) + 0.75), 600000)))
	local job_cash = self._data.counted_risk_cash
	local gui_job_cash = self._data.gui_objects.job_cash
	local gui_job_add_cash = self._data.gui_objects.job_add_cash

	gui_job_add_cash:set_text(" +" .. managers.experience:cash_string(job_cash))
	self:make_fine_text(gui_job_add_cash)

	if self._data.counted_risk_xp == self._data.add_experience and self._data.counted_risk_cash == self._data.add_job_cash and self._data.counted_heat_xp == self._data.heat_experience + self._data.heat_add_experience then
		self._step = self._step + 1
	end
end

function CrimeNetContractGui:count_job_payday(t, dt)
	self._data.counted_payday_money = math.round(math.step(self._data.counted_payday_money, self._data.payday_money, dt * math.max(self._data.payday_money / (math.rand(1) + 1.5), 80000)))

	self._data.gui_objects.payday_text:set_text(managers.localization:to_upper_text("menu_payday", {
		MONEY = managers.experience:cash_string(self._data.counted_payday_money)
	}))
	self:make_fine_text(self._data.gui_objects.payday_text)

	if self._data.counted_payday_money == self._data.payday_money then
		self._step = self._step + 1
	end
end

function CrimeNetContractGui:set_potential_rewards(show_max)
	if self._step <= #self._steps then
		return
	end

	local job_data = self._node:parameters().menu_component_data
	local narrative = tweak_data.narrative:job_data(job_data.job_id)
	local narrative_chains = tweak_data.narrative:job_chain(job_data.job_id)
	local job_stars = narrative.jc / 10
	local difficulty_stars = job_data.difficulty_id - 2
	local gui_panel = self._contract_panel
	local potential_level_up_text = gui_panel:child("potential_level_up_text")
	local job_heat_value = managers.job:get_job_heat(job_data.job_id)
	local contract_visuals = job_data.contract_visuals or {}
	local total_xp, dissected_xp, total_payout, base_payout, risk_payout = nil

	if show_max then
		local xp_max = contract_visuals.max_mission_xp and (type(contract_visuals.max_mission_xp) == "table" and contract_visuals.max_mission_xp[difficulty_stars + 1] or contract_visuals.max_mission_xp) or 0
		total_xp, dissected_xp = managers.experience:get_contract_xp_by_stars(job_data.job_id, job_stars, difficulty_stars, job_data.professional, #narrative_chains, {
			ignore_heat = job_heat_value > 0 and self._customizable,
			mission_xp = xp_max
		})
		total_payout, base_payout, risk_payout = managers.money:get_contract_money_by_stars(job_stars, difficulty_stars, #narrative_chains, job_data.job_id, nil, {
			mandatory_bags_value = contract_visuals.mandatory_bags_value and contract_visuals.mandatory_bags_value[difficulty_stars + 1],
			bonus_bags_value = contract_visuals.bonus_bags_value and contract_visuals.bonus_bags_value[difficulty_stars + 1],
			small_value = contract_visuals.small_value and contract_visuals.small_value[difficulty_stars + 1],
			vehicle_value = contract_visuals.vehicle_value and contract_visuals.vehicle_value[difficulty_stars + 1]
		})
	else
		local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[difficulty_stars + 1] or contract_visuals.min_mission_xp) or 0
		total_xp, dissected_xp = managers.experience:get_contract_xp_by_stars(job_data.job_id, job_stars, difficulty_stars, job_data.professional, #narrative_chains, {
			ignore_heat = job_heat_value > 0 and self._customizable,
			mission_xp = xp_min
		})
		total_payout, base_payout, risk_payout = managers.money:get_contract_money_by_stars(job_stars, difficulty_stars, #narrative_chains, job_data.job_id)
	end

	local base_xp, risk_xp, heat_base_xp, heat_risk_xp, ghost_base_xp, ghost_risk_xp = unpack(dissected_xp)
	local num_stages_string = tostring(#narrative_chains) .. " x "
	local xp = base_xp
	local gui_xp = gui_panel:child("job_xp")
	local gui_add_xp = gui_panel:child("add_xp")
	local gui_heat_add_xp = gui_panel:child("heat_add_xp")
	local gui_ghost_add_xp = gui_panel:child("ghost_add_xp")
	local heat_xp = heat_base_xp + heat_risk_xp
	local ghost_xp = ghost_base_xp + ghost_risk_xp
	local risk_prefix = risk_xp >= 0 and " +" or " -"
	local heat_prefix = heat_xp >= 0 and " +" or " -"
	local ghost_prefix = ghost_xp >= 0 and " +" or " -"
	local abs_risk_xp = math.abs(risk_xp)
	local abs_heat_xp = math.abs(heat_xp)
	local abs_ghost_xp = math.abs(ghost_xp)

	gui_xp:set_text(managers.money:add_decimal_marks_to_string(tostring(xp)))
	self:make_fine_text(gui_xp)
	gui_add_xp:set_text(risk_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_risk_xp)))
	self:make_fine_text(gui_add_xp)
	gui_heat_add_xp:set_text(heat_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_heat_xp)))
	self:make_fine_text(gui_heat_add_xp)
	gui_ghost_add_xp:set_text(ghost_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_ghost_xp)))
	self:make_fine_text(gui_ghost_add_xp)

	if potential_level_up_text and not managers.experience:reached_level_cap() then
		local gain_xp = base_xp + risk_xp + heat_xp + ghost_xp
		local levels_gained = managers.experience:get_levels_gained_from_xp(gain_xp)
		local levelup_text = managers.localization:to_upper_text("menu_levelup", {
			levels = string.format("%0.1d%%", levels_gained * 100)
		})

		potential_level_up_text:set_text(levelup_text)
		self:make_fine_text(potential_level_up_text)
		self:_check_level_up(levels_gained)
	end

	self:_update_xp_appendices()

	local job_cash = base_payout
	local gui_job_cash = gui_panel:child("job_cash")
	local gui_job_add_cash = gui_panel:child("job_add_cash")

	gui_job_cash:set_text(managers.experience:cash_string(job_cash))
	self:make_fine_text(gui_job_cash)
	gui_job_add_cash:set_x(math.round(gui_job_cash:right()))

	local job_cash = risk_payout
	local gui_job_add_cash = gui_panel:child("job_add_cash")

	gui_job_add_cash:set_text(" +" .. managers.experience:cash_string(job_cash))
	self:make_fine_text(gui_job_add_cash)

	local risks = {
		"risk_swat",
		"risk_fbi",
		"risk_death_squad",
		"risk_easy_wish"
	}

	if not Global.SKIP_OVERKILL_290 then
		table.insert(risks, "risk_murder_squad")
		table.insert(risks, "risk_sm_wish")
	end

	for i, risk in ipairs(risks) do
		gui_panel:child(risk):set_alpha(i <= difficulty_stars and 1 or 0.25)
		gui_panel:child(risk):set_color(i <= difficulty_stars and tweak_data.screen_colors.risk or Color.white)

		local this_difficulty = i == difficulty_stars
		local active = i <= difficulty_stars
		local color = active and tweak_data.screen_colors.risk or Color.white
		local alpha = this_difficulty and 1 or 0.5

		gui_panel:child("risk_stats_panel"):child(risk):set_color(color)
		gui_panel:child("risk_stats_panel"):child(risk):set_alpha(alpha)
	end

	gui_panel:child("risk_text"):show()
	gui_panel:child("payday_text"):set_text(managers.localization:to_upper_text("menu_payday", {
		MONEY = managers.experience:cash_string(total_payout)
	}))
	self:make_fine_text(gui_panel:child("payday_text"))

	local can_afford = managers.money:can_afford_buy_premium_contract(job_data.job_id, job_data.difficulty_id)
	local text_id = MenuCallbackHandler:bang_active() and "menu_cn_premium_buy_fee_short" or "menu_cn_premium_buy_fee"
	local text_string = managers.localization:to_upper_text(text_id, {
		contract_fee = "##" .. managers.experience:cash_string(managers.money:get_cost_of_premium_contract(job_data.job_id, job_data.difficulty_id)) .. "##"
	})
	local text_dissected = utf8.characters(text_string)
	local idsp = Idstring("#")
	local start_ci = {}
	local end_ci = {}
	local first_ci = true

	for i, c in ipairs(text_dissected) do
		if Idstring(c) == idsp then
			local next_c = text_dissected[i + 1]

			if next_c and Idstring(next_c) == idsp then
				if first_ci then
					table.insert(start_ci, i)
				else
					table.insert(end_ci, i)
				end

				first_ci = not first_ci
			end
		end
	end

	if #start_ci == #end_ci then
		for i = 1, #start_ci, 1 do
			start_ci[i] = start_ci[i] - ((i - 1) * 4 + 1)
			end_ci[i] = end_ci[i] - (i * 4 - 1)
		end
	end

	text_string = string.gsub(text_string, "##", "")
	local premium_text = gui_panel:child("premium_text")

	if alive(premium_text) then
		premium_text:set_text(text_string)
		premium_text:clear_range_color(1, utf8.len(text_string))

		if #start_ci ~= #end_ci then
			Application:error("CrimeNetContractGui: Not even amount of ##'s in skill description string!", #start_ci, #end_ci)
		else
			for i = 1, #start_ci, 1 do
				premium_text:set_range_color(start_ci[i], end_ci[i], i == 1 and not can_afford and tweak_data.screen_colors.pro_color or tweak_data.screen_colors.button_stage_2)
			end
		end
	end
end

function CrimeNetContractGui:set_all(t, dt)
	local job_data = self._node:parameters().menu_component_data
	local narrative = tweak_data.narrative:job_data(job_data.job_id)
	local narrative_chains = tweak_data.narrative:job_chain(job_data.job_id)
	local job_stars = narrative.jc / 10
	local difficulty_stars = job_data.difficulty_id - 2
	local gui_panel = self._contract_panel
	local potential_level_up_text = gui_panel:child("potential_level_up_text")
	local job_heat_value = managers.job:get_job_heat(job_data.job_id)
	local contract_visuals = job_data.contract_visuals or {}
	local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[difficulty_stars + 1] or contract_visuals.min_mission_xp) or 0
	local total_xp, dissected_xp = managers.experience:get_contract_xp_by_stars(job_data.job_id, job_stars, difficulty_stars, job_data.professional, #narrative_chains, {
		ignore_heat = job_heat_value > 0 and self._customizable,
		mission_xp = xp_min
	})
	local total_payout, base_payout, risk_payout = managers.money:get_contract_money_by_stars(job_stars, difficulty_stars, #narrative_chains, job_data.job_id)
	local base_xp, risk_xp, heat_base_xp, heat_risk_xp, ghost_base_xp, ghost_risk_xp = unpack(dissected_xp)
	local num_stages_string = tostring(#narrative_chains) .. " x "
	local xp = base_xp
	local gui_xp = gui_panel:child("job_xp")
	local gui_add_xp = gui_panel:child("add_xp")
	local gui_heat_add_xp = gui_panel:child("heat_add_xp")
	local gui_ghost_add_xp = gui_panel:child("ghost_add_xp")
	local heat_xp = heat_base_xp + heat_risk_xp
	local ghost_xp = ghost_base_xp + ghost_risk_xp
	local risk_prefix = risk_xp >= 0 and " +" or " -"
	local heat_prefix = heat_xp >= 0 and " +" or " -"
	local ghost_prefix = ghost_xp >= 0 and " +" or " -"
	local abs_risk_xp = math.abs(risk_xp)
	local abs_heat_xp = math.abs(heat_xp)
	local abs_ghost_xp = math.abs(ghost_xp)

	gui_xp:set_text(managers.money:add_decimal_marks_to_string(tostring(xp)))
	self:make_fine_text(gui_xp)
	gui_add_xp:set_text(risk_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_risk_xp)))
	self:make_fine_text(gui_add_xp)
	gui_heat_add_xp:set_text(heat_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_heat_xp)))
	self:make_fine_text(gui_heat_add_xp)
	gui_ghost_add_xp:set_text(ghost_prefix .. managers.money:add_decimal_marks_to_string(tostring(abs_ghost_xp)))
	self:make_fine_text(gui_ghost_add_xp)

	local job_cash = base_payout
	local gui_job_cash = gui_panel:child("job_cash")
	local gui_job_add_cash = gui_panel:child("job_add_cash")

	gui_job_cash:set_text(managers.experience:cash_string(job_cash))
	self:make_fine_text(gui_job_cash)
	gui_job_add_cash:set_x(math.round(gui_job_cash:right()))

	if potential_level_up_text and not managers.experience:reached_level_cap() then
		local gain_xp = base_xp + risk_xp + heat_xp + ghost_xp
		local levels_gained = managers.experience:get_levels_gained_from_xp(gain_xp)
		local levelup_text = managers.localization:to_upper_text("menu_levelup", {
			levels = string.format("%0.1d%%", levels_gained * 100)
		})

		potential_level_up_text:set_text(levelup_text)
		self:make_fine_text(potential_level_up_text)
		self:_check_level_up(levels_gained)
	end

	self:_update_xp_appendices()

	local job_cash = risk_payout
	local gui_job_add_cash = gui_panel:child("job_add_cash")

	gui_job_add_cash:set_text(" +" .. managers.experience:cash_string(job_cash))
	self:make_fine_text(gui_job_add_cash)

	local risks = {
		"risk_swat",
		"risk_fbi",
		"risk_death_squad",
		"risk_easy_wish"
	}

	if not Global.SKIP_OVERKILL_290 then
		table.insert(risks, "risk_murder_squad")
		table.insert(risks, "risk_sm_wish")
	end

	for i, risk in ipairs(risks) do
		gui_panel:child(risk):set_alpha(i <= difficulty_stars and 1 or 0.25)
		gui_panel:child(risk):set_color(i <= difficulty_stars and tweak_data.screen_colors.risk or Color.white)

		local this_difficulty = i == difficulty_stars
		local active = i <= difficulty_stars
		local color = active and tweak_data.screen_colors.risk or Color.white
		local alpha = this_difficulty and 1 or 0.5

		gui_panel:child("risk_stats_panel"):child(risk):set_color(color)
		gui_panel:child("risk_stats_panel"):child(risk):set_alpha(alpha)
	end

	gui_panel:child("risk_text"):show()
	gui_panel:child("payday_text"):set_text(managers.localization:to_upper_text("menu_payday", {
		MONEY = managers.experience:cash_string(total_payout)
	}))
	self:make_fine_text(gui_panel:child("payday_text"))

	local can_afford = managers.money:can_afford_buy_premium_contract(job_data.job_id, job_data.difficulty_id)
	local text_id = MenuCallbackHandler:bang_active() and "menu_cn_premium_buy_fee_short" or "menu_cn_premium_buy_fee"
	local text_string = managers.localization:to_upper_text(text_id, {
		contract_fee = "##" .. managers.experience:cash_string(managers.money:get_cost_of_premium_contract(job_data.job_id, job_data.difficulty_id)) .. "##"
	})
	local text_dissected = utf8.characters(text_string)
	local idsp = Idstring("#")
	local start_ci = {}
	local end_ci = {}
	local first_ci = true

	for i, c in ipairs(text_dissected) do
		if Idstring(c) == idsp then
			local next_c = text_dissected[i + 1]

			if next_c and Idstring(next_c) == idsp then
				if first_ci then
					table.insert(start_ci, i)
				else
					table.insert(end_ci, i)
				end

				first_ci = not first_ci
			end
		end
	end

	if #start_ci == #end_ci then
		for i = 1, #start_ci, 1 do
			start_ci[i] = start_ci[i] - ((i - 1) * 4 + 1)
			end_ci[i] = end_ci[i] - (i * 4 - 1)
		end
	end

	text_string = string.gsub(text_string, "##", "")

	if alive(gui_panel:child("premium_text")) then
		gui_panel:child("premium_text"):set_text(text_string)
		gui_panel:child("premium_text"):clear_range_color(1, utf8.len(text_string))

		if #start_ci ~= #end_ci then
			Application:error("CrimeNetContractGui: Not even amount of ##'s in skill description string!", #start_ci, #end_ci)
		else
			for i = 1, #start_ci, 1 do
				gui_panel:child("premium_text"):set_range_color(start_ci[i], end_ci[i], i == 1 and not can_afford and tweak_data.screen_colors.pro_color or tweak_data.screen_colors.button_stage_2)
			end
		end
	end

	if self._step == 2 then
		self._step = self._step + 1
	end
end

function CrimeNetContractGui:free_memory(t, dt)
	self._data = nil
	self._step = self._step + 1

	if self._counting_sound then
		managers.menu_component:post_event("count_1_finished")

		self._counting_sound = false
	end

	if alive(self._potential_rewards_title) then
		self._potential_rewards_title:set_color(managers.menu:is_pc_controller() and (self._button_potential_rewards_highlight and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3) or tweak_data.screen_colors.text)
		self._potential_rewards_title:set_text(managers.localization:to_upper_text(self._potential_show_max and "menu_potential_rewards_max" or "menu_potential_rewards_min", {
			BTN_Y = managers.localization:btn_macro("menu_modify_item")
		}))
		self:make_fine_text(self._potential_rewards_title)

		if self._step > 3 then
			managers.menu_component:post_event("menu_enter")
		end
	end
end

function CrimeNetContractGui:sound_event_callback(event_type, duration)
	if event_type == "end_of_event" then
		self._briefing_duration = nil
		self._briefing_remaining = nil

		self._briefing_len_panel:child("duration"):set_w(0)
		self._briefing_len_panel:child("text"):set_text(managers.localization:to_upper_text("menu_cn_message_stopped"))
		self._briefing_len_panel:child("button_text"):set_text(managers.localization:to_upper_text("menu_play_sound", {
			BTN_X = managers.localization:btn_macro("menu_toggle_voice_message")
		}))
		self:make_fine_text(self._briefing_len_panel:child("text"))
		self:make_fine_text(self._briefing_len_panel:child("button_text"))
		self._briefing_len_panel:child("button_text"):set_position(self._briefing_len_panel:child("text"):left(), self._briefing_len_panel:child("text"):bottom())
	elseif event_type == "duration" and duration > 6 then
		self._briefing_duration = duration
		self._briefing_remaining = self._briefing_duration
	end
end

function CrimeNetContractGui:toggle_post_event()
	if not self._briefing_event then
		return
	end

	if managers.briefing:event_playing() then
		managers.briefing:stop_event()
	else
		managers.briefing:post_event(self._briefing_event, self._post_event_params)
		self._briefing_len_panel:child("text"):set_text(managers.localization:to_upper_text("menu_cn_message_playing"))
		self._briefing_len_panel:child("button_text"):set_text(managers.localization:to_upper_text("menu_stop_sound", {
			BTN_X = managers.localization:btn_macro("menu_toggle_voice_message")
		}))
		self:make_fine_text(self._briefing_len_panel:child("text"))
		self:make_fine_text(self._briefing_len_panel:child("button_text"))
		self._briefing_len_panel:child("button_text"):set_position(self._briefing_len_panel:child("text"):left(), self._briefing_len_panel:child("text"):bottom())
	end
end

function CrimeNetContractGui:set_active_page(index)
	if self._active_page then
		self._tabs[self._active_page]:set_active(false)
		self._pages[self._active_page]:set_visible(false)

		self._active_page = nil
	end

	if self._tabs[index] then
		self._tabs[index]:set_active(true)
		self._pages[index]:set_visible(true)

		self._active_page = index
	end
end

function CrimeNetContractGui:update(t, dt)
	if self._wait_t then
		if self._wait_t < t then
			self._wait_t = nil
		end
	else
		local current_step = self._steps[self._step]

		if current_step then
			self[current_step](self, t, dt)
		end
	end

	if self._briefing_duration and self._briefing_remaining then
		self._briefing_remaining = math.max(self._briefing_remaining - dt, 0)

		if self._briefing_remaining > 0 then
			self._briefing_len_panel:child("duration"):set_w(self._briefing_len_panel:w() * (1 - self._briefing_remaining / self._briefing_duration))
		else
			self._briefing_len_panel:child("duration"):set_w(self._briefing_len_panel:w())

			self._briefing_duration = nil
			self._briefing_remaining = nil
		end
	end
end

function CrimeNetContractGui:mouse_moved(o, x, y)
	if alive(self._briefing_len_panel) and self._briefing_len_panel:visible() and self._step > 2 then
		if self._briefing_len_panel:child("button_text"):inside(x, y) then
			if not self._button_highlight then
				self._button_highlight = true

				self._briefing_len_panel:child("button_text"):set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end

			return true, "link"
		elseif self._button_highlight then
			self._briefing_len_panel:child("button_text"):set_color(tweak_data.screen_colors.button_stage_3)

			self._button_highlight = false
		end
	end

	if alive(self._potential_rewards_title) and self._potential_rewards_title:visible() and self._step > #self._steps then
		if self._potential_rewards_title:inside(x, y) then
			if not self._button_potential_rewards_highlight then
				self._button_potential_rewards_highlight = true

				self._potential_rewards_title:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end

			return true, "link"
		elseif self._button_potential_rewards_highlight then
			self._potential_rewards_title:set_color(tweak_data.screen_colors.button_stage_3)

			self._button_potential_rewards_highlight = false
		end
	end

	local used, pointer = nil

	if self._mod_items and self._mods_tab and self._mods_tab:is_active() then
		for _, item in ipairs(self._mod_items) do
			if item[1]:inside(x, y) and not used then
				pointer = "link"
				used = true

				item[1]:set_visible(false)
				item[2]:set_visible(true)
			else
				item[1]:set_visible(true)
				item[2]:set_visible(false)
			end
		end
	end

	if used then
		return used, pointer
	end

	if self._active_page then
		for k, tab_item in pairs(self._tabs) do
			if not tab_item:is_active() and tab_item:inside(x, y) then
				return true, "link"
			end
		end
	end

	if x > self._contract_panel:left() + 270 and y > self._contract_panel:bottom() - 140 and x < self._contract_panel:right() and y < self._contract_panel:bottom() then
		return false
	end

	return false, "arrow"
end

function CrimeNetContractGui:mouse_pressed(o, button, x, y)
	if alive(self._briefing_len_panel) and self._briefing_len_panel:visible() and self._step > 2 and self._briefing_len_panel:child("button_text"):inside(x, y) then
		self:toggle_post_event()
	end

	if alive(self._potential_rewards_title) and self._potential_rewards_title:visible() and self._potential_rewards_title:inside(x, y) then
		self:_toggle_potential_rewards()
	end

	if self._active_page and button == Idstring("0") then
		for k, tab_item in pairs(self._tabs) do
			if not tab_item:is_active() and tab_item:inside(x, y) then
				self:set_active_page(tab_item:index())
			end
		end
	end

	if self._mod_items and self._mods_tab and self._mods_tab:is_active() and button == Idstring("0") then
		for _, item in ipairs(self._mod_items) do
			if item[1]:inside(x, y) then
				Steam:overlay_activate("url", "http://paydaymods.com/mods/" .. item[1]:name())

				break
			end
		end
	end
end

function CrimeNetContractGui:mouse_wheel_up(x, y)
	if self._mutators_scroll then
		self._mutators_scroll:scroll(x, y, 1)
	end

	if self._mods_scroll then
		self._mods_scroll:scroll(x, y, 1)
	end
end

function CrimeNetContractGui:mouse_wheel_down(x, y)
	if self._mutators_scroll then
		self._mutators_scroll:scroll(x, y, -1)
	end

	if self._mods_scroll then
		self._mods_scroll:scroll(x, y, -1)
	end
end

function CrimeNetContractGui:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function CrimeNetContractGui:_toggle_potential_rewards()
	if alive(self._potential_rewards_title) and self._step > #self._steps then
		self._potential_show_max = not self._potential_show_max

		self._potential_rewards_title:set_text(managers.localization:to_upper_text(self._potential_show_max and "menu_potential_rewards_max" or "menu_potential_rewards_min", {
			BTN_Y = managers.localization:btn_macro("menu_modify_item")
		}))
		self:make_fine_text(self._potential_rewards_title)
		self:set_potential_rewards(self._potential_show_max)
		managers.menu_component:post_event("menu_enter")
	end
end

function CrimeNetContractGui:special_btn_pressed(button)
	if button == Idstring("voice_message") or self._smart_matchmaking and button == Idstring("menu_toggle_voice_message") then
		if alive(self._briefing_len_panel) and self._briefing_len_panel:visible() and self._step > 2 then
			self:toggle_post_event()
		end

		return true
	elseif button == Idstring("menu_modify_item") then
		self:_toggle_potential_rewards()
	elseif button == Idstring("menu_toggle_filters") then
		-- Nothing
	end

	return false
end

function CrimeNetContractGui:previous_page()
	if self._active_page and self._active_page > 1 then
		self:set_active_page(self._active_page - 1)

		return true
	end
end

function CrimeNetContractGui:next_page()
	if self._active_page and self._active_page < #self._tabs then
		self:set_active_page(self._active_page + 1)

		return true
	end
end

function CrimeNetContractGui:set_difficulty_id(difficulty_id)
	local job_data = self._node:parameters().menu_component_data
	local diffs = {
		"easy",
		"normal",
		"hard",
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	job_data.difficulty_id = difficulty_id
	job_data.difficulty = diffs[difficulty_id]
	local menu_risk_id = "menu_risk_pd"

	if job_data.difficulty == "hard" then
		menu_risk_id = "menu_risk_swat"
	elseif job_data.difficulty == "overkill" then
		menu_risk_id = "menu_risk_fbi"
	elseif job_data.difficulty == "overkill_145" then
		menu_risk_id = "menu_risk_special"
	elseif job_data.difficulty == "easy_wish" then
		menu_risk_id = "menu_risk_easy_wish"
	elseif job_data.difficulty == "overkill_290" then
		menu_risk_id = "menu_risk_elite"
	elseif job_data.difficulty == "sm_wish" then
		menu_risk_id = "menu_risk_sm_wish"
	end

	local stat = managers.statistics:completed_job(job_data.job_id, tweak_data:index_to_difficulty(difficulty_id))
	local risk_text = self._contract_panel:child("risk_text")

	risk_text:set_text(managers.localization:to_upper_text(menu_risk_id) .. " " .. managers.localization:to_upper_text("menu_stat_job_completed", {
		stat = tostring(stat)
	}) .. " ")
	self:set_potential_rewards(self._potential_show_max)
end

function CrimeNetContractGui:set_one_down(one_down)
	local job_data = self._node:parameters().menu_component_data
	job_data.one_down = one_down
end

function CrimeNetContractGui:close()
	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:activate_controller_mouse()
	end

	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)

	if self._counting_sound then
		managers.menu_component:post_event("count_1_finished")

		self._counting_sound = false
	end

	managers.briefing:stop_event(true)
	managers.menu:active_menu().input:set_force_input(false)
end
