CrimeNetSidebarGui = CrimeNetSidebarGui or class(MenuGuiComponent)
local padding = 10

function CrimeNetSidebarGui:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._node = node
	self.make_fine_text = BlackMarketGui.make_fine_text
	self._rec_round_object = NewSkillTreeGui._rec_round_object
	self._buttons = {}
	self._buttons_map = {}
	self._collapsed = false

	self:_setup()
end

function CrimeNetSidebarGui:close()
	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end

	if alive(self._ws_panel) then
		self._ws:panel():remove(self._ws_panel)
	end

	if alive(self._fullscreen_panel) then
		self._fullscreen_ws:panel():remove(self._fullscreen_panel)
	end

	self:_update_crimenet_elements()
end

function CrimeNetSidebarGui:_setup()
	self._panel = self._ws:panel():panel({
		w = 256,
		layer = 100
	})
	self._ws_panel = self._ws:panel():panel({
		layer = 100,
		w = self._ws:panel():w() - self._panel:w() - padding,
		x = self._panel:w() + padding
	})
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		layer = 100,
		name = "fullscreen"
	})
	self._icons_panel = self._panel:panel({
		w = padding + 24 + 5
	})
	self._bg_panel = self._panel:panel({
		layer = -1
	})

	self._bg_panel:rect({
		alpha = 0.4,
		color = Color.black
	})
	self._bg_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur_bg",
		halign = "scale",
		layer = -1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = self._bg_panel:w(),
		h = self._bg_panel:h()
	})

	local next_position = padding
	local item_margin = 2

	for i, item in ipairs(tweak_data.gui.crime_net.sidebar) do
		local visible = true

		if item.visible_callback then
			visible = self[item.visible_callback](self)
		end

		if visible then
			local item_class = CrimeNetSidebarItem

			if item.item_class then
				item_class = _G[item.item_class]

				if not item_class then
					Application:error("No class exists for sidebar item: ", item.item_class)

					item_class = CrimeNetSidebarItem
				end
			end

			local btn = item_class:new(self, self._panel, {
				position = next_position,
				name_id = item.name_id,
				btn_macro = item.btn_macro,
				show_name_while_collapsed = item.show_name_while_collapsed,
				icon = item.icon,
				callback = item.callback and callback(self, self, item.callback)
			})
			next_position = next_position + btn:panel():height() + item_margin

			table.insert(self._buttons, btn)

			if item.id then
				self._buttons_map[item.id] = btn
			end
		end
	end

	self._box_guis = {
		collapsed = {
			BoxGuiObject:new(self._panel:panel({
				layer = 100
			}), {
				sides = {
					1,
					0,
					3,
					3
				}
			}),
			BoxGuiObject:new(self._ws_panel:panel({
				layer = 100
			}), {
				sides = {
					0,
					1,
					4,
					4
				}
			})
		},
		expanded = {
			BoxGuiObject:new(self._panel:panel({
				layer = 100
			}), {
				sides = {
					1,
					1,
					1,
					1
				}
			}),
			BoxGuiObject:new(self._ws_panel:panel({
				layer = 100
			}), {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		}
	}

	self:set_collapsed(managers.crimenet:sidebar_collapsed())
end

function CrimeNetSidebarGui:get_button(id)
	return self._buttons_map[id]
end

function CrimeNetSidebarGui:set_collapsed(collapsed)
	self._collapsed = collapsed

	managers.crimenet:set_sidebar_collapsed(collapsed)
	self._bg_panel:set_visible(not collapsed)

	for i, btn in ipairs(self._buttons) do
		btn:set_collapsed(collapsed)
	end

	local box_guis = self._box_guis[collapsed and "collapsed" or "expanded"]

	for _, gui in ipairs(box_guis) do
		gui:set_visible(true)
	end

	local box_guis = self._box_guis[not collapsed and "collapsed" or "expanded"]

	for _, gui in ipairs(box_guis) do
		gui:set_visible(false)
	end

	self:_update_crimenet_elements()
end

function CrimeNetSidebarGui:_update_crimenet_elements()
	local crimenet = managers.menu_component._crimenet_gui

	if not crimenet then
		return
	end

	local x, _x = nil

	if alive(self._panel) then
		if self:collapsed() then
			x = self._icons_panel:w() + padding
			_x = padding
		else
			x = self._panel:w() + padding * 2
			_x = x
		end
	else
		x = padding
		_x = x
	end

	crimenet:set_players_online_pos(x, nil)
	WalletGuiObject.set_wallet_pos(_x, nil)
end

function CrimeNetSidebarGui:collapsed()
	return self._collapsed
end

function CrimeNetSidebarGui:mouse_moved(o, x, y)
	local used, pointer = nil

	for _, btn in ipairs(self._buttons) do
		if btn:accepts_interaction() then
			if not used and btn:inside(x, y) then
				btn:set_highlight(true)

				pointer = "link"
				used = true
			else
				btn:set_highlight(false)
			end
		end
	end

	return used, pointer
end

function CrimeNetSidebarGui:special_btn_pressed(button)
	if button == Idstring("menu_preview_achievement") then
		return self:confirm_pressed()
	end
end

function CrimeNetSidebarGui:mouse_pressed(button, x, y)
	for _, btn in ipairs(self._buttons) do
		if btn:accepts_interaction() and btn:inside(x, y) and btn:callback() then
			btn:callback()()

			return true
		end
	end
end

function CrimeNetSidebarGui:confirm_pressed()
	local x, y = managers.mouse_pointer:modified_mouse_pos()

	for _, btn in ipairs(self._buttons) do
		if btn:accepts_interaction() and btn:inside(x, y) and btn:callback() then
			btn:callback()()

			return true
		end
	end
end

function CrimeNetSidebarGui:back_pressed()
	managers.menu:force_back(false, true)

	return true
end

function CrimeNetSidebarGui:update(t, dt)
	for _, btn in ipairs(self._buttons) do
		btn:update(t, dt)
	end

	if not managers.menu:is_pc_controller() and managers.mouse_pointer:mouse_move_x() == 0 and managers.mouse_pointer:mouse_move_y() == 0 then
		local closest_btn = nil
		local closest_dist = 100000000
		local closest_x = 0
		local closest_y = 0
		local mx, my = managers.mouse_pointer:modified_mouse_pos()

		if (self:collapsed() and self._icons_panel or self._panel):inside(mx, my) then
			for _, btn in ipairs(self._buttons) do
				if btn:accepts_interaction() then
					local btn_y = btn:panel():center_y()
					local y = btn_y - my
					local dist = y * y

					if closest_dist > dist then
						closest_btn = btn
						closest_dist = dist
						closest_y = btn_y
					end
				end
			end

			if closest_btn then
				closest_dist = math.sqrt(closest_dist)

				if closest_dist < tweak_data.gui.crime_net.controller.snap_distance then
					managers.mouse_pointer:force_move_mouse_pointer(0, math.lerp(my, closest_y, dt * tweak_data.gui.crime_net.controller.snap_speed) - my)
				end
			end
		end
	end
end

function CrimeNetSidebarGui:input_focus()
	local mouse_pos_x, mouse_pos_y = managers.mouse_pointer:modified_mouse_pos()

	if self:collapsed() then
		return self._icons_panel:inside(mouse_pos_x, mouse_pos_y)
	else
		return self._panel:inside(mouse_pos_x, mouse_pos_y)
	end
end

function CrimeNetSidebarGui:clbk_toggle_sidebar()
	self:set_collapsed(not self:collapsed())
	managers.menu:post_event("menu_enter")
end

function CrimeNetSidebarGui:clbk_crimenet_filters()
	if SystemInfo:platform() == Idstring("X360") then
		XboxLive:show_friends_ui(managers.user:get_platform_id())
	else
		managers.menu:open_node("crimenet_filters", {})
	end

	managers.menu:post_event("menu_enter")
end

function CrimeNetSidebarGui:clbk_the_basics()
	managers.menu:open_node("crimenet_contract_short")
end

function CrimeNetSidebarGui:clbk_safehouse()
	if managers.custom_safehouse:unlocked() then
		managers.menu:open_node("custom_safehouse")
	else
		MenuCallbackHandler:play_safehouse({})
	end
end

function CrimeNetSidebarGui:clbk_contract_broker()
	managers.menu:open_node("contract_broker")
end

function CrimeNetSidebarGui:clbk_side_jobs()
	managers.menu:open_node("side_jobs")
end

function CrimeNetSidebarGui:clbk_contact_database()
	managers.menu:open_node("crimenet_contact_info")
end

function CrimeNetSidebarGui:clbk_offshore_payday()
	managers.menu:open_node("crimenet_contract_casino")
end

function CrimeNetSidebarGui:clbk_gage_courier()
	managers.menu:open_node("crimenet_gage_assignment")
end

function CrimeNetSidebarGui:clbk_mutators()
	managers.menu:open_node("mutators")
end

function CrimeNetSidebarGui:clbk_crime_spree()
	CrimeSpreeMenuComponent:_open_crime_spree_contract()
end

function CrimeNetSidebarGui:clbk_visible_not_in_lobby()
	return not managers.network:session() or Global.game_settings.single_player
end

function CrimeNetSidebarGui:clbk_visible_crime_spree()
	return self:clbk_visible_not_in_lobby() and managers.crime_spree:unlocked()
end

function CrimeNetSidebarGui:clbk_visible_multiplayer()
	return not managers.network:session() and not Global.game_settings.single_player
end

function CrimeNetSidebarGui:clbk_visible_singleplayer()
	return Global.game_settings.single_player
end

function CrimeNetSidebarGui:clbk_open_story_missions()
	managers.menu:open_node("story_missions")
end

function CrimeNetSidebarGui:clbk_skirmish()
	SkirmishLandingMenuComponent:open_node()
end

function CrimeNetSidebarGui:clbk_visible_skirmish()
	return managers.skirmish:is_unlocked()
end

CrimeNetSidebarSeparator = CrimeNetSidebarSeparator or class()

function CrimeNetSidebarSeparator:init(sidebar, parent_panel, parameters)
	self._full_width = parent_panel:width() - padding * 2
	self._collapsed_width = 24
	self._panel = parent_panel:panel({
		h = 10,
		layer = 10,
		w = self._full_width,
		x = padding,
		y = parameters.position
	})
	local bitmap = self._panel:bitmap({
		texture = "guis/dlcs/sju/textures/pd2/crimenet_menu_dots_df",
		name = "separator",
		color = tweak_data.screen_colors.button_stage_3
	})

	bitmap:set_center_y(self._panel:height() * 0.5)
end

function CrimeNetSidebarSeparator:panel()
	return self._panel
end

function CrimeNetSidebarSeparator:set_collapsed(collapsed)
	self._panel:set_width(collapsed and self._collapsed_width or self._full_width)
end

function CrimeNetSidebarSeparator:accepts_interaction()
	return false
end

function CrimeNetSidebarSeparator:update(t, dt)
end

CrimeNetSidebarItem = CrimeNetSidebarItem or class()

function CrimeNetSidebarItem:init(sidebar, panel, parameters)
	local font_size = math.ceil(tweak_data.menu.pd2_small_font_size)
	local icon_size = 24
	local panel_size = math.max(font_size, icon_size)
	self._collapsed = false
	self._show_name_while_collapsed = parameters.show_name_while_collapsed
	self._callback = parameters.callback
	self._panel = panel:panel({
		halign = "scale",
		layer = 10,
		valign = "scale",
		w = panel:w() - padding * 2,
		h = panel_size,
		x = padding,
		y = parameters.position
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data(parameters.icon)
	self._icon = self._panel:bitmap({
		name = "icon",
		blend_mode = "normal",
		layer = 1,
		texture = texture,
		texture_rect = rect,
		w = icon_size,
		h = icon_size
	})
	self._text = self._panel:text({
		text = "",
		name = "title",
		valign = "scale",
		halign = "scale",
		blend_mode = "normal",
		y = 2,
		layer = 2,
		font = tweak_data.menu.pd2_medium_font,
		font_size = font_size,
		color = tweak_data.screen_colors.button_stage_3,
		x = icon_size + 4,
		h = font_size
	})
	local macros = {}

	if parameters.btn_macro then
		macros.btn = managers.localization:btn_macro(parameters.btn_macro)
	end

	self:set_text(managers.localization:text(parameters.name_id, macros))

	self._bg = self._panel:rect({
		blend_mode = "normal",
		layer = 1,
		halign = "scale",
		alpha = 0.66,
		valign = "scale",
		x = icon_size,
		color = Color.black
	})

	self:set_highlight(false, true)
end

function CrimeNetSidebarItem:accepts_interaction()
	return true
end

function CrimeNetSidebarItem:inside(x, y)
	if self._collapsed then
		return self._icon:inside(x, y)
	else
		return self._panel:inside(x, y)
	end
end

function CrimeNetSidebarItem:panel()
	return self._panel
end

function CrimeNetSidebarItem:icon()
	return self._icon
end

function CrimeNetSidebarItem:w()
	return self._text:right() + padding
end

function CrimeNetSidebarItem:callback()
	return self._callback
end

function CrimeNetSidebarItem:set_highlight(enabled, no_sound, force_update)
	if self._highlight ~= enabled or force_update then
		if self._collapsed then
			if self._show_name_while_collapsed == nil or self._show_name_while_collapsed then
				self._text:set_visible(enabled)
				self._bg:set_visible(enabled)
			else
				self._text:set_visible(false)
				self._bg:set_visible(false)
			end
		else
			self._text:set_visible(true)
			self._bg:set_visible(enabled)
		end

		self._text:set_color(enabled and self:highlight_color() or self:color())
		self._icon:set_color(enabled and self:highlight_color() or self:color())
		self._bg:set_color(Color.black)

		if not no_sound then
			managers.menu:post_event("highlight")
		end

		self._highlight = enabled
	end
end

function CrimeNetSidebarItem:set_collapsed(collapsed)
	self._collapsed = collapsed

	self._text:set_visible(not collapsed)
	self:set_highlight(self._highlight, true, true)
end

function CrimeNetSidebarItem:set_text(text)
	text = utf8.to_upper(text)
	text = text:gsub(" ", "_")

	self._text:set_text(text)
end

function CrimeNetSidebarItem:color()
	return self._color or tweak_data.screen_colors.button_stage_2
end

function CrimeNetSidebarItem:set_color(color)
	self._color = color

	self:set_highlight(self._highlight, true, true)
end

function CrimeNetSidebarItem:highlight_color()
	return self._highlight_color or Color.white
end

function CrimeNetSidebarItem:set_highlight_color(color)
	self._highlight_color = color

	self:set_highlight(self._highlight, true, true)
end

function CrimeNetSidebarItem:set_pulse_color(color)
	self._pulse_color = color
end

function CrimeNetSidebarItem:create_glow(panel, color, scale)
	scale = scale or 1
	local glow_panel = panel:panel({
		alpha = 0,
		layer = 10,
		w = 448 * scale,
		h = 96 * scale
	})
	local glow_center = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		name = "glow_center",
		blend_mode = "add",
		alpha = 0.55,
		w = 96 * scale,
		h = 96 * scale,
		color = color
	})
	local glow_stretch = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		name = "glow_stretch",
		blend_mode = "add",
		alpha = 0.55,
		w = 448 * scale,
		h = 64 * scale,
		color = color
	})
	local glow_center_dark = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		name = "glow_center_dark",
		blend_mode = "normal",
		alpha = 0.7,
		layer = -1,
		w = 80 * scale,
		h = 80 * scale,
		color = Color.black
	})
	local glow_stretch_dark = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		name = "glow_stretch_dark",
		blend_mode = "normal",
		alpha = 0.75,
		layer = -1,
		w = 462 * scale,
		h = 64 * scale,
		color = Color.black
	})

	glow_center:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	glow_stretch:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	glow_center_dark:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	glow_stretch_dark:set_center(glow_panel:w() / 2, glow_panel:h() / 2)

	return glow_panel
