ContractBoxGui = ContractBoxGui or class()

function ContractBoxGui:init(ws, fullscreen_ws)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._panel = self._ws:panel():panel()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()
	local crewpage_text = self._panel:text({
		vertical = "top",
		name = "crewpage_text",
		align = "left",
		text = self:_crewpage_text(),
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local _, _, w, h = crewpage_text:text_rect()

	crewpage_text:set_size(w, h)

	local wfs_text = nil

	if not Network:is_server() then
		wfs_text = self._panel:text({
			vertical = "bottom",
			name = "wfs",
			align = "right",
			text = managers.localization:to_upper_text("victory_client_waiting_for_server"),
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			color = tweak_data.screen_colors.text
		})
		local _, _, w, h = wfs_text:text_rect()

		wfs_text:set_size(w, h)
		wfs_text:set_rightbottom(self._panel:w(), self._panel:h())
	elseif not managers.job:has_active_job() then
		wfs_text = self._panel:text({
			vertical = "bottom",
			name = "wfs",
			align = "right",
			text = managers.localization:to_upper_text("menu_choose_new_contract"),
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			color = tweak_data.screen_colors.text
		})
		local _, _, w, h = wfs_text:text_rect()

		wfs_text:set_size(w, h)
		wfs_text:set_rightbottom(self._panel:w(), self._panel:h())
	end

	self._bg_rect = self._fullscreen_panel:rect({
		name = "lobby_bg",
		alpha = 0,
		layer = -1,
		color = Color.black
	})

	if not managers.menu:is_pc_controller() and wfs_text then
		wfs_text:set_rightbottom(self._panel:w() - 40, self._panel:h() - 150)
	end

	if MenuBackdropGUI then
		if crewpage_text then
			local bg_text = self._fullscreen_panel:text({
				name = "crewpage_text",
				vertical = "top",
				h = 90,
				alpha = 0.4,
				align = "left",
				layer = 1,
				text = self:_crewpage_text(),
				font_size = tweak_data.menu.pd2_massive_font_size,
				font = tweak_data.menu.pd2_massive_font,
				color = tweak_data.screen_colors.button_stage_3
			})
			local x, y = managers.gui_data:safe_to_full_16_9(crewpage_text:world_x(), crewpage_text:world_center_y())

			bg_text:set_world_left(x)
			bg_text:set_world_center_y(y)
			bg_text:move(-13, 9)
			MenuBackdropGUI.animate_bg_text(self, bg_text)
		end

		if managers.menu:is_pc_controller() and wfs_text then
			if false then
				local bg_text = self._fullscreen_panel:text({
					vertical = "bottom",
					h = 90,
					alpha = 0.4,
					align = "right",
					layer = 1,
					text = wfs_text:text(),
					font_size = tweak_data.menu.pd2_massive_font_size,
					font = tweak_data.menu.pd2_massive_font,
					color = tweak_data.screen_colors.button_stage_3
				})
				local x, y = managers.gui_data:safe_to_full_16_9(wfs_text:world_right(), wfs_text:world_center_y())

				bg_text:set_world_right(x)
				bg_text:set_world_center_y(y)
				bg_text:move(13, -9)
				MenuBackdropGUI.animate_bg_text(self, bg_text)
			end
		end
	end

	self:create_contract_box()
	self:create_mutators_tooltip()

	self._lobby_mutators_text = self._panel:text({
		vertical = "top",
		name = "mutated_text",
		align = "left",
		text = managers.localization:to_upper_text("menu_mutators_lobby_wait_title"),
		font_size = tweak_data.menu.pd2_large_font_size * 0.75,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.mutators_color_text
	})
	local _, _, w, h = self._lobby_mutators_text:text_rect()

	self._lobby_mutators_text:set_size(w, h)
	self._lobby_mutators_text:set_top(crewpage_text:bottom())

	local job_chain = managers.job:current_job_chain_data()
	local mutators_active = managers.mutators:are_mutators_enabled() and managers.mutators:allow_mutators_in_level(job_chain and job_chain[1] and job_chain[1].level_id)

	self._lobby_mutators_text:set_visible(mutators_active)
end

function ContractBoxGui:_crewpage_text()
	return managers.localization:to_upper_text("menu_crewpage")
end

function ContractBoxGui:create_contract_box()
	if not managers.network:session() then
		return
	end

	if self._contract_panel and alive(self._contract_panel) then
		self._panel:remove(self._contract_panel)
	end

	if self._contract_text_header and alive(self._contract_text_header) then
		self._panel:remove(self._contract_text_header)
	end

	if alive(self._panel:child("pro_text")) then
		self._panel:remove(self._panel:child("pro_text"))
	end

	self._contract_panel = nil
	self._contract_text_header = nil
	local contact_data = managers.job:current_contact_data()
	local job_data = managers.job:current_job_data()
	local job_chain = managers.job:current_job_chain_data()
	local job_id = managers.job:current_job_id()
	local job_tweak = tweak_data.levels[job_id]
	self._contract_panel = self._panel:panel({
		name = "contract_box_panel",
		h = 100,
		layer = 0,
		w = self._panel:w() * 0.35
	})

	self._contract_panel:rect({
		halign = "grow",
		valign = "grow",
		layer = -1,
		color = Color(0.5, 0, 0, 0)
	})

	local font = tweak_data.menu.pd2_small_font
	local font_size = tweak_data.menu.pd2_small_font_size

	if contact_data then
		self._contract_text_header = self._panel:text({
			blend_mode = "add",
			text = utf8.to_upper(managers.localization:text(contact_data.name_id) .. ": " .. managers.localization:text(job_data.name_id)),
			h = tweak_data.menu.pd2_medium_font_size,
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			color = tweak_data.screen_colors.text
		})
		local length_text_header = self._contract_panel:text({
			text = managers.localization:to_upper_text("cn_menu_contract_length_header"),
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})
		local risk_text_header = self._contract_panel:text({
			text = managers.localization:to_upper_text("menu_lobby_difficulty_title"),
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})
		local exp_text_header = self._contract_panel:text({
			text = managers.localization:to_upper_text("menu_experience"),
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})
		local payout_text_header = self._contract_panel:text({
			text = managers.localization:to_upper_text("cn_menu_contract_jobpay_header"),
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})
		local _, _, tw, th = self._contract_text_header:text_rect()

		self._contract_text_header:set_size(tw, th)

		local w = 0
		local _, _, tw, th = length_text_header:text_rect()
		w = math.max(w, tw)

		length_text_header:set_size(tw, th)

		local _, _, tw, th = risk_text_header:text_rect()
		w = math.max(w, tw)

		risk_text_header:set_size(tw, th)

		local _, _, tw, th = exp_text_header:text_rect()
		w = math.max(w, tw)

		exp_text_header:set_size(tw, th)

		local _, _, tw, th = payout_text_header:text_rect()
		w = math.max(w, tw)

		payout_text_header:set_size(tw, th)

		w = w + 10

		length_text_header:set_right(w)
		risk_text_header:set_right(w)
		exp_text_header:set_right(w)
		payout_text_header:set_right(w)
		risk_text_header:set_top(10)
		length_text_header:set_top(risk_text_header:bottom())
		exp_text_header:set_top(length_text_header:bottom())
		payout_text_header:set_top(exp_text_header:bottom())

		local length_text = self._contract_panel:text({
			vertical = "top",
			align = "left",
			text = managers.localization:to_upper_text("cn_menu_contract_length", {
				stages = #job_chain
			}),
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})

		length_text:set_position(length_text_header:right() + 5, length_text_header:top())

		local _, _, tw, th = length_text:text_rect()
		w = math.max(w, tw)

		length_text:set_size(tw, th)

		if managers.job:is_job_ghostable(managers.job:current_job_id()) then
			local ghost_icon = self._contract_panel:bitmap({
				blend_mode = "add",
				texture = "guis/textures/pd2/cn_minighost",
				h = 16,
				w = 16,
				color = tweak_data.screen_colors.ghost_color
			})

			ghost_icon:set_center_y(length_text:center_y())
			ghost_icon:set_left(length_text:right())
		end

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
		local job_stars = managers.job:current_job_stars()
		local job_and_difficulty_stars = managers.job:current_job_and_difficulty_stars()
		local difficulty_stars = managers.job:current_difficulty_stars()
		local risk_color = tweak_data.screen_colors.risk
		local cy = risk_text_header:center_y()
		local sx = risk_text_header:right() + 5
		local difficulty = tweak_data.difficulties[difficulty_stars + 2] or 1
		local difficulty_string_id = tweak_data.difficulty_name_ids[difficulty]
		local difficulty_string = managers.localization:to_upper_text(difficulty_string_id)
		local difficulty_text = self._contract_panel:text({
			font = font,
			font_size = font_size,
			text = difficulty_string,
			color = tweak_data.screen_colors.text
		})

		if Global.game_settings.one_down then
			local one_down_string = managers.localization:to_upper_text("menu_one_down")

			difficulty_text:set_text(difficulty_string .. " " .. one_down_string)
			difficulty_text:set_range_color(#difficulty_string + 1, math.huge, tweak_data.screen_colors.one_down)
		end

		local _, _, tw, th = difficulty_text:text_rect()

		difficulty_text:set_size(tw, th)
		difficulty_text:set_x(math.round(sx))
		difficulty_text:set_center_y(cy)
		difficulty_text:set_y(math.round(difficulty_text:y()))

		if difficulty_stars > 0 then
			difficulty_text:set_color(risk_color)
		end

		local plvl = managers.experience:current_level()
		local player_stars = math.max(math.ceil(plvl / 10), 1)
		local contract_visuals = job_data.contract_visuals or {}
		local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[difficulty_stars + 1] or contract_visuals.min_mission_xp) or 0
		local xp_max = contract_visuals.max_mission_xp and (type(contract_visuals.max_mission_xp) == "table" and contract_visuals.max_mission_xp[difficulty_stars + 1] or contract_visuals.max_mission_xp) or 0
		local total_xp_min, _ = managers.experience:get_contract_xp_by_stars(job_id, job_stars, difficulty_stars, job_data.professional, #job_chain, {
			mission_xp = xp_min
		})
		local total_xp_max, _ = managers.experience:get_contract_xp_by_stars(job_id, job_stars, difficulty_stars, job_data.professional, #job_chain, {
			mission_xp = xp_max
		})
		local xp_text_min = managers.money:add_decimal_marks_to_string(tostring(math.round(total_xp_min)))
		local xp_text_max = managers.money:add_decimal_marks_to_string(tostring(math.round(total_xp_max)))
		local job_xp_text = total_xp_min < total_xp_max and managers.localization:text("menu_number_range", {
			min = xp_text_min,
			max = xp_text_max
		}) or xp_text_min
		local job_xp = self._contract_panel:text({
			font = font,
			font_size = font_size,
			text = job_xp_text,
			color = tweak_data.screen_colors.text
		})
		local _, _, tw, th = job_xp:text_rect()

		job_xp:set_size(tw, th)
		job_xp:set_position(math.round(exp_text_header:right() + 5), math.round(exp_text_header:top()))

		local risk_xp = self._contract_panel:text({
			font = font,
			font_size = font_size,
			text = " +" .. tostring(math.round(0)),
			color = risk_color
		})
		local _, _, tw, th = risk_xp:text_rect()

		risk_xp:set_size(tw, th)
		risk_xp:set_position(math.round(job_xp:right()), job_xp:top())
		risk_xp:hide()

		local job_ghost_mul = managers.job:get_ghost_bonus() or 0
		local ghost_xp_text = nil

		if job_ghost_mul ~= 0 then
			local job_ghost = math.round(job_ghost_mul * 100)
			local job_ghost_string = tostring(math.abs(job_ghost))
			local ghost_color = tweak_data.screen_colors.ghost_color

			if job_ghost == 0 and job_ghost_mul ~= 0 then
				job_ghost_string = string.format("%0.2f", math.abs(job_ghost_mul * 100))
			end

			local text_prefix = job_ghost_mul < 0 and "-" or "+"
			local text_string = " (" .. text_prefix .. job_ghost_string .. "%)"
			ghost_xp_text = self._contract_panel:text({
				blend_mode = "add",
				font = font,
				font_size = font_size,
				text = text_string,
				color = ghost_color
			})
			local _, _, tw, th = ghost_xp_text:text_rect()

			ghost_xp_text:set_size(tw, th)
			ghost_xp_text:set_position(math.round(risk_xp:visible() and risk_xp:right() or job_xp:right()), job_xp:top())
		end

		local job_heat = managers.job:current_job_heat() or 0
		local job_heat_mul = managers.job:heat_to_experience_multiplier(job_heat) - 1
		local heat_xp_text = nil

		if job_heat_mul ~= 0 then
			job_heat = math.round(job_heat_mul * 100)
			local job_heat_string = tostring(math.abs(job_heat))
			local heat_color = managers.job:current_job_heat_color()

			if job_heat == 0 and job_heat_mul ~= 0 then
				job_heat_string = string.format("%0.2f", math.abs(job_heat_mul * 100))
			end

			local text_prefix = job_heat_mul < 0 and "-" or "+"
			local text_string = " (" .. text_prefix .. job_heat_string .. "%)"
			heat_xp_text = self._contract_panel:text({
				blend_mode = "add",
				font = font,
				font_size = font_size,
				text = text_string,
				color = heat_color
			})
			local _, _, tw, th = heat_xp_text:text_rect()

			heat_xp_text:set_size(tw, th)
			heat_xp_text:set_position(math.round(ghost_xp_text and ghost_xp_text:right() or risk_xp:visible() and risk_xp:right() or job_xp:right()), job_xp:top())
		end

		local total_payout_min, base_payout_min, risk_payout_min = managers.money:get_contract_money_by_stars(job_stars, difficulty_stars, #job_chain, managers.job:current_job_id(), managers.job:current_level_id())
		local total_payout_max, base_payout_max, risk_payout_max = managers.money:get_contract_money_by_stars(job_stars, difficulty_stars, #job_chain, managers.job:current_job_id(), managers.job:current_level_id(), {
			mandatory_bags_value = contract_visuals.mandatory_bags_value and contract_visuals.mandatory_bags_value[difficulty_stars + 1],
			bonus_bags_value = contract_visuals.bonus_bags_value and contract_visuals.bonus_bags_value[difficulty_stars + 1],
			small_value = contract_visuals.small_value and contract_visuals.small_value[difficulty_stars + 1],
			vehicle_value = contract_visuals.vehicle_value and contract_visuals.vehicle_value[difficulty_stars + 1]
		})
		local payout_text_min = managers.experience:cash_string(math.round(total_payout_min))
		local payout_text_max = managers.experience:cash_string(math.round(total_payout_max))
		local total_payout_text = total_payout_min < total_payout_max and managers.localization:text("menu_number_range", {
			min = payout_text_min,
			max = payout_text_max
		}) or payout_text_min
		local job_money = self._contract_panel:text({
			font = font,
			font_size = font_size,
			text = total_payout_text,
			color = tweak_data.screen_colors.text
		})
		local _, _, tw, th = job_money:text_rect()

		job_money:set_size(tw, th)
		job_money:set_position(math.round(payout_text_header:right() + 5), math.round(payout_text_header:top()))

		local risk_money = self._contract_panel:text({
			font = font,
			font_size = font_size,
			text = " +" .. managers.experience:cash_string(math.round(risk_payout_min)),
			color = risk_color
		})
		local _, _, tw, th = risk_money:text_rect()

		risk_money:set_size(tw, th)
		risk_money:set_position(math.round(job_money:right()), job_money:top())
		risk_money:hide()
		self._contract_panel:set_h(payout_text_header:bottom() + 10)

		if managers.mutators:are_mutators_enabled() and managers.mutators:allow_mutators_in_level(job_chain and job_chain[1] and job_chain[1].level_id) then
			local mutators_text_header = self._contract_panel:text({
				name = "mutators_text_header",
				text = managers.localization:to_upper_text("cn_menu_contract_mutators_header"),
				font_size = font_size,
				font = font,
				color = tweak_data.screen_colors.text
			})
			local _, _, tw, th = mutators_text_header:text_rect()
			w = math.max(w, tw)

			mutators_text_header:set_size(tw, th)
			mutators_text_header:set_right(w)
			mutators_text_header:set_top(payout_text_header:bottom())

			local mutators_text = self._contract_panel:text({
				name = "mutators_text",
				font = font,
				font_size = font_size,
				text = managers.localization:to_upper_text("cn_menu_contract_mutators_active"),
				color = tweak_data.screen_colors.mutators_color_text
			})
			local _, _, tw, th = mutators_text:text_rect()

			mutators_text:set_size(tw, th)
			mutators_text:set_position(math.round(mutators_text_header:right() + 5), math.round(mutators_text_header:top()))
			self._contract_panel:set_h(mutators_text:bottom() + 10)
		end
	elseif managers.menu:debug_menu_enabled() then
		local debug_start = self._contract_panel:text({
			text = "Use DEBUG START to start your level",
			y = 10,
			wrap = true,
			x = 10,
			word_wrap = true,
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})

		debug_start:grow(-debug_start:x() - 10, debug_start:y() - 10)
	end

	self._contract_panel:set_rightbottom(self._panel:w() - 0, self._panel:h() - 60)

	if self._contract_text_header then
		self._contract_text_header:set_bottom(self._contract_panel:top())
		self._contract_text_header:set_left(self._contract_panel:left())

		local wfs_text = self._panel:child("wfs")

		if wfs_text and not managers.menu:is_pc_controller() then
			wfs_text:set_rightbottom(self._panel:w() - 20, self._contract_text_header:top())
		end
	end

	local wfs = self._panel:child("wfs")

	if wfs then
		self._contract_panel:grow(0, wfs:h() + 5)
		self._contract_panel:move(0, -(wfs:h() + 5))

		if self._contract_text_header then
			self._contract_text_header:move(0, -(wfs:h() + 5))
		end

		wfs:set_world_rightbottom(self._contract_panel:world_right() - 5, self._contract_panel:world_bottom())
	end

	if job_tweak and job_tweak.is_safehouse and not job_tweak.is_safehouse_combat then
		self._contract_text_header:set_bottom(self._contract_panel:bottom())
		self._contract_panel:set_h(0)
	end

	BoxGuiObject:new(self._contract_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	for i = 1, tweak_data.max_players, 1 do
		local peer = managers.network:session():peer(i)

		if peer then
			local peer_pos = managers.menu_scene:character_screen_position(i)
			local peer_name = peer:name()

			if peer_pos then
				self:create_character_text(i, peer_pos.x, peer_pos.y, peer_name)
			end
		end
	end

	self._enabled = true
end

function ContractBoxGui:create_mutators_tooltip()
	if self._mutators_tooltip and alive(self._mutators_tooltip) then
		self._fullscreen_panel:remove(self._mutators_tooltip)

		self._mutators_tooltip = nil
		self._mutators_data = nil
	end

	if not managers.network:session() or not managers.mutators:are_mutators_enabled() then
		return
	end

	self._mutators_tooltip = self._fullscreen_panel:panel({
		name = "mutator_tooltip",
		h = 100,
		layer = 10,
		w = self._panel:w() * 0.25
	})
	local mutators_title = self._mutators_tooltip:text({
		y = 10,
		name = "mutators_title",
		x = 10,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		text = managers.localization:to_upper_text("menu_cn_mutators_active"),
		h = tweak_data.menu.pd2_medium_font_size
	})
	local _y = mutators_title:bottom() + 5
	local mutators_list = {}
	self._mutators_data = deep_clone(managers.mutators:get_mutators_from_lobby_data())

	for mutator_id, mutator_data in pairs(self._mutators_data) do
		local mutator = managers.mutators:get_mutator_from_id(mutator_id)

		if mutator then
			table.insert(mutators_list, mutator)
		end
	end

	table.sort(mutators_list, function (a, b)
		return a:name() < b:name()
	end)

	for i, mutator in ipairs(mutators_list) do
		local mutator_text = self._mutators_tooltip:text({
			x = 10,
			layer = 1,
			name = "mutator_text_" .. tostring(mutator:id()),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			text = mutator:name(),
			y = _y,
			h = tweak_data.menu.pd2_small_font_size
		})
		_y = mutator_text:bottom() + 2
	end

	self._mutators_tooltip:set_h(_y + 10)
	self._mutators_tooltip:rect({
		alpha = 0.8,
		layer = -1,
		color = Color.black
	})
	BoxGuiObject:new(self._mutators_tooltip, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self._mutators_tooltip:set_alpha(0)
end

function ContractBoxGui:check_update_mutators_tooltip()
	local refresh_contract, refresh_tooltip = nil

	if alive(self._lobby_mutators_text) then
		self._lobby_mutators_text:set_visible(managers.mutators:are_mutators_enabled())
	end

	if not managers.mutators:are_mutators_enabled() then
		if self._mutators_tooltip then
			refresh_contract = true
			refresh_tooltip = true
		end
	else
		local lobby_data = managers.mutators:get_mutators_from_lobby_data()

		if self._mutators_data then
			refresh_contract = self._contract_panel:child("mutators_text") == nil

			for mutator_id, mutator_data in pairs(lobby_data) do
				if self._mutators_data[mutator_id] then
					for key, value in pairs(mutator_data) do
						if self._mutators_data[mutator_id][key] ~= value then
							refresh_tooltip = true

							break
						end
					end
				else
					refresh_tooltip = true
				end
			end

			if not refresh_tooltip then
				for mutator_id, mutator_data in pairs(self._mutators_data) do
					if not lobby_data[mutator_id] then
						refresh_tooltip = true

						break
					else
						for key, value in pairs(mutator_data) do
							if lobby_data[mutator_id][key] ~= value then
								refresh_tooltip = true

								break
							end
						end
					end
				end
			end
		elseif lobby_data then
			refresh_tooltip = true
			refresh_contract = self._contract_panel:child("mutators_text") == nil
		elseif not lobby_data then
			refresh_contract = self._contract_panel:child("mutators_text") ~= nil
		end
	end

	if refresh_contract then
		self:create_contract_box()
	end

	if refresh_tooltip then
		self:create_mutators_tooltip()
	end
end

function ContractBoxGui:refresh()
	self:create_contract_box()
	self:create_mutators_tooltip()
end

function ContractBoxGui:update(t, dt)
	for i = 1, tweak_data.max_players, 1 do
		self:update_character(i)
	end

	if managers.job:current_contact_data() then
		self._update_tooltip_t = (self._update_tooltip_t or 1) - dt

		if self._update_tooltip_t < 0 then
			self:check_update_mutators_tooltip()

			self._update_tooltip_t = 1
		end
	end

	if self._mutators_tooltip then
		local mutators_text_header = self._contract_panel:child("mutators_text_header")
		local mutators_text = self._contract_panel:child("mutators_text")
		local speed = 6
		local x, y = managers.mouse_pointer:modified_mouse_pos()

		if mutators_text_header and mutators_text_header:inside(x, y) or mutators_text and mutators_text:inside(x, y) then
			self._mutators_tooltip:set_alpha(math.clamp(self._mutators_tooltip:alpha() + speed * TimerManager:main():delta_time(), 0, 1))
		else
			self._mutators_tooltip:set_alpha(math.clamp(self._mutators_tooltip:alpha() - speed * TimerManager:main():delta_time(), 0, 1))
		end
	end

	if alive(self._lobby_mutators_text) then
		local a = 0.75 + math.abs(math.sin(t * 120) * 0.25)

		self._lobby_mutators_text:set_alpha(a)
	end
end

function ContractBoxGui:create_character_text(peer_id, x, y, text, icon, panel)
	panel = panel or self._panel

	if _G.IS_VR then
		panel, x, y = managers.menu_scene:create_character_text_panel(peer_id)
	end

	self._peers = self._peers or {}
	local color_id = peer_id
	local color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
	self._peers[peer_id] = self._peers[peer_id] or panel:text({
		vertical = "center",
		blend_mode = "add",
		align = "center",
		text = "",
		layer = 0,
		name = tostring(peer_id),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = color
	})

	self._peers[peer_id]:set_text(text or "")
	self._peers[peer_id]:set_visible(self._enabled)

	local _, _, w, h = self._peers[peer_id]:text_rect()

	self._peers[peer_id]:set_size(w, h)
	self._peers[peer_id]:set_center(x, y)

	self._peers_state = self._peers_state or {}
	self._peers_state[peer_id] = self._peers_state[peer_id] or panel:text({
		vertical = "top",
		blend_mode = "add",
		align = "center",
		text = "",
		rotation = 360,
		layer = 0,
		name = tostring(peer_id) .. "_state",
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})

	self._peers_state[peer_id]:set_top(self._peers[peer_id]:bottom())
	self._peers_state[peer_id]:set_center_x(self._peers[peer_id]:center_x())

	if icon then
		local texture = tweak_data.hud_icons:get_icon_data("infamy_icon")
		self._peers_icon = self._peers_icon or {}
		self._peers_icon[peer_id] = self._peers_icon[peer_id] or panel:bitmap({
			w = 16,
			h = 32,
			texture = texture,
			color = color
		})

		self._peers_icon[peer_id]:set_right(self._peers[peer_id]:x())
		self._peers_icon[peer_id]:set_top(self._peers[peer_id]:y())
	elseif self._peers_icon and self._peers_icon[peer_id] then
		panel:remove(self._peers_icon[peer_id])

		self._peers_icon[peer_id] = nil
	end

	self._peers_spree = self._peers_spree or {}

	if self._peers[peer_id]:visible() and self._peers[peer_id]:text() ~= "" then
		local level = managers.crime_spree:get_peer_spree_level(peer_id)
		local text = managers.experience:cash_string(level, "") .. managers.localization:get_default_macro("BTN_SPREE_TICKET")
		self._peers_spree[peer_id] = self._peers_spree[peer_id] or panel:text({
			vertical = "top",
			blend_mode = "add",
			align = "center",
			rotation = 360,
			layer = 0,
			name = tostring(peer_id) .. "_spree",
			text = text,
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			color = tweak_data.screen_colors.crime_spree_risk
		})

		self._peers_spree[peer_id]:set_text(text)

		local _, _, w, h = self._peers_spree[peer_id]:text_rect()

		self._peers_spree[peer_id]:set_size(w, h)
		self._peers_spree[peer_id]:set_bottom(self._peers[peer_id]:top())
		self._peers_spree[peer_id]:set_center_x(self._peers[peer_id]:center_x())
		self._peers_spree[peer_id]:set_visible(self._enabled and game_state_machine:gamemode().id == GamemodeCrimeSpree.id and level >= 0)
	elseif self._peers_spree and self._peers_spree[peer_id] then
		panel:remove(self._peers_spree[peer_id])

		self._peers_spree[peer_id] = nil
	end
end

function ContractBoxGui:update_character(peer_id)
	if not peer_id or not managers.network:session() then
		return
	end

	local x = 0
	local y = 0
	local text = ""
	local player_rank = 0
	local peer = managers.network:session():peer(peer_id)

	if peer then
		local local_peer = managers.network:session() and managers.network:session():local_peer()
		local peer_pos = managers.menu_scene:character_screen_position(peer_id)
		x = peer_pos.x
		y = peer_pos.y
		text = peer:name()
		local player_level = peer == local_peer and managers.experience:current_level() or peer:level()

		if player_level then
			player_rank = peer == local_peer and managers.experience:current_rank() or peer:rank()
			local experience = (player_rank > 0 and managers.experience:rank_string(player_rank) .. "-" or "") .. player_level
			text = text .. " (" .. experience .. ")"
		end
	else
		self:update_character_menu_state(peer_id, nil)
	end

	self:create_character_text(peer_id, x, y, text, player_rank > 0)
end

function ContractBoxGui:update_character_menu_state(peer_id, state)
	if not self._peers_state then
		return
	end

	if not self._peers_state[peer_id] then
		return
	end

	self._peers_state[peer_id]:set_text(state and managers.localization:to_upper_text("menu_lobby_menu_state_" .. state) or "")
end

function ContractBoxGui:update_bg_state(peer_id, state)
	local peer = managers.network:session() and managers.network:session():local_peer() or false

	if peer and peer:id() == peer_id then
		self._bg_rect:set_alpha(state == "options" and 0.4 or 0)
	end
end

function ContractBoxGui:set_character_panel_alpha(peer_id, alpha)
	if self._peers and self._peers[peer_id] then
		self._peers[peer_id]:set_alpha(alpha)
	end

	if self._peers_state and self._peers_state[peer_id] then
		self._peers_state[peer_id]:set_alpha(alpha)
	end

	if self._peers_icon and self._peers_icon[peer_id] then
		self._peers_icon[peer_id]:set_alpha(alpha)
	end
end

function ContractBoxGui:_create_text_box(ws, title, text, content_data, config)
end

function ContractBoxGui:_create_lower_static_panel(lower_static_panel)
end

function ContractBoxGui:mouse_pressed(button, x, y)
	if not self:can_take_input() then
		return
	end

	if button == Idstring("0") then
		local used = false
		local pointer = "arrow"

		if self._peers and SystemInfo:platform() == Idstring("WIN32") and MenuCallbackHandler:is_overlay_enabled() then
			for peer_id, object in pairs(self._peers) do
				if alive(object) and object:inside(x, y) then
					local peer = managers.network:session() and managers.network:session():peer(peer_id)

					if peer then
						Steam:overlay_activate("url", tweak_data.gui.fbi_files_webpage .. "/suspect/" .. peer:user_id() .. "/")

						return
					end
				end
			end
		end
	end
end

function ContractBoxGui:mouse_moved(x, y)
	if not self:can_take_input() then
		return
	end

	local used = false
	local pointer = "arrow"

	if self._peers and SystemInfo:platform() == Idstring("WIN32") and MenuCallbackHandler:is_overlay_enabled() then
		for peer_id, object in pairs(self._peers) do
			if alive(object) and object:inside(x, y) then
				used = true
				pointer = "link"
			end
		end
	end

	if self._mutators_tooltip then
		local mutators_text_header = self._contract_panel:child("mutators_text_header")
		local mutators_text = self._contract_panel:child("mutators_text")
		local speed = 6

		if mutators_text_header and mutators_text_header:inside(x, y) or mutators_text and mutators_text:inside(x, y) then
			self._mutators_tooltip:set_world_left(x)
			self._mutators_tooltip:set_world_bottom(y)

			return true, "link"
		end
	end

	return used, pointer
end

function ContractBoxGui:can_take_input()
	return true
end

function ContractBoxGui:moved_scroll_bar()
end

function ContractBoxGui:mouse_wheel_down()
end

function ContractBoxGui:mouse_wheel_up()
end

function ContractBoxGui:check_minimize()
	return false
end

function ContractBoxGui:check_grab_scroll_bar()
	return false
end

function ContractBoxGui:release_scroll_bar()
	return false
end

function ContractBoxGui:set_enabled(enabled)
	self._enabled = enabled

	if self._contract_panel then
		self._contract_panel:set_visible(enabled)
	end

	if self._contract_text_header then
		self._contract_text_header:set_visible(enabled)
	end

	if self._contract_pro_text then
		self._contract_pro_text:set_visible(enabled)
	end

	if self._panel:child("wfs") then
		self._panel:child("wfs"):set_visible(enabled)
	end
end

function ContractBoxGui:set_size(x, y)
end

function ContractBoxGui:set_visible(visible)
end

function ContractBoxGui:close()
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end
