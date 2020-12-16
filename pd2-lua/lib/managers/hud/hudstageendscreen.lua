require("lib/managers/menu/MenuBackdropGUI")
require("lib/managers/menu/WalletGuiObject")

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))

	return x, y, w, h
end

HUDPackageUnlockedItem = HUDPackageUnlockedItem or class()
HUDPackageUnlockedItem.MIN_DISPLAYED = 2
HUDPackageUnlockedItem.MAX_DISPLAYED = 2

function HUDPackageUnlockedItem:init(panel, row, params, hud_stage_end_screen)
	local num_unlocks = math.clamp(params.unlocks, HUDPackageUnlockedItem.MIN_DISPLAYED, HUDPackageUnlockedItem.MAX_DISPLAYED)
	self._panel = panel:panel({
		alpha = 0,
		y = 40,
		x = 10,
		w = panel:w() - 20,
		h = panel:h() * 1 / num_unlocks - 15 - 10
	})

	self._panel:move(0, self._panel:h() * (row - 1))

	if HUDPackageUnlockedItem.MAX_DISPLAYED < row then
		self._panel:hide()
	end

	local announcement = params.announcement
	local upgrade = params.upgrade
	local ghost_bonus = params.ghost_bonus
	local gage_assignment = params.gage_assignment
	local challenge_completed = params.challenge_completed
	local tango_mission_completed = params.tango_mission
	local bitmap_texture = "guis/textures/pd2/endscreen/test_icon_package"
	local text_string = ""
	local blend_mode = "normal"
	local post_event = "stinger_new_weapon"
	local wait_time = 0.35

	if announcement then
		bitmap_texture = "guis/textures/pd2/endscreen/announcement"
		text_string = managers.localization:to_upper_text("menu_es_announcement") .. "\n" .. managers.localization:to_upper_text(announcement)
		blend_mode = "add"
	elseif params.skirmish_wave then
		bitmap_texture = "guis/dlcs/skm/textures/pd2/endscreen/announcement_skm"
		local text_id = nil

		if params.success then
			if params.skirmish_wave == select(2, managers.skirmish:wave_range()) then
				text_id = "menu_skirmish_success_all_end_screen"
			else
				text_id = "menu_skirmish_success_end_screen"
			end
		else
			text_id = "menu_skirmish_fail_end_screen"
		end

		text_string = managers.localization:to_upper_text(text_id, {
			wave = params.skirmish_wave
		})

		if managers.skirmish:is_weekly_skirmish() and #managers.skirmish:unclaimed_rewards() > 0 then
			text_string = text_string .. " " .. managers.localization:to_upper_text("menu_skirmish_weekly_reward_end_screen")
		end
	elseif upgrade then
		local upgrade_def = tweak_data.upgrades.definitions[upgrade]

		if upgrade_def then
			local category = Idstring(upgrade_def.category)

			if category == Idstring("weapon") then
				local weapon_id = upgrade_def.weapon_id
				local weapon_name = managers.weapon_factory:get_weapon_name_by_factory_id(upgrade_def.factory_id)
				local weapon_class = managers.localization:text("menu_" .. tweak_data.weapon[upgrade_def.weapon_id].categories[1])
				local weapon_category = managers.localization:text("bm_menu_" .. (tweak_data.weapon[upgrade_def.weapon_id].use_data.selection_index == 2 and "primaries" or "secondaries"))
				bitmap_texture = managers.blackmarket:get_weapon_icon_path(weapon_id, nil)
				text_string = managers.localization:text("menu_es_package_weapon", {
					weapon = utf8.to_upper(weapon_name),
					type = utf8.to_upper(weapon_class),
					category = weapon_category,
					INVENTORY_MENU = managers.localization:text("menu_inventory")
				})
			elseif category == Idstring("armor") then
				local guis_catalog = "guis/"
				local bundle_folder = tweak_data.blackmarket.armors[upgrade_def.armor_id] and tweak_data.blackmarket.armors[upgrade_def.armor_id].texture_bundle_folder

				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/armors/" .. upgrade_def.armor_id
				text_string = managers.localization:text("menu_es_package_armor", {
					armor = managers.localization:to_upper_text(upgrade_def.name_id)
				})
			elseif category == Idstring("grenade") then
				local guis_catalog = "guis/"
				local bundle_folder = tweak_data.blackmarket.projectiles[upgrade] and tweak_data.blackmarket.projectiles[upgrade].texture_bundle_folder

				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/grenades/" .. upgrade
				text_string = managers.localization:text("menu_es_package_projectile", {
					projectile = managers.localization:to_upper_text(tweak_data.blackmarket.projectiles[upgrade].name_id)
				})
			elseif category == Idstring("melee_weapon") then
				local bm_tweak_data = tweak_data.blackmarket.melee_weapons[upgrade]
				local guis_catalog = "guis/"
				local bundle_folder = bm_tweak_data and bm_tweak_data.texture_bundle_folder

				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/melee_weapons/" .. upgrade
				text_string = managers.localization:text("menu_es_package_melee_weapon", {
					melee_weapon = bm_tweak_data and managers.localization:to_upper_text(bm_tweak_data.name_id)
				})
			elseif category == Idstring("rep_upgrade") then
				bitmap_texture = "guis/textures/pd2/endscreen/" .. upgrade_def.category
				text_string = managers.localization:to_upper_text("menu_es_rep_upgrade", {
					point = upgrade_def.value or 2
				})
				blend_mode = "add"

				hud_stage_end_screen:give_skill_points(upgrade_def.value or 2)
			elseif DB:has(Idstring("texture"), "guis/textures/pd2/endscreen/" .. upgrade_def.category) then
				bitmap_texture = "guis/textures/pd2/endscreen/" .. upgrade_def.category
			else
				bitmap_texture = "guis/textures/pd2/endscreen/what_is_this"

				Application:error("[HUDPackageUnlockedItem] Unknown category detected!", upgrade_def.category, category)
			end
		end
	elseif ghost_bonus then
		local on_last_stage = managers.job:on_last_stage()
		bitmap_texture = "guis/textures/pd2/endscreen/stealth_bonus"
		local string_id = on_last_stage and "menu_es_ghost_bonus_job" or "menu_es_ghost_bonus_day"
		text_string = managers.localization:to_upper_text(string_id, {
			bonus = ghost_bonus
		})
		blend_mode = "add"
	elseif gage_assignment then
		local completed, progressed = managers.gage_assignment:get_latest_data()
		bitmap_texture = "guis/dlcs/gage_pack_jobs/textures/pd2/endscreen/gage_assignment"
		blend_mode = "add"
		local string_id = ""

		if table.size(completed) > 0 then
			string_id = "menu_es_gage_assignment_package_complete"
			post_event = "gage_package_win"
			wait_time = 0.6
		else
			string_id = "menu_es_gage_assignment_package"
		end

		text_string = managers.localization:to_upper_text(string_id, {})
	elseif challenge_completed then
		bitmap_texture = "guis/textures/pd2/endscreen/announcement"
		blend_mode = "add"
		text_string = managers.localization:to_upper_text("menu_es_challenge_completed", {})
	elseif tango_mission_completed then
		bitmap_texture = "guis/dlcs/tng/textures/pd2/blackmarket/icons/endscreen_icons/endscreen_gage_modpack"
		blend_mode = "add"
		text_string = managers.localization:to_upper_text("menu_es_tango_completed", {})
	else
		Application:debug("HUDPackageUnlockedItem: Something something unknown")
	end

	local bitmap = self._panel:bitmap({
		texture = bitmap_texture,
		blend_mode = blend_mode
	})
	local tw = bitmap:texture_width()
	local th = bitmap:texture_height()

	if th ~= 0 then
		local ratio = tw / th
		local size = self._panel:h() - 10
		local sw = math.max(size, size * ratio)
		local sh = math.max(size, size / ratio)

		bitmap:set_size(sw, sh)
		bitmap:set_center_x(self._panel:h() - 5)
		bitmap:set_center_y(self._panel:h() / 2)

		local text = self._panel:text({
			word_wrap = true,
			vertical = "center",
			wrap = true,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text,
			text = text_string,
			x = bitmap:right() + 10,
			y = bitmap:top()
		})

		text:grow(-text:x() - 5, -text:y() - 5)

		local _, _, _, h = text:text_rect()

		if text:h() < h then
			text:set_font(tweak_data.menu.pd2_small_font_id)
			text:set_font_size(tweak_data.menu.pd2_small_font_size)
		end

		text:set_position(math.round(text:x()), math.round(text:y()))
		managers.menu_component:make_color_text(text, params.color or tweak_data.screen_colors.ghost_color)
	end

	self._panel:animate(callback(self, self, "create_animation", {
		post_event = post_event,
		wait_time = wait_time
	}))
end

function HUDPackageUnlockedItem:create_animation(params)
	managers.menu_component:post_event(params.post_event)
	wait(params.wait_time or 0.1)
	over(0.13, function (p)
		self._panel:set_alpha(math.lerp(0, 1, p))
	end)
end

function HUDPackageUnlockedItem:destroy_animation()
	over(0.1, function (p)
		self._panel:set_alpha(math.lerp(1, 0.2, p))
	end)
	over(0.3, function (p)
		self._panel:set_alpha(math.lerp(0.2, 0, p))
	end)
	self._panel:parent():remove(self._panel)

	self._panel = nil
end

function HUDPackageUnlockedItem:close()
	if not alive(self._panel) then
		return
	end

	self._panel:stop()
	self._panel:animate(callback(self, self, "destroy_animation"))
end

HUDStageEndScreen = HUDStageEndScreen or class()
local max_speed_up = 5
HUDStageEndScreen.stages = {
	{
		"stage_money_counter_init",
		max_speed_up
	},
	{
		"stage_money_counter_count",
		max_speed_up
	},
	{
		"stage_money_counter_hide",
		max_speed_up
	},
	{
		"safehouse_currency_init",
		max_speed_up
	},
	{
		"safehouse_currency_fade_in",
		max_speed_up
	},
	{
		"safehouse_currency_count",
		max_speed_up
	},
	{
		"safehouse_currency_trophies",
		max_speed_up
	},
	{
		"safehouse_currency_hide",
		max_speed_up
	},
	{
		"stage_experience_init",
		max_speed_up
	},
	{
		"stage_experience_count_exp",
		max_speed_up
	},
	{
		"stage_experience_spin_up",
		max_speed_up
	},
	{
		"stage_experience_show_all",
		max_speed_up
	},
	{
		"stage_experience_spin_levels",
		max_speed_up
	},
	{
		"stage_experience_spin_slowdown",
		max_speed_up
	},
	{
		"stage_experience_end",
		max_speed_up
	},
	{
		"stage_done",
		max_speed_up
	}
}

