CrimeSpreeDetailsMenuComponent = CrimeSpreeDetailsMenuComponent or class(MenuGuiComponentGeneric)
local padding = 10
local button_size = {
	w = 164,
	h = 96
}
CrimeSpreeDetailsMenuComponent.disallowed_menus = {
	"kit_menu",
	"mission_end_menu"
}

function CrimeSpreeDetailsMenuComponent:init(...)
	CrimeSpreeDetailsMenuComponent.super.init(self, ...)
	self._fullscreen_panel:set_layer(tweak_data.gui.MENU_LAYER)

	if not managers.menu:is_pc_controller() then
		self:_setup_controller_input()
	end

	if self:_is_in_game() then
		managers.menu_component:set_max_lines_game_chat(tweak_data.crime_spree.gui.max_chat_lines.preplanning)
	end
end

function CrimeSpreeDetailsMenuComponent:_is_in_preplanning()
	return managers.menu:active_menu().id == "kit_menu"
end

function CrimeSpreeDetailsMenuComponent:_is_in_game()
	return table.contains(CrimeSpreeDetailsMenuComponent.disallowed_menus, managers.menu:active_menu().id)
end

function CrimeSpreeDetailsMenuComponent:_setup(is_start_page, component_data)
	component_data = self:_start_page_data()

	CrimeSpreeDetailsMenuComponent.super._setup(self, is_start_page, component_data)

	self._safe_panel = self._ws:panel():panel({
		layer = self._init_layer
	})
	local is_host = Network:is_server() or Global.game_settings.single_player

	if not is_host and managers.crime_spree:in_progress() then
		self:_add_page_subtitle()

		if not self:_is_in_game() then
			self._page_panel:move(0, padding)
			self._tabs_panel:move(0, padding)
		end
	end
end

function CrimeSpreeDetailsMenuComponent:close()
	if alive(self._modifier_panel) then
		self._fullscreen_panel:remove(self._modifier_panel)

		self._modifier_panel = nil
	end

	self._ws:panel():remove(self._safe_panel)
	CrimeSpreeDetailsMenuComponent.super.close(self)
end

function CrimeSpreeDetailsMenuComponent:_start_page_data()
	local data = {}
	local topic_id = "cn_crime_spree_level"
	local topic_params = {
		level = managers.experience:cash_string(tonumber(managers.crime_spree:server_spree_level() or 0), "")
	}

	if not managers.crime_spree:in_progress() then
		topic_id = "cn_crime_spree"
	end

	data.topic_id = topic_id
	data.topic_params = topic_params
	data.topic_range_color = {
		from = utf8.len(managers.localization:text("cn_crime_spree_level_no_num")),
		to = utf8.len(managers.localization:text(data.topic_id, data.topic_params)),
		color = tweak_data.screen_colors.crime_spree_risk
	}
	data.subtopic_id = "cn_crime_spree_my_level"
	data.subtopic_params = {
		level = managers.experience:cash_string(managers.crime_spree:spree_level(), "")
	}
	data.subtopic_range_color = {
		from = utf8.len(managers.localization:text("cn_crime_spree_my_level_no_num")),
		to = utf8.len(managers.localization:text(data.subtopic_id, data.subtopic_params)),
		color = tweak_data.screen_colors.crime_spree_risk
	}
	data.no_back_button = true
	data.no_blur_background = true
	data.outline_data = {
		layer = 100,
		sides = {
			3,
			3,
			2,
			0
		}
	}

	return data
end

function CrimeSpreeDetailsMenuComponent:update(t, dt)
	CrimeSpreeDetailsMenuComponent.super.update(self, t, dt)

	if alive(self._right_title_text) then
		self._right_title_text:set_visible(true)
	end
end

