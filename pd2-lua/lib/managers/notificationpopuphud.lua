function HUDBGBox_create(panel, params, config)
	local box_panel = panel:panel(params)
	local color = config and config.color
	local bg_color = config and config.bg_color or Color(1, 0, 0, 0)
	local blend_mode = config and config.blend_mode

	box_panel:rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = bg_color
	})

	local left_top = box_panel:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "left_top",
		visible = true,
		layer = 0,
		y = 0,
		halign = "left",
		x = 0,
		valign = "top",
		color = color,
		blend_mode = blend_mode
	})
	local left_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "left_bottom",
		visible = true,
		layer = 0,
		x = 0,
		y = 0,
		halign = "left",
		rotation = -90,
		valign = "bottom",
		color = color,
		blend_mode = blend_mode
	})

	left_bottom:set_bottom(box_panel:h())

	local right_top = box_panel:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "right_top",
		visible = true,
		layer = 0,
		x = 0,
		y = 0,
		halign = "right",
		rotation = 90,
		valign = "top",
		color = color,
		blend_mode = blend_mode
	})

	right_top:set_right(box_panel:w())

	local right_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "right_bottom",
		visible = true,
		layer = 0,
		x = 0,
		y = 0,
		halign = "right",
		rotation = 180,
		valign = "bottom",
		color = color,
		blend_mode = blend_mode
	})

	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())

	return box_panel
end

local box_speed = 1000

function HUDBGBox_animate_open_right(panel, wait_t, target_w, done_cb)
	panel:set_visible(false)
	panel:set_w(0)

	if wait_t then
		wait(wait_t)
	end

	panel:set_visible(true)

	local speed = box_speed
	local bg = panel:child("bg")

	bg:stop()
	bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"))

	local TOTAL_T = target_w / speed
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		panel:set_w((1 - t / TOTAL_T) * target_w)
	end

	panel:set_w(target_w)
	done_cb()
end

function HUDBGBox_animate_close_right(panel, done_cb)
	local speed = box_speed
	local cw = panel:w()
	local TOTAL_T = cw / speed
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		panel:set_w(t / TOTAL_T * cw)
	end

	panel:set_w(0)
	done_cb()
end

function HUDBGBox_animate_open_left(panel, wait_t, target_w, done_cb, config)
	config = config or {}

	panel:set_visible(false)

	local right = panel:right()

	panel:set_w(0)
	panel:set_right(right)

	if wait_t then
		wait(wait_t)
	end

	panel:set_visible(true)

	local speed = box_speed
	local bg = panel:child("bg")

	bg:stop()
	bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {
		color = config.attention_color,
		attention_color_function = config.attention_color_function,
		forever = config.attention_forever
	})

	local TOTAL_T = target_w / speed
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		panel:set_w((1 - t / TOTAL_T) * target_w)
		panel:set_right(right)
	end

	panel:set_w(target_w)
	panel:set_right(right)
	done_cb()
end

function HUDBGBox_animate_close_left(panel, done_cb)
	local speed = box_speed
	local cw = panel:w()
	local right = panel:right()
	local TOTAL_T = cw / speed
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		panel:set_w(t / TOTAL_T * cw)
		panel:set_right(right)
	end

	panel:set_w(0)
	panel:set_right(right)
	done_cb()
end

function HUDBGBox_animate_open_center(panel, wait_t, target_w, done_cb, config)
	config = config or {}

	panel:set_visible(false)

	local center_x = panel:center_x()

	panel:set_w(0)

	if wait_t then
		wait(wait_t)
	end

	panel:set_visible(true)

	local speed = box_speed
	local bg = panel:child("bg")

	bg:stop()
	bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {
		color = config.attention_color,
		forever = config.attention_forever
	})

	local TOTAL_T = target_w / speed
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		panel:set_w((1 - t / TOTAL_T) * target_w)
		panel:set_center_x(center_x)
	end

	panel:set_w(target_w)
	panel:set_center_x(center_x)

	if done_cb then
		done_cb()
	end
end