function HUDStageEndScreen:init(hud, workspace)
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
	local small_font = tweak_data.menu.pd2_small_font
	local bg_font_size = tweak_data.menu.pd2_massive_font_size
	local title_font_size = tweak_data.menu.pd2_large_font_size
	local content_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local massive_font = bg_font
	local large_font = title_font
	local medium_font = content_font
	local massive_font_size = bg_font_size
	local large_font_size = title_font_size
	local medium_font_size = content_font_size
	self._background_layer_safe = self._backdrop:get_new_background_layer()
	self._background_layer_full = self._backdrop:get_new_background_layer()
	self._foreground_layer_safe = self._backdrop:get_new_foreground_layer()
	self._foreground_layer_full = self._backdrop:get_new_foreground_layer()

	self._backdrop:set_panel_to_saferect(self._background_layer_safe)
	self._backdrop:set_panel_to_saferect(self._foreground_layer_safe)

	if managers.job:has_active_job() then
		local current_contact_data = managers.job:current_contact_data()
		local contact_gui = current_contact_data and self._background_layer_full:gui(current_contact_data.assets_gui, {
			empty = true
		})
		local contact_pattern = contact_gui and contact_gui:has_script() and contact_gui:script().pattern

		if contact_pattern then
			self._backdrop:set_pattern(contact_pattern)
		end
	end

	local padding_y = 0
	self._paygrade_panel = self._background_layer_safe:panel({
		w = 210,
		h = 70,
		y = padding_y
	})
	local pg_text = self._foreground_layer_safe:text({
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

	local job_stars = managers.job:has_active_job() and managers.job:current_job_stars() or 1
	local job_and_difficulty_stars = managers.job:has_active_job() and managers.job:current_job_and_difficulty_stars() or 1
	local difficulty_stars = managers.job:has_active_job() and managers.job:current_difficulty_stars() or 0
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

	local panel_w = 0
	local panel_h = 0
	local x = 0
	local y = 0

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
	self._paygrade_panel:set_right(self._background_layer_safe:w())
	pg_text:set_right(self._paygrade_panel:left())
	pg_text:set_center_y(self._paygrade_panel:center_y())
	pg_text:set_y(math.round(pg_text:y()))

	if managers.skirmish:is_skirmish() then
		self._paygrade_panel:set_visible(false)
		pg_text:set_visible(false)

		local min, max = managers.skirmish:wave_range()
		local wave_range_text = self._foreground_layer_safe:text({
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
		wave_range_text:set_right(self._background_layer_safe:w())
	end

	self._stage_name = managers.job:current_level_id() and managers.localization:to_upper_text(tweak_data.levels[managers.job:current_level_id()].name_id) or ""

	if managers.skirmish:is_skirmish() then
		if managers.skirmish:is_weekly_skirmish() then
			self._stage_name = managers.localization:to_upper_text("menu_weekly_skirmish")
		else
			self._stage_name = managers.localization:to_upper_text("menu_skirmish")
		end
	end

	self._foreground_layer_safe:text({
		name = "stage_text",
		vertical = "center",
		align = "left",
		text = self._stage_name,
		h = title_font_size,
		font_size = title_font_size,
		font = title_font,
		color = tweak_data.screen_colors.text
	})

	local bg_text = self._background_layer_full:text({
		name = "stage_text",
		vertical = "top",
		alpha = 0.4,
		align = "left",
		text = self._stage_name,
		h = bg_font_size,
		font_size = bg_font_size,
		font = bg_font,
		color = tweak_data.screen_colors.button_stage_3
	})

	bg_text:set_world_center_y(self._foreground_layer_safe:child("stage_text"):world_center_y())
	bg_text:set_world_x(self._foreground_layer_safe:child("stage_text"):world_x())
	bg_text:move(-13, 9)
	self._backdrop:animate_bg_text(bg_text)

	self._coins_backpanel = self._background_layer_safe:panel({
		name = "coins_backpanel",
		y = 70,
		w = self._background_layer_safe:w() / 2 - 10,
		h = self._background_layer_safe:h() / 2
	})
	self._coins_forepanel = self._foreground_layer_safe:panel({
		name = "coins_forepanel",
		y = 70,
		w = self._foreground_layer_safe:w() / 2 - 10,
		h = self._foreground_layer_safe:h() / 2
	})
	local level_progress_text = self._coins_forepanel:text({
		vertical = "top",
		name = "coin_progress_text",
		align = "left",
		y = 10,
		x = 10,
		text = managers.localization:to_upper_text("menu_es_coins_progress"),
		h = content_font_size + 2,
		font_size = content_font_size,
		font = content_font,
		color = tweak_data.screen_colors.text
	})
	local _, _, lw, lh = level_progress_text:text_rect()

	level_progress_text:set_size(lw, lh)

	local coins_bg_circle = self._coins_backpanel:bitmap({
		texture = "guis/textures/pd2/endscreen/exp_ring",
		name = "bg_progress_circle",
		alpha = 0.6,
		blend_mode = "normal",
		h = self._coins_backpanel:h() - content_font_size,
		w = self._coins_backpanel:h() - content_font_size,
		y = content_font_size,
		color = Color.black
	})
	self._coins_circle = self._coins_backpanel:bitmap({
		texture = "guis/textures/pd2/endscreen/exp_ring",
		name = "progress_circle",
		blend_mode = "add",
		render_template = "VertexColorTexturedRadial",
		layer = 1,
		h = self._coins_backpanel:h() - content_font_size,
		w = self._coins_backpanel:h() - content_font_size,
		y = content_font_size,
		color = Color(0, 1, 1)
	})
	self._coins_text = self._coins_forepanel:text({
		name = "coins_text",
		vertical = "center",
		align = "center",
		text = "",
		font_size = bg_font_size,
		font = bg_font,
		h = self._coins_backpanel:h() - content_font_size,
		w = self._coins_backpanel:h() - content_font_size,
		y = content_font_size,
		color = tweak_data.screen_colors.text
	})
	self._coins_box = BoxGuiObject:new(self._coins_backpanel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self._lp_backpanel = self._background_layer_safe:panel({
		name = "lp_backpanel",
		y = 70,
		w = self._background_layer_safe:w() / 2 - 10,
		h = self._background_layer_safe:h() / 2
	})
	self._lp_forepanel = self._foreground_layer_safe:panel({
		name = "lp_forepanel",
		y = 70,
		w = self._foreground_layer_safe:w() / 2 - 10,
		h = self._foreground_layer_safe:h() / 2
	})
	local level_progress_text = self._lp_forepanel:text({
		vertical = "top",
		name = "level_progress_text",
		align = "left",
		y = 10,
		x = 10,
		text = managers.localization:to_upper_text("menu_es_level_progress"),
		h = content_font_size + 2,
		font_size = content_font_size,
		font = content_font,
		color = tweak_data.screen_colors.text
	})
	local _, _, lw, lh = level_progress_text:text_rect()

	level_progress_text:set_size(lw, lh)

	local lp_bg_circle = self._lp_backpanel:bitmap({
		texture = "guis/textures/pd2/endscreen/exp_ring",
		name = "bg_progress_circle",
		alpha = 0.6,
		blend_mode = "normal",
		h = self._lp_backpanel:h() - content_font_size,
		w = self._lp_backpanel:h() - content_font_size,
		y = content_font_size,
		color = Color.black
	})
	self._lp_circle = self._lp_backpanel:bitmap({
		texture = "guis/textures/pd2/endscreen/exp_ring",
		name = "progress_circle",
		blend_mode = "add",
		render_template = "VertexColorTexturedRadial",
		layer = 1,
		h = self._lp_backpanel:h() - content_font_size,
		w = self._lp_backpanel:h() - content_font_size,
		y = content_font_size,
		color = Color(0, 1, 1)
	})
	self._lp_text = self._lp_forepanel:text({
		name = "level_text",
		vertical = "center",
		align = "center",
		text = "",
		font_size = bg_font_size,
		font = bg_font,
		h = self._lp_backpanel:h() - content_font_size,
		w = self._lp_backpanel:h() - content_font_size,
		y = content_font_size,
		color = tweak_data.screen_colors.text
	})
	self._lp_curr_xp = self._lp_forepanel:text({
		vertical = "top",
		name = "current_xp",
		align = "left",
		text = managers.localization:to_upper_text("menu_es_current_xp"),
		h = small_font_size,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})
	self._lp_xp_gained = self._lp_forepanel:text({
		vertical = "top",
		name = "xp_gained",
		align = "left",
		text = managers.localization:to_upper_text("menu_es_xp_gained"),
		h = content_font_size,
		font_size = content_font_size,
		font = content_font,
		color = tweak_data.screen_colors.text
	})
	self._lp_next_level = self._lp_forepanel:text({
		vertical = "top",
		name = "next_level",
		align = "left",
		text = managers.localization:to_upper_text("menu_es_next_level"),
		h = small_font_size,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})
	self._lp_skill_points = self._lp_forepanel:text({
		vertical = "top",
		name = "skill_points",
		align = "left",
		text = managers.localization:to_upper_text("menu_es_skill_points_gained"),
		h = small_font_size,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})
	self._lp_xp_curr = self._lp_forepanel:text({
		text = "",
		vertical = "top",
		name = "c_xp",
		align = "left",
		h = small_font_size,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})
	self._lp_xp_gain = self._lp_forepanel:text({
		text = "",
		vertical = "top",
		name = "xp_g",
		align = "left",
		h = content_font_size,
		font_size = content_font_size,
		font = content_font,
		color = tweak_data.screen_colors.text
	})
	self._lp_xp_nl = self._lp_forepanel:text({
		text = "",
		vertical = "top",
		name = "xp_nl",
		align = "left",
		h = small_font_size,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})
	self._lp_sp_gain = self._lp_forepanel:text({
		text = "0",
		vertical = "center",
		name = "sp_g",
		align = "left",
		h = small_font_size,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})
	local _, _, cw, ch = self._lp_curr_xp:text_rect()
	local _, _, gw, gh = self._lp_xp_gained:text_rect()
	local _, _, nw, nh = self._lp_next_level:text_rect()
	local _, _, sw, sh = self._lp_skill_points:text_rect()
	ch = ch - 2
	nh = nh - 2
	sh = sh - 2
	local w = math.ceil(math.max(cw, gw, nw, sw)) + 20
	local squeeze_more_pixels = false

	if w > 170 then
		squeeze_more_pixels = true
	end

	self._num_skill_points_gained = 0
	self._lp_sp_info = self._lp_forepanel:text({
		vertical = "top",
		name = "sp_info",
		wrap = true,
		align = "left",
		word_wrap = true,
		text = managers.localization:text("menu_es_skill_points_info", {
			SKILL_MENU = managers.localization:to_upper_text("menu_skilltree")
		}),
		h = small_font_size,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})

	self._lp_sp_info:grow(-self._lp_circle:right() - 10, 0)

	local _, _, iw, ih = self._lp_sp_info:text_rect()

	self._lp_sp_info:set_h(ih)
	self._lp_sp_info:set_leftbottom(self._lp_circle:right() + 0, self._lp_forepanel:h() - 10)

	local w = self._lp_forepanel:w() - self._lp_sp_info:x() - 90
	local number_text_x = self._lp_sp_info:left() + w

	self._lp_skill_points:set_size(sw, sh)
	self._lp_skill_points:set_left(self._lp_sp_info:left())
	self._lp_skill_points:set_bottom(self._lp_sp_info:top())
	self._lp_sp_gain:set_left(number_text_x)
	self._lp_sp_gain:set_top(self._lp_skill_points:top())
	self._lp_sp_gain:set_size(self._lp_forepanel:w() - self._lp_sp_gain:left() - 10, sh)
	self._lp_next_level:set_size(nw, nh)
	self._lp_next_level:set_left(self._lp_sp_info:left())
	self._lp_next_level:set_bottom(self._lp_skill_points:top())
	self._lp_xp_nl:set_left(number_text_x)
	self._lp_xp_nl:set_top(self._lp_next_level:top())
	self._lp_xp_nl:set_size(self._lp_forepanel:w() - self._lp_xp_nl:left() - 10, nh)
	self._lp_curr_xp:set_size(cw, ch)
	self._lp_curr_xp:set_left(self._lp_sp_info:left())
	self._lp_curr_xp:set_bottom(self._lp_next_level:top())
	self._lp_xp_curr:set_left(number_text_x)
	self._lp_xp_curr:set_top(self._lp_curr_xp:top())
	self._lp_xp_curr:set_size(self._lp_forepanel:w() - self._lp_xp_curr:left() - 10, ch)
	self._lp_xp_gained:set_size(gw, gh)
	self._lp_xp_gained:set_left(self._lp_curr_xp:left())
	self._lp_xp_gained:set_bottom(self._lp_curr_xp:top())
	self._lp_xp_gain:set_left(number_text_x)
	self._lp_xp_gain:set_top(self._lp_xp_gained:top())
	self._lp_xp_gain:set_size(self._lp_forepanel:w() - self._lp_xp_gain:left() - 10, gh)
	self._lp_xp_gained:set_bottom(math.round(self._lp_forepanel:h() / 2))
	self._lp_curr_xp:set_top(self._lp_xp_gained:bottom())
	self._lp_next_level:set_top(self._lp_curr_xp:bottom())
	self._lp_skill_points:set_top(self._lp_next_level:bottom())
	self._lp_sp_info:set_top(self._lp_skill_points:bottom())
	self._lp_xp_gain:set_top(self._lp_xp_gained:top())
	self._lp_xp_curr:set_top(self._lp_curr_xp:top())
	self._lp_xp_nl:set_top(self._lp_next_level:top())
	self._lp_sp_gain:set_top(self._lp_skill_points:top())

	if squeeze_more_pixels then
		lp_bg_circle:move(-20, 0)
		self._lp_circle:move(-20, 0)
		self._lp_text:move(-20, 0)
		self._lp_curr_xp:move(-30, 0)
		self._lp_xp_gained:move(-30, 0)
		self._lp_next_level:move(-30, 0)
		self._lp_skill_points:move(-30, 0)
		self._lp_sp_info:move(-30, 0)
	end

	self._box = BoxGuiObject:new(self._lp_backpanel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	WalletGuiObject.set_wallet(self._foreground_layer_safe)
	WalletGuiObject.hide_wallet()

	self._package_forepanel = self._foreground_layer_safe:panel({
		alpha = 1,
		name = "package_forepanel",
		y = 70,
		w = self._foreground_layer_safe:w() / 2 - 10,
		h = self._foreground_layer_safe:h() / 2 - 70 - 10
	})

	self._package_forepanel:set_right(self._foreground_layer_safe:w())
	self._package_forepanel:text({
		text = "",
		name = "title_text",
		y = 10,
		x = 10,
		font = content_font,
		font_size = content_font_size
	})

	local package_box_panel = self._foreground_layer_safe:panel()

	package_box_panel:set_shape(self._package_forepanel:shape())
	package_box_panel:set_layer(self._package_forepanel:layer())

	self._package_box = BoxGuiObject:new(package_box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self._package_items = {}

	self:clear_stage()

	if self._data then
		self:start_experience_gain()
	end

	for i, child in ipairs(self._lp_forepanel:children()) do
		if child.text then
			local text = child:text()

			child:set_text(string.gsub(text, ":", ""))
		end
	end

	local skip_panel = self._foreground_layer_safe:panel({
		name = "skip_forepanel",
		y = 70,
		w = self._foreground_layer_safe:w() / 2 - 10,
		h = self._foreground_layer_safe:h() / 2
	})
	local macros = {
		BTN_SPEED = managers.localization:btn_macro("menu_challenge_claim", true)
	}

	if not managers.menu:is_pc_controller() then
		macros.BTN_SPEED = managers.localization:get_default_macro("BTN_SWITCH_WEAPON")
	end

	self._skip_text = skip_panel:text({
		name = "skip_text",
		visible = false,
		alpha = 0.5,
		font = small_font,
		font_size = small_font_size,
		text = managers.localization:to_upper_text("menu_stageendscreen_speed_up", macros)
	})

	make_fine_text(self._skip_text)
	self._skip_text:set_right(skip_panel:w() - 10)
	self._skip_text:set_bottom(skip_panel:h() - 10)
end

function HUDStageEndScreen:hide()
	self._backdrop:hide()
end

function HUDStageEndScreen:show()
	self._backdrop:show()
end

function HUDStageEndScreen:update_layout()
	self._backdrop:_set_black_borders()
end

function HUDStageEndScreen:spawn_animation(o, delay, post_event)
	wait(delay or 0)

	if post_event then
		managers.menu_component:post_event(post_event)
	end

	over(0.5, function (p)
		o:set_alpha(p)
	end)
end

function HUDStageEndScreen:destroy_animation(o, delay, speed)
	wait(delay or 0)

	local start_alpha = o:alpha()

	over(0.25 * (speed or 1), function (p)
		o:set_alpha(math.lerp(start_alpha, 0, p))

		if o.children then
			for _, child in ipairs(o:children()) do
				if child.set_color then
					child:set_color(math.lerp(child:color(), tweak_data.screen_colors.text, p))
				else
					for _, object in ipairs(child:children()) do
						object:set_color(math.lerp(object:color(), tweak_data.screen_colors.text, p))
					end
				end
			end
		end
	end)
	o:parent():remove(o)

	o = nil
end

function HUDStageEndScreen:_create_bonus(params)
	local panel = params.panel
	local positive_color = params.positive_color
	local negative_color = params.negative_color
	local color = params.color or params.bonus > 0 and positive_color or negative_color or Color.white
	local positive_title = params.positive_title
	local negative_title = params.negative_title
	local title_string = params.title or params.bonus > 0 and positive_title or negative_title or ""
	local sign_string = params.bonus > 0 and "+ " or "- "
	local stat_string = managers.money:add_decimal_marks_to_string(tostring(math.abs(params.bonus)))
	local bonus_panel = panel:panel({
		layer = 1
	})
	local title_text = bonus_panel:text({
		name = "title",
		text = title_string,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = color
	})
	local sign_text = bonus_panel:text({
		name = "sign",
		text = sign_string,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = color
	})
	local stat_text = bonus_panel:text({
		name = "stat",
		text = stat_string,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = color
	})
	local x = self._lp_xp_gain:x() - panel:x()
	local _, _, _, h = make_fine_text(title_text)

	make_fine_text(sign_text)
	bonus_panel:set_h(h - 4)
	title_text:set_left(0)
	sign_text:set_right(x)
	stat_text:set_left(x)
	stat_text:set_top(title_text:top())
	stat_text:set_w(bonus_panel:w() - x)
	stat_text:set_h(title_text:h())

	for i, child in ipairs(bonus_panel:children()) do
		if child.text then
			local text = child:text()

			child:set_text(string.gsub(text, ":", ""))
		end
	end

	return bonus_panel
end

function HUDStageEndScreen:bonus_risk(panel, delay, bonus)
	local risk_text = panel:text({
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.risk,
		text = managers.localization:to_upper_text("menu_es_risk_bonus")
	})
	local _, _, w, h = risk_text:text_rect()

	risk_text:set_size(w, h)
	panel:set_h(h)

	local has_active_job = managers.job:has_active_job()
	local job_and_difficulty_stars = has_active_job and managers.job:current_job_and_difficulty_stars() or 1
	local job_stars = has_active_job and managers.job:current_job_stars() or 1
	local difficulty_stars = has_active_job and managers.job:current_difficulty_stars() or 0

	panel:animate(callback(self, self, "spawn_animation"), delay, "box_tick")

	local sign_text = panel:text({
		text = "+",
		alpha = 0,
		align = "right",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.risk
	})

	make_fine_text(sign_text)
	sign_text:set_world_right(self._lp_xp_curr:world_left())
	sign_text:animate(callback(self, self, "spawn_animation"), delay, false)

	local value_text = panel:text({
		alpha = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.risk,
		text = managers.money:add_decimal_marks_to_string(tostring(math.abs(bonus)))
	})

	value_text:set_world_left(self._lp_xp_curr:world_left())
	value_text:animate(callback(self, self, "spawn_animation"), delay, false)
	make_fine_text(value_text)

	return delay
end

function HUDStageEndScreen:bonus_days(panel, delay, bonus)
	local text = panel:text({
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		text = managers.localization:to_upper_text("menu_es_day_bonus")
	})
	local _, _, w, h = text:text_rect()

	panel:set_h(h)
	text:set_size(w, h)
	text:set_center_y(panel:h() / 2)
	text:set_position(math.round(text:x()), math.round(text:y()))
	panel:animate(callback(self, self, "spawn_animation"), delay, "box_tick")

	local sign_text = panel:text({
		text = "+",
		alpha = 0,
		align = "right",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(sign_text)
	sign_text:set_world_right(self._lp_xp_curr:world_left())
	sign_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)

	local value_text = panel:text({
		alpha = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		text = managers.money:add_decimal_marks_to_string(tostring(math.abs(bonus)))
	})

	value_text:set_world_left(self._lp_xp_curr:world_left())
	value_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)
	make_fine_text(value_text)

	return delay + 0
end

function HUDStageEndScreen:bonus_skill(panel, delay, bonus)
	local text = panel:text({
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		text = managers.localization:to_upper_text("menu_es_skill_bonus")
	})
	local _, _, w, h = text:text_rect()

	panel:set_h(h)
	text:set_size(w, h)
	text:set_center_y(panel:h() / 2)
	text:set_position(math.round(text:x()), math.round(text:y()))
	panel:animate(callback(self, self, "spawn_animation"), delay, "box_tick")

	local sign_text = panel:text({
		text = "+",
		alpha = 0,
		align = "right",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(sign_text)
	sign_text:set_world_right(self._lp_xp_curr:world_left())
	sign_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)

	local value_text = panel:text({
		alpha = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		text = managers.money:add_decimal_marks_to_string(tostring(math.abs(bonus)))
	})

	value_text:set_world_left(self._lp_xp_curr:world_left())
	value_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)
	make_fine_text(value_text)

	return delay + 0
end

function HUDStageEndScreen:bonus_num_players(panel, delay, bonus)
	local text = panel:text({
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		text = managers.localization:to_upper_text("menu_es_alive_players_bonus")
	})
	local _, _, w, h = text:text_rect()

	panel:set_h(h)
	text:set_size(w, h)
	text:set_center_y(panel:h() / 2)
	text:set_position(math.round(text:x()), math.round(text:y()))
	panel:animate(callback(self, self, "spawn_animation"), delay, "box_tick")

	local sign_text = panel:text({
		text = "+",
		alpha = 0,
		align = "right",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(sign_text)
	sign_text:set_world_right(self._lp_xp_curr:world_left())
	sign_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)

	local value_text = panel:text({
		alpha = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		text = managers.money:add_decimal_marks_to_string(tostring(math.abs(bonus)))
	})

	value_text:set_world_left(self._lp_xp_curr:world_left())
	value_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)
	make_fine_text(value_text)

	return delay + 0
end

function HUDStageEndScreen:bonus_failed(panel, delay, bonus)
	local text = panel:text({
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.important_1,
		text = managers.localization:to_upper_text("menu_es_alive_failed_bonus")
	})
	local _, _, w, h = text:text_rect()

	panel:set_h(h)
	text:set_size(w, h)
	text:set_center_y(panel:h() / 2)
	text:set_position(math.round(text:x()), math.round(text:y()))
	panel:animate(callback(self, self, "spawn_animation"), delay, "box_tick")

	local sign_text = panel:text({
		text = "-",
		alpha = 0,
		align = "right",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.important_1
	})

	make_fine_text(sign_text)
	sign_text:set_world_right(self._lp_xp_curr:world_left())
	sign_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)

	local value_text = panel:text({
		alpha = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.important_1,
		text = managers.money:add_decimal_marks_to_string(tostring(math.abs(bonus)))
	})

	value_text:set_world_left(self._lp_xp_curr:world_left())
	value_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)
	make_fine_text(value_text)

	return delay + 0
end

function HUDStageEndScreen:in_custody(panel, delay, bonus)
	local text = panel:text({
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.important_1,
		text = managers.localization:to_upper_text("menu_es_in_custody_reduction")
	})
	local _, _, w, h = text:text_rect()

	panel:set_h(h)
	text:set_size(w, h)
	text:set_center_y(panel:h() / 2)
	text:set_position(math.round(text:x()), math.round(text:y()))
	panel:animate(callback(self, self, "spawn_animation"), delay, "box_tick")

	local sign_text = panel:text({
		text = "-",
		alpha = 0,
		align = "right",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.important_1
	})

	make_fine_text(sign_text)
	sign_text:set_world_right(self._lp_xp_curr:world_left())
	sign_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)

	local value_text = panel:text({
		alpha = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.important_1,
		text = managers.money:add_decimal_marks_to_string(tostring(math.abs(bonus)))
	})

	value_text:set_world_left(self._lp_xp_curr:world_left())
	value_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)
	make_fine_text(value_text)

	return delay + 0
end

function HUDStageEndScreen:heat_xp(panel, delay, bonus)
	local heat = managers.job:last_known_heat() or managers.job:has_active_job() and managers.job:get_job_heat(managers.job:current_job_id()) or 0
	local heat_color = managers.job:get_heat_color(heat)
	local text = panel:text({
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = heat_color,
		text = managers.localization:to_upper_text(bonus >= 0 and "menu_es_heat_bonus" or "menu_es_heat_reduction")
	})
	local _, _, w, h = text:text_rect()

	panel:set_h(h)
	text:set_size(w, h)
	text:set_center_y(panel:h() / 2)
	text:set_position(math.round(text:x()), math.round(text:y()))
	panel:animate(callback(self, self, "spawn_animation"), delay, "box_tick")

	local prefix = bonus >= 0 and "+" or "-"
	local sign_text = panel:text({
		alpha = 0,
		align = "right",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = heat_color,
		text = prefix
	})

	make_fine_text(sign_text)
	sign_text:set_world_right(self._lp_xp_curr:world_left())
	sign_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)

	local value_text = panel:text({
		alpha = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = heat_color,
		text = managers.money:add_decimal_marks_to_string(tostring(math.abs(bonus)))
	})

	value_text:set_world_left(self._lp_xp_curr:world_left())
	value_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)
	make_fine_text(value_text)

	return delay + 0
end

function HUDStageEndScreen:bonus_low_level(panel, delay, bonus)
	local text = panel:text({
		5,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		text = managers.localization:to_upper_text("menu_es_alive_low_level_bonus")
	})
	local _, _, w, h = text:text_rect()

	panel:set_h(h)
	text:set_size(w, h)
	text:set_center_y(panel:h() / 2)
	text:set_position(math.round(text:x()), math.round(text:y()))
	panel:animate(callback(self, self, "spawn_animation"), delay, "box_tick")

	local sign_text = panel:text({
		text = "-",
		alpha = 0,
		align = "right",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(sign_text)
	sign_text:set_world_right(self._lp_xp_curr:world_left())
	sign_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)

	local value_text = panel:text({
		alpha = 0,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		text = managers.money:add_decimal_marks_to_string(tostring(math.abs(bonus)))
	})

	value_text:set_world_left(self._lp_xp_curr:world_left())
	value_text:animate(callback(self, self, "spawn_animation"), delay + 0, false)
	make_fine_text(value_text)

	return delay + 0
end

function HUDStageEndScreen:start_experience_gain()
	self:reset_stage()
end

function HUDStageEndScreen:clear_stage()
	self._wait_t = nil
	self._csl = nil
	self._all_done = nil
	self._playing_sound = nil

	self._coins_backpanel:child("bg_progress_circle"):hide()
	self._coins_forepanel:child("coin_progress_text"):hide()
	self._lp_text:hide()
	self._lp_circle:hide()
	self._lp_backpanel:child("bg_progress_circle"):hide()
	self._lp_forepanel:child("level_progress_text"):hide()
	self._lp_curr_xp:hide()
	self._lp_xp_gained:hide()
	self._lp_next_level:hide()
	self._lp_skill_points:hide()
	self._lp_sp_info:hide()
	self._lp_xp_gain:hide()
	self._lp_xp_curr:hide()
	self._lp_xp_nl:hide()
	self._lp_sp_gain:hide()
	self._lp_text:set_text(tostring(self._data and self._data.start_t.level or 0))
	self:reset_skill_points()

	self._endgame_setup = false

	if self._background_layer_full:child("money_video") then
		self._background_layer_full:child("money_video"):stop()
		self._background_layer_full:remove(self._background_layer_full:child("money_video"))
	end

	if self._money_panel then
		self._money_panel:parent():remove(self._money_panel)

		self._money_panel = nil
	end

	WalletGuiObject.hide_wallet()
end

function HUDStageEndScreen:_update_skirmish_wave()
	if not managers.skirmish:is_skirmish() then
		return
	end

	local wave = managers.skirmish:current_wave_number()
	local wave_item = HUDPackageUnlockedItem:new(self._package_forepanel, 1, {
		unlocks = 1,
		skirmish_wave = wave,
		color = tweak_data.screen_colors.skirmish_color,
		success = self._success
	}, self)

	for _, item in pairs(self._package_items) do
		item:close()
	end

	self._package_items = {
		wave_item
	}
end

function HUDStageEndScreen:_check_special_packages()
	local ghost_bonus_mul = self._ghost_bonus
	local ghost_string = nil
	local got_ghost = false
	local row = 1
	local ghost_package, gage_package, challenge_completed = nil
	local unlock_count = 0

	if ghost_bonus_mul and ghost_bonus_mul > 0 then
		unlock_count = unlock_count + 1
	end

	if self._tango_mission_completed then
		unlock_count = unlock_count + 1
	end

	if self._gage_assignment then
		unlock_count = unlock_count + 1
	end

	if self._challenge_completed then
		unlock_count = unlock_count + 1
	end

	if ghost_bonus_mul and ghost_bonus_mul > 0 then
		local ghost_bonus = math.round(ghost_bonus_mul * 100)

		if ghost_bonus == 0 then
			ghost_string = string.format("%0.2f", math.abs(ghost_bonus_mul * 100))
		else
			ghost_string = tostring(math.abs(ghost_bonus))
		end

		ghost_package = HUDPackageUnlockedItem:new(self._package_forepanel, row, {
			ghost_bonus = ghost_string,
			unlocks = unlock_count
		}, self)
		row = row + 1
	end

	local tango_completed = nil

	if self._tango_mission_completed then
		tango_completed = HUDPackageUnlockedItem:new(self._package_forepanel, row, {
			tango_mission = true,
			unlocks = unlock_count
		}, self)
		row = row + 1
	end

	if self._gage_assignment then
		gage_package = HUDPackageUnlockedItem:new(self._package_forepanel, row, {
			gage_assignment = true,
			unlocks = unlock_count
		}, self)
		row = row + 1
	end

	if self._challenge_completed then
		challenge_completed = HUDPackageUnlockedItem:new(self._package_forepanel, row, {
			challenge_completed = true,
			unlocks = unlock_count
		}, self)
		row = row + 1
	end

	local package_items = {}

	if ghost_package and (not gage_package or not challenge_completed) then
		table.insert(package_items, ghost_package)
	end

	if tango_completed then
		table.insert(package_items, tango_completed)
	end

	if gage_package then
		table.insert(package_items, gage_package)
	end

	if challenge_completed then
		table.insert(package_items, challenge_completed)
	end

	if #package_items > 0 then
		for _, item in pairs(self._package_items) do
			item:close()
		end

		self._package_items = package_items
	end
end

function HUDStageEndScreen:stop_stage()
	self:clear_stage()

	self._stage = 0
end

function HUDStageEndScreen:reset_stage()
	self:clear_stage()

	self._stage = 1
end

function HUDStageEndScreen:step_stage_up()
	self._stage = self._stage + 1
end

function HUDStageEndScreen:step_stage_down()
	self._stage = self._stage - 1
end

function HUDStageEndScreen:step_stage_to_start()
	self._stage = 1
end

function HUDStageEndScreen:step_stage_to_end()
	self._stage = #self.stages
end

function HUDStageEndScreen:_wait_for_video()
	local time = 0
	local video = self._background_layer_full:child("money_video")
	local length = video:length()
	local fade_t = 1
	local alpha = 0

	while alive(video) and video:loop_count() == 0 do
		local dt = coroutine.yield() * (self._speed_up or 1)
		time = time + dt

		video:set_alpha(math.min(time, 1) * 0.2)
	end

	if alive(video) then
		local start_alpha = video:alpha()

		over(0.25, function (p)
			video:set_alpha(math.lerp(start_alpha, 0, p))
		end)
		video:parent():remove(video)

		video = nil
	end
end

function HUDStageEndScreen:stage_money_counter_init(t, dt)
	WalletGuiObject.refresh()
	WalletGuiObject.hide_wallet()

	if alive(self._skip_text) then
		self._skip_text:set_visible(true)
	end

	local is_success = game_state_machine:current_state().is_success and game_state_machine:current_state():is_success()

	self:_check_special_packages()
	self:_update_skirmish_wave()

	self._is_fail_video = not is_success

	if SystemInfo:platform() ~= Idstring("X360") then
		local gui_width, gui_height = managers.gui_data:get_base_res()

		if self._is_fail_video then
			local variant = math.random(2)
			local video = self._background_layer_full:video({
				blend_mode = "add",
				name = "money_video",
				alpha = 0,
				loop = false,
				video = "movies/fail_stage" .. tostring(variant),
				width = gui_width,
				height = gui_height
			})

			video:animate(callback(self, self, "_wait_for_video"), nil)
		else
			local variant = 0
			local video = self._background_layer_full:video({
				blend_mode = "add",
				name = "money_video",
				alpha = 0,
				loop = true,
				video = "movies/money_count" .. tostring(variant),
				width = gui_width,
				height = gui_height
			})

			video:animate(callback(self, self, "spawn_animation"), 1, false)
		end
	end

	self._money_panel = self._lp_forepanel:panel({
		name = "money_panel",
		x = 10,
		y = 10
	})

	self._money_panel:grow(-20, -20)

	local payouts = managers.money:get_payouts()
	local stage_payout = payouts.stage_payout
	local job_payout = payouts.job_payout
	local bag_payout = payouts.bag_payout
	local vehicle_payout = payouts.vehicle_payout
	local small_loot_payout = payouts.small_loot_payout
	local crew_payout = payouts.crew_payout
	local skirmish_payout = payouts.skirmish_payout
	local mutators_reduction = -payouts.mutators_reduction

	local function check_if_clear(data)
		for _, d in ipairs(data) do
			if d[2] and d[2] > 0 then
				return false
			end
		end

		return true
	end

	local function round_and_fix_precision(x)
		x = math.round(x)

		return math.step(x, x, 0)
	end

	self._money = {
		income = {
			{
				"menu_es_cash_stage",
				round_and_fix_precision(stage_payout or 0)
			},
			{
				"menu_es_cash_job",
				round_and_fix_precision(job_payout or 0)
			},
			{
				"menu_cash_bonus_bags",
				round_and_fix_precision(bag_payout or 0)
			},
			{
				"menu_cash_vehicles",
				round_and_fix_precision(vehicle_payout or 0)
			},
			{
				"menu_cash_crew",
				round_and_fix_precision(crew_payout or 0)
			},
			{
				"hud_instant_cash",
				round_and_fix_precision(small_loot_payout or 0)
			},
			{
				"menu_es_skirmish_cash",
				round_and_fix_precision(skirmish_payout or 0)
			},
			{
				"menu_mutators_reduction_cash",
				round_and_fix_precision(mutators_reduction or 0)
			},
			name_id = managers.localization:to_upper_text("menu_cash_income", {
				money = ""
			})
		}
	}

	if check_if_clear(self._money.income) then
		self._money.income = {}
	end

	self._money.costs = {
		name_id = managers.localization:to_upper_text("menu_cash_costs", {
			money = ""
		})
	}

	if check_if_clear(self._money.costs) then
		self._money.costs = {}
	end

	local spending_earned = managers.money:heist_spending()
	self._money.balance = {
		{
			"hud_offshore_account",
			round_and_fix_precision(managers.money:heist_offshore())
		},
		{
			"menu_cash_spending",
			round_and_fix_precision(spending_earned),
			spending_earned > 0 and tweak_data.screen_colors.friend_color or tweak_data.screen_colors.pro_color
		},
		name_id = managers.localization:to_upper_text("menu_cash_balance", {
			money = ""
		})
	}

	if check_if_clear(self._money.balance) then
		self._money.balance = {}
	end

	self._money_stage = {
		"income",
		"costs",
		"balance"
	}

	self:reset_income_count()

	self._wait_t = 1

	self:step_stage_up()

	self._debug_m = nil
end

function HUDStageEndScreen:set_debug_m(name)
	return

	if self._debug_m ~= name then
		self._debug_m = name

		Application:debug(name)
	end
end

function HUDStageEndScreen:stage_money_counter_count(t, dt)
	if self:perform_income_count(t, dt, self._money_panel, self._money_stage, self._money, self.get_count_speed_fast, self.display_as_cash) then
		WalletGuiObject.set_objects_visible({
			"wallet_money_icon",
			"wallet_money_text"
		}, true)
		managers.menu_component:show_endscreen_cash_summary()

		self._wait_t = 1.25

		self:step_stage_up()
	end
end

function HUDStageEndScreen:reset_income_count()
	self._money_text_y = 10
	self._start_count_money = false
	self._counting_money = false
	self._money_counting_amount = 0
	self._income_stage_index = 1
	self._income_index = 0
end

function HUDStageEndScreen:get_count_speed_fast(dt, data)
	return dt * math.max(20000, math.abs(data[2]) / 1.5)
end

function HUDStageEndScreen:get_count_speed_slow(dt, data)
	return dt * math.max(200, math.abs(data[2]) / 1.5)
end

function HUDStageEndScreen:display_as_cash(amount)
	return managers.experience:cash_string(amount)
end

function HUDStageEndScreen:perform_income_count(t, dt, parent_panel, stage_table, income_table, count_func, display_func)
	local income_stage = stage_table[self._income_stage_index]

	if income_stage then
		local income_data = income_table[income_stage]

		if income_data then
			local income_specific = income_data[self._income_index]

			if (income_specific or self._income_index == 0) and income_data.name_id then
				if self._income_index == 0 then
					local text_object = parent_panel:text({
						x = 0,
						y = self._money_text_y,
						text = income_data.name_id,
						font = tweak_data.menu.pd2_medium_font,
						font_size = tweak_data.menu.pd2_medium_font_size
					})

					managers.hud:make_fine_text(text_object)
					text_object:grow(0, 2)
					managers.menu_component:post_event("box_tick")

					self._money_text_y = text_object:bottom()
					self._wait_t = 0.65
					self._income_index = 1
				elseif self._start_count_money then
					local text_object = parent_panel:text({
						name = "text" .. tostring(self._income_stage_index) .. tostring(self._income_index),
						x = parent_panel:w() * 0.5,
						y = self._money_text_y,
						text = display_func(self, 0),
						font = tweak_data.menu.pd2_small_font,
						font_size = tweak_data.menu.pd2_small_font_size
					})

					managers.hud:make_fine_text(text_object)

					local dir_object = parent_panel:text({
						name = "dir" .. tostring(self._income_stage_index) .. tostring(self._income_index),
						y = self._money_text_y,
						text = income_specific[2] < 0 and "-" or "+",
						font = tweak_data.menu.pd2_small_font,
						font_size = tweak_data.menu.pd2_small_font_size
					})

					managers.hud:make_fine_text(dir_object)
					dir_object:set_right(text_object:left())
					dir_object:hide()

					self._wait_t = 0.45
					self._start_count_money = false
					self._counting_money = true
					self._money_counting_amount = 0
					self._set_count_first = true
				elseif self._counting_money then
					local text_object = parent_panel:child("text" .. tostring(self._income_stage_index) .. tostring(self._income_index))
					local dir_object = parent_panel:child("dir" .. tostring(self._income_stage_index) .. tostring(self._income_index))

					if self._set_count_first then
						self._set_count_first = nil

						managers.menu_component:post_event("count_1")
						dir_object:show()
					end

					self._money_counting_amount = math.round(math.step(self._money_counting_amount, income_specific[2], count_func(self, dt, income_specific)))

					text_object:set_text(display_func(self, math.abs(self._money_counting_amount)))
					managers.hud:make_fine_text(text_object)

					if self._money_counting_amount == income_specific[2] then
						self._counting_money = false
						self._income_index = self._income_index + 1
						self._money_text_y = text_object:bottom()
						self._wait_t = 0.45

						managers.menu_component:post_event("count_1_finished")
						text_object:set_color(income_specific[3] or tweak_data.screen_colors.text)
						dir_object:set_color(income_specific[3] or tweak_data.screen_colors.text)
					end
				elseif not income_specific[2] or income_specific[2] == 0 then
					self._income_index = self._income_index + 1
				else
					local text_object = parent_panel:text({
						x = 10,
						y = self._money_text_y,
						text = managers.localization:to_upper_text(income_specific[1], {
							money = ""
						}),
						font = tweak_data.menu.pd2_small_font,
						font_size = tweak_data.menu.pd2_small_font_size
					})

					managers.hud:make_fine_text(text_object)
					managers.menu_component:post_event("box_tick")

					self._start_count_money = true
				end
			else
				self._income_index = 0
				self._income_stage_index = self._income_stage_index + 1
				self._money_text_y = self._money_text_y + 15
				self._wait_t = income_data and 0 or 1
			end

			return false
		end
	end

	return true
end

function HUDStageEndScreen:stage_money_counter_hide(t, dt)
	Application:debug("HUDStageEndScreen:stage_money_counter_hide")

	if alive(self._money_panel) then
		self._money_panel:animate(callback(self, self, "destroy_animation"))

		self._money_panel = nil
	end

	self:step_stage_up()
end

function HUDStageEndScreen:safehouse_currency_init(t, dt)
	local safehouse_manager = nil
	safehouse_manager = managers.custom_safehouse

	if not safehouse_manager:unlocked() then
		self._wait_t = 0
		self._start_ramp_up_t = nil
		self._ramp_up_timer = 0
		self._safehouse_data = nil

		WalletGuiObject.set_objects_visible({
			"wallet_coins_icon",
			"wallet_coins_text"
		}, true)
		self:step_stage_up()

		return
	end

	local coins = safehouse_manager:coins()
	local previous_coins = safehouse_manager:previous_coins()
	local total_income = coins - previous_coins
	local exp_income = total_income
	local trophies = {}

	for idx, trophy_data in ipairs(safehouse_manager:completed_trophies()) do
		if trophy_data.type == "trophy" then
			table.insert(trophies, {
				trophy_data.name,
				trophy_data.reward,
				tweak_data.screen_colors.challenge_completed_color
			})

			exp_income = exp_income - trophy_data.reward
		end
	end

	local is_success = game_state_machine:current_state().is_success and game_state_machine:current_state():is_success()
	local has_completed_daily = safehouse_manager:has_completed_daily() and not safehouse_manager:has_rewarded_daily()

	if has_completed_daily then
		table.insert(trophies, {
			"menu_es_safehouse_income_daily",
			tweak_data.safehouse.rewards.daily_complete,
			tweak_data.screen_colors.heat_warm_color
		})

		exp_income = exp_income - tweak_data.safehouse.rewards.daily_complete
	end

	local was_safehouse_raid = managers.job:current_job_id() == "chill_combat"

	if was_safehouse_raid and is_success then
		table.insert(trophies, {
			"menu_es_safehouse_raid",
			tweak_data.safehouse.rewards.raid,
			tweak_data.screen_colors.important_1
		})

		exp_income = exp_income - tweak_data.safehouse.rewards.raid
	end

	if total_income <= 0 then
		self._wait_t = 0
		self._start_ramp_up_t = nil
		self._ramp_up_timer = 0
		self._safehouse_data = nil

		WalletGuiObject.set_objects_visible({
			"wallet_coins_icon",
			"wallet_coins_text"
		}, true)
		self:step_stage_up()

		return
	end

	self._coins_text:show()
	self._coins_circle:show()
	self._coins_backpanel:child("bg_progress_circle"):show()
	self._coins_forepanel:child("coin_progress_text"):show()
	self._coins_circle:set_alpha(0)
	self._coins_backpanel:child("bg_progress_circle"):set_alpha(0)
	self._coins_text:set_alpha(0)

	self._safehouse_data = {
		income = exp_income,
		remaining_income = exp_income,
		current = coins - total_income,
		trophies = trophies
	}

	safehouse_manager:flush_completed_trophies()

	local partial_coins = self._safehouse_data.current % 1

	self._coins_circle:set_color(Color(partial_coins, 1, 1))
	self:set_coin_text(self._safehouse_data.current)

	self._bonuses_panel = self._lp_forepanel:panel({
		y = 10,
		x = self._lp_xp_gained:x(),
		w = self._lp_forepanel:w() - self._lp_xp_gained:left() - 10,
		h = self._lp_xp_gained:top() - 10
	})
	self._wait_t = 0.5
	self._start_ramp_up_t = 1
	self._ramp_up_timer = 0

	managers.menu_component:post_event("box_tick")
	self:step_stage_up()
end

function HUDStageEndScreen:set_coin_text(coins)
	self._coins_text:set_text(managers.experience:cash_string(math.floor(coins), ""))

	local fs = tweak_data.menu.pd2_massive_font_size

	if coins > 99999 then
		fs = tweak_data.menu.pd2_large_font_size
	elseif coins > 9999 then
		fs = tweak_data.menu.pd2_massive_font_size * 0.65
	elseif coins > 999 then
		fs = tweak_data.menu.pd2_massive_font_size * 0.85
	end

	self._coins_text:set_font_size(fs)
end

function HUDStageEndScreen:coin_up(new_coins, alpha_multi)
	if alpha_multi == nil then
		alpha_multi = 1
	end

	local function level_text_func(o, ding_scale, new_coins_text)
		local center_x, center_y = o:center()
		local size = tweak_data.menu.pd2_massive_font_size
		local ding_size = size * (1 + ding_scale)

		wait(0.1)
		o:set_text(new_coins_text)
	end

	local function text_ding_func(o)
		local TOTAL_T = 0.4
		local t = TOTAL_T
		local mul = 1
		local size = o:font_size()

		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			local ratio = math.max(t / TOTAL_T, 0)
			mul = mul + dt * 4

			o:set_font_size(size * mul)
			o:set_alpha(ratio * alpha_multi)
			o:set_color(math.lerp(Color.white, tweak_data.screen_colors.challenge_completed_color, 1 - ratio))
		end

		o:parent():remove(o)
	end

	local function circle_ding_func(o)
		wait(0.15)

		local TOTAL_T = 0.6
		local t = TOTAL_T
		local mul = 1
		local c_x, c_y = o:center()
		local size = o:w()

		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			local ratio = math.max(t / TOTAL_T, 0)
			mul = mul + dt * 0.75

			o:set_size(size * mul, size * mul)
			o:set_center(c_x, c_y)
			o:set_alpha(ratio * alpha_multi)
			o:set_color(math.lerp(Color.white, tweak_data.screen_colors.challenge_completed_color, 1 - ratio))
		end

		o:parent():remove(o)
	end

	managers.menu_component:post_event("stinger_levelup")

	local ding_circle = self._coins_backpanel:bitmap({
		texture = "guis/textures/pd2/endscreen/exp_ring",
		rotation = 360,
		blend_mode = "add",
		layer = 0,
		w = self._coins_circle:w(),
		h = self._coins_circle:h(),
		x = self._coins_circle:x(),
		y = self._coins_circle:y(),
		color = Color.white
	})

	ding_circle:animate(circle_ding_func)

	local ding_text = self._coins_forepanel:text({
		vertical = "center",
		align = "center",
		rotation = 360,
		blend_mode = "add",
		layer = 0,
		w = self._coins_text:w(),
		h = self._coins_text:h(),
		x = self._coins_text:x(),
		y = self._coins_text:y(),
		color = Color.white,
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		text = self._coins_text:text()
	})

	ding_text:animate(text_ding_func)
	self._coins_text:stop()
	self._coins_text:animate(level_text_func, 1, managers.experience:cash_string(math.floor(new_coins)))
end

function HUDStageEndScreen:safehouse_currency_fade_in(t, dt)
	local safehouse_manager = nil
	safehouse_manager = managers.custom_safehouse

	if not safehouse_manager:unlocked() or not self._safehouse_data then
		self:step_stage_up()

		return
	end

	if self._start_ramp_up_t then
		self._ramp_up_timer = math.min(self._ramp_up_timer + dt, self._start_ramp_up_t)
		local ratio = self._ramp_up_timer / self._start_ramp_up_t

		self._coins_circle:set_alpha(ratio)
		self._coins_backpanel:child("bg_progress_circle"):set_alpha(ratio * 0.6)
		self._coins_text:set_alpha(ratio)

		if self._ramp_up_timer == self._start_ramp_up_t then
			self._start_ramp_up_t = 1

			self:step_stage_up()
		end

		return
	end

	self:step_stage_up()
end

function HUDStageEndScreen:safehouse_currency_count(t, dt)
	local safehouse_manager = nil
	safehouse_manager = managers.custom_safehouse
	local data = self._safehouse_data

	if not safehouse_manager:unlocked() or not data then
		self:step_stage_up()

		return
	end

	if not self._last_trophy_bonus then
		local bonus = self:_create_bonus({
			panel = self._bonuses_panel,
			color = tweak_data.screen_colors.text,
			title = managers.localization:to_upper_text("menu_experience"),
			bonus = math.floor(self._safehouse_data.current + data.remaining_income) - math.floor(self._safehouse_data.current)
		})

		bonus:child("sign"):hide()

		self._last_trophy_bonus = bonus
	end

	if not self._playing_sound then
		self._playing_sound = true

		managers.menu_component:post_event("count_1")
	end

	if data.remaining_income > 0 then
		local initial_xp = self._safehouse_data.current % 1
		local total_next_coin_xp = math.min(data.remaining_income, 1 - initial_xp)

		if self._next_coin_xp == nil then
			self._next_coin_xp = total_next_coin_xp
		end

		local coin_xp_gained = dt * math.max(0.66, self._next_coin_xp)
		self._next_coin_xp = self._next_coin_xp - coin_xp_gained

		if self._next_coin_xp <= 0 then
			coin_xp_gained = coin_xp_gained + self._next_coin_xp
			self._next_coin_xp = 0
		end

		local ratio = initial_xp + total_next_coin_xp - self._next_coin_xp

		self._coins_circle:set_color(Color(ratio, 1, 1))

		if self._next_coin_xp == 0 then
			local is_coin_up = self._safehouse_data.current % 1 + data.remaining_income > 1

			if is_coin_up then
				self._safehouse_data.current = math.floor(self._safehouse_data.current + 1)

				self:set_coin_text(self._safehouse_data.current)
				self:coin_up(self._safehouse_data.current, 0.66)

				self._wait_t = 0.65
			else
				self._safehouse_data.current = self._safehouse_data.current + data.remaining_income
				self._wait_t = 0.4
			end

			data.remaining_income = data.remaining_income - total_next_coin_xp
			self._next_coin_xp = nil

			self:_end_count_up_sound()
		end
	else
		WalletGuiObject.set_objects_visible({
			"wallet_coins_icon",
			"wallet_coins_text"
		}, true)

		self._wait_t = 0.5

		self:_end_count_up_sound()
		self:step_stage_up()
	end
end

function HUDStageEndScreen:_end_count_up_sound()
	if self._playing_sound then
		managers.menu_component:post_event("count_1_finished")

		self._playing_sound = nil
	end
end

function HUDStageEndScreen:safehouse_currency_trophies(t, dt)
	if not managers.custom_safehouse:unlocked() or not self._safehouse_data then
		self:step_stage_up()

		return
	end

	self:_end_count_up_sound()

	local data = self._safehouse_data
	self._trophy_bonuses = self._trophy_bonuses or {}

	if #data.trophies > 0 then
		local trophy = data.trophies[1]

		if not self._trophy_bonuses[trophy[1]] then
			local bonus = self:_create_bonus({
				panel = self._bonuses_panel,
				color = trophy[3],
				title = managers.localization:to_upper_text(trophy[1]),
				bonus = trophy[2]
			})

			bonus:child("sign"):hide()

			self._trophy_bonuses[trophy[1]] = bonus

			if self._last_trophy_bonus then
				bonus:set_top(self._last_trophy_bonus:bottom())
			end

			self._last_trophy_bonus = bonus
			self._wait_t = 0.5

			return
		end

		if trophy[2] > 0 then
			self._safehouse_data.current = self._safehouse_data.current + 1
			trophy[2] = trophy[2] - 1

			self:set_coin_text(self._safehouse_data.current)
			self:coin_up(self._safehouse_data.current)

			self._wait_t = 0.16

			if trophy[2] <= 0 then
				table.remove(data.trophies, 1)

				self._wait_t = 1
			end
		end

		return
	end

	self._wait_t = 1
	self._start_ramp_up_t = 0.35
	self._ramp_up_timer = 0

	self:step_stage_up()
end

function HUDStageEndScreen:safehouse_currency_hide(t, dt)
	local safehouse_manager = nil
	safehouse_manager = managers.custom_safehouse

	if not safehouse_manager:unlocked() or not self._safehouse_data then
		self:step_stage_up()

		return
	end

	if self._start_ramp_up_t then
		self._ramp_up_timer = math.min(self._ramp_up_timer + dt, self._start_ramp_up_t)
		local ratio = 1 - self._ramp_up_timer / self._start_ramp_up_t

		self._coins_circle:set_alpha(ratio)
		self._coins_forepanel:child("coin_progress_text"):set_alpha(ratio)
		self._coins_backpanel:child("bg_progress_circle"):set_alpha(ratio * 0.6)
		self._coins_text:set_alpha(ratio)
		self._bonuses_panel:set_alpha(ratio)

		if self._ramp_up_timer == self._start_ramp_up_t then
			self._start_ramp_up_t = nil
		end

		return
	end

	if not self._is_fail_video then
		local video = self._background_layer_full:child("money_video")

		if video then
			video:animate(callback(self, self, "destroy_animation"))
		end
	end

	self._start_ramp_up_t = 1

	self:step_stage_up()
end

function HUDStageEndScreen:display_as_coins(amount)
	return managers.experience:cash_string(math.floor(amount), "")
end

function HUDStageEndScreen:stage_experience_init(t, dt)
	local data = self._data

	self._lp_text:show()
	self._lp_circle:show()
	self._lp_backpanel:child("bg_progress_circle"):show()
	self._lp_forepanel:child("level_progress_text"):show()

	if false and managers.experience:reached_level_cap() then
		self._lp_text:set_text(tostring(data.start_t.level))
		self._lp_circle:set_color(Color(1, 1, 1))
		managers.menu_component:post_event("box_tick")
		self:step_stage_to_end()

		return
	end

	self._lp_circle:set_alpha(0)
	self._lp_backpanel:child("bg_progress_circle"):set_alpha(0)
	self._lp_text:set_alpha(0)

	self._bonuses_panel = self._lp_forepanel:panel({
		y = 10,
		x = self._lp_xp_gained:x(),
		w = self._lp_forepanel:w() - self._lp_xp_gained:left() - 10,
		h = self._lp_xp_gained:top() - 10
	})
	self._anim_exp_bonus = nil
	local bonus_params = {
		panel = self._bonuses_panel,
		color = tweak_data.screen_colors.text,
		title = managers.localization:to_upper_text("menu_experience"),
		bonus = 0
	}
	local exp = self:_create_bonus(bonus_params)

	exp:child("sign"):hide()

	self._experience_text_panel = exp

	self._experience_text_panel:set_alpha(0)

	self._experience_added = 0
	self._bonuses = {}

	if data.bonuses.stage_xp and data.bonuses.stage_xp ~= 0 then
		bonus_params.title = managers.localization:to_upper_text("menu_es_base_xp_stage")
		bonus_params.bonus = data.bonuses.stage_xp
		local stage = self:_create_bonus(bonus_params)

		stage:set_right(0)
		stage:set_top(exp:bottom())
		table.insert(self._bonuses, {
			stage,
			bonus_params.bonus
		})
	end

	local job = nil

	if data.bonuses.last_stage and data.bonuses.job_xp ~= 0 then
		bonus_params.title = managers.localization:to_upper_text("menu_es_base_xp_job")
		bonus_params.bonus = data.bonuses.job_xp
		job = self:_create_bonus(bonus_params)

		job:set_right(0)
		job:set_top(exp:bottom())
		table.insert(self._bonuses, {
			job,
			bonus_params.bonus
		})
	end

	local heat_xp = self._bonuses.heat_xp or 0
	local heat = managers.job:last_known_heat() or managers.job:has_active_job() and managers.job:get_job_heat(managers.job:current_job_id()) or 0
	local heat_color = managers.job:get_heat_color(heat)
	local bonuses_list = {
		"bonus_mission_xp",
		"bonus_days",
		"bonus_pro_job",
		"bonus_low_level",
		"bonus_risk",
		"bonus_failed",
		"in_custody",
		"bonus_num_players",
		"bonus_skill",
		"bonus_infamy",
		"bonus_gage_assignment",
		"bonus_extra",
		"bonus_ghost",
		"heat_xp",
		"bonus_mutators"
	}
	local bonuses_params = {
		bonus_mission_xp = {
			color = tweak_data.screen_colors.text,
			title = managers.localization:to_upper_text("menu_es_mission_xp_bonus")
		},
		bonus_days = {
			color = tweak_data.screen_colors.text,
			title = managers.localization:to_upper_text("menu_es_day_bonus")
		},
		bonus_pro_job = {
			color = tweak_data.screen_colors.text,
			title = managers.localization:to_upper_text("menu_es_pro_job_bonus")
		},
		bonus_low_level = {
			color = tweak_data.screen_colors.important_1,
			title = managers.localization:to_upper_text("menu_es_alive_low_level_bonus")
		},
		bonus_risk = {
			color = tweak_data.screen_colors.risk,
			title = managers.localization:to_upper_text("menu_es_risk_bonus")
		},
		bonus_failed = {
			color = tweak_data.screen_colors.important_1,
			title = managers.localization:to_upper_text("menu_es_alive_failed_bonus")
		},
		in_custody = {
			color = tweak_data.screen_colors.important_1,
			title = managers.localization:to_upper_text("menu_es_in_custody_reduction")
		},
		bonus_num_players = {
			color = tweak_data.screen_colors.risk,
			title = managers.localization:to_upper_text("menu_es_alive_players_bonus")
		},
		bonus_skill = {
			color = tweak_data.screen_colors.button_stage_2,
			title = managers.localization:to_upper_text("menu_es_skill_bonus")
		},
		bonus_infamy = {
			color = tweak_data.lootdrop.global_values.infamy.color,
			title = managers.localization:to_upper_text("menu_es_infamy_bonus")
		},
		bonus_gage_assignment = {
			color = tweak_data.screen_colors.button_stage_2,
			title = managers.localization:to_upper_text("menu_es_gage_assignment_bonus")
		},
		bonus_extra = {
			color = tweak_data.screen_colors.event_color,
			title = managers.localization:to_upper_text("menu_es_extra_bonus")
		},
		bonus_ghost = {
			color = tweak_data.screen_colors.ghost_color,
			title = managers.localization:to_upper_text("menu_es_ghost_bonus")
		},
		heat_xp = {
			color = heat_color,
			title = managers.localization:to_upper_text(heat >= 0 and "menu_es_heat_bonus" or "menu_es_heat_reduction")
		},
		bonus_mutators = {
			color = tweak_data.screen_colors.important_1,
			title = managers.localization:to_upper_text("menu_mutators_reduction_exp")
		}
	}

	for i, func_name in ipairs(bonuses_list) do
		local bonus = data.bonuses[func_name] or 0

		if bonus ~= 0 then
			bonus_params.color = bonuses_params[func_name] and bonuses_params[func_name].color or Color.purple
			bonus_params.title = bonuses_params[func_name] and bonuses_params[func_name].title or "ERR: " .. func_name
			bonus_params.bonus = bonus
			local b = self:_create_bonus(bonus_params)

			b:set_right(0)
			b:set_top(exp:bottom())
			table.insert(self._bonuses, {
				b,
				bonus_params.bonus
			})
		end
	end

	local delay = 0.8
	local y = 0
	local sum_text = self._lp_forepanel:text({
		text = "= ",
		name = "sum_text",
		alpha = 1,
		align = "right",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})

	make_fine_text(sum_text)
	sum_text:set_righttop(self._lp_xp_gain:left(), self._lp_xp_gain:top())
	sum_text:hide()

	self._sum_text = sum_text

	self._lp_circle:set_color(Color(data.start_t.current / data.start_t.total, 1, 1))

	self._wait_t = 0.5
	self._start_ramp_up_t = 1
	self._ramp_up_timer = 0

	managers.menu_component:post_event("box_tick")
	self:step_stage_up()
end

function HUDStageEndScreen:anim_count_experience(o, stat)
	self._anim_exp_bonus = true
	local dt = nil

	managers.menu_component:post_event("count_1_finished")

	while o:left() < 0 do
		dt = coroutine.yield() * (self._speed_up or 1)

		o:move(o:w() * dt * 6, 0)
		o:set_left(math.min(o:left(), 0))
	end

	local wait_t = 0.85

	while wait_t > 0 do
		dt = coroutine.yield() * (self._speed_up or 1)
		wait_t = wait_t - dt
	end

	if stat > 0 then
		managers.menu_component:post_event("zoom_in")
	else
		managers.menu_component:post_event("zoom_out")
	end

	while o:top() > 0 do
		dt = coroutine.yield() * (self._speed_up or 1)

		o:move(0, -o:h() * dt * 6)
		o:set_top(math.max(o:top(), 0))
		o:set_alpha(o:top() / o:h())
	end

	local old_exp_text = self._bonuses_panel:text({
		rotation = 360,
		layer = 3,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		text = self._experience_text_panel:child("stat"):text()
	})

	old_exp_text:set_size(self._experience_text_panel:child("stat"):size())
	old_exp_text:set_world_position(self._experience_text_panel:child("stat"):world_position())

	self._experience_added = self._experience_added + stat

	self._experience_text_panel:child("stat"):set_text(managers.money:add_decimal_marks_to_string(tostring(self._experience_added)))

	local st = 0.5
	local t = st

	while t > 0 do
		dt = coroutine.yield() * (self._speed_up or 1)
		t = t - dt

		old_exp_text:move(dt * 5, -35 * dt)
		old_exp_text:set_alpha(t / st)
	end

	self._bonuses_panel:remove(old_exp_text)

	self._anim_exp_bonus = false

	o:parent():remove(o)
end

function HUDStageEndScreen:stage_experience_count_exp(t, dt)
	local data = self._data

	if self._start_ramp_up_t then
		self._ramp_up_timer = math.min(self._ramp_up_timer + dt, self._start_ramp_up_t)
		local ratio = self._ramp_up_timer / self._start_ramp_up_t * data.start_t.current / data.start_t.total
		ratio = self._ramp_up_timer / self._start_ramp_up_t

		self._lp_circle:set_alpha(ratio)
		self._lp_backpanel:child("bg_progress_circle"):set_alpha(ratio * 0.6)
		self._lp_text:set_alpha(ratio)
		self._experience_text_panel:set_alpha(ratio)

		if self._ramp_up_timer == self._start_ramp_up_t then
			if self._anim_exp_bonus then
				return
			end

			if #self._bonuses > 0 then
				local bonus = self._bonuses[1][1]
				local stat = self._bonuses[1][2]
				local func = callback(self, self, "anim_count_experience")

				bonus:animate(func, stat)
				table.remove(self._bonuses, 1)

				return
			end

			self._start_ramp_up_t = 1

			self:step_stage_up()
		end

		return
	end

	self:step_stage_up()
end

function HUDStageEndScreen:stage_experience_spin_up(t, dt)
	local data = self._data

	if self._start_ramp_up_t then
		local ratio = 0

		if self._ramp_up_timer == self._start_ramp_up_t then
			self._static_current_xp = data.start_t.xp
			self._static_gained_xp = 0
			self._static_start_xp = data.start_t.current
			self._current_xp = self._static_current_xp
			self._gained_xp = self._static_gained_xp
			self._next_level_xp = data.start_t.total - data.start_t.current
			self._speed = 1
			self._wait_t = 0.8
			self._ramp_up_timer = nil
			self._start_ramp_up_t = nil
			ratio = 1

			self._lp_circle:set_alpha(ratio)
			self._lp_backpanel:child("bg_progress_circle"):set_alpha(ratio * 0.6)
			self._lp_text:set_alpha(ratio)
			self._lp_text:stop()
			self._lp_text:set_font_size(tweak_data.menu.pd2_massive_font_size)
			self._lp_text:set_text(tostring(data.start_t.level))
			self._lp_xp_curr:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(data.start_t.xp))))
			self._lp_xp_gain:set_text("")
			self._lp_xp_nl:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(data.start_t.total - data.start_t.current))))

			local clbk = callback(self, self, "spawn_animation")
			local start_max_level = data.start_t.level == managers.experience:level_cap()

			self._lp_xp_gained:show()
			self._lp_curr_xp:set_visible(not start_max_level)
			self._lp_next_level:set_visible(not start_max_level)
			self._lp_xp_gain:show()
			self._lp_xp_curr:set_visible(not start_max_level)
			self._lp_xp_nl:set_visible(not start_max_level)
			self._lp_curr_xp:animate(clbk, 0)
			self._lp_xp_gained:animate(clbk, 0)
			self._lp_next_level:animate(clbk, 0)
			self._lp_xp_gain:animate(clbk, 0)
			self._lp_xp_curr:animate(clbk, 0)
			self._lp_xp_nl:animate(clbk, 0)
			self:step_stage_up()
		end
	end

	self:step_stage_up()
