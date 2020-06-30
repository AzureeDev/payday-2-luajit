core:module("SystemMenuManager")

NXInvitationBanner = NXInvitationBanner or class()
NXInvitationBanner.list_changed_callback = nil

function NXInvitationBanner:init()
	if alive(self._noti_ws) then
		managers.gui_data:destroy_workspace(self._noti_ws)

		self._noti_ws = nil
	end

	self._noti_ws = managers.gui_data:create_1280_workspace()
	local noti = {}
	self.noti = noti
	local bw = 346
	local bh = 102
	local bglayer = 1050
	noti.box = self._noti_ws:panel():panel({
		name = "noti_panel",
		y = 25,
		x = 44,
		width = bw,
		height = bh,
		layer = bglayer
	})
	local box = noti.box
	noti.bg = box:rect({
		name = "bg",
		alpha = 0.9,
		color = Color(0, 0.49, 0.71),
		layer = bglayer
	})
	noti.cornerTL = box:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "TL",
		h = 8,
		halign = "left",
		w = 8,
		y = 0,
		x = 0,
		valign = "top",
		color = Color.white,
		layer = bglayer + 1,
		texture_rect = {
			0,
			0,
			8,
			8
		}
	})
	noti.cornerTR = box:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "TR",
		h = 8,
		halign = "left",
		w = 8,
		y = 0,
		valign = "top",
		color = Color.white,
		layer = bglayer + 1,
		x = bw - 8,
		texture_rect = {
			8,
			0,
			-8,
			8
		}
	})
	noti.cornerBL = box:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "BL",
		h = 8,
		halign = "left",
		w = 8,
		x = 0,
		valign = "top",
		color = Color.white,
		layer = bglayer + 1,
		y = bh - 8,
		texture_rect = {
			0,
			8,
			8,
			-8
		}
	})
	noti.cornerBR = box:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "BR",
		h = 8,
		halign = "left",
		w = 8,
		valign = "top",
		color = Color.white,
		layer = bglayer + 1,
		x = bw - 8,
		y = bh - 8,
		texture_rect = {
			8,
			8,
			-8,
			-8
		}
	})
	local ts = 218
	local ls = 63
	local tx = (bw - ts) * 0.5
	local ly = (bh - ls) * 0.5
	noti.edgeT = box:rect({
		name = "edgeT",
		h = 2,
		y = 0,
		color = Color.white,
		layer = bglayer + 1,
		x = tx,
		w = ts
	})
	noti.edgeB = box:rect({
		name = "edgeB",
		h = 2,
		color = Color.white,
		layer = bglayer + 1,
		x = tx,
		y = bh - 2,
		w = ts
	})
	noti.edgeL = box:rect({
		w = 2,
		name = "edgeL",
		x = 0,
		color = Color.white,
		layer = bglayer + 1,
		y = ly,
		h = ls
	})
	noti.edgeR = box:rect({
		w = 2,
		name = "edgeR",
		color = Color.white,
		layer = bglayer + 1,
		x = bw - 2,
		y = ly,
		h = ls
	})
	noti.icon = box:bitmap({
		texture = "guis/textures/pd2/feature_crimenet_heat",
		height = 40,
		name = "icon",
		width = 44,
		halign = "right",
		align = "right",
		vertical = "bottom",
		valign = "bottom",
		y = 14,
		x = 285,
		color = Color.white,
		layer = bglayer + 1,
		texture_rect = {
			31,
			36,
			194,
			173
		}
	})
	noti.title = box:text({
		vertical = "top",
		font = "fonts/font_small_mf",
		font_size = 18,
		align = "left",
		text = managers.localization:text("nx64_noti_received_from"),
		color = Color.black,
		layer = bglayer + 1
	})

	noti.title:set_position(15, 12)

	local str1 = managers.localization:text("nx64_noti_press_to_view_p1")
	local str2 = managers.localization:text("nx64_noti_press_to_view_p2")
	local str3 = managers.localization:text("nx64_noti_press_to_view_p3")

	if str2 ~= "" then
		if str1 ~= "" and string.sub(str1, -1, -1) ~= " " then
			str1 = str1 .. " "
		end

		if str3 ~= "" and string.sub(str3, 1, 1) ~= " " then
			str3 = " " .. str3
		end
	end

	local press_panel = box:panel({
		y = 75,
		x = 16,
		layer = bglayer + 1,
		w = bw - 16,
		h = bh - 75
	})
	noti.press1 = press_panel
	noti.press2 = press_panel:text({
		vertical = "top",
		font = "fonts/font_small_mf",
		font_size = 15,
		align = "left",
		text = str1,
		color = Color.black,
		layer = bglayer + 1
	})
	noti.press3 = press_panel:text({
		vertical = "top",
		font = "fonts/font_small_mf",
		font_size = 15,
		align = "left",
		text = str2,
		color = Color.white,
		layer = bglayer + 1
	})
	noti.press4 = press_panel:text({
		vertical = "top",
		font = "fonts/font_small_mf",
		font_size = 15,
		align = "left",
		text = str3,
		color = Color.black,
		layer = bglayer + 1
	})

	noti.press2:set_shape(noti.press2:text_rect())
	noti.press3:set_shape(noti.press3:text_rect())
	noti.press4:set_shape(noti.press4:text_rect())
	noti.press2:set_position(0, 0)
	noti.press3:set_position(noti.press2:right(), 0)
	noti.press4:set_position(noti.press3:right(), 0)

	self.button_visible = true
	noti.pname = box:text({
		text = "PLAYER NAME",
		vertical = "center",
		font = "fonts/font_large_mf",
		font_size = 44,
		align = "left",
		color = Color.white,
		layer = bglayer + 1
	})

	noti.pname:set_shape(14, 27, bw - 14, 50)
	self._noti_ws:hide()

	self.animating = false
	self.middle_of_anim = false
	self.button_enabled = false

	NX64Online:set_matchmaking_callback("invite_list_changed", "NXInvitationBanner:init", function ()
		if NXInvitationBanner.list_changed_callback ~= nil then
			NXInvitationBanner.list_changed_callback()
		end

		self:kick_anim()
	end)
	self:kick_anim()
