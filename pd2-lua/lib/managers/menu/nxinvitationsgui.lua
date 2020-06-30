NXInvitationsGui = NXInvitationsGui or class(TextBoxGui)

function NXInvitationsGui:init(...)
	local ws, title, text, content_data, config = ...
	config.is_title_outside = true
	config.nx_forced_button_h = 56
	config.w = 708
	config.forced_h = 377
	config.type = "invitations"
	config.title_font_size = 36
	config.use_indicator = false
	config.make_text_a_panel = true
	self.want_mouse_press_events = true
	self.force_scroll_bar_visible = false
	self.invo_list = {}
	self.invo_highlight = 0
	self.old_size = 0
	self.pending_change = false
	self.block_changes = false
	self.action = nil
	self.action_args = nil
	self._color_bg_normal = Color(0.14, 0.21, 0.25)
	self._color_bg_highlighted = Color(0.03, 0.29, 0.41)
	self._color_bg_blip = Color.white
	self._color_fg_normal = Color(1, 1, 1)
	self._color_fg_old = Color(0.24, 0.54, 0.62)
	self._color_fg_highlighted = Color.white
	self._color_fg_blip = Color(0.03, 0.29, 0.41)
	self._color_bg_button_normal = Color(0.01, 0.65, 0.96)
	self._color_bg_button_blip = Color.white

	NXInvitationsGui.super.init(self, ...)
end

function NXInvitationsGui:_create_text_box(ws, title, text_field, content_data, config)
	self.invo_list = {}
	self.invo_highlight = 0
	self.old_size = 0
	self.pending_change = false
	self.block_changes = false
	self.action = nil
	self.action_args = nil
	self.dialog = self.dialog or content_data and content_data.dialog
	local result = NXInvitationsGui.super._create_text_box(self, ws, title, text_field, content_data, config)

	if self._ws then
		local info_area = self._text_box:child("info_area")
		self.envelope = self._ws:panel():bitmap({
			texture = "guis/textures/pd2/feature_crimenet_heat",
			name = "icon",
			width = 73,
			height = 68,
			alpha = 1,
			align = "right",
			halign = "right",
			vertical = "bottom",
			valign = "bottom",
			y = 14,
			x = 285,
			color = Color.white,
			layer = self._init_layer + 2,
			texture_rect = {
				31,
				36,
				194,
				173
			}
		})
		local buttons_panel = self._text_box_buttons_panel
		local bph = buttons_panel:h()
		local bpl = buttons_panel:left()
		self.back_button = info_area:panel({
			name = "back_button",
			w = 0,
			layer = 1,
			x = bpl,
			y = buttons_panel:y(),
			h = bph
		})
		self.back_button_bg = self.back_button:rect({
			blend_mode = "normal",
			valign = "grow",
			halign = "grow",
			alpha = 0.37,
			layer = 2,
			color = self._color_bg_button_normal
		})
		local text_props = {
			word_wrap = false,
			vertical = "left",
			alpha = 1,
			wrap = false,
			font_size = 32,
			align = "left",
			layer = 3,
			font = "fonts/font_medium_mf",
			halign = "left",
			valign = "top",
			color = Color.white,
			text = managers.localization:text("nx64_noti_button_back")
		}
		local text = self.back_button:text(text_props)
		local _, _, w, h = text:text_rect()

		text:set_size(w, h)
		self.back_button:set_w(w + 64)
		self.back_button:set_right(bpl)
		text:set_world_center(self.back_button:world_center())

		self._back_text = text
		text_props.text = managers.localization:text("nx64_noti_legend_view_invite")
		text = info_area:text(text_props)
		_, _, w, h = text:text_rect()

		text:set_size(w, h)
		text:set_world_center_y(self.back_button:world_center_y())
		text:set_world_right(self.back_button:world_left() - 23)

		self._label1_text = text
	end

	self.invo_highlight = 0

	self:_refresh_list_layout()

	function self.dialog._banner_link.list_changed_callback()
		self:list_changed()
	end

	self:list_changed()

	return result
end

function NXInvitationsGui:close()
	self.block_changes = true
	self.dialog._banner_link.list_changed_callback = nil

	if self.invo_list ~= nil then
		for i, p in ipairs(self.invo_list) do
			self:_destroy_item(p)
		end
	end

	self.invo_list = nil
	self.invo_highlight = 0
	self.old_size = 0
	self.pending_change = false
	self.action = nil
	self.action_args = nil
	local info_area = alive(self._text_box) and self._text_box:child("info_area")

	if alive(self.envelope) and alive(self._ws) then
		self.envelope = self._ws:panel():remove(self.envelope)
	end

	if alive(info_area) then
		if alive(self.back_button) then
			if alive(self.back_button_bg) then
				self.back_button_bg = self.back_button:remove(self.back_button_bg)
			end

			if alive(self._back_text) then
				self._back_text = self.back_button:remove(self._back_text)
			end

			self.back_button = info_area:remove(self.back_button)
		end

		if alive(self._label1_text) then
			self._label1_text = info_area:remove(self._label1_text)
		end
	end

	NXInvitationsGui.super.close(self)
