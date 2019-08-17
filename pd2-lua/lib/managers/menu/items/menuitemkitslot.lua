core:import("CoreMenuItem")

MenuItemKitSlot = MenuItemKitSlot or class(CoreMenuItem.Item)
MenuItemKitSlot.TYPE = "kitslot"

function MenuItemKitSlot:init(data_node, parameters)
	CoreMenuItem.Item.init(self, data_node, parameters)

	self._type = MenuItemKitSlot.TYPE
	self._options = {}
	self._current_index = 1

	if self._parameters.category == "weapon" then
		self._options = managers.player:availible_weapons(self._parameters.slot)
		local selected_weapon = managers.player:weapon_in_slot(self._parameters.slot)

		for i, option in ipairs(self._options) do
			if option == selected_weapon then
				self._current_index = i

				break
			end
		end
	elseif self._parameters.category == "equipment" then
		self._options = managers.player:availible_equipment(self._parameters.slot)
		local selected = managers.player:equipment_in_slot(self._parameters.slot)

		for i, option in ipairs(self._options) do
			if option == selected then
				self._current_index = i

				break
			end
		end
	end
end

function MenuItemKitSlot:next()
	if not self._enabled then
		return
	end

	if #self._options < 2 then
		return
	end

	if self._current_index == #self._options then
		return
	end

	self._current_index = self._current_index == #self._options and 1 or self._current_index + 1

	if self._parameters.category == "weapon" then
		managers.player:set_equipment_in_slot(self._options[self._current_index], self._parameters.slot)
	end

	if self._parameters.category == "equipment" then
		managers.player:set_equipment_in_slot(self._options[self._current_index], self._parameters.slot)
	end

	if not managers.network:session() then
		return
	end

	local peer_id = managers.network:session():local_peer():id()

	managers.menu:get_menu("kit_menu").renderer:set_kit_selection(peer_id, self._parameters.category, self._options[self._current_index], self._parameters.slot)

	return true
end

function MenuItemKitSlot:previous()
	if not self._enabled then
		return
	end

	if #self._options < 2 then
		return
	end

	if self._current_index == 1 then
		return
	end

	self._current_index = self._current_index == 1 and #self._options or self._current_index - 1

	if self._parameters.category == "weapon" then
		Global.player_manager.kit.weapon_slots[self._parameters.slot] = self._options[self._current_index]
	end

	if self._parameters.category == "equipment" then
		managers.player:set_equipment_in_slot(self._options[self._current_index], self._parameters.slot)
	end

	if not managers.network:session() then
		return
	end

	local peer_id = managers.network:session():local_peer():id()

	managers.menu:get_menu("kit_menu").renderer:set_kit_selection(peer_id, self._parameters.category, self._options[self._current_index], self._parameters.slot)

	return true
end

function MenuItemKitSlot:left_arrow_visible()
	return self._current_index > 1 and self._enabled
end

function MenuItemKitSlot:right_arrow_visible()
	return self._current_index < #self._options and self._enabled
end

function MenuItemKitSlot:arrow_visible()
	return #self._options > 0
end

function MenuItemKitSlot:text()
	if #self._options == 0 then
		return managers.localization:text("menu_kit_locked")
	end

	if self._parameters.category == "weapon" then
		local id = self._options[self._current_index]
		local name_id = tweak_data.weapon[id].name_id

		return managers.localization:text(name_id)
	elseif self._parameters.category == "equipment" then
		local id = self._options[self._current_index]
		local equipment_id = tweak_data.upgrades.definitions[id].equipment_id
		local name_id = (tweak_data.equipments.specials[equipment_id] or tweak_data.equipments[equipment_id]).text_id

		return managers.localization:text(name_id)
	end
end

function MenuItemKitSlot:icon_and_description()
	if #self._options == 0 then
		return "locked", managers.localization:text("des_locked")
	end

	if self._parameters.category == "weapon" then
		local id = self._options[self._current_index]
		local hud_icon = tweak_data.weapon[id].hud_icon
		local description_id = tweak_data.weapon[id].description_id
		local name_id = tweak_data.weapon[id].name_id

		return hud_icon, managers.localization:text(description_id)
	elseif self._parameters.category == "equipment" then
		local id = self._options[self._current_index]
		local equipment_id = tweak_data.upgrades.definitions[id].equipment_id
		local tweak_data = tweak_data.equipments.specials[equipment_id] or tweak_data.equipments[equipment_id]
		local description_id = tweak_data.description_id
		local hud_icon = tweak_data.icon

		return hud_icon, description_id and managers.localization:text(description_id) or "NO DESCRIPTION"
	end
