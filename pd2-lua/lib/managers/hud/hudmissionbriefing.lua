require("lib/managers/menu/MenuBackdropGUI")
require("lib/managers/menu/SkirmishBriefingProgress")

HUDMissionBriefing = HUDMissionBriefing or class()

function HUDMissionBriefing:init(hud, workspace)
	self._backdrop = MenuBackdropGUI:new(workspace)

	if not _G.IS_VR then
		self._backdrop:create_black_borders()
	end

	self._hud = hud
	self._workspace = workspace
	self._singleplayer = Global.game_settings.single_player
	local bg_font = tweak_data.menu.pd2_massive_font
	local title_font = tweak_data.menu.pd2_large_font
	local content_font = tweak_data.menu.pd2_medium_font
	local text_font = tweak_data.menu.pd2_small_font
	local bg_font_size = tweak_data.menu.pd2_massive_font_size
	local title_font_size = tweak_data.menu.pd2_large_font_size
	local content_font_size = tweak_data.menu.pd2_medium_font_size
	local text_font_size = tweak_data.menu.pd2_small_font_size
	local interupt_stage = managers.job:interupt_stage()
	self._background_layer_one = self._backdrop:get_new_background_layer()
	self._background_layer_two = self._backdrop:get_new_background_layer()
	self._background_layer_three = self._backdrop:get_new_background_layer()
	self._foreground_layer_one = self._backdrop:get_new_foreground_layer()

	self._backdrop:set_panel_to_saferect(self._background_layer_one)
	self._backdrop:set_panel_to_saferect(self._foreground_layer_one)

	self._ready_slot_panel = self._foreground_layer_one:panel({
		name = "player_slot_panel",
		w = self._foreground_layer_one:w() / 2,
		h = text_font_size * 4 + 20
	})

	self._ready_slot_panel:set_bottom(self._foreground_layer_one:h() - 70)
	self._ready_slot_panel:set_right(self._foreground_layer_one:w())

	if not self._singleplayer then
		local voice_icon, voice_texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_talk")

		for i = 1, tweak_data.max_players do
			local color_id = i
			local color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
			local slot_panel = self._ready_slot_panel:panel({
				x = 10,
				name = "slot_" .. tostring(i),
				h = text_font_size,
				y = (i - 1) * text_font_size + 10,
				w = self._ready_slot_panel:w() - 20
			})
			local criminal = slot_panel:text({
				name = "criminal",
				align = "left",
				blend_mode = "add",
				vertical = "center",
				font_size = text_font_size,
				font = text_font,
				color = color,
				text = tweak_data.gui.LONGEST_CHAR_NAME
			})
			local voice = slot_panel:bitmap({
				name = "voice",
				visible = false,
				x = 10,
				layer = 2,
				texture = voice_icon,
				texture_rect = voice_texture_rect,
				w = voice_texture_rect[3],
				h = voice_texture_rect[4],
				color = color
			})
			local name = slot_panel:text({
				vertical = "center",
				name = "name",
				w = 256,
				align = "left",
				blend_mode = "add",
				rotation = 360,
				layer = 1,
				text = managers.localization:text("menu_lobby_player_slot_available") .. "  ",
				font = text_font,
				font_size = text_font_size,
				color = color:with_alpha(0.5),
				h = text_font_size
			})
			local status = slot_panel:text({
				vertical = "center",
				name = "status",
				w = 256,
				align = "right",
				blend_mode = "add",
				text = "  ",
				visible = false,
				layer = 1,
				font = text_font,
				font_size = text_font_size,
				h = text_font_size,
				color = tweak_data.screen_colors.text:with_alpha(0.5)
			})
			local infamy = slot_panel:bitmap({
				w = 16,
				name = "infamy",
				h = 16,
				visible = false,
				y = 1,
				layer = 2,
				color = color
			})
			local detection = slot_panel:panel({
				name = "detection",
				visible = false,
				layer = 2,
				w = slot_panel:h(),
				h = slot_panel:h()
			})
			local detection_ring_left_bg = detection:bitmap({
				blend_mode = "add",
				name = "detection_left_bg",
				alpha = 0.2,
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				w = detection:w(),
				h = detection:h()
			})
			local detection_ring_right_bg = detection:bitmap({
				blend_mode = "add",
				name = "detection_right_bg",
				alpha = 0.2,
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				w = detection:w(),
				h = detection:h()
			})

			detection_ring_right_bg:set_texture_rect(detection_ring_right_bg:texture_width(), 0, -detection_ring_right_bg:texture_width(), detection_ring_right_bg:texture_height())

			local detection_ring_left = detection:bitmap({
				blend_mode = "add",
				name = "detection_left",
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				render_template = "VertexColorTexturedRadial",
				layer = 1,
				w = detection:w(),
				h = detection:h()
			})
			local detection_ring_right = detection:bitmap({
				blend_mode = "add",
				name = "detection_right",
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				render_template = "VertexColorTexturedRadial",
				layer = 1,
				w = detection:w(),
				h = detection:h()
			})

			detection_ring_right:set_texture_rect(detection_ring_right:texture_width(), 0, -detection_ring_right:texture_width(), detection_ring_right:texture_height())

			local detection_value = slot_panel:text({
				text = " ",
				name = "detection_value",
				align = "left",
				blend_mode = "add",
				vertical = "center",
				font_size = text_font_size,
				font = text_font,
				color = color
			})

			detection:set_left(slot_panel:w() * 0.65)
			detection_value:set_left(detection:right() + 2)
			detection_value:set_visible(detection:visible())

			local _, _, w, _ = criminal:text_rect()

			voice:set_left(w + 2)
			criminal:set_w(w)
			criminal:set_align("right")
			criminal:set_text("")
			name:set_left(voice:right() + 2)
			status:set_right(slot_panel:w())
			infamy:set_left(name:x())
		end

		BoxGuiObject:new(self._ready_slot_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	if not managers.job:has_active_job() then
		return
	end

	self._current_contact_data = managers.job:current_contact_data()
	self._current_level_data = managers.job:current_level_data()
	self._current_stage_data = managers.job:current_stage_data()
	self._current_job_data = managers.job:current_job_data()
	self._current_job_chain = managers.job:current_job_chain_data()
	self._job_class = self._current_job_data and self._current_job_data.jc or 0
	local show_contact_gui = true

	if managers.crime_spree:is_active() then
		self._backdrop:set_pattern("guis/textures/pd2/mission_briefing/bain/bd_pattern", 0.1, "add")

		show_contact_gui = false
	end

	if show_contact_gui then
		local contact_gui = self._background_layer_two:gui(self._current_contact_data.assets_gui, {})
		local contact_pattern = contact_gui:has_script() and contact_gui:script().pattern

		if contact_pattern then
			self._backdrop:set_pattern(contact_pattern, 0.1, "add")
		end
	end

	local padding_y = 60
	self._paygrade_panel = self._background_layer_one:panel({
		w = 210,
		h = 70,
		y = padding_y
	})
	local pg_text = self._foreground_layer_one:text({
		name = "pg_text",
		vertical = "center",
		h = 32,
		align = "right",
		text = utf8.to_upper(managers.localization:text("menu_risk")),
		y = padding_y,
		font_size = content_font_size,
		font = content_font,
		color = tweak_data.screen_colors.text
	})
	local _, _, w, h = pg_text:text_rect()

	pg_text:set_size(w, h)

	self._paygrade_text = pg_text
	local job_stars = managers.job:current_job_stars()
	local job_and_difficulty_stars = managers.job:current_job_and_difficulty_stars()
	local difficulty_stars = managers.job:current_difficulty_stars()
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
	local num_stars = 0
	local x = 0
	local y = 0
	local star_size = 18
	local panel_w = 0
	local panel_h = 0
	local risk_color = tweak_data.screen_colors.risk
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

	for i, name in ipairs(risks) do
		local texture, rect = tweak_data.hud_icons:get_icon_data(name)
		local active = i <= difficulty_stars
		local color = active and risk_color or tweak_data.screen_colors.text
		local alpha = active and 1 or 0.25
		local risk = self._paygrade_panel:bitmap({
			y = 0,
			x = 0,
			name = name,
			texture = texture,
			texture_rect = rect,
			alpha = alpha,
			color = color
		})

		risk:set_position(x, y)

		x = x + risk:w() + 0
		panel_w = math.max(panel_w, risk:right())
		panel_h = math.max(panel_h, risk:h())
	end

	pg_text:set_color(risk_color)
	self._paygrade_panel:set_h(panel_h)
	self._paygrade_panel:set_w(panel_w)
	self._paygrade_panel:set_right(self._background_layer_one:w())
	pg_text:set_right(self._paygrade_panel:left())

	if Global.game_settings.one_down then
		local one_down_text = self._foreground_layer_one:text({
			name = "one_down_text",
			text = managers.localization:to_upper_text("menu_one_down"),
			font = content_font,
			font_size = content_font_size,
			color = tweak_data.screen_colors.one_down
		})
		local _, _, w, h = one_down_text:text_rect()

		one_down_text:set_size(w, h)
		one_down_text:set_righttop(pg_text:left() - 10, pg_text:top())
	end

	if managers.skirmish:is_skirmish() then
		self._paygrade_panel:set_visible(false)
		pg_text:set_visible(false)

		local min, max = managers.skirmish:wave_range()
		local wave_range_text = self._foreground_layer_one:text({
			name = "wave_range",
			vertical = "center",
			h = 32,
			align = "right",
			text = managers.localization:to_upper_text("menu_skirmish_wave_range", {
				min = min,
				max = max
			}),
			y = padding_y,
			font_size = content_font_size,
			font = content_font,
			color = tweak_data.screen_colors.skirmish_color
		})

		managers.hud:make_fine_text(wave_range_text)
		wave_range_text:set_right(self._background_layer_one:w())
	end

	self._job_schedule_panel = self._background_layer_one:panel({
		h = 70,
		w = self._background_layer_one:w() / 2
	})

	self._job_schedule_panel:set_right(self._foreground_layer_one:w())
	self._job_schedule_panel:set_top(padding_y + content_font_size + 15)

	if interupt_stage then
		self._job_schedule_panel:set_alpha(0.2)

		if not tweak_data.levels[interupt_stage].bonus_escape then
			self._interupt_panel = self._background_layer_one:panel({
				h = 125,
				w = self._background_layer_one:w() / 2
			})
			local interupt_text = self._interupt_panel:text({
				name = "job_text",
				vertical = "top",
				h = 80,
				font_size = 70,
				align = "left",
				layer = 5,
				text = utf8.to_upper(managers.localization:text("menu_escape")),
				font = bg_font,
				color = tweak_data.screen_colors.important_1
			})
			local _, _, w, h = interupt_text:text_rect()

			interupt_text:set_size(w, h)
			interupt_text:rotate(-15)
			interupt_text:set_center(self._interupt_panel:w() / 2, self._interupt_panel:h() / 2)
			self._interupt_panel:set_shape(self._job_schedule_panel:shape())
		end
	end

	local num_stages = self._current_job_chain and #self._current_job_chain or 0
	local day_color = tweak_data.screen_colors.item_stage_1
	local chain = self._current_job_chain and self._current_job_chain or {}
	local js_w = self._job_schedule_panel:w() / 7
	local js_h = self._job_schedule_panel:h()

	for i = 1, 7 do
		local day_font = text_font
		local day_font_size = text_font_size
		day_color = tweak_data.screen_colors.item_stage_1

		if num_stages < i then
			day_color = tweak_data.screen_colors.item_stage_3
		elseif i == managers.job:current_stage() then
			day_font = content_font
			day_font_size = content_font_size
		end

		local day_text = self._job_schedule_panel:text({
			vertical = "center",
			align = "center",
			blend_mode = "add",
			name = "day_" .. tostring(i),
			text = utf8.to_upper(managers.localization:text("menu_day_short", {
				day = tostring(i)
			})),
			font_size = day_font_size,
			font = day_font,
			w = js_w,
			h = js_h,
			color = day_color
		})

		day_text:set_left(i == 1 and 0 or self._job_schedule_panel:child("day_" .. tostring(i - 1)):right())

		local ghost = self._job_schedule_panel:bitmap({
			texture = "guis/textures/pd2/cn_minighost",
			h = 16,
			blend_mode = "add",
			w = 16,
			name = "ghost_" .. tostring(i),
			color = tweak_data.screen_colors.ghost_color
		})

		ghost:set_center(day_text:center_x(), day_text:center_y() + day_text:h() * 0.25)

		local ghost_visible = i <= num_stages and managers.job:is_job_stage_ghostable(managers.job:current_real_job_id(), i)

		ghost:set_visible(ghost_visible)

		if ghost_visible then
			self:_apply_ghost_color(ghost, i, not Network:is_server())
		end
	end

	local stage_crossed_icon = {
		texture = "guis/textures/pd2/mission_briefing/calendar_xo",
		texture_rect = {
			0,
			0,
			80,
			64
		}
	}
	local stage_circled_icon = {
		texture = "guis/textures/pd2/mission_briefing/calendar_xo",
		texture_rect = {
			80,
			0,
			80,
			64
		}
	}

	for i = 1, managers.job:current_stage() or 0 do
		local icon = i == managers.job:current_stage() and stage_circled_icon or stage_crossed_icon
		local stage_marker = self._job_schedule_panel:bitmap({
			h = 64,
			layer = 1,
			w = 80,
			name = "stage_done_" .. tostring(i),
			texture = icon.texture,
			texture_rect = icon.texture_rect,
			rotation = math.rand(-10, 10)
		})

		stage_marker:set_center(self._job_schedule_panel:child("day_" .. tostring(i)):center())
		stage_marker:move(math.random(4) - 2, math.random(4) - 2)
	end

	if managers.job:has_active_job() then
		local payday_stamp = self._job_schedule_panel:bitmap({
			texture = "guis/textures/pd2/mission_briefing/calendar_xo",
			name = "payday_stamp",
			h = 64,
			layer = 2,
			w = 96,
			texture_rect = {
				160,
				0,
				96,
				64
			},
			rotation = math.rand(-5, 5)
		})

		payday_stamp:set_center(self._job_schedule_panel:child("day_" .. tostring(num_stages)):center())
		payday_stamp:move(math.random(4) - 2 - 7, math.random(4) - 2 + 8)

		if payday_stamp:rotation() == 0 then
			payday_stamp:set_rotation(1)
		end
	end

	local job_overview_text = self._foreground_layer_one:text({
		name = "job_overview_text",
		vertical = "bpttom",
		align = "left",
		text = utf8.to_upper(managers.localization:text("menu_job_overview")),
		h = content_font_size,
		font_size = content_font_size,
		font = content_font,
		color = tweak_data.screen_colors.text
	})
	local _, _, w, h = job_overview_text:text_rect()

	job_overview_text:set_size(w, h)
	job_overview_text:set_leftbottom(self._job_schedule_panel:left(), pg_text:bottom())
	job_overview_text:set_y(math.round(job_overview_text:y()))

	self._job_overview_text = job_overview_text

	self._paygrade_panel:set_center_y(job_overview_text:center_y())
	pg_text:set_center_y(job_overview_text:center_y())
	pg_text:set_y(math.round(pg_text:y()))

	if pg_text:left() <= job_overview_text:right() + 15 then
		pg_text:move(0, -pg_text:h())
		self._paygrade_panel:move(0, -pg_text:h())
	end

	local text = utf8.to_upper(managers.localization:text(self._current_contact_data.name_id) .. ": " .. managers.localization:text(self._current_job_data.name_id))
	local text_align, text_len = nil

	if managers.crime_spree:is_active() then
		local level_id = Global.game_settings.level_id
		local name_id = level_id and tweak_data.levels[level_id] and tweak_data.levels[level_id].name_id
		local mission = managers.crime_spree:get_mission()
		text = managers.localization:to_upper_text(name_id) .. ": "
		text_len = utf8.len(text)
		text = text .. "+" .. managers.localization:text("menu_cs_level", {
			level = mission and mission.add or 0
		})
		text_align = "right"
	end

	if managers.skirmish:is_skirmish() then
		if managers.skirmish:is_weekly_skirmish() then
			text = managers.localization:to_upper_text("menu_weekly_skirmish")
		else
			text = managers.localization:to_upper_text("menu_skirmish")
		end
	end

	local job_text = self._foreground_layer_one:text({
		vertical = "top",
		name = "job_text",
		text = text,
		align = text_align or "left",
		font_size = title_font_size,
		font = title_font,
		color = tweak_data.screen_colors.text
	})

	if managers.crime_spree:is_active() then
		job_text:set_range_color(text_len, utf8.len(text), tweak_data.screen_colors.crime_spree_risk)
	end

	if not text_align then
		local big_text = self._background_layer_three:text({
			vertical = "top",
			name = "job_text",
			alpha = 0.4,
			text = text,
			align = text_align or "left",
			font_size = bg_font_size,
			font = bg_font,
			color = tweak_data.screen_colors.button_stage_1
		})

		big_text:set_world_center_y(self._foreground_layer_one:child("job_text"):world_center_y())
		big_text:set_world_x(self._foreground_layer_one:child("job_text"):world_x())
		big_text:move(-13, 9)
		self._backdrop:animate_bg_text(big_text)
	end

	if managers.job:current_job_data().name_id == "heist_rvd" then
		local day_1_text = self._job_schedule_panel:child("day_1")
		local day_1_sticker = self._job_schedule_panel:bitmap({
			texture = "guis/dlcs/rvd/textures/pd2/mission_briefing/day2",
			h = 48,
			w = 96,
			rotation = 360,
			layer = 2
		})

		day_1_sticker:set_center(day_1_text:center())
		day_1_sticker:move(math.random(4) - 2, math.random(4) - 2)

		local day_2_text = self._job_schedule_panel:child("day_2")
		local day_2_sticker = self._job_schedule_panel:bitmap({
			texture = "guis/dlcs/rvd/textures/pd2/mission_briefing/day1",
			h = 48,
			w = 96,
			rotation = 360,
			layer = 2
		})

		day_2_sticker:set_center(day_2_text:center())
		day_2_sticker:move(math.random(4) - 2, math.random(4) - 2)
	end

	if managers.crime_spree:is_active() then
		self._paygrade_panel:set_visible(false)
		self._job_schedule_panel:set_visible(false)
		self._paygrade_text:set_visible(false)
		self._job_overview_text:set_visible(false)
	end

	if managers.skirmish:is_skirmish() then
		self._job_schedule_panel:set_visible(false)

		self._skirmish_progress = SkirmishBriefingProgress:new(self._background_layer_one, {
			x = self._job_schedule_panel:x(),
			y = self._job_schedule_panel:y(),
			w = self._job_schedule_panel:width(),
			h = self._job_schedule_panel:height()
		})
	end
end

function HUDMissionBriefing:_apply_ghost_color(ghost, i, is_unknown)
	local accumulated_ghost_bonus = managers.job:get_accumulated_ghost_bonus()
	local agb = accumulated_ghost_bonus and accumulated_ghost_bonus[i]

	if is_unknown then
		ghost:set_color(Color(64, 255, 255, 255) / 255)
	elseif i == managers.job:current_stage() then
		if not managers.groupai or not managers.groupai:state():whisper_mode() then
			ghost:set_color(Color(255, 255, 51, 51) / 255)
		else
			ghost:set_color(Color(128, 255, 255, 255) / 255)
		end
	elseif agb and agb.ghost_success then
		ghost:set_color(tweak_data.screen_colors.ghost_color)
	elseif i < managers.job:current_stage() then
		ghost:set_color(Color(255, 255, 51, 51) / 255)
	else
		ghost:set_color(Color(128, 255, 255, 255) / 255)
	end
end

function HUDMissionBriefing:on_whisper_mode_changed()
	if alive(self._job_schedule_panel) then
		local i = managers.job:current_stage() or 1
		local ghost_icon = self._job_schedule_panel:child("ghost_" .. tostring(i))

		if alive(ghost_icon) then
			self:_apply_ghost_color(ghost_icon, i)
		end
	end
end

function HUDMissionBriefing:hide()
	self._backdrop:hide()

	if alive(self._background_layer_two) then
		self._background_layer_two:clear()
	end
end

function HUDMissionBriefing:show()
	print("SHOW")
	self._backdrop:show()
end

function HUDMissionBriefing:inside_slot(peer_id, child, x, y)
	local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))

	if not slot or not alive(slot) then
		return nil
	end

	local object = slot:child(child)

	if not object or not alive(object) then
		return nil
	end

	if not slot:child("status") or not alive(slot:child("status")) or not slot:child("status"):visible() then
		return
	end

	return object:inside(x, y)
