core:import("CoreMenuItem")

MenuItemUpgrade = MenuItemUpgrade or class(CoreMenuItem.Item)
MenuItemUpgrade.TYPE = "upgrade"

function MenuItemUpgrade:init(data_node, parameters)
	CoreMenuItem.Item.init(self, data_node, parameters)

	self._parameters.upgrade_id = parameters.upgrade_id
	self._parameters.topic_text = parameters.topic_text
	self._type = MenuItemUpgrade.TYPE
end

function MenuItemUpgrade:setup_gui(node, row_item)
	local upgrade_id = self:parameters().upgrade_id
	row_item.gui_panel = node.item_panel:panel({
		w = node.item_panel:w()
	})
	row_item.upgrade_name = node:_text_item_part(row_item, row_item.gui_panel, node:_right_align())

	row_item.upgrade_name:set_font_size(tweak_data.menu.upgrades_font_size)

	if self:parameters().topic_text then
		row_item.topic_text = node:_text_item_part(row_item, row_item.gui_panel, node:_left_align())

		row_item.topic_text:set_align("right")
		row_item.topic_text:set_font_size(tweak_data.menu.upgrades_font_size)
		row_item.topic_text:set_text(self:parameters().topic_text)
	end

	if self:name() == "upgrade_lock" then
		row_item.not_aquired = true
		row_item.locked = true
	else
		row_item.not_aquired = managers.upgrades:progress_by_tree(self:parameters().tree) < self:parameters().step
		row_item.locked = managers.upgrades:is_locked(self:parameters().step)
	end

	local upg_color = row_item.locked and tweak_data.menu.upgrade_locked_color or row_item.not_aquired and tweak_data.menu.upgrade_not_aquired_color or row_item.color

	if managers.upgrades:aquired(upgrade_id) then
		upg_color = row_item.color
	end

	row_item.upgrade_name:set_color(upg_color)

	if row_item.topic_text then
		row_item.topic_text:set_color(upg_color)
	end

	if self:name() ~= "upgrade_lock" then
		row_item.gui_info_panel = node.safe_rect_panel:panel({
			y = 0,
			visible = false,
			x = 0,
			layer = node.layers.items,
			w = node:_left_align(),
			h = node._item_panel_parent:h()
		})
		local image, rect = managers.upgrades:image(upgrade_id)
		row_item.upgrade_info_image_rect = rect
		row_item.upgrade_info_image = row_item.gui_info_panel:bitmap({
			y = 0,
			h = 150,
			visible = true,
			w = 340,
			x = 0,
			texture = image,
			texture_rect = rect
		})
		row_item.upgrade_info_title = row_item.gui_info_panel:text({
			halign = "top",
			vertical = "top",
			word_wrap = true,
			wrap = true,
			align = "left",
			y = 0,
			x = 0,
			font_size = node.font_size,
			font = row_item.font,
			color = Color.white,
			layer = node.layers.items,
			text = string.upper(managers.upgrades:complete_title(upgrade_id, " > "))
		})
		row_item.upgrade_info_text = row_item.gui_info_panel:text({
			halign = "top",
			vertical = "top",
			word_wrap = true,
			wrap = true,
			align = "left",
			y = 0,
			x = 0,
			font = tweak_data.menu.small_font,
			font_size = tweak_data.menu.small_font_size,
			color = Color.white,
			layer = node.layers.items,
			text = string.upper(managers.upgrades:description(upgrade_id))
		})

		if tweak_data.upgrades.visual.upgrade[upgrade_id] and not tweak_data.upgrades.visual.upgrade[upgrade_id].base then
			row_item.upgrade_icon = row_item.gui_panel:bitmap({
				texture = "guis/textures/icon_star",
				texture_rect = {
					0,
					0,
					32,
					32
				},
				layer = node.layers.items,
				color = upg_color
			})

			if managers.upgrades:aquired(upgrade_id) then
				row_item.toggle_text = row_item.gui_info_panel:text({
					halign = "top",
					vertical = "top",
					word_wrap = true,
					wrap = true,
					align = "left",
					text = "",
					y = 0,
					x = 0,
					font = tweak_data.menu.small_font,
					font_size = tweak_data.menu.small_font_size,
					color = Color.white,
					layer = node.layers.items
				})

				self:reload(row_item, node)
			end
		end
	end

	self:_layout(node, row_item)

	return true
end

