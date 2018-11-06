NetworkFriendsXBL = NetworkFriendsXBL or class()

function NetworkFriendsXBL:init()
	self._callback = {}
end

function NetworkFriendsXBL:destroy()
end

function NetworkFriendsXBL:set_visible(set)
end

function NetworkFriendsXBL:get_friends_list()
	local player_index = managers.user:get_platform_id()

	if not player_index then
		Application:error("Player map not ready yet.")

		player_index = 0
	end

	local friend_list = XboxLive:friends(player_index)
	local friends = {}

	for i, friend in ipairs(friend_list) do
		table.insert(friends, NetworkFriend:new(friend.xuid, friend.gamertag))
	end

	return friends
end

function NetworkFriendsXBL:get_friends_by_name()
	local player_index = managers.user:get_platform_id()
	local friend_list = XboxLive:friends(player_index)
	local friends = {}

	for i, friend in ipairs(friend_list) do
		friends[friend.gamertag] = friend
	end

	return friends
end

function NetworkFriendsXBL:get_friends()
	if not self._initialized then
		self._initialized = true

		self._callback.initialization_done()
	end
end

function NetworkFriendsXBL:register_callback(event, callback)
	self._callback[event] = callback
end

function NetworkFriendsXBL:send_friend_request(nickname)
end

function NetworkFriendsXBL:remove_friend(id)
end

function NetworkFriendsXBL:has_builtin_screen()
	return true
end

function NetworkFriendsXBL:accept_friend_request(player_id)
end

function NetworkFriendsXBL:ignore_friend_request(player_id)
end

function NetworkFriendsXBL:num_pending_friend_requests()
	return 0
end