end

function HUDStageEndScreen:stage_experience_show_all(t, dt)
	local start_max_level = data.start_t.level == managers.experience:level_cap()

	self._lp_xp_gained:show()
	self._lp_curr_xp:set_visible(not start_max_level)
	self._lp_next_level:set_visible(not start_max_level)
	self._lp_xp_gain:show()
	self._lp_xp_curr:set_visible(not start_max_level)
	self._lp_xp_nl:set_visible(not start_max_level)
	self._sum_text:set_visible(not start_max_level)
	self:step_stage_up()
end

function HUDStageEndScreen:stage_experience_spin_levels(t, dt)
	local data = self._data

	if not self._playing_sound then
		self._playing_sound = true

		managers.menu_component:post_event("count_1")
	end

	self._csl = self._csl or 1
	local current_level_data = data[self._csl]

	if current_level_data then
		local total_xp = current_level_data.total
		local xp_gained_frame = dt * self._speed * math.max(total_xp * 0.08, 450)
		self._next_level_xp = self._next_level_xp - xp_gained_frame

		if self._next_level_xp <= 0 then
			xp_gained_frame = xp_gained_frame + self._next_level_xp
			self._next_level_xp = 0
		end

		self._current_xp = self._current_xp + xp_gained_frame
		self._gained_xp = self._gained_xp + xp_gained_frame
		self._speed = self._speed + dt * 1.55
		local ratio = 1 - self._next_level_xp / total_xp

		self._lp_circle:set_color(Color(ratio, 1, 1))

		if self._next_level_xp == 0 then
			self._csl = self._csl + 1

			if data[self._csl] then
				self._next_level_xp = data[self._csl].total
			else
				self._next_level_xp = false
			end

			self._static_current_xp = self._static_current_xp + current_level_data.total - self._static_start_xp
			self._static_gained_xp = self._static_gained_xp + current_level_data.total - self._static_start_xp
			self._current_xp = self._static_current_xp
			self._gained_xp = self._static_gained_xp
			self._static_start_xp = 0
			self._speed = math.max(1, self._speed * 0.55)
			local package_unlocked = self:level_up(current_level_data.level)

			if package_unlocked then
				self._wait_t = 0.63 + (package_unlocked.upgrades and #package_unlocked.upgrades * 0.57 or 0)

				managers.menu_component:post_event("count_1_finished")

				self._playing_sound = nil
			else
				self._wait_t = 0.4

				managers.menu_component:post_event("count_1_finished")

				self._playing_sound = nil
			end
		end

		local floored_gained = math.floor(self._gained_xp)

		self._experience_text_panel:child("stat"):set_text(managers.money:add_decimal_marks_to_string(tostring(self._experience_added - floored_gained)))
		self._lp_xp_curr:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(self._current_xp))))
		self._lp_xp_gain:set_text(managers.money:add_decimal_marks_to_string(tostring(floored_gained)))

		if self._next_level_xp then
			self._lp_xp_nl:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(self._next_level_xp))))
		else
			self._lp_xp_nl:set_text("")

			self._next_level_xp = current_level_data.level < managers.experience:level_cap() and data.end_t.total or 0
		end
	else
		self._speed = math.max(1.55, self._speed * 0.55)
		self._top_speed = self._speed

		self:step_stage_up()
	end
