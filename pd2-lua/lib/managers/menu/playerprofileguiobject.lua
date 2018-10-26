PlayerProfileGuiObject = PlayerProfileGuiObject or class()

function PlayerProfileGuiObject:init(ws)
	local panel = ws:panel():panel()
	local next_level_data = managers.experience:next_level_data() or {}
	local max_left_len = 0
	local max_right_len = 0
	local font = tweak_data.menu.pd2_small_font
	local font_size = tweak_data.menu.pd2_small_font_size
	local bg_ring = panel:bitmap({
		texture = "guis/textures/pd2/level_ring_small",
		y = 10,
		alpha = 0.4,
		x = 10,
		w = font_size * 4,
		h = font_size * 4,
		color = Color.black
	})
	local exp_ring = panel:bitmap({
		texture = "guis/textures/pd2/level_ring_small",
		render_template = "VertexColorTexturedRadial",
		blend_mode = "add",
		y = 10,
		x = 10,
		layer = 1,
		w = font_size * 4,
		h = font_size * 4,
		color = Color((next_level_data.current_points or 1) / (next_level_data.points or 1), 1, 1)
	})
	local player_level = managers.experience:current_level()
	local player_rank = managers.experience:current_rank()
	local is_infamous = player_rank > 0
	local level_string = (is_infamous and managers.experience:rank_string(player_rank) .. "-" or "") .. tostring(player_level)
	local level_text = panel:text({
		vertical = "center",
		align = "center",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size + (is_infamous and -5 or 0),
		text = level_string,
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(level_text)
	level_text:set_font_size(level_text:font_size() * math.min((font_size * 2) / level_text:w(), 1))
	level_text:set_center(exp_ring:center())

	max_left_len = math.max(max_left_len, level_text:w())
	local player_text = panel:text({
		y = 10,
		font = font,
		font_size = font_size,
		text = tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name()),
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(player_text)
	player_text:set_left(math.round(exp_ring:right()))

	max_left_len = math.max(max_left_len, player_text:w())
	local money_text = panel:text({
		text = self:get_text("menu_cash", {money = managers.money:total_string()}),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(money_text)
	money_text:set_left(math.round(exp_ring:right()))
	money_text:set_top(math.round(player_text:bottom()))

	max_left_len = math.max(max_left_len, money_text:w())
	local total_money_text = panel:text({
		text = self:get_text("hud_offshore_account") .. ": " .. managers.experience:cash_string(managers.money:offshore()),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(total_money_text)
	total_money_text:set_left(math.round(exp_ring:right()))
	total_money_text:set_top(math.round(money_text:bottom()))

	max_left_len = math.max(max_left_len, total_money_text:w())
	local skillpoints = managers.skilltree:points()
	local skill_text, skill_glow = nil

	if skillpoints > 0 then
		skill_text = panel:text({
			layer = 1,
			text = self:get_text("menu_spendable_skill_points", {points = tostring(skillpoints)}),
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})

		self:_make_fine_text(skill_text)
		skill_text:set_left(math.round(exp_ring:right()))
		skill_text:set_top(math.round(total_money_text:bottom()))

		max_left_len = math.max(max_left_len, skill_text:w())
		local skill_icon = panel:bitmap({
			w = 16,
			texture = "guis/textures/pd2/shared_skillpoint_symbol",
			h = 16,
			layer = 1
		})

		skill_icon:set_right(skill_text:left())
		skill_icon:set_center_y(skill_text:center_y() + 1)

		skill_glow = panel:bitmap({
			texture = "guis/textures/pd2/crimenet_marker_glow",
			blend_mode = "add",
			layer = 0,
			w = panel:w(),
			h = skill_text:h() * 2,
			color = tweak_data.screen_colors.button_stage_3
		})

		skill_glow:set_center_y(skill_icon:center_y())
	end

	local font_scale = 1
	local mastermind_ponts, num_skills = managers.skilltree:get_tree_progress_2("mastermind")
	mastermind_ponts = string.format("%02d", mastermind_ponts)
	local mastermind_text = panel:text({
		y = 10,
		text = self:get_text("menu_profession_progress", {
			profession = self:get_text("st_menu_mastermind"),
			progress = mastermind_ponts,
			num_skills = num_skills
		}),
		font_size = font_size * font_scale,
		font = font,
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(mastermind_text)

	max_right_len = math.max(max_right_len, mastermind_text:w())
	local enforcer_ponts, num_skills = managers.skilltree:get_tree_progress_2("enforcer")
	enforcer_ponts = string.format("%02d", enforcer_ponts)
	local enforcer_text = panel:text({
		text = self:get_text("menu_profession_progress", {
			profession = self:get_text("st_menu_enforcer"),
			progress = enforcer_ponts,
			num_skills = num_skills
		}),
		font_size = font_size * font_scale,
		font = font,
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(enforcer_text)
	enforcer_text:set_top(math.round(mastermind_text:bottom()))

	max_right_len = math.max(max_right_len, enforcer_text:w())
	local technician_ponts, num_skills = managers.skilltree:get_tree_progress_2("technician")
	technician_ponts = string.format("%02d", technician_ponts)
	local technician_text = panel:text({
		text = self:get_text("menu_profession_progress", {
			profession = self:get_text("st_menu_technician"),
			progress = technician_ponts,
			num_skills = num_skills
		}),
		font_size = font_size * font_scale,
		font = font,
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(technician_text)
	technician_text:set_top(math.round(enforcer_text:bottom()))

	max_right_len = math.max(max_right_len, technician_text:w())
	local ghost_ponts, num_skills = managers.skilltree:get_tree_progress_2("ghost")
	ghost_ponts = string.format("%02d", ghost_ponts)
	local ghost_text = panel:text({
		text = self:get_text("menu_profession_progress", {
			profession = self:get_text("st_menu_ghost"),
			progress = ghost_ponts,
			num_skills = num_skills
		}),
		font_size = font_size * font_scale,
		font = font,
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(ghost_text)
	ghost_text:set_top(math.round(technician_text:bottom()))

	max_right_len = math.max(max_right_len, ghost_text:w())
	local hoxton_ponts, num_skills = managers.skilltree:get_tree_progress_2("hoxton")
	hoxton_ponts = string.format("%02d", hoxton_ponts)
	local hoxton_text = panel:text({
		text = self:get_text("menu_profession_progress", {
			profession = self:get_text("st_menu_hoxton_pack"),
			progress = hoxton_ponts,
			num_skills = num_skills
		}),
		font_size = font_size * font_scale,
		font = font,
		color = tweak_data.screen_colors.text
	})

	self:_make_fine_text(hoxton_text)
	hoxton_text:set_top(math.round(ghost_text:bottom()))

	max_right_len = math.max(max_right_len, hoxton_text:w())
	self._panel = panel

	self._panel:set_size(exp_ring:w() + max_left_len + 15 + max_right_len + 10, math.max(skill_text and skill_text:bottom() or total_money_text:bottom(), hoxton_text:bottom()) + 8)
	self._panel:set_bottom(self._panel:parent():h() - 60)
	BoxGuiObject:new(self._panel, {sides = {
		1,
		1,
		1,
		1
	}})
	mastermind_text:set_right(self._panel:w() - 10)
	enforcer_text:set_right(self._panel:w() - 10)
	technician_text:set_right(self._panel:w() - 10)
	ghost_text:set_right(self._panel:w() - 10)
	hoxton_text:set_right(self._panel:w() - 10)
	bg_ring:move(-5, 0)
	exp_ring:move(-5, 0)
	level_text:set_center(exp_ring:center())

	if skill_glow then

		local function animate_new_skillpoints(o)
			while true do
				over(1, function (p)
					o:set_alpha(math.lerp(0.4, 0.85, math.sin(p * 180)))
				end)
			end
		end

		skill_glow:set_w(self._panel:w())
		skill_glow:set_center_x(skill_text and skill_text:center_x() or 0)
		skill_glow:animate(animate_new_skillpoints)
	end

	self:_rec_round_object(panel)
end

function PlayerProfileGuiObject:_rec_round_object(object)
	local x, y, w, h = object:shape()

	object:set_shape(math.round(x), math.round(y), math.round(w), math.round(h))

	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end
end

function PlayerProfileGuiObject:get_text(text, macros)
	return utf8.to_upper(managers.localization:text(text, macros))
end

function PlayerProfileGuiObject:_make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function PlayerProfileGuiObject:close()
	if self._panel and alive(self._panel) then
		self._panel:parent():remove(self._panel)

		self._panel = nil
	end
end

