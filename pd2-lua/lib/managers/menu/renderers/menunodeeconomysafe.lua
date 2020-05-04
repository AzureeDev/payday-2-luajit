MenuNodeEconomySafe = MenuNodeEconomySafe or class(MenuNodeBaseGui)

function MenuNodeEconomySafe:init(node, layer, parameters)
	MenuNodeEconomySafe.super.init(self, node, layer, parameters)

	local safe_entry = node:parameters().safe_entry

	if node:parameters().debug then
		local function f()
			self:_test_start_open_economy_safe(safe_entry)
		end

		managers.menu_scene:create_economy_safe_scene(safe_entry, f)
	else
		managers.menu_scene:start_open_economy_safe()
	end

	self:_build_raffle_panel(safe_entry)
	managers.music:post_event("stop_all_music")
	managers.environment_controller:set_dof_setting("standard")
	managers.environment_controller:set_dof_distance(600, true)

	local stored_safe_result = managers.menu_scene:fetch_safe_result()

	if stored_safe_result then
		self:_safe_result_recieved(unpack(stored_safe_result))
	end
end

function MenuNodeEconomySafe:_test_start_open_economy_safe(safe_entry)
	MenuNodeEconomySafe.reward_unlock_request_id = (MenuNodeEconomySafe.reward_unlock_request_id or 0) + 1

	managers.network.account:inventory_reward_unlock(safe_entry, nil, nil, callback(self, self, "_test_safe_result_recieved", MenuNodeEconomySafe.reward_unlock_request_id))

	local function ready_clbk()
		print("ECONOMY SAFE READY CALLBACK")
	end

	managers.menu_scene:start_open_economy_safe(safe_entry, ready_clbk)
end

function MenuNodeEconomySafe:_test_safe_result_recieved(request_id, ...)
	if request_id ~= MenuNodeEconomySafe.reward_unlock_request_id then
		return
	end

	if not alive(self._raffle_panel) then
		return
	end

	self:_safe_result_recieved(...)
end

function MenuNodeEconomySafe:_safe_result_recieved(error, items_new, items_removed)
	if error then
		managers.menu:set_cash_safe_scene_done(true)

		local function ok_func()
			managers.menu:back(true)
		end

		managers.menu:show_safe_error_dialog({
			string_id = "dialog_failed_open_safe",
			ok_button = ok_func
		})

		return
	end

	local load_start_time = Application:time()
	local result = items_new[1]

	print("result.category: ", result.category, tweak_data.economy[result.category], tweak_data.blackmarket[result.category])

	local entry_data = (tweak_data.economy[result.category] or tweak_data.blackmarket[result.category])[result.entry]

	if entry_data.rarity ~= "legendary" and entry_data.rarity ~= "epic" then
		managers.menu:set_cash_safe_scene_done(true, true)
	end

	managers.mission:call_global_event(Message.OnSafeOpened, result)
	print("B: RESULT RECIEVED", result.weapon_skin, Application:time())

	local function ready_clbk()
		if not alive(self._raffle_panel) then
			return
		end

		print("READY CALLBACK")

		local function stopped_clbk()
			print("stopped_clbk")

			self._raffle_panel_alpha_target = 0

			managers.menu_scene:create_safe_content(callback(self, self, "_build_result_panel"))
		end

		local j, steps = self:_find_replace_raffle_panel()

		print("replace", j)
		print("steps", steps)
		self:_replace_raffle_panel_at(j, result)
		self:stop_at(j, steps, stopped_clbk)
	end

	self._result = result

	managers.menu_scene:load_safe_result_content(result, ready_clbk)
end

function MenuNodeEconomySafe:_find_replace_raffle_panel()
	local i, _ = self:_current_raffle_panel()
	local max_steps = 7 + math.random(5)
	local steps = 0
	local j = nil

	while steps <= max_steps do
		i = i + 1

		if i > #self._raffle_panels then
			i = 1
		end

		if self._raffle_panel:w() < self._raffle_panels[i]:x() then
			j = i
		elseif j then
			print("LIMIT TO RIGHT REACHED")

			return j, steps
		end

		steps = steps + 1

		if steps == max_steps then
			print("MAX STEPS REACHED")

			return j, steps
		end
	end
end

