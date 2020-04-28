VoteManager = VoteManager or class()
VoteManager.VOTE_EVENT = {
	stopped = 3,
	request_kick = 4,
	server_kick_option = 10,
	instant_kick = 6,
	respond = 2,
	request_restart = 7,
	process_restart = 8,
	process_kick = 5,
	reports = 1,
	instant_restart = 9
}
VoteManager.VOTES = {
	yes = 1,
	cancel = 3,
	none = -1,
	no = 2
}
VoteManager.REASON = {
	invalid_mask = 8,
	invalid_character = 10,
	many_equipments = 5,
	invalid_henchmen = 11,
	many_bags_pickup = 2,
	invalid_player_style = 12,
	wrong_equipment = 6,
	invalid_job = 7,
	many_bags = 3,
	many_assets = 1,
	many_grenades = 4,
	invalid_weapon = 9
}

function VoteManager:init()
end

function VoteManager:kick(peer_id)
	self:_request_vote("kick", self.VOTE_EVENT.request_kick, peer_id)
end

function VoteManager:kick_auto(reason, peer, loading)
	if Network:is_server() then
		if not peer:is_host() then
			if not loading then
				managers.network:session():send_to_peers("kick_peer", peer:id(), 0)
				managers.network:session():on_peer_kicked(peer, peer:id(), 0)
			end

			managers.network:session():send_to_peers_except(peer:id(), "voting_data", self.VOTE_EVENT.instant_kick, peer:id(), reason)
		end
	elseif managers.network:session():local_peer() then
		managers.network:session():on_peer_kicked(managers.network:session():local_peer(), managers.network:session():local_peer():id(), 4)
	end
end

function VoteManager:restart()
	self:_request_vote("restart", self.VOTE_EVENT.request_restart)
end

function VoteManager:restart_auto()
	if managers.network:session() then
		managers.network:session():send_to_peers_except(self._peer_to_exclude, "voting_data", self.VOTE_EVENT.instant_restart, 0, 0)
		self:_restart_counter()
	end
end

function VoteManager:response(state)
	if self._voted or not managers.network:session() then
		return
	end

	self._voted = state

	if Network:is_server() then
		self:_host_register(managers.network:session():local_peer():id(), state)
	else
		managers.network:session():send_to_host("voting_data", self.VOTE_EVENT.respond, state, 0)
	end
end

function VoteManager:abort_vote(peer_id)
	if not self._type then
		return
	end

	self:_host_register(peer_id, self.VOTES.cancel)
end

function VoteManager:available()
	return not self._cooldown and not self._type
end

function VoteManager:kick_reason_to_string(reason)
	local reason_texts = {
		"menu_chat_peer_cheated_many_assets",
		"menu_chat_peer_cheated_many_bags_pickup",
		Network:is_server() and "menu_chat_peer_cheated_many_bags_server" or "menu_chat_peer_cheated_many_bags",
		Network:is_server() and "menu_chat_peer_cheated_many_grenades_server" or "menu_chat_peer_cheated_many_grenades",
		Network:is_server() and "menu_chat_peer_cheated_many_equipments_server" or "menu_chat_peer_cheated_many_equipments",
		Network:is_server() and "menu_chat_peer_cheated_wrong_equipment_server" or "menu_chat_peer_cheated_wrong_equipment",
		"menu_chat_peer_cheated_invalid_job",
		"menu_chat_peer_cheated_invalid_mask",
		"menu_chat_peer_cheated_invalid_weapon",
		"menu_chat_peer_cheated_invalid_character",
		"menu_chat_peer_cheated_invalid_henchmen",
		"menu_chat_peer_cheated_invalid_player_style"
	}

	return reason_texts[reason]
end

function VoteManager:is_restarting()
	return self._callback_type == "restart"
end

function VoteManager:_request_vote(vote_type, vote_network, peer_id)
	if self._type then
		return
	end

	if self._cooldown or self._vote_cooldown and self._vote_cooldown[peer_id] then
		return false
	end

	self._voted = self.VOTES.yes
	self._peer_to_exclude = peer_id
	self._cooldown = TimerManager:wall():time() + tweak_data.voting.cooldown

	if Network:is_server() then
		if self:_host_start(vote_type, managers.network:session():local_peer():id(), peer_id) then
			self:_host_register(managers.network:session():local_peer():id(), self.VOTES.yes)
		end
	elseif managers.network:session() then
		managers.network:session():send_to_host("voting_data", vote_network, peer_id or 0, 0)
	end

	self:_refresh_menu()
end