end

function HUDStageEndScreen:stage_experience_spin_slowdown(t, dt)
	local data = self._data
	local level_cap = data.end_t.level == managers.experience:level_cap()
	local xp_gained_frame = dt * self._speed * math.max(data.end_t.total * 0.1, 450, (level_cap and self._experience_added or 0) * 0.075)
	local total_xp = data.end_t.total - data.end_t.current

	if level_cap then
		if not self._endgame_setup then
			self._endgame_setup = true

			self._experience_text_panel:show()
			self._lp_xp_gained:show()
			self._lp_curr_xp:show()
			self._lp_next_level:show()

			local start_max_level = self._data.start_t.level == managers.experience:level_cap()

			self._lp_next_level:set_visible(not start_max_level)
			self._lp_xp_nl:set_visible(not start_max_level)
			self._lp_xp_gain:show()
			self._lp_xp_curr:show()
			self._lp_xp_nl:show()
			self._sum_text:hide()
			self._lp_circle:set_color(Color(1, 1, 1))
		end

		self._gained_xp = self._gained_xp + xp_gained_frame
		local countdown_xp = math.max(self._experience_added - math.floor(self._gained_xp), 0)

		self._experience_text_panel:child("stat"):set_text(managers.money:add_decimal_marks_to_string(tostring(countdown_xp)))
		self._lp_xp_gain:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(self._gained_xp))))

		self._next_level_xp = total_xp

		if countdown_xp == 0 then
			WalletGuiObject.refresh()
			self._lp_xp_gain:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(self._experience_added))))
			self:step_stage_up()
		end

		return
	end

	self._next_level_xp = self._next_level_xp - xp_gained_frame

	if self._next_level_xp < total_xp then
		WalletGuiObject.refresh()

		xp_gained_frame = xp_gained_frame + self._next_level_xp - total_xp
		self._next_level_xp = total_xp

		self:step_stage_up()
	end

	xp_gained_frame = math.min(xp_gained_frame, self._next_level_xp)
	self._current_xp = self._current_xp + xp_gained_frame
	self._gained_xp = self._gained_xp + xp_gained_frame

	if data.end_t.current ~= 0 then
		self._top_speed = self._top_speed or 1
		local ex = (data.end_t.total - self._next_level_xp) / data.end_t.current
		self._speed = math.max(1, self._top_speed / (self._top_speed * 2)^ex)
	end

	local ratio = 1 - self._next_level_xp / data.end_t.total

	self._lp_circle:set_color(Color(ratio, 1, 1))

	if data.end_t.level < managers.experience:level_cap() then
		local floored_gained = math.max(math.floor(self._gained_xp), 0)

		self._experience_text_panel:child("stat"):set_text(managers.money:add_decimal_marks_to_string(tostring(self._experience_added - floored_gained)))
		self._lp_xp_curr:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(self._current_xp))))
		self._lp_xp_gain:set_text(managers.money:add_decimal_marks_to_string(tostring(floored_gained)))
		self._lp_xp_nl:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(self._next_level_xp))))
	else
		self._lp_xp_nl:set_text("")
	end