end

function NXInvitationBanner:destroy()
	NX64Online:set_matchmaking_callback("invite_list_changed", "NXInvitationBanner:init", nil)

	if self.noti and alive(self.noti.box) then
		self.noti.box:stop()
	end

	if alive(self._noti_ws) then
		managers.gui_data:destroy_workspace(self._noti_ws)

		self._noti_ws = nil
	end

	self.noti = nil
end

function NXInvitationBanner:resolution_changed()
	if self._noti_ws ~= nil then
		managers.gui_data:layout_1280_workspace(self._noti_ws)
	end
end

function NXInvitationBanner:update_button_visibility()
	local state = self:is_okay_to_show_notification()
	local show = state == 2
	local noti = self.noti

	if noti ~= nil and show ~= self.button_visible then
		self.button_visible = show

		noti.press1:set_visible(show)
	end

	self.button_enabled = self.middle_of_anim and show

	return state
end

function NXInvitationBanner:kick_anim()
	if not self.animating and self.noti and alive(self.noti.box) and self:is_okay_to_show_notification() and self:is_there_something_to_show(false) then
		self.animating = true

		self.noti.box:animate(self.show_animation, self)
	end
end

function NXInvitationBanner:opening_list_box()
	if self._showing then
		self._showing = 99
	end
end

function NXInvitationBanner:is_okay_to_open_invitations()
	if self:is_okay_to_show_notification() ~= 2 then
		return false
	end

	if self.button_enabled then
		return true
	end

	local menu = managers.menu:active_menu()
	local logic = menu and menu.logic
	local node = logic and logic:selected_node()
	local params = node and node:parameters()
	local flag = params and params.allow_nx_invites_menu

	if flag then
		if flag == "online" then
			if managers.network.matchmake:is_inet_mode() then
				return true
			end
		else
			return true
		end
	end

	return false
end

function NXInvitationBanner:is_okay_to_show_notification()
	local stp = rawget(_G, "setup")

	if stp and stp:has_queued_exec() then
		return false
	end

	if managers.system_menu:is_active() then
		return 1
	end

	local gsm = _G.game_state_machine

	if gsm == nil or gsm.current_state_name == nil then
		return 1
	else
		local currentState = gsm:current_state_name()

		if currentState == "menu_titlescreen" or currentState == "bootup" then
			return 1
		end
	end

	return 2
end

function NXInvitationBanner:is_there_something_to_show(extract)
	local invitations = NX64Online:invite_get_list()

	if invitations ~= nil then
		for id in pairs(invitations) do
			local el = invitations[id]

			if not el.read then
				if extract then
					el.read = true

					NX64Online:invite_read(el.room_id)

					return el.invited_by_name
				else
					return true
				end
			end
		end
	end

	return nil
end

