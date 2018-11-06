HUDInteraction = HUDInteraction or class()

function HUDInteraction:init(hud, child_name)
	self._hud_panel = hud.panel
	self._circle_radius = 64
	self._sides = 64
	self._child_name_text = (child_name or "interact") .. "_text"
	self._child_ivalid_name_text = (child_name or "interact") .. "_invalid_text"

	if self._hud_panel:child(self._child_name_text) then
		self._hud_panel:remove(self._hud_panel:child(self._child_name_text))
	end

	if self._hud_panel:child(self._child_ivalid_name_text) then
		self._hud_panel:remove(self._hud_panel:child(self._child_ivalid_name_text))
	end

	local interact_text = self._hud_panel:text({
		layer = 1,
		h = 64,
		align = "center",
		text = "HELLO",
		visible = false,
		valign = "center",
		name = self._child_name_text,
		color = Color.white,
		font = tweak_data.hud_present.text_font,
		font_size = tweak_data.hud_present.text_size
	})
	local invalid_text = self._hud_panel:text({
		layer = 3,
		h = 64,
		text = "HELLO",
		align = "center",
		blend_mode = "normal",
		visible = false,
		valign = "center",
		name = self._child_ivalid_name_text,
		color = Color(1, 0.3, 0.3),
		font = tweak_data.hud_present.text_font,
		font_size = tweak_data.hud_present.text_size
	})

	interact_text:set_y(self._hud_panel:h() / 2 + 64 + 16)
	invalid_text:set_center_y(interact_text:center_y())
end

function HUDInteraction:show_interact(data)
	self:remove_interact()

	local text = utf8.to_upper(data.text or "Press 'F' to interact")

	self._hud_panel:child(self._child_name_text):set_visible(true)
	self._hud_panel:child(self._child_name_text):set_text(text)
end

function HUDInteraction:remove_interact()
	if not alive(self._hud_panel) then
		return
	end

	self._hud_panel:child(self._child_name_text):set_visible(false)
	self._hud_panel:child(self._child_ivalid_name_text):set_visible(false)
end

function HUDInteraction:show_interaction_bar(current, total)
	if self._interact_circle then
		self._interact_circle:remove()

		self._interact_circle = nil
	end

	self._interact_circle = CircleBitmapGuiObject:new(self._hud_panel, {
		use_bg = true,
		blend_mode = "add",
		layer = 2,
		radius = self._circle_radius,
		sides = self._sides,
		current = self._sides,
		total = self._sides,
		color = Color.white:with_alpha(1)
	})

	self._interact_circle:set_position(self._hud_panel:w() / 2 - self._circle_radius, self._hud_panel:h() / 2 - self._circle_radius)
end

function HUDInteraction:set_interaction_bar_width(current, total)
	if not self._interact_circle then
		return
	end

	self._interact_circle:set_current(math.clamp(current / total, 0, 1))
end

function HUDInteraction:hide_interaction_bar(complete)
	if complete then
		local bitmap = self._hud_panel:bitmap({
			texture = "guis/textures/pd2/hud_progress_active",
			blend_mode = "add",
			layer = 2,
			align = "center",
			valign = "center"
		})

		bitmap:set_position(bitmap:parent():w() / 2 - bitmap:w() / 2, bitmap:parent():h() / 2 - bitmap:h() / 2)

		local radius = 64
		local circle = CircleBitmapGuiObject:new(self._hud_panel, {
			sides = 64,
			current = 64,
			total = 64,
			blend_mode = "normal",
			layer = 3,
			radius = radius,
			color = Color.white:with_alpha(1)
		})

		circle:set_position(self._hud_panel:w() / 2 - radius, self._hud_panel:h() / 2 - radius)
		bitmap:animate(callback(self, self, "_animate_interaction_complete"), circle)
	end

	if self._interact_circle then
		self._interact_circle:remove()

		self._interact_circle = nil
	end
end

function HUDInteraction:set_bar_valid(valid, text_id)
	local texture = valid and "guis/textures/pd2/hud_progress_active" or "guis/textures/pd2/hud_progress_invalid"

	self._interact_circle:set_image(texture)
	self._hud_panel:child(self._child_name_text):set_visible(valid)

	local invalid_text = self._hud_panel:child(self._child_ivalid_name_text)

	if text_id then
		invalid_text:set_text(managers.localization:to_upper_text(text_id))
	end

	invalid_text:set_visible(not valid)
end

function HUDInteraction:destroy()
	self._hud_panel:remove(self._hud_panel:child(self._child_name_text))
	self._hud_panel:remove(self._hud_panel:child(self._child_ivalid_name_text))

	if self._interact_circle then
		self._interact_circle:remove()

		self._interact_circle = nil
	end
end

function HUDInteraction:_animate_interaction_complete(bitmap, circle)
	local TOTAL_T = 0.6
	local t = TOTAL_T
	local mul = 1
	local c_x, c_y = bitmap:center()
	local size = bitmap:w()

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		mul = mul + dt * 0.75

		bitmap:set_size(size * mul, size * mul)
		bitmap:set_center(c_x, c_y)
		bitmap:set_alpha(math.max(t / TOTAL_T, 0))
		circle._circle:set_size(size * mul, size * mul)
		circle._circle:set_center(c_x, c_y)
		circle:set_current(1 - t / TOTAL_T)
		circle:set_alpha(math.max(t / TOTAL_T, 0))
	end

	bitmap:parent():remove(bitmap)
	circle:remove()
end

if _G.IS_VR then
	require("lib/managers/hud/vr/HUDInteractionVR")
end
