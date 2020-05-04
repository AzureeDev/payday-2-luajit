HUDAssaultCorner = HUDAssaultCorner or class()

function HUDAssaultCorner:init(hud, full_hud, tweak_hud)
	self._hud_panel = hud.panel
	self._full_hud_panel = full_hud.panel

	if self._hud_panel:child("assault_panel") then
		self._hud_panel:remove(self._hud_panel:child("assault_panel"))
	end

	local size = 200

	if _G.IS_VR then
		size = 150
	end

	local assault_panel = self._hud_panel:panel({
		name = "assault_panel",
		h = 100,
		visible = false,
		w = size * 2
	})

	assault_panel:set_top(0)
	assault_panel:set_right(self._hud_panel:w())

	self._assault_mode = "normal"
	self._assault_color = Color(1, 1, 1, 0)
	self._vip_assault_color = Color(1, 1, 0.5019607843137255, 0)

	if managers.mutators:are_mutators_active() then
		self._assault_color = Color(255, 211, 133, 255) / 255
		self._vip_assault_color = Color(255, 255, 133, 225) / 255
	end

	if managers.skirmish:is_skirmish() then
		self._assault_color = tweak_data.screen_colors.skirmish_color
	end

	self._assault_survived_color = Color(1, 0.12549019607843137, 0.9019607843137255, 0.12549019607843137)
	self._current_assault_color = self._assault_color
	local icon_assaultbox = assault_panel:bitmap({
		texture = "guis/textures/pd2/hud_icon_assaultbox",
		name = "icon_assaultbox",
		h = 24,
		layer = 0,
		w = 24,
		y = 0,
		visible = true,
		blend_mode = "add",
		halign = "right",
		x = 0,
		valign = "top",
		color = self._assault_color
	})

	icon_assaultbox:set_right(icon_assaultbox:parent():w())

	self._bg_box_size = size * 1.5 - 58
	self._bg_box = HUDBGBox_create(assault_panel, {
		x = 0,
		h = 38,
		y = 0,
		w = self._bg_box_size
	}, {
		blend_mode = "add",
		color = self._assault_color
	})

	self._bg_box:set_right(icon_assaultbox:left() - 3)

	local yellow_tape = assault_panel:rect({
		name = "yellow_tape",
		visible = false,
		layer = 1,
		h = tweak_data.hud.location_font_size * 1.5,
		w = size * 3,
		color = Color(1, 0.8, 0)
	})

	yellow_tape:set_center(10, 10)
	yellow_tape:set_rotation(30)
	yellow_tape:set_blend_mode("add")
	assault_panel:panel({
		name = "text_panel",
		layer = 1,
		w = yellow_tape:w()
	}):set_center(yellow_tape:center())

	if self._hud_panel:child("hostages_panel") then
		self._hud_panel:remove(self._hud_panel:child("hostages_panel"))
	end

	local hostage_w = 70
	local hostage_h = 38
	local hostage_box = 38
	local hostages_panel = self._hud_panel:panel({
		name = "hostages_panel",
		w = hostage_w,
		h = hostage_h,
		x = self._hud_panel:w() - hostage_w
	})
	local hostages_icon = hostages_panel:bitmap({
		texture = "guis/textures/pd2/hud_icon_hostage",
		name = "hostages_icon",
		layer = 1,
		y = 0,
		x = 0,
		valign = "top"
	})
	self._hostages_bg_box = HUDBGBox_create(hostages_panel, {
		x = 0,
		y = 0,
		w = hostage_box,
		h = hostage_box
	}, {})

	hostages_icon:set_right(hostages_panel:w() + 5)
	hostages_icon:set_center_y(self._hostages_bg_box:h() / 2)
	self._hostages_bg_box:set_right(hostages_icon:left())

	local num_hostages = self._hostages_bg_box:text({
		layer = 1,
		vertical = "center",
		name = "num_hostages",
		align = "center",
		text = "0",
		y = 0,
		x = 0,
		valign = "center",
		w = self._hostages_bg_box:w(),
		h = self._hostages_bg_box:h(),
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
		font_size = tweak_data.hud_corner.numhostages_size
	})

	if tweak_hud.no_hostages then
		hostages_panel:hide()
	end

	self:setup_wave_display(0, hostages_panel:left() - 3)

	if self._hud_panel:child("point_of_no_return_panel") then
		self._hud_panel:remove(self._hud_panel:child("point_of_no_return_panel"))
	end

	local size = 300
	local point_of_no_return_panel = self._hud_panel:panel({
		name = "point_of_no_return_panel",
		h = 40,
		visible = false,
		w = size,
		x = self._hud_panel:w() - size
	})
	self._noreturn_color = Color(1, 1, 0, 0)
	local icon_noreturnbox = point_of_no_return_panel:bitmap({
		texture = "guis/textures/pd2/hud_icon_noreturnbox",
		name = "icon_noreturnbox",
		h = 24,
		layer = 0,
		w = 24,
		y = 0,
		visible = true,
		blend_mode = "add",
		halign = "right",
		x = 0,
		valign = "top",
		color = self._noreturn_color
	})

	icon_noreturnbox:set_right(icon_noreturnbox:parent():w())

	self._noreturn_bg_box = HUDBGBox_create(point_of_no_return_panel, {
		x = 0,
		h = 38,
		y = 0,
		w = self._bg_box_size
	}, {
		blend_mode = "add",
		color = self._noreturn_color
	})

	self._noreturn_bg_box:set_right(icon_noreturnbox:left() - 3)

	local w = point_of_no_return_panel:w()
	local size = 200 - tweak_data.hud.location_font_size
	local point_of_no_return_text = self._noreturn_bg_box:text({
		valign = "center",
		vertical = "center",
		name = "point_of_no_return_text",
		blend_mode = "add",
		align = "right",
		text = "",
		y = 0,
		x = 0,
		layer = 1,
		color = self._noreturn_color,
		font_size = tweak_data.hud_corner.noreturn_size,
		font = tweak_data.hud_corner.assault_font
	})

	point_of_no_return_text:set_text(utf8.to_upper(managers.localization:text("hud_assault_point_no_return_in", {
		time = ""
	})))
	point_of_no_return_text:set_size(self._noreturn_bg_box:w(), self._noreturn_bg_box:h())

	local point_of_no_return_timer = self._noreturn_bg_box:text({
		valign = "center",
		vertical = "center",
		name = "point_of_no_return_timer",
		blend_mode = "add",
		align = "center",
		text = "",
		y = 0,
		x = 0,
		layer = 1,
		color = self._noreturn_color,
		font_size = tweak_data.hud_corner.noreturn_size,
		font = tweak_data.hud_corner.assault_font
	})
	local _, _, w, h = point_of_no_return_timer:text_rect()

	point_of_no_return_timer:set_size(46, self._noreturn_bg_box:h())
	point_of_no_return_timer:set_right(point_of_no_return_timer:parent():w())
	point_of_no_return_text:set_right(math.round(point_of_no_return_timer:left()))

	if self._hud_panel:child("casing_panel") then
		self._hud_panel:remove(self._hud_panel:child("casing_panel"))
	end

	local size = 300
	local casing_panel = self._hud_panel:panel({
		name = "casing_panel",
		h = 40,
		visible = false,
		w = size,
		x = self._hud_panel:w() - size
	})
	self._casing_color = Color.white
	local icon_casingbox = casing_panel:bitmap({
		texture = "guis/textures/pd2/hud_icon_stealthbox",
		name = "icon_casingbox",
		h = 24,
		layer = 0,
		w = 24,
		y = 0,
		visible = true,
		blend_mode = "add",
		halign = "right",
		x = 0,
		valign = "top",
		color = self._casing_color
	})

	icon_casingbox:set_right(icon_casingbox:parent():w())

	self._casing_bg_box = HUDBGBox_create(casing_panel, {
		x = 0,
		h = 38,
		y = 0,
		w = self._bg_box_size
	}, {
		blend_mode = "add",
		color = self._casing_color
	})

	self._casing_bg_box:set_right(icon_casingbox:left() - 3)

	local w = casing_panel:w()
	local size = 200 - tweak_data.hud.location_font_size

	casing_panel:panel({
		name = "text_panel",
		layer = 1,
		w = yellow_tape:w()
	}):set_center(yellow_tape:center())

	if self._hud_panel:child("buffs_panel") then
		self._hud_panel:remove(self._hud_panel:child("buffs_panel"))
	end

	local width = 200
	local x = assault_panel:left() + self._bg_box:left() - 3 - width
	local buffs_panel = self._hud_panel:panel({
		name = "buffs_panel",
		h = 38,
		visible = false,
		w = width,
		x = x
	})
	self._vip_bg_box_bg_color = Color(1, 0, 0.6666666666666666, 1)
	self._vip_bg_box = HUDBGBox_create(buffs_panel, {
		w = 38,
		h = 38,
		y = 0,
		x = width - 38
	}, {
		color = Color.white,
		bg_color = self._vip_bg_box_bg_color
	})
	local vip_icon = self._vip_bg_box:bitmap({
		texture = "guis/textures/pd2/hud_buff_shield",
		name = "vip_icon",
		h = 38,
		layer = 0,
		w = 38,
		y = 0,
		visible = true,
		blend_mode = "add",
		halign = "center",
		x = 0,
		valign = "center",
		color = Color.white
	})

	vip_icon:set_center(self._vip_bg_box:w() / 2, self._vip_bg_box:h() / 2)