function MenuItemUpgrade:reload(row_item, node)
	local upgrade_id = self:parameters().upgrade_id

	if row_item.toggle_text then
		local text = nil

		if not managers.upgrades:visual_weapon_upgrade_active(upgrade_id) then
			text = managers.localization:text("menu_show_upgrade_info", {
				UPGRADE = managers.localization:text("menu_" .. upgrade_id .. "_info")
			})
		else
			text = managers.localization:text("menu_hide_upgrade_info", {
				UPGRADE = managers.localization:text("menu_" .. upgrade_id .. "_info")
			})
		end

		row_item.toggle_text:set_text(string.upper(text))
	end

	return true
end

function MenuItemUpgrade:highlight_row_item(node, row_item, mouse_over)
	if row_item.gui_info_panel then
		row_item.gui_info_panel:set_visible(true)
	end

	row_item.upgrade_name:set_color(row_item.color)
	row_item.upgrade_name:set_font(tweak_data.menu.default_font_no_outline_id)

	if row_item.topic_text then
		row_item.topic_text:set_color(row_item.color)
		row_item.topic_text:set_font(tweak_data.menu.default_font_no_outline_id)
	end

	if row_item.upgrade_icon then
		row_item.upgrade_icon:set_image("guis/textures/icon_star", 32, 0, 32, 32)
	end

	return true
end

function MenuItemUpgrade:fade_row_item(node, row_item)
	if row_item.gui_info_panel then
		row_item.gui_info_panel:set_visible(false)
	end

	local upg_color = row_item.locked and tweak_data.menu.upgrade_locked_color or row_item.not_aquired and tweak_data.menu.upgrade_not_aquired_color or row_item.color

	if managers.upgrades:aquired(self:parameters().upgrade_id) then
		upg_color = row_item.color
	end

	row_item.upgrade_name:set_color(upg_color)
	row_item.upgrade_name:set_font(tweak_data.menu.default_font_id)

	if row_item.topic_text then
		row_item.topic_text:set_color(upg_color)
		row_item.topic_text:set_font(tweak_data.menu.default_font_id)
	end

	if row_item.upgrade_icon then
		row_item.upgrade_icon:set_image("guis/textures/icon_star", 0, 0, 32, 32)
	end

	return true
end

local xl_pad = 64

function MenuItemUpgrade:_layout(node, row_item)
	local safe_rect = managers.gui_data:scaled_size()

	row_item.gui_panel:set_width(safe_rect.width / 2 + xl_pad * 1.5)
	row_item.gui_panel:set_x(safe_rect.width / 2 - xl_pad * 1.5)

	local x, y, w, h = row_item.upgrade_name:text_rect()

	row_item.upgrade_name:set_height(h)
	row_item.upgrade_name:set_left(node:_right_align() - row_item.gui_panel:x())
	row_item.gui_panel:set_height(h)

	if row_item.topic_text then
		row_item.topic_text:set_height(h)
		row_item.topic_text:set_right(row_item.gui_panel:w())
	end

	if row_item.upgrade_icon then
		local s = math.min(32, h * 1.75)

		row_item.upgrade_icon:set_size(s, s)
		row_item.upgrade_icon:set_left(node:_right_align() - row_item.gui_panel:x() + w + node._align_line_padding)
		row_item.upgrade_icon:set_center_y(h / 2)
	end

	if row_item.gui_info_panel then
		node:_align_item_gui_info_panel(row_item.gui_info_panel)

		local w = row_item.gui_info_panel:w()
		local m = row_item.upgrade_info_image_rect[3] / row_item.upgrade_info_image_rect[4]

		row_item.upgrade_info_image:set_size(w, w / m)
		row_item.upgrade_info_image:set_y(0)
		row_item.upgrade_info_image:set_center_x(row_item.gui_info_panel:w() / 2)
		row_item.upgrade_info_title:set_width(w)

		local _, _, _, h = row_item.upgrade_info_title:text_rect()

		row_item.upgrade_info_title:set_height(h)
		row_item.upgrade_info_title:set_top(row_item.upgrade_info_image:bottom() + tweak_data.menu.info_padding)
		row_item.upgrade_info_text:set_top(row_item.upgrade_info_image:bottom() + h + tweak_data.menu.info_padding * 2)
		row_item.upgrade_info_text:set_width(w)

		local _, _, _, h = row_item.upgrade_info_text:text_rect()

		row_item.upgrade_info_text:set_height(h)

		if row_item.toggle_text then
			row_item.toggle_text:set_width(row_item.gui_info_panel:w())

			local _, _, _, h = row_item.toggle_text:text_rect()

			row_item.toggle_text:set_height(h)
			row_item.toggle_text:set_bottom(row_item.gui_info_panel:height())
			row_item.toggle_text:set_left(0)
		end
	end
end
