HUDHeistTimer = HUDHeistTimer or class()

function HUDHeistTimer:init(hud, tweak_hud)
	self._hud_panel = hud.panel

	if self._hud_panel:child("heist_timer_panel") then
		self._hud_panel:remove(self._hud_panel:child("heist_timer_panel"))
	end

	self._heist_timer_panel = self._hud_panel:panel({
		y = 0,
		name = "heist_timer_panel",
		h = 40,
		visible = true,
		layer = 0,
		valign = "top"
	})
	self._timer_text = self._heist_timer_panel:text({
		name = "timer_text",
		vertical = "top",
		word_wrap = false,
		wrap = false,
		font_size = 28,
		align = "center",
		text = "00:00",
		layer = 1,
		font = tweak_data.hud.medium_font_noshadow,
		color = Color.white
	})
	self._last_time = 0
	self._enabled = not tweak_hud.no_timer

	if not self._enabled then
		self._heist_timer_panel:hide()
	end
end

function HUDHeistTimer:set_time(time)
	local inverted = false

	if time < 0 then
		inverted = true
		time = math.abs(time)
	end

	if not self._enabled or not inverted and math.floor(time) < self._last_time then
		return
	end

	self._last_time = time
	time = math.floor(time)
	local hours = math.floor(time / 3600)
	time = time - hours * 3600
	local minutes = math.floor(time / 60)
	time = time - minutes * 60
	local seconds = math.round(time)
	local text = hours > 0 and (hours < 10 and "0" .. hours or hours) .. ":" or ""
	local text = text .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)

	self._timer_text:set_text(text)
end

function HUDHeistTimer:modify_time(time)
	self:set_time(self._last_time + time)
end

function HUDHeistTimer:reset()
	self._last_time = 0
end

if _G.IS_VR then
	require("lib/managers/hud/vr/HUDHeistTimerVR")
end
