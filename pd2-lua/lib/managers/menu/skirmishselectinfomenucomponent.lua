require("lib/managers/menu/ExtendedUiElemets")
require("lib/managers/menu/BoxGuiObject")
require("lib/managers/menu/SkirmishBriefingProgress")

SkirmishSelectInfoMenuComponent = SkirmishSelectInfoMenuComponent or class()
local padding = 10

function SkirmishSelectInfoMenuComponent:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._panel = ws:panel():panel({
		layer = 1099
	})
	self._fullscreen_panel = fullscreen_ws:panel():panel({
		layer = 1100
	})
	local main_panel = ExtendedPanel:new(self._panel, {
		w = self._panel:w() * 0.45 - padding,
		h = self._panel:h() * 0.7
	})

	main_panel:set_left(0)
	main_panel:set_top(padding * 2 + tweak_data.menu.pd2_large_font_size * 2)

	local text_width = main_panel:w() - 2 * padding
	local title_text = FineText:new(self._panel, {
		w = text_width,
		text = managers.localization:to_upper_text("menu_skirmish_selected"),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size
	})
	local description_text = FineText:new(self._panel, {
		w = text_width,
		text = managers.localization:to_upper_text("menu_weekly_skirmish_tab_description"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})

	description_text:set_left(main_panel:left())
	description_text:set_bottom(main_panel:top())

	local map_selection_text = FineText:new(self._panel, {
		w = text_width,
		text = managers.localization:to_upper_text("menu_skirmish_map_selection"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})

	map_selection_text:set_left(main_panel:right() + padding)
	map_selection_text:set_bottom(main_panel:top())

	local pick_heist_text = FineText:new(self._panel, {
		alpha = 0.4,
		w = text_width,
		text = managers.localization:to_upper_text("menu_skirmish_pick_heist"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})

	pick_heist_text:set_right(self._panel:w())
	pick_heist_text:set_bottom(main_panel:top())

	if pick_heist_text:left() - padding < map_selection_text:right() then
		pick_heist_text:set_visible(false)
	end

	local placer = UiPlacer:new(padding, padding, 0, padding)

	placer:add_row(FineText:new(main_panel, {
		wrap = true,
		wrap_word = true,
		w = text_width,
		text = managers.localization:text("menu_skirmish_selected_briefing"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	}))

	local min_wave, max_wave = managers.skirmish:wave_range()
	local wave_panel = ExtendedPanel:new(main_panel, {
		x = 10,
		w = text_width
	})
	local wave_placer = UiPlacer:new(0, 10, 5, 2)
	local skirmish_progress_panel = wave_panel:panel()
	local card_texture, card_texture_rect = tweak_data.hud_icons:get_icon_data("downcard_overkill_deck")
	local arrow_texture, arrow_texture_rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local start_wave, end_wave = managers.skirmish:wave_range()
	local wave_diff = end_wave - start_wave
	local base_color = tweak_data.screen_colors.text:with_alpha(0.4)
	local progress_padding = 15
	local progress_width = skirmish_progress_panel:w() - 2 * progress_padding - 4
	local progress_bar = skirmish_progress_panel:rect({
		h = 8,
		y = 50,
		x = progress_padding - 2,
		w = progress_width + 4,
		color = base_color
	})
	local wave_number, wave_progress, card, arrow, indicator, number, color, cx = nil

	for i = 0, wave_diff do
		wave_number = start_wave + i
		wave_progress = i / wave_diff
		cx = progress_padding + progress_width * wave_progress
		color = i == 0 and tweak_data.screen_colors.skirmish_color or base_color

		if tweak_data.skirmish.additional_lootdrops[wave_number] then
			card = skirmish_progress_panel:bitmap({
				w = 26,
				h = 36,
				texture = card_texture,
				texture_rect = card_texture_rect
			})

			card:set_center_x(cx)

			arrow = skirmish_progress_panel:bitmap({
				h = 6,
				w = 12,
				rotation = 180,
				texture = arrow_texture,
				texture_rect = arrow_texture_rect,
				color = color
			})

			arrow:set_center_x(cx)
			arrow:set_bottom(progress_bar:top() - 6)
		end

		indicator = skirmish_progress_panel:rect({
			w = 4,
			laer = 1,
			y = progress_bar:top() - 4,
			h = i == 0 and progress_bar:h() + 4 or 4,
			color = color
		})

		indicator:set_center_x(cx)

		number = FineText:new(skirmish_progress_panel, {
			text = tostring(wave_number),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = color,
			y = progress_bar:bottom()
		})

		number:set_center_x(cx)
	end

	skirmish_progress_panel:set_h(progress_bar:bottom() + tweak_data.menu.pd2_small_font_size)
	wave_placer:add_row(skirmish_progress_panel)

	local skirmish_exp = {
		max = 135900,
		min = 8000
	}
	local job_id = "skm_mus"
	local job_chain = tweak_data.narrative:job_chain(job_id)
	local job_stars = math.ceil(tweak_data.narrative:job_data(job_id).jc / 10)
	local difficulty_stars = tweak_data:difficulty_to_index("overkill_145") - 2
	local total_xp_min = managers.experience:get_contract_xp_by_stars(job_id, job_stars, difficulty_stars, false, #job_chain, {
		ignore_heat = true,
		mission_xp = skirmish_exp.min
	})
	local total_xp_max = managers.experience:get_contract_xp_by_stars(job_id, job_stars, difficulty_stars, false, #job_chain, {
		ignore_heat = true,
		mission_xp = skirmish_exp.max
	})
	local xp_text_min = managers.money:add_decimal_marks_to_string(tostring(math.round(total_xp_min)))
	local xp_text_max = managers.money:add_decimal_marks_to_string(tostring(math.round(total_xp_max)))
	local job_xp_text = total_xp_min < total_xp_max and managers.localization:text("menu_number_range", {
		min = xp_text_min,
		max = xp_text_max
	}) or xp_text_min
	local max_ransom = tweak_data.skirmish.ransom_amounts[end_wave]
	local total_payout_text = managers.experience:cash_string(max_ransom)
	local experience_text = FineText:new(wave_panel, {
		text = managers.localization:to_upper_text("menu_experience"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		w = text_width,
		color = tweak_data.screen_colors.text
	})
	local ransom_text = FineText:new(wave_panel, {
		text = managers.localization:to_upper_text("cn_menu_skirmish_contract_ransom_header"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		w = text_width,
		color = tweak_data.screen_colors.text
	})
	local text_width_diff = math.abs(experience_text:width() - ransom_text:width())
	local is_ransom_widest = experience_text:width() < ransom_text:width()

	wave_placer:new_row(0, 10)
	wave_placer:add_row(experience_text)
	wave_placer:add_right(FineText:new(wave_panel, {
		text = job_xp_text,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	}), (is_ransom_widest and text_width_diff or 0) + 5)
	wave_placer:add_row(ransom_text)
	wave_placer:add_right(FineText:new(wave_panel, {
		text = total_payout_text,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	}), (is_ransom_widest and 0 or text_width_diff) + 5)
	wave_panel:set_h(wave_placer:current_bottom())
	wave_panel:set_bottom(main_panel:h() - padding)
	BoxGuiObject:new(main_panel:panel({
		layer = 100
	}), {
		sides = {
			1,
			1,
			1,
			1
		}
	})
end

function SkirmishSelectInfoMenuComponent:close()
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end