end

function HUDMissionBriefing:set_player_slot(nr, params)
	print("set_player_slot( nr, params )", nr, params)

	local slot = self._ready_slot_panel:child("slot_" .. tostring(nr))

	if not slot or not alive(slot) then
		return
	end

	slot:child("status"):stop()
	slot:child("status"):set_alpha(1)
	slot:child("status"):set_color(slot:child("status"):color():with_alpha(1))
	slot:child("status"):set_font_size(tweak_data.menu.pd2_small_font_size)
	slot:child("name"):set_color(slot:child("name"):color():with_alpha(1))
	slot:child("name"):set_text(params.name)
	slot:child("criminal"):set_color(slot:child("criminal"):color():with_alpha(1))
	slot:child("criminal"):set_text(managers.localization:to_upper_text("menu_" .. tostring(params.character)))

	local name_len = utf8.len(slot:child("name"):text())
	local color_range_offset = name_len + 2
	local experience, color_ranges = managers.experience:gui_string(params.level, params.rank, color_range_offset)

	slot:child("name"):set_text(slot:child("name"):text() .. " (" .. experience .. ")  ")

	for _, color_range in ipairs(color_ranges or {}) do
		slot:child("name"):set_range_color(color_range.start, color_range.stop, color_range.color)
	end

	if params.rank > 0 then
		local texture, texture_rect = managers.experience:rank_icon_data(params.rank)

		slot:child("infamy"):set_image(texture, unpack(texture_rect))
		slot:child("infamy"):set_visible(true)
		slot:child("name"):set_x(slot:child("infamy"):right())
	else
		slot:child("infamy"):set_visible(false)
	end

	if params.status then
		slot:child("status"):set_text(params.status)
	end
