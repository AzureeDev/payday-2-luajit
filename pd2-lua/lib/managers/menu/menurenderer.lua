core:import("CoreMenuRenderer")
require("lib/utils/gui/Blackborders")
require("lib/managers/menu/MenuNodeGui")
require("lib/managers/menu/renderers/MenuNodeBaseGui")
require("lib/managers/menu/renderers/MenuNodeTableGui")
require("lib/managers/menu/renderers/MenuNodeStatsGui")
require("lib/managers/menu/renderers/MenuNodeCreditsGui")
require("lib/managers/menu/renderers/MenuNodeButtonLayoutGui")
require("lib/managers/menu/renderers/MenuNodeHiddenGui")
require("lib/managers/menu/renderers/MenuNodeCrimenetGui")
require("lib/managers/menu/renderers/MenuNodeUpdatesGui")
require("lib/managers/menu/renderers/MenuNodeReticleSwitchGui")
require("lib/managers/menu/renderers/MenuNodePrePlanningGui")
require("lib/managers/menu/renderers/MenuNodeJukeboxGui")
require("lib/managers/menu/renderers/MenuModInfoGui")
require("lib/managers/menu/renderers/MenuNodeSkillSwitchGui")
require("lib/managers/menu/renderers/MenuNodeEconomySafe")
require("lib/managers/menu/renderers/MenuNodeWeaponCosmeticsGui")
require("lib/managers/menu/renderers/MenuNodeDoubleColumnGui")
require("lib/managers/menu/renderers/MenuNodeMutatorOptionsGui")
require("lib/managers/menu/renderers/MenuNodeLobbyCountdownGui")
require("lib/managers/menu/renderers/MenuNodeCustomizeGadgetGui")
require("lib/managers/menu/renderers/MenuNodeAchievementFilterGui")
require("lib/managers/menu/renderers/MenuNodeCustomizeWeaponColorGui")

MenuRenderer = MenuRenderer or class(CoreMenuRenderer.Renderer)

function MenuRenderer:init(logic, ...)
	MenuRenderer.super.init(self, logic, ...)

	self._sound_source = SoundDevice:create_source("MenuRenderer")
end

