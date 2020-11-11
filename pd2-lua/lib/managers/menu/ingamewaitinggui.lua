IngameWaitingGui = IngameWaitingGui or class()
local PADDING = 10
local text_font = tweak_data.menu.pd2_medium_font
local text_font_size = tweak_data.menu.pd2_medium_font_size
local font_color_highlighted = tweak_data.screen_colors.button_stage_2
local font_color_rest = tweak_data.screen_colors.button_stage_3

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function IngameWaitingGui:init(ws)
	self._panel = ws:panel()
	self._current_btn = {}
	self._buttons = {}
	self._saved_names = {}
	self._text_panel = self._panel:panel()
	self._header_text = self._text_panel:text({
		align = "right",
		text = managers.localization:text("menu_waiting_peer_info"),
		font = text_font,
		font_size = text_font_size
	})

	make_fine_text(self._header_text)
	self._text_panel:set_w(self._header_text:w())
	self._text_panel:set_h(self._header_text:h() + 2)

	self._content_panel = self._panel:panel()
	self._background = self._content_panel:rect({
		alpha = 0.25,
		layer = -1,
		color = Color(255, 0, 170, 255) / 255
	})
	local color = tweak_data.screen_colors.text
	self._info_panel = self._content_panel:panel({
		name = "self._info_panel",
		h = 42,
		x = PADDING,
		y = PADDING
	})
	local detection = self._info_panel:panel({
		w = 42,
		name = "detection",
		h = 42,
		visible = false
	})
	local detection_ring_left_bg = detection:bitmap({
		blend_mode = "add",
		name = "detection_left_bg",
		alpha = 0.2,
		texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
		w = detection:w(),
		h = detection:h()
	})
	local detection_ring_right_bg = detection:bitmap({
		blend_mode = "add",
		name = "detection_right_bg",
		alpha = 0.2,
		texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
		w = detection:w(),
		h = detection:h()
	})

	detection_ring_right_bg:set_texture_rect(detection_ring_right_bg:texture_width(), 0, -detection_ring_right_bg:texture_width(), detection_ring_right_bg:texture_height())

	local detection_ring_left = detection:bitmap({
		blend_mode = "add",
		name = "detection_left",
		texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
		render_template = "VertexColorTexturedRadial",
		layer = 1,
		w = detection:w(),
		h = detection:h()
	})
	local detection_ring_right = detection:bitmap({
		blend_mode = "add",
		name = "detection_right",
		texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
		render_template = "VertexColorTexturedRadial",
		layer = 1,
		w = detection:w(),
		h = detection:h()
	})

	detection_ring_right:set_texture_rect(detection_ring_right:texture_width(), 0, -detection_ring_right:texture_width(), detection_ring_right:texture_height())

	local detection_value = self._info_panel:text({
		text = "",
		name = "detection_value",
		align = "center",
		blend_mode = "add",
		vertical = "center",
		font_size = text_font_size,
		font = text_font,
		color = color
	})

	detection_value:set_center_x(detection:left() + detection:w() / 2)
	detection_value:set_center_y(detection:top() + detection:h() / 2 + 2)
	detection_value:set_visible(detection:visible())

	self._detection = detection
	self._detection_value = detection_value
	self._name_text = self._info_panel:text({
		text = "",
		name = "peer_name",
		align = "left",
		vertical = "center",
		font_size = text_font_size,
		font = text_font,
		color = color
	})

	self._name_text:set_left(detection:right() + 5)
	self._name_text:set_center_y(detection_value:center_y())

	self._loadout_bottom = self._info_panel:bottom() + 128 + PADDING
	self._loadout_width = 448
	self._button_panel = self._content_panel:panel({
		x = self._info_panel:x(),
		y = self._loadout_bottom + PADDING,
		h = text_font_size
	})
	self._peer_btns_panel = self._button_panel:panel({
		w = 0
	})
	self._peer_btns = {
		self:add_button(self._peer_btns_panel, "hud_waiting_accept", "drop_in_accept", "spawn", 30),
		self:add_button(self._peer_btns_panel, "hud_waiting_return", "drop_in_return", "return_back", 30),
		self:add_button(self._peer_btns_panel, "hud_waiting_kick", "drop_in_kick", "kick")
	}
	self._left_btns_panel = self._button_panel:panel({
		w = 0
	})
	self._left_btns = {
		self:add_button(self._left_btns_panel, "hud_waiting_ok", "drop_in_accept", "left_ok")
	}

	self._content_panel:set_h(self._button_panel:bottom() + PADDING)
	self._content_panel:set_w(self._loadout_width + PADDING * 2)
	BoxGuiObject:new(self._content_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._prev_panel = self._content_panel:panel()
	self._next_panel = self._content_panel:panel()
	self._prev_arrow = IngameWaitingButton:new(self._prev_panel, "<", nil, callback(self, self, "next_page"))
	self._next_arrow = IngameWaitingButton:new(self._next_panel, ">", nil, callback(self, self, "prev_page"))

	BoxGuiObject:new(self._prev_panel, {
		sides = {
			2,
			0,
			0,
			0
		}
	})
	BoxGuiObject:new(self._next_panel, {
		sides = {
			0,
			2,
			0,
			0
		}
	})
	self._prev_arrow:panel():set_top(self._button_panel:top())
	self._next_arrow:panel():set_top(self._button_panel:top())
	self._prev_arrow:panel():set_left(PADDING)
	self._next_arrow:panel():set_right(self._content_panel:w() - PADDING)
	self._button_panel:set_w(self._next_arrow:panel():left() - self._prev_arrow:panel():right())
	self._button_panel:set_left(self._prev_arrow:panel():right())
	self._peer_btns_panel:set_center_x(self._button_panel:w() / 2)
	self._left_btns_panel:set_center_x(self._button_panel:w() / 2)
	self._content_panel:set_right(self._panel:w())

	if managers.menu_component._ingame_contract_gui then
		self._content_panel:set_world_bottom(managers.menu_component._ingame_contract_gui._panel:world_bottom())
	else
		self._content_panel:set_bottom(self._panel:h() - PADDING * 3)
	end

	self._text_panel:set_rightbottom(self._content_panel:righttop())
	self:try_get_dummy()
end

function IngameWaitingGui:close()
	if self._panel and alive(self._panel) then
		self._panel:remove(self._content_panel)
		self._panel:remove(self._text_panel)
	end
end

function IngameWaitingGui:calc_next(current)
	current = current or self._current_slot

	if not current then
		return nil
	end

	current = current + 1

	for id = current, CriminalsManager.MAX_NR_CRIMINALS do
		local peer = managers.network:session():peer(id)

		if peer and managers.wait:is_waiting(id) then
			self._saved_names[id] = peer:name()

			return id
		elseif self._saved_names[id] then
			return id
		end
	end

	return nil
end

function IngameWaitingGui:calc_prev(current)
	current = current or self._current_slot

	if not current then
		return nil
	end

	current = current - 1

	for id = current, 1, -1 do
		local peer = managers.network:session():peer(id)

		if peer and managers.wait:is_waiting(id) then
			self._saved_names[id] = peer:name()

			return id
		elseif self._saved_names[id] then
			return id
		end
	end

	return nil
end

function IngameWaitingGui:left_ok()
	if not self._current_slot then
		return
	end

	self:check_remove_panel(self._current_slot)
end

function IngameWaitingGui:kick()
	if not self._peer then
		return
	end

	managers.vote:message_host_kick(self._peer)
end

function IngameWaitingGui:return_back()
	if not self._peer then
		return
	end

	managers.wait:kick_to_briefing(self._peer:id())
	self:check_remove_panel(self._peer:id())
end

function IngameWaitingGui:spawn()
	if not self._peer then
		return
	end

	managers.wait:spawn_waiting(self._peer:id())
	self:check_remove_panel(self._peer:id())
end

function IngameWaitingGui:check_remove_panel(slot_id)
	self._saved_names[slot_id] = nil

	if slot_id == self._current_slot then
		local peer = managers.network:session():peer(self._current_slot)

		if self._peer ~= peer and managers.wait:is_waiting(peer:id()) then
			self:set_panel_for(self._current_slot, true)
		else
			self:set_panel_for(self:calc_next() or self:calc_prev(), true)
		end
	end
end

function IngameWaitingGui:add_button(panel, text, binding, func_name, padding)
	local params = {
		MY_BTN = managers.localization:btn_macro(binding, true, true) or ""
	}
	text = managers.localization:text(text, params)
	local btn, btn_panel = IngameWaitingButton:new(panel, text, binding, callback(self, self, func_name))

	btn_panel:set_x(panel:w())
	panel:set_w(btn_panel:right() + (padding or 0))

	return btn
end

function IngameWaitingGui:set_layer(layer)
	self._content_panel:set_layer(layer)
	self._text_panel:set_layer(layer)
end

function IngameWaitingGui:try_get_dummy()
	local active_node_gui = managers.menu:active_menu().renderer:active_node_gui()

	if active_node_gui then
		self._dummy_item = active_node_gui:row_item_by_name("drop_in_dummy")

		self._dummy_item.item:set_actual_item(self)

		local id = self:calc_next(1)

		if not id then
			self:set_enabled(false)
		else
			self:set_enabled(true)
			self:set_panel_for(id)
		end
	end

	return self._dummy_item
end

IngameWaitingGui.game_state_blacklist = {
	victoryscreen = true,
	gameoverscreen = true
}

function IngameWaitingGui:update(t, dt)
	if not self._dummy_item then
		self:try_get_dummy()
	end

	if self.game_state_blacklist[game_state_machine:last_queued_state_name()] then
		self:set_enabled(false)

		return
	end

	if not self._content_panel:visible() or not self._current_slot then
		local valid_slot = self:calc_next(1)

		if valid_slot then
			self:set_enabled(true)
			self:set_panel_for(valid_slot)
		else
			return
		end
	end

	if self._peer and self._peer ~= managers.network:session():peer(self._current_slot) then
		self:set_panel_for(self._current_slot)
	end

	self._next_panel:set_visible(self:calc_next())
	self._prev_panel:set_visible(self:calc_prev())
end

function IngameWaitingGui:set_enabled(enabled)
	enabled = not not enabled

	self._content_panel:set_visible(enabled)
	self._text_panel:set_visible(enabled)

	self._peer = enabled and self._peer or nil

	if self._dummy_item then
		self._dummy_item.item.no_select = not enabled
	end
end

function IngameWaitingGui:set_panel_for(peer_id)
	self._current_slot = peer_id
	self._peer = managers.network:session():peer(peer_id)

	if peer_id == nil then
		self:set_enabled(false)

		return
	end

	if self._loadout_panel then
		self._content_panel:remove(self._loadout_panel)
	end

	self._buttons = {}

	if not self._peer or not managers.wait:is_waiting(self._peer:id()) and not peer_id == 1 then
		local name = self._saved_names[peer_id] or "N/A"
		local str = managers.localization:text("menu_waiting_peer_left", {
			name = name
		})
		self._loadout_panel = self._content_panel:panel()

		self._detection:set_visible(false)
		self._detection_value:set_visible(false)
		self._name_text:set_visible(false)

		local text = self._loadout_panel:text({
			vertical = "center",
			align = "left",
			text = str,
			font = text_font,
			font_size = text_font_size
		})

		make_fine_text(text)
		text:set_world_left(self._detection:world_left())
		text:set_world_center_y(self._name_text:world_center_y())

		self._buttons = self._left_btns

		self._button_panel:set_visible(true)
		self._left_btns_panel:set_visible(true)
		self._peer_btns_panel:set_visible(false)
		self:set_current_button(math.clamp(1, self._current_btn.index, #self._buttons))

		return
	end

	self._saved_names[peer_id] = self._peer:name()
	local kit_menu = managers.menu:get_menu("kit_menu")

	if not kit_menu or not kit_menu.renderer then
		return
	end

	local kit_slot = kit_menu.renderer:get_player_slot_by_peer_id(peer_id)
	local outfit = kit_slot and kit_slot.outfit

	if not outfit then
		return
	end

	self._buttons = self._peer_btns

	self._left_btns_panel:set_visible(false)
	self._peer_btns_panel:set_visible(true)
	self:set_current_button(math.clamp(1, self._current_btn.index, #self._buttons))

	local current, reached = managers.blackmarket:get_suspicion_offset_of_peer(self._peer, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)

	self._detection:child("detection_left"):set_color(Color(0.5 + current * 0.5, 1, 1))
	self._detection:child("detection_right"):set_color(Color(0.5 + current * 0.5, 1, 1))
	self._detection:set_visible(true)
	self._detection_value:set_visible(true)
	self._detection_value:set_text(math.round(current * 100))

	if reached then
		self._detection_value:set_color(Color(255, 255, 42, 0) / 255)
	else
		self._detection_value:set_color(tweak_data.screen_colors.text)
	end

	local peer_name_string = self._peer:name()
	local color_range_offset = utf8.len(peer_name_string) + 2
	local experience, color_ranges = managers.experience:gui_string(self._peer:level(), self._peer:rank(), color_range_offset)

	self._name_text:set_text(self._peer:name() .. " (" .. experience .. ")")

	for _, color_range in ipairs(color_ranges or {}) do
		self._name_text:set_range_color(color_range.start, color_range.stop, color_range.color)
	end

	self._name_text:set_visible(true)

	self._loadout_panel = self._content_panel:panel()
	local primary_panel = self._loadout_panel:panel({
		w = 128,
		h = 128
	})
	local secondary_panel = self._loadout_panel:panel({
		w = 128,
		h = 128
	})

	self:create_weapon(outfit.primary, primary_panel)
	self:create_weapon(outfit.secondary, secondary_panel)
	secondary_panel:set_lefttop(primary_panel:righttop())
	self._loadout_panel:set_left(self._info_panel:left())
	self._loadout_panel:set_top(self._info_panel:bottom() + PADDING)

	local background = self._loadout_panel:rect({
		alpha = 0.2,
		layer = -1,
		color = Color(255, 0, 0, 0) / 255
	})
	local melee_panel = self._loadout_panel:panel({
		w = 128,
		h = 64
	})
	local throw_panel = self._loadout_panel:panel({
		w = 128,
		h = 64
	})
	local deploy_panel = self._loadout_panel:panel({
		w = 64,
		h = 64
	})
	local armor_panel = self._loadout_panel:panel({
		w = 64,
		h = 64
	})

	self:create_melee(melee_panel, outfit, tweak_data.blackmarket.melee_weapons[outfit.melee_weapon], "textures/pd2/blackmarket/icons/melee_weapons/")
	self:create_item(throw_panel, outfit.grenade, tweak_data.blackmarket.projectiles[outfit.grenade], "textures/pd2/blackmarket/icons/grenades/")
	self:create_item(deploy_panel, outfit.deployable, tweak_data.blackmarket.deployables[outfit.deployable], "textures/pd2/blackmarket/icons/deployables/")
	self:create_item(armor_panel, outfit.armor, tweak_data.blackmarket.armors[outfit.armor], "textures/pd2/blackmarket/icons/armors/")
	melee_panel:set_lefttop(secondary_panel:righttop())
	armor_panel:set_lefttop(melee_panel:righttop())
	throw_panel:set_leftbottom(secondary_panel:rightbottom())
	deploy_panel:set_lefttop(throw_panel:righttop())
	self._loadout_panel:set_w(deploy_panel:right())
	self._loadout_panel:set_h(primary_panel:bottom())
	BoxGuiObject:new(self._loadout_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	return true
end

function IngameWaitingGui:create_item(panel, outfit_item, tweak_data, folder)
	local w = panel:w()
	local h = panel:h()

	if outfit_item and outfit_item ~= "nil" then
		local guis_catalog = "guis/"
		local bundle_folder = tweak_data and tweak_data.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		local item_bitmap = panel:bitmap({
			alpha = 0.8,
			texture = guis_catalog .. folder .. outfit_item,
			w = w,
			h = h
		})
	else
		self:create_empty(panel)
	end
end

function IngameWaitingGui:create_melee(panel, outfit, ...)
	return self:create_item(panel, outfit.melee_weapon, ...)
end

function IngameWaitingGui:create_empty(panel)
	local empty_bitmap = panel:bitmap({
		texture = "guis/textures/pd2/none_icon",
		alpha = 0.8,
		w = panel:w(),
		h = panel:h()
	})
	local aspect = empty_bitmap:texture_width() / math.max(1, empty_bitmap:texture_height())

	empty_bitmap:set_w(empty_bitmap:h() * aspect)
	empty_bitmap:set_center_x(panel:center_x())
end

function IngameWaitingGui:create_weapon(weapon, panel)
	local w = panel:w()
	local h = panel:h()

	if weapon.factory_id then
		local primary_id = managers.weapon_factory:get_weapon_id_by_factory_id(weapon.factory_id)
		local texture, rarity = managers.blackmarket:get_weapon_icon_path(primary_id, weapon.cosmetics)
		local primary_bitmap = panel:bitmap({
			alpha = 0.8,
			layer = 1,
			texture = texture,
			w = w,
			h = h
		})
		local aspect = primary_bitmap:texture_height() / math.max(1, primary_bitmap:texture_width())

		primary_bitmap:set_h(primary_bitmap:w() * aspect)
		primary_bitmap:set_center_y(panel:center_y())

		if rarity then
			local rarity_bitmap = panel:bitmap({
				blend_mode = "add",
				rotation = 360,
				texture = rarity
			})
			local texture_width = rarity_bitmap:texture_width()
			local texture_height = rarity_bitmap:texture_height()
			local panel_width = primary_bitmap:w()
			local panel_height = primary_bitmap:h()
			local tw = texture_width
			local th = texture_height
			local pw = panel_width
			local ph = panel_height

			if tw == 0 or th == 0 then
				Application:error("[TeamLoadoutItem] BG Texture size error!:", "width", tw, "height", th)

				tw = 1
				th = 1
			end

			local sw = math.min(pw, ph * tw / th)
			local sh = math.min(ph, pw / (tw / th))

			rarity_bitmap:set_size(math.round(sw), math.round(sh))
			rarity_bitmap:set_center(primary_bitmap:center())
		end

		local perk_index = 0
		local perks = managers.blackmarket:get_perks_from_weapon_blueprint(weapon.factory_id, weapon.blueprint)

		if table.size(perks) > 0 then
			for perk in pairs(perks) do
				if perk ~= "bonus" then
					local texture = "guis/textures/pd2/blackmarket/inv_mod_" .. perk

					if DB:has(Idstring("texture"), texture) then
						local perk_object = panel:bitmap({
							w = 16,
							h = 16,
							alpha = 0.8,
							layer = 2,
							texture = texture
						})

						perk_object:set_rightbottom(math.round(panel:right() - perk_index * 16), math.round(panel:bottom() - 5))

						perk_index = perk_index + 1
					end
				end
			end
		end

		local factory = tweak_data.weapon.factory.parts
		local parts = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("bonus", weapon.factory_id, weapon.blueprint) or {}
		local stats, custom_stats, has_stat, has_team = nil
		local textures = {}

		for _, part_id in ipairs(parts) do
			stats = factory[part_id] and factory[part_id].stats or false
			custom_stats = factory[part_id] and factory[part_id].custom_stats or false
			has_stat = stats and table.size(stats) > 1 and true or false

			if custom_stats and (custom_stats.exp_multiplier or custom_stats.money_multiplier) then
				has_team = true
			else
				has_team = false
			end

			if has_stat then
				table.insert(textures, "guis/textures/pd2/blackmarket/inv_mod_bonus_stats")
			end

			if has_team then
				table.insert(textures, "guis/textures/pd2/blackmarket/inv_mod_bonus_team")
			end
		end

		if #textures == 0 and weapon.cosmetics and weapon.cosmetics.bonus and not managers.job:is_current_job_competitive() then
			local bonus_data = tweak_data.economy.bonuses[tweak_data.blackmarket.weapon_skins[weapon.cosmetics.id].bonus]
			has_stat = bonus_data and bonus_data.stats and true or false
			has_team = bonus_data and (bonus_data.exp_multiplier or bonus_data.money_multiplier) and true or false

			if has_stat then
				table.insert(textures, "guis/textures/pd2/blackmarket/inv_mod_bonus_stats")
			end

			if has_team then
				table.insert(textures, "guis/textures/pd2/blackmarket/inv_mod_bonus_team")
			end
		end

		for _, texture in ipairs(table.list_union(textures)) do
			if DB:has(Idstring("texture"), texture) then
				local perk_object = panel:bitmap({
					w = 16,
					h = 16,
					alpha = 0.8,
					layer = 2,
					texture = texture
				})

				perk_object:set_rightbottom(math.round(panel:right() - perk_index * 16), math.round(panel:bottom() - 5))

				perk_index = perk_index + 1
			end
		end
	end
end

function IngameWaitingGui:dummy_trigger()
	local btn = self._current_btn.button
	local _ = btn and btn:trigger()
end

function IngameWaitingGui:dummy_set_highlight(highlight)
	if self._highlighted == highlight then
		return
	end

	self._highlighted = highlight

	self._background:set_visible(highlight)

	local btn = self._current_btn.button

	if not btn then
		return
	end

	btn:set_highlighted(highlight)
end

function IngameWaitingGui:move_left()
	if not self._highlighted then
		return
	end

	if self._current_btn.index == 1 then
		self:set_current_button(self:prev_page() and #self._buttons or 1)
	else
		self:set_current_button(self._current_btn.index - 1)
	end
end

function IngameWaitingGui:move_right()
	if not self._highlighted then
		return
	end

	if self._current_btn.index == #self._buttons then
		self:set_current_button(self:next_page() and 1 or #self._buttons)
	else
		self:set_current_button(self._current_btn.index + 1)
	end
end

function IngameWaitingGui:prev_page()
	local page = self:calc_prev()

	if page then
		self:set_panel_for(page)

		return true
	end

	return false
end

IngameWaitingGui.previous_page = IngameWaitingGui.prev_page

function IngameWaitingGui:next_page()
	local page = self:calc_next()

	if page then
		self:set_panel_for(page)

		return true
	end

	return false
end

function IngameWaitingGui:mouse_moved(o, x, y)
	if not self._content_panel:visible() then
		return
	end

	if self._content_panel:inside(x, y) then
		if not self._highlighted then
			self:dummy_set_highlight(true)

			if self._dummy_item then
				managers.menu:active_menu().logic:mouse_over_select_item(self._dummy_item.name, false)
			end
		end
	else
		return
	end

	for k, btn in pairs(self._buttons) do
		if btn:panel():inside(x, y) then
			self:set_current_button(k)

			return true, "link"
		end
	end

	self._next_arrow:set_highlighted(self._next_arrow:panel():inside(x, y))
	self._prev_arrow:set_highlighted(self._prev_arrow:panel():inside(x, y))

	if self._next_arrow._highlighted or self._prev_arrow._highlighted then
		return true, "link"
	end
end

function IngameWaitingGui:special_btn_pressed(button)
	print(button)

	for k, btn in pairs(self._buttons) do
		if btn.binding == button then
			btn:trigger()
		end
	end
end

function IngameWaitingGui:mouse_pressed(button, x, y)
	if not self._content_panel:visible() or button ~= Idstring("0") then
		return
	end

	if not self._content_panel:inside(x, y) then
		return
	end

	for k, btn in pairs(self._buttons) do
		if btn:panel():inside(x, y) then
			btn:trigger()

			return
		end
	end

	local t = self._next_arrow:panel():inside(x, y) and self:next_page()
	local t = self._prev_arrow:panel():inside(x, y) and self:prev_page()
end

function IngameWaitingGui:set_current_button(index)
	index = math.clamp(1, index or 1, #self._buttons)
	local current = self._current_btn.button
	local target = self._buttons[index]
	self._current_btn = {
		button = target,
		index = index
	}
	local t1 = current and current:set_highlighted(false)
	local t0 = target and target:set_highlighted(self._highlighted)
end

IngameWaitingButton = IngameWaitingButton or class()

function IngameWaitingButton:init(parent_panel, text, binding, callback)
	self._panel = parent_panel:panel()
	self._callback = callback
	self.binding = binding and Idstring(binding)
	self._text = self._panel:text({
		text = text,
		font = text_font,
		font_size = text_font_size,
		color = font_color_rest
	})

	make_fine_text(self._text)
	self._panel:set_size(self._text:size())

	return self._panel
end

function IngameWaitingButton:set_highlighted(highlighted)
	self._highlighted = highlighted

	self._text:set_color(highlighted and font_color_highlighted or font_color_rest)
end

function IngameWaitingButton:panel()
	return self._panel
end

function IngameWaitingButton:trigger()
	if self._callback then
		self._callback()
	end
end