end

function HUDMissionBriefing:set_slot_joining(peer, peer_id)
	print("set_slot_joining( peer, peer_id )", peer, peer_id)

	local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))

	if not slot or not alive(slot) then
		return
	end

	slot:child("voice"):set_visible(false)
	slot:child("infamy"):set_visible(false)
	slot:child("status"):stop()
	slot:child("status"):set_alpha(1)
	slot:child("status"):set_color(slot:child("status"):color():with_alpha(1))
	slot:child("criminal"):set_color(slot:child("criminal"):color():with_alpha(1))
	slot:child("criminal"):set_text(managers.localization:to_upper_text("menu_" .. tostring(peer:character())))
	slot:child("name"):set_text(peer:name() .. "  ")
	slot:child("status"):set_visible(true)
	slot:child("status"):set_text(managers.localization:text("menu_waiting_is_joining"))
	slot:child("status"):set_font_size(tweak_data.menu.pd2_small_font_size)

	local function animate_joining(o)
		local t = 0

		while true do
			t = (t + coroutine.yield()) % 1

			o:set_alpha(0.3 + 0.7 * math.sin(t * 180))
		end
	end

	slot:child("status"):animate(animate_joining)
end

function HUDMissionBriefing:set_slot_ready(peer, peer_id)
	print("set_slot_ready( peer, peer_id )", peer, peer_id)

	local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))

	if not slot or not alive(slot) then
		return
	end

	slot:child("status"):stop()
	slot:child("status"):set_blend_mode("add")
	slot:child("status"):set_visible(true)
	slot:child("status"):set_alpha(1)
	slot:child("status"):set_color(slot:child("status"):color():with_alpha(1))
	slot:child("status"):set_text(managers.localization:text("menu_waiting_is_ready"))
	slot:child("status"):set_font_size(tweak_data.menu.pd2_small_font_size)

	local is_local = managers.network:session():local_peer():id() == peer_id

	if is_local then
		managers.music:stop_listen_all()
	end

	managers.menu_component:flash_ready_mission_briefing_gui()