end

function MenuItemKitSlot:upgrade_progress()
	if #self._options == 0 then
		return 0, 0
	end

	if self._parameters.category == "weapon" then
		local id = self._options[self._current_index]

		return managers.player:weapon_upgrade_progress(id)
	elseif self._parameters.category == "equipment" then
		local id = self._options[self._current_index]
		local equipment_id = tweak_data.upgrades.definitions[id].equipment_id

		return managers.player:equipment_upgrade_progress(equipment_id)
	end

	return 0, 0
end

function MenuItemKitSlot:percentage()
	return 66
end

function MenuItemKitSlot.clbk_msg_set_kit_selection(overwrite_data, msg_queue, rpc_name, peer_id, category, selection_name, slot)
	if msg_queue then
		local category_data = overwrite_data.categories[category]

		if not category_data then
			category_data = {}
			overwrite_data.categories[category] = category_data
		end

		local item_index = category_data[slot]

		if item_index then
			msg_queue[item_index] = {
				rpc_name,
				peer_id,
				category,
				selection_name,
				slot
			}
		else
			table.insert(msg_queue, {
				rpc_name,
				peer_id,
				category,
				selection_name,
				slot
			})

			category_data[slot] = #msg_queue
		end
	else
		for cat_name, cat_data in pairs(overwrite_data.categories) do
			for _slot, _ in pairs(cat_data) do
				cat_data[_slot] = nil
			end
		end
	end
end

function MenuItemKitSlot:setup_gui(node, row_item)
	local category = self:parameters().category
	local slot = self:parameters().slot
	row_item.gui_panel = node.item_panel:panel({
		w = node.item_panel:w()
	})
	row_item.gui_text = node:_text_item_part(row_item, row_item.gui_panel, node:_right_align(), "right")

	row_item.gui_text:set_wrap(true)
	row_item.gui_text:set_word_wrap(true)

	row_item.choice_panel = row_item.gui_panel:panel({
		w = node.item_panel:w()
	})
	row_item.choice_text = row_item.choice_panel:text({
		halign = "center",
		vertical = "center",
		align = "left",
		y = 0,
		font_size = node.font_size,
		x = node:_right_align(),
		font = row_item.font,
		color = self:arrow_visible() and tweak_data.menu.default_changeable_text_color or tweak_data.menu.default_disabled_text_color,
		layer = node.layers.items,
		text = string.upper(self:text()),
		render_template = Idstring("VertexColorTextured")
	})
	local w = 20
	local h = 20
	local base = 20
	local height = 15
	row_item.arrow_left = row_item.gui_panel:bitmap({
		texture = "guis/textures/menu_arrows",
		y = 0,
		x = 0,
		texture_rect = {
			0,
			0,
			24,
			24
		},
		color = Color(0.5, 0.5, 0.5),
		visible = self:arrow_visible(),
		layer = node.layers.items
	})
	row_item.arrow_right = row_item.gui_panel:bitmap({
		texture = "guis/textures/menu_arrows",
		x = 0,
		y = 0,
		rotation = 180,
		texture_rect = {
			0,
			0,
			24,
			24
		},
		color = Color(0.5, 0.5, 0.5),
		visible = self:arrow_visible(),
		layer = node.layers.items
	})
	row_item.description_panel = node.safe_rect_panel:panel({
		h = 112,
		visible = false,
		w = node.item_panel:w() / 2
	})

	row_item.description_panel:set_left(row_item.choice_panel:left())

	row_item.description_panel_bg = row_item.description_panel:rect({
		color = Color.black:with_alpha(0.5)
	})
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data("fallback")
	row_item.description_icon = row_item.description_panel:bitmap({
		name = "description_icon",
		h = 48,
		y = 0,
		w = 48,
		x = 0,
		texture = icon,
		layer = node.layers.items,
		texture_rect = texture_rect
	})
	row_item.description_progress_text = row_item.description_panel:text({
		halign = "left",
		vertical = "bottom",
		word_wrap = false,
		wrap = false,
		align = "left",
		y = 0,
		x = 0,
		font_size = node.font_size,
		font = row_item.font,
		color = row_item.color,
		layer = node.layers.items,
		text = managers.localization:text("menu_upgrade_progress"),
		render_template = Idstring("VertexColorTextured")
	})
	local _, _, w, h = row_item.description_progress_text:text_rect()
	row_item.progress_bg = row_item.description_panel:rect({
		halign = "center",
		vertical = "center",
		h = 22,
		w = 256,
		align = "center",
		y = 0,
		x = 52 + w + 4,
		color = Color.black:with_alpha(0.5),
		layer = node.layers.items - 1
	})
	row_item.progress_bar = row_item.description_panel:gradient({
		vertical = "center",
		align = "center",
		halign = "center",
		orientation = "vertical",
		gradient_points = {
			0,
			Color(1, 1, 0.6588235294117647, 0),
			1,
			Color(1, 0.6039215686274509, 0.4, 0)
		},
		x = row_item.progress_bg:x() + 2,
		y = row_item.progress_bg:y() + 2,
		w = (row_item.progress_bg:w() - 4) * 0.11,
		h = row_item.progress_bg:h() - 4,
		layer = node.layers.items
	})
	row_item.progress_text = row_item.description_panel:text({
		y = 0,
		vertical = "center",
		align = "center",
		halign = "center",
		valign = "center",
		font_size = tweak_data.menu.stats_font_size,
		x = row_item.progress_bg:x(),
		h = h,
		w = row_item.progress_bg:w(),
		font = node.font,
		color = node.color,
		layer = node.layers.items + 1,
		text = "" .. math.floor(11) .. "%",
		render_template = Idstring("VertexColorTextured")
	})
	row_item.description_text = row_item.description_panel:text({
		halign = "left",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		y = 0,
		x = 0,
		font_size = tweak_data.menu.small_font_size,
		font = tweak_data.menu.small_font,
		color = row_item.color,
		layer = node.layers.items,
		text = self:text(),
		render_template = Idstring("VertexColorTextured")
	})

	self:_layout(node, row_item)

	return true