end

function HUDStageEndScreen:stage_experience_end(t, dt)
	local data = self._data
	local ratio = data.end_t.current / data.end_t.total
	self._static_current_xp = data.end_t.xp
	self._static_gained_xp = data.gained
	self._current_xp = self._static_current_xp
	self._gained_xp = self._static_gained_xp
	local floored_gained = math.floor(self._gained_xp)

	if data.end_t.level < managers.experience:level_cap() then
		self._experience_text_panel:child("stat"):set_text(managers.money:add_decimal_marks_to_string(tostring(self._experience_added - floored_gained)))
		self._experience_text_panel:hide()
		self._lp_xp_curr:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(self._current_xp))))
		self._lp_xp_gain:set_text(managers.money:add_decimal_marks_to_string(tostring(floored_gained)))
		self._lp_circle:set_color(Color(ratio, 1, 1))
		self._lp_xp_nl:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(data.end_t.total - data.end_t.current))))
	else
		self._lp_circle:set_color(Color(1, 1, 1))
		self._lp_xp_nl:set_text("")
	end

	managers.menu_component:post_event("count_1_finished")
	self:step_stage_up()
end

function HUDStageEndScreen:stage_done(t, dt)
	if self._all_done then
		return
	end

	if self._done_clbk then
		WalletGuiObject.refresh()
		self._skip_text:set_visible(false)
		self._done_clbk(true)

		self._all_done = true
	end