end

function HUDMissionBriefing:set_slot_not_ready(peer, peer_id)
	print("set_slot_not_ready( peer, peer_id )", peer, peer_id)

	local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))

	if not slot or not alive(slot) then
		return
	end

	slot:child("status"):stop()
	slot:child("status"):set_visible(true)
	slot:child("status"):set_alpha(1)
	slot:child("status"):set_color(slot:child("status"):color():with_alpha(1))
	slot:child("status"):set_text(managers.localization:text("menu_waiting_is_not_ready"))
	slot:child("status"):set_font_size(tweak_data.menu.pd2_small_font_size)
end

function HUDMissionBriefing:set_dropin_progress(peer_id, progress_percentage, mode)
	local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))

	if not slot or not alive(slot) then
		return
	end

	slot:child("status"):stop()
	slot:child("status"):set_visible(true)
	slot:child("status"):set_alpha(1)

	local status_text = mode == "join" and "menu_waiting_is_joining" or "debug_loading_level"

	slot:child("status"):set_text(utf8.to_upper(managers.localization:text(status_text) .. " " .. tostring(progress_percentage) .. "%"))
	slot:child("status"):set_font_size(tweak_data.menu.pd2_small_font_size)
end

function HUDMissionBriefing:set_kit_selection(peer_id, category, id, slot)
	print("set_kit_selection( peer_id, category, id, slot )", peer_id, category, id, slot)