function NXInvitationBanner.show_animation(obj, self)
	coroutine.yield()
	coroutine.yield()

	local okay_to_show = self:is_okay_to_show_notification()
	local checked = false

	while okay_to_show do
		if okay_to_show ~= 2 then
			if not checked then
				if not self:is_there_something_to_show(false) then
					break
				end

				checked = true
			end

			local totalTime = 5

			while totalTime > 0 do
				local dt = coroutine.yield()

				if dt <= 0 then
					dt = 0.03333333333333333
				end

				totalTime = totalTime - dt
			end
		else
			checked = false
			local new_name = self:is_there_something_to_show(true)

			if not new_name then
				break
			end

			self.noti.pname:set_text(new_name)
			self._noti_ws:show()

			self._showing = true
			local startX = -60 - obj:w()
			local targetX = 60
			local startY = 36
			local targetY = -60 - obj:h()

			obj:set_top(startY)

			local totalTime = 0.66
			local frac = 0

			while frac < 1 do
				local frac2 = frac * (2 - frac)
				local alpha = 1 - (1 - frac) * (1 - frac)

				obj:set_alpha(alpha)
				obj:set_left((targetX - startX) * frac2 + startX)
				self:update_button_visibility()

				local step = coroutine.yield()

				if step == 0 then
					step = 0.03333333333333333
				end

				frac = frac + step / totalTime
			end

			obj:set_left(targetX)

			self.middle_of_anim = true
			totalTime = 8

			while totalTime > 0 do
				if self:update_button_visibility() == false then
					totalTime = 0
				end

				local step = coroutine.yield()

				if step == 0 then
					step = 0.03333333333333333
				end

				totalTime = totalTime - step

				if self._showing == 99 then
					totalTime = 0
				end
			end

			self.middle_of_anim = false
			self.button_enabled = false
			frac = 0
			totalTime = 0.66

			while frac < 1 do
				local frac2 = frac * frac
				local alpha = 1 - frac * frac

				obj:set_alpha(alpha)
				obj:set_top((targetY - startY) * frac2 + startY)

				local step = coroutine.yield()

				if step == 0 then
					step = 0.03333333333333333
				end

				frac = frac + step / totalTime
			end

			obj:set_top(targetY)
			self._noti_ws:hide()

			self._showing = false
		end

		okay_to_show = self:is_okay_to_show_notification()
	end

	self.animating = false
end

NXInvitationsDialog = NXInvitationsDialog or class(GenericDialog)
NXInvitationsDialog.PANEL_SCRIPT_CLASS = "NXInvitationsGui"

function NXInvitationsDialog:init(manager, data, is_title_outside)
	self._menu_up_func = callback(self, self, "menu_up_callback")
	self._menu_down_func = callback(self, self, "menu_down_callback")
	data.add_cancel_trigger = true
	data.dialog = self
	self._banner_link = NXInvitationBanner
	self._crimenet_paused = managers.crimenet and managers.crimenet:is_active()

	if self._crimenet_paused then
		managers.crimenet:deactivate()

		if not managers.menu:is_pc_controller() then
			managers.menu:active_menu().input:deactivate_controller_mouse()
		end

		if managers.menu:is_switch_controller() then
			managers.menu:active_menu().input:activate_mouse(nil, true)
		end
	end

	NXInvitationsDialog.super.init(self, manager, data, is_title_outside)
end

function NXInvitationsDialog:close()
	if self._crimenet_paused then
		managers.crimenet:activate()

		if not managers.menu:is_pc_controller() then
			managers.menu:active_menu().input:activate_controller_mouse()
		end
	end

	NXInvitationsDialog.super.close(self)
end

function NXInvitationsDialog:dialog_cancel_callback()
	self._panel_script:_press_back()
end

function NXInvitationsDialog:button_pressed_callback()
	self._panel_script:_trigger_highlighted_item(false, false)
end

function NXInvitationsDialog:menu_up_callback()
	self._panel_script:move_highlight(-1)
end

function NXInvitationsDialog:menu_down_callback()
	self._panel_script:move_highlight(1)
end

function NXInvitationsDialog:set_extra_triggers(enabled)
	if enabled then
		self._controller:add_trigger("menu_up", self._menu_up_func)
		self._controller:add_trigger("menu_down", self._menu_down_func)
	else
		self._controller:remove_trigger("menu_up", self._menu_up_func)
		self._controller:remove_trigger("menu_down", self._menu_down_func)
	end

	NXInvitationsDialog.super.set_extra_triggers(self, enabled)
end

function NXInvitationsDialog:update(t, dt)
	NXInvitationsDialog.super.update(self, t, dt)
	self._panel_script:invi_update(t, dt)
end