end

function HUDAssaultCorner:setup_wave_display(top, right)
	if self._hud_panel:child("wave_panel") then
		self._hud_panel:remove(self._hud_panel:child("wave_panel"))
	end

	self._max_waves = 0
	self._wave_number = 0
	self._max_waves = managers.job:current_level_wave_count()

	if self:should_display_waves() then
		self._wave_panel_size = {
			145,
			38
		}
		local wave_w = 38
		local wave_h = 38
		local wave_panel = self._hud_panel:panel({
			name = "wave_panel",
			w = self._wave_panel_size[1],
			h = self._wave_panel_size[2]
		})

		wave_panel:set_top(top)
		wave_panel:set_right(right)

		local waves_icon = wave_panel:bitmap({
			texture = "guis/textures/pd2/specialization/icons_atlas",
			name = "waves_icon",
			layer = 1,
			valign = "top",
			y = 0,
			x = 0,
			texture_rect = {
				192,
				64,
				64,
				64
			},
			w = wave_w,
			h = wave_h
		})
		self._wave_bg_box = HUDBGBox_create(wave_panel, {
			w = 100,
			x = 0,
			y = 0,
			h = wave_h
		}, {
			blend_mode = "add"
		})

		waves_icon:set_right(wave_panel:w())
		waves_icon:set_center_y(self._wave_bg_box:h() * 0.5)
		self._wave_bg_box:set_right(waves_icon:left())

		local num_waves = self._wave_bg_box:text({
			vertical = "center",
			name = "num_waves",
			layer = 1,
			align = "center",
			y = 0,
			halign = "right",
			x = 0,
			valign = "center",
			text = self:get_completed_waves_string(),
			w = self._wave_bg_box:w(),
			h = self._wave_bg_box:h(),
			color = Color.white,
			font = tweak_data.hud_corner.assault_font,
			font_size = tweak_data.hud_corner.numhostages_size
		})
	end