end

function HUDMissionBriefing:set_slot_outfit(peer_id, criminal_name, outfit)
	local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))

	if not slot or not alive(slot) then
		return
	end

	if managers.network:session() and not managers.network:session():peer(peer_id) then
		return
	end

	local detection, reached = managers.blackmarket:get_suspicion_offset_of_outfit_string(outfit, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
	local detection_panel = slot:child("detection")

	detection_panel:child("detection_left"):set_color(Color(0.5 + detection * 0.5, 1, 1))
	detection_panel:child("detection_right"):set_color(Color(0.5 + detection * 0.5, 1, 1))
	detection_panel:set_visible(true)
	slot:child("detection_value"):set_visible(detection_panel:visible())
	slot:child("detection_value"):set_text(math.round(detection * 100))

	if reached then
		slot:child("detection_value"):set_color(Color(255, 255, 42, 0) / 255)
	else
		slot:child("detection_value"):set_color(tweak_data.screen_colors.text)
	end
end

function HUDMissionBriefing:set_slot_voice(peer, peer_id, active)
	print("set_slot_voice( peer, peer_id, active )", peer, peer_id, active)

	local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))

	if not slot or not alive(slot) then
		return
	end

	slot:child("voice"):set_visible(active)
end

function HUDMissionBriefing:remove_player_slot_by_peer_id(peer, reason)
	print("remove_player_slot_by_peer_id( peer, reason )", peer, reason)

	local slot = self._ready_slot_panel:child("slot_" .. tostring(peer:id()))

	if not slot or not alive(slot) then
		return
	end

	slot:child("status"):stop()
	slot:child("status"):set_alpha(1)
	slot:child("criminal"):set_text("")
	slot:child("name"):set_text(utf8.to_upper(managers.localization:text("menu_lobby_player_slot_available")))
	slot:child("status"):set_text("")
	slot:child("status"):set_visible(false)
	slot:child("voice"):set_visible(false)
	slot:child("status"):set_font_size(tweak_data.menu.pd2_small_font_size)
	slot:child("name"):set_x(slot:child("infamy"):x())
	slot:child("infamy"):set_visible(false)
	slot:child("detection"):set_visible(false)
	slot:child("detection_value"):set_visible(slot:child("detection"):visible())
end

function HUDMissionBriefing:update_layout()
	self._backdrop:_set_black_borders()
end

function HUDMissionBriefing:reload()
	self._backdrop:close()

	self._backdrop = nil

	HUDMissionBriefing.init(self, self._hud, self._workspace)
end