end

function HUDStageEndScreen:level_up(level)
	local function level_text_func(o, ding_scale, level)
		local center_x, center_y = o:center()
		local size = tweak_data.menu.pd2_massive_font_size
		local ding_size = size * (1 + ding_scale)

		wait(0.1)
		o:set_text(tostring(level))
		self:give_skill_points(1)
	end

	local function text_ding_func(o)
		local TOTAL_T = 0.4
		local t = TOTAL_T
		local mul = 1
		local size = o:font_size()

		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			local ratio = math.max(t / TOTAL_T, 0)
			mul = mul + dt * 4

			o:set_font_size(size * mul)
			o:set_alpha(ratio)
			o:set_color(math.lerp(Color.white, tweak_data.screen_colors.button_stage_2, 1 - ratio))
		end

		o:parent():remove(o)
	end

	local function circle_ding_func(o)
		wait(0.15)

		local TOTAL_T = 0.6
		local t = TOTAL_T
		local mul = 1
		local c_x, c_y = o:center()
		local size = o:w()

		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			local ratio = math.max(t / TOTAL_T, 0)
			mul = mul + dt * 0.75

			o:set_size(size * mul, size * mul)
			o:set_center(c_x, c_y)
			o:set_alpha(ratio)
			o:set_color(math.lerp(Color.white, tweak_data.screen_colors.button_stage_2, 1 - ratio))
		end

		o:parent():remove(o)
	end

	local function package_func(o, data)
		local start_alpha = o:alpha()

		for _, item in pairs(self._package_items) do
			item:close()
		end

		self._package_items = {}

		wait(0.6)

		local new_items = {}

		if data.announcements then
			for i, announcement in ipairs(data.announcements) do
				table.insert(new_items, {
					announcement = announcement
				})
			end
		end

		if data.upgrades then
			for i, upgrade in ipairs(data.upgrades) do
				if not managers.upgrades:is_upgrade_locked(upgrade) then
					table.insert(new_items, {
						upgrade = upgrade
					})
				end
			end
		end

		self._package_forepanel:child("title_text"):set_text(managers.localization:to_upper_text("menu_es_package_unlocked_" .. (#new_items == 1 and "singular" or "plural")))

		if HUDPackageUnlockedItem.MAX_DISPLAYED < #new_items then
			Application:error(string.format("HUDStageEndScreen: Please, max %i announcements+upgrades per level in tweak_data.level_tree, rest will not be shown in gui!", HUDPackageUnlockedItem.MAX_DISPLAYED))
		end

		over(0.42, function (p)
			o:set_alpha(math.cos(652 * p) * math.rand(0.4, 0.8))
		end)
		over(0.04, function (p)
			o:set_alpha(math.step(o:alpha(), 1, p))
		end)
		o:set_alpha(1)

		local row = nil

		for i, item in ipairs(new_items) do
			row = i % HUDPackageUnlockedItem.MAX_DISPLAYED

			if self._package_items[row] then
				wait(0.23)
				self._package_items[row]:close()

				self._package_items[row] = nil

				wait(0.33)
			end

			item.unlocks = #new_items
			self._package_items[row] = HUDPackageUnlockedItem:new(o, math.clamp(item.unlocks, HUDPackageUnlockedItem.MIN_DISPLAYED, HUDPackageUnlockedItem.MAX_DISPLAYED) - row, item, self)

			wait(0.27)
		end
	end

	managers.menu_component:post_event("stinger_levelup")

	local ding_circle = self._lp_backpanel:bitmap({
		texture = "guis/textures/pd2/endscreen/exp_ring",
		rotation = 360,
		blend_mode = "add",
		layer = 0,
		w = self._lp_circle:w(),
		h = self._lp_circle:h(),
		x = self._lp_circle:x(),
		y = self._lp_circle:y(),
		color = Color.white
	})

	ding_circle:animate(circle_ding_func)

	local ding_text = self._lp_forepanel:text({
		vertical = "center",
		align = "center",
		rotation = 360,
		blend_mode = "add",
		layer = 0,
		w = self._lp_text:w(),
		h = self._lp_text:h(),
		x = self._lp_text:x(),
		y = self._lp_text:y(),
		color = Color.white,
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		text = self._lp_text:text()
	})

	ding_text:animate(text_ding_func)
	self._lp_circle:set_color(Color(level == managers.experience:level_cap() and 1 or 0, 1, 1))
	self._lp_text:stop()
	self._lp_text:animate(level_text_func, 1, tostring(level))

	local package_unlocked = tweak_data.upgrades.level_tree[level]

	if package_unlocked then
		self._package_forepanel:stop()
		self._package_forepanel:animate(package_func, package_unlocked)
	end

	return package_unlocked
end

function HUDStageEndScreen:reset_skill_points()
	self:give_skill_points(-self._num_skill_points_gained)
end

function HUDStageEndScreen:give_skill_points(points)
	self._num_skill_points_gained = self._num_skill_points_gained + points
	self._update_skill_points = true
end

function HUDStageEndScreen:stage_debug_loop(t, dt)
	self:reset_stage()

	self._wait_t = 3
end

function HUDStageEndScreen:set_speed_up(multiplier)
	self._speed_up = multiplier
end

function HUDStageEndScreen:update(t, dt)
	local stage = self._stage and self.stages[self._stage]
	local ddt = dt * math.clamp(self._speed_up or 1, 1, stage and stage[2] or 5)

	if self._wait_t then
		self._wait_t = self._wait_t - ddt

		if self._wait_t <= 0 then
			self._wait_t = nil
		end
	elseif stage then
		self[stage[1]](self, t, ddt)
	end

	if self._update_skill_points then
		self._update_skill_points = nil

		local function skill_point_text_func(o, text)
			local center_x, center_y = o:center()
			local content_font_size = tweak_data.menu.pd2_small_font_size
			local start_font_size = o:font_size()

			o:set_rotation(360)
			o:set_color(tweak_data.screen_colors.text)
			over(0.12, function (p)
				o:set_font_size(math.lerp(start_font_size, content_font_size * 0.2, p))
			end)
			over(0.07, function (p)
				o:set_font_size(math.lerp(content_font_size * 0.2, content_font_size * 2, p))
			end)
			o:set_text(text)
			over(0.19, function (p)
				o:set_font_size(math.lerp(content_font_size * 2, content_font_size, math.sin(p * 180)))
				o:set_color(math.lerp(tweak_data.screen_colors.text, tweak_data.screen_colors.button_stage_2, math.clamp(math.sin(p * 180), 0, 1)))
			end)
			o:set_font_size(content_font_size)
			o:set_color(tweak_data.screen_colors.text)
			o:set_rotation(0)

			local t = 0
			local dt = 0

			while true do
				dt = coroutine.yield() * (self._speed_up or 1)
				t = (t + dt * 90) % 180
				local color = math.lerp(tweak_data.screen_colors.text, tweak_data.screen_colors.resource, math.clamp(math.sin(t), 0, 1))

				o:set_color(color)
			end
		end

		local function animate_new_skillpoints(o)
			while true do
				over(1, function (p)
					o:set_alpha(math.lerp(0.4, 0.85, math.sin(p * 180)))
				end)
			end
		end

		self._lp_sp_gain:set_text(tostring(self._num_skill_points_gained))

		local skill_glow = self._lp_sp_gain:parent():child("skill_glow")
		skill_glow = skill_glow or self._lp_sp_gain:parent():bitmap({
			texture = "guis/textures/pd2/crimenet_marker_glow",
			name = "skill_glow",
			h = 40,
			blend_mode = "add",
			rotation = 360,
			layer = 0,
			w = self._lp_sp_gain:parent():w() * 0.25,
			color = tweak_data.screen_colors.button_stage_3
		})

		skill_glow:set_center_y(self._lp_skill_points:center_y())
		skill_glow:set_center_x(self._lp_sp_gain:left() + 5)
		skill_glow:stop()

		local visible = self._num_skill_points_gained > 0

		if visible then
			skill_glow:animate(animate_new_skillpoints)
		end

		skill_glow:set_visible(visible)
		self._lp_skill_points:set_visible(visible)
		self._lp_sp_gain:set_visible(visible)
		self._lp_sp_info:set_visible(visible)
	end

	if alive(self._skip_text) then
		local a = 0.75 + math.abs(math.sin(t * 120) * 0.25)

		if self._speed_up and self._speed_up > 1 then
			a = 0
		end

		self._skip_text:set_alpha(a)
	end
end

function HUDStageEndScreen:set_continue_button_text(text)
	print("HUDStageEndScreen:set_continue_button_text( text )", text)

	self._button_text = text
end

function HUDStageEndScreen:set_success(success, server_left)
	print("HUDStageEndScreen:set_success( success, server_left )", success, server_left)

	self._success = success
	self._server_left = server_left
	local stage_status = success and utf8.to_upper(managers.localization:text("menu_success")) or utf8.to_upper(managers.localization:text("menu_failed"))

	self._foreground_layer_safe:child("stage_text"):set_text(self._stage_name .. ": " .. stage_status)
	self._background_layer_full:child("stage_text"):set_text(self._stage_name .. ": " .. stage_status)
end

function HUDStageEndScreen:set_special_packages(params)
	self._challenge_completed = params.challenge_completed
	self._gage_assignment = params.gage_assignment
	self._ghost_bonus = params.ghost_bonus
	self._tango_mission_completed = params.tango_mission_completed

	self:_check_special_packages()
end

function HUDStageEndScreen:set_statistics(criminals_completed, success)
	print("HUDStageEndScreen:set_statistics( criminals_completed, success )", criminals_completed, success)

	self._criminals_completed = criminals_completed
	self._success = success
	local stage_status = success and utf8.to_upper(managers.localization:text("menu_success")) or utf8.to_upper(managers.localization:text("menu_failed"))

	self._foreground_layer_safe:child("stage_text"):set_text(self._stage_name .. ": " .. stage_status)
	self._background_layer_full:child("stage_text"):set_text(self._stage_name .. ": " .. stage_status)
end

function HUDStageEndScreen:animate_level_progress(o, data)
	local function animate_func(o, self, data)
		local function spin_func(self, o, xp, end_xp, total_xp, current_xp, gained_xp, speed, breaks)
			local dt = 0
			local ratio = xp / total_xp
			local diff_xp = 0

			o:set_color(Color(ratio, 1, 1))
			self._lp_xp_curr:set_text(managers.money:add_decimal_marks_to_string(math.floor(tostring(current_xp))))
			self._lp_xp_gain:set_text(managers.money:add_decimal_marks_to_string(math.floor(tostring(gained_xp))))
			self._lp_xp_nl:set_text(managers.money:add_decimal_marks_to_string(math.floor(tostring(total_xp - xp))))

			while true do
				dt = coroutine.yield() * (self._speed_up or 1)
				diff_xp = xp
				xp = math.min(xp + dt * total_xp * 0.2 * speed, end_xp)
				diff_xp = xp - diff_xp
				speed = speed + dt * 0.5

				if breaks and end_xp ~= 0 then
					speed = math.lerp(speed, 1, xp / end_xp)
				end

				ratio = xp / total_xp
				gained_xp = gained_xp + diff_xp
				current_xp = current_xp + diff_xp

				o:set_color(Color(ratio, 1, 1))
				self._lp_xp_curr:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(current_xp))))
				self._lp_xp_gain:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(gained_xp))))
				self._lp_xp_nl:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(total_xp - xp))))

				if xp == end_xp then
					return current_xp, gained_xp, speed
				end
			end
		end

		local function wait_func(self, o, wait_time)
			local dt = 0
			local time = wait_time

			while true do
				if self._skip then
					self._skip = nil

					return
				end

				dt = coroutine.yield() * (self._speed_up or 1)
				time = time - dt

				if time <= 0 then
					return
				end
			end
		end

		local base_font_size = self._lp_text:font_size()

		local function ding_func(o, font_size, ding_size, level)
			local center_x, center_y = o:center()
			local size = font_size
			local ding_size = size * (1 + ding_size)
			local color = o:color()

			over(0.1, function (p)
				o:set_font_size(math.lerp(size, ding_size, p))
			end)
			o:set_text(tostring(level))
			over(0.18, function (p)
				o:set_font_size(math.lerp(ding_size, size, p))
				o:set_color(math.lerp(color, tweak_data.screen_colors.important_2, math.sin(p * 180)))
			end)
		end

		local function package_func(o, data)
			local start_alpha = o:alpha()

			over(0.04, function (p)
				o:set_alpha(math.lerp(start_alpha, 0, p))
			end)

			if data.name_id then
				local item_string = ""
				local items = {}

				if data.announcements then
					self._package_unlocked_text:set_text(utf8.to_upper(managers.localization:text("menu_es_announcements")))
					self._package_upgrade_text:set_text("")
					self._package_picture:set_image("guis/textures/pd2/mission_briefing/calendar_stamp")
					self._package_unlocked_text:set_align("center")

					for _, string_id in ipairs(data.announcements) do
						item_string = item_string .. managers.localization:text(string_id) .. "\n"
					end
				elseif data.upgrades then
					self._package_unlocked_text:set_text(utf8.to_upper(managers.localization:text("menu_package_unlocked") .. ": '" .. managers.localization:text(data.name_id) .. "'"))
					self._package_upgrade_text:set_text(utf8.to_upper(managers.localization:text("menu_package_upgrade", {
						package = data.name_id
					})))
					self._package_unlocked_text:set_align("left")

					for _, id in ipairs(data.upgrades) do
						local upgrade = tweak_data.upgrades.definitions[id]

						if upgrade then
							local category = upgrade.category
							local upgrade_string = ""
							local localized = false

							if category == "weapon" then
								upgrade_string = managers.weapon_factory:get_weapon_name_by_factory_id(upgrade.factory_id)
								localized = true
							elseif category == "crafting" then
								upgrade_string = tweak_data.weapon[upgrade.weapon_id].name_id
							elseif category == "equipment" or category == "armor" or category == "ammo" or category == "what_is_this" then
								upgrade_string = upgrade.name_id
							elseif category == "rep_upgrade" then
								upgrade_string = "menu_es_rep_upgrade"
							end

							if not localized then
								item_string = item_string .. managers.localization:text(upgrade_string) .. "\n"
							else
								item_string = item_string .. upgrade_string .. "\n"
							end
						else
							item_string = item_string .. "! " .. id .. " !" .. "\n"
						end
					end

					local first_upgrade = tweak_data.upgrades.definitions[data.upgrades[1]]

					if first_upgrade and first_upgrade.category == "weapon" then
						local icon_texture_path, icon_rarity_path = managers.blackmarket:get_weapon_icon_path(weapon_id, nil)

						self._package_picture:set_image(icon_texture_path)
					else
						self._package_picture:set_image("guis/textures/pd2/endscreen/test_icon_package")
					end
				end

				local w = self._package_picture:texture_width()
				local h = self._package_picture:texture_height()
				local sh = math.min(self._package_forepanel:w() * 0.3, self._package_forepanel:w() * 0.3 / (w / h))
				local sw = math.min(self._package_forepanel:w() * 0.3, self._package_forepanel:w() * 0.3 * w / h)
				local cx, cy = self._package_picture:center()

				self._package_picture:set_size(sw, sh)
				self._package_picture:set_center(cx, cy)

				local _, _, _, h = self._package_upgrade_text:text_rect()

				self._package_items:set_top(h + self._package_upgrade_text:y())
				self._package_items:set_left(self._package_upgrade_text:left())
				self._package_items:set_text(item_string)
			else
				self._package_unlocked_text:set_text("")
				self._package_upgrade_text:set_text("")
				self._package_items:set_text("")
				self._package_picture:hide()
			end

			over(0.08, function (p)
				o:set_alpha(math.lerp(0, 1, p))
			end)
		end

		if data.gained == 0 and data.start_t.current == data.start_t.total then
			self._lp_text:set_text(tostring(data.start_t.level))
			self._lp_xp_gain:hide()
			self._lp_xp_curr:hide()
			self._lp_xp_nl:hide()
			self._lp_curr_xp:hide()
			self._lp_xp_gained:hide()
			self._lp_next_level:hide()
			o:set_color(Color(1, 1, 1))

			if self._done_clbk then
				self._done_clbk(true)
			end

			return
		end

		self._lp_xp_gain:show()
		self._lp_xp_curr:show()
		self._lp_xp_nl:show()
		self._lp_curr_xp:show()
		self._lp_xp_gained:show()
		self._lp_next_level:show()

		local current_xp = data.start_t.xp - data.start_t.current
		local gained_xp = 0
		local speed = 1.5

		self._lp_text:set_text(tostring(data.start_t.level))
		self._lp_xp_gain:hide()

		current_xp = data.start_t.xp
		gained_xp = 0
		speed = 1

		o:set_color(Color(data.start_t.current / data.start_t.total, 1, 1))
		self._lp_xp_curr:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(data.start_t.xp))))
		self._lp_xp_gain:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(gained_xp))))
		self._lp_xp_nl:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(data.start_t.total - data.start_t.current))))
		self._lp_xp_gain:show()

		if data.gained == 0 then
			if self._done_clbk then
				self._done_clbk(true)
			end

			return
		end

		wait_func(self, o, 1.3)

		local last_level = data.start_t.level

		for i = 1, #data do
			current_xp, gained_xp, speed = spin_func(self, o, data[i].current, data[i].total, data[i].total, current_xp, gained_xp, speed)
			local package_unlocked = tweak_data.upgrades.level_tree[data[i].level]

			self._lp_text:stop()
			self._lp_text:animate(ding_func, base_font_size, math.min(1, data[i].level / managers.experience:level_cap() * (package_unlocked and 10 or 1)), data[i].level)

			last_level = data[i].level

			if package_unlocked then
				self._package_forepanel:stop()
				self._package_forepanel:animate(package_func, package_unlocked)
			end
		end

		current_xp, gained_xp, speed = spin_func(self, o, #data > 0 and 0 or data.start_t.current, data.end_t.current, data.end_t.total, current_xp, gained_xp, speed, true)

		if last_level ~= data.end_t.level then
			self._lp_text:stop()
			self._lp_text:animate(ding_func, base_font_size, data.end_t.level / managers.experience:level_cap(), tostring(data.end_t.level))

			local package_unlocked = tweak_data.upgrades.level_tree[data.end_t.level]

			if package_unlocked then
				self._package_forepanel:stop()
				self._package_forepanel:animate(package_func, package_unlocked)
			end
		else
			self._lp_text:set_text(tostring(data.end_t.level))
		end

		self._lp_xp_curr:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(data.end_t.xp))))
		self._lp_xp_gain:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(data.gained))))
		self._lp_xp_nl:set_text(managers.money:add_decimal_marks_to_string(tostring(math.floor(data.end_t.total - data.end_t.current))))

		if self._done_clbk then
			self._done_clbk(true)
		end
	end

	o:animate(animate_func, self, data)
