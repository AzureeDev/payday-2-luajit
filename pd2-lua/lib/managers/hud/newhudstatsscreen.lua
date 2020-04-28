local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local tiny_font = tweak_data.menu.pd2_tiny_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local tiny_font_size = tweak_data.menu.pd2_tiny_font_size
HudTrackedAchievement = HudTrackedAchievement or class(GrowPanel)

function HudTrackedAchievement:init(parent, id, black_bg)
	HudTrackedAchievement.super.init(self, parent, {
		border = 10,
		padding = 4,
		fixed_w = parent:w()
	})

	self._info = managers.achievment:get_info(id)
	self._visual = tweak_data.achievement.visual[id]
	self._progress = self._visual and self._visual.progress
	local placer = self:placer()
	local texture, texture_rect = tweak_data.hud_icons:get_icon_or(self._visual.icon_id, "guis/dlcs/unfinished/textures/placeholder")
	local bitmap = placer:add_bottom(self:bitmap({
		w = 50,
		h = 50,
		texture = texture,
		texture_rect = texture_rect
	}))
	local awarded = self._info.awarded

	if not awarded then
		bitmap:set_color(Color.white:with_alpha(0.1))
		self._panel:bitmap({
			texture = "guis/dlcs/trk/textures/pd2/lock",
			w = bitmap:w(),
			h = bitmap:h(),
			x = bitmap:x(),
			y = bitmap:y()
		})
	end

	local title_text = managers.localization:text(self._visual.name_id)
	local desc_text = managers.localization:text(self._visual.desc_id)

	placer:add_right(self:fine_text({
		text = title_text,
		font = medium_font,
		font_size = medium_font_size
	}))

	local desc = self:text({
		wrap = true,
		word_wrap = true,
		text = desc_text,
		font = tiny_font,
		font_size = tiny_font_size,
		color = tweak_data.screen_colors.achievement_grey,
		w = self:row_w() - placer:current_left()
	})

	self.limit_text_rows(desc, 2)
	placer:add_bottom(self.make_fine_text(desc), 0)

	if self._progress then
		self._bar = placer:add_bottom(TextProgressBar:new(self, {
			w = 300,
			h = 10,
			back_color = Color(255, 60, 60, 65) / 255,
			max = type(self._progress.max) == "function" and self._progress:max() or self._progress.max
		}, {
			font_size = 12,
			font = tiny_font
		}, self._progress:get()))
	end

	if black_bg then
		self:rect({
			layer = -1,
			color = Color.black:with_alpha(0.6)
		})
	end
end

function HudTrackedAchievement:update_progress()
	if self._bar then
		if self._info.awarded then
			local max = type(self._progress.max) == "function" and self._progress:max() or self._progress.max

			self._bar:set_progress(max)
		else
			self._bar:set_progress(self._progress:get())
		end
	end
end

HUDStatsScreen = HUDStatsScreen or class(ExtendedPanel)

function HUDStatsScreen:init()
	HUDStatsScreen.super.init(self, managers.hud:script(managers.hud.STATS_SCREEN_FULLSCREEN).panel, {
		use_given = true
	})
	self:clear()

	local padding = 10
	self._leftpos = {
		padding,
		padding
	}
	self._rightpos = {
		self:w() - padding,
		padding
	}
	self._left = ExtendedPanel:new(self, {
		w = self:w() / 3 - padding * 2,
		h = self:h() - padding * 2
	})
	self._right = ExtendedPanel:new(self, {
		w = self._left:w(),
		h = self._left:h()
	})
	self._bottom = self:panel()

	self._left:set_righttop(self:left(), self._leftpos[2])
	self._right:set_lefttop(self:right(), self._rightpos[2])
	self:recreate_left()
	self:recreate_right()
end

