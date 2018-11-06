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

local function HUDBGBox_create_ex(panel, config)
	local box_panel = panel
	local color = config and config.color
	local bg_color = config and config.bg_color or Color(1, 0, 0, 0)
	local blend_mode = config and config.blend_mode

	box_panel:rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0.4,
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

local box_speed = 1500

local function animate_open(panel, done_cb)
	local target_w = panel:w()

	panel:set_w(0)
	panel:set_visible(true)

	local speed = box_speed
	local TOTAL_T = target_w / speed
	local t = TOTAL_T

	while t > 0 do
		coroutine.yield()

		local dt = TimerManager:main():delta_time()
		t = t - dt

		panel:set_w((1 - t / TOTAL_T) * target_w)
	end

	panel:set_w(target_w)
	done_cb()
end

local function animate_close(panel, done_cb)
	local speed = box_speed
	local cw = panel:w()
	local TOTAL_T = cw / speed
	local t = TOTAL_T

	while t > 0 do
		coroutine.yield()

		local dt = TimerManager:main():delta_time()
		t = t - dt

		panel:set_w(t / TOTAL_T * cw)
	end

	panel:set_w(0)
	done_cb()
end

local function wait_global(seconds)
	local t = 0

	while seconds > t do
		coroutine.yield()

		local dt = TimerManager:main():delta_time()
		t = t + dt
	end
end

HudChallengeNotification = HudChallengeNotification or class(ExtendedPanel)
HudChallengeNotification.ICON_SIZE = 80
HudChallengeNotification.BOX_MAX_W = 400
HudChallengeNotification.default_queue = HudChallengeNotification.default_queue or {}

function HudChallengeNotification.queue(title, text, icon, rewards, queue)
	if Application:editor() then
		return
	end

	queue = queue or HudChallengeNotification.default_queue

	table.insert(queue, {
		title,
		text,
		icon,
		rewards,
		queue
	})

	if #queue == 1 then
		HudChallengeNotification:new(unpack(queue[1]))
	end
end

function HudChallengeNotification:init(title, text, icon, rewards, queue)
	if _G.IS_VR then
		HudChallengeNotification.super.init(self, managers.hud:prompt_panel())
	else
		self._ws = managers.gui_data:create_fullscreen_workspace()

		HudChallengeNotification.super.init(self, self._ws:panel())
	end

	self:set_layer(1000)

	self._queue = queue or {}
	self._top = ExtendedPanel:new(self)
	local title = self._top:fine_text({
		layer = 1,
		text = title or "ACHIEVEMENT UNLOCKED!",
		font = small_font,
		font_size = small_font_size,
		color = Color.black
	})

	title:move(8, 0)
	self._top:set_size(title:right() + 8, title:h())
	self._top:bitmap({
		texture = "guis/textures/pd2/shared_tab_box",
		w = self._top:w(),
		h = self._top:h()
	})

	local box_size = (icon and self.ICON_SIZE * 2 or self.ICON_SIZE) + math.max(180, self._top:w())
	self._box = GrowPanel:new(self, {
		padding = 4,
		border = 4,
		w = box_size,
		y = self._top:bottom()
	})
	local placer = self._box:placer()
	local icon_texture, icon_texture_rect = tweak_data.hud_icons:get_icon_or(icon, nil)

	if icon_texture then
		local icon_bitmap = self._box:fit_bitmap({
			texture = icon_texture,
			texture_rect = icon_texture_rect,
			w = self.ICON_SIZE,
			h = self.ICON_SIZE
		})

		placer:add_right(icon_bitmap)
		self._top:set_left(placer:current_right())
	end

	local description = self._box:fine_text({
		wrap = true,
		word_wrap = true,
		text = text,
		font = medium_font,
		font_size = medium_font_size,
		w = self.BOX_MAX_W - placer:current_left()
	})

	placer:add_right(description)

	local box_height = self._box:height()

	for i, reward in ipairs(rewards or {}) do
		local reward_panel = self._box:panel({
			h = 32,
			x = description:left(),
			y = description:bottom() + (i - 1) * 32
		})
		local reward_icon = reward_panel:bitmap({
			w = 32,
			h = 32,
			texture = reward.texture
		})
		local reward_text = managers.localization:text(reward.name_id)

		if reward.amount then
			reward_text = reward.amount .. "x " .. reward_text
		end

		local reward_text_gui = FineText:new(reward_panel, {
			text = reward_text,
			x = reward_icon:right() + 8
		})

		reward_text_gui:set_center_y(reward_icon:center_y())
		reward_panel:set_width(reward_text_gui:right())

		box_height = math.max(box_height, reward_panel:bottom() + 8)
	end

	self._box:set_height(box_height)

	local total_w = self._box:right()

	self:set_w(total_w)
	self:set_h(self._box:bottom())
	self:set_center_x(self:parent():w() / 2)
	self:set_bottom(self:parent():h() * 5 / 7)

	self._box_bg = self:panel()

	self._box_bg:set_shape(self._box:shape())
	HUDBGBox_create_ex(self._box_bg)
	self._box:set_visible(false)
	self._box_bg:animate(animate_open, function ()
		self._box:set_visible(true)
		wait_global(2)
		self._box:set_visible(false)
		self._box_bg:animate(animate_close, function ()
			self:close()
		end)
	end)
end

function HudChallengeNotification:close()
	self:remove_self()

	if self._ws and not _G.IS_VR then
		managers.gui_data:destroy_workspace(self._ws)

		self._ws = nil
	end

	table.remove(self._queue, 1)

	if #self._queue > 0 then
		HudChallengeNotification:new(unpack(self._queue[1]))
	end
end