end

function HUDAssaultCorner:should_display_waves()
	return self._max_waves < math.huge
end

function HUDAssaultCorner:_animate_text(text_panel, bg_box, color, color_function)
	local text_list = (bg_box or self._bg_box):script().text_list
	local text_index = 0
	local texts = {}
	local padding = 10

	local function create_new_text(text_panel, text_list, text_index, texts)
		if texts[text_index] and texts[text_index].text then
			text_panel:remove(texts[text_index].text)

			texts[text_index] = nil
		end

		local text_id = text_list[text_index]
		local text_string = ""

		if type(text_id) == "string" then
			text_string = managers.localization:to_upper_text(text_id)
		elseif text_id == Idstring("risk") then
			local use_stars = true

			if managers.crime_spree:is_active() then
				text_string = text_string .. managers.localization:to_upper_text("menu_cs_level", {
					level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")
				})
				use_stars = false
			end

			if use_stars then
				for i = 1, managers.job:current_difficulty_stars() do
					text_string = text_string .. managers.localization:get_default_macro("BTN_SKULL")
				end
			end
		end

		local mod_color = color_function and color_function() or color or self._assault_color
		local text = text_panel:text({
			vertical = "center",
			h = 10,
			w = 10,
			align = "center",
			blend_mode = "add",
			layer = 1,
			text = text_string,
			color = mod_color,
			font_size = tweak_data.hud_corner.assault_size,
			font = tweak_data.hud_corner.assault_font
		})
		local _, _, w, h = text:text_rect()

		text:set_size(w, h)

		texts[text_index] = {
			x = text_panel:w() + w * 0.5 + padding * 2,
			text = text
		}
	end

	while true do
		local dt = coroutine.yield()
		local last_text = texts[text_index]

		if last_text and last_text.text then
			if last_text.x + last_text.text:w() * 0.5 + padding < text_panel:w() then
				text_index = text_index % #text_list + 1

				create_new_text(text_panel, text_list, text_index, texts)
			end
		else
			text_index = text_index % #text_list + 1

			create_new_text(text_panel, text_list, text_index, texts)
		end

		local speed = 90

		for i, data in pairs(texts) do
			if data.text then
				data.x = data.x - dt * speed

				data.text:set_center_x(data.x)
				data.text:set_center_y(text_panel:h() * 0.5)

				if data.x + data.text:w() * 0.5 < 0 then
					text_panel:remove(data.text)

					data.text = nil
				elseif color_function then
					data.text:set_color(color_function())
				end
			end
		end
	end