function HUDStatsScreen:recreate_left()
	self._left:clear()
	self._left:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "grow",
		w = self._left:w(),
		h = self._left:h()
	})

	local lb = HUDBGBox_create(self._left, {}, {
		blend_mode = "normal",
		color = Color.white
	})

	lb:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
	lb:child("bg"):set_alpha(1)

	local placer = UiPlacer:new(10, 10, 0, 8)
	local job_data = managers.job:current_job_data()
	local stage_data = managers.job:current_stage_data()

	if job_data and managers.job:current_job_id() == "safehouse" and Global.mission_manager.saved_job_values.playedSafeHouseBefore then
		self._left:set_visible(false)

		return
	end

	local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()

	if stage_data then
		if managers.crime_spree:is_active() then
			local level_data = managers.job:current_level_data()
			local mission = managers.crime_spree:get_mission(managers.crime_spree:current_played_mission())

			if mission then
				local level_str = managers.localization:to_upper_text(tweak_data.levels[mission.level.level_id].name_id) or ""

				placer:add_row(self._left:fine_text({
					font = large_font,
					font_size = tweak_data.hud_stats.objectives_title_size,
					text = level_str
				}))
			end

			placer:add_row(self._left:fine_text({
				font = medium_font,
				font_size = tweak_data.hud_stats.loot_size,
				text = managers.localization:to_upper_text("menu_lobby_difficulty_title"),
				color = tweak_data.screen_colors.text
			}), 8, 0)

			local str = managers.localization:text("menu_cs_level", {
				level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")
			})

			placer:add_right(self._left:fine_text({
				font = medium_font,
				font_size = tweak_data.hud_stats.loot_size,
				text = str,
				color = tweak_data.screen_colors.crime_spree_risk
			}))
		else
			local job_chain = managers.job:current_job_chain_data()
			local day = managers.job:current_stage()
			local days = job_chain and #job_chain or 0
			local day_title = placer:add_bottom(self._left:fine_text({
				font = tweak_data.hud_stats.objectives_font,
				font_size = tweak_data.hud_stats.loot_size,
				text = managers.localization:to_upper_text("hud_days_title", {
					DAY = day,
					DAYS = days
				})
			}))

			if managers.job:is_level_ghostable(managers.job:current_level_id()) then
				local ghost_color = is_whisper_mode and Color.white or tweak_data.screen_colors.important_1
				local ghost = placer:add_right(self._left:bitmap({
					texture = "guis/textures/pd2/cn_minighost",
					name = "ghost_icon",
					h = 16,
					blend_mode = "add",
					w = 16,
					color = ghost_color
				}))

				ghost:set_center_y(day_title:center_y())
			end

			placer:new_row(8)

			local level_data = managers.job:current_level_data()

			if level_data then
				placer:add_bottom(self._left:fine_text({
					font = large_font,
					font_size = tweak_data.hud_stats.objectives_title_size,
					text = managers.localization:to_upper_text(level_data.name_id)
				}))
			end

			placer:add_bottom(self._left:fine_text({
				font = medium_font,
				font_size = tweak_data.hud_stats.loot_size,
				text = managers.localization:to_upper_text("menu_lobby_difficulty_title"),
				color = tweak_data.screen_colors.text
			}), 0)

			if job_data then
				local job_stars = managers.job:current_job_stars()
				local difficulty_stars = managers.job:current_difficulty_stars()
				local difficulty = tweak_data.difficulties[difficulty_stars + 2] or 1
				local difficulty_string = managers.localization:to_upper_text(tweak_data.difficulty_name_ids[difficulty])
				local difficulty_text = self._left:fine_text({
					font = medium_font,
					font_size = tweak_data.hud_stats.loot_size,
					text = difficulty_string,
					color = difficulty_stars > 0 and tweak_data.screen_colors.risk or tweak_data.screen_colors.text
				})

				if Global.game_settings.one_down then
					local one_down_string = managers.localization:to_upper_text("menu_one_down")

					difficulty_text:set_text(difficulty_string .. " " .. one_down_string)
					difficulty_text:set_range_color(#difficulty_string + 1, math.huge, tweak_data.screen_colors.one_down)
				end

				local _, _, tw, th = difficulty_text:text_rect()

				difficulty_text:set_size(tw, th)
				placer:add_right(difficulty_text)
			end

			placer:new_row(8, 0)

			local payout = managers.localization:text("hud_day_payout", {
				MONEY = managers.experience:cash_string(managers.money:get_potential_payout_from_current_stage())
			})

			placer:add_bottom(self._left:fine_text({
				keep_w = true,
				font = tweak_data.hud_stats.objectives_font,
				font_size = tweak_data.hud_stats.loot_size,
				text = payout
			}), 0)
		end

		placer:new_row()
	end

	placer:add_bottom(self._left:fine_text({
		vertical = "top",
		align = "left",
		font_size = tweak_data.hud_stats.objectives_title_size,
		font = tweak_data.hud_stats.objectives_font,
		text = managers.localization:to_upper_text("hud_objective")
	}), 16)
	placer:new_row(8)

	local row_w = self._left:w() - placer:current_left() * 2

	for i, data in pairs(managers.objectives:get_active_objectives()) do
		placer:add_bottom(self._left:fine_text({
			word_wrap = true,
			wrap = true,
			align = "left",
			text = utf8.to_upper(data.text),
			font = tweak_data.hud.medium_font,
			font_size = tweak_data.hud.active_objective_title_font_size,
			w = row_w
		}))
		placer:add_bottom(self._left:fine_text({
			word_wrap = true,
			wrap = true,
			font_size = 24,
			align = "left",
			text = data.description,
			font = tweak_data.hud_stats.objective_desc_font,
			w = row_w
		}), 0)
	end

	local loot_panel = ExtendedPanel:new(self._left, {
		w = self._left:w() - 16 - 8
	})
	placer = UiPlacer:new(16, 0, 8, 4)

	if not is_whisper_mode and managers.player:has_category_upgrade("player", "convert_enemies") then
		local minion_text = placer:add_bottom(loot_panel:fine_text({
			keep_w = true,
			text = managers.localization:text("hud_stats_enemies_converted"),
			font = medium_font,
			font_size = medium_font_size
		}))

		placer:add_right(nil, 0)

		local minion_texture, minion_rect = tweak_data.hud_icons:get_icon_data("minions_converted")
		local minion_icon = placer:add_left(loot_panel:fit_bitmap({
			w = 17,
			h = 17,
			texture = minion_texture,
			texture_rect = minion_rect
		}))

		minion_icon:set_center_y(minion_text:center_y())
		placer:add_left(loot_panel:fine_text({
			text = tostring(managers.player:num_local_minions()),
			font = medium_font,
			font_size = medium_font_size
		}), 7)
		placer:new_row()
	end

	if is_whisper_mode then
		local pagers_used = managers.groupai:state():get_nr_successful_alarm_pager_bluffs()
		local max_pagers_data = managers.player:has_category_upgrade("player", "corpse_alarm_pager_bluff") and tweak_data.player.alarm_pager.bluff_success_chance_w_skill or tweak_data.player.alarm_pager.bluff_success_chance
		local max_num_pagers = #max_pagers_data

		for i, chance in ipairs(max_pagers_data) do
			if chance == 0 then
				max_num_pagers = i - 1

				break
			end
		end

		local pagers_text = placer:add_bottom(loot_panel:fine_text({
			keep_w = true,
			text = managers.localization:text("hud_stats_pagers_used"),
			font = medium_font,
			font_size = medium_font_size
		}))

		placer:add_right(nil, 0)

		local pagers_texture, pagers_rect = tweak_data.hud_icons:get_icon_data("pagers_used")
		local pagers_icon = placer:add_left(loot_panel:fit_bitmap({
			w = 17,
			h = 17,
			texture = pagers_texture,
			texture_rect = pagers_rect
		}))

		pagers_icon:set_center_y(pagers_text:center_y())
		placer:add_left(loot_panel:fine_text({
			text = tostring(pagers_used) .. "/" .. tostring(max_num_pagers),
			font = medium_font,
			font_size = medium_font_size
		}), 7)
		placer:new_row()
	end

	local mandatory_bags_data = managers.loot:get_mandatory_bags_data()
	local mandatory_amount = mandatory_bags_data and mandatory_bags_data.amount
	local secured_amount = managers.loot:get_secured_mandatory_bags_amount()
	local bonus_amount = managers.loot:get_secured_bonus_bags_amount()
	local bag_text = placer:add_bottom(loot_panel:fine_text({
		keep_w = true,
		text = managers.localization:text("hud_stats_bags_secured"),
		font = medium_font,
		font_size = medium_font_size
	}))

	placer:add_right(nil, 0)

	local bag_texture, bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
	local bag_icon = placer:add_left(loot_panel:fit_bitmap({
		w = 16,
		h = 16,
		texture = bag_texture,
		texture_rect = bag_rect
	}))

	bag_icon:set_center_y(bag_text:center_y())

	if mandatory_amount and mandatory_amount > 0 then
		local str = bonus_amount > 0 and string.format("%d/%d+%d", secured_amount, mandatory_amount, bonus_amount) or string.format("%d/%d", secured_amount, mandatory_amount)

		placer:add_left(loot_panel:fine_text({
			text = str,
			font = medium_font,
			font_size = medium_font_size
		}))
	else
		placer:add_left(loot_panel:fine_text({
			text = tostring(bonus_amount),
			font = medium_font,
			font_size = medium_font_size
		}))
	end

	placer:new_row()

	local body_text = placer:add_bottom(loot_panel:fine_text({
		keep_w = true,
		text = managers.localization:to_upper_text("hud_body_bags"),
		font = medium_font,
		font_size = medium_font_size
	}))

	placer:add_right(nil, 0)

	local body_texture, body_rect = tweak_data.hud_icons:get_icon_data("equipment_body_bag")
	local body_icon = placer:add_left(loot_panel:fit_bitmap({
		w = 17,
		h = 17,
		texture = body_texture,
		texture_rect = body_rect
	}))

	body_icon:set_center_y(body_text:center_y())
	placer:add_left(loot_panel:fine_text({
		text = tostring(managers.player:get_body_bags_amount()),
		font = medium_font,
		font_size = medium_font_size
	}), 7)
	placer:new_row()

	local secured_bags_money = managers.experience:cash_string(managers.money:get_secured_mandatory_bags_money() + managers.money:get_secured_bonus_bags_money())

	placer:add_bottom(loot_panel:fine_text({
		keep_w = true,
		text_id = "hud_stats_bags_secured_value",
		font = medium_font,
		font_size = medium_font_size
	}), 12)
	placer:add_right(nil, 0)
	placer:add_left(loot_panel:fine_text({
		text = secured_bags_money,
		font = medium_font,
		font_size = medium_font_size
	}))
	placer:new_row()

	local instant_cash = managers.experience:cash_string(managers.loot:get_real_total_small_loot_value())

	placer:add_bottom(loot_panel:fine_text({
		keep_w = true,
		text = managers.localization:to_upper_text("hud_instant_cash"),
		font = medium_font,
		font_size = medium_font_size
	}))
	placer:add_right(nil, 0)
	placer:add_left(loot_panel:fine_text({
		text = instant_cash,
		font = medium_font,
		font_size = medium_font_size
	}))
	loot_panel:set_size(placer:most_rightbottom())
	loot_panel:set_leftbottom(0, self._left:h() - 16)
end

function HUDStatsScreen:recreate_right()
	self._right:clear()
	self._right:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "grow",
		w = self._right:w(),
		h = self._right:h()
	})

	local rb = HUDBGBox_create(self._right, {}, {
		blend_mode = "normal",
		color = Color.white
	})

	rb:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
	rb:child("bg"):set_alpha(1)

	if managers.mutators:are_mutators_active() then
		self:_create_mutators_list(self._right)
	else
		self:_create_tracked_list(self._right)
	end

	local track_text = self._right:fine_text({
		text = managers.localization:to_upper_text("menu_es_playing_track") .. " " .. managers.music:current_track_string(),
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.text
	})

	track_text:set_leftbottom(10, self._right:h() - 10)
