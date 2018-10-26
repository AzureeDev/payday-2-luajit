
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

HUDObjectives = HUDObjectives or class()

function HUDObjectives:init(hud)
	self._hud_panel = hud.panel

	if self._hud_panel:child("objectives_panel") then
		self._hud_panel:remove(self._hud_panel:child("objectives_panel"))
	end

	local objectives_panel = self._hud_panel:panel({
		y = 0,
		name = "objectives_panel",
		h = 100,
		visible = false,
		w = 500,
		x = 0,
		valign = "top"
	})
	local icon_objectivebox = objectives_panel:bitmap({
		texture = "guis/textures/pd2/hud_icon_objectivebox",
		name = "icon_objectivebox",
		h = 24,
		layer = 0,
		w = 24,
		y = 0,
		visible = true,
		blend_mode = "normal",
		halign = "left",
		x = 0,
		valign = "top"
	})
	self._bg_box = HUDBGBox_create(objectives_panel, {
		w = 200,
		x = 26,
		h = 38,
		y = 0
	})
	local objective_text = objectives_panel:text({
		y = 8,
		name = "objective_text",
		vertical = "top",
		align = "left",
		text = "",
		visible = false,
		x = 0,
		layer = 2,
		color = Color.white,
		font_size = tweak_data.hud.active_objective_title_font_size,
		font = tweak_data.hud.medium_font_noshadow
	})

	objective_text:set_x(self._bg_box:x() + 8)
	objective_text:set_y(6)

	local amount_text = objectives_panel:text({
		y = 0,
		name = "amount_text",
		vertical = "top",
		align = "left",
		text = "1/4",
		visible = true,
		x = 6,
		layer = 2,
		color = Color.white,
		font_size = tweak_data.hud.active_objective_title_font_size,
		font = tweak_data.hud.medium_font_noshadow
	})

	amount_text:set_x(objective_text:x())
	amount_text:set_y((objective_text:y() + objective_text:font_size()) - 2)
end

function HUDObjectives:activate_objective(data)
	print("[HUDObjectives] activate_objective", data.id, data.amount)

	self._active_objective_id = data.id
	local objectives_panel = self._hud_panel:child("objectives_panel")
	local objective_text = objectives_panel:child("objective_text")

	objective_text:set_text(utf8.to_upper(data.text))

	local _, _, w, _ = objective_text:text_rect()

	objectives_panel:set_visible(true)
	self._bg_box:set_h(data.amount and 60 or 38)
	objective_text:set_visible(false)
	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_right"), 0.66, w + 16, callback(self, self, "open_right_done", data.amount and true or false))
	objectives_panel:stop()
	objectives_panel:animate(callback(self, self, "_animate_activate_objective"))
	objectives_panel:child("amount_text"):set_visible(false)

	if data.amount then
		self:update_amount_objective(data)
	end
end

function HUDObjectives:remind_objective(id)
	print("[HUDObjectives] remind_objective", id, self._active_objective_id)

	if id == self._active_objective_id then
		local objectives_panel = self._hud_panel:child("objectives_panel")

		objectives_panel:stop()
		objectives_panel:animate(callback(self, self, "_animate_activate_objective"))

		local bg = self._bg_box:child("bg")

		bg:stop()
		bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"))
	end
end

function HUDObjectives:complete_objective(data)
	print("[HUDObjectives] complete_objective", data.id, self._active_objective_id)

	if data.id == self._active_objective_id then
		local objectives_panel = self._hud_panel:child("objectives_panel")

		objectives_panel:stop()
		objectives_panel:animate(callback(self, self, "_animate_complete_objective"))
	end
end

function HUDObjectives:update_amount_objective(data)
	print("[HUDObjectives] update_amount_objective", data.id, data.current_amount, data.amount)

	if data.id == self._active_objective_id then
		local current = data.current_amount or 0
		local amount = data.amount
		local objectives_panel = self._hud_panel:child("objectives_panel")
		local amount_text = objectives_panel:child("amount_text")

		if alive(amount_text) then
			amount_text:set_text(current .. "/" .. amount)
		end
	end
end

function HUDObjectives:open_right_done(uses_amount)
	local objectives_panel = self._hud_panel:child("objectives_panel")
	local objective_text = objectives_panel:child("objective_text")

	objective_text:set_visible(true)
	objective_text:stop()

	local amount_text = objectives_panel:child("amount_text")

	if alive(amount_text) then
		amount_text:set_visible(uses_amount)
	end

	objective_text:animate(callback(self, self, "_animate_show_text"), amount_text)
end

function HUDObjectives:_animate_show_text(objective_text, amount_text)
	local TOTAL_T = 0.5
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local alpha = math.round(math.abs(math.sin(t * 360 * 3)))

		objective_text:set_alpha(alpha)

		if alive(amount_text) then
			amount_text:set_alpha(alpha)
		end
	end

	objective_text:set_alpha(1)

	if alive(amount_text) then
		amount_text:set_alpha(1)
	end
end

function HUDObjectives:_animate_complete_objective(objectives_panel)
	local objective_text = objectives_panel:child("objective_text")
	local amount_text = objectives_panel:child("amount_text")
	local icon_objectivebox = objectives_panel:child("icon_objectivebox")

	icon_objectivebox:set_y(0)

	local TOTAL_T = 0.5
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local vis = math.round(math.abs(math.cos(t * 360 * 3)))

		objective_text:set_alpha(vis)

		if alive(amount_text) then
			amount_text:set_alpha(vis)
		end
	end

	objective_text:set_alpha(1)
	objective_text:set_visible(false)

	if alive(amount_text) then
		amount_text:set_alpha(1)
		amount_text:set_visible(false)
	end

	local function done_cb()
		objectives_panel:child("objective_text"):set_text(utf8.to_upper(""))
		objectives_panel:set_visible(false)
	end

	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_right"), done_cb)
end

function HUDObjectives:_animate_activate_objective(objectives_panel)
	local icon_objectivebox = objectives_panel:child("icon_objectivebox")

	icon_objectivebox:stop()
	icon_objectivebox:animate(callback(self, self, "_animate_icon_objectivebox"))
end

function HUDObjectives:_animate_icon_objectivebox(icon_objectivebox)
	local TOTAL_T = 5
	local t = TOTAL_T

	icon_objectivebox:set_y(0)

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		icon_objectivebox:set_y(math.round((1 + math.sin((TOTAL_T - t) * 450 * 2)) * 12 * t / TOTAL_T))
	end

	icon_objectivebox:set_y(0)
end

if _G.IS_VR then
	require("lib/managers/hud/vr/HUDObjectivesVR")
end

