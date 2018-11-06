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
		text = managers.localization:to_upper_text("menu_skirmish_random"),
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
	local briefing_text = contract_panel:text({
		wrap = true,
		y = 10,
		x = 10,
		wrap_word = true,
		text = managers.localization:text("menu_skirmish_random_briefing"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		w = text_width
	})
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