function VoteManager:_host_start(vote_type, voter_peer_id, kicked_peer_id)
	if self._type then
		return false
	end

	if self._vote_cooldown and self._vote_cooldown[voter_peer_id] then
		return false
	end

	if vote_type == "kick" and kicked_peer_id == 1 then
		return false
	end

	self._type = vote_type
	self._peer_to_exclude = kicked_peer_id
	self._timeout = TimerManager:wall():time() + tweak_data.voting.timeout
	self._vote_cooldown = self._vote_cooldown or {}
	self._vote_cooldown[voter_peer_id] = TimerManager:wall():time() + tweak_data.voting.cooldown
	self._vote_response = {
		[managers.network:session():local_peer():id()] = self.VOTES.none
	}

	for id, peer in pairs(managers.network:session():peers()) do
		if not peer:loading() and id ~= kicked_peer_id then
			self._vote_response[id] = self.VOTES.none
		end
	end

	if vote_type == "kick" then
		managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_vote_kick_started"))
		managers.network:session():send_to_peers_except(self._peer_to_exclude, "voting_data", self.VOTE_EVENT.process_kick, kicked_peer_id, 0)
	elseif vote_type == "restart" then
		managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_vote_restart_started"))
		managers.network:session():send_to_peers("voting_data", self.VOTE_EVENT.process_restart, 0, 0)
	end

	self:_refresh_menu()

	return true
end

function VoteManager:_host_finish(success)
	managers.system_menu:close("vote_data")

	local stop_data = 0

	if success then
		if self._type == "kick" then
			stop_data = self._peer_to_exclude
		elseif self._type == "restart" then
			stop_data = 1
		end
	end

	managers.network:session():send_to_peers_except(self._peer_to_exclude, "voting_data", self.VOTE_EVENT.stopped, stop_data, 0)

	local vote_type = self._type

	self:_stop()

	if success then
		if vote_type == "kick" then
			managers.network:session():send_to_peers("kick_peer", stop_data, 0)

			local peer = managers.network:session():peer(stop_data)

			if peer then
				managers.network:session():on_peer_kicked(peer, stop_data, 0)
			end
		elseif vote_type == "restart" then
			self:_restart_counter()
		end
	end

	self._vote_response = nil
end

function VoteManager:_host_register(peer_id, response)
	if not self._vote_response or not self._vote_response[peer_id] or self._vote_response[peer_id] ~= self.VOTES.none then
		return
	end

	self._vote_response[peer_id] = response

	self:_message(response, peer_id, self._peer_to_exclude)
	managers.network:session():send_to_peers_except(self._peer_to_exclude, "voting_data", self.VOTE_EVENT.reports, peer_id, response)

	local success, final = self:_host_count()

	if final or success then
		self:_host_finish(success)
	end
end

function VoteManager:_host_count(abort)
	local yes_count = 0
	local cancel_count = 0
	local all_voted = true

	for peer_id, value in pairs(self._vote_response) do
		if value == self.VOTES.none then
			all_voted = false

			if abort then
				local timeout_choice = nil

				if self._type == "kick" then
					timeout_choice = self.VOTES.no
				elseif self._type == "restart" then
					timeout_choice = self.VOTES.cancel
					cancel_count = cancel_count + 1
				end

				self:_message(timeout_choice, peer_id, self._peer_to_exclude)
				managers.network:session():send_to_peers_except(self._peer_to_exclude, "voting_data", self.VOTE_EVENT.reports, peer_id, timeout_choice)
			end
		elseif value == self.VOTES.yes then
			yes_count = yes_count + 1
		elseif value == self.VOTES.cancel then
			cancel_count = cancel_count + 1
		end
	end

	local success = nil
	local amount = table.size(self._vote_response) - cancel_count

	if self._type == "kick" then
		if amount == 3 then
			amount = amount + 1

			if self._voted == self.VOTES.yes then
				yes_count = yes_count + 1
			end
		end

		success = yes_count > amount / 2
	elseif self._type == "restart" then
		success = yes_count == amount
	end

	return success, all_voted
end

function VoteManager:_start(type, kick_peer)
	self._type = type
	self._peer_to_exclude = kick_peer
	self._timeout = TimerManager:wall():time() + tweak_data.voting.timeout

	if type == "kick" then
		managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_vote_kick_started"))
	elseif type == "restart" then
		managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_vote_restart_started"))
	end

	self:message_vote()
end

function VoteManager:_stop()
	managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text(self._type == "kick" and "menu_chat_vote_kick_ended" or "menu_chat_vote_restart_ended"))

	self._type = nil
	self._voted = nil
	self._timeout = nil
	self._peer_to_exclude = nil

	managers.system_menu:close("vote_data")
end

function VoteManager:_restart_counter()
	if not self._stopped then
		self._callback_type = "restart"
		self._callback_counter = TimerManager:wall():time() + tweak_data.voting.restart_delay
	end
end