end

function HUDAssaultCorner:set_buff_enabled(buff_name, enabled)
	self._hud_panel:child("buffs_panel"):set_visible(enabled)

	local bg = self._vip_bg_box:child("bg")

	bg:stop()

	if enabled then
		bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {
			forever = true,
			color = self._vip_bg_box_bg_color
		})
	end
end

function HUDAssaultCorner:get_assault_mode()
	return self._assault_mode
end

function HUDAssaultCorner:sync_set_assault_mode(mode)
	if self._assault_mode == mode then
		return
	end

	self._assault_mode = mode
	local color = self._assault_color

	if mode == "phalanx" then
		color = self._vip_assault_color
	end

	self:_update_assault_hud_color(color)
	self:_set_text_list(self:_get_assault_strings())

	local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = assault_panel:child("icon_assaultbox")
	local image = mode == "phalanx" and "guis/textures/pd2/hud_icon_padlockbox" or "guis/textures/pd2/hud_icon_assaultbox"

	icon_assaultbox:set_image(image)
end

function HUDAssaultCorner:_update_assault_hud_color(color)
	self._current_assault_color = color

	self._bg_box:child("left_top"):set_color(color)
	self._bg_box:child("left_bottom"):set_color(color)
	self._bg_box:child("right_top"):set_color(color)
	self._bg_box:child("right_bottom"):set_color(color)

	local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = assault_panel:child("icon_assaultbox")

	icon_assaultbox:set_color(color)
end

function HUDAssaultCorner:sync_start_assault(assault_number)
	if self._point_of_no_return or self._casing then
		return
	end

	local color = self._assault_color

	if self._assault_mode == "phalanx" then
		color = self._vip_assault_color
	end

	self:_update_assault_hud_color(color)
	self:set_assault_wave_number(assault_number)

	self._start_assault_after_hostage_offset = true

	self:_set_hostage_offseted(true)
end

function HUDAssaultCorner:set_assault_wave_number(assault_number)
	self._wave_number = assault_number
	local panel = self._hud_panel:child("wave_panel")

	print("found panel")

	if alive(self._wave_bg_box) and panel then
		local wave_text = panel:child("num_waves")

		if wave_text then
			wave_text:set_text(self:get_completed_waves_string())
		end
	end
end

function HUDAssaultCorner:start_assault_callback()
	self:_start_assault(self:_get_assault_strings())
end

function HUDAssaultCorner:_get_assault_strings()
	if self._assault_mode == "normal" then
		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")

			return {
				"hud_assault_assault",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				"hud_assault_assault",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line"
			}
		else
			return {
				"hud_assault_assault",
				"hud_assault_end_line",
				"hud_assault_assault",
				"hud_assault_end_line",
				"hud_assault_assault",
				"hud_assault_end_line"
			}
		end
	end

	if self._assault_mode == "phalanx" then
		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")

			return {
				"hud_assault_vip",
				"hud_assault_padlock",
				ids_risk,
				"hud_assault_padlock",
				"hud_assault_vip",
				"hud_assault_padlock",
				ids_risk,
				"hud_assault_padlock"
			}
		else
			return {
				"hud_assault_vip",
				"hud_assault_padlock",
				"hud_assault_vip",
				"hud_assault_padlock",
				"hud_assault_vip",
				"hud_assault_padlock"
			}
		end
	end
end

function HUDAssaultCorner:_get_survived_assault_strings()
	if managers.job:current_difficulty_stars() > 0 then
		local ids_risk = Idstring("risk")

		return {
			"hud_assault_survived",
			"hud_assault_end_line",
			ids_risk,
			"hud_assault_end_line",
			"hud_assault_survived",
			"hud_assault_end_line",
			ids_risk,
			"hud_assault_end_line"
		}
	else
		return {
			"hud_assault_survived",
			"hud_assault_end_line",
			"hud_assault_survived",
			"hud_assault_end_line",
			"hud_assault_survived",
			"hud_assault_end_line"
		}
	end