end

function MenuItemKitSlot:reload(row_item, node)
	local icon_id, description = self:icon_and_description()

	if icon_id then
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(icon_id)

		row_item.description_icon:set_image(icon, texture_rect[1], texture_rect[2], texture_rect[3], texture_rect[4])
		row_item.description_text:set_text(string.upper(description))
	end

	row_item.choice_text:set_text(string.upper(self:text()))

	local current, total = self:upgrade_progress()
	local value = total ~= 0 and current / total or 0

	row_item.progress_bar:set_w((row_item.progress_bg:w() - 4) * value)
	row_item.progress_text:set_text(current .. "/" .. total)
	row_item.arrow_left:set_color(self:left_arrow_visible() and tweak_data.menu.arrow_available or tweak_data.menu.arrow_unavailable)
	row_item.arrow_right:set_color(self:right_arrow_visible() and tweak_data.menu.arrow_available or tweak_data.menu.arrow_unavailable)

	return true
end

function MenuItemKitSlot:highlight_row_item(node, row_item, mouse_over)
	row_item.description_panel:set_visible(false)
	row_item.choice_text:set_color(row_item.color)
	row_item.choice_text:set_font(tweak_data.menu.default_font_no_outline_id)
	row_item.arrow_left:set_image("guis/textures/menu_arrows", 24, 0, 24, 24)
	row_item.arrow_right:set_image("guis/textures/menu_arrows", 24, 0, 24, 24)
	row_item.arrow_left:set_color(self:left_arrow_visible() and tweak_data.menu.arrow_available or tweak_data.menu.arrow_unavailable)
	row_item.arrow_right:set_color(self:right_arrow_visible() and tweak_data.menu.arrow_available or tweak_data.menu.arrow_unavailable)

	return true
end

function MenuItemKitSlot:fade_row_item(node, row_item, mouse_over)
	row_item.description_panel:set_visible(false)
	row_item.choice_text:set_color(self:arrow_visible() and tweak_data.menu.default_changeable_text_color or tweak_data.menu.default_disabled_text_color)
	row_item.choice_text:set_font(tweak_data.menu.default_font_id)
	row_item.arrow_left:set_image("guis/textures/menu_arrows", 0, 0, 24, 24)
	row_item.arrow_right:set_image("guis/textures/menu_arrows", 0, 0, 24, 24)
	row_item.arrow_left:set_color(self:left_arrow_visible() and tweak_data.menu.arrow_available or tweak_data.menu.arrow_unavailable)
	row_item.arrow_right:set_color(self:right_arrow_visible() and tweak_data.menu.arrow_available or tweak_data.menu.arrow_unavailable)

	return true