end

function NXInvitationsGui:set_centered()
	NXInvitationsGui.super.set_centered(self)
	self.envelope:set_world_right(self._text_box:world_x() - 12)
	self.envelope:set_world_y(self._text_box:world_y() - 37)
end

function NXInvitationsGui:_set_alpha(alpha)
	self.envelope:set_alpha(alpha)
	NXInvitationsGui.super._set_alpha(self, alpha)
end

function NXInvitationsGui:set_layer(layer)
	NXInvitationsGui.super.set_layer(self, layer)
	self.envelope:set_layer(self._panel:layer() + 2)
end

function NXInvitationsGui:set_corners_visible(item, visible)
	item.corners[1]:set_visible(visible)
	item.corners[2]:set_visible(visible)
	item.corners[3]:set_visible(visible)
	item.corners[4]:set_visible(visible)
end

function NXInvitationsGui:set_corners_selected(item, selected)
	local cornerSize = nil

	if selected then
		cornerSize = item.corner_visible_size
	else
		cornerSize = item.corner_hidden_size
	end

	item.corners[1]:set_texture_rect(0, 0, cornerSize, cornerSize)
	item.corners[2]:set_texture_rect(cornerSize, 0, -cornerSize, cornerSize)
	item.corners[3]:set_texture_rect(0, cornerSize, cornerSize, -cornerSize)
	item.corners[4]:set_texture_rect(cornerSize, cornerSize, -cornerSize, -cornerSize)
	item.corners[1]:set_size(cornerSize, cornerSize)
	item.corners[2]:set_size(cornerSize, cornerSize)
	item.corners[3]:set_size(cornerSize, cornerSize)
	item.corners[4]:set_size(cornerSize, cornerSize)
	item.corners[1]:set_left(0)
	item.corners[1]:set_top(0)
	item.corners[2]:set_right(item.panel:w())
	item.corners[2]:set_top(0)
	item.corners[3]:set_left(0)
	item.corners[3]:set_bottom(item.panel:h())
	item.corners[4]:set_right(item.panel:w())
	item.corners[4]:set_bottom(item.panel:h())
end

function NXInvitationsGui:_add_invitation(invitation)
	local newItem = {
		data = invitation,
		list_index = 1 + #self.invo_list
	}

	table.insert(self.invo_list, newItem)

	local panel = self._text_panel:panel({
		valign = "top",
		h = 46,
		halign = "left",
		w = 669,
		x = 0,
		layer = 0
	})
	newItem.highlighted = false
	newItem.panel = panel
	newItem.bg = panel:rect({
		alpha = 0.8,
		blend_mode = "normal",
		layer = 1,
		color = self._color_bg_normal
	})
	local label = managers.localization:text("nx64_noti_dialog_subject", {
		player_name = invitation.invited_by_name
	})
	newItem.text = panel:text({
		valign = "top",
		vertical = "top",
		y = 7,
		wrap = false,
		word_wrap = false,
		align = "left",
		font_size = 32,
		alpha = 1,
		font = "fonts/font_medium_mf",
		halign = "left",
		x = 10,
		layer = 2,
		text = label,
		color = invitation.new and self._color_fg_normal or self.color_fg_old
	})
	newItem.corners = {
		newItem.panel:bitmap({
			texture = "guis/textures/pd2/hud_corner",
			name = "TL",
			layer = 2,
			halign = "left",
			y = 0,
			visible = true,
			x = 0,
			valign = "top",
			color = Color.white
		}),
		newItem.panel:bitmap({
			texture = "guis/textures/pd2/hud_corner",
			name = "TR",
			layer = 2,
			halign = "right",
			y = 0,
			visible = true,
			x = 0,
			valign = "top",
			color = Color.white
		}),
		newItem.panel:bitmap({
			texture = "guis/textures/pd2/hud_corner",
			name = "BL",
			layer = 2,
			halign = "left",
			y = 0,
			visible = true,
			x = 0,
			valign = "bottom",
			color = Color.white
		}),
		newItem.panel:bitmap({
			texture = "guis/textures/pd2/hud_corner",
			name = "BR",
			layer = 2,
			halign = "right",
			y = 0,
			visible = true,
			x = 0,
			valign = "bottom",
			color = Color.white
		})
	}

	newItem.corners[1]:set_left(0)
	newItem.corners[1]:set_top(0)
	newItem.corners[2]:set_top(0)
	newItem.corners[3]:set_left(0)
	newItem.corners[3]:set_bottom(newItem.panel:h())
	newItem.corners[4]:set_bottom(newItem.panel:h())

	newItem.corner_visible_size = newItem.corners[1]:w()
	newItem.corner_hidden_size = 2

	self:_recalc_panel_width(newItem)
	self:set_corners_visible(newItem, true)
	self:set_corners_selected(newItem, false)
	self:_refresh_display_colour(newItem)
