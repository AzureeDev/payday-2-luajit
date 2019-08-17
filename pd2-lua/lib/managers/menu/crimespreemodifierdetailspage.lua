CrimeSpreeModifierDetailsPage = CrimeSpreeModifierDetailsPage or class(CrimeSpreeDetailsPage)
local padding = 10

function CrimeSpreeModifierDetailsPage:init(...)
	CrimeSpreeModifierDetailsPage.super.init(self, ...)

	local modifiers = managers.crime_spree:server_active_modifiers()
	local next_modifiers_h = tweak_data.menu.pd2_small_font_size * 2 + padding * 0.5
	local line_h = tweak_data.menu.pd2_small_font_size * 1.5
	local warning_title, warning_text = nil

	if managers.crime_spree:server_spree_level() < managers.crime_spree:spree_level() then
		warning_title = "menu_cs_modifiers_suspended"
		warning_text = "menu_cs_modifiers_suspended_desc"
	elseif not managers.crime_spree:in_progress() then
		warning_title = "menu_cs_modifiers_not_in_progress"
		warning_text = "menu_cs_modifiers_not_in_progress_desc"
	elseif managers.crime_spree:has_failed() then
		warning_title = "menu_cs_modifiers_has_failed"
		warning_text = "menu_cs_modifiers_has_failed_desc"
	end

	local level_layer = 50

	if warning_title then
		local level_panel = self:panel():panel({
			layer = level_layer
		})

		level_panel:bitmap({
			texture = "guis/textures/pd2/cs_warning_background",
			name = "background",
			h = 128,
			layer = 10,
			color = Color.white,
			w = level_panel:w()
		})

		local suspend_text = level_panel:text({
			word_wrap = true,
			vertical = "left",
			wrap = true,
			align = "left",
			layer = 20,
			text = warning_title and managers.localization:to_upper_text(warning_title) or "",
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			color = Color.white
		})

		self:make_fine_text(suspend_text)
		suspend_text:set_top(padding * 2)
		suspend_text:set_left(padding * 4)

		local w_multi = 0.75
		local suspend_desc_text = level_panel:text({
			vertical = "top",
			word_wrap = true,
			wrap = true,
			align = "left",
			layer = 20,
			text = warning_text and managers.localization:text(warning_text) or "",
			x = self:panel():w() * (1 - w_multi) * 0.5,
			w = self:panel():w() * w_multi,
			font_size = tweak_data.menu.pd2_small_font_size,
			font = tweak_data.menu.pd2_small_font,
			color = Color.white
		})

		self:make_fine_text(suspend_desc_text)
		suspend_desc_text:set_top(suspend_text:bottom())
		suspend_desc_text:set_left(padding * 4)

		next_modifiers_h = suspend_desc_text:bottom() + padding
	end

	self._next_panel = self:panel():panel({
		h = next_modifiers_h
	})
	local name_color = managers.crime_spree:in_progress() and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1
	self._next_text = self._next_panel:text({
		vertical = "center",
		align = "left",
		halign = "left",
		layer = 1,
		text = self:upcoming_modifiers_text(),
		x = padding,
		color = name_color,
		font = tweak_data.menu.pd2_tiny_font,
		font_size = tweak_data.menu.pd2_tiny_font_size,
		h = next_modifiers_h
	})

	self._next_text:set_visible(not warning_title)

	self._cached_server_level = managers.crime_spree:server_spree_level()
	local modifiers_panel = self:panel():panel({
		y = self._next_panel:h() - padding,
		h = self:panel():h() - self._next_panel:h() + padding
	})
	local modifiers_h = CrimeSpreeModifierDetailsPage.add_modifiers_panel(self, modifiers_panel, nil, true)
	modifiers_h = modifiers_h + next_modifiers_h

	self:panel():bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		halign = "scale",
		alpha = 1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = self:panel():w(),
		h = modifiers_h
	})
	self:panel():rect({
		halign = "scale",
		alpha = 0.5,
		valign = "scale",
		color = Color.black,
		h = modifiers_h
	})

	local outline_panel = self:panel():panel({
		w = self._next_panel:w(),
		h = math.min(modifiers_h, self:panel():h()),
		layer = warning_title and level_layer + 10 or 0
	})

	BoxGuiObject:new(outline_panel, {
		sides = {
			4,
			4,
			2,
			1
		}
	})
end