function MenuNodeEconomySafe._item_probability_list(item_list)
	local rarity_list = {}

	for category, items in pairs(item_list) do
		local tweak_group = tweak_data.economy[category] or tweak_data.blackmarket[category]

		for _, id in pairs(items) do
			local tweak_item = tweak_group[id]

			if tweak_item and tweak_item.rarity then
				rarity_list[tweak_item.rarity] = rarity_list[tweak_item.rarity] or {}

				if tweak_item.reserve_quality then
					local index = 0

					for quality, _ in pairs(tweak_data.economy.qualities) do
						table.insert(rarity_list[tweak_item.rarity], {
							bonus = false,
							category = category,
							entry = id,
							quality = quality
						})

						index = index + 1
					end

					for quality, _ in pairs(tweak_data.economy.qualities) do
						table.insert(rarity_list[tweak_item.rarity], {
							bonus = true,
							category = category,
							entry = id,
							quality = quality
						})

						index = index + 1
					end
				else
					table.insert(rarity_list[tweak_item.rarity], {
						category = category,
						entry = id
					})
				end
			end
		end
	end

	local total_ratio = 0
	local probability_list = {}

	for rarity, item_list in pairs(rarity_list) do
		local rarity_tweak = tweak_data.economy.rarities[rarity]

		if rarity_tweak and rarity_tweak.fake_chance then
			local current_ratio = nil
			local ratio = rarity_tweak.fake_chance / table.size(item_list)

			for _, data in pairs(item_list) do
				current_ratio = data.bonus == nil and ratio or ratio * (data.bonus and 0.1 or 0.9)
				total_ratio = total_ratio + current_ratio

				table.insert(probability_list, {
					category = data.category,
					entry = data.entry,
					quality = data.quality,
					bonus = data.bonus,
					ratio = current_ratio
				})
			end
		end
	end

	for _, data in pairs(probability_list) do
		data.ratio = data.ratio / (total_ratio / 100)
	end

	return probability_list
end