end

function MenuItemKitSlot:_layout(node, row_item)
	local safe_rect = managers.gui_data:scaled_size()
	local xl_pad = 64

	row_item.gui_text:set_font_size(node.font_size)
	row_item.choice_text:set_font_size(node.font_size)
	row_item.gui_panel:set_width(safe_rect.width / 2 + xl_pad)
	row_item.gui_panel:set_x(safe_rect.width / 2 - xl_pad)
	row_item.arrow_right:set_size(24 * tweak_data.scale.multichoice_arrow_multiplier, 24 * tweak_data.scale.multichoice_arrow_multiplier)
	row_item.arrow_right:set_right(node:_left_align() - row_item.gui_panel:x())
	row_item.arrow_left:set_size(24 * tweak_data.scale.multichoice_arrow_multiplier, 24 * tweak_data.scale.multichoice_arrow_multiplier)
	row_item.arrow_left:set_right(row_item.arrow_right:left() + 2 * (1 - tweak_data.scale.multichoice_arrow_multiplier))
	row_item.gui_text:set_width(row_item.arrow_left:left() - node._align_line_padding * 2)

	local x, y, w, h = row_item.gui_text:text_rect()

	row_item.gui_text:set_h(h)
	row_item.choice_panel:set_w(safe_rect.width - node:_right_align())
	row_item.choice_panel:set_h(h)
	row_item.choice_panel:set_left(node:_right_align() - row_item.gui_panel:x())
	row_item.choice_text:set_w(row_item.choice_panel:w())
	row_item.choice_text:set_h(h)
	row_item.choice_text:set_left(0)
	row_item.arrow_right:set_center_y(row_item.choice_panel:center_y())
	row_item.arrow_left:set_center_y(row_item.choice_panel:center_y())
	row_item.gui_text:set_left(0)
	row_item.gui_text:set_height(h)
	row_item.gui_panel:set_height(h)
	row_item.description_panel:set_h(126 * tweak_data.scale.kit_menu_description_h_scale)
	row_item.description_panel:set_w(safe_rect.width / 2)
	row_item.description_panel:set_right(safe_rect.width)
	row_item.description_panel:set_bottom(safe_rect.height - tweak_data.menu.upper_saferect_border - tweak_data.menu.border_pad)
	row_item.description_panel_bg:set_size(row_item.description_panel:size())

	local pad = 4 * tweak_data.scale.kit_menu_bar_scale

	row_item.description_icon:set_size(48 * tweak_data.scale.kit_menu_bar_scale, 48 * tweak_data.scale.kit_menu_bar_scale)
	row_item.description_icon:set_position(pad, pad)
	row_item.description_text:set_font_size(tweak_data.menu.kit_description_font_size)
	row_item.description_text:set_h(row_item.description_panel:h())
	row_item.description_text:set_w(safe_rect.width / 2 - (row_item.description_icon:right() + 4) - pad)
	row_item.description_text:set_y(pad)
	row_item.description_text:set_left(row_item.description_icon:right() + 4)
	row_item.description_progress_text:set_font_size(node.font_size)
	row_item.description_progress_text:set_left(pad)

	local _, _, w, h = row_item.description_progress_text:text_rect()

	row_item.description_progress_text:set_w(w)
	row_item.description_progress_text:set_bottom(row_item.description_panel:h() - pad)
	row_item.progress_bg:set_h(22 * tweak_data.scale.kit_menu_bar_scale)
	row_item.progress_bg:set_bottom(row_item.description_panel_bg:h() - pad)
	row_item.progress_bg:set_left(row_item.description_progress_text:right() + 8)
	row_item.progress_bg:set_w(row_item.description_panel:w() - row_item.progress_bg:left() - pad)

	local current, total = self:upgrade_progress()
	local value = total ~= 0 and current / total or 0

	row_item.progress_bar:set_h(row_item.progress_bg:h() - 4)
	row_item.progress_bar:set_w((row_item.progress_bg:w() - 4) * value)
	row_item.progress_bar:set_position(row_item.progress_bg:x() + 2, row_item.progress_bg:y() + 2)
	row_item.progress_text:set_font_size(tweak_data.menu.stats_font_size)
	row_item.progress_text:set_size(row_item.progress_bg:size())
	row_item.progress_text:set_position(row_item.progress_bg:x(), row_item.progress_bg:y())
end