end

function CrimeNetSidebarItem:update(t, dt)
	if self._highlight then
		return
	end

	if self._pulse_color then
		local _t = math.abs(math.sin(t * 150))
		local col = math.lerp(tweak_data.screen_colors.button_stage_3, self._pulse_color, _t)

		self._text:set_color(col)
		self._icon:set_color(col)
	end
end

CrimeNetSidebarAttentionItem = CrimeNetSidebarAttentionItem or class(CrimeNetSidebarItem)

function CrimeNetSidebarAttentionItem:init(sidebar, panel, parameters)
	CrimeNetSidebarAttentionItem.super.init(self, sidebar, panel, parameters)

	local glow_color = parameters.attention_color or tweak_data.screen_colors.heat_warm_color

	if parameters.calling_attention then
		self._unplayed_pulse = self:create_glow(sidebar._fullscreen_panel, glow_color, 0.85)

		self._unplayed_pulse:set_world_center(managers.gui_data:safe_to_full_16_9(self._icon:world_center()))

		self._pulse_offset = math.random()
	end
end

function CrimeNetSidebarAttentionItem:update(t, dt)
	CrimeNetSidebarAttentionItem.super.update(self, t, dt)

	local target_alpha = self._highlight and 0 or 0.2

	if alive(self._unplayed_pulse) then
		local _t = math.abs(math.sin((t + self._pulse_offset) * 100))

		self._unplayed_pulse:set_alpha(0.3 + _t * target_alpha)
	end