end

function NXInvitationsGui:_destroy_item(item)
	local panel = item.panel

	if alive(panel) then
		if alive(item.bg) then
			panel:remove(item.bg)
		end

		if alive(item.text) then
			panel:remove(item.text)
		end

		if alive(self._text_panel) then
			self._text_panel:remove(panel)
		end
	end

	item.panel = nil
	item.bg = nil
	item.text = nil
	item.highlighted = false
	item.list_index = 0
end

function NXInvitationsGui:_find_invitation(invitation)
	if invitation == nil then
		return 0
	end

	local li = invitation.list_index

	if li ~= nil and li > 0 and li <= #self.invo_list and self.invo_list[li] == invitation then
		return li
	end

	for i, p in ipairs(self.invo_list) do
		if p == invitation or p.data == invitation then
			return i
		end
	end

	for i, p in ipairs(self.invo_list) do
		if invitation.room_id == p.room_id and invitation.invited_by == p.invited_by then
			return i
		end
	end

	for i, p in ipairs(self.invo_list) do
		if invitation.invited_by_name == p.invited_by_name then
			return i
		end
	end

	return 0
end

function NXInvitationsGui:_refresh_list_layout()
	local num_items = #self.invo_list

	if self.invo_highlight == 0 then
		if num_items > 0 then
			self:_set_highlight(1)
		end
	elseif num_items < self.invo_highlight then
		self:_set_highlight(num_items)
	end

	for i, p in ipairs(self.invo_list) do
		p.panel:set_top((i - 1) * 50)

		p.list_index = i
	end

	if self.old_size ~= num_items then
		self._text_panel:set_h(num_items > 0 and num_items * 50 - 4 or 0)

		self.old_size = num_items

		self:_set_scroll_indicator()
	end

	self:scroll_to_highlight()
end

function NXInvitationsGui:_set_scroll_indicator()
	NXInvitationsGui.super._set_scroll_indicator(self)
	self:_recalc_panel_widths()
end

function NXInvitationsGui:_recalc_panel_widths()
	local full_width = self._scroll_panel:parent():width()

	self._scroll_panel:set_w(full_width)
	self._text_panel:set_w(full_width)

	for i, p in ipairs(self.invo_list) do
		self:_recalc_panel_width(p)
	end
end

function NXInvitationsGui:_recalc_panel_width(invo)
	local scroll_bar = self._text_box:child("scroll_bar")
	local w = 671

	if not scroll_bar:visible() then
		w = scroll_bar:world_right() - invo.panel:world_left() - 2
	end

	invo.panel:set_w(w)
	invo.bg:set_w(w)
	invo.corners[2]:set_right(w)
	invo.corners[4]:set_right(w)
end

function NXInvitationsGui:_refresh_display_colour(obj)
	obj.text:set_color(obj.data.new and self._color_fg_normal or self._color_fg_old)
end

function NXInvitationsGui:_set_highlight_state(obj, newState)
	if obj ~= nil and obj.highlighted ~= newState then
		obj.highlighted = newState

		obj.bg:set_color(newState and self._color_bg_highlighted or self._color_bg_normal)
		self:set_corners_selected(obj, newState)
		self:_refresh_display_colour(obj)
	end
end

function NXInvitationsGui:_set_highlight(newIndex, prevent_scroll)
	if self.invo_highlight == newIndex then
		return
	end

	local oldIndex = self.invo_highlight
	local totalItems = #self.invo_list

	if oldIndex > 0 and oldIndex <= totalItems then
		self:_set_highlight_state(self.invo_list[oldIndex], false)
	end

	if newIndex > 0 and newIndex <= totalItems then
		local obj = self.invo_list[newIndex]

		self:_set_highlight_state(obj, true)
	end

	self.invo_highlight = newIndex

	if not prevent_scroll then
		self:scroll_to_highlight()
	end
