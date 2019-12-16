require("lib/managers/menu/items/ContractBrokerHeistItem")

local padding = 10

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

ContractBrokerGui = ContractBrokerGui or class(MenuGuiComponent)
ContractBrokerGui.tabs = {
	{
		"menu_filter_contractor",
		"_setup_filter_contact"
	},
	{
		"menu_filter_time",
		"_setup_filter_time"
	},
	{
		"menu_filter_tactic",
		"_setup_filter_tactic"
	},
	{
		"menu_filter_most_played",
		"_setup_filter_most_played"
	},
	{
		"menu_filter_favourite",
		"_setup_filter_favourite"
	}
}
ContractBrokerGui.MAX_SEARCH_LENGTH = 20

function ContractBrokerGui:init(ws, fullscreen_ws, node)
	self._fullscreen_ws = managers.gui_data:create_fullscreen_16_9_workspace()
	self._ws = managers.gui_data:create_saferect_workspace()
	self._node = node
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		layer = 1000
	})
	self._panel = self._ws:panel():panel({
		layer = 1100
	})
	self.make_fine_text = BlackMarketGui.make_fine_text
	self._enabled = true
	self._current_filter = Global.contract_broker and Global.contract_broker.filter or 1
	self._highlighted_filter = Global.contract_broker and Global.contract_broker.filter or 1
	self._current_tab = Global.contract_broker and Global.contract_broker.tab or 1
	self._highlighted_tab = Global.contract_broker and Global.contract_broker.tab or 1
	self._current_selection = 0
	self._active_filters = {}
	self._buttons = {}
	self._tab_buttons = {}
	self._filter_buttons = {}
	self._heist_items = {}

	managers.menu_component:disable_crimenet()
	managers.menu:active_menu().input:deactivate_controller_mouse()
	self:setup()

	if Global.contract_broker and Global.contract_broker.job_id then
		for idx, item in ipairs(self._heist_items) do
			if item._job_data and item._job_data.job_id == Global.contract_broker.job_id then
				self._panels.scroll:scroll_to(item._panel:y())
				self:_set_selection(idx)

				break
			end
		end
	end

	Global.contract_broker = nil
end

function ContractBrokerGui:close()
	self:disconnect_search_input()

	self._enabled = false

	managers.menu:active_menu().input:activate_controller_mouse()
	managers.menu_component:enable_crimenet()

	if alive(self._ws) then
		managers.gui_data:destroy_workspace(self._ws)

		self._ws = nil
	end

	if alive(self._fullscreen_ws) then
		managers.gui_data:destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end
end

function ContractBrokerGui:enabled()
	return self._enabled
end

function ContractBrokerGui:setup()
	self:_create_background()
	self:_create_title()
	self:_create_panels()
	self:_create_back_button()
	self:_create_legend()
	self:_setup_tabs()
	self:_setup_filters()
	self:_setup_jobs()

	local default_to_search = managers.menu:is_pc_controller()
	default_to_search = default_to_search and not _G.IS_VR

	if default_to_search then
		self:connect_search_input()
	else
		self:_set_selection(1)
	end

	self:refresh()
end

function ContractBrokerGui:_setup_change_tab()
	self:clear_filters()
	self:_setup_filters()
	self:_setup_jobs()
	self:_set_selection(1)
	self:refresh()
end

function ContractBrokerGui:_setup_change_filter()
	self:_setup_jobs()
	self:_set_selection(1)
	self:refresh()
end

function ContractBrokerGui:_setup_change_search()
	self:clear_filters()
	self:_setup_filters()
	self:_setup_jobs()
	self:refresh()
end

function ContractBrokerGui:_create_background()
	self._fullscreen_panel:rect({
		alpha = 0.6,
		layer = 10,
		color = Color.black
	})
	self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -2,
		halign = "scale",
		alpha = 10,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = self._fullscreen_panel:w(),
		h = self._fullscreen_panel:h()
	})
end

