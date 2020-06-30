require("lib/network/matchmaking/NetworkAccount")

NetworkAccountNX64 = NetworkAccountNX64 or class(NetworkAccount)

function NetworkAccountNX64:init()
	NetworkAccount.init(self)
end

function NetworkAccountNX64:signin_state()
	if NX64Online:is_online() == true then
		return "signed in"
	end

	return "not signed in"
end

function NetworkAccountNX64:local_signin_state()
	local n = NX64Online:get_localinfo()

	if not n then
		return false
	end

	if not n.local_ip then
		return false
	end

	return true
end

function NetworkAccountNX64:show_signin_ui()
end

function NetworkAccountNX64:username_id()
	local online_name = NX64Online:get_username_id()

	if online_name then
		return online_name
	else
		local local_user_info_name = NX64Online:name()

		if local_user_info_name then
			return local_user_info_name
		end
	end

	return managers.localization:text("menu_mp_player")
end

function NetworkAccountNX64:player_id()
	return NX64Online:get_player_id()
end

function NetworkAccountNX64:is_connected()
	return true
end

function NetworkAccountNX64:lan_connection()
	return NX64Online:cable_connected()
end

function NetworkAccountNX64:_lan_ip()
	local l = NX64Online:get_lan_info()

	if l and l.lan_ip then
		return l.lan_ip
	end

	return "player_lan"
end

function NetworkAccountNX64:publish_statistics(stats, force_store)
	Application:error("NetworkAccountNX64:publish_statistics( stats, force_store )")
	Application:stack_dump()
end

function NetworkAccountNX64:achievements_fetched()
	self._achievements_fetched = true
end

function NetworkAccountNX64:challenges_loaded()
	self._challenges_loaded = true
end

function NetworkAccountNX64:experience_loaded()
	self._experience_loaded = true
end