function CrimeSpreeDetailsMenuComponent:_add_page_right_title()
	if alive(self._safe_panel:child("title_right_text")) then
		self._safe_panel:remove(self._safe_panel:child("title_right_text"))
	end

	self._right_title_text = self._safe_panel:text({
		name = "title_right_text",
		text = self._data.right_topic_id and managers.localization:to_upper_text(self._data.right_topic_id, self._data.right_topic_params) or "",
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text,
		layer = self._init_layer + 10
	})

	self:make_fine_text(self._right_title_text)
	self._right_title_text:set_world_right(self._safe_panel:world_right())

	if self._data.right_topic_range_color then
		self._right_title_text:set_range_color(self._data.right_topic_range_color.from, self._data.right_topic_range_color.to, self._data.right_topic_range_color.color)
	end

	if MenuBackdropGUI then
		if alive(self._fullscreen_panel:child("title_right_text_bg")) then
			self._fullscreen_panel:remove(self._fullscreen_panel:child("title_right_text_bg"))
		end

		local bg_text = self._fullscreen_panel:text({
			name = "title_right_text_bg",
			vertical = "top",
			h = 90,
			alpha = 0.4,
			align = "right",
			text = self._right_title_text:text(),
			font_size = tweak_data.menu.pd2_massive_font_size,
			font = tweak_data.menu.pd2_massive_font,
			color = tweak_data.screen_colors.button_stage_3
		})
		local x, y = managers.gui_data:safe_to_full_16_9(self._right_title_text:world_right(), self._right_title_text:world_center_y())

		bg_text:set_world_right(x)
		bg_text:set_world_center_y(y)
		bg_text:move(13, 9)
		MenuBackdropGUI.animate_bg_text(self, bg_text)
	end
end

function CrimeSpreeDetailsMenuComponent:_add_page_subtitle()
	if alive(self._safe_panel:child("subtitle_text")) then
		self._safe_panel:remove(self._safe_panel:child("subtitle_text"))
	end

	if self._data.subtopic_id then
		self._subtitle_text = self._safe_panel:text({
			name = "subtitle_text",
			text = managers.localization:to_upper_text(self._data.subtopic_id, self._data.subtopic_params),
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			color = tweak_data.screen_colors.text,
			layer = self._init_layer + 10
		})

		self:make_fine_text(self._subtitle_text)

		if self._data.subtopic_range_color then
			self._subtitle_text:set_range_color(self._data.subtopic_range_color.from, self._data.subtopic_range_color.to, self._data.subtopic_range_color.color)
		end

		self._subtitle_text:set_top(self._title_text:bottom() - padding)
	end
end

function CrimeSpreeDetailsMenuComponent:_setup_panel_size()
	local w = 0.5

	if self:_is_in_game() then
		w = 0.49
	end

	self._panel:set_w(self._ws:panel():w() * w)
	self._panel:set_h(self._ws:panel():h() * w)
end

function CrimeSpreeDetailsMenuComponent:populate_tabs_data(tabs_data)
	table.insert(tabs_data, {
		name_id = "menu_cs_modifiers",
		width_multiplier = 1,
		page_class = "CrimeSpreeModifierDetailsPage"
	})

	if not self:_is_in_preplanning() then
		table.insert(tabs_data, {
			name_id = "menu_cs_rewards",
			width_multiplier = 1,
			page_class = "CrimeSpreeRewardsDetailsPage"
		})
	end
end

function CrimeSpreeDetailsMenuComponent:input_focus()
end

function CrimeSpreeDetailsMenuComponent:_setup_controller_input()
	self._left_axis_vector = Vector3()
	self._right_axis_vector = Vector3()

	self._ws:connect_controller(managers.menu:active_menu().input:get_controller(), true)
	self._panel:axis_move(callback(self, self, "_axis_move"))
end

function CrimeSpreeDetailsMenuComponent:_destroy_controller_input()
	self._ws:disconnect_all_controllers()

	if alive(self._panel) then
		self._panel:axis_move(nil)
	end
end

function CrimeSpreeDetailsMenuComponent:_axis_move(o, axis_name, axis_vector, controller)
	if axis_name == Idstring("left") then
		mvector3.set(self._left_axis_vector, axis_vector)
	elseif axis_name == Idstring("right") then
		mvector3.set(self._right_axis_vector, axis_vector)
	end
end

