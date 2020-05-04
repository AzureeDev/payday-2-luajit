CrimeSpreeRewardsDetailsPage = CrimeSpreeRewardsDetailsPage or class(CrimeSpreeDetailsPage)
local padding = 10

function CrimeSpreeRewardsDetailsPage:init(...)
	CrimeSpreeRewardsDetailsPage.super.init(self, ...)
	self:panel():bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		halign = "scale",
		alpha = 1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = self:panel():w(),
		h = self:panel():h()
	})
	self:panel():rect({
		alpha = 0.5,
		valign = "scale",
		halign = "scale",
		color = Color.black
	})

	local outline_panel = self:panel():panel({})

	BoxGuiObject:new(outline_panel, {
		sides = {
			4,
			4,
			2,
			1
		}
	})

	local w = (self:panel():w() - padding) / #tweak_data.crime_spree.rewards
	local count = 0

	for i, data in ipairs(tweak_data.crime_spree.rewards) do
		local amount = math.max(math.floor(data.amount * managers.crime_spree:reward_level()), 0)

		if amount > 0 or data.always_show then
			local panel = self:panel():panel({
				w = w,
				x = count * w
			})
			local card_layer = 50
			local num_cards = math.clamp(math.floor(amount / (data.card_inc or 1)), 1, data.max_cards)
			local upcard = self:create_card(panel, data.icon, card_layer, 10, 0, num_cards > 1)

			for i = 1, num_cards - 1 do
				self:create_card(panel, data.icon, card_layer - i * 2, 10, 6, true)
			end

			local reward_name = panel:text({
				vertical = "center",
				h = 32,
				wrap = true,
				align = "center",
				word_wrap = true,
				blend_mode = "add",
				layer = 11,
				name = "reward" .. tostring(i),
				text = managers.localization:to_upper_text(data.name_id or ""),
				w = panel:w(),
				font_size = tweak_data.menu.pd2_small_font_size * 0.8,
				font = tweak_data.menu.pd2_small_font,
				color = Color.white:with_alpha(0.4)
			})

			reward_name:set_top(upcard:bottom() + padding * 2)

			local x, y, w, h = reward_name:text_rect()

			reward_name:set_h(h)

			local reward_amount = panel:text({
				vertical = "center",
				h = 32,
				wrap = true,
				align = "center",
				word_wrap = true,
				blend_mode = "add",
				layer = 11,
				name = "reward" .. tostring(i),
				text = managers.experience:cash_string(amount, data.cash_string or ""),
				w = panel:w(),
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				color = Color.white
			})

			reward_amount:set_top(reward_name:bottom())

			local x, y, w, h = reward_amount:text_rect()

			reward_amount:set_h(h)

			count = count + 1
		end
	end

	local warning_title, warning_text = nil

	if managers.crime_spree:server_spree_level() < managers.crime_spree:spree_level() then
		warning_title = "menu_cs_rewards_suspended"
		warning_text = "menu_cs_rewards_suspended_desc"
	elseif not managers.crime_spree:in_progress() then
		warning_title = "menu_cs_rewards_not_in_progress"
		warning_text = "menu_cs_rewards_not_in_progress_desc"
	elseif managers.crime_spree:has_failed() then
		warning_title = "menu_cs_rewards_has_failed"
		warning_text = "menu_cs_rewards_has_failed_desc"
	end

	if warning_title then
		local level_layer = 50
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
		level_panel:rect({
			alpha = 0.75,
			color = Color.black
		})
		outline_panel:set_layer(level_layer + 10)
	end
end

function CrimeSpreeRewardsDetailsPage:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))

	return x, y, w, h
end

function CrimeSpreeRewardsDetailsPage:create_card(panel, icon, layer, rotation_amt, wiggle_amt, outline)
	local rotation = math.rand(-rotation_amt, rotation_amt)
	local wiggle_x = math.rand(-wiggle_amt, wiggle_amt)
	local wiggle_y = math.rand(-wiggle_amt, wiggle_amt)
	local scale = 0.35
	local upcard = self:_create_card(panel, icon, scale, layer, rotation, wiggle_x, wiggle_y)

	if outline then
		local outline_card = nil
		local color = Color.black:with_alpha(0.4)
		outline_card = self:_create_card(panel, icon, scale, layer - 1, rotation, wiggle_x + 1, wiggle_y + 1)

		outline_card:set_color(color)

		outline_card = self:_create_card(panel, icon, scale, layer - 1, rotation, wiggle_x - 1, wiggle_y - 1)

		outline_card:set_color(color)
	end

	return upcard
end

function CrimeSpreeRewardsDetailsPage:_create_card(panel, icon, scale, layer, rotation, wiggle_x, wiggle_y)
	local texture, rect, coords = tweak_data.hud_icons:get_icon_data(icon or "downcard_overkill_deck")
	local upcard = panel:bitmap({
		name = "upcard",
		halign = "scale",
		valign = "scale",
		texture = texture,
		w = math.round(0.7111111111111111 * panel:h() * scale),
		h = panel:h() * scale,
		layer = layer or 20
	})

	upcard:set_center_x(panel:w() * 0.5 + wiggle_x)
	upcard:set_center_y(panel:h() * 0.3 + wiggle_y)
	upcard:set_rotation(rotation)

	if coords then
		local tl = Vector3(coords[1][1], coords[1][2], 0)
		local tr = Vector3(coords[2][1], coords[2][2], 0)
		local bl = Vector3(coords[3][1], coords[3][2], 0)
		local br = Vector3(coords[4][1], coords[4][2], 0)

		upcard:set_texture_coordinates(tl, tr, bl, br)
	else
		upcard:set_texture_rect(unpack(rect))
	end

	return upcard
end
