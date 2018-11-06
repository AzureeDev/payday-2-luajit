HUDSuspicion = HUDSuspicion or class()

function HUDSuspicion:init(hud, sound_source)
	self._hud_panel = hud.panel
	self._sound_source = sound_source

	if self._hud_panel:child("suspicion_panel") then
		self._hud_panel:remove(self._hud_panel:child("suspicion_panel"))
	end

	self._suspicion_panel = self._hud_panel:panel({
		y = 0,
		name = "suspicion_panel",
		layer = 1,
		visible = false,
		valign = "center"
	})
	self._misc_panel = self._suspicion_panel:panel({
		name = "misc_panel"
	})

	self._suspicion_panel:set_size(200, 200)
	self._suspicion_panel:set_center(self._suspicion_panel:parent():w() / 2, self._suspicion_panel:parent():h() / 2)

	local scale = 1.175
	local suspicion_left = self._suspicion_panel:bitmap({
		texture = "guis/textures/pd2/hud_stealthmeter",
		name = "suspicion_left",
		h = 128,
		w = 128,
		alpha = 1,
		layer = 1,
		blend_mode = "add",
		visible = true,
		render_template = "VertexColorTexturedRadial",
		valign = "center",
		color = Color(0, 1, 1)
	})

	suspicion_left:set_size(suspicion_left:w() * scale, suspicion_left:h() * scale)
	suspicion_left:set_center_x(self._suspicion_panel:w() / 2)
	suspicion_left:set_center_y(self._suspicion_panel:h() / 2)

	local suspicion_right = self._suspicion_panel:bitmap({
		texture = "guis/textures/pd2/hud_stealthmeter",
		name = "suspicion_right",
		h = 128,
		w = 128,
		alpha = 1,
		layer = 1,
		blend_mode = "add",
		visible = true,
		render_template = "VertexColorTexturedRadial",
		valign = "center",
		color = Color(0, 1, 1)
	})

	suspicion_right:set_size(suspicion_right:w() * scale, suspicion_right:h() * scale)
	suspicion_right:set_center(suspicion_left:center())
	suspicion_left:set_texture_rect(128, 0, -128, 128)

	local hud_stealthmeter_bg = self._misc_panel:bitmap({
		texture = "guis/textures/pd2/hud_stealthmeter_bg",
		name = "hud_stealthmeter_bg",
		h = 128,
		w = 128,
		alpha = 0,
		blend_mode = "normal",
		visible = true,
		color = Color(0.2, 1, 1, 1),
		valign = {
			0.5,
			0
		}
	})

	hud_stealthmeter_bg:set_size(hud_stealthmeter_bg:w() * scale, hud_stealthmeter_bg:h() * scale)
	hud_stealthmeter_bg:set_center(suspicion_left:center())

	local suspicion_detected = self._suspicion_panel:text({
		name = "suspicion_detected",
		vertical = "center",
		align = "center",
		alpha = 0,
		layer = 2,
		text = managers.localization:to_upper_text("hud_detected"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font
	})

	suspicion_detected:set_text(utf8.to_upper(managers.localization:text("hud_suspicion_detected")))
	suspicion_detected:set_center(suspicion_left:center())

	local hud_stealth_eye = self._misc_panel:bitmap({
		texture = "guis/textures/pd2/hud_stealth_eye",
		name = "hud_stealth_eye",
		h = 32,
		alpha = 0,
		w = 32,
		layer = 1,
		blend_mode = "add",
		visible = true,
		valign = "center"
	})

	hud_stealth_eye:set_center(suspicion_left:center_x(), suspicion_left:bottom() - 4)

	local hud_stealth_exclam = self._misc_panel:bitmap({
		texture = "guis/textures/pd2/hud_stealth_exclam",
		name = "hud_stealth_exclam",
		h = 32,
		alpha = 0,
		w = 32,
		layer = 1,
		blend_mode = "add",
		visible = true,
		valign = "center"
	})

	hud_stealth_exclam:set_center(suspicion_left:center_x(), suspicion_left:top() - 4)

	self._eye_animation = nil
	self._suspicion_value = 0
	self._hud_timeout = 0
end

function HUDSuspicion:animate_eye()
	if self._eye_animation then
		return
	end

	self._suspicion_value = 0
	self._discovered = nil
	self._back_to_stealth = nil

	local function animate_func(o, self)
		local wanted_value = 0
		local value = wanted_value
		local suspicion_left = o:child("suspicion_left")
		local suspicion_right = o:child("suspicion_right")
		local suspicion_detected = o:child("suspicion_detected")
		local misc_panel = o:child("misc_panel")

		local function animate_hide_misc(o)
			local hud_stealthmeter_bg = o:child("hud_stealthmeter_bg")
			local hud_stealth_eye = o:child("hud_stealth_eye")
			local start_alpha = hud_stealth_eye:alpha()

			wait(1.8)
			over(0.1, function (p)
				hud_stealthmeter_bg:set_alpha(math.lerp(start_alpha, 0, p))
				hud_stealth_eye:set_alpha(math.lerp(start_alpha, 0, p))
			end)
		end

		local function animate_show_misc(o)
			local hud_stealthmeter_bg = o:child("hud_stealthmeter_bg")
			local hud_stealth_eye = o:child("hud_stealth_eye")
			local start_alpha = hud_stealth_eye:alpha()

			over(0.1, function (p)
				hud_stealthmeter_bg:set_alpha(math.lerp(start_alpha, 1, p))
				hud_stealth_eye:set_alpha(math.lerp(start_alpha, 1, p))
			end)
		end

		misc_panel:stop()
		misc_panel:animate(animate_show_misc)

		local c = math.lerp(1, 0, math.clamp((value - 0.75) * 4, 0, 1))
		local dt = nil
		local detect_me = false
		local time_to_end = 4

		while true do
			if not alive(o) then
				return
			end

			dt = coroutine.yield()
			self._hud_timeout = self._hud_timeout - dt

			if self._hud_timeout < 0 then
				self._back_to_stealth = true
			end

			if self._discovered then
				self._discovered = nil

				if not detect_me then
					detect_me = true
					wanted_value = 1
					self._suspicion_value = wanted_value

					self._sound_source:post_event("hud_suspicion_discovered")

					local function animate_detect_text(o)
						local c = 0
						local s = 0
						local a = 0
						local font_scale = o:font_scale()

						over(0.8, function (p)
							c = math.lerp(1, 0, math.clamp((p - 0.75) * 6, 0, 1))
							s = math.lerp(0, 1, math.min(1, p * 2))
							a = math.lerp(0, 1, math.min(1, p * 3))

							o:set_alpha(a)
							o:set_font_scale(font_scale * s)
							o:set_color(Color(1, c, c))
						end)
					end

					suspicion_detected:stop()
					suspicion_detected:animate(animate_detect_text)
				end
			end

			if not detect_me and wanted_value ~= self._suspicion_value then
				wanted_value = self._suspicion_value
			end

			if (not detect_me or time_to_end < 2) and self._back_to_stealth then
				self._back_to_stealth = nil
				detect_me = false
				wanted_value = 0
				self._suspicion_value = wanted_value

				misc_panel:stop()
				misc_panel:animate(animate_hide_misc)
			end

			value = math.lerp(value, wanted_value, 0.9)
			c = math.lerp(1, 0, value)

			if math.abs(value - wanted_value) < 0.01 then
				value = wanted_value
			end

			suspicion_left:set_color(Color(0.5 + value * 0.5, 1, 1))
			suspicion_right:set_color(Color(0.5 + value * 0.5, 1, 1))

			local misc_panel = o:child("misc_panel")
			local hud_stealth_exclam = misc_panel:child("hud_stealth_exclam")

			hud_stealth_exclam:set_alpha(math.clamp((value - 0.5) * 2, 0, 1))

			if value == 1 then
				time_to_end = time_to_end - dt

				if time_to_end <= 0 then
					self._eye_animation = nil

					self:hide()

					return
				end
			elseif value <= 0 then
				time_to_end = time_to_end - dt * 2

				if time_to_end <= 0 then
					self._eye_animation = nil

					self:hide()

					return
				end
			elseif time_to_end ~= 4 then
				time_to_end = 4

				misc_panel:stop()
				misc_panel:animate(animate_show_misc)
			end
		end
	end

	self._sound_source:post_event("hud_suspicion_start")

	self._eye_animation = self._suspicion_panel:animate(animate_func, self)
end

function HUDSuspicion:show()
	self:animate_eye()
	self._suspicion_panel:set_visible(true)
end

function HUDSuspicion:hide()
	if self._eye_animation then
		self._eye_animation:stop()

		self._eye_animation = nil

		self._sound_source:post_event("hud_suspicion_end")
	end

	self._suspicion_value = 0
	self._discovered = nil
	self._back_to_stealth = nil

	if alive(self._misc_panel) then
		self._misc_panel:stop()
		self._misc_panel:child("hud_stealth_eye"):set_alpha(0)
		self._misc_panel:child("hud_stealth_exclam"):set_alpha(0)
		self._misc_panel:child("hud_stealthmeter_bg"):set_alpha(0)
	end

	if alive(self._suspicion_panel) then
		self._suspicion_panel:set_visible(false)
		self._suspicion_panel:child("suspicion_detected"):stop()
		self._suspicion_panel:child("suspicion_detected"):set_alpha(0)
	end
end

function HUDSuspicion:feed_value(value)
	self:show()

	self._suspicion_value = math.min(value, 1)
	self._hud_timeout = 5
end

function HUDSuspicion:back_to_stealth()
	self._back_to_stealth = true

	if not self._eye_animation then
		self:hide()
	end
end

function HUDSuspicion:discovered()
	self._discovered = true
end

if _G.IS_VR then
	require("lib/managers/hud/vr/HUDSuspicionVR")
end