end

CrimeNetSidebarTutorialHeistsItem = CrimeNetSidebarTutorialHeistsItem or class(CrimeNetSidebarAttentionItem)

function CrimeNetSidebarTutorialHeistsItem:init(sidebar, panel, parameters)
	local tutorial_completions = 0

	for _, data in ipairs(tweak_data.narrative.tutorials) do
		tutorial_completions = tutorial_completions + managers.statistics:completed_job(data.job or "short", "normal")
	end

	parameters.calling_attention = tutorial_completions == 0

	CrimeNetSidebarTutorialHeistsItem.super.init(self, sidebar, panel, parameters)
end

CrimeNetSidebarSkirmishItem = CrimeNetSidebarSkirmishItem or class(CrimeNetSidebarAttentionItem)

function CrimeNetSidebarSkirmishItem:init(sidebar, panel, parameters)
	parameters.calling_attention = #managers.skirmish:unclaimed_rewards() > 0

	CrimeNetSidebarSkirmishItem.super.init(self, sidebar, panel, parameters)
end

CrimeNetSidebarStoryMissionItem = CrimeNetSidebarStoryMissionItem or class(CrimeNetSidebarAttentionItem)

function CrimeNetSidebarStoryMissionItem:init(sidebar, panel, parameters)
	local current = managers.story:current_mission()
	parameters.calling_attention = current and current.completed and not current.rewarded

	CrimeNetSidebarStoryMissionItem.super.init(self, sidebar, panel, parameters)
