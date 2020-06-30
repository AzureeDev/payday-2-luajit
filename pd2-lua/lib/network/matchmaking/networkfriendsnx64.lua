NetworkFriendsNX64 = NetworkFriendsNX64 or class()

function NetworkFriendsNX64:init()
	cat_print("lobby", "friends = NetworkFriendsNX64")

	self._friends = {}
	self._callback = {}
	self._updated_list_friends = NX64Online:update_list_friends()
	self._last_info = {
		friends = 0,
		friends_map = {},
		friends_status_map = {}
	}

	NX64Online:set_matchmaking_callback("friends_updated", "NetworkFriendsNX64:init", function ()
		managers.network.friends:nx_update_friends()
	end)
	NX64Online:update_async_friends(true, 20)
end

function NetworkFriendsNX64:destroy()
	NX64Online:set_matchmaking_callback("friends_updated", "NetworkFriendsNX64:destroy", function ()
	end)
	NX64Online:update_async_friends(false, 20)
end

function NetworkFriendsNX64:set_visible(set)
	if set == true then
		NX64Online:update_async_friends(true, 5)
	else
		NX64Online:update_async_friends(true, 20)
	end
end

function NetworkFriendsNX64:call_callback(func, ...)
	if self._callback[func] then
		self._callback[func](...)
	else
		Application:error("Callback", func, "is not registred.")
	end
end

function NetworkFriendsNX64:get_friends_list()
	return self._friends

	local npids = {}
	local friends = NX64Online:get_list_friends()

	for _, f in pairs(friends) do
		table.insert(npids, f)
	end

	return npids
end

function NetworkFriendsNX64:get_names_friends_list()
	if not self._updated_list_friends then
		self._updated_list_friends = NX64Online:update_list_friends()
	end

	local names = {}
	local friends = NX64Online:get_list_friends()

	if not friends then
		return names
	end

	for _, f in pairs(friends) do
		if f.friend ~= NX64Online:get_local_userid() then
			names[tostring(f.friend)] = true
		end
	end

	return names
end

function NetworkFriendsNX64:get_NXid_friends_list()
	local NXids = {}
	local friends = NX64Online:get_list_friends()

	if not friends then
		return NXids
	end

	for _, f in pairs(friends) do
		if f.friend ~= NX64Online:get_local_userid() then
			table.insert(NXids, f.friend)
		end
	end

	return NXids
end

function NetworkFriendsNX64:get_friends()
	cat_print("lobby", "NetworkFriendsNX64:get_friends()")

	if not self._updated_list_friends then
		self._updated_list_friends = NX64Online:update_list_friends()
	end

	self._friends = {}
	local name = managers.network.account:player_id()
	local friends = NX64Online:get_list_friends()

	if friends then
		self._last_info.friends = #friends

		self:_fill_li_friends_map(friends)

		self._last_info.friends_status_map = {}

		for k, v in pairs(friends) do
			if tostring(v.friend) ~= name then
				local online_status = "not_signed_in"
				local info_mod = 1
				self._last_info.friends_status_map[tostring(v.friend)] = v.status * info_mod

				if managers.network.matchmake:user_in_lobby(v.friend) then
					online_status = "in_group"
				elseif managers.network:session() and managers.network:session():is_kicked(tostring(v.friend)) then
					online_status = "banned"
				elseif v.status == 0 then
					-- Nothing
				elseif v.status == 1 then
					online_status = "signed_in"
				elseif v.status == 2 then
					online_status = "signed_in"
				end

				local f = NetworkFriend:new(v.friend, v.nickname, online_status)

				table.insert(self._friends, f)
				self:call_callback("status_change", f)
			end
		end

		self:call_callback("get_friends_done", self._friends)
	end
end

function NetworkFriendsNX64:register_callback(event, callback)
	self._callback[event] = callback
end

function NetworkFriendsNX64:send_friend_request(nickname)
end

function NetworkFriendsNX64:remove_friend(id)
end

function NetworkFriendsNX64:has_builtin_screen()
	return true
end

function NetworkFriendsNX64:accept_friend_request(player_id)
end

function NetworkFriendsNX64:ignore_friend_request(player_id)
end

function NetworkFriendsNX64:num_pending_friend_requests()
	return 0
end

function NetworkFriendsNX64:nx_update_friends()
	local friends = NX64Online:get_list_friends() or {}

	if #friends >= 0 then
		local change_of_friends = false

		for k, v in pairs(friends) do
			local friend_in_list = self._last_info.friends_map[tostring(v.friend)]

			if not friend_in_list then
				change_of_friends = true

				break
			end

			self._last_info.friends_map[tostring(v.friend)] = nil
		end

		for k, v in pairs(self._last_info.friends_map) do
			change_of_friends = true

			break
		end

		self:_fill_li_friends_map(friends)

		if change_of_friends then
			self._last_info.friends = #friends
			self._updated_list_friends = NX64Online:update_list_friends()

			self:call_silent_callback("friends_reset")

			return
		elseif self:_count_online(friends) then
			self:call_silent_callback("friends_reset")

			return
		end
	end
end

function NetworkFriendsNX64:is_friend(id)
	local friends = NX64Online:get_list_friends()

	if not friends then
		return false
	end

	for _, data in ipairs(friends) do
		if data.friend == id then
			return true
		end
	end

	return false
end

function NetworkFriendsNX64:_fill_li_friends_map(friends)
	self._last_info.friends_map = {}

	for k, v in pairs(friends) do
		self._last_info.friends_map[tostring(v.friend)] = true
	end
end

function NetworkFriendsNX64:_fill_li_friends_status_map(friends)
	self._last_info.friends_status_map = {}

	for k, v in pairs(friends) do
		local info_mod = 1

		if v.status == 2 and v.info and v.info == managers.platform:presence() then
			info_mod = -1
		end

		self._last_info.friends_status_map[tostring(v.friend)] = v.status * info_mod
	end
end

function NetworkFriendsNX64:_count_online(friends)
	local name = managers.network.account:player_id()
	local status_changed = false

	for k, v in pairs(friends) do
		local friend_status = self._last_info.friends_status_map[tostring(v.friend)] or 42
		local info_mod = 1

		if tostring(v.friend) ~= name and friend_status ~= v.status * info_mod then
			status_changed = true

			break
		end
	end

	if not status_changed then
		return false
	end

	self:_fill_li_friends_status_map(friends)

	return true
end

function NetworkFriendsNX64:nx64_disconnected()
	self._updated_list_friends = false
end