end

function HUDAssaultCorner:sync_end_assault(result)
	if self._point_of_no_return or self._casing then
		return
	end

	self:_end_assault()
end

function HUDAssaultCorner:_set_text_list(text_list)
	local assault_panel = self._hud_panel:child("assault_panel")
	local text_panel = assault_panel:child("text_panel")
	text_panel:script().text_list = text_panel:script().text_list or {}

	while #text_panel:script().text_list > 0 do
		table.remove(text_panel:script().text_list)
	end

	self._bg_box:script().text_list = self._bg_box:script().text_list or {}

	while #self._bg_box:script().text_list > 0 do
		table.remove(self._bg_box:script().text_list)
	end

	for _, text_id in ipairs(text_list) do
		table.insert(text_panel:script().text_list, text_id)
		table.insert(self._bg_box:script().text_list, text_id)
	end
end

function HUDAssaultCorner:_start_assault(text_list)
	text_list = text_list or {
		""
	}
	local assault_panel = self._hud_panel:child("assault_panel")
	local text_panel = assault_panel:child("text_panel")

	self:_set_text_list(text_list)

	local started_now = not self._assault
	self._assault = true

	if self._bg_box:child("text_panel") then
		self._bg_box:child("text_panel"):stop()
		self._bg_box:child("text_panel"):clear()
	else
		self._bg_box:panel({
			name = "text_panel"
		})
	end

	self._bg_box:child("bg"):stop()
	assault_panel:set_visible(true)

	local icon_assaultbox = assault_panel:child("icon_assaultbox")

	icon_assaultbox:stop()
	icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"))

	local config = {
		attention_forever = true,
		attention_color = self._assault_color,
		attention_color_function = callback(self, self, "assault_attention_color_function")
	}

	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_left"), 0.75, self._bg_box_size, function ()
	end, config)

	local box_text_panel = self._bg_box:child("text_panel")

	box_text_panel:stop()
	box_text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
	self:_set_feedback_color(self._assault_color)

	if alive(self._wave_bg_box) then
		self._wave_bg_box:stop()
		self._wave_bg_box:animate(callback(self, self, "_animate_wave_started"), self)
	end

	if managers.skirmish:is_skirmish() and started_now then
		self:_popup_wave_started()
	end
end

function HUDAssaultCorner:assault_attention_color_function()
	return self._current_assault_color
end

function HUDAssaultCorner:_end_assault()
	if not self._assault then
		self._start_assault_after_hostage_offset = nil

		return
	end

	self:_set_feedback_color(nil)

	self._assault = false
	local box_text_panel = self._bg_box:child("text_panel")

	box_text_panel:stop()
	box_text_panel:clear()

	self._remove_hostage_offset = true
	self._start_assault_after_hostage_offset = nil
	local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")

	icon_assaultbox:stop()

	if self:should_display_waves() then
		self:_update_assault_hud_color(self._assault_survived_color)
		self:_set_text_list(self:_get_survived_assault_strings())
		box_text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
		icon_assaultbox:stop()
		icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"))
		self._wave_bg_box:stop()
		self._wave_bg_box:animate(callback(self, self, "_animate_wave_completed"), self)

		if managers.skirmish:is_skirmish() then
			self:_popup_wave_finished()
		end
	else
		self:_close_assault_box()
	end
end

function HUDAssaultCorner:_close_assault_box()
	local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")

	icon_assaultbox:stop()

	local function close_done()
		self._bg_box:set_visible(false)
		icon_assaultbox:stop()
		icon_assaultbox:animate(callback(self, self, "_hide_icon_assaultbox"))
		self:sync_set_assault_mode("normal")
	end

	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_left"), close_done)
end

function HUDAssaultCorner:_show_icon_assaultbox(icon_assaultbox)
	local TOTAL_T = 2
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local alpha = math.round(math.abs(math.sin(t * 360 * 2)))

		icon_assaultbox:set_alpha(alpha)
	end

	icon_assaultbox:set_alpha(1)
end