end

CrimeNetSidebarSafehouseItem = CrimeNetSidebarSafehouseItem or class(CrimeNetSidebarItem)

function CrimeNetSidebarSafehouseItem:init(sidebar, panel, parameters)
	CrimeNetSidebarSafehouseItem.super.init(self, sidebar, panel, parameters)

	if managers.custom_safehouse:unlocked() and not managers.custom_safehouse:has_entered_safehouse() then
		self._unplayed_pulse = self:create_glow(sidebar._fullscreen_panel, tweak_data.screen_colors.heat_warm_color, 0.85)

		self._unplayed_pulse:set_world_center(managers.gui_data:safe_to_full_16_9(self._icon:world_center()))

		self._pulse_offset = math.random()
		self._unplayed = true
	end

	if managers.custom_safehouse:unlocked() and managers.custom_safehouse:is_being_raided() then
		self:set_text(managers.localization:text("menu_cn_chill_combat"))
		self:set_pulse_color(math.lerp(tweak_data.screen_colors.button_stage_2, Color.white, 0.75))

		self._siren_red = self:create_glow(sidebar._fullscreen_panel, Color(255, 255, 0, 0) / 255, 0.85)

		self._siren_red:set_center(self._icon:right() + self._icon:w() + 14 - 2, self._panel:bottom() + self._panel:h() * 0.5 - 2)

		self._siren_blue = self:create_glow(sidebar._fullscreen_panel, Color(255, 0, 180, 255) / 255, 1)

		self._siren_blue:set_center(self._icon:right() + self._icon:w() + 14 + 2, self._panel:bottom() + self._panel:h() * 0.5 - 2)

		self._raid_active = true
	end
