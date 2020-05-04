local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

GageAssetsItem = GageAssetsItem or class(MissionBriefingTabItem)

function GageAssetsItem.animate_select(o, center_helper, instant)
	o:set_layer(2)

	local size = o:h()

	if size == 85 then
		return
	end

	managers.menu_component:post_event("highlight")

	local center_x, center_y = o:center()

	if alive(center_helper) then
		local center_x, center_y = center_helper:center()
	end

	if instant then
		local s = math.lerp(size, 85, 1)

		o:set_size(s, s)
		o:set_center(center_x, center_y)

		return
	end

	over(math.abs(85 - size) / 100, function (p)
		local s = math.lerp(size, 85, p)

		if alive(center_helper) then
			center_x, center_y = center_helper:center()
		end

		o:set_size(s, s)
		o:set_center(center_x, center_y)
	end)
end

function GageAssetsItem.animate_deselect(o, center_helper)
	o:set_layer(1)

	local size = o:h()

	if size == 65 then
		return
	end

	local center_x, center_y = o:center()

	if alive(center_helper) then
		local center_x, center_y = center_helper:center()
	end

	over(math.abs(65 - size) / 100, function (p)
		local s = math.lerp(size, 65, p)

		if alive(center_helper) then
			center_x, center_y = center_helper:center()
		end

		o:set_size(s, s)
		o:set_center(center_x, center_y)
	end)
end

function GageAssetsItem:init(panel, text, i)
	GageAssetsItem.super.init(self, panel, text, i)

	self._num_items = 8

	self._panel:set_w(self._main_panel:w() * self._num_items / 8)
	self._panel:set_right(self._main_panel:w())
	self:create_assets()
end

function GageAssetsItem:post_init()
	self:select_asset(1, true)

	for i = 1, #self._assets_list do
		self._panel:child("asset_" .. tostring(i)):set_rotation(0)
	end

	for i, data in ipairs(self._assets_list) do
		if managers.crime_spree:is_asset_unlocked(data.id) then
			self:_unlock_asset(i, data)
		end
	end
end

function GageAssetsItem:select(no_sound)
	GageAssetsItem.super.select(self, no_sound)
end

function GageAssetsItem:deselect()
	GageAssetsItem.super.deselect(self)
end

function GageAssetsItem:get_requested_textures()
	return self._requested_textures
end