end

function HUDStageEndScreen:send_xp_data(data, done_clbk)
	self._data = data
	self._done_clbk = done_clbk

	print("HUDStageEndScreen:send_xp_data", inspect(data), done_clbk)
	self:start_experience_gain()
end

function HUDStageEndScreen:set_group_statistics(best_kills, best_kills_score, best_special_kills, best_special_kills_score, best_accuracy, best_accuracy_score, most_downs, most_downs_score, total_kills, total_specials_kills, total_head_shots, group_accuracy, group_downs)
	print("HUDStageEndScreen:set_group_statistics( best_kills, best_kills_score, best_special_kills, best_special_kills_score, best_accuracy, best_accuracy_score, most_downs, most_downs_score, total_kills, total_specials_kills, total_head_shots, group_accuracy, group_downs )", best_kills, best_kills_score, best_special_kills, best_special_kills_score, best_accuracy, best_accuracy_score, most_downs, most_downs_score, total_kills, total_specials_kills, total_head_shots, group_accuracy, group_downs)

	self._lot_of_stuff = {
		best_kills,
		best_kills_score,
		best_special_kills,
		best_special_kills_score,
		best_accuracy,
		best_accuracy_score,
		most_downs,
		most_downs_score,
		total_kills,
		total_specials_kills,
		total_head_shots,
		group_accuracy,
		group_downs
	}
end

function HUDStageEndScreen:reload()
	self._backdrop:close()

	self._backdrop = nil

	HUDStageEndScreen.init(self, self._hud, self._workspace)
end