function ContractBrokerGui:_create_title()
	local title = self._panel:text({
		vertical = "top",
		align = "left",
		layer = 100,
		text = managers.localization:to_upper_text("menu_contract_broker"),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(title)
	title:set_top(padding)
	title:set_left(padding)
end

function ContractBrokerGui:_create_panels()
	local main_panel = self._panel:panel({
		w = self._panel:w() * 0.55,
		h = self._panel:h() * 0.7
	})

	main_panel:set_center_x(self._panel:w() * 0.5)
	main_panel:set_top(padding * 2 + tweak_data.menu.pd2_large_font_size * 2)
	BoxGuiObject:new(main_panel:panel({
		layer = 100
	}), {
		sides = {
			1,
			1,
			2,
			2
		}
	})

	local jobs_scroll = ScrollablePanel:new(main_panel, "jobs_scroll", {
		ignore_up_indicator = true,
		y_padding = 0,
		ignore_down_indicator = true
	})
	local filters_panel = self._panel:panel({
		w = self._panel:w() * 0.15,
		h = main_panel:h()
	})

	filters_panel:set_top(main_panel:top())
	filters_panel:set_right(main_panel:left() - padding)

	local tabs_panel = self._panel:panel({
		w = main_panel:w(),
		h = tweak_data.menu.pd2_large_font_size
	})

	tabs_panel:set_left(main_panel:left())
	tabs_panel:set_bottom(main_panel:top())

	self._panels = {
		main = main_panel,
		scroll = jobs_scroll,
		canvas = jobs_scroll:canvas(),
		filters = filters_panel,
		tabs = tabs_panel
	}
end

function ContractBrokerGui:_create_back_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_left(self._panels.main:left())
	back_panel:set_top(self._panels.main:bottom() + 5)

	if managers.menu:is_pc_controller() then
		self._back_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_back"),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._back_button)
		self._back_button:set_right(back_panel:w())
	end
end

function ContractBrokerGui:_create_legend()
	if not managers.menu:is_pc_controller() then
		local legend_items = {
			"move",
			"scroll",
			"select",
			"favourite",
			"back"
		}
		local legends = {}

		if table.contains(legend_items, "move") then
			legends[#legends + 1] = {
				string_id = "menu_legend_preview_move"
			}
		end

		if table.contains(legend_items, "scroll") then
			legends[#legends + 1] = {
				string_id = "menu_legend_scroll"
			}
		end

		if table.contains(legend_items, "select") then
			legends[#legends + 1] = {
				string_id = "menu_legend_select"
			}
		end

		if table.contains(legend_items, "favourite") then
			legends[#legends + 1] = {
				string_id = "menu_legend_broker_favorite"
			}
		end

		if table.contains(legend_items, "back") then
			legends[#legends + 1] = {
				string_id = "menu_legend_back"
			}
		end

		if table.contains(legend_items, "zoom") then
			legends[#legends + 1] = {
				string_id = "menu_legend_preview_zoom"
			}
		end

		local legend_text = ""

		for i, legend in ipairs(legends) do
			local spacing = i > 1 and "  |  " or ""
			legend_text = legend_text .. spacing .. managers.localization:to_upper_text(legend.string_id)
		end

		self._legends_panel = self._panel:panel({
			w = self._panel:w() * 0.75,
			h = tweak_data.menu.pd2_medium_font_size
		})

		self._legends_panel:set_rightbottom(self._panel:w(), self._panel:h())
		self._legends_panel:text({
			name = "text",
			vertical = "bottom",
			align = "right",
			blend_mode = "add",
			halign = "right",
			valign = "bottom",
			text = legend_text,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.text
		})
	end
end

function ContractBrokerGui:_setup_tabs()
	local last_x = 0

	if not managers.menu:is_pc_controller() then
		local icon_text = self._panels.tabs:text({
			vertical = "top",
			alpha = 1,
			align = "center",
			layer = 1,
			text = managers.localization:get_default_macro("BTN_BOTTOM_L"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text,
			x = padding,
			y = padding
		})

		make_fine_text(icon_text)
		icon_text:set_x(padding)

		last_x = icon_text:right()
	end

	for _, data in ipairs(self.tabs) do
		local tab_panel = self._panels.tabs:panel({})
		local text = tab_panel:text({
			vertical = "top",
			alpha = 0.8,
			align = "left",
			layer = 1,
			text = managers.localization:to_upper_text(data[1]),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text,
			x = padding,
			y = padding
		})

		make_fine_text(text)
		tab_panel:set_w(padding * 2 + text:w())
		tab_panel:set_x(last_x)

		last_x = tab_panel:right()

		if data[3] then
			tab_panel:set_visible(data[3](self))
		end

		table.insert(self._buttons, {
			type = "tab",
			element = text
		})
		table.insert(self._tab_buttons, text)
	end

	if not managers.menu:is_pc_controller() then
		local icon_text = self._panels.tabs:text({
			vertical = "top",
			alpha = 1,
			align = "center",
			layer = 1,
			text = managers.localization:get_default_macro("BTN_BOTTOM_R"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text,
			x = padding,
			y = padding
		})

		make_fine_text(icon_text)
		icon_text:set_x(last_x)
	end
end

function ContractBrokerGui:_setup_filters()
	for _, btn in ipairs(self._filter_buttons) do
		self._panels.filters:remove(btn)
	end

	self._filter_buttons = {}
	local tab_data = self.tabs[self._current_tab]
	local filters_clbk = callback(self, self, tab_data[2])

	filters_clbk()

	self._search_filter_visible = false

	if self._search and alive(self._search.text) and #self._search.text:text() > 0 then
		local last_y = 0
		local num_filters = #self._filter_buttons

		if num_filters > 0 then
			last_y = self._filter_buttons[num_filters]:bottom() + 1
		end

		self:_add_filter_button("menu_filter_search_results", last_y)

		self._current_filter = num_filters + 1
		self._search_filter_visible = true
	end

	if not alive(self._filter_selection_bg) then
		self._filter_selection_bg = self._panels.filters:rect({
			blend_mode = "add",
			alpha = 0.4,
			layer = 1,
			color = tweak_data.screen_colors.button_stage_3,
			w = self._panels.filters:w(),
			h = tweak_data.menu.pd2_small_font_size
		})
	end

	if not managers.menu:is_pc_controller() then
		if table.size(self._filter_buttons) > 1 then
			for _, btn in ipairs(self._filter_buttons) do
				btn:set_y(btn:y() + tweak_data.menu.pd2_small_font_size)
			end

			if not self._filter_up then
				self._filter_up = self._panels.filters:text({
					vertical = "top",
					alpha = 1,
					align = "right",
					layer = 1,
					text = managers.localization:get_default_macro("BTN_TOP_L"),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					color = tweak_data.screen_colors.text,
					x = padding,
					y = padding
				})

				make_fine_text(self._filter_up)
			end

			self._filter_up:set_right(self._panels.filters:w() - 4)
			self._filter_up:set_bottom(self._filter_buttons[1]:top())
			self._filter_up:set_visible(true)

			if not self._filter_down then
				self._filter_down = self._panels.filters:text({
					vertical = "top",
					alpha = 1,
					align = "right",
					layer = 1,
					text = managers.localization:get_default_macro("BTN_TOP_R"),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					color = tweak_data.screen_colors.text,
					x = padding,
					y = padding
				})

				make_fine_text(self._filter_down)
			end

			self._filter_down:set_right(self._panels.filters:w() - 4)
			self._filter_down:set_top(self._filter_buttons[#self._filter_buttons]:bottom())
			self._filter_down:set_visible(true)
		else
			if self._filter_up then
				self._filter_up:set_visible(false)
			end

			if self._filter_down then
				self._filter_down:set_visible(false)
			end
		end
	end

	if managers.menu:is_pc_controller() and not self._search then
		local search_panel = self._panel:panel({
			alpha = 1,
			layer = 2,
			h = tweak_data.menu.pd2_medium_font_size
		})

		search_panel:set_w(256)
		search_panel:set_top(self._panels.main:bottom() + 4)
		search_panel:set_left(self._panels.main:left())

		local search_placeholder = search_panel:text({
			vertical = "top",
			align = "center",
			alpha = 0.6,
			layer = 2,
			text = managers.localization:to_upper_text("menu_filter_search"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text
		})
		local search_text = search_panel:text({
			vertical = "top",
			alpha = 1,
			align = "center",
			text = "",
			layer = 2,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text,
			w = search_panel:w() - 3
		})
		local caret = search_panel:rect({
			name = "caret",
			h = 0,
			y = 0,
			w = 0,
			x = 0,
			layer = 200,
			color = Color(0.05, 1, 1, 1)
		})

		caret:set_right(search_panel:w() * 0.5)
		search_panel:rect({
			layer = -1,
			color = Color.black:with_alpha(0.25)
		})
		BoxGuiObject:new(search_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		self._search = {
			panel = search_panel,
			placeholder = search_placeholder,
			text = search_text,
			caret = caret
		}
	end
end

function ContractBrokerGui:_add_filter_button(text_id, y, params)
	local text = self._panels.filters:text({
		vertical = "top",
		align = "right",
		alpha = 1,
		layer = 2,
		text = managers.localization:to_upper_text(text_id),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})

	make_fine_text(text)
	text:set_w(self._panels.filters:w())
	text:set_h(tweak_data.menu.pd2_small_font_size + (params and params.extra_h or 0))
	text:set_y(y)
	text:set_right(self._panels.filters:w() - 4)
	table.insert(self._buttons, {
		type = "filter",
		element = text
	})
	table.insert(self._filter_buttons, text)

	return text
end

function ContractBrokerGui:_setup_filter_none()
end

function ContractBrokerGui:_setup_filter_contact()
	local contacts = {}
	local filters = {}

	for index, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		local job_tweak = tweak_data.narrative:job_data(job_id)
		local contact = job_tweak.contact
		local contact_tweak = tweak_data.narrative.contacts[contact]

		if contact then
			local allow_contact = true
			allow_contact = not table.contains(contacts, contact) and (not contact_tweak or not contact_tweak.hidden)

			if allow_contact then
				table.insert(contacts, contact)
				table.insert(filters, {
					id = contact,
					data = contact_tweak
				})
			end
		end
	end

	table.sort(filters, function (a, b)
		return managers.localization:to_upper_text(a.data.name_id) < managers.localization:to_upper_text(b.data.name_id)
	end)

	local last_y = 0

	for _, contact in ipairs(filters) do
		local text = self:_add_filter_button(contact.data.name_id, last_y)
		last_y = text:bottom() + 1
	end

	self._contact_filter_list = filters

	self:add_filter("contact", ContractBrokerGui.perform_filter_contact)
	self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
end

function ContractBrokerGui:_setup_filter_time()
	local times = {
		{
			"menu_filter_heist_short"
		},
		{
			"menu_filter_heist_medium"
		},
		{
			"menu_filter_heist_long"
		}
	}
	local last_y = 0

	for _, filter in ipairs(times) do
		local text = self:_add_filter_button(filter[1], last_y, {
			extra_h = 4
		})
		last_y = text:bottom() + 1
	end

	self:add_filter("job_id", ContractBrokerGui.perform_filter_time)
	self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
end

function ContractBrokerGui:_setup_filter_tactic()
	local tactics = {
		{
			"menu_filter_tactic_loud_only"
		},
		{
			"menu_filter_tactic_stealth_only"
		},
		{
			"menu_filter_tactic_stealthable"
		}
	}
	local last_y = 0

	for _, filter in ipairs(tactics) do
		local text = self:_add_filter_button(filter[1], last_y)
		last_y = text:bottom() + 1
	end

	self:add_filter("job", ContractBrokerGui.perform_filter_tactic)
	self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
end

function ContractBrokerGui:_setup_filter_most_played()
	local played = {
		{
			"menu_filter_most_played"
		},
		{
			"menu_filter_least_played"
		}
	}
	local last_y = 0

	for _, filter in ipairs(played) do
		local text = self:_add_filter_button(filter[1], last_y)
		last_y = text:bottom() + 1
	end

	self:set_sorting_function(ContractBrokerGui.perform_most_played_sort)
end

function ContractBrokerGui:_setup_filter_favourite()
	self._favourite_jobs = managers.crimenet:get_favourite_jobs()

	self:add_filter("job_id", ContractBrokerGui.perform_filter_favourites)
	self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
end

function ContractBrokerGui:perform_filter_contact(value)
	return value == (self._contact_filter_list[self._current_filter] or self._contact_filter_list[1] or {}).id
end

function ContractBrokerGui:perform_filter_time(value)
	local job_tweak = tweak_data.narrative:job_data(value)

	if job_tweak.job_wrapper then
		job_tweak = tweak_data.narrative.jobs[job_tweak.job_wrapper[1]]

		return (job_tweak and job_tweak.chain and table.size(job_tweak.chain) or 1) == self._current_filter
	else
		return table.size(job_tweak.chain) == self._current_filter
	end
end

function ContractBrokerGui:perform_filter_tactic(job_tweak, wrapped_tweak)
	local allow = false
	local chain = wrapped_tweak and wrapped_tweak.chain or job_tweak.chain

	for _, data in ipairs(chain) do
		local level_data = tweak_data.levels[data.level_id]

		if level_data then
			if self._current_filter == 1 then
				allow = allow or level_data.ghost_bonus == nil
			elseif self._current_filter == 2 then
				allow = allow or level_data.ghost_required or level_data.ghost_required_visual
			elseif self._current_filter == 3 then
				allow = allow or level_data.ghost_bonus ~= nil
			end
		end
	end

	return allow
end

function ContractBrokerGui:perform_filter_favourites(value)
	return self._favourite_jobs[value] == true
end

function ContractBrokerGui:perform_filter_search(job_tweak)
	if self._search and alive(self._search.text) then
		local search_text = string.lower(self._search.text:text())

		if #search_text > 0 then
			local job_name = string.lower(managers.localization:text(job_tweak.name_id or "no name_id"))

			if string.find(job_name, search_text, nil, true) then
				return true
			end

			local contact_tweak = tweak_data.narrative.contacts[job_tweak.contact]

			if contact_tweak then
				local contact_name = string.lower(managers.localization:text(contact_tweak.name_id or "no name_id"))

				if string.find(contact_name, search_text, nil, true) then
					return true
				end
			end

			return false
		end
	end

	return true
end

function ContractBrokerGui.perform_standard_sort(x, y)
	if x.enabled ~= y.enabled then
		return x.enabled
	end

	if x.is_new and y.is_new then
		if x.date_value ~= y.date_value then
			return x.date_value < y.date_value
		end
	elseif x.is_new and not y.is_new then
		return true
	elseif not x.is_new and y.is_new then
		return false
	end

	local job_tweak_x = tweak_data.narrative:job_data(x.job_id)
	local job_tweak_y = tweak_data.narrative:job_data(y.job_id)
	local string_x = managers.localization:to_upper_text(job_tweak_x.name_id)
	local string_y = managers.localization:to_upper_text(job_tweak_y.name_id)
	local ids_x = Idstring(string_x)
	local ids_y = Idstring(string_y)

	if ids_x ~= ids_y then
		return string_x < string_y
	end

	if job_tweak_x.jc ~= job_tweak_y.jc then
		return job_tweak_x.jc <= job_tweak_y.jc
	end

	return false
end

function ContractBrokerGui.perform_most_played_sort(x, y)
	local x_played = managers.crimenet:get_job_times_played(x.job_id)
	local y_played = managers.crimenet:get_job_times_played(y.job_id)

	if x_played ~= y_played then
		if not managers.menu_component:contract_broker_gui() or managers.menu_component:contract_broker_gui()._current_filter == 1 then
			return y_played < x_played
		else
			return x_played < y_played
		end
	else
		return ContractBrokerGui.perform_standard_sort(x, y)
	end
end

function ContractBrokerGui:clear_filters()
	self._active_filters = {}
	self._current_filter = 1
end

function ContractBrokerGui:add_filter(key, pass_func)
	self._active_filters[key] = pass_func
end

function ContractBrokerGui:remove_filter(key)
	self._active_filters[key] = nil
end

function ContractBrokerGui:set_sorting_function(sort_func)
	self._sorting_func = sort_func
end

function ContractBrokerGui:_setup_jobs()
	local date_value = {
		tonumber(os.date("%Y")),
		tonumber(os.date("%m")),
		tonumber(os.date("%d"))
	}
	date_value = date_value[1] * 30 * 12 + date_value[2] * 30 + date_value[3]
	local release_window = 7

	if alive(self._jobs_spacer) then
		self._panels.canvas:remove(self._jobs_spacer)
	end

	for _, item in ipairs(self._heist_items) do
		item:destroy()
	end

	self._heist_items = {}

	self._panels.scroll:scroll_to(0)

	local jobs = {}
	local max_jc = managers.job:get_max_jc_for_player()

	for index, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		local job_tweak = tweak_data.narrative:job_data(job_id)
		local wrapped_tweak = nil

		if job_tweak.job_wrapper then
			wrapped_tweak = tweak_data.narrative.jobs[job_tweak.job_wrapper[1]]
		end

		local filter_pass = true
		local contact_pass = true
		local contact = job_tweak.contact
		local contact_tweak = tweak_data.narrative.contacts[contact]

		if contact then
			contact_pass = true
			contact_pass = not contact_tweak or not contact_tweak.hidden
		end

		if self._search_filter_visible and self._current_filter == #self._filter_buttons then
			if not self:perform_filter_search(job_tweak) then
				filter_pass = false
			end
		else
			for key, pass_func in pairs(self._active_filters) do
				if key == "search" then
					if not pass_func(self, job_tweak) then
						filter_pass = false

						break
					end
				elseif key == "job" then
					if not pass_func(self, job_tweak, wrapped_tweak) then
						filter_pass = false

						break
					end
				elseif key == "job_id" then
					if not pass_func(self, job_id) then
						filter_pass = false

						break
					end
				elseif job_tweak[key] then
					if not pass_func(self, job_tweak[key]) then
						filter_pass = false

						break
					end
				else
					filter_pass = false

					break
				end
			end
		end

		if filter_pass and contact_pass and not tweak_data.narrative:is_wrapped_to_job(job_id) then
			local dlc = job_tweak.dlc
			dlc = not dlc or managers.dlc:is_dlc_unlocked(dlc)
			dlc = dlc and not tweak_data.narrative:is_job_locked(job_id)
			local date_value = job_tweak.date_added and job_tweak.date_added[1] * 30 * 12 + job_tweak.date_added[2] * 30 + job_tweak.date_added[3] - date_value or false

			table.insert(jobs, {
				job_id = job_id,
				enabled = dlc and max_jc >= (job_tweak.jc or 0) + (job_tweak.professional and 10 or 0),
				date_value = date_value,
				is_new = date_value ~= false and date_value >= -release_window
			})
		end
	end

	table.sort(jobs, self._sorting_func)

	for idx, job in ipairs(jobs) do
		local item = ContractBrokerHeistItem:new(self._panels.canvas, job, idx)

		table.insert(self._heist_items, item)
	end

	if #self._heist_items > 0 then
		self._jobs_spacer = self._panels.canvas:panel({
			y = self._heist_items[#self._heist_items]._panel:bottom(),
			h = padding
		})
	end

	self._panels.scroll:update_canvas_size()
	self._panels.scroll:update_canvas_size()
end

function ContractBrokerGui:update(t, dt)
	local cx, cy = managers.menu_component:get_right_controller_axis()

	if cy ~= 0 and self._panels.scroll then
		self._panels.scroll:perform_scroll(math.abs(cy * 500 * dt), math.sign(cy))
	end
end

function ContractBrokerGui:refresh()
	if self._filter_buttons[self._current_filter] then
		self._filter_selection_bg:set_y(self._filter_buttons[self._current_filter]:y())
		self._filter_selection_bg:set_visible(true)
	else
		self._filter_selection_bg:set_visible(false)
	end

	for idx, btn in ipairs(self._filter_buttons) do
		if idx == self._current_filter then
			btn:set_color(tweak_data.screen_colors.button_stage_2)
			btn:set_blend_mode("add")
		else
			btn:set_color(tweak_data.screen_colors.button_stage_3)
			btn:set_blend_mode("normal")
		end
	end

	for idx, btn in ipairs(self._tab_buttons) do
		if idx == self._current_tab then
			btn:set_alpha(1)
		else
			btn:set_alpha(0.7)
		end
	end
end

function ContractBrokerGui:_move_selection(dir)
	self:_set_selection((self._current_selection or 0) + dir)
	self:disconnect_search_input()
end

function ContractBrokerGui:_set_selection(idx)
	local last_selection = self._current_selection
	self._current_selection = math.clamp(idx, 1, #self._heist_items)
	local last_heist = last_selection and self._heist_items[last_selection]

	if last_heist then
		last_heist:deselect()
	end

	local new_heist = self._current_selection and self._heist_items[self._current_selection]

	if new_heist then
		new_heist:select()

		local scroll_panel = self._panels.scroll:scroll_panel()
		local y = self._panels.scroll:canvas():y() + new_heist:bottom()

		if scroll_panel:h() < y then
			self._panels.scroll:perform_scroll(y - scroll_panel:h(), -1)
		else
			y = self._panels.scroll:canvas():y() + new_heist:top()

			if y < 0 then
				self._panels.scroll:perform_scroll(math.abs(y), 1)
			end
		end
	end
end

function ContractBrokerGui:mouse_moved(button, x, y)
	local used, pointer = nil

	if not used then
		local u, p = self._panels.scroll:mouse_moved(button, x, y)

		if u then
			used = u
			pointer = p or pointer
		end
	end

	if self._filter_buttons[self._current_filter] then
		self._filter_selection_bg:set_y(self._filter_buttons[self._current_filter]:y())
		self._filter_selection_bg:set_visible(true)
	else
		self._filter_selection_bg:set_visible(false)
	end

	for idx, btn in ipairs(self._filter_buttons) do
		if not used and self._current_filter ~= idx and btn:inside(x, y) then
			pointer = "link"
			used = true

			btn:set_color(tweak_data.screen_colors.button_stage_2)
			btn:set_blend_mode("add")
			self._filter_selection_bg:set_y(btn:y())

			if self._highlighted_filter ~= idx then
				self._highlighted_filter = idx

				managers.menu:post_event("highlight")
			end
		elseif idx == self._current_filter then
			btn:set_color(tweak_data.screen_colors.button_stage_2)
			btn:set_blend_mode("add")
		else
			btn:set_color(tweak_data.screen_colors.button_stage_3)
			btn:set_blend_mode("normal")
		end
	end

	for idx, btn in ipairs(self._tab_buttons) do
		if not used and self._current_tab ~= idx and btn:inside(x, y) then
			pointer = "link"
			used = true

			btn:set_alpha(1)

			if self._highlighted_tab ~= idx then
				self._highlighted_tab = idx

				managers.menu:post_event("highlight")
			end
		elseif idx == self._current_tab then
			btn:set_alpha(1)
		else
			btn:set_alpha(0.7)
		end
	end

	if self._panels.main:inside(x, y) then
		for _, item in ipairs(self._heist_items) do
			local u, p = item:mouse_moved(button, x, y, used)

			if u then
				used = u
				pointer = p or pointer
			end
		end
	else
		for _, item in ipairs(self._heist_items) do
			item:deselect()
		end
	end

	if self._search and alive(self._search.panel) and not used and self._search.panel:inside(x, y) then
		used = true
		pointer = "link"
	end

	if alive(self._back_button) then
		if not used and self._back_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._back_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._back_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._back_button:set_blend_mode("add")
			end
		else
			self._back_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._back_button:set_blend_mode("normal")
		end
	end

	return used, pointer
end

function ContractBrokerGui:mouse_clicked(o, button, x, y)
	self:disconnect_search_input()

	if self._scroll_event then
		self._scroll_event = nil

		return
	end

	if self._panels.scroll:mouse_clicked(o, button, x, y) then
		self._scroll_event = true

		return true
	end

	for idx, btn in ipairs(self._filter_buttons) do
		if self._current_filter ~= idx and btn:inside(x, y) then
			self._current_filter = idx

			self:_setup_change_filter()
			managers.menu:post_event("menu_enter")

			return true
		end
	end

	for idx, btn in ipairs(self._tab_buttons) do
		if self._current_tab ~= idx and btn:inside(x, y) then
			self._current_tab = idx

			self:_setup_change_tab()
			managers.menu:post_event("menu_enter")

			return true
		end
	end

	if self._panels.main:inside(x, y) then
		for _, item in ipairs(self._heist_items) do
			if item:mouse_clicked(o, button, x, y) then
				return true
			end
		end
	end

	if self._search and alive(self._search.panel) and self._search.panel:inside(x, y) then
		self:connect_search_input()

		return true
	end

	if alive(self._back_button) and self._back_button:inside(x, y) then
		managers.menu:back()

		return true
	end
end

function ContractBrokerGui:mouse_pressed(button, x, y)
	if self._panels.scroll:mouse_pressed(button, x, y) then
		self._scroll_event = true

		return true
	end
end

function ContractBrokerGui:mouse_released(button, x, y)
	if self._panels.scroll:mouse_released(button, x, y) then
		self._scroll_event = true

		return true
	end
end

function ContractBrokerGui:confirm_pressed()
	if self._search_focus then
		return
	end

	local item = self._current_selection and self._heist_items[self._current_selection]

	if item then
		item:trigger()
	end
end

function ContractBrokerGui:back_pressed()
	if self._search_focus then
		return
	end

	managers.menu:back(true)
end

local ids_cancel = Idstring("cancel")
local ids_favourite = Idstring("menu_toggle_legends")
local ids_trigger_left = Idstring("trigger_left")
local ids_trigger_right = Idstring("trigger_right")

function ContractBrokerGui:special_btn_pressed(button)
	if self._search_focus then
		return
	end

	if button == ids_cancel then
		managers.menu:back(true)
	elseif button == ids_favourite then
		local item = self._current_selection and self._heist_items[self._current_selection]

		if item then
			item:toggle_favourite()
		end
	elseif button == ids_trigger_right then
		local num_filters = #self._filter_buttons

		if num_filters > 1 then
			self._current_filter = self._current_filter + 1

			if num_filters < self._current_filter then
				self._current_filter = 1
			end

			self:_setup_change_filter()
			managers.menu:post_event("menu_enter")
		end
	elseif button == ids_trigger_left then
		local num_filters = #self._filter_buttons

		if num_filters > 1 then
			self._current_filter = self._current_filter - 1

			if self._current_filter < 1 then
				self._current_filter = num_filters
			end

			self:_setup_change_filter()
			managers.menu:post_event("menu_enter")
		end
	end
end

function ContractBrokerGui:move_up()
	self:_move_selection(-1)
end

function ContractBrokerGui:move_down()
	self:_move_selection(1)
end

function ContractBrokerGui:next_page()
	self._current_tab = self._current_tab + 1

	if self._current_tab > #self._tab_buttons then
		self._current_tab = 1
	end

	self:_setup_change_tab()
	managers.menu:post_event("menu_enter")
end

function ContractBrokerGui:previous_page()
	self._current_tab = self._current_tab - 1

	if self._current_tab < 1 then
		self._current_tab = #self._tab_buttons
	end

	self:_setup_change_tab()
	managers.menu:post_event("menu_enter")
end

function ContractBrokerGui:mouse_wheel_up(x, y)
	self._panels.scroll:scroll(x, y, 1)
end

function ContractBrokerGui:mouse_wheel_down(x, y)
	self._panels.scroll:scroll(x, y, -1)
end

function ContractBrokerGui:input_focus()
	return 1
end

function ContractBrokerGui:save_temporary_data(job_id)
	Global.contract_broker = {
		filter = self._current_filter,
		tab = self._current_tab,
		job_id = job_id
	}
end

function ContractBrokerGui:connect_search_input()
	if not self._search_focus then
		self._ws:connect_keyboard(Input:keyboard())

		if _G.IS_VR then
			Input:keyboard():show_with_text(self._search.text:text())
		end

		self._search.panel:key_press(callback(self, self, "search_key_press"))
		self._search.panel:key_release(callback(self, self, "search_key_release"))

		self._enter_callback = callback(self, self, "enter_key_callback")
		self._esc_callback = callback(self, self, "esc_key_callback")
		self._search_focus = true
		self._focus = true

		self:update_caret()
	end
end

function ContractBrokerGui:disconnect_search_input()
	if self._search_focus then
		self._ws:disconnect_keyboard()
		self._search.panel:key_press(nil)
		self._search.panel:key_release(nil)

		self._search_focus = nil
		self._focus = nil

		self:update_caret()
	end
end

function ContractBrokerGui:search_key_press(o, k)
	if self._skip_first then
		self._skip_first = false

		return
	end

	if not self._enter_text_set then
		self._search.panel:enter_text(callback(self, self, "enter_text"))

		self._enter_text_set = true
	end

	local text = self._search.text
	local s, e = text:selection()
	local n = utf8.len(text:text())
	local d = math.abs(e - s)
	self._key_pressed = k

	text:stop()
	text:animate(callback(self, self, "update_key_down"), k)

	local len = utf8.len(text:text())

	text:clear_range_color(0, len)

	if k == Idstring("backspace") then
		if s == e and s > 0 then
			text:set_selection(s - 1, e)
		end

		text:replace_text("")
	elseif k == Idstring("delete") then
		if s == e and s < n then
			text:set_selection(s, e + 1)
		end

		text:replace_text("")
	elseif k == Idstring("insert") then
		local clipboard = Application:get_clipboard() or ""

		text:replace_text(clipboard)

		local lbs = text:line_breaks()

		if ContractBrokerGui.MAX_SEARCH_LENGTH < #text:text() then
			text:set_text(string.sub(text:text(), 1, ContractBrokerGui.MAX_SEARCH_LENGTH))
		end

		if #lbs > 1 then
			local s = lbs[2]
			local e = utf8.len(text:text())

			text:set_selection(s, e)
			text:replace_text("")
		end
	elseif k == Idstring("left") then
		if s < e then
			text:set_selection(s, s)
		elseif s > 0 then
			text:set_selection(s - 1, s - 1)
		end
	elseif k == Idstring("right") then
		if s < e then
			text:set_selection(e, e)
		elseif s < n then
			text:set_selection(s + 1, s + 1)
		end
	elseif self._key_pressed == Idstring("end") then
		text:set_selection(n, n)
	elseif self._key_pressed == Idstring("home") then
		text:set_selection(0, 0)
	elseif k == Idstring("enter") then
		if type(self._enter_callback) ~= "number" then
			self._enter_callback()
		end
	elseif k == Idstring("esc") and type(self._esc_callback) ~= "number" then
		if not _G.IS_VR then
			text:set_text("")
			text:set_selection(0, 0)
		end

		self._esc_callback()
	end

	self:update_caret()
end

function ContractBrokerGui:search_key_release(o, k)
	if self._key_pressed == k then
		self._key_pressed = false

		self:_setup_change_search()
	end
end

function ContractBrokerGui:update_key_down(o, k)
	wait(0.6)

	local text = self._search.text

	while self._key_pressed == k do
		local s, e = text:selection()
		local n = utf8.len(text:text())
		local d = math.abs(e - s)

		if self._key_pressed == Idstring("backspace") then
			if s == e and s > 0 then
				text:set_selection(s - 1, e)
			end

			text:replace_text("")
		elseif self._key_pressed == Idstring("delete") then
			if s == e and s < n then
				text:set_selection(s, e + 1)
			end

			text:replace_text("")
		elseif self._key_pressed == Idstring("insert") then
			local clipboard = Application:get_clipboard() or ""

			text:replace_text(clipboard)

			if ContractBrokerGui.MAX_SEARCH_LENGTH < #text:text() then
				text:set_text(string.sub(text:text(), 1, ContractBrokerGui.MAX_SEARCH_LENGTH))
			end

			local lbs = text:line_breaks()

			if #lbs > 1 then
				local s = lbs[2]
				local e = utf8.len(text:text())

				text:set_selection(s, e)
				text:replace_text("")
			end
		elseif self._key_pressed == Idstring("left") then
			if s < e then
				text:set_selection(s, s)
			elseif s > 0 then
				text:set_selection(s - 1, s - 1)
			end
		elseif self._key_pressed == Idstring("right") then
			if s < e then
				text:set_selection(e, e)
			elseif s < n then
				text:set_selection(s + 1, s + 1)
			end
		else
			self._key_pressed = false
		end

		self:update_caret()
		wait(0.03)
	end
end

function ContractBrokerGui:enter_text(o, s)
	if self._skip_first then
		self._skip_first = false

		return
	end

	local text = self._search.text

	if #text:text() < ContractBrokerGui.MAX_SEARCH_LENGTH then
		if _G.IS_VR then
			text:set_text(s)
		else
			text:replace_text(s)
		end
	end

	local lbs = text:line_breaks()

	if #lbs > 1 then
		local s = lbs[2]
		local e = utf8.len(text:text())

		text:set_selection(s, e)
		text:replace_text("")
	end

	self:update_caret()
	self:_setup_change_search()
end

function ContractBrokerGui:enter_key_callback()
	self:_setup_change_search()
end

function ContractBrokerGui:esc_key_callback()
	self:disconnect_search_input()
end

function ContractBrokerGui.blink(o)
	while true do
		o:set_color(Color(0, 1, 1, 1))
		wait(0.3)
		o:set_color(Color.white)
		wait(0.3)
	end
end

function ContractBrokerGui:set_blinking(b)
	local caret = self._search.caret

	if b == self._blinking then
		return
	end

	if b then
		caret:animate(self.blink)
	else
		caret:stop()
	end

	self._blinking = b

	if not self._blinking then
		caret:set_color(Color.white)
	end
end

function ContractBrokerGui:update_caret()
	local text = self._search.text
	local caret = self._search.caret
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()
	local text_s = text:text()

	if #text_s == 0 then
		if text:align() == "center" then
			x = text:world_x() + text:w() / 2
		else
			x = text:world_x() + text:w()
		end

		y = text:world_y()
	end

	h = text:h()

	if w < 3 then
		w = 3
	end

	if not self._focus then
		w = 0
		h = 0
	end

	caret:set_world_shape(x, y + 2, w, h - 4)
	self:set_blinking(s == e and self._focus)
	self._search.placeholder:set_visible(#text_s == 0)
end