function HUDAssaultCorner:_hide_icon_assaultbox(icon_assaultbox)
	local TOTAL_T = 1
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local alpha = math.round(math.abs(math.cos(t * 360 * 2)))

		icon_assaultbox:set_alpha(alpha)

		if self._remove_hostage_offset and t < 0.03 then
			self:_set_hostage_offseted(false)
		end
	end

	if self._remove_hostage_offset then
		self:_set_hostage_offseted(false)
	end

	icon_assaultbox:set_alpha(0)

	if not self._casing then
		self:_show_hostages()
	end
end

function HUDAssaultCorner:_show_hostages()
	if not self._point_of_no_return then
		self._hud_panel:child("hostages_panel"):show()
	end
end

function HUDAssaultCorner:_hide_hostages()
	self._hud_panel:child("hostages_panel"):hide()
end

function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
	local hostage_panel = self._hud_panel:child("hostages_panel")
	self._remove_hostage_offset = nil

	hostage_panel:stop()
	hostage_panel:animate(callback(self, self, "_offset_hostage", is_offseted))

	local wave_panel = self._hud_panel:child("wave_panel")

	if wave_panel then
		wave_panel:stop()
		wave_panel:animate(callback(self, self, "_offset_hostage", is_offseted))
	end
end

function HUDAssaultCorner:_offset_hostage(is_offseted, hostage_panel)
	local TOTAL_T = 0.18
	local OFFSET = self._bg_box:h() + 8
	local from_y = is_offseted and 0 or OFFSET
	local target_y = is_offseted and OFFSET or 0
	local t = (1 - math.abs(hostage_panel:y() - target_y) / OFFSET) * TOTAL_T

	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = math.min(t + dt, TOTAL_T)
		local lerp = t / TOTAL_T

		hostage_panel:set_y(math.lerp(from_y, target_y, lerp))

		if self._start_assault_after_hostage_offset and lerp > 0.4 then
			self._start_assault_after_hostage_offset = nil

			self:start_assault_callback()
		end
	end

	if self._start_assault_after_hostage_offset then
		self._start_assault_after_hostage_offset = nil

		self:start_assault_callback()
	end
end

function HUDAssaultCorner:set_control_info(data)
	self._hostages_bg_box:child("num_hostages"):set_text("" .. data.nr_hostages)

	local bg = self._hostages_bg_box:child("bg")

	bg:stop()
	bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {})
end

function HUDAssaultCorner:feed_point_of_no_return_timer(time, is_inside)
	time = math.floor(time)
	local minutes = math.floor(time / 60)
	local seconds = math.round(time - minutes * 60)
	local text = (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)

	self._noreturn_bg_box:child("point_of_no_return_timer"):set_text(text)
end

function HUDAssaultCorner:show_point_of_no_return_timer()
	local delay_time = self._assault and 1.2 or 0

	self:_end_assault()

	local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")

	self:_hide_hostages()
	point_of_no_return_panel:stop()
	point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
	self:_set_feedback_color(self._noreturn_color)

	self._point_of_no_return = true
end

function HUDAssaultCorner:hide_point_of_no_return_timer()
	self._noreturn_bg_box:stop()
	self._hud_panel:child("point_of_no_return_panel"):set_visible(false)

	self._point_of_no_return = false

	self:_show_hostages()
	self:_set_feedback_color(nil)
end

function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
	local function flash_timer(o)
		local t = 0

		while t < 0.5 do
			t = t + coroutine.yield()
			local n = 1 - math.sin(t * 180)
			local r = math.lerp(1 or self._point_of_no_return_color.r, 1, n)
			local g = math.lerp(0 or self._point_of_no_return_color.g, 0.8, n)
			local b = math.lerp(0 or self._point_of_no_return_color.b, 0.2, n)

			o:set_color(Color(r, g, b))
			o:set_font_size(math.lerp(tweak_data.hud_corner.noreturn_size, tweak_data.hud_corner.noreturn_size * 1.25, n))
		end
	end

	local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")

	point_of_no_return_timer:animate(flash_timer)
end