function CrimeSpreeModifierDetailsPage:upcoming_modifiers_text()
	local upcoming_modifiers_text = ""

	for i, category in ipairs({
		"forced",
		"loud",
		"stealth"
	}) do
		local next_level = managers.crime_spree:next_modifier_level(category)

		if next_level then
			local text_id = "menu_cs_next_modifier_" .. category
			local padding = i > 1 and "  " or ""
			local localized = managers.localization:to_upper_text(text_id, {
				next = next_level - managers.crime_spree:server_spree_level()
			})
			upcoming_modifiers_text = upcoming_modifiers_text .. padding .. localized
		end
	end

	return upcoming_modifiers_text
end

function CrimeSpreeModifierDetailsPage:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))

	return x, y, w, h
end

function CrimeSpreeModifierDetailsPage:mouse_wheel_up(x, y)
	self._scroll:scroll(x, y, 1)
end

function CrimeSpreeModifierDetailsPage:mouse_wheel_down(x, y)
	self._scroll:scroll(x, y, -1)
end

function CrimeSpreeModifierDetailsPage:update(t, dt)
	if not managers.menu:is_pc_controller() and self._gui and self._gui._right_axis_vector and not mvector3.is_zero(self._gui._right_axis_vector) then
		local x = mvector3.x(self._gui._right_axis_vector)
		local y = mvector3.y(self._gui._right_axis_vector)

		self._scroll:perform_scroll(ScrollablePanel.SCROLL_SPEED * dt * 24, y)
	end

	if self._cached_server_level ~= managers.crime_spree:server_spree_level() then
		self._next_text:set_text(self:upcoming_modifiers_text())

		self._cached_server_level = managers.crime_spree:server_spree_level()
	end
end

function CrimeSpreeModifierDetailsPage:add_modifiers_panel(parent, modifiers, is_tab)
	modifiers = modifiers or managers.crime_spree:server_active_modifiers()
	local left_scroll, ignore_up_indicator, extra_padding_right = nil

	if is_tab then
		left_scroll = true
		ignore_up_indicator = true
		extra_padding_right = 0
	else
		left_scroll = false
		ignore_up_indicator = false
		extra_padding_right = padding
	end

	local max_level = (modifiers[#modifiers] or {}).level or 0
	local max_level_text = parent:text({
		vertical = "top",
		halign = "right",
		align = "right",
		valign = "top",
		text = managers.localization:get_default_macro("BTN_SPREE_STEALTH") .. managers.experience:cash_string(max_level, ""),
		color = Color.white,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})
	local _, _, level_w, _ = max_level_text:text_rect()
	level_w = level_w + padding

	parent:remove(max_level_text)

	local params = {
		force_scroll_indicators = true,
		padding = 0,
		layer = 1,
		left_scrollbar = left_scroll,
		ignore_up_indicator = ignore_up_indicator
	}
	self._scroll = ScrollablePanel:new(parent, "modifiers_scroll", params)
	local modifiers_count = {}
	local count = 0
	local next_y = 0

	for i = #modifiers, 1, -1 do
		local modifier_data = modifiers[i]
		local modifier = managers.crime_spree:get_modifier(modifier_data.id)

		if modifier then
			local modifier_class = _G[modifier.class] or {}
			local panel = self._scroll:canvas():panel({
				w = self._scroll:canvas():w(),
				y = next_y
			})
			modifiers_count[modifier.class] = (modifiers_count[modifier.class] or 0) + 1
			local desc = panel:text({
				halign = "left",
				vertical = "top",
				wrap = true,
				align = "left",
				layer = 1,
				alpha = 0.8,
				y = 5,
				word_wrap = true,
				valign = "top",
				text = managers.crime_spree:make_modifier_description(modifier_data.id, modifiers_count[modifier.class] == 1),
				x = padding * 1.5 + level_w,
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				w = panel:w() - level_w - padding * 2 - extra_padding_right,
				h = tweak_data.menu.pd2_small_font_size,
				color = Color.white
			})
			local level = panel:text({
				halign = "right",
				vertical = "top",
				align = "right",
				layer = 1,
				y = 2,
				valign = "top",
				text = managers.experience:cash_string(modifier_data.level, ""),
				x = padding,
				color = Color.white,
				font = tweak_data.menu.pd2_medium_font,
				font_size = tweak_data.menu.pd2_medium_font_size,
				w = level_w - padding * 0.5,
				h = tweak_data.menu.pd2_medium_font_size
			})

			if modifier_class.stealth then
				level:set_text(managers.localization:get_default_macro("BTN_SPREE_STEALTH") .. level:text())
			end

			local _, _, dw, dh = desc:text_rect()

			desc:set_h(dh)
			panel:set_h(dh + desc:y() * 2)
			panel:rect({
				color = Color.black,
				alpha = count % 2 == 1 and 0.4 or 0
			})

			next_y = panel:bottom()
			count = count + 1
		end
	end

	self._scroll:update_canvas_size()

	return next_y
end