function MenuNodeEconomySafe:_build_raffle_panel(safe_entry)
	local safe_data = tweak_data.economy.safes[safe_entry]
	local drill_data = tweak_data.economy.drills[safe_data.drill]
	local content_entry = safe_data.content
	local item_list = MenuNodeEconomySafe._item_probability_list(tweak_data.economy.contents[content_entry].contains)
	local random_item_list = self:_create_random_item_list(item_list)
	self._raffle_max_speed = 1000
	self._raffle_min_speed = 2
	self._raffle_speed = self._raffle_max_speed
	self._raffle_panel_width = 180
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local res = RenderSettings.resolution
	local w_pad = 200
	local width = self._raffle_panel_width * 4.5
	local x = math.round((safe_rect_pixels.width - width) / 2)
	self._raffle_panel_alpha = 0
	self._raffle_panel_alpha_target = 1
	self._raffle_panel = self.safe_rect_panel:panel({
		h = 132,
		visible = true,
		x = x,
		y = safe_rect_pixels.height - 132,
		w = width,
		alpha = self._raffle_panel_alpha
	})

	self._raffle_panel:bitmap({
		texture = "guis/dlcs/cash/textures/pd2/safe_raffle/header_white",
		name = "",
		h = 24,
		w = self._raffle_panel:w()
	})

	local title = managers.localization:text("menu_cash_safe_overdrill_title", {
		SAFE = managers.localization:text(safe_data.name_id),
		DRILL = managers.localization:text(drill_data.name_id or "")
	})

	self._raffle_panel:text({
		halign = "left",
		vertical = "center",
		h = 24,
		name = "title",
		font_size = 20,
		align = "left",
		y = 0,
		x = 2,
		layer = 1,
		text = title,
		font = self.font,
		color = Color.black
	})
	self._raffle_panel:bitmap({
		texture = "guis/dlcs/cash/textures/pd2/safe_raffle/scroller_edges",
		name = "",
		y = 24,
		x = 0,
		layer = 18,
		w = self._raffle_panel:w(),
		h = self._raffle_panel:h() - 24
	})

	self._needle_panel = self._raffle_panel:panel({
		w = 8,
		layer = 20,
		y = 24
	})

	self._needle_panel:set_center_x(self._raffle_panel:w() / 2)
	self._needle_panel:bitmap({
		texture = "guis/dlcs/cash/textures/pd2/safe_raffle/scroller_line",
		name = "",
		y = 0,
		w = 8,
		x = 1,
		h = self._needle_panel:h()
	})

	self._raffle_panels = {}
	local j = 1

	while #random_item_list > 0 do
		local i = math.random(#random_item_list)
		local data = table.remove(random_item_list, i)
		local x = j * self._raffle_panel_width

		self:_create_raffle_panel(x, data)

		j = j + 1
	end
end

function MenuNodeEconomySafe:_create_random_item_list(item_list)
	local list = {}

	for _, data in pairs(item_list) do
		if data.category ~= "contents" then
			local amount = math.ceil(data.ratio / 1)

			for j = 1, amount do
				table.insert(list, data)
			end
		end
	end

	return list
end

function MenuNodeEconomySafe:_create_raffle_panel(x, data, index)
	local p = self._raffle_panel:panel({
		h = 108,
		y = 24,
		x = x,
		w = self._raffle_panel_width
	})
	local image_panel = p:panel({
		x = 0,
		y = 0,
		w = p:w(),
		h = p:h() - 24
	})

	image_panel:bitmap({
		texture = "guis/dlcs/cash/textures/pd2/safe_raffle/bg_black",
		name = "bg_black",
		layer = -1,
		w = image_panel:w(),
		h = image_panel:h()
	})

	index = index or #self._raffle_panels + 1

	table.insert(self._raffle_panels, index, p)

	local texture_name = nil
	local name_id = "bm_none"
	local rarity_color = Color.white
	local texture_rarity_name = "guis/dlcs/cash/textures/pd2/safe_raffle/header_col_common"
	local is_legendary = false
	local bonuses = nil

	if tweak_data.blackmarket[data.category] then
		local entry_data = tweak_data.blackmarket[data.category][data.entry]
		local weapon_id = entry_data.weapon_id or entry_data.weapons[1]
		is_legendary = entry_data.rarity == "legendary"
		texture_name = is_legendary and "guis/dlcs/cash/textures/pd2/safe_raffle/icon_legendary" or managers.blackmarket:get_weapon_icon_path(weapon_id, {
			id = data.entry
		})
		name_id = entry_data.name_id
		rarity_color = tweak_data.economy.rarities[entry_data.rarity].color
		texture_rarity_name = tweak_data.economy.rarities[entry_data.rarity].header_col

		if data.bonus and entry_data.bonus then
			bonuses = tweak_data.economy:get_bonus_icons(entry_data.bonus)
		end
	elseif tweak_data.economy[data.category] then
		local entry_data = tweak_data.economy[data.category][data.entry]
		name_id = entry_data.name_id
		texture_name = "guis/dlcs/" .. entry_data.texture_bundle_folder .. "/" .. data.category .. "/" .. data.entry
		rarity_color = tweak_data.economy.rarities[entry_data.rarity].color
		texture_rarity_name = tweak_data.economy.rarities[entry_data.rarity].header_col
	end

	local name = managers.localization:text(name_id)

	if is_legendary then
		name = managers.localization:text("bm_menu_rarity_legendary_item")
	end

	p:text({
		halign = "left",
		vertical = "top",
		name = "number",
		align = "center",
		visible = false,
		layer = 10,
		text = "" .. index,
		font_size = self.font_size,
		font = self.font
	})
	p:bitmap({
		name = "",
		h = 24,
		texture = texture_rarity_name,
		y = p:h() - 24,
		w = p:w()
	})
	p:text({
		halign = "left",
		vertical = "center",
		h = 24,
		name = "name",
		font_size = 20,
		align = "left",
		x = 8,
		layer = 10,
		text = name,
		y = p:h() - 24,
		font = self.font
	})

	if bonuses then
		local x = p:w() - 4

		for _, texture_path in ipairs(bonuses) do
			local bonus_bitmap = p:bitmap({
				name = "bonus",
				h = 16,
				w = 16,
				layer = 1,
				texture = texture_path,
				x = p:w() - 24,
				y = p:h() - 24
			})

			bonus_bitmap:set_right(x)
			bonus_bitmap:set_center_y(p:h() - 12)

			x = bonus_bitmap:left() - 1
		end
	end

	self:request_texture(texture_name, image_panel, true)
end

function MenuNodeEconomySafe:_replace_raffle_panel_at(index, data)
	local removed = table.remove(self._raffle_panels, index)
	local x = removed:x()

	self:_create_raffle_panel(x, data, index)
	removed:parent():remove(removed)
end

function MenuNodeEconomySafe:set_raffle_speed(speed)
	self._raffle_speed = speed
end

function MenuNodeEconomySafe:stop_at(at, offset, stopped_clbk)
	self._stop_data = {
		max_speed = self._raffle_speed,
		lerp_value = 0,
		at = at,
		decc = (0 - self._raffle_speed * self._raffle_speed) / 2 / 1000,
		start_time = Application:time(),
		distance = 0,
		stopped_clbk = stopped_clbk
	}
	local total_length = #self._raffle_panels * self._raffle_panels[1]:w()

	print("total_length", total_length)

	offset = offset or 16

	print("offset", offset)

	self._stop_data.offset = offset
	self._stop_data.start_stop_at = (at - offset) % #self._raffle_panels
	self._stop_data.start_stop_at = self._stop_data.start_stop_at ~= 0 and self._stop_data.start_stop_at or #self._raffle_panels

	self._raffle_panels[at]:child("number"):set_color(Color.green)
end

function MenuNodeEconomySafe:_current_raffle_panel()
	local needle_x = self._needle_panel:center_x()

	for i, panel in ipairs(self._raffle_panels) do
		if panel:x() < needle_x and needle_x < panel:right() then
			return i, panel
		end
	end
end

function MenuNodeEconomySafe:update(t, dt)
	MenuNodeEconomySafe.super.update(self, t, dt)

	if self._raffle_panel_alpha_target ~= self._raffle_panel_alpha then
		self._raffle_panel_alpha = math.step(self._raffle_panel_alpha, self._raffle_panel_alpha_target, dt / 0.5)

		self._raffle_panel:set_alpha(self._raffle_panel_alpha)
	end

	if not self._current_active_raffle_panel or self._current_active_raffle_panel ~= self:_current_raffle_panel() then
		managers.menu:post_event("cash_tick")

		self._current_active_raffle_panel = self:_current_raffle_panel()
	end

	if self._stop_data and not self._stop_data.done then
		if self._stop_data.start_stop_at then
			local i, panel = self:_current_raffle_panel()

			if i == self._stop_data.start_stop_at and panel:center_x() < self._needle_panel:center_x() then
				self._stop_data.start_stop_at = nil
				self._stop_data.deaccelerating = true
				self._stop_data.distance = 0
				local overshoot = self._needle_panel:center_x() - panel:center_x()

				print("overshoot", overshoot)

				local rand_offset = math.rand(-(self._raffle_panel_width / 2 - 1), self._raffle_panel_width / 2 - 1)
				self._stop_data.total_distance = self._stop_data.offset * self._raffle_panel_width - overshoot + rand_offset
				self._stop_data.distance_to_go = self._stop_data.total_distance

				print("distance to go", self._stop_data.distance_to_go, "rand_offset", rand_offset)
			end
		end

		if self._stop_data.deaccelerating then
			self._stop_data.lerp_value = math.min(self._stop_data.lerp_value + dt / 5, 1)
			local dist_lerp = math.lerp(self._stop_data.distance_to_go / self._stop_data.total_distance, 0, self._stop_data.lerp_value)

			if self._stop_data.lerp_value == 1 then
				-- Nothing
			end

			local bez = math.lerp(1, 0, self._stop_data.lerp_value)
			bez = math.lerp(bez, 0, 1 - bez)
			self._raffle_speed = self._stop_data.max_speed * bez
			self._raffle_speed = math.clamp(self._stop_data.distance_to_go * 1, self._raffle_min_speed, self._raffle_max_speed)
			self._stop_data.distance_to_go = self._stop_data.distance_to_go - self._raffle_speed * dt
			self._stop_data.distance = self._stop_data.distance + self._raffle_speed * dt

			if self._stop_data.distance_to_go <= 0.1 then
				self._stop_data.done = true
				self._raffle_speed = 0

				print("  ", self._stop_data.distance)
				print("DONE", Application:time() - self._stop_data.start_time)

				if self._stop_data.stopped_clbk then
					self._stop_data.stopped_clbk()
				end
			end
		end
	end

	for i = #self._raffle_panels, 1, -1 do
		local panel = self._raffle_panels[i]
		local move = true

		if panel:right() <= 0 then
			local align_i = i > 1 and i - 1 or #self._raffle_panels

			panel:set_x(self._raffle_panels[align_i]:right())

			move = i ~= 1
		end

		if move then
			panel:set_x(panel:x() - self._raffle_speed * dt)
		end
	end
end

function MenuNodeEconomySafe:_build_result_panel()
	if not alive(self._raffle_panel) then
		return
	end

	if self.safe_rect_panel:child("result_panel") then
		self.safe_rect_panel:remove(self.safe_rect_panel:child("result_panel"))
	end

	local item_data = (tweak_data.economy[self._result.category] or tweak_data.blackmarket[self._result.category])[self._result.entry]
	local rarity_data = tweak_data.economy.rarities[item_data.rarity]
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local w_pad = 200
	local width = 800
	local x = 0
	self._result_panel = self.safe_rect_panel:panel({
		name = "result_panel",
		h = 132,
		visible = true,
		x = x,
		y = safe_rect_pixels.height - 132,
		w = width
	})
	local name_text = managers.localization:text(item_data.name_id)
	local quality_data = self._result.quality and tweak_data.economy.qualities[self._result.quality] or nil
	local quality_text = quality_data and managers.localization:text(quality_data.name_id) or ""
	local result_text = managers.localization:to_upper_text("menu_cash_safe_result", {
		quality = quality_text,
		name = name_text
	})
	local name = self._result_panel:text({
		halign = "left",
		vertical = "bottom",
		name = "name",
		blend_mode = "add",
		font_size = 24,
		align = "left",
		y = 0,
		x = 2,
		layer = 1,
		text = result_text,
		font = self.font,
		color = Color.white
	})

	managers.menu_component:make_color_text(name, rarity_data.color)

	if self._result.bonus then
		local bonus_data = item_data.bonus and tweak_data.economy.bonuses[item_data.bonus]

		if bonus_data then
			local bonuses = item_data.bonus and tweak_data.economy:get_bonus_icons(item_data.bonus) or {}
			local _, _, w, h = name:text_rect()
			local bonus_bitmap = nil
			local x = w + 16

			for i = #bonuses, 1, -1 do
				local texture_path = bonuses[i]
				bonus_bitmap = self._result_panel:bitmap({
					name = "bonus",
					h = 16,
					y = 0,
					w = 16,
					x = 0,
					layer = 1,
					texture = texture_path
				})

				bonus_bitmap:set_x(x)
				bonus_bitmap:set_center_y(self._result_panel:h() - h / 2)

				x = bonus_bitmap:right() + 1
			end

			local bonus_value = bonus_data.exp_multiplier and bonus_data.exp_multiplier * 100 - 100 .. "%" or bonus_data.money_multiplier and bonus_data.money_multiplier * 100 - 100 .. "%"
			local bonus_title = bonus_data and managers.localization:to_upper_text(bonus_data.name_id, {
				team_bonus = bonus_value
			}) or ""
			local bonus_text = self._result_panel:text({
				halign = "left",
				vertical = "bottom",
				name = "bonus_text",
				blend_mode = "add",
				font_size = 24,
				align = "left",
				y = 0,
				x = 2,
				layer = 1,
				text = bonus_title,
				font = self.font,
				color = Color.white
			})

			bonus_text:set_x(bonus_bitmap:right() + 4)
		end
	end
end

function MenuNodeEconomySafe:_setup_panels(node)
	MenuNodeEconomySafe.super._setup_panels(self, node)
end

function MenuNodeEconomySafe:set_visible(visible)
	MenuNodeEconomySafe.super.set_visible(self, visible)
end

function MenuNodeEconomySafe:close(...)
	MenuNodeEconomySafe.super.close(self, ...)
	managers.environment_controller:set_dof_distance(10, false)
	managers.music:post_event(managers.music:jukebox_menu_track("mainmenu"))
	managers.menu_component:set_blackmarket_disable_fetching(false)
end

function MenuNodeEconomySafe:_test_textures()
	local t = {}

	for material, data in pairs(tweak_data.blackmarket.materials) do
		local texture_bundle_folder = data.texture_bundle_folder

		if texture_bundle_folder then
			table.insert(t, "guis/dlcs/" .. texture_bundle_folder .. "/textures/pd2/blackmarket/icons/materials/" .. material)
		else
			table.insert(t, "guis/textures/pd2/blackmarket/icons/materials/" .. material)
		end
	end

	return t
end