function HUDAssaultCorner:show_casing(mode)
	local delay_time = self._assault and 1.2 or 0

	self:_end_assault()

	local casing_panel = self._hud_panel:child("casing_panel")
	local text_panel = casing_panel:child("text_panel")
	text_panel:script().text_list = {}
	self._casing_bg_box:script().text_list = {}
	local msg = nil

	if mode == "civilian" then
		msg = {
			"hud_casing_mode_ticker_clean",
			"hud_assault_end_line",
			"hud_casing_mode_ticker_clean",
			"hud_assault_end_line"
		}
	else
		msg = {
			"hud_casing_mode_ticker",
			"hud_assault_end_line",
			"hud_casing_mode_ticker",
			"hud_assault_end_line"
		}
	end

	for _, text_id in ipairs(msg) do
		table.insert(text_panel:script().text_list, text_id)
		table.insert(self._casing_bg_box:script().text_list, text_id)
	end

	if self._casing_bg_box:child("text_panel") then
		self._casing_bg_box:child("text_panel"):stop()
		self._casing_bg_box:child("text_panel"):clear()
	else
		self._casing_bg_box:panel({
			halign = "grow",
			name = "text_panel"
		})
	end

	self._casing_bg_box:child("bg"):stop()
	self:_hide_hostages()
	casing_panel:stop()
	casing_panel:animate(callback(self, self, "_animate_show_casing"), delay_time)

	self._casing = true
end

function HUDAssaultCorner:hide_casing()
	if self._casing_bg_box:child("text_panel") then
		self._casing_bg_box:child("text_panel"):stop()
		self._casing_bg_box:child("text_panel"):clear()
	end

	local icon_casingbox = self._hud_panel:child("casing_panel"):child("icon_casingbox")

	icon_casingbox:stop()

	local function close_done()
		self._casing_bg_box:set_visible(false)

		local icon_casingbox = self._hud_panel:child("casing_panel"):child("icon_casingbox")

		icon_casingbox:stop()
		icon_casingbox:animate(callback(self, self, "_hide_icon_assaultbox"))
	end

	self._casing_bg_box:stop()
	self._casing_bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_left"), close_done)

	self._casing = false
end

function HUDAssaultCorner:_animate_simple_text(text)
	local _, _, w, _ = text:text_rect()

	text:set_w(w + 10)
	text:set_visible(true)
	text:set_x(text:parent():w())

	local x = text:x()
	local t = 0
	local speed = 90

	while true do
		local dt = coroutine.yield()
		t = t + dt
		x = x - speed * dt

		text:set_x(x)

		if text:right() < 0 then
			text:set_x(text:parent():w())

			x = text:x()
		end
	end
end

function HUDAssaultCorner:_animate_show_casing(casing_panel, delay_time)
	local icon_casingbox = casing_panel:child("icon_casingbox")

	wait(delay_time)
	casing_panel:set_visible(true)
	icon_casingbox:stop()
	icon_casingbox:animate(callback(self, self, "_show_icon_assaultbox"))

	local function open_done()
	end

	self._casing_bg_box:stop()
	self._casing_bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_left"), 0.75, self._bg_box_size, open_done, {
		attention_forever = true,
		attention_color = self._casing_color
	})

	local text_panel = self._casing_bg_box:child("text_panel")

	text_panel:stop()
	text_panel:animate(callback(self, self, "_animate_text"), self._casing_bg_box, Color.white)
end

function HUDAssaultCorner:_animate_show_noreturn(point_of_no_return_panel, delay_time)
	local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
	local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")

	point_of_no_return_text:set_visible(false)

	local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")

	point_of_no_return_timer:set_visible(false)
	wait(delay_time)
	point_of_no_return_panel:set_visible(true)
	icon_noreturnbox:stop()
	icon_noreturnbox:animate(callback(self, self, "_show_icon_assaultbox"))

	local function open_done()
		point_of_no_return_text:animate(callback(self, self, "_animate_show_texts"), {
			point_of_no_return_text,
			point_of_no_return_timer
		})
	end

	self._noreturn_bg_box:stop()
	self._noreturn_bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_left"), 0.75, self._bg_box_size, open_done, {
		attention_forever = true,
		attention_color = self._casing_color
	})
end

function HUDAssaultCorner:_animate_show_texts(anim_object, texts)
	for _, text in ipairs(texts) do
		text:set_visible(true)
	end

	local TOTAL_T = 0.5
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local alpha = math.round(math.abs(math.sin(t * 360 * 3)))

		for _, text in ipairs(texts) do
			text:set_alpha(alpha)
		end
	end

	for _, text in ipairs(texts) do
		text:set_alpha(1)
	end
end

function HUDAssaultCorner:test()
	self._hud_panel:child("point_of_no_return_panel"):animate(callback(self, self, "_animate_test_point_of_no_return"))
end