function GageAssetsItem:create_assets()
	self._panel:clear()

	self._assets_list = {}
	self._assets = tweak_data.crime_spree.assets
	local center_y = math.round(self._panel:h() / 2) - tweak_data.menu.pd2_small_font_size
	self._asset_text_panel = self._panel:panel({
		layer = 4,
		name = "asset_text"
	})
	local sorted_assets = {}

	for id, data in pairs(self._assets) do
		table.insert(sorted_assets, {
			id = id,
			data = data
		})
	end

	table.sort(sorted_assets, function (a, b)
		return managers.localization:text(a.data.name_id) < managers.localization:text(b.data.name_id)
	end)

	local mission = managers.crime_spree:get_mission()
	local level_tweak = tweak_data.levels[mission.level.level_id]
	local stealthable = level_tweak and level_tweak.ghost_bonus
	local first_rect, rect = nil
	local i = 0
	local w = self._panel:w() / (self._num_items / 2)
	local step = w * 0.5

	for _, asset_data in pairs(sorted_assets) do
		if not asset_data.data.stealth or stealthable then
			i = i + 1
			local center_x = i * w - w * 0.5
			rect = self._panel:rect({
				w = 85,
				h = 85,
				name = "bg_rect_" .. tostring(i)
			})

			rect:hide()

			first_rect = first_rect or rect
			local center_x = math.ceil(i / 2) * w - step
			local center_y = self._panel:h() * (i % 2 > 0 and 0.295 or 0.815)
			local asset = nil
			local texture, texture_rect = tweak_data.hud_icons:get_icon_data(asset_data.data.icon)

			if texture and DB:has(Idstring("texture"), texture) then
				asset = self._panel:bitmap({
					h = 65,
					layer = 1,
					w = 65,
					valign = "top",
					name = "asset_" .. tostring(i),
					texture = texture,
					texture_rect = texture_rect,
					rotation = math.random(2) - 1.5
				})
			else
				asset = self._panel:bitmap({
					texture = "guis/textures/pd2/endscreen/what_is_this",
					h = 65,
					w = 65,
					alpha = 0,
					valign = "top",
					layer = 1,
					name = "asset_" .. tostring(i),
					rotation = math.random(2) - 1.5
				})
			end

			rect:set_center(center_x, center_y)
			rect:set_position(math.round(rect:x()), math.round(rect:y()))
			asset:set_center(rect:center())
			asset:set_position(math.round(asset:x()), math.round(asset:y()))
			asset:set_rotation(0.5)

			local lock = self._panel:bitmap({
				texture = "guis/textures/pd2/blackmarket/money_lock",
				layer = 3,
				name = "asset_lock_" .. tostring(i),
				color = tweak_data.screen_colors.item_stage_1
			})

			lock:set_center(rect:center())
			asset:set_color((asset_data.data.class and Color.black or Color.red):with_alpha(0.6))
			table.insert(self._assets_list, {
				locked = true,
				id = asset_data.id,
				data = asset_data.data,
				asset = asset
			})
		end
	end

	self._text_strings_localized = false
	self._my_asset_space = w
	self._my_left_i = 1

	if math.ceil(#self._assets_list / self._num_items) > 1 then
		self._move_left_rect = self._panel:bitmap({
			texture = "guis/textures/pd2/hud_arrow",
			h = 32,
			blend_mode = "add",
			w = 32,
			rotation = 360,
			layer = 3,
			color = tweak_data.screen_colors.button_stage_3
		})

		self._move_left_rect:set_center(0, self._panel:h() / 2)
		self._move_left_rect:set_position(math.round(self._move_left_rect:x()), math.round(self._move_left_rect:y()))
		self._move_left_rect:set_visible(false)

		self._move_right_rect = self._panel:bitmap({
			texture = "guis/textures/pd2/hud_arrow",
			h = 32,
			blend_mode = "add",
			w = 32,
			rotation = 180,
			layer = 3,
			color = tweak_data.screen_colors.button_stage_3
		})

		self._move_right_rect:set_center(self._panel:w(), self._panel:h() / 2)
		self._move_right_rect:set_position(math.round(self._move_right_rect:x()), math.round(self._move_right_rect:y()))
		self._move_right_rect:set_visible(false)
	end

	if not managers.menu:is_pc_controller() then
		local legends = {
			"menu_legend_preview_move",
			"menu_legend_select"
		}
		local t_text = ""

		for i, string_id in ipairs(legends) do
			local spacing = i > 1 and "  |  " or ""
			t_text = t_text .. spacing .. utf8.to_upper(managers.localization:text(string_id, {
				BTN_UPDATE = managers.localization:btn_macro("menu_update"),
				BTN_BACK = managers.localization:btn_macro("back")
			}))
		end

		local legend_text = self._panel:text({
			rotation = 360,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			text = t_text
		})
		local _, _, lw, lh = legend_text:text_rect()

		legend_text:set_size(lw, lh)
		legend_text:set_righttop(self._panel:w() - 5, 5)
	end

	local first_rect = self._panel:child("bg_rect_1")

	if first_rect then
		self._select_box_panel = self._panel:panel({
			visible = false,
			layer = -3
		})

		self._select_box_panel:set_shape(first_rect:shape())

		self._select_box = BoxGuiObject:new(self._select_box_panel, {
			sides = {
				2,
				2,
				2,
				2
			}
		})
	end

	self:post_init()
end

function GageAssetsItem:move_assets_left()
	self._my_left_i = math.max(self._my_left_i - 1, 1)

	self:update_asset_positions_and_text()
	managers.menu_component:post_event("menu_enter")
end

function GageAssetsItem:move_assets_right()
	self._my_left_i = math.min(self._my_left_i + 1, math.ceil(#self._assets_list / self._num_items))

	self:update_asset_positions_and_text()
	managers.menu_component:post_event("menu_enter")
end

function GageAssetsItem:update_asset_positions_and_text()
	self:update_asset_positions()

	local bg = self._panel:child("bg_rect_" .. tostring(self._asset_selected))

	if alive(bg) then
		self._asset_text_panel:set_center_x(bg:center_x())
		self._asset_text_panel:set_position(math.round(self._asset_text_panel:x()), math.round(self._asset_text_panel:y()))

		for i, asset_text in ipairs(self._asset_text_panel:children()) do
			if asset_text:world_left() < 10 then
				asset_text:set_world_left(10)
				asset_text:set_align("left")
			elseif asset_text:world_right() > self._panel:w() - 10 then
				asset_text:set_world_right(self._panel:w() - 10)
				asset_text:set_align("right")
			else
				asset_text:set_align("center")
			end
		end
	end
end

function GageAssetsItem:update_asset_positions()
	local w = self._my_asset_space

	for i, asset in pairs(self._assets_list) do
		local cx = (math.ceil(i / 2) - (self._my_left_i - 1) * self._num_items / 2) * w - w / 2
		local lock = self._panel:child("asset_lock_" .. tostring(i))

		if alive(lock) then
			lock:set_center_x(cx)
		end

		self._panel:child("bg_rect_" .. tostring(i)):set_center_x(cx)
		self._panel:child("bg_rect_" .. tostring(i)):set_left(math.round(self._panel:child("bg_rect_" .. tostring(i)):left()))
		asset.asset:set_center_x(cx)
		asset.asset:set_left(math.round(asset.asset:left()))
	end

	self._move_left_rect:set_visible(self._my_left_i > 1)
	self._move_right_rect:set_visible(self._my_left_i < math.ceil(#self._assets_list / self._num_items))

	if math.ceil(#self._assets_list / self._num_items) > 1 then
		self:set_tab_suffix(" (" .. tostring(self._my_left_i) .. "/" .. tostring(math.ceil(#self._assets_list / self._num_items)) .. ")")
	end
end

function GageAssetsItem:select_asset(i, instant)
	if self._num_items < #self._assets_list then
		if i then
			local page = math.ceil(i / self._num_items)
			self._my_left_i = page
		end

		self:update_asset_positions()
	end

	if not i then
		return
	end

	local bg = self._panel:child("bg_rect_" .. tostring(i))
	local text_string = self._assets_list[i].data.name_id
	local extra_string, extra_color = nil

	if not self._text_strings_localized then
		text_string = managers.localization:text(text_string)
	end

	text_string = text_string .. "\n"

	if self._asset_selected == i and not instant then
		return
	end

	local is_init = self._asset_selected == nil

	self:check_deselect_item()

	self._asset_selected = i
	local rect = self._panel:child("bg_rect_" .. tostring(i))

	if rect then
		self._select_box_panel:set_shape(rect:shape())
		self._select_box:create_sides(self._select_box_panel, {
			sides = {
				2,
				2,
				2,
				2
			}
		})
	end

	if self._assets_list[i].locked then
		local can_unlock, reason = managers.crime_spree:can_unlock_asset()
		extra_string = managers.localization:text("bm_cs_continental_coin_cost", {
			cost = managers.experience:cash_string(self._assets_list[i].data.cost, "")
		})
		local coins = 0
		coins = managers.custom_safehouse:coins()

		if coins < self._assets_list[i].data.cost then
			extra_string = extra_string .. "\n" .. managers.localization:text("bm_cs_not_enough_coins")
			extra_color = tweak_data.screen_colors.important_1
		end

		if not can_unlock then
			extra_string = managers.localization:text(reason or "menu_cs_ga_limit_reached")
			extra_color = tweak_data.screen_colors.important_1
		end
	end

	extra_color = extra_color or tweak_data.screen_colors.text

	self._asset_text_panel:clear()

	if text_string then
		local text = self._asset_text_panel:text({
			name = "text_string",
			align = "center",
			text = text_string,
			font_size = tweak_data.menu.pd2_small_font_size,
			font = tweak_data.menu.pd2_small_font,
			color = tweak_data.screen_colors.text
		})

		make_fine_text(text)
		text:set_top(0)
		text:set_center_x(self._asset_text_panel:w() / 2)
	end

	if extra_string then
		local last_child = self._asset_text_panel:children()[self._asset_text_panel:num_children()]
		local text = self._asset_text_panel:text({
			name = "extra_string",
			align = "center",
			text = extra_string,
			font_size = tweak_data.menu.pd2_small_font_size,
			font = tweak_data.menu.pd2_small_font,
			color = extra_color
		})

		make_fine_text(text)

		if last_child then
			text:set_top(last_child:bottom())
		end

		text:set_center_x(self._asset_text_panel:w() / 2)
	end

	self._assets_list[i].asset:stop()
	self._assets_list[i].asset:animate(self.animate_select, self._panel:child("bg_rect_" .. tostring(i)), instant)

	if alive(bg) then
		self._asset_text_panel:set_h(self._asset_text_panel:children()[self._asset_text_panel:num_children()]:bottom())
		self._asset_text_panel:set_center_x(bg:center_x())
		self._asset_text_panel:set_position(math.round(self._asset_text_panel:x()), math.round(self._asset_text_panel:y()))

		local a_left = self._asset_text_panel:left()
		local a_right = self._asset_text_panel:right()

		for i, asset_text in ipairs(self._asset_text_panel:children()) do
			asset_text:set_position(math.round(asset_text:x()), math.round(asset_text:y()))

			if a_left + asset_text:left() < 12 then
				asset_text:set_left(12 - a_left)
			elseif a_left + asset_text:right() > self._panel:w() - 12 then
				asset_text:set_right(self._panel:w() - 12 - a_left)
			end
		end
	end

	if rect then
		if i % 2 > 0 then
			self._asset_text_panel:set_top(rect:bottom())
		else
			self._asset_text_panel:set_bottom(rect:top())
		end
	end
end

function GageAssetsItem:check_deselect_item()
	if self._asset_selected and self._assets_list[self._asset_selected] then
		self._assets_list[self._asset_selected].asset:stop()
		self._assets_list[self._asset_selected].asset:animate(self.animate_deselect, self._panel:child("bg_rect_" .. tostring(self._asset_selected)))
		self._asset_text_panel:clear()
	end

	self._asset_selected = nil
end

function GageAssetsItem:mouse_moved(x, y)
	if alive(self._move_left_rect) and alive(self._move_right_rect) then
		if self._move_left_rect:visible() and self._move_left_rect:inside(x, y) then
			if not self._move_left_highlighted then
				self._move_left_highlighted = true

				self._move_left_rect:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
				self:check_deselect_item()
			end

			self._asset_text_panel:clear()

			return false, true
		elseif self._move_left_highlighted then
			self._move_left_rect:set_color(tweak_data.screen_colors.button_stage_3)

			self._move_left_highlighted = false
		end

		if self._move_right_rect:visible() and self._move_right_rect:inside(x, y) then
			if not self._move_right_highlighted then
				self._move_right_highlighted = true

				self._move_right_rect:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
				self:check_deselect_item()
			end

			self._asset_text_panel:clear()

			return false, true
		elseif self._move_right_highlighted then
			self._move_right_rect:set_color(tweak_data.screen_colors.button_stage_3)

			self._move_right_highlighted = false
		end
	end

	local selected, highlighted = GageAssetsItem.super.mouse_moved(self, x, y)

	if not self._panel:inside(x, y) or not selected then
		self:check_deselect_item()

		return selected, highlighted
	end

	self._assets_list = self._assets_list or {}
	local update_select = false

	if not self._asset_selected then
		update_select = true
	elseif self._assets_list[self._asset_selected] and not self._panel:child("bg_rect_" .. tostring(self._asset_selected)):inside(x, y) and self._assets_list[self._asset_selected].asset:visible() then
		update_select = true
	end

	if update_select then
		for i, asset in ipairs(self._assets_list) do
			if self._panel:child("bg_rect_" .. tostring(i)):inside(x, y) and asset.asset:visible() then
				update_select = false

				self:select_asset(i)

				break
			end
		end
	end

	if not update_select then
		return false, true
	end

	return selected, highlighted
end

function GageAssetsItem:mouse_pressed(button, x, y)
	local inside = GageAssetsItem.super.mouse_pressed(self, button, x, y)

	if inside == false then
		return false
	end

	if alive(self._move_left_rect) and alive(self._move_right_rect) then
		if self._move_left_rect:visible() and self._move_left_rect:inside(x, y) then
			self:move_assets_left()

			return
		end

		if self._move_right_rect:visible() and self._move_right_rect:inside(x, y) then
			self:move_assets_right()

			return
		end
	end

	if self._asset_selected and alive(self._panel:child("bg_rect_" .. tostring(self._asset_selected))) and self._panel:child("bg_rect_" .. tostring(self._asset_selected)):inside(x, y) then
		return self:_return_asset_info(self._asset_selected)
	end

	return inside
end

function GageAssetsItem:move(x, y)
	if #self._assets_list == 0 then
		return
	end

	local asset_selected = self._asset_selected
	local new_selected = self._my_left_i and (self._my_left_i - 1) * self._num_items + 1 or 1

	if asset_selected then
		local is_top = asset_selected % 2 > 0
		local step = 2 * x + (is_top and math.max(y, 0) or math.min(y, 0))
		new_selected = asset_selected + step

		if new_selected > #self._assets_list then
			local old_page = math.ceil(asset_selected / self._num_items)
			local new_page = math.ceil(new_selected / self._num_items)

			if old_page < new_page then
				new_selected = #self._assets_list
			end
		end
	end

	if new_selected >= 1 and new_selected <= #self._assets_list then
		self._asset_selected = asset_selected

		self:select_asset(new_selected)
	end
end

function GageAssetsItem:move_left()
	self:move(-1, 0)

	return

	if #self._assets_list == 0 then
		return
	end

	self._asset_selected = self._asset_selected or 0
	local new_selected = math.max(self._asset_selected - 1, 1)

	self:select_asset(new_selected)
end

function GageAssetsItem:move_up()
	self:move(0, -1)
end

function GageAssetsItem:move_down()
	self:move(0, 1)
end

function GageAssetsItem:move_right()
	self:move(1, 0)

	return

	if #self._assets_list == 0 then
		return
	end

	self._asset_selected = self._asset_selected or 0
	local new_selected = math.min(self._asset_selected + 1, #self._assets_list)

	self:select_asset(new_selected)
end

function GageAssetsItem:confirm_pressed()
	return self:_return_asset_info(self._asset_selected)
end

function GageAssetsItem:something_selected()
	return self._asset_selected and true or false
end

function GageAssetsItem:_return_asset_info(i)
	if not i or not self._assets_list[i] then
		return nil
	end

	local asset_cost = nil

	if self._assets_list[i].locked then
		local cost = self._assets_list[i].data.cost
		local coins = 0
		coins = managers.custom_safehouse:coins()

		if cost <= coins then
			asset_cost = cost
		else
			asset_cost = true
		end
	end

	return i, asset_cost
end

function GageAssetsItem:get_asset_id(i)
	return self._assets_list[i].id, true, self._assets_list[i].locked
end

function GageAssetsItem:unlock_asset_by_id(id)
	for i, data in ipairs(self._assets_list) do
		if Idstring(data.id) == Idstring(id) then
			self:_unlock_asset(i, data)
		end
	end

	self:select_asset(self._asset_selected, true)
end

function GageAssetsItem:_unlock_asset(i, asset_data)
	asset_data.locked = false

	self._assets_list[i].asset:set_color(Color.white)

	local lock = self._panel:child("asset_lock_" .. tostring(i))

	if lock then
		self._panel:remove(lock)
	end
end