end

function NXInvitationsGui:move_highlight(diff)
	if self.action or self.animating then
		return
	end

	local numItems = #self.invo_list

	if numItems > 0 then
		local newPos = self.invo_highlight + diff

		if numItems < newPos then
			newPos = numItems
		end

		if newPos < 1 then
			newPos = 1
		end

		self:_set_highlight(newPos)
	end
end

function NXInvitationsGui:mouse_pressed(button, x, y)
	if self.action or self.animating then
		return true
	end

	if self.back_button:inside(x, y) then
		self:_press_back()
	end

	if self._scroll_panel:inside(x, y) then
		for i, p in ipairs(self.invo_list) do
			if p.panel:inside(x, y) then
				managers.menu:on_press_rumble()
				self:_set_highlight(i, true)
				self:_trigger_highlighted_item(true, false)

				return true
			end
		end
	end

	return NXInvitationsGui.super.mouse_pressed(self, button, x, y)
end

function NXInvitationsGui:clamp_scrolling()
	local window_h = self._scroll_panel:h()
	local content_h = self._text_panel:h()

	if content_h <= window_h then
		self._text_panel:set_y(0)
	else
		local wiggle = content_h - window_h
		local y = self._text_panel:y()

		if y > 0 then
			self._text_panel:set_y(0)
		elseif y < -wiggle then
			self._text_panel:set_y(-wiggle)
		end
	end
end

function NXInvitationsGui:scroll_to_highlight()
	local hl = self.invo_highlight
	local totalItems = #self.invo_list

	if hl < 1 or totalItems < hl then
		return
	end

	local item = self.invo_list[hl]
	local h = item.panel:h()
	local gap = h * 0.75
	local min_world_top = self._scroll_panel:world_top() + gap
	local max_world_top = self._scroll_panel:world_bottom() - gap - h
	local where = item.panel:world_top()
	local offset = 0
	local old_y = self._text_panel:y()

	if where < min_world_top then
		self._text_panel:set_y(self._text_panel:y() + min_world_top - where)
	elseif max_world_top < where then
		self._text_panel:set_y(self._text_panel:y() + max_world_top - where)
	end

	self:clamp_scrolling()

	if self._text_panel:y() ~= old_y then
		self:_check_scroll_indicator_states()
	end
end

function NXInvitationsGui:invi_update(t, dt)
	if self.action then
		if not self.animating and self:can_update() then
			if self.action == "query" then
				if not self:_open_accept_dialog(self.action_args) then
					self.action = nil
					self.action_args = nil
					self.block_changes = false

					if self.pending_change then
						self:list_changed()
					end
				end
			elseif self.action == "back" then
				self.action_args = nil
				self.action = nil
				self.block_changes = true

				self.dialog:remove_mouse()
				self.dialog:fade_out_close()
			elseif self.action == "waiting_for_join_result" then
				-- Nothing
			elseif self.action == "join" then
				local invitation = self.action_args
				self.action_args = nil
				self.action = "waiting_for_join_result"
				self.block_changes = true
				managers.system_menu.force_override = true

				local function join_cb(result)
					if self.action ~= "waiting_for_join_result" or self.dialog == nil or self.dialog:is_closing() then
						print("AWOOGA - BAD STATE!")

						result = false
					end

					managers.system_menu.force_override = nil
					self.action = nil

					if result then
						self.dialog:close()
					else
						self.block_changes = false

						self:list_changed()
					end
				end

				local result = managers.network.matchmake:nx_join_via_invitation_list(invitation.data, join_cb)

				if result == 1 then
					-- Nothing
				elseif result then
					managers.system_menu.force_override = nil
					self.action = nil

					self.dialog:close()
				else
					managers.system_menu.force_override = nil
					self.action = nil
					self.block_changes = false

					self:list_changed()
				end
			end
		end
	elseif self.pending_change and self.action == nil and not self.animating and not self.block_changes and self:can_update() then
		self:list_changed()
	end
end

function NXInvitationsGui:_press_back(skip_anim)
	if self.animating or self.action then
		return
	end

	self.action = "back"
	self.action_args = nil

	if not skip_anim then
		self.animating = true
		local blip_time = 0.1

		if managers.menu:active_menu() then
			managers.menu:active_menu().renderer:disable_input(blip_time * 1.5)
		end

		self.back_button_bg:animate(function (o, self, blip_time)
			o:set_color(self._color_bg_button_blip)
			safe_wait(blip_time)
			o:set_color(self._color_bg_button_normal)

			self.animating = false
		end, self, blip_time)
	end