function HUDBGBox_animate_close_center(panel, done_cb)
	local center_x = panel:center_x()
	local cw = panel:w()
	local speed = box_speed
	local TOTAL_T = cw / speed
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		panel:set_w(t / TOTAL_T * cw)
		panel:set_center_x(center_x)
	end

	panel:set_w(0)
	panel:set_center_x(center_x)

	if done_cb then
		done_cb()
	end
end

function HUDBGBox_animate_bg_attention(bg, config)
	local color = config and config.color or Color.white
	local attention_color_function = config and config.attention_color_function
	local forever = config and config.forever or false
	local TOTAL_T = 3
	local t = TOTAL_T

	while t > 0 or forever do
		local dt = coroutine.yield()
		t = t - dt
		local cv = math.abs(math.sin(t * 180 * 1))
		local mod_color = attention_color_function and attention_color_function() or color

		bg:set_color(Color(1, mod_color.red * cv, mod_color.green * cv, mod_color.blue * cv))
	end

	bg:set_color(Color(1, 0, 0, 0))
end

NotificationPopUpHud = NotificationPopUpHud or class()

function NotificationPopUpHud:init()
	self:setup()
end

function NotificationPopUpHud:setup()
	self._ws = managers.gui_data:create_saferect_workspace()
	self._hud_panel = self._ws:panel({
		layer = 40
	})

	if self._hud_panel:child("notifications_panel") then
		self._hud_panel:remove(self._hud_panel:child("notifications_panel"))
	end

	local notifications_panel = self._hud_panel:panel({
		y = 50,
		name = "notifications_panel",
		h = 100,
		visible = false,
		w = 500,
		valign = "top",
		x = self._hud_panel:w() / 2
	})
	self._bg_box = HUDBGBox_create(notifications_panel, {
		w = 400,
		x = 26,
		h = 100,
		y = 0
	})
	local achievement_text = notifications_panel:text({
		y = 8,
		name = "achievement_text",
		vertical = "top",
		font_size = 24,
		align = "left",
		text = "",
		visible = false,
		x = 0,
		layer = 40,
		color = Color.white,
		font = tweak_data.hud.medium_font_noshadow
	})

	achievement_text:set_x(self._bg_box:x() + 8)
	achievement_text:set_y(6)

	local amount_text = notifications_panel:text({
		y = 0,
		name = "amount_text",
		vertical = "top",
		font_size = 24,
		align = "left",
		text = "1/4",
		visible = true,
		x = 6,
		layer = 40,
		color = Color.white,
		font = tweak_data.hud.medium_font_noshadow
	})

	amount_text:set_x(achievement_text:x())
	amount_text:set_y(achievement_text:y() + achievement_text:font_size() - 2)
end

function NotificationPopUpHud:text(text)
	local notifications_panel = self._hud_panel:child("notifications_panel")
	local achievement_text = notifications_panel:child("achievement_text")

	achievement_text:set_text(utf8.to_upper(text))

	local _, _, w, _ = achievement_text:text_rect()

	notifications_panel:set_visible(true)
	self._bg_box:set_h(60 or 38)
	achievement_text:set_visible(false)
	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_right"), 0.66, w + 16, callback(self, self, "open_right_done", true or false))
	notifications_panel:child("amount_text"):set_visible(false)
end

function NotificationPopUpHud:activate_achievement(data)
	print("[NotificationPopUpHud] activate_achievement", data.id, data.amount)

	self._active_achievement_id = data.id
	local notifications_panel = self._hud_panel:child("notifications_panel")
	local achievement_text = notifications_panel:child("achievement_text")

	achievement_text:set_text(utf8.to_upper(data.text))

	local _, _, w, _ = achievement_text:text_rect()

	notifications_panel:set_visible(true)
	self._bg_box:set_h(data.amount and 60 or 38)
	achievement_text:set_visible(false)
	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_right"), 0.66, w + 16, callback(self, self, "open_right_done", data.amount and true or false))
	notifications_panel:stop()
	notifications_panel:animate(callback(self, self, "_animate_activate_achievement"))
	notifications_panel:child("amount_text"):set_visible(false)

	if data.amount then
		self:update_amount_achievement(data)
	end
