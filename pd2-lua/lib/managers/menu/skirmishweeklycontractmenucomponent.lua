SkirmishWeeklyContractMenuComponent = SkirmishWeeklyContractMenuComponent or class()

function SkirmishWeeklyContractMenuComponent:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._panel = ws:panel():panel({
		layer = 51
	})
	self._fullscreen_panel = fullscreen_ws:panel():panel({
		layer = 50
	})
	local job_data = node:parameters().menu_component_data
	local bg_overlay = BlurSheet:new(self._fullscreen_panel, {
		name = "bg_overlay",
		layer = 1,
		color = Color(0.75, 0, 0, 0)
	})
	local title_text = FineText:new(self._panel, {
		name = "title_text",
		layer = 1,
		text = managers.localization:to_upper_text("menu_weekly_skirmish"),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size
	})
	local width = 900
	local height = 580
	local contract_panel = self._panel:panel({
		name = "contract_panel",
		layer = 5,
		w = width,
		h = height
	})

	contract_panel:set_center(self._panel:width() * 0.5, self._panel:height() * 0.5)
	title_text:set_leftbottom(contract_panel:lefttop())

	local progress_title = FineText:new(contract_panel, {
		name = "progress_title",
		layer = 1,
		text = managers.localization:to_upper_text("menu_weekly_skirmish_rewards")
	})
	local reward_panel = contract_panel:panel({
		name = "reward_panel",
		h = 200,
		y = progress_title:bottom()
	})

	BoxGuiObject:new(reward_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	if managers.skirmish:host_weekly_match() then
		local countdown_text = FineText:new(reward_panel, {
			name = "countdown",
			y = 5,
			x = 10,
			layer = 1,
			text = managers.localization:to_upper_text("skirmish_weekly_time_left", managers.skirmish:weekly_time_left_params()),
			color = tweak_data.screen_colors.text:with_alpha(0.5)
		})

		countdown_text:animate(function (o)
			while true do
				wait(1)

				local time_text = managers.localization:to_upper_text("skirmish_weekly_time_left", managers.skirmish:weekly_time_left_params())

				countdown_text:set_text(time_text)
			end
		end)
	end

	local max_weekly_wave = 9
	local progress_text = FineText:new(reward_panel, {
		name = "progress_text",
		layer = 1,
		y = 5,
		text = managers.localization:to_upper_text("menu_weekly_skirmish_current_progress", {
			current = managers.skirmish:weekly_progress(),
			total = max_weekly_wave
		})
	})

	progress_text:set_right(reward_panel:w() - 10)

	local progress = managers.skirmish:weekly_progress() / max_weekly_wave
	local progress_bar = ProgressBar:new(reward_panel, {
		name = "progress_bar",
		h = 8,
		edges = "up",
		progress_color = tweak_data.screen_colors.button_stage_2,
		back_color = tweak_data.screen_colors.text:with_alpha(0.4),
		w = reward_panel:w() * 0.75,
		y = reward_panel:h() * 0.75
	}, progress)

	progress_bar:set_center_x(reward_panel:w() / 2)

	local milestones = {
		0,
		3,
		5,
		9
	}

	for _, milestone in ipairs(milestones) do
		local milestone_progress = milestone / max_weekly_wave
		local milestone_panel = reward_panel:panel({
			w = 50,
			h = 150,
			layer = 50,
			name = "milestone_" .. tostring(milestone)
		})

		milestone_panel:set_center_x(progress_bar:x() + progress_bar:w() * milestone_progress)
		milestone_panel:set_bottom(progress_bar:y())

		local unlocked = milestone_progress <= progress
		local color = tweak_data.screen_colors.text:with_alpha(unlocked and 1 or 0.4)
		local milestone_title = FineText:new(milestone_panel, {
			name = "title",
			align = "center",
			text = tostring(milestone),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = color
		})
		local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
		local milestone_arrow = milestone_panel:bitmap({
			name = "arrow",
			h = 6,
			w = 12,
			rotation = 180,
			texture = texture,
			texture_rect = rect,
			color = color
		})

		milestone_arrow:set_center_x(milestone_panel:w() / 2)
		milestone_arrow:set_bottom(milestone_panel:h() - 5)
		milestone_title:set_bottom(milestone_arrow:y() - 2)

		if milestone > 0 then
			local milestone_reward = managers.skirmish:claimed_reward_by_id(milestone)
			local icon_data, text_id = nil

			if milestone_reward then
				local reward_type, reward_id = unpack(milestone_reward)
				local guis_catalog = "guis/"
				local bundle_folder = tweak_data.blackmarket[reward_type][reward_id] and tweak_data.blackmarket[reward_type][reward_id].texture_bundle_folder

				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				if reward_type == "textures" then
					icon_data = {
						render_template = "VertexColorTexturedPatterns",
						texture = tweak_data.blackmarket.textures[reward_id].texture
					}
					text_id = tweak_data.blackmarket.textures[reward_id].name_id
				elseif reward_type == "materials" then
					icon_data = {
						texture = guis_catalog .. "textures/pd2/blackmarket/icons/materials/" .. reward_id
					}
					text_id = tweak_data.blackmarket.materials[reward_id].name_id
				elseif reward_type == "masks" then
					icon_data = {
						texture = guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. reward_id
					}
					text_id = tweak_data.blackmarket.masks[reward_id].name_id
				else
					icon_data = tweak_data.hud_icons.downcard_overkill_deck
				end
			else
				icon_data = tweak_data.hud_icons.downcard_overkill_deck
			end

			local reward_icon = milestone_panel:bitmap({
				name = "icon",
				texture = icon_data.texture,
				texture_rect = icon_data.texture_rect,
				render_template = icon_data.render_template,
				color = color
			})

			ExtendedPanel.make_bitmap_fit(reward_icon, milestone_panel:w(), milestone_panel:h())
			reward_icon:set_center_x(milestone_panel:w() / 2)
			reward_icon:set_bottom(milestone_title:y() - 5)

			if text_id then
				local reward_title = FineText:new(milestone_panel, {
					name = "reward_title",
					align = "center",
					rotation = 360,
					text = managers.localization:to_upper_text(text_id),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size
				})

				reward_title:set_bottom(reward_icon:top())
				reward_title:set_center_x(reward_icon:center_x())
			end
		end
	end

	local details_panel = contract_panel:panel({
		name = "details",
		y = reward_panel:bottom() + 10,
		w = width / 2,
		h = height - (reward_panel:bottom() + 10) - 16
	})
	local show_progress_warning = job_data.state == tweak_data:server_state_to_index("in_game")
	local modifiers = job_data.skirmish_weekly_modifiers and string.split(job_data.skirmish_weekly_modifiers, ";") or managers.skirmish:weekly_modifiers()
	self._details_page = SkirmishWeeklyContractDetails:new(details_panel, show_progress_warning, modifiers)

	managers.menu_component:disable_crimenet()
	managers.menu:active_menu().input:deactivate_controller_mouse()

	if not managers.menu:is_pc_controller() then
		self._ws:connect_controller(managers.menu:active_menu().input:get_controller(), true)
	end
end

function SkirmishWeeklyContractMenuComponent:close()
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
	managers.menu:active_menu().input:activate_controller_mouse()
end

function SkirmishWeeklyContractMenuComponent:input_focus()
	local input = managers.menu:active_menu().input

	if input:menu_next_page_input_bool() or input:menu_previous_page_input_bool() then
		return 1
	end

	return false
end

local function redirect_to_member(class, member_name, functions)
	for _, name in pairs(functions) do
		class[name] = function (self, ...)
			local member = self[member_name]

			return member[name](member, ...)
		end
	end
end

redirect_to_member(SkirmishWeeklyContractMenuComponent, "_details_page", {
	"mouse_clicked",
	"mouse_pressed",
	"mouse_released",
	"mouse_wheel_up",
	"mouse_wheel_down",
	"mouse_moved",
	"next_page",
	"previous_page",
	"update"
})

SkirmishWeeklyContractDetails = SkirmishWeeklyContractDetails or class(MenuGuiComponentGeneric)

function SkirmishWeeklyContractDetails:init(panel, show_progress_warning, modifiers)
	self._init_layer = panel:layer()
	self.make_fine_text = BlackMarketGui.make_fine_text
	self._rec_round_object = NewSkillTreeGui._rec_round_object
	self._show_progress_warning = show_progress_warning
	self._modifier_list = modifiers
	self._panel = panel
	self._tabs = {}
	self._tabs_data = {}

	self:populate_tabs_data(self._tabs_data)
	self:_setup()
	self:set_layer(10)
end

function SkirmishWeeklyContractDetails:_setup()
	self._panel:clear()
	self:_add_panels()
	self:_add_tabs()
	self:_rec_round_object(self._panel)
	self:set_active_page(1)
end

function SkirmishWeeklyContractDetails:_add_panels()
	local tab_h = tweak_data.menu.pd2_medium_font_size + 10
	self._page_panel = self._panel:panel({
		layer = 1,
		name = "PageRootPanel",
		h = self._panel:h() - tab_h,
		y = tab_h
	})
	self._tabs_panel = self._panel:panel({
		name = "TabPanel",
		y = 2,
		h = tab_h
	})
	self._tabs_scroll_panel = self._tabs_panel:panel({})
	self._outline_panel = self._page_panel:panel({
		layer = 10
	})
	self._outline_box = BoxGuiObject:new(self._outline_panel, {
		sides = {
			1,
			1,
			2,
			1
		}
	})
end

function SkirmishWeeklyContractDetails:populate_tabs_data(tabs_data)
	table.insert(tabs_data, {
		name_id = "menu_weekly_skirmish_tab_description",
		page_class = "SkirmishWeeklyContractDescriptionPage"
	})
	table.insert(tabs_data, {
		name_id = "menu_cs_modifiers",
		page_class = "SkirmishWeeklyContractModifiersPage"
	})
end

function SkirmishWeeklyContractDetails:close()
end

function SkirmishWeeklyContractDetails:set_active_page(new_index, play_sound)
	if new_index == self._active_page or new_index <= 0 or new_index > #self._tabs then
		return false
	end

	local active_page = self._tabs[self._active_page] and self._tabs[self._active_page].page
	local active_tab = self._tabs[self._active_page] and self._tabs[self._active_page].tab
	local new_page = self._tabs[new_index] and self._tabs[new_index].page
	local new_tab = self._tabs[new_index] and self._tabs[new_index].tab
	local tab_width = self._tabs[new_index] and self._tabs[new_index].width_multiplier

	if active_page then
		active_page:set_active(false)
	end

	if active_tab then
		active_tab:set_active(false)
	end

	if new_page then
		new_page:set_active(true)
	end

	if new_tab then
		new_tab:set_active(true)

		self._selected_page = new_tab:page()
	end

	local prev_page = self._tabs_panel:child("prev_page")

	if prev_page then
		prev_page:set_visible(new_index > 1)
	end

	local next_page = self._tabs_panel:child("next_page")

	if prev_page then
		next_page:set_visible(new_index < #self._tabs)
	end

	if play_sound then
		managers.menu_component:post_event("highlight")
	end

	if self._outline_box then
		self._outline_box:close()
	end

	self._outline_box = BoxGuiObject:new(self._outline_panel, {
		sides = {
			1,
			1,
			2,
			1
		}
	})
	self._active_page = new_index

	self:update_legend()

	return true
end

function SkirmishWeeklyContractDetails:next_page()
	if self._active_page ~= nil then
		return self:set_active_page(self._active_page + 1)
	end
end

function SkirmishWeeklyContractDetails:previous_page()
	if self._active_page ~= nil then
		return self:set_active_page(self._active_page - 1)
	end
end

SkirmishWeeklyContractPage = SkirmishWeeklyContractPage or class()

function SkirmishWeeklyContractPage:init(page_id, page_panel, fullscreen_panel, gui)
end

function SkirmishWeeklyContractPage:set_active(active)
end

function SkirmishWeeklyContractPage:mouse_moved(button, x, y)
end

function SkirmishWeeklyContractPage:mouse_pressed(button, x, y)
end

function SkirmishWeeklyContractPage:mouse_released(button, x, y)
end

function SkirmishWeeklyContractPage:mouse_wheel_up(x, y)
end

function SkirmishWeeklyContractPage:mouse_wheel_down(x, y)
end

function SkirmishWeeklyContractPage:mouse_clicked(o, button, x, y)
end

function SkirmishWeeklyContractPage:update()
end

function SkirmishWeeklyContractPage:get_legend()
	return {}
end

SkirmishWeeklyContractDescriptionPage = SkirmishWeeklyContractDescriptionPage or class(SkirmishWeeklyContractPage)

function SkirmishWeeklyContractDescriptionPage:init(page_id, page_panel, fullscreen_panel, gui)
	local desc_text = managers.localization:text("menu_weekly_skirmish_desc")
	local color_start = nil

	if gui._show_progress_warning then
		desc_text = desc_text .. "\n\n##" .. managers.localization:text("menu_weekly_skirmish_dropin_warning") .. "##"
	end

	self._desc = FineText:new(page_panel, {
		name = "description",
		wrap = true,
		word_wrap = true,
		y = 10,
		x = 10,
		text = desc_text,
		w = page_panel:width() - 20,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})

	managers.menu_component:make_color_text(self._desc, tweak_data.screen_colors.important_1)
end

function SkirmishWeeklyContractDescriptionPage:set_active(active)
	self._desc:set_visible(active)
end

SkirmishWeeklyContractModifiersPage = SkirmishWeeklyContractModifiersPage or class(SkirmishWeeklyContractPage)

function SkirmishWeeklyContractModifiersPage:init(page_id, page_panel, fullscreen_panel, gui)
	self._gui = gui
	self._modifier_list = SkirmishModifierList:new(page_panel, {
		visible = false,
		modifiers = gui._modifier_list
	})

	if not managers.menu:is_pc_controller() then
		self:_setup_controller_input(page_panel)
	end
end

function SkirmishWeeklyContractModifiersPage:_setup_controller_input(page_panel)
	self._controller_scroll_input = 0

	page_panel:axis_move(callback(self, self, "_axis_move"))
end

function SkirmishWeeklyContractModifiersPage:_axis_move(o, axis_name, axis_vector, controller)
	if axis_name == Idstring("right") then
		self._controller_scroll_input = axis_vector.y
	end
end

function SkirmishWeeklyContractModifiersPage:mouse_wheel_up(x, y)
	self._modifier_list:scroll(x, y, 1)
end

function SkirmishWeeklyContractModifiersPage:mouse_wheel_down(x, y)
	self._modifier_list:scroll(x, y, -1)
end

function SkirmishWeeklyContractModifiersPage:update(t, dt)
	if not managers.menu:is_pc_controller() then
		local y = self._controller_scroll_input

		if y ~= 0 then
			self._modifier_list:perform_scroll(ScrollablePanel.SCROLL_SPEED * dt * 24, y)
		end
	end
end

function SkirmishWeeklyContractModifiersPage:set_active(active)
	self._modifier_list:set_visible(active)
end