end

function CrimeNetSidebarSafehouseItem:update(t, dt)
	if self._unplayed then
		local target_alpha = self._highlight and 0 or 0.2

		if alive(self._unplayed_pulse) then
			local _t = math.abs(math.sin((t + self._pulse_offset) * 100))

			self._unplayed_pulse:set_alpha(0.15 + _t * target_alpha)
		end
	end

	if self._raid_active then
		if not self._highlight and self._pulse_color then
			local _t = math.abs(math.sin(t * 150))
			local col = math.lerp(tweak_data.screen_colors.button_stage_2, self._pulse_color, _t)

			if _t < 0.2 then
				local col = math.lerp(tweak_data.screen_colors.button_stage_2, self._pulse_color, math.abs(math.sin(t * 1200)))

				self._text:set_color(col)
				self._icon:set_color(col)
			else
				self._text:set_color(tweak_data.screen_colors.button_stage_2)
				self._icon:set_color(tweak_data.screen_colors.button_stage_2)
			end
		end

		local target_alpha = self._highlight and 0.3 or 0.4

		if alive(self._siren_red) then
			local _t = math.abs(math.sin(t * 300))

			self._siren_red:set_alpha(_t * target_alpha)
		end

		if alive(self._siren_blue) then
			local _t = math.abs(math.sin((t + 0.35) * 450))

			self._siren_blue:set_alpha(_t * target_alpha)
		end
	end