end

function NotificationPopUpHud:remind_achievement(id)
	print("[NotificationPopUpHud] remind_achievement", id, self._active_achievement_id)

	if id == self._active_achievement_id then
		local notifications_panel = self._hud_panel:child("notifications_panel")

		notifications_panel:stop()
		notifications_panel:animate(callback(self, self, "_animate_activate_achievement"))

		local bg = self._bg_box:child("bg")

		bg:stop()
		bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"))
	end
end

function NotificationPopUpHud:complete_achievement(data)
	print("[NotificationPopUpHud] complete_achievement", data.id, self._active_achievement_id)

	if data.id == self._active_achievement_id then
		local notifications_panel = self._hud_panel:child("notifications_panel")

		notifications_panel:stop()
		notifications_panel:animate(callback(self, self, "_animate_complete_achievement"))
	end
end

function NotificationPopUpHud:update_amount_achievement(data)
	print("[NotificationPopUpHud] update_amount_achievement", data.id, data.current_amount, data.amount)

	if data.id == self._active_achievement_id then
		local current = data.current_amount or 0
		local amount = data.amount
		local notifications_panel = self._hud_panel:child("notifications_panel")
		local amount_text = notifications_panel:child("amount_text")

		if alive(amount_text) then
			amount_text:set_text(current .. "/" .. amount)
		end
	end
end

function NotificationPopUpHud:open_right_done(uses_amount)
	local notifications_panel = self._hud_panel:child("notifications_panel")
	local achievement_text = notifications_panel:child("achievement_text")

	achievement_text:set_visible(true)
	achievement_text:stop()

	local amount_text = notifications_panel:child("amount_text")

	if alive(amount_text) then
		amount_text:set_visible(uses_amount)
	end

	achievement_text:animate(callback(self, self, "_animate_show_text"), amount_text)
end

function NotificationPopUpHud:_animate_show_text(achievement_text, amount_text)
	local TOTAL_T = 2
	local t = TOTAL_T

	achievement_text:set_alpha(1)

	if alive(amount_text) then
		amount_text:set_alpha(0)
	end

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
	end

	achievement_text:animate(callback(self, self, "_animate_complete_achievement"))
end

function NotificationPopUpHud:close_right_done(uses_amount)
	local notifications_panel = self._hud_panel:child("notifications_panel")
	local achievement_text = notifications_panel:child("achievement_text")

	achievement_text:set_visible(false)
	achievement_text:stop()

	local amount_text = notifications_panel:child("amount_text")

	amount_text:set_visible(false)
end

function NotificationPopUpHud:_animate_complete_achievement()
	local notifications_panel = self._hud_panel:child("notifications_panel")
	local achievement_text = notifications_panel:child("achievement_text")
	local amount_text = notifications_panel:child("amount_text")
	local TOTAL_T = 0.5
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local vis = math.round(math.abs(math.cos(t * 360 * 3)))

		achievement_text:set_alpha(vis)

		if alive(amount_text) then
			amount_text:set_alpha(vis)
		end
	end

	achievement_text:set_alpha(1)
	achievement_text:set_visible(false)

	if alive(amount_text) then
		amount_text:set_alpha(1)
		amount_text:set_visible(false)
	end

	local function done_cb()
		notifications_panel:child("achievement_text"):set_text(utf8.to_upper(""))
		notifications_panel:set_visible(false)
	end

	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_right"), done_cb)
end

function NotificationPopUpHud:_animate_activate_achievement(notifications_panel)
	local icon_achievementbox = notifications_panel:child("icon_achievementbox")

	icon_achievementbox:stop()
	icon_achievementbox:animate(callback(self, self, "_animate_icon_achievementbox"))
end

function NotificationPopUpHud:_animate_icon_achievementbox(icon_achievementbox)
	local TOTAL_T = 5
	local t = TOTAL_T

	icon_achievementbox:set_y(0)

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		icon_achievementbox:set_y(math.round((1 + math.sin((TOTAL_T - t) * 450 * 2)) * 12 * t / TOTAL_T))
	end

	icon_achievementbox:set_y(0)
end
