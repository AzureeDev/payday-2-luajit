local padding = 10

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

ContractBrokerHeistItem = ContractBrokerHeistItem or class()

function ContractBrokerHeistItem:init(parent_panel, job_data, idx)
	self._parent = parent_panel
	self._job_data = job_data
	local job_tweak = tweak_data.narrative:job_data(job_data.job_id)
	local contact = job_tweak.contact
	local contact_tweak = tweak_data.narrative.contacts[contact]
	self._panel = parent_panel:panel({
		halign = "grow",
		layer = 10,
		h = 90,
		x = 0,
		valign = "top",
		y = 90 * (idx - 1)
	})
	self._background = self._panel:rect({
		blend_mode = "add",
		alpha = 0.4,
		halign = "grow",
		layer = -1,
		valign = "grow",
		y = padding,
		h = self._panel:h() - padding,
		color = job_data.enabled and tweak_data.screen_colors.button_stage_3 or tweak_data.screen_colors.important_1
	})

	self._background:set_visible(false)

	local img_size = self._panel:h() - padding
	self._image_panel = self._panel:panel({
		halign = "left",
		layer = 1,
		x = 0,
		valign = "top",
		y = padding,
		w = img_size * 1.7777777777777777,
		h = img_size
	})
	local has_image = false

	if job_tweak.contract_visuals and job_tweak.contract_visuals.preview_image then
		local data = job_tweak.contract_visuals.preview_image
		local path, rect = nil

		if data.id then
			path = "guis/dlcs/" .. (data.folder or "bro") .. "/textures/pd2/crimenet/" .. data.id
			rect = data.rect
		elseif data.icon then
			path, rect = tweak_data.hud_icons:get_icon_data(data.icon)
		end

		if path and DB:has(Idstring("texture"), path) then
			self._image_panel:bitmap({
				valign = "scale",
				layer = 2,
				blend_mode = "add",
				halign = "scale",
				texture = path,
				texture_rect = rect,
				w = self._image_panel:w(),
				h = self._image_panel:h(),
				color = Color.white
			})

			self._image = self._image_panel:rect({
				alpha = 1,
				layer = 1,
				color = Color.black
			})
			has_image = true
		end
	end

	if not has_image then
		local color = Color.red
		local error_message = "Missing Preview Image"

		self._image_panel:rect({
			alpha = 0.4,
			layer = 1,
			color = color
		})
		self._image_panel:text({
			vertical = "center",
			wrap = true,
			align = "center",
			word_wrap = true,
			layer = 2,
			text = error_message,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size
		})
		BoxGuiObject:new(self._image_panel:panel({
			layer = 100
		}), {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	local job_name = self._panel:text({
		layer = 1,
		vertical = "top",
		align = "left",
		halign = "left",
		valign = "top",
		text = managers.localization:to_upper_text(job_tweak.name_id),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = job_data.enabled and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1
	})

	make_fine_text(job_name)
	job_name:set_left(self._image_panel:right() + padding * 2)
	job_name:set_top(self._panel:h() * 0.5 + padding * 0.5)

	local contact_name = self._panel:text({
		alpha = 0.8,
		vertical = "top",
		layer = 1,
		align = "left",
		halign = "left",
		valign = "top",
		text = managers.localization:to_upper_text(contact_tweak.name_id),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.9,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(contact_name)
	contact_name:set_left(job_name:left())
	contact_name:set_bottom(job_name:top())

	local dlc_name, dlc_color = self:get_dlc_name_and_color(job_tweak)
	local dlc_name = self._panel:text({
		alpha = 1,
		vertical = "top",
		layer = 1,
		align = "left",
		halign = "left",
		valign = "top",
		text = dlc_name,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.9,
		color = dlc_color
	})

	make_fine_text(dlc_name)
	dlc_name:set_left(contact_name:right() + 5)
	dlc_name:set_bottom(job_name:top())

	if job_data.is_new then
		local new_name = self._panel:text({
			alpha = 1,
			vertical = "top",
			layer = 1,
			align = "left",
			halign = "left",
			valign = "top",
			text = managers.localization:to_upper_text("menu_new"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size * 0.9,
			color = Color(255, 105, 254, 59) / 255
		})

		make_fine_text(new_name)
		new_name:set_left((dlc_name:text() ~= "" and dlc_name or contact_name):right() + 5)
		new_name:set_bottom(job_name:top())
	end

	local last_played = self._panel:text({
		alpha = 0.7,
		vertical = "top",
		layer = 1,
		align = "right",
		halign = "right",
		valign = "top",
		text = self:get_last_played_text(),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.8,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(last_played)
	last_played:set_right(self._panel:right() - padding)
	last_played:set_bottom(job_name:top())

	local icons_panel = self._panel:panel({
		valign = "top",
		halign = "right",
		h = job_name:h(),
		w = self._panel:w() * 0.3
	})

	icons_panel:set_right(self._panel:right() - padding)
	icons_panel:set_top(job_name:top())

	local icon_size = icons_panel:h()
	local last_icon = nil
	self._favourite = icons_panel:bitmap({
		texture = "guis/dlcs/bro/textures/pd2/favourite",
		halign = "right",
		alpha = 0.8,
		valign = "top",
		color = Color.white,
		w = icon_size,
		h = icon_size
	})

	self._favourite:set_right(icons_panel:w())

	last_icon = self._favourite
	local day_text = icons_panel:text({
		layer = 1,
		vertical = "bottom",
		align = "right",
		halign = "right",
		valign = "top",
		text = self:get_heist_day_text(),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.9,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(day_text)
	day_text:set_right(last_icon:left() - 5)
	day_text:set_bottom(icons_panel:h())

	last_icon = day_text
	local length_icon = icons_panel:text({
		layer = 1,
		vertical = "bottom",
		align = "right",
		halign = "right",
		valign = "top",
		text = self:get_heist_day_icon(),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.8,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(length_icon)
	length_icon:set_right(last_icon:left() - padding)
	length_icon:set_top(2)

	last_icon = length_icon

	if self:is_stealthable() then
		local stealth = icons_panel:text({
			layer = 1,
			vertical = "top",
			align = "right",
			halign = "right",
			valign = "top",
			text = managers.localization:get_default_macro("BTN_GHOST"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text
		})

		make_fine_text(stealth)
		stealth:set_right(last_icon:left() - padding)

		last_icon = stealth
	end

	self:refresh()
end

function ContractBrokerHeistItem:destroy()
	self._parent:remove(self._panel)
end

function ContractBrokerHeistItem:top()
	return self._panel:top()
end

function ContractBrokerHeistItem:bottom()
	return self._panel:bottom()
end

function ContractBrokerHeistItem:get_last_played_text()
	local current_date = DateTime:new("now")
	local last_played_date = managers.crimenet:get_last_played_job(self._job_data.job_id)
	local time_str = managers.localization:to_upper_text("menu_time_never")

	if last_played_date then
		local diff = (current_date - last_played_date):value()

		if diff == 0 then
			time_str = managers.localization:to_upper_text("menu_time_today")
		elseif diff == 1 then
			time_str = managers.localization:to_upper_text("menu_time_day_ago", {
				time = diff
			})
		elseif diff < DateTime.days_per_week then
			time_str = managers.localization:to_upper_text("menu_time_days_ago", {
				time = diff
			})
		elseif diff < DateTime.days_per_week * 2 then
			time_str = managers.localization:to_upper_text("menu_time_week_ago", {
				time = math.floor(diff / DateTime.days_per_week)
			})
		elseif diff < DateTime.days_per_month then
			time_str = managers.localization:to_upper_text("menu_time_weeks_ago", {
				time = math.floor(diff / DateTime.days_per_week)
			})
		elseif diff < DateTime.days_per_month * 2 then
			time_str = managers.localization:to_upper_text("menu_time_month_ago", {
				time = math.floor(diff / DateTime.days_per_month)
			})
		elseif diff < DateTime.days_per_month * DateTime.months_per_year then
			time_str = managers.localization:to_upper_text("menu_time_months_ago", {
				time = math.floor(diff / DateTime.days_per_month)
			})
		elseif diff >= DateTime.days_per_month * DateTime.months_per_year then
			time_str = managers.localization:to_upper_text("menu_time_year_over")
		end
	end

	return managers.localization:to_upper_text("menu_broker_last_played", {
		time = time_str
	})
end

function ContractBrokerHeistItem:get_dlc_name_and_color(job_tweak)
	local dlc_name = ""
	local dlc_color = Color(1, 0, 1)

	if job_tweak.dlc then
		if not tweak_data.dlc[job_tweak.dlc] or not tweak_data.dlc[job_tweak.dlc].free then
			if job_tweak.dlc == "pd2_clan" then
				dlc_color = tweak_data.screen_colors.community_color

				if SystemInfo:distribution() == Idstring("STEAM") then
					dlc_name = managers.localization:to_upper_text("cn_menu_community")
				end
			else
				dlc_color = tweak_data.screen_colors.dlc_color
				dlc_name = managers.localization:to_upper_text("cn_menu_dlc")
			end
		end
	elseif job_tweak.competitive then
		dlc_color = tweak_data.screen_colors.competitive_color
		dlc_name = managers.localization:to_upper_text("cn_menu_competitive_job")
	end

	return dlc_name, dlc_color
end

function ContractBrokerHeistItem:is_stealthable()
	local job_tweak = tweak_data.narrative:job_data(self._job_data.job_id)

	if job_tweak.job_wrapper then
		local wrapped_tweak = tweak_data.narrative.jobs[job_tweak.job_wrapper[1]]
		job_tweak = wrapped_tweak or job_tweak
	end

	for _, data in ipairs(job_tweak.chain) do
		local level_data = tweak_data.levels[data.level_id] or {}

		if level_data and level_data.ghost_bonus or level_data.ghost_required then
			return true
		end
	end

	return false
end

function ContractBrokerHeistItem:_job_num_days()
	local job_tweak = tweak_data.narrative:job_data(self._job_data.job_id)

	if job_tweak.job_wrapper then
		job_tweak = tweak_data.narrative.jobs[job_tweak.job_wrapper[1]]

		return job_tweak and job_tweak.chain and table.size(job_tweak.chain) or 1
	else
		return table.size(job_tweak.chain)
	end
end

function ContractBrokerHeistItem:get_heist_day_text()
	local days = self:_job_num_days()

	if days == 1 then
		return managers.localization:to_upper_text("menu_broker_day", {
			days = days
		})
	else
		return managers.localization:to_upper_text("menu_broker_days", {
			days = days
		})
	end
end

function ContractBrokerHeistItem:get_heist_day_icon()
	local days = self:_job_num_days()

	if days == 1 then
		return managers.localization:get_default_macro("BTN_SPREE_SHORT")
	elseif days == 2 then
		return managers.localization:get_default_macro("BTN_SPREE_MEDIUM")
	else
		return managers.localization:get_default_macro("BTN_SPREE_LONG")
	end
end

function ContractBrokerHeistItem:refresh()
	self._favourite:set_color(managers.crimenet:is_job_favourite(self._job_data.job_id) and Color.yellow or Color.white)
end

function ContractBrokerHeistItem:select()
	if not self._selected then
		self._selected = true

		self._background:set_visible(true)

		if alive(self._image) then
			self._image:set_color(tweak_data.screen_colors.button_stage_3)
		end

		managers.menu:post_event("highlight")
	end
end

function ContractBrokerHeistItem:deselect()
	if self._selected then
		self._selected = false

		if alive(self._image) then
			self._image:set_color(Color.black)
		end

		self._background:set_visible(false)
	end
end

function ContractBrokerHeistItem:mouse_moved(button, x, y, used)
	local used = used
	local pointer = nil

	if not used and self._favourite:inside(x, y) then
		pointer = "link"
		used = true

		if not self._favourite_selected then
			self._favourite:set_alpha(1)

			self._favourite_selected = true

			managers.menu:post_event("highlight")
		end
	elseif self._favourite_selected then
		self._favourite:set_alpha(0.8)

		self._favourite_selected = false
	end

	if not used and self._background:inside(x, y) then
		self:select()

		pointer = "link"
		used = true
	else
		self:deselect()
	end

	return used, pointer
end

function ContractBrokerHeistItem:mouse_clicked(o, button, x, y)
	if self._favourite:inside(x, y) then
		self:toggle_favourite()

		return true
	end

	if self._background:inside(x, y) then
		self:trigger()

		return true
	end
end

function ContractBrokerHeistItem:trigger()
	if self._job_data and not self._job_data.enabled then
		managers.menu:post_event("menu_error")

		return
	end

	managers.menu_component:contract_broker_gui():save_temporary_data(self._job_data.job_id)

	local job_tweak = tweak_data.narrative:job_data(self._job_data.job_id)
	local is_professional = job_tweak and job_tweak.professional or false
	local is_competitive = job_tweak and job_tweak.competitive or false

	managers.menu:open_node(Global.game_settings.single_player and "crimenet_contract_singleplayer" or "crimenet_contract_host", {
		{
			customize_contract = true,
			job_id = self._job_data.job_id,
			difficulty = is_professional and "hard" or "normal",
			difficulty_id = is_professional and 3 or 2,
			professional = is_professional,
			competitive = is_competitive,
			contract_visuals = job_tweak.contract_visuals
		}
	})
end

function ContractBrokerHeistItem:toggle_favourite()
	local is_fav = managers.crimenet:is_job_favourite(self._job_data.job_id)

	managers.crimenet:set_job_favourite(self._job_data.job_id, not is_fav)
	managers.menu:post_event("menu_enter")
	self:refresh()
end