end

function HUDStatsScreen:_create_tracked_list(panel)
	local placer = UiPlacer:new(10, 10, 0, 8)

	placer:add_bottom(self._right:fine_text({
		text_id = "hud_stats_tracked",
		font = large_font,
		font_size = tweak_data.hud_stats.objectives_title_size
	}))

	local tracked = managers.achievment:get_tracked_fill()

	if #tracked == 0 then
		placer:add_bottom(self._right:fine_text({
			wrap = true,
			word_wrap = true,
			text_id = "hud_stats_no_tracked",
			font = medium_font,
			font_size = medium_font_size,
			w = self._right:w() - placer:current_left() * 2
		}))
	end

	self._tracked_items = {}
	local placer = UiPlacer:new(0, placer:most().bottom, 0, 0)
	local with_bg = true

	for _, id in pairs(tracked) do
		local t = placer:add_row(HudTrackedAchievement:new(self._right, id, with_bg), 0, 0)

		if t._progress and t._progress.update and table.contains({
			"realtime",
			"second"
		}, t._progress.update) then
			table.insert(self._tracked_items, t)
		end

		with_bg = not with_bg
	end
end

function HUDStatsScreen:_create_mutators_list(panel)
	local placer = UiPlacer:new(10, 10)

	placer:add_bottom(self._right:fine_text({
		text = managers.localization:to_upper_text("menu_mutators"),
		font = large_font,
		font_size = tweak_data.hud_stats.objectives_title_size
	}))

	for i, active_mutator in ipairs(managers.mutators:active_mutators()) do
		placer:add_row(self._right:fine_text({
			text = active_mutator.mutator:name(),
			font = tweak_data.hud_stats.objectives_font,
			font_size = tweak_data.hud_stats.day_description_size
		}), 8, 2)
	end
