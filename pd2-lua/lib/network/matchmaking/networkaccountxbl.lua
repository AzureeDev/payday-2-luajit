require("lib/network/matchmaking/NetworkAccount")

NetworkAccountXBL = NetworkAccountXBL or class(NetworkAccount)

function NetworkAccountXBL:init()
	NetworkAccount.init(self)
end

function NetworkAccountXBL:signin_state()
	local xbl_state = managers.user:signed_in_state(managers.user:get_index())
	local game_signin_state = self:_translate_signin_state(xbl_state)

	return game_signin_state
end

function NetworkAccountXBL:local_signin_state()
	local xbl_state = managers.user:signed_in_state(managers.user:get_index())

	if xbl_state == "not_signed_in" then
		return "not signed in"
	end

	if xbl_state == "signed_in_locally" then
		return "signed in"
	end

	if xbl_state == "signed_in_to_live" then
		return "signed in"
	end

	return "not signed in"
end

function NetworkAccountXBL:show_signin_ui()
end

function NetworkAccountXBL:username_id()
	return Global.user_manager.user_index and Global.user_manager.user_map[Global.user_manager.user_index].username or ""
end

function NetworkAccountXBL:player_id()
	return managers.user:get_xuid(nil)
end

function NetworkAccountXBL:is_connected()
	return true
end

function NetworkAccountXBL:lan_connection()
	return true
end

function NetworkAccountXBL:publish_statistics(stats, force_store)
	Application:error("NetworkAccountXBL:publish_statistics( stats, force_store )")
	Application:stack_dump()
end

function NetworkAccountXBL:challenges_loaded()
	self._challenges_loaded = true
end

function NetworkAccountXBL:experience_loaded()
	self._experience_loaded = true
end

function NetworkAccountXBL:_translate_signin_state(xbl_state)
	if xbl_state == "signed_in_to_live" then
		return "signed in"
	end

	return "not signed in"
end