function MenuRenderer:show_node(node)
	local gui_class = MenuNodeGui

	if node:parameters().gui_class then
		gui_class = CoreSerialize.string_to_classtable(node:parameters().gui_class)
	end

	local parameters = {
		marker_alpha = 0.6,
		align = "right",
		row_item_blend_mode = "add",
		to_upper = true,
		font = tweak_data.menu.pd2_medium_font,
		row_item_color = tweak_data.screen_colors.button_stage_3,
		row_item_hightlight_color = tweak_data.screen_colors.button_stage_2,
		font_size = tweak_data.menu.pd2_medium_font_size,
		node_gui_class = gui_class,
		spacing = node:parameters().spacing,
		marker_color = tweak_data.screen_colors.button_stage_3:with_alpha(0.2)
	}

	MenuRenderer.super.show_node(self, node, parameters)

	local previous_node_gui = self._node_gui_stack[#self._node_gui_stack - 1]

	if previous_node_gui and (node:parameters().hide_previous == false or node:parameters().hide_previous == "false") then
		previous_node_gui:set_visible(true)
	end
end

function MenuRenderer:open(...)
	MenuRenderer.super.open(self, ...)
	self:_create_framing()

	self._menu_stencil_align = "left"
	self._menu_stencil_default_image = "guis/textures/empty"
	self._menu_stencil_image = self._menu_stencil_default_image

	self:_layout_menu_bg()
end

function MenuRenderer:_create_framing()
	local bh = CoreMenuRenderer.Renderer.border_height
	local scaled_size = managers.gui_data:scaled_size()
	self._bottom_line = self._main_panel:bitmap({
		texture = "guis/textures/headershadow",
		alpha = 0,
		blend_mode = "add",
		rotation = 180,
		layer = 1,
		color = Color.white:with_alpha(0),
		w = scaled_size.width,
		y = scaled_size.height - bh
	})

	self._bottom_line:hide()
	MenuRenderer._create_bottom_text(self)
end

function MenuRenderer:_create_bottom_text()
	local scaled_size = managers.gui_data:scaled_size()
	self._bottom_text = self._main_panel:text({
		vertical = "top",
		wrap = true,
		word_wrap = true,
		align = "right",
		text = "",
		hvertical = "top",
		halign = "right",
		layer = 2,
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		w = scaled_size.width * 0.66
	})

	self._bottom_text:set_right(self._bottom_text:parent():w())
end

function MenuRenderer:set_bottom_text(id, localize)
	if not alive(self._bottom_text) then
		return
	end

	if not id then
		self._bottom_text:set_text("")

		return
	end

	self._bottom_text:set_text(utf8.to_upper(localize and managers.localization:text(id) or id))

	local _, _, _, h = self._bottom_text:text_rect()

	self._bottom_text:set_h(h)
end

function MenuRenderer:close(...)
	MenuRenderer.super.close(self, ...)
	managers.menu_component:close_newsfeed_gui()

	if alive(self._blackborder_workspace) then
		managers.gui_data:destroy_workspace(self._blackborder_workspace)

		self._blackborder_workspace = nil
	end
end

function MenuRenderer:_layout_menu_bg()
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.gui_data:scaled_size()

	self:set_stencil_align(self._menu_stencil_align, self._menu_stencil_align_percent)

	if not self._disable_blackborder then
		self:_create_blackborders()
	end
end

function MenuRenderer:_create_blackborders()
	if alive(self._blackborder_workspace) then
		managers.gui_data:destroy_workspace(self._blackborder_workspace)

		self._blackborder_workspace = nil
	end

	self._blackborder_workspace = managers.gui_data:create_fullscreen_workspace()

	BlackBorders:new(self._blackborder_workspace:panel())
end

function MenuRenderer:update(t, dt)
	MenuRenderer.super.update(self, t, dt)
end

local mugshot_stencil = {
	random = {
		"bg_lobby_fullteam",
		65
	},
	undecided = {
		"bg_lobby_fullteam",
		65
	},
	american = {
		"bg_hoxton",
		65
	},
	german = {
		"bg_wolf",
		55
	},
	russian = {
		"bg_dallas",
		65
	},
	spanish = {
		"bg_chains",
		60
	}
}

function MenuRenderer:highlight_item(item, ...)
	MenuRenderer.super.highlight_item(self, item, ...)

	if item then
		self:post_event("highlight")
	end
end

function MenuRenderer:trigger_item(item)
	MenuRenderer.super.trigger_item(self, item)

	if item and item:visible() and item:parameters().sound ~= "false" then
		local item_type = item:type()

		if item_type == "" then
			self:post_event("menu_enter")
		elseif item_type == "toggle" then
			if item:value() == "on" then
				self:post_event("box_tick")
			else
				self:post_event("box_untick")
			end
		elseif item_type == "slider" then
			local percentage = item:percentage()

			if percentage > 0 and percentage < 100 then
				-- Nothing
			end
		elseif item_type == "grid" then
			-- Nothing
		elseif item_type == "multi_choice" then
			-- Nothing
		end
	end
end

function MenuRenderer:post_event(event)
	if _G.IS_VR then
		managers.menu:post_event_vr(event)
	end

	self._sound_source:post_event(event)
end

function MenuRenderer:navigate_back()
	MenuRenderer.super.navigate_back(self)
	self:active_node_gui():update_item_icon_visibility()
	self:post_event("menu_exit")
end

function MenuRenderer:resolution_changed(...)
	MenuRenderer.super.resolution_changed(self, ...)
	self:_layout_menu_bg()

	local active_node_gui = self:active_node_gui()

	if active_node_gui and active_node_gui.update_item_icon_visibility then
		self:active_node_gui():update_item_icon_visibility()
	end
end

function MenuRenderer:set_bg_visible(visible)
end

function MenuRenderer:set_bg_area(area)
end

function MenuRenderer:set_stencil_image(image)
	if not self._menu_stencil then
		return
	end

	self._menu_stencil_image_name = image
	image = tweak_data.menu_themes[managers.user:get_setting("menu_theme")][image]

	if self._menu_stencil_image == image then
		return
	end

	self._menu_stencil_image = image or self._menu_stencil_default_image

	self._menu_stencil:set_image(self._menu_stencil_image)
	self:set_stencil_align(self._menu_stencil_align, self._menu_stencil_align_percent)
end

function MenuRenderer:refresh_theme()
	self:set_stencil_image(self._menu_stencil_image_name)
end

function MenuRenderer:set_stencil_align(align, percent)
	if not self._menu_stencil then
		return
	end

	self._menu_stencil_align = align
	self._menu_stencil_align_percent = percent
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local y = safe_rect_pixels.height - tweak_data.load_level.upper_saferect_border * 2 + 2
	local m = self._menu_stencil:texture_width() / self._menu_stencil:texture_height()

	self._menu_stencil:set_size(y * m, y)
	self._menu_stencil:set_center_y(res.y / 2)

	local w = self._menu_stencil:texture_width()
	local h = self._menu_stencil:texture_height()

	if align == "right" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)
		self._menu_stencil:set_right(res.x)
	elseif align == "left" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)
		self._menu_stencil:set_left(0)
	elseif align == "center" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)
		self._menu_stencil:set_center_x(res.x / 2)
	elseif align == "center-right" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)
		self._menu_stencil:set_center_x(res.x * 0.66)
	elseif align == "center-left" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)
		self._menu_stencil:set_center_x(res.x * 0.33)
	elseif align == "manual" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)

		percent = percent / 100

		self._menu_stencil:set_left(res.x * percent - y * m * percent)
	end