function VoteManager:_message(response, peer_id, kick_peer_id)
	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return
	end

	if response == self.VOTES.cancel then
		managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_vote_cancel", {
			name = peer:name()
		}))
	else
		local kick_peer = kick_peer_id and managers.network:session():peer(kick_peer_id)

		if self._type == "kick" then
			if kick_peer then
				managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text(response == self.VOTES.yes and "menu_chat_vote_kick_yes" or "menu_chat_vote_kick_no", {
					name = peer:name(),
					kick_name = kick_peer:name()
				}))
			else
				managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text(response == self.VOTES.yes and "menu_chat_vote_kick_yes_unknown" or "menu_chat_vote_kick_no_unknown", {
					name = peer:name()
				}))
			end
		elseif self._type == "restart" then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text(response == self.VOTES.yes and "menu_chat_vote_restart_yes" or "menu_chat_vote_restart_no", {
				name = peer:name()
			}))
		end
	end
end

function VoteManager:_refresh_menu()
	if managers.menu:active_menu() and managers.menu:active_menu().logic:selected_node() then
		local name = managers.menu:active_menu().logic:selected_node():parameters().name

		if name == "kick_player" then
			managers.menu:active_menu().logic:refresh_node()
		elseif name == "pause" then
			managers.menu:active_menu().logic:refresh_node()
		end
	end
end

function VoteManager:help_text()
	if not self:available() and self._cooldown then
		return managers.localization:text("menu_vote_kick_cooldown", {
			time = math.ceil(self._cooldown - TimerManager:wall():time())
		})
	end

	return ""
end

function VoteManager:network_package(type, value, result, peer_id)
	if Network:is_server() then
		if type == self.VOTE_EVENT.request_kick then
			if self:_host_start("kick", peer_id, value) then
				self:_host_register(peer_id, self.VOTES.yes)
				self:message_vote()
			end
		elseif type == self.VOTE_EVENT.request_restart then
			if self:_host_start("restart", peer_id) then
				self:_host_register(peer_id, self.VOTES.yes)
				self:message_vote()
			end
		elseif type == self.VOTE_EVENT.respond then
			self:_host_register(peer_id, value)
		end
	elseif type == self.VOTE_EVENT.process_kick then
		self:_start("kick", value)
	elseif type == self.VOTE_EVENT.process_restart then
		self:_start("restart")
	elseif type == self.VOTE_EVENT.stopped then
		local vote_type = self._type

		self:_stop()

		if vote_type == "kick" then
			if value ~= 0 and not managers.network:session():peer(value) then
				managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_kicked_unknown"))
			end
		elseif vote_type == "restart" and value == 1 then
			self:_restart_counter()
		end
	elseif type == self.VOTE_EVENT.reports then
		self:_message(result, value, self._peer_to_exclude)
	elseif type == self.VOTE_EVENT.instant_kick then
		local peer = managers.network:session():peer(value)

		if peer and result ~= 0 then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text(self:kick_reason_to_string(result), {
				name = peer:name()
			}))
		end
	elseif type == self.VOTE_EVENT.instant_restart then
		self:_restart_counter()
	elseif type == self.VOTE_EVENT.server_kick_option then
		Global.game_settings.kick_option_synced = value
	end
end

function VoteManager:update(t, dt)
	local current_time = TimerManager:wall():time()

	if Network:is_server() then
		if self._timeout and self._timeout < current_time then
			local vote_count = 0

			for _, value in pairs(self._vote_response) do
				if value == 1 then
					vote_count = vote_count + 1
				end
			end

			local success = self:_host_count(true)

			self:_host_finish(success)
		end

		if self._vote_cooldown then
			for id, time in pairs(self._vote_cooldown) do
				if time < current_time then
					self._vote_cooldown[id] = nil
				end
			end

			if table.size(self._vote_cooldown) == 0 then
				self._vote_cooldown = nil
			end
		end
	end

	if self._cooldown and self._cooldown < current_time then
		self._cooldown = nil

		self:_refresh_menu()
	end

	if self._callback_counter then
		if managers.platform:presence() == "Mission_end" then
			self._callback_type = nil
		end

		if self._callback_type == "restart" then
			self._callback_counter_print = self._callback_counter_print or tweak_data.voting.restart_delay

			if self._callback_counter_print > self._callback_counter - current_time then
				managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_restart_timer", {
					time = self._callback_counter_print
				}))

				self._callback_counter_print = self._callback_counter_print - 1
			end
		end

		if self._callback_counter < current_time then
			if self._callback_type and self._callback_type == "restart" then
				Telemetry:on_end_heist("restart_game", 0)
			end

			if Network:is_server() and self._callback_type == "restart" then
				managers.game_play_central:restart_the_game()
			end

			self._callback_type = nil
			self._callback_counter = nil
			self._callback_counter_print = nil
		end
	end
end

function VoteManager:stop()
	if self._callback_counter and self._callback_type and self._callback_type == "restart" then
		Telemetry:on_end_heist("restart_game", 0)
	end

	self._callback_type = nil
	self._callback_counter = nil
	self._callback_counter_print = nil
	self._stopped = true
