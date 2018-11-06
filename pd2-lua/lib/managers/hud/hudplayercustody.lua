HUDPlayerCustody = HUDPlayerCustody or class()

function HUDPlayerCustody:init(hud)
	self._hud = hud
	self._hud_panel = hud.panel
	self._last_respawn_type_is_ai_trade = false

	if self._hud_panel:child("custody_panel") then
		self._hud_panel:remove(self._hud_panel:child("custody_panel"))
	end

	local custody_panel = self._hud_panel:panel({
		valign = "grow",
		name = "custody_panel",
		halign = "grow"
	})
	local timer_msg = custody_panel:text({
		text = "something IN",
		vertical = "center",
		h = 40,
		name = "timer_msg",
		w = 400,
		align = "center",
		font = tweak_data.hud_custody.custody_font,
		font_size = tweak_data.hud_downed.timer_message_size
	})

	timer_msg:set_text(utf8.to_upper(managers.localization:text("hud_respawning_in")))

	local _, _, w, h = timer_msg:text_rect()

	timer_msg:set_h(h)
	timer_msg:set_x(math.round(self._hud_panel:center_x() - timer_msg:w() / 2))
	timer_msg:set_y(28)

	local timer = custody_panel:text({
		text = "00:00",
		vertical = "bottom",
		h = 32,
		name = "timer",
		w = 400,
		align = "center",
		font_size = 42,
		font = tweak_data.hud_custody.custody_font_large
	})
	local _, _, w, h = timer:text_rect()

	timer:set_h(h)
	timer:set_y(math.round(timer_msg:bottom() - 6))
	timer:set_center_x(self._hud_panel:center_x())

	self._timer = timer
	self._last_time = -1
	self._last_trade_delay_time = -1
	local civilians_killed = custody_panel:text({
		vertical = "top",
		name = "civilians_killed",
		h = 32,
		w = 400,
		align = "right",
		text = "Civilians killed",
		valign = "bottom",
		font = tweak_data.hud_custody.custody_font,
		font_size = tweak_data.hud_custody.small_font_size
	})
	local trade_delay = custody_panel:text({
		vertical = "top",
		name = "trade_delay",
		h = 32,
		w = 400,
		align = "right",
		text = "Trade delay",
		valign = "bottom",
		font = tweak_data.hud_custody.custody_font,
		font_size = tweak_data.hud_custody.small_font_size
	})
	local trade_text1 = self._hud.trade_text1

	trade_text1:set_font(Idstring(tweak_data.hud_custody.custody_font))
	trade_text1:set_font_size(tweak_data.hud_custody.font_size)
	trade_text1:set_visible(true)
	trade_text1:set_align("right")
	trade_text1:set_valign("bottom")
	trade_text1:set_text(utf8.to_upper(managers.localization:text("menu_spectator_being_traded")))

	local _, _, w, h = trade_text1:text_rect()

	trade_text1:set_h(h)
	trade_text1:set_y(self._hud_panel:h() - 152 - 80)

	local level_id = Global.level_data and Global.level_data.level_id
	local level_tweak = tweak_data.levels[level_id]
	local trade_text2_id = "menu_spectator_being_traded_hesitant_" .. (level_tweak and level_tweak.narrator or "bain")
	local trade_text2 = self._hud.trade_text2

	trade_text2:set_font(Idstring(tweak_data.hud_custody.custody_font))
	trade_text2:set_font_size(tweak_data.hud_custody.font_size)
	trade_text2:set_visible(true)
	trade_text2:set_align("right")
	trade_text2:set_valign("bottom")
	trade_text2:set_text(utf8.to_upper(managers.localization:text(trade_text2_id)))

	local _, _, w, h = trade_text2:text_rect()

	trade_text2:set_h(h)
	trade_text2:set_y(trade_text1:y())

	local _, _, w, h = civilians_killed:text_rect()

	civilians_killed:set_h(h)
	civilians_killed:set_right(civilians_killed:parent():w())
	civilians_killed:set_y(trade_text1:bottom())

	local _, _, w, h = trade_delay:text_rect()

	trade_delay:set_h(h)
	trade_delay:set_right(trade_delay:parent():w())
	trade_delay:set_y(civilians_killed:bottom())
end

function HUDPlayerCustody:set_timer_visibility(visible)
	self._timer:set_visible(visible)
	self._hud_panel:child("custody_panel"):child("timer_msg"):set_visible(visible)
end

function HUDPlayerCustody:set_respawn_time(time)
	if math.floor(time) == math.floor(self._last_time) then
		return
	end

	self._last_time = time
	local time_text = self:_get_time_text(time)

	self._timer:set_text(utf8.to_upper(tostring(time_text)))
end

function HUDPlayerCustody:set_civilians_killed(amount)
	local amount_text = (amount < 10 and "0" or "") .. amount
	local civilians_killed = self._hud_panel:child("custody_panel"):child("civilians_killed")

	civilians_killed:set_text(utf8.to_upper(managers.localization:text("hud_civilians_killed", {
		AMOUNT = tostring(amount_text)
	})))
end

function HUDPlayerCustody:set_trade_delay(time)
	if math.floor(time) == math.floor(self._last_trade_delay_time) then
		return
	end

	self._last_trade_delay_time = time
	local time_text = self:_get_time_text(time)
	local trade_delay = self._hud_panel:child("custody_panel"):child("trade_delay")

	trade_delay:set_text(utf8.to_upper(managers.localization:text("hud_trade_delay", {
		TIME = tostring(time_text)
	})))
end

function HUDPlayerCustody:set_trade_delay_visible(visible)
	self._hud_panel:child("custody_panel"):child("trade_delay"):set_visible(visible)
	self._hud_panel:child("custody_panel"):child("civilians_killed"):set_visible(visible)
end

function HUDPlayerCustody:set_negotiating_visible(visible)
	self._hud.trade_text2:set_visible(visible)
	self._hud.trade_text2:stop()

	if visible then
		self._hud.trade_text2:animate(callback(self, self, "_animate_text_pulse"))
	end
end

function HUDPlayerCustody:set_can_be_trade_visible(visible)
	self._hud.trade_text1:set_visible(visible)
	self._hud.trade_text1:stop()

	if visible then
		self._hud.trade_text1:animate(callback(self, self, "_animate_text_pulse"))
	end
end

function HUDPlayerCustody:_get_time_text(time)
	time = math.max(math.floor(time), 0)
	local minutes = math.floor(time / 60)
	time = time - minutes * 60
	local seconds = math.round(time)
	local text = ""

	return text .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
end

function HUDPlayerCustody:_animate_text_pulse(text)
	local t = 0

	while true do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = 0.5 + math.abs(math.sin(t * 360 * 0.5)) / 2

		text:set_alpha(alpha)
	end
end

function HUDPlayerCustody:set_respawn_type(is_ai_trade)
	if self._last_respawn_type_is_ai_trade ~= is_ai_trade then
		local text = utf8.to_upper(managers.localization:text(is_ai_trade and "hud_ai_traded_in" or "hud_respawning_in"))

		self._hud_panel:child("custody_panel"):child("timer_msg"):set_text(text)

		self._last_respawn_type_is_ai_trade = is_ai_trade
	end
end