end

function NXInvitationsGui:return_from_dialog(result)
	if result == "cancel" then
		self.action = nil
		self.action_args = nil
		self.block_changes = false
	elseif result == "accept" then
		self.action = "join"
		self.block_changes = true
	end
end

function NXInvitationsGui:can_update()
	return not self.dialog._fade_in_time and not self.dialog._fade_out_time and not self.dialog._data.delay_input
end

function NXInvitationsGui:list_changed()
	if not self:can_update() or self.block_changes or self.action or self.animating then
		self.pending_change = true

		return
	end

	self.pending_change = false
	local net_list = self:_get_net_list()

	if net_list ~= nil then
		self:_merge_in_new_list(net_list)
	end
end

function NXInvitationsGui:_open_accept_dialog(invitation_info)
	if invitation_info ~= nil and invitation_info.highlighted and invitation_info.list_index == self.invo_highlight and invitation_info.list_index ~= 0 then
		local dialog_data = {
			title = managers.localization:text("nx64_noti_dialog_subject", {
				player_name = invitation_info.data.invited_by_name
			}),
			text = "",
			force = true,
			add_cancel_trigger = true,
			cancel_is_button_zero = true,
			click_outside_to_cancel = true,
			type = "system_menu2",
			id = "nx_invitation_accept"
		}
		local cancel_button = {
			text = managers.localization:text("dialog_cancel"),
			callback_func = function ()
				self:return_from_dialog("cancel")
			end,
			cancel_button = true
		}
		local accept_button = {
			text = managers.localization:text("nx64_noti_invite_accept"),
			callback_func = function ()
				self:return_from_dialog("accept")
			end
		}

		function dialog_data.callback_func(button_index, data)
			if button_index == 0 then
				self:return_from_dialog("cancel")
			end
		end

		dialog_data.button_list = {
			cancel_button,
			accept_button
		}
		self.block_changes = true

		managers.system_menu:show(dialog_data)
		NX64Online:invite_old(invitation_info.data.room_id)

		return true
	end

	return false
end

function NXInvitationsGui:_trigger_highlighted_item(is_touch, skip_blip)
	if self.action then
		return
	end

	local list = self.invo_list
	local index = self.invo_highlight

	if index < 1 or index > #list then
		return
	end

	local invitation_info = list[index]

	if skip_blip then
		self:_open_accept_dialog(invitation_info)
	else
		local bg = invitation_info.bg

		if not alive(bg) then
			self:_open_accept_dialog(invitation_info)
		else
			self.animating = true
			self.action = "query"
			self.action_args = invitation_info
			local blip_time = 0.1

			if managers.menu:active_menu() then
				managers.menu:active_menu().renderer:disable_input(blip_time * 1.5)
			end

			bg:animate(function (o)
				o:set_color(self._color_bg_blip)
				invitation_info.text:set_color(self._color_fg_blip)
				safe_wait(blip_time)
				o:set_color(self._color_bg_highlighted)
				invitation_info.text:set_color(self._color_fg_highlighted)

				self.animating = false
			end)
		end
	end
end

function NXInvitationsGui:find_highlit_roomid()
	for i, p in ipairs(self.invo_list) do
		if p.highlighted then
			return p.data.room_id, i
		end
	end

	return nil, nil
end

function NXInvitationsGui:find_room_invite_idx(room_id)
	for i, p in ipairs(self.invo_list) do
		if p.data.room_id == room_id then
			return i
		end
	end

	return nil
end

function NXInvitationsGui:_merge_in_new_list(new_list)
	local refresh = false
	local highlighted_roomid, highlighted_idx = self:find_highlit_roomid()
	local old_y = self._text_panel:y()

	if self.invo_list ~= nil then
		for i, p in ipairs(self.invo_list) do
			self:_destroy_item(p)
		end
	end

	local our_list = {}
	self.invo_list = our_list

	for key, inv in ipairs(new_list) do
		self:_add_invitation(inv)
	end

	local room_idx = self:find_room_invite_idx(highlighted_roomid)
	room_idx = room_idx and room_idx or highlighted_idx

	if room_idx and room_idx > #our_list then
		if #our_list > 0 then
			room_idx = #our_list
		else
			room_idx = nil
		end
	end

	self:_refresh_list_layout()

	if room_idx ~= nil then
		self:_set_highlight_state(our_list[room_idx], true)

		self.invo_highlight = room_idx

		self._text_panel:set_y(old_y)
		self:scroll_to_highlight()
	end
end

function NXInvitationsGui:_get_net_list()
	return NX64Online:invite_get_list()
end