function CrimeSpreeDetailsMenuComponent:perform_update()
	local is_host = Network:is_server() or Global.game_settings.single_player
	self._data = self:_start_page_data()

	self:_add_page_title()
	self:_add_page_right_title()

	if not is_host and managers.crime_spree:in_progress() then
		self:_add_page_subtitle()
	end

	for _, data in ipairs(self._tabs) do
		data.page:perform_update()
	end
end

function CrimeSpreeDetailsMenuComponent:show_new_modifier(modifier_id)
	local modifier = managers.crime_spree:get_modifier(modifier_id)
	local modifier_class = _G[modifier.class] or {}

	if alive(self._modifier_panel) then
		self._fullscreen_panel:remove(self._modifier_panel)

		self._modifier_panel = nil
	end

	self._modifier_panel = self._fullscreen_panel:panel({
		w = 300,
		alpha = 0,
		h = 130,
		layer = tweak_data.gui.CRIMENET_CHAT_LAYER + 100
	})

	self._modifier_panel:set_center_x(self._fullscreen_panel:w() * 0.5)
	self._modifier_panel:set_center_y(self._fullscreen_panel:h() * 0.75)
	self._modifier_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		halign = "scale",
		alpha = 1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = self._modifier_panel:w(),
		h = self._modifier_panel:h()
	})
	self._modifier_panel:rect({
		alpha = 0.8,
		valign = "scale",
		halign = "scale",
		color = Color.black
	})
	BoxGuiObject:new(self._modifier_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local title = self._modifier_panel:text({
		name = "title",
		layer = 10,
		text = managers.localization:to_upper_text(modifier_class.stealth and "menu_cs_new_modifier_stealth" or "menu_cs_new_modifier_loud"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text,
		x = padding,
		y = padding
	})

	self:make_fine_text(title)

	local texture, rect = tweak_data.hud_icons:get_icon_data(modifier.icon)
	local image = self._modifier_panel:bitmap({
		name = "icon",
		h = 80,
		valign = "grow",
		w = 80,
		layer = 10,
		blend_mode = "add",
		halign = "grow",
		texture = texture,
		texture_rect = rect
	})

	image:set_bottom(self._modifier_panel:h() - padding)
	image:set_left(padding)

	local desc = self._modifier_panel:text({
		name = "desc",
		word_wrap = true,
		wrap = true,
		layer = 10,
		text = managers.crime_spree:make_modifier_description(modifier_id),
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.text,
		w = self._modifier_panel:w() - padding * 3 - image:w()
	})

	self:make_fine_text(desc)
	desc:set_center_y(image:center_y())
	desc:set_left(image:right() + padding)
	self._modifier_panel:animate(callback(self, self, "animate_modifier"))
end

function CrimeSpreeDetailsMenuComponent:animate_modifier(o)
	managers.menu:post_event(tweak_data.crime_spree.announce_modifier_stinger)
	wait(0.5)
	self:fade_in_modifier(o)
	wait(3.25)
	self:fade_out_modifier(o)
end

function CrimeSpreeDetailsMenuComponent:fade_in_modifier(o)
	local start_y = o:y() - 40
	local end_y = o:y()

	over(0.25, function (p)
		o:set_alpha(math.lerp(0, 1, p))
		o:set_y(math.lerp(start_y, end_y, p))
	end)
end

function CrimeSpreeDetailsMenuComponent:fade_out_modifier(o)
	local start_y = o:y()
	local end_y = o:y() + 40

	over(0.25, function (p)
		o:set_alpha(math.lerp(1, 0, p))
		o:set_y(math.lerp(start_y, end_y, p))
	end)
end

CrimeSpreeDetailsPage = CrimeSpreeDetailsPage or class(CustomSafehouseGuiPage)

function CrimeSpreeDetailsPage:init(...)
	CrimeSpreeDetailsPage.super.init(self, ...)

	local w = self:info_panel():w() + padding + 3

	self:info_panel():grow(-w, 0)
	self:panel():grow(w, 0)
end

function CrimeSpreeDetailsPage:get_legend()
	return {}
end

function CrimeSpreeDetailsPage:perform_update()
end
