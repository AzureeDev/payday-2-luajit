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
HUDStatsScreenSkirmish = HUDStatsScreenSkirmish or class(HUDStatsScreen)

function HUDStatsScreenSkirmish:recreate_left()
	self._left:clear()
	self._left:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "grow",
		w = self._left:w(),
		h = self._left:h()
	})

	local lb = HUDBGBox_create(self._left, {}, {
		blend_mode = "normal",
		color = Color.white
	})

	lb:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
	lb:child("bg"):set_alpha(1)

	local placer = UiPlacer:new(10, 10, 0, 8)
	local job_data = managers.job:current_job_data()
	local title_text_id = managers.skirmish:is_weekly_skirmish() and "hud_weekly_skirmish" or "hud_skirmish"
	local skirmish_title = placer:add_bottom(self._left:fine_text({
		text = managers.localization:to_upper_text(title_text_id),
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.loot_size
	}))

	placer:new_row(8)

	local level_data = managers.job:current_level_data()

	if level_data then
		placer:add_bottom(self._left:fine_text({
			text = managers.localization:to_upper_text(level_data.name_id),
			font = large_font,
			font_size = tweak_data.hud_stats.objectives_title_size
		}))
		placer:new_row()
	end

	local objectives_title = self._left:fine_text({
		vertical = "top",
		align = "left",
		font_size = tweak_data.hud_stats.objectives_title_size,
		font = tweak_data.hud_stats.objectives_font,
		text = managers.localization:to_upper_text("hud_objective")
	})

	placer:add_bottom(objectives_title, 16)
	placer:new_row(8)

	local row_w = self._left:w() - placer:current_left() * 2

	for i, data in pairs(managers.objectives:get_active_objectives()) do
		placer:add_bottom(self._left:fine_text({
			word_wrap = true,
			wrap = true,
			align = "left",
			text = utf8.to_upper(data.text),
			font = tweak_data.hud.medium_font,
			font_size = tweak_data.hud.active_objective_title_font_size,
			w = row_w
		}))
		placer:add_bottom(self._left:fine_text({
			word_wrap = true,
			wrap = true,
			font_size = 24,
			align = "left",
			text = data.description,
			font = tweak_data.hud_stats.objective_desc_font,
			w = row_w
		}), 0)
	end

	local loot_panel = ExtendedPanel:new(self._left, {
		w = self._left:w() - 16 - 8
	})
	placer = UiPlacer:new(16, 0, 8, 4)

	if managers.player:has_category_upgrade("player", "convert_enemies") then
		local minion_text = placer:add_bottom(loot_panel:fine_text({
			keep_w = true,
			text = managers.localization:text("hud_stats_enemies_converted"),
			font = medium_font,
			font_size = medium_font_size
		}))

		placer:add_right(nil, 0)

		local minion_texture, minion_rect = tweak_data.hud_icons:get_icon_data("minions_converted")
		local minion_icon = placer:add_left(loot_panel:fit_bitmap({
			w = 17,
			h = 17,
			texture = minion_texture,
			texture_rect = minion_rect
		}))

		minion_icon:set_center_y(minion_text:center_y())
		placer:add_left(loot_panel:fine_text({
			text = tostring(managers.player:num_local_minions()),
			font = medium_font,
			font_size = medium_font_size
		}), 7)
		placer:new_row()
	end

	placer:add_bottom(loot_panel:fine_text({
		keep_w = true,
		text = managers.localization:to_upper_text("hud_skirmish_ransom"),
		font = medium_font,
		font_size = medium_font_size
	}))

	local ransom_amount = managers.skirmish:current_ransom_amount()

	placer:add_right(nil, 0)
	placer:add_left(loot_panel:fine_text({
		text = managers.experience:cash_string(ransom_amount),
		font = medium_font,
		font_size = medium_font_size
	}))
	loot_panel:set_size(placer:most_rightbottom())
	loot_panel:set_leftbottom(0, self._left:h() - 16)
end