end

function VoteManager:message_vote()
	if not self._type or self._voted or not managers.network:session() then
		return
	end

	if self._type == "kick" and not self:option_vote_kick() then
		return
	end

	if game_state_machine:current_state_name() == "menu_main" then
		if not managers.menu:active_menu() or not managers.menu:active_menu().logic:selected_node() or managers.menu:active_menu().logic:selected_node():parameters().name ~= "lobby" then
			return
		end
	elseif game_state_machine:current_state_name() == "ingame_waiting_for_players" then
		if not managers.menu:active_menu() or not managers.menu:active_menu().logic:selected_node() or managers.menu:active_menu().logic:selected_node():parameters().name ~= "kit" then
			return
		end
	elseif not managers.menu:active_menu() or not managers.menu:active_menu().logic:selected_node() or managers.menu:active_menu().logic:selected_node():parameters().name ~= "pause" then
		return
	end

	local count = math.ceil(self._timeout - TimerManager:wall():time())
	local message = nil
	local dialog_data = {
		id = "vote_data"
	}
	local peer = self._peer_to_exclude and managers.network:session():peer(self._peer_to_exclude)
	local yes_button = {
		callback_func = function ()
			self:response(self.VOTES.yes)
		end
	}
	local no_button = {
		callback_func = function ()
			self:response(self.VOTES.no)
		end
	}
	local cancel_button = {
		text = managers.localization:text("dialog_vote_cancel"),
		callback_func = function ()
			self:response(self.VOTES.cancel)
		end,
		cancel_button = true
	}
	local timeout_choice = nil

	if self._type == "kick" then
		if peer then
			message = "dialog_mp_vote_kick_message"
		else
			message = "dialog_mp_vote_kick_unknown_message"
		end

		dialog_data.title = managers.localization:text("dialog_mp_vote_kick_response_title")
		yes_button.text = managers.localization:text("dialog_vote_kick_yes")
		no_button.text = managers.localization:text("dialog_vote_kick_no")
		timeout_choice = self.VOTES.no
	elseif self._type == "restart" then
		message = "dialog_mp_vote_restart_message"
		dialog_data.title = managers.localization:text("dialog_mp_vote_restart_response_title")
		yes_button.text = managers.localization:text("dialog_yes")
		no_button.text = managers.localization:text("dialog_no")
		timeout_choice = self.VOTES.cancel
	end

	dialog_data.text = managers.localization:text(message, {
		name = peer and peer:name(),
		time = count
	})
	dialog_data.focus_button = 2
	dialog_data.counter = {
		1,
		function ()
			count = count - 1

			if not managers.network:session() then
				managers.system_menu:close(dialog_data.id)
			end

			if count < 0 then
				self:response(timeout_choice)
				managers.system_menu:close(dialog_data.id)
			else
				local dlg = managers.system_menu:get_dialog(dialog_data.id)

				if dlg then
					dlg:set_text(managers.localization:text(message, {
						name = peer and peer:name(),
						time = count
					}), true)
				end
			end
		end
	}
	dialog_data.button_list = {
		yes_button,
		no_button,
		cancel_button
	}

	managers.system_menu:show(dialog_data)
end

function VoteManager:message_host_kick(peer)
	local dialog_data = {
		title = managers.localization:text("dialog_mp_kick_player_title"),
		text = managers.localization:text("dialog_mp_kick_player_message", {
			PLAYER = peer:name()
		})
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = function ()
			if peer then
				managers.network:session():send_to_peers("kick_peer", peer:id(), 0)
				managers.network:session():on_peer_kicked(peer, peer:id(), 0)
			end

			managers.menu:back(true)
		end
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function VoteManager:sync_server_kick_option(peer)
	peer:send("voting_data", self.VOTE_EVENT.server_kick_option, Global.game_settings.kick_option, 0)
end

function VoteManager:option_vote_kick()
	return game_state_machine:current_state_name() ~= "menu_main" and (Network:is_server() and Global.game_settings.kick_option or Global.game_settings.kick_option_synced) == 2
end

function VoteManager:option_host_kick()
	return game_state_machine:current_state_name() == "menu_main" or (Network:is_server() and Global.game_settings.kick_option or Global.game_settings.kick_option_synced) == 1
end

function VoteManager:option_no_kick()
	return (Network:is_server() and Global.game_settings.kick_option or Global.game_settings.kick_option_synced) == 0
end

function VoteManager:option_vote_restart()
	local setting = Network:is_server() and Global.game_settings.kick_option or Global.game_settings.kick_option_synced

	return setting == 2 or setting == 0
end

function VoteManager:option_host_restart()
	return (Network:is_server() and Global.game_settings.kick_option or Global.game_settings.kick_option_synced) == 1
end
