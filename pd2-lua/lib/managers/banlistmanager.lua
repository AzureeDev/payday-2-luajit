BanListManager = BanListManager or class()

function BanListManager:init()
	if not Global.ban_list then
		Global.ban_list = {}
	end

	self._global = self._global or Global.ban_list
	self._global.banned = self._global.banned or {}
end

function BanListManager:ban(identifier, name)
	table.insert(self._global.banned, {
		name = name,
		identifier = identifier
	})
end

function BanListManager:unban(identifier)
	local user_index = nil

	for index, user in ipairs(self._global.banned) do
		if user.identifier == identifier then
			user_index = index

			break
		end
	end

	if user_index then
		table.remove(self._global.banned, user_index)
	end
end

function BanListManager:banned(identifier)
	for _, user in ipairs(self._global.banned) do
		if user.identifier == identifier then
			return true
		end
	end

	return false
end

function BanListManager:ban_list()
	return self._global.banned
end

function BanListManager:save(data)
	data.ban_list = self._global
end

function BanListManager:load(data)
	if data.ban_list then
		Global.ban_list = data.ban_list
		self._global = Global.ban_list
	end
end
