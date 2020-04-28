require("lib/managers/menu/ExtendedUiElemets")
require("lib/managers/menu/SkirmishBriefingProgress")

SkirmishContractMenuComponent = SkirmishContractMenuComponent or class()

function SkirmishContractMenuComponent:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._panel = ws:panel():panel({
		layer = 51
	})
	self._fullscreen_panel = fullscreen_ws:panel():panel({
		layer = 50
	})
	local is_win_32 = SystemInfo:platform() == Idstring("WIN32")
	local is_nextgen = SystemInfo:platform() == Idstring("PS4") or SystemInfo:platform() == Idstring("XB1")
	local bg_overlay = BlurSheet:new(self._fullscreen_panel, {
		name = "bg_overlay",
		layer = 1,
		color = Color(0.75, 0, 0, 0)
	})
	local title_text = FineText:new(self._panel, {
		name = "title_text",
		layer = 1,
		text = managers.localization:to_upper_text("menu_skirmish_selected"),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size
	})
	local width = 900
	local height = 580
	local contract_panel = self._panel:panel({
		name = "contract_panel",
		layer = 5,
		w = width,
		h = height
	})

	BoxGuiObject:new(contract_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	contract_panel:set_center(self._panel:width() * 0.5, self._panel:height() * 0.5)
	title_text:set_leftbottom(contract_panel:lefttop())

	local text_width = width - (is_win_32 and 389 or 356)
	text_width = text_width - 3
	local briefing_text = contract_panel:text({
		wrap = true,
		y = 10,
		x = 10,
		wrap_word = true,
		text = managers.localization:text("heist_skm_random_briefing"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		w = text_width
	})
	local job_data = node:parameters().menu_component_data
	local job_id = job_data.job_id
	local job_chain = tweak_data.narrative:job_chain(job_id)
	local job_stars = math.ceil(tweak_data.narrative:job_data(job_id).jc / 10)
	local difficulty_stars = job_data.difficulty_id - 2
	local job_heat_value = managers.job:get_job_heat(job_id)
	local ignore_heat = job_heat_value > 0 and job_data.customize_contract
	local contract_visuals = job_data.contract_visuals or {}
	local xp_min = contract_visuals.min_mission_xp and contract_visuals.min_mission_xp or 0
	local xp_max = contract_visuals.max_mission_xp and contract_visuals.max_mission_xp or 0
	local total_xp_min = managers.experience:get_contract_xp_by_stars(job_id, job_stars, difficulty_stars, job_data.professional, #job_chain, {
		mission_xp = xp_min,
		ignore_heat = ignore_heat
	})
	local total_xp_max = managers.experience:get_contract_xp_by_stars(job_id, job_stars, difficulty_stars, job_data.professional, #job_chain, {
		mission_xp = xp_max,
		ignore_heat = ignore_heat
	})
	local xp_text_min = managers.money:add_decimal_marks_to_string(tostring(math.round(total_xp_min)))
	local xp_text_max = managers.money:add_decimal_marks_to_string(tostring(math.round(total_xp_max)))
	local job_xp_text = total_xp_min < total_xp_max and managers.localization:text("menu_number_range", {
		min = xp_text_min,
		max = xp_text_max
	}) or xp_text_min
	local max_ransom = tweak_data.skirmish.ransom_amounts[select(2, managers.skirmish:wave_range())]
	local total_payout_text = managers.experience:cash_string(max_ransom)
	local wave_panel = ExtendedPanel:new(contract_panel, {
		x = 10,
		w = text_width
	})
	local placer = UiPlacer:new(0, 10, 5, 2)
	local min_wave, max_wave = managers.skirmish:wave_range()

	placer:add_row(FineText:new(wave_panel, {
		text = managers.localization:to_upper_text("cn_menu_skirmish_contract_waves_header"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.skirmish_color,
		w = text_width
	}))
	placer:add_right(FineText:new(wave_panel, {
		text = string.format("%d - %d", managers.skirmish:wave_range()),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.skirmish_color
	}))

	local skirmish_progress = SkirmishBriefingProgress:new(wave_panel, {
		align_top = true,
		w = text_width * 0.8,
		static_wave = job_data.skirmish_wave
	})

	placer:add_row(skirmish_progress)

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

	placer:new_row(0, 10)
	placer:add_row(experience_text)
	placer:add_right(FineText:new(wave_panel, {
		text = job_xp_text,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	}), (is_ransom_widest and text_width_diff or 0) + 5)
	placer:add_row(ransom_text)
	placer:add_right(FineText:new(wave_panel, {
		text = total_payout_text,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	}), (is_ransom_widest and 0 or text_width_diff) + 5)
	wave_panel:set_h(placer:current_bottom())
	wave_panel:set_bottom(math.floor(contract_panel:h() - 10))

	local video_aspect_ratio = 1.7777777777777777
	local video_width = width - briefing_text:right() - 20
	local video_height = video_width / video_aspect_ratio
	local video_panel = contract_panel:panel({
		name = "video_panel",
		w = video_width,
		h = video_height
	})

	video_panel:set_righttop(width - 10, 10)

	local crimenet_videos = tweak_data.skirmish.random_skirmish.crimenet_videos
	local briefing_video = video_panel:video({
		blend_mode = "add",
		name = "briefing_video",
		loop = true,
		video = "movies/" .. crimenet_videos[math.random(#crimenet_videos)],
		width = video_panel:width(),
		height = video_panel:height(),
		color = tweak_data.screen_colors.button_stage_2
	})

	BoxGuiObject:new(video_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	managers.menu_component:disable_crimenet()
	managers.menu:active_menu().input:deactivate_controller_mouse()
end

function SkirmishContractMenuComponent:close()
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
	managers.menu:active_menu().input:activate_controller_mouse()
end
