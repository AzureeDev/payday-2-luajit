CrimeSpreeContractBoxGui = CrimeSpreeContractBoxGui or class()

function CrimeSpreeContractBoxGui:init(ws, fullscreen_ws)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._panel = self._ws:panel():panel()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()
	self._peer_panels = {}

	if not self:_can_update() then
		for i = 1, tweak_data.max_players do
			self:_check_create_peer_panel(i)
		end
	end

	self._enabled = true
end

function CrimeSpreeContractBoxGui:set_enabled(enabled)
	self._enabled = enabled
end

function CrimeSpreeContractBoxGui:close()
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

function CrimeSpreeContractBoxGui:_can_update()
	return not Global.game_settings.single_player
end

function CrimeSpreeContractBoxGui:_check_create_peer_panel(peer_id)
	if not self._peer_panels[peer_id] and managers.network:session() then
		local peer = managers.network:session():peer(peer_id)

		if peer then
			local char_data = LobbyCharacterData:new(self._panel, peer)
			self._peer_panels[peer_id] = char_data
		end
	end

	return self._peer_panels[peer_id]
end

function CrimeSpreeContractBoxGui:update_character_menu_state(peer_id, state)
	if not self:_can_update() then
		return
	end

	local panel = self:_check_create_peer_panel(peer_id)

	if panel then
		panel:update_peer_id(peer_id)
		panel:update_character_menu_state(state)
	end
end

function CrimeSpreeContractBoxGui:update_character(peer_id)
	if not self:_can_update() then
		return
	end

	local panel = self:_check_create_peer_panel(peer_id)

	if panel then
		panel:update_peer_id(peer_id)
		panel:update_character()
	end
end

function CrimeSpreeContractBoxGui:update_bg_state(peer_id, state)
end

function CrimeSpreeContractBoxGui:set_character_panel_alpha(peer_id, alpha)
	if not self:_can_update() then
		return
	end

	local panel = self:_check_create_peer_panel(peer_id)

	if panel then
		panel:update_peer_id(peer_id)
		panel:set_alpha(alpha)
	end
end

function CrimeSpreeContractBoxGui:refresh()
end

function CrimeSpreeContractBoxGui:update(t, dt)
	if not self:_can_update() then
		return
	end

	for i = 1, 4 do
		self:update_character(i)
	end
end

function CrimeSpreeContractBoxGui:mouse_pressed(button, x, y)
	if not self:can_take_input() or not self:_can_update() then
		return
	end

	if button == Idstring("0") and self._peer_panels and SystemInfo:platform() == Idstring("WIN32") and MenuCallbackHandler:is_overlay_enabled() then
		for peer_id, object in pairs(self._peer_panels) do
			if alive(object:panel()) and object:panel():inside(x, y) then
				local peer = managers.network:session() and managers.network:session():peer(peer_id)

				if peer then
					Steam:overlay_activate("url", tweak_data.gui.fbi_files_webpage .. "/suspect/" .. peer:user_id() .. "/")

					return
				end
			end
		end
	end
end

function CrimeSpreeContractBoxGui:mouse_moved(x, y)
	if not self:can_take_input() or not self:_can_update() then
		return
	end

	local used = false
	local pointer = "arrow"

	if self._peer_panels and SystemInfo:platform() == Idstring("WIN32") and MenuCallbackHandler:is_overlay_enabled() then
		for peer_id, object in pairs(self._peer_panels) do
			if alive(object:panel()) and object:panel():inside(x, y) then
				used = true
				pointer = "link"
			end
		end
	end

	if used then
		return used, pointer
	end
end

function CrimeSpreeContractBoxGui:can_take_input()
	if managers.menu_component and managers.menu_component:crime_spree_modifiers() then
		return false
	end

	return true
end

function CrimeSpreeContractBoxGui:check_minimize()
	return false
end

function CrimeSpreeContractBoxGui:moved_scroll_bar()
end

function CrimeSpreeContractBoxGui:mouse_wheel_down()
end

function CrimeSpreeContractBoxGui:mouse_wheel_up()
end

function CrimeSpreeContractBoxGui:check_grab_scroll_bar()
	return false
end

function CrimeSpreeContractBoxGui:release_scroll_bar()
	return false
end
