require("lib/managers/menu/WalletGuiObject")

local is_win_32 = SystemInfo:platform() == Idstring("WIN32")
local WIDTH_MULTIPLIER = is_win_32 and 0.65 or 0.5
InfamyTreeGui = InfamyTreeGui or class()

function InfamyTreeGui:init(ws, fullscreen_ws, node)
	managers.menu:active_menu().renderer.ws:hide()

	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()

	self:_setup()
	self:set_layer(1000)
end

function InfamyTreeGui:_setup()
	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end

	self._panel = self._ws:panel():panel({
		valign = "center",
		visible = true,
		layer = self._init_layer
	})
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()
	self._requested_textures = {}

	WalletGuiObject.set_wallet(self._panel)

	local title_text = self._panel:text({
		vertical = "top",
		name = "infamytree_text",
		align = "left",
		text = utf8.to_upper(managers.localization:text("menu_infamytree")),
		h = tweak_data.menu.pd2_large_font_size,
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local title_bg_text = self._fullscreen_panel:text({
		name = "infamytree_text",
		vertical = "top",
		h = 90,
		alpha = 0.4,
		align = "left",
		blend_mode = "add",
		layer = 1,
		text = utf8.to_upper(managers.localization:text("menu_infamytree")),
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	local x, y = managers.gui_data:safe_to_full_16_9(title_text:world_x(), title_text:world_center_y())

	title_bg_text:set_world_left(x)
	title_bg_text:set_world_center_y(y)
	title_bg_text:move(-13, 9)
	MenuBackdropGUI.animate_bg_text(self, title_bg_text)

	self._tree_main_panel = self._panel:panel({})

	self._tree_main_panel:set_w(math.round(self._panel:w() * WIDTH_MULTIPLIER - 10))
	self._tree_main_panel:set_h(math.round(self._panel:h() - title_text:bottom() - 70 - 4))
	self._tree_main_panel:set_top(title_text:bottom() + 2)

	self._tree_panel = self._tree_main_panel:panel({
		name = "tree_panel"
	})
	local size = math.min(self._tree_main_panel:w(), self._tree_main_panel:h())

	BoxGuiObject:new(self._tree_panel, {
		sides = {
			0,
			0,
			0,
			0
		}
	})

	self._description_panel = self._panel:panel({
		name = "description_panel"
	})

	self._description_panel:set_w(math.round(self._panel:w() * (1 - WIDTH_MULTIPLIER)))
	self._description_panel:set_h(math.round(self._panel:h() - title_text:bottom() - 70 - 4))
	self._description_panel:set_top(title_text:bottom() + 2)
	self._description_panel:set_right(self._panel:w())
	self._description_panel:text({
		vertical = "top",
		name = "description_title",
		halign = "scale",
		wrap = true,
		align = "left",
		valign = "scale",
		word_wrap = true,
		text = "",
		y = 10,
		x = 10,
		layer = 1,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})
	self._description_panel:text({
		vertical = "top",
		name = "description_warning",
		halign = "scale",
		wrap = true,
		align = "left",
		valign = "scale",
		word_wrap = true,
		text = "",
		y = 10,
		x = 10,
		layer = 1,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.important_1
	})
	self._description_panel:text({
		vertical = "top",
		name = "description_text",
		wrap = true,
		align = "left",
		valign = "scale",
		word_wrap = true,
		text = "",
		halign = "scale",
		y = 10,
		x = 10,
		layer = 1,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		h = tweak_data.menu.pd2_small_font_size + 10
	})
	BoxGuiObject:new(self._description_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local tree_rows = tweak_data.infamy.tree_rows or 3
	local tree_cols = tweak_data.infamy.tree_cols or 3
	local item_width = self._tree_panel:w() / tree_cols
	local item_height = self._tree_panel:h() / tree_rows
	self._tree_items = {}
	local x = 0
	local y = 0
	local item = nil
	local fw = math.random(item_width)
	local fh = 0
	local fhs = {}

	for i = 1, tree_cols do
		fhs[i] = i
	end

	local c = 0
	local texture_rect_x, texture_rect_y = nil

	for count = 1, tree_rows * tree_cols do
		item = {
			panel = self._tree_panel:panel({
				x = x,
				y = y,
				w = item_width,
				h = item_height
			})
		}

		table.insert(self._tree_items, item)

		if c > 0 then
			item.neighbour_left = {}
			local connector = self._tree_panel:bitmap({
				blend_mode = "add",
				texture = "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df",
				h = 16,
				alpha = 0.5,
				wrap_mode = "wrap",
				w = item_width
			})

			connector:set_texture_coordinates(Vector3(0 + fw, 0, 0), Vector3(item_width + fw, 0, 0), Vector3(0 + fw, 16, 0), Vector3(item_width + fw, 16, 0))
			connector:set_right(item.panel:center_x())
			connector:set_center_y(item.panel:center_y())

			item.neighbour_left[1] = connector
			local connector = self._tree_panel:bitmap({
				blend_mode = "add",
				texture = "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df",
				h = 16,
				alpha = 0.5,
				wrap_mode = "wrap",
				w = item_width
			})

			connector:set_texture_coordinates(Vector3(0 - fw, 0, 0), Vector3(item_width - fw, 0, 0), Vector3(0 - fw, 16, 0), Vector3(item_width - fw, 16, 0))
			connector:set_right(item.panel:center_x())
			connector:set_center_y(item.panel:center_y())

			item.neighbour_left[2] = connector
			fw = fw + item_width
			item.fw = fw
		end

		if tree_cols < count then
			item.neighbour_top = {}
			fh = fhs[c + 1]
			local connector = self._tree_panel:bitmap({
				blend_mode = "add",
				texture = "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df",
				alpha = 0.5,
				w = 16,
				wrap_mode = "wrap",
				h = item_height
			})

			connector:set_texture_coordinates(Vector3(0 + fh, 16, 0), Vector3(0 + fh, 0, 0), Vector3(item_height + fh, 16, 0), Vector3(item_height + fh, 0, 0))
			connector:set_center_x(item.panel:center_x())
			connector:set_bottom(item.panel:center_y())

			item.neighbour_top[1] = connector
			local connector = self._tree_panel:bitmap({
				blend_mode = "add",
				texture = "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df",
				alpha = 0.5,
				w = 16,
				wrap_mode = "wrap",
				h = item_height
			})

			connector:set_texture_coordinates(Vector3(0 - fh, 16, 0), Vector3(0 - fh, 0, 0), Vector3(item_height - fh, 16, 0), Vector3(item_height - fh, 0, 0))
			connector:set_center_x(item.panel:center_x())
			connector:set_bottom(item.panel:center_y())

			item.neighbour_top[2] = connector
			item.fh = fh
			fhs[c + 1] = fhs[c + 1] + item_height
		end

		x = x + item_width
		c = c + 1

		if tree_cols <= c then
			c = 0
			x = 0
			y = y + item_height
			fw = math.random(item_width)
		end
	end

	x = self._tree_panel:w() / 2 - item_width / 2
	local border_size = 2
	local size = item_height - border_size * 2
	self._owned_selected_size = math.floor(size)
	self._owned_unselected_size = math.floor(size * 0.8)
	self._unlocked_selected_size = math.floor(size * 0.9)
	self._unlocked_unselected_size = math.floor(size * 0.7)
	self._locked_selected_size = math.floor(size * 0.5)
	self._locked_unselected_size = math.floor(size * 0.4)
	local pos = item_width / 2 - size / 2
	local secret_count = 1
	local start_item = 1
	local neighbour_top, neighbour_left = nil
	local neighbour_non_alpha = 0.3

	for index, item in pairs(self._tree_items) do
		if tweak_data.infamy.tree[index] then
			if tweak_data.infamy.tree[index] == "infamy_root" then
				start_item = index
			end

			local infamy_tweak = tweak_data.infamy.items[tweak_data.infamy.tree[index]]
			local texture_rect_x = infamy_tweak.icon_xy and infamy_tweak.icon_xy[1] or 0
			local texture_rect_y = infamy_tweak.icon_xy and infamy_tweak.icon_xy[2] or 0
			item.owned = managers.infamy:owned(tweak_data.infamy.tree[index])
			item.unlocked = managers.infamy:available(tweak_data.infamy.tree[index])

			if item.neighbour_left then
				neighbour_left = index - 1

				if self._tree_items[neighbour_left] then
					item.neighbour_left[1]:set_image(item.owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
					item.neighbour_left[2]:set_image(self._tree_items[neighbour_left].owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
					item.neighbour_left[1]:set_alpha((item.owned and 1 or item.unlocked and 0.7 or 0.1) * (self._tree_items[neighbour_left].owned and 1 or 0.5))
					item.neighbour_left[2]:set_alpha((self._tree_items[neighbour_left].owned and 1 or self._tree_items[neighbour_left].unlocked and 0.7 or 0.1) * (item.owned and 1 or 0.6))
				end
			end

			if item.neighbour_top then
				neighbour_top = index - tree_cols

				if self._tree_items[neighbour_top] then
					item.neighbour_top[1]:set_image(item.owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
					item.neighbour_top[2]:set_image(self._tree_items[neighbour_top].owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
					item.neighbour_top[1]:set_alpha((item.owned and 1 or item.unlocked and 0.7 or 0.1) * (self._tree_items[neighbour_top].owned and 1 or 0.5))
					item.neighbour_top[2]:set_alpha((self._tree_items[neighbour_top].owned and 1 or self._tree_items[neighbour_top].unlocked and 0.7 or 0.1) * (item.owned and 1 or 0.6))
				end
			end

			item.select_size = item.owned and self._owned_selected_size or item.unlocked and self._unlocked_selected_size or self._locked_selected_size
			item.unselect_size = item.owned and self._owned_unselected_size or item.unlocked and self._unlocked_unselected_size or self._locked_unselected_size
			local color = item.owned and tweak_data.screen_colors.item_stage_1 or item.unlocked and tweak_data.screen_colors.item_stage_2 or tweak_data.screen_colors.item_stage_3
			local image = item.panel:bitmap({
				texture = "guis/dlcs/infamous/textures/pd2/infamous_tree/infamous_tree_atlas",
				name = "image",
				layer = 1,
				blend_mode = "add",
				w = item.unselect_size,
				h = item.unselect_size,
				texture_rect = {
					texture_rect_x * 128,
					texture_rect_y * 128,
					128,
					128
				},
				color = color
			})

			image:set_center(item.panel:w() / 2, item.panel:h() / 2)
			item.panel:text({
				name = "text",
				wrap = false,
				word_wrap = false,
				align = "center",
				visible = true,
				alpha = 0,
				text = "",
				x = 0,
				layer = 1,
				y = item_height - tweak_data.menu.pd2_small_font_size - border_size,
				w = item_width,
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size
			})

			local glow_size = size * 1.25
			local glow = item.panel:panel({
				name = "unlock_glow",
				w = glow_size,
				h = glow_size
			})

			glow:bitmap({
				texture = "guis/dlcs/infamous/textures/pd2/infamous_tree/spinner_01_df",
				name = "glow1",
				blend_mode = "add",
				halign = "scale",
				rotation = 360,
				valign = "scale",
				w = glow_size,
				h = glow_size,
				color = tweak_data.screen_colors.text
			})
			glow:bitmap({
				texture = "guis/dlcs/infamous/textures/pd2/infamous_tree/spinner_02_df",
				name = "glow2",
				blend_mode = "add",
				halign = "scale",
				rotation = 360,
				valign = "scale",
				w = glow_size,
				h = glow_size,
				color = tweak_data.screen_colors.text
			})
			glow:set_center(item.panel:w() / 2, item.panel:h() / 2)
			glow:set_visible(item.owned)
			glow:set_alpha(item.owned and 1 or item.unlocked and 0.25 or 0.25)

			item.glow_alpha = false

			local function anim_pulse_glow(o)
				local t = 0
				local old_t = 0
				local dt = 0
				local speed = math.random() * 0.1 + 0.4
				local glow1 = o:child("glow1")
				local glow2 = o:child("glow2")
				local r1 = (0.5 + math.rand(0.3)) * 95
				local r2 = -(0.5 + math.rand(0.3)) * 95

				glow1:set_alpha(1)
				glow2:set_alpha(1)

				item.glow_alpha = item.glow_alpha or o:alpha()
				local wanted_alpha = item.glow_alpha
				local wanted_size = item.unselect_size
				local cur_size = image:w()
				local neighbour_left = neighbour_left
				local neighbour_top = neighbour_top
				local connector_speed = nil
				local speed_mul = 0.75
				local cx, cy, s = nil

				while true do
					dt = coroutine.yield()
					t = (t + dt * speed) % 1
					wanted_alpha = (math.sin(t * 180) * 0.4 + 0.6) * 1 * item.glow_alpha

					o:set_alpha(math.step(o:alpha(), wanted_alpha, dt * speed * 2))
					glow1:rotate(dt * r1)
					glow2:rotate(dt * r2)

					cx, cy = glow:center()
					s = (math.sin(t * 180) * 0.1 + 0.9) * glow_size * 1.05

					glow:set_size(s, s)
					glow:set_center(cx, cy)

					if item.neighbour_left and self._tree_items[neighbour_left] then
						connector_speed = (self._tree_items[neighbour_left].unlocked and 1 or speed_mul) * (self._tree_items[neighbour_left].owned and 1 or speed_mul) * (item.unlocked and 1 or speed_mul) * (item.unlocked and 1 or speed_mul)
						item.fw = (item.fw + dt * 10 * connector_speed) % item.neighbour_left[1]:texture_width()

						item.neighbour_left[1]:set_texture_coordinates(Vector3(0 + item.fw, 0, 0), Vector3(item_width + item.fw, 0, 0), Vector3(0 + item.fw, 16, 0), Vector3(item_width + item.fw, 16, 0))
						item.neighbour_left[2]:set_texture_coordinates(Vector3(0 - item.fw, 0, 0), Vector3(item_width - item.fw, 0, 0), Vector3(0 - item.fw, 16, 0), Vector3(item_width - item.fw, 16, 0))
					end

					if item.neighbour_top and self._tree_items[neighbour_top] then
						connector_speed = (self._tree_items[neighbour_top].unlocked and 1 or speed_mul) * (self._tree_items[neighbour_top].owned and 1 or speed_mul) * (item.unlocked and 1 or speed_mul) * (item.unlocked and 1 or speed_mul)
						item.fh = (item.fh + dt * 10 * connector_speed) % item.neighbour_top[1]:texture_width()

						item.neighbour_top[1]:set_texture_coordinates(Vector3(0 + item.fh, 16, 0), Vector3(0 + item.fh, 0, 0), Vector3(item_height + item.fh, 16, 0), Vector3(item_height + item.fh, 0, 0))
						item.neighbour_top[2]:set_texture_coordinates(Vector3(0 - item.fh, 16, 0), Vector3(0 - item.fh, 0, 0), Vector3(item_height - item.fh, 16, 0), Vector3(item_height - item.fh, 0, 0))
					end

					if self._selected_item == index and item.panel:child("text"):alpha() ~= 1 then
						item.panel:child("text"):set_alpha(math.lerp(item.panel:child("text"):alpha(), 1, dt * 10))
					end

					wanted_size = self._selected_item == index and item.select_size or item.unselect_size

					if cur_size ~= wanted_size then
						cx, cy = image:center()
						cur_size = math.lerp(cur_size, wanted_size, dt * 6)
						cur_size = math.step(cur_size, wanted_size, dt * 25)

						image:set_size(cur_size, cur_size)
						image:set_center(cx, cy)
					end

					if t < old_t then
						speed = math.random() * 0.1 + 0.4
					end

					old_t = t
				end
			end

			glow:animate(anim_pulse_glow)
		else
			item.owned = false
			item.unlocked = false

			if item.neighbour_left then
				neighbour_left = index - 1

				if self._tree_items[neighbour_left] then
					item.neighbour_left[1]:set_image("guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
					item.neighbour_left[2]:set_image("guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
					item.neighbour_left[1]:set_alpha(neighbour_non_alpha * neighbour_non_alpha * neighbour_non_alpha)
					item.neighbour_left[2]:set_alpha(neighbour_non_alpha * neighbour_non_alpha * neighbour_non_alpha)
				end
			end

			if item.neighbour_top then
				neighbour_top = index - tree_cols

				if self._tree_items[neighbour_top] then
					item.neighbour_top[1]:set_image("guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
					item.neighbour_top[2]:set_image("guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
					item.neighbour_top[1]:set_alpha(neighbour_non_alpha * neighbour_non_alpha * neighbour_non_alpha)
					item.neighbour_top[2]:set_alpha(neighbour_non_alpha * neighbour_non_alpha * neighbour_non_alpha)
				end
			end

			item.panel:rect({
				blend_mode = "add",
				name = "image",
				alpha = 0,
				x = border_size,
				y = border_size,
				w = size,
				h = size
			})
			item.panel:text({
				name = "text",
				wrap = false,
				word_wrap = false,
				align = "center",
				text = "",
				x = 0,
				layer = 1,
				y = item_height - tweak_data.menu.pd2_small_font_size - border_size,
				w = item_width,
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size
			})
		end

		item.border = BoxGuiObject:new(item.panel, {
			sides = {
				0,
				0,
				0,
				0
			}
		})
	end

	local points_text = self._panel:text({
		word_wrap = false,
		name = "points",
		wrap = false,
		align = "center",
		layer = 1,
		text = utf8.to_upper(managers.localization:text("st_menu_infamy_available_points", {
			points = managers.infamy:points()
		})),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})
	local _, _, w, h = points_text:text_rect()

	points_text:set_size(self._tree_main_panel:w(), h)
	points_text:set_top(self._tree_main_panel:bottom() + 5)
	points_text:set_center_x(self._tree_panel:center_x())

	if managers.menu:is_pc_controller() then
		local back_text = self._panel:text({
			vertical = "bottom",
			name = "back_button",
			align = "right",
			blend_mode = "add",
			text = utf8.to_upper(managers.localization:text("menu_back")),
			h = tweak_data.menu.pd2_large_font_size,
			font_size = tweak_data.menu.pd2_large_font_size,
			font = tweak_data.menu.pd2_large_font,
			color = tweak_data.screen_colors.button_stage_3
		})
		local _, _, w, h = back_text:text_rect()

		back_text:set_size(w, h)
		back_text:set_position(math.round(back_text:x()), math.round(back_text:y()))
		back_text:set_right(self._panel:w())
		back_text:set_bottom(self._panel:h())

		local bg_back = self._fullscreen_panel:text({
			name = "back_button",
			vertical = "bottom",
			h = 90,
			align = "right",
			alpha = 0.4,
			blend_mode = "add",
			layer = 1,
			text = utf8.to_upper(managers.localization:text("menu_back")),
			font_size = tweak_data.menu.pd2_massive_font_size,
			font = tweak_data.menu.pd2_massive_font,
			color = tweak_data.screen_colors.button_stage_3
		})
		local x, y = managers.gui_data:safe_to_full_16_9(self._panel:child("back_button"):world_right(), self._panel:child("back_button"):world_center_y())

		bg_back:set_world_right(x)
		bg_back:set_world_center_y(y)
		bg_back:move(13, -9)
		MenuBackdropGUI.animate_bg_text(self, bg_back)
	end

	local black_rect = self._fullscreen_panel:rect({
		layer = 1,
		color = Color(0.4, 0, 0, 0)
	})
	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		layer = -1,
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h()
	})

	local function func(o)
		over(0.6, function (p)
			o:set_alpha(p)
		end)
	end

	blur:animate(func)
	self:_select_item(start_item)

	if MenuCallbackHandler:can_become_infamous() or managers.experience:current_rank() == 0 then
		local infamous_cost = managers.money:get_infamous_cost(managers.experience:current_rank() + 1)

		managers.menu:show_infamous_message(MenuCallbackHandler:can_become_infamous() and infamous_cost <= managers.money:offshore())
	end

	managers.features:announce_feature("infamy_2_0")
end

function InfamyTreeGui:_flash_item(item)
	local text = item.panel:child("text")
	local image = item.panel:child("image")
	local border = item.border

	local function flash_anim()
		local color = tweak_data.screen_colors.item_stage_1
		local lerp_color = nil

		over(0.5, function (t)
			lerp_color = math.lerp(color, tweak_data.screen_colors.important_1, math.min(1, math.sin(t * 180) * 2))

			text:set_color(lerp_color)
			image:set_color(lerp_color)
			border:set_color(lerp_color)
		end)
		text:set_color(color)
		image:set_color(color)
		border:set_color(color)
	end

	managers.menu_component:post_event("menu_error")
	item.panel:stop()
	item.panel:animate(flash_anim)
end

function InfamyTreeGui:_update_description(name, unlocked)
	local desc_title = self._description_panel:child("description_title")
	local desc_text = self._description_panel:child("description_text")
	local desc_warning = self._description_panel:child("description_warning")
	local desc_upgrade = self._description_panel:child("description_upgrade")

	if desc_upgrade then
		for i, data in pairs(self._requested_textures) do
			managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
		end

		self._requested_textures = {}

		self._description_panel:remove(desc_upgrade)
	end

	if name then
		local infamy_tweak = tweak_data.infamy.items[name]
		local params = deep_clone(infamy_tweak.desc_params)

		if infamy_tweak.upgrades and infamy_tweak.upgrades.infamous_lootdrop then
			local stars = managers.experience:level_to_stars()
			local item_pc = tweak_data.lootdrop.STARS[stars].pcs[1]
			local skip_types = {
				xp = true,
				cash = true
			}
			local droppable_items = managers.lootdrop:droppable_items(item_pc, true, skip_types)
			local items_total = 0
			local items_infamous = 0

			for type, items in pairs(droppable_items) do
				items_total = items_total + #items

				for _, item in pairs(items) do
					if item.global_value == "infamous" then
						items_infamous = items_infamous + 1
					end
				end
			end

			local _, infamous_base_chance, infamous_mod = managers.lootdrop:infamous_chance({
				disable_difficulty = true
			})
			local infamous_chance = items_total > 0 and infamous_base_chance * items_infamous / items_total or 0
			local mult = 10
			local base_text = math.floor(infamous_chance * 100 * mult + 0.5) / mult
			local buffed_text = base_text * infamy_tweak.upgrades.infamous_lootdrop
			params.base_chance = string.format("%.1f", base_text) .. "%"
			params.buffed_chance = string.format("%.1f", buffed_text) .. "%"
		end

		local title_text = utf8.to_upper(managers.localization:text(infamy_tweak.name_id))

		if infamy_tweak.add_tier then
			local index = table.get_key(tweak_data.infamy.tree, name) or 0

			if index > 0 then
				local tier = math.floor((index + 2) / InfamyTreeGui.tree_cols)
				title_text = managers.localization:to_upper_text("st_menu_tier", {
					tier = string.format("%02d", tier)
				}) .. ": " .. title_text
			end
		end

		desc_title:set_text(title_text)
		desc_warning:set_text(unlocked and "" or utf8.to_upper(managers.localization:text("menu_infamy_unlock_prev_tier")))
		desc_text:set_text(managers.localization:text(infamy_tweak.desc_id, params))
		managers.menu_component:add_colors_to_text_object(desc_text, tweak_data.screen_colors.resource)
	else
		desc_title:set_text(utf8.to_upper(managers.localization:text("st_menu_infamy_secret")))
		desc_warning:set_text("")
		desc_text:set_text(managers.localization:text("st_menu_infamy_secret_desc"))
	end

	local _, _, _, h = desc_title:text_rect()

	desc_title:set_size(self._description_panel:w() - 20, h)

	local _, _, _, h = desc_warning:text_rect()

	desc_warning:set_size(self._description_panel:w() - 20, h)
	desc_warning:set_top(desc_title:bottom() + (is_win_32 and 10 or 0))

	local _, _, _, h = desc_text:text_rect()

	desc_text:set_size(self._description_panel:w() - 20, h)
	desc_text:set_top(desc_warning:bottom() + (is_win_32 and 5 or 0))

	if name then
		desc_upgrade = self._description_panel:panel({
			name = "description_upgrade"
		})
		local infamy_tweak = tweak_data.infamy.items[name]
		local category_list = {
			texture = "textures",
			color = "colors",
			material = "materials",
			mask = "masks"
		}
		local icon_size = 64
		local y = desc_text:bottom() + (is_win_32 and 10 or 0)

		for bonus, item in ipairs(infamy_tweak.upgrades) do
			local global_value = item[1]
			local category = item[2]
			local item_id = item[3]
			local item_tweak_data = tweak_data.blackmarket[category][item_id]
			local guis_catalog = "guis/"
			local bundle_folder = item_tweak_data and item_tweak_data.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			if category == "colors" then
				desc_upgrade:bitmap({
					texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg",
					x = 10,
					layer = 2,
					name = item_id .. "_color_bg",
					y = y,
					w = icon_size,
					h = icon_size
				})
				desc_upgrade:bitmap({
					texture = "guis/textures/pd2/blackmarket/icons/colors/color_02",
					x = 10,
					layer = 1,
					name = item_id .. "_color_1",
					y = y,
					w = icon_size,
					h = icon_size,
					color = tweak_data.blackmarket.colors[item_id].colors[1]
				})
				desc_upgrade:bitmap({
					texture = "guis/textures/pd2/blackmarket/icons/colors/color_01",
					x = 10,
					layer = 1,
					name = item_id .. "_color_2",
					y = y,
					w = icon_size,
					h = icon_size,
					color = tweak_data.blackmarket.colors[item_id].colors[2]
				})
			elseif category == "textures" then
				local icon_texture = tweak_data.blackmarket.textures[item_id].texture

				if DB:has(Idstring("texture"), icon_texture) then
					local panel = desc_upgrade:panel({
						x = 10,
						layer = 1,
						name = item_id .. "_image",
						y = y,
						w = icon_size,
						h = icon_size
					})
					local texture_count = managers.menu_component:request_texture(icon_texture, callback(self, self, "_texture_done_clbk", {
						render_template = "VertexColorTexturedPatterns",
						panel = panel
					}))

					table.insert(self._requested_textures, {
						texture_count = texture_count,
						texture = icon_texture
					})
				end
			else
				local icon_texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. category .. "/" .. item_id

				if DB:has(Idstring("texture"), icon_texture) then
					if category == "materials" then
						local panel = desc_upgrade:panel({
							x = 10,
							layer = 1,
							name = item_id .. "_image",
							y = y,
							w = icon_size,
							h = icon_size
						})
						local texture_count = managers.menu_component:request_texture(icon_texture, callback(self, self, "_texture_done_clbk", {
							panel = panel
						}))

						table.insert(self._requested_textures, {
							texture_count = texture_count,
							texture = icon_texture
						})
					else
						desc_upgrade:bitmap({
							x = 10,
							layer = 1,
							name = item_id .. "_image",
							y = y,
							w = icon_size,
							h = icon_size,
							texture = icon_texture
						})
					end
				end
			end

			local icon_text = desc_upgrade:text({
				wrap = false,
				word_wrap = false,
				vertical = "center",
				layer = 1,
				name = item_id .. "_text",
				x = icon_size + 20,
				y = y,
				h = icon_size,
				font = tweak_data.menu.pd2_medium_font,
				font_size = tweak_data.menu.pd2_medium_font_size
			})

			icon_text:set_text(managers.localization:text(item_tweak_data.name_id))

			y = y + icon_size
		end
	end
end

function InfamyTreeGui:_texture_done_clbk(params, texture_ids)
	if alive(params.panel) then
		params.panel:bitmap({
			texture = texture_ids,
			w = params.panel:w(),
			h = params.panel:h(),
			render_template = params.render_template
		})
	end

	repeat
		local found = nil

		for i, data in pairs(self._requested_textures) do
			if Idstring(data.texture) == texture_ids then
				managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
				table.remove(self._requested_textures, i)

				found = true

				break
			end
		end
	until not found
end

function InfamyTreeGui:_unlock_item(index)
	if not self._tree_items[index] then
		return
	end

	if not self._tree_items[index].unlocked then
		self:_flash_item(self._tree_items[index])

		return
	end

	if self._tree_items[index].owned then
		return
	end

	local infamy_name = tweak_data.infamy.tree[index]

	if managers.infamy:required_points(infamy_name) then
		local params = {
			text_string = "dialog_unlock_infamyitem",
			infamy_item = managers.localization:to_upper_text(tweak_data.infamy.items[infamy_name].name_id),
			points = Application:digest_value(tweak_data.infamy.items[infamy_name].cost, false),
			remaining_points = managers.infamy:points(),
			yes_func = callback(self, self, "_dialog_confirm_yes", index)
		}

		managers.menu:show_confirm_infamypoints(params)
	else
		self:_flash_item(self._tree_items[index])
	end
end

function InfamyTreeGui:_select_item(index)
	if type(index) == "string" then
		for i, name in ipairs(tweak_data.infamy.tree) do
			if name == index then
				index = i

				break
			end
		end
	end

	if self._selected_item ~= index then
		if self._selected_item then
			local selected_item = self._tree_items[self._selected_item]

			selected_item.panel:stop()
			selected_item.border:create_sides(selected_item.panel, {
				sides = {
					0,
					0,
					0,
					0
				}
			})
			selected_item.panel:child("image"):set_color(self._tree_items[self._selected_item].owned and tweak_data.screen_colors.item_stage_1 or self._tree_items[self._selected_item].unlocked and tweak_data.screen_colors.item_stage_2 or tweak_data.screen_colors.item_stage_3)
			selected_item.panel:child("text"):set_text("")
			selected_item.panel:child("text"):set_alpha(0)
		end

		self._selected_item = index
		local infamy_name = tweak_data.infamy.tree[index]
		local item = self._tree_items[index]
		local text = infamy_name and (item.owned and "st_menu_skill_owned" or item.unlocked and "st_menu_point" or "st_menu_skill_locked") or "st_menu_infamy_secret"

		item.panel:child("text"):set_text(utf8.to_upper(managers.localization:text(text, {
			points = infamy_name and Application:digest_value(tweak_data.infamy.items[infamy_name].cost, false) or 0
		})))
		item.panel:child("text"):set_color(tweak_data.screen_colors.text)
		item.panel:child("text"):set_alpha(0)
		item.panel:child("image"):set_color(tweak_data.screen_colors.item_stage_1)
		item.border:create_sides(item.panel, {
			sides = {
				0,
				0,
				0,
				0
			}
		})
		self:_update_description(infamy_name, item.unlocked)
	end
end

function InfamyTreeGui:_dialog_confirm_yes(index)
	local infamy_item = self._tree_items[index]
	local infamy_name = tweak_data.infamy.tree[index]

	managers.infamy:unlock_item(infamy_name)

	infamy_item.owned = true

	infamy_item.panel:child("image"):set_color(tweak_data.screen_colors.item_stage_1)
	managers.menu_component:post_event("menu_skill_investment")
	SimpleGUIEffectSpewer.infamous_up(infamy_item.panel:child("image"):center_x(), infamy_item.panel:child("image"):center_y(), infamy_item.panel)
	self._panel:child("points"):set_text(utf8.to_upper(managers.localization:text("st_menu_infamy_available_points", {
		points = managers.infamy:points()
	})))

	if self._selected_item == index then
		infamy_item.panel:child("text"):set_text(utf8.to_upper(managers.localization:text("st_menu_skill_owned")))
	end

	self:reload()
end

function InfamyTreeGui:reload()
	local tree_rows = tweak_data.infamy.tree_rows or 3
	local tree_cols = tweak_data.infamy.tree_cols or 3
	local neighbour_non_alpha = 0.55

	for index, item in pairs(self._tree_items) do
		item.unlocked = managers.infamy:available(tweak_data.infamy.tree[index])

		item.panel:child("image"):set_color(item.owned and tweak_data.screen_colors.item_stage_1 or item.unlocked and tweak_data.screen_colors.item_stage_2 or tweak_data.screen_colors.item_stage_3)

		item.select_size = item.owned and self._owned_selected_size or item.unlocked and self._unlocked_selected_size or self._locked_selected_size
		item.unselect_size = item.owned and self._owned_unselected_size or item.unlocked and self._unlocked_unselected_size or self._locked_unselected_size

		if item.neighbour_left then
			local neighbour_left = index - 1

			if self._tree_items[neighbour_left] then
				item.neighbour_left[1]:set_image(item.owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
				item.neighbour_left[2]:set_image(self._tree_items[neighbour_left].owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
				item.neighbour_left[1]:set_texture_coordinates(Vector3(0 + item.fw, 0, 0), Vector3(item.panel:width() + item.fw, 0, 0), Vector3(0 + item.fw, 16, 0), Vector3(item.panel:width() + item.fw, 16, 0))
				item.neighbour_left[2]:set_texture_coordinates(Vector3(0 - item.fw, 0, 0), Vector3(item.panel:width() - item.fw, 0, 0), Vector3(0 - item.fw, 16, 0), Vector3(item.panel:width() - item.fw, 16, 0))
				item.neighbour_left[1]:set_alpha((item.owned and 1 or item.unlocked and 0.7 or 0.1) * (self._tree_items[neighbour_left].owned and 1 or 0.5))
				item.neighbour_left[2]:set_alpha((self._tree_items[neighbour_left].owned and 1 or self._tree_items[neighbour_left].unlocked and 0.7 or 0.1) * (item.owned and 1 or 0.5))
			end
		end

		if item.neighbour_top then
			local neighbour_top = index - tree_cols

			if self._tree_items[neighbour_top] then
				item.neighbour_top[1]:set_image(item.owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
				item.neighbour_top[2]:set_image(self._tree_items[neighbour_top].owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
				item.neighbour_top[1]:set_texture_coordinates(Vector3(0 + item.fh, 16, 0), Vector3(0 + item.fh, 0, 0), Vector3(item.panel:height() + item.fh, 16, 0), Vector3(item.panel:height() + item.fh, 0, 0))
				item.neighbour_top[2]:set_texture_coordinates(Vector3(0 - item.fh, 16, 0), Vector3(0 - item.fh, 0, 0), Vector3(item.panel:height() - item.fh, 16, 0), Vector3(item.panel:height() - item.fh, 0, 0))
				item.neighbour_top[1]:set_alpha((item.owned and 1 or item.unlocked and 0.7 or 0.1) * (self._tree_items[neighbour_top].owned and 1 or 0.6))
				item.neighbour_top[2]:set_alpha((self._tree_items[neighbour_top].owned and 1 or self._tree_items[neighbour_top].unlocked and 0.7 or 0.1) * (item.owned and 1 or 0.6))
			end
		end

		if alive(item.panel:child("unlock_glow")) then
			item.panel:child("unlock_glow"):set_visible(item.owned)

			item.glow_alpha = item.owned and 1 or item.unlocked and 0.25 or 0.25
		end
	end

	local selected_item = self._tree_items[self._selected_item]

	if selected_item then
		local infamy_name = tweak_data.infamy.tree[self._selected_item]

		self:_update_description(infamy_name, selected_item.unlocked)
	end
end

function InfamyTreeGui:set_layer(layer)
	self._panel:set_layer(self._init_layer + layer)
end

function InfamyTreeGui:input_focus()
	return 1
end

function InfamyTreeGui:mouse_moved(o, x, y)
	local used = false
	local pointer = "arrow"

	for index, item in pairs(self._tree_items) do
		if item.panel:inside(x, y) then
			used = true
			pointer = "link"

			if self._selected_item ~= index then
				self:_select_item(index)
				managers.menu_component:post_event("highlight")
			end
		end
	end

	if managers.menu:is_pc_controller() then
		local back_button = self._panel:child("back_button")

		if not used and back_button:inside(x, y) then
			used = true
			pointer = "link"

			if not self._back_highlight then
				self._back_highlight = true

				back_button:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
				self:_select_item("infamy_root")
			end
		elseif self._back_highlight then
			self._back_highlight = false

			back_button:set_color(tweak_data.screen_colors.button_stage_3)
		end
	end

	used = used or self._panel:inside(x, y)

	return used, pointer
end

function InfamyTreeGui:mouse_pressed(button, x, y)
	if button == Idstring("0") then
		if self._panel:child("back_button"):inside(x, y) then
			managers.menu:back()

			return
		end

		if self._selected_item then
			local infamy_item = self._tree_items[self._selected_item]

			if infamy_item and infamy_item.panel:inside(x, y) then
				self:_unlock_item(self._selected_item)
			end
		end
	end
end

function InfamyTreeGui:move(x, y)
	local tree_cols = tweak_data.infamy.tree_cols or 3
	local tree_rows = tweak_data.infamy.tree_rows or 3
	local item_x = (self._selected_item - 1) % tree_cols + 1
	local item_y = math.floor((self._selected_item - 1) / tree_cols) + 1
	item_x = math.clamp(item_x + x, 1, tree_cols)
	item_y = math.clamp(item_y + y, 1, tree_rows)
	local new_selected = (item_y - 1) * tree_cols + item_x

	self:_select_item(new_selected)
end

function InfamyTreeGui:move_up()
	if not self._selected_item then
		self:_select_item("infamy_root")
	else
		self:move(0, -1)
	end
end

function InfamyTreeGui:move_down()
	if not self._selected_item then
		self:_select_item("infamy_root")
	else
		self:move(0, 1)
	end
end

function InfamyTreeGui:move_left()
	if not self._selected_item then
		self:_select_item("infamy_root")
	else
		self:move(-1, 0)
	end
end

function InfamyTreeGui:move_right()
	if not self._selected_item then
		self:_select_item("infamy_root")
	else
		self:move(1, 0)
	end
end

function InfamyTreeGui:confirm_pressed()
	if self._selected_item then
		self:_unlock_item(self._selected_item)
	end

	return false
end

function InfamyTreeGui:close()
	managers.menu:active_menu().renderer.ws:show()
	WalletGuiObject.close_wallet(self._panel)

	for i, data in pairs(self._requested_textures) do
		managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
	end

	self._requested_textures = {}

	for _, item in pairs(self._tree_items) do
		item.border:close()
	end

	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end