end

function MenuRenderer:current_menu_text(topic_id)
	local ids = {}

	for i, node_gui in ipairs(self._node_gui_stack) do
		table.insert(ids, node_gui.node:parameters().topic_id)
	end

	table.insert(ids, topic_id)

	local s = ""

	for i, id in ipairs(ids) do
		s = s .. managers.localization:text(id)
		s = s .. (i < #ids and " > " or "")
	end

	return s
end

function MenuRenderer:accept_input(accept)
	managers.menu_component:accept_input(accept)
end

function MenuRenderer:input_focus()
	if self:active_node_gui() and (self:active_node_gui().name == "crimenet_contract_crime_spree_join" or self:active_node_gui().name == "crimenet_crime_spree_contract_host" or self:active_node_gui().name == "crimenet_crime_spree_contract_singleplayer") then
		return false
	end

	if self:active_node_gui() and self:active_node_gui().input_focus then
		local input_focus = self:active_node_gui():input_focus()

		if input_focus then
			return input_focus
		end
	end

	return managers.menu_component:input_focus()
end

function MenuRenderer:mouse_pressed(o, button, x, y)
	if self:active_node_gui() and self:active_node_gui().mouse_pressed and self:active_node_gui():mouse_pressed(button, x, y) then
		return true
	end

	if managers.menu_component:mouse_pressed(o, button, x, y) then
		return true
	end

	if managers.menu_scene and managers.menu_scene:mouse_pressed(o, button, x, y) then
		return true
	end
end

function MenuRenderer:mouse_released(o, button, x, y)
	if self:active_node_gui() and self:active_node_gui().mouse_released and self:active_node_gui():mouse_released(button, x, y) then
		return true
	end

	if managers.menu_component:mouse_released(o, button, x, y) then
		return true
	end

	if managers.menu_scene and managers.menu_scene:mouse_released(o, button, x, y) then
		return true
	end

	return false
end

function MenuRenderer:mouse_clicked(o, button, x, y)
	if self:active_node_gui() and self:active_node_gui().mouse_clicked and self:active_node_gui():mouse_clicked(button, x, y) then
		return true
	end

	if managers.menu_component:mouse_clicked(o, button, x, y) then
		return true
	end

	return false
end

function MenuRenderer:mouse_double_click(o, button, x, y)
	if managers.menu_component:mouse_double_click(o, button, x, y) then
		return true
	end

	return false
end

function MenuRenderer:mouse_moved(o, x, y)
	local wanted_pointer = "arrow"

	if self:active_node_gui() and self:active_node_gui().mouse_moved and managers.menu_component:input_focus() ~= true then
		local used, pointer = self:active_node_gui():mouse_moved(o, x, y)
		wanted_pointer = pointer or wanted_pointer

		if used then
			return true, wanted_pointer
		end
	end

	local used, pointer = managers.menu_component:mouse_moved(o, x, y)
	wanted_pointer = pointer or wanted_pointer

	if used then
		return true, wanted_pointer
	end

	if managers.menu_scene then
		local used, pointer = managers.menu_scene:mouse_moved(o, x, y)
		wanted_pointer = pointer or wanted_pointer

		if used then
			return true, wanted_pointer
		end
	end

	return false, wanted_pointer
end

function MenuRenderer:scroll_up()
	return managers.menu_component:scroll_up()
end

function MenuRenderer:scroll_down()
	return managers.menu_component:scroll_down()
end

function MenuRenderer:move_up()
	if self:active_node_gui() and self:active_node_gui().move_up and self:active_node_gui():move_up() then
		return true
	end

	return managers.menu_component:move_up()
end

function MenuRenderer:move_down()
	if self:active_node_gui() and self:active_node_gui().move_down and self:active_node_gui():move_down() then
		return true
	end

	return managers.menu_component:move_down()
end

function MenuRenderer:move_left()
	if self:active_node_gui() and self:active_node_gui().move_left and self:active_node_gui():move_left() then
		return true
	end

	return managers.menu_component:move_left()
end

function MenuRenderer:move_right()
	if self:active_node_gui() and self:active_node_gui().move_right and self:active_node_gui():move_right() then
		return true
	end

	return managers.menu_component:move_right()
end

function MenuRenderer:next_page()
	if self:active_node_gui() and self:active_node_gui().next_page and self:active_node_gui():next_page() then
		return true
	end

	return managers.menu_component:next_page()
end

function MenuRenderer:previous_page()
	if self:active_node_gui() and self:active_node_gui().previous_page and self:active_node_gui():previous_page() then
		return true
	end

	return managers.menu_component:previous_page()
end

function MenuRenderer:confirm_pressed()
	if self:active_node_gui() and self:active_node_gui().confirm_pressed and self:active_node_gui():confirm_pressed() then
		return true
	end

	return managers.menu_component:confirm_pressed()
end

function MenuRenderer:back_pressed()
	return managers.menu_component:back_pressed()
end

function MenuRenderer:special_btn_pressed(...)
	if self:active_node_gui() and self:active_node_gui().special_btn_pressed and self:active_node_gui():special_btn_pressed(...) then
		return true
	end

	return managers.menu_component:special_btn_pressed(...)
end

function MenuRenderer:special_btn_released(...)
	if self:active_node_gui() and self:active_node_gui().special_btn_released and self:active_node_gui():special_btn_released(...) then
		return true
	end

	return managers.menu_component:special_btn_released(...)
end

function MenuRenderer:ws_test()
	if alive(self._test_safe) then
		managers.gui_data:destroy_workspace(self._test_safe)
	end

	if alive(self._test_full) then
		managers.gui_data:destroy_workspace(self._test_full)
	end

	self._test_safe = managers.gui_data:create_saferect_workspace()
	self._test_full = managers.gui_data:create_fullscreen_workspace()
	local x = 150
	local y = 200
	local fx, fy = managers.gui_data:safe_to_full(x, y)
	local safe = self._test_safe:panel():rect({
		h = 48,
		w = 48,
		orientation = "vertical",
		layer = 0,
		x = x,
		y = y,
		color = Color.green
	})
	local full = self._test_full:panel():rect({
		h = 48,
		w = 48,
		orientation = "vertical",
		layer = 0,
		x = fx,
		y = fy,
		color = Color.red
	})
end