end

function HUDStatsScreen:hide()
	local left_panel = self._left
	local right_panel = self._right
	local bottom_panel = self._bottom

	left_panel:stop()

	local teammates_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("teammates_panel")
	local objectives_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("objectives_panel")
	local chat_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("chat_panel")

	left_panel:animate(callback(self, self, "_animate_hide_stats_left_panel"), right_panel, bottom_panel, teammates_panel, objectives_panel, chat_panel)
end

function HUDStatsScreen:show()
	self:recreate_left()
	self:recreate_right()

	local safe = managers.hud.STATS_SCREEN_SAFERECT
	local full = managers.hud.STATS_SCREEN_FULLSCREEN

	managers.hud:show(full)

	local left_panel = self._left
	local right_panel = self._right
	local bottom_panel = self._bottom

	left_panel:stop()

	local teammates_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("teammates_panel")
	local objectives_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("objectives_panel")
	local chat_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("chat_panel")

	left_panel:animate(callback(self, self, "_animate_show_stats_left_panel"), right_panel, bottom_panel, teammates_panel, objectives_panel, chat_panel)
end

function HUDStatsScreen:loot_value_updated()
	self:recreate_left()
end

function HUDStatsScreen:on_ext_inventory_changed()
	self:recreate_left()
end

function HUDStatsScreen:_rec_round_object(object)
	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end

	local x, y = object:position()

	object:set_position(math.round(x), math.round(y))
