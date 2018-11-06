PlayerAction.StockholmSyndromeTrade = {
	Priority = 1,
	Function = function (pos, peer_id)
		managers.hint:show_hint("skill_stockholm_syndrome_trade")

		local controller = managers.controller:create_controller("player_custody", nil, false)

		controller:enable()

		local quit = false
		local previous_state = game_state_machine:current_state_name()
		local co = coroutine.running()

		while not quit do
			if controller:get_input_pressed("jump") and not managers.hud:chat_focus() then
				if Network:is_server() then
					managers.player:init_auto_respawn_callback(pos, peer_id, true)
					managers.player:change_stockholm_syndrome_count(-1)
				else
					managers.network:session():send_to_host("auto_respawn_player", pos, peer_id)
					managers.network:session():send_to_host("sync_set_super_syndrome", peer_id, false)
				end

				quit = true
			end

			local current_state = game_state_machine:current_state_name()

			if previous_state == "ingame_waiting_for_respawn" and current_state ~= previous_state then
				quit = true
			end

			previous_state = current_state

			coroutine.yield(co)
		end

		controller:destroy()

		controller = nil
	end
}
StockholmSyndromeTradeAction = StockholmSyndromeTradeAction or class()

function StockholmSyndromeTradeAction:init(pos, peer_id)
	self._pos = pos
	self._peer_id = peer_id
end

function StockholmSyndromeTradeAction:on_enter()
	self._controller = managers.controller:create_controller("player_custody", nil, false)

	self._controller:enable()

	self._previous_state = game_state_machine:current_state_name()
	self._quit = false
	self._request_hostage_trade = false
	self._last_can_use = false

	managers.player:register_message(Message.CanTradeHostage, "request_stockholm_syndrome", callback(self, self, "_request_stockholm_syndrome_results"))

	local can_use = managers.trade:is_stockholm_syndrome_allowed()

	if can_use then
		managers.hint:show_hint("stockholm_syndrome_hint")

		self._last_can_use = true
	end
end

function StockholmSyndromeTradeAction:on_exit()
	managers.player:unregister_message(Message.CanTradeHostage, "request_stockholm_syndrome")
	self._controller:destroy()

	self._controller = nil
	self._pos = nil
	self._peer_id = nil
	self._previous_state = nil
	self._quit = nil
	self._request_hostage_trade = nil
end

function StockholmSyndromeTradeAction:update(t, dt)
	local auto_activate = managers.groupai:state():num_alive_criminals() <= 0
	local allowed, feedback_idx = StockholmSyndromeTradeAction.is_allowed()

	if allowed and not self._last_can_use then
		managers.hint:show_hint("stockholm_syndrome_hint")
	end

	if not self._request_hostage_trade and (self._controller:get_input_pressed("jump") and not managers.hud:chat_focus() or auto_activate) then
		local pm = managers.player

		if Network:is_server() then
			if allowed then
				pm:init_auto_respawn_callback(self._pos, self._peer_id, false)
				pm:change_stockholm_syndrome_count(-1)

				self._quit = true
			elseif feedback_idx > 0 and not auto_activate then
				self.on_failure(feedback_idx)
			end
		elseif managers.network:session() then
			managers.network:session():send_to_host("request_stockholm_syndrome", self._pos, self._peer_id, auto_activate)

			self._request_hostage_trade = true
		end
	end

	local current_state = game_state_machine:current_state_name()

	if self._previous_state == "ingame_waiting_for_respawn" and current_state ~= self._previous_state then
		self._quit = true
	end

	self._previous_state = current_state
	self._last_can_use = allowed

	return self._quit
end

local hint_feedback = {
	"stockholm_syndrome_trade",
	"stockholm_syndrome_stealth",
	"stockholm_syndrome_no_hostages"
}

function StockholmSyndromeTradeAction:_request_stockholm_syndrome_results(can_trade, feedback_idx)
	if can_trade then
		self._quit = true

		managers.player:change_stockholm_syndrome_count(-1)
	else
		self._request_hostage_trade = false

		if feedback_idx > 0 then
			StockholmSyndromeTradeAction.on_failure(feedback_idx)
		end
	end
end

function StockholmSyndromeTradeAction.is_allowed()
	local allowed, trade_in_progress, is_in_stealth, no_hostages = managers.trade:is_stockholm_syndrome_allowed()
	local hint_id = 0

	if trade_in_progress then
		hint_id = 1
	elseif is_in_stealth then
		hint_id = 2
	elseif no_hostages then
		hint_id = 3
	end

	return allowed, hint_id
end

function StockholmSyndromeTradeAction.on_failure(feedback_idx)
	managers.hint:show_hint(hint_feedback[feedback_idx])
end