function HUDAssaultCorner:_animate_test_point_of_no_return(panel)
	managers.hud:show_point_of_no_return_timer()

	local t = 15
	local prev_time = t

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local sec = math.floor(t)

		if sec < math.floor(prev_time) then
			prev_time = sec

			managers.hud:flash_point_of_no_return_timer(sec <= 10)
		end

		managers.hud:feed_point_of_no_return_timer(math.max(t, 0), false)
	end

	managers.hud:hide_point_of_no_return_timer()
end

function HUDAssaultCorner:_set_feedback_color(color)
	if self._feedback_color ~= color then
		self._feedback_color = color

		if color then
			self._feedback_color_t = 2.8

			managers.hud:add_updator("feedback_color", callback(self, self, "_update_feedback_alpha"))
		else
			managers.hud:remove_updator("feedback_color")
			managers.platform:set_feedback_color(nil)
		end
	end
end

function HUDAssaultCorner:_update_feedback_alpha(t, dt)
	self._feedback_color_t = self._feedback_color_t - dt
	local alpha_curve = math.sin(self._feedback_color_t * 180)
	local alpha = math.abs(alpha_curve)
	local color = self._feedback_color

	if color == self._assault_color then
		if alpha_curve < 0 then
			color = Color.blue
		else
			color = Color.red
		end
	end

	managers.platform:set_feedback_color(color:with_alpha(alpha))
end

function HUDAssaultCorner:_animate_wave_started(panel, assault_hud)
	local wave_text = panel:child("num_waves")
	local bg = panel:child("bg")

	wave_text:set_text(self:get_completed_waves_string())
	bg:stop()
	bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {})
end

function HUDAssaultCorner:_animate_wave_completed(panel, assault_hud)
	local wave_text = panel:child("num_waves")
	local bg = panel:child("bg")

	wait(1.4)
	wave_text:set_text(self:get_completed_waves_string())
	bg:stop()
	bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {})
	wait(7.2)
	assault_hud:_close_assault_box()
end

function HUDAssaultCorner:get_completed_waves_string()
	local macro = {
		current = managers.network:session():is_host() and managers.groupai:state():get_assault_number() or self._wave_number,
		max = self._max_waves or 0
	}

	return managers.localization:to_upper_text("hud_assault_waves", macro)
end

function HUDAssaultCorner:wave_popup_string_start()
	local macro = {
		current = managers.network:session():is_host() and managers.groupai:state():get_assault_number() or self._wave_number
	}

	return managers.localization:to_upper_text("hud_skirmish_wave_start", macro)
end

function HUDAssaultCorner:wave_popup_string_end()
	local macro = {
		current = managers.network:session():is_host() and managers.groupai:state():get_assault_number() or self._wave_number
	}

	return managers.localization:to_upper_text("hud_skirmish_wave_end", macro)
end

function HUDAssaultCorner:_popup_wave_started()
	self:_popup_wave(self:wave_popup_string_start(), self._assault_color)
end

function HUDAssaultCorner:_popup_wave_finished()
	self:_popup_wave(self:wave_popup_string_end(), self._assault_survived_color)
end

function HUDAssaultCorner:_popup_wave(text, color)
	local popup_panel = self._hud_panel:panel({
		w = 250,
		name = "wave_popup",
		h = tweak_data.hud_corner.assault_size + 10
	})

	popup_panel:set_center_x(self._hud_panel:w() / 2)
	popup_panel:set_center_y(self._hud_panel:h() / 3.5)

	local box = BoxGuiObject:new(popup_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	box:set_color(color)
	popup_panel:rect({
		name = "bg",
		color = color:with_alpha(0.3)
	})
	popup_panel:text({
		name = "text",
		vertical = "center",
		align = "center",
		text = text,
		font = tweak_data.hud_corner.assault_font,
		font_size = tweak_data.hud_corner.assault_size,
		color = color
	})

	local function animate_popup(panel)
		local cx = panel:center_x()

		over(0.25, function (p)
			if alive(panel) then
				panel:set_w(p * 250)
				panel:set_center_x(cx)
				panel:child("text"):set_center_x(panel:w() / 2)
			end
		end)
		wait(2.5)
		over(0.25, function (p)
			if alive(panel) then
				panel:set_w((1 - p) * 250)
				panel:set_center_x(cx)
				panel:child("text"):set_center_x(panel:w() / 2)
			end
		end)

		if alive(panel) then
			panel:parent():remove(panel)
		end
	end

	popup_panel:animate(animate_popup)
end

if _G.IS_VR then
	require("lib/managers/hud/vr/HUDAssaultCornerVR")
end
