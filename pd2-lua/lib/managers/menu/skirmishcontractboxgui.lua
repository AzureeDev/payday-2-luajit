require("lib/managers/menu/ContractBoxGui")

SkirmishContractBoxGui = SkirmishContractBoxGui or class(ContractBoxGui)

function SkirmishContractBoxGui:_is_weekly()
	local lobby_data = managers.network.matchmake:get_lobby_data()

	return tonumber(lobby_data.skirmish) == SkirmishManager.LOBBY_WEEKLY
end

function SkirmishContractBoxGui:_crewpage_text()
	return managers.localization:to_upper_text(self:_is_weekly() and "menu_weekly_skirmish" or "menu_skirmish")
end

function SkirmishContractBoxGui:create_contract_box()
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
			text = managers.localization:to_upper_text(self:_is_weekly() and "menu_weekly_skirmish" or "menu_skirmish"),
			h = tweak_data.menu.pd2_medium_font_size,
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			color = tweak_data.screen_colors.text
		})
		local _, _, tw, th = self._contract_text_header:text_rect()

		self._contract_text_header:set_size(tw, th)

		local job_stars = managers.job:current_job_stars()
		local difficulty_stars = managers.job:current_difficulty_stars()
		local contract_visuals = job_data.contract_visuals or {}
		local xp_min = contract_visuals.min_mission_xp and contract_visuals.min_mission_xp or 0
		local xp_max = contract_visuals.max_mission_xp and contract_visuals.max_mission_xp or 0
		local total_xp_min = managers.experience:get_contract_xp_by_stars(job_id, job_stars, difficulty_stars, job_data.professional, #job_chain, {
			mission_xp = xp_min
		})
		local total_xp_max = managers.experience:get_contract_xp_by_stars(job_id, job_stars, difficulty_stars, job_data.professional, #job_chain, {
			mission_xp = xp_max
		})
		local xp_text_min = managers.money:add_decimal_marks_to_string(tostring(math.round(total_xp_min)))
		local xp_text_max = managers.money:add_decimal_marks_to_string(tostring(math.round(total_xp_max)))
		local job_xp_text = total_xp_min < total_xp_max and managers.localization:text("menu_number_range", {
			min = xp_text_min,
			max = xp_text_max
		}) or xp_text_min
		local max_ransom = tweak_data.skirmish.ransom_amounts[select(2, managers.skirmish:wave_range())]
		local total_payout_text = managers.experience:cash_string(max_ransom)
		local next_top = 10
		local lines = {}
		local heading_max_width = 0

		local function add_line(heading_text, value_text)
			local heading = FineText:new(self._contract_panel, {
				text = heading_text,
				font_size = font_size,
				font = font,
				color = tweak_data.screen_colors.text
			})
			heading_max_width = math.max(heading_max_width, heading:width())

			heading:set_top(next_top)

			next_top = math.round(heading:bottom())
			local value = FineText:new(self._contract_panel, {
				text = value_text,
				font = font,
				font_size = font_size,
				color = tweak_data.screen_colors.text
			})

			value:set_top(heading:top())
			table.insert(lines, {
				heading = heading,
				value = value
			})
		end

		local waves_heading = managers.localization:to_upper_text("cn_menu_skirmish_contract_waves_header")
		local waves_value = string.format("%d - %d", managers.skirmish:wave_range())

		add_line(waves_heading, waves_value)

		if self:_is_weekly() then
			local modifiers_heading = managers.localization:to_upper_text("cn_menu_skirmish_contract_modifiers_header")
			local modifiers_value = managers.localization:to_upper_text("cn_menu_contract_mutators_active")

			add_line(modifiers_heading, modifiers_value)
		end

		local exp_heading = managers.localization:to_upper_text("menu_experience")

		add_line(exp_heading, job_xp_text)

		local ransom_heading = managers.localization:to_upper_text("cn_menu_skirmish_contract_ransom_header")

		add_line(ransom_heading, total_payout_text)

		for _, line in ipairs(lines) do
			line.heading:set_right(10 + heading_max_width)
			line.value:set_left(10 + heading_max_width + 5)
		end

		self._contract_panel:set_h(lines[#lines].heading:bottom() + 10)
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

	BoxGuiObject:new(self._contract_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	for i = 1, tweak_data.max_players do
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