end

function CrimeNetSidebarSafehouseItem:set_highlight(enabled, no_sound, force_update)
	CrimeNetSidebarSafehouseItem.super.set_highlight(self, enabled, no_sound, force_update)

	if enabled and self._raid_active and not self._played_event and not no_sound then
		managers.menu_component:post_event("pln_sfr_cnc_01_01", true)

		self._played_event = true
	end
end

CrimeNetSidebarMutatorsItem = CrimeNetSidebarMutatorsItem or class(CrimeNetSidebarItem)

function CrimeNetSidebarMutatorsItem:init(sidebar, panel, parameters)
	CrimeNetSidebarMutatorsItem.super.init(self, sidebar, panel, parameters)

	if managers.mutators:are_mutators_enabled() then
		self._glow_panel = self:create_glow(sidebar._fullscreen_panel, Color(1, 0, 1) * 0.8, 0.85)

		self._glow_panel:set_center(self._icon:right() + self._icon:w() + 14 - 2, self._panel:bottom() + self._panel:h() * 0.5 - 2)
		self._glow_panel:set_alpha(0.4)

		self._pulse_offset = math.random()

		self:set_color(Color(1, 0, 1))
	end
end

function CrimeNetSidebarMutatorsItem:update(t, dt)
	CrimeNetSidebarMutatorsItem.super.update(self, t, dt)

	local target_alpha = self._highlight and 0 or 0.2

	if alive(self._glow_panel) then
		local _t = math.abs(math.sin((t + self._pulse_offset) * 100))

		self._glow_panel:set_alpha(0.3 + _t * target_alpha)
	end
end

CrimeNetSidebarCrimeSpreeItem = CrimeNetSidebarCrimeSpreeItem or class(CrimeNetSidebarItem)

function CrimeNetSidebarCrimeSpreeItem:init(...)
	CrimeNetSidebarCrimeSpreeItem.super.init(self, ...)

	if managers.crime_spree:in_progress() then
		self:set_text(managers.localization:text("cn_crime_spree_level", {
			level = managers.experience:cash_string(managers.crime_spree:spree_level(), "")
		}))
		self:set_color(tweak_data.screen_colors.crime_spree_risk)
		self:set_highlight_color(tweak_data.screen_colors.crime_spree_risk)
	end
end