end

function HUDStatsScreen:_animate_show_stats_left_panel(left_panel, right_panel, bottom_panel, teammates_panel, objectives_panel, chat_panel)
	local start_x = left_panel:x()
	local start_a = 1 - start_x / -left_panel:w()
	local TOTAL_T = 0.33 * start_x / -left_panel:w()
	local t = 0

	while TOTAL_T > t do
		local dt = coroutine.yield() * 1 / TimerManager:game():multiplier()
		t = t + dt
		local a = math.lerp(start_a, 1, t / TOTAL_T)

		left_panel:set_alpha(a)
		left_panel:set_x(math.lerp(start_x, self._leftpos[1], t / TOTAL_T))
		right_panel:set_alpha(a)
		right_panel:set_x(right_panel:parent():w() - (left_panel:x() + right_panel:w()))
		bottom_panel:set_alpha(a)
		bottom_panel:set_y(bottom_panel:parent():h() - (left_panel:x() + bottom_panel:h()))

		local a_half = 0.5 + (1 - a) * 0.5

		teammates_panel:set_alpha(a_half)
		objectives_panel:set_alpha(1 - a)
		chat_panel:set_alpha(a_half)
	end

	left_panel:set_lefttop(unpack(self._leftpos))
	left_panel:set_alpha(1)
	teammates_panel:set_alpha(0.5)
	objectives_panel:set_alpha(0)
	chat_panel:set_alpha(0.5)
	right_panel:set_alpha(1)
	right_panel:set_righttop(unpack(self._rightpos))
	bottom_panel:set_alpha(1)
	bottom_panel:set_y(bottom_panel:parent():h() - bottom_panel:h())
	self:_rec_round_object(left_panel)
	self:_rec_round_object(right_panel)
	self:_rec_round_object(bottom_panel)
end

function HUDStatsScreen:_animate_hide_stats_left_panel(left_panel, right_panel, bottom_panel, teammates_panel, objectives_panel, chat_panel)
	local start_x = left_panel:x()
	local start_a = 1 - start_x / -left_panel:w()
	local TOTAL_T = 0.33 * (1 - start_x / -left_panel:w())
	local t = 0

	while TOTAL_T > t do
		local dt = coroutine.yield() * 1 / TimerManager:game():multiplier()
		t = t + dt
		local a = math.lerp(start_a, 0, t / TOTAL_T)

		left_panel:set_alpha(a)
		left_panel:set_x(math.lerp(start_x, -left_panel:w(), t / TOTAL_T))
		right_panel:set_alpha(a)
		right_panel:set_x(right_panel:parent():w() - (left_panel:x() + right_panel:w()))
		bottom_panel:set_alpha(a)
		bottom_panel:set_y(bottom_panel:parent():h() - (left_panel:x() + bottom_panel:h()))

		local a_half = 0.5 + (1 - a) * 0.5

		teammates_panel:set_alpha(a_half)
		objectives_panel:set_alpha(1 - a)
		chat_panel:set_alpha(a_half)
	end

	left_panel:set_x(-left_panel:w())
	left_panel:set_alpha(0)
	teammates_panel:set_alpha(1)
	objectives_panel:set_alpha(1)
	chat_panel:set_alpha(1)
	right_panel:set_alpha(0)
	right_panel:set_x(right_panel:parent():w())
	bottom_panel:set_alpha(0)
	bottom_panel:set_y(bottom_panel:parent():h())
end

function HUDStatsScreen:update(t, dt)
	for _, v in pairs(self._tracked_items or {}) do
		v:update_progress()
	end
end
